; [SUS] provides suspend services

#!S::
SUS_AutoSuspendToggle:
Suspend, Permit
{
	SUS_AutoSuspend := !SUS_AutoSuspend
	Gosub, CFG_ApplySettings
	Gosub, SUS_SuspendHandler
}
Return

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

	SUS_Allowed_Margin := 10
	; If no border (0x800000 is WS_BORDER) and not minimized (0x20000000 is WS_MINIMIZE), but H and W equals to screen size => FullScreenWindowed
	isFullScreenWindowed := ((SUS_WinStyle & 0x20800000) or (SUS_WinH < A_ScreenHeight - SUS_Allowed_Margin) or (SUS_WinW < A_ScreenWidth - SUS_Allowed_Margin)) ? false : true
	; If maximized, H and W equals to screen size or larger => FullScreen
	isFullScreen := (SUS_WinMinMax == 1) and ((SUS_WinX <= 0) and (SUS_WinY <= 0)) and ((SUS_WinW >= A_ScreenWidth - SUS_Allowed_Margin) and (SUS_WinH >= A_ScreenHeight - SUS_Allowed_Margin))
	
	; Log("isFullScreenWindowed " isFullScreenWindowed " | isFullScreen " isFullScreen,"INFO")

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