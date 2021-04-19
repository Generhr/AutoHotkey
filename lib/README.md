# ObjectOriented.ahk
Warning for this lib:

Arrays are adjusted to start at 0 but because variadic arrays have no base class, they remain at 1 which is very inconsistent and also breaks `[1, 2, 3]*`.
