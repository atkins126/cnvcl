{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2023 CnPack ������                       }
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

unit CnMath;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ���ѧ������㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��ּ������ Math �⣬�Ȳ�̫������Ч��
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2021.12.08 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes;

{
  ������������
                  A1
  B0 +  ----------------------
                     A2
        B1 + -----------------
                       A3
             B2 + ------------
                            An
                  B4 + ... ---
                            Bn
}
// function Int64ContinuedFraction

function Int64Sqrt(N: Int64): Extended;
{* ���� Int64 ��ƽ������ʹ��ţ�ٵ��� Xn+1 = (Xn + N/Xn)/2}

function FloatSqrt(F: Extended): Extended;
{* ������չ���ȸ�������ƽ������ʹ��ţ�ٵ��� Xn+1 = (Xn + N/Xn)/2}

function Int64LogN(N: Int64): Extended;
{* ���� Int64 ����Ȼ������ʹ�÷�˫������չ��}

function FloatLogN(F: Extended): Extended;
{* ������չ���ȸ���������Ȼ������ʹ�÷�˫������չ��}

function Int64Log10(N: Int64): Extended;
{* ���� Int64 �ĳ��ö�����ֱ��ʹ����Ȼ��������}

function FloatLog10(F: Extended): Extended;
{* ������չ���ȸ������ĳ��ö�����ֱ��ʹ����Ȼ��������}

function Int64Log2(N: Int64): Extended;
{* ���� Int64 �� 2 Ϊ�׵Ķ�����ֱ��ʹ����Ȼ��������}

function FloatLog2(F: Extended): Extended;
{* ������չ���ȸ������� 2 Ϊ�׵Ķ�����ֱ��ʹ����Ȼ��������}

function FloatGaussLegendrePi(RoundCount: Integer = 3): string;
{* ��չ���ȷ�Χ���ø�˹���õ¹�ʽ���� Pi��3 �ֱ��ѵִ���չ���ȼ���}

function GaussLegendrePi(RoundCount: Integer = 8): string;
{* �󸡵����ø�˹���õ¹�ʽ���� Pi��8 �ε������Ⱦ͵��� 100 ��λ��12 �ֺ�ʱ 5 ��}

function XavierGourdonEuler(BlockSize: Integer = 1000): string;
{* �� Xavier Gourdon ������ŷ������ e ��ֵ������Ϊ��������}

function FloatAlmostZero(F: Extended): Boolean;
{* �ж�һ�������Ƿ��� 0 �㹻��}

implementation

uses
  CnBigDecimal;

const
  SCN_EXTEND_GAP = 0.00000000001;
  SCN_LOGN_TO_LOG2 = 1.4426950408889634073599246810019;
  SCN_LOGN_TO_LOG10 = 0.43429448190325182765112891891661;

resourcestring
  SCN_SQRT_RANGE_ERROR = 'Sqrt Range Error.';
  SCN_LOG_RANGE_ERROR = 'Log Range Error.';

function CnAbs(F: Extended): Extended;
begin
  if F < 0 then
    Result := -F
  else
    Result := F;
end;

{$HINTS OFF}

function Int64Sqrt(N: Int64): Extended;
var
  X0: Extended;
begin
  if N < 0 then
    raise ERangeError.Create(SCN_SQRT_RANGE_ERROR);

  Result := 0;
  if (N = 0) or (N = 1) then
  begin
    Result := N;
    Exit;
  end;

  X0 := N;
  while True do
  begin
    Result := (X0 + N/X0) / 2;

    if CnAbs(Result - X0) < SCN_EXTEND_GAP then
      Break;
    X0 := Result;
  end;
end;

function FloatSqrt(F: Extended): Extended;
var
  X0: Extended;
begin
  if F < 0 then
    raise ERangeError.Create(SCN_SQRT_RANGE_ERROR);

  Result := 0;
  if (F = 0) or (F = 1) then
  begin
    Result := F;
    Exit;
  end;

  X0 := F;
  while True do
  begin
    Result := (X0 + F/X0) / 2;

    if CnAbs(Result - X0) < SCN_EXTEND_GAP then
      Break;
    X0 := Result;
  end;
end;

{$HINTS ON}

function Int64LogN(N: Int64): Extended;
var
  I: Integer;
  F: Extended;
  Z, D: Extended;
begin
  if N <= 0 then
    raise ERangeError.Create(SCN_LOG_RANGE_ERROR);

  Result := 0;
  if N = 1 then
    Exit;

  //           [ z-1   1 (z-1)^3   1 (z-1)^5        ]
  // lnz = 2 * | --- + - ------- + - ------- + .... |
  //           [ z+1   3 (z+1)^3   5 (z+1)^5        ]

  F := N;
  Z := (F - 1) / (F + 1);
  D := Z;
  Z := Z * Z;
  I := 1;

  while True do
  begin
    Result := Result + D / I;
    Inc(I, 2);
    D := D * Z;

    if CnAbs(D) < SCN_EXTEND_GAP then
      Break;
  end;
  Result := Result * 2;
end;

function FloatLogN(F: Extended): Extended;
var
  I: Integer;
  Z, D: Extended;
begin
  if F <= 0 then
    raise ERangeError.Create(SCN_LOG_RANGE_ERROR);

  Result := 0;
  if F = 1 then
    Exit;

  //           [ z-1   1 (z-1)^3   1 (z-1)^5        ]
  // lnz = 2 * | --- + - ------- + - ------- + .... |
  //           [ z+1   3 (z+1)^3   5 (z+1)^5        ]

  Z := (F - 1) / (F + 1);
  D := Z;
  Z := Z * Z;
  I := 1;

  while True do
  begin
    Result := Result + D / I;
    Inc(I, 2);
    D := D * Z;

    if CnAbs(D) < SCN_EXTEND_GAP then
      Break;
  end;
  Result := Result * 2;
end;

function Int64Log10(N: Int64): Extended;
begin
  Result := Int64LogN(N) * SCN_LOGN_TO_LOG10;
end;

function FloatLog10(F: Extended): Extended;
begin
  Result := FloatLogN(F) * SCN_LOGN_TO_LOG10;
end;

function Int64Log2(N: Int64): Extended;
begin
  Result := Int64LogN(N) * SCN_LOGN_TO_LOG2;
end;

function FloatLog2(F: Extended): Extended;
begin
  Result := FloatLogN(F) * SCN_LOGN_TO_LOG2;
end;

function FloatGaussLegendrePi(RoundCount: Integer): string;
var
  I: Integer;
  A0, B0, T0, P0: Extended;
  A1, B1, T1, P1: Extended;
  Res: Extended;
begin
  A0 := 1;
  B0 := Sqrt(2) / 2;
  T0 := 0.25;
  P0 := 1;
  Res := 0;

  for I := 1 to RoundCount do
  begin
    A1 := (A0 + B0) / 2;
    B1 := Sqrt(A0 * B0);
    T1 := T0 - P0 * (A0 - A1) * (A0 - A1);
    P1 := P0 * 2;

    Res := (A1 + B1) * (A1 + B1) / (T1 * 4);

    A0 := A1;
    B0 := B1;
    T0 := T1;
    P0 := P1;
  end;

  Result := FloatToStr(Res);
end;

function GaussLegendrePi(RoundCount: Integer): string;
var
  I, P: Integer;
  A0, B0, T0, P0: TCnBigDecimal;
  A1, B1, T1, P1: TCnBigDecimal;
  X1, X2: TCnBigDecimal;
  Res: TCnBigDecimal;
begin
  A0 := nil;
  B0 := nil;
  T0 := nil;
  P0 := nil;

  A1 := nil;
  B1 := nil;
  T1 := nil;
  P1 := nil;

  Res := nil;
  X1 := nil;
  X2 := nil;

  try
    A0 := TCnBigDecimal.Create;
    B0 := TCnBigDecimal.Create;
    T0 := TCnBigDecimal.Create;
    P0 := TCnBigDecimal.Create;

    A1 := TCnBigDecimal.Create;
    B1 := TCnBigDecimal.Create;
    T1 := TCnBigDecimal.Create;
    P1 := TCnBigDecimal.Create;

    Res := TCnBigDecimal.Create;

    // ��ʱ����
    X1 := TCnBigDecimal.Create;
    X1.SetWord(2);
    X2 := TCnBigDecimal.Create;

    P := 1 shl RoundCount;  // ���� Round ������ǰȷ������
    if P < 16 then
      P := 16;

    A0.SetOne;
    B0.SetWord(2);
    BigDecimalSqrt(B0, B0, P);
    BigDecimalDiv(B0, B0, X1, P);
    T0.SetExtended(0.25);
    P0.SetOne;

    Res.SetZero;
    for I := 1 to RoundCount do
    begin
      // A1 := (A0 + B0) / 2;
      BigDecimalAdd(A1, A0, B0);
      BigDecimalDiv(A1, A1, X1, P);

      // B1 := Sqrt(A0 * B0);
      BigDecimalMul(B1, A0, B0);
      BigDecimalSqrt(B1, B1, P);

      // T1 := T0 - P0 * (A0 - A1) * (A0 - A1);
      BigDecimalSub(T1, A0, A1);
      BigDecimalMul(T1, T1, T1);
      BigDecimalMul(T1, T1, P0);
      BigDecimalSub(T1, T0, T1);

      // P1 := P0 * 2;
      BigDecimalAdd(P1, P0, P0);

      // Res := (A1 + B1) * (A1 + B1) / (T1 * 4);
      BigDecimalAdd(Res, A1, B1);
      BigDecimalMul(Res, Res, Res);
      BigDecimalAdd(X2, T1, T1);
      BigDecimalAdd(X2, X2, X2);

      BigDecimalDiv(Res, Res, X2, P);

      // ׼����һ�ֵ���
      BigDecimalCopy(A0, A1);
      BigDecimalCopy(B0, B1);
      BigDecimalCopy(T0, T1);
      BigDecimalCopy(P0, P1);
    end;

    Result := Res.ToString;
  finally
    X1.Free;
    X2.Free;

    Res.Free;

    A1.Free;
    B1.Free;
    T1.Free;
    P1.Free;

    A0.Free;
    B0.Free;
    T0.Free;
    P0.Free;
  end;
end;

function XavierGourdonEuler(BlockSize: Integer = 1000): string;
var
  N, M, X: Integer;
  A: array of Integer;
begin
  if BlockSize <= 0 then
    Exit;

  SetLength(A, BlockSize);
  N := BlockSize;
  M := BlockSize;
  Dec(N);
  A[0] := 0;
  while N <> 0 do
  begin
    A[N] := 1;
    Dec(N);
  end;
  A[1] := 2;
  X := 65536; // X ��Ȼ����Ǽ�����û��ʼ��ò�ƶ��У�

  while M > 9 do
  begin
    N := M;
    Dec(M);
    Dec(N);
    while N <> 0 do
    begin
      A[N] := X mod N;
      X := 10 * A[N - 1] + X div N;
      Dec(N);
    end;

    Result := Result + IntToStr(X);
  end;

  if Length(Result) > 2 then
    Insert('.', Result, 2);
end;

function FloatAlmostZero(F: Extended): Boolean;
begin
  Result := CnAbs(F) < SCN_EXTEND_GAP;
end;

end.
