#Requires AutoHotkey v2.0.0

;============ Auto-Execute ====================================================;
;---------------  Admin  -------------------------------------------------------;

if (!A_IsAdmin || !DllCall("Kernel32\GetCommandLine", "Str") ~= " /restart(?!\S)") {
    try {
        Run(Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (Format('{} /restart "{}"', A_AhkPath, A_ScriptFullPath))))
    }

    ExitApp()
}

;--------------  Include  ------------------------------------------------------;

#Include ..\lib\FindPixel.ahk
#Include ..\lib\Console\Console.ahk

;--------------  Setting  ------------------------------------------------------;

;#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
;DetectHiddenWindows(True)
ListLines(False)
Persistent(True)
ProcessSetPriority("Normal")
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..")

;---------------- Menu --------------------------------------------------------;

TraySetIcon(A_WorkingDir . "\res\Image\Icon\0.ico")

;-------------- Variable ------------------------------------------------------;

global debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
    , windowMessage := DllCall("User32\RegisterWindowMessage", "Str", "WindowMessage", "UInt")
    , null := Chr(0)

;---------------- Hook --------------------------------------------------------;

OnMessage(windowMessage, WindowMessageHandler)

OnExit(ExitHandler)

;---------------- Test --------------------------------------------------------;

pixel := { x: Random(500, A_ScreenWidth - 1), y: Random(500, A_ScreenHeight - 1) }
    , color := 0xFF9932CC

;~ FindSinglePixel_WholeScreen

SetPixel(pixel.x, pixel.y)

mark := GetTime()
result := FindSinglePixel_WholeScreen(color)

MsgBox(FormatString(result, mark))

;~ FindSinglePixel_Rectangle

SetPixel(pixel.x, pixel.y)

mark := GetTime()
result := FindSinglePixel_Rectangle(pixel.x - 500, pixel.y - 500, pixel.x + 1, pixel.y + 1, color)

MsgBox(FormatString(result, mark))

Exit()

;=============== Hotkey =======================================================;

#HotIf (WinActive(A_ScriptName) || WinActive("FindPixel.ahk"))

$F10:: {
    ListVars()

    KeyWait("F10")
}

~$^s:: {
    Critical(True)

    Sleep(200)
    Reload()
}

#HotIf

;============== Function ======================================================;
;---------------- Hook --------------------------------------------------------;

WindowMessageHandler(wParam, lParam, msg, hWnd) {
    switch (wParam) {
        case 0x1000:
            global debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")

            return (True)
    }

    return (-1)
}

ExitHandler(exitReason, exitCode) {
    Critical(True)
}

;----------------  QPC  --------------------------------------------------------;

GetTime() {
    static frequency := (DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &(frequency := 0)), frequency)  ;* Ticks-per-second.

    return (DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &(current := 0)), (current * 1000) / frequency)  ;~ No error handling as there is no reason for this to fail.
}

;----------------  QPC  --------------------------------------------------------;

SetPixel(x, y) {
    DllCall("Gdiplus\GdipBitmapSetPixel", "Ptr", GDIp.Bitmap, "Int", x, "Int", y, "UInt", color)
    DllCall("Gdi32\BitBlt", "Ptr", DllCall("User32\GetDC", "Ptr", 0, "Ptr"), "Int", x, "Int", y, "Int", 1, "Int", 1, "Ptr", GDIp.DC.Handle, "Int", x, "Int", y, "UInt", 0x00CC0020 | 0x40000000)
}

FormatString(result, mark) {
    return (result.x . ", " . result.y . ((result.x == pixel.x && result.y == pixel.y) ? ("") : (" (" . pixel.x . ", " . pixel.y . ")")) . "`n" . Format("{:.2f}", GetTime() - mark) . "ms")
}
