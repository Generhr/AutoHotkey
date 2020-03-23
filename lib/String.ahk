;=====            Class             =========================;

Class String {
	Static ο := ("".base.base := String.__String)

	;-----            Method            -------------------------;

;*	String.Count(_Deliminator, _Needle)
;*	Description:
;*		Count the number of times `_Needle` exists within the string.
	Count(_String, _Needle) {
		StringReplace, _String, _String, % _Needle, % _Needle, UseErrorLevel

		Return, (ErrorLevel)
	}

;*	String.Reverse(_String)
;*	Description:
;*		Reverse.
	Reverse(_String) {
		Loop, Parse, % StrReplace(_String, d := Chr(959), "`r`n")
			s := A_LoopField . s

		Return, (StrReplace(s, "`r`n", d))
	}

;*	String.Strip(_String, _SearchString)
;*	Description:
;*		Remove all occurrences from a string.
	Strip(_String, _Character) {
		Return, (RegExReplace(_String, "[" RegExReplace(_Character, "[\\\]]", "\$0") "]"))
	}

;*	Array := String.Split(_String[, _Delimiters[, _OmitChars[, _MaxParts]]])
;*	Description:
;*		Separates a string into an array of substrings using the specified delimiters.
	Split(_String, _Delimiters := "", _OmitChars := "", _MaxParts := "-1") {
		r := []

		Loop, Parse, % StrReplace(_String, _Delimiters, d := Chr(959)), % d, % _OmitChars
			r.Push(A_LoopField)

		Return, (r)
	}

	;-----         Nested Class         -------------------------;

	Class __String {  ;* Super secret class.
		__Call(_Key, _Value*) {
			Switch (_Key) {
				Case "Hex":
					Loop, Parse, this
						h .= Format("{:x}", Asc(A_LoopField))

					Return, (h)
				Case "String":
					VarSetCapacity(b, StrLen(this)//2, 0), a := &b

					Loop, Parse, this
						If (Mod(A_Index, 2))
							s := A_LoopField
						Else
							a := NumPut("0x" . s . A_LoopField, a + 0, "UChar")
					s := StrGet(&b, "UTF-8")

					Return, (s)
				Case "Includes":
					Return, (InStr(this, _Value[1], 1, Math.Max(0, Math.Min(StrLen(this), _Value[2])) + 1) != 0)
				Case "IndexOf":
					Return, (InStr(this, _Value[1], 1, Math.Max(0, Math.Min(StrLen(this), _Value[2])) + 1) - 1)
				Case "Reverse":
					Loop, Parse, % StrReplace(this, d := Chr(959), "`r`n")
						s := A_LoopField . s

					Return, (StrReplace(s, "`r`n", d))  ;! DllCall("msvcrt\_" . (A_IsUnicode ? "wcs" : "Str") . "rev", "UInt", &this, "CDecl")
				Case "Slice":
					s := StrLen(this)

					Return, (SubStr(this, _Value[1] + 1, Max((Type(_Value[2]) == "Integer" ? (_Value[2] >= 0 ? Math.Min(s, _Value[2]) : Math.Max(s + _Value[2], 0)) - (_Value[1] >= 0 ? Math.Min(s, _Value[1]) : Math.Max(s + _Value[1], 0)) : s), 0)))
				Case "Split":
					r := []

					Loop, Parse, % StrReplace(this, _Value[1], d := Chr(959)), % d, % _Value[2]
						r.Push(A_LoopField)

					Return, (r)
				Case "ToLowerCase":
					Return, (Format("{:L}", this))
				Case "ToUpperCase":
					Return, (Format("{:U}", this))
				Case "Trim":
					Return, (Trim(this))
			}
			MsgBox("__String.__Call(): " . _Key)
		}

		__Get(_Key*) {
			Switch (_Key[1]) {
				Case "Length":
					Return, (StrLen(this))
				Default:
					If (Type(_Key[1]) == "Integer") {  ;* This is the same as the String.Slice() method except that it returns just one character if `_Key[2]` is undefined.
						s := StrLen(this)

						Return, (SubStr(this, _Key[1] + 1, Max((Type(_Key[2]) == "Integer" ? (_Key[2] >= 0 ? Math.Min(s, _Key[2]) : Math.Max(s + _Key[2], 0)) - (_Key[1] >= 0 ? Math.Min(s, _Key[1]) : Math.Max(s + _Key[1], 0)) : _Key[2] != 0), 0)))
					}
					MsgBox("__String.__Get(): " . _Key[1])
			}
		}
	}

	Class Clipboard {

;*		String.Clipboard.Copy([_Trim[, _Line]])
;*		Description:
;*			Copies and returns the selected text or optionally the whole line if no text is selected while preserving the clipboard content.
		Copy(_Trim := 0, _Line := 0) {
			c := ClipboardAll
			Clipboard := ""

			Send, ^c
			ClipWait, 0.1
			If (ErrorLevel && _Line) {
				Send, {Home}+{End}^c
				ClipWait, 0.1

				If (Clipboard)
					Send, {Right}
			}

			s := (_Trim ? Trim(Clipboard) : Clipboard)  ;! RegExReplace(Clipboard, "^\h*(.*?)\h*$", "$1")
			Clipboard := c

			Return, (s)
		}

;*		String.Clipboard.Paste(_String[, _Select])
;*		Description:
;*			Paste the provided text while preserving the clipboard content and optionally select the text that was pasted.
		Paste(_String, _Select := 0) {
			c := ClipboardAll
			Clipboard := ""

			Sleep, 25
			Clipboard := _String
			Send, ^v

			Sleep, 25
			Clipboard := c

			If (_Select) {
				If (InStr(_String, "`n"))
					Loop, Parse, _String, `n, `r
						s += StrLen(A_LoopField) + (A_Index > 1)

				Send, % "+{Left " . Math.Max(s, StrLen(_String)) . "}"
			}
		}
	}
}