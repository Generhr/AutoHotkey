#Requires AutoHotkey v2.0-beta.12

/*
* The MIT License (MIT)
*
* Copyright (c) 2023, Chad Blease
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

GDIp.Startup()

OnExit((*) => (GDIp.Shutdown()))

;============== Function ======================================================;

FindSinglePixel_WholeScreen(color) {
    x1 := DllCall("User32\GetSystemMetrics", "Int", 76), y1 := DllCall("User32\GetSystemMetrics", "Int", 77), width := DllCall("User32\GetSystemMetrics", "Int", 78), height := DllCall("User32\GetSystemMetrics", "Int", 79)

    DllCall("Gdi32\BitBlt", "Ptr", GDIp.DC.Handle, "Int", x1, "Int", y1, "Int", width - 1, "Int", height - 1, "Ptr", DllCall("User32\GetDC", "Ptr", 0, "Ptr"), "Int", x1, "Int", y1, "UInt", 0x00CC0020 | 0x40000000)  ;* Copy a portion of the source DC's bitmap to the destination DC's bitmap.

    bitmap := GDIp.Bitmap, pBitmap := bitmap.Ptr
    bitmap.LockBits()

    reset := x1
        , y2 := y1

    scan0 := bitmap.Scan0, stride := bitmap.Stride

    loop (height) {
        x2 := reset

        loop (width) {
            if (color = Numget(scan0 + x2 * 4 + y2 * stride, "UInt")) {
                bitmap.UnlockBits()

                return { x: x2, y: y2 }
            }

            x2++
        }

        y2++
    }

    bitmap.UnlockBits()

    return { x: "NOT", y: "FOUND" }
}

FindSinglePixel_Rectangle(x1, y1, width, height, color) {
    DllCall("Gdi32\BitBlt", "Ptr", GDIp.DC.Handle, "Int", x1, "Int", y1, "Int", width - 1, "Int", height - 1, "Ptr", DllCall("User32\GetDC", "Ptr", 0, "Ptr"), "Int", x1, "Int", y1, "UInt", 0x00CC0020 | 0x40000000)  ;* Copy a portion of the source DC's bitmap to the destination DC's bitmap.

    bitmap := GDIp.Bitmap, pBitmap := bitmap.Ptr
    bitmap.LockBits()

    static __Clamp(number, lower, upper) {
        return (((number := (number < lower) ? (lower) : (number)) > upper) ? (upper) : (number))
    }

    reset := Max(0, x1)
        , y2 := Max(0, y1), width := __Clamp(width, 0, NumGet(bitmap.BitmapData.Ptr, "UInt")) - reset, height := __Clamp(height, 0, NumGet(bitmap.BitmapData.Ptr + 4, "UInt")) - y2

    scan0 := bitmap.Scan0, stride := bitmap.Stride

    loop (height) {
        loop (x2 := reset, width) {
            if (color = Numget(scan0 + x2 * 4 + y2 * stride, "UInt")) {
                bitmap.UnlockBits()

                return { x: x2, y: y2 }
            }

            x2++
        }

        y2++
    }

    bitmap.UnlockBits()

    return { x: "NOT", y: "FOUND" }
}

;===============  Class  =======================================================;

class GDIp {

    __New(params*) {
        throw (TargetError("This class may not be constructed.", -1))
    }

    static Startup() {
        if (this.HasProp("Token")) {
            return (false)
        }

        ;* Load the GDIp library
        if (!(hModule := DllCall("Kernel32\LoadLibrary", "Str", "Gdiplus", "Ptr"))) {
            throw (OSError())
        }

        ;* Initializes Windows GDI+
        if (status := DllCall("Gdiplus\GdiplusStartup", "Ptr*", &(pToken := 0)
            , "Ptr", (() => (structure := Buffer(A_PtrSize * 2 + 8, 0), NumPut("UInt", 0x0001, structure), structure)).Call()  ;* GdiplusStartupInput structure: https://learn.microsoft.com/en-us/windows/win32/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput
            , "Ptr", 0)) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup
            throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
        }

        ;* Create a memory device context (DC) compatible with the device
        if (!(hDC := DllCall("Gdi32\CreateCompatibleDC", "Ptr", 0, "Ptr"))) {  ;~ Memory DC
            throw (OSError())
        }

        this.DC := this.CreateCompatibleDC(hDC)

        ;* Make the bitmap as large as the screen
        width := DllCall("User32\GetSystemMetrics", "Int", 78), height := DllCall("User32\GetSystemMetrics", "Int", 79)
        pixelFormat := 0x0026200A, bitCount := (pixelFormat >> 8) & 0xFF

        ;* Creates a Divice Independent Bitmap (DIB) that we can write to directly
        if (!(hBitmap := DllCall("Gdi32\CreateDIBSection", "Ptr", this.DC.Handle
            , "Ptr", (() => (structure := Buffer(40), NumPut("UInt", 40, "Int", width, "Int", -height, "UShort", 1, "UShort", bitCount, "UInt", 0x0000, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0, "UInt", 0, structure.Ptr), structure)).Call()  ;* BITMAPINFOHEADER structure: https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
            , "UInt", 0, "Ptr*", &(pBits := 0), "Ptr", 0, "UInt", 0, "Ptr"))) {
            throw (OSError())
        }

        this.DC.SelectObject({ Class: "HBitmap", Handle: hBitmap, __Delete: (*) => (DllCall("Gdi32\DeleteObject", "Ptr", hBitmap, "UInt")) })

        ;* Creates a Bitmap object based on an array of bytes along with size and format information. I use a clever trick here
        ;* and construct it with the pointer to the DIB bit values returned by `Gdi32\CreateDIBSection` so changes to this bitmap
        ;* are reflected on the bitmap selected into `this.DC` because they use the same memory which allows me to `Gdi32\BitBlt`
        ;* to another DC or from another to to mine which is far easier than juggling bitmaps and selecting them into DCs.
        if (status := DllCall("Gdiplus\GdipCreateBitmapFromScan0", "UInt", width, "UInt", height, "UInt", width * (bitCount >> 3), "UInt", pixelFormat, "Ptr", pBits, "Ptr*", &(pBitmap := 0), "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(int_int_int_pixelformat_byte)
            throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
        }

        this.Bitmap := this.CreateBitmap(pBitmap)

        return (!!(this.Token := pToken))
    }

    static Shutdown() {
        if (this.HasProp("Token")) {
            if (status := DllCall("Gdiplus\GdiplusShutdown", "Ptr", this.DeleteProp("Token"))) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }
        }

        ;* Free the GDIp library
        if (!DllCall("Kernel32\FreeLibrary", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "UInt")) {
            throw (OSError())
        }
    }

    class CreateCompatibleDC {
        Class := "DC", OriginalObjects := {}

        __New(hDC) {
            this.Handle := hDC
        }

        __Delete() {
            this.Reset()

            if (!DllCall("Gdi32\DeleteDC", "Ptr", this.Handle, "UInt")) {
                throw (OSError())
            }
        }

        ;-------------- Property ------------------------------------------------------;

        Layout {
            get {
                return (this.GetLayout())
            }

            set {
                this.SetLayout(value)

                return (value)
            }
        }

        ;* DC.GetLayout()
        ;* Return:
            ;* [Integer] layout
        GetLayout() {
            if ((layout := DllCall("Gdi32\SetLayout", this.Handle, "UInt")) == -1) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getlayout
                throw (OSError())
            }
        }

        ;* DC.SetLayout(layout)
        ;* Parameter:
            ;* [Integer] layout
        ;* Note
            ;~ The values returned by GetWindowOrgEx, GetWindowExtEx, GetViewportOrgEx and GetViewportExtEx are not affected by calling SetLayout.
        SetLayout(layout) {
            if (DllCall("Gdi32\SetLayout", this.Handle, "UInt", layout, "UInt") == -1) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-setlayout
                throw (OSError())
            }
        }

        ;--------------- Method -------------------------------------------------------;

        ;* DC.SelectObject(object)
        ;* Parameter:
            ;* [Object] object
        ;* Return:
            ;* [Integer] - Boolean value that indicates if an object was selected into this DC.
        SelectObject(object) {
            switch (class := object.Class) {
                case "HBitmap", "Brush", "Pen", "Region", "Font":
                    if (!(hObject := DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", object.Handle, "Ptr"))) {  ;~ If an error occurs and the selected object is not a region, the return value is `NULL`. Otherwise, it is `HGDI_ERROR`.
                        throw (OSError())
                    }

                    if (!this.OriginalObjects.HasProp(class)) {  ;* Save the handle to any original, default objects that are replaced.
                        this.OriginalObjects.%class% := hObject
                    }

                    return (true)
            }

            return (false)
        }

        ;* DC.Reset([class])
        ;* Parameter:
            ;* [String] class
        ;* Return:
            ;* [Integer] - Boolean value that indicates if an object was reset.
        Reset(class := "") {
            if (this.OriginalObjects.HasProp(class)) {
                if (!(hObject := DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", this.OriginalObjects.DeleteProp(class), "Ptr"))) {
                    throw (OSError())
                }

                return (hObject)
            }
            else if (!class) {
                for class in this.OriginalObjects.Clone().OwnProps() {
                    if (!DllCall("Gdi32\SelectObject", "Ptr", this.Handle, "Ptr", this.OriginalObjects.DeleteProp(class), "Ptr")) {
                        throw (OSError())
                    }
                }

                return (true)
            }

            return (false)
        }
    }

    class CreateBitmap {
        Class := "Bitmap"

        __New(pBitmap) {
            this.Ptr := pBitmap
        }

        ;* bitmap.Clone([x, y, width, height, pixelFormat])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Integer] pixelFormat - See PixelFormat enumeration.
        ;* Note:
            ;~ The new bitmap will have the same pixel format.
        ;* Return:
            ;* [Bitmap]
        Clone(x?, y?, width?, height?, pixelFormat := 0) {
            if (status := (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height))
                ? (DllCall("Gdiplus\GdipCloneBitmapArea", "Float", x, "Float", y, "Float", width, "Float", height, "UInt", pixelFormat || this.GetPixelFormat(), "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int"))
                : (DllCall("Gdiplus\GdipCloneImage", "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int"))) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }

            return (GDIp.Bitmap(pBitmap))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDisposeImage", "Ptr", this.Ptr, "Int")
            }
        }

        Width {
            get {
                return (this.GetWidth())
            }
        }

        ;* Return:
            ;* [Integer]
        GetWidth() {
            if (status := DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", &(width := 0), "Int")) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }

            return (width)
        }

        Height {
            get {
                return (this.GetHeight())
            }
        }

        ;* Return:
            ;* [Integer]
        GetHeight() {
            if (status := DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", &(height := 0), "Int")) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }

            return (height)
        }

        PixelFormat {
            get {
                return (this.GetPixelFormat())
            }
        }

        ;* bitmap.GetPixelFormat()
        ;* Return:
            ;* [Integer] - See PixelFormat enumeration.
        GetPixelFormat() {
            if (status := DllCall("Gdiplus\GdipGetImagePixelFormat", "Ptr", this.Ptr, "UInt*", &(pixelFormat := 0), "Int")) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }

            return (pixelFormat)
        }

        ;* Return:
            ;* [Object]
        GetRect(&unit := 0) {
            static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

            if (status := DllCall("Gdiplus\GdipGetImageBounds", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int*", &unit, "Int")) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }

            return ({ x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float") })
        }

        ;* Parameter:
            ;* [Integer] x
            ;* [Integer] y
        ;* Return:
            ;* [Integer]
        GetPixel(x, y) {
            if (this.HasProp("BitmapData")) {
                color := NumGet(this.Scan0 + x * 4 + y * this.Stride, "UInt")
            }
            else {
                static procAddress := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapGetPixel", "Ptr")

                DllCall(procAddress, "Ptr", this.Ptr, "Int", x, "Int", y, "UInt*", &(color := 0))  ;~ No error handling.
            }

            return (color)
        }

        /*
            ** Accessing bytes in various pixel formats: https://stackoverflow.com/a/50359349 **
        */

        ;* Parameter:
            ;* [Integer] x
            ;* [Integer] y
            ;* [Integer] width
            ;* [Integer] height
            ;* [Integer] color
        SetPixel(params*) {
            color := params.Pop()

            static __Clamp(number, lower, upper) {
                return (((number := (number < lower) ? (lower) : (number)) > upper) ? (upper) : (number))
            }

            if (this.HasProp("BitmapData")) {
                scan0 := this.Scan0, stride := this.Stride

                switch (params.Length) {
                    case 2:
                        Numput("UInt", color, scan0 + Max(params[0], 0) * 4 + Max(params[1], 0) * stride)
                    case 4:
                        reset := Max(params[0], 0)
                        , y := Max(params[1], 0), width := __Clamp(params[2], 0, NumGet(this.BitmapData.Ptr, "UInt")) - reset, height := __Clamp(params[3], 0, NumGet(this.BitmapData.Ptr + 4, "UInt")) - y
                    default:
                        reset := 0
                            , y := 0, width := NumGet(this.BitmapData.Ptr, "UInt"), height := NumGet(this.BitmapData.Ptr + 4, "UInt")
                }

                loop (height) {
                    loop (x := reset, width) {
                        Numput("UInt", color, scan0 + x++ * 4 + y * stride)  ;~ The Stride data member is negative if the pixel data is stored bottom-up.
                    }

                    y++
                }
            }
            else {
                static procAddress := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapSetPixel", "Ptr")

                switch (params.Length) {
                    case 2:
                        DllCall(procAddress, "Ptr", this.Ptr, "Int", Max(params[0], 0), "Int", Max(params[1], 0), "Int", color)
                    case 4:
                        reset := Max(params[0], 0)
                        , y := Max(params[1], 0), width := __Clamp(params[2], 0, this.Width) - reset, height := __Clamp(params[3], 0, this.Height) - y
                    default:
                        reset := 0
                            , y := 0, width := this.Width, height := this.Height
                }

                pBitmap := this.Ptr

                loop (height) {
                    loop (x := reset, width) {
                        DllCall(procAddress, "Ptr", pBitmap, "Int", x++, "Int", y, "UInt", color)
                    }

                    y++
                }
            }
        }

        ConvertFormat(pixelFormat, dithertype, palettetype, colorPalette, alphaThresholdPercent) {
            if (status := DllCall("Gdiplus\GdipBitmapConvertFormat", "Ptr", this.Ptr, "UInt", pixelFormat, "UInt", dithertype, "UInt", palettetype, "Ptr", colorPalette, "UInt", alphaThresholdPercent, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }
        }

        ;* bitmap.LockBits([x, y, width, height, pixelFormat, lockMode])
        ;* Parameter:
            ;* [Integer] x
            ;* [Integer] y
            ;* [Integer] width
            ;* [Integer] height
            ;* [Integer] pixelFormat - See PixelFormat enumeration.
            ;* [Integer] lockMode - See ImageLockMode enumeration.
        ;* Return:
            ;* [Integer] - Boolean value that indicates if the bitmap was locked.
        LockBits(x := 0, y := 0, width?, height?, lockMode := 0x0003, pixelFormat := 0) {  ;? http://supercomputingblog.com/graphics/using-lockbits-in-gdi/
            if (!this.HasProp("BitmapData")) {
                if (!IsSet(width)) {
                    if (!IsSet(height)) {
                        DllCall("Gdiplus\GdipGetImageDimension", "Ptr", this.Ptr, "Float*", &(width := 0), "Float*", &(height := 0))
                    }
                    else {
                        DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", &(width := 0))
                    }
                }
                else if (!IsSet(height)) {
                    DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", &(height := 0))
                }

                static __CreateRect(x, y, width, height) {
                    (structure := Buffer(16)), NumPut("UInt", x, "UInt", y, "UInt", width, "UInt", height, structure)
                    return (structure)
                }  ;? RECT, *PRECT, *NPRECT, *LPRECT;

                static __CreateBitmapData(width := 0, height := 0, stride := 0, pixelFormat := 0x26200A, scan0 := 0) {
                    static Buffer := { Call: (*) => ({ Class: "Buffer",
                        __Delete: (this) => (DllCall("Kernel32\HeapFree", "Ptr", DllCall("Kernel32\GetProcessHeap", "Ptr"), "UInt", 0, "Ptr", this.Ptr)) }) }

                    NumPut("UInt", width, "UInt", height, "Int", stride, "Int", pixelFormat, "Ptr", scan0, (instance := Buffer.Call()).Ptr := DllCall("Kernel32\HeapAlloc", "Ptr", DllCall("Kernel32\GetProcessHeap", "Ptr"), "UInt", 0x00000008, "Ptr", A_PtrSize * 2 + 16, "Ptr"))  ;! DllCall("Kernel32\HeapCreate", "UInt", 0x00000004, "Ptr", 0, "Ptr", 0, "Ptr")

                    return (instance)
                }  ;? BITMAPDATA;

                if (status := DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", this.Ptr, "Ptr", __CreateRect(x, y, width, height), "UInt", lockMode, "UInt", pixelFormat || this.GetPixelFormat(), "Ptr", (bitmapData := __CreateBitmapData()).Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
                    throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
                }

                this.Scan0 := NumGet(bitmapData.Ptr, 16, "Ptr"), this.Stride := NumGet(bitmapData.Ptr, 8, "Int")

                return (!!(this.BitmapData := bitmapData))  ;~ LockBits returning too much data: https://github.com/dotnet/runtime/issues/28600.
            }

            return (false)
        }

        ;* bitmap.UnlockBits()
        ;* Return:
            ;* [Integer] - Boolean value that indicates if the bitmap was unlocked.
        UnlockBits() {
            if (this.HasProp("BitmapData")) {
                if (status := DllCall("Gdiplus\GdipBitmapUnlockBits", "Ptr", this.Ptr, "Ptr", this.DeleteProp("BitmapData").Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
                    throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
                }

                this.DeleteProp("Scan0"), this.DeleteProp("Stride")

                return (true)
            }

            return (false)
        }

        ;* bitmap.RotateFlip(rotateType)
        ;* Parameter:
            ;* [Integer] rotateType - See RotateFlipType enumeration.
        RotateFlip(rotateType) {
            if (status := DllCall("Gdiplus\GdipImageRotateFlip", "Ptr", this.Ptr, "Int", rotateType, "Int")) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }
        }

        ;* bitmap.SaveToFile(file)
        ;* Parameter:
            ;* [String] file
        SaveToFile(file) {
            if (status := DllCall("Gdiplus\GdipGetImageEncodersSize", "UInt*", &(number := 0), "UInt*", &(size := 0), "Int")) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }

            if (status := DllCall("Gdiplus\GdipGetImageEncoders", "UInt", number, "UInt", size, "Ptr", (imageCodecInfo := Buffer(size)).Ptr, "Int")) {  ;* Fill a buffer with the available encoders.
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }

            loop (extension := RegExReplace(file, ".*(\.\w+)$", "$1"), number) {
                if (InStr(StrGet(imageCodecInfo.NumGet(A_PtrSize * 3 + (offset := (48 + A_PtrSize * 7) * (A_Index - 1)) + 32, "Ptr"), "UTF-16"), "*" . extension)) {
                    pCodec := imageCodecInfo.Ptr + offset  ;* Get the pointer to the matching encoder.

                    break
                }
            }

            if (!pCodec) {
                throw (Error("Could not find a matching encoder for the specified file format."))
            }

            if (status := DllCall("Gdiplus\GdipSaveImageToFile", "Ptr", this.Ptr, "Ptr", StrPtr(file), "Ptr", pCodec, "UInt", 0, "Int")) {
                throw (OSError(status, -2, ["GenericError", "InvalidParameter", "OutOfMemory", "ObjectBusy", "InsufficientBuffer", "NotImplemented", "Win32Error", "WrongState", "Aborted", "FileNotFound", "ValueOverflow", "AccessDenied", "UnknownImageFormat", "FontFamilyNotFound", "FontStyleNotFound", "NotTrueTypeFont", "UnsupportedGdiplusVersion", "GdiplusNotInitialized", "PropertyNotFound", "PropertyNotSupported", "ProfileNotFound"][status]))
            }
        }
    }
}
