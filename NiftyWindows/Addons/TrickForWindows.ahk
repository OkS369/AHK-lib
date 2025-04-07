HideShowTaskbar(action) {
	static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
	VarSetCapacity(APPBARDATA, size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
	NumPut(size, APPBARDATA), NumPut(WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
	NumPut(action ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
	DllCall("Shell32\SHAppBarMessage", UInt, ABM_SETSTATE, Ptr, &APPBARDATA)
}

SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
	{
		static AndMask, XorMask, $, h_cursor
,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
, b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
, h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
	if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
	{
		$ := "h"                                       ; active default cursors
		VarSetCapacity( h_cursor,4444, 1 )
		VarSetCapacity( AndMask, 32*4, 0xFF )
		VarSetCapacity( XorMask, 32*4, 0 )
		system_cursors := "32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650"
		StringSplit c, system_cursors, `,
		Loop %c0%
		{
			h_cursor   := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
			h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
			b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0
 , "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
		}
	}
	if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
		$ := "b"  ; use blank cursors
	else
		$ := "h"  ; use the saved cursors
	
	Loop %c0%
	{
		h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
		DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
	}
}

ToggleHiddenFilesInExplorer()
{
RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
If HiddenFiles_Status = 2 
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
Else   
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
WinGetClass, eh_Class,A
If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
	Send, {F5}
Else PostMessage, 0x111, 28931,,, A
	Send, {F5}
}

TogglesFileExtensionsInExplorer()
{
RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
If HiddenFiles_Status = 1 
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
Else 
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
WinGetClass, eh_Class,A
If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
	send, {F5}
Else PostMessage, 0x111, 28931,,, A
	send, {F5}
}

FitColumnsSizeInExplorer()
{
	Send, ^{NumpadAdd}
}

GetActiveExplorerPath()
{
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd)
	{
		for window in ComObjCreate("Shell.Application").Windows
		{
			if (window.hwnd==explorerHwnd)
			{
				return window.Document.Folder.Self.Path
			}
		}
	}
}



KillProcessByPID(PID)
{
	Process, Close, PID
}

SuspendProcessByPID(PID)
{
	Run cmd /c pssuspend %PID% ;Send pssuspend %PID% -nobanner
}


UnSuspendProcessByPID(PID)
{
	Loop, 2
	{
		Run cmd /c pssuspend -r %PID%
	}
}

ToggleIconsOnDesktop()
{
	/*
	RegRead, HideIcons, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideIcons
	HideIcons := !HideIcons
	If (HideIcons = 1)
		FileSetAttrib, -H, %A_Desktop%\*.*, 1
	Else
		FileSetAttrib, +H, %A_Desktop%\*.*, 1
	RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideIcons, %HideIcons%
	SendMessage, 0x1A,,,, Program Manager
	Return HideIcons
	*/
	RegRead, HideIcons, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideIcons
	HideIcons := !HideIcons
	If (HideIcons = 1)
		WinHide,Program Manager
	Else
		WinShow,Program Manager
	Return HideIcons
}

GetTaskbarVisibleWindows(limit:=0, checkDisabled:=True, checkEmptyTitle:=False
					   ,compareLastActivePopupToOwner:=False, checkNoActivate:=True
					   ,checkImmediateOwnerVisibility:=True, checkITaskListDeleted:=True)
{
	static sevenOrBelow := A_OSVersion ~= "WIN_(7|XP|VISTA)", rect, PropEnumProcEx := 0, cleanup := {base: {__Delete: "GetTaskbarVisibleWindows"}}
	static WS_DISABLED := 0x08000000, WS_EX_TOOLWINDOW := 0x00000080, WS_EX_APPWINDOW := 0x00040000, WS_EX_CONTROLPARENT := 0x00010000, WS_EX_NOREDIRECTIONBITMAP := 0x00200000, WS_EX_NOACTIVATE := 0x08000000
	static GA_ROOTOWNER := 3, GW_OWNER := 4, DWMWA_CLOAKED := 14

	if (!cleanup) {
		if (PropEnumProcEx)
			DllCall("GlobalFree", "Ptr", PropEnumProcEx, "Ptr"), PropEnumProcEx := 0
		return
	}

	if (PropEnumProcEx && A_EventInfo == PropEnumProcEx && compareLastActivePopupToOwner >= 4096 && DllCall("IsWindow", "Ptr", limit)) {
		if (checkDisabled && StrGet(checkDisabled) == "ApplicationViewCloakType") {
			NumPut(checkEmptyTitle != 1, compareLastActivePopupToOwner+0, "Int")
			return False
		}
		return True
	}

	if (!VarSetCapacity(rect)) {
		VarSetCapacity(rect, 16)
		if (!sevenOrBelow)
			PropEnumProcEx := RegisterCallback(A_ThisFunc, "Fast", 4)
	}

	shell := 0 ; DllCall("GetShellWindow", "Ptr")

	ret := []
	prevDetectHiddenWindows := A_DetectHiddenWindows

	DetectHiddenWindows Off

	WinGet id, list,,, Program Manager
	Loop %id% {
		hwnd := id%A_Index%

		if (limit && limit == ret.MaxIndex())
			break

		if (checkEmptyTitle) {
			WinGetTitle wndTitle, ahk_id %hwnd%
			if (!wndTitle)
				continue
		}

		if (checkDisabled) {
			WinGet dwStyle, Style, ahk_id %hwnd%
			if (dwStyle & WS_DISABLED)
				continue
		}

		if (checkITaskListDeleted && DllCall("GetProp", "Ptr", hwnd, "Str", "ITaskList_Deleted", "Ptr"))
			continue 

		if (DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", &rect) && !DllCall("IsRectEmpty", "Ptr", &rect)) {
			if (!shell) {
				hwndRootOwner := DllCall("GetAncestor", "Ptr", hwnd, "UInt", GA_ROOTOWNER, "Ptr")
			} else {
				hwndTmp := hwnd
				Loop {
					hwndRootOwner := hwndTmp
					hwndTmp := DllCall("GetWindow", "Ptr", hwndTmp, "UInt", GW_OWNER, "Ptr")
				} until (!hwndTmp || hwndTmp == shell)
			}

			if (compareLastActivePopupToOwner)
				if (DllCall("GetLastActivePopup", "Ptr", hwndRootOwner, "Ptr") != hwnd) ; https://autohotkey.com/boards/viewtopic.php?t=13288
					continue

			WinGet dwStyleEx, ExStyle, ahk_id %hwndRootOwner%
			if (hwnd != hwndRootOwner)
				WinGet dwStyleEx2, ExStyle, ahk_id %hwnd%
			else
				dwStyleEx2 := dwStyleEx

			hasAppWindow := dwStyleEx2 & WS_EX_APPWINDOW
			if ((checkNoActivate) && ((dwStyleEx2 & WS_EX_NOACTIVATE) && !hasAppWindow))
				continue

			if (checkImmediateOwnerVisibility) {
				hwndOwner := DllCall("GetWindow", "Ptr", hwnd, "UInt", GW_OWNER, "Ptr")
				if (!(!hwndOwner || !DllCall("IsWindowVisible", "Ptr", hwndRootOwner)))
					continue
			}				

			if (!(dwStyleEx & WS_EX_TOOLWINDOW) || hasAppWindow || (!(dwStyleEx2 & WS_EX_TOOLWINDOW) && dwStyleEx2 & WS_EX_CONTROLPARENT)) {
				if (!sevenOrBelow) {
					WinGetClass wndClass, ahk_id %hwnd%
					if (wndClass == "Windows.UI.Core.CoreWindow")
						continue
					if (wndClass == "ApplicationFrameWindow") {
						hasAppropriateApplicationViewCloakType := !PropEnumProcEx
						if (PropEnumProcEx)
							DllCall("EnumPropsEx", "Ptr", hwnd, "Ptr", PropEnumProcEx, "Ptr", &hasAppropriateApplicationViewCloakType)
						if (!hasAppropriateApplicationViewCloakType)
							continue
					} else {
						if (dwStyleEx & WS_EX_NOREDIRECTIONBITMAP) 
							continue
						if (!DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwndRootOwner, "UInt", DWMWA_CLOAKED, "UInt*", isCloaked, "Ptr", 4) && isCloaked)
							continue
					}
				}
				ret.push(hwnd)
			}
		}
	}
	
	DetectHiddenWindows %prevDetectHiddenWindows%
	return ret
}
