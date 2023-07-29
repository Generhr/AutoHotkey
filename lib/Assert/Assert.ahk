;==============  Include  ======================================================;

#Include, %A_LineFile%\..\..\Core.ahk

#Include, %A_LineFile%\..\..\Console\Console.ahk

;===============  Class  =======================================================;

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
            result := Print(result)
        }

        if (IsObject(expected)) {
            expected := Print(expected)
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
        Console.Write(this.BuildReport())
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
}
