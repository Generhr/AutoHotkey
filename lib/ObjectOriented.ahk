;=====           Function           =========================;

Array(_Parameter*) {
	r := new __Array

	Loop, % _Parameter.Length()
		r[A_Index - 1] := _Parameter[A_Index]

	Return, (r)
}

Object(_Parameter*) {
	r := new __Object

	Loop, % _Parameter.Count()//2
		r[_Parameter[(i := A_Index*2) - 1]] := _Parameter[i]

	Return, (r)
}

__Sort(_Value1, _Value2) {
	Return, (_Value1 < _Value2 ? -1 : _Value1 > _Value2 ? 1 : 0)
}

;=====            Class             =========================;

Class __Array {

	;-----           Property           -------------------------;

;*	Array.Count
;*	Description:
;*		Returns the number of enumerable properties in the array.
	Count[] {
		Get {
			For i, v in this
				r += (v != "")

			Return, (Round(r))
		}
	}

;*	Array.Length[ := Integer]
;*	Description:
;*		The Length property of an object which is an instance of type Array sets or returns the number of elements in that array. The value is an unsigned, 32-bit integer that is always numerically greater than the highest index in the array.
	Length[] {
		Get {
			Return, (Round(this.MaxIndex() + 1))
		}

		Set {
			If (value ~= "^[0-9]+$") {
				o := value - (s := Round(this.MaxIndex() + 1))

				Loop, % Math.Abs(o)
					(o < 0) ? this.RemoveAt(--s) : this[s++] := ""  ;? ["" || "undefined"].

				Return, (s)
			}
			Throw, (Exception("Invalid assignment.", -1, Format("""{}"" is invalid. This property may only be assigned a possitive integer.", value)))
		}
	}

	;-----            Method            -------------------------;

	;---------------            Custom            ---------------;

;*	[String := ]Array.Print()
;*	Description:
;*		Converts the array into a string to more easily see the structure. No effort has been made to handle FuncObj/ComObj however.
	Print() {
		m := this.MaxIndex()

		For i, v in this
			r .= (i == 0 ? "[" : "") . (IsObject(v) ? v.Print() : (v == "" || Type(v) == "String" ? Format("""{}""", v) : v)) . (i < m ? ", " : "]")

		Return, (r ? r : "[]")
	}

;*	Array.Empty()
;*	Description:
;*		Removes all elements in an array.
;*	Note:
;*		This is the same as `Array.Length := 0` but it returns a reference to `this` instead of the new length to allow for unreadable one line code. Winning.
	Empty() {
		this.RemoveAt(0, Round(this.MaxIndex() + 1))

		Return, (this)
	}

;*	Array.Shuffle()
;*	Description:
;*		Fisher–Yates shuffle (https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle).
	Shuffle() {
		Loop, % s := this.MaxIndex()
			this.Swap(i := A_Index - 1, Math.Random(i, s))

		Return, (this)
	}

;*	Array.Swap(_Index1, _Index2)
;*	Description:
;*		Swap any two elements in an array.
	Swap(_Index1, _Index2) {
		m := this.MaxIndex()

		If (_Index1 >= 0 && _Index1 <= m && _Index2 >= 0 && _Index2 <= m) {  ;- No error handling.
			t := this[_Index1]

			this[_Index1] := this[_Index2]
			this[_Index2] := t
		}

		Return, (this)
	}

	;---------------             MDN              ---------------;  ;? https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array

;*	Array := Array.Concat([_Value1[, _Value2[, ...[, _ValueN]]]])
;
;*	Description:
;*		Merges two or more arrays. This method does not change the existing arrays, but instead returns a new array.
	Concat(_Value*) {
		r := this.Clone()

		Loop, % _Value.Length() {  ;* Using a loop because enumerating with the variadic parameter will skip empty elements.
			v := _Value[A_Index]

			If (Type(v) == "Array")
				For i, v in v
					r.Push(v)
			Else
				r.Push(v)
		}

		Return, (r)
	}

;*	Array.Every(Func("Function"))
;*	Description:
;*		Tests whether all elements in the array pass the test implemented by the provided function. It returns a Boolean value.
;*	Note:
;*		Calling this method on an empty array will return true for any condition.
	Every(_Callback) {
		For i, v in this
			If (!_Callback.Call(v, i, this))
				Return, (0)

		Return, (1)
	}

;*	Array.Fill(_Value[, _Start[, _End]])
;*	Description:
;*		Changes all elements in an array to a static value, from a start index (default 0) to an end index (default Array.Length). It returns the modified array.
	Fill(_Value := "", _Start := 0, _End := "undefined") {  ;? _Value := ["" || "undefined"].
		s := Round(this.MaxIndex() + 1)

		Loop, % (_End != "undefined" ? _End >= 0 ? Math.Min(s, _End) : Math.Max(s + _End, 0) : s) - _Start := _Start >= 0 ? Math.Min(s, _Start) : Math.Max(s + _Start, 0)
			this[_Start++] := _Value

		Return, (this)
	}

;*	Array := Array.Filter(Func("Function"))
;*	Description:
;*		Creates a new array with all elements that pass the test implemented by the provided function.
	Filter(_Callback) {
		r := []

		For i, v in this
			If (_Callback.Call(v, i, this))
				r.Push(v)

		Return, (r)
	}

;*	Array.Find(Func("Function"))
;*	Description:
;*		Returns the value of the first element in the provided array that satisfies the provided testing function.
	Find(_Callback) {
		For i, v in this
			If (_Callback.Call(v, i, this))
				Return, (v)

		Return, ("")  ;? ["" || "undefined"].
	}

;*	Array.FindIndex(Func("Function"))
;*	Description:
;*		Returns the index of the first element in the array that satisfies the provided testing function. Otherwise, it returns -1, indicating that no element passed the test.
	FindIndex(_Callback) {
		For i, v in this
			If (_Callback.Call(v, i, this))
				Return, (i)

		Return, (-1)
	}

;*	Array := Array.Flat([_Depth])
;*	Description:
;*		Creates a new array with all sub-array elements concatenated into it recursively up to the specified depth.
	Flat(_Depth := 1) {
		r := []

		For i, v in this
			If (Type(v) == "Array" && _Depth > 0)
				r := r.Concat(v.Flat(_Depth - 1))
			Else If (v != "")  ;* Skip empty elements.
				r.Push(v)

		Return, (r)
	}

;*	Array.ForEach(Func("Function"))
;*	Description:
;*		Executes a provided function once for each array element.
	ForEach(_Callback) {
		For i, v in this
			If (v != "")
				this[i] := _Callback.Call(v, i, this)
	}

;*	Array.Includes(_Needle[, _Start])
;*	Description:
;*		Determines whether an array includes a certain value among its entries, returning true or false as appropriate.
	Includes(_Needle, _Start := 0) {
		Return, (_Start <= this.MaxIndex() && this.IndexOf(_Needle, _Start) != -1)
	}

;*	Array.IndexOf(_Needle[, _Start])
;*	Description:
;*		Returns the first index at which a given element can be found in the array, or -1 if it is not present.
	IndexOf(_SearchElement, _Start := 0) {
		s := Round(this.MaxIndex() + 1)

		Loop, % s - _Start := _Start >= 0 ? Math.Min(s, _Start) : Math.Max(s + _Start, 0) {
			If (this[_Start] == _SearchElement)  ;- Case sensitive.
				Return, (_Start)

			_Start++
		}

		Return, (-1)
	}

;*	Array.Join([_Delimiters])
;*	Description:
;*		Creates and returns a new string by concatenating all of the elements in an array (or an array-like object), separated by commas or a specified separator string. If the array has only one item, then that item will be returned without using the separator.
	Join(_Delimiters := ", ") {
		m := Round(this.MaxIndex())

		For i, v in this
			r .= (IsObject(v) ? Type(v) == "Array" ? v.Join(_Delimiters) : "[object Object]" : v) . (i < m ? _Delimiters : "")

		Return, (r)
	}

;*	Array.LastIndexOf(_Needle[, _Start])
;*	Description:
;*		Returns the last index at which a given element can be found in the array, or -1 if it is not present. The array is searched backwards, starting at fromIndex.
	LastIndexOf(_Needle, _Start := -1) {
		s := Round(this.MaxIndex() + 1)
			, _Start := (_Start >= 0 ? Math.Min(s - 1, _Start) : Math.Max(s + _Start, -1))

		While (_Start > -1) {
			If (this[_Start] == _Needle)  ;- Case sensitive.
				Return, (_Start)

			_Start--
		}

		Return, (-1)
	}

;*	Array.Map(Func("Function"))
;*	Description:
;*		Creates a new array populated with the results of calling a provided function on every element in the calling array.
	Map(_Callback) {
		r := []

		For i, v in this
			r[i] := (_Callback.Call(v, i, this))

		Return, (r)
	}

;*	Array.Pop()
;*	Description:
;*		Removes the last element from an array and returns that element. This method changes the length of the array.
	Pop() {
		Try
			Return, (this.RemoveAt(this.MaxIndex()))
		Catch
			Return, ("")  ;? ["" || "undefined"].
	}

;*	Array.Push([_Element1[, _Element2[, ...[, _ElementN]]]])
;*	Description:
;*		Adds one or more elements to the end of an array and returns the new length of the array.
	Push(_Element*) {
		s := Round(this.MaxIndex() + 1)

		Loop, % _Element.Length()
			this.InsertAt(s++, _Element[A_Index])

		Return, (s)
	}

;*	Array.Reverse()
;*	Description:
;*		Reverses an array in place. The first array element becomes the last, and the last array element becomes the first.
	Reverse() {
		Loop, % s := Round(this.MaxIndex() + 1)
			this.InsertAt(s - 1, this.RemoveAt(s - A_Index))

		Return, (this)
	}

;*	Array.Shift()
;*	Description:
;*		Removes the first element from an array and returns that removed element. This method changes the length of the array.
	Shift() {
		Return, (this.RemoveAt(0))  ;? [this.RemoveAt(0) || Round(this.MaxIndex() + 1) ? this.RemoveAt(0) : "undefined"].
	}

;*	Array.Slice([_Start[, _End]])
;*	Description:
;*		Returns a shallow copy of a portion of an array into a new array object selected from begin to end (end not included) where begin and end represent the index of items in that array. The original array will not be modified.
	Slice(_Start := 0, _End := "undefined") {
		s := Round(this.MaxIndex() + 1), r := []

		Loop, % (_End != "undefined" ? _End >= 0 ? Math.Min(s, _End) : Math.Max(s + _End, 0) : s) - _Start := (_Start >= 0 ? Math.Min(s, _Start) : Math.Max(s + _Start, 0))
			r.Push(this[_Start++])

		Return, (r)
	}

;*	Array.Some(Func("Function"))
;*	Description:
;*		Tests whether at least one element in the array passes the test implemented by the provided function. It returns a Boolean value.
;*	Note:
;*		Calling this method on an empty array returns false for any condition.
	Some(_Callback) {

		For i, v in this
			If (_Callback.Call(v, i, this))
				Return, (1)

		Return, (0)
	}

;*	Array.Sort([_CompareFunction])
;*	Description:
;*		Sorts the elements of an array in place and returns the sorted array. The default sort order is ascending, built upon converting the elements into strings, then comparing their sequences of UTF-16 code units values.
;*	Note:
;*		Use `StringCaseSense, [On || Off]` with the default _CompareFunction to control case sensetivity.
	Sort(_CompareFunction := "__Sort") {
		s := Round(this.MaxIndex())

		While (c != 0) {
			c := 0

			Loop, % s
				If (%_CompareFunction%(this[A_Index - 1], this[A_Index]) > 0)
					this.Swap(A_Index - (c := 1), A_Index)

			s--
		}

		Return, (this)
	}

;*	Array.Splice(_Start[, _DeleteCount[, _Element1[, _Element2[, ...[, _ElementN]]]]])
;*	Description:
;*		Changes the contents of an array by removing or replacing existing elements and/or adding new elements in place.
	Splice(_Start, _DeleteCount := "undefined", _Element*) {
		s := Round(this.MaxIndex() + 1), m := _Element.MaxIndex(), r := []

		Loop, % (_DeleteCount != "undefined" ? Math.Max(s <= (_Start := _Start >= 0 ? Math.Min(s, _Start) : Math.Max(s + _Start, 0)) + _DeleteCount ? s - _Start : _DeleteCount, 0) : m ? 0 : s)
			r.InsertAt(A_Index - 1, this.RemoveAt(_Start))

		If (m)
			this.InsertAt(_Start, _Element*)

		return (r)
	}

;*	Array.UnShift(_Element1[, _Element2[, ...[, _ElementN]]])
;*	Description:
;*		Adds one or more elements to the beginning of an array and returns the new length of the array.
	UnShift(_Element*) {
		s := Round(this.MaxIndex() + (m := _Element.MaxIndex()) + 1)

		Loop, % m
			this.InsertAt(A_Index - 1, _Element[A_Index])

		Return, (s)
	}
}

Class __Object {

;*	Object.Print()
;*	Description:
;*		Returns the number of key-value pairs present in the object.
	Print() {
		c := this.Count()

		For k, v in this
			r .= (A_Index = 1 ? "{" : "") . k . ": " . (IsObject(v) ? v.Print() : (v == "" || Type(v) == "String" ? Format("""{}""", v) : v)) . (A_Index < c ? ", " : "}")

		Return, (r ? r : "{}")
	}
}
