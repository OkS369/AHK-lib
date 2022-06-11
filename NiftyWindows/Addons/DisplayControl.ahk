ChangeOrientation(device, degrees) {
	
	Run, %A_ScriptDir%\Addons\Software\Display\display64.exe /device %device% -rotate %degrees%
}

GetMonitorIndexFromWindow(windowHandle)
{
	; Starts with 1.
	monitorIndex := 1
	
	VarSetCapacity(monitorInfo, 40)
	NumPut(40, monitorInfo)
	
	if (monitorHandle := DllCall("MonitorFromWindow", "uint", windowHandle, "uint", 0x2)) 
		&& DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) 
	{
		monitorLeft   := NumGet(monitorInfo,  4, "Int")
		monitorTop    := NumGet(monitorInfo,  8, "Int")
		monitorRight  := NumGet(monitorInfo, 12, "Int")
		monitorBottom := NumGet(monitorInfo, 16, "Int")
		workLeft      := NumGet(monitorInfo, 20, "Int")
		workTop       := NumGet(monitorInfo, 24, "Int")
		workRight     := NumGet(monitorInfo, 28, "Int")
		workBottom    := NumGet(monitorInfo, 32, "Int")
		isPrimary     := NumGet(monitorInfo, 36, "Int") & 1
		
		SysGet, monitorCount, MonitorCount
		
		Loop, %monitorCount%
		{
			SysGet, tempMon, Monitor, %A_Index%
			
			; Compare location to determine the monitor index.
			if ((monitorLeft = tempMonLeft) and (monitorTop = tempMonTop)
				and (monitorRight = tempMonRight) and (monitorBottom = tempMonBottom))
			{
				monitorIndex := A_Index
				break
			}
		}
	}
	
	return monitorIndex
}

<^>!#Up:: ; Landscape Mode
monitor := GetMonitorIndexFromWindow(WinExist("A"))
ChangeOrientation(monitor, 0)
return

<^>!#Right:: ; Portrait Mode
monitor := GetMonitorIndexFromWindow(WinExist("A"))
ChangeOrientation(monitor, 90)
return

<^>!#Down:: ; Landscape Mode (Flipped)
monitor := GetMonitorIndexFromWindow(WinExist("A"))
ChangeOrientation(monitor, 180)
return

<^>!#Left:: ; Landscape Mode (Flipped)
monitor := GetMonitorIndexFromWindow(WinExist("A"))
ChangeOrientation(monitor, 270)