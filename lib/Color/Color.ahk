#Requires AutoHotkey v2.0.0

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

#DllLoad "Shlwapi"

class Color {  ;: https://docs.microsoft.com/en-us/dotnet/api/system.windows.media.colors?redirectedfrom=MSDN&view=netframework-4.8

    __New(params*) {
        throw (TargetError("This class may not be constructed.", -1))
    }

    static Call(alpha, name?) {
        static colors := Map("AliceBlue", 0xF0F8FF, "AntiqueWhite", 0xFAEBD7, "Aqua", 0x00FFFF, "Aquamarine", 0x7FFFD4, "Azure", 0xF0FFFF, "Beige", 0xF5F5DC, "Bisque", 0xFFE4C4, "Black", 0x000000, "BlanchedAlmond", 0xFFEBCD, "Blue", 0x0000FF, "BlueViolet", 0x8A2BE2, "Brown", 0xA52A2A, "BurlyWood", 0xDEB887, "CadetBlue", 0x5F9EA0, "Chartreuse", 0x7FFF00, "Chocolate", 0xD2691E, "Coral", 0xFF7F50, "CornflowerBlue", 0x6495ED, "Cornsilk", 0xFFF8DC, "Crimson", 0xDC143C, "Cyan", 0x00FFFF, "DarkBlue", 0x00008B, "DarkCyan", 0x008B8B, "DarkGoldenrod", 0xB8860B, "DarkGray", 0xA9A9A9, "DarkGreen", 0x006400, "DarkKhaki", 0xBDB76B, "DarkMagenta", 0x8B008B, "DarkOliveGreen", 0x556B2F, "DarkOrange", 0xFF8C00, "DarkOrchid", 0x9932CC, "DarkRed", 0x8B0000, "DarkSalmon", 0xE9967A, "DarkSeaGreen", 0x8FBC8F, "DarkSlateBlue", 0x483D8B, "DarkSlateGray", 0x2F4F4F, "DarkTurquoise", 0x00CED1, "DarkViolet", 0x9400D3, "DeepPink", 0xFF1493, "DeepSkyBlue", 0x00BFFF, "DimGray", 0x696969, "DodgerBlue", 0x1E90FF, "Firebrick", 0xB22222, "FloralWhite", 0xFFFAF0, "ForestGreen", 0x228B22, "Fuchsia", 0xFF00FF, "Gainsboro", 0xDCDCDC, "GhostWhite", 0xF8F8FF, "Gold", 0xFFD700, "Goldenrod", 0xDAA520, "Gray", 0x808080, "Green", 0x008000, "GreenYellow", 0xADFF2F, "Honeydew", 0xF0FFF0, "HotPink", 0xFF69B4, "IndianRed", 0xCD5C5C, "Indigo", 0x4B0082, "Ivory", 0xFFFFF0, "Khaki", 0xF0E68C, "Lavender", 0xE6E6FA, "LavenderBlush", 0xFFF0F5, "LawnGreen", 0x7CFC00, "LemonChiffon", 0xFFFACD, "LightBlue", 0xADD8E6, "LightCoral", 0xF08080, "LightCyan", 0xE0FFFF, "LightGoldenrodYellow", 0xFAFAD2, "LightGray", 0xD3D3D3, "LightGreen", 0x90EE90, "LightPink", 0xFFB6C1, "LightSalmon", 0xFFA07A, "LightSeaGreen", 0x20B2AA, "LightSkyBlue", 0x87CEFA, "LightSlateGray", 0x778899, "LightSteelBlue", 0xB0C4DE, "LightYellow", 0xFFFFE0, "Lime", 0x00FF00, "LimeGreen", 0x32CD32, "Linen", 0xFAF0E6, "Magenta", 0xFF00FF, "Maroon", 0x800000, "MediumAquamarine", 0x66CDAA, "MediumBlue", 0x0000CD, "MediumOrchid", 0xBA55D3, "MediumPurple", 0x9370DB, "MediumSeaGreen", 0x3CB371, "MediumSlateBlue", 0x7B68EE, "MediumSpringGreen", 0x00FA9A, "MediumTurquoise", 0x48D1CC, "MediumVioletRed", 0xC71585, "MidnightBlue", 0x191970, "MintCream", 0xF5FFFA, "MistyRose", 0xFFE4E1, "Moccasin", 0xFFE4B5, "NavajoWhite", 0xFFDEAD, "Navy", 0x000080, "OldLace", 0xFDF5E6, "Olive", 0x808000, "OliveDrab", 0x6B8E23, "Orange", 0xFFA500, "OrangeRed", 0xFF4500, "Orchid", 0xDA70D6, "PaleGoldenrod", 0xEEE8AA, "PaleGreen", 0x98FB98, "PaleTurquoise", 0xAFEEEE, "PaleVioletRed", 0xDB7093, "PapayaWhip", 0xFFEFD5, "PeachPuff", 0xFFDAB9, "Peru", 0xCD853F, "Pink", 0xFFC0CB, "Plum", 0xDDA0DD, "PowderBlue", 0xB0E0E6, "Purple", 0x800080, "Red", 0xFF0000, "RosyBrown", 0xBC8F8F, "RoyalBlue", 0x4169E1, "SaddleBrown", 0x8B4513, "Salmon", 0xFA8072, "SandyBrown", 0xF4A460, "SeaGreen", 0x2E8B57, "SeaShell", 0xFFF5EE, "Sienna", 0xA0522D, "Silver", 0xC0C0C0, "SkyBlue", 0x87CEEB, "SlateBlue", 0x6A5ACD, "SlateGray", 0x708090, "Snow", 0xFFFAFA, "SpringGreen", 0x00FF7F, "SteelBlue", 0x4682B4, "Tan", 0xD2B48C, "Teal", 0x008080, "Thistle", 0xD8BFD8, "Tomato", 0xFF6347, "Turquoise", 0x40E0D0, "Violet", 0xEE82EE, "Wheat", 0xF5DEB3, "White", 0xFFFFFF, "WhiteSmoke", 0xF5F5F5, "Yellow", 0xFFFF00, "YellowGreen", 0x9ACD32)

        if (!IsSet(name)) {
            name := alpha, alpha := 0xFF
        }

        return (alpha << 24 | colors[name])
    }

    ;* Color.ToHLS(rgb)
    static ToHLS(rgb) {
        DllCall("Shlwapi\ColorRGBToHLS", "UInt", (rgb & 0xFF0000) >> 16 | rgb & 0xFF00 | (rgb & 0xFF) << 16, "UShort*", &(hue := 0), "UShort*", &(luminosity := 0), "UShort*", &(saturation := 0))  ;: https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-colorrgbtohls

        return ([hue*1.5, luminosity/240, saturation/240])
    }

    ;* Color.ToRGB(hue[, luminosity, saturation])
    static ToRGB(hue, luminosity := 1, saturation := .5) {
        color := DllCall("Shlwapi\ColorHLSToRGB", "UShort", hue*240, "UShort", __Clamp(saturation, 0.0, 1.0)*240, "UShort", __Clamp(saturation, 0.0, 1.0)*240)  ;: https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-colorhlstorgb

        __Clamp(number, lower, upper) {
            return (((number := (number < lower) ? (lower) : (number)) > upper) ? (upper) : (number))
        }

        return (Format("0x{:08X}", 255 << 24 | (color & 0xFF0000) >> 16 | color & 0xFF00 | (color & 0xFF) << 16))
    }

    ;* Color.Random([alpha])
    static Random(alpha := 0xFF) {
        static colors := [0xF0F8FF, 0xFAEBD7, 0x00FFFF, 0x7FFFD4, 0xF0FFFF, 0xF5F5DC, 0xFFE4C4, 0x000000, 0xFFEBCD, 0x0000FF, 0x8A2BE2, 0xA52A2A, 0xDEB887, 0x5F9EA0, 0x7FFF00, 0xD2691E, 0xFF7F50, 0x6495ED, 0xFFF8DC, 0xDC143C, 0x00FFFF, 0x00008B, 0x008B8B, 0xB8860B, 0xA9A9A9, 0x006400, 0xBDB76B, 0x8B008B, 0x556B2F, 0xFF8C00, 0x9932CC, 0x8B0000, 0xE9967A, 0x8FBC8F, 0x483D8B, 0x2F4F4F, 0x00CED1, 0x9400D3, 0xFF1493, 0x00BFFF, 0x696969, 0x1E90FF, 0xB22222, 0xFFFAF0, 0x228B22, 0xFF00FF, 0xDCDCDC, 0xF8F8FF, 0xFFD700, 0xDAA520, 0x808080, 0x008000, 0xADFF2F, 0xF0FFF0, 0xFF69B4, 0xCD5C5C, 0x4B0082, 0xFFFFF0, 0xF0E68C, 0xE6E6FA, 0xFFF0F5, 0x7CFC00, 0xFFFACD, 0xADD8E6, 0xF08080, 0xE0FFFF, 0xFAFAD2, 0xD3D3D3, 0x90EE90, 0xFFB6C1, 0xFFA07A, 0x20B2AA, 0x87CEFA, 0x778899, 0xB0C4DE, 0xFFFFE0, 0x00FF00, 0x32CD32, 0xFAF0E6, 0xFF00FF, 0x800000, 0x66CDAA, 0x0000CD, 0xBA55D3, 0x9370DB, 0x3CB371, 0x7B68EE, 0x00FA9A, 0x48D1CC, 0xC71585, 0x191970, 0xF5FFFA, 0xFFE4E1, 0xFFE4B5, 0xFFDEAD, 0x000080, 0xFDF5E6, 0x808000, 0x6B8E23, 0xFFA500, 0xFF4500, 0xDA70D6, 0xEEE8AA, 0x98FB98, 0xAFEEEE, 0xDB7093, 0xFFEFD5, 0xFFDAB9, 0xCD853F, 0xFFC0CB, 0xDDA0DD, 0xB0E0E6, 0x800080, 0xFF0000, 0xBC8F8F, 0x4169E1, 0x8B4513, 0xFA8072, 0xF4A460, 0x2E8B57, 0xFFF5EE, 0xA0522D, 0xC0C0C0, 0x87CEEB, 0x6A5ACD, 0x708090, 0xFFFAFA, 0x00FF7F, 0x4682B4, 0xD2B48C, 0x008080, 0xD8BFD8, 0xFF6347, 0x40E0D0, 0xEE82EE, 0xF5DEB3, 0xFFFFFF, 0xF5F5F5, 0xFFFF00, 0x9ACD32]

        return (alpha << 24 | colors[Random(0, 139)])
    }
}
