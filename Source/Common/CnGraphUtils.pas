{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnGraphUtils;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�����ͼ����̿ⵥԪ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ GDI+ ֧�ֺ���֧�ֵͰ汾 Windows
* ����ƽ̨��PWin98SE + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2024.06.09 V1.2
*               ���뼸���߰汾�� TPoint/TRect ��װ����
*           2021.09.28 V1.1
*               ����һ��ƽ���������λͼ�ĺ�����ʹ�� GDI+
*           2002.10.20 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Graphics, Math, Classes, Controls
  {$IFDEF SUPPORT_GDIPLUS}, WinApi.GDIPOBJ, WinApi.GDIPAPI {$ENDIF};

//==============================================================================
// ��չ����ɫ��ʽת������
//==============================================================================

var
  HSLRange: Integer = 240;

//------------------------------------------------------------------------------
// HSL ��ɫ�� RGB ɫת������
//------------------------------------------------------------------------------

function HSLToRGB(H, S, L: Double): TColor;
{* HSL ��ɫת��Ϊ RGB ��ɫ
 |<PRE>
   H, S, L: Double   - �ֱ�Ϊɫ�������Ͷȡ����ȷ�����Ϊ"0"��"1"֮���С��
   Result: TColor    - ���� RGB ��ɫֵ
 |</PRE>}
function HSLRangeToRGB(H, S, L: Integer): TColor;
{* HSL ��ɫת��Ϊ RGB ��ɫ
 |<PRE>
   H, S, L: Integer  - �ֱ�Ϊɫ�������Ͷȡ����ȷ�����0..240
   Result: TColor    - ���� RGB ��ɫֵ
 |</PRE>}
procedure RGBToHSL(Color: TColor; out H, S, L: Double);
{* RGB ��ɫת��Ϊ HSL ��ɫ
 |<PRE>
  Color: TColor         - RGB ��ɫֵ
  H, S, L: Integer      - ����ֱ�Ϊɫ�������Ͷȡ����ȷ�����Ϊ"0"��"1"֮���С��
 |</PRE>}
procedure RGBToHSLRange(Color: TColor; out H, S, L: Integer);
{* RGB ��ɫת��Ϊ HSL ��ɫ
 |<PRE>
   Color: TColor        - RGB��ɫֵ
   H, S, L: Integer     - ����ֱ�Ϊɫ�������Ͷȡ����ȷ�����0..240
 |</PRE>}

function ChangeHue(Color: TColor; Hue: Double): TColor;
{* �滻��ɫ�е�ɫ��ֵ�������µ���ɫ}
function ChangeSaturation(Color: TColor; Saturation: Double): TColor;
{* �滻��ɫ�еı��Ͷ�ֵ�������µ���ɫ}
function ChangeLighteness(Color: TColor; Lighteness: Double): TColor;
{* �滻��ɫ�е�����ֵ�������µ���ɫ}

function AdjustHue(Color: TColor; Added: Double): TColor;
{* ������ɫ�е�ɫ��ֵ�������µ���ɫ}
function AdjustSaturation(Color: TColor; Added: Double): TColor;
{* ������ɫ�еı��Ͷ�ֵ�������µ���ɫ}
function AdjustLighteness(Color: TColor; Added: Double): TColor;
{* ������ɫ�е�����ֵ�������µ���ɫ}

//------------------------------------------------------------------------------
// CMY ��ɫ�� RGB ɫת������
//------------------------------------------------------------------------------

function CMYToRGB(const C, M, Y: Byte): TColor;
{* CMY ��ɫת��Ϊ RGB ��ɫ
 |<PRE>
  C, M, Y: Byte         - �ֱ�Ϊ Cyan �ࡢMagenta Ʒ�졢Yellow �Ʒ�����0..255
  Result: TColor        - ����RGB��ɫֵ
 |</PRE>}
procedure RGBToCMY(const RGB: TColor; out C, M, Y: Byte);
{* RGB ��ɫת��Ϊ CMY ��ɫ
 |<PRE>
 |<BR> Color: TColor      RGB ��ɫֵ
 |<BR> C, M, Y: Byte      ����ֱ�Ϊ Cyan �ࡢMagenta Ʒ�졢Yellow �Ʒ�����0..255
 |</PRE>}

//------------------------------------------------------------------------------
// CMYK ��ɫ�� RGB ɫת������
//------------------------------------------------------------------------------

function CMYKToRGB(const C, M, Y, K: Byte): TColor;
{* CMYK ��ɫת��Ϊ RGB ��ɫ
 |<PRE>
   C, M, Y, K: Byte     - �ֱ�Ϊ Cyan �ࡢMagenta Ʒ�졢Yellow �ơ�Black �ڷ�����0..255
   Result: TColor       - ���� RGB ��ɫֵ
 |</PRE>}
procedure RGBToCMYK(const RGB: TColor; out C, M, Y, K: Byte);
{* RGB ��ɫת��Ϊ CMY ��ɫ
 |<PRE>
   Color: TColor        - RGB ��ɫֵ
   C, M, Y, K: Byte     - ����ֱ�ΪCyan�ࡢMagentaƷ�졢Yellow�ơ�Black�ڷ�����0..255
 |</PRE>}

//==============================================================================
// ��ǿ����ɫ������
//==============================================================================

function Gray(Intensity: Byte): TColor;
{* ����һ���Ҷ� RGB ��ɫֵ}
function Intensity(Color: TColor): Byte;
{* ���� RGB ��ɫֵ�ĻҶ�ֵ}
function RandomColor: TColor;
{* ����һ����� RGB ��ɫֵ}
procedure DeRGB(Color: TColor; var r, g, b: Byte);
{* �� Color �ֽ�Ϊ r��g��b ��ɫ����}

//==============================================================================
// ��չ��λͼ������
//==============================================================================

function CreateEmptyBmp24(Width, Height: Integer; Color: TColor): TBitmap;
{* ����һ���� Color Ϊ����ɫ��ָ����С�� 24 λλͼ }

function DrawBmpToIcon(Bmp: TBitmap; Icon: TIcon): Boolean;
{* �� Bitmap �����ݷŵ� Icon ��}

procedure StretchDrawBmp(Src, Dst: TBitmap; Smooth: Boolean = True);
{* ��λͼ Src ��������� Dst��֧�� GDI+ ʱ����ʹ��ƽ������}

//==============================================================================
// �߰汾 Rect��Point �Ⱥ����ĵͰ汾ʵ��
//==============================================================================

function CnCreatePoint(X, Y: Integer): TPoint;
{* ���� X��Y ���괴��һ����}

function CnGetRectWidth(const Rect: TRect): Integer;
{* ���� TRect �Ŀ��}

function CnGetRectHeight(const Rect: TRect): Integer;
{* ���� TRect �ĸ߶�}

function CnGetRectCenter(const Rect: TRect): TPoint;
{* ���� TRect �����ĵ�����}

function CnGetRectIsEmpty(const Rect: TRect): Boolean;
{* ���� TRect �Ƿ�Ϊ��}

procedure CnSetRectWidth(var Rect: TRect; Value: Integer);
{* ����һ TRect �Ŀ��}

procedure CnSetRectHeight(var Rect: TRect; Value: Integer);
{* ����һ TRect �ĸ߶�}

procedure CnRectInflate(var Rect: TRect; DX, DY: Integer);
{* ��Сһ�� TRect}

procedure CnRectOffset(var Rect: TRect; DX, DY: Integer);
{* ƫ��һ�� TRect}

procedure CnRectCopy(const Source: TRect; var Dest: TRect);
{* ����һ�� Rect}

function CnRectContains(const Rect: TRect; const PT: TPoint): Boolean;
{* ����һ TRect �Ƿ����һ���㣬ע��������ϱߣ������������±�}

procedure CnSetRectLocation(var Rect: TRect; const X, Y: Integer); overload;
{* ���� TRect �����Ͻ����꣬����Ϊ X��Y ����}

procedure CnSetRectLocation(var Rect: TRect; const P: TPoint); overload;
{* ���� TRect �����Ͻ����꣬����Ϊһ����}

procedure CnCanvasRoundRect(const Canvas: TCanvas; const Rect: TRect; CX, CY: Integer);
{* �� Canvas �ϻ���Բ�Ǿ���}

{$IFNDEF SUPPORT_GDIPLUS}

procedure CnStartUpGdiPlus;
{* ���� DLL �в�������ŵ�Ԫ����ʼ��/�ͷ� GDI+������������������ã���ʼ�� GDI+}
procedure CnShutDownGdiPlus;
{* ���� DLL �в�������ŵ�Ԫ����ʼ��/�ͷ� GDI+������������������ã��ͷ� GDI+}

{$ENDIF}

function FontEqual(A, B: TFont): Boolean;
{* �Ƚ����������ĸ������Ƿ����}

implementation

{$IFNDEF SUPPORT_GDIPLUS}

//==============================================================================
// ��������֧�� GDI+ ʱ�ֹ����� GDI+ ��غ���
//==============================================================================

const
  WINGDIPDLL = 'gdiplus.dll';
  SmoothingModeInvalid     = -1;
  SmoothingModeDefault     = 0;
  SmoothingModeHighSpeed   = 1;
  SmoothingModeHighQuality = 2;
  SmoothingModeNone        = 3;
  SmoothingModeAntiAlias   = 4;

type
  GpGraphics = Pointer;
  {* GDI+ ��ͼ�����࣬�� GdipCreateFromHDC �ȴ������� GdipDeleteGraphics �ͷ�}

  GpImage = Pointer;
  {* GDI+ ͼ����࣬������һ���� GdipCreateBitmapFromHBITMAP �ȴ������� GdipDisposeImage �ͷ�}

  GpBitmap = Pointer;
  {* GDI+ GpImage �����࣬����λͼ}

  TStatus = (
    Ok,
    GenericError,
    InvalidParameter,
    OutOfMemory,
    ObjectBusy,
    InsufficientBuffer,
    NotImplemented,
    Win32Error,
    WrongState,
    Aborted,
    FileNotFound,
    ValueOverflow,
    AccessDenied,
    UnknownImageFormat,
    FontFamilyNotFound,
    FontStyleNotFound,
    NotTrueTypeFont,
    UnsupportedGdiplusVersion,
    GdiplusNotInitialized,
    PropertyNotFound,
    PropertyNotSupported
  );

  GpStatus = TStatus;

  TSmoothingMode = Integer;
  {* ʹ�� const �е� SmoothingMode* ֵ}

  TDebugEventLevel = (DebugEventLevelFatal, DebugEventLevelWarning);

  DebugEventProc = procedure(Level: TDebugEventLevel; Message: PChar); stdcall;
  NotificationHookProc = function(out Token: ULONG): TStatus; stdcall;
  NotificationUnhookProc = procedure(Token: ULONG); stdcall;

  GdiplusStartupInput = record
    GdiplusVersion          : Cardinal;       // Must be 1
    DebugEventCallback      : DebugEventProc;
    SuppressBackgroundThread: BOOL;
    SuppressExternalCodecs  : BOOL;
  end;
  TGdiplusStartupInput = GdiplusStartupInput;
  PGdiplusStartupInput = ^TGdiplusStartupInput;

  GdiplusStartupOutput = record
    NotificationHook  : NotificationHookProc;
    NotificationUnhook: NotificationUnhookProc;
  end;
  TGdiplusStartupOutput = GdiplusStartupOutput;
  PGdiplusStartupOutput = ^TGdiplusStartupOutput;

  // GDI+ ������ĺ�����������
  TGdiplusStartup = function(out Token: ULONG; Input: PGdiplusStartupInput;
    Output: PGdiplusStartupOutput): GPSTATUS; stdcall;

  TGdiplusShutdown = procedure(Token: ULONG); stdcall;

  TGdipCreateFromHDC = function(hdc: HDC; out Graphic: GPGRAPHICS): GPSTATUS; stdcall;

  TGdipDeleteGraphics = function(Graphic: GPGRAPHICS): GPSTATUS; stdcall;

  TGdipSetSmoothingMode = function(Graphic: GPGRAPHICS; Sm: TSmoothingMode):
    GPSTATUS; stdcall;

  TGdipGetSmoothingMode = function(Graphic: GPGRAPHICS; var Sm: TSmoothingMode):
    GPSTATUS; stdcall;

  TGdipCreateBitmapFromHBITMAP = function(hbm: HBITMAP; hpal: HPALETTE; out
    Bitmap: GPBITMAP): GPSTATUS; stdcall;

  TGdipDisposeImage = function(Image: GPIMAGE): GPSTATUS; stdcall;

  TGdipDrawImageRect = function(Graphic: GPGRAPHICS; Image: GPIMAGE; x: Single;
    y: Single; Width: Single; Height: Single): GPSTATUS; stdcall;

  TGdipDrawImageRectI = function(Graphic: GPGRAPHICS; Image: GPIMAGE; x: Integer;
    y: Integer; Width: Integer; Height: Integer): GPSTATUS; stdcall;

var
  GdiPlusInit: Boolean = False;
  GdiPlusHandle: THandle = 0;
  StartupInput: TGDIPlusStartupInput;
  GdiplusToken: ULONG;

  GdiplusStartup: TGdiplusStartup = nil;
  GdiplusShutdown: TGdiplusShutdown = nil;
  GdipCreateFromHDC: TGdipCreateFromHDC = nil;
  GdipDeleteGraphics: TGdipDeleteGraphics = nil;
  GdipSetSmoothingMode: TGdipSetSmoothingMode = nil;
  GdipGetSmoothingMode: TGdipGetSmoothingMode = nil;
  GdipCreateBitmapFromHBITMAP: TGdipCreateBitmapFromHBITMAP = nil;
  GdipDisposeImage: TGdipDisposeImage = nil;
  GdipDrawImageRect: TGdipDrawImageRect = nil;
  GdipDrawImageRectI: TGdipDrawImageRectI = nil;

{$ENDIF}

//==============================================================================
// ��չ����ɫ��ʽת������
//==============================================================================

//------------------------------------------------------------------------------
// HSL ��ɫ�� RGB ɫת������
// �㷨��Դ��
// http:/www.r2m.com/win-developer-faq/graphics/8.html
// Grahame Marsh 12 October 1997
//------------------------------------------------------------------------------

// HSL ��ɫת��Ϊ RGB ɫ
function HSLToRGB(H, S, L: Double): TColor;
var
  M1, M2: Double;

  procedure CheckInput(var V: Double);
  begin
    if V < 0 then V := 0;
    if V > 1 then V := 1;
  end;

  function HueToColourValue(Hue: Double): Byte;
  var
    V: Double;
  begin
    if Hue < 0 then
      Hue := Hue + 1
    else if Hue > 1 then
      Hue := Hue - 1;
    if 6 * Hue < 1 then
      V := M1 + (M2 - M1) * Hue * 6
    else if 2 * Hue < 1 then
      V := M2
    else if 3 * Hue < 2 then
      V := M1 + (M2 - M1) * (2 / 3 - Hue) * 6
    else
      V := M1;
    Result := Round(255 * V)
  end;
var
  r, g, b: Byte;
begin
  H := H - Floor(H);                   // ��֤ɫ���� 0..1 ֮��
  CheckInput(S);
  CheckInput(L);
  if S = 0 then
  begin
    r := Round(255 * L);
    g := r;
    b := r
  end else
  begin
    if L <= 0.5 then
      M2 := L * (1 + S)
    else
      M2 := L + S - L * S;
    M1 := 2 * L - M2;
    r := HueToColourValue(H + 1 / 3);
    g := HueToColourValue(H);
    b := HueToColourValue(H - 1 / 3)
  end;
  Result := RGB(r, g, b);
end;

// HSL ��ɫ��Χת��Ϊ RGB ɫ
function HSLRangeToRGB(H, S, L: Integer): TColor;
begin
  Assert(HSLRange > 1);
  Result := HSLToRGB(H / (HSLRange - 1), S / HSLRange, L / HSLRange)
end;

// RGB ��ɫתΪ HSL ɫ
procedure RGBToHSL(Color: TColor; out H, S, L: Double);
var
  r, g, b, D, Cmax, Cmin: Double;
begin
  Color := ColorToRGB(Color);
  r := GetRValue(Color) / 255;
  g := GetGValue(Color) / 255;
  b := GetBValue(Color) / 255;
  Cmax := Max(r, Max(g, b));
  Cmin := Min(r, Min(g, b));
  L := (Cmax + Cmin) / 2;
  if Cmax = Cmin then
  begin
    H := 0;
    S := 0
  end else
  begin
    D := Cmax - Cmin;
    if L < 0.5 then
      S := D / (Cmax + Cmin)
    else
      S := D / (2 - Cmax - Cmin);
    if r = Cmax then
      H := (g - b) / D
    else if g = Cmax then
      H := 2 + (b - r) / D
    else
      H := 4 + (r - g) / D;
    H := H / 6;
    if H < 0 then
      H := H + 1
  end
end;

// RGB ��ɫתΪ HSL ɫ��Χ
procedure RGBToHSLRange(Color: TColor; out H, S, L: Integer);
var
  Hd, Sd, Ld: Double;
begin
  RGBToHSL(Color, Hd, Sd, Ld);
  H := Round(Hd * (HSLRange - 1));
  S := Round(Sd * HSLRange);
  L := Round(Ld * HSLRange);
end;

// �滻��ɫ�е�ɫ��ֵ�������µ���ɫ
function ChangeHue(Color: TColor; Hue: Double): TColor;
var
  H, S, L: Double;
begin
  RGBToHSL(Color, H, S, L);
  Result := HSLToRGB(Hue, S, L);
end;

// �滻��ɫ�еı��Ͷ�ֵ�������µ���ɫ
function ChangeSaturation(Color: TColor; Saturation: Double): TColor;
var
  H, S, L: Double;
begin
  RGBToHSL(Color, H, S, L);
  Result := HSLToRGB(H, Saturation, L);
end;

// �滻��ɫ�е�����ֵ�������µ���ɫ
function ChangeLighteness(Color: TColor; Lighteness: Double): TColor;
var
  H, S, L: Double;
begin
  RGBToHSL(Color, H, S, L);
  Result := HSLToRGB(H, S, Lighteness);
end;

// ������ɫ�е�ɫ��ֵ�������µ���ɫ
function AdjustHue(Color: TColor; Added: Double): TColor;
var
  H, S, L: Double;
begin
  RGBToHSL(Color, H, S, L);
  Result := HSLToRGB(H + Added, S, L);
end;

// ������ɫ�еı��Ͷ�ֵ�������µ���ɫ
function AdjustSaturation(Color: TColor; Added: Double): TColor;
var
  H, S, L: Double;
begin
  RGBToHSL(Color, H, S, L);
  Result := HSLToRGB(H, S + Added, L);
end;

// ������ɫ�е�����ֵ�������µ���ɫ
function AdjustLighteness(Color: TColor; Added: Double): TColor;
var
  H, S, L: Double;
begin
  RGBToHSL(Color, H, S, L);
  Result := HSLToRGB(H, S, L + Added);
end;

//------------------------------------------------------------------------------
// CMY ��ɫ�� RGB ɫת������
// �㷨�ṩ��CnPack������ ����
//------------------------------------------------------------------------------

// CMY ��ɫת��Ϊ RGB
function CMYToRGB(const C, M, Y: Byte): TColor;
var
  r, g, b: Byte;
begin
  r := 255 - C;
  g := 255 - M;
  b := 255 - Y;
  Result := RGB(r, g, b);
end;

// RGB ��ɫת��Ϊ CMY
procedure RGBToCMY(const RGB: TColor; out C, M, Y: Byte);
var
  r, g, b: Byte;
begin
  DeRGB(RGB, r, g, b);
  C := 255 - r;
  M := 255 - g;
  Y := 255 - b;
end;

//------------------------------------------------------------------------------
// CMYK ��ɫ�� RGB ɫת������
// �㷨�ṩ��CnPack������ ����
//------------------------------------------------------------------------------

// CMYK ��ɫת��Ϊ RGB
function CMYKtoRGB(const C, M, Y, K: Byte): TColor;
var
  r, g, b: Byte;
begin
  r := 255 - (C + K);
  g := 255 - (M + K);
  b := 255 - (Y + K);
  Result := RGB(r, g, b);
end;

// RGB ��ɫת��Ϊ CMYK
procedure RGBToCMYK(const RGB: TColor; out C, M, Y, K: Byte);
begin
  RGBToCMY(RGB, C, M, Y);
  K := MinIntValue([C, M, Y]);
  C := C - K;
  M := M - K;
  Y := Y - K;
end;

//==============================================================================
// ��ǿ����ɫ������
//==============================================================================

// �����Ҷ���ɫ
function Gray(Intensity: Byte): TColor;
begin
  Result := Intensity shl 16 + Intensity shl 8 + Intensity;
end;

// ������ɫ����ֵ
// �㷨��Դ��Graphic32
// �㷨�޸ģ��ܾ���
function Intensity(Color: TColor): Byte; assembler;
asm
// ����:  RGB --> EAX
// ���:  (R * 61 + G * 174 + B * 20) / 256 --> AL
        MOV     ECX,EAX
        AND     EAX,$00FF00FF      // EAX <-   0 B 0 R
        IMUL    EAX,$0014003D
        AND     ECX,$0000FF00      // ECX <-   0 0 G 0
        IMUL    ECX,$0000AE00
        MOV     EDX,EAX
        SHR     ECX,8
        SHR     EDX,16
        ADD     EAX,ECX
        ADD     EAX,EDX
        SHR     EAX,8
end;

// ���������ɫ
function RandomColor: TColor;
begin
  Result := HSLToRGB(Random, 0.75 + Random * 0.25, 0.3 + Random * 0.25);
end;

// ȡ��ɫ RGB ����
procedure DeRGB(Color: TColor; var r, g, b: Byte);
begin
  Color := ColorToRGB(Color);
  r := GetRValue(Color);
  g := GetGValue(Color);
  b := GetBValue(Color);
end;

//==============================================================================
// ��չ��λͼ������
//==============================================================================

// ����һ���� Color Ϊ����ɫ��ָ����С�� 24 λλͼ
function CreateEmptyBmp24(Width, Height: Integer; Color: TColor): TBitmap;
type
  TRGBArray = array[0..65535] of TRGBTriple;
var
  r, g, b: Byte;
  x, y: Integer;
  P: ^TRGBArray;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.Width := Width;
  Result.Height := Height;
  DeRGB(Color, r, g, b);
  for y := 0 to Height - 1 do
  begin
    P := Result.ScanLine[y];
    for x := 0 to Width - 1 do
    begin
      with P^[x] do
      begin
        rgbtBlue := b;
        rgbtGreen := g;
        rgbtRed := r;
      end;
    end;
  end;
end;

// �� Bitmap �����ݷŵ� Icon ��
function DrawBmpToIcon(Bmp: TBitmap; Icon: TIcon): Boolean;
var
  ImageList: TImageList;
begin
  Result := False;
  if (Bmp = nil) or (Icon = nil) or Bmp.Empty then
    Exit;

  ImageList := TImageList.CreateSize(Bmp.Width, Bmp.Height);
  try
    ImageList.AddMasked(Bmp, Bmp.TransparentColor);
    ImageList.GetIcon(0, Icon);
    Result := True;
  finally
    ImageList.Free;
  end;
end;

procedure StretchDrawBmp(Src, Dst: TBitmap; Smooth: Boolean = True);
var
{$IFDEF SUPPORT_GDIPLUS}
  Bmp: TGPBitmap;
  GP: TGPGraphics;
{$ELSE}
  Rd: TRect;
  GP: GpGraphics;
  Bmp: GpBitmap;
  St: TStatus;
{$ENDIF}
begin
  if (Src = nil) or (Dst = nil) then
    Exit;

{$IFDEF SUPPORT_GDIPLUS} // ����������������� GDIPlus ֧��
  GP := nil;
  Bmp := nil;
  try
    GP := TGPGraphics.Create(Dst.Canvas.Handle);
    if Smooth then
      GP.SetSmoothingMode(SmoothingModeAntiAlias);

    Bmp := TGPBitmap.Create(Src.Handle, Src.Palette);
    GP.DrawImage(Bmp, 0, 0, Dst.Width + 1, Dst.Height + 1);
  finally
    Bmp.Free;
    GP.Free;
  end;
{$ELSE}
  if (Src.Width <> Dst.Width) or (Src.Height <> Dst.Height) then
  begin
    if not GdiPlusInit then // û�ж�̬�ҵ� GDIPlus ��֧��
    begin
      Rd := Rect(0, 0, Dst.Width, Dst.Height);
      Dst.Canvas.StretchDraw(Rd, Src);
    end
    else
    begin
      GP := nil;
      St := GdipCreateFromHDC(Dst.Canvas.Handle, GP);
      if (St <> Ok) or (GP = nil) then
        Exit;

      try
        if Smooth then
          GdipSetSmoothingMode(GP, SmoothingModeAntiAlias);

        Bmp := nil;
        St := GdipCreateBitmapFromHBITMAP(Src.Handle, Src.Palette, Bmp);
        if (St <> Ok) or (Bmp = nil) then
          Exit;

        GdipDrawImageRectI(GP, Bmp, 0, 0, Dst.Width + 1, Dst.Height + 1);
      finally
        if Bmp <> nil then
          GdipDisposeImage(Bmp);
        if GP <> nil then
          GdipDeleteGraphics(GP);
      end;
    end
  end
  else
    Dst.Canvas.Draw(0, 0, Src);
{$ENDIF}
end;

function FontEqual(A, B: TFont): Boolean;
begin
  if (A = nil) and (B = nil) then
  begin
    Result := True;
    Exit;
  end
  else if (A = nil) or (B = nil) then
  begin
    Result := False;
    Exit
  end
  else
  begin
    Result := False;

    if A.Name <> B.Name then
      Exit;
    if A.Size <> B.Size then
      Exit;
    if A.Style <> B.Style then
      Exit;
    if A.Color <> B.Color then
      Exit;
    if A.Height <> B.Height then
      Exit;
    if A.Charset <> B.Charset then
      Exit;
    if A.Pitch <> B.Pitch then
      Exit;
    if A.PixelsPerInch <> B.PixelsPerInch then
      Exit;

    Result := True;
  end;
end;
function CnCreatePoint(X, Y: Integer): TPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

function CnGetRectWidth(const Rect: TRect): Integer;
begin
  Result := Rect.Right - Rect.Left;
end;

function CnGetRectHeight(const Rect: TRect): Integer;
begin
  Result := Rect.Bottom - Rect.Top;
end;

function CnGetRectCenter(const Rect: TRect): TPoint;
begin
  Result.X := (Rect.Right - Rect.Left) div 2 + Rect.Left;
  Result.Y := (Rect.Bottom - Rect.Top) div 2 + Rect.Top;
end;

function CnGetRectIsEmpty(const Rect: TRect): Boolean;
begin
  Result := (Rect.Right <= Rect.Left) or (Rect.Bottom <= Rect.Top);
end;

procedure CnSetRectWidth(var Rect: TRect; Value: Integer);
begin
  Rect.Right := Rect.Left + Value;
end;

procedure CnSetRectHeight(var Rect: TRect; Value: Integer);
begin
  Rect.Bottom := Rect.Top + Value;
end;

procedure CnRectInflate(var Rect: TRect; DX, DY: Integer);
begin
  Rect.Left := Rect.Left - DX;
  Rect.Right := Rect.Right + DX;
  Rect.Top := Rect.Top - DY;
  Rect.Bottom := Rect.Bottom + DY;
end;

procedure CnRectOffset(var Rect: TRect; DX, DY: Integer);
begin
  if @Rect <> nil then
  begin
    Inc(Rect.Left, DX);
    Inc(Rect.Right, DX);
    Inc(Rect.Top, DY);
    Inc(Rect.Bottom, DY);
  end;
end;

procedure CnRectCopy(const Source: TRect; var Dest: TRect);
begin
  if (@Source <> nil) and (@Dest <> nil) then
  begin
    Dest.Left := Source.Left;
    Dest.Top := Source.Top;
    Dest.Right := Source.Right;
    Dest.Bottom := Source.Bottom;
  end;
end;

function CnRectContains(const Rect: TRect; const PT: TPoint): Boolean;
begin
  Result := (PT.X >= Rect.Left) and (PT.X < Rect.Right) and (PT.Y >= Rect.Top)
    and (PT.Y < Rect.Bottom);
end;

procedure CnSetRectLocation(var Rect: TRect; const X, Y: Integer);
begin
  OffsetRect(Rect, X - Rect.Left, Y - Rect.Top);
end;

procedure CnSetRectLocation(var Rect: TRect; const P: TPoint);
begin
  CnSetRectLocation(Rect, P.X, P.Y);
end;

procedure CnCanvasRoundRect(const Canvas: TCanvas; const Rect: TRect; CX, CY: Integer);
begin
  if Canvas <> nil then
    Canvas.RoundRect(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, CX, CY);
end;

{$IFNDEF SUPPORT_GDIPLUS}

procedure CnStartUpGdiPlus;
begin
  if not GdiPlusInit and (GdiPlusHandle <> 0) then
  begin
    StartupInput.DebugEventCallback := nil;
    StartupInput.SuppressBackgroundThread := False;
    StartupInput.SuppressExternalCodecs   := False;
    StartupInput.GdiplusVersion := 1;

    GdiplusStartup(GdiPlusToken, @StartupInput, nil);

    GdiPlusInit := True;
  end;
end;

procedure CnShutDownGdiPlus;
begin
  if GdiPlusInit then
  begin
    GdiplusShutdown(GdiplusToken);

    GdiplusToken := 0;
    GdiPlusInit := False;
  end;
end;

{$ENDIF}

{$IFNDEF SUPPORT_GDIPLUS}

initialization
  GdiPlusHandle := LoadLibrary(WINGDIPDLL);
  if GdiPlusHandle <> 0 then
  begin
    GdiplusStartup := TGdiplusStartup(GetProcAddress(GdiPlusHandle, 'GdiplusStartup'));
    Assert(Assigned(GdiplusStartup), 'Load GdiplusStartup from GDI+ DLL.');

    GdiplusShutdown := TGdiplusShutdown(GetProcAddress(GdiPlusHandle, 'GdiplusShutdown'));
    Assert(Assigned(GdiplusShutdown), 'Load GdiplusShutdown from GDI+ DLL.');

    GdipCreateFromHDC:= TGdipCreateFromHDC(GetProcAddress(GdiPlusHandle, 'GdipCreateFromHDC'));
    Assert(Assigned(GdipCreateFromHDC), 'Load GdipCreateFromHDC from GDI+ DLL.');

    GdipDeleteGraphics:= TGdipDeleteGraphics(GetProcAddress(GdiPlusHandle, 'GdipDeleteGraphics'));
    Assert(Assigned(GdipDeleteGraphics), 'Load GdipDeleteGraphics from GDI+ DLL.');

    GdipSetSmoothingMode:= TGdipSetSmoothingMode(GetProcAddress(GdiPlusHandle, 'GdipSetSmoothingMode'));
    Assert(Assigned(GdipSetSmoothingMode), 'Load GdipSetSmoothingMode from GDI+ DLL.');

    GdipGetSmoothingMode:= TGdipGetSmoothingMode(GetProcAddress(GdiPlusHandle, 'GdipGetSmoothingMode'));
    Assert(Assigned(GdipGetSmoothingMode), 'Load GdipGetSmoothingMode from GDI+ DLL.');

    GdipCreateBitmapFromHBITMAP:= TGdipCreateBitmapFromHBITMAP(GetProcAddress(GdiPlusHandle, 'GdipCreateBitmapFromHBITMAP'));
    Assert(Assigned(GdipCreateBitmapFromHBITMAP), 'Load GdipCreateBitmapFromHBITMAP from GDI+ DLL.');

    GdipDisposeImage:= TGdipDisposeImage(GetProcAddress(GdiPlusHandle, 'GdipDisposeImage'));
    Assert(Assigned(GdipDisposeImage), 'Load GdipDisposeImage from GDI+ DLL.');

    GdipDrawImageRect:= TGdipDrawImageRect(GetProcAddress(GdiPlusHandle, 'GdipDrawImageRect'));
    Assert(Assigned(GdipDrawImageRect), 'Load GdipDrawImageRect from GDI+ DLL.');

    GdipDrawImageRectI:= TGdipDrawImageRectI(GetProcAddress(GdiPlusHandle, 'GdipDrawImageRectI'));
    Assert(Assigned(GdipDrawImageRectI), 'Load GdipDrawImageRectI from GDI+ DLL.');
  end;

finalization
  if GdiPlusHandle <> 0 then
    FreeLibrary(GdiPlusHandle);

{$ENDIF}

end.
