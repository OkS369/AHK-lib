;Gosub, TRY_TrayInit

/*
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
*/
#Include %A_ScriptDir%\Addons\BrightnessSetter.ahk
;Run, "%SYS_ScriptDir%\NumpadMouse.ahk"
;SetScrollLockState, Off


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

!Pause::		Pause ; Pressing Alt+ Pause (Fn+P) once will pause the script. Pressing it again will unpause.



!c::					Run, "C:\Windows\System32\calc.exe"										; Alt+C to run Calculator
!n::					Run, "D:\Programs\Notepad++\notepad++.exe"									; Alt+N to launch or switch to Notepad++
#!j::				Run, "D:\Programs\AutoHotkey\AHK-Studio-master\AHK-Studio.ahk"					; Wib+Alt+J to launch AHK-Studio
#c::					Run, "D:\Programs\sMath Studio\SMathStudio_Desktop.exe"						; Win+C to launch SMath
#Del::				FileRecycleEmpty ; win + del 												; make trash empty
!d:: 				Run, "C:\Users\OkS\Downloads" 											; open Downloads folder
!#m:: 				Run, "%windir%\system32\magnify.exe"										; launch default ScreenMagnifier
^!m:: 				Run, "D:\Programs\AutoHotkey\MyLib\Other\ScreenMagnifier.ahk"					; launch ScreenMagnifier
>^Down::				Send, {PgDn}
>^Up::				Send, {PgUp}
>^Left::				Send, {Home}
>^Right::				Send, {End}
>+Down::				Send, {Volume_Down 1}
>+Up::				Send, {Volume_Up 1}
>+Left::				Send, {XButton1}
>+Right::				Send, {XButton2}
^+!t::				Run, https://translate.google.com/?source=gtx#view=home&op=translate&sl=auto&tl=uk&text=%clipboard%
^+!g::				Run, https://google.com.ua/search?lr=-lang_ru&safe=off&q=%clipboard%
#Esc::				Send, {LCtrl down}{LShift down}{Esc}{LCtrl up}{LShift up}
NumLock::				DllCall("LockWorkStation")
RControl & RShift::		Send !+{Esc}
RControl & Enter::		Send !{Esc}
^!F4::				WinKill, A

^!q::
{
	If (FanState = 0)
	{
		Run *RunAs "C:\Program Files (x86)\NoteBook FanControl\Fan_auto.bat.lnk",, hide
		FanState = 1
		SYS_ToolTipText = Fan in auto mode
	}
	Else If (FanState = 1)
	{
		Run *RunAs "C:\Program Files (x86)\NoteBook FanControl\Fan_stop.bat.lnk",, hide
		FanState = 0
		SYS_ToolTipText = Fan control is stopped
	}
	Else
	{
		Run *RunAs "C:\Program Files (x86)\NoteBook FanControl\Fan_auto.bat.lnk",, hide
		FanState = 1
		SYS_ToolTipText = Fan in auto mode
	}
	SYS_ToolTipSeconds = 2.0
	Gosub, SYS_ToolTipShow
}
Return
		
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
	F9::				#i
	F12::			Insert
}
Return

>^Delete::			Gosub, ScrollLock

; Horizontal scrolling in Excel only
#IfWinActive ahk_class XLMAIN
{
	CapsLock &  WheelUp:: 
	SetScrollLockState, On 
	SendInput {Left} 
	SetScrollLockState, Off 
	Return 
	
	CapsLock & WheelDown:: 
	SetScrollLockState, On 
	SendInput {Right} 
	SetScrollLockState, Off 
	Return 
}
; Horizontal scrolling in Word only
#IfWinActive ahk_class WINWORD
{
; Shift + Wheel for horizontal scrolling
	CapsLock & WheelDown::WheelRight
	CapsLock & WheelUp::WheelLeft
}
; Horizontal scrolling in everything except Excel. 
#IfWinNotActive ahk_class XLMAIN 
{
;!WheelDown::WheelRight
;!WheelUp::WheelLeft
	CapsLock & WheelUp::  ; Scroll left.
	ControlGetFocus, control, A
	Loop 5  ; <-- Increase this value to scroll faster.	
		SendMessage, 0x114, 0, 0, %control%, A ; 0x114 is WM_HSCROLL
	return
	
	CapsLock & WheelDown:: ; Scroll right.
	ControlGetFocus, control, A
	Loop 5  ; <-- Increase this value to scroll faster.	
		SendMessage, 0x114, 1, 0, %control%, A ; 0x114 is WM_HSCROLL
	return
}

~sc029::
IfWinActive, ahk_class CabinetWClass
	Send, {LAlt down}{Up down}{LAlt up}{Up up}
Else
	Send, {`}
	Return
	
	#If GetKeyState("RButton", "P") ; True if RButton is pressed, false otherwise.
	{
		F1:: 				Send, {Volume_Mute}
		F2:: 				Send, {Volume_Down}
		F3:: 				Send, {Volume_Up}
		F4:: 				Send, {LAlt down}{Tab}{LAlt up}
		F4 & F5:: 			BS.SetBrightness(-1)
		F4 & F6:: 			BS.SetBrightness(1)
		F5:: 				BS.SetBrightness(-10)
		F6:: 				BS.SetBrightness(10)
		F7:: 				SendMessage, 0x112, 0xF140, 0, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF140 is SC_SCREENSAVE
		F8::					DllCall("LockWorkStation")
		F9::					#i
		F12::				Insert
		*w::					Up
		*a::					Left
		*s::					Down
		*d::					Right
		f::					^f
		*x:: 				^x
		*c:: 				^c
		*v:: 				^v
		*z:: 				^a
		k::					Gosub, ScrollLock
		l::					SendMessage, 0x112, 0xF170, 2, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF170 is SC_MONITORPOWER ; (2 = off, 1 = standby, -1 = on)
		r::					^r
		q:: 					^z
		e:: 					^y
		1::					#^LEFT
		2::					#^RIGHT
		3::					#^d
		4::					#^F4
		Tab::				^!Tab
		*RShift::
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
		*RCtrl::
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
		
		$^Numpad0:: HideShowTaskbar(hide := !hide)
		
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
		
		^Numpad4:: 		Send, {Media_Play_Pause}
		^Numpad5:: 		Send, {Media_Stop}
		^Numpad6:: 		Send, {Media_Prev}
		
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
	}
	Return
	
	$!w::
	$^!w::							; Alt+W to launch or switch to browser
	IfInString, A_ThisHotkey, ^
		Run, "D:\My Workplace\Прграми\Інтернет\Веб-переглядачі\Cent Browser.lnk" --new-window --incognito
	Else If !WinExist("ahk_exe chrome.exe")
		Run, "D:\My Workplace\Прграми\Інтернет\Веб-переглядачі\Cent Browser.lnk"
	Else
		WinActivate, ahk_class Chrome_WidgetWin_1
	WinActivateBottom, ahk_class Chrome_WidgetWin_1
	Return
	
	^+c::			; Google Search highlighted text
	{
		Send, ^c
		Sleep, 50
		Run, http://www.google.com/search?q=%clipboard%
	}
	Return
	
	!q::				; ability quickly set highlighted text to title mode (first letter in UPPER case)
	{
		clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
		Send, ^c
		ClipWait
		ClipSaved := Clipboard
		StringUpper, OutputVar, ClipSaved, T
		Clipboard := OutputVar
		Send, ^v
	}
	Return
	
	!g::			;run Google Search or new tab of browser
	{
		;Run, http://www.google.com/
		Run, "http://"
	}
	Return
	
	#IfWinActive ahk_class ConsoleWindowClass
	^v::
;Send, {Raw}%clipboard%
	Send !{Space}ep
	Return
	#IfWinActive
	
	<^<!e::
	{
		Run *RunAs "C:\Users\OkS\Desktop\Ярлики\Перезапустити Провідник.bat"
	}
	Return
	
	<^<!0::
	{
		Run, "D:\Programs\Windows TweakerS\Win 10 Tweaker.exe"
	}
	Return
	
	<^<!9::
	{
		Run, cmd.exe
	}
	Return
	
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
	En_ExLa 	:= 0xF0C10409
	En_US 	:= 0x04090409
	En_Co	:= 0xF0CE0409
	
	>^CapsLock::
	{
		l := GetKeyboardLanguage()
		MsgBox %l%`n`nUk_U2 := 0xF0Cx0422`nUk_Ex := 0xF0A80422`nRu_Uk:= 0x4192000`nRu:= 0x4190419`nEn_ExLa:= 0xF0C10409`nEn_US:= 0x04090409
		En_Co	:= 0xF0CE0409
	}
	Return
	
	/*
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
		
		
;~LCtrl & ~LShift:: 		Gosub, LanguageChangerStandart
		~LShift & ~LCtrl:: 		Gosub, LanguageChangerStandart
		
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
			SYS_ToolTipText = Ukrainian Unicode
		Else If (L = 0xF0C50422)
			SYS_ToolTipText = English Extended Latin
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
	*/
	
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