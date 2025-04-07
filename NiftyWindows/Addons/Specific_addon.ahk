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
