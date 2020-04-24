SuspendProcess(PID)
{
	Run cmd /c pssuspend %PID% ;Send pssuspend %PID% -nobanner
}

UnSuspendProcess(PID)
{
	Loop, 3
	{
		Run cmd /c pssuspend -r %PID%
	}
}

^F11::
^+F11::
{	
	
	IfInString, A_ThisHotkey, +
	{
		
		If ArrayOfSuspendedProcess.Length() != 0
		{
			PID_of_process := ArrayOfSuspendedProcess.Pop()
			MsgBox, %PID_of_process%
			UnSuspendProcess(PID_of_process)
		}
	}
	Else
	{
		WinGet, PID_of_process, PID, A
		WinGet, Path_of_process, ProcessPath, ahk_pid %PID_of_process%
		MsgBox, 1, Suspend this process?,Path: %Path_of_process%  PID: %PID_of_process%, 10
		IfMsgBox Ok
		{
			If !ArrayOfSuspendedProcess.Length()
				ArrayOfSuspendedProcess := [PID_of_process]
			Else
				ArrayOfSuspendedProcess.Push(PID_of_process)
			MsgBox, % ArrayOfSuspendedProcess.Length()
			SuspendProcess(PID_of_process)
		}
	}
}
Return