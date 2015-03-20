#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <MsgBoxConstants.au3>



Local Const $sFilePath = @DesktopDir & "\FileCreateShortcutExample.lnk"
Local $ShortcutDir = @AppDataDir & "\Microsoft\Windows\Start Menu\Programs\SafeSync"
FileCreateShortcut(@ProgramFilesDir & "\SafeSync.exe", $ShortcutDir & "\SafeSync.lnk")