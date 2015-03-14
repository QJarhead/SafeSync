#cs ----------------------------------------------------------------------------

AutoIt Version: 	3.3.12.0
Author:				Tim Christoph Lid
Version:			1.0
Name:				Test.au3

Description:
Testing the Installation process

#ce ----------------------------------------------------------------------------


Exit
; Not Needed, because of setting: "use_gui:false"
#Include <GuiToolBar.au3>


Opt("WinTitleMatchMode", 4)
Global $hTray = WinGetHandle("[CLASS:Shell_TrayWnd]")
Global $hToolbar = ControlGetHandle($hTray, "", "[CLASSNN:ToolbarWindow321]")
Global $iCnt = _GUICtrlToolbar_ButtonCount($hToolbar)
ConsoleWrite("Debug: $iCnt = " & $iCnt & @LF)
Global $iCmdVolume = -1
Global $sMsg, $sText, $iCmd
For $n = 0 To $iCnt - 1
    $sMsg = "Index: " & $n
    $iCmd = _GUICtrlToolbar_IndexToCommand($hToolbar, $n)
    $sMsg &= "  CommandID: " & $iCmd
    $sText = _GUICtrlToolbar_GetButtonText($hToolbar, $iCmd)
    If StringInStr($sText, "BitTorrent") Then
		_GUICtrlToolbar_SetButtonState($hToolbar, $iCmd, $TBSTATE_HIDDEN)
	EndIf
    $sMsg &= "  Text: " & $sText
    ConsoleWrite("Debug: " & $sMsg & @LF)
Next
ConsoleWrite("Debug: $iCmdVolume = " & $iCmdVolume & @LF)

_GUICtrlToolbar_SetButtonState($hToolbar, $iCmdVolume, $TBSTATE_HIDDEN)

Exit
#include <GUIConstantsEx.au3>

$SafeSyncRegistry = "HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync"
$DisplayIcon = @UserProfileDir & "\Program Files\SafeSync\SafeSync.exe"
$DisplayName = "SafeSync"
$DisplayVersion = "0.0.1"
$InstallLocation = @UserProfileDir & "\Program Files\SafeSync"
$Publisher = "SafeSync-Team"
$UninstallString = @UserProfileDir & "\Program Files\SafeSync\SafeSync.exe /UNINSTALL"

If Not StringCompare( $DisplayName, RegRead( $SafeSyncRegistry, "DisplayName")) = 0 Then
	Install()
EndIf


Func Install()
    ; Create a GUI with various controls.
    Local $InstallationDialog = GUICreate("SafeSync - Installation", 470,150)
    Local $InstallButton = GUICtrlCreateButton("Install", 350, 100, 85, 25)
    Local $InstallDirectory = GUICtrlCreateLabel("Installation dir;",10,20)
	Local $InstallDir = GUICtrlCreateInput($InstallLocation, 10, 38, 300)
	Local $InstallDirSelect = GUICtrlCreateButton( "SelectFolder", 320,35,100)

    ; Display the GUI.
    GUISetState(@SW_SHOW, $InstallationDialog)

    ; Loop until the user exits.
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
			Case $InstallButton
				RegWrite( $SafeSyncRegistry)
				RegWrite( $SafeSyncRegistry, "DisplayIcon", "REG_SZ", $DisplayIcon)
				;RegWrite( $SafeSyncRegistry, "DisplayName", "REG_SZ", $DisplayName)
				RegWrite( $SafeSyncRegistry, "DisplayVersion", "REG_SZ", $DisplayVersion)
				RegWrite( $SafeSyncRegistry, "InstallLocation", "REG_SZ", $InstallLocation)
				RegWrite( $SafeSyncRegistry, "Publisher", "REG_SZ", $Publisher)
				RegWrite( $SafeSyncRegistry, "UninstallString", "REG_SZ", $UninstallString)
				; TODO Copy other files and create folder
				ExitLoop
			Case $InstallDirSelect
				GUICtrlSetData( $InstallDir, FileSelectFolder( "Choose the destination folder", $InstallLocation))
        EndSwitch
    WEnd

    ; Delete the previous GUI and all controls.
    GUIDelete($InstallationDialog)
EndFunc