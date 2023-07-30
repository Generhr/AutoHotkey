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

class Vec3 extends Array {

    /*
     * Indicates whether two vectors are equal.
     */
    static Equals(vector1, vector2) {
        return (vector1 is Vec3 && vector2 is Vec3 && vector1.Every((element, index, *) => (element == vector2[index])))
    }

    ;* Vec2.Divide(vector1, vector2)
    static Divide(vector1, vector2) {
        try {
            return (this(vector1[0]/vector2[0], vector1[1]/vector2[1], vector1[2]/vector2[2]))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
        ;* Use the default ZeroDivisionError.
    }

    static DivideScalar(vector, scalar) {
        try {
            return (this(vector[0]/scalar, vector[1]/scalar, vector[2]/scalar))
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
        catch TypeError {
            throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    ;* Vec2.Multiply(vector1, vector2)
    static Multiply(vector1, vector2) {
        try {
            return (this(vector1[0]*vector2[0], vector1[1]*vector2[1], vector1[2]*vector2[2]))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    static MultiplyScalar(vector, scalar) {
        try {
            return (this(vector[0]*scalar, vector[1]*scalar, vector[2]*scalar))
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
        catch TypeError {
            throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    ;* Vec2.Add(vector1, vector2)
    static Add(vector1, vector2) {
        try {
            return (this(vector1[0] + vector2[0], vector1[1] + vector2[1], vector1[2] + vector2[2]))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    static AddScalar(vector, scalar) {
        try {
            return (this(vector[0] + scalar, vector[1] + scalar, vector[2] + scalar))
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
        catch TypeError {
            throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    ;* Vec2.Subtract(vector1, vector2)
    static Subtract(vector1, vector2) {
        try {
            return (this(vector1[0] - vector2[0], vector1[1] - vector2[1], vector1[2] - vector2[2]))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    static SubtractScalar(vector, scalar) {
        try {
            return (this(vector[0] - scalar, vector[1] - scalar, vector[2] - scalar))
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
        catch TypeError {
            throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    ;* Vec2.Distance(vector1, vector2)
    static Distance(vector1, vector2) {
        try {
            return (Sqrt((vector1[0] - vector2[0])**2 + (vector1[1] - vector2[1])**2 + (vector1[2] - vector2[2])**2))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    ;* Vec2.DistanceSquared(vector1, vector2)
    static DistanceSquared(vector1, vector2) {
        try {
            return ((vector1[0] - vector2[0])**2 + (vector1[1] - vector2[1])**2 + (vector1[2] - vector2[2])**2)
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    /*
     * Calculates the dot product (scalar) of two vectors (greatest yield for parallel vectors).
     */
    static Dot(vector1, vector2) {
        try {
            return (vector1[0]*vector2[0] + vector1[1]*vector2[1] + vector1[2]*vector2[2])  ;? Math.Abs(a.Length)*Math.Abs(b.Length)*Math.Cos(AOB)
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    /*
     * Calculates the cross product (vector) of two vectors (greatest yield for perpendicular vectors).
     */
    static Cross(vector1, vector2) {
        try {
            a1 := vector1[0], a2 := vector1[1], a3 := vector1[2]
                , b1 := vector2[0], b2 := vector2[1], b3 := vector2[2]

            ;[a2*b3 - a3*b2]
            ;[a3*b1 - a1*b3]
            ;[a1*b2 - a2*b1]

            return (this(a2*b3 - a3*b2, a3*b1 - a1*b3, a1*b2 - a2*b1))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    static Transform(vector, matrix) {
        try {
            x := vector[0], y := vector[1], z := vector[2]

            switch (Type(matrix)) {
;               case "TransformMatrix":
;                   return (this(matrix[0]*x + matrix[3]*y + matrix[6], matrix[1]*x + matrix[4]*y + matrix[7]))
                case "Matrix3", "RotationMatrix":
                    return (this(matrix[0]*x + matrix[3]*y + matrix[6]*z, matrix[1]*x + matrix[4]*y + matrix[7]*z, matrix[2]*x + matrix[5]*y + matrix[8]*z))
            }

            return (this(matrix[0]*x + matrix[3]*y + matrix[6]*z, matrix[1]*x + matrix[4]*y + matrix[7]*z, matrix[2]*x + matrix[5]*y + matrix[8]*z))
        }
        catch IndexError {
            throw ((vector is Array && vector.Length == 3)
                ? (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
                : (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    /*
     * Returns a new vector that is the linear blend of the two given vectors.
     * @param {Vec3} vector1 - The starting vector.
     * @param {Vec3} vector2 - The vector to interpolate towards.
     * @param {Number} alpha - Interpolation factor, typically in the closed interval [0, 1].
     */
    static Lerp(vector1, vector2, alpha) {
        try {
            return (this(vector1[0] + (vector2[0] - vector1[0])*alpha, vector1[1] + (vector2[1] - vector1[1])*alpha, vector1[2] + (vector2[2] - vector1[2])*alpha))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
        catch TypeError {
            throw (TypeError("``alpha`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    /*
     * Clamp a vector to the given minimum and maximum vectors or values.
     *
     * Note: Assumes `lower` is less than `upper`.
     * @param {Vec3} vector - Input vector.
     * @param {Vec3} lower - Minimum vector.
     * @param {Vec3} upper - Maximum vector.
     */
    static Clamp(vector, lower, upper) {
        try {
            return (this(Max(lower[0], Min(upper[0], vector[0])), Max(lower[1], Min(upper[1], vector[1])), Max(lower[2], Min(upper[2], vector[2]))))
        }
        catch IndexError {
            throw ((vector is Array && vector.Length == 3)
                ? ((lower is Array && lower.Length == 3)
                    ? (TypeError("``upper`` is invalid.", -1, "This parameter must be an Array with three elements."))
                    : (TypeError("``lower`` is invalid.", -1, "This parameter must be an Array with three elements.")))
                : (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    ;* Vec2.Min(vector1, vector2)
    static Min(vector1, vector2) {
        try {
            return (this(Min(vector1[0], vector2[0]), Min(vector1[1], vector2[1]), Min(vector1[2], vector2[2])))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    ;* Vec2.Max(vector1, vector2)
    static Max(vector1, vector2) {
        try {
            return (this(Max(vector1[0], vector2[0]), Max(vector1[1], vector2[1]), Max(vector1[2], vector2[2])))
        }
        catch IndexError {
            throw ((vector1 is Array && vector1.Length == 3)
                ? (TypeError("``vector2`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``vector1`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    ;* Vec2([x, y])
    __New(x := 0, y := 0, z := 0) {
        this.Push(x, y, z)
    }

    Clone() {
        return (Vec3(this*))
    }

    x {
        Get {
            return (this[0])
        }

        Set {
            return (this[0] := value)
        }
    }

    y {
        Get {
            return (this[1])
        }

        Set {
            return (this[1] := value)
        }
    }

    z {
        Get {
            return (this[2])
        }

        Set {
            return (this[2] := value)
        }
    }

    ;* vector.Magnitude[ := value]
    ;* Description:
        ;* Calculates the length (magnitude) of the vector.
    Magnitude {
        Get {
            return (Sqrt(this[0]**2 + this[1]**2 + this[2]**2))
        }

        Set {
            this.Normalize().MultiplyScalar(value)

            return (value)
        }
    }

    ;* vector.MagnitudeSquared
    MagnitudeSquared {
        Get {
            return (this[0]**2 + this[1]**2 + this[2]**2)
        }
    }

    Copy(vector) {
        try {
            return (this.Set(vector[0], vector[1], vector[2]))
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
    }

    Set(x, y, z) {
        this[0] := x, this[1] := y, this[2] := z

        return (this)
    }

    SetScalar(scalar) {
        this[0] := scalar, this[1] := scalar, this[2] := scalar

        return (this)
    }

    /*
     * Inverts this vector.
     */
    Negate() {
        this[0] *= -1, this[1] *= -1, this[2] *= -1

        return (this)
    }

    /*
     * Normalises the vector such that it's length/magnitude is 1. The result is called a unit vector.
     */
    Normalize() {
        if (magnitude := this.Magnitude) {
            this[0] /= magnitude, this[1] /= magnitude, this[2] /= magnitude
        }

        return (this)
    }

    Divide(vector) {
        try {
            this[0] /= vector[0], this[1] /= vector[1], this[2] /= vector[2]

            return (this)
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
    }

    DivideScalar(scalar) {
        try {
            this[0] /= scalar, this[1] /= scalar, this[2] /= scalar

            return (this)
        }
        catch TypeError {
            throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    Multiply(vector) {
        try {
            this[0] *= vector[0], this[1] *= vector[1], this[2] *= vector[2]

            return (this)
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
    }

    MultiplyScalar(scalar) {
        try {
            this[0] *= scalar, this[1] *= scalar, this[2] *= scalar

            return (this)
        }
        catch TypeError {
            throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    Add(vector) {
        try {
            this[0] += vector[0], this[1] += vector[1], this[2] += vector[2]

            return (this)
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
    }

    AddScalar(scalar) {
        try {
            this[0] += scalar, this[1] += scalar, this[2] += scalar

            return (this)
        }
        catch TypeError {
            throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    Subtract(vector) {
        try {
            this[0] -= vector[0], this[1] -= vector[1], this[2] -= vector[2]

            return (this)
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
    }

    SubtractScalar(scalar) {
        try {
            this[0] -= scalar, this[1] -= scalar, this[2] -= scalar

            return (this)
        }
        catch TypeError {
            throw (TypeError("``scalar`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    Transform(matrix) {
        try {
            x := this[0], y := this[1], z := this[2]

            switch (Type(matrix)) {
;               case "TransformMatrix":
;                   ;             [m11   m12   0]
;                   ; [x   y   1] [m21   m22   0] = [x*m11 + y*m21 + 1*m31   x*m12 + y*m22 + 1*m32]
;                   ;             [m31   m32   1]
;
;                   return (this.Set(x*matrix[0] + y*matrix[3] + matrix[6], x*matrix[1] + y*matrix[4] + matrix[7]))
                case "Matrix3", "RotationMatrix":
                    return (this.Set(matrix[0]*x + matrix[3]*y + matrix[6]*z, matrix[1]*x + matrix[4]*y + matrix[7]*z, matrix[2]*x + matrix[5]*y + matrix[8]*z))
            }
        }
        catch IndexError {
            throw (TypeError("``matrix`` is invalid.", -1, "This parameter must be an Array."))
        }
    }

    Lerp(vector, alpha) {
        try {
            this[0] += (vector[0] - this[0])*alpha, this[1] += (vector[1] - this[1])*alpha, this[2] += (vector[2] - this[2])*alpha

            return (this)
        }
        catch IndexError {
            throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
        }
        catch TypeError {
            throw (TypeError("``alpha`` is invalid.", -1, "This parameter must be a Number."))
        }
    }

    Clamp(lower, upper) {
        try {
            return (this.Set(Max(lower[0], Min(upper[0], this[0])), Max(lower[1], Min(upper[1], this[1])), Max(lower[2], Min(upper[2], this[2]))))
        }
        catch IndexError {
            throw ((lower is Array && lower.Length == 3)
                ? (TypeError("``upper`` is invalid.", -1, "This parameter must be an Array with three elements."))
                : (TypeError("``lower`` is invalid.", -1, "This parameter must be an Array with three elements.")))
        }
    }

    ClampScalar(lower, upper) {
        try {
            return (this.Set(Max(lower, Min(upper, this[0])), Max(lower, Min(upper, this[1])), Max(lower, Min(upper, this[2]))))
        }
        catch TypeError {
            throw ((lower is Number)
                ? (TypeError("``upper`` is invalid.", -1, "This parameter must be a Number."))
                : (TypeError("``lower`` is invalid.", -1, "This parameter must be a Number.")))
        }
    }

;   ClampMagnitude(lower, upper) {
;       if (magnitude := this.Magnitude) {
;           this.DivideScalar(magnitude)
;       }
;
;       try {
;           return (this.MultiplyScalar(Max(lower, Min(upper, magnitude))))
;       }
;       catch TypeError {
;           throw ((lower is Number)
;               ? (TypeError("``upper`` is invalid.", -1, "This parameter must be a Number."))
;               : (TypeError("``lower`` is invalid.", -1, "This parameter must be a Number.")))
;       }
;   }
;
;   Ceil(decimalPlace := false) {
;       try {
;           if (decimalPlace) {
;               p := 10**decimalPlace
;
;               return (this.Set(Round(Ceil(this[0]*p)/p, decimalPlace), Round(Ceil(this[1]*p)/p, decimalPlace)))
;           }
;
;           return (this.Set(Ceil(this[0]), Ceil(this[1])))
;       }
;       catch TypeError {
;           throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
;       }
;   }
;
;   Floor(decimalPlace := false) {
;       try {
;           if (decimalPlace) {
;               p := 10**decimalPlace
;
;               return (this.Set(Round(Floor(this[0]*p)/p, decimalPlace), Round(Floor(this[1]*p)/p, decimalPlace)))
;           }
;
;           return (this.Set(Floor(this[0]), Floor(this[1])))
;       }
;       catch TypeError {
;           throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
;       }
;   }
;
;   Fix(decimalPlace := false) {
;       try {
;           x := this[0], y := this[1]
;
;           if (decimalPlace) {
;               p := 10**decimalPlace
;
;               return (this.Set(Round((x < 0) ? (Ceil(x*p)/p) : (Floor(x*p)/p), decimalPlace), Round((y < 0) ? (Ceil(y*p)/p) : (Floor(y*p)/p), decimalPlace)))
;           }
;
;           return (this.Set((x < 0) ? (Ceil(x)) : (Floor(x)), (y < 0) ? (Ceil(y)) : (Floor(y))))
;       }
;       catch TypeError {
;           throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
;       }
;   }
;
;   Round(decimalPlace := false) {
;       try {
;           return ((decimalPlace)
;               ? (this.Set(Round(this[0], decimalPlace), Round(this[1], decimalPlace)))
;               : (this.Set(Round(this[0]), Round(this[1]))))
;       }
;       catch TypeError {
;           throw (TypeError("``decimalPlace`` is invalid.", -1, "This parameter must be a Number."))
;       }
;   }
;
;   Min(vector) {
;       try {
;           return (this.Set(Min(this[0], vector[0]), Min(this[1], vector[1])))
;       }
;       catch IndexError {
;           throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
;       }
;   }
;
;   Max(vector) {
;       try {
;           return (this.Set(Max(this[0], vector[0]), Max(this[1], vector[1])))
;       }
;       catch IndexError {
;           throw (TypeError("``vector`` is invalid.", -1, "This parameter must be an Array with three elements."))
;       }
;   }
}
