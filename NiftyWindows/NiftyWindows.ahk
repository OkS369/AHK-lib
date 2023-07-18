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

; [SYS] autostart section
SYS_StartTime := A_NowUTC
Gosub, SYS_ParseCommandLine
Gosub, CFG_LoadSettings
Gosub, CFG_ApplySettings
Gosub, TRY_TrayInit
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

IfNotExist, %A_ScriptDir%\readme.txt
{
	TRY_TrayEvent := "Help"
	Gosub, TRY_TrayEvent
	Suspend, On
	Sleep, 10000
	ExitApp, 1
}

IfNotExist, %A_ScriptDir%\license.txt
{
	TRY_TrayEvent := "View License"
	Gosub, TRY_TrayEvent
	Suspend, On
	Sleep, 10000
	ExitApp, 1
}

TRY_TrayEvent := "About script"
SYS_TrayTipSeconds = 2
Gosub, TRY_TrayEvent
Return

#Include *i %A_ScriptDir%\_SUS.ahk


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

; [SYS] copy old logs and create new log file

#,::
SYS_ClearLogs:
{
	OldLogsDirName := "Logs"
	FileCopy, %A_ScriptDir%\logfile.log, %A_ScriptDir%\%OldLogsDirName%\%SYS_StartTime%.log, 1
	FileDelete, %A_ScriptDir%\logfile.log
	FileAppend, % A_NowUTC ": Started logging`n", %A_ScriptDir%\logfile.log
	SYS_ToolTipText = NiftyWindows logs was reseted. Old logs was saved to another file.
	Gosub, SYS_ToolTipFeedbackShow
	WriteLog("NiftyWindows logs was reseted. Old logs was saved to another file.")
}
Return

WriteLog(text) {
	FileAppend, % A_NowUTC ": " text "`n",  %A_ScriptDir%\logfile.log
}

;[SYS] provides reversion of all visual effects

/**
	* This powerful hotkey removes all visual effects (like on exit) that have
	* been made before by NiftyWindows. You can use this action as a fall-back
	* solution to quickly revert any always-on-top, rolled windows and
	* transparency features you've set before.
*/

^#BS::
^!BS::
SYS_RevertVisualEffects:
Gosub, AOT_SetAllOff
Gosub, ROL_RollDownAll
Gosub, TRA_TransparencyAllOff
SYS_TrayTipText = All visual effects (AOT, Roll, Transparency) were reverted
Gosub, SYS_TrayTipShow
WriteLog("All visual effects (AOT, Roll, Transparency) were reverted")
Return

; [SYS] Load modules with main functionality

; Nifty Windows Dragging
#Include *i %A_ScriptDir%\_NWD.ahk
; Changing Active Window
#Include *i %A_ScriptDir%\_CAW.ahk
; Size changer
#Include *i %A_ScriptDir%\_SIZ.ahk
; Always On Top
#Include *i %A_ScriptDir%\_AOT.ahk
; Transparency handler
#Include *i %A_ScriptDir%\_TRA.ahk
; Addons
#Include *i %A_ScriptDir%\Addons\Addons_entry.ahk

; [SCR] starts the user defined screensaver

/**
	* Starts the user defined screensaver (password protection aware).
*/

#^l up::
#!l up::
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
IniRead, SYS_ScriptBuild, %CFG_IniFile%, Info, Build
IniRead, SYS_ScriptVersion, %CFG_IniFile%, Info, Version
IniRead, SYS_Debuging, %CFG_IniFile%, Main, Debuging, 0
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
IniWrite, %SYS_Debuging%, %CFG_IniFile%, Main, Debuging
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

; [UPD] checks for a new build

UPD_CheckForUpdate:
UPD_CheckSuccess =
Random, UPD_Random
If ( TEMP )
	UPD_BuildFile = %TEMP%\%SYS_ScriptNameNoExt%.%UPD_Random%.tmp
Else
	UPD_BuildFile = %SYS_ScriptDir%\%SYS_ScriptNameNoExt%.%UPD_Random%.tmp
Gosub, SUS_SuspendSaveState
Suspend, On
URLDownloadToFile, http://www.enovatic.org/products/niftywindows/files/build.txt?random=%UPD_Random%, %UPD_BuildFile%
Gosub, SUS_SuspendRestoreState
If ( !ErrorLevel )
{
	FileReadLine, UPD_Build, %UPD_BuildFile%, 1
	If ( !ErrorLevel )
		If UPD_Build is digit
		{
			UPD_CheckSuccess = 1
			UPD_LastUpdateCheck = %A_MM%
			If ( UPD_Build > SYS_ScriptBuild )
			{
				SYS_TrayTipText = There is a new version available. Please check website.
				SYS_TrayTipOptions = 1
				Run, http://www.enovatic.org/products/niftywindows/
			}
			Else
				SYS_TrayTipText = There is no new version available.
		}
	Else
		SYS_TrayTipText = wrong build pattern in downloaded build file
	Else
		SYS_TrayTipText = downloaded build file couldn't be read
}
Else
	SYS_TrayTipText = build file couldn't be downloaded
FileDelete, %UPD_BuildFile%
If ( !UPD_CheckSuccess )
{
	SYS_TrayTipText = Check for update failed:`n%SYS_TrayTipText%
	SYS_TrayTipOptions = 3
}
Gosub, SYS_TrayTipShow
Return

UPD_AutoCheckForUpdate:
If ( UPD_LastUpdateCheck != A_MM )
{
	Gosub, SUS_SuspendSaveState
	Suspend, On
	MsgBox, 4132, Update Handler - %SYS_ScriptInfo%, You haven't checked for updates for a long period of time (at least one month).`n`nDo you want NiftyWindows to check for a new version now (highly recommended)?
	Gosub, SUS_SuspendRestoreState
	IfMsgBox, Yes
		Gosub, UPD_CheckForUpdate
	Else
		UPD_LastUpdateCheck = %A_MM%
}
Return

#Include *i %A_ScriptDir%\_TRY.ahk


; [EDT] edits this script in notepad

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



; [REL] reloads this script on change

SYS_ScriptReload:
If ( A_IsCompiled )
	Return
CFG_IniFile = %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
FileGetAttrib, Main_File_Attribs, %A_ScriptFullPath%
FileGetAttrib, AOT_Attribs, %A_ScriptDir%\_AOT.ahk
FileGetAttrib, CAW_Attribs, %A_ScriptDir%\_CAW.ahk
FileGetAttrib, NWD_Attribs, %A_ScriptDir%\_NWD.ahk
FileGetAttrib, SIZ_Attribs, %A_ScriptDir%\_SIZ.ahk
FileGetAttrib, SUS_Attribs, %A_ScriptDir%\_SUS.ahk
FileGetAttrib, TRA_Attribs, %A_ScriptDir%\_TRA.ahk
FileGetAttrib, TRY_Attribs, %A_ScriptDir%\_TRY.ahk
FileGetAttrib, Addons_Attribs, %A_ScriptDir%\Addons\Addons_entry.ahk
FileGetAttrib, Addons_WinGrid_Attribs, %A_ScriptDir%\Addons\WinGrid.ahk
Files_Attribs :=Main_File_Attribs AOT_Attribs CAW_Attribs NWD_Attribs SIZ_Attribs SUS_Attribs TRA_Attribs TRY_Attribs Addons_Attribs Addons_WinGrid_Attribs
IfInString, Files_Attribs, A
{
	FileSetAttrib, -A, %A_ScriptFullPath%
	FileSetAttrib, -A, %A_ScriptDir%\_AOT.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_CAW.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_NWD.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_SIZ.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_SUS.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_TRA.ahk
	FileSetAttrib, -A, %A_ScriptDir%\_TRY.ahk
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

; [RERUN] rerun this script

SYS_ScripRerun:
#!u::
Suspend, Permit
{
	Run, %A_ScriptFullPath%
	SYS_TrayTipText = NiftyWindows is reruned!
	Gosub, SYS_TrayTipShow
}
Return

; [EXT] exits this script

SYS_ScriptExit:
#!F10::
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