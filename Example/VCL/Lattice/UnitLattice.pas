unit UnitLattice;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, CnLattice, ComCtrls;

type
  TFormLattice = class(TForm)
    pgcLattice: TPageControl;
    tsNTRU: TTabSheet;
    tsBasic: TTabSheet;
    btnInt64GaussianReduceBasis: TButton;
    btnGenNTRUKeys: TButton;
    btnPolynomialNTRU: TButton;
    btnSimpleTest2: TButton;
    btnSimpleTest: TButton;
    grpNTRU: TGroupBox;
    lblNTRUType: TLabel;
    lblPrivateKey: TLabel;
    lblPublicKey: TLabel;
    lblNTRUMessage: TLabel;
    lblNTRUPolynomial: TLabel;
    lblNTRUEnc: TLabel;
    lblNTRUDec: TLabel;
    lblNTRUMessageDec: TLabel;
    cbbNTRUType: TComboBox;
    mmoNTRUPrivateKeyF: TMemo;
    mmoNTRUPublicKey: TMemo;
    edtNTRUMessage: TEdit;
    mmoNTRUPolynomial: TMemo;
    mmoNTRUEnc: TMemo;
    btnNTRUEncrypt: TButton;
    mmoNTRUDec: TMemo;
    edtNTRUMessageDec: TEdit;
    btnNTRUGenerateKeys: TButton;
    mmoNTRUPrivateKeyG: TMemo;
    btnNTRUEncryptBytes: TButton;
    procedure btnSimpleTestClick(Sender: TObject);
    procedure btnInt64GaussianReduceBasisClick(Sender: TObject);
    procedure btnSimpleTest2Click(Sender: TObject);
    procedure btnPolynomialNTRUClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnGenNTRUKeysClick(Sender: TObject);
    procedure cbbNTRUTypeChange(Sender: TObject);
    procedure btnNTRUGenerateKeysClick(Sender: TObject);
    procedure btnNTRUEncryptClick(Sender: TObject);
    procedure btnNTRUEncryptBytesClick(Sender: TObject);
  private
    FPriv: TCnNTRUPrivateKey;
    FPub: TCnNTRUPublicKey;
  public
    { Public declarations }
  end;

var
  FormLattice: TFormLattice;

implementation

{$R *.DFM}

uses
  CnBigNumber, CnVector, CnPolynomial, CnNative;

procedure TFormLattice.btnSimpleTestClick(Sender: TObject);
var
  Q, H, F, G: TCnBigNumber;
  M, R, E: TCnBigNumber;
  A, B: TCnBigNumber;
  X, Y, V1, V2: TCnBigNumberVector;
begin
  // q �Ǵ���������ѡ������
  // ѡ f ��С�� q һ���ƽ����
  // ѡ g ���� q �ķ�֮һ��ƽ����С�� q һ���ƽ����
  // ���� h = g/f Ҳ���� g ���� f ���� q ��ģ��Ԫ
  // ˽Կ f g
  // ��Կ h q

  Q := TCnBigNumber.Create;
  H := TCnBigNumber.Create;
  F := TCnBigNumber.Create;
  G := TCnBigNumber.Create;

  M := TCnBigNumber.Create;
  R := TCnBigNumber.Create;
  E := TCnBigNumber.Create;

  A := TCnBigNumber.Create;
  B := TCnBigNumber.Create;

  Q.SetHex('FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF');
  // F ҪС�� Q/2 ��ƽ���� B504F3339F5BEAEA45EDB90ABDFFDE01 ����ȡ AA3A7C074DEF52E20A184147D7586D17
  // G Ҫ���� Q/4 ��ƽ���� 7FFFFFFFBFFFFFFFEFFFFFFFF7FFFFFF ��С�� F ����ȡ 961E643A19DC196A359774162C793BB1

  F.SetHex('AA3A7C074DEF52E20A184147D7586D17');
  G.SetHex('961E643A19DC196A359774162C793BB1');
  BigNumberModularInverse(H, F, Q);
  BigNumberDirectMulMod(H, H, G, Q);
  // H �õ� 1144FB9BEC274A81064DA6D5243258E7F5B997DE76CF45BEFAF0D97FDCCD8751

  // ȡ���� M ҪС�� Q/4 ��ƽ����ȡ 7BBBBBBBBBBBBBBBBBBBBBBBB7BBBBBB
  // ȡ������� R ҪС�� Q/2 ��ƽ����ȡ AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
  // ���� (R * H + M) mod Q �õ�����
  R.SetHex('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
  M.SetHex('7BBBBBBBBBBBBBBBBBBBBBBBB7BBBBBB');
  BigNumberDirectMulMod(E, R, H, Q);
  BigNumberAddMod(E, E, M, Q);

  // E ���ĵõ� B2EB4167BD48A4914086FE1D29F08E29FB8F8ED3FADC38146C41C8B2947AE56B
  ShowMessage(E.ToHex());

  // Ȼ�����
  // �ȼ��� A = F * E mod Q
  // �ټ��� A / F mod G Ҳ���� A ���� F �� G ��ģ��Ԫ
  BigNumberDirectMulMod(A, F, E, Q);
  BigNumberModularInverse(B, F, G);
  BigNumberDirectMulMod(B, A, B, G);

  ShowMessage(B.ToHex());
  if BigNumberEqual(B, M) then
    ShowMessage('Encryption/Decryption OK');

  // ���濼�ǹ�������
  // �ȼ����� (1, H) �� (0, Q) ���������������ʹ���� (F', G') �㹻��
  // ��� (F', G') �����þ͵�ͬ�� (F, G) �ܹ���������
  // ��������Ϊ��ά���ϵ� SVP �����������
  // ��ֱ��ʹ�ø�˹���Լ���㷨
  // ���㷨���� Gram_Schmidt ��������Ϊ����������ϵ������Ҫ��ϵ����������Ĵ���

  X := TCnBigNumberVector.Create(2);
  Y := TCnBigNumberVector.Create(2);
  V1 := TCnBigNumberVector.Create(2);
  V2 := TCnBigNumberVector.Create(2);

  X[0].SetWord(1);
  BigNumberCopy(X[1], H);
  Y[0].SetZero;
  BigNumberCopy(Y[1], Q);

  BigNumberGaussianLatticeReduction(V1, V2, X, Y);

  ShowMessage(V1.ToString); // V1 ������������˵���� F' �� G'
  ShowMessage(V2.ToString);

  // Ȼ�����½���
  // �ȼ��� A = F' * E mod Q
  // �ټ��� A / F' mod G' Ҳ���� A ���� F' �� G' ��ģ��Ԫ
  BigNumberDirectMulMod(A, V1[0], E, Q);
  BigNumberModularInverse(B, V1[0], V1[1]);
  BigNumberDirectMulMod(B, A, B, V1[1]);

  ShowMessage(B.ToHex());
  if BigNumberEqual(B, M) then
    ShowMessage('Attack OK');

  V2.Free;
  V1.Free;
  Y.Free;
  X.Free;

  B.Free;
  A.Free;

  E.Free;
  R.Free;
  M.Free;

  G.Free;
  F.Free;
  H.Free;
  Q.Free;
end;

procedure TFormLattice.btnInt64GaussianReduceBasisClick(Sender: TObject);
var
  V1, V2, X, Y: TCnInt64Vector;
begin
  // (90, 123) �� (56, 76) ҪԼ���õ� (-6, 3) �� (-2, -7)
  X := TCnInt64Vector.Create(2);
  Y := TCnInt64Vector.Create(2);
  V1 := TCnInt64Vector.Create(2);
  V2 := TCnInt64Vector.Create(2);

  X[0] := 90;
  X[1] := 123;
  Y[0] := 56;
  Y[1] := 76;

  Int64GaussianLatticeReduction(V1, V2, X, Y);
  ShowMessage(V1.ToString);
  ShowMessage(V2.ToString);

  V2.Free;
  V1.Free;
  Y.Free;
  X.Free;
end;

procedure TFormLattice.btnSimpleTest2Click(Sender: TObject);
var
  F, G, Fp, Fq, Ring, H: TCnInt64Polynomial;
  M, R: TCnInt64Polynomial;
  E: TCnInt64Polynomial;
begin
  // NTRU ����ʽ���ӹ������� N = 11, P = 3, Q = 32
  // ����ʽ��ߴ��� N - 1
  // ������ɶ���ʽ F �� G ��Ϊ˽Կ��������Ϊ -1 �� 0 �� 1
  F := TCnInt64Polynomial.Create([-1, 1, 1, 0, -1, 0, 1, 0, 0, 1, -1]);
  // -1+x+x^2-x^4+x^6+x^9-x^10

  G := TCnInt64Polynomial.Create([-1, 0, 1, 1, 0, 1, 0, 0, -1, 0, -1]);
  // -1+x^2+x^3+x^5-x^8-x^10

  Fp := TCnInt64Polynomial.Create();
  Fq := TCnInt64Polynomial.Create();

  Ring := TCnInt64Polynomial.Create();
  Ring.MaxDegree := 11;
  Ring[11] := 1;
  Ring[0] := -1;  // ����ʽ��Ϊ x^n - 1

  // �� F ��� 3 �� x^11 - 1 ��ģ�����ʽ
  Int64PolynomialGaloisModularInverse(Fp, F, Ring, 3);
  ShowMessage(Fp.ToString);  // 2X^9+X^8+2X^7+X^5+2X^4+2X^3+2X+1

  // �� F ��� 32 �� x^11 - 1 ��ģ�����ʽ
  Int64PolynomialGaloisPrimePowerModularInverse(Fq, F, Ring, 2, 5);
  ShowMessage(Fq.ToString); // 30X^10+18X^9+20X^8+22X^7+16X^6+15X^5+4X^4+16X^3+6X^2+9X+5

  // ���� H = P * Fq * G mod 32 ��Ϊ��Կ
  H := TCnInt64Polynomial.Create;
  Int64PolynomialGaloisMul(H, Fq, G, 32, Ring);
  Int64PolynomialGaloisMulWord(H, 3, 32);
  ShowMessage(H.ToString);  // 16X^10+19X^9+12X^8+19X^7+15X^6+24X^5+12X^4+20X^3+22X^2+25X+8

  // ���ܷ������ĺ������
  M := TCnInt64Polynomial.Create([-1, 0, 0, 1, -1, 0, 0, 0, -1, 1, 1]);  // ���� X^10+X^9-X^8-X^4+X^3-1
  R := TCnInt64Polynomial.Create([-1, 0, 1, 1, 1, -1, 0, -1]);           // ����� -X^7-X^5+X^4+X^3+X^2-1

  E := TCnInt64Polynomial.Create;

  // ���ܵ��������� Ring �ϼ��� e = r * h + m mod 32
  Int64PolynomialGaloisMul(E, R, H, 32, Ring);
  Int64PolynomialGaloisAdd(E, E, M, 32, Ring);
  ShowMessage(E.ToString); // 19X^10+6X^9+25X^8+7X^7+30X^6+16X^5+14X^4+24X^3+26X^2+11X+14

  // ������ Ring �� f * e mod 32 �� mod 3 �ٳ��� Fp mod 3
  Int64PolynomialGaloisMul(G, F, E, 32, Ring);

  Int64PolynomialCentralize(G, 32); // ϵ������ -15 �� 16 �õ� -7X^10-3X^9+5X^8+7X^7+6X^6+7X^5+10X^4-11X^3-10X^2-7X+3

  Int64PolynomialNonNegativeModWord(G, 3);
  Int64PolynomialGaloisMul(G, G, Fp, 3, Ring);
  Int64PolynomialCentralize(G, 3);  // ϵ������ -1 �� 1 �õ� -7X^10-3X^9+5X^8+7X^7+6X^6+7X^5+10X^4-11X^3-10X^2-7X+3

  ShowMessage(G.ToString);       // �������� X^10+X^9-X^8-X^4+X^3-1 ͨ��!
  ShowMessage('Encryption/Decryption OK');

  // TODO: ���濼�ǹ�������

  E.Free;
  R.Free;
  M.Free;
  H.Free;
  Ring.Free;
  Fq.Free;
  Fp.Free;
  G.Free;
  F.Free;
end;

procedure TFormLattice.btnPolynomialNTRUClick(Sender: TObject);
var
  NTRU: TCnNTRU;
  M, En, De: TCnInt64Polynomial;
begin
  if FPriv.F.IsZero then
  begin
    ShowMessage('Invalid Keys');
    Exit;
  end;

  NTRU := TCnNTRU.Create(cnptHPS2048509);
  // NTRU.GenerateKeys(FPriv, FPub);

  M := TCnInt64Polynomial.Create([1,0,1,1,0,0,0,0,1,-1,-1,-1,-1,-1,-1,0,1,-1]);
  En := TCnInt64Polynomial.Create;
  De := TCnInt64Polynomial.Create;

  NTRU.Encrypt(FPub, M, En);
  ShowMessage(En.ToString);
  NTRU.Decrypt(FPriv, En, De);
  ShowMessage(De.ToString);

  if Int64PolynomialEqual(M, De) then
    ShowMessage('Encryption/Decryption OK');

  De.Free;
  En.Free;
  M.Free;
  NTRU.Free;
end;

procedure TFormLattice.FormCreate(Sender: TObject);
var
  Pt: TCnNTRUParamType;
begin
  FPriv := TCnNTRUPrivateKey.Create;
  FPub := TCnNTRUPublicKey.Create;

  for Pt := Low(TCnNTRUParamType) to High(TCnNTRUParamType) do
    cbbNTRUType.Items.Add(GetEnumName(TypeInfo(TCnNTRUParamType), Ord(Pt)));
end;

procedure TFormLattice.FormDestroy(Sender: TObject);
begin
  FPub.Free;
  FPriv.Free;
end;

procedure TFormLattice.btnGenNTRUKeysClick(Sender: TObject);
var
  NTRU: TCnNTRU;
begin
  NTRU := TCnNTRU.Create(cnptHPS2048509);
  NTRU.GenerateKeys(FPriv, FPub);
  ShowMessage('Keys Generate OK.');
  ShowMessage(FPriv.F.ToString);
  ShowMessage(FPriv.G.ToString);
  ShowMessage(FPub.H.ToString);
  NTRU.Free;
end;

procedure TFormLattice.cbbNTRUTypeChange(Sender: TObject);
begin
  mmoNTRUPrivateKeyF.Lines.Clear;
  mmoNTRUPrivateKeyG.Lines.Clear;
  mmoNTRUPublicKey.Lines.Clear;
end;

procedure TFormLattice.btnNTRUGenerateKeysClick(Sender: TObject);
var
  NTRU: TCnNTRU;
begin
  NTRU := TCnNTRU.Create(TCNNTRUParamType(cbbNTRUType.ItemIndex));
  NTRU.GenerateKeys(FPriv, FPub);
  mmoNTRUPrivateKeyF.Lines.Text := FPriv.F.ToString;
  mmoNTRUPrivateKeyG.Lines.Text := FPriv.G.ToString;
  mmoNTRUPublicKey.Lines.Text := FPub.H.ToString;
  NTRU.Free;
end;

procedure TFormLattice.btnNTRUEncryptClick(Sender: TObject);
var
  NTRU: TCnNTRU;
  B: TBytes;
  Pl, En, De: TCnInt64Polynomial;
  L: Integer;
begin
  NTRU := TCnNTRU.Create(TCNNTRUParamType(cbbNTRUType.ItemIndex));
  B := AnsiToBytes(edtNTRUMessage.Text);

  Pl := TCnInt64Polynomial.Create;
  NTRUDataToInt64Polynomial(Pl, @B[0], Length(B), NTRU.N, NTRU.Prime);
  mmoNTRUPolynomial.Lines.Text := Pl.ToString; // ����ԭ��ת���ɶ���ʽ

  En := TCnInt64Polynomial.Create;
  NTRU.Encrypt(FPub, Pl, En);
  mmoNTRUEnc.Lines.Text := En.ToString;        // ԭ�Ķ���ʽ���ܺ�Ķ���ʽ���

  De := TCnInt64Polynomial.Create;
  NTRU.Decrypt(FPriv, En, De);                 // ע������û��ת�����������ݣ�����ֱ��ʹ�����Ķ���ʽ���н���

  mmoNTRUDec.Lines.Text := De.ToString;        // ���Ķ���ʽ���ܺ�Ķ���ʽ���

  L := NTRUInt64PolynomialToData(De, NTRU.N, NTRU.Prime, nil);
  if L > 0 then
  begin
    SetLength(B, L);
    NTRUInt64PolynomialToData(De, NTRU.N, NTRU.Prime, @B[0]);
    edtNTRUMessageDec.Text := BytesToAnsi(B);
  end;

  Pl.Free;
  En.Free;
  De.Free;
  NTRU.Free;
end;

procedure TFormLattice.btnNTRUEncryptBytesClick(Sender: TObject);
var
  NTRU: TCnNTRU;
  Pl, En, De: TBytes;
begin
  NTRU := TCnNTRU.Create(TCNNTRUParamType(cbbNTRUType.ItemIndex));
  Pl := AnsiToBytes(edtNTRUMessage.Text);

  En := NTRU.EncryptBytes(FPub, Pl);
  mmoNTRUEnc.Lines.Text := BytesToHex(En);

  De := NTRU.DecryptBytes(FPriv, En);
  edtNTRUMessageDec.Text := BytesToAnsi(De);

  NTRU.Free;
end;

end.
