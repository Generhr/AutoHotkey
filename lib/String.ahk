;===============  Class  =======================================================;

Class String {
    Static StringCaseSense := 1
		, ThrowException := 1

	;--------------- Method -------------------------------------------------------;

	IsPalindrome(string) {
		Local

		string := Format("{:U}", RegExReplace(string, "[\s.,?!;']"))

		return (string == this.Reverse(string))
	}

	IsUrl(url) {
		Static needle := "S)((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)"

		return (url ~= needle)
	}

	Buffer(string, commentCharacter, bufferCharacter, bufferLength, offset := "", specialBuffer := 0) {
		Local

		if (offset == "") {
			offset := bufferLength//2
		}

		stringLength := StrLen(string)
			, subtract := Ceil(stringLength/2) + StrLen(commentCharacter) + 1, isOdd := stringLength & 1

		leftOffset := 0, rightOffset := 0

		if (!specialBuffer && isOdd) {
			if (offset <= bufferLength//2) {
				rightOffset := 1
			}
			else {
				leftOffset := 1
			}
		}

		return (commentCharacter
			. StrReplace(Format("{:0" . offset - subtract + leftOffset . "}", 0), "0", bufferCharacter)
			. ((specialBuffer && isOdd) ? (Format("  {}  ", string)) : (Format(" {} ", string)))
			. StrReplace(Format("{:0" . bufferLength - offset - subtract + rightOffset . "}", 0), "0", bufferCharacter)
			. commentCharacter)
	}

	;* String.Count(string, needle)
	;* Description:
		;* Count the number of times `needle` exists within a string.
	Count(string, needle) {
		StringReplace, string, string, % needle, % needle, UseErrorLevel

		return (ErrorLevel)
	}

	;* String.Inverse(string)
	Inverse(string) {
		return (RegExReplace(string, "([A-Z])|([a-z])", "$L1$U2"))
	}

	;* String.Repeat(string, times)
	Repeat(string, times) {
		return (StrReplace(Format("{:0" . times . "}", 0), "0", string))
	}

	;* String.Reverse(string)
	Reverse(string) {
		d := Chr(959)

		for i, v in StrSplit(StrReplace(string, d, "`r`n")) {
			s := v . s
		}

		return (StrReplace(s, "`r`n", d))
	}

	;* String.Strip(string, characters)
	;* Description:
		;* Remove all occurrences of `Characters` from a string.
	Strip(string, characters) {
		return (RegExReplace(string, "[" . characters . "]"))
	}

	;* String.Split(string, (delimiter), (omitChars), (maxParts))
	;* Description:
		;* Separates a string into an array of substrings using the specified delimiters.
	Split(string, delimiter := "", omitChars := "", maxParts := "-1") {
		d := Chr(959), r := []

		loop, Parse, % StrReplace(string, delimiter, d), % d, % omitChars
			r.Push(A_LoopField)

		return (r)
	}

	;* String.Split(String, (characters))
	;* Description:
		;* Removes leading and trailing `characters` from a string.
	Trim(string, characters := "") {
		return ((characters) ? (Trim(string, characters)) : (Trim(string)))
	}

	;------------ Nested Class ----------------------------------------------------;

	Class Clipboard {

		;* String.Clipboard.Copy((trim), (getLine))
		;* Description:
			;* Copies and returns the selected text or optionally the whole line if no text is selected while preserving the clipboard content.
		Copy(trim := 0, getLine := 0) {
			c := ClipboardAll
			Clipboard := ""

			Send, ^c
			ClipWait, 0.2
			if (ErrorLevel && getLine) {
				Send, {Home}+{End}^c
				ClipWait, 0.2

				if (Clipboard) {
					Send, {Right}
				}
			}

			s := (trim) ? (Trim(Clipboard)) : (Clipboard)
			Clipboard := c

			return (s)
		}

		;* String.Clipboard.Paste(string, (select))
		;* Description:
			;* Paste the provided text while preserving the clipboard content and optionally select the text that was pasted.
		Paste(string, select := 0) {
			c := ClipboardAll
			Clipboard := ""

			Sleep, 25
			Clipboard := string
			Send, ^v

			Sleep, 25
			Clipboard := c

			if (select) {
				if (InStr(string, "`n")) {
					loop, Parse, string, `n, `r
						s += StrLen(A_LoopField) + (A_Index > 1)
				}

				Send, % "+{Left " . Math.Max(s, StrLen(string)) . "}"
			}
		}
	}
}
