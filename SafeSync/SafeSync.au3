#cs ----------------------------------------------------------------------------
	AutoIt Version: 	3.3.12.0
	Author:				Tim Christoph Lid
	Version:			1.0
	Name:				SafeSync Management Tool

	TODO:
	1. Write documentation
	Rename Variables
	Commentation
	Output log file, with function for output file, and console output
	Correct Version number

	Maybe:
	Check Folder Exists
	KEY ist correct?
	Check if BTSync is running
	Stop btsync with api
	more btsync option
	safecrypt options
	count Foldername
	Issues:
	Actually store the gui for new folder

#ce ----------------------------------------------------------------------------

#cs ----------------------------------------------------------------------------
	SafeSync Version Info
#ce ----------------------------------------------------------------------------

; DisplayName for installation
Global Const $SafeSyncDisplayName = "SafeSync"
; DisplayVersion for installation
Global Const $SafeSyncDisplayVersion = "1.0"
; DisplayVersion for installation
Global Const $SafeSyncPublisher = "SafeSync - Team"

#cs ----------------------------------------------------------------------------
	Including
#ce ----------------------------------------------------------------------------

; �nclude everything
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
#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <Crypt.au3>
#include <ComboConstants.au3>
#include <StringConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEX.au3>
#include <ColorConstants.au3>
#include <Color.au3>

; Including files
FileInstall("C:\include\7z.exe", @AppDataDir & "\SafeCrypt\7z.exe")
FileInstall("C:\include\BitTorrent_SyncX64.exe", @TempDir & "\BitTorrent_SyncX64.exe", 1)
FileInstall("C:\include\config.ini", @TempDir & "\config.ini", 1)
FileInstall("C:\include\RegisterSSF.exe", @TempDir & "\RegisterSSF.exe", 1)
FileInstall("C:\include\UninstallSafeSync.exe", @TempDir & "\UninstallSafeSync.exe", 1)
FileInstall("C:\include\InstallSafeSync.exe", @TempDir & "\InstallSafeSync.exe", 1)
FileInstall("C:\include\RunSafeSyncAsAdmin.exe", @TempDir & "\RunSafeSyncAsAdmin.exe", 1)

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
Global Const $SafeSyncRegistryFolders = $SafeSyncRegistrySoftware & "\Folders"
; Run SafeSyncAsAdmin
Global Const $RunSafeSyncAsAdmin = @TempDir & "\RunSafeSyncAsAdmin.exe " & @ScriptFullPath
; SafeSync ShortcutFolder
Global Const $SafeSyncShortcutFolder = @AppDataDir & "\Microsoft\Windows\Start Menu\Programs\SafeSync"

#cs ----------------------------------------------------------------------------
	Static-Variables SafeCrypt
#ce ----------------------------------------------------------------------------

; SafeCrypt Registry
Global Const $SafeCryptRegistrySoftware = "HKEY_CURRENT_USER64\Software\SafeSync\SafeCrypt"
$7zLocation = @AppDataDir & "\SafeCrypt\7z.exe"
$SafeCryptFolder = "D:\SafeCrypt\"
$DataFolderDecrypt = $SafeCryptFolder & "Decrypt\"
$DataFolderEncrypt = $SafeCryptFolder & "Encrypt\"
$LogListFolderDecrypt = $SafeCryptFolder & "FolderDecrypt.txt"
$LogListFolderEncrypt = $SafeCryptFolder & "FolderEncrypt.txt"
$LogListFileDecrypt = $SafeCryptFolder & "FilesDecrypt.txt"
$LogListFileEncrypt = $SafeCryptFolder & "FilesEncrypt.txt"
Global $ListEncrypt
Global $ListDecrypt
Global $FileListDecrypt
Global $FileListEncrypt
Global $CreateDecryptionDir

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
	Global $SafeSyncStandardDataFolder = RegRead("HKEY_CURRENT_USER64\Software\SafeSync\ManagementTool", "DataDir")
	If $SafeSyncStandardDataFolder = "" Then
		MsgBox(0, "Warning", "Please choose a Folder, for your Data")
		$SafeSyncStandardDataFolder = FileSelectFolder("Choose the destination folder", "C:\")
		RegWrite("HKEY_CURRENT_USER64\Software\SafeSync\ManagementTool", "DataDir", "REG_SZ", $SafeSyncStandardDataFolder)
	EndIf
	; Read SafeCrypt Location from Registry
	Global $InstallLocationSafeSync = RegRead($SafeSyncRegistrySoftwareManagementTool, "InstallDir")
	; Read BTSyncShowGUI show GUI Option
	Global $BTSyncShowGUI = RegRead($SafeSyncRegistrySoftwareManagementTool, "ShowGUI")
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
EndFunc   ;==>ReadRegistry

#cs ----------------------------------------------------------------------------
	Option Variables
#ce ----------------------------------------------------------------------------


;---------------------------------------------------------------------------------------


; Read command line parameters
; Create Registry, if an external file is open with command line parameter "ImportFile"
If Not $CmdLine[0] = 0 Then
	If $CmdLine[1] == "SafeCrypt" Then
		If $CmdLine[2] == "Start" Then
			Global $Password = $CmdLine[3]
			TraySetState(2)
			RunSafeCrypt()
		EndIf
	EndIf
	If $CmdLine[1] == "ImportFile" Then
		;TODO create new import!
		; Open the File
		FileOpen($CmdLine[2])
		Local $NewFolderKey = StringRight(FileReadLine($CmdLine[2], 1), StringLen(FileReadLine($CmdLine[2], 1)) - StringInStr(FileReadLine($CmdLine[2], 1), " "))
		Local $NewFolderNameWithSpace = StringLeft(FileReadLine($CmdLine[2], 1), StringInStr(FileReadLine($CmdLine[2], 1), " "))
		Local $NewFolderName = StringLeft($NewFolderNameWithSpace, StringLen($NewFolderNameWithSpace) - 1)
		Local $arr[2]
		$arr = ChooseDecryptEncryptFolder($NewFolderName, "")
		RegWrite($SafeSyncRegistrySoftwareManagementTool, "refreshGUI", "REG_SZ", "1")
		RegistryCreateNewFolder($arr[0], $arr[1], $NewFolderName, $NewFolderKey, 0, "", "")
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

RegWrite($SafeSyncRegistrySoftwareManagementTool, "RunSafeCrypt", "REG_SZ", "1")

Global $Password = PasswordCheck()

;Start SafeCrypt
;Run(@ComSpec & ' /c ' & @ScriptFullPath & ' SafeCrypt' & ' Start ' & $Password, @TempDir, @SW_HIDE)

#cs ----------------------------------------------------------------------------
	Install Programms
#ce ----------------------------------------------------------------------------

#cs ----------------------------------------------------------------------------
	Install BitTorrent Sync 1.4 if not installed yet
#ce ----------------------------------------------------------------------------
If RegRead($BTSyncRegistryUninstall, "DisplayIcon") == "" Then
	RunWait('"' & $BTSyncInstaller & '" /PERFORMINSTALL /AUTOMATION')
EndIf

#cs ----------------------------------------------------------------------------
	Install 7Zip if not installed yes
#ce ----------------------------------------------------------------------------
RegRead($7ZipRegistrySoftware, "Path")
If @error Then
	ConsoleWrite("Install 7zip")
	CheckAdmin()
	RunWait(@ComSpec & ' /c ' & $7zipInstaller & "/quiet /passive ", @TempDir, @SW_HIDE)
EndIf

#cs ----------------------------------------------------------------------------
	Install SafeSync if not installed yes
#ce ----------------------------------------------------------------------------TODO
If RegRead($SafeSyncRegistrySoftware, "FileRegistered") = 0 Then
	ConsoleWrite("FileRegister" & @CRLF)
	RegisterFileExtension($InstallLocationSafeSync, $SafeSyncStandardDataFolder)
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

Global $Form1 = GUICreate("AddNewFolders", 717, 298, 194, 135)
$Encryption = GUICtrlCreateRadio("Encryption", 48, 128, 113, 25)
GUICtrlSetState(-1, $GUI_CHECKED)
$NoEncryption = GUICtrlCreateRadio("No Encryption", 48, 150, 113, 25)
$CreateFolder_Name = GUICtrlCreateInput("Name", 48, 88, 121, 21)
$FolderName = GUICtrlCreateLabel("Foldername", 48, 64, 59, 17)
$PasswordInput1 = GUICtrlCreateInput("", 48, 180, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
$PasswordInput2 = GUICtrlCreateInput("", 48, 202, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
$PasswordEntropy = GUICtrlCreateLabel("-1", 48, 224, 121, 21)
$DecryptionDir = GUICtrlCreateInput("", 216, 88, 361, 21)
$DecryptionDirButton = GUICtrlCreateButton("Select Folder", 586, 88, 80, 21)
$DecryptionDirLabel = GUICtrlCreateLabel("Destination Folder:", 216, 64, 92, 17)
$CreateButton = GUICtrlCreateButton("Create", 224, 248, 75, 25)
GuiCtrlSetState(-1, 512)
$EncryptionDirLabel = GUICtrlCreateLabel("Encryption Folder:", 216, 115, 92, 17)
$EncryptionDir = GUICtrlCreateInput("", 216, 132, 361, 21)
$EncryptionDirButton = GUICtrlCreateButton("Select Folder", 586, 132, 80, 21)
$CreateFolder_KeyInput = GUICtrlCreateInput(getNewKey(), 216, 202, 361, 21)
$CreateFolder_KeyLabel = GUICtrlCreateLabel("Key for Bittorent-Sync", 216, 180, 361, 21)
$CreateFolder_KeyButton = GUICtrlCreateButton("Generate New", 586, 202, 80, 21)

#cs
	Global $Form1 = GUICreate("Form1", 165, 160, 200, 124)
	$Radio1 = GUICtrlCreateRadio("Generate new Key", 32, 20, 113, 25)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$Radio3 = GUICtrlCreateRadio("Manual", 32, 60, 113, 17)
	$Button1 = GUICtrlCreateButton("Button1", 32, 100, 91, 33)
#ce

Global $Gui_SafeSync_Encrypt_Folder = GUICreate("Use Encryption?", 165, 160, 200, 124)
$Radio5 = GUICtrlCreateRadio("With encryption", 32, 20, 113, 25)
GUICtrlSetState(-1, $GUI_CHECKED)
$Radio4 = GUICtrlCreateRadio("Don't use encryption", 32, 60, 113, 17)
$Button2 = GUICtrlCreateButton("Button1", 32, 100, 91, 33)

GUISwitch($SafeSyncManagementTool)

Local $aProcessList = ProcessList("SafeCrypt.exe")
For $i = 1 To $aProcessList[0][0]
	ProcessClose($aProcessList[$i][1])
Next

Func Input1Change()
	MsgBox(0,"","Test2")
EndFunc

;Run( $SafeCryptInstallDir & "/SafeCrypt.exe")

;Gui Things
Opt('TrayOnEventMode', 1)
Opt('TrayMenuMode', 1)
TraySetOnEvent(-7, '_Restore')
TraySetState(2)

; Running the Gui in Loop
While 1
	$nMsg = GUIGetMsg(1)
	$RefreshGUI = RegRead($SafeSyncRegistrySoftwareManagementTool, "RefreshGUI")
	If $RefreshGUI = 1 Then
		ReloadListView()
	EndIf
	Switch $nMsg[0] ; check which GUI sent the message
		Case $GUI_EVENT_CLOSE
			Switch $nMsg[1]
				Case $Form1
					Exit
					GUISetState(@SW_SHOW, $SafeSyncManagementTool)
					GUISetState(@SW_HIDE, $Form1)
					GUISwitch($SafeSyncManagementTool)
				Case $SafeSyncManagementTool
					$iMsgBoxAnswer = MsgBox(33, "Quit SafeSync?", "Do you want to quit Safe-Sync?" & @CRLF & "You can also minize it," & @CRLF & " to run it in the background." & @CRLF & "Otherwise the Data will not be secure!")
					Select
						Case $iMsgBoxAnswer = 1
							StopBTSync()
							RegWrite($SafeSyncRegistrySoftwareManagementTool, "RunSafeCrypt", "REG_SZ", "0")
							GUISetState(@SW_HIDE, $SafeSyncManagementTool)
							ExitLoop
						Case $iMsgBoxAnswer = 2
					EndSelect
			EndSwitch
		Case $GUI_EVENT_MINIMIZE
			TraySetState(1)
			GUISetState(@SW_HIDE)
		Case $MenuNew
			GUISetState(@SW_SHOW, $Form1)
			GUISetState(@SW_HIDE, $SafeSyncManagementTool)
		Case $MenuDelete
			MenuDelete()
		Case $MenuRefresh
			ReloadListView()
		Case $MenuExport
			MenuExport()
		Case $CreateFolder_KeyButton
			GUICtrlSetData($CreateFolder_KeyInput, getNewKey())
		Case $DecryptionDirButton
			GUICtrlSetData($DecryptionDir, FileSelectFolder("Choose Standard Data Folder", $InstallLocationSafeSync))
		Case $EncryptionDirButton
			GUICtrlSetData($EncryptionDir, FileSelectFolder("Choose Standard Data Folder", $InstallLocationSafeSync))
		Case $Encryption
			GUICtrlSetState($PasswordInput1, $GUI_ENABLE)
			GUICtrlSetState($PasswordInput2, $GUI_ENABLE)
			GUICtrlSetState($EncryptionDir, $GUI_ENABLE)
			GUICtrlSetState($EncryptionDirButton, $GUI_ENABLE)
			GuiCtrlSetData($PasswordEntropy,"-1")
			GUICtrlSetState($PasswordEntropy, $GUI_ENABLE)

			GUICtrlSetState($NoEncryption, $GUI_UNCHECKED)
		Case $NoEncryption
			GUICtrlSetState($PasswordInput1, $GUI_DISABLE)
			GUICtrlSetState($PasswordInput2, $GUI_DISABLE)
			GUICtrlSetState($EncryptionDir, $GUI_DISABLE)
			GUICtrlSetState($EncryptionDirButton, $GUI_DISABLE)
			GUICtrlSetState($PasswordEntropy, $GUI_DISABLE)
			Local $Hellgrau[3] = [0xcc, 0xcc, 0xcc]

		Local $COLOR_HellGrau = _ColorSetRGB($Hellgrau)
			GUICtrlSetBkColor ( $PasswordEntropy, $COLOR_HellGrau)
			GUICtrlSetState($Encryption, $GUI_UNCHECKED)
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
		Case $CreateButton
			If CheckNewName(GUICtrlRead($CreateFolder_Name)) Then
				If BitAND(GUICtrlRead($Encryption), $GUI_CHECKED) = $GUI_CHECKED Then
					If StringCompare(GUICtrlRead($PasswordInput1), GUICtrlRead($PasswordInput2)) Then
						MsgBox(16, "Error", "Passwords doesn't match")
					Else
						If StringLen(GUICtrlRead($PasswordInput1)) <= 6 Then
							MsgBox(16, "Error", "Please choose a Password greater then 6")
						Else
							Local $PasswordCreateSalt
							For $i = 0 To 100 Step 1
								$PasswordCreateSalt = $PasswordCreateSalt & Chr(Random(32, 126, 1))
							Next
							$PasswordCrypt = CryptPassword(GUICtrlRead($PasswordInput1), $PasswordCreateSalt)
							RegistryCreateNewFolder(GUICtrlRead($EncryptionDir), GUICtrlRead($DecryptionDir), GUICtrlRead($CreateFolder_Name), GUICtrlRead($CreateFolder_KeyInput), 1, $PasswordCrypt, $PasswordCreateSalt)
							ReloadListView()
							GUISetState(@SW_SHOW, $SafeSyncManagementTool)
							GUISetState(@SW_HIDE, $Form1)
						EndIf
					EndIf
				Else
					RegistryCreateNewFolder(GUICtrlRead($EncryptionDir), GUICtrlRead($DecryptionDir), GUICtrlRead($CreateFolder_Name), GUICtrlRead($CreateFolder_KeyInput), 0, "", "")
					GUISetState(@SW_SHOW, $SafeSyncManagementTool)
					GUISetState(@SW_HIDE, $Form1)
					ReloadListView()
				EndIf
			Else
				MsgBox(0, "", "Please choose an other folder name!")
			EndIf
	EndSwitch
	$PasswordEntropySet = GuiCtrlRead($PasswordEntropy)
	$PasswordEntropyNew = Int ( CalculateBitEntropy(GuiCtrlRead($PasswordInput1))) & " Bits"
	if $PasswordEntropySet <> $PasswordEntropyNew then
		GuiCtrlSetData($PasswordEntropy,$PasswordEntropyNew)
		Switch $PasswordEntropyNew
			Case 0 To 50
				GUICtrlSetBkColor ( $PasswordEntropy, $COLOR_RED )
			Case 50 To 100
				GUICtrlSetBkColor ( $PasswordEntropy, $COLOR_YELLOW )
			Case Else
				GUICtrlSetBkColor ( $PasswordEntropy, $COLOR_GREEN )
		EndSwitch
	EndIf
	$DataFolderSet = GuiCtrlRead($DecryptionDir)
	$DataFolderNew = $SafeSyncStandardDataFolder & "\" & GuiCtrlRead($CreateFolder_Name)
	if $DataFolderSet <> $DataFolderNew then
		GuiCtrlSetData($DecryptionDir,$DataFolderNew)
		GuiCtrlSetData($EncryptionDir,$DataFolderNew & "Encrypt")
	EndIf
WEnd

Func _Restore()
	TraySetState(2)
	GUISetState(@SW_SHOW, $SafeSyncManagementTool)
	WinActivate("SafeSyncManagementTool")
EndFunc   ;==>_Restore

#cs ----------------------------------------------------------------------------
	Functions
#ce ----------------------------------------------------------------------------

#cs ----------------------------------------------------------------------------
	Install
	Install - Process
#ce ----------------------------------------------------------------------------

Func Install()
	; Create a GUI with various controls.
	Local $InstallationDialog = GUICreate("SafeSync - Installation", 430, 170)
	Local $InstallButton = GUICtrlCreateButton("Install", 320, 130, 85, 25)
	Local $InstallDirectory = GUICtrlCreateLabel("Installation dir:", 10, 20)
	Local $InstallDir = GUICtrlCreateInput(@ProgramFilesDir & "\SafeSync", 10, 38, 300)
	Local $InstallDirSelect = GUICtrlCreateButton("SelectFolder", 320, 36, 100)
	Local $DataDirectory = GUICtrlCreateLabel("Standard Data Directory:", 10, 70)
	Local $DataDir = GUICtrlCreateInput(@UserProfileDir & "\Documents\Data", 10, 88, 300)
	Local $DataDirSelect = GUICtrlCreateButton("SelectFolder", 320, 86, 100)
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
				RegWrite($SafeSyncRegistryUninstall)
				RegWrite($SafeSyncRegistryUninstall, "DisplayIcon", "REG_SZ", GUICtrlRead($InstallDir) & "\SafeSync.exe")
				RegWrite($SafeSyncRegistryUninstall, "DisplayName", "REG_SZ", $SafeSyncDisplayName)
				RegWrite($SafeSyncRegistryUninstall, "DisplayVersion", "REG_SZ", $SafeSyncDisplayVersion)
				RegWrite($SafeSyncRegistryUninstall, "InstallLocation", "REG_SZ", GUICtrlRead($InstallDir))
				RegWrite("HKEY_CURRENT_USER64\Software\SafeSync", "InstallDir", "REG_SZ", GUICtrlRead($InstallDir))
				RegWrite("HKEY_CURRENT_USER64\Software\SafeSync", "DataDir", "REG_SZ", GUICtrlRead($DataDir))
				RegWrite($SafeSyncRegistryUninstall, "Publisher", "REG_SZ", $SafeSyncPublisher)
				RegWrite($SafeSyncRegistryUninstall, "UninstallString", "REG_SZ", GUICtrlRead($InstallDir) & "\SafeSync.exe /UNINSTALL")
				$SafeSyncDataFolder = RegRead($SafeSyncRegistryUninstall, "DataFolder")
				$SafeSyncDataCryptFolder = RegRead($SafeSyncRegistryUninstall, "DataCryptFolder")
				RegisterFileExtension(GUICtrlRead($InstallDir), GUICtrlRead($DataDir))
				FileCopy(@TempDir & "/InstallSafeSync.exe", GUICtrlRead($InstallDir) & "/")
				; TODO Copy other files and create folder
				ExitLoop
			Case $InstallDirSelect
				GUICtrlSetData($InstallDir, FileSelectFolder("Choose the destination folder", $InstallLocationSafeSync))
			Case $DataDirSelect
				GUICtrlSetData($DataDir, FileSelectFolder("Choose Standard Data Folder", $InstallLocationSafeSync))
		EndSwitch
	WEnd

	;Read SafeSync Standard Data folder from Registry
	$SafeSyncStandardDataFolder = RegRead("HKEY_CURRENT_USER64\Software\SafeSync", "DataDir")
	; Read SafeCrypt Location from Registry
	$InstallLocationSafeCrypt = RegRead("HKEY_CURRENT_USER64\Software\SafeSync\SafeCrypt", "InstallDir")
	; Read SafeCrypt Location from Registry
	$InstallLocationSafeSync = RegRead("HKEY_CURRENT_USER64\Software\SafeSync", "InstallDir")
	DirCreate($SafeSyncShortcutFolder)
	CreateShortcut($InstallLocationSafeSync & "\SafeSync.exe", $SafeSyncShortcutFolder & "\SafeSync.lnk")

	GUIDelete($InstallationDialog)
EndFunc   ;==>Install

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
		RunWait(RegRead($BTSyncRegistryUninstall, "UninstallString"))
		Run(@ComSpec & ' /c ' & @TempDir & "\UninstallSafeSync.exe ", @TempDir, @SW_HIDE)
	EndIf
	Exit
EndFunc   ;==>Uninstall

#cs ----------------------------------------------------------------------------
	Uninstall
	The Uninstall Process
#ce ----------------------------------------------------------------------------
Func CreateShortcut($ShortcutSourceFile, $ShortcutDestinationFile)
	FileCreateShortcut($ShortcutSourceFile, $ShortcutDestinationFile)
EndFunc   ;==>CreateShortcut

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

	ConsoleWrite("SyncNewFolder: " & $NewFolderName)

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
						MsgBox(0, "Data", "Please Choose the Data Folder, with the Encrypted File")
						$arr = ChooseDecryptEncryptFolder("", $NewFolderName)
						$NewFolderKeyDataDecrypt = $arr[0]
						$NewFolderKeyDataEncrypt = $arr[1]
						;Local $NewFolderKey = InputBox("Folder Name", "Enter folder Name", "", "")
						;MsgBox(64, "Passed Parameters", getNewKey())
						RegistryCreateNewFolder($NewFolderKeyDataDecrypt, $NewFolderKeyDataEncrypt, $PathSplit[3], $NewFolderKey, 0, "", "")
						Exit
					Case BitAND(GUICtrlRead($Radio3), $GUI_CHECKED) = $GUI_CHECKED
						Local $NewFolderKey = InputBox("Folder Name", "Enter folder key", "", "")
						$arr = ChooseDecryptEncryptFolder("", $NewFolderName)
						$NewFolderKeyDataDecrypt = $arr[0]
						$NewFolderKeyDataEncrypt = $arr[1]
						RegistryCreateNewFolder($NewFolderKeyDataDecrypt, $NewFolderKeyDataEncrypt, $PathSplit[3], $NewFolderKey, 0, "", "")
						Exit
				EndSelect
		EndSwitch
	WEnd
	ReloadListView()
EndFunc   ;==>SyncNewFolder

#cs ----------------------------------------------------------------------------
	ReloadListView
	Reloading the list view from the registry, to see the entries in the GUI
#ce ----------------------------------------------------------------------------
Func ReloadListView()
	RegWrite($SafeSyncRegistrySoftwareManagementTool, "refreshGUI", "REG_SZ", 0)
	_GUICtrlListView_DeleteAllItems($idListview)
	Local $FolderCounter = 0
	For $i = 1 To 1000
		$sVar = RegEnumVal($SafeSyncRegistryFolders, $i)
		$FolderCounter = $i
		If @error <> 0 Then ExitLoop
		$sVar1 = RegRead($SafeSyncRegistryFolders, $sVar)
		Local $idItem1 = GUICtrlCreateListViewItem("" & $sVar & "| " & $sVar1 & " | " & RegRead($SafeSyncRegistryFolders & "\" & $sVar, "Encrypt") & " | " & RegRead($SafeSyncRegistryFolders & "\" & $sVar, "Decrypt") & " ", $idListview)
	Next
	Global $SyncFolders[$FolderCounter][2]
	For $i = 1 To $FolderCounter + 1
		$sVar = RegEnumVal($SafeSyncRegistryFolders, $i)
		If @error <> 0 Then ExitLoop
		$sVar1 = RegRead($SafeSyncRegistryFolders, $sVar)
		If RegRead($SafeSyncRegistryFolders & "\" & $sVar, "UseEncryption") = 1 Then
			$SyncFolders[$i][0] = RegRead($SafeSyncRegistryFolders & "\" & $sVar, "Encrypt")
		Else
			$SyncFolders[$i][0] = RegRead($SafeSyncRegistryFolders & "\" & $sVar, "Decrypt")
		EndIf
		$SyncFolders[$i][1] = $sVar1
	Next
	createConfig($SyncFolders, $BTSyncStoragePath)
EndFunc   ;==>ReloadListView

#cs ----------------------------------------------------------------------------
	RegistryCreateNewFolder
	Function to create a New Folder
#ce ----------------------------------------------------------------------------
Func RegistryCreateNewFolder($NewFolderKeyDataEncrypt, $NewFolderKeyDataDecrypt, $NewFolderName, $NewFolderKey, $CreateFolder_Encryption, $CreateFolder_Password, $PasswordSalt)
	RegWrite($SafeSyncRegistryFolders, $NewFolderName, "REG_SZ", $NewFolderKey)
	DirCreate($NewFolderKeyDataDecrypt)
	DirCreate($NewFolderKeyDataEncrypt)
	RegWrite($SafeSyncRegistryFolders)
	RegWrite($SafeSyncRegistryFolders & "\" & $NewFolderName)
	RegWrite($SafeSyncRegistryFolders & "\" & $NewFolderName, "Encrypt", "REG_SZ", $NewFolderKeyDataEncrypt)
	RegWrite($SafeSyncRegistryFolders & "\" & $NewFolderName, "UseEncryption", "REG_SZ", $CreateFolder_Encryption)
	RegWrite($SafeSyncRegistryFolders & "\" & $NewFolderName, "Decrypt", "REG_SZ", $NewFolderKeyDataDecrypt)
	RegWrite($SafeSyncRegistryFolders & "\" & $NewFolderName, "PasswordSalt", "REG_SZ", $PasswordSalt)



	RegWrite($SafeSyncRegistryFolders & "\" & $NewFolderName, "Password", "REG_SZ", $CreateFolder_Password)
	;RunWait( @ComSpec & ' /c ""' & $SafeCryptInstallDir & '\SafeCrypt.exe" AddFolder ""' & $NewFolderName & '"" ""' & $NewFolderKeyDataDecrypt & '"" ""' & $NewFolderKeyDataEncrypt & '"" ""' )
	;RestartBTSync()
EndFunc   ;==>RegistryCreateNewFolder

Func CryptPassword($CryptPassword, $PasswordSalt)
	$CryptPassword = _Crypt_EncryptData($CryptPassword & $PasswordSalt, $Password, $CALG_RC4)
	Return $CryptPassword
EndFunc   ;==>CryptPassword

Func DecryptPassword($CryptPassword, $PasswordSalt)
	Local $PasswordWithSalt = BinaryToString(_Crypt_DecryptData($CryptPassword, $Password, $CALG_RC4))
	Return StringLeft(BinaryToString($PasswordWithSalt), StringLen($PasswordWithSalt) - StringLen($PasswordSalt))
EndFunc   ;==>DecryptPassword

#cs ----------------------------------------------------------------------------
	RegistryDeleteFolder
	Function to delete a New Folder
#ce ----------------------------------------------------------------------------
Func RegistryDeleteFolder($FolderName)
	RegDelete($SafeSyncRegistryFolders, $FolderName)
	RegDelete($SafeSyncRegistryFolders & "\" & $FolderName)
	ReloadListView()
	RestartBTSync()
EndFunc   ;==>RegistryDeleteFolder

#cs ----------------------------------------------------------------------------
	StopBTSync
	Stop the Bittorent Sync Process
#ce ----------------------------------------------------------------------------
Func StopBTSync()
	;Stopping both processes, for better compatibility
	StopProcess("BitTorrent_SyncX64.exe")
	StopProcess("BTSync.exe")
EndFunc   ;==>StopBTSync

#cs ----------------------------------------------------------------------------
	StartBTSync
	Stop the Bittorent Sync Process with the config file
#ce ----------------------------------------------------------------------------
Func StartBTSync()
	ConsoleWrite('"C:\Users\Tim\Program Files\BitTorrent Sync\BTSync.exe" /config "' & $BTSyncConfig & '"' & @CRLF)
	Run('"C:\Users\Tim\Program Files\BitTorrent Sync\BTSync.exe" /config "' & $BTSyncConfig & '"')
EndFunc   ;==>StartBTSync

#cs ----------------------------------------------------------------------------
	RestartBTSync
	Restart the BTSync with config File
#ce ----------------------------------------------------------------------------
Func RestartBTSync()
	StopBTSync()
	Sleep(200)
	StartBTSync()
EndFunc   ;==>RestartBTSync

Func MenuDelete()
	$iSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected")
	$sSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetText", $iSelect)

	$iMsgBoxAnswer = MsgBox(33, "Delete Folder?", "Delete '" & $sSelect & "'?")
	Select
		Case $iMsgBoxAnswer = 1
			RegistryDeleteFolder($sSelect)
		Case $iMsgBoxAnswer = 2
	EndSelect
	ReloadListView()
EndFunc   ;==>MenuDelete

Func MenuExport()
	$kSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected")
	;$iSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected", 1)
	;$jSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected", 1)
	;$sSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected", 1)

	$TempInt = Number($kSelect)
	$FolderKey = _GUICtrlListView_GetItemText($idListview, $TempInt, 1)
	$FolderName = _GUICtrlListView_GetItemText($idListview, $TempInt, 0)
	Local Const $sMessage = "Choose a filename."

	; Display a save dialog to select a file.
	Local $sFileSaveDialog = FileSaveDialog($sMessage, "::{450D8FBA-AD25-11D0-98A8-0800361B1103}", "Scripts (*.ssf)", $FD_PATHMUSTEXIST, $FolderName)

	FileDelete($sFileSaveDialog)
	Sleep(100)
	_FileCreate($sFileSaveDialog)
	Sleep(100)
	$SaveFile = FileOpen($sFileSaveDialog, 1)
	FileWrite($SaveFile, $FolderName & "" & $FolderKey)
	FileClose($SaveFile)
	ReloadListView()
EndFunc   ;==>MenuExport

Func MenuExit()
	_Exit()
EndFunc   ;==>MenuExit

Func CheckNewName($NewFolderNameCheck)
	If StringCompare($NewFolderNameCheck, "") Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>CheckNewName

Func MenuBitTorrent()
	$hGUI = GUICreate("Settings", 150, 230)
	$BTSyncOption_Button_Save = GUICtrlCreateButton("Save", 30, 180, 65, 35)
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

	GUISetState(@SW_HIDE, $SafeSyncManagementTool)
	GUISetState(@SW_SHOW, $hGUI)
	$test = 1
	While $test
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				GUIDelete($hGUI)
			Case $BTSyncOption_Button_Save
				If BitAND(GUICtrlRead($BTSyncOption_ShowGUI_True), $GUI_CHECKED) = $GUI_CHECKED Then
					RegWrite($SafeSyncRegistrySoftwareManagementTool, "ShowGUI", "REG_SZ", "true")
					$BTSyncShowGUI = "true"
				Else
					RegWrite($SafeSyncRegistrySoftwareManagementTool, "ShowGUI", "REG_SZ", "false")
					$BTSyncShowGUI = "false"
				EndIf
				ReloadListView()
				GUISetState(@SW_SHOW, $SafeSyncManagementTool)
				GUIDelete($hGUI)
				$test = 0
		EndSwitch
	WEnd
EndFunc   ;==>MenuBitTorrent

Func MenuCrypt()
	MsgBox(0, "TODO", "Open real CryptSync?")
EndFunc   ;==>MenuCrypt

Func MenuOther()
	MsgBox(0, "TODO", "General settings")
EndFunc   ;==>MenuOther

Func MenuAbout()
	MsgBox(0, "About SafeSync", "SafeSync" & @LF & "Version 0.0.1.2" & @LF & "  16.02.2015" & @LF & "by SafeSync-Team")
EndFunc   ;==>MenuAbout

Func _Exit()
	Exit
EndFunc   ;==>_Exit

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
EndFunc   ;==>_DebugPrint


Func FolderEdit()
	Local $iTimeout = 10
	; Display a message box with a nested variable in its text.
	MsgBox($MB_SYSTEMMODAL, "Title", "This message box will timeout after " & $iTimeout & " seconds or select the OK button.", $iTimeout)
EndFunc   ;==>FolderEdit

#cs ----------------------------------------------------------------------------
	createConfig
	Function to create the config File, from the entries on the registry
#ce ----------------------------------------------------------------------------
Func createConfig($SyncFolders, $Storage_Path)
	DirCreate($Storage_Path)
	_FileCreate($BTSyncConfig)
	Local $hFileOpen = FileOpen($BTSyncConfig, 1)
	If $hFileOpen = -1 Then
		MsgBox("Test", "", "An error occurred when reading the file.")
	EndIf
	; Write data to the file using the handle returned by FileOpen.
	FileWrite($hFileOpen, '{' & @CRLF)
	FileWrite($hFileOpen, '     "storage_path" : "' & $Storage_Path & '",' & @CRLF)
	FileWrite($hFileOpen, '     "check_for_updates" : false,' & @CRLF)
	FileWrite($hFileOpen, '     "use_gui" : ' & $BTSyncShowGUI & ',' & @CRLF)
	FileWrite($hFileOpen, '     "webui" :' & @CRLF)
	FileWrite($hFileOpen, '     {' & @CRLF)
	FileWrite($hFileOpen, '          "listen" : "127.0.0.1:7878",' & @CRLF)
	;   FileWrite($hFileOpen, '          "login" : "login",'& @CRLF)
	;   FileWrite($hFileOpen, '          "password" : "passwd",'& @CRLF)
	FileWrite($hFileOpen, '          "api_key" : "UPK4TNW735M6D4UERSZ7EW6A2VRRPMA5JJKFJ6JTYSPTNGTN4JGCLBUOJ46I6ZDXHRLT3PHGQD76I4SGVJWLNII7TPNFNMBOJ4J3KBAPDMVBKCXLNNSCJUMDLQTRW4BMQ6OZHPA"' & @CRLF)
	FileWrite($hFileOpen, '     }' & @CRLF)
	FileWrite($hFileOpen, '     ,' & @CRLF)
	FileWrite($hFileOpen, '     "shared_folders" :' & @CRLF)
	FileWrite($hFileOpen, '     [' & @CRLF)
	$Counter = UBound($SyncFolders, $UBOUND_ROWS) - 1
	For $element = 1 To $Counter
		If $element <= $Counter And $element >= 2 Then
			FileWrite($hFileOpen, '     ,' & @CRLF)
		EndIf
		FileWrite($hFileOpen, '     {' & @CRLF)
		FileWrite($hFileOpen, '     "secret" : "' & $SyncFolders[$element][1] & '",' & @CRLF)
		FileWrite($hFileOpen, '     "dir" : "' & StringReplace($SyncFolders[$element][0], "\", "/") & '",' & @CRLF)
		FileWrite($hFileOpen, '     "use_relay_server" : true,' & @CRLF)
		FileWrite($hFileOpen, '     "use_tracker" : true,' & @CRLF)
		FileWrite($hFileOpen, '     "use_dht" : false,' & @CRLF)
		FileWrite($hFileOpen, '     "search_lan" : true,' & @CRLF)
		FileWrite($hFileOpen, '     "use_sync_trash" : true' & @CRLF)
		FileWrite($hFileOpen, '     }' & @CRLF)
	Next
	FileWrite($hFileOpen, '     ]' & @CRLF)
	FileWrite($hFileOpen, '}' & @CRLF)
EndFunc   ;==>createConfig

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

	$NewKey = StringRegExpReplace($NewKey, "{*:", "")

	$WriteKey = StringSplit($NewKey, '"')

	;Return $WriteKey[8]
	Return "TestKey"
	; Delete the file.
	FileDelete($sFilePath)
EndFunc   ;==>getNewKey

#cs ----------------------------------------------------------------------------
	StopProcess
#ce ----------------------------------------------------------------------------
Func StopProcess($ProcessName)
	Local $aProcessList = ProcessList($ProcessName)
	For $i = 1 To $aProcessList[0][0]
		ProcessClose($aProcessList[$i][1])
	Next
EndFunc   ;==>StopProcess

#cs ----------------------------------------------------------------------------
	StopProcess
#ce ----------------------------------------------------------------------------
Func ChooseDecryptEncryptFolder($FolderName, $FolderData)
	; Create a GUI with various controls.
	$TempString = ""
	If StringCompare($TempString, $FolderData) = 0 Then
		$FolderData = $SafeSyncStandardDataFolder & "\" & $FolderName
	EndIf
	Local $InstallationDialog = GUICreate("SafeSync - Select Folder", 430, 170)
	Local $OKButton = GUICtrlCreateButton("OK", 320, 130, 85, 25)
	Local $DecryptDirectory = GUICtrlCreateLabel("DecryptFolder:", 10, 20)
	Local $DecryptDir = GUICtrlCreateInput($FolderData, 10, 38, 300)
	Local $DecryptDirSelect = GUICtrlCreateButton("SelectFolder", 320, 36, 100)
	Local $EncryptDirectory = GUICtrlCreateLabel("EncryptFolder:", 10, 70)
	Local $EncryptDir = GUICtrlCreateInput($FolderData & "Encrypt", 10, 88, 300)
	Local $EncryptDirSelect = GUICtrlCreateButton("SelectFolder", 320, 86, 100)
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
				GUICtrlSetData($DecryptDir, FileSelectFolder("Choose the destination folder", $InstallLocationSafeSync))
			Case $EncryptDirSelect
				GUICtrlSetData($EncryptDir, FileSelectFolder("Choose Standard Data Folder", $InstallLocationSafeSync))
		EndSwitch
	WEnd
	Local $arr[2]
	$arr[0] = GUICtrlRead($DecryptDir)
	$arr[1] = GUICtrlRead($EncryptDir)
	GUIDelete($InstallationDialog)
	GUISetState(@SW_SHOW, $SafeSyncManagementTool)
	Return $arr
EndFunc   ;==>ChooseDecryptEncryptFolder

#cs ----------------------------------------------------------------------------
	run Register file Extision, for supporting .ssf - files
#ce ----------------------------------------------------------------------------
Func RegisterFileExtension($InstallPath, $DataDir)
	;RunWait( @ComSpec & ' /c ' & @TempDir & '\InstallSafeSync.exe "' & $InstallPath & '" "' & @ScriptFullPath & '"', @TempDir , @SW_HIDE )
	;RunWait( @ComSpec & ' /c ' & @TempDir & '\InstallSafeSync.exe "' & $DataDir & '"', @TempDir , @SW_HIDE )
	ConsoleWrite("Run File-Extension support" & @CRLF)
	ConsoleWrite("Run: " & @TempDir & "\RegisterSSF.exe" & @CRLF)
	RunWait(@ComSpec & ' /c ' & @TempDir & "\RegisterSSF.exe", @TempDir, @SW_HIDE)
	RegWrite($SafeSyncRegistrySoftware, "FileRegistered", "REG_SZ", "1")
EndFunc   ;==>RegisterFileExtension

Func CheckAdmin()
	If Not IsAdmin() Then
		ConsoleWrite($RunSafeSyncAsAdmin)
		Run(@ComSpec & ' /c ' & $RunSafeSyncAsAdmin, @TempDir, @SW_HIDE)
		Exit
	EndIf
EndFunc   ;==>CheckAdmin

#cs ----------------------------------------------------------------------------
	AutoIt Version: 	3.3.12.0
	Author:				Tim Christoph Lid
	Name:				SafeCrypt x64
	Script Function:
	SafeCrypt Tool
	TODO:
	Check File encryption, with wrong filenames? Maybe not needed
#ce ----------------------------------------------------------------------------

#cs ----------------------------------------------------------------------------
	Install SafeSync if not installed yes
#ce ----------------------------------------------------------------------------
;If Not StringCompare( $DisplayName, RegRead( $SafeCryptRegistry, "DisplayName")) = 0 Then
;	Install()
;EndIf

#cs ----------------------------------------------------------------------------
	Command line parameters
#ce ----------------------------------------------------------------------------



; Read command line parameters
; Create Registry, if an external file is open with command line parameter "ImportFile"
#cs
	If Not $CmdLine[0] = 0 Then
	If $CmdLine[1] == "AddFolder" Then
	FileOpen($CmdLine[2])
	RegWrite($SafeCryptFoldersRegistry)
	RegWrite($SafeCryptFoldersRegistry & "\" & $CmdLine[2])
	RegWrite($SafeCryptFoldersRegistry & "\" & $CmdLine[2], "Encrypt", "REG_SZ", $CmdLine[3])
	RegWrite($SafeCryptFoldersRegistry & "\" & $CmdLine[2], "Decrypt", "REG_SZ", $CmdLine[4])
	Exit
	EndIf
	If $CmdLine[1] == "/Install" Then
	Install()
	Exit
	EndIf
	EndIf
#ce



Func RunSafeCrypt()
	While 1
		For $i = 1 To 100
			If RegRead($SafeSyncRegistrySoftwareManagementTool, "RunSafeCrypt") = 0 Then
				Exit
			EndIf
			$var = RegEnumKey($SafeSyncRegistryFolders, $i)
			If @error <> 0 Then ExitLoop
			If RegRead($SafeSyncRegistryFolders & "\" & $var, "UseEncryption") Then
				Local $PasswordFolder = BinaryToString(DecryptPassword(RegRead($SafeSyncRegistryFolders & "\" & $var, "Password"), RegRead($SafeSyncRegistryFolders & "\" & $var, "PasswordSalt")))
				SafeCrypt($var, RegRead($SafeSyncRegistryFolders & "\" & $var, "Decrypt"), RegRead($SafeSyncRegistryFolders & "\" & $var, "Encrypt"), "", "", "", "", $PasswordFolder)
			EndIf
		Next
		Sleep(5000)
	WEnd
EndFunc   ;==>RunSafeCrypt

Func SafeCrypt($FolderName, $DataFolderDecrypt, $DataFolderEncrypt, $LogListFolderDecrypt, $LogListFolderEncrypt, $LogListFileDecrypt, $LogListFileEncrypt, $PasswordFolder)

	DirGetSize($DataFolderDecrypt)
	If @error Then
		ConsoleWrite("Folder not exists: " & $DataFolderDecrypt & @CRLF)
	Else
		DirGetSize($DataFolderDecrypt)
		If @error Then
			ConsoleWrite("Folder not exists: " & $DataFolderDecrypt)
		Else
			DirCreate(@AppDataDir & "\SafeCrypt")
			DirCreate(@AppDataDir & "\SafeCrypt\" & $FolderName)

			$AppDir = @AppDataDir & "\SafeCrypt\" & $FolderName
			$LogListFolderDecrypt = $AppDir & "\FolderDecrypt.txt"
			$LogListFolderEncrypt = $AppDir & "\FolderEncrypt.txt"
			$LogListFileDecrypt = $AppDir & "\FileDecrypt.txt"
			$LogListFileEncrypt = $AppDir & "\FileEncrypt.txt"

			If Not FileExists($LogListFolderDecrypt) Then
				_FileCreate($LogListFolderDecrypt)
			EndIf

			If Not FileExists($LogListFolderEncrypt) Then
				_FileCreate($LogListFolderEncrypt)
			EndIf

			If Not FileExists($LogListFileDecrypt) Then
				_FileCreate($LogListFileDecrypt)
			EndIf

			If Not FileExists($LogListFileEncrypt) Then
				_FileCreate($LogListFileEncrypt)
			EndIf

			; Check Deleted Folder
			ConsoleWrite("Check Deleted Folder" & @CRLF)
			CheckDeletedFilesOrFolders(2, $DataFolderDecrypt, $DataFolderEncrypt, $LogListFileEncrypt, $LogListFileDecrypt, $LogListFolderEncrypt, $LogListFolderDecrypt)

			; Check Deleted Files
			ConsoleWrite("Check Deleted Files" & @CRLF)
			CheckDeletedFilesOrFolders(1, $DataFolderDecrypt, $DataFolderEncrypt, $LogListFileEncrypt, $LogListFileDecrypt, $LogListFolderEncrypt, $LogListFolderDecrypt)

			; Check for Changes in Files
			ConsoleWrite("Check Deleted Files" & @CRLF)
			CheckChangedFiles($LogListFileDecrypt, $LogListFileEncrypt, $DataFolderDecrypt, $DataFolderEncrypt, $PasswordFolder)

			; Copy Folder from Decrypt to Encrypt
			ConsoleWrite("Copy Folder from Decrypt to Encrypt" & @CRLF)
			CopyFilesOrFolder($DataFolderDecrypt, $DataFolderEncrypt, 2, 0, $PasswordFolder)

			; Copy Folder from Encrypt to Decrypt
			ConsoleWrite("Copy Folder from Encrypt to Decrypt" & @CRLF)
			CopyFilesOrFolder($DataFolderEncrypt, $DataFolderDecrypt, 2, 0, $PasswordFolder)

			; Copy Files from Encrypt to Decrypt
			ConsoleWrite("Copy Files from Encrypt to Decrypt" & @CRLF)
			CopyFilesOrFolder($DataFolderEncrypt, $DataFolderDecrypt, 1, 1, $PasswordFolder)
			ConsoleWrite("Copy Files from Encrypt to Decrypt Ends" & @CRLF)

			; Copy Files from Decrypt to Encrypt
			ConsoleWrite("Copy Files from Decrypt to Encrypt" & @CRLF)
			CopyFilesOrFolder($DataFolderDecrypt, $DataFolderEncrypt, 1, 0, $PasswordFolder)
			ConsoleWrite("Copy Files from Decrypt to Encrypt Ends" & @CRLF)

			; Generate New File Lists, for the Next run
			ConsoleWrite("Generate Lists" & @CRLF)
			GenerateList($DataFolderDecrypt, $LogListFileDecrypt, 1)
			GenerateList($DataFolderEncrypt, $LogListFileEncrypt, 1)
			GenerateList($DataFolderDecrypt, $LogListFolderDecrypt, 2)
			GenerateList($DataFolderEncrypt, $LogListFolderEncrypt, 2)
			ConsoleWrite("Generate Lists End" & @CRLF)
		EndIf
	EndIf
EndFunc   ;==>SafeCrypt

; Copy Files from Decrypt to Encrypt
Func CopyFilesOrFolder($LeftFolder, $RightFolder, $Param, $Decrypt, $PasswordFolder)
	$FileList = _FileListToArrayRec($LeftFolder, "*|.sync|.sync", $Param, 1, Default, 2)
	If Not @error Then
		For $i = 1 To $FileList[0] Step 1
			If $Param = 1 Then
				$PathSplit = _PathSplit(StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1), $sDrive, $sDir, $sFilename, $sExtension)
				If $Decrypt Then
					If Not FileExists($PathSplit[1] & $PathSplit[2] & $PathSplit[3]) Then
						ConsoleWrite("Decrypt File1: " & $PathSplit[1] & $PathSplit[2] & $PathSplit[3] & @CRLF)
						DecryptFile($FileList[$i], $PathSplit[1] & $PathSplit[2], $PasswordFolder)
						;FileCopy( $FileList[$i], StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1))
					EndIf
				Else
					If Not FileExists(StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1) & ".7z") Then
						EncryptFile($FileList[$i], StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1) & ".7z", $PasswordFolder)
						ConsoleWrite("Encrypt File1: " & StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1) & @CRLF)
						;FileCopy( $FileList[$i], StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1))
					EndIf
				EndIf
			ElseIf $Param = 2 Then
				DirGetSize(StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1))
				If @error Then
					ConsoleWrite("Dir Create: " & StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1) & @CRLF)
					DirCreate(StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1))
				EndIf
			EndIf
		Next
	EndIf
EndFunc

#cs CheckChangedFiles - Documentation
Name:               CheckChangedFiles
Version:			0.1
Description:        Function, Check for deleted Files and delete the file on the other side
Author:             Tim Lid
Parameters:         $CDFOF_Param		- String: The folder to scan
					$CDFOF_DataFolderDecrypt		- String: Path of the decrypt data folder
					$CDFOF_DataFolderEncrypt		- String: Path of the encrypt data folder
					$CDFOF_LogListFileEncrypt		- String: Path to log list of decrypt file
					$CDFOF_LogListFileDecrypt		- String: Path to log list of decrypt file
					$CDFOF_LogListFolderEncrypt		- String: Path to log list of encrypt folder
					$CDFOF_LogListFolderDecrypt		- String: Path to log list of decrypt folder
Return values:      Success:				- Delete files on the other location
                    Failure:				- TODO
Last edit:			2015.04.16 - 10:27 - renaming variables
TODO:				Commentation; Failure; Console output
#ce
Func CheckDeletedFilesOrFolders($CDFOF_Param, $CDFOF_DataFolderDecrypt, $CDFOF_DataFolderEncrypt, $CDFOF_LogListFileEncrypt, $CDFOF_LogListFileDecrypt, $CDFOF_LogListFolderEncrypt, $CDFOF_LogListFolderDecrypt)
	Local $CDFOF_ListDecrypt
	Local $CDFOF_ListEncrypt
	If $CDFOF_Param = 1 Then
		_FileReadToArray($CDFOF_LogListFileDecrypt, $CDFOF_ListDecrypt)
		If Not @error Then
			For $i = 1 To $CDFOF_ListDecrypt[0] Step 3
				If Not FileExists($CDFOF_ListDecrypt[$i] & $CDFOF_ListDecrypt[$i + 1]) Then
					Local $CDFOF_EncryptFile = StringReplace($CDFOF_ListDecrypt[$i], $CDFOF_DataFolderDecrypt, $CDFOF_DataFolderEncrypt, 1) & $CDFOF_ListDecrypt[$i + 1] & ".7z"
					If FileExists($CDFOF_EncryptFile) Then
						ConsoleWrite("Delete Encrypted File: " & $CDFOF_EncryptFile & @CRLF)
						Local $iDelete = FileDelete($CDFOF_EncryptFile)
					EndIf
				EndIf
			Next
		EndIf
		_FileReadToArray($CDFOF_LogListFileEncrypt, $CDFOF_ListEncrypt)
		If Not @error Then
			For $i = 1 To $CDFOF_ListEncrypt[0] Step 3
				If Not FileExists($CDFOF_ListEncrypt[$i] & $CDFOF_ListEncrypt[$i + 1]) Then
					$PathSplit = _PathSplit(StringReplace($CDFOF_ListEncrypt[$i], $CDFOF_DataFolderEncrypt, $CDFOF_DataFolderDecrypt, 1) & $CDFOF_ListEncrypt[$i + 1], $sDrive, $sDir, $sFilename, $sExtension)
					$CDFOF_DecryptFile = $PathSplit[1] & $PathSplit[2] & $PathSplit[3]
					If FileExists($CDFOF_DecryptFile) Then
						ConsoleWrite("Delete Decrypted File: " & $CDFOF_DecryptFile & @CRLF)
						Local $iDelete = FileDelete($CDFOF_DecryptFile)
					EndIf
				EndIf
			Next
		EndIf
	ElseIf $CDFOF_Param = 2 Then
		_FileReadToArray($CDFOF_LogListFolderDecrypt, $CDFOF_ListDecrypt)
		If Not @error Then
			For $i = 1 To $CDFOF_ListDecrypt[0] Step 3
				DirGetSize($CDFOF_ListDecrypt[$i] & $CDFOF_ListDecrypt[$i + 1])
				If @error Then
					ConsoleWrite("Delete Folder1: " & StringReplace($CDFOF_ListDecrypt[$i], $CDFOF_DataFolderDecrypt, $CDFOF_DataFolderEncrypt, 1) & $CDFOF_ListDecrypt[$i + 1] & @CRLF)
					DirRemove(StringReplace($CDFOF_ListDecrypt[$i], $CDFOF_DataFolderDecrypt, $CDFOF_DataFolderEncrypt, 1) & $CDFOF_ListDecrypt[$i + 1], 1)
				EndIf
			Next
		EndIf
		_FileReadToArray($CDFOF_LogListFolderEncrypt, $CDFOF_ListEncrypt)
		If Not @error Then
			For $i = 1 To $CDFOF_ListEncrypt[0] Step 3
				DirGetSize($CDFOF_ListEncrypt[$i] & $CDFOF_ListEncrypt[$i + 1])
				If @error Then
					$EncryptFolder = StringReplace($CDFOF_ListEncrypt[$i], $CDFOF_DataFolderEncrypt, $CDFOF_DataFolderDecrypt, 1) & $CDFOF_ListEncrypt[$i + 1]
					ConsoleWrite("Delete Folder2: " & $EncryptFolder & @CRLF)
					DirRemove($EncryptFolder, 1)
				EndIf
			Next
		EndIf
	EndIf
EndFunc

#cs CheckChangedFiles - Documentation
Name:               CheckChangedFiles
Version:			0.1
Description:        Function, Check for Changes in Files with MD5 Checksum
Author:             Tim Lid
Parameters:         $CCF_LogListFileDecrypt		- String: The folder to scan
					$CCF_LogListFileEncrypt		- String: The encrypt file location
					$CCF_DataFolderDecrypt		- String: Parameter 1: choosing Folder / 2: choosing File
					$CCF_DataFolderEncrypt		- Array[String] Files/Folders in $GL_ScanFolder
					$CCF_PasswordFolder			- String: Password for de/encryption
Return values:      Success:				- Changed files, are updated to the other location
                    Failure:				- TODO
Last edit:			2015.04.16 - 08:51 - Documentation
TODO:				Commentation; Failure; rename variables
#ce
Func CheckChangedFiles($CCF_LogListFileDecrypt, $CCF_LogListFileEncrypt, $CCF_DataFolderDecrypt, $CCF_DataFolderEncrypt, $CCF_PasswordFolder)
	Local $CCF_LeftFolder
	Local $CCF_RightFolder
	_FileReadToArray($CCF_LogListFileEncrypt, $CCF_LeftFolder)
	If Not @error Then
		For $i = 1 To $CCF_LeftFolder[0] Step 3
			$NewHash = _Crypt_HashFile($CCF_LeftFolder[$i] & $CCF_LeftFolder[$i + 1], $CALG_MD5)
			$OldHash = $CCF_LeftFolder[$i + 2]
			$PathSplit = _PathSplit(StringReplace($CCF_LeftFolder[$i], $CCF_DataFolderEncrypt, $CCF_DataFolderDecrypt, 1) & $CCF_LeftFolder[$i + 1], $sDrive, $sDir, $sFilename, $sExtension)
			If $OldHash <> $NewHash Then
				If FileExists($CCF_LeftFolder[$i] & $CCF_LeftFolder[$i + 1]) Then
					ConsoleWrite("Change in File: " & $CCF_LeftFolder[$i] & $CCF_LeftFolder[$i + 1] & @CRLF)
					ConsoleWrite("Decrypt To: " & StringReplace($CCF_LeftFolder[$i], $CCF_DataFolderEncrypt, $CCF_DataFolderDecrypt, 1) & $CCF_LeftFolder[$i + 1] & @CRLF)
					FileDelete(StringReplace($CCF_LeftFolder[$i], $CCF_DataFolderEncrypt, $CCF_DataFolderDecrypt, 1) & $CCF_LeftFolder[$i + 1])
					$From = $CCF_LeftFolder[$i] & $CCF_LeftFolder[$i + 1]
					$To = StringReplace($CCF_LeftFolder[$i], $CCF_DataFolderEncrypt, $CCF_DataFolderDecrypt, 1) & $CCF_LeftFolder[$i + 1]
					ConsoleWrite($CCF_LeftFolder[$i] & $CCF_LeftFolder[$i + 1] & "    " & $PathSplit[1] & $PathSplit[2] & $PathSplit[3] & @CRLF)
					DecryptFile($CCF_LeftFolder[$i] & $CCF_LeftFolder[$i + 1], $PathSplit[1] & $PathSplit[2], $CCF_PasswordFolder)
					;FileCopy( $LeftFolder[$i] & $LeftFolder[$i+1], StringReplace($LeftFolder[$i], $DataFolderEncrypt, $DataFolderDecrypt, 1) & $LeftFolder[$i+1] )
				EndIf
			EndIf
		Next
	EndIf
	_FileReadToArray($CCF_LogListFileDecrypt, $CCF_RightFolder)
	If Not @error Then
		For $i = 1 To $CCF_RightFolder[0] Step 3
			$NewHash = _Crypt_HashFile($CCF_RightFolder[$i] & $CCF_RightFolder[$i + 1], $CALG_MD5)
			$OldHash = $CCF_RightFolder[$i + 2]
			If $OldHash <> $NewHash Then
				If FileExists($CCF_RightFolder[$i] & $CCF_RightFolder[$i + 1]) Then
					FileDelete(StringReplace($CCF_RightFolder[$i], $CCF_DataFolderDecrypt, $CCF_DataFolderEncrypt, 1) & $CCF_RightFolder[$i + 1])
					EncryptFile($CCF_RightFolder[$i] & $CCF_RightFolder[$i + 1], StringReplace($CCF_RightFolder[$i], $CCF_DataFolderDecrypt, $CCF_DataFolderEncrypt, 1) & $CCF_RightFolder[$i + 1] & ".7z", $CCF_PasswordFolder)
				EndIf
			EndIf
		Next
	EndIf
EndFunc

#cs GenerateList - Documentation
Name:               GenerateList
Version:			0.1
Description:        Function, List all the files or folders in the desktop directory using the default parameters and return the array.
Author:             Tim Lid
Parameters:         $GL_ScanFolder			- String: The folder to scan
					$GL_OutputList			- String: The encrypt file location
					$GL_Param				- String: Parameter 1: choosing Folder / 2: choosing File
					$GL_GeneratedList		- Array[String] Files/Folders in $GL_ScanFolder
					$GL_SplitPath			- Array[String] The Path splited into their elements
Return values:      Success:				- String: Generated list of Files/Folders in an array
                    Failure:				- TODO
Last edit:			2015.04.16 - 08:51 - Documentation
TODO:				Commentation; Failure; rename variables
#ce
Func GenerateList($GL_ScanFolder, $GL_OutputList, $GL_Param)
	FileDelete($GL_OutputList)
	Local $GL_GeneratedList = _FileListToArrayRec($GL_ScanFolder, "*|.sync|.sync", $GL_Param, 1, Default, 2)
	If Not @error Then
		_FileCreate($GL_OutputList)
		Local $GL_OutputListOpen = FileOpen($GL_OutputList, $FO_APPEND)
		If $GL_OutputListOpen = -1 Then
			MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
			Return False
		EndIf
		Local $GL_GeneratedListWithHash[$GL_GeneratedList[0] + 1][2]
		For $i = 1 To $GL_GeneratedList[0]
			$GL_GeneratedListWithHash[$i][0] = $GL_GeneratedList[$i]
			$GL_GeneratedListWithHash[$i][1] = _Crypt_HashFile($GL_GeneratedList[$i], $CALG_MD5)
			Local $GL_SplitPath = _PathSplit($GL_GeneratedList[$i], $sDrive, $sDir, $sFilename, $sExtension)
			FileWriteLine($GL_OutputListOpen, $GL_SplitPath[1] & $GL_SplitPath[2] & @CRLF)
			FileWriteLine($GL_OutputListOpen, $GL_SplitPath[3] & $GL_SplitPath[4] & @CRLF)
			FileWriteLine($GL_OutputListOpen, $GL_GeneratedListWithHash[$i][1] & @CRLF)
		Next
		FileClose($GL_OutputListOpen)
	EndIf
	Return $GL_GeneratedList
EndFunc

#cs DecryptFile - Documentation
Name:               DecryptFile
Version:			0.1
Description:        Decrypt a file with a password by using 7zip
Author:             Tim Lid
Parameters:         $DF_DecryptFolder		- String: The decrypt folder location
					$DF_EncryptFile			- String: The encrypt file location
					$EF_Password			- String: The password for the encryption
Return values:      Success:				- String: The file is decrypt
                    Failure:				- TODO
Last edit:			2015.04.16 - 08:42 - renaming variables
TODO:				Commentation; Failure
#ce
Func DecryptFile($DF_EncryptFile, $DF_DecryptFolder, $DF_Password)
	ConsoleWrite("Decript:" & @ComSpec & ' /c ' & $7zLocation & ' x -y -t7z -o"' & $DF_DecryptFolder & '" -p"' & "%Password%" & '" "' & $DF_EncryptFile & '"' & @CRLF)
	RunWait(@ComSpec & ' /c ' & $7zLocation & ' x -y -t7z -o"' & $DF_DecryptFolder & '" -p"' & $DF_Password & '" "' & $DF_EncryptFile & '"', @TempDir, @SW_HIDE)
EndFunc

#cs EncryptFile - Documentation
Name:               EncryptFile
Version:			0.1
Description:        Encrypt a file with a password by using 7zip
Author:             Tim Lid
Parameters:         $EF_DecryptFile			- String: The decrypt file location
					$EF_EncryptFile			- String: The encrypt file location
					$EF_Password			- String: The password for the encryption
Return values:      Success:				- String: The file is encrypt
                    Failure:				- TODO
Last edit:			2015.04.15 - 22:10 - Documentation
TODO:				Commentation; Failure
#ce
Func EncryptFile($EF_DecryptFile, $EF_EncryptFile, $EF_Password)
	ConsoleWrite("Encrypt: " & @ComSpec & ' /c ' & $7zLocation & ' a -y -t7z -p"' & "%Password%" & '" "' & $EF_EncryptFile & '" "' & $EF_DecryptFile & '"' & @CRLF)
	RunWait(@ComSpec & ' /c ' & $7zLocation & ' a -y -t7z -p"' & $EF_Password & '" "' & $EF_EncryptFile & '" "' & $EF_DecryptFile & '"', @TempDir, @SW_HIDE)
EndFunc

#cs PasswordCheck - Documentation
Name:               PasswordCheck
Version:			0.1
Description:        Check if Password is set. If not, create a new Masterpassword for the SafeSyncManagementool
Author:             Tim Lid
Parameters:         $PC_Password			- String: The password
                    $PC_Salt				- String: A salt, for englarging the password
					$PC_PasswordHash		- String: The hash of the current password
					$PC_PasswordCheck		- String: The second password input from the user
Return values:      Success:				- String: The password.
                    Failure:				- Restart until the password is correct
Last edit:			2015.04.15 - 22:03 - Documentation
TODO:				Commentation
#ce
Func PasswordCheck()
	$PC_Password = ""
	If Not RegRead($SafeCryptRegistrySoftware, "Installed") = 1 Then
		RegWrite($SafeCryptRegistrySoftware)
		$PC_Salt = ""
		For $i = 0 To 100 Step 1
			$PC_Salt = $PC_Salt & Chr(Random(32, 126, 1))
		Next
		While 1
			Local $PC_Password = InputBox("Set password", "Enter your new password.", "", "*")
			Local $PC_PasswordHash = $PC_Password
			If @error = 1 Then
				Exit
			EndIf
			Local $PC_PasswordCheck = InputBox("Set password", "Retype your password.", "", "*")
			If @error = 1 Then
				Exit
			EndIf
			If Not $PC_Password = $PC_PasswordCheck Then
				MsgBox(16, "Error", "Passwords doesn't match")
			Else
				If StringLen($PC_Password) <= 6 Then
					MsgBox(16, "Error", "Please choose a Password greater then 6")
				Else
					For $i = 0 To 3000 Step 1
						$PC_PasswordHash = _Crypt_HashData($PC_PasswordHash & $PC_Salt, $CALG_SHA1)
					Next
					RegWrite($SafeCryptRegistrySoftware, "PasswordHashed", "REG_SZ", $PC_PasswordHash)
					RegWrite($SafeCryptRegistrySoftware, "Installed", "REG_DWORD", "1")
					RegWrite($SafeCryptRegistrySoftware, "Salt", "REG_SZ", $PC_Salt)
					ExitLoop
				EndIf
			EndIf
		WEnd
	EndIf
	If Not StringCompare($PC_Password, "") Then
		While 1
			Local $PC_Password = InputBox("Security Check", "Enter your password.", "", "*")
			If @error = 1 Then
				Exit
			EndIf
			$PC_PasswordHash = $PC_Password
			$PC_Salt = RegRead($SafeCryptRegistrySoftware, "Salt")
			For $i = 0 To 3000 Step 1
				$PC_PasswordHash = _Crypt_HashData($PC_PasswordHash & $PC_Salt, $CALG_SHA1)
			Next
			If $PC_PasswordHash = RegRead($SafeCryptRegistrySoftware, "PasswordHashed") Then
				ExitLoop
			Else
				MsgBox(16, "Error", "Wrong password")
			EndIf
		WEnd
	EndIf
	Return BinaryToString($PC_Password)
EndFunc

#cs _CalculateBitEntropy - Documentation
Name:               _CalculateBitEntropy (Thanks dany)
Version:			0.2
Description:        Calculate the bit entropy of a string.
Author:             dany / improved by Tim Lid, bug fixing: When using upper/lower Chars and! special character
Parameters:         $CBE_PasswordForEntropy	- String: String to evaluate.
                    $CBE_UseCaseSensitive	- Boolean: Do case-sensitive evaluation, default true.
					$CBE_PasswordLenght		- Int: The lenght of the password
					$CBE_SplitedPassword	- Array[String]: Password is cutted in substrings, whitespaces
					$CBE_EntropyFactor		- Floeat: Bit entropy factor
Return values:      Success:				- Float: Bit entropy.
                    Failure:				- 0 and sets @error
Last edit:			2015.04.15 - 16:25 - Bug fix / Documentation / renaming variables
Link:				<a href='http://www.autoitscript.com/forum/topic/139260-autoit-snippets/page__st__80#entry1021181</a>
Link:               <a href='http://en.wikipedia.org/wiki/Password_strength#Entropy_as_a_measure_of_password_strength' class='bbc_url' title='External link' rel='nofollow external'>http://en.wikipedia.org/wiki/Password_strength#Entropy_as_a_measure_of_password_strength</a>
TODO:				Commentation
#ce
Func CalculateBitEntropy($CBE_PasswordForEntropy, $CBE_UseCaseSensitive = True)
    If IsBinary($CBE_PasswordForEntropy) Then $CBE_PasswordForEntropy = BinaryToString($CBE_PasswordForEntropy)
    If Not IsString($CBE_PasswordForEntropy) Then Return SetError(1, 0, 0)
    Local $CBE_SplitedPassword, $CBE_EntropyFactor = 0, $CBE_PasswordLenght = StringLen($CBE_PasswordForEntropy)
    If 0 = $CBE_PasswordLenght Then Return SetError(2, 0, 0)
    $CBE_SplitedPassword = StringSplit($CBE_PasswordForEntropy, ' ')
    If 1 < $CBE_SplitedPassword[0] And StringRegExp($CBE_PasswordForEntropy, '^[[:alnum:] ]+$') Then Return $CBE_SplitedPassword[0] * 12.925
    If StringIsDigit($CBE_PasswordForEntropy) Then
        $CBE_EntropyFactor = 3.3219
    ElseIf StringIsXDigit($CBE_PasswordForEntropy) Then
        $CBE_EntropyFactor = 4.0000
    ElseIf StringIsAlpha($CBE_PasswordForEntropy) Then
        $CBE_EntropyFactor = 4.7004
        If $CBE_UseCaseSensitive Then
            If StringRegExp($CBE_PasswordForEntropy, '[[:lower:]]') And StringRegExp($CBE_PasswordForEntropy, '[[:upper:]]') Then $CBE_EntropyFactor = 5.7004
        EndIf
    ElseIf StringIsAlNum($CBE_PasswordForEntropy) Then
        $CBE_EntropyFactor = 5.1699
        If $CBE_UseCaseSensitive Then
            If StringRegExp($CBE_PasswordForEntropy, '[[:lower:]]') And StringRegExp($CBE_PasswordForEntropy, '[[:upper:]]') Then $CBE_EntropyFactor = 5.9542
        EndIf
    ElseIf StringRegExp($CBE_PasswordForEntropy, '^[^[:cntrl:]x7F]+$') Then
        $CBE_EntropyFactor = 6.5699
    ElseIf StringRegExp($CBE_PasswordForEntropy, '^[^[:cntrl:]x7Fx81x8Dx8Fx90x9D]+$') Then
        $CBE_EntropyFactor = 7.7682
	Else
		$CBE_EntropyFactor = 8
    EndIf
    Return $CBE_EntropyFactor * $CBE_PasswordLenght
EndFunc