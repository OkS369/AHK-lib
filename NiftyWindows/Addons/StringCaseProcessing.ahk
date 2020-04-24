/*
AdaptCase(String1, String2)	: Adapts String2 with String1 case
ConvertCase(String, Case)	: Converts a string in a given case
GetCase(String)				: Returns the case of the string
Author : R3gX
Thanks to : Lexikos & String (n-l-i user)
*/

AdaptCase(String1, String2){
	If IsUpper(String1)
		Return, ConvertCase(String2, "upper")
	Else If IsLower(String1)
		Return, ConvertCase(String2, "lower")
	Else If IsTitle(String1)
		Return, ConvertCase(String2, "title")
	Return, String2
}

ConvertCase(String, Case){
	If (Case="upper" || Case="u")
		Return, RegExReplace(String, "(.+)", "$u1")
	Else If (Case="title" || Case="t")
		Return, RegExReplace(String, "(.+)", "$t1")
	Else
		Return, RegExReplace(String, "(.+)", "$l1")
}

GetCase(String){
	If IsUpper(String1)
		Return, "upper"
	Else If IsLower(String)
		Return, "lower"
	Else If IsTitle(String)
		Return, "title"
	Else
		Return, String2
}

IsUpper(String){
  Return (String == RegExReplace(String, "(.+)", "$U1")) ? 1 : 0
}

IsLower(String){
  Return (String == RegExReplace(String, "(.+)", "$L1")) ? 1 : 0
}

IsTitle(String){
  Return (String == RegExReplace(String, "(.+)", "$T1")) ? 1 : 0
}