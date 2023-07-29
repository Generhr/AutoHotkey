#Requires AutoHotkey v2.0.0

/*
* The MIT License (MIT)
*
* Copyright (c) 2020 - 2023, Chad Blease
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

;============ Auto-Execute ====================================================;

PatchString()

;============== Function ======================================================;
;---------------  Patch  -------------------------------------------------------;

PatchString() {

    ;======================================================== Base ================;
    ;---------------------------------------------------- IsPalindrome ------------;

    String.Base.DefineProp("IsPalindrome", {Call: (this, text) => (RegExReplace(text, "S)[\s.,?!;']") = DllCall("msvcrt\_wcsrev", "Str", RegExReplace(text, "S)[\s.,?!;']"), "UInt", 0, "Str"))})

    ;-------------------------------------------------------  IsUrl  ---------------;

    String.Base.DefineProp("IsUrl", {Call: __IsUrl})

    __IsUrl(this, text) {
        static needle := "S)((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)"

        return (text ~= needle)
    }

    ;------------------------------------------------------  Inverse  --------------;

    ;* String.Inverse(text)
    String.Base.DefineProp("Inverse", {Call: (this, text) => (RegExReplace(text, "([A-Z])|([a-z])", "$L1$U2"))})

    ;------------------------------------------------------- Repeat ---------------;

    ;* String.Repeat(text, times)
    String.Base.DefineProp("Repeat", {Call: (this, text, times) => (StrReplace(Format("{:0" . times . "}", 0), "0", text))})

    ;------------------------------------------------------  Reverse  --------------;

    String.Base.DefineProp("Reverse", {Call: (this, text) => (__Reverse(text))})

    ;* String.Reverse(text)
    __Reverse(text) {
        static d := Chr(959)

        for letter in (out := "", StrSplit(StrReplace(text, d, "`r`n"))) {
            out := letter . out
        }

        return (StrReplace(out, "`r`n", d))  ;! DllCall("msvcrt\_wcsrev", "Ptr", StrPtr(this), "UInt", 0, "Str")
    }

    ;-------------------------------------------------------  Split  ---------------;

    ;* String.Split(text[, delimiter, omitChars, maxParts])
    ;* Description:
        ;* Separates a string into an array of substrings using the specified delimiters.
    String.Base.DefineProp("Split", {Call: (this, params*) => (StrSplit(params*))})

    ;-------------------------------------------------------  Strip  ---------------;

    ;* String.Strip(text, characters)
    ;* Description:
        ;* Remove all occurrences of `characters` from a string.
    String.Base.DefineProp("Strip", {Call: (this, text, characters) => (RegExReplace(text, "[" . characters . "]"))})

    ;-------------------------------------------------------  Split  ---------------;

    ;* String.Split(text[, characters])
    ;* Description:
        ;* Removes leading and trailing `characters` from a string.
    String.Base.DefineProp("Trim", {Call: (this, params*) => (Trim(params*))})

    ;------------------------------------------------------- Buffer ---------------;

    String.Base.DefineProp("Buffer", {Call: __Buffer})

    __Buffer(this, text, commentCharacter, bufferCharacter, bufferLength, offset := "", specialBuffer := 0) {
        if (offset == "") {
            offset := bufferLength//2
        }

        stringLength := StrLen(text)
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
            . ((specialBuffer && isOdd) ? (Format("  {}  ", text)) : (Format(" {} ", text)))
            . StrReplace(Format("{:0" . bufferLength - offset - subtract + rightOffset . "}", 0), "0", bufferCharacter)
            . commentCharacter)
    }

    ;=====================================================  Prototype  =============;

    DefineProp := {}.DefineProp

    ;------------------------------------------------------- Length ---------------;

    DefineProp(String.Prototype, "Length", {Get: StrLen})

    ;----------------------------------------------------  ToLowerCase  ------------;

    ;* "String".ToLowerCase()
    DefineProp(String.Prototype, "ToLowerCase", {Call: (this) => (Format("{:L}", this))})

    ;----------------------------------------------------  ToUpperCase  ------------;

    ;* "String".ToUpperCase()
    DefineProp(String.Prototype, "ToUpperCase", {Call: (this) => (Format("{::U}", this))})

    ;------------------------------------------------------ Includes --------------;

    ;* "String".Includes(needle[, start])
    DefineProp(String.Prototype, "Includes", {Call: (this, needle, start := 0) => (InStr(this, needle, 1, Max(0, Min(StrLen(this), Round(start))) + 1) != 0)})

    ;------------------------------------------------------  IndexOf  --------------;

    ;* "String".IndexOf(needle[, start])
    DefineProp(String.Prototype, "IndexOf", {Call: (this, needle, start := 0) => (InStr(this, needle, 1, Max(0, Min(StrLen(this), Round(start))) + 1) - 1)})

    ;------------------------------------------------------  Reverse  --------------;

    ;* "String".Reverse()
    DefineProp(String.Prototype, "Reverse", {Call: __Reverse})

    ;-------------------------------------------------------  Slice  ---------------;

    ;* "String".Slice(start[, end])
    DefineProp(String.Prototype, "Slice", {Call: (this, start, end := "") => (m := StrLen(this), SubStr(this, start + 1, Max(((IsInteger(end)) ? (((end >= 0) ? (Min(m, end)) : (Max(m + end, 0))) - ((start >= 0) ? (Min(m, start)) : (Max(m + start, 0)))) : (m)), 0)))})

    ;-------------------------------------------------------- Trim ----------------;

    ;* "String".Trim([characters])
    DefineProp(String.Prototype, "Trim", {Call: (this, characters := A_Space) => (Trim(this, characters))})
}

;---------------  Other  -------------------------------------------------------;

/**
 * Copies and returns the selected text or optionally the whole line if no text is selected while preserving the clipboard content.
 * @param {Boolean} getLine
 * @param {Boolean} strip
 * @returns {String}
 */
Copy(getLine := False, strip := False) {
    c := ClipboardAll()
    A_Clipboard := ""

    Send("^c")

    if (!ClipWait(0.2) && getLine) {
        Send("{Home}+{End}^c")
        ClipWait(0.2)

        if (A_Clipboard) {
            Send("{Right}")
        }
    }

    s := (strip) ? (Trim(A_Clipboard)) : (A_Clipboard)
    A_Clipboard := c

    return (s)
}

/**
 * Paste the provided text while preserving the clipboard content and optionally select the text that was pasted.
 * @param {String} text
 * @param {Boolean} select
 * @returns {String}
 */
Paste(text, select := False) {
    c := ClipboardAll()
    A_Clipboard := ""

    Sleep(25)
    A_Clipboard := text

    Send("^v")

    Sleep(25)
    A_Clipboard := c

    if (select) {
        select := 0

        if (InStr(text, "`n")) {
            for v in StrSplit(StrReplace(text, "`n", "`r")) {
                select += StrLen(A_LoopField) + (A_Index != 1)
            }
        }

        Send(Format("+{Left {:1}}", Max(select, StrLen(text))))
    }
}
