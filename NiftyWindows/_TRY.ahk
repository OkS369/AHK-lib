; [TRY] handles the tray icon/menu

TRY_TrayInit:
Menu, TRAY, NoStandard
Menu, TRAY, Tip, %SYS_ScriptInfo%

If ( !A_IsCompiled )
{
	Menu, AutoHotkey, Standard
	Menu, TRAY, Add, AutoHotkey, :AutoHotkey
	Menu, TRAY, Add
}

Menu, TRAY, Add, Help, TRY_TrayEvent
Menu, TRAY, Default, Help
Menu, TRAY, Add
Menu, TRAY, Add, About script, TRY_TrayEvent
;Menu, TRAY, Add
;Menu, TRAY, Add, Author, TRY_TrayEvent
;Menu, TRAY, Add, View License, TRY_TrayEvent
;Menu, TRAY, Add, Visit Website, TRY_TrayEvent
;Menu, TRAY, Add, Check For Update, TRY_TrayEvent
Menu, TRAY, Add

Menu, MouseHooks, Add, All Mouse Buttons, TRY_TrayEvent
Menu, MouseHooks, Add, Left Mouse Button, TRY_TrayEvent
Menu, MouseHooks, Add, Middle Mouse Button, TRY_TrayEvent
Menu, MouseHooks, Add, Right Mouse Button, TRY_TrayEvent
Menu, MouseHooks, Add, Fourth Mouse Button, TRY_TrayEvent
Menu, MouseHooks, Add, Fifth Mouse Button, TRY_TrayEvent
Menu, MouseHooks, Add, WheelUp, TRY_TrayEvent
Menu, MouseHooks, Add, WheelDown, TRY_TrayEvent
Menu, TRAY, Add, Mouse Hooks, :MouseHooks

Menu, TRAY, Add, Debuging, TRY_TrayEvent
Menu, TRAY, Add, Configuration, TRY_TrayEvent
Menu, TRAY, Add, WindowsDraging, TRY_TrayEvent
Menu, TRAY, Add, ToolTip Feedback, TRY_TrayEvent
Menu, TRAY, Add, Auto Suspend, TRY_TrayEvent
Menu, TRAY, Add, Focus Follows Mouse, TRY_TrayEvent
Menu, TRAY, Add, Suspend All Hooks, TRY_TrayEvent
Menu, TRAY, Add, Revert Visual Effects, TRY_TrayEvent
Menu, TRAY, Add, Hide Tray Icon, TRY_TrayEvent
Menu, TRAY, Add
Menu, TRAY, Add, Exit, TRY_TrayEvent

Gosub, TRY_TrayUpdate

If ( A_IconHidden )
	Menu, TRAY, Icon
Return

TRY_TrayUpdate:
If ( CFG_AllMouseButtonsHook )
{
	Menu, MouseHooks, Check, All Mouse Buttons
	Menu, MouseHooks, Check, Left Mouse Button
	Menu, MouseHooks, Check, Middle Mouse Button
	Menu, MouseHooks, Check, Right Mouse Button
	Menu, MouseHooks, Check, Fourth Mouse Button
	Menu, MouseHooks, Check, Fifth Mouse Button
	Menu, MouseHooks, Check, WheelUp
	Menu, MouseHooks, Check, WheelDown
}
Else
{
	Menu, MouseHooks, UnCheck, All Mouse Buttons
	
	If ( CFG_LeftMouseButtonHook )
		Menu, MouseHooks, Check, Left Mouse Button
	Else
		Menu, MouseHooks, UnCheck, Left Mouse Button
	If ( CFG_MiddleMouseButtonHook )
		Menu, MouseHooks, Check, Middle Mouse Button
	Else
		Menu, MouseHooks, UnCheck, Middle Mouse Button
	If ( CFG_RightMouseButtonHook )
		Menu, MouseHooks, Check, Right Mouse Button
	Else
		Menu, MouseHooks, UnCheck, Right Mouse Button
	If ( CFG_FourthMouseButtonHook )
		Menu, MouseHooks, Check, Fourth Mouse Button
	Else
		Menu, MouseHooks, UnCheck, Fourth Mouse Button
	If ( CFG_FifthMouseButtonHook )
		Menu, MouseHooks, Check, Fifth Mouse Button
	Else
		Menu, MouseHooks, UnCheck, Fifth Mouse Button
	If ( CFG_WheelUpMouseButtonHook )
		Menu, MouseHooks, Check, WheelUp
	Else
		Menu, MouseHooks, UnCheck, WheelUp
	If ( CFG_WheelDownMouseButtonHook )
		Menu, MouseHooks, Check, WheelDown
	Else
		Menu, MouseHooks, UnCheck, WheelDown
}

If ( SYS_Debuging )
	Menu, TRAY, Check, Debuging
Else
	Menu, TRAY, UnCheck, Debuging
If ( WindowsDraging )
	Menu, TRAY, Check, WindowsDraging
Else
	Menu, TRAY, UnCheck, WindowsDraging
If ( SYS_ToolTipFeedback )
	Menu, TRAY, Check, ToolTip Feedback
Else
	Menu, TRAY, UnCheck, ToolTip Feedback
If ( SUS_AutoSuspend )
	Menu, TRAY, Check, Auto Suspend
Else
	Menu, TRAY, UnCheck, Auto Suspend
If ( XWN_FocusFollowsMouse )
	Menu, TRAY, Check, Focus Follows Mouse
Else
	Menu, TRAY, UnCheck, Focus Follows Mouse
If ( A_IsSuspended )
	Menu, TRAY, Check, Suspend All Hooks
Else
	Menu, TRAY, UnCheck, Suspend All Hooks
;IconChanger:
If A_IsSuspended
{
	If(FileExist(A_ScriptDir "\NiftyWindows_suspended.png"))
		Menu,Tray,Icon,%A_ScriptDir%\NiftyWindows_suspended.png, ,1 	; custom icon for script when suspended
}
Else
{
	If(FileExist(A_ScriptDir "\NiftyWindows.png"))
		Menu,Tray,Icon,%A_ScriptDir%\NiftyWindows.png 	; custom icon for script when active
}
Return

TRY_TrayEvent:
If ( !TRY_TrayEvent )
	TRY_TrayEvent = %A_ThisMenuItem%

If ( TRY_TrayEvent = "Help" )
	IfExist, %A_ScriptDir%\readme.txt
Run, "%A_ScriptDir%\readme.txt"
Else
{
	SYS_TrayTipText = File couldn't be accessed:`n%A_ScriptDir%\readme.txt
	SYS_TrayTipOptions = 3
	Gosub, SYS_TrayTipShow
}

If ( TRY_TrayEvent = "About script" )
{
	SYS_TrayTipText = NiftyWindows is free tool provides many helpful features for an easier handling of your Windows
	SYS_TrayTipSeconds = 5
	Gosub, SYS_TrayTipShow
}

If ( TRY_TrayEvent = "Author" )
{
	SYS_TrayTipText = OkS
	SYS_TrayTipSeconds = 3
	Gosub, SYS_TrayTipShow
}

If ( TRY_TrayEvent = "View License" )
	IfExist, %A_ScriptDir%\license.txt
Run, "%A_ScriptDir%\license.txt"
Else
{
	SYS_TrayTipText = File couldn't be accessed:`n%A_ScriptDir%\license.txt
	SYS_TrayTipOptions = 3
	Gosub, SYS_TrayTipShow
}

If ( TRY_TrayEvent = "Visit Website" )
	Run, http://www.enovatic.org/products/niftywindows/

If ( TRY_TrayEvent = "Debuging" )
	SYS_Debuging := !SYS_Debuging

If ( TRY_TrayEvent = "WindowsDraging" )
	WindowsDraging := !WindowsDraging

If ( TRY_TrayEvent = "ToolTip Feedback" )
	SYS_ToolTipFeedback := !SYS_ToolTipFeedback

If ( TRY_TrayEvent = "Auto Suspend" )
{
	SUS_AutoSuspend := !SUS_AutoSuspend
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "Focus Follows Mouse" )
{
	XWN_FocusFollowsMouse := !XWN_FocusFollowsMouse
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "Suspend All Hooks" )
{
	If (SUS_AutoSuspend) 
	{
		SUS_AutoSuspend := !SUS_AutoSuspend
		Gosub, CFG_ApplySettings
	}
	Gosub, SUS_SuspendToggle
}

If ( TRY_TrayEvent = "Revert Visual Effects" )
	Gosub, SYS_RevertVisualEffects

If ( TRY_TrayEvent = "Hide Tray Icon" )
{
	SYS_TrayTipText = Tray icon will be hidden now.`nPress WIN+X to show it again.
	SYS_TrayTipOptions = 2
	SYS_TrayTipSeconds = 5
	Gosub, SYS_TrayTipShow
	SetTimer, TRY_TrayHide, 5000
}

If ( TRY_TrayEvent = "Exit" )
	ExitApp

If ( TRY_TrayEvent = "Left Mouse Button" )
{
	CFG_LeftMouseButtonHook := !CFG_LeftMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "Middle Mouse Button" )
{
	CFG_MiddleMouseButtonHook := !CFG_MiddleMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "Right Mouse Button" )
{
	CFG_RightMouseButtonHook := !CFG_RightMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "Fourth Mouse Button" )
{
	CFG_FourthMouseButtonHook := !CFG_FourthMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "Fifth Mouse Button" )
{
	CFG_FifthMouseButtonHook := !CFG_FifthMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "WheelUp" )
{
	CFG_WheelUpMouseButtonHook := !CFG_WheelUpMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "WheelDown" )
{
	CFG_WheelDownMouseButtonHook := !CFG_WheelDownMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "All Mouse Buttons" )
{
	CFG_AllMouseButtonsHook := !CFG_AllMouseButtonsHook
	If (CFG_AllMouseButtonsHook = 0)
	{
		CFG_LeftMouseButtonHook := 0
		CFG_MiddleMouseButtonHook := 0
		CFG_RightMouseButtonHook := 0
		CFG_FourthMouseButtonHook := 0
		CFG_FifthMouseButtonHook := 0
		CFG_WheelUpMouseButtonHook := 0
		CFG_WheelDownMouseButtonHook := 0
	}
	Else If (CFG_AllMouseButtonsHook = 1)
	{
		CFG_LeftMouseButtonHook := 1
		CFG_MiddleMouseButtonHook := 1
		CFG_RightMouseButtonHook := 1
		CFG_FourthMouseButtonHook := 1
		CFG_FifthMouseButtonHook := 1
		CFG_WheelUpMouseButtonHook := 1
		CFG_WheelDownMouseButtonHook := 1
	}
	Gosub, CFG_ApplySettings
}
Else If  ( TRY_TrayEvent != "All Mouse Buttons" ) and ( (CFG_LeftMouseButtonHook = 0) or (CFG_MiddleMouseButtonHook = 0) or (CFG_RightMouseButtonHook = 0) or (CFG_FourthMouseButtonHook = 0) or (CFG_FifthMouseButtonHook = 0) or (CFG_WheelUpMouseButtonHook = 0) or (CFG_WheelDownMouseButtonHook = 0) )
{
	CFG_AllMouseButtonsHook := 0
	Gosub, CFG_ApplySettings
}
Else If ( TRY_TrayEvent != "All Mouse Buttons" ) and ( (CFG_LeftMouseButtonHook = 1) and (CFG_MiddleMouseButtonHook = 1) and (CFG_RightMouseButtonHook = 1) and (CFG_FourthMouseButtonHook = 1) and (CFG_FifthMouseButtonHook = 1) and (CFG_WheelUpMouseButtonHook = 1) and (CFG_WheelDownMouseButtonHook = 1) )
{
	CFG_AllMouseButtonsHook := 1
	Gosub, CFG_ApplySettings
}

If ( TRY_TrayEvent = "Configuration" )
{
	IfExist, %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
	Run, "%A_ScriptDir%\%SYS_ScriptNameNoExt%.ini"
}

Gosub, TRY_TrayUpdate
Gosub, CFG_SaveSettings
TRY_TrayEvent =
Return

TRY_TrayHide:
SetTimer, TRY_TrayHide, Off
Menu, TRAY, NoIcon
Return