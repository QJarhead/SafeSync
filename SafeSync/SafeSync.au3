#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=include\SafeSync_265.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

AutoIt Version: 	3.3.12.0
Author:				Tim Christoph Lid
Version:			0.0.1.6
Name:				SafeSync Management Tool

TODO:
Testing
Complete the GUI

Maybe:
KEY ist correct?
Folder is  already in use
Name ist already in use
Check if BTSync is running
Check if BTSync is running

Issues:

#NoTrayIcon

#ce ----------------------------------------------------------------------------

#cs ----------------------------------------------------------------------------

SafeSync Version Info

#ce ----------------------------------------------------------------------------

; DisplayName for installation
Global Const $SafeSyncDisplayName = "SafeSync"
; DisplayVersion for installation
Global Const $SafeSyncDisplayVersion = "0.0.1"
; DisplayVersion for installation
Global Const $SafeSyncPublisher = "SafeSync - Team"

#cs ----------------------------------------------------------------------------

Including

#ce ----------------------------------------------------------------------------

; Ínclude everything
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <File.au3>
#include <GuiImageList.au3>
#include <IE.au3>
#include <INet.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>

; Including files
FileInstall("C:\include\BitTorrent_SyncX64.exe", @TempDir & "\BitTorrent_SyncX64.exe", 1)
FileInstall("C:\include\config.ini", @TempDir & "\config.ini", 1)
FileInstall("C:\include\RegisterSSF.exe", @TempDir & "\RegisterSSF.exe", 1)
FileInstall("C:\include\UninstallSafeSync.exe", @TempDir & "\UninstallSafeSync.exe", 1)
FileInstall("C:\include\InstallSafeSync.exe", @TempDir & "\InstallSafeSync.exe", 1)
FileInstall("C:\include\RunSafeSyncAsAdmin.exe", @TempDir & "\RunSafeSyncAsAdmin.exe", 1)
FileInstall("C:\include\7z938-x64.msi", @TempDir & "\7z938-x64.msi", 1)
FileInstall("C:\include\SafeCrypt.msi", @TempDir & "\SafeCrypt.msi", 1)

#cs ----------------------------------------------------------------------------

Static-Variables SafeSync

#ce ----------------------------------------------------------------------------

; SafeSync Registry Uninstall
Global Const $SafeSyncRegistryUninstall = "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync"
; SafeSync Registry
Global Const $SafeSyncRegistrySoftware = "HKEY_CURRENT_USER64\Software\SafeSync"
; SafeSyncManagementool Registry
Global Const $SafeSyncRegistrySoftwareManagementTool = "HKEY_CURRENT_USER64\Software\SafeSync\ManagementTool"
; SafeSync Folders
Global Const $SafeSyncRegistryFolders = $SafeSyncRegistrySoftware & "\ManagementTool\Folders"
; Run SafeSyncAsAdmin
Global Const $RunSafeSyncAsAdmin = @TempDir & "\RunSafeSyncAsAdmin.exe " & @ScriptFullPath
; SafeSync ShortcutFolder
Global Const $SafeSyncShortcutFolder = @AppDataDir & "\Microsoft\Windows\Start Menu\Programs\SafeSync"

#cs ----------------------------------------------------------------------------

Static-Variables SafeCrypt

#ce ----------------------------------------------------------------------------

; SafeCrypt Registry Uninstall
Global Const $SafeCryptRegistryUninstall = "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeCrypt"
; SafeCrypt Registry
Global Const $SafeCryptRegistrySoftware = "HKEY_CURRENT_USER64\Software\SafeSync\SafeCrypt"
; SafeCrypt Folders
Global Const $SafeCryptRegistryFolders = $SafeCryptRegistrySoftware & "\Folders"

#cs ----------------------------------------------------------------------------

Static-Variables BitTorrent Sync

#ce ----------------------------------------------------------------------------

; Bittorent Sync Uninstall String
Global Const $BTSyncRegistryUninstall = "HKEY_LOCAL_MACHINE64\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BitTorrent Sync"
; InstallationLocationBTSync
Global Const $InstallationLocationBTSync = @UserProfileDir & "\Program Files\BitTorrent Sync"
; ConfigFile for BitTorrent Sync
Global Const $BTSyncConfig = "C://Users/Tim/Program Files/BitTorrent Sync/config.json"
Global Const $BTSyncStoragePath = "C:/Users/Tim/Program Files/BitTorrent Sync/StoragePath"


; Temp Dir for BitTorrent_SyncX64.exe
Global Const $BTSyncInstaller = @TempDir & "\BitTorrent_SyncX64.exe"

#cs ----------------------------------------------------------------------------

Static-Variables 7zip

#ce ----------------------------------------------------------------------------

; Bittorent Sync Uninstall String
Global Const $7ZipRegistrySoftware = "HKEY_CURRENT_USER64\Software\7-Zip"
; 7zip EXE Location
Global Const $7zipInstaller = @TempDir & "\7z938-x64.msi"

#cs ----------------------------------------------------------------------------

Static-Variables

#ce ----------------------------------------------------------------------------

; For running _PathSplit()
Global $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""

#cs ----------------------------------------------------------------------------

Non-Static-Variables

#ce ----------------------------------------------------------------------------

ReadRegistry()
Func ReadRegistry()
	; Read SafeSync Standard Data Folder
	Global $SafeSyncStandardDataFolder =RegRead( "HKEY_CURRENT_USER64\Software\SafeSync\ManagementTool", "DataDir")
	If $SafeSyncStandardDataFolder = "" Then
		MsgBox( 0,"Warning","Please choose a Folder, for your Data")
		$SafeSyncStandardDataFolder = FileSelectFolder( "Choose the destination folder", "C:\")
		RegWrite("HKEY_CURRENT_USER64\Software\SafeSync\ManagementTool", "DataDir", "REG_SZ", $SafeSyncStandardDataFolder)
	EndIf
	; Read SafeCrypt Location from Registry
	Global $SafeCryptInstallDir = RegRead( "HKEY_CURRENT_USER64\Software\SafeSync\SafeCrypt", "InstallDir")
	; Read SafeCrypt Location from Registry
	Global $InstallLocationSafeSync = RegRead( $SafeSyncRegistrySoftwareManagementTool, "InstallDir")
	; Read BTSyncShowGUI show GUI Option
	Global $BTSyncShowGUI = RegRead( $SafeSyncRegistrySoftwareManagementTool, "ShowGUI")
	If $BTSyncShowGUI = "" Then
		$BTSyncShowGUI = "false"
	EndIf
	; SafeSyncExe
	Global $SafeSyncExe = $InstallLocationSafeSync & "\SafeSync.exe"
	;Column width in GUI for Name TODO: In Registry
	Global $ColumnWitdhName = 80
	;Column width in GUI for Key TODO: In Registry
	Global $ColumnWitdhKey = 280
	;Column width in GUI for Path TODO: In Registry
	Global $ColumnWitdhPath = 250
	;Column width in GUI for EncryptPath TODO: In Registry
	Global $ColumnWitdhEncrypt = 240
EndFunc

#cs ----------------------------------------------------------------------------

Option Variables

#ce ----------------------------------------------------------------------------


;---------------------------------------------------------------------------------------

; Read command line parameters
; Create Registry, if an external file is open with command line parameter "ImportFile"
If Not $CmdLine[0] = 0 Then
	If $CmdLine[1] == "ImportFile" Then
		; Open the File
		FileOpen( $CmdLine[2] )
		Local $NewFolderKey = StringRight( FileReadLine( $CmdLine[2], 1),StringLen(FileReadLine( $CmdLine[2], 1)) - StringInStr( FileReadLine( $CmdLine[2], 1), " " ))
		Local $NewFolderNameWithSpace = StringLeft( FileReadLine( $CmdLine[2], 1),StringInStr( FileReadLine( $CmdLine[2], 1), " " ))
		Local $NewFolderName = StringLeft($NewFolderNameWithSpace,StringLen($NewFolderNameWithSpace)-1)
		Local $arr[2]
		$arr = ChooseDecryptEncryptFolder($NewFolderName, "")
		RegWrite($SafeSyncRegistrySoftwareManagementTool,"refreshGUI","REG_SZ","1")
		RegistryCreateNewFolder($arr[0], $arr[1], $NewFolderName, $NewFolderKey)
		Exit
	ElseIf $CmdLine[1] == "SyncNewFolder" Then
		SyncNewFolder($CmdLine[2])
		Exit
	EndIf
	; Command line parameter for uninstalling SafeSync
	If $CmdLine[1] == "/UNINSTALL" Then
		Uninstall()
		Exit
	EndIf
EndIf

#cs ----------------------------------------------------------------------------

Install Programms

#ce ----------------------------------------------------------------------------

#cs ----------------------------------------------------------------------------
Install BitTorrent Sync 1.4 if not installed yet
#ce ----------------------------------------------------------------------------
If RegRead( $BTSyncRegistryUninstall, "DisplayIcon") == "" Then
	RunWait( '"' & $BTSyncInstaller & '" /PERFORMINSTALL /AUTOMATION')
EndIf

#cs ----------------------------------------------------------------------------
Install SafeCrypt if not installed yet
#ce ----------------------------------------------------------------------------

If RegRead( "HKEY_CURRENT_USER64\Software\SafeSync\SafeCrypt", "InstallDir") = "" Then
	ConsoleWrite( "Install SafeCrypt" & @CRLF)
	RunWait(@ComSpec & ' /c ' & @TempDir & "\SafeCrypt.msi", @TempDir, @SW_HIDE)
	ReadRegistry()
EndIf

#cs ----------------------------------------------------------------------------
Install 7Zip if not installed yes
#ce ----------------------------------------------------------------------------
RegRead($7ZipRegistrySoftware,"Path")
If @error Then
	ConsoleWrite( "Install 7zip" )
	CheckAdmin()
	RunWait(@ComSpec & ' /c ' & $7zipInstaller & "/quiet /passive ", @TempDir , @SW_HIDE)
EndIf

#cs ----------------------------------------------------------------------------
Install SafeSync if not installed yes
#ce ----------------------------------------------------------------------------TODO
If RegRead($SafeSyncRegistrySoftware, "FileRegistered") = 0 Then
	ConsoleWrite("FileRegister" & @CRLF)
	RegisterFileExtension($InstallLocationSafeSync,$SafeSyncStandardDataFolder)
	ConsoleWrite("Ready" & @CRLF)
EndIf

#cs ----------------------------------------------------------------------------

SetVariables after Installation

#ce ----------------------------------------------------------------------------

ReadRegistry()

#cs ----------------------------------------------------------------------------

GUI

#ce ----------------------------------------------------------------------------

; Settings Menu entries
Global $SafeSyncManagementTool = GUICreate("SafeSyncManagementTool", 915, 437, 195, 124)
$MenuFile = GUICtrlCreateMenu("&File")
$MenuRefresh = GUICtrlCreateMenuItem("Refresh", $MenuFile)
$MenuNew = GUICtrlCreateMenuItem("New", $MenuFile)
$MenuDelete = GUICtrlCreateMenuItem("Delete", $MenuFile)
$MenuExport = GUICtrlCreateMenuItem("Export", $MenuFile)
$MenuExit = GUICtrlCreateMenuItem("Exit", $MenuFile)
$MenuSettings = GUICtrlCreateMenu("&Settings")
$MenuBitTorrent = GUICtrlCreateMenuItem("BitTorrent", $MenuSettings)
$MenuCrypt = GUICtrlCreateMenuItem("Crypt-Safe", $MenuSettings)
$MenuOther = GUICtrlCreateMenuItem("Other", $MenuSettings)
$MenuInfo = GUICtrlCreateMenu("&Info")
$MenuAbout = GUICtrlCreateMenuItem("About", $MenuInfo)

;Functions for Menu/Button
;GUICtrlSetOnEvent($MenuNew, "MenuNew")
;GUICtrlSetOnEvent($MenuDelete, "MenuDelete")
;GUICtrlSetOnEvent($MenuExport, "MenuExport")
;GUICtrlSetOnEvent($MenuExit, "MenuExit")
;GUICtrlSetOnEvent($MenuBitTorrent, "MenuBitTorrent")
;GUICtrlSetOnEvent($MenuCrypt, "MenuCrypt")
;GUICtrlSetOnEvent($MenuOther, "MenuOther")
;GUICtrlSetOnEvent($MenuAbout, "MenuAbout")
;GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

; Create ListView
Local $idListview = GUICtrlCreateListView("Name|Key|EncryptLocation|Location", 10, 10, 895, 395) ;,$LVS_SORTDESCENDING)

;Initial reloading list View
ReloadListView()

; Set the column witdh
_GUICtrlListView_SetColumnWidth($idListview, 0, $ColumnWitdhName)
_GUICtrlListView_SetColumnWidth($idListview, 1, $ColumnWitdhKey)
_GUICtrlListView_SetColumnWidth($idListview, 2, $ColumnWitdhPath)
_GUICtrlListView_SetColumnWidth($idListview, 3, $ColumnWitdhEncrypt)
GUISetState(@SW_SHOW)
Global $Form1 = GUICreate("Form1", 165, 160, 200, 124)
$Radio1 = GUICtrlCreateRadio("Generate new Key", 32, 20, 113, 25)
GUICtrlSetState(-1, $GUI_CHECKED)
$Radio3 = GUICtrlCreateRadio("Manual", 32, 60, 113, 17)
$Button1 = GUICtrlCreateButton("Button1", 32, 100, 91, 33)

GUISwitch($SafeSyncManagementTool)

Local $aProcessList = ProcessList("SafeCrypt.exe")
For $i = 1 To $aProcessList[0][0]
	ProcessClose ( $aProcessList[$i][1] )
Next

;Start SafeCrypt
Run( $SafeCryptInstallDir & "/SafeCrypt.exe")
Opt('TrayOnEventMode', 1)
Opt('TrayMenuMode', 1)
TraySetOnEvent( -7, '_Restore')

; Running the Gui in Loop
While 1
	$nMsg = GUIGetMsg(1)
	$RefreshGUI =RegRead( $SafeSyncRegistrySoftwareManagementTool, "RefreshGUI")
	If $RefreshGUI = 1 Then
		ReloadListView()
	EndIf
	Switch $nMsg[0] ; check which GUI sent the message
		Case $GUI_EVENT_CLOSE
			Switch $nMsg[1]
				Case $Form1
					GUISetState(@SW_SHOW,$SafeSyncManagementTool)
					GUISetState(@SW_HIDE,$Form1)
					GUISwitch($SafeSyncManagementTool)
				Case $SafeSyncManagementTool
					$iMsgBoxAnswer = MsgBox(33,"Quit SafeSync?","Do you want to quit Safe-Sync?" & @CRLF & "You can also minize it," & @CRLF & " to run it in the background." & @CRLF & "Otherwise the Data will not be secure!")
					Select
						Case $iMsgBoxAnswer = 1
							StopBTSync()
							StopProcess("SafeCrypt.exe")
							GUISetState(@SW_HIDE, $SafeSyncManagementTool)
							ExitLoop
						Case $iMsgBoxAnswer = 2
					EndSelect
			EndSwitch
		Case $GUI_EVENT_MINIMIZE
			TraySetState(1)
			GUISetState(@SW_HIDE)
		Case $MenuNew
			GUISetState(@SW_SHOW,$Form1)
			GUISetState(@SW_HIDE,$SafeSyncManagementTool)
		Case $MenuDelete
			MenuDelete()
		Case $MenuRefresh
			ReloadListView()
		Case $MenuExport
			MenuExport()
		Case $MenuExit
			MenuExit()
		Case $MenuBitTorrent
			MenuBitTorrent()
		Case $MenuCrypt
			MenuCrypt()
		Case $MenuOther
			MenuOther()
		Case $MenuAbout
			MenuAbout()
		Case $Button1
			Select
				Case BitAND(GUICtrlRead($Radio1), $GUI_CHECKED) = $GUI_CHECKED
					Local $NewFolderKey = getNewKey()
					Local $NewFolderName = InputBox("Folder Name", "Enter new foldername")
					Local $arr[2]
					$arr = ChooseDecryptEncryptFolder($NewFolderName, "")
					$NewFolderKeyDataDecrypt = $arr[0]
					$NewFolderKeyDataEncrypt = $arr[1]
					RegistryCreateNewFolder($NewFolderKeyDataDecrypt, $NewFolderKeyDataEncrypt, $NewFolderName, $NewFolderKey)
					ReloadListView()
					GUISetState(@SW_SHOW,$SafeSyncManagementTool)
					GUISetState(@SW_HIDE,$Form1)
				Case BitAND(GUICtrlRead($Radio3), $GUI_CHECKED) = $GUI_CHECKED
					Local $NewFolderName = InputBox("Folder Key", "Enter folder Key", "", "")
					Local $NewFolderKey = InputBox("Folder Name", "Enter folder key", "", "")
					Local $arr[2]
					$arr = ChooseDecryptEncryptFolder($NewFolderName, "")
					$NewFolderKeyDataDecrypt = $arr[0]
					$NewFolderKeyDataEncrypt = $arr[1]
					RegistryCreateNewFolder($NewFolderKeyDataDecrypt, $NewFolderKeyDataEncrypt, $NewFolderName, $NewFolderKey)
					ReloadListView()
					GUISetState(@SW_SHOW,$SafeSyncManagementTool)
					GUISetState(@SW_HIDE,$Form1)
        EndSelect
   EndSwitch
WEnd

Func _Restore()
	TraySetState(2)
	GUISetState(@SW_SHOW,$SafeSyncManagementTool)
	WinActivate("SafeSyncManagementTool")
EndFunc

#cs ----------------------------------------------------------------------------

Functions

#ce ----------------------------------------------------------------------------

#cs ----------------------------------------------------------------------------
Install
Install - Process
#ce ----------------------------------------------------------------------------

Func Install()
    ; Create a GUI with various controls.
    Local $InstallationDialog = GUICreate("SafeSync - Installation", 430,170)
    Local $InstallButton = GUICtrlCreateButton("Install", 320, 130, 85, 25)
    Local $InstallDirectory = GUICtrlCreateLabel("Installation dir:",10,20)
	Local $InstallDir = GUICtrlCreateInput(@ProgramFilesDir & "\SafeSync", 10, 38, 300)
	Local $InstallDirSelect = GUICtrlCreateButton( "SelectFolder", 320,36,100)
	Local $DataDirectory = GUICtrlCreateLabel("Standard Data Directory:",10,70)
	Local $DataDir = GUICtrlCreateInput(@UserProfileDir & "\Documents\Data", 10, 88, 300)
	Local $DataDirSelect = GUICtrlCreateButton( "SelectFolder", 320,86,100)
	;Local $DataCryptDirectory = GUICtrlCreateLabel("CryptDirectory:",10,120)
	;Local $DataCryptDir = GUICtrlCreateInput($InstallLocationSafeSync & "\Crypt", 10, 138, 300)
	;Local $DataCryptDirSelect = GUICtrlCreateButton( "SelectFolder", 320,136,100)
    ; Display the GUI.
    GUISetState(@SW_SHOW, $InstallationDialog)
    ; Loop until the user exits.
    While 1
        Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit
                ExitLoop
			Case $InstallButton
				RegWrite( $SafeSyncRegistryUninstall)
				RegWrite( $SafeSyncRegistryUninstall, "DisplayIcon", "REG_SZ", GUICtrlRead($InstallDir) & "\SafeSync.exe")
				RegWrite( $SafeSyncRegistryUninstall, "DisplayName", "REG_SZ", $SafeSyncDisplayName)
				RegWrite( $SafeSyncRegistryUninstall, "DisplayVersion", "REG_SZ", $SafeSyncDisplayVersion)
				RegWrite( $SafeSyncRegistryUninstall, "InstallLocation", "REG_SZ", GUICtrlRead($InstallDir) )
				RegWrite( "HKEY_CURRENT_USER64\Software\SafeSync", "InstallDir", "REG_SZ", GUICtrlRead($InstallDir) )
				RegWrite( "HKEY_CURRENT_USER64\Software\SafeSync", "DataDir", "REG_SZ", GUICtrlRead($DataDir))
				RegWrite( $SafeSyncRegistryUninstall, "Publisher", "REG_SZ", $SafeSyncPublisher)
				RegWrite( $SafeSyncRegistryUninstall, "UninstallString", "REG_SZ", GUICtrlRead($InstallDir) & "\SafeSync.exe /UNINSTALL")
				$SafeSyncDataFolder = RegRead( $SafeSyncRegistryUninstall, "DataFolder")
				$SafeSyncDataCryptFolder = RegRead( $SafeSyncRegistryUninstall, "DataCryptFolder")
				RegisterFileExtension(GUICtrlRead($InstallDir),GUICtrlRead($DataDir))
				FileCopy( @TempDir & "/InstallSafeSync.exe", GUICtrlRead($InstallDir) & "/")
				;Start SafeCrypt
				Run( $SafeCryptInstallDir & "/SafeCrypt.exe")
				; TODO Copy other files and create folder
				ExitLoop
			Case $InstallDirSelect
				GUICtrlSetData( $InstallDir, FileSelectFolder( "Choose the destination folder", $InstallLocationSafeSync))
			Case $DataDirSelect
				GUICtrlSetData( $DataDir, FileSelectFolder( "Choose Standard Data Folder", $InstallLocationSafeSync))
        EndSwitch
    WEnd

	;Read SafeSync Standard Data folder from Registry
	$SafeSyncStandardDataFolder =RegRead( "HKEY_CURRENT_USER64\Software\SafeSync", "DataDir")
	; Read SafeCrypt Location from Registry
	$InstallLocationSafeCrypt = RegRead( "HKEY_CURRENT_USER64\Software\SafeSync\SafeCrypt", "InstallDir")
	; Read SafeCrypt Location from Registry
	$InstallLocationSafeSync = RegRead( "HKEY_CURRENT_USER64\Software\SafeSync", "InstallDir")
	DirCreate( $SafeSyncShortcutFolder )
	CreateShortcut($InstallLocationSafeSync & "\SafeSync.exe", $SafeSyncShortcutFolder & "\SafeSync.lnk")

    GUIDelete($InstallationDialog)
EndFunc

#cs ----------------------------------------------------------------------------
Uninstall
The Uninstall Process
#ce ----------------------------------------------------------------------------
Func Uninstall()
	; Registry Cleanup
	If MsgBox(4, "Uninstall?", "Uninstall SafeSync?") <> 6 Then
		Exit
	Else
		StopBTSync()
		RunWait( RegRead( $BTSyncRegistryUninstall, "UninstallString"))
		Run( @ComSpec & ' /c ' & @TempDir & "\UninstallSafeSync.exe ", @TempDir , @SW_HIDE )
	EndIf
	Exit
EndFunc

#cs ----------------------------------------------------------------------------
Uninstall
The Uninstall Process
#ce ----------------------------------------------------------------------------
Func CreateShortcut($ShortcutSourceFile, $ShortcutDestinationFile)
	FileCreateShortcut($ShortcutSourceFile, $ShortcutDestinationFile)
EndFunc

#cs ----------------------------------------------------------------------------
SyncNewFolder
Create new Folder by clicking Sync with SafeSync from Context menu
#ce ----------------------------------------------------------------------------
Func SyncNewFolder($NewFolderName)
	Global $ChooseForm = GUICreate("Form1", 165, 160, 200, 124)
	$Radio1 = GUICtrlCreateRadio("Generate new Key", 32, 20, 113, 25)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$Radio3 = GUICtrlCreateRadio("Manual", 32, 60, 113, 17)
	$Button1 = GUICtrlCreateButton("OK", 32, 100, 91, 33)

	GUISetState(@SW_SHOW)

	ConsoleWrite( "SyncNewFolder: " & $NewFolderName)

	$PathSplit = _PathSplit($NewFolderName, $sDrive, $sDir, $sFilename, $sExtension)

; Running the Gui in Loop
While 1
	$nMsg = GUIGetMsg(1)
	Switch $nMsg[0] ; check which GUI sent the message
		Case $GUI_EVENT_CLOSE
			Switch $nMsg[1]
				Case $Form1
					ExitLoop
			EndSwitch
		Case $Button1
			Select
				Case BitAND(GUICtrlRead($Radio1), $GUI_CHECKED) = $GUI_CHECKED
					Local $NewFolderKey = getNewKey()
					MsgBox( 0, "Data", "Please Choose the Data Folder, with the Encrypted File")
					$arr = ChooseDecryptEncryptFolder("", $NewFolderName)
					$NewFolderKeyDataDecrypt = $arr[0]
					$NewFolderKeyDataEncrypt = $arr[1]
					;Local $NewFolderKey = InputBox("Folder Name", "Enter folder Name", "", "")
					;MsgBox(64, "Passed Parameters", getNewKey())
					RegistryCreateNewFolder($NewFolderKeyDataDecrypt, $NewFolderKeyDataEncrypt, $PathSplit[3], $NewFolderKey)
					Exit
				Case BitAND(GUICtrlRead($Radio3), $GUI_CHECKED) = $GUI_CHECKED
					Local $NewFolderKey = InputBox("Folder Name", "Enter folder key", "", "")
					$arr = ChooseDecryptEncryptFolder("", $NewFolderName)
					$NewFolderKeyDataDecrypt = $arr[0]
					$NewFolderKeyDataEncrypt = $arr[1]
					RegistryCreateNewFolder($NewFolderKeyDataDecrypt, $NewFolderKeyDataEncrypt, $PathSplit[3], $NewFolderKey)
					Exit
        EndSelect
   EndSwitch
WEnd
ReloadListView()
EndFunc

#cs ----------------------------------------------------------------------------
ReloadListView
Reloading the list view from the registry, to see the entries in the GUI
#ce ----------------------------------------------------------------------------
Func ReloadListView()
	RegWrite($SafeSyncRegistrySoftwareManagementTool,"refreshGUI","REG_SZ",0)
	_GUICtrlListView_DeleteAllItems ( $idListview )
   Local $FolderCounter = 0
   For $i = 1 To 1000
	  $sVar = RegEnumVal($SafeSyncRegistryFolders, $i)
	  $FolderCounter = $i
	  If @error <> 0 Then ExitLoop
	  $sVar1 = RegRead($SafeSyncRegistryFolders, $sVar)
	  Local $idItem1 = GUICtrlCreateListViewItem("" & $sVar & "| " & $sVar1 & " | " & RegRead( $SafeCryptRegistryFolders & "\" & $sVar, "Encrypt") & " | " & RegRead( $SafeCryptRegistryFolders & "\" & $sVar, "Decrypt") & " ", $idListview)
   Next
   Global $SyncFolders[$FolderCounter][2]
   For $i = 1 To $FolderCounter + 1
	  $sVar = RegEnumVal($SafeSyncRegistryFolders, $i)
	  If @error <> 0 Then ExitLoop
	  $sVar1 = RegRead($SafeSyncRegistryFolders, $sVar)
	  $SyncFolders[$i][0] = RegRead( $SafeCryptRegistryFolders & "\" & $sVar, "Encrypt")
	  $SyncFolders[$i][1] = $sVar1
   Next
   createConfig($SyncFolders, $BTSyncStoragePath)
   RestartBTSync()
EndFunc

#cs ----------------------------------------------------------------------------
RegistryCreateNewFolder
Function to create a New Folder
#ce ----------------------------------------------------------------------------
Func RegistryCreateNewFolder($NewFolderKeyDataEncrypt, $NewFolderKeyDataDecrypt, $NewFolderName, $NewFolderKey)
	RegWrite($SafeSyncRegistryFolders, $NewFolderName, "REG_SZ", $NewFolderKey)
	DirCreate ($NewFolderKeyDataDecrypt)
	DirCreate ($NewFolderKeyDataEncrypt)
	; SafeCrypt Add folder
	RunWait( @ComSpec & ' /c ""' & $SafeCryptInstallDir & '\SafeCrypt.exe" AddFolder ""' & $NewFolderName & '"" ""' & $NewFolderKeyDataDecrypt & '"" ""' & $NewFolderKeyDataEncrypt & '"" ""' )
	;RestartBTSync()
EndFunc

#cs ----------------------------------------------------------------------------
RegistryDeleteFolder
Function to delete a New Folder
#ce ----------------------------------------------------------------------------
Func RegistryDeleteFolder($FolderName)
	RegDelete($SafeSyncRegistryFolders,$FolderName)
	ReloadListView()
	RestartBTSync()
EndFunc

#cs ----------------------------------------------------------------------------
StopBTSync
Stop the Bittorent Sync Process
#ce ----------------------------------------------------------------------------
Func StopBTSync()
	;Stopping both processes, for better compatibility
	StopProcess("BitTorrent_SyncX64.exe")
	StopProcess("BTSync.exe")
EndFunc

#cs ----------------------------------------------------------------------------
StartBTSync
Stop the Bittorent Sync Process with the config file
#ce ----------------------------------------------------------------------------
Func StartBTSync()
	ConsoleWrite('"C:\Users\Tim\Program Files\BitTorrent Sync\BTSync.exe" /config "' & $BTSyncConfig & '"' & @CRLF)
	Run('"C:\Users\Tim\Program Files\BitTorrent Sync\BTSync.exe" /config "' & $BTSyncConfig & '"')
EndFunc

#cs ----------------------------------------------------------------------------
RestartBTSync
Restart the BTSync with config File
#ce ----------------------------------------------------------------------------
Func RestartBTSync()
	StopBTSync()
	Sleep(200)
	StartBTSync()
EndFunc

Func MenuDelete()

	$iSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected")
	$sSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetText", $iSelect)

	$iMsgBoxAnswer = MsgBox(33,"Delete Folder?","Delete '"& $sSelect &"'?")
	Select
		Case $iMsgBoxAnswer = 1
			RegistryDeleteFolder($sSelect)
		Case $iMsgBoxAnswer = 2
	EndSelect
	ReloadListView()
EndFunc

Func MenuExport()
	$kSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected")
	;$iSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected", 1)
	;$jSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected", 1)
	;$sSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected", 1)

	$TempInt = Number($kSelect)
	$FolderKey = _GUICtrlListView_GetItemText ( $idListview, $TempInt , 1)
	$FolderName = _GUICtrlListView_GetItemText ( $idListview, $TempInt , 0)
	Local Const $sMessage = "Choose a filename."

	; Display a save dialog to select a file.
	Local $sFileSaveDialog = FileSaveDialog($sMessage, "::{450D8FBA-AD25-11D0-98A8-0800361B1103}", "Scripts (*.ssf)", $FD_PATHMUSTEXIST, $FolderName)

	FileDelete($sFileSaveDialog)
	Sleep(100)
	_FileCreate($sFileSaveDialog)
	Sleep(100)
	$SaveFile = FileOpen($sFileSaveDialog,1)
	FileWrite($SaveFile, $FolderName & "" & $FolderKey)
	FileClose($SaveFile)
	ReloadListView()
EndFunc

Func MenuExit()
	_Exit()
EndFunc

Func MenuBitTorrent()
	$hGUI = GUICreate("Settings", 150, 230)
	$BTSyncOption_Button_Save = GUICtrlCreateButton( "Save", 30, 180, 65,35)
	GUIStartGroup()
	$BTSyncOption_ShowGUI_True = GUICtrlCreateRadio("True", 20, 30, 100, 20)
	$BTSyncOption_ShowGUI_False = GUICtrlCreateRadio("False", 20, 50, 100, 20)

	If $BTSyncShowGUI = "true" Then
		GUICtrlSetState($BTSyncOption_ShowGUI_True, $GUI_CHECKED)
	Else
		GUICtrlSetState($BTSyncOption_ShowGUI_False, $GUI_CHECKED)
	EndIf
	GUIStartGroup()
	$BTSyncOption_UseRelayServer_True = GUICtrlCreateRadio("True", 20, 110, 100, 20)
	$BTSyncOption_UseRelayServer_False = GUICtrlCreateRadio("False", 20, 130, 100, 20)
	GUIStartGroup()
	$hGroup_1 = GUICtrlCreateGroup("Show GUI?", 10, 10, 120, 70)
	$hGroup_2 = GUICtrlCreateGroup("UseRelayServer?", 10, 90, 120, 70)

	GUISetState(@SW_HIDE,$SafeSyncManagementTool)
	GUISetState(@SW_SHOW,$hGUI)
	$test = 1
	While $test

		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				GUIDelete($hGUI)
			Case $BTSyncOption_Button_Save
				If BitAND(GUICtrlRead($BTSyncOption_ShowGUI_True), $GUI_CHECKED) = $GUI_CHECKED Then
					RegWrite( $SafeSyncRegistrySoftwareManagementTool, "ShowGUI", "REG_SZ", "true")
					$BTSyncShowGUI = "true"
				Else
					RegWrite( $SafeSyncRegistrySoftwareManagementTool, "ShowGUI", "REG_SZ", "false")
					$BTSyncShowGUI = "false"
				EndIf
				ReloadListView()
				GUISetState(@SW_SHOW,$SafeSyncManagementTool)
				GUIDelete($hGUI)
				$test = 0
		EndSwitch
	WEnd
EndFunc

Func MenuCrypt()
	MsgBox(0, "TODO", "Open real CryptSync?")
EndFunc

Func MenuOther()
	MsgBox(0, "TODO", "General settings")
EndFunc

Func MenuAbout()
	MsgBox(0, "About SafeSync", "SafeSync" & @LF & "Version 0.0.1.2" & @LF & "  16.02.2015" & @LF & "by SafeSync-Team")
EndFunc

Func _Exit()
    Exit
EndFunc

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
    $hWndListView = $idListview
    If Not IsHWnd($idListview) Then $hWndListView = GUICtrlGetHandle($idListview)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    _DebugPrint("$NM_CLICK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode & @LF & _
                            "-->Index:" & @TAB & DllStructGetData($tInfo, "Index") & @LF & _
                            "-->SubItem:" & @TAB & DllStructGetData($tInfo, "SubItem") & @LF & _
                            "-->NewState:" & @TAB & DllStructGetData($tInfo, "NewState") & @LF & _
                            "-->OldState:" & @TAB & DllStructGetData($tInfo, "OldState") & @LF & _
                            "-->Changed:" & @TAB & DllStructGetData($tInfo, "Changed") & @LF & _
                            "-->ActionX:" & @TAB & DllStructGetData($tInfo, "ActionX") & @LF & _
                            "-->ActionY:" & @TAB & DllStructGetData($tInfo, "ActionY") & @LF & _
                            "-->lParam:" & @TAB & DllStructGetData($tInfo, "lParam") & @LF & _
                            "-->KeyFlags:" & @TAB & DllStructGetData($tInfo, "KeyFlags"))
                Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    _DebugPrint("$NM_RCLICK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode & @LF & _
                            "-->Index:" & @TAB & DllStructGetData($tInfo, "Index") & @LF & _
                            "-->SubItem:" & @TAB & DllStructGetData($tInfo, "SubItem") & @LF & _
                            "-->NewState:" & @TAB & DllStructGetData($tInfo, "NewState") & @LF & _
                            "-->OldState:" & @TAB & DllStructGetData($tInfo, "OldState") & @LF & _
                            "-->Changed:" & @TAB & DllStructGetData($tInfo, "Changed") & @LF & _
                            "-->ActionX:" & @TAB & DllStructGetData($tInfo, "ActionX") & @LF & _
                            "-->ActionY:" & @TAB & DllStructGetData($tInfo, "ActionY") & @LF & _
                            "-->lParam:" & @TAB & DllStructGetData($tInfo, "lParam") & @LF & _
                            "-->KeyFlags:" & @TAB & DllStructGetData($tInfo, "KeyFlags"))
							FolderEdit()
                    Return 0 ; allow the default processing
                Case $NM_RETURN ; The control has the input focus and that the user has pressed the ENTER key
                    _DebugPrint("$NM_RETURN" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode)
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

#cs ----------------------------------------------------------------------------
_DebugPrint
Print debuggingtext in the console
#ce ----------------------------------------------------------------------------
Func _DebugPrint($s_text, $line = @ScriptLineNumber)
    ConsoleWrite( _
            "!===========================================================" & @LF & _
            "+======================================================" & @LF & _
            "-->Line(" & StringFormat("%04d", $line) & "):" & @TAB & $s_text & @LF & _
            "+======================================================" & @LF)
EndFunc


Func FolderEdit()
   Local $iTimeout = 10
   ; Display a message box with a nested variable in its text.
		MsgBox($MB_SYSTEMMODAL , "Title", "This message box will timeout after " & $iTimeout & " seconds or select the OK button.", $iTimeout)
EndFunc

#cs ----------------------------------------------------------------------------
createConfig
Function to create the config File, from the entries on the registry
#ce ----------------------------------------------------------------------------
Func createConfig($SyncFolders, $Storage_Path)
	DirCreate($Storage_Path)
   _FileCreate($BTSyncConfig)
   Local $hFileOpen = FileOpen($BTSyncConfig,1)
   If $hFileOpen = -1 Then
	   MsgBox("Test", "", "An error occurred when reading the file.")
   EndIf
   ; Write data to the file using the handle returned by FileOpen.
   FileWrite($hFileOpen, '{' & @CRLF)
   FileWrite($hFileOpen, '     "storage_path" : "'&$storage_Path&'",'&@CRLF)
   FileWrite($hFileOpen, '     "check_for_updates" : false,'& @CRLF)
   FileWrite($hFileOpen, '     "use_gui" : ' & $BTSyncShowGUI & ','& @CRLF)
   FileWrite($hFileOpen, '     "webui" :'& @CRLF)
   FileWrite($hFileOpen, '     {'& @CRLF)
   FileWrite($hFileOpen, '          "listen" : "127.0.0.1:7878",'& @CRLF)
;   FileWrite($hFileOpen, '          "login" : "login",'& @CRLF)
;   FileWrite($hFileOpen, '          "password" : "passwd",'& @CRLF)
	FileWrite($hFileOpen, '          "api_key" : "UPK4TNW735M6D4UERSZ7EW6A2VRRPMA5JJKFJ6JTYSPTNGTN4JGCLBUOJ46I6ZDXHRLT3PHGQD76I4SGVJWLNII7TPNFNMBOJ4J3KBAPDMVBKCXLNNSCJUMDLQTRW4BMQ6OZHPA"'& @CRLF)
	FileWrite($hFileOpen, '     }'& @CRLF)
	FileWrite($hFileOpen, '     ,'& @CRLF)
	FileWrite($hFileOpen, '     "shared_folders" :'& @CRLF)
	FileWrite($hFileOpen, '     ['& @CRLF)
	$Counter = UBound($SyncFolders, $UBOUND_ROWS) -1
	For $element = 1 To $Counter
	   If $element <= $Counter And $element >= 2 Then
		   FileWrite($hFileOpen, '     ,'& @CRLF)
	   EndIf
	   FileWrite($hFileOpen, '     {'& @CRLF)
	  FileWrite($hFileOpen, '     "secret" : "'&$SyncFolders[$element][1]&'",'& @CRLF)
	  FileWrite($hFileOpen, '     "dir" : "'&StringReplace($SyncFolders[$element][0], "\", "/")&'",'& @CRLF)
	  FileWrite($hFileOpen, '     "use_relay_server" : true,'& @CRLF)
	  FileWrite($hFileOpen, '     "use_tracker" : true,'& @CRLF)
	  FileWrite($hFileOpen, '     "use_dht" : false,'& @CRLF)
	  FileWrite($hFileOpen, '     "search_lan" : true,'& @CRLF)
	  FileWrite($hFileOpen, '     "use_sync_trash" : true'& @CRLF)
	  FileWrite($hFileOpen, '     }'& @CRLF)
   Next
   FileWrite($hFileOpen, '     ]'& @CRLF)
   FileWrite($hFileOpen, '}'& @CRLF)
EndFunc

#cs ----------------------------------------------------------------------------
getNewKEy
get a New BitTorrent Sync Key
#ce ----------------------------------------------------------------------------
Func getNewKey()
	    ; Save the downloaded file to the temporary folder.
    Local $sFilePath = @TempDir & "\secretKey.temp"

    ; Download the file in the background with the selected option of 'force a reload from the remote site.'
    Local $hDownload = InetGet("http://admin:passwd@127.0.0.1:7878/api?method=get_secrets", @TempDir & "\secretKey.temp", $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

    ; Wait for the download to complete by monitoring when the 2nd index value of InetGetInfo returns True.
    Do
        Sleep(250)
    Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

    ; Retrieve the number of total bytes received and the filesize.
    Local $iBytesSize = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
    Local $iFileSize = FileGetSize($sFilePath)

    ; Close the handle returned by InetGet.
    InetClose($hDownload)

	$NewKey = FileReadLine($sFilePath, 1)

	$NewKey = StringRegExpReplace ( $NewKey, "{*:", "" )

	$WriteKey = StringSplit( $NewKey, '"')

	return $WriteKey[8]
    ; Delete the file.
    FileDelete($sFilePath)
EndFunc

#cs ----------------------------------------------------------------------------
StopProcess
#ce ----------------------------------------------------------------------------
Func StopProcess($ProcessName)
	Local $aProcessList = ProcessList($ProcessName)
    For $i = 1 To $aProcessList[0][0]
		ProcessClose ( $aProcessList[$i][1] )
    Next
EndFunc

#cs ----------------------------------------------------------------------------
StopProcess
#ce ----------------------------------------------------------------------------
Func ChooseDecryptEncryptFolder($FolderName, $FolderData)
    ; Create a GUI with various controls.
	$TempString = ""
	If StringCompare( $TempString, $FolderData) = 0 Then
		$FolderData = $SafeSyncStandardDataFolder & "\" & $FolderName
	EndIf
    Local $InstallationDialog = GUICreate("SafeSync - Select Folder", 430,170)
    Local $OKButton = GUICtrlCreateButton("OK", 320, 130, 85, 25)
    Local $DecryptDirectory = GUICtrlCreateLabel("DecryptFolder:",10,20)
	Local $DecryptDir = GUICtrlCreateInput($FolderData, 10, 38, 300)
	Local $DecryptDirSelect = GUICtrlCreateButton( "SelectFolder", 320,36,100)
	Local $EncryptDirectory = GUICtrlCreateLabel("EncryptFolder:",10,70)
	Local $EncryptDir = GUICtrlCreateInput($FolderData & "Encrypt", 10, 88, 300)
	Local $EncryptDirSelect = GUICtrlCreateButton( "SelectFolder", 320,86,100)
	;Local $DataCryptDirectory = GUICtrlCreateLabel("CryptDirectory:",10,120)
	;Local $DataCryptDir = GUICtrlCreateInput($InstallLocationSafeSync & "\Crypt", 10, 138, 300)
	;Local $DataCryptDirSelect = GUICtrlCreateButton( "SelectFolder", 320,136,100)
    ; Display the GUI.
    GUISetState(@SW_SHOW, $InstallationDialog)
    ; Loop until the user exits.
    While 1
        Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit
                ExitLoop
			Case $OKButton
				ExitLoop
			Case $DecryptDirSelect
				GUICtrlSetData( $DecryptDir, FileSelectFolder( "Choose the destination folder", $InstallLocationSafeSync))
			Case $EncryptDirSelect
				GUICtrlSetData( $EncryptDir, FileSelectFolder( "Choose Standard Data Folder", $InstallLocationSafeSync))
        EndSwitch
    WEnd
	Local $arr[2]
	$arr[0] = Guictrlread($DecryptDir)
	$arr[1] = GUICtrlRead($EncryptDir)
	GUIDelete( $InstallationDialog )
	return $arr
EndFunc

#cs ----------------------------------------------------------------------------
run Register file Extision, for supporting .ssf - files
#ce ----------------------------------------------------------------------------
Func RegisterFileExtension($InstallPath, $DataDir)
	;RunWait( @ComSpec & ' /c ' & @TempDir & '\InstallSafeSync.exe "' & $InstallPath & '" "' & @ScriptFullPath & '"', @TempDir , @SW_HIDE )
	;RunWait( @ComSpec & ' /c ' & @TempDir & '\InstallSafeSync.exe "' & $DataDir & '"', @TempDir , @SW_HIDE )
	ConsoleWrite( "Run File-Extension support" & @CRLF)
	ConsoleWrite( "Run: " & @TempDir & "\RegisterSSF.exe" &@CRLF)
	RunWait( @ComSpec & ' /c ' & @TempDir & "\RegisterSSF.exe", @TempDir , @SW_HIDE )
	RegWrite($SafeSyncRegistrySoftware, "FileRegistered","REG_SZ","1")
EndFunc

Func CheckAdmin()
	If Not IsAdmin() Then
		ConsoleWrite($RunSafeSyncAsAdmin)
		Run(@ComSpec & ' /c ' & $RunSafeSyncAsAdmin, @TempDir , @SW_HIDE)
		Exit
	EndIf
EndFunc