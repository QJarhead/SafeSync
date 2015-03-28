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

Global Const $SafeSyncRegistrySoftware = "HKEY_CURRENT_USER64\Software\SafeSync"
Global Const $SafeSyncRegistryFolders = "HKEY_CURRENT_USER64\Software\SafeSync\Folders"
For $i = 1 To 1000
	$sVar = RegEnumVal($SafeSyncRegistryFolders, $i)
	$FolderCounter = $i
	If @error <> 0 Then ExitLoop
	$sVar1 = RegRead($SafeSyncRegistryFolders, $sVar)
	GetInfo($sVar1)
Next

Func GetInfo($secret)
	; Download the file
	Local $sFilePath = @TempDir & "\secretKey.temp"

	; Download the file in the background with the selected option of 'force a reload from the remote site.'
	Local $hDownload = InetGet("http://admin:passwd@127.0.0.1:7878/api?method=get_folder_peers&secret=" & $secret, @TempDir & "\secretKey.temp", $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

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

	MsgBox(0,"",$NewKey)

	;$NewKey = StringRegExpReplace ( $NewKey, "{*:", "" )

	;$WriteKey = StringSplit( $NewKey, '"')

	;return $WriteKey[8]
EndFunc