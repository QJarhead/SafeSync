#cs ----------------------------------------------------------------------------

AutoIt Version: 	3.3.12.0
Author:				Tim Christoph Lid
Version:			0.0.1.4
Name:				SafeSync x64

Script Function:
SafeSync Management Tool

TODO:
Commentation
Check every Variable
Uninstall-Function!
Testing (Another Installation)

#ce ----------------------------------------------------------------------------

#RequireAdmin

; Command line parameter:
; 1: Installation Location

DirCreate( $CmdLine[1] )
If $CmdLine[0] > 1 Then
	FileCopy( $CmdLine[2], $CmdLine[1] & "/")
	FileCopy( @TempDir & "/Uninstall.exe", $CmdLine[1] & "/", 1)
EndIf