#Requires AutoHotkey v2.0-beta

;============ Auto-Execute ====================================================;
;=======================================================  Admin  ===============;

if (!A_IsAdmin || !DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)") {
	try {
		Run(Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (Format('{} /restart "{}"', A_AhkPath, A_ScriptFullPath))))
	}

	ExitApp()
}

;======================================================  Include  ==============;

#Include %A_ScriptDir%\..\lib\Core.ahk

#Include %A_ScriptDir%\..\lib\General\General.ahk
#Include %A_ScriptDir%\..\lib\Console\Console.ahk

;======================================================  Setting  ==============;

#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
;#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
ListLines(False)
ProcessSetPriority("High")
SetWorkingDir(A_ScriptDir . "\..")
SetWinDelay(-1)

;=======================================================  Group  ===============;

;for i, v in [[]] {  ;? [["Title Class ahk_class ahk_exe ProcessName", "ExcludeTitle"], ...]
;	try {
;		GroupAdd("Suspend", v[0], , v[1])
;	}
;	catch {
;		GroupAdd("Suspend", v[0])
;	}
;}

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

	, A_SavedClipboard
	, A_Null := Chr(0)

A_Debug := 0

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;=======================================================  Other  ===============;

SetTimer(WindowMonitor, -500)  ;! SetTimer(WindowMonitor.Bind(scripts), -500)

Exit()

;=============== Hotkey =======================================================;

#HotIf (WinActive(A_ScriptName))

	$F10:: {
		ListVars

		KeyWait("F10")
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload()
	}

#HotIf

;============== Function ======================================================;

WindowMonitor(scripts := "") {
	while (True) {
		try {
			windowHandle := WinGetID("A")
		}
		catch {
			Sleep(50)

			continue
		}

		if (A_Debug) {
			Console.Clear()
		}

		if (!(windowTitle := WinGetTitle(windowHandle)) || !(windowClass := WinGetClass(windowHandle)) || ["#32768", "#32770", "Shell_TrayWnd", "MultitaskingViewFrame"].Includes(windowClass) || !(windowProcessName := WinGetProcessName(windowHandle))) {  ;* Catch for right clicking a script menu, a MsgBox window, the taskbar, or the AltTab window.
			if (A_Debug) {
				Console.Log("Waiting for a valid window...")
			}

			WinActivate(windowHandle)
			WinWaitNotActive(windowHandle)
		}
		else {
			WinActivate(windowHandle)
			WinWaitActive(windowHandle)

			break
		}
	}

	if (A_Debug) {
		Console.Log(Format("Found a valid window:`n    - {}`n    - ahk_class {}`n    - ahk_exe {}`n", windowTitle, windowClass, windowProcessName))
	}

	windowProcessName := ((!windowProcessName || windowProcessName == "ApplicationFrameHost.exe") ? (windowTitle . ".exe") : (windowProcessName))
		, isExplorer := windowProcessName = "explorer.exe"

	if ((isExplorer && windowClass == "CabinetWClass")
	|| (windowProcessName ~= "(7zFM|Calculator|Camera|Code)\.exe"))
	|| (windowProcessName == "chrome.exe" && windowTitle && !(["Bookmark added", "Connection is secure", "Edit bookmark", "Edit folder name", "Extensions", "Leave site?", "Location access denied", "New folder", "Open", "Save As"].Includes(windowTitle) || windowTitle ~= "wants to"))
	|| (windowProcessName == "Discord.exe" && windowTitle != "Open")
	|| (windowProcessName == "hh.exe" && windowTitle != "Find")
	|| (windowProcessName == "msedge.exe")
	|| (windowProcessName == "notepad++.exe" && !["Find", "Keep non existing file", "Reload", "Replace", "Save"].Includes(windowTitle)) {
		position := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Window Positions", windowProcessName, "Error")

		if (position != "Error") {
			position := String.Split(position, ", "), position := {x: position[0], y: position[1], Width: position[2], Height: position[3]}

			if (!WinGetMinMax(windowHandle)) {
				if (isExplorer) {
					if (A_Debug) {
						Console.Log("Explorer.exe!")
					}

					static explorerWindows := {Cascade: [], Exempt: [], ExemptPosition: Map()}

					;* Create a clone array of `explorerWindows.Cascade` and `explorerWindows.Exempt` to iterate through and remove handles that don't exist anymore from the original arrays:
					for handle in [].Concat(explorerWindows.Cascade, explorerWindows.Exempt) {
						if (!WinExist(handle)) {
							if (explorerWindows.Exempt.Includes(handle)) {
								explorerWindows.Exempt.RemoveAt(explorerWindows.Exempt.IndexOf(handle))  ;* The index needs to be looked up each time because removing any element will desync `explorerWindows.Cascade` and `explorerWindows.Exempt` from `[].Concat(explorerWindows.Cascade, explorerWindows.Exempt)`.
								explorerWindows.ExemptPosition.Delete(handle)
							}
							else {
								explorerWindows.Cascade.RemoveAt(explorerWindows.Cascade.IndexOf(handle))
							}
						}
						else if (explorerWindows.Cascade.Includes(handle) && handle == windowHandle) {
							explorerWindows.Cascade.RemoveAt(explorerWindows.Cascade.IndexOf(handle))
						}
					}

					if (!explorerWindows.Exempt.Includes(windowHandle)) {
						explorerWindows.Cascade.UnShift(windowHandle)  ;* Place the active window's handle at the beginning of the array to have an offset of 0.

						if (!GetKeyState("LButton", "P")) {
							Cascade(position)
						}

						Cascade(position) {
							if (A_Debug) {
								Console.Log("Cascading windows.")
							}

							for index, handle in explorerWindows.Cascade {
								offset := index*50

								if (!DllCall("User32\SetWindowPos", "Ptr", handle, "Ptr", 0, "Int", position.x + offset, "Int", position.y - offset, "Int", position.Width, "Int", position.Height, "UInt", 0x0004, "UInt")) {  ;? 0x0004 = SWP_NOZORDER  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
									throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
								}
							}

							if (A_Debug) {
								ToolTip(explorerWindows.Cascade.Print() . " || " . explorerWindows.Exempt.Print() . "`n`n" . explorerWindows.ExemptPosition.Print(), 5, 5, 20)
							}
						}
					}
					else {
						position := explorerWindows.ExemptPosition[windowHandle]
					}
				}
				else {
					if (A_Debug) {
						Console.Log("Normal window, setting initial position.")
					}

					WinMove(position.x, position.y, position.Width, position.Height, windowHandle)  ;* If the window is not maximized then perform an initial position update because Windows repositions some windows randomly when its first created.
				}
			}
		}
		else {  ;* If there are no setting for this window, save the current position. Be aware that if the window is initially maximized and has it no saved configuration then the configuration written to Settings.ini will be that of the maximized window.
			if (A_Debug) {
				Console.Log("No position settings for this window.")
			}

			WinGetPos(&x, &y, &width, &height, windowHandle)

			IniWrite((position.x := x) . ", " . (position.y := y) . ", " . (position.Width := width) . ", " . (position.Height := height), A_WorkingDir . "\cfg\Settings.ini", "Window Positions", windowProcessName)

			MsgBox("IniWrite (" . position . " == Error)")
		}

		if (isExplorer) {
			(BoundFunc := WindowPositionExplorer.Bind(windowHandle, position)).Call()

			WindowPositionExplorer(handle, originalPos) {
				if (WinActive(handle)) {
					if (!WinGetMinMax(handle)) {
						cascadeIndex := explorerWindows.Cascade.IndexOf(handle)
							, WinGetPos(&x, &y, &width, &height)

						if (~cascadeIndex) {
							offset := x - originalPos.x
								, offsetPos := {x: originalPos.x + offset, y: originalPos.y - offset, Width: originalPos.Width, Height: originalPos.Height}

							hasMoved := originalPos.x != x || originalPos.y != y || originalPos.Width != width || originalPos.Height != height
						}
						else {
							exemptIndex := explorerWindows.Exempt.IndexOf(handle)
								, offsetPos := explorerWindows.ExemptPosition[handle]

							hasMoved := offsetPos.x != x || offsetPos.y != y || offsetPos.Width != width || offsetPos.Height != height
						}

						if (hasMoved) {
							if (A_Debug) {
								Console.Log("Window has moved!")
							}

							ToolTip(111)

							if (GetKeyState("LButton", "P")) {
								KeyWait("LButton")

								WinGetPos(&x, &y, &width, &height)
							}

							if (GetKeyState("AppsKey", "P")) {  ;* Allow repositioning and save the new coordinates if `{AppsKey}` is held down when `{LButton}` is released.
								IniWrite(x . ", " . y . ", " . width . ", " . height, A_WorkingDir . "\cfg\Settings.ini", "Window Positions", "Explorer.EXE")

								originalPos.x := x, originalPos.y := y, originalPos.Width := width, originalPos.Height := height

								if (IsSet(exemptIndex)) {
									explorerWindows.Cascade.UnShift(explorerWindows.Exempt.RemoveAt(exemptIndex))  ;* Transfer the handle back to `explorerWindows.Cascade` as this is now the new `pos` from which other explorerWindows windows will be offset.
								}
							}
							else if (offsetPos.Width != width || offsetPos.Height != height) {
								if (IsSet(exemptIndex)) {
									if (A_Debug) {
										Console.Log("Saving new width/height.")
									}

									explorerWindows.ExemptPosition[handle] := {x: x, y: y, Width: width, Height: height}
								}
								else {
									if (A_Debug) {
										Console.Log("Restoring window width/height.")
									}

									WinMove(offsetPos.x, offsetPos.y, offsetPos.Width, offsetPos.Height, windowHandle)
								}
							}
							else if (offsetPos.x != x || offsetPos.y != y) {  ;* If the window has been moved but not resized.
								if (A_Debug) {
									Console.Log("Saving new position" . ((IsSet(exemptIndex)) ? (".") : (" and marking window as exempt from cascading.")))
								}

								explorerWindows.ExemptPosition[handle] := {x: x, y: y, Width: width, Height: height}

								if (~cascadeIndex) {
									explorerWindows.Exempt.Push(explorerWindows.Cascade.RemoveAt(cascadeIndex))  ;* Transfer the handle from `explorerWindows.Cascade` to `explorerWindows.Exempt`.

									Cascade(originalPos)
								}
							}
							else {
								Cascade(originalPos)
							}
						}
					}

					SetTimer(BoundFunc, -50)
				}
			}
		}
		else {
			(BoundFunc := WindowPosition.Bind(windowHandle, windowProcessName, position)).Call()

			WindowPosition(handle, processName, position) {
				if (WinActive(handle)) {
					if (!WinGetMinMax(handle)) {
						WinGetPos(&x, &y, &width, &height)

						if (position.x != x || position.y != y || position.Width != width || position.Height != height) {
							if (A_Debug) {
								Console.Log("Window has moved!")
							}

							if (GetKeyState("LButton", "P")) {
								KeyWait("LButton")

								WinGetPos(&x, &y, &width, &height)
							}

							if (GetKeyState("AppsKey", "P")) {  ;* Allow repositioning and save the new coordinates if `AppsKey` is held down after `LButton` is released.
								IniWrite(x . ", " . y . ", " . width . ", " . height, A_WorkingDir . "\cfg\Settings.ini", "Window Positions", processName)

								MsgBox("IniWrite (AppsKey (" . GetKeyState("AppsKey", "P") . "))")

								position := {x: x, y: y, Width: width, Height: height}
							}
							else {
								if (A_Debug) {
									Console.Log("Restoring window positon.")
								}

								WinMove(position.x, position.y, position.Width, position.Height, windowHandle)
							}
						}
					}

					SetTimer(BoundFunc, -50)
				}
			}
		}
	}

	WinWaitNotActive(windowHandle)

	SetTimer(WindowMonitor, -50)
}

;======================================================== Hook ================;

__WindowMessage(wParam := 0, lParam := 0, msg := 0, hWnd := 0) {
	switch (wParam) {
		case 0x1000:
			if (!(A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug"))) {
				ToolTip("", , , 20)
			}

			return (True)
	}

	return (-1)
}

__Exit(exitReason, exitCode) {
	Critical(True)

	ExitApp()
}