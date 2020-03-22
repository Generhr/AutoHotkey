;=====             AHK              =========================;

KeyGet(_KeyName := "") {
	Return, (RegExReplace(_KeyName ? _KeyName : A_ThisHotkey, "[~*$+^#! &]|AppsKey"))
}

__KeyWait(_KeyName) {
	Return, (GetKeyState(_KeyName, "P"))
}
KeyWait(_KeyName := "", _Options := "") {
	Static oFuncObj := Func("__KeyWait")

	k := [].Concat(_KeyName ? _KeyName : KeyGet(A_ThisHotkey)), s := !InStr(_Options, "D"), t := RegExReplace(_Options, "iS)[^t]*t?([\d\.]*).*", "$1") + !QueryPerformanceCounter(0)

	While (k.Some(oFuncObj) == s)
		If (t && QueryPerformanceCounter(1) >= t)  ;* `QueryPerformanceCounter()` is only called if `t` evaluates as true.
			Return, (ErrorLevel := 1)

	Return, (ErrorLevel := 0)
}

MouseGet(_SubCommand := "", _RelativeTo := "", _Flag := 0) {
	If (_RelativeTo)
		CoordMode, Mouse, % _RelativeTo  ;- No error handling, no restore.

	If (_SubCommand != "") {
		Switch (_SubCommand) {
			Case "Control": MouseGetPos, , , , r, % _Flag
			Case "Pos":
				MouseGetPos, x, y, , , % _Flag
				r := {"x": x
					, "y": y}
			Case "Window": MouseGetPos, , , r, , % _Flag
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

MsgBox(_Text := "", _Options := 0, _Title := "Beep boop", _Timeout := 0) {
	MsgBox, % _Options, % _Title, % _Text, % _Timeout
}

PostMessage(_Msg, _wParam := 0, _lParam := 0, _Control := "", _WinTitle := "A", _WinText := "", _ExcludeTitle := "", _ExcludeText := "", _DetectHiddenWindows := "") {
	If (_DetectHiddenWindows != "" && _DetectHiddenWindows != (d := A_DetectHiddenWindows))
		DetectHiddenWindows, % _DetectHiddenWindows  ;- No error handling.

	PostMessage, _Msg, _wParam, _lParam, % _Control, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText

	If (d)
		DetectHiddenWindows, % d
	Return, (ErrorLevel)  ;* ErrorLevel is set to 1 if there was a problem such as the target window or control not existing. Otherwise, it is set to 0.
}

RunActivate(_WinTitle, _Target, _Options := "", _Timeout := "", _Pos := "") {
	If (!WinExist(_WinTitle)) {
		Run, % _Target, , % _Options  ;- Native error handling.
		WinWait, % _WinTitle, , _Timeout
		If (ErrorLevel)
			Return, (1)  ;* Timed out.

		If (_Pos)
			WinMove, % _WinTitle, , _Pos.x, _Pos.y, _Pos.Width, _Pos.Height
	}
	WinActivate
	WinWaitActive, A  ;* Set "Last Found" window.

	Return, (WinExist())
}

SendMessage(_Msg, _wParam := 0, _lParam := 0, _Control := "", _WinTitle := "A", _WinText := "", _ExcludeTitle := "", _ExcludeText := "", _Timeout := 5000, _DetectHiddenWindows := "") {
	If (_DetectHiddenWindows != "" && _DetectHiddenWindows != (d := A_DetectHiddenWindows))
		DetectHiddenWindows, % _DetectHiddenWindows  ;- No error handling.

	SendMessage, _Msg, _wParam, _lParam, % _Control, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText, _Timeout

	If (d)
		DetectHiddenWindows, % d
	Return, (ErrorLevel)  ;* ErrorLevel is set to the word FAIL if there was a problem or the command timed out. Otherwise, it is set to the numeric result of the message, which might sometimes be a "reply" depending on the nature of the message and its target window.
}

SetTimer(_Label, _Period := "", _Priority := 0) {
	SetTimer, % _Label, % _Period, % _Priority  ;* Parameters are evaluated before calling functions which means you can pass `Func("Function").Bind("Parameter")` directly to the command.
}

ToolTip(_Text := "", _X := "", _Y := "", _RelativeTo := "", _WhichToolTip := 1) {
	If (_RelativeTo)
		CoordMode, ToolTip, % _RelativeTo  ;- No error handling, no restore.

	ToolTip, % _Text, _X, _Y, _WhichToolTip
}

WinGet(_SubCommand := "", _WinTitle := "A", _WinText := "", _ExcludeTitle := "", _ExcludeText := "", _DetectHiddenWindows := "") {
	If (_DetectHiddenWindows != "" && _DetectHiddenWindows != (d := A_DetectHiddenWindows))
		DetectHiddenWindows, % _DetectHiddenWindows  ;- No error handling.

	If (_WinTitle == "A" || WinExist(_WinTitle, _WinText, _ExcludeTitle, _ExcludeText)) {
		If (_SubCommand != "") {
			Switch (_SubCommand) {
				Case "Class": WinGetClass, r, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
				Case "Extension":
					WinGet, n, ProcessName, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
					r := RegExReplace(n, "i).*\.([a-z]+).*", "$1")
				Case "List":
					WinGet, h, List, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
					Loop, % ((r := []).Length := h)
						r[A_Index - 1] := h%A_Index%
				Case "Pos":
					WinGetPos, x, y, w, h, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
					r := {"x": x
						, "y": y
						, "Width": w
						, "Height": h}
				Case "Text": WinGetText, r, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
				Case "Title": WinGetTitle, r, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
				Case "Transparent":
					WinGet, a, Transparent, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
					r := a != "" ? a : 255  ;*** There was a 4th exception?
				Case "Visible":
					WinGet, h, ID, % _WinTitle, % _WinText, % _ExcludeTitle, % _ExcludeText
					r := DllCall("IsWindowVisible", "UInt", h)
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

;=====            ComObj            =========================;

;=====        Date and time         =========================;

;* Description:
;*		Returns accurately how many seconds have passed between `QueryPerformanceCounter(0)` and `QueryPerformanceCounter(1)`.
QueryPerformanceCounter(_Query := 0) {
	Static vFrequency, vCurrent := !DllCall("QueryPerformanceFrequency", "Int64P", vFrequency), vPrevious

	Return, (!DllCall("QueryPerformanceCounter", "Int64P", vCurrent) + (_Query ? vCurrent - vPrevious : vPrevious := vCurrent)/vFrequency)
}

;=====             Type             =========================;

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

Swap(ByRef _Variable1, ByRef _Variable2) {
	t := _Variable1

	_Variable1 := _Variable2
	_Variable2 := t
}

;=====            Window            =========================;

;* Description:
;*		Gradually fade in/out a target window to a target alpha over a period of time.
Fade(_Mode, _Alpha := "" , _Time := 5000, _Window := "A") {  ;- _Mode is not case sensitive.
	a := t := (t := WinGet("Transparent", (w := _Window == "A" ? "ahk_id" . WinGet("ID") : _Window))) == "" ? 255*(_Mode = "In") : t, s := A_TickCount
		v := [t - _Alpha, _Alpha - t][_Mode = "In"]

	Switch (_Mode) {  ;* Using switch instead of ternary because `While` will re-evaluate the condition after every loop.
		Case "In":
			While (a < _Alpha)
				WinSet, Transparent, % a := ((A_TickCount - s)/_Time)*v + t, % w
		Case "Out":
			While (a > _Alpha)
				WinSet, Transparent, % a := (1 - ((A_TickCount - s)/_Time))*v + _Alpha, % w
		Default:
			Throw, (Exception("Invalid parameter.", -1, Format("""{}"" is invalid.", _Mode)))
	}
}