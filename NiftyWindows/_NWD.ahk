; [NWD] nifty window dragging

/**
	* This is the most powerful feature of NiftyWindows. The area of every window
	* is tiled in a virtual 9-cell grid with three columns and rows. The center
	* cell is the largest one and you can grab and move a window around by clicking
	* and holding it with the right mouse button. The other eight corner cells are
	* used to resize a resizable window in the same manner.
*/

RButton::
+RButton::
+!RButton::
+^RButton::
+#RButton::
+!^RButton::
+!#RButton::
+^#RButton::
+!^#RButton::
!RButton::
!^RButton::
!#RButton::
!^#RButton::
^RButton::
^#RButton::
#RButton::
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
If ( (NWD_WinClass = "Progman") or ((NWD_CtrlState = "U") and (((NWD_WinStyle & 0x80000000) and !(NWD_WinStyle & 0x4C0000)) or (NWD_WinClass = "IEFrame") or (NWD_WinClass = "MozillaWindowClass") ) or (NWD_WinClass = "OpWindow") or (NWD_WinClass = "ATL:ExplorerFrame") or (NWD_WinClass = "ATL:ScrapFrame") ) )
;If ( (NWD_WinClass = "Progman") or ((NWD_CtrlState = "U") and (((NWD_WinStyle & 0x80000000) and !(NWD_WinStyle & 0x4C0000)) or (NWD_WinClass in IEFrame,MozillaWindowClass,OpWindow,"ATL:ExplorerFrame","ATL:ScrapFrame") ) ) ) ; ,Chrome_WidgetWin_1
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

NWD_Dragging := (WindowsDraging = 1) and (NWD_WinClass != "Progman") and ((NWD_CtrlState = "D") or ((NWD_WinMinMax != 1) and !NWD_ImmediateDownRequest))

If ( !((NWD_WinStyle & 0x80000000) and !(NWD_WinStyle & 0x4C0000)) )
	IfWinNotActive, ahk_id %NWD_WinID%
		WinActivate, ahk_id %NWD_WinID%

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
SetTimer, RButtonHandler, 10
Return

Hotkey, RButton, %CFG_RightMouseButtonHookStr%
Hotkey, +RButton, %CFG_RightMouseButtonHookStr%
Hotkey, +!RButton, %CFG_RightMouseButtonHookStr%
Hotkey, +^RButton, %CFG_RightMouseButtonHookStr%
Hotkey, +#RButton, %CFG_RightMouseButtonHookStr%
Hotkey, +!^RButton, %CFG_RightMouseButtonHookStr%
Hotkey, +!#RButton, %CFG_RightMouseButtonHookStr%
Hotkey, +^#RButton, %CFG_RightMouseButtonHookStr%
Hotkey, +!^#RButton, %CFG_RightMouseButtonHookStr%
Hotkey, !RButton, %CFG_RightMouseButtonHookStr%
Hotkey, !^RButton, %CFG_RightMouseButtonHookStr%
Hotkey, !#RButton, %CFG_RightMouseButtonHookStr%
Hotkey, !^#RButton, %CFG_RightMouseButtonHookStr%
Hotkey, ^RButton, %CFG_RightMouseButtonHookStr%
Hotkey, ^#RButton, %CFG_RightMouseButtonHookStr%
Hotkey, #RButton, %CFG_RightMouseButtonHookStr%

NWD_SetDraggingOff:
NWD_Dragging = 0
SetTimer, NWD_WindowHandler, Off
SetTimer, ButtonsHandlerAfterWindowDragging, Off
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
CoordMode, Mouse, Screen
MouseGetPos, NWD_MouseX, NWD_MouseY
GetKeyState, NWD_RButtonStateP, RButton, P
GetKeyState, NWD_RButtonState, RButton
GetKeyState, NWD_CtrlState, Ctrl, P
GetKeyState, NWD_LWinState, LWin, P
GetKeyState, NWD_RWinState, RWin, P
If ( (NWD_LWinState = "D") or (NWD_RWinState = "D") )
	NWD_WinState = D
Else
	NWD_WinState = U
If ( NWD_RButtonStateP = "U" )
{
	SetTimer, RButtonHandler, Off
	RButtonPressingCooldownTime = 350
	If ( NWD_ImmediateDown )
		Click, RIGHT, %NWD_MouseX%, %NWD_MouseY%, Up
	Else
		If ( NWD_PermitClick or ( !NWD_Dragging or ((NWD_MouseStartX = NWD_MouseX) and (NWD_MouseStartY = NWD_MouseY)) ) )
		{
			RButtonUnPressedElapsedTime := A_TickCount - RButtonPressedStartTime
			If ( (RButtonUnPressedElapsedTime > RButtonPressingCooldownTime) ) ;or (NWD_CtrlState = "D") )
			{
				Return
			}
			Else If ( RButtonUnPressedElapsedTime < RButtonPressingCooldownTime )
			{
				If (NWD_CtrlState = "D" and NWD_WinState = "D") {
					WinGet, RB_WinProcessName, ProcessName, A
					WinClose, A
					SYS_ToolTipText = %RB_WinProcessName% window closed
					Gosub, SYS_ToolTipFeedbackShow
					Log(RB_WinProcessName " window closed")
				} Else {
					Click, RIGHT, Down
					Click, RIGHT, Up
				}
			}
		}
	Else If (WindowsDraging = 1)
	{
			;SetTimer, NWD_WindowHandler, -25
		GoSub, ButtonsHandlerAfterWindowDragging
	}
	Gosub, NWD_SetAllOff
	NWD_ImmediateDown = 0
}
Else
{
	NWD_MouseDeltaX := NWD_MouseX - NWD_MouseStartX
	NWD_MouseDeltaY := NWD_MouseY - NWD_MouseStartY
	If ((NWD_MouseStartX = NWD_MouseX) and (NWD_MouseStartY = NWD_MouseY))
	{
		If ( NWD_ImmediateDownRequest and !NWD_ImmediateDown )
		{
			MouseClick, RIGHT, %NWD_MouseStartX%, %NWD_MouseStartY%, , , D
			MouseMove, %NWD_MouseX%, %NWD_MouseY%
			NWD_ImmediateDown = 1
			NWD_PermitClick = 0
		}
	}
	Else
		SetTimer, NWD_WindowHandler, -0
}
Return

NWD_WindowHandler:
SetWinDelay, -1
CoordMode, Mouse, Screen
MouseGetPos, NWD_MouseX, NWD_MouseY
WinGetPos, NWD_WinX, NWD_WinY, NWD_WinW, NWD_WinH, ahk_id %NWD_WinID%
GetKeyState, NWD_RButtonState, RButton, P
GetKeyState, NWD_ShiftState, Shift, P
GetKeyState, NWD_AltState, Alt, P
GetKeyState, NWD_CtrState, Ctrl, P
GetKeyState, NWD_LWinState, LWin, P
GetKeyState, NWD_RWinState, RWin, P
RButtonUnPressedElapsedTime := A_TickCount - RButtonPressedStartTime
If ( (NWD_LWinState = "D") or (NWD_RWinState = "D") )
	NWD_WinState = D
Else
	NWD_WinState = U
If ( (NWD_RButtonState = "D") and (WindowsDraging = 1) and (RButtonUnPressedElapsedTime >= 500 or NWD_CtrState = "D") )
{
	MouseGetPos, NWD_MouseX, NWD_MouseY
	NWD_MouseDeltaX := NWD_MouseX - NWD_MouseStartX
	NWD_MouseDeltaY := NWD_MouseY - NWD_MouseStartY
	If ( (NWD_MouseDeltaX >= 10) or (NWD_MouseDeltaY >= 10) )
	{
		; disabled?
		If ( NWD_ImmediateDownRequest and !NWD_ImmediateDown )
		{
			Click, RIGHT, %NWD_MouseStartX%, %NWD_MouseStartY%, Down
			MouseMove, %NWD_MouseX%, %NWD_MouseY%
			NWD_ImmediateDown = 1
			NWD_PermitClick = 0
		}
		
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
		NWD_Dragging := (NWD_WinClass != "Progman") and (NWD_WinClass != "Shell_TrayWnd") and ((NWD_CtrlState = "D") or ((NWD_WinMinMax != 1) and !NWD_ImmediateDownRequest))
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
				If ( (NWD_WinNewW = NWD_WinW) and (NWD_WinNewH = NWD_WinH) )
				{
					GoSub, NWD_WindowDragingHandler
				}
				Else
				{
					; TODO: replace WinMove for resizing with emulating of user resizing (left click on border and move)
					WinMove, ahk_id %NWD_WinID%, , %NWD_WinNewX%, %NWD_WinNewY%, %NWD_WinNewW%, %NWD_WinNewH%
				}
			}
		}
	}
}
If ( (NWD_LButtonState = "D") and (WindowsDraging = 1) )
{
	GoSub, NWD_WindowDragingHandler
}
Return

NWD_WindowDragingHandler:
WinGetPos, NWD_WinX_Draging, NWD_WinY_Draging, NWD_WinW_Draging, NWD_WinH_Draging, ahk_id %NWD_WinID% ;*[NiftyWindows]
If (NWD_WinH_Draging != NWD_WinH)
	x := NWD_WinX_Draging + NWD_WinW_Draging/2
Else
	x := NWD_WinX + NWD_WinW/2
SysGet, NWD_HeightOfTittleBar, 4
If (NWD_WinY > 0)
	y := NWD_WinY + NWD_HeightOfTittleBar - 1
Else
	y := NWD_HeightOfTittleBar - 1
GetKeyState, NWD_LButtonState, LButton
If (NWD_LButtonState = "U")
	Click, LEFT, %x%, %y%, Down
If ( SYS_ToolTipFeedback and SYS_Debuging )
{
	MouseGetPos, MouseX, MouseY
	WinGetPos, NWD_ToolTipWinX, NWD_ToolTipWinY, NWD_ToolTipWinW, NWD_ToolTipWinH, ahk_id %NWD_WinID%
	SYS_ToolTipText = Window Drag: (X:%NWD_ToolTipWinX%, Y:%NWD_ToolTipWinY%, W:%NWD_ToolTipWinW%, H:%NWD_ToolTipWinH%)`nMouse Position: (X:%MouseX%, Y:%MouseY%)
	SYS_ToolTipSeconds = 1.5
	Gosub, SYS_ToolTipFeedbackShow
}
GoSub, ButtonsHandlerAfterWindowDragging
Return

ButtonsHandlerAfterWindowDragging:
GetKeyState, NWD_LButtonStateP, LButton, P
GetKeyState, NWD_RButtonStateP, RButton, P
GetKeyState, NWD_LButtonState, LButton
GetKeyState, NWD_RButtonState, RButton
If ( (NWD_RButtonStateP = "U") and (NWD_LButtonStateP = "U") )
{
	SetTimer, NWD_WindowHandler, Off
	If (NWD_LButtonState = "D")
		Click, LEFT, Up ;*[NiftyWindows]
	If (NWD_RButtonState = "D")
		Click, RIGHT, Up ;*[NiftyWindows]
	Gosub, NWD_SetAllOff
}
Else
{
	SetTimer, NWD_WindowHandler, -1
}
Return

NWD_WinMove(ID, X, Y, W, H)
{
	WinMove, ahk_id %ID%, , %X%, %Y%, %W%, %H%
	WinGetTitle, WinTitle,  ahk_id %ID%
	Return WinTitle
}
