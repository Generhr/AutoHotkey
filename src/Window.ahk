;=====         Auto-execute         =========================;

;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\lib\General.ahk
#Include, %A_ScriptDir%\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\lib\String.ahk

#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance, Force

DetectHiddenWindows, On
SetTitleMatchMode, 2
SetWinDelay, -1

Process, Priority, , Normal

;===============            Group             ===============;

For i, v in []  ;? [["Title", "ProcessName"], ..., ["Title", "ProcessName"]].
	GroupAdd, Suspend, % v[0] . (v[1] ? " ahk_exe " . v[1] . ".exe" : ""), , , % v[2]

;===============           Variable           ===============;

IniRead, vScripts, % A_WorkingDir . "\cfg\Settings.ini", Scripts, Scripts
Global vScripts

;===============            Timer             ===============;

SetTimer("WindowMonitor", "-50")

;===============            Other             ===============;

For i, v in String.Split(vScripts, "|")
	DllCall("SetFileAttributes", "Str", A_WorkingDir . "\src\" . v, "UInt", 0x80)  ;* Need this here to avoid double reloading with `WindowMonitor()`.

Exit

;=====           Function           =========================;

WindowMonitor() {
	Static vIsSuspended := [0, 0]

	WinWaitActive, A  ;* Set "Last Found" window.
	w := WinGet()

	For i, v in String.Split(vScripts, "|") {
		SendMessage(0xFF, , , , v . "ahk_exeAutoHotkey.exe")  ;* Query if the script is suspended.

		If ((vIsSuspended[0] == vIsSuspended[1]) && ((!ErrorLevel && WinActive("ahk_group Suspend")) || (ErrorLevel && !WinActive("ahk_group Suspend")))) {
			Run, % A_WorkingDir . "\bin\Nircmd.exe speak text " . Format("""{}.""", (vIsSuspended[0] := vIsSuspended[1] := !ErrorLevel) ? "You're suspended young lady!" : "Carry on...")

			PostMessage(0x111, 65305, , , v . "ahk_exe AutoHotkey.exe")   ;? 65305 = suspend.
		}

		If (w.Class != "#32768" && !(w.Title ~= "AutoHotkey Help|" . vScripts))  ;* Check to see if the file attributes have changed (OS updated the attributes because it was saved).
			If (DllCall("GetFileAttributes", "Str", A_WorkingDir . "\src\" . v) == 0x20) {  ;? 0x20 = FILE_ATTRIBUTE_ARCHIVE.
				DllCall("SetFileAttributes", "Str", A_WorkingDir . "\src\" . v, "UInt", 0x80)  ;? 0x80 = FILE_ATTRIBUTE_NORMAL.

				PostMessage(0x111, 65303, , , v . "ahk_exe AutoHotkey.exe")   ;? 65305 = reload.
			}
	}

	If (w.Class != "#32768")
		If (((w.ProcessName := (!w.ProcessName || w.ProcessName == "ApplicationFrameHost.exe") ? w.Title . ".exe" : w.ProcessName) == "Explorer.EXE" && w.Class == "CabinetWClass") || (w.ProcessName == "notepad++.exe" && !["Find", "Reload", "Save"].Includes(w.Title)) || (w.ProcessName == "hh.exe" && w.Title != "Find") || w.ProcessName ~= "(7zFM|Calculator|Camera|Code|Discord)\.exe")
			WindowPosition(w)  ;* Pass the object to save processing power. :)

	WinWaitNotActive, % "ahk_id" . w.ID

	For i, v in String.Split(vScripts, "|")
		vIsSuspended[0] := SendMessage(0xFF, , , , v . "ahk_exeAutoHotkey.exe")

	SetTimer(A_ThisFunc, -50)
}

WindowPosition(_Window := "") {
	Static oWindow
	If (_Window) {
		oWindow := _Window

		IniRead, v, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % oWindow.ProcessName
		If (v != "ERROR") {
			oWindow.Pos := {"x": (v := String.Split(v, ", "))[0], "y": v[1], "Width": v[2], "Height": v[3]}

			If (!oWindow.MinMax)  ;* If the window is not maximized then perform an initial move because Windows repositions some windows randomly when they're first started.
				WinMove, A, , v[0], v[1], v[2], v[3]
		}
		Else  ;* If there is no setting for this window, save the current position. Be aware that if the window is initially maximized and has it no saved configuration then the configuration written to ini will be that of the maximized window. I feel that it's not worth accounting for this.
			IniWrite, % oWindow.Pos.x ", " oWindow.Pos.y ", " oWindow.Pos.Width ", " oWindow.Pos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % oWindow.ProcessName
	}

	If (WinActive("ahk_id" . oWindow.ID)) {
		If (!WinGet("MinMax")) {
			If ((oWindow.Pos.x != (w := WinGet("Pos")).x || oWindow.Pos.y != w.y) && w.Width && w.Height) {
				KeyWait("LButton")

				If (GetKeyState("Ctrl", "P"))  ;* Allow repositioning and save the new coordinates if "Ctrl" is held down.
					IniWrite, % (oWindow.Pos := w).x ", " oWindow.Pos.y ", " oWindow.Pos.Width ", " oWindow.Pos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % oWindow.ProcessName
				Else
					WinMove, A, , oWindow.Pos.x, oWindow.Pos.y, oWindow.Pos.Width, oWindow.Pos.Height
			}
		}

		SetTimer(A_ThisFunc, -50)
	}
}

;=====            Hotkey            =========================;

~$^s::
	Critical
	SetTitleMatchMode, 2

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return