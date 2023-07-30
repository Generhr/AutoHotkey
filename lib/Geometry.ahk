#Requires AutoHotkey v2.0-beta

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

;============ Auto-execute ====================================================;
;======================================================  Include  ==============;

#Include ..\lib\Math\Math.ahk

;===============  Class  =======================================================;

Class Point {

    ;--------------- Method -------------------------------------------------------;
    ;-------------------------            General           -----;

    ;* Point.Angle(point1 [Point], point2 [Point])
    ;* Description:
        ;* Calculate the angle from `point1` to `point2`.
    Angle(point1, point2) {
        x := -Math.ATan2(point2.y - point1.y, point2.x - point1.x)

        return ((x < 0) ? (-x) : (Math.Tau - x))
    }

    ;* Point.Distance(point1 [Point], point2 [Point])
    Distance(point1, point2) {
        return (Sqrt((point2.x - point1.x)**2 + (point2.y - point1.y)**2))
    }

    ;* Point.Equals(point1 [Point], point2 [Point])
    Equals(point1, point2) {
        return (point1.x == point2.x && point1.y == point2.y)
    }

    ;* Point.Slope(point1 [Point], point2 [Point])
    ;* Note:
        ;* Two lines are parallel if their slopes are the same.
        ;* Two lines are perpendicular if their slopes are negative reciprocals of each other.
    Slope(point1, point2) {
        return ((point2.y - point1.y)/(point2.x - point1.x))
    }

    ;* Point.MidPoint(point1 [Point], point2 [Point])
    MidPoint(point1, point2) {
        return (super((point1.x + point2.x)/2, (point1.y + point2.y)/2))
    }

    ;* Point.Rotate(point1 [Point], point2 [Point], theta [Radians])
    ;* Description:
        ;* Calculate the coordinates of `point1` rotated around `point2`.
    Rotate(point1, point2, theta) {
        c := Cos(theta), s := Sin(theta)
            , x := point1.x - point2.x, y := point1.y - point2.y

        return (super(x*c - y*s + point2.x, x*s + y*c + point2.y))
    }

    ;-------------------------           Triangle           -----;  ;* ** https://hratliff.com/files/curvature_calculations_and_circle_fitting.pdf || https://www.onlinemath4all.com/circumcenter-of-a-triangle.html **

    ;* Point.Circumcenter(point1 [Point], point2 [Point], point3 [Point])
    ;* Description:
        ;* Calculate the circumcenter for three 2D points.
    Circumcenter(point1, point2, point3) {
        x1 := point1.x, y1 := point1.y, x2 := point2.x, y2 := point2.y, x3 := point3.x, y3 := point3.y
            , a := 0.5*((x2 - x1)*(y3 - y2) - (y2 - y1)*(x3 - x2))

        if (a != 0) {
            x := (((y3 - y1)*(y2 - y1)*(y3 - y2)) - ((x2**2 - x1**2)*(y3 - y2)) + ((x3**2 - x2**2)*(y2 - y1)))/(-4*a), y := (-1*(x2 - x1)/(y2 - y1))*(x - 0.5*(x1 + x2)) + 0.5*(y1 + y2)

            return (super(x, y))
        }

        MsgBox("Failed: points are either collinear or not distinct")
    }

    ;* Point.Circumradius(point1 [Point], point2 [Point], point3 [Point])
    ;* Description:
        ;* Calculate the circumradius for three 2D points.
    Circumradius(point1, point2, point3) {
        x1 := point1.x, y1 := point1.y, x2 := point2.x, y2 := point2.y, x3 := point3.x, y3 := point3.y
            , d := 2*((x2 - x1)*(y3 - y2) - (y2 - y1)*(x3 - x2))

        if (d != 0) {
            n := ((((x2 - x1)**2) + ((y2 - y1)**2))*((( x3 - x2)**2) + ((y3 - y2)**2))*(((x1 - x3)**2) + ((y1 - y3)**2)))**(0.5)

            return (Abs(n/d))
        }

        MsgBox("Failed: points are either collinear or not distinct")
    }

    ;-------------------------            Ellipse           -----;

    ;* Point.Foci(EllipseObject)
    Foci(ellipse) {
        f := ellipse.FocalLength
            , o1 := (ellipse.Radius.a > ellipse.Radius.b)*f, o2 := (ellipse.Radius.a < ellipse.Radius.b)*f

        return ([super(ellipse.h - o1, ellipse.k - o2), super(ellipse.h + o1, ellipse.k + o2)])
    }

    ;* Point.Epicycloid(EllipseObject1, EllipseObject2, (theta [Radians]))   ;*** Bad reference (oEllipse). Check formula
    Epicycloid(ellipse1, ellipse2, theta := 0) {
        return (super(ellipse1.h + (ellipse1.Radius + ellipse2.Radius)*Math.Cos(theta) - ellipse2.Radius*Math.Cos((ellipse1.Radius/ellipse2.Radius + 1)*theta), oEllipse.k - o[2], ellipse1.k + (ellipse1.Radius + ellipse2.Radius)*Math.Sin(theta) - ellipse2.Radius*Math.Sin((ellipse1.Radius/ellipse2.Radius + 1)*theta)))
    }

    ;* Point.Hypocycloid([EllipseObject1, EllipseObject2], (theta [Radians]))
    Hypocycloid(ellipse1, ellipse2, theta := 0) {
        return (super(ellipse1.h + (ellipse1.Radius - ellipse2.Radius)*Math.Cos(theta) + ellipse2.Radius*Math.Cos((ellipse1.Radius/ellipse2.Radius - 1)*theta), ellipse1.k + (ellipse1.Radius - ellipse2.Radius)*Math.Sin(theta) - ellipse2.Radius*Math.Sin((ellipse1.Radius/ellipse2.Radius - 1)*theta)))
    }

    ;* Point.OnEllipse(EllipseObject, (theta [Radians]))
    ;* Description:
        ;* Calculate the coordinates of a point on the circumference of an ellipse.
    OnEllipse(ellipse, theta := 0) {
        if (IsObject(ellipse.Radius)) {
            t := Math.Tan(theta), o := [ellipse.Radius.a*ellipse.Radius.b, Sqrt(ellipse.Radius.b**2 + ellipse.Radius.theta**2*t**2)], s := (90 < theta && theta <= 270) ? (-1) : (1)

            return (super(ellipse.h + (o[0]/o[1])*s, ellipse.k + ((o[0]*t)/o[1])*s))
        }
        return (super(ellipse.h + ellipse.Radius*Math.Cos(theta), ellipse.k + ellipse.Radius*Math.Sin(theta)))
    }
}

PointOnEllipse(h, k, radius, theta) {
    return (Vec2(h + radius*Math.Cos(theta), k + radius*Math.Sin(theta)))
}

;------------------------------------------------------- Vector ---------------;

#Include *i ..\lib\Geometry\Vec2.ahk
#Include *i ..\lib\Geometry\Vec3.ahk
#Include *i ..\lib\Geometry\Vec4.ahk

;------------------------------------------------------- Matrix ---------------;

#Include *i ..\lib\Geometry\Matrix3.ahk
#Include *i ..\lib\Geometry\RotationMatrix.ahk
#Include *i ..\lib\Geometry\TransformMatrix.ahk

;-------------------------------------------------------  Shape  ---------------;

#Include *i ..\lib\Geometry\Ellipse.ahk
#Include *i ..\lib\Geometry\Rect.ahk
