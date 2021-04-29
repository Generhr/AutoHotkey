;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#NoEnv
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox

Process, Priority, , Normal
SetTitleMatchMode, 2

;======================================================== Test ================;

Assert.SetLabel("001")
primary := Primary(Header(1, 2), Body(3, 4, 5, 6))  ;* Create a struct by combining two other structs.
loop, % (size := primary.Size)//4 {
	contents001 .= NumGet(primary.Pointer + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents001, "1, 2, 3, 4, 5, 6")  ;* Test that all the data from the other structs was copied.

Assert.SetLabel("002")
primary.NumPut(0, "Struct", Body(3, 4, 5, 6))  ;* Insert an entire struct at offset 0.
loop, % (size := primary.Size)//4 {
	contents002 .= NumGet(primary.Pointer + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents002, "3, 4, 5, 6, 5, 6")  ;* Test that all the data from the other struct was inserted.

Assert.SetLabel("003")
primary.NumPut(20, "Int", 1)  ;* Attempt to insert an "Int" (4 bytes) value of 1 at offset 20.
loop, % (size := primary.Size)//4 {
	contents003 .= NumGet(primary.Pointer + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents003, "3, 4, 5, 6, 5, 1")  ;* Test that the value was inserted.

Assert.SetLabel("004")
primary.NumPut(24, "Int", 1)  ;* Attempt to insert an "Int" (4 bytes) value at offset 24 but that points to memory beyond this struct's size.
Assert.IsNotEqual(primary.NumGet(24, "Int"), "1")  ;* Test that the 4	 bytes of memory at offset 24 are unaffected.

Assert.SetLabel("005")
primary.NumPut(12, "Struct", Body(3, 4, 5, 6))  ;* Attempt to insert an entire struct at offset 12 but doing so would affect memory beyond this struct's size.
Assert.IsNotEqual(primary.NumGet(24, "Int"), "6")  ;* Test that the insertion is truncated and the 4 bytes of memory at offset 24 are unaffected.

Assert.SetLabel("006")
primary := primary.NumGet(4, "Struct", 8)  ;* Create a new struct from a slice of another.
loop, % (size := primary.Size)//4 {
	contents006 .= NumGet(primary.Pointer + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents006, "4, 5")

Assert.SetLabel("007")
primary := primary.NumGet(8, "Struct", 4)  ;* Cannot create a slice from memory not part of another structure.
loop, % (size := primary.Size)//4 {
	contents007 .= NumGet(primary.Pointer + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsNull(contents007)  ;* Test that null is returned.

Assert.SetLabel("008")
primary := new Structure(8, 1)  ;* Create a new struct with the HEAP_ZERO_MEMORY flag.
loop, % (size := primary.Size)//4 {
	contents008 .= NumGet(primary.Pointer + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents008, "0, 0")  ;* Test that the values are 0.

Assert.SetLabel("009")
primary.NumPut(0, "Int", 1, "Int", 1)
primary.ZeroMemory(12)  ;* Give `ZeroMemory()` a length greater than this structure's size (this will cause a critical error without handling).
loop, % (size := primary.Size)//4 {
	contents009 .= NumGet(primary.Pointer + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents009, "0, 0")  ;* Test that 0s were inserted.
Assert.SetLabel("010")
Assert.IsNotEqual(primary.NumGet(8, "Int"), "0")  ;* Test that the memory at offset 8 is unaffected.

Assert.Report()

exit

;=============== Hotkey =======================================================;

#If (WinActive(A_ScriptName))

	~*$Esc::
		ExitApp
		return

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

;==============  Include  ======================================================;

#Include, <Assert>
#Include, <Structure>

;============== Function ======================================================;

Header(number1, number2) {
	(header := new Structure(8)).NumPut(0, "Int", number1, "Int", number2)

	return (header)
}

Body(number1, number2, number3, number4) {
	(body := new Structure(16)).NumPut(0, "Int", number1, "Int", number2, "Int", number3, "Int", number4)

	return (body)
}

Primary(header, body) {
	return (new Structure(header, body))
}
