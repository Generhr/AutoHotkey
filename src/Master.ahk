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

TraySetIcon("Mstscax.dll", 10)  ;: https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/

TrayMenu := A_TrayMenu
TrayMenu.Delete()
for v in ["", "[&1] Edit", "[&2] Open Script Folder", "[&3] Window Spy", "[&4] List Lines", "[&5] List Vars", "[&6] List Hotkeys", "[&7] KeyHistory", "", "[&8] Pause", "[&9] Suspend", "", "[10] Restore All", "[11] Reload", "[12] Exit", ""] {
	TrayMenu.Add(v, MenuHandler)
}

CaseMenu := Menu()
for v in ["", "[&1] lowercase", "[&2] UPPERCASE", "[&3] Sentence case", "[&4] Title Case", "", "[&5] iNVERSE", "[&6] Reverse", ""] {
	CaseMenu.Add(v, MenuHandler)
}

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

CheckForNewVersion()

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

		Send(lookup[StripModifiers(A_ThisHotkey)])
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

;====================================================== Keyboard ==============;

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
	global A_SavedClipboard := A_Clipboard

	A_Clipboard := "/*`n`t" . StrReplace(ControlGetText("Edit1", "Window Spy ahk_class AutoHotkeyGUI"), "`n", "`n`t") . "`n*/"

	if (!(keyboardHook := DllCall("User32\SetWindowsHookEx", "Int", 13, "Ptr", CallbackCreate(LowLevelKeyboardProc, "Fast"), "Ptr", DllCall("Kernel32\GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0, "Ptr"))) {
		throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	LowLevelKeyboardProc(nCode, wParam, lParam) {
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
	if (!KeyWait("F1", "T0.25")) {
		extension := RegExReplace(WinGetTitle("A"), "i).*\.(\w+).*", "$1")

		if (extension ~= "ah\d*") {
			if (text := RegExReplace(String.Copy(True, True), "iSs)[^a-z_]*((?<!#(?=[a-z]))[#a-z_]*).*", "$1")) {
				version := SubStr(extension, -1)

				RunActivate("AutoHotkey v2 Help ahk_class HH Parent ahk_exe hh.exe", A_ProgramFiles . "\AutoHotkey\v2\AutoHotkey.chm", , , -7, 730, 894, 357)  ;* Force the position here to avoid flickering with Window.ahk.

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
		global A_Debug

		IniWrite(A_Debug := !A_Debug, A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")

		DetectHiddenWindows(True)

		for scripts in WinGetList("ahk_class AutoHotkey", , A_ScriptName) {
			SendMessage(A_WindowMessage, 0x1000, 0, , scripts)  ;* Tell other running scripts to update their `A_Debug` value.
		}

		Run(A_WorkingDir . "\bin\Nircmd.exe speak text " . Format('"DEBUG {}."', (A_Debug) ? ("ON") : ("OFF")))

		KeyWait("\")
	}
	else {
		Send("\")
	}
}

$w::
$s:: {
	if (!KeyWait((k := StripModifiers(A_ThisHotkey)), "T0.25")) {
		Send((k == "w") ? ("^{Home}") : ("^{End}"))

		KeyWait(k)
	}
	else {
		Send((A_CapsLockState) ? (k.ToUpperCase()) : (k))
	}
}

$t:: {
	if (!KeyWait("t", "T0.25")) {
		Send("^+t")

		KeyWait("t")
	}
	else {
		Send((A_CapsLockState) ? ("T") : ("t"))
	}
}

$p:: {
	if (!KeyWait("p", "T0.25")) {
		Send("^+p")

		KeyWait("p")
	}
	else {
		Send((A_CapsLockState) ? ("P") : ("p"))
	}
}

$a::
$d:: {
	if (!KeyWait((k := StripModifiers(A_ThisHotkey)), "T0.25")) {
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
		Send((A_CapsLockState) ? (k.ToUpperCase()) : (k))
	}
}

$c:: {
	if (!KeyWait("c", "T0.25")) {
		static extensionLookup := Map("ahk", ";", "lib", ";", "cs", "//", "js", "//", "json", "//", "pde", "//", "elm", "--", "py", "#")

		if ((text := String.Copy()) && (comment := extensionLookup[RegExReplace(WinGetTitle("A"), "iS).*\.([a-z]+).*", "$1")])) {
			String.Paste((SubStr(text, 1, StrLen(comment)) == comment) ? (RegExReplace(text, "`am)^" . comment)) : (RegExReplace(text, "`am)^", comment)))
		}
		else {
			Run(A_WorkingDir . '\bin\Nircmd.exe speak text "NO TEXT"')
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
	if (!KeyWait("t", "T0.25")) {
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

$Escape:: {
	static single := (*) => (Send("{Escape}"))

	if (A_PriorHotkey == "$Escape" && A_TimeSincePriorHotkey <= 200) {
		SetTimer(single, 0)

		ShowDesktop()
	}
	else if (WinActive("ahk_group Escape") && !WinGetMinMax("A")) {
		WinClose(winTitle := WinGetID("A"))

		if (!WinWaitNotActive(winTitle, , 1) && WinGetClass("A") != "#32770") {
			winTitle := WinGetTitle("A")

			ProcessClose(WinGetPID("A"))
			Console.Log(Format("{} Forced: {}", A_Clipboard := A_ThisHotkey, winTitle))
		}
	}
	else {
		SetTimer(single, -200)
	}

	KeyWait("Escape")
}

$Space:: {
	if (!KeyWait("Space", "T0.5") && !Desktop()) {
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
	Run(A_WorkingDir . '\bin\Nircmd.exe speak text "Kill screen"')

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

		WinClose(winTitle := WinGetID("A"))

		if (!WinWaitNotActive(winTitle, , 1) && WinGetClass("A") != "#32770") {
			winTitle := WinGetTitle("A")

			ProcessClose(WinGetPID("A"))
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
	MenuHandler("WindowSpy")

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
	if (!KeyWait("CapsLock", "T0.25")) {
		if (String.Copy(True)) {
			CaseMenu.Show()  ;* ** Need a different script to handle hiding this menu, the thread is locked up. **
		}
	}
	else {
		Send("{Home}")
	}

	KeyWait("CapsLock")
}

AppsKey & Tab:: {
	String.Paste("`t")

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

	if (text := String.Copy()) {
		static lookup := Map("1", [Chr(39), Chr(39)], "2", [Chr(34), Chr(34)], "9", [Chr(40), Chr(41)], "[", [Chr(91), Chr(93)])

		characters := lookup[key]

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
			FadeWindow(WinGetID("A"), 35, 1000)
		}
		else {
			FadeWindow(WinGetID("A"), 255, 1000)
		}
	}

	KeyWait("Space")
}

$!q:: {
	Console.Log(A_Clipboard := OCR())

	KeyWait("q")
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

		__UpdateGui()

		__UpdateGui() {
			MouseGetPos(&x, &y)

			ControlSetText(text := Format("{}, {}", x, y) . ((GetKeyState("Ctrl", "P")) ? (Format(" ({})", Pixelgetcolor(x, y, "Slow"))) : ("")), "Static1", A_ScriptName)

			SetTimer(__UpdateGui, -25)
		}
	}
	else if (coordinates) {
		A_SavedClipboard := ClipboardAll()
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

	KeyWait("g")
}

AppsKey & h:: {
	if (A_HiddenWindows.Length < 50) {
		if (Desktop()) {
			MsgBox("The desktop and taskbar may not be hidden.")

			return
		}

		name := "        " . ((title := WinGetTitle("A")) ? (title) : (WinGetProcessName("A"))) . " (" . Format("{:#x}", hWnd := WinGetID("A")) . ")"

		Send("!{Esc}")  ;* Because hiding the window won't deactivate it, activate the window beneath this one.
		WinHide(hWnd)

		if (!A_HiddenWindows.Includes(name)) {  ;* Ensure that this window doesn't already exist in the array.
			length := A_HiddenWindows.Length + 16

			loop 3 {
				TrayMenu.Delete(length-- . "&")
			}

			A_HiddenWindows.Push(name)

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
	if (length := A_HiddenWindows.Length) {
		MenuHandler(A_HiddenWindows[length - 1])
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

;AppsKey & Up::
;AppsKey & Left::
;AppsKey & Down::
;AppsKey & Right::
;	k := StripModifiers(A_ThisHotkey)
;
;	MouseMove, % Round({"Left": -1, "Right": 1}[k]), % Round({"Up": -1, "Down": 1}[k]), 0, R
;	return

;*$Up::
;*$Left::
;*$Down::
;*$Right::
;	if (GetKeyState("LButton", "P")) {
;		KeyWait(A_ThisHotkey)
;		return
;	}
;
;	Send, % "{" . StripModifiers(A_ThisHotkey) . "}"
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

__Exit(exitReason, exitCode) {	;? ExitReason = Close || Error || Exit || Logoff || Menu || Reload || Restart || ShutDown || Single
	Critical(True)

	SetSystemCursor("Restore")
	MenuHandler("RestoreAll")

	if (exitReason && exitReason ~= "Close|Error|Exit|Menu") {
		DetectHiddenWindows(True)

		for script in WinGetList("ahk_class AutoHotkey", , A_ScriptName) {  ;* Close all AutoHotkey processes besides this one.
			PostMessage(0x111, 65307, , , script)
		}
	}
}

;======================================================== Menu ================;  ;~ Menus (Menus and Other Resources): https://learn.microsoft.com/en-gb/windows/win32/menurc/menus?redirectedfrom=MSDN

MenuHandler(thisMenuItem := "", thisMenuItemPos := 0, thisMenu := TrayMenu) {
	switch (thisMenu.Handle) {
		case TrayMenu.Handle:
			if (A_Debug) {
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
					Run(Format('{}\bin\Nircmd.exe speak text "{}"', A_WorkingDir, (A_IsPaused) ? ("Paused") : ("Unpaused")))

					__TryActivate(hWnd)
				case "Suspend":
					hWnd := __TryActivate() || 0

					TrayMenu.ToggleCheck("[&9] Suspend")

					if (!A_IsPaused) {
						TraySetIcon((A_IsSuspended) ? ("mstscax.dll") : ("wmploc.dll"), (A_IsSuspended) ? (10) : (136), 1)
					}

					Suspend(-1)
					Run(Format('{}\bin\Nircmd.exe speak text "{}"', A_WorkingDir, (A_IsSuspended) ? ("You're suspended young lady!") : ("Carry on...")))

					__TryActivate(hWnd)
				case "RestoreAll":
					hWnd := __TryActivate() || 0

					loop (length := A_HiddenWindows.Length) {
						MenuHandler(A_HiddenWindows[--length])
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
					A_HiddenWindows.RemoveAt(A_HiddenWindows.IndexOf(thisMenuItem))
			}
		case CaseMenu.Handle:
			if (A_Debug) {
				Console.Log("CaseMenu")
			}

			text := String.Copy()

			switch (RegExReplace(thisMenuItem, "iS).*?([a-z])", "$1")) {
				case "Sentencecase":
					text := RegExReplace(Format("{:L}", text), "S)((?:^|[.!?]\s*)[a-z])", "$U1")

					for word in ["I", "Dr", "Mr", "Ms", "Mrs"] {
						text := RegExReplace(text, "i)\b" . word . "\b", word)
					}
				case "iNVERSE":
					text := String.Inverse(text)
				case "Reverse":
					text := String.Reverse(text)
				default:
					text := Format("{:" . SubStr(thisMenuItem, 6, 1) . "}", text)
			}

			String.Paste(text)
		}
}

;=======================================================  Other  ===============;

CheckForNewVersion() {
	if (RegExReplace(version := DownloadContent("https://autohotkey.com/download/2.0/version.txt"), "\s") != A_AhkVersion) {
		static hide := (*) => (Console.Hide(), Console.Clear())

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
							static filename := Format("C:\Users\{}\Downloads\AutoHotkey v{}.exe", A_UserName, version)

							Download "https://www.autohotkey.com/download/ahk-v2.exe", filename
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
		, hide := (array := [], ANDPlane := Buffer(128, 0xFF), XORPlane := Buffer(128, 0), cursorNames.Every((*) => (array.Push(DllCall("User32\CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", ANDPlane, "Ptr", XORPlane)))), array), show := (array := [], cursorNames.Every((cursorName, *) => (array.Push(DllCall("User32\CopyImage", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", cursorName), "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)))), array)

	for index, cursorName in cursorNames {
		DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", %internal%[index], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", cursorName)
	}
}

;===============  Class  =======================================================;