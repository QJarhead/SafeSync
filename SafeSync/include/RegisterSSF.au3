#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=SafeSync_265.ico
#AutoIt3Wrapper_Outfile_x64=C:\include\RegisterSSF.Exe
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here


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

	MsgBox(0,"Success","File-Extension support was installed successfully")

EndFunc

RegisterFileExtension()