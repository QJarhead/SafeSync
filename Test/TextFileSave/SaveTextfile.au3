#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <File.au3>
Example()

Func Example()
    ; Create a constant variable in Local scope of the message to display in FileSaveDialog.
    Local Const $sMessage = "Choose a filename."

    ; Display a save dialog to select a file.
    Local $sFileSaveDialog = FileSaveDialog($sMessage, "::{450D8FBA-AD25-11D0-98A8-0800361B1103}", "Scripts (*.ssf)", $FD_PATHMUSTEXIST)
	MsgBox(0,"",$sFileSaveDialog)

	FileDelete($sFileSaveDialog)
	Sleep(100)
	_FileCreate($sFileSaveDialog)
	Sleep(100)
	$SaveFile = FileOpen($sFileSaveDialog,1)
	FileWrite($SaveFile, "Text1 Test2")
	FileClose($SaveFile)
EndFunc   ;==>Example