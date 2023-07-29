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

#DllLoad "msvcrt"
;#DllLoad "..\Math\lib\random"

;============ Auto-Execute ====================================================;

#Include ../Core.ahk

;===============  Class  =======================================================;

class Math {

  __New(params*) {
    throw (TargetError("This class may not be constructed.", -1))
  }

  /*
    ** Constants: https://numerics.mathdotnet.com/Constants.html. **
  */

  /**
   * Euler's exponential constant.
   */
  static E {
    get {
      return (2.718281828459045)  ;? ≈ Exp(1)
    }
  }

  /**
   * The smallest signficant differentiation between two floating point values. Useful as a tolerance when testing if two single precision real numbers approximate each other.
   *
   * Note: The smallest 32-bit integer greater than zero is `1/(2**32 - 1)`.
   */
  static Epsilon {
    get {
      epsilon := 1.0

      while (epsilon + 1 > 1) {
        epsilon /= 2
      }

      this.DefineProp("Epsilon", { Value: epsilon *= 2 })  ;* Only initialize this value as needed.

      return (epsilon)
    }
  }

  /**
   * The base-2 logarithm of a number.
   */
  static Log2[number?] {
    get {
      if (IsSet(number)) {
        try {
          return (Ln(number) / 0.693147180559945)
        }

        throw (ValueError("``number`` may not be less than zero.", -1, number))

      }

      return (0.693147180559945)
    }
  }

  /**
   * The base-2 logarithm of E.
   */
  static Log2E {
    get {
      return (1.442695040888963)
    }
  }

  /**
   * The base-10 logarithm of a number.
   */
  static Log10[number?] {
    get {
      if (IsSet(number)) {
        try {
          return (Log(number))
        }

        throw (ValueError("``number`` may not be less than zero.", -1, number))

      }

      return (2.302585092994046)
    }
  }

  /**
   * The base-10 logarithm of E.
   */
  static Log10E {
    get {
      return (0.434294481903252)
    }
  }

  static Pi {
    get {
      return (3.141592653589793)  ;? ≈ ACos(-1)
    }
  }

  /**
   * The ratio of a circle's circumference to its diameter (τ).
   */
  static Tau {
    get {
      return (6.283185307179587)
    }
  }

  ;===================================================== Comparison =============;

  /**
   * Determine whether a number is within bounds (inclusive) and is not an excluded number.
   */
  static IsBetween(number, lower, upper, exclude*) {
    for v in exclude {
      if (v == number) {
        return (False)
      }
    }

    return ((number - lower) * (number - upper) <= 0)
  }

  static IsEven(number) {
    return (Mod(number, 2) == 0)
  }

  static IsHexadecimal(number) {
    return (IsXDigit(number))
  }

  static IsFloat(number) {
    return (IsFloat(number))
  }

  static IsInteger(number) {
    return (IsInteger(number))
  }

  static IsNegativeInteger(number) {
    return (IsInteger(number) && number < 0)
  }

  static IsPositiveInteger(number) {
    return (IsInteger(number) && number >= 0)
  }

  static IsNumber(number) {
    return (IsNumber(number))
  }

  static IsPrime(number) {
    if (number < 2) {
      return (False)
    }

    loop (Floor(this.Sqrt(number))) {
      if (Mod(number, A_Index) == 0 && A_Index > 1) {
        return (False)
      }
    }

    return (True)
  }

  static IsSquare(number) {
    return (IsInteger(this.Sqrt(number)))
  }

  ;===================================================== Conversion =============;
  ;-------------------------------------------------------  Angle  ---------------;

  static ToDegrees(radians) {
    try {
      return (radians * 57.295779513082321)
    }

    throw (TypeError("``radians`` must be a number.", -1, radians))
  }

  static ToRadians(degrees) {
    try {
      return (degrees * 0.017453292519943)
    }

    throw (TypeError("``degrees`` must be a number.", -1, degrees))
  }

  ;-------------------------------------------------------- Base ----------------;

  static ToBase(number, currentBase, targetBase) {
    if (number < 0) {
      sign := "-", number := Abs(number)
    }

    result := DllCall("msvcrt\_i64tow", "Int64", DllCall("msvcrt\_wcstoui64", "Str", number, "UInt", 0, "UInt", currentBase, "Int64"), "Ptr*", 0, "UInt", targetBase, "Str")

    if (targetBase > 10) {
      result := Format("0x{:U}", result)
    }

    return (sign . result)
  }

  static ToDecimal(hexadecimal) {
    return (DllCall("msvcrt\_wcstoui64", "Str", hexadecimal, "UInt", 0, "UInt", 16, "Int64"))
  }

  static ToHexadecimal(decimal) {
    if (decimal < 0) {
      sign := "-", decimal := Abs(decimal)
    }

    return (Format("{}0x{:U}", sign, DllCall("msvcrt\_i64tow", "Int64", decimal, "Ptr*", 0, "UInt", 16, "Str")))
  }

  ;-------------------------------------------------------  Other  ---------------;

  /**
   * Re-maps a number from one range to another.
   */
  static Map(value, start1, stop1, start2, stop2) {
    return (start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1)))
  }

  ;===================================================== Elementary =============;
  ;----------------------------------------------------  Exponential  ------------;

  /**
   * Calculates the exponent of a number.
   */
  static Exp(number) {
    return (Exp(number))
  }

  /**
   * Calculates the logarithm of a number.
   */
  static Log(base, number := "") {
    if (number == "") {
      number := base, base := ""
    }

    try {
      return ((base == "") ? (Ln(number)) : (Ln(number) / Ln(base)))
    }

    throw (ValueError("``number`` may not be less than zero.", -1, number))
  }

  ;-------------------------------------------------------- Root ----------------;

  /**
   * Calculates the cubic root of a number.
   */
  static Cbrt(number) {
    return ((number < 0) ? (-(-number) ** (1 / 3)) : (number ** (1 / 3)))
  }

  /**
   * Calculates the square root of a number.
   */
  static Sqrt(number) {
    try {
      return (Sqrt(number))
    }

    throw (ValueError("``number`` may not be less than zero.", -1, number))
  }

  /**
   * Calculates the nᵗʰ root of a number.
   */
  static Surd(number, n) {
    return (this.Abs(number) ** (1 / n) * ((number > 0) - (number < 0)))
  }

  ;---------------------------------------------------  Trigonometric  -----------;

  /**
   * opposite/hypotenuse.
   */
  static Sin(radians) {
    return (DllCall("msvcrt\sin", "Double", radians, "Double"))
  }

  static ASin(radians) {
    if (radians <= -1 || radians >= 1) {
      throw (ValueError("``radians`` must be in the range [-1, 1].", -1, radians))
    }

    return (DllCall("msvcrt\asin", "Double", radians, "Double"))
  }

  /**
   * adjacent/hypotenuse.
   */
  static Cos(radians) {
    return (DllCall("msvcrt\cos", "Double", radians, "Double"))
  }

  static ACos(radians) {
    if (radians <= -1 || radians >= 1) {
      throw (ValueError("``radians`` must be in the range [-1, 1].", -1, radians))
    }

    return (DllCall("msvcrt\acos", "Double", radians, "Double"))
  }

  /**
   * opposite/adjacent.
   */
  static Tan(radians) {
    return (DllCall("msvcrt\tan", "Double", radians, "Double"))
  }

  static ATan(radians) {
    return (DllCall("msvcrt\atan", "Double", radians, "Double"))
  }

  static ATan2(y, x) {
    return (DllCall("msvcrt\atan2", "Double", y, "Double", x, "Double"))
  }

  /**
   * hypotenuse/opposite.
   */
  static Csc(radians) {
    return (1 / DllCall("msvcrt\sin", "Double", radians, "Double"))
  }

  static ACsc(radians) {
    if (!(radians < -1 && radians > 1)) {
      throw (ValueError("``radians`` must be in the range (-inf, -1] ∪ [1, inf).", -1, radians))
    }

    return (DllCall("msvcrt\asin", "Double", 1 / radians, "Double"))
  }

  /**
   * hypotenuse/adjacent.
   */
  static Sec(radians) {
    return (1 / DllCall("msvcrt\cos", "Double", radians, "Double"))
  }

  static ASec(radians) {
    if (!(radians < -1 && radians > 1)) {
      throw (ValueError("``radians`` must be in the range (-inf, -1] ∪ [1, inf).", -1, radians))
    }

    return (DllCall("msvcrt\acos", "Double", 1 / radians, "Double"))
  }

  /**
   * adjacent/opposite.
   */
  static Cot(radians) {
    return (1 / DllCall("msvcrt\tan", "Double", radians, "Double"))
  }

  static ACot(radians) {
    return (DllCall("msvcrt\atan", "Double", 1 / radians, "Double"))
  }

  ;----------------------------------------------------- Hyperbolic -------------;

  static SinH(radians) {
    return (DllCall("msvcrt\sinh", "Double", radians, "Double"))
  }

  static ASinH(radians) {
    return (Ln(radians + Sqrt(radians ** 2 + 1)))
  }

  static CosH(radians) {
    return (DllCall("msvcrt\cosh", "Double", radians, "Double"))
  }

  static ACosH(radians) {
    if (radians < 1) {
      throw (ValueError("``radians`` must be greater or equal to 1.", -1, radians))
    }

    return (Ln(radians + Sqrt(radians ** 2 - 1)))
  }

  static TanH(radians) {
    return (DllCall("msvcrt\tanh", "Double", radians, "Double"))
  }

  static ATanH(radians) {
    if (radians < -1 || radians > 1) {
      throw (ValueError("``radians`` must be in the range (-1, 1).", -1, radians))
    }

    return (0.5 * Ln((1 + radians) / (1 - radians)))
  }

  static CscH(radians) {
    if (radians == 0) {
      throw (ValueError("``radians`` may not be 0.", -1, radians))
    }

    return (1 / DllCall("msvcrt\sinh", "Double", radians, "Double"))
  }

  static ACscH(radians) {
    if (radians == 0) {
      throw (ValueError("``radians`` may not be 0.", -1, radians))
    }

    return (Ln(1 / radians + Sqrt(1 + radians ** 2) / Abs(radians)))
  }

  static SecH(radians) {
    return (1 / DllCall("msvcrt\cosh", "Double", radians, "Double"))
  }

  static ASecH(radians) {
    if (radians < 0 || radians >= 1) {
      throw (ValueError("``radians`` must be in the range (0, 1].", -1, radians))
    }

    return (Ln(1 / radians + Sqrt(1 / radians ** 2 - 1)))
  }

  static CotH(radians) {
    if (radians == 0) {
      throw (ValueError("``radians`` may not be 0.", -1, radians))
    }

    return (1 / DllCall("msvcrt\tanh", "Double", radians, "Double"))
  }

  static ACotH(radians) {
    if (!(this.Abs(radians) > 1)) {
      throw (ValueError("``radians`` must be in the range (-inf, -1) U (1, inf).", -1, radians))
    }

    return (0.5 * Ln((radians + 1) / (radians - 1)))
  }

  ;======================================================  Integer  ==============;
  ;-------------------------------------------------- Division-related ----------;

  ;------------------------------------------------- Recurrence and Sum ---------;

  ;-------------------------------------------------- Number Theoretic ----------;

  ;=====================================================  Numerical  =============;
  ;----------------------------------------------------- Arithmetic -------------;

  /**
   * Calculates the absolute value of a number.
   */
  static Abs(number) {
    return (Abs(number))
  }

  /**
   * Limit a number to a upper and lower value.
   * @param {Number} number - Value to clamp.
   * @param {Number} lower - Lower value of the range.
   * @param {Number} upper - Upper value of the range.
   * @returns {Number}
   */
  static Clamp(number, lower, upper) {
    return (((number := (number < lower) ? (lower) : (number)) > upper) ? (upper) : (number))
  }

  /**
   * Copies the sign of one number to another.
   */
  static CopySign(number1, number2) {
    return (Abs(number1) * ((number2 < 0) ? (-1) : (1)))
  }

  static Mod(number, divisor) {
    return (Mod(number, divisor))
  }

  /**
   * Calculates the sign of a number.
   */
  static Sign(number) {
    return ((number > 0) - (number < 0))
  }

  static Wrap(number, lower, upper) {
    return ((number < lower) ? (upper - Mod(lower - number, upper - lower)) : (lower + Mod(number - lower, upper - lower)))
  }

  ;-------------------------------------------------  Integral Rounding  ---------;

  /**
   * Rounds a number towards plus infinity.
   */
  static Ceil(number, decimalPlace := 0) {
    p := 10 ** decimalPlace

    return (Ceil(number * p) / p)
  }

  /**
   * Rounds a number towards minus infinity.
   */
  static Floor(number, decimalPlace := 0) {
    p := 10 ** decimalPlace

    return (Floor(number * p) / p)
  }

  /**
   * Rounds a number towards zero.
   */
  static Fix(number, decimalPlace := 0) {
    p := 10 ** decimalPlace

    return ((number < 0) ? (Ceil(number * p) / p) : (Floor(number * p) / p))
  }

  /**
   * Rounds a number towards the nearest integer.
   */
  static Round(number, decimalPlace := 0) {
    return (Round(number, decimalPlace))
  }

  ;----------------------------------------------------  Statistical  ------------;

  /**
   * Calculates the numerically smallest of two or more numbers.
   */
  static Min(numbers*) {
    return (Min(numbers*))  ;? b ^ ((a ^ b) & -(a < b))
  }

  /**
   * Calculates the numerically largest of two or more numbers.
   */
  static Max(numbers*) {
    return (Max(numbers*))  ;? a ^ ((a ^ b) & -(a < b))
  }

  /**
   * Calculates statistical mean of two or more numbers.
   */
  static Mean(numbers*) {
    for number in (total := 0, numbers) {
      total += number
    }

    return (total / numbers.Length)
  }

  static Percentage(number, percentage) {
    return (number / 100.0 * percentage)
  }

  static PercentageChange(number1, number2) {
    return ((number2 - number1) / Abs(number1) * 100)
  }

  static PercentageDifference(number1, number2) {
    return (Abs(number1 - number2) / ((number1 + number2) / 2) * 100)
  }

  ;====================================================  Probability  ============;

  class Random {

    __New(params*) {
      throw (TargetError("This class may not be constructed.", -1))
    }

    static Call(min?, max?) {
      if (!IsSet(max)) {
        if (!IsSet(min)) {
          return (DllCall("random\uniform_double", "Double", 0.0, "Double", 1.0, "Double"))
        }
        else {
          max := min, min := 0
        }
      }

      return ((IsFloat(min) || IsFloat(max)) ? (DllCall("random\uniform_double", "Double", min, "Double", max, "Double")) : (DllCall("random\uniform_int64", "Int64", min, "Int64", max, "Int64")))
    }

    static Seed(seed) {
      DllCall("random\seed", "Int64", seed)
    }

    static Bool(probability := 0.5) {
      return (this() <= probability)
    }

    static Normal(mean := 0, deviation := 1.0) {
      return (DllCall("random\normal", "Double", mean, "Double", deviation, "Double"))
    }

    /**
     * @see {@link https://en.wikipedia.org/wiki/Marsaglia_polar_method}
     */
    static MarsagliaPolar(mean := 0, deviation := 1.0) {
      static spare := 0

      s := 0

      if (!spare) {
        while (s >= 1 || s == 0) {  ;* `s` may not be 0 because `log(0)` will generate an error.
          u := 2.0 * this() - 1, v := 2.0 * this() - 1
            , s := u ** 2 + v ** 2
        }

        spare := (s := Sqrt(-2.0 * Ln(s) / s)) * v, s *= u
      }
      else {
        Swap(&s, &spare)
      }

      return (s * deviation + mean)
    }
  }
}
