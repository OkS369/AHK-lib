#SingleInstance force

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

RemoveToolTip:
	ToolTip

Uk_U2 	:= "0xF0C20422"
Uk_Ex 	:= "0xF0A80422"
Ru_Uk 	:= "0x4192000"
Ru 	  	:= "0x4190419"
En_ExLa := "0xF0C10409"
En_US 	:= "0x04090409"


>^CapsLock::
{
	l := GetKeyboardLanguage()
	MsgBox %l%
}
Return


CapsLock::
L := GetKeyboardLanguage()
If (L = 0xF0C10409)
{
    ;SetDefaultKeyboard(Uk_U2)
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
	;SetDefaultKeyboard(En_ExLa)
	PostMessage, 0x50, 0, 0xF0C10409,, A
	SYS_ToolTipText = English
	SYS_ToolTipMiliSeconds = 500
	MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
	SYS_ToolTipX += 16
	SYS_ToolTipY += 4
	ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
	SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
}
Return

