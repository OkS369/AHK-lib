#SingleInstance force
#NoTrayIcon

^Numpad1:: 
{
	Run "D:\Google Drive\Code\Python\My collection\fix text from another language\change_layout.py"
	Sleep 100
	WinActivate, ahk_exe py.exe
	Sleep 10
	Send {1}{Enter}
	Sleep 10
	SendInput ^v
	Send {Enter}
	WinActivate, ahk_exe py.exe
	Sleep 10
	Send ^a
	Send ^c
	Send !F4
}
Return

^Numpad2:: 
{
	Run "D:\Google Drive\Code\Python\My collection\fix text from another language\change_layout.py"
	Sleep 100
	WinActivate, ahk_exe py.exe
	Sleep 10
	Send {2}{Enter}
	Sleep 10
	SendInput ^v
	Send {Enter}
	WinActivate, ahk_exe py.exe
	Sleep 10
	Send ^a
	Send ^c
	Send !F4
}
Return


