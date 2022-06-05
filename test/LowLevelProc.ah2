;============ Auto-execute ====================================================;

#Requires AutoHotkey v2.0-beta

;======================================================  Setting  ==============;

;#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off
#WinActivateForce

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
DetectHiddenWindows(True)
InstallKeybdHook()
InstallMouseHook()
ListLines(False)
Persistent(True)
ProcessSetPriority("High")
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir . "\..")

;====================================================== Variable ==============;

global mouseHook := SetWindowsHookEx(14, LowLevelMouseProc)
	, keyboardHook := SetWindowsHookEx(13, LowLevelKeyboardProc)

;=======================================================  Other  ===============;

exit

;=============== Hotkey =======================================================;

#HotIf (WinActive(A_ScriptName))

	$F10:: {
		ListVars

		KeyWait("F10")
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload
	}

#HotIf

~$Escape:: {
	global mouseHook := "", keyboardHook := ""

	ExitApp
}

;============== Function ======================================================;

SetWindowsHookEx(idHook, callback) {
	if (!(hHook := DllCall("User32\SetWindowsHookExW", "Int", idHook, "Ptr", CallbackCreate(callback, "Fast"), "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr"), "UInt", 0, "Ptr"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw
		throw (Error(Format("0x{:X}", A_LastError), -1, ErrorFromMessage(A_LastError)))
	}

	static instance := {Call: (*) => ({Class: "HookEx",
		__Delete: UnhookWindowsHookEx})}

	(hookEx := instance.Call()).Handle := hHook

	return (hookEx)
}

UnhookWindowsHookEx(hookEx) {
	if (!DllCall("UnhookWindowsHookEx", "Ptr", hookEx.Handle, "UInt")) {
		throw (Error(Format("0x{:X}", A_LastError), -1, ErrorFromMessage(A_LastError)))
	}
}

;* ErrorFromMessage(messageID)
ErrorFromMessage(messageID) {
	if (!(length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100  ;? 0x1100 = FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER
		, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", &(buffer := 0), "UInt", 0, "Ptr", 0, "Int"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
		return (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
	}

	message := StrGet(buffer, length - 2)  ;* Account for the newline and carriage return characters.
	DllCall("Kernel32\LocalFree", "Ptr", buffer)

	return (Error(Format("0x{:X}", messageID), -1, message))
}

LowLevelMouseProc(nCode, wParam, lParam) {
	Critical(True)

	x := NumGet(lParam + 0, "Int"), y := NumGet(lParam + 4, "Int")

	switch (wParam) {
		case 0x0201:  ;? 0x0201 = WM_LBUTTONDOWN
			ToolTip("WM_LBUTTONDOWN")
		case 0x0202:  ;? 0x0202 = WM_LBUTTONUP
			ToolTip("WM_LBUTTONUP")

		case 0x0204:  ;? 0x0204 = WM_RBUTTONDOWN
			ToolTip("WM_RBUTTONDOWN")
		case 0x0205:  ;? 0x0205 = WM_RBUTTONUP
			ToolTip("WM_RBUTTONUP")

		case 0x0207:  ;? 0x0207 = WM_MBUTTONDOWN
			ToolTip("WM_MBUTTONDOWN")
		case 0x0208:  ;? 0x0208 = WM_MBUTTONUP
			ToolTip("WM_MBUTTONUP")

		case 0x020A:  ;? 0x020A = WM_MOUSEWHEEL (Vertical)
			ToolTip(Format("WM_MOUSEWHEEL {}", (NumGet(lParam + 8, "UInt") >> 16 == 120) ? ("Up") : ("Down")))
		case 0x020E:  ;? 0x020E = WM_MOUSEWHEEL (Horizontal)
			ToolTip(Format("WM_MOUSEWHEEL {}", (NumGet(lParam + 8, "UInt") >> 16 == 120) ? ("Right") : ("Left")))
	}

	return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam))
}

LowLevelKeyboardProc(nCode, wParam, lParam) {
	Critical(True)

	scCode := ((scCode := (NumGet(lParam + 0, 8, "UInt") & 1 << 8) | NumGet(lParam + 4, "UInt")) == 0x136) ? (0x36) : (scCode), vkCode := Format("{:X}", NumGet(lParam + 0, "UInt"))
		, key := GetKeyName(Format("vk{}", vkCode))

	switch (wParam) {
		case 0x100:  ;? 0x100 = WM_KEYDOWN
			ToolTip("WM_KEYDOWN")
		case 0x101:  ;? 0x101 = WM_KEYUP
			ToolTip("WM_KEYUP")

		case 0x104:  ;? 0x104 = WM_SYSKEYDOWN
			ToolTip("WM_SYSKEYDOWN")
		case 0x105:  ;? 0x105 = WM_SYSKEYUP
			ToolTip("WM_SYSKEYUP")
	}

	return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam))
}
