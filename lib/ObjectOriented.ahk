;=====           Function           =========================;

Array(vParameters*) {
	r := new __Array

	Loop, % vParameters.Length() {
		r[A_Index - 1] := vParameters[A_Index]
	}

	Return, (r)
}

Object(vParameters*) {
	r := new __Object

	Loop, % vParameters.Count()//2 {
		r[vParameters[(i := A_Index*2) - 1]] := vParameters[i]
	}

	Return, (r)
}

Range(vStart := 0, vStop := "", vStep := 1) {
	If (vStop == "") {
		vStop := vStart, vStart := 0
	}

	If (Math.IsInteger(vStart) && Math.IsInteger(vStop)) {
		r := []

		Loop, % Math.Max(Math.Ceil((vStop - vStart)/vStep), 0) {
			r.Push(vStart), vStart += vStep
		}

		Return, (r)
	}

	Throw, (Exception("TypeError.", -1, Format("Range({}) may only contain integers.", [vStart, vStop, vStep].Join(", "))))
}

__Sort(vValue1, vValue2) {
	Return, (vValue1 < vValue2 ? -1 : vValue1 > vValue2 ? 1 : 0)
}

;=====            Class             =========================;

Class __Array {
    Static StringCaseSense := 1, ThrowException := 1

	;-----           Property           -------------------------;

	__Get(vKey) {
		Switch (vKey) {

			;* Array.Length
			Case "Length":
				Return, (Round(this.MaxIndex() + 1))

			;* Array.Count
			;* Description:
				;* Count of enumerable properties.
			Case "Count":
				For i, v in this {
					r += (v != "")
				}

				Return, (Round(r))

			;* Array[-N]
			Default:
				If (vKey < 0) {
					v := Round(this.MaxIndex() + 1) + vKey

					If (this.HasKey(v)) {
						Return, (this[v])
					}
				}
		}
	}

	__Set(vKey, vValue) {
		Switch (vKey) {

			;* Array.Length := N
			Case "Length":
				If (Math.IsInteger(vValue) && vValue >= 0) {
					o := vValue - (s := Round(this.MaxIndex() + 1))

					Loop, % Math.Abs(o) {
						(o < 0) ? this.RemoveAt(--s) : this[s++] := ""  ;? ["" || "undefined"]
					}

					Return, (s)
				}

				If (this.ThrowException) {
					Throw, (Exception("Invalid assignment.", -1, Format("""{}"" is invalid. This property may only be assigned a possitive integer.", vValue)))
				}
		}
	}

	;-----            Method            -------------------------;
	;---------------             AHK              ---------------;

	__Call(vKey) {
		Switch (vKey) {

			;* Array.Count()
			Case "Count":
				Return, (this.Count)  ;* Redirect `Array.Count()` to `Array.Count[]`.
		}
	}

	;---------------            Custom            ---------------;

	;* Array.Print()
	;* Description:
		;* Converts the array into a string to more easily see the structure.
	Print() {
		m := Round(this.MaxIndex() + 1)

		Loop, % m {
			i := A_Index - 1
				, r .= (A_Index == 1 ? "[" : "") . (IsObject(this[i]) ? this[i].Print() : ((Math.IsNumeric(this[i])) ? (RegExReplace(this[i], "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format("""{}""", this[i])))) . (A_Index < m ? ", " : "]")  ;! RegExReplace(v, "S)^0*(\d+(?:\.(?:(?!0+$)\d)+)?).*", "$1")
		}

		Return, (r ? r : "[]")
	}

	;* Array.Empty()
	;* Description:
		;* Removes all elements in an array.
	;* Note:
		;* This is the same as `Array.Length := 0` but it returns a reference to `this` instead of the new length to allow for unreadable one line code. Winning.
	Empty() {
		this.RemoveAt(0, Round(this.MaxIndex() + 1))

		Return, (this)
	}

	;* Array.Shuffle()
	;* Description:
		;* Fisher–Yates shuffle (https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle).
	Shuffle() {
		m := this.MaxIndex()

		For i, v in this {
			this.Swap(i, Math.Random(i, m))
		}

		Return, (this)
	}

	;* Array.Swap(vIndex1, vIndex2)
	;* Description:
		;* Swap any two elements in an array.
	Swap(vIndex1, vIndex2) {
		m := this.MaxIndex()

		If (Math.IsBetween(vIndex1, 0, m) && Math.IsBetween(vIndex2, 0, m)) {  ;- No error handling.
			t := this[vIndex1], this[vIndex1] := this[vIndex2], this[vIndex2] := t
		}

		Return, (this)
	}

	;---------------             MDN              ---------------;  ;? https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array, https://javascript.info/array-methods.

	;* Array.Concat(vValue1, vValue2, ..., vValueN)
	;* Description:
		;* Merges two or more arrays. This method does not change the existing arrays, but instead returns a new array.
	Concat(vValues*) {
		r := this.Clone()

		For i, v in [vValues*] {
			If (Type(v) == "Array") {
				For i, v in v {
					r.Push(v)
				}
			}
			Else {
				r.Push(v)
			}
		}

		Return, (r)
	}

	;* Array.Every(Func("Function"))
	;* Description:
		;* Tests whether all elements in the array pass the test implemented by the provided function. It returns a Boolean value.
	;* Note:
		;* Calling this method on an empty array will return true for any condition.
	Every(oCallback) {
		For i, v in this {
			If (!oCallback.Call(v, i, this)) {
				Return, (0)
			}
		}

		Return, (1)
	}

	;* Array.Fill($vValue, $vStart, $vEnd)
	;* Description:
		;* Changes all elements in an array to a static value, from a start index (default 0) to an end index (default `Array.Length`). It returns the modified array.
	Fill(vValue := "", vStart := 0, vEnd := "") {  ;? vValue := ["" || "undefined"]
		m := Round(this.MaxIndex() + 1)
			, vStart := vStart >= 0 ? Math.Min(m, vStart) : Math.Max(m + vStart, 0)

		Loop, % (vEnd != "" ? vEnd >= 0 ? Math.Min(m, vEnd) : Math.Max(m + vEnd, 0) : m) - vStart {
			this[vStart++] := vValue
		}

		Return, (this)
	}

	;* Array.Filter(Func("Function"))
	;* Description:
		;* Creates a new array with all elements that pass the test implemented by the provided function.
	Filter(oCallback) {
		r := []

		For i, v in this {
			If (oCallback.Call(v, i, this)) {
				r.Push(v)
			}
		}

		Return, (r)
	}

;  // Return all the elements for which a truth test fails.
;  function reject(obj, predicate, context) {
;    return filter(obj, negate(cb(predicate)), context);
;  }

	;* Array.Find(Func("Function"))
	;* Description:
		;* Returns the value of the first element in the provided array that satisfies the provided testing function.
	Find(oCallback) {
		For i, v in this {
			If (oCallback.Call(v, i, this)) {
				Return, (v)
			}
		}

		Return, ("")  ;? ["" || "undefined"]
	}

	;* Array.FindIndex(Func("Function"))
	;* Description:
		;* Returns the index of the first element in the array that satisfies the provided testing function. Otherwise, it returns -1, indicating that no element passed the test.
	FindIndex(oCallback) {
		For i, v in this {
			If (oCallback.Call(v, i, this)) {
				Return, (i)
			}
		}

		Return, (-1)
	}

	;* Array.Flat($vDepth)
	;* Description:
		;* Creates a new array with all sub-array elements concatenated into it recursively up to the specified depth.
	Flat(vDepth := 1) {
		r := []

		For i, v in this {
			If (Type(v) == "Array" && vDepth > 0) {
				r := r.Concat(v.Flat(vDepth - 1))
			}
			Else If (v != "") {  ;- Skip empty elements.
				r.Push(v)
			}
		}

		Return, (r)
	}

	;* Array.ForEach(Func("Function"))
	;* Description:
		;* Executes a provided function once for each array element.
	ForEach(oCallback) {
		For i, v in this {
			this[i] := oCallback.Call(v, i, this)
		}
	}

	;* Array.Includes(vNeedle, $vStart)
	;* Description:
		;* Determines whether an array includes a certain value among its entries, returning true or false as appropriate.
	Includes(vNeedle, vStart := 0) {
		Return, (vStart < Round(this.MaxIndex() + 1) && this.IndexOf(vNeedle, vStart) != -1)
	}

	;* Array.IndexOf(vNeedle, $vStart)
	;* Description:
		;* Returns the first index at which a given element can be found in the array, or -1 if it is not present.
	IndexOf(vNeedle, vStart := 0) {
		m := Round(this.MaxIndex() + 1)
			, vStart := vStart >= 0 ? Math.Min(m, vStart) : Math.Max(m + vStart, 0)

		Loop, % m - vStart {
			If (this.StringCaseSense ? this[vStart] == vNeedle : this[vStart] = vNeedle) {
				Return, (vStart)
			}

			vStart++
		}

		Return, (-1)
	}

	;* Array.Join($vDelimiter)
	;* Description:
		;* Creates and returns a new string by concatenating all of the elements in an array (or an array-like object), separated by commas or a specified separator string. If the array has only one item, then that item will be returned without using the separator.
	Join(vDelimiter := ", ") {
		m := Round(this.MaxIndex())

		For i, v in this {
			r .= (IsObject(v) ? Type(v) == "Array" ? v.Join(vDelimiter) : "[object Object]" : v) . (i < m ? vDelimiter : "")
		}

		Return, (r)
	}

	;* Array.LastIndexOf(vNeedle, $vStart)
	;* Description:
		;* Returns the last index at which a given element can be found in the array, or -1 if it is not present. The array is searched backwards, starting at fromIndex.
	LastIndexOf(vNeedle, vStart := -1) {
		vStart := (vStart >= 0 ? Math.Min(Round(this.MaxIndex() + 1) - 1, vStart) : Math.Max(Round(this.MaxIndex() + 1) + vStart, -1))

		While (vStart > -1) {
			If (this.StringCaseSense ? this[vStart] == vNeedle : this[vStart] = vNeedle) {
				Return, (vStart)
			}

			vStart--
		}

		Return, (-1)
	}

	;* Array.Map(Func("Function"))
	;* Description:
		;* Creates a new array populated with the results of calling a provided function on every element in the calling array.
	Map(oCallback) {
		r := []

		For i, v in this {
			r.Push(oCallback.Call(v, i, this))
		}

		Return, (r)
	}

	;* Array.Pop()
	;* Description:
		;* Removes the last element from an array and returns that element. This method changes the length of the array.
	Pop() {
		Try {
			Return, (this.RemoveAt(this.MaxIndex()))
		}
		Catch {
			Return, ("")  ;? ["" || "undefined"]
		}
	}

	;* Array.Push(vElement1, vElement2, ..., vElementN)
	;* Description:
		;* Adds one or more elements to the end of an array and returns the new length of the array.
	Push(vElements*) {
		m := Round(this.MaxIndex() + 1)

		For i, v in [vElements*] {
			this.InsertAt(m++, v)
		}

		Return, (m)
	}

	;* Array.Reverse()
	;* Description:
		;* Reverses an array in place. The first array element becomes the last, and the last array element becomes the first.
	Reverse() {
		m := this.MaxIndex()

		For i, v in this {
			this.InsertAt(m, this.RemoveAt(m - i))
		}

		Return, (this)
	}

	;* Array.Shift()
	;* Description:
		;* Removes the first element from an array and returns that removed element. This method changes the length of the array.
	Shift() {
		Return, (this.RemoveAt(0))  ;? [this.RemoveAt(0) || Round(this.MaxIndex() + 1) ? this.RemoveAt(0) : "undefined"]
	}

	;* Array.Slice($vStart, $vEnd)
	;* Description:
		;* Returns a shallow copy of a portion of an array into a new array object selected from begin to end (end not included) where begin and end represent the index of items in that array. The original array will not be modified.
	Slice(vStart := 0, vEnd := "") {
		m := Round(this.MaxIndex() + 1), r := []
			, vStart := (vStart >= 0 ? Math.Min(m, vStart) : Math.Max(m + vStart, 0))

		Loop, % (vEnd != "" ? vEnd >= 0 ? Math.Min(m, vEnd) : Math.Max(m + vEnd, 0) : m) - vStart
			r.Push(this[vStart++])

		Return, (r)
	}

	;* Array.Some(Func("Function"))
	;* Description:
		;* Tests whether at least one element in the array passes the test implemented by the provided function. It returns a Boolean value.
	;* Note:
		;* Calling this method on an empty array returns false for any condition.
	Some(oCallback) {
		For i, v in this
			If (oCallback.Call(v, i, this))
				Return, (1)

		Return, (0)
	}

	;* Array.Sort($Func("Function"))
	;* Description:
		;* Sorts the elements of an array in place and returns the sorted array. The default sort order is ascending, built upon converting the elements into strings, then comparing their sequences of UTF-16 code units values.
	Sort(oCompareFunction := "__Sort") {
		z := A_StringCaseSense

		StringCaseSense, % this.StringCaseSense

		While (c != 0) {
			c := 0

			Loop, % Round(this.MaxIndex())
				If (%oCompareFunction%(this[A_Index - 1], this[A_Index]) > 0)
					this.Swap(A_Index - (c := 1), A_Index)
		}

		StringCaseSense, % z

		Return, (this)
	}

	;* Array.Splice(vStart, $vDeleteCount, $vElement1, $vElement2, ..., $vElementN)
	;* Description:
		;* Changes the contents of an array by removing or replacing existing elements and/or adding new elements in place.
	Splice(vStart, vDeleteCount := "", vElements*) {
		m1 := Round(this.MaxIndex() + 1), m2 := vElements.MaxIndex(), r := []
			, vStart := vStart >= 0 ? Math.Min(m1, vStart) : Math.Max(m1 + vStart, 0)

		Loop, % (vDeleteCount != "" ? Math.Max(m1 <= vStart + vDeleteCount ? m1 - vStart : vDeleteCount, 0) : m2 ? 0 : m1)
			r.InsertAt(A_Index - 1, this.RemoveAt(vStart))

		If (m2)
			this.InsertAt(vStart, vElements*)

		return (r)
	}

	;* Array.UnShift(vElement1, vElement2, ..., vElementN)
	;* Description:
		;* Adds one or more elements to the beginning of an array and returns the new length of the array.
	UnShift(vElements*) {
		For i, v in [vElements*]
			this.InsertAt(i, v)

		Return, (Round(this.MaxIndex() + 1))
	}
}

Class __Object {
    Static StringCaseSense := 1, ThrowException := 1

	;-----            Method            -------------------------;

	;* Object.Print()
	;* Description:
		;* Converts an object into a string to more easily see the structure.
	Print() {
		m := this.Count()

		For k, v in this {
			r .= (A_Index == 1 ? "{" : "") . k . ": " . (IsObject(v) ? v.Print() : (Math.IsNumeric(v) ? (RegExReplace(v, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : Format("""{}""", v))) . (A_Index < m ? ", " : "}")
		}

		Return, (r ? r : "{}")
	}
}

Class __String {
	Static __ := ("".base.base := __String), StringCaseSense := 1, ThrowException := 1

	;-----           Property           -------------------------;

	__Get(vKeys*) {
		Switch (vKeys[1]) {

			;* "String".Length
			Case "Length":
				Return, (StrLen(this))

			;* "String"[N, N]
			;* Note:
				;* This is the same as `"String".Slice(N*)` but it will return just one character if the second parameter is undefined.
			Default:
				If (Math.IsInteger(vKeys[1])) {
					m := StrLen(this)

					Return, (SubStr(this, vKeys[1] + 1, Max(((Math.IsInteger(vKeys[2])) ? (((vKeys[2] >= 0) ? (Math.Min(m, vKeys[2])) : (Math.Max(m + vKeys[2], 0))) - ((vKeys[1] >= 0) ? (Math.Min(m, vKeys[1])) : (Math.Max(m + vKeys[1], 0)))) : (vKeys[2] != 0)), 0)))
				}
		}
	}

	__Set(vKey, vValue) {
	}

	;-----            Method            -------------------------;
	;---------------            Custom            ---------------;

	Hex() {
		Loop, Parse, this
			h .= Format("{:x}", Asc(A_LoopField))

		Return, (h)
	}

	String() {
		VarSetCapacity(b, StrLen(this)//2, 0), a := &b

		Loop, Parse, this
			If (Math.IsEven(A_Index)) {
				s := A_LoopField
			}
			Else {
				a := NumPut("0x" . s . A_LoopField, a + 0, "UChar")
			}

		Return, (StrGet(&b, "UTF-8"))
	}

	;---------------             MDN              ---------------;

	Includes(vNeedle, vStart := 0) {
		Return, (InStr(this, vNeedle, 1, Math.Max(0, Math.Min(StrLen(this), Round(vStart))) + 1) != 0)
	}

	IndexOf(vNeedle, vStart := 0) {
		Return, (InStr(this, vNeedle, 1, Math.Max(0, Math.Min(StrLen(this), Round(vStart))) + 1) - 1)
	}

	Reverse() {
		d := Chr(959)

		Loop, Parse, % StrReplace(this, d, "`r`n")
			s := A_LoopField . s

		Return, (StrReplace(s, "`r`n", d))  ;! DllCall("msvcrt\_" . (A_IsUnicode ? "wcs" : "Str") . "rev", "UInt", &this, "CDECL")
	}

	Slice(vStart, vEnd := "") {
		m := StrLen(this)

		Return, (SubStr(this, vStart + 1, Max(((Math.IsInteger(vEnd)) ? (((vEnd >= 0) ? (Math.Min(m, vEnd)) : (Math.Max(m + vEnd, 0))) - ((vStart >= 0) ? (Math.Min(m, vStart)) : (Math.Max(m + vStart, 0)))) : (m)), 0)))
	}

	Split() {
		d := Chr(959), r := []

		Loop, Parse, % StrReplace(this, vValue[1], d), % d, % vValue[2]
			r.Push(A_LoopField)

		Return, (r)
	}

	ToLowerCase() {
		Return, (Format("{:L}", this))
	}

	ToUpperCase() {
		Return, (Format("{:U}", this))
	}

	Trim() {
		Return, (Trim(this))
	}
}