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

MsgBox("Merm" . "Blue Whale"["Blue Whale".IndexOf("Whale"), "Blue Whale".Length][2] . "id!")  ;* ("Merm" . ("Blue Whale"[5, 10] == "Whale"[2] == "a") . "id!") == "Mermaid!"

;*** Slice()
vString := "1234567890"
For i, v in [["", 4, -7], ["567890", -6], ["1234567890", -200], ["0", -1], ["890", 7], ["", 10], ["", 9, -1], ["6789", -5, -1], ["9", -2, -1], ["2", +1, +2], ["23456789", +1, -1], ["2", +1, -8], ["", +1, -9], ["12", -0, +2], ["89", -3, -1], ["", -1, -1], ["12345678", -0, +8], ["12", -0, -8], ["12345678", -0, -2], ["", -0, -0]]
	If (vString.Slice(v[1], v[2]) != v[0])
		MsgBox(i "] " "vString.Slice(" . v[1] . ", " . (v[2] ? v[2] : """""") . ")" . " != " . Format("""{}""", v[0]))

;*** Includes()
vString := "To be, or not to be, that is the question."
For i, v in [[1, "To be"], [1, "question"], [0, "nonexistent"] , [0, "To be", 1], [0, "TO BE"], [1, ""], [1, "that", -200]]
	If (vString.Includes(v[1], v[2]) != v[0])
		MsgBox(i "] " "vString.Includes(" . Format("""{}""", v[1]) . ", " . (v[2] ? v[2] : """""") . ")" . " != " . v[0])

;*** IndexOf()
vString := "The quick brown fox jumps over the lazy dog. If the dog barked, was it really lazy?"
For i, v in [[0, "The"], [-1, "Teh"], [31, "the"], [16, "fox", 0], [16, "fox", 16], [-1, "fox", 17], [0, ""], [82, "", 82], [83, "", 83], [83, "", 85]]
	If (vString.IndexOf(v[1], v[2]) != v[0])
		MsgBox(i "] " "vString.Includes(" . Format("""{}""", v[1]) . ", " . (v[2] ? v[2] : """""") . ")" . " != " . v[0])

;*** ToLowerCase(), ToUpperCase()
MsgBox(Format("""{}""", "What am I?".ToLowerCase().ToUpperCase()))

;*** Trim()
MsgBox(Format("""{}""", "   `tHello world!   ".Trim()))

;=====            Hotkey            =========================;

~$^s::
	Critical
	SetTitleMatchMode, 2

	If (WinActive(A_ScriptName)) {
		Sleep, 200
		Reload
	}
	Return