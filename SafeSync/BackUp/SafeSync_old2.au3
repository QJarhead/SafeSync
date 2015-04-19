#cs SafeSync - Information
	AutoIt Version: 	3.3.12.0
	Author:				Tim Christoph Lid
	Version:			0.1
	Name:				SafeSync Management Tool

	TODO:
	1. Write documentation
	2. If NewFolderGUI closed, not exit everthings, just open manangementtool!
	Rename Variables
	Commentation
	Output log file, with function for output file, and console output
	Correct Version number
	Write registry for ssf-support in the msi

	Maybe:
	Check Folder Exists
	KEY ist correct?
	Check if BTSync is running
	Stop btsync with api
	more btsync option
	safecrypt options
	count Foldername

	Issues:
	Actually store the gui for new folder (delete gui?)

#ce
; DisplayName for installation
Global Const $SafeSyncDisplayName = "SafeSync"
; DisplayVersion for installation
Global Const $SafeSyncDisplayVersion = "0.1"
; DisplayVersion for installation
Global Const $SafeSyncPublisher = "SafeSync - Team"

#cs Include
	Including
#ce ----------------------------------------------------------------------------
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
#include <Crypt.au3>
#include <ComboConstants.au3>
#include <StringConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
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
Global $7zLocation = @AppDataDir & "\SafeCrypt\7z.exe"
Global $SafeCryptFolder = "D:\SafeCrypt\"
Global $DataFolderDecrypt = $SafeCryptFolder & "Decrypt\"
Global $DataFolderEncrypt = $SafeCryptFolder & "Encrypt\"
Global $LogListFolderDecrypt = $SafeCryptFolder & "FolderDecrypt.txt"
Global $LogListFolderEncrypt = $SafeCryptFolder & "FolderEncrypt.txt"
Global $LogListFileDecrypt = $SafeCryptFolder & "FilesDecrypt.txt"
Global $LogListFileEncrypt = $SafeCryptFolder & "FilesEncrypt.txt"
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
; ConfigFile for BitTorrentSync
Global Const $BTSyncConfig = "C://Users/Tim/Program Files/BitTorrent Sync/config.json"
; BittorentSync storage path
Global Const $BTSyncStoragePath = "C:/Users/Tim/Program Files/BitTorrent Sync/StoragePath"
; Temp Dir for BitTorrent_SyncX64.exe
Global Const $BTSyncInstaller = @TempDir & "\BitTorrent_SyncX64.exe"

#cs Static-Variables 7zip
#ce

; Bittorent Sync Uninstall String
Global Const $7ZipRegistrySoftware = "HKEY_CURRENT_USER64\Software\7-Zip"
; 7zip EXE Location
Global Const $7zipInstaller = @TempDir & "\7z938-x64.msi"

#cs Static-Variables
#ce

; For running _PathSplit()
Global $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""

ReadRegistry()
CheckCommandLine()
CheckSafeSyncUpdate()
CheckInstalledSoftware()
Global $Password = PasswordCheck()
CheckForSafeCrypt()
RunSafeSyncManagementToolGUI()

#cs ReadRegistry - Documentation
Name:               ReadRegistry
Version:			0.1
Description:        Read actual registry entries for SafeSync
Author:             Tim Lid
Last edit:			2015.04.16 - 22:46 - Move function
TODO:				Commentation; Log
#ce
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
EndFunc

#cs CheckCommandLine - Documentation
Name:               CheckCommandLine
Version:			0.1
Description:        Read command line parameters
Author:             Tim Lid
Last edit:			2015.04.16 - 22:43 - Create Function
TODO:				Commentation; Log
#ce
Func CheckCommandLine()
	If Not $CmdLine[0] = 0 Then
		If $CmdLine[1] == "SafeCrypt" Then
			If $CmdLine[2] == "Start" Then
				Global $Password = $CmdLine[3]
				TraySetState(2)
				RunSafeCrypt()
			EndIf
		EndIf
		If $CmdLine[1] == "ImportFile" Then
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
	EndIf
EndFunc

Func CheckForSafeCrypt()
	ConsoleWrite(@ComSpec & ' /c "' & @ScriptFullPath & ' ' & 'SafeCrypt Start ' & $Password & '"')
	Run(@ComSpec & ' /c "' & @ScriptFullPath & ' ' & 'SafeCrypt Start ' & $Password & '"', @TempDir, @SW_HIDE)
EndFunc

#cs CheckInstalledSoftware - Documentation
Name:               CheckInstalledSoftware
Version:			0.1
Description:        Check for all software that are required, to run SafeSync
Author:             Tim Lid
Last edit:			2015.04.16 - 22:43 - Create Function
TODO:				Commentation; Log
#ce
Func CheckInstalledSoftware()
	If RegRead($BTSyncRegistryUninstall, "DisplayIcon") == "" Then
		RunWait('"' & $BTSyncInstaller & '" /PERFORMINSTALL /AUTOMATION')
	EndIf
EndFunc

#cs RunSafeSyncManagementToolGUI - Documentation
Name:               RunSafeSyncManagementToolGUI
Version:			0.1
Description:        Running the SafeSyncManagementToolGUI
Author:             Tim Lid
Last edit:			2015.04.16 - 22:28 - renaming variables
TODO:				Commentation; Log
#ce
Func RunSafeSyncManagementToolGUI()
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

	; Create ListView
	Global $idListview = GUICtrlCreateListView("Name|Key|EncryptLocation|Location", 10, 10, 895, 395) ;,$LVS_SORTDESCENDING)

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

	Global $Gui_SafeSync_Encrypt_Folder = GUICreate("Use Encryption?", 165, 160, 200, 124)
	$Radio5 = GUICtrlCreateRadio("With encryption", 32, 20, 113, 25)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$Radio4 = GUICtrlCreateRadio("Don't use encryption", 32, 60, 113, 17)
	$Button2 = GUICtrlCreateButton("Button1", 32, 100, 91, 33)
	GUISwitch($SafeSyncManagementTool)
	Opt('TrayOnEventMode', 1)
	Opt('TrayMenuMode', 1)
	TraySetOnEvent(-7, 'RestoreFromTray')
	TraySetState(2)
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
								$PasswordCrypt = EncryptPassword(GUICtrlRead($PasswordInput1), $PasswordCreateSalt)
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
EndFunc

#cs CheckSafeSyncUpdate - Documentation
Name:               CheckSafeSyncUpdate
Version:			0.1
Description:        Check for update and popup a tray tip
Author:             Tim Lid
Return values:      Success:			- The GUI will be display in the Front and there's no longer a trayicon
                    Failure:			- TODO
Last edit:			2015.04.17 - 15:58 - create function
TODO:				Commentation; Log
#ce
Func CheckSafeSyncUpdate()
	; Download the file in the background with the selected option of 'force a reload from the remote site.'
	Local $GNK_Download = InetGet("http://safesync.no-ip.org/download/SafeSync//Info.txt", @TempDir & "\SafeSyncUpdateInfo.temp", $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

	; Wait for the download to complete by monitoring when the 2nd index value of InetGetInfo returns True.
	Do
		Sleep(100)
	Until InetGetInfo($GNK_Download, $INET_DOWNLOADCOMPLETE)
	Local $GNK_ReadFile = FileReadLine(@TempDir & "\SafeSyncUpdateInfo.temp", 1)
	If _StringCompareVersions($GNK_ReadFile, $SafeSyncDisplayVersion) > 0 Then
		TrayTip ( "Update", "There a new version of SafeSync: " & $GNK_ReadFile, 4)
	Else
		TrayTip ( "No Update", "Thers no new update for version: " & $GNK_ReadFile, 4)
	EndIf
EndFunc

#cs RestoreFromTray - Documentation
Name:               RestoreFromTray
Version:			0.1
Description:        Restore the GUI from the iconmenu
Author:             Tim Lid
Return values:      Success:			- The GUI will be display in the Front and there's no longer a trayicon
                    Failure:			- TODO
Last edit:			2015.04.16 - 22:23 - renaming function
TODO:				Commentation; Log
#ce
Func RestoreFromTray()
	TraySetState(2)
	GUISetState(@SW_SHOW, $SafeSyncManagementTool)
	WinActivate("SafeSyncManagementTool")
EndFunc

;===============================================================================
;
; FunctionName:  _StringCompareVersions()
; Description:    Compare 2 strings of the FileGetVersion format [a.b.c.d].
; Syntax:          _StringCompareVersions( $s_Version1, [$s_Version2] )
; Parameter(s):  $s_Version1          - The string being compared
;                  $s_Version2        - The string to compare against
;                                         [Optional] : Default = 0.0.0.0
; Requirement(s):   None
; Return Value(s):  0 - Strings are the same (if @error=0)
;                 -1 - First string is (<) older than second string
;                  1 - First string is (>) newer than second string
;                  0 and @error<>0 - String(s) are of incorrect format:
;                        @error 1 = 1st string; 2 = 2nd string; 3 = both strings.
; Author(s):        PeteW
; Note(s):        Comparison checks that both strings contain numeric (decimal) data.
;                  Supplied strings are contracted or expanded (with 0s)
;                    MostSignificant_Major.MostSignificant_minor.LeastSignificant_major.LeastSignificant_Minor
;
;===============================================================================

Func _StringCompareVersions($s_Version1, $s_Version2 = "0.0.0.0")

; Confirm strings are of correct basic format. Set @error to 1,2 or 3 if not.
    SetError((StringIsDigit(StringReplace($s_Version1, ".", ""))=0) + 2 * (StringIsDigit(StringReplace($s_Version2, ".", ""))=0))
    If @error>0 Then Return 0; Ought to Return something!

    Local $i_Index, $i_Result, $ai_Version1, $ai_Version2

; Split into arrays by the "." separator
    $ai_Version1 = StringSplit($s_Version1, ".")
    $ai_Version2 = StringSplit($s_Version2, ".")
    $i_Result = 0; Assume strings are equal

; Ensure strings are of the same (correct) format:
;  Short strings are padded with 0s. Extraneous components of long strings are ignored. Values are Int.
    If $ai_Version1[0] <> 4 Then ReDim $ai_Version1[5]
    For $i_Index = 1 To 4
        $ai_Version1[$i_Index] = Int($ai_Version1[$i_Index])
    Next

    If $ai_Version2[0] <> 4 Then ReDim $ai_Version2[5]
    For $i_Index = 1 To 4
        $ai_Version2[$i_Index] = Int($ai_Version2[$i_Index])
    Next

    For $i_Index = 1 To 4
        If $ai_Version1[$i_Index] < $ai_Version2[$i_Index] Then; Version1 older than Version2
            $i_Result = -1
        ElseIf $ai_Version1[$i_Index] > $ai_Version2[$i_Index] Then; Version1 newer than Version2
            $i_Result = 1
        EndIf
   ; Bail-out if they're not equal
        If $i_Result <> 0 Then ExitLoop
    Next

    Return $i_Result

EndFunc ;==>_StringCompareVersions

#cs SyncNewFolder - Documentation
Name:               SyncNewFolder
Version:			0.1
Description:        Create new Folder by clicking Sync with SafeSync from Context menu
Author:             Tim Lid
Parameters:			$SNF_NewFolderName					- String: New folder name
					$SNF_GUI_SyncNewFolderDialog		- Dialog: Dialog for choosing options
					$SNF_GUI_RADIO_GenerateNewKey		- RADIO: Choosing if a Key will be generated
					$SNF_GUI_RADIO_ManualKey			- RADIO: Choosing if a Key will be manually inputed
					$SNF_GUI_BUTTON_Ok					- BUTTON: For OK
					$SNF_NewFolderKey					- String: New folder key
					$SNF_DecryptEncryptFolder			- Array[String]: Path to the encrypt and decrypt folder
					$SNF_GUI_SyncNewFolderDialog_Msg	- String: GUI Messages
					$SNF_NewFolderDataDecrypt			- String: Path of the decrypt folder
					$SNF_NewFolderDataEncrypt			- String: Path of the encrypt folder
Return values:      Success:			- String: The decrypted password
                    Failure:			- TODO
Last edit:			2015.04.16 - 19:55 - renaming variables
TODO:				Commentation; Testing; new GUI!
#ce
Func SyncNewFolder($SNF_NewFolderName)
	Global $SNF_GUI_SyncNewFolderDialog = GUICreate("Sync new folder", 165, 160, 200, 124)
	$SNF_GUI_RADIO_GenerateNewKey = GUICtrlCreateRadio("Generate new Key", 32, 20, 113, 25)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$SNF_GUI_RADIO_ManualKey = GUICtrlCreateRadio("Manual", 32, 60, 113, 17)
	$SNF_GUI_BUTTON_Ok = GUICtrlCreateButton("OK", 32, 100, 91, 33)

	GUISetState(@SW_SHOW)

	ConsoleWrite("SyncNewFolder: " & $SNF_NewFolderName)

	$SNF_SplitPath = _PathSplit($SNF_NewFolderName, $sDrive, $sDir, $sFilename, $sExtension)

	Local $SNF_NewFolderKey
	Local $SNF_DecryptEncryptFolder
	Local $SNF_NewFolderDataDecrypt
	Local $SNF_NewFolderDataEncrypt

	While 1
		$SNF_GUI_SyncNewFolderDialog_Msg = GUIGetMsg(1)
		Switch $SNF_GUI_SyncNewFolderDialog_Msg[0] ; check which GUI sent the message
			Case $GUI_EVENT_CLOSE
				Switch $SNF_GUI_SyncNewFolderDialog_Msg[1]
					Case $SNF_GUI_SyncNewFolderDialog
						ExitLoop
				EndSwitch
			Case $SNF_GUI_BUTTON_Ok
				Select
					Case BitAND(GUICtrlRead($SNF_GUI_RADIO_GenerateNewKey), $GUI_CHECKED) = $GUI_CHECKED
						$SNF_NewFolderKey = getNewKey()
						MsgBox(0, "Data", "Please Choose the Data Folder, with the Encrypted File")
						$SNF_DecryptEncryptFolder = ChooseDecryptEncryptFolder("", $SNF_NewFolderName)
						$SNF_NewFolderDataDecrypt = $SNF_DecryptEncryptFolder[0]
						$SNF_NewFolderDataEncrypt = $SNF_DecryptEncryptFolder[1]
						RegistryCreateNewFolder($SNF_NewFolderDataDecrypt, $SNF_NewFolderDataEncrypt, $SNF_SplitPath[3], $SNF_NewFolderKey, 0, "", "")
						Exit
					Case BitAND(GUICtrlRead($SNF_GUI_RADIO_ManualKey), $GUI_CHECKED) = $GUI_CHECKED
						Local $NewFolderKey = InputBox("Folder Name", "Enter folder key", "", "")
						$SNF_DecryptEncryptFolder = ChooseDecryptEncryptFolder("", $SNF_NewFolderName)
						$SNF_NewFolderDataDecrypt = $SNF_DecryptEncryptFolder[0]
						$SNF_NewFolderDataEncrypt = $SNF_DecryptEncryptFolder[1]
						RegistryCreateNewFolder($SNF_NewFolderDataDecrypt, $SNF_NewFolderDataEncrypt, $SNF_SplitPath[3], $NewFolderKey, 0, "", "")
						Exit
				EndSelect
		EndSwitch
	WEnd
	ReloadListView()
EndFunc

#cs ReloadListView - Documentation
Name:               ReloadListView
Version:			0.1
Description:        Function reloads the list view from the registry, to see the entries in the GUI
Author:             Tim Lid
Parameters:			$RLV_FolderCounter				- Integer: Counter for folders
					$RLV_Counter					- Integer: Counter
					$RLV_RegistryValueEntry			- String: Registry folder entry
					$RLV_RegistryValue				- String: Registry folder entry
					$RLV_Item1						- ListViewItem: Current List view Item
Return values:      Success:			- The new Listview in the GUI
                    Failure:			- TODO
Last edit:			2015.04.16 - 19:19 - renaming variables
TODO:				Commentation
#ce
Func ReloadListView()
	RegWrite($SafeSyncRegistrySoftwareManagementTool, "refreshGUI", "REG_SZ", 0)
	Local $RLV_RegistryValueEntry
	_GUICtrlListView_DeleteAllItems($idListview)
	Local $RLV_FolderCounter = 0
	For $RLV_Counter = 1 To 1000
		$RLV_RegistryValue = RegEnumVal($SafeSyncRegistryFolders, $RLV_Counter)
		$RLV_FolderCounter = $RLV_Counter
		If @error <> 0 Then ExitLoop
		$RLV_RegistryValueEntry = RegRead($SafeSyncRegistryFolders, $RLV_RegistryValue)
		Local $RLV_Item1 = GUICtrlCreateListViewItem("" & $RLV_RegistryValue & "| " & $RLV_RegistryValueEntry & " | " & RegRead($SafeSyncRegistryFolders & "\" & $RLV_RegistryValue, "Encrypt") & " | " & RegRead($SafeSyncRegistryFolders & "\" & $RLV_RegistryValue, "Decrypt") & " ", $idListview)
	Next
	Global $SyncFolders[$RLV_FolderCounter][2]
	For $RLV_Counter = 1 To $RLV_FolderCounter + 1
		$RLV_RegistryValue = RegEnumVal($SafeSyncRegistryFolders, $RLV_Counter)
		If @error <> 0 Then ExitLoop
		$RLV_RegistryValueEntry = RegRead($SafeSyncRegistryFolders, $RLV_RegistryValue)
		If RegRead($SafeSyncRegistryFolders & "\" & $RLV_RegistryValue, "UseEncryption") = 1 Then
			$SyncFolders[$RLV_Counter][0] = RegRead($SafeSyncRegistryFolders & "\" & $RLV_RegistryValue, "Encrypt")
		Else
			$SyncFolders[$RLV_Counter][0] = RegRead($SafeSyncRegistryFolders & "\" & $RLV_RegistryValue, "Decrypt")
		EndIf
		$SyncFolders[$RLV_Counter][1] = $RLV_RegistryValueEntry
	Next
	createConfig($SyncFolders, $BTSyncStoragePath)
	RestartBTSync()
EndFunc

#cs RegistryCreateNewFolder - Documentation
Name:               RegistryCreateNewFolder
Version:			0.1
Description:        Function register a new folder in the registry
Author:             Tim Lid
Parameters:			$RCNF_NewFolderDataEncrypt		- String: Path to new Encrypt Folder
					$RCNF_NewFolderDataDecrypt		- String: Path to new Decrypt Folder
					$RCNF_NewFolderName				- String: new folder name
					$RCNF_NewFolderKey				- String: new folder key
					$RCNF_CreateFolderEncryption	- Boolean: Use encryption or not
					$RCNF_CreateFolderPassword		- String: The password
					$RCNF_PasswordSalt				- String: The password salt
Return values:      Success:			- String: The decrypted password
                    Failure:			- TODO
Last edit:			2015.04.16 - 19:19 - renaming variables
TODO:				Commentation
#ce
Func RegistryCreateNewFolder($RCNF_NewFolderDataEncrypt, $RCNF_NewFolderDataDecrypt, $RCNF_NewFolderName, $RCNF_NewFolderKey, $RCNF_CreateFolderEncryption, $RCNF_CreateFolderPassword, $RCNF_PasswordSalt)
	RegWrite($SafeSyncRegistryFolders, $RCNF_NewFolderName, "REG_SZ", $RCNF_NewFolderKey)
	DirCreate($RCNF_NewFolderDataDecrypt)
	DirCreate($RCNF_NewFolderDataEncrypt)
	RegWrite($SafeSyncRegistryFolders)
	RegWrite($SafeSyncRegistryFolders & "\" & $RCNF_NewFolderName)
	RegWrite($SafeSyncRegistryFolders & "\" & $RCNF_NewFolderName, "Encrypt", "REG_SZ", $RCNF_NewFolderDataEncrypt)
	RegWrite($SafeSyncRegistryFolders & "\" & $RCNF_NewFolderName, "UseEncryption", "REG_SZ", $RCNF_CreateFolderEncryption)
	RegWrite($SafeSyncRegistryFolders & "\" & $RCNF_NewFolderName, "Decrypt", "REG_SZ", $RCNF_NewFolderDataDecrypt)
	RegWrite($SafeSyncRegistryFolders & "\" & $RCNF_NewFolderName, "PasswordSalt", "REG_SZ", $RCNF_PasswordSalt)
	RegWrite($SafeSyncRegistryFolders & "\" & $RCNF_NewFolderName, "Password", "REG_SZ", $RCNF_CreateFolderPassword)
EndFunc

#cs EncryptPassword - Documentation
Name:               EncryptPassword
Version:			0.1
Description:        Function decrypt a Password
Author:             Tim Lid
Parameters:			$DP_CryptPassword	- String: The crypted password
					$PD_PasswordSalt	- String: The password salt
Return values:      Success:			- String: The decrypted password
                    Failure:			- TODO
Last edit:			2015.04.16 - 17:02 - renaming variables
TODO:				Commentation
#ce
Func EncryptPassword($EP_CryptPassword, $EP_PasswordSalt)
	Local $EP_Password = _Crypt_EncryptData($EP_CryptPassword & $EP_PasswordSalt, $Password, $CALG_RC4)
	Return $EP_Password
EndFunc   ;==>CryptPassword

#cs DecryptPassword - Documentation
Name:               DecryptPassword
Version:			0.1
Description:        Function decrypt a Password
Author:             Tim Lid
Parameters:			$DP_CryptPassword	- String: The crypted password
					$PD_PasswordSalt	- String: The password salt
Return values:      Success:			- String: The decrypted password
                    Failure:			- TODO
Last edit:			2015.04.16 - 17:02 - renaming variables
TODO:				Commentation
#ce
Func DecryptPassword($DP_Password, $PD_PasswordSalt)
	Local $DP_PasswordWithSalt = BinaryToString(_Crypt_DecryptData($DP_Password, $Password, $CALG_RC4))
	Return StringLeft(BinaryToString($DP_PasswordWithSalt), StringLen($DP_PasswordWithSalt) - StringLen($PD_PasswordSalt))
EndFunc

#cs RegistryDeleteFolder - Documentation
Name:               RegistryDeleteFolder
Version:			0.1
Description:        Function delete a Folder from the Registry
Author:             Tim Lid
Parameters:			$RDF_FolderName		- String: Foldername
Return values:      Success:			- Delete the folder
                    Failure:			- TODO
Last edit:			2015.04.16 - 17:00 - renaming variables
TODO:				Commentation
#ce
Func RegistryDeleteFolder($RDF_FolderName)
	RegDelete($SafeSyncRegistryFolders, $RDF_FolderName)
	RegDelete($SafeSyncRegistryFolders & "\" & $RDF_FolderName)
	ReloadListView()
	RestartBTSync()
EndFunc

#cs StopBTSync - Documentation
Name:               StopBTSync
Version:			0.1
Description:        Function stop the BTSync programm
Author:             Tim Lid
Return values:      Success:			- Delete the folder
                    Failure:			- TODO
Last edit:			2015.04.16 - 16:59 - renaming variables
TODO:				Commentation
#ce
Func StopBTSync()
	;Stopping both processes, for better compatibility
	StopProcess("BitTorrent_SyncX64.exe")
	StopProcess("BTSync.exe")
EndFunc   ;==>StopBTSync

#cs StartBTSync - Documentation
Name:               StartBTSync
Version:			0.1
Description:        Function start the BTSync programm
Author:             Tim Lid
Return values:      Success:			- Delete the folder
                    Failure:			- TODO
Last edit:			2015.04.16 - 16:58 - renaming variables
TODO:				Commentation
#ce
Func StartBTSync()
	ConsoleWrite('"C:\Users\Tim\Program Files\BitTorrent Sync\BTSync.exe" /config "' & $BTSyncConfig & '"' & @CRLF)
	Run('"C:\Users\Tim\Program Files\BitTorrent Sync\BTSync.exe" /config "' & $BTSyncConfig & '"')
EndFunc

#cs RestartBTSync - Documentation
Name:               RestartBTSync
Version:			0.1
Description:        Function restart the BTSync programm
Author:             Tim Lid
Return values:      Success:			- Delete the folder
                    Failure:			- TODO
Last edit:			2015.04.16 - 16:57 - renaming variables
TODO:				Commentation
#ce
Func RestartBTSync()
	StopBTSync()
	Sleep(200)
	StartBTSync()
EndFunc

#cs MenuDelete - Documentation
Name:               MenuDelete
Version:			0.1
Description:        Function deletes a choosen entry from the gui
Author:             Tim Lid
Parameters:         $MD_SelectEntry			- ContorlListView: the choosen entry
					$MD_SelectEntryText		- String: the name of the folder
					$MD_MsgBoxAnswer		- Integer: Answer from the MsgBox
Return values:      Success:			- Delete the folder
                    Failure:			- TODO
Last edit:			2015.04.16 - 16:52 - renaming variables
TODO:				Commentation; expand the function
#ce
Func MenuDelete()
	$MD_SelectEntry = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected")
	$MD_SelectEntryText = ControlListView($SafeSyncManagementTool, "", $idListview, "GetText", $MD_SelectEntry)

	$MD_MsgBoxAnswer = MsgBox(33, "Delete Folder?", "Delete '" & $MD_SelectEntryText & "'?")
	Select
		Case $MD_MsgBoxAnswer = 1
			RegistryDeleteFolder($MD_SelectEntryText)
		Case $MD_MsgBoxAnswer = 2
	EndSelect
	ReloadListView()
EndFunc

#cs MenuExport - Documentation
Name:               MenuExport
Version:			0.1
Description:        Function export a choosen entry from the gui and export it to a file
Author:             Tim Lid
Return values:      Success:			- Stops SafeSync
Last edit:			2015.04.16 - 16:34 - insert the new ExitSafeSync - Function
TODO:				Commentation; Log
#ce
Func MenuExport()
	$ME_SelectEntry = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected")
	$ME_SelectEntryNumber = Number($ME_SelectEntry)
	$ME_FolderKey = _GUICtrlListView_GetItemText($idListview, $ME_SelectEntryNumber, 1)
	$ME_FolderName = _GUICtrlListView_GetItemText($idListview, $ME_SelectEntryNumber, 0)

	; Display a save dialog to select a file.
	Local $ME_SaveFile = FileSaveDialog("Chose a filename", "::{450D8FBA-AD25-11D0-98A8-0800361B1103}", "Scripts (*.ssf)", $FD_PATHMUSTEXIST, $ME_FolderName)

	FileDelete($ME_SaveFile)
	Sleep(100)
	_FileCreate($ME_SaveFile)
	Sleep(100)
	$ME_SaveFileOpen = FileOpen($ME_SaveFile, 1)
	FileWrite($ME_SaveFileOpen, $ME_FolderName & "" & $ME_FolderKey)
	FileClose($ME_SaveFileOpen)
	ReloadListView()
EndFunc

#cs MenuExit - Documentation
Name:               MenuExit
Version:			0.1
Description:        Function stops SafeSync, from the GUI File - Exit
Author:             Tim Lid
Return values:      Success:			- Stops SafeSync
Last edit:			2015.04.16 - 16:39 - insert the new ExitSafeSync - Function
TODO:				Commentation; Log
#ce
Func MenuExit()
	ExitSafeSync()
EndFunc

#cs CheckNewName - Documentation
Name:               CheckNewName
Version:			0.1
Description:        Function checks the new name for a folder
Author:             Tim Lid
Parameters:         $CNN_FolderName		- String: The new name of the folder to create
Return values:      Success:			- Integer: 1 Correct, 0 Uncorrect
                    Failure:			- TODO
Last edit:			2015.04.16 - 16:50 - renaming variables
TODO:				Commentation; expand the function
#ce
Func CheckNewName($CNN_FolderName)
	If StringCompare($CNN_FolderName, "") Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

#cs MenuBitTorrent - Documentation
Name:               SafeCrypt
Version:			0.1
Description:        Function, run gui with btsync options
Author:             Tim Lid
Parameters:         $MBT_GUI_BittorentSyncSettings		- String: The name of the sync folder
					$MBT_GUI_BUTTON_Save				- String: Path of the decrypt data folder
					$MBT_RADIO_ShowGui_True				- String: Path of the encrypt data folder
					$MBT_RADIO_ShowGui_False			- String: Path to log list of decrypt file
					$MBT_RADIO_UseRelayServer_True		- String: Path to log list of decrypt file
					$MBT_RADIO_UseRelayServer_False		- String: Path to log list of decrypt folder
Return values:      Success:				- Set the new Bittorent Sync options
                    Failure:				- TODO
Last edit:			2015.04.16 - 16:18 - renaming variables
TODO:				Commentation; Failure; Console output
#ce
Func MenuBitTorrent()
	$MBT_GUI_BittorentSyncSettings = GUICreate("Bittorent Sync - Settings", 150, 230)
	$MBT_GUI_BUTTON_Save = GUICtrlCreateButton("Save", 30, 180, 65, 35)
	GUIStartGroup()
	$MBT_RADIO_ShowGui_True = GUICtrlCreateRadio("True", 20, 30, 100, 20)
	$MBT_RADIO_ShowGui_False = GUICtrlCreateRadio("False", 20, 50, 100, 20)

	If $BTSyncShowGUI = "true" Then
		GUICtrlSetState($MBT_RADIO_ShowGui_True, $GUI_CHECKED)
	Else
		GUICtrlSetState($MBT_RADIO_ShowGui_False, $GUI_CHECKED)
	EndIf
	GUIStartGroup()
	$MBT_RADIO_UseRelayServer_True = GUICtrlCreateRadio("True", 20, 110, 100, 20)
	$MBT_RADIO_UseRelayServer_False = GUICtrlCreateRadio("False", 20, 130, 100, 20)
	GUIStartGroup()
	$MBT_RADIO_ShowGui = GUICtrlCreateGroup("Show GUI?", 10, 10, 120, 70)
	$MBT_RADIO_UseRelayServer = GUICtrlCreateGroup("UseRelayServer?", 10, 90, 120, 70)

	GUISetState(@SW_HIDE, $SafeSyncManagementTool)
	GUISetState(@SW_SHOW, $MBT_GUI_BittorentSyncSettings)
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				GUIDelete($MBT_GUI_BittorentSyncSettings)
			Case $MBT_GUI_BUTTON_Save
				If BitAND(GUICtrlRead($MBT_RADIO_ShowGui_True), $GUI_CHECKED) = $GUI_CHECKED Then
					RegWrite($SafeSyncRegistrySoftwareManagementTool, "ShowGUI", "REG_SZ", "true")
					$BTSyncShowGUI = "true"
				Else
					RegWrite($SafeSyncRegistrySoftwareManagementTool, "ShowGUI", "REG_SZ", "false")
					$BTSyncShowGUI = "false"
				EndIf
				ReloadListView()
				GUISetState(@SW_SHOW, $SafeSyncManagementTool)
				GUIDelete($MBT_GUI_BittorentSyncSettings)
				ExitLoop
		EndSwitch
	WEnd
EndFunc

#cs MenuCrypt - Documentation
Name:               MenuCrypt
Version:			0.1
Description:        SafeCrypt settings
Author:             Tim Lid
Return values:      Success:	- TODO
					Failure:	- TODO
Last edit:			2015.04.16 - 15:30 - Documentation (TL)
TODO:				Create windows for options
#ce
Func MenuCrypt()
	MsgBox(0, "TODO", "Open real CryptSync?")
EndFunc   ;==>MenuCrypt

#cs MenuOther - Documentation
Name:               MenuOther
Version:			0.1
Description:        Other settings
Author:             Tim Lid
Return values:      Success:	- TODO
					Failure:	- TODO
Last edit:			2015.04.16 - 15:30 - Documentation (TL)
TODO:				Create windows for options
#ce
Func MenuOther()
	MsgBox(0, "TODO", "General settings")
EndFunc

#cs MenuAbout - Documentation
Name:               MenuAbout
Version:			0.1
Description:        Function to output information
Author:             Tim Lid
Return values:      Success:	- Output information
Last edit:			2015.04.16 - 15:26 - Documentation (TL)
TODO:				Print variables
#ce
Func MenuAbout()
	; Output "About SafeSync" - Information
	MsgBox(0, "About SafeSync", "SafeSync" & @LF & "Version 0.0.1.2" & @LF & "  16.04.2015" & @LF & "by SafeSync-Team")
EndFunc

#cs ExitSafeSync - Documentation
Name:               ExitSafeSync
Version:			0.1
Description:        Function to stop SafeSync and subprograms
Author:             Tim Lid
Return values:      Success:	- Stops SafeSync and subprograms
                    Failure:	- TODO
Last edit:			2015.04.16 - 15:24 - Documentation (TL)
TODO:				Commentation; Failure; Console output
#ce
Func ExitSafeSync()
	StopBTSync()
	StopSafeCrypt()
	Exit
EndFunc

#cs StopSafeCrypt - Documentation
Name:               StopSafeCrypt
Version:			0.1
Description:        Function to stop SafeCrypt
Author:             Tim Lid
Return values:      Success:	- Stops SafeCrypt
                    Failure:	- TODO
Last edit:			2015.04.16 - 15:23 - Create the function (TL)
TODO:				Commentation; Failure; Console output
#ce
Func StopSafeCrypt()
	RegWrite($SafeSyncRegistrySoftwareManagementTool, "RunSafeCrypt", "REG_SZ", "0")
EndFunc

#cs createConfig - Documentation
Name:               createConfig
Version:			0.1
Description:        Function create the config File, from the entries on the registry
Author:             Tim Lid
Parameters:         $CC_SyncFolders			- String: The name of the sync folder
					$CC_StoragePath			- String: Path to the BTSync storage path
					$CC_BTSyncConfigOpen	- OpenFile: The file to write the config
					$CC_Element				- Counter the rounds in the for-loop
					$CC_Counter				- Count the number of folders
Return values:      Success:				- Write the config file for BTSync
                    Failure:				- TODO
Last edit:			2015.04.16 - 14:52 - renaming variables/Documentation (TL)
TODO:				Commentation; Failure; Console output
#ce
Func createConfig($CC_SyncFolders, $CC_StoragePath)
	DirCreate($CC_StoragePath)
	_FileCreate($BTSyncConfig)
	Local $CC_BTSyncConfigOpen = FileOpen($BTSyncConfig, 1)
	If $CC_BTSyncConfigOpen = -1 Then
		MsgBox("Test", "", "An error occurred when reading the file.")
	EndIf
	; Write data to the file using the handle returned by FileOpen.
	FileWrite($CC_BTSyncConfigOpen, '{' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     "storage_path" : "' & $CC_StoragePath & '",' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     "check_for_updates" : false,' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     "use_gui" : ' & $BTSyncShowGUI & ',' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     "webui" :' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     {' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '          "listen" : "127.0.0.1:7878",' & @CRLF)
	;FileWrite($hFileOpen, '          "login" : "login",'& @CRLF)
	;FileWrite($hFileOpen, '          "password" : "passwd",'& @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '          "api_key" : "UPK4TNW735M6D4UERSZ7EW6A2VRRPMA5JJKFJ6JTYSPTNGTN4JGCLBUOJ46I6ZDXHRLT3PHGQD76I4SGVJWLNII7TPNFNMBOJ4J3KBAPDMVBKCXLNNSCJUMDLQTRW4BMQ6OZHPA"' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     }' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     ,' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     "shared_folders" :' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '     [' & @CRLF)
	Local $CC_Counter = UBound($CC_SyncFolders, $UBOUND_ROWS) - 1
	For $CC_Element = 1 To $CC_Counter
		If $CC_Element <= $CC_Counter And $CC_Element >= 2 Then
			FileWrite($CC_BTSyncConfigOpen, '     ,' & @CRLF)
		EndIf
		FileWrite($CC_BTSyncConfigOpen, '     {' & @CRLF)
		FileWrite($CC_BTSyncConfigOpen, '     "secret" : "' & $CC_SyncFolders[$CC_Element][1] & '",' & @CRLF)
		FileWrite($CC_BTSyncConfigOpen, '     "dir" : "' & StringReplace($CC_SyncFolders[$CC_Element][0], "\", "/") & '",' & @CRLF)
		FileWrite($CC_BTSyncConfigOpen, '     "use_relay_server" : true,' & @CRLF)
		FileWrite($CC_BTSyncConfigOpen, '     "use_tracker" : true,' & @CRLF)
		FileWrite($CC_BTSyncConfigOpen, '     "use_dht" : false,' & @CRLF)
		FileWrite($CC_BTSyncConfigOpen, '     "search_lan" : true,' & @CRLF)
		FileWrite($CC_BTSyncConfigOpen, '     "use_sync_trash" : true' & @CRLF)
		FileWrite($CC_BTSyncConfigOpen, '     }' & @CRLF)
	Next
	FileWrite($CC_BTSyncConfigOpen, '     ]' & @CRLF)
	FileWrite($CC_BTSyncConfigOpen, '}' & @CRLF)
EndFunc

#cs getNewKey - Documentation
Name:               getNewKey
Version:			0.1
Description:        Function, get a new BitTorrent Sync Key
Author:             Tim Lid
Parameters:         $SP_ProcessName			- String: The name of the sync folder
					$SP_ProcessList			- Array[String] a List of processes with the given name
Return values:      Success:				- Stops a process
                    Failure:				- TODO
Last edit:			2015.04.16 - 14:36 - renaming variables (TL)
TODO:				Commentation; Failure; Console output
#ce
Func getNewKey()
	; Save the downloaded file to the temporary folder.
	Local $GNK_FilePath = @TempDir & "\secretKey.temp"

	; Download the file in the background with the selected option of 'force a reload from the remote site.'
	Local $GNK_Download = InetGet("http://admin:passwd@127.0.0.1:7878/api?method=get_secrets", @TempDir & "\secretKey.temp", $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

	; Wait for the download to complete by monitoring when the 2nd index value of InetGetInfo returns True.
	Do
		Sleep(100)
	Until InetGetInfo($GNK_Download, $INET_DOWNLOADCOMPLETE)

	; Close the handle returned by InetGet.
	InetClose($GNK_Download)

	Local $GNK_ReadFile = FileReadLine($GNK_FilePath, 1)

	$GNK_ReadFile = StringRegExpReplace($GNK_ReadFile, "{*:", "")

	$GNK_NewKey = StringSplit($GNK_ReadFile, '"')

	; Delete the file.
	FileDelete($GNK_FilePath)

	Return $GNK_NewKey[8]
	;Return "TestKey"
EndFunc

#cs StopProcess - Documentation
Name:               StopProcess
Version:			0.1
Description:        Function, stops a process with the given name
Author:             Tim Lid
Parameters:         $SP_ProcessName			- String: The name of the sync folder
					$SP_ProcessList			- Array[String] a List of processes with the given name
Return values:      Success:				- Stops a process
                    Failure:				- TODO
Last edit:			2015.04.16 - 14:11 - renaming variables (TL)
TODO:				Commentation; Failure; Console output
#ce
Func StopProcess($SP_ProcessName)
	Local $SP_ProcessList = ProcessList($SP_ProcessName)
	For $i = 1 To $SP_ProcessList[0][0]
		ProcessClose($SP_ProcessList[$i][1])
	Next
EndFunc

#cs ChooseDecryptEncryptFolder - Documentation
Name:               ChooseDecryptEncryptFolder
Version:			0.1
Description:        Function, GUI for choosing a new encrypt and decrypt folder
Author:             Tim Lid
Parameters:         $CDEF_FolderName								- String: The name of the sync folder
					$CDEF_FolderData								- String: Path of the decrypt data folder
					$CDEF_EmptyString								- String: Temp string, TODO: Delete this one, and test it.
					$CDEF_GUI_GUI_ChooseDecryptEncryptFolderDialog	- String: Path to log list of decrypt file
					$CDEF_GUI_BUTTON_Ok								- BUTTON: OK Button
					$CDEF_GUI_LABEL_DecryptDir						- LABEL: Label decrypt folder input
					$CDEF_GUI_INPUT_DecryptDir						- INPUT: The Input for the decrypt folder
					$CDEF_GUI_BUTTON_DecryptDir						- BUTTOM: Button for selecting the decrypt folder
					$CDEF_GUI_LABEL_EncryptDir						- LABEL: Label encrypt folder input
					$CDEF_GUI_INPUT_EncryptDir						- INPUT: The Input for the encrypt folder
					$CDEF_GUI_BUTTON_EncryptDir						- BUTTOM: Button for selecting the encrypt folder
Return values:      Success:				- Array[String]: The choosen encrypt and decrypt folder
                    Failure:				- TODO
Last edit:			2015.04.16 - 14:09 - renaming variables
TODO:				Commentation; Failure; Console output
#ce
Func ChooseDecryptEncryptFolder($CDEF_FolderName, $CDEF_FolderData)
	$CDEF_EmptyString = ""
	If StringCompare($CDEF_EmptyString, $CDEF_FolderData) = 0 Then
		$CDEF_FolderData = $SafeSyncStandardDataFolder & "\" & $CDEF_FolderName
	EndIf
	Local $CDEF_GUI_ChooseDecryptEncryptFolderDialog = GUICreate("SafeSync - Select Folder", 430, 170)
	Local $CDEF_GUI_BUTTON_Ok = GUICtrlCreateButton("OK", 320, 130, 85, 25)
	GuiCtrlSetState(-1, 512)
	Local $CDEF_GUI_LABEL_DecryptDir = GUICtrlCreateLabel("DecryptFolder:", 10, 20)
	Local $CDEF_GUI_INPUT_DecryptDir = GUICtrlCreateInput($CDEF_FolderData, 10, 38, 300)
	Local $CDEF_GUI_BUTTON_DecryptDir = GUICtrlCreateButton("SelectFolder", 320, 36, 100)
	Local $CDEF_GUI_LABEL_EncryptDir = GUICtrlCreateLabel("EncryptFolder:", 10, 70)
	Local $CDEF_GUI_INPUT_EncryptDir = GUICtrlCreateInput($CDEF_FolderData & "Encrypt", 10, 88, 300)
	Local $CDEF_GUI_BUTTON_EncryptDir = GUICtrlCreateButton("SelectFolder", 320, 86, 100)
	GUISetState(@SW_SHOW, $CDEF_GUI_ChooseDecryptEncryptFolderDialog)
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit
				ExitLoop
			Case $CDEF_GUI_BUTTON_Ok
				ExitLoop
			Case $CDEF_GUI_BUTTON_DecryptDir
				GUICtrlSetData($CDEF_GUI_INPUT_DecryptDir, FileSelectFolder("Choose the destination folder", $InstallLocationSafeSync))
			Case $CDEF_GUI_BUTTON_EncryptDir
				GUICtrlSetData($CDEF_GUI_INPUT_EncryptDir, FileSelectFolder("Choose Standard Data Folder", $InstallLocationSafeSync))
		EndSwitch
	WEnd
	Local $CDEF_EncryptDecryptFolder[2]
	$CDEF_EncryptDecryptFolder[0] = GUICtrlRead($CDEF_GUI_INPUT_DecryptDir)
	$CDEF_EncryptDecryptFolder[1] = GUICtrlRead($CDEF_GUI_INPUT_EncryptDir)
	GUIDelete($CDEF_GUI_ChooseDecryptEncryptFolderDialog)
	GUISetState(@SW_SHOW, $SafeSyncManagementTool)
	Return $CDEF_EncryptDecryptFolder
EndFunc

#cs RunSafeCrypt - Documentation
Name:               RunSafeCrypt
Version:			0.1
Description:        Function, run SafeCrypt in a loop, and sync two folders with encryption in both ways
Author:             Tim Lid
Parameters:         $SC_FolderName				- String: The name of the sync folder
					$SC_DataFolderDecrypt		- String: Path of the decrypt data folder
					$SC_DataFolderEncrypt		- String: Path of the encrypt data folder
					$SC_LogListFolderDecrypt	- String: Path to log list of decrypt file
					$SC_LogListFolderEncrypt	- String: Path to log list of decrypt file
					$SC_LogListFileDecrypt		- String: Path to log list of decrypt folder
					$SC_LogListFileEncrypt		- String: Path to log list of encrypt folder
					$SC_PasswordFolder			- String: Password of the folder
Return values:      Success:				- Delete files on the other location
                    Failure:				- TODO
Last edit:			2015.04.16 - 12:27 - renaming variables
TODO:				Commentation; Failure; Console output
#ce
Func RunSafeCrypt()
	RegWrite($SafeSyncRegistrySoftwareManagementTool, "RunSafeCrypt", "REG_SZ", "1")
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
EndFunc

#cs SafeCrypt - Documentation
Name:               SafeCrypt
Version:			0.1
Description:        Function, Check for deleted Files and delete the file on the other side
Author:             Tim Lid
Parameters:         $SC_FolderName				- String: The name of the sync folder
					$SC_DataFolderDecrypt		- String: Path of the decrypt data folder
					$SC_DataFolderEncrypt		- String: Path of the encrypt data folder
					$SC_LogListFolderDecrypt	- String: Path to log list of decrypt file
					$SC_LogListFolderEncrypt	- String: Path to log list of decrypt file
					$SC_LogListFileDecrypt		- String: Path to log list of decrypt folder
					$SC_LogListFileEncrypt		- String: Path to log list of encrypt folder
					$SC_PasswordFolder			- String: Password of the folder
Return values:      Success:				- Delete files on the other location
                    Failure:				- TODO
Last edit:			2015.04.16 - 12:27 - renaming variables
TODO:				Commentation; Failure; Console output
#ce
Func SafeCrypt($SC_FolderName, $SC_DataFolderDecrypt, $SC_DataFolderEncrypt, $SC_LogListFolderDecrypt, $SC_LogListFolderEncrypt, $SC_LogListFileDecrypt, $SC_LogListFileEncrypt, $SC_PasswordFolder)

	DirGetSize($SC_DataFolderDecrypt)
	If @error Then
		ConsoleWrite("Folder not exists: " & $SC_DataFolderDecrypt & @CRLF)
	Else
		DirGetSize($SC_DataFolderDecrypt)
		If @error Then
			ConsoleWrite("Folder not exists: " & $SC_DataFolderDecrypt)
		Else
			DirCreate(@AppDataDir & "\SafeCrypt")
			DirCreate(@AppDataDir & "\SafeCrypt\" & $SC_FolderName)

			$SC_AppDir = @AppDataDir & "\SafeCrypt\" & $SC_FolderName
			$SC_LogListFolderDecrypt = $SC_AppDir & "\FolderDecrypt.txt"
			$SC_LogListFolderEncrypt = $SC_AppDir & "\FolderEncrypt.txt"
			$SC_LogListFileDecrypt = $SC_AppDir & "\FileDecrypt.txt"
			$SC_LogListFileEncrypt = $SC_AppDir & "\FileEncrypt.txt"

			If Not FileExists($SC_LogListFolderDecrypt) Then
				_FileCreate($SC_LogListFolderDecrypt)
			EndIf

			If Not FileExists($SC_LogListFolderEncrypt) Then
				_FileCreate($SC_LogListFolderEncrypt)
			EndIf

			If Not FileExists($SC_LogListFileDecrypt) Then
				_FileCreate($SC_LogListFileDecrypt)
			EndIf

			If Not FileExists($SC_LogListFileEncrypt) Then
				_FileCreate($SC_LogListFileEncrypt)
			EndIf

			; Check Deleted Folder
			ConsoleWrite("Check Deleted Folder" & @CRLF)
			CheckDeletedFilesOrFolders(2, $SC_DataFolderDecrypt, $SC_DataFolderEncrypt, $SC_LogListFileEncrypt, $SC_LogListFileDecrypt, $SC_LogListFolderEncrypt, $SC_LogListFolderDecrypt)

			; Check Deleted Files
			ConsoleWrite("Check Deleted Files" & @CRLF)
			CheckDeletedFilesOrFolders(1, $SC_DataFolderDecrypt, $SC_DataFolderEncrypt, $SC_LogListFileEncrypt, $SC_LogListFileDecrypt, $SC_LogListFolderEncrypt, $SC_LogListFolderDecrypt)

			; Check for Changes in Files
			ConsoleWrite("Check Deleted Files" & @CRLF)
			CheckChangedFiles($SC_LogListFileDecrypt, $SC_LogListFileEncrypt, $SC_DataFolderDecrypt, $SC_DataFolderEncrypt, $SC_PasswordFolder)

			; Copy Folder from Decrypt to Encrypt
			ConsoleWrite("Copy Folder from Decrypt to Encrypt" & @CRLF)
			CopyFilesOrFolder($SC_DataFolderDecrypt, $SC_DataFolderEncrypt, 2, 0, $SC_PasswordFolder)

			; Copy Folder from Encrypt to Decrypt
			ConsoleWrite("Copy Folder from Encrypt to Decrypt" & @CRLF)
			CopyFilesOrFolder($SC_DataFolderEncrypt, $SC_DataFolderDecrypt, 2, 0, $SC_PasswordFolder)

			; Copy Files from Encrypt to Decrypt
			ConsoleWrite("Copy Files from Encrypt to Decrypt" & @CRLF)
			CopyFilesOrFolder($SC_DataFolderEncrypt, $SC_DataFolderDecrypt, 1, 1, $SC_PasswordFolder)
			ConsoleWrite("Copy Files from Encrypt to Decrypt Ends" & @CRLF)

			; Copy Files from Decrypt to Encrypt
			ConsoleWrite("Copy Files from Decrypt to Encrypt" & @CRLF)
			CopyFilesOrFolder($SC_DataFolderDecrypt, $SC_DataFolderEncrypt, 1, 0, $SC_PasswordFolder)
			ConsoleWrite("Copy Files from Decrypt to Encrypt Ends" & @CRLF)

			; Generate New File Lists, for the Next run
			ConsoleWrite("Generate Lists" & @CRLF)
			GenerateList($SC_DataFolderDecrypt, $SC_LogListFileDecrypt, 1)
			GenerateList($SC_DataFolderEncrypt, $SC_LogListFileEncrypt, 1)
			GenerateList($SC_DataFolderDecrypt, $SC_LogListFolderDecrypt, 2)
			GenerateList($SC_DataFolderEncrypt, $SC_LogListFolderEncrypt, 2)
			ConsoleWrite("Generate Lists End" & @CRLF)
		EndIf
	EndIf
EndFunc

#cs CheckChangedFiles - Documentation
Name:               CheckChangedFiles
Version:			0.1
Description:        Function, Check for deleted Files and delete the file on the other side
Author:             Tim Lid
Parameters:         $CFOF_LeftFolder		- String: The folder to scan
					$CFOF_RightFolder		- String: Path of the decrypt data folder
					$CFOF_Param				- String: Path of the encrypt data folder
					$CFOF_Decrypt			- String: Path to log list of decrypt file
					$CFOF_PasswordFolder	- String: Path to log list of decrypt file
					$GL_SplitPath			- Array[String] The Path splited into their elements
Return values:      Success:				- Delete files on the other location
                    Failure:				- TODO
Last edit:			2015.04.16 - 10:36 - renaming variables
TODO:				Commentation; Failure; Console output; rename left/right folder
#ce
Func CopyFilesOrFolder($CFOF_LeftFolder, $CFOF_RightFolder, $CFOF_Param, $CFOF_Decrypt, $CFOF_PasswordFolder)
	$CFOF_FileList = _FileListToArrayRec($CFOF_LeftFolder, "*|.sync|.sync", $CFOF_Param, 1, Default, 2)
	If Not @error Then
		For $i = 1 To $CFOF_FileList[0] Step 1
			If $CFOF_Param = 1 Then
				$CFOF_SplitPath = _PathSplit(StringReplace($CFOF_FileList[$i], $CFOF_LeftFolder, $CFOF_RightFolder, 1), $sDrive, $sDir, $sFilename, $sExtension)
				If $CFOF_Decrypt Then
					If Not FileExists($CFOF_SplitPath[1] & $CFOF_SplitPath[2] & $CFOF_SplitPath[3]) Then
						ConsoleWrite("Decrypt File1: " & $CFOF_SplitPath[1] & $CFOF_SplitPath[2] & $CFOF_SplitPath[3] & @CRLF)
						DecryptFile($CFOF_FileList[$i], $CFOF_SplitPath[1] & $CFOF_SplitPath[2], $CFOF_PasswordFolder)
					EndIf
				Else
					If Not FileExists(StringReplace($CFOF_FileList[$i], $CFOF_LeftFolder, $CFOF_RightFolder, 1) & ".7z") Then
						EncryptFile($CFOF_FileList[$i], StringReplace($CFOF_FileList[$i], $CFOF_LeftFolder, $CFOF_RightFolder, 1) & ".7z", $CFOF_PasswordFolder)
						ConsoleWrite("Encrypt File1: " & StringReplace($CFOF_FileList[$i], $CFOF_LeftFolder, $CFOF_RightFolder, 1) & @CRLF)
					EndIf
				EndIf
			ElseIf $CFOF_Param = 2 Then
				DirGetSize(StringReplace($CFOF_FileList[$i], $CFOF_LeftFolder, $CFOF_RightFolder, 1))
				If @error Then
					ConsoleWrite("Dir Create: " & StringReplace($CFOF_FileList[$i], $CFOF_LeftFolder, $CFOF_RightFolder, 1) & @CRLF)
					DirCreate(StringReplace($CFOF_FileList[$i], $CFOF_LeftFolder, $CFOF_RightFolder, 1))
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
Parameters:         $CDFOF_Param					- String: The folder to scan
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