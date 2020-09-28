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
    btnManualOnCurve: TButton;
    btnCheckDivisionPolynomialZero: TButton;
    btnCalcSimpleEcc: TButton;
    mmoEcc: TMemo;
    bvl4: TBevel;
    btnCheckRationalAdd: TButton;
    btnTestPiXPolynomial: TButton;
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
    procedure btnManualOnCurveClick(Sender: TObject);
    procedure btnCheckDivisionPolynomialZeroClick(Sender: TObject);
    procedure btnCalcSimpleEccClick(Sender: TObject);
    procedure btnCheckRationalAddClick(Sender: TObject);
    procedure btnTestPiXPolynomialClick(Sender: TObject);
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
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 25
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 21

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 7, DP, P);
  mmoTestDivisionPolynomial.Lines.Add('7: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 22
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 23

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 8, DP, P);
  mmoTestDivisionPolynomial.Lines.Add('8: === ' + DP.ToString);
  V := Int64PolynomialGaloisGetValue(DP, X1, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 0��
  V := Int64PolynomialGaloisGetValue(DP, X2, P);
  mmoTestDivisionPolynomial.Lines.Add(IntToStr(V));                                    // �õ� 31

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

  X.SetOne;
  X.Nominator.SetCoefficents([0, 1]);
  Y.SetOne;

  TCnInt64PolynomialEcc.RationalMultiplePoint(2, X, Y, 1, 1, 23);
  ShowMessage(X.ToString);
  ShowMessage(Y.ToString);

  // ��֤ 6 19 �Ķ������� 13 16
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(X, 6, 23))); // �õ� 13 ����
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(Y, 6, 23) * 19 mod 23)); // �õ� 16 ����

  X.SetOne;
  X.Nominator.SetCoefficents([0, 1]);
  Y.SetOne;

  TCnInt64PolynomialEcc.RationalMultiplePoint(3, X, Y, 1, 1, 23);
  ShowMessage(X.ToString);
  ShowMessage(Y.ToString);

  // ��֤ 6 19 ���������� 7 11
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(X, 6, 23))); // �õ� 7 ����
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(Y, 6, 23) * 19 mod 23)); // �õ� 11 ����

  X.SetOne;
  X.Nominator.SetCoefficents([0, 1]);
  Y.SetOne;

  TCnInt64PolynomialEcc.RationalMultiplePoint(4, X, Y, 1, 1, 23);
  ShowMessage(X.ToString);
  ShowMessage(Y.ToString);

  // ��֤ 6 19 ���ı����� 5 19
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(X, 6, 23))); // �õ� 5
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(Y, 6, 23) * 19 mod 23)); // �õ� 19

  X.SetOne;
  X.Nominator.SetCoefficents([0, 1]);
  Y.SetOne;

  TCnInt64PolynomialEcc.RationalMultiplePoint(5, X, Y, 1, 1, 23);
  ShowMessage(X.ToString);
  ShowMessage(Y.ToString);

  // ��֤ 6 19 ���屶���� 12 4
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(X, 6, 23))); // �õ� 12
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(Y, 6, 23) * 19 mod 23)); // �õ� 4

// ����ʽ������������߷��̣���ֵ������ģ���ŵ���
//  if TCnInt64PolynomialEcc.IsRationalPointOnCurve(X, Y, 2, 1, 13) then
//    ShowMessage('On Curve')
//  else
//    ShowMessage('NOT On Curve');

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

procedure TFormPolynomial.btnManualOnCurveClick(Sender: TObject);
var
  A, B, Q: Int64;
  X, Y: TCnInt64RationalPolynomial;
  P, Y2: TCnInt64Polynomial;
  RL, RR, T: TCnInt64RationalPolynomial;
begin
  // ����Բ���߶������ÿɳ�����ʽ�ֹ�����Ľ����֤��ͨ��
  X := TCnInt64RationalPolynomial.Create;
  Y := TCnInt64RationalPolynomial.Create;
  Y2 := TCnInt64Polynomial.Create;
  P := TCnInt64Polynomial.Create;

  RL := TCnInt64RationalPolynomial.Create;
  RR := TCnInt64RationalPolynomial.Create;
  T := TCnInt64RationalPolynomial.Create;

  A := 1;
  B := 1;
  Q := 23;   // ������F23�ϵ� Y^2=X^3+X+1  ��6��19��* 2 = ��13��16��

  // ����������
  X.Nominator.SetCoefficents([A*A, 4-12*B, 4-6*A, 0, 1]);  //  X4 + (4-6A)X2 + (4- 12B)x + A2
  X.Denominator.SetCoefficents([4*B, 4*A, 0, 4]);         //        4X3 + 4AX + 4B

  Y.Nominator.SetCoefficents([-A*A*A-8*B*B, -4*A*B, -5*A*A, 20*B, 5*A, 0, 1]); // X6 + 5AX4 + 20BX3 - 5A2X2 - 4ABX - 8B2 - A3
  Y.Denominator.SetCoefficents([8*B*B, 16*A*B, 8*A*A, 16*B, 16*A, 0, 8]);      //          8(X3+AX+B)(X3+AX+B)

  Y2.SetCoefficents([B, A, 0, 1]);
  // ��֤ Y^2 * (x^3+Ax+B) �Ƿ���� X3 + AX + B

  Int64RationalPolynomialMul(Y, Y, Y);
  Int64RationalPolynomialMul(Y, Y2, RL); // �õ� Y^2 (x^3+Ax+B)
  RL.Reduce;
  ShowMessage(RL.ToString);

  Int64RationalPolynomialMul(X, X, RR);
  Int64RationalPolynomialMul(RR, X, RR); // �õ� X^3

  P.SetCoefficents([A]);
  Int64RationalPolynomialMul(X, P, T);   // T �õ� A * X
  Int64RationalPolynomialAdd(RR, T, RR); // RR �õ� X^3 + AX

  P.SetCoefficents([B]);
  Int64RationalPolynomialAdd(RR, P, RR); // RR �õ� X^3 + AX + B
  RR.Reduce;
  ShowMessage(RR.ToString);

  // RL/RR �����������г�ʽ���ȣ��� Fq ������ԭʼ�㣨6��19���������㹫ʽ����ȥ�õ���13��16��
  X.Nominator.SetCoefficents([A*A, 4-12*B, 4-6*A, 0, 1]);  //  X4 + (4-6A)X2 + (4- 12B)x + A2
  X.Denominator.SetCoefficents([4*B, 4*A, 0, 4]);          //        4X3 + 4AX + 4B
  ShowMessage('2*X (X=6) using Division Polynomial is '
    + IntToStr(Int64RationalPolynomialGaloisGetValue(X, 6, Q))); // �õ� 13 ����

  Y.Nominator.SetCoefficents([-A*A*A-8*B*B, -4*A*B, -5*A*A, 20*B, 5*A, 0, 1]); // X6 + 5AX4 + 20BX3 - 5A2X2 - 4ABX - 8B2 - A3
  Y.Denominator.SetCoefficents([8*B*B, 16*A*B, 8*A*A, 16*B, 16*A, 0, 8]);      //          8(X3+AX+B)(X3+AX+B)
  ShowMessage('2*Y (X=6) using Division Polynomial is '
    + IntToStr((Int64RationalPolynomialGaloisGetValue(Y, 6, Q) * 19) mod Q)); // �õ� 16 ����

  Y2.SetCoefficents([B, A, 0, 1]);
  // ��֤�����㹫ʽ��һ���������������ֵ Y^2 * (x^3+Ax+B) �Ƿ���� X3 + AX + B

  Int64RationalPolynomialGaloisMul(Y, Y, Y, Q);
  Int64RationalPolynomialGaloisMul(Y, Y2, RL, Q); // �õ� Y^2 (x^3+Ax+B)
  ShowMessage(RL.ToString);

  Int64RationalPolynomialGaloisMul(X, X, RR, Q);
  Int64RationalPolynomialGaloisMul(RR, X, RR, Q); // �õ� X^3

  P.SetCoefficents([A]);
  Int64RationalPolynomialGaloisMul(X, P, T, Q);   // T �õ� A * X
  Int64RationalPolynomialGaloisAdd(RR, T, RR, Q); // RR �õ� X^3 + AX

  P.SetCoefficents([B]);
  Int64RationalPolynomialGaloisAdd(RR, P, RR, Q); // RR �õ� X^3 + AX + B
  ShowMessage(RR.ToString);

  // RL/RR �� F23 �ڱ��ʽ���ǲ��ȣ���������ֵ��������Ȼ��ȣ�
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(RL, 6, Q)));  // 3 = ������ Y ����ƽ�� 16^2 mod 23 = 3
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(RR, 6, Q)));  // 3 = ������ X ���� 13^3 + 13 + 1 mod 23 = 3

  // ��������һ���� ��13��16���Ķ����㣨5��19����һ�ԣ�Ҳ��
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(RL, 13, Q)));  // 16 = ������ Y ����ƽ�� 19^2 mod 23 = 16
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(RR, 13, Q)));  // 16 = ������ X ���� 5^3 + 5 + 1 mod 23 = 16

  // ����� X Y �����㹫ʽ��ģ�����ʽ��������᲻����ȣ���û�б�ԭ����ʽ����ȫû������

  P.Free;
  T.Free;
  RL.Free;
  RR.Free;
  Y2.Free;
  Y.Free;
  X.Free;
end;

procedure TFormPolynomial.btnCheckDivisionPolynomialZeroClick(
  Sender: TObject);
var
  F: TCnInt64Polynomial;
  A, B, Q, V: Int64;
begin
  // ����Բ������ nP = 0 �ĵ������ x y����֤ fn(x) �Ƿ���� 0
  // Ҫ�� 2 3 4 5 6 ������

  F := TCnInt64Polynomial.Create;
  // F29 �µ� Y^2 = X^3 + 6X + 1����Ϊ 24���� 2 3 4 �����ӣ�����Ҳ�� 6 8 12 24

  A := 6; B := 1; Q := 29;
  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 2, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 25, Q);  // 25, 0 �Ƕ��׵�
  ShowMessage(IntToStr(V));                      // 2 ���� 0������

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 3, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 18, Q);  // 18, 5 �����׵�
  ShowMessage(IntToStr(V));                      // �� 0

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 4, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 20, Q);  // 20, 1 ���Ľ׵�
  ShowMessage(IntToStr(V));                      // �� 0

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 6, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 9, Q);   // 9, 28 �����׵�
  ShowMessage(IntToStr(V));                      // �� 0

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 8, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 7, Q);   // 7, 26 �ǰ˽׵�
  ShowMessage(IntToStr(V));                      // �� 0

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 12, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 24, Q);  // 24, 22 ��ʮ���׵�
  ShowMessage(IntToStr(V));                      // �� 0

  // F23 �µ� Y^2 = X^3 + X + 9����Ϊ 20���� 2 4 5 �����ӣ�����Ҳ�� 10 20

  A := 1; B := 9; Q := 23;
  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 2, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 8, Q);   // 8, 0 �Ƕ��׵�
  ShowMessage(IntToStr(V));                      // 2 ���� 0������

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 4, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 5, Q);   // 5, 22 ���Ľ׵�
  ShowMessage(IntToStr(V));                      // �� 0

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 5, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 3, Q);   // 3, 4 ����׵�
  ShowMessage(IntToStr(V));                      // �� 0

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 10, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 16, Q);  // 16, 2 ��ʮ�׵�
  ShowMessage(IntToStr(V));                      // �� 0

  Int64PolynomialGaloisCalcDivisionPolynomial(A, B, 20, F, Q);
  ShowMessage(F.ToString);
  V := Int64PolynomialGaloisGetValue(F, 6, Q);   // 6, 22 �Ƕ�ʮ�׵�
  ShowMessage(IntToStr(V));                      // �� 0
  F.Free;
end;

procedure TFormPolynomial.btnCalcSimpleEccClick(Sender: TObject);
var
  List: TStrings;

  procedure CalcEccPoints(A, B, Q: Int64; AList: TStrings);
  var
    Ecc: TCnInt64Ecc;
    I, J, K: Integer;
    P, T: TCnInt64EccPoint;
  begin
    AList.Clear;
    Ecc := TCnInt64Ecc.Create(A, B, Q, 0, 0, Q);
    for J := 0 to Q - 1 do
    begin
      P.X := J;
      for I := 0 to Q - 1 do
      begin
        P.Y := I;
        if Ecc.IsPointOnCurve(P) then
        begin
          // �ҵ�һ���㣬Ȼ����֤���˶��ٵ� 0
          for K := 1 to 2 * Q do
          begin
            T := P;
            Ecc.MultiplePoint(K, T);
            if (T.X = 0) and (T.Y = 0) then
            begin
              AList.Add(Format('(%d, %d) * %d = 0', [P.X, P.Y, K]));
              Break;
            end;
          end;
        end;
      end;
    end;
  end;

begin
  List := TStringList.Create;
  mmoEcc.Clear;
  CalcEccPoints(6, 1, 29, List); // �� 2 3 4 6 8 12 24 �׵�
  ShowMessage(List.Text);
  mmoEcc.Lines.AddStrings(List);
  mmoEcc.Lines.Add('');

  CalcEccPoints(1, 9, 23, List); // �� 2 4 5 10 20 �׵�
  ShowMessage(List.Text);
  mmoEcc.Lines.AddStrings(List);

  List.Free;
end;

procedure TFormPolynomial.btnCheckRationalAddClick(Sender: TObject);
var
  X, Y, M2X, M2Y, M3X, M3Y: TCnInt64RationalPolynomial;
begin
  // ���һ������ʽ�Ͷ�������ʽ��ӣ�����Ƿ����������
  // һ���� (x, 1 * y)���������� RationalMultiplePoint ��

  X := TCnInt64RationalPolynomial.Create;
  Y := TCnInt64RationalPolynomial.Create;
  M2X := TCnInt64RationalPolynomial.Create;
  M2Y := TCnInt64RationalPolynomial.Create;
  M3X := TCnInt64RationalPolynomial.Create;
  M3Y := TCnInt64RationalPolynomial.Create;

  X.Denominator.SetOne;
  X.Nominator.SetCoefficents([0, 1]);
  Y.Denominator.SetOne;
  Y.Denominator.SetCoefficents([1]);

  TCnInt64PolynomialEcc.RationalMultiplePoint(2, M2X, M2Y, 6, 1, 29);
  ShowMessage(M2X.ToString);
  ShowMessage(M2Y.ToString);

  // һ������Ϊ 18, 5
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(M2X, 18, 29))); // �������� X ���� 18������
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(M2Y, 18, 29) * 5 mod 29)); // �������� Y ���� 24������

  // �������ʽ�޷��ж�������ʽ��ͬ�ĵ� X �� Y �Ƿ���ȣ��������ָ��
  TCnInt64PolynomialEcc.RationalPointAddPoint(X, Y, M2X, M2Y, M3X, M3Y, 6, 1, 29, True); // ָ�� X ��ȣ��� Y �����
  ShowMessage(M3X.ToString);  // ����ʽ���� 0
  ShowMessage(M3Y.ToString);  // ����ʽ���� 0

  // ������Ӧ���� 0��0
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(M3X, 18, 29))); // ��������� X ���� 0
  ShowMessage(IntToStr(Int64RationalPolynomialGaloisGetValue(M3Y, 18, 29) * 5 mod 29)); // ��������� Y ���� 0

  X.Free;
  Y.Free;
  M2X.Free;
  M2Y.Free;
  M3X.Free;
  M3Y.Free;
end;

procedure TFormPolynomial.btnTestPiXPolynomialClick(Sender: TObject);
var
  DP, X, Y, Pi1X, Pi1Y, Pi2X, Pi2Y, SX, SY: TCnInt64Polynomial;
  RX, RY: TCnInt64RationalPolynomial;
//  Pi2RX, Pi2RY, R2X, R2Y, S2X, S2Y: TCnInt64RationalPolynomial;
begin
{
  ���� F97 �ϵ���Բ���� Y2=X3+31X-12 �����Ť�㣬ע��ϵ��ֻҪ��� 97 ͬ������
  ���� ��(x^97, y^97) �롡��(x^97^2, y^97^2) �� 2 * (x, 1*y)

��(x, y) =
[47 x^11 + 11 x^10 - 16 x^9 + 8 x^8 + 44 x^7 + 8 x^6 + 10 x^5 + 12 x^4 - 40 x^3 + 42 x^2 + 11 x + 26,
(6 x^11 + 45 x^10 + 34 x^9 + 28 x^8 - 11 x^7 + 3 x^6 - 3 x^5 + 2 x^4 - 39 x^3 -^48 x^2 - x - 9)y].

��^2(x, y) =
[-17 x^11 + 2 x^10 - 25 x^9 - x^8 + 28 x^7 + 31 x^6 + 25 x^5 - 32 x^4 + 45 x^3 + 26 x^2 + 36 x + 60,
(34 x^11 + 35 x^10 - 8 x^9 - 11 x^8 - 48 x^7 + 34 x^6 - 8 x^5 - 37 x^4 - 21 x^3 + 40 x^2 + 11 x + 48)y].

2 *(x, y) =
[22 x^11 + 17 x^10 + 18 x^9 + 40 x^8 + 41 x^7 - 13 x^6 + 30 x^5 + 11 x^4 - 38 x^3 + 7 x^2 + 20 x + 17,
(-11 x^10 - 17 x^9 - 48 x^8 - 12 x^7 + 17 x^6 + 44 x^5 - 10 x^4 + 8 x^3 + 38 x^2 + 25 x + 24)y].

��^2(x, y) + [2]P =   (��������ԣ������ Ring 5 �м���Ļ���5 �׿ɳ�����ʽ��� 12 �η����������������ֻ�� 11 �Σ�����Ϊ��ð���� 14 �Σ�)
[-14 x^14 + 15 x^13 - 20 x^12 - 43 x^11 - 10 x^10 - 27 x^9 + 5 x^7 + 11 x^6 + 45 x^5 - 17 x^4 + 30 x^3 - 2 x^2 + 35 x - 46,
(-11 x^14 - 35 x^13 - 26 x^12 - 21 x^11 + 25 x^10 + 23 x^9 + 4 x^8 - 24 x^7 + 9 x^6 + 43 x^5 - 47 x^4 + 26 x^3 + 19 x^2 - 40 x - 32)y].

���͵�� x ����� �е� 1 ����� x �����������ʽ <> 1��y Ҳһ�������Եõ� t5 = 1

  ������Դ��һ�� PPT

  Counting points on elliptic curves over Fq
           Christiane Peters
        DIAMANT-Summer School on
 Elliptic and Hyperelliptic Curve Cryptography
          September 17, 2008
}

  DP := TCnInt64Polynomial.Create;
  Pi1X := TCnInt64Polynomial.Create;
  Pi1Y := TCnInt64Polynomial.Create;
  Pi2X := TCnInt64Polynomial.Create;
  Pi2Y := TCnInt64Polynomial.Create;
  SX := TCnInt64Polynomial.Create;
  SY := TCnInt64Polynomial.Create;

  X := TCnInt64Polynomial.Create;
  Y := TCnInt64Polynomial.Create([-12, 31, 0, 1]);

  Int64PolynomialGaloisCalcDivisionPolynomial(31, -12, 5, DP, 97);

  X.MaxDegree := 1;
  X[1] := 1;                 // x
  Int64PolynomialGaloisPower(Pi1X, X, 97, 97, DP);
  ShowMessage(Pi1X.ToString);               // �õ���ȷ�����Ring ���ڼ������ mod f��

  Int64PolynomialGaloisPower(Pi1Y, Y, (97 - 1) div 2, 97, DP);
  ShowMessage(Pi1Y.ToString);               // �õ���ȷ�����y^q = y^q-1 * y = (x3+Ax+B)^((q-1)/2) * y

  X.MaxDegree := 1;
  X[1] := 1;                 // x
  Int64PolynomialGaloisPower(Pi2X, X, 97 * 97, 97, DP);
  ShowMessage(Pi2X.ToString);         // �õ�������ȷ�Ľ����Ring ���ڼ������ mod f����ԭ�������һ���������д�

  Y.SetCoefficents([-12, 31, 0, 1]);
  Int64PolynomialGaloisPower(Pi2Y, Y, (97 * 97 - 1) div 2, 97, DP);
  ShowMessage(Pi2Y.ToString);               // �õ���ȷ�����y^q^2 = y^q^2-1 * y = (x3+Ax+B)^((q^2-1)/2) * y

  RX := TCnInt64RationalPolynomial.Create;
  RY := TCnInt64RationalPolynomial.Create;
  TCnInt64PolynomialEcc.RationalMultiplePoint(2, RX, RY, 31, -12, 97);
  // ShowMessage(RX.ToString);
  // ShowMessage(RY.ToString);              // �õ� 2P �� X �� Y �����������ʽ

  Int64PolynomialGaloisModularInverse(X, RX.Denominator, DP, 97);
  Int64PolynomialGaloisMul(X, X, RX.Nominator, 97, DP);
  ShowMessage(X.ToString);               // ��ģ�����ʽ�� 2P �� X ����ת��Ϊ����ʽ���õ���ȷ���

  Int64PolynomialGaloisModularInverse(Y, RY.Denominator, DP, 97);
  Int64PolynomialGaloisMul(Y, Y, RY.Nominator, 97, DP);
  ShowMessage(Y.ToString);               // ��ģ�����ʽ�� 2P �� Y ����ת��Ϊ����ʽ���õ���ȷ���

  // ���ܼ���ӣ����ж����� X �Ƿ���ȣ�ֱ���ж�ģϵ����ʽ��
  if Int64PolynomialGaloisEqual(Pi2X, X, 97) then
    ShowMessage('��^2 (x) == 2 * P (x)')
  else
    ShowMessage('��^2 (x) <> 2 * P (x)');

  // ���ܼ���ӣ����ж����� Y �Ƿ���ȣ�ֱ���ж�ģϵ����ʽ��
  if Int64PolynomialGaloisEqual(Pi2Y, Y, 97) then
    ShowMessage('��^2 (y) == 2 * P (y)')
  else
    ShowMessage('��^2 (y) <> 2 * P (y)');

  // ������ӵõ������
//  Pi2RX := TCnInt64RationalPolynomial.Create;
//  Pi2RY := TCnInt64RationalPolynomial.Create;
//  R2X := TCnInt64RationalPolynomial.Create;
//  R2Y := TCnInt64RationalPolynomial.Create;
//  S2X := TCnInt64RationalPolynomial.Create;
//  S2Y := TCnInt64RationalPolynomial.Create;
//
//  Pi2RX.Denominator.SetOne;
//  Int64PolynomialCopy(Pi2RX.Nominator, Pi2X);
//  Pi2RY.Denominator.SetOne;
//  Int64PolynomialCopy(Pi2RY.Nominator, Pi2Y);
//  R2X.Denominator.SetOne;
//  Int64PolynomialCopy(R2X.Nominator, X);
//  R2Y.Denominator.SetOne;
//  Int64PolynomialCopy(R2Y.Nominator, Y);

  TCnInt64PolynomialEcc.PointAddPoint1(Pi2X, Pi2Y, X, Y, SX, SY, 31, -12, 97, DP);
  ShowMessage(SX.ToString);
  ShowMessage(SY.ToString);                // �� DP ��Ϊ��ԭ����ʽֱ�Ӽӣ��������

//  Int64PolynomialGaloisModularInverse(X, S2X.Denominator, DP, 97);
//  Int64PolynomialGaloisMul(X, X, S2X.Nominator, 97, DP);
//  ShowMessage(X.ToString);               // ��ģ�����ʽ���͵�� X ����ת��Ϊ����ʽ���������
//
//  Int64PolynomialGaloisModularInverse(Y, S2Y.Denominator, DP, 97);
//  Int64PolynomialGaloisMul(Y, Y, S2Y.Nominator, 97, DP);
//  ShowMessage(Y.ToString);               // ��ģ�����ʽ���͵�� Y ����ת��Ϊ����ʽ���������

//  Pi2RX.Free;
//  Pi2RY.Free;
//  R2X.Free;
//  R2Y.Free;
//  S2X.Free;
//  S2Y.Free;
  RX.Free;
  RY.Free;
  Pi1X.Free;
  Pi1Y.Free;
  Pi2X.Free;
  Pi2Y.Free;
  DP.Free;
  X.Free;
  Y.Free;
end;

end.

