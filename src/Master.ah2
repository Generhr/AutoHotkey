;============ Auto-Execute ====================================================;

#Requires AutoHotkey v2.0-beta

;=======================================================  Admin  ===============;

if (!A_IsAdmin || !DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)") {
	try {
		Run(Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (Format("{} /restart `"{}`"", A_AhkPath, A_ScriptFullPath))))
	}

	ExitApp
}

;======================================================  Include  ==============;

#Include %A_ScriptDir%\..\lib\Core.ah2

#Include %A_ScriptDir%\..\lib\General\General.ah2
#Include %A_ScriptDir%\..\lib\Console\Console.ah2

#Include %A_ScriptDir%\..\lib\OCR.ah2

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
ProcessSetPriority("High")
SetCapsLockState(("AlwaysOff"))
SetNumlockState("AlwaysOn")
SetScrollLockState("AlwaysOff")
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..")

;======================================================== Menu ================;

TraySetIcon("mstscax.dll", 10)	;: https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/

;Menu, Tray, NoStandard
;for k, v in {"Case": ["", "[&1] lowercase", "[&2] UPPERCASE", "[&3] Sentence case", "[&4] Title Case", "", "[&5] iNVERSE", "[&6] Reverse", ""], "Tray": ["", "[&1] Edit", "[&2] Open Script Folder", "[&3] Window Spy", "[&4] List Lines", "[&5] List Vars", "[&6] List Hotkeys", "[&7] KeyHistory", "", "[&8] Pause", "[&9] Suspend", "", "[10] Restore All", "[11] Exit", ""]} {
;	for i, v in v {
;		Menu, % k, Add, % v, Menu
;	}
;}

;=======================================================  Group  ===============;

for k, v in Map("Browser", [["Google Chrome ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe"]],	;? [["Title ahk_class ClassName ahk_exe ProcessName", "ExcludeTitle"], ...]
	"Editor", [["Notepad++ ahk_class Notepad++ ahk_exe notepad++.exe"], ["ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe"], ["Microsoft Visual Studio ahk_exe devenv.exe"]],
	"Escape", [["ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe", "Calculator"], ["Help ahk_class HH Parent ahk_exe hh.exe"], ["ahk_class MediaPlayerClassicW ahk_exe mpc-hc64.exe"], ["Windows Photo Viewer ahk_class Photo_Lightweight_Viewer ahk_exe DllHost.exe"], ["Window Spy ahk_class AutoHotkeyGUI"]]) {
	for i, v in v {
		try {
			GroupAdd(k, v[0], , v[1])
		}
		catch {
			GroupAdd(k, v[0])
		}
	}
}

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

, A_SavedClipboard, A_CapsLockState := False
, A_HiddenWindows := []
, A_Null := Chr(0)

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;========================================================  Run  ================;

;for v in ["AutoCorrect", "Connection", "Window"] {
for v in ["AutoCorrect"] {
	Run(A_ScriptDir . "\" . v . ".ah2")
}

;=======================================================  Other  ===============;

if ((v := DownloadContent("https://autohotkey.com/download/2.0/version.txt")) != A_AhkVersion) {
	Console.Log(Format("New AHK version: {}", v))
}

exit

;q:: {
;	s := String.Buffer(Format("{:T}", String.Copy()), ";", "=", 80, 60, 1)
;
;	Send("{Home}+{End}")
;	String.Paste(s)
;}

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

#HotIf ((WinActive("ahk_group Editor") || WinActive("ahk_group Browser")) && !WinActive("ahk_group Game"))

~$WheelDown::
~$WheelUp:: {
	if (A_TimeSincePriorHotkey && A_TimeSincePriorHotkey >= 50 && MouseGet("Pos", "Window").y <= 80 + 30*(WinActive("ahk_group Browser") > 0)) {
		static keyCombination := Map("WheelUp", "^{PgUp}", "WheelDown", "^{PgDn}")

		Send(keyCombination[KeyGet(A_ThisHotkey)])
	}
}

#HotIf

#HotIf (!WinActive("ahk_group Game"))

Media_Prev::
XButton1 & LButton:: {
	Spotify.Prev()

	KeyWait("LButton")
}

Media_Next::
XButton1 & RButton:: {
	Spotify.Next()

	KeyWait("RButton")
}

Media_Play_Pause::
XButton1 & MButton:: {
	Spotify.PlayPause()

	KeyWait("MButton")
}

*$XButton1:: {
	KeyWait("XButton1")

	switch (WinGet("ProcessName")) {
		case "7zFM.exe":
			Send("{Backspace}")
		case "Spotify.exe":
			Send("!{Left}")
		default:
			Send("{XButton1}")
	}
}

XButton2 & MButton:: {
	Send("{Volume_Mute}")

	KeyWait("MButton")
}

XButton2 & WheelUp:: {
	Send("{Volume_Up}")
}

XButton2 & WheelDown:: {
	Send("{Volume_Down}")
}

$XButton2:: {
	KeyWait("XButton2")

	switch (WinGet("ProcessName")) {
		case "Spotify.exe":
			Send("!{Right}")
		default:
			Send("{XButton2}")
	}
}

#HotIf

;AppsKey & LButton::
;	if (!WinGet("MinMax")) {
;		before := [WinGet("Pos"), MouseGet("Pos")]  ;~ before
;
;		UpdateWindow:
;			if (GetKeyState("Escape", "P")) {
;				WinMove, A, , % before[0].x, % before[0].y
;			}
;			else if (GetKeyState("LButton", "P")) {
;				current := [WinGet("Pos"), MouseGet("Pos")]  ;~ current
;
;				WinMove, A, , current[0].x - before[1].x + (before[1].x := current[1].x), current[0].y - before[1].y + (before[1].y := current[1].y)
;
;				SetTimer("UpdateWindow", -25)
;			}
;
;			return
;	}
;
;	KeyWait("LButton")
;	return

;~$LButton::
;	while (GetKeyState("LButton", "P")) {
;		if (k := ((GetKeyState("Up", "P")) ? ("Up") : ((GetKeyState("Left", "P")) ? ("Left") : ((GetKeyState("Down", "P")) ? ("Down") : ((GetKeyState("Right", "P")) ? ("Right") : (0)))))) {
;			MouseMove, % Round({"Left": -1, "Right": 1}[k]), % Round({"Up": -1, "Down": 1}[k]), 0, R
;
;			KeyWait(k)
;		}
;
;		Sleep, -1
;	}
;
;	return

;====================================================== Keyboard ==============;

#HotIf (WinActive(A_ScriptName) && !(WinGet("Extension") == "ah1"))

$F10:: {
	ListVars

	KeyWait("F10")
}

~$^s:: {
	Critical(True)

	Sleep(200)
	Reload
}

#HotIf

#HotIf (WinExist("Window Spy ahk_class AutoHotkeyGUI"))

$^c:: {
	global A_SavedClipboard := A_Clipboard, SinglePaste := True

	A_Clipboard := "/*`n`t" . StrReplace(ControlGetText("Edit1", "Window Spy ahk_class AutoHotkeyGUI"), "`n", "`n`t") . "`n*/"

	;		HotKey("~$^v", SinglePaste, "On")
}

#HotIf

;#HotIf (SinglePaste)
;
;	~$^v:: {
;		Sleep(50)
;		A_Clipboard := A_SavedClipboard
;
;		global SinglePaste := False
;	}
;
;#HotIf

#HotIf (WinActive("ahk_group Editor"))

$F1:: {
	if (KeyWait("F1", "T0.25")) {
		extension := RegExReplace(WinGet("Title"), "i).*\.(\w+).*", "$1")

		if (extension ~= "ah\d*") {
			if (text := RegExReplace(String.Copy(True, True), "iSs)[^a-z_]*((?<!#(?=[a-z]))[#a-z_]*).*", "$1")) {
				version := SubStr(extension, -1)

				RunActivate((version == "1") ? ("AutoHotkey Help ahk_class HH Parent ahk_exe hh.exe") : ("AutoHotkey v2 Help ahk_class HH Parent ahk_exe hh.exe"), A_ProgramFiles . "\AutoHotkey\v" . version . "\AutoHotkey.chm", , , -7, 730, 894, 357)	;* Force the position here to avoid flickering with Window.ah2.

				Send("!n")
				Sleep(200)

				Send("^a")
				SendText(text)
				Send("{Enter}")
			}
			else {
				Run(Format("{}\bin\Nircmd.exe speak text `"NO TEXT`"", A_WorkingDir))
			}
		}

		KeyWait("F1")
	}
	else {
		Send("{F1}")
	}
}

$^q::
$^e:: {
	Send((A_ThisHotkey == "$^q") ? ("+{F2}") : ("+{F3}"))

	KeyWait(SubStr(A_ThisHotkey, -1))
}

$\:: {
	if (KeyWait("\", "T0.5")) {
		global A_Debug

		IniWrite(A_Debug := !A_Debug, A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")

		DetectHiddenWindows(True)

		for scripts in WinGetList("ahk_class AutoHotkey", , A_ScriptName) {
			SendMessage(A_WindowMessage, 0x1000, 0, scripts)  ;* Tell other running scripts to update their `A_Debug` value.
		}

		Run(A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("`"DEBUG {}.`"", (A_Debug) ? ("ON") : ("OFF")))

		KeyWait("\")
	}
	else {
		Send("\")
	}
}

$w::
$s:: {
	if (KeyWait((k := KeyGet(A_ThisHotkey)), "T0.25")) {
		Send((k == "w") ? ("^{Home}") : ("^{End}"))

		KeyWait(k)
	}
	else {
		Send((A_CapsLockState) ? (k.ToUpperCase()) : (k))
	}
}

$t:: {
	if (KeyWait("t", "T0.25")) {
		Send("^+t")

		KeyWait("t")
	}
	else {
		Send((A_CapsLockState) ? ("T") : ("t"))
	}
}

$p:: {
	if (KeyWait("p", "T0.25")) {
		Send("^+p")

		KeyWait("p")
	}
	else {
		Send((A_CapsLockState) ? ("P") : ("p"))
	}
}

$a::
$d:: {
	if (KeyWait((k := KeyGet(A_ThisHotkey)), "T0.25")) {
		switch (k) {
			case "a":
				Send("^{Left}")

				if (KeyWait(k, "T0.5")) {
					Send("{Home 2}")
				}
			case "d":
				Send("^{Right}")

				if (KeyWait(k, "T0.5")) {
					Send("{End}")
				}
		}

		KeyWait(k)
	}
	else {
		Send((A_CapsLockState) ? (k.ToUpperCase()) : (k))
	}
}

$c:: {
	if (KeyWait("c", "T0.25")) {
		static extensionLookup := Map("ah", ";", "lib", ";", "cs", "//", "js", "//", "json", "//", "pde", "//", "elm", "--", "py", "#")

		if ((text := String.Copy()) && (comment := extensionLookup[RegExReplace(WinGet("Title"), "iS).*\.([a-z]+).*", "$1")])) {
			String.Paste((SubStr(text, 1, StrLen(comment)) == comment) ? (RegExReplace(text, "`am)^" . comment)) : (RegExReplace(text, "`am)^", comment)))
		}
		else {
			Run(A_WorkingDir . "\bin\Nircmd.exe speak text `"NO TEXT`"")
		}

		KeyWait("c")
	}
	else {
		Send((A_CapsLockState) ? ("C") : ("c"))
	}
}

#HotIf

#HotIf (WinActive("__Rename ahk_exe Explorer.EXE"))

$F9:: {
	loop Files ("C:\Users\Onimuru\OneDrive\__User\Pictures\__Rename\*.*") {
		loop (10 + 5*((extension := RegExReplace(A_LoopFileName, "i).*(\.\w+).*", "$1")) ~= "gif|mov|mp4|webm" != 0)) {
			extension := Random(0, 9) . extension
		}

		if (A_Debug) {
			Console.Log(Format("{} --> {} ({})", A_LoopFileName, extension, 10 + 5*(extension ~= "gif|mov|mp4|webm" != 0)))
		}

		FileMove(A_LoopFilePath, A_LoopFileDir . "\" . extension)
	}

	KeyWait("F9")
}

#HotIf

#HotIf (WinActive("ahk_group Browser"))  ;~ Chrome shortcuts: https://support.google.com/chrome/answer/157179?co=GENIE.Platform%3DDesktop&hl=en-GB#zippy=%2Ctab-and-window-shortcuts.

$^q::
$^e:: {
	Send((A_ThisHotkey == "$^q") ? ("+^g") : ("^g"))
}

$t:: {
	if (KeyWait("t", "T0.25")) {
		Send("^+t")

		KeyWait("t")
	}
	else {
		Send((A_CapsLockState) ? ("T") : ("t"))
	}
}

$^f:: {
	text := String.Copy(True)

	Send("^f")
	Sleep(50)

	String.Paste(text)

	KeyWait("f")
}

#HotIf

#HotIf (!WinActive("ahk_group Game"))

$Esc:: {
	KeyWait("Escape")

	if (!KeyWait("Escape", "DT0.25")) {
		ShowDesktop()

		KeyWait("Escape")
	}
	else if (WinActive("ahk_group Escape") && !WinGet("MinMax")) {
		WinClose(winTitle := WinGet("ID"))

		if (!WinWaitNotActive(winTitle, , 1) && WinGet("Class") != "#32770") {
			winTitle := WinGet("Title")

			ProcessClose(WinGet("PID"))
			Console.Log(Format("{} FORCED: {}", A_Clipboard := A_ThisHotkey, winTitle))
		}
	}
	else {
		Send("{Escape}")
	}
}

$Space:: {
	if (KeyWait("Space", "T0.5") && !Desktop()) {
		if ([255, ""].Includes(WinGetTransparent("A"))) {
			window := WinGetID("A")

			FadeWindow(window, 35, 500)

			KeyWait("Space")
			FadeWindow(window, 255, 0)
		}

		KeyWait("Space")
	}
	else {
		Send("{Space}")
	}
}

$Delete:: {
	if (KeyWait("Del", "T0.5")) {
		RunActivate("Recycle Bin ahk_exe Explorer.exe", "::{645FF040-5081-101B-9F08-00AA002F954E}")

		if (KeyWait("Del", "T2")) {
			FileRecycleEmpty()

			if (KeyWait("Del", "T2")) {
				WinClose("Recycle Bin ahk_exe Explorer.exe")
			}
		}

		KeyWait("Del")
	}
	else {
		Send("{Del}")
	}
}

#HotIf

AppsKey & Escape:: {
	Run(A_WorkingDir . "\bin\Nircmd.exe speak text `"KILL SCREEN`"")

	while (GetKeyState("AppsKey", "P") || GetKeyState("Escape", "P")) {
		Sleep(-1)
	}

	SendMessage(0x112, 0xF170, 2, "Program Manager")  ;? 0x112 = WM_SYSCOMMAND, 0xF170 = SC_MONITORPOWER
}

AppsKey & F1:: {
	RunActivate("ahk_exe Discord.exe", "C:\Users\Onimuru\AppData\Local\Discord\Update.exe --processStart Discord.exe")

	KeyWait("F1")
}

AppsKey & F2:: {
	RunActivate("ahk_exe Spotify.exe", "C:\Users\Onimuru\AppData\Local\Microsoft\WindowsApps\Spotify.exe")

	KeyWait("F2")
}

AppsKey & F4:: {
	if (!Desktop()) {
		if (WinActive("Google Chrome ahk_exe chrome.exe")) {
			Send("^w")

			if (!KeyWait("F4", "T0.5")) {
				return
			}
		}

		WinClose(winTitle := WinGet("ID"))

		if (!WinWaitNotActive(winTitle, , 1) && WinGet("Class") != "#32770") {
			winTitle := WinGet("Title")

			ProcessClose(WinGet("PID"))
			Console.Log(Format("{} FORCED: {}", A_Clipboard := A_ThisHotkey, winTitle))
		}
	}

	KeyWait("F4")
}

AppsKey & F5:: {
	RunActivate("ahk_exe chrome.exe", Format("{} (x86)\Google\Chrome\Application\chrome.exe", A_ProgramFiles))

	KeyWait("F5")
}

AppsKey & F7:: {
	RunActivate("ahk_exe Code.exe", Format("{}\Microsoft VS Code\Code.exe", A_ProgramFiles))

	KeyWait("F7")
}

AppsKey & F8:: {
	if (!WinExist("ahk_class CabinetWClass")) {
		Run("::{20d04fe0-3aea-1069-a2d8-08002b30309d}")
		WinWait("This PC ahk_class CabinetWClass")
	}

	GroupAdd("Explorer", "ahk_class CabinetWClass")
	GroupActivate("Explorer", "R")

	KeyWait("F8")
}

AppsKey & F11:: {
	RunActivate("Notepad++ ahk_exe notepad++.exe", Format("{} (x86)\Notepad++\notepad++.exe", A_ProgramFiles))

	KeyWait("F11")
}

AppsKey & F12:: {
;	Menu("WindowSpy")

	KeyWait("F12")
}

AppsKey & PrintScreen:: {
	Send("+#s")

	KeyWait("PrintScreen")
}

AppsKey & ScrollLock:: {
	Run(Format("{}\bin\Camera", A_WorkingDir))

	KeyWait("ScrollLock")
}

AppsKey & Pause:: {
	Run(Format("*RunAs {}\System32\WindowsPowerShell\v1.0\powershell.exe", A_WinDir))

	KeyWait("Pause")
}

AppsKey & Insert:: {
	Run(A_WinDir . "\System32\SndVol.exe")

	KeyWait("Insert")
}

$^CapsLock::
$+CapsLock:: {
	Send(SubStr(A_ThisHotkey, 2, 1) . "{Home}")

	KeyWait("CapsLock")
}

AppsKey & CapsLock::
CapsLock(*) {
	global A_CapsLockState

	SetCapsLockState((A_CapsLockState := !A_CapsLockState) ? ("On") : ("AlwaysOff"))
	SetTimer(CapsLock, (A_CapsLockState) ? (-30000) : (0))

	KeyWait("CapsLock")
}

$CapsLock:: {
	if (KeyWait("CapsLock", "T0.25")) {
		if (String.Copy(True)) {
;			Menu, Case, Show  ;* ** Need a different script to handle hiding this menu, the thread is locked up. **
		}

		KeyWait("CapsLock")
	}
	else {
		Send("{Home}")
	}
}

AppsKey & Tab:: {
	String.Paste("`t")

	KeyWait("Tab")
}

;AppsKey & `:: {
;	SetSystemCursor()
;}

$`:: {
	KeyWait("``")

	if (!KeyWait("``", "DT0.25")) {
		DllCall("SystemParametersInfo", "UInt", 0x70, "UInt", 0, "UInt*", &(originalSpeed := 0), "UInt", 0)	;? 0x70 = SPI_GETMOUSESPEED
		DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", 2, "UInt", 0)	;? 0x71 = SPI_SETMOUSESPEED (range is 1-20, default is 10)

		KeyWait("``")
		DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", originalSpeed, "UInt", 0)
	}
	else {
		Send("{``}")
	}
}

AppsKey & 1::
AppsKey & 2::
AppsKey & 9::
AppsKey & [:: {
	characters := Map("1", [Chr(39), Chr(39)], "2", [Chr(34), Chr(34)], "9", [Chr(40), Chr(41)], "[", [Chr(91), Chr(93)])[key := SubStr(A_ThisHotkey, -1)]

	if (text := String.Copy()) {
		String.Paste(characters[0] . text . characters[1], 1)
	}

	KeyWait(key)
}

AppsKey & Enter:: {
	String.Paste("`r`n")

	KeyWait("Enter")
}

AppsKey & Space:: {
	if (!Desktop()) {
		if ([255, ""].Includes(WinGetTransparent("A"))) {
			FadeWindow(WinGet("ID"), 35, 1000)
		}
		else {
			FadeWindow(WinGet("ID"), 255, 1000)
		}
	}

	KeyWait("Space")
}

$!q:: {
	Console.Log(A_Clipboard := OCR())  ;! Send, #.

	KeyWait("q")
}

AppsKey & q:: {
	static coordinates := "", text := ""

	global A_SavedClipboard

	if (text == "Reset") {
		A_Clipboard := A_SavedClipboard

		coordinates.Destroy()
		coordinates := text := ""
	}
	else if (!(coordinates is Gui)) {
		coordinates := Gui("-Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20")
		coordinates.BackColor := "FFFFFF"
		WinSetTransColor("FFFFFF", coordinates)

		coordinates.SetFont("s30")
		coordinates.Add("Text", "c3FFEFF", "XXXX YYYY (CxCCCCCC)")
		coordinates.Show("x5 y5 NoActivate")

		UpdateGui()

		UpdateGui() {
			MouseGetPos(&x, &y)

			ControlSetText(text := Format("{}, {}", x, y) . ((GetKeyState("Ctrl", "P")) ? (Format(" ({})", Pixelgetcolor(x, y))) : ("")), "Static1", A_ScriptName)

			SetTimer(UpdateGui, -25)
		}
	}
	else if (coordinates) {
		A_SavedClipboard := ClipboardAll()
		A_Clipboard := text

		SetTimer(UpdateGui, 0)

		text := "Reset"
	}

	KeyWait("q")
}

AppsKey & t:: {
	if (!Desktop()) {
		WinSetAlwaysOnTop(-1, "A")
	}

	KeyWait("t")
}

AppsKey & s:: {
	while (GetKeyState("AppsKey", "P") || GetKeyState("s", "P")) {
		Sleep(-1)
	}

	splash := Gui("-Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20")
	splash.BackColor := "FF0E05"
	WinSetTransColor("FF0E05", splash)

	splash.SetFont("s20 Bold", "Fira Code Retina")
	splash.Add("Text", "cFFFFFF", "[R] Restart`n[S] Shutdown`n[L] Log Off`n`n[H] Hibernate`n[P] Sleep")
	splash.Show("x5 y5 NoActivate")

	Suspend(True)
	BlockInput("On")

	if (!(keyboardHook := DllCall("SetWindowsHookEx", "Int", 13, "Ptr", CallbackCreate(WindowsProc, "Fast"), "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr"), "UInt", 0, "Ptr"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	WindowsProc(nCode, wParam, lParam) {
		Critical(True)

		if (wParam == 0x101) {  ;? 0x100 = WM_KEYDOWN
			Suspend(False)
			BlockInput("Off")

			switch (GetKeyName(Format("vk{:X}", NumGet(lParam + 0, "UInt")))) {
				case "r":
					ShutDown(2)
				case "s":
					ShutDown(8)
				case "l":
					ShutDown(0)
				case "h":
					DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
				case "p":
					DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
			}

			if (!DllCall("UnhookWindowsHookEx", "Ptr", keyboardHook, "UInt")) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}

			splash.Destroy()
		}

		return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "Ptr", lParam))
	}
}

AppsKey & g:: {
	if (text := String.Copy(True, True)) {
		Run(Format("{}\Google\Chrome\Application\chrome.exe {}", A_ProgramFiles, (text ~= "i)(http|ftp)s?:\/\/|w{3}\.") ? (RegExReplace(text, "iS).*?(((http|ftp)s?|w{3})[a-z0-9-+&./?=#_%@:]+)(.|\s)*", "$1")) : ("www.google.com/search?&q=" . StrReplace(text, A_Space, "+"))))
	}

	KeyWait("g")
}

;AppsKey & h::
;	if (HiddenWindows.Length < 50) {
;		if (Desktop()) {
;			MsgBox("The desktop and taskbar may not be hidden.")
;
;			return
;		}
;
;		WinWaitActive, A
;		v := "        " . ((v := WinGet("Title")) ? (v) : (WinGet("ProcessName"))) . " (" . WinGet("ID") . ")"
;
;		if (WinExist("ahk_id" . RegExReplace(v, ".*?\((0x.*?)\)", "$1"))) {
;			Send, !{Esc}  ;* Because hiding the window won't deactivate it, activate the window beneath this one.
;			WinHide
;
;			if (!HiddenWindows.Includes(v)) {  ;* Ensure that this window doesn't already exist in the array.
;				Menu, Tray, Delete, % 15 + HiddenWindows.Length . "&"  ;* Move the "Exit" menu item to the bottom.
;				Menu, Tray, Delete, % 14 + HiddenWindows.Length . "&"
;
;				HiddenWindows.Push(v)
;
;				Menu, Tray, Add, % v, Menu
;				Menu, Tray, Add, [11] Exit, Menu
;				Menu, Tray, Add, , Menu
;			}
;		}
;		else {
;			throw (Exception("!!!!!", -1, Format("""{}"" is invalid.", v)))
;		}
;	}
;	else {
;		throw (Exception("Limit.", -1, "No more than 50 windows may be hidden simultaneously."))
;	}
;
;	KeyWait("h")
;	return
;
;AppsKey & u:: {
;	if (v := HiddenWindows.Length) {
;		Menu(HiddenWindows[--v])
;	}
;
;	KeyWait("u")
;}

AppsKey & c:: {
	RunActivate("Calculator ahk_exe ApplicationFrameHost.exe", "calc.exe")

	KeyWait("c")
}

AppsKey & v:: {
	if (A_Clipboard) {
		Send(A_Clipboard)
	}

	KeyWait("v")
}

;AppsKey & Up::
;AppsKey & Left::
;AppsKey & Down::
;AppsKey & Right::
;	k := KeyGet(A_ThisHotkey)
;
;	MouseMove, % Round({"Left": -1, "Right": 1}[k]), % Round({"Up": -1, "Down": 1}[k]), 0, R
;	return

;*$Up::
;*$Left::
;*$Down::
;*$Right::
;	if (GetKeyState("LButton", "P")) {
;		KeyWait(KeyGet(A_ThisHotkey))
;		return
;	}
;
;	Send, % "{" . KeyGet(A_ThisHotkey) . "}"
;	return

;============== Function ======================================================;
;======================================================== Hook ================;

__WindowMessage(wParam := 0, lParam := 0, msg := 0, hWnd := 0) {
	switch (wParam) {
		case 0x1000:
			if (!(A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug"))) {
				ToolTip("", , , 20)
			}

			return (True)
;		case 0x1001:
;			Menu, Tray, ToggleCheck, [&9] Suspend
;			if (!A_IsPaused) {
;				Menu, Tray, Icon, % ((!A_IsSuspended) ? ("mstscax.dll") : ("wmploc.dll")), % ((!A_IsSuspended) ? (10) : (136)), 1
;			}
;
;			Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", ((A_IsSuspended) ? ("You're suspended young lady!") : ("Carry on...")))
;
;			return (A_IsSuspended)
	}

	return (-1)
}

;WindowMessage(wParam := 0, lParam := 0) {
;	switch (wParam) {
;		case 0x1000: {
;			IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
;
;			return (Debug)
;		}
;		case 0x1001: {
;			Menu, Tray, ToggleCheck, [&9] Suspend
;			if (!A_IsPaused) {
;				Menu, Tray, Icon, % ((!A_IsSuspended) ? ("mstscax.dll") : ("wmploc.dll")), % ((!A_IsSuspended) ? (10) : (136)), 1
;			}
;
;			Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", ((A_IsSuspended) ? ("You're suspended young lady!") : ("Carry on...")))
;
;			return, (A_IsSuspended)
;		}
;	}
;
;	return (0)
;}

__Exit(exitReason, exitCode) {	;? ExitReason: Close || Error || Exit || Logoff || Menu || Reload || Restart || ShutDown || Single
	Critical(True)

	;	SetSystemCursor("Restore")
	;	Menu("RestoreAll")

	;	if (exitReason && exitReason ~= "Close|Error|Exit|Menu|Restart") {  ;* Need this check to avoid double calling when `ExitApp` is called internally for script close. It isn't a big deal, only to avoid throwing an error with `WinGet()`.
	;		DetectHiddenWindows, On
	;
	;		for i, v in WinGet("List", "ahk_class AutoHotkey", , A_ScriptName) {  ;* Close all AutoHotkey processes.
	;			PostMessage(0x111, 65307, , "ahk_id" . v)
	;		}
	;	}

	ExitApp
}

;======================================================== Menu ================;

;Menu(thisMenuItem := "", thisMenuItemPos := 0, thisMenu := "Tray") {
;	switch (thisMenu) {
;		case "Case": {
;			s := String.Clipboard.Copy()
;
;			switch (RegExReplace(thisMenuItem, "iS).*?([a-z])", "$1")) {
;				case "Sentencecase": {
;					s := RegExReplace(Format("{:L}", s), "S)((?:^|[.!?]\s*)[a-z])", "$U1")
;
;					for i, v in ["I", "Dr", "Mr", "Ms", "Mrs"] {
;						s := RegExReplace(s, "i)\b" . v . "\b", v)
;					}
;				}
;				case "iNVERSE": {
;					s := String.Inverse(s)
;				}
;				case "Reverse": {
;					s := String.Reverse(s)
;				}
;				default: {
;					s := Format("{:" . SubStr(thisMenuItem, 6, 1) . "}", s)
;				}
;			}
;
;			String.Clipboard.Paste(s)
;		}
;		case "Tray": {
;			switch (RegExReplace(thisMenuItem, "iS).*?([a-z])", "$1")) {
;				case "Edit": {
;					Edit, % A_ScriptName
;				}
;				case "OpenScriptFolder": {
;					Run, % "explorer.exe /select," . A_ScriptDir . "\" . A_ScriptName
;				}
;				case "WindowSpy": {
;					w := "ahk_id" . WinGet("ID")
;
;					RunActivate("Window Spy ahk_class AutoHotkeyGUI", A_ProgramFiles . "\AutoHotkey v1\WindowSpy.ah1", , , 50, 35)
;
;					if (WinExist(w)) {
;						WinActivate, % w
;					}
;
;					else {  ;* Launched with script menu.
;						Send, !{Esc}  ;* Restore focus away from the taskbar.
;					}
;				}
;				case "ListLines": {
;					ListLines
;
;					Sleep, 100
;					Send, ^{End}
;				}
;				case "ListVars": {
;					ListVars
;				}
;				case "ListHotkeys": {
;					ListHotkeys
;				}
;				case "KeyHistory": {
;					KeyHistory
;
;					Sleep, 100
;					Send, ^{End}
;				}
;				case "Pause": {
;					Menu, Tray, ToggleCheck, [&8] Pause
;					if (!A_IsSuspended) {
;						Menu, Tray, Icon, % (A_IsPaused) ? ("mstscax.dll") : ("wmploc.dll"), % (A_IsPaused) ? (10) : (136), 1
;					}
;
;					Pause, -1, 1
;					Run, % Format("{}\bin\Nircmd.exe speak text ""{}.""", A_WorkingDir, (A_IsPaused) ? ("Paused") : ("Unpaused"))
;				}
;				case "Suspend": {
;					w := "ahk_id" . WinGet("ID")
;
;					Menu, Tray, ToggleCheck, [&9] Suspend
;					if (!A_IsPaused) {
;						Menu, Tray, Icon, % (A_IsSuspended) ? ("mstscax.dll") : ("wmploc.dll"), % (A_IsSuspended) ? (10) : (136), 1
;					}
;
;					Suspend, -1
;					Run, %  Format("{}\bin\Nircmd.exe speak text ""{}.""", A_WorkingDir, A_IsSuspended ? "You're suspended young lady!" : "Carry on...")
;
;					if (WinExist(w)) {
;						WinActivate, % w
;					}
;					else {
;						Send, !{Esc}
;					}
;				}
;				case "RestoreAll": {
;					w := "ahk_id" . WinGet("ID")
;
;					loop, % s := HiddenWindows.Length {
;						Menu(HiddenWindows[--s])
;					}
;
;					WinActivate, % w
;				}
;				case "Exit": {
;					Exit()
;				}
;				default: {
;					w := "ahk_id" . RegExReplace(thisMenuItem, ".*?\((0x.*?)\)", "$1")
;
;					WinShow, % w
;					WinActivate, % w
;
;					DetectHiddenWindows, Off
;
;					if (!WinExist(w)) {
;						MsgBox(Format("There was an error unhiding this window ({}). Please contact your system administrator.", thisMenuItem))
;					}
;
;					DetectHiddenWindows, % DetectHiddenWindows
;
;					Menu, Tray, Delete, % thisMenuItem
;					HiddenWindows.RemoveAt(HiddenWindows.IndexOf(thisMenuItem))
;				}
;			}
;		}
;	}
;}

;=======================================================  Other  ===============;

;__SetSystemCursor() {
;	Local
;
;	VarSetCapacity(pvANDPlane, 128, 0xFF), VarSetCapacity(pvXORPlane, 128, 0)
;
;	for index, lpCursorName in (default := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650], hide := [], show := []) {
;		hide[index] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", &pvANDPlane, "Ptr", &pvXORPlane)
;			, show[index] := DllCall("CopyImage", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", lpCursorName), "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
;	}
;
;	return {"Default": default, "Hide": hide, "Show": show}
;}

;SetSystemCursor(mode := "") {
;	Local
;
;	Static default := (v := __SetSystemCursor()).Default, hide := v.Hide, show := v.Show
;		, internal, mouse
;
;	if (mode == "Timer" && MouseGet("Pos").Print() == mouse.Print()) {
;		if (internal == "Hide") {
;			SetTimer(Func(A_ThisFunc).Bind("Timer"), -50)
;		}
;
;		return
;	}
;
;	internal := ["Show", "Hide"][internal != "Hide" && mode != "Restore"]
;
;	if (internal == "Hide") {
;		mouse := MouseGet("Pos")
;
;		SetTimer(Func(A_ThisFunc).Bind("Timer"), -50)
;	}
;
;	for index, id in default {
;		DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", %internal%[index], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", id)
;	}
;}

;===============  Class  =======================================================;
