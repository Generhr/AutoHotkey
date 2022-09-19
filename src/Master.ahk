#Requires AutoHotkey v2.0-beta.9

;============ Auto-Execute ====================================================;
;=======================================================  Admin  ===============;

if (!A_IsAdmin || !DllCall("Kernel32\GetCommandLine", "Str") ~= " /restart(?!\S)") {
	try {
		Run(Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (Format('{} /restart "{}"', A_AhkPath, A_ScriptFullPath))))
	}

	ExitApp()
}

;======================================================  Include  ==============;

#Include ..\lib\Core.ahk

#Include ..\lib\General\General.ahk
#Include ..\lib\Console\Console.ahk

#Include ..\lib\OCR.ahk
#Include ..\lib\YouTube_Music.ahk

;======================================================  Setting  ==============;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
CoordMode("Pixel", "Screen")
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

TraySetIcon("mstscax.dll", 10)  ;: https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/

;Menu, Tray, NoStandard
;for k, v in {"Case": ["", "[&1] lowercase", "[&2] UPPERCASE", "[&3] Sentence case", "[&4] Title Case", "", "[&5] iNVERSE", "[&6] Reverse", ""], "Tray": ["", "[&1] Edit", "[&2] Open Script Folder", "[&3] Window Spy", "[&4] List Lines", "[&5] List Vars", "[&6] List Hotkeys", "[&7] KeyHistory", "", "[&8] Pause", "[&9] Suspend", "", "[10] Restore All", "[11] Exit", ""]} {
;	for i, v in v {
;		Menu, % k, Add, % v, Menu
;	}
;}

;=======================================================  Group  ===============;

for k, v in Map("Browser", [["Google Chrome ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe"]],  ;? [["Title ahk_class ClassName ahk_exe ProcessName", "ExcludeTitle"], ...]
	"Editor", [["Notepad++ ahk_class Notepad++ ahk_exe notepad++.exe"], ["ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe"], ["Microsoft Visual Studio ahk_exe devenv.exe"]],
	"Escape", [["ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe", "Calculator"], ["Help ahk_class HH Parent ahk_exe hh.exe"], ["ahk_class MediaPlayerClassicW ahk_exe mpc-hc64.exe"], ["Windows Photo Viewer ahk_class Photo_Lightweight_Viewer ahk_exe DllHost.exe"], ["Window Spy ahk_class AutoHotkeyGUI"], ["ahk_exe YouTube Music Desktop App.exe"]]) {
	for v in v {
		try {
			GroupAdd(k, v[0], , v[1])
		}
		catch IndexError {
			GroupAdd(k, v[0])
		}
	}
}

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("User32\RegisterWindowMessage", "Str", "WindowMessage", "UInt")

	, A_SavedClipboard := A_Clipboard, A_CapsLockState := False
	, A_HiddenWindows := []
	, A_Null := Chr(0)

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;========================================================  Run  ================;

for v in ["AutoCorrect", "Window"] {
	Run(A_ScriptDir . "\" . v . ".ahk")
}

;=======================================================  Other  ===============;

if (RegExReplace(v := DownloadContent("https://autohotkey.com/download/2.0/version.txt"), "\s") != A_AhkVersion) {
	hide := (*) => (Console.Hide(), Console.Clear())

	Console.KeyboardHook := LowLevelKeyboardProc

	LowLevelKeyboardProc(nCode, wParam, lParam) {
		Critical(True)

		if (!nCode) {  ;? 0 = HC_ACTION
			switch (Format("{:#x}", NumGet(lParam, "UInt"))) {
				case 0x1B:  ;? 0x1B = VK_ESCAPE
					if (wParam == 0x0101) {  ;? 0x0101 = WM_KEYUP
						SetTimer(hide, -1)
					}

					return (1)
				case 0x20:  ;? 0x20 = VK_SPACE
					if (wParam == 0x0101) {
						Run(Format("{}\Google\Chrome\Application\chrome.exe https://www.autohotkey.com/download/ahk-v2.exe", A_ProgramFiles))

						WinActivate("Google Chrome ahk_exe chrome.exe")
						WinWaitActive("Google Chrome ahk_exe chrome.exe")

						SetTimer(hide, -1)
					}

					return (1)
			}
		}

		return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
	}

	Console.Log(Format("New AHK version: {}`nPress {Spacebar} to download.", v))

	SetTimer(hide, -20000)
}

Exit()

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

#HotIf ((WinActive("ahk_group Editor") || WinActive("ahk_group Browser")) && !WinActive("ahk_group Game"))

~$WheelDown::
~$WheelUp:: {
	CoordMode("Mouse", "Window")
	MouseGetPos(, &y)

	if (A_TimeSincePriorHotkey && A_TimeSincePriorHotkey >= 50 && y <= 80 + 30*(WinActive("ahk_group Browser") > 0)) {
		static lookup := Map("WheelUp", "^{PgUp}", "WheelDown", "^{PgDn}")

		Send(lookup[KeyGet(A_ThisHotkey)])
	}
}

#HotIf

#HotIf (!WinActive("ahk_group Game"))

Media_Prev::
XButton1 & LButton:: {
	YouTube_Music.Prev()

	KeyWaitEx("LButton")
}

Media_Next::
XButton1 & RButton:: {
	YouTube_Music.Next()

	KeyWaitEx("RButton")
}

Media_Play_Pause::
XButton1 & MButton:: {
	YouTube_Music.PlayPause()

	KeyWaitEx("MButton")
}

*$XButton1:: {
	KeyWaitEx("XButton1")

	switch (WinGetProcessName("A")) {
		case "7zFM.exe":
			Send("{Backspace}")
		case "YouTube Music Desktop App.exe":
			Send("!{Left}")
		default:
			Send("{XButton1}")
	}
}

XButton2 & MButton:: {
	Send("{Volume_Mute}")

	KeyWaitEx("MButton")
}

XButton2 & WheelUp:: {
	Send("{Volume_Up}")
}

XButton2 & WheelDown:: {
	Send("{Volume_Down}")
}

$XButton2:: {
	KeyWaitEx("XButton2")

	switch (WinGetProcessName("A")) {
		case "YouTube Music Desktop App.exe":
			Send("!{Right}")
		default:
			Send("{XButton2}")
	}
}

#HotIf

;AppsKey & LButton::
;	if (!WinGetMinMax("A")) {
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
;	KeyWaitEx("LButton")
;	return

;====================================================== Keyboard ==============;

#HotIf (WinActive(A_ScriptName))

$F10:: {
	ListVars()

	KeyWaitEx("F10")
}

~$^s:: {
	Critical(True)

	Sleep(200)
	Reload()
}

#HotIf

#HotIf (WinExist("Window Spy ahk_class AutoHotkeyGUI"))

$^c:: {
	global A_SavedClipboard := A_Clipboard

	A_Clipboard := "/*`n`t" . StrReplace(ControlGetText("Edit1", "Window Spy ahk_class AutoHotkeyGUI"), "`n", "`n`t") . "`n*/"

	if (!(keyboardHook := DllCall("User32\SetWindowsHookEx", "Int", 13, "Ptr", CallbackCreate(LowLevelKeyboardProc2, "Fast"), "Ptr", DllCall("Kernel32\GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0, "Ptr"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	LowLevelKeyboardProc2(nCode, wParam, lParam) {
		Critical(True)

		if (!nCode) {
			static ctrlDown := False

			switch (Format("{:#x}", NumGet(lParam, "UInt"))) {
				case 0xA2:  ;? 0xA2 = VK_CONTROL
					switch (wParam) {
						case 0x0100:  ;? 0x0100 = WM_KEYDOWN
							if (!ctrlDown) {
								ctrlDown := True
							}
						case 0x0101:  ;? 0x0101 = WM_KEYUP
							ctrlDown := False
					}
				case 0x56:  ;? 0x56 = V key
					if (ctrlDown) {
						if (A_Debug) {
							Console.Log("^v")
						}

						if (!DllCall("User32\UnhookWindowsHookEx", "Ptr", keyboardHook, "UInt")) {
							throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
						}

						SetTimer((*) => (A_Clipboard := A_SavedClipboard), -50)
					}
			}
		}

		return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
	}
}

#HotIf

#HotIf (WinActive("ahk_group Editor"))

$F1:: {
	if (KeyWaitEx("F1", "T0.25")) {
		extension := RegExReplace(WinGetTitle("A"), "i).*\.(\w+).*", "$1")

		if (extension ~= "ah\d*") {
			if (text := RegExReplace(String.Copy(True, True), "iSs)[^a-z_]*((?<!#(?=[a-z]))[#a-z_]*).*", "$1")) {
				version := SubStr(extension, -1)

				RunActivate("AutoHotkey v2 Help ahk_class HH Parent ahk_exe hh.exe", A_ProgramFiles . "\AutoHotkey\v2\AutoHotkey.chm", , , -7, 730, 894, 357)	;* Force the position here to avoid flickering with Window.ahk.

				Send("!n")
				Sleep(200)

				Send("^a")
				SendText(text)
				Send("{Enter}")
			}
			else {
				Run(Format('{}\bin\Nircmd.exe speak text "NO TEXT"', A_WorkingDir))
			}
		}

		KeyWaitEx("F1")
	}
	else {
		Send("{F1}")
	}
}

$^q::
$^e:: {
	Send((A_ThisHotkey == "$^q") ? ("+{F2}") : ("+{F3}"))

	KeyWaitEx(SubStr(A_ThisHotkey, -1))
}

$\:: {
	if (KeyWaitEx("\", "T0.5")) {
		global A_Debug

		IniWrite(A_Debug := !A_Debug, A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")

		DetectHiddenWindows(True)

		for scripts in WinGetList("ahk_class AutoHotkey", , A_ScriptName) {
			SendMessage(A_WindowMessage, 0x1000, 0, , scripts)  ;* Tell other running scripts to update their `A_Debug` value.
		}

		Run(A_WorkingDir . "\bin\Nircmd.exe speak text " . Format('"DEBUG {}."', (A_Debug) ? ("ON") : ("OFF")))

		KeyWaitEx("\")
	}
	else {
		Send("\")
	}
}

$w::
$s:: {
	if (KeyWaitEx((k := KeyGet(A_ThisHotkey)), "T0.25")) {
		Send((k == "w") ? ("^{Home}") : ("^{End}"))

		KeyWaitEx(k)
	}
	else {
		Send((A_CapsLockState) ? (k.ToUpperCase()) : (k))
	}
}

$t:: {
	if (KeyWaitEx("t", "T0.25")) {
		Send("^+t")

		KeyWaitEx("t")
	}
	else {
		Send((A_CapsLockState) ? ("T") : ("t"))
	}
}

$p:: {
	if (KeyWaitEx("p", "T0.25")) {
		Send("^+p")

		KeyWaitEx("p")
	}
	else {
		Send((A_CapsLockState) ? ("P") : ("p"))
	}
}

$a::
$d:: {
	if (KeyWaitEx((k := KeyGet(A_ThisHotkey)), "T0.25")) {
		switch (k) {
			case "a":
				Send("^{Left}")

				if (KeyWaitEx(k, "T0.5")) {
					Send("{Home 2}")
				}
			case "d":
				Send("^{Right}")

				if (KeyWaitEx(k, "T0.5")) {
					Send("{End}")
				}
		}

		KeyWaitEx(k)
	}
	else {
		Send((A_CapsLockState) ? (k.ToUpperCase()) : (k))
	}
}

$c:: {
	if (KeyWaitEx("c", "T0.25")) {
		static extensionLookup := Map("ahk", ";", "lib", ";", "cs", "//", "js", "//", "json", "//", "pde", "//", "elm", "--", "py", "#")

		if ((text := String.Copy()) && (comment := extensionLookup[RegExReplace(WinGetTitle("A"), "iS).*\.([a-z]+).*", "$1")])) {
			String.Paste((SubStr(text, 1, StrLen(comment)) == comment) ? (RegExReplace(text, "`am)^" . comment)) : (RegExReplace(text, "`am)^", comment)))
		}
		else {
			Run(A_WorkingDir . '\bin\Nircmd.exe speak text "NO TEXT"')
		}

		KeyWaitEx("c")
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

	KeyWaitEx("F9")
}

#HotIf

#HotIf (WinActive("ahk_group Browser"))  ;~ Chrome shortcuts: https://support.google.com/chrome/answer/157179?co=GENIE.Platform%3DDesktop&hl=en-GB#zippy=%2Ctab-and-window-shortcuts.

$^q::
$^e:: {
	Send((A_ThisHotkey == "$^q") ? ("+^g") : ("^g"))
}

$t:: {
	if (KeyWaitEx("t", "T0.25")) {
		Send("^+t")

		KeyWaitEx("t")
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

	KeyWaitEx("f")
}

#HotIf

#HotIf (!WinActive("ahk_group Game"))

$Esc:: {
	KeyWaitEx("Escape")

	if (!KeyWaitEx("Escape", "DT0.25")) {
		ShowDesktop()

		KeyWaitEx("Escape")
	}
	else if (WinActive("ahk_group Escape") && !WinGetMinMax("A")) {
		WinClose(winTitle := WinGetID("A"))

		if (!WinWaitNotActive(winTitle, , 1) && WinGetClass("A") != "#32770") {
			winTitle := WinGetTitle("A")

			ProcessClose(WinGetPID("A"))
			Console.Log(Format("{} FORCED: {}", A_Clipboard := A_ThisHotkey, winTitle))
		}
	}
	else {
		Send("{Escape}")
	}
}

$Space:: {
	if (KeyWaitEx("Space", "T0.5") && !Desktop()) {
		if ([255, ""].Includes(WinGetTransparent("A"))) {
			window := WinGetID("A")

			FadeWindow(window, 35, 500)

			KeyWaitEx("Space")
			FadeWindow(window, 255, 0)
		}

		KeyWaitEx("Space")
	}
	else {
		Send("{Space}")
	}
}

$Delete:: {
	if (KeyWaitEx("Del", "T0.5")) {
		RunActivate("Recycle Bin ahk_exe Explorer.exe", "::{645FF040-5081-101B-9F08-00AA002F954E}")

		if (KeyWaitEx("Del", "T2")) {
			FileRecycleEmpty()

			if (KeyWaitEx("Del", "T2")) {
				WinClose("Recycle Bin ahk_exe Explorer.exe")
			}
		}

		KeyWaitEx("Del")
	}
	else {
		Send("{Del}")
	}
}

#HotIf

AppsKey & Escape:: {
	Run(A_WorkingDir . '\bin\Nircmd.exe speak text "KILL SCREEN"')

	while (GetKeyState("AppsKey", "P") || GetKeyState("Escape", "P")) {
		Sleep(-1)
	}

	SendMessage(0x112, 0xF170, 2, , "Program Manager")  ;? 0x112 = WM_SYSCOMMAND, 0xF170 = SC_MONITORPOWER
}

AppsKey & F1:: {
	RunActivate("ahk_exe Discord.exe", "C:\Users\Onimuru\AppData\Local\Discord\Update.exe --processStart Discord.exe")

	KeyWaitEx("F1")
}

AppsKey & F2:: {
	RunActivate("ahk_exe YouTube Music Desktop App.exe", "C:\Users\Onimuru\AppData\Local\Programs\youtube-music-desktop-app\YouTube Music Desktop App.exe")

	KeyWaitEx("F2")
}

AppsKey & F4:: {
	if (!Desktop()) {
		if (WinActive("Google Chrome ahk_exe chrome.exe")) {
			Send("^w")

			if (!KeyWaitEx("F4", "T0.5")) {
				return
			}
		}

		WinClose(winTitle := WinGetID("A"))

		if (!WinWaitNotActive(winTitle, , 1) && WinGetClass("A") != "#32770") {
			winTitle := WinGetTitle("A")

			ProcessClose(WinGetPID("A"))
			Console.Log(Format("{} FORCED: {}", A_Clipboard := A_ThisHotkey, winTitle))
		}
	}

	KeyWaitEx("F4")
}

AppsKey & F5:: {
	RunActivate("ahk_exe chrome.exe", Format("{} (x86)\Google\Chrome\Application\chrome.exe", A_ProgramFiles))

	KeyWaitEx("F5")
}

AppsKey & F7:: {
	RunActivate("ahk_exe Code.exe", Format("{}\Microsoft VS Code\Code.exe", A_ProgramFiles))

	KeyWaitEx("F7")
}

AppsKey & F8:: {
	if (!WinExist("ahk_class CabinetWClass")) {
		Run("::{20d04fe0-3aea-1069-a2d8-08002b30309d}")
		WinWait("This PC ahk_class CabinetWClass")
	}

	GroupAdd("Explorer", "ahk_class CabinetWClass")
	GroupActivate("Explorer", "R")

	KeyWaitEx("F8")
}

AppsKey & F11:: {
	RunActivate("Notepad++ ahk_exe notepad++.exe", Format("{} (x86)\Notepad++\notepad++.exe", A_ProgramFiles))

	KeyWaitEx("F11")
}

AppsKey & F12:: {
;	Menu("WindowSpy")

	KeyWaitEx("F12")
}

AppsKey & PrintScreen:: {
	Send("+#s")

	KeyWaitEx("PrintScreen")
}

AppsKey & ScrollLock:: {
	Run(Format("{}\bin\Camera", A_WorkingDir))

	KeyWaitEx("ScrollLock")
}

AppsKey & Pause:: {
	Run(Format("*RunAs {}\System32\WindowsPowerShell\v1.0\powershell.exe", A_WinDir))

	KeyWaitEx("Pause")
}

AppsKey & Insert:: {
	Run(A_WinDir . "\System32\SndVol.exe")

	KeyWaitEx("Insert")
}

$^CapsLock::
$+CapsLock:: {
	Send(SubStr(A_ThisHotkey, 2, 1) . "{Home}")

	KeyWaitEx("CapsLock")
}

AppsKey & CapsLock::
CapsLock(*) {
	global A_CapsLockState

	SetCapsLockState((A_CapsLockState := !A_CapsLockState) ? ("On") : ("AlwaysOff"))
	SetTimer(CapsLock, (A_CapsLockState) ? (-30000) : (0))

	KeyWaitEx("CapsLock")
}

$CapsLock:: {
	if (KeyWaitEx("CapsLock", "T0.25")) {
		if (String.Copy(True)) {
;			Menu, Case, Show  ;* ** Need a different script to handle hiding this menu, the thread is locked up. **
		}

		KeyWaitEx("CapsLock")
	}
	else {
		Send("{Home}")
	}
}

AppsKey & Tab:: {
	String.Paste("`t")

	KeyWaitEx("Tab")
}

;AppsKey & `:: {
;	SetSystemCursor()
;}

$`:: {
	if (KeyWaitEx("``", "T0.25")) {
		DllCall("User32\SystemParametersInfo", "UInt", 0x70, "UInt", 0, "UInt*", &(originalSpeed := 0), "UInt", 0)	;? 0x70 = SPI_GETMOUSESPEED
		DllCall("User32\SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", 2, "UInt", 0)	;? 0x71 = SPI_SETMOUSESPEED (range is 1-20, default is 10)

		KeyWaitEx("``")
		DllCall("User32\SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", originalSpeed, "UInt", 0)
	}
	else {
		Send("{``}")
	}
}

AppsKey & 1::
AppsKey & 2::
AppsKey & 9::
AppsKey & [:: {
	key := SubStr(A_ThisHotkey, -1)

	if (text := String.Copy()) {
		static lookup := Map("1", [Chr(39), Chr(39)], "2", [Chr(34), Chr(34)], "9", [Chr(40), Chr(41)], "[", [Chr(91), Chr(93)])

		characters := lookup[key]

		String.Paste(characters[0] . text . characters[1], 1)
	}

	KeyWaitEx(key)
}

AppsKey & Enter:: {
	String.Paste("`r`n")

	KeyWaitEx("Enter")
}

AppsKey & Space:: {
	if (!Desktop()) {
		if ([255, ""].Includes(WinGetTransparent("A"))) {
			FadeWindow(WinGetID("A"), 35, 1000)
		}
		else {
			FadeWindow(WinGetID("A"), 255, 1000)
		}
	}

	KeyWaitEx("Space")
}

$!q:: {
	Console.Log(A_Clipboard := OCR())  ;! Send, #.

	KeyWaitEx("q")
}

AppsKey & q:: {
	global A_SavedClipboard

	static coordinates := "", text := ""

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

			ControlSetText(text := Format("{}, {}", x, y) . ((GetKeyState("Ctrl", "P")) ? (Format(" ({})", Pixelgetcolor(x, y, "Slow"))) : ("")), "Static1", A_ScriptName)

			SetTimer(UpdateGui, -25)
		}
	}
	else if (coordinates) {
		A_SavedClipboard := ClipboardAll()
		A_Clipboard := text

		SetTimer(UpdateGui, 0)

		text := "Reset"
	}

	KeyWaitEx("q")
}

AppsKey & t:: {
	if (!Desktop()) {
		WinSetAlwaysOnTop(-1, "A")
	}

	KeyWaitEx("t")
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

	if (!(keyboardHook := DllCall("User32\SetWindowsHookEx", "Int", 13, "Ptr", CallbackCreate(LowLevelKeyboardProc, "Fast"), "Ptr", DllCall("Kernel32\GetModuleHandle", "UInt", 0, "Ptr"), "UInt", 0, "Ptr"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	LowLevelKeyboardProc(nCode, wParam, lParam) {
		Critical(True)

		if (wParam == 0x0101) {  ;? 0x0101 = WM_KEYUP
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

			if (!DllCall("User32\UnhookWindowsHookEx", "Ptr", keyboardHook, "UInt")) {
				throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
			}

			splash.Destroy()
		}

		return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "Ptr", lParam))
	}
}

AppsKey & g:: {
	if (text := String.Copy(True, True)) {
		Run(Format("{}\Google\Chrome\Application\chrome.exe {}", A_ProgramFiles, (text ~= "i)(http|ftp)s?:\/\/|w{3}\.") ? (RegExReplace(text, "iS).*?(((http|ftp)s?|w{3})[a-z0-9-+&./?=#_%@:]+)(.|\s)*", "$1")) : ("www.google.com/search?&q=" . StrReplace(text, A_Space, "+"))))
	}

	KeyWaitEx("g")
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
;	KeyWaitEx("h")
;	return
;
;AppsKey & u:: {
;	if (v := HiddenWindows.Length) {
;		Menu(HiddenWindows[--v])
;	}
;
;	KeyWaitEx("u")
;}

AppsKey & c:: {
	RunActivate("Calculator ahk_exe ApplicationFrameHost.exe", "calc.exe")

	KeyWaitEx("c")
}

AppsKey & v:: {
	if (A_Clipboard) {
		Send(A_Clipboard)
	}

	KeyWaitEx("v")
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
;		KeyWaitEx(A_ThisHotkey)
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

	ExitApp()
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