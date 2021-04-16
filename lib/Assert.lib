Class Assert {
	Static Tests := 0, Failures := 0, Successes := 0
		, Log := []

	SetGroup(name) {
		this.Group := name
	}

	SetLabel(name) {
		this.Label := name
	}

	Test(result, expected, negate := 0) {
		Local

		this.Tests++

		if (IsObject(result)) {
			result := this.Print(result)
		}

		if (IsObject(expected)) {
			expected := this.Print(expected)
		}

		if (~((result == expected) - (negate + 1))) {  ;* The bitwise operator will return a truthy value for anything but -1.
			this.Successes++

			return (1)
		}
		else {
			this.Failures++

			Static currentGroup

			if (!(this.Group == currentGroup)) {
				currentGroup := this.Group

				stringLength := StrLen(currentGroup), subtract := Ceil(stringLength/2) + 1

				this.Log.Push("`n" . StrReplace(Format("{:0" . 20 - subtract + (stringLength & 1) . "}", 0), "0", "=")
					. Format(" {} ", currentGroup)
					. StrReplace(Format("{:0" . 60 - subtract . "}", 0), "0", "="))
			}

			Static currentLabel

			if (!(this.Label == currentLabel)) {
				currentLabel := this.Label

				stringLength := StrLen(currentLabel), subtract := Ceil(stringLength/2) + 1

				this.Log.Push("`n" . StrReplace(Format("{:0" . 60 - subtract + (stringLength & 1) . "}", 0), "0", "=")
					. Format(" {} ", currentLabel)
					. StrReplace(Format("{:0" . 20 - subtract . "}", 0), "0", "=") . "`n")
			}

			this.Log.Push(Format("`nTest #{}", SubStr("000" . this.Tests, -2))
				. Format("`nResult{}:`n{}", (negate) ? (" (expected to be different)") : (""), result)
				. Format("`nExpected:`n{}", expected))

			this.Log.Push("`n")

			return (0)
		}
	}

	IsEqual(result, expected) {
		return (this.Test(result, expected))
	}

	IsNotEqual(result, expected) {
		return (this.Test(result, expected, 1))
	}

	IsTrue(result) {
		return (this.Test(result, 1))
	}

	IsFalse(result) {
		return (this.Test(result, 0))
	}

	IsNull(result) {
		return (this.Test(result, ""))
	}

	BuildReport() {
		r := Format("{} {} completed with a {}% success rate ({} {}).`n", this.Tests, (this.Tests == 1) ? ("test") : ("tests"), Floor((this.Successes/this.Tests)*100), this.Failures, (this.Failures == 1) ? ("failure") : ("failures"))

		for i, entry in this.Log {
			r .= entry
		}

		return (r)
	}

	Report() {
		this.Console(this.BuildReport())
	}

	WriteResultsToFile(path := "", clear := 1, run := 1) {
		if (path == "") {
			Static default := A_ScriptDir . "\Assert.log"

			path := default
		}

		if (clear) {
			FileDelete, % path
		}

		FileAppend, % this.BuildReport(), % path

		if (run) {
			Run, % path
		}
	}

	Print(object) {
		Local

		Static needleRegEx := "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$"  ;! RegExReplace(v, "S)^0*(\d+(?:\.(?:(?!0+$)\d)+)?).*", "$1")

		if IsObject(object) {
			index := object.MinIndex()

			for key in object {
				isArray := (key == index++)
			} until (!isArray)

			if (isArray) {
				if (object.Length()) {
					index := object.MinIndex(), maxIndex := object.MaxIndex() + 1 - index  ;* Account for 0-base arrays.

					string := "["

					loop, % maxIndex {  ;* Use `loop` to avoid skipping over empty elements.
						value := object[index++]

						string .= ((IsObject(value)) ? (this.Print(value)) : ((value ~= "[\d\.]+") ? (RegExReplace(value, needleRegEx)) : (Format("""{}""", value)))) . ((A_Index < maxIndex) ? (", ") : ("]"))
					}
				}
				else {
					string := "[]"
				}
			}
			else {
				count := object.Count()

				if (count) {
					string := "{"

					for key, value in object {
						string .= Format("{}: ", (key == Round(key)) ? (key) : (Format("""{}""", key))) . ((IsObject(value)) ? (this.Print(value)) : (((value ~= "[\d\.]+") ? (RegExReplace(value, needleRegEx)) : (Format("""{}""", value))))) . ((A_Index < count) ? (", ") : ("}"))
					}
				}
				else {
					string := "{}"
				}
			}
		}

		return (string)
	}

	Console(output) {
		try {
			DllCall("AttachConsole", "Int", -1) || DllCall("AllocConsole")
			FileAppend, % output . "`n", CONOUT$
		}
		catch {
			return (0)
		}

		KeyWait, Esc, D

		DllCall("FreeConsole")

		return (1)
	}
}
