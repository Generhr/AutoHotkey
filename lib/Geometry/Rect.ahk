;Class Rect {
;
;   ;------------  Constructor  ----------------------------------------------------;
;
;   ;* new Rect(x, y, width, height)
;   ;* new Rect([Vec2 || Vec3] point, width, height)
;   ;* new Rect([Object] rect)
;   __New(params*) {
;       switch (Class(params[1])) {
;           case "__String": {
;               switch (params.Count()) {
;                   case 4: {
;                       return {"x": params[1], "y": params[2]
;                           , "Width": params[3], "Height": params[4]
;
;                           , "Base": this.__Rect}
;                   }
;                   Default: {
;                       throw (Exception("ArgumentException", -1, "Too many parameters passed to this function."))
;                   }
;               }
;           }
;           case "__Vec2", "__Vec3": {
;               return {"x": params[1].x, "y": params[1].y
;                   , "Width": params[2], "Height": params[3]
;
;                   , "Base": this.__Rect}
;           }
;           case "__Array": {  ;* Array is only included here to support legacy scripts as I don't intend to account for arrays of length 2/4 (`[x, y]` vs `[x, y, width, height]`).
;               return ({"x": params[1][0], "y": params[1][1]
;                   , "Width": params[2], "Height": params[3]
;
;                   , "Base": this.__Rect})
;           }
;           Default: {
;               if ((x := params[1].x) != "" && (y := params[1].y) != "" && (width := params[1].Width) != "" && (height := params[1].Height) != "") {
;                   return {"x": x, "y": y
;                       , "Width": width, "Height": height
;
;                       , "Base": this.__Rect}
;               }
;
;               throw (Exception("ArgumentException", -1, Format("{} is invalid. This object must be constructed from type:`n`tInteger, Array, Object, Vec2, Vec3 or Rect.", Class(x))))
;           }
;       }
;   }
;
;   IsIntersect(rect1, rect2) {
;       x1 := rect1.x, y1 := rect1.y
;           , x2 := rect2.x, y2 := rect2.y
;
;       return (!(x2 > rect1.Width + x1 || x1 > rect2.Width + x2 || y2 > rect1.Height + y1 || y1 > rect2.Height + y2))
;   }
;
;   Scale(rectangle1, rectangle2) {
;       r1 := rectangle2.Width/rectangle1.Width, r2 := rectangle2.Height/rectangle1.Height
;
;       if (r1 > r2) {
;           h := rectangle2.Height//r1
;
;           return (new Rect(0, (rectangle1.Height - h)//2, rectangle1.Width, h))
;       }
;       else {
;           w := rectangle2.Width//r2
;
;           return (new Rect((rectangle1.Width - w)//2, 0, 2, rectangle1.Height))
;       }
;   }
;
;   Class __Rect extends Vec2.__Vec2 {
;
;       IsIntersect(rect) {
;           Local
;
;           x1 := this.x, y1 := this.y
;               , x2 := rect.x, y2 := rect.y
;
;           return (!(x1 > rect.Width + x2 || x2 > this.Width + x1 || y1 > rect.Height + y2 || y2 > this.Height + y1))
;       }
;
;       Clone() {
;           return (new Rect(this.x, this.y, this.Width, this.Height))
;       }
;   }
;}
