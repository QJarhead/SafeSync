#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=include\SafeSync_265.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

AutoIt Version: 	3.3.12.0
Author:				Tim Christoph Lid
Version:			0.0.1.6
Name:				SafeSync Management Tool

TODO:
Commentation

#ce ----------------------------------------------------------------------------

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

; Including files
FileInstall("C:\include\BitTorrent_SyncX64.exe", @TempDir & "\BitTorrent_SyncX64.exe", 1)
FileInstall("C:\include\config.ini", @TempDir & "\config.ini", 1)
FileInstall("C:\include\RegisterSSF.exe", @TempDir & "\RegisterSSF.exe", 1)
FileInstall("C:\include\SafeCrypt.exe", @TempDir & "\SafeCrypt.exe", 1)
FileInstall("C:\include\UninstallSafeSync.exe", @TempDir & "\UninstallSafeSync.exe", 1)
FileInstall("C:\include\InstallSafeSync.exe", @TempDir & "\InstallSafeSync.exe", 1)
FileInstall("C:\include\RunSafeSyncAsAdmin.exe", @TempDir & "\RunSafeSyncAsAdmin.exe", 1)

#cs ----------------------------------------------------------------------------

Static-Variables

#ce ----------------------------------------------------------------------------

; Programs and Features Key
Global $SafeSyncRegistry = "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync"
; SafeCrypt Registry Uninstall
Global $SafeCryptRegistryUninstall = "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeCrypt"
; SafeCrypt Registry
Global $SafeCryptRegistry = "HKEY_CURRENT_USER\Software\SafeCrypt"
; SafeCrypt Folders
Global $SafeCryptFoldersRegistry = $SafeCryptRegistry & "\Folders"
; SafeSync Folders
Global $SafeSyncRegKey = "HKEY_CURRENT_USER\Software\SafeSync\Folders"
; DisplayName for installation
Global $DisplayName = "SafeSync"
; DisplayVersion for installation
Global $DisplayVersion = "0.0.1"
; ConfigFile for BitTorrent Sync
Global $ConfigFileBTSync = @UserProfileDir & "\Program Files\BitTorrent Sync\config.json"
; Publisher for installation
Global $Publisher = "SafeSync-Team"
; For running _PathSplit()
Global $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""
; InstallationLocationBTSync
$InstallationLocationBTSync = @UserProfileDir & "\Program Files\BitTorrent Sync"
; BitTorrent Config Location
$InstallationLocationBTSyncSplit = _PathSplit($InstallationLocationBTSync, $sDrive,$sDir,$sFilename,$sExtension)
;ConfigLocationBTSync
$ConfigLocationBTSync = $InstallationLocationBTSyncSplit[1] & "/" & StringReplace($InstallationLocationBTSyncSplit[2] & $InstallationLocationBTSyncSplit[3], "\", "/" ) & "/StoragePath"
; BTSync Config File Location
$BTSyncConfigCreate = $InstallationLocationBTSync & "\config.json"
; Bittorent Sync Uninstall String
$BTSyncUninstallRegKey = "HKEY_LOCAL_MACHINE64\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BitTorrent Sync"
; Bittorent Sync Uninstall String
$7ZipPathKey = "HKEY_CURRENT_USER64\Software\7-Zip"

#cs ----------------------------------------------------------------------------

Variables

#ce ----------------------------------------------------------------------------

; Read SafeSync Standard Data Folder
$SafeSyncStandardDataFolder =RegRead( "HKEY_CURRENT_USER64\Software\SafeSync", "DataDir")
; Read SafeCrypt Location from Registry
$InstallLocationSafeCrypt = RegRead( "HKEY_CURRENT_USER64\Software\SafeCrypt", "InstallDir")
; Read SafeCrypt Location from Registry
$InstallLocationSafeSync = RegRead( "HKEY_CURRENT_USER64\Software\SafeSync", "InstallDir")
; Temp Dir for BitTorrent_SyncX64.exe
$BitTorrentSyncTemp = @TempDir & "\BitTorrent_SyncX64.exe"
; Temp Dir for BitTorrent_SyncX64.exe
$RunSafeSyncAsAdmin = @TempDir & "\RunSafeSyncAsAdmin.exe " & @ScriptFullPath
; SafeSyncExe
$SafeSyncExe = $InstallLocationSafeSync & "\SafeSync.exe"
; DisplayIcon for
$DisplayIcon = $SafeSyncExe
; UninstallString for Registry
$UninstallString = $SafeSyncExe & " /UNINSTALL"
;Column width in GUI for Name
$ColumnWitdhName = 80
;Column width in GUI for Key
$ColumnWitdhKey = 280
;Column width in GUI for Path
$ColumnWitdhPath = 250
;Column width in GUI for EncryptPath
$ColumnWitdhEncrypt = 240

#cs ----------------------------------------------------------------------------

Command line parameters

#ce ----------------------------------------------------------------------------

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
		RegistryCreateNewFolder($arr[0], $arr[1], $NewFolderName, $NewFolderKey)
		Exit
	ElseIf $CmdLine[1] == "SyncNewFolder" Then
		SyncNewFolder($CmdLine[2])
		Exit
	EndIf
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
If RegRead( $BTSyncUninstallRegKey, "DisplayIcon") == "" Then
	RunWait( '"' & $BitTorrentSyncTemp & '" /PERFORMINSTALL /AUTOMATION')
	DirCreate($ConfigLocationBTSync)
EndIf

#cs ----------------------------------------------------------------------------
Install SafeSync if not installed yes
#ce ----------------------------------------------------------------------------
If Not StringCompare( $DisplayName, RegRead( $SafeSyncRegistry, "DisplayName")) = 0 Then
	CheckAdmin()
	Install()
EndIf

#cs ----------------------------------------------------------------------------
Install SafeCrypt if not installed yes
#ce ----------------------------------------------------------------------------
$SafeCryptName = "SafeCrypt"
If Not StringCompare( $SafeCryptName, RegRead( $SafeCryptRegistryUninstall, "DisplayName")) = 0 Then
	CheckAdmin()
	RunWait(@TempDir & "\SafeCrypt.exe /Install")
EndIf

#cs ----------------------------------------------------------------------------
Install SafeCrypt if not installed yes
#ce ----------------------------------------------------------------------------
RegRead($7ZipPathKey,"Path")
If @error Then
	CheckAdmin()
	RunWait(@ComSpec & ' /c ' & @TempDir & "\7z938-x64.msi /quiet /passive ", @TempDir , @SW_HIDE)
EndIf

#cs ----------------------------------------------------------------------------

SetVariables after Installation

#ce ----------------------------------------------------------------------------

; Read SafeCrypt Location from Registry
$InstallLocationSafeCrypt = RegRead( "HKEY_CURRENT_USER64\Software\SafeCrypt", "InstallDir")
; Read SafeCrypt Location from Registry
$InstallLocationSafeSync = RegRead( "HKEY_CURRENT_USER64\Software\SafeSync", "InstallDir")
; Temp Dir for BitTorrent_SyncX64.exe

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
Run( $InstallLocationSafeCrypt & "/SafeCrypt.exe")

; Running the Gui in Loop
While 1
	$nMsg = GUIGetMsg(1)
	Switch $nMsg[0] ; check which GUI sent the message
		Case $GUI_EVENT_CLOSE
			Switch $nMsg[1]
				Case $Form1
					GUISetState(@SW_SHOW,$SafeSyncManagementTool)
					GUISetState(@SW_HIDE,$Form1)
					GUISwitch($SafeSyncManagementTool)
				Case $SafeSyncManagementTool
					StopBTSync()
					StopProcess("SafeCrypt.exe")
					ExitLoop
			EndSwitch
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
					;Local $NewFolderKey = InputBox("Folder Name", "Enter folder Name", "", "")
					;MsgBox(64, "Passed Parameters", getNewKey())
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
					;Local $NewFolderKey = InputBox("Folder Name", "Enter folder Name", "", "")
					;MsgBox(64, "Passed Parameters", getNewKey())
					RegistryCreateNewFolder($NewFolderKeyDataDecrypt, $NewFolderKeyDataEncrypt, $NewFolderName, $NewFolderKey)
					ReloadListView()
					GUISetState(@SW_SHOW,$SafeSyncManagementTool)
					GUISetState(@SW_HIDE,$Form1)
        EndSelect
   EndSwitch
WEnd

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
				RegWrite( $SafeSyncRegistry)
				RegWrite( $SafeSyncRegistry, "DisplayIcon", "REG_SZ", GUICtrlRead($InstallDir) & "\SafeSync.exe")
				RegWrite( $SafeSyncRegistry, "DisplayName", "REG_SZ", $DisplayName)
				RegWrite( $SafeSyncRegistry, "DisplayVersion", "REG_SZ", $DisplayVersion)
				RegWrite( $SafeSyncRegistry, "InstallLocation", "REG_SZ", GUICtrlRead($InstallDir) )
				RegWrite( "HKEY_CURRENT_USER64\Software\SafeSync", "InstallDir", "REG_SZ", GUICtrlRead($InstallDir) )
				RegWrite( "HKEY_CURRENT_USER64\Software\SafeSync", "DataDir", "REG_SZ", GUICtrlRead($DataDir))
				RegWrite( $SafeSyncRegistry, "Publisher", "REG_SZ", $Publisher)
				RegWrite( $SafeSyncRegistry, "UninstallString", "REG_SZ", GUICtrlRead($InstallDir) & "\SafeSync.exe /UNINSTALL")
				$SafeSyncDataFolder = RegRead( $SafeSyncRegistry, "DataFolder")
				$SafeSyncDataCryptFolder = RegRead( $SafeSyncRegistry, "DataCryptFolder")
				RegisterFileExtension(GUICtrlRead($InstallDir),GUICtrlRead($DataDir))
				FileCopy( @TempDir & "/InstallSafeSync.exe", GUICtrlRead($InstallDir) & "/")
				;Start SafeCrypt
				Run( $InstallLocationSafeCrypt & "/SafeCrypt.exe")
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
	$InstallLocationSafeCrypt = RegRead( "HKEY_CURRENT_USER64\Software\SafeCrypt", "InstallDir")
	; Read SafeCrypt Location from Registry
	$InstallLocationSafeSync = RegRead( "HKEY_CURRENT_USER64\Software\SafeSync", "InstallDir")
	; Temp Dir for BitTorrent_SyncX64.exe
    ; Delete the previous GUI and all controls.
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
		RunWait( RegRead( $BTSyncUninstallRegKey, "UninstallString"))
		Run( @ComSpec & ' /c ' & @TempDir & "\UninstallSafeSync.exe ", @TempDir , @SW_HIDE )
	EndIf
	Exit
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

EndFunc

#cs ----------------------------------------------------------------------------
ReloadListView
Reloading the list view from the registry, to see the entries in the GUI
#ce ----------------------------------------------------------------------------
Func ReloadListView()
	_GUICtrlListView_DeleteAllItems ( $idListview )
   Local $FolderCounter = 0
   For $i = 1 To 1000
	  $sVar = RegEnumVal($SafeSyncRegKey, $i)
	  $FolderCounter = $i
	  If @error <> 0 Then ExitLoop
	  $sVar1 = RegRead($SafeSyncRegKey, $sVar)
	  Local $idItem1 = GUICtrlCreateListViewItem("" & $sVar & "| " & $sVar1 & " | " & RegRead( $SafeCryptFoldersRegistry & "\" & $sVar, "Encrypt") & " | " & RegRead( $SafeCryptFoldersRegistry & "\" & $sVar, "Decrypt") & " ", $idListview)
   Next
   Global $SyncFolders[$FolderCounter][2]
   For $i = 1 To $FolderCounter + 1
	  $sVar = RegEnumVal($SafeSyncRegKey, $i)
	  If @error <> 0 Then ExitLoop
	  $sVar1 = RegRead($SafeSyncRegKey, $sVar)
	  $SyncFolders[$i][0] = RegRead( $SafeCryptFoldersRegistry & "\" & $sVar, "Encrypt")
	  $SyncFolders[$i][1] = $sVar1
   Next
   createConfig($SyncFolders, $ConfigLocationBTSync)
   RestartBTSync()
EndFunc

#cs ----------------------------------------------------------------------------
RegistryCreateNewFolder
Function to create a New Folder
#ce ----------------------------------------------------------------------------
Func RegistryCreateNewFolder($NewFolderKeyDataEncrypt, $NewFolderKeyDataDecrypt, $NewFolderName, $NewFolderKey)
	RegWrite($SafeSyncRegKey, $NewFolderName, "REG_SZ", $NewFolderKey)
	DirCreate ($NewFolderKeyDataDecrypt)
	DirCreate ($NewFolderKeyDataEncrypt)
	; SafeCrypt Add folder
	RunWait( @ComSpec & ' /c ""' & $InstallLocationSafeCrypt & '\SafeCrypt.exe" AddFolder ""' & $NewFolderName & '"" ""' & $NewFolderKeyDataDecrypt & '"" ""' & $NewFolderKeyDataEncrypt & '"" ""' )
	;RestartBTSync()
EndFunc

#cs ----------------------------------------------------------------------------
RegistryDeleteFolder
Function to delete a New Folder
#ce ----------------------------------------------------------------------------
Func RegistryDeleteFolder($FolderName)
	RegDelete($SafeSyncRegKey,$FolderName)
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
	ConsoleWrite('"C:\Users\Tim\Program Files\BitTorrent Sync\BTSync.exe" /config "' & $BTSyncConfigCreate & '"' & @CRLF)
	Run('"C:\Users\Tim\Program Files\BitTorrent Sync\BTSync.exe" /config "' & $BTSyncConfigCreate & '"')
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
	ControlListView(@ProgramFilesDir & "\AutoIt3", "", $idListview, "SelectAll")
	$iSelect = ControlListView("SafeSyncManagementTool", "", $idListview, "GetSelected")
	$sSelect = ControlListView("SafeSyncManagementTool", "", $idListview, "GetText", $iSelect)
	MsgBox($MB_SYSTEMMODAL, "", $sSelect)
	MsgBox(0, "TODO", "Open real Bittorent?")
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
   _FileCreate($BTSyncConfigCreate)
   Local $hFileOpen = FileOpen($BTSyncConfigCreate,1)
   If $hFileOpen = -1 Then
	   MsgBox("Test", "", "An error occurred when reading the file.")
   EndIf
   ; Write data to the file using the handle returned by FileOpen.
   FileWrite($hFileOpen, '{' & @CRLF)
   FileWrite($hFileOpen, '     "storage_path" : "'&$storage_Path&'",'&@CRLF)
   FileWrite($hFileOpen, '     "check_for_updates" : false,'& @CRLF)
   FileWrite($hFileOpen, '     "use_gui" : false,'& @CRLF)
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
CreateCryptSyncPair
Create with CryptSync a Folder Pair, not neede anymore, when using of SafeCrypt
TODO:
Check if this needed
#ce ----------------------------------------------------------------------------
Func CreateCryptSyncPair($SyncFolder, $CryptFolder, $Password)
	ProcessClose("CryptSync.exe")
	sleep(100)
	Run( "C:\Program Files\CryptSync\CryptSync.exe")
	WinActivate ( "CryptSync", "Folder Pairs" )
	WinWaitActive( "CryptSync", "Folder Pairs")
	ControlClick( "CryptSync", "New Pair", 1009)
	Send($SyncFolder)
	ControlClick( "Sync Pair", "", 1012)
	Send($CryptFolder)
	ControlClick( "Sync Pair", "", 1015)
	Send($Password)
	ControlClick( "Sync Pair", "", 1017)
	Send($Password)
	ControlClick( "Sync Pair", "", 1028)
	ControlClick( "Sync Pair", "", 1033)
	Send(".sync")
	ControlClick( "Sync Pair", "OK", 1)
	ControlClick( "CryptSync", "Run in", 1)
EndFunc

#cs ----------------------------------------------------------------------------
GetCountCryptFolder
Get the Count of the Crypted folder, maybe not needed anymore.
TODO:
Check if this is needed
#ce ----------------------------------------------------------------------------
Func GetCountCryptFolder($RegName)
	$Counter = 0
	While true
		$ReadRegCryptSync = RegRead( "HKEY_CURRENT_USER\Software\CryptSync", "SyncPairOrig" & $Counter)
		if $ReadRegCryptSync == $RegName Then
			return $Counter
		EndIf
		If $ReadRegCryptSync == "" Then
			ExitLoop
		EndIf
		$Counter = $Counter + 1
	WEnd
	return ($Counter - 1)
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
	RunWait( @ComSpec & ' /c ' & @TempDir & '\InstallSafeSync.exe "' & $InstallPath & '" "' & @ScriptFullPath & '"', @TempDir , @SW_HIDE )
	RunWait( @ComSpec & ' /c ' & @TempDir & '\InstallSafeSync.exe "' & $DataDir & '"', @TempDir , @SW_HIDE )
	ConsoleWrite( "Run File-Extension support" & @CRLF)
	ConsoleWrite( "Run: " & @TempDir & "\RegisterSSF.exe" &@CRLF)
	RunWait( @ComSpec & ' /c ' & @TempDir & "\RegisterSSF.exe", @TempDir , @SW_HIDE )
EndFunc


Func CheckAdmin()
	If Not IsAdmin() Then
		ConsoleWrite($RunSafeSyncAsAdmin)
		Run(@ComSpec & ' /c ' & $RunSafeSyncAsAdmin, @TempDir , @SW_HIDE)
		Exit
	EndIf
EndFunc