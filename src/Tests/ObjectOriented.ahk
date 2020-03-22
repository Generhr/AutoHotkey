;=====         Auto-execute         =========================;

;===============           Settings           ===============;

#Include, %A_ScriptDir%\..\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\lib\Functions.ahk
#Include, %A_ScriptDir%\..\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\String.ahk

#NoEnv
#SingleInstance, Force

Process, Priority, , Normal

;===============            Other             ===============;

;-----          Properties          -------------------------;

;---------------             AHK              ---------------;

;*** Count
MsgBox([1, 2, , 4].Count())  ;3
MsgBox([0].Count())  ;1
MsgBox([""].Count())  ;0

;---------------             MDN              ---------------;

;*** Length
Array := [1, , 3]
MsgBox(Array.Length)  ;3
Array.Length := 5
MsgBox(Array.Print())  ;[1, "", 3, "", ""]
MsgBox(Array.Length)  ;5

;-----           Methods            -------------------------;

;---------------            Custom            ---------------;

;-------------------------           Mutator            -----;

;*** Empty
Array1 := Array2 := [1, 2]
Array1.Empty()
MsgBox(Array1.Print() " == " Array2.Print())  ;[] == []

;*** Shuffle
Array := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
MsgBox(Array.Shuffle().Print())
MsgBox(Array.Fill("", 4, 7).Shuffle().Print())

;*** Swap
MsgBox([{1.1: ".1", 1.2: ".2"}, [2], 3, , 5].Swap(0, 4).Print())  ;[5, [2], 3, , {1.1: ".1", 1.2: ".2"}]
MsgBox([1, 2, 3].Swap(2, 5).Print())  ;[1, 2, 3]

;---------------             MDN              ---------------;

;-------------------------           Accessor           -----;

;*** Concat
Array := [[2, 3], [4, 5, 6], [8, 9, 10]]
MsgBox([1].Concat(Array[0], Array[1], 7, Array[2]).Print())  ;[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
MsgBox([1].Concat([2], [], {3: "Three"}, [[4]], , 6).Print())  ;[1, 2, {3: "Three"}, [4], "", 6]

;*** Filter
MsgBox(["Spray", "Limit", "Elite", "Exuberant", "Destruction", "Present"].Filter(Func("Filter")).Print())  ;["Exuberant", "Destruction", "Present"]
MsgBox([4, 6, 8, 9, 12, 53, -17, 2, 5, 7, 31, 97, -1, 17].Filter(Func("IsPrime")).Print())  ;[53, 2, 5, 7, 31, 97, 17]

;*** Flat
MsgBox([1, 2, , 3, [[4]], [5]].Flat().Print())  ;[1, 2, 3, [4], 5]
MsgBox([1, 2, [3, 4]].Flat().Print())  ;[1, 2, 3, 4]
MsgBox([1, 2, [3, 4, [5, 6]]].Flat().Print())  ;[1, 2, 3, 4, [5, 6]]
MsgBox([1, 2, [3, 4, [5, 6]]].Flat(2).Print())  ;[1, 2, 3, 4, 5, 6]
MsgBox([1, 2, [{3: "Three"}, , [4, 5, [6, 7, [8, [[[[9]]]]]]]]].Flat(5000).Print())  ;[1, 2, {3: "Three"}, 4, 5, 6, 7, 8, 9]

;*** Includes
Array := [1, 2, 3]
MsgBox(Array.includes("3", 3))  ;0
MsgBox(Array.includes("3", 100))  ;0
MsgBox(Array.includes("1", -10))  ;1
MsgBox(Array.includes("1", -2))  ;0
Array[1] := "", MsgBox(Array.Includes(""))  ;1
MsgBox(["red", "Green", "bLUe"].Includes("Blue"))  ;0

;*** IndexOf
Array := ["ant", "bison", "camel", "", "bison"]
MsgBox(Array.IndexOf("bison"))  ;1
MsgBox(Array.IndexOf("bison", 2))  ;4
MsgBox(Array.IndexOf("Marco"))  ;-1

;*** Join
Array := [1, "", "3", , "Five"]
MsgBox(Array.Join(" + "))  ;1 +  + 3 +  + Five
MsgBox(Array.Join(""))  ;13Five

;*** LastIndexOf
Array := [2, 5, 9, 2, , 1]
MsgBox(Array.LastIndexOf(2))  ;3
MsgBox(Array.LastIndexOf(7))  ;-1
MsgBox(Array.LastIndexOf(2, 3))  ;3
MsgBox(Array.LastIndexOf(2, 2))  ;0
MsgBox(Array.LastIndexOf(2, -4))  ;0
MsgBox(Array.LastIndexOf(2, -1))  ;3

;! *** ToString

;*** Slice
Array := ["ant", "bison", "camel", "duck", "elephant"]
MsgBox(Array.slice(2).Print())  ;["camel", "duck", "elephant"]
MsgBox(Array.slice(2, 4).Print())  ;["camel", "duck"]
MsgBox(Array.slice(1, 5).Print())  ;["bison", "camel", "duck", "elephant"]
MsgBox(Array.slice(-1).Print())  ;["elephant"]

;! *** ToLocaleString

;! *** ToSource

;! *** ToString

;-------------------------          Iteration           -----;

;! *** Entries()

;*** Every
Array := [1, 30, 39, 29, 10, 13]
MsgBox(Array.Every(Func("Every")))  ;1
Array.Push(40)
MsgBox(Array.Every(Func("Every")))  ;0

;*** Find
Array := [5, 12, 8, 130, 44]
MsgBox(Array.Find(Func("Find")))  ;12

;*** FindIndex
MsgBox([5, 12, 8, 130, 44].FindIndex(Func("FindIndex")))  ;3
MsgBox([4, 6, 8, 12].Find(Func("IsPrime")))  ;""
MsgBox([4, 5, 8, 12].Find(Func("IsPrime")))  ;5

;! *** FlatMap

;*** ForEach
Array := [1, 3, , 7]
Array.ForEach(Func("ForEach"))  ;1, 3, 7

;! *** Keys

;*** Map
Array := [1, 4, 9, 16]
MsgBox(Array.Map(Func("Map")).Print())  ;[2, 8, 18, 32]
MsgBox(Array.Print())  ;[1, 4, 9, 16]

;! *** Reduce

;! *** ReduceRight

;*** Some
MsgBox([1, 2, 3, 4, 5].Some(Func("Some")))  ;1
MsgBox([1, 3, 5, 7, 9].Some(Func("Some")))  ;0

;! ===== *** Values

;-------------------------           Mutator            -----;

;! *** CopyWithin()

;*** Fill
Array := [1, 2, 3, 4]
MsgBox(Array.Fill(0).Print())  ;[0, 0, 0, 0]
MsgBox(Array.Fill(1, -3, -1).Print())  ;[0, 1, 1, 0]
MsgBox(Array.Fill(0, 2, 4).Fill(5, 1).Fill(6).Print())  ;[6, 6, 6, 6]
Array.Fill({})[0].key := "value"
MsgBox(Array.Print())  ;[{key: "value"}, {key: "value"}, {key: "value"}, {key: "value"}]

;*** Pop
Array := ["broccoli", "cauliflower"]
MsgBox(Array.Pop())  ;"cauliflower"
MsgBox(Array.Print())  ;["broccoli"]
Array.Pop()
MsgBox(Array.Print())  ;[]

;*** Push
Array := ["pigs", "goats", "sheep"]
MsgBox(Array.Push(, ["cows", , "horses"]))  ;5
MsgBox(Array.Print())  ;["pigs", "goats", "sheep", , ["cows", , "horses"]]

;*** Reverse
Array := ["One", "Two", "Three", , 5]
MsgBox(Array.Reverse().Print())  ;[5, "", "Three", "Two", "One"]
MsgBox(Array.Print())  ;[5, "", "Three", "Two", "One"]

;*** Shift
Array := ["1", 2, "Three", , 5]
MsgBox(Array.Shift())  ;1
MsgBox(Array.Print())  ;[2, "Three", "", 5]
(Array := [5]).Shift()
MsgBox(Array.Print())  ;[]

;*** Sort
MsgBox(["March", "Jan", "Feb", "Dec"].Sort().Print())  ;["Dec", "Feb", "Jan", "March"]
MsgBox([1, 30, 4, 21, 100000].Sort().Print())  ;[1, 4, 21, 30, 100000]

;*** Splice
Array := ["Jan", "March", "April", "June"]
Array.Splice(1, 0, "Feb")
MsgBox(Array.Print())  ;["Jan", "Feb", "March", "April", "June"]
Array.Splice(4, 1, "May")
MsgBox(Array.Print())  ;["Jan", "Feb", "March", "April", "May"]

;*** UnShift
Array := [4, 5, 6]
MsgBox(Array.UnShift(1, , 2))  ;6
MsgBox(Array.Print())  ;[1, "", 2, 4, 5, 6]

Exit

;=====          Functions           =========================;

IsPrime(_Number) {
	If (_Number < 2 || _Number != Round(_Number))
		Return, (0)

	Loop, % Floor(Sqrt(_Number))
		If (A_Index > 1 && Mod(_Number, A_Index) == 0)
			Return, (0)

	Return, (1)
}

Every(_Element) {
	Return, (_Element < 40)
}

Filter(_Element) {
	Return, (StrLen(_Element) > 5)
}

Find(_Element) {
	Return, (_Element > 10)
}

FindIndex(_Element) {
	Return, (_Element > 12)
}

ForEach(_Element) {
	MsgBox(_Element)
}

Map(_Element) {
	Return, (_Element*2)
}

Some(_Element) {
	Return, (Mod(_Element, 2) == 0)
}

;=====           Hotkeys            =========================;

~$^s::
	SetTitleMatchMode, 2
	Critical

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return

~$F10::
	SetTitleMatchMode, 2

	If (WinActive(A_ScriptName))
		ListVars
	Return