;=====         Auto-execute         =========================;

;===============           Setting            ===============;

#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force

Process, Priority, , Normal

;===============           Variable           ===============;

IniRead, vNetwork, % A_WorkingDir . "\cfg\Settings.ini", Network, Network
Global vNetwork

Exit

;=====           Function           =========================;

Connection() {
    Static Օ := Connection()

    If (DllCall("WinINet\InternetCheckConnectionW", "WStr", "https://www.google.com", "UInt", 1, "UInt", 0) == 0) {
        vClipBoard := ClipboardAll, Clipboard := ""

        Runwait, %ComSpec% /c netsh wlan Show interface | clip, , Hide
        ClipWait, 0.2

        If (!InStr(RegExReplace(Clipboard, "s).*?\R\s+SSID\s+:(\V+).*", "$1"), vNetwork)) {
            Run, %ComSpec% /c netsh wlan connect name="%vNetwork%", , Hide

            WinWait, ahk_class SymHTMLDialog, , 5
            If (!ErrorLevel)
                WinClose, ahk_class SymHTMLDialog
        }
        Clipboard := vClipBoard
    }

    SetTimer, % A_ThisFunc, -1000
}
