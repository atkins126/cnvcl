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

unit CnDFT;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����ڸ��㸴������ɢ����Ҷ�任ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��ʹ�ÿ��ٸ���Ҷ�任ʵ����ɢ����Ҷ�任�Լ��ٶ���ʽ�˷����򸡵���ڻ���ʧ����
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.11.23 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Math, CnNativeDecl, CnComplex;

procedure ButterflyChange(CA: PCnComplexArray; Len: Integer);
{* �����任�����������ڲ�Ԫ�ص�˳���Ա���ż����}

function CnFFT(Data: PCnComplexArray; Len: Integer): Boolean;
{* ���ٸ���Ҷ�任��������ʽ��ϵ������ת��Ϊ��ֵ�������飬Ҫȷ�� Len Ϊ 2 ����������}

function CnIFFT(Data: PCnComplexArray; Len: Integer): Boolean;
{* ���ٸ���Ҷ��任������ֵ��������ת��Ϊ����ʽ��ϵ�����飬Ҫȷ�� Len Ϊ 2 ����������}

implementation

const
  Pi = 3.1415926535897932384626;

// �����任�����������ڲ�Ԫ�ص�˳��Ҫȷ�� Len Ϊ 2 ����������
procedure ButterflyChange(CA: PCnComplexArray; Len: Integer);
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

  ButterflyChange(Data, Len);

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

end.
