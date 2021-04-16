;============ Auto-execute ====================================================;
;=======================================================  Admin  ===============;

if (!A_IsAdmin || !(DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)")) {
	try {
		Run, % Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (A_AhkPath . " /restart " . A_ScriptFullPath))
	}

	ExitApp
}

;======================================================  Setting  ==============;

#InstallKeybdHook
#InstallMouseHook
#NoEnv
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox
#WinActivateForce

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
Process, Priority, , High
SendMode, Input
SetBatchLines, -1
SetCapsLockState, AlwaysOff
SetKeyDelay, -1, -1
SetNumlockState, AlwaysOn
SetScrollLockState, AlwaysOff
SetTitleMatchMode, 2
SetWinDelay, -1
SetWorkingDir, % A_ScriptDir . "\.."

;======================================================== Menu ================;

Menu, Tray, Icon, mstscax.dll, 10, 1  ;: https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/
Menu, Tray, NoStandard
for k, v in {"Case": ["", "[&1] lowercase", "[&2] UPPERCASE", "[&3] Sentence case", "[&4] Title Case", "", "[&5] iNVERSE", "[&6] Reverse", ""], "Tray": ["", "[&1] Edit", "[&2] Open Script Folder", "[&3] Window Spy", "[&4] List Lines", "[&5] List Vars", "[&6] List Hotkeys", "[&7] KeyHistory", "", "[&8] Pause", "[&9] Suspend", "", "[10] Restore All", "[11] Exit", ""]} {
	for i, v in v {
		Menu, % k, Add, % v, Menu
	}
}

;====================================================== Variable ==============;

IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global Debug
	, DetectHiddenWindows := A_DetectHiddenWindows, CapsLockState := 0
	, SavedClipboard
	, HiddenWindows := []

;=======================================================  Group  ===============;

for k, v in {"Browser": [["Google Chrome", "chrome"]]
	, "Editor" : [["Notepad++", "notepad++"], ["", "Code"], ["Microsoft Visual Studio", "devenv"]]
	, "Escape": [["", "ApplicationFrameHost", "Calculator"], ["AutoHotkey Help", "hh"], ["", "mpc-hc64"], ["Windows Photo Viewer", "DllHost"]]} {
	for i, v in v {
		GroupAdd, % k, % v[0] . (v[1] ? " ahk_exe " . RegExReplace(v[1], "i)\.exe") . ".exe" : ""), , , % v[2]  ;? v[0], v[1] = WinTitle, v[2] = ExcludeTitle
	}
}

;========================================================  Run  ================;

for i, v in ["AutoCorrect", "Connection", "Window"] {
	Run, % A_ScriptDir . "\" . v . ".ahk"
}
for i, v in ["QuickTest"] {
	Run, % A_WorkingDir . "\test\" . v . ".ahk"
}

;======================================================== Hook ================;

OnExit("Exit"), OnMessage(0xFF, "UpdateScript")

;=======================================================  Other  ===============;

Exit

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

#If ((WinActive("ahk_group Editor") || WinActive("ahk_group Browser")) && !WinActive("ahk_group Game"))

	~$WheelDown::
	~$WheelUp::
		if (A_TimeSincePriorHotkey >= 50 && MouseGet("Pos", "Window").y <= 80 + 30*(WinActive("ahk_group Browser") > 0)) {
			Send, % "^{" . {"WheelUp": "PgUp", "WheelDown": "PgDn"}[KeyGet(A_ThisHotkey)] . "}"
		}

		return

#If

#If (!WinActive("ahk_group Game"))

	Media_Prev::
	XButton1 & LButton::
		Spotify.Prev()
		return

	Media_Next::
	XButton1 & RButton::
		Spotify.Next()
		return

	Media_Play_Pause::
	XButton1 & MButton::
		Spotify.PlayPause()
		return

	*$XButton1::
		KeyWait, XButton1

		switch (WinGet("ProcessName")) {
			case "7zFM.exe":
				Send, {Backspace}
			case "Spotify.exe":
				Send, !{Left}
			Default:
				Send, {XButton1}
		}

		return

	XButton2 & MButton::
		Send, {Volume_Mute}
		return

	XButton2 & WheelUp::
		Send, {Volume_Up}
		return

	XButton2 & WheelDown::
		Send, {Volume_Down}
		return

	$XButton2::
		KeyWait, XButton2

		switch (WinGet("ProcessName")) {
			case "Spotify.exe":
				Send, !{Right}
			Default:
				Send, {XButton2}
		}

		return

#If

AppsKey & LButton::
	if (!WinGet("MinMax")) {
		before := [WinGet("Pos"), MouseGet("Pos")]  ;~ before

		UpdateWindow:
			if (GetKeyState("Escape", "P")) {
				WinMove, A, , % before[0].x, % before[0].y
			}
			else if (GetKeyState("LButton", "P")) {
				current := [WinGet("Pos"), MouseGet("Pos")]  ;~ current

				WinMove, A, , current[0].x - before[1].x + (before[1].x := current[1].x), current[0].y - before[1].y + (before[1].y := current[1].y)

				SetTimer("UpdateWindow", -25)
			}

			return
	}

	KeyWait("LButton")
	return

~$LButton::
	while (GetKeyState("LButton", "P")) {
		if (k := ((GetKeyState("Up", "P")) ? ("Up") : ((GetKeyState("Left", "P")) ? ("Left") : ((GetKeyState("Down", "P")) ? ("Down") : ((GetKeyState("Right", "P")) ? ("Right") : (0)))))) {
			MouseMove, % Round({"Left": -1, "Right": 1}[k]), % Round({"Up": -1, "Down": 1}[k]), 0, R

			KeyWait(k)
		}

		Sleep, -1
	}

	return

;====================================================== Keyboard ==============;

#If (WinExist("Window Spy ahk_exe AutoHotkey.exe"))

	Esc::WinClose, Window Spy ahk_exe AutoHotkey.exe

	$^c::
		SavedClipboard := ClipboardAll

		ControlGetText, Clipboard, Edit1, Window Spy ahk_exe AutoHotkey.exe
		Clipboard := "/*`n`t" . StrReplace(Clipboard, "`n", "`n`t") . "`n*/"

		HotKey, ~$^v, SinglePaste, On
		return

#If

#If (WinActive("ahk_group Editor"))

	$!F1::
		return

	$F1::
		KeyWait("F1", "T0.25")
		if (ErrorLevel) {
			RegExMatch(WinGet("Title"), "\w+$", extension)  ;~ extension

			if (extension ~= "ahk.*|lib") {
				if (text := RegExReplace(String.Clipboard.Copy(0, 1), "iSs)[^a-z_]*((?<!#(?=[a-z]))[#a-z_]*).*", "$1")) {
					if (extension == "ahk_v2") {
						append := " v2"  ;~ append
					}

					RunActivate("AutoHotkey" . append . " Help ahk_exe hh.exe", A_ProgramFiles . "\AutoHotkey" . append . "\AutoHotkey.chm", , , [-7, 730, 894, 357])  ;* Force the position here to avoid flickering with Window.ahk.

					Send, !n
					Sleep, 200
					Send, ^a
					SendRaw, % text
					Send, {Enter}
				}
				else {
					Run, % Format("{}\bin\Nircmd.exe speak text ""No text.""", A_WorkingDir)
				}
			}

			KeyWait("F1")
		}
		else {
			Send, {F1}
		}

		return

	$^q::
	$^e::
		Send, % (A_ThisHotkey == "$^q") ? ("+{F2}") : ("+{F3}")
		return

	$\::
		if (KeyWait("\", "T0.25")) {
			IniWrite, % Debug := !Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug

			for i, v in WinGet("List", "ahk_class AutoHotkey", , A_ScriptName, , "On") {
				SendMessage(0xFF, -1, , "ahk_id" . v, , , , "On")  ;* Tell other running scripts to update their `Debug` value.
			}

			Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""Debug {}.""", (Debug) ? ("On") : ("Off"))

			KeyWait("\")
			return
		}

		Send, \
		return

	$w::
	$s::
		k := KeyGet(A_ThisHotkey)

		if (KeyWait(k, "T0.25")) {
			Send, % (k == "s") ? ("^{End}") : ("^{Home}")

			KeyWait(k)
			return
		}

		Send, % (CapsLockState) ? (Format("{:U}", k)) : (k)
		return

	$t::
		if (KeyWait("t", "T0.25")) {
			Send, ^+t

			KeyWait("t")
			return
		}

		Send, % (CapsLockState) ? ("T") : ("t")
		return

	$a::
	$d::
		k := KeyGet(A_ThisHotkey)

		if (KeyWait(k, "T0.25")) {
			Send, % (k == "a") ? ("^{Left}") : ("^{Right}")

			if (KeyWait(k, "T0.5")) {
				Send, % (k == "a") ? ("{Home 2}") : ("{End}")
			}

			KeyWait(k)
			return
		}

		Send, % (CapsLockState) ? (Format("{:U}", k)) : (k)
		return

	$c::
		if (KeyWait("c", "T0.25")) {
			text := String.Clipboard.Copy()  ;~ text

			if (text && (v := {"ahk": ";", "lib": ";", "cs": "//", "js": "//", "json": "//", "pde": "//", "elm": "--", "py": "#"}[RegExReplace(WinGet("Title"), "iS).*\.([a-z]+).*", "$1")])) {
				String.Clipboard.Paste((SubStr(text, 1, StrLen(v)) == v ? RegExReplace(text, "`am)^" . v) : RegExReplace(text, "`am)^", v)))
			}
			else {
				Run, % A_WorkingDir . "\bin\Nircmd.exe speak text ""No text."""
			}

			KeyWait("c")
			return
		}

		Send, % (CapsLockState) ? ("C") : ("c")
		return

#If

#If (WinActive("__Rename ahk_exe Explorer.EXE"))

	$F9::
		loop, % "C:\Users\Onimuru\OneDrive\__User\Pictures\__Rename\*.*" {
			extension := RegExReplace(A_LoopFileName, "i).*(\.\w+).*", "$1")  ;~ extension

			loop, % 10 + 5*(extension ~= "gif|mov|mp4|webm" != 0) {
				extension := Math.Random.Uniform(0, 9) . extension
			}

			if (Debug) {
				MsgBox(A_LoopFileName . " --> " . extension . " (" . 10 + 5*(extension ~= "gif|mov|mp4|webm" != 0) . ")")
			}

			FileMove, % A_LoopFilePath, % A_LoopFileDir . "\" . extension
		}

		return

#If

#If (WinActive("ahk_group Browser"))

	$!F1::
		return

	$^q::
	$^e::
		Send, % (A_ThisHotkey == "$^q") ? ("+^g") : ("^g")
		return

	$t::
		if (KeyWait("t", "T0.25")) {
			Send, ^+t

			KeyWait("t")
			return
		}

		Send, % (CapsLockState) ? ("T") : ("t")
		return

	$^f::
		Send, % "^f" . String.Clipboard.Copy(1)
		return

#If

#If (!WinActive("ahk_group Game"))

	$Esc::
		if (DoubleTap()) {
			if (!window && !Desktop()) {
				window := "ahk_id" . WinGet("ID")  ;~ window
			}

			ShowDesktop()

			Sleep, 500

			WinWaitNotActive, window
			if (window && !Desktop()) {
				WinActivate, % window
				WinWaitActive, % window

				window := ""
			}

			KeyWait("Esc")
			return
		}

		if (KeyWait("Esc", "T1")) {
			Run, % A_WorkingDir . "\bin\Nircmd.exe speak text ""Kill screen."""

			KeyWait("Esc")
			BlockInput, On
			SendMessage(0x112, 0xF170, 2, "Off", "Program Manager")  ;? 0x112 = WM_SYSCOMMAND, 0xF170 = SC_MONITORPOWER.

			Input, v, , {Space}

			KeyWait("Space")
			BlockInput, Off
		}
		else if (WinActive("ahk_group Escape") && !WinGet("MinMax")) {
			winTitle := [WinGet("Class"), "ahk_id" . WinGet("ID"), WinGet("Title")]  ;~ winTitle

			WinClose, % winTitle[1]

			WinWaitNotActive, % winTitle[1], , 1
			if (ErrorLevel && winTitle[0] != "#32770") {
				Process, Close, % winTitle[1]

				MsgBox(Format("{} FORCED: {}", Clipboard := A_ThisHotkey, winTitle[2]))
			}
		}
		else {
			Send, {Esc}
		}

		return

	$Space::
		if (KeyWait("Space", "T0.5") && !Desktop()) {
			winTitle := ["ahk_id" . WinGet("ID"), WinGet("Transparent") == 255]  ;~ winTitle

			if (winTitle[1]) {
				FadeWindow("Out", 35, 500, winTitle[0])
			}

			KeyWait("Space")
			if (winTitle[1]) {  ;* This will fail if the window was not initially hidden with this hotkey.
				FadeWindow("In", 255, 500, winTitle[0])
			}
			return
		}

		Send, {Space}
		return

	$Delete::
		if (KeyWait("Del", "T0.5")) {
			RunActivate("Recycle Bin ahk_exe Explorer.exe", "::{645FF040-5081-101B-9F08-00AA002F954E}")

			if (KeyWait("Del", "T2")) {
				FileRecycleEmpty

				if (KeyWait("Del", "T2")) {
					WinClose, Recycle Bin ahk_exe Explorer.exe
				}
			}

			KeyWait("Del")
			return
		}

		Send, {Del}
		return

	Insert::
		Run, % A_WinDir . "\System32\SndVol.exe"
		return

#If

#If (WinActive(A_ScriptName))

	$F10::
		ListVars
		return

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

AppsKey & F1::
	RunActivate("ahk_exe Discord.exe", "C:\Users\Onimuru\AppData\Local\Discord\Update.exe --processStart Discord.exe")

	KeyWait("F1")
	return

AppsKey & F2::
	RunActivate("ahk_exe Spotify.exe", "C:\Users\Onimuru\AppData\Local\Microsoft\WindowsApps\Spotify.exe")

	KeyWait("F2")
	return

AppsKey & F4::
	if (!Desktop()) {
		if (WinActive("Google Chrome ahk_exe chrome.exe")) {
			Send, ^w

			if (!KeyWait("F4", "T0.5")) {
				return
			}
		}

		winTitle := [WinGet("Class"), "ahk_id" . WinGet("ID"), WinGet("Title")]  ;~ winTitle

		WinClose, % winTitle[1]

		WinWaitNotActive, % winTitle[1], , 1
		if (ErrorLevel && winTitle[0] != "#32770") {
			Process, Close, % winTitle[1]

			MsgBox(Format("{} FORCED: {}", Clipboard := A_ThisHotkey, winTitle[2]))
		}
	}

	KeyWait("F4")
	return

AppsKey & F5::
	RunActivate("ahk_exe chrome.exe", Format("{} (x86)\Google\Chrome\Application\chrome.exe", A_ProgramFiles))

	KeyWait("F5")
	return

AppsKey & F7::
	RunActivate("ahk_exe Code.exe", Format("{}\Microsoft VS Code\Code.exe", A_ProgramFiles))

	KeyWait("F7")
	return

AppsKey & F8::
	if (!WinExist("ahk_class CabinetWClass")) {
		Run, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}
		WinWait, This PC ahk_class CabinetWClass
	}

	GroupActivate, Explorer, R
	GroupAdd, Explorer, ahk_class CabinetWClass

	KeyWait("F8")
	return

AppsKey & F11::
	RunActivate("Notepad++ ahk_exe notepad++.exe", Format("{} (x86)\Notepad++\notepad++.exe", A_ProgramFiles))

	KeyWait("F11")
	return

AppsKey & F12::
	Menu("WindowSpy")

	KeyWait("F12")
	return

AppsKey & 1::
AppsKey & 2::
AppsKey & 9::
AppsKey & [::
	v := {1: [Chr(39), Chr(39)], 2: [Chr(34), Chr(34)], 9: [Chr(40), Chr(41)], "[" : [Chr(91), Chr(93)]}[SubStr(A_ThisHotkey, 0)]

	if (text := String.Clipboard.Copy()) {  ;~ text
		String.Clipboard.Paste(v[0] . text . v[1], 1)
	}

	return

AppsKey & `::SetSystemCursor()

$`::
	if (DoubleTap()) {
		if (KeyWait("``", "T0.5")) {
			DllCall("SystemParametersInfo", "UInt", 0x70, "UInt", 0, "UIntP", originalSpeed, "UInt", 0)  ;~ originalSpeed  ;? 0x70 = SPI_GETMOUSESPEED.
			DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", 2, "UInt", 0)  ;? 0x71 = SPI_SETMOUSESPEED (range is 1-20, default is 10).

			KeyWait("``")
			DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", originalSpeed, "UInt", 0)

			return
		}
	}

	Send, {``}
	KeyWait("``")

	return

AppsKey & Tab::
	String.Clipboard.Paste("`t")
	return

$+CapsLock::
$^CapsLock::
	Send, % SubStr(A_ThisHotkey, 2, 1) . "{Home}"
	return

AppsKey & CapsLock::
	SetCapsLockState, % (CapsLockState := !CapsLockState) ? ("On") : ("AlwaysOff")
	SetTimer(A_ThisHotkey, (CapsLockState) ? (-30000) : ("Delete"))
$!CapsLock::
	return

$CapsLock::
	if (KeyWait("CapsLock", "T0.25")) {
		if (String.Clipboard.Copy(1)) {
			Menu, Case, Show  ; ** Need a different script to handle hiding this menu, the thread is locked up. **
		}

		KeyWait("CapsLock")
		return
	}

	Send, {Home}
	return

AppsKey & Space::
	if (!Desktop()) {
		if (WinGet("Transparent") == 255) {
			FadeWindow("Out", 35, 1000, "ahk_id" . WinGet("ID"))
		}
		else {
			FadeWindow("In", 255, 1500, "ahk_id" . WinGet("ID"))
		}
	}
	return

AppsKey & Enter::
	String.Clipboard.Paste("`r`n")
	return

;$!q::
;	return

AppsKey & q::
	if (coordinates == "Delete") {
		Clipboard := SavedClipboard
		coordinates := ""

		Gui, Coordinates: Destroy
	}
	else if (coordinates := !coordinates) {  ;~ coordinates
		Gui, Coordinates: New, -Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20
		Gui, Color, 0xFFFFFF
		WinSet, TransColor, 0xFFFFFF 255
		Gui, Font, s30
		Gui, Add, Text, c0x3FFEFF, XXXX YYYY (CxCCCCCC)
		ControlSetText, Static1  ;* Set the text to "XXXX YYYY (CxCCCCCC)" in order to size the control properly and then reset it to avoid flickering.
		Gui, Show, x5 y5 NA

		UpdateGui:
			v := MouseGet("Pos")
			Pixelgetcolor, c, v.x, v.y

			ControlSetText, Static1, % text := Format("{}, {}", v.x, v.y) . ((GetKeyState("Ctrl", "P")) ? (Format(" ({})", c)) : ("")), % A_ScriptName  ;~ text

			SetTimer("UpdateGui", -25)
			return
	}
	else if (!coordinates) {
		SavedClipboard := ClipboardAll
		Clipboard := text

		SetTimer("UpdateGui", (coordinates := "Delete"))
	}

	KeyWait("q")
	return

AppsKey & t::
	if (!Desktop()) {
		WinSet, AlwaysOnTop, Toggle, A

		WinGetTitle, v, A
		WinSetTitle, A, , % ((SubStr(v, 1, 2) != "▲ ") ? "▲ " . v : SubStr(v, 3))  ; ** Need a better way to identify a window as AoT. **
	}

	KeyWait("t")
	return

AppsKey & s::
	SplashImage, , % "B1C01 CWFFFFFF CT000000", % "[R] Restart`n[S] Shutdown`n[L] Log Off`n`n[H] Hibernate`n[P] Sleep", % "Press a key:", , Courier New

	Input, v, L1T5
	SplashImage, Off

	if (v ~= "r|s|l|h|p") {
		switch (v) {
			case "r":
				ShutDown, 2
			case "s":
				ShutDown, 8
			case "l":
				ShutDown, 0
			case "h":
				DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
			case "p":
				DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
		}
	}

	return

AppsKey & g::
	if (text := String.Clipboard.Copy(1, 1)) {  ;~ text
		Run, % Format("{}\Google\Chrome\Application\chrome.exe {}", A_ProgramFiles, (text ~= "i)(http|ftp)s?:\/\/|w{3}\.") ? (RegExReplace(text, "iS).*?(((http|ftp)s?|w{3})[a-z0-9-+&./?=#_%@:]+)(.|\s)*", "$1")) : ("www.google.com/search?&q=" . StrReplace(text, A_Space, "+")))
	}

	KeyWait("g")
	return

AppsKey & h::
	if (HiddenWindows.Length < 50) {
		if (Desktop()) {
			MsgBox("The desktop and taskbar may not be hidden.")

			return
		}

		WinWaitActive, A
		v := "        " . ((v := WinGet("Title")) ? (v) : (WinGet("ProcessName"))) . " (" . WinGet("ID") . ")"

		if (WinExist("ahk_id" . RegExReplace(v, ".*?\((0x.*?)\)", "$1"))) {
			Send, !{Esc}  ;* Because hiding the window won't deactivate it, activate the window beneath this one.
			WinHide

			if (!HiddenWindows.Includes(v)) {  ;* Ensure that this window doesn't already exist in the array.
				Menu, Tray, Delete, % 15 + HiddenWindows.Length . "&"  ;* Move the "Exit" menu item to the bottom.
				Menu, Tray, Delete, % 14 + HiddenWindows.Length . "&"

				HiddenWindows.Push(v)

				Menu, Tray, Add, % v, Menu
				Menu, Tray, Add, [11] Exit, Menu
				Menu, Tray, Add, , Menu
			}
		}
		else {
			throw (Exception("!!!!!", -1, Format("""{}"" is invalid.", v)))
		}
	}
	else {
		throw (Exception("Limit.", -1, "No more than 50 windows may be hidden simultaneously."))
	}

	KeyWait("h")
	return

AppsKey & u::
	if (v := HiddenWindows.Length) {
		Menu(HiddenWindows[--v])
	}

	KeyWait("u")
	return

AppsKey & c::
	RunActivate("Calculator ahk_exe ApplicationFrameHost.exe", "calc.exe")

	KeyWait("c")
	return

AppsKey & v::
	if (Clipboard) {
		String.Clipboard.Paste(Clipboard)
	}

	KeyWait("v")
	return

AppsKey & PrintScreen::
	Send, +#s
	return

AppsKey & ScrollLock::
	Run, % Format("{}\bin\Camera", A_WorkingDir)
	return

Pause::
	Run, % Format("*RunAs {}\System32\WindowsPowerShell\v1.0\powershell.exe", A_WinDir)
	return

AppsKey & Up::
AppsKey & Left::
AppsKey & Down::
AppsKey & Right::
	k := KeyGet(A_ThisHotkey)

	MouseMove, % Round({"Left": -1, "Right": 1}[k]), % Round({"Up": -1, "Down": 1}[k]), 0, R
	return

*$Up::
*$Left::
*$Down::
*$Right::
	if (GetKeyState("LButton", "P")) {
		KeyWait(KeyGet(A_ThisHotkey))
		return
	}

	Send, % "{" . KeyGet(A_ThisHotkey) . "}"
	return

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\lib\Color.lib
#Include, %A_ScriptDir%\..\lib\GDIp.lib
#Include, %A_ScriptDir%\..\lib\General.lib
#Include, %A_ScriptDir%\..\lib\Geometry.lib
#Include, %A_ScriptDir%\..\lib\Math.lib
#Include, %A_ScriptDir%\..\lib\ObjectOriented.lib
#Include, %A_ScriptDir%\..\lib\String.lib

;===============  Label  =======================================================;

;============== Function ======================================================;

UpdateScript(wParam := 0, lParam := 0) {
	switch (wParam) {
		case -1:
			IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug

			return (Debug)

		case 2:
			Menu, Tray, ToggleCheck, [&9] Suspend
			if (!A_IsPaused) {
				Menu, Tray, Icon, % ((!A_IsSuspended) ? ("mstscax.dll") : ("wmploc.dll")), % ((!A_IsSuspended) ? (10) : (136)), 1
			}

			Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", ((A_IsSuspended) ? ("You're suspended young lady!") : ("Carry on...")))

			return, (A_IsSuspended)
	}

	return (0)
}

Exit(exitReason := "", exitCode := "") {  ;? ExitReason: Close || Error || Exit || Logoff || Menu || Reload || Restart || ShutDown || Single
	Critical, On

	SetSystemCursor("Restore")
	Menu("RestoreAll")

	if (exitReason && exitReason ~= "Close|Error|Exit|Menu|Restart") {  ;* Need this check to avoid double calling when `ExitApp` is called internally for script close. It isn't a big deal, only to avoid throwing an error with `WinGet()`.
		DetectHiddenWindows, On

		for i, v in WinGet("List", "ahk_class AutoHotkey", , A_ScriptName) {  ;* Close all AutoHotkey processes.
			PostMessage(0x111, 65307, , "ahk_id" . v)
		}
	}

	ExitApp
}

Menu(thisMenuItem := "", thisMenuItemPos := 0, thisMenu := "Tray") {
	switch (thisMenu) {
		case "Case":
			s := String.Clipboard.Copy()

			switch (RegExReplace(thisMenuItem, "iS).*?([a-z])", "$1")) {
				case "Sentencecase":
					s := RegExReplace(Format("{:L}", s), "S)((?:^|[.!?]\s*)[a-z])", "$U1")

					for i, v in ["I", "Dr", "Mr", "Ms", "Mrs"] {
						s := RegExReplace(s, "i)\b" . v . "\b", v)
					}

				case "iNVERSE":
					s := String.Inverse(s)

				case "Reverse":
					s := String.Reverse(s)

				Default:
					s := Format("{:" . SubStr(thisMenuItem, 6, 1) . "}", s)
			}

			String.Clipboard.Paste(s)

		case "Tray":
			switch (RegExReplace(thisMenuItem, "iS).*?([a-z])", "$1")) {
				case "Edit":
					Edit, % A_ScriptName

				case "OpenScriptFolder":
					Run, % "explorer.exe /select," . A_ScriptDir . "\" . A_ScriptName

				case "WindowSpy":
					w := "ahk_id" . WinGet("ID")

					RunActivate("Window Spy ahk_exe AutoHotkey.exe", A_ProgramFiles . "\AutoHotkey\WindowSpy.ahk", , , [50, 35])

					if (WinExist(w)) {
						WinActivate, % w
					}
					else {  ;* Launched with script menu.
						Send, !{Esc}  ;* Restore focus away from the taskbar.
					}

				case "ListLines":
					ListLines

					Sleep, 100
					Send, ^{End}

				case "ListVars":
					ListVars

				case "ListHotkeys":
					ListHotkeys

				case "KeyHistory":
					KeyHistory

					Sleep, 100
					Send, ^{End}

				case "Pause":
					Menu, Tray, ToggleCheck, [&8] Pause
					if (!A_IsSuspended) {
						Menu, Tray, Icon, % (A_IsPaused) ? ("mstscax.dll") : ("wmploc.dll"), % (A_IsPaused) ? (10) : (136), 1
					}

					Pause, -1, 1
					Run, % Format("{}\bin\Nircmd.exe speak text ""{}.""", A_WorkingDir, (A_IsPaused) ? ("Paused") : ("Unpaused"))

				case "Suspend":
					w := "ahk_id" . WinGet("ID")

					Menu, Tray, ToggleCheck, [&9] Suspend
					if (!A_IsPaused)
						Menu, Tray, Icon, % (A_IsSuspended) ? ("mstscax.dll") : ("wmploc.dll"), % (A_IsSuspended) ? (10) : (136), 1

					Suspend, -1
					Run, %  Format("{}\bin\Nircmd.exe speak text ""{}.""", A_WorkingDir, A_IsSuspended ? "You're suspended young lady!" : "Carry on...")

					if (WinExist(w)) {
						WinActivate, % w
					}
					else {
						Send, !{Esc}
					}

				case "RestoreAll":
					w := "ahk_id" . WinGet("ID")

					loop, % s := HiddenWindows.Length {
						Menu(HiddenWindows[--s])
					}

					WinActivate, % w

				case "Exit":
					Exit()

				Default:
					w := "ahk_id" . RegExReplace(thisMenuItem, ".*?\((0x.*?)\)", "$1")

					WinShow, % w
					WinActivate, % w

					DetectHiddenWindows, Off

					if (!WinExist(w)) {
						MsgBox(Format("There was an error unhiding this window ({}). Please contact your system administrator.", thisMenuItem))
					}

					DetectHiddenWindows, % DetectHiddenWindows

					Menu, Tray, Delete, % thisMenuItem
					HiddenWindows.RemoveAt(HiddenWindows.IndexOf(thisMenuItem))
			}
	}
}

SetSystemCursor(mode := "") {
	Static default := (v := __GetSystemCursors()).Default, hide := v.Hide, show := v.Show
		, internal, mouse

	if (mode == "Timer" && MouseGet("Pos").Print() == mouse.Print()) {
		if (internal == "Hide") {
			SetTimer(Func(A_ThisFunc).Bind("Timer"), -50)
		}

		return
	}

	internal := ["Show", "Hide"][internal != "Hide" && mode != "Restore"]

	if (internal == "Hide") {
		mouse := MouseGet("Pos")

		SetTimer(Func(A_ThisFunc).Bind("Timer"), -50)
	}

	for i, v in default {
		DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", %internal%[i], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", v)
	}
}

__GetSystemCursors() {
	default := [], hide := [], show := []

	VarSetCapacity(v1, 128, 0xFF), VarSetCapacity(v2, 128, 0)
	for i, v in (default := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]) {
		hide[i] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", &v1, "Ptr", &v2), show[i] := DllCall("CopyImage", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", v), "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
	}

	return {"Default": default, "Hide": hide, "Show": show}
}

SinglePaste() {
	Sleep, 50
	Clipboard := SavedClipboard

	HotKey, ~$^v, SinglePaste, Off
}
