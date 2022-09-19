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

;======================================================  Setting  ==============;

;#NoTrayIcon
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

global A_Debug := False  ;! A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("User32\RegisterWindowMessage", "Str", "WindowMessage", "UInt")

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

DllCall("User32\RegisterShellHookWindow", "UInt", A_ScriptHwnd)
OnMessage(DllCall("User32\RegisterWindowMessage", "Str", "SHELLHOOK"), ShellMessage)

;=======================================================  Other  ===============;

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

ShellMessage(wParam, windowHandle, *) {
	Critical(True)

	switch (wParam) {  ;* My best guess is that nVidia is is not using CallNextHookEx, so many of these messages can't be received.
		case 1:  ;? 1 = HSHELL_WINDOWCREATED
		case 2:  ;? 2 = HSHELL_WINDOWDESTROYED
		case 3:  ;? 3 = HSHELL_ACTIVATESHELLWINDOW
		case 4, 0x8004:  ;? 4 = HSHELL_WINDOWACTIVATED, 0x8004 = HSHELL_RUDEAPPACTIVATED (HSHELL_WINDOWACTIVATED | HSHELL_HIGHBIT)
			try {
				windowTitle := WinGetTitle(windowHandle), windowClass := WinGetClass(windowHandle), windowProcessName := WinGetProcessName(windowHandle)

				if (windowProcessName == "ApplicationFrameHost.exe") {
					windowProcessName := windowTitle . ".exe"
				}

				if (A_Debug) {
					Console.Clear()
					Console.Log(Format("Found a valid window:`n    - {}`n    - ahk_class {}`n    - ahk_exe {}`n", windowTitle, windowClass, windowProcessName))
				}

				position := []

				loop parse, IniRead(A_WorkingDir . "\cfg\Settings.ini", "Window Positions", windowProcessName, "Error"), ",", " " {
					position.Push(A_LoopField)
				}

				if (position.Length) {
					if (A_Debug) {
						Console.Log("Saved window.")
					}

					if (!(explorerWindow := (windowProcessName == "explorer.exe"))) {
						BoundFunc := WindowPosition.Bind(windowHandle, windowProcessName, position)

						WindowPosition(windowHandle, windowProcessName, position) {
							if (WinActive(windowHandle)) {
								if (!WinGetMinMax(windowHandle)) {
									WinGetPos(&x, &y, &width, &height, windowHandle)

									if (position[0] != x || position[1] != y || position[2] != width || position[3] != height) {
										if (A_Debug) {
											Console.Log("• Window has moved, ", False)
										}

										if (GetKeyState("LButton", "P")) {
											if (A_Debug) {
												Console.Log("waiting for {LButton} to be released...")
											}

											KeyWait("LButton")

											if (GetKeyState("AppsKey", "P")) {  ;* Allow repositioning and save the new coordinates if `{AppsKey}` is pressed when `{LButton}` is released.
												if (A_Debug) {
													Console.Log("• Saving new window positon.")
												}

												WinGetPos(&x, &y, &width, &height, windowHandle)

												IniWrite((position[0] := x) . ", " . (position[1] := y) . ", " . (position[2] := width) . ", " . (position[3] := height), A_WorkingDir . "\cfg\Settings.ini", "Window Positions", windowProcessName)
											}
											else {
												if (A_Debug) {
													Console.Log("• Restoring window positon.")
												}

												WinMove(position[0], position[1], position[2], position[3], windowHandle)
											}
										}
										else {
											if (A_Debug) {
												Console.Log("restoring window positon.")
											}

											WinMove(position[0], position[1], position[2], position[3], windowHandle)
										}
									}
								}

								SetTimer(BoundFunc, -50)
							}
						}
					}
					else {
						BoundFunc := WindowPositionExplorer.Bind(windowHandle, position)

						WindowPositionExplorer(windowHandle, originalPos) {
							if (WinActive(windowHandle)) {
								if (!WinGetMinMax(windowHandle)) {
									cascadeIndex := explorerWindows.Cascade.IndexOf(windowHandle)
										, WinGetPos(&x, &y, &width, &height, windowHandle)

									if (~cascadeIndex) {
										offset := x - originalPos[0]
											, offsetPos := [originalPos[0] + offset, originalPos[1] - offset, originalPos[2], originalPos[3]]

										hasMoved := originalPos[0] != x || originalPos[1] != y || originalPos[2] != width || originalPos[3] != height
									}
									else {
										exemptIndex := explorerWindows.Exempt.IndexOf(windowHandle)
											, offsetPos := explorerWindows.ExemptPosition[windowHandle]

										hasMoved := offsetPos[0] != x || offsetPos[1] != y || offsetPos[2] != width || offsetPos[3] != height
									}

									if (hasMoved) {
										if (A_Debug) {
											Console.Log("• Window has moved, ", False)
										}

										if (GetKeyState("LButton", "P")) {
											if (A_Debug) {
												Console.Log("waiting for {LButton} to be released...")
											}

											KeyWait("LButton")

											WinGetPos(&x, &y, &width, &height, windowHandle)

											if (GetKeyState("AppsKey", "P")) {
												if (A_Debug) {
													Console.Log("• Saving new window positon.")
												}

												IniWrite((originalPos[0] := x) . ", " . (originalPos[1] := y) . ", " . (originalPos[2] := width) . ", " . (originalPos[3] := height), A_WorkingDir . "\cfg\Settings.ini", "Window Positions", "Explorer.EXE")

												if (IsSet(exemptIndex)) {
													explorerWindows.Cascade.UnShift(explorerWindows.Exempt.RemoveAt(exemptIndex))  ;* Transfer the handle back to `explorerWindows.Cascade` as this is now the new `originalPos` from which other explorerWindows windows will be offset.
												}
											}
											else if (offsetPos[2] != width || offsetPos[3] != height) {
												if (IsSet(exemptIndex)) {
													if (A_Debug) {
														Console.Log("• Saving new width/height.")
													}

													explorerWindows.ExemptPosition[windowHandle] := [x, y, width, height]
												}
												else {
													if (A_Debug) {
														Console.Log("• Restoring window width/height.")
													}

													WinMove(offsetPos[0], offsetPos[1], offsetPos[2], offsetPos[3], windowHandle)
												}
											}
											else if (offsetPos[0] != x || offsetPos[1] != y) {  ;* If the window has been moved but not resized.
												if (A_Debug) {
													Console.Log("• Saving new position" . ((IsSet(exemptIndex)) ? (".") : (" and marking this window as exempt from cascading.")))
												}

												explorerWindows.ExemptPosition[windowHandle] := [x, y, width, height]

												if (~cascadeIndex) {
													explorerWindows.Exempt.Push(explorerWindows.Cascade.RemoveAt(cascadeIndex))  ;* Transfer the handle from `explorerWindows.Cascade` to `explorerWindows.Exempt`.

													if (A_Debug) {
														Console.Log("• Cascading windows.")
													}

													Cascade(originalPos)
												}
											}
											else {
												if (A_Debug) {
													Console.Log("• Cascading windows.")
												}

												Cascade(originalPos)
											}
										}
										else {
											if (A_Debug) {
												Console.Log("cascading windows.")
											}

											Cascade(originalPos)
										}
									}
								}

								SetTimer(BoundFunc, -50)
							}
						}
					}

					if (!WinGetMinMax(windowHandle)) {
						if (!explorerWindow) {
							if (A_Debug) {
								Console.Log("• Setting initial position.")
							}

							WinMove(position[0], position[1], position[2], position[3], windowHandle)  ;* If the window is not maximized then perform an initial position update because Windows repositions some windows randomly when they are first created.
						}
						else {
							static explorerWindows := {Cascade: [], Exempt: [], ExemptPosition: Map()}

							for handle in [].Concat(explorerWindows.Cascade, explorerWindows.Exempt) {  ;* Create a clone array of `explorerWindows.Cascade` and `explorerWindows.Exempt` to iterate through and remove handles that don't exist anymore from the original arrays.
								if (!WinExist(handle)) {
									if (explorerWindows.Exempt.Includes(handle)) {
										explorerWindows.Exempt.RemoveAt(explorerWindows.Exempt.IndexOf(handle))  ;* The index needs to be looked up each time because removing any element will desync `explorerWindows.Cascade` and `explorerWindows.Exempt` from `[].Concat(explorerWindows.Cascade, explorerWindows.Exempt)`.
										explorerWindows.ExemptPosition.Remove(handle)
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
									if (A_Debug) {
										Console.Log("• Cascading windows.")
									}

									Cascade(position)

									Cascade(position) {
										for index, handle in explorerWindows.Cascade {
											offset := index*50

											if (!DllCall("User32\SetWindowPos", "Ptr", handle, "Ptr", 0, "Int", position[0] + offset, "Int", position[1] - offset, "Int", position[2], "Int", position[3], "UInt", 0x0004, "UInt")) {  ;? 0x0004 = SWP_NOZORDER  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
												throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
											}
										}

										if (A_Debug) {
											ToolTip(explorerWindows.Cascade.Print() . " || " . explorerWindows.Exempt.Print() . "`n`n" . explorerWindows.ExemptPosition.Print(), 5, 5, 20)
										}
									}
								}
							}
							else {
								position := explorerWindows.ExemptPosition[windowHandle]
							}
						}
					}
					else {
						if (A_Debug) {
							Console.Log("• Window is maximized.")
						}
					}

					try {
						SetTimer(BoundFunc, -50)
					}
				}
				else if (A_Debug) {
					Console.Log("Not interested in this window.")
				}
			}
			catch {
				if (A_Debug) {
					Console.Clear()
					Console.Log("Waiting for a valid window...")
				}
			}
		case 5:  ;? 5 = HSHELL_GETMINRECT
		case 6:  ;? 6 = HSHELL_REDRAW
		case 7:  ;? 7 = HSHELL_TASKMAN
		case 8:  ;? 8 = HSHELL_LANGUAGE
		case 9:  ;? 9 = HSHELL_SYSMENU
		case 10:  ;? 10 = HSHELL_ENDTASK
		case 11:  ;? 11 = HSHELL_ACCESSIBILITYSTATE
		case 12:  ;? 12 = HSHELL_APPCOMMAND
		case 13:  ;? 13 = HSHELL_WINDOWREPLACED
		case 14:  ;? 14 = HSHELL_WINDOWREPLACING

		case 0x8006:  ;? 0x8006 = HSHELL_FLASH (HSHELL_REDRAW | HSHELL_HIGHBIT)

		case 16:

		case 53, 54:

		default:
			Console.Log("UNKNOWN: " wParam ", " windowHandle)
	}
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

	DllCall("User32\DeregisterShellHookWindow", "UInt", A_ScriptHwnd)

	ExitApp()
}