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

#DllLoad NtDll

/*
    ** MSDN Data Types: http://ahkscript.org/ursrc/Windows_Data_Types.html. **
    ** MSDN Structs: https://www.autohotkey.com/boards/viewtopic.php?f=74&t=30497. **

    ** x64 Software Convention: https://docs.microsoft.com/en-us/cpp/build/x64-software-conventions?view=msvc-160#types-and-storage. **
*/

;============ Auto-Execute ====================================================;

PatchBuffer()

;============== Function ======================================================;
;---------------  Patch  -------------------------------------------------------;

PatchBuffer() {

    ;======================================================== Base ================;
    ;-------------------------------------------------- CreateBitmapData ----------;

    Buffer.Base.DefineProp("CreateBitmapData", {Call: __CreateBitmapData})

    ;* Buffer.CreateBitmapData([width, height, stride, pixelFormat, scan0])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/previous-versions/ms534421(v=vs.85).
    __CreateBitmapData(this, width := 0, height := 0, stride := 0, pixelFormat := 0x26200A, scan0 := 0) {
        static cbSize := A_PtrSize*2 + 16

        (structure := this(cbSize)).NumPut(0, "UInt", width, "UInt", height, "Int", stride, "Int", pixelFormat, "Ptr", scan0)
        return (structure)
    }  ;? BITMAPDATA;

    ;-------------------------------------------------- CreateBitmapInfo ----------;

    Buffer.Base.DefineProp("CreateBitmapInfo", {Call: __CreateBitmapInfo})

    ;* Buffer.CreateBitmapInfo(bmiHeader, bmiColors)
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfo.
    __CreateBitmapInfo(this, bmiHeader, bmiColors) {
        return (BufferFromBuffer(bmiHeader, bmiColors))
    }  ;? BITMAPINFO, *LPBITMAPINFO, *PBITMAPINFO;

    ;----------------------------------------------- CreateBitmapInfoHeader -------;

    Buffer.Base.DefineProp("CreateBitmapInfoHeader", {Call: __CreateBitmapInfoHeader})

    ;* Buffer.CreateBitmapInfoHeader(width, height[, bitCount, compression, sizeImage, xPelsPerMeter, yPelsPerMeter, clrUsed, clrImportant])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/previous-versions/dd183376(v=vs.85).
    ;* Parameter:
        ;* compression:
            ;? 0x0000 = BI_RGB - An uncompressed format.
            ;? 0x0003 = BI_BITFIELDS - Specifies that the bitmap is not compressed. The members bV4RedMask, bV4GreenMask, and bV4BlueMask specify the red, green, and blue components for each pixel. This is valid when used with 16- and 32-bpp bitmaps.
            ;? 0x0002 = BI_RLE4 - A run-length encoded (RLE) format for bitmaps with 4 bpp. The compression format is a 2-byte format consisting of a count byte followed by two word-length color indexes.
            ;? 0x0001 = BI_RLE8 - A run-length encoded (RLE) format for bitmaps with 8 bpp. The compression format is a 2-byte format consisting of a count byte followed by a byte containing a color index.
        ;* sizeImage - Specifies the size, in bytes, of the image. It is valid to set this member to zero if the bitmap is in the `BI_RGB` format.
        ;* clrUsed - Specifies the number of color indexes in the color table actually used by the bitmap. If this value is zero, the bitmap uses the maximum number of colors corresponding to the value of the `bitCount` member.
        ;* clrImportant - Specifies the number of color indexes that are considered important for displaying the bitmap. If this value is zero, all colors are important.
    __CreateBitmapInfoHeader(this, width, height, bitCount := 32, compression := 0x0000, sizeImage := 0, xPelsPerMeter := 0, yPelsPerMeter := 0, clrUsed := 0, clrImportant := 0) {
        (structure := this(40)).NumPut(0, "UInt", 40, "Int", width, "Int", height, "UShort", 1, "UShort", bitCount, "UInt", compression, "UInt", sizeImage, "Int", xPelsPerMeter, "Int", yPelsPerMeter, "UInt", clrUsed, "UInt", clrImportant)
        return (structure)
    }  ;? BITMAPINFOHEADER, *PBITMAPINFOHEADER;

    ;------------------------------------------------  CreateBlendFunction  --------;

    Buffer.Base.DefineProp("CreateBlendFunction", {Call: __CreateBlendFunction})

    ;* Buffer.CreateBlendFunction([sourceConstantAlpha, alphaFormat])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-blendfunction, https://www.teamdev.com/downloads/jniwrapper/winpack/javadoc/constant-values.html#com.jniwrapper.win32.gdi.BlendFunction.AC_SRC_OVER.
    ;~ Note:
        ;~ When the AlphaFormat member is AC_SRC_ALPHA, the source bitmap must be 32 bpp. If it is not, the AlphaBlend function will fail.
    __CreateBlendFunction(this, sourceConstantAlpha := 255, alphaFormat := 1) {
        (structure := this(4, 0)).NumPut(2, "UChar", sourceConstantAlpha, "UChar", alphaFormat)
        return (structure)
    }  ;? BLENDFUNCTION, *PBLENDFUNCTION;

    ;-------------------------------------------------  CreateColorMatrix  ---------;

    Buffer.Base.DefineProp("CreateColorMatrix", {Call: __CreateColorMatrix})

    ;* Buffer.CreateColorMatrix([red, green, blue, alpha])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimageattributes/nf-gdiplusimageattributes-imageattributes-setcolormatrix.blue.
    __CreateColorMatrix(this, red := 1, green := 1, blue := 1, alpha := 1) {
        ; [r   0   0   0   0]
        ; [0   g   0   0   0]
        ; [0   0   b   0   0]
        ; [0   0   0   a   0]
        ; [0   0   0   0   1]

        (structure := this(100, 0)).NumPut(0, "Float", red), structure.NumPut(24, "Float", green), structure.NumPut(48, "Float", blue), structure.NumPut(72, "Float", alpha), structure.NumPut(96, "Float", 1)
        return (structure)
    }

    ;--------------------------------------------- CreateGreyScaleColorMatrix -----;

    Buffer.Base.DefineProp("CreateGreyScaleColorMatrix", {Call: __CreateGreyScaleColorMatrix})

    ;* Buffer.CreateGreyScaleColorMatrix([alpha])
    __CreateGreyScaleColorMatrix(this, alpha := 1) {
        ; [0.299   0.299   0.299   0   0]
        ; [0.587   0.587   0.587   0   0]
        ; [0.114   0.114   0.114   0   0]
        ; [  0       0       0     a   0]
        ; [  0       0       0     0   1]

        (structure := this(100, 0)).NumPut(0, "Float", 0.299, "Float", 0.299, "Float", 0.299), structure.NumPut(20, "Float", 0.587, "Float", 0.587, "Float", 0.587), structure.NumPut(40, "Float", 0.114, "Float", 0.114, "Float", 0.114), structure.NumPut(72, "Float", alpha), structure.NumPut(96, "Float", 1)
        return (structure)
    }

    ;---------------------------------------------  CreateNegativeColorMatrix  -----;

    Buffer.Base.DefineProp("CreateNegativeColorMatrix", {Call: __CreateNegativeColorMatrix})

    ;* Buffer.CreateNegativeColorMatrix([alpha])
    __CreateNegativeColorMatrix(this, alpha := 1) {
        ; [-1    0    0   0   0]
        ; [ 0   -1    0   0   0]
        ; [ 0    0   -1   0   0]
        ; [ 0    0    0   a   0]
        ; [ 1    1    1   0   1]

        (structure := this(100, 0)).NumPut(0, "Float", -1), structure.NumPut(24, "Float", -1), structure.NumPut(48, "Float", -1), structure.NumPut(72, "Float", alpha), structure.NumPut(80, "Float", 1, "Float", 1, "Float", 1, "Float", 0, "Float", 1)
        return (structure)
    }

    ;------------------------------------------  CreateConsoleReadConsoleControl  --;

    Buffer.Base.DefineProp("CreateConsoleReadConsoleControl", {Call: __CreateConsoleReadConsoleControl})

    ;* Buffer.CreateConsoleReadConsoleControl([initialChars, ctrlWakeupMask, controlKeyState])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/console/console-readconsole-control.
    ;* Parameter:
        ;* ctrlWakeupMask - See https://www.asciitable.com/.
    __CreateConsoleReadConsoleControl(this, initialChars := 0, ctrlWakeupMask := 0x0A, controlKeyState := 0) {
        (structure := this(16)).NumPut(0, "UInt", 16, "UInt", initialChars, "UInt", ctrlWakeupMask, "UInt", controlKeyState)
        return (structure)
    }  ;? CONSOLE_READCONSOLE_CONTROL, *PCONSOLE_READCONSOLE_CONTROL;

    ;----------------------------------------------------  CreateCoord  ------------;

    Buffer.Base.DefineProp("CreateCoord", {Call: __CreateCoord})

    ;* Buffer.CreateCoord([x, y])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/console/coord-str.
    __CreateCoord(this, x := 0, y := 0) {
        (structure := this(4)).NumPut(0, "Short", x, "Short", y)
        return (structure)
    }  ;? COORD, *PCOORD;

    ;---------------------------------------------  CreateGDIplusStartupInput  -----;

    Buffer.Base.DefineProp("CreateGDIplusStartupInput", {Call: __CreateGDIplusStartupInput})

    ;* Buffer.CreateGDIplusStartupInput()
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput.
    __CreateGDIplusStartupInput(this) {
        static cbSize := A_PtrSize*2 + 8

        (structure := this(cbSize, 0)).NumPut(0, "UInt", 0x0001)
        return (structure)
    }

    ;-------------------------------------------------- CreateCursorInfo ----------;

    Buffer.Base.DefineProp("CreateCursorInfo", {Call: __CreateCursorInfo})

    ;* Buffer.CreateCursorInfo([flags, cursor, [Buffer] screenPos])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-cursorinfo.
    __CreateCursorInfo(this, flags := 0, cursor := 0, screenPos?) {
        static cbSize := A_PtrSize + 16

        (structure := this(cbSize)).NumPut(0, "UInt", cbSize, "UInt", flags, "Ptr", cursor, "Buffer", (IsSet(screenPos)) ? (screenPos) : (this.CreatePoint(0, 0, "UInt")))
        return (structure)
    }  ;? CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

    ;----------------------------------------------------  CreatePoint  ------------;

    Buffer.Base.DefineProp("CreatePoint", {Call: __CreatePoint})

    ;* Buffer.CreatePoint([x, y, type])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-point.
    __CreatePoint(this, x := 0, y := 0, type := "UInt") {
        if (!(type ~= "i)Float|(U?Int)")) {
            throw (ValueError("``type`` must be a valid data type.", -1, type))
        }

        (structure := this(8)).NumPut(0, type, x, type, y)
        return (structure)
    }  ;? POINT, *PPOINT, *NPPOINT, *LPPOINT;

    ;---------------------------------------------------  CreateRGBQuad  -----------;

    Buffer.Base.DefineProp("CreateRGBQuad", {Call: __CreateRGBQuad})

    ;* Buffer.CreateRGBQuad([blue, green, red])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-rgbquad#members.
    ;* Parameter:
        ;* blue - Specifies the intensity of blue in the color.
        ;* green - Specifies the intensity of green in the color.
        ;* red - Specifies the intensity of red in the color.
    __CreateRGBQuad(this, blue := 0, green := 0, red := 0) {
        (structure := this(4, 0)).NumPut(0, "UChar", blue, "UChar", green, "UChar", red)
        return (structure)
    }  ;? RGBQUAD;

    ;----------------------------------------------------- CreateRect -------------;

    Buffer.Base.DefineProp("CreateRect", {Call: __CreateRect})

    ;* Buffer.CreateRect([x, y, width, height, type])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect.
    __CreateRect(this, x := 0, y := 0, width := 0, height := 0, type := "UInt") {
        if (!(type ~= "i)Float|(U?Int)")) {
            throw (ValueError("``type`` must be a valid data type.", -1, type))
        }

        (structure := this(16)).NumPut(0, type, x, type, y, type, width, type, height)
        return (structure)
    }  ;? RECT, *PRECT, *NPRECT, *LPRECT;

    ;---------------------------------------------- CreateSecurityDescriptor ------;

    Buffer.Base.DefineProp("CreateSecurityDescriptor", {Call: __CreateSecurityDescriptor})

    ;* Buffer.CreateSecurityDescriptor()
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-security_descriptor.
    __CreateSecurityDescriptor(this) {
        static cbSize := A_PtrSize*4 - (A_PtrSize == 4)*4 + 8

        structure := this(cbSize)
        return (structure)
    }  ;? SECURITY_DESCRIPTOR, *PISECURITY_DESCRIPTOR;

    ;----------------------------------------------------- CreateSize -------------;

    Buffer.Base.DefineProp("CreateSize", {Call: __CreateSize})

    ;* Buffer.CreateSize(width, height)
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/previous-versions//dd145106(v=vs.85).
    __CreateSize(this, width, height) {
        (structure := this(8)).NumPut(0, "Int", width, "Int", height)
        return (structure)
    }  ;? SIZE, *PSIZE;

    ;--------------------------------------------------  CreateSmallRect  ----------;

    Buffer.Base.DefineProp("CreateSmallRect", {Call: __CreateSmallRect})

    ;* Buffer.CreateSmallRect([x, y, width, height])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/console/small-rect-str.
    __CreateSmallRect(this, x := 0, y := 0, width := 0, height := 0) {
        (structure := this(8)).NumPut(0, "Short", x, "Short", y, "Short", x + width - 1, "Short", y + height - 1)
        return (structure)
    }  ;? SMALL_RECT;

    ;-----------------------------------------------  CreateTrackMouseEvent  -------;

    Buffer.Base.DefineProp("CreateTrackMouseEvent", {Call: __CreateTrackMouseEvent})

    ;* Buffer.CreateTrackMouseEvent(hWnd[, dwFlags, dwHoverTime])
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-trackmouseevent.
    __CreateTrackMouseEvent(this, hWnd, dwFlags := 0x00000002, dwHoverTime := 400) {
        static cbSize := A_PtrSize*2 + 8

        (structure := this(cbSize, 0)).NumPut(0, "UInt", cbSize, "UInt", dwFlags, "Ptr", hWnd, "UInt", dwHoverTime)
        return (structure)
    }  ;? TRACKMOUSEEVENT, *LPTRACKMOUSEEVENT;

    ;-------------------------------------------------- CreateWndClassEx ----------;

    Buffer.Base.DefineProp("CreateWndClassEx", {Call: __CreateWndClassEx})

    ;* Buffer.CreateWndClassEx(style, lpfnWndProc, cbClsExtra, cbWndExtra, hInstance, hIcon, hCursor, hbrBackground, lpszMenuName, lpszClassName, hIconSm)
    ;* Description:
        ;* See https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa.
    ;* Parameter:
        ;* style - See https://docs.microsoft.com/en-us/windows/win32/winmsg/window-class-styles.
    __CreateWndClassEx(this, style, lpfnWndProc, cbClsExtra, cbWndExtra, hInstance, hIcon, hCursor, hbrBackground, lpszMenuName, lpszClassName, hIconSm) {
        static cbSize := (A_PtrSize == 8) ? (80) : (48)

        (structure := this(cbSize)).NumPut(0, "UInt", cbSize, "UInt", style, "Ptr", lpfnWndProc, "Int", cbClsExtra, "Int", cbWndExtra, "Ptr", hInstance, "Ptr", hIcon, "Ptr", hCursor, "Ptr", hbrBackground, "Ptr", lpszMenuName, "Ptr", lpszClassName, "Ptr", hIconSm)
        return (structure)
    }  ;? WNDCLASSEXA, *PWNDCLASSEXA, *NPWNDCLASSEXA, *LPWNDCLASSEXA;

    ;=====================================================  Prototype  =============;
    ;------------------------------------------------------- NumPut ---------------;

    Buffer.Prototype.DefineProp("NumPut", {Call: __NumPut})

    ;* buffer.NumPut(offset, type1, number1[, type2, number2, ...])
    __NumPut(this, offset, params*) {
        if (!(IsInteger(offset) && offset >= 0)) {
            throw (ValueError("``offset`` must be a non negative integer.", -1, offset))
        }

        pointer := this.Ptr

        loop (params.Length/2) {
            index := (A_Index - 1)*2
                , type := params[index], value := params[index + 1]

            if (type = "Buffer") {  ;* Not case-sensitive.
                if (value.__Class != "Buffer") {
                    throw (TypeError("``type`` does not match the variable.", -1, value.__Class))
                }

                size := value.Size, limit := this.Size - offset
                    , bytes := (size > limit) ? (limit) : (size)  ;* Ensure that there is capacity left after accounting for the offset. It is entirely possible to insert a type that exceeds 2 bytes in size into the last 2 bytes of this struct's memory however, thereby corrupting the value.

                if (bytes) {
                    DllCall("NtDll\RtlCopyMemory", "Ptr", pointer + offset, "Ptr", value.Ptr, "Ptr", bytes), offset += bytes
                }
            }
            else {
                if (!(type ~= "i)(U?Char)|(U?Short)|(U?Int)|Float|(U?Int64)|(U?Ptr)|Double")) {
                    throw (ValueError("``type`` must be a valid data type.", -1, type))
                }

                size := SizeOf(type), limit := this.Size - offset
                    , bytes := (size > limit) ? (limit) : (size)

                if (!(bytes - size)) {
                    NumPut(type, value, pointer, offset), offset += bytes
                }
            }
        }

        return (offset)  ;* Similar to `array.Push()` returning the new length.
    }

    ;------------------------------------------------------- NumGet ---------------;

    Buffer.Prototype.DefineProp("NumGet", {Call: __NumGet})

    ;* buffer.NumGet(offset, type[, bytes])
    __NumGet(this, offset, type, bytes := 0) {
        if (!(IsInteger(offset) && offset >= 0)) {
            throw (ValueError("``offset`` must be a non negative integer.", -1, offset))
        }

        if (type ~= "i)Buffer") {  ;* Create and return a new struct from a slice of another.
            if (!(IsInteger(bytes) && bytes >= 0)) {
                throw (ValueError("``bytes`` must be a non negative integer.", -1, bytes))
            }

            if (offset + bytes >= this.Size) {
                throw (MemoryError(Format("``offset`` ({}) + ``bytes`` ({}) exceeds the size the buffer ({}).", offset, bytes, this.Size), -1))
            }

            DllCall("NtDll\RtlCopyMemory", "Ptr", (instance := Buffer(bytes)).Ptr, "Ptr", this.Ptr + offset, "Ptr", bytes)
            return (instance)
        }
        else {
            if (!(type ~= "i)(U?Char)|(U?Short)|(U?Int)|Float|(U?Int64)|(U?Ptr)|Double")) {
                throw (ValueError("``type`` must be a valid data type.", -1, type))
            }

            return (NumGet(this.Ptr + offset, type))
        }
    }

    ;------------------------------------------------------- StrGet ---------------;

    Buffer.Prototype.DefineProp("StrGet", {Call: __StrGet})

    ;* buffer.StrGet([length, encoding])
    __StrGet(this, length?, encoding := "CP0") {
        if (IsSet(length)) {
            return (StrGet(this.Ptr, length, encoding))
        }

        return (StrGet(this.Ptr))
    }

    ;----------------------------------------------------- ZeroMemory -------------;

    Buffer.Prototype.DefineProp("ZeroMemory", {Call: __ZeroMemory})

    ;* buffer.ZeroMemory([bytes])
    __ZeroMemory(this, bytes := 0) {
        DllCall("Ntdll\RtlZeroMemory", "Ptr", this.Ptr, "Ptr", (bytes) ? ((bytes > (size := this.Size)) ? (size) : (bytes)) : (this.Size))
    }
}

;---------------  Other  -------------------------------------------------------;

;* BufferFromArray(array[, type])
BufferFromArray(array, type := "UInt") {
    if (array.__Class != "Array") {
        throw (TypeError("``array`` must be an array.", -1, array.__Class))
    }

    if (!(type ~= "i)(U?Char)|(U?Short)|(U?Int)|Float|(U?Int64)|(U?Ptr)|Double")) {
        throw (ValueError("``type`` must be a valid data type.", -1, type))
    }

    size := SizeOf(type)
        , pointer := (instance := Buffer(array.Length*size)).Ptr

    for index, value in array {
        NumPut(type, value, pointer + size*index)
    }

    return (instance)
}

/**
 * Creates a new buffer instance with the data from any number of buffer objects concatenated into it.
 * @param {...Buffer} [structs] - Buffer instance(s) from which to copy data.
 * @return {Buffer}
 */
BufferFromBuffer(structs*) {
    if (!structs.Every((value, *) => (value.__Class == "Buffer"))) {
        throw (TypeError("``structs`` must all be an instance of Buffer.", -1))
    }

    for struct in (bytes := 0, structs) {
        bytes += struct.Size
    }

    for struct in (pointer := (instance := Buffer(bytes)).Ptr, structs) {
        DllCall("NtDll\RtlCopyMemory", "Ptr", pointer, "Ptr", struct.Ptr, "Ptr", size := struct.Size), pointer += size
    }

    return (instance)
}
