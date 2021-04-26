;==============  Include  ======================================================;

#Include, <Math>
#Include, <Structure>

;============== Function ======================================================;

__ConsoleCtrlHandler(ctrlType) {  ;: https://docs.microsoft.com/en-us/windows/console/handlerroutine
	switch (ctrlType) {
		case 0: {  ;? 0 = CTRL_C_EVENT
			return (1)
		}
		case 2: {  ;? 2 = CTRL_CLOSE_EVENT
			;! DllCall("FreeConsole")

			return (0)
		}
	}
}

__WindowsProc(nCode, wParam, lParam) {
	Critical, On

	if (WinActive("ahk_group Console")) {
		switch (wParam) {
			case 0x100: {  ;? 0x100 = WM_KEYDOWN
				SetFormat IntegerFast, H

				if (GetKeyName(Format("vk{}", NumGet(lParam + 0, "UInt"))) == "Escape") {
					Console.Hide()
				}
			}
			case 0x0202: {  ;? 0x0202 = WM_LBUTTONUP
				CoordMode, Mouse, Client
				MouseGetPos, x, y

				if (!(931 > x || x > 977 || -30 > y || y > -1)) {  ;! SendMessage, 0x0084, , (x & 0xFFFF) | (y & 0xFFFF) << 16  ;? 0x0084 = WM_NCHITTEST
					Console.Hide()
				}
			}
		}
	}

	return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "Ptr", lParam))
}

;===============  Class  =======================================================;

Class Console {
	Static Handle := Console.Create()

	Create() {
		if (!this.Handle) {
			WinGet, hWnd, ID, A

			if (!DllCall("AllocConsole", "UInt")) {
				throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
			}

			WinHide, % Format("ahk_id{}", DllCall("GetConsoleWindow"))
			WinActivate, % Format("ahk_id{}", hWnd)

			this.Handle := DllCall("GetConsoleWindow")
				, this.Input := DllCall("GetStdHandle", "Int", -10, "Ptr"), this.Output := DllCall("GetStdHandle", "Int", -11, "Ptr")

			DllCall("SetConsoleTitle", "Str", A_ScriptName)
			this.SetColor(0x0000, 0x000A)

			if (!DllCall("SetConsoleCtrlHandler", "UInt", RegisterCallback("__ConsoleCtrlHandler"), "UInt", 1, "UInt")) {
				throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
			}

			GroupAdd, Console, % Format("ahk_id{}", this.Handle)

			return (this.Handle)
		}
	}

	Delete() {
		this.Hide()

		if (!DllCall("FreeConsole", "UInt")) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		this.Handle := ""
	}

	GetColor() {
		if (!DllCall("GetConsoleScreenBufferInfo", "Ptr", this.Output, "Ptr", (consoleScreenBufferInfo := new Structure(20)).Pointer)) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		return ({"BackgroundColor": consoleScreenBufferInfo.NumGet(8, "Word") >> 4 & 0x0F, "ForegroundColor": consoleScreenBufferInfo.NumGet(8, "Word") & 0x0F})
	}

	SetColor(backgroundColor := 0x0, foregroundColor := 0xF) {
		if (!DllCall("SetConsoleTextAttribute", "Int", this.Output, "Int", backgroundColor << 4 | foregroundColor)) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}
	}

	GetCursorPosition() {
		if (!DllCall("GetConsoleScreenBufferInfo", "Ptr", this.Output, "Ptr", (consoleScreenBufferInfo := new Structure(20)).Pointer)) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		return ({"x": consoleScreenBufferInfo.NumGet(4, "Short"), "y": consoleScreenBufferInfo.NumGet(6, "Short")})
	}

	SetCursorPosition(x, y) {
		if (!DllCall("SetConsoleCursorPosition", "Ptr", this.Output, "UInt", x << 4 | y, "UInt")) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}
	}

	GetSize() {
		if (!DllCall("GetConsoleScreenBufferInfo", "Ptr", this.Output, "Ptr", (consoleScreenBufferInfo := new Structure(20)).Pointer)) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		return ({"Width": consoleScreenBufferInfo.NumGet(0, "Short"), "Height": consoleScreenBufferInfo.NumGet(2, "Short")})
	}

	SetSize(width, height) {
		if (!DllCall("SetConsoleScreenBufferSize", "Ptr", this.Output, "Ptr", CreateCoord(width, height).Pointer)) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		if (!DllCall("SetConsoleWindowInfo", "Ptr", this.Output, "UInt", True, "Ptr", CreateSmallRect(0, 0, width, height).Pointer)) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		return (DllCall("SetConsoleScreenBufferSize", "Ptr", this.Output, "UInt", width | height << 16))
	}

	SetTitle(title) {
		if (!DllCall("SetConsoleTitle", "Str", title, "UInt")) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}
	}

	FillOutputCharacter(character, length, x, y) {
		if (!DllCall("FillConsoleOutputCharacter", "Ptr", this.Output, "Short", Asc(character), "UInt", length, "UInt", x | y << 4, "Ptr", (numberOfCharsWritten := new Structure(4)).Pointer, "UInt")) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		return (numberOfCharsWritten.NumGet(0, "UInt"))
	}

	Clear() {
		size := this.GetSize()

		this.SetCursorPosition(0, 0)
		return (this.FillOutputCharacter(A_Space, size.Width*size.Height, 0, 0))
	}

	Hide(disable := 0) {
		if (disable || this.IsVisible) {
			if (!DllCall("UnhookWindowsHookEx", "Ptr", this.KeyboardHook, "UInt")) {
				MsgBox(Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16) . " (" . DllCall("GetLastError", "UInt") . ")")
			}

			if (!DllCall("UnhookWindowsHookEx", "Ptr", this.MouseHook, "UInt")) {
				MsgBox(Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16) . " (" . DllCall("GetLastError", "UInt") . ")")
			}
		}

		if (!disable && this.IsVisible) {
			this.IsVisible := 0

			WinHide, % Format("ahk_id{}", this.Handle)

			WinGet, hWnd, ID, A
			if (!WinExist(Format("ahk_id{}", hWnd))) {
				Send, !{Escape}
			}
		}
	}

	Show(enable := 0) {
		if (enable || !this.IsVisible) {
			if (!this.KeyboardHook := DllCall("SetWindowsHookEx", "Int", 13, "Ptr", RegisterCallback("__WindowsProc", "Fast"), "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr"), "UInt", 0, "Ptr")) {
				MsgBox(Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16) . " (" . DllCall("GetLastError", "UInt") . ")")
			}

			if (!this.MouseHook := DllCall("SetWindowsHookEx", "Int", 14, "Ptr", RegisterCallback("__WindowsProc", "Fast"), "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr"), "UInt", 0, "Ptr")) {
				MsgBox(Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16) . " (" . DllCall("GetLastError", "UInt") . ")")
			}
		}

		if (!enable && !this.IsVisible) {
			this.IsVisible := 1

			WinShow, % Format("ahk_id{}", this.Handle)
			WinSet, AlwaysOnTop, On, % Format("ahk_id{}", this.Handle)

			WinActivate, % Format("ahk_id{}", this.Handle)
			WinWaitActive, A
		}
	}

	;* Check IP address from CMD: https://www.windows-commandline.com/find-ip-address/.
	;* Get SID of user: https://www.windows-commandline.com/get-sid-of-user/.
	Execute(commnad) {
		Static shell := ComObjCreate("WScript.Shell")

		if (error := (exec := shell.Exec(commnad)).StdErr.ReadAll()) {
;			throw (Exception("NotImplementedError", -1, error))
		}

		return (exec.StdOut.ReadAll())
	}

	Read(numberOfCharsToRead := "") {
		this.Show()

		if (numberOfCharsToRead == "") {
			numberOfCharsToRead := this.GetSize().Width
		}

		buffer := new Structure(numberOfCharsToRead*20)

		this.Hide(1)

		if (!DllCall("ReadConsole", "Ptr", this.Input, "Ptr", buffer.Pointer, "UInt", numberOfCharsToRead, "UInt*", numberOfCharsRead, "Ptr", CreateConsoleReadConsoleControl(0, (1 << 0x0A) | (1 << 0x1B)).Pointer, "UInt")) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		this.Show(1)

		return (SubStr(buffer.StrGet(), 1, numberOfCharsRead - 2))  ;* Account for the newline and carriage return characters.
	}

	Write(text := "Red hot cock", newLine := 1) {
		this.Show()

		if (newLine) {
			text .= "`n"
		}

		if (!DllCall("WriteConsole", "Ptr", this.Output, "Str", text, "UInt", StrLen(text), "UInt*", written, "Ptr", 0, "UInt")) {
			throw (Exception("NotImplementedError", -1, Math.ToBase(DllCall("GetLastError", "UInt"), 10, 16)))
		}

		return (written - (newLine != 0))  ;* Account for the newline character.
	}
}