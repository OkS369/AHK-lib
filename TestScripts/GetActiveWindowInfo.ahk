1::
{
WinGet, WinStyle, Style, A
WinGet, WinEXStyle, EXStyle, A
WinGet, WinID, ID, A
WinGet, WinPID, PID, A
WinGet, WinProcessName, ProcessName, A
WinGet, WinMinMax, MinMax, A
WinGetClass, WinClass, A

MsgBox, ,, ProcessName:`n`t`t`t%WinProcessName%`nWinClass:`n`t`t`t%WinClass%`nID:`n`t`t`t%WinID%`nPID:`n`t`t`t%WinPID%`nMinMax:`n`t`t`t%WinMinMax%`nStyle:`n`t`t`t%WinStyle%`nEXStyle:`n`t`t`t%WinEXStyle%,10000
}
#SingleInstance force