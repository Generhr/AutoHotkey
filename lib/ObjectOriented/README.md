# ObjectOriented.ahk

Ported most of the MDN prototype as well as some custom methods for use with ahk objects and adjusted the base index of arrays to zero.

## Warning for this lib:

Arrays are adjusted to start at 0 but because variadic arrays have no base class, they remain at 1 which is very inconsistent and also breaks `[1, 2, 3]*`.

## Array Properties

#### `.Count[[skipEmpty]]`
Alias: `.Count([skipEmpty])`

Returns the number of enumerable properties.

##### Example

```autohotkey
[1, 2, , 4].Count  ; 4
[1, 2, , 4].Count[1]  ; 3 (Passing the skipEmpty flag skips over null elements)
```

#### `.Length[ := value]`

#### Get

Returns the length of the array.

#### Set

Either truncates the array if less than the current length of the array or else adds new elements to satisfy the new length.

##### Example

```autohotkey
array := [0, 1, 2]
array[9] := 9
MsgBox, % array.Length  ; 10

array.Length := 1
MsgBox, % array.Print()  ; "[0]"
```

## Array methods

#### `.Print()`

Converts the array into a string to more easily see the structure.

##### Example

```autohotkey
array := [0, 1, 2]
MsgBox, % array.Print()  ; "[0, 1, 2]"
```

#### `.Compact([recursive])`

Remove all falsy values from an array.

##### Example

```autohotkey
array := [0, , 2, ""]
MsgBox, % array.Compact().Print()  ; "[0, 2]"
```

#### `.Empty()`

Removes all elements from an array.

##### Example

```autohotkey
array := [0, 1, 2]
MsgBox, % array.Empty().Print()  ; "[]"
```

#### `.Sample([n])`

Returns a new array with `n` random elements from an array.

##### Example

```autohotkey
array := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
MsgBox, % array.Sample(5).Print()  ; Potential result: "[5, 9, 6, 1, 3]"
```

#### `.Shuffle()`

Fisher–Yates shuffle (https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle).

##### Example

```autohotkey
array := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
MsgBox, % array.Shuffle().Print()  ; Potential result: "[2, 8, 5, 9, 4, 3, 6, 0, 7, 1]"
```

#### `.Swap(index1, index2)`

Swap any two elements in an array.

##### Example

```autohotkey
array := [[0], 1, 2, 3, 4, 5, 6, 7, 8, {"Nine": 9}]
MsgBox, % array.Swap(0, 9).Print()  ; [{Nine: 9}, 1, 2, 3, 4, 5, 6, 7, 8, [0]]
```

#### `.Concat(values*)`

Merges two or more arrays. This method does not change the existing arrays, but instead returns a new array.

##### Example

```autohotkey
array := [[2, 3], [4, 5, 6], [8, 9, 10]]
MsgBox, % [1].Concat(array[0], array[1], 7, array[2]).Print()  ; [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

#### `.Every(Func("FunctionName"))`

Tests whether all elements in the array pass the test implemented by the provided function. It returns a Boolean value.

##### Example

```autohotkey
array := [1, 30, 39, 29, 10, 13]
MsgBox, % array.Every(Func("Every"))  ; True

Every(element) {
    return (element < 40)
}
```

#### `.Fill([value[, start[, end]]])`

Changes all elements in an array to a static value, from a start index (default: 0) to an end index (default: `array.Length`). It returns the modified array.

##### Example

```autohotkey
array := [0, 1, 2, , 4]
MsgBox, % array.Fill(0).Print()  ; "[0, 0, 0, 0, 0]"
```

#### `.Filter(Func("FunctionName"))`

Creates a new array with all elements that pass the test implemented by the provided function.

##### Example

```autohotkey
MsgBox, % ["Spray", "Limit", "Elite", "Exuberant", "Destruction", "Present"].Filter(Func("Filter")).Print()  ; "["Exuberant", "Destruction", "Present"]"

Filter(element) {
    return (StrLen(element) > 5)
}
```

#### `.Find(Func("FunctionName"))`

Returns the value of the first element in the provided array that satisfies the provided testing function.

##### Example

```autohotkey
MsgBox, % [5, 12, 8, 130, 44].Find(Func("Find"))  ; 12

Find(element) {
    return (element > 10)
}
```

#### `.FindIndex(Func("FunctionName"))`

Returns the index of the first element in the array that satisfies the provided testing function. Otherwise, it returns -1, indicating that no element passed the test.

##### Example

```autohotkey
MsgBox, % [5, 12, 8, 130, 44].FindIndex(Func("FindIndex"))  ; 3

FindIndex(element) {
    return (element > 12)
}
```

#### `.Flat([depth])`

Creates a new array with all sub-array elements concatenated into it recursively up to the specified depth.

##### Example

```autohotkey
MsgBox, % [1, 2, , 3, [[4]], [5]].Flat().Print()  ; "[1, 2, 3, [4], 5]"
```

#### `.ForEach(Func("FunctionName"))`

Executes a provided function once for each array element.

##### Example

```autohotkey
(array := [1, 3, , 7]).ForEach(Func("ForEach"))
MsgBox, % array.Print()  ; "[0, 2, "", 6]"

ForEach(element) {
    return (element - 1)
}
```

#### `.Includes(needle[, start])`

Determines whether an array includes a certain value among its entries, returning true or false as appropriate.

##### Example

```autohotkey
MsgBox, % [1, 2, 3].Includes("3", 3)  ; False
MsgBox, % [1, 2, 3].Includes("3", -1)  ; True
MsgBox, % [1, 2, 3].Includes("3", 0)  ; True
```

#### `.IndexOf(needle[, start])`

Returns the first index at which a given element can be found in the array, or -1 if it is not present.

##### Example

```autohotkey
MsgBox, % ["ant", "bison", "camel", "", "bison"].IndexOf("bison")  ; 1
MsgBox, % ["ant", "bison", "camel", "", "bison"].IndexOf("bison", 2)  ; 4
```

#### `.Join([delimiter])`

Creates and returns a new string by concatenating all of the elements in an array (or an array-like object), separated by commas or a specified separator string. If the array has only one item, then that item will be returned without using the separator.

##### Example

```autohotkey
MsgBox, % [0, 1, 2, 3, 4].Join("xXx")  ; 0xXx1xXx2xXx3xXx4
MsgBox, % [0, 1, 2, 3, 4].Join()  ; 0, 1, 2, 3, 4
```

#### `.LastIndexOf(needle[, start])`

Returns the last index at which a given element can be found in the array, or -1 if it is not present. The array is searched backwards, starting at fromIndex.

##### Example

```autohotkey
array := [2, 5, 9, 2, "", 1]
MsgBox, % array.LastIndexOf(2)  ; 3
MsgBox, % array.LastIndexOf(7)  ; -1
```

#### `.Map(Func("FunctionName"))`

Returns the last index at which a given element can be found in the array, or -1 if it is not present. The array is searched backwards, starting at fromIndex.

##### Example

```autohotkey
array := [1, 4, 9, 16]
MsgBox, % array.Map(Func("Map")).Print()  ; "[2, 8, 18, 32]"
MsgBox, % array.Print()  ; "[1, 4, 9, 16]"

Map(element) {
    return (element*2)
}
```

#### `.Pop()`

Removes the last element from an array and returns that element. This method changes the length of the array.

#### `.Push(elements*)`

Adds one or more elements to the end of an array and returns the new length of the array.

#### `.Reduce(Func("FunctionName"))`

Executes a callback function on each element of the array, resulting in a single output value.

##### Example

```autohotkey
array := [1, 2, 3, 4]
MsgBox, % array.Reduce(Func("Reduce"))  ; 10

Reduce(accumulator, currentValue) {
    return (accumulator + currentValue)
}
```

#### `.ReduceRight(Func("FunctionName"))`

Executes a callback function on each element of the array from right to left, resulting in a single output value.

##### Example

```autohotkey
MsgBox, % [[0, 1], [2, 3], [4, 5]].ReduceRight(Func("ReduceRight")).Print()  ; "[4, 5, 2, 3, 0, 1]"

ReduceRight(element1, element2) {
    return (element1.Concat(element2))
}
```

#### `.Reverse()`

Reverses an array in place. The first array element becomes the last, and the last array element becomes the first.

##### Example

```autohotkey
MsgBox, % [0, 1, 2, 3, , 5].Reverse().Print()  ; "[5, "", 3, 2, 1, 0]"
```

#### `.Shift()`

Removes the first element from an array and returns that removed element. This method changes the length of the array.

#### `.Slice([start[, end]])`

Returns a shallow copy of a portion of an array into a new array object selected from begin to end (end not included) where begin and end represent the index of items in that array. The original array will not be modified.

##### Example

```autohotkey
MsgBox, % ["ant", "bison", "camel", "duck", "elephant"].Slice(2).Print()  ; "["camel", "duck", "elephant"]"
```

#### `.Some(Func("FunctionName"))`

Tests whether at least one element in the array passes the test implemented by the provided function. It returns a Boolean value.

##### Example

```autohotkey
MsgBox, % [1, 2, 3, 4, 5].Some(Func("Some"))  ; 1
MsgBox, % [1, 3, 5, 7, 9].Some(Func("Some"))  ; 0

Some(element) {
    return (Mod(element, 2) == 0)
}
```

#### `.Sort([Func("FunctionName")])`

Sorts the elements of an array in place and returns the sorted array. The default sort order is ascending, built upon converting the elements into strings, then comparing their sequences of UTF-16 code units values.

##### Example

```autohotkey
MsgBox, % ["March", "Jan", "Feb", "Dec"].Sort().Print()  ; "["Dec", "Feb", "Jan", "March"]"
```

#### `.Splice(start[, deleteCount[, elements*]])`

Changes the contents of an array by removing or replacing existing elements and/or adding new elements in place.

##### Example

```autohotkey
(array := ["Jan", "March", "April", "June"]).Splice(1, 0, "Feb")
MsgBox, % array.Print()  ; "["Jan", "Feb", "March", "April", "June"]"
```

#### `.UnShift(elements*)`

Adds one or more elements to the beginning of an array and returns the new length of the array.

## Object methods

#### `.Print()`

Converts an object into a string to more easily see the structure.

##### Example

```autohotkey
MsgBox, % {"One": 1, "Two": 2, "Three": 3, "Four": 4, "Five": 5}.Print()  ; "{Five: 5, Four: 4, One: 1, Three: 3, Two: 2}"
```

## String methods
