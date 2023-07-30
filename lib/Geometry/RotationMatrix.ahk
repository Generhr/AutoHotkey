;/*
;** Euler Angle Formulas: https://www.geometrictools.com/Documentation/EulerAngles.pdf. **
;*/

RotationMatrixFromUnitVector(object, theta) {  ;: https://www.euclideanspace.com/maths/algebra/matrix/orthogonal/rotation/index.htm
;       1 + (1-cos(angle))*(x*x-1)     -z*sin(angle)+(1-cos(angle))*x*y    y*sin(angle)+(1-cos(angle))*x*z
;    z*sin(angle)+(1-cos(angle))*x*y       1 + (1-cos(angle))*(y*y-1)     -x*sin(angle)+(1-cos(angle))*y*z
;   -y*sin(angle)+(1-cos(angle))*x*z    x*sin(angle)+(1-cos(angle))*y*z      1 + (1-cos(angle))*(z*z-1)
}

class RotationMatrix extends Array {
    __New(roll, pitch, yaw) {  ;* ψ, θ, ϕ
;       axis := []

;       if (IsSet(ψ)) {
;           c := Cos(ψ), s := Sin(ψ)
;
;           ; [1     0          0  ]
;           ; [0   cos(ψ)   -sin(ψ)]
;           ; [0   sin(ψ)    cos(ψ)]
;
;           axis.Push([1, 0, 0, 0, c, -s, 0, s, c])
;       }
;
;       if (IsSet(θ)) {
;           c := Cos(θ), s := Sin(θ)
;
;           ; [ cos(θ)   0   sin(θ)]
;           ; [   0      1     0   ]
;           ; [-sin(θ)   0   cos(θ)]
;
;           axis.Push([c, 0, s, 0, 1, 0, -s, 0, c])
;       }
;
;       if (IsSet(ϕ)) {
;           c := Cos(ϕ), s := Sin(ϕ)
;
;           ; [cos(ϕ)   -sin(ϕ)   0]
;           ; [sin(ϕ)    cos(ϕ)   0]
;           ; [    0       0      1]
;
;           axis.Push([c, -s, 0, s, c, 0, 0, 0, 1])
;       }

        cu := Cos(yaw), su := Sin(yaw)
      , cv := Cos(pitch), sv := Sin(pitch)
      , cw := Cos(roll), sw := Sin(roll)

        ; [1     0          0  ] [ cos(θ)   0   sin(θ)] [cos(ϕ)   -sin(ϕ)   0]   [ cos(θ)   sin(ψ)*sin(θ)   cos(ψ)*sin(θ)] [cos(ϕ)   -sin(ϕ)   0]   [cos(θ)*cos(ϕ)   sin(ψ)*sin(θ)*cos(ϕ) - cos(ψ)*sin(ϕ)   cos(ψ)*sin(θ)*cos(ϕ) + sin(ψ)*sin(ϕ)]
        ; [0   cos(ψ)   -sin(ψ)]*[   0      1     0   ]*[sin(ϕ)    cos(ϕ)   0] = [   0          cos(ψ)         −sin(ψ)   ]*[sin(ϕ)    cos(ϕ)   0] = [cos(θ)*sin(ϕ)   sin(ψ)*sin(θ)*sin(ϕ) + cos(ψ)*cos(ϕ)   cos(ψ)*sin(θ)*sin(ϕ) - sin(ψ)*cos(ϕ)]
        ; [0   sin(ψ)    cos(ψ)] [-sin(θ)   0   cos(θ)] [    0       0      1]   [−sin(θ)   sin(ψ)*cos(θ)   cos(ψ)*cos(θ)] [    0       0      1]   [  -sin(θ)                  sin(ψ)*cos(θ)                            cos(ψ)*cos(θ)          ]

        this.Push(cv*cu, sw*sv*cu - cw*su, cw*sv*cu + sw*su, cv*su, sw*sv*su + cw*cu, cw*sv*su - sw*cu, -sv, sw*cv, cw*cv)
    }

    Roll {  ;* x-axis (ψ)
        Get {
            return (DllCall("msvcrt\atan2", "Double", this[7], "Double", this[8], "Double"))
        }
    }

    Pitch {  ;* y-axis (θ)
        Get {
            return (DllCall("msvcrt\atan2", "Double", -this[6], "Double", Sqrt(this[7]**2 + this[8]**2), "Double"))  ;! return (DllCall("msvcrt\asin", "Double", this[6], "Double"))
        }
    }

    Yaw {  ;* z-axis (ϕ)
        Get {
            return (DllCall("msvcrt\atan2", "Double", this[3], "Double", this[0], "Double"))
        }
    }

;   Print() {
;       length := this.Reduce((accumulator, currentValue, *) => (Max(accumulator, StrLen(currentValue))), 0)
;           , left := StrReplace(Format("{:0" . length//2 . "}", 0), "0", A_Space), right := StrReplace(Format("{:0" . Ceil(length/2) . "}", 0), "0", A_Space)
;
;       for i, v in (r := "[", this) {
;           offset := Ceil(StrLen(v)/2) + 1, subtract := (i ~= "2|5|8") ? (length//2 - StrLen(v)//2) : (0)
;               , sign := !!(SubStr(v, 1, 1) == "-")
;
;           if (i != 0) {
;               r .= "|"
;           }
;
;           r .= SubStr(left . v . right, offset + sign, length - subtract)
;
;           if (i != 8) {
;               r .=  (i ~= "2|5") ? ("`n") : ("   ")
;           }
;       }
;       return (r . "]")
;   }
}
