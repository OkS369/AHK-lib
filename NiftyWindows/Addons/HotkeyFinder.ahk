;Hotkey finder
#!^h:: ;<-- Hotkey Help
tkShowHotkeyHelp:
        SetTitleMatchMode 2
	Includelist0 = 0
	InclIdx = 0 ; for handling include files
	splitpath, A_Scriptfullpath, ohname, ohdir, ohext, ohnameNE, ohdrv
	
	HlpSrcFile = %ohname%
    HlpDestFile = %ohnameNE%_Hotkeys.txt
	OldWorkingDir := A_WorkingDir
	SetWorkingDir, %ohdir%
	
	
	; first time in for base file
	;HelpFile = %ofnameNE%Help.txt
	;BaseHelpFile = %ofnameNE%Help.txt
	IfWinExist, %HlpDestFile%
	{	WinClose, %HlpDestFile%
		WinWaitclose, %HlpDestFile%
		Return
	}
	IfExist, %HlpDestFile%
		FileDelete, %HlpDestFile%
		
tkShowMore:
	oldTrim := A_AutoTrim
	AutoTrim, On
	HlpSrcFile = %ohname%
		
	Loop
	{	fileReadline, thisline, %HlpSrcFile%, %A_Index%
		If ErrorLevel
			Break
		
		; ignore single line comments
		firstch := SubStr(thisline,1,1)
		If (firstch = ";")
			continue
		; Ignore IfInString test lines
		IfInString, thisline, IfInString
			continue
			
		;....................	
		; process rem comments
		;IfInString, thisline, ¾beginBlockComment%
		IfInString, thisline, /*
		{	InComment = 1	
			Continue
		}
		;IfInString, thisline, %endBlockComment%
		IfInString, thisline, */
		{	InComment = 0
			Continue
		}
		; handle a line within a block comment
		If (InComment = 1)
			Continue
		
		; process hotkey command
		; line as hotkey def there are two forms of a hotkey assignment. one uses the 
		; label Hotkey the other uses the double colon in the key assignment.
		tempstr = %thisline% ;<-- to cause autotrim to activate
		firstword := SubStr(tempstr,1,6)
		If (firstword = "Hotkey")
		{	FileAppend, %tempstr% Line# %A_Index%`n, %HlpDestFile%
			Continue
		}
		
		; double colon hotkey or hotstring
		IfInString, thisline, ::
		{	FileAppend,%thisline% Line# %A_Index%`n, %HlpDestFile%
			Continue
		}
		
		; process single line comment statement
		IfInString, thisline, `;
			Continue
		
		; handle #include files this is so you can identify
		; hotkeys from additional files
		IfInString, thisline, #IncludeAgain		;<-- ignore multiple includes of the same file
			Continue
			
		IfInString, thisline, #Include
		{	InclIdx++ ;<-- count the include file
			IncludeList0 := IncIdx
			inclstr :=(SubStr(thisline, 10))
			;MsgBox,0, ,inclstr=%inclstr%
			IfInString, inclstr, *i
				inclstr := SubStr(inclstr,3)
			IncludeList%InclIdx% = %inclstr%
			FileAppend,%thisline% Line# %a_Index%`n, %HlpDestFile%
			Continue
			
		}
	}		
	AutoTrim := oldtrim
	
	; walk backwards through the include files 
	If (InclIdx > 0)
	{	inclstr := IncludeList%InclIdx%
		InclIdx--
		Splitpath, InclStr,ohname,,,ohnameNE
		FileAppend, `r`n`r`nIncluded %ohname%`r`n`r`n, %HlpDestFile%
		Goto tkShowMore
	}
	Run, Notepad %ohdir%\%HlpDestFile%
	SetWorkingdir, %OldWorkingDir%
	Return