unit UnitPolynomial;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, CnPolynomial, CnECC;

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
  private
    FIP1: TCnInt64Polynomial;
    FIP2: TCnInt64Polynomial;
    FIP3: TCnInt64Polynomial;
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
end;

procedure TFormPolynomial.FormDestroy(Sender: TObject);
begin
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

end.

