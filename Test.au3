If FileExists("C:\Users\lid\AppData\Roaming\SafeCrypt\Test.7z") Then
	FileDelete("C:\Users\lid\AppData\Roaming\SafeCrypt\Test.7z")
EndIf
Run("C:\Users\lid\AppData\Roaming\SafeCrypt\7z.exe a -t7z C:\Users\lid\AppData\Roaming\SafeCrypt\Test.7z C:\Users\lid\AppData\Roaming\SafeCrypt\Test.txt -y > null")