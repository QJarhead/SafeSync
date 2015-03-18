#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#RequireAdmin

; Delete Registry

Local $aProcessList = ProcessList("SafeSync.exe")
For $i = 1 To $aProcessList[0][0]
	ProcessClose ( $aProcessList[$i][1] )
Next

DirRemove( RegRead( "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync", "InstallLocation"), 1)
DirRemove( RegRead( "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeCrypt", "InstallLocation"), 1)
RegDelete("HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync")
RegDelete("HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeCrypt")
RegDelete("HKEY_CURRENT_USER\Software\SafeCrypt")
RegDelete("HKEY_CURRENT_USER\Software\SafeSync")
RegDelete( "HKEY_CLASSES_ROOT64\ssffile")