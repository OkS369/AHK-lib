#Persistent
Menu, Tray, Icon, C`:\Windows\explorer.exe, 4

SetTitleMatchMode, 2
hwnd := WinExist("ahk_class WorkerW")

SetTimer, Hidecheck, 10

OnExit, ShowIconsAndCursor  ; Ensure the icons cursor are made visible when the script exits.

;Initally fade out - otherwise it seems to do this weird blinking thing before it stabilizes
{
    hwnd := WinExist("ahk_class WorkerW")
   WinGet, Trans, Transparent, ahk_id %Window%
   If Not Trans {
      WinSet, Transparent, 0, ahk_id %Window%
      Return
   }
   Loop 15
   {
      WinSet, Transparent, % 255 - A_Index * 17, ahk_id %Window%
      Sleep %Speed%
   }
Return
}

Hidecheck:
{
    {
    If WinActive("ahk_class WorkerW") AND (A_TimeIdlePhysical > 2000) {
    GoSub, FadeHideIconsAndCursor
    }
    else
    {
    If WinActive("ahk_class WorkerW") AND (A_TimeIdlePhysical < 2000) {
    GoSub, FadeShowIconsAndCursor
    }
    else
    {
    If NOT WinActive("ahk_class WorkerW") AND (A_TimeIdlePhysical > 2000) {
    GoSub, HideCursor
    }
    else
    {
    If NOT WinActive("ahk_class WorkerW") AND (A_TimeIdlePhysical < 2000) {
    GoSub, FadeHideIconsShowCursor
    }
}
}
}
}
}
Return


FadeIn(Window, Speed="1")
{
    hwnd := WinExist("ahk_class WorkerW")
   DetectHiddenWindows, On
      WinGet, Trans, Transparent, ahk_id %Window%
         If Trans {
   WinSet, Transparent, 255, ahk_id %Window%
   Return
}
   Loop 15
   {
      WinSet, Transparent, % A_Index * 17, ahk_id %Window%
      Sleep %Speed%
   }
Return
}


FadeOut(Window, Speed="1")
{
    hwnd := WinExist("ahk_class WorkerW")
    
   WinGet, Trans, Transparent, ahk_id %Window%
   If Not Trans {
      WinSet, Transparent, 0, ahk_id %Window%
      Return
   }
   Loop 15
   {
      WinSet, Transparent, % 255 - A_Index * 17, ahk_id %Window%
      Sleep %Speed%
   }
Return
}

   
   
FadeShowIconsAndCursor:
{
    SystemCursor("On")
    FadeIn(hwnd, 1)
}
Return


FadeHideIconsAndCursor:
{
    SystemCursor("Off")
    FadeOut(hwnd, 1)
}
Return


FadeHideIconsShowCursor:
{
    SystemCursor("On")
    FadeOut(hwnd, 1)
}
Return


HideCursor:
{
    SystemCursor("Off")
}
Return


ShowIconsAndCursor:
{
    SystemCursor("On")
        FadeIn(hwnd, 1)
   ExitApp
}
Return


SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{
    static AndMask, XorMask, $, h_cursor
        ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
    if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
    {
        $ = h                                          ; active default cursors
        VarSetCapacity( h_cursor,4444, 1 )
        VarSetCapacity( AndMask, 32*4, 0xFF )
        VarSetCapacity( XorMask, 32*4, 0 )
        system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
        StringSplit c, system_cursors, `,
        Loop %c0%
        {
            h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
            h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
            b%A_Index% := DllCall("CreateCursor","uint",0, "int",0, "int",0
                , "int",32, "int",32, "uint",&AndMask, "uint",&XorMask )
        }
    }
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
        $ = b  ; use blank cursors
    else
        $ = h  ; use the saved cursors

    Loop %c0%
    {
        h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
        DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
    }
}
Return