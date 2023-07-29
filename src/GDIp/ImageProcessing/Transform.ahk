#Requires AutoHotkey v2.0-beta.12

;============ Auto-Execute ====================================================;
;---------------  Admin  -------------------------------------------------------;

if (!A_IsAdmin || !DllCall("Kernel32\GetCommandLine", "Str") ~= " /restart(?!\S)") {
    try {
        Run(Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (Format('{} /restart "{}"', A_AhkPath, A_ScriptFullPath))))
    }

    ExitApp()
}

;--------------  Include  ------------------------------------------------------;

#Include ..\..\lib\Core.ahk

#Include ..\..\lib\General\General.ahk
#Include ..\..\lib\Assert\Assert.ahk
#Include ..\..\lib\Console\Console.ahk

#Include ..\..\lib\Geometry.ahk
#Include ..\..\lib\Color\Color.ahk
#Include ..\..\lib\Math\Math.ahk

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
SetWorkingDir(A_ScriptDir . "\..\..")

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

;0: rotation
;
;1: vertical flip
;
;2: horizontal flip
;
;3: vertical+horizontal flip

image := GDIp.CreateBitmapFromFile("C:\Users\Onimuru\OneDrive\__Code\GDIp\res\Image\Texture\stonewall.jpg")

dimention := image.Width

if (!IsPowerOfTwo(dimention) && image.Width != image.Height) {
    Console.Log("The image you have provided does not have dimensions N x N where N is a power of 2.")

    closest_valid_dimension := 2**Round(Math.Log(2, Math.Min(image.Width, image.Height)))
}

transform_type := 0, tempBitmap := image.Clone()

image.LockBits()

for rotations in Range(4) {
    width := dimention//2
    number_of_frames := Integer(Math.log2[dimention])*2

    while (width > 0) {
        number_of_frames -= 2
        number_of_frames := Math.Max(1, number_of_frames)

        ;create the sliding animation by gradually moving the tiles
        for index in Range(0, number_of_frames) {

            tempBitmap := image.Clone(), tempBitmap.LockBits()
            shift := (width*(index + 1))  ; number_of_frames

            if (transform_type == 0) {
                for x in Range(0, dimention, width*2) {
                    for y in Range(0, dimention, width*2) {
                        rotate_with_steps(image, tempBitmap, x, y, width, shift)
                    }
                }
            }
;           else if (transform_type == 1) {
;               for y in Range(0, dimention, width*2) {
;                   v_flip_with_steps(image, tempBitmap, y, width, shift)
;               }
;           }
;           else if (transform_type == 2) {
;               for x in Range(0, dimention, width*2) {
;                   h_flip_with_steps(image, tempBitmap, x, width, shift)
;               }
;           }

;           cv.imshow('output', tempBitmap)
;           cv.waitKey(1)
;
;           out.write(tempBitmap)
        }

;       image := tempBitmap.Clone()
        width := width//2
    }
}

image.UnLockBits()

canvas.Graphics.DrawImage(image)
canvas.Update()



IsPowerOfTwo(number) {
    return (number != 0 && number & (number -1 ) == 0)
}

rotate_with_steps(img, output, x, y, width, shift) {
    stride1 := img.BitmapData.NumGet(8, "Int"), scan01 := img.BitmapData.NumGet(16, "Ptr")
    stride2 := output.BitmapData.NumGet(8, "Int"), scan02 := output.BitmapData.NumGet(16, "Ptr")

    reset := x

    loop (width) {
        loop (x := reset, width) {
            Numput("UInt", NumGet(scan01 + x++*4 + y*stride1, "UInt"), scan02 + x++*4 + y*stride2)  ;~ The Stride data member is negative if the pixel data is stored bottom-up.
        }

        y++
    }

;   img[y + width:y + 2 * width, x:x + width]           output[y + width - shift:y + 2 * width - shift, x:x + width] =


;   output[y + width:y + 2 * width, x + width - shift:x + 2 * width - shift] = img[y + width:y + 2 * width, x + width:x + 2 * width]
;   output[y + shift:y + width + shift, x + width:x + 2 * width] = img[y:y + width, x + width:x + 2 * width]
;   output[y:y + width, x + shift:x + width + shift] = img[y:y + width, x:x + width]
}


;--------------------------------------------------------  Log  ----------------;

;Console.Log(Assert.CreateReport())

;---------------  Other  -------------------------------------------------------;

Exit()  ;! ExitApp()

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

    global canvas := null
        , brush := null, pen := null

    GDIp.Shutdown()
}

;----------------  QPC  --------------------------------------------------------;

GetTime() {
    static frequency := (DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &(frequency := 0)), frequency)  ;* Ticks-per-second.

    return (DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &(current := 0)), (current*1000)/frequency)  ;~ No error handling as there is no reason for this to fail.
}

;===============  Class  =======================================================;
