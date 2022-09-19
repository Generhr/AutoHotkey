#Requires AutoHotkey v2.0-beta.9

;============ Auto-Execute ====================================================;
;======================================================  Include  ==============;

#Include ..\lib\Console\Console.ahk

;======================================================  Setting  ==============;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

CoordMode("ToolTip", "Screen")
ListLines(False)
ProcessSetPriority("High")

;====================================================== Variable ==============;

global A_Debug := IniRead("..\cfg\Settings.ini", "Debug", "Debug")

Console.KeyboardHook := LowLevelKeyboardProc

LowLevelKeyboardProc(nCode, wParam, lParam) {
	Critical(True)

	if (!nCode) {  ;? 0 = HC_ACTION
		if (Format("{:#x}", NumGet(lParam, "UInt")) == 0x1B && (WinActive("ahk_group Console"))) {
			ExitApp()
		}
	}

	return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
}

;======================================================== Hook ================;

OnExit(__Exit)

DllCall("User32\RegisterShellHookWindow", "UInt", A_ScriptHwnd)
OnMessage(DllCall("User32\RegisterWindowMessage", "Str", "SHELLHOOK"), ShellMessage)

;=======================================================  Other  ===============;

Exit()

;=============== Hotkey =======================================================;

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

;============== Function ======================================================;

__Exit(exitReason, exitCode) {
	Critical(True)

	DllCall("User32\DeregisterShellHookWindow", "UInt", A_ScriptHwnd)

	ExitApp()
}

ShellMessage(wParam, lParam, msg, hWnd) {
	Critical(True)

	switch (wParam) {  ;* My best guess is that nVidia is is not using CallNextHookEx, so many of these messages can't be received.
		case 1:  ;? 1 = HSHELL_WINDOWCREATED
			Console.Log("HSHELL_WINDOWCREATED:`n  " . WinGetTitle(lParam) . "`n  ahk_class " . WinGetClass(lParam) . "`n  ahk_exe" . WinGetProcessName(lParam))
		case 2:  ;? 2 = HSHELL_WINDOWDESTROYED
			Console.Log("HSHELL_WINDOWDESTROYED")
		case 3:  ;? 3 = HSHELL_ACTIVATESHELLWINDOW
			Console.Log("HSHELL_ACTIVATESHELLWINDOW : " . WinGetProcessName(lParam))
		case 4:  ;? 4 = HSHELL_WINDOWACTIVATED
			try {
				processName := WinGetProcessName(lParam)

				Console.Clear()
				Console.Log("HSHELL_WINDOWACTIVATED: " . processName)
			}
			catch {
				Console.Log("HSHELL_WINDOWACTIVATED")
			}
		case 5:  ;? 5 = HSHELL_GETMINRECT
			Console.Log("HSHELL_GETMINRECT")
		case 6:  ;? 6 = HSHELL_REDRAW
			Console.Log("HSHELL_REDRAW")
		case 7:  ;? 7 = HSHELL_TASKMAN
			Console.Log("HSHELL_TASKMAN")
		case 8:  ;? 8 = HSHELL_LANGUAGE
			Console.Log("HSHELL_LANGUAGE")
		case 9:  ;? 9 = HSHELL_SYSMENU
			Console.Log("HSHELL_SYSMENU")
		case 10:  ;? 10 = HSHELL_ENDTASK
			Console.Log("HSHELL_ENDTASK")
		case 11:  ;? 11 = HSHELL_ACCESSIBILITYSTATE
			Console.Log("HSHELL_ACCESSIBILITYSTATE")
		case 12:  ;? 12 = HSHELL_APPCOMMAND
			Console.Log("HSHELL_APPCOMMAND")
		case 13:  ;? 13 = HSHELL_WINDOWREPLACED
			Console.Log("HSHELL_WINDOWREPLACED")
		case 14:  ;? 14 = HSHELL_WINDOWREPLACING
			Console.Log("HSHELL_WINDOWREPLACING")

		case 0x8004:  ;? 0x8004 = HSHELL_RUDEAPPACTIVATED (HSHELL_WINDOWACTIVATED | HSHELL_HIGHBIT)
			try {
				processName := WinGetProcessName(lParam)

				Console.Clear()
				Console.Log("HSHELL_RUDEAPPACTIVATED: " . processName)
			}
			catch {
				Console.Log("HSHELL_RUDEAPPACTIVATED")
			}
		case 0x8006:  ;? 0x8006 = HSHELL_FLASH (HSHELL_REDRAW | HSHELL_HIGHBIT)
			Console.Log("HSHELL_FLASH")

		default:
			Console.Log("UNKNOWN: " wParam ", " lParam ", " msg ", " hWnd)
	}
}