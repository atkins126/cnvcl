unit UnitPolynomial;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Contnrs, CnPolynomial, CnECC;

type
  TFormPolynomial = class(TForm)
    pgcPoly: TPageControl;
    tsIntegerPolynomial: TTabSheet;
    grpIntegerPolynomial: TGroupBox;
    btnIPCreate: TButton;
    edtIP1: TEdit;
    bvl1: TBevel;
    mmoIP1: TMemo;
    mmoIP2: TMemo;
    btnIP1Random: TButton;
    btnIP2Random: TButton;
    lblDeg1: TLabel;
    lblDeg2: TLabel;
    edtIPDeg1: TEdit;
    edtIPDeg2: TEdit;
    btnIPAdd: TButton;
    btnIPSub: TButton;
    btnIPMul: TButton;
    btnIPDiv: TButton;
    lblIPEqual: TLabel;
    edtIP3: TEdit;
    btnTestExample1: TButton;
    btnTestExample2: TButton;
    bvl2: TBevel;
    btnTestExample3: TButton;
    btnTestExample4: TButton;
    tsExtensionEcc: TTabSheet;
    grpEccGalois: TGroupBox;
    btnGaloisOnCurve: TButton;
    btnPolyGcd: TButton;
    btnGaloisTestGcd: TButton;
    btnTestGaloisMI: TButton;
    btnGF28Test1: TButton;
    btnEccPointAdd: TButton;
    btnTestEccPointAdd2: TButton;
    btnTestDivPoly: TButton;
    btnTestDivPoly2: TButton;
    btnTestGaloisPoint2: TButton;
    btnTestPolyPoint2: TButton;
    btnTestPolyEccPoint3: TButton;
    btnTestPolyAdd2: TButton;
    btnTestGaloisPolyMulMod: TButton;
    btnTestGaloisModularInverse1: TButton;
    btnTestEuclid2: TButton;
    btnTestExtendEuclid3: TButton;
    btnTestGaloisDiv: TButton;
    btnTestEccDivisionPoly3: TButton;
    mmoTestDivisionPolynomial: TMemo;
    btnGenerateDivisionPolynomial: TButton;
    tsRationalPolynomial: TTabSheet;
    grpRationalPolynomial: TGroupBox;
    btnRP2Point: TButton;
    bvl3: TBevel;
    edtRationalNominator1: TEdit;
    lbl1: TLabel;
    edtRationalDenominator1: TEdit;
    btnRationalPolynomialAdd: TButton;
    btnRationalPolynomialSub: TButton;
    btnRationalPolynomialMul: TButton;
    btnRationalPolynomialDiv: TButton;
    chkRationalPolynomialGalois: TCheckBox;
    edtRationalPolynomialPrime: TEdit;
    edtRationalNominator2: TEdit;
    lbl2: TLabel;
    edtRationalDenominator2: TEdit;
    lbl3: TLabel;
    lbl4: TLabel;
    btnRationalPolynomialGenerate: TButton;
    edtRationalResultNominator: TEdit;
    edtRationalResultDenominator: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnIPCreateClick(Sender: TObject);
    procedure btnIP1RandomClick(Sender: TObject);
    procedure btnIP2RandomClick(Sender: TObject);
    procedure btnIPAddClick(Sender: TObject);
    procedure btnIPSubClick(Sender: TObject);
    procedure btnIPMulClick(Sender: TObject);
    procedure btnIPDivClick(Sender: TObject);
    procedure btnTestExample1Click(Sender: TObject);
    procedure btnTestExample2Click(Sender: TObject);
    procedure btnTestExample3Click(Sender: TObject);
    procedure btnTestExample4Click(Sender: TObject);
    procedure btnGaloisOnCurveClick(Sender: TObject);
    procedure btnPolyGcdClick(Sender: TObject);
    procedure btnGaloisTestGcdClick(Sender: TObject);
    procedure btnTestGaloisMIClick(Sender: TObject);
    procedure btnGF28Test1Click(Sender: TObject);
    procedure btnEccPointAddClick(Sender: TObject);
    procedure btnTestEccPointAdd2Click(Sender: TObject);
    procedure btnTestDivPolyClick(Sender: TObject);
    procedure btnTestDivPoly2Click(Sender: TObject);
    procedure btnTestGaloisPoint2Click(Sender: TObject);
    procedure btnTestPolyPoint2Click(Sender: TObject);
    procedure btnTestPolyEccPoint3Click(Sender: TObject);
    procedure btnTestPolyAdd2Click(Sender: TObject);
    procedure btnTestGaloisPolyMulModClick(Sender: TObject);
    procedure btnTestGaloisModularInverse1Click(Sender: TObject);
    procedure btnTestEuclid2Click(Sender: TObject);
    procedure btnTestExtendEuclid3Click(Sender: TObject);
    procedure btnTestGaloisDivClick(Sender: TObject);
    procedure btnTestEccDivisionPoly3Click(Sender: TObject);
    procedure btnGenerateDivisionPolynomialClick(Sender: TObject);
    procedure btnRP2PointClick(Sender: TObject);
    procedure btnRationalPolynomialGenerateClick(Sender: TObject);
    procedure btnRationalPolynomialAddClick(Sender: TObject);
    procedure btnRationalPolynomialSubClick(Sender: TObject);
    procedure btnRationalPolynomialMulClick(Sender: TObject);
    procedure btnRationalPolynomialDivClick(Sender: TObject);
  private
    FIP1: TCnInt64Polynomial;
    FIP2: TCnInt64Polynomial;
    FIP3: TCnInt64Polynomial;
    FRP1: TCnInt64RationalPolynomial;
    FRP2: TCnInt64RationalPolynomial;
    FRP3: TCnInt64RationalPolynomial;
  public
    { Public declarations }
  end;

var
  FormPolynomial: TFormPolynomial;

implementation

{$R *.DFM}

procedure TFormPolynomial.FormCreate(Sender: TObject);
begin
  FIP1 := TCnInt64Polynomial.Create;
  FIP2 := TCnInt64Polynomial.Create;
  FIP3 := TCnInt64Polynomial.Create;

  FRP1 := TCnInt64RationalPolynomial.Create;
  FRP2 := TCnInt64RationalPolynomial.Create;
  FRP3 := TCnInt64RationalPolynomial.Create;
end;

procedure TFormPolynomial.FormDestroy(Sender: TObject);
begin
  FRP1.Free;
  FRP2.Free;
  FRP3.Free;

  FIP1.Free;
  FIP2.Free;
  FIP3.Free;
end;

procedure TFormPolynomial.btnIPCreateClick(Sender: TObject);
var
  IP: TCnInt64Polynomial;
begin
  IP := TCnInt64Polynomial.Create([23, 4, -45, 6, -78, 23, 34, 1, 0, -34, 4]);
  edtIP1.Text := IP.ToString;
  IP.Free;
end;

procedure TFormPolynomial.btnIP1RandomClick(Sender: TObject);
var
  I, D: Integer;
begin
  D := StrToIntDef(edtIPDeg1.Text, 10);
  FIP1.Clear;
  Randomize;
  for I := 0 to D do
    FIP1.Add(Random(256) - 128);
  mmoIP1.Lines.Text := FIP1.ToString;
end;

procedure TFormPolynomial.btnIP2RandomClick(Sender: TObject);
var
  I, D: Integer;
begin
  D := StrToIntDef(edtIPDeg2.Text, 10);
  FIP2.Clear;
  Randomize;
  for I := 0 to D do
    FIP2.Add(Random(256) - 128);
  mmoIP2.Lines.Text := FIP2.ToString;
end;

procedure TFormPolynomial.btnIPAddClick(Sender: TObject);
begin
  if Int64PolynomialAdd(FIP3, FIP1, FIP2) then
    edtIP3.Text := FIP3.ToString;
end;

procedure TFormPolynomial.btnIPSubClick(Sender: TObject);
begin
  if Int64PolynomialSub(FIP3, FIP1, FIP2) then
    edtIP3.Text := FIP3.ToString;
end;

procedure TFormPolynomial.btnIPMulClick(Sender: TObject);
begin
  if Int64PolynomialMul(FIP3, FIP1, FIP2) then
    edtIP3.Text := FIP3.ToString;
end;

procedure TFormPolynomial.btnIPDivClick(Sender: TObject);
var
  R: TCnInt64Polynomial;
begin
  R := TCnInt64Polynomial.Create;

  // ���Դ���
//  FIP1.SetCoefficents([1, 2, 3]);
//  FIP2.SetCoefficents([2, 1]);
//  if Int64PolynomialDiv(FIP3, R, FIP1, FIP2) then
//  begin
//    edtIP3.Text := FIP3.ToString;          // 3X - 4
//    ShowMessage('Remain: ' + R.ToString);  // 9
//  end;
  // ���Դ���

  if FIP2[FIP2.MaxDegree] <> 1 then
  begin
    ShowMessage('Divisor MaxDegree only Support 1, change to 1');
    FIP2[FIP2.MaxDegree] := 1;
    mmoIP2.Lines.Text := FIP2.ToString;
  end;

  if Int64PolynomialDiv(FIP3, R, FIP1, FIP2) then
  begin
    edtIP3.Text := FIP3.ToString;
    ShowMessage('Remain: ' + R.ToString);
  end;

  // ���� FIP3 * FIP2 + R
  Int64PolynomialMul(FIP3, FIP3, FIP2);
  Int64PolynomialAdd(FIP3, FIP3, R);
  ShowMessage(FIP3.ToString);
  if mmoIP1.Lines.Text = FIP3.ToString then
    ShowMessage('Equal Verified OK.');
  R.Free;
end;

procedure TFormPolynomial.btnTestExample1Click(Sender: TObject);
var
  X, Y, P: TCnInt64Polynomial;
begin
{
  ����һ��
  ����һ��������Ķ������� 67*67����ָ���䱾ԭ����ʽ�� u^2 + 1 = 0��
  Ȼ�������湹��һ����Բ���� y^2 = x^3 + 4x + 3��ѡһ���� 2u + 16, 30u + 39
  ��֤������ڸ���Բ�����ϡ���ע�� n �������ϵ���Բ�����ϵĵ��������һ�� n �ζ���ʽ��

  ����������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 2.2.5

  ����ʵ�־��Ǽ���(Y^2 - X^3 - A*X - B) mod Primtive��Ȼ��ÿ��ϵ������ʱ��Ҫ mod p
  ���� A = 4��B = 3��
  ���������ϣ�p ������ 67����ԭ����ʽ�� u^2 + 1
}

  X := TCnInt64Polynomial.Create([16, 2]);
  Y := TCnInt64Polynomial.Create([39, 30]);
  P := TCnInt64Polynomial.Create([1, 0, 1]);
  try
    Int64PolynomialGaloisMul(Y, Y, Y, 67, P); // Y^2 �õ� 62X + 18

    Int64PolynomialMulWord(X, 4);
    Int64PolynomialSub(Y, Y, X);
    Int64PolynomialSubWord(Y, 3);             // Y ��ȥ�� A*X - B���õ� 54X + 18
    Int64PolynomialNonNegativeModWord(Y, 67);

    X.SetCoefficents([16, 2]);
    Int64PolynomialGaloisPower(X, X, 3, 67, P);  // �õ� 54X + 18


    Int64PolynomialSub(Y, Y, X);
    Int64PolynomialMod(Y, Y, P);    // ��� 0
    ShowMessage(Y.ToString);
  finally
    P.Free;
    Y.Free;
    X.Free;
  end;
end;

procedure TFormPolynomial.btnTestExample2Click(Sender: TObject);
var
  X, Y, P: TCnInt64Polynomial;
begin
{
  ��������
  ����һ��������Ķ������� 7691*7691����ָ���䱾ԭ����ʽ�� u^2 + 1 = 0��
  Ȼ�������湹��һ����Բ���� y^2=x^3+1 mod 7691��ѡһ���� 633u + 6145, 7372u + 109
  ��֤������ڸ���Բ�����ϡ�

  ����������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 4.0.1

  ����ʵ�־��Ǽ���(Y^2 - X^3 - A*X - B) mod Primtive��Ȼ��ÿ��ϵ������ʱ��Ҫ mod p
  ���� A = 0��B = 1
  ���������ϣ�p ������ 7691����ԭ����ʽ�� u^2 + 1
}

  X := TCnInt64Polynomial.Create([6145, 633]);
  Y := TCnInt64Polynomial.Create([109, 7372]);
  P := TCnInt64Polynomial.Create([1, 0, 1]);
  try
    Int64PolynomialGaloisMul(Y, Y, Y, 7691, P);

    Int64PolynomialSubWord(Y, 1);
    Int64PolynomialNonNegativeModWord(Y, 7691);

    X.SetCoefficents([6145, 633]);
    Int64PolynomialGaloisPower(X, X, 3, 7691, P);

    Int64PolynomialSub(Y, Y, X);
    Int64PolynomialMod(Y, Y, P);    // ��� 0
    ShowMessage(Y.ToString);
  finally
    P.Free;
    Y.Free;
    X.Free;
  end;
end;

procedure TFormPolynomial.btnTestExample3Click(Sender: TObject);
var
  X, P: TCnInt64Polynomial;
begin
{
  ��������
  ����һ��������Ķ������� 67*67����ָ���䱾ԭ����ʽ�� u^2 + 1 = 0��
  ��֤��(2u + 16)^67 = 65u + 16, (30u + 39)^67 = 37u + 39

  ��������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 2.2.5
}

  X := TCnInt64Polynomial.Create([16, 2]);
  P := TCnInt64Polynomial.Create([1, 0, 1]);
  try
    Int64PolynomialGaloisPower(X, X, 67, 67, P);
    ShowMessage(X.ToString);

    X.SetCoefficents([39, 30]);
    Int64PolynomialGaloisPower(X, X, 67, 67, P);
    ShowMessage(X.ToString);
  finally
    X.Free;
    P.Free;
  end;
end;

procedure TFormPolynomial.btnTestExample4Click(Sender: TObject);
var
  X, P: TCnInt64Polynomial;
begin
{
  �����ģ�
  ����һ����������������� 67*67*67����ָ���䱾ԭ����ʽ�� u^3 + 2 = 0��
  ��֤��
  (15v^2 + 4v + 8)^67  = 33v^2 + 14v + 8, 44v^2 + 30v + 21)^67 = 3v^2 + 38v + 21
  (15v^2 + 4v + 8)^(67^2)  = 19v^2 + 49v + 8, (44v^2 + 30v + 21)^(67^2) = 20v^2 + 66v + 21
  (15v^2 + 4v + 8)^(67^3)  = 15v^2 + 4v + 8,  (44v^2 + 30v + 21)^(67^3) = 44v^2 + 30v + 21 ���ص�����

  ��������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 2.2.5
}

  X := TCnInt64Polynomial.Create;
  P := TCnInt64Polynomial.Create([2, 0, 0, 1]);
  try
    X.SetCoefficents([8, 4, 15]);
    Int64PolynomialGaloisPower(X, X, 67, 67, P);
    ShowMessage(X.ToString);

    X.SetCoefficents([21, 30, 44]);
    Int64PolynomialGaloisPower(X, X, 67, 67, P);
    ShowMessage(X.ToString);

    X.SetCoefficents([8, 4, 15]);
    Int64PolynomialGaloisPower(X, X, 67 * 67, 67, P);
    ShowMessage(X.ToString);

    X.SetCoefficents([21, 30, 44]);
    Int64PolynomialGaloisPower(X, X, 67 * 67, 67, P);
    ShowMessage(X.ToString);

    X.SetCoefficents([8, 4, 15]);
    Int64PolynomialGaloisPower(X, X, 67 * 67 * 67, 67, P);
    ShowMessage(X.ToString);

    X.SetCoefficents([21, 30, 44]);
    Int64PolynomialGaloisPower(X, X, 67 * 67 * 67, 67, P);
    ShowMessage(X.ToString);
  finally
    X.Free;
    P.Free;
  end;
end;

procedure TFormPolynomial.btnGaloisOnCurveClick(Sender: TObject);
var
  Ecc: TCnInt64PolynomialEcc;
begin
{
  ����һ��
  ��Բ���� y^2 = x^3 + 4x + 3, ��������ڶ������� F67^2 �ϣ���ԭ����ʽ u^2 + 1
  �жϻ��� P(2u+16, 30u+39) ��������

  ��������
  ��Բ���� y^2 = x^3 + 4x + 3, ����������������� F67^3 �ϣ���ԭ����ʽ u^3 + 2
  �жϻ��� P((15v^2 + 4v + 8, 44v^2 + 30v + 21)) ��������

  ��������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 2.2.8
}

  Ecc := TCnInt64PolynomialEcc.Create(4, 3, 67, 2, [16, 2], [39, 30], 0, [1, 0,
    1]); // Order δָ�����Ȳ���
  if Ecc.IsPointOnCurve(Ecc.Generator) then
    ShowMessage('Ecc 1 Generator is on Curve')
  else
    ShowMessage('Error');

  Ecc.Free;

  Ecc := TCnInt64PolynomialEcc.Create(4, 3, 67, 3, [8, 4, 15], [21, 30, 44], 0,
    [2, 0, 0, 1]); // Order δָ�����Ȳ���
  if Ecc.IsPointOnCurve(Ecc.Generator) then
    ShowMessage('Ecc 2 Generator is on Curve')
  else
    ShowMessage('Error');

  Ecc.Free;
end;

procedure TFormPolynomial.btnPolyGcdClick(Sender: TObject);
begin
  if (FIP2[FIP2.MaxDegree] <> 1) and (FIP2[FIP2.MaxDegree] <> 1) then
  begin
    ShowMessage('Divisor MaxDegree only Support 1, change to 1');
    FIP1[FIP1.MaxDegree] := 1;
    mmoIP1.Lines.Text := FIP1.ToString;
    FIP2[FIP2.MaxDegree] := 1;
    mmoIP2.Lines.Text := FIP2.ToString;
  end;

//  FIP1.SetCoefficents([-5, 2, 0, 3]);
//  FIP2.SetCoefficents([-1, -2, 0, 3]);
  if Int64PolynomialGreatestCommonDivisor(FIP3, FIP1, FIP2) then
    edtIP3.Text := FIP3.ToString;
end;

procedure TFormPolynomial.btnGaloisTestGcdClick(Sender: TObject);
begin
// GCD ����һ��
// F11 �����ϵ� x^2 + 8x + 7 �� x^3 + 7x^2 + x + 7 �������ʽ�� x + 7
  FIP1.SetCoefficents([7, 8, 1]);
  FIP2.SetCoefficents([7, 1, 7, 1]);  // ���� [7, 1, 2, 1] ����
  if Int64PolynomialGaloisGreatestCommonDivisor(FIP3, FIP1, FIP2, 11) then
    ShowMessage(FIP3.ToString);

// GCD ���Ӷ���
// F2 �����ϵ� x^6 + x^5 + x^4 + x^3 + x^2 + x + 1 �� x^4 + x^2 + x + 1 �������ʽ�� x^3 + x^2 + 1
  FIP1.SetCoefficents([1,1,1,1,1,1,1]);
  FIP2.SetCoefficents([1,1,1,0,1]);
  if Int64PolynomialGaloisGreatestCommonDivisor(FIP3, FIP1, FIP2, 2) then
    edtIP3.Text := FIP3.ToString;
end;

procedure TFormPolynomial.btnTestGaloisMIClick(Sender: TObject);
begin
// Modulus Inverse ���ӣ�
// F3 �������ϵı�ԭ����ʽ x^3 + 2x + 1 �� x^2 + 1 ��ģ�����ʽΪ 2x^2 + x + 2
  FIP1.SetCoefficents([1, 0, 1]);
  FIP2.SetCoefficents([1, 2, 0, 1]);
  Int64PolynomialGaloisModularInverse(FIP3, FIP1, FIP2, 3);
    edtIP3.Text := FIP3.ToString;
end;

procedure TFormPolynomial.btnGF28Test1Click(Sender: TObject);
var
  IP: TCnInt64Polynomial;
begin
  FIP1.SetCoefficents([1,1,1,0,1,0,1]); // 57
  FIP2.SetCoefficents([1,1,0,0,0,0,0,1]); // 83
  FIP3.SetCoefficents([1,1,0,1,1,0,0,0,1]); // ��ԭ����ʽ

  IP := TCnInt64Polynomial.Create;
  Int64PolynomialGaloisMul(IP, FIP1, FIP2, 2, FIP3);
  edtIP3.Text := IP.ToString;  // �õ� 1,0,0,0,0,0,1,1 
  IP.Free;
end;

procedure TFormPolynomial.btnEccPointAddClick(Sender: TObject);
var
  Ecc: TCnInt64PolynomialEcc;
  P, Q, S: TCnInt64PolynomialEccPoint;
begin
// ���������ϵĶ���ʽ��Բ���ߵ��
// F67^2 �ϵ���Բ���� y^2 = x^3 + 4x + 3 ��ԭ����ʽ u^2 + 1
// �� P(2u + 16, 30u + 39) ���� 68P + 11��P = 0
// ���� ��P �� P �� Frob ӳ��Ҳ���� X Y �� 67 �η�Ϊ�������е�(65u + 16, 37u + 39)

// ��������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 2.2.8

  Ecc := TCnInt64PolynomialEcc.Create(4, 3, 67, 2, [16, 2], [39, 30], 0, [1, 0,
    1]); // Order δָ�����Ȳ���

  P := TCnInt64PolynomialEccPoint.Create;
  P.Assign(Ecc.Generator);
  Ecc.MultiplePoint(68, P);
  ShowMessage(P.ToString);   // 15x+6, 63x+4

  Q := TCnInt64PolynomialEccPoint.Create;
  Q.Assign(Ecc.Generator);
  Int64PolynomialGaloisPower(Q.X, Q.X, 67, 67, Ecc.Primitive);
  Int64PolynomialGaloisPower(Q.Y, Q.Y, 67, 67, Ecc.Primitive);

  Ecc.MultiplePoint(11, Q);
  ShowMessage(Q.ToString);   // 39x+2, 38x+48

  S := TCnInt64PolynomialEccPoint.Create;
  Ecc.PointAddPoint(S, P, Q);
  ShowMessage(S.ToString);   // 0, 0

  S.Free;
  P.Free;
  Q.Free;
  Ecc.Free;
end;

procedure TFormPolynomial.btnTestEccPointAdd2Click(Sender: TObject);
var
  Ecc: TCnInt64PolynomialEcc;
  P, Q, S: TCnInt64PolynomialEccPoint;
begin
// ���������ϵĶ���ʽ��Բ���ߵ��
// F67^3 �ϵ���Բ���� y^2 = x^3 + 4x + 3 ��ԭ����ʽ u^3 + 2
// �� P(15v^2 + 4v + 8, 44v^2 + 30v + 21) ���� ��2P - (-11)��P + 67P = 0
// ���� ��P �� P �� Frob ӳ��Ҳ���� X Y �� 67 �η�
// ��PΪ�������е�(33v^2 + 14v + 8, 3v^2 + 38v + 21)
// ��2PΪ�������е� 67^2 �η�(19v^2 + 49v + 8, 20v^2 + 66v + 21)

// ��������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 2.2.8

  Ecc := TCnInt64PolynomialEcc.Create(4, 3, 67, 3, [8, 4, 15], [21, 30, 44], 0, [2,
    0, 0 ,1]); // Order δָ�����Ȳ���

  P := TCnInt64PolynomialEccPoint.Create;
  P.Assign(Ecc.Generator);
  Ecc.MultiplePoint(67, P);                                        // �� 67P

  Q := TCnInt64PolynomialEccPoint.Create;
  Q.Assign(Ecc.Generator);
  Int64PolynomialGaloisPower(Q.X, Q.X, 67, 67, Ecc.Primitive);
  Int64PolynomialGaloisPower(Q.Y, Q.Y, 67, 67, Ecc.Primitive);   // �� ��P
  Ecc.MultiplePoint(-11, Q);                                       // �� -11��p

  S := TCnInt64PolynomialEccPoint.Create;
  Ecc.PointSubPoint(S, P, Q);

  Q.Assign(Ecc.Generator);
  Int64PolynomialGaloisPower(Q.X, Q.X, 67*67, 67, Ecc.Primitive);
  Int64PolynomialGaloisPower(Q.Y, Q.Y, 67*67, 67, Ecc.Primitive); // �� ��2P

  Ecc.PointAddPoint(S, S, Q);
  ShowMessage(Q.ToString);                                          // �õ� 0,0

  P.Free;
  Q.Free;
  S.Free;
  Ecc.Free;
end;

procedure TFormPolynomial.btnTestDivPolyClick(Sender: TObject);
var
  P: TCnInt64Polynomial;
begin
  // ��֤�ɳ�����ʽ������
  // ���� F101 �϶������Բ����: y^2 = x^3 + x + 1
  // �������ݲ�����ֻ����Ϊ����ͨ��
  // ��������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 2.2.9

  P := TCnInt64Polynomial.Create;

  Int64PolynomialGaloisCalcDivisionPolynomial(1, 1, 0, P, 101);
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(1, 1, 1, P, 101);
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(1, 1, 2, P, 101);
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(1, 1, 3, P, 101);  // 3x4 +6x2+12x+100
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(1, 1, 4, P, 101);  // ...
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(1, 1, 5, P, 101);  // 5x12 ... 16
  ShowMessage(P.ToString);

  P.Free;
end;

procedure TFormPolynomial.btnTestDivPoly2Click(Sender: TObject);
var
  P: TCnInt64Polynomial;
begin
  // ��֤�ɳ�����ʽ������
  // ���� F13 �϶������Բ����: y^2 = x^3 + 2x + 1
  // �������ݲ�����ֻ����Ϊ����ͨ��
  // ��������Դ�� Craig Costello �ġ�Pairings for beginners���е� Example 2.2.10

  P := TCnInt64Polynomial.Create;

  Int64PolynomialGaloisCalcDivisionPolynomial(2, 1, 0, P, 13);
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(2, 1, 1, P, 13);
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(2, 1, 2, P, 13);
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(2, 1, 3, P, 13);  // 3x4 +12x2+12x+9
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(2, 1, 4, P, 13);  // ...
  ShowMessage(P.ToString);
  Int64PolynomialGaloisCalcDivisionPolynomial(2, 1, 5, P, 13);  // 5x12 ... 6x + 7
  ShowMessage(P.ToString);

  P.Free;
end;

procedure TFormPolynomial.btnTestGaloisPoint2Click(Sender: TObject);
var
  X, Y, P, E: TCnInt64Polynomial;
begin
  X := TCnInt64Polynomial.Create([12, 8, 11, 1]);
  Y := TCnInt64Polynomial.Create([12, 5, 2, 12]);
  P := TCnInt64Polynomial.Create([9, 12, 12, 0, 3]);
  E := TCnInt64Polynomial.Create([1, 2, 0, 1]);

  Int64PolynomialGaloisMul(Y, Y, Y, 13, P); // ���� PiY ϵ����ƽ��
  Int64PolynomialGaloisMul(Y, Y, E, 13, P); // �ٳ��� Y ��ƽ��Ҳ���� X3+AX+B����ʱ Y ����Բ�����ұߵĵ� 2x3+7x2+12x+5

  // �ټ��� x ���꣬Ҳ���Ǽ��� X3+AX+B���� x �Ķ���ʽ���룬Ҳ�õ� 2x3+7x2+12x+5
  Int64PolynomialGaloisCompose(E, E, X, 13, P);

  if Int64PolynomialEqual(E, Y) then
    ShowMessage('Pi On Curve')
  else
    ShowMessage('Pi NOT');

  E.Free;
  P.Free;
  Y.Free;
  X.Free;
end;

procedure TFormPolynomial.btnTestPolyPoint2Click(Sender: TObject);
var
  X, Y, P, E: TCnInt64Polynomial;
begin
  X := TCnInt64Polynomial.Create([12,11,5,6]);
  Y := TCnInt64Polynomial.Create([8,5]);
  P := TCnInt64Polynomial.Create([9, 12, 12, 0, 3]);
  E := TCnInt64Polynomial.Create([1, 2, 0, 1]);

  Int64PolynomialGaloisMul(Y, Y, Y, 13, P); // ���� PiY ϵ����ƽ��
  Int64PolynomialGaloisMul(Y, Y, E, 13, P); // �ٳ��� Y ��ƽ��Ҳ���� X3+AX+B����ʱ Y ����Բ�����ұߵĵ� 2x3+7x2+12x+5

  // �ټ��� x ���꣬Ҳ���Ǽ��� X3+AX+B���� x �Ķ���ʽ���룬Ҳ�õ� 2x3+7x2+12x+5
  Int64PolynomialGaloisCompose(E, E, X, 13, P);

  if Int64PolynomialEqual(E, Y) then
    ShowMessage('Pi^2 On Curve')
  else
    ShowMessage('Pi^2 NOT');

  E.Free;
  P.Free;
  Y.Free;
  X.Free;
end;

procedure TFormPolynomial.btnTestPolyEccPoint3Click(Sender: TObject);
var
  X, Y, P, E: TCnInt64Polynomial;
begin
  E := TCnInt64Polynomial.Create([1, 2, 0, 1]);
  P := TCnInt64Polynomial.Create([7, 6, 1, 9, 10, 11, 12, 12, 9, 3, 7, 5]);

  // ĳ Pi
  X := TCnInt64Polynomial.Create([9,4,5,6,11,3,8,8,6,2,9]);
  Y := TCnInt64Polynomial.Create([12,1,11,0,1,1,7,1,8,9,12,7]);

  Int64PolynomialGaloisMul(Y, Y, Y, 13, P); // ���� PiY ϵ����ƽ��
  Int64PolynomialGaloisMul(Y, Y, E, 13, P); // �ٳ��� Y ��ƽ��Ҳ���� X3+AX+B����ʱ Y ����Բ�����ұߵĵ�

  // �ټ��� x ���꣬Ҳ���Ǽ��� X3+AX+B���� x �Ķ���ʽ����
  Int64PolynomialGaloisCompose(E, E, X, 13, P);

  if Int64PolynomialEqual(E, Y) then
    ShowMessage('Pi On Curve')
  else
    ShowMessage('Pi NOT');

  // ĳ Pi^2
  X.SetCoefficents([5,11,3,2,2,7,5,2,11,6,12,5]);
  Y.SetCoefficents([9,3,9,9,2,10,5,3,5,6,2,6]);

  Int64PolynomialGaloisMul(Y, Y, Y, 13, P); // ���� PiY ϵ����ƽ��
  Int64PolynomialGaloisMul(Y, Y, E, 13, P); // �ٳ��� Y ��ƽ��Ҳ���� X3+AX+B����ʱ Y ����Բ�����ұߵĵ�

  // �ټ��� x ���꣬Ҳ���Ǽ��� X3+AX+B���� x �Ķ���ʽ����
  Int64PolynomialGaloisCompose(E, E, X, 13, P);

  if Int64PolynomialEqual(E, Y) then
    ShowMessage('Pi^2 On Curve')
  else
    ShowMessage('Pi^2 NOT');

  // ĳ 3 * P
  X.SetCoefficents([10,8,7,9,5,12,4,12,3,4,1,6]);
  Y.SetCoefficents([7,2,10,0,3,7,4,6,3,0,11,12]);

  Int64PolynomialGaloisMul(Y, Y, Y, 13, P); // ���� PiY ϵ����ƽ��
  Int64PolynomialGaloisMul(Y, Y, E, 13, P); // �ٳ��� Y ��ƽ��Ҳ���� X3+AX+B����ʱ Y ����Բ�����ұߵĵ�

  // �ټ��� x ���꣬Ҳ���Ǽ��� X3+AX+B���� x �Ķ���ʽ����
  Int64PolynomialGaloisCompose(E, E, X, 13, P);

  if Int64PolynomialEqual(E, Y) then
    ShowMessage('3 * P On Curve')
  else
    ShowMessage('3 * P NOT');

  // ĳ��� ��^2 + 3 * P
  X.SetCoefficents([4,5,1,11,4,4,9,6,12,2,6,3]);
  Y.SetCoefficents([2,7,9,11,7,2,9,5,5,6,12,3]);

  Int64PolynomialGaloisMul(Y, Y, Y, 13, P); // ���� PiY ϵ����ƽ��
  Int64PolynomialGaloisMul(Y, Y, E, 13, P); // �ٳ��� Y ��ƽ��Ҳ���� X3+AX+B����ʱ Y ����Բ�����ұߵĵ�

  // �ټ��� x ���꣬Ҳ���Ǽ��� X3+AX+B���� x �Ķ���ʽ����
  Int64PolynomialGaloisCompose(E, E, X, 13, P);

  if Int64PolynomialEqual(E, Y) then
    ShowMessage('Pi^2 + 3 * P On Curve')
  else
    ShowMessage('Pi^2 + 3 * P NOT');

  E.Free;
  P.Free;
  Y.Free;
  X.Free;
end;

procedure TFormPolynomial.btnTestPolyAdd2Click(Sender: TObject);
var
  X, Y, P, E, RX, RY: TCnInt64Polynomial;
begin
  X := TCnInt64Polynomial.Create([0, 1]);
  Y := TCnInt64Polynomial.Create([1]);
  P := TCnInt64Polynomial.Create([9, 12, 12, 0, 3]);
  E := TCnInt64Polynomial.Create([1, 2, 0, 1]);

  RX := TCnInt64Polynomial.Create;
  RY := TCnInt64Polynomial.Create;

  TCnInt64PolynomialEcc.PointAddPoint1(X, Y, X, Y, RX, RY, 2, 1, 13, P);

  ShowMessage(RX.ToString);
  ShowMessage(RY.ToString);

  Int64PolynomialGaloisMul(RY, RY, RY, 13, P); // ���� Y ϵ����ƽ��
  Int64PolynomialGaloisMul(RY, RY, E, 13, P);  // �ٳ��� Y ��ƽ��Ҳ���� X3+AX+B����ʱ Y ����Բ�����ұߵĵ�

  // �ټ��� x ���꣬Ҳ���Ǽ��� X3+AX+B���� x �Ķ���ʽ����
  Int64PolynomialGaloisCompose(E, E, RX, 13, P);
  if Int64PolynomialEqual(E, Y) then
    ShowMessage('Add Point On Curve')
  else
    ShowMessage('Add Point NOT');

  RX.Free;
  RY.Free;
  E.Free;
  P.Free;
  Y.Free;
  X.Free;
end;

procedure TFormPolynomial.btnTestGaloisPolyMulModClick(Sender: TObject);
var
  P, Q, H: TCnInt64Polynomial;
begin
  P := TCnInt64Polynomial.Create([11,0,6,12]);
  Q := TCnInt64Polynomial.Create([2,4,0,2]);
  H := TCnInt64Polynomial.Create([9,12,12,0,3]);
  Int64PolynomialGaloisMul(P, P, Q, 13, H);
  ShowMessage(P.ToString);

  H.Free;
  Q.Free;
  P.Free;
end;

procedure TFormPolynomial.btnTestGaloisModularInverse1Click(
  Sender: TObject);
begin
  FIP1.SetCoefficents([1,2,0,1]);
  FIP2.SetCoefficents([3,4,4,0,1]);  // ��ԭ����ʽ
  Int64PolynomialGaloisModularInverse(FIP3, FIP1, FIP2, 13);
  ShowMessage(FIP3.ToString);  // �õ� 5x^3+6x+2

  Int64PolynomialGaloisMul(FIP3, FIP3, FIP1, 13, FIP2); // ��һ�����㿴�ǲ��ǵõ� 1
  ShowMessage(FIP3.ToString);

  FIP1.SetCoefficents([4,8,0,4]);
  FIP2.SetCoefficents([9,12,12,0,3]);
  Int64PolynomialGaloisModularInverse(FIP3, FIP1, FIP2, 13);
  ShowMessage(FIP3.ToString);  // �õ� 11x^3+8x+7

  // ���²��ã�
//  FIP1.SetCoefficents([4,-8,-4,0,1]);
//  Int64PolynomialGaloisMul(FIP1, FIP1, FIP3, 13, FIP2);
//  // Int64PolynomialGaloisMul(FIP3, FIP3, FIP1, 13, FIP2); // ��һ�����㿴�ǲ��ǵõ� 1
//  ShowMessage(FIP1.ToString); // ��Ȼ�õ� x
end;

procedure TFormPolynomial.btnTestEuclid2Click(Sender: TObject);
var
  A, B, X, Y: TCnInt64Polynomial;
begin
  A := TCnInt64Polynomial.Create([0,6]);
  B := TCnInt64Polynomial.Create([3]);
  X := TCnInt64Polynomial.Create;
  Y := TCnInt64Polynomial.Create;

  // �� 6x * X + 3 * Y = 1 mod 13 �Ľ⣬�õ� 0��9
  Int64PolynomialGaloisExtendedEuclideanGcd(A, B, X, Y, 13);
  ShowMessage(X.ToString);
  ShowMessage(Y.ToString);

  A.Free;
  B.Free;
  X.Free;
  Y.Free;
end;

procedure TFormPolynomial.btnTestExtendEuclid3Click(Sender: TObject);
var
  A, B, X, Y: TCnInt64Polynomial;
begin
  A := TCnInt64Polynomial.Create([3,3,2]);
  B := TCnInt64Polynomial.Create([0,6]);
  X := TCnInt64Polynomial.Create;
  Y := TCnInt64Polynomial.Create;

  // �� 2x2+3x+3 * X - 6x * Y = 1 mod 13 �Ľ⣬Ӧ�õõ� 9 �� 10x+2
  Int64PolynomialGaloisExtendedEuclideanGcd(A, B, X, Y, 13);
  ShowMessage(X.ToString);
  ShowMessage(Y.ToString);

  A.Free;
  B.Free;
  X.Free;
  Y.Free;
end;

procedure TFormPolynomial.btnTestGaloisDivClick(Sender: TObject);
var
  A, B, C, D: TCnInt64Polynomial;
begin
  // GF13 �� (2x^2+3x+3) div (6x) Ӧ�õ��� 9x + 7
  A := TCnInt64Polynomial.Create([3,3,2]);
  B := TCnInt64Polynomial.Create([0,6]);
  C := TCnInt64Polynomial.Create;
  D := TCnInt64Polynomial.Create;
  Int64PolynomialGaloisDiv(C, D, A, B, 13);
  ShowMessage(C.ToString);
  ShowMessage(D.ToString);
  A.Free;
  B.Free;
  C.Free;
  D.Free;
end;

procedure TFormPolynomial.btnTestEccDivisionPoly3Click(Sender: TObject);
var
  DP: TCnInt64Polynomial;
  A, B, P, V, X1, X2: Int64;
begin
  // Division Polynomial �������������� John J. McGee ��
  // ��Rene Schoof's Algorithm for Determing the Order of the Group of Points
  //    on an Elliptic Curve over a Finite Field���� 31 ҳ
  A := 46;
  B := 74;
  P := 97;

  X1 := 4;
  X2 := 90;

  DP := TCnInt64Polynomial.Create;
  mmoTestDivisionPolynomial.Lines.Clear;

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 2, DP, P);
  mmoTestDivisionPolynomial.Lines.Add('2: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 2
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 2

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 3, DP, P);
  mmoTestDivisionPolynomial.Lines.Add('3: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 24
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 76

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 4, DP, P);
  mmoTestDivisionPolynomial.Lines.Add('4: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 0
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 14

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 5, DP, P);
  mmoTestDivisionPolynomial.Lines.Add('5: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 47
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 0

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 6, DP, P);
  mmoTestDivisionPolynomial.Lines.Add('6: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �д�Ӧ�õõ� 25������õ� 85
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �д�Ӧ�õõ� 21������õ� 36

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 7, DP, P);
  mmoTestDivisionPolynomial.Lines.Add('7: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                     // �õ� 22
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                     // �д�Ӧ�õõ��õ� 23������õ� 69

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 8, DP, P); 
  mmoTestDivisionPolynomial.Lines.Add('8: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                     // �д�Ӧ�õõ� 0��
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                     // �õ� 29 ��

  DP.Free;
end;

procedure TFormPolynomial.btnGenerateDivisionPolynomialClick(
  Sender: TObject);
var
  List: TObjectList;
  I: Integer;
begin
  List := TObjectList.Create(True);
  CnInt64GenerateGaloisDivisionPolynomials(46, 74, 97, 20, List);

  mmoTestDivisionPolynomial.Lines.Clear;
  for I := 0 to List.Count - 1 do
    mmoTestDivisionPolynomial.Lines.Add(TCnInt64Polynomial(List[I]).ToString);

  List.Free;
end;

procedure TFormPolynomial.btnRP2PointClick(Sender: TObject);
var
  X, Y: TCnInt64RationalPolynomial;
begin
  X := TCnInt64RationalPolynomial.Create;
  Y := TCnInt64RationalPolynomial.Create;

  TCnInt64PolynomialEcc.RationalMultiplePoint(2, X, Y, 2, 1, 13);
  ShowMessage(X.ToString);
  ShowMessage(Y.ToString);

  X.Free;
  Y.Free;
end;

procedure TFormPolynomial.btnRationalPolynomialGenerateClick(
  Sender: TObject);
var
  I, D: Integer;
begin
  D := 2;
  FRP1.SetZero;
  FRP2.SetZero;

  Randomize;
  for I := 0 to D do
  begin
    FRP1.Nominator.Add(Random(16) - 1);
    FRP2.Nominator.Add(Random(16) - 1);
    FRP1.Denominator.Add(Random(16) - 1);
    FRP2.Denominator.Add(Random(16) - 1);
  end;

  edtRationalNominator1.Text := FRP1.Nominator.ToString;
  edtRationalNominator2.Text := FRP2.Nominator.ToString;
  edtRationalDenominator1.Text := FRP1.Denominator.ToString;
  edtRationalDenominator2.Text := FRP2.Denominator.ToString;
end;

procedure TFormPolynomial.btnRationalPolynomialAddClick(Sender: TObject);
begin
  if chkRationalPolynomialGalois.Checked then
    Int64RationalPolynomialGaloisAdd(FRP1, FRP2, FRP3, StrToInt(edtRationalPolynomialPrime.Text))
  else
    Int64RationalPolynomialAdd(FRP1, FRP2, FRP3);
  edtRationalResultNominator.Text := FRP3.Nominator.ToString;
  edtRationalResultDenominator.Text := FRP3.Denominator.ToString;
end;

procedure TFormPolynomial.btnRationalPolynomialSubClick(Sender: TObject);
begin
  if chkRationalPolynomialGalois.Checked then
    Int64RationalPolynomialGaloisSub(FRP1, FRP2, FRP3, StrToInt(edtRationalPolynomialPrime.Text))
  else
    Int64RationalPolynomialSub(FRP1, FRP2, FRP3);
  edtRationalResultNominator.Text := FRP3.Nominator.ToString;
  edtRationalResultDenominator.Text := FRP3.Denominator.ToString;
end;

procedure TFormPolynomial.btnRationalPolynomialMulClick(Sender: TObject);
begin
  if chkRationalPolynomialGalois.Checked then
    Int64RationalPolynomialGaloisMul(FRP1, FRP2, FRP3, StrToInt(edtRationalPolynomialPrime.Text))
  else
    Int64RationalPolynomialMul(FRP1, FRP2, FRP3);
  edtRationalResultNominator.Text := FRP3.Nominator.ToString;
  edtRationalResultDenominator.Text := FRP3.Denominator.ToString;
end;

procedure TFormPolynomial.btnRationalPolynomialDivClick(Sender: TObject);
begin
  if chkRationalPolynomialGalois.Checked then
    Int64RationalPolynomialGaloisDiv(FRP1, FRP2, FRP3, StrToInt(edtRationalPolynomialPrime.Text))
  else
    Int64RationalPolynomialDiv(FRP1, FRP2, FRP3);
  edtRationalResultNominator.Text := FRP3.Nominator.ToString;
  edtRationalResultDenominator.Text := FRP3.Denominator.ToString;
end;

end.

