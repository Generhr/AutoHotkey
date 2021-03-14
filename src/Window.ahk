;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\lib\General.lib
#Include, %A_ScriptDir%\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\lib\String.ahk

#InstallMouseHook
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

For i, v in [[]] {  ;? [["Title", "ProcessName", "ExcludeTitle"], ...]
	GroupAdd, Suspend, % v[0] . (v[1] ? " ahk_exe " . RegExReplace(v[1], "i)\.exe") . ".exe" : ""), , , % v[2]
}

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global vDebug
IniRead, vScripts, % A_WorkingDir . "\cfg\Settings.ini", Scripts, Scripts

;===============            Other             ===============;

For i, v in String.Split((vScripts := RegExReplace(vScripts, "i)\.ahk")), "|") {
	DllCall("SetFileAttributes", "Str", A_WorkingDir . "\src\" . v . ".ahk", "UInt", 0x80)  ;* Need this here to avoid double reloading.
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

	While (!windowClass || !windowProcessName || !windowTitle || ["#32768", "MultitaskingViewFrame"].Includes(windowClass)) {  ;* Catch for right clicking a script menu, a MsgBox window or the AltTab window.
		windowClass := WinGet("Class"), windowProcessName := WinGet("ProcessName"), windowTitle := WinGet("Title")

		Sleep, -1

		If (vDebug && A_Index == 2) {
			ToolTip("WindowMonitor:`n    " . windowTitle . "`n    " . windowProcessName . "`n    " . windowClass, A_ScreenWidth, 5, 9)
		}
	}

	WinWaitActive, A  ;* Set "Last Found" window.
	windowProcessName := ((!windowProcessName || windowProcessName == "ApplicationFrameHost.exe") ? (windowTitle . ".exe") : (windowProcessName)), windowID := WinGet("ID")
		, isExplorer := windowProcessName = "Explorer.exe"

	If ((isExplorer && windowClass == "CabinetWClass")
		|| (windowProcessName ~= "(7zFM|Calculator|Camera|Code)\.exe"))
		|| (windowProcessName == "chrome.exe" && windowTitle && !(["Bookmark added", "Edit bookmark", "Edit folder name", "Extensions", "Leave site?", "Location access denied", "New folder", "Open", "Save As"].Includes(windowTitle) || windowTitle ~= "wants to"))
		|| (windowProcessName == "Discord.exe" && windowTitle != "Open")
		|| (windowProcessName == "hh.exe" && windowTitle != "Find")
		|| (windowProcessName == "msedge.exe")
		|| (windowProcessName == "notepad++.exe" && !["Find", "Keep non existing file", "Reload", "Replace", "Save"].Includes(windowTitle)) {
		IniRead, pos, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % windowProcessName

		If (pos != "ERROR") {
			pos := String.Split(pos, ", "), pos := {"x": pos[0], "y": pos[1], "Width": pos[2], "Height": pos[3]}

			If (!WinGet("MinMax")) {
				If (isExplorer) {
					Static oExplorer := {"ID": [], "Exempt": [], "Pos": []}

					;* Create a clone array of `oExplorer.ID` and `oExplorer.Exempt` to iterate through and remove handles that don't exist anymore from the original arrays:
					For index, handle in [].Concat(oExplorer.ID, oExplorer.Exempt) {
						If (!WinExist("ahk_id" . handle)) {
							If (oExplorer.Exempt.Includes(handle)) {
								index := oExplorer.Exempt.IndexOf(handle)  ;* The index needs to be looked up each time because removing any element will desync `oExplorer.ID` and `oExplorer.Exempt` from `[].Concat(oExplorer.ID, oExplorer.Exempt)`.

								oExplorer.Exempt.RemoveAt(index)
								oExplorer.Pos.RemoveAt(index)
							}
							Else {
								oExplorer.ID.RemoveAt(oExplorer.ID.IndexOf(handle))
							}
						}
						Else If (oExplorer.ID.Includes(handle) && handle == windowID) {
							index := oExplorer.ID.IndexOf(handle)

							oExplorer.ID.RemoveAt(index)
						}
					}

					If (!oExplorer.Exempt.Includes(windowID)) {
						oExplorer.ID.UnShift(windowID)  ;* Place the active window's handle at the beginning of the array to have an offset of 0.
					}

					If (!GetKeyState("LButton", "P")) {  ;* Let `WindowPositionExplorer()` call `Cascade()` after `{LButton}` is released.
						Cascade(oExplorer, pos)
					}
				}
				Else {
					WinMove, A, , pos.x, pos.y, pos.Width, pos.Height  ;* If the window is not maximized then perform an initial position update because Windows repositions some windows randomly when its first created.
				}
			}
		}
		Else {  ;* If there are no setting for this window, save the current position. Be aware that if the window is initially maximized and has it no saved configuration then the configuration written to Settings.ini will be that of the maximized window.
			pos := WinGet("Pos")

			IniWrite, % pos.x . ", " . pos.y . ", " . pos.Width . ", " . pos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % windowProcessName
		}

		If (isExplorer) {
			WindowPositionExplorer(oExplorer, windowID, pos)  ;* `{LButton}` may be released within 50ms so call the function immediately to ensure the correct logic is used.

			timer := Func("WindowPositionExplorer").Bind(oExplorer, windowID, pos)
		}
		Else {
			WindowPosition(windowID, windowProcessName, pos)

			timer := Func("WindowPosition").Bind(windowID, windowProcessName, pos)
		}

		SetTimer(timer, 50)
	}

	WinWaitNotActive, % "ahk_id" . windowID
	SetTimer(timer, "Delete")

	SetTimer("WindowMonitor", -1)
}

Cascade(explorer, pos) {
	For index, handle in explorer.ID {
		offset := index*50

		WinMove, % "ahk_id" . handle, , pos.x + offset, pos.y - offset, pos.Width, pos.Height
	}

	If (vDebug) {
		ToolTip(explorer.ID.Print() . " || " . explorer.Exempt.Print() . "`n`n" . explorer.Pos.Print(), 5, 5, 0)
	}
}

WindowPositionExplorer(explorer, ID, originalPos) {
	If (!WinGet("MinMax") && GetKeyState("LButton", "P") && WinActive("ahk_id" . ID)) {  ;* Do the `WinActive("ahk_id" . ID)` check last as that's only likely if `GetKeyState("LButton", "P")` passes.
		KeyWait, LButton

		If (WinActive("ahk_id" . ID)) {
			windowPos := WinGet("Pos")
				, cascadeIndex := explorer.ID.IndexOf(ID)

			If (~cascadeIndex) {
				offset := windowPos.x - originalPos.x  ;* Can't use an index lookup here because the handle has already been moved to index 0.
					, pos := {"x": originalPos.x + offset, "y": originalPos.y - offset}
			}
			Else {
				exemptIndex := explorer.Exempt.IndexOf(ID)
					, pos := explorer.Pos[exemptIndex]
			}

			If (GetKeyState("AppsKey", "P")) {
				IniWrite, % windowPos.x . ", " . windowPos.y . ", " . windowPos.Width . ", " . windowPos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % "Explorer.EXE"

				originalPos.x := windowPos.x, originalPos.y := windowPos.y, originalPos.Width := windowPos.Width, originalPos.Height := windowPos.Height

				If (~exemptIndex) {
					explorer.ID.UnShift(explorer.Exempt.RemoveAt(exemptIndex))  ;* Transfer the handle back to `explorer.ID` as this is now the new `originalPos` from which other explorer windows will be offset.
				}
			}
			Else If (originalPos.Width != windowPos.Width || originalPos.Height != windowPos.Height) {
				WinMove, % "ahk_id" . ID, , pos.x, pos.y, originalPos.Width, originalPos.Height

				If (vDebug) {
					MsgBox("Reset Width\Height")
				}
			}
			Else If (pos.x != windowPos.x || pos.y != windowPos.y) {  ;* If the window has been moved but not resized.
				If (~cascadeIndex) {
					explorer.Exempt.Push(explorer.ID.RemoveAt(cascadeIndex))  ;* Transfer the handle from `explorer.ID` to `explorer.Exempt`.

					exemptIndex := explorer.Exempt.MaxIndex()
				}

				explorer.Pos[exemptIndex] := windowPos  ;* Use the same index to more easily link `explorer.Exempt` and `explorer.Pos` elements.

				If (vDebug) {
					MsgBox("Update position: " . pos.x . " != " . windowPos.x . " || " . pos.y . " != " . windowPos.y)
				}
			}

			Cascade(explorer, originalPos)
		}
	}
}

WindowPosition(ID, processName, pos) {
	If (!WinGet("MinMax") && GetKeyState("LButton", "P") && WinActive("ahk_id" . ID)) {
		KeyWait, LButton

		If (WinActive("ahk_id" . ID)) {
			windowPos := WinGet("Pos")

			If ((pos.x != windowPos.x || pos.y != windowPos.y || pos.Width != windowPos.Width || pos.Height != windowPos.Height) && windowPos.Width && windowPos.Height) {
				If (GetKeyState("AppsKey", "P")) {  ;* Allow repositioning and save the new coordinates if `{AppsKey}` is held down when `{LButton}` is released.
					IniWrite, % windowPos.x . ", " . windowPos.y . ", " . windowPos.Width . ", " . windowPos.Height, % A_WorkingDir . "\cfg\Settings.ini", Window Positions, % processName
				}
				Else {
					WinMove, A, , pos.x, pos.y, pos.Width, pos.Height
				}
			}
		}
	}
}
