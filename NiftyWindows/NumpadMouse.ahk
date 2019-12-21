; Using Keyboard Numpad as a Mouse -- by deguix & OkS
; http://www.autohotkey.com
; This script makes mousing with your keyboard almost as easy
; as using a real mouse (maybe even easier for some tasks).
; It supports up to five mouse buttons and the turning of the
; mouse wheel.  It also features customizable movement speed,
; acceleration, and "axis inversion".


#SingleInstance force
#MaxHotkeysPerInterval 500
#NoTrayIcon
#InstallKeybdHook
SetKeyDelay, -1
SetMouseDelay, -1


/*
o------------------------------------------------------------o
|Using Keyboard Numpad as a Mouse                            |
(------------------------------------------------------------)
| By deguix & OkS     / A Script file for AutoHotkey		 		 |
|                    ----------------------------------------|
|                                                            |
|    This script is an example of use of AutoHotkey. It uses |
| the remapping of numpad keys of a keyboard to transform it |
| into a mouse. Some features are the acceleration which     |
| enables you to increase the mouse movement when holding    |
| numpad mouse to "turn". I.e. Numpad2 as Numpad8            |
| and vice-versa. See the list of keys used below:           |
|                                                            |
|------------------------------------------------------------|
| Keys                  | Description                        |
|------------------------------------------------------------|
| 	RShift & NumLock    |Tooggle numpad mouse mode. 				 |
|-----------------------|------------------------------------|
| Numpad0               | Left mouse button click.           |
| Numpad5               | Middle mouse button click.         |
| NumpadDot             | Right mouse button click.          |
| NumpadDiv/NumpadMult  | X1/X2 mouse button click. (Win 2k+)|
| NumpadSub/NumpadAdd   | Moves up/down the mouse wheel.     |
|                       |                                    |
|-----------------------|------------------------------------|
|-----------------------|------------------------------------|
| Numpad1/2/3//4/6/7/8/9| Mouse movement.                    |
|                       |                                    |
|-----------------------|------------------------------------|
|-----------------------|------------------------------------|
| NumpadHome/NumpadEnd  | Inc./dec. acceleration per         |
|                       | button press.                      |
| NumpadUp/NumpadDown   | Inc./dec. initial speed per        |
|                       | button press.                      |
| NumpadPgUp/NumpadPgDn | Inc./dec. maximum speed per        |
|                       | button press.                      |
| ^NumpadHome/^NumpadEnd| Inc./dec. wheel acceleration per   |
|                       | button press*.                     |
| ^NumpadUp/^NumpadDown | Inc./dec. wheel initial speed per  |
|                       | button press*.                     |
| ^NumpadPgUp/          | Inc./dec. wheel maximum speed per  |
| ^NumpadPgDn	         | button press*.                     |
| NumpadLeft/      		  | Inc./dec. rotation angle to        |
| NumpadRight           | right in degrees. (i.e. 180° =     |
|                       | = inversed controls).              |
|------------------------------------------------------------|
| * = These options are affected by the mouse wheel speed    |
| adjusted on Control Panel. If you don't have a mouse with  |
| wheel, the default is 3 +/- lines per option button press. |
o------------------------------------------------------------o
*/

;START OF CONFIG SECTION



; Using the keyboard hook to implement the Numpad hotkeys prevents
; them from interfering with the generation of ANSI characters such
; as à.  This is because AutoHotkey generates such characters
; by holding down ALT and sending a series of Numpad keystrokes.
; Hook hotkeys are smart enough to ignore such keystrokes.

MouseSpeed = 3
MouseAccelerationSpeed = 12
MouseMaxSpeed = 10

;Mouse wheel speed is also set on Control Panel. As that
;will affect the normal mouse behavior, the real speed of
;these three below are times the normal mouse wheel speed.
MouseWheelSpeed = 3
MouseWheelAccelerationSpeed = 10
MouseWheelMaxSpeed = 5

MouseRotationAngle = 0

;END OF CONFIG SECTION

;This is needed or key presses would faulty send their natural
;actions. Like NumpadDiv would send sometimes "/" to the
;screen.       

Temp = 0
Temp2 = 0

MouseRotationAnglePart = %MouseRotationAngle%
;Divide by 45º because MouseMove only supports whole numbers,
;and changing the mouse rotation to a number lesser than 45º
;could make strange movements.
;
;For example: 22.5 when pressing Numpad8:
;  First it would move upwards until the speed
;  to the side reaches 1.
MouseRotationAnglePart /= 45

MouseCurrentAccelerationSpeed = 0
MouseCurrentSpeed = %MouseSpeed%

MouseWheelCurrentAccelerationSpeed = 0
MouseWheelCurrentSpeed = %MouseSpeed%



Hotkey, *Numpad0, ButtonLeftClick
Hotkey, *NumpadIns, ButtonLeftClickIns
Hotkey, *Numpad5, ButtonMiddleClick
Hotkey, *NumpadClear, ButtonMiddleClickClear
Hotkey, *NumpadDot, ButtonRightClick
Hotkey, *NumpadDel, ButtonRightClickDel
Hotkey, *NumpadDiv, ButtonX1Click
Hotkey, *NumpadMult, ButtonX2Click

Hotkey, *NumpadSub, ButtonWheelUp
Hotkey, *NumpadAdd, ButtonWheelDown

Hotkey, *Numpad8, ButtonUp
Hotkey, *Numpad2, ButtonDown
Hotkey, *Numpad4, ButtonLeft
Hotkey, *Numpad6, ButtonRight
Hotkey, *Numpad7, ButtonUpLeft
Hotkey, *Numpad1, ButtonUpRight
Hotkey, *Numpad9, ButtonDownLeft
Hotkey, *Numpad3, ButtonDownRight

Hotkey, NumpadUp, ButtonSpeedUp
Hotkey, NumpadDown, ButtonSpeedDown
Hotkey, NumpadHome, ButtonAccelerationSpeedUp
Hotkey, NumpadEnd, ButtonAccelerationSpeedDown
Hotkey, NumpadPgUp, ButtonMaxSpeedUp
Hotkey, NumpadPgDn, ButtonMaxSpeedDown

Hotkey, NumpadRight, ButtonRotationAngleUp
Hotkey, NumpadLeft, ButtonRotationAngleDown

Hotkey, !NumpadUp, ButtonWheelSpeedUp
Hotkey, !NumpadDown, ButtonWheelSpeedDown
Hotkey, !NumpadHome, ButtonWheelAccelerationSpeedUp
Hotkey, !NumpadEnd, ButtonWheelAccelerationSpeedDown
Hotkey, !NumpadPgUp, ButtonWheelMaxSpeedUp
Hotkey, !NumpadPgDn, ButtonWheelMaxSpeedDown


;Key activation support

NumPadMouseState = 0
Hotkey, *Numpad0, Off
Hotkey, *NumpadIns, Off
Hotkey, *Numpad5, Off
Hotkey, *NumpadDot, Off
Hotkey, *NumpadDel, Off
Hotkey, *NumpadDiv, Off
Hotkey, *NumpadMult, Off

Hotkey, *NumpadSub, Off
Hotkey, *NumpadAdd, Off

Hotkey, *Numpad8, Off
Hotkey, *Numpad2, Off
Hotkey, *Numpad4, Off
Hotkey, *Numpad6, Off
Hotkey, *Numpad7, Off
Hotkey, *Numpad1, Off
Hotkey, *Numpad9, Off
Hotkey, *Numpad3, Off

Hotkey, NumpadUp, Off
Hotkey, NumpadDown, Off
Hotkey, NumpadHome, Off
Hotkey, NumpadEnd, Off
Hotkey, NumpadPgUp, Off
Hotkey, NumpadPgDn, Off

Hotkey, NumpadRight, Off
Hotkey, NumpadLeft, Off

Hotkey, !NumpadUp, Off
Hotkey, !NumpadDown, Off
Hotkey, !NumpadHome, Off
Hotkey, !NumpadEnd, Off
Hotkey, !NumpadPgUp, Off
Hotkey, !NumpadPgDn, Off

RShift & NumLock::
If (NumPadMouseState = 1)
{
	NumPadMouseState = 0
	ToolTip, NumPadMouse: Off
	SetTimer, RemToolTip, 1000
}
Else If (NumPadMouseState = 0)
{
	NumPadMouseState = 1
	ToolTip, NumPadMouse: On
	SetTimer, RemToolTip, 1000
}


If (NumPadMouseState = 1)
{
	Hotkey, *Numpad0, 		On
	Hotkey, *NumpadIns, 	On
	Hotkey, *Numpad5, 		On
	Hotkey, *NumpadDot, 	On
	Hotkey, *NumpadDel, 	On
	Hotkey, *NumpadDiv,		On
	Hotkey, *NumpadMult, 	On

	Hotkey, *NumpadSub, On
	Hotkey, *NumpadAdd, On

	Hotkey, *Numpad8, On
	Hotkey, *Numpad2, On
	Hotkey, *Numpad4, On
	Hotkey, *Numpad6, On
	Hotkey, *Numpad7, On
	Hotkey, *Numpad1, On
	Hotkey, *Numpad9, On
	Hotkey, *Numpad3, On

	Hotkey, NumpadUp, On
	Hotkey, NumpadDown, On
	Hotkey, NumpadHome, On
	Hotkey, NumpadEnd, On
	Hotkey, NumpadPgUp, On
	Hotkey, NumpadPgDn, On

	Hotkey, NumpadRight, On
	Hotkey, NumpadLeft, On

	Hotkey, !NumpadUp, On
	Hotkey, !NumpadDown, On
	Hotkey, !NumpadHome, On
	Hotkey, !NumpadEnd, On
	Hotkey, !NumpadPgUp, On
	Hotkey, !NumpadPgDn, On
}
Else
{
	Hotkey, *Numpad0, Off
	Hotkey, *NumpadIns, Off
	Hotkey, *Numpad5, Off
	Hotkey, *NumpadDot, Off
	Hotkey, *NumpadDel, Off
	Hotkey, *NumpadDiv, Off
	Hotkey, *NumpadMult, Off

	Hotkey, *NumpadSub, Off
	Hotkey, *NumpadAdd, Off

	Hotkey, *Numpad8, Off
	Hotkey, *Numpad2, Off
	Hotkey, *Numpad4, Off
	Hotkey, *Numpad6, Off
	Hotkey, *Numpad7, Off
	Hotkey, *Numpad1, Off
	Hotkey, *Numpad9, Off
	Hotkey, *Numpad3, Off

	Hotkey, NumpadUp, Off
	Hotkey, NumpadDown, Off
	Hotkey, NumpadHome, Off
	Hotkey, NumpadEnd, Off
	Hotkey, NumpadPgUp, Off
	Hotkey, NumpadPgDn, Off

	Hotkey, NumpadRight, Off
	Hotkey, NumpadLeft, Off

	Hotkey, !NumpadUp, Off
	Hotkey, !NumpadDown, Off
	Hotkey, !NumpadHome, Off
	Hotkey, !NumpadEnd, Off
	Hotkey, !NumpadPgUp, Off
	Hotkey, !NumpadPgDn, Off
}
return

;Mouse click support

ButtonLeftClick:
GetKeyState, already_down_state, LButton
If already_down_state = D
	return
Button2 = Numpad0
ButtonClick = Left
Goto ButtonClickStart
ButtonLeftClickIns:
GetKeyState, already_down_state, LButton
If already_down_state = D
	return
Button2 = NumpadIns
ButtonClick = Left
Goto ButtonClickStart

ButtonMiddleClick:
GetKeyState, already_down_state, MButton
If already_down_state = D
	return
Button2 = Numpad5
ButtonClick = Middle
Goto ButtonClickStart
ButtonMiddleClickClear:
GetKeyState, already_down_state, MButton
If already_down_state = D
	return
Button2 = NumpadClear
ButtonClick = Middle
Goto ButtonClickStart

ButtonRightClick:
GetKeyState, already_down_state, RButton
If already_down_state = D
	return
Button2 = NumpadDot
ButtonClick = Right
Goto ButtonClickStart
ButtonRightClickDel:
GetKeyState, already_down_state, RButton
If already_down_state = D
	return
Button2 = NumpadDel
ButtonClick = Right
Goto ButtonClickStart

ButtonX1Click:
GetKeyState, already_down_state, XButton1
If already_down_state = D
	return
Button2 = NumpadDiv
ButtonClick = X1
Goto ButtonClickStart

ButtonX2Click:
GetKeyState, already_down_state, XButton2
If already_down_state = D
	return
Button2 = NumpadMult
ButtonClick = X2
Goto ButtonClickStart

ButtonClickStart:
MouseClick, %ButtonClick%,,, 1, 0, D
SetTimer, ButtonClickEnd, 10
return

ButtonClickEnd:
GetKeyState, kclickstate, %Button2%, P
if kclickstate = D
	return

SetTimer, ButtonClickEnd, Off
MouseClick, %ButtonClick%,,, 1, 0, U
return

;Mouse movement support

ButtonSpeedUp:
MouseSpeed++
ToolTip, Mouse speed: %MouseSpeed% pixels
SetTimer, RemToolTip, 1000
return
ButtonSpeedDown:
If MouseSpeed > 1
	MouseSpeed--
If MouseSpeed = 1
	ToolTip, Mouse speed: %MouseSpeed% pixel
Else
	ToolTip, Mouse speed: %MouseSpeed% pixels
SetTimer, RemToolTip, 1000
return
ButtonAccelerationSpeedUp:
MouseAccelerationSpeed++
ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixels
SetTimer, RemToolTip, 1000
return
ButtonAccelerationSpeedDown:
If MouseAccelerationSpeed > 1
	MouseAccelerationSpeed--
If MouseAccelerationSpeed = 1
	ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixel
Else
	ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixels
SetTimer, RemToolTip, 1000
return

ButtonMaxSpeedUp:
MouseMaxSpeed++
ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixels
SetTimer, RemToolTip, 1000
return
ButtonMaxSpeedDown:
If MouseMaxSpeed > 1
	MouseMaxSpeed--
If MouseMaxSpeed = 1
	ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixel
Else
	ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixels
SetTimer, RemToolTip, 1000
return

ButtonRotationAngleUp:
MouseRotationAnglePart++
If MouseRotationAnglePart >= 8
	MouseRotationAnglePart = 0
MouseRotationAngle = %MouseRotationAnglePart%
MouseRotationAngle *= 45
ToolTip, Mouse rotation angle: %MouseRotationAngle%°
SetTimer, RemToolTip, 1000
return
ButtonRotationAngleDown:
MouseRotationAnglePart--
If MouseRotationAnglePart < 0
	MouseRotationAnglePart = 7
MouseRotationAngle = %MouseRotationAnglePart%
MouseRotationAngle *= 45
ToolTip, Mouse rotation angle: %MouseRotationAngle%°
SetTimer, RemToolTip, 1000
return

ButtonUp:
ButtonDown:
ButtonLeft:
ButtonRight:
ButtonUpLeft:
ButtonUpRight:
ButtonDownLeft:
ButtonDownRight:
If Button <> 0
{
	IfNotInString, A_ThisHotkey, %Button%
	{
		MouseCurrentAccelerationSpeed = 0
		MouseCurrentSpeed = %MouseSpeed%
	}
}
StringReplace, Button, A_ThisHotkey, *

ButtonAccelerationStart:
If MouseAccelerationSpeed >= 1
{
	If MouseMaxSpeed > %MouseCurrentSpeed%
	{
		Temp = 0.001
		Temp *= %MouseAccelerationSpeed%
		MouseCurrentAccelerationSpeed += %Temp%
		MouseCurrentSpeed += %MouseCurrentAccelerationSpeed%
	}
}

;MouseRotationAngle convertion to speed of button direction
{
	MouseCurrentSpeedToDirection = %MouseRotationAngle%
	MouseCurrentSpeedToDirection /= 90.0
	Temp = %MouseCurrentSpeedToDirection%

	if Temp >= 0
	{
		if Temp < 1
		{
			MouseCurrentSpeedToDirection = 1
			MouseCurrentSpeedToDirection -= %Temp%
			Goto EndMouseCurrentSpeedToDirectionCalculation
		}
	}
	if Temp >= 1
	{
		if Temp < 2
		{
			MouseCurrentSpeedToDirection = 0
			Temp -= 1
			MouseCurrentSpeedToDirection -= %Temp%
			Goto EndMouseCurrentSpeedToDirectionCalculation
		}
	}
	if Temp >= 2
	{
		if Temp < 3
		{
			MouseCurrentSpeedToDirection = -1
			Temp -= 2
			MouseCurrentSpeedToDirection += %Temp%
			Goto EndMouseCurrentSpeedToDirectionCalculation
		}
	}
	if Temp >= 3
	{
		if Temp < 4
		{
			MouseCurrentSpeedToDirection = 0
			Temp -= 3
			MouseCurrentSpeedToDirection += %Temp%
			Goto EndMouseCurrentSpeedToDirectionCalculation
		}
	}
}
EndMouseCurrentSpeedToDirectionCalculation:

;MouseRotationAngle convertion to speed of 90 degrees to right
{
	MouseCurrentSpeedToSide = %MouseRotationAngle%
	MouseCurrentSpeedToSide /= 90.0
	Temp = %MouseCurrentSpeedToSide%
	Transform, Temp, mod, %Temp%, 4

	if Temp >= 0
	{
		if Temp < 1
		{
			MouseCurrentSpeedToSide = 0
			MouseCurrentSpeedToSide += %Temp%
			Goto EndMouseCurrentSpeedToSideCalculation
		}
	}
	if Temp >= 1
	{
		if Temp < 2
		{
			MouseCurrentSpeedToSide = 1
			Temp -= 1
			MouseCurrentSpeedToSide -= %Temp%
			Goto EndMouseCurrentSpeedToSideCalculation
		}
	}
	if Temp >= 2
	{
		if Temp < 3
		{
			MouseCurrentSpeedToSide = 0
			Temp -= 2
			MouseCurrentSpeedToSide -= %Temp%
			Goto EndMouseCurrentSpeedToSideCalculation
		}
	}
	if Temp >= 3
	{
		if Temp < 4
		{
			MouseCurrentSpeedToSide = -1
			Temp -= 3
			MouseCurrentSpeedToSide += %Temp%
			Goto EndMouseCurrentSpeedToSideCalculation
		}
	}
}
EndMouseCurrentSpeedToSideCalculation:

MouseCurrentSpeedToDirection *= %MouseCurrentSpeed%
MouseCurrentSpeedToSide *= %MouseCurrentSpeed%

Temp = %MouseRotationAnglePart%
Transform, Temp, Mod, %Temp%, 2

If Button = Numpad8
{
	if Temp = 1
	{
		MouseCurrentSpeedToSide *= 2
		MouseCurrentSpeedToDirection *= 2
	}

	MouseCurrentSpeedToDirection *= -1
	MouseMove, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 0, R
}
Else if Button = Numpad2
{
	if Temp = 1
	{
		MouseCurrentSpeedToSide *= 2
		MouseCurrentSpeedToDirection *= 2
	}

	MouseCurrentSpeedToSide *= -1
	MouseMove, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 0, R
}
Else if Button = Numpad4
{
	if Temp = 1
	{
		MouseCurrentSpeedToSide *= 2
		MouseCurrentSpeedToDirection *= 2
	}

	MouseCurrentSpeedToSide *= -1
	MouseCurrentSpeedToDirection *= -1
	MouseMove, %MouseCurrentSpeedToDirection%, %MouseCurrentSpeedToSide%, 0, R
}
Else if Button = Numpad6
{
	if Temp = 1
	{
		MouseCurrentSpeedToSide *= 2
		MouseCurrentSpeedToDirection *= 2
	}

	MouseMove, %MouseCurrentSpeedToDirection%, %MouseCurrentSpeedToSide%, 0, R
}
Else if Button = Numpad7
{
	Temp = %MouseCurrentSpeedToDirection%
	Temp -= %MouseCurrentSpeedToSide%
	Temp *= -1
	Temp2 = %MouseCurrentSpeedToDirection%
	Temp2 += %MouseCurrentSpeedToSide%
	Temp2 *= -1
	MouseMove, %Temp%, %Temp2%, 0, R
}
Else if Button = Numpad9
{
	Temp = %MouseCurrentSpeedToDirection%
	Temp += %MouseCurrentSpeedToSide%
	Temp2 = %MouseCurrentSpeedToDirection%
	Temp2 -= %MouseCurrentSpeedToSide%
	Temp2 *= -1
	MouseMove, %Temp%, %Temp2%, 0, R
}
Else if Button = Numpad1
{
	Temp = %MouseCurrentSpeedToDirection%
	Temp += %MouseCurrentSpeedToSide%
	Temp *= -1
	Temp2 = %MouseCurrentSpeedToDirection%
	Temp2 -= %MouseCurrentSpeedToSide%
	MouseMove, %Temp%, %Temp2%, 0, R
}
Else if Button = Numpad3
{
	Temp = %MouseCurrentSpeedToDirection%
	Temp -= %MouseCurrentSpeedToSide%
	Temp2 *= -1
	Temp2 = %MouseCurrentSpeedToDirection%
	Temp2 += %MouseCurrentSpeedToSide%
	MouseMove, %Temp%, %Temp2%, 0, R
}

SetTimer, ButtonAccelerationEnd, 10
return

ButtonAccelerationEnd:
GetKeyState, kstate, %Button%, P
if kstate = D
	Goto ButtonAccelerationStart

SetTimer, ButtonAccelerationEnd, Off
MouseCurrentAccelerationSpeed = 0
MouseCurrentSpeed = %MouseSpeed%
Button = 0
return

;Mouse wheel movement support

ButtonWheelSpeedUp:
MouseWheelSpeed++
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
MouseWheelSpeedReal = %MouseWheelSpeed%
MouseWheelSpeedReal *= %MouseWheelSpeedMultiplier%
ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% lines
SetTimer, RemToolTip, 1000
return
ButtonWheelSpeedDown:
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
If MouseWheelSpeedReal > %MouseWheelSpeedMultiplier%
{
	MouseWheelSpeed--
	MouseWheelSpeedReal = %MouseWheelSpeed%
	MouseWheelSpeedReal *= %MouseWheelSpeedMultiplier%
}
If MouseWheelSpeedReal = 1
	ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% line
Else
	ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% lines
SetTimer, RemToolTip, 1000
return

ButtonWheelAccelerationSpeedUp:
MouseWheelAccelerationSpeed++
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
MouseWheelAccelerationSpeedReal = %MouseWheelAccelerationSpeed%
MouseWheelAccelerationSpeedReal *= %MouseWheelSpeedMultiplier%
ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% lines
SetTimer, RemToolTip, 1000
return
ButtonWheelAccelerationSpeedDown:
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
If MouseWheelAccelerationSpeed > 1
{
	MouseWheelAccelerationSpeed--
	MouseWheelAccelerationSpeedReal = %MouseWheelAccelerationSpeed%
	MouseWheelAccelerationSpeedReal *= %MouseWheelSpeedMultiplier%
}
If MouseWheelAccelerationSpeedReal = 1
	ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% line
Else
	ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% lines
SetTimer, RemToolTip, 1000
return

ButtonWheelMaxSpeedUp:
MouseWheelMaxSpeed++
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
MouseWheelMaxSpeedReal = %MouseWheelMaxSpeed%
MouseWheelMaxSpeedReal *= %MouseWheelSpeedMultiplier%
ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% lines
SetTimer, RemToolTip, 1000
return
ButtonWheelMaxSpeedDown:
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
If MouseWheelMaxSpeed > 1
{
	MouseWheelMaxSpeed--
	MouseWheelMaxSpeedReal = %MouseWheelMaxSpeed%
	MouseWheelMaxSpeedReal *= %MouseWheelSpeedMultiplier%
}
If MouseWheelMaxSpeedReal = 1
	ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% line
Else
	ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% lines
SetTimer, RemToolTip, 1000
return

ButtonWheelUp:
ButtonWheelDown:

If Button <> 0
{
	If Button <> %A_ThisHotkey%
	{
		MouseWheelCurrentAccelerationSpeed = 0
		MouseWheelCurrentSpeed = %MouseWheelSpeed%
	}
}
StringReplace, Button, A_ThisHotkey, *

ButtonWheelAccelerationStart:
If MouseWheelAccelerationSpeed >= 1
{
	If MouseWheelMaxSpeed > %MouseWheelCurrentSpeed%
	{
		Temp = 0.001
		Temp *= %MouseWheelAccelerationSpeed%
		MouseWheelCurrentAccelerationSpeed += %Temp%
		MouseWheelCurrentSpeed += %MouseWheelCurrentAccelerationSpeed%
	}
}

If Button = NumpadSub
	MouseClick, WheelUp,,, %MouseWheelCurrentSpeed%, 0, D
Else if Button = NumpadAdd
	MouseClick, WheelDown,,, %MouseWheelCurrentSpeed%, 0, D

SetTimer, ButtonWheelAccelerationEnd, 100
return

ButtonWheelAccelerationEnd:
GetKeyState, kstate, %Button%, P
if kstate = D
	Goto ButtonWheelAccelerationStart

MouseWheelCurrentAccelerationSpeed = 0
MouseWheelCurrentSpeed = %MouseWheelSpeed%
Button = 0
return

RemToolTip:
SetTimer, RemToolTip, Off
ToolTip
return
