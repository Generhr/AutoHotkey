# Assert.ahk

A unit test framework for AutoHotkey v2.0.

## Static methods

#### `Assert.IsEqual(result, expected)`

Checks if `result` and `expected` are equal. String comparisons are case-sensitive.

##### Parameters
1. [Any] result: The result value computed. Objects by themselves are automatically converted to string.
2. [Any] expected: The expected value. Objects by themselves are automatically converted to string.

##### Return
[Bool]: True if the values were the same, else false.

##### Example
```autohotkey
Assert.IsEqual("string", "tsring")  ; False

Assert.IsEqual((1 > 0 ), True)  ; True
```

#### `Assert.IsTrue(result)`
Checks if `result` is true.

##### Parameters
1. [Any] result: The result value computed.

##### Return
[Bool]: True if the value is true, else false.

##### Example
```autohotkey
Assert.IsTrue((1 == 1))  ; True

Assert.IsTrue(InStr("String", "S"))  ; True
```

#### `Assert.IsFalse(result)`
Checks if `result` is false.

##### Parameters
1. [Any] result: The result value computed.

##### Return
[Bool]: True if the value is false, else false.

##### Example
```autohotkey
Assert.IsFalse((1 != 1))  ; True

Assert.IsFalse(InStr("String", "X"))  ; True
```

#### `Assert.NotEqual(result, expected)`
Checks if result and expected are NOT the same or equal. The comparison is case-sensitive.

##### Parameters
1. [Any] result: The result value computed.
2. [Any] expected: The expected value.

##### Return
[Bool]: True if the value is false, else false.

##### Example
```autohotkey
Assert.NotEqual((1 != 1))  ; True

Assert.notEqual(InStr("String", "X"))  ; True
```


#### `Assert.IsNull(result)`
Checks if `result` is null or undefined (`""`).

##### Parameters
1. [Any] result: The result value computed.

##### Return
[Bool]: True if the value is `""`, else false.

##### Example
```autohotkey
Assert.IsFalse((1 != 1))  ; True

Assert.IsFalse(InStr("String", "X"))  ; True
```


#### `Assert.SetLabel(label)`
Labels the tests that follow for logs and readability.

##### Parameters
1. [String] label: A label for the next test(s) in sequence.


##### Example
```autohotkey
Assert.SetLabel("string comparisons")

Assert.IsEqual("String", "s")
Console.Log(Assert.CreateReport())
/*---------------------------
1 test completed with a 0% success rate (1 failure).

================================================== string comparisons ==========

Test #001
Result:
String
Expected:
s
---------------------------*/
```

#### `Assert.SetGroup(label)`
Appends the label to a group of following tests for logs and readability. This may be useful when one has a lot of tests; and doesn't want to type out a repeatative label.

##### Parameters
1. [String] label: A human readable label prepend for the next test(s) in sequence

##### Example
```autohotkey
Assert.SetGroup("Strings")
Assert.SetLabel("Comparison")
Assert.IsEqual("String", "s")

Assert.SetLabel("Length")
Assert.IsEqual(strLen("String"), 9)

Console.Log(Assert.CreateReport())
/*---------------------------
2 tests completed with a 0% success rate (2 failures).

================ Strings =======================================================
====================================================== Comparison ==============

Test #001
Result:
String
Expected:
s

======================================================== Length ================

Test #002
Result:
6
Expected:
9
---------------------------*/
```

#### `Assert.CreateReport()`

##### Return
[String]: The results of all tests done thus far.

##### Example
```autohotkey
Assert.IsTrue(InStr("String", "S"))

Console.Log(Assert.CreateReport())
/*---------------------------
1 test completed with a 100% success rate (0 failures).
---------------------------*/
```

#### `Assert.WriteResultsToFile([path, clear, open])`
Writes results of all tests done thus far to a file.

##### Parameters
1. [String] path: Optional, The file path to write all tests results to, the default is `A_Temp "\Assert.log"`.
2. [Bool] clear: Delete the file at `path` if it exists.
3. [Bool] open: Open the file if `True`.

##### Example
```autohotkey
Assert.IsTrue(InStr("String", "X"))

Assert.WriteResultsToFile()
/*1 test completed with a 0% success rate (1 failure).

Test #001
Result:
0
Expected:
1*/
```
