#Include %A_ScriptDir%\Addons\AHK controls.ahk
#Include %A_ScriptDir%\Addons\DisplayControl.ahk
#Include %A_ScriptDir%\Addons\Experiments.ahk
#Include %A_ScriptDir%\Addons\Specific_addon.ahk			; there must be changed paths to a specific files
#Include %A_ScriptDir%\Addons\ProcessSuspender.ahk
#Include %A_ScriptDir%\Addons\StringCaseProcessing.ahk
#Include %A_ScriptDir%\Addons\TrickForWindows.ahk
#Include %A_ScriptDir%\Addons\WinGrid.ahk


#!c::				Run, "C:\Windows\System32\calc.exe"										; Wib+Alt+C to run Calculator
#Del::				FileRecycleEmpty ; win + del 												; make trash empty
#q:: 				Run, "C:\Users\%A_UserName%\Downloads" 											; open Downloads folder
!#m:: 				Run, "C:\Windows\System32\magnify.exe"										; launch default ScreenMagnifier
>^Down::				Send, {Volume_Down 1}
>^Up::				Send, {Volume_Up 1}
>^Left::				Send, {XButton1}
>^Right::				Send, {XButton2}
^+!t::				Run, https://translate.google.com/?source=gtx#view=home&op=translate&sl=auto&tl=uk&text=%clipboard%
^+!g::				Run, https://google.com.ua/search?lr=-lang_ru&safe=off&q=%clipboard%
#Esc::				Send, {LCtrl down}{LShift down}{Esc}{LCtrl up}{LShift up}
RControl & Home::		Send !+{Esc}
RControl & End::		Send !{Esc}
#h::					Run cmd /c rundll32.exe powrprof.dll,SetSuspendState 0,1,0						; hibernate (or sleep if hiberntion off)
#j::					Run, "psshutdown.exe -d -t 0"												; sleep (even if hibernation on)
#k::					SendMessage,0x112,0xF170,2,,Program Manager	 								; turn off screen 

Pause::		
Suspend, Permit
{
	Send, #d
}
Return

LWin:: return

;LWin::
;{
	;LWinPressedStartTime := A_TickCount
	;KeyWait, LWin up, T0.5
	;LWinElapsedTime := A_TickCount - LWinPressedStartTime
	;If (LWinElapsedTime >= 200)
	;{
		;Return
	;}
	;Else
	;{
		;Send, {LWin}
		;Return
	;}
;}
;Return

ActivityImitation:
{
	Send, {F16}
	Sleep, 1000
	Send, {F13}
}
Return

^!+a::
^!+s::
Suspend, Permit
{
	MouseGetPos, X, Y
	IfInString, A_ThisHotkey, a
	{
		SetTimer, ActivityImitation, 900000
		SYS_ToolTipText = AI activated
		Suspend, Off
		WriteLog("Activity imitation started")
		If(FileExist(A_ScriptDir "\NiftyWindows_ai.png"))
			Menu,Tray,Icon,%A_ScriptDir%\NiftyWindows_ai.png, ,1 	; custom icon for script when imitated
	}
	IfInString, A_ThisHotkey, s
	{
		SetTimer, ActivityImitation, Off
		SYS_ToolTipText = AI disabled
		Suspend, On
		WriteLog("Activity imitation stoped")
		If(FileExist(A_ScriptDir "\NiftyWindows.png"))
			Menu,Tray,Icon,%A_ScriptDir%\NiftyWindows.png, ,1 	; custom icon for script
	}
	ToolTip, %SYS_ToolTipText%, X, Y
	Sleep, 1000
	ToolTip
}
Return

~sc029::
IfWinActive, ahk_class CabinetWClass
{
	Send, {LAlt down}{Up down}{LAlt up}{Up up}
}
Else
{
	Send, {`}
}
Return

Space::
SpacePressedStartTime := A_TickCount
KeyWait, Space, T0.5
SpaceElapsedTime := A_TickCount - SpacePressedStartTime
GetKeyState, RButtonState, RButton, P
If (SpaceElapsedTime >= 400)
	Return
Else
{
	If (RButtonState = "D")
		Send, {Media_Play_Pause}
	Else
		Send, {Space}
}
Return

Insert & Space::
Suspend, Permit
{
	If (BH_Space)
	{
		BH_Space := 0
		SYS_ToolTipText = BH DEactivated
	}
	Else
	{
		BH_Space := 1
		BH_Space_Delay := 1000
		BH_Space_StartSleep := 0
		SYS_ToolTipText = BH activated
	}
	SYS_ToolTipSeconds = 1.0
	Gosub, SYS_ToolTipShow
}
Return

BH_Space:
{
	If GetKeyState("Space", "P")
	{
		Send, {Blind}{Space}
		SetTimer, BH_Space, -%BH_Space_Delay%
	}
	Else
	{
		SetTimer, BH_Space, Off
	}
}
Return

If ( ( (SUS_WinMinMax = 0) or (SUS_WinW = A_ScreenWidth and SUS_WinH = A_ScreenHeight) ) and BH_Space and GetKeyState("Space", "P"))
{
	Insert & s::
	Suspend, Permit
	{
		If (BH_Space_StartSleep)
		{
			BH_Space_StartSleep := 0
			SYS_ToolTipText = BH delay removed
		}
		Else
		{
			BH_Space_StartSleep := 1
			SYS_ToolTipText = BH delay added - %BH_Space_Delay% ms
		}
		SYS_ToolTipSeconds = 1.0
		Gosub, SYS_ToolTipShow
		
	}
	Return
	
	Insert & 0::
	Insert & 1::
	Insert & 2::
	Insert & 3::
	Insert & 4::
	Insert & 5::
	Insert & 6::
	Insert & 7::
	Insert & 8::
	Insert & 9::
	Suspend, Permit
	{
		IfInString, A_ThisHotkey, 1
		BH_Space_Delay := 250
		IfInString, A_ThisHotkey, 2
		BH_Space_Delay := 400
		IfInString, A_ThisHotkey, 3
		BH_Space_Delay := 500
		IfInString, A_ThisHotkey, 4
		BH_Space_Delay := 600
		IfInString, A_ThisHotkey, 5
		BH_Space_Delay := 750
		IfInString, A_ThisHotkey, 6
		BH_Space_Delay := 800
		IfInString, A_ThisHotkey, 7
		BH_Space_Delay := 900
		IfInString, A_ThisHotkey, 8
		BH_Space_Delay := 1000
		IfInString, A_ThisHotkey, 9
		BH_Space_Delay := 1500
		IfInString, A_ThisHotkey, 0
		BH_Space_Delay := 3000
		
		BH_Space_StartSleep := 1
		SYS_ToolTipText = BH delay changed - %BH_Space_Delay% ms
		SYS_ToolTipSeconds = 1.0
		Gosub, SYS_ToolTipShow
	}
	Return
	
	
	*~$Space::
	Suspend, Permit
	WinGet, SUS_WinMinMax, MinMax, ahk_id %SUS_WinID%
	WinGetPos, SUS_WinX, SUS_WinY, SUS_WinW, SUS_WinH, ahk_id %SUS_WinID%
	If ( ( (SUS_WinMinMax = 0) and (SUS_WinX = 0 and SUS_WinY = 0) and (SUS_WinW = A_ScreenWidth and SUS_WinH = A_ScreenHeight) ) and BH_Space )
	{
		If (BH_Space_StartSleep)
			Sleep, BH_Space_Delay
		SetTimer, BH_Space, -0
	}
	Return
}
Return

^!F4::
Suspend, Permit
{
	WinKill, A
}
Return


>^>#e::
{
	RunWait , %comspec% /c  "taskkill /F /IM explorer.exe"
	RunWait , %comspec% /c  "start explorer.exe"
}
Return

;ScrollLock:
;{
;Send, {ScrollLock}
;If (GetKeyState("ScrollLock", "T"))
	;SYS_ToolTipText = ScrollLock ON
;Else If (not GetKeyState("ScrollLock", "T"))
	;SYS_ToolTipText = ScrollLock Off
;SYS_ToolTipSeconds = 0.5
;Gosub, SYS_ToolTipShow
;}
;Return
	;
;>^Delete::			Gosub, ScrollLock


#If GetKeyState("RButton", "P") ; True if RButton is pressed, false otherwise.
{
	F8:: 				SendMessage, 0x112, 0xF140, 0, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF140 is SC_SCREENSAVE
	F9::				DllCall("LockWorkStation")
	*w::				Up
	*a::				Left
	*s::				Down
	*d::				Right
	f::					^f
	*x:: 				^x
	*c:: 				^c
	*v:: 				^v
	*z:: 				^a
	;k::				Gosub, ScrollLock
	l::					SendMessage, 0x112, 0xF170, 2, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF170 is SC_MONITORPOWER ; (2 = off, 1 = standby, -1 = on)
	r::					^r
	q:: 				^z
	e:: 				^y
	Left::				#^LEFT
	Right::				#^RIGHT
	Up::				#^d
	Down::				#^F4
	Tab::				#Tab
	
	*RShift::
	{
		If (LongShiftState = 1)
		{
			Send, {Shift up}
			LongShiftState = 0
			SYS_ToolTipText = Long Shift Off
			SYS_ToolTipSeconds = 0.5
			Gosub, SYS_ToolTipShow
		}
		Else
		{
			Send, {Shift down}
			LongShiftState = 1
			SYS_ToolTipText = Long Shift ON
			SYS_ToolTipSeconds = 5
			Gosub, SYS_ToolTipShow
		}
	}
	Return
	
	*RCtrl::
	{
		If (LongControlState = 1)
		{
			Send, {Control up}
			LongControlState = 0
			SYS_ToolTipText = Long Ctr Off
			SYS_ToolTipSeconds = 0.5
			Gosub, SYS_ToolTipShow
		}
		Else
		{
			Send, {Control down}
			LongControlState = 1
			SYS_ToolTipText = Long Ctr ON
			SYS_ToolTipSeconds = 5
			Gosub, SYS_ToolTipShow
		}
	}
	Return
}
Return

^!NumpadDiv::
{
	Sleep, 2000
	WinGet, WinStyle, Style, A
	WinGet, WinEXStyle, EXStyle, A
	WinGet, WinID, ID, A
	WinGet, WinPID, PID, A
	WinGet, WinProcessName, ProcessName, A
	WinGet, WinMinMax, MinMax, A
	WinGetClass, WinClass, A
	
	MsgBox,  ProcessName:`n`t`t`t%WinProcessName%`nWinClass:`n`t`t`t%WinClass%`nID:`n`t`t`t%WinID%`nPID:`n`t`t`t%WinPID%`nMinMax:`n`t`t`t%WinMinMax%`nStyle:`n`t`t`t%WinStyle%`nEXStyle:`n`t`t`t%WinEXStyle%
}
Return

^+g::			; Google Search highlighted text
{
	Send, ^c
	Sleep, 50
	Run, http://www.google.com/search?q=%clipboard%
}
Return

!q::				; ability quickly set highlighted text to title mode (first letter in upper case) or lower case (depends on start case of word)
{
	StringCaseSense, On
	clipboard := ""  ; Start with empty clipboard to allow ClipWait to detect when the text has arrived.
	Send, ^c
	ClipWait
	ClipSaved0 := Clipboard
	ClipSaved :=  Trim(ClipSaved0)
	ClipFirstChar := SubStr(ClipSaved, 1, 1)
	ClipLastChar := SubStr(ClipSaved, 0)
	If  ( IsLower(ClipFirstChar) and IsLower(ClipLastChar) )
		StringUpper, OutputVar, ClipSaved0, T
	Else
		StringLower, OutputVar, ClipSaved0
	Clipboard := OutputVar
	Send, ^v
	StringCaseSense, Off
}
Return

<^<!0::
{
	Run, cmd.exe
}
Return

#h::			; Toggles hidden files in explorer
{
	ToggleHiddenFilesInExplorer()
}
Return

#y::			; Toggles file extensions in explorer
{
	TogglesFileExtensionsInExplorer()
}
Return

#f::			; Resize the colums in explorer
{
	FitColumnsSizeInExplorer()
}
Return

#w::			; Get current explorer window path in explorer
{
	GetActiveExplorerPath() 
}
Return