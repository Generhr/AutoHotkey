#Requires AutoHotkey v2.0-beta

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

class YouTube_Music {
    static Handle := 0

    static Pause() {
        PostMessage(0x319, 0, 0x2F0000, , this.GetWindow(False))  ;? 0x319 = WM_APPCOMMAND, 0x2F0000 = APPCOMMAND_MEDIA_PAUSE  ;: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-appcommand
    }

    static PlayPause() {
        PostMessage(0x319, 0, 0xE0000, , this.GetWindow(False))  ;? 0xE0000 = APPCOMMAND_MEDIA_PLAY_PAUSE
    }

    static Play() {
        hWnd := this.GetWindow(False)

        PostMessage(0x319, 0, 0xD0000, , hWnd)  ;? 0xD0000 = APPCOMMAND_MEDIA_STOP
        PostMessage(0x319, 0, 0xE0000, , hWnd)
    }

    static Next() {
        PostMessage(0x319, 0, 0xB0000, , this.GetWindow(False))  ;? 0xB0000 = APPCOMMAND_MEDIA_NEXTTRACK
    }

    static Prev() {
        PostMessage(0x319, 0, 0xC0000, , this.GetWindow(False))  ;? 0xC0000 = APPCOMMAND_MEDIA_PREVIOUSTRACK
    }

    static GetWindow(prefix := False) {
        detect := A_DetectHiddenWindows

        DetectHiddenWindows(True)

        if (WinExist("ahk_class Chrome_WidgetWin_1 ahk_exe YouTube Music Desktop App.exe")) {
            hWnd := this.Handle

            if (!(hWnd && DllCall("User32\IsWindow", "Ptr", hWnd, "UInt"))) {
                for hWnd in WinGetList("ahk_class Chrome_WidgetWin_1 ahk_exe YouTube Music Desktop App.exe") {
                    if (WinGetClass(hWnd) == "Chrome_WidgetWin_1") {
                        this.Handle := hWnd

                        break
                    }
                }
            }
        }
        else {
            Run("C:\Users\" . A_UserName . "\AppData\Local\Programs\youtube-music-desktop-app\YouTube Music Desktop App.exe")

            while (!hWnd := WinExist("ahk_class Chrome_WidgetWin_1 ahk_exe YouTube Music Desktop App.exe")) {
                Sleep(-1)
            }

            this.Handle := hWnd
        }

        DetectHiddenWindows(detect)  ;* Avoid leaving `A_DetectHiddenWindows` on for the calling thread.

        return ((prefix) ? (Format("ahk_ID {}", this.Handle)) : (this.Handle))
    }
}
