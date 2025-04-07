XButton1::	; short press to use XButton1 / short press while space down to use Media_Prev / long press and hold to emulate Control down
XButton1PressedStartTime := A_TickCount
If ( NWD_ImmediateDown )
	Return
GetKeyState, XB1_SpaceState, Space, P
GetKeyState, XB1_XButton1State, XButton1, P
ControlUsed = 0
While ( (XB1_XButton1State = "D") )
{
	GetKeyState, XB1_XButton1State, XButton1, P
	If (XB1_XButton1State = "U")
	{
		XButton1UnPressedElapsedTime := A_TickCount - XButton1PressedStartTime
		If ( XButton1UnPressedElapsedTime < 350 )
		{
			If (XB1_SpaceState = "D")
				Send, {Media_Prev}
			Else
				Send, {XButton1}
		}
		Break
	}
	Else If (XB1_XButton1State = "D")
	{
		GetKeyState, XB1_CtrlState, LControl
		XButton1PressedElapsedTime := A_TickCount - XButton1PressedStartTime
		If ( (XB1_CtrlState = "U") and (XButton1PressedElapsedTime > 700) and (ControlUsed != 1) )
		{
			Send, {LControl down}
			ControlUsed = 1
		}
	}
}
If (ControlUsed = 1)
{
	Send, {LControl up}
	ControlUsed = 0
}
Return
!XButton1::		Send, {Delete}
^XButton1::		Send, {End}
^+XButton1::	Send, {LControl down}{End}{LControl up}	; end of file/page
^#XButton1::	Send, #^{RIGHT}	; next virtual desktop
!#XButton1::	win_align_with_grid(1, 1, 1, 2, ByRef HWND)
+XButton1::		; send PgDn with interval while Shift and XButton1 psessed
{
	
	SleepTime = 300
	GetKeyState, XB1_XButton1State, XButton1, P
	While ( (XB1_XButton1State = "D") )
	{
		Send, {PgDn}
		Sleep, %SleepTime%
		GetKeyState, XB1_XButton1State, XButton1, P
		If (XB1_XButton1State = "U")
			Break
		Else
			SleepTime = 50
	}
}
Return
Hotkey, XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, ^XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, +XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, !XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, ^+XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, !#XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, ^#XButton1, %CFG_FourthMouseButtonHookStr%


!XButton2::		Send, {Backspace}
^XButton2::		Send, {Home}
^+XButton2::	Send, {LControl down}{Home}{LControl up}	; start of file/page
^#XButton2::	Send,#^{LEFT}	; prev virtual desktop
!#XButton2::	win_align_with_grid(-1, -1, 1, 2, ByRef HWND)
XButton2::		; short press to use XButton2 / short press while space down to use Media_Next / long press and hold to emulate Shift down
{
	XButton2PressedStartTime := A_TickCount
	If ( NWD_ImmediateDown )
		Return
	GetKeyState, XB2_SpaceState, Space, P
	GetKeyState, XB2_XButton2State, XButton2, P
	ShiftUsed = 0
	While ( (XB2_XButton2State = "D") )
	{
		GetKeyState, XB2_XButton2State, XButton2, P
		If (XB2_XButton2State = "U")
		{
			XButton2UnPressedElapsedTime := A_TickCount - XButton2PressedStartTime
			If ( XButton2UnPressedElapsedTime < 350 )
			{
				If (XB2_SpaceState = "D")
					Send, {Media_Next}
				Else
					Send, {XButton2}
			}
			Break
		}
		Else If (XB2_XButton2State = "D")
		{
			GetKeyState, XB2_ShiftState, Shift
			XButton2PressedElapsedTime := A_TickCount - XButton2PressedStartTime
			If ( (XB2_ShiftState = "U") and (XButton2PressedElapsedTime > 700) and (ShiftUsed != 1) )
			{
				Send, {Shift down}
				ShiftUsed = 1
			}
		}
	}
	If (ShiftUsed = 1)
	{
		Send, {Shift up}
		ShiftUsed = 0
	}
}
Return
+XButton2::
{
	; send PgDn with interval while Shift and XButton1 psessed
	SleepTime = 300
	GetKeyState, XB2_XButton2State, XButton2, P
	While ( (XB2_XButton2State == "D") )
	{
		Send, {PgUp}
		Sleep, %SleepTime%
		GetKeyState, XB2_XButton2State, XButton2, P
		If (XB2_XButton2State == "U")
			Break
		Else
			SleepTime = 50
	}
}
Return
Hotkey, XButton2, %CFG_FifthMouseButtonHook%
Hotkey, ^XButton2, %CFG_FifthMouseButtonHook%
Hotkey, +XButton2, %CFG_FifthMouseButtonHook%
Hotkey, ^+XButton2, %CFG_FifthMouseButtonHook%
Hotkey, ^#XButton2, %CFG_FifthMouseButtonHook%
Hotkey, !#XButton2, %CFG_FifthMouseButtonHook%
Hotkey, !XButton2, %CFG_FifthMouseButtonHook%


<#WheelDown::		Send, {LWin down}{LControl down}{PgDn}{LWin up}{LControl up}
<#<+WheelDown::		Send, {LWin down}{LShift down}{RIGHT}{LWin up}{LShift up}
<#<^WheelDown::		Send, {LWin down}{LControl down}{RIGHT}{LWin up}{LControl up}
<#<!WheelDown::		win_align_with_grid(0, +1, 0, 2, ByRef HWND)
<#<^<!WheelDown::	win_align_with_grid(+1, 0, 0, 2, ByRef HWND)
Hotkey, <#WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#<+WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#<^WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#<!WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#<^<!WheelDown, %CFG_WheelDownMouseButtonHookStr%