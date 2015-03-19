#RequireAdmin
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

$SafeSyncRegistry = "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync"
$SafeSyncInstallLocation = RegRead("HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync", "InstallLocation")

Func RegisterFileExtension()
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf", "", "REG_SZ", "SafeSync")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf", "AlwaysShowExt", "REG_SZ", "")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf\DefaultIcon")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf\DefaultIcon", "", "REG_SZ", RegRead($SafeSyncRegistry, "InstallLocation") & "\SafeSync.exe")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf\shell")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf\shell\open")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf\shell\open", "", "REG_SZ", "&Open with SafeSync - Magement Tools")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf\shell\open\command")
	RegWrite( "HKEY_CLASSES_ROOT64\.ssf\shell\open\command", "", "REG_SZ", RegRead($SafeSyncRegistry, "InstallLocation") & "\SafeSync.exe ImportFile %1")
	RegWrite( "HKEY_CLASSES_ROOT64\Folder\shell\Sync with SafeSync")
	RegWrite( "HKEY_CLASSES_ROOT64\Folder\shell\Sync with SafeSync\command")
	RegWrite( "HKEY_CLASSES_ROOT64\Folder\shell\Sync with SafeSync\command", "", "REG_SZ", $SafeSyncInstallLocation & '\SafeSync.exe SyncNewFolder "%1"')
EndFunc

RegisterFileExtension()