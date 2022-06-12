#Requires AutoHotkey v2.0-beta

;============ Auto-Execute ====================================================;
;======================================================  Setting  ==============;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

CoordMode("ToolTip", "Screen")
ListLines(False)
ProcessSetPriority("High")

;====================================================== Variable ==============;

global keyboardHook := SetWindowsHookEx(13, LowLevelKeyboardProc)  ;? 13 = WH_KEYBOARD_LL
	, mouseHook := SetWindowsHookEx(14, LowLevelMouseProc)  ;? 14 = WH_MOUSE_LL

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

~$Escape:: {
	global keyboardHook := "", mouseHook := ""

	ExitApp()
}

;============== Function ======================================================;

SetWindowsHookEx(idHook, callback) {
	if (!(hHook := DllCall("User32\SetWindowsHookEx", "Int", idHook, "Ptr", CallbackCreate(callback, "Fast"), "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0, "Ptr"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw
		throw (MessageError(DllCall("Kernel32\GetLastError")))
	}

	static instance := {Call: (*) => ({Class: "HookEx",
		__Delete: UnhookWindowsHookEx})}

	UnhookWindowsHookEx(hookEx) {
		if (!DllCall("UnhookWindowsHookEx", "Ptr", hookEx.Handle, "UInt")) {
			throw (MessageError(DllCall("Kernel32\GetLastError")))
		}
	}

	(hookEx := instance.Call()).Handle := hHook
	return (hookEx)
}

MessageError(messageID) {
	if (!(length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", &(buffer := 0), "UInt", 0, "Ptr", 0, "Int"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
		return (MessageError(DllCall("Kernel32\GetLastError")))
	}

	message := StrGet(buffer, length - 2)  ;* Account for the newline and carriage return characters.
	DllCall("Kernel32\LocalFree", "Ptr", buffer)

	return (Error(Format("{:#x}", messageID), -1, message))
}

LowLevelKeyboardProc(nCode, wParam, lParam) {
	Critical(True)

	if (!nCode) {  ;? 0 = HC_ACTION
		flags := NumGet(lParam + 8, "UInt")
			, extended := flags & 0x00000001, injected := (flags & 0x00000010) >> 4, context := (flags & 0x00000020) >> 5, state := (flags & 0x00000080) >> 7  ;? 0x00000001 = LLKHF_EXTENDED, 0x00000010 = LLKHF_INJECTED, 0x00000020 = LLKHF_ALTDOWN, 0x00000080 = LLKHF_UP

		scanCode := NumGet(lParam + 4, "UInt") | (extended << 8), vkCode := Format("{:#x}", NumGet(lParam, "UInt"))  ;* Virtual-Key Codes: https://docs.microsoft.com/en-gb/windows/win32/inputdev/virtual-key-codes?redirectedfrom=MSDN.
			, keyName := GetKeyName(Format("vk{}", vkCode))

		ToolTip(keyName, 50, 75, 20)

		switch (wParam) {
			case 0x100:  ;? 0x100 = WM_KEYDOWN
				ToolTip("WM_KEYDOWN", 50, 50, 19)
			case 0x101:  ;? 0x101 = WM_KEYUP
				ToolTip("WM_KEYUP", 50, 50, 19)

			case 0x104:  ;? 0x104 = WM_SYSKEYDOWN
				ToolTip("WM_SYSKEYDOWN", 50, 50, 19)
			case 0x105:  ;? 0x105 = WM_SYSKEYUP
				ToolTip("WM_SYSKEYUP", 50, 50, 19)
		}
	}

	return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
}

LowLevelMouseProc(nCode, wParam, lParam) {
	Critical(True)

	if (!nCode) {
		flags := NumGet(lParam + 12, "UInt")
			, injected := (flags & 0x00000001) || (flags & 0x00000002)  ;? 0x00000001 = LLMHF_INJECTED, 0x00000002 = LLMHF_LOWER_IL_INJECTED

		x := NumGet(lParam, "Int"), y := NumGet(lParam + 4, "Int")

		ToolTip(x ", " y, 50, 75, 20)

		switch (wParam) {
			case 0x0201:  ;? 0x0201 = WM_LBUTTONDOWN
				ToolTip("WM_LBUTTONDOWN", 50, 50, 19)
			case 0x0202:  ;? 0x0202 = WM_LBUTTONUP
				ToolTip("WM_LBUTTONUP", 50, 50, 19)

			case 0x0204:  ;? 0x0204 = WM_RBUTTONDOWN
				ToolTip("WM_RBUTTONDOWN", 50, 50, 19)
			case 0x0205:  ;? 0x0205 = WM_RBUTTONUP
				ToolTip("WM_RBUTTONUP", 50, 50, 19)

			case 0x0207:  ;? 0x0207 = WM_MBUTTONDOWN
				ToolTip("WM_MBUTTONDOWN", 50, 50, 19)
			case 0x0208:  ;? 0x0208 = WM_MBUTTONUP
				ToolTip("WM_MBUTTONUP", 50, 50, 19)

			case 0x020A:  ;? 0x020A = WM_MOUSEWHEEL (Vertical)
				ToolTip(Format("WM_MOUSEWHEEL {}", (NumGet(lParam + 8, "UInt") >> 16 == 120) ? ("Up") : ("Down")), 50, 50, 19)
			case 0x020E:  ;? 0x020E = WM_MOUSEWHEEL (Horizontal)
				ToolTip(Format("WM_MOUSEWHEEL {}", (NumGet(lParam + 8, "UInt") >> 16 == 120) ? ("Right") : ("Left")), 50, 50, 19)
		}
	}

	return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
}
