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

#Include %A_LineFile%\..\ObjectOriented\Array.ah2
#Include %A_LineFile%\..\ObjectOriented\Object.ah2
#Include %A_LineFile%\..\String\String.ah2

#Include %A_LineFile%\..\Structure\Structure.ah2

;============== Function ======================================================;
;=================================================== Error Handling ===========;

;* MessageError(messageID)
MessageError(messageID) {
	if (!(length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100  ;? 0x1100 = FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER
		, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", &(buffer := 0), "UInt", 0, "Ptr", 0, "Int"))) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
		return (MessageError(DllCall("Kernel32\GetLastError")))
	}

	message := StrGet(buffer, length - 2)  ;* Account for the newline and carriage return characters.
	DllCall("Kernel32\LocalFree", "Ptr", buffer)

	return (Error(Format("{:#x}", messageID), -1, message))
}

;======================================================  Library  ==============;

LoadLibrary(libraryName) {
	static loaded := FreeLibrary("__SuperSecretString")

	if (!loaded.HasProp(libraryName)) {
		if (!(ptr := DllCall("Kernel32\LoadLibrary", "Str", libraryName, "Ptr"))) {
			throw (MessageError(DllCall("Kernel32\GetLastError")))
		}

		loaded.%libraryName% := {Count: 0, Ptr: ptr}
	}

	loaded.%libraryName%.Count++

	return (loaded.%libraryName%.Ptr)
}

FreeLibrary(libraryName) {
	static loaded := {ComCtl32: {Ptr: DllCall("Kernel32\GetModuleHandle", "Str", "ComCtl32", "Ptr")}, Gdi32: {Ptr: DllCall("Kernel32\GetModuleHandle", "Str", "Gdi32", "Ptr")}, Kernel32: {Ptr: DllCall("Kernel32\GetModuleHandle", "Str", "Kernel32", "Ptr") }, User32: {Ptr: DllCall("Kernel32\GetModuleHandle", "Str", "User32", "Ptr")}}  ;* "User32", "Kernel32", "ComCtl32" and "Gdi32" are already loaded.

	if (libraryName == "__SuperSecretString") {
		return (loaded)
	}
	else if (Type(libraryName) == "Object") {
		if (--loaded.%libraryName := libraryName.Name%.Count) {
			return (False)
		}
	}

	if (!(libraryName ~= "i)ComCtl32|Gdi32|Kernel32|User32")) {
		if (loaded.HasProp(libraryName)) {
			loaded.DeleteProp(libraryName)
		}

		if (handle := DllCall("Kernel32\GetModuleHandle", "Str", libraryName, "Ptr")) {  ;* If the library module is already in the address space of the script's process.
			if (!DllCall("Kernel32\FreeLibrary", "Ptr", handle, "UInt")) {
				throw (MessageError(DllCall("Kernel32\GetLastError")))
			}

			return (True)
		}
	}

	return (False)
}

GetProcAddress(libraryName, functionName) {
	if (functionName == "*") {
		static library := {Call: (*) => ({Class: "Library",
			__Delete: FreeLibrary})}

		(o := library.Call()).Name := libraryName
			, p := (ptr := LoadLibrary(libraryName)) + NumGet(ptr + 0x3C, "Int") + 24

		static offset := (A_PtrSize == 4) ? (92) : (108)

		if (NumGet(p + offset, "UInt") < 1 || (ts := NumGet(p + offset + 4, "UInt") + ptr) == ptr || (te := NumGet(p + offset + 8, "UInt") + ts) == ts) {
			return (o)
		}

		loop (n := ptr + NumGet(ts + 32, "UInt"), NumGet(ts + 24, "UInt")) {
			if (p := NumGet(n + (A_Index - 1) * 4, "UInt")) {
				o.%f := StrGet(ptr + p, "CP0")% := DllCall("Kernel32\GetProcAddress", "Ptr", ptr, "AStr", f, "Ptr")

				if (SubStr(f, -1) == "W") {
					o.%SubStr(f, 1, -1)% := o.%f%
				}
			}
		}

		return (o)
	}

	return (DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", libraryName, "Ptr"), "AStr", functionName, "Ptr"))
}

;=======================================================  Ole32  ===============;

StringFromCLSID(CLSID) {
	if (DllCall("Ole32\StringFromCLSID", "Ptr", CLSID, "Ptr*", &(pointer := 0), "UInt")) {
		throw
	}

	string := StrGet(pointer)
	DllCall("Ole32\CoTaskMemFree", "Ptr", pointer)

	return (string)
}

CLSIDFromString(string) {
	if (DllCall("Ole32\CLSIDFromString", "Ptr", StrPtr(string), "Ptr", (CLSID := Structure(16).Ptr), "UInt")) {
		throw
	}

	return (CLSID)
}

;======================================================= MSVCRT ===============;

MemoryCopy(dest, src, bytes) {
	return (DllCall("msvcrt\memcpy", "Ptr", dest, "Ptr", src, "UInt", bytes))
}

MemoryMove(dest, src, bytes) {
	return (DllCall("msvcrt\memmove", "Ptr", dest, "Ptr", src, "UInt", bytes))
}

MemoryDifference(ptr1, ptr2, bytes) {
	return (DllCall("msvcrt\memcmp", "Ptr", ptr1, "Ptr", ptr2, "Int", bytes))
}
