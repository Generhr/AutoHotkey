;===========  Code Snippets  ===================================================;
;--------------- Switch -------------------------------------------------------;

condition := 3

switch (condition) {
    case 1, 2, 3:
        MsgBox("`condition` is 1 or 2 or 3.")
    case 4:
        MsgBox("`condition` is 4.")
    default:
        MsgBox("`condition` is not accounted for.")
}

;---------------  Timer  -------------------------------------------------------;

Key::SetTimer(Function, (toggle := !toggle) ? (-1) : (0))

Function() {
    ; code...
}

;-------  JSON To An AHK Object  -----------------------------------------------;

obj :=
( LTrim Join
{
    key: "value",
    list: [
        "item1",
        "item2"
    ]
}
)

for k, v in obj.OwnProps() {
    MsgBox(k . ": " . ((v.HasMethod("Print")) ? (v.Print()) : (v)))
}

;------------- Comparison -----------------------------------------------------;

if (a = b) {  ;* Case insensitive.
}

if (a == b) {  ;* Case sensitive.
}

if !(a <> b) {  ;* Depends on A_StringCaseSense.
}

;--------------  Capture  ------------------------------------------------------;

;\:: {
;   Gui, Capture: New, -Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20
;   Gui, Add, Edit, -WantReturn vtext
;   Gui, Add, Button, Default gButton
;
;   GuiControl, Hide, Button1
;
;   MouseGetPos, x, y
;   Gui, Show, % Format("x{} y{} h32", x, y)
;}
;
;Button:
;   Gui, Capture: Submit
;
;   Run, % text
;   return

;------------- Evaluation -----------------------------------------------------;

WhileFuntion(condition, expresion) { ;* <-- Evaluate expresion while condition is true.
    loop {
        if (!Evaluate(condition)) {
            return (y)
        }
        else {
            y := Eval(expresion)
        }
    }
}

UntilFuntion(expresion, condition) { ;* <-- Evaluate expresion until condition is true.
    loop {
        y := (Evaluate(expresion))

        if (Eval(condition)) {
            return (y)
        }
    }
}

;-----------  Try and Catch  ---------------------------------------------------;

try {
    Something()
}
catch (Error as e) {
    switch (e.Message) {
        case "Some custom error text here":
            MsgBox("Error 1")
        case "Some other error text":
            Msgbox("Error 2")
    }
}

;============  Useful Code  ====================================================;
;----- Exponential Moving Average ---------------------------------------------;

smoothing := 0.95
average := average*smoothing + value*(1 - smoothing)

;------------- Text Align -----------------------------------------------------;

MsgBox(Format("[{1:-20s}]", "Align Left"))
MsgBox(Format("[{1:20s}]",  "Align Right"))

;--------  Convert Miliseconds  ------------------------------------------------;

seconds := Mod(miliseconds//1000, 60)
minutes := Mod(miliseconds//(1000*60), 60)
hours := Mod(miliseconds//(1000*60*60), 24)

;------  Disable Key Temporarily  ----------------------------------------------;

void := ObjBindMethod({}, {})
Hotkey("*LButton", void, (toggle := !toggle) ? ("On") : ("Off"))

;-----------  Window Exists  ---------------------------------------------------;

WinExist(hWnd) {
    return (DllCall("IsWindow", "Ptr", hWnd))  ;~ Doesn't rely on `DetectHiddenWindows`.
}

;--------- Window Under Mouse -------------------------------------------------;

WatchMouse() {
    static window := GetWindow()

    if (GetWindow() != window) {
        window := GetWindow()

        WinGetTitle(title, "ahk_id" . window)

        if (title ~= "Notepad") {
            MsgBox("Found it!")
        }
    }
}

GetWindow() {
    MouseGetPos(, , &(window := 0))

    return (window)
}

;----------- Random Methods ---------------------------------------------------;

OneLineRandom(Min := 0, Max := 1) {
    return ("", VarSetCapacity(CSPHandle, 8, 0), VarSetCapacity(RandomBuffer, 8, 0), DllCall("advapi32.dll\CryptAcquireContextA", "Ptr", &CSPHandle, "UInt", 0, "UInt", 0, "UInt", PROV_RSA_AES := 0x00000018,"UInt", CRYPT_VERIFYCONTEXT := 0xF0000000), DllCall("advapi32.dll\CryptGenRandom", "Ptr", NumGet(&CSPHandle, 0, "UInt64"), "UInt", 8, "Ptr", &RandomBuffer), DllCall("advapi32.dll\CryptReleaseContext", "Ptr", NumGet(&CSPHandle, 0, "UInt64"), "UInt", 0)) (Abs(NumGet(&RandomBuffer, 0, "UInt64") / 2 ** 64) * (Max - Min)) + Min
}

MsgBox(Math.Random()*(max - min) + min)  ;Get a random floating point number between `min` and `max`.
MsgBox(Math.Floor(Math.Random()*(max - min + 1) + min))  ;Get a random integer between `min` and `max`.
MsgBox(Math.Random() >= 0.5)  ;Get a random boolean value.

getRandomInt(min, max) {  ;Returns a random integer between min (inclusive) and max (inclusive).
    min := Ceil(min), max := Floor(max)

    return (Floor(Math.random()*(max - min + 1)) + min)
}

RandomBool(Probability) {
    return (Random(0.0, 100.0) <= Probability)
}  ;: https://alvinalexander.com/java/java-method-returns-random-boolean-based-on-probability

RandomColor() {
    static string := StrSplit("0123456789ABCDEF")

    loop (6) {
        color .= string[Math.Random(0, 15)]
    }

    return (Format("0x{:X}", color))
}

;-----  Indirect Class References  ---------------------------------------------;

Class Test {
    static Instances := []

    __New() {

        instance := {Base: this.__Test}

        pointer := &instance
            , this.Instances[pointer] := instance, ObjRelease(pointer)  ;* Decrease this object's reference count to allow `__Delete()` to be called while still keeping a copy in `Test.Instances`.

        return (instance)
    }

    ActionAll() {
        for i, object in this.Instances {
            object.Action()
        }
    }

    Class __Test {

        __Delete() {
            pointer := &this
                , ObjAddRef(pointer), Test.Instances.Delete(pointer)  ;* Increase this object's reference count before deleting the copy stored in `Test.Instances` to avoid crashing the calling script.
        }

        Action() {
            ;* Do some cool stuff.
        }
    }
}

;-------------- Alphabet ------------------------------------------------------;

loop (26) {
    Send(Chr(96 + A_Index))
}

;---------- Webpage Contents --------------------------------------------------;

GetWebPage(url, postdata :="", user :="", pass := "") {
    Static whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")

    whr.Open((postdata ? "Post" : "Get"), url, true)            ;* Post or Get depending if postdata is submitted.
    whr.SetTimeouts("30000", "30000", "30000", "30000")    ;* Timeout is 30 seconds.
    if (StrLen(user) > 0) {
        whr.SetAutoLogonPolicy(0)
        whr.SetCredentials(user, pass, 0)
    }
    if (StrLen(postdata) > 0) {
        whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        whr.Send(postdata)
    }
    else {
        whr.Send()
    }

    whr.WaitForResponse()
    return (whr.ResponseText)
}

;------------  Scroll Wheel  ----------------------------------------------------;

Class ScrollWheel {

    Get() {  ;* Retrieves the number of lines to scroll when the vertical mouse wheel is moved.
        VarSetCapacity(pvParam, 4, 0)
        if !(DllCall("user32.dll\SystemParametersInfo", "UInt", 0x0068, "UInt", 0, "Ptr", &pvParam, "UInt", 0)) {
            return ("*" A_LastError)
        }

        return (NumGet(pvParam, 0, "UInt"))
    }

    Set(NUMBER_OF_LINES_TO_SCROLL := 3) {  ;* Sets the number of lines to scroll when the vertical mouse wheel is moved (default is 3).
        if !(DllCall("user32.dll\SystemParametersInfo", "UInt", 0x0069, "UInt", NUMBER_OF_LINES_TO_SCROLL, "Ptr", 0, "UInt", 0)) {
            return ("*" A_LastError)
        }

        if !(DllCall("user32.dll\SendMessageTimeout", "Ptr", 0xFFFF, "UInt", 0x001A, "UPtr", 0x0069, "Ptr", 0, "UInt", 0, "UInt", 1000, "UPtr", 0, "Ptr")) {
            return ("*" A_LastError)
        }

        return (this.GET())
    }
}

;-------  Offset Size To Center  -----------------------------------------------;

width := 50, height := 50

myGui := Gui("-Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20")
myGui.BackColor := "FFFFFF"

loop {
    point := OffsetSizeToCenter(width, height)

    myGui.Show(Format("x{} y{} w{} h{} NA", point[0], point[1], width, height))
} until (GetKeyState("Esc", "P"))

myGui.Destroy()

OffsetSizeToCenter(width, height) {
    MouseGetPos(&x, &y)

    if (x <= A_ScreenWidth/2 && y <= A_ScreenHeight/2) {
        ToolTip(1, 50, 50)

        return ([x, y])
    }
    else if (x > A_ScreenWidth/2 && y <= A_ScreenHeight/2) {
        ToolTip(2, 50, 50)

        return ([x - width + 1, y])
    }
    else if (x > A_ScreenWidth/2 && y > A_ScreenHeight/2) {
        ToolTip(3, 50, 50)

        return ([x - width + 1, y - height + 1])
    }
    else {
        ToolTip(4, 50, 50)

        return ([x, y - height + 1])
    }
}

;------------ WM_NCHITTEST ----------------------------------------------------;

WinWaitActive("A")
SendMessage(0x84, , (x & 0xFFFF) | (y & 0xFFFF) << 16)  ;? 0x84 = WM_NCHITTEST

;-----------  Package Array  ---------------------------------------------------;

packaged := ToStructure([0, 0, "", "", 0, 0, 0, 0, 0, 0], "Int")

DllCall(MCode("2,x64:SInIxwEAAAAAx0EEAQAAAMdBCAIAAADHQQwDAAAAx0EQBAAAAMdBFAUAAADHQRgGAAAAx0EcBwAAAMdBIAgAAADHQSQJAAAAw5CQkJCQkJA="), "Int", packaged.Pointer, "Cdecl Int")

myArray := ToArray(packaged, "Int")

ToArray(structure, type) {
    static sizeLookup := {Char: 1, UChar: 1, Short: 2, UShort: 2, Float: 4, Int: 4, UInt: 4, Int64: 8, UInt64: 8, Ptr: A_PtrSize, UPtr: A_PtrSize}

    if (!(Type(structure) == "Structure")) {
        throw (Error("ArgumentException", -1, "You must call `GDIp.Startup()` before initializing this class."))
    }

    loop (structure.Size//(size := sizeLookup[type]), r := []) {
        r.Push(structure.NumGet(size*(A_Index - 1), type))
    }

    return (r)
}

ToStructure(array, type) {
    static sizeLookup := {Char: 1, UChar: 1, Short: 2, UShort: 2, Float: 4, Int: 4, UInt: 4, Int64: 8, UInt64: 8, Ptr: A_PtrSize, UPtr: A_PtrSize}

    for i, value in (array, size := sizeLookup[type], packaged := new Structure(array.Length*size)) {
        packaged.NumPut(size*(A_Index - 1), type, value)  ;* Use `A_Index - 1` instead of `i` as there may be empty indices.
    }

    return (packaged)
}

;=============  Reference  =====================================================;
;--------------  Bitwise  ------------------------------------------------------;

if ((x & 1) == 0) {
    ; x is even
}
else {
    ; x is odd
}

"a and b: " . a & b
"a or b: "  . a | b
"a xor b: " . a ^ b
"not a: "   .~a       ;* Treated as unsigned integer  ;~ The bitwise not (~) operator will return a truthy value for anything but -1. Negating it is as simple as doing `!~`.
"a << b: "  . a << b  ;* Left shift
"a >> b: "  . a >> b  ;* Arithmetic right shift

MsgBox(1.0/((1 << 53) - 1) == 1.0/(2**53 - 1))

;-------- DllCall Optimisation ------------------------------------------------;

MulDivProc := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "kernel32", "Ptr"), "AStr", "MulDiv", "Ptr")  ;~ In this example, if the DLL isn't yet loaded, use LoadLibrary in place of GetModuleHandle.

loop (500) {
    DllCall(MulDivProc, "Int", 3, "Int", 4, "Int", 3)
}

;---------  DllCall Benchmark  -------------------------------------------------;

q1 := 3 , q2 := 2

QueryPerformanceCounter(0)  ;~ The overhead of the DllCall outweighs any possible benefits in this example. Often, when you can replace a script loop with a compiled loop, then you can get speed benefits.
loop (2000) {
    result := DllCall(MCode("2,x64:icgPr8LD"), "Int", q1, "Int", q2)  ;* "2,x64:icgPr8LD" = q1*q2
}
MsgBox(Format("Elapsed: {}`nResult: {}", QueryPerformanceCounter(1), result))

QueryPerformanceCounter(0)
loop (2000) {
    result := q1*q2
}
MsgBox(Format("Elapsed: {}`nResult: {}", QueryPerformanceCounter(1), result))

;---  Structure Management Template  -------------------------------------------;

primary := Primary(Header(1, 2), Body(3, 4, 5, 6))

loop ((size := primary.Size)//4) {
    contents .= NumGet(primary.Pointer + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}

MsgBox("Contents: " . contents
    . "`nSize: " . size)

Primary(header, body) {
    return (new Structure("Struct", header, "Struct", body))
}

Header(number1, number2) {
    return (new Structure("Int", number1, "Int", number2))
}

Body(number1, number2, number3, number4) {
    return (new Structure("Int", number1, "Int", number2, "Int", number3, "Int", number4))
}

;DllCall("RtlCompareMemory", "Ptr", pSource1, "Ptr", pSource2, "Ptr", bytes, "Ptr")  ;* The RtlCompareMemory routine compares two blocks of memory and returns the number of bytes that match.
;DllCall("RtlEqualMemory", "Ptr", pSource1, "Ptr", pSource2, "Ptr", bytes, "UInt")  ;* The RtlEqualMemory routine compares two blocks of memory to determine whether the specified number of bytes are identical.
;DllCall("RtlFillMemory", "Ptr", pSource, "Ptr", bytes, "Int", content)  ;* The RtlFillMemory routine fills a block of memory with the specified fill value.
;DllCall("RtlMoveMemory", "Ptr", pDestination, "Ptr", pSource, "Int", bytes)  ;* The RtlMoveMemory routine copies the contents of a source memory block to a destination memory block, and supports overlapping source and destination memory blocks.
;DllCall("RtlZeroMemory", "Ptr", pSource, "Ptr", bytes)  ;* The RtlZeroMemory routine fills a block of memory with zeros, given a pointer to the block and the length, in bytes, to be filled.

;----- Cloakersmoker Magic Tricks ---------------------------------------------;

*(2**16-1)
ToolTip("bam, the magic exitapp")  ;~ AHK has a sanity check for numbers below 0xFFFF. Well, any number is technically a valid address, it's just that the address is not readable memory.

;NumPut(69, &MyVariable)
;MsgBox(*(&AVariable))

;-------- Export Dll Functions ------------------------------------------------;

DllListExports( DLL, Hdr := 0 ) {  ;* By SKAN  ;:  http://goo.gl/DsMqa6
    Local LOADED_IMAGE, nSize := VarSetCapacity( LOADED_IMAGE, 84, 0 ), pMappedAddress, pFileHeader
        , pIMGDIR_EN_EXP, IMAGE_DIRECTORY_ENTRY_EXPORT := 0, RVA, VA, LIST := ""
        , hModule := DllCall( "LoadLibrary", "Str","ImageHlp.dll", "Ptr" )

    If ! DllCall( "ImageHlp\MapAndLoad", "AStr",DLL, "Int",0, "Ptr",&LOADED_IMAGE, "Int",True, "Int",True )
        Return

    pMappedAddress := NumGet( LOADED_IMAGE, ( A_PtrSize = 4 ) ?  8 : 16 )
    pFileHeader    := NumGet( LOADED_IMAGE, ( A_PtrSize = 4 ) ? 12 : 24 )

    pIMGDIR_EN_EXP := DllCall( "ImageHlp\ImageDirectoryEntryToData", "Ptr",pMappedAddress
                            , "Int",False, "UShort",IMAGE_DIRECTORY_ENTRY_EXPORT, "PtrP",nSize, "Ptr" )

    VA  := DllCall( "ImageHlp\ImageRvaToVa", "Ptr",pFileHeader, "Ptr",pMappedAddress, "UInt"
    , RVA := NumGet(pIMGDIR_EN_EXP + 12), "Ptr",0, "Ptr" )

    If ( VA ) {
        VarSetCapacity( LIST, nSize, 0 )
        Loop % NumGet( pIMGDIR_EN_EXP + 24, "UInt" ) + 1
            LIST .= StrGet( Va + StrLen( LIST ), "" ) "`n"
                ,  ( Hdr = 0 and A_Index = 1 and ( Va := Va + StrLen( LIST ) ) ? LIST := "" : "" )
    }

    DllCall( "ImageHlp\UnMapAndLoad", "Ptr",&LOADED_IMAGE ),   DllCall( "FreeLibrary", "Ptr",hModule )

    return (RTrim( List, "`n" ))
}
