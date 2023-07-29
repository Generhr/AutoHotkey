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

if (!DllCall("User32\SetWindowPos", "Ptr", Console.Handle, "Ptr", -1  ;? -1 = HWND_TOPMOST
    , "Int", A_ScreenWidth - 815, "Int", 50, "Int", 450, "Int", 500, "UInt", 0x0080, "UInt")) {  ;? 0x0080 = SWP_HIDEWINDOW  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
    throw (ErrorFromMessage())
}

DllCall("User32\SetWindowLongPtr", "Ptr", Console.Handle, "Int", -20, "Ptr", DllCall("User32\GetWindowLongPtr", "Ptr", Console.Handle, "Int", -20, "Ptr") | 0x00000020)  ;? -20 = GWL_EXSTYLE, 0x00000020 = WS_EX_TRANSPARENT

if (!DllCall("User32\SetWindowPos", "Ptr", Console.Handle, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0027, "UInt")) {  ;? 0x0027 = SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
    throw (ErrorFromMessage())
}

WinSetStyle(-0x00E40000, Console.Handle)

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

OnMessage(windowMessage, MessageHandler)

OnExit(ExitHandler)

;----------------  Run  --------------------------------------------------------;

;Run(A_ScriptDir . "\Secondary.ahk")

;---------------- GDIp --------------------------------------------------------;

GDIp.Startup()

global canvas := LayeredWindow(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, "Canvas", ["CS_HREDRAW", "CS_VREDRAW"], WindowProc, 32512, false, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TOPMOST"], ["WS_CLIPCHILDREN", "WS_POPUPWINDOW"], 0, "SW_SHOWNOACTIVATE", 0xFF, 0x000E200B, 7, 4)
    , brush := [GDIp.CreateSolidBrush(Color("CadetBlue")), GDIp.CreateSolidBrush(Color("Crimson"))]
    , pen := [GDIp.CreatePen(0x80FFFFFF), GDIp.CreatePen(Color("DimGray"))]

global started := false, running := false
    , discardTime := false

global point := {Position: Vec2(150, 150), PreviousPosition: Vec2(150, 150), Width: 50, Height: 50
    , Velocity: Vec2(Random(-50, 50), Random(-50, 50))  ;* Pixels per second.

    , IsColliding: false}

;---------------- Test --------------------------------------------------------;
;--------------------------------------------------------  Log  ----------------;

;---------------  Other  -------------------------------------------------------;

if (!DllCall("User32\SetUserObjectInformationW", "Ptr", DllCall("Kernel32\GetCurrentProcess", "Ptr"), "Int", 7  ;? 7 = UOI_TIMERPROC_EXCEPTION_SUPPRESSION  ;~ Before using SetTimer or other timer-related functions, it is recommended to set the UOI_TIMERPROC_EXCEPTION_SUPPRESSION flag to false through the SetUserObjectInformationW function, otherwise the application could behave unpredictably and could be vulnerable to security exploits.
    , "UInt*", false, "UInt", 4, "UInt")) {  ;: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setuserobjectinformationw
    throw (ErrorFromMessage())
}

Start()

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

#HotIf (debug)

    ~*$RShift:: {
        if (!running) {
            Update(1000/Settings.TargetFPS)

            Draw()
        }

        KeyWait("RShift")
    }

    $#:: {
        if (!KeyWait("#", "T1")) {
            if (started) {
                Stop()
            }
            else {
                Start()
            }

            KeyWait("#")
        }
        else {
            Send("{#}")
        }
    }

#HotIf

;============== Function ======================================================;
;---------------- Hook --------------------------------------------------------;

MessageHandler(wParam, lParam, msg, hWnd) {
    switch (wParam) {
        case 0x1000:
            global debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")

            return (true)
    }

    return (-1)
}

ExitHandler(exitReason, exitCode) {
    Critical(true)

    Stop()

    global canvas := null
        , brush := null, pen := null

    GDIp.Shutdown()
}

;---------------- GDIp --------------------------------------------------------;  ;* All of the following code is based on this amazing tutorial: https://www.isaacsukin.com/news/2015/01/detailed-explanation-javascript-game-loops-and-timing.

WindowProc(hWnd, uMsg, wParam, lParam) {
    static WM_TIMER := 0x0113

    switch (uMsg) {
        case WM_TIMER:
            DllCall("User32\KillTimer", "Ptr", hWnd, "Ptr", 0, "UInt")

            MainLoop(GetTime())
    }

    return (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr"))
}

Start() {
    Critical(true)

    if (!started) {
        global started := true
            , discardTime := true

        Draw()

        DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", 10, "Ptr", 0, "Ptr")

        global running := true
    }
}

Stop() {
    Critical(true)

    if (running) {
        DllCall("User32\KillTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt")

        global running := false, started := false
    }
}

MainLoop(timestamp) {
    static previousTimestamp := 0  ;* The timestamp (in milliseconds) of the last time the main loop was run. Used to compute the time elapsed between frames.

    static minFrameDelay := 0  ;* The minimum amount of time (in milliseconds) that must pass since the last frame was executed before another frame can be executed.

    if (discardTime) {
        elapsed := 0

        previousFpsTimestamp := timestamp

        global discardTime := false
    }
    else if ((elapsed := timestamp - previousTimestamp) < minFrameDelay) {  ;* Throttle the frame rate if `minFrameDelay` is set to a non-zero value.
        return (DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", elapsed - 10, "Ptr", 0, "Ptr"))
    }

    previousTimestamp := timestamp

    ;=======================================================  Begin  ===============;  ;* Typically used to process input before the updates run. Processing input here (in chunks) can reduce the running time of event handlers, which is useful because long-running event handlers can sometimes delay frames.

    static keyboardHook := Hook(13, __LowLevelKeyboardProc)

    __LowLevelKeyboardProc(nCode, wParam, lParam) {
        Critical(true)

        injected := (NumGet(lParam + 8, "UInt") & 0x00000010) >> 4

        if (!nCode && !injected) {  ;? 0 = HC_ACTION
            static VK_CONTROL := 0x11, VK_PRIOR := 0x21, VK_NEXT := 0x22, VK_LEFT := 0x25, VK_UP := 0x26, VK_RIGHT := 0x27, VK_DOWN := 0x28, VK_F1 := 0x70, VK_F2 := 0x71, VK_F3 := 0x72, VK_F4 := 0x73, VK_F5 := 0x74, VK_F6 := 0x75

            static WM_KEYDOWN := 0x0100, WM_KEYUP := 0x0101

            switch (vkCode := NumGet(lParam, "UInt")) {  ;~ Virtual-Key Codes: https://docs.microsoft.com/en-gb/windows/win32/inputdev/virtual-key-codes?redirectedfrom=MSDN.
                case VK_LEFT:  ;? 0x25 = VK_LEFT
                    if (wParam == WM_KEYUP) {
                        cueAction.SlowFactor := 2
                    }

                    return (1)

                case VK_RIGHT:
                    if (wParam == WM_KEYUP) {
                        cueAction.SlowFactor := 0.5
                    }

                    return (1)

                case VK_CONTROL, 0xA2:
                    if (wParam == WM_KEYDOWN) {
                        ctrlIsDown := true
                            , ticksSinceLastFpsUpdate := Settings.TargetFPS
                    }

                    if (wParam == WM_KEYUP) {
                        ctrlIsDown := false

                        ToolTip()
                    }
            }
        }

        return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
    }

    static cueAction := {}  ;: https://snookerfreaks.com/perfecting-your-cue-action/

    if (ObjOwnPropCount(cueAction)) {
        Begin(cueAction)
    }

    static ctrlIsDown := false

    ;========================================================  FPS  ================;

    static previousFpsTimestamp := timestamp, fpsUpdateInterval := 1000  ;* The minimum duration between updates to the frames-per-second estimate. Higher values increase accuracy, but result in slower updates.
        , fpsAverage := Settings.TargetFPS

    if (timestamp - previousFpsTimestamp >= fpsUpdateInterval) {
        static fpsAlpha := Settings.FPSAlpha

        fpsAverage := fpsAlpha*fpsAverage + (1 - fpsAlpha)*framesSinceLastFpsUpdate, framesSinceLastFpsUpdate := 0  ;! timeSince := (timestamp - previousFpsTimestamp)/frequency, fpsAverage := fpsAlpha*framesSinceLastFpsUpdate*1000/timeSince + (1 - fpsAlpha)*fpsAverage, framesSinceLastFpsUpdate := 0  ;* An exponential moving average of the frames per second.

        if (debug && ctrlIsDown) {
            static averageTicks := Settings.TargetFPS

            averageTicks := fpsAlpha*averageTicks + (1 - fpsAlpha)*ticksSinceLastFpsUpdate, ticksSinceLastFpsUpdate := 0  ;! averageTicks := fpsAlpha*ticksSinceLastFpsUpdate*1000/timeSince + (1 - fpsAlpha)*averageTicks, ticksSinceLastFpsUpdate := 0

            ToolTip(fpsAverage . ", " . averageTicks . "`n" . timestamp - previousFpsTimestamp, 5, 5)
        }

        previousFpsTimestamp += fpsUpdateInterval
    }

    static framesSinceLastFpsUpdate := 0  ;* The number of frames delivered since the last time the fps moving average was updated (i.e. since `previousFpsTimestamp`).

    ++framesSinceLastFpsUpdate

    ;======================================================= Update ===============;

    static frameDelta := 0  ;* The cumulative amount of in-app time that hasn't been simulated yet.

    frameDelta += elapsed  ;* Track the accumulated time that hasn't been simulated yet. This approach avoids inconsistent rounding errors and ensures that there are no giant leaps between frames.

    static simulationTimestep := 1000/Settings.TargetFPS  ;* The amount of time (in milliseconds) to simulate each time `Update()` is called.

    slowStep := simulationTimestep*Settings.SlowFactor

    static ticksSinceLastFpsUpdate := Settings.TargetFPS  ;* The number of times `Update()` is called in a given frame.

    updateCount := 0  ;* The number of times `Update()` is called in a given frame.
        , panic := false  ;* Whether the simulation has fallen too far behind real time. Specifically, `panic` will be set to `true` if too many updates occur in one frame.

    while (frameDelta >= slowStep) {
        ++ticksSinceLastFpsUpdate

        static chunk := simulationTimestep*0.001

        Update(chunk)

        frameDelta -= slowStep

        if (++updateCount >= 240) {
            panic := true

            break
        }
    }

    ;======================================================= Render ===============;

    Draw(frameDelta/simulationTimestep)  ;* Render the screen. We do this regardless of whether `Update()` has run during this frame because it is possible to interpolate between updates to make the frame rate appear faster than updates are actually happening.

    ;========================================================  End  ================;  ;* Handles any updates that are not dependent on time in the simulation since it is always called exactly once at the end of every frame.

    if (panic) {
        Console.Clear()
        Console.Log("Panic!", 0xC)

        return (Stop())
    }

    static fpsThreshold := Settings.TargetFPS*0.6666666666666667

    if (fpsAverage < fpsThreshold) {
        Console.Log("Average fps has fallen below 2/3 of the target fps!", 0xE)

        minFrameDelay := 1000/Settings.MaxFPS
    }
    else if (minFrameDelay && fpsAverage >= fpsThreshold) {
        Console.Log("Average fps has recovered.", 0xA)

        minFrameDelay := 0
    }

    End(timestamp)

    ;==============================================================================;

    DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", 10, "Ptr", 0, "Ptr")
}

Begin(cueAction) {
    for variable, adjustment in cueAction.OwnProps() {
        switch (variable) {
            case "SlowFactor":
                Settings.SlowFactor *= adjustment
        }

        cueAction.DeleteProp(variable)
    }
}

/*
 * Simulates everything that is affected by time. It can be called zero or more times per frame depending on the frame rate.
 */
Update(delta) {
    point.PreviousPosition := point.Position.Clone()
        , point.Position.x += point.Velocity.x*delta, point.Position.y += point.Velocity.y*delta

    x := point.Position.x, y := point.Position.y
        , xOffset := point.Width*0.5, yOffset := point.Height*0.5

    if (x < xOffset) {  ;* Check for collision with the left and right of the canvas.
        point.Position.x := xOffset, point.Velocity.x *= -1
            , brush[0].Color := Color.Random()
    }
    else if (x > 300 - xOffset) {
        point.Position.x := 300 - xOffset, point.Velocity.x *= -1
            , brush[0].Color := Color.Random()
    }

    if (y < yOffset) {  ;* Check for collision with the top and bottom of the canvas.
        point.Position.y := yOffset, point.Velocity.y *= -1
            , brush[0].Color := Color.Random()
    }
    else if (y > 300 - yOffset) {
        point.Position.y := 300 - yOffset, point.Velocity.y *= -1
            , brush[0].Color := Color.Random()
    }
}

/*
 * A function that draws things on the screen.
 * @param {Number} [interpolation]
 *  The cumulative amount of time that hasn't been simulated yet, divided by the amount of time that will be simulated the next time `Update()` runs. Useful for interpolating frames.
 */
Draw(interpolation := 0) {
    x := point.Position.x, y := point.Position.y
        , width := point.Width, height := point.Height

    canvas.Graphics.FillRectangle(brush[0], point.PreviousPosition.x + (x - point.PreviousPosition.x)*interpolation - width*0.5, point.PreviousPosition.y + (y - point.PreviousPosition.y)*interpolation - height*0.5, width, height)
    canvas.Graphics.DrawLine(pen[1], x, y, x + point.Velocity.x, y + point.Velocity.y)

    ;==============================================================================;

    canvas.Update()
    canvas.Graphics.Clear()

    ;======================================================= Border ===============;

    canvas.Graphics.DrawRectangle(pen[0], 0, 0, 300, 300)
    canvas.Graphics.DrawEllipse(pen[0], 0, 0, 300, 300)
}

End(timestamp) {

}

;----------------  QPC  --------------------------------------------------------;

GetTime() {
    static frequency := (DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &(frequency := 0)), frequency/1000)  ;* Ticks-per-second.

    return (DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &(current := 0)), current/frequency)  ;~ No error handling as there is no reason for this to fail.
}

;===============  Class  =======================================================;

class Settings {
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
