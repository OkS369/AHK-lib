!#h::																; open AHK help
Suspend, Permit
{		
	If WinExist("ahk_exe hh.exe") 
		WinActivate, ahk_exe hh.exe
	Else
		Run, "P:\Programs\AutoHotkey\AutoHotkey.chm"
}
Return

!#k::																; open AHK KeyHistory
Suspend, Permit
{		
	Run, "P:\Programs\AutoHotkey\MyLib\TestScripts\KeyHistory.ahk"
}
Return

!#w::																; open WindowSpy
Suspend, Permit
{		
	If WinExist("ahk_id 4280") 
		WinActivate, ahk_exe AutoHotkey.exe
	Else
		Run, "P:\Programs\AutoHotkey\WindowSpy.ahk"
}
Return

;!#Pause::																; Pressing once will pause the script. Pressing it again will unpause.
!^#p::																; Pressing once will pause the script. Pressing it again will unpause.
Suspend, Permit
{
Pause 													
}
Return

!^#r:: 																; to reload all AutoHotkey scripts
Suspend, Permit
{
ReloadAllAhkScripts() 
}
Return

!^#c:: 																; to close all AutoHotkey scripts
Suspend, Permit
{
CloseAllAhkScripts() 
}
Return

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

CloseAllAhkScripts() 
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
		PostMessage, 0x10,,,, % "ahk_id" . hwnd
	}
	Reload
}