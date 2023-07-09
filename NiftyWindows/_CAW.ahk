
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
GetKeyState, MAW_SpaceState, Space, P
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
	
	If ( CLW_MouseY <= CLW_CaptionHeight + CLW_BorderHeight ) and (MAW_SpaceState = "U")
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
	If (MAW_SpaceState = "D")
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
XButton1PressedStartTime := A_TickCount
If ( NWD_ImmediateDown )
	Return
GetKeyState, TSM_RButtonState, RButton, P
GetKeyState, TSM_CtrlState, LControl, P
GetKeyState, TSM_ShiftState, LShift, P
GetKeyState, TSM_AltState, LAlt, P
GetKeyState, TSM_WinState, LWin, P
GetKeyState, MAW_SpaceState, Space, P
ControlUsed = 0
If ( TSM_RButtonState = "U" )
{
	If ( (TSM_CtrlState = "U") and (TSM_ShiftState = "U") and (TSM_AltState = "U") and (TSM_WinState = "U") )
	{
		GetKeyState, TSM_XButton1State, XButton1, P
		While ( (TSM_XButton1State = "D") )
		{
			GetKeyState, TSM_XButton1State, XButton1, P
			If (TSM_XButton1State = "U")
			{
				XButton1UnPressedElapsedTime := A_TickCount - XButton1PressedStartTime
				If ( XButton1UnPressedElapsedTime < 350 )
				{
					If (MAW_SpaceState = "D")
						Send, {Media_Prev}
					Else
						Send, {XButton1}
				}
				Break
			}
			Else If (TSM_XButton1State = "D")
			{
				GetKeyState, TSM_CtrlState, LControl
				XButton1PressedElapsedTime := A_TickCount - XButton1PressedStartTime
				If ( (TSM_CtrlState = "U") and (XButton1PressedElapsedTime > 700) and (ControlUsed != 1) )
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
	Else If ( (TSM_CtrlState = "U") and (TSM_ShiftState = "U") and (TSM_AltState = "D") and (TSM_WinState = "U") )
	{
		Send, {Delete}
	}
	Else If ( (TSM_CtrlState = "U") and (TSM_ShiftState = "D") and (TSM_AltState = "U") and (TSM_WinState = "U") )
	{
		SleepTime = 300
		GetKeyState, TSM_XButton1State, XButton1, P
		While ( (TSM_XButton1State = "D") )
		{
			Send, {PgDn}
			Sleep, %SleepTime%
			GetKeyState, TSM_XButton1State, XButton1, P
			If (TSM_XButton1State = "U")
				Break
			Else
				SleepTime = 50
		}
	}
	Else If  ( (TSM_CtrlState = "D") and (TSM_ShiftState = "U") and (TSM_AltState = "U") and (TSM_WinState = "U") )
	{
		Send, {End}
	}
	Else If  ( (TSM_CtrlState = "U") and (TSM_ShiftState = "U") and (TSM_AltState = "U") and (TSM_WinState = "D") )
	{
		Send, #^{RIGHT}
	}
}
Else If ( TSM_RButtonState = "D" )
{
	IfWinActive, A
	{
		WinGet, TSM_WinID, ID
		If ( !TSM_WinID )
			Return
		WinGetClass, TSM_WinClass, ahk_id %TSM_WinID%
		If ( TSM_WinClass = "Progman" ) or ( TSM_WinClass = "WorkerW" )
		{
			WinMinimizeAllUndo
			;Send, #+m
			ShowDesktopFeatureUsed = 1
			WinGetClass, TSM_WinClass, ahk_id %TSM_WinID%
			If ( TSM_WinClass = "Progman" ) or ( TSM_WinClass = "WorkerW" )
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
XButton2PressedStartTime := A_TickCount
If ( NWD_ImmediateDown )
	Return
GetKeyState, MAW_RButtonState, RButton, P
GetKeyState, MAW_ShiftState, LShift, P
GetKeyState, MAW_CtrlState, LControl, P
GetKeyState, MAW_AltState, LAlt, P
GetKeyState, MAW_WinState, LWin, P
GetKeyState, MAW_WheelUpState, WheelUp, P
GetKeyState, MAW_WheelDownState, WheelDown, P
GetKeyState, MAW_SpaceState, Space, P
ShiftUsed = 0
If ( MAW_RButtonState = "U" )
{
	If ( (MAW_CtrlState = "U") and (MAW_ShiftState = "U") and (MAW_AltState = "U") and (MAW_WinState = "U") )
	{
		GetKeyState, MAW_XButton2State, XButton2, P
		While ( (MAW_XButton2State = "D") )
		{
			GetKeyState, MAW_XButton2State, XButton2, P
			If (MAW_XButton2State = "U")
			{
				XButton2UnPressedElapsedTime := A_TickCount - XButton2PressedStartTime
				If ( XButton2UnPressedElapsedTime < 350 )
				{
					If (MAW_SpaceState = "D")
						Send, {Media_Next}
					Else
						Send, {XButton2}
				}
				Break
			}
			Else If (MAW_XButton2State = "D")
			{
				GetKeyState, MAW_ShiftState, Shift
				XButton2PressedElapsedTime := A_TickCount - XButton2PressedStartTime
				If ( (MAW_ShiftState = "U") and (XButton2PressedElapsedTime > 700) and (ShiftUsed != 1) )
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
	Else If ( (MAW_CtrlState = "U") and (MAW_ShiftState = "U") and (MAW_AltState = "D") and (MAW_WinState = "U") )
	{
		Send, {Backspace}
	}
	Else If ( (MAW_CtrlState = "U") and (MAW_ShiftState = "D") and (MAW_AltState = "U") and (MAW_WinState = "U") )
	{
		SleepTime = 300
		GetKeyState, MAW_XButton2State, XButton2, P
		While ( (MAW_XButton2State == "D") )
		{
			Send, {PgUp}
			Sleep, %SleepTime%
			GetKeyState, MAW_XButton2State, XButton2, P
			If (MAW_XButton2State == "U")
				Break
			Else
				SleepTime = 50
		}
	}
	Else If ( (MAW_CtrlState = "D") and (MAW_ShiftState = "U") and (MAW_AltState = "U") and (MAW_WinState = "U") )
	{
		Send, {Home}
	}
	Else If ( (MAW_CtrlState = "U") and (MAW_ShiftState = "U") and (MAW_AltState = "U") and (MAW_WinState = "D") )
	{
		Send,#^{LEFT}
	}
}
Else If ( MAW_RButtonState = "D" )
{
	IfWinActive, A
	{
		WinGet, MAW_WinID, ID
		If ( !MAW_WinID )
			Return
		WinGetClass, MAW_WinClass, ahk_id %MAW_WinID%
		If ( (MAW_WinClass != "Progman") and (MAW_WinClass != "WorkerW") and (MAW_WinClass != "Shell_TrayWnd") and (MAW_WinClass != "tooltips_class32") )
		{
			Gosub, NWD_SetAllOff
			
			WinGet, MAW_MinMax, MinMax, A
					;MsgBox %MAW_MinMax% %MAW_WinClass%
			If ( MAW_MinMax = 0 )
			{
				WinMaximize
				SYS_ToolTipText = Window Maximized
				Gosub, SYS_ToolTipFeedbackShow
			}
			Else If ( MAW_MinMax = 1 )
			{
				WinRestore
				SYS_ToolTipText = Window Restored
				Gosub, SYS_ToolTipFeedbackShow
			}
		}
		Else
		{
			If (!WinExist(%LastApp_ID%)) or (ShowDesktopFeatureUsed = 1) or ((MAW_WinClass = "Progman") or (MAW_WinClass = "WorkerW") or (MAW_WinClass = "AutoHotkeyGUI") or (MAW_WinClass = "Static"))
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
GetKeyState, TSW_RButtonState, RButton, P
GetKeyState, TSW_XButton1State, XButton1, P
GetKeyState, TSW_XButton2State, XButton2, P
GetKeyState, TSW_LAltState, LAlt, P
GetKeyState, TSW_LShiftState, LShift, P
GetKeyState, TSW_LCtrState, LControl, P
GetKeyState, TSW_LWinState, LWin, P
GetKeyState, MAW_SpaceState, Space, P
If ( ((TSW_LAltState = "D") and (TSW_LWinState = "U")) or ((TSW_RButtonState = "D") and (!NWD_ImmediateDown)) )
{
	GetKeyState, TSW_AltState, Alt
	If ( TSW_AltState = "U" or FirstUseOfAltTAbByWheelAndLAlt != 1)
	{
		Gosub, NWD_SetAllOff
		Send, {LAlt down}{Tab}
		SetTimer, TSW_WheelHandler, 100
	}
	Else
		Send, {Tab}
}
Else
{
	If  (TSW_LWinState = "D")
	{
		If (TSW_LShiftState = "U" and TSW_LCtrState = "D" and TSW_LAltState = "D")
			Send, {Volume_Down 100}
		Else If (TSW_LShiftState = "U" and TSW_LCtrState = "U" and TSW_LAltState = "D")
			Send, {Volume_Down 20}
		Else If (TSW_LShiftState = "D" and TSW_LCtrState = "U" and TSW_LAltState = "U")
			Send, {LWin down}{LShift down}{RIGHT}{LWin up}{LShift up}
		Else
			Send, {LWin down}{LControl down}{RIGHT}{LWin up}{LControl up}
	}
	Else If ( (TSW_XButton1State = "D") or (TSW_LCtrState = "D") )
	{
		GetKeyState, TSW_CtrState, Alt
		If ( TSW_CtrState = "U" or FirstUseOfCtrTAbByWheel != 1)
		{
			Gosub, NWD_SetAllOff
			Send, {LControl down}{Tab}
			SetTimer, TSW_WheelHandler, 100
		}
		Else
			Send, {Tab}
	}
	Else If ( (TSW_XButton2State = "D") or (TSW_LShiftState = "D") )
		Send, {LShift up}{PgDn}
	
	Else If (MAW_SpaceState = "D")
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
GetKeyState, TSW_RButtonState, RButton, P
GetKeyState, TSW_XButton1State, XButton1, P
GetKeyState, TSW_XButton2State, XButton2, P
GetKeyState, TSW_LAltState, LAlt, P
GetKeyState, TSW_LShiftState, LShift, P
GetKeyState, TSW_LCtrState, LControl, P
GetKeyState, TSW_LWinState, LWin, P
GetKeyState, MAW_SpaceState, Space, P
If ( ((TSW_LAltState = "D")  and (TSW_LWinState = "U"))  or ((TSW_RButtonState = "D") and (!NWD_ImmediateDown)) )
{
	GetKeyState, TSW_AltState, Alt
	If ( TSW_AltState = "U" or FirstUseOfAltTAbByWheelAndLAlt != 1)
	{
		Gosub, NWD_SetAllOff
		Send, {LAlt down}+{Tab}
		SetTimer, TSW_WheelHandler, 1000
	}
	Else
		Send, +{Tab}
}
Else
{
	If  (TSW_LWinState = "D")
	{
		If (TSW_LShiftState = "U" and TSW_LCtrState = "D" and TSW_LAltState = "D")
			Send, {Volume_Up 100}
		Else If (TSW_LShiftState = "U" and TSW_LCtrState = "U" and TSW_LAltState = "D")
			Send, {Volume_Up 20}
		Else If (TSW_LShiftState = "D" and TSW_LCtrState = "U" and TSW_LAltState = "U")
			Send, {LWin down}{LShift down}{LEFT}{LWin up}{LShift up}
		Else
			Send, {LWin down}{LControl down}{LEFT}{LWin up}{LControl up}
	}
	Else If ( (TSW_XButton1State = "D") or (TSW_LCtrState = "D") )
	{
		GetKeyState, TSW_CtrState, Alt
		If ( TSW_CtrState = "U" or FirstUseOfCtrTAbByWheel != 1)
		{
			Gosub, NWD_SetAllOff
			Send, {LControl down}+{Tab}
			SetTimer, TSW_WheelHandler, 1000
		}
		Else
			Send, {LShift down}{Tab}{LShift up}
	}
	Else If ( (TSW_XButton2State = "D") or (TSW_LShiftState = "D") )
		Send, {LShift up}{PgUp}
	Else If (MAW_SpaceState = "D")
		Send, {Volume_Up}
	Else
		Send, {WheelUp}
}
Return

TSW_WheelHandler:
GetKeyState, TSW_RButtonState, RButton, P
GetKeyState, TSW_LAltState, LAlt, P
GetKeyState, TSW_XButton1State, XButton1, P
GetKeyState, TSW_LCtrState, LControl, P
If ( TSW_RButtonState = "U" and TSW_LAltState = "U" and TSW_XButton1State = "U" and TSW_LCtrState = "U")
{
	SetTimer, TSW_WheelHandler, Off
	FirstUseOfAltTAbByWheelAndLAlt = 0
	FirstUseOfCtrTAbByWheel = 0
	GetKeyState, TSW_AltState, Alt
	If ( TSW_AltState = "D" )
		Send, {Alt up}
	GetKeyState, TSW_CtrState, Control
	If ( TSW_CtrState = "D" )
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