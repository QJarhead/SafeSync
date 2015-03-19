#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#RequireAdmin
MsgBox(0,"","Script1 is admin: " & IsAdmin())
MsgBox(0,"",@ScriptDir & "\AdminScript2.au3")
RunWait( @ScriptDir & "\AdminScript2.exe")