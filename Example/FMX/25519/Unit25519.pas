unit Unit25519;

interface

uses
  {$IFDEF MSWINDOWS} Windows, Messages, {$ENDIF} SysUtils, Classes, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Clipboard, CnBigNumber, CnECC, Cn25519, FMX.ExtCtrls, CnNative, FMX.Edit, FMX.TabControl, FMX.Types,
  FMX.Controls.Presentation;

type
  TForm25519 = class(TForm)
    pgc25519: TTabControl;
    ts25519: TTabItem;
    grp25519: TGroupBox;
    btnCurve25519G: TButton;
    btnEd25519G: TButton;
    btnCurve25519GAdd: TButton;
    btnEd25519GAdd: TButton;
    btnCurve25519GSub: TButton;
    btnEd25519GSub: TButton;
    btnCurve25519GMul: TButton;
    btnEd25519GMul: TButton;
    btnEd25519ExtendedAdd: TButton;
    btnEd25519ExtendedMul: TButton;
    btnEd25519GenKey: TButton;
    btnEd25519SignSample: TButton;
    btnEd25519PointData: TButton;
    btnCurve25519DHKeyExchange: TButton;
    btnCalcSqrt: TButton;
    btn25519PointConvert: TButton;
    btnCurv25519MontLadderDouble: TButton;
    btnCurv25519MontLadderAdd: TButton;
    btnCurv25519MontLadderMul: TButton;
    btnBigNumberToField: TButton;
    btnField64Mul: TButton;
    btnField64MulTime: TButton;
    btnCurv25519MontLadderField64Double: TButton;
    btnCurv25519MontLadderField64Add: TButton;
    btnCurv25519MontLadderField64Mul: TButton;
    btnField64Sub: TButton;
    btnField64Reduce: TButton;
    btnEd25519ExtendedField64Add: TButton;
    btnEd25519ExtendedField64Mul: TButton;
    btn25519Field64Power2k: TButton;
    btn25519Field64PowerPMinus2: TButton;
    ts25519Sign: TTabItem;
    grpEd25519Sign: TGroupBox;
    lblEd25519Priv: TLabel;
    lblEd25519Pub: TLabel;
    lblEd25519Msg: TLabel;
    lblEd25519Sig: TLabel;
    edtEd25519Priv: TEdit;
    edtEd25519Pub: TEdit;
    btnEd25519Gen: TButton;
    edtEd25519Message: TEdit;
    btnEd25519Sign: TButton;
    edtEd25519Sig: TEdit;
    btnEd25519Verify: TButton;
    btnSignTime: TButton;
    btnVerifyTime: TButton;
    btnEd25519SignFile: TButton;
    btnEd25519VerifyFile: TButton;
    btnEd25519LoadKeys: TButton;
    btnEd25519SaveKeys: TButton;
    dlgOpen1: TOpenDialog;
    dlgSave1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCurve25519GClick(Sender: TObject);
    procedure btnEd25519GClick(Sender: TObject);
    procedure btnCurve25519GAddClick(Sender: TObject);
    procedure btnEd25519GAddClick(Sender: TObject);
    procedure btnCurve25519GSubClick(Sender: TObject);
    procedure btnEd25519GSubClick(Sender: TObject);
    procedure btnCurve25519GMulClick(Sender: TObject);
    procedure btnEd25519GMulClick(Sender: TObject);
    procedure btnEd25519ExtendedAddClick(Sender: TObject);
    procedure btnEd25519ExtendedMulClick(Sender: TObject);
    procedure btnEd25519GenKeyClick(Sender: TObject);
    procedure btnEd25519SignSampleClick(Sender: TObject);
    procedure btnEd25519PointDataClick(Sender: TObject);
    procedure btnCurve25519DHKeyExchangeClick(Sender: TObject);
    procedure btnCalcSqrtClick(Sender: TObject);
    procedure btn25519PointConvertClick(Sender: TObject);
    procedure btnCurv25519MontLadderDoubleClick(Sender: TObject);
    procedure btnCurv25519MontLadderAddClick(Sender: TObject);
    procedure btnCurv25519MontLadderMulClick(Sender: TObject);
    procedure btnBigNumberToFieldClick(Sender: TObject);
    procedure btnField64MulClick(Sender: TObject);
    procedure btnField64MulTimeClick(Sender: TObject);
    procedure btnCurv25519MontLadderField64DoubleClick(Sender: TObject);
    procedure btnCurv25519MontLadderField64AddClick(Sender: TObject);
    procedure btnCurv25519MontLadderField64MulClick(Sender: TObject);
    procedure btnField64SubClick(Sender: TObject);
    procedure btnField64ReduceClick(Sender: TObject);
    procedure btnEd25519ExtendedField64AddClick(Sender: TObject);
    procedure btnEd25519ExtendedField64MulClick(Sender: TObject);
    procedure btn25519Field64Power2kClick(Sender: TObject);
    procedure btn25519Field64PowerPMinus2Click(Sender: TObject);
    procedure btnEd25519GenClick(Sender: TObject);
    procedure btnEd25519SignClick(Sender: TObject);
    procedure btnEd25519VerifyClick(Sender: TObject);
    procedure btnSignTimeClick(Sender: TObject);
    procedure btnVerifyTimeClick(Sender: TObject);
    procedure btnEd25519SignFileClick(Sender: TObject);
    procedure btnEd25519VerifyFileClick(Sender: TObject);
  private
    FCurve25519: TCnCurve25519;
    FEd25519: TCnEd25519;
    FPrivKey: TCnEccPrivateKey;
    FPubKey: TCnEccPublicKey;
    FSigData: TCnEd25519SignatureData;
  public

  end;

var
  Form25519: TForm25519;

implementation

{$R *.fmx}

uses
  CnCommon;

const
  SCN_25519_PRIME = '7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED';
  // 2^255 - 19

  SCN_25519_COFACTOR = 8;
  // �����Ӿ�Ϊ 8��Ҳ������Բ�����ܵ����� G ������İ˱�

  SCN_25519_ORDER = '1000000000000000000000000000000014DEF9DEA2F79CD65812631A5CF5D3ED';
  // ���������Ϊ 2^252 + 27742317777372353535851937790883648493

  // 25519 Ť�����»����߲���
  SCN_25519_EDWARDS_A = '-01';
  // -1

  SCN_25519_EDWARDS_D = '52036CEE2B6FFE738CC740797779E89800700A4D4141D8AB75EB4DCA135978A3';
  // -121655/121656��Ҳ���� 121656 * D mod P = P - 121655 ��� D =
  // 37095705934669439343138083508754565189542113879843219016388785533085940283555

  SCN_25519_EDWARDS_GX = '216936D3CD6E53FEC0A4E231FDD6DC5C692CC7609525A7B2C9562D608F25D51A';
  // 15112221349535400772501151409588531511454012693041857206046113283949847762202

  SCN_25519_EDWARDS_GY = '6666666666666666666666666666666666666666666666666666666666666658';
  // 46316835694926478169428394003475163141307993866256225615783033603165251855960


procedure TForm25519.FormCreate(Sender: TObject);
begin
  FCurve25519 := TCnCurve25519.Create;
  FEd25519 := TCnEd25519.Create;
  FPrivKey := TCnEccPrivateKey.Create;
  FPubKey := TCnEccPublicKey.Create;
end;

procedure TForm25519.FormDestroy(Sender: TObject);
begin
  FPubKey.Free;
  FPrivKey.Free;
  FEd25519.Free;
  FCurve25519.Free;
end;

procedure TForm25519.btnCurve25519GClick(Sender: TObject);
begin
  if FCurve25519.IsPointOnCurve(FCurve25519.Generator) then
    ShowMessage('Curve 25519 Generator Point is on this Curve');
end;

procedure TForm25519.btnEd25519GClick(Sender: TObject);
begin
  if FEd25519.IsPointOnCurve(FEd25519.Generator) then
    ShowMessage('Ed 25519 Generator Point is on this Curve');
end;

procedure TForm25519.btnCurve25519GAddClick(Sender: TObject);
var
  P, Q: TCnEccPoint;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FCurve25519.Generator);
  Q.Assign(FCurve25519.Generator);

  FCurve25519.PointAddPoint(P, Q, P);
  // P �� 2*G
  if FCurve25519.IsPointOnCurve(P) then
    ShowMessage('Curve 25519 G + G is on this Curve');

  FCurve25519.PointAddPoint(P, Q, P);
  // P �� 3*G
  if FCurve25519.IsPointOnCurve(P) then
    ShowMessage('Curve 25519 G + 2*G is on this Curve');

  P.Assign(FCurve25519.Generator);
  Q.Assign(FCurve25519.Generator);
  FCurve25519.PointInverse(Q);

  FCurve25519.PointAddPoint(P, Q, P);
  if P.IsZero then
    ShowMessage('Curve 25519 G + -G is Zero');

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnEd25519GAddClick(Sender: TObject);
var
  P, Q: TCnEccPoint;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FEd25519.Generator);
  Q.Assign(FEd25519.Generator);

  FEd25519.PointAddPoint(P, Q, P);
  // P �� 2*G
  if FEd25519.IsPointOnCurve(P) then
    ShowMessage('Curve 25519 G + G is on this Curve');

  FEd25519.PointAddPoint(P, Q, P);
  // P �� 3*G
  if FEd25519.IsPointOnCurve(P) then
    ShowMessage('Ed 25519 G + 2*G is on this Curve');

  P.Assign(FEd25519.Generator);
  Q.Assign(FEd25519.Generator);
  FEd25519.PointInverse(Q);

  FEd25519.PointAddPoint(P, Q, P);
  if FEd25519.IsNeutualPoint(P) then
    ShowMessage('Ed 25519 G + -G is Zero');

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnCurve25519GSubClick(Sender: TObject);
var
  P, Q: TCnEccPoint;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FCurve25519.Generator);
  Q.Assign(FCurve25519.Generator);

  FCurve25519.PointAddPoint(P, Q, P);
  FCurve25519.PointAddPoint(P, Q, P);

  // P �� 3*G��Q �� G
  FCurve25519.PointSubPoint(P, Q, Q); // Q �� 2*G
  if FCurve25519.IsPointOnCurve(Q) then
    ShowMessage('Curve 25519 3*G - G is on this Curve');

  FCurve25519.PointSubPoint(P, P, Q); // Q ������Զ��
  if Q.IsZero then
    ShowMessage('Curve 25519 G - G is Zero');

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnEd25519GSubClick(Sender: TObject);
var
  P, Q: TCnEccPoint;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FEd25519.Generator);
  Q.Assign(FEd25519.Generator);

  FEd25519.PointAddPoint(P, Q, P);
  FEd25519.PointAddPoint(P, Q, P);

  // P �� 3*G��Q �� G
  FEd25519.PointSubPoint(P, Q, Q); // Q �� 2*G
  if FEd25519.IsPointOnCurve(Q) then
    ShowMessage('Curve 25519 3*G - G is on this Curve');

  FEd25519.PointSubPoint(P, P, Q); // Q ������Զ��
  if FEd25519.IsNeutualPoint(Q) then
    ShowMessage('Curve 25519 G - G is Zero');

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnCurve25519GMulClick(Sender: TObject);
var
  P: TCnEccPoint;
begin
  P := TCnEccPoint.Create;
  P.Assign(FCurve25519.Generator);

  FCurve25519.MultiplePoint(456768997823, P);
  if FCurve25519.IsPointOnCurve(P) then
    ShowMessage('Curve 25519 Random * G is on this Curve');

  P.Free;
end;

procedure TForm25519.btnEd25519GMulClick(Sender: TObject);
var
  P: TCnEccPoint;
begin
  P := TCnEccPoint.Create;
  P.Assign(FEd25519.Generator);

  FEd25519.MultiplePoint(8099261456373487672, P);
  if FEd25519.IsPointOnCurve(P) then
    ShowMessage('Ed 25519 Random * G is on this Curve');

  P.Free;
end;

procedure TForm25519.btnEd25519ExtendedAddClick(Sender: TObject);
var
  P, Q, S: TCnEccPoint;
  P4, Q4, S4: TCnEcc4Point;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;
  S := TCnEccPoint.Create;

  P4 := TCnEcc4Point.Create;
  Q4 := TCnEcc4Point.Create;
  S4 := TCnEcc4Point.Create;

  P.Assign(FEd25519.Generator);
  Q.Assign(FEd25519.Generator);
//  FEd25519.SetNeutualPoint(P);
//  FEd25519.SetNeutualPoint(Q);
  // ============ ��ͬ��ĵ�� ================
  // P �� G , Q �� G
  CnEccPointToEcc4Point(P4, P, FEd25519.FiniteFieldSize);
  CnEccPointToEcc4Point(Q4, Q, FEd25519.FiniteFieldSize);

  FEd25519.ExtendedPointAddPoint(P4, Q4, S4);
  // ShowMessage(S4.ToString);
  FEd25519.PointAddPoint(P, Q, S);

  // ��֤ S �� S4 �Ƿ����
  CnEcc4PointToEccPoint(P, S4, FEd25519.FiniteFieldSize);
  //ShowMessage(P.ToString);
  //ShowMessage(S.ToString);
  if CnEccPointsEqual(P, S) then
    ShowMessage('Extended Add G+G OK');

  // ============ ��ͬ��ĵ�� ================
  P.Assign(FEd25519.Generator);
  Q.Assign(FEd25519.Generator);
  //FEd25519.SetNeutualPoint(Q);
  FEd25519.PointAddPoint(P, Q, P);

  // P �� 2*G , Q �� G
  CnEccPointToEcc4Point(P4, P, FEd25519.FiniteFieldSize);
  CnEccPointToEcc4Point(Q4, Q, FEd25519.FiniteFieldSize);

  FEd25519.ExtendedPointAddPoint(P4, Q4, S4);
  FEd25519.PointAddPoint(P, Q, S);
  // ShowMessage(S.ToString);

  // ��֤ S �� S4 �Ƿ����
  CnEcc4PointToEccPoint(P, S4, FEd25519.FiniteFieldSize);
  // ShowMessage(S4.ToString);
  if CnEccPointsEqual(P, S) then
    ShowMessage('Extended Add G+2G OK');

  S4.Free;
  Q4.Free;
  P4.Free;
  S.Free;
  Q.Free;
  P.Free;
end;

procedure TForm25519.btnEd25519ExtendedMulClick(Sender: TObject);
const
  M = -8099261456373487672;
var
  P, Q: TCnEccPoint;
  P4: TCnEcc4Point;
  T1, T2: Cardinal;
  I: Integer;
begin
  P := TCnEccPoint.Create;
  P.Assign(FEd25519.Generator);

  P4 := TCnEcc4Point.Create;
  CnEccPointToEcc4Point(P4, P, FEd25519.FiniteFieldSize);

  FEd25519.MultiplePoint(M, P);
  FEd25519.ExtendedMultiplePoint(M, P4);

  if FEd25519.IsExtendedPointOnCurve(P4) then
    ShowMessage('Ed 25519 Extended Random * G is on this Curve');

  Q := TCnEccPoint.Create;
  CnEcc4PointToEccPoint(Q, P4, FEd25519.FiniteFieldSize);

  if CnEccPointsEqual(P, Q) then
    ShowMessage('Ed 25519 Mul/ExtendedMul Equal OK');

  T1 := CnGetTickCount;
  for I := 1 to 1000 do
    FEd25519.MultiplePoint(M, P); // �Ѿ������ Extended ����
  T1 := CnGetTickCount - T1;

  T2 := CnGetTickCount;
  for I := 1 to 1000 do
    FEd25519.ExtendedMultiplePoint(M, P4);
  T2 := CnGetTickCount - T2;

  ShowMessage(Format('Normal %d, Extended %d', [T1, T2])); // Extended �ȳ���Ŀ�ʮ�����ϣ�
  CnEcc4PointToEccPoint(Q, P4, FEd25519.FiniteFieldSize);
  if CnEccPointsEqual(P, Q) then
    ShowMessage('Ed 25519 1000 Mul/ExtendedMul Equal OK');

  Q.Free;
  P4.Free;
  P.Free;
end;

procedure TForm25519.btnEd25519GenKeyClick(Sender: TObject);
var
  Data: TCnEd25519Data;
begin
  FEd25519.GenerateKeys(FPrivKey, FPubKey);
  FEd25519.PointToPlain(FPubKey, Data);
  ShowMessage(FPubKey.ToString);
end;

procedure TForm25519.btnEd25519SignSampleClick(Sender: TObject);
var
  B: Byte;
  Sig, ASig: TCnEd25519Signature;
begin
  B := $72;
  Sig := TCnEd25519Signature.Create;
  if CnEd25519SignData(@B, 1, FPrivKey, FPubKey, Sig) then
  begin
    ShowMessage('Sign OK');
    Sig.SaveToData(FSigData);

    ASig := TCnEd25519Signature.Create;
    ASig.LoadFromData(FSigData);

    // �Ƚ� Sig �� ASig �Ƿ���ͬ
    if CnEccPointsEqual(Sig.R, ASig.R) and BigNumberEqual(Sig.S, ASig.S) then
      ShowMessage('Sig Save/Load OK');

    if CnEd25519VerifyData(@B, 1, Sig, FPubKey) then
      ShowMessage('Verify OK')
    else
      ShowMessage('Verify Fail. Maybe Key needs to be Re-Generated?');
    ASig.Free;
  end;
  Sig.Free;
end;

procedure TForm25519.btnEd25519PointDataClick(Sender: TObject);
var
  Data: TCnEd25519Data;
  P, Q: TCnEccPoint;
  I, K: Integer;
begin
  FEd25519.PointToPlain(FEd25519.Generator, Data);

  P := TCnEccPoint.Create;
  FEd25519.PlainToPoint(Data, P);

  if CnEccPointsEqual(P, FEd25519.Generator) then
    ShowMessage('OK for G');

  Q := TCnEccPoint.Create;
  for I := 1 to 1000 do
  begin
    P.Assign(FEd25519.Generator);
    K := Random(65536);
    FEd25519.MultiplePoint(K, P);

    FEd25519.PointToPlain(P, Data);
    FEd25519.PlainToPoint(Data, Q);

    if not CnEccPointsEqual(P, Q) then
    begin
      ShowMessage('Fail. ' + IntToStr(K));
      Exit;
    end;
  end;
  ShowMessage('OK');

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnCurve25519DHKeyExchangeClick(Sender: TObject);
var
  Priv1, Priv2: TCnEccPrivateKey;
  Pub1, Pub2: TCnEccPublicKey;
  Key1, Key2, Key1O, Key2O: TCnEccPoint;
begin
  Priv1 := nil;
  Priv2 := nil;
  Pub1 := nil;
  Pub2 := nil;
  Key1 := nil;
  Key2 := nil;
  Key1O := nil;
  Key2O := nil;

  try
    Priv1 := TCnEccPrivateKey.Create;
    Priv2 := TCnEccPrivateKey.Create;
    Pub1 := TCnEccPublicKey.Create;
    Pub2 := TCnEccPublicKey.Create;
    Key1 := TCnEccPoint.Create;
    Key2 := TCnEccPoint.Create;
    Key1O := TCnEccPoint.Create;
    Key2O := TCnEccPoint.Create;

    Priv1.SetHex('77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a');
    Priv2.SetHex('5dab087e624a8a4b79e17f8b83800ee66f3bb1292618b6fd1c2f8b27ff88e0eb');

    CnCurve25519KeyExchangeStep1(Priv1, Key1); // ��һ�����ã����� Key 1
    CnCurve25519KeyExchangeStep1(Priv2, Key2); // ��һ�����ã����� Key 2

    // Key2 ��һ��Key1 ����һ��

    CnCurve25519KeyExchangeStep2(Priv1, Key2, Key1O); // ��һ�����ã��������� Key 1O
    CnCurve25519KeyExchangeStep2(Priv2, Key1, Key2O); // ��һ�����ã��������� Key 2O

    if CnEccPointsEqual(Key1O, Key2O) then
      ShowMessage('Key Exchange OK '+ Key1O.ToString);
  finally
    Key2O.Free;
    Key1O.Free;
    Key2.Free;
    Key1.Free;
    Pub2.Free;
    Pub1.Free;
    Priv2.Free;
    Priv1.Free;
  end;

end;

procedure TForm25519.btnCalcSqrtClick(Sender: TObject);
var
  Prime, P, R, Inv: TCnBigNumber;
begin
  // ��� Curve25519 ���� By^2 = x^3 + Ax^2 + x �� Ed25519 ���� au^2 + v^2 = 1 + du^2v^2
  // �Ĳ������Ϲ�ϵ B = 4 /(a-d) ��û����֤��  A = 2(a+d)/(a-d) ����֤

  Prime := TCnBigNumber.Create;
  Prime.SetHex('7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED');

  P := TCnBigNumber.Create;
  BigNumberSubMod(P, FEd25519.CoefficientA, FEd25519.CoefficientD, Prime);
  Inv := TCnBigNumber.Create;
  BigNumberModularInverse(Inv, P, Prime);
  BigNumberMulWord(Inv, 4);
  BigNumberNonNegativeMod(P, Inv, Prime);
  ShowMessage(P.ToDec);

  BigNumberDirectMulMod(P, P, FCurve25519.CoefficientB, Prime);
  if P.IsWord(4) then
    ShowMessage('OK')
  else
    ShowMessage('B = 4 /(a-d) Fail');

  R := TCnBigNumber.Create;
  BigNumberSubMod(R, FEd25519.CoefficientA, FEd25519.CoefficientD, Prime);
  BigNumberModularInverse(Inv, R, Prime);

  BigNumberAddMod(P, FEd25519.CoefficientA, FEd25519.CoefficientD, Prime);
  BigNumberAddMod(P, P, P, Prime);

  BigNumberDirectMulMod(P, P, Inv, Prime);
  if BigNumberEqual(P, FCurve25519.CoefficientA) then
    ShowMessage('OK: A = 2(a+d)/(a-d) = ' + P.ToDec); // 486662

  Inv.Free;
  R.Free;
  P.Free;
  Prime.Free;
end;

procedure TForm25519.btn25519PointConvertClick(Sender: TObject);
var
  P, Q: TCnEccPoint;
begin
  P := nil;
  Q := nil;

  try
    P := TCnEccPoint.Create;
    Q := TCnEccPoint.Create;

    P.Assign(FCurve25519.Generator);
    CnCurve25519PointToEd25519Point(Q, P);
    ShowMessage(Q.ToString);
    if FEd25519.IsPointOnCurve(Q) then
      ShowMessage('Converted Ed25519 Point is on Curve');

    P.Assign(FEd25519.Generator);
    CnEd25519PointToCurve25519Point(Q, P);
    ShowMessage(Q.ToString);

    if FCurve25519.IsPointOnCurve(Q) then
      ShowMessage('Converted Curve25519 Point is on Curve');
  finally
    Q.Free;
    P.Free;
  end;
end;

procedure TForm25519.btnCurv25519MontLadderDoubleClick(Sender: TObject);
var
  P, Q: TCnEccPoint;
  T: TCnBigNumber;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FCurve25519.Generator);
  FCurve25519.PointToXAffinePoint(P, P); // ת��Ϊ��Ӱ��
  FCurve25519.XAffinePointToPoint(P, P); // ��ת������
  ShowMessage(P.ToString); // �� G ���

  FCurve25519.PointToXAffinePoint(P, FCurve25519.Generator);
  ShowMessage(P.ToString); // P �õ���Ӱ G ��
  FCurve25519.MontgomeryLadderPointXDouble(P, P);
  ShowMessage(P.ToString); // P �õ���Ӱ 2*G ��
  FCurve25519.XAffinePointToPoint(P, P);
  ShowMessage(P.ToString); // P �õ���ͨ 2*G ��

  Q.Assign(FCurve25519.Generator);
  FCurve25519.PointAddPoint(Q, Q, Q);
  ShowMessage(Q.ToString);

  // P �� X Y ��ʽ�� 2*G��Q ����ͨ��ʽ�� 2*G���ж��� X �Ƿ����
  if BigNumberEqual(P.X, Q.X) then
  begin
    if BigNumberEqual(P.Y, Q.Y) then
      ShowMessage('Montgomery Ladder Double OK. X, Y Both Equals.')
    else
    begin
      T := TCnBigNumber.Create;
      BigNumberAdd(T, P.Y, Q.Y);
      if BigNumberEqual(T, FCurve25519.FiniteFieldSize) then
        ShowMessage('Montgomery Ladder Double OK. X Equals. Y +-');
      T.Free;
    end;
  end;

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnCurv25519MontLadderAddClick(Sender: TObject);
var
  P, Q: TCnEccPoint;
  T: TCnBigNumber;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FCurve25519.Generator);
  Q.SetZero;
  FCurve25519.PointToXAffinePoint(P, P);
  ShowMessage(P.ToString);                // 9, 1
  FCurve25519.PointToXAffinePoint(Q, Q);  // Q 0
  ShowMessage(Q.ToString);                // 0, 1
  FCurve25519.MontgomeryLadderPointXAdd(P, P, Q, P); // ������ P Ҫ�õ�����
  ShowMessage(P.ToString); // ������� 9, 1
  FCurve25519.XAffinePointToPoint(P, P);
  ShowMessage(P.ToString); // ת���������� 9, xxxxxxx ���� FCurve25519.Generator

  P.Assign(FCurve25519.Generator);
  FCurve25519.PointToXAffinePoint(P, P); // P ת��Ϊ��Ӱ�� G
  FCurve25519.MontgomeryLadderPointXDouble(Q, P); // Q ��Ӱ 2*G

  FCurve25519.MontgomeryLadderPointXAdd(P, Q, P, P); // P �õ���Ӱ 3*G

  FCurve25519.XAffinePointToPoint(P, P);
  ShowMessage(P.ToString); // P �õ���ͨ 3*G ��

  Q.Assign(FCurve25519.Generator);
  FCurve25519.PointAddPoint(Q, Q, Q);
  FCurve25519.PointAddPoint(Q, FCurve25519.Generator, Q); // Q ֱ�Ӽӳ���ͨ 3*G ��
  ShowMessage(Q.ToString);

  // P �� X Y ��ʽ�� 3*G��Q ����ͨ��ʽ�� 3*G���ж��� X �Ƿ����
  if BigNumberEqual(P.X, Q.X) then
  begin
    if BigNumberEqual(P.Y, Q.Y) then
      ShowMessage('Montgomery Ladder Add OK. X, Y Both Equals.')
    else
    begin
      T := TCnBigNumber.Create;
      BigNumberAdd(T, P.Y, Q.Y);
      if BigNumberEqual(T, FCurve25519.FiniteFieldSize) then
        ShowMessage('Montgomery Ladder Add OK. X Equals. Y +-');
      T.Free;
    end;
  end;

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnCurv25519MontLadderMulClick(Sender: TObject);
const
  MUL_COUNT = 9876577987898;
var
  P, Q: TCnEccPoint;
  T: TCnBigNumber;
  T1, T2: Cardinal;
  I: Integer;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FCurve25519.Generator);
  FCurve25519.PointToXAffinePoint(P, P); // P ת��Ϊ��Ӱ�� G
  FCurve25519.MontgomeryLadderMultiplePoint(MUL_COUNT, P); // P �Գ�
  FCurve25519.XAffinePointToPoint(P, P); // nG ת��Ϊ��ͨ��

  Q.Assign(FCurve25519.Generator);
  FCurve25519.MultiplePoint(MUL_COUNT, Q);

  if BigNumberEqual(P.X, Q.X) then
  begin
    if BigNumberEqual(P.Y, Q.Y) then
      ShowMessage('Montgomery Ladder Mul OK. X, Y Both Equals.')
    else
    begin
      T := TCnBigNumber.Create;
      BigNumberAdd(T, P.Y, Q.Y);
      if BigNumberEqual(T, FCurve25519.FiniteFieldSize) then
        ShowMessage('Montgomery Ladder Mul OK. X Equals. Y +-');
      T.Free;
    end;
  end;

  Q.Assign(FCurve25519.Generator);
  FCurve25519.PointToXAffinePoint(Q, Q); // Q ת��Ϊ��Ӱ�� G
  T1 := CnGetTickCount;
  for I := 1 to 1000 do
  begin
    P.Assign(Q);
    FCurve25519.MontgomeryLadderMultiplePoint(MUL_COUNT, P); // P �Գˣ��ɸ��������ݷ��ȳ���Ŀ�ʮ�����ϣ�
  end;
  T1 := CnGetTickCount - T1;

  T2 := CnGetTickCount;
  for I := 1 to 1000 do
  begin
    P.Assign(FCurve25519.Generator);
    FCurve25519.MultiplePoint(MUL_COUNT, P); // P �Գˣ�Ҳ�Ѿ��ĳ��ɸ��������ݷ���
  end;
  T2 := CnGetTickCount - T2;

  ShowMessage(Format('Curve 25519 1000 Mul %d, MontgomeryLadder %d', [T2, T1]));

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnBigNumberToFieldClick(Sender: TObject);
var
  B, C: TCnBigNumber;
  L: TCnBigNumberList;
  D: TCn25519Field64;
begin
  // B := TCnBigNumber.FromHex('8888888877777777666666665555555544444444333333332222222211111111');
  B := TCnBigNumber.FromHex('7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEC');
  Cn25519BigNumberToField64(D, B);

  ShowMessage(UInt64ToHex(D[0]));
  ShowMessage(UInt64ToHex(D[1]));
  ShowMessage(UInt64ToHex(D[2]));
  ShowMessage(UInt64ToHex(D[3]));
  ShowMessage(UInt64ToHex(D[4]));

  L := TCnBigNumberList.Create;
  L.Add.SetInt64(D[0]);
  L.Add.SetInt64(D[1]);
  L.Add.SetInt64(D[2]);
  L.Add.SetInt64(D[3]);
  L.Add.SetInt64(D[4]);

  L[1].ShiftLeft(51);
  L[2].ShiftLeft(102);
  L[3].ShiftLeft(153);
  L[4].ShiftLeft(204);

  C := TCnBigNumber.Create;
  L.SumTo(C);
  ShowMessage(C.ToHex);

  Cn25519Field64ToBigNumber(C, D);
  ShowMessage(C.ToHex);

  C.Free;
  L.Free;
  B.Free;
end;

procedure TForm25519.btnField64MulClick(Sender: TObject);
var
  A, B, C: TCnBigNumber;
  FA, FB, FC: TCn25519Field64;
begin
  A := TCnBigNumber.FromHex('11111111222222223333333344444444555555556666666677777777');
  B := TCnBigNumber.FromHex('66666666555555554444444433333333222222221111111100000000');

//  A := TCnBigNumber.FromHex('F00000000000000000000000');
//  B := TCnBigNumber.FromHex('F00000000000000000000000'); // ��������

//  A := TCnBigNumber.FromHex('1000000000000000000000000'); // ��� 0 �ͳ����ˣ��˻����ȫ 0 �ˣ����������޸�
//  B := TCnBigNumber.FromHex('100000000000000000000000'); 

  Cn25519BigNumberToField64(FA, A);
  Cn25519BigNumberToField64(FB, B);

  Cn25519Field64Mul(FC, FA, FB);

  C := TCnBigNumber.Create;
  Cn25519Field64ToBigNumber(C, FC);
  ShowMessage(C.ToHex());  // ���������Ҫ���

  BigNumberDirectMulMod(C, A, B, FEd25519.FiniteFieldSize);
  ShowMessage(C.ToHex());  // ���������Ҫ���

  C.Free;
  B.Free;
  A.Free;
end;

procedure TForm25519.btnField64MulTimeClick(Sender: TObject);
var
  I: Integer;
  A, B, C: TCnBigNumber;
  FA, FB, FC: TCn25519Field64;
  T1, T2: Cardinal;
begin
  A := TCnBigNumber.FromHex('11111111222222223333333344444444555555556666666677777777');
  B := TCnBigNumber.FromHex('66666666555555554444444433333333222222221111111100000000');

  Cn25519BigNumberToField64(FA, A);
  Cn25519BigNumberToField64(FB, B);

  T1 := CnGetTickCount;
  for I := 1 to 50000 do
    Cn25519Field64Mul(FC, FA, FB);
  T1 := CnGetTickCount - T1;

  C := TCnBigNumber.Create;
  Cn25519Field64ToBigNumber(C, FC);

  T2 := CnGetTickCount;
  for I := 1 to 50000 do
    BigNumberDirectMulMod(C, A, B, FEd25519.FiniteFieldSize);
  T2 := CnGetTickCount - T2;

  ShowMessage(Format('Field %d. DirectMulMod %d', [T1, T2])); // ǰ����΢��һ���

  C.Free;
  B.Free;
  A.Free;
end;

procedure TForm25519.btnCurv25519MontLadderField64DoubleClick(
  Sender: TObject);
var
  P, Q: TCnEccPoint;
  PF: TCn25519Field64EccPoint;
  T: TCnBigNumber;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FCurve25519.Generator);
  FCurve25519.PointToField64XAffinePoint(PF, P); // ת��Ϊ����ʽ��
  FCurve25519.Field64XAffinePointToPoint(P, PF); // ��ת������
  ShowMessage(P.ToString); // �� G ���

  FCurve25519.PointToField64XAffinePoint(PF, FCurve25519.Generator); // PF �õ���Ӱ G ��
  FCurve25519.MontgomeryLadderField64PointXDouble(PF, PF); // P �õ���Ӱ 2*G ��
  FCurve25519.Field64XAffinePointToPoint(P, PF);
  ShowMessage(P.ToString); // P �õ���ͨ 2*G ��

  Q.Assign(FCurve25519.Generator);
  FCurve25519.PointAddPoint(Q, Q, Q);
  ShowMessage(Q.ToString);

  // P �� X Y ��ʽ�� 2*G��Q ����ͨ��ʽ�� 2*G���ж��� X �Ƿ����
  if BigNumberEqual(P.X, Q.X) then
  begin
    if BigNumberEqual(P.Y, Q.Y) then
      ShowMessage('Montgomery Ladder Field64 Double OK. X, Y Both Equals.')
    else
    begin
      T := TCnBigNumber.Create;
      BigNumberAdd(T, P.Y, Q.Y);
      if BigNumberEqual(T, FCurve25519.FiniteFieldSize) then
        ShowMessage('Montgomery Ladder Field64 Double OK. X Equals. Y +-');
      T.Free;
    end;
  end;

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnCurv25519MontLadderField64AddClick(
  Sender: TObject);
var
  P, Q: TCnEccPoint;
  PF, QF: TCn25519Field64EccPoint;
  T: TCnBigNumber;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FCurve25519.Generator);
  FCurve25519.PointToField64XAffinePoint(PF, P); // PF ת��Ϊ����ʽ��Ӱ�� G
  FCurve25519.MontgomeryLadderField64PointXDouble(QF, PF); // QF ����ʽ��Ӱ 2*G
  FCurve25519.MontgomeryLadderField64PointXAdd(PF, QF, PF, PF); // PF �õ�����ʽ��Ӱ 3*G
  FCurve25519.Field64XAffinePointToPoint(P, PF);
  ShowMessage(P.ToString); // P �õ���ͨ 3*G �㣬�ƺ���ò���

  Q.Assign(FCurve25519.Generator);
  FCurve25519.PointAddPoint(Q, Q, Q);
  FCurve25519.PointAddPoint(Q, FCurve25519.Generator, Q); // Q ֱ�Ӽӳ���ͨ 3*G ��
  ShowMessage(Q.ToString);

  // P �� X Y ��ʽ�� 3*G��Q ����ͨ��ʽ�� 3*G���ж��� X �Ƿ����
  if BigNumberEqual(P.X, Q.X) then
  begin
    if BigNumberEqual(P.Y, Q.Y) then
      ShowMessage('Montgomery Ladder Add OK. X, Y Both Equals.')
    else
    begin
      T := TCnBigNumber.Create;
      BigNumberAdd(T, P.Y, Q.Y);
      if BigNumberEqual(T, FCurve25519.FiniteFieldSize) then
        ShowMessage('Montgomery Ladder Add OK. X Equals. Y +-');
      T.Free;
    end;
  end;

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnField64SubClick(Sender: TObject);
var
  A, B, C: TCnBigNumber;
  FA, FB, FC: TCn25519Field64;
begin
  A := TCnBigNumber.FromHex('64');
  B := TCnBigNumber.FromHex('40');

  Cn25519BigNumberToField64(FA, A);
  Cn25519BigNumberToField64(FB, B);

  Cn25519Field64Sub(FC, FA, FB);

  C := TCnBigNumber.Create;
  Cn25519Field64ToBigNumber(C, FC);
  ShowMessage(C.ToHex());  // ���������Ҫ���

  C.Free;
  B.Free;
  A.Free;
end;

procedure TForm25519.btnField64ReduceClick(Sender: TObject);
var
  FA: TCn25519Field64;
  R: TCnBigNumber;
begin
  FA[0] := 45;
  FA[1] := 2251799813685248;
  FA[2] := 2251799813685247;
  FA[3] := 2251799813685247;
  FA[4] := 2251799813685247;

  R := TCnBigNumber.Create;
  Cn25519Field64ToBigNumber(R, FA);
  ShowMessage(R.ToHex); // �õ� 40

  Cn25519Field64Reduce(FA);
  ShowMessage(Cn25519Field64ToHex(FA));
  Cn25519Field64ToBigNumber(R, FA);
  ShowMessage(R.ToHex); // ��֪���õ��˸�ɶ

  R.Free;
end;

procedure TForm25519.btnCurv25519MontLadderField64MulClick(
  Sender: TObject);
const
  MUL_COUNT = 9823454363465987;
var
  P, Q: TCnEccPoint;
  PF, QF: TCn25519Field64EccPoint;
  T: TCnBigNumber;
  T1, T2: Cardinal;
  I: Integer;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;

  P.Assign(FCurve25519.Generator);
  FCurve25519.PointToField64XAffinePoint(PF, P); // P ת��Ϊ����ʽ�� G
  FCurve25519.MontgomeryLadderField64MultiplePoint(MUL_COUNT, PF); // P �Գ�
  FCurve25519.Field64XAffinePointToPoint(P, PF); // nG ת��Ϊ��ͨ��

  P.Assign(FCurve25519.Generator);
  FCurve25519.PointToXAffinePoint(P, P); // P ת��Ϊ��Ӱ�� G
  FCurve25519.MontgomeryLadderMultiplePoint(MUL_COUNT, P); // P �Գ�
  FCurve25519.XAffinePointToPoint(P, P); // nG ת��Ϊ��ͨ��

  Q.Assign(FCurve25519.Generator);
  FCurve25519.MultiplePoint(MUL_COUNT, Q);

  if BigNumberEqual(P.X, Q.X) then
  begin
    if BigNumberEqual(P.Y, Q.Y) then
      ShowMessage('Montgomery Ladder Mul OK. X, Y Both Equals.')
    else
    begin
      T := TCnBigNumber.Create;
      BigNumberAdd(T, P.Y, Q.Y);
      if BigNumberEqual(T, FCurve25519.FiniteFieldSize) then
        ShowMessage('Montgomery Ladder Mul OK. X Equals. Y +-');
      T.Free;
    end;
  end;

  Q.Assign(FCurve25519.Generator);
  FCurve25519.PointToXAffinePoint(Q, Q); // Q ת��Ϊ��Ӱ�� G
  T1 := CnGetTickCount;
  for I := 1 to 5000 do
  begin
    P.Assign(Q);
    FCurve25519.MontgomeryLadderMultiplePoint(MUL_COUNT, P); // P �Գˣ��ɸ��������ݷ�
  end;
  T1 := CnGetTickCount - T1;

  P.Assign(FCurve25519.Generator);
  FCurve25519.PointToField64XAffinePoint(QF, P);
  T2 := CnGetTickCount;
  for I := 1 to 5000 do
  begin
    Cn25519Field64EccPointCopy(PF, QF);
    FCurve25519.MontgomeryLadderField64MultiplePoint(MUL_COUNT, PF); // PF ����ʽ����Գˣ��ֿ��˽�һ����
  end;
  T2 := CnGetTickCount - T2;

  ShowMessage(Format('Curve 25519 5000 Field Mul %d, MontgomeryLadder %d', [T2, T1]));

  Q.Free;
  P.Free;
end;

procedure TForm25519.btnEd25519ExtendedField64AddClick(Sender: TObject);
var
  P, Q, S: TCnEccPoint;
  P4, Q4, S4: TCn25519Field64Ecc4Point;
begin
  P := TCnEccPoint.Create;
  Q := TCnEccPoint.Create;
  S := TCnEccPoint.Create;

  P.Assign(FEd25519.Generator);
  Q.Assign(FEd25519.Generator);

  // ============ ��ͬ��ĵ�� ================
  CnEccPointToField64Ecc4Point(P4, P);
  CnEccPointToField64Ecc4Point(Q4, Q);

  FEd25519.ExtendedField64PointAddPoint(P4, Q4, S4);
  FEd25519.PointAddPoint(P, Q, S);

  // ��֤ S �� S4 �Ƿ����
  CnField64Ecc4PointToEccPoint(P, S4);
  if CnEccPointsEqual(P, S) then
    ShowMessage('Extended Add G+G OK');

  // ============ ��ͬ��ĵ�� ================
  P.Assign(FEd25519.Generator);
  Q.Assign(FEd25519.Generator);
  FEd25519.PointAddPoint(P, Q, P);

  // P �� 2*G , Q �� G
  CnEccPointToField64Ecc4Point(P4, P);
  CnEccPointToField64Ecc4Point(Q4, Q);

  FEd25519.ExtendedField64PointAddPoint(P4, Q4, S4);
  FEd25519.PointAddPoint(P, Q, S);

  // ��֤ S �� S4 �Ƿ����
  CnField64Ecc4PointToEccPoint(P, S4);
  if CnEccPointsEqual(P, S) then
    ShowMessage('Extended Add G+2G OK');

  S.Free;
  Q.Free;
  P.Free;
end;

procedure TForm25519.btnEd25519ExtendedField64MulClick(Sender: TObject);
const
  M = 809926145687654876;
var
  P, Q: TCnEccPoint;
  P4: TCn25519Field64Ecc4Point;
  T1, T2: Cardinal;
  I: Integer;
  Ed: TCnTwistedEdwardsCurve;
begin
  Ed := TCnTwistedEdwardsCurve.Create;
  Ed.Load(SCN_25519_EDWARDS_A, SCN_25519_EDWARDS_D, SCN_25519_PRIME, SCN_25519_EDWARDS_GX,
    SCN_25519_EDWARDS_GY, SCN_25519_ORDER, 8);

  P := TCnEccPoint.Create;
  P.Assign(FEd25519.Generator);

  CnEccPointToField64Ecc4Point(P4, P);

  FEd25519.MultiplePoint(M, P);
  FEd25519.ExtendedField64MultiplePoint(M, P4);

  if FEd25519.IsExtendedField64PointOnCurve(P4) then
    ShowMessage('Ed 25519 Extended Random * G is on this Curve');

  Q := TCnEccPoint.Create;
  CnField64Ecc4PointToEccPoint(Q, P4);

  if CnEccPointsEqual(P, Q) then
    ShowMessage('Ed 25519 Mul/ExtendedMul Equal OK');

  T1 := CnGetTickCount;
  for I := 1 to 1000 do
    Ed.MultiplePoint(M, P); // ��ԭʼ�ĵ��
  T1 := CnGetTickCount - T1;

  T2 := CnGetTickCount;
  for I := 1 to 1000 do
    FEd25519.ExtendedField64MultiplePoint(M, P4);
  T2 := CnGetTickCount - T2;

  ShowMessage(Format('Normal %d, Field64 Extended %d', [T1, T2])); // Field64 Extended �� Extended �Ļ�Ҫ��һ�����ϣ�
  CnField64Ecc4PointToEccPoint(Q, P4);
  if CnEccPointsEqual(P, Q) then
    ShowMessage('Ed 25519 1000 Mul/ Field64 Extended Mul Equal OK');

  Q.Free;
  P.Free;
  Ed.Free;
end;

procedure TForm25519.btnEd25519GenClick(Sender: TObject);
var
  Pub: TCnEd25519Data;
begin
  if FEd25519.GenerateKeys(FPrivKey, FPubKey) then
  begin
    edtEd25519Priv.Text := FPrivKey.ToHex(CN_25519_BLOCK_BYTESIZE);
    FEd25519.PointToPlain(FPubKey, Pub);
    edtEd25519Pub.Text := DataToHex(@Pub[0], CN_25519_BLOCK_BYTESIZE);
  end;
end;

procedure TForm25519.btnEd25519SignClick(Sender: TObject);
var
  Priv: TCnEccPrivateKey;
  Pub: TCnEccPublicKey;
  PubData: TCnEd25519Data;
  Sig: TCnEd25519Signature;
  SigData: TCnEd25519SignatureData;
  S: AnsiString;
begin
  Priv := TCnEccPrivateKey.Create;
  Pub := TCnEccPublicKey.Create;

  HexToData(edtEd25519Pub.Text, @PubData[0]);
  FEd25519.PlainToPoint(PubData, Pub);

  Priv.SetHex(edtEd25519Priv.Text);

  Sig := TCnEd25519Signature.Create;

  S := edtEd25519Message.Text;
  if CnEd25519SignData(@S[1], Length(S), Priv, Pub, Sig) then
  begin
    Sig.SaveToData(SigData);
    edtEd25519Sig.Text := DataToHex(@SigData[0], CN_25519_BLOCK_BYTESIZE * 2);
    ShowMessage('Sign OK');
  end;

  Sig.Free;

  Pub.Free;
  Priv.Free;
end;

procedure TForm25519.btnEd25519VerifyClick(Sender: TObject);
var
  Pub: TCnEccPublicKey;
  PubData: TCnEd25519Data;
  Sig: TCnEd25519Signature;
  SigData: TCnEd25519SignatureData;
  S: AnsiString;
begin
  Pub := TCnEccPublicKey.Create;

  HexToData(edtEd25519Pub.Text, @PubData[0]);
  FEd25519.PlainToPoint(PubData, Pub);

  Sig := TCnEd25519Signature.Create;
  HexToData(edtEd25519Sig.Text, @SigData[0]);
  Sig.LoadFromData(SigData);

  S := edtEd25519Message.Text;
  if CnEd25519VerifyData(@S[1], Length(S), Sig, Pub) then
    ShowMessage('Verify OK');

  Sig.Free;
  Pub.Free;
end;

procedure TForm25519.btnSignTimeClick(Sender: TObject);
var
  Priv: TCnEccPrivateKey;
  Pub: TCnEccPublicKey;
  PubData: TCnEd25519Data;
  Sig: TCnEd25519Signature;
  SigData: TCnEd25519SignatureData;
  S: AnsiString;
  T: Cardinal;
  I: Integer;
begin
  Priv := TCnEccPrivateKey.Create;
  Pub := TCnEccPublicKey.Create;

  HexToData(edtEd25519Pub.Text, @PubData[0]);
  FEd25519.PlainToPoint(PubData, Pub);

  Priv.SetHex(edtEd25519Priv.Text);

  Sig := TCnEd25519Signature.Create;

  S := edtEd25519Message.Text;
  T := CnGetTickCount;
  for I := 1 to 1000 do
  begin
    if CnEd25519SignData(@S[1], Length(S), Priv, Pub, Sig) then
      Sig.SaveToData(SigData);
  end;
  T := CnGetTickCount - T;
  ShowMessage('Sign OK ' + IntToStr(T));
  // 32 λ��7 ��ǩһǧ�Σ�һ�� 7 ����
  // 64 λ��2.5 ��ǩһǧ�Σ�һ�� 2.5 ����

  Sig.Free;

  Pub.Free;
  Priv.Free;
end;

procedure TForm25519.btnVerifyTimeClick(Sender: TObject);
var
  Pub: TCnEccPublicKey;
  PubData: TCnEd25519Data;
  Sig: TCnEd25519Signature;
  SigData: TCnEd25519SignatureData;
  S: AnsiString;
  T: Cardinal;
  I: Integer;
begin
  Pub := TCnEccPublicKey.Create;

  HexToData(edtEd25519Pub.Text, @PubData[0]);
  FEd25519.PlainToPoint(PubData, Pub);

  Sig := TCnEd25519Signature.Create;
  HexToData(edtEd25519Sig.Text, @SigData[0]);
  Sig.LoadFromData(SigData);

  S := edtEd25519Message.Text;
  T := CnGetTickCount;
  for I := 1 to 1000 do
  begin
    if CnEd25519VerifyData(@S[1], Length(S), Sig, Pub) then
      ;
  end;
  T := CnGetTickCount - T;
  ShowMessage('Verify OK ' + IntToStr(T));
  // 32 λ��15 ����֤һǧ�Σ�һ�� 15 ����
  // 64 λ��4.5 ����֤һǧ�Σ�һ�� 4.5 ����

  Sig.Free;
  Pub.Free;
end;

procedure TForm25519.btnEd25519SignFileClick(Sender: TObject);
var
  Ed: TCnEd25519;
  Priv: TCnEccPrivateKey;
  Pub: TCnEccPublicKey;
  PubData: TCnEd25519Data;
  SigStream: TMemoryStream;
begin
  dlgOpen1.Title := 'Open a File to Sign';
  if dlgOpen1.Execute then
  begin
    Ed := TCnEd25519.Create;
    Priv := TCnEccPrivateKey.Create;
    Pub := TCnEccPublicKey.Create;

    HexToData(edtEd25519Pub.Text, @PubData[0]);
    Ed.PlainToPoint(PubData, Pub);

    Priv.SetHex(edtEd25519Priv.Text);

    SigStream := TMemoryStream.Create;
    if CnEd25519SignFile(dlgOpen1.FileName, Priv, Pub, SigStream, Ed) then
    begin
      dlgSave1.Title := 'Save Signature to a File';
      dlgSave1.FileName := 'Sig.bin';
      if dlgSave1.Execute then
      begin
        SigStream.SaveToFile(dlgSave1.FileName);
        ShowMessage('Sign OK. Signature Saved to ' + dlgSave1.FileName);
      end;
    end;

    SigStream.Free;
    Pub.Free;
    Priv.Free;
    Ed.Free;
  end;
end;

procedure TForm25519.btnEd25519VerifyFileClick(Sender: TObject);
var
  Ed: TCnEd25519;
  Pub: TCnEccPublicKey;
  PubData: TCnEd25519Data;
  SigStream: TMemoryStream;
begin
  dlgOpen1.Title := 'Open a File to Verify';
  dlgSave1.Title := 'Open a Signature File';
  if dlgOpen1.Execute and dlgSave1.Execute then
  begin
    Ed := TCnEd25519.Create;
    Pub := TCnEccPublicKey.Create;

    HexToData(edtEd25519Pub.Text, @PubData[0]);
    Ed.PlainToPoint(PubData, Pub);

    SigStream := TMemoryStream.Create;
    SigStream.LoadFromFile(dlgSave1.FileName);
    SigStream.Position := 0;

    if CnEd25519VerifyFile(dlgOpen1.FileName, SigStream, Pub, Ed) then
      ShowMessage('Verify OK')
    else
      ShowMessage('Verify Fail');

    SigStream.Free;
    Pub.Free;
    Ed.Free;
  end;
end;

procedure TForm25519.btn25519Field64Power2kClick(Sender: TObject);
const
  K = 17;
  DATA = '7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0FFFFFFFFFFFFFFFFFFFFFFEC';
var
  B, C, P: TCnBigNumber;
  L: Integer;
  D: TCn25519Field64;
begin
  B := TCnBigNumber.FromHex(DATA);
  Cn25519BigNumberToField64(D, B);
  Cn25519Field64Power2K(D, D, K);

  C := TCnBigNumber.Create;
  Cn25519Field64ToBigNumber(C, D);
  ShowMessage(C.ToHex());

  L := 1 shl K;
  P := TCnBigNumber.FromHex(SCN_25519_PRIME);
  BigNumberPowerWordMod(B, B, L, P);

  ShowMessage(B.ToHex());  // ������ B �� C ���

  C.SetWord(K);
  B.SetHex(DATA);
  BigNumberPowerMod(B, B, C, P);
  ShowMessage(B.ToHex());          // ���������ȷֵ

  B.SetHex(DATA);
  Cn25519BigNumberToField64(D, B);
  Cn25519Field64Power(D, D, K);
  Cn25519Field64ToBigNumber(C, D);
  ShowMessage(C.ToHex());          // ������ B �� C ���

  B.SetHex(DATA);
  Cn25519BigNumberToField64(D, B);
  P.SetWord(K);
  Cn25519Field64Power(D, D, P);
  Cn25519Field64ToBigNumber(C, D);
  ShowMessage(C.ToHex());

  P.Free;
  C.Free;
  B.Free;
end;

procedure TForm25519.btn25519Field64PowerPMinus2Click(Sender: TObject);
const
  DATA = '345678909876543456fe1234567098';
var
  B, C, P: TCnBigNumber;
  D: TCn25519Field64;
begin
  P := TCnBigNumber.FromHex(SCN_25519_PRIME);
  B := TCnBigNumber.Create;
  BigNumberCopy(B, P);
  B.SubWord(2);

  C := TCnBigNumber.Create;
  C.SetHex(DATA);
  BigNumberPowerMod(C, C, B, P);  // ���� C �� p-2 �η����������
  ShowMessage(C.ToHex());

  C.SetHex(DATA);
  Cn25519BigNumberToField64(D, C);
  Cn25519Field64Power(D, D, B);    // ���� C �� p-2 �η�
  Cn25519Field64ToBigNumber(C, D);
  ShowMessage(C.ToHex());

  B.SetHex(DATA);
  BigNumberDirectMulMod(C, B, C, P);
  ShowMessage(C.ToHex());          // �õ� 1

  P.Free;
  C.Free;
  B.Free;
end;

end.
