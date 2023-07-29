#Requires AutoHotkey v2.0-beta

;============ Auto-Execute ====================================================;
;=======================================================  Admin  ===============;

if (!A_IsAdmin || !DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)") {
    try {
        Run(Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (Format('{} /restart "{}"', A_AhkPath, A_ScriptFullPath))))
    }

    ExitApp()
}

;======================================================  Include  ==============;

#Include ..\..\lib\Core.ahk

#Include ..\..\lib\Console\Console.ahk

#Include ..\..\lib\Color\Color.ahk
#Include ..\..\lib\Geometry.ahk
#Include ..\..\lib\Math\Math.ahk

;======================================================  Setting  ==============;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
;DetectHiddenWindows(True)
InstallKeybdHook(True)
InstallMouseHook(True)
ListLines(False)
Persistent(True)
ProcessSetPriority("Realtime")
SetKeyDelay(-1, -1)
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..\..")

;======================================================== Menu ================;

TraySetIcon(A_WorkingDir . "\res\Image\Icon\1.ico")

;=======================================================  Group  ===============;

for v in [
    "Core.ahk",
        "Array.ahk", "Object.ahk", "String.ahk",

        "Structure.ahk",

        "Direct2D.ahk",
        "DirectWrite.ahk",
        "GDI.ahk",
        "GDIp.ahk",
            "Canvas.ahk", "Bitmap.ahk", "Graphics.ahk", "Brush.ahk", "Pen.ahk", "Path.ahk", "Matrix.ahk",
        "WIC.ahk",

    "General.ahk", "Assert.ahk", "Console.ahk",

    "Color.ahk",
    "Geometry.ahk",
        "Vec2.ahk", "Vec3.ahk", "TransformMatrix.ahk", "RotationMatrix.ahk", "Matrix3.ahk", "Ellipse.ahk", "Rect.ahk"
    "Math.ahk"] {
    GroupAdd("Library", v)
}

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug"),
    A_WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt"),

    A_SavedClipboard,
    A_Null := Chr(0)

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;========================================================  Run  ================;

;Run(A_ScriptDir . "\Secondary.ahk")

;======================================================== GDIp ================;

GDIp.Startup()

global Grid := CreateGrid(A_ScreenWidth - 640 - 50, 50, 640),
    Overlay := CreateOverlay()

;   Layers := CreateLayers(Grid.x, Grid.y, Grid.Width),
;   Overlay := CreateOverlay(Grid.x, Grid.y + 32, Grid.Width)

;Script.Canvas := LayeredWindow(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, className := "Canvas", ["CS_HREDRAW", "CS_VREDRAW"], windowProc := False, 32512, title := False, exStyle := ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TOPMOST"], style := ["WS_CLIPCHILDREN", "WS_POPUPWINDOW"], parent := 0, show := "SW_SHOWNOACTIVATE", alpha := 0xFF, pixelFormat := 0x000E200B, interpolation := 7, smoothing := 4)
;   Script.Brush := [GDIp.CreateSolidBrush(Color("AliceBlue")), GDIp.CreateLinearBrushFromRect(0, 0, Script.Canvas.Width, Script.Canvas.Height, Color("Honeydew"), Color("Sienna"), 2, 0)],
;   Script.Pen := [GDIp.CreatePenFromBrush(Script.Brush[0]), GDIp.CreatePenFromBrush(Script.Brush[1])],
;
;   Script.Border := {x: 0, y: 0, Width: 300, Height: 300}

;======================================================== Test ================;

;=======================================================  Other  ===============;

Exit()

;=============== Hotkey =======================================================;

#HotIf (WinActive(A_ScriptName) || WinActive("ahk_group Library"))

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
;======================================================== Hook ================;

__WindowMessage(wParam := 0, lParam := 0, msg := 0, hWnd := 0) {
    switch (wParam) {
        case 0x1000:
            if (!(A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug"))) {
                ToolTip("", , , 20)
            }

            return (True)
    }

    return (-1)
}

__Exit(exitReason, exitCode) {
    Critical(True)

;   global Grid := A_Null, Layers := A_Null
;       Overlay := A_Null
;
;   GDIp.Shutdown()
}

/*
** WM Constants: https://www.pinvoke.net/default.aspx/Constants.WM. **
*/

__GridProc(hWnd, uMsg, wParam, lParam) {
    static tracking := False

    static previous := -1

    static nullBrush := GDIp.CreateSolidBrush(0x00000000)

    static currentLayer := 0, currentBlock := 1

    switch (uMsg) {
        case 0x0200:  ;? 0x0200 = WM_MOUSEMOVE
            if (!tracking) {
                tracking := True

                TrackMouseEvent(hWND, 0x00000003)  ;? 0x00000003 = TME_HOVER | TME_LEAVE

                if (A_Debug) {
                    ToolTip("WM_MOUSEMOVE", 5, 5, 20)
                }

                Overlay.Show()
            }

            index := GetIndex(lParam & 0xFFFF, lParam >> 16)

            GetIndex(x, y) {
                static height := Grid.Height, tiles := Grid.Width//32

                offset := 16 + 64,
                    x := (x - height)*0.5 + offset/2, y -= offset  ;* `offset` accounts for the gap at the top.

                return (Fix((x + y - 1)/16) + Fix((y - x - 1)/16)*tiles)

                Fix(number) {
                    return (number < 0 ? Ceil(number) : Floor(number))
                }
            }

            if (index != previous) {
                if (~previous) {
                    node := Grid.Nodes[previous]

                    Overlay.Graphics.FillRectangle(nullBrush, node[0] - 16, node[1] - 16, 64, 64)
                }

                previous := index

                if (A_Debug) {
                    ToolTip(index, 5, 25, 19)
                }

                static select := GDIp.CreateBitmapFromFile(A_WorkingDir . "\res\Image\Isometric\Select.png")

                DrawBlock(Overlay.Graphics, select, Grid.Nodes[index], .35)
                Overlay.Update()
            }
        case 0x02A1:  ;? 0x02A1 = WM_MOUSEHOVER
            Critical(True)

            if (A_Debug) {
                ToolTip("WM_MOUSEHOVER", 5, 5, 20)
                ToolTip(previous, 5, 25, 19)
            }

            static perpetual := False

            if (perpetual) {
                TrackMouseEvent(hWND, 0x00000001)  ;? 0x00000001 = TME_HOVER
            }
        case 0x02A3:  ;? 0x02A3 = WM_MOUSELEAVE
            Critical(True)

            TrackMouseEvent(hWND, 0x80000000)  ;? 0x80000000 = TME_CANCEL

            if (A_Debug) {
                ToolTip("WM_MOUSELEAVE", 5, 5, 20)
                ToolTip(, , , 19)
            }

            Overlay.Hide()

            if (~previous) {
                node := Grid.Nodes[previous]

                Overlay.Graphics.FillRectangle(nullBrush, node[0] - 16, node[1] - 16, 64, 64)
                Overlay.Update()

                previous := -1
            }

            tracking := False

        case 0x0201:  ;? 0x0201 = WM_LBUTTONDOWN
            Critical(True)
        ;case 0x0202:  ;? 0x0202 = WM_LBUTTONUP
        ;case 0x0203:  ;? 0x0203 = WM_LBUTTONDBLCLK

        case 0x0204:  ;? 0x0204 = WM_RBUTTONDOWN
            Critical(True)
        ;case 0x0205:  ;? 0x0205 = WM_RBUTTONUP
        ;case 0x0206:  ;? 0x0206 = WM_RBUTTONDBLCLK

        ;case 0x0207:  ;? 0x0207 = WM_MBUTTONDOWN
        ;case 0x0208:  ;? 0x0208 = WM_MBUTTONUP
        ;case 0x0209:  ;? 0x0209 = WM_MBUTTONDBLCLK

        ;case 0x020A:  ;? 0x020A = WM_MOUSEWHEEL (Vertical)
    }

    TrackMouseEvent(hWnd, flags := 0x00000002, hoverTime := 400) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent
        static size := A_PtrSize*2 + 8

        eventTrack := Buffer(size),
            NumPut("UInt", size, "UInt", flags, "Ptr", hWnd, "UInt", hoverTime, eventTrack)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-trackmouseevent

        if (!DllCall("User32\TrackMouseEvent", "Ptr", eventTrack, "UInt")) {
            throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
        }

        return (False)
    }

    ScreenToGridTransform(x, y) {
        ; [0.5   -0.5   0]
        ; [ 1      1    0]
        ; [ 0      0    1]

        x *= 0.5

        return (Vec2(x + y, y - x))
    }

    GridToScreenTransform(x, y) {
        ; [ 1   0.5   0]
        ; [-1   0.5   0]
        ; [ 0    0    1]

        return (Vec2(x - y, (x + y)*0.5))
    }

    return (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "UPtr", wParam, "Ptr", lParam, "Ptr"))
}

;======================================================== GDIp ================;

CreateGrid(x, y, width, layers := 3) {
    yOffset := 16 + 32*(layers - 1)

    (grid := LayeredWindow(x, y, width, width*0.5 + yOffset, "IsometricGrid", ["CS_HREDRAW", "CS_VREDRAW"], __GridProc, 32512, False, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TOPMOST"], [["WS_CLIPCHILDREN", "WS_POPUPWINDOW"], ["WS_CAPTION"]], False, "SW_SHOWNOACTIVATE", 0xFF, 0x000E200B, 7, 4)).Nodes := [],
        gridWidth := grid.Width, graphics := grid.Graphics, nodes := grid.Nodes

    tile := GDIp.CreateBitmapFromFile(A_WorkingDir . "\res\Image\Isometric\Tile.png"),
        tileWidth := tile.Width

    loop (loopIndex := 0, gridWidth/32) {
        for rangeIndex, xOffset in Range(Round(gridWidth/2) - loopIndex*16, gridWidth - loopIndex*16, 16) {
            x := xOffset - 16, y := rangeIndex*8 + loopIndex*8 - 16 + yOffset

            graphics.DrawImageRectRect(tile, x, y + 16, 32, 32, 0, 0, tileWidth, tileWidth)  ;* Offset 16 pixels in the y-axis because the nodes are placed for 32x32 blocks and tiles are 32x16.

            nodes.Push(Vec2(x, y))
        }

        loopIndex++
    }

    grid.Update()

    return (grid)
}

CreateOverlay() {
    Overlay := LayeredWindow(Grid.x, Grid.y, Grid.Width, Grid.Height, "IsometricLayer", 0x00000000, False, False, False, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TRANSPARENT"], ["WS_OVERLAPPEDWINDOW"], Grid.Handle, 0, 0xFF, 0x000E200B, 7, 4)

    static alpha := 0x8F/0xFF

    for index, block in [11, 1, 2] {
        DrawBlock(Overlay.Graphics, GDIp.CreateBitmapFromFile(A_WorkingDir . "\res\Image\Isometric\Cubes\" . SubStr("00" . block, -2) . "_64x64.png"), Vec2(16, 32*5 + 5 - index*(32 + 5) - 1), (index == 1) ? (1) : (alpha))
    }

    Overlay.Graphics.SetCompositingMode(0)

    width := Overlay.Width - 48

;   loop (3) {
;       DrawPlane(Overlay, Vec2(width, 64 + 7 + (A_Index - 1)*(16 + 5)), A_WorkingDir . "\res\Image\Isometric\Plane.png", (A_Index == 3) ? (1) : (alpha))
;   }

    Overlay.Graphics.SetCompositingMode(1)

    return (Overlay)
}

DrawBlock(Graphics, Bitmap, node, alpha?) {
    if (IsSet(alpha)) {
        static imageAttributes := GDIp.CreateImageAttributes()

        static inMatrix := 1

        if (inMatrix != alpha) {
            inMatrix := alpha

            static colorMatrix := Structure.CreateColorMatrix()

            colorMatrix.NumPut(72, "Float", alpha)

            if (status := DllCall("Gdiplus\GdipSetImageAttributesColorMatrix"
                , "Ptr", imageAttributes.Ptr  ;* imageattr
                , "Int", 0  ;* type
                , "Int", 1  ;* enableFlag
                , "Ptr", colorMatrix.Ptr  ;* colorMatrix
                , "Ptr", 0  ;* grayMatrix
                , "Int", 0  ;* flags
                , "UInt")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimageattributes/nf-gdiplusimageattributes-imageattributes-setcolormatrix
                throw (ErrorFromStatus(status))
            }
        }

        if (status := DllCall("Gdiplus\GdipGetImageDimension", "Ptr", Bitmap, "Float*", &(width := 0), "Float*", &(height := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        Graphics.DrawImageRectRect(Bitmap, node[0], node[1], 32, 32, 0, 0, width, height, imageAttributes)
    }
    else {
        Graphics.DrawImageRect(Bitmap, node[0], node[1], 32, 32)
    }
}

;===============  Class  =======================================================;

class Script {
    static Started := False, Running := False

    static SlowFactor := 1.0  ;* Slow motion scaling factor.

    static TargetFPS {  ;* Generally, 60 is a good choice because most monitors run at 60 Hz.
        Get {
            return (60)
        }
    }

    static MaxFPS {
        Get {
            return (60)
        }
    }

    static FPSAlpha {  ;* A factor that affects how heavily to weigh more recent seconds' performance when calculating the average frames per second in the range (0.0, 1.0). Higher values result in weighting more recent seconds more heavily.
        Get {
            return (0.85)
        }
    }
}
