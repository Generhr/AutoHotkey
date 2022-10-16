#Requires AutoHotkey v2.0-beta.12

;============ Auto-Execute ====================================================;
;--------------  Include  ------------------------------------------------------;

#Include ..\lib\Console\Console.ahk

;--------------  Setting  ------------------------------------------------------;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

CoordMode("ToolTip", "Screen")
ListLines(False)
ProcessSetPriority("High")

;-------------- Variable ------------------------------------------------------;

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

;---------------- Hook --------------------------------------------------------;

DllCall("User32\RegisterShellHookWindow", "UInt", A_ScriptHwnd)
OnMessage(DllCall("User32\RegisterWindowMessage", "Str", "SHELLHOOK"), ShellMessageHandler)

OnExit(ExitHandler)

;---------------  Other  -------------------------------------------------------;

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

ShellMessageHandler(wParam, lParam, msg, hWnd) {
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
			Console.Log("HSHELL_APPCOMMAND")  ;? 1 = APPCOMMAND_BROWSER_BACKWARD, 2 = APPCOMMAND_BROWSER_FORWARD, 3 = APPCOMMAND_BROWSER_REFRESH, 4 = APPCOMMAND_BROWSER_STOP, 5 = APPCOMMAND_BROWSER_SEARCH, 6 = APPCOMMAND_BROWSER_FAVORITES, 7 = APPCOMMAND_BROWSER_HOME, 8 = APPCOMMAND_VOLUME_MUTE, 9 = APPCOMMAND_VOLUME_DOWN, 10 = APPCOMMAND_VOLUME_UP, 11 = APPCOMMAND_MEDIA_NEXTTRACK, 12 = APPCOMMAND_MEDIA_PREVIOUSTRACK, 13 = APPCOMMAND_MEDIA_STOP, 14 = APPCOMMAND_MEDIA_PLAY_PAUSE, 15 = APPCOMMAND_LAUNCH_MAIL, 16 = APPCOMMAND_LAUNCH_MEDIA_SELECT, 17 = APPCOMMAND_LAUNCH_APP1, 18 = APPCOMMAND_LAUNCH_APP2, 19 = APPCOMMAND_BASS_DOWN, 20 = APPCOMMAND_BASS_BOOST, 21 = APPCOMMAND_BASS_UP, 22 = APPCOMMAND_TREBLE_DOWN, 23 = APPCOMMAND_TREBLE_UP, 24 = APPCOMMAND_MICROPHONE_VOLUME_MUTE, 25 = APPCOMMAND_MICROPHONE_VOLUME_DOWN, 26 = APPCOMMAND_MICROPHONE_VOLUME_UP, 27 = APPCOMMAND_HELP, 28 = APPCOMMAND_FIND, 29 = APPCOMMAND_NEW, 30 = APPCOMMAND_OPEN, 31 = APPCOMMAND_CLOSE, 32 = APPCOMMAND_SAVE, 33 = APPCOMMAND_PRINT, 34 = APPCOMMAND_UNDO, 35 = APPCOMMAND_REDO, 36 = APPCOMMAND_COPY, 37 = APPCOMMAND_CUT, 38 = APPCOMMAND_PASTE, 39 = APPCOMMAND_REPLY_TO_MAIL, 40 = APPCOMMAND_FORWARD_MAIL, 41 = APPCOMMAND_SEND_MAIL, 42 = APPCOMMAND_SPELL_CHECK, 43 = APPCOMMAND_DICTATE_OR_COMMAND_CONTROL_TOGGLE, 44 = APPCOMMAND_MIC_ON_OFF_TOGGLE, 45 = APPCOMMAND_CORRECTION_LIST, 46 = APPCOMMAND_MEDIA_PLAY, 47 = APPCOMMAND_MEDIA_PAUSE, 48 = APPCOMMAND_MEDIA_RECORD, 49 = APPCOMMAND_MEDIA_FAST_FORWARD, 50 = APPCOMMAND_MEDIA_REWIND, 51 = APPCOMMAND_MEDIA_CHANNEL_UP, 52 = APPCOMMAND_MEDIA_CHANNEL_DOWN, 53 = APPCOMMAND_DELETE, 54 = APPCOMMAND_DWM_FLIP3D
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

ExitHandler(exitReason, exitCode) {
	Critical(True)

	DllCall("User32\DeregisterShellHookWindow", "UInt", A_ScriptHwnd)

	ExitApp()
}