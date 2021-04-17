;============== Function ======================================================;
;========================================================  AHK  ================;

;* KeyGet(keyName)
;* Description:
	;* Strip a key of modifiers.
KeyGet(keyName) {
	return (RegExReplace(keyName, "[~*$+^! &]|AppsKey"))
}

;* KeyWait(keyName, (options))
;* Description:
	;* Waits for any number of keys or mouse/joystick buttons to be released or pressed down.
;* Parameter:
	;* keyName:
		;* A single key or an array of multiple keys automatically stripped of modifiers, any of which failing the condition (as set with a "D" in `options`) will cause this function to terminate.
	;* options:
		;* Same as the options in the docs for the `KeyWait` command.
KeyWait(keyName, options := "") {
	Static funcObj := Func("__KeyWait")

	keys := [].Concat(keyName), state := !options.Includes("D")
		, time := RegExReplace(options, "iS)[^t]*t?([\d\.]*).*", "$1")

	keys.ForEach(Func("KeyGet"))

	QueryPerformanceCounter(0)

	while (keys.Some(funcObj) == state) {
		if (time && QueryPerformanceCounter(1) >= time) {
			return (ErrorLevel := 1)
		}

		Sleep, -1  ;* Need this here to register a key up event or else potentially create a second thread if there is a return immediately after this function in the calling thread.
	}

	return (ErrorLevel := 0)
}

__KeyWait(keyName) {
	return (GetKeyState(keyName, "P"))
}

;* MouseGet((subCommand), (relativeTo), (flag))
MouseGet(subCommand := "", relativeTo := "", flag := 0) {
	if (relativeTo) {
		CoordMode, Mouse, % relativeTo  ;~ No error handling, no restore.
	}

	if (subCommand != "") {
		switch (subCommand) {
			case "Control":
				MouseGetPos, , , , out, % flag
			case "Pos":
				MouseGetPos, x, y, , , % flag

				out := {"x": x
					, "y": y}
			case "Window":
				MouseGetPos, , , out, , % flag
			default:
				throw, (Exception("Invalid Parameter", -1, Format("""{}"" is invalid.", subCommand)))
		}

		return (out)
	}

	MouseGetPos, x, y, window, control, % flag
	return ({"Pos": {"x": x
			, "y": y}
		, "Control": control
		, "Window": window})
}

;* MsgBox((message), (options), (title), (timeOut))
MsgBox(message := "", options := 0, title := "Beep Boop", timeOut := 0) {
	MsgBox, % options, % title, % (message == "") ? ("""""") : ((message.Base.HasKey("Print")) ? (message.Print()) : (message)), % timeOut
}

;* PostMessage(msg, (wParam), (lParam), (winTitle), (excludeTitle), (control), (detectHiddenWindows))
PostMessage(msg, wParam := 0, lParam := 0, winTitle := "", excludeTitle := "", control := "", detectHiddenWindows := "") {
	if (detectHiddenWindows != "" && detectHiddenWindows != (detect := A_DetectHiddenWindows)) {
		DetectHiddenWindows, % detectHiddenWindows  ;~ No error handling.
	}

	PostMessage, msg, wParam, lParam, % control, % winTitle, , % excludeTitle

	if (detect) {
		DetectHiddenWindows, % detect
	}

	return (ErrorLevel)  ;* ErrorLevel is set to 1 if there was a problem such as the target window or control not existing. Otherwise, it is set to 0.
}

;* RunActivate(winTitle, target, (options), (timeOut), ([Rect] position))
;* Parameter:
	;* rect:
		;* *: An array containg x, y, width and height.
RunActivate(winTitle, target, options := "", timeOut := 5000, rect := "") {
	if (!WinExist(winTitle)) {
		Run, % target, , % options  ;~ Native error handling.
		WinWait, % winTitle, , timeOut/1000
		if (ErrorLevel) {
			return (ErrorLevel)  ;* ErrorLevel is set to 1 if `WinWait` timed out.
		}

		if (rect) {
			WinMove, % winTitle, , rect[0], rect[1], rect[2], rect[3]
		}
	}

	WinActivate
	WinWaitActive, A  ;* Set "Last Found" window.

	return (WinExist())
}

;* SendMessage(msg, (wParam), (lParam), (winTitle), (excludeTitle), (control), (timeOut), (detectHiddenWindows))
SendMessage(msg, wParam := 0, lParam := 0, winTitle := "", excludeTitle := "", control := "", timeOut := 5000, detectHiddenWindows := "") {
	if (detectHiddenWindows != "" && detectHiddenWindows != (detect := A_DetectHiddenWindows)) {
		DetectHiddenWindows, % detectHiddenWindows  ;~ No error handling.
	}

	SendMessage, msg, wParam, lParam, % control, % winTitle, , % excludeTitle, , timeOut

	if (detect) {
		DetectHiddenWindows, % detect
	}

	return (ErrorLevel)  ;* ErrorLevel is set to "FAIL" if there was a problem or the command timed out. Otherwise, it is set to the numeric result of the message, which might sometimes be a "reply" depending on the nature of the message and it's target window.
}

;* SetTimer(label, (period), (priority))
SetTimer(label, period := "", priority := 0) {
	try {
		SetTimer, % label, % period, % priority  ;* Parameters are evaluated before calling functions which means you can pass `FuncObj.Bind("Function")` directly to `SetTimer()`.
	}
	catch {
		return (0)
	}
}

;* Sleep(milliseconds)
Sleep(milliseconds) {
    Sleep, milliseconds
}

;* ToolTip((message), ([Array] point), (which), (relativeTo))
ToolTip(message := "", point := "", which := 1, relativeTo := "") {
	if (relativeTo) {
		CoordMode, ToolTip, % relativeTo  ;~ No error handling.
	}

	ToolTip, % (message.Base.HasKey("Print")) ? (message.Print()) : (message), point[0], point[1], Math.Clamp(which, 1, 20)
}

;* WinGet((subCommand), (winTitle), (winText), (excludeTitle), (excludeText), (detectHiddenWindows))
WinGet(subCommand := "", winTitle := "A", winText := "", excludeTitle := "", excludeText := "", detectHiddenWindows := "") {
	if (detectHiddenWindows != "" && detectHiddenWindows != (detect := A_DetectHiddenWindows)) {
		DetectHiddenWindows, % detectHiddenWindows  ;~ No error handling.
	}

	if (winTitle == "A" || WinExist(winTitle, winText, excludeTitle, excludeText)) {
		if (subCommand != "") {
			switch (subCommand) {
				case "Class":
					WinGetClass, out, % winTitle, % winText, % excludeTitle, % excludeText
				case "Extension":
					WinGet, name, ProcessName, % winTitle, % winText, % excludeTitle, % excludeText

					out := RegExReplace(name, "i).*\.([a-z]+).*", "$1")
				case "List":
					WinGet, handles, List, % winTitle, % winText, % excludeTitle, % excludeText
					out := []

					loop, % handles {
						out.Push(handles%A_Index%)
					}
				case "Pos":
					WinGetPos, x, y, width, height, % winTitle, % winText, % excludeTitle, % excludeText

					out := {"x": x, "y": y, "Width": width, "Height": height}
				case "Text":
					WinGetText, out, % winTitle, % winText, % excludeTitle, % excludeText
				case "Title":
					WinGetTitle, out, % winTitle, % winText, % excludeTitle, % excludeText
				case "Transparent":
					WinGet, alpha, Transparent, % winTitle, % winText, % excludeTitle, % excludeText

					out := (alpha != "") ? (alpha) : (255)
				case "Visible":
					WinGet, handle, ID, % winTitle, % winText, % excludeTitle, % excludeText

					out := DllCall("IsWindowVisible", "UInt", handle)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-iswindowvisible
				default:
					WinGet, out, % subCommand, % winTitle, % winText, % excludeTitle, % excludeText  ;~ Native error handling.
			}
		}
		else {
			out := {}

			for i, v in ["Class", "ControlList", "ControlListHwnd", "Count", "ExStyle", "Extension", "ID", "IDLast", "List", "MinMax", "PID", "Pos", "ProcessName", "ProcessPath", "Style", "Text", "Title", "TransColor", "Transparent", "Visible"] {
				out[v] := WinGet(v, winTitle, winText, excludeTitle, excludeText)  ;* No need to pass `detectHiddenWindows` as that setting is persistent for any given thread.
			}
		}

		if (detect) {
			DetectHiddenWindows, % detect
		}

		return (out)
	}

	throw, (Exception("Invalid title.", -1, Format("""{}"" is invalid or doesn't exist.", winTitle)))
}

;=====================================================  Clipboard  =============;

;* CloseClipboard()
CloseClipboard() {
    if (!DllCall("user32\CloseClipboard")) {  ;: https://github.com/jNizM/AHK_DllCall_WinAPI/tree/master/src/Clipboard%20Functions
        return (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    return (ErrorLevel := 0)
}

;* EmptyClipboard()
EmptyClipboard() {
    if (!DllCall("user32\EmptyClipboard")) {  ;: https://msdn.microsoft.com/en-us/library/ms649037.aspx
        return (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    return (ErrorLevel := 0)
}

;* OpenClipboard((newOwner))
OpenClipboard(newOwner := 0) {
    if (!DllCall("user32\OpenClipboard", "Ptr", newOwner)) {  ;: https://msdn.microsoft.com/en-us/library/ms649048.aspx
        return (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    return (ErrorLevel := 0)
}

;====================================================== Keyboard ==============;

;* BlockInput((mode))
;* Note:
	;* Note that only the thread that blocked input can successfully unblock input.
BlockInput(mode := 0) {
    if (!DllCall("user32\BlockInput", "UInt", mode)) {  ;: https://msdn.microsoft.com/en-us/library/ms646290.aspx
        return (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    return (ErrorLevel := 0)
}

DoubleTap(wait := 0, delay := 300) {
	if (!wait) {
		return ((A_ThisHotkey == A_PriorHotkey) && (A_TimeSincePriorHotkey <= 300))
	}

    KeyWait, % A_ThisHotkey
    KeyWait, % A_ThisHotkey, % Format("DT{}", delay/1000)

	return (!ErrorLevel)
}

;===================================================  Date and Time  ===========;

;* QueryPerformanceCounter((mode))
;* Description:
	;* Returns accurately how many seconds have passed between `QueryPerformanceCounter(0)` and `QueryPerformanceCounter(1)`.
QueryPerformanceCounter(mode := 0) {
	Static Frequency,  Previous := !DllCall("QueryPerformanceFrequency", "Int64P", Frequency)  ;: https://msdn.microsoft.com/en-us/library/ms644905.aspx

	return (!DllCall("QueryPerformanceCounter", "Int64P", current) + ((mode) ? (current - Previous) : (Previous := current))/Frequency)  ;: https://msdn.microsoft.com/en-us/library/ms644904.aspx
}

__QueryPerformanceCounter(fps := 20) {
	Static Frequency, Previous := !DllCall("QueryPerformanceFrequency", "Int64P", Frequency)

	target := 1000/fps

	return (!DllCall("QueryPerformanceCounter", "Int64P", current) + ((Previous) ? (((delta := (current - Previous)*1000/Frequency) >= target) ? (!(Previous := current - Mod(delta, target)) + 1) : (0)) : (!(Previous := current) - 1)))
}

Class Date {

	;* Date.IsLeapYear(year)
	IsLeapYear(year) {
		return (!Mod(year, 4) && (!Mod(year, 400) || Mod(year, 100)))
	}

	;* Date.ToJulian(date [yyyyMMddHHmmss])
	;* Description:
		;* Convert a Gregorian date to a Julian date (https://en.wikipedia.org/wiki/Julian_day).
	;* Credit:
		;* SKAN  ;: https://autohotkey.com/board/topic/19644-julian-date-converter-for-google-daterange-search/#entry129225.
	ToJulian(date) {
		FormatTime, date, % date, yyyyMMddHHmmss

		y := date[0, 4] + 0, m := date[4, 6] + 0
		if (m <= 2) {
			m += 12, y -= 1
		}

		return Round(2 - ~~(y/100) + ~~(~~(y/100)/4) + ~~(365.25*(y + 4716)) + ~~(30.6001*(m + 1)) + (date[6, 8] + 0) - 1524.5 + ((date[8, 10] + 0) + ((date[10, 12] + 0)/60.0) + ((date[12, 14] + 0)/3600.0))/24.0)
	}
}

Clock() {
    return (DllCall("msvcrt\clock"))
}

;==================================================== Machine Code ============;

;* Bentschi's version.
MCode(machineCode) {
	Static e := {1: 4, 2: 1}, c := ((A_PtrSize == 8) ? ("x64") : ("x86"))

	if (!RegExMatch(machineCode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m)) {
		Return
	}

	DllCall("Crypt32\CryptStringToBinaryW", "Str", m3, "UInt", 0, "UInt", e[m1], "Ptr", 0, "UIntP", s, "Ptr", 0, "Ptr", 0)  ;? e[m1] = 4 (Hex) || 1 (Base64)

	p := DllCall("Kernel32\GlobalAlloc", "UInt", 0, "Ptr", s, "Ptr")
    if (A_PtrSize == 8) {
        DllCall("Kernel32\VirtualProtect", "Ptr", p, "Ptr", s, "UInt", 0x40, "UIntP", 0)
	}

	if (DllCall("Crypt32\CryptStringToBinaryW", "str", m3, "UInt", 0, "UInt", e[m1], "Ptr", p, "UIntP", s, "Ptr", 0, "Ptr", 0)) {
		return (p)
	}

	DllCall("GlobalFree", "Ptr", p)
}

;=======================================================  Mouse  ===============;

;* ClipCursor((confine), ([Array] rect))
;* Description:
	;* Confines the cursor to a rectangular area on the screen. If a subsequent cursor position (set by the SetCursorPos function or the mouse) lies outside the rectangle, the system automatically adjusts the position to keep the cursor inside the rectangular area.
;* Parameter:
	;* confine:
		;* 1: The cursor is confined to the rect defined in `rect` or the window that is currently active if no position object is passed.
		;* 0: The cursor is free to move anywhere on the screen.
	;* rect:
		;* *: An array containg x, y, width and height in that order.
ClipCursor(confine := 0, rect := "") {
	Static __Rect := VarSetCapacity(__Rect, 16, 0)

	if (!confine) {
		return (DllCall("user32\ClipCursor"))  ;: https://msdn.microsoft.com/en-us/library/ms648383.aspx
	}

	if (rect) {
		NumPut(rect.x, __Rect, 0, "Int"), NumPut(rect.y, __Rect, 4, "Int"), NumPut(rect.x + rect.Width, __Rect, 8, "Int"), NumPut(rect.y + rect.Height, __Rect, 12, "Int")  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect
	}
	else {
		DllCall("GetWindowRect", "UPtr", WinExist(), "UPtr", &__Rect)
	}

	if (!DllCall("user32\ClipCursor", "Ptr", &__Rect))
		return (ErrorLevel := DllCall("kernel32\GetLastError"))

	return (ErrorLevel := 0)
}

;* GetDoubleClickTime()
GetDoubleClickTime() {
    return (ErrorLevel := DllCall("user32\GetDoubleClickTime"))  ;: https://msdn.microsoft.com/en-us/library/ms646258.aspx
}

;* GetCapture()
GetCapture() {
    return (ErrorLevel := DllCall("user32\GetCapture"))  ;: https://msdn.microsoft.com/en-us/library/ms646262.aspx
}

;* GetCapture([Point2] stop, (speed))
MouseMove(stop, speed := 0.5) {
	start := MouseGet("Pos")
		, distance := Sqrt((stop.x - start.x)**2 + (stop.y - start.y)**2), difference := {x: (stop.x - start.x)/distance, y: (stop.y - start.y)/distance}

	loop, % distance/speed {
		ratio := A_Index*speed

		MouseMove, start.x + difference.x*ratio, start.y + difference.y*ratio
	}
}

MouseWheel(delta := 120) {
	CoordMode, Mouse, Screen

	MouseGetPos, x, y
	modifiers := 0x8*GetKeyState("Ctrl") | 0x1*GetKeyState("LButton") | 0x10*GetKeyState("MButton") | 0x2*GetKeyState("RButton") | 0x4*GetKeyState("Shift") | 0x20*GetKeyState("XButton1") | 0x40*GetKeyState("XButton2")

	PostMessage, 0x20A, delta << 16 | modifiers, y << 16 | x , , A  ;: http://msdn.microsoft.com/en-us/library/windows/desktop/ms645617(v=vs.85).aspx
}

;* ReleaseCapture()
ReleaseCapture() {
    if (!DllCall("user32\ReleaseCapture")) {  ;: https://msdn.microsoft.com/en-us/library/ms646261.aspx
        return (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    return (ErrorLevel := 0)
}

;* SetDoubleClickTime((interval))
SetDoubleClickTime(interval := 500) {
    if (!DllCall("user32\SetDoubleClickTime", "UInt", interval)) {  ;: https://msdn.microsoft.com/en-us/library/ms646263.aspx
        return (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    return (ErrorLevel := 0)
}

;* SwapMouseButton((mode))
SwapMouseButton(mode := 0) {
    DllCall("user32\SwapMouseButton", "UInt", mode)  ;: https://msdn.microsoft.com/en-us/library/ms646264.aspx
}

;======================================================== Type ================;

;* Type(variable)
Type(variable) {
	Static RegExMatchObject := NumGet(&(m, RegExMatch("", "O)", m))), BoundFuncObject := NumGet(&(f := Func("Func").Bind())), FileObject := NumGet(&(f := FileOpen("*", "w"))), EnumeratorObject := NumGet(&(e := ObjNewEnum({}))), hHeap := DllCall("GetProcessHeap", "Ptr")

    if (IsObject(variable)) {
        return ((ObjGetCapacity(variable) != "") ? (RegExReplace(variable.__Class, "S)(.*?\.|_*)(?!.*?\..*?)")) : ((IsFunc(variable)) ? ("FuncObject") : ((ComObjType(variable) != "") ? ("ComObject") : ((NumGet(&variable) == BoundFuncObject) ? ("BoundFuncObject ") : ((NumGet(&variable) == RegExMatchObject) ? ("RegExMatchObject") : ((NumGet(&variable) == FileObject) ? ("FileObject") : ((NumGet(&variable) == EnumeratorObject) ? ("EnumeratorObject") : ("Property"))))))))
	}
	else if (Math.IsNumeric(variable)) {
		return ((variable == Round(variable)) ? ("Integer") : ("Float"))
	}
	else {
		return ((ObjGetCapacity([variable], 0) > 0) ? ("String") : (""))
	}
}

;====================================================== Variable ==============;

;* DownloadContent(url)
DownloadContent(url) {
	Static ComObj := ComObjCreate("MSXML2.XMLHTTP")

	ComObj.Open("Get", url, 0)
	ComObj.Send()

	return (ComObj.ResponseText)
}

;* VarExist([ByRef] Variable)
;* Description:
	;* Indicates whether a variable exists or not.
;* Return:
	;* 0: The variable does not exist.
	;* 1: The variable does exist and contains data.
	;* 2: The variable does exist and is empty.
;* Credit:
	;* SKAN  ;: https://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/page-3?&#entry78387.
VarExist(ByRef variable) {
	return ((&variable == &v) ? (0) : ((variable == "") ? (2) : (1)))
}

;* Swap([ByRef] Variable1, [ByRef] Variable2)
Swap(ByRef Variable1, ByRef Variable2) {
	temp := Variable1
		, Variable1 := Variable2, Variable2 := temp
}

;======================================================= Window ===============;

Desktop() {
	WinGet, style, Style, A

	if (Debug && (!(style & 0x02000000) || !(style & 0x80000000)) && (style & 0x00020000 || style & 0x00010000)) {
		MsgBox(((!(style & 0x02000000)) ? ("0x02000000 (WS_CLIPCHILDREN)") : ("0x80000000 (WS_POPUP)")) . " && " . ((style & 0x00020000) ? ("0x00020000 (WS_MINIMIZEBOX || WS_GROUP)") : ("0x00010000 (WS_MAXIMIZEBOX || WS_TABSTOP)")))
	}

	return (((style & 0x02000000) || (style & 0x80000000)) && !(style & 0x00020000 || style & 0x00010000))
	;! return ((style & 0x00C00000) ? (style & 0x80000000) : (!(style & 0x00020000 || style & 0x00010000)))

	MsgBox(!(style & 0x00800000) . " (WS_BORDER)`n"
		. !(style & 0x00C00000) . " (WS_CAPTION)`n"
		. !(style & 0x40000000) . " (WS_CHILD || WS_CHILDWINDOW)`n"
;		. !(style & 0x02000000) . " (WS_CLIPCHILDREN)`n"  ;! Desktop
;		. !(style & 0x04000000) . " (WS_CLIPSIBLINGS)`n"  ;! Desktop
		. !(style & 0x08000000) . " (WS_DISABLED)`n"
		. !(style & 0x00400000) . " (WS_DLGFRAME)`n"  ;*** Use WS_DLGFRAME as a potential alternative to WS_CAPTION.
		. !(style & 0x00020000) . " (WS_MINIMIZEBOX || WS_GROUP)`n"
		. !(style & 0x00100000) . " (WS_HSCROLL)`n"
		. !(style & 0x20000000) . " (WS_ICONIC || WS_MINIMIZE)`n"
		. !(style & 0x01000000) . " (WS_MAXIMIZE)`n"
		. !(style & 0x00010000) . " (WS_MAXIMIZEBOX || WS_TABSTOP)`n"
		. !(style & 0x00000000) . " (WS_OVERLAPPED || WS_TILED)`n"
;		. !(style & 0x80000000) . " (WS_POPUP)`n"  ;! Desktop
		. !(style & 0x00040000) . " (WS_SIZEBOX || WS_THICKFRAME)`n"
		. !(style & 0x00080000) . " (WS_SYSMENU)`n"
;		. !(style & 0x10000000) . " (WS_VISIBLE)`n"  ;! Desktop
		. !(style & 0x00200000) . " (WS_VSCROLL)`n`n")
}

;* Fade(mode, (alpha), (time), (targetWindow))
;* Description:
	;* Gradually fade the target window to a target alpha over a period of time.
FadeWindow(mode, alpha := "", time := 5000, targetWindow := "A") {
	a := t := ((t := WinGet("Transparent", (w := (targetWindow == "A") ? ("ahk_id" . WinExist()) : (targetWindow)))) == "") ? (255*(mode == "In")) : (t), s := A_TickCount  ;* Safety check for `WinGet("Transparent")` returning `""` because I'm unsure how to test for the fourth exception mentioned in the docs.

	switch (mode) {  ;~ No error handling.
		case "In":
			v := (z := Math.Clamp(alpha, 0, 255)) - t

			while (a < z) {
				WinSet, Transparent, % a := ((A_TickCount - s)/time)*v + t, % w
			}
		case "Out":
			v := t - (z := Math.Clamp(alpha, 0, 255))

			while (a > z) {
				WinSet, Transparent, % a := (1 - ((A_TickCount - s)/time))*v + z, % w
			}
	}
}

GetActiveExplorerPath() {
	if (hWnd := WinActive("ahk_class CabinetWClass")) {
		for window in ComObjCreate("Shell.Application").Windows {
			if (window.hWnd == hWnd) {
				return (window.Document.Folder.Self.Path)
			}
		}
	}
}

;* ScriptCommand(scriptName, message)
ScriptCommand(scriptName, message) {
    Static commands := {"Open": 65300, "Help": 65301, "Spy": 65302, "Reload": 65303, "Edit": 65304, "Suspend": 65305, "Pause": 65306, "Exit": 65307}

	PostMessage(0x111, commands[message], , scriptName . " - AutoHotkey", , , 1)
}

;* ShowDesktop()
ShowDesktop() {
	Static comObj := ComObjCreate("shell.application")

	comObj.ToggleDesktop()
}

;* ShowStartMenu()
ShowStartMenu() {
	DllCall("User32\PostMessage", "Ptr", WinExist(), "UInt", 0x112, "Ptr", 0xF130, "Ptr", 0)
}

;=======================================================  Other  ===============;

InternetConnection() {
	return (ErrorLevel := DllCall("Wininet\InternetGetConnectedState", "Str", "", "Int", 0))  ;: https://docs.microsoft.com/en-us/windows/win32/api/wininet/nf-wininet-internetgetconnectedstate
}

;* Speak(message)
;* Note:
	;* This is not ideal for active use as it will halt the thread that makes the request, better to call it from a second script or compile a dedicated executable.
Speak(message) {
	Static comObj := ComObjCreate("SAPI.SpVoice")

	comObj.Speak(message)
}

;===============  Class  =======================================================;

Class Spotify {
	Static Handle := 0

    Pause() {
		PostMessage(0x319, , 0xD0000, this.GetWindow(1), , , 1)  ;? 0x319 = WM_APPCOMMAND
    }

    PlayPause() {
		PostMessage(0x319, , 0xE0000, this.GetWindow(1), , , 1)
    }

    Play() {
		Local

		detect := A_DetectHiddenWindows
		DetectHiddenWindows, On

		window := this.GetWindow(1)

		PostMessage, 0x319, , 0xD0000, , % window
		PostMessage, 0x319, , 0xE0000, , % window

		DetectHiddenWindows, % detect
    }

    Prev() {
		PostMessage(0x319, , 0xC0000, this.GetWindow(1), , , 1)
    }

    Next() {
		PostMessage(0x319, , 0xB0000, this.GetWindow(1), , , 1)
    }

    GetWindow(prefix := true) {
		Local

		detect := A_DetectHiddenWindows
		DetectHiddenWindows, On

		if (WinExist("ahk_exe Spotify.exe")) {
			if (this.Handle && WinGet("Class", "ahk_ID" . this.Handle) == "Chrome_WidgetWin_0" && WinGet("Title", "ahk_ID" . this.Handle) ~= "^(Spotify.*|.* - .*)$") {
				window := (prefix) ? ("ahk_ID" . this.Handle) : (this.Handle)
			}
			else {
				for i, hWnd in WinGet("List", "ahk_exe Spotify.exe") {
					if (WinGet("Class", "ahk_ID" . hWnd) == "Chrome_WidgetWin_0" && WinGet("Title", "ahk_ID" . hWnd) ~= "^(Spotify.*|.* - .*)$") {
						this.Handle := hWnd
							, window := (prefix) ? ("ahk_ID" . hWnd) : (hWnd)

						break
					}
				}
			}
		}

		DetectHiddenWindows, % detect  ;* Avoid leaving `DetectHiddenWindows` on for the calling thread.

        return (window)
    }
}

Class Timer {
	Static Instances := []

	__New(callback, interval := 0, priority := 0) {
		Local

		instance := {"Callback": callback, "Interval": interval, "Priority": priority
			, "State": -1

			, "Base": this.__Timer}

		pointer := &instance
			, this.Instances[pointer] := instance, ObjRelease(pointer)  ;* Decrease this object's reference count to allow `__Delete()` to be called while still keeping a copy in `Timer.Instances`.

		return (instance)
	}

	StartAll(interval := "") {
		Local

		for pointer, object in this.Instances {
			object.Start(interval)
		}
	}

	StopAll() {
		Local

		for pointer, object in this.Instances {
			object.Stop()
		}
	}

	Class __Timer {

		__Delete() {
			if (this.State != -1) {
				SetTimer(this.Callback, "Delete")
			}

			if (Debug) {
				MsgBox("__Timer.__Delete(): " Timer.Instances.Count)
			}

			pointer := &this
				, ObjAddRef(pointer), Timer.Instances.Delete(pointer)  ;* Increase this object's reference count before deleting the copy stored in `Timer.Instances` to avoid crashing the calling script.
		}

		Start(interval := "") {
			Local

			if (this.State != 1) {
				this.State := 1

				if (interval != "") {
					this.Interval := interval
				}

				SetTimer(this.Callback, this.Interval, this.Priority)
			}
		}

		Stop() {
			Local

			if (this.State == 1) {
				this.State := 0

				SetTimer(this.Callback, "Off")
			}
		}
	}
}
