;==============  Include  ======================================================;

#Include, %A_LineFile%\..\ObjectOriented\ObjectOriented.ahk
#Include, %A_LineFile%\..\Structure\Structure.ahk

;============== Function ======================================================;

;* FormatMessage(messageID)
FormatMessage(messageID) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage
	if (!length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr", (buffer := new Structure(A_PtrSize)).Pointer, "UInt", 0, "UInt*", 0, "UInt")) {
		return (FormatMessage(DllCall("Kernel32\GetLastError")))
	}

	return (StrGet(buffer.NumGet(0, "Ptr"), length - 2))  ;* Account for the newline and carriage return characters.
}

;* Type(variable)
Type(variable) {  ;: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2306
    if (IsObject(variable)) {
		Static RegExMatchObject := NumGet(&(m, RegExMatch("", "O)", m))), BoundFuncObject := NumGet(&(f := Func("Func").Bind())), FileObject := NumGet(&(f := FileOpen("*", "w"))), EnumeratorObject := NumGet(&(e := ObjNewEnum({}))), hHeap := DllCall("GetProcessHeap", "Ptr")

        return ((ObjGetCapacity(variable) != "") ? (RegExReplace(variable.__Class, "S)(.*?\.|__)(?!.*?\..*?)")) : ((IsFunc(variable)) ? ("FuncObject") : ((ComObjType(variable) != "") ? ("ComObject") : ((NumGet(&variable) == BoundFuncObject) ? ("BoundFuncObject ") : ((NumGet(&variable) == RegExMatchObject) ? ("RegExMatchObject") : ((NumGet(&variable) == FileObject) ? ("FileObject") : ((NumGet(&variable) == EnumeratorObject) ? ("EnumeratorObject") : ("Property"))))))))
	}

	if (InStr(variable, ".")) {
		variable := variable + 0  ;* Account for floats being treated as strings as they're stored in the string buffer.
	}

    return ([variable].GetCapacity(0) != "") ? ("String") : ((InStr(variable, ".")) ? ("Float") : ("Integer"))
}