#Requires AutoHotkey v2.0-beta.12

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

#DllLoad "Gdiplus"

;#DllLoad "..\Core\engine"

;============ Auto-Execute ====================================================;

#Include ..\Math\Math.ahk

;===============  Class  =======================================================;

/*
    ** GDIp_Enums: https://github.com/mono/libgdiplus/blob/main/src/gdipenums.h **

;* enum BrushType  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-brushtype
    0 = BrushTypeSolidColor
    1 = BrushTypeHatchFill
    2 = BrushTypeTextureFill
    3 = BrushTypePathGradient
    4 = BrushTypeLinearGradient

;* enum ColorAdjustType  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolormatrix/ne-gdipluscolormatrix-coloradjusttype
    0 = ColorAdjustTypeDefault
    1 = ColorAdjustTypeBitmap
    2 = ColorAdjustTypeBrush
    3 = ColorAdjustTypePen
    4 = ColorAdjustTypeText
    5 = ColorAdjustTypeCount
    6 = ColorAdjustTypeAny

;* enum ColorChannelFlags  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolor/ne-gdipluscolor-colorchannelflags
    0 = ColorChannelFlagsC
    1 = ColorChannelFlagsM
    2 = ColorChannelFlagsY
    3 = ColorChannelFlagsK
    4 = ColorChannelFlagsLast

;* enum ColorMatrixFlags  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolormatrix/ne-gdipluscolormatrix-colormatrixflags
    0 = ColorMatrixFlagsDefault
    1 = ColorMatrixFlagsSkipGrays
    2 = ColorMatrixFlagsAltGray

;* enum CombineMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-combinemode
    0 = CombineModeReplace
    1 = CombineModeIntersect
    2 = CombineModeUnion
    3 = CombineModeXor
    4 = CombineModeExclude
    5 = CombineModeComplement

;* enum CompositingMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingmode
    0 = CompositingModeSourceOver - Specifies that when a color is rendered, it overwrites the background color.
    1 = CompositingModeSourceCopy - Specifies that when a color is rendered, it is blended with the background color. The blend is determined by the alpha component of the color being rendered.

;* enum CompositingQuality  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingquality
    0 = CompositingQualityDefault
    1 = CompositingQualityHighSpeed
    2 = CompositingQualityHighQuality
    3 = CompositingQualityGammaCorrected
    4 = CompositingQualityAssumeLinear

;* enum CurveAdjustments  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curveadjustments
    0 = AdjustExposure
    1 = AdjustDensity
    2 = AdjustContrast
    3 = AdjustHighlight
    4 = AdjustShadow
    5 = AdjustMidtone
    6 = AdjustWhiteSaturation
    7 = AdjustBlackSaturation

;* enum CurveChannel  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curvechannel
    0 = CurveChannelAll
    1 = CurveChannelRed
    2 = CurveChannelGreen
    3 = CurveChannelBlue

;* enum DashCap  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-dashcap
    0 = DashCapFlat
    2 = DashCapRound
    3 = DashCapTriangle

;* enum DashStyle  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-dashstyle
    0 = DashStyleSolid
    1 = DashStyleDash
    2 = DashStyleDot
    3 = DashStyleDashDot
    4 = DashStyleDashDotDot
    5 = DashStyleCustom

;* enum FillMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fillmode
    0 = FillModeAlternate
    1 = FillModeWinding

;* enum FlushIntention  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-flushintention
    0 = FlushIntentionFlush - Flush all batched rendering operations and return immediately.
    1 = FlushIntentionSync - Flush all batched rendering operations and wait for them to complete.

;* enum FontStyle  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fontstyle
    0 = FontStyleRegular
    1 = FontStyleBold
    2 = FontStyleItalic
    3 = FontStyleBoldItalic
    4 = FontStyleUnderline
    8 = FontStyleStrikeout

;* enum HatchStyle  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-hatchstyle
     0 = HatchStyleHorizontal || HatchStyleMin
     1 = HatchStyleVertical
     2 = HatchStyleForwardDiagonal
     3 = HatchStyleBackwardDiagonal
     4 = HatchStyleCross || HatchStyleLargeGrid
     5 = HatchStyleDiagonalCross
     6 = HatchStyle05Percent
     7 = HatchStyle10Percent
     8 = HatchStyle20Percent
     9 = HatchStyle25Percent
    10 = HatchStyle30Percent
    11 = HatchStyle40Percent
    12 = HatchStyle50Percent
    13 = HatchStyle60Percent
    14 = HatchStyle70Percent
    15 = HatchStyle75Percent
    16 = HatchStyle80Percent
    17 = HatchStyle90Percent
    18 = HatchStyleLightDownwardDiagonal
    19 = HatchStyleLightUpwardDiagonal
    20 = HatchStyleDarkDownwardDiagonal
    21 = HatchStyleDarkUpwardDiagonal
    22 = HatchStyleWideDownwardDiagonal
    23 = HatchStyleWideUpwardDiagonal
    24 = HatchStyleLightVertical
    25 = HatchStyleLightHorizontal
    26 = HatchStyleNarrowVertical
    27 = HatchStyleNarrowHorizontal
    28 = HatchStyleDarkVertical
    29 = HatchStyleDarkHorizontal
    30 = HatchStyleDashedDownwardDiagonal
    31 = HatchStyleDashedUpwardDiagonal
    32 = HatchStyleDashedHorizontal
    33 = HatchStyleDashedVertical
    34 = HatchStyleSmallConfetti
    35 = HatchStyleLargeConfetti
    36 = HatchStyleZigZag
    37 = HatchStyleWave
    38 = HatchStyleDiagonalBrick
    39 = HatchStyleHorizontalBrick
    40 = HatchStyleWeave
    41 = HatchStylePlaid
    42 = HatchStyleDivot
    43 = HatchStyleDottedGrid
    44 = HatchStyleDottedDiamond
    45 = HatchStyleShingle
    46 = HatchStyleTrellis
    47 = HatchStyleSphere
    48 = HatchStyleSmallGrid
    49 = HatchStyleSmallCheckerBoard
    50 = HatchStyleLargeCheckerBoard
    51 = HatchStyleOutlinedDiamond
    52 = HatchStyleSolidDiamond || HatchStyleMax
    53 = HatchStyleTotal

;* enum ImageFlags  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-imageflags
    0x00000000 = ImageFlagsNone
    0x00000001 = ImageFlagsScalable
    0x00000002 = ImageFlagsHasAlpha
    0x00000004 = ImageFlagsHasTranslucent
    0x00000008 = ImageFlagsPartiallyScalable
    0x00000010 = ImageFlagsColorSpaceRGB
    0x00000020 = ImageFlagsColorSpaceCMYK
    0x00000040 = ImageFlagsColorSpaceGRAY
    0x00000080 = ImageFlagsColorSpaceYCBCR
    0x00000100 = ImageFlagsColorSpaceYCCK
    0x00001000 = ImageFlagsHasRealDPI
    0x00002000 = ImageFlagsHasRealPixelSize
    0x00010000 = ImageFlagsReadOnly
    0x00020000 = ImageFlagsCaching

;* enum ImageLockMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-imagelockmode
    0x0001 = ImageLockModeRead
    0x0002 = ImageLockModeWrite
    0x0004 = ImageLockModeUserInputBuf

;* enum InterpolationMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-interpolationmode
    0 = InterpolationModeDefault
    1 = InterpolationModeLowQuality
    2 = InterpolationModeHighQuality
    3 = InterpolationModeBilinear
    4 = InterpolationModeBicubic
    5 = InterpolationModeNearestNeighbor
    6 = InterpolationModeHighQualityBilinear
    7 = InterpolationModeHighQualityBicubic

;* enum LineCap  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-linecap
    0x00 = LineCapFlat
    0x01 = LineCapSquare
    0x02 = LineCapRound
    0x03 = LineCapTriangle
    0x10 = LineCapNoAnchor
    0x11 = LineCapSquareAnchor
    0x12 = LineCapRoundAnchor
    0x13 = LineCapDiamondAnchor
    0x14 = LineCapArrowAnchor
    0xFF = LineCapCustom
    0xF0 = LineCapAnchorMask

;* enum LinearGradientMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-lineargradientmode
    0 = LinearGradientModeVertical
    1 = LinearGradientModeHorizontal
    2 = LinearGradientModeBackwardDiagonal
    3 = LinearGradientModeForwardDiagonal

;* enum MatrixOrder  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder
    0 = MatrixOrderPrepend
    1 = MatrixOrderAppend

;* enum PenAlignment  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-penalignment
    0 = PenAlignmentCenter - Specifies that the pen is aligned on the center of the line that is drawn.
    1 = PenAlignmentInset - Specifies, when drawing a polygon, that the pen is aligned on the inside of the edge of the polygon.

;* enum PenType  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-pentype
    0 = PenTypeSolidColor
    1 = PenTypeHatchFill
    2 = PenTypeTextureFill
    3 = PenTypePathGradient
    4 = PenTypeLinearGradient
    -1 = PenTypeUnknown

;* enum PixelFormat  ;: https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-emfplus/47cbe48e-d13c-450b-8a23-6aa95488428e
    0x00030101 = PixelFormat1bppIndexed
    0x00030402 = PixelFormat4bppIndexed
    0x00030803 = PixelFormat8bppIndexed
    0x00101004 = PixelFormat16bppGrayScale
    0x00021005 = PixelFormat16bppRGB555
    0x00021006 = PixelFormat16bppRGB565
    0x00061007 = PixelFormat16bppARGB1555
    0x00021808 = PixelFormat24bppRGB
    0x00022009 = PixelFormat32bppRGB
    0x0026200A = PixelFormat32bppARGB
    0x000E200B = PixelFormat32bppPARGB
    0x0010300C = PixelFormat48bppRGB
    0x0034400D = PixelFormat64bppARGB
    0x001A400E = PixelFormat64bppPARGB

;* enum PixelOffsetMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-pixeloffsetmode
    -1 = PixelOffsetModeInvalid
    0 = PixelOffsetModeDefault - Equivalent to `PixelOffsetModeNone`.
    1 = PixelOffsetModeHighSpeed - Equivalent to `PixelOffsetModeNone`.
    2 = PixelOffsetModeHighQuality - Equivalent to `PixelOffsetModeHalf`.
    3 = PixelOffsetModeNone - Indicates that pixel centers have integer coordinates.
    4 = PixelOffsetModeHalf - Indicates that pixel centers have coordinates that are half way between integer values.

;* enum RotateFlipType  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-rotatefliptype
    0 = RotateNoneFlipNone
    1 = Rotate90FlipNone
    2 = Rotate180FlipNone
    3 = Rotate270FlipNone
    4 = RotateNoneFlipX
    5 = Rotate90FlipX
    6 = Rotate180FlipX
    7 = Rotate270FlipX
    RotateNoneFlipY = Rotate180FlipX
    Rotate90FlipY = Rotate270FlipX
    Rotate180FlipY = RotateNoneFlipX
    Rotate270FlipY = Rotate90FlipX
    RotateNoneFlipXY = Rotate180FlipNone
    Rotate90FlipXY = Rotate270FlipNone
    Rotate180FlipXY = RotateNoneFlipNone
    Rotate270FlipXY = Rotate90FlipNone

;* enum SmoothingMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-smoothingmode
    0 = SmoothingModeDefault
    1 = SmoothingModeHighSpeed
    2 = SmoothingModeHighQuality
    3 = SmoothingModeNone
    4 = SmoothingModeAntiAlias

;* enum StringAlignment  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringalignment
    0 = StringAlignmentNear - Left/Top.
    1 = StringAlignmentCenter
    2 = StringAlignmentFar - Right/Bottom.

;* enum StringDigitSubstitute  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringdigitsubstitute
    0 = StringDigitSubstituteUser
    1 = StringDigitSubstituteNone
    2 = StringDigitSubstituteNational
    3 = StringDigitSubstituteTraditional

;* enum StringFormatFlags  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringformatflags
    0x00000001 = StringFormatFlagsDirectionRightToLeft
    0x00000002 = StringFormatFlagsDirectionVertical
    0x00000004 = StringFormatFlagsNoFitBlackBox - Parts of characters are allowed to overhang the string's layout rectangle.
    0x00000020 = StringFormatFlagsDisplayFormatControl - Unicode layout control characters are displayed with a representative character.
    0x00000400 = StringFormatFlagsNoFontFallback - Prevent using an alternate font  for characters that are not supported in the requested font.
    0x00000800 = StringFormatFlagsMeasureTrailingSpaces - The spaces at the end of each line are included in a string measurement.
    0x00001000 = StringFormatFlagsNoWrap - Disable text wrapping.
    0x00002000 = StringFormatFlagsLineLimit - Only entire lines are laid out in the layout rectangle.
    0x00004000 = StringFormatFlagsNoClip - Characters overhanging the layout rectangle and text extending outside the layout rectangle are allowed to show.

;* enum StringTrimming  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringtrimming
    0 = StringTrimmingNone
    1 = StringTrimmingCharacter
    2 = StringTrimmingWord
    3 = StringTrimmingEllipsisCharacter
    4 = StringTrimmingEllipsisWord
    5 = StringTrimmingEllipsisPath

;* enum TextRenderingHint  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-textrenderinghint
    0 = TextRenderingHintSystemDefault
    1 = TextRenderingHintSingleBitPerPixelGridFit
    2 = TextRenderingHintSingleBitPerPixel
    3 = TextRenderingHintAntiAliasGridFit
    4 = TextRenderingHintAntiAlias
    5 = TextRenderingHintClearTypeGridFit

;* enum Unit  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit
    0 = UnitWorld - World coordinate (non-physical unit).
    1 = UnitDisplay - Variable (only for PageTransform).
    2 = UnitPixel - Each unit is one device pixel.
    3 = UnitPoint - Each unit is a printer's point, or 1/72 inch.
    4 = UnitInch
    5 = UnitDocument - Each unit is 1/300 inch.

;* enum WrapMode  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-wrapmode
    0 = WrapModeTile - Tiling without flipping.
    1 = WrapModeTileFlipX - Tiles are flipped horizontally as you move from one tile to the next in a row.
    2 = WrapModeTileFlipY - Tiles are flipped vertically as you move from one tile to the next in a column.
    3 = WrapModeTileFlipXY - Tiles are flipped horizontally as you move along a row and flipped vertically as you move along a column.
    4 = WrapModeClamp - No tiling takes place.
*/

class GDIp {

    __New(params*) {
        throw (TargetError("This class may not be constructed.", -1))
    }

    ;* GDIp.Startup()
    static Startup() {
        if (this.HasProp("Token")) {
            return (false)
        }

        static input := Buffer.CreateGDIplusStartupInput()

        if (status := DllCall("Gdiplus\GdiplusStartup", "Ptr*", &(pToken := 0), "Ptr", input.Ptr, "Ptr", 0, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup
            throw (ErrorFromStatus(status))
        }

        return (!!(this.Token := pToken))
    }

    ;* GDIp.Shutdown()
    static Shutdown() {
        if (this.HasProp("Token")) {
            if (status := DllCall("Gdiplus\GdiplusShutdown", "Ptr", this.DeleteProp("Token"))) {
                throw (ErrorFromStatus(status))
            }

            return (true)
        }

        return (false)
    }

    ;======================================================= Effect ===============;

    ;* GDIp.CreateBlurEffect(radius, expandEdge)
    ;* Parameter:
        ;* [Float] radius - Real number that specifies the blur radius (the radius of the Gaussian convolution kernel) in pixels. The radius must be in the range 0 through 255. As the radius increases, the resulting bitmap becomes more blurry.
        ;* [Integer] expandEdge - Boolean value that specifies whether the bitmap expands by an amount equal to the blur radius. If TRUE, the bitmap expands by an amount equal to the radius so that it can have soft edges. If FALSE, the bitmap remains the same size and the soft edges are clipped.
    ;* Return:
        ;* [Effect]
    static CreateBlurEffect(radius, expandEdge) {
        static GUID := CLSIDFromString("{633C80A4-1843-482B-9EF2-BE2834C5FDD4}")  ;? {0x633C80A4, 0x1843, 0x482B, {0x9E, 0xF2, 0xBE, 0x28, 0x34, 0xC5, 0xFD, 0xD4}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        (params := Buffer(8)).NumPut(0, "Float", radius, "UInt", expandEdge)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-blurparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 8, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateSharpenEffect(radius, amount)
    ;* Parameter:
        ;* [Float] radius - Specifies the sharpening radius (the radius of the convolution kernel) in pixels. The radius must be in the range 0 through 255. As the radius increases, more surrounding pixels are involved in calculating the new value of a given pixel.
        ;* [Float] amount - Real number in the range 0 through 100 that specifies the amount of sharpening to be applied. A value of 0 specifies no sharpening. As the value of amount increases, the sharpness increases.
    ;* Return:
        ;* [Effect]
    static CreateSharpenEffect(radius, amount) {
        static GUID := CLSIDFromString("{63CBF3EE-C526-402C-8F71-62C540BF5142}")  ;? {0x63CBF3EE, 0xC526, 0x402C, {0x8F, 0x71, 0x62, 0xC5, 0x40, 0xBF, 0x51, 0x42}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        (params := Buffer(8)).NumPut(0, "Float", radius, "Float", amount)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-sharpenparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 8, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateColorMatrixEffect(colorMatrix)
    ;* Parameter:
        ;* [Buffer] colorMatrix - A 5x5 matrix structure to apply.
    ;* Return:
        ;* [Effect]
    static CreateColorMatrixEffect(colorMatrix) {
        static GUID := CLSIDFromString("{718F2615-7933-40E3-A511-5F68FE14DD74}")  ;? {0x718F2615, 0x7933, 0x40E3, {0xA5, 0x11, 0x5F, 0x68, 0xFE, 0x14, 0xDD, 0x74}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", colorMatrix, "UInt", 100, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-colormatrixeffect-setparameters
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateColorLUTEffect()
    ;* Return:
        ;* [Effect]
    static CreateColorLUTEffect() {
        static GUID := CLSIDFromString("{A7CE72A9-0F7F-40D7-B3CC-D0C02D5C3212}")  ;? {0xA7CE72A9, 0xF7F, 0x40D7, {0xB3, 0xCC, 0xD0, 0xC0, 0x2D, 0x5C, 0x32, 0x12}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateBrightnessContrastEffect(brightness, contrast)
    ;* Parameter:
        ;* [Integer] brightness - Integer in the range -255 through 255 that specifies the brightness level. If the value is 0, the brightness remains the same. As the value moves from 0 to 255, the brightness of the image increases. As the value moves from 0 to -255, the brightness of the image decreases.
        ;* [Integer] contrast - Integer in the range -100 through 100 that specifies the contrast level. If the value is 0, the contrast remains the same. As the value moves from 0 to 100, the contrast of the image increases. As the value moves from 0 to -100, the contrast of the image decreases.
    ;* Return:
        ;* [Effect]
    static CreateBrightnessContrastEffect(brightness, contrast) {
        static GUID := CLSIDFromString("{D3A1DBE1-8EC4-4C17-9F4C-EA97AD1C343D}")  ;? {0xD3A1DBE1, 0x8EC4, 0x4C17, {0x9F, 0x4C, 0xEA, 0x97, 0xAD, 0x1C, 0x34, 0x3D}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        (params := Buffer(8)).NumPut(0, "Int", brightness, "Int", contrast)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-brightnesscontrastparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 8, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateHueSaturationLightnessEffect(hue, saturation, lightness)
    ;* Parameter:
        ;* [Integer] hue - Integer in the range -180 through 180 that specifies the change in hue. A value of 0 specifies no change. Positive values specify counterclockwise rotation on the color wheel. Negative values specify clockwise rotation on the color wheel.
        ;* [Integer] saturation - Integer in the range -100 through 100 that specifies the change in saturation. A value of 0 specifies no change. Positive values specify increased saturation and negative values specify decreased saturation.
        ;* [Integer] lightness - Integer in the range -100 through 100 that specifies the change in lightness. A value of 0 specifies no change. Positive values specify increased lightness and negative values specify decreased lightness.
    ;* Return:
        ;* [Effect]
    static CreateHueSaturationLightnessEffect(hue, saturation, lightness) {
        static GUID := CLSIDFromString("{8B2DD6C3-EB07-4D87-A5F0-7108E26A9C5F}")  ;? {0x8B2DD6C3, 0xEB07, 0x4D87, {0xA5, 0xF0, 0x71, 0x8, 0xE2, 0x6A, 0x9C, 0x5F}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        (params := Buffer(12)).NumPut(0, "Int", hue, "Int", saturation, "Int", lightness)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 12, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateLevelsEffect(highlight, midtone, shadow)
    ;* Parameter:
        ;* [Integer] highlight - Integer in the range 0 through 100 that specifies which pixels should be lightened. You can use this adjustment to lighten pixels that are already lighter than a certain threshold. Setting highlight to 100 specifies no change. Setting highlight to t specifies that a color channel value is increased if it is already greater than t percent of full intensity. For example, setting highlight to 90 specifies that all color channel values greater than 90 percent of full intensity are increased.
        ;* [Integer] midtone - Integer in the range -100 through 100 that specifies how much to lighten or darken an image. Color channel values in the middle of the intensity range are altered more than color channel values near the minimum or maximum intensity. You can use this adjustment to lighten (or darken) an image without loosing the contrast between the darkest and lightest portions of the image. A value of 0 specifies no change. Positive values specify that the midtones are made lighter, and negative values specify that the midtones are made darker.
        ;* [Integer] shadow - Integer in the range 0 through 100 that specifies which pixels should be darkened. You can use this adjustment to darken pixels that are already darker than a certain threshold. Setting shadow to 0 specifies no change. Setting shadow to t specifies that a color channel value is decreased if it is already less than t percent of full intensity. For example, setting shadow to 10 specifies that all color channel values less than 10 percent of full intensity are decreased.
    ;* Return:
        ;* [Effect]
    static CreateLevelsEffect(highlight, midtone, shadow) {
        static GUID := CLSIDFromString("{99C354EC-2A31-4F3A-8C34-17A803B33A25}")  ;? {0x99C354EC, 0x2A31, 0x4F3A, {0x8C, 0x34, 0x17, 0xA8, 0x3, 0xB3, 0x3A, 0x25}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        (params := Buffer(12)).NumPut(0, "Int", highlight, "Int", midtone, "Int", shadow)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-levelsparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 12, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateTintEffect(hue, amount)
    ;* Parameter:
        ;* [Integer] hue - Integer in the range -180 through 180 that specifies the hue to be strengthened or weakened. A value of 0 specifies blue. A positive value specifies a clockwise angle on the color wheel. For example, positive 60 specifies cyan and positive 120 specifies green. A negative value specifies a counter-clockwise angle on the color wheel. For example, negative 60 specifies magenta and negative 120 specifies red.
        ;* [Integer] amount - Integer in the range -100 through 100 that specifies how much the hue (given by the hue parameter) is strengthened or weakened. A value of 0 specifies no change. Positive values specify that the hue is strengthened and negative values specify that the hue is weakened.
    ;* Return:
        ;* [Effect]
    static CreateTintEffect(hue, amount) {
        static GUID := CLSIDFromString("{1077AF00-2848-4441-9489-44AD4C2D7A2C}")  ;? {0x1077AF00, 0x2848, 0x4441, {0x94, 0x89, 0x44, 0xAD, 0x4C, 0x2D, 0x7A, 0x2C}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        (params := Buffer(8)).NumPut(0, "Int", hue, "Int", amount)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-tintparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 8, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateColorBalanceEffect(cyanRed, magentaGreen, yellowBlue)
    ;* Parameter:
        ;* [Integer] cyanRed - Integer in the range -100 through 100 that specifies a change in the amount of red in the image. If the value is 0, there is no change. As the value moves from 0 to 100, the amount of red in the image increases and the amount of cyan decreases. As the value moves from 0 to -100, the amount of red in the image decreases and the amount of cyan increases.
        ;* [Integer] magentaGreen - Integer in the range -100 through 100 that specifies a change in the amount of green in the image. If the value is 0, there is no change. As the value moves from 0 to 100, the amount of green in the image increases and the amount of magenta decreases. As the value moves from 0 to -100, the amount of green in the image decreases and the amount of magenta increases.
        ;* [Integer] yellowBlue - Integer in the range -100 through 100 that specifies a change in the amount of blue in the image. If the value is 0, there is no change. As the value moves from 0 to 100, the amount of blue in the image increases and the amount of yellow decreases. As the value moves from 0 to -100, the amount of blue in the image decreases and the amount of yellow increases.
    ;* Return:
        ;* [Effect]
    static CreateColorBalanceEffect(cyanRed, magentaGreen, yellowBlue) {
        static GUID := CLSIDFromString("{537E597D-251E-48DA-9664-29CA496B70F8}")  ;? {0x537E597D, 0x251E, 0x48DA, {0x96, 0x64, 0x29, 0xCA, 0x49, 0x6B, 0x70, 0xF8}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        (params := Buffer(12)).NumPut(0, "Int", cyanRed, "Int", magentaGreen, "Int", yellowBlue)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorbalanceparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 12, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateRedEyeCorrectionEffect(objects*)
    ;* Parameter:
        ;* [Integer] objects - Any number of objects with `x`, `y`, `Width` and `Height` properties which specify areas of the bitmap to which red eye correction should be applied.
    ;* Return:
        ;* [Effect]
    static CreateRedEyeCorrectionEffect(objects*) {
        static GUID := CLSIDFromString("{74D29D05-69A4-4266-9549-3CC52836B632}")  ;? {0x74D29D05, 0x69A4, 0x4266, {0x95, 0x49, 0x3C, 0xC5, 0x28, 0x36, 0xB6, 0x32}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        for index, rect in (areas := Buffer(bytes := (numberOfAreas := objects.Length)*16), objects) {
            areas.NumPut(index*16, "Int", rect.x, "Int", rect.y, "Int", rect.x + rect.Width - 1, "Int", rect.y + rect.Height - 1)  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect
        }

        (params := Buffer(16)).NumPut(0, "UInt", numberOfAreas, "UInt", 0, "Ptr", areas.Ptr)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-redeyecorrectionparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params.Ptr, "UInt", 16 + bytes, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    ;* GDIp.CreateRedEyeCorrectionEffect(adjustment, channel, adjustValue)
    ;* Parameter:
        ;* [Integer] adjustment - See CurveAdjustments enumeration.
        ;* [Integer] channel - See CurveChannel enumeration.
        ;* [Integer] adjustValue - Integer that specifies the intensity of the adjustment. The range of acceptable values depends on which adjustment is being applied:
            ; AdjustExposure - In the [-255, 255] interval.
            ; AdjustDensity - In the [-255, 255] interval.
            ; AdjustContrast - In the [-100, 100] interval.
            ; AdjustHighlight - In the [-100, 100] interval.
            ; AdjustShadow - In the [-100, 100] interval.
            ; AdjustMidtone - In the [-100, 100] interval.
            ; AdjustWhiteSaturation - In the [0, 255] interval.
            ; AdjustBlackSaturation - In the [0, 255] interval.
    ;* Return:
        ;* [Effect]
    static CreateColorCurveEffect(adjustment, channel, adjustValue) {
        static GUID := CLSIDFromString("{DD6A0022-58E4-4A67-9D9B-D48EB881A53D}")  ;? {0xDD6A0022, 0x58E4, 0x4A67, {0x9D, 0x9B, 0xD4, 0x8E, 0xB8, 0x81, 0xA5, 0x3D}}

        if (status := DllCall("Gdiplus\GdipCreateEffect", "Ptr", GUID, "Ptr*", &(pEffect := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        (params := Buffer(12)).NumPut(0, "Int", adjustment, "Int", channel, "Int", adjustValue)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorcurveparams

        if (status := DllCall("Gdiplus\GdipSetEffectParameters", "Ptr", pEffect, "Ptr", params, "UInt", 12, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Effect(pEffect))
    }

    class Effect {
        Class := "Effect"

        __New(pEffect) {
            this.Ptr := pEffect
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteEffect", "Ptr", this.Ptr, "Int")
            }
        }
    }

    ;======================================================= Matrix ===============;

    ;* GDIp.CreateMatrix([m11, m12, m21, m22, m31, m32])
    ;* Return:
        ;* [Matrix]
    static CreateMatrix(m11 := 1, m12 := 0, m21 := 0, m22 := 1, m31 := 0, m32 := 0) {
        if (status := DllCall("Gdiplus\GdipCreateMatrix2", "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", m31, "Float", m32, "Ptr*", &(pMatrix := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Matrix(pMatrix))
    }

/*
    ** Matrix Class: https://docs.microsoft.com/en-us/dotnet/api/system.drawing.drawing2d.matrix?view=net-5.0. **
*/

    class Matrix {
        Class := "Matrix"

        static Equals(matrix1, matrix2) {
            if (status := DllCall("Gdiplus\GdipIsMatrixEqual", "Ptr", matrix1, "Ptr", matrix2, "Int*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        __New(pMatrix) {
            this.Ptr := pMatrix
        }

        ;* matrix.Clone()
        ;* Return:
            ;* [Matrix]
        Clone() {
            if (status := DllCall("Gdiplus\GdipCloneMatrix", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Matrix(pMatrix))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteMatrix", "Ptr", this.Ptr, "Int")
            }
        }

        IsIdentityMatrix() {
            if (status := DllCall("Gdiplus\GdipIsMatrixIdentity", "Ptr", this.Ptr, "UInt*", &(bool := false), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        IsInvertible() {
            if (status := DllCall("Gdiplus\GdipIsMatrixInvertible", "Ptr", this.Ptr, "UInt*", &(bool := false), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* matrix.Set(m11, m12, m21, m22, m31, m32)
        ;* Parameter:
            ;* [Float] m11
            ;* [Float] m12
            ;* [Float] m21
            ;* [Float] m22
            ;* [Float] m31
            ;* [Float] m32
        Set(m11, m12, m21, m22, m31, m32) {
            if (status := DllCall("Gdiplus\GdipSetMatrixElements", "Ptr", this.Ptr, "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", m31, "Float", m32, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (this)
        }

        ;* matrix.SetIdentity()
        SetIdentity() {
            if (status := DllCall("Gdiplus\GdipResetMatrix", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (this)
        }

        ;* matrix.Multiply(matrix[, matrixOrder])
        ;* Description:
            ;* Updates this matrix with the product of itself and another matrix.
        ;* Parameter:
            ;* [Matrix] matrix - See MatrixOrder enumeration.
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        Multiply(matrix, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipMultiplyMatrix", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (this)
        }

        ;* matrix.Invert()
        ;* Description:
            ;* If the matrix is invertible, this function replaces its elements  with the elements of its inverse.
        Invert() {
            if (status := DllCall("Gdiplus\GdipInvertMatrix", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (this)
        }

        ;* matrix.Rotate(angle[, matrixOrder])
        ;* Description:
            ;* Updates this matrix with the product of itself and a rotation matrix.
        ;* Parameter:
            ;* [Float] angle - Simple precision value that specifies the angle of rotation (in degrees). Positive values specify clockwise rotation.
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        Rotate(angle, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipRotateMatrix", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (this)
        }

        ;* matrix.RotateWithTranslation(angle, dx, dy[, matrixOrder])
        ;* Parameter:
            ;* [Float] angle - Simple precision value that specifies the angle of rotation (in degrees). Positive values specify clockwise rotation.
            ;* [Float] dx
            ;* [Float] dy
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        RotateWithTranslation(angle, dx, dy, matrixOrder := 0) {
            theta := angle*0.017453292519943
                , c := Cos(theta), s := Sin(theta)

            static matrix := Buffer(24)

            if (status := DllCall("Gdiplus\GdipGetMatrixElements", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            if (matrixOrder) {
                a11 := matrix.NumGet(0, "Float"), a12 := matrix.NumGet(4, "Float"), a21 := matrix.NumGet(8, "Float"), a22 := matrix.NumGet(12, "Float"), a31 := matrix.NumGet(16, "Float"), a32 := matrix.NumGet(20, "Float")

                return (this.Set(a11*c + a12*-s, a11*s + a12*c, a21*c + a22*-s, a21*s + a22*c, a31*c + a32*-s + dx*(1 - c) + dy*s, a31*s + a32*c - dx*s + dy*(1 - c)))
            }
            else {
                b11 := matrix.NumGet(0, "Float"), b12 := matrix.NumGet(4, "Float"), b21 := matrix.NumGet(8, "Float"), b22 := matrix.NumGet(12, "Float")

                return (this.Set(c*b11 + s*b21, c*b12 + s*b22, -s*b11 + c*b21, -s*b12 + c*b22, matrix.NumGet(16, "Float") + dx*(1 - c) + dy*s, matrix.NumGet(20, "Float") - dx*s + dy*(1 - c)))
            }
        }

        ;* matrix.Scale(x, y[, matrixOrder])
        ;* Description:
            ;* Updates this matrix with the product of itself and a scaling matrix.
        ;* Parameter:
            ;* [Float] x - Simple precision value that specifies the horizontal scale factor.
            ;* [Float] y - Simple precision value that specifies the vertical scale factor.
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        Scale(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipScaleMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (this)
        }

        ;* matrix.ScaleWithTranslation(sx, sy, dx, dy[, matrixOrder])
        ;* Parameter:
            ;* [Float] sx
            ;* [Float] sy
            ;* [Float] dx
            ;* [Float] dy
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        ScaleWithTranslation(sx, sy, dx, dy, matrixOrder := 0) {
            static matrix := Buffer(24)

            if (status := DllCall("Gdiplus\GdipGetMatrixElements", "Ptr", this.Ptr, "Ptr", matrix.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            if (matrixOrder) {
                return (this.Set(matrix.NumGet(0, "Float")*sx, matrix.NumGet(4, "Float")*sy, matrix.NumGet(8, "Float")*sx, matrix.NumGet(12, "Float")*sy, matrix.NumGet(16, "Float")*sx + dx*(1 - sx), matrix.NumGet(20, "Float")*sy + dy*(1 - sy)))
            }
            else {
                b11 := matrix.NumGet(0, "Float"), b12 := matrix.NumGet(4, "Float"), b21 := matrix.NumGet(8, "Float"), b22 := matrix.NumGet(12, "Float")

                return (this.Set(sx*b11, sx*b12, sy*b21, sy*b22, dx*(1 - sx)*b11 + dy*(1 - sy)*b21 + matrix.NumGet(16, "Float"), dx*(1 - sx)*b12 + dy*(1 - sy)*b22 + matrix.NumGet(20, "Float")))
            }
        }

        ;* matrix.Shear(x, y[, matrixOrder])
        ;* Description:
            ;* Updates this matrix with the product of itself and a shearing matrix.
        ;* Parameter:
            ;* [Float] x - Simple precision value that specifies the horizontal shear factor.
            ;* [Float] y - Simple precision value that specifies the vertical shear factor.
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        Shear(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipShearMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (this)
        }

        ;* matrix.Translate(x, y[, matrixOrder])
        ;* Description:
            ;* Updates this matrix with the product of itself and a scaling matrix.
        ;* Parameter:
            ;* [Float] x - Single precision value that specifies the horizontal component of the translation.
            ;* [Float] y - Single precision value that specifies the vertical component of the translation.
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        Translate(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipTranslateMatrix", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (this)
        }
    }

    ;==================================================  ImageAttributes  ==========;

    ;* GDIp.CreateImageAttributes()
    ;* Return:
        ;* [ImageAttributes]
    static CreateImageAttributes() {
        if (status := DllCall("Gdiplus\GdipCreateImageAttributes", "Ptr*", &(pImageAttributes := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.ImageAttributes(pImageAttributes))
    }

    class ImageAttributes {
        Class := "ImageAttributes"

        __New(pImageAttributes) {
            this.Ptr := pImageAttributes
        }

        ;* imageAttributes.Clone()
        ;* Return:
            ;* [ImageAttributes]
        Clone() {
            if (status := DllCall("Gdiplus\GdipCloneImageAttributes", "Ptr", this.Ptr, "Ptr*", &(pImageAttributes := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.ImageAttributes(pImageAttributes))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDisposeImageAttributes", "Ptr", this.Ptr, "Int")
            }
        }

        ;* imageAttributes.SetAdjustType(adjustType, enableFlag)
        ;* Description:
            ;* Enables or disables color adjustment for a specified category.
        ;* Parameter:
            ;* [Integer] adjustType - See ColorAdjustType enumeration.
            ;* [Integer] enableFlag - Boolean value that specifies whether a color adjustment is enabled for the category specified by `adjustType`.
        SetAdjustType(adjustType, enableFlag) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesNoOp", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.SetColorKeys(colorLow, colorHigh[, adjustType, enableFlag])
        ;* Description:
            ;* Sets the color key (transparency range) for a specified category.
        ;* Parameter:
            ;* [Integer] colorLow - Color that specifies the low color-key value.
            ;* [Integer] colorHigh - Color that specifies the high color-key value.
            ;* [Integer] adjustType - See ColorAdjustType enumeration.
            ;* [Integer] enableFlag - Boolean value that specifies whether a separate transparency range is enabled for the category specified by `adjustType`.
        SetColorKeys(colorLow, colorHigh, adjustType := 0, enableFlag := true) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesColorKeys", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "UInt", colorLow, "UInt", colorHigh, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.SetColorMatrix(colorMatrix[, adjustType, enableFlag, flags, grayMatrix])
        ;* Description:
            ;* Sets the color-adjustment matrix for a specified category.
        ;* Parameter:
            ;* [Buffer] colorMatrix - A 5x5 color-adjustment matrix structure.
            ;* [Integer] adjustType - See ColorAdjustType enumeration.
            ;* [Integer] enableFlag - Boolean value that specifies whether a separate color adjustment is enabled for the category specified by `adjustType`.
            ;* [Integer] flags - See ColorMatrixFlags enumeration.
            ;* [Buffer] grayMatrix - A 5x5 color-adjustment matrix structure used for adjusting gray shades when the value of `flags` is `ColorMatrixFlagsAltGray`.
        SetColorMatrix(colorMatrix, adjustType := 0, enableFlag := true, flags := 0, grayMatrix := 0) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesColorMatrix", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Ptr", colorMatrix.Ptr, "Ptr", grayMatrix, "Int", flags, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.SetGamma(gamma[, adjustType, enableFlag])
        ;* Description:
            ;* Sets the gamma value for a specified category.
        ;* Parameter:
            ;* [Float] gamma
            ;* [Integer] adjustType - See ColorAdjustType enumeration.
            ;* [Integer] enableFlag - Boolean value that specifies whether a separate gamma is enabled for the category specified by `adjustType`.
        SetGamma(gamma, adjustType := 0, enableFlag := true) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesGamma", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Float", gamma, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.SetICMMode(bool)
        ;* Parameter:
            ;* [Integer] bool
        SetICMMode(bool) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesICMMode", "Ptr", this.Ptr, "UInt", bool, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.SetOutputChannel(channelFlags[, adjustType, enableFlag])
        ;* Description:
            ;* Sets the CMYK output channel for a specified category.
        ;* Parameter:
            ;* [Integer] channelFlags - See ColorChannelFlags enumeration.
            ;* [Integer] adjustType - See ColorAdjustType enumeration.
            ;* [Integer] enableFlag - Boolean value that specifies whether a separate output channel is enabled for the category specified by `adjustType`.
        SetOutputChannel(channelFlags, adjustType := 0, enableFlag := true) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesOutputChannel", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Int", channelFlags, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.SetThreshold(threshold[, adjustType, enableFlag])
        ;* Description:
            ;* Sets the threshold (transparency range) for a specified category.
        ;* Parameter:
            ;* [Float] threshold
            ;* [Integer] adjustType - See ColorAdjustType enumeration.
            ;* [Integer] enableFlag - Boolean value that specifies whether a separate threshold is enabled for the category specified by `adjustType`.
        SetThreshold(threshold, adjustType := 0, enableFlag := true) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesThreshold", "Ptr", this.Ptr, "Int", adjustType, "UInt", enableFlag, "Float", threshold, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.SetWrapMode(wrapMode, color)
        ;* Description:
            ;* Sets the wrap mode of this ImageAttributes object.
        ;* Parameter:
            ;* [Integer] wrapMode - See WrapMode enumeration.
            ;* [Integer] color
        SetWrapMode(wrapMode, color) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesWrapMode", "Ptr", this.Ptr, "Int", wrapMode, "UInt", color, "UInt", 0, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.Reset(adjustType)
        ;* Parameter:
            ;* [Integer] adjustType - See ColorAdjustType enumeration.
        Reset(adjustType) {
            if (status := DllCall("Gdiplus\GdipResetImageAttributes", "Ptr", this.Ptr, "Int", adjustType, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* imageAttributes.ResetColorMatrix(adjustType)
        ;* Description:
            ;* Sets the color-adjustment matrix of a specified category to identity matrix.
        ;* Parameter:
            ;* [Integer] adjustType - See ColorAdjustType enumeration.
        ResetColorMatrix(adjustType) {
            if (status := DllCall("Gdiplus\GdipSetImageAttributesToIdentity", "Ptr", this.Ptr, "Int", adjustType, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
    }

    ;======================================================= Bitmap ===============;

    ;* GDIp.CreateBitmap(width, height[, pixelFormat, stride, scan0])
    ;* Parameter:
        ;* [Integer] width
        ;* [Integer] height
        ;* [Integer] pixelFormat - See PixelFormat enumeration.
        ;* [Integer] stride
        ;* [Buffer] scan0
    ;* Return:
        ;* [Bitmap]
    static CreateBitmap(width, height, pixelFormat := 0x26200A, stride := 0, scan0 := 0) {
        if (status := DllCall("Gdiplus\GdipCreateBitmapFromScan0", "UInt", width, "UInt", height, "UInt", stride, "UInt", pixelFormat, "Ptr", scan0, "Ptr*", &(pBitmap := 0), "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(int_int_int_pixelformat_byte)
            throw (ErrorFromStatus(status))
        }

        return (this.Bitmap(pBitmap))
    }

    ;* GDIp.CreateBitmapFromBase64(base64)
    ;* Parameter:
        ;* [String] base64
    ;* Return:
        ;* [Bitmap]
    static CreateBitmapFromBase64(base64) {  ;* ** Conversion: https://base64.guru/converter/encode/image/bmp **
        base64 := StrPtr(base64)

        if (!DllCall("Crypt32\CryptStringToBinary", "Ptr", base64, "UInt", 0, "UInt", 0x00000001, "Ptr", 0, "UInt*", &(bytes := 0), "Ptr", 0, "Ptr", 0, "UInt")) {  ;? 0x00000001 = CRYPT_STRING_BASE64  ;: https://docs.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptstringtobinarya
            throw (ErrorFromMessage())
        }

        if (!DllCall("Crypt32\CryptStringToBinary", "Ptr", base64, "UInt", 0, "UInt", 0x00000001, "Ptr", (buffer := Buffer(bytes)).Ptr, "UInt*", &bytes, "Ptr", 0, "Ptr", 0, "UInt")) {
            throw (ErrorFromMessage())
        }

        if (!(pStream := DllCall("Shlwapi\SHCreateMemStream", "Ptr", buffer.Ptr, "UInt", bytes, "Ptr"))) {
            throw (MemoryError("E_OUTOFMEMORY"))
        }

        bitmap := this.CreateBitmapFromStream(pStream, true)
        ObjRelease(pStream)

        return (bitmap)
    }

    ;* GDIp.CreateBitmapFromBitmapWithEffect(bitmap, effect[, x, y, width, height])
    ;* Parameter:
        ;* [Bitmap] bitmap
        ;* [Effect] effect
        ;* [Integer] x
        ;* [Integer] y
        ;* [Integer] width
        ;* [Integer] height
    ;* Return:
        ;* [Bitmap]
    static CreateBitmapFromBitmapWithEffect(bitmap, effect, x?, y?, width?, height?) {
        if (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height)) {
            static rect := Buffer.CreateRect(0, 0, 0, 0, "Int")

            rect.NumPut(0, "Int", x, "Int", y, "Int", width, "Int", height)

            if (status := DllCall("Gdiplus\GdipBitmapCreateApplyEffect", "Ptr*", bitmap, "Int", 1, "Ptr", effect, "Ptr", rect.Ptr, "Ptr", 0, "Ptr*", &(pBitmap := 0), "UInt", 0, "Ptr*", 0, "Int", 0, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
        else if (status := DllCall("Gdiplus\GdipBitmapCreateApplyEffect", "Ptr*", bitmap, "Int", 1, "Ptr", effect, "Ptr", 0, "Ptr", 0, "Ptr*", &(pBitmap := 0), "UInt", 0, "Ptr*", 0, "Int", 0, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Bitmap(pBitmap))
    }

    ;* GDIp.CreateBitmapFromFile(file[, useICM])
    ;* Parameter:
        ;* [String] file
        ;* [Integer] useICM
    ;* Return:
        ;* [Bitmap]
    static CreateBitmapFromFile(file, useICM := false) {
        if (status := (useICM)
            ? (DllCall("Gdiplus\GdipCreateBitmapFromFileICM", "Ptr", StrPtr(file), "Ptr*", &(pBitmap := 0), "Int"))
            : (DllCall("Gdiplus\GdipCreateBitmapFromFile", "Ptr", StrPtr(file), "Ptr*", &(pBitmap := 0), "Int"))) {
            throw (ErrorFromStatus(status))
        }

        return (this.Bitmap(pBitmap))
    }

    ;~ CreateBitmapFromGDIDIB

    ;* GDIp.CreateBitmapFromGraphics(graphics, width, height)
    ;* Parameter:
        ;* [Graphics] graphics - Graphics object that contains information used to initialize certain properties (for example, dots per inch) of the new Bitmap object.
        ;* [Integer] width
        ;* [Integer] height
    ;* Return:
        ;* [Bitmap]
    static CreateBitmapFromGraphics(graphics, width, height) {
        if (status := DllCall("Gdiplus\GdipCreateBitmapFromGraphics", "Int", width, "Int", height, "Ptr", graphics, "Ptr*", &(pBitmap := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Bitmap(pBitmap))
    }

    ;* GDIp.CreateBitmapFromHBITMAP(bitmap[, hPalette])
    ;* Parameter:
        ;* [HBitmap] bitmap
        ;* [Integer] hPalette
    ;* Return:
        ;* [Bitmap]
    static CreateBitmapFromHBITMAP(bitmap, hPalette := 0) {
        if (status := DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", bitmap.Handle, "Ptr", hPalette, "Ptr*", &(pBitmap := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Bitmap(pBitmap))
    }

    ;~ CreateBitmapFromHICON

    ;~ CreateBitmapFromResource

    ;* GDIp.CreateBitmapFromScreen([x, y, width, height])
    ;* Parameter:
        ;* [Integer] x
        ;* [Integer] y
        ;* [Integer] width
        ;* [Integer] height
    ;* Return:
        ;* [Bitmap]
    static CreateBitmapFromScreen(params*) {
        switch (params.Length) {
            case 4:
                x := params[0], y := params[1]
                    , width := params[2], height := params[3]
            case 1:

            default:
                x := DllCall("User32\GetSystemMetrics", "Int", 76), y := DllCall("User32\GetSystemMetrics", "Int", 77)
                    , width := DllCall("User32\GetSystemMetrics", "Int", 78), height := DllCall("User32\GetSystemMetrics", "Int", 79)
        }

        DC := GDI.CreateCompatibleDC()
        bitmap := GDI.CreateDIBSection(Buffer.CreateBitmapInfoHeader(width, -height), DC)
            , DC.SelectObject(bitmap)

        GDI.BitBlt(DC, 0, 0, width, height, GetDC(), x, y, 0x40CC0020)  ;? 0x40CC0020 = SRCCOPY | CAPTUREBLT

        return (this.CreateBitmapFromHBITMAP(bitmap))
    }

    ;* GDIp.CreateBitmapFromStream(stream[, useICM])
    ;* Parameter:
        ;* [Buffer] stream
        ;* [Integer] useICM
    ;* Return:
        ;* [Bitmap]
    static CreateBitmapFromStream(stream, useICM := false) {
        if (status := (useICM)
            ? (DllCall("Gdiplus\GdipCreateBitmapFromStreamICM", "Ptr", stream, "Ptr*", &(pBitmap := 0), "Int"))
            : (DllCall("Gdiplus\GdipCreateBitmapFromStream", "Ptr", stream, "Ptr*", &(pBitmap := 0), "Int"))) {
            throw (ErrorFromStatus(status))
        }

        return (this.Bitmap(pBitmap))
    }

    ;* GDIp.CreateBitmapFromWindow(hWnd[, client])
    ;* Parameter:
        ;* [Integer] hWnd
        ;* [Integer] client
    ;* Return:
        ;* [Bitmap]
    static CreateBitmapFromWindow(hWnd, client := true) {
        if (DllCall("User32\IsIconic", "Ptr", hWnd, "UInt")) {
            DllCall("User32\ShowWindow", "ptr", hWnd, "Int", 4)  ;* Restore the window if it is minimized as it must be visible for capture.
        }

        static rect := Buffer.CreateRect(0, 0, 0, 0, "Int")

        if (client) {
            if (!DllCall("User32\GetClientRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
                throw (ErrorFromMessage())
            }
        }
        else if (DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "UPtr", rect.Ptr, "UInt", 16, "UInt")) {
            if (!DllCall("User32\GetWindowRect", "Ptr", hWnd, "Ptr", rect.Ptr, "UInt")) {
                throw (ErrorFromMessage())
            }
        }

        DC := GDI.CreateCompatibleDC()
        bitmap := GDI.CreateDIBSection(Buffer.CreateBitmapInfoHeader(rect.NumGet(8, "Int"), -rect.NumGet(12, "Int"), 32, 0x0000), DC)
            , DC.SelectObject(bitmap)

        if (!DllCall("User32\PrintWindow", "Ptr", hWnd, "Ptr", DC.Handle, "UInt", 2 + client, "UInt")) {  ;? 2 = PW_RENDERFULLCONTENT, 1 = PW_CLIENTONLY
            throw (ErrorFromMessage())
        }

        return (this.CreateBitmapFromHBITMAP(bitmap))
    }

    ;* GDIp.CreateHBITMAPFromBitmap(bitmap[, background])
    ;* Parameter:
        ;* [Bitmap] bitmap
        ;* [Integer] background - Color that specifies the background color. This parameter is ignored if the bitmap is totally opaque.
    ;* Return:
        ;* [HBitmap]
    static CreateHBITMAPFromBitmap(bitmap, background := 0xFFFFFFFF) {
        if (status := DllCall("Gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", bitmap, "Ptr*", (hBitmap := 0), "UInt", background, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (GDI.HBitmap(hBitmap))
    }

    ;* GDIp.CreateThumbnail(bitmap, width, height)
    ;* Parameter:
        ;* [Bitmap] bitmap
        ;* [Integer] width
        ;* [Integer] height
    ;* Return:
        ;* [Bitmap]
    static CreateThumbnail(bitmap, width, height) {
        if (status := DllCall("Gdiplus\GdipGetImageThumbnail", "Ptr", bitmap, "UInt", width, "UInt", height, "Ptr*", &(pBitmap := 0), "Ptr", 0, "Ptr", 0, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (GDIp.Bitmap(pBitmap))
    }

    ;~ CreateHICONFromBitmap

/*
    ** A Beginners Guide to Bitmaps: http://paulbourke.net/dataformats/bitmaps/. **
*/

    class Bitmap {
        Class := "Bitmap"

        __New(pBitmap) {
            this.Ptr := pBitmap
        }

        ;* bitmap.Clone([x, y, width, height, pixelFormat])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Integer] pixelFormat - See PixelFormat enumeration.
        ;* Note:
            ;~ The new bitmap will have the same pixel format.
        ;* Return:
            ;* [Bitmap]
        Clone(x?, y?, width?, height?, pixelFormat := 0) {
            if (status := (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height))
                ? (DllCall("Gdiplus\GdipCloneBitmapArea", "Float", x, "Float", y, "Float", width, "Float", height, "UInt", pixelFormat || this.GetPixelFormat(), "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int"))
                : (DllCall("Gdiplus\GdipCloneImage", "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int"))) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Bitmap(pBitmap))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDisposeImage", "Ptr", this.Ptr, "Int")
            }
        }

        Width {
            Get {
                return (this.GetWidth())
            }
        }

        ;* Return:
            ;* [Integer]
        GetWidth() {
            if (status := DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", &(width := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (width)
        }

        Height {
            Get {
                return (this.GetHeight())
            }
        }

        ;* Return:
            ;* [Integer]
        GetHeight() {
            if (status := DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", &(height := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (height)
        }

        PixelFormat {
            Get {
                return (this.GetPixelFormat())
            }
        }

        ;* bitmap.GetPixelFormat()
        ;* Return:
            ;* [Integer] - See PixelFormat enumeration.
        GetPixelFormat() {
            if (status := DllCall("Gdiplus\GdipGetImagePixelFormat", "Ptr", this.Ptr, "UInt*", &(pixelFormat := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (pixelFormat)
        }

        ;* Return:
            ;* [Object]
        GetRect(&unit := 0) {
            static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

            if (status := DllCall("Gdiplus\GdipGetImageBounds", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int*", &unit, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
        }

        ;* bitmap.GetHorizontalResolution()
        ;* Return:
            ;* [Integer]
        GetHorizontalResolution() {
            if (status := DllCall("Gdiplus\GdipGetImageHorizontalResolution", "Ptr", this.Ptr, "UInt*", &(xDpi := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (xDpi)
        }

        ;* bitmap.GetVerticalResolution()
        ;* Return:
            ;* [Integer]
        GetVerticalResolution() {
            if (status := DllCall("Gdiplus\GdipGetImageVerticalResolution", "Ptr", this.Ptr, "UInt*", &(yDpi := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (yDpi)
        }

        ;* bitmap.SetResolution(xDpi, yDpi)
        ;* Parameter:
            ;* [Integer] xDpi
            ;* [Integer] yDpi
        SetResolution(xDpi, yDpi) {
            if (status := DllCall("Gdiplus\GdipBitmapSetResolution", "Ptr", this.Ptr, "Float", xDpi, "Float", yDpi, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* bitmap.GetFlags()
        ;* Return:
            ;* [Integer] - See ImageFlags enumeration.
        GetFlags() {
            if (status := DllCall("Gdiplus\GdipGetImageFlags", "Ptr", this.Ptr, "UInt*", &(flags := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (flags)
        }

        ;* Parameter:
            ;* [Integer] x
            ;* [Integer] y
        ;* Return:
            ;* [Integer]
        GetPixel(x, y) {
            if (this.HasProp("BitmapData")) {
                color := NumGet(this.Scan0 + x*4 + y*this.Stride, "UInt")
            }
            else {
                static procAddress := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapGetPixel", "Ptr")

                DllCall(procAddress, "Ptr", this.Ptr, "Int", x, "Int", y, "UInt*", &(color := 0))  ;~ No error handling.
            }

            return (color)
        }

/*
    ** Accessing bytes in various pixel formats: https://stackoverflow.com/a/50359349 **
*/

        ;* Parameter:
            ;* [Integer] x
            ;* [Integer] y
            ;* [Integer] width
            ;* [Integer] height
            ;* [Integer] color
        SetPixel(params*) {
            color := params.Pop()

            if (this.HasProp("BitmapData")) {
                scan0 := this.Scan0, stride := this.Stride

                switch (params.Length) {
                    case 2:
                        Numput("UInt", color, scan0 + Math.Max(params[0], 0)*4 + Math.Max(params[1], 0)*stride)
                    case 4:
                        reset := Math.Max(params[0], 0)
                            , y := Math.Max(params[1], 0), width := Math.Clamp(params[2], 0, NumGet(this.BitmapData.Ptr, "UInt")) - reset, height := Math.Clamp(params[3], 0, NumGet(this.BitmapData.Ptr + 4, "UInt")) - y
                    default:
                        reset := 0
                            , y := 0, width := NumGet(this.BitmapData.Ptr, "UInt"), height := NumGet(this.BitmapData.Ptr + 4, "UInt")
                }

                loop (height) {
                    loop (x := reset, width) {
                        Numput("UInt", color, scan0 + x++*4 + y*stride)  ;~ The Stride data member is negative if the pixel data is stored bottom-up.
                    }

                    y++
                }
            }
            else {
                static procAddress := DllCall("Kernel32\GetProcAddress", "Ptr", DllCall("Kernel32\GetModuleHandle", "Str", "Gdiplus", "Ptr"), "AStr", "GdipBitmapSetPixel", "Ptr")

                switch (params.Length) {
                    case 2:
                        DllCall(procAddress, "Ptr", this.Ptr, "Int", Math.Max(params[0], 0), "Int", Math.Max(params[1], 0), "Int", color)
                    case 4:
                        reset := Math.Max(params[0], 0)
                            , y := Math.Max(params[1], 0), width := Math.Clamp(params[2], 0, this.Width) - reset, height := Math.Clamp(params[3], 0, this.Height) - y
                    default:
                        reset := 0
                            , y := 0, width := this.Width, height := this.Height
                }

                pBitmap := this.Ptr

                loop (height) {
                    loop (x := reset, width) {
                        DllCall(procAddress, "Ptr", pBitmap, "Int", x++, "Int", y, "UInt", color)
                    }

                    y++
                }
            }
        }

        ;* bitmap.ApplyEffect(effect[, x, y, width, height])
        ;* Parameter:
            ;* [Effect] effect
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        ApplyEffect(effect, x?, y?, width?, height?) {
            if (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height)) {
                static rect := Buffer.CreateRect(0, 0, 0, 0, "Int")

                rect.NumPut(0, "Int", x, "Int", y, "Int", width, "Int", height)

                if (status := DllCall("Gdiplus\GdipBitmapApplyEffect", "Ptr", this.Ptr, "Ptr", effect, "Ptr", rect, "UInt", 0, "Ptr*", 0, "Int", 0, "Int")) {
                    throw (ErrorFromStatus(status))
                }
            }
            else if (status := DllCall("Gdiplus\GdipBitmapApplyEffect", "Ptr", this.Ptr, "Ptr", effect, "Ptr", 0, "UInt", 0, "Ptr*", 0, "Int", 0, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ConvertFormat(pixelFormat, dithertype, palettetype, colorPalette, alphaThresholdPercent) {
            if (status := DllCall("Gdiplus\GdipBitmapConvertFormat", "Ptr", this.Ptr, "UInt", pixelFormat, "UInt", dithertype, "UInt", palettetype, "Ptr", colorPalette, "UInt", alphaThresholdPercent, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
                throw (ErrorFromStatus(status))
            }
        }

        ;~ GetHistogram
        ;~ GetHistogramSize

        ;* bitmap.LockBits([x, y, width, height, pixelFormat, lockMode])
        ;* Parameter:
            ;* [Integer] x
            ;* [Integer] y
            ;* [Integer] width
            ;* [Integer] height
            ;* [Integer] pixelFormat - See PixelFormat enumeration.
            ;* [Integer] lockMode - See ImageLockMode enumeration.
        ;* Return:
            ;* [Integer] - Boolean value that indicates if the bitmap was locked.
        LockBits(x := 0, y := 0, width?, height?, lockMode := 0x0003, pixelFormat := 0) {  ;? http://supercomputingblog.com/graphics/using-lockbits-in-gdi/
            if (!this.HasProp("BitmapData")) {
                if (!IsSet(width)) {
                    if (!IsSet(height)) {
                        DllCall("Gdiplus\GdipGetImageDimension", "Ptr", this.Ptr, "Float*", &(width := 0), "Float*", &(height := 0))
                    }
                    else {
                        DllCall("Gdiplus\GdipGetImageWidth", "Ptr", this.Ptr, "UInt*", &(width := 0))
                    }
                }
                else if (!IsSet(height)) {
                    DllCall("Gdiplus\GdipGetImageHeight", "Ptr", this.Ptr, "UInt*", &(height := 0))
                }

                if (status := DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", this.Ptr, "Ptr", Buffer.CreateRect(x, y, width, height, "UInt").Ptr, "UInt", lockMode, "UInt", pixelFormat || this.GetPixelFormat(), "Ptr", (bitmapData := __CreateBitmapData()).Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
                    throw (ErrorFromStatus(status))
                }

                __CreateBitmapData(width := 0, height := 0, stride := 0, pixelFormat := 0x26200A, scan0 := 0) {
                    static Buffer := {Call: (*) => ({Class: "Buffer",
                        __Delete: (this) => (DllCall("Kernel32\HeapFree", "Ptr", DllCall("Kernel32\GetProcessHeap", "Ptr"), "UInt", 0, "Ptr", this.Ptr))})}

                    NumPut("UInt", width, "UInt", height, "Int", stride, "Int", pixelFormat, "Ptr", scan0, (instance := Buffer.Call()).Ptr := DllCall("Kernel32\HeapAlloc", "Ptr", DllCall("Kernel32\GetProcessHeap", "Ptr"), "UInt", 0x00000008, "Ptr", A_PtrSize*2 + 16, "Ptr"))  ;! DllCall("Kernel32\HeapCreate", "UInt", 0x00000004, "Ptr", 0, "Ptr", 0, "Ptr")

                    return (instance)
                }  ;? BITMAPDATA;

                this.Scan0 := NumGet(bitmapData.Ptr, 16, "Ptr"), this.Stride := NumGet(bitmapData.Ptr, 8, "Int")

                return (!!(this.BitmapData := bitmapData))  ;~ LockBits returning too much data: https://github.com/dotnet/runtime/issues/28600.
            }

            return (false)
        }

        ;* bitmap.UnlockBits()
        ;* Return:
            ;* [Integer] - Boolean value that indicates if the bitmap was unlocked.
        UnlockBits() {
            if (this.HasProp("BitmapData")) {
                if (status := DllCall("Gdiplus\GdipBitmapUnlockBits", "Ptr", this.Ptr, "Ptr", this.DeleteProp("BitmapData").Ptr, "Int")) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits
                    throw (ErrorFromStatus(status))
                }

                this.DeleteProp("Scan0"), this.DeleteProp("Stride")

                return (true)
            }

            return (false)
        }

        ;* bitmap.RotateFlip(rotateType)
        ;* Parameter:
            ;* [Integer] rotateType - See RotateFlipType enumeration.
        RotateFlip(rotateType) {
            if (status := DllCall("Gdiplus\GdipImageRotateFlip", "Ptr", this.Ptr, "Int", rotateType, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* bitmap.SaveToFile(file)
        ;* Parameter:
            ;* [String] file
        SaveToFile(file) {
            if (status := DllCall("Gdiplus\GdipGetImageEncodersSize", "UInt*", &(number := 0), "UInt*", &(size := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            if (status := DllCall("Gdiplus\GdipGetImageEncoders", "UInt", number, "UInt", size, "Ptr", (imageCodecInfo := Buffer(size)).Ptr, "Int")) {  ;* Fill a buffer with the available encoders.
                throw (ErrorFromStatus(status))
            }

            loop (extension := RegExReplace(file, ".*(\.\w+)$", "$1"), number) {
                if (InStr(StrGet(imageCodecInfo.NumGet(A_PtrSize*3 + (offset := (48 + A_PtrSize*7)*(A_Index - 1)) + 32, "Ptr"), "UTF-16"), "*" . extension)) {
                    pCodec := imageCodecInfo.Ptr + offset  ;* Get the pointer to the matching encoder.

                    break
                }
            }

            if (!pCodec) {
                throw (Error("Could not find a matching encoder for the specified file format."))
            }

            if (status := DllCall("Gdiplus\GdipSaveImageToFile", "Ptr", this.Ptr, "Ptr", StrPtr(file), "Ptr", pCodec, "UInt", 0, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* bitmap.SaveToStream()
        SaveToStream() {
        }
    }

    ;* GDIp.CreateCachedBitmap(bitmap, graphics)
    ;* Parameter:
        ;* [Bitmap] bitmap
        ;* [Graphics] graphics
    ;* Return:
        ;* [CachedBitmap]
    static CreateCachedBitmap(bitmap, graphics) {
        if (status := DllCall("Gdiplus\GdipCreateCachedBitmap", "Ptr", bitmap, "Ptr", graphics, "Ptr*", &(pCachedBitmap := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.CachedBitmap(pCachedBitmap))
    }

    class CachedBitmap {
        Class := "CachedBitmap"

        __New(pCachedBitmap) {
            this.Ptr := pCachedBitmap
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteCachedBitmap", "Ptr", this.Ptr, "Int")
            }
        }
    }

    ;====================================================== Graphics ==============;

    ;* GDIp.CreateGraphicsFromDC(DC)
    ;* Parameter:
        ;* [DC] DC
    ;* Return:
        ;* [Graphics]
    static CreateGraphicsFromDC(DC) {
        if (status := DllCall("Gdiplus\GdipCreateFromHDC", "Ptr", DC.Handle, "Ptr*", &(pGraphics := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Graphics(pGraphics))
    }

    ;* GDIp.CreateGraphicsFromBitmap(bitmap)
    ;* Parameter:
        ;* [Bitmap] bitmap
    ;* Return:
        ;* [Graphics]
    static CreateGraphicsFromBitmap(bitmap) {
        if (status := DllCall("Gdiplus\GdipGetImageGraphicsContext", "Ptr", bitmap, "Ptr*", &(pGraphics := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Graphics(pGraphics))
    }

    ;* GDIp.CreateGraphicsFromWindow(hWnd[, useICM])
    ;* Parameter:
        ;* [Integer] hWnd
        ;* [Integer] useICM
    ;* Return:
        ;* [Graphics]
    static CreateGraphicsFromWindow(hWnd, useICM := false) {
        if (status := (useICM)
            ? (DllCall("Gdiplus\GdipCreateFromHWNDICM", "Ptr", hWnd, "Ptr*", &(pGraphics := 0), "Int"))
            : (DllCall("Gdiplus\GdipCreateFromHWND", "Ptr", hWnd, "Ptr*", &(pGraphics := 0), "Int"))) {
            throw (ErrorFromStatus(status))
        }

        return (this.Graphics(pGraphics))
    }

    class Graphics {
        Class := "Graphics", States := []

        __New(pGraphics) {
            this.Ptr := pGraphics
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteGraphics", "Ptr", this.Ptr, "Int")
            }
        }

        ;* graphics.IsPointVisible[x, y]
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
        ;* Return:
            ;* [Integer]
        IsPointVisible(x, y) {
            if (status := DllCall("Gdiplus\GdipIsVisiblePoint", "Ptr", this.Ptr, "Float", x, "Float", y, "Int*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* graphics.IsRectVisible[x, y, width, height]
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        ;* Return:
            ;* [Integer]
        IsRectVisible(x, y, width, height) {
            if (status := DllCall("Gdiplus\GdipIsVisibleRect", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* graphics.IsClipEmpty
        ;* Return:
            ;* [Integer]
        IsClipEmpty() {
            if (status := DllCall("Gdiplus\GdipIsClipEmpty", "Ptr", this.Ptr, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* graphics.IsVisibleClipEmpty
        ;* Return:
            ;* [Integer]
        IsVisibleClipEmpty() {
            if (status := DllCall("Gdiplus\GdipIsVisibleClipEmpty", "Ptr", this.Ptr, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        CompositingMode {
            Get {
                return (this.GetCompositingMode())
            }

            Set {
                this.SetCompositingMode(value)

                return (value)
            }
        }

        ;* graphics.GetCompositingMode()
        ;* Return:
            ;* [Integer] - See CompositingMode enumeration.
        GetCompositingMode() {
            if (status := DllCall("Gdiplus\GdipGetCompositingMode", "Ptr", this.Ptr, "UInt*", &(compositingMode := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (compositingMode)
        }

        ;* graphics.SetCompositingMode(compositingMode)
        ;* Parameter:
            ;* [Integer] compositingMode - See CompositingMode enumeration.
        SetCompositingMode(compositingMode) {
            if (status := DllCall("Gdiplus\GdipSetCompositingMode", "Ptr", this.Ptr, "UInt", compositingMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        CompositingQuality {
            Get {
                return (this.GetCompositingQuality())
            }

            Set {
                this.SetCompositingQuality(value)

                return (value)
            }
        }

        ;* graphics.GetCompositingQuality()
        ;* Return:
            ;* [Integer] - See CompositingQuality enumeration.
        GetCompositingQuality() {
            if (status := DllCall("Gdiplus\GdipGetCompositingQuality", "Ptr", this.Ptr, "UInt*", &(compositingQuality := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (compositingQuality)
        }

        ;* graphics.SetCompositingQuality(compositingQuality)
        ;* Parameter:
            ;* [Integer] compositingQuality - See CompositingQuality enumeration.
        SetCompositingQuality(compositingQuality) {
            if (status := DllCall("Gdiplus\GdipSetCompositingQuality", "Ptr", this.Ptr, "UInt", compositingQuality, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        InterpolationMode {
            Get {
                return (this.GetInterpolationMode())
            }

            Set {
                this.SetInterpolationMode(value)

                return (value)
            }
        }

        ;* graphics.GetInterpolationMode()
        ;* Return:
            ;* [Integer] - See InterpolationMode enumeration.
        GetInterpolationMode() {
            if (status := DllCall("Gdiplus\GdipGetInterpolationMode", "Ptr", this.Ptr, "UInt*", &(interpolationMode := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (interpolationMode)
        }

        ;* graphics.SetInterpolationMode(interpolationMode)
        ;* Parameter:
            ;* [Integer] interpolationMode - See InterpolationMode enumeration.
        SetInterpolationMode(interpolationMode) {
            if (status := DllCall("Gdiplus\GdipSetInterpolationMode", "Ptr", this.Ptr, "UInt", interpolationMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        PixelOffsetMode {
            Get {
                return (this.GetPixelOffsetMode())
            }

            Set {
                this.SetPixelOffsetMode(value)

                return (value)
            }
        }

        ;* graphics.GetPixelOffsetMode()
        ;* Return:
            ;* [Integer] - See PixelOffsetMode enumeration.
        GetPixelOffsetMode() {
            if (status := DllCall("Gdiplus\GdipGetPixelOffsetMode", "Ptr", this.Ptr, "Int*", &(pixelOffsetMode := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (pixelOffsetMode)
        }

        ;* graphics.SetPixelOffsetMode(unit)
        ;* Parameter:
            ;* [Integer] pixelOffsetMode - See PixelOffsetMode enumeration.
        SetPixelOffsetMode(unit) {
            if (status := DllCall("Gdiplus\GdipSetPixelOffsetMode", "Ptr", this.Ptr, "Int", unit, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        SmoothingMode {
            Get {
                return (this.GetSmoothingMode())
            }

            Set {
                this.SetSmoothingMode(value)

                return (value)
            }
        }

        ;* graphics.GetSmoothingMode()
        ;* Return:
            ;* [Integer] - See SmoothingMode enumeration.
        GetSmoothingMode() {
            if (status := DllCall("Gdiplus\GdipGetSmoothingMode", "Ptr", this.Ptr, "UInt*", &(smoothingMode := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (smoothingMode)
        }

        ;* graphics.SetSmoothingMode(smoothingMode)
        ;* Parameter:
            ;* [Integer] smoothingMode - See SmoothingMode enumeration.
        SetSmoothingMode(smoothingMode) {
            if (status := DllCall("Gdiplus\GdipSetSmoothingMode", "Ptr", this.Ptr, "UInt", smoothingMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.GetPageScale()
        ;* Return:
            ;* [Float] - The scaling factor for the page transformation of this graphics object.
        GetPageScale() {
            if (status := DllCall("Gdiplus\GdipGetPageScale", "Ptr", this.Ptr, "Float*", &(scale := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (scale)
        }

        ;* graphics.SetPageScale(scale)
        ;* Parameter:
            ;* [Float] scale - Sets the scaling factor for the page transformation of this graphics object.
        SetPageScale(scale) {
            if (status := DllCall("Gdiplus\GdipSetPageScale", "Ptr", this.Ptr, "Float", scale, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.GetPageUnit()
        ;* Return:
            ;* [Integer] - See Unit enumeration.
        GetPageUnit() {
            if (status := DllCall("Gdiplus\GdipGetPageUnit", "Ptr", this.Ptr, "Int*", &(unit := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (unit)
        }

        ;* graphics.SetPageUnit(unit)
        ;* Parameter:
            ;* [Integer] unit - See Unit enumeration.
        SetPageUnit(unit) {
            if (status := DllCall("Gdiplus\GdipSetPageUnit", "Ptr", this.Ptr, "Int", unit, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.GetRenderingOrigin()
        ;* Return:
            ;* [Array]
        GetRenderingOrigin() {
            if (status := DllCall("Gdiplus\GdipGetRenderingOrigin", "Ptr", this.Ptr, "Int*", &(x := 0), "Int*", &(y := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (Vec2(x, y))
        }

        ;* graphics.SetRenderingOrigin(x, y)
        ;* Parameter:
            ;* [Integer] x
            ;* [Integer] y
        SetRenderingOrigin(x, y) {
            if (status := DllCall("Gdiplus\GdipSetRenderingOrigin", "Ptr", this.Ptr, "Int", x, "Int", y, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.GetTextContrast()
        ;* Return:
            ;* [Integer] - A number between 0 and 12, which defines the value of contrast used for antialiasing text.
        GetTextContrast() {
            if (status := DllCall("Gdiplus\GdipGetTextContrast", "Ptr", this.Ptr, "UInt*", &(contrast := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (contrast)
        }

        ;* graphics.SetTextContrast(contrast)
        ;* Parameter:
            ;* [Integer] contrast - A number between 0 and 12, which defines the value of contrast used for antialiasing text.
        SetTextContrast(contrast) {
            if (status := DllCall("Gdiplus\GdipSetTextContrast", "Ptr", this.Ptr, "UInt", contrast, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.GetTextRenderingHint()
        ;* Return:
            ;* [Integer] - See TextRenderingHint enumeration.
        GetTextRenderingHint() {
            if (status := DllCall("Gdiplus\GdipGetTextRenderingHint", "Ptr", this.Ptr, "UInt*", &(hint := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (hint)
        }

        ;* graphics.SetTextRenderingHint(hint)
        ;* Parameter:
            ;* [Integer] hint - See TextRenderingHint enumeration.
        SetTextRenderingHint(hint) {
            if (status := DllCall("Gdiplus\GdipSetTextRenderingHint", "Ptr", this.Ptr, "UInt", hint, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;------------------------------------------------------  Control  --------------;

        ;* graphics.Flush(intention)
        ;* Parameter:
            ;* [Integer] intention - Element that specifies whether pending operations are flushed immediately (not executed) or executed as soon as possible. See FlushIntention enumeration.
        Flush(intention) {
            if (status := DllCall("Gdiplus\GdipFlush", "Ptr", this.Ptr, "Int", intention, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* Note:
            ;~ When you call GdipEndContainer, all information blocks placed on the stack (by GdipSaveGraphics or by GdipBeginContainer) after the corresponding call to GdipBeginContainerare removed from the stack. Likewise, when you call GdipRestoreGraphics, all information blocks placed on the stack (by GdipSaveGraphics or by GdipBeginContainer) after the corresponding call to GdipSaveGraphics are removed from the stack.
        Begin(dstRect?, srcRect?, unit := 2) {
            if (IsSet(dstRect) && IsSet(srcRect)) {
                if (status := DllCall("Gdiplus\GdipBeginContainer", "Ptr", this.Ptr, "Ptr", dstRect, "Ptr", srcRect, "Int", unit, "UInt*", &(state := 0), "Int")) {
                    throw (ErrorFromStatus(status))
                }
            }
            else if (status := DllCall("Gdiplus\GdipBeginContainer2", "Ptr", this.Ptr, "UInt*", &(state := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (state)
        }

        End(state) {
            if (status := DllCall("Gdiplus\GdipEndContainer", "Ptr", this.Ptr, "UInt", state, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.Save()
        ;* Return:
            ;* [Integer]
        Save() {
            if (status := DllCall("Gdiplus\GdipSaveGraphics", "Ptr", this.Ptr, "UInt*", &(state := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            this.States.Push(state)
            return (state)
        }

        ;* graphics.Restore([state])
        ;* Parameter:
            ;* [Integer] state
        ;* Return:
            ;* [Integer]
        Restore(state?) {
            if (status := DllCall("Gdiplus\GdipRestoreGraphics", "Ptr", this.Ptr, "UInt", (IsSet(state)) ? (this.States.RemoveAt(this.States.IndexOf(state))) : (this.States.Shift()), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (state)
        }

        ;* graphics.Clear([color])
        ;* Parameter:
            ;* [Integer] color
        Clear(color := 0x00000000) {
            if (status := DllCall("Gdiplus\GdipGraphicsClear", "Ptr", this.Ptr, "UInt", color, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;-----------------------------------------------------  Transform  -------------;

        ;* graphics.GetTransform()
        ;* Return:
            ;* [Matrix]
        GetTransform() {
            if (status := DllCall("Gdiplus\GdipGetWorldTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Matrix(pMatrix))
        }

        ;* graphics.SetTransform(matrix)
        ;* Parameter:
            ;* [Matrix] matrix
        SetTransform(matrix) {
            if (status := DllCall("Gdiplus\GdipSetWorldTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.TranslateTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        TranslateTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipTranslateWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.RotateTransform(angle[, matrixOrder])
        ;* Parameter:
            ;* [Float] angle - Angle of rotation (in degrees).
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        RotateTransform(angle, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipRotateWorldTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.MultiplyTransform(matrix[, matrixOrder])
        ;* Parameter:
            ;* [Matrix] matrix
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        MultiplyTransform(matrix, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipMultiplyWorldTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.ScaleTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        ScaleTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipScaleWorldTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.ResetTransform()
        ResetTransform() {
            if (status := DllCall("Gdiplus\GdipResetWorldTransform", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.ResetPageTransform()
        ResetPageTransform() {
            if (status := DllCall("Gdiplus\GdipResetPageTransform", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;-------------------------------------------------------  Image  ---------------;

        ;* graphics.DrawImage(bitmap[, x, y])
        ;* Parameter:
            ;* [Bitmap] bitmap
            ;* [Float] x
            ;* [Float] y
        DrawImage(bitmap, x := 0, y := 0) {
            if (status := DllCall("Gdiplus\GdipDrawImage", "Ptr", this.Ptr, "Ptr", bitmap, "Float", x, "Float", y, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawImageFX(bitmap, matrix, effect[, x, y, width, height, imageAttributes, unit])
        ;* Parameter:
            ;* [Bitmap] bitmap
            ;* [Matrix] matrix
            ;* [Effect] effect
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Imageattributes] imageAttributes
            ;* [Integer] unit - See Unit enumeration.
        DrawImageFX(bitmap, matrix, effect, x?, y?, width?, height?, imageAttributes := 0, unit := 2) {
            if (IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height)) {
                static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

                rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

                if (status := DllCall("Gdiplus\GdipDrawImageFX", "Ptr", this.Ptr, "Ptr", bitmap, "Ptr", rect, "Ptr", matrix, "Ptr", effect, "Ptr", imageAttributes, "Int", unit, "Int")) {
                    throw (ErrorFromStatus(status))
                }
            }
            else if (status := DllCall("Gdiplus\GdipDrawImageFX", "Ptr", this.Ptr, "Ptr", bitmap, "Ptr", 0, "Ptr", matrix, "Ptr", effect, "Ptr", imageAttributes, "Int", unit, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawImageRect(bitmap, x, y, width, height)
        ;* Parameter:
            ;* [Bitmap] bitmap
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        DrawImageRect(bitmap, x, y, width, height) {
            if (status := DllCall("Gdiplus\GdipDrawImageRect", "Ptr", this.Ptr, "Ptr", bitmap, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawImageRectRect(bitmap, dx, dy, dWidth, dHeight, sx, sy, sWidth, sHeight[, imageAttributes, unit])
        ;* Parameter:
            ;* [Bitmap] bitmap
            ;* [Float] dx
            ;* [Float] dy
            ;* [Float] dWidth
            ;* [Float] dHeight
            ;* [Float] sx
            ;* [Float] sy
            ;* [Float] sWidth
            ;* [Float] sHeight
            ;* [ImageAttributes] imageAttributes
            ;* [Integer] unit - See Unit enumeration.
        DrawImageRectRect(bitmap, dx, dy, dWidth, dHeight, sx, sy, sWidth, sHeight, imageAttributes := 0, unit := 2) {
            if (status := DllCall("Gdiplus\GdipDrawImageRectRect", "Ptr", this.Ptr, "Ptr", bitmap, "Float", dx, "Float", dy, "Float", dWidth, "Float", dHeight, "Float", sx, "Float", sy, "Float", sWidth, "Float", sHeight, "Int", unit, "Ptr", imageAttributes, "Ptr", 0, "Ptr", 0, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;------------------------------------------------------- Bitmap ---------------;

        ;* graphics.DrawCachedBitmap(bitmap[, x, y])
        ;* Parameter:
            ;* [CachedBitmap] bitmap
            ;* [Integer] x
            ;* [Integer] y
        DrawCachedBitmap(bitmap, x := 0, y := 0) {
            if (status := DllCall("Gdiplus\GdipDrawCachedBitmap", "Ptr", this.Ptr, "Ptr", bitmap, "Int", x, "Int", y, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;-------------------------------------------------------- Fill ----------------;

        ;~FillClosedCurve
        ;~FillEllipse
        ;~FillPath
        ;~FillPie
        ;~FillPolygon
        ;~FillRectangle
        ;~FillRoundedRectangle
        ;~FillRegion

        ;* graphics.FillClosedCurve(brush, points*[, tension, fillMode])
        ;* Parameter:
            ;* [Brush] brush
            ;* [Array]* points
            ;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
            ;* [Integer] fillMode - See FillMode enumeration.
        FillClosedCurve(brush, points*) {
            if (IsNumber(points[-1])) {
                fillMode := (IsNumber(points[-2])) ? (points.Pop()) : (0), tension := points.Pop()
            }

            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := (tension)
                ? (DllCall("Gdiplus\GdipFillClosedCurve2", "Ptr", this.Ptr, "Ptr", brush, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "UInt", fillMode, "Int"))
                : (DllCall("Gdiplus\GdipFillClosedCurve", "Ptr", this.Ptr, "Ptr", brush, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.FillEllipse(brush, x, y, width, height)
        ;* Parameter:
            ;* [Brush] brush
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        FillEllipse(brush, x, y, width, height) {
            if (status := DllCall("Gdiplus\GdipFillEllipse", "Ptr", this.Ptr, "Ptr", brush, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.FillPath(brush, path)
        ;* Parameter:
            ;* [Brush] brush
            ;* [Path] path
        FillPath(brush, path) {
            if (status := DllCall("Gdiplus\GdipFillPath", "Ptr", this.Ptr, "Ptr", brush, "Ptr", path, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.FillPie(brush, x, y, width, height, startAngle, sweepAngle)
        ;* Parameter:
            ;* [Brush] brush
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Float] startAngle
            ;* [Float] sweepAngle
        FillPie(brush, x, y, width, height, startAngle, sweepAngle) {
            if (status := DllCall("Gdiplus\GdipFillPie", "Ptr", this.Ptr, "Ptr", brush, "Float", x, "Float", y, "Float", width, "Float", height, "Float", startAngle, "Float", sweepAngle, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.FillPolygon(brush, points*[, fillMode])
        ;* Parameter:
            ;* [Brush] brush
            ;* [Array]* points
            ;* [Integer] fillMode - See FillMode enumeration.
        FillPolygon(brush, points*) {
            fillMode := (IsNumber(points[-1])) ? (points.Pop()) : (0)

            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := DllCall("Gdiplus\GdipFillPolygon", "Ptr", this.Ptr, "Ptr", brush, "Ptr", struct.Ptr, "Int", length, "UInt", fillMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.FillRectangle(brush, x, y, width, height)
        ;* Parameter:
            ;* [Brush] brush
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        FillRectangle(brush, x, y, width, height) {
            if (status := DllCall("Gdiplus\GdipFillRectangle", "Ptr", this.Ptr, "Ptr", brush, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.FillRoundedRectangle(brush, x, y, width, height, radius)
        ;* Parameter:
            ;* [Brush] brush
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Float] radius - Radius of the rounded corners.
        FillRoundedRectangle(brush, x, y, width, height, radius) {
            state := this.Save()
                , pGraphics := this.Ptr

            DllCall("Gdiplus\GdipSetPixelOffsetMode", "Ptr", pGraphics, "Int", 2)

            (path := GDIp.CreatePath()).AddRoundedRectangle(x, y, width, height, radius)

            if (status := DllCall("Gdiplus\GdipFillPath", "Ptr", pGraphics, "Ptr", brush, "Ptr", path.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            this.Restore(state)
        }

        ;* graphics.FillRegion(brush, region)
        ;* Parameter:
            ;* [Brush] brush
            ;* [Region] region
        FillRegion(brush, region) {
            if (status := DllCall("Gdiplus\GdipFillRegion", "Ptr", this.Ptr, "Ptr", brush, "Ptr", region, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;-------------------------------------------------------- Draw ----------------;

        ;DrawArc
        ;DrawBezier
        ;DrawBeziers
        ;DrawClosedCurve
        ;DrawCurve
        ;DrawEllipse
        ;DrawLine
        ;DrawLines
        ;DrawPath
        ;DrawPie
        ;DrawPolygon
        ;DrawRectangle
        ;DrawRoundedRectangle

        ;* graphics.DrawArc(pen, x, y, width, height, startAngle, sweepAngle)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Float] startAngle
            ;* [Float] sweepAngle
        DrawArc(pen, x, y, width, height, startAngle, sweepAngle) {
            try {
                offset := pen.Width
            }
            catch {
                if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
                    throw (ErrorFromStatus(status))
                }
            }

            if (status := DllCall("Gdiplus\GdipDrawArc", "Ptr", this.Ptr, "Ptr", pen, "Float", x, "Float", y, "Float", width - offset, "Float", height - offset, "Float", startAngle, "Float", sweepAngle, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawBezier(pen, point1, point2, point3, point4)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Array] point1
            ;* [Array] point2
            ;* [Array] point3
            ;* [Array] point4
        DrawBezier(pen, point1, point2, point3, point4) {
            if (status := DllCall("Gdiplus\GdipDrawBezier", "Ptr", this.Ptr, "Ptr", pen, "Float", point1[0], "Float", point1[1], "Float", point2[0], "Float", point2[1], "Float", point3[0], "Float", point3[1], "Float", point4[0], "Float", point4[1], "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawBeziers(pen, points*)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Array]* points
        ;* Note:
            ;~ The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
        DrawBeziers(pen, points*) {
            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := DllCall("Gdiplus\GdipDrawBeziers", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawClosedCurve(pen, points*[, tension])
        ;* Parameter:
            ;* [Pen] pen
            ;* [Array]* points
            ;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
        DrawClosedCurve(pen, points*) {
            if (IsNumber(points[-1])) {
                tension := points.Pop()
            }

            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := (tension)
                ? (DllCall("Gdiplus\GdipDrawClosedCurve2", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "Int"))
                : (DllCall("Gdiplus\GdipDrawClosedCurve", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawCurve(pen, points*[, tension])
        ;* Parameter:
            ;* [Pen] pen
            ;* [Array]* points
            ;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
        DrawCurve(pen, points*) {
            if (IsNumber(points[-1])) {
                tension := points.Pop()
            }

            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := (tension)
                ? (DllCall("Gdiplus\GdipDrawCurve2", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "Int"))
                : (DllCall("Gdiplus\GdipDrawCurve", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawEllipse(pen, x, y, width, height)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        DrawEllipse(pen, x, y, width, height) {
            try {
                offset := pen.Width
            }
            catch {
                if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
                    throw (ErrorFromStatus(status))
                }
            }

            if (status := DllCall("Gdiplus\GdipDrawEllipse", "Ptr", this.Ptr, "Ptr", pen, "Float", x, "Float", y, "Float", width - offset, "Float", height - offset, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawLine(pen, point1, point2)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Array] point1
            ;* [Array] point2
        DrawLine(pen, x1, y1, x2, y2) {
            if (status := DllCall("Gdiplus\GdipDrawLine", "Ptr", this.Ptr, "Ptr", pen, "Float", x1, "Float", y1, "Float", x2, "Float", y2, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawLines(pen, points*)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Array]* points
        DrawLines(pen, points*) {
            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := DllCall("Gdiplus\GdipDrawLines", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawPath(pen, path)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Path] path
        DrawPath(pen, path) {
            if (status := DllCall("Gdiplus\GdipDrawPath", "Ptr", this.Ptr, "Ptr", pen, "Ptr", path.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawPie(pen, x, y, width, height, startAngle, startAngle, sweepAngle)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Float] startAngle
            ;* [Float] sweepAngle
        DrawPie(pen, x, y, width, height, startAngle, sweepAngle) {
            try {
                offset := pen.Width
            }
            catch {
                if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
                    throw (ErrorFromStatus(status))
                }
            }

            if (status := DllCall("Gdiplus\GdipDrawPie", "Ptr", this.Ptr, "Ptr", pen, "Float", x, "Float", y, "Float", width - offset, "Float", height - offset, "Float", startAngle, "Float", sweepAngle, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawPolygon(pen, points*)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Array]* points
        DrawPolygon(pen, points*) {
            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := DllCall("Gdiplus\GdipDrawPolygon", "Ptr", this.Ptr, "Ptr", pen, "Ptr", struct.Ptr, "UInt", length, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawRectangle(pen, x, y, width, height)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        DrawRectangle(pen, x, y, width, height) {
            try {
                offset := pen.Width
            }
            catch {
                if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
                    throw (ErrorFromStatus(status))
                }
            }

            if (status := DllCall("Gdiplus\GdipDrawRectangle", "Ptr", this.Ptr, "Ptr", pen, "Float", x, "Float", y, "Float", width - offset, "Float", height - offset, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* graphics.DrawRoundedRectangle(pen, x, y, width, height, radius)
        ;* Parameter:
            ;* [Pen] pen
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Float] radius - Radius of the rounded corners.
        DrawRoundedRectangle(pen, x, y, width, height, radius) {
            try {
                offset := pen.Width
            }
            catch {
                if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", pen, "Float*", &(offset := 0), "Int")) {
                    throw (ErrorFromStatus(status))
                }
            }

            diameter := radius*2
                , width -= diameter + offset, height -= diameter + offset

            DllCall("Gdiplus\GdipCreatePath", "UInt", 0, "Ptr*", &(pPath := 0))

            DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y, "Float", diameter, "Float", diameter, "Float", 180, "Float", 90)
            DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y, "Float", diameter, "Float", diameter, "Float", 270, "Float", 90)
            DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 0, "Float", 90)
            DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 90, "Float", 90)
            DllCall("Gdiplus\GdipClosePathFigure", "Ptr", pPath)

            if (status := DllCall("Gdiplus\GdipDrawPath", "Ptr", this.Ptr, "Ptr", pen, "Ptr", pPath, "Int")) {
                throw (ErrorFromStatus(status))
            }

            DllCall("Gdiplus\GdipDeletePath", "Ptr", pPath)
        }
    }

    ;=======================================================  Brush  ===============;
    ;----------------------------------------------------- SolidBrush -------------;

    ;* GDIp.CreateSolidBrush(color)
    ;* Parameter:
        ;* [Integer] color
    ;* Return:
        ;* [Brush]
    static CreateSolidBrush(color)  {
        if (status := DllCall("Gdiplus\GdipCreateSolidFill", "UInt", color, "Ptr*", &(pBrush := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.SolidBrush(pBrush))
    }

    class SolidBrush {
        Class := "Brush"

        __New(pBrush) {
            this.Ptr := pBrush
        }

        ;* brush.Clone()
        ;* Return:
            ;* [Brush]
        Clone() {
            if (status := DllCall("Gdiplus\GdipCloneBrush", "Ptr", this.Ptr, "Ptr*", &(pBrush := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.SolidBrush(pBrush))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteBrush", "Ptr", this.Ptr, "Int")
            }
        }

        Color {
            Get {
                return (this.GetColor())
            }

            Set {
                this.SetColor(value)

                return (value)
            }
        }

        ;* brush.GetColor()
        ;* Return:
            ;* [Integer]
        GetColor() {
            if (status := DllCall("Gdiplus\GdipGetSolidFillColor", "Ptr", this.Ptr, "UInt*", &(color := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (color)
        }

        ;* brush.SetColor(color)
        ;* Parameter:
            ;* [Integer] color
        SetColor(color) {
            if (status := DllCall("Gdiplus\GdipSetSolidFillColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        Type {
            Get {
                return (this.GetType())
            }
        }

        ;* brush.GetType()
        ;* Return:
            ;* [Integer] - See BrushType enumeration.
        GetType() {
            if (status := DllCall("Gdiplus\GdipGetPenFillType", "Ptr", this.Ptr, "Int*", &(type := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (type)
        }
    }

    ;----------------------------------------------------- HatchBrush -------------;

    ;* GDIp.CreateHatchBrush(foregroundColor, backgroundColor[, style])
    ;* Parameter:
        ;* [Integer] foregroundColor
        ;* [Integer] backgroundColor
        ;* [Integer] style - See HatchStyle enumeration.
    ;* Return:
        ;* [Brush]
    static CreateHatchBrush(foregroundColor, backgroundColor, style := 0) {
        if (status := DllCall("Gdiplus\GdipCreateHatchBrush", "Int", style, "UInt", foregroundColor, "UInt", backgroundColor, "Ptr*", &(pBrush := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.HatchBrush(pBrush))
    }

    class HatchBrush {
        Class := "Brush"

        __New(pBrush) {
            this.Ptr := pBrush
        }

        ;* brush.Clone()
        ;* Return:
            ;* [Brush]
        Clone() {
            if (status := DllCall("Gdiplus\GdipCloneBrush", "Ptr", this.Ptr, "Ptr*", &(pBrush := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.HatchBrush(pBrush))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteBrush", "Ptr", this.Ptr, "Int")
            }
        }

        ForegroundColor {
            Get {
                return (this.GetForegroundColor())
            }
        }

        ;* hatchBrush.GetForegroundColor()
        ;* Return:
            ;* [Integer]
        GetForegroundColor() {
            if (status := DllCall("Gdiplus\GdipGetHatchForegroundColor", "Ptr", this.Ptr, "UInt*", &(foregroundColor := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (foregroundColor)
        }

        BackgroundColor {
            Get {
                return (this.GetBackgroundColor())
            }
        }

        ;* hatchBrush.GetBackgroundColor()
        ;* Return:
            ;* [Integer]
        GetBackgroundColor() {
            if (status := DllCall("Gdiplus\GdipGetHatchBackgroundColor", "Ptr", this.Ptr, "UInt*", &(backgroundColor := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (backgroundColor)
        }

        Style {
            Get {
                return (this.GetStyle())
            }
        }

        ;* hatchBrush.Style
        ;* Return:
            ;* [Integer] - See HatchStyle enumeration.
        GetStyle() {
            if (status := DllCall("Gdiplus\GdipGetHatchStyle", "Ptr", this.Ptr, "Int*", &(style := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (style)
        }

        Type {
            Get {
                return (this.GetType())
            }
        }

        ;* brush.GetType()
        ;* Return:
            ;* [Integer] - See BrushType enumeration.
        GetType() {
            if (status := DllCall("Gdiplus\GdipGetPenFillType", "Ptr", this.Ptr, "Int*", &(type := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (type)
        }
    }

    ;---------------------------------------------------- TextureBrush ------------;

    ;* GDIp.CreateTextureBrush(bitmap[, wrapMode, x, y, width, height, imageAttributes])
    ;* Parameter:
        ;* [Bitmap] bitmap
        ;* [Integer] wrapMode - See WrapMode enumeration.
        ;* [Float] x
        ;* [Float] y
        ;* [Float] width
        ;* [Float] height
        ;* [ImageAttributes] imageAttributes
    ;* Return:
        ;* [Brush]
    static CreateTextureBrush(bitmap, wrapMode := 0, x?, y?, width?, height?, imageAttributes?) {
        if (!(IsSet(x) && IsSet(y) && IsSet(width) && IsSet(height))) {
            if (status := DllCall("Gdiplus\GdipCreateTexture", "Ptr", bitmap, "UInt", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
        else if (IsSet(imageAttributes)) {
            if (status := DllCall("Gdiplus\GdipCreateTextureIA", "Ptr", bitmap, "Ptr", imageAttributes, "Float", x, "Float", y, "Float", width, "Float", height, "Ptr*", &(pBrush := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            if (status := DllCall("Gdiplus\GdipSetTextureWrapMode", "Ptr", pBrush, "Int", wrapMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
        else {
            if (status := DllCall("Gdiplus\GdipCreateTexture2", "Ptr", bitmap, "UInt", wrapMode, "Float", x, "Float", y, "Float", width, "Float", height, "Ptr*", &(pBrush := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        return (this.TextureBrush(pBrush))
    }

    class TextureBrush extends GDIp.SolidBrush {

        Bitmap {
            Get {
                return (this.GetBitmap())
            }
        }

        ;* textureBrush.GetBitmap()
        ;* Return:
            ;* [Bitmap]
        GetBitmap() {
            if (status := DllCall("Gdiplus\GdipGetTextureImage", "Ptr", this.Ptr, "Ptr*", &(pBitmap := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Bitmap(pBitmap))
        }

        WrapMode {
            Get {
                return (this.GetWrapMode())
            }

            Set {
                this.SetWrapMode(value)

                return (value)
            }
        }

        ;* textureBrush.GetWrapMode()
        ;* Return:
            ;* [Integer] - See WrapMode enumeration.
        GetWrapMode() {
            if (status := DllCall("Gdiplus\GdipGetTextureWrapMode", "Ptr", this.Ptr, "Int*", &(wrapMode := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (wrapMode)
        }

        ;* textureBrush.SetWrapMode(wrapMode)
        ;* Parameter:
            ;* [Integer] wrapMode - See WrapMode enumeration.
        SetWrapMode(wrapMode) {
            if (status := DllCall("Gdiplus\GdipSetTextureWrapMode", "Ptr", this.Ptr, "Int", wrapMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* textureBrush.GetTransform()
        ;* Return:
            ;* [Matrix]
        GetTransform() {
            if (status := DllCall("Gdiplus\GdipGetTextureTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Matrix(pMatrix))
        }

        ;* textureBrush.SetTransform(matrix)
        ;* Parameter:
            ;* [Matrix] matrix
        SetTransform(matrix) {
            if (status := DllCall("Gdiplus\GdipSetTextureTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* textureBrush.TranslateTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        TranslateTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipTranslateTextureTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* textureBrush.RotateTransform(angle[, matrixOrder])
        ;* Parameter:
            ;* [Float] angle
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        RotateTransform(angle, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipRotateTextureTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* textureBrush.MultiplyTransform(matrix[, matrixOrder])
        ;* Parameter:
            ;* [Matrix] matrix
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        MultiplyTransform(matrix, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipMultiplyTextureTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* textureBrush.ScaleTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder - See MatrixOrder enumeration.
        ScaleTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipScaleTextureTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* textureBrush.ResetTransform()
        ResetTransform() {
            if (status := DllCall("Gdiplus\GdipResetTextureTransform", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
    }

    ;-----------------------------------------------------  PathBrush  -------------;

    ;* GDIp.CreatePathBrush(objects*[, wrapMode])
    ;* Parameter:
        ;* [Array]* objects
        ;* [Integer] wrapMode - See WrapMode enumeration.
    ;* Return:
        ;* [Brush]
    static CreatePathBrush(objects*)  {
        wrapMode := (IsNumber(objects[-1])) ? (objects.Pop()) : (0)

        for index, object in (points := Buffer((length := objects.Length)*8), objects) {
            points.NumPut(index*8, "Float", object[0], "Float", object[1])
        }

        if (status := DllCall("Gdiplus\GdipCreatePathGradient", "Ptr", points.Ptr, "Int", length, "Int", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.PathBrush(pBrush))
    }

    ;* GDIp.CreatePathBrushFromPath(path)
    ;* Parameter:
        ;* [Path] path
    ;* Return:
        ;* [Brush]
    static CreatePathBrushFromPath(path) {
        if (status := DllCall("Gdiplus\GdipCreatePathGradientFromPath", "Ptr", path, "Ptr*", &(pBrush := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.PathBrush(pBrush))
    }

    class PathBrush extends GDIp.SolidBrush {

        WrapMode {
            Get {
                return (this.GetWrapMode())
            }

            Set {
                this.SetWrapMode(value)

                return (value)
            }
        }

        ;* pathBrush.GetWrapMode()
        ;* Return:
            ;* [Integer] - See WrapMode enumeration.
        GetWrapMode() {
            if (status := DllCall("Gdiplus\GdipGetPathGradientWrapMode", "Ptr", this.Ptr, "Int*", &(wrapMode := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (wrapMode)
        }

        ;* pathBrush.SetWrapMode(wrapMode)
        ;* Parameter:
            ;* [Integer] wrapMode - See WrapMode enumeration.
        SetWrapMode(wrapMode) {
            if (status := DllCall("Gdiplus\GdipSetPathGradientWrapMode", "Ptr", this.Ptr, "Int", wrapMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.GetCenterColor()
        ;* Return:
            ;* [Integer]
        GetCenterColor() {
            if (status := DllCall("Gdiplus\GdipGetPathGradientCenterColor", "Ptr", this.Ptr, "UInt*", &(color := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (color)
        }

        ;* pathBrush.SetCenterColor(color)
        ;* Parameter:
            ;* [Integer] color
        SetCenterColor(color) {
            if (status := DllCall("Gdiplus\GdipSetPathGradientCenterColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.GetCenterPoint()
        ;* Return:
            ;* [Object]
        GetCenterPoint() {
            static point := Buffer(8)

            if (status := DllCall("Gdiplus\GdipGetPathGradientCenterPoint", "Ptr", this.Ptr, "Ptr", point.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (Vec2(point.NumGet(0, "Float"), point.NumGet(4, "Float")))
        }

        ;* pathBrush.SetCenterPoint(x, y)
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
        SetCenterPoint(x, y) {
            static point := Buffer(8)

            point.NumPut(0, "Float", x, "Float", y)

            if (status := DllCall("Gdiplus\GdipSetPathGradientCenterPoint", "Ptr", this.Ptr, "Ptr", point.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.GetRect()
        ;* Return:
            ;* [Object]
        GetRect() {
            static rect := Buffer(16)

            if (status := DllCall("Gdiplus\GdipGetPathGradientRect", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
        }

        ;* pathBrush.GetFocusScales()
        ;* Return:
            ;* [Object]
        GetFocusScales() {
            static point := Buffer(8)

            if (status := DllCall("Gdiplus\GdipGetPathGradientFocusScales", "Ptr", this.Ptr, "Float*", &(x := 0), "Float*", &(y := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (Vec2(x, y))
        }

        ;* pathBrush.SetFocusScales(x, y)
        ;* Parameter:
            ;* [Float] x - Scalar in the range (0.0, 1.0).
            ;* [Float] y - Scalar in the range (0.0, 1.0).
        SetFocusScales(x, y) {
            if (status := DllCall("Gdiplus\GdipSetPathGradientFocusScales", "Ptr", this.Ptr, "Float", x, "Float", y, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.GetGammaCorrection()
        ;* Return:
            ;* [Integer]
        GetGammaCorrection() {
            if (status := DllCall("Gdiplus\GdipGetPathGradientGammaCorrection", "Ptr", this.Ptr, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* pathBrush.SetGammaCorrection(useGammaCorrection)
        ;* Parameter:
            ;* [Integer] useGammaCorrection - Boolean value that indicates if gamma correction should be used or not.
        SetGammaCorrection(useGammaCorrection) {
            if (status := DllCall("Gdiplus\GdipSetPathGradientGammaCorrection", "Ptr", this.Ptr, "UInt", useGammaCorrection, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.SetLinearBlend(focus[, scale])
        ;* Parameter:
            ;* [Float] focus - Number in the range (0.0, 1.0) that specifies where the center color will be at its highest intensity.
            ;* [Float] scale - Number in the range (0.0, 1.0) that specifies the maximum intensity of center color that gets blended with the boundary color.
        SetLinearBlend(focus, scale := 1.0) {
            if (status := DllCall("Gdiplus\GdipSetPathGradientLinearBlend", "Ptr", this.Ptr, "Float", focus, "Float", scale, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.GetPointCount()
        ;* Return:
            ;* [Integer]
        GetPointCount() {
            if (status := DllCall("Gdiplus\GdipGetPathGradientPointCount", "Ptr", this.Ptr, "Int*", &(count := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (count)
        }

        ;* pathBrush.SetSigmaBlend(focus[, scale])
        ;* Parameter:
            ;* [Float] focus - Number in the range (0.0, 1.0) that specifies where the center color will be at its highest intensity.
            ;* [Float] scale - Number in the range (0.0, 1.0) that specifies the maximum intensity of center color that gets blended with the boundary color.
        SetSigmaBlend(focus, scale := 1.0) {
            if (status := DllCall("Gdiplus\GdipSetPathGradientSigmaBlend", "Ptr", this.Ptr, "Float", focus, "Float", scale, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.GetSurroundColorCount()
        ;* Return:
            ;* [Integer]
        GetSurroundColorCount() {
            if (status := DllCall("Gdiplus\GdipGetPathGradientSurroundColorCount", "Ptr", this.Ptr, "UInt*", &(count := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (count)
        }

        ;* pathBrush.GetSurroundColors()
        ;* Return:
            ;* [Array]
        GetSurroundColors() {
            if (status := DllCall("Gdiplus\GdipGetPathGradientSurroundColorsWithCount", "Ptr", this.Ptr, "Ptr", (struct := Buffer((count := this.GetSurroundColorCount())*4)).Ptr, "Int*", &(count), "Int")) {
                throw (ErrorFromStatus(status))
            }

            loop (array := [], count) {
                array.Push(struct.NumGet((A_Index - 1)*4, "UInt"))
            }

            return (array)
        }

        ;* pathBrush.SetSurroundColors(colors*)
        ;* Parameter:
            ;* [Integer]* colors
        SetSurroundColors(colors*) {
            for index, color in (struct := Buffer((length := colors.Length)*4), colors) {
                struct.NumPut(index*4, "UInt", color)
            }

            if (status := DllCall("Gdiplus\GdipSetPathGradientSurroundColorsWithCount", "Ptr", this.Ptr, "Ptr", struct.Ptr, "Int*", length, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.GetTransform()
        ;* Return:
            ;* [Matrix]
        GetTransform() {
            if (status := DllCall("Gdiplus\GdipGetPathGradientTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Matrix(pMatrix))
        }

        ;* pathBrush.SetTransform(matrix)
        ;* Parameter:
            ;* [Matrix] matrix
        SetTransform(matrix) {
            if (status := DllCall("Gdiplus\GdipSetPathGradientTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.TranslateTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder
        TranslateTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipTranslatePathGradientTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.RotateTransform(angle[, matrixOrder])
        ;* Parameter:
            ;* [Float] angle
            ;* [Integer] matrixOrder
        RotateTransform(angle, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipRotatePathGradientTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.MultiplyTransform(matrix[, matrixOrder])
        ;* Parameter:
            ;* [Matrix] matrix
            ;* [Integer] matrixOrder
        MultiplyTransform(matrix, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipMultiplyPathGradientTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.ScaleTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder
        ScaleTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipScalePathGradientTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pathBrush.ResetTransform()
        ResetTransform() {
            if (status := DllCall("Gdiplus\GdipResetPathGradientTransform", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
    }

    ;----------------------------------------------------  LinearBrush  ------------;

    ;* GDIp.CreateLinearBrush(x1, y1, x2, y2, color1, color2[, wrapMode])
    ;* Parameter:
        ;* [Float] x1
        ;* [Float] y1
        ;* [Float] x2
        ;* [Float] y2
        ;* [Integer] color1
        ;* [Integer] color2
        ;* [Integer] wrapMode - See WrapMode enumeration.
    ;* Return:
        ;* [Brush]
    static CreateLinearBrush(x1, y1, x2, y2, color1, color2, wrapMode := 0) {
        static point1 := Buffer.CreatePoint(0, 0, "Float"), point2 := Buffer.CreatePoint(0, 0, "Float")

        point1.NumPut(0, "Float", x1, "Float", y1), point2.NumPut(0, "Float", x2, "Float", y2)

        if (status := DllCall("Gdiplus\GdipCreateLineBrush", "Ptr", point1.Ptr, "Ptr", point2.Ptr, "UInt", color1, "UInt", color2, "UInt", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.LinearBrush(pBrush))
    }

    ;* GDIp.CreateLinearBrushFromRect(x, y, width, height, color1, color2[, gradientMode, wrapMode])
    ;* Parameter:
        ;* [Float] x
        ;* [Float] y
        ;* [Float] width
        ;* [Float] height
        ;* [Integer] color1
        ;* [Integer] color2
        ;* [Integer] gradientMode - See LinearGradientMode enumeration.
        ;* [Integer] wrapMode - See WrapMode enumeration.
    ;* Return:
        ;* [Brush]
    static CreateLinearBrushFromRect(x, y, width, height, color1, color2, gradientMode := 0, wrapMode := 0) {
        static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

        rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

        if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRect", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "UInt", gradientMode, "UInt", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.LinearBrush(pBrush))
    }

    ;* GDIp.CreateLinearBrushFromRectWithAngle(x, y, width, height, color1, color2, angle[, wrapMode])
    ;* Parameter:
        ;* [Float] x
        ;* [Float] y
        ;* [Float] width
        ;* [Float] height
        ;* [Integer] color1
        ;* [Integer] color2
        ;* [Float] angle
        ;* [Integer] wrapMode - See WrapMode enumeration.
    ;* Return:
        ;* [Brush]
    static CreateLinearBrushFromRectWithAngle(x, y, width, height, color1, color2, angle, wrapMode := 0) {
        static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

        rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

        if (status := DllCall("Gdiplus\GdipCreateLineBrushFromRectWithAngle", "Ptr", rect.Ptr, "UInt", color1, "UInt", color2, "Float", angle, "UInt", 0, "UInt", wrapMode, "Ptr*", &(pBrush := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.LinearBrush(pBrush))
    }

    class LinearBrush extends GDIp.SolidBrush {

        Color {
            Get {
                return (this.GetColor())
            }

            Set {
                this.SetColor(value*)

                return (value)
            }
        }

        ;* linearBrush.GetColor()
        ;* Return:
            ;* [Array]
        GetColor() {
            static colors := Buffer(8)

            if (status := DllCall("Gdiplus\GdipGetLineColors", "Ptr", this.Ptr, "Ptr", colors.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return ([colors.NumGet(0, "UInt"), colors.NumGet(4, "UInt")])
        }

        ;* linearBrush.SetColor(color1, color2)
        ;* Parameter:
            ;* [Integer] color1
            ;* [Integer] color2
        SetColor(color1, color2) {
            if (status := DllCall("Gdiplus\GdipSetLineColors", "Ptr", this.Ptr, "UInt", color1, "UInt", color2, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        WrapMode {
            Get {
                return (this.GetWrapMode())
            }

            Set {
                this.SetWrapMode(value)

                return (value)
            }
        }
        ;* linearBrush.GetWrapMode()
        ;* Return:
            ;* [Integer] - See WrapMode enumeration.
        GetWrapMode() {
            if (status := DllCall("Gdiplus\GdipGetLineWrapMode", "Ptr", this.Ptr, "Int*", &(wrapMode := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (wrapMode)
        }
        ;* linearBrush.SetWrapMode(wrapMode)
        ;* Parameter:
            ;* [Integer] wrapMode - See WrapMode enumeration.
        SetWrapMode(wrapMode) {
            if (status := DllCall("Gdiplus\GdipSetLineWrapMode", "Ptr", this.Ptr, "Int", wrapMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* linearBrush.GetRect()
        ;* Return:
            ;* [Object]
        GetRect() {
            static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

            if (status := DllCall("Gdiplus\GdipGetLineRect", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
        }

        ;* lineBrush.GetGammaCorrection()
        ;* Return:
            ;* [Integer] - Boolean value that indicates if gamma correction is enabled or not.
        GetGammaCorrection() {
            if (status := DllCall("Gdiplus\GdipGetLineGammaCorrection", "Ptr", this.Ptr, "Int*", &(enabled := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (enabled)
        }

        ;* linearBrush.SetGammaCorrection(useGammaCorrection)
        ;* Parameter:
            ;* [Integer] useGammaCorrection - Boolean value that indicates if gamma correction should be enabled or not.
        SetGammaCorrection(useGammaCorrection) {
            if (status := DllCall("Gdiplus\GdipSetLineGammaCorrection", "Ptr", this.Ptr, "Int", useGammaCorrection, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* lineBrush.GetTransform()
        ;* Return:
            ;* [Matrix]
        GetTransform() {
            if (status := DllCall("Gdiplus\GdipGetLineTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Matrix(pMatrix))
        }

        ;* linearBrush.SetTransform(matrix)
        ;* Parameter:
            ;* [Matrix] matrix
        SetTransform(matrix) {
            if (status := DllCall("Gdiplus\GdipSetLineTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* linearBrush.TranslateTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder
        TranslateTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipTranslateLineTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* linearBrush.RotateTransform(angle[, matrixOrder])
        ;* Parameter:
            ;* [Float] angle
            ;* [Integer] matrixOrder
        RotateTransform(angle, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipRotateLineTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* linearBrush.MultiplyTransform(matrix[, matrixOrder])
        ;* Parameter:
            ;* [Matrix] matrix
            ;* [Integer] matrixOrder
        MultiplyTransform(matrix, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipMultiplyLineTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* linearBrush.ScaleTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder
        ScaleTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipScaleLineTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* linearBrush.ResetTransform()
        ResetTransform() {
            if (status := DllCall("Gdiplus\GdipResetLineTransform", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
    }

    ;========================================================  Pen  ================;

    ;* GDIp.CreatePen(color[, width, unit])
    ;* Parameter:
        ;* [Integer] color
        ;* [Float] width
        ;* [Integer] unit - See Unit enumeration.
    ;* Return:
        ;* [Pen]
    static CreatePen(color, width := 1, unit := 2) {
        if (status := DllCall("Gdiplus\GdipCreatePen1", "UInt", color, "Float", width, "Int", unit, "Ptr*", &(pPen := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Pen(pPen))
    }

    ;* GDIp.CreatePenFromBrush(brush[, width, unit])
    ;* Parameter:
        ;* [Brush] brush
        ;* [Float] width
        ;* [Integer] unit - See Unit enumeration.
    ;* Return:
        ;* [Pen]
    static CreatePenFromBrush(brush, width := 1, unit := 2) {
        if (status := DllCall("Gdiplus\GdipCreatePen2", "Ptr", brush, "Float", width, "Int", 2, "Ptr*", &(pPen := 0), "Int", unit, "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Pen(pPen))
    }

    class Pen {
        Class := "Pen"

        __New(pPen) {
            this.Ptr := pPen
        }

        ;* pen.Clone()
        ;* Return:
            ;* [Pen]
        Clone() {
            if (status := DllCall("Gdiplus\GdipClonePen", "Ptr", this.Ptr, "Ptr*", &(pPen := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Pen(pPen))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeletePen", "Ptr", this.Ptr, "Int")
            }
        }

        Color {
            Get {
                return (this.GetColor())
            }

            Set {
                this.SetColor(value)

                return (value)
            }
        }

        ;* pen.GetColor()
        ;* Return:
            ;* [Integer]
        GetColor() {
            if (status := DllCall("Gdiplus\GdipGetPenColor", "Ptr", this.Ptr, "UInt*", &(color := 0), "Int")) {  ;* `GetColor()` throws an exception if the Pen object inherited it's color from a LineBrush object.
                throw (ErrorFromStatus(status))
            }

            return (color)
        }

        ;* pen.SetColor(color)
        ;* Parameter:
            ;* [Integer] color
        SetColor(color) {
            if (status := DllCall("Gdiplus\GdipSetPenColor", "Ptr", this.Ptr, "UInt", color, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        Width {
            Get {
                return (this.GetWidth())
            }

            Set {
                this.SetWidth(value)

                return (value)
            }
        }

        ;* pen.GetWidth()
        ;* Return:
            ;* [Float]
        GetWidth() {
            if (status := DllCall("Gdiplus\GdipGetPenWidth", "Ptr", this.Ptr, "Float*", &(width := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (width)
        }

        ;* pen.SetWidth(width)
        ;* Parameter:
            ;* [Float] width
        SetWidth(width) {
            if (status := DllCall("Gdiplus\GdipSetPenWidth", "Ptr", this.Ptr, "Float", width, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        Unit {
            Get {
                return (this.GetUnit())
            }

            Set {
                this.SetUnit(value)

                return (value)
            }
        }

        ;* pen.GetUnit()
        ;* Return:
            ;* [Integer] - See Unit enumeration.
        GetUnit() {
            if (status := DllCall("Gdiplus\GdipGetPenUnit", "Ptr", this.Ptr, "Int*", &(unit := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (unit)
        }

        ;* pen.SetUnit(unit)
        ;* Parameter:
            ;* [Integer] unit - See Unit enumeration.
        SetUnit(unit) {
            if (status := DllCall("Gdiplus\GdipSetPenUnit", "Ptr", this.Ptr, "Int", unit, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        Brush {
            Get {
                return (this.GetBrush())
            }

            Set {
                this.SetBrush(value)

                return (value)
            }
        }

        ;* pen.GetBrush()
        ;* Description:
            ;* Gets the brush object that is currently set for this pen object.
        ;* Return:
            ;* [Brush]
        GetBrush() {
            if (status := DllCall("Gdiplus\GdipGetPenBrushFill", "Ptr", this.Ptr, "Ptr*", &(pBrush := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            if (status := DllCall("Gdiplus\GdipGetBrushType", "Ptr", pBrush, "Int*", &(type := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            switch (type) {
                case 0: instance := GDIp.SolidBrush(pBrush)
                case 1: instance := GDIp.HatchBrush(pBrush)
                case 2: instance := GDIp.TextureBrush(pBrush)
                case 3: instance := GDIp.PathBrush(pBrush)
                case 4: instance := GDIp.LinearBrush(pBrush)
            }

            return (instance)
        }

        ;* pen.SetBrush(brush)
        ;* Parameter:
            ;* [Brush] brush
        SetBrush(brush) {
            if (status := DllCall("Gdiplus\GdipSetPenBrushFill", "Ptr", this.Ptr, "Ptr", brush, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        Type {
            Get {
                return (this.GetType())
            }
        }

        ;* pen.GetType()
        ;* Return:
            ;* [Integer] - See PenType enumeration.
        GetType() {
            if (status := DllCall("Gdiplus\GdipGetPenFillType", "Ptr", this.Ptr, "Int*", &(type := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (type)
        }

        ;* pen.GetAlignment()
        ;* Return:
            ;* [Integer] - See PenAlignment enumeration.
        GetAlignment() {
            if (status := DllCall("Gdiplus\GdipGetPenMode", "Ptr", this.Ptr, "Int*", &(alignment := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (alignment)
        }

        ;* pen.SetAlignment(alignment)
        ;* Parameter:
            ;* [Integer] alignment - See PenAlignment enumeration.
        ;* Note:
            ;~ If you set the alignment to `PenAlignmentInset`, you cannot use that pen to draw compound lines or triangular dash caps.
        SetAlignment(alignment) {
            if (status := DllCall("Gdiplus\GdipSetPenMode", "Ptr", this.Ptr, "Int", alignment, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.SetCompoundArray(compoundArray)
        ;* Parameter:
            ;* [Array] compoundArray
        ;* Note:
            ;~ If you set the alignment to `PenAlignmentInset`, you cannot use that pen to draw compound lines.
        SetCompoundArray(compoundArray) {
            for index, number in (compounds := Buffer((length := compoundArray.Length)*4), compoundArray) {
                compounds.NumPut(index*4, "Float", number)
            }

            if (status := DllCall("Gdiplus\GdipSetPenCompoundArray", "Ptr", this.Ptr, "Ptr", compounds.Ptr, "Int", length, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.GetCompoundCount()
        ;* Return:
            ;* [Integer]
        GetCompoundCount() {
            if (status := DllCall("Gdiplus\GdipGetPenCompoundCount", "Ptr", this.Ptr, "Int*", &(compoundCount := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (compoundCount)
        }

        ;* pen.GetStartCap()
        ;* Return:
            ;* [Integer] - See LineCap enumeration.
        GetStartCap() {
            if (status := DllCall("Gdiplus\GdipGetPenStartCap", "Ptr", this.Ptr, "UInt*", &(lineCap := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (Format("0x{:02X}", lineCap))
        }

        ;* pen.SetStartCap(lineCap)
        ;* Parameter:
            ;* [Integer] lineCap - See LineCap enumeration.
        SetStartCap(lineCap) {
            if (status := DllCall("Gdiplus\GdipSetPenStartCap", "Ptr", this.Ptr, "UInt", lineCap, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.GetEndCap()
        ;* Return:
            ;* [Integer] - See LineCap enumeration.
        GetEndCap() {
            if (status := DllCall("Gdiplus\GdipGetPenEndCap", "Ptr", this.Ptr, "UInt*", &(lineCap := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (Format("0x{:02X}", lineCap))
        }

        ;* pen.SetEndCap(lineCap)
        ;* Parameter:
            ;* [Integer] lineCap - See LineCap enumeration.
        SetEndCap(lineCap) {
            if (status := DllCall("Gdiplus\GdipSetPenEndCap", "Ptr", this.Ptr, "UInt", lineCap, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.GetDashCap()
        ;* Return:
            ;* [Integer] - See DashCap enumeration.
        GetDashCap() {
            if (status := DllCall("Gdiplus\GdipGetPenDashCap197819", "Ptr", this.Ptr, "Int*", &(dashCap := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (dashCap)
        }

        ;* pen.SetDashCap(dashCap)
        ;* Parameter:
            ;* [Integer] dashCap - See DashCap enumeration.
        ;* Note:
            ;~ If you set the alignment to `PenAlignmentInset`, you cannot use that pen to draw triangular dash caps.
        SetDashCap(dashCap) {
            if (status := DllCall("Gdiplus\GdipSetPenDashCap197819", "Ptr", this.Ptr, "Int", dashCap, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.SetLineCap(startCap, endCap, dashCap)
        ;* Parameter:
            ;* [Integer] startCap - See LineCap enumeration.
            ;* [Integer] endCap - See LineCap enumeration.
            ;* [Integer] dashCap - See DashCap enumeration.
        SetLineCap(startCap, endCap, dashCap) {
            if (status := DllCall("Gdiplus\GdipSetPenLineCap197819", "Ptr", this.Ptr, "Int", startCap, "Int", endCap, "Int", dashCap, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.GetDashOffset()
        ;* Return:
            ;* [Float]
        GetDashOffset() {
            if (status := DllCall("Gdiplus\GdipGetPenDashOffset", "Ptr", this.Ptr, "Float*", &(dashOffset := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (dashOffset)
        }

        ;* pen.SetDashOffset(dashOffset)
        ;* Parameter:
            ;* [Float] dashOffset
        SetDashOffset(dashOffset) {
            if (status := DllCall("Gdiplus\GdipSetPenDashOffset", "Ptr", this.Ptr, "Float", dashOffset, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.GetDashStyle()
        ;* Return:
            ;* [Integer] - See DashStyle enumeration.
        GetDashStyle() {
            if (status := DllCall("Gdiplus\GdipGetPenDashStyle", "Ptr", this.Ptr, "Int*", &(dashStyle := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (dashStyle)
        }

        ;* pen.SetDashStyle(dashStyle)
        ;* Parameter:
            ;* [Integer] dashStyle - See DashStyle enumeration.
        SetDashStyle(dashStyle) {
            if (status := DllCall("Gdiplus\GdipSetPenDashStyle", "Ptr", this.Ptr, "Int", dashStyle, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.GetTransform()
        ;* Return:
            ;* [Matrix]
        GetTransform() {
            if (status := DllCall("Gdiplus\GdipGetPenTransform", "Ptr", this.Ptr, "Ptr*", &(pMatrix := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Matrix(pMatrix))
        }

        ;* pen.SetTransform(matrix)
        ;* Parameter:
            ;* [Matrix] matrix
        SetTransform(matrix) {
            if (status := DllCall("Gdiplus\GdipSetPenTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.TranslateTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder
        TranslateTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipTranslatePenTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.RotateTransform(angle[, matrixOrder])
        ;* Parameter:
            ;* [Float] angle
            ;* [Integer] matrixOrder
        RotateTransform(angle, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipRotatePenTransform", "Ptr", this.Ptr, "Float", angle, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.MultiplyTransform(matrix[, matrixOrder])
        ;* Parameter:
            ;* [Matrix] matrix
            ;* [Integer] matrixOrder
        MultiplyTransform(matrix, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipMultiplyPenTransform", "Ptr", this.Ptr, "Ptr", matrix, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.ScaleTransform(x, y[, matrixOrder])
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Integer] matrixOrder
        ScaleTransform(x, y, matrixOrder := 0) {
            if (status := DllCall("Gdiplus\GdipScalePenTransform", "Ptr", this.Ptr, "Float", x, "Float", y, "Int", matrixOrder, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* pen.ResetTransform()
        ResetTransform() {
            if (status := DllCall("Gdiplus\GdipResetPenTransform", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
    }

    ;======================================================== Path ================;

    ;* GDIp.CreatePath([fillMode])
    ;* Parameter:
        ;* [Integer] fillMode - See FillMode enumeration.
    ;* Return:
        ;* [Path]
    static CreatePath(fillMode := 0) {
        if (status := DllCall("Gdiplus\GdipCreatePath", "Int", fillMode, "Ptr*", &(pPath := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Path(pPath))
    }

    class Path {
        Class := "Path"

        __New(pPath) {
            this.Ptr := pPath
        }

        ;* path.Clone()
        ;* Return:
            ;* [Path]
        Clone() {
            if (status := DllCall("Gdiplus\GdipClonePath", "Ptr", this.Ptr, "Ptr*", &(pPath := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Path(pPath))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeletePath", "Ptr", this.Ptr, "Int")
            }
        }

        FillMode {
            Get {
                return (this.GetFillMode())
            }

            Set {
                this.SetFillMode(value)

                return (value)
            }
        }

        ;* path.GetFillMode()
        ;* Return:
            ;* [Integer] - See FillMode enumeration.
        GetFillMode() {
            if (status := DllCall("Gdiplus\GdipGetPathFillMode", "Ptr", this.Ptr, "Int*", &(fillMode := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (fillMode)
        }

        ;* path.SetFillMode(fillMode)
        ;* Parameter:
            ;* [Integer] fillMode - See FillMode enumeration.
        SetFillMode(fillMode) {
            if (status := DllCall("Gdiplus\GdipSetPathFillMode", "Ptr", this.Ptr, "Int", fillMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.GetRect()
        ;* Return:
            ;* [Object]
        GetRect() {
            static rect := Buffer.CreateRect(0, 0, "Float")

            if (status := DllCall("gdiplus\GdipGetPathWorldBounds", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
        }

        ;* path.GetPointCount()
        ;* Return:
            ;* [Integer]
        GetPointCount() {
            if (status := DllCall("Gdiplus\GdipGetPointCount", "Ptr", this.Ptr, "Int*", &(count := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (count)
        }

        ;* path.GetPoints()
        ;* Return:
            ;* [Array]
        GetPoints() {
            if (status := DllCall("Gdiplus\GdipGetPathPoints", "Ptr", this.Ptr, "Ptr", (struct := Buffer((count := this.GetPointCount())*8)).Ptr, "Int*", &count, "Int")) {
                throw (ErrorFromStatus(status))
            }

            loop (array := [], count) {
                offset := (A_Index - 1)*8
                    , array.Push(Vec2(struct.NumGet(offset, "Float"), struct.NumGet(offset + 4, "Float")))
            }

            return (array)
        }

        ;* path.GetLastPoint()
        ;* Return:
            ;* [Array]
        GetLastPoint() {
            static point := Buffer.CreatePoint(0, 0, "Float")

            if (status := DllCall("Gdiplus\GdipGetPathLastPoint", "Ptr", this.Ptr, "Ptr", point.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (Vec2(point.NumGet(0, "Float"), point.NumGet(4, "Float")))
        }

        ;------------------------------------------------------  Control  --------------;

        ;* path.Flatten(flatness[, matrix])
        ;* Parameter:
            ;* [Float] flatness
            ;* [Matrix] matrix
        Flatten(flatness, matrix := 0) {
            if (status := DllCall("Gdiplus\GdipFlattenPath", "Ptr", this.Ptr, "Ptr", matrix, "Float", flatness, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.Reverse()
        Reverse() {
            if (status := DllCall("Gdiplus\GdipReversePath", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.Widen(pen[, flatness, matrix])
        ;* Parameter:
            ;* [Pen] pen
            ;* [Float] flatness
            ;* [Matrix] matrix
        Widen(pen, flatness := 1.0, matrix := 0) {
            if (status := DllCall("Gdiplus\GdipWidenPath", "Ptr", this.Ptr, "Ptr", pen, "Ptr", matrix, "Float", flatness, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.Transform(matrix)
        ;* Parameter:
            ;* [Matrix] matrix
        Transform(matrix) {
            if (status := DllCall("gdiplus\GdipTransformPath", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.Reset()
        Reset() {
            if (status := DllCall("Gdiplus\GdipResetPath", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;------------------------------------------------------- Figure ---------------;

        ;* path.StartFigure() - Starts a new figure without closing the current figure. Subsequent points added to this path are added to the new figure.
        StartFigure() {
            if (status := DllCall("Gdiplus\GdipStartPathFigure", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.CloseFigure([all])
        ;* Parameter:
            ;* [Integer] all
        CloseFigure(all := false) {
            if (status := (all)
                ? (DllCall("Gdiplus\GdipClosePathFigures", "Ptr", this.Ptr, "Int"))
                : (DllCall("Gdiplus\GdipStartPathFigure", "Ptr", this.Ptr, "Int"))) {
                throw (ErrorFromStatus(status))
            }
        }

        ;--------------------------------------------------------  Add  ----------------;

        ;AddArc
        ;AddBezier
        ;AddBeziers
        ;AddClosedCurve
        ;AddCurve
        ;AddEllipse
        ;AddLine
        ;AddLines
        ;AddPie
        ;AddPolygon
        ;AddRectangle
        ;AddRoundedRectangle

        ;* path.AddArc(x, y, width, height, startAngle, sweepAngle)
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Float] startAngle
            ;* [Float] sweepAngle
        AddArc(x, y, width, height, startAngle, sweepAngle) {
            if (status := DllCall("Gdiplus\GdipAddPathArc", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Float", startAngle, "Float", sweepAngle, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddBezier(point1, point2, point3, point4)
        ;* Parameter:
            ;* [Array] point1
            ;* [Array] point2
            ;* [Array] point3
            ;* [Array] point4
        AddBezier(point1, point2, point3, point4) {
            if (status := DllCall("Gdiplus\GdipAddPathBezier", "Ptr", this.Ptr, "Float", point1[0], "Float", point1[1], "Float", point2[0], "Float", point2[1], "Float", point3[0], "Float", point3[1], "Float", point4[0], "Float", point4[1], "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddBeziers(points*)
        ;* Parameter:
            ;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
        ;* Note:
            ;~ The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
        AddBeziers(points*) {
            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := DllCall("Gdiplus\GdipAddPathBeziers", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddClosedCurve(points*[, tension])
        ;* Parameter:
            ;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
            ;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
        AddClosedCurve(points*) {
            if (IsNumber(points[-1])) {
                tension := points.Pop()
            }

            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := (tension)
                ? (DllCall("Gdiplus\GdipAddPathClosedCurve2", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "Int"))
                : (DllCall("Gdiplus\GdipAddPathClosedCurve", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddCurve(points*[, tension])
        ;* Parameter:
            ;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
            ;* [Float] tension - Non-negative real number that specifies how tightly the spline bends as it passes through the points.
        AddCurve(points*) {
            if (IsNumber(points[-1])) {
                tension := points.Pop()
            }

            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := (tension)
                ? (DllCall("Gdiplus\GdipAddPathCurve2", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Float", tension, "Int"))
                : (DllCall("Gdiplus\GdipAddPathCurve", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Int"))) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddEllipse(x, y, width, height)
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        AddEllipse(x, y, width, height) {
            if (status := DllCall("Gdiplus\GdipAddPathEllipse", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddLine(point1, point2)
        ;* Parameter:
            ;* [Array] point1 - An Array with values at index 0 and 1 to be used as x and y coordinates respectively.
            ;* [Array] point2 - An Array with values at index 0 and 1 to be used as x and y coordinates respectively.
        AddLine(point1, point2) {
            if (status := DllCall("Gdiplus\GdipAddPathLine", "Ptr", this.Ptr, "Float", point1[0], "Float", point1[1], "Float", point2[0], "Float", point2[1], "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddLines(points*)
        ;* Parameter:
            ;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
        AddLines(points*) {
            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := DllCall("Gdiplus\GdipAddPathLine2", "Ptr", this.Ptr, "Ptr", struct.Ptr, "UInt", length, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddPie(x, y, width, height, startAngle, sweepAngle)
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Float] startAngle
            ;* [Float] sweepAngle
        AddPie(x, y, width, height, startAngle, sweepAngle) {
            if (status := DllCall("Gdiplus\GdipAddPathPie", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Float", startAngle, "Float", sweepAngle, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddPolygon(points*)
        ;* Parameter:
            ;* [Array]* points - Any number of Arrays with values at index 0 and 1 to be used as x and y coordinates respectively.
        ;* Note:
            ;~ The `"Gdiplus\GdipAddPathPolygon"` function is similar to the `"Gdiplus\GdipAddPathLine2"` function. The difference is that a polygon is an intrinsically closed figure, but a sequence of lines is not a closed figure unless you call `"Gdiplus\GdipClosePathFigure"`. When Microsoft Windows GDI+ renders a path, each polygon in that path is closed; that is, the last vertex of the polygon is connected to the first vertex by a straight line.
        AddPolygon(points*) {
            for index, point in (struct := Buffer((length := points.Length)*8), points) {
                struct.NumPut(index*8, "Float", point[0], "Float", point[1])
            }

            if (status := DllCall("Gdiplus\GdipAddPathPolygon", "Ptr", this.Ptr, "Ptr", struct.Ptr, "Int", length, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddRectangle(x, y, width, height)
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        AddRectangle(x, y, width, height) {
            if (status := DllCall("Gdiplus\GdipAddPathRectangle", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* path.AddRoundedRectangle(x, y, width, height, radius)
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Float] radius - Radius of the rounded corners.
        AddRoundedRectangle(x, y, width, height, radius) {
            diameter := radius*2
                , width -= diameter, height -= diameter

            pPath := this.Ptr

            DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y, "Float", diameter, "Float", diameter, "Float", 180, "Float", 90)
            DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y, "Float", diameter, "Float", diameter, "Float", 270, "Float", 90)
            DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x + width, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 0, "Float", 90)
            DllCall("Gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", x, "Float", y + height, "Float", diameter, "Float", diameter, "Float", 90, "Float", 90)
            DllCall("Gdiplus\GdipClosePathFigure", "Ptr", pPath)
        }
    }

    ;======================================================= Region ===============;

    ;* GDIp.CreateRegion()
    ;* Return:
        ;* [Region]
    static CreateRegion() {
        if (status := DllCall("Gdiplus\GdipCreateRegion", "Ptr*", &(pRegion := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Region(pRegion))
    }

    ;* GDIp.CreateRegionFromPath(path)
    ;* Parameter:
        ;* [Path] path
    ;* Return:
        ;* [Region]
    static CreateRegionFromPath(path) {
        if (status := DllCall("Gdiplus\GdipCreateRegionPath", "Ptr", path, "Ptr*", &(pRegion := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Region(pRegion))
    }

    ;* GDIp.CreateRegionFromRect(x, y, width, height)
    ;* Parameter:
        ;* [Float] x
        ;* [Float] y
        ;* [Float] width
        ;* [Float] height
    ;* Return:
        ;* [Region]
    static CreateRegionFromRect(x, y, width, height) {
        static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

        rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

        if (status := DllCall("Gdiplus\GdipCreateRegionRect", "Ptr", rect.Ptr, "Ptr*", &(pRegion := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Region(pRegion))
    }

    class Region {
        Class := "Region"

        ;* Parameter:
            ;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
            ;* [Region] region1
            ;* [Region] region2
        ;* Return:
            ;* [Integer]
        static Equals(graphics, region1, region2) {
            if (status := DllCall("Gdiplus\GdipIsEqualRegion", "Ptr", region1, "Ptr", region2, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        __New(pRegion) {
            this.Ptr := pRegion
        }

        ;* Return:
            ;* [Region]
        Clone() {
            if (status := DllCall("Gdiplus\GdipCloneRegion", "Ptr", this.Ptr, "Ptr*", &(pRegion := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Region(pRegion))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteRegion", "Ptr", this.Ptr, "Int")
            }
        }

        ;* Parameter:
            ;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
        ;* Return:
            ;* [Integer]
        IsEmpty(graphics) {
            if (status := DllCall("Gdiplus\GdipIsEmptyRegion", "Ptr", this.Ptr, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* Parameter:
            ;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
        ;* Return:
            ;* [Integer]
        IsInfinite(graphics) {
            if (status := DllCall("Gdiplus\GdipIsInfiniteRegion", "Ptr", this.Ptr, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* Parameter:
            ;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
            ;* [Float] x
            ;* [Float] y
        ;* Return:
            ;* [Integer]
        IsPointVisible(graphics, x, y) {
            if (status := DllCall("Gdiplus\GdipIsVisibleRegionPoint", "Ptr", this.Ptr, "Float", x, "Float", y, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* Parameter:
            ;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
        ;* Return:
            ;* [Integer]
        IsRectVisible(graphics, x, y, width, height) {
            if (status := DllCall("Gdiplus\GdipIsVisibleRegionRect", "Ptr", this.Ptr, "Float", x, "Float", y, "Float", width, "Float", height, "Ptr", graphics, "UInt*", &(bool := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (bool)
        }

        ;* Parameter:
            ;* [Graphics] graphics - Graphics object that contains the world and page transformations required to calculate the device coordinates of this region.
        ;* Return:
            ;* [Object]
        GetRect(graphics) {
            static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

            if (status := DllCall("Gdiplus\GdipGetRegionBounds", "Ptr", this.Ptr, "Ptr", graphics, "Ptr", rect.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }

            return ({x: rect.NumGet(0, "Float"), y: rect.NumGet(4, "Float"), Width: rect.NumGet(8, "Float"), Height: rect.NumGet(12, "Float")})
        }

        SetEmpty() {
            if (status := DllCall("Gdiplus\GdipSetEmpty", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        SetInfinite() {
            if (status := DllCall("Gdiplus\GdipSetInfinite", "Ptr", this.Ptr, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* region.CombinePath(path, combineMode)
        ;* Parameter:
            ;* [Path] path
            ;* [Integer] combineMode - See CombineMode enumeration.
        CombinePath(path, combineMode) {
            if (status := DllCall("Gdiplus\GdipCombineRegionPath", "Ptr", this.Ptr, "Ptr", path, "Int", combineMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* region.CombineRect(x, y, width, height, combineMode)
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
            ;* [Float] width
            ;* [Float] height
            ;* [Integer] combineMode - See CombineMode enumeration.
        CombineRect(x, y, width, height, combineMode) {
            static rect := Buffer.CreateRect(0, 0, 0, 0, "Float")

            rect.NumPut(0, "Float", x, "Float", y, "Float", width, "Float", height)

            if (status := DllCall("Gdiplus\GdipCombineRegionRect", "Ptr", this.Ptr, "Ptr", rect.Ptr, "Int", combineMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* region.CombineRegion(region, combineMode)
        ;* Parameter:
            ;* [Region] region
            ;* [Integer] combineMode - See CombineMode enumeration.
        CombineRegion(region, combineMode) {
            if (status := DllCall("Gdiplus\GdipCombineRegionRegion", "Ptr", this.Ptr, "Ptr", region, "Int", combineMode, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* region.Translate(x, y)
        ;* Parameter:
            ;* [Float] x
            ;* [Float] y
        Translate(x, y) {
            if (status := DllCall("Gdiplus\GdipTranslateRegion", "Ptr", this.Ptr, "Float", x, "Float", y, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        ;* region.Transform(matrix)
        ;* Parameter:
            ;* [Matrix] matrix
        Transform(matrix) {
            if (status := DllCall("Gdiplus\GdipTransformRegion", "Ptr", this.Ptr, "Ptr", matrix, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
    }

    ;===================================================== FontFamily =============;  ;~ A font family is a group of fonts that have the same typeface but different styles.

    ;* GDIp.CreateFontFamilyFromName([name, fontCollection])
    ;* Parameter:
        ;* [String] name
        ;* [FontCollection] fontCollection
    ;* Return:
        ;* [FontFamily]
    static CreateFontFamilyFromName(name := "Fira Code Retina", fontCollection := 0) {
        if (status := DllCall("Gdiplus\GdipCreateFontFamilyFromName", "Ptr", StrPtr(name), "Ptr", fontCollection, "Ptr*", &(pFontFamily := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.FontFamily(pFontFamily))
    }

    class FontFamily {
        Class := "FontFamily"

        __New(pFontFamily) {
            this.Ptr := pFontFamily
        }

        ;* fontFamily.Clone()
        ;* Return:
            ;* [FontFamily]
        Clone() {
            if (status := DllCall("Gdiplus\GdipCloneFontFamily", "Ptr", this.Ptr, "Ptr*", &(pFontFamily := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.FontFamily(pFontFamily))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteFontFamily", "Ptr", this.Ptr, "Int")
            }
        }

        Name {
            Get {
                return (this.GetName())
            }
        }

        ;* fontFamily.GetName()
        ;* Parameter:
            ;* [Integer] language - See https://robotics.ee.uwa.edu.au/courses/robotics/project/festo/(D)%20FST4.21-110802/SDK/Localization/LANGID.H.
        ;* Return:
            ;* [String] - The name of this font family.
        GetName(language := 0x00) {
            if (status := DllCall("Gdiplus\GdipGetFamilyName", "Ptr", this.Ptr, "Ptr", (name := Buffer(64)).Ptr, "UShort", language, "Int")) {  ;? LF_FACESIZE = 32
                throw (ErrorFromStatus(status))
            }

            return (name.StrGet())
        }
    }

    ;======================================================== Font ================;

    ;* GDIp.CreateFont(fontFamily, size[, style, unit])
    ;* Parameter:
        ;* [FontFamily] fontFamily
        ;* [Float] size
        ;* [Integer] style - See FontStyle enumeration.
        ;* [Integer] unit - See Unit enumeration.
    ;* Return:
        ;* [Font]
    static CreateFont(fontFamily, size, style := 0, unit := 2) {
        if (status := DllCall("Gdiplus\GdipCreateFont", "Ptr", fontFamily.Ptr, "Float", size, "Int", style, "UInt", unit, "Ptr*", &(pFont := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Font(pFont))
    }

    ;* GDIp.CreateFontFromDC(DC)
    ;* Parameter:
        ;* [DC] DC
    ;* Return:
        ;* [Font]
    static CreateFontFromDC(DC) {
        if (status := DllCall("Gdiplus\GdipCreateFontFromDC", "Ptr", DC.Handle, "Ptr*", &(pFont := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.Font(pFont))
    }

    class Font {
        Class := "Font"

        __New(pFont) {
            this.Ptr := pFont
        }

        ;* font.Clone()
        ;* Return:
            ;* [Font]
        Clone() {
            if (status := DllCall("Gdiplus\GdipCloneFont", "Ptr", this.Ptr, "Ptr*", &(pFont := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.Font(pFont))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteFont", "Ptr", this.Ptr, "Int")
            }
        }

        FontFamily {
            Get {
                return (this.GetFontFamily())
            }
        }

        ;* Return:
            ;* [FontFamily]
        GetFontFamily() {
            if (status := DllCall("Gdiplus\GdipGetFamily", "Ptr", this.Ptr, "Ptr*", &(pFontFamily := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.FontFamily(pFontFamily))
        }

        Size {
            Get {
                return (this.GetSize())
            }
        }

        ;* font.GetSize()
        ;* Return:
            ;* [Float]
        GetSize() {
            if (status := DllCall("Gdiplus\GdipGetFontSize", "Ptr", this.Ptr, "Float*", &(size := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (size)
        }

        Style {
            Get {
                return (this.GetStyle())
            }
        }

        ;* font.GetStyle()
        ;* Return:
            ;* [Integer] - See FontStyle enumeration.
        GetStyle() {
            if (status := DllCall("Gdiplus\GdipGetFontStyle", "Ptr", this.Ptr, "Int*", &(style := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (style)
        }

        Unit {
            Get {
                return (this.GetUnit())
            }
        }

        ;* font.GetUnit()
        ;* Return:
            ;* [Integer] - See Unit enumeration.
        GetUnit() {
            if (status := DllCall("Gdiplus\GdipGetFontUnit", "Ptr", this.Ptr, "Int*", &(unit := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (unit)
        }

        ;* font.GetHeight([graphics])
        ;* Parameter:
            ;* [Graphics] graphics - A Graphics object whose unit and vertical resolution are used in the height calculation.
        ;* Return:
            ;* [Float]
        GetHeight(graphics := 0) {
            if (status := DllCall("Gdiplus\GdipGetFontHeight", "Ptr", this.Ptr, "Ptr", graphics, "Float*", &(height := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (height)
        }
    }

    ;==================================================== StringFormat ============;

    ;* GDIp.CreateStringFormat([flags, language])
    ;* Parameter:
        ;* [Integer] flags - See StringFormatFlags enumeration.
        ;* [Integer] language - Sixteen-bit value that specifies the language to use.
    ;* Return:
        ;* [StringFormat]
    static CreateStringFormat(flags := 0, language := 0) {
        if (status := DllCall("Gdiplus\GdipCreateStringFormat", "UInt", flags, "UInt", language, "Ptr*", &(pStringFormat := 0), "Int")) {
            throw (ErrorFromStatus(status))
        }

        return (this.StringFormat(pStringFormat))
    }

    class StringFormat {
        Class := "StringFormat"

        __New(pStringFormat) {
            this.Ptr := pStringFormat
        }

        ;* stringFormat.Clone()
        ;* Return:
            ;* [StringFormat]
        Clone() {
            if (status := DllCall("Gdiplus\GdipCloneStringFormat", "Ptr", this.Ptr, "Ptr*", &(pStringFormat := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (GDIp.StringFormat(pStringFormat))
        }

        __Delete() {
            try {
                DllCall("Gdiplus\GdipDeleteStringFormat", "Ptr", this.Ptr, "Int")
            }
        }

        Flags {
            Get {
                return (this.GetFlags())
            }

            Set {
                this.SetFlags(value)

                return (value)
            }
        }

        ;* stringFormat.GetFlags()
        ;* Return:
            ;* [Integer] - See StringFormatFlags enumeration.
        GetFlags() {
            if (status := DllCall("gdiplus\GdipGetStringFormatFlags", "UPtr", this.Ptr, "Int*", &(flags := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (flags)
        }

        ;* stringFormat.SetFlags(flags)
        ;* Parameter:
            ;* [Integer] flags - See StringFormatFlags enumeration.
        SetFlags(flags) {
            if (status := DllCall("Gdiplus\GdipSetStringFormatFlags", "Ptr", this.Ptr, "Int", flags, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        Alignment {
            Get {
                return (this.GetAlignment())
            }

            Set {
                this.SetAlignment(value)

                return (value)
            }
        }

        ;* stringFormat.GetAlignment()
        ;* Return:
            ;* [Integer] - See StringAlignment enumeration.
        GetAlignment() {
            if (status := DllCall("Gdiplus\GdipGetStringFormatAlign", "Ptr", this.Ptr, "Int*", &(alignment := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (alignment)
        }

        ;* stringFormat.SetAlignment(alignment)
        ;* Parameter:
            ;* [Integer] alignment - See StringAlignment enumeration.
        SetAlignment(alignment) {
            if (status := DllCall("Gdiplus\GdipSetStringFormatAlign", "Ptr", this.Ptr, "Int", alignment, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        DigitSubstitution {
            Get {
                return (this.GetDigitSubstitution())
            }

            Set {
                this.SetDigitSubstitution(value)

                return (value)
            }
        }

        ;* stringFormat.GetDigitSubstitution()
        ;* Return:
            ;* [Integer] - See StringDigitSubstitute enumeration.
        GetDigitSubstitution() {
            if (status := DllCall("Gdiplus\GdipGetStringFormatDigitSubstitution", "Ptr", this.Ptr, "UShort*", 0, "Int*", &(substitute := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (substitute)
        }

        ;* stringFormat.SetDigitSubstitution(substitute[, language])
        ;* Parameter:
            ;* [Integer] substitute - See StringDigitSubstitute enumeration.
            ;* [Integer] language - Sixteen-bit value that specifies the language to use.
        SetDigitSubstitution(substitute, language := 0) {
            if (status := DllCall("Gdiplus\GdipSetStringFormatDigitSubstitution", "Ptr", this.Ptr, "UShort", language, "Int", substitute, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        LineAlignment {
            Get {
                return (this.GetLineAlignment())
            }

            Set {
                this.SetLineAlignment(value)

                return (value)
            }
        }

        ;* stringFormat.GetLineAlignment()
        ;* Return:
            ;* [Integer] - See StringAlignment enumeration.
        GetLineAlignment() {
            if (status := DllCall("Gdiplus\GdipGetStringFormatLineAlign", "Ptr", this.Ptr, "Int*", &(alignment := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (alignment)
        }

        ;* stringFormat.SetLineAlignment(alignment)
        ;* Parameter:
            ;* [Integer] alignment - See StringAlignment enumeration.
        SetLineAlignment(alignment) {
            if (status := DllCall("Gdiplus\GdipSetStringFormatLineAlign", "Ptr", this.Ptr, "Int", alignment, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }

        Trimming {
            Get {
                return (this.GetTrimming())
            }

            Set {
                this.SetTrimming(value)

                return (value)
            }
        }

        ;* stringFormat.GetTrimming()
        ;* Return:
            ;* [Integer] - See StringTrimming enumeration.
        GetTrimming() {
            if (status := DllCall("Gdiplus\GdipGetStringFormatTrimming", "Ptr", this.Ptr, "Int*", &(trimming := 0), "Int")) {
                throw (ErrorFromStatus(status))
            }

            return (trimming)
        }

        ;* stringFormat.SetTrimming(trimming)
        ;* Parameter:
            ;* [Integer] trimming - See StringTrimming enumeration.
        SetTrimming(trimming) {
            if (status := DllCall("Gdiplus\GdipSetStringFormatTrimming", "Ptr", this.Ptr, "Int", trimming, "Int")) {
                throw (ErrorFromStatus(status))
            }
        }
    }
}
