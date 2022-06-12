#Requires AutoHotkey v2.0-beta

;============ Auto-Execute ====================================================;
;======================================================  Setting  ==============;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

CoordMode("ToolTip", "Screen")
ListLines(False)
ProcessSetPriority("High")

;======================================================== Hook ================;

for v in [0x0200, 0x02A1, 0x02A3] {
	OnMessage(v, MsgHandler)
}

;=======================================================  Other  ===============;

(square := Gui("+AlwaysOnTop -Caption +Border +LastFound +ToolWindow")).Add("Edit", Format("x{} y{} w{} h{}", 50, 50, 25, 25))
square.Show(Format("x{} y{} w{} h{} NA", 50, 50, 100, 100))
WinSetTransparent(80, square)

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
	ExitApp()
}

;============== Function ======================================================;

MsgHandler(wParam, lParam, msg, hWND) {
	Critical(True)

	if (!GuiFromHwnd(hWND)) {  ;* This is here to ignore `ToolTip()` windows.
		return (0)
	}

	x := lParam & 0xFFFF, y := lParam >> 16

	ToolTip(x ", " y, 50, 75, 19)

	static tracking := False

	switch (msg) {
		case 0x0200:  ;? 0x0200 = WM_MOUSEMOVE
			if (!tracking) {
				tracking := True

				ToolTip("WM_MOUSEMOVE", 50, 50, 20)

				TrackMouseEvent(hWND, 0x00000003)  ;? 0x00000003 = TME_HOVER | TME_LEAVE
			}
		case 0x02A1:  ;? 0x02A1 = WM_MOUSEHOVER
			static perpetual := False

			ToolTip("WM_MOUSEHOVER", 50, 50, 20)

			if (perpetual) {
				TrackMouseEvent(hWND, 0x00000001)  ;? 0x00000001 = TME_HOVER
			}
		case 0x02A3:  ;? 0x02A3 = WM_MOUSELEAVE
			tracking := False

			ToolTip(, , , 19)
			ToolTip("WM_MOUSELEAVE", 50, 50, 20)

			TrackMouseEvent(hWND, 0x80000000)  ;? 0x80000000 = TME_CANCEL

		case 0x00A0:  ;? 0x00A0 = WM_NCMOUSEMOVE
			ToolTip("WM_NCMOUSEMOVE", 50, 50, 20)
		case 0x02A0:  ;? 0x02A0 = WM_NCMOUSEHOVER
			ToolTip("WM_NCMOUSEHOVER", 50, 50, 20)
		case 0x02A2:  ;? 0x02A2 = WM_NCMOUSELEAVE
			ToolTip("WM_NCMOUSELEAVE", 50, 50, 20)
	}

	TrackMouseEvent(hWnd, flags := 0x00000002, hoverTime := 400) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent
		static size := A_PtrSize*2 + 8

		eventTrack := Buffer(size)
			, NumPut("UInt", size, "UInt", flags, "Ptr", hWnd, "UInt", hoverTime, eventTrack)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-trackmouseevent

		if (!DllCall("User32\TrackMouseEvent", "Ptr", eventTrack, "UInt")) {
			throw (MessageError(DllCall("Kernel32\GetLastError")))
		}

		return (True)
	}
}

MessageError(messageID) {
	if (!(length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", &(buffer := 0), "UInt", 0, "Ptr", 0, "Int"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
		return (MessageError(DllCall("Kernel32\GetLastError")))
	}

	message := StrGet(buffer, length - 2)  ;* Account for the newline and carriage return characters.
	DllCall("Kernel32\LocalFree", "Ptr", buffer)

	return (Error(Format("{:#x}", messageID), -1, message))
}