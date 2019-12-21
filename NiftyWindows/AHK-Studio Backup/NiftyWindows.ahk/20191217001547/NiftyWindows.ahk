/*
 * NiftyWindows by OkS
 * with AutoHotKey
 * http://www.enovatic.org/products/niftywindows/
 * http://www.autohotkey.com/
*/

#SingleInstance force
#HotkeyInterval 10
#MaxHotkeysPerInterval 100
#NoTrayIcon
#InstallKeybdHook
#InstallMouseHook
#NoEnv
SetBatchLines -1
ListLines Off
Process, Priority, , HIGH
DetectHiddenWindows, On
DetectHiddenText, On
#MaxThreadsBuffer On

; [SYS] autostart section

if(FileExist(A_ScriptDir "\NiftyWindows.ico"))		; custom icon for script
	Menu,Tray,Icon,%A_ScriptDir%\NiftyWindows.ico 	;*[NiftyWindows]

SplitPath, A_ScriptFullPath, SYS_ScriptNameExt, SYS_ScriptDir, SYS_ScriptExt, SYS_ScriptNameNoExt, SYS_ScriptDrive
SYS_ScriptVersion = 0.9.9
SYS_ScriptBuild = 10012019
SYS_ScriptInfo = %SYS_ScriptNameNoExt% %SYS_ScriptVersion%

;Run, "%SYS_ScriptDir%\NumpadMouse.ahk"

SetKeyDelay, 0, 0
SetMouseDelay, 0
SetDefaultMouseSpeed, 0
SetWinDelay, 0
SetControlDelay, 0

Gosub, SYS_ParseCommandLine
Gosub, CFG_LoadSettings
Gosub, CFG_ApplySettings

if ( !A_IsCompiled )
	SetTimer, REL_ScriptReload, 1000

OnExit, SYS_ExitHandler

Gosub, TRY_TrayInit
Gosub, SYS_ContextCheck

BS := new BrightnessSetter()

class BrightnessSetter {
	; qwerty12 - 27/05/17
	; https://github.com/qwerty12/AutoHotkeyScripts/tree/master/LaptopBrightnessSetter
	static _WM_POWERBROADCAST := 0x218, _osdHwnd := 0, hPowrprofMod := DllCall("LoadLibrary", "Str", "powrprof.dll", "Ptr") 

	__New() {
		if (BrightnessSetter.IsOnAc(AC))
			this._AC := AC
		if ((this.pwrAcNotifyHandle := DllCall("RegisterPowerSettingNotification", "Ptr", A_ScriptHwnd, "Ptr", BrightnessSetter._GUID_ACDC_POWER_SOURCE(), "UInt", DEVICE_NOTIFY_WINDOW_HANDLE := 0x00000000, "Ptr"))) ; Sadly the callback passed to *PowerSettingRegister*Notification runs on a new threadl
			OnMessage(this._WM_POWERBROADCAST, ((this.pwrBroadcastFunc := ObjBindMethod(this, "_On_WM_POWERBROADCAST"))))
	}

	__Delete() {
		if (this.pwrAcNotifyHandle) {
			OnMessage(BrightnessSetter._WM_POWERBROADCAST, this.pwrBroadcastFunc, 0)
			,DllCall("UnregisterPowerSettingNotification", "Ptr", this.pwrAcNotifyHandle)
			,this.pwrAcNotifyHandle := 0
			,this.pwrBroadcastFunc := ""
		}
	}

	SetBrightness(increment, jump := False, showOSD := True, autoDcOrAc := -1, ptrAnotherScheme := 0)
	{
		static PowerGetActiveScheme := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerGetActiveScheme", "Ptr")
			  ,PowerSetActiveScheme := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerSetActiveScheme", "Ptr")
			  ,PowerWriteACValueIndex := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerWriteACValueIndex", "Ptr")
			  ,PowerWriteDCValueIndex := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerWriteDCValueIndex", "Ptr")
			  ,PowerApplySettingChanges := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerApplySettingChanges", "Ptr")

		if (increment == 0 && !jump) {
			if (showOSD)
				BrightnessSetter._ShowBrightnessOSD()
			return
		}

		if (!ptrAnotherScheme ? DllCall(PowerGetActiveScheme, "Ptr", 0, "Ptr*", currSchemeGuid, "UInt") == 0 : DllCall("powrprof\PowerDuplicateScheme", "Ptr", 0, "Ptr", ptrAnotherScheme, "Ptr*", currSchemeGuid, "UInt") == 0) {
			if (autoDcOrAc == -1) {
				if (this != BrightnessSetter) {
					AC := this._AC
				} else {
					if (!BrightnessSetter.IsOnAc(AC)) {
						DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
						return
					}
				}
			} else {
				AC := !!autoDcOrAc
			}

			currBrightness := 0
			if (jump || BrightnessSetter._GetCurrentBrightness(currSchemeGuid, AC, currBrightness)) {
				 maxBrightness := BrightnessSetter.GetMaxBrightness()
				,minBrightness := BrightnessSetter.GetMinBrightness()

				if (jump || !((currBrightness == maxBrightness && increment > 0) || (currBrightness == minBrightness && increment < minBrightness))) {
					if (currBrightness + increment > maxBrightness)
						increment := maxBrightness
					else if (currBrightness + increment < minBrightness)
						increment := minBrightness
					else
						increment += currBrightness

					if (DllCall(AC ? PowerWriteACValueIndex : PowerWriteDCValueIndex, "Ptr", 0, "Ptr", currSchemeGuid, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt", increment, "UInt") == 0) {
						; PowerApplySettingChanges is undocumented and exists only in Windows 8+. Since both the Power control panel and the brightness slider use this, we'll do the same, but fallback to PowerSetActiveScheme if on Windows 7 or something
						if (!PowerApplySettingChanges || DllCall(PowerApplySettingChanges, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt") != 0)
							DllCall(PowerSetActiveScheme, "Ptr", 0, "Ptr", currSchemeGuid, "UInt")
					}
				}

				if (showOSD)
					BrightnessSetter._ShowBrightnessOSD()
			}
			DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
		}
	}

	IsOnAc(ByRef acStatus)
	{
		static SystemPowerStatus
		if (!VarSetCapacity(SystemPowerStatus))
			VarSetCapacity(SystemPowerStatus, 12)

		if (DllCall("GetSystemPowerStatus", "Ptr", &SystemPowerStatus)) {
			acStatus := NumGet(SystemPowerStatus, 0, "UChar") == 1
			return True
		}

		return False
	}
	
	GetDefaultBrightnessIncrement()
	{
		static ret := 10
		DllCall("powrprof\PowerReadValueIncrement", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt")
		return ret
	}

	GetMinBrightness()
	{
		static ret := -1
		if (ret == -1)
			if (DllCall("powrprof\PowerReadValueMin", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt"))
				ret := 0
		return ret
	}

	GetMaxBrightness()
	{
		static ret := -1
		if (ret == -1)
			if (DllCall("powrprof\PowerReadValueMax", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt"))
				ret := 100
		return ret
	}

	_GetCurrentBrightness(schemeGuid, AC, ByRef currBrightness)
	{
		static PowerReadACValueIndex := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerReadACValueIndex", "Ptr")
			  ,PowerReadDCValueIndex := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerReadDCValueIndex", "Ptr")
		return DllCall(AC ? PowerReadACValueIndex : PowerReadDCValueIndex, "Ptr", 0, "Ptr", schemeGuid, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", currBrightness, "UInt") == 0
	}
	
	_ShowBrightnessOSD()
	{
		static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
			  ,WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
		if A_OSVersion in WIN_VISTA,WIN_7
			return
		BrightnessSetter._RealiseOSDWindowIfNeeded()
		; Thanks to YashMaster @ https://github.com/YashMaster/Tweaky/blob/master/Tweaky/BrightnessHandler.h for realising this could be done:
		if (BrightnessSetter._osdHwnd)
			DllCall(PostMessagePtr, "Ptr", BrightnessSetter._osdHwnd, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
	}

	_RealiseOSDWindowIfNeeded()
	{
		static IsWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", "IsWindow", "Ptr")
		if (!DllCall(IsWindow, "Ptr", BrightnessSetter._osdHwnd) && !BrightnessSetter._FindAndSetOSDWindow()) {
			BrightnessSetter._osdHwnd := 0
			try if ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
				try if ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
					 DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
					,ObjRelease(flyoutDisp)
				}
				ObjRelease(shellProvider)
				if (BrightnessSetter._FindAndSetOSDWindow())
					return
			}
			; who knows if the SID & IID above will work for future versions of Windows 10 (or Windows 8). Fall back to this if needs must
			Loop 2 {
				SendEvent {Volume_Mute 2}
				if (BrightnessSetter._FindAndSetOSDWindow())
					return
				Sleep 100
			}
		}
	}
	
	_FindAndSetOSDWindow()
	{
		static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")
		return !!((BrightnessSetter._osdHwnd := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")))
	}

	_On_WM_POWERBROADCAST(wParam, lParam)
	{
		;OutputDebug % &this
		if (wParam == 0x8013 && lParam && NumGet(lParam+0, 0, "UInt") == NumGet(BrightnessSetter._GUID_ACDC_POWER_SOURCE()+0, 0, "UInt")) { ; PBT_POWERSETTINGCHANGE and a lazy comparison
			this._AC := NumGet(lParam+0, 20, "UChar") == 0
			return True
		}
	}

	_GUID_VIDEO_SUBGROUP()
	{
		static GUID_VIDEO_SUBGROUP__
		if (!VarSetCapacity(GUID_VIDEO_SUBGROUP__)) {
			 VarSetCapacity(GUID_VIDEO_SUBGROUP__, 16)
			,NumPut(0x7516B95F, GUID_VIDEO_SUBGROUP__, 0, "UInt"), NumPut(0x4464F776, GUID_VIDEO_SUBGROUP__, 4, "UInt")
			,NumPut(0x1606538C, GUID_VIDEO_SUBGROUP__, 8, "UInt"), NumPut(0x99CC407F, GUID_VIDEO_SUBGROUP__, 12, "UInt")
		}
		return &GUID_VIDEO_SUBGROUP__
	}

	_GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS()
	{
		static GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__
		if (!VarSetCapacity(GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__)) {
			 VarSetCapacity(GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 16)
			,NumPut(0xADED5E82, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 0, "UInt"), NumPut(0x4619B909, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 4, "UInt")
			,NumPut(0xD7F54999, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 8, "UInt"), NumPut(0xCB0BAC1D, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 12, "UInt")
		}
		return &GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__
	}

	_GUID_ACDC_POWER_SOURCE()
	{
		static GUID_ACDC_POWER_SOURCE_
		if (!VarSetCapacity(GUID_ACDC_POWER_SOURCE_)) {
			 VarSetCapacity(GUID_ACDC_POWER_SOURCE_, 16)
			,NumPut(0x5D3E9A59, GUID_ACDC_POWER_SOURCE_, 0, "UInt"), NumPut(0x4B00E9D5, GUID_ACDC_POWER_SOURCE_, 4, "UInt")
			,NumPut(0x34FFBDA6, GUID_ACDC_POWER_SOURCE_, 8, "UInt"), NumPut(0x486551FF, GUID_ACDC_POWER_SOURCE_, 12, "UInt")
		}
		return &GUID_ACDC_POWER_SOURCE_
	}

}

BrightnessSetter_new() {
	return new BrightnessSetter()
}



;SetScrollLockState, Off

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
	Gosub, ShowCursor
	WinClose NumpadMouse.ahk - AutoHotkey
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



; [SUS] provides suspend services

#x::
SUS_SuspendToggle:
	Suspend, Permit
	If ( !A_IsSuspended )
	{
		Suspend, On
		SYS_TrayTipText = NiftyWindows is suspended now.`nPress WIN+X to resume it again.
		SYS_TrayTipOptions = 2
	}
	Else
	{
		Suspend, Off
		SYS_TrayTipText = NiftyWindows is resumed now.`nPress WIN+X to suspend it again.
	}
	Gosub, SYS_TrayTipShow
	Gosub, TRY_TrayUpdate
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
		If ( (SUS_WinClass != "Chrome_WidgetWin_1" ) and (SUS_WinClass != "MediaPlayerClassicW") )
			{
				IdleCheckTime = 600000
			}
		Else If ( (SUS_WinClass = "Chrome_WidgetWin_1" ) or (SUS_WinClass = "MediaPlayerClassicW") )
			{
				IdleCheckTime = 180000000
			}
		If ( (SUS_WinMinMax = 0) and (SUS_WinX = 0) and (SUS_WinY = 0) and (SUS_WinW = A_ScreenWidth) and (SUS_WinH = A_ScreenHeight)  ) 
		{
			WinGetClass, SUS_WinClass, ahk_id %SUS_WinID%
			WinGet, SUS_ProcessName, ProcessName, ahk_id %SUS_WinID%
			SplitPath, SUS_ProcessName, , , SUS_ProcessExt
			If ( (SUS_WinClass != "Progman") and (SUS_WinClass != " Shell_TrayWnd") and (SUS_WinClass != "WorkerW") and (SUS_ProcessExt != "scr") and (!SUS_FullScreenSuspend) )
			{
				SUS_FullScreenSuspend = 1
				SUS_FullScreenSuspendState := A_IsSuspended
				If ( !A_IsSuspended )
				{
					Suspend, On
					SYS_ToolTipText = NiftyWindows is suspended now.`nPress WIN+X to resume it again.
					SYS_ToolTipSeconds = 1
					SYS_ToolTipX = 1560
					SYS_ToolTipY = 1012
					Gosub, SYS_ToolTipShow
					Gosub, TRY_TrayUpdate
				}
			}
		}
		Else If ( SUS_FullScreenSuspend )
		{
			SUS_FullScreenSuspend = 0
			If ( A_IsSuspended and !SUS_FullScreenSuspendState )
			{
				Suspend, Off
				SYS_ToolTipText = NiftyWindows is resumed now.`nPress WIN+X to suspend it again.
				SYS_ToolTipSeconds = 1
				SYS_ToolTipX = 1560
				SYS_ToolTipY = 1012
				Gosub, SYS_ToolTipShow
				Gosub, TRY_TrayUpdate
			}
		}
	}
Return
	/*If ( (A_TimeIdlePhysical > IdleCheckTime)  and (!SUS_FullScreenSuspend) )
		{
			SYS_ToolTipText = The last  activity was at least 10 minutes ago.
			SYS_ToolTipX = 1560
			SYS_ToolTipY = 1012
			SYS_ToolTipSeconds = 2
			Gosub, SYS_ToolTipShow
			TimeIdlePhysical = 1
			If ( !A_IsSuspended )
			{
				Suspend, On
				SYS_ToolTipText = NiftyWindows is paused now.`nPress Pause to resume it again.
				SYS_ToolTipSeconds = 1
				SYS_ToolTipX = 1560
				SYS_ToolTipY = 1012
				Gosub, SYS_ToolTipShow
				Gosub, TRY_TrayUpdate
			}
			DllCall("LockWorkStation")
		}
		Else If ( ( A_TimeIdlePhysical < IdleCheckTime ) and (!SUS_FullScreenSuspend) and (TimeIdlePhysical) )
		{
			Suspend, Off
		}
		Return*/
		
		
		
		
; [SYS] provides reversion of all visual effects
		
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
	SYS_TrayTipText = All visual effects (AOT, Roll, Transparency) were reverted.
	Gosub, SYS_TrayTipShow
	Return
	
	
	
; [NWD] nifty window dragging
	
	/**
		* This is the most powerful feature of NiftyWindows. The area of every window 
		* is tiled in a virtual 9-cell grid with three columns and rows. The center 
		* cell is the largest one and you can grab and move a window around by clicking 
		* and holding it with the right mouse button. The other eight corner cells are 
		* used to resize a resizable window in the same manner.
	*/
	
	$RButton::
	$+RButton::
	$+!RButton::
	$+^RButton::
	$+#RButton::
	$+!^RButton::
	$+!#RButton::
	$+^#RButton::
	$+!^#RButton::
	$!RButton::
	$!^RButton::
	$!#RButton::
	$!^#RButton::
	$^RButton::
	$^#RButton::
	$#RButton::
	RButtonPressedStartTime := A_TickCount
	NWD_ResizeGrids = 5
	CoordMode, Mouse, Screen
	MouseGetPos, NWD_MouseStartX, NWD_MouseStartY, NWD_WinID
	If ( !NWD_WinID )
		Return
	WinGetPos, NWD_WinStartX, NWD_WinStartY, NWD_WinStartW, NWD_WinStartH, ahk_id %NWD_WinID%
	WinGet, NWD_WinMinMax, MinMax, ahk_id %NWD_WinID%
	WinGet, NWD_WinStyle, Style, ahk_id %NWD_WinID%
	WinGetClass, NWD_WinClass, ahk_id %NWD_WinID%
	GetKeyState, NWD_CtrlState, Ctrl, P
	
	; the and'ed condition checks for popup window:
	; (WS_POPUP) and !(WS_DLGFRAME | WS_SYSMENU | WS_THICKFRAME)
	If ( (NWD_WinClass = "Progman") or ((NWD_CtrlState = "U") and (((NWD_WinStyle & 0x80000000) and !(NWD_WinStyle & 0x4C0000)) or (NWD_WinClass = "IEFrame") or (NWD_WinClass = "MozillaWindowClass") or NWD_WinClass = "MozillaWindowClass") or (NWD_WinClass = "OpWindow") or (NWD_WinClass = "ATL:ExplorerFrame") or (NWD_WinClass = "ATL:ScrapFrame") ))
	{
		NWD_ImmediateDownRequest = 1
		NWD_ImmediateDown = 0
		NWD_PermitClick = 1
	}
	Else
	{
		NWD_ImmediateDownRequest = 0
		NWD_ImmediateDown = 0
		NWD_PermitClick = 1
	}
	
	NWD_Dragging := (NWD_WinClass != "Progman") and ((NWD_CtrlState = "D") or ((NWD_WinMinMax != 1) and !NWD_ImmediateDownRequest))
	
	; checks wheter the window has a sizing border (WS_THICKFRAME)
	If ( (NWD_CtrlState = "D") or (NWD_WinStyle & 0x40000) )
	{
		If ( (NWD_MouseStartX >= NWD_WinStartX + NWD_WinStartW / NWD_ResizeGrids) and (NWD_MouseStartX <= NWD_WinStartX + (NWD_ResizeGrids - 1) * NWD_WinStartW / NWD_ResizeGrids) )
			NWD_ResizeX = 0
		Else
			If ( NWD_MouseStartX > NWD_WinStartX + NWD_WinStartW / 2 )
				NWD_ResizeX := 1
		Else
			NWD_ResizeX := -1
		
		If ( (NWD_MouseStartY >= NWD_WinStartY + NWD_WinStartH / NWD_ResizeGrids) and (NWD_MouseStartY <= NWD_WinStartY + (NWD_ResizeGrids - 1) * NWD_WinStartH / NWD_ResizeGrids) )
			NWD_ResizeY = 0
		Else
			If ( NWD_MouseStartY > NWD_WinStartY + NWD_WinStartH / 2 )
				NWD_ResizeY := 1
		Else
			NWD_ResizeY := -1
	}
	Else
	{
		NWD_ResizeX = 0
		NWD_ResizeY = 0
	}
	
	If ( NWD_WinStartW and NWD_WinStartH )
		NWD_WinStartAR := NWD_WinStartW / NWD_WinStartH
	Else
		NWD_WinStartAR = 0
	
	; TODO : this is a workaround (checks for popup window) for the activation 
	; bug of AutoHotkey -> can be removed as soon as the known bug is fixed
	If ( !((NWD_WinStyle & 0x80000000) and !(NWD_WinStyle & 0x4C0000)) )
		IfWinNotActive, ahk_id %NWD_WinID%
			WinActivate, ahk_id %NWD_WinID%
	
	; TODO : the hotkeys must be enabled in the 2nd block because the 1st block 
	; activates them only for the first call (historical problem of AutoHotkey)
	Hotkey, Shift, NWD_IgnoreKeyHandler
	Hotkey, Ctrl, NWD_IgnoreKeyHandler
	Hotkey, Alt, NWD_IgnoreKeyHandler
	Hotkey, LWin, NWD_IgnoreKeyHandler
	Hotkey, RWin, NWD_IgnoreKeyHandler
	Hotkey, Shift, On
	Hotkey, Ctrl, On
	Hotkey, Alt, On
	Hotkey, LWin, On
	Hotkey, RWin, On
	SetTimer, NWD_IgnoreKeyHandler, 100
	SetTimer, NWD_WindowHandler, 10
	Return
	
	NWD_SetDraggingOff:
	NWD_Dragging = 0
	Return
	
	NWD_SetClickOff:
	NWD_PermitClick = 0
	NWD_ImmediateDownRequest = 0
	Return
	
	NWD_SetAllOff:
	Gosub, NWD_SetDraggingOff
	Gosub, NWD_SetClickOff
	Return
	
	NWD_IgnoreKeyHandler:
	GetKeyState, NWD_RButtonState, RButton, P
	GetKeyState, NWD_ShiftState, Shift, P
	GetKeyState, NWD_CtrlState, Ctrl, P
	GetKeyState, NWD_AltState, Alt, P
	; TODO : unlike the other modifiers, Win does not exist 
	; as a virtual key (but Ctrl, Alt and Shift do)
	GetKeyState, NWD_LWinState, LWin, P
	GetKeyState, NWD_RWinState, RWin, P
	If ( (NWD_LWinState = "D") or (NWD_RWinState = "D") )
		NWD_WinState = D
	Else
		NWD_WinState = U
	
	If ( (NWD_RButtonState = "U") and (NWD_ShiftState = "U") and (NWD_CtrlState = "U") and (NWD_AltState = "U") and (NWD_WinState = "U") )
	{
		SetTimer, NWD_IgnoreKeyHandler, Off
		Hotkey, Shift, Off
		Hotkey, Ctrl, Off
		Hotkey, Alt, Off
		Hotkey, LWin, Off
		Hotkey, RWin, Off
	}
	Return
	
	RButtonHandler:
	GetKeyState, NWD_RButtonState, RButton, P
	
	
	
	NWD_WindowHandler:
	SetWinDelay, -1
	CoordMode, Mouse, Screen
	MouseGetPos, NWD_MouseX, NWD_MouseY
	WinGetPos, NWD_WinX, NWD_WinY, NWD_WinW, NWD_WinH, ahk_id %NWD_WinID%
	GetKeyState, NWD_RButtonState, RButton, P
	GetKeyState, NWD_ShiftState, Shift, P
	GetKeyState, NWD_AltState, Alt, P
	; TODO : unlike the other modifiers, Win does not exist 
	; as a virtual key (but Ctrl, Alt and Shift do)
	GetKeyState, NWD_LWinState, LWin, P
	GetKeyState, NWD_RWinState, RWin, P
	;MouseClickRIGHT := not (MouseClickRIGHT)
	If ( (NWD_LWinState = "D") or (NWD_RWinState = "D") )
		NWD_WinState = D
	Else
		NWD_WinState = U
	If ( NWD_RButtonState = "U" )
	{
		SetTimer, NWD_WindowHandler, Off
		
		If ( NWD_ImmediateDown )
			MouseClick, RIGHT, %NWD_MouseX%, %NWD_MouseY%, , , U
		Else
			If ( NWD_PermitClick or (!NWD_Dragging or ((NWD_MouseStartX = NWD_MouseX) and (NWD_MouseStartY = NWD_MouseY))) )
			{
				RButtonUnPressedElapsedTime := A_TickCount - RButtonPressedStartTime
				If ( RButtonUnPressedElapsedTime > 350 )
				{
					Return
				}
				Else If ( RButtonUnPressedElapsedTime < 350 )
				{
					MouseClick, RIGHT, , , , , D
					MouseClick, RIGHT, , , , , U
					;Click, RIGHT
				}
			}
		
		Gosub, NWD_SetAllOff
		NWD_ImmediateDown = 0
	}
	Else
	{
		NWD_MouseDeltaX := NWD_MouseX - NWD_MouseStartX
		NWD_MouseDeltaY := NWD_MouseY - NWD_MouseStartY
		
		If ( (NWD_MouseDeltaX >= 10) or (NWD_MouseDeltaY >= 10) )
		{
			If ( NWD_ImmediateDownRequest and !NWD_ImmediateDown )
			{
				MouseClick, RIGHT, %NWD_MouseStartX%, %NWD_MouseStartY%, , , D
				MouseMove, %NWD_MouseX%, %NWD_MouseY%
				NWD_ImmediateDown = 1
				NWD_PermitClick = 0
			}
			If ( NWD_Dragging )
			{
				If ( !NWD_ResizeX and !NWD_ResizeY )
				{
					NWD_WinNewX := NWD_WinStartX + NWD_MouseDeltaX
					NWD_WinNewY := NWD_WinStartY + NWD_MouseDeltaY
					NWD_WinNewW := NWD_WinStartW
					NWD_WinNewH := NWD_WinStartH
				}
				Else
				{
					NWD_WinDeltaW = 0
					NWD_WinDeltaH = 0
					If ( NWD_ResizeX )
						NWD_WinDeltaW := NWD_ResizeX * NWD_MouseDeltaX
					If ( NWD_ResizeY )
						NWD_WinDeltaH := NWD_ResizeY * NWD_MouseDeltaY
					If ( NWD_WinState = "D" )
					{
						If ( NWD_ResizeX )
							NWD_WinDeltaW *= 2
						If ( NWD_ResizeY )
							NWD_WinDeltaH *= 2
					}
					NWD_WinNewW := NWD_WinStartW + NWD_WinDeltaW
					NWD_WinNewH := NWD_WinStartH + NWD_WinDeltaH
					If ( NWD_WinNewW < 0 )
						If ( NWD_WinState = "D" )
							NWD_WinNewW *= -1
					Else
						NWD_WinNewW := 0
					If ( NWD_WinNewH < 0 )
						If ( NWD_WinState = "D" )
							NWD_WinNewH *= -1
					Else
						NWD_WinNewH := 0
					If ( (NWD_AltState = "D") and NWD_WinStartAR )
					{
						NWD_WinNewARW := NWD_WinNewH * NWD_WinStartAR
						NWD_WinNewARH := NWD_WinNewW / NWD_WinStartAR
						If ( NWD_WinNewW < NWD_WinNewARW )
							NWD_WinNewW := NWD_WinNewARW
						If ( NWD_WinNewH < NWD_WinNewARH )
							NWD_WinNewH := NWD_WinNewARH
					}
					NWD_WinDeltaX = 0
					NWD_WinDeltaY = 0
					If ( NWD_WinState = "D" )
					{
						NWD_WinDeltaX := NWD_WinStartW / 2 - NWD_WinNewW / 2
						NWD_WinDeltaY := NWD_WinStartH / 2 - NWD_WinNewH / 2
					}
					Else
					{
						If ( NWD_ResizeX = -1 )
							NWD_WinDeltaX := NWD_WinStartW - NWD_WinNewW
						If ( NWD_ResizeY = -1 )
							NWD_WinDeltaY := NWD_WinStartH - NWD_WinNewH
					}
					NWD_WinNewX := NWD_WinStartX + NWD_WinDeltaX
					NWD_WinNewY := NWD_WinStartY + NWD_WinDeltaY
				}
				
				If ( NWD_ShiftState = "D" )
					NWD_WinNewRound = -1
				Else
					NWD_WinNewRound = 0
				
				Transform, NWD_WinNewX, Round, %NWD_WinNewX%, %NWD_WinNewRound%
				Transform, NWD_WinNewY, Round, %NWD_WinNewY%, %NWD_WinNewRound%
				Transform, NWD_WinNewW, Round, %NWD_WinNewW%, %NWD_WinNewRound%
				Transform, NWD_WinNewH, Round, %NWD_WinNewH%, %NWD_WinNewRound%
				
				If ( (NWD_WinNewX != NWD_WinX) or (NWD_WinNewY != NWD_WinY) or (NWD_WinNewW != NWD_WinW) or (NWD_WinNewH != NWD_WinH) )
				{
					
					WinMove, ahk_id %NWD_WinID%, , %NWD_WinNewX%, %NWD_WinNewY%, %NWD_WinNewW%, %NWD_WinNewH%
					WinGetPos, NWD_ToolTipWinX, NWD_ToolTipWinY, NWD_ToolTipWinW, NWD_ToolTipWinH, ahk_id %NWD_WinID%
					MouseGetPos, MouseX, MouseY
					If ( SYS_ToolTipFeedback )
					{
						SYS_ToolTipText = Window Drag: (X:%NWD_ToolTipWinX%, Y:%NWD_ToolTipWinY%, W:%NWD_ToolTipWinW%, H:%NWD_ToolTipWinH%)`nMouse Position: (X:%MouseX%, Y:%MouseY%)
						SYS_ToolTipSeconds = 0.5
						;Gosub, SYS_ToolTipFeedbackShow
					}
					;SYS_ToolTipText = %NWD_WinNewX% %NWD_WinX% %NWD_WinNewY% %NWD_WinY% %NWD_WinNewW% %NWD_WinW% %NWD_WinNewH% %NWD_WinH% %MouseX% %MouseY%
					;Gosub, SYS_ToolTipFeedbackShow
					If ( (NWD_WinNewW = NWD_WinW) and (NWD_WinNewH = NWD_WinH) )
					{
						If (MouseX < 5)
						{
							If ( (MouseX < 5) and ((MouseY > 100) and (MouseY < 1045)) ) 			; left side, center
							{
								WinMove, ahk_id %NWD_WinID%, , -10, 0, 974, 1057
								SYS_ToolTipText = Window move to left side corner after dragging
								SYS_ToolTipSeconds = 1
								Gosub, SYS_ToolTipFeedbackShow
								Sleep, 500
							}
							Else If ( (MouseX < 5) and (MouseY < 95) )									; left top corner
							{
								WinMove, ahk_id %NWD_WinID%, , -7, 0, 974, 532
								SYS_ToolTipText = Window move to left top corner after dragging
								SYS_ToolTipSeconds = 1
								Gosub, SYS_ToolTipFeedbackShow
								Sleep, 500
							}
							Else If ( (MouseX < 5) and (MouseY > 1020) )								; left bottom corner
							{
								WinMove, ahk_id %NWD_WinID%, , -7, 525, 974, 532
								SYS_ToolTipText = Window move to left bottom corner after dragging
								SYS_ToolTipSeconds = 1
								Gosub, SYS_ToolTipFeedbackShow
								Sleep, 500	
							}
						}
						Else If (MouseX > 800)
						{
							If ( ((MouseX > 800) and (MouseX < 1000)) and (MouseY > 1030) )		; bottom side, center
							{
								WinMinimize, ahk_id %NWD_WinID%
								SYS_ToolTipText = Window minimized after dragging
								SYS_ToolTipSeconds = 2
								Gosub, SYS_ToolTipFeedbackShow
								Sleep, 500							
							}
							Else If ( ((MouseX > 800) and (MouseX < 1000)) and (MouseY < 10) )			; top side, center
							{
								WinMaximize, ahk_id %NWD_WinID%
								SYS_ToolTipText = Window maximized after dragging
								SYS_ToolTipSeconds = 2
								Gosub, SYS_ToolTipFeedbackShow
								Sleep, 1000
							}
							Else If ( (MouseX > 1915) and ((MouseY > 100) and (MouseY < 1030)) )		; right side, center
							{
								If (NWD_WinID == "0x1708d2")
									WinMove, ahk_id %NWD_WinID%, , 957, 0, 963, 1050
								Else
									WinMove, ahk_id %NWD_WinID%, , 953, 0, 974, 1057
								SYS_ToolTipText = Window move to right side after dragging
								SYS_ToolTipSeconds = 1
								Gosub, SYS_ToolTipFeedbackShow
								Sleep, 500
							}
							Else If ( (MouseX > 1915) and (MouseY < 95) )								; right top corner
							{
								WinMove, ahk_id %NWD_WinID%, , 953, 0, 974, 532
								SYS_ToolTipText = Window move to right top corner after dragging
								SYS_ToolTipSeconds = 1
								Gosub, SYS_ToolTipFeedbackShow
								Sleep, 500
							}
							Else If ( (MouseX > 1915) and (MouseY > 1020) )								; right bottom corner
							{
								WinMove, ahk_id %NWD_WinID%, , 953, 525, 974, 532
								SYS_ToolTipText = Window move to right bottom corner after dragging
								SYS_ToolTipSeconds = 1
								Gosub, SYS_ToolTipFeedbackShow
								Sleep, 500	
							}
						}
					}
				}
			}
		}
	}
	Return
	
	
	
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
		; this feature should be implemented by using a timer because 
		; AutoHotkeys threading blocks the first thread if another 
		; one is started (until the 2nd is stopped)
		
		Thread, Priority, 1
		Thread, Interrupt, -1
		Critical
		MouseClick, LEFT, , , , , D
		KeyWait, LButton
		MouseClick, LEFT, , , , , U
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
	
; [CLW {NWD}] close/send bottom on right + middle mouse button || double click on middle mouse button
	
	/**
		* Closes the selected window (if closeable) as if you click the close button 
		* in the titlebar. If you press the middle button over the titlebar the 
		* selected window will be sent to the bottom of the window stack instead of 
		* being closed.
	*/
	
	$MButton::
	$^MButton::
	GetKeyState, CLW_RButtonState, RButton, P
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
		
		If ( CLW_MouseY <= CLW_CaptionHeight + CLW_BorderHeight )
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
		Send, {MButton}
	}
	Return
	
	
	$XButton1::
	$^XButton1::
	$+XButton1::
	$^+XButton1::
	$!XButton1::
	XButton1PressedStartTime := A_TickCount
	If ( NWD_ImmediateDown )
		Return	
	GetKeyState, TSM_RButtonState, RButton, P
	GetKeyState, TSM_CtrlState, LCtrl, P
	GetKeyState, TSM_ShiftState, LShift, P
	GetKeyState, TSM_AltState, LAlt, P
	If ( TSM_RButtonState = "U" )
	{
		If ( (TSM_CtrlState = "U") and (TSM_ShiftState = "U") and (TSM_AltState = "U") )
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
						Send, {XButton1}
					}
					Break
				}
				Else
				{
					GetKeyState, TSM_CtrlState, Ctrl
					If (TSM_CtrlState = "U")
						Send, {Ctrl down}
				}
			}
			Send, {Ctrl up}
		}
		Else If ( (TSM_CtrlState = "D") and (TSM_ShiftState = "U") and (TSM_AltState = "U") )
		{
			Send, {Backspace}
		}
		Else If ( (TSM_CtrlState = "U") and (TSM_ShiftState = "D") and (TSM_AltState = "U") )
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
		Else If  ( (TSM_CtrlState = "U") and (TSM_ShiftState = "U") and (TSM_AltState = "D") )
		{		
			Send, {End}
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
			If ( TSM_WinClass != "Progman" )
			{
				Gosub, NWD_SetAllOff
				WinGet, LastApp_ID, ID, A
				Send, #d
				SYS_ToolTipText = All Windows Minimized
				Gosub, SYS_ToolTipFeedbackShow				
			}
			
		}
	}
	Return
	
	
; [MAW {NWD}] Maximize Active Window
	
	
	$XButton2::
	$^XButton2::
	$+XButton2::
	$^+XButton2::
	$!XButton2::
	XButton2PressedStartTime := A_TickCount
	If ( NWD_ImmediateDown )
		Return	
	GetKeyState, MAW_RButtonState, RButton, P
	GetKeyState, MAW_ShiftState, LShift, P
	GetKeyState, MAW_CtrlState, LCtrl, P
	GetKeyState, MAW_AltState, LAlt, P
	If ( MAW_RButtonState = "U" )
	{
		If ( (MAW_CtrlState = "U") and (MAW_ShiftState = "U") and (MAW_AltState = "U") )
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
						Send, {XButton2}
					}
					Break
				}
				Else
				{
					GetKeyState, MAW_ShiftState, Shift
					If (MAW_ShiftState = "U")
						Send, {Shift down}
				}
			}
			Send, {Shift up}
		}
		Else If ( (MAW_CtrlState = "D") and (MAW_ShiftState = "U") and (MAW_AltState = "U") )
		{
			Send, {Del}
		}
		Else If ( (MAW_CtrlState = "U") and (MAW_ShiftState = "D") and (MAW_AltState = "U") )
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
		Else If ( (MAW_CtrlState = "U") and (MAW_ShiftState = "U") and (MAW_AltState = "D") )
		{
			Send, {Home}
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
				If !WinExist(%LastApp_ID%) 
					SYS_ToolTipText = Last app unknown. Can not to restore.
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
	
	
	
; [TSW {NWD}] provides alt-tab-menu to the right mouse button + mouse wheel
	
	/**
		* Provides a quick task switcher (alt-tab-menu) controlled by the mouse wheel.
	*/
	
	WheelDown::
	GetKeyState, TSW_RButtonState, RButton, P
	If ( (TSW_RButtonState = "D") and (!NWD_ImmediateDown) )
	{
		; TODO : this is a workaround because the original tabmenu 
		; code of AutoHotkey is buggy on some systems
		GetKeyState, TSW_LAltState, LAlt
		If ( TSW_LAltState = "U" )
		{
			Gosub, NWD_SetAllOff
			Send, {LAlt down}{Tab}
			SetTimer, TSW_WheelHandler, 1
		}
		Else
			Send, {Tab}
	}
	Else
		Send, {WheelDown}
	Return
	
	WheelUp::
	GetKeyState, TSW_RButtonState, RButton, P
	If ( (TSW_RButtonState = "D") and (!NWD_ImmediateDown) )
	{
		; TODO : this is a workaround because the original tabmenu 
		; code of AutoHotkey is buggy on some systems
		GetKeyState, TSW_LAltState, LAlt
		If ( TSW_LAltState = "U" )
		{
			Gosub, NWD_SetAllOff
			Send, {LAlt down}+{Tab}
			SetTimer, TSW_WheelHandler, 1
		}
		Else
			Send, +{Tab}
	}
	Else
		Send, {WheelUp}
	Return
	
	TSW_WheelHandler:
	GetKeyState, TSW_RButtonState, RButton, P
	If ( TSW_RButtonState = "U" )
	{
		SetTimer, TSW_WheelHandler, Off
		GetKeyState, TSW_LAltState, LAlt
		If ( TSW_LAltState = "D" )
			Send, {LAlt up}
	}
	Return
	
	
	
; [AOT] toggles always on top
	
	/**
		* Toggles the always-on-top attribute of the selected/active window.
	*/
	
	#SC029::
	#LButton::
	AOT_SetToggle:
	Gosub, AOT_CheckWinIDs
	SetWinDelay, -1
	
	IfInString, A_ThisHotkey, LButton
	{
		MouseGetPos, , , AOT_WinID
		If ( !AOT_WinID )
			Return
		IfWinNotActive, ahk_id %AOT_WinID%
			WinActivate, ahk_id %AOT_WinID%
	}
	
	IfWinActive, A
	{
		WinGet, AOT_WinID, ID
		If ( !AOT_WinID )
			Return
		WinGetClass, AOT_WinClass, ahk_id %AOT_WinID%
		If ( AOT_WinClass = "Progman" )
			Return
		
		WinGet, AOT_ExStyle, ExStyle, ahk_id %AOT_WinID%
		If ( AOT_ExStyle & 0x8 ) ; 0x8 is WS_EX_TOPMOST
		{
			SYS_ToolTipText = Always on Top: OFF
			Gosub, AOT_SetOff
		}
		Else
		{
			SYS_ToolTipText = Always on Top: ON
			Gosub, AOT_SetOn
		}
		Gosub, SYS_ToolTipFeedbackShow
	}
	Return
	
	AOT_SetOn:
	Gosub, AOT_CheckWinIDs
	SetWinDelay, -1
	IfWinNotExist, ahk_id %AOT_WinID%
		Return
	IfNotInString, AOT_WinIDs, |%AOT_WinID%
		AOT_WinIDs = %AOT_WinIDs%|%AOT_WinID%
	WinSet, AlwaysOnTop, On, ahk_id %AOT_WinID%
	Return
	
	AOT_SetOff:
	Gosub, AOT_CheckWinIDs
	SetWinDelay, -1
	IfWinNotExist, ahk_id %AOT_WinID%
		Return
	StringReplace, AOT_WinIDs, AOT_WinIDs, |%A_LoopField%, , All
	WinSet, AlwaysOnTop, Off, ahk_id %AOT_WinID%
	Return
	
	AOT_SetAllOff:
	Gosub, AOT_CheckWinIDs
	Loop, Parse, AOT_WinIDs, |
		If ( A_LoopField )
		{
			AOT_WinID = %A_LoopField%
			Gosub, AOT_SetOff
		}
	Return
	
	#^SC029::
	Gosub, AOT_SetAllOff
	SYS_ToolTipText = Always on Top: ALL OFF
	Gosub, SYS_ToolTipFeedbackShow
	Return
	
	AOT_CheckWinIDs:
	DetectHiddenWindows, On
	Loop, Parse, AOT_WinIDs, |
		If ( A_LoopField )
			IfWinNotExist, ahk_id %A_LoopField%
				StringReplace, AOT_WinIDs, AOT_WinIDs, |%A_LoopField%, , All
	Return
	
	AOT_ExitHandler:
	Gosub, AOT_SetAllOff
	Return
	
	
	
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
	
	
	
; [TRA] provides window transparency
	
	/**
		* Adjusts the transparency of the active window in ten percent steps 
		* (opaque = 100%) which allows the contents of the windows behind it to shine 
		* through. If the window is completely transparent (0%) the window is still 
		* there and clickable. If you loose a transparent window it will be extremly 
		* complicated to find it again because it's invisible (see the first hotkey 
		* in this list for emergency help in such situations). 
	*/
	
	#WheelUp::
	#+WheelUp::
	#WheelDown::
	#+WheelDown::
	Gosub, TRA_CheckWinIDs
	SetWinDelay, -1
	IfWinActive, A
	{
		WinGet, TRA_WinID, ID
		If ( !TRA_WinID )
			Return
		WinGetClass, TRA_WinClass, ahk_id %TRA_WinID%
		If ( TRA_WinClass = "Progman" )
			Return
		
		IfNotInString, TRA_WinIDs, |%TRA_WinID%
			TRA_WinIDs = %TRA_WinIDs%|%TRA_WinID%
		TRA_WinAlpha := TRA_WinAlpha%TRA_WinID%
		TRA_PixelColor := TRA_PixelColor%TRA_WinID%
		
		IfInString, A_ThisHotkey, +
		TRA_WinAlphaStep := 255 * 0.01 ; 1 percent steps
		Else
			TRA_WinAlphaStep := 255 * 0.1 ; 10 percent steps
		
		If ( TRA_WinAlpha = "" )
			TRA_WinAlpha = 255
		
		IfInString, A_ThisHotkey, WheelDown
		TRA_WinAlpha -= TRA_WinAlphaStep
		Else
			TRA_WinAlpha += TRA_WinAlphaStep
		
		If ( TRA_WinAlpha > 255 )
			TRA_WinAlpha = 255
		Else
			If ( TRA_WinAlpha < 0 )
				TRA_WinAlpha = 0
		
		If ( !TRA_PixelColor and (TRA_WinAlpha = 255) )
		{
			Gosub, TRA_TransparencyOff
			SYS_ToolTipText = Transparency: OFF
		}
		Else
		{
			TRA_WinAlpha%TRA_WinID% = %TRA_WinAlpha%
			
			If ( TRA_PixelColor )
				WinSet, TransColor, %TRA_PixelColor% %TRA_WinAlpha%, ahk_id %TRA_WinID%
			Else
				WinSet, Transparent, %TRA_WinAlpha%, ahk_id %TRA_WinID%
			
			TRA_ToolTipAlpha := TRA_WinAlpha * 100 / 255
			Transform, TRA_ToolTipAlpha, Round, %TRA_ToolTipAlpha%
			SYS_ToolTipText = Transparency: %TRA_ToolTipAlpha% `%
		}
		Gosub, SYS_ToolTipFeedbackShow
	}
	Return
	
	#^LButton::
	#^MButton::
	Gosub, TRA_CheckWinIDs
	SetWinDelay, -1
	CoordMode, Mouse, Screen
	CoordMode, Pixel, Screen
	MouseGetPos, TRA_MouseX, TRA_MouseY, TRA_WinID
	If ( !TRA_WinID )
		Return
	WinGetClass, TRA_WinClass, ahk_id %TRA_WinID%
	If ( TRA_WinClass = "Progman" )
		Return
	
	IfWinNotActive, ahk_id %TRA_WinID%
		WinActivate, ahk_id %TRA_WinID%
	IfNotInString, TRA_WinIDs, |%TRA_WinID%
		TRA_WinIDs = %TRA_WinIDs%|%TRA_WinID%
	
	IfInString, A_ThisHotkey, MButton
	{
		AOT_WinID = %TRA_WinID%
		Gosub, AOT_SetOn
		TRA_WinAlpha%TRA_WinID% := 25 * 255 / 100
	}
	
	TRA_WinAlpha := TRA_WinAlpha%TRA_WinID%
	
	; TODO : the transparency must be set off first, 
	; this may be a bug of AutoHotkey
	WinSet, TransColor, OFF, ahk_id %TRA_WinID%
	PixelGetColor, TRA_PixelColor, %TRA_MouseX%, %TRA_MouseY%, RGB
	WinSet, TransColor, %TRA_PixelColor% %TRA_WinAlpha%, ahk_id %TRA_WinID%
	TRA_PixelColor%TRA_WinID% := TRA_PixelColor
	
	IfInString, A_ThisHotkey, MButton
	SYS_ToolTipText = Transparency: 25 `% + %TRA_PixelColor% color (RGB) + Always on Top
	Else
		SYS_ToolTipText = Transparency: %TRA_PixelColor% color (RGB)
	Gosub, SYS_ToolTipFeedbackShow
	Return
	
	#MButton::
	Gosub, TRA_CheckWinIDs
	SetWinDelay, -1
	MouseGetPos, , , TRA_WinID
	If ( !TRA_WinID )
		Return
	IfWinNotActive, ahk_id %TRA_WinID%
		WinActivate, ahk_id %TRA_WinID%
	IfNotInString, TRA_WinIDs, |%TRA_WinID%
		Return
	Gosub, TRA_TransparencyOff
	
	SYS_ToolTipText = Transparency: OFF
	Gosub, SYS_ToolTipFeedbackShow
	Return
	
	TRA_TransparencyOff:
	Gosub, TRA_CheckWinIDs
	SetWinDelay, -1
	If ( !TRA_WinID )
		Return
	IfNotInString, TRA_WinIDs, |%TRA_WinID%
		Return
	StringReplace, TRA_WinIDs, TRA_WinIDs, |%TRA_WinID%, , All
	TRA_WinAlpha%TRA_WinID% =
	TRA_PixelColor%TRA_WinID% =
	; TODO : must be set to 255 first to avoid the black-colored-window problem
	WinSet, Transparent, 255, ahk_id %TRA_WinID%
	WinSet, TransColor, OFF, ahk_id %TRA_WinID%
	WinSet, Transparent, OFF, ahk_id %TRA_WinID%
	WinSet, Redraw, , ahk_id %TRA_WinID%
	Return
	
	TRA_TransparencyAllOff:
	Gosub, TRA_CheckWinIDs
	Loop, Parse, TRA_WinIDs, |
		If ( A_LoopField )
		{
			TRA_WinID = %A_LoopField%
			Gosub, TRA_TransparencyOff
		}
	Return
	
	#^t::
	Gosub, TRA_TransparencyAllOff
	SYS_ToolTipText = Transparency: ALL OFF
	Gosub, SYS_ToolTipFeedbackShow
	Return
	
	TRA_CheckWinIDs:
	DetectHiddenWindows, On
	Loop, Parse, TRA_WinIDs, |
		If ( A_LoopField )
			IfWinNotExist, ahk_id %A_LoopField%
			{
				StringReplace, TRA_WinIDs, TRA_WinIDs, |%A_LoopField%, , All
				TRA_WinAlpha%A_LoopField% =
				TRA_PixelColor%A_LoopField% =
			}
	Return
	
	TRA_ExitHandler:
	Gosub, TRA_TransparencyAllOff
	Return
	
	
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
	
	
; [SIZ {NWD}] provides several size adjustments to windows
	
	/**
		* Adjusts the transparency of the active window in ten percent steps 
		* (opaque = 100%) which allows the contents of the windows behind it to shine 
		* through. If the window is completely transparent (0%) the window is still 
		* there and clickable. If you loose a transparent window it will be extremly 
		* complicated to find it again because it's invisible (see the first hotkey in 
		* this list for emergency help in such situations). 
	*/
	
	!WheelUp::
	!+WheelUp::
	!^WheelUp::
	!#WheelUp::
	!+^WheelUp::
	!+#WheelUp::
	!^#WheelUp::
	!+^#WheelUp::
	!WheelDown::
	!+WheelDown::
	!^WheelDown::
	!#WheelDown::
	!+^WheelDown::
	!+#WheelDown::
	!^#WheelDown::
	!+^#WheelDown::
	; TODO : the following code block is a workaround to handle 
	; virtual ALT calls in WheelDown/Up functions
	GetKeyState, SIZ_AltState, Alt, P
	If ( SIZ_AltState = "U" )
	{
		IfInString, A_ThisHotkey, WheelDown
		Gosub, WheelDown
		Else
			Gosub, WheelUp
		Return
	}
	
	If ( NWD_Dragging or NWD_ImmediateDown )
		Return
	
	SetWinDelay, -1
	CoordMode, Mouse, Screen
	IfWinActive, A
	{
		WinGet, SIZ_WinID, ID
		If ( !SIZ_WinID )
			Return
		WinGetClass, SIZ_WinClass, ahk_id %SIZ_WinID%
		If ( SIZ_WinClass = "Progman" )
			Return
		
		GetKeyState, SIZ_CtrlState, Ctrl, P
		WinGet, SIZ_WinMinMax, MinMax, ahk_id %SIZ_WinID%
		WinGet, SIZ_WinStyle, Style, ahk_id %SIZ_WinID%
		
		; checks wheter the window isn't maximized and has a sizing border (WS_THICKFRAME)
		If ( (SIZ_CtrlState = "D") or ((SIZ_WinMinMax != 1) and (SIZ_WinStyle & 0x40000)) )
		{
			WinGetPos, SIZ_WinX, SIZ_WinY, SIZ_WinW, SIZ_WinH, ahk_id %SIZ_WinID%
			
			If ( SIZ_WinW and SIZ_WinH )
			{
				SIZ_AspectRatio := SIZ_WinW / SIZ_WinH
				
				IfInString, A_ThisHotkey, WheelDown
				SIZ_Direction = 1
				Else
					SIZ_Direction = -1
				
				IfInString, A_ThisHotkey, +
				SIZ_Factor = 0.01
				Else
					SIZ_Factor = 0.1
				
				SIZ_WinNewW := SIZ_WinW + SIZ_Direction * SIZ_WinW * SIZ_Factor
				SIZ_WinNewH := SIZ_WinH + SIZ_Direction * SIZ_WinH * SIZ_Factor
				
				IfInString, A_ThisHotkey, #
				{
					SIZ_WinNewX := SIZ_WinX + (SIZ_WinW - SIZ_WinNewW) / 2
					SIZ_WinNewY := SIZ_WinY + (SIZ_WinH - SIZ_WinNewH) / 2
				}
				Else
				{
					SIZ_WinNewX := SIZ_WinX
					SIZ_WinNewY := SIZ_WinY
				}
				
				If ( SIZ_WinNewW > A_ScreenWidth )
				{
					SIZ_WinNewW := A_ScreenWidth
					SIZ_WinNewH := SIZ_WinNewW / SIZ_AspectRatio
				}
				If ( SIZ_WinNewH > A_ScreenHeight )
				{
					SIZ_WinNewH := A_ScreenHeight
					SIZ_WinNewW := SIZ_WinNewH * SIZ_AspectRatio
				}
				
				Transform, SIZ_WinNewX, Round, %SIZ_WinNewX%
				Transform, SIZ_WinNewY, Round, %SIZ_WinNewY%
				Transform, SIZ_WinNewW, Round, %SIZ_WinNewW%
				Transform, SIZ_WinNewH, Round, %SIZ_WinNewH%
				
				WinMove, ahk_id %SIZ_WinID%, , SIZ_WinNewX, SIZ_WinNewY, SIZ_WinNewW, SIZ_WinNewH
				
				If ( SYS_ToolTipFeedback )
				{
					WinGetPos, SIZ_ToolTipWinX, SIZ_ToolTipWinY, SIZ_ToolTipWinW, SIZ_ToolTipWinH, ahk_id %SIZ_WinID%
					SYS_ToolTipText = Window Size: (X:%SIZ_ToolTipWinX%, Y:%SIZ_ToolTipWinY%, W:%SIZ_ToolTipWinW%, H:%SIZ_ToolTipWinH%)
					Gosub, SYS_ToolTipFeedbackShow
				}
			}
		}
	}
	Return
	
	!NumpadAdd::
	!^NumpadAdd::
	!#NumpadAdd::
	!^#NumpadAdd::
	!NumpadSub::
	!^NumpadSub::
	!#NumpadSub::
	!^#NumpadSub::
	If ( NWD_Dragging or NWD_ImmediateDown )
		Return
	
	SetWinDelay, -1
	CoordMode, Mouse, Screen
	IfWinActive, A
	{
		WinGet, SIZ_WinID, ID
		If ( !SIZ_WinID )
			Return
		WinGetClass, SIZ_WinClass, ahk_id %SIZ_WinID%
		If ( SIZ_WinClass = "Progman" )
			Return
		
		GetKeyState, SIZ_CtrlState, Ctrl, P
		WinGet, SIZ_WinMinMax, MinMax, ahk_id %SIZ_WinID%
		WinGet, SIZ_WinStyle, Style, ahk_id %SIZ_WinID%
		
		; checks wheter the window isn't maximized and has a sizing border (WS_THICKFRAME)
		If ( (SIZ_CtrlState = "D") or ((SIZ_WinMinMax != 1) and (SIZ_WinStyle & 0x40000)) )
		{
			WinGetPos, SIZ_WinX, SIZ_WinY, SIZ_WinW, SIZ_WinH, ahk_id %SIZ_WinID%
			
			IfInString, A_ThisHotkey, NumpadAdd
			If ( SIZ_WinW < 160 )
				SIZ_WinNewW = 160
			Else
				If ( SIZ_WinW < 320 )
					SIZ_WinNewW = 320
			Else
				If ( SIZ_WinW < 640 )
					SIZ_WinNewW = 640
			Else
				If ( SIZ_WinW < 800 )
					SIZ_WinNewW = 800
			Else
				If ( SIZ_WinW < 1024 )
					SIZ_WinNewW = 1024
			Else
				If ( SIZ_WinW < 1152 )
					SIZ_WinNewW = 1152
			Else
				If ( SIZ_WinW < 1280 )
					SIZ_WinNewW = 1280
			Else
				If ( SIZ_WinW < 1400 )
					SIZ_WinNewW = 1400
			Else
				If ( SIZ_WinW < 1600 )
					SIZ_WinNewW = 1600
			Else
				SIZ_WinNewW = 1920
			Else
				If ( SIZ_WinW <= 320 )
					SIZ_WinNewW = 160
			Else
				If ( SIZ_WinW <= 640 )
					SIZ_WinNewW = 320
			Else
				If ( SIZ_WinW <= 800 )
					SIZ_WinNewW = 640
			Else
				If ( SIZ_WinW <= 1024 )
					SIZ_WinNewW = 800
			Else
				If ( SIZ_WinW <= 1152 )
					SIZ_WinNewW = 1024
			Else
				If ( SIZ_WinW <= 1280 )
					SIZ_WinNewW = 1152
			Else
				If ( SIZ_WinW <= 1400 )
					SIZ_WinNewW = 1280
			Else
				If ( SIZ_WinW <= 1600 )
					SIZ_WinNewW = 1400
			Else
				If ( SIZ_WinW <= 1920 )
					SIZ_WinNewW = 1600
			Else
				SIZ_WinNewW = 1920
			
			If ( SIZ_WinNewW > A_ScreenWidth )
				SIZ_WinNewW := A_ScreenWidth
			SIZ_WinNewH := 3 * SIZ_WinNewW / 4
			If ( SIZ_WinNewW = 1280 )
				SIZ_WinNewH := 1024
			
			IfInString, A_ThisHotkey, #
			{
				SIZ_WinNewX := SIZ_WinX + (SIZ_WinW - SIZ_WinNewW) / 2
				SIZ_WinNewY := SIZ_WinY + (SIZ_WinH - SIZ_WinNewH) / 2
			}
			Else
			{
				SIZ_WinNewX := SIZ_WinX
				SIZ_WinNewY := SIZ_WinY
			}
			
			Transform, SIZ_WinNewX, Round, %SIZ_WinNewX%
			Transform, SIZ_WinNewY, Round, %SIZ_WinNewY%
			Transform, SIZ_WinNewW, Round, %SIZ_WinNewW%
			Transform, SIZ_WinNewH, Round, %SIZ_WinNewH%
			
			WinMove, ahk_id %SIZ_WinID%, , SIZ_WinNewX, SIZ_WinNewY, SIZ_WinNewW, SIZ_WinNewH
			
			If ( SYS_ToolTipFeedback )
			{
				WinGetPos, SIZ_ToolTipWinX, SIZ_ToolTipWinY, SIZ_ToolTipWinW, SIZ_ToolTipWinH, ahk_id %SIZ_WinID%
				SYS_ToolTipText = Window Size: (X:%SIZ_ToolTipWinX%, Y:%SIZ_ToolTipWinY%, W:%SIZ_ToolTipWinW%, H:%SIZ_ToolTipWinH%)
				Gosub, SYS_ToolTipFeedbackShow
			}
		}
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
	
	Menu, MouseHooks, Add, Left Mouse Button, TRY_TrayEvent
	Menu, MouseHooks, Add, Middle Mouse Button, TRY_TrayEvent
	Menu, MouseHooks, Add, Right Mouse Button, TRY_TrayEvent
	Menu, MouseHooks, Add, Fourth Mouse Button, TRY_TrayEvent
	Menu, MouseHooks, Add, Fifth Mouse Button, TRY_TrayEvent
	Menu, TRAY, Add, Mouse Hooks, :MouseHooks
	
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
		Gosub, SUS_SuspendToggle
	
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
	
	Gosub, TRY_TrayUpdate
	TRY_TrayEvent =
	Return
	
	TRY_TrayHide:
	SetTimer, TRY_TrayHide, Off
	Menu, TRAY, NoIcon
	Return
	
	
	
; [EDT] edits this script in notepad
	
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
	
	REL_ScriptReload:
	If ( A_IsCompiled )
		Return
	
	FileGetAttrib, REL_Attribs, %A_ScriptFullPath%
	IfInString, REL_Attribs, A
	{
		FileSetAttrib, -A, %A_ScriptFullPath%
		If ( REL_InitDone )
		{
			Gosub, SUS_SuspendSaveState
			Suspend, On
			MsgBox, 4145, Update Handler - %SYS_ScriptInfo%, The following script has changed:`n`n%A_ScriptFullPath%`n`nReload and activate this script?
			Gosub, SUS_SuspendRestoreState
			IfMsgBox, OK
				Reload
		}
	}
	REL_InitDone = 1
	Return
	
	
	
; [EXT] exits this script
	
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
	
	
	
; [CFG] handles the persistent configuration
	
	CFG_LoadSettings:
	CFG_IniFile = %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
	IniRead, SUS_AutoSuspend, %CFG_IniFile%, Main, AutoSuspend, 1
	IniRead, XWN_FocusFollowsMouse, %CFG_IniFile%, WindowHandling, FocusFollowsMouse, 0
	IniRead, SYS_ToolTipFeedback, %CFG_IniFile%, Visual, ToolTipFeedback, 1
	IniRead, UPD_LastUpdateCheck, %CFG_IniFile%, UpdateCheck, LastUpdateCheck, %A_MM%
	IniRead, CFG_LeftMouseButtonHook, %CFG_IniFile%, MouseHooks, LeftMouseButton, 1
	IniRead, CFG_MiddleMouseButtonHook, %CFG_IniFile%, MouseHooks, MiddleMouseButton, 1
	IniRead, CFG_RightMouseButtonHook, %CFG_IniFile%, MouseHooks, RightMouseButton, 1
	IniRead, CFG_FourthMouseButtonHook, %CFG_IniFile%, MouseHooks, FourthMouseButton, 1
	IniRead, CFG_FifthMouseButtonHook, %CFG_IniFile%, MouseHooks, FifthMouseButton, 1
	Return
	
	CFG_SaveSettings:
	CFG_IniFile = %A_ScriptDir%\%SYS_ScriptNameNoExt%.ini
	IniWrite, %SUS_AutoSuspend%, %CFG_IniFile%, Main, AutoSuspend
	IniWrite, %XWN_FocusFollowsMouse%, %CFG_IniFile%, WindowHandling, FocusFollowsMouse
	IniWrite, %SYS_ToolTipFeedback%, %CFG_IniFile%, Visual, ToolTipFeedback
	IniWrite, %UPD_LastUpdateCheck%, %CFG_IniFile%, UpdateCheck, LastUpdateCheck
	IniWrite, %CFG_LeftMouseButtonHook%, %CFG_IniFile%, MouseHooks, LeftMouseButton
	IniWrite, %CFG_MiddleMouseButtonHook%, %CFG_IniFile%, MouseHooks, MiddleMouseButton
	IniWrite, %CFG_RightMouseButtonHook%, %CFG_IniFile%, MouseHooks, RightMouseButton
	IniWrite, %CFG_FourthMouseButtonHook%, %CFG_IniFile%, MouseHooks, FourthMouseButton
	IniWrite, %CFG_FifthMouseButtonHook%, %CFG_IniFile%, MouseHooks, FifthMouseButton
	Return
	
	CFG_ApplySettings:
	If ( SUS_AutoSuspend )
		SetTimer, SUS_SuspendHandler, 1000
	Else
		SetTimer, SUS_SuspendHandler, Off
	
	If ( XWN_FocusFollowsMouse )
		SetTimer, XWN_FocusHandler, 100
	Else
		SetTimer, XWN_FocusHandler, Off
	
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
	
	Hotkey, $LButton, %CFG_LeftMouseButtonHookStr%
	Hotkey, $^LButton, %CFG_LeftMouseButtonHookStr%
	Hotkey, #LButton, %CFG_LeftMouseButtonHookStr%
	Hotkey, #^LButton, %CFG_LeftMouseButtonHookStr%
	
	Hotkey, #MButton, %CFG_MiddleMouseButtonHookStr%
	Hotkey, #^MButton, %CFG_MiddleMouseButtonHookStr%
	Hotkey, $MButton, %CFG_MiddleMouseButtonHookStr%
	Hotkey, $^MButton, %CFG_MiddleMouseButtonHookStr%
	
	Hotkey, $RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $+RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $+!RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $+^RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $+#RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $+!^RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $+!#RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $+^#RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $+!^#RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $!RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $!^RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $!#RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $!^#RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $^RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $^#RButton, %CFG_RightMouseButtonHookStr%
	Hotkey, $#RButton, %CFG_RightMouseButtonHookStr%
	
	Hotkey, $XButton1, %CFG_FourthMouseButtonHookStr%
	Hotkey, $^XButton1, %CFG_FourthMouseButtonHookStr%
	
	Hotkey, $XButton2, %CFG_FifthMouseButtonHookStr%
	Hotkey, $^XButton2, %CFG_FifthMouseButtonHookStr%
	Return
	
	
	
	
	^#!b::
	If ( !A_IsCompiled )
	{
		UPD_VersionFile = %SYS_ScriptDir%\version.txt
		IfExist, %UPD_VersionFile%
		{
			FileDelete, %UPD_VersionFile%
			If ( ErrorLevel )
				Return
		}
		FileAppend, %SYS_ScriptVersion%, %UPD_VersionFile%
		If ( ErrorLevel )
			Return
		
		UPD_BuildFile = %SYS_ScriptDir%\build.txt
		IfExist, %UPD_BuildFile%
		{
			FileDelete, %UPD_BuildFile%
			If ( ErrorLevel )
				Return
		}
		FileAppend, %A_NowUTC% (%A_Hour%:%A_Min% %A_DD%/%A_MM%/%A_YYYY%), %UPD_BuildFile%
		If ( ErrorLevel )
			Return
		
		SYS_TrayTipText = Version and build files were written successfully:`n%UPD_VersionFile%`n%UPD_BuildFile%
		SYS_TrayTipOptions = 2
		SYS_TrayTipSeconds = 5
		Gosub, SYS_TrayTipShow
	}
	Return
	
	!#h::			; open AHK help
	{		
		If WinExist("ahk_exe hh.exe") 
			WinActivate, ahk_exe hh.exe
		Else
			Run, "D:\Programs\AutoHotkey\AutoHotkey.chm"
	}
	Return
	
	!#k::			; open AHK KeyHistory
	{		
		Run, "D:\Programs\AutoHotkey\MyLib\TestScripts\KeyHistory.ahk"
	}
	Return
	
	!#w::		; open WindowSpy
	{		
		If WinExist("ahk_id 4280") 
			WinActivate, ahk_exe AutoHotkey.exe
		Else
			Run, "D:\Programs\AutoHotkey\WindowSpy.ahk"
	}
	Return
	
	Pause::		Pause ; Pressing Pause (Fn+P) once will pause the script. Pressing it again will unpause.
	
	!#u::			; rerun this script
	{
		Run, "D:\Programs\AutoHotkey\MyLib\NiftyWindows\NiftyWindows.ahk"
		SYS_TrayTipText = NiftyWindows.ahk is reruned!
		Gosub, SYS_TrayTipShow
	}
	Return
	!c::				Run, "C:\Windows\System32\calc.exe"										; Alt+C to run Calculator
	!n::				Run, "D:\Programs\Notepad++\notepad++.exe"									; Alt+N to launch or switch to Notepad++
	#!j::				Run, "D:\Programs\AutoHotkey\AHK-Studio-master\AHK-Studio.ahk"				; Wib+Alt+J to launch AHK-Studio
	#c::				Run, "D:\Programs\sMath Studio\SMathStudio_Desktop.exe"						; Win+C to launch SMath
	#Del::			FileRecycleEmpty ; win + del 												; make trash empty
	!d:: 			Run, "C:\Users\OkS\Downloads" 											; open Downloads folder
	!#m:: 			Run, "%windir%\system32\magnify.exe"										; launch default ScreenMagnifier
	^!m:: 			Run, "D:\Programs\AutoHotkey\MyLib\Other\ScreenMagnifier.ahk"					; launch ScreenMagnifier
	>^Down::			Send, {PgDn}
	>^Up::			Send, {PgUp}
	>^Left::			Send, {Home}
	>^Right::			Send, {End}
	>+Down::			Send, {Volume_Down 1}
	>+Up::			Send, {Volume_Up 1}
	>+Left::			Send, {XButton1}
	>+Right::			Send, {XButton2}
	^+!t::			Run, https://translate.google.com/?source=gtx#view=home&op=translate&sl=auto&tl=uk&text=%clipboard%
	^+!g::			Run, https://google.com.ua/search?lr=-lang_ru&safe=off&q=%clipboard%
	#Esc::			Send, {LCtrl down}{LShift down}{Esc}{LCtrl up}{LShift up}
	XButton2 & WheelUp::	PgUp
	XButton2 & WheelDown::	PgDn
	
	CapsLock::		
	{
		GetKeyState, RButtonState, RButton, P
		If (RButtonState = "D")
			Send, {Insert}
		Else
			Send, {LAlt down}{Tab}{LAlt up}
	}
	Return
	
	ScrollLock::
	{
		Send, {ScrollLock}
		If (GetKeyState("ScrollLock", "T"))
			SYS_ToolTipText = ScrollLock ON
		Else If (not GetKeyState("ScrollLock", "T"))
			SYS_ToolTipText = ScrollLock Off
		SYS_ToolTipSeconds = 0.5
		Gosub, SYS_ToolTipShow
	}
	Return
	
	#If GetKeyState("ScrollLock", "T") ; True if ScrollLock is ON, false otherwise.
	{
		F1:: 			Send, {Volume_Mute}
		F2:: 			Send, {Volume_Down}
		F3:: 			Send, {Volume_Up}
		F4:: 			Send, {LAlt down}{Tab}{LAlt up}
		F4 & F5:: 		BS.SetBrightness(-1)
		F4 & F6:: 		BS.SetBrightness(1)
		F5:: 			BS.SetBrightness(-10)
		F6:: 			BS.SetBrightness(10)
		F7:: 			SendMessage, 0x112, 0xF140, 2, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF140 is SC_SCREENSAVE
		F8:: 			DllCall("LockWorkStation")
		F9::			#i
		F12::		Insert
	}
	Return
	
	>^Delete::			Gosub, ScrollLock
	
	~sc029::
	IfWinActive, ahk_class CabinetWClass
		Send, {LAlt down}{Up down}{LAlt up}{Up up}
	Else
		Send, {`}
	Return
	
	~MButton::
	IfWinActive, ahk_class CabinetWClass
		Send, {LAlt}{Up}
	Else
		Send, {MButton}
	Return
	
	#If GetKeyState("RButton", "P") ; True if RButton is pressed, false otherwise.
	{
		F1:: 				Send, {Volume_Mute}
		F2:: 				Send, {Volume_Down}
		F3:: 				Send, {Volume_Up}
		F4:: 				Send, {LAlt down}{Tab}{LAlt up}
		F4 & F5:: 		BS.SetBrightness(-1)
		F4 & F6:: 		BS.SetBrightness(1)
		F5:: 				BS.SetBrightness(-10)
		F6:: 				BS.SetBrightness(10)
		F7:: 				SendMessage, 0x112, 0xF140, 0, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF140 is SC_SCREENSAVE
		F8::				DllCall("LockWorkStation")
		F9::				#i
		F12::				Insert
		*w::				Up
		*a::				Left
		*s::				Down
		*d::				Right
		f::					^f
		*x:: 				^x
		*c:: 				^c
		*v:: 				^v
		*z:: 				^a
		k::				Gosub, ScrollLock
		l::					SendMessage, 0x112, 0xF170, 2, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF170 is SC_MONITORPOWER ; (2 = off, 1 = standby, -1 = on)
		r::					^r
		q:: 				^z
		e:: 				^y
		1::				#^LEFT
		2::				#^RIGHT
		3::				#^d
		4::				#^F4
		Tab::			#Tab
		*LShift::
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
		*LCtrl::
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
	
	#If GetKeyState("NumLock", "T") ; True if NumLock is ON, false otherwise.
	{
		
		$#NumpadAdd::	Send, {Volume_Up 10} 		; Win+NumpadAdd increase sound level
		$#NumpadSub::	Send, {Volume_Down 10} 	; Win+NumpadSub decrease sound level
		$+NumpadAdd::	Send, {Volume_Up 5} 			; Shift+Numpad	Add increase sound level
		$+NumpadSub::	Send, {Volume_Down 5} 		; Shift+NumpadSub decrease sound level
		^Numpad4:: 		Send, {Media_Play_Pause}
		^Numpad5:: 		Send, {Media_Stop}
		^Numpad6:: 		Send, {Media_Prev}
		^NumpadMult:: 	Send, {Media_Next}
		$^NumpadAdd::	Send, {Volume_Up 1} 			; Ctr+Numpad	Add increase sound level
		$^NumpadSub::	Send, {Volume_Down 1} 		; Ctr+NumpadSub decrease sound level
		^NumpadDiv::
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
		
		^Numpad1:: 
		{
			WinGetClass, ActiveWindow, A
			Send, ^c
			RunWait, "D:\Google Drive\Code\Python\My collection\fix text from another language\English to Ukrainian.pyw"
			Critical
			WinActivate, ahk_class %ActiveWindow%
			Send, ^v
		}
		Return
		
		$^Numpad0:: HideShowTaskbar(hide := !hide)
		
		^Numpad2::
		{
			WinGetClass, ActiveWindow, A
			Send, ^c
			RunWait, "D:\Google Drive\Code\Python\My collection\fix text from another language\Ukrainian to English.pyw"
			Critical
			WinActivate, ahk_class %ActiveWindow%
			Send, ^v
		}
		Return
		^!Numpad7::		Run, "%SYS_ScriptDir%\NumpadMouse.ahk"
		^Numpad7::
		{
		; Retrieve the current speed so that it can be restored later:
			DllCall("SystemParametersInfo", UInt, 0x70, UInt, 0, UIntP, OrigMouseSpeed, UInt, 0) ; SPI_GETMOUSESPEED = 0x70
		; Now set the mouse to the slower speed specified in the next-to-last parameter (the range is 1-20, 10 is default):
			InputBox, UserInput, Mouse Sensitive, Please enter a number from 1 to 20.`nPrevious value is %OrigMouseSpeed%., , 250, 140
			Transform, UserInput, Ceil, UserInput
			If ErrorLevel
				Return
			Else
				MsgBox, You entered %UserInput%. Previous value is %OrigMouseSpeed%.
			DllCall("SystemParametersInfo", UInt, 0x71, UInt, 0, Ptr, UserInput, UInt, 0) ; SPI_SETMOUSESPEED = 0x71
			KeyWait F1  ; This prevents keyboard auto-repeat from doing the DllCall repeatedly.
			Return
		}
		
		^+NumpadSub::
		{
			InputBox, UserInput, Get the ASCII code of char, Please enter char., , 240, 180
			Transform, OutputVar, Asc, %UserInput%  ; Get the ASCII codes
			If (UserInput)
				MsgBox, %OutputVar%
			Return
		}
		^Numpad8::		Run, "D:\Programs\WinCompose-NoInstall-0.9.0\wincompose-sequences.vbs"
		^Numpad9::
		IniRead, PreWinComposeDisabled, D:\Programs\WinCompose-NoInstall-0.9.0\settings.ini, global, disabled
		If PreWinComposeDisabled = False
		{
			WinComposeDisabled = True
			FutureWinComposeAction = disable
		}
		Else
		{
			WinComposeDisabled = False
			FutureWinComposeAction = enable
		}
		MsgBox, 3,, Would you like to (re)run WinCompose?
		IfMsgBox Yes
		{
			Process, Close,  wincompose.exe
			Run *RunAs "D:\Programs\WinCompose-NoInstall-0.9.0\wincompose.exe"
		}
		IfMsgBox No
		{
			MsgBox, 259,, Would you like to run WinCompose sequences?
			IfMsgBox Yes
				Run, "D:\Programs\WinCompose-NoInstall-0.9.0\wincompose-sequences.vbs"
			IfMsgBox No
			{
				MsgBox, 259,, WinCompose is running. Would you like to %FutureWinComposeAction% WinCompose?, 10
				IfMsgBox Yes
					IniWrite, %WinComposeDisabled%, D:\Programs\WinCompose-NoInstall-0.9.0\settings.ini, global, disabled
				IfMsgBox No
				{
					MsgBox, 259,, Would you like to run WinCompose settings?
					IfMsgBox Yes
						Run, "D:\Programs\WinCompose-NoInstall-0.9.0\wincompose-settings.vbs"
					Else
						Return
				}
				Else
					Return
			}
			Else
				Return
		}
		Else
			Return
		Return
	}
	Return
	
	ReRun_WinCompose:
	Process, Close,  wincompose.exe
	Run *RunAs "D:\Programs\WinCompose-NoInstall-0.9.0\wincompose.exe"
	Return
	
	SetTimer, ReRun_WinCompose, 600000
	
	^+!c::			; Get color (in HEX) of pixel in mouse position 
	{
		MouseGetPos,x,y
		PixelGetColor,rgb,x,y,RGB
		StringTrimLeft,rgb,rgb,2
		Clipboard=%rgb%
	}
	Return
	
	$!w::			; Alt+W to launch or switch to Chrome
	If WinExist("ahk_exe chrome.exe") 
		WinActivate, ahk_exe chrome.exe
	Else
		Run, "C:\Users\OkS\Desktop\Google Chrome.lnk"
	
	^+c::			; Google Search highlighted text
	{
		Send, ^c
		Sleep, 50
		Run, http://www.google.com/search?q=%clipboard%
	}
	Return
	
	#IfWinActive ahk_class ConsoleWindowClass
	^v::
;Send, {Raw}%clipboard%
	Send !{Space}ep
	Return
	#IfWinActive
	
	
	#h::			; Toggles hidden files in explorer
	RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
	If HiddenFiles_Status = 2 
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
	Else 
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
	WinGetClass, eh_Class,A
	If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
		send, {F5}
	Else PostMessage, 0x111, 28931,,, A
		send, {F5}
	Return
	
	#y::			; Toggles file extensions in explorer
	RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
	If HiddenFiles_Status = 1 
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
	Else 
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
	WinGetClass, eh_Class,A
	If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
		send, {F5}
	Else PostMessage, 0x111, 28931,,, A
		send, {F5}
	Return
	
	GetActiveExplorerPath()
	{
		explorerHwnd := WinActive("ahk_class CabinetWClass")
		if (explorerHwnd)
		{
			for window in ComObjCreate("Shell.Application").Windows
			{
				if (window.hwnd==explorerHwnd)
				{
					return window.Document.Folder.Self.Path
				}
			}
		}
	}
	
	#p::			GetActiveExplorerPath() ; Get current explorer window path in explorer
	
	
	GetKeyboardLanguage()
	{
		SetFormat, Integer, H
		WinGet, WinID,, A
		ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
		InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
  ;MsgBox %InputLocaleID%
  ;InputLocaleID := InputLocaleID & 0xFFFF
  ;MsgBox %InputLocaleID%
		Return %InputLocaleID%
	}
	
	SetDefaultKeyboard(layout){
		PostMessage, 0x50, 0, %layout%,, A
	}
	return
	
	Uk_U2 	:= 0xF0C20422
	Uk_Ex 	:= 0xF0A80422
	Ru_Uk 	:= 0x4192000
	Ru 	  	:= 0x4190419
	En_ExLa := 0xF0C10409
	En_US 	:= 0x04090409
	En_Co	:= 0xF0CE0409
	
	>^CapsLock::
	{
		l := GetKeyboardLanguage()
		MsgBox %l%`n`nUk_U2 := 0xF0Cx0422`nUk_Ex := 0xF0A80422`nRu_Uk:= 0x4192000`nRu:= 0x4190419`nEn_ExLa:= 0xF0C10409`nEn_US:= 0x04090409
		En_Co	:= 0xF0CE0409
	}
	Return
	
	
	LanguageChanger:
	L := GetKeyboardLanguage()
	L0 := L
	If (L = 0xF0C10409)
	{
		Aim = 0xF0C50422
		PostMessage, 0x50, 0, 0xF0C20422,, %WinID%
		L := GetKeyboardLanguage()
		if (L = 0xF0C20422)
			MsgBox YES!!!
		PostMessage, 0x50, 0, 0xF0C20422,, A
		SYS_ToolTipText = Ukrainian
		SYS_ToolTipMiliSeconds = 5004
		MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
		SYS_ToolTipX += 16
		SYS_ToolTipY += 4
		ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
		SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
	}
	Else
	{
		Aim = 0xF0C10409
		PostMessage, 0x50, 0, 0xF0C10409,, A
		SYS_ToolTipText = English
		SYS_ToolTipMiliSeconds = 500
		MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
		SYS_ToolTipX += 16
		SYS_ToolTipY += 4
		ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
		SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
	}
	L := GetKeyboardLanguage()
	If ( L = Aim )
		Return
	Else
	{
		Gosub, LanguageChangerStandart
		L := GetKeyboardLanguage()
		If ( L = Aim )
			Return
		Else If (L0 = L)
		;MsgBox L: %L%`nA: %Aim%
			SYS_ToolTipText = L: %L%`nA: %Aim%
		SYS_ToolTipMiliSeconds = 500
		MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
		SYS_ToolTipX += 16
		SYS_ToolTipY += 4
		ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
		SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
	}
	Return
	
	
	~LCtrl & ~LShift:: 	
	Gosub, LanguageChangerStandart
	~LShift & ~LCtrl:: 	
	Gosub, LanguageChangerStandart
	
	LanguageChangerNew:
	Gosub, RemoveToolTip
	WinGet, active_id, ID, A
	Send, {LShift down}{LCtrl}{LShift up}
	ControlFocus, , %active_id%
	Sleep, 100
	L := GetKeyboardLanguage()
	If (L = 0xF0C10409)
		SYS_ToolTipText = English Extended Latin
	Else If (L = 0xF0C50422)
		SYS_ToolTipText = Ukrainian Unicode
	Else If (L = 0x4190419)
		SYS_ToolTipText = Russian
	Else
		SYS_ToolTipText = Unknown language
	SYS_ToolTipMiliSeconds = 500
	MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
	SYS_ToolTipX += 16
	SYS_ToolTipY += 4
	ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
	SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
	Return
	
	LanguageChangerStandart:
	Gosub, RemoveToolTip
	WinGet, active_id, ID, A
	ControlFocus, , %active_id%
	Sleep, 100
	L := GetKeyboardLanguage()
	If (L = 0xF0C10409)
		SYS_ToolTipText = English Extended Latin
	Else If (L = 0xF0C50422)
		SYS_ToolTipText = Ukrainian Unicode
	Else
		SYS_ToolTipText = Another language
	SYS_ToolTipMiliSeconds = 500
	MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
	SYS_ToolTipX += 16
	SYS_ToolTipY += 4
	ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
	SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
	;Send, {LShift down}{LCtrl}{LShift up}
	Return
	
	
	ShowCursor:
	SystemCursor("On")
	ExitApp
	
	!#c::SystemCursor("Toggle")  ; Win+C hotkey to toggle the cursor on and off.
	
	SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
	{
		static AndMask, XorMask, $, h_cursor
        ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
		if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
		{
			$ := "h"                                       ; active default cursors
			VarSetCapacity( h_cursor,4444, 1 )
			VarSetCapacity( AndMask, 32*4, 0xFF )
			VarSetCapacity( XorMask, 32*4, 0 )
			system_cursors := "32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650"
			StringSplit c, system_cursors, `,
			Loop %c0%
			{
				h_cursor   := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
				h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
				b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0
                , "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
			}
		}
		if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
			$ := "b"  ; use blank cursors
		else
			$ := "h"  ; use the saved cursors
		
		Loop %c0%
		{
			h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
			DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
		}
	}
	
	
; Press CapsLock and Numpad2 to reload all AutoHotkey scripts
	CapsLock & Numpad2::
	ReloadAllAhkScripts() {
		DetectHiddenWindows, On
		SetTitleMatchMode, 2
		WinGet, allAhkExe, List, ahk_class AutoHotkey
		Loop, % allAhkExe {
			hwnd := allAhkExe%A_Index%
			if (hwnd = A_ScriptHwnd)  ; ignore the current window for reloading
			{
				continue
			}
			PostMessage, 0x111, 65303,,, % "ahk_id" . hwnd
		}
		Reload
	}
	
	
	
	HideShowTaskbar(action) {
		static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
		VarSetCapacity(APPBARDATA, size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
		NumPut(size, APPBARDATA), NumPut(WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
		NumPut(action ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
		DllCall("Shell32\SHAppBarMessage", UInt, ABM_SETSTATE, Ptr, &APPBARDATA)
	}