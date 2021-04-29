Assert.ahk
===========

A unit test framework for AutoHotkey

## Installation

In a terminal or command line navigated to your project folder:
```bash
npm install unit-testing.ahk
```

In your code:
```autohotkey
#Include %A_ScriptDir%\node_modules
#Include unit-testing.ahk\export.ahk

testVar := 2 + 2
Assert.IsEqual(testVar, 4)
Assert.Report()
```
You may also review or copy the library from [./export.ahk on GitHub](https://github.com/Chunjee/unit-testing.ahk); #Include as you would normally when manually downloading.


## Usage

Grants access to a class named `Assert` with the following methods: `.IsEqual`, `.IsTrue`, `.IsFalse`, `.IsNotEqual`, `.SetLabel`, `.SetGroup`, `.Report`, and `.WriteResultsToFile`

```autohotkey

; .IsEqual checks and logs whether or not both arguments are the same
Assert.SetLabel("string comparison")
Assert.IsEqual("StringExample", "StringExample")

Assert.SetLabel("value testing")
Assert.IsEqual((1 > 0 ), True)

Assert.SetLabel("true/false testing")
Assert.IsTrue((1 == 1))
Assert.IsFalse((1 != 1))
Assert.IsNotEqual(true, false)

Assert.Report()
Assert.WriteResultsToFile()
```

## API

### .IsEqual(result, expected)

Alias: `.Test`

Checks if the result and expected are the same or equal. The comparison is case-sensitive.

##### Arguments
1. result (*): The result value computed.
2. expected (*): The expected value.

##### Returns
(boolean): Returns true if the values were the same, else false.

##### Example
```autohotkey
Assert.IsEqual("string", "tsring")
; => False

Assert.IsEqual((1 > 0 ), True)
; => True
```


### .IsTrue(result)
Checks if result value is true.

##### Arguments
1. result (*): The result value computed.

##### Returns
(boolean): Returns true if the value is true, else false.

##### Example
```autohotkey
Assert.IsTrue((1 == 1))
; => True

Assert.IsTrue(InStr("String", "S"))
; => True
```


### .IsFalse(result)
Checks if result value is false.

##### Arguments
1. result (*): The result value computed.

##### Returns
(boolean): returns true if the value is false, else false.

##### Example
```autohotkey
Assert.IsFalse((1 != 1))
; => True

Assert.IsFalse(InStr("String", "X"))
; => True
```


### .notEqual(result, expected)
Checks if result and expected are NOT the same or equal. The comparison is case-insensitive when ahk is `inStringCaseSense, Off` (default ahk behavior).

##### Arguments
1. result (*): The result value computed.
2. expected (*): The expected value

##### Returns
(boolean): returns true if the value is false, else false.

##### Example
```autohotkey
Assert.notEqual((1 != 1))
; => True

Assert.notEqual(InStr("String", "X"))
; => True
```


### .undefined(result)
Checks if result is undefined (`""`).

##### Arguments
1. result (*): The result value computed.

##### Returns
(boolean): returns true if the value is `""`, else false.

##### Example
```autohotkey
Assert.IsFalse((1 != 1))
; => True

Assert.IsFalse(InStr("String", "X"))
; => True
```


### .SetLabel(label)
Labels the tests that follow for logs and readability.

##### Arguments
1. label (string): A human readable label for the next test(s) in sequence.


##### Example
```autohotkey
Assert.SetLabel("string comparisons")

Assert.IsEqual("String", "s")
Assert.Report()
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

### .SetGroup(label)
appends the label to a group of following tests for logs and readability

This may be useful when one has a lot of tests; and doesn't want to type out a repeatative label

##### Arguments
1. label (string): A human readable label prepend for the next test(s) in sequence


##### Example
```autohotkey
Assert.SetGroup("strings")
Assert.SetLabel("comparison")
Assert.IsEqual("String", "s")

Assert.SetLabel("length")
Assert.IsEqual(strLen("String"), 9)

Assert.Report()
/*---------------------------
2 tests completed with a 0% success rate (2 failures).

================ strings =======================================================
====================================================== comparison ==============

Test #001
Result:
String
Expected:
s

======================================================== length ================

Test #002
Result:
6
Expected:
9
---------------------------*/
```


### .Report()
Display the results of all tests in a console window.

##### Example
```autohotkey
Assert.IsTrue(InStr("String", "S"))

Assert.Report()
/*---------------------------
1 test completed with a 100% success rate (0 failures).
---------------------------*/
```


### .WriteResultsToFile([path])
writes test results to a file

##### Arguments
1. filepath (string): Optional, The file path to write all tests results to, the default is `A_ScriptDir "\Assert.log"`.

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
