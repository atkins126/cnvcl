unit UnitWatermark;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, jpeg,
  StdCtrls, ExtCtrls, CnNative, CnMatrix, CnDFT;

type
  TFormWatermark = class(TForm)
    btnOpenFile: TButton;
    dlgOpen1: TOpenDialog;
    img1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure btnOpenFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FJpg: TJPEGImage;
    FBmp: TBitmap;
  public

  end;

var
  FormWatermark: TFormWatermark;

implementation

uses
  CnDebug;

const
  WATERMARK_CELL_SIZE = 8;

{$R *.DFM}

procedure TFormWatermark.FormCreate(Sender: TObject);
begin
  FJpg := TJPEGImage.Create;
  FBmp := TBitmap.Create;
end;

procedure TFormWatermark.btnOpenFileClick(Sender: TObject);
var
  R, C, X, Y, W, H, B: Integer;
  M, T, MDCT, MIDCT: TCnFloatMatrix;
  P: PByte;
begin
  if dlgOpen1.Execute then
  begin
    FJpg.LoadFromFile(dlgOpen1.FileName);
    FBmp.Assign(FJpg);

    // CnDebugger.EvaluateObject(FBmp);
    case FBmp.PixelFormat of
      pf8bit:  B := 1;
      pf16bit: B := 2;
      pf24bit: B := 3;
      pf32bit: B := 4;
    else
      raise Exception.Create('PixelFormat Not Supported');
    end;

    W := FBmp.Width div WATERMARK_CELL_SIZE;
    H := FBmp.Height div WATERMARK_CELL_SIZE;

    M := TCnFloatMatrix.Create(WATERMARK_CELL_SIZE, WATERMARK_CELL_SIZE);
    T := TCnFloatMatrix.Create(WATERMARK_CELL_SIZE, WATERMARK_CELL_SIZE);

    MDCT := TCnFloatMatrix.Create;
    MIDCT := TCnFloatMatrix.Create;

    CnGenerateDCT2Matrix(MDCT, WATERMARK_CELL_SIZE);
    CnMatrixTranspose(MDCT, MIDCT);

    for R := 0 to H - 1 do
    begin
      for C := 0 to W - 1 do
      begin
        // ���� [R, C] ����Ԫ�� M ��
        // ������ ScanLine[R * WATERMARK_CELL_SIZE]�������ڸ� ScanLine ͷ + C * WATERMARK_CELL_SIZE * BytesPerPixels

        for Y := 0 to WATERMARK_CELL_SIZE - 1 do
        begin
          P := FBmp.ScanLine[R * WATERMARK_CELL_SIZE + Y]; // P ָ���п�ͷ
          P := Pointer(TCnNativeInt(P) + C * WATERMARK_CELL_SIZE * B); // P ָ�򱾾���ͷ
          for X := 0 to WATERMARK_CELL_SIZE - 1 do
          begin
            // ��ʱ P ָ���������أ���ȡ P ָ�� 1 2 3 4 ���ֽ���Ϊ������
            M[X, Y] := P^; // ��ֻ��һ���ֽ�
            // P^ := $00;
            Inc(P, B);
          end;
        end;

        // ������һ�������� DCT2
        CnDCT2(M, T, MDCT, MIDCT);

        // TODO: �� T ����ˮӡ
        T[0, 0] := 0;

        // ���� DCT2 ��ԭ
        CnIDCT2(T, M, MDCT, MIDCT);


        // �� M д�ص��� [R, C] ����Ԫ����
        // ������ ScanLine[R * WATERMARK_CELL_SIZE]�������ڸ� ScanLine ͷ + C * WATERMARK_CELL_SIZE * BytesPerPixels

        for Y := 0 to WATERMARK_CELL_SIZE - 1 do
        begin
          P := FBmp.ScanLine[R * WATERMARK_CELL_SIZE + Y]; // P ָ���п�ͷ
          P := Pointer(TCnNativeInt(P) + C * WATERMARK_CELL_SIZE * B); // P ָ�򱾾���ͷ
          for X := 0 to WATERMARK_CELL_SIZE - 1 do
          begin
            // ��ʱ P ָ���������أ�
            P^ := Round(M[X, Y]);
            Inc(P, B);
          end;
        end;
      end;
    end;

    img1.Picture.Assign(FBmp);
    MIDCT.Free;
    MDCT.Free;
    T.Free;
    M.Free;
  end;
end;

procedure TFormWatermark.FormDestroy(Sender: TObject);
begin
  FBmp.Free;
  FJpg.Free;
end;

end.
