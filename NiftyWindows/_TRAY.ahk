; [TRY] handles the tray icon/menu

TRAY_TrayInit:
Menu, TRAY, NoStandard
Menu, TRAY, Tip, %SYS_ScriptInfo%

If ( !A_IsCompiled )
{
	Menu, AutoHotkey, Standard
	Menu, TRAY, Add, AutoHotkey, :AutoHotkey
	Menu, TRAY, Add
}

Menu, TRAY, Add, Help, TRAY_TrayEvent
Menu, TRAY, Default, Help
Menu, TRAY, Add
Menu, TRAY, Add, About script, TRAY_TrayEvent
;Menu, TRAY, Add
;Menu, TRAY, Add, Author, TRAY_TrayEvent
;Menu, TRAY, Add, View License, TRAY_TrayEvent
;Menu, TRAY, Add, Visit Website, TRAY_TrayEvent
;Menu, TRAY, Add, Check For Update, TRAY_TrayEvent
Menu, TRAY, Add

Menu, MouseHooks, Add, All Mouse Buttons, TRAY_TrayEvent
Menu, MouseHooks, Add, Left Mouse Button, TRAY_TrayEvent
Menu, MouseHooks, Add, Middle Mouse Button, TRAY_TrayEvent
Menu, MouseHooks, Add, Right Mouse Button, TRAY_TrayEvent
Menu, MouseHooks, Add, Fourth Mouse Button, TRAY_TrayEvent
Menu, MouseHooks, Add, Fifth Mouse Button, TRAY_TrayEvent
Menu, MouseHooks, Add, WheelUp, TRAY_TrayEvent
Menu, MouseHooks, Add, WheelDown, TRAY_TrayEvent
Menu, TRAY, Add, Mouse Hooks, :MouseHooks

Menu, TRAY, Add, Debug, TRAY_TrayEvent
Menu, TRAY, Add, Configuration, TRAY_TrayEvent
Menu, TRAY, Add, WindowsDraging, TRAY_TrayEvent
Menu, TRAY, Add, ToolTip Feedback, TRAY_TrayEvent
Menu, TRAY, Add, Auto Suspend, TRAY_TrayEvent
Menu, TRAY, Add, Focus Follows Mouse, TRAY_TrayEvent
Menu, TRAY, Add, Suspend All Hooks, TRAY_TrayEvent
Menu, TRAY, Add, Revert Visual Effects, TRAY_TrayEvent
Menu, TRAY, Add, Hide Tray Icon, TRAY_TrayEvent
Menu, TRAY, Add
Menu, TRAY, Add, Exit, TRAY_TrayEvent

Gosub, TRAY_TrayUpdate

If ( A_IconHidden )
	Menu, TRAY, Icon
Return

TRAY_TrayUpdate:
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

If ( SYS_Debug )
	Menu, TRAY, Check, Debug
Else
	Menu, TRAY, UnCheck, Debug
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
	If(FileExist(A_ScriptDir "\Icons\NiftyWindows_suspended.png"))
		Menu,Tray,Icon,%A_ScriptDir%\Icons\NiftyWindows_suspended.png, ,1 	; custom icon for script when suspended
}
Else
{
	If(FileExist(A_ScriptDir "\Icons\NiftyWindows.png"))
		Menu,Tray,Icon,%A_ScriptDir%\Icons\NiftyWindows.png 	; custom icon for script when active
}
Return

TRAY_TrayEvent:
If ( !TRAY_TrayEvent )
	TRAY_TrayEvent = %A_ThisMenuItem%

If ( TRAY_TrayEvent = "Help" )
	IfExist, %A_ScriptDir%\readme.txt
Run, "%A_ScriptDir%\readme.txt"
Else
{
	SYS_TrayTipText = File couldn't be accessed:`n%A_ScriptDir%\readme.txt
	SYS_TrayTipOptions = 3
	Gosub, SYS_TrayTipShow
}

If ( TRAY_TrayEvent = "About script" )
{
	SYS_TrayTipText = NiftyWindows is free tool provides many helpful features for an easier handling of your Windows
	SYS_TrayTipSeconds = 5
	Gosub, SYS_TrayTipShow
}

If ( TRAY_TrayEvent = "Author" )
{
	SYS_TrayTipText = OkS
	SYS_TrayTipSeconds = 3
	Gosub, SYS_TrayTipShow
}

If ( TRAY_TrayEvent = "View License" )
	IfExist, %A_ScriptDir%\license.txt
Run, "%A_ScriptDir%\license.txt"
Else
{
	SYS_TrayTipText = File couldn't be accessed:`n%A_ScriptDir%\license.txt
	SYS_TrayTipOptions = 3
	Gosub, SYS_TrayTipShow
}

If ( TRAY_TrayEvent = "Visit Website" )
	Run, http://www.enovatic.org/products/niftywindows/

If ( TRAY_TrayEvent = "Debug" )
	SYS_Debug := !SYS_Debug

If ( TRAY_TrayEvent = "WindowsDraging" )
	WindowsDraging := !WindowsDraging

If ( TRAY_TrayEvent = "ToolTip Feedback" )
	SYS_ToolTipFeedback := !SYS_ToolTipFeedback

If ( TRAY_TrayEvent = "Auto Suspend" )
{
	SUS_AutoSuspend := !SUS_AutoSuspend
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "Focus Follows Mouse" )
{
	XWN_FocusFollowsMouse := !XWN_FocusFollowsMouse
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "Suspend All Hooks" )
{
	If (SUS_AutoSuspend) 
	{
		SUS_AutoSuspend := !SUS_AutoSuspend
		Gosub, CFG_ApplySettings
	}
	Gosub, SUS_SuspendToggle
}

If ( TRAY_TrayEvent = "Revert Visual Effects" )
	Gosub, SYS_RevertVisualEffects

If ( TRAY_TrayEvent = "Hide Tray Icon" )
{
	SYS_TrayTipText = Tray icon will be hidden now.`nPress WIN+X to show it again.
	SYS_TrayTipOptions = 2
	SYS_TrayTipSeconds = 5
	Gosub, SYS_TrayTipShow
	SetTimer, TRAY_TrayHide, 5000
}

If ( TRAY_TrayEvent = "Exit" )
	ExitApp

If ( TRAY_TrayEvent = "Left Mouse Button" )
{
	CFG_LeftMouseButtonHook := !CFG_LeftMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "Middle Mouse Button" )
{
	CFG_MiddleMouseButtonHook := !CFG_MiddleMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "Right Mouse Button" )
{
	CFG_RightMouseButtonHook := !CFG_RightMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "Fourth Mouse Button" )
{
	CFG_FourthMouseButtonHook := !CFG_FourthMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "Fifth Mouse Button" )
{
	CFG_FifthMouseButtonHook := !CFG_FifthMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "WheelUp" )
{
	CFG_WheelUpMouseButtonHook := !CFG_WheelUpMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "WheelDown" )
{
	CFG_WheelDownMouseButtonHook := !CFG_WheelDownMouseButtonHook
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "All Mouse Buttons" )
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
Else If  ( TRAY_TrayEvent != "All Mouse Buttons" ) and ( (CFG_LeftMouseButtonHook = 0) or (CFG_MiddleMouseButtonHook = 0) or (CFG_RightMouseButtonHook = 0) or (CFG_FourthMouseButtonHook = 0) or (CFG_FifthMouseButtonHook = 0) or (CFG_WheelUpMouseButtonHook = 0) or (CFG_WheelDownMouseButtonHook = 0) )
{
	CFG_AllMouseButtonsHook := 0
	Gosub, CFG_ApplySettings
}
Else If ( TRAY_TrayEvent != "All Mouse Buttons" ) and ( (CFG_LeftMouseButtonHook = 1) and (CFG_MiddleMouseButtonHook = 1) and (CFG_RightMouseButtonHook = 1) and (CFG_FourthMouseButtonHook = 1) and (CFG_FifthMouseButtonHook = 1) and (CFG_WheelUpMouseButtonHook = 1) and (CFG_WheelDownMouseButtonHook = 1) )
{
	CFG_AllMouseButtonsHook := 1
	Gosub, CFG_ApplySettings
}

If ( TRAY_TrayEvent = "Configuration" )
{
	IfExist, %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
	Run, "%A_ScriptDir%\%SYS_ScriptNameNoExt%.ini"
}

Gosub, TRAY_TrayUpdate
Gosub, CFG_SaveSettings
TRAY_TrayEvent =
Return

TRAY_TrayHide:
SetTimer, TRAY_TrayHide, Off
Menu, TRAY, NoIcon
Return

IfNotExist, %A_ScriptDir%\readme.txt
{
	TRAY_TrayEvent := "Help"
	Gosub, TRAY_TrayEvent
	Suspend, On
	Sleep, 10000
	ExitApp, 1
}

IfNotExist, %A_ScriptDir%\license.txt
{
	TRAY_TrayEvent := "View License"
	Gosub, TRAY_TrayEvent
	Suspend, On
	Sleep, 10000
	ExitApp, 1
}

TRAY_TrayEvent := "About script"
SYS_TrayTipSeconds = 2
Gosub, TRAY_TrayEvent
Return