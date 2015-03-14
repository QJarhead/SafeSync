#cs ----------------------------------------------------------------------------

AutoIt Version: 	3.3.12.0
Author:				Tim Christoph Lid
Version:			0.0.1.4
Name:				SafeCrypt x64

Script Function:
SafeCrypt Tool

#ce ----------------------------------------------------------------------------

#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <Crypt.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StringConstants.au3>

Global $Password = PasswordSkript()
$7zLocation = "D:\Temp2\7z.exe"
$SafeCryptFolder = "D:\SafeCrypt\"
$DataFolderDecrypt = $SafeCryptFolder & "Decrypt\"
$DataFolderEncrypt = $SafeCryptFolder & "Encrypt\"
$LogListFolderDecrypt = $SafeCryptFolder & "FolderDecrypt.txt"
$LogListFolderEncrypt = $SafeCryptFolder & "FolderEncrypt.txt"
$LogListFileDecrypt = $SafeCryptFolder & "FilesDecrypt.txt"
$LogListFileEncrypt = $SafeCryptFolder & "FilesEncrypt.txt"

Global $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""

Local $ListEncrypt
Local $ListDecrypt
Local $FileListDecrypt
Local $FileListEncrypt

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
CheckDeletedFilesOrFolders(2)

; Check Deleted Files
CheckDeletedFilesOrFolders(1)

; Check for Changes in Files
CheckChangedFiles()

; Copy Folder from Decrypt to Encrypt
CopyFilesOrFolder($DataFolderDecrypt, $DataFolderEncrypt, 2, 0)

; Copy Folder from Encrypt to Decrypt
CopyFilesOrFolder($DataFolderEncrypt, $DataFolderDecrypt, 2, 0)

; Copy Files from Encrypt to Decrypt
CopyFilesOrFolder($DataFolderEncrypt, $DataFolderDecrypt, 1, 1)

; Copy Files from Decrypt to Encrypt
CopyFilesOrFolder($DataFolderDecrypt, $DataFolderEncrypt, 1, 0)

; Generate New File Lists, for the Next run
GenerateList($DataFolderDecrypt, $LogListFileDecrypt, 1)
GenerateList($DataFolderEncrypt, $LogListFileEncrypt, 1)
GenerateList($DataFolderDecrypt, $LogListFolderDecrypt, 2)
GenerateList($DataFolderEncrypt, $LogListFolderEncrypt, 2)

; Copy Files from Decrypt to Encrypt
Func CopyFilesOrFolder($LeftFolder, $RightFolder, $Param, $Decrypt)
	$FileList = _FileListToArrayRec($LeftFolder, "*", $Param, 1, Default, 2)
	If Not @error Then
		For $i = 1 To $FileList[0] Step 1
			If $Param = 1 Then
				$PathSplit = _PathSplit( StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1), $sDrive, $sDir, $sFilename, $sExtension)
				If $Decrypt Then
					If Not FileExists($PathSplit[1] & $PathSplit[2] & $PathSplit[3]) Then
						ConsoleWrite( "Encrypt File: " &  $PathSplit[1] & $PathSplit[2] & $PathSplit[3]  & @CRLF)
						DecryptFile($FileList[$i], $PathSplit[1] & $PathSplit[2], $Password)
						;FileCopy( $FileList[$i], StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1))
					EndIf
				Else
					If Not FileExists(StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1) & ".7z") Then
						EncryptFile( $FileList[$i], StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1) & ".7z", $Password)
						ConsoleWrite( "Decrypt File: " &  StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1) & @CRLF)
						;FileCopy( $FileList[$i], StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1))
					EndIf
				EndIf
			ElseIf $Param = 2 Then
				If Not DirGetSize(StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1)) <> -1 Then
					ConsoleWrite( "Create Folder: " &  StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1) & @CRLF)
					DirCreate( StringReplace($FileList[$i], $LeftFolder, $RightFolder, 1))
				EndIf
			EndIf
		Next
	EndIf
EndFunc

; Check for Deleted Files
Func CheckDeletedFilesOrFolders($Param)
	If $Param = 1 Then
		_FileReadToArray($LogListFileEncrypt, $ListEncrypt)
		_FileReadToArray($LogListFileDecrypt, $ListDecrypt)
	ElseIf $Param = 2 Then
		_FileReadToArray($LogListFolderEncrypt, $ListEncrypt)
		_FileReadToArray($LogListFolderDecrypt, $ListDecrypt)
	EndIf
	If Not @error Then
		If $Param = 1 Then
			For $i = 1 To $ListDecrypt[0] Step 3
				If Not FileExists( $ListDecrypt[$i] & $ListDecrypt[$i+1]) Then
					$EncryptFile = StringReplace($ListDecrypt[$i], $DataFolderDecrypt, $DataFolderEncrypt, 1) & $ListDecrypt[$i+1] & ".7z"
					If FileExists($EncryptFile) Then
						ConsoleWrite("Delete Encrypted File: " & $EncryptFile & @CRLF)
						Local $iDelete = FileDelete( $EncryptFile )
					EndIf
				EndIf
			Next
			For $i = 1 To $ListEncrypt[0] Step 3
				If Not FileExists( $ListEncrypt[$i] & $ListEncrypt[$i+1]) Then
					$PathSplit = _PathSplit(StringReplace($ListEncrypt[$i], $DataFolderEncrypt, $DataFolderDecrypt, 1) & $ListEncrypt[$i+1], $sDrive, $sDir, $sFilename, $sExtension)
					$DecryptFile = $PathSplit[1] & $PathSplit[2] & $PathSplit[3]
					If FileExists( $DecryptFile ) Then
						ConsoleWrite("Delete Decrypted File: " & $DecryptFile & @CRLF)
						Local $iDelete = FileDelete( $DecryptFile )
					EndIf
				EndIf
			Next
		ElseIf $Param = 2 Then
			For $i = 1 To $ListDecrypt[0] Step 3
				If Not DirGetSize($ListDecrypt[$i] & $ListDecrypt[$i+1]) <> -1 Then
					If Not DirGetSize(StringReplace($ListDecrypt[$i], $DataFolderDecrypt, $DataFolderEncrypt, 1) & $ListDecrypt[$i+1]) <> -1 Then
						ConsoleWrite("Delete Folder1: " & StringReplace($ListDecrypt[$i], $DataFolderDecrypt, $DataFolderEncrypt, 1) & $ListDecrypt[$i+1] & @CRLF)
						DirRemove( StringReplace($ListDecrypt[$i], $DataFolderDecrypt, $DataFolderEncrypt, 1) & $ListDecrypt[$i+1], 1 )
					EndIf
				EndIf
			Next
			For $i = 1 To $ListEncrypt[0] Step 3
				If Not DirGetSize($ListEncrypt[$i] & $ListEncrypt[$i+1]) <> -1 Then
					$EncryptFolder = StringReplace($ListEncrypt[$i], $DataFolderEncrypt, $DataFolderDecrypt, 1) & $ListEncrypt[$i+1]
					ConsoleWrite("Delete Folder2: " & $EncryptFolder & @CRLF)
					DirRemove( $EncryptFolder, 1 )
				EndIf
			Next
		EndIf
	EndIf
EndFunc

; Check for Changes in Files with MD5 Checksum
Func CheckChangedFiles()
	Local $LeftFolder
	Local $RightFolder
	_FileReadToArray($LogListFileEncrypt, $LeftFolder)
	_FileReadToArray($LogListFileDecrypt, $RightFolder)
	If Not @error Then
		For $i = 1 To $LeftFolder[0] Step 3
			$NewHash = _Crypt_HashFile($LeftFolder[$i] & $LeftFolder[$i+1], $CALG_MD5)
			$OldHash = $LeftFolder[$i+2]
			$PathSplit = _PathSplit(StringReplace($LeftFolder[$i], $DataFolderEncrypt, $DataFolderDecrypt, 1) &  $LeftFolder[$i+1], $sDrive, $sDir, $sFilename, $sExtension)
			If $OldHash <> $NewHash Then
				If FileExists($LeftFolder[$i] & $LeftFolder[$i+1]) Then
					MsgBox(0,"",$LeftFolder[$i] & $LeftFolder[$i+1])
					ConsoleWrite("Change in File: " & $LeftFolder[$i] & $LeftFolder[$i+1] & @CRLF)
					ConsoleWrite("Decrypt To: " & StringReplace($LeftFolder[$i], $DataFolderEncrypt, $DataFolderDecrypt, 1) &  $LeftFolder[$i+1] & @CRLF)
					FileDelete(StringReplace($LeftFolder[$i], $DataFolderEncrypt, $DataFolderDecrypt, 1) & $LeftFolder[$i+1])
					$From =  $LeftFolder[$i] & $LeftFolder[$i+1]
					$To = StringReplace($LeftFolder[$i], $DataFolderEncrypt, $DataFolderDecrypt, 1) & $LeftFolder[$i+1]
					ConsoleWrite($LeftFolder[$i] & $LeftFolder[$i+1] & "    " & $PathSplit[1] & $PathSplit[2] & $PathSplit[3] & @CRLF)
					DecryptFile($LeftFolder[$i] & $LeftFolder[$i+1], $PathSplit[1] & $PathSplit[2], $Password)
					;FileCopy( $LeftFolder[$i] & $LeftFolder[$i+1], StringReplace($LeftFolder[$i], $DataFolderEncrypt, $DataFolderDecrypt, 1) & $LeftFolder[$i+1] )
				EndIf
			EndIf
		Next
		For $i = 1 To $RightFolder[0] Step 3
			$NewHash = _Crypt_HashFile($RightFolder[$i] & $RightFolder[$i+1], $CALG_MD5)
			$OldHash = $RightFolder[$i+2]
			If $OldHash <> $NewHash Then
				If FileExists($RightFolder[$i] & $RightFolder[$i+1]) Then
					ConsoleWrite("Change in File: " & $RightFolder[$i] & $RightFolder[$i+1] & @CRLF)
					ConsoleWrite("Encrypt File " & $RightFolder[$i] & $RightFolder[$i+1] & @CRLF)
					FileDelete(StringReplace($RightFolder[$i], $DataFolderDecrypt, $DataFolderEncrypt, 1) & $RightFolder[$i+1])
					EncryptFile($RightFolder[$i] & $RightFolder[$i+1], StringReplace($RightFolder[$i], $DataFolderDecrypt, $DataFolderEncrypt, 1) & $RightFolder[$i+1] & ".7z", $Password)
					;FileCopy( $RightFolder[$i] + $RightFolder[$i+1], StringReplace($RightFolder[$i], $DataFolderDecrypt, $DataFolderEncrypt, 1) & $RightFolder[$i+1])
				EndIf
			EndIf
		Next
	EndIf
EndFunc

; Function, return a Array of the Files in the Folder to Scan and the Checksum, create a .txt file, which includes the full path and the Checksum
Func GenerateList($FolderScan, $OutputFileList, $Param)
	; List all the files and folders in the desktop directory using the default parameters and return the full path.
	FileDelete($OutputFileList)
	Local $FileList = _FileListToArrayRec($FolderScan, "*", $Param, 1, Default, 2)
	If Not @error Then
		_FileCreate($OutputFileList)
		Local $OutputFileListOpen = FileOpen($OutputFileList, $FO_APPEND)
		If $OutputFileListOpen = -1 Then
			MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
			Return False
		EndIf
		Local $FileListWithHash[$FileList[0] + 1][2]
		For $i = 1 To $FileList[0]
			$FileListWithHash[$i][0] = $FileList[$i]
			$FileListWithHash[$i][1] = _Crypt_HashFile($FileList[$i], $CALG_MD5)
			Local $aPathSplit = _PathSplit($FileList[$i], $sDrive, $sDir, $sFilename, $sExtension)
			FileWriteLine($OutputFileListOpen, $aPathSplit[1] & $aPathSplit[2] & @CRLF)
			FileWriteLine($OutputFileListOpen, $aPathSplit[3] & $aPathSplit[4] & @CRLF)
			FileWriteLine($OutputFileListOpen, $FileListWithHash[$i][1] & @CRLF)
		Next
		FileClose($OutputFileListOpen)
	EndIf
	Return $FileList
EndFunc

; Decrypt File
Func DecryptFile($EncryptFile, $DecryptFolder, $Password)
	RunWait( @ComSpec & ' /c ' & $7zLocation &  ' x -y -t7z -o"' & $DecryptFolder & '" -p"' & $Password & '" "' & $EncryptFile & '"', @TempDir , @SW_HIDE )
EndFunc

; Encrypt File
Func EncryptFile($DecryptFile, $EncryptFile, $Password)
	RunWait( @ComSpec & ' /c ' & $7zLocation &  ' a -y -t7z -p"' & $Password & '" "' & $EncryptFile & '" "' & $DecryptFile & '"', @TempDir , @SW_HIDE )
EndFunc

Func PasswordSkript()
	$Password = ""

	;Init Section
	If Not RegRead( "HKEY_CURRENT_USER\Software\SafeCrypt", "Installed") = 1 Then
		RegWrite("HKEY_CURRENT_USER\Software\SafeCrypt")
		$PasswordCreateSalt = ""
		For $i = 0 To 100 Step 1
			$PasswordCreateSalt = $PasswordCreateSalt & Chr(Random(32,126,1))
		Next
		While 1
			Local $Passwd = InputBox("Set password", "Enter your new password.", "", "*")
			If @error = 1 Then
				Exit
			EndIf
			Local $PasswdCheck = InputBox("Set password", "Retype your password.", "", "*")
			If @error = 1 Then
				Exit
			EndIf
			If Not $Passwd = $PasswdCheck Then
				MsgBox(16, "Error", "Passwords doesn't match")
			Else
				If StringLen($Passwd) <= 6 Then
					MsgBox(16,"Error", "Please choose a Password greater then 6")
				Else
					For $i = 0 To 3000 Step 1
						$Passwd = _Crypt_HashData($Passwd & $PasswordCreateSalt, $CALG_SHA1)
					Next
					RegWrite("HKEY_CURRENT_USER\Software\SafeCrypt", "PasswordHashed", "REG_SZ", $Passwd)
					RegWrite("HKEY_CURRENT_USER\Software\SafeCrypt", "Installed", "REG_DWORD", "1")
					RegWrite("HKEY_CURRENT_USER\Software\SafeCrypt", "Salt", "REG_SZ", $PasswordCreateSalt)
					MsgBox(64,"Congratulation", "Your new password is set!" & @CRLF & "Please Login, to begin the Magic")
					ExitLoop
				EndIf
			EndIf
		WEnd
	EndIf

	;Test Password for Correct
	While 1
		Local $Passwd = InputBox("Security Check", "Enter your password.", "", "*")
		$Password = $Passwd
		If @error = 1 Then
			Exit
		EndIf
		$PasswordSalt = RegRead("HKEY_CURRENT_USER\Software\SafeCrypt", "Salt")
		For $i = 0 To 3000 Step 1
			$Passwd = _Crypt_HashData($Passwd & $PasswordSalt, $CALG_SHA1)
		Next
		If $Passwd = RegRead("HKEY_CURRENT_USER\Software\SafeCrypt", "PasswordHashed") Then
			ExitLoop
		Else
			MsgBox(16,"Error", "Wrong password")
		EndIf
	WEnd
	return $Password
EndFunc