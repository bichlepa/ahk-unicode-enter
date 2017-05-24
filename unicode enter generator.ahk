#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if not fileexist("unicode definitions.txt")
{
	MsgBox, 16, Unicode enter generator, Settings file not found. Please create a file named "unicode definitions.txt" in the script folder and run me again.
	ExitApp
}

progresspercentage:=0
;~ gui,add,text,,generating unicode enter script
;~ gui,add,Progress,vprogressbar,0
;~ gui,show, w300
progress,,,generating unicode enter script,unicode enter generator
settimer, updateprogress,100



fileencoding, UTF-8
FileRead,file,unicode definitions.txt
FileDelete, unicode enter script.ahk

StringReplace,file,file,`r`n,`n,all
StringReplace,file,file,`t,% " ",all
StringReplace,file,file,% "  ",% " ",all
StringReplace,file,file,% "  ",% " ",all
StringReplace,file,file,% "  ",% " ",all

addcode("#NoEnv")
addcode("SendMode Input")
addcode("SetWorkingDir %A_ScriptDir%")
addcode("#persistent")
addcode("#hotstring EndChars #")
addcode("sendlevel 1")
addcode("showNewChar:")
addcode("gosub prepareNewChar")
addcode("gosub showNextChar")
addcode("return")
addcode("prepareNewChar:")
addcode("lastsentchar:=""""")
addcode("lastsentindex:=0")
addcode("lastsentlength:=0")
addcode("lastsentlength:=0")
addcode("return")
addcode("showNextChar:")
addcode("settimer, turnOffTooltip, off")
addcode("settimer, turnOffHotkeyShowNextChar, off")
addcode("lastsentindex++")
addcode("if (lastsentindex > currentChars.maxindex())")
addcode("	lastsentindex = 1")
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
addcode("send,{bs %lastsentlength%}")
addcode("sendraw,% currentChars[lastsentindex]")
addcode("lastsentchar:=currentChars[lastsentindex]")
addcode("lastsentlength:=strlen(currentChars[lastsentindex])")
addcode("loop")
addcode("{")
addcode("	if (GetKeyState(""#"") == False)")
addcode("		break")
addcode("	sleep 10")
addcode("}")
addcode("settimer, turnOffTooltip, -1000")
addcode("settimer, turnOffHotkeyShowNextChar, -5000")
addcode("settimer, turnOffHotkeyShowNextChar2, 1")
addcode("return")
addcode("turnOffHotkeyShowNextChar:")
addcode("hotkey,#,showNextChar, off")
addcode("settimer, turnOffHotkeyShowNextChar, off")
addcode("settimer, turnOffHotkeyShowNextChar2, off")
addcode("return")
addcode("turnOffHotkeyShowNextChar2:")
addcode("Input, SingleKey, L1 T0.2 V, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}")
addcode("if (SingleKey && SingleKey != ""#"")")
addcode("goto turnOffHotkeyShowNextChar")
addcode("return")
addcode("turnOffTooltip:")
addcode("tooltip")
addcode("return")

progresspercentage:=1

hotkeys:=Object()
allFileEntries:=Object()
loop,parse,file,`n
{
	pos:=instr(A_LoopField," = ")
	lineindex:=a_index
	if (pos)
	{
		namesString:=substr(A_LoopField,1,pos-1)
		charsString:=substr(A_LoopField,pos + strlen(" = "))
		;~ MsgBox % namesString "---"charsString
		names:=Object()
		chars:=Object()
		expls:=Object()
		loop,parse, namesString,% ","
		{
			onename:=trim(a_loopfield)
			;~ MsgBox name %name%
			if (onename != "")
			{
				names.push(onename)
			}
			
			
		}
		loop,parse, charsString,% ","
		{
			onestring:=trim(a_loopfield)
			expl:=""
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
		if (names.MaxIndex() && chars.MaxIndex())
			allFileEntries.push({names:names, chars:chars, explanations:expls})
	}
}
progresspercentage:=2

allHotkeys := Object()
allHotstrings := Object()
for oneindex, oneentry in allFileEntries
{
	for onenameindex, onename in oneentry.names
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
		
		if not isobject(destObject[keyname])
		{
			destObject[keyname]:=Object()
			destObject[keyname].chars:=Object()
		}
		for onecharindex, onechar in oneentry.chars
		{
			destObject[keyname].keyname:=keyname
			destObject[keyname].chars.push(onechar)
			destObject[keyname].keytype:=keytype
			destObject[keyname].explanations:=oneentry.explanations
		}
	}
}
progresspercentage:=3

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
countallEntriesInverted:=allEntriesInverted.MaxIndex()
for oneindex, oneentry in allEntriesInverted
{
	;~ MsgBox % oneentry.keytype " -" oneentry.keyname " - " oneentry.chars[1] "," oneentry.chars[2] "," oneentry.chars[3]
	If (oneentry.keytype = "hotkey")
	{
		addcode("~" oneentry.keyname "::")
	}
	else
		addcode(":?:" oneentry.keyname "::")
	
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
	addcode("hotkey,#,showNextChar, on")
	addcode("fileappend,%a_tickcount% %a_thishotkey%, log.txt")
	addcode("settimer,turnOffHotkeyShowNextChar, -5000")
	addcode("if (not instr(a_thishotkey,"":?:""))")
	addcode("{")
	addcode("	settimer,prepareNewChar,-1")
	addcode("}")
	addcode("else")
	addcode("{")
	addcode("	settimer,showNewChar,-1")
	addcode("}")
	addcode("return")
	
	progresspercentage:=6+(94/countallEntriesInverted*A_Index)
}
progresspercentage = 100
splashtextoff
run, unicode enter script.ahk
ExitApp
return

addcode(line)
{
	FileAppend, % line "`n", unicode enter script.ahk
}


guiclose:
ExitApp

updateprogress:
;~ guicontrol,,progressbar, %progresspercentage%
progress,%progresspercentage%
return



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