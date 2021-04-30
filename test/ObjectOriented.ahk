;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#NoEnv
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox

Process, Priority, , Normal
SetTitleMatchMode, 2

;======================================================== Test ================;

Assert.SetGroup("Function")  ;--------- Function ------------------------------;

For i, v in [[[10], "[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]"], [[1, 20], "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]"], [[5, 20], "[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]"], [[0, 30, 3], "[0, 3, 6, 9, 12, 15, 18, 21, 24, 27]"], [[0, 50, 5], "[0, 5, 10, 15, 20, 25, 30, 35, 40, 45]"], [[2, 25, 2], "[2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]"], [[0, 30, 4], "[0, 4, 8, 12, 16, 20, 24, 28]"], [[15, 25, 3], "[15, 18, 21, 24]"], [[25, 2, -2], "[25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3]"], [[30, 1, -4], "[30, 26, 22, 18, 14, 10, 6, 2]"], [[25, -6, -3], "[25, 22, 19, 16, 13, 10, 7, 4, 1, -2, -5]"]] {
	Assert.IsEqual((Range(v[0, 0], v[0, 1], Round(v[0, 2] - 1) + 1).Print()), v[1])
}  ;---------------------------------------------------------  Range  ----------;

Assert.SetGroup("Property")  ;--------- Property ------------------------------;

Assert.SetLabel("Count")  ;----------------------------------  Count  ----------;
Assert.IsEqual([1, 2, , 4].Count, 3)
Assert.IsEqual([0].Count, 1)
Assert.IsEqual([""].Count, 0)

Assert.SetLabel("Length")  ;--------------------------------- Length ----------;
array := [1, , 3]
Assert.IsEqual(array.Length, 3)
array.Length := 5
Assert.IsEqual(array.Print(), "[1, """", 3, """", """"]")
Assert.IsEqual(array.Length, 5)

Assert.SetGroup("Method")  ;---------- Method ---------------------------------;

Assert.SetLabel("Compact")  ;-------------------------------  Compact  ---------;
Assert.IsEqual([0, [0, 0], 0, 0].Compact(1).Print(), "[[]]")
Assert.IsEqual([0, [0, 0], 0, 0].Compact(0).Print(), "[[0, 0]]")
Assert.IsEqual([0, 0, 0, 0, 0].Compact().Print(), "[]")

Assert.SetLabel("Empty")  ;----------------------------------  Empty  ----------;
array1 := array2 := [1, 2]
array1.Empty()
Assert.IsEqual(array1.Print(), array2.Print())

Assert.SetLabel("Swap")  ;------------------------------------ Swap -----------;
Assert.IsEqual([{1.1: ".10", 1.2: ".2"}, [2], 3, , 5].Swap(0, 4).Print(), "[5, [2], 3, """", {1.1: .1, 1.2: .2}]")
Assert.IsEqual([1, 2, 3].Swap(2, 5).Print(), "[1, 2, 3]")

Assert.SetLabel("Concat")  ;--------------------------------- Concat ----------;
array := [[2, 3], [4, 5, 6], [8, 9, 10]]
Assert.IsEqual([1].Concat(array[0], array[1], 7, array[2]).Print(), "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]")
Assert.IsEqual([1].Concat([2], [], {3: "Three"}, [[4]], , 6).Print(), "[1, 2, {3: ""Three""}, [4], """", 6]")

;! *** CopyWithin()

;! *** Entries()

Assert.SetLabel("Every")  ;----------------------------------  Every  ----------;
array := [1, 30, 39, 29, 10, 13]
Assert.IsTrue(array.Every(Func("Every")))
array.Push(40)
Assert.IsFalse(array.Every(Func("Every")))

Assert.SetLabel("Fill")  ;------------------------------------ Fill -----------;
array := [1, 2, 3, 4]
Assert.IsEqual(array.Fill(0).Print(), "[0, 0, 0, 0]")
Assert.IsEqual(array.Fill(1, -3, -1).Print(), "[0, 1, 1, 0]")
Assert.IsEqual(array.Fill(0, 2, 4).Fill(5, 1).Fill(6).Print(), "[6, 6, 6, 6]")
array.Fill({})[0].key := "value"
Assert.IsEqual(array.Print(), "[{key: ""value""}, {key: ""value""}, {key: ""value""}, {key: ""value""}]")

Assert.SetLabel("Filter")  ;--------------------------------- Filter ----------;
Assert.IsEqual(["Spray", "Limit", "Elite", "Exuberant", "Destruction", "Present"].Filter(Func("Filter")).Print(), "[""Exuberant"", ""Destruction"", ""Present""]")
Assert.IsEqual([4, 6, 8, 9, 12, 53, -17, 2, 5, 7, 31, 97, -1, 17].Filter(Func("IsPrime")).Print(), "[53, 2, 5, 7, 31, 97, 17]")

Assert.SetLabel("Find")  ;------------------------------------ Find -----------;
array := [5, 12, 8, 130, 44]
Assert.IsEqual(array.Find(Func("Find")), 12)

Assert.SetLabel("FindIndex")  ;----------------------------  FindIndex  --------;
Assert.IsEqual([5, 12, 8, 130, 44].FindIndex(Func("FindIndex")), 3)

Assert.SetLabel("Flat")  ;------------------------------------ Flat -----------;
Assert.IsEqual([1, 2, , 3, [[4]], [5]].Flat().Print(), "[1, 2, 3, [4], 5]")
Assert.IsEqual([1, 2, [3, 4]].Flat().Print(), "[1, 2, 3, 4]")
Assert.IsEqual([1, 2, [3, 4, [5, 6]]].Flat().Print(), "[1, 2, 3, 4, [5, 6]]")
Assert.IsEqual([1, 2, [3, 4, [5, 6]]].Flat(2).Print(), "[1, 2, 3, 4, 5, 6]")
Assert.IsEqual([1, 2, [{3: "Three"}, , [4, 5, [6, 7, [8, [[[[9]]]]]]]]].Flat(5000).Print(), "[1, 2, {3: ""Three""}, 4, 5, 6, 7, 8, 9]")

;! *** FlatMap

Assert.SetLabel("ForEach")  ;-------------------------------  ForEach  ---------;
array := [1, 3, , 7]
array.ForEach(Func("ForEach"))
Assert.IsEqual(array.Print(), "[0, 2, """", 6]")

Assert.SetLabel("Includes")  ;------------------------------ Includes ---------;
array := [1, 2, 3]
Assert.IsFalse(array.Includes("3", 3))
Assert.IsFalse(array.Includes("3", 100))
Assert.IsTrue(array.Includes("1", -10))
Assert.IsFalse(array.Includes("1", -2))
array[1] := ""
Assert.IsTrue(array.Includes(""))
Assert.IsFalse(["red", "Green", "bLUe"].Includes("Blue"))

Assert.SetLabel("IndexOf")  ;-------------------------------  IndexOf  ---------;
array := ["ant", "bison", "camel", "", "bison"]
Assert.IsEqual(array.IndexOf("bison"), 1)
Assert.IsEqual(array.IndexOf("bison", 2), 4)
Assert.IsEqual(array.IndexOf("Marco"), -1)

Assert.SetLabel("Join")  ;------------------------------------ Join -----------;
array := [1, "", "3", , "Five"]
Assert.IsEqual(array.Join(" + "), "1 +  + 3 +  + Five")
Assert.IsEqual(array.Join(""), "13Five")

;! *** Keys

Assert.SetLabel("LastIndexOf")  ;-------------------------  LastIndexOf  -------;
array := [2, 5, 9, 2, , 1]
Assert.IsEqual(array.LastIndexOf(2), 3)
Assert.IsEqual(array.LastIndexOf(7), -1)
Assert.IsEqual(array.LastIndexOf(2, 3), 3)
Assert.IsEqual(array.LastIndexOf(2, 2), 0)
Assert.IsEqual(array.LastIndexOf(2, -4), 0)
Assert.IsEqual(array.LastIndexOf(2, -1), 3)

Assert.SetLabel("Map")  ;-------------------------------------  Map  -----------;
array := [1, 4, 9, 16]
Assert.IsEqual(array.Map(Func("Map")).Print(), "[2, 8, 18, 32]")
Assert.IsEqual(array.Print(), "[1, 4, 9, 16]")

Assert.SetLabel("Pop")  ;-------------------------------------  Pop  -----------;
array := ["broccoli", "cauliflower"]
Assert.IsEqual(array.Pop(), "cauliflower")
Assert.IsEqual(array.Print(), "[""broccoli""]")
array.Pop()
Assert.IsEqual(array.Print(), "[]")

Assert.SetLabel("Push")  ;------------------------------------ Push -----------;
array := ["pigs", "goats", "sheep"]
Assert.IsEqual(array.Push(, ["cows", , "horses"]), 5)
Assert.IsEqual(array.Print(), "[""pigs"", ""goats"", ""sheep"", """", [""cows"", """", ""horses""]]")

;! *** Reduce

;! *** ReduceRight

Assert.SetLabel("Reverse")  ;-------------------------------  Reverse  ---------;
array := ["One", "Two", "Three", , 5]
Assert.IsEqual(array.Reverse().Print(), "[5, """", ""Three"", ""Two"", ""One""]")
Assert.IsEqual(array.Print(), "[5, """", ""Three"", ""Two"", ""One""]")

Assert.SetLabel("Shift")  ;----------------------------------  Shift  ----------;
array := ["1", 2, "Three", , 5]
Assert.IsEqual(array.Shift(), 1)
Assert.IsEqual(array.Print(), "[2, ""Three"", """", 5]")
(array := [5]).Shift()
Assert.IsEqual(array.Print(), "[]")

Assert.SetLabel("Slice")  ;----------------------------------  Slice  ----------;
array := ["ant", "bison", "camel", "duck", "elephant"]
Assert.IsEqual(array.slice(2).Print(), "[""camel"", ""duck"", ""elephant""]")
Assert.IsEqual(array.slice(2, 4).Print(), "[""camel"", ""duck""]")
Assert.IsEqual(array.slice(1, 5).Print(), "[""bison"", ""camel"", ""duck"", ""elephant""]")
Assert.IsEqual(array.slice(-1).Print(), "[""elephant""]")

Assert.SetLabel("Some")  ;------------------------------------ Some -----------;
Assert.IsTrue([1, 2, 3, 4, 5].Some(Func("Some")))
Assert.IsFalse([1, 3, 5, 7, 9].Some(Func("Some")))

Assert.SetLabel("Sort")  ;------------------------------------ Sort -----------;
Assert.IsEqual(["March", "Jan", "Feb", "Dec"].Sort().Print(), "[""Dec"", ""Feb"", ""Jan"", ""March""]")
Assert.IsEqual([1, 30, 4, 21, 100000].Sort().Print(), "[1, 4, 21, 30, 100000]")

Assert.SetLabel("Splice")  ;--------------------------------- Splice ----------;
array := ["Jan", "March", "April", "June"]
array.Splice(1, 0, "Feb")
Assert.IsEqual(array.Print(), "[""Jan"", ""Feb"", ""March"", ""April"", ""June""]")
array.Splice(4, 1, "May")
Assert.IsEqual(array.Print(), "[""Jan"", ""Feb"", ""March"", ""April"", ""May""]")

;! *** ToLocaleString

;! *** ToSource

;! *** ToString

Assert.SetLabel("UnShift")  ;-------------------------------  UnShift  ---------;
array := [4, 5, 6]
Assert.IsEqual(array.UnShift(1, , 3), 6)
Assert.IsEqual(array.Print(), "[1, """", 3, 4, 5, 6]")

;! *** Values

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

#Include, %A_ScriptDir%\..\lib\Assert\Assert.ahk
#Include, %A_ScriptDir%\..\lib\General.ahk
#Include, %A_ScriptDir%\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\lib\ObjectOriented.ahk

;============== Function ======================================================;

IsPrime(number) {
	if (number < 2 || number != Round(number)) {
		return (0)
	}

	loop, % Floor(Sqrt(number)) {
		if (A_Index > 1 && Mod(number, A_Index) == 0) {
			return (0)
		}
	}

	return (1)
}

Every(element) {
	return (element < 40)
}

Filter(element) {
	return (StrLen(element) > 5)
}

Find(element) {
	return (element > 10)
}

FindIndex(element) {
	return (element > 12)
}

ForEach(element) {
	return (element - 1)
}

Map(element) {
	return (element*2)
}

Some(element) {
	return (Mod(element, 2) == 0)
}
