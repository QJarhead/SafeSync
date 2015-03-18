#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#RequireAdmin

; Delete Registry
RegDelete("HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeSync")
RegDelete("HKEY_CURRENT_USER64\Software\Microsoft\Windows\CurrentVersion\Uninstall\SafeCrypt")
RegDelete("HKEY_CURRENT_USER\Software\SafeCrypt")
RegDelete("HKEY_CURRENT_USER\Software\SafeSync")
RegDelete( "HKEY_CLASSES_ROOT64\ssffile")