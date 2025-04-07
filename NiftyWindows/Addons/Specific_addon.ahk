; here placed some path/process specific binds that require editing when moving to another system/computer

;^!m:: 				Run, "B:\Programs\AutoHotkey\MyLib\Other\ScreenMagnifier.ahk"					; launch ScreenMagnifier

#b::					Run PowerShell.exe -windowstyle hidden -command D:\Scripts\bluetooth.ps1			; special script by this path
#[:: 				Run, "C:\Windows\System32\DisplaySwitch.exe" /internal
#]:: 				Run, "C:\Windows\System32\DisplaySwitch.exe" /extend
!#j::
Suspend, Permit
{
	Run, "S:\Programs\AutoHotkey\AHK-Studio-master\AHK-Studio.ahk"				; launch AHK-Studio
}
Return

#!+Home::
Suspend, Permit
{
	CS2_WinProcessName := "cs2.exe"
	WinActivate, ahk_exe %CS2_WinProcessName%
	; Send, {LWin down}{LShift down}{LEFT}{LWin up}{LShift up}
	WinMove, ahk_exe %CS2_WinProcessName%, , 0, 0
	WinMinimize, ahk_exe %CS2_WinProcessName%
	; Sleep, 1000
	WinMaximize, ahk_exe %CS2_WinProcessName%
}
Return

#!+End::
Suspend, Permit
{
	CS2_WinProcessName := "cs2.exe"
	WinActivate, ahk_exe %CS2_WinProcessName%
	WinMaximize, ahk_exe %CS2_WinProcessName%
}
Return

#IfWinActive, Genshin
{
	; w::w 				; move forward
	; s::s 				; move backward
	; a::a 				; move left
	; d::d 				; move right

	g::					; party setup
	Suspend, Permit
	{
		Send, {l down}{l up}
	}
	Return
	x::					; switch walk run
	Suspend, Permit
	{
		Send, {LControl down}{LControl up}
	}
	Return
	t::					; party setup
	Suspend, Permit
	{
		Send, {l down}{l up}
	}
	Return
	;LShift::LShift 	; sprint
	;Space::Space 		; jump

	; LButton::LButton 	; normal attack bugs sometimes out of genshin with holding left button on mouse
	XButton1::			; switch aiming mode
	Suspend, Permit
	{
		Send, {r down}{r up}
	}
	Return	
	; MButton::MButton 	; elemental sight
	; e::e 				; elemental skill
	; q::q 				; elemental burst

	; f::f 				; pickup/interact	
	XButton2::			; pickup/interact
	Suspend, Permit
	{
		While (Getkeystate("XButton2","P")) 
		{
			Send, {f down}{f up}
			Sleep 100
		}
	}
	Return

	; 1::1 				; switch to party member 1
	; 2::2 				; switch to party member 2
	; 3::3 				; switch to party member 3
	; 4::4 				; switch to party member 4
	; 5::5 				; switch to party member 5

	; b::b 				; open inventory
	; c::c 				; open character screen
	; m::m 				; open map
	; j::j 				; open quest menu
	; v::v 				; quest navigation

	; Esc::Esc 			; open paimon menu
	; Enter::Enter 		; open chat screen

	; y::y 				; open notification details
	; u::u 				; open domain screen
	; g::g 				; check tutorial details

	; F1::F1 			; open adventurer handbook screen
	; F2::F2 			; open coop screen
	; F3::F3 			; open wish screen
	; F4::F4 			; open battle pass screen
	; F5::F5 			; open the events menu

	; Tab::Tab 			; tab menu if you swap tab you cant alt tab

	RButton:: 			; combo
	Suspend, Permit
	{
		GetKeyState, NWD_RButtonStateP, RButton, P
		RButtonPressingCooldownTime = 250
		RButtonPressedStartTime := A_TickCount
		While (Getkeystate("RButton","P")) 
		{
			If (A_TickCount - RButtonPressedStartTime > RButtonPressingCooldownTime)
			{
				Click, LEFT, Down	; attack
				Click, LEFT, Up		; attack
				Sleep 100
			}
		}
		RButtonUnPressedElapsedTime := A_TickCount
		If ( RButtonUnPressedElapsedTime - RButtonPressedStartTime  < RButtonPressingCooldownTime )
		{
			Send, {x down}{x up}	; drop
			Click, RIGHT, Down		; sprint
			Click, RIGHT, Up		; sprint
		}
	}
	Return
}