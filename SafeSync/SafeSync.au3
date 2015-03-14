#cs ----------------------------------------------------------------------------

AutoIt Version: 	3.3.12.0
Author:				Tim Christoph Lid
Version:			0.0.1.4
Name:				SafeSync x64

Script Function:
SafeSync Management Tool

#ce ----------------------------------------------------------------------------

; Temp
;MsgBox(64, "Passed Parameters", "Test")


#cs ----------------------------------------------------------------------------

FunctionName:		Init

Function include Everything needed for the Programm
#ce ----------------------------------------------------------------------------

; Ínclude everything needed
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

;Check for Parameters
;Install CryptSync

; Import Data in .exe
FileInstall("C:\Program Files (x86)\SafeSync\include\BitTorrent_SyncX64.exe", @TempDir & "\BitTorrent_SyncX64.exe")
;FileInstall("D:\Cloud\TimLid\Daten\Programmierung\Mittelstufenprojekt\SafeSync\include\CryptSync64-1.2.0.msi", @TempDir & "\CryptSync64-1.2.0.msi")

; General variables
$ConfigFile = "config.ini"

; Read Ini Section BTSync
$BTSyncFolder = IniRead($ConfigFile, "BTSync", "InstallFolder", @ProgramFilesDir & "\BitTorrent Sync")
$BTSyncConfigCreate = @ProgramFilesDir & "\BitTorrent Sync\config.json"
;@TempDir&IniRead($ConfigFile, "BTSync", "ConfigFileCreate", "\ConfigFileBTSync.conf")

; Read Ini Section SafeSync
If @OSArch = "X64" Then
	$SafeSyncRegKey = "HKEY_CURRENT_USER"&IniRead($ConfigFile, "SafeSync", "RegKey", "\SOFTWARE\SafeSync\Folders")
	$BTSyncUninstallRegKey = "HKEY_LOCAL_MACHINE64"&IniRead($ConfigFile, "BTSync", "UninstallRegKey", "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BitTorrent Sync")
Else
	$SafeSyncRegKey = "HKEY_CURRENT_USER"&IniRead($ConfigFile, "SafeSync", "RegKey", "\SOFTWARE\SafeSync\Folders")
	$BTSyncUninstallRegKey = "HKEY_LOCAL_MACHINE"&IniRead($ConfigFile, "BTSync", "UninstallRegKey", "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BitTorrent Sync")
EndIf

$SafeSyncDataFolder = IniRead($ConfigFile, "SafeSync", "DataFolder", "\SOFTWARE\SafeSync\Folders")
$SafeSyncDataCryptFolder = IniRead($ConfigFile, "SafeSync", "DataCryptFolder", "\SOFTWARE\SafeSync\Folders")

; End Of Declaration


; Create Registry, if an external file is open with command line parameter "ImportFile"
If Not $CmdLine[0] = 0 Then
	If $CmdLine[1] == "ImportFile" Then
		FileOpen( $CmdLine[2] )
		MsgBox(0,"Test","Test")
		RegistryCreateNewFolder(StringLeft( FileReadLine( $CmdLine[2], 1),StringInStr( FileReadLine( $CmdLine[2], 1), " " )), StringRight( FileReadLine( $CmdLine[2], 1),StringLen(FileReadLine( $CmdLine[2], 1)) - StringInStr( FileReadLine( $CmdLine[2], 1), " " )))
		Exit
	EndIf
EndIf

; Create Gui

;Opt("GUIOnEventMode", 1)

Global $SafeSyncManagementTool = GUICreate("SafeSyncManagementTool", 915, 437, 195, 124)
$MenuFile = GUICtrlCreateMenu("&File")
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
GUICtrlSetOnEvent($MenuNew, "MenuNew")
GUICtrlSetOnEvent($MenuDelete, "MenuDelete")
GUICtrlSetOnEvent($MenuExport, "MenuExport")
GUICtrlSetOnEvent($MenuExit, "MenuExit")
GUICtrlSetOnEvent($MenuBitTorrent, "MenuBitTorrent")
GUICtrlSetOnEvent($MenuCrypt, "MenuCrypt")
GUICtrlSetOnEvent($MenuOther, "MenuOther")
GUICtrlSetOnEvent($MenuAbout, "MenuAbout")
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
Local $idListview = GUICtrlCreateListView("Name|Key|Location", 10, 10, 895, 395) ;,$LVS_SORTDESCENDING)

Func ReloadListView()
	_GUICtrlListView_DeleteAllItems ( $idListview )
   Local $FolderCounter = 0
   For $i = 1 To 1000
	  $sVar = RegEnumVal($SafeSyncRegKey, $i)
	  $FolderCounter = $i
	  If @error <> 0 Then ExitLoop
	  $sVar1 = RegRead($SafeSyncRegKey, $sVar)
	  Local $idItem1 = GUICtrlCreateListViewItem("" & $sVar & "| " & $sVar1 & " | " & $SafeSyncDataFolder & $sVar & " ", $idListview)
   Next
   Global $SyncFolders[$FolderCounter][2]
   For $i = 1 To $FolderCounter + 1
	  $sVar = RegEnumVal($SafeSyncRegKey, $i)
	  If @error <> 0 Then ExitLoop
	  $sVar1 = RegRead($SafeSyncRegKey, $sVar)
	  $SyncFolders[$i][0] = $SafeSyncDataFolder & $sVar
	  $SyncFolders[$i][1] = $sVar1
   Next
   createConfig($SyncFolders, "D://SafeSync/Config")
   StopBTSync()
   Sleep(1000)
   StartBTSync()
EndFunc

;Initial reloading list View
ReloadListView()

_GUICtrlListView_SetColumnWidth($idListview, 0, 120)
_GUICtrlListView_SetColumnWidth($idListview, 1, 240)
_GUICtrlListView_SetColumnWidth($idListview, 2, 350)
GUISetState(@SW_SHOW)


Global $Form1 = GUICreate("Form1", 165, 200, 200, 124)
$Radio1 = GUICtrlCreateRadio("Generate new Key", 32, 20, 113, 25)
GUICtrlSetState(-1, $GUI_CHECKED)
$Radio2 = GUICtrlCreateRadio("Import from File", 32, 60, 113, 17)
$Radio3 = GUICtrlCreateRadio("Manual", 32, 100, 113, 17)
$Button1 = GUICtrlCreateButton("Button1", 32, 140, 91, 33)

GUISwitch($SafeSyncManagementTool)

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
					ExitLoop
			EndSwitch
		Case $MenuNew
			GUISetState(@SW_SHOW,$Form1)
			GUISetState(@SW_HIDE,$SafeSyncManagementTool)
		Case $MenuDelete
			MenuDelete()
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
					Local $NewFolderName = InputBox("Folder Key", "Enter folder Key", getNewKey(), "")
					Local $NewFolderKey = InputBox("Folder Name", "Enter folder Name", "", "")
					;MsgBox(64, "Passed Parameters", getNewKey())
					RegistryCreateNewFolder($NewFolderKey, $NewFolderName)
					ReloadListView()
					GUISetState(@SW_SHOW,$SafeSyncManagementTool)
					GUISetState(@SW_HIDE,$Form1)
				Case BitAND(GUICtrlRead($Radio2), $GUI_CHECKED) = $GUI_CHECKED
					Local $sFileOpenDialog = FileOpenDialog("Suche File!", @WindowsDir & "\", "Files (*.txt)", $FD_FILEMUSTEXIST + $FD_MULTISELECT)
					$NewKey = FileReadLine($sFileOpenDialog, 1)
					$WriteKey = StringSplit( $NewKey, ';')
					RegistryCreateNewFolder($WriteKey[1],$WriteKey[2])
					GUISetState(@SW_SHOW,$SafeSyncManagementTool)
					GUISetState(@SW_HIDE,$Form1)
				Case BitAND(GUICtrlRead($Radio3), $GUI_CHECKED) = $GUI_CHECKED
					Local $NewFolderName = InputBox("Folder Key", "Enter folder Key", "", "")
					Local $NewFolderKey = InputBox("Folder Name", "Enter folder key", "", "")
					RegistryCreateNewFolder($NewFolderKey,$NewFolderName)
					GUISetState(@SW_SHOW,$SafeSyncManagementTool)
					GUISetState(@SW_HIDE,$Form1)
        EndSelect
   EndSwitch
WEnd

; Function to Create a New Folder
Func RegistryCreateNewFolder($NewFolderName, $NewFolderKey)
	RegWrite($SafeSyncRegKey, $NewFolderName, "REG_SZ", $NewFolderKey)
	DirCreate ($SafeSyncDataFolder & $NewFolderName)
	DirCreate ($SafeSyncDataCryptFolder & $NewFolderName)

	; CryptSync Add folder
	MsgBox(0,"Test","Test")
	;CreateCryptSyncPair($SafeSyncDataFolder & $NewFolderName, $SafeSyncDataCryptFolder & $NewFolderName, "Password")
	Run(@TempDir & '\BitTorrent_SyncX64.exe /config ' & $BTSyncConfigCreate)
EndFunc

; Function to Delete a Folder
Func RegistryDeleteFolder($FolderName)
	RegDelete($SafeSyncRegKey,$FolderName)
	ReloadListView()
	StopBTSync()
	StartBTSync()
	;Run(@TempDir & '\BitTorrent_SyncX64.exe /config ' & $BTSyncConfigCreate)
EndFunc

; Stop the Bittorent Sync Process
Func StopBTSync()
	    Local $aProcessList = ProcessList("BitTorrent_SyncX64.exe")
    For $i = 1 To $aProcessList[0][0]
		ProcessClose ( $aProcessList[$i][1] )
    Next
EndFunc

; Start the BitTorrent Sync with the config File
Func StartBTSync()
	Run(@TempDir & '\BitTorrent_SyncX64.exe /config "' & $BTSyncConfigCreate & '"')
EndFunc

;Menu Functions
Func MenuNew()

   ; TODO Switch Case, abfrage neuer ordner, key eingeben oder datei importieren



 ;  $Form1 = GUICreate("Form1", 165, 145, 192, 124)
  ; $Radio1 = GUICtrlCreateRadio("Generate new Key", 32, 20, 113, 25)
;   GUICtrlSetState(-1, $GUI_CHECKED)
;   $Radio2 = GUICtrlCreateRadio("Import from File", 32, 60, 113, 17)
;   $Button1 = GUICtrlCreateButton("Button1", 32, 96, 91, 33)
;   GUISetState(@SW_SHOW)
;MsgBox(64, "Passed Parameters", "Test")
	;Local $NewFolderName = InputBox("New Folder", "Enter new folder name", "", "")
	;Local $NewFolderKey = InputBox("Folder Key", "Enter folder key", "", "")
	;MsgBox(64, "Passed Parameters", getNewKey())
	;RegistryCreateNewFolder($NewFolderName, $NewFolderKey)
	;ReloadListView()
EndFunc

Func gui2()
     $hGUI2 = GUICreate("Gui 2", 200, 200, 350, 350)
     $hButton3 = GUICtrlCreateButton("MsgBox 2", 10, 10, 80, 30)
     GUISetState()
 EndFunc   ;==>gui2

Func MenuDelete()
	$iSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetSelected")
	$sSelect = ControlListView($SafeSyncManagementTool, "", $idListview, "GetText", $iSelect)
	$iMsgBoxAnswer = MsgBox(33,"Test23","Delete '"& $sSelect &"'?")
	Select
		Case $iMsgBoxAnswer = 1
			RegistryDeleteFolder($sSelect)
		Case $iMsgBoxAnswer = 2
	EndSelect
	ReloadListView()
EndFunc

Func MenuExport()
	MsgBox(0, "TODO", "Should be export BTSync Settings & Ini-File & Readme with discription, in a zip")
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

; Test

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
		MsgBox($MB_SYSTEMMODAL , "Title", "This message box will timeout after " & $iTimeout & " seconds or select the OK button.", $iTimeout)
EndFunc

; Function to create the config File, from the entries on the registry
Func createConfig($SyncFolders, $Storage_Path)
   ;_ArrayDisplay($Table, "2D display") ; Note columns truncated

   _FileCreate($BTSyncConfigCreate)
   Local $hFileOpen = FileOpen($BTSyncConfigCreate,1)
   If $hFileOpen = -1 Then
	   MsgBox("Test", "", "An error occurred when reading the file.")
   EndIf

   ; Write data to the file using the handle returned by FileOpen.
   FileWrite($hFileOpen, '{' & @CRLF)
   FileWrite($hFileOpen, '     "storage_path" : "'&$storage_Path&'",'&@CRLF)
   FileWrite($hFileOpen, '     "use_gui" : true,'& @CRLF)
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

; Function to get a new Secret-Key
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

; Function to Create with CryptSync a Folder Pair, not neede anymore, when using of SafeCrypt
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

; Function to Get the Count of the Crypted folder, maybe not needed anymore.
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
	MsgBox(64,"Test",$Counter)
	return ($Counter - 1)
EndFunc

; TODO
Func RegisterFile()
	;RegWrite( "HKEY_CLASSES_ROOT\ssfile
EndFunc

#cs ----------------------------------------------------------------------------

[HKEY_CLASSES_ROOT\ssffile]
@="KeePass Password Database"
"AlwaysShowExt"=""

[HKEY_CLASSES_ROOT\ssffile\DefaultIcon]
@="\"C:\\Program Files (x86)\\KeePass Password Safe 2\\KeePass.exe\",0"

[HKEY_CLASSES_ROOT\ssffile\shell]

[HKEY_CLASSES_ROOT\ssffile\shell\open]
@="&Open with KeePass Password Safe"

[HKEY_CLASSES_ROOT\ssffile\shell\open\command]
@="\"C:\\Program Files (x86)\\KeePass Password Safe 2\\KeePass.exe\" \"%1\""

#ce ----------------------------------------------------------------------------
