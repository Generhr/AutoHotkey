;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#KeyHistory, 0
#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox
#WinActivateForce

CoordMode, ToolTip, Screen
ListLines, Off
Process, Priority, , Normal
SetBatchLines, -1
SetTitleMatchMode, 2
SetWinDelay, -1

;====================================================== Variable ==============;

;IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
;Global Debug

;IniRead, scripts, % A_WorkingDir . "\cfg\Settings.ini", Scripts, Scripts

;=======================================================  Group  ===============;

for i, v in [[]] {  ;? [["Title Class ahk_class ahk_exe ProcessName", "ExcludeTitle"], ...]
	GroupAdd, Suspend, % v[0], , , % v[1]
}

;======================================================== Hook ================;

OnMessage(0x2000, "UpdateScript")

;=======================================================  Other  ===============;

;for i, v in String.Split((scripts := RegExReplace(scripts, "i)\.ahk")), "|") {
;	DllCall("SetFileAttributes", "Str", A_WorkingDir . "\src\" . v . ".ahk", "UInt", 0x80)  ;* Need this here to avoid double reloading.
;}

SetTimer(Func("WindowMonitor").Bind(scripts), -500)

exit

;=============== Hotkey =======================================================;

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

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\lib\General.ahk
#Include, %A_ScriptDir%\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\lib\String.ahk

;============== Function ======================================================;

UpdateScript(wParam := 0, lParam := 0) {
	switch (wParam) {
		case -1:
			IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug

			ToolTip, , , , 20

			return (0)
	}

	return (-1)
}

WindowMonitor(scripts := "") {
	while (True) {
		if (!(windowTitle := WinGet("Title")) || !(windowClass := WinGet("Class")) || ["#32768", "#32770", "MultitaskingViewFrame"].Includes(windowClass) || !(windowProcessName := WinGet("ProcessName"))) {  ;* Catch for right clicking a script menu, a MsgBox window or the AltTab window.
			if (Debug) {
				MsgBox(Format("WindowMonitor(): failed`n`t{}`n`tahk_class {}`n`tahk_exe {}", windowTitle, windowClass, windowProcessName))
			}

			WinWaitNotActive, % Format("{} ahk_class{} ahk_exe{}", windowTitle, windowClass, windowProcessName)
		}
		else {
			WinActivate, % Format("{} ahk_class{} ahk_exe{}", windowTitle, windowClass, windowProcessName)  ;* Set "Last Found" window.
			WinWaitActive, A

			break
		}
	}

	if (Debug) {
		MsgBox(Format("WindowMonitor(): continue`n`t{}`n`tahk_class {}`n`tahk_exe {}", windowTitle, windowClass, windowProcessName))
	}

	windowProcessName := ((!windowProcessName || windowProcessName == "ApplicationFrameHost.exe") ? (windowTitle . ".exe") : (windowProcessName)), windowID := WinGet("ID")
		, isExplorer := windowProcessName = "Explorer.exe"

	if ((isExplorer && windowClass == "CabinetWClass")
		|| (windowProcessName ~= "(7zFM|Calculator|Camera|Code)\.exe"))
		|| (windowProcessName == "chrome.exe" && windowTitle && !(["Bookmark added", "Connection is secure", "Edit bookmark", "Edit folder name", "Extensions", "Leave site?", "Location access denied", "New folder", "Open", "Save As"].Includes(windowTitle) || windowTitle ~= "wants to"))
		|| (windowProcessName == "Discord.exe" && windowTitle != "Open")
		|| (windowProcessName == "hh.exe" && windowTitle != "Find")
		|| (windowProcessName == "msedge.exe")
		|| (windowProcessName == "notepad++.exe" && !["Find", "Keep non existing file", "Reload", "Replace", "Save"].Includes(windowTitle)) {
		IniRead, pos, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % windowProcessName

		if (pos != "ERROR") {
			pos := String.Split(pos, ", "), pos := {"x": pos[0], "y": pos[1], "Width": pos[2], "Height": pos[3]}

			if (!WinGet("MinMax")) {
				if (isExplorer) {
					Static oExplorer := {"ID": [], "Exempt": [], "Pos": []}

					;* Create a clone array of `oExplorer.ID` and `oExplorer.Exempt` to iterate through and remove handles that don't exist anymore from the original arrays:
					for index, handle in [].Concat(oExplorer.ID, oExplorer.Exempt) {
						if (!WinExist("ahk_id" . handle)) {
							if (oExplorer.Exempt.Includes(handle)) {
								index := oExplorer.Exempt.IndexOf(handle)  ;* The index needs to be looked up each time because removing any element will desync `oExplorer.ID` and `oExplorer.Exempt` from `[].Concat(oExplorer.ID, oExplorer.Exempt)`.

								oExplorer.Exempt.RemoveAt(index)
								oExplorer.Pos.RemoveAt(index)
							}
							else {
								oExplorer.ID.RemoveAt(oExplorer.ID.IndexOf(handle))
							}
						}
						else if (oExplorer.ID.Includes(handle) && handle == windowID) {
							index := oExplorer.ID.IndexOf(handle)

							oExplorer.ID.RemoveAt(index)
						}
					}

					if (!oExplorer.Exempt.Includes(windowID)) {
						oExplorer.ID.UnShift(windowID)  ;* Place the active window's handle at the beginning of the array to have an offset of 0.
					}

					if (!GetKeyState("LButton", "P")) {  ;* Let `WindowPositionExplorer()` call `Cascade()` after `{LButton}` is released.
						Cascade(oExplorer, pos)
					}
				}
				else {
					WinMove, A, , pos.x, pos.y, pos.Width, pos.Height  ;* If the window is not maximized then perform an initial position update because Windows repositions some windows randomly when its first created.
				}
			}
		}
		else {  ;* If there are no setting for this window, save the current position. Be aware that if the window is initially maximized and has it no saved configuration then the configuration written to Settings.ini will be that of the maximized window.
			pos := WinGet("Pos")

			IniWrite, % pos.x . ", " . pos.y . ", " . pos.Width . ", " . pos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % windowProcessName
		}

		if (isExplorer) {
			WindowPositionExplorer(oExplorer, windowID, pos)  ;* `{LButton}` may be released within 50ms so call the function immediately to ensure the correct logic is used.

			funcObj := Func("WindowPositionExplorer").Bind(oExplorer, windowID, pos)
		}
		else {
			WindowPosition(windowID, windowProcessName, pos)

			funcObj := Func("WindowPosition").Bind(windowID, windowProcessName, pos)
		}

		SetTimer(funcObj, 50)
	}

	WinWaitNotActive, % "ahk_id" . windowID
	SetTimer(funcObj, "Delete")

	SetTimer("WindowMonitor", -1)
}

Cascade(explorer, pos) {
	for index, handle in explorer.ID {
		offset := index*50

		WinMove, % "ahk_id" . handle, , pos.x + offset, pos.y - offset, pos.Width, pos.Height
	}

	if (Debug) {
		ToolTip(explorer.ID.Print() . " || " . explorer.Exempt.Print() . "`n`n" . explorer.Pos.Print(), [5, 5], 20)
	}
}

WindowPositionExplorer(explorer, ID, originalPos) {
	if (!WinGet("MinMax") && GetKeyState("LButton", "P") && WinActive("ahk_id" . ID)) {  ;* Do the `WinActive("ahk_id" . ID)` check last as that's only likely if `GetKeyState("LButton", "P")` passes.
		KeyWait, LButton

		if (WinActive("ahk_id" . ID)) {
			windowPos := WinGet("Pos")
				, cascadeIndex := explorer.ID.IndexOf(ID)

			if (~cascadeIndex) {
				offset := windowPos.x - originalPos.x  ;* Can't use an index lookup here because the handle has already been moved to index 0.
					, pos := {"x": originalPos.x + offset, "y": originalPos.y - offset}
			}
			else {
				exemptIndex := explorer.Exempt.IndexOf(ID)
					, pos := explorer.Pos[exemptIndex]
			}

			if (GetKeyState("AppsKey", "P")) {
				IniWrite, % windowPos.x . ", " . windowPos.y . ", " . windowPos.Width . ", " . windowPos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % "Explorer.EXE"

				originalPos.x := windowPos.x, originalPos.y := windowPos.y, originalPos.Width := windowPos.Width, originalPos.Height := windowPos.Height

				if (~exemptIndex) {
					explorer.ID.UnShift(explorer.Exempt.RemoveAt(exemptIndex))  ;* Transfer the handle back to `explorer.ID` as this is now the new `originalPos` from which other explorer windows will be offset.
				}
			}
			else if (originalPos.Width != windowPos.Width || originalPos.Height != windowPos.Height) {
				WinMove, % "ahk_id" . ID, , pos.x, pos.y, originalPos.Width, originalPos.Height

				if (Debug) {
					MsgBox("Reset Width\Height")
				}
			}
			else if (pos.x != windowPos.x || pos.y != windowPos.y) {  ;* If the window has been moved but not resized.
				if (~cascadeIndex) {
					explorer.Exempt.Push(explorer.ID.RemoveAt(cascadeIndex))  ;* Transfer the handle from `explorer.ID` to `explorer.Exempt`.

					exemptIndex := explorer.Exempt.MaxIndex()
				}

				explorer.Pos[exemptIndex] := windowPos  ;* Use the same index to more easily link `explorer.Exempt` and `explorer.Pos` elements.

				if (Debug) {
					MsgBox("Update position: " . pos.x . " != " . windowPos.x . " || " . pos.y . " != " . windowPos.y)
				}
			}

			Cascade(explorer, originalPos)
		}
	}
}

WindowPosition(ID, processName, pos) {
	if (!WinGet("MinMax") && GetKeyState("LButton", "P") && WinActive("ahk_id" . ID)) {
		KeyWait, LButton

		if (WinActive("ahk_id" . ID)) {
			windowPos := WinGet("Pos")

			if ((pos.x != windowPos.x || pos.y != windowPos.y || pos.Width != windowPos.Width || pos.Height != windowPos.Height) && windowPos.Width && windowPos.Height) {
				if (GetKeyState("AppsKey", "P")) {  ;* Allow repositioning and save the new coordinates if `{AppsKey}` is held down when `{LButton}` is released.
					IniWrite, % windowPos.x . ", " . windowPos.y . ", " . windowPos.Width . ", " . windowPos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % processName
				}
				else {
					WinMove, A, , pos.x, pos.y, pos.Width, pos.Height
				}
			}
		}
	}
}
