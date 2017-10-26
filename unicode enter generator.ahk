#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;user settings
triggerhotkey:="break"


;At first search for definition files
files:=Object()
loop,unicode definitions\*.txt
{
	filefound:=true
	files.push({path:A_LoopFileFullPath, name:A_LoopFileName})
}

if (files.MaxIndex() < 1)
{
	MsgBox, 16, Unicode enter generator, Settings file not found. Please a .txt file in the folder "unicode definitions" and run me again.
	FileCreateDir, unicode definitions
	ExitApp
}

;create gui and ask user which definitions to use
filelist:=""
for onefileindex, onefileobj in files
{
	if a_index != 1
		filelist.="|"
	filelist.=onefileobj.name
	
}
gui,add, text, ,Select the definition!
gui,add,DropDownList,vfiledropdown AltSubmit,%filelist%

gui,add,button,vStart gstart, Generate!
gui,show
return

start:
;User has pressed start
gui,submit,NoHide
if filedropdown<1
{
	MsgBox Please select a file
	return
}
gui,destroy
filepath:=files[filedropdown].path
if not fileexist(filepath)
{
	;catch error which normally cannot occur
	MsgBox Sorry. File %filepath% not found
	ExitApp
}

;start showing progress
progresspercentage:=0
progress,AM,,generating unicode enter script,unicode enter generator
settimer, updateprogress,100

;read file definitions
fileencoding, UTF-8
FileRead,file,%filepath%

IfInString,file,`n#include
{
	fileInclude:=substr(file,instr(file, "`n",, instr(file,"`n#include") + 5) +1) 
	file:=substr(file,1,instr(file,"#include")-1) 
}

StringReplace,file,file,`r`n,`n,all
StringReplace,file,file,`t,% " ",all
StringReplace,file,file,% "  ",% " ",all
StringReplace,file,file,% "  ",% " ",all
StringReplace,file,file,% "  ",% " ",all

;Delete old script file
FileDelete, unicode enter script.ahk
;Start creating new script file
addcode("#NoEnv")
addcode("SendMode Input")
addcode("SetWorkingDir %A_ScriptDir%")
addcode("#persistent")
addcode("#hotstring ?*B0")

;Include the content which was defined by user
addcode("`n" fileInclude "`n")

;Shows a new string after keyword was entered
addcode("showNewChar:")
addcode("gosub prepareNewChar")
addcode("return")
addcode(triggerhotkey "::")
addcode("gosub showNextChar")
addcode("return")

;prepares to show a new string
addcode("prepareNewChar:")
addcode("lastsentchar:=""""")
addcode("lastsentindex:=0")
addcode("if instr(a_thishotkey, ""::"")")
addcode("{")
addcode("	lastsentlength:=strlen(substr(a_thishotkey,3))")
addcode("}")
addcode("else")
addcode("{")
addcode("	lastsentlength:=0")
addcode("}")
addcode("return")

;Show the next string. If a string was previously entered, it will be deleted first.
addcode("showNextChar:")
addcode("settimer, turnOffTooltip, off")
addcode("settimer, turnOffHotkeyShowNextChar, off")
;find the next index
addcode("lastsentindex++")
addcode("if (lastsentindex > currentChars.maxindex())")
addcode("	lastsentindex = 1")
;Create the tooltip string. The current char will be shown on top
addcode("currentcharsstring = ")
addcode("currentcharsstring1 = ")
addcode("currentcharsstring2 = ")
addcode("for oneindex, onechar in currentChars")
addcode("{")
addcode("	if (oneindex < lastsentindex)")
addcode("	{")
addcode("		currentcharsstring1.= onechar ")
addcode("		if (CurrentExplanations[oneindex])")
addcode("		{")
addcode("			currentcharsstring1.= ""("" CurrentExplanations[oneindex] "")""")
addcode("		}")
addcode("		currentcharsstring1.= ""``n""")
addcode("	}")
addcode("	else")
addcode("	{")
addcode("		currentcharsstring2.= onechar ")
addcode("		if (CurrentExplanations[oneindex])")
addcode("		{")
addcode("			currentcharsstring2.= ""("" CurrentExplanations[oneindex] "")""")
addcode("		}")
addcode("		currentcharsstring2.= ""``n""")
addcode("	}")
addcode("}")
addcode("currentcharsstring := currentcharsstring2 currentcharsstring1")
addcode("if (A_CaretX && A_CaretY)")
addcode("{")
addcode("	tooltip,% currentcharsstring, % A_CaretX, % A_CaretY +20")
addcode("}")
addcode("else")
addcode("{")
addcode("	tooltip,% currentcharsstring")
addcode("}")
;Delete the old string
addcode("send,{bs %lastsentlength%}")
;Send new string
addcode("sendraw,% currentChars[lastsentindex]")
;keep in mind which string was send last
addcode("lastsentchar:=currentChars[lastsentindex]")
addcode("lastsentlength:=new_strlen(currentChars[lastsentindex])")
;wait until user releases the hotkey
addcode("loop")
addcode("{")
addcode("	if (GetKeyState(""" triggerhotkey """) == False)")
addcode("		break")
addcode("	sleep 10")
addcode("}")
;Set timer in order to remove the tooltip and if user does not press the hotkey for some seconds or presses an other key, pressing # later will have no effect
addcode("settimer, turnOffTooltip, -1000")
addcode("settimer, turnOffHotkeyShowNextChar, -5000")
addcode("settimer, turnOffHotkeyShowNextChar2, 1")
addcode("return")

;remove the hotkey
addcode("turnOffHotkeyShowNextChar:")
addcode("hotkey," triggerhotkey ",showNextChar, off")
addcode("settimer, turnOffHotkeyShowNextChar, off")
addcode("settimer, turnOffHotkeyShowNextChar2, off")
addcode("return")

;Wait user to press any key
addcode("turnOffHotkeyShowNextChar2:")
addcode("Input, SingleKey, L1 T0.2 V, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}")
addcode("if (SingleKey && SingleKey != """ triggerhotkey """)")
addcode("goto turnOffHotkeyShowNextChar")
addcode("return")
addcode("turnOffTooltip:")
addcode("tooltip")
addcode("return")

;Workaround since strlen() does not always have the correct result
addcode("new_strlen(newstrlen_string)")
addcode("{")
addcode("	newstrlen_length:=0")
addcode("	loop,parse,newstrlen_string")
addcode("	{")
addcode("		newstrlen_length++")
addcode("		Transform,newstrlen_charnumber,asc,%A_LoopField%")
addcode("		if (newstrlen_charnumber >= 0xDC00 && newstrlen_charnumber <= 0xDFFF)")
addcode("			newstrlen_length--")
addcode("	}")
addcode("	return newstrlen_length")
addcode("}")

progresspercentage:=1

;start parsing the configurator file
hotkeys:=Object()
allFileEntries:=Object()
loop,parse,file,`n
{
	lineindex:=a_index
	;Search for the "=" character which separates the keywords from the strings
	;there is a workaround to allow the usage of the "=" character as keyword or string. If the "=" is separated by a space on each side, it will be taken as the separator (this way the keys can have other "=" characters which will not be considered).
	pos:=instr(A_LoopField," = ")
	if (not pos)
	{
		pos:=instr(A_LoopField,"=")
	}
	else
	{
		pos+=1
	}
	if (pos) ;If a "=" was found
	{
		namesString:=substr(A_LoopField,1,pos-1) ;get everything from the left
		charsString:=substr(A_LoopField,pos + strlen("=") ) ;get everything from the right
		;~ MsgBox % namesString "---"charsString
		names:=Object()
		chars:=Object()
		expls:=Object()
		
		;Go through all keywords
		loop,parse, namesString,% ","
		{
			onename:=trim(a_loopfield)
			;~ MsgBox name %name%
			if (onename != "")
			{
				names.push(onename)
			}
		}
		
		;Go through all strings
		laststring:=""
		loop,parse, charsString,% ","
		{
			;Allow commas inside the string which are escaped
			if (substr(a_loopfield,-0,1) == "``")
			{
				laststring.=substr(a_loopfield,1,strlen(a_loopfield)-1) ","
			}
			else
			{
				onestring:=trim(laststring a_loopfield)
				laststring := 
				expl:=""
				;if a string has a comment, extract it
				if ((posklammer := instr(onestring,"(")) && (substr(onestring,-0) == ")"))
				{
					expl := substr(onestring,posklammer + 1,strlen(onestring)-1-posklammer)
					onestring := substr(onestring,1,posklammer-1)
					onestring:=trim(onestring)
				}
				if (onestring != "")
				{
					chars.push(onestring)
					expls.push(expl)
				}
			}
		}
		
		;Check whether a keyword or string was found
		if (not names.MaxIndex())
		{
			MsgBox, 48, Unicode enter generator, Warning`, no keyword was found in this line: `n`n%a_loopfield%
		}
		else if (not chars.MaxIndex())
		{
			MsgBox, 48, Unicode enter generator, Warning`, no string was found in this line: `n`n%a_loopfield%
		}
		else
		{
			allFileEntries.push({names:names, chars:chars, explanations:expls})
		}
	}
	else ;If "=" was not found
	{ 
		if (trim(a_loopfield) != "") ;if the line is not empty, show a warning
		{
			MsgBox, 48, Unicode enter generator, Warning`, the equal sign was not found in this line: `n`n%a_loopfield%
		}
	}
}

progresspercentage:=2

;Go through all entries found in file and
;find out wheter the keywords are hotstrings or hotkeys
;Make a list of keywords and find all strings which belong to that keyword
allHotkeys := Object()
allHotstrings := Object()
for oneindex, oneentry in allFileEntries
{
	for onenameindex, onename in oneentry.names ;go through all keywords
	{
		keytype := "hotstring"
		destObject := allHotstrings
		If (substr(onename,1,1) == "{" && substr(onename,-0) == "}")
		{
			keytype:="hotkey"
			destObject := allHotkeys
			keyname := substr(onename,2,strlen(onename)-2)
		}
		else
			keyname := onename
		
		;Check whether the keyword ist present
		if not isobject(destObject[keyname])
		{
			;If keyword is not yet present, create it
			destObject[keyname]:=Object()
			destObject[keyname].chars:=Object()
			destObject[keyname].explanations:=Object()
		}
		for onecharindex, onechar in oneentry.chars
		{
			;Add entry to the keyword
			destObject[keyname].keyname:=keyname
			destObject[keyname].chars.push(onechar)
			destObject[keyname].keytype:=keytype
			;~ MsgBox % onechar " - " oneentry.explanations[onecharindex]
			destObject[keyname].explanations.push(oneentry.explanations[onecharindex])
		}
	}
}

progresspercentage:=3

;Sort all hotstrings by name
;This is necessary because a short hotstring may interrupt a long hotstring if the short hotstring has higher priority.
;This first hotstring mentioned in script will have higher priority than the second.
;By sorting them the long hotstrings will have higher priority than the short ones
allEntriesInverted:=Object()
maxhotstringlength:=0
for onename, oneentry in allHotstrings
{
	strlength:=strlen(oneentry.keyname)
	if (maxhotstringlength < strlength)
		maxhotstringlength := strlength
}
progresspercentage:=4
loop % maxhotstringlength
{
	currstrlen:=a_index
	for onename, oneentry in allHotstrings
	{
		if (strlen(oneentry.keyname) = currstrlen)
			allEntriesInverted.insertat(1,oneentry)
	}
}
progresspercentage:=5
for onename, oneentry in allHotkeys
{
	allEntriesInverted.insertat(1,oneentry)
}

progresspercentage:=6

;At last go through all keywords and write the code to the script
countallEntriesInverted:=allEntriesInverted.MaxIndex()
for oneindex, oneentry in allEntriesInverted
{
	;~ MsgBox % oneentry.keytype " -" oneentry.keyname " - " oneentry.chars[1] "," oneentry.chars[2] "," oneentry.chars[3]
	;Add hotkey or hotstring
	If (oneentry.keytype = "hotkey")
	{
		addcode("~" oneentry.keyname "::")
	}
	else
		addcode("::" oneentry.keyname "::")
	
	;Write variables which will contain the strings and their comments
	codeline:="CurrentChars:= [" 
	codelineexpl:="CurrentExplanations:= [" 
	for onecharindex, onechar in oneentry.chars
	{
		if a_index > 1
		{
			codeline.=", " 
			codelineexpl.=", " 
		}
		codeline.="""" onechar """" 
		codelineexpl.="""" oneentry.explanations[onecharindex] """" 
	}
	
	codeline.="]" 
	codelineexpl.="]" 
	addcode(codeline)
	addcode(codelineexpl)
	
	;Enable hotkey
	addcode("hotkey," triggerhotkey ",showNextChar, on")
	;~ addcode("fileappend,%a_tickcount% %a_thishotkey%, log.txt") ;only for debugging
	addcode("settimer,turnOffHotkeyShowNextChar, -5000") ;disable the hotkey after some seconds
	
	addcode("if (not instr(a_thishotkey,"":?:""))")
	addcode("{")
	 ;If this is a hotkey, only prepare the new char without showing it. It will only be shown when user presses the hotkey
	addcode("	settimer,prepareNewChar,-1")
	addcode("}")
	addcode("else")
	addcode("{")
	;If this is a hotstring, the user already pressed the hotkey. So show the first char
	addcode("	settimer,showNewChar,-1")
	addcode("}")
	addcode("return")
	
	progresspercentage:=6+(94/countallEntriesInverted*A_Index)
}

writefile()
;everything done
progresspercentage = 100
splashtextoff
run, unicode enter script.ahk
ExitApp
return

;Adds code to the script file
addcode(line)
{
	global scriptcode
	scriptcode.= line "`n"
}
writefile()
{
	global scriptcode
	FileAppend, % scriptcode, unicode enter script.ahk
}

guiclose:
ExitApp

updateprogress:
;~ guicontrol,,progressbar, %progresspercentage%
progress,%progresspercentage%
return


;Only for debugging.
;it will open a window whith two edit fields. It will tell you whether the contents of the edit fields are equal.
f12::
gui,compare:default
gui,destroy
gui,add,edit,xm ym vstring1 gcomparestrings
gui,add,edit,X+10 yp vstring2 gcomparestrings
gui,add,text,xm Y+10 vtextequal, Gleich
gui,add,text,xp yp vtextNotequal, Nicht gleich
gui,show
gosub,comparestrings
return

comparestrings:
gui,submit,nohide
if (string1==string2)
{
	guicontrol,show,textequal
	guicontrol,hide,textNotequal
}
else
{
	guicontrol,show,textNotequal
	guicontrol,hide,textequal
}
return