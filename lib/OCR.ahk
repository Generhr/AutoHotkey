#Requires AutoHotkey v2.0-beta

/*
* The MIT License (MIT)
* Copyright © 2022 Onimuru
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the “Software”), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

;============ Auto-Execute ====================================================;
;======================================================  Include  ==============;

#Include %A_LineFile%\..\Core.ah2

;============== Function ======================================================;

OCR(file := "") {
	static image := A_Temp . "\tesseract.tiff", text := A_Temp . "\tesseract.txt"

	LoadLibrary("Gdiplus")

	DllCall("Gdiplus\GdiplusStartup", "Ptr*", &(pToken := 0), "Ptr", Structure.CreateGDIplusStartupInput().Ptr, "Ptr", 0)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup

	if (FileExist(file)) {
		DllCall("Gdiplus\GdipCreateBitmapFromFile", "WStr", file, "Ptr*", &(pBitmap := 0))
	}
	else {
		(overlay := Gui("+AlwaysOnTop -Caption +Border +LastFound +ToolWindow +E0x20")).BackColor := "0xFFFFFF"
		WinSetTransparent(80, overlay)

		overlay.Show(Format("x{} y{} w{} h{} NA", 0, 0, A_ScreenWidth, A_ScreenHeight))

		Hotkey("*LButton", ObjBindMethod({}, {}), "On")

		while (!(GetKeyState("Esc", "P") || GetKeyState("LButton", "P"))) {
			Sleep(-1)
		}

		start := MouseGet("Pos")

		loop {
			if (GetKeyState("Esc", "P")) {
				GoTo("Shutdown")
			}

			current := MouseGet("Pos")
				, width := Abs(start.x - current.x) + 1, height := Abs(start.y - current.y) + 1

			if (width >= 5 && height >= 5) {
				x := (start.x < current.x) ? (start.x) : (current.x), y := (start.y < current.y) ? (start.y) : (current.y)

				overlay.Show(Format("x{} y{} w{} h{} NA", x, y, width, height))

				ToolTip(Format("{}, {}", width, height), 50, 50)
			}
			else {
				ToolTip()
			}

			Sleep(10)

		} until (!GetKeyState("LButton", "P"))

		if (width < 5 || height < 5) {
			x := DllCall("User32\GetSystemMetrics", "Int", 76), y := DllCall("User32\GetSystemMetrics", "Int", 77), width := DllCall("User32\GetSystemMetrics", "Int", 78), height := DllCall("User32\GetSystemMetrics", "Int", 79)
		}

		ToolTip()

		;* Create the bitmap:
		hDestinationDC := DllCall("Gdi32\CreateCompatibleDC", "Ptr", hSourceDC := DllCall("GetDC", "Ptr", 0, "Ptr"), "Ptr")  ;* Create a compatible DC, which is used in a BitBlt from the source DC (in this case the entire screen).
			, hCompatibleBitmap := DllCall("CreateDIBSection", "Ptr", hDestinationDC, "Ptr", Structure.CreateBitmapInfoHeader(width, -height).Ptr, "UInt", 0, "Ptr*", 0, "Ptr", 0, "UInt", 0, "Ptr"), hOriginalBitmap := DllCall("SelectObject", "Ptr", hDestinationDC, "Ptr", hCompatibleBitmap, "Ptr")  ;* Select the device-independent bitmap into the compatible DC.

		DllCall("Gdi32\BitBlt", "Ptr", hDestinationDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hSourceDC, "Int", x, "Int", y, "UInt", 0x00CC0020 | 0x40000000)  ;* Copy a portion of the source DC's bitmap to the destination DC's bitmap.
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

	if (!IsSet(pCodec) || !pCodec) {
		throw (Error("Could not find a matching encoder for the specified file format."))
	}

	DllCall("Gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", image, "Ptr", pCodec, "UInt", 0)  ;* Save the bitmap to a .tiff file for tesseract to analyze.
	DllCall("Gdiplus\GdipDisposeImage", "Ptr", pBitmap)  ;* Dispose of the bitmap.

	RunWait(Format("{} /c `"{} {} {}`"", A_ComSpec, "tesseract.exe", image, SubStr(text, 1, -4)), , "Hide")  ;* tesseract.exe must be in PATH. The extension for the output text file is automatically added here.
	content := FileRead(text)

	FileDelete(image)
	FileDelete(text)

Shutdown:
	overlay.Destroy()
	Hotkey("*LButton", "Off")

	DllCall("Gdiplus\GdiplusShutdown", "Ptr", pToken)
	FreeLibrary("Gdiplus")

	try {
		return (content)
	}
}
