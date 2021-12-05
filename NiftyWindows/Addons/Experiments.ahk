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
	
	Uk_U2 	:= 0xF0C20422
	Uk_Ex 	:= 0xF0A80422
	Ru_Uk 	:= 0x4192000
	Ru 	  	:= 0x4190419
	En_ExLa 	:= 0xF0C10409
	En_US 	:= 0x04090409
	En_Co	:= 0xF0CE0409
	
	>^CapsLock::
	{
		l := GetKeyboardLanguage()
		MsgBox %l%`n`nUk_U2 := 0xF0Cx0422`nUk_Ex := 0xF0A80422`nRu_Uk:= 0x4192000`nRu:= 0x4190419`nEn_ExLa:= 0xF0C10409`nEn_US:= 0x04090409
		En_Co	:= 0xF0CE0409
	}
	Return
	
	/*
		LanguageChanger:
		L := GetKeyboardLanguage()
		L0 := L
		If (L = 0xF0C10409)
		{
			Aim = 0xF0C50422
			PostMessage, 0x50, 0, 0xF0C20422,, %WinID%
			L := GetKeyboardLanguage()
			if (L = 0xF0C20422)
				MsgBox YES!!!
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
			Aim = 0xF0C10409
			PostMessage, 0x50, 0, 0xF0C10409,, A
			SYS_ToolTipText = English
			SYS_ToolTipMiliSeconds = 500
			MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
			SYS_ToolTipX += 16
			SYS_ToolTipY += 4
			ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
			SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
		}
		L := GetKeyboardLanguage()
		If ( L = Aim )
			Return
		Else
		{
			Gosub, LanguageChangerStandart
			L := GetKeyboardLanguage()
			If ( L = Aim )
				Return
			Else If (L0 = L)
		;MsgBox L: %L%`nA: %Aim%
				SYS_ToolTipText = L: %L%`nA: %Aim%
			SYS_ToolTipMiliSeconds = 500
			MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
			SYS_ToolTipX += 16
			SYS_ToolTipY += 4
			ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
			SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
		}
		Return
		
		
;~LCtrl & ~LShift:: 		Gosub, LanguageChangerStandart
		~LShift & ~LCtrl:: 		Gosub, LanguageChangerStandart
		
		LanguageChangerNew:
		Gosub, RemoveToolTip
		WinGet, active_id, ID, A
		Send, {LShift down}{LCtrl}{LShift up}
		ControlFocus, , %active_id%
		Sleep, 100
		L := GetKeyboardLanguage()
		If (L = 0xF0C10409)
			SYS_ToolTipText = English Extended Latin
		Else If (L = 0xF0C50422)
			SYS_ToolTipText = Ukrainian Unicode
		Else If (L = 0x4190419)
			SYS_ToolTipText = Russian
		Else
			SYS_ToolTipText = Unknown language
		SYS_ToolTipMiliSeconds = 500
		MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
		SYS_ToolTipX += 16
		SYS_ToolTipY += 4
		ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
		SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
		Return
		
		LanguageChangerStandart:
		Gosub, RemoveToolTip
		WinGet, active_id, ID, A
		ControlFocus, , %active_id%
		Sleep, 100
		L := GetKeyboardLanguage()
		If (L = 0xF0C10409)
			SYS_ToolTipText = Ukrainian Unicode
		Else If (L = 0xF0C50422)
			SYS_ToolTipText = English Extended Latin
		Else
			SYS_ToolTipText = Another language
		SYS_ToolTipMiliSeconds = 500
		MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
		SYS_ToolTipX += 16
		SYS_ToolTipY += 4
		ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
		SetTimer, RemoveToolTip, %SYS_ToolTipMiliSeconds%
;Send, {LShift down}{LCtrl}{LShift up}
		Return
*/
