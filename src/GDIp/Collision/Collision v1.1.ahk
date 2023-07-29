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
    , "Int", A_ScreenWidth - 800, "Int", 50, "Int", 435, "Int", 500, "UInt", 0x0080, "UInt")) {  ;? 0x0080 = SWP_HIDEWINDOW  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
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

global circles := []

loop 5 {
    circles.Push(Circle(Vec2(Random(25, 300 - 50), Random(25, 300 - 25)), Vec2(Random(-50, 50), Random(-50, 50)), Random(10, 25)))
}

loop 15 {
    circles.Push(Circle(Vec2(Random(10, 300 - 20), Random(10, 300 - 10)), Vec2(Random(-50, 50), Random(-50, 50)), Random(5, 10)))
}

;---------------- Test --------------------------------------------------------;

;---------------  Other  -------------------------------------------------------;

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

    GDIp.Shutdown()
}

;---------------- GDIp --------------------------------------------------------;  ;* All of the following code is based on this amazing tutorial: https://www.isaacsukin.com/news/2015/01/detailed-explanation-javascript-game-loops-and-timing.

WindowProc(hWnd, uMsg, wParam, lParam) {
    switch (uMsg) {
        case 0x0113:  ;? 0x0113 = WM_TIMER
            DllCall("User32\KillTimer", "Ptr", hWnd, "Ptr", 0, "UInt")

            MainLoop(GetCounter())

        case 0x0201:  ;? 0x0201 = WM_LBUTTONDOWN
            circles.ForEach((object, *) => (object.IsSuperTropper := false))

            for index, object in circles {
                x := object.Position.x, y := object.Position.y
                    , radius := object.Radius

                if (Math.IsBetween(lParam & 0xFFFF, x - radius, x + radius) && Math.IsBetween(lParam >> 16, y - radius, y + radius)) {
                    object.IsSuperTropper := true

                    circles.UnShift(circles.RemoveAt(index))

                    Console.Clear()

                    break
                }
            }
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

        if (!nCode) {  ;? 0 = HC_ACTION
            static WM_KEYDOWN := 0x0100, WM_KEYUP := 0x0101

            switch (vkCode := NumGet(lParam, "UInt")) {  ;~ Virtual-Key Codes: https://docs.microsoft.com/en-gb/windows/win32/inputdev/virtual-key-codes?redirectedfrom=MSDN.
                case 0x25:  ;? 0x25 = VK_LEFT
                    if (wParam == WM_KEYUP) {
                        cueAction.SlowFactor := 2
                    }

                    return (1)

                case 0x27:  ;? 0x27 = VK_RIGHT
                    if (wParam == WM_KEYUP) {
                        cueAction.SlowFactor := 0.5
                    }

                    return (1)

                case 0x51:
                    if (wParam == WM_KEYUP) {
                        cueAction.AddVelocity := true
                    }
            }
        }

        return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
    }

    static cueAction := {}  ;: https://snookerfreaks.com/perfecting-your-cue-action/

    for variable, adjustment in cueAction.OwnProps() {
        switch (variable) {
            case "SlowFactor":
                Settings.SlowFactor *= adjustment

            case "AddVelocity":
                for object in circles {
                    x := object.Velocity[0], y := object.Velocity[1]

                    object.Velocity[0] := Math.Sign(x)*(Math.Abs(x) + Random(0, 50)), object.Velocity[1] := Math.Sign(y)*(Math.Abs(y) + Random(0, 50))
                }
        }

        cueAction.DeleteProp(variable)
    }

    ;========================================================  FPS  ================;

    static previousFpsTimestamp := timestamp, fpsUpdateInterval := GetFrequency()  ;* The minimum duration between updates to the frames-per-second estimate. Higher values increase accuracy, but result in slower updates.

    if (timestamp > previousFpsTimestamp + fpsUpdateInterval) {
        static fpsAverage := Settings.TargetFPS , fpsAlpha := Settings.FPSAlpha

        fpsAverage := fpsAlpha*fpsAverage + (1 - fpsAlpha)*framesSinceLastFpsUpdate, framesSinceLastFpsUpdate := 0  ;! timeSince := (timestamp - previousFpsTimestamp)/frequency, fpsAverage := fpsAlpha*framesSinceLastFpsUpdate*1000/timeSince + (1 - fpsAlpha)*fpsAverage, framesSinceLastFpsUpdate := 0  ;* An exponential moving average of the frames per second.

        if (debug) {
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

    ;==============================================================================;

    DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", 10, "Ptr", 0, "Ptr")
}

Update(delta) {  ;* Simulates everything that is affected by time. It can be called zero or more times per frame depending on the frame rate.
    colors := Map()

    for object in circles {
        colors[object.Color] := colors.Has(object.Color) ? colors[object.Color] + 1 : 1
    }

    if (colors.Count == 1) {
        for object in circles {
            x := object.Velocity[0], y := object.Velocity[1]

            object.Velocity[0] := Math.Sign(x)*(Math.Abs(x) + Random(0, 50)), object.Velocity[1] := Math.Sign(y)*(Math.Abs(y) + Random(0, 50))
                , object.Color := Color.Random()

            object.IsSuperTropper := false

            Console.Clear()
            Console.Hide()
        }
    }

    for object in circles {
        x := object.Position[0], y := object.Position[1]
            , radius := object.Radius

        static restitution := 0.95  ;* Set a restitution, a lower value will cause the loss of more energy when colliding.

        if (x < radius) {  ;* Check for collision with the left and right of the canvas.
            object.Position[0] := radius, object.Velocity[0] *= -(object.IsSuperTropper) ? (-1) : (-restitution)  ;* Correct the position and then reverse velocity.
        }
        else if (x > 300 - radius) {
            object.Position[0] := 300 - radius, object.Velocity[0] *= -(object.IsSuperTropper) ? (-1) : (-restitution)
        }

        if (y < radius) {  ;* Check for collision with the top and bottom of the canvas.
            object.Position[1] := radius, object.Velocity[1] *= -(object.IsSuperTropper) ? (-1) : (-restitution)
        }
        else if (y > 300 - radius) {
            object.Position[1] := 300 - radius, object.Velocity[1] *= -(object.IsSuperTropper) ? (-1) : (-restitution)
        }

        object.Position[0] += object.Velocity[0]*delta, object.Position[1] += object.Velocity[1]*delta
    }

    for index, object1 in circles {
        if (!object1.IsMoving) {  ;* A ball that is not moving can't hit anything.
            MouseMove(canvas.x + object1.Position[0], canvas.y + object1.Position[1])

            MsgBox(Format("{} ({}) not moving.", index, object1.Velocity.Print()))

            break
        }

        for object2 in circles.Slice(index + 1) {
            x1 := object1.Position[0], y1 := object1.Position[1], r1 := object1.Radius
                , x2 := object2.Position[0], y2 := object2.Position[1], r2 := object2.Radius

            squareDistance := (x1 - x2)**2 + (y1 - y2)**2  ;* Calculate the distance between the two circles.

            if (squareDistance <= (r1 + r2)**2) {  ;* When the distance is smaller or equal to the sum of the two radius, the circles touch or overlap.
                collision := Vec2(x2 - x1, y2 - y1), distance := Math.Sqrt(squareDistance)
                    , collisionNorm := Vec2(collision[0]/distance, collision[1]/distance), relativeVelocity := Vec2(object1.Velocity[0] - object2.Velocity[0], object1.Velocity[1] - object2.Velocity[1])

                speed := (collisionNorm[0]*relativeVelocity[0] + collisionNorm[1]*relativeVelocity[1])*Math.Min(object1.Restitution, object2.Restitution)

                if (speed < 0) {
                    continue
                }

                momentum1 := object1.Velocity.Magnitude*object1.Mass, momentum2 := object2.Velocity.Magnitude*object2.Mass

                if (momentum1 > momentum2) {
                    if (object1.Color != object2.Color) {
                        if (object1.IsSuperTropper) {
                            Console.Log(momentum1 . " (" object1.Mass . ") > " momentum2 . " (" object2.Mass . ")", 0xA)
                        }
                        else if (object2.IsSuperTropper) {
                            Console.Log(momentum2 . " (" object2.Mass . ") < " momentum1 . " (" object1.Mass . ")", 0xC)
                        }

                        object2.Color := object1.Color
                    }
                }
                else if (momentum2 > momentum1) {
                    if (object1.Color != object2.Color) {
                        if (object1.IsSuperTropper) {
                            Console.Log(momentum1 . " (" object1.Mass . ") < " momentum2 . " (" object2.Mass . ")", 0xC)
                        }
                        else if (object2.IsSuperTropper) {
                            Console.Log(momentum2 . " (" object2.Mass . ") > " momentum1 . " (" object1.Mass . ")", 0xA)
                        }

                        object1.Color := object2.Color
                    }
                }

                impulse := 2*speed/(object1.Mass + object2.Mass)

                object1.Velocity[0] -= impulse*object2.Mass*collisionNorm[0], object1.Velocity[1] -= impulse*object2.Mass*collisionNorm[1]
                    , object2.Velocity[0] += impulse*object1.Mass*collisionNorm[0], object2.Velocity[1] += impulse*object1.Mass*collisionNorm[1]
            }
        }
    }
}

/*
* @param {Number} [interpolation]
*   The cumulative amount of time that hasn't been simulated yet, divided by the amount of time that will be simulated the next time `Update()` runs. Useful for interpolating frames.
*/
Draw(interpolation := 0) {  ;* A function that draws things on the screen.
    for object in circles {
        x := object.Position[0], y := object.Position[1]
            , radius := object.Radius, diameter := object.Diameter

        canvas.Graphics.FillEllipse(GDIp.CreateSolidBrush(object.Color), x - radius, y - radius, diameter, diameter)
        canvas.Graphics.DrawLine(pen[1], x, y, x + object.Velocity[0], y + object.Velocity[1])
    }

    for object in circles {
        if (object.IsSuperTropper) {
            radius := object.Radius, diameter := object.Diameter

            canvas.Graphics.DrawEllipse(GDIp.CreatePen(Color("Crimson"), 2), object.Position[0] - radius - 4, object.Position[1] - radius - 4, diameter + 10, diameter + 10)

            break
        }
    }

    ;==============================================================================;

    canvas.Update()
    canvas.Graphics.Clear()

    ;======================================================= Border ===============;

    canvas.Graphics.DrawRectangle(pen[0], 0, 0, 300, 300)
    canvas.Graphics.DrawEllipse(pen[0], 0, 0, 300, 300)
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

class Circle {
    __New(position, velocity, radius) {
        this.Position := position, this.Velocity := velocity
            , this.Radius := radius, this.Diameter := this.Radius*2

        this.Mass := Math.Round(Math.Exp(radius/5)*10)  ;* `27` (at 5) - `1484` (at 25)
            , this.Restitution := Math.Round(Math.Map(radius, 5, 25, 0.95, 0.75), 2)  ;* `0.95` (at 5) - `0.75` (at 25)

        this.Color := Color.Random()

        this.IsSuperTropper := false
    }

    IsMoving {
        Get {
            return (this.Velocity[0] || this.Velocity[1])
        }
    }
}
