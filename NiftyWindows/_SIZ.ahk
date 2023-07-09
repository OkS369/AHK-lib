; [SIZ {NWD}] provides several size adjustments to windows

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