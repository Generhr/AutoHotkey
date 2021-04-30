;============== Function ======================================================;

Array(parameters*) {
	loop, % (parameters.Length(), r := new __Array) {
		r[A_Index - 1] := parameters[A_Index]
	}

	return (r)
}

Object(parameters*) {
	loop, % (parameters.MaxIndex()//2, r := new __Object) {
		i := A_Index*2

		r[parameters[i - 1]] := parameters[i]
	}

	return (r)
}

Print(object) {
	switch (Type(object)) {
		case "Array":
			if (s := this.Length) {
				for i, v in (this, r := "[") {
					r .= ((IsObject(v)) ? (Print(v)) : ((Math.IsNumber(v)) ? (RegExReplace(v, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format("""{}""", v)))) . ((A_Index < s) ? (", ") : ("]"))
				}
			}
			else {
				r := "[]"
			}
		case "Object":
			if (s := this.Length) {
				for i, v in (this, r := "[") {
					r .= ((IsObject(v)) ? (Print(v)) : ((Math.IsNumber(v)) ? (RegExReplace(v, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format("""{}""", v)))) . ((A_Index < s) ? (", ") : ("]"))
				}
			}
			else {
				r := "[]"
			}
	}

	return (r)
}

;* Range((start), (stop), (step))
;* Description:
	;* Returns a sequence of integers starting at `Start` with increments of `Step`, ending at `Stop` (noninclusive).  ;: https://pynative.com/python-range-function/
Range(start := 0, stop := "", step := 1) {
	if (stop == "") {
		stop := start, start := 0
	}

	if (Math.IsInteger(start) && Math.IsInteger(stop)) {
		loop, % (Math.Max(Math.Ceil((stop - start)/step), 0), r := []) {
			r.Push(start), start += step
		}

		return (r)
	}

	throw (Exception("TypeError.", -1, Format("Range({}) may only contain integers.", [start, stop, step].Join(", "))))
}

__Sort(value1, value2) {
	return ((value1 < value2) ? (-1) : ((value1 > value2) ? (1) : (0)))
}

;===============  Class  =======================================================;

Class __Array {
    Static StringCaseSense := 1
		, ThrowException := 1

	__Call(key) {
		switch (key) {

			;* array.Count()
			case "Count":
				return (this.Count)

			;* array.Length()
			case "Length":
				return (this.Length)
		}
	}

	;-------------- Property ------------------------------------------------------;

	__Get(index) {
		;* array[-index]
		;* Description:
			;* Register negative index lookups as an offset from the arrays last index with -1 referring to the last index.
		if (Math.IsNegativeInteger(index)) {
			index += this.Length

			if (this.HasKey(index)) {
				return (this[index])
			}
		}
	}

	Count[] {

		;* array.Count
		;* Description:
			;* Returns the number of enumerable properties.
		Get {
			for i, v in this {
				r += (v != "")
			}

			return (Round(r))
		}
	}

	Length[] {

		;* array.Length
		Get {
			Static offset := A_PtrSize*4

			return (NumGet(&this, offset))
		}

		;* array.Length := value
		Set {
			if (Math.IsPositiveInteger(value)) {
				loop, % Math.Abs(o := value - (s := this.Length)) {
					(o < 0) ? this.RemoveAt(--s) : this[s++] := ""
				}

				return (value)
			}

			if (this.ThrowException) {
				throw (Exception("Invalid Assignment", -1, Format("""{}"" is invalid. This property may only be assigned a non negative integer.", value)))
			}
		}
	}

	;--------------- Method -------------------------------------------------------;
	;------------------------------------------------------- Custom ---------------;

	;* array.Compact((recursive))
	;* Description:
		;* Remove all falsy values from an array.
	Compact(recursive := 0) {
		for i, v in (this, r := []) {
			if (v) {
				r.Push((recursive && v.__Class == "__Array") ? (v.Compact(recursive)) : (v))
			}
		}

		return (this := r)
	}

	;* array.Print()
	;* Description:
		;* Converts the array into a string to more easily see the structure.
	Print() {
		if (s := this.Length) {
			for i, v in (this, r := "[") {
				r .= ((IsObject(v)) ? (v.Print()) : ((Math.IsNumber(v)) ? (RegExReplace(v, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format("""{}""", v)))) . ((A_Index < s) ? (", ") : ("]"))  ;! RegExReplace(v, "S)^0*(\d+(?:\.(?:(?!0+$)\d)+)?).*", "$1")
			}
		}
		else {
			r := "[]"
		}

		return (r)
	}

	;* array.Empty()
	;* Description:
		;* Removes all elements from an array.
	;* Note:
		;* This is the same as `array.Length := 0` but it returns a reference to `this` as opposed to the assigned value to allow for unreadable one line code.
	Empty() {
		this.RemoveAt(0, this.Length)

		return (this)
	}

	;* array.Sample(n)
	;* Description:
		;* Returns a new array with `n` random elements from an array.
	Sample(n := 0) {
		s := this.Length

		return (this.Clone().Shuffle().Slice(0, Math.Min(Math.Max((n == 0) ? (s) : (n), 0), s)))
	}

	;* array.Shuffle()
	;* Description:
		;* Fisher–Yates shuffle.  ;: https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
	Shuffle() {
		for i, v in (this, m := this.MaxIndex()) {
			u := Math.Random.Uniform(i, m)
				, t := this[i], this[i] := this[u], this[u] := t
		}

		return (this)
	}

	;* array.Swap(index1, index2)
	;* Description:
		;* Swap any two elements in an array.
	Swap(index1, index2) {
		m := this.MaxIndex()

		if (Math.IsBetween(index1, 0, m) && Math.IsBetween(index2, 0, m)) {  ;~ No error handling.
			t := this[index1], this[index1] := this[index2], this[index2] := t
		}

		return (this)
	}

	;--------------------------------------------------------  MDN  ----------------;  ;: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array, https://javascript.info/array-methods

	;* array.Concat(values*)
	;* Description:
		;* Merges two or more arrays. This method does not change the existing arrays, but instead returns a new array.
	Concat(values*) {
		for i, v in ([values*], r := this.Clone()) {
			if (v.__Class == "__Array") {
				for i, v in v {
					r.Push(v)
				}
			}
			else {
				r.Push(v)
			}
		}

		return (r)
	}

	;* array.Every(Func("FunctionName"))
	;* Description:
		;* Tests whether all elements in the array pass the test implemented by the provided function. It returns a Boolean value.
	;* Note:
		;* Calling this method on an empty array will return true for any condition.
	Every(callback) {
		for i, v in this {
			if (!callback.Call(v, i, this)) {
				return (0)
			}
		}

		return (1)
	}

	;* array.Fill((value), (start), (end))
	;* Description:
		;* Changes all elements in an array to a static value, from a start index (default: 0) to an end index (default: `array.Length`). It returns the modified array.
	Fill(value := "", start := 0, end := "") {
		s := this.Length
			, start := (start >= 0) ? (Math.Min(s, start)) : (Math.Max(s + start, 0))

		loop, % ((end != "") ? ((end >= 0) ? (Math.Min(s, end)) : (Math.Max(s + end, 0))) : s) - start {
			this[start++] := value
		}

		return (this)
	}

	;* array.Filter(Func("FunctionName"))
	;* Description:
		;* Creates a new array with all elements that pass the test implemented by the provided function.
	Filter(callback) {
		for i, v in (this, r := []) {
			if (callback.Call(v, i, this)) {
				r.Push(v)
			}
		}

		return (r)
	}

	;* array.Find(Func("FunctionName"))
	;* Description:
		;* Returns the value of the first element in the provided array that satisfies the provided testing function.
	Find(callback) {
		for i, v in this {
			if (callback.Call(v, i, this)) {
				return (v)
			}
		}

		return
	}

	;* array.FindIndex(Func("FunctionName"))
	;* Description:
		;* Returns the index of the first element in the array that satisfies the provided testing function. Otherwise, it returns -1, indicating that no element passed the test.
	FindIndex(callback) {
		for i, v in this {
			if (callback.Call(v, i, this)) {
				return (i)
			}
		}

		return (-1)
	}

	;* array.Flat((depth))
	;* Description:
		;* Creates a new array with all sub-array elements concatenated into it recursively up to the specified depth.
	Flat(depth := 1) {
		for i, v in (this, r := []) {
			if (v.__Class == "__Array" && depth > 0) {
				r := r.Concat(v.Flat(depth - 1))
			}
			else if (v != "") {  ;~ Skip empty elements.
				r.Push(v)
			}
		}

		return (r)
	}

	;* array.ForEach(Func("FunctionName"))
	;* Description:
		;* Executes a provided function once for each array element.
	ForEach(callback) {
		for i, v in this {
			this[i] := callback.Call(v, i, this)
		}
	}

	;* array.Includes(needle, (start))
	;* Description:
		;* Determines whether an array includes a certain value among its entries, returning true or false as appropriate.
	Includes(needle, start := 0) {
		return (start < this.Length && this.IndexOf(needle, start) != -1)
	}

	;* array.IndexOf(needle, (start))
	;* Description:
		;* Returns the first index at which a given element can be found in the array, or -1 if it is not present.
	IndexOf(needle, start := 0) {
		s := this.Length
			, start := (start >= 0) ? (Math.Min(s, start)) : (Math.Max(s + start, 0))

		if (this.StringCaseSense) {
			loop, % s - start {
				if (this[start] == needle) {
					return (start)
				}

				start++
			}
		}
		else {
			loop, % s - start {
				if (this[start] = needle) {
					return (start)
				}

				start++
			}
		}

		return (-1)
	}

	;* array.Join((delimiter))
	;* Description:
		;* Creates and returns a new string by concatenating all of the elements in an array (or an array-like object), separated by commas or a specified separator string. If the array has only one item, then that item will be returned without using the separator.
	Join(delimiter := ", ") {
		for i, v in (this, m := Round(this.MaxIndex())) {
			r .= ((IsObject(v)) ? ((v.__Class == "__Array") ? (v.Join(delimiter)) : ("[object Object]")) : (v))

			if (i < m) {
				r .= delimiter
			}
		}

		return (r)
	}

	;* array.LastIndexOf(needle, (start))
	;* Description:
		;* Returns the last index at which a given element can be found in the array, or -1 if it is not present. The array is searched backwards, starting at fromIndex.
	LastIndexOf(needle, start := -1) {
		start := ((start >= 0) ? (Math.Min(this.Length - 1, start)) : (Math.Max(this.Length + start, -1)))

		if (this.StringCaseSense) {
			while (start > -1) {
				if (this[start] == needle) {
					return (start)
				}

				start--
			}
		}
		else {
			while (start > -1) {
				if (this[start] = needle) {
					return (start)
				}

				start--
			}
		}

		return (-1)
	}

	;* array.Map(Func("FunctionName"))
	;* Description:
		;* Creates a new array populated with the results of calling a provided function on every element in the calling array.
	Map(callback) {
		for i, v in (this, r := []) {
			r.Push(callback.Call(v, i, this))
		}

		return (r)
	}

	;* array.Pop()
	;* Description:
		;* Removes the last element from an array and returns that element. This method changes the length of the array.
	Pop() {
		return (this.RemoveAt(this.MaxIndex()))
	}

	;* array.Push(elements*)
	;* Description:
		;* Adds one or more elements to the end of an array and returns the new length of the array.
	Push(elements*) {
		for i, v in ([elements*], s := this.Length) {
			this.InsertAt(s++, v)
		}

		return (s)
	}

	;* array.Reverse()
	;* Description:
		;* Reverses an array in place. The first array element becomes the last, and the last array element becomes the first.
	Reverse() {
		for i in (this, m := this.MaxIndex()) {
			this.InsertAt(m, this.RemoveAt(m - i))
		}

		return (this)
	}

	;* array.Shift()
	;* Description:
		;* Removes the first element from an array and returns that removed element. This method changes the length of the array.
	Shift() {
		return (this.RemoveAt(0))
	}

	;* array.Slice((start), (end))
	;* Description:
		;* Returns a shallow copy of a portion of an array into a new array object selected from begin to end (end not included) where begin and end represent the index of items in that array. The original array will not be modified.
	Slice(start := 0, end := "") {
		s := this.Length
			, start := ((start >= 0) ? (Math.Min(s, start)) : (Math.Max(s + start, 0)))

		loop, % (((end != "") ? ((end >= 0) ? (Math.Min(s, end)) : (Math.Max(s + end, 0))) : s) - start, r := []) {
			r.Push(this[start++])
		}

		return (r)
	}

	;* array.Some(Func("FunctionName"))
	;* Description:
		;* Tests whether at least one element in the array passes the test implemented by the provided function. It returns a Boolean value.
	;* Note:
		;* Calling this method on an empty array returns false for any condition.
	Some(callback) {
		for i, v in this {
			if (callback.Call(v, i, this)) {
				return (1)
			}
		}

		return (0)
	}

	;* array.Sort(Func("FunctionName"))
	;* Description:
		;* Sorts the elements of an array in place and returns the sorted array. The default sort order is ascending, built upon converting the elements into strings, then comparing their sequences of UTF-16 code units values.
	Sort(compareFunction := "__Sort") {
		z := A_StringCaseSense

		StringCaseSense, % this.StringCaseSense

		m := this.MaxIndex()

		while (c != 0) {
			loop, % (m, c := 0) {
				i := A_Index - 1

				if (%compareFunction%(this[i], this[A_Index]) > 0) {
					t := this[i], this[i] := this[A_Index], this[A_Index] := t

					c := 1
				}
			}
		}

		StringCaseSense, % z

		return (this)
	}

	;* array.Splice(start, (deleteCount), elements*)
	;* Description:
		;* Changes the contents of an array by removing or replacing existing elements and/or adding new elements in place.
	Splice(start, deleteCount := "", elements*) {
		s := this.Length, m := elements.MaxIndex()
			, start := (start >= 0) ? (Math.Min(s, start)) : (Math.Max(s + start, 0))

		loop, % (((deleteCount != "") ? (Math.Max((s <= start + deleteCount) ? (s - start) : (deleteCount), 0)) : ((m) ? (0) : (s))), r := []) {
			r.InsertAt(A_Index - 1, this.RemoveAt(start))
		}

		if (m) {
			this.InsertAt(start, elements*)
		}

		return (r)
	}

	;* array.UnShift(elements*)
	;* Description:
		;* Adds one or more elements to the beginning of an array and returns the new length of the array.
	UnShift(elements*) {
		for i, v in [elements*] {
			this.InsertAt(i, v)
		}

		return (this.Length)
	}
}

Class __Object {
    Static StringCaseSense := 1
		, ThrowException := 1

	;--------------- Method -------------------------------------------------------;

	;* Object.Print()
	;* Description:
		;* Converts an object into a string to more easily see the structure.
	Print() {
		if (c := this.Count()) {
			for k, v in (this, r := "{") {
				r .= k . ": " . ((IsObject(v)) ? (v.Print()) : (((Math.IsNumber(v)) ? (RegExReplace(v, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format("""{}""", v))))) . ((A_Index < c) ? (", ") : ("}"))
			}
		}
		else {
			r := "{}"
		}

		return (r)
	}
}

Class __String {
	Static __ := ("".Base.Base := __String)

	;-------------- Property ------------------------------------------------------;

	Length[] {

		;* "String".Length
		Get {
			return (StrLen(this))
		}
	}

	;--------------- Method -------------------------------------------------------;
	;------------------------------------------------------- Custom ---------------;

	;--------------------------------------------------------  MDN  ----------------;

	;* "String".ToLowerCase()
	ToLowerCase() {
		return (Format("{:L}", this))
	}

	;* "String".ToUpperCase()
	ToUpperCase() {
		return (Format("{:U}", this))
	}

	;* "String".Includes(needle, (start))
	Includes(needle, start := 0) {
		return (InStr(this, needle, 1, Math.Max(0, Math.Min(StrLen(this), Round(start))) + 1) != 0)
	}

	;* "String".IndexOf(needle, (start))
	IndexOf(needle, start := 0) {
		return (InStr(this, needle, 1, Math.Max(0, Math.Min(StrLen(this), Round(start))) + 1) - 1)
	}

	;* "String".Reverse()
	Reverse() {
		Static d := Chr(959)

		for i, v in StrSplit(StrReplace(this, d, "`r`n")) {
			r := v . r
		}

		return (StrReplace(r, "`r`n", d))  ;! DllCall("msvcrt\_" . (A_IsUnicode ? "wcs" : "Str") . "rev", "UInt", &this, "CDECL")
	}

	;* "String".Slice(start, (end))
	Slice(start, end := "") {
		m := StrLen(this)

		return (SubStr(this, start + 1, Max(((Math.IsInteger(end)) ? (((end >= 0) ? (Math.Min(m, end)) : (Math.Max(m + end, 0))) - ((start >= 0) ? (Math.Min(m, start)) : (Math.Max(m + start, 0)))) : (m)), 0)))
	}

	;* "String".Trim((characters))
	Trim(characters := " ") {
		return (Trim(this, characters))
	}
}
