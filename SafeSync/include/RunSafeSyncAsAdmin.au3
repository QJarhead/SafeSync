#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#RequireAdmin
MsgBox(0,"RunSafeSyncAsAdmin",$CmdLine[1])
Run($CmdLine[1])