unit UnitNative;

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnNative, ExtCtrls, Buttons, SysConst;

type
  TFormNative = class(TForm)
    btnUInt64Div: TButton;
    btnUInt64Mod: TButton;
    mmoRes: TMemo;
    bvl1: TBevel;
    btnStrUInt64: TButton;
    btnMul32: TButton;
    btnHighLowBits: TButton;
    btnInt64MulMod: TButton;
    btnUInt64Add: TButton;
    btnUInt64Mul: TButton;
    btnGetGT2Power: TButton;
    btnGetGT2Power64: TButton;
    edtPower: TEdit;
    btnPower: TSpeedButton;
    edtExponent: TEdit;
    btnRoot: TSpeedButton;
    btnURoot: TSpeedButton;
    edtUPower: TEdit;
    edtUExponent: TEdit;
    bvl2: TBevel;
    bvl3: TBevel;
    btnInt64AddMod: TButton;
    btnEndian: TButton;
    chkSwap: TCheckBox;
    btnConstTimeCondSwap: TButton;
    btnInt64DivMod: TButton;
    btnUInt64DivMod: TButton;
    btnInt128DivMod: TButton;
    btnUInt128DivMod: TButton;
    btnToBinTest: TButton;
    btnReverseBit: TButton;
    btn128Bit: TButton;
    btnU12864DivMod: TButton;
    btn12864DivMod: TButton;
    btnMemSort: TButton;
    btnUInt32ToStr: TButton;
    btnInt16ToLE: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnUInt64DivClick(Sender: TObject);
    procedure btnUInt64ModClick(Sender: TObject);
    procedure btnStrUInt64Click(Sender: TObject);
    procedure btnMul32Click(Sender: TObject);
    procedure btnHighLowBitsClick(Sender: TObject);
    procedure btnInt64MulModClick(Sender: TObject);
    procedure btnUInt64AddClick(Sender: TObject);
    procedure btnUInt64MulClick(Sender: TObject);
    procedure btnGetGT2PowerClick(Sender: TObject);
    procedure btnGetGT2Power64Click(Sender: TObject);
    procedure btnPowerClick(Sender: TObject);
    procedure btnRootClick(Sender: TObject);
    procedure btnURootClick(Sender: TObject);
    procedure btnInt64AddModClick(Sender: TObject);
    procedure btnEndianClick(Sender: TObject);
    procedure btnConstTimeCondSwapClick(Sender: TObject);
    procedure btnInt64DivModClick(Sender: TObject);
    procedure btnUInt64DivModClick(Sender: TObject);
    procedure btnInt128DivModClick(Sender: TObject);
    procedure btnUInt128DivModClick(Sender: TObject);
    procedure btnToBinTestClick(Sender: TObject);
    procedure btnReverseBitClick(Sender: TObject);
    procedure btn128BitClick(Sender: TObject);
    procedure btnU12864DivModClick(Sender: TObject);
    procedure btn12864DivModClick(Sender: TObject);
    procedure btnMemSortClick(Sender: TObject);
    procedure btnUInt32ToStrClick(Sender: TObject);
    procedure btnInt16ToLEClick(Sender: TObject);
  private

  public

  end;

var
  FormNative: TFormNative;

implementation

{$R *.DFM}

const
  A0: TUInt64 = 0;
  MIN_UINT64: TUInt64 = 0;
  MAX_UINT64: TUInt64 = $FFFFFFFFFFFFFFFF; // 18446744073709551615;
  MIN_INT64: TUInt64 = $8000000000000000;  // -9223372036854775808;
  MAX_INT64: TUInt64 = $7FFFFFFFFFFFFFFF; // 9223372036854775807;

var
  A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6, B7, B8: TUInt64;

procedure TFormNative.FormCreate(Sender: TObject);
begin
  // UInt64 �� div mod ��������������������� Int64 �ĽǶ���������A+B+��A-B-��A+B-��A-B+

  A1 := TUInt64(4227372036857772807);
  A2 := TUInt64(-2227372036857772807); // 16219372036851778809
  A3 := TUInt64(97372037857779845);
  A4 := TUInt64(-97372037857779845);   // 18349372035851771771
  A5 := $22222222FFFFFFFF;
  A6 := $FFFFFFFF22222222;
  A7 := $FEFEFEFEFEFEFEFE;
  A8 := $FEFEFEFEFEFEFEFE;
  B1 := TUInt64(84560395435344);
  B2 := TUInt64(-684560395435342);     // 18446059513314116274
  B3 := TUInt64(-784560395435344);     // 18445959513314116272
  B4 := TUInt64(64560395435344);
  B5 := $1111111111111111;
  B6 := $1111111111111111;
  B7 := $0000000033333333;
  B8 := $3333333300000000;
end;

procedure TFormNative.btnUInt64DivClick(Sender: TObject);
begin
  mmoRes.Clear;
  mmoRes.Lines.Add(UInt64ToStr(A0) + ' div ' + UInt64ToStr(B1) + ' = ' + UInt64ToStr(UInt64Div(A0, B1)));
  mmoRes.Lines.Add(UInt64ToStr(A1) + ' div ' + UInt64ToStr(B1) + ' = ' + UInt64ToStr(UInt64Div(A1, B1)));
  mmoRes.Lines.Add(UInt64ToStr(A2) + ' div ' + UInt64ToStr(B2) + ' = ' + UInt64ToStr(UInt64Div(A2, B2)));
  mmoRes.Lines.Add(UInt64ToStr(A3) + ' div ' + UInt64ToStr(B3) + ' = ' + UInt64ToStr(UInt64Div(A3, B3)));
  mmoRes.Lines.Add(UInt64ToStr(A4) + ' div ' + UInt64ToStr(B4) + ' = ' + UInt64ToStr(UInt64Div(A4, B4)));
  mmoRes.Lines.Add(UInt64ToStr(A5) + ' div ' + UInt64ToStr(B5) + ' = ' + UInt64ToStr(UInt64Div(A5, B5)));
  mmoRes.Lines.Add(UInt64ToStr(A6) + ' div ' + UInt64ToStr(B6) + ' = ' + UInt64ToStr(UInt64Div(A6, B6)));
  mmoRes.Lines.Add(UInt64ToStr(A7) + ' div ' + UInt64ToStr(B7) + ' = ' + UInt64ToStr(UInt64Div(A7, B7)));
  mmoRes.Lines.Add(UInt64ToStr(A8) + ' div ' + UInt64ToStr(B8) + ' = ' + UInt64ToStr(UInt64Div(A8, B8)));
{$IFDEF SUPPORT_UINT64}
  mmoRes.Lines.Add('');
  mmoRes.Lines.Add(UInt64ToStr(A0) + ' div ' + UInt64ToStr(B1) + ' = ' + UInt64ToStr(A0 div B1));
  mmoRes.Lines.Add(UInt64ToStr(A1) + ' div ' + UInt64ToStr(B1) + ' = ' + UInt64ToStr(A1 div B1));
  mmoRes.Lines.Add(UInt64ToStr(A2) + ' div ' + UInt64ToStr(B2) + ' = ' + UInt64ToStr(A2 div B2));
  mmoRes.Lines.Add(UInt64ToStr(A3) + ' div ' + UInt64ToStr(B3) + ' = ' + UInt64ToStr(A3 div B3));
  mmoRes.Lines.Add(UInt64ToStr(A4) + ' div ' + UInt64ToStr(B4) + ' = ' + UInt64ToStr(A4 div B4));
  mmoRes.Lines.Add(UInt64ToStr(A5) + ' div ' + UInt64ToStr(B5) + ' = ' + UInt64ToStr(A5 div B5));
  mmoRes.Lines.Add(UInt64ToStr(A6) + ' div ' + UInt64ToStr(B6) + ' = ' + UInt64ToStr(A6 div B6));
  mmoRes.Lines.Add(UInt64ToStr(A7) + ' div ' + UInt64ToStr(B7) + ' = ' + UInt64ToStr(A7 div B7));
  mmoRes.Lines.Add(UInt64ToStr(A8) + ' div ' + UInt64ToStr(B8) + ' = ' + UInt64ToStr(A8 div B8));
{$ENDIF}
end;

procedure TFormNative.btnUInt64ModClick(Sender: TObject);
begin
  mmoRes.Clear;
  mmoRes.Lines.Add(UInt64ToStr(A0) + ' mod ' + UInt64ToStr(B1) + ' = ' + UInt64ToStr(UInt64Mod(A0, B1)));
  mmoRes.Lines.Add(UInt64ToStr(A1) + ' mod ' + UInt64ToStr(B1) + ' = ' + UInt64ToStr(UInt64Mod(A1, B1)));
  mmoRes.Lines.Add(UInt64ToStr(A2) + ' mod ' + UInt64ToStr(B2) + ' = ' + UInt64ToStr(UInt64Mod(A2, B2)));
  mmoRes.Lines.Add(UInt64ToStr(A3) + ' mod ' + UInt64ToStr(B3) + ' = ' + UInt64ToStr(UInt64Mod(A3, B3)));
  mmoRes.Lines.Add(UInt64ToStr(A4) + ' mod ' + UInt64ToStr(B4) + ' = ' + UInt64ToStr(UInt64Mod(A4, B4)));
  mmoRes.Lines.Add(UInt64ToStr(A5) + ' mod ' + UInt64ToStr(B5) + ' = ' + UInt64ToStr(UInt64Mod(A5, B5)));
  mmoRes.Lines.Add(UInt64ToStr(A6) + ' mod ' + UInt64ToStr(B6) + ' = ' + UInt64ToStr(UInt64Mod(A6, B6)));
  mmoRes.Lines.Add(UInt64ToStr(A7) + ' mod ' + UInt64ToStr(B7) + ' = ' + UInt64ToStr(UInt64Mod(A7, B7)));
  mmoRes.Lines.Add(UInt64ToStr(A8) + ' mod ' + UInt64ToStr(B8) + ' = ' + UInt64ToStr(UInt64Mod(A8, B8)));
{$IFDEF SUPPORT_UINT64}
  mmoRes.Lines.Add('');
  mmoRes.Lines.Add(UInt64ToStr(A0) + ' mod ' + UInt64ToStr(B1) + ' = ' + UInt64ToStr(A0 mod B1));
  mmoRes.Lines.Add(UInt64ToStr(A1) + ' mod ' + UInt64ToStr(B1) + ' = ' + UInt64ToStr(A1 mod B1));
  mmoRes.Lines.Add(UInt64ToStr(A2) + ' mod ' + UInt64ToStr(B2) + ' = ' + UInt64ToStr(A2 mod B2));
  mmoRes.Lines.Add(UInt64ToStr(A3) + ' mod ' + UInt64ToStr(B3) + ' = ' + UInt64ToStr(A3 mod B3));
  mmoRes.Lines.Add(UInt64ToStr(A4) + ' mod ' + UInt64ToStr(B4) + ' = ' + UInt64ToStr(A4 mod B4));
  mmoRes.Lines.Add(UInt64ToStr(A5) + ' mod ' + UInt64ToStr(B5) + ' = ' + UInt64ToStr(A5 mod B5));
  mmoRes.Lines.Add(UInt64ToStr(A6) + ' mod ' + UInt64ToStr(B6) + ' = ' + UInt64ToStr(A6 mod B6));
  mmoRes.Lines.Add(UInt64ToStr(A7) + ' mod ' + UInt64ToStr(B7) + ' = ' + UInt64ToStr(A7 mod B7));
  mmoRes.Lines.Add(UInt64ToStr(A8) + ' mod ' + UInt64ToStr(B8) + ' = ' + UInt64ToStr(A8 mod B8));
{$ENDIF}
end;

procedure TFormNative.btnStrUInt64Click(Sender: TObject);
var
  A: TUInt64;
  S: string;
begin
  S := '10977225559701242671';
  A := StrToUInt64(S);
  mmoRes.Lines.Clear;
  mmoRes.Lines.Add(S + ' Converted to TUInt64.');
  mmoRes.Lines.Add(UInt64ToStr(A));
end;

procedure TFormNative.btnMul32Click(Sender: TObject);
var
  A, B: Cardinal;
  C: Int64;
{$IFDEF SUPPORT_UINT64}
  D: UInt64;
{$ENDIF}
begin
  A := $FFFFFFFF;
  B := $FFFFFFFE;
  C := UInt64Mul(A, B);
  mmoRes.Clear;
  mmoRes.Lines.Add(UInt64ToStr(C));
{$IFDEF SUPPORT_UINT64}
  D := UInt64(A) * B;
  mmoRes.Lines.Add(UInt64ToStr(D));
{$ENDIF}

end;

procedure TFormNative.btnHighLowBitsClick(Sender: TObject);
var
  H, L: Integer;
  T1: Cardinal;
  T2: TUInt64;               //    28
begin                        //    *                          1
  T1 := 349583946;           // 00010100110101100011101001001010
  T2 := 102849293434583456;  // 0000000101101101011001001110001100110000100100010111100110100000
                             //        *                                                  5
                             //        56

//  T1 := $FFFFFFFF;
//  T2 := $FFFFFFFFFFFFFFFC;
  H := GetUInt32HighBits(T1);
  L := GetUInt32LowBits(T1);
  mmoRes.Lines.Add(Format('32: High %d Low %d.', [H, L]));

  H := GetUInt64HighBits(T2);
  L := GetUInt64LowBits(T2);
  mmoRes.Lines.Add(Format('64: High %d Low %d.', [H, L]));
end;

procedure TFormNative.btnInt64MulModClick(Sender: TObject);
var
  A, B: Int64;
begin
  A := 3567798656;
  B := 3352796231;
  B := Int64NonNegativeMulMod(A, B, 4294967291);
  // B := UInt64NonNegativeMulMod(A, B, 4294967291);
  mmoRes.Lines.Add(IntToStr(B)); // Ҫ���� 1 �Ŷ�
end;

procedure TFormNative.btnUInt64AddClick(Sender: TObject);
var
  A, B, L, H: TUInt64;
begin
  A := CN_MAX_TUINT64;
  B := CN_MAX_TUINT64;

  UInt64AddUInt64(A, B, L, H);
  ShowMessage(UInt64ToHex(L));
  ShowMessage(UInt64ToHex(H));
end;

procedure TFormNative.btnUInt64MulClick(Sender: TObject);
var
  A, B, L, H: TUInt64;
begin
  A := $FFFFFFFFFFFFFF3C;
  B := $FFFFFFFFFFFFFF2E;

  UInt64MulUInt64(A, B, L, H);
  ShowMessage(UInt64ToHex(L));
  ShowMessage(UInt64ToHex(H));
end;

procedure TFormNative.btnGetGT2PowerClick(Sender: TObject);
var
  N, R: Cardinal;
begin
  N := Trunc(Random(MaxInt) * 2);
  R := GetUInt32PowerOf2GreaterEqual(N);
  ShowMessage(UInt64ToStr(N) + ' < ' + UInt64ToStr(R));
end;

procedure TFormNative.btnGetGT2Power64Click(Sender: TObject);
var
  N, R: TUInt64;
begin
  N := Trunc(Random(MaxInt) * 2);
  N := UInt64Mul(N, N);
  R := GetUInt64PowerOf2GreaterEqual(N);
  ShowMessage(UInt64ToStr(N) + ' < ' + UInt64ToStr(R));
end;

procedure TFormNative.btnPowerClick(Sender: TObject);
begin
  mmoRes.Lines.Text := IntToStr(Int64NonNegativPower(StrToInt64(edtPower.Text),
    StrToInt(edtExponent.Text))) + ' ' + UInt64ToStr(UInt64NonNegativPower(StrToUInt64(edtPower.Text),
    StrToInt(edtExponent.Text)));
end;

procedure TFormNative.btnRootClick(Sender: TObject);
var
  M: Int64;
begin
  M := Int64NonNegativeRoot(StrToInt64(edtPower.Text), StrToInt(edtExponent.Text));
  mmoRes.Lines.Text := IntToStr(M) + ' ' + IntToStr(Int64NonNegativPower(M, StrToInt(edtExponent.Text)));
end;

procedure TFormNative.btnURootClick(Sender: TObject);
var
  M: TUInt64;
begin
  M := UInt64NonNegativeRoot(StrToUInt64(edtUPower.Text), StrToInt(edtUExponent.Text));
  mmoRes.Lines.Text := UInt64ToStr(M);
end;

procedure TFormNative.btnInt64AddModClick(Sender: TObject);
var
  A, B, P: Int64;
begin
  // Caption := IntToStr(High(Int64));

  // ���� High(Int64) С���� A+B ���� Int64 ��Χ���������
  A := 9223372036854775783;  // $7FFFFFFFFFFFFFE7
  B := 8223372036854775782;  // $721F494C589BFFE6
  P := 1223372036854775783;  // $10FA4A62C4DFFFE7

  mmoRes.Lines.Add(IntToStr(Int64NonNegativeMod(A, P))); // 659767778871345302
  mmoRes.Lines.Add(IntToStr(Int64NonNegativeMod(B, P))); // 883139815726121084

  mmoRes.Lines.Add(IntToStr(Int64NonNegativeMod(A + B, P)));
  // ����������ӷ��õ� -1000000000000000051��ȡģ�õ� 223372036854775732�����ԣ�
  //                    $F21F494C589BFFCD

  mmoRes.Lines.Add(IntToStr(UInt64NonNegativeAddMod(A, B, P)));
  // ���� UInt64 �����ȡģ�Ļ�û��������ӷ��õ� 17446744073709551565��ȡģ�õ� 319535557742690603 ��ȷ��ģ
  //                                              $F21F494C589BFFCD

  mmoRes.Lines.Add(IntToStr(Int64NonNegativeAddMod(A, B, P)));
  // Ӧ�ú�����һ��

  mmoRes.Lines.Add('=====');

  // ���� Low(Int64) С���� A+B ���� Int64 ��Χ���������
  A := -9223372036854775783; // $8000000000000019
  B := -8223372036854775782; // $8DE0B6B3A764001A

  mmoRes.Lines.Add(IntToStr(Int64NonNegativeMod(A, P))); // 563604257983430481 �����ĵ� 659767778871345302 ���������� P
  mmoRes.Lines.Add(IntToStr(Int64NonNegativeMod(B, P))); // 340232221128654699 �����ĵ� 883139815726121084 ���������� P

  mmoRes.Lines.Add(IntToStr(Int64NonNegativeMod(A + B, P)));
  // ����������ӷ��õ� 1000000000000000051���� P С��ȡģ�õ� 1000000000000000051�����ԣ�
  //                    $0DE0B6B3A7640033

  mmoRes.Lines.Add(IntToStr(P - UInt64NonNegativeAddMod(-A, -B, P)));
  // ���� UInt64 �����ȡģ�Ļ�����Ӧ�õõ� -17446744073709551565��ȡģ��õ���ֵ���� P����û��ֱ����
  // ����������ӣ��ӷ��õ� 17446744073709551565��ȡģ�õ� 903836479112085180 ��ȷ��ģ�������ĵ� 319535557742690603 ���������� P
  //                          $F21F494C589BFFCD

  mmoRes.Lines.Add(IntToStr(Int64NonNegativeAddMod(A, B, P)));
  // Ӧ�ú�����һ��
end;

procedure TFormNative.btnEndianClick(Sender: TObject);
begin
  if CurrentByteOrderIsBigEndian then
    ShowMessage('Big Endian')
  else
    ShowMessage('Little Endian');
end;

procedure TFormNative.btnConstTimeCondSwapClick(Sender: TObject);
var
  A8, B8: Byte;
  A16, B16: Word;
  A32, B32: Cardinal;
  A64, B64: TUInt64;
  A, B: TBytes;
begin
  A8 := 45;
  B8 := 247;
  ConstTimeConditionalSwap8(chkSwap.Checked, A8, B8);
  mmoRes.Lines.Add(Format('%d, %d', [A8, B8]));

  A16 := 4502;
  B16 := 24701;
  ConstTimeConditionalSwap16(chkSwap.Checked, A16, B16);
  mmoRes.Lines.Add(Format('%d, %d', [A16, B16]));

  A32 := 45020001;
  B32 := 247010002;
  ConstTimeConditionalSwap32(chkSwap.Checked, A32, B32);
  mmoRes.Lines.Add(Format('%d, %d', [A32, B32]));

  A64 := 4502000199999283434;
  B64 := 4701000299999283434;
  ConstTimeConditionalSwap64(chkSwap.Checked, A64, B64);
  mmoRes.Lines.Add(Format('%d, %d', [A64, B64]));

  A := AnsiToBytes('123');
  B := AnsiToBytes('123');
  if ConstTimeBytesEqual(A, B) then
    mmoRes.Lines.Add('2 Bytes Equal');
end;

procedure TFormNative.btnInt64DivModClick(Sender: TObject);
var
  A: Int64;
  B: Integer;
  D, R: Integer;
begin
  A := $DDDDFFFFFFFF;
  B := 10000000;
  Int64DivInt32Mod(A, B, D, R);
  mmoRes.Lines.Add(Format('%d / %d = %d ... %d', [A, B, D, R]));
end;

procedure TFormNative.btnUInt64DivModClick(Sender: TObject);
var
  A: TUInt64;
  B: Cardinal;
  D, R: Cardinal;
begin
  A := $DDDDFFFFFFFF;
  B := 10000000;
  UInt64DivUInt32Mod(A, B, D, R);
  mmoRes.Lines.Add(Format('%d / %d = %d ... %d', [A, B, D, R]));
end;

procedure TFormNative.btnInt128DivModClick(Sender: TObject);
{$IFDEF CPUX64}
var
  L, H, B, D, R: Int64;
{$ENDIF}
begin
{$IFDEF CPUX64}
  L := $F0000000E0000000;
  H := $0000000007770000;
  B := $99999999999;
  Int128DivInt64Mod(L, H, B, D, R);

  mmoRes.Lines.Add(IntToStr(H)+IntToStr(L) + ' / ' + IntToStr(B) + ' = ' + IntToStr(D) + ' ... ' + IntToStr(R));
{$ENDIF}
end;

procedure TFormNative.btnUInt128DivModClick(Sender: TObject);
{$IFDEF CPUX64}
var
  L, H, B, D, R: TUInt64;
{$ENDIF}
begin
{$IFDEF CPUX64}
  L := $F0000000E0000000;
  H := $0000000007770000;
  B := $99999999999;
  UInt128DivUInt64Mod(L, H, B, D, R);

  mmoRes.Lines.Add(IntToStr(H)+IntToStr(L) + ' / ' + IntToStr(B) + ' = ' + IntToStr(D) + ' ... ' + IntToStr(R));
{$ENDIF}
end;

procedure TFormNative.btnToBinTestClick(Sender: TObject);
var
  V1: Byte;
  V2: Word;
  V3: Cardinal;
  V4: TUInt64;
  V5: array[0..1] of TUInt64;
begin
  V1 := 56;
  V2 := 65531;
  V3 := 987654456;
  V4 := 3409732345677742456;
  V5[0] := $FFEEDDCC000000FF;
  V5[1] := $1100000099887766;

  mmoRes.Lines.Add(UInt8ToBinStr(V1));
  mmoRes.Lines.Add(UInt16ToBinStr(V2));
  mmoRes.Lines.Add(UInt32ToBinStr(V3));
  mmoRes.Lines.Add(UInt64ToBinStr(V4));
  mmoRes.Lines.Add('');
  mmoRes.Lines.Add(MemoryToBinStr(@(V5[0]), SizeOf(V5), True));

  MemoryShiftLeft(@(V5[0]), nil, SizeOf(V5), 15);
  mmoRes.Lines.Add(MemoryToBinStr(@(V5[0]), SizeOf(V5), True));

  V5[0] := $FFEEDDCC000000FF;
  V5[1] := $1100000099887766;
  mmoRes.Lines.Add('');
  mmoRes.Lines.Add(MemoryToBinStr(@(V5[0]), SizeOf(V5), True));
  MemoryShiftRight(@(V5[0]), nil, SizeOf(V5), 9);
  mmoRes.Lines.Add(MemoryToBinStr(@(V5[0]), SizeOf(V5), True));
end;

procedure TFormNative.btnReverseBitClick(Sender: TObject);
var
  B: Byte;
  W: Word;
  C: Cardinal;
  I: Int64;
begin
  B := $53;
  mmoRes.Lines.Add(MemoryToBinStr(@B, SizeOf(B)));
  B := ReverseBitsInInt8(B);
  mmoRes.Lines.Add(MemoryToBinStr(@B, SizeOf(B)));

  W := $57EA;  // x86 ���� EA 57������
  mmoRes.Lines.Add(MemoryToBinStr(@W, SizeOf(W)));
  W := ReverseBitsInInt16(W);
  mmoRes.Lines.Add(MemoryToBinStr(@W, SizeOf(W)));

  C := $8D3906E4;
  mmoRes.Lines.Add(MemoryToBinStr(@C, SizeOf(C)));
  C := ReverseBitsInInt32(C);
  mmoRes.Lines.Add(MemoryToBinStr(@C, SizeOf(C)));

  I := $1122334455667788;  // $8D3906E40923EB10;
  mmoRes.Lines.Add(MemoryToBinStr(@I, SizeOf(I)));
  I := ReverseBitsInInt64(I);
  mmoRes.Lines.Add(MemoryToBinStr(@I, SizeOf(I)));
end;

procedure TFormNative.btn128BitClick(Sender: TObject);
var
  L, H: TUInt64;

  procedure PrintValue;
  var
    LL, HH: TUInt64;
  begin
    LL := Int64HostToNetwork(L);
    HH := Int64HostToNetwork(H);
    mmoRes.Lines.Add(MemoryToBinStr(@HH, SizeOf(HH)) + MemoryToBinStr(@LL, SizeOf(LL)));
  end;

  procedure PrintSet(N: Integer; BitSet: Boolean);
  begin
    if BitSet then
      mmoRes.Lines.Add(Format('%d Bit is set', [N]))
    else
      mmoRes.Lines.Add(Format('%d Bit Cleared', [N]));
  end;

begin
  L := 0;
  H := 0;

  SetUInt128Bit(L, H, 64);
  PrintValue;
  SetUInt128Bit(L, H, 63);
  PrintValue;
  SetUInt128Bit(L, H, 127);
  PrintValue;
  SetUInt128Bit(L, H, 0);
  PrintValue;

  PrintSet(0, IsUInt128BitSet(L, H, 0));
  PrintSet(62, IsUInt128BitSet(L, H, 62));
  PrintSet(64, IsUInt128BitSet(L, H, 64));
  PrintSet(123, IsUInt128BitSet(L, H, 123));
  PrintSet(127, IsUInt128BitSet(L, H, 127));

  ClearUInt128Bit(L, H, 0);
  PrintValue;
  ClearUInt128Bit(L, H, 63);
  PrintValue;
  ClearUInt128Bit(L, H, 64);
  PrintValue;
  ClearUInt128Bit(L, H, 127);
  PrintValue;
end;

// ���ϸ��ͬ�� UInt128DivUInt64Mod ��ʵ��
procedure MyUInt128DivUInt64Mod(ALo, AHi: TUInt64; B: TUInt64; var DivRes, ModRes: TUInt64);
var
  I, Cnt: Integer;
  Q, R: TUInt64;
begin
  if B = 0 then
    raise EDivByZero.Create(SDivByZero);

  if AHi = 0 then
  begin
    DivRes := UInt64Div(ALo, B);
    ModRes := UInt64Mod(ALo, B);
  end
  else
  begin
    // �и�λ�е�λզ�죿���ж��Ƿ���������� AHi >= B�����ʾ��Ҫ�� 64 λ�����
    if UInt64Compare(AHi, B) >= 0 then
      raise Exception.Create(SIntOverflow);

    Q := 0;
    R := 0;
    Cnt := GetUInt64LowBits(AHi) + 64;
    for I := Cnt downto 0 do
    begin
      R := R shl 1;
      if IsUInt128BitSet(ALo, AHi, I) then  // �������ĵ� I λ�Ƿ��� 0
        R := R or 1
      else
        R := R and not TUInt64(1);

      if UInt64Compare(R, B) >= 0 then
      begin
        R := R - B;
        Q := Q or (TUInt64(1) shl I);
      end;
    end;
    DivRes := Q;
    ModRes := R;
  end;
end;

procedure TFormNative.btnU12864DivModClick(Sender: TObject);
var
  L, H, B, Q, R: TUInt64;

  procedure Print;
  var
    S: string;
  begin
    if H = 0 then
      S := Format('%s / %s = %s ... %s',[UInt64ToStr(L), UInt64ToStr(B),
        UInt64ToStr(Q), UInt64ToStr(R)])
    else
    S := Format('%s|%s / %s = %s ... %s',[UInt64ToStr(H), UInt64ToStr(L), UInt64ToStr(B),
      UInt64ToStr(Q), UInt64ToStr(R)]);
    mmoRes.Lines.Add(S);
  end;

begin
  L := 0;
  H := 0;
  B := 1;
  MyUInt128DivUInt64Mod(L, H, B, Q, R);
  Print;

  L := 13;
  H := 0;
  B := 4;
  MyUInt128DivUInt64Mod(L, H, B, Q, R);
  Print;

  // 18446744073709551616 + 5000000000000000004
  L := 5000000000000000004;
  H := 1;
  B := 10;
  MyUInt128DivUInt64Mod(L, H, B, Q, R);
  Print;

  L := 5000000000000000004;
  H := 1;
  B := 12;
  MyUInt128DivUInt64Mod(L, H, B, Q, R);
  Print;
end;

// ���ϸ��ͬ�� Int128DivUInt64Mod ��ʵ�֣������ڲ��ݹ��������� My
procedure MyInt128DivInt64Mod(ALo, AHi: Int64; B: Int64; var DivRes, ModRes: Int64);
var
  C: Integer;
begin
  if B = 0 then
    raise EDivByZero.Create(SDivByZero);

  if (AHi = 0) or (AHi = $FFFFFFFFFFFFFFFF) then // �� 64 λΪ 0 ����ֵ��ֵ
  begin
    DivRes := ALo div B;
    ModRes := ALo mod B;
  end
  else
  begin
    if B < 0 then // �����Ǹ���
    begin
      MyInt128DivInt64Mod(ALo, AHi, -B, DivRes, ModRes);
      DivRes := -DivRes;
      Exit;
    end;

    if AHi < 0 then // �������Ǹ���
    begin
      // AHi, ALo �󷴼� 1���Եõ���ֵ
      AHi := not AHi;
      ALo := not ALo;
{$IFDEF SUPPORT_UINT64}
      UInt64Add(UInt64(ALo), UInt64(ALo), 1, C);
{$ELSE}
      UInt64Add(ALo, ALo, 1, C);
{$ENDIF}
      if C > 0 then
        AHi := AHi + C;

      // ������ת����
      MyInt128DivInt64Mod(ALo, AHi, B, DivRes, ModRes);

      // ����ٵ���
      if ModRes = 0 then
        DivRes := -DivRes
      else
      begin
        DivRes := -DivRes - 1;
        ModRes := B - ModRes;
      end;
      Exit;
    end;

    // ȫ���󣬰��޷�������
{$IFDEF SUPPORT_UINT64}
    UInt128DivUInt64Mod(TUInt64(ALo), TUInt64(AHi), TUInt64(B), TUInt64(DivRes), TUInt64(ModRes));
{$ELSE}
    UInt128DivUInt64Mod(ALo, AHi, B, DivRes, ModRes);
{$ENDIF}
  end;
end;

procedure TFormNative.btn12864DivModClick(Sender: TObject);
var
  L, H, B, Q, R: Int64;

  procedure Print;
  var
    S: string;
  begin
    if H = 0 then
      S := Format('%s / %s = %s ... %s',[IntToStr(L), IntToStr(B),
        IntToStr(Q), IntToStr(R)])
    else
    S := Format('%s|%s / %s = %s ... %s',[IntToStr(H), UInt64ToStr(L), IntToStr(B),
      IntToStr(Q), IntToStr(R)]);
    mmoRes.Lines.Add(S);
  end;

begin
  L := 13;
  H := 0;
  B := -4;
  MyInt128DivInt64Mod(L, H, B, Q, R);
  Print;

  L := -5000000000000000004;
  H := not 0;
  B := 10;
  MyInt128DivInt64Mod(L, H, B, Q, R);
  Print;
end;

procedure QuickSort(B: PByteArray; L, R: Integer);
var
  I, J, P: Integer;
  T: Byte;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while B^[I] < B^[P] do Inc(I);
      while B^[J] > B^[P] do Dec(J);
      if I <= J then
      begin
        T := B^[I];
        B^[I] := B^[J];
        B^[J] := T;

        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(B, L, J);
    L := I;
  until I >= R;
end;

procedure TFormNative.btnMemSortClick(Sender: TObject);
var
  D: array[0..8] of Byte;
begin
  D[0] := 0;
  D[1] := 1;
  D[2] := 2;
  D[3] := 9;
  D[4] := 4;
  D[5] := 5;
  D[6] := 6;
  D[7] := 7;
  D[8] := 8;
  QuickSort(@D[0], 0, SizeOf(D) - 1);
  mmoRes.Lines.Add(DataToHex(@D[0], SizeOf(D)));

  D[0] := 8;
  D[1] := 7;
  D[2] := 6;
  D[3] := 5;
  D[4] := 4;
  D[5] := 3;
  D[6] := 2;
  D[7] := 1;
  D[8] := 0;

  MemoryQuickSort(@D[0], 1, SizeOf(D));
  mmoRes.Lines.Add(DataToHex(@D[0], SizeOf(D)));
end;

procedure TFormNative.btnUInt32ToStrClick(Sender: TObject);
begin
  mmoRes.Lines.Add(UInt32ToStr(Cardinal(-1)));
end;

procedure TFormNative.btnInt16ToLEClick(Sender: TObject);
var
  C: Cardinal;
begin
  C := 28057;
  C := Int16ToBigEndian(C);
  ShowMessage(IntToStr(C));

  C := 28057;
  C := UInt16ToBigEndian(C);
  ShowMessage(IntToStr(C));
end;

end.

