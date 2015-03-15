#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#RequireAdmin

$SafeSyncRegistry = "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync"

Func RegisterFileExtension()
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile", "", "REG_SZ", "SafeSync")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile", "AlwaysShowExt", "REG_SZ", "")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile\DefaultIcon")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile\DefaultIcon", "", "REG_SZ", RegRead($SafeSyncRegistry, "InstallLocation") & "\SafeSync.exe")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile\shell")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile\shell\open")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile\shell\open", "", "REG_SZ", "&Open with SafeSync - Magement Tools")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile\shell\open\command")
	RegWrite( "HKEY_CLASSES_ROOT64\ssffile\shell\open\command", "", "REG_SZ", RegRead($SafeSyncRegistry, "InstallLocation") & "\SafeSync.exe ImportFile %1")
EndFunc

RegisterFileExtension()