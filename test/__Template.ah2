;============ Auto-execute ====================================================;

#Requires AutoHotkey v2.0-beta

;=======================================================  Admin  ===============;

if (!A_IsAdmin || !DllCall("GetCommandLine", "Str") ~= " /restart(?!\S)") {
	try {
		Run(Format("*RunAs {}", (A_IsCompiled) ? (A_ScriptFullPath . " /restart") : (Format("{} /restart `"{}`"", A_AhkPath, A_ScriptFullPath))))
	}

	ExitApp
}

;======================================================  Include  ==============;

#Include %A_ScriptDir%\..\lib\Core.ah2

#Include %A_ScriptDir%\..\lib\General\General.ah2

#Include %A_ScriptDir%\..\lib\Assert\Assert.ah2
#Include %A_ScriptDir%\..\lib\Console\Console.ah2

;======================================================  Setting  ==============;

;#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")
;DetectHiddenWindows(True)
ListLines(False)
Persistent(True)
ProcessSetPriority("Normal")
SetWorkingDir(A_ScriptDir . "\..")

;======================================================== Menu ================;

;=======================================================  Group  ===============;

for i, v in [A_ScriptName, "Assert.ah2", "Color.ah2", "Console.ah2", "Core.ah2", "GDIp.ah2", "General.ah2", "Geometry.ah2", "Math.ah2", "ObjectOriented.ah2", "OCR.ah2", "String.ah2", "Structure.ah2"] {
	GroupAdd("Library", v)
}

;====================================================== Variable ==============;

global A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug")
	, A_WindowMessage := DllCall("RegisterWindowMessage", "Str", "WindowMessage", "UInt")

	, A_SavedClipboard
	, A_Null := Chr(0)

;======================================================== Hook ================;

OnMessage(A_WindowMessage, __WindowMessage)

OnExit(__Exit)

;========================================================  Run  ================;

;======================================================== Test ================;
;--------------------------------------------------------  Log  ----------------;

Console.Log(Assert.CreateReport())

;=======================================================  Other  ===============;

exit

;=============== Hotkey =======================================================;
;=======================================================  Mouse  ===============;

;====================================================== Keyboard ==============;

#HotIf (WinActive(A_ScriptName) && !(WinGet("Extension") == "ah1"))

	$F10:: {
		ListVars

		KeyWait("F10")
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload
	}

#HotIf

;============== Function ======================================================;
;======================================================== Hook ================;

__WindowMessage(wParam := 0, lParam := 0, msg := 0, hWnd := 0) {
	switch (wParam) {
		case 0x1000:
			if (!(A_Debug := IniRead(A_WorkingDir . "\cfg\Settings.ini", "Debug", "Debug"))) {
				ToolTip("", , , 20)
			}

			return (True)
	}

	return (-1)
}

__Exit(exitReason, exitCode) {
	Critical(True)

	ExitApp
}

;===============  Class  =======================================================;