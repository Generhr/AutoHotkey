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

#Include ..\lib\Core.ahk

#Include ..\lib\General\General.ahk
#Include ..\lib\Console\Console.ahk
#Include ..\lib\Math\Math.ahk

#Include ..\lib\OCR.ahk
#Include ..\lib\Timer.ahk
#Include ..\lib\YouTube_Music.ahk

;--------------  Setting  ------------------------------------------------------;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
CoordMode("Pixel", "Screen")
InstallKeybdHook(True)
InstallMouseHook(True)
ListLines(False)
ProcessSetPriority("High")
SetCapsLockState("AlwaysOff")
SetNumlockState("AlwaysOn")
SetScrollLockState("AlwaysOff")
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..")

;---------------- Menu --------------------------------------------------------;

TraySetIcon("Mstscax.dll", 10)  ;: https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/

TrayMenu := A_TrayMenu
TrayMenu.Delete()
for v in ["", "[&1] Edit", "[&2] Open Script Folder", "[&3] Window Spy", "[&4] List Lines", "[&5] List Vars", "[&6] List Hotkeys", "[&7] KeyHistory", "", "[&8] Pause", "[&9] Suspend", "", "[10] Restore All", "[11] Reload", "[12] Exit", ""] {
	TrayMenu.Add(v, MenuHandler)
}

CaseMenu := Menu()
for v in ["", "[&1] lowercase", "[&2] UPPERCASE", "[&3] Sentence case", "[&4] Title Case", "", "[&5] iNVERSE", "[&6] esreveR", ""] {
	CaseMenu.Add(v, MenuHandler)
}

;---------------  Group  -------------------------------------------------------;

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

;-------------- Variable ------------------------------------------------------;

global debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, windowMessage := DllCall("User32\RegisterWindowMessage", "Str", "WindowMessage", "UInt")

	, savedClipboard := A_Clipboard, capsLockState := False
	, hiddenWindows := []
	, null := Chr(0)

;---------------- Hook --------------------------------------------------------;

OnMessage(windowMessage, WindowMessageHandler)

OnExit(ExitHandler)

;----------------  Run  --------------------------------------------------------;

for v in ["AutoCorrect", "Window"] {
	Run(A_ScriptDir . "\" . v . ".ahk")
}

;---------------  Other  -------------------------------------------------------;

CheckForNewVersion()

Exit()

;=============== Hotkey =======================================================;
;---------------  Mouse  -------------------------------------------------------;

#HotIf ((WinActive("ahk_group Editor") || WinActive("ahk_group Browser")) && !WinActive("ahk_group Game"))

~$WheelDown::
~$WheelUp:: {
	CoordMode("Mouse", "Window")
	MouseGetPos(, &y)

	if (A_TimeSincePriorHotkey && A_TimeSincePriorHotkey >= 50 && y <= 80 + 30*(WinActive("ahk_group Browser") > 0)) {
		static lookup := Map("WheelUp", "^{PgUp}", "WheelDown", "^{PgDn}")

		Send(lookup[KeyStripModifiers(A_ThisHotkey)])
	}
}

#HotIf

#HotIf (!WinActive("ahk_group Game"))

Media_Prev::
XButton1 & LButton:: {
	YouTube_Music.Prev()

	KeyWait("LButton")
}

Media_Next::
XButton1 & RButton:: {
	YouTube_Music.Next()

	KeyWait("RButton")
}

Media_Play_Pause::
XButton1 & MButton:: {
	YouTube_Music.PlayPause()

	KeyWait("MButton")
}

*$XButton1:: {
	KeyWait("XButton1")

	try {
		switch (WinGetProcessName("A")) {
			case "7zFM.exe":
				Send("{Backspace}")
			case "YouTube Music Desktop App.exe":
				Send("!{Left}")
			default:
				Send("{XButton1}")
		}
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

	try {
		switch (WinGetProcessName("A")) {
			case "YouTube Music Desktop App.exe":
				Send("!{Right}")
			default:
				Send("{XButton2}")
		}
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
;	KeyWait("LButton")
;	return

;-------------- Keyboard ------------------------------------------------------;

#HotIf (WinActive(A_ScriptName))

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

#HotIf (WinExist("Window Spy ahk_class AutoHotkeyGUI"))

$^c:: {
	global savedClipboard := A_Clipboard

	A_Clipboard := "`n`n/*`n`t" . StrReplace(ControlGetText("Edit1", "Window Spy ahk_class AutoHotkeyGUI"), "`n", "`n`t") . "`n*/"

	keyboardHook := Hook(13, __LowLevelKeyboardProc)

	__LowLevelKeyboardProc(nCode, wParam, lParam) {
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
						if (debug) {
							Console.Log("^v")
						}

						keyboardHook := null

						SetTimer((*) => (A_Clipboard := savedClipboard), -50)
					}
			}
		}

		return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
	}
}

#HotIf

#HotIf (WinActive("ahk_group Editor"))

$F1:: {
	if (!KeyWait("F1", "T0.25")) {
		extension := RegExReplace(WinGetTitle("A"), "i).*\.(\w+).*", "$1")

		if (extension ~= "ah\d*") {
			if (text := RegExReplace(Copy(True, True), "iSs)[^a-z_]*((?<!#(?=[a-z]))[#a-z_]*).*", "$1")) {
				version := SubStr(extension, -1)

				RunActivate("AutoHotkey v2 Help ahk_class HH Parent ahk_exe hh.exe", A_ProgramFiles . "\AutoHotkey\v2\AutoHotkey.chm", , , -7, 730, 894, 357)  ;* Force the position here to avoid flickering with Window.ahk.

				Send("!n")
				Sleep(200)

				Send("^a")
				SendText(text)
				Send("{Enter}")
			}
			else {
				Speak("No text.")
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
	if (!KeyWait("\", "T0.5")) {
		global debug := !debug

		IniWrite(debug, A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")

		DetectHiddenWindows(True)

		for scripts in WinGetList("ahk_class AutoHotkey", , A_ScriptName) {
			SendMessage(windowMessage, 0x1000, 0, , scripts)  ;* Tell other running scripts to update their `debug` value.
		}

		Speak(Format("Debug {}.", (debug) ? ("on") : ("off")))

		KeyWait("\")
	}
	else {
		Send("\")
	}
}

$w::
$s:: {
	if (!KeyWait((k := KeyStripModifiers(A_ThisHotkey)), "T0.25")) {
		Send((k == "w") ? ("^{Home}") : ("^{End}"))

		KeyWait(k)
	}
	else {
		Send((capsLockState) ? (k.ToUpperCase()) : (k))
	}
}

$t:: {
	if (!KeyWait("t", "T0.25")) {
		Send("^+t")

		KeyWait("t")
	}
	else {
		Send((capsLockState) ? ("T") : ("t"))
	}
}

$p:: {
	if (!KeyWait("p", "T0.25")) {
		Send("^+p")

		KeyWait("p")
	}
	else {
		Send((capsLockState) ? ("P") : ("p"))
	}
}

$a::
$d:: {
	if (!KeyWait((k := KeyStripModifiers(A_ThisHotkey)), "T0.25")) {
		switch (k) {
			case "a":
				Send("^{Left}")

				if (!KeyWait(k, "T0.5")) {
					Send("{Home 2}")
				}
			case "d":
				Send("^{Right}")

				if (!KeyWait(k, "T0.5")) {
					Send("{End}")
				}
		}

		KeyWait(k)
	}
	else {
		Send((capsLockState) ? (k.ToUpperCase()) : (k))
	}
}

$c:: {
	if (!KeyWait("c", "T0.25")) {
		static extensionLookup := Map("ahk", ";", "lib", ";", "cs", "//", "js", "//", "json", "//", "pde", "//", "elm", "--", "py", "#")

		if ((text := Copy()) && (comment := extensionLookup[RegExReplace(WinGetTitle("A"), "iS).*\.([a-z]+).*", "$1")])) {
			Paste((SubStr(text, 1, StrLen(comment)) == comment) ? (RegExReplace(text, "`am)^" . comment)) : (RegExReplace(text, "`am)^", comment)))
		}
		else {
			Speak("No text.")
		}

		KeyWait("c")
	}
	else {
		Send((capsLockState) ? ("C") : ("c"))
	}
}

#HotIf

#HotIf (WinActive("__Rename ahk_exe explorer.exe"))

$F9:: {
	loop Files ("C:\Users\Onimuru\OneDrive\__User\Pictures\__Rename\*.*") {
		loop (10 + 5*((extension := RegExReplace(A_LoopFileName, "i).*(\.\w+).*", "$1")) ~= "gif|mov|mp4|webm" != 0)) {
			extension := Random(0, 9) . extension
		}

		if (debug) {
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
	if (!KeyWait("t", "T0.25")) {
		Send("^+t")

		KeyWait("t")
	}
	else {
		Send((capsLockState) ? ("T") : ("t"))
	}
}

$^f:: {
	text := Copy(True)

	Send("^f")
	Sleep(50)

	Paste(text)

	KeyWait("f")
}

#HotIf

#HotIf (!WinActive("ahk_group Game"))

$Escape:: {
	if (A_PriorHotkey == "$Escape" && A_TimeSincePriorHotkey <= 350) {
		SetTimer(__SinglePress, 0)

		ShowDesktop()
	}
	else {
		SetTimer(__SinglePress, -350)
	}

	__SinglePress() {
		if (WinActive("ahk_group Escape") && WinGetMinMax(hWnd := WinGetID("A")) != 1) {
			WinClose(hWnd)

			if (!WinWaitClose("ahk_ID" . hWnd, , 1) && WinGetClass(hWnd) != "#32770") {  ;* Passing `"ahk_ID" . hWnd` here to respect `A_DetectHiddenWindows`.
				if (debug) {
					Console.Log(Format("{} forced close: {}", A_Clipboard := A_ThisHotkey, WinGetProcessName(hWnd)))
				}

				ProcessClose(WinGetPID(hWnd))
			}
		}
		else if (DllCall("User32\IsWindowVisible", "UInt", hWnd := WinExist("Window Spy ahk_class AutoHotkeyGUI"), "UInt")) {
			WinClose(hWnd)
		}
		else {
			Send("{Escape}")
		}
	}

	KeyWait("Escape")
}

$Space:: {
	if (!KeyWait("Space", "T0.5") && !Desktop()) {
		if ([255, ""].Includes(WinGetTransparent("A"))) {
			hWnd := WinGetID("A")

			WinFade(hWnd, 35, 500)

			KeyWait("Space")
			WinFade(hWnd, 255, 0)
		}

		KeyWait("Space")
	}
	else {
		Send("{Space}")
	}
}

$Delete:: {
	if (!KeyWait("Del", "T0.5")) {
		RunActivate("Recycle Bin ahk_exe Explorer.exe", "::{645FF040-5081-101B-9F08-00AA002F954E}")

		if (!KeyWait("Del", "T2")) {
			FileRecycleEmpty()

			if (!KeyWait("Del", "T2")) {
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
	Speak("Kill screen.")

	while (GetKeyState("AppsKey", "P") || GetKeyState("Escape", "P")) {
		Sleep(-1)
	}

	SendMessage(0x112, 0xF170, 2, , "Program Manager")  ;? 0x112 = WM_SYSCOMMAND, 0xF170 = SC_MONITORPOWER
}

AppsKey & F1:: {
	RunActivate("ahk_exe Discord.exe", "C:\Users\Onimuru\AppData\Local\Discord\Update.exe --processStart Discord.exe")

	KeyWait("F1")
}

AppsKey & F2:: {
	RunActivate("ahk_exe YouTube Music Desktop App.exe", "C:\Users\Onimuru\AppData\Local\Programs\youtube-music-desktop-app\YouTube Music Desktop App.exe")

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

		WinClose(hWnd := WinGetID("A"))

		if (!WinWaitClose("ahk_ID" . hWnd, , 1) && WinGetClass(hWnd) != "#32770") {
			if (debug) {
				Console.Log(Format("{} forced close: {}", A_Clipboard := A_ThisHotkey, WinGetProcessName(hWnd)))
			}

			ProcessClose(WinGetPID(hWnd))
		}
	}

	KeyWait("F4")
}

AppsKey & F5:: {
	RunActivate("ahk_exe chrome.exe", Format("{}\Google\Chrome\Application\chrome.exe", A_ProgramFiles))

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
	MenuHandler("WindowSpy")

	KeyWait("F12")
}

AppsKey & PrintScreen:: {
	Send("+#s")

	KeyWait("PrintScreen")
}

AppsKey & ScrollLock:: {
	Run(Format("*RunAs Camera.exe"))

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
	global capsLockState

	SetCapsLockState((capsLockState := !capsLockState) ? ("On") : ("AlwaysOff"))
	SetTimer(CapsLock, (capsLockState) ? (-30000) : (0))

	KeyWait("CapsLock")
}

$CapsLock:: {
	if (!KeyWait("CapsLock", "T0.25")) {
		if (Copy(True)) {
			keyboardHook := Hook(13, __LowLevelKeyboardProc)  ;* No need to capture this in the function as this variable exists as long as the thread is captured by the menu.

			__LowLevelKeyboardProc(nCode, wParam, lParam) {
				Critical(True)

				if (!nCode) {
					if (Format("{:#x}", NumGet(lParam, "UInt")) == 0x1B) {  ;? 0x1B = VK_ESCAPE
						if (wParam == 0x0101) {
							if (!DllCall("User32\EndMenu", "UInt")) {  ;~ If a platform does not support EndMenu, send the owner of the active menu a WM_CANCELMODE message.
								throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
							}
						}

						return (1)
					}
				}

				return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
			}

			CaseMenu.Show()
		}
	}
	else {
		Send("{Home}")
	}

	KeyWait("CapsLock")
}

AppsKey & Tab:: {
	Paste("`t")

	KeyWait("Tab")
}

AppsKey & `:: {
	SetSystemCursor()
}

$`:: {
	if (!KeyWait("``", "T0.25")) {
		DllCall("User32\SystemParametersInfo", "UInt", 0x70, "UInt", 0, "UInt*", &(originalSpeed := 0), "UInt", 0)	;? 0x70 = SPI_GETMOUSESPEED
		DllCall("User32\SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", 2, "UInt", 0)  ;? 0x71 = SPI_SETMOUSESPEED (range is 1-20, default is 10)

		KeyWait("``")
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

	if (text := Copy()) {
		static lookup := Map("1", [Chr(39), Chr(39)], "2", [Chr(34), Chr(34)], "9", [Chr(40), Chr(41)], "[", [Chr(91), Chr(93)])

		characters := lookup[key]

		Paste(characters[0] . text . characters[1], 1)
	}

	KeyWait(key)
}

AppsKey & Enter:: {
	Paste("`r`n")

	KeyWait("Enter")
}

AppsKey & Space:: {
	if (!Desktop()) {
		if ([255, ""].Includes(WinGetTransparent("A"))) {
			WinFade(WinGetID("A"), 35, 1000)
		}
		else {
			WinFade(WinGetID("A"), 255, 1000)
		}
	}

	KeyWait("Space")
}

$!q:: {
	Console.Log(A_Clipboard := OCR())

	KeyWait("q")
}

AppsKey & q:: {
	static coordinates := "", text := ""

	if (text == "Reset") {
		A_Clipboard := savedClipboard

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

		__UpdateGui()

		__UpdateGui() {
			MouseGetPos(&x, &y)

			ControlSetText(text := Format("{}, {}", x, y) . ((GetKeyState("Ctrl", "P")) ? (Format(" ({})", Pixelgetcolor(x, y, "Slow"))) : ("")), "Static1", A_ScriptName)

			SetTimer(__UpdateGui, -25)
		}
	}
	else if (coordinates) {
		global savedClipboard := ClipboardAll()
		A_Clipboard := text

		SetTimer(__UpdateGui, 0)

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
	splash.Add("Text", "cFFFFFF", "[R] Restart`n[S] Shutdown`n[L] Lock Computer`n`n[H] Hibernate`n[P] Sleep")
	splash.Show("x5 y5 NoActivate")

	Suspend(True)
	BlockInput("On")

	keyboardHook := Hook(13, __LowLevelKeyboardProc)

	__LowLevelKeyboardProc(nCode, wParam, lParam) {
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
					DllCall("User32\LockWorkStation", "UInt")  ;! ShutDown(0)
				case "h":
					DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
				case "p":
					DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
			}

			keyboardHook := null

			splash.Destroy()

			return (1)
		}

		return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "Ptr", lParam))
	}
}

AppsKey & g:: {
	if (text := Copy(True, True)) {
		Run(Format("{}\Google\Chrome\Application\chrome.exe {}", A_ProgramFiles, (text ~= "i)(http|ftp)s?:\/\/|w{3}\.") ? (RegExReplace(text, "iS).*?(((http|ftp)s?|w{3})[a-z0-9-+&./?=#_%@:]+)(.|\s)*", "$1")) : ("www.google.com/search?&q=" . StrReplace(text, A_Space, "+"))))
	}

	KeyWait("g")
}

AppsKey & h:: {
	if (hiddenWindows.Length < 50) {
		if (Desktop()) {
			MsgBox("The desktop and taskbar may not be hidden.")

			return
		}

		name := "        " . ((title := WinGetTitle("A")) ? (title) : (WinGetProcessName("A"))) . " (" . Format("{:#x}", hWnd := WinGetID("A")) . ")"

		Send("!{Esc}")  ;* Because hiding the window won't deactivate it, activate the window beneath this one.
		WinHide(hWnd)

		if (!hiddenWindows.Includes(name)) {  ;* Ensure that this window doesn't already exist in the array.
			length := hiddenWindows.Length + 16

			loop 3 {
				TrayMenu.Delete(length-- . "&")
			}

			hiddenWindows.Push(name)

			TrayMenu.Add(name, MenuHandler)
			TrayMenu.Add("[11] Reload", MenuHandler)
			TrayMenu.Add("[12] Exit", MenuHandler)
			TrayMenu.Add("")
		}
	}
	else {
		throw (Error("Limit.", -1, "No more than 50 windows may be hidden simultaneously."))
	}

	KeyWait("h")
}

AppsKey & u:: {
	if (length := hiddenWindows.Length) {
		MenuHandler(hiddenWindows[length - 1])
	}

	KeyWait("u")
}

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

AppsKey & .:: {
	Send("#.")
}

AppsKey & Left:: {
	MouseMove(-1, 0, 0, "R")
}

AppsKey & Up:: {
	MouseMove(0, -1, 0, "R")
}

AppsKey & Right:: {
	MouseMove(1, 0, 0, "R")
}

AppsKey & Down:: {
	MouseMove(0, 1, 0, "R")
}

;============== Function ======================================================;
;---------------- Hook --------------------------------------------------------;

WindowMessageHandler(wParam, lParam, msg, hWnd) {
	switch (wParam) {
		case 0x1000:
			global debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")

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

ExitHandler(exitReason, exitCode) {	;? ExitReason = Close || Error || Exit || Logoff || Menu || Reload || Restart || ShutDown || Single
	Critical(True)

	SetSystemCursor("Restore")
	MenuHandler("RestoreAll")

	if (exitReason && exitReason ~= "Close|Error|Exit|Menu") {
		DetectHiddenWindows(True)

		for hWnd in WinGetList("ahk_class AutoHotkey", , A_ScriptName) {  ;* Close all AutoHotkey processes besides this one.
			PostMessage(0x111, 65307, , , hWnd)
		}
	}
}

;---------------- Menu --------------------------------------------------------;  ;~ Menus (Menus and Other Resources): https://learn.microsoft.com/en-gb/windows/win32/menurc/menus?redirectedfrom=MSDN

MenuHandler(thisMenuItem := "", thisMenuItemPos := 0, thisMenu := TrayMenu) {
	switch (thisMenu.Handle) {
		case TrayMenu.Handle:
			if (debug) {
				Console.Log("TrayMenu")
			}

			switch (RegExReplace(thisMenuItem, "iS).*?([a-z])", "$1")) {
				case "Edit":
					Edit()
				case "OpenScriptFolder":
					Run("explorer.exe /select," . A_ScriptDir . "\" . A_ScriptName)
				case "WindowSpy":
					hWnd := __TryActivate() || 0

					__TryActivate(hWnd?) {
						if (IsSet(hWnd)) {
							try {
								WinActivate(hWnd)
							}
							catch {  ;* Launched with script menu.
								Send("!{Esc}")  ;* Restore focus away from the taskbar.
							}

						}
						else {
							try {
								return (WinGetID("A"))
							}
						}
					}

					RunActivate("Window Spy ahk_class AutoHotkeyGUI", A_ProgramFiles . "\AutoHotkey\UX\WindowSpy.ahk", , , 36, 32)

					__TryActivate(hWnd)
				case "ListLines":
					ListLines()

					Sleep(100)
					Send("^{End}")
				case "ListVars":
					ListVars()
				case "ListHotkeys":
					ListHotkeys()
				case "KeyHistory":
					KeyHistory()

					Sleep(100)
					Send("^{End}")
				case "Pause":
					hWnd := __TryActivate() || 0

					TrayMenu.ToggleCheck("[&8] Pause")

					if (!A_IsSuspended) {
						TraySetIcon((A_IsPaused) ? ("mstscax.dll") : ("wmploc.dll"), (A_IsPaused) ? (10) : (136), 1)
					}

					Pause(-1)
					Speak((A_IsPaused) ? ("Paused") : ("Unpaused"))

					__TryActivate(hWnd)
				case "Suspend":
					hWnd := __TryActivate() || 0

					TrayMenu.ToggleCheck("[&9] Suspend")

					if (!A_IsPaused) {
						TraySetIcon((A_IsSuspended) ? ("mstscax.dll") : ("wmploc.dll"), (A_IsSuspended) ? (10) : (136), 1)
					}

					Suspend(-1)
					Speak((A_IsSuspended) ? ("You're suspended young lady!") : ("Carry on..."))

					__TryActivate(hWnd)
				case "RestoreAll":
					hWnd := __TryActivate() || 0

					loop (length := hiddenWindows.Length) {
						MenuHandler(hiddenWindows[--length])
					}

					__TryActivate(hWnd)
				case "Reload":
					Reload()
				case "Exit":
					ExitApp()
				default:
					hWnd := RegExReplace(thisMenuItem, ".*?\((0x.*?)\)", "$1") + 0

					WinShow(hWnd)
					WinActivate(hWnd)

					if (!WinExist("ahk_id" . hWnd)) {
						MsgBox(Format("There was an error unhiding this window ({}). Please contact your system administrator.", thisMenuItem))
					}

					TrayMenu.Delete(thisMenuItem)
					hiddenWindows.RemoveAt(hiddenWindows.IndexOf(thisMenuItem))
			}
		case CaseMenu.Handle:
			if (debug) {
				Console.Log("CaseMenu")
			}

			text := Copy()

			switch (RegExReplace(thisMenuItem, "iS).*?([a-z])", "$1")) {
				case "Sentencecase":
					text := RegExReplace(Format("{:L}", text), "S)((?:^|[.!?]\s*)[a-z])", "$U1")

					for word in ["I", "Dr", "Mr", "Ms", "Mrs"] {
						text := RegExReplace(text, "i)\b" . word . "\b", word)
					}
				case "iNVERSE":
					text := String.Inverse(text)
				case "esreveR":
					text := String.Reverse(text)
				default:
					text := Format("{:" . SubStr(thisMenuItem, 6, 1) . "}", text)
			}

			Paste(text)
		}
}

;---------------  Other  -------------------------------------------------------;

CheckForNewVersion() {
	if (RegExReplace(version := DownloadContent("https://autohotkey.com/download/2.0/version.txt"), "\s") != A_AhkVersion) {
		static hide := (*) => (Console.Hide(), Console.Clear())

		Console.KeyboardHook := Hook(13, __LowLevelKeyboardProc)

		__LowLevelKeyboardProc(nCode, wParam, lParam) {
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
							static filename := Format("C:\Users\{}\Downloads\AutoHotkey v{}.exe", A_UserName, version)

							Download("https://www.autohotkey.com/download/ahk-v2.exe", filename)
							Run(filename)

							SetTimer(hide, -1)
						}

						return (1)
				}
			}

			return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
		}

		Console.Log(Format("New AHK version: {}`nPress {Spacebar} to download.", version))

		SetTimer(hide, -20000)
	}
}

SetSystemCursor(mode := "") {
	static internal := 0, mouse := [0, 0]

	if (mode == "Timer" && __MouseGetPos().Every((value, index, *) => (value == mouse[index]))) {
		if (internal == "Hide") {
			SetTimer(SetSystemCursor.Bind("Timer"), -50)
		}

		return
	}

	__MouseGetPos() {
		MouseGetPos(&x, &y)

		return ([x, y])
	}

	if ((internal := (internal != "Hide" && mode != "Restore") ? ("Hide") : ("Show")) == "Hide") {
		mouse := __MouseGetPos()

		SetTimer(SetSystemCursor.Bind("Timer"), -50)
	}

	static cursorNames := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]  ;? 32650 = OCR_APPSTARTING, 32512 = OCR_NORMAL, 32515 = OCR_CROSS, 32649 = OCR_HAND, 32651 = OCR_HELP, 32513 = OCR_IBEAM, 32648 = OCR_NO, 32646 = OCR_SIZEALL, 32643 = OCR_SIZENESW, 32645 = OCR_SIZENS, 32642 = OCR_SIZENWSE, 32644 = OCR_SIZEWE, 32516 = OCR_UP, 32514 = OCR_WAIT
		, hide := (ANDPlane := Buffer(128, 0xFF), XORPlane := Buffer(128, 0), cursorNames.Map((*) => (DllCall("User32\CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", ANDPlane, "Ptr", XORPlane)))), show := cursorNames.Map((cursorName, *) => (DllCall("User32\CopyImage", "Ptr", DllCall("User32\LoadCursor", "Ptr", 0, "Ptr", cursorName), "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)))

	for index, cursorName in cursorNames {
		DllCall("User32\SetSystemCursor", "Ptr", DllCall("User32\CopyImage", "Ptr", %internal%[index], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", cursorName)
	}
}