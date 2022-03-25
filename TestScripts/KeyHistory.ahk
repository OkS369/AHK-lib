#Persistent
#InstallMouseHook
#InstallKeybdHook
#KeyHistory 50
While !(getKeyState("F4", "T"))
{
	KeyHistory
	Sleep, 500
}
Return
Esc::ExitApp