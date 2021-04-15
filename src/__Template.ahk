;============ Auto-execute ====================================================;
;=======================================================  Admin  ===============;

if (!A_IsAdmin || !(DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)")) {
	try {
		Run, % Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (A_AhkPath . " /restart " . A_ScriptFullPath))
	}

	ExitApp
}

;======================================================  Setting  ==============;

#InstallKeybdHook
#InstallMouseHook
#NoEnv
;#NoTrayIcon
;#Persistent
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox
#WinActivateForce

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
;DetectHiddenWindows, On
Process, Priority, , High
SendMode, Input
SetBatchLines, -1
SetKeyDelay, -1, -1
SetTitleMatchMode, 2
SetWinDelay, -1
SetWorkingDir, % A_ScriptDir . "\.."

;======================================================== Menu ================;

;Menu, Tray, Icon, % A_WorkingDir . "\res\Image\Icon\___.ico"

;====================================================== Variable ==============;

IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global Debug

;=======================================================  Group  ===============;

;======================================================== GDIp ================;

GDIp.Startup()

;========================================================  Run  ================;

;======================================================== Hook ================;

OnExit("Exit")

;=======================================================  Other  ===============;

Exit

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

;====================================================== Keyboard ==============;

#If (WinActive(A_ScriptName) || WinActive(SubStr(A_ScriptName, 1, -3) . "lib"))

	$F10::ListVars

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\lib\Color.ahk
#Include, %A_ScriptDir%\..\lib\GDIp.lib
#Include, %A_ScriptDir%\..\lib\General.lib
#Include, %A_ScriptDir%\..\lib\Geometry.ahk
#Include, %A_ScriptDir%\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\lib\String.ahk

;===============  Label  =======================================================;

;============== Function ======================================================;

Exit() {
	Critical, On

	GDIp.Shutdown()

	ExitApp
}

;===============  Class  =======================================================;