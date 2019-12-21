CoordMode, Mouse, Screen
BlockInput, MouseMove
Global mouse1
Global mouse2
Global Stage = 1

Gui, Color, 000000
Gui, -Caption +AlwaysOnTop +ToolWindow +LastFound
Gui, show, w30 h30 x0 y0, luuu
WinSet, Region, 0--1 0-16 1-16 5-12 7-12 11-12 11-10, luuu
GuiHandle := WinExist()
Gui, Show

SetFormat, FloatFast, 3.0

AHKHID_UseConstants()
OnMessage(0x00FF, "InputMsg")
AHKHID_Register(1, 2, GuiHandle, RIDEV_INPUTSINK)
Return

LButton::
RButton::
Return

Escape::
GuiClose:
AHKHID_Register(1, 2, 0, RIDEV_REMOVE)
ExitApp

InputMsg(wParam, lParam) {
	Local x, y
	m := AHKHID_GetInputInfo(lParam, 8)
	If (Stage) {
		If (Stage = 1) {
			Mouse1 := m
			Stage = 2
		} Else If (Stage = 2 && m != Mouse1) {
			Mouse2 := m
			Stage = 0
		}
		Return
	}
	
	x := AHKHID_GetInputInfo(lParam, II_MSE_LASTX)
	y := AHKHID_GetInputInfo(lParam, II_MSE_LASTY)
	b := AHKHID_GetInputInfo(lParam, II_MSE_BUTTONFLAGS)
	
	If !(x || y || b)
		Return
	
	If (m = Mouse1) { ; 720953
		MouseMove, %x%, %y%, 0, r
		MouseGetPos, x, y
		Click(x, y, b)
	} Else If (m = Mouse2) { ; 18416789
		Mouse(x, y, b)
	}
	Return
}

Mouse(xo, yo, b=0) {
	Static x, y
	x += xo ;/ 1.75
	y += yo ;/ 1.75
	If (x < 0)
		x := 0
	Else If (x > A_ScreenWidth - 1)
		x := A_ScreenWidth - 1
	If (y < 0)
		y := 0
	Else If (y > A_ScreenHeight - 1)
		y := A_ScreenHeight - 1
	Gui, Show, x%x% y%y% NA
	If b
		Click(x, y, b)
	Return
}

Click(x, y, b=1) {
	hwnd := DllCall("WindowFromPoint", "Int", x - 1, "Int", y - 1)
	WinGetPos, WinX, WinY,,, Ahk_ID %hwnd%
	x -= winx
	y -= winy
	
	If b = 1
	{
		b = left
		d = down
	}
	else if b = 2
	{
		b = left
		d = up
	}
	else if b = 4
	{
		b = right
		d = down
	}
	else if b = 8
	{
		b = right
		d = up
	}
	else if b = 5
	{
		b = left
		d = down
		ControlClick, x%X% y%Y%, Ahk_ID %hwnd%, , %B%, 1, %D%
		b = right
	}
	else if b = 10
	{
		b = left
		d = up
		ControlClick, x%X% y%Y%, Ahk_ID %hwnd%, , %B%, 1, %D%
		b = right
	}
	else
		Return
	
	ControlClick, x%X% y%Y%, Ahk_ID %hwnd%, , %B%, 1, %D%
	Return
}