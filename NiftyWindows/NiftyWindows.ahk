/*
	* NiftyWindows by OkS
	* with AutoHotKey
	* http://www.autohotkey.com/
*/

#SingleInstance force
#HotkeyInterval 100
#MaxHotkeysPerInterval 10
#InstallKeybdHook
#InstallMouseHook
#NoEnv
#MaxThreadsBuffer On
SetBatchLines -1
ListLines Off
Process, Priority, , HIGH
DetectHiddenWindows, On
DetectHiddenText, On
SetKeyDelay, 0, 0
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, 0
SetControlDelay, 0
SetCapsLockState, AlwaysOff

SYS_ScriptVersion := 0.10.3

; [SYS] autostart section
SYS_StartTime := A_NowUTC
Gosub, SYS_ParseCommandLine
Gosub, CFG_LoadSettings
Gosub, CFG_ApplySettings
Gosub, TRAY_TrayInit
Gosub, SYS_ContextCheck
if ( !A_IsCompiled )
	SetTimer, SYS_ScriptReload, 1000
OnExit, SYS_ExitHandler
Gosub, SYS_ClearLogs

; [SYS] parses command line parameters

SYS_ParseCommandLine:
Loop %0%
	If ( (%A_Index% = "/x") or (%A_Index% = "/exit") )
		ExitApp
Return

; [SYS] exit handler

SYS_ExitHandler:
Gosub, AOT_ExitHandler
Gosub, ROL_ExitHandler
Gosub, TRA_ExitHandler
Gosub, CFG_SaveSettings
WinClose AutoHotkey
WinClose AutoHotkey.exe
ExitApp

; [SYS] context check

SYS_ContextCheck:
Gosub, SYS_TrayTipBalloonCheck
If ( !SYS_TrayTipBalloon )
{
	Gosub, SUS_SuspendSaveState
	Suspend, On
	MsgBox, 4148, Balloon Handler - %SYS_ScriptInfo%, The balloon messages are disabled on your system. These visual messages`nabove the system tray are often used by tools as additional information four`nyour interest.`n`nNiftyWindows uses balloon messages to show you some important operating`ndetails. If you leave the messages disabled NiftyWindows will show some plain`nmessages as tooltips instead (in front of the system tray).`n`nDo you want to enable balloon messages now (highly recommended)?
	Gosub, SUS_SuspendRestoreState
	IfMsgBox, Yes
	{
		SYS_TrayTipBalloon = 1
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, EnableBalloonTips, %SYS_TrayTipBalloon%
		RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, EnableBalloonTips, %SYS_TrayTipBalloon%
		SendMessage, 0x001A, , , , ahk_id 0xFFFF ; 0x001A is WM_SETTINGCHANGE ; 0xFFFF is HWND_BROADCAST
		Sleep, 500 ; lets the other windows relax
	}
}

; [SUS] provides suspend services

#!X::
SUS_SuspendToggle:
Suspend, Permit
If ( !A_IsSuspended )
{
	Suspend, On
	Log("NiftyWindows is manualy suspended")
	SYS_TrayTipText = NiftyWindows is suspended now.`nPress WIN+ALT+X to resume it again.
	SYS_TrayTipOptions = 2
}
Else
{
	Suspend, Off
	Log("NiftyWindows is manualy resumed")
	SYS_TrayTipText = NiftyWindows is resumed now.`nPress WIN+ALT+X to suspend it again.
}
Gosub, SUS_SuspendSaveState
If (SUS_AutoSuspend) 
{
	SUS_AutoSuspend := !SUS_AutoSuspend
	Gosub, CFG_ApplySettings
}
Gosub, SYS_TrayTipShow
Gosub, TRAY_TrayUpdate
Return

SUS_SuspendSaveState:
SUS_Suspended := A_IsSuspended
Return

SUS_SuspendRestoreState:
If ( SUS_Suspended )
	Suspend, On
Else
	Suspend, Off
Return


SUS_SuspendHandler:
IfWinActive, A
{
	WinGet, SUS_WinID, ID
	If ( !SUS_WinID )
		Return
	WinGet, SUS_WinMinMax, MinMax, ahk_id %SUS_WinID%
	WinGetPos, SUS_WinX, SUS_WinY, SUS_WinW, SUS_WinH, ahk_id %SUS_WinID%
	WinGetClass, SUS_WinClass, ahk_id %SUS_WinID%
	WinGet, SUS_WinStyle, Style, ahk_id %SUS_WinID%
	WinGet, SUS_WinEXStyle, EXStyle, ahk_id %SUS_WinID%

	; If no border (0x800000 is WS_BORDER) and not minimized (0x20000000 is WS_MINIMIZE), but H and W equals to screen size => FullScreenWindowed
	isFullScreenWindowed := ((SUS_WinStyle & 0x20800000) or (SUS_WinH < A_ScreenHeight) or (SUS_WinW < A_ScreenWidth)) ? false : true
	; If maximized, H and W equals to screen size or larger => FullScreen
	isFullScreen := (SUS_WinMinMax == 1) and ((SUS_WinX <= 0) and (SUS_WinY <= 0)) and ((SUS_WinW >= A_ScreenWidth) and (SUS_WinH >= A_ScreenHeight))

	If ( isFullScreenWindowed or isFullScreen)
	{
		WinGetClass, SUS_WinClass, ahk_id %SUS_WinID%
		WinGet, SUS_ProcessName, ProcessName, ahk_id %SUS_WinID%
		SplitPath, SUS_ProcessName, , , SUS_ProcessExt
		Ignored := SUS_WinClass = "Progman" or SUS_WinClass = "Shell_TrayWnd" or SUS_WinClass = "WorkerW" or SUS_WinClass = "CabinetWClass"
		SUS_Condition := !Ignored and (SUS_ProcessExt != "scr")
		If (SUS_Condition)
		{
			SUS_FullScreenSuspendState := A_IsSuspended
			If ( !A_IsSuspended )
			{
				Suspend, On
				If SYS_ToolTipFeedback
				{
					SYS_ToolTipText = NiftyWindows is suspended now.`nPress WIN+X to resume it again.
					SYS_ToolTipSeconds = 1
					SYS_ToolTipX = 1560
					SYS_ToolTipY = 1012
					Gosub, SYS_ToolTipShow
				}
				Gosub, TRAY_TrayUpdate
			}
		}
	}
	Else
	{
		If ( A_IsSuspended )
		{
			Log("Unspended")
			Suspend, Off
			If SYS_ToolTipFeedback
			{
				SYS_ToolTipText = NiftyWindows is resumed now.`nPress WIN+X to suspend it again.
				SYS_ToolTipSeconds = 1
				SYS_ToolTipX = 1560
				SYS_ToolTipY = 1012
				Gosub, SYS_ToolTipShow
			}
			Gosub, TRAY_TrayUpdate
			Sleep, 100
		}
	}
	If (SUS_SuspendOnIdle = 1)
	{
		If (SUS_WinClass in SUS_IdleCheckTimeWhiteListApp )
		{
			IdleCheckTime = SUS_IdleCheckTime
		}
		Else If ( SUS_WinClass not in SUS_IdleCheckTimeWhiteListApp)
		{
			IdleCheckTime = SUS_IdleCheckTimeWhiteListApp
		}
		If ( A_TimeIdlePhysical > IdleCheckTime )
		{
			SYS_ToolTipText = The last  activity was at least 10 minutes ago.
			SYS_ToolTipX = 1560
			SYS_ToolTipY = 1012
			SYS_ToolTipSeconds = 2
			Gosub, SYS_ToolTipShow
			TimeIdlePhysical = 1
			If ( !A_IsSuspended )
			{
				Log("Suspended on idle")
				Suspend, On
				SYS_ToolTipText = NiftyWindows is paused now.`nPress Pause to resume it again.
				SYS_ToolTipSeconds = 1
				SYS_ToolTipX = 1560
				SYS_ToolTipY = 1012
				Gosub, SYS_ToolTipShow
				Gosub, TRAY_TrayUpdate
			}
		 ;DllCall("LockWorkStation")
		}
		Else If ( ( A_TimeIdlePhysical < IdleCheckTime ) and (!SUS_FullScreenSuspend) and (TimeIdlePhysical) )
		{
			Suspend, Off
		}
	}
}
Return


; [SYS] handles tooltips

SYS_ToolTipShow:
If ( SYS_ToolTipText )
{
	If ( !SYS_ToolTipSeconds )
		SYS_ToolTipSeconds = 2
	SYS_ToolTipMillis := SYS_ToolTipSeconds * 1000
	CoordMode, Mouse, Screen
	CoordMode, ToolTip, Screen
	If ( !SYS_ToolTipX or !SYS_ToolTipY )
	{
		MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
		SYS_ToolTipX += 16
		SYS_ToolTipY += 24
	}
	ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
	SetTimer, SYS_ToolTipHandler, %SYS_ToolTipMillis%
}
SYS_ToolTipText =
SYS_ToolTipSeconds =
SYS_ToolTipX =
SYS_ToolTipY =
Return

SYS_ToolTipFeedbackShow:
If ( SYS_ToolTipFeedback )
	Gosub, SYS_ToolTipShow
SYS_ToolTipText =
SYS_ToolTipSeconds =
SYS_ToolTipX =
SYS_ToolTipY =
Return

SYS_ToolTipHandler:
SetTimer, SYS_ToolTipHandler, Off
ToolTip
Return

RemoveToolTip:
ToolTip
Return


; [SYS] handles balloon messages

SYS_TrayTipShow:
If ( SYS_TrayTipText )
{
	If ( !SYS_TrayTipTitle )
		SYS_TrayTipTitle = %SYS_ScriptInfo%
	If ( !SYS_TrayTipSeconds )
		SYS_TrayTipSeconds = 1
	If ( !SYS_TrayTipOptions )
		SYS_TrayTipOptions = 17
	SYS_TrayTipMillis := SYS_TrayTipSeconds * 1000
	Gosub, SYS_TrayTipBalloonCheck
	If ( SYS_TrayTipBalloon and !A_IconHidden )
	{
		TrayTip, %SYS_TrayTipTitle%, %SYS_TrayTipText%, %SYS_TrayTipSeconds%, %SYS_TrayTipOptions%
		SetTimer, SYS_TrayTipHandler, %SYS_TrayTipMillis%
	}
	Else
	{
		TrayTip
		SYS_ToolTipText = %SYS_TrayTipTitle%:`n`n%SYS_TrayTipText%
		SYS_ToolTipSeconds = %SYS_TrayTipSeconds%
		SysGet, SYS_TrayTipDisplay, Monitor
		SYS_ToolTipX = %SYS_TrayTipDisplayRight%
		SYS_ToolTipY = %SYS_TrayTipDisplayBottom%
		Gosub, SYS_ToolTipShow
	}
}
SYS_TrayTipTitle =
SYS_TrayTipText =
SYS_TrayTipSeconds =
SYS_TrayTipOptions =
Return

SYS_TrayTipHandler:
SetTimer, SYS_TrayTipHandler, Off
TrayTip
Return

SYS_TrayTipBalloonCheck:
RegRead, SYS_TrayTipBalloonCU, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, EnableBalloonTips
SYS_TrayTipBalloonCU := ErrorLevel or SYS_TrayTipBalloonCU
RegRead, SYS_TrayTipBalloonLM, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, EnableBalloonTips
SYS_TrayTipBalloonLM := ErrorLevel or SYS_TrayTipBalloonLM
SYS_TrayTipBalloon := SYS_TrayTipBalloonCU and SYS_TrayTipBalloonLM
Return


; [RERUN] rerun this script manually

#!r::
SYS_ScripRerun:
Suspend, Permit
{
	Run, %A_ScriptFullPath%
	SYS_TrayTipText = NiftyWindows is reruned!
	Gosub, SYS_TrayTipShow
}
Return

; open script folder in explorer

SYS_ScriptFolder:
#!F8::
Gosub, SUS_SuspendSaveState
Suspend, On
MsgBox, 4129, Edit Handler - %SYS_ScriptInfo%, You pressed the hotkey for opening script folder:`n`n%A_ScriptDir%`n`nDo you really want to proceed?
Gosub, SUS_SuspendRestoreState
IfMsgBox, OK
	Run, explorer.exe %A_ScriptDir%
Return

; [EDT] edits this script in notepad++

SYS_ScriptEdit:
#!F9::
If ( A_IsCompiled )
	Return

Gosub, SUS_SuspendSaveState
Suspend, On
MsgBox, 4129, Edit Handler - %SYS_ScriptInfo%, You pressed the hotkey for editing this script:`n`n%A_ScriptFullPath%`n`nDo you really want to edit?
Gosub, SUS_SuspendRestoreState
IfMsgBox, OK
	Run, notepad++.exe %A_ScriptFullPath%
Return

; [EXIT] exits this script

#!F10::
SYS_ScriptExit:
If ( A_IconHidden )
{
	Menu, TRAY, Icon
	SYS_TrayTipText = Tray icon is shown now.`nPress WIN+Alt+F10 again to exit NiftyWindows.
	SYS_TrayTipSeconds = 5
	Gosub, SYS_TrayTipShow
	Return
}

If ( A_IsCompiled )
{
	SYS_TrayTipText = NiftyWindows will exit now.`nYou can find it here (to start it again):`n%A_ScriptFullPath%
	SYS_TrayTipOptions = 2
	SYS_TrayTipSeconds = 5
	Gosub, SYS_TrayTipShow
	Suspend, On
	Sleep, 5000
	ExitApp
}

Gosub, SUS_SuspendSaveState
Suspend, On
MsgBox, 4145, Exit Handler - %SYS_ScriptInfo%, You pressed the hotkey for exiting this script:`n`n%A_ScriptFullPath%`n`nDo you really want to exit?
Gosub, SUS_SuspendRestoreState
IfMsgBox, OK
	ExitApp
Return

; [SYS] reset logs and copy old logs to different file if debug on

#,::
SYS_ClearLogs:
{
	If (SYS_Debug) {
		OldLogsDirName := "Logs"

		Level := Format("{:U}", "debug")
		Timestamp := % A_DD "/" A_MM "/" A_YYYY " " A_Hour ":" A_Min ":" A_Sec "." A_MSec
		LogMessage := % Timestamp " [" Level "] " "Nifty Windows logging started`n"

		FileCopy, %A_ScriptDir%\logfile.log, %A_ScriptDir%\%OldLogsDirName%\%SYS_StartTime%.log, 1
		FileDelete, %A_ScriptDir%\logfile.log
		FileAppend, %LogMessage%, %A_ScriptDir%\logfile.log
		SYS_ToolTipText = NiftyWindows logs was reseted. Old logs was saved to another file.
		Gosub, SYS_ToolTipFeedbackShow
	}
}
Return

; [SYS] add log messages to file if debug on

Log(text, log_level := "debug", rows_before := 0, rows_after := 0) {
	If (global SYS_Debug)
	{
		Loop, %rows_before% {
			FileAppend, `n,  %A_ScriptDir%\logfile.log
		}

		Level := Format("{:U}", log_level)
		Timestamp := % A_DD "/" A_MM "/" A_YYYY " " A_Hour ":" A_Min ":" A_Sec "." A_MSec
		LogMessage := % Timestamp " [" Level "] " text "`n"
		FileAppend, %LogMessage%,  %A_ScriptDir%\logfile.log

		Loop, %rows_before% {
			FileAppend, `n,  %A_ScriptDir%\logfile.log
		}
	}
}

;[SYS] provides reversion of all visual effects

/**
	* This powerful hotkey removes all visual effects (like on exit) that have
	* been made before by NiftyWindows. You can use this action as a fall-back
	* solution to quickly revert any always-on-top, rolled windows and
	* transparency features you've set before.
*/

^!BS::
SYS_RevertVisualEffects:
Gosub, AOT_SetAllOff
Gosub, ROL_RollDownAll
Gosub, TRA_TransparencyAllOff
SYS_TrayTipText = All visual effects (AOT, Roll, Transparency) were reverted
Gosub, SYS_TrayTipShow
Log("All visual effects (AOT, Roll, Transparency) were reverted")
Return

; [SCR] starts the user defined screensaver

/**
	* Starts the user defined screensaver (password protection aware).
*/

#^l up::
#!l up::
; SYS_StartScreensaver:
RegRead, SCR_Saver, HKEY_CURRENT_USER, Control Panel\Desktop, SCRNSAVE.EXE
If ( !ErrorLevel and SCR_Saver )
{
	SendMessage, 0x112, 0xF140, 0, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF140 is SC_SCREENSAVE
	If ( A_ThisHotkey != "#!l up" )
		Return
	SplitPath, SCR_Saver, SCR_SaverFileName
	Process, Wait, %SCR_SaverFileName%, 5
	If ( ErrorLevel )
	{
		Gosub, SUS_SuspendSaveState
		Suspend, On
		Sleep, 500
		Gosub, SUS_SuspendRestoreState
		Process, Exist, %SCR_SaverFileName%
		If ( ErrorLevel )
			SendMessage, 0x112, 0xF170, 2, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF170 is SC_MONITORPOWER ; (2 = off, 1 = standby, -1 = on)
	}
	
}
Else
{
	SYS_TrayTipText = No screensaver specified in display settings (control panel).
	SYS_TrayTipOptions = 2
	Gosub, SYS_TrayTipShow
}
Return

; [XWN] provides X Window like focus switching (focus follows mouse)

/**
	* Provided a 'X Window' like focus switching by mouse cursor movement. After
	* activation of this feature (by using the responsible entry in the tray icon
	* menu) the focus will follow the mouse cursor with a delayed focus change
	* (after movement end) of 500 milliseconds (half a second). This feature is
	* disabled per default to avoid any confusion due to the new user-interface-flow.
*/

XWN_FocusHandler:
CoordMode, Mouse, Screen
MouseGetPos, XWN_MouseX, XWN_MouseY, XWN_WinID
If ( !XWN_WinID )
	Return

If ( (XWN_MouseX != XWN_MouseOldX) or (XWN_MouseY != XWN_MouseOldY) )
{
	IfWinNotActive, ahk_id %XWN_WinID%
		XWN_FocusRequest = 1
	Else
		XWN_FocusRequest = 0
	
	XWN_MouseOldX := XWN_MouseX
	XWN_MouseOldY := XWN_MouseY
	XWN_MouseMovedTickCount := A_TickCount
}
Else
	If ( XWN_FocusRequest and (A_TickCount - XWN_MouseMovedTickCount > 500) )
	{
		WinGetClass, XWN_WinClass, ahk_id %XWN_WinID%
		If ( XWN_WinClass = "Progman" )
			Return
		
		; checks wheter the selected window is a popup menu
		; (WS_POPUP) and !(WS_DLGFRAME | WS_SYSMENU | WS_THICKFRAME)
		WinGet, XWN_WinStyle, Style, ahk_id %XWN_WinID%
		If ( (XWN_WinStyle & 0x80000000) and !(XWN_WinStyle & 0x4C0000) )
			Return
		
		IfWinNotActive, ahk_id %XWN_WinID%
			WinActivate, ahk_id %XWN_WinID%
		
		XWN_FocusRequest = 0
}
Return

SYS_ScriptInfo = %SYS_ScriptNameNoExt% %SYS_ScriptVersion%
; [CFG] handles the persistent configuration

CFG_LoadSettings:
SplitPath, A_ScriptFullPath, SYS_ScriptNameExt, SYS_ScriptDir, SYS_ScriptExt, SYS_ScriptNameNoExt, SYS_ScriptDrive
CFG_IniFile = %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini

global SYS_Debug
IniRead, SYS_ScriptBuild, %CFG_IniFile%, Info, Build
IniRead, SYS_ScriptVersion, %CFG_IniFile%, Info, Version
IniRead, SYS_Debug, %CFG_IniFile%, Main, Debug, 0
IniRead, SUS_AutoSuspend, %CFG_IniFile%, Suspending, AutoSuspend, 1
IniRead, SUS_SuspendOnIdle, %CFG_IniFile%, Suspending, SuspendOnIdle, 0
IniRead, SUS_IdleCheckTime, %CFG_IniFile%, Suspending, IdleCheckTime, 6000000
IniRead, SUS_IdleCheckTimeWhiteListApp, %CFG_IniFile%, Suspending, IdleCheckTimeWhiteListApp, 180000000
IniRead, SUS_IdleWhiteListApps, %CFG_IniFile%, Suspending, IdleWhiteListApps, []
IniRead, XWN_FocusFollowsMouse, %CFG_IniFile%, WindowHandling, FocusFollowsMouse, 0
IniRead, WindowsDraging, %CFG_IniFile%, WindowHandling, WindowsDraging, 0
IniRead, SYS_ToolTipFeedback, %CFG_IniFile%, Visual, ToolTipFeedback, 1
IniRead, UPD_LastUpdateCheck, %CFG_IniFile%, UpdateCheck, LastUpdateCheck, %A_MM%
IniRead, CFG_AllMouseButtonsHook, %CFG_IniFile%, MouseHooks, AllMouseButtons, 1
IniRead, CFG_LeftMouseButtonHook, %CFG_IniFile%, MouseHooks, LeftMouseButton, 1
IniRead, CFG_MiddleMouseButtonHook, %CFG_IniFile%, MouseHooks, MiddleMouseButton, 1
IniRead, CFG_RightMouseButtonHook, %CFG_IniFile%, MouseHooks, RightMouseButton, 1
IniRead, CFG_FourthMouseButtonHook, %CFG_IniFile%, MouseHooks, FourthMouseButton, 1
IniRead, CFG_FifthMouseButtonHook, %CFG_IniFile%, MouseHooks, FifthMouseButton, 1
IniRead, CFG_WheelUpMouseButtonHook, %CFG_IniFile%, MouseHooks, WheelUpMouseButton, 1
IniRead, CFG_WheelDownMouseButtonHook, %CFG_IniFile%, MouseHooks, WheelDownMouseButton, 1
Return

CFG_SaveSettings:
CFG_IniFile = %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
IniWrite, %SYS_ScriptBuild%, %CFG_IniFile%, Info, Build
IniWrite, %SYS_ScriptVersion%, %CFG_IniFile%, Info, Version
IniWrite, %SUS_AutoSuspend%, %CFG_IniFile%, Suspending, AutoSuspend
IniWrite, %SUS_SuspendOnIdle%, %CFG_IniFile%, Suspending, SuspendOnIdle
IniWrite, %SUS_IdleCheckTime%, %CFG_IniFile%, Suspending, IdleCheckTime
IniWrite, %SUS_IdleCheckTimeWhiteListApp%, %CFG_IniFile%, Suspending, IdleCheckTimeWhiteListApp
IniWrite, %SUS_IdleWhiteListApps%, %CFG_IniFile%, Suspending, IdleWhiteListApps
IniWrite, %SYS_Debug%, %CFG_IniFile%, Main, Debug
IniWrite, %XWN_FocusFollowsMouse%, %CFG_IniFile%, WindowHandling, FocusFollowsMouse
IniWrite, %WindowsDraging%, %CFG_IniFile%, WindowHandling, WindowsDraging
IniWrite, %SYS_ToolTipFeedback%, %CFG_IniFile%, Visual, ToolTipFeedback
IniWrite, %UPD_LastUpdateCheck%, %CFG_IniFile%, UpdateCheck, LastUpdateCheck
IniWrite, %CFG_AllMouseButtonsHook%, %CFG_IniFile%, MouseHooks, AllMouseButtons
IniWrite, %CFG_LeftMouseButtonHook%, %CFG_IniFile%, MouseHooks, LeftMouseButton
IniWrite, %CFG_MiddleMouseButtonHook%, %CFG_IniFile%, MouseHooks, MiddleMouseButton
IniWrite, %CFG_RightMouseButtonHook%, %CFG_IniFile%, MouseHooks, RightMouseButton
IniWrite, %CFG_FourthMouseButtonHook%, %CFG_IniFile%, MouseHooks, FourthMouseButton
IniWrite, %CFG_FifthMouseButtonHook%, %CFG_IniFile%, MouseHooks, FifthMouseButton
IniWrite, %CFG_WheelUpMouseButtonHook%, %CFG_IniFile%, MouseHooks, WheelUpMouseButton
IniWrite, %CFG_WheelDownMouseButtonHook%, %CFG_IniFile%, MouseHooks, WheelDownMouseButton
Return

CFG_ApplySettings:
If ( SUS_AutoSuspend and !SUS_Suspended )
	SetTimer, SUS_SuspendHandler, 100
Else
	SetTimer, SUS_SuspendHandler, Off

If ( XWN_FocusFollowsMouse )
	SetTimer, XWN_FocusHandler, 100
Else
	SetTimer, XWN_FocusHandler, Off

If ( CFG_AllMouseButtonsHook )
{
	CFG_AllMouseButtonsHookStr = On
	
	CFG_LeftMouseButtonHookStr = On
	CFG_MiddleMouseButtonHookStr = On
	CFG_RightMouseButtonHookStr = On
	CFG_FourthMouseButtonHookStr = On
	CFG_FifthMouseButtonHookStr = On
	CFG_WheelUpMouseButtonHookStr = On
	CFG_WheelDownMouseButtonHookStr = On
}
Else
{
	CFG_AllMouseButtonsHookStr = Off
	
	If ( CFG_LeftMouseButtonHook )
		CFG_LeftMouseButtonHookStr = On
	Else
		CFG_LeftMouseButtonHookStr = Off
	
	If ( CFG_MiddleMouseButtonHook )
		CFG_MiddleMouseButtonHookStr = On
	Else
		CFG_MiddleMouseButtonHookStr = Off
	
	If ( CFG_RightMouseButtonHook )
		CFG_RightMouseButtonHookStr = On
	Else
		CFG_RightMouseButtonHookStr = Off
	
	If ( CFG_FourthMouseButtonHook )
		CFG_FourthMouseButtonHookStr = On
	Else
		CFG_FourthMouseButtonHookStr = Off
	
	If ( CFG_FifthMouseButtonHook )
		CFG_FifthMouseButtonHookStr = On
	Else
		CFG_FifthMouseButtonHookStr = Off
	
	If ( CFG_WheelUpMouseButtonHook )
		CFG_WheelUpMouseButtonHookStr = On
	Else
		CFG_WheelUpMouseButtonHookStr = Off
	
	If ( CFG_WheelDownMouseButtonHook )
		CFG_WheelDownMouseButtonHookStr = On
	Else
		CFG_WheelDownMouseButtonHookStr = Off
}
Return

; [SYS] Load modules with main functionality

; TRAY settings
#Include *i %A_ScriptDir%\_TRAY.ahk
; Nifty Windows Dragging
#Include *i %A_ScriptDir%\_NWD.ahk
; Changing Active Window
#Include *i %A_ScriptDir%\_CAW.ahk
; Always On Top
#Include *i %A_ScriptDir%\_AOT.ahk
; TRAnsparency handler
#Include *i %A_ScriptDir%\_TRA.ahk
; Nifty Windows Grid
#Include *i %A_ScriptDir%\_NWG.ahk
; Addons
#Include *i %A_ScriptDir%\Addons\Addons_entry.ahk


; [REL] reloads this script on change of any included part

SYS_ScriptReload:
If ( A_IsCompiled )
	Return
CFG_IniFile = %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
FileGetAttrib, Main_File_Attribs, %A_ScriptFullPath%
FileGetAttrib, AOT_Attribs, %A_ScriptDir%\_AOT.ahk
FileGetAttrib, CAW_Attribs, %A_ScriptDir%\_CAW.ahk
FileGetAttrib, NWD_Attribs, %A_ScriptDir%\_NWD.ahk
FileGetAttrib, NWG_Attribs, %A_ScriptDir%\_NWG.ahk
FileGetAttrib, TRA_Attribs, %A_ScriptDir%\_TRA.ahk
FileGetAttrib, TRAY_Attribs, %A_ScriptDir%\_TRAY.ahk
FileGetAttrib, Addons_Attribs, %A_ScriptDir%\Addons\Addons_entry.ahk
Files_Attribs :=Main_File_Attribs AOT_Attribs CAW_Attribs NWD_Attribs NWG_Attribs TRA_Attribs TRAY_Attribs Addons_Attribs
IfInString, Files_Attribs, A
{
	FileSetAttrib, -A, %A_ScriptFullPath%
	FileSetAttrib, -A, %A_ScriptDir%\_AOT.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_CAW.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_NWD.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_NWG.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_TRA.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_TRAY.ahk
	FileSetAttrib, -A, %A_ScriptDir%\Addons\Addons_entry.ahk
	FileSetAttrib, -A, %A_ScriptDir%\Addons\WinGrid.ahk
	If ( REL_InitDone )
	{
		Gosub, SUS_SuspendSaveState
		Suspend, On
		MsgBox, 4145, Update Handler - %SYS_ScriptInfo%, The following script has changed:`n`n%A_ScriptFullPath%`n`nReload and activate this script?
		Gosub, SUS_SuspendRestoreState
		IfMsgBox, OK
		{
			SYS_ScriptBuild++
			IniWrite, %SYS_ScriptBuild%, %CFG_IniFile%, Info, Build
			SYS_ScriptVersionArray := StrSplit(SYS_ScriptVersion,".")
			SYS_ScriptVersion =% SYS_ScriptVersionArray[1]"."SYS_ScriptVersionArray[2]"."SYS_ScriptVersionArray[3]"."SYS_ScriptBuild
			IniWrite, %SYS_ScriptVersion%, %CFG_IniFile%, Info, Version
			IniWrite, %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%, %CFG_IniFile%, Info, Edited
			Reload
		}
	}
}
REL_InitDone = 1
Return