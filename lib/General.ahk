;=====           Function           =========================;
;===============              AHK             ===============;

;* KeyGet(KeyName)
;* Description:
	;* Strip a key of modifiers.
KeyGet(vKeyName := "") {
	Return, (RegExReplace(vKeyName, "[~*$+^#! &]|AppsKey"))
}

;* KeyWait(KeyName, Options)
;* Description:
	;* Waits for a key or mouse/joystick button to be released or pressed down.
;* Parameter:
	;* vKeyName:
		;* A single key or an array of multiple keys automatically stripped of modifiers, any of which fulling the condition (as set with a "D" in `vOptions`) will cause this function to terminate.
	;* vOptions:
		;* Same as docs for `KeyWait`.
KeyWait(vKeyName, vOptions := "") {
	Static __FuncObj := Func("__KeyWait")
	k := [].Concat(vKeyName), s := !vOptions.Includes("D"), t := RegExReplace(vOptions, "iS)[^t]*t?([\d\.]*).*", "$1") + !QueryPerformanceCounter(0)

	k.ForEach(Func("KeyGet"))

	While (k.Some(__FuncObj) == s) {
		If (t && QueryPerformanceCounter(1) >= t) {  ;* `QueryPerformanceCounter()` is only called if `t` evaluates as true.
			Return, (ErrorLevel := 1)
		}

		Sleep, -1  ;* Need this here to register a key up event or else potentially create a second thread if there is a return immediately after this function in the calling thread.
	}

	Return, (ErrorLevel := 0)
}
__KeyWait(vKeyName) {
	Return, (GetKeyState(vKeyName, "P"))
}

;* MouseGet(SubCommand, RelativeTo, Flag)
MouseGet(vSubCommand := "", vRelativeTo := "", vFlag := 0) {
	If (vRelativeTo) {
		CoordMode, Mouse, % vRelativeTo  ;- No error handling, no restore.
	}

	If (vSubCommand != "") {
		Switch (vSubCommand) {
			Case "Control":
				MouseGetPos, , , , r, % vFlag
			Case "Pos":
				MouseGetPos, x, y, , , % vFlag

				r := {"x": x
					, "y": y}
			Case "Window":
				MouseGetPos, , , r, , % vFlag
			Default:
				Throw, (Exception("Invalid subcommand.", -1, Format("""{}"" is invalid.", vSubCommand)))
		}
		Return, (r)
	}

	MouseGetPos, x, y, w, c, % vFlag
	Return, ({"Pos": {"x": x
			, "y": y}
		, "Control": c
		, "Window": w})
}

;* MsgBox(Text, Options, Title, Timeout)
MsgBox(vText := "", vOptions := 0, vTitle := "Beep boop.", vTimeout := 0) {
	MsgBox, % vOptions, % vTitle, % (vText == "") ? ("""""") : (vText), % vTimeout
}

;* PostMessage(Msg, wParam, lParam, WinTitle, ExcludeTitle, Control, DetectHiddenWindows)
PostMessage(vMsg, vParameter1 := 0, vParameter2 := 0, vWinTitle := "", vExcludeTitle := "", vControl := "", vDetectHiddenWindows := "") {
	If (vDetectHiddenWindows != "" && vDetectHiddenWindows != (z := A_DetectHiddenWindows)) {
		DetectHiddenWindows, % vDetectHiddenWindows  ;- No error handling.
	}

	PostMessage, vMsg, vParameter1, vParameter2, % vControl, % vWinTitle, , % vExcludeTitle

	If (z) {
		DetectHiddenWindows, % z
	}
	Return, (ErrorLevel)  ;* ErrorLevel is set to 1 if there was a problem such as the target window or control not existing. Otherwise, it is set to 0.
}

;* RunActivate(WinTitle, Target, Options, Timeout, {"x": x, "y": y, "Width": Width, "Height": Height})
;* Parameter:
	;* oPos:
		;* *: An object containg x, y, width and height.
RunActivate(vWinTitle, vTarget, vOptions := "", vTimeout := "", oPos := "") {
	If (!WinExist(vWinTitle)) {
		Run, % vTarget, , % vOptions  ;- Native error handling.
		WinWait, % vWinTitle, , vTimeout
		If (ErrorLevel) {
			Return, (ErrorLevel)  ;* ErrorLevel is set to 1 if `WinWait` timed out.
		}

		If (oPos) {
			WinMove, % vWinTitle, , oPos.x, oPos.y, oPos.Width, oPos.Height
		}
	}
	WinActivate
	WinWaitActive, A  ;* Set "Last Found" window.

	Return, (WinExist())
}

;* SendMessage(Msg, wParam, lParam, WinTitle, ExcludeTitle, Control, Timeout, DetectHiddenWindows)
SendMessage(vMsg, vParameter1 := 0, vParameter2 := 0, vWinTitle := "", vExcludeTitle := "", vControl := "", vTimeout := 5000, vDetectHiddenWindows := "") {
	If (vDetectHiddenWindows != "" && vDetectHiddenWindows != (z := A_DetectHiddenWindows)) {
		DetectHiddenWindows, % vDetectHiddenWindows  ;- No error handling.
	}

	SendMessage, vMsg, vParameter1, vParameter2, % vControl, % vWinTitle, , % vExcludeTitle, , vTimeout

	If (z) {
		DetectHiddenWindows, % z
	}
	Return, (ErrorLevel)  ;* ErrorLevel is set to the word FAIL if there was a problem or the command timed out. Otherwise, it is set to the numeric result of the message, which might sometimes be a "reply" depending on the nature of the message and its target window.
}

;* SetTimer(Label, Period, Priority)
SetTimer(vLabel, vPeriod := "", vPriority := 0) {
	SetTimer, % vLabel, % vPeriod, % vPriority  ;* Parameters are evaluated before calling functions which means you can pass `FuncObj.Bind("Parameter")` directly to `SetTimer()`.
}

;* Sleep(Milliseconds)
Sleep(vMilliseconds) {
    Sleep, vMilliseconds
}

;* ToolTip(String, {"x": x, "y": y}, RelativeTo, WhichToolTip)
ToolTip(vString := "", oPos := "", vRelativeTo := "Screen", vWhichToolTip := 1) {
	If (vRelativeTo) {
		CoordMode, ToolTip, % vRelativeTo  ;- No error handling.
	}

	ToolTip, % vString, oPos.x, oPos.y, vWhichToolTip
}

;* WinGet(SubCommand, WinTitle, WinText, ExcludeTitle, ExcludeText, DetectHiddenWindows)
WinGet(vSubCommand := "", vWinTitle := "A", vWinText := "", vExcludeTitle := "", vExcludeText := "", vDetectHiddenWindows := "") {
	If (vDetectHiddenWindows != "" && vDetectHiddenWindows != (z := A_DetectHiddenWindows)) {
		DetectHiddenWindows, % vDetectHiddenWindows  ;- No error handling.
	}

	If (vWinTitle == "A" || WinExist(vWinTitle, vWinText, vExcludeTitle, vExcludeText)) {
		If (vSubCommand != "") {
			Switch (vSubCommand) {
				Case "Class":
					WinGetClass, r, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText
				Case "Extension":
					WinGet, n, ProcessName, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText

					r := RegExReplace(n, "i).*\.([a-z]+).*", "$1")
				Case "List":
					WinGet, h, List, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText
					r := []

					Loop, % h {
						r.Push(h%A_Index%)
					}
				Case "Pos":
					WinGetPos, x, y, w, h, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText

					r := {"x": x
						, "y": y
						, "Width": w
						, "Height": h}
				Case "Text":
					WinGetText, r, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText
				Case "Title":
					WinGetTitle, r, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText
				Case "Transparent":
					WinGet, a, Transparent, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText

					r := (a != "") ? (a) : (255)
				Case "Visible":
					WinGet, h, ID, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText

					r := DllCall("IsWindowVisible", "UInt", h)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-iswindowvisible
				Default:
					WinGet, r, % vSubCommand, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText  ;- Native error handling.
			}
		}
		Else {
			r := {}

			For i, v in ["Class", "ControlList", "ControlListHwnd", "Count", "ExStyle", "Extension", "ID", "IDLast", "List", "MinMax", "PID", "Pos", "ProcessName", "ProcessPath", "Style", "Text", "Title", "TransColor", "Transparent", "Visible"] {
				r[v] := WinGet(v, vWinTitle, vWinText, vExcludeTitle, vExcludeText)  ;* No need to pass `vDetectHiddenWindows` as that setting is not instanced.
			}
		}

		If (z) {
			DetectHiddenWindows, % z
		}
		Return, (r)
	}

	Throw, (Exception("Invalid title.", -1, Format("""{}"" is invalid or doesn't exist.", vWinTitle)))
}

;===============           Clipboard          ===============;

;* CloseClipboard()
CloseClipboard() {
    If (!DllCall("user32\CloseClipboard")) {  ;: https://github.com/jNizM/AHK_DllCall_WinAPI/tree/master/src/Clipboard%20Functions
        Return, (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    Return, (ErrorLevel := 0)
}

;* EmptyClipboard()
EmptyClipboard() {
    If (!DllCall("user32\EmptyClipboard")) {  ;: https://msdn.microsoft.com/en-us/library/ms649037.aspx
        Return, (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    Return, (ErrorLevel := 0)
}

;* OpenClipboard(NewOwner)
OpenClipboard(vNewOwner := 0) {
    If (!DllCall("user32\OpenClipboard", "Ptr", vNewOwner)) {  ;: https://msdn.microsoft.com/en-us/library/ms649048.aspx
        Return, (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    Return, (ErrorLevel := 0)
}

;===============           Keyboard           ===============;

;* BlockInput(Mode)
;* Note:
	;* Note that only the thread that blocked input can successfully unblock input.
BlockInput(vMode := 0) {
    If (!DllCall("user32\BlockInput", "UInt", vMode)) {  ;: https://msdn.microsoft.com/en-us/library/ms646290.aspx
        Return, (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    Return, (ErrorLevel := 0)
}

DoubleTap(){
    Return, ((A_ThisHotkey == A_PriorHotkey) && (A_TimeSincePriorHotkey <= 300))
}

;==============         Date and Time        ===============;

;* QueryPerformanceCounter(Mode)
;* Description:
	;* Returns accurately how many seconds have passed between `QueryPerformanceCounter(0)` and `QueryPerformanceCounter(1)`.
QueryPerformanceCounter(vMode := 0) {
	Static __Frequency,  __Previous := !DllCall("QueryPerformanceFrequency", "Int64P", __Frequency)  ;: https://msdn.microsoft.com/en-us/library/ms644905.aspx

	Return, (!DllCall("QueryPerformanceCounter", "Int64P", c) + ((vMode) ? (c - __Previous) : (__Previous := c))/__Frequency)  ;: https://msdn.microsoft.com/en-us/library/ms644904.aspx
}

Class Date {

	;* Date.IsLeapYear(Year)
	IsLeapYear(vYear) {
		Return, (!Mod(vYear, 4) && (!Mod(vYear, 400) || Mod(vYear, 100)))
	}

	;* Date.ToJulian(YYYYMMDDHHMMSS)
	;* Description:
		;* Convert a Gregorian date to a Julian date (https://en.wikipedia.org/wiki/Julian_day).
	;* Credit:
		;* SKAN: https://autohotkey.com/board/topic/19644-julian-date-converter-for-google-daterange-search/#entry129225.
	ToJulian(vDate) {
		FormatTime, vDate, % vDate, yyyyMMddHHmmss

		y := vDate[0, 4] + 0, m := vDate[4, 6] + 0
		If (m <= 2) {
			m += 12, y -= 1
		}

		Return, Round(2 - ~~(y/100) + ~~(~~(y/100)/4) + ~~(365.25*(y + 4716)) + ~~(30.6001*(m + 1)) + (vDate[6, 8] + 0) - 1524.5 + ((vDate[8, 10] + 0) + ((vDate[10, 12] + 0)/60.0) + ((vDate[12, 14] + 0)/3600.0))/24.0)
	}
}

Clock() {
    Return, (DllCall("msvcrt\clock"))
}

;==============         Machine Code         ===============;

;* Bentschi's version.
MCode(vMachineCode) {
	Static e := {1: 4, 2: 1}, c := ((A_PtrSize == 8) ? ("x64") : ("x86"))

	If (!RegExMatch(vMachineCode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m)) {
		Return
	}

	DllCall("Crypt32\CryptStringToBinaryW", "Str", m3, "UInt", 0, "UInt", e[m1], "Ptr", 0, "UIntP", s, "Ptr", 0, "Ptr", 0)  ;? e[m1] = 4 (Hex) || 1 (Base64)

	p := DllCall("Kernel32\GlobalAlloc", "UInt", 0, "Ptr", s, "Ptr")
    If (A_PtrSize == 8) {
        DllCall("Kernel32\VirtualProtect", "Ptr", p, "Ptr", s, "UInt", 0x40, "UIntP", 0)
	}

	If (DllCall("Crypt32\CryptStringToBinaryW", "str", m3, "UInt", 0, "UInt", e[m1], "Ptr", p, "UIntP", s, "Ptr", 0, "Ptr", 0)) {
		Return, (p)
	}

	DllCall("GlobalFree", "Ptr", p)
}

;==============             Mouse            ===============;

;* ClipCursor(Confine, {"x": x, "y": y, "Width": Width, "Height": Height})
;* Description:
	;* Confines the cursor to a rectangular area on the screen. If a subsequent cursor position (set by the SetCursorPos function or the mouse) lies outside the rectangle, the system automatically adjusts the position to keep the cursor inside the rectangular area.
;* Parameter:
	;* vConfine:
		;* 1: The cursor is confined to the `oPos` or the window that is currently active if no position object is passed.
		;* 0: The cursor is free to move anywhere on the screen.
	;* oPos:
		;* *: An object containg x, y, width and height.
ClipCursor(vConfine := 0, oPos := "") {
	Static __Rect := VarSetCapacity(__Rect, 16, 0)

	If (!vConfine) {
		Return, (DllCall("user32\ClipCursor"))  ;: https://msdn.microsoft.com/en-us/library/ms648383.aspx
	}

	If (Math.IsNumeric(oPos.x) && Math.IsNumeric(oPos.y) && Math.IsNumeric(oPos.Width) && Math.IsNumeric(oPos.Height)) {
		NumPut(oPos.x, __Rect, 0, "Int"), NumPut(oPos.y, __Rect, 4, "Int"), NumPut(oPos.x + oPos.Width, __Rect, 8, "Int"), NumPut(oPos.y + oPos.Height, __Rect, 12, "Int")  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect
	}
	Else {
		DllCall("GetWindowRect", "UPtr", WinExist(), "UPtr", &__Rect)
	}

	If (!DllCall("user32\ClipCursor", "Ptr", &__Rect))
		Return, (ErrorLevel := DllCall("kernel32\GetLastError"))

	Return, (ErrorLevel := 0)
}

;* GetDoubleClickTime()
GetDoubleClickTime() {
    Return, (DllCall("user32\GetDoubleClickTime"))  ;: https://msdn.microsoft.com/en-us/library/ms646258.aspx
}

;* GetCapture()
GetCapture() {
    Return, (DllCall("user32\GetCapture"))  ;: https://msdn.microsoft.com/en-us/library/ms646262.aspx
}

;* ReleaseCapture()
ReleaseCapture() {
    If (!DllCall("user32\ReleaseCapture")) {  ;: https://msdn.microsoft.com/en-us/library/ms646261.aspx
        Return, (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    Return, (ErrorLevel := 0)
}

;* SetDoubleClickTime()
SetDoubleClickTime(vInterval := 500) {
    If (!DllCall("user32\SetDoubleClickTime", "UInt", vInterval)) {  ;: https://msdn.microsoft.com/en-us/library/ms646263.aspx
        Return, (ErrorLevel := DllCall("kernel32\GetLastError"))
	}

    Return, (ErrorLevel := 0)
}

;* SwapMouseButton()
SwapMouseButton(vMode := 0) {
    DllCall("user32\SwapMouseButton", "UInt", vMode)  ;: https://msdn.microsoft.com/en-us/library/ms646264.aspx
}

;==============             Type             ===============;

;* Type(Variable)
Type(vVariable) {
	Static __RegExMatchObject := NumGet(&(m, RegExMatch("", "O)", m))), __BoundFuncObject := NumGet(&(f := Func("Func").Bind())), __FileObject := NumGet(&(f := FileOpen("*", "w"))), __EnumeratorObject := NumGet(&(e := ObjNewEnum({})))

    If (IsObject(vVariable)) {
        Return, ((ObjGetCapacity(vVariable) != "") ? ((vVariable.Base.__Class == "__Array") ? ("Array") : ("Object")) : ((IsFunc(vVariable)) ? ("FuncObject") : ((ComObjType(vVariable) != "") ? ("ComObject") : ((NumGet(&vVariable) == __BoundFuncObject) ? ("BoundFuncObject ") : ((NumGet(&vVariable) == __RegExMatchObject) ? ("RegExMatchObject") : ((NumGet(&vVariable) == __FileObject) ? ("FileObject") : ((NumGet(&vVariable) == __EnumeratorObject) ? ("EnumeratorObject") : ("Property"))))))))
	}
	Else If (Math.IsNumeric(vVariable)) {
		Return, ((vVariable == Round(vVariable)) ? ("Integer") : ("Float"))
	}
	Else {
		Return, ((ObjGetCapacity([vVariable], 0) > 0) ? ("String") : (""))
	}
}

;==============           Variable           ===============;

;* DownloadContent(Url)
DownloadContent(vUrl) {
	Static __ComObj := ComObjCreate("MSXML2.XMLHTTP")

	__ComObj.Open("Get", vUrl, 0)
	__ComObj.Send()

	Return, (__ComObj.ResponseText)
}

;* VarExist(Variable)
;* Description:
	;* Returns a value to indicate whether the variable exists.
;* Return:
	;* 0: The variable does not exist.
	;* 1: The variable does exist and contains data.
	;* 2: The variable does exist and is empty.
;* Credit:
	;* SKAN: https://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/page-3?&#entry78387.
VarExist(ByRef vVariable) {
	Return, ((&vVariable == &v) ? (0) : ((vVariable == "") ? (2) : (1)))
}

;* Swap(Variable1, Variable2)
Swap(ByRef vVariable1, ByRef vVariable2) {
	t := vVariable1, vVariable1 := vVariable2, vVariable2 := t
}

;==============            Window            ===============;

;* Fade(Mode, Alpha, Time, TargetWindow)
;* Description:
	;* Gradually fade a target window to a target alpha over a period of time.
Fade(vMode, vAlpha := "", vTime := 5000, vTargetWindow := "A") {
	a := t := ((t := WinGet("Transparent", (w := (vTargetWindow == "A") ? ("ahk_id" . WinExist()) : (vTargetWindow)))) == "") ? (255*(vMode = "In")) : (t), s := A_TickCount  ;* Safety check for `WinGet("Transparent")` returning `""` because I'm unsure how to test for the fourth exception mentioned in the docs.

	Switch (vMode) {  ;- No error handling.
		Case "In":
			v := (z := Math.Clamp(vAlpha, 0, 255)) - t

			While (a < z) {
				WinSet, Transparent, % a := ((A_TickCount - s)/vTime)*v + t, % w
			}
		Case "Out":
			v := t - (z := Math.Clamp(vAlpha, 0, 255))

			While (a > z) {
				WinSet, Transparent, % a := (1 - ((A_TickCount - s)/vTime))*v + z, % w
			}
	}
}

Desktop() {
	v := WinGet("Style")

	Return, ((v & 0xC00000) ? (v & 0x80000000) : (!(v & 0x00020000 || v & 0x00010000)))  ;? 0xC00000 = WS_CAPTION, 0x80000000 = WS_POPUP, 0x00020000 = WS_MINIMIZEBOX, 0x00010000 = WS_MAXIMIZEBOX
	Return, (["", "NotifyIconOverflowWindow", "Progman", "Shell_TrayWnd", "Windows.UI.Core.CoreWindow", "WorkerW"].Includes(WinGet("Class")))  ;HwndWrapper[ExpressVPN.exe;;4aa35596-23e0-414b-8d79-42598d67db97]

	MsgBox(!(v & 0x00800000) . " (WS_BORDER)`n"
		. !(v & 0x00C00000) . " (WS_CAPTION)`n"
		. !(v & 0x40000000) . " (WS_CHILD || WS_CHILDWINDOW)`n"
;		. !(v & 0x02000000) . " (WS_CLIPCHILDREN)`n"  ;! Desktop
;		. !(v & 0x04000000) . " (WS_CLIPSIBLINGS)`n"  ;! Desktop
		. !(v & 0x08000000) . " (WS_DISABLED)`n"
		. !(v & 0x00400000) . " (WS_DLGFRAME)`n"
		. !(v & 0x00020000) . " (WS_MINIMIZEBOX || WS_GROUP)`n"
		. !(v & 0x00100000) . " (WS_HSCROLL)`n"
		. !(v & 0x20000000) . " (WS_ICONIC || WS_MINIMIZE)`n"
		. !(v & 0x01000000) . " (WS_MAXIMIZE)`n"
		. !(v & 0x00010000) . " (WS_MAXIMIZEBOX || WS_TABSTOP)`n"
		. !(v & 0x00000000) . " (WS_OVERLAPPED || WS_TILED)`n"
;		. !(v & 0x80000000) . " (WS_POPUP)`n"  ;! Desktop
		. !(v & 0x00040000) . " (WS_SIZEBOX || WS_THICKFRAME)`n"
		. !(v & 0x00080000) . " (WS_SYSMENU)`n"
;		. !(v & 0x10000000) . " (WS_VISIBLE)`n"  ;! Desktop
		. !(v & 0x00200000) . " (WS_VSCROLL)`n`n"
		. "Test: " . Desktop())  ;*** Use WS_DLGFRAME as a potential alternative to WS_CAPTION.
}

;* ScriptCommand(ScriptName, Command)
ScriptCommand(vScript, vCommand) {
    Static __Command := {"Open": 65300, "Help": 65301, "Spy": 65302, "Reload": 65303, "Edit": 65304, "Suspend": 65305, "Pause": 65306, "Exit": 65307}

	PostMessage(0x111, __Command[vCommand], , vScript . " - AutoHotkey", , , "On")
}

;==============             Other            ===============;

InternetConnection() {
	Return, (ErrorLevel := DllCall("Wininet\InternetGetConnectedState", "Str", "", "Int", 0))  ;: https://docs.microsoft.com/en-us/windows/win32/api/wininet/nf-wininet-internetgetconnectedstate
}

;* ShowDesktop()
ShowDesktop() {
	Static __ComObj := ComObjCreate("shell.application")

	__ComObj.ToggleDesktop()
}

;* ShowStartMenu()
ShowStartMenu() {
	DllCall("User32\PostMessage", "Ptr", WinExist(), "UInt", 0x112, "Ptr", 0xF130, "Ptr", 0)
}

;* Speak(String)
;* Note:
	;* This is not ideal for active use as it will halt the thread that makes the request, better to call it from a second script or compile a dedicated executable.
Speak(vString) {
	Static __ComObj := ComObjCreate("SAPI.SpVoice")

	__ComObj.Speak(vString)
}