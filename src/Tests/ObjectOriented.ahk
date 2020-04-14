;=====         Auto-execute         =========================;
;===============           Settings           ===============;

#Include, %A_ScriptDir%\..\..\lib\General.ahk
#Include, %A_ScriptDir%\..\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\lib\String.ahk

#NoEnv
#SingleInstance, Force

Process, Priority, , Normal

;===============            Other             ===============;

;-----           Function           -------------------------;

;*** Range
For i, v in [[[10], "[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]"], [[1, 20], "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]"], [[5, 20], "[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]"], [[0, 30, 3], "[0, 3, 6, 9, 12, 15, 18, 21, 24, 27]"], [[0, 50, 5], "[0, 5, 10, 15, 20, 25, 30, 35, 40, 45]"], [[2, 25, 2], "[2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]"], [[0, 30, 4], "[0, 4, 8, 12, 16, 20, 24, 28]"], [[15, 25, 3], "[15, 18, 21, 24]"], [[25, 2, -2], "[25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3]"], [[30, 1, -4], "[30, 26, 22, 18, 14, 10, 6, 2]"], [[25, -6, -3], "[25, 22, 19, 16, 13, 10, 7, 4, 1, -2, -5]"]] {
	Assert("Range()", (Range(v[0, 0], v[0, 1], Round(v[0, 2] - 1) + 1).Print()), v[1])
}

;-----            Class             -------------------------;
;---------------           Property           ---------------;
;-------------------------             AHK              -----;

;*** Count
Assert(".Count", [1, 2, , 4].Count, 3)
Assert(".Count", [0].Count, 1)
Assert(".Count", [""].Count, 0)

;*** Length
Array := [1, , 3]
Assert(".Length", Array.Length, 3)
Array.Length := 5
Assert(".Length", Array.Print(), "[1, """", 3, """", """"]")
Assert(".Length", Array.Length, 5)

;---------------            Method            ---------------;
;-------------------------            Custom            -----;

;*** Empty
Array1 := Array2 := [1, 2]
Array1.Empty()
Assert(".Empty()", Array1.Print(), Array2.Print())

;*** Swap
Assert(".Swap()", [{1.1: ".1", 1.2: ".2"}, [2], 3, , 5].Swap(0, 4).Print(), "[5, [2], 3, """", {1.1: .1, 1.2: .2}]")
Assert(".Swap()", [1, 2, 3].Swap(2, 5).Print(), "[1, 2, 3]")

;-------------------------             MDN              -----;

;*** Concat
Array := [[2, 3], [4, 5, 6], [8, 9, 10]]
Assert(".Concat()", [1].Concat(Array[0], Array[1], 7, Array[2]).Print(), "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]")
Assert(".Concat()", [1].Concat([2], [], {3: "Three"}, [[4]], , 6).Print(), "[1, 2, {3: ""Three""}, [4], """", 6]")

;! *** CopyWithin()

;! *** Entries()

;*** Every
Array := [1, 30, 39, 29, 10, 13]
Assert(".Every()", Array.Every(Func("Every")), 1)
Array.Push(40)
Assert(".Every()", Array.Every(Func("Every")), 0)

;*** Fill
Array := [1, 2, 3, 4]
Assert(".Fill()", Array.Fill(0).Print(), "[0, 0, 0, 0]")
Assert(".Fill()", Array.Fill(1, -3, -1).Print(), "[0, 1, 1, 0]")
Assert(".Fill()", Array.Fill(0, 2, 4).Fill(5, 1).Fill(6).Print(), "[6, 6, 6, 6]")
Array.Fill({})[0].key := "value"
Assert(".Fill()", Array.Print(), "[{key: ""value""}, {key: ""value""}, {key: ""value""}, {key: ""value""}]")

;*** Filter
Assert(".Filter()", ["Spray", "Limit", "Elite", "Exuberant", "Destruction", "Present"].Filter(Func("Filter")).Print(), "[""Exuberant"", ""Destruction"", ""Present""]")
Assert(".Filter()", [4, 6, 8, 9, 12, 53, -17, 2, 5, 7, 31, 97, -1, 17].Filter(Func("IsPrime")).Print(), "[53, 2, 5, 7, 31, 97, 17]")

;*** Find
Array := [5, 12, 8, 130, 44]
Assert(".Find()", Array.Find(Func("Find")), "12")

;*** FindIndex
Assert(".FindIndex()", [5, 12, 8, 130, 44].FindIndex(Func("FindIndex")), "3")

;*** Flat
Assert(".Flat()", [1, 2, , 3, [[4]], [5]].Flat().Print(), "[1, 2, 3, [4], 5]")
Assert(".Flat()", [1, 2, [3, 4]].Flat().Print(), "[1, 2, 3, 4]")
Assert(".Flat()", [1, 2, [3, 4, [5, 6]]].Flat().Print(), "[1, 2, 3, 4, [5, 6]]")
Assert(".Flat()", [1, 2, [3, 4, [5, 6]]].Flat(2).Print(), "[1, 2, 3, 4, 5, 6]")
Assert(".Flat()", [1, 2, [{3: "Three"}, , [4, 5, [6, 7, [8, [[[[9]]]]]]]]].Flat(5000).Print(), "[1, 2, {3: ""Three""}, 4, 5, 6, 7, 8, 9]")

;! *** FlatMap

;*** ForEach
Array := [1, 3, , 7]
Array.ForEach(Func("ForEach"))
Assert(".ForEach()", Array.Print(), "[0, 2, """", 6]")

;*** Includes
Array := [1, 2, 3]
Assert(".Includes()", Array.Includes("3", 3), "0")
Assert(".Includes()", Array.Includes("3", 100), "0")
Assert(".Includes()", Array.Includes("1", -10), "1")
Assert(".Includes()", Array.Includes("1", -2), "0")
Array[1] := ""
Assert(".Includes()", Array.Includes(""), "1")
Assert(".Includes()", ["red", "Green", "bLUe"].Includes("Blue"), "0")

;*** IndexOf
Array := ["ant", "bison", "camel", "", "bison"]
Assert(".IndexOf()", Array.IndexOf("bison"), "1")
Assert(".IndexOf()", Array.IndexOf("bison", 2), "4")
Assert(".IndexOf()", Array.IndexOf("Marco"), "-1")

;*** Join
Array := [1, "", "3", , "Five"]
Assert(".Join()", Array.Join(" + "), "1 +  + 3 +  + Five")
Assert(".Join()", Array.Join(""), "13Five")

;! *** Keys

;*** LastIndexOf
Array := [2, 5, 9, 2, , 1]
Assert(".LastIndexOf()", Array.LastIndexOf(2), "3")
Assert(".LastIndexOf()", Array.LastIndexOf(7), "-1")
Assert(".LastIndexOf()", Array.LastIndexOf(2, 3), "3")
Assert(".LastIndexOf()", Array.LastIndexOf(2, 2), "0")
Assert(".LastIndexOf()", Array.LastIndexOf(2, -4), "0")
Assert(".LastIndexOf()", Array.LastIndexOf(2, -1), "3")

;*** Map
Array := [1, 4, 9, 16]
Assert(".Map()", Array.Map(Func("Map")).Print(), "[2, 8, 18, 32]")
Assert(".Map()", Array.Print(), "[1, 4, 9, 16]")

;*** Pop
Array := ["broccoli", "cauliflower"]
Assert(".Pop()", Array.Pop(), "cauliflower")
Assert(".Pop()", Array.Print(), "[""broccoli""]")
Array.Pop()
Assert(".Pop()", Array.Print(), "[]")

;*** Push
Array := ["pigs", "goats", "sheep"]
Assert(".Push()", Array.Push(, ["cows", , "horses"]), "5")
Assert(".Push()", Array.Print(), "[""pigs"", ""goats"", ""sheep"", """", [""cows"", """", ""horses""]]")

;! *** Reduce

;! *** ReduceRight

;*** Reverse
Array := ["One", "Two", "Three", , 5]
Assert(".Reverse()", Array.Reverse().Print(), "[5, """", ""Three"", ""Two"", ""One""]")
Assert(".Reverse()", Array.Print(), "[5, """", ""Three"", ""Two"", ""One""]")

;*** Shift
Array := ["1", 2, "Three", , 5]
Assert(".Shift()", Array.Shift(), "1")
Assert(".Shift()", Array.Print(), "[2, ""Three"", """", 5]")
(Array := [5]).Shift()
Assert(".Shift()", Array.Print(), "[]")

;*** Slice
Array := ["ant", "bison", "camel", "duck", "elephant"]
Assert(".Slice()", Array.slice(2).Print(), "[""camel"", ""duck"", ""elephant""]")
Assert(".Slice()", Array.slice(2, 4).Print(), "[""camel"", ""duck""]")
Assert(".Slice()", Array.slice(1, 5).Print(), "[""bison"", ""camel"", ""duck"", ""elephant""]")
Assert(".Slice()", Array.slice(-1).Print(), "[""elephant""]")

;*** Some
Assert(".Some()", [1, 2, 3, 4, 5].Some(Func("Some")), 1)
Assert(".Some()", [1, 3, 5, 7, 9].Some(Func("Some")), 0)

;*** Sort
Assert(".Sort()", ["March", "Jan", "Feb", "Dec"].Sort().Print(), "[""Dec"", ""Feb"", ""Jan"", ""March""]")
Assert(".Sort()", [1, 30, 4, 21, 100000].Sort().Print(), "[1, 4, 21, 30, 100000]")

;*** Splice
Array := ["Jan", "March", "April", "June"]
Array.Splice(1, 0, "Feb")
Assert(".Splice()", Array.Print(), "[""Jan"", ""Feb"", ""March"", ""April"", ""June""]")
Array.Splice(4, 1, "May")
Assert(".Splice()", Array.Print(), "[""Jan"", ""Feb"", ""March"", ""April"", ""May""]")

;! *** ToLocaleString

;! *** ToSource

;! *** ToString

;*** UnShift
Array := [4, 5, 6]
Assert(".UnShift()", Array.UnShift(1, , 3), "6")
Assert(".UnShift()", Array.Print(), "[1, """", 3, 4, 5, 6]")

;! *** Values

MsgBox("Finished.")

ExitApp

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#IF

;=====           Function           =========================;

Assert(vFunction, vQuery, vResult) {
	If (vQuery != vResult) {
		MsgBox(vFunction . ": " . vQuery . " != " . vResult)
	}
}

IsPrime(_Number) {
	If (_Number < 2 || _Number != Round(_Number))
		Return, (0)

	Loop, % Floor(Sqrt(_Number))
		If (A_Index > 1 && Mod(_Number, A_Index) == 0)
			Return, (0)

	Return, (1)
}

Every(vElement) {
	Return, (vElement < 40)
}

Filter(vElement) {
	Return, (StrLen(vElement) > 5)
}

Find(vElement) {
	Return, (vElement > 10)
}

FindIndex(vElement) {
	Return, (vElement > 12)
}

ForEach(vElement) {
	Return, (vElement - 1)
}

Map(vElement) {
	Return, (vElement*2)
}

Some(vElement) {
	Return, (Mod(vElement, 2) == 0)
}