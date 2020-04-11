;=====         Auto-execute         =========================;

Global Math := new Math

;=====            Class             =========================;

Class Math {

	;-----         Constructor          -------------------------;

	Static __Precision := 18, __ThrowException := 1

	__Init() {
		SetFormat, FloatFast, % "4." . this.__Precision
	}

	;-----           Property           -------------------------;

	__Get(vKey, vValues*) {
		Switch (vKey) {

			;* Description:
				;* Euler"s exponential constant.
			Case "E":
				Return, (2.718281828459045235360287471352662497757247093699959574966968)

			;* Description:
				;* The smallest signficant differentiation between two floating point values. Useful as a tolerance when testing if two single precision real numbers approximate each other.
			;* Note:
				;* The smallest 32-bit integer greater than zero is `1/(2^32 - 1)`.
			Case "Epsilon":
				Return, (1.0e-15)

			;* Description:
				;* The angle subtended by the smaller arc when two arcs that make up a circle are in the golden ratio.
			Case "GoldenAngle":
				Return, (2.399963229728653322231555506633613853124999011058115042935112)  ;? ≈ ((4 - 2*Phi)*Pi)

			;* Description:
				;* The golden ratio (φ).
			Case "GoldenRatio":
				Return, (1.618033988749894848204586834365638117720309179805762862135449)  ;? ≈ ((1 + Sqrt(5))/2)

			;* Math.Log2[vNumber]
			;* Description:
				;* The natural logarithm of 2.
			Case "Log2":
				Return, (0.693147180559945309417232121458176568075500134360255254120680)

			;* Description:
				;* The base-2 logarithm of E.
			Case "Log2E":
				Return, (1.442695040888963407359924681001892137426645954152985934135450)

			;* Description:
				;* The natural logarithm of 10.
			Case "Log10":
				Return, (2.302585092994045684017991454684364207601101488628772976033328)

			;* Description:
				;* The base-10 logarithm of E.
			Case "Log10E":
				Return, (0.434294481903251827651128918916605082294397005803666566114454)

			;* Description:
				;* (π).
			Case "Pi":
				Return, (3.141592653589793238462643383279502884197169399375105820974945)

			;* Description:
				;* The ratio of a circle's circumference to its diameter (τ).
			Case "Tau":
				Return, (6.283185307179586476925286766559005768394338798750211641949889)
		}
	}

	__Set(vKey, vValue) {
		Switch (vKey) {
			Case "Precision":
				ObjRawSet(Math, "__Precision", vValue)

				SetFormat, FloatFast, % "4." . vValue
			Case "ThrowException":
				ObjRawSet(Math, "__ThrowException", vValue)
		}
		Return
	}

	;-----            Method            -------------------------;
	;---------------          Comparison          ---------------;

	;* Math.IsBetween(vNumber)
	;* Description:
		;* Determine whether a number is within bounds (inclusive) and is not an excluded number.
	IsBetween(vNumber, vLower, vUpper, vExclude*) {
		For i, v in vExclude {
			If (v == vNumber)
				Return, (0)
		}

		Return, ((!(vLower == "" || vUpper == "")) ? (vNumber >= vLower && vNumber <= vUpper) : ((vLower == "") ? (vNumber <= vUpper) : (vNumber <= vLower)))
	}

	;* Math.IsEven(vNumber)
	IsEven(vNumber) {
		Return, (Mod(vNumber, 2) == 0)
	}

	;* Math.IsInteger(vNumber)
	IsInteger(vNumber) {
		Return, (this.IsNumeric(vNumber) && vNumber == Round(vNumber))
	}

	;* Math.IsNumeric(vNumber)
	IsNumeric(vNumber) {
		If vNumber is Number
			Return, (1)
		Return, (0)
	}

	;* Math.IsPrime(vNumber)
	IsPrime(vNumber) {
		If (vNumber < 2 || vNumber != Round(vNumber))
			Return, (0)

		Loop, % ~~(this.Sqrt(vNumber))
			If (A_Index > 1 && Mod(vNumber, A_Index) == 0)
				Return, (0)

		Return, (1)
	}

	;* Math.IsSquare(vNumber)
	IsSquare(vNumber) {
		Return, (this.IsInteger(this.Sqrt(vNumber)))
	}

	;---------------          Conversion          ---------------;
	;-------------------------            Angle             -----;

	;* Math.ToDegrees(vTheta)
	ToDegrees(vTheta) {
		Return, (vTheta*57.295779513082320876798154814105170332405472466564321549160244)
	}

	;* Math.ToRadians(vTheta)
	ToRadians(vTheta) {
		Return, (vTheta*0.017453292519943295769236907684886127134428718885417254560972)
	}

	;-------------------------             Base             -----;

	ToBase(vNumber, vCurrentBase, vTargetBase) {
		Static __IsUnicode := A_IsUnicode ? ["_wcstoui64", "_i64tow"] : ["_strtoui64", "_i64toa"], __Result := VarSetCapacity(__Result, 66, 0)

		DllCall("msvcrt.dll\" . __IsUnicode[1], "Int64", DllCall("msvcrt.dll\" . __IsUnicode[0], "Str", vNumber, "UInt", 0, "UInt", vCurrentBase, "Int64"), "Str", __Result, "UInt", vTargetBase)

		Return, (__Result.ToUpperCase())
	}

	ToNumber(ByRef vVariable) {
		MsgBox("ToNumber(): " vVariable.Print())
		If (Type(vVariable) == "Array") {
			For i, v in vVariable {
				If (!Math.IsNumeric(v)) {
					vVariable[i] := Round(v)
				}
			}
			Return, (vVariable)
		}

		Return, (!Math.IsNumeric(v) ? Round(vVariable) : vVariable)
	}

	;---------------          Elementary          ---------------;
	;-------------------------         Exponential          -----;

	;* Math.Exp(vNumber || [vNumber1, vNumber2, ..., vNumberN])
	;* Description:
		;* Calculate the exponent of a number.
	Exp(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v))
					r[i] := Exp(v)
				Else If (Type(v) == "Array")
					r[i] := this.Exp(v)
			}

			Return, (r)
		}

		Return, (Exp(vNumber))
	}

	;* Math.Log($vBase, vNumber)
	;* Description:
		;* Calculate the logarithm of a number.
	;* Note:
		;* In AutoHotkey `Ln()` is the natural logarithm and `Log()` is the decadic logarithm.
	Log(vParameters*) {
		vNumber := vParameters[1 + (vParameters.Length() > 1)], vBase := vParameters[(vParameters.Length() > 1)]  ;* Switch: `Math.Log(vNumber) || Math.Log(vBase, vNumber)`.

		If (Type(vNumber) == "Array") {
			r := vNumber.Clone(), e := this.__ThrowException

			If (vBase == "")
				For i, v in r {
					If (this.IsNumeric(v)) {
						If (v > 0)
							r[i] := Ln(vNumber)
						Else If (e)
							Throw, (Exception("NaN.", -1, Format("Math.Log({}) is out of bounds.", vNumber.Print())))
					}
					Else If (Type(v) == "Array")
						r[i] := this.Log(v)
				}
			Else
				For i, v in r {
					If (this.IsNumeric(v)) {
						If (v > 0)
							r[i] := Ln(vNumber)/Ln(vBase)
						Else If (e)
							Throw, (Exception("NaN.", -1, Format("Math.Log({}) is out of bounds.", vNumber.Print())))
					}
					Else If (Type(v) == "Array")
						r[i] := this.Log(v)
				}

			Return, (r)
		}

		If (vNumber > 0)
			Return, ((vBase != "") ? (Ln(vNumber)/Ln(vBase)) : (Ln(vNumber)))

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Log({}) is out of bounds.", [vParameters*].Join(", "))))
	}



	;* Math.Log2(vNumber)
	;* Description:
		;* Calculate the base-2 logarithm of a number.
	Log2(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone(), e := this.__ThrowException

			For i, v in r {
				If (this.IsNumeric(v)) {
					If (v > 0)
						r[i] := Ln(vNumber)/0.693147180559945309417232121458176568075500134360255254120680
					Else If (e)
						Throw, (Exception("NaN.", -1, Format("Math.Log2({}) is out of bounds.", vNumber.Print())))
				}
				Else If (Type(v) == "Array")
					r[i] := this.Log(v)
			}

			Return, (r)
		}

		If (vNumber > 0)
			Return, (Ln(vNumber)/0.693147180559945309417232121458176568075500134360255254120680)

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Log2({}) is out of bounds.", vNumber)))
	}

	;* Math.Log10(vNumber)
	;* Description:
		;* Calculate the base-10 logarithm of a number.
	Log10(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone(), e := this.__ThrowException

			For i, v in r {
				If (this.IsNumeric(v)) {
					If (v > 0)
						r[i] := Log(vNumber)
					Else If (e)
						Throw, (Exception("NaN.", -1, Format("Math.Log10({}) is out of bounds.", vNumber.Print())))
				}
				Else If (Type(v) == "Array")
					r[i] := this.Log(v)
			}

			Return, (r)
		}

		If (vNumber > 0)
			Return, (Log(vNumber))

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Log10({}) is out of bounds.", vNumber)))
	}

	;-------------------------             Root             -----;

	;* Math.CubeRoot(vNumber || [vNumber1, vNumber2, ..., vNumberN])
	;* Description:
		;* Calculate the cubic root of a number.
	Cbrt(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v))
					r[i] := (v < 0) ? (-(-v)**(1/3)) : (v**(1/3))
				Else If (Type(v) == "Array")
					r[i] := this.Cbrt(v)
			}

			Return, (r)
		}

		Return, ((vNumber < 0) ? (-(-vNumber)**(1/3)) : (vNumber**(1/3)))
	}

	;* Math.Sqrt(vNumber || [vNumber1, vNumber2, ..., vNumberN])
	;* Description:
		;* Calculate the square root of a number.
	Sqrt(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone(), e := this.__ThrowException

			For i, v in r {
				If (this.IsNumeric(v)) {
					If (v >= 0)
						r[i] := Sqrt(v)
					Else If (e)
						Throw, (Exception("NaN.", -1, Format("Math.Sqrt({}) is out of bounds.", vNumber.Print())))
				}
				Else If (Type(v) == "Array")
					r[i] := this.Sqrt(v)
			}

			Return, (r)
		}

		If (vNumber >= 0)
			Return, (Sqrt(vNumber))

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Sqrt({}) is out of bounds.", vNumber)))
	}

	;* Math.Surd(vNumber || [vNumber1, vNumber2, ..., vNumberN], vN)
	;* Description:
		;* Calculate the nᵗʰ root of a number.
	Surd(vNumber, vN) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone(), e := this.__ThrowException, c := this.IsEven(vN)

			For i, v in r {
				If (this.IsNumeric(v)) {
					If (!c || v >= 0)
						r[i] := this.Abs(v)**(1/vN)*((v > 0) - (v < 0))
					Else If (e)
						Throw, (Exception("NaN.", -1, Format("Math.Surd({}, {}) is out of bounds.", vNumber, vN)))
				}
				Else If (Type(v) == "Array")
					r[i] := this.Surd(v)
			}

			Return, (r)
		}

		If (!this.IsEven(vN) || vNumber >= 0)
			Return, (this.Abs(vNumber)**(1/vN)*((vNumber > 0) - (vNumber < 0)))

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Surd({}, {}) is out of bounds.", vNumber, vN)))
	}

	;-------------------------        Trigonometric         -----;

	Sin(vTheta) {
		Return, (DllCall("msvcrt\sin", "Double", vTheta, "Double"))
	}

	ASin(vTheta) {
		If (vTheta > -1 && vTheta < 1)
			Return, (DllCall("msvcrt\asin", "Double", vTheta, "Double"))  ;* -1 < θ < 1

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ASin({}) is out of bounds.", vTheta)))
	}

	Cos(vTheta) {
		Return, (DllCall("msvcrt\cos", "Double", vTheta, "Double"))
	}

	ACos(vTheta) {
		If (vTheta > -1 && vTheta < 1)
			Return, (DllCall("msvcrt\acos", "Double", vTheta, "Double"))  ;* -1 < θ < 1

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ACos({}) is out of bounds.", vTheta)))
	}

	Tan(vTheta) {
		Return, (DllCall("msvcrt\tan", "Double", vTheta, "Double"))
	}

	ATan(vTheta) {
		Return, (DllCall("msvcrt\atan", "Double", vTheta, "Double"))
	}

	ATan2(oPoint) {
		Return, (DllCall("msvcrt\atan2", "Double", oPoint.y, "Double", oPoint.x, "Double"))
	}

	Csc(vTheta) {
		If (vTheta != 0)
			Return, (1/DllCall("msvcrt\sin", "Double", vTheta, "Double"))  ;* θ != 0

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Csc({}) is out of bounds.", vTheta)))
	}

	ACsc(vTheta) {
		If (vTheta != 0)
			Return, (DllCall("msvcrt\asin", "Double", 1/vTheta, "Double"))  ;* θ != 0

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ACsc({}) is out of bounds.", vTheta)))
	}

	Sec(vTheta) {
		Return, (1/DllCall("msvcrt\cos", "Double", vTheta, "Double"))
	}

	ASec(vTheta) {
		If (vTheta != 0)
			Return, (DllCall("msvcrt\acos", "Double", 1/vTheta, "Double"))  ;* θ != 0

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ASec({}) is out of bounds.", vTheta)))
	}

	Cot(vTheta) {
		If (vTheta != 0)
			Return, (1/DllCall("msvcrt\tan", "Double", vTheta, "Double"))  ;* θ != 0

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Cot({}) is out of bounds.", vTheta)))
	}

	ACot(vTheta) {
		If (vTheta != 0)
			Return, (DllCall("msvcrt\atan", "Double", 1/vTheta, "Double"))  ;* θ != 0

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ACot({}) is out of bounds.", vTheta)))
	}

	;-------------------------          Hyperbolic          -----;

	SinH(vTheta) {
		Return, (DllCall("msvcrt\sinh", "Double", vTheta, "Double"))
	}

	ASinH(vTheta) {
		Return, (this.Log(vTheta + Sqrt(vTheta**2 + 1)))
	}

	CosH(vTheta) {
		Return, (DllCall("msvcrt\cosh", "Double", vTheta, "Double"))
	}

	ACosH(vTheta) {
		If (vTheta >= 1)
			Return, (this.Log(vTheta + Sqrt(vTheta**2 - 1)))  ;* θ >= 1

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ACosH({}) is out of bounds.", vTheta)))
	}

	TanH(vTheta) {
		Return, (DllCall("msvcrt\tanh", "Double", vTheta, "Double"))
	}

	ATanH(vTheta) {
		If (this.Abs(vTheta) < 1)
		Return, (0.5*this.Log((1 + vTheta)/(1 - vTheta)))  ;* |θ| < 1

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ATanH({}) is out of bounds.", vTheta)))
	}

	CscH(vTheta) {
		If (vTheta != 0)
			Return, (1/DllCall("msvcrt\sinh", "Double", vTheta, "Double"))  ;* θ != 0

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.CscH({}) is out of bounds.", vTheta)))
	}

	ACscH(vTheta) {
		If (vTheta != 0)
			Return, (this.Log(1/vTheta + Sqrt(1 + vTheta**2)/Abs(vTheta))) ;* θ != 0

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ACscH({}) is out of bounds.", vTheta)))
	}

	SecH(vTheta) {
		Return, (1/DllCall("msvcrt\cosh", "Double", vTheta, "Double"))
	}

	ASecH(vTheta) {
		If (vTheta > 0 && vTheta <= 1)
			Return, (this.Log(1/vTheta + Sqrt(1/vTheta**2 - 1)))  ;* 0 < θ <= 1

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ASecH({}) is out of bounds.", vTheta)))
	}

	CotH(vTheta) {
		If (vTheta != 0)
			Return, (1/DllCall("msvcrt\tanh", "Double", vTheta, "Double"))  ;* θ != 0

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.CotH({}) is out of bounds.", vTheta)))
	}

	ACotH(vTheta) {
		If (this.Abs(vTheta) > 1)
			Return, (0.5*this.Log((vTheta + 1)/(vTheta - 1)))  ;* |θ| > 1

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.ACotH({}) is out of bounds.", vTheta)))
	}

	;---------------           Integer            ---------------;
	;-------------------------       Division-related       -----;

	;* Math.GCD(vNumber1, [vNumber2, vNumber3, ...], ..., vNumberN)
	;* Description:
		;* Calculates the greatest common divisor of two or more integers.
	GCD(vNumbers*) {
		Static __MCode := [MCode("2,x64:QYnIiciJ0UHB+B/B+R9EMcAxykQpwCnKDx+EAAAAAAA50HQKOcJ9CCnQOdB19vPDKcLr7JCQkJA="), MCode("2,x64:iwGD+gF+V4PqAkyNQQRMjVSRCEGLEEGLCEGJwUHB+R9EMcjB+h8x0SnRicJEKcqJyDnRdRHrGWYPH4QAAAAAACnQOdB0CjnQf/YpwjnQdfaD+AF0CUmDwARNOdB1tfPD")]

		If (Type(vNumbers[1]) == "Array" || Type(vNumbers[2]) == "Array" || vNumbers.Count() > 2) {
			o := [].Concat(vNumbers*), VarSetCapacity(a, o.Count*4, 0), c := 0, e := this.__ThrowException

			For i, v in o {
				If (this.IsInteger(v))
					NumPut(v, a, (c++)*4, "Int")
				Else If (e)
					Throw, (Exception("Type error.", -1, Format("Math.GCD({}) may only contain integers.", [vNumbers*].Print())))
			}

			Return, (DllCall(__MCode[1], "Int", &a, "Int", c, "Int"))  ;* I couldn't find a way to get the length of an array that is passed as a parameter to a C function so I'm passing it here.
		}

		If (this.IsInteger(vNumbers[1]) && this.IsInteger(vNumbers[2]))
			Return, (DllCall(__MCode[0], "Int", vNumbers[1], "Int", vNumbers[2], "Int"))

		If (this.__ThrowException)
			Throw, (Exception("Type error.", -1, Format("Math.GCD({}) may only contain integers.", [vNumbers*].Join(", "))))
	}
	;! For i, v in [[[81, 6], 3], [[8, 12, 20], 4], [[8, 40, 100], 4], [[20, 30, 45, 10, 55], 5]]
		;! MsgBox(Math.GCD(v[0]) " == " v[1])

	;* Math.LCM(vNumber1, [vNumber2, vNumber3, ...], ..., vNumberN)
	;* Description:
		;* Calculates the greatest common multiple of two or more integers.
	LCM(vNumbers*) {
		Static __MCode := MCode("2,x64:QYnIiciJ0UHB+B/B+R9EMcAxykQpwCnKDx+EAAAAAAA50HQKOcJ9CCnQOdB19vPDKcLr7JCQkJA=")

		If (Type(vNumbers[1]) == "Array" || Type(vNumbers[2]) == "Array" || vNumbers.Count() > 2) {
			r := (o := [].Concat(vNumbers*)).Shift(), e := this.__ThrowException

			For i, v in o {
				If (this.IsInteger(r) && this.IsInteger(v))
					r := r*v/DllCall(__MCode, "Int", r, "Int", v, "Int")
				Else If (e)
					Throw, (Exception("Type error.", -1, Format("Math.LCM({}) may only contain integers.", [vNumbers*].Print())))
			}

			Return, (~~r)
		}

		If (this.IsInteger(vNumbers[1]) && this.IsInteger(vNumbers[2]))
			Return, (~~(vNumbers[1]*vNumbers[2]/DllCall(__MCode, "Int", vNumbers[1], "Int", vNumbers[2], "Int")))

		If (this.__ThrowException)
			Throw, (Exception("Type error.", -1, Format("Math.LCM({}) may only contain integers.", [vNumbers*].Join(", "))))
	}
	;! For i, v in [[[20, 30, 45, 6, 10], 180], [[12, 15, 10, 75], 300], [[330, 75, 450, 225], 4950], [[12, 8], 24]]
		;! MsgBox(Math.LCM(v[0]) " == " v[1])

	;-------------------------      Recurrence and Sum      -----;

	;* Math.Factorial(vNumber)
	;* Description:
		;* Calculate the factorial of an integer.
	Factorial(vNumber) {
		Static __MCode := MCode("2,x64:hcl+GYPBAboBAAAAuAEAAAAPr8KDwgE5ynX288O4AQAAAMOQkJCQ")

		If (this.IsInteger(vNumber) && vNumber >= 0)
			Return, (DllCall(__MCode, "Int", vNumber, "Int"))

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Factorial({}) is out of bounds.", vNumber)))
	}
	;! For i, v in [1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600, 6227020800, 87178291200, 1307674368000, 20922789888000, 355687428096000, 6402373705728000, 121645100408832000, 2432902008176640000, 51090942171709440000, 1124000727777607680000, 25852016738884976640000, 620448401733239439360000, 15511210043330985984000000, 403291461126605635584000000, 10888869450418352160768000000, 304888344611713860501504000000, 8841761993739701954543616000000, 265252859812191058636308480000000]
		;! If (Math.Factorial(i) != v)
			;! MsgBox(i ": " v)

	;* Math.Fibonacci(vN)
	;* Description:
		;* Calculate the nᵗʰ Fibonacci number.
	Fibonacci(vN) {
		Static __MCode := MCode("2,x64:hcl+L4PBAboBAAAAuAEAAABFMcDrDWYuDx+EAAAAAABEiciDwgFFjQwAQYnAOdF17/PDMcDDkJA=")

		If (this.IsInteger(vN) && vN >= 0)
			Return, (DllCall(__MCode, "Int", vN, "Int"))

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Fibonacci({}) is out of bounds.", vN)))
	}
	;! For i, v in [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946, 17711, 28657, 46368, 75025, 121393, 196418, 317811, 514229, 832040]
		;! If (Math.Fibonacci(i) != v)
			;! MsgBox(i ": " v)

	;---------------       Number Theoretic       ---------------;

	;* Math.Prime(vN)
	;* Description:
		;* Calculate the nᵗʰ prime number.
	Prime(vN) {
		Static __MCode := MCode("2,x64:QbkCAAAAg/kBfmJBugEAAABBuQEAAABBu1ZVVVUPHwBBg8ECQYP5A3Q6RInIQffrRInIwfgfKcKNBFJBOcF0KEG4AwAAAOsTDx+EAAAAAABEiciZQff4hdJ0DUGDwAJFOcF/7EGDwgFBOcp1s0SJyMOQkJCQ")

		If (this.IsInteger(vN) && vN > 0)
			Return, (DllCall(__MCode, "Int", vN, "Int"))

		If (this.__ThrowException)
			Throw, (Exception("NaN.", -1, Format("Math.Prime({}) is out of bounds.", vN)))
	}
	;! For i, v in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113]
		;! If (Math.Prime(A_Index) != v)
			;! MsgBox(A_Index ": " v)

	;---------------          Numerical           ---------------;
	;-------------------------          Arithmetic          -----;

	;* Math.Abs(vNumber || [vNumber1, vNumber2, ..., vNumberN])
	;* Description:
		;* Calculate the absolute value of a number.
	Abs(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone(), e := this.__ThrowException

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := Abs(v)

					If (v == -9223372036854775808 && e)
						Throw, (Exception("Overflow.", -1, Format("Math.Abs({}) has no 64-bit non-negative equal in magnitude.", vNumber.Print())))
				}
				Else If (Type(v) == "Array")
					r[i] := this.Abs(v)
			}

			Return, (r)
		}

		If (this.IsNumeric(vNumber))
			Return, (Abs(vNumber))

		If (vNumber == -9223372036854775808 && this.__ThrowException)
			Throw, (Exception("Overflow.", -1, Format("Math.Abs({}) has no 64-bit non-negative equal in magnitude.", vNumber)))
	}

	;* Math.Clamp(vNumber, vLower, vUpper)
	;* Description:
		;* Limit a number to a upper and lower limit.
	Clamp(vNumber, vLower := -1, vUpper := 1) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			If (!(vLower == "" || vUpper == ""))
				For i, v in r {
					If (this.IsNumeric(v))
						r[i] := (v < vLower) ? (vLower) : ((v > vUpper) ? (vUpper) : (v))
					Else If (Type(v) == "Array")
						r[i] := this.Abs(v)
				}
			Else If (vLower == "")
				For i, v in r {
					If (this.IsNumeric(v))
						r[i] := (v > vUpper) ? (vUpper) : (v)
					Else If (Type(v) == "Array")
						r[i] := this.Abs(v)
				}
			Else
				For i, v in r {
					If (this.IsNumeric(v))
						r[i] := (v < vLower) ? (vLower) : (v)
					Else If (Type(v) == "Array")
						r[i] := this.Abs(v)
				}

			Return, (r)
		}

		Return, ((!(vLower == "" || vUpper == "")) ? ((vNumber < vLower) ? (vLower) : ((vNumber > vUpper) ? (vUpper) : (vNumber))) : ((vLower == "") ? ((vNumber > vUpper) ? (vUpper) : (vNumber)) : ((vNumber < vLower) ? (vLower) : (vNumber))))
	}

	;* Math.CopySign(vNumber1, vNumber2)
	CopySign(vNumber1, vNumber2) {
		Return, (Abs(vNumber1)*(vNumber2 < 0 ? -1 : 1))
	}

	;* Math.Mod(vNumber || [vNumber1, vNumber2, ..., vNumberN], vDivisor)
	Mod(vNumber, vDivisor) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v))
					r[i] := Mod(v, vDivisor)
				Else If (Type(v) == "Array")
					r[i] := this.Abs(v)
			}

			Return, (r)
		}

		Return, (Mod(vNumber, vDivisor))
	}

	;* Math.Sign(vNumber)
	;* Description:
		;* Calculate the sign of a number.
	Sign(vNumber) {
		Return, ((vNumber > 0) - (vNumber < 0))
	}

	;* Math.Wrap(vNumber, vLower, vUpper)
	Wrap(vNumber, vLower, vUpper) {
		vUpper -= vLower

		return (vLower + Mod(vUpper + Mod(vNumber - vLower, vUpper), vUpper))  ;! Return, ((vLower + ((v := Mod(vNumber - vLower, vUpper)) == 0) ? (vUpper) : (Mod(vUpper + v, vUpper))))
	}

	;-------------------------      Integral Rounding       -----;

	;* Math.Ceil(vNumber || [vNumber1, vNumber2, ..., vNumberN], $vDecimalPlace)
	;* Description:
		;* Round a number towards plus infinity.
	Ceil(vNumber, vDecimalPlace := 0) {
		p := 10**vDecimalPlace

		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v))
					r[i] := Ceil(v*p)/p
				Else If (Type(v) == "Array")
					r[i] := this.Ceil(v, p)
			}

			Return, (r)
		}

		Return, (Ceil(vNumber*p)/p)  ;! (DllCall("msvcrt\ceil", "Double", vNumber*p, "Double")/p)
	}

	;* Math.Floor(vNumber || [vNumber1, vNumber2, ..., vNumberN], $vDecimalPlace)
	;* Description:
		;* Round a number towards minus infinity.
	Floor(vNumber, vDecimalPlace := 0) {
		p := 10**vDecimalPlace

		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v))
					r[i] := ~~(v*p)/p
				Else If (Type(v) == "Array")
					r[i] := this.Floor(v, p)
			}

			Return, (r)
		}

		Return, (~~(vNumber*p)/p)  ;! (DllCall("msvcrt\floor", "Double", vNumber*p, "Double")/p)
	}

	;* Math.Fix(vNumber || [vNumber1, vNumber2, ..., vNumberN], $vDecimalPlace)
	;* Description:
		;* Round a number towards zero.
	Fix(vNumber, vDecimalPlace := 0) {
		p := 10**vDecimalPlace

		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v))
					r[i] := v < 0 ? Ceil(v*p)/p : ~~(v*p)/p
				Else If (Type(v) == "Array")
					r[i] := this.Fix(v, vDecimalPlace)
			}

			Return, (r)
		}

		Return, (vNumber < 0 ? Ceil(vNumber*p)/p : ~~(vNumber*p)/p)
	}
	;! MsgBox(Math.Fix(520.50, -2))

	;* Math.Round(vNumber || [vNumber1, vNumber2, ..., vNumberN], $vDecimalPlace)
	;* Description:
		;* Round a number towards the nearest integer.
	Round(vNumber, vDecimalPlace := 0) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v))
					r[i] := Round(v, vDecimalPlace)
				Else If (Type(v) == "Array")
					r[i] := this.Round(v, vDecimalPlace)
			}
		}

		Return, (Round(vNumber, vDecimalPlace))
	}

	;-------------------------         Statistical          -----;

	;* Math.Min(vNumber1, [vNumber2, vNumber3, ...], ..., vNumberN)
	;* Description:
		;* Calculate the numerically smallest of two or more numbers.
	Min(vNumbers*) {
		If (Type(vNumbers[1]) == "Array" || Type(vNumbers[2]) == "Array" || vNumbers.Count() > 2) {
			r := [].Concat(vNumbers*)

			Return, (Min(r[0], r*))
		}

		Return, (Min(vNumbers*))
	}

	;* Math.Max(vNumber1, [vNumber2, vNumber3, ...], ..., vNumberN)
	;* Description:
		;* Calculate the numerically largest of two or more numbers.
	Max(vNumbers*) {
		If (Type(vNumbers[1]) == "Array" || Type(vNumbers[2]) == "Array" || vNumbers.Count() > 2) {
			r := [].Concat(vNumbers*)

			Return, (Max(r[0], r*))
		}

		Return, (Max(vNumbers*))
	}

	;* Math.Mean(vNumber || [vNumber1, vNumber2, ..., vNumberN])
	;* Description:
		;* Calculate statistical mean of two or more numbers.
	Mean(vNumbers*) {
		t := c := 0

		For i, v in [].Concat(vNumbers*)  ;- Doesn't maintain structure.
			If (this.IsNumeric(v))
				t += v, c++

		Return, (t/c)
	}

	;* Percent(vNumber, vPercentage)
	Percent(vNumber, vPercentage) {
		Return, (vNumber/100.0*vPercentage)
	}

	;* PercentChange(vNumber1, vNumber2)
	PercentChange(vNumber1, vNumber2) {
		vNumber1 := this.Abs(vNumber1), vNumber2 := this.Abs(vNumber2)

		Return, (vNumber1 < vNumber2 ? this.Abs((vNumber1 - vNumber2)/vNumber2*100.0) : (vNumber2 - vNumber1)/vNumber1*100.0)
	}

	;---------------         Probability          ---------------;
	;-------------------------            Normal            -----;

	;-----      Rejection Sampling      -----;

	;* Math.Ziggurat($vMean, $vDeviation)
	;* Description:
		;* https://en.wikipedia.org/wiki/Ziggurat_algorithm.
	;* Note:
		;* This algorithm is ~3.5 times faster than the Box Muller transform.
	Ziggurat(vMean := 0, vDeviation := 1.0) {
		Static __K := (v := Math.__Ziggurat()).k, __W := v.w, __F := v.f  ;* Populate the lookup tables.

		Loop {
			u := Math.Random(-2147483648, 2147483647), i := u & 255

			If (Abs(u) < __K[i])  ;* Rectangle. This will be the case for 99.33% of values (512 rectangles would be 99.64%).
				Return, (u*__W[i]*vDeviation + vMean)

			x := u*__W[i]

			If (i == 0) {  ;* Base segment. Sample using a ratio of uniforms.
				While (2*y <= x**2)
					x := -Math.Log(Math.Random())*.27366123732975828, y := -Math.Log(Math.Random())  ;? .27366123732975828 = 1/r

				Return, (((u > 0)*2 - 1)*(3.6541528853610088 + x)*vDeviation + vMean)
			}

			If ((__F[i - 1] - __F[i])*Math.Random() + __F[i] < Exp(-.5*x**2))  ;* Wedge.
				Return, (x*vDeviation + vMean)

			;* The wedge was missed; start again.
		}
	}
	__Ziggurat() {
		r := 3.6541528853610088, v := 0.00492867323399, q := Exp(-.5*r**2)  ;? r = start of the tail, v = area of each rectangle
			, k := [(r*(q/v*2147483648.0)), 0], w := [(v/q)/2147483648.0], w[255] := r/2147483648.0, f := [1.0], f[255] := q  ;* Index zero is for the base segment, where Marsaglia and Tsang define this as k[0] = 2^31*r*f(r)/v, w[0] = .5^31*v/f(r), f[0] = 1.0.

		i := 255
		While (--i) {
			x := Sqrt(-2.0*Math.Log(v/r + f[i + 1]))

			k[i + 1] := ((x/r)*2147483648.0), w[i] := x/2147483648.0, f[i] := Exp(-.5*x**2)

			r := x
		}

		Return, ({"k": k, "w": w, "f": f})
	}

	;-----        Transformation        -----;

	;* Math.MarsagliaPolar($vMean, $vDeviation)
	;* Description:
		;* https://en.wikipedia.org/wiki/Marsaglia_polar_method.
	;* Note:
		;* This algorithm does not involve any approximations so it has the proper behavior even in the tail of the distribution. It is however moderately expensive since the efficiency of the rejection method is `e = π/4 ≈ 0.785`, so about 21.5% of the uniformly distributed points within the square are discarded. The square root and the logarithm also contribute significantly to the computational cost.
	MarsagliaPolar(vMean := 0, vDeviation := 1.0) {
		Static __Secondary

		If (!__Secondary) {
			r := 0

			While (r > 1.0 || r == 0)
				u1 := Math.Random()*2.0 - 1.0, u2 := Math.Random()*2.0 - 1.0, r := u1**2 + u2**2
			__Secondary := (r := Sqrt((-2.0*Math.Log(r))/r))*u1

			Return, (r*u2*vDeviation + vMean)
		}

		Swap(r, __Secondary)

		Return, (r*vDeviation + vMean)
	}

	;-------------------------           Uniform            -----;

	;* Math.Random($vMin, $vMax)
	;* Note:
		;* AHK's built in Random command limits the range of its parameters: both `vMin` and `vMax` must be signed 32-bit integers (between -2147483648(-2**31) and 2147483647(2**31 - 1))
	Random(vMin := 0.0, vMax := 1.0) {
		Random, r, vMin, vMax

		Return, (r)
	}

	;* Math.Random64($vMin, $vMax)
	;* Description:
		;* Combines (if needed) two random numbers generated by `Random` to provide a random number in any range.
	;* Credit:
		;* Laszlo: https://autohotkey.com/board/topic/19233-64-bit-random-numbers/.
	Random64(vMin := -2147483648, vMax := 2147483647) {
		d := vMax - vMin

		If (d > 0)  ;* No overflow.
			If (d <= 0xFFFFFFFF) {  ;* 32-bit case.
				Random u, -0x80000000, d - 0x80000000

				Return, (u + vMin + 0x80000000)
			}
			Else
				Loop {  ;* Range < 2^63.
					Random u1, 0, (1 << (1 + DllCall("ntdll\RtlFindMostSignificantBit", "Int64", d >> 32))) - 1  ;! r | (r |= (r |= (r |= (r |= r >> 1) >> 2) >> 4) >> 8) >> 16
					Random u2, -0x80000000, 0x7FFFFFFF
					r := (u1 << 32) | u2 + 0x80000000

					If (r <= d)
						Return, (r + vMin)  ;! (Math.Random(0, 2147483647) & 0xFFFF << 16 | Math.Random(0, 2147483647) & 0xFFFF)
				}
		Loop {  ;* Range >= 2^63.
			Random u1, -0x80000000, 0x7FFFFFFF
			Random u2, -0x80000000, 0x7FFFFFFF
			r := (u1 << 32) | u2 + 0x80000000

			If (vMin <= r && r <= vMax)
				Return, (r)
		}
	}

	;* Math.RandomBool(vProbability)
	RandomBool(vProbability) {
		Return, (this.Random(0.0, 100.0) <= vProbability)
	}
	;! r := []
	;! Loop, 5000
		;! r.Push(Math.RandomBool(10))
	;! MsgBox(Math.Mean(r))

	;* Math.RandomSeed(vSeed)
	RandomSeed(vSeed) {
		Random, , vSeed
	}
}