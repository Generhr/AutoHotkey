;============== Function ======================================================;
 
;* CreateCursorInfo()
;* Description:
	;* Contains global cursor information.
CreateCursorInfo(flags := 0, cursor := 0, screenPos := 0) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-cursorinfo
	if (!screenPos) {
		screenPos := CreatePoint()
	}

	(s := new Structure(16 + A_PtrSize)).NumPut(0, "UInt", 16 + A_PtrSize, "UInt", flags, "Ptr", cursor, "UInt", screenPos, "Struct", screenPos)

    return (s)
}  ;? CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

;* CreateSecurityDescriptor()
;* Description:
	;* The SECURITY_DESCRIPTOR structure contains the security information associated with an object. Applications use this structure to set and query an object's security status.
CreateSecurityDescriptor() {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-security_descriptor
	s := new Structure(8 + A_PtrSize*4 - 4*(A_PtrSize == 4), 1)

    return (s)
}  ;? SECURITY_DESCRIPTOR, *PISECURITY_DESCRIPTOR;

;* CreateConsoleReadConsoleControl(initialChars, ctrlWakeupMask, controlKeyState)
;* Description:
	;* Contains information for a console read operation.
;* Parameters:
	;* ctrlWakeupMask
		;* *: https://www.asciitable.com/
CreateConsoleReadConsoleControl(initialChars := 0, ctrlWakeupMask := 0x0A, controlKeyState := 0) {  ;: https://docs.microsoft.com/en-us/windows/console/console-readconsole-control
	(s := new Structure(16)).NumPut(0, "UInt", 16, "UInt", initialChars, "UInt", ctrlWakeupMask, "UInt", controlKeyState)

    return (s)
}  ;? CONSOLE_READCONSOLE_CONTROL, *PCONSOLE_READCONSOLE_CONTROL;

;* CreateSmallRect((x), (y), (width), (height))
;* Description:
	;* Defines the coordinates of the upper left and lower right corners of a rectangle.
CreateSmallRect(x := 0, y := 0, width := 0, height := 0) {  ;: https://docs.microsoft.com/en-us/windows/console/small-rect-str
	(s := new Structure(8)).NumPut(0, "Short", x, "Short", y, "Short", x + width - 1, "Short", y + height - 1)

    return (s)
}  ;? SMALL_RECT;

;* CreateCoord((x), (y))
;* Description:
	;* Defines the coordinates of a character cell in a console screen buffer. The origin of the coordinate system (0,0) is at the top, left cell of the buffer.
CreateCoord(x := 0, y := 0) {  ;: https://docs.microsoft.com/en-us/windows/console/coord-str
	(s := new Structure(4)).NumPut(0, "Short", x, "Short", y)

	Static f := Func("NumGet")
	p := s.Pointer
		, s.Fields := {"x": f.Bind(p, 0, "Short"), "y": f.Bind(p, 2, "Short")}

    return (s)
}  ;? COORD, *PCOORD;

;* CreatePoint((x), (y), (type))
;* Description:
	;* The POINT structure defines the x- and y-coordinates of a point.
CreatePoint(x := 0, y := 0, type := "UInt") {  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-point
	b := Structure.ValidateType(type)
		, (s := new Structure(b*2)).NumPut(0, type, x, type, y)

	Static f := Func("NumGet")
	p := s.Pointer
		, s.Fields := {"x": f.Bind(p, 0, type), "y": f.Bind(p, b, type)}

    return (s)
}  ;? POINT, *PPOINT, *NPPOINT, *LPPOINT;

;* CreateRect((x), (y), (width), (height), (type))
;* Description:
	;* The RECT structure defines a rectangle by the coordinates of its upper-left and lower-right corners.
CreateRect(x := 0, y := 0, width := 0, height := 0, type := "UInt") {  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect
	b := Structure.ValidateType(type)
		, (s := new Structure(b*4)).NumPut(0, type, x, type, y, type, width, type, height)

	Static f := Func("NumGet")
	p := s.Pointer
		, s.Fields := {"x": f.Bind(p, 0, type), "y": f.Bind(p, b, type), "width": f.Bind(p, b*2, type), "height": f.Bind(p, b*3, type)}

	return (s)
}  ;? RECT, *PRECT, *NPRECT, *LPRECT;

;* CreateBitmapData((width), (height), (stride), (pixelFormat), (scan0))
;* Description:
	;* The BitmapData class stores attributes of a bitmap.
CreateBitmapData(width := 0, height := 0, stride := 0, pixelFormat := 0x26200A, scan0 := 0) {  ;: https://docs.microsoft.com/en-us/previous-versions/ms534421(v=vs.85)
	(s := new Structure(16 + 2*A_PtrSize, 1)).NumPut(0, "UInt", width, "UInt", height, "Int", stride, "Int", pixelFormat, "Ptr", scan0)

	return (s)
}  ;? BITMAPDATA;

;* CreateBitmapInfo([BITMAPINFOHEADER] bmiHeader, [RGBQUAD] bmiColors)
;* Description:
	;* The BITMAPINFO structure defines the dimensions and color information for a DIB.
CreateBitmapInfo(bmiHeader, bmiColors) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfo
	return (new Structure(bmiHeader, bmiColors))
}  ;? BITMAPINFO, *LPBITMAPINFO, *PBITMAPINFO;

;* CreateBitmapInfoHeader(width, height, (bitCount), (compression), (sizeImage), (xPelsPerMeter), (yPelsPerMeter), (clrUsed), (clrImportant))
;* Description:
	;* The BITMAPINFOHEADER structure contains information about the dimensions and color format of a DIB.
CreateBitmapInfoHeader(width, height, bitCount := 32, compression := 0x0000, sizeImage := 0, xPelsPerMeter := 0, yPelsPerMeter := 0, clrUsed := 0, clrImportant := 0) {  ;: https://docs.microsoft.com/en-us/previous-versions/dd183376(v=vs.85)
	(s := new Structure(40)).NumPut(0, "UInt", 40, "Int", width, "Int", height, "UShort", 1, "UShort", bitCount, "UInt", compression, "UInt", sizeImage, "Int", xPelsPerMeter, "Int", yPelsPerMeter, "UInt", biClrUsed, "UInt", clrImportant)

	return (s)
}  ;? BITMAPINFOHEADER, *PBITMAPINFOHEADER;

;* CreateBlendFunction((sourceConstantAlpha), (alphaFormat))
;* Description:
	;* The BLENDFUNCTION structure controls blending by specifying the blending functions for source and destination bitmaps.
CreateBlendFunction(sourceConstantAlpha := 255, alphaFormat := 1) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-blendfunction, https://www.teamdev.com/downloads/jniwrapper/winpack/javadoc/constant-values.html#com.jniwrapper.win32.gdi.BlendFunction.AC_SRC_OVER
	(s := new Structure(4, 1)).NumPut(2, "UChar", sourceConstantAlpha, "UChar", alphaFormat)  ;* ** When the AlphaFormat member is AC_SRC_ALPHA, the source bitmap must be 32 bpp. If it is not, the AlphaBlend function will fail. **

	return (s)
}  ;? BLENDFUNCTION, *PBLENDFUNCTION;

;* CreateRGBQuad((rgbBlue), (rgbGreen), (rgbRed))
;* Description:
	;* The RGBQUAD structure describes a color consisting of relative intensities of red, green, and blue.
CreateRGBQuad(blue := 0, green := 0, red := 0) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-rgbquad#members
	(s := new Structure(4, 1)).NumPut(0, "UChar", blue, "UChar", green, "UChar", red)

	return (s)
}  ;? RGBQUAD;

;* CreateSize(width, height)
;* Description:
	;* The SIZE structure specifies the width and height of a rectangle.
CreateSize(width, height) {  ;: https://docs.microsoft.com/en-us/previous-versions//dd145106(v=vs.85)
	(s := new Structure(8)).NumPut(0, "Int", width, "Int", height)

	Static f := Func("NumGet")
	p := s.Pointer
		, s.Fields := {"Width": f.Bind(p, 0, "Int"), "Height": f.Bind(p, 4, "Int")}

	return (s)
}  ;? SIZE, *PSIZE;

;===============  Class  =======================================================;

Class Structure {
	Static Heap := DllCall("Kernel32\GetProcessHeap", "Ptr")
		, ThrowException := 1

	;* new Structure(struct*)
	;* new Structure(bytes, (zeroFill))
	__New(params*) {
		Local

		if (RegExReplace(params[1].__Class, "S).*?\.(?!.*?\..*?)") == "__Structure") {
			bytes := 0

			for i, struct in params {
				bytes += struct.Size  ;* Calculate the total size for all structures being added.
			}

			for i, struct in (params, pointer := DllCall("Kernel32\HeapAlloc", "Ptr", this.Heap, "UInt", 0, "Ptr", bytes, "Ptr"), offset := 0) {
				size := struct.Size

				DllCall("Ntdll\RtlCopyMemory", "Ptr", pointer + offset, "Ptr", struct.Pointer, "Ptr", size), offset += size  ;* Copy the data to the new address and offset the pointer to the next byte in this structure.
			}
		}
		else {
			bytes := params[1]

			if (!bytes == Round(bytes) && bytes >= 0) {
				throw, (Exception("Invalid Assignment", -1, Format("""{}"" is invalid. This value must be a non negative integer.", bytes)))
			}

			pointer := DllCall("Kernel32\HeapAlloc", "Ptr", this.Heap, "UInt", (params[2]) ? (0x00000008) : (0), "Ptr", bytes, "Ptr")  ;* ** Heap allocations made by calling the malloc and HeapAlloc functions are non-executable. **
		}

		return ({"Pointer": pointer

			, "Base": this.__Structure})
	}

	SizeOf(type) {
		Static sizeLookup := {"Char": 1, "UChar": 1, "Short": 2, "UShort": 2, "Float": 4, "Int": 4, "UInt": 4, "Int64": 8, "UInt64": 8, "Ptr": A_PtrSize, "UPtr": A_PtrSize}

		return (sizeLookup[type])
	}

	ValidateType(type) {
		if (!b := this.SizeOf(type)) {
			throw
		}

		return (b)
	}

	Class __Structure {

		__Delete() {
			DllCall("Kernel32\HeapFree", "Ptr", Structure.Heap, "UInt", 0, "Ptr", this.Pointer, "UInt")
		}

		__Get(key) {
			if (!(key == "Size" || key == "Ptr")) {
				return (ObjRawGet(this, "Fields")[key].Call())
			}
		}

		Ptr[] {
			Get {
				return (this.Pointer)
			}
		}

		Size[zero := 0] {
			Get {
				return (DllCall("Kernel32\HeapSize", "Ptr", Structure.Heap, "UInt", 0, "Ptr", this.Pointer, "Ptr"))
			}

			Set {
				if (!p := DllCall("Kernel32\HeapReAlloc", "Ptr", Structure.Heap, "UInt", (zero) ? (0x00000008) : (0), "Ptr", this.Pointer, "Ptr", value, "Ptr")) {
					throw, (Exception("Critical Failue", -1, Format("Kernel32\HeapReAlloc failed to allocate memory.")))
				}

				this.Pointer := p  ;* ** If HeapReAlloc fails, the original memory is not freed, and the original handle and pointer are still valid. **

				return (value)
			}
		}

		NumGet(offset, type, bytes := 0) {
			if (!(offset == Round(offset) && offset >= 0)) {
				throw, (Exception("Invalid Assignment", -1, Format("""{}"" is invalid. This value must be a non negative integer.", offset)))
			}

			if (type == "Struct" && bytes == Round(bytes) && bytes >= 0) {  ;* Create and return a new struct from a slice of another.
				if (offset + bytes < this.Size) {  ;* Ensure that the memory from `offset` to `offset + bytes` is part of this struct.
					struct := new Structure(bytes)
					DllCall("Ntdll\RtlCopyMemory", "Ptr", struct.Pointer, "Ptr", this.Pointer + offset, "Ptr", bytes)

					return (struct)
				}

				return  ;~ No error handling.
			}

			return (NumGet(this.Pointer + offset, type))
		}

		NumPut(offset, params*) {
			if (!(offset == Round(offset) && offset >= 0)) {
				throw, (Exception("Invalid Assignment", -1, Format("""{}"" is invalid. This value must be a non negative integer.", offset)))
			}

			loop, % (params.Length()//2, pointer := this.Pointer) {
				index := A_Index*2
					, type := params[index - 1], value := params[index]

				if (type == "Struct") {
					size := value.Size, limit := this.Size - offset
						, bytes := (size > limit) ? (limit) : (size)  ;* Ensure that there is capacity left after accounting for the offset. It is entirely possible to insert a type that exceeds 2 bytes in size into the last 2 bytes of this struct's memory however, thereby corrupting the value.

					if (bytes) {
						DllCall("Ntdll\RtlCopyMemory", "Ptr", pointer + offset, "Ptr", value.Pointer, "Ptr", bytes), offset += bytes
					}
				}
				else {
					Static sizeLookup := {"Char": 1, "UChar": 1, "Short": 2, "UShort": 2, "Float": 4, "Int": 4, "UInt": 4, "Int64": 8, "UInt64": 8, "Ptr": A_PtrSize, "UPtr": A_PtrSize}
					size := sizeLookup[type], limit := this.Size - offset
						, bytes := (size > limit) ? (limit) : (size)

					if (bytes - size == 0) {
						NumPut(value, pointer + offset, type), offset += bytes
					}
				}
			}

			return (offset)  ;* Similar to `Push()` returning position of the last inserted value.
		}
		
		StrGet(length := "", encoding := "") {
			if (length) {
				return (StrGet(this.Pointer, length, encoding))
			}

			return (StrGet(this.Pointer))
		}

		ZeroMemory(bytes := 0) {
			Local

			size := this.Size
				, bytes := (bytes) ? ((bytes > size) ? (size) : (bytes)) : (this.Size)

			DllCall("Ntdll\RtlZeroMemory", "Ptr", this.Pointer, "Ptr", bytes)
		}
	}
}
