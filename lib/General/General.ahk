#Requires AutoHotkey v2.0.0

/*
* The MIT License (MIT)
*
* Copyright (c) 2021 - 2023, Chad Blease
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

;============ Auto-Execute ====================================================;

#Include ..\Core.ahk

;============== Function ======================================================;
;------------ AHK Wrappers ----------------------------------------------------;

;* KeyStripModifiers(hotkey)
;* Description:
    ;* Strip a key of modifiers.
KeyStripModifiers(keyName) {
    return (RegExReplace(keyName, "[~*$+^! &]|AppsKey"))
}

;* KeyWait(keyName[, options])
;* Description:
    ;* Waits for any number of keys or mouse/joystick buttons to be released or pressed down.
;* Parameter:
    ;* keyName - A single key or an array of multiple keys automatically stripped of modifiers, any of which failing the condition (as set with a "D" in `options`) will cause this function to terminate.
    ;* options - Same as the options in the docs for the `KeyWait` function.
KeyWaitEx(keyName, options := "") {
    (keys := [].Concat(keyName)).ForEach((keyName, *) => (RegExReplace(keyName, "[~*$+^! &]|AppsKey"))), state := !options.Includes("D")
        , time := (options.Includes("T")) ? (RegExReplace(options, "iS)[^t]*t?([\d\.]*).*", "$1")*1000) : (0)

    QueryPerformanceCounter(0)

    while (keys.Some((keyName, *) => (GetKeyState(keyName, "P") == state))) {
        if (time && time <= QueryPerformanceCounter(1)) {
            return (True)
        }

        Sleep(-1)  ;* Need this here to register a key up event or else potentially create a second thread if there is a return immediately after this function in the calling thread.
    }

    return (False)
}

/**
 * .
 * @param {String} winTitle
 * @param {String} target
 * @param {String} [options]
 * @param {Integer} [timeOut]
 * @param {...Integer} [position]
 * @returns {Integer}
 */
RunActivate(winTitle, target, options := "", timeOut := 5000, position*) {
    if (!WinExist(winTitle)) {
        Run(target, , options)

        if (!WinWait(winTitle, , timeOut/1000)) {
            return (False)
        }

        if (position) {
            WinMove(position*)
        }
    }

    WinActivate(winTitle)
    WinWaitActive(winTitle)  ;* Set "Last Found" window.

    return (WinGetID(winTitle))
}

WinGetExtension(winTitle := "A", excludeTitle := "") {
    return (RegExReplace(WinGetProcessName(winTitle, , excludeTitle), "iS).*\.([a-z]+).*", "$1"))
}

;-------------- Keyboard ------------------------------------------------------;

DoubleTap(wait := False, delay := 300) {
    if (!wait) {
        return (A_ThisHotkey == A_PriorHotkey && A_TimeSincePriorHotkey <= 300)
    }

    KeyWait(A_ThisHotkey)

    return (!KeyWait(A_ThisHotkey, "DT" . delay/1000))
}

;---------------  Mouse  -------------------------------------------------------;

MouseIsOver(winTitle) {
    MouseGetPos(, , &hWnd)

    return (WinExist(winTitle . " ahk_ID " . hWnd))
}

;* MouseMoveEx(x, y[, speed])
MouseMoveEx(x, y, speed := 5) {
    MouseGetPos(&sx, &sy)

    distance := Sqrt((x - sx)**2 + (y - sy)**2)
        , dx := (x - sx)/distance, dy := (y - sy)/distance

    loop (distance/speed) {
        ratio := A_Index*speed

        MouseMove(sx + dx*ratio, sy + dy*ratio, 0)
    }
}

MouseWheel(delta := 120) {
    CoordMode("Mouse", "Screen")

    MouseGetPos(&x, &y)

    modifiers := 0x8*GetKeyState("Ctrl") | 0x1*GetKeyState("LButton") | 0x10*GetKeyState("MButton") | 0x2*GetKeyState("RButton") | 0x4*GetKeyState("Shift") | 0x20*GetKeyState("XButton1") | 0x40*GetKeyState("XButton2")

    PostMessage(0x20A, (delta << 16) | modifiers, (y << 16) | x, , "A")  ;: http://msdn.microsoft.com/en-us/library/windows/desktop/ms645617(v=vs.85).aspx
}

;* ClipCursor(confine[, x, y, width, height])
;* Description:
    ;* Confines the cursor to a rectangular area on the screen. If a subsequent cursor position (set by the SetCursorPos function or the mouse) lies outside the rectangle, the system automatically adjusts the position to keep the cursor inside the rectangular area.
;* Parameter:
    ;* confine:
        ;* 1: The cursor is confined to the rect defined in `rect` or the window that is currently active if no position object is passed.
        ;* 0: The cursor is free to move anywhere on the screen.
ClipCursor(confine, x?, y?, width?, height?) {
    if (!confine) {
        return (DllCall("User32\ClipCursor", "Ptr", 0, "UInt"))  ;: https://msdn.microsoft.com/en-us/library/ms648383.aspx
    }

    static rect := Buffer.CreateRect()

    try {
        rect.NumPut(0, "Int", x, "Int", y, "Int", width, "Int", height)  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect
    }
    catch {
        if (!DllCall("User32\GetWindowRect", "Ptr", WinGetID("A"), "Ptr", rect.Ptr, "UInt")) {
            throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
        }
    }

    if (!DllCall("User32\ClipCursor", "Ptr", rect.Ptr, "UInt")) {
        throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }

    return (False)
}

;* GetDoubleClickTime()
GetDoubleClickTime() {
    return (DllCall("User32\GetDoubleClickTime"))  ;: https://msdn.microsoft.com/en-us/library/ms646258.aspx
}

;* SetDoubleClickTime((interval))
SetDoubleClickTime(interval := 500) {
    if (!DllCall("User32\SetDoubleClickTime", "UInt", interval, "UInt")) {  ;: https://msdn.microsoft.com/en-us/library/ms646263.aspx
        throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }
}

;* GetCapture()
GetCapture() {
    return (DllCall("User32\GetCapture"))  ;: https://msdn.microsoft.com/en-us/library/ms646262.aspx
}

;* ReleaseCapture()
ReleaseCapture() {
    if (!DllCall("User32\ReleaseCapture", "UInt")) {  ;: https://msdn.microsoft.com/en-us/library/ms646261.aspx
        throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }
}

;* ShowCursor(show)
;* Return:
    ;* [Integer] - A value that specifies the new display counter.
ShowCursor(show) {
    return (DllCall("User32\ShowCursor", "UInt", show, "Int"))  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showcursor
}

;* SwapMouseButton(mode)
SwapMouseButton(mode) {
    if (!DllCall("User32\SwapMouseButton", "UInt", mode, "UInt")) {  ;: https://msdn.microsoft.com/en-us/library/ms646264.aspx
        throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }
}

;-------------  Clipboard  -----------------------------------------------------;

;* CloseClipboard()
CloseClipboard() {
    if (!DllCall("User32\CloseClipboard", "UInt")) {  ;: https://github.com/jNizM/AHK_DllCall_WinAPI/tree/master/src/Clipboard%20Functions
        throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }
}

;* EmptyClipboard()
EmptyClipboard() {
    if (!DllCall("User32\EmptyClipboard", "UInt")) {  ;: https://msdn.microsoft.com/en-us/library/ms649037.aspx
        throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }
}

;* OpenClipboard(newOwner)
OpenClipboard(newOwner) {
    if (!DllCall("User32\OpenClipboard", "Ptr", newOwner, "UInt")) {  ;: https://msdn.microsoft.com/en-us/library/ms649048.aspx
        throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }
}

;-----------  Date and Time  ---------------------------------------------------;

Clock() {
    return (DllCall("msvcrt\clock"))
}

;* QueryPerformanceCounter(mode)
;* Description:
    ;* Returns accurately how many milliseconds have passed between `QueryPerformanceCounter(0)` and `QueryPerformanceCounter(1)`.
QueryPerformanceCounter(mode) {
    static previous := !DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &(f := 0)), frequency := f/1000  ;: https://msdn.microsoft.com/en-us/library/ms644905.aspx

    DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &(current := 0))

    return (((mode) ? (current - previous) : (previous := current))/frequency)  ;: https://msdn.microsoft.com/en-us/library/ms644904.aspx
}

class Date {

    static Now() {
        DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &(time := 0))

        return (time)
    }

    ;* Date.IsLeapYear(year)
    static IsLeapYear(year) {
        return (!Mod(year, 4) && (!Mod(year, 400) || Mod(year, 100)))
    }

    ;* Date.ToJulian(year, month, day)
    ;* Description:
        ;* Convert a Gregorian date to a Julian date (https://en.wikipedia.org/wiki/Julian_day).
    ;* Credit:
        ;* SKAN: https://autohotkey.com/board/topic/19644-julian-date-converter-for-google-daterange-search/#entry129225.
    static ToJulian(year, month, day) {
        if (month <= 2) {
            month += 12, year -= 1
        }

        return (Floor(2 - Floor(year/100) + Floor(Floor(year/100)/4) + Floor((year + 4716)*365.25) + Floor((month + 1)*30.6001) + day - 1524.5))
    }
}

;------------ Machine Code ----------------------------------------------------;

;-------------- Variable ------------------------------------------------------;

;* DownloadContent(url)
DownloadContent(url) {
    static comObj := ComObject("WinHttp.WinHttpRequest.5.1")

    comObj.Open("GET", url, False)
    comObj.Send()

    return (comObj.ResponseText)
}

;* Swap(&variable1, &variable2)
Swap(&variable1, &variable2) {
    temp := variable1, variable1 := variable2, variable2 := temp
}


/**
 * @deprecated
 */
__Unset(variables*) {
/*
    ** ObjectBase **  ;: https://github.com/Lexikos/AutoHotkey_L/blob/alpha/source/script_object.h#L15
    ULONG mRefCount;  ;* 4
#ifdef _WIN64
    UINT mFlags;  ;* 4
#endif

    ** Var **  ;: https://github.com/Lexikos/AutoHotkey_L/blob/alpha/source/var.h#L118
    union  ;* A_PtrSize
    {
        __int64 mContentsInt64;  ;* A_PtrSize
        double mContentsDouble;  ;* A_PtrSize
        IObject *mObject;  ;* A_PtrSize
        VirtualVar *mVV;  ;* A_PtrSize
    };
    union  ;* A_PtrSize
    {
        LPTSTR mCharContents;  ;* A_PtrSize
        char *mByteContents;  ;* 1
    };
    union  ;* A_PtrSize
    {
        Var *mAliasFor;  ;* A_PtrSize
        VarSizeType mByteLength;  ;* A_PtrSize
    };
    VarSizeType mByteCapacity;  ;* A_PtrSize
    AllocMethodType mHowAllocated;  ;* 1
    VarAttribType mAttrib;  ;* 1
    UCHAR mScope;  ;* 1
    VarTypeType mType;  ;* 1
*/
    static offset := A_PtrSize*6 + 1

    for variable in variables {
        pointer := ObjPtr(variable) + offset

        NumPut("UChar", NumGet(pointer, "UChar") | 0x02, pointer)  ;? 0x02 = VAR_ATTRIB_UNINITIALIZED
    }
}

;--------------- Window -------------------------------------------------------;

Desktop() {
    style := WinGetStyle("A")

;   if (Debug && (!(style & 0x02000000) || !(style & 0x80000000)) && (style & 0x00020000 || style & 0x00010000)) {
;       MsgBox(((!(style & 0x02000000)) ? ("0x02000000 (WS_CLIPCHILDREN)") : ("0x80000000 (WS_POPUP)")) . " && " . ((style & 0x00020000) ? ("0x00020000 (WS_MINIMIZEBOX || WS_GROUP)") : ("0x00010000 (WS_MAXIMIZEBOX || WS_TABSTOP)")))
;   }

    return (((style & 0x02000000) || (style & 0x80000000)) && !(style & 0x00020000 || style & 0x00010000))
    ;! return ((style & 0x00C00000) ? (style & 0x80000000) : (!(style & 0x00020000 || style & 0x00010000)))

;   MsgBox(!(style & 0x00800000) . " (WS_BORDER)`n"
;       . !(style & 0x00C00000) . " (WS_CAPTION)`n"
;       . !(style & 0x40000000) . " (WS_CHILD || WS_CHILDWINDOW)`n"
;;      . !(style & 0x02000000) . " (WS_CLIPCHILDREN)`n"  ;! Desktop
;;      . !(style & 0x04000000) . " (WS_CLIPSIBLINGS)`n"  ;! Desktop
;       . !(style & 0x08000000) . " (WS_DISABLED)`n"
;       . !(style & 0x00400000) . " (WS_DLGFRAME)`n"  ;*** Use WS_DLGFRAME as a potential alternative to WS_CAPTION.
;       . !(style & 0x00020000) . " (WS_MINIMIZEBOX || WS_GROUP)`n"
;       . !(style & 0x00100000) . " (WS_HSCROLL)`n"
;       . !(style & 0x20000000) . " (WS_ICONIC || WS_MINIMIZE)`n"
;       . !(style & 0x01000000) . " (WS_MAXIMIZE)`n"
;       . !(style & 0x00010000) . " (WS_MAXIMIZEBOX || WS_TABSTOP)`n"
;       . !(style & 0x00000000) . " (WS_OVERLAPPED || WS_TILED)`n"
;;      . !(style & 0x80000000) . " (WS_POPUP)`n"  ;! Desktop
;       . !(style & 0x00040000) . " (WS_SIZEBOX || WS_THICKFRAME)`n"
;       . !(style & 0x00080000) . " (WS_SYSMENU)`n"
;;      . !(style & 0x10000000) . " (WS_VISIBLE)`n"  ;! Desktop
;       . !(style & 0x00200000) . " (WS_VSCROLL)`n`n")
}

GetActiveExplorerPath() {
    if (hWnd := WinActive("ahk_class CabinetWClass")) {
        for window in ComObject("Shell.Application").Windows {
            if (window.hWnd == hWnd) {
                return (window.Document.Folder.Self.Path)
            }
        }
    }
}

;* ScriptCommand(scriptName, message)
ScriptCommand(scriptName, message) {
    static commands := Map("Open", 65300, "Help", 65301, "Spy", 65302, "Reload", 65303, "Edit", 65304, "Suspend", 65305, "Pause", 65306, "Exit", 65307)

    PostMessage(0x111, commands[message], , , WinGetID(scriptName . " - AutoHotkey"))
}

;* ShowDesktop()
ShowDesktop() {
    static comObj := ComObject("Shell.Application")

    comObj.ToggleDesktop()
}

;* ShowStartMenu()
ShowStartMenu() {
    if (!DllCall("User32\PostMessage", "Ptr", WinGetID("A"), "UInt", 0x112, "Ptr", 0xF130, "Ptr", 0, "UInt")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-postmessagea
        throw (ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }
}

;* WinFade([winTitle, target, time])
;* Description:
    ;* Gradually fade `winTitle` to a `target` alpha over a period of `time` (in miliseconds).
WinFade(winTitle := "A", target := 255, time := 1000) {
    target := Min(255, Max(0, target))

    if (time > 0) {
        if ((alpha := WinGetTransparent(winTitle)) == "") {
            WinSetTransparent(alpha := 255, winTitle)
        }

        start := A_TickCount, original := alpha

        if (alpha < target) {
            difference := target - alpha

            while (alpha < target) {
                WinSetTransparent(Min(Round(alpha := original + ((A_TickCount - start)/time)*difference), 255), winTitle)
            }
        }
        else if (alpha != target) {
            difference := alpha - target

            while (alpha > target) {
                WinSetTransparent(Max(Round(alpha := original - ((A_TickCount - start)/time)*difference), 0), winTitle)
            }
        }
    }
    else {
        WinSetTransparent(target, winTitle)
    }
}

;-------------  Microsoft  -----------------------------------------------------;

GetCurrentProcessID() {
    return (DllCall("Kernel32\GetCurrentProcessId", "UInt"))
}

GetCurrentThreadID() {
    return (DllCall("Kernel32\GetCurrentThreadId", "UInt"))
}

;* InternetGetConnectedState()
InternetGetConnectedState() {
    return (DllCall("Wininet\InternetGetConnectedState", "Ptr", 0, "Int", 0, "UInt"))  ;: https://docs.microsoft.com/en-us/windows/win32/api/wininet/nf-wininet-internetgetconnectedstate
}

/*
    ** Create Bing Search resource through Azure Marketplace: https://learn.microsoft.com/en-us/bing/search-apis/bing-web-search/create-bing-search-service-resource **
    ** Spell Check API v7 reference: https://learn.microsoft.com/en-us/rest/api/cognitiveservices-bingsearch/bing-spell-check-api-v7-reference **
*/

;comObj := ComObject("WinHttp.WinHttpRequest.5.1")
;comObj.open("GET", "https://ipinfo.io")
;comObj.Send()
;comObj.WaitForResponse()
;
;Console.Log(comObj.ResponseText.country)

SpellCheck(query, preContextText := "", postContextText := "") {
    static comObj := ComObject("WinHttp.WinHttpRequest.5.1")

    comObj.open("POST", "https://api.bing.microsoft.com/v7.0/spellcheck?mode=proof&mkt=en-GB&text=" . query . "&preContextText=" . preContextText . "&postContextText=" . postContextText)  ;~ The combined length of `text`, `preContextText`, and `postContextText` may not exceed 10,000 characters.

    static subscriptionKey := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Bing", "Subscription Key")

    comObj.SetRequestHeader("Ocp-Apim-Subscription-Key", subscriptionKey)

    try {
        comObj.SetRequestHeader("X-MSEdge-ClientID", clientID)
    }

    comObj.Send()
    comObj.WaitForResponse()

    static clientID := comObj.getResponseHeader("X-MSEdge-ClientID")

    Console.Log(comObj.ResponseText)
}

;---------------  Other  -------------------------------------------------------;

;* Speak(message)
Speak(message, rate?, volume?) {
    static comObj := ComObject("SAPI.SpVoice")

    if (IsSet(rate)) {
        comObj.Rate := rate  ;: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ms723606(v=vs.85)
    }

    if (IsSet(volume)) {
        comObj.Volume := volume  ;: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ms723615(v=vs.85)
    }

    comObj.Speak(message, 1)  ;? 1 = SVSFlagsAsync  ;: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ms723609(v=vs.85), https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ms720892(v=vs.85)
}
