#SingleInstance force
#NoTrayIcon
#NoEnv
SetBatchLines -1
ListLines Off

#include D:\Programs\AutoHotkey\MyLib\Other\BrightnessSetter.ahk ;
; #include D:\Programs\AutoHotkey\MyLib\Other\Clipboard\Deluxe Clipboard.ahk


$Insert:: Suspend	; make the Insert key toggle all hotkeys.



!#u:: 	Run, "D:\Programs\AutoHotkey\MyLib\My_HotKeys.ahk"		; rerun this script

!c::	Run, "C:\Windows\System32\calc.exe"	; Alt+C to run Calc
	
!n::	Run, "D:\Programs\Notepad++\notepad++.exe"	; Alt+N to launch or switch to Notepad++

#c::	Run, "D:\Programs\sMath Studio\SMathStudio_Desktop.exe"	; Win+C to launch SMath

#Del::FileRecycleEmpty ; win + del ; Empty trash

!d:: Run "C:\Users\OkS\Downloads" ; Open Downloads folder

!#m:: Run "%windir%\system32\magnify.exe"	; launch default ScreenMagnifier

^!m:: Run "D:\Programs\AutoHotkey\MyLib\Other\ScreenMagnifier.ahk"	; launch ScreenMagnifier

#If GetKeyState("NumLock", "T") ; True if NumLock is ON, false otherwise.
{
	F1:: 		^x
	F2:: 		^c
	F3:: 		^v
	F4:: 		^a
	F4 & F5:: 	BS.SetBrightness(-1)
	F4 & F6:: 	BS.SetBrightness(1)
	F5:: 		BS.SetBrightness(-10)
	F6:: 		BS.SetBrightness(10)
	F7:: 		^z
	F8:: 		^y
	
	CapsLock::  Send, {LAlt down}{Tab}{LAlt up}
	
	$#NumpadAdd::Send {Volume_Up 50} ; Win+NumpadAdd increase sound level
	$#NumpadSub::Send {Volume_Down 50} ; Win+NumpadSub decrease sound level
	$+NumpadAdd::Send {Volume_Up 5} ; Shift+Numpad	Add increase sound level
	$+NumpadSub::Send {Volume_Down 5} ; Shift+NumpadSub decrease sound level
	
	^Numpad1:: 
	{
		WinGetClass, ActiveWindow, A
		Send ^c
		RunWait "D:\Google Drive\Code\Python\My collection\fix text from another language\English to Ukrainian.pyw"
		WinActivate, ahk_class %ActiveWindow%
		Send ^v	
	}
	Return

	^Numpad2:: 
	{
		WinGetClass, ActiveWindow, A
		Send ^c	
		RunWait "D:\Google Drive\Code\Python\My collection\fix text from another language\Ukrainian to English.pyw"
		WinActivate, ahk_class %ActiveWindow%
		Send ^v
	}
	Return
}

^+!t::Run https://translate.google.com/?source=gtx#view=home&op=translate&sl=auto&tl=uk&text=%clipboard%

>^Down::Send {PgDn}
>^Up::Send {PgUp}
>^Left::Send {Home}
>^Right::Send {End}
>+Down::Send {Volume_Down 1}
>+Up::Send {Volume_Up 1}
>+Left::Send {XButton1}
>+Right::Send {XButton2}

^+!c::
MouseGetPos,x,y
PixelGetColor,rgb,x,y,RGB
StringTrimLeft,rgb,rgb,2
Clipboard=%rgb%
Return

	; Alt+W to launch or switch to Chrome
$!w::
if WinExist("ahk_exe chrome.exe") 
	WinActivate, ahk_exe chrome.exe
else
	Run "C:\Users\OkS\Desktop\Google Chrome.lnk"


	; Press middle mouse button to move up a folder in Explorer
#IfWinActive ahk_exe explorer.exe
`::Send !{Up}
~MButton::Send !{Up}
#IfWinActive
return

; Google Search highlighted text
^+c::
{
 Send, ^c
 Sleep 50
 Run, http://www.google.com/search?q=%clipboard%
 Return
}

#IfWinActive ahk_class ConsoleWindowClass
^V::
SendInput {Raw}%clipboard%
return
#IfWinActive

; WINDOWS KEY + H TOGGLES HIDDEN FILES
#h::
RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
If HiddenFiles_Status = 2 
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
Else 
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
WinGetClass, eh_Class,A
If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
send, {F5}
Else PostMessage, 0x111, 28931,,, A
Return

; WINDOWS KEY + Y TOGGLES FILE EXTENSIONS
#y::
RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
If HiddenFiles_Status = 1 
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
Else 
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
WinGetClass, eh_Class,A
If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
send, {F5}
Else PostMessage, 0x111, 28931,,, A
Return

~LAlt & WheelUp::  ; Scroll left.
ControlGetFocus, fcontrol, A
Loop 2  ; <-- Increase this value to scroll faster.
    SendMessage, 0x114, 0, 0, %fcontrol%, A  ; 0x114 is WM_HSCROLL and the 0 after it is SB_LINELEFT.
return

~LAlt & WheelDown::  ; Scroll right.
ControlGetFocus, fcontrol, A
Loop 2  ; <-- Increase this value to scroll faster.
    SendMessage, 0x114, 1, 0, %fcontrol%, A  ; 0x114 is WM_HSCROLL and the 1 after it is SB_LINERIGHT.
return
