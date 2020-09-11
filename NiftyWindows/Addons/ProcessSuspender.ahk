SuspendProcess(PID)
{
	Run cmd /c pssuspend %PID%,,Hide
}

UnSuspendProcess(PID)
{
	Loop, 3
	{
		Run cmd /c pssuspend -r %PID%,,Hide
	}
}


<^>!F11::
<^>!F12::
ProcessSuspender:
Suspend, Permit
{	
	
	IfInString, A_ThisHotkey, F12
	{
		If ArrayOfSuspendedProcess.Length() != 0
		{
			PID_of_process := ArrayOfSuspendedProcess.Pop()
			WinGet, Path_of_process, ProcessPath, ahk_pid %PID_of_process%
			MsgBox, 1, Unsuspend this process?,Path: %Path_of_process%  PID: %PID_of_process%, 10
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
			SuspendProcess(PID_of_process)
		}
	}
}
Return