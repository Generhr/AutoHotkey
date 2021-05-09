;======================================================  Setting  ==============;

#InstallKeybdHook
#InstallMouseHook
#KeyHistory, 0
#NoEnv
;#NoTrayIcon
;#Persistent
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox
#WinActivateForce

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
;DetectHiddenWindows, On
ListLines, Off
Process, Priority, , High
SendMode, Input
SetBatchLines, -1
SetKeyDelay, -1, -1
SetTitleMatchMode, 2
SetWinDelay, -1
SetWorkingDir, % A_ScriptDir . "\.."

;====================================================== Variable ==============;

mouseHook := SetWindowsHookEx(14, "LowLevelMouseProc")
	, keyboardHook := SetWindowsHookEx(13, "LowLevelKeyboardProc")

;=======================================================  Other  ===============;

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

;============== Function ======================================================;

SetWindowsHookEx(idHook, callback) {
	if (!hHook := DllCall(Format("SetWindowsHookEx{}", (A_IsUnicode) ? ("W") : ("A")), "Int", idHook, "Ptr", RegisterCallback(callback, "Fast"), "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr"), "UInt", 0, "Ptr")) {
		throw (Exception(Format("0x{:X}", A_LastError), -1, FormatMessage(A_LastError)))
	}

	Static instance := {"__Class": "__HookEx"
			, "__Delete": Func("UnhookWindowsHookEx")}

	(hookEx := new instance()).Handle := hHook

	return (hookEx)
}

UnhookWindowsHookEx(hookEx) {
	if (!DllCall("UnhookWindowsHookEx", "Ptr", hookEx.Handle, "UInt")) {
		throw (Exception(Format("0x{:X}", A_LastError), -1, FormatMessage(A_LastError)))
	}

	return (True)
}

LowLevelMouseProc(nCode, wParam, lParam) {
	Critical, On

	x := NumGet(lParam + 0, "Int"), y := NumGet(lParam + 4, "Int")

	switch (wParam) {
		case 0x0201: {  ;? 0x0201 = WM_LBUTTONDOWN
			ToolTip, % "WM_LBUTTONDOWN"
		}
		case 0x0202: {  ;? 0x0202 = WM_LBUTTONUP
			ToolTip, % "WM_LBUTTONUP"
		}

		case 0x0204: {  ;? 0x0204 = WM_RBUTTONDOWN
			ToolTip, % "WM_RBUTTONDOWN"
		}
		case 0x0205: {  ;? 0x0205 = WM_RBUTTONUP
			ToolTip, % "WM_RBUTTONUP"
		}

		case 0x0207: {  ;? 0x0207 = WM_MBUTTONDOWN
			ToolTip, % "WM_MBUTTONDOWN"
		}
		case 0x0208: {  ;? 0x0208 = WM_MBUTTONUP
			ToolTip, % "WM_MBUTTONUP"
		}

		case 0x020A: {  ;? 0x020A = WM_MOUSEWHEEL (Vertical)
			ToolTip, % Format("WM_MOUSEWHEEL {}", (NumGet(lParam + 8, "UInt") >> 16 == 120) ? ("Up") : ("Down"))
		}
		case 0x020E: {  ;? 0x020E = WM_MOUSEWHEEL (Horizontal)
			ToolTip, % Format("WM_MOUSEWHEEL {}", (NumGet(lParam + 8, "UInt") >> 16 == 120) ? ("Right") : ("Left"))
		}
	}

	return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam))
}

LowLevelKeyboardProc(nCode, wParam, lParam) {
	Critical, On

	scCode := ((scCode := (NumGet(lParam + 0, 8, "UInt") & 1 << 8) | NumGet(lParam + 4, "UInt")) == 0x136) ? (0x36) : (scCode), vkCode := Format("{:X}", NumGet(lParam + 0, "UInt"))
		, key := GetKeyName(Format("vk{}", vkCode))

	switch (wParam) {
		case 0x100: {  ;? 0x100 = WM_KEYDOWN
			ToolTip, % "WM_KEYDOWN"
		}
		case 0x101: {  ;? 0x101 = WM_KEYUP
			ToolTip, % "WM_KEYUP"
		}

		case 0x104: {  ;? 0x104 = WM_SYSKEYDOWN
			ToolTip, % "WM_SYSKEYDOWN"
		}
		case 0x105: {  ;? 0x105 = WM_SYSKEYUP
			ToolTip, % "WM_SYSKEYUP"
		}
	}

	return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam))
}

;* FormatMessage(messageID)
FormatMessage(messageID) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
	Local

	if (!length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", buffer := 0, "UInt", 0, "Ptr", 0, "UInt")) {
		return (FormatMessage(DllCall("Kernel32\GetLastError")))
	}

	return (StrGet(buffer, length - 2), DllCall("Kernel32\LocalFree", "Ptr", buffer, "Ptr"))  ;* Account for the newline and carriage return characters.
}