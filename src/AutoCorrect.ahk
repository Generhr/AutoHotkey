#Requires AutoHotkey v2.0-beta

;============ Auto-Execute ====================================================;
;--------------  Setting  ------------------------------------------------------;

#NoTrayIcon
#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

ListLines(False)
ProcessSetPriority("Normal")

;---------------  Other  -------------------------------------------------------;

Exit()

;=============== Hotkey =======================================================;

#HotIf (WinActive(A_ScriptName))

    $F10:: {
        ListVars()

        KeyWait("F10")
    }

    ~$^s:: {
        Critical(True)

        Sleep(200)
        Reload()
    }

#HotIf

;=============  Hotstring  =====================================================;
;====================================================== Personal ==============;

:*:\\@:: {
    static email := IniRead(A_ScriptDir . "\..\cfg\Settings.ini", "Email", "Email")

    Send(email)
}

;==================================================  Window Specific  ==========;

#HotIf (WinActive("ahk_exe Code.exe"))

    :*:\\c:: {
        SendText("A_Clipboard := ")

        KeyWait("c")
    }

    :*:\\f:: {
        Send('Format("')

        KeyWait("f")
    }

    :*:\\i:: {
        Send("if (condition) {{}{}}{Left}{Enter}{Up}^{Left}^+{Right}")

        KeyWait("i")
    }

    :*:\\s:: {
        Send('switch () {{}{}}{Left}{Enter}case "_____":{}{Enter}{Up 2}{Right 4}condition^{Left}^+{Right}')

        KeyWait("s")
    }

    :*:\\t:: {
        SendText("ToolTip(")

        KeyWait("t")
    }

    :*:\\l:: {
        Send("Console.Log(")

        KeyWait("l")
    }

    :*:\\m:: {
        SendText("MsgBox(")

        KeyWait("m")
    }

    :*:\\r:: {
        Send("return")

        KeyWait("r")
    }

    :*:\\?:: {
        Send("(condition) ? (_____) : (_____)^{Left 7}^+{Right}")

        KeyWait("/")
    }

    :*:\\o::
    :*:\\a:: {
        c := A_Clipboard

        switch (A_ThisHotkey) {
            case ":*:\\o":
                Send('{{}Key: "value"' . (A_Clipboard := ', Key: "value"') . '{}}{Left}')
            case ":*:\\a":
                Send('{[}"value"' . (A_Clipboard := ', "value"') . '{]}{Left}')
        }

        SetTimer(__Restore.Bind(c), -200)

        ;* Description:
            ;*  Restores the clipboard to what it was after 0.85 seconds of inactivity.
        __Restore(string) {
            if (A_TimeIdleKeyboard >= 850) {
                return (A_Clipboard := string)
            }

            SetTimer(__Restore.Bind(string), -200)
        }
    }

    :*:\vec2:: {
        Send("{{}x: _____, y: _____{}}^{Left 3}^+{Right}")
    }

    :*:\vec3:: {
        Send("{{}x: _____, y: _____{}, z: _____{}}^{Left 5}^+{Right}")
    }

    :*:\rect:: {
        Send("{{}x: _____, y: _____, Width: _____, Height: _____{}}^{Left 7}^+{Right}")
    }

#HotIf

#HotIf (WinActive("Microsoft Visual Studio ahk_exe devenv.exe"))

    :*:\\r:: {
        Send("return")

        KeyWait("r")
    }

#HotIf

#HotIf (WinActive("AutoHotkey - Discord ahk_class Chrome_WidgetWin_1 ahk_exe Discord.exe"))

    :*:``````::``````ahk`n`n``````{Up}

#HotIf

#HotIf (WinActive("#include - Discord ahk_class Chrome_WidgetWin_1 ahk_exe Discord.exe"))

    :*:``````::``````cpp`n`n``````{Up}

#HotIf

#HotIf (WinActive("Command Prompt ahk_exe cmd.exe"))

    :*:\\h::doskey /history
    :*:\\f::ipconfig /flushdns

#HotIf

;=======================================================  Angle  ===============;  ;: https://altcodeunicode.com/

:?*:\deg::{U+00B0}

;====================================================== Fraction ==============;

:*:\1/4::{U+00BC}
:*:\1/2::{U+00BD}
:*:\3/4::{U+00BE}

;=======================================================  Greek  ===============;

:*:\alpha::{U+03B1}
:*:\beta::{U+03B2}
:*:\gamma::{U+03B3}
:*:\delta::{U+03B4}
:*:\epsilon::{U+03B5}
:*:\zeta::{U+03B6}
:*:\eta::{U+03B7}
:*:\theta::{U+03B8}
:*:\iota::{U+03B9}
:*:\kappa::{U+03BA}
:*:\lambda::{U+03BB}
:*:\mu::{U+03BC}
:*:\nu::{U+03BD}
:*:\xi::{U+03BE}
:*:\omicron::{U+03BF}
:*:\pi::{U+03C0}
:*:\rho::{U+03C1}
:*:\sigma::{U+03C3}
:*:\fsigma::{U+03C2}
:*:\tau::{U+03C4}
:*:\upsilon::{U+03C5}
:*:\phi::{U+03C6}
:*:\chi::{U+03C7}
:*:\psi::{U+03C8}
:*:\omega::{U+03C9}

;====================================================== Inverted ==============;

:*:\!::{U+00A1}
:*:\?::{U+00BF}

;====================================================  Superscript  ============;

:*:\^1::{U+00B9}
:*:\^2::{U+00B2}
:*:\^3::{U+00B3}
:*:\^4::{U+2074}
:*:\^5::{U+2075}
:*:\^6::{U+2076}
:*:\^7::{U+2077}
:*:\^8::{U+2078}
:*:\^9::{U+2079}
:*:\^0::{U+2070}
:*:\^+::{U+207A}
:*:\^-::{U+207B}
:*:\^=::{U+207C}
:*:\^(::{U+207D}
:*:\^)::{U+207E}
:*:\^n::{U+207F}
