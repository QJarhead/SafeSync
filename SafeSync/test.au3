#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Form1", 517, 298, 194, 135)
$Encryption = GUICtrlCreateRadio("Encryption", 48, 128, 113, 25)
$Input1 = GUICtrlCreateInput("Name", 48, 88, 121, 21)
$Foldername = GUICtrlCreateLabel("Foldername", 48, 64, 59, 17)
$Input2 = GUICtrlCreateInput("Input2", 48, 160, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$Input3 = GUICtrlCreateInput("Input3", 216, 88, 161, 21)
$Input4 = GUICtrlCreateInput("Input4", 48, 192, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$Destination = GUICtrlCreateLabel("Destination Folder:", 216, 64, 92, 17)
$Button1 = GUICtrlCreateButton("Create", 224, 248, 75, 25)
$Label1 = GUICtrlCreateLabel("Encryption Folder:", 216, 136, 89, 17)
$Label2 = GUICtrlCreateLabel("Add Folder", 240, 24, 55, 17)
$Input5 = GUICtrlCreateInput("Input5", 216, 160, 161, 21)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $Encryption
	EndSwitch
WEnd
