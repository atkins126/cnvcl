unit UnitAACtrl;

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TFormAACtrl = class(TForm)
    img1: TImage;
    grpTextOutput32: TGroupBox;
    btnTextOutput32: TButton;
    edt32Text: TEdit;
    dlgFont1: TFontDialog;
    chk32Transparent: TCheckBox;
    btnFont: TButton;
    lbl32BkColor: TLabel;
    shp32BkColor: TShape;
    dlgColor1: TColorDialog;
    chk32PaintAlpha: TCheckBox;
    btnBlendColor: TButton;
    btnBlendEx: TButton;
    btnBlendExFore: TButton;
    dlgOpen1: TOpenDialog;
    procedure btnTextOutput32Click(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure shp32BkColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chk32TransparentClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBlendColorClick(Sender: TObject);
    procedure btnBlendExClick(Sender: TObject);
    procedure btnBlendExForeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormAACtrl: TFormAACtrl;

implementation

uses
  CnAAFont;

{$IFNDEF COMPILER6_UP}
const
  AC_SRC_ALPHA = $01;
{$ENDIF}

{$R *.DFM}

procedure TFormAACtrl.btnTextOutput32Click(Sender: TObject);
var
  Bmp: TBitmap;
  AAFont: TCnAAFont;
  S: string;
  W, H: Integer;
  Bf: TBlendFunction;
begin
  Bmp := TBitmap.Create;
  Bmp.PixelFormat := pf32bit;
  Bmp.Width := 160;
  Bmp.Height := 160;

{$IFDEF TGRAPHIC_SUPPORT_PARTIALTRANSPARENCY}
  Bmp.AlphaFormat := afDefined;
{$ENDIF}

  W := Bmp.Width * SizeOf(TRGBQuad); // ScanLine Width
  for H := 0 to Bmp.Height - 1 do
    FillChar(Bmp.ScanLine[H]^, W, $00); // �����ȫ͸�������ﻭ����û��

  AAFont := TCnAAFont.Create(Bmp.Canvas);
  try
    Bmp.Canvas.Font.Name := dlgFont1.Font.Name; // ��������
    Bmp.Canvas.Font.Size := dlgFont1.Font.Size;
    Bmp.Canvas.Font.Color := dlgFont1.Font.Color;

    Bmp.Canvas.Brush.Color := shp32BkColor.Brush.Color;  // ע��Ҫ������ Color����������õ� Color �ᵼ�� Style ��� bsSolid

    if chk32Transparent.Checked then
      Bmp.Canvas.Brush.Style := bsClear // bsClear ����͸������
    else
      Bmp.Canvas.Brush.Style := bsSolid;

    S := edt32Text.Text;
    W := AAFont.TextWidth(S);
    H := AAFont.TextHeight(S);

    // �� BMP ��������ı�
    AAFont.TextOutput((Bmp.Width - W) div 2, (Bmp.Height - H) div 2, S, 100, 0, True);

    if chk32PaintAlpha.Checked then
    begin
      // ͸�����ȴ�͸���ȵظ���Ŀ�걳����
      Bf.BlendOp := AC_SRC_OVER;
      Bf.BlendFlags := 0;
      Bf.SourceConstantAlpha := $FF;
      Bf.AlphaFormat := AC_SRC_ALPHA;

      Windows.AlphaBlend(Canvas.Handle, 250, 250, Bmp.Width, Bmp.Height,
        Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, Bf);
    end
    else // ����ֱ��ʹ�� Draw������͸���Ļ����� XE2 �����ϲ�����������
    begin
      Canvas.Draw(50, 50, Bmp);
    end;
  finally
    AAFont.Free;
    Bmp.Free;
  end;
end;

procedure TFormAACtrl.btnFontClick(Sender: TObject);
begin
  dlgFont1.Execute;
end;

procedure TFormAACtrl.shp32BkColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    if dlgColor1.Execute then
      shp32BkColor.Brush.Color := dlgColor1.Color;
end;

procedure TFormAACtrl.chk32TransparentClick(Sender: TObject);
begin
  lbl32BkColor.Enabled := not chk32Transparent.Checked;
  shp32BkColor.Enabled := not chk32Transparent.Checked;
end;

procedure TFormAACtrl.FormCreate(Sender: TObject);
begin
  dlgFont1.Font.Size := 72;
  dlgFont1.Font.Color := clLime;
end;

procedure TFormAACtrl.btnBlendColorClick(Sender: TObject);
var
  ForeColor: TColor;
  R, B, G: Byte;
  DiffForeAlpha: DWORD;
  ForeAlpha, BkAlpha: Byte;
  Cr: TRGBQuad;
  Weight: Byte;
begin
  ForeColor := clYellow;
  ForeAlpha := 255;
  BkAlpha := 0;

  Cr.rgbBlue := 0;
  Cr.rgbRed := 0;
  Cr.rgbGreen := 0;
  Cr.rgbReserved := 0;
  // ���������룬ForeColor �� ForeAlpha �Լ� Alpha ��ϣ��ǵ� BkColor �� BkAlpha ��

  ForeColor := ColorToRGB(ForeColor);       // ʵ��ǰ��ɫ
  R := GetRValue(ForeColor);                // ɫ�ʷ���
  G := GetGValue(ForeColor);
  B := GetBValue(ForeColor);

  DiffForeAlpha := ($FF - ForeAlpha) * BkAlpha;
  Weight := ($FF * $FF - ($FF - ForeAlpha) * ($FF - BkAlpha)) div $FF;
  // ��ǰ����ȫ��͸��Ҳ���� ForeAlpha Ϊ 255 ʱ�����۱���͸���ȶ��٣����͸����Ϊ 255��Ҳ������ȫ��͸��
  // ��ǰ����ȫ͸��Ҳ���� ForeAlpha Ϊ 0 ʱ�����͸����Ϊ����͸���� BkAlpha

  Cr.rgbReserved := Weight;
  if Weight <> 0 then // 0 ��ʾȫ͸�����Ͳ���Ҫ��ɫ��
  begin
    Cr.rgbBlue := (B * ForeAlpha + (Cr.rgbBlue * DiffForeAlpha) div $FF) div Weight;
    Cr.rgbGreen := (G * ForeAlpha + (Cr.rgbGreen * DiffForeAlpha) div $FF) div Weight;
    Cr.rgbRed := (R * ForeAlpha + (Cr.rgbRed * DiffForeAlpha) div $FF) div Weight;
  end;

  Caption := Format('RGBA: %2.2x, %2.2x, %2.2x, %2.2x', [Cr.rgbRed, Cr.rgbGreen,
    Cr.rgbBlue, Cr.rgbReserved]);
end;

procedure TFormAACtrl.btnBlendExClick(Sender: TObject);
var
  Bmp: TBitmap;
  AAFont: TCnAAFontEx;
  S: string;
  W, H: Integer;
  Bf: TBlendFunction;
begin
  Bmp := TBitmap.Create;
  Bmp.PixelFormat := pf32bit;
  Bmp.Width := 160;
  Bmp.Height := 160;

{$IFDEF TGRAPHIC_SUPPORT_PARTIALTRANSPARENCY}
  Bmp.AlphaFormat := afDefined;
{$ENDIF}

  W := Bmp.Width * SizeOf(TRGBQuad); // ScanLine Width
  for H := 0 to Bmp.Height - 1 do
    FillChar(Bmp.ScanLine[H]^, W, $00); // �����ȫ͸�������ﻭ����û��

  AAFont := TCnAAFontEx.Create(Bmp.Canvas);
  try
    Bmp.Canvas.Font.Name := dlgFont1.Font.Name; // ��������
    Bmp.Canvas.Font.Size := dlgFont1.Font.Size;
    Bmp.Canvas.Font.Color := dlgFont1.Font.Color;

    Bmp.Canvas.Brush.Color := shp32BkColor.Brush.Color;
    // ע��Ҫ������ Color����������õ� Color �ᵼ�� Style ��� bsSolid

    if chk32Transparent.Checked then
      Bmp.Canvas.Brush.Style := bsClear // bsClear ����͸������
    else
      Bmp.Canvas.Brush.Style := bsSolid;

    S := edt32Text.Text;
    W := AAFont.TextWidth(S);
    H := AAFont.TextHeight(S);

    // �� BMP ��������ı�
    AAFont.Effect.Alpha := 90;

    AAFont.Effect.Shadow.Enabled := True;
    AAFont.Effect.Shadow.Color := clRed;
    AAFont.Effect.Shadow.Blur := 100;
    AAFont.Effect.Shadow.Alpha := 90;
    AAFont.Effect.Shadow.OffsetX := 6;
    AAFont.Effect.Shadow.OffsetY := 6;

    // OK
    AAFont.Effect.Gradual.Enabled := True;
    AAFont.Effect.Gradual.StartColor := clRed;
    AAFont.Effect.Gradual.EndColor := clBlue;

    AAFont.Effect.Outline := True; // OK
    AAFont.Effect.Blur := 50;      // OK
//    AAFont.Effect.Angle := 45;     // Partly OK for some font
    AAFont.Effect.Noise := 150;    // OK
    AAFont.Effect.Spray := 2;         // OK
    AAFont.Effect.HorzMirror := True;  // OK
    AAFont.Effect.VertMirror := True;  // OK

    AAFont.TextOutput((Bmp.Width - W) div 2, (Bmp.Height - H) div 2, S, True);

// CnDebugger.EvaluateObject(Bmp, True);
    if chk32PaintAlpha.Checked then
    begin
      // ͸�����ȴ�͸���ȵظ���Ŀ�걳����
      Bf.BlendOp := AC_SRC_OVER;
      Bf.BlendFlags := 0;
      Bf.SourceConstantAlpha := $FF;
      Bf.AlphaFormat := AC_SRC_ALPHA;

      Windows.AlphaBlend(Canvas.Handle, 250, 250, Bmp.Width, Bmp.Height,
        Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, Bf);
    end
    else // ����ֱ��ʹ�� Draw������͸���Ļ����� XE2 �����ϲ�����������
    begin
      Canvas.Draw(50, 50, Bmp);
    end;
  finally
    AAFont.Free;
    Bmp.Free;
  end;
end;

procedure TFormAACtrl.btnBlendExForeClick(Sender: TObject);
var
  Bmp: TBitmap;
  Blend: TCnAABlend;
  AAFont: TCnAAFont;
  Mask: TCnAAMask;
  Size: TSize;
begin
  // BlendEx ����
  Bmp := TBitmap.Create;
  Bmp.PixelFormat := pf32bit;
  Bmp.Width := 160;
  Bmp.Height := 160;

{$IFDEF TGRAPHIC_SUPPORT_PARTIALTRANSPARENCY}
  Bmp.AlphaFormat := afDefined;
{$ENDIF}

  AAFont := TCnAAFont.Create(Bmp.Canvas);
  Blend := TCnAABlend.Create(AAFont);
  Mask := TCnAAMask.Create(AAFont);

  Bmp.Canvas.Font.Name := dlgFont1.Font.Name; // ��������
  Bmp.Canvas.Font.Size := dlgFont1.Font.Size;
  Bmp.Canvas.Font.Color := dlgFont1.Font.Color;
  Bmp.Canvas.Brush.Style := bsClear;

  try
    if dlgOpen1.Execute then
    begin
      Blend.ForeBmp.LoadFromFile(dlgOpen1.FileName);
      Blend.SyncForeBmp32;
      Size.cx := Blend.ForeBmp.Width;
      Size.cy := Blend.ForeBmp.Height;
      Mask.DrawMaskEx('��', Size, Point(0, 0));
      Blend.BlendEx(0, 0, 60, Mask, True);

// CnDebugger.EvaluateObject(Bmp, True);
    end;
  finally
    Blend.Free;
    AAFont.Free;
    Bmp.Free;
  end;
end;

end.
