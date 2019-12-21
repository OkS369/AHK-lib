#SingleInstance force
#HotkeyInterval 10
#MaxHotkeysPerInterval 10
#NoTrayIcon
#InstallKeybdHook
#InstallMouseHook
#NoEnv

RAlt::
composeCount += 1
Input, inputChar, L1T3,{RAlt},a,o,u
if (ErrorLevel = "Endkey:RAlt")
    goto, RAlt
if (Errorlevel = "Match")
{
    if (composeCount = 1)
    {
        if (inputChar = "a")
            sendInput {U+00E4}
        if (inputChar = "o")
            sendInput {U+00F6}
        if (inputChar = "u")
            sendInput {U+00FC}
    }
    if (composeCount = 2)
    {
        if (inputChar = "a")
            sendInput {U+00C4}
        if (inputChar = "o")
            sendInput {U+00D6}
        if (inputChar = "u")
            sendInput {U+00DC}
    }
}
composeCount := 0
Return