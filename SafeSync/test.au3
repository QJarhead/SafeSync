#include <ComboConstants.au3>
#include <Crypt.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

$CryptPassword = "Geheim"
$PasswordSalt = "Test"
$Password = "GanzGeheim"


#cs
MsgBox(0,"",$CryptPassword)
$CryptPassword = _Crypt_EncryptData($CryptPassword & $PasswordSalt, $Password, $CALG_RC4)

MsgBox(0,"",$CryptPassword)
$CryptPassword = _Crypt_DecryptData($CryptPassword, $Password, $CALG_RC4)
MsgBox(0,"",$CryptPassword)
MsgBox(0,"",BinaryToString($CryptPassword))

#ce

$Crypt = CryptPassword("Teseagvrsgarwgt", "Sawzs645wh354blt")

MsgBox(0,"",$Crypt)
MsgBox(0,"",DecryptPassword($Crypt, "Sawzs645wh354blt"))

Func CryptPassword($CryptPassword, $PasswordSalt)
	$CryptPassword = _Crypt_EncryptData($CryptPassword & $PasswordSalt, $Password, $CALG_RC4)
	return $CryptPassword
EndFunc

Func DecryptPassword($CryptPassword, $PasswordSalt)
	Local $PasswordWithSalt = BinaryToString(_Crypt_DecryptData($CryptPassword, $Password, $CALG_RC4))
	return StringLeft(BinaryToString($PasswordWithSalt), StringLen($PasswordWithSalt) - StringLen($PasswordSalt))
EndFunc