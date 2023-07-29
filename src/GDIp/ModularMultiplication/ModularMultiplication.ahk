#Requires AutoHotkey v2.0-beta.12

;============ Auto-Execute ====================================================;
;---------------  Admin  -------------------------------------------------------;

if (!A_IsAdmin || !DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)") {
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

if (!DllCall("User32\SetWindowPos", "Ptr", Console.Handle, "Ptr", -1  ;? -1 = HWND_TOPMOST
    , "Int", A_ScreenWidth - 815, "Int", 50, "Int", 450, "Int", 500, "UInt", 0x0080, "UInt")) {  ;? 0x0080 = SWP_HIDEWINDOW  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
    throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
}

DllCall("User32\SetWindowLongPtr", "Ptr", Console.Handle, "Int", -20, "Ptr", DllCall("User32\GetWindowLongPtr", "Ptr", Console.Handle, "Int", -20, "Ptr") | 0x00000020)  ;? -20 = GWL_EXSTYLE, 0x00000020 = WS_EX_TRANSPARENT

if (!DllCall("User32\SetWindowPos", "Ptr", Console.Handle, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0027, "UInt")) {  ;? 0x0027 = SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
    throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
}

if (!DllCall("User32\SetUserObjectInformationW", "Ptr", DllCall("Kernel32\GetCurrentProcess", "Ptr"), "Int", 7  ;? 7 = UOI_TIMERPROC_EXCEPTION_SUPPRESSION
    , "UInt*", false, "UInt", 4, "UInt")) {  ;: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setuserobjectinformationw
    throw (ErrorFromMessage())
}

WinSetStyle(-0x00E40000, Console.Handle)

#Include ..\..\lib\Color\Color.ahk
#Include ..\..\lib\Geometry.ahk
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

for v in [
    "Core.ahk"
        , "Array.ahk", "Object.ahk", "String.ahk", "Buffer.ahk"

        , "Direct2D.ahk", "DirectWrite.ahk", "GDI.ahk", "GDIp.ahk", "WIC.ahk"

    , "General.ahk", "Assert.ahk", "Console.ahk"

    , "Color.ahk"
    , "Geometry.ahk"
        , "Vec2.ahk", "Vec3.ahk", "TransformMatrix.ahk", "RotationMatrix.ahk", "Matrix3.ahk", "Ellipse.ahk", "Rect.ahk"
    , "Math.ahk"] {
    GroupAdd("Library", v)
}

;-------------- Variable ------------------------------------------------------;

global debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
    , windowMessage := DllCall("User32\RegisterWindowMessage", "Str", "WindowMessage", "UInt")

    , null := Chr(0)

;---------------- Hook --------------------------------------------------------;

OnMessage(windowMessage, WindowMessageHandler)

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

global sectors := 200, multiplier := 2.00, colorSetting := "Solid"
    , lines := []

loop (index := 0, sectors) {
    lines.Push(Line(Vec2(), Vec2(), index++*(-6.283185307179587/sectors)))
}

;---------------- Test --------------------------------------------------------;

;---------------  Other  -------------------------------------------------------;

if (!DllCall("User32\SetUserObjectInformationW", "Ptr", DllCall("Kernel32\GetCurrentProcess", "Ptr"), "Int", 7  ;? 7 = UOI_TIMERPROC_EXCEPTION_SUPPRESSION
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

WindowMessageHandler(wParam, lParam, msg, hWnd) {
    switch (wParam) {
        case 0x1000:
            debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")

            return (true)
    }

    return (-1)
}

ExitHandler(exitReason, exitCode) {
    Critical(true)

    Stop()

    global canvas := null
        , brush := null, pen := null

    global lines := null

    GDIp.Shutdown()
}

;---------------- GDIp --------------------------------------------------------;  ;* All of the following code is based on this amazing tutorial: https://www.isaacsukin.com/news/2015/01/detailed-explanation-javascript-game-loops-and-timing.

WindowProc(hWnd, uMsg, wParam, lParam) {
    switch (uMsg) {
        case 0x0113:  ;? 0x0113 = WM_TIMER
            DllCall("User32\KillTimer", "Ptr", hWnd, "Ptr", 0, "UInt")

            MainLoop(GetCounter())
    }

    return (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr"))
}

Start() {
    Critical(true)

    if (!started) {
        global started := true, discardTime := true

        Draw()

        DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", 10, "Ptr", 0, "Ptr")  ;~ Before using SetTimer or other timer-related functions, it is recommended to set the UOI_TIMERPROC_EXCEPTION_SUPPRESSION flag to false through the SetUserObjectInformationW function, otherwise the application could behave unpredictably and could be vulnerable to security exploits.

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
        , frequency := GetFrequency()/1000

    static minFrameDelay := 0  ;* The minimum amount of time (in milliseconds) that must pass since the last frame was executed before another frame can be executed.

    if (discardTime) {
        elapsed := 0

        previousFpsTimestamp := timestamp

        global discardTime := false
    }
    else {
        if ((elapsed := (timestamp - previousTimestamp)/frequency) < minFrameDelay) {  ;* Throttle the frame rate (if `minFrameDelay` is set to a non-zero value).
            return (DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", elapsed - 10, "Ptr", 0, "Ptr"))
        }
    }

    previousTimestamp := timestamp

    ;=======================================================  Begin  ===============;  ;* Typically used to process input before the updates run. Processing input here (in chunks) can reduce the running time of event handlers, which is useful because long-running event handlers can sometimes delay frames.

    static keyboardHook := Hook(13, __LowLevelKeyboardProc)

    __LowLevelKeyboardProc(nCode, wParam, lParam) {
        Critical(true)

        flags := NumGet(lParam + 8, "UInt")
            , injected := (flags & 0x00000010) >> 4

        if (!nCode && !injected) {  ;? 0 = HC_ACTION
            static VK_CONTROL := 0x11, VK_LEFT := 0x25, VK_RIGHT := 0x25, VK_F1 := 0x70, VK_F2 := 0x71, VK_F3 := 0x72

            static WM_KEYDOWN := 0x0100, WM_KEYUP := 0x0101

            switch (NumGet(lParam, "UInt")) {  ;~ Virtual-Key Codes: https://docs.microsoft.com/en-gb/windows/win32/inputdev/virtual-key-codes?redirectedfrom=MSDN.
                case VK_LEFT:
                    if (wParam == WM_KEYUP) {
                        cueAction.SlowFactor := 2
                    }

                    return (1)

                case VK_RIGHT:
                    if (wParam == WM_KEYUP) {
                        cueAction.SlowFactor := 0.5
                    }

                    return (1)

                case VK_F1:
                    return (1)

                case VK_F2:
                    return (1)

                case VK_F3:
                    static toggle := false

                    if (wParam == WM_KEYUP) {
                        cueAction.ChangeColor := true

                        static lookUp := Map("Solid", "Distance Color", "Distance Color", "Distance Alpha", "Distance Alpha", "Solid")

                        global colorSetting := lookUp[colorSetting]
                    }

                    return (1)

                case VK_CONTROL, 0xA2:
                    if (wParam == WM_KEYDOWN) {
                        ctrlIsDown := true
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
        , ctrlIsDown := false

    Begin(cueAction)

    ;========================================================  FPS  ================;

    static previousFpsTimestamp := timestamp, fpsUpdateInterval := GetFrequency()  ;* The minimum duration between updates to the frames-per-second estimate. Higher values increase accuracy, but result in slower updates.
        , fpsAverage := Settings.TargetFPS

    if (timestamp > previousFpsTimestamp + fpsUpdateInterval) {
        static fpsAlpha := Settings.FPSAlpha

        fpsAverage := fpsAlpha*fpsAverage + (1 - fpsAlpha)*framesSinceLastFpsUpdate, framesSinceLastFpsUpdate := 0  ;! timeSince := (timestamp - previousFpsTimestamp)/frequency, fpsAverage := fpsAlpha*framesSinceLastFpsUpdate*1000/timeSince + (1 - fpsAlpha)*fpsAverage, framesSinceLastFpsUpdate := 0  ;* An exponential moving average of the frames per second.

        if (debug && ctrlIsDown) {
            static averageTicks := Settings.TargetFPS

            averageTicks := fpsAlpha*averageTicks + (1 - fpsAlpha)*ticksSinceLastFpsUpdate, ticksSinceLastFpsUpdate := 0  ;! averageTicks := fpsAlpha*ticksSinceLastFpsUpdate*1000/timeSince + (1 - fpsAlpha)*averageTicks, ticksSinceLastFpsUpdate := 0

            ToolTip(fpsAverage . ", " . averageTicks . "`n" . (timestamp - previousFpsTimestamp)/frequency, 5, 5)
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

    static ticksSinceLastFpsUpdate := 0  ;* The number of times `Update()` is called in a given frame.

    updateCount := 0  ;* The number of times `Update()` is called in a given frame.
        , panic := false  ;* Whether the simulation has fallen too far behind real time. Specifically, `panic` will be set to `true` if too many updates occur in one frame.

    while (frameDelta >= slowStep) {
        ++ticksSinceLastFpsUpdate

        Update(simulationTimestep*0.001)

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
        Console.Log("Panic!")

        Stop()
    }

    if (!debug) {
        static fpsThreshold := Settings.TargetFPS*0.5

        if (fpsAverage < fpsThreshold) {
            ToolTip(fpsAverage, 50, 50, 20)

            minFrameDelay := 1000/Settings.MaxFPS
        }
        else if (fpsAverage > 30) {
            ToolTip(, , , 20)

            minFrameDelay := 0
        }
    }

    End(panic, fpsAverage)

    ;==============================================================================;

    DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", 10, "Ptr", 0, "Ptr")
}

Begin(cueAction) {
    for variable, adjustment in cueAction.OwnProps() {
        switch (variable) {
            case "SlowFactor":
                Settings.SlowFactor *= adjustment

            case "ChangeColor":
                static diameter := 300

                switch (colorSetting) {
                    case "Solid":
                        lines.ForEach((line, *) => (line.Pen.Color := 0xFFFFFFFF))
                    case "Distance Alpha":
                        ;* Calculate the distance between the start and end of the line and translate that into a range of 0 -> 255:
                        lines.ForEach((line, *) => (line.GetColor := (this) => (Format("0x{:02X}{:X}", Abs(Floor(Sqrt((this.End[0] - this.Start[0])**2 + (this.End[1] - this.Start[1])**2)/diameter*255) - 255), 0xFFFFFF))))
                    case "Distance Color":
                        ;* Calculate the distance between the start and end of the line and translate that into a range of 0 -> 240 with an offset to have red (160) at the center and then to a range of 0 -> 255:
                        lines.ForEach((line, *) => (line.GetColor := (this) => (Format("{:#X}{:06X}", 0xFF, DllCall("shlwapi\ColorHLSToRGB", "UInt", (v := Floor(Sqrt((this.End[0] - this.Start[0])**2 + (this.End[1] - this.Start[1])**2)/diameter*240) + 160) + ((v > 240) ? (-240) : (0)), "UInt", 120, "UInt", 240)))))
;                   case "Oscillate Color":
;                       ;* Calculate values for the R, G and B components with out of sync sine waves and translate that to a range of 0 -> 255:
;                       v := f*i + phase
;                           , Pen[1].Color := Format("{:#X}{:02X}{:02X}{:02X}", 255, Sin(v)*127.5 + 127.5, Sin(v + 2.094395102393196)*127.5 + 127.5, Sin(v + 4.188790204786391)*127.5 + 127.5)
;                   case "*":
;                       v := f*i + phase
;                           , Pen[1].Color := Format("{:#X}{:02X}{:02X}{:02X}", 255, Sin(v)*127.5 + 127.5, Sin(v + 2.094395102393196)*127.5 + 127.5, Sin(v + 4.188790204786391)*127.5 + 127.5)
;
;                           , v := Sin(v - phase)*25
;
;                       Canvas2.DrawRectangle(Pen[1], {"x": x + i*r, "y": y + (v < 1)*v, "Width": r*1.25, "Height": Abs(v)})
                }
        }

        cueAction.DeleteProp(variable)
    }
}

Update(delta) {  ;* Simulates everything that is affected by time. It can be called zero or more times per frame depending on the frame rate.
    global multiplier := (multiplier == 500) ? (0) : (multiplier + delta)

    static radius := 150

    for line in lines {
        angle := line.Angle
            , line.Start[0] := radius*Cos(angle), line.Start[1] := radius*Sin(angle)

        angle *= Mod(multiplier, sectors)
            , line.End[0] := radius*Cos(angle), line.End[1] := radius*Sin(angle)
    }
}

/*
* @param {Number} [interpolation]
*   The cumulative amount of time that hasn't been simulated yet, divided by the amount of time that will be simulated the next time `Update()` runs. Useful for interpolating frames.
*/
Draw(interpolation := 0) {  ;* A function that draws things on the screen.
    canvas.Graphics.TranslateTransform(150, 150)

    switch (colorSetting) {
        case "Solid":
            lines.ForEach((line, *) => (canvas.Graphics.DrawLine(line.Pen, line.Start[0], line.Start[1], line.End[0], line.End[1])))

;           static struct := Buffer(lines.Length*16)
;
;           for index, line in lines {
;               struct.NumPut(index*16, "Float", line.Start[0], "Float", line.Start[1], "Float", line.End[0], "Float", line.End[1])
;           }
;
;           if (status := DllCall("Gdiplus\GdipDrawLines", "Ptr", canvas.Graphics.Ptr, "Ptr", Pen[0].Ptr, "Ptr", struct.Ptr, "UInt", lines.Length*2, "Int")) {
;               throw (ErrorFromStatus(status))
;           }
        default:
            lines.ForEach((line, *) => (canvas.Graphics.DrawLine(line.GetPen(), line.Start[0], line.Start[1], line.End[0], line.End[1])))
    }

    ;==============================================================================;

    canvas.Update()
    canvas.Graphics.Clear()

    ;======================================================= Border ===============;

    canvas.Graphics.ResetTransform()
    canvas.Graphics.DrawEllipse(pen[0], 0, 0, 300, 300)
}

End(panic, fpsAverage) {
}

;---------- Queryperformance --------------------------------------------------;

GetCounter() {
    DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &(current := 0))

    return (current)
}

GetFrequency() {
    DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &(frequency := 0))

    return (frequency)
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

class Line {
    __New(start, end, angle, color := 0xFFFFFFFF) {
        this.Start := start, this.End := end
            , this.Angle := angle

        this.Pen := GDIp.CreatePen(color)
            , this.GetColor := (*) => (color), this.GetPen := (this) => (this.Pen.Color := this.GetColor(), this.Pen)
    }
}
