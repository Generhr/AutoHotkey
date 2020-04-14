;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\lib\General.ahk
#Include, %A_ScriptDir%\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\lib\String.ahk

#KeyHistory, 0
#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance, Force

ListLines, Off
Process, Priority, , Normal
SetTitleMatchMode, 2
SetWinDelay, -1

;===============            Group             ===============;

For i, v in [["Steam", "ahk_exe Steam.exe"]] {  ;? [["Title", "ProcessName", "ExcludeTitle"], ...].
	GroupAdd, Suspend, % v[0] . (v[1] ? " ahk_exe " . RegExReplace(v[1], "i)\.exe") . ".exe" : ""), , , % v[2]
}

;===============           Variable           ===============;

IniRead, vScripts, % A_WorkingDir . "\cfg\Settings.ini", Scripts, Scripts

;===============            Other             ===============;

For i, v in String.Split((vScripts := RegExReplace(vScripts, "i)\.ahk")), "|") {
	DllCall("SetFileAttributes", "Str", A_WorkingDir . "\src\" . v . ".ahk", "UInt", 0x80)  ;* Need this here to avoid double reloading with `WindowMonitor()`.
}

;===============            Timer             ===============;

SetTimer(Func("WindowMonitor").Bind(vScripts), -500)

Exit

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#IF

;=====           Function           =========================;

WindowMonitor(_Scripts := "") {
	Static oScripts
	If (_Scripts) {
		oScripts := [_Scripts, {}]
		For i, v in String.Split(oScripts[0], "|") {
			oScripts[1][v] := [0]
		}
	}

	While (!(WinGet("Title") || WinGet("Class") || WinGet("ProcessName"))) {  ;* Catch for right clicking a script menu.
		Sleep, -1
	}

	WinWaitActive, A  ;* Set "Last Found" window.
	w := WinGet()

	For k, v in oScripts[1] {
		k .= ".ahk"

		SendMessage(0xFF, , , , k . " - AutoHotkey", , , , , "On")  ;* Query if this script is suspended.

		If ((v[0] == ErrorLevel) && ((!ErrorLevel && WinActive("ahk_group Suspend")) || (ErrorLevel && !WinActive("ahk_group Suspend")))) {
			v[0] := !ErrorLevel  ;* Keep track locally to check for manual suspending.

			ScriptCommand(k, "Suspend")

			Sleep(50)
			SendMessage(0xFF, 1, , , k . " - AutoHotkey", , , , , "On")  ;* Optional feedback message to set icon or whatever.
		}

		If (w.Class != "#32768" && w.ProcessName != "AutoHotkey.exe" && !(w.Title ~= "AutoHotkey Help|" . oScripts[0]))  ;* Check to see if the file attributes have changed (OS updated the attributes because it was saved).
			If (DllCall("GetFileAttributes", "Str", A_WorkingDir . "\src\" . k) == 0x20) {  ;? 0x20 = FILE_ATTRIBUTE_ARCHIVE.
				DllCall("SetFileAttributes", "Str", A_WorkingDir . "\src\" . k, "UInt", 0x80)  ;? 0x80 = FILE_ATTRIBUTE_NORMAL.

				ScriptCommand(k, "Reload")
			}
	}

	If (w.Class != "#32768") {
		If (((w.ProcessName := (!w.ProcessName || w.ProcessName == "ApplicationFrameHost.exe") ? w.Title . ".exe" : w.ProcessName) == "Explorer.EXE" && w.Class == "CabinetWClass") || (w.ProcessName == "notepad++.exe" && !["Find", "Reload", "Save"].Includes(w.Title)) || (w.ProcessName == "hh.exe" && w.Title != "Find") || w.ProcessName ~= "(7zFM|Calculator|Camera|Code|Discord)\.exe") {
			WindowPosition(w)
		}
	}

	WinWaitNotActive, % "ahk_id" . w.ID

	SetTimer(A_ThisFunc, -50)
}

WindowPosition(vWindow := "") {
	Static oWindow
	If (vWindow) {  ;*Initial call passes a window object.
		oWindow := vWindow

		IniRead, v, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % oWindow.ProcessName
		If (v != "ERROR") {
			oWindow.Pos := {"x": (v := String.Split(v, ", "))[0], "y": v[1], "Width": v[2], "Height": v[3]}

			If (!oWindow.MinMax) {  ;* If the window is not maximized then perform an initial move because Windows repositions some windows randomly when they're first started.
				WinMove, A, , v[0], v[1], v[2], v[3]
			}
		}
		Else {  ;* If there are no setting for this window, save the current position. Be aware that if the window is initially maximized and has it no saved configuration then the configuration written to ini will be that of the maximized window.
			IniWrite, % oWindow.Pos.x . ", " . oWindow.Pos.y . ", " . oWindow.Pos.Width . ", " . oWindow.Pos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % oWindow.ProcessName
		}
	}

	If (WinActive("ahk_id" . oWindow.ID)) {
		If (!WinGet("MinMax")) {
			If ((oWindow.Pos.x != (w := WinGet("Pos")).x || oWindow.Pos.y != w.y) && w.Width && w.Height) {
				KeyWait("LButton")

				If (GetKeyState("Ctrl", "P")) { ;* Allow repositioning and save the new coordinates if `{Ctrl}` is held down.
					IniWrite, % (oWindow.Pos := w).x ", " oWindow.Pos.y ", " oWindow.Pos.Width ", " oWindow.Pos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % oWindow.ProcessName
				}
				Else {
					WinMove, A, , oWindow.Pos.x, oWindow.Pos.y, oWindow.Pos.Width, oWindow.Pos.Height
				}
			}
		}

		SetTimer(A_ThisFunc, -50)
	}
}