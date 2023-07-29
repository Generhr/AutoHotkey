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
;DetectHiddenWindows(True)
ListLines(False)
Persistent(True)
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

global canvas := LayeredWindow(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, "Canvas", ["CS_HREDRAW", "CS_VREDRAW"], WindowProc, 32512, False, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TOPMOST"], ["WS_CLIPCHILDREN", "WS_POPUPWINDOW"], 0, "SW_SHOWNOACTIVATE", 0xFF, 0x000E200B, 7, 4)
    , brush := [GDIp.CreateSolidBrush(Color("CadetBlue")), GDIp.CreateSolidBrush(Color("Crimson"))]
    , pen := [GDIp.CreatePen(0x80FFFFFF), GDIp.CreatePen(Color("DimGray"))]

global started := False, running := False
    , reset := False

global circles := []

loop 2 {
    circles.Push(Circle(Vec2(Random(25, 300 - 50), Random(25, 300 - 25)), Vec2(Random(-50/1000, 50/1000), Random(-50/1000, 50/1000)), 25, 1000, 0.75))
}

loop 15 {
    circles.Push(Circle(Vec2(Random(10, 300 - 20), Random(10, 300 - 10)), Vec2(Random(-50/1000, 50/1000), Random(-50/1000, 50/1000)), 10, 5, 0.95))
}

Start()

;---------------- Test --------------------------------------------------------;

;---------------  Other  -------------------------------------------------------;

if (!DllCall("User32\SetUserObjectInformationW", "Ptr", DllCall("Kernel32\GetCurrentProcess", "Ptr"), "Int", 7  ;? 7 = UOI_TIMERPROC_EXCEPTION_SUPPRESSION
    , "UInt*", False, "UInt", 4, "UInt")) {  ;: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setuserobjectinformationw
    throw (ErrorFromMessage())
}

DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", 10, "Ptr", 0, "Ptr")  ;~ Before using SetTimer or other timer-related functions, it is recommended to set the UOI_TIMERPROC_EXCEPTION_SUPPRESSION flag to false through the SetUserObjectInformationW function, otherwise the application could behave unpredictably and could be vulnerable to security exploits.

Exit()

WindowProc(hWnd, uMsg, wParam, lParam) {
    switch (uMsg) {
        case 0x0113:  ;? 0x0113 = WM_TIMER
            DllCall("User32\KillTimer", "Ptr", hWnd, "Ptr", 0, "UInt")

            MainLoop(GetCounter())
    }

    return (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr"))
}

;=============== Hotkey =======================================================;
;---------------  Mouse  -------------------------------------------------------;

;-------------- Keyboard ------------------------------------------------------;

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

            return (True)
    }

    return (-1)
}

ExitHandler(exitReason, exitCode) {
    Critical(True)

    Stop()

    global canvas := null
        , brush := null, pen := null

    GDIp.Shutdown()
}

;---------------- GDIp --------------------------------------------------------;  ;* All of the following code is based on this amazing tutorial: https://www.isaacsukin.com/news/2015/01/detailed-explanation-javascript-game-loops-and-timing.

Start() {
    Critical(True)

    if (!started) {
        global started := True, reset := True

        Draw()

        DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", 10, "Ptr", 0, "Ptr")

        global running := True
    }
}

Stop() {
    Critical(True)

    if (running) {
        DllCall("User32\KillTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt")

        global running := False, started := False
    }
}

MainLoop(timestamp) {
    static previous := 0  ;* The timestamp of the last time the main loop was run. Used to compute the time elapsed between frames.

    static frequency := GetFrequency()/1000

    if (reset) {
        elapsed := 0

        previousFpsUpdate := timestamp

        global reset := False
    }
    else {
        elapsed := (timestamp - previous)/frequency

;       static throttle := 1000/Settings.MaxFPS
;
;       if ((elapsed := (timestamp - previous)/frequency) < throttle) {  ;* Throttle the frame rate.
;           return (DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", elapsed, "Ptr", 0, "Ptr"))
;       }
    }

    previous := timestamp

    ;=======================================================  Begin  ===============;  ;* Typically used to process input before the updates run. Processing input here (in chunks) can reduce the running time of event handlers, which is useful because long-running event handlers can sometimes delay frames.

    static keyboardHook := Hook(13, __LowLevelKeyboardProc)

    __LowLevelKeyboardProc(nCode, wParam, lParam) {
        Critical(True)

        if (!nCode) {  ;? 0 = HC_ACTION
            static WM_KEYDOWN := 0x0100, WM_KEYUP := 0x0101

            switch (vkCode := NumGet(lParam, "UInt")) {  ;~ Virtual-Key Codes: https://docs.microsoft.com/en-gb/windows/win32/inputdev/virtual-key-codes?redirectedfrom=MSDN.
                case 0x25:  ;? 0x25 = VK_LEFT
                    if (wParam == WM_KEYUP) {
                        action.SlowFactor := 2
                    }

                    return (1)

                case 0x27:  ;? 0x27 = VK_RIGHT
                    if (wParam == WM_KEYUP) {
                        action.SlowFactor := 0.5
                    }

                    return (1)
            }
        }

        return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
    }

    static action := {}

    for variable, adjustment in action.OwnProps() {
        switch (variable) {
            case "SlowFactor":
                Settings.SlowFactor *= adjustment
        }

        action.DeleteProp(variable)
    }

    ;========================================================  FPS  ================;

    static previousFpsUpdate := GetCounter(), fpsUpdateInterval := GetFrequency()  ;* The minimum duration between updates to the frames-per-second estimate. Higher values increase accuracy, but result in slower updates.

    if (timestamp > previousFpsUpdate + fpsUpdateInterval) {
        static averageFrames := Settings.TargetFPS, alpha := Settings.FPSAlpha

        averageFrames := alpha*averageFrames + (1 - alpha)*frames, frames := 0  ;! timeSince := (timestamp - previousFpsUpdate)/frequency, averageFrames := alpha*frames*1000/timeSince + (1 - alpha)*averageFrames, frames := 0  ;* An exponential moving average of the frames per second.

        if (debug) {
            static averageTicks := Settings.TargetFPS

            averageTicks := alpha*averageTicks + (1 - alpha)*ticks, ticks := 0  ;! averageTicks := alpha*ticks*1000/timeSince + (1 - alpha)*averageTicks, ticks := 0

            ToolTip(averageFrames . ", " . averageTicks . "`n" . (timestamp - previousFpsUpdate)/frequency, 50, 50, 20)
        }

        previousFpsUpdate += fpsUpdateInterval
    }

    static frames := 0

    ++frames

    ;======================================================= Update ===============;

    static delta := 0  ;* The cumulative amount of time that hasn't been simulated yet.

    delta += elapsed  ;* Track the accumulated time that hasn't been simulated yet. This approach avoids inconsistent rounding errors and ensures that there are no giant leaps between frames.

    static simulationTimestep := 1000/Settings.TargetFPS  ;* The amount of time (in milliseconds) to simulate each time `Update()` is called.

    slowStep := simulationTimestep*Settings.SlowFactor

    static ticks := 0

    updateCount := 0  ;* The number of times `Update()` is called in a given frame.
        , panic := False

    while (delta >= slowStep) {
        ++ticks

        Update(simulationTimestep)

        delta -= slowStep

        if (++updateCount >= 240) {
            panic := True  ;* Indicates too many updates have taken place because the simulation has fallen too far behind real time.

            break
        }
    }

    ;======================================================= Render ===============;

    Draw(delta/simulationTimestep)  ;* Render the screen. We do this regardless of whether `Update()` has run during this frame because it is possible to interpolate between updates to make the frame rate appear faster than updates are actually happening.

    ;========================================================  End  ================;  ;* Handles any updates that are not dependent on time in the simulation since it is always called exactly once at the end of every frame.

    if (panic) {
        Console.Clear()
        Console.Log("Panic!")

        Stop()
    }

    if (!debug) {
        if (averageFrames < 25) {
            ToolTip(averageFrames, 50, 50, 20)
        }
        else if (averageFrames > 30) {
            ToolTip(, , , 20)
        }
    }

    ;==============================================================================;

    DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", 10, "Ptr", 0, "Ptr")
}

Update(delta) {  ;* Simulates everything that is affected by time. It can be called zero or more times per frame depending on the frame rate.
    for object in circles {
        object.IsColliding := False  ;* Reset collision state of all objects.

        static restitution := 0.90  ;* Set a restitution, a lower value will cause the loss of more energy when colliding.

        x := object.Position.x, y := object.Position.y, radius := object.Radius

        if (x < radius) {  ;* Check for collision with the left and right of the canvas.
            object.Position.x := radius, object.Magnitude.x *= -restitution
                , object.IsColliding := True
        }
        else if (x > 300 - radius) {
            object.Position.x := 300 - radius, object.Magnitude.x *= -restitution
                , object.IsColliding := True
        }

        if (y < radius) {  ;* Check for collision with the top and bottom of the canvas.
            object.Position.y := radius, object.Magnitude.y *= -restitution
                , object.IsColliding := True
        }
        else if (y > 300 - radius) {
            object.Position.y := 300 - radius, object.Magnitude.y *= -restitution
                , object.IsColliding := True
        }

        object.Position.Add(Vec2.MultiplyScalar(object.Magnitude, delta))
    }

    for index, object1 in circles {
        for object2 in circles.Slice(index + 1) {
            x1 := object1.Position.x, y1 := object1.Position.y, r1 := object1.Radius
                , x2 := object2.Position.x, y2 := object2.Position.y, r2 := object2.Radius

            squareDistance := (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)  ;* Calculate the distance between the two circles.

            if (squareDistance <= (r1 + r2)*(r1 + r2)) {  ;* When the distance is smaller or equal to the sum of the two radius, the circles touch or overlap.
                object1.IsColliding := True, object2.IsColliding := True

                collision := Vec2(x2 - x1, y2 - y1), distance := Math.Sqrt(squareDistance)
                    , collisionNorm := Vec2(collision.x/distance, collision.y/distance), relativeVelocity := Vec2(object1.Magnitude.x - object2.Magnitude.x, object1.Magnitude.y - object2.Magnitude.y)

                speed := (collisionNorm.x*relativeVelocity.x + collisionNorm.y*relativeVelocity.y)*Math.Min(object1.Restitution, object2.Restitution)

                if (speed < 0) {
                    break
                }

                impulse := 2*speed/(object1.Mass + object2.Mass)

                object1.Magnitude.x -= impulse*object2.Mass*collisionNorm.x, object1.Magnitude.y -= impulse*object2.Mass*collisionNorm.y
                    , object2.Magnitude.x += impulse*object1.Mass*collisionNorm.x, object2.Magnitude.y += impulse*object1.Mass*collisionNorm.y
            }
        }
    }
}

Draw(interpolation := 0) {  ;* A function that draws things on the screen.
    for object in circles {
        x := object.Position.x, y := object.Position.y, r := object.Radius

        canvas.Graphics.FillEllipse(brush[object.IsColliding], x - r, y - r, object.Diameter, object.Diameter)
        canvas.Graphics.DrawLine(pen[1], x, y, x + object.Magnitude.x*1000, y + object.Magnitude.y*1000)
    }

    ;======================================================= Border ===============;

    canvas.Graphics.DrawRectangle(pen[0], 0, 0, 300, 300)
    canvas.Graphics.DrawEllipse(pen[0], 5, 5, 300 - 10, 300 - 10)

    ;==============================================================================;

    canvas.Update()
    canvas.Graphics.Clear()
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
    __New(position, magnitude, radius, mass, restitution) {
        this.Position := position, this.Magnitude := magnitude
            , this.Radius := radius, this.Diameter := this.Radius*2

        this.Mass := mass || 5, this.Restitution := restitution

        this.IsColliding := False
    }
}
