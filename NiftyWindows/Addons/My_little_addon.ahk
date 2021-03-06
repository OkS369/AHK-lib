﻿#Include %A_ScriptDir%\Addons\BrightnessSetter.ahk
#Include %A_ScriptDir%\Addons\ProcessSuspender.ahk
#Include %A_ScriptDir%\Addons\AHK controls.ahk
#Include %A_ScriptDir%\Addons\StringCaseProcessing.ahk
#Include %A_ScriptDir%\Addons\TrickForWindows.ahk



;Run, "%SYS_ScriptDir%\NumpadMouse.ahk"
;SetScrollLockState, Off


#!c::				Run, "C:\Windows\System32\calc.exe"										; Wib+Alt+C to run Calculator
!n::					Run, "D:\Programs\Notepad++\notepad++.exe"									; Alt+N to launch or switch to Notepad++
#Del::				FileRecycleEmpty ; win + del 												; make trash empty
#q:: 				Run, "C:\Users\OkS\Downloads" 											; open Downloads folder
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
RControl & Home::		Send !+{Esc}
RControl & End::		Send !{Esc}

	
Pause::		
Suspend, Permit
{
	DllCall("LockWorkStation")
	SetNumLockState, On
}

^!F4::
Suspend, Permit
{
	WinKill, A
}

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
		Send, ^!{Tab}
	Else
		Send, {LAlt down}{Tab}{LAlt up}
	SetCapsLockState, Off
}
Return


ScrollLock:
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

;#If GetKeyState("ScrollLock", "T") ; True if ScrollLock is ON, false otherwise.
;{
	;F1:: 			Send, {Volume_Mute}
	;F2:: 			Send, {Volume_Down}
	;F3:: 			Send, {Volume_Up}
	;F4:: 			Send, {LAlt down}{Tab}{LAlt up}
	;F4 & F5:: 		BS.SetBrightness(-1)
	;F4 & F6:: 		BS.SetBrightness(1)
	;F5:: 			BS.SetBrightness(-10)
	;F6:: 			BS.SetBrightness(10)
	;F7:: 			SendMessage, 0x112, 0xF140, 2, , Program Manager ; 0x112 is WM_SYSCOMMAND ; 0xF140 is SC_SCREENSAVE
	;F8:: 			DllCall("LockWorkStation")
	;F9::				#i
	;F12::			Insert
;}
;Return

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

CapsLock & Space::
Suspend, Permit
{
	If (BH_Space)
		BH_Space := 0
	Else
		{
			BH_Space := 1
			BH_Space_Delay := 1000
			BH_Space_StartSleep := 0
		}
}
Return

#If ( ( (SUS_WinMinMax = 0) and (SUS_WinX = 0 and SUS_WinY = 0) and (SUS_WinW = A_ScreenWidth and SUS_WinH = A_ScreenHeight) ) and BH_Space )
{
	#if GetKeyState("Space", "P")
	{
		Shift & s::
		Suspend, Permit
		{
			If (BH_Space_StartSleep)
				BH_Space_StartSleep := 0
			Else
				BH_Space_StartSleep := 1
		}
		Return
		
		Shift & 0::
		Shift & 1::
		Shift & 2::
		Shift & 3::
		Shift & 4::
		Shift & 5::
		Shift & 6::
		Shift & 7::
		Shift & 8::
		Shift & 9::
		Suspend, Permit
		{
			IfInString, A_ThisHotkey, 0
				BH_Space_Delay := 2000
			IfInString, A_ThisHotkey, 1
				BH_Space_Delay := 250
			IfInString, A_ThisHotkey, 2
				BH_Space_Delay := 400
			IfInString, A_ThisHotkey, 3
				BH_Space_Delay := 500
			IfInString, A_ThisHotkey, 4
				BH_Space_Delay := 600
			IfInString, A_ThisHotkey, 5
				BH_Space_Delay := 750
			IfInString, A_ThisHotkey, 6
				BH_Space_Delay := 800
			IfInString, A_ThisHotkey, 7
				BH_Space_Delay := 900
			IfInString, A_ThisHotkey, 8
				BH_Space_Delay := 1000
			IfInString, A_ThisHotkey, 9
				BH_Space_Delay := 1500
		}
		Return
	}
		
	*~$Space::
	Suspend, Permit
	WinGet, SUS_WinMinMax, MinMax, ahk_id %SUS_WinID%
	WinGetPos, SUS_WinX, SUS_WinY, SUS_WinW, SUS_WinH, ahk_id %SUS_WinID%
	If ( ( (SUS_WinMinMax = 0) and (SUS_WinX = 0 and SUS_WinY = 0) and (SUS_WinW = A_ScreenWidth and SUS_WinH = A_ScreenHeight) ) and BH_Space )
	{
		If (BH_Space_StartSleep)
			Sleep, 1000
		SetTimer, BH_Space, -0
	}
	Return

	BH_Space:
	{
		If GetKeyState("Space", "P")
			{
				Send, {Blind}{Space}
				SetTimer, BH_Space, -%BH_Space_Delay%
			}
		Else
			{
				SetTimer, BH_Space, Off
			}
	}
	Return
}

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
	Space::				Send, {Enter}
	1::					#^LEFT
	2::					#^RIGHT
	3::					#^d
	4::					#^F4
	Tab::				#Tab
	]::
	Suspend, Permit					
	{
		Send,#^{LEFT}
	}
	Return
	
	Enter::
	Suspend, Permit					
	{
		Send, #^{RIGHT}
	}
	Return
	
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
	;$^NumpadAdd::	Send, {Volume_Up 1} 			; Ctr+Numpad	Add increase sound level
	;$^NumpadSub::	Send, {Volume_Down 1} 		; Ctr+NumpadSub decrease sound level
	^!NumpadDiv::
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
	
	$#Numpad0:: HideShowTaskbar(hide := !hide)
	
	+Numpad1:: 
	{
		WinGetClass, ActiveWindow, A
		Send, ^c
		RunWait, "D:\Google Drive\Code\Python\My collection\fix text from another language\English to Ukrainian.pyw"
		Critical
		WinActivate, ahk_class %ActiveWindow%
		Send, ^v
	}
	Return
	
	+Numpad2::
	{
		WinGetClass, ActiveWindow, A
		Send, ^c
		RunWait, "D:\Google Drive\Code\Python\My collection\fix text from another language\Ukrainian to English.pyw"
		Critical
		WinActivate, ahk_class %ActiveWindow%
		Send, ^v
	}
	Return
	
	+Numpad4:: 		Send, {Media_Play_Pause}
	+Numpad5:: 		Send, {Media_Stop}
	+Numpad6:: 		Send, {Media_Prev}
	
	+!Numpad7::		Run, "%SYS_ScriptDir%\NumpadMouse.ahk"
	+Numpad7::
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
$!+w::
$^!w::							; Alt+W to launch or switch to browser
IfInString, A_ThisHotkey, ^
	Run, "D:\My Workplace\   \   Усі програми\Cent Browser.lnk" --new-window --incognito
IfInString, A_ThisHotkey, +
	Run, "D:\My Workplace\   \   Усі програми\Cent Browser.lnk" --new-window --guest
Else If !WinExist("ahk_exe chrome.exe")
	Run, "D:\My Workplace\   \   Усі програми\Cent Browser.lnk"
Else
	WinActivate, ahk_exe chrome.exe
WinActivateBottom, ahk_exe chrome.exe
Return

^+g::			; Google Search highlighted text
{
	Send, ^c
	Sleep, 50
	Run, http://www.google.com/search?q=%clipboard%
}
Return

!q::				; ability quickly set highlighted text to title mode (first letter in upper case) or lower case (depends on start case of word)
{
	;StringCaseSense, On
	clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
	Send, ^c
	ClipWait
	ClipSaved0 := Clipboard
	ClipSaved :=  Trim(ClipSaved0)
	ClipFirstChar := SubStr(ClipSaved, 1, 1)
	ClipLastChar := SubStr(ClipSaved, 0)
	If ( IsUpper(ClipFirstChar) and IsUpper(ClipLastChar) )
		StringLower, OutputVar, ClipSaved0
	If ( IsUpper(ClipFirstChar) and IsLower(ClipLastChar) )
		StringLower, OutputVar, ClipSaved0
	If ( IsLower(ClipFirstChar) and IsUpper(ClipLastChar) )
		StringLower, OutputVar, ClipSaved0
	If  ( IsLower(ClipFirstChar) and IsLower(ClipLastChar) )
		StringUpper, OutputVar, ClipSaved0, T 
	;MsgBox, %ClipSaved%, %OutputVar%, %ClipFirstChar%, %ClipLastChar%
	Clipboard := OutputVar
	Send, ^v
	StringCaseSense, Off
}
Return

!g::			;run Google Search or new tab of browser
{
	;Run, http://www.google.com/
	Run, "http://"
}
Return

;#IfWinActive ahk_class ConsoleWindowClass
;^v::
;Send, {Raw}%clipboard%
Send !{Space}
;Return
;#IfWinActive

<^<!e::
{
	Run *RunAs "C:\Users\OkS369\Desktop\Ярлики\Перезапустити Провідник.bat"
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
{
	ToggleHiddenFilesInExplorer()
}
Return

#y::			; Toggles file extensions in explorer
{
	TogglesFileExtensionsInExplorer()
}
Return

#f::			; Resize the colums in explorer
{
	FitColumnsSizeInExplorer()
}
Return


#^p::			; Get current explorer window path in explorer
{
	GetActiveExplorerPath() 
}
Return

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

>^#c::SystemCursor("Toggle")  ; Win+C hotkey to toggle the cursor on and off.

;FileGetAttrib, REL_Attribs, %A_WorkingDir%/Addons/My_little_addon.ahk
FileGetAttrib, REL_Attribs, My_little_addon.ahk
IfInString, REL_Attribs, A
{
	FileSetAttrib, -A, %A_WorkingDir%/Addons/My_little_addon.ahk
	;MsgBox, 4145, Update Handler - %SYS_ScriptInfo%, The following script has changed:`n`n%A_ScriptFullPath%`n`nReload and activate this script?
	;IfMsgBox, OK
	;{
		;IniRead, %SYS_AddonBuild%, %A_ScriptDir%\My_little_addon.ini, Info, Build
		;IniRead, %SYS_AddonVersion%, %A_ScriptDir%\My_little_addon.ini, Info, Version
		;SYS_AddonBuild++
		IniWrite, %SYS_AddonBuild%, %A_ScriptDir%\My_little_addon.ini, Info, Build
		;SYS_AddonVersionnArray := StrSplit(SYS_AddonVersion,".")
		;SYS_AddonVersion =% SYS_ScriptVersionArray[1]"."SYS_ScriptVersionArray[2]"."SYS_ScriptVersionArray[3]"."SYS_AddonBuild
		SYS_AddonBuildSYS_AddonBuild = 156
		SYS_AddonVersion = 0.0.1.156
		IniWrite, %SYS_AddonVersion%, %A_ScriptDir%\My_little_addon.ini, Info, Version
		IniWrite, %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%, %A_ScriptDir%\My_little_addon.ini, Info, Edited
		Reload
	;}
	;MSGBOX, hello  
	Reload
}
Return


/*
	ShowAllMinimizedWindows:
	{
		Send,{LAlt down}{Tab}{LAlt up}
		Send,{LAlt down}{Shift down}{Tab}{Shift up}{LAlt up}
		WinGet, FirstApp_WinID, ID, A
		Windows_IDs := [FirstApp_WinID]
		Loop				
		{
			Send,{LAlt down}{Tab}{LAlt up}
			WinGet, WinID, ID, A
			If WinID in Windows_IDs
				continue
			Else
				Windows_IDs.Push(WinID)
			If (WinID = FirstApp_WinID)
				Break
			if (A_Index > 50)
				break  ; Terminate the loop
		}
		For index, value in Windows_IDs
			MsgBox % "Item " index " is '" value "'"
	}
	Return
*/

!^F7::	
{
	FileSetAttrib, -H, %A_Desktop%\*.*, 1
	RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideIcons, 0
	Send, {LAlt down}{f}{LAlt up}
}
Return

!^F8::	
{
	If (ToggleIconsOnDesktop())
	{
		Send, {LAlt down}{h}{LAlt up}
	}
	Else
	{
		Send, {LAlt down}{f}{LAlt up}
	}
}
Return


!^F9::
!^F10::
{
	IfInString A_ThisHotkey, F10
	{
		ToolTip, Game mode off
		Send, {LControl down}{RAlt down}{LShift down}{9}{LShift up}{LControl up}{RAlt up}
		Sleep, 10
		Send, {LControl down}{LShift down}{F11}{LControl up}{LShift up}
		Sleep, 1000
		ToolTip
	}
	IfInString A_ThisHotkey, F9
	{
		ToolTip, Game mode on
		If !WinExist("ahk_exe MSIAfterburner.exe") 
			Run, "D:\Programs\MSI Afterburner\MSIAfterburner.exe",, Min
		; Run, "D:\Programs\Windows TweakerS\Win 10 Tweaker.exe" kill
		Send, {LControl down}{RAlt down}{LShift down}{0}{LShift up}{LControl up}{RAlt up}
		Sleep, 1000
		Send, {LControl down}{LShift down}{F9}{LControl up}{LShift up}
		Sleep, 1000
		ToolTip
	}
}
Return

LenovoUtility:
>+F12::
{
	;WinGet, PID_of_Lenovo_Utility, PID, ahk_exe utility.exe 
	Process, Exist, utility.exe
	If (ErrorLevel)
		Process, Close, utility.exe
	Else
		Run, "D:\My Workplace\   \ Усі програми\LenovoUtility.lnk"
}
Return

^!f::			; Change windowed application to fullscreen windowed (without borders)
Suspend, Permit
{
	WinSet, Style, -0xC40000, a
	WinMove, a, , 0, 0, 1920, 1080
}
Return