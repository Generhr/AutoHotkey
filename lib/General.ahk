;=====           Function           =========================;
;===============             AHK              ===============;

;* KeyGet(vKeyName)
;* Description:
	;* Strip a key of modifiers.
KeyGet(vKeyName := "") {
	Return, (RegExReplace(vKeyName, "[~*$+^#! &]|AppsKey"))
}

;* KeyWait(vKeyName, $vOptions)
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
		If (t && QueryPerformanceCounter(1) >= t)  ;* `QueryPerformanceCounter()` is only called if `t` evaluates as true.
			Return, (ErrorLevel := 1)

		Sleep(-1)  ;* Need this here to register a key up event or else potentially create a second thread if there is a return immediately after this function in the calling thread.
	}

	Return, (ErrorLevel := 0)
}
__KeyWait(vKeyName) {
	Return, (GetKeyState(vKeyName, "P"))
}

;* MouseGet($vSubCommand, $vRelativeTo, $vFlag)
MouseGet(vSubCommand := "", vRelativeTo := "", vFlag := 0) {
	If (vRelativeTo)
		CoordMode, Mouse, % vRelativeTo  ;- No error handling, no restore.

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

;* MsgBox($vText, $vOptions, $vTitle, $vTimeout)
MsgBox(vText := "", vOptions := 0, vTitle := "Beep boop.", vTimeout := 0) {
	MsgBox, % vOptions, % vTitle, % (vText == "") ? ("""""") : (vText), % vTimeout
}

;* PostMessage(vMsg, $vParameter1, $vParameter2, $vControl, $vWinTitle, $vWinText, $vExcludeTitle, $vExcludeText, $vDetectHiddenWindows)
PostMessage(vMsg, vParameter1 := 0, vParameter2 := 0, vControl := "", vWinTitle := "", vWinText := "", vExcludeTitle := "", vExcludeText := "", vDetectHiddenWindows := "") {
	If (vDetectHiddenWindows != "" && vDetectHiddenWindows != (z := A_DetectHiddenWindows))
		DetectHiddenWindows, % vDetectHiddenWindows  ;- No error handling.

	PostMessage, vMsg, vParameter1, vParameter2, % vControl, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText

	If (z)
		DetectHiddenWindows, % z
	Return, (ErrorLevel)  ;* ErrorLevel is set to 1 if there was a problem such as the target window or control not existing. Otherwise, it is set to 0.
}

;* RunActivate(vWinTitle, vTarget, $vOptions, $vTimeout, $oPos)
;* Parameter:
	;* oPos:
		;* *: An object containg x, y, width and height.
RunActivate(vWinTitle, vTarget, vOptions := "", vTimeout := "", oPos := "") {
	If (!WinExist(vWinTitle)) {
		Run, % vTarget, , % vOptions  ;- Native error handling.
		WinWait, % vWinTitle, , vTimeout
		If (ErrorLevel)
			Return, (ErrorLevel)  ;* ErrorLevel is set to 1 if `WinWait` timed out.

		If (oPos)
			WinMove, % vWinTitle, , oPos.x, oPos.y, oPos.Width, oPos.Height
	}
	WinActivate
	WinWaitActive, A  ;* Set "Last Found" window.

	Return, (WinExist())
}

;* SendMessage(vMsg, $vParameter1, $vParameter2, $vControl, $vWinTitle, $vWinText, $vExcludeTitle, $vExcludeText, $vTimeout, $vDetectHiddenWindows)
SendMessage(vMsg, vParameter1 := 0, vParameter2 := 0, vControl := "", vWinTitle := "", vWinText := "", vExcludeTitle := "", vExcludeText := "", vTimeout := 5000, vDetectHiddenWindows := "") {
	If (vDetectHiddenWindows != "" && vDetectHiddenWindows != (d := A_DetectHiddenWindows))
		DetectHiddenWindows, % vDetectHiddenWindows  ;- No error handling.

	SendMessage, vMsg, vParameter1, vParameter2, % vControl, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText, vTimeout

	If (d)
		DetectHiddenWindows, % d
	Return, (ErrorLevel)  ;* ErrorLevel is set to the word FAIL if there was a problem or the command timed out. Otherwise, it is set to the numeric result of the message, which might sometimes be a "reply" depending on the nature of the message and its target window.
}

;* SetTimer(vLabel, $vPeriod, $vPriority)
SetTimer(vLabel, vPeriod := "", vPriority := 0) {
	SetTimer, % vLabel, % vPeriod, % vPriority  ;* Parameters are evaluated before calling functions which means you can pass `FuncObj.Bind("Parameter")` directly to `SetTimer()`.
}

;* Sleep(vMilliseconds)
Sleep(vMilliseconds) {
    Sleep, vMilliseconds
}

;* ToolTip($vText, $vX, $vY, $vRelativeTo, $vWhichToolTip)
ToolTip(vText := "", vX := "", vY := "", vRelativeTo := "Screen", vWhichToolTip := 1) {
	If (vRelativeTo)
		CoordMode, ToolTip, % vRelativeTo  ;- No error handling.

	ToolTip, % vText, vX, vY, vWhichToolTip
}

;* WinGet($vSubCommand, $vWinTitle, $vWinText, $vExcludeTitle, $vExcludeText, $vDetectHiddenWindows)
WinGet(vSubCommand := "", vWinTitle := "A", vWinText := "", vExcludeTitle := "", vExcludeText := "", vDetectHiddenWindows := "") {
	If (vDetectHiddenWindows != "" && vDetectHiddenWindows != (z := A_DetectHiddenWindows))
		DetectHiddenWindows, % vDetectHiddenWindows  ;- No error handling.

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

					Loop, % ((r := []).Length := h)
						r.Push(h%A_Index%)
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

					r := DllCall("IsWindowVisible", "UInt", h)  ;? https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-iswindowvisible.
				Default:
					WinGet, r, % vSubCommand, % vWinTitle, % vWinText, % vExcludeTitle, % vExcludeText  ;- Native error handling.
			}
		}
		Else {
			r := {}

			For i, v in ["Class", "ControlList", "ControlListHwnd", "Count", "ExStyle", "Extension", "ID", "IDLast", "List", "MinMax", "PID", "Pos", "ProcessName", "ProcessPath", "Style", "Text", "Title", "TransColor", "Transparent", "Visible"]
				r[v] := WinGet(v, vWinTitle, vWinText, vExcludeTitle, vExcludeText)  ;* No need to pass `vDetectHiddenWindows` as that setting is not instanced.
		}

		If (z)
			DetectHiddenWindows, % z
		Return, (r)
	}

	Throw, (Exception("Invalid title.", -1, Format("""{}"" is invalid or doesn't exist.", vWinTitle)))
}

;===============          Clipboard           ===============;

;* CloseClipboard()
CloseClipboard() {
    If (!DllCall("user32.dll\CloseClipboard"))  ;? https://github.com/jNizM/AHK_DllCall_WinAPI/tree/master/src/Clipboard%20Functions.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;* EmptyClipboard()
EmptyClipboard() {
    If (!DllCall("user32.dll\EmptyClipboard"))  ;? https://msdn.microsoft.com/en-us/library/ms649037.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;* OpenClipboard($vNewOwner)
OpenClipboard(vNewOwner := 0) {
    If (!DllCall("user32.dll\OpenClipboard", "Ptr", vNewOwner))  ;? https://msdn.microsoft.com/en-us/library/ms649048.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;===============           Keyboard           ===============;

;* BlockInput($vMode)
;* Note:
	;* Note that only the thread that blocked input can successfully unblock input.
BlockInput(vMode := 0) {
    If (!DllCall("user32.dll\BlockInput", "UInt", vMode))  ;? https://msdn.microsoft.com/en-us/library/ms646290.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;==============        Date and Time         ===============;

;* QueryPerformanceCounter($vQuery)
;* Description:
	;* Returns accurately how many seconds have passed between `QueryPerformanceCounter(0)` and `QueryPerformanceCounter(1)`.
QueryPerformanceCounter(vQuery := 0) {
	Static __Frequency,  __Previous := !DllCall("QueryPerformanceFrequency", "Int64P", __Frequency)  ;? https://msdn.microsoft.com/en-us/library/ms644905.aspx.

	Return, (!DllCall("QueryPerformanceCounter", "Int64P", c) + ((vQuery) ? (c - __Previous) : (__Previous := c))/__Frequency)  ;? https://msdn.microsoft.com/en-us/library/ms644904.aspx.
}

Class Date {

	;* Date.IsLeapYear(vYear)
	IsLeapYear(vYear) {
		Return, (!Mod(vYear, 4) && (!Mod(vYear, 400) || Mod(vYear, 100)))
	}

	;* Date.Julian(vDate)
	;* Description:
		;* Convert a Gregorian date to a Julian date (https://en.wikipedia.org/wiki/Julian_day).
	;* Credit:
		;* SKAN: https://autohotkey.com/board/topic/19644-julian-date-converter-for-google-daterange-search/#entry129225.
	ToJulian(vDate) {
		FormatTime, vDate, % vDate, yyyyMMddHHmmss

		y := vDate[0, 4] + 0, m := vDate[4, 6] + 0
		If (m <= 2)
			m += 12, y -= 1

		Return, Round(2 - ~~(y/100) + ~~(~~(y/100)/4) + ~~(365.25*(y + 4716)) + ~~(30.6001*(m + 1)) + (vDate[6, 8] + 0) - 1524.5 + ((vDate[8, 10] + 0) + ((vDate[10, 12] + 0)/60.0) + ((vDate[12, 14] + 0)/3600.0))/24.0)
	}
}

;==============         Machine Code         ===============;

;* Bentschi's version.
MCode(vMachineCode) {
	Static e := {1: 4, 2: 1}, c := ((A_PtrSize == 8) ? ("x64") : ("x86"))

	If (!RegExMatch(vMachineCode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m))
		Return

	DllCall("Crypt32\CryptStringToBinaryW", "Str", m3, "UInt", 0, "UInt", e[m1], "Ptr", 0, "UIntP", s, "Ptr", 0, "Ptr", 0)  ;? e[m1] = 4: (Hex) || 1: (Base64)

	p := DllCall("Kernel32\GlobalAlloc", "UInt", 0, "Ptr", s, "Ptr")
    If (A_PtrSize == 8)
        DllCall("Kernel32\VirtualProtect", "Ptr", p, "Ptr", s, "UInt", 0x40, "UIntP", 0)

	If (DllCall("Crypt32\CryptStringToBinaryW", "str", m3, "UInt", 0, "UInt", e[m1], "Ptr", p, "UIntP", s, "Ptr", 0, "Ptr", 0))
		Return, (p)

	DllCall("GlobalFree", "Ptr", p)
}

;==============            Mouse             ===============;

;* ClipCursor($vConfine, $vWindow, $oPos)
;* Description:
	;* Confines the cursor to a rectangular area on the screen. If a subsequent cursor position (set by the SetCursorPos function or the mouse) lies outside the rectangle, the system automatically adjusts the position to keep the cursor inside the rectangular area.
;* Parameter:
	;* vConfine:
		;* 0: The cursor is free to move anywhere on the screen.
		;* 1: The cursor is confined to `oPos*`.
	;* oPos:
		;* *: An object containg x, y, width and height.
ClipCursor(vConfine := 0, oPos := "") {
    Static __Rect := VarSetCapacity(__Rect, 16, 0)

    If (!vConfine)
        Return, (DllCall("user32.dll\ClipCursor"))  ;? https://msdn.microsoft.com/en-us/library/ms648383.aspx.

    NumPut(oPos.x, __Rect, 0, "Int"), NumPut(oPos.y, __Rect, 4, "Int"), NumPut(oPos.x + oPos.Width, __Rect, 8, "Int"), NumPut(oPos.y + oPos.Height, __Rect, 12, "Int")  ;? https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect.

	If (!DllCall("user32.dll\ClipCursor", "Ptr", &__Rect))
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;* GetDoubleClickTime()
GetDoubleClickTime() {
    Return, (DllCall("user32.dll\GetDoubleClickTime"))  ;? https://msdn.microsoft.com/en-us/library/ms646258.aspx.
}

;* GetCapture()
GetCapture() {
    Return, (DllCall("user32.dll\GetCapture"))  ;? https://msdn.microsoft.com/en-us/library/ms646262.aspx.
}

;* ReleaseCapture()
ReleaseCapture() {
    If (!DllCall("user32.dll\ReleaseCapture"))  ;? https://msdn.microsoft.com/en-us/library/ms646261.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;* SetDoubleClickTime()
SetDoubleClickTime(vInterval := 500) {
    If (!DllCall("user32.dll\SetDoubleClickTime", "UInt", vInterval))  ;? https://msdn.microsoft.com/en-us/library/ms646263.aspx.
        Return, (ErrorLevel := DllCall("kernel32.dll\GetLastError"))

    Return, (ErrorLevel := 0)
}

;* SwapMouseButton()
SwapMouseButton(vMode := 0) {
    DllCall("user32.dll\SwapMouseButton", "UInt", vMode)  ;? https://msdn.microsoft.com/en-us/library/ms646264.aspx.
}

;==============             Type             ===============;

;* Type(vVariable)
Type(vVariable) {
	Static __RegExMatchObject := NumGet(&(m, RegExMatch("", "O)", m))), __BoundFuncObject := NumGet(&(f := Func("Func").Bind())), __FileObject := NumGet(&(f := FileOpen("*", "w"))), __EnumeratorObject := NumGet(&(e := ObjNewEnum({})))

    If (IsObject(vVariable))
        Return, ((ObjGetCapacity(vVariable) != "") ? ((vVariable.Base.__Class == "__Array") ? ("Array") : ("Object")) : ((IsFunc(vVariable)) ? ("FuncObject") : ((ComObjType(vVariable) != "") ? ("ComObject") : ((NumGet(&vVariable) == __BoundFuncObject) ? ("BoundFuncObject ") : ((NumGet(&vVariable) == __RegExMatchObject) ? ("RegExMatchObject") : ((NumGet(&vVariable) == __FileObject) ? ("FileObject") : ((NumGet(&vVariable) == __EnumeratorObject) ? ("EnumeratorObject") : ("Property"))))))))
	Else If vVariable is Number
		Return, ((vVariable == Round(vVariable)) ? ("Integer") : ("Float"))
	Else
		Return, ((ObjGetCapacity([vVariable], 0) > 0) ? ("String") : (""))
}

;==============           Variable           ===============;

;* DownloadContent(vUrl)
DownloadContent(vUrl) {
	Static __ComObj := ComObjCreate("MSXML2.XMLHTTP")

	__ComObj.Open("Get", vUrl, 0)
	__ComObj.Send()

	Return, (__ComObj.ResponseText)
}

;* VarExist(vVariable)
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

;* Swap(vVariable, vVariable2)
Swap(ByRef vVariable1, ByRef vVariable2) {
	t := vVariable1, vVariable1 := vVariable2, vVariable2 := t
}

;==============            Window            ===============;

;* Fade(vMode, $vAlpha, $vTime, $vWindow)
;* Description:
	;* Gradually fade a target window to a target alpha over a period of time.
Fade(vMode, vAlpha := "" , vTime := 5000, vWindow := "A") {
	a := t := ((t := WinGet("Transparent", (w := (vWindow == "A") ? ("ahk_id" . WinGet("ID")) : (vWindow)))) == "") ? (255*(vMode = "In")) : (t), s := A_TickCount  ;* Safety check for `WinGet("Transparent")` returning `""` because I'm unsure how to test for the fourth exception mentioned in the docs.

	Switch (vMode) {  ;- No error handling.
		Case "In":
			v := (z := Math.Min(255, Math.Max(0, vAlpha))) - t

			While (a < z)
				WinSet, Transparent, % a := ((A_TickCount - s)/vTime)*v + t, % w
		Case "Out":
			v := t - (z := Math.Min(255, Math.Max(0, vAlpha)))

			While (a > z)
				WinSet, Transparent, % a := (1 - ((A_TickCount - s)/vTime))*v + z, % w
	}
}

;* ScriptCommand(vScript, vCommand)
ScriptCommand(vScript, vCommand) {
    Static __Command := {"Open": 65300, "Help": 65301, "Spy": 65302, "Reload": 65303, "Edit": 65304, "Suspend": 65305, "Pause": 65306, "Exit": 65307}

	PostMessage(0x111, __Command[vCommand], , , vScript . " - AutoHotkey", , , , "On")
}

;==============            Other             ===============;

;* ShowDesktop()
ShowDesktop() {
	Static __ComObj := ComObjCreate("shell.application")

	__ComObj.ToggleDesktop()
}

;* ShowStartMenu()
ShowStartMenu() {
	DllCall("User32.dll\PostMessageW", "Ptr", DllCall("User32.dll\GetForegroundWindow", "Ptr"), "UInt", 0x112, "Ptr", 0xF130, "Ptr", 0)
}

;* Speak(vString)
;* Note:
	;* This is not ideal for active use as it will halt the thread that makes the request, better to call it from a second script or compile a dedicated executable.
Speak(vString) {
	Static __ComObj := ComObjCreate("SAPI.SpVoice")

	__ComObj.Speak(vString)
}