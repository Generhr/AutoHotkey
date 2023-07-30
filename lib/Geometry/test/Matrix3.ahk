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

;---------------- Test --------------------------------------------------------;  ;* See also: https://www.mathsisfun.com/algebra/matrix-calculator.html.
;-------------------------------------------------------  __New  ---------------;
Assert.SetLabel("__New")

Assert.IsEqual(Matrix3(), [1, 0, 0, 0, 1, 0, 0, 0, 1])

;----------------------------------------------------  Determinant  ------------;
Assert.SetLabel("Determinant")

Assert.IsEqual(Matrix3.Determinant(Matrix3(0)), 0)
Assert.IsEqual(Matrix3.Determinant(Matrix3(2)), 2)
Assert.IsEqual(Matrix3.Determinant(Matrix3(6, 1, 1, 4, -2, 5, 2, 8, 7)), -306)

;------------------------------------------------------ Multiply --------------;  ;* Values checked against https://www.euclideanspace.com/maths/algebra/matrix/arithmetic/threeD/index.htm.
Assert.SetLabel("Multiply")

Assert.IsEqual(Matrix3.Multiply(Matrix3(1, 0, 0, 0, 0.3, 0, 0, 0, 2), Matrix3().Set(1.2, 0, 0, 0, 1, 0, 0, 0, 2)), [1.2, 0, 0, 0, 0.3, 0, 0, 0, 4])
Assert.IsEqual(Matrix3(3, 2, 1, 6, 3, 3, 1, 4, 5).Multiply(Matrix3(3, 2, 1, 6, 3, 3, 1, 4, 5)), [22, 16, 14, 39, 33, 30, 32, 34, 38])
Assert.IsEqual(Matrix3(0.5, 0, 0, 4.5, 0.5, -2.25, -1, 0, 0.5).Multiply(Matrix3(1, 1, 0, 0, 0.5, 0, 0, 1, 1), true), [0.5, 0.5, 0, 4.5, 2.5, -2.25, -1, -0.5, 0.5])

;------------------------------------------------------  RotateX  --------------;
Assert.SetLabel("RotateX")

Assert.IsEqual(Matrix3().RotateX(1.2), [1, 0, 0, 0, 0.36235775447667362, 0.93203908596722629, 0, -0.93203908596722629, 0.36235775447667362])
Assert.IsEqual(Matrix3.RotateX(Matrix3(), 1.2), Matrix3().RotateX(1.2))
Assert.IsEqual(Matrix3.RotateX(Matrix3(), 0.52359877559829004), [1, 0, 0, 0, 0.86602540378444304, 0.49999999999999234, 0, -0.49999999999999234, 0.86602540378444304])

;------------------------------------------------------  RotateY  --------------;
Assert.SetLabel("RotateY")

Assert.IsEqual(Matrix3().RotateY(1.2), [0.36235775447667362, 0, -0.93203908596722629, 0, 1, 0, 0.93203908596722629, 0, 0.36235775447667362])
Assert.IsEqual(Matrix3.RotateY(Matrix3(), 1.2), Matrix3().RotateY(1.2))

;------------------------------------------------------  RotateZ  --------------;
Assert.SetLabel("RotateZ")

Assert.IsEqual(Matrix3().RotateZ(1.2), [0.36235775447667362, 0.93203908596722629, 0, -0.93203908596722629, 0.36235775447667362, 0, 0, 0, 1])
Assert.IsEqual(Matrix3.RotateZ(Matrix3(), 1.2), Matrix3().RotateZ(1.2))

;-------------------------------------------------------  Scale  ---------------;
Assert.SetLabel("Scale")

Assert.IsEqual(Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9).Scale(0.25, 0.25), [0.25, 0.5, 0.75, 1, 1.25, 1.5, 7, 8, 9])

;------------------------------------------------------- Invert ---------------;  ;* Values checked against https://www.euclideanspace.com/maths/algebra/matrix/functions/inverse/threeD/index.htm.
Assert.SetLabel("Invert")

Assert.IsEqual(Matrix3(0, 0, 0, 0, 0, 0, 0, 0, 0).Invert(), false)
Assert.IsEqual(Matrix3(9, 3, 7, 2, 1, 0, 4, 1, 2).Invert(), [-0.25, -0.125, 0.875, 0.5, 1.25, -1.75, 0.25, -0.375, -0.375])
Assert.IsEqual(Matrix3(2, 2, 3, 2, 1, 2, 3, 0, 1).Invert(), [1, -2, 1, 4, -7, 2, -3, 6, -2])

;-----------------------------------------------------  Transpose  -------------;
Assert.SetLabel("Transpose")

Assert.IsEqual(Matrix3(1, 0, 0, 1, 0, 0, 1, 0, 0).Transpose(), Matrix3(1, 1, 1, 0, 0, 0, 0, 0, 0))

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
