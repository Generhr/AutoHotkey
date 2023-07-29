#Requires AutoHotkey v2.0-beta.6

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

class Timer {
  static Instances := Map()

  __New(callback, interval?, priority := 0) {
    this.Callback := callback, this.Interval := -1, this.Priority := priority
      , this.State := 0

    pointer := ObjPtr(this)

    Timer.Instances[pointer] := this, ObjRelease(pointer)  ;* Decrease this object's reference count to allow `__Delete()` to be triggered while still keeping a copy in `Timer.Instances`.

    if (IsSet(interval)) {
      this.Start(interval)
    }
  }

  __Delete() {
    if (this.State) {
      SetTimer(this.Callback, 0)
    }

    pointer := ObjPtr(this)

    ObjAddRef(pointer), Timer.Instances.Delete(pointer)  ;* Increase this object's reference count before deleting the copy stored in `Timer.Instances` to avoid crashing the calling script.
  }

  static StartAll(interval?) {
    for pointer, instance in this.Instances {
      instance.Start(interval?)
    }
  }

  static StopAll() {
    for pointer, instance in this.Instances {
      instance.Stop()
    }
  }

  Start(interval?) {
    if (IsSet(interval)) {
      this.Interval := interval
    }
    else {
      interval := this.Interval
    }

    this.State := 1

    SetTimer(this.Callback, interval, this.Priority)
  }

  Stop() {
    if (this.State) {
      this.State := 0

      SetTimer(this.Callback, 0)
    }
  }
}
