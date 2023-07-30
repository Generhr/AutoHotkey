/*
    ** Row-major vs Column-major: https://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/geometry/row-major-vs-column-major-vector. **
*/

class Matrix3 extends Array {

    __New(m11 := 1, m12 := 0, m13 := 0, m21 := 0, m22 := 1, m23 := 0, m31 := 0, m32 := 0, m33 := 1) {
        this.Push(m11, m12, m13, m21, m22, m23, m31, m32, m33)
    }

    ;* Matrix3.Equals(matrix1, matrix2)
    static Equals(matrix1, matrix2) {
        return (matrix1 is Matrix3 && matrix2 is Matrix3 && matrix1.Every((element, index, *) => (element == matrix2[index])))
    }

    static Multiply(matrix1, matrix2) {
        a11 := matrix1[0], a12 := matrix1[1], a13 := matrix1[2], a21 := matrix1[3], a22 := matrix1[4], a23 := matrix1[5], a31 := matrix1[6], a32 := matrix1[7], a33 := matrix1[8]
      , b11 := matrix2[0], b12 := matrix2[1], b13 := matrix2[2], b21 := matrix2[3], b22 := matrix2[4], b23 := matrix2[5], b31 := matrix2[6], b32 := matrix2[7], b33 := matrix2[8]

        ; [a11*b11 + a12*b21 + a13*b31   a11*b12 + a12*b22 + a13*b32   a11*b13 + a12*b23 + a13*b33]
        ; [a21*b11 + a22*b21 + a23*b31   a21*b12 + a22*b22 + a23*b32   a21*b13 + a22*b23 + a23*b33]
        ; [a31*b11 + a32*b21 + a33*b31   a31*b12 + a32*b22 + a33*b32   a31*b13 + a32*b23 + a33*b33]

        return (this(a11*b11 + a12*b21 + a13*b31, a11*b12 + a12*b22 + a13*b32, a11*b13 + a12*b23 + a13*b33, a21*b11 + a22*b21 + a23*b31, a21*b12 + a22*b22 + a23*b32, a21*b13 + a22*b23 + a23*b33, a31*b11 + a32*b21 + a33*b31, a31*b12 + a32*b22 + a33*b32, a31*b13 + a32*b23 + a33*b33))
    }

    static MultiplyScalar(matrix, scalar) {
        return (this(matrix[0]*scalar, matrix[1]*scalar, matrix[2]*scalar, matrix[3]*scalar, matrix[4]*scalar, matrix[5]*scalar, matrix[6]*scalar, matrix[7]*scalar, matrix[8]*scalar))
    }

    static Determinant(matrix) {
        m21 := matrix[3], m22 := matrix[4], m23 := matrix[5], m31 := matrix[6], m32 := matrix[7], m33 := matrix[8]

        return (matrix[0]*(m22*m33 - m23*m32) - matrix[1]*(m21*m33 - m23*m31) + matrix[2]*(m21*m32 - (m22*m31)))
    }

    ;* Matrix3.RotateX(matrix, theta)
    static RotateX(matrix, theta) {
        c := Cos(theta), s := Sin(theta)
            , m12 := matrix[1], m13 := matrix[2], m22 := matrix[4], m23 := matrix[5], m32 := matrix[7], m33 := matrix[8]

        ;[1      0         0  ]
        ;[0    cos(θ)   sin(θ)]
        ;[0   -sin(θ)   cos(θ)]

        return (this(matrix[0], m12*c + m13*-s, m12*s + m13*c, matrix[3], m22*c + m23*-s, m22*s + m23*c, matrix[6], m32*c + m33*-s, m32*s + m33*c))
    }

    ;* Matrix3.RotateY(matrix, theta)
    static RotateY(matrix, theta) {
        c := Cos(theta), s := Sin(theta)
            , m11 := matrix[0], m13 := matrix[2], m21 := matrix[3], m23 := matrix[5], m31 := matrix[6], m33 := matrix[8]

        ;[cos(θ)   0   -sin(θ)]
        ;[  0      1      0   ]
        ;[sin(θ)   0    cos(θ)]

        return (this(m11*c + m13*s, matrix[1], m11*-s + m13*c, m21*c + m23*s, matrix[4], m21*-s + m23*c, m31*c + m33*s, matrix[7], m31*-s + m33*c))
    }

    ;* Matrix3.RotateZ(matrix, theta)
    static RotateZ(matrix, theta) {
        c := Cos(theta), s := Sin(theta)
            , m11 := matrix[0], m12 := matrix[1], m21 := matrix[3], m22 := matrix[4], m31 := matrix[6], m32 := matrix[7]

        ;[ cos(θ)   sin(θ)   0]
        ;[-sin(θ)   cos(θ)   0]
        ;[    0       0      1]

        return (this(m11*c + m12*-s, m11*s + m12*c, matrix[2], m21*c + m22*-s, m21*s + m22*c, matrix[5], m31*c + m32*-s, m31*s + m32*c, matrix[8]))
    }

    Copy(matrix) {
        switch (Type(matrix)) {
            case "Matrix3":
                return (this.Set(matrix*))
            case "Matrix4":
                return (this.Set(matrix[0], matrix[1], matrix[2], matrix[4], matrix[5], matrix[6], matrix[8], matrix[9], matrix[10]))
        }
    }

    Set(m11, m12, m13, m21, m22, m23, m31, m32, m33) {
        this[0] := m11, this[1] := m12, this[2] := m13, this[3] := m21, this[4] := m22, this[5] := m23, this[6] := m31, this[7] := m32, this[8] := m33

        return (this)
    }

    SetIdentity() {
        return (this.Set(1, 0, 0, 0, 1, 0, 0, 0, 1))
    }

    Multiply(matrix, matrixOrder := 0) {
        if (matrixOrder) {
            a11 := this[0], a12 := this[1], a13 := this[2], a21 := this[3], a22 := this[4], a23 := this[5], a31 := this[6], a32 := this[7], a33 := this[8]
          , b11 := matrix[0], b12 := matrix[1], b13 := matrix[2], b21 := matrix[3], b22 := matrix[4], b23 := matrix[5], b31 := matrix[6], b32 := matrix[7], b33 := matrix[8]
        }
        else {
            a11 := matrix[0], a12 := matrix[1], a13 := matrix[2], a21 := matrix[3], a22 := matrix[4], a23 := matrix[5], a31 := matrix[6], a32 := matrix[7], a33 := matrix[8]
          , b11 := this[0], b12 := this[1], b13 := this[2], b21 := this[3], b22 := this[4], b23 := this[5], b31 := this[6], b32 := this[7], b33 := this[8]
        }

        return (this.Set(a11*b11 + a12*b21 + a13*b31, a11*b12 + a12*b22 + a13*b32, a11*b13 + a12*b23 + a13*b33, a21*b11 + a22*b21 + a23*b31, a21*b12 + a22*b22 + a23*b32, a21*b13 + a22*b23 + a23*b33, a31*b11 + a32*b21 + a33*b31, a31*b12 + a32*b22 + a33*b32, a31*b13 + a32*b23 + a33*b33))
    }

    MultiplyScalar(scalar) {
        this[0] *= scalar, this[3] *= scalar, this[6] *= scalar, this[1] *= scalar, this[4] *= scalar, this[7] *= scalar, this[2] *= scalar, this[5] *= scalar, this[8] *= scalar

        return (this)
    }

    Invert() {
        m11 := this[0], m12 := this[1], m13 := this[2], m21 := this[3], m22 := this[4], m23 := this[5], m31 := this[6], m32 := this[7], m33 := this[8]

        if ((d := m11*(t11 := m33*m22 - m32*m23) + m21*(t12 := m32*m13 - m33*m12) + m31*(t13 := m23*m12 - m22*m13)) == 0) {
            return (False)
        }

        dI := 1/d

        return (this.set(t11*dI, t12*dI, t13*dI, (m31*m23 - m33*m21)*dI, (m33*m11 - m31*m13)*dI, (m21*m13 - m23*m11)*dI, (m32*m21 - m31*m22)*dI, (m31*m12 - m32*m11)*dI, (m22*m11 - m21*m12)*dI))
    }

    RotateX(theta) {
        c := Cos(theta), s := Sin(theta)
            , m12 := this[1], m13 := this[2], m22 := this[4], m23 := this[5], m32 := this[7], m33 := this[8]

        this[1] := m12*c + m13*-s, this[2] := m12*s + m13*c, this[4] := m22*c + m23*-s, this[5] := m22*s + m23*c, this[7] := m32*c + m33*-s, this[8] := m32*s + m33*c

        return (this)
    }

    RotateY(theta) {
        c := Cos(theta), s := Sin(theta)
            , m11 := this[0], m13 := this[2], m21 := this[3], m23 := this[5], m31 := this[6], m33 := this[8]

        this[0] := m11*c + m13*s, this[2] := m11*-s + m13*c, this[3] := m21*c + m23*s, this[5] := m21*-s + m23*c, this[6] := m31*c + m33*s, this[8] := m31*-s + m33*c

        return (this)
    }

    RotateZ(theta) {
        c := Cos(theta), s := Sin(theta)
            , m11 := this[0], m12 := this[1], m21 := this[3], m22 := this[4], m31 := this[6], m32 := this[7]

        this[0] := m11*c + m12*-s, this[1] := m11*s + m12*c, this[3] := m21*c + m22*-s, this[4] := m21*s + m22*c, this[6] := m31*c + m32*-s, this[7] := m31*s + m32*c

        return (this)
    }

    Scale(sx, sy) {
        this[0] *= sx, this[1] *= sx, this[2] *= sx, this[3] *= sy, this[4] *= sy, this[5] *= sy

        return (this)
    }

    Transpose() {
        tmp := this[1], this[1] := this[3], this[3] := tmp, tmp := this[2], this[2] := this[6], this[6] := tmp, tmp := this[5], this[5] := this[6], this[6] := tmp

        return (this)
    }

    Print() {  ;* This only works if you use a monospaced font, otherwise the elements will not be spaced correctly.
        (lengths := this.Reduce((a, c, i, *) => (((l := StrLen(c)) > a[i := Mod(i, 3)]) ? (a[i] := l, a) : (a)), [0, 0, 0])).ForEach((v, i, this) => (this[i] := [v//2, Ceil(v/2)]))

        for index, element in (string := "[", this) {
            if (index ~= "3|6") {
                string .= A_Space
            }

            column := Mod(index, 3), length := StrLen(element)
                , string .= SubStr(((offset := lengths[column][0]) && StrReplace(Format("{:0" . offset . "}", 0), "0", A_Space) || "") . element . StrReplace(Format("{:0" . lengths[column][1] . "}", 0), "0", A_Space), length//2 + 1, -Ceil(length/2))

            if (index != 8) {
                string .=  (index ~= "2|5") ? ("`n") : ("   ")
            }
        }

        return (string . "]")
    }

    ToString() {
        return (this.Print())
    }
}
