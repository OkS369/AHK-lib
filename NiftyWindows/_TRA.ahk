; [TRA] provides window transparency

/**
	* Adjusts the transparency of the active window in ten percent steps
	* (opaque = 100%) which allows the contents of the windows behind it to shine
	* through. If the window is completely transparent (0%) the window is still
	* there and clickable. If you loose a transparent window it will be extremly
	* complicated to find it again because it's invisible (see the first hotkey
	* in this list for emergency help in such situations).
*/

>#>^WheelUp::
>#>+WheelUp::
>#>^WheelDown::
>#>+WheelDown::
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
;WinSet, TransColor, %TRA_PixelColor% %TRA_WinAlpha%, ahk_id %TRA_WinID%
WinSet, TransColor, %TRA_PixelColor% 200%TRA_WinID%, ahk_id %TRA_WinID%
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

Hotkey, #^LButton, %CFG_LeftMouseButtonHookStr%
Hotkey, #^MButton, %CFG_MiddleMouseButtonHookStr%
Hotkey, #MButton, %CFG_MiddleMouseButtonHookStr%

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