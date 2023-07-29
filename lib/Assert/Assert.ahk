#Requires AutoHotkey v2.0.0

/*
* The MIT License (MIT)
*
* Copyright (c) 2021 - 2023, Chad Blease
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

class Assert {
    static tests := 0, failures := 0, successes := 0
        , log := []

    __New(params*) {
        throw (TargetError("This class may not be constructed.", -1))
    }

    static SetGroup(name) {
        this.Group := name
    }

    static SetLabel(name) {
        this.Label := name
    }

    static Test(result, expected, negate := False) {
        this.Tests++

        if (IsObject(result)) {
            result := __Print(result)
        }

        if (IsObject(expected)) {
            expected := __Print(expected)
        }

        __Print(input) {
            if (input is Array) {
                if (length := input.Length) {
                    out := "["

                    for value in input {
                        if (!IsSet(value)) {
                            value := ""
                        }

                        out .= ((IsObject(value)) ? (__Print(value)) : ((IsNumber(value)) ? (RegExReplace(value, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format('"{}"', value)))) . ((A_Index < length) ? (", ") : ("]"))
                    }
                }
                else {
                    out := "[]"
                }
            }
            else if (input is Object) {
                if (count := ObjOwnPropCount(input)) {
                    out := "{"

                    for key, value in (input.OwnProps()) {
                        out .= key . ": " . ((IsObject(value)) ? (__Print(value)) : ((IsNumber(value)) ? (RegExReplace(value, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format('"{}"', value)))) . ((A_Index < count) ? (", ") : ("}"))
                    }
                }
                else {
                    out := "{}"
                }
            }
            else {
                out := input
            }

            return (out)
        }

        if (~((result == expected) - (negate + 1))) {  ;* The bitwise operator will return a truthy value for anything but -1.
            this.Successes++

            return (True)
        }
        else {
            this.Failures++

            static currentGroup := ""

            if (this.HasProp("Group") && this.Group != currentGroup) {
                currentGroup := this.Group
                    , stringLength := StrLen(currentGroup), subtract := Ceil(stringLength/2) + 1

                this.Log.Push("`n" . StrReplace(Format("{:0" . 20 - subtract + (stringLength & 1) . "}", 0), "0", "=")
                    . Format(" {} ", currentGroup)
                    . StrReplace(Format("{:0" . 60 - subtract . "}", 0), "0", "="))
            }

            static currentLabel := ""

            if (this.HasProp("Label") && this.Label != currentLabel) {
                currentLabel := this.Label
                    , stringLength := StrLen(currentLabel), subtract := Ceil(stringLength/2) + 1

                this.Log.Push("`n" . StrReplace(Format("{:0" . 60 - subtract + (stringLength & 1) . "}", 0), "0", "-")
                    . Format(" {} ", currentLabel)
                    . StrReplace(Format("{:0" . 20 - subtract . "}", 0), "0", "-") . "`n")
            }

            this.Log.Push(Format("`nTest #{}", SubStr("000" . this.Tests, -2))
                . Format("`nResult{}:`n{}", (negate) ? (" (expected to be different)") : (""), result)
                . Format("`nExpected:`n{}", expected))

            this.Log.Push("`n")

            return (False)
        }
    }

    static IsEqual(result, expected) {
        return (this.Test(result, expected))
    }

    static IsNotEqual(result, expected) {
        return (this.Test(result, expected, True))
    }

    static IsTrue(result) {
        return (this.Test(result, True))
    }

    static IsFalse(result) {
        return (this.Test(result, False))
    }

    static IsNull(result) {
        return (this.Test(result, ""))
    }

    static IsSet(result := unset) {
        return (this.Test(IsSet(result), True))
    }

    static CreateReport() {
        try {  ;* Catch for `ZeroDivisionError` if `this.Tests` is zero.
            report := Format("{} {} completed with a {}% success rate ({} {}).`n", this.Tests, (this.Tests == 1) ? ("test") : ("tests"), Floor((this.Successes/this.Tests)*100), this.Failures, (this.Failures == 1) ? ("failure") : ("failures"))

            for entry in this.Log {
                report .= entry
            }

            return (report)
        }
    }

    static WriteResultsToFile(path := "", clear := True, open := True) {
        if (!path) {
            static default := A_Temp . "\Assert.log"

            path := default
        }

        if (clear) {
            try {
                FileDelete(path)
            }
        }

        FileAppend(this.CreateReport(), path)

        if (open) {
            Run(path)
        }
    }
}
