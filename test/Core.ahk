;============ Auto-execute ====================================================;
;--------------  Setting  ------------------------------------------------------;

#NoEnv
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox

Process, Priority, , Normal
SetBatchLines, -1
SetTitleMatchMode, 2

;-------------- Variable ------------------------------------------------------;

IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global Debug

;---------------- Hook --------------------------------------------------------;

OnExit("Exit")

;---------------- Test --------------------------------------------------------;

loops := 1000000
global gdiplus := LoadLibrary("gdiplus")

VarSetCapacity(bin, 20, 0)
NumPut(1, bin, 0, "Int")
DllCall(gdiplus.GdiplusStartup, "Ptr*", token, "Ptr", &bin, "Ptr", 0)
DllCall(gdiplus.GdipCreateBitmapFromScan0, "Int", 1, "Int", 1, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", pBitmap)

start := A_TickCount
loop % loops
    DllCall("gdiplus\GdipBitmapGetPixel", "Ptr", pBitmap, "Int", 1, "Int", 1, "uint*", col)
timeA := A_TickCount-start

start := A_TickCount
loop % loops
    DllCall(gdiplus.GdipBitmapGetPixel, "Ptr", pBitmap, "Int", 1, "Int", 1, "uint*", col)
timeB := A_TickCount-start

DllCall(gdiplus.DisposeImage, "Ptr", pBitmap)
DllCall(gdiplus.Cleanup, "Ptr", token)
MsgBox % "Normal:`n" timeA "`n`nWith LoadLibrary:`n" timeB "`n`n" timeA/timeB

;Assert.Report()

exit

;=============== Hotkey =======================================================;

#If (WinActive(A_ScriptName))

    ~*$Esc::
        KeyWait, Esc, T1
        if (ErrorLevel) {
            ExitApp
        }

        return

    $F10::
        ListVars
        return

    ~$^s::
        Critical, On

        Sleep, 200
        Reload

        return

#If

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\lib\Assert\Assert.ahk

;===============  Label  =======================================================;

;============== Function ======================================================;

Exit() {
    Critical, On

    ExitApp
}

;===============  Class  =======================================================;
