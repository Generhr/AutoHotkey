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

;============ Auto-Execute ====================================================;
;======================================================  Include  ==============;

#Include %A_LineFile%\..\Structure\Structure.ahk  ;~ All `Structure()` calls can be replaced with `Buffer()`, just manually construct the necessary structs.

;============== Function ======================================================;

;* OCR([file])
;* Parameter:
	;* [String] file - The directory of the file from which to capture text.
;* Return:
	;* [String] - The text that was catured from the image.
OCR(file := "") {
	static image := A_Temp . "\tesseract.tiff", text := A_Temp . "\tesseract.txt"

	if (!(hModule := DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr"))) {  ;* Load the GDIp library.
		throw (MessageError(DllCall("Kernel32\GetLastError")))
	}

	DllCall("Gdiplus\GdiplusStartup", "Ptr*", &(pToken := 0), "Ptr", Structure.CreateGDIplusStartupInput().Ptr, "Ptr", 0)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup

	if (FileExist(file)) {
		DllCall("Gdiplus\GdipCreateBitmapFromFile", "WStr", file, "Ptr*", &(pBitmap := 0))
	}
	else {
		(overlay := Gui("+AlwaysOnTop -Caption +Border +LastFound +ToolWindow +E0x20")).BackColor := "0xFFFFFF"
		overlay.Show(Format("x{} y{} w{} h{} NA", 0, 0, A_ScreenWidth, A_ScreenHeight))
		WinSetTransparent(80, overlay)

		cancel := False

		if (!(hKeyboardHook := DllCall("User32\SetWindowsHookEx", "Int", 13, "Ptr", CallbackCreate(LowLevelKeyboardProc, "Fast"), "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0, "Ptr"))) {
			throw (MessageError(DllCall("Kernel32\GetLastError")))
		}

		LowLevelKeyboardProc(nCode, wParam, lParam) {
			Critical(True)

			if (!nCode) {  ;? 0 = HC_ACTION
				if (Format("{:#x}", NumGet(lParam, "UInt")) == 0x1B) {  ;? 0x1B = VK_ESCAPE
					if (wParam == 0x100) {  ;? 0x100 = WM_KEYDOWN
						cancel := True
					}

					return (1)
				}
			}

			return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
		}

		capture := False

		if (!(hMouseHook := DllCall("User32\SetWindowsHookEx", "Int", 14, "Ptr", CallbackCreate(LowLevelMouseProc, "Fast"), "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0, "Ptr"))) {
			throw (MessageError(DllCall("Kernel32\GetLastError")))
		}

		LowLevelMouseProc(nCode, wParam, lParam) {
			Critical(True)

			if (!nCode) {
				switch (wParam) {
					case 0x0201:  ;? 0x0201 = WM_LBUTTONDOWN
						capture := True

						return (1)
					case 0x0202:  ;? 0x0202 = WM_LBUTTONUP
						capture := False

						return (1)
				}
			}

			return (DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
		}

		while (!(capture || cancel)) {
			Sleep(-1)
		}

		if (capture) {
			MouseGetPos(&x1, &y1)

			loop {
				MouseGetPos(&x2, &y2)
					, width := Abs(x1 - x2) + 1, height := Abs(y1 - y2) + 1

				if (width > 5 && height > 5) {
					x2 := Min(x1, x2), y2 := Min(y1, y2)

					overlay.Show(Format("x{} y{} w{} h{} NA", x2, y2, width, height))

					if (A_Debug) {
						ToolTip(Format("{}, {}", width, height))
					}
				}
				else {
					overlay.Show(Format("x{} y{} w{} h{} NA", 0, 0, A_ScreenWidth, A_ScreenHeight))
				}

				Sleep(-1)

			} until (!capture || cancel)

			if (A_Debug) {
				ToolTip()
			}
		}

		overlay.Destroy()

		if (!DllCall("UnhookWindowsHookEx", "Ptr", hKeyboardHook, "UInt") || !DllCall("UnhookWindowsHookEx", "Ptr", hMouseHook, "UInt")) {
			throw (MessageError(DllCall("Kernel32\GetLastError")))
		}

		if (cancel) {
			GoTo("Shutdown")
		}

		if (width <= 5 || height <= 5) {
			x2 := DllCall("User32\GetSystemMetrics", "Int", 76), y2 := DllCall("User32\GetSystemMetrics", "Int", 77), width := DllCall("User32\GetSystemMetrics", "Int", 78), height := DllCall("User32\GetSystemMetrics", "Int", 79)
		}

		;* Create the bitmap:
		hDestinationDC := DllCall("Gdi32\CreateCompatibleDC", "Ptr", hSourceDC := DllCall("GetDC", "Ptr", 0, "Ptr"), "Ptr")  ;* Create a compatible DC, which is used in a BitBlt from the source DC (in this case the entire screen).
			, hCompatibleBitmap := DllCall("CreateDIBSection", "Ptr", hDestinationDC, "Ptr", Structure.CreateBitmapInfoHeader(width, -height).Ptr, "UInt", 0, "Ptr*", 0, "Ptr", 0, "UInt", 0, "Ptr"), hOriginalBitmap := DllCall("SelectObject", "Ptr", hDestinationDC, "Ptr", hCompatibleBitmap, "Ptr")  ;* Select the device-independent bitmap into the compatible DC.

		DllCall("Gdi32\BitBlt", "Ptr", hDestinationDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hSourceDC, "Int", x2, "Int", y2, "UInt", 0x00CC0020 | 0x40000000)  ;* Copy a portion of the source DC's bitmap to the destination DC's bitmap.
		DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hCompatibleBitmap, "Ptr", 0, "Ptr*", &(pBitmap := 0))  ;* Convert the hBitmap to a pBitmap.

		;* Cleanup up:
		DllCall("Gdi32\SelectObject", "Ptr", hDestinationDC, "Ptr", hOriginalBitmap), DllCall("Gdi32\DeleteObject", "Ptr", hCompatibleBitmap), DllCall("Gdi32\DeleteDC", "Ptr", hDestinationDC)
		DllCall("User32\ReleaseDC", "Ptr", 0, "Ptr", hSourceDC)
	}

	;* Save the bitmap to file:
	if (DllCall("Gdiplus\GdipGetImageEncodersSize", "UInt*", &(numEncoders := 0), "UInt*", &(size := 0))) {  ;: https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-retrieving-the-class-identifier-for-an-encoder-use
		throw (Error("Could not get a list of image codec encoders on this system."))
	}

	DllCall("Gdiplus\GdipGetImageEncoders", "UInt", numEncoders, "UInt", size, "Ptr", (imageCodecInfo := Structure(size)).Ptr)  ;* Fill a buffer with the available encoders.

	extension := RegExReplace(image, ".*\.(\w+)$", "$1")

	loop (numEncoders) {
		encoderExtensions := StrGet(imageCodecInfo.NumGet((index := (48 + A_PtrSize*7)*(A_Index - 1)) + 32 + A_PtrSize*3, "UPtr"), "UTF-16")

		if (InStr(encoderExtensions, "*." . extension, False)) {
			pCodec := imageCodecInfo.Ptr + index  ;* Get the pointer to the matching encoder.

			break
		}
	}

	if (!IsSet(pCodec)) {
		throw (Error("Could not find a matching encoder for the specified file format."))
	}

	DllCall("Gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", image, "Ptr", pCodec, "UInt", 0)  ;* Save the bitmap to a .tiff file for tesseract to analyze.
	DllCall("Gdiplus\GdipDisposeImage", "Ptr", pBitmap)  ;* Dispose of the bitmap.

	RunWait(Format('{} /c "{} {} {}"', A_ComSpec, "tesseract.exe", image, SubStr(text, 1, -4)), , "Hide")  ;* ** tesseract.exe must be in PATH. ** The extension for the output text file is automatically added here.
	content := FileRead(text)

	FileDelete(image)
	FileDelete(text)

Shutdown:
	DllCall("Gdiplus\GdiplusShutdown", "Ptr", pToken)

	if (!DllCall("Kernel32\FreeLibrary", "Ptr", hModule, "UInt")) {  ;* Free the GDIp library.
		throw (MessageError(DllCall("Kernel32\GetLastError")))
	}

	try {
		return (content)
	}

	;* MessageError(messageID)
	MessageError(messageID) {
		if (!(length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", &(buffer := 0), "UInt", 0, "Ptr", 0, "Int"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
			return (MessageError(DllCall("Kernel32\GetLastError")))
		}

		message := StrGet(buffer, length - 2)  ;* Account for the newline and carriage return characters.
		DllCall("Kernel32\LocalFree", "Ptr", buffer)

		return (Error(Format("{:#x}", messageID), -1, message))
	}
}