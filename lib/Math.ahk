;===============  Class  =======================================================;

Class Math {

	;-------------- Property ------------------------------------------------------;  ;* ** Constants: https://numerics.mathdotnet.com/Constants.html **

	Precision[] {
		Get {
			return (A_FormatFloat)
		}

		Set {
			SetFormat, FloatFast, % value

			return (value)
		}
	}

	E[] {

		;* Description:
			;* Euler's exponential constant.
		Get {
			return (2.718281828459045)  ;? ≈ Exp(1)
		}
	}

	Epsilon[] {

		;* Description:
			;* The smallest signficant differentiation between two floating point values. Useful as a tolerance when testing if two single precision real numbers approximate each other.
		;* Note:
			;* The smallest 32-bit integer greater than zero is `1/(2**32 - 1)`.
		Get {
			epsilon := 1.0

			while (epsilon + 1 > 1) {
				epsilon /= 2
			}

			epsilon *= 2
			ObjRawSet(this, "Epsilon", epsilon)

			return (epsilon)
		}
	}

	Log2[number := ""] {

		;* Description:
			;* Calculate the base-2 logarithm of a number.
		Get {
			if (number == "") {
				return (0.693147180559945)
			}

			if (number > 0) {
				return (Ln(number)/0.693147180559945)
			}

			throw, (Exception("NaN.", -1, Format("Math.Log2({}) is out of bounds.", number)))
		}
	}

	Log2E[] {

		;* Description:
			;* The base-2 logarithm of E.
		Get {
			return (1.442695040888963)
		}
	}

	Log10[number := ""] {

		;* Description:
			;* Calculate the base-10 logarithm of a number.
		Get {
			if (number == "") {
				return (2.302585092994046)
			}

			if (number > 0) {
				return (Log(number))
			}

			throw, (Exception("NaN.", -1, Format("Math.Log10({}) is out of bounds.", number)))
		}
	}

	Log10E[] {

		;* Description:
			;* The base-10 logarithm of E.
		Get {
			return (0.434294481903252)
		}
	}

	Pi[] {
		Get {
			return (3.141592653589793)  ;? ≈ ACos(-1)
		}
	}

	Tau[] {

		;* Description:
			;* The ratio of a circle's circumference to its diameter (τ).
		Get {
			return (6.283185307179587)
		}
	}

	;--------------- Method -------------------------------------------------------;
	;----------------------------------------------------- Comparison -------------;

	;* Math.IsBetween(number, lower, upper, (exclude*))
	;* Description:
		;* Determine whether a number is within bounds (inclusive) and is not an excluded number.
	IsBetween(number, lower, upper, exclude*) {
		for i, v in exclude {
			if (v == number) {
				return (0)
			}
		}

		return ((number - lower)*(number - upper) <= 0)
	}

	;* Math.IsEven(number)
	IsEven(number) {
		return (Mod(number, 2) == 0)
	}

	IsHexadecimal(number) {
		if number is xdigit
			return (1)
		return (0)
	}

	;* Math.IsInteger(number)
	IsInteger(number) {
		return (number == Round(number))
	}

	;* Math.IsNegativeInteger(number)
	IsNegativeInteger(number) {
		return (number < 0 && this.IsInteger(number))
	}

	;* Math.IsPositiveInteger(number)
	IsPositiveInteger(number) {
		return (number >= 0 && this.IsInteger(number))
	}

	;* Math.IsNumber(number)
	IsNumber(number) {
		if number is Number
			return (1)
		return (0)
	}

	;* Math.IsPrime(number)
	IsPrime(number) {
		if (number < 2 || !this.IsInteger(number)) {
			return (0)
		}

		loop, % Floor(this.Sqrt(number)) {
			if (Mod(number, A_Index) == 0 && A_Index > 1) {
				return (0)
			}
		}

		return (1)
	}

	;* Math.IsSquare(number)
	IsSquare(number) {
		return (this.IsInteger(this.Sqrt(number)))
	}

	;----------------------------------------------------- Conversion -------------;
	;----------------------------------------  Angle  ------------------------------;

	;* Math.ToDegrees(radians)
	ToDegrees(radians) {
		return (radians*57.295779513082321)
	}

	;* Math.ToRadians(degrees)
	ToRadians(degrees) {
		return (degrees*0.017453292519943)
	}

	;----------------------------------------- Base -------------------------------;

	ToBase(number, currentBase := 10, targetBase := 16) {
		if (number < 0) {
			s := "-", number := Abs(number)
		}

		result := DllCall("msvcrt\_i64tow", "Int64", DllCall("msvcrt\_wcstoui64", "Str", number, "UInt", 0, "UInt", currentBase, "Int64"), "Ptr*", 0, "UInt", targetBase, "Str")

		if (targetBase > 10) {
			result := Format("0x{:U}", result)
		}

		return (s . result)
	}

	;* Math.ToDecimal(hexadecimal)
	ToDecimal(hexadecimal) {
		return (DllCall("msvcrt\_wcstoui64", "Str", hexadecimal, "UInt", 0, "UInt", 16, "Int64"))
	}

	;* Math.ToHexadecimal(decimal)
	ToHexadecimal(decimal) {
		if (decimal < 0) {
			s := "-", decimal := Abs(decimal)
		}

		return (Format("{}0x{:U}", s, DllCall("msvcrt\_i64tow", "Int64", decimal, "Ptr*", 0, "UInt", 16, "Str")))
	}

	;---------------------------------------  General  -----------------------------;

	;* Math.Map(value, start1, stop1, start2, stop2)
	;* Description:
		;* Re-maps a number from one range to another.
	Map(value, start1, stop1, start2, stop2) {
		return (start2 + (stop2 - start2)*((value - start1)/(stop1 - start1)))
	}

	;----------------------------------------------------- Elementary -------------;
	;-------------------------------------  Exponential  ---------------------------;

	;* Math.Exp(number)
	;* Description:
		;* Calculate the exponent of a number.
	Exp(number) {
		return (Exp(number))
	}

	;* Math.Log(number) || Math.Log(base, number)
	;* Description:
		;* Calculate the logarithm of a number.
	;* Note:
		;* In AutoHotkey `Ln()` is the natural logarithm and `Log()` is the decadic logarithm.
	Log(base, number := "") {
		if (number == "") {
			Swap(number, base)
		}

		if (number > 0) {
			return ((base == "") ? (Ln(number)) : (Ln(number)/Ln(base)))
		}

		throw, (Exception("NaN.", -1, Format("Math.Log({}) is out of bounds.", [parameters*].Join(", "))))
	}

	;----------------------------------------- Root -------------------------------;

	;* Math.CubeRoot(number)
	;* Description:
		;* Calculate the cubic root of a number.
	Cbrt(number) {
		return ((number < 0) ? (-(-number)**(1/3)) : (number**(1/3)))
	}

	;* Math.Sqrt(number)
	;* Description:
		;* Calculate the square root of a number.
	Sqrt(number) {
		if (number >= 0) {
			return (Sqrt(number))
		}

		throw, (Exception("NaN.", -1, Format("Math.Sqrt({}) is out of bounds.", number)))
	}

	;* Math.Surd(number, n)
	;* Description:
		;* Calculate the `n`ᵗʰ root of a number.
	Surd(number, n) {
		if (!this.IsEven(n) || number >= 0) {
			return (this.Abs(number)**(1/n)*((number > 0) - (number < 0)))
		}

		throw, (Exception("NaN.", -1, Format("Math.Surd({}, {}) is out of bounds.", number, n)))
	}

	;------------------------------------  Trigonometric  --------------------------;

	;* Description:
		;* `opposite/hypotenuse`.
	Sin(radians) {
		return (DllCall("msvcrt\sin", "Double", radians, "Double"))
	}

	ASin(radians) {
		if (radians <= -1 || radians >= 1) {
			throw, (Exception("NaN.", -1, Format("Math.ASin({}) is out of bounds.", radians)))
		}

		return (DllCall("msvcrt\asin", "Double", radians, "Double"))  ;* [-1, 1]
	}

	;* Description:
		;* `adjacent/hypotenuse`.
	Cos(radians) {
		return (DllCall("msvcrt\cos", "Double", radians, "Double"))
	}

	ACos(radians) {
		if (radians <= -1 || radians >= 1) {
			throw, (Exception("NaN.", -1, Format("Math.ACos({}) is out of bounds.", radians)))
		}

		return (DllCall("msvcrt\acos", "Double", radians, "Double"))  ;* [-1, 1]
	}

	;* Description:
		;* `opposite/adjacent`.
	Tan(radians) {
		return (DllCall("msvcrt\tan", "Double", radians, "Double"))
	}

	ATan(radians) {
		return (DllCall("msvcrt\atan", "Double", radians, "Double"))
	}

	;* Math.ATan(x, y)
	ATan2(x, y) {
		return (DllCall("msvcrt\atan2", "Double", y, "Double", x, "Double"))
	}

	;* Description:
		;* `hypotenuse/opposite`.
	Csc(radians) {
		return (1/DllCall("msvcrt\sin", "Double", radians, "Double"))
	}

	ACsc(radians) {
		if (!(radians < -1 && radians > 1)) {
			throw, (Exception("NaN.", -1, Format("Math.ACsc({}) is out of bounds.", radians)))
		}

		return (DllCall("msvcrt\asin", "Double", 1/radians, "Double"))   ;* (-inf, -1] ∪ [1, inf)
	}

	;* Description:
		;* `hypotenuse/adjacent`.
	Sec(radians) {
		return (1/DllCall("msvcrt\cos", "Double", radians, "Double"))
	}

	ASec(radians) {
		if (!(radians < -1 && radians > 1)) {
			throw, (Exception("NaN.", -1, Format("Math.ASec({}) is out of bounds.", radians)))
		}

		return (DllCall("msvcrt\acos", "Double", 1/radians, "Double"))   ;* (-inf, -1] ∪ [1, inf)
	}

	;* Description:
		;* `adjacent/opposite`.
	Cot(radians) {
		return (1/DllCall("msvcrt\tan", "Double", radians, "Double"))
	}

	ACot(radians) {
		return (DllCall("msvcrt\atan", "Double", 1/radians, "Double"))
	}

	;-------------------------------------- Hyperbolic ----------------------------;

	SinH(radians) {
		return (DllCall("msvcrt\sinh", "Double", radians, "Double"))
	}

	ASinH(radians) {
		return (Ln(radians + Sqrt(radians**2 + 1)))
	}

	CosH(radians) {
		return (DllCall("msvcrt\cosh", "Double", radians, "Double"))
	}

	ACosH(radians) {
		if (radians < 1) {
			throw, (Exception("NaN.", -1, Format("Math.ACosH({}) is out of bounds.", radians)))
		}

		return (Ln(radians + Sqrt(radians**2 - 1)))  ;* θ >= 1
	}

	TanH(radians) {
		return (DllCall("msvcrt\tanh", "Double", radians, "Double"))
	}

	ATanH(radians) {
		if (radians < -1 || radians > 1) {
			throw, (Exception("NaN.", -1, Format("Math.ATanH({}) is out of bounds.", radians)))
		}

		return (0.5*Ln((1 + radians)/(1 - radians)))  ;* (-1, 1)
	}

	CscH(radians) {
		if (!radians) {
			throw, (Exception("NaN.", -1, Format("Math.CscH({}) is out of bounds.", radians)))
		}

		return (1/DllCall("msvcrt\sinh", "Double", radians, "Double"))  ;* (-inf, 0) U (0, inf)
	}

	ACscH(radians) {
		if (radians != 0) {
			throw, (Exception("NaN.", -1, Format("Math.ACscH({}) is out of bounds.", radians)))
		}

		return (Ln(1/radians + Sqrt(1 + radians**2)/Abs(radians))) ;* θ != 0
	}

	SecH(radians) {
		return (1/DllCall("msvcrt\cosh", "Double", radians, "Double"))
	}

	ASecH(radians) {
		if (radians < 0 || radians >= 1) {
			throw, (Exception("NaN.", -1, Format("Math.ASecH({}) is out of bounds.", radians)))
		}

		return (Ln(1/radians + Sqrt(1/radians**2 - 1)))  ;* (0, 1]
	}

	CotH(radians) {
		if (!radians) {
			throw, (Exception("NaN.", -1, Format("Math.CotH({}) is out of bounds.", radians)))
		}

		return (1/DllCall("msvcrt\tanh", "Double", radians, "Double"))  ;* (-inf, 0) U (0, inf)
	}

	ACotH(radians) {
		if (!(this.Abs(radians) > 1)) {
			throw, (Exception("NaN.", -1, Format("Math.ACotH({}) is out of bounds.", radians)))
		}

		return (0.5*Ln((radians + 1)/(radians - 1)))  ;* |θ| > 1
	}

	;------------------------------------------------------  Integer  --------------;
	;----------------------------------- Division-related -------------------------;

	;* Math.GCD(integers*)
	;* Description:
		;* Calculates the greatest common divisor of two or more integers.
	GCD(integers*) {
		Static mCode := [MCode("2,x64:QYnIiciJ0UHB+B/B+R9EMcAxykQpwCnKDx+EAAAAAAA50HQKOcJ9CCnQOdB19vPDKcLr7JCQkJA="), MCode("2,x64:iwGD+gF+V4PqAkyNQQRMjVSRCEGLEEGLCEGJwUHB+R9EMcjB+h8x0SnRicJEKcqJyDnRdRHrGWYPH4QAAAAAACnQOdB0CjnQf/YpwjnQdfaD+AF0CUmDwARNOdB1tfPD")]
		integers := [integers*]

		if (Type(integers[0]) == "Array" || Type(integers[1]) == "Array" || integers.Count() > 2) {
			o := [].Concat(integers*), VarSetCapacity(a, o.Count*4, 0), c := 0

			for i, v in o {
				if (!this.IsInteger(v)) {
					throw, (Exception("TypeError.", -1, Format("Math.GCD({}) may only contain integers.", integers.Print())))
				}

				NumPut(v, a, (c++)*4, "Int")
			}

			return (DllCall(mCode[1], "Int", &a, "Int", c, "Int"))
		}

		if (this.IsInteger(integers[0]) && this.IsInteger(integers[1])) {
			return (DllCall(mCode[0], "Int", integers[0], "Int", integers[1], "Int"))
		}

		throw, (Exception("TypeError.", -1, Format("Math.GCD({}) may only contain integers.", integers.Join(", "))))
	}

	;* Math.LCM(integers*)
	;* Description:
		;* Calculates the greatest common multiple of two or more integers.
	LCM(integer*) {
		Static mCode := MCode("2,x64:QYnIiciJ0UHB+B/B+R9EMcAxykQpwCnKDx+EAAAAAAA50HQKOcJ9CCnQOdB19vPDKcLr7JCQkJA=")
		integer := [integer*]

		if (Type(integer[0]) == "Array" || Type(integer[1]) == "Array" || integer.Count() > 2) {
			r := (o := [].Concat(integer*)).Shift()

			for i, v in o {
				if (!(this.IsInteger(r) && this.IsInteger(v))) {
					throw, (Exception("TypeError.", -1, Format("Math.LCM({}) may only contain integers.", integer.Print())))
				}

				r := r*v/DllCall(mCode, "Int", r, "Int", v, "Int")
			}

			return (Floor(r))
		}

		if (this.IsInteger(integer[0]) && this.IsInteger(integer[1])) {
			return (Floor(integer[0]*integer[2]/DllCall(mCode, "Int", integer[1], "Int", integer[1], "Int")))
		}

		throw, (Exception("TypeError.", -1, Format("Math.LCM({}) may only contain integers.", integer.Join(", "))))
	}

	;---------------------------------- Recurrence and Sum ------------------------;

	;* Math.Factorial(integer)
	;* Description:
		;* Calculate the factorial of an integer.
	Factorial(integer) {
		if (!this.IsPositiveInteger(integer)) {
			throw, (Exception("NaN.", -1, Format("Math.Factorial({}) is out of bounds.", integer)))
		}

		Static mCode := MCode("2,x64:hcl+GYPBAboBAAAAuAEAAAAPr8KDwgE5ynX288O4AQAAAMOQkJCQ")

		return (DllCall(mCode, "Int", integer, "Int"))
	}

	;* Math.Fibonacci(n)
	;* Description:
		;* Calculate the `n`ᵗʰ Fibonacci number.
	Fibonacci(n) {
		if (!this.IsPositiveInteger(n)) {
			throw, (Exception("NaN.", -1, Format("Math.Fibonacci({}) is out of bounds.", n)))
		}

		Static mCode := MCode("2,x64:hcl+L4PBAboBAAAAuAEAAABFMcDrDWYuDx+EAAAAAABEiciDwgFFjQwAQYnAOdF17/PDMcDDkJA=")

		return (DllCall(mCode, "Int", n, "Int"))
	}

	;----------------------------------- Number Theoretic -------------------------;

	;* Math.Prime(n)
	;* Description:
		;* Calculate the `n`ᵗʰ prime number.
	Prime(n) {
		if (!(this.IsInteger(n) && n > 0)) {
			throw, (Exception("NaN.", -1, Format("Math.Prime({}) is out of bounds.", n)))
		}

		Static mCode := MCode("2,x64:QbkCAAAAg/kBfmJBugEAAABBuQEAAABBu1ZVVVUPHwBBg8ECQYP5A3Q6RInIQffrRInIwfgfKcKNBFJBOcF0KEG4AwAAAOsTDx+EAAAAAABEiciZQff4hdJ0DUGDwAJFOcF/7EGDwgFBOcp1s0SJyMOQkJCQ")

		return (DllCall(mCode, "Int", n, "Int"))
	}

	;-----------------------------------------------------  Numerical  -------------;
	;-------------------------------------- Arithmetic ----------------------------;

	;* Math.Abs(number)
	;* Description:
		;* Calculate the absolute value of a number.
	Abs(number) {
		if (number == -9223372036854775808) {
			throw, (Exception("Overflow.", -1, Format("Math.Abs({}) has no 64-bit non-negative equal in magnitude.", number)))
		}

		if (this.IsNumber(number)) {
			return (Abs(number))
		}
	}

	;* Math.Clamp(number, lower, upper)
	;* Description:
		;* Limit a number to a upper and lower value.
	Clamp(number, lower, upper) {
		return (((number := (number < lower) ? (lower) : (number)) > upper) ? (upper) : (number))
	}

	;* Math.CopySign(number1, number2)
	;* Description:
		;* Copy the sign of `number2` to `number1`.
	CopySign(number1, number2) {
		return (Abs(number1)*((number2 < 0) ? (-1) : (1)))
	}

	;* Math.Mod(number, divisor)
	Mod(number, divisor) {
		return (Mod(number, divisor))
	}

	;* Math.Sign(number)
	;* Description:
		;* Calculate the sign of a number.
	Sign(number) {
		return ((number > 0) - (number < 0))
	}

	;* Math.Wrap(number, lower, upper)
	Wrap(number, lower, upper) {
		return ((number < lower) ? (upper - Mod(lower - number, upper - lower)) : (lower + Mod(number - lower, upper - lower)))
	}

	;----------------------------------  Integral Rounding  ------------------------;

	;* Math.Ceil(number, (decimalPlace))
	;* Description:
		;* Round a number towards plus infinity.
	Ceil(number, decimalPlace := 0) {
		p := 10**decimalPlace

		return (Ceil(number*p)/p)
	}

	;* Math.Floor(number, (decimalPlace))
	;* Description:
		;* Round a number towards minus infinity.
	Floor(number, decimalPlace := 0) {
		p := 10**decimalPlace

		return (Floor(number*p)/p)
	}

	;* Math.Fix(number, (decimalPlace))
	;* Description:
		;* Round a number towards zero.
	Fix(number, decimalPlace := 0) {
		p := 10**decimalPlace

		return (number < 0 ? Ceil(number*p)/p : Floor(number*p)/p)
	}

	;* Math.Round(number, (decimalPlace))
	;* Description:
		;* Round a number towards the nearest integer and strips trailing zeros.
	Round(number, decimalPlace := 0) {
		return (Round(number, decimalPlace))
	}

	;-------------------------------------  Statistical  ---------------------------;

	;* Math.Min(numbers*)
	;* Description:
		;* Calculate the numerically smallest of two or more numbers.
	Min(numbers*) {
		return (Min(numbers*))
	}

	;* Math.Max(numbers*)
	;* Description:
		;* Calculate the numerically largest of two or more numbers.
	Max(numbers*) {
		return (Max(numbers*))
	}

	;* Math.Mean(numbers*)
	;* Description:
		;* Calculate statistical mean of two or more numbers.
	Mean(numbers*) {
		for i, v in numbers {
			t += v
		}

		return (t/i)
	}

	;* Percentage(number, percentage)
	Percentage(number, percentage) {
		return (number/100.0*percentage)
	}

	;* PercentageChange(number1, number2)
	PercentageChange(number1, number2) {
		return ((number2 - number1)/Abs(number1)*100)
	}

	;* PercentageDifference(number1, number2)
	PercentageDifference(number1, number2) {
		return (Abs(number1 - number2)/((number1 + number2)/2)*100)
	}

	;----------------------------------------------------  Probability  ------------;

	Class Random {

		;---------------------------------------- Normal ------------------------------;

		Normal(min := 0.0, max := 1.0) {
			loop, 12 {
				u += this.Uniform()
			}

			return ((u/12)*(max - min) + min)  ;! return (((u/12)*(max - min) + min)*deviation + mean)
		}

		;* Math.Random.Ziggurat((mean), (deviation))
		;* Description:
			;* https://en.wikipedia.org/wiki/Ziggurat_algorithm.
		;* Note:
			;* This algorithm is ~3.5 times faster than the Box Muller transform.
		Ziggurat(mean := 0, deviation := 1.0) {
			Static __K := (v := Math.Random.__Ziggurat()).k, __W := v.w, __F := v.f  ;* Populate the lookup tables.

			loop {
				u := this.Uniform(-0x80000000, 0x7FFFFFFF), i := u & 0xFF

				if (Abs(u) < __K[i]) {  ;* Rectangle. This will be the case for 99.33% of values (512 rectangles would be 99.64%).
					return (u*__W[i]*deviation + mean)
				}

				x := u*__W[i]

				if (i == 0) {  ;* Base segment. Sample using a ratio of uniforms.
					While (2*y <= x**2) {
						x := -Ln(this.Uniform())*.273661237329758, y := -Ln(this.Uniform())  ;? .273661237329758 = 1/r
					}

					return (((u > 0)*2 - 1)*(3.654152885361009 + x)*deviation + mean)
				}

				if ((__F[i - 1] - __F[i])*this.Uniform() + __F[i] < Exp(-.5*x**2)) {  ;* Wedge.
					return (x*deviation + mean)
				}

				;* The wedge was missed; start again.
			}
		}
		__Ziggurat() {
			r := 3.654152885361009, v := 0.00492867323399, q := Exp(-.5*r**2)  ;? r = start of the tail, v = area of each rectangle
				, k := [(r*(q/v*2147483648.0)), 0], w := [(v/q)/2147483648.0], w[255] := r/2147483648.0, f := [1.0], f[255] := q  ;* Index zero is for the base segment, where Marsaglia and Tsang define this as k[0] = 2^31*r*f(r)/v, w[0] = .5^31*v/f(r), f[0] = 1.0.

			i := 255
			While (--i) {
				x := Sqrt(-2.0*Ln(v/r + f[i + 1]))

				k[i + 1] := ((x/r)*2147483648.0), w[i] := x/2147483648.0, f[i] := Exp(-.5*x**2)

				r := x
			}

			return ({"k": k, "w": w, "f": f})
		}

		;* Math.Random.MarsagliaPolar((mean), (deviation))
		;* Description:
			;* https://en.wikipedia.org/wiki/Marsaglia_polar_method.
		;* Note:
			;* This algorithm does not involve any approximations so it has the proper behavior even in the tail of the distribution. It is however moderately expensive since the efficiency of the rejection method is `e = π/4 ≈ 0.785`, so about 21.5% of the uniformly distributed points within the square are discarded. The square root and the logarithm also contribute significantly to the computational cost.
		MarsagliaPolar(mean := 0, deviation := 1.0) {
			Static spare

			if (!spare) {
				s := 0

				while (s >= 1 || s == 0) {  ;* `s` may not be 0 because `log(0)` will generate an error.
					u := 2.0*this.Uniform() - 1, v := 2.0*this.Uniform() - 1
						, s := u**2 + v**2
				}

				spare := (s := Sqrt(-2.0*Ln(s)/s))*v, s *= u
			}
			else {
				Swap(s, spare)
			}

			return (s*deviation + mean)
		}

		;---------------------------------------  Uniform  -----------------------------;

		;* Math.Random.Uniform((min), (max))
		Uniform(min := 0.0, max := 1.0) {
			Random, u, min, max

			return (u)
		}

		;* Math.Random.Uniform64((min), (max))
		;* Description:
			;* Combines (if needed) two random numbers generated by `Random` to provide a random number in any range.
		;* Credit:
			;* Laszlo (https://autohotkey.com/board/topic/19233-64-bit-random-numbers/).
		Uniform64(min := -0x80000000, max := 0x7FFFFFFF) {  ;? 0x7FFFFFFF = 2**31 - 1
			d := max - min

			if (d > 0) {  ;* No overflow.
				if (d <= 0xFFFFFFFF) {  ;* 32-bit case.
					Random, u, -0x80000000, d - 0x80000000

					return (u + min + 0x80000000)
				}
				else {  ;* Range < 2**63.
					loop {
						Random, u1, 0, (1 << (1 + DllCall("ntdll\RtlFindMostSignificantBit", "Int64", d >> 32))) - 1
						Random, u2, -0x80000000, 0x7FFFFFFF
						r := (u1 << 32) | u2 + 0x80000000

						if (r <= d) {
							return (r + min)  ;! (Math.Random.Uniform(0, 2147483647) & 0xFFFF << 16 | Math.Random.Uniform(0, 2147483647) & 0xFFFF)
						}
					}
				}
			}

			loop {  ;* Range >= 2**63.
				Random, u1, -0x80000000, 0x7FFFFFFF
				Random, u2, -0x80000000, 0x7FFFFFFF
				r := (u1 << 32) | u2 + 0x80000000

				if (min <= r && r <= max) {
					return (r)
				}
			}
		}

		;* Math.Random.Bool((probability))
		Bool(probability := 0.5) {
			return (this.Uniform() >= probability)
		}

		;* Math.Random.Seed(seed)
		Seed(seed) {
			Random, , seed
		}
	}
}