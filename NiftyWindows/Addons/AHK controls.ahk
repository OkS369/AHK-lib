!#h::																; open AHK help
{		
	If WinExist("ahk_exe hh.exe") 
		WinActivate, ahk_exe hh.exe
	Else
		Run, "D:\Programs\AutoHotkey\AutoHotkey.chm"
}
Return

!#k::																; open AHK KeyHistory
{		
	Run, "D:\Programs\AutoHotkey\MyLib\TestScripts\KeyHistory.ahk"
}
Return

!#w::																; open WindowSpy
{		
	If WinExist("ahk_id 4280") 
		WinActivate, ahk_exe AutoHotkey.exe
	Else
		Run, "D:\Programs\AutoHotkey\WindowSpy.ahk"
}
Return

!#Pause::		Pause 													; Pressing Alt+ Pause (Fn+P) once will pause the script. Pressing it again will unpause.

!#r:: ReloadAllAhkScripts() 												; Press CapsLock and Numpad2 to reload all AutoHotkey scripts

!#j::	Run, "D:\Programs\AutoHotkey\AHK-Studio-master\AHK-Studio.ahk"			; Wib+Alt+J to launch AHK-Studio



ReloadAllAhkScripts() 
{
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	WinGet, allAhkExe, List, ahk_class AutoHotkey
	Loop, % allAhkExe {
		hwnd := allAhkExe%A_Index%
		if (hwnd = A_ScriptHwnd)  		; ignore the current window for reloading
		{
			continue
		}
		PostMessage, 0x111, 65303,,, % "ahk_id" . hwnd
	}
	Reload
}