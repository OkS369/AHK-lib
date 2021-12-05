;^!m:: 				Run, "B:\Programs\AutoHotkey\MyLib\Other\ScreenMagnifier.ahk"					; launch ScreenMagnifier

#b::					Run PowerShell.exe -windowstyle hidden -command D:\Scripts\bluetooth.ps1			; special script by this path

<^<!e::
{
	Run *RunAs "C:\Users\Roman\Desktop\Ярлики\Перезапустити Провідник.bat"
}
Return

<^<!9::
{
	Run, "D:\Programs\Windows TweakerS\W10T\Win 10 Tweaker.exe"
}
Return

^!q::
{
	If (FanState = 0)
	{
		Run *RunAs "C:\Program Files (x86)\NoteBook FanControl\Fan_auto.bat.lnk",, hide
		FanState = 1
		SYS_ToolTipText = Fan in auto mode
	}
	Else If (FanState = 1)
	{
		Run *RunAs "C:\Program Files (x86)\NoteBook FanControl\Fan_stop.bat.lnk",, hide
		FanState = 0
		SYS_ToolTipText = Fan control is stopped
	}
	Else
	{
		Run *RunAs "C:\Program Files (x86)\NoteBook FanControl\Fan_auto.bat.lnk",, hide
		FanState = 1
		SYS_ToolTipText = Fan in auto mode
	}
	SYS_ToolTipSeconds = 2.0
	Gosub, SYS_ToolTipShow
}
Return

; power profile id, nvidiaInspector shortcut, hotkey from ThrottleStop
<^>!F9::
<^>!F10::
{
	IfInString A_ThisHotkey, F10
	{
		ToolTip, Game mode off
		Run, powercfg.exe /setactive 711c9d8a-4c12-46ac-b696-8392ba1a0f2f
		Send, {LControl down}{RAlt down}{LShift down}9{LShift up}{LControl up}{RAlt up}
		Sleep, 1000
		ToolTip
	}
	IfInString A_ThisHotkey, F9
	{
		ToolTip, Game mode on
		Run, "C:\Users\Roman\Desktop\NVI_0_3_200_1000_94_0.lnk",, Min
		Run, powercfg.exe /setactive e1d7b4fb-5fe3-4a33-b376-f563838b414c
		Send, {LControl down}{LAlt down}{LShift down}0{LControl up}{LAlt up}{LShift up}
		Sleep, 1000
		ToolTip
	}
}
Return

; JetBoost app
^!b::    
Run, "B:\Programs\JetBoost\JetBoost.exe" -game

; LenovoUtility
LenovoUtility:
>+F12::
{
;WinGet, PID_of_Lenovo_Utility, PID, ahk_exe utility.exe 
	Process, Exist, utility.exe
	If (ErrorLevel)
		Process, Close, utility.exe
	Else
		Run, "D:\My Workplace\   \ Усі програми\LenovoUtility.lnk"
}
Return