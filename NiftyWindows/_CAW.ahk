; [MIW {NWD}] minimize/roll on right + left mouse button

/**
	* Minimizes the selected window (if minimizable) to the task bar. If you press
	* the left button over the titlebar the selected window will be rolled up
	* instead of being minimized. You have to apply this action again to roll the
	* window back down.
*/

LButton::
^LButton::
GetKeyState, MIW_RButtonState, RButton, P
WinGet, NWD_WinID, ID, A
WinGet,  NWD_WinStyle, Style, A
WinGet, NWD_WinProcessName, ProcessName, A
WinGetClass, NWD_WinClass, ahk_id %NWD_WinID%
If ( (MIW_RButtonState = "U") or (NWD_WinClass = "Progman") )
{
	;Thread, Priority, 2147483647
	;Thread, Interrupt, -1
	;Critical
	Click, LEFT, D
	SetTimer, LButtonHandler, 10
}
Else If ( (MIW_RButtonState = "D") and (!NWD_ImmediateDown) and (NWD_WinClass != "Progman") )
{
	GetKeyState, MIW_CtrlState, Ctrl, P
	WinGet, MIW_WinStyle, Style, ahk_id %NWD_WinID%
	SysGet, MIW_CaptionHeight, 4 ; SM_CYCAPTION
	SysGet, MIW_BorderHeight, 7 ; SM_CXDLGFRAME
	MouseGetPos, , MIW_MouseY
	
	If ( (MIW_MouseY - 10) <= (MIW_CaptionHeight + MIW_BorderHeight) )
	{
			; checks wheter the window has a sizing border (WS_THICKFRAME)
		If ( (MIW_CtrlState = "D") or (MIW_WinStyle & 0x40000) )
		{
			Gosub, NWD_SetAllOff
			ROL_WinID = %NWD_WinID%
			Gosub, ROL_RollToggle
		}
	}
	Else
	{
		If ( (MIW_CtrlState = "D") or (MIW_WinStyle & 0xCA0000 = 0xCA0000) or (NWD_WinStyle = "Chrome_WidgetWin_1")  or  (NWD_WinProcessName = "Discord.exe"))
		{
			Gosub, NWD_SetAllOff
			WinGet, LastApp_ID, ID, A
			WinMinimize, ahk_id %NWD_WinID%
			SYS_ToolTipText = Window Minimized
			SYS_ToolTipSeconds = 0.5
			Gosub, SYS_ToolTipFeedbackShow
		}
	}
}
Return

Hotkey, $LButton, %CFG_LeftMouseButtonHookStr%
Hotkey, $^LButton, %CFG_LeftMouseButtonHookStr%

; [CLW {NWD}] close/send bottom on right + middle mouse button || double click on middle mouse button

/**
	* Closes the selected window (if closeable) as if you click the close button
	* in the titlebar. If you press the middle button over the titlebar the
	* selected window will be sent to the bottom of the window stack instead of
	* being closed.
*/

MButton::
^MButton::
GetKeyState, CLW_RButtonState, RButton, P
GetKeyState, CLW_SpaceState, Space, P
WinGet, NWD_WinID, ID, A
WinGet,  NWD_WinStyle, Style, A
WinGet, NWD_WinProcessName, ProcessName, A
WinGetClass, NWD_WinClass, ahk_id %NWD_WinID%
If ( (CLW_RButtonState = "D") and (!NWD_ImmediateDown) and (NWD_WinClass != "Progman") )
{
	GetKeyState, CLW_CtrlState, Ctrl, P
	WinGet, CLW_WinStyle, Style, ahk_id %NWD_WinID%
	SysGet, CLW_CaptionHeight, 4 ; SM_CYCAPTION
	SysGet, CLW_BorderHeight, 7 ; SM_CXDLGFRAME
	MouseGetPos, , CLW_MouseY
	
	If ( CLW_MouseY <= CLW_CaptionHeight + CLW_BorderHeight ) and (CLW_SpaceState = "U")
	{
		Gosub, NWD_SetAllOff
		Send, !{Esc}
		SYS_ToolTipText = Window Check
		Gosub, SYS_ToolTipFeedbackShow
	}
	Else
	{
			; the second condition checks for closeable window:
			; (WS_CAPTION | WS_SYSMENU)
		If ( (CLW_CtrlState = "D") or (CLW_WinStyle & 0xC80000 = 0xC80000)  or (NWD_WinStyle = "Chrome_WidgetWin_1")  or  (NWD_WinProcessName = "Discord.exe") )
		{
			Gosub, NWD_SetAllOff
			WinClose, ahk_id %NWD_WinID%
			SYS_ToolTipText = Window Close
			Gosub, SYS_ToolTipFeedbackShow
		}
	}
}
Else
{
	If (CLW_SpaceState = "D")
		Send, {Volume_Mute}
	Else
		Send, {MButton}
}
Return

Hotkey, #MButton, %CFG_MiddleMouseButtonHookStr%
Hotkey, #^MButton, %CFG_MiddleMouseButtonHookStr%

$XButton1::
$^XButton1::
$+XButton1::
$^+XButton1::
$!XButton1::
$#XButton1::
$!#XButton1::
$^#XButton1::
XButton1PressedStartTime := A_TickCount
If ( NWD_ImmediateDown )
	Return
GetKeyState, XB1_RButtonState, RButton, P
GetKeyState, XB1_CtrlState, LControl, P
GetKeyState, XB1_ShiftState, LShift, P
GetKeyState, XB1_AltState, LAlt, P
GetKeyState, XB1_WinState, LWin, P
GetKeyState, XB1_SpaceState, Space, P
ControlUsed = 0
If ( XB1_RButtonState = "U" )
{
	If ( (XB1_CtrlState = "U") and (XB1_ShiftState = "U") and (XB1_AltState = "U") and (XB1_WinState = "U") )
	{
		GetKeyState, XB1_XButton1State, XButton1, P
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
	}
	Else If ( (XB1_CtrlState = "U") and (XB1_ShiftState = "U") and (XB1_AltState = "D") and (XB1_WinState = "U") )
	{
		Send, {Delete}
	}
	Else If ( (XB1_CtrlState = "U") and (XB1_ShiftState = "D") and (XB1_AltState = "U") and (XB1_WinState = "U") )
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
	Else If  ( (XB1_CtrlState = "D") and (XB1_ShiftState = "U") and (XB1_AltState = "U") and (XB1_WinState = "U") )
	{
		Send, {End}
	}
	Else If  ( (XB1_CtrlState = "D") and (XB1_ShiftState = "D") and (XB1_AltState = "U") and (XB1_WinState = "U") )
	{
		Send, {LControl down}{End}{LControl up}
	}
	Else If  ( (XB1_CtrlState = "U") and (XB1_ShiftState = "U") and (XB1_AltState = "U") and (XB1_WinState = "D") )
	{
		Send, #^{RIGHT}
	}
	Else If ( (XB1_CtrlState = "U") and (XB1_ShiftState = "U") and (XB1_AltState = "D") and (XB1_WinState = "D") )
	{
		win_align_with_grid(0, +1, 1, 2, ByRef HWND)
	}
	Else If ( (XB1_CtrlState = "D") and (XB1_ShiftState = "U") and (XB1_AltState = "U") and (XB1_WinState = "D") )
	{
		win_align_with_grid(+1, 0, 1, 2, ByRef HWND)
	}
}
Else If ( XB1_RButtonState = "D" )
{
	IfWinActive, A
	{
		WinGet, XB1_WinID, ID
		If ( !XB1_WinID )
			Return
		WinGetClass, XB1_WinClass, ahk_id %XB1_WinID%
		If ( XB1_WinClass = "Progman" ) or ( XB1_WinClass = "WorkerW" )
		{
			WinMinimizeAllUndo
			;Send, #+m
			ShowDesktopFeatureUsed = 1
			WinGetClass, XB1_WinClass, ahk_id %XB1_WinID%
			If ( XB1_WinClass = "Progman" ) or ( XB1_WinClass = "WorkerW" )
				Send, !{Tab}
			SYS_ToolTipText = All Minimized Windows Unminimized
			Gosub, SYS_ToolTipFeedbackShow
		}
		Else
		{
			Gosub, NWD_SetAllOff
			;WinGet, LastApp_ID, ID, A
			WinMinimizeAll
			;Send, #m
			SYS_ToolTipText = All Windows Minimized
			Gosub, SYS_ToolTipFeedbackShow
		}
	}
	Else
	{
		Send, ^!{Tab}
	}
}
Return

Hotkey, $XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, $^XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, $+XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, $^+XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, $!XButton1, %CFG_FourthMouseButtonHookStr%
Hotkey, $#XButton1, %CFG_FourthMouseButtonHookStr%

; [MAW {NWD}] Maximize Active Window
$XButton2::
$^XButton2::
$+XButton2::
$^+XButton2::
$!XButton2::
$#XButton2::
$!#XButton2::
$^#XButton2::
XButton2PressedStartTime := A_TickCount
If ( NWD_ImmediateDown )
	Return
GetKeyState, XB2_RButtonState, RButton, P
GetKeyState, XB2_ShiftState, LShift, P
GetKeyState, XB2_CtrlState, LControl, P
GetKeyState, XB2_AltState, LAlt, P
GetKeyState, XB2_WinState, LWin, P
GetKeyState, XB2_WheelUpState, WheelUp, P
GetKeyState, XB2_WheelDownState, WheelDown, P
GetKeyState, XB2_SpaceState, Space, P
ShiftUsed = 0
If ( XB2_RButtonState = "U" )
{
	If ( (XB2_CtrlState = "U") and (XB2_ShiftState = "U") and (XB2_AltState = "U") and (XB2_WinState = "U") )
	{
		GetKeyState, XB2_XButton2State, XButton2, P
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
	Else If ( (XB2_CtrlState = "U") and (XB2_ShiftState = "U") and (XB2_AltState = "D") and (XB2_WinState = "U") )
	{
		Send, {Backspace}
	}
	Else If ( (XB2_CtrlState = "U") and (XB2_ShiftState = "D") and (XB2_AltState = "U") and (XB2_WinState = "U") )
	{
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
	Else If ( (XB2_CtrlState = "D") and (XB2_ShiftState = "U") and (XB2_AltState = "U") and (XB2_WinState = "U") )
	{
		Send, {Home}
	}
	Else If ( (XB2_CtrlState = "D") and (XB2_ShiftState = "D") and (XB2_AltState = "U") and (XB2_WinState = "U") )
	{
		Send, {LControl down}{Home}{LControl up}
	}
	Else If ( (XB2_CtrlState = "U") and (XB2_ShiftState = "U") and (XB2_AltState = "U") and (XB2_WinState = "D") )
	{
		Send,#^{LEFT}
	}
	Else If ( (XB2_CtrlState = "U") and (XB2_ShiftState = "U") and (XB2_AltState = "D") and (XB2_WinState = "D") )
	{
		win_align_with_grid(0, -1, 1, 2, ByRef HWND)
	}
	Else If ( (XB2_CtrlState = "D") and (XB2_ShiftState = "U") and (XB2_AltState = "U") and (XB2_WinState = "D") )
	{
		win_align_with_grid(-1, 0, 1, 2, ByRef HWND)
	}
}
Else If ( XB2_RButtonState = "D" )
{
	IfWinActive, A
	{
		WinGet, XB2_WinID, ID
		If ( !XB2_WinID )
			Return
		WinGetClass, XB2_WinClass, ahk_id %XB2_WinID%
		If ( (XB2_WinClass != "Progman") and (XB2_WinClass != "WorkerW") and (XB2_WinClass != "Shell_TrayWnd") and (XB2_WinClass != "tooltips_class32") )
		{
			Gosub, NWD_SetAllOff
			
			WinGet, XB2_MinMax, MinMax, A
					;MsgBox %XB2_MinMax% %XB2_WinClass%
			If ( XB2_MinMax = 0 )
			{
				WinMaximize
				SYS_ToolTipText = Window Maximized
				Gosub, SYS_ToolTipFeedbackShow
			}
			Else If ( XB2_MinMax = 1 )
			{
				WinRestore
				SYS_ToolTipText = Window Restored
				Gosub, SYS_ToolTipFeedbackShow
			}
		}
		Else
		{
			If (!WinExist(%LastApp_ID%)) or (ShowDesktopFeatureUsed = 1) or ((XB2_WinClass = "Progman") or (XB2_WinClass = "WorkerW") or (XB2_WinClass = "AutoHotkeyGUI") or (XB2_WinClass = "Static"))
			{
				SYS_ToolTipText = Last app unknown. Can not to restore.
				ShowDesktopFeatureUsed = 0
				Send, ^!{Tab}
			}
			Else
			{
				WinRestore, ahk_id %LastApp_ID%
				SYS_ToolTipText = Minimized Window Restored
			}
			Gosub, SYS_ToolTipFeedbackShow
		}
	}
}
Return

Hotkey, $XButton2, %CFG_FifthMouseButtonHook%
Hotkey, $^XButton2, %CFG_FifthMouseButtonHook%
Hotkey, $+XButton2, %CFG_FifthMouseButtonHook%
Hotkey, $^+XButton2, %CFG_FifthMouseButtonHook%
Hotkey, $!XButton2, %CFG_FifthMouseButtonHook%
Hotkey, $#XButton2, %CFG_FifthMouseButtonHook%

; [TSW {NWD}] provides alt-tab-menu to the right mouse button + mouse wheel

/**
	* Provides a quick task switcher (alt-tab-menu) controlled by the mouse wheel.
*/

WheelDown::
<+WheelDown::
<^WheelDown::
<!WheelDown::
<#WheelDown::
<#<+WheelDown::
<#<^WheelDown::
<#<!WheelDown::
<#<^<!WheelDown::
GetKeyState, MWD_RButtonState, RButton, P
GetKeyState, MWD_XButton1State, XButton1, P
GetKeyState, MWD_XButton2State, XButton2, P
GetKeyState, MWD_LAltState, LAlt, P
GetKeyState, MWD_LShiftState, LShift, P
GetKeyState, MWD_LCtrState, LControl, P
GetKeyState, MWD_LWinState, LWin, P
GetKeyState, MWD_SpaceState, Space, P
If ( ((MWD_LAltState = "D") and (MWD_LWinState = "U")) or ((MWD_RButtonState = "D") and (!NWD_ImmediateDown)) )
{
	GetKeyState, MWD_AltState, Alt
	If ( MWD_AltState = "U" or FirstUseOfAltTAbByWheelAndLAlt != 1)
	{
		Gosub, NWD_SetAllOff
		Send, {LAlt down}{Tab}
		SetTimer, MW_WheelHandler, 100
	}
	Else
		Send, {Tab}
}
Else
{
	If  (MWD_LWinState = "D")
	{
		If (MWD_LShiftState = "U" and MWD_LCtrState = "D" and MWD_LAltState = "D")
			win_align_with_grid(+1, 0, 0, 2, ByRef HWND)
		Else If (MWD_LShiftState = "U" and MWD_LCtrState = "U" and MWD_LAltState = "D")
			win_align_with_grid(0, +1, 0, 2, ByRef HWND)
		Else If (MWD_LShiftState = "U" and MWD_LCtrState = "D" and MWD_LAltState = "U")
			Send, {LWin down}{LControl down}{PgDn}{LWin up}{LControl up}
		Else If (MWD_LShiftState = "D" and MWD_LCtrState = "U" and MWD_LAltState = "U")
			Send, {LWin down}{LShift down}{RIGHT}{LWin up}{LShift up}
		Else
			Send, {LWin down}{LControl down}{PgDn}{LWin up}{LControl up}
	}

	Else If ( (MWD_XButton1State = "D") or (MWD_LCtrState = "D") )
	{
		GetKeyState, MWD_CtrState, Alt
		If ( MWD_CtrState = "U" or FirstUseOfCtrTAbByWheel != 1)
		{
			Gosub, NWD_SetAllOff
			Send, {LControl down}{Tab}
			SetTimer, MW_WheelHandler, 100
		}
		Else
			Send, {Tab}
	}
	Else If ( (MWD_XButton2State = "D") or (MWD_LShiftState = "D") )
		Send, {LShift up}{PgDn}
	
	Else If (MWD_SpaceState = "D")
		Send, {Volume_Down}
	Else
		Send, {WheelDown}
}
Return


Hotkey, WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <+WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <^WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <!WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#<+WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#<^WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#<!WheelDown, %CFG_WheelDownMouseButtonHookStr%
Hotkey, <#<^<!WheelDown, %CFG_WheelDownMouseButtonHookStr%


WheelUp::
<+WheelUp::
<^WheelUp::
<!WheelUp::
<#WheelUp::
<#<+WheelUp::
<#<^WheelUp::
<#<!WheelUp::
<#<^<!WheelUp::
GetKeyState, MWU_RButtonState, RButton, P
GetKeyState, MWU_XButton1State, XButton1, P
GetKeyState, MWU_XButton2State, XButton2, P
GetKeyState, MWU_LAltState, LAlt, P
GetKeyState, MWU_LShiftState, LShift, P
GetKeyState, MWU_LCtrState, LControl, P
GetKeyState, MWU_LWinState, LWin, P
GetKeyState, MWU_SpaceState, Space, P
If ( ((MWU_LAltState = "D")  and (MWU_LWinState = "U"))  or ((MWU_RButtonState = "D") and (!NWD_ImmediateDown)) )
{
	GetKeyState, MWU_AltState, Alt
	If ( MWU_AltState = "U" or FirstUseOfAltTAbByWheelAndLAlt != 1)
	{
		Gosub, NWD_SetAllOff
		Send, {LAlt down}+{Tab}
		SetTimer, MW_WheelHandler, 1000
	}
	Else
		Send, +{Tab}
}
Else
{
	If  (MWU_LWinState = "D")
	{
		If (MWU_LShiftState = "U" and MWU_LCtrState = "D" and MWU_LAltState = "D")
			win_align_with_grid(-1, 0, 0, 2, ByRef HWND)
		Else If (MWU_LShiftState = "U" and MWU_LCtrState = "U" and MWU_LAltState = "D")
			win_align_with_grid(0, -1, 0, 2, ByRef HWND)
		Else If (MWU_LShiftState = "U" and MWU_LCtrState = "D" and MWU_LAltState = "U")
			Send, {LWin down}{LControl down}{LEFT}{LWin up}{LControl up}
		Else If (MWU_LShiftState = "D" and MWU_LCtrState = "U" and MWU_LAltState = "U")
			Send, {LWin down}{LShift down}{LEFT}{LWin up}{LShift up}
		Else
			Send, {LWin down}{LControl down}{PgUp}{LWin up}{LControl up}
	}
	Else If ( (MWU_XButton1State = "D") or (MWU_LCtrState = "D") )
	{
		GetKeyState, MWU_CtrState, Alt
		If ( MWU_CtrState = "U" or FirstUseOfCtrTAbByWheel != 1)
		{
			Gosub, NWD_SetAllOff
			Send, {LControl down}+{Tab}
			SetTimer, MW_WheelHandler, 1000
		}
		Else
			Send, {LShift down}{Tab}{LShift up}
	}
	Else If ( (MWU_XButton2State = "D") or (MWU_LShiftState = "D") )
		Send, {LShift up}{PgUp}
	Else If (MWU_SpaceState = "D")
		Send, {Volume_Up}
	Else
		Send, {WheelUp}
}
Return

MW_WheelHandler:
GetKeyState, MW_RButtonState, RButton, P
GetKeyState, MW_LAltState, LAlt, P
GetKeyState, MW_XButton1State, XButton1, P
GetKeyState, MW_LCtrState, LControl, P
If ( MW_RButtonState = "U" and MW_LAltState = "U" and MW_XButton1State = "U" and MW_LCtrState = "U")
{
	SetTimer, MW_WheelHandler, Off
	FirstUseOfAltTAbByWheelAndLAlt = 0
	FirstUseOfCtrTAbByWheel = 0
	GetKeyState, MW_AltState, Alt
	If ( MW_AltState = "D" )
		Send, {Alt up}
	GetKeyState, MW_CtrState, Control
	If ( MW_CtrState = "D" )
		Send, {Control up}
}
Return

Hotkey, WheelUp, %CFG_WheelUpMouseButtonHookStr%
Hotkey, <+WheelUp, %CFG_WheelUpMouseButtonHookStr%
Hotkey, <^WheelUp, %CFG_WheelUpMouseButtonHookStr%
Hotkey, <!WheelUp, %CFG_WheelUpMouseButtonHookStr%
Hotkey, <#WheelUp, %CFG_WheelUpMouseButtonHookStr%
Hotkey, <#<+WheelUp, %CFG_WheelUpMouseButtonHookStr%
Hotkey, <#<^WheelUp, %CFG_WheelUpMouseButtonHookStr%
Hotkey, <#<!WheelUp, %CFG_WheelUpMouseButtonHookStr%
Hotkey, <#<^<!WheelUp, %CFG_WheelUpMouseButtonHookStr%

; [ROL] rolls up/down a window to/from its title bar

ROL_RollToggle:
Gosub, ROL_CheckWinIDs
SetWinDelay, -1
IfWinNotExist, ahk_id %ROL_WinID%
	Return
WinGetClass, ROL_WinClass, ahk_id %ROL_WinID%
If ( ROL_WinClass = "Progman" )
	Return

IfNotInString, ROL_WinIDs, |%ROL_WinID%
{
	SYS_ToolTipText = Window Roll: UP
	Gosub, ROL_RollUp
}
Else
{
	WinGetPos, , , , ROL_WinHeight, ahk_id %ROL_WinID%
	If ( ROL_WinHeight = ROL_WinRolledHeight%ROL_WinID% )
	{
		SYS_ToolTipText = Window Roll: DOWN
		Gosub, ROL_RollDown
	}
	Else
	{
		SYS_ToolTipText = Window Roll: UP
		Gosub, ROL_RollUp
	}
}
Gosub, SYS_ToolTipFeedbackShow
Return

ROL_RollUp:
Gosub, ROL_CheckWinIDs
SetWinDelay, -1
IfWinNotExist, ahk_id %ROL_WinID%
	Return
WinGetClass, ROL_WinClass, ahk_id %ROL_WinID%
If ( ROL_WinClass = "Progman" )
	Return

WinGetPos, , , , ROL_WinHeight, ahk_id %ROL_WinID%
IfInString, ROL_WinIDs, |%ROL_WinID%
If ( ROL_WinHeight = ROL_WinRolledHeight%ROL_WinID% )
	Return
SysGet, ROL_CaptionHeight, 4 ; SM_CYCAPTION
SysGet, ROL_BorderHeight, 7 ; SM_CXDLGFRAME
If ( ROL_WinHeight > (ROL_CaptionHeight + ROL_BorderHeight) )
{
	IfNotInString, ROL_WinIDs, |%ROL_WinID%
		ROL_WinIDs = %ROL_WinIDs%|%ROL_WinID%
	ROL_WinOriginalHeight%ROL_WinID% := ROL_WinHeight
	WinMove, ahk_id %ROL_WinID%, , , , , (ROL_CaptionHeight + ROL_BorderHeight)
	WinGetPos, , , , ROL_WinRolledHeight%ROL_WinID%, ahk_id %ROL_WinID%
}
Return

ROL_RollDown:
Gosub, ROL_CheckWinIDs
SetWinDelay, -1
If ( !ROL_WinID )
	Return
IfNotInString, ROL_WinIDs, |%ROL_WinID%
	Return
WinGetPos, , , , ROL_WinHeight, ahk_id %ROL_WinID%
If( ROL_WinHeight = ROL_WinRolledHeight%ROL_WinID% )
	WinMove, ahk_id %ROL_WinID%, , , , , ROL_WinOriginalHeight%ROL_WinID%
StringReplace, ROL_WinIDs, ROL_WinIDs, |%ROL_WinID%, , All
ROL_WinOriginalHeight%ROL_WinID% =
ROL_WinRolledHeight%ROL_WinID% =
Return

ROL_RollDownAll:
Gosub, ROL_CheckWinIDs
Loop, Parse, ROL_WinIDs, |
	If ( A_LoopField )
	{
		ROL_WinID = %A_LoopField%
		Gosub, ROL_RollDown
	}
Return

#^r::
Gosub, ROL_RollDownAll
SYS_ToolTipText = Window Roll: ALL DOWN
Gosub, SYS_ToolTipFeedbackShow
Return

ROL_CheckWinIDs:
DetectHiddenWindows, On
Loop, Parse, ROL_WinIDs, |
	If ( A_LoopField )
		IfWinNotExist, ahk_id %A_LoopField%
		{
			StringReplace, ROL_WinIDs, ROL_WinIDs, |%A_LoopField%, , All
			ROL_WinOriginalHeight%A_LoopField% =
			ROL_WinRolledHeight%A_LoopField% =
}
Return

ROL_ExitHandler:
Gosub, ROL_RollDownAll
Return