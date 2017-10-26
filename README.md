# ahk-unicode-enter
Simple Insertion of unicode characters and abbreviations

## quick start
* rename file "unicode definitions german.txt" to "unicode definitions.txt"
* run "unicode enter generator.ahk". It will generate and start "unicode enter script.ahk"

For everyday use start "unicode enter script.ahk" directly.
You can change the definitions by editing "unicode definitions.txt" then run "unicode enter generator.ahk" again.

## how to use
Enter a keyword and press **#**. Your keyword will be replaced by the first unicode character. If multiple unicode characters have the same keyword you can press **#** multiple times and choose which one you want.

## how to define
You can easily define your own keyword - character pairs. Create a new .txt file in the folder "unicode definitions" (use UTF-8 encoding) and follow those rules:
* write one or multiple keywords separated by comma.
* enter an equal sign: **=**
* write one or multiple characters or strings separated by comma.
* make a linebreak and start from first step

As keyword you can use any string which noes not include spaces or the **#**. You can also specify a hotkey as described in the AutoHotkey Help. Put that hotkey in those Brackets **{}**. Examples: `{left}` or `{^s}` or `{f5}`

You can use the **=** in a keyword, but then you must make sure to put a space on each side of **=**. Example: `/=, =/ = ≠`

You can add comments to each character. Puth them is brackets. Example: `animal = 🐅 (Tiger), 🐁 (Mouse), 🐘 (Elephant)`

If you want a comma to be entered in a string, escape it (`,). You can also enter linefeeds and other special keys as described in the AutoHotkey help.

You can insert variables content by surrounding them with the `"` character. Example: `time = " a_now "`

If you write `#include`, the remainder of the file will be included into your script. This allows you to define your own variables.