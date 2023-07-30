#Requires AutoHotkey v2.0-beta.12

#DllLoad msvcrt

;============ Auto-Execute ====================================================;
;---------------  Admin  -------------------------------------------------------;

if (!A_IsAdmin || !DllCall("Kernel32\GetCommandLine", "Str") ~= " /restart(?!\S)") {
    try {
        Run(Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (Format('{} /restart "{}"', A_AhkPath, A_ScriptFullPath))))
    }

    ExitApp()
}

;--------------  Include  ------------------------------------------------------;

#Include ..\lib\Core.ahk

#Include ..\lib\General\General.ahk
#Include ..\lib\Assert\Assert.ahk
#Include ..\lib\Console\Console.ahk

#Include ..\lib\Color\Color.ahk
#Include ..\lib\Geometry.ahk
#Include ..\lib\Math\Math.ahk

;--------------  Setting  ------------------------------------------------------;

;#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
;DetectHiddenWindows(true)
ListLines(false)
Persistent(true)
ProcessSetPriority("Realtime")
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..")

;---------------- Menu --------------------------------------------------------;

TraySetIcon(A_WorkingDir . "\res\Image\Icon\Triangle.ico")

;---------------  Group  -------------------------------------------------------;

for library in [
    "Core.ahk"
        , "Array.ahk", "Object.ahk", "String.ahk", "Buffer.ahk"

        , "Direct2D.ahk", "DirectWrite.ahk", "GDI.ahk", "GDIp.ahk", "WIC.ahk"

    , "General.ahk", "Assert.ahk", "Console.ahk"

    , "Color.ahk"
    , "Geometry.ahk"
        , "Vec2.ahk", "Vec3.ahk", "TransformMatrix.ahk", "RotationMatrix.ahk", "Matrix3.ahk", "Ellipse.ahk", "Rect.ahk"
    , "Math.ahk"] {
    GroupAdd("Library", library)
}

;-------------- Variable ------------------------------------------------------;

global debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
    , windowMessage := DllCall("User32\RegisterWindowMessage", "Str", "WindowMessage", "UInt")

    , null := Chr(0)

;---------------- Hook --------------------------------------------------------;

OnMessage(windowMessage, WindowMessageHandler)

OnExit(ExitHandler)

;----------------  Run  --------------------------------------------------------;

;---------------- GDIp --------------------------------------------------------;

GDIp.Startup()

global canvas := LayeredWindow(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, "Canvas", ["CS_HREDRAW", "CS_VREDRAW"], false, 32512, false, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TOPMOST"], ["WS_CLIPCHILDREN", "WS_POPUPWINDOW"], 0, "SW_SHOWNOACTIVATE", 0xFF, 0x000E200B, 7, 4)
    , brush := [GDIp.CreateSolidBrush(Color("CadetBlue")), GDIp.CreateSolidBrush(Color("Crimson"))]
    , pen := [GDIp.CreatePen(0x80FFFFFF), GDIp.CreatePen(Color("DimGray"))]

;---------------- Test --------------------------------------------------------;

width := canvas.Width, height := canvas.Height
    , bitmap := canvas.Bitmap, pBitmap := bitmap.Ptr

set := Color("Crimson")

;* 1: SetPixel():
mark := GetTime()

reset := 0
    , y := 0

loop (height) {
    loop (x := reset, width) {
        DllCall("Gdiplus\GdipBitmapSetPixel", "Ptr", pBitmap, "Int", x++, "Int", y, "UInt", set)
    }

    y++
}

result .= "[1] " . Format("{:.2f}", GetTime() - mark) . "ms.`n"

;* 2 - SetPixel() (with GetProcAddress):
pGdipBitmapSetPixel := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapSetPixel", "Ptr")

mark := GetTime()

reset := 0
    , y := 0

loop (height) {
    loop (x := reset, width) {
        DllCall(pGdipBitmapSetPixel, "Ptr", pBitmap, "Int", x++, "Int", y, "UInt", set)
    }

    y++
}

result .= "[2] " . Format("{:.2f}", GetTime() - mark) . "ms.`n"

;* 3: SetLockBitPixel():

bitmap.LockBits()

mark := GetTime()

reset := 0
    , y := 0

scan0 := bitmap.Scan0, stride := bitmap.Stride

loop (height) {
    loop (x := reset, width) {
        Numput("UInt", set, scan0 + x++*4 + y*stride)  ;! DllCall("msvcrt\memset", "Ptr", scan0 + x++*4 + y*stride, "Int", 0xFFFFFFFF, "UInt", 4)
    }

    y++
}

result .= "[3] " . Format("{:.2f}", GetTime() - mark) . "ms.`n"

bitmap.UnlockBits()
canvas.Graphics.DrawImage(bitmap)

canvas.Update()

MsgBox(result)

;---------------  Other  -------------------------------------------------------;

Exit()

;=============== Hotkey =======================================================;
;---------------  Mouse  -------------------------------------------------------;

;-------------- Keyboard ------------------------------------------------------;

#HotIf (WinActive(A_ScriptName) || WinActive("ahk_group Library"))

$F10:: {
    ListVars()

    KeyWait("F10")
}

~$^s:: {
    Critical(true)

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

            return (true)
    }

    return (-1)
}

ExitHandler(exitReason, exitCode) {
    Critical(true)

    GDIp.Shutdown()
}

;----------------  QPC  --------------------------------------------------------;

GetTime() {
    static frequency := (DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &(frequency := 0)), frequency)  ;* Ticks-per-second.

    return (DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &(current := 0)), (current*1000)/frequency)  ;~ No error handling as there is no reason for this to fail.
}

;===============  Class  =======================================================;
