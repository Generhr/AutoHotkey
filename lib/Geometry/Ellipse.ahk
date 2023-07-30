;Class Ellipse {
;
;   ;------------  Constructor  ----------------------------------------------------;
;
;   ;* new Ellipse(x, y, radius)
;   ;* new Ellipse(x, y, width, height)
;   ;* new Ellipse([Vec2 || Vec3 || Array] point, radius)
;   ;* new Ellipse([Vec2 || Vec3 || Array] point, width, height)
;   __New(params*) {
;       Local
;
;       switch (Class(params[1])) {
;           case "__String": {
;               switch (params.Count()) {
;                   case 4: {
;                       width := params[3], height := params[4]
;                           , r1 := (width < 1 && width > 0 && height >= 1) ? ((height/2)*Sqrt(1 - width**2)) : (width/2), r2 := (height < 1 && height > 0 && width >= 1) ? ((width/2)*Sqrt(1 - height**2)) : (height/2)
;
;                       if (r1 == r2) {
;                           return ({"x": params[1], "y": params[2]
;                               , "__Radius": r1
;
;                               , "Base": this.__Circle})
;                       }
;
;                       return ({"x": params[1], "y": params[2]
;                           , "__Radius": [r1, r2]
;
;                           , "Base": this.__Ellipse})
;                   }
;                   case 3: {
;                       return {"x": params[1], "y": params[2]
;                           , "__Radius": params[3]
;
;                           , "Base": this.__Circle}
;                   }
;                   Default: {
;                       throw (Exception("ArgumentException", -1, "Too many parameters passed to this function."))
;                   }
;               }
;           }
;           case "__Vec2", "__Vec3": {
;               switch (params.Count()) {
;                   case 3: {
;                       width := params[2], height := params[3]
;                           , r1 := (width < 1 && width > 0 && height >= 1) ? ((height/2)*Sqrt(1 - width**2)) : (width/2), r2 := (height < 1 && height > 0 && width >= 1) ? ((width/2)*Sqrt(1 - height**2)) : (height/2)
;
;                       if (r1 == r2) {
;                           return ({"x": params[1].x, "y": params[1].y
;                               , "__Radius": r1
;
;                               , "Base": this.__Circle})
;                       }
;
;                       return ({"x": params[1].x, "y": params[1].y
;                           , "__Radius": [r1, r2]
;
;                           , "Base": this.__Ellipse})
;                   }
;                   case 2: {
;                       return {"x": params[1].x, "y": params[1].y
;                           , "__Radius": params[2]
;
;                           , "Base": this.__Circle}
;                   }
;                   Default: {
;                       throw (Exception("ArgumentException", -1, "Too many parameters passed to this function."))
;                   }
;               }
;           }
;           case "__Array": {
;               switch (params.Count()) {
;                   case 3: {
;                       width := params[2], height := params[3]
;                           , r1 := (width < 1 && width > 0 && height >= 1) ? ((height/2)*Sqrt(1 - width**2)) : (width/2), r2 := (height < 1 && height > 0 && width >= 1) ? ((width/2)*Sqrt(1 - height**2)) : (height/2)
;
;                       if (r1 == r2) {
;                           return ({"x": params[1][0], "y": params[1][1]
;                               , "__Radius": r1
;
;                               , "Base": this.__Circle})
;                       }
;
;                       return ({"x": params[1][0], "y": params[1][1]
;                           , "__Radius": [r1, r2]
;
;                           , "Base": this.__Ellipse})
;                   }
;                   case 2: {
;                       return {"x": params[1][0], "y": params[1][1]
;                           , "__Radius": params[2]
;
;                           , "Base": this.__Circle}
;                   }
;                   Default: {
;                       throw (Exception("ArgumentException", -1, "Too many parameters passed to this function."))
;                   }
;               }
;           }
;           Default: {
;               if ((x := params[1].x) != "" && (y := params[1].y) != "") {
;                   if ((width := params[1].Width) != "" && (height := params[1].Height) != "") {
;                       r1 := (width < 1 && width > 0 && height >= 1) ? ((height/2)*Sqrt(1 - width**2)) : (width/2), r2 := (height < 1 && height > 0 && width >= 1) ? ((width/2)*Sqrt(1 - height**2)) : (height/2)
;
;                       if (r1 == r2) {
;                           return ({"x": x, "y": y
;                               , "__Radius": r1
;
;                               , "Base": this.__Circle})
;                       }
;
;                       return ({"x": x, "y": y
;                           , "__Radius": [r1, r2]
;
;                           , "Base": this.__Ellipse})
;                   }
;                   else if ((radius := params[1].Radius) != "") {
;                       return {"x": x, "y": y
;                           , "__Radius": radius
;
;                           , "Base": this.__Circle}
;                   }
;               }
;
;               throw (Exception("ArgumentException", -1, Format("{} is invalid. This object must be constructed from type:`n`tInteger, Float, Array, Vec2, Vec3 or Rect.", Class(x))))
;           }
;       }
;   }
;
;   ;--------------- Method -------------------------------------------------------;
;
;   IsIntersectCircle(circle1, circle2) {
;       return ((circle1.x - circle2.x)**2 + (circle1.y - circle2.y)**2 <= (circle1.Radius + circle2.Radius)**2)
;   }
;
;   ;* Note:
;       ;* To determine radius given n: `radius := (ellipse.Radius/(Math.Sin(Math.Pi/n) + 1))*Math.Sin(Math.Pi/n)`.
;   InscribeEllipse(ellipse, radius, theta := 0, offset := 0) {
;       c := ellipse.h + (ellipse.Radius - radius - offset)*Math.Cos(theta), s := ellipse.k + (ellipse.Radius - radius - offset)*Math.Sin(theta)
;
;       return (new Ellipse(c - radius, s - radius, radius*2, radius*2))
;   }
;
;   ;------------ Nested Class ----------------------------------------------------;
;
;   Class __Circle extends Vec2.__Vec2 {
;
;       Width[] {
;           Get {
;               return (this.__Radius*2)
;           }
;       }
;
;       Height[] {
;           Get {
;               return (this.__Radius*2)
;           }
;       }
;
;       h[] {
;           Get {
;               return (this.x + this.__Radius)
;           }
;
;           Set {
;               ObjRawSet(this, "x", value - this.__Radius)
;
;               return (value)
;           }
;       }
;
;       k[] {
;           Get {
;               return (this.y + this.__Radius)
;           }
;
;           Set {
;               ObjRawSet(this, "y", value - this.__Radius)
;
;               return (value)
;           }
;       }
;
;       Radius[] {
;           Get {
;               return (this.__Radius)
;           }
;
;           Set {
;               switch (Class(value)) {
;                   case "__String": {
;                       ObjRawSet(this, "__Radius", value)
;                   }
;                   case "__Object": {
;                       ObjRawSet(this, "__Radius", [value.a, value.b]), ObjSetBase(this, Ellipse.__Ellipse)
;                   }
;                   Default: {
;                       throw (Exception("ArgumentException", -1, "Incorrect type."))
;                   }
;               }
;
;               return (value)
;           }
;       }
;
;       Diameter[] {
;           Get {
;               return (this.__Radius*2)
;           }
;       }
;
;       Eccentricity[] {
;           Get {
;               return (0)
;           }
;       }
;
;       FocalLength[] {
;           Get {
;               return (0)
;           }
;       }
;
;       Apoapsis[] {
;           Get {
;               return (this.__Radius)
;           }
;       }
;
;       Periapsis[] {
;           Get {
;               return (this.__Radius)
;           }
;       }
;
;       SemiMajorAxis[] {
;           Get {
;               return (this.__Radius)
;           }
;       }
;
;       SemiMinorAxis[] {
;           Get {
;               return (this.__Radius)
;           }
;       }
;
;       SemiLatusRectum[] {
;           Get {
;               return (0)
;           }
;       }
;
;       Area[] {
;           Get {
;               return (this.__Radius**2*Math.Pi)
;           }
;       }
;
;       Circumference[] {
;           Get {
;               return (this.__Radius*Math.Tau)
;           }
;       }
;   }
;
;   Class __Ellipse extends Vec2.__Vec2 {
;
;       Width[] {
;           Get {
;               return (this.__Radius[0]*2)
;           }
;       }
;
;       Height[] {
;           Get {
;               return (this.__Radius[1]*2)
;           }
;       }
;
;       h[] {
;           Get {
;               return (this.x + this.__Radius[0])
;           }
;
;           Set {
;               ObjRawSet(this, "x", value - this.__Radius[0])
;
;               return (value)
;           }
;       }
;
;       k[] {
;           Get {
;               return (this.y + this.__Radius[1])
;           }
;
;           Set {
;               ObjRawSet(this, "y", value - this.__Radius[1])
;
;               return (value)
;           }
;       }
;
;       Radius[] {
;           Get {
;               return ({"a": this.__Radius[0], "b": this.__Radius[1]})
;           }
;
;           Set {
;               switch (Class(value)) {
;                   case "__String": {
;                       ObjRawSet(this, "__Radius", value), ObjSetBase(this, Ellipse.__Circle)
;                   }
;                   case "__Object": {
;                       ObjRawSet(this, "__Radius", [value.a, value.b])
;                   }
;                   Default: {
;                       throw (Exception("ArgumentException", -1, "Incorrect type."))
;                   }
;               }
;
;               return (value)
;           }
;       }
;
;       Diameter[] {
;           Get {
;               return ({"a": this.__Radius[0]*2, "b": this.__Radius[1]*2})
;           }
;       }
;
;       Eccentricity[] {
;           Get {
;               return (this.FocalLength/this.SemiMajorAxis)
;           }
;       }
;
;       FocalLength[] {
;           Get {
;               return (Sqrt(this.SemiMajorAxis**2 - this.SemiMinorAxis**2))
;           }
;       }
;
;       Apoapsis[] {
;           Get {
;               return (this.SemiMajorAxis*(1 + this.Eccentricity))
;           }
;       }
;
;       Periapsis[] {
;           Get {
;               return (this.SemiMajorAxis*(1 - this.Eccentricity))
;           }
;       }
;
;       SemiMajorAxis[] {
;           Get {
;               return (Max(this.__Radius[0], this.__Radius[1]))
;           }
;       }
;
;       SemiMinorAxis[] {
;           Get {
;               return (Min(this.__Radius[0], this.__Radius[1]))
;           }
;       }
;
;       SemiLatusRectum[] {
;           Get {
;               return (this.SemiMajorAxis*(1 - this.Eccentricity**2))
;           }
;       }
;
;       Area[] {
;           Get {
;               return (this.__Radius[0]*this.__Radius[1]*Math.Pi)
;           }
;       }
;
;       Circumference[] {
;           Get {
;               return ((3*(this.__Radius[0] + this.__Radius[1]) - Sqrt((3*this.__Radius[0] + this.__Radius[1])*(this.__Radius[0] + 3*this.__Radius[1])))*Math.Pi)  ;* Approximation by Srinivasa Ramanujan.
;           }
;       }
;   }
;}
