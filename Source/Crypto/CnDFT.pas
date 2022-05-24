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

unit CnDFT;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����ڸ��㸴������ɢ����Ҷ�任�Լ����� Int 64 �Ŀ������۱任ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��ʹ�ÿ��ٸ���Ҷ�任ʵ����ɢ����Ҷ�任�Լ��ٶ���ʽ�˷����򸡵���ڻ���ʧ����
*           ʹ�ÿ������۱任��û������⡣���������۱任Ҳ�����ƣ�
*           1������ʽϵ������Ϊ������С��ģ��������ϵ������֪��զ�㣩��
*           2������ʽ����С�� 2^23������Ԫģ�����ƣ�
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2021.08.29 V1.1
*               ���ӿ������۱任��ʹ���ض�����
*           2020.11.23 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNativeDecl, CnComplex;

procedure ButterflyChangeComplex(CA: PCnComplexArray; Len: Integer);
{* �����任���������������ڲ�Ԫ�ص�˳���Ա���ż����}

procedure ButterflyChangeInt64(IA: PInt64Array; Len: Integer);
{* �����任������ int64 �����ڲ�Ԫ�ص�˳���Ա���ż����}

function CnFFT(Data: PCnComplexArray; Len: Integer): Boolean;
{* ���ٸ���Ҷ�任��������ʽ��ϵ����������ת��Ϊ��ֵ�����������飬Ҫȷ�� Len Ϊ 2 ����������}

function CnIFFT(Data: PCnComplexArray; Len: Integer): Boolean;
{* ���ٸ���Ҷ��任������ֵ������������ת��Ϊ����ʽ��ϵ���������飬Ҫȷ�� Len Ϊ 2 ����������}

function CnNTT(Data: PInt64Array; Len: Integer): Boolean;
{* �������۱任��������ʽ��ϵ�� int 64 ����ת��Ϊ��ֵ���� int64 ���飬
  ע��Ҫȷ�� Len Ϊ 2 ���������ݣ����� Data ��ϵ��������� 0 ��С�� CN_P}

function CnINTT(Data: PInt64Array; Len: Integer): Boolean;
{* ����������任������ֵ���� int 64 ����ת��Ϊ����ʽ��ϵ�� int 64 ���飬
  ע��Ҫȷ�� Len Ϊ 2 ���������ݣ����� Data ��ϵ��������� 0 ��С�� CN_P}

implementation

uses
  CnPrimeNumber;

const
  Pi = 3.1415926535897932384626;

  CN_NR = 1 shl 22;     // 2 �� 23 �η���һ�룬���ֻ�ܴ������Ϊ CN_NR �Ķ���ʽ
  CN_G = 3;             // ����������ԭ���� 3
  CN_G_INV = 332748118; // ��ԭ���Ը���������ԪΪ 332748118
  CN_P = 998244353;     // ѡȡ����Ϊ 998244353 = 2^23*119 + 1��С�� Int32 �����ֵ 2147483647

// �����任�����������ڲ�Ԫ�ص�˳��Ҫȷ�� Len Ϊ 2 ����������
procedure ButterflyChangeComplex(CA: PCnComplexArray; Len: Integer);
var
  I: Integer;
  R: array of Integer;
begin
  if Len <= 1 then
    Exit;

  SetLength(R, Len);
  for I := 0 to Len - 1 do
  begin
    R[I] := R[I shr 1] shr 1;
    if (I and 1) <> 0 then
      R[I] := R[I] or (Len shr 1);
  end;

  for I := 0 to Len - 1 do
  begin
    if I < R[I] then
      ComplexNumberSwap(CA^[I], CA^[R[I]]);
  end;
  SetLength(R, 0);
end;

// �����任�����������ڲ�Ԫ�ص�˳��Ҫȷ�� Len Ϊ 2 ����������
procedure ButterflyChangeInt64(IA: PInt64Array; Len: Integer);
var
  I: Integer;
  R: array of Integer;
  T: Int64;
begin
  if Len <= 1 then
    Exit;

  SetLength(R, Len);
  for I := 0 to Len - 1 do
  begin
    R[I] := R[I shr 1] shr 1;
    if (I and 1) <> 0 then
      R[I] := R[I] or (Len shr 1);
  end;

  for I := 0 to Len - 1 do
  begin
    if I < R[I] then
    begin
      T := IA^[I];
      IA^[I] := IA^[R[I]];
      IA^[R[I]] := T;
    end;
  end;
  SetLength(R, 0);
end;

// �����ǵݹ鷽ʽʵ�ֵĿ��ٸ���Ҷ�任������任
function FFT(Data: PCnComplexArray; Len: Integer; IsReverse: Boolean): Boolean;
var
  J, T, M, R, K: Integer;
  WN, W, X, Y: TCnComplexNumber;
begin
  Result := False;
  if (Data = nil) or (Len <= 0) then
    Exit;

  // Len ���� 2 ����������
  if not IsUInt32PowerOf2(Cardinal(Len)) then
    Exit;

  if IsReverse then
    T := -1
  else
    T := 1;

  ButterflyChangeComplex(Data, Len);

  M := 1;
  while M < Len do
  begin
    WN.R := Cos(Pi / M);
    WN.I := Sin(Pi / M) * T;

    J := 0;
    R := M shl 1;
    while J < Len do
    begin
      W.R := 1.0;
      W.I := 0;

      K := 0;
      while K < M do
      begin
        ComplexNumberCopy(X, Data^[J + K]);
        ComplexNumberMul(Y, Data^[J + K + M], W);

        ComplexNumberAdd(Data^[J + K], X, Y);
        ComplexNumberSub(Data^[J + K + M], X, Y);

        ComplexNumberMul(W, W, WN);
        Inc(K);
      end;

      J := J + R;
    end;

    M := M shl 1;
  end;

  if IsReverse then
    for J := 0 to Len - 1 do
      ComplexNumberDiv(Data^[J], Data^[J], Len);

  Result := True;
end;

function CnFFT(Data: PCnComplexArray; Len: Integer): Boolean;
begin
  Result := FFT(Data, Len, False);
end;

function CnIFFT(Data: PCnComplexArray; Len: Integer): Boolean;
begin
  Result := FFT(Data, Len, True);
end;

// �����ǵݹ鷽ʽʵ�ֵĿ������۱任������任
function NTT(Data: PInt64Array; Len: Integer; IsReverse: Boolean): Boolean;
var
  M, K, J, R: Integer;
  G0, GN, X, Y: Int64;
begin
  Result := False;
  if (Data = nil) or (Len <= 0) or (Len > CN_NR) then
    Exit;

  // Len ���� 2 ����������
  if not IsUInt32PowerOf2(Cardinal(Len)) then
    Exit;

  ButterflyChangeInt64(Data, Len);

  M := 1;
  while M < Len do
  begin
    // MontgomeryPowerMod ��Ѹ��� Int64 ��Ϊ�����޷��� UInt64���������ϵ����Ϊ��������ʹ��
    if IsReverse then
      GN := MontgomeryPowerMod(CN_G_INV, (CN_P - 1) div (M shl 1), CN_P)
    else
      GN := MontgomeryPowerMod(CN_G, (CN_P - 1) div (M shl 1) , CN_P);

    J := 0;
    R := M shl 1;
    while J < Len do
    begin
      G0 := 1;
      K := 0;

      while K < M do
      begin
        X := Data^[J + K];
        Y := Int64MultipleMod(G0, Data^[J + K + M], CN_P);
        Data^[J + K] := Int64AddMod(X, Y, CN_P);

        X := X - Y;
        if X < 0 then
          X := X + CN_P; // X - Y �����Ǹ����������� AddMod
        Data^[J + K + M] := X mod CN_P;

        G0 := Int64MultipleMod(G0, GN, CN_P);
        Inc(K);
      end;

      J := J + R;
    end;

    M := M shl 1;
  end;

  if IsReverse then
    for J := 0 to Len - 1 do
      Data^[J] := Data^[J] div Len;

  Result := True;
end;

function CnNTT(Data: PInt64Array; Len: Integer): Boolean;
begin
  Result := NTT(Data, Len, False);
end;

function CnINTT(Data: PInt64Array; Len: Integer): Boolean;
begin
  Result := NTT(Data, Len, True);
end;

end.
