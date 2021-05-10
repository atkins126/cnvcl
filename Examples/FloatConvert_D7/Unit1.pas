unit Unit1;

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, CnFloatConvert, CnNativeDecl, StdCtrls;

type
  TFormFloat = class(TForm)
   Edit1: TEdit;
   CheckBox1: TCheckBox;
   CheckBox2: TCheckBox;
   Button1: TButton;
   Label1: TLabel;
   rdoBin: TRadioButton;
   rdoOct: TRadioButton;
   rdoHex: TRadioButton;
    btnExtract: TButton;
    btnUInt64ToFloat: TButton;
   procedure Button1Click(Sender: TObject);
    procedure btnExtractClick(Sender: TObject);
    procedure btnUInt64ToFloatClick(Sender: TObject);
  private
   { Private declarations }
  public
   { Public declarations }
  end;

var
  FormFloat: TFormFloat;

implementation

{$R *.dfm}

procedure TFormFloat.Button1Click(Sender: TObject);
begin
{$IFNDEF WIN64}
{$IFNDEF COMPILER5}
{$IFNDEF COMPILER6}
  if rdoBin.Checked then
    ShowMessage(FloatDecimalToBinExtended(StrToFloat(Edit1.Text), CheckBox1.Checked,
      CheckBox2.Checked))
  else if rdoOct.Checked then
    ShowMessage(FloatDecimalToOctExtended(StrToFloat(Edit1.Text), CheckBox1.Checked,
      CheckBox2.Checked))
  else
    ShowMessage(FloatDecimalToHexExtended(StrToFloat(Edit1.Text), CheckBox1.Checked,
      CheckBox2.Checked));
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;

procedure TFormFloat.btnExtractClick(Sender: TObject);
var
  SignNeg1, SignNeg2, SignNeg3: Boolean;
  Exponent1, Exponent2, Exponent3: Integer;
  Mantissa1: Cardinal;
  Mantissa2: TUInt64;
  Mantissa3: TUInt64;
  A1, A2: Single;
  B1, B2: Double;
  C1, C2: Extended;
begin
  A1 := -0.33;            // C3 F5 A8 BE ���ڴ��е����ݣ�����ʱ�ֽ���Ҫ������BEA8F5C3
  B1 := 1003.2354545;     // 91 09 F8 35 E2 59 8F 40������ʱͬ��������
  C1 := -88843453452.091981100001; // 97 60 BC 60 20 DC 7B A5 23 C0

  ExtractFloatSingle(A1, SignNeg1, Exponent1, Mantissa1);
  ExtractFloatDouble(B1, SignNeg2, Exponent2, Mantissa2);
  ExtractFloatExtended(C1, SignNeg3, Exponent3, Mantissa3);

  CombineFloatSingle(SignNeg1, Exponent1, Mantissa1, A2);
  CombineFloatDouble(SignNeg2, Exponent2, Mantissa2, B2);
  CombineFloatExtended(SignNeg3, Exponent3, Mantissa3, C2);

  if (A1 = A2) and (B1 = B2) and (C1 = C2) then
    ShowMessage('Float Extract and Combine OK.');
end;

procedure TFormFloat.btnUInt64ToFloatClick(Sender: TObject);
var
  U: TUInt64;
  D: Double;
  E: Extended;
begin
  U := -234567869758674564;
  ShowMessage(UInt64ToStr(U));

  D := UInt64ToDouble(U);
  ShowMessage(FloatToStr(D));

  E := UInt64ToExtended(U);
  ShowMessage(FloatToStr(E));
end;

end.
