;=====         Auto-execute         =========================;
;===============            Admin             ===============;

If (!(A_IsAdmin || RegExMatch(DllCall("GetCommandLine", "Str"), " /restart(?!\S)"))) {
    Try
		Run, % "*RunAs " . v := [A_ProgramFiles . "\AutoHotkey\AutoHotkey.exe /restart " . A_ScriptFullPath, A_ScriptFullPath . " /restart"][Round(A_IsCompiled)]
    ExitApp
}

;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\lib\General.ahk
#Include, %A_ScriptDir%\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\lib\String.ahk

#InstallKeybdHook
#InstallMouseHook
#KeyHistory, 0
#NoEnv  ;* #NoEnv is recommended for all scripts, it disables environment variables.
#SingleInstance, Force
#WinActivateForce

AutoTrim, Off
CoordMode, Mouse, Screen
ListLines, Off
Process, Priority, , R
SendMode, Input
SetBatchLines, -1
SetCapsLockState, AlwaysOff
SetControlDelay, -1
SetDefaultMouseSpeed, 0
SetKeyDelay, -1, -1  ;* Even though `SendInput` ignores `SetKeyDelay`, `SetMouseDelay` and `SetDefaultMouseSpeed`, having these delays at -1 improves `SendEvent` speed just in case `SendInput` is not available and falls back to `SendEvent`. ;? Default = 10.
SetMouseDelay, -1
SetNumlockState, AlwaysOn
SetScrollLockState, AlwaysOff
SetTitleMatchMode, 2
SetWinDelay, -1
SetWorkingDir, % A_ScriptDir . "\.."

;===============            Group             ===============;

For k, v in {"Browser": [["Google Chrome", "chrome"]]
	, "Editor" : [["Notepad++", "notepad++"], ["", "Code"]]
	, "Escape": [["", "ApplicationFrameHost", "Calculator"], ["AutoHotkey Help", "hh"]]}
	For i, v in v
		GroupAdd, % k, % v[0] . (v[1] ? " ahk_exe " . RegExReplace(v[1], "i)\.exe") . ".exe" : ""), , , % v[2]

;===============             Menu             ===============;

Menu, Tray, Tip, Text
Menu, Tray, Color, 0xFFFFFF, Single
Menu, Tray, Icon, mstscax.dll, 10, 1  ;? https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/.
Menu, Tray, NoStandard
For k, v in {"Case": ["", "[&1] lowercase", "[&2] UPPERCASE", "[&3] Sentence case", "[&4] Title Case", "", "[&5] iNVERSE", "[&6] Reverse", ""]
	, "Tray": ["", "[&1] Edit", "[&2] Open Script Folder", "[&3] Window Spy", "[&4] List Lines", "[&5] List Vars", "[&6] List Hotkeys", "[&7] KeyHistory", "", "[&8] Pause", "[&9] Suspend", "", "[10] Restore All", "[11] Exit", ""]}
	For i, v in v
		Menu, % k, Add, % v, Menu

;===============             Run              ===============;

For i, v in ["AutoCorrect", "Connection", "QuickTest", "Window"]
	Run, % "*RunAs " . A_ScriptDir . "/" . v . ".ahk"

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global vDebug
	, vDetectHiddenWindows := A_DetectHiddenWindows, vKeyDelay := A_KeyDelay, vIsSuspended := A_IsSuspended
	, vClipboard

oHiddenWindows := []

;===============            Other             ===============;

OnExit("Exit"), OnMessage(0xFF, "StatusReport")

Exit

;=====           Function           =========================;

Exit(vExitReason := "", vExitCode := "") {  ;? ExitReason: Close || Error || Exit || Logoff || Menu || Reload || Restart || ShutDown || Single
	Critical

	SetSystemCursor("Restore")
	Menu("RestoreAll")

	If (vExitReason && vExitReason != "Reload") {  ;* Need this check to avoid double calling when `ExitApp` is called internally for script close. Its not a big deal, only to avoid throwing an error with `WinGet()`.
		For i, v in WinGet("List", "ahk_class AutoHotkey", , A_ScriptName, , "On") {  ;* Close all AutoHotkey processes.
			PostMessage(0x111, 65307, , , "ahk_id" . v, , , , "On")
		}
	}

	ExitApp
}

StatusReport(wParam := "") {
	If (wParam == 1) {
		Menu, Tray, ToggleCheck, [&9] Suspend
		If (!A_IsPaused) {
			Menu, Tray, Icon, % (!A_IsSuspended ? "mstscax.dll" : "wmploc.dll"), % (!A_IsSuspended ? 10 : 136), 1
		}

		Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", A_IsSuspended ? "You're suspended young lady!" : "Carry on...")
	}

	Return, (A_IsSuspended)
}

Menu(vThisMenuItem := "", vThisMenuItemPos := 0, vThisMenu := "Tray") {
	Global oHiddenWindows

	Switch (vThisMenu) {
		Case "Case":
			s := String.Clipboard.Copy()

			Switch (RegExReplace(vThisMenuItem, "iS).*?([a-z])", "$1")) {
				Case "Sentencecase":
					s := RegExReplace(Format("{:L}", s), "S)((?:^|[.!?]\s*)[a-z])", "$U1")

					For i, v in ["I", "Dr", "Mr", "Ms", "Mrs"] {
						s := RegExReplace(s, "i)\b" . v . "\b", v)
					}
				Case "iNVERSE":
					s := s.Inverse()
				Case "Reverse":
					s := s.Reverse()
				Default:
					s := Format("{:" . SubStr(vThisMenuItem, 6, 1) . "}", s)
			}

			String.Clipboard.Paste(s)

		Case "Tray":
			Switch (RegExReplace(vThisMenuItem, "iS).*?([a-z])", "$1")) {
				Case "Edit":
					Edit, % A_ScriptName
				Case "OpenScriptFolder":
					Run, % "explorer.exe /select," . A_ScriptDir . "\" . A_ScriptName
				Case "WindowSpy":
					w := "ahk_id" . WinGet("ID")

					RunActivate("Window Spy ahk_exe AutoHotkey.exe", A_ProgramFiles . "\AutoHotkey\WindowSpy.ahk", , , {"x": 50, "y": 35})

					If (WinExist(w)) {
						WinActivate, % w
					}
					Else {  ;* Launched with script menu.
						Send, !{Esc}
					}
				Case "ListLines":
					ListLines

					Sleep, 100
					Send, ^{End}
				Case "ListVars":
					ListVars
				Case "ListHotkeys":
					ListHotkeys
				Case "KeyHistory":
					KeyHistory

					Sleep, 100
					Send, ^{End}
				Case "Pause":
					Menu, Tray, ToggleCheck, [&8] Pause
					If (!A_IsSuspended) {
						Menu, Tray, Icon, % (A_IsPaused ? "mstscax.dll" : "wmploc.dll"), % (A_IsPaused ? 10 : 136), 1
					}

					Pause, -1, 1
					Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", A_IsPaused ? "Paused" : "Unpaused")
				Case "Suspend":
					w := "ahk_id" . WinGet("ID")

					Menu, Tray, ToggleCheck, [&9] Suspend
					If (!A_IsPaused)
						Menu, Tray, Icon, % (A_IsSuspended ? "mstscax.dll" : "wmploc.dll"), % (A_IsSuspended ? 10 : 136), 1

					Suspend, -1
					Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", A_IsSuspended ? "You're suspended young lady!" : "Carry on...")

					If (WinExist(w)) {
						WinActivate, % w
					}
					Else {
						Send, !{Esc}
					}
				Case "RestoreAll":
					w := WinGet("ID")

					Loop, % s := oHiddenWindows.Length {
						Menu(oHiddenWindows[--s])
					}

					WinActivate, % "ahk_id" . w
				Case "Exit": Exit()
				Default:
					WinShow, % w := "ahk_id" . SubStr(vThisMenuItem, -7, -1)
					WinActivate, % w

					DetectHiddenWindows, Off

					If (!WinExist(w)) {
						MsgBox("There was an error unhiding this window (" . vThisMenuItem . "). Please contact your system administrator.")
					}

					DetectHiddenWindows, % vDetectHiddenWindows

					Menu, Tray, Delete, % vThisMenuItem
					oHiddenWindows.RemoveAt(oHiddenWindows.IndexOf(vThisMenuItem))
			}
	}
}

SetSystemCursor(_Mode := "") {
	Static vDefault := [], vHide := [], vShow := [], vMode , vMouseGet
	If (!vDefault.Length) {
		VarSetCapacity(v1, 128, 0xFF), VarSetCapacity(v2, 128, 0)
		For i, v in (vDefault := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]) {
			vHide[i] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", &v1, "Ptr", &v2)
			vShow[i] := DllCall("CopyImage", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", v), "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
		}
	}

	If (_Mode == "Timer" && (v := MouseGet("Pos")).x == vMouseGet.x && v.y == vMouseGet.y) {
		If (vMode == "Hide") {
			SetTimer(Func(A_ThisFunc).Bind("Timer"), -50)
		}
		Return
	}

	If ((vMode := ["Show", "Hide"][vMode != "Hide" && _Mode != "Restore"]) == "Hide") {
		vMouseGet := MouseGet("Pos")

		SetTimer(Func(A_ThisFunc).Bind("Timer"), -50)
	}

	For i, v in vDefault {
		DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", v%vMode%[i], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", v)
	}
}

;=====            Hotkey            =========================;
;===============            Mouse             ===============;

#If (WinActive("ahk_group Editor") || WinActive("ahk_group Browser"))

	~$WheelDown::
	~$WheelUp::
		If (A_TimeSincePriorHotkey >= 50 && MouseGet("Pos", "Window").y <= 80 + 30*(WinActive("ahk_group Browser") > 0)) {
			Send, % "^{" . {"~$WheelUp": "PgUp", "~$WheelDown": "PgDn"}[A_ThisHotkey] . "}"
		}
		Return

#If

AppsKey & LButton::
	If (!WinGet("MinMax")) {
		vMouseGet := [{"x": (v := [WinGet("Pos"), MouseGet("Pos")])[0].x, "y": v[0].x}, {"x": v[1].x, "y": v[1].y}]

		UpdateWindow:
			If (GetKeyState("Escape", "P")) {
				WinMove, A, , % vMouseGet[0].x, % vMouseGet[0].y
			}
			Else If (GetKeyState("LButton", "P")) {
				WinMove, A, , (v := [WinGet("Pos"), MouseGet("Pos")])[0].x - vMouseGet[1].x + vMouseGet[1].x := v[1].x, v[0].y - vMouseGet[1].y + vMouseGet[1].y := v[1].y

				SetTimer("UpdateWindow", -25)
			}
			Return
	}

	KeyWait("LButton")
	Return

NumLock::
XButton1 & LButton::
NumpadMult::
XButton1 & RButton::
NumpadDiv::
XButton1 & MButton::PostMessage(0x0319, , {"NumLock": 0xC0000, "XButton1 & LButton": 0xC0000, "NumpadMult": 0xB0000, "XButton1 & RButton": 0xB0000, "NumpadDiv": 0xE0000, "XButton1 & MButton": 0xE0000}[A_ThisHotkey], , "ahk_exe Spotify.exe", , , , "On")  ;* You have to record and use the PID if you don"t disable Hardware Media Key Handling (chrome://flags/#hardware-media-key-handling) because there is no way to discriminate between Chrome and Spotify with Class, Exe or Title since Spotify is an Electron application.
$XButton1::
	Switch (WinGet("ProcessName")) {
		Case "7zFM.exe":
			Send, {Backspace}
		Case "Spotify.exe":
			Send, !{Left}
		Default:
			Send, {XButton1}
	}
	Return

NumpadDot::
XButton2 & MButton::Send, {Volume_Mute}
NumpadSub::
XButton2 & WheelUp::Send, {Volume_Up}
NumpadAdd::
XButton2 & WheelDown::Send, {Volume_Down}
$XButton2::
	Switch (WinGet("ProcessName")) {
		Case "Spotify.exe":
			Send, !{Right}
		Default:
			Send, {XButton2}
	}
	Return

;===============           Keyboard           ===============;

#If (WinActive("ahk_group Browser"))

	$!F1::Return

	$1::
	$2::
	$3::
	$4::
	$5::
	$6::
	$7::
	$8::
	$9::
	$0::
		If (KeyWait(k := KeyGet(A_ThisHotkey), "T0.25")) {
			Send, % "^" . k

			KeyWait(k)
			Return
		}

		Send, % k
		Return

	$^q::
	$^e::Send, % "^" . ["+"][A_ThisHotkey == "$^e"] . "g"

	$t::
		If (KeyWait("t", "T0.25")) {
			Send, ^+t

			KeyWait("t")
			Return
		}

		Send, % ["+"][!vSetCapsLockState] . "t"
		Return

	$^f::Send, % "^f" . String.Clipboard.Copy(1)

	$n::
		If (KeyWait("n", "T0.25")) {
			;! ControlGet, vControlGet, HWND, , Chrome_RenderWidgetHostHWND1, % (vWinGet := Winget("ID"))

			Send, ^l
			Sleep, 50
			vString := String.Clipboard.Copy(1)

			Send, ^w

			Run, % A_ProgramFiles . " (x86)\Google\Chrome\Application\chrome.exe --new-window " . vString

			;! ControlFocus, , % "ahk_id" . vControlGet
			;! ControlSend, Chrome_RenderWidgetHostHWND1, ^w, % "ahk_id" . vWinGet

			KeyWait("n")
			Return
		}

		Send, % ["+"][!vSetCapsLockState] . "n"
		Return

#If (WinActive("ahk_group Editor"))

	$!F1::Return
	$F1::
		KeyWait("F1", "T0.25")
		If (ErrorLevel) {
			If (RegExReplace(WinGet("Title"), "iS).*\.([a-z]+).*", "$1") == "ahk") {
				If (vString := RegExReplace(String.Clipboard.Copy(0, 1), "iSs)[^a-z_]*((?<!#(?=[a-z]))[#a-z_]*).*", "$1")) {  ;! "iSs).*?((?=#?[a-z])#?[a-z_]*).*"
					RunActivate("AutoHotkey Help ahk_exe hh.exe", A_ProgramFiles . "\AutoHotkey\AutoHotkey.chm", , , {"x": -7, "y": 730, "Width": 894, "Height": 357})  ;* Force the position here to avoid flickering with `Window.ahk`

					;! SetKeyDelay, 100

					Send, !n
					Sleep, 200
					Send, ^a
					SendRaw, % vString  ;* `SendRaw` to handle `{#}` and `{_}`.
					Send, {Enter}

					;! SetKeyDelay, vKeyDelay
				}
				Else {
					Run, % A_WorkingDir . "\bin\Nircmd.exe speak text ""No text."""
				}
			}

			KeyWait("F1")
			Return
		}

		Send, {F1}
		Return

	~$F10::
		If (WinActive(A_ScriptName)) {
			ListVars
		}
		Return

	$1::
	$2::
	$3::
	$4::
	$5::
	$6::
	$7::
	$8::
	$9::
	$0::
		If (KeyWait(k := KeyGet(A_ThisHotkey), "T0.25")) {
			Send, % "!" . k

			KeyWait(k)
			Return
		}

		Send, % k
		Return

	$^q::
	$^e::Send, % ["+"][A_ThisHotkey == "$^e"] . "{F3}"

	$\::
		If (KeyWait("\", "T0.25")) {
			IniWrite, % vDebug := {"On": "Off", "Off": "On"}[vDebug], % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
			Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""Debug {}.""", vDebug)

			KeyWait("\")
			Return
		}

		Send, \
		Return

	$w::
	$s::
		If (KeyWait(k := KeyGet(A_ThisHotkey), "T0.25")) {
			Send, % "^{" . {"$s": "End", "$w": "Home"}[A_ThisHotkey] . "}"

			KeyWait(k)
			Return
		}

		Send, % ["+"][!vSetCapsLockState] . k
		Return

	~$^s::
		Critical

		If (WinActive(A_ScriptName)) {
			Sleep, 200
			Reload
		}
		Return

	$t::
		If (KeyWait("t", "T0.25")) {
			Send, ^+t

			KeyWait("t")
			Return
		}

		Send, % ["+"][!vSetCapsLockState] . "t"
		Return

	$a::
	$d::
		If (KeyWait(k := KeyGet(A_ThisHotkey), "T0.25")) {
			Send, % "^{" . {"$a": "Left", "$d": "Right"}[A_ThisHotkey] . "}"

			If (KeyWait(k, "T0.25")) {
				Send, % "{" . {"$a": "Home 2", "$d": "End"}[A_ThisHotkey] . "}"
			}

			KeyWait(k)
			Return
		}

		Send, % ["+"][!vSetCapsLockState] . k
		Return

	$k::
		If (KeyWait("k", "T0.25")) {
			Send, % {"pde": "+^b", "py": "!^k"}[RegExReplace(WinGet("Title"), "iS).*\.([a-z]+).*", "$1")]

			KeyWait("k")
			Return
		}

		Send, % ["+"][!vSetCapsLockState] . "k"
		Return

	$c::
		If (KeyWait("c", "T0.25")) {
			If ((vString := String.Clipboard.Copy()) && (v := {"ahk": ";", "cs": "//", "js": "//", "json": "//", "pde": "//", "py": "#"}[RegExReplace(WinGet("Title"), "iS).*\.([a-z]+).*", "$1")])) {
				String.Clipboard.Paste((SubStr(vString, 1, StrLen(v)) == v ? RegExReplace(vString, "`am)^" . v) : RegExReplace(vString, "`am)^", v)))
			}
			Else {
				Run, % A_WorkingDir . "\bin\Nircmd.exe speak text ""No text."""
			}

			KeyWait("c")
			Return
		}

		Send, % ["+"][!vSetCapsLockState] . "c"
		Return

	$^v::
		If (RegExReplace(WinGet("Title"), "iS).*\.([a-z]+).*", "$1") == "ahk" && Math.IsEven(String.Count(Clipboard, Chr(39)))) {  ;* This is a very basic test. "I'll go get the money we're owed." passes for instance.
			Clipboard := StrReplace(Clipboard, Chr(39), Chr(34))
		}

		Send, ^v
		Return

#If (WinExist("Window Spy ahk_exe AutoHotkey.exe"))

	Esc::WinClose, Window Spy ahk_exe AutoHotkey.exe

	$^c::
		vClipboard := ClipboardAll

		ControlGetText, Clipboard, Edit1, Window Spy ahk_exe AutoHotkey.exe
		Clipboard := "/*`n`t" . StrReplace(Clipboard, "`n", "`n`t") . "`n*/"

		HotKey, ~$^v, SinglePaste, On
		Return

	SinglePaste:
		Sleep, 25
		Clipboard := vClipboard

		HotKey, ~$^v, SinglePaste, Off
		Return

#If

AppsKey & F1::
	If (!WinExist("ahk_class CabinetWClass")) {
		Run, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}
		WinWait, This PC ahk_class CabinetWClass
	}

	GroupActivate, Explorer, R
	GroupAdd, Explorer, ahk_class CabinetWClass

	KeyWait("F1")
	Return

AppsKey & F2::
AppsKey & F3::
	RunActivate("ahk_exe" . ({"F2": "Code", "F3": "chrome"}[k := KeyGet(A_ThisHotkey)]) . ".exe", A_ProgramFiles . ({"F2": "\Microsoft VS Code\Code", "F3": " (x86)\Google\Chrome\Application\chrome"}[k]) . ".exe", "Max")

	KeyWait(k)
	Return

AppsKey & F4::
	If (WinGet("Style") & 0x00040000) {
		If (WinActive("Google Chrome ahk_exe chrome.exe")) {
			Send, ^w

			If (!KeyWait("F4", "T0.5")) {
				Return
			}
		}
		WinClose, % (vWinGet := [WinGet("Class"), "ahk_id" . WinGet("ID"), WinGet("Title")])[1]

		WinWaitNotActive, % vWinGet[1], , 1
		If (ErrorLevel && vWinGet[0] != "#32770") {
			Process, Close, % vWinGet[1]

			MsgBox("$F4- FORCED: " . vWinGet[2])
		}
	}

	KeyWait("F4")
	Return

$F11::
	If (KeyWait("F11", "T0.5")) {
		RunActivate("Notepad++ ahk_exe notepad++.exe", A_ProgramFiles . " (x86)\Notepad++\notepad++.exe")

		KeyWait("F11")
		Return
	}

	Send, {F11}
	Return

$F12::
	If (KeyWait("F12", "T0.5")) {
		Menu("WindowSpy")

		KeyWait("F12")
		Return
	}

	Send, {F12}
	Return

AppsKey & 1::
AppsKey & 2::
AppsKey & 9::
AppsKey & [::
	If ((v := {1: [Chr(39), Chr(39)], 2: [Chr(34), Chr(34)], 9: [Chr(40), Chr(41)], "[" : [Chr(91), Chr(93)]}[SubStr(A_ThisHotkey, 0)])[2] := String.Clipboard.Copy()) {
		String.Clipboard.Paste(v[0] . v[2] . v[1], 1)
	}
	Return

$Esc::
	If (A_ThisHotkey == A_PriorHotkey && A_TimeSincePriorHotkey <= 300) {
		If (!vShowDesktop && WinGet("Style") & 0x00040000) {
			vShowDesktop := "ahk_id" . WinGet("ID")
		}

		ShowDesktop()
		Sleep, 250
		If (vShowDesktop && (WinGet("Style") & 0x00040000)) {
			WinActivate, % vShowDesktop
			WinWaitActive, % vShowDesktop

			vShowDesktop := 0
		}

		KeyWait("Esc")
		Return
	}

	If (KeyWait("Esc", "T1")) {
		Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . """Kill screen."""

		KeyWait("Esc")
		BlockInput, On
		SendMessage, 0x112, 0xF170, 2, , Program Manager  ;? 0x112 = WM_SYSCOMMAND, 0xF170 = SC_MONITORPOWER.

		Input, v, , {Space}

		KeyWait("Space")
		BlockInput, Off
	}
	Else If (WinActive("ahk_group Escape")) {
		WinClose, % (vWinGet := [WinGet("Class"), "ahk_id" . WinGet("ID"), WinGet("Title")])[1]

		WinWaitNotActive, % vWinGet[1], , 1
		If (ErrorLevel && vWinGet[0] != "#32770") {
			Process, Close, % vWinGet[1]

			MsgBox("$Esc- FORCED: " . vWinGet[2])
		}
	}
	Else
		Send, {Esc}
	Return

AppsKey & `::SetSystemCursor()
$`::
	If (KeyWait("``", "T0.5")) {
		DllCall("SystemParametersInfo", "UInt", 0x70, "UInt", 0, "UIntP", vOriginalSpeed, "UInt", 0)  ;? 0x70 = SPI_GETMOUSESPEED.
		DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", 2, "UInt", 0)  ;? 0x71 = SPI_SETMOUSESPEED (range is 1-20, default is 10).

		KeyWait("``")
		DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", vOriginalSpeed, "UInt", 0)
		Return
	}

	Send, ``
	Return

AppsKey & Tab::String.Clipboard.Paste("`t")

$+CapsLock::
$^CapsLock::Send, % A_ThisHotkey[1] . "{Home}"
AppsKey & CapsLock::
	SetCapsLockState, % ((vSetCapsLockState := !vSetCapsLockState) ? "On" : "AlwaysOff")
	SetTimer(A_ThisHotkey, (vSetCapsLockState ? -30000 : "Delete"))
$!CapsLock::Return
$CapsLock::
	If (KeyWait("CapsLock", "T0.25")) {
		If (String.Clipboard.Copy(1)) {
			Menu, Case, Show
		}

		KeyWait("CapsLock")
		;*** Menu, Case, Destroy
		Return
	}

	Send, {Home}
	Return

AppsKey & Space::
	If (WinGet("Style") & 0x00040000) {
		If ((v := ["ahk_id" . WinGet("ID"), WinGet("Transparent") == 255])[1]) {
			Fade("Out", 35, 1000, v[0])
		}
		Else {
			Fade("In", 255, 1500, v[0])
		}
	}
	Return
$Space::
	If (KeyWait("Space", "T0.5") && WinGet("Style") & 0x00040000) {
		If ((vWinGet := ["ahk_id" . WinGet("ID"), WinGet("Transparent") == 255])[1]) {
			Fade("Out", 35, 500, vWinGet[0])
		}

		KeyWait("Space")
		If (vWinGet[1]) {  ;* This will fail if the window was not initially hidden with this hotkey.
			Fade("In", 255, 500, vWinGet[0])
		}
		Return
	}

	Send, {Space}
	Return

AppsKey & Enter::String.Clipboard.Paste("`r`n")

$!q::Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", String.Clipboard.Copy(1))
AppsKey & q::
	If (vCoordinates == "Delete") {
		vCoordinates := !(Clipboard := vClipboard)		;*** OUTSOURCE: PostMessage, 0x111, 65307, , , % "ahk_id" . v

		GUI, gCoordinates: Destroy
	}
	Else If (vCoordinates := !vCoordinates) {
		GUI, gCoordinates: New, -Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20
		GUI, Color, 0xFFFFFF
		WinSet, TransColor, 0xFFFFFF 255
		GUI, Font, s30
		GUI, Add, Text, c0x3FFEFF, XXXXX YY
		GUI, Show, x5 y5 NA

		UpdateGUI:
			ControlSetText, Static1, % (vString := (v := MouseGet("Pos")).x . ", " . v.y), % A_ScriptName

			SetTimer("UpdateGUI", -25)
			Return
	}
	Else If (!vCoordinates) {
		vClipboard := ClipboardAll
		Clipboard := vString

		SetTimer("UpdateGUI", (vCoordinates := "Delete"))
	}

	KeyWait("q")
	Return

AppsKey & t::
	If (WinGet("Style") & 0x00040000) {
		WinSet, AlwaysOnTop, Toggle, A

		WinGetTitle, v, A
		WinSetTitle, A, , % ((SubStr(v, 1, 2) != "▲ ") ? "▲ " . v : SubStr(v, 3))  ;*** Need a better way to identify a window as AoT.
	}

	KeyWait("t")
	Return

AppsKey & s::
	SplashImage, , B1C01 CWFFFFFF CT000000, [R] Restart`n[S] Shutdown`n[L] Log Off`n`n[H] Hibernate`n[P] Sleep, Press a key:, , Courier New  ;! Arial

	Input, v, L1T5
	SplashImage, Off
	Switch (v) {
		Case "R":
			ShutDown, 2
		Case "S":
			ShutDown, 8
		Case "L":
			ShutDown, 0
		Case "H":
			DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
		Case "P":
			DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
	}
	Return

AppsKey & g::
	If (vString := String.Clipboard.Copy(1, 1))
		Run, % A_ProgramFiles . " (x86)\Google\Chrome\Application\chrome.exe " . (vString ~= "i)(http|ftp)s?:\/\/|w{3}\." ? RegExReplace(vString, "iS).*?(((http|ftp)s?|w{3})[a-z0-9-+&./?=#_%@:]+)(.|\s)*", "$1") : "www.google.com/search?&q=" . StrReplace(vString, A_Space, "+"))

	KeyWait("g")
	Return

AppsKey & h::
	If (oHiddenWindows.Length < 50) {
		If (!(WinGet("Style") & 0x00040000)) {
			MsgBox("The desktop and taskbar may not be hidden.")
			Return
		}

		WinWaitActive, A
		If (WinExist("ahk_id" . SubStr((v := "        " . ((v := WinGet("Title")) ? v : WinGet("ProcessName")) . " (" . WinGet("ID") . ")"), -7, -1))) {
			Send, !{Esc}  ;* Because hiding the window won"t deactivate it, activate the window beneath this one.
			WinHide

			If (!oHiddenWindows.Includes(v)) {  ;* Ensure that this window doesn"t already exist in the array.
				Menu, Tray, Delete, % 15 + oHiddenWindows.Length . "&"  ;* Move the "Exit" menu item to the bottom.
				Menu, Tray, Delete, % 14 + oHiddenWindows.Length . "&"

				oHiddenWindows.Push(v)

				Menu, Tray, Add, % v, Menu
				Menu, Tray, Add, [11] Exit, Menu
				Menu, Tray, Add, , Menu
			}
		}
		Else {
			Throw, (Exception("!!!!!", -1, Format("""{}"" is invalid.", v)))
		}
	}
	Else {
		Throw, (Exception("Limit.", -1, "No more than 50 windows may be hidden simultaneously."))
	}

	KeyWait("h")
	Return

AppsKey & u::
	If (v := oHiddenWindows.Length) {
		Menu(oHiddenWindows[--v])
	}

	KeyWait("u")
	Return

AppsKey & c::
	RunActivate("Calculator ahk_exe ApplicationFrameHost.exe", "calc.exe", "Max")

	KeyWait("c")
	Return

AppsKey & v::
	If (Clipboard) {
		String.Clipboard.Paste(Clipboard)
	}

	KeyWait("v")
	Return

AppsKey & PrintScreen::Send, +#s

ScrollLock::Run, % A_WorkingDir . "\bin\Camera"

Pause::Run, % "*RunAs " A_WinDir . "\System32\WindowsPowerShell\v1.0\powershell.exe"

Insert::Run, % A_WinDir . "\System32\SndVol.exe"

$Delete::
	If (KeyWait("Del", "T0.5")) {
		If (!WinExist("Recycle Bin ahk_exe Explorer.exe")) {
			Run, ::{645FF040-5081-101B-9F08-00AA002F954E}  ;*** CLSID List --> RunActivate.
			WinWait, Recycle Bin ahk_exe Explorer.exe
		}
		WinActivate, Recycle Bin ahk_exe Explorer.exe

		If (KeyWait("Del", "T2")) {
			FileRecycleEmpty

			If (KeyWait("Del", "T2")) {
				WinClose, Recycle Bin ahk_exe Explorer.exe
			}
		}

		KeyWait("Del")
		Return
	}

	Send, {Del}
	Return

AppsKey & Up::
AppsKey & Left::
AppsKey & Down::
AppsKey & Right::MouseMove, % Round({"Left": -1, "Right": 1}[k := KeyGet(A_ThisHotkey)]), % Round({"Up": -1, "Down": 1}[k]), 0, R