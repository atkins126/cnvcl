{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
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
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnSM2;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�SM2 ��Բ�����㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��ʵ���� GM/T0003.x-2012��SM2��Բ���߹�Կ�����㷨��
*           �淶�еĻ��� SM2 �����ݼӽ��ܡ�ǩ����ǩ����Կ����
*           ע����ǩ���淶��ȫ��ͬ�� openssl �е� Ecc ǩ���������Ӵպ���ֻ��ʹ�� SM3
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.04.04 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnECC, CnBigNumber, CnSM3, CnKDF;

type
  TCnSM2 = class(TCnEcc)
  {* SM2 ��Բ���������࣬����ʵ����ָ���������͵Ļ��� TCnEcc ��}
  public
    constructor Create; override;
  end;

  TCnSM2Signature = class(TCnEccPoint);
  {* ǩ��������������X Y �ֱ���� R S}

// ========================= SM2 ��Բ���߼ӽ����㷨 ============================

function CnSM2EncryptData(PlainData: Pointer; DataLen: Integer; OutStream:
  TStream; PublicKey: TCnEccPublicKey; Sm2: TCnSm2 = nil): Boolean;
{* �ù�Կ�����ݿ���м��ܣ��ο� GM/T0003.4-2012��SM2��Բ���߹�Կ�����㷨
   ��4����:��Կ�����㷨���е�������򣬲�ͬ����ͨ ECC �� RSA �Ķ������}

function CnSM2DecryptData(EnData: Pointer; DataLen: Integer; OutStream: TStream;
  PrivateKey: TCnEccPrivateKey; Sm2: TCnSm2 = nil): Boolean;
{* �ù�Կ�����ݿ���н��ܣ��ο� GM/T0003.4-2012��SM2��Բ���߹�Կ�����㷨
   ��4����:��Կ�����㷨���е�������򣬲�ͬ����ͨ ECC �� RSA �Ķ������}

// ====================== SM2 ��Բ��������ǩ����֤�㷨 =========================

function CnSM2SignData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  OutSignature: TCnSM2Signature; PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey;
  Sm2: TCnSM2 = nil): Boolean;
{* ˽Կ�����ݿ�ǩ������ GM/T0003.2-2012��SM2��Բ���߹�Կ�����㷨
   ��2����:����ǩ���㷨���е��������Ҫ����ǩ������������Ϣ�Լ���Կ������ժҪ}

function CnSM2VerifyData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  InSignature: TCnSM2Signature; PublicKey: TCnEccPublicKey; Sm2: TCnSM2 = nil): Boolean;
{* ��Կ��֤���ݿ��ǩ������ GM/T0003.2-2012��SM2��Բ���߹�Կ�����㷨
   ��2����:����ǩ���㷨���е����������}

// ======================== SM2 ��Բ������Կ�����㷨 ===========================

{
  SM2 ��Կ����ǰ�᣺A B ˫���������� ID �빫˽Կ������֪���Է��� ID ��Է��Ĺ�Կ
}
function CnSM2KeyExchangeAStep1(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  APrivateKey: TCnEccPrivateKey; APublicKey, BPublicKey: TCnEccPublicKey;
  OutARand: TCnBigNumber; OutRA: TCnEccPoint; Sm2: TCnSM2 = nil): Boolean;
{* ���� SM2 ����Կ����Э�飬��һ�� A �û���������� RA�������� B
  ���룺A B ���û������������볤�ȡ��Լ���˽Կ��˫���Ĺ�Կ
  ��������ֵ OutARand�����ɵ������ RA������ B��}

function CnSM2KeyExchangeBStep1(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  BPrivateKey: TCnEccPrivateKey; APublicKey, BPublicKey: TCnEccPublicKey; InRA: TCnEccPoint;
  out OutKeyB: AnsiString; OutRB: TCnEccPoint; out OutOptionalSB: TSM3Digest;
  out OutOptionalS2: TSM3Digest; Sm2: TCnSM2 = nil): Boolean;
{* ���� SM2 ����Կ����Э�飬�ڶ��� B �û��յ� A �����ݣ����� Kb�����ѿ�ѡ����֤������� A
  ���룺A B ���û������������볤�ȡ��Լ���˽Կ��˫���Ĺ�Կ��A ������ RA
  ���������ɹ��Ĺ�����Կ Kb�����ɵ������ RB������ A������ѡ��У���Ӵ� SB������ A ��֤������ѡ��У���Ӵ� S2}

function CnSM2KeyExchangeAStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  APrivateKey: TCnEccPrivateKey; APublicKey, BPublicKey: TCnEccPublicKey; MyRA, InRB: TCnEccPoint;
  MyARand: TCnBigNumber; out OutKeyA: AnsiString; InOptionalSB: TSM3Digest;
  out OutOptionalSA: TSM3Digest; Sm2: TCnSM2 = nil): Boolean;
{* ���� SM2 ����Կ����Э�飬������ A �û��յ� B �����ݼ��� Ka�����ѿ�ѡ����֤������� B������Э�̺� Ka = Kb
  ���룺A B ���û������������볤�ȡ��Լ���˽Կ��˫���Ĺ�Կ��B ������ RB ���ѡ�� SB���Լ��ĵ� RA���Լ������ֵ MyARand
  ���������ɹ��Ĺ�����Կ Ka����ѡ��У���Ӵ� SA������ B ��֤��}

function CnSM2KeyExchangeBStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  BPrivateKey: TCnEccPrivateKey; APublicKey, BPublicKey: TCnEccPublicKey;
  InOptionalSA: TSM3Digest; MyOptionalS2: TSM3Digest; Sm2: TCnSM2 = nil): Boolean;
{* ���� SM2 ����Կ����Э�飬���Ĳ� B �û��յ� A �����ݼ�����У�飬Э����ϣ��˲���ѡ
  ʵ����ֻ�Ա� B �ڶ������ɵ� S2 �� A ������������ SA�������������ʹ��}

implementation

{* X <= 2^W + (x and (2^W - 1) ��ʾ�� x �ĵ� W λ�� 1���� W + 1 ������ȫ�� 0
   �����֮����ȡ X �ĵ� W λ����֤��һλ�ĵ� W λ�� 1��λ�� 0 ��ʼ��
  ���� W �� N �� BitsCount ��һ���ٵ�����ú���������Կ����
  ע�⣺���� CnECC �е�ͬ���������ܲ�ͬ}
procedure BuildShortXValue(X: TCnBigNumber; Order: TCnBigNumber);
var
  I, W: Integer;
begin
  W := (Order.GetBitsCount + 1) div 2 - 1;
  BigNumberSetBit(X, W);
  for I := W + 1 to X.GetBitsCount - 1 do
    BigNumberClearBit(X, I);
end;

{ TCnSM2 }

constructor TCnSM2.Create;
begin
  inherited;
  Load(ctSM2);
end;

{
  �������� M���� MLen �ֽڣ�������� k������

  Cl = k * G => (xl, yl)         // ��ѹ���洢������Ϊ��������λ���� 1

  k * PublicKey => (x2, y2)
  t <= KDF(x2��y2, Mlen)
  C2 <= M xor t                  // ���� MLen

  C3 <= SM3(x2��M��y2)           // ���� 32 �ֽ�

  ����Ϊ��C1��C3��C2
}
function CnSM2EncryptData(PlainData: Pointer; DataLen: Integer; OutStream:
  TStream; PublicKey: TCnEccPublicKey; Sm2: TCnSm2 = nil): Boolean;
var
  Py, P1, P2: TCnEccPoint;
  K: TCnBigNumber;
  B: Byte;
  M: PAnsiChar;
  I: Integer;
  Buf: array of Byte;
  KDFStr, T, C3H: AnsiString;
  Sm3Dig: TSM3Digest;
  Sm2IsNil: Boolean;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (OutStream = nil) or (PublicKey = nil) then
    Exit;

  Py := nil;
  P1 := nil;
  P2 := nil;
  K := nil;
  Sm2IsNil := Sm2 = nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    K := TCnBigNumber.Create;

    // ȷ����Կ X Y ������
    if PublicKey.Y.IsZero then
    begin
      Py := TCnEccPoint.Create;
      if not Sm2.PlainToPoint(PublicKey.X, Py) then
        Exit;
      BigNumberCopy(PublicKey.Y, Py.Y);
    end;

    // ����һ����� K
    if not BigNumberRandRange(K, Sm2.Order) then
      Exit;
    // K.SetHex('384F30353073AEECE7A1654330A96204D37982A3E15B2CB5');

    P1 := TCnEccPoint.Create;
    P1.Assign(Sm2.Generator);
    Sm2.MultiplePoint(K, P1);  // ����� K * G �õ� X1 Y1

    B := 4;
    OutStream.Position := 0;

    OutStream.Write(B, 1);
    SetLength(Buf, P1.X.GetBytesCount);
    P1.X.ToBinary(@Buf[0]);
    OutStream.Write(Buf[0], P1.X.GetBytesCount);
    SetLength(Buf, P1.Y.GetBytesCount);
    P1.Y.ToBinary(@Buf[0]);
    OutStream.Write(Buf[0], P1.Y.GetBytesCount); // ƴ�� C1

    P2 := TCnEccPoint.Create;
    P2.Assign(PublicKey);
    Sm2.MultiplePoint(K, P2); // ����� K * PublicKey �õ� X2 Y2

    SetLength(KDFStr, P2.X.GetBytesCount + P2.Y.GetBytesCount);
    P2.X.ToBinary(@KDFStr[1]);
    P2.Y.ToBinary(@KDFStr[P2.X.GetBytesCount + 1]);
    T := CnSM2KDF(KDFStr, DataLen);

    M := PAnsiChar(PlainData);
    for I := 1 to DataLen do
      T[I] := AnsiChar(Byte(T[I]) xor Byte(M[I - 1])); // T ���� C2�����Ȳ���д

    SetLength(C3H, P2.X.GetBytesCount + P2.Y.GetBytesCount + DataLen);
    P2.X.ToBinary(@C3H[1]);
    Move(M[0], C3H[P2.X.GetBytesCount + 1], DataLen);
    P2.Y.ToBinary(@C3H[P2.X.GetBytesCount + DataLen + 1]); // ƴ���� C3 ��
    Sm3Dig := SM3(@C3H[1], Length(C3H));                   // ��� C3

    OutStream.Write(Sm3Dig[0], SizeOf(TSM3Digest));        // д�� C3
    OutStream.Write(T[1], DataLen);                        // д�� C2
    Result := True;
  finally
    P2.Free;
    P1.Free;
    Py.Free;
    K.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

{
  MLen <= DataLen - SM3DigLength - 2 * Sm2 Byte Length - 1�������õ� C1 C2 C3

  PrivateKey * C1 => (x2, y2)

  t <= KDF(x2��y2, Mlen)

  M' <= C2 xor t

  ���ɶԱ� SM3(x2��M��y2) Hash �Ƿ��� C3 ���
}
function CnSM2DecryptData(EnData: Pointer; DataLen: Integer; OutStream: TStream;
  PrivateKey: TCnEccPrivateKey; Sm2: TCnSM2): Boolean;
var
  MLen: Integer;
  M: PAnsiChar;
  MP: AnsiString;
  KDFStr, T, C3H: AnsiString;
  Sm2IsNil: Boolean;
  P2: TCnEccPoint;
  I: Integer;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  if (EnData = nil) or (DataLen <= 0) or (OutStream = nil) or (PrivateKey = nil) then
    Exit;

  P2 := nil;
  Sm2IsNil := Sm2 = nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    MLen := DataLen - SizeOf(TSM3Digest) - (Sm2.BitsCount div 4) - 1;
    if MLen <= 0 then
      Exit;

    P2 := TCnEccPoint.Create;
    M := PAnsiChar(EnData);
    Inc(M);
    P2.X.SetBinary(M, Sm2.BitsCount div 8);
    Inc(M, Sm2.BitsCount div 8);
    P2.Y.SetBinary(M, Sm2.BitsCount div 8);
    Sm2.MultiplePoint(PrivateKey, P2);

    SetLength(KDFStr, P2.X.GetBytesCount + P2.Y.GetBytesCount);
    P2.X.ToBinary(@KDFStr[1]);
    P2.Y.ToBinary(@KDFStr[P2.X.GetBytesCount + 1]);
    T := CnSM2KDF(KDFStr, MLen);

    SetLength(MP, MLen);
    M := PAnsiChar(EnData);
    Inc(M, SizeOf(TSM3Digest) + (Sm2.BitsCount div 4) + 1);
    for I := 1 to MLen do
      MP[I] := AnsiChar(Byte(M[I - 1]) xor Byte(T[I])); // MP �õ�����

    SetLength(C3H, P2.X.GetBytesCount + P2.Y.GetBytesCount + MLen);
    P2.X.ToBinary(@C3H[1]);
    Move(MP[1], C3H[P2.X.GetBytesCount + 1], MLen);
    P2.Y.ToBinary(@C3H[P2.X.GetBytesCount + MLen + 1]);    // ƴ���� C3 ��
    Sm3Dig := SM3(@C3H[1], Length(C3H));                   // ��� C3

    M := PAnsiChar(EnData);
    Inc(M, (Sm2.BitsCount div 4) + 1);
    if CompareMem(@Sm3Dig[0], M, SizeOf(TSM3Digest)) then  // �ȶ� Hash �Ƿ����
    begin
      OutStream.Write(MP[1], Length(MP));
      Result := True;
    end;
  finally
    P2.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

// ���� Za ֵҲ���� Hash(EntLen��UserID��a��b��xG��yG��xA��yA)
function CalcSM2UserHash(const UserID: AnsiString; PublicKey: TCnEccPublicKey;
  Sm2: TCnSM2): TSM3Digest;
var
  Stream: TMemoryStream;
  Len: Integer;
  ULen: Word;
begin
  Stream := TMemoryStream.Create;
  try
    Len := Length(UserID) * 8;
    ULen := ((Len and $FF) shl 8) or ((Len and $FF00) shr 8);

    Stream.Write(ULen, SizeOf(ULen));
    if ULen > 0 then
      Stream.Write(UserID[1], Length(UserID));

    BigNumberWriteBinaryToStream(Sm2.CoefficientA, Stream);
    BigNumberWriteBinaryToStream(Sm2.CoefficientB, Stream);
    BigNumberWriteBinaryToStream(Sm2.Generator.X, Stream);
    BigNumberWriteBinaryToStream(Sm2.Generator.Y, Stream);
    BigNumberWriteBinaryToStream(PublicKey.X, Stream);
    BigNumberWriteBinaryToStream(PublicKey.Y, Stream);

    Result := SM3(PAnsiChar(Stream.Memory), Stream.Size);  // ��� ZA
  finally
    Stream.Free;
  end;
end;

// ���� Za �������ٴμ����Ӵ�ֵ e
function CalcSM2SignatureHash(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  PublicKey: TCnEccPublicKey; Sm2: TCnSM2): TSM3Digest;
var
  Stream: TMemoryStream;
  Sm3Dig: TSM3Digest;
begin
  Stream := TMemoryStream.Create;
  try
    Sm3Dig := CalcSM2UserHash(UserID, PublicKey, Sm2);
    Stream.Write(Sm3Dig[0], SizeOf(TSM3Digest));
    Stream.Write(PlainData^, DataLen);

    Result := SM3(PAnsiChar(Stream.Memory), Stream.Size);  // �ٴ�����Ӵ�ֵ e
  finally
    Stream.Free;
  end;
end;

{
  ZA <= Hash(EntLen��UserID��a��b��xG��yG��xA��yA)
  e <= Hash(ZA��M)

  k * G => (x1, y1)

  r <= (e + x1) mod n

  s <= ((1 + PrivateKey)^-1 * (k - r * PrivateKey)) mod n
}
function CnSM2SignData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  OutSignature: TCnSM2Signature; PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey;
  Sm2: TCnSM2): Boolean;
var
  K, R, E: TCnBigNumber;
  P: TCnEccPoint;
  Sm2IsNil: Boolean;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (OutSignature = nil) or
    (PrivateKey = nil) or (PublicKey = nil) then
    Exit;

  K := nil;
  P := nil;
  E := nil;
  R := nil;
  Sm2IsNil := Sm2 = nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    Sm3Dig := CalcSM2SignatureHash(UserID, PlainData, DataLen, PublicKey, Sm2); // �Ӵ�ֵ e

    P := TCnEccPoint.Create;
    E := TCnBigNumber.Create;
    R := TCnBigNumber.Create;
    K := TCnBigNumber.Create;

    while True do
    begin
      // ����һ����� K
      if not BigNumberRandRange(K, Sm2.Order) then
        Exit;
      // K.SetHex('6CB28D99385C175C94F94E934817663FC176D925DD72B727260DBAAE1FB2F96F');

      P.Assign(Sm2.Generator);
      Sm2.MultiplePoint(K, P);

      // ���� R = (e + x) mod N
      E.SetBinary(@Sm3Dig[0], SizeOf(TSM3Digest));
      if not BigNumberAdd(E, E, P.X) then
        Exit;
      if not BigNumberMod(R, E, Sm2.Order) then // ��� R �� E ������
        Exit;

      if R.IsZero then  // R ����Ϊ 0
        Continue;

      if not BigNumberAdd(E, R, K) then
        Exit;
      if BigNumberCompare(E, Sm2.Order) = 0 then // R + K = N Ҳ����
        Continue;

      BigNumberCopy(OutSignature.X, R);  // �õ�һ��ǩ��ֵ R

      BigNumberCopy(E, PrivateKey);
      BigNumberAddWord(E, 1);
      BigNumberModularInverse(R, E, Sm2.Order);      // ����Ԫ�õ� (1 + PrivateKey)^-1������ R ��

      // �� K - R * PrivateKey�������� E ��
      if not BigNumberMul(E, OutSignature.X, PrivateKey) then
        Exit;
      if not BigNumberSub(E, K, E) then
        Exit;

      if not BigNumberMul(R, E, R) then // (1 + PrivateKey)^-1 * (K - R * PrivateKey) ���� R ��
        Exit;

      if not BigNumberNonNegativeMod(OutSignature.Y, R, Sm2.Order) then // ע����������Ϊ��
        Exit;

      Result := True;
      Break;
    end;
  finally
    K.Free;
    P.Free;
    R.Free;
    E.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

{
  ZA = Hash(EntLen��UserID��a��b��xG��yG��xA��yA)
  e <= Hash(ZA��M)

  t <= (r + s) mod n
  P <= s * G + t * PublicKey
  r' <= (e + P.x) mod n
  �ȶ� r' �� r
}
function CnSM2VerifyData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  InSignature: TCnSM2Signature; PublicKey: TCnEccPublicKey; Sm2: TCnSM2 = nil): Boolean;
var
  K, R, E: TCnBigNumber;
  P, Q: TCnEccPoint;
  Sm2IsNil: Boolean;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (InSignature = nil) or (PublicKey = nil) then
    Exit;

  K := nil;
  P := nil;
  Q := nil;
  E := nil;
  R := nil;
  Sm2IsNil := Sm2 = nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    if BigNumberCompare(InSignature.X, Sm2.Order) >= 0 then
      Exit;
    if BigNumberCompare(InSignature.Y, Sm2.Order) >= 0 then
      Exit;

    Sm3Dig := CalcSM2SignatureHash(UserID, PlainData, DataLen, PublicKey, Sm2); // �Ӵ�ֵ e

    P := TCnEccPoint.Create;
    Q := TCnEccPoint.Create;
    E := TCnBigNumber.Create;
    R := TCnBigNumber.Create;
    K := TCnBigNumber.Create;

    if not BigNumberAdd(K, InSignature.X, InSignature.Y) then
      Exit;
    if not BigNumberNonNegativeMod(R, K, Sm2.Order) then
      Exit;
    if R.IsZero then  // (r + s) mod n = 0 ��ʧ�ܣ����� R �����е� T
      Exit;

    P.Assign(Sm2.Generator);
    Sm2.MultiplePoint(InSignature.Y, P);
    Q.Assign(PublicKey);
    Sm2.MultiplePoint(R, Q);
    Sm2.PointAddPoint(P, Q, P);   // s * G + t * PublicKey => P

    E.SetBinary(@Sm3Dig[0], SizeOf(TSM3Digest));
    if not BigNumberAdd(E, E, P.X) then
      Exit;

    if not BigNumberNonNegativeMod(R, E, Sm2.Order) then
      Exit;

    Result := BigNumberCompare(R, InSignature.X) = 0;
  finally
    K.Free;
    P.Free;
    Q.Free;
    R.Free;
    E.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

{
  ���㽻��������Կ��KDF(Xuv��Yuv��Za��Zb, kLen)
}
function CalcSM2ExchangeKey(UV: TCnEccPoint; Za, Zb: TSM3Digest; KeyByteLength: Integer): AnsiString;
var
  Stream: TMemoryStream;
  S: AnsiString;
begin
  Stream := TMemoryStream.Create;
  try
    BigNumberWriteBinaryToStream(UV.X, Stream);
    BigNumberWriteBinaryToStream(UV.Y, Stream);
    Stream.Write(Za[0], SizeOf(TSM3Digest));
    Stream.Write(Zb[0], SizeOf(TSM3Digest));

    SetLength(S, Stream.Size);
    Stream.Position := 0;
    Stream.Read(S[1], Stream.Size);

    Result := CnSM2KDF(S, KeyByteLength);
  finally
    SetLength(S, 0);
    Stream.Free;
  end;
end;

{
  Hash(0x02��Yuv��Hash(Xuv��Za��Zb��X1��Y1��X2��Y2))
       0x03
}
function CalcSM2OptionalSig(UV, P1, P2: TCnEccPoint; Za, Zb: TSM3Digest; Step2or3: Boolean): TSM3Digest;
var
  Stream: TMemoryStream;
  Sm3Dig: TSM3Digest;
  B: Byte;
begin
  if Step2or3 then
    B := 2
  else
    B := 3;

  Stream := TMemoryStream.Create;
  try
    BigNumberWriteBinaryToStream(UV.X, Stream);
    Stream.Write(Za[0], SizeOf(TSM3Digest));
    Stream.Write(Zb[0], SizeOf(TSM3Digest));
    BigNumberWriteBinaryToStream(P1.X, Stream);
    BigNumberWriteBinaryToStream(P1.Y, Stream);
    BigNumberWriteBinaryToStream(P2.X, Stream);
    BigNumberWriteBinaryToStream(P2.Y, Stream);
    Sm3Dig := SM3(PAnsiChar(Stream.Memory), Stream.Size);

    Stream.Clear;
    Stream.Write(B, 1);
    BigNumberWriteBinaryToStream(UV.Y, Stream);
    Stream.Write(Sm3Dig[0], SizeOf(TSM3Digest));

    Result := SM3(PAnsiChar(Stream.Memory), Stream.Size);
  finally
    Stream.Free;
  end;
end;

{
  ���ֵ rA * G => RA ���� B
}
function CnSM2KeyExchangeAStep1(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  APrivateKey: TCnEccPrivateKey; APublicKey, BPublicKey: TCnEccPublicKey;
  OutARand: TCnBigNumber; OutRA: TCnEccPoint; Sm2: TCnSM2): Boolean;
var
  Sm2IsNil: Boolean;
begin
  Result := False;
  if (KeyByteLength <= 0) or (APrivateKey = nil) or (APublicKey = nil) or (OutRA = nil)
    or (OutARand = nil) then
    Exit;

  Sm2IsNil := Sm2 = nil;
  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    if not BigNumberRandRange(OutARand, Sm2.Order) then
      Exit;
    // OutARand.SetHex('83A2C9C8B96E5AF70BD480B472409A9A327257F1EBB73F5B073354B248668563');

    OutRA.Assign(Sm2.Generator);
    Sm2.MultiplePoint(OutARand, OutRA);
    Result := True;
  finally
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

{
  ���ֵ * G => RB
  x2 <= RB.X
  X2 <= 2^W + (x2 and (2^W - 1) ��ʾ�� x2 �ĵ� W λ�� 1��W + 1 ����ȫ�� 0
  T <= (BPrivateKey + ���ֵ * X2) mod N

  x1 <= RA.X
  X1 <= 2^W + (x1 and (2^W - 1)
  KB <= (h * T) * (APublicKey + X1 * RA)

  ע�� BigNumber �� BitCount Ϊ 2 Ϊ�׵Ķ�������ȡ��
}
function CnSM2KeyExchangeBStep1(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  BPrivateKey: TCnEccPrivateKey; APublicKey, BPublicKey: TCnEccPublicKey; InRA: TCnEccPoint;
  out OutKeyB: AnsiString; OutRB: TCnEccPoint; out OutOptionalSB: TSM3Digest;
  out OutOptionalS2: TSM3Digest; Sm2: TCnSM2): Boolean;
var
  Sm2IsNil: Boolean;
  R, X, T: TCnBigNumber;
  V: TCnEccPoint;
  Za, Zb: TSM3Digest;
begin
  Result := False;
  if (KeyByteLength <= 0) or (BPrivateKey = nil) or (APublicKey = nil) or
    (BPublicKey = nil) or (InRA = nil) then
    Exit;

  Sm2IsNil := Sm2 = nil;
  R := nil;
  X := nil;
  T := nil;
  V := nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    if not Sm2.IsPointOnCurve(InRA) then // ��֤�������� RA �Ƿ����㷽��
      Exit;

    R := TCnBigNumber.Create;
    if not BigNumberRandRange(R, Sm2.Order) then
      Exit;

    R.SetHex('33FE21940342161C55619C4A0C060293D543C80AF19748CE176D83477DE71C80');
    OutRB.Assign(Sm2.Generator);
    Sm2.MultiplePoint(R, OutRB);

    X := TCnBigNumber.Create;
    BigNumberCopy(X, OutRB.X);

    // 2^W �η���ʾ�� W λ 1��λ�� 0 ��ʼ�㣩 ��2^W - 1 ���ʾ 0 λ�� W - 1 λȫ�� 1
    // X2 = 2^W + (x2 and (2^W - 1) ��ʾ�� x2 �ĵ� W λ�� 1��W + 1 ����ȫ�� 0��x2 �� RB.X
    BuildShortXValue(X, Sm2.Order);

    if not BigNumberMul(X, R, X) then
      Exit;
    if not BigNumberAdd(X, X, BPrivateKey) then
      Exit;
    T := TCnBigNumber.Create;
    if not BigNumberNonNegativeMod(T, X, Sm2.Order) then // T = (BPrivateKey + ���ֵ * X2) mod N
      Exit;

    BigNumberCopy(X, InRA.X);
    BuildShortXValue(X, Sm2.Order);

    // ���� XV YV�� (h * t) * (APublicKey + X * RA)
    V := TCnEccPoint.Create;
    V.Assign(InRA);
    Sm2.MultiplePoint(X, V);
    Sm2.PointAddPoint(V, APublicKey, V);
    Sm2.MultiplePoint(T, V);

    if V.X.IsZero or V.Y.IsZero then // ���������Զ����Э��ʧ��
      Exit;

    // Э�̳����ɹ������� KB
    Za := CalcSM2UserHash(AUserID, APublicKey, Sm2);
    Zb := CalcSM2UserHash(BUserID, BPublicKey, Sm2);
    OutKeyB := CalcSM2ExchangeKey(V, Za, Zb, KeyByteLength); // ������ԿЭ�̳ɹ���

    // Ȼ����� SB �� A �˶�
    OutOptionalSB := CalcSM2OptionalSig(V, InRA, OutRB, Za, Zb, True);

    // ˳����� S2 �� A ���� SA ʱ�˶�
    OutOptionalS2 := CalcSM2OptionalSig(V, InRA, OutRB, Za, Zb, False);
    Result := True;
  finally
    V.Free;
    T.Free;
    X.Free;
    R.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

function CnSM2KeyExchangeAStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  APrivateKey: TCnEccPrivateKey; APublicKey, BPublicKey: TCnEccPublicKey; MyRA, InRB: TCnEccPoint;
  MyARand: TCnBigNumber; out OutKeyA: AnsiString; InOptionalSB: TSM3Digest;
  out OutOptionalSA: TSM3Digest; Sm2: TCnSM2): Boolean;
var
  Sm2IsNil: Boolean;
  X, T: TCnBigNumber;
  U: TCnEccPoint;
  Za, Zb: TSM3Digest;
begin
  Result := False;
  if (KeyByteLength <= 0) or (APrivateKey = nil) or (APublicKey = nil) or
    (BPublicKey = nil) or (MyRA = nil) or (InRB = nil) or (MyARand = nil) then
    Exit;

  Sm2IsNil := Sm2 = nil;
  X := nil;
  T := nil;
  U := nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    if not Sm2.IsPointOnCurve(InRB) then // ��֤�������� RB �Ƿ����㷽��
      Exit;

    X := TCnBigNumber.Create;
    BigNumberCopy(X, MyRA.X);
    BuildShortXValue(X, Sm2.Order);     // �� RA ������ X1

    if not BigNumberMul(X, MyARand, X) then
      Exit;
    if not BigNumberAdd(X, X, APrivateKey) then
      Exit;
    T := TCnBigNumber.Create;
    if not BigNumberNonNegativeMod(T, X, Sm2.Order) then // T = (APrivateKey + ���ֵ * X1) mod N
      Exit;

    BigNumberCopy(X, InRB.X);
    BuildShortXValue(X, Sm2.Order);

    // ���� XU YU�� (h * t) * (BPublicKey + X * RB)
    U := TCnEccPoint.Create;
    U.Assign(InRB);
    Sm2.MultiplePoint(X, U);
    Sm2.PointAddPoint(U, BPublicKey, U);
    Sm2.MultiplePoint(T, U);

    if U.X.IsZero or U.Y.IsZero then // ���������Զ����Э��ʧ��
      Exit;

    // Э�̳����ɹ������� KA
    Za := CalcSM2UserHash(AUserID, APublicKey, Sm2);
    Zb := CalcSM2UserHash(BUserID, BPublicKey, Sm2);
    OutKeyA := CalcSM2ExchangeKey(U, Za, Zb, KeyByteLength); // ������ԿЭ�̳ɹ���

    // Ȼ����� SB �˶�
    OutOptionalSA := CalcSM2OptionalSig(U, MyRA, InRB, Za, Zb, True);
    if not CompareMem(@OutOptionalSA[0], @InOptionalSB[0], SizeOf(TSM3Digest)) then
      Exit;

    // Ȼ����� SA �� B �˶�
    OutOptionalSA := CalcSM2OptionalSig(U, MyRA, InRB, Za, Zb, False);
    Result := True;
  finally
    U.Free;
    T.Free;
    X.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

function CnSM2KeyExchangeBStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  BPrivateKey: TCnEccPrivateKey; APublicKey, BPublicKey: TCnEccPublicKey;
  InOptionalSA: TSM3Digest; MyOptionalS2: TSM3Digest; Sm2: TCnSM2): Boolean;
begin
  Result := CompareMem(@InOptionalSA[0], @MyOptionalS2[0], SizeOf(TSM3Digest));
end;

end.

