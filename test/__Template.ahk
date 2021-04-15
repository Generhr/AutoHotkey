;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#NoEnv
#SingleInstance, Force

Process, Priority, , Normal
SetTitleMatchMode, 2

;=======================================================  Group  ===============;

for i, v in [A_ScriptName, "Assert.lib", "Color.lib", "GDIp.lib", "General.lib", "Geometry.lib", "Math.lib", "ObjectOriented.lib", "OCR.lib", "String.lib", "Structure.lib"] {
	GroupAdd, Library, % v
}

;======================================================== Hook ================;

OnExit("Exit")

;======================================================== Test ================;

Assert.FullReport()

ExitApp

;=============== Hotkey =======================================================;

#If (WinActive("ahk_group Library"))

	~*$Esc::ExitApp

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\lib\Assert.lib
#Include, %A_ScriptDir%\..\lib\General.lib

;===============  Label  =======================================================;

;============== Function ======================================================;

Exit() {
	Critical, On

	ExitApp
}

;===============  Class  =======================================================;