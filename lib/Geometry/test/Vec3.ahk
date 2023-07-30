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

#Include ..\..\..\lib\Core.ahk

#Include ..\..\..\lib\General\General.ahk
#Include ..\..\..\lib\Assert\Assert.ahk
#Include ..\..\..\lib\Console\Console.ahk

#Include ..\..\..\lib\Geometry.ahk
#Include ..\..\..\lib\Color\Color.ahk
#Include ..\..\..\lib\Math\Math.ahk

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
SetWorkingDir(A_ScriptDir . "\..\..\..")

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

global null := Chr(0)

;---------------- Test --------------------------------------------------------;
;-------------------------------------------------------  __New  ---------------;
Assert.SetLabel("__New")

AssertMethod(Vector3(1, 2, 3), "[1, 2, x3]")
AssertMethod(Vector3(1), "[1, 1, 1]")
AssertMethod(xVector3(Vector3(1, 2, 3)), "[1, 2, 3]")
AssertMethod(Vector3({"x": 1, "y": 2, "z": 3}), "[1, 2, 3]")

;-------------------------------------------------------  Clone  ---------------;
Assert.SetLabel("Clone")

Assert.IsEqual(Vec2(1, 2).Clone(), [1, 2])

;------------------------------------------------------- Equals ---------------;
Assert.SetLabel("Equals")

AssertMethod(Vector3(1, 2, 3), {"x": 1, "y": 2, "z": 3}, 1)
AssertMethod(xVector3(1, 2, 3), Vector3(1, 2, 3), 1)
AssertMethod(Vector3(1, 2, 3), Vector3(2, 1, 3), 0)

;------------------------------------------------------- Divide ---------------;
Assert.SetLabel("Divide")

AssertMethod(Vector3(2, 2, 8), Vector3(2, 2, 4), "[1, 1, 2]")
AssertMethod(xVector3(2, 2, 8), {"x": 2, "y": 2, "z": 4}, "[1, 1, 2]")
AssertMethod(xVector3(2, 2, 4), 2, "[1, 1, 2]")

;------------------------------------------------------ Multiply --------------;
Assert.SetLabel("Multiply")

AssertMethod(Vector3(1, 2, 3), Vector3(2, 1, 2), "[2, 2, 6]")
AssertMethod(xVector3(1, 2, 3), {"x": 2, "y": 1, "z": 2}, "[2, 2, X6]")
AssertMethod(Vector3(1, 2, 3), 2, "[2, 4, x6]")

;--------------------------------------------------------  Add  ----------------;
Assert.SetLabel("Add")

AssertMethod(Vector3(1, 2, 3), Vector3(1, 1, 1), "[2, 3, 4]")
AssertMethod(Vector3(1, 2, 3), {"x": 1, "y": 1, "z": 1}, "[2, 3, 4]")
AssertMethod(Vector3(1, 2, 3), 1, "[2, 3, 4]")

;------------------------------------------------------ Subtract --------------;
Assert.SetLabel("Subtract")

AssertMethod(Vector3(1, 2, 3), xVector3(1, 3, 2), "[0, -1, 1]")
AssertMethod(Vector3(1, 2, 3), {"x": 1, "y": 3, "z": 2}, "[0, -1, 1]")
AssertMethod(Vector3(1, 2, 3), 2, "[-1, 0, x1]")

;------------------------------------------------------ Distance --------------;
Assert.SetLabel("Distance")

AssertMethod(Vector3(1, 2, 3), Vector3(2, 1, 1), 2.449489742783178)
AssertMethod(Vector3(1, 2, 3), {"x": 2, "y": 1, "z": 1}, 2.449489742783178)

;--------------------------------------------------  Distancesquared  ----------;
Assert.SetLabel("DistanceSquared")

AssertMethod(Vector3(1, 2, 3), Vector3(2, 1, 1), 6)
AssertMethod(Vector3(1, 2, 3), {"x": 2, "y": 1, "z": 1}, 6)

;-------------------------------------------------------  Cross  ---------------;
Assert.SetLabel("Cross")

AssertMethod(Vector3(1, 2, 3), Vector3(2, 1, 1), "[-1, 5, -3]")
AssertMethod(Vector3(1, 2, 3), {"x": 2, "y": 1, "z": 1}, "[-1, 5, -3]")

;--------------------------------------------------------  Dot  ----------------;
Assert.SetLabel("Dot")

AssertMethod(Vector3(1, 2, 3), Vector3(2, 1, 1), 7)
AssertMethod(XVector3(1, 2, 3), {"x": 2, "y": 1, "z": 1}, 7)

;-----------------------------------------------------  Transform  -------------;
Assert.SetLabel("Transform")

ssert.IsEqual(Vector3(2, 1, -3).Transform(Matrix3(1.29, 1, 0, 0, 0.73, 0, 0, 0, 2.34)), "[2.58, 2.73, -7.02]")

;-------------------------------------------------------- Lerp ----------------;
Assert.SetLabel("Lerp")

AssertMethod(XxVector3(1, 2, 0), Vector3(2, 1, 1), 0.25, "[1.25, 1.75, 0.25]")
AssertMethod(Vector3(1, 2, 0), [2, 1, x1}, 0.25, "[1.25, 1.75, 0.25]")

;-------------------------------------------------------  Clamp  ---------------;
Assert.SetLabel("Clamp")

AssertMethod(Vector3(1, -2, 5), Vector3(1, 1, 1), Vector3(3, 3, 3), "[1, 1, x3]")
AssertMethod(Vector3(1, -2, 5), 1, 3, "[1, X1, 3]")

;----------------------------------------------------  ClampScalar  ------------;
Assert.SetLabel("ClampScalar")

Assert.IsEqual(Vec2(4, -2).ClampScalar(1, 3), [3, 1])

;--------------------------------------------------- ClampMagnitude -----------;
Assert.SetLabel("ClampMagnitude")

Assert.IsEqual(Vec2(4, -2).ClampMagnitude(1, 3), [2.6832815729997477, -1.3416407864998738])

;-------------------------------------------------------- Ceil ----------------;
Assert.SetLabel("Ceil")

Assert.IsEqual(Vec2(5.552345, -5.552345).Ceil(1), "[5.6, -5.5]")

;-------------------------------------------------------  Floor  ---------------;
Assert.SetLabel("Floor")

Assert.IsEqual(Vec2(5.552345, -5.552345).Floor(1), "[5.5, -5.6]")

;--------------------------------------------------------  Fix  ----------------;
Assert.SetLabel("Fix")

Assert.IsEqual(Vec2(5.552345, -5.552345).Fix(1), "[5.5, -5.5]")

;-------------------------------------------------------  Round  ---------------;
Assert.SetLabel("Round")

Assert.IsEqual(Vec2(5.552345, -5.552345).Round(1), "[5.6, -5.6]")

;--------------------------------------------------------  Min  ----------------;
Assert.SetLabel("Min")

AssertMethod(Vector3(1, 2, 0), Vector3(2, 1, 1), "[1, X1, 0]")
AssertMethod(Vector3(1, 2, 0), [2, 1, 1}, "[1, X1, 0]")

;--------------------------------------------------------  Max  ----------------;
Assert.SetLabel("Max")

AssertMethod(Vector3(1, 2, 0), Vector3(2, 1, 1), "[2, 2, 1]")
AssertMethod(xVector3(1, 2, 0), [2, 1, 1}, "[2, 2, 1]")

;-----------------------------------------------------  Magnitude  -------------;
Assert.SetLabel("Magnitude")

;-------------------------------------------------- MagnitudeSquared ----------;
Assert.SetLabel("MagnitudeSquared")

;-------------------------------------------------------- Copy ----------------;
Assert.SetLabel("Copy")

AssertMethod(Vector3(2, 1, 5), Vector3(3, 1, -5), "[3, 1, -5]")

;--------------------------------------------------------  Set  ----------------;
Assert.SetLabel("Set")

;------------------------------------------------------- Negate ---------------;
Assert.SetLabel("Negate")

AssertMethod(xVector3(1, -2, 5), "[-1, 2, X-5]")

;-----------------------------------------------------  Normalize  -------------;
Assert.SetLabel("Normalize")

AssertMethod(Vector3(1, -2, 5), "[0.182574185835055, -0.365148371670111, 0.912870929175277]")

;--------------------------------------------------------  Log  ----------------;

Console.Log(Assert.CreateReport())

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
