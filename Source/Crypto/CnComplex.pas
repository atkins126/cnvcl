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

unit CnComplex;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����㸴��ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х
* ��    ע���� record ������ Object��֧�ֿ�ƽ̨
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2023.06.26 V1.1
*               ���ӷ��������ֵ�Ⱥ���
*           2020.11.20 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, SysConst, Math, CnMath;

type
  ECnComplexNumberException = class(Exception);
  {* ������ص��쳣}

  TCnComplexNumber = packed record
  {* ���㾫�ȵĸ�����ʾ�ṹ}
    R: Extended;
    I: Extended;
  end;
  PCnComplexNumber = ^TCnComplexNumber;

  TCnComplexArray = array[0..8191] of TCnComplexNumber;

  PCnComplexArray = ^TCnComplexArray;

function ComplexNumberIsZero(var Complex: TCnComplexNumber): Boolean;
{* ���ظ����Ƿ�Ϊ 0}

procedure ComplexNumberSetZero(var Complex: TCnComplexNumber);
{* ������ 0}

procedure ComplexNumberSetValue(var Complex: TCnComplexNumber;
  AR, AI: Extended); overload;
{* ������ֵ}

procedure ComplexNumberSetValue(var Complex: TCnComplexNumber;
  const AR, AI: string); overload;
{* ������ֵ}

function ComplexNumberToString(var Complex: TCnComplexNumber): string;
{* ����ת��Ϊ�ַ���}

function ComplexNumberEqual(var Complex1, Complex2: TCnComplexNumber): Boolean;
{* �ж����������ṹ�Ƿ����}

procedure ComplexNumberSwap(var Complex1, Complex2: TCnComplexNumber);
{* ������������ֵ}

procedure ComplexNumberCopy(var Dst, Src: TCnComplexNumber);
{* ��������ֵ}

procedure ComplexNumberAdd(var Res: TCnComplexNumber;
  var Complex1, Complex2: TCnComplexNumber); overload;
{* �����ӷ���Complex1 �� Complex2 ������ͬһ���ṹ��Res ������ Complex1 �� Complex2}

procedure ComplexNumberSub(var Res: TCnComplexNumber;
  var Complex1, Complex2: TCnComplexNumber); overload;
{* ����������Complex1 �� Complex2 ������ͬһ���ṹ��Res ������ Complex1 �� Complex2}

procedure ComplexNumberMul(var Res: TCnComplexNumber;
  var Complex1, Complex2: TCnComplexNumber); overload;
{* �����˷���Complex1 �� Complex2 ������ͬһ���ṹ��Res ������ Complex1 �� Complex2}

procedure ComplexNumberDiv(var Res: TCnComplexNumber;
  var Complex1, Complex2: TCnComplexNumber); overload;
{* ����������Complex1 �� Complex2 ������ͬһ���ṹ��Res ������ Complex1 �� Complex2}

procedure ComplexNumberAdd(var Res: TCnComplexNumber;
  var Complex: TCnComplexNumber; Value: Extended); overload;
{* �����븡�����ļӷ���Complex �� Res ������ͬһ���ṹ}

procedure ComplexNumberSub(var Res: TCnComplexNumber;
  var Complex: TCnComplexNumber; Value: Extended); overload;
{* �����븡�����ļ�����Complex �� Res ������ͬһ���ṹ}

procedure ComplexNumberMul(var Res: TCnComplexNumber;
  var Complex: TCnComplexNumber; Value: Extended); overload;
{* �����븡�����ĳ˷���Complex �� Res ������ͬһ���ṹ}

procedure ComplexNumberDiv(var Res: TCnComplexNumber;
  var Complex: TCnComplexNumber; Value: Extended); overload;
{* �����븡�����ĳ�����Complex �� Res ������ͬһ���ṹ}

procedure ComplexConjugate(var Res, Complex: TCnComplexNumber);
{* ��ù������Res ������ Complex}

function ComplexIsPureReal(var Complex: TCnComplexNumber): Boolean;
{* �����Ƿ�ʵ����Ҳ�����ж��鲿�Ƿ�Ϊ 0}

function ComplexIsPureImaginary(var Complex: TCnComplexNumber): Boolean;
{* �����Ƿ�������Ҳ�����ж�ʵ���Ƿ�Ϊ 0 ���鲿��Ϊ 0}

function ComplexNumberAbsolute(var Complex: TCnComplexNumber): Extended;
{* ���ظ����ľ���ֵ��Ҳ���ิƽ��ԭ��ľ���}

function ComplexNumberArgument(var Complex: TCnComplexNumber): Extended;
{* ���ظ����ķ�����ֵ��Ҳ���븴ƽ���� X ��ļнǣ���Χ�� 0 �� 2��}

implementation

function ComplexNumberIsZero(var Complex: TCnComplexNumber): Boolean;
begin
  Result := (Complex.R = 0) and (Complex.I = 0);
end;

procedure ComplexNumberSetZero(var Complex: TCnComplexNumber);
begin
  Complex.R := 0.0;
  Complex.I := 0.0;
end;

procedure ComplexNumberSetValue(var Complex: TCnComplexNumber; AR, AI: Extended);
begin
  Complex.R := AR;
  Complex.I := AI;
end;

procedure ComplexNumberSetValue(var Complex: TCnComplexNumber;
  const AR, AI: string);
begin
  ComplexNumberSetZero(Complex);
  if (AR = '') and (AI = '') then
    Exit
  else if AR = '' then
    Complex.I := StrToFloat(AI)
  else if AI = '' then
    Complex.R := StrToFloat(AR)
  else
    ComplexNumberSetValue(Complex, StrToFloat(AR), StrToFloat(AI));
end;

function ComplexNumberToString(var Complex: TCnComplexNumber): string;
begin
  if ComplexIsPureReal(Complex) then
    Result := Format('%f', [Complex.R])
  else if ComplexIsPureImaginary(Complex) then
    Result := Format('%fi', [Complex.I])
  else if Complex.I < 0 then
    Result := Format('%f%fi', [Complex.R, Complex.I])
  else
    Result := Format('%f+%fi', [Complex.R, Complex.I]);
end;

function ComplexNumberEqual(var Complex1, Complex2: TCnComplexNumber): Boolean;
begin
  Result := FloatEqual(Complex1.R, Complex2.R) and FloatEqual(Complex1.I, Complex2.I);
end;

procedure ComplexNumberSwap(var Complex1, Complex2: TCnComplexNumber);
var
  T: Extended;
begin
  T := Complex1.R;
  Complex1.R := Complex2.R;
  Complex2.R := T;

  T := Complex1.I;
  Complex1.I := Complex2.I;
  Complex2.I := T;
end;

procedure ComplexNumberCopy(var Dst, Src: TCnComplexNumber);
begin
  Dst.R := Src.R;
  Dst.I := Src.I;
end;

procedure ComplexNumberAdd(var Res: TCnComplexNumber;
  var Complex1, Complex2: TCnComplexNumber);
begin
  Res.R := Complex1.R + Complex2.R;
  Res.I := Complex1.I + Complex2.I;
end;

procedure ComplexNumberSub(var Res: TCnComplexNumber;
  var Complex1, Complex2: TCnComplexNumber);
begin
  Res.R := Complex1.R - Complex2.R;
  Res.I := Complex1.I - Complex2.I;
end;

procedure ComplexNumberMul(var Res: TCnComplexNumber;
  var Complex1, Complex2: TCnComplexNumber);
var
  T: Extended;
begin
  T := Complex1.R * Complex2.R - Complex1.I * Complex2.I;
  Res.I := Complex1.R * Complex2.I + Complex1.I * Complex2.R;
  Res.R := T;
end;

procedure ComplexNumberDiv(var Res: TCnComplexNumber;
  var Complex1, Complex2: TCnComplexNumber);
var
  T, D: Extended;
begin
  D := Complex2.R * Complex2.R + Complex2.I * Complex2.I;
  if FloatEqual(D, 0.0) then
    raise EZeroDivide.Create(SZeroDivide);

  T := (Complex1.R * Complex2.R + Complex1.I * Complex2.I) / D;
  Res.I := (Complex1.I * Complex2.R - Complex1.R * Complex2.I) / D;
  Res.R := T;
end;

procedure ComplexNumberAdd(var Res: TCnComplexNumber;
  var Complex: TCnComplexNumber; Value: Extended); overload;
begin
  Res.R := Complex.R + Value;
  Res.I := Complex.I;
end;

procedure ComplexNumberSub(var Res: TCnComplexNumber;
  var Complex: TCnComplexNumber; Value: Extended); overload;
begin
  Res.R := Complex.R - Value;
  Res.I := Complex.I;
end;

procedure ComplexNumberMul(var Res: TCnComplexNumber;
  var Complex: TCnComplexNumber; Value: Extended); overload;
begin
  Res.R := Complex.R * Value;
  Res.I := Complex.I;
end;

procedure ComplexNumberDiv(var Res: TCnComplexNumber;
  var Complex: TCnComplexNumber; Value: Extended); overload;
begin
  Res.R := Complex.R / Value;
  Res.I := Complex.I;
end;

procedure ComplexConjugate(var Res, Complex: TCnComplexNumber);
begin
  Res.R := Complex.R;
  Res.I := -Complex.I;
end;

function ComplexIsPureReal(var Complex: TCnComplexNumber): Boolean;
begin
  Result := FloatEqual(Complex.I, 0.0);
end;

function ComplexIsPureImaginary(var Complex: TCnComplexNumber): Boolean;
begin
  Result := FloatEqual(Complex.R, 0.0) and not FloatEqual(Complex.I, 0.0);
end;

function ComplexNumberAbsolute(var Complex: TCnComplexNumber): Extended;
begin
  Result := Sqrt(Complex.R * Complex.R + Complex.I * Complex.I);
end;

function ComplexNumberArgument(var Complex: TCnComplexNumber): Extended;
begin
  if Complex.I = 0 then
  begin
    if Complex.R >= 0 then // ��ʵ�����Ƿ��� 0������ 0 Ҳ�պ��ŷ��� 0
      Result := 0
    else
      Result := Pi;     // ��ʵ�����Ƿ��� ��
  end
  else if Complex.R = 0 then
  begin
    if Complex.I > 0 then      // �����������Ƿ��ذ� ��
      Result := Pi / 2
    else
      Result := Pi + Pi / 2;   // �����������Ƿ��� 3��/2
  end
  else // ʵ���鲿����Ϊ 0
  begin
    Result := ArcTan2(Complex.I, Complex.R);
    if Result < 0 then
      Result := Result + Pi * 2;
  end;
end;

end.
