#Requires AutoHotkey v2.0-beta

/*
* MIT License
*
* Copyright (c) 2022 Onimuru
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

class Spotify {
	static Handle := 0

	static Pause() {
		PostMessage(0x319, 0, 0x2F0000, this.GetWindow(False))  ;? 0x319 = WM_APPCOMMAND, 0x2F0000 = APPCOMMAND_MEDIA_PAUSE  ;: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-appcommand
	}

	static PlayPause() {
		PostMessage(0x319, 0, 0xE0000, this.GetWindow(False))  ;? 0xE0000 = APPCOMMAND_MEDIA_PLAY_PAUSE
	}

	static Play() {
		hWnd := this.GetWindow(False)

		PostMessage(0x319, 0, 0xD0000, hWnd)  ;? 0xD0000 = APPCOMMAND_MEDIA_STOP
		PostMessage(0x319, 0, 0xE0000, hWnd)
	}

	static Next() {
		PostMessage(0x319, 0, 0xB0000, this.GetWindow(False))  ;? 0xB0000 = APPCOMMAND_MEDIA_NEXTTRACK
	}

	static Prev() {
		PostMessage(0x319, 0, 0xC0000, this.GetWindow(False))  ;? 0xC0000 = APPCOMMAND_MEDIA_PREVIOUSTRACK
	}

	static GetWindow(prefix := False) {
		detect := A_DetectHiddenWindows
		DetectHiddenWindows(True)

		if (WinExist("ahk_exe Spotify.exe")) {
			hWnd := this.Handle

			if (!(hWnd && DllCall("IsWindow", "Ptr", hWnd, "UInt"))) {
				for hWnd in WinGetList("ahk_exe Spotify.exe") {
					if (WinGetClass(hWnd) == "Chrome_WidgetWin_0" && WinGetTitle(hWnd) ~= "^(Spotify.*|.* - .*)$") {
						this.Handle := hWnd

						break
					}
				}
			}
		}
		else {
			Run("C:\Program Files\WindowsApps\SpotifyAB.SpotifyMusic_1.187.612.0_x86__zpdnekdrzrea0\Spotify.exe")  ;* ** Spotify.exe location: https://community.spotify.com/t5/Desktop-Windows/Spotify-exe-location/td-p/5260104, gaining access to WindowsApps: https://helpdeskgeek.com/windows-10/how-to-access-the-windowsapps-folder-in-windows-10/. **
			WinWait("ahk_exe Spotify.exe")

			this.Handle := WinGetID("A")
		}

		DetectHiddenWindows(detect)  ;* Avoid leaving `A_DetectHiddenWindows` on for the calling thread.

		return ((prefix) ? ("ahk_ID" . this.Handle) : (this.Handle))
	}
}