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

global A_Debug := IniRead("..\cfg\Settings.ini", "Debug", "Debug", False)

;============== Function ======================================================;

/**
 * Captures a portion of the screen and passes the image to tesseract to be processed for text.
 * @param {String} [file] - The directory of an image to be processed instead of capturing a portion of the screen.
 * @return {String} The text that was catured from the image.
 */
OCR(file := "") {
    static image := A_Temp . "\tesseract.tiff", text := A_Temp . "\tesseract.txt"

    if (!(hModule := DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr"))) {  ;* Load the GDIp library.
        throw (__ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }

    __ErrorFromMessage(messageID) {
        if (!(length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", &(buffer := 0), "UInt", 0, "Ptr", 0, "Int"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
            return (__ErrorFromMessage(DllCall("Kernel32\GetLastError")))
        }

        message := StrGet(buffer, length - 2)  ;* Account for the newline and carriage return characters.
        DllCall("Kernel32\LocalFree", "Ptr", buffer)

        return (OSError(Format("{:#x}", messageID), -1, message))
    }

    DllCall("Gdiplus\GdiplusStartup", "Ptr*", &(pToken := 0), "Ptr", __CreateGDIplusStartupInput().Ptr, "Ptr", 0)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup

    __CreateGDIplusStartupInput() {
        static cbSize := A_PtrSize*2 + 8

        (structure := Buffer(cbSize, 0)), NumPut("UInt", 0x0001, structure.Ptr)
        return (structure)
    }

    if (FileExist(file)) {
        DllCall("Gdiplus\GdipCreateBitmapFromFile", "WStr", file, "Ptr*", &(pBitmap := 0))
    }
    else {
        (overlay := Gui("+AlwaysOnTop -Caption +Border +LastFound +ToolWindow +E0x20")).BackColor := "0xFFFFFF"
        overlay.Show(Format("x{} y{} w{} h{} NA", 0, 0, A_ScreenWidth, A_ScreenHeight))
        WinSetTransparent(80, overlay)

        cancel := False

        if (!(hKeyboardHook := DllCall("User32\SetWindowsHookEx", "Int", 13, "Ptr", CallbackCreate(__LowLevelKeyboardProc, "Fast"), "Ptr", DllCall("Kernel32\GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0, "Ptr"))) {
            throw (__ErrorFromMessage(DllCall("Kernel32\GetLastError")))
        }

        __LowLevelKeyboardProc(nCode, wParam, lParam) {
            Critical(True)

            if (!nCode) {  ;? 0 = HC_ACTION
                if (Format("{:#x}", NumGet(lParam, "UInt")) == 0x1B) {  ;? 0x1B = VK_ESCAPE
                    if (wParam == 0x100) {  ;? 0x100 = WM_KEYDOWN
                        cancel := True
                    }

                    return (1)
                }
            }

            return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
        }

        capture := False

        if (!(hMouseHook := DllCall("User32\SetWindowsHookEx", "Int", 14, "Ptr", CallbackCreate(__LowLevelMouseProc, "Fast"), "Ptr", DllCall("Kernel32\GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0, "Ptr"))) {
            throw (__ErrorFromMessage(DllCall("Kernel32\GetLastError")))
        }

        __LowLevelMouseProc(nCode, wParam, lParam) {
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

            return (DllCall("User32\CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr"))
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

        if (!DllCall("User32\UnhookWindowsHookEx", "Ptr", hKeyboardHook, "UInt") || !DllCall("User32\UnhookWindowsHookEx", "Ptr", hMouseHook, "UInt")) {
            throw (__ErrorFromMessage(DllCall("Kernel32\GetLastError")))
        }

        if (cancel) {
            GoTo("Shutdown")
        }

        if (width <= 5 || height <= 5) {
            x2 := DllCall("User32\GetSystemMetrics", "Int", 76), y2 := DllCall("User32\GetSystemMetrics", "Int", 77), width := DllCall("User32\GetSystemMetrics", "Int", 78), height := DllCall("User32\GetSystemMetrics", "Int", 79)
        }

        ;* Create the bitmap:
        hDestinationDC := DllCall("Gdi32\CreateCompatibleDC", "Ptr", hSourceDC := DllCall("GetDC", "Ptr", 0, "Ptr"), "Ptr")  ;* Create a compatible DC, which is used in a BitBlt from the source DC (in this case the entire screen).
            , hCompatibleBitmap := DllCall("Gdi32\CreateDIBSection", "Ptr", hDestinationDC, "Ptr", __CreateBitmapInfoHeader(width, -height).Ptr, "UInt", 0, "Ptr*", 0, "Ptr", 0, "UInt", 0, "Ptr"), hOriginalBitmap := DllCall("Gdi32\SelectObject", "Ptr", hDestinationDC, "Ptr", hCompatibleBitmap, "Ptr")  ;* Select the device-independent bitmap into the compatible DC.

        __CreateBitmapInfoHeader(width, height) {
            structure := Buffer(40), NumPut("UInt", 40, "Int", width, "Int", height, "UShort", 1, "UShort", 32, "UInt", 0x0000, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0, "UInt", 0, structure.Ptr)
            return (structure)
        }

        DllCall("Gdi32\BitBlt", "Ptr", hDestinationDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hSourceDC, "Int", x2, "Int", y2, "UInt", 0x00CC0020 | 0x40000000)  ;* Copy a portion of the source DC's bitmap to the destination DC's bitmap.
        DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hCompatibleBitmap, "Ptr", 0, "Ptr*", &(pBitmap := 0))  ;* Convert the hBitmap to a pBitmap.

        ;* Cleanup up:
        DllCall("Gdi32\SelectObject", "Ptr", hDestinationDC, "Ptr", hOriginalBitmap), DllCall("Gdi32\DeleteObject", "Ptr", hCompatibleBitmap), DllCall("Gdi32\DeleteDC", "Ptr", hDestinationDC)
        DllCall("User32\ReleaseDC", "Ptr", 0, "Ptr", hSourceDC)
    }

    ;* Save the bitmap to file:
    if (status := DllCall("Gdiplus\GdipGetImageEncodersSize", "UInt*", &(numEncoders := 0), "UInt*", &(size := 0), "UInt")) {  ;: https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-retrieving-the-class-identifier-for-an-encoder-use
        throw (__ErrorFromStatus(status))
    }

    __ErrorFromStatus(status) {
        static statusLookup := Map(1, "GenericError", 2, "InvalidParameter", 3, "OutOfMemory", 4, "ObjectBusy", 5, "InsufficientBuffer", 6, "NotImplemented", 7, "Win32Error", 8, "WrongState", 9, "Aborted", 10, "FileNotFound", 11, "ValueOverflow", 12, "AccessDenied", 13, "UnknownImageFormat", 14, "FontFamilyNotFound", 15, "FontStyleNotFound", 16, "NotTrueTypeFont", 17, "UnsupportedGdiplusVersion", 18, "GdiplusNotInitialized", 19, "PropertyNotFound", 20, "PropertyNotSupported", 21, "ProfileNotFound")  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplustypes/ne-gdiplustypes-status

        return (Error(status, -2, statusLookup[status]))
    }

    DllCall("Gdiplus\GdipGetImageEncoders", "UInt", numEncoders, "UInt", size, "Ptr", (imageCodecInfo := Buffer(size)).Ptr)  ;* Fill a buffer with the available encoders.

    extension := RegExReplace(image, ".*\.(\w+)$", "$1")

    loop (numEncoders) {
        encoderExtensions := StrGet(imageCodecInfo.NumGet((index := (48 + A_PtrSize*7)*(A_Index - 1)) + 32 + A_PtrSize*3, "Ptr*"), "UTF-16")

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
        throw (__ErrorFromMessage(DllCall("Kernel32\GetLastError")))
    }

    try {
        return (content)
    }
}
