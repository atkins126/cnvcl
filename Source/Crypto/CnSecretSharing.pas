{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
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

unit CnSecretSharing;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����ܹ�����㷨ʵ�ֵ�Ԫ��Ŀǰ���� Shamir ���޷���
* ��Ԫ���ߣ���Х
* ��    ע��Shamir ���޷��������ù������ʽ���ɶ�������겢���ò�ֵ��ԭ������ܹ�����
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2022.05.24 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils,
  CnConsts, CnNativeDecl, CnPrimeNumber, CnContainers, CnPolynomial, CnRandom,
  CnBigNumber;

const
  CN_SHAMIR_DEFAULT_PRIME_BITS         = 1024;

  // ������
  ECN_SECRET_OK                        = ECN_OK; // û��
  ECN_SECRET_ERROR_BASE                = ECN_CUSTOM_ERROR_BASE + $400; // Secret Sharing �������׼

  ECN_SECRET_INVALID_INPUT             = ECN_SECRET_ERROR_BASE + 1;    // ����Ϊ�ջ򳤶Ȳ���
  ECN_SECRET_RANDOM_ERROR              = ECN_SECRET_ERROR_BASE + 2;    // �������ش���

function CnInt64ShamirSplit(Secret: Int64; ShareCount, Threshold: Integer;
  OutShares: TCnInt64List; var Prime: Int64): Boolean;
{* �� Shamir ���޷���ʵ�� Int64 �����ܹ�����һ Int64 ֵ���Ϊ ShareCount �� Int64 ֵ
  ֻ��Ҫ���� Threshold ��ֵ����˳����ܻ�ԭ Secret�������Ƿ��ֳɹ���
  ���ֵ�� OutShares �У���Ӧ˳��ֵΪ���±� + 1����� 0 ���Ӧ 1��
  ������������� Prime ��ָ������Ϊ 0�������ɷ���Ҫ�������ֵ����}

function CnInt64ShamirReconstruct(Prime: Int64; InOrders, InShares: TCnInt64List;
  out Secret: Int64): Boolean;
{* �� Shamir ���޷���ʵ�� Int64 �����ܹ����� Threshold ����ֺ�� Int64 ֵ�����Ӧ��Ų����
  ����������� Secret�������Ƿ�����ɹ����ɹ�������ֵ�� Secret �з���}

function CnShamirSplit(Secret: TCnBigNumber; ShareCount, Threshold: Integer;
  OutOrders, OutShares: TCnBigNumberList; Prime: TCnBigNumber): Boolean;
{* �� Shamir ���޷���ʵ�ִ�����Χ�ڵ����ܹ�����һ���� Secret ���Ϊ ShareCount ������ֵ
  ֻ��Ҫ���� Threshold ��ֵ����˳����ܻ�ԭ Secret�������Ƿ��ֳɹ���
  ���˳��� InOrders �У��������� 1 2 3 4 �����������ֵ�� OutShares ��
  �� Prime ֵ��Ϊ 0 �Ҵ��� Secret �Ļ��������������б�֤ Prime Ϊ����}

function CnShamirReconstruct(Prime: TCnBigNumber; InOrders, InShares: TCnBigNumberList;
  OutSecret: TCnBigNumber): Boolean;
{* �� Shamir ���޷���ʵ�ִ�����Χ�ڵ����ܹ����� Threshold ����ֺ�Ĵ���ֵ�����Ӧ��Ų����
  ����������� Secret�������Ƿ�����ɹ����ɹ�������ֵ�� Secret �з���}

implementation

function CnInt64ShamirSplit(Secret: Int64; ShareCount, Threshold: Integer;
  OutShares: TCnInt64List; var Prime: Int64): Boolean;
var
  Poly: TCnInt64Polynomial;
  I: Integer;
begin
  Result := False;

  if (Secret < 0) or (ShareCount < 3) or (Threshold < 2) or (ShareCount < Threshold) then
  begin
    _CnSetLastError(ECN_SECRET_INVALID_INPUT);
    Exit;
  end;

  if (Prime <= 0) or (Prime <= Secret) or not CnInt64IsPrime(Prime) then // ������������С������������
  begin
    if Secret < CN_PRIME_NUMBERS_SQRT_UINT32[High(CN_PRIME_NUMBERS_SQRT_UINT32)] then
      Prime := CN_PRIME_NUMBERS_SQRT_UINT32[High(CN_PRIME_NUMBERS_SQRT_UINT32)]
    else
    begin
      // TODO: Ѱ��һ���� Secret �������

    end;
  end;

  Poly := nil;
  try
    Poly := TCnInt64Polynomial.Create;

    Poly.MaxDegree := Threshold - 1;
    Poly[0] := Secret;
    for I := 1 to Poly.MaxDegree do
      Poly[I] := RandomInt64LessThan(Prime);

    // �������������ʽ
    OutShares.Clear;
    for I := 1 to ShareCount do
      OutShares.Add(Int64PolynomialGaloisGetValue(Poly, I, Prime));

    Result := True;
    _CnSetLastError(ECN_SECRET_OK);
  finally
    Poly.Free;
  end;
end;

function CnInt64ShamirReconstruct(Prime: Int64; InOrders, InShares: TCnInt64List;
  out Secret: Int64): Boolean;
var
  I, J: Integer;
  X, Y, N, D: Int64;
begin
  Result := False;
  if (Prime < 2) or (InOrders.Count < 2) or (InOrders.Count <> InShares.Count) then
  begin
    _CnSetLastError(ECN_SECRET_INVALID_INPUT);
    Exit;
  end;

  // �������ղ�ֵ��ʽ��InOrder ��һ�� X ���꣬InShares ��һ�� Y ����
  // �� T �� Shares����Ҫ�ۼ� T �ÿ�����һ�� X Y ���꣬�����¼��㷽����
  // ÿ�� = ��Y * (-�������� X �Ļ�) / (��X - ��������X) �Ļ�)

  Secret := 0;
  for I := 0 to InOrders.Count - 1 do
  begin
    X := InOrders[I];
    Y := InShares[I];

    //  ���˵ķŵ����� N �У������ķŵ���ĸ D ������ģ��Ԫ
    N := Y;
    D := 1;
    for J := 0 to InOrders.Count - 1 do
    begin
      if J <> I then
      begin
        N := Int64NonNegativeMulMod(N, InOrders[J], Prime);
        D := Int64NonNegativeMulMod(D, Int64AddMod(X, -InOrders[J], Prime), Prime);
      end;
    end;
    D := CnInt64ModularInverse2(D, Prime);

    N := Int64NonNegativeMulMod(N, D, Prime);
    Secret := Int64AddMod(Secret, N, Prime);
  end;

  Result := True;
  _CnSetLastError(ECN_SECRET_OK);
end;

function CnShamirSplit(Secret: TCnBigNumber; ShareCount, Threshold: Integer;
  OutOrders, OutShares: TCnBigNumberList; Prime: TCnBigNumber): Boolean;
var
  Poly: TCnBigNumberPolynomial;
  T: TCnBigNumber;
  I, Bits: Integer;
begin
  Result := False;

  if (Secret.IsNegative) or (ShareCount < 3) or (Threshold < 2) or (ShareCount < Threshold) then
  begin
    _CnSetLastError(ECN_SECRET_INVALID_INPUT);
    Exit;
  end;

  if Prime.IsZero or Prime.IsNegative or (BigNumberCompare(Prime, Secret) <= 0) then // ���������С������������
  begin
    // Ѱ��һ���� Secret ����������� Bits Ϊý��
    Bits := Secret.GetBitsCount + 1;
    if Bits < CN_SHAMIR_DEFAULT_PRIME_BITS then
      Bits := CN_SHAMIR_DEFAULT_PRIME_BITS;

    if not BigNumberGeneratePrimeByBitsCount(Prime, Bits) then
      Exit;
  end;

  Poly := nil;
  T := nil;

  try
    Poly := TCnBigNumberPolynomial.Create;

    Poly.MaxDegree := Threshold - 1;
    BigNumberCopy(Poly[0], Secret);
    for I := 1 to Poly.MaxDegree do
    begin
      if not BigNumberRandRange(Poly[I], Prime) then
      begin
        _CnSetLastError(ECN_SECRET_RANDOM_ERROR);
        Exit;
      end;
    end;

    // �������������ʽ���� 1 �� ShareCount ����ֱ���ֵ
    OutOrders.Clear;
    OutShares.Clear;

    T := TCnBigNumber.Create;
    for I := 1 to ShareCount do
    begin
      OutOrders.Add.SetWord(I);
      T.SetWord(I);
      if not BigNumberPolynomialGaloisGetValue(OutShares.Add, Poly, T, Prime) then
        Exit;
    end;

    Result := True;
    _CnSetLastError(ECN_SECRET_OK);
  finally
    T.Free;
    Poly.Free;
  end;
end;

function CnShamirReconstruct(Prime: TCnBigNumber; InOrders, InShares: TCnBigNumberList;
  OutSecret: TCnBigNumber): Boolean;
var
  I, J: Integer;
  X, Y, T, N, D: TCnBigNumber;
begin
  Result := False;
  if Prime.IsNegative or Prime.IsZero or (InOrders.Count < 2) or (InOrders.Count <> InShares.Count) then
  begin
    _CnSetLastError(ECN_SECRET_INVALID_INPUT);
    Exit;
  end;

  // �������ղ�ֵ��ʽ��InOrder ��һ�� X ���꣬InShares ��һ�� Y ����
  // �� T �� Shares����Ҫ�ۼ� T �ÿ�����һ�� X Y ���꣬�����¼��㷽����
  // ÿ�� = ��Y * (-�������� X �Ļ�) / (��X - ��������X) �Ļ�)

  N := nil;
  D := nil;
  T := nil;

  try
    OutSecret.SetZero;

    T := TCnBigNumber.Create;
    N := TCnBigNumber.Create;
    D := TCnBigNumber.Create;

    for I := 0 to InOrders.Count - 1 do
    begin
      X := InOrders[I];
      Y := InShares[I];

      //  ���˵ķŵ����� N �У������ķŵ���ĸ D ������ģ��Ԫ
      if BigNumberCopy(N, Y) = nil then
        Exit;
      D.SetOne;

      for J := 0 to InOrders.Count - 1 do
      begin
        if J <> I then
        begin
          if not BigNumberDirectMulMod(N, N, InOrders[J], Prime) then
            Exit;

          if not BigNumberSubMod(T, X, InOrders[J], Prime) then
            Exit;

          if not BigNumberDirectMulMod(D, D, T, Prime) then
            Exit;
        end;
      end;

      if not BigNumberModularInverse(T, D, Prime) then
        Exit;

      if not BigNumberDirectMulMod(N, T, N, Prime) then
        Exit;

      if not BigNumberAddMod(OutSecret, OutSecret, N, Prime) then
        Exit;
    end;

    Result := True;
    _CnSetLastError(ECN_SECRET_OK);
  finally
    T.Free;
    D.Free;
    N.Free;
  end;
end;

end.
