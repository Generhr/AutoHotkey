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

#Include ..\..\lib\General\General.ahk
#Include ..\..\lib\Console\Console.ahk

#Include ..\..\lib\Color\Color.ahk
#Include ..\..\lib\Geometry.ahk
#Include ..\..\lib\Math\Math.ahk

;======================================================  Setting  ==============;

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

;======================================================== Menu ================;

TraySetIcon(A_WorkingDir . "\res\Image\Icon\0.ico")

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

    A_Null := Chr(0)

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;======================================================== GDIp ================;

GDIp.Startup()

Script.Canvas := LayeredWindow(A_ScreenWidth - (150*2 + 50 + 10), 50, 150*2, 150*2, className := "Canvas", ["CS_HREDRAW", "CS_VREDRAW"], windowProc := False, 32512, title := False, exStyle := ["WS_EX_LAYERED", "WS_EX_NOACTIVATE", "WS_EX_TOOLWINDOW", "WS_EX_TOPMOST"], style := ["WS_CLIPCHILDREN", "WS_POPUPWINDOW"], parent := 0, show := "SW_SHOWNOACTIVATE", alpha := 0xFF, pixelFormat := 0x000E200B, interpolation := 7, smoothing := 4)
    Script.Brush := [GDIp.CreateSolidBrush(Color.Random(0xFF)), GDIp.CreateLinearBrushFromRect(0, 0, Script.Canvas.Width, Script.Canvas.Height, Color("Honeydew"), Color("Sienna"), 2, 0)],
    Script.Pen := [GDIp.CreatePenFromBrush(Script.Brush[0]), GDIp.CreatePenFromBrush(Script.Brush[1])],

    Script.Border := {x: 0, y: 0, Width: 300, Height: 300},

    Script.SolarSystem := {h: Script.Canvas.Width/2,
        k: Script.Canvas.Height/2,

        Ratio: 1,
        Depth: 0,

        Planets: [],

        Date: 0}

Script.SolarSystem.Planets.Push(PlanetTemplate("Sun", Min(Script.Canvas.Width, Script.Canvas.Height)/10, 0, 0, 0, SolarSystem))  ;? (Name, Diameter, OrbitAngle, OrbitRadius, OrbitRevolution (in days), Parent)
loop (Math.Random.Normal(1, 5)) {
    SolarSystem.Planets.Push(PlanetTemplate(A_Index, Math.Random.Normal(10, SolarSystem.Planets[0].Diameter[0]*1.35), Math.Random.Uniform(0, 360), Math.Random.Uniform(SolarSystem.Planets[0].Diameter[0], Min(Script.Canvas.Width/2, Script.Canvas.Height/2)), Math.Random.Uniform(250, 2500), SolarSystem.Planets[0]))

    loop (Math.Random.Normal(-5, 3)) {
        SolarSystem.Planets.Push(PlanetTemplate(Round(SolarSystem.Planets[SolarSystem.Planets.Length - A_Index].Name + A_Index/10, 1), Math.Random.Normal(5, SolarSystem.Planets[SolarSystem.Planets.Length - A_Index].Diameter[0]*.5), Math.Random.Uniform(0, 360), Math.Random.Uniform(SolarSystem.Planets[SolarSystem.Planets.Length - A_Index].Diameter[0]*1.25, SolarSystem.Planets[SolarSystem.Planets.Length - A_Index].Diameter[0]*1.75), Math.Random.Uniform(35, 800), SolarSystem.Planets[SolarSystem.Planets.Length - A_Index]))
    }
}

Start()

;======================================================== Test ================;

;=======================================================  Other  ===============;

Exit()

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

;====================================================== Keyboard ==============;

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

#HotIf (A_Debug)

    ~*$RShift:: {
        if (!Script.Running) {
            Update(1000/Script.TargetFPS)

            Draw()
        }

        KeyWait("RShift")
    }

    $#:: {
        if (KeyWait("#", "T1")) {
            if (Script.Started) {
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

~$Left:: {
    Script.SlowFactor /= 2

    KeyWait("Left")
}

~$Right:: {
    Script.SlowFactor *= 2

    KeyWait("Right")
}

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

    if (Script.Running) {
        SetTimer(MainLoop, 0)
    }

    Script.Canvas := A_Null,
        Script.Brush := A_Null, Script.Pen := A_Null

    GDIp.Shutdown()
}

;======================================================== GDIp ================;  ;* All of the following code is based on this amazing tutorial: https://www.isaacsukin.com/news/2015/01/detailed-explanation-javascript-game-loops-and-timing.

Start() {
    Critical(True)

    if (!Script.Started) {
        Script.Started := True

        Draw()

        SetTimer(MainLoop.Bind(True), -1)

        Script.Running := True
    }
}

Stop() {
    Critical(True)

    if (Script.Running) {
        SetTimer(MainLoop, 0)

        Script.Running := False, Script.Started := False
    }
}

MainLoop(reset := False) {
    static previous := 0  ;* The timestamp of the last time the main loop was run. Used to compute the time elapsed between frames.

    current := GetCounter()

    static frequency := GetFrequency()/1000

    if (reset) {
        elapsed := 0

        previousFpsUpdate := current
    }
    else {
        static throttle := 1000/Script.MaxFPS

        if ((elapsed := (current - previous)/frequency) < throttle) {  ;* Throttle the frame rate.
            return (SetTimer(MainLoop, -elapsed))
        }
    }

    previous := current

    ;---------------  Begin  -------------------------------------------------------;

    Begin()  ;* Run any updates that are not dependent on time in the simulation.

    ;----------------  FPS  --------------------------------------------------------;

    static previousFpsUpdate := GetCounter()

    static averageTicks := Script.TargetFPS, alpha := Script.FPSAlpha,
        averageFrames := averageTicks/2

    static fpsUpdateInterval := GetFrequency()  ;* The minimum duration between updates to the frames-per-second estimate. Higher values increase accuracy, but result in slower updates.

    if (current > previousFpsUpdate + fpsUpdateInterval) {
        timeSince := current - previousFpsUpdate

        previousFpsUpdate += fpsUpdateInterval

        averageFrames := alpha*averageFrames + (1 - alpha)*frames, frames := 0,  ;* An exponential moving average of the frames per second.
            averageTicks := alpha*averageTicks + (1 - alpha)*ticks, ticks := 0

        if (A_Debug) {
            ToolTip(averageFrames . ", " . averageTicks . "`n" . timeSince/frequency, 50, 50, 20)
        }
    }

    static frames := 0

    ++frames

    ;--------------- Update -------------------------------------------------------;

    static delta := 0  ;* The cumulative amount of time that hasn't been simulated yet.

    delta += elapsed  ;* Track the accumulated time that hasn't been simulated yet. This approach avoids inconsistent rounding errors and ensures that there are no giant leaps between frames.

    static slowFactor := Script.SlowFactor,
        simulationTimestep := 1000/Script.TargetFPS, slowStep := simulationTimestep*slowFactor  ;* The amount of time (in milliseconds) to simulate each time `Update()` is called.

    static ticks := 0

    updateCount := 0,  ;* The number of times `Update()` is called in a given frame.
        panic := False

    while (delta >= slowStep) {
        ++ticks

        Update(simulationTimestep)

        delta -= slowStep

        if (++updateCount >= 240) {
            panic := True  ;* Indicates too many updates have taken place because the simulation has fallen too far behind real time.

            break
        }
    }

    ;--------------- Render -------------------------------------------------------;

    Draw(delta/simulationTimestep)  ;* Render the screen. We do this regardless of whether `Update()` has run during this frame because it is possible to interpolate between updates to make the frame rate appear faster than updates are actually happening.

    ;----------------  End  --------------------------------------------------------;

    End(panic, averageTicks, averageFrames)  ;* Run any updates that are not dependent on time in the simulation.

    SetTimer(MainLoop, -1)
}

Begin() {  ;* Typically used to process input before the updates run. Processing input here (in chunks) can reduce the running time of event handlers, which is useful because long-running event handlers can sometimes delay frames.

}

Update(delta) {  ;* Simulates everything that is affected by time. It can be called zero or more times per frame depending on the frame rate.

}

Draw(interpolation := 0) {  ;* A function that draws things on the screen.
    Script.Canvas.Clear()



    static x := Script.Border.x, y := Script.Border.y, width := Script.Border.Width, height := Script.Border.Height

    Script.Canvas.Graphics.DrawRectangle(Script.Pen[0], x, y, width, height)

    Script.Canvas.Update()
}

End(panic, averageTicks, averageFrames) {  ;* Handles any updates that are not dependent on time in the simulation since it is always called exactly once at the end of every frame.
    if (panic) {
        Console.Clear()
        Console.Log("Panic!")

        Stop()
    }

    if (!A_Debug) {
        if (averageFrames < 25) {
            ToolTip(averageTicks . ", " . averageFrames, 50, 50, 20)
        }
        else if (averageFrames > 30) {
            ToolTip(, , , 20)
        }
    }
}

;=======================================================  Other  ===============;

GetCounter() {
    DllCall("QueryPerformanceCounter", "Int64*", &(current := 0))

    return (current)
}

GetFrequency() {
    DllCall("QueryPerformanceFrequency", "Int64*", &(frequency := 0))

    return (frequency)
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
