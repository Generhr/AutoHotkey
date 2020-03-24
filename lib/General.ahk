;=====             AHK              =========================;

;*	KeyGet(_KeyName)
;*	Description:
;*		Strip a key of modifiers.
KeyGet(_KeyName) {
	Return, (RegExReplace(_KeyName, "[~*$+^#! &]|AppsKey"))
}

;*	KeyWait(_KeyName[, _Options])
;*	Description:
;*		Waits for a key or mouse/joystick button to be released or pressed down.
;*	Note:
;*		`_KeyName` may be an array of multiple keys, any of which fulling the condition (as set with a "D" in `_Options`) will cause this function to terminate. `_KeyName` is automatically stripped of modifiers.
KeyWait(_KeyName, _Options := "") {
	Static oFuncObj := Func("__KeyWait")
	k := [].Concat(_KeyName), s := !InStr(_Options, "D"), t := RegExReplace(_Options, "iS)[^t]*t?([\d\.]*).*", "$1") + !QueryPerformanceCounter(0)

	k.ForEach(Func("KeyGet"))

	While (k.Some(oFuncObj) == s) {
		If (t && QueryPerformanceCounter(1) >= t)  ;* `QueryPerformanceCounter()` is only called if `t` evaluates as true.
			Return, (ErrorLevel := 1)

		Sleep(0)  ;* Need this here to register a key up event or else potentially create a second thread if there is a return immediately after this function in the calling thread.
	}

	Return, (ErrorLevel := 0)
}
__KeyWait(_KeyName) {
	Return, (GetKeyState(_KeyName, "P"))
}

;*	MouseGet([_SubCommand[, _RelativeTo[, _Flag]]])
MouseGet(_SubCommand := "", _RelativeTo := "", _Flag := 0) {
	If (_RelativeTo)
		CoordMode, Mouse, % _RelativeTo  ;- No error handling, no restore.

	If (_SubCommand != "") {
		Switch (_SubCommand) {
			Case "Control":
				MouseGetPos, , , , r, % _Flag
			Case "Pos":
				MouseGetPos, x, y, , , % _Flag

				r := {"x": x
					, "y": y}
			Case "Window":
				MouseGetPos, , , r, , % _Flag
			Default:
				Throw, (Exception("Invalid subcommand.", -1, Format("""{}"" is invalid.", _SubCommand)))
		}
		Return, (r)
	}

	MouseGetPos, x, y, w, c, % _Flag
	Return, ({"Pos": {"x": x
			, "y": y}
		, "Control": c
		, "Window": w})
}

;*	MsgBox([_Text[, _Options[, _Title[, _Timeout]]]])
MsgBox(_Text := "", _Options := 0, _Title := "Beep boop", _Timeout := 0) {
	MsgBox, % _Options, % _Title, % _Text, % _Timeout
}

;*	PostMessage([_Msg[, _wParam[, _lParam[, _Control[, _WinTitle[, _WinText[, _ExcludeTitle[, _ExcludeText[, _DetectHiddenWindows]]]]]]]]])
PostMessage(_Msg, _wParam := 0, _lParam := 0, _Control := "", _WinTitle := "", _WinText := "", _ExcludeTitle := "", _ExcludeText := "", _DetectHiddenWindows := "") {
	If (_DetectHiddenWindows != "" && _DetectHiddenWindows != (d := A_DetectHiddenWindows))
		DetectHiddenWindows, % _DetectHiddenWindows  ;- No error handling.

	PostMessage, _Msg, _wParam, _lParam, % _Control, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText

	If (d)
		DetectHiddenWindows, % d
	Return, (ErrorLevel)  ;* ErrorLevel is set to 1 if there was a problem such as the target window or control not existing. Otherwise, it is set to 0.
}

;*	RunActivate(_WinTitle, _Target[, _Options[, _Timeout[, _Pos]]])
;*	Parameter:
;*		_Pos:
;*			*: An object containg x, y, width and height.
RunActivate(_WinTitle, _Target, _Options := "", _Timeout := "", _Pos := "") {
	If (!WinExist(_WinTitle)) {
		Run, % _Target, , % _Options  ;- Native error handling.
		WinWait, % _WinTitle, , _Timeout
		If (ErrorLevel)
			Return, (ErrorLevel)  ;* ErrorLevel is set to 1 if `WinWait` timed out.

		If (_Pos)
			WinMove, % _WinTitle, , _Pos.x, _Pos.y, _Pos.Width, _Pos.Height
	}
	WinActivate
	WinWaitActive, A  ;* Set "Last Found" window.

	Return, (WinExist())
}

;*	SendMessage([_Msg[, _wParam[, _lParam[, _Control[, _WinTitle[, _WinText[, _ExcludeTitle[, _ExcludeText[, _Timeout[, _DetectHiddenWindows]]]]]]]]]])
SendMessage(_Msg, _wParam := 0, _lParam := 0, _Control := "", _WinTitle := "", _WinText := "", _ExcludeTitle := "", _ExcludeText := "", _Timeout := 5000, _DetectHiddenWindows := "") {
	If (_DetectHiddenWindows != "" && _DetectHiddenWindows != (d := A_DetectHiddenWindows))
		DetectHiddenWindows, % _DetectHiddenWindows  ;- No error handling.

	SendMessage, _Msg, _wParam, _lParam, % _Control, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText, _Timeout

	If (d)
		DetectHiddenWindows, % d
	Return, (ErrorLevel)  ;* ErrorLevel is set to the word FAIL if there was a problem or the command timed out. Otherwise, it is set to the numeric result of the message, which might sometimes be a "reply" depending on the nature of the message and its target window.
}

;*	SetTimer(_Label[, _Period[, _Priority]])
SetTimer(_Label, _Period := "", _Priority := 0) {
	SetTimer, % _Label, % _Period, % _Priority  ;* Parameters are evaluated before calling functions which means you can pass `FuncObj.Bind("Parameter")` directly to the command.
}

;*	Sleep(_Milliseconds)
;*	Note:
;*		A value of zero causes the thread to relinquish the remainder of its time slice to any other thread that is ready to run. If there are no other threads ready to run, the function returns immediately, and the thread continues execution.
Sleep(_Milliseconds) {
    DllCall("kernel32.dll\Sleep", "UInt", _Milliseconds)  ;? https://msdn.microsoft.com/en-us/library/ms686298.aspx.
}

;*	ToolTip([_Text[, _x[, _y[, _RelativeTo[, _WhichToolTip]]]]])
ToolTip(_Text := "", _x := "", _y := "", _RelativeTo := "", _WhichToolTip := 1) {
	If (_RelativeTo)
		CoordMode, ToolTip, % _RelativeTo  ;- No error handling, no restore.

	ToolTip, % _Text, _x, _y, _WhichToolTip
}

;*	WinGet([_SubCommand[, _WinTitle[, _WinText[, _ExcludeTitle[, _ExcludeText[, _DetectHiddenWindows]]]]]])
WinGet(_SubCommand := "", _WinTitle := "A", _WinText := "", _ExcludeTitle := "", _ExcludeText := "", _DetectHiddenWindows := "") {
	If (_DetectHiddenWindows != "" && _DetectHiddenWindows != (d := A_DetectHiddenWindows))
		DetectHiddenWindows, % _DetectHiddenWindows  ;- No error handling.

	If (_WinTitle == "A" || WinExist(_WinTitle, _WinText, _ExcludeTitle, _ExcludeText)) {
		If (_SubCommand != "") {
			Switch (_SubCommand) {
				Case "Class":
					WinGetClass, r, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
				Case "Extension":
					WinGet, n, ProcessName, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText

					r := RegExReplace(n, "i).*\.([a-z]+).*", "$1")
				Case "List":
					WinGet, h, List, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText

					Loop, % ((r := []).Length := h)
						r.Push(h%A_Index%)
				Case "Pos":
					WinGetPos, x, y, w, h, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText

					r := {"x": x
						, "y": y
						, "Width": w
						, "Height": h}
				Case "Text":
					WinGetText, r, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
				Case "Title":
					WinGetTitle, r, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
				Case "Transparent":
					WinGet, a, Transparent, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText

					r := a != "" ? a : 255
				Case "Visible":
					WinGet, h, ID, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText

					r := DllCall("IsWindowVisible", "UInt", h)  ;? https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-iswindowvisible.
				Default:
					WinGet, r, % _SubCommand, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText  ;- Native error handling.
			}
		}
		Else {
			r := {}

			For i, v in ["Class", "ControlList", "ControlListHwnd", "Count", "ExStyle", "Extension", "ID", "IDLast", "List", "MinMax", "PID", "Pos", "ProcessName", "ProcessPath", "Style", "Text", "Title", "TransColor", "Transparent", "Visible"]
				r[v] := WinGet(v, _WinTitle, _WinText, _ExcludeTitle, _ExcludeText)  ;* No need to pass `_DetectHiddenWindows` as that setting is not instanced.
		}

		If (d)
			DetectHiddenWindows, % d
		Return, (r)
	}

	Throw, (Exception("Invalid title.", -1, Format("""{}"" is invalid or doesn't exist.", _WinTitle)))
}

;=====          Clipboard           =========================;

;*	CloseClipboard()
CloseClipboard() {
    If (!DllCall("user32.dll\CloseClipboard"))  ;? https://github.com/jNizM/AHK_DllCall_WinAPI/tree/master/src/Clipboard%20Functions.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;*	EmptyClipboard()
EmptyClipboard() {
    If (!DllCall("user32.dll\EmptyClipboard"))  ;? https://msdn.microsoft.com/en-us/library/ms649037.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;*	OpenClipboard([_NewOwner])
OpenClipboard(_NewOwner := 0) {
    If (!DllCall("user32.dll\OpenClipboard", "Ptr", _NewOwner))  ;? https://msdn.microsoft.com/en-us/library/ms649048.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;=====           Keyboard           =========================;

;*	BlockInput([_Mode])
;*	Note:
;*		Note that only the thread that blocked input can successfully unblock input.
BlockInput(_Mode := 0) {
    If (!DllCall("user32.dll\BlockInput", "UInt", _Mode))  ;? https://msdn.microsoft.com/en-us/library/ms646290.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;=====        Date and Time         =========================;

;*	QueryPerformanceCounter([_Query])
;*	Description:
;*		Returns accurately how many seconds have passed between `QueryPerformanceCounter(0)` and `QueryPerformanceCounter(1)`.
QueryPerformanceCounter(_Query := 0) {
	Static vFrequency, vCurrent := !DllCall("QueryPerformanceFrequency", "Int64P", vFrequency), vPrevious  ;? https://msdn.microsoft.com/en-us/library/ms644905.aspx.

	Return, (!DllCall("QueryPerformanceCounter", "Int64P", vCurrent) + (_Query ? vCurrent - vPrevious : vPrevious := vCurrent)/vFrequency)  ;? https://msdn.microsoft.com/en-us/library/ms644904.aspx.
}

Class Date {

;*	Date.IsLeapYear(_Year)
	IsLeapYear(_Year) {
		Return, (!Mod(_Year, 4) && (!Mod(_Year, 400) || Mod(_Year, 100)))
	}

;*	Date.Julian(_Date)
;*	Description:
;*		Convert a Gregorian date to a Julian date (https://en.wikipedia.org/wiki/Julian_day).
;*	Credit:
;*		SKAN: https://autohotkey.com/board/topic/19644-julian-date-converter-for-google-daterange-search/#entry129225.
	Julian(_Date) {
		FormatTime, _Date, % _Date, yyyyMMddHHmmss

		y := _Date[0, 4] + 0, m := _Date[4, 6] + 0
		If (m <= 2)
			m += 12, y -= 1

		Return, Round(2 - ~~(y/100) + ~~(~~(y/100)/4) + ~~(365.25*(y + 4716)) + ~~(30.6001*(m + 1)) + (_Date[6, 8] + 0) - 1524.5 + ((_Date[8, 10] + 0) + ((_Date[10, 12] + 0)/60.0) + ((_Date[12, 14] + 0)/3600.0))/24.0)
	}
}

;=====            Mouse             =========================;

;*	ClipCursor([_Confine[, upper-left x, upper-left y, lower-right x, lower-right y]])
;*	Description:
;*		Confines the cursor to a rectangular area on the screen. If a subsequent cursor position (set by the SetCursorPos function or the mouse) lies outside the rectangle, the system automatically adjusts the position to keep the cursor inside the rectangular area.
;*	Parameter:
;*		_Confine:
;*			0: The cursor is free to move anywhere on the screen.
;*			1: The cursor is confined to `_RECT`.
;*		_RECT:
;*			*: Expects 4 parameters; upper-left x, upper-left y, lower-right x (upper-left x + width) and lower-right y (upper-left y + height) of the rectangle that the mouse is to be confined to.
ClipCursor(_Confine := 0, _RECT*) {
    Static vClipCursor := VarSetCapacity(vClipCursor, 16, 0)

    If (!_Confine)
        Return, (DllCall("user32.dll\ClipCursor"))  ;? https://msdn.microsoft.com/en-us/library/ms648383.aspx.

    NumPut(_RECT[1], vClipCursor, 0, "Int"), NumPut(_RECT[2], vClipCursor, 4, "Int"), NumPut(_RECT[3], vClipCursor, 8, "Int"), NumPut(_RECT[4], vClipCursor, 12, "Int")  ;? https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect.
    If (!DllCall("user32.dll\ClipCursor", "Ptr", &vClipCursor))
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;*	GetDoubleClickTime()
GetDoubleClickTime() {
    Return, (DllCall("user32.dll\GetDoubleClickTime"))  ;? https://msdn.microsoft.com/en-us/library/ms646258.aspx.
}

;*	GetCapture()
GetCapture() {
    Return, (DllCall("user32.dll\GetCapture"))  ;? https://msdn.microsoft.com/en-us/library/ms646262.aspx.
}

;*	ReleaseCapture()
ReleaseCapture() {
    If (!DllCall("user32.dll\ReleaseCapture"))  ;? https://msdn.microsoft.com/en-us/library/ms646261.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;*	SetDoubleClickTime()
SetDoubleClickTime(_Interval := 500) {
    If (!DllCall("user32.dll\SetDoubleClickTime", "UInt", _Interval))  ;? https://msdn.microsoft.com/en-us/library/ms646263.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;*	SwapMouseButton()
SwapMouseButton(_Mode := 0) {
    DllCall("user32.dll\SwapMouseButton", "UInt", _Mode)  ;? https://msdn.microsoft.com/en-us/library/ms646264.aspx.
}

;=====             Type             =========================;

;*	Type(_Variable)
Type(_Variable) {
	Static vRegExMatchObject := NumGet(&(m, RegExMatch("", "O)", m))), vBoundFunc := NumGet(&(f := Func("Func").Bind())), vFileObject := NumGet(&(f := FileOpen("*", "w"))), vEnumeratorObject := NumGet(&(e := ObjNewEnum({})))

    If (IsObject(_Variable))
        Return, (ObjGetCapacity(_Variable) != "" ? SubStr(_Variable.base.__Class, 3) : IsFunc(_Variable) ? "Func" : ComObjType(_Variable) != "" ? "ComObject" : NumGet(&_Variable) == vBoundFunc ? "BoundFunc" : NumGet(&_Variable) == vRegExMatchObject ? "RegExMatchObject" : NumGet(&_Variable) == vFileObject ? "FileObject" : NumGet(&_Variable) == vEnumeratorObject ? "Object.Enumerator" : "Property")
	Else If _Variable is Number
		Return, (InStr(_Variable, ".") ? "Float" : "Integer")
	Else
		Return, (ObjGetCapacity([_Variable], 0) > 0 ? "String" : "")
}

;=====           Variable           =========================;

;*	DownloadContent(_Url)
DownloadContent(_Url) {
	Static oComObj := ComObjCreate("MSXML2.XMLHTTP")

	oComObj.Open("Get", _Url, 0)
	oComObj.Send()

	Return, (oComObj.ResponseText)
}

;*	VarExist(_Variable)
;*	Description:
;*		Returns a value to indicate whether the variable exists.
;*	Return:
;*		0: The variable does not exist.
;*		1: The variable does exist and contains data.
;*		2: The variable does exist and is empty.
;*	Credit:
;*		SKAN: https://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/page-3?&#entry78387.
VarExist(ByRef _Variable) {
	Return, (&_Variable == &v ? 0 : _Variable == "" ? 2 : 1)
}

;*	Swap(_Variable, _Variable2)
Swap(ByRef _Variable1, ByRef _Variable2) {
	t := _Variable1, _Variable1 := _Variable2, _Variable2 := t
}

;=====            Window            =========================;

;*	Fade(_Mode[, _Alpha[, _Time[, _Window]]])
;*	Description:
;*		Gradually fade a target window to a target alpha over a period of time.
Fade(_Mode, _Alpha := "" , _Time := 5000, _Window := "A") {
	a := t := (t := WinGet("Transparent", (w := _Window == "A" ? "ahk_id" . WinGet("ID") : _Window))) == "" ? 255*(_Mode = "In") : t, s := A_TickCount  ;* Safety check for `WinGet("Transparent")` returning `""` because I'm unsure how to test for the fourth exception mentioned in the docs.

	Switch (_Mode) {  ;- No error handling.
		Case "In":
			v := (z := Math.Min(255, Math.Max(0, _Alpha))) - t

			While (a < z)
				WinSet, Transparent, % a := ((A_TickCount - s)/_Time)*v + t, % w
		Case "Out":
			v := t - (z := Math.Min(255, Math.Max(0, _Alpha)))

			While (a > z)
				WinSet, Transparent, % a := (1 - ((A_TickCount - s)/_Time))*v + z, % w
	}
}

;=====            Other             =========================;

;*	ShowDesktop()
ShowDesktop() {
	Static oComObj := ComObjCreate("shell.application")

	oComObj.ToggleDesktop()
}

;*	ShowStartMenu()
ShowStartMenu() {
	DllCall("User32.dll\PostMessageW", "Ptr", DllCall("User32.dll\GetForegroundWindow", "Ptr"), "UInt", 0x112, "Ptr", 0xF130, "Ptr", 0)
}

;*	Speak(_String)
;*	Note:
;*		This is not ideal for active use as it will halt the thread that makes the request, better to call it from a second script or compile a dedicated executable.
Speak(_String) {
	Static oComObj := ComObjCreate("SAPI.SpVoice")

	oComObj.Speak(_String)
}