/**
	* Minimizes the selected window (if minimizable) to the task bar. If you press
	* the left button over the titlebar the selected window will be rolled up
	* instead of being minimized. You have to apply this action again to roll the
	* window back down.
*/

#LButton::
GetKeyState, MIW_RButtonState, RButton, P
WinGet, CAW_WinID, ID, A
WinGet,  CAW_WinStyle, Style, A
WinGet, CAW_WinProcessName, ProcessName, A
WinGetClass, CAW_WinClass, ahk_id %CAW_WinID%
If ( (!NWD_ImmediateDown) and (CAW_WinClass != "Progman") )
{
	GetKeyState, MIW_CtrlState, Ctrl, P
	WinGet, MIW_WinStyle, Style, ahk_id %CAW_WinID%
	WinGetPos, , WinY, , , ahk_id %CAW_WinID%
	SysGet, MIW_CaptionHeight, 4 ; SM_CYCAPTION
	SysGet, MIW_BorderHeight, 7 ; SM_CXDLGFRAME
	MouseGetPos, , MIW_MouseY

	If ( (MIW_MouseY - WinY) <= (MIW_CaptionHeight + MIW_BorderHeight) )
	{
		; checks wheter the window has a sizing border (WS_THICKFRAME)
		If ( (MIW_CtrlState = "D") or (MIW_WinStyle & 0x40000) )
		{
			Gosub, NWD_SetAllOff
			ROL_WinID = %CAW_WinID%
			Gosub, ROL_RollToggle
		}
	}
	Else
	{
		If ( (MIW_CtrlState = "D") or (MIW_WinStyle & 0xCA0000 = 0xCA0000) or (CAW_WinClass = "Chrome_WidgetWin_1") )
		{
			Gosub, NWD_SetAllOff
			WinGet, LastApp_ID, ID, A
			WinMinimize, ahk_id %CAW_WinID%
			SYS_ToolTipText = Window Minimized
			SYS_ToolTipSeconds = 0.5
			Gosub, SYS_ToolTipFeedbackShow
			Log(CAW_WinProcessName " minimazed")
		}
	}
}
Return

Hotkey, #^LButton, %CFG_LeftMouseButtonHookStr%

/**
	* Closes the selected window (if closeable) as if you click the close button in the titlebar if use press middle mouse button while Win and Ctrl pressed.
	* If you press the middle button while right mouse button pressed selected window will be sent to the bottom of the window stack instead of being closed.
	* If you press the middle button while space pressed Volume_Mute command will be sent.
*/

MButton::
^#MButton::
GetKeyState, CLW_RButtonState, RButton, P
GetKeyState, CLW_SpaceState, Space, P
GetKeyState, CLW_LCtrlState, LCtrl, P
GetKeyState, CLW_LWinState, Lwin, P
WinGet, CAW_WinID, ID, A
WinGet,  CAW_WinStyle, Style, A
WinGet, CAW_WinProcessName, ProcessName, A
WinGetClass, CAW_WinClass, ahk_id %CAW_WinID%
If ( (CLW_RButtonState = "D") and (!NWD_ImmediateDown) and (CAW_WinClass != "Progman") )
{
	Gosub, NWD_SetAllOff
	Send, !{Esc}
	SYS_ToolTipText = %CAW_WinProcessName% window sent to bottom
	Gosub, SYS_ToolTipFeedbackShow
	Log(CAW_WinProcessName " window sent to bottom")

}
Else
{
	If ( (CLW_SpaceState = "D") and (CLW_LCtrlState = "U") and (CLW_LWinState = "U"))
		Send, {Volume_Mute}
	Else If ( (CLW_SpaceState = "U") and (CLW_LCtrlState = "D") and (CLW_LWinState = "D"))
	{
		WinKill, ahk_id %CAW_WinID%
		SYS_ToolTipText = Window Check
		Gosub, SYS_ToolTipFeedbackShow
	}
	Else
		Send, {MButton}
}
Return
Hotkey, MButton, %CFG_MiddleMouseButtonHookStr%
Hotkey, ^#MButton, %CFG_MiddleMouseButtonHookStr%


#XButton1::	; minimaze all windows or show alt tab menu
{
	IfWinActive, A
	{
		WinGet, XB1_WinID, ID
		If ( !XB1_WinID )
			Return
		WinGetClass, XB1_WinClass, ahk_id %XB1_WinID%

		; show alt tab menu to select window
		If ( XB1_WinClass = "Progman" ) or ( XB1_WinClass = "WorkerW" )
		{
			SYS_ToolTipText = Choose window
			Gosub, SYS_ToolTipFeedbackShow
			Send, ^!{Tab}
		}
		; Minimize All Windows
		Else
		{
			Gosub, NWD_SetAllOff
			WinGet, LastApp_ID, ID, A
			WinMinimizeAll
			SYS_ToolTipText = All Windows Minimized
			SYS_ToolTipSeconds = 0.5
			Gosub, SYS_ToolTipFeedbackShow
			Log("All Windows Minimized")
		}
	}
	; show alt tab menu to select window
	Else
	{
		SYS_ToolTipText = Target window unknown. Choose window manually to restore.
		Gosub, SYS_ToolTipFeedbackShow
		Send, ^!{Tab}
	}
}
Return
Hotkey, #XButton1, %CFG_FourthMouseButtonHookStr%


#XButton2::	; toggle maximize active window  or show alt tab menu
{
	IfWinActive, A
	{
		WinGet, XB2_WinID, ID
		If ( !XB2_WinID )
			Return
		WinGetClass, XB2_WinClass, ahk_id %XB2_WinID%
		WinGetClass, XB2_WinClass, ahk_id %XB2_WinID%
		If ( (XB2_WinClass != "Progman") and (XB2_WinClass != "WorkerW") and (XB2_WinClass != "Shell_TrayWnd") and (XB2_WinClass != "tooltips_class32") )
		{
			Gosub, NWD_SetAllOff
			
			WinGet, XB2_MinMax, MinMax, A
			WinGet, XB2_WinProcessName, ProcessName, A

			; maximize active window
			If ( XB2_MinMax = 0 )
			{
				WinMaximize
				SYS_ToolTipText = Window Maximized
				Gosub, SYS_ToolTipFeedbackShow
				Log(XB2_WinProcessName " maximized")
			}
			; unmaximize active window
			Else If ( XB2_MinMax = 1 )
			{
				WinRestore
				SYS_ToolTipText = Window Restored
				Gosub, SYS_ToolTipFeedbackShow
				Log(XB2_WinProcessName " restored to non fullscreen window")
			}
		}
		Else
		{
			If ( (!WinExist(%LastApp_ID%)) or (ShowDesktopFeatureUsed = 1) or (XB2_WinClass in Progman,WorkerW,AutoHotkeyGUI,StaticStatic) )
			; If (!WinExist(%LastApp_ID%)) or (ShowDesktopFeatureUsed = 1) or ((XB2_WinClass = "Progman") or (XB2_WinClass = "WorkerW") or (XB2_WinClass = "AutoHotkeyGUI") or (XB2_WinClass = "Static"))
			{
				SYS_ToolTipText = Target app unknown. Choose app manually to restore.
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
Hotkey, #XButton2, %CFG_FifthMouseButtonHook%


GetKeyState, MWD_RButtonState, RButton, P
GetKeyState, MWD_LAltState, LAlt, P
GetKeyState, MWD_LWinState, LWin, P

Return

WheelDown::
<+WheelDown::
<^WheelDown::
<!WheelDown::
{
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
		; quick task switcher (alt-tab-menu) controlled by the mouse wheel.
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


; TODO: move simple action to different place as separated hotkeys
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
	; quick task switcher (alt-tab-menu) controlled by the mouse wheel.
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
WinGet, ROL_WinProcessName, ProcessName, A
If ( ROL_WinClass = "Progman" )
	Return

IfNotInString, ROL_WinIDs, |%ROL_WinID%
{
	SYS_ToolTipText = Window Roll: UP
	Gosub, ROL_RollUp
	Log(ROL_WinProcessName " rolled up")
}
Else
{
	WinGetPos, , , , ROL_WinHeight, ahk_id %ROL_WinID%
	If ( ROL_WinHeight = ROL_WinRolledHeight%ROL_WinID% )
	{
		SYS_ToolTipText = Window Roll: DOWN
		Gosub, ROL_RollDown
		Log(ROL_WinProcessName " rolled down")
	}
	Else
	{
		SYS_ToolTipText = Window Roll: UP
		Gosub, ROL_RollUp
		Log(ROL_WinProcessName " rolled up")
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