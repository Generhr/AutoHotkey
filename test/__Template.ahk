;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#NoEnv
#SingleInstance, Force

Process, Priority, , Normal
SetTitleMatchMode, 2

;======================================================== Hook ================;

OnExit("Exit")

;======================================================== Test ================;

Assert.FullReport()

ExitApp

;=============== Hotkey =======================================================;

#If (WinActive(A_ScriptName) || WinActive(SubStr(A_ScriptName, 1, -3) . "lib"))

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