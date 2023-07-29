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

if (!DllCall("User32\SetWindowPos", "Ptr", Console.Handle, "Ptr", -1  ;? -1 = HWND_TOPMOST
    , "Int", A_ScreenWidth - 815, "Int", 50, "Int", 450, "Int", 500, "UInt", 0x0080, "UInt")) {  ;? 0x0080 = SWP_HIDEWINDOW  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
    throw (ErrorFromMessage())
}

DllCall("User32\SetWindowLongPtr", "Ptr", Console.Handle, "Int", -20, "Ptr", DllCall("User32\GetWindowLongPtr", "Ptr", Console.Handle, "Int", -20, "Ptr") | 0x00000020)  ;? -20 = GWL_EXSTYLE, 0x00000020 = WS_EX_TRANSPARENT

if (!DllCall("User32\SetWindowPos", "Ptr", Console.Handle, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0027, "UInt")) {  ;? 0x0027 = SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
    throw (ErrorFromMessage())
}

WinSetStyle(-0x00E40000, Console.Handle)

#Include ..\..\lib\Color\Color.ahk
#Include ..\..\lib\Geometry.ahk
#Include ..\..\lib\Math\Math.ahk

;--------------  Setting  ------------------------------------------------------;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
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

;Run(A_ScriptDir . "\Secondary.ahk")

;---------------- GDIp --------------------------------------------------------;

GDIp.Startup()

global canvas := LayeredWindow(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, "Canvas", ["CS_HREDRAW", "CS_VREDRAW"], WindowProc, 32512, false, ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TOPMOST"], ["WS_CLIPCHILDREN", "WS_POPUPWINDOW"], 0, "SW_SHOWNOACTIVATE", 0xFF, 0x000E200B, 7, 4)
    , brush := [GDIp.CreateSolidBrush(Color("CadetBlue")), GDIp.CreateSolidBrush(Color("Crimson"))]
    , pen := [GDIp.CreatePen(0x80FFFFFF), GDIp.CreatePen(Color("DimGray"))]

global started := false, running := false
    , discardTime := false

global god := {x: 75, y: 75, h: 100, k: 100
        , Radius: 25

        , Color: {Get: (this) => (this.Pen.Color)}
        , Brush: GDIp.CreateSolidBrush(0xFFFFFFFF), Pen: GDIp.CreatePen(0xFFFFFFFF)

        , Worshippers: 0}
    , circles := Circle.CreateCircles(5, 15)

god.Pen.Color := Circle.GetColorOfLargestCircle()  ;* God likes them thick.

;---------------- Test --------------------------------------------------------;

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

    global god := "Dead"

    GDIp.Shutdown()
}

;---------------- GDIp --------------------------------------------------------;  ;* All of the following code is based on this amazing tutorial: https://www.isaacsukin.com/news/2015/01/detailed-explanation-javascript-game-loops-and-timing.

WindowProc(hWnd, uMsg, wParam, lParam) {
    Critical(true)

    switch (uMsg) {
        case 0x0113:  ;? 0x0113 = WM_TIMER
            DllCall("User32\KillTimer", "Ptr", hWnd, "Ptr", 0, "UInt")

            MainLoop(GetCounter())

        case 0x0201:  ;? 0x0201 = WM_LBUTTONDOWN
        case 0x0202:  ;? 0x0202 = WM_LBUTTONUP
            x := god.x, y := god.y
                , radius := god.Radius

            if (Math.IsBetween(lParam & 0xFFFF, x, x + radius*2) && Math.IsBetween(lParam >> 16, y, y + radius*2)) {
                Console.Log("God is angry! (forced)", 0xC)

                currentColor := Color("Crimson")
                    , god.Pen.Color := currentColor

                god.Pulse := {x: x, y: y
                    , Radius: radius

                    , Brush: GDIp.CreateSolidBrush(Format("{:#02x}", Math.Map(god.Worshippers, 1, circles.Length, 0x22, 0x7F)) . SubStr(Format("{:x}", currentColor), -6))

                    , Delta: 0}
            }
            else {
                for index, object in circles {
                    x := object.Position.x, y := object.Position.y
                        , radius := object.Radius

                    if (Math.IsBetween(lParam & 0xFFFF, x - radius, x + radius) && Math.IsBetween(lParam >> 16, y - radius, y + radius)) {
                        Console.Clear()

                        if (object.IsSuperTrooper) {
                            Console.Hide()

                            object.IsSuperTrooper := false
                        }
                        else {
                            circles.UnShift(circles.RemoveAt(index)), circles.ForEach((object, index, *) => (object.IsSuperTrooper := index == 0))  ;* Place the object that was clicked on at the beginning of the array to save on code later.
                        }

                        break
                    }
                }
            }

            return (1)
    }

    return (DllCall("User32\DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr"))
}

Start() {
    Critical(true)

    if (!started) {
        global started := true, discardTime := true

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
        , frequency := GetFrequency()/1000

    static minFrameDelay := 0  ;* The minimum amount of time (in milliseconds) that must pass since the last frame was executed before another frame can be executed.

    if (discardTime) {
        elapsed := 0

        previousFpsTimestamp := timestamp

        global discardTime := false
    }
    else if ((elapsed := (timestamp - previousTimestamp)/frequency) < minFrameDelay) {  ;* Throttle the frame rate (if `minFrameDelay` is set to a non-zero value).
        return (DllCall("User32\SetTimer", "Ptr", canvas.Handle, "Ptr", 0, "UInt", elapsed - 10, "Ptr", 0, "Ptr"))
    }

    previousTimestamp := timestamp

    ;=======================================================  Begin  ===============;  ;* Typically used to process input before the updates run. Processing input here (in chunks) can reduce the running time of event handlers, which is useful because long-running event handlers can sometimes delay frames.

    static keyboardHook := Hook(13, __LowLevelKeyboardProc)

    __LowLevelKeyboardProc(nCode, wParam, lParam) {
        Critical(true)

        injected := (NumGet(lParam + 8, "UInt") & 0x00000010) >> 4

        if (!nCode && !injected) {  ;? 0 = HC_ACTION
            static VK_CONTROL := 0x11, VK_LEFT := 0x25, VK_RIGHT := 0x25, VK_F1 := 0x70, VK_F2 := 0x71, VK_F3 := 0x72

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

                case VK_F2:
                    if (wParam == WM_KEYUP) {
                        cueAction.AddVelocity := true
                    }

                    return (1)

                case VK_F3:
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

            case "AddVelocity":
                for object in circles {
                    acceleration := Math.Map(object.Radius, 5, 25, 35, 10)

                    object.Velocity[0] += (Math.Random.Bool()) ? (-acceleration) : (acceleration), object.Velocity[1] += (Math.Random.Bool()) ? (-acceleration) : (acceleration)  ;! object.Velocity[0] += Random(0, Math.Sign(object.Velocity[0])*50), object.Velocity[1] += Random(0, Math.Sign(object.Velocity[1])*50)
                }
        }

        cueAction.DeleteProp(variable)
    }
}

Update(delta) {  ;* Simulates everything that is affected by time. It can be called zero or more times per frame depending on the frame rate.
    if (god.HasProp("Pulse")) {
        x := god.Pulse.x, y := god.Pulse.y
            radius := god.Pulse.Radius

        pulseDelta := god.Pulse.Delta

        god.Pulse.x := x + (0 - x)*pulseDelta, god.Pulse.y := y + (0 - y)*pulseDelta  ;* Interpolate between the top left of `god` and `canvas` (0, 0).
            god.Pulse.Radius += (150 - radius)*pulseDelta  ;* Interpolate for the radius also.

        god.Pulse.Delta += 0.0001  ;* ~5 seconds.

        if (god.Pulse.Radius >= 149) {
            god.DeleteProp("Pulse")

            circles.ForEach((object, *) => (object.DeleteProp("HandOfGod")))
        }
    }

    ;* Check if any object has made contact with anything and update their positions:
    for object in circles {
        x := object.Position[0], y := object.Position[1]
            , radius := object.Radius

        ;* Check if this object has made contact with `god`:
        if ((squaredDistance := (dx := x - god.h)**2 + (dy := y - god.k)**2) <= (radius + god.Radius)**2) {
            object.BounceBack(squaredDistance, dx, dy, (object.Color == god.Color) ? (1.15) : ((object.IsSuperTrooper) ? (1) : (0.85)), delta)
        }
        ;* Check if this object has made contact with the outer circle:
        else if ((squaredDistance := (dx := x - 149)**2 + (dy := y - 149)**2) > (150 - radius)**2) {
            static restitution := 0.95  ;* Set a restitution, a lower value will cause the loss of more energy when colliding.

            object.BounceBack(squaredDistance, dx, dy, (object.IsSuperTrooper) ? (1) : (restitution), delta)  ;* If `object.IsSuperTrooper` it will lose no energy.
        }

        object.Position[0] += object.Velocity[0]*delta, object.Position[1] += object.Velocity[1]*delta
    }

    ;* Check if any object has made contact with any other object:
    for index, object1 in circles {
        for object2 in circles.Slice(index + 1) {  ;* Only compare with objects after this one in the array as previous objects have already compared themselves to this one.
            x1 := object1.Position[0], y1 := object1.Position[1]
                , r1 := object1.Radius

            x2 := object2.Position[0], y2 := object2.Position[1]
                , r2 := object2.Radius

            if ((squareDistance := (x1 - x2)**2 + (y1 - y2)**2) <= (r1 + r2)**2) {  ;* When the distance is smaller or equal to the sum of the two radius, the circles touch or overlap.
                collision := Vec2(x2 - x1, y2 - y1), distance := Math.Sqrt(squareDistance)
                    , collisionNorm := Vec2(collision[0]/distance, collision[1]/distance), relativeVelocity := Vec2(object1.Velocity[0] - object2.Velocity[0], object1.Velocity[1] - object2.Velocity[1])

                if ((speed := (collisionNorm[0]*relativeVelocity[0] + collisionNorm[1]*relativeVelocity[1])*Math.Min(object1.Restitution, object2.Restitution)) < 0) {
                    continue
                }

                momentum1 := object1.Velocity.Magnitude*object1.Mass, momentum2 := object2.Velocity.Magnitude*object2.Mass

                if (momentum1 > momentum2) {
                    if (object1.Color != object2.Color) {
                        if (object1.IsSuperTrooper) {
                            Console.Log(momentum1 . " (" object1.Mass . ") > " momentum2 . " (" object2.Mass . ")", 0xA)
                        }
                        else if (object2.IsSuperTrooper) {
                            Console.Log(momentum2 . " (" object2.Mass . ") < " momentum1 . " (" object1.Mass . ")", 0xC)
                        }

                        object2.Color := object1.Color
                    }
                }
                else if (momentum2 > momentum1) {
                    if (object1.Color != object2.Color) {
                        if (object1.IsSuperTrooper) {
                            Console.Log(momentum1 . " (" object1.Mass . ") < " momentum2 . " (" object2.Mass . ")", 0xC)
                        }
                        else if (object2.IsSuperTrooper) {
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
        if (object.IsSuperTrooper) {
            radius := object.Radius, diameter := object.Diameter

            canvas.Graphics.DrawEllipse(GDIp.CreatePen(Color("Crimson"), 2), object.Position[0] - radius - 4, object.Position[1] - radius - 4, diameter + 10, diameter + 10)

            break
        }
    }

    if (god.HasProp("Pulse")) {
        diameter := god.Pulse.Radius*2

        canvas.Graphics.FillEllipse(god.Pulse.Brush, god.Pulse.x, god.Pulse.y, diameter, diameter)
    }

    x := god.x, y := god.y
        , diameter := god.Radius*2

    canvas.Graphics.FillEllipse(god.Brush, god.x, god.y, diameter, diameter)
    canvas.Graphics.DrawEllipse(god.Pen, god.x, god.y, diameter, diameter)

    ;==============================================================================;

    canvas.Update()
    canvas.Graphics.Clear()

    ;======================================================= Border ===============;

    canvas.Graphics.DrawEllipse(pen[0], 0, 0, 300, 300)
}

End(timestamp) {
    colors := Map()

    for object in circles {
        colors[object.Color] := colors.Has(object.Color) ? colors[object.Color] + 1 : 1
    }

    if (colors.Count == 1) {
        for object in circles {
            acceleration := Math.Map(object.Radius, 5, 25, 35, 10)

            object.Velocity[0] += (Math.Random.Bool()) ? (-acceleration) : (acceleration), object.Velocity[1] += (Math.Random.Bool()) ? (-acceleration) : (acceleration)
                , object.Color := Color.Random()
        }

        if (god.HasProp("Pulse")) {
            god.DeleteProp("Pulse")
        }

        god.Pen.Color := Circle.GetColorOfLargestCircle()

        Console.Clear()
    }
    else if (god.HasProp("Pulse")) {
        radius := god.Pulse.Radius

        for object in circles {
            if (!object.HasProp("HandOfGod") && (object.Position[0] - (god.Pulse.x + radius))**2 + (object.Position[1] - (god.Pulse.y + radius))**2 < (radius + object.Radius)**2) {  ;* `object.HandOfGod` tracks whether the object has already been in contact with this pulse.
                if (!object.IsSuperTrooper && object.Color != god.Color && Math.Random.Bool(Math.Map(object.Radius, 5, 25, 0.2, 0.05))) {  ;* The bigger the object, the less likely it is to be converted.
                    acceleration := Math.Map(object.Radius, 5, 25, 35, 10)

                    object.Velocity[0] := Math.Sign(object.Velocity[0])*(Math.Abs(object.Velocity[0]) + Random(5, acceleration)), object.Velocity[1] := Math.Sign(object.Velocity[1])*(Math.Abs(object.Velocity[1]) + Random(5, acceleration))  ;* Gets a burst of speed.
                        , object.Color := god.Pen.Color  ;* Becomes an angry zealot!
                }

                object.HandOfGod := true
            }
        }
    }
    else {
        currentColor := god.Pen.Color
            , count := (colors.Has(currentColor)) ? (colors[currentColor]) : (0)

        static lastTimeGodWasAngry := GetCounter()

        static length := circles.Length

        if (!count || (Math.IsBetween(count, 1, 5) && (passed := (timestamp - lastTimeGodWasAngry)) > 100000000 && !Math.Random(0, 2147483647 >> (22 - count - (passed > 200000000))))) {  ;* 20 second timeout between pulses.
            Console.Log("God is angry! (" . ((count) ? ("random") : ("no worshippers")) . ") " . (timestamp - lastTimeGodWasAngry)/GetFrequency(), 0xC)

            currentColor := Color("Crimson")
                , god.Pen.Color := currentColor

            god.Pulse := {x: god.x, y: god.y
                , Radius: god.Radius

                , Brush: GDIp.CreateSolidBrush(Format("{:#02x}", Math.Map(count, 1, length, 0x22, 0x7F)) . SubStr(Format("{:x}", currentColor), -6))

                , Delta: 0}

            lastTimeGodWasAngry := timestamp
        }

        if (god.Worshippers != count) {
            god.Worshippers := count
                , god.Brush.Color := Format("{:#02x}", Math.Map(count, 1, length, 0x22, 0x7F)) . SubStr(Format("{:x}", currentColor), -6)
        }
    }
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

    static CreateCircles(large, small) {
        circles := []

        loop large {
            loop {
                x := Random(0, 300), y := Random(0, 300)
                    , radius := Random(10, 25)

                if ((x - 149)**2 + (y - 149)**2 <= (150 - radius)**2 && (x - god.h)**2 + (y - god.k)**2 > (god.Radius + radius)**2) {
                    circles.Push(this(Vec2(x, y), Vec2(Random(-35, 35), Random(-35, 35)), radius))

                    break
                }
            }
        }

        loop small {
            loop {
                x := Random(0, 300), y := Random(0, 300)
                    , radius := Random(5, 10)

                if ((x - 149)**2 + (y - 149)**2 <= (150 - radius)**2 && (x - god.h)**2 + (y - god.k)**2 > (god.Radius + radius)**2) {
                    circles.Push(this(Vec2(x, y), Vec2(Random(-50, 50), Random(-50, 50)), radius))

                    break
                }
            }
        }

        return (circles)
    }

    static GetColorOfLargestCircle() {
        largest := circles[0]

        for object in circles {
            if (object.Radius > largest.Radius) {
                largest := object
            }
        }

        return (largest.Color)
    }

    __New(position, velocity, radius) {
        this.Position := position, this.Velocity := velocity
            , this.Radius := radius, this.Diameter := this.Radius*2

        this.Mass := Math.Round(Math.Exp(radius/5)*10)  ;* `27` (at 5) - `10966` (at 35)
            , this.Restitution := Math.Round(Math.Map(radius, 5, 25, 0.95, 0.80), 2)  ;* `0.95` (at 5) - `0.80` (at 25)

        this.Color := Color.Random()

        this.IsSuperTrooper := false, this.IsImmovable := false
    }

    IsMoving {
        Get {
            return (this.Velocity[0] || this.Velocity[1])
        }
    }

    BounceBack(squaredDistance, dx, dy, restitution, delta) {
        if (this.IsSuperTrooper) {
            angle := (((angle := DllCall("msvcrt\atan2", "Double", 149 - this.Position[1], "Double", 149 - this.Position[0], "Double")) <= 0) ? (angle + Math.Tau) : (angle)) + Math.Pi

            Console.Log(this.Velocity.Magnitude " (" . Mod(angle*(180/Math.Pi), 360) . ")", 0xF)
        }

        vx := this.Velocity[0], vy := this.Velocity[1]

        distance := Math.Sqrt(squaredDistance)
            , nx := -dx/distance, ny := -dy/distance  ;* Collision norm.

        dotProduct := vx*nx + vy*ny
            , this.Velocity[0] := (vx - nx*dotProduct*2)*restitution, this.Velocity[1] := (vy - ny*dotProduct*2)*restitution

        this.Position[0] += this.Velocity[0]*delta, this.Position[1] += this.Velocity[1]*delta  ;* Increment position here to avoid getting stuck if `this.Velocity` is too low.
    }
}
