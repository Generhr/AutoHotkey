;=====         Auto-execute         =========================;
;===============           Variable           ===============;

Global String := new String

;=====            Class             =========================;

Class String {
    Static CaseSensitive := 1, ThrowException := 1

	;-----           Property           -------------------------;

	__Set(vKey, vValue) {
		Switch (vKey) {

			;* String.StringCaseSense := (1 || 0)
			Case "StringCaseSense":
				ObjRawSet(String, "StringCaseSense", vValue)

			;* String.ThrowException := (1 || 0)
			Case "ThrowException":
				ObjRawSet(String, "ThrowException", vValue)
		}
	}

	;-----            Method            -------------------------;

	;* String.Count(vString, vNeedle)
	;* Description:
		;* Count the number of times `vNeedle` exists within a string.
	Count(vString, vNeedle) {
		StringReplace, vString, vString, % vNeedle, % vNeedle, UseErrorLevel

		Return, (ErrorLevel)
	}

	;* String.Reverse(vString)
	Reverse(vString) {
		d := Chr(959)

		Loop, Parse, % StrReplace(vString, d, "`r`n")
			s := A_LoopField . s

		Return, (StrReplace(s, "`r`n", d))
	}

	;* String.Strip(vString, vCharacter)
	;* Description:
		;* Remove all occurrences from a string.
	Strip(vString, vCharacter) {
		Return, (RegExReplace(vString, "[" RegExReplace(vCharacter, "[\\\]]", "\$0") "]"))
	}

	;* String.Split(vString, $vDelimiter, $vOmitChars, $vMaxParts)
	;* Description:
		;* Separates a string into an array of substrings using the specified delimiters.
	Split(vString, vDelimiter := "", vOmitChars := "", vMaxParts := "-1") {
		d := Chr(959), r := []

		Loop, Parse, % StrReplace(vString, vDelimiter, d), % d, % vOmitChars
			r.Push(A_LoopField)

		Return, (r)
	}

	StrTrim(String, TrimChars) {  ;* Removes specified leading and trailing characters from a string.
		if !(DllCall("shlwapi.dll\StrTrim", "Ptr", &String, "Ptr", &TrimChars))  ;StrTrim("_!ABCDEFG#", "#A!_\0")    ; ==> BCDEFG
			return FALSE
		return StrGet(&String)
	}

	;-----         Nested Class         -------------------------;

	Class Clipboard {

		;-----           Property           -------------------------;

		__Set() {
			Return
		}

		;-----            Method            -------------------------;

		;* String.Clipboard.Copy($vTrim, $vLine)
		;* Description:
			;* Copies and returns the selected text or optionally the whole line if no text is selected while preserving the clipboard content.
		Copy(vTrim := 0, vLine := 0) {
			c := ClipboardAll
			Clipboard := ""

			Send, ^c
			ClipWait, 0.1
			If (ErrorLevel && vLine) {
				Send, {Home}+{End}^c
				ClipWait, 0.1

				If (Clipboard)
					Send, {Right}
			}

			s := ((vTrim) ? (Trim(Clipboard)) : (Clipboard))  ;! RegExReplace(Clipboard, "^\h*(.*?)\h*$", "$1")
			Clipboard := c

			Return, (s)
		}

		;* String.Clipboard.Paste(vString, $vSelect)
		;* Description:
			;* Paste the provided text while preserving the clipboard content and optionally select the text that was pasted.
		Paste(vString, vSelect := 0) {
			c := ClipboardAll
			Clipboard := ""

			Sleep, 25
			Clipboard := vString
			Send, ^v

			Sleep, 25
			Clipboard := c

			If (vSelect) {
				If (InStr(vString, "`n"))
					Loop, Parse, vString, `n, `r
						s += StrLen(A_LoopField) + (A_Index > 1)

				Send, % "+{Left " . Math.Max(s, StrLen(vString)) . "}"
			}
		}
	}
}