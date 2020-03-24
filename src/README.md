# Window.ahk
Monitors which window is active and performs 3 functions:
            
1. Suspend any scripts that it is baby sitting if a window in the "Suspend" becomes active.
2. Reloads any scripts that it is baby sitting if that script was editted.
3. Forces any window in Settings.ini to maintain it's x, y, width and height (unless it is maximized or Ctrl is held).

Setup:
1. For any scripts that you want Window.ahk to babysit, they must have the following code in them:
```　
    OnMessage(0xFF, "StatusReport")
    
    StatusReport() {
        Return, (A_IsSuspended)
    }
```
   and in your Settings.ini:
```
    [Scripts]
    Scripts="Script1.ahk|Script2.ahk|...|ScriptN.ahk"
```
2. Your Settings.ini file must include a section titled "[Window Positions]". For example:
```
    [Window Positions]
    7zFM.exe=-7, 730, 894, 357
    Calculator.exe=-7, 0, 336, 541
    Camera.exe=-7, 0, 871, 541
    Code.exe=-1, 0, 825, 1080
    Discord.exe=-1, 0, 940, 1080
    Explorer.EXE=-7, 730, 894, 357
    hh.exe=-7, 730, 894, 357
    notepad++.exe=1549, 0, 377, 1087
```
3. Any exceptions to the windows declared in Settings.ini must be coded at line 68.
