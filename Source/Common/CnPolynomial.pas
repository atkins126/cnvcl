{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
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

unit CnPolynomial;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�����ʽ����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org��
* ��    ע��֧����ͨ����ϵ������ʽ�������㣬����ֻ֧�ֳ�����ߴ���Ϊ 1 �����
*           ֧����������Χ�ڵĶ���ʽ�������㣬ϵ���� mod p ���ҽ���Ա�ԭ����ʽ����
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.08.28 V1.1
*               ʵ�����������жԱ�ԭ����ʽ�����ģ��Ԫ
*           2020.08.21 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, SysConst, Math, Contnrs, CnPrimeNumber, CnNativeDecl;

type
  ECnPolynomialException = class(Exception);

  TCnInt64Polynomial = class(TCnInt64List)
  {* ��ϵ������ʽ��ϵ����ΧΪ Int64}
  private
    function GetMaxDegree: Integer;
    procedure SetMaxDegree(const Value: Integer);
  public
    constructor Create(LowToHighCoefficients: array of const); overload;
    constructor Create; overload;
    destructor Destroy; override;

    procedure SetCoefficents(LowToHighCoefficients: array of const);
    {* һ���������ôӵ͵��ߵ�ϵ��}
    procedure CorrectTop;
    {* �޳��ߴε� 0 ϵ��}
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ʽת���ַ���}
    function IsZero: Boolean;
    {* �����Ƿ�Ϊ 0}
    procedure SetZero;
    {* ��Ϊ 0}
    function IsOne: Boolean;
    {* �����Ƿ�Ϊ 1}
    procedure SetOne;
    {* ��Ϊ 1}
    property MaxDegree: Integer read GetMaxDegree write SetMaxDegree;
    {* ��ߴ�����0 ��ʼ}
  end;

  TCnInt64PolynomialPool = class(TObjectList)
  {* ��ϵ������ʽ��ʵ���࣬����ʹ�õ������ĵط����д���������}
  private
{$IFDEF MULTI_THREAD}
  {$IFDEF MSWINDOWS}
    FCriticalSection: TRTLCriticalSection;
  {$ELSE}
    FCriticalSection: TCriticalSection;
  {$ENDIF}
{$ENDIF}
    procedure Enter; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    procedure Leave; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    function Obtain: TCnInt64Polynomial;
    procedure Recycle(Poly: TCnInt64Polynomial);
  end;

function Int64PolynomialNew: TCnInt64Polynomial;
{* ����һ����̬�������ϵ������ʽ���󣬵�ͬ�� TCnInt64Polynomial.Create}

procedure Int64PolynomialFree(const P: TCnInt64Polynomial);
{* �ͷ�һ����ϵ������ʽ���󣬵�ͬ�� TCnInt64Polynomial.Free}

function Int64PolynomialDuplicate(const P: TCnInt64Polynomial): TCnInt64Polynomial;
{* ��һ����ϵ������ʽ�����¡һ���¶���}

function Int64PolynomialCopy(const Dst: TCnInt64Polynomial;
  const Src: TCnInt64Polynomial): TCnInt64Polynomial;
{* ����һ����ϵ������ʽ���󣬳ɹ����� Dst}

function Int64PolynomialToString(const P: TCnInt64Polynomial;
  const VarName: string = 'X'): string;
{* ��һ����ϵ������ʽ����ת���ַ�����δ֪��Ĭ���� X ��ʾ}

function Int64PolynomialIsZero(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ����ϵ������ʽ�����Ƿ�Ϊ 0}

procedure Int64PolynomialSetZero(const P: TCnInt64Polynomial);
{* ��һ����ϵ������ʽ������Ϊ 0}

function Int64PolynomialIsOne(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ����ϵ������ʽ�����Ƿ�Ϊ 1}

procedure Int64PolynomialSetOne(const P: TCnInt64Polynomial);
{* ��һ����ϵ������ʽ������Ϊ 1}

procedure Int64PolynomialNegate(const P: TCnInt64Polynomial);
{* ��һ����ϵ������ʽ��������ϵ����}

procedure Int64PolynomialShiftLeft(const P: TCnInt64Polynomial; N: Integer);
{* ��һ����ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N}

procedure Int64PolynomialShiftRight(const P: TCnInt64Polynomial; N: Integer);
{* ��һ����ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N��С�� 0 �ĺ�����}

function Int64PolynomialEqual(const A, B: TCnInt64Polynomial): Boolean;
{* �ж�����ϵ������ʽÿ��ϵ���Ƿ��Ӧ��ȣ����򷵻� True}

// =========================== ����ʽ��ͨ���� ==================================

procedure Int64PolynomialAddWord(const P: TCnInt64Polynomial; N: Integer);
{* ��һ����ϵ������ʽ����ĳ�ϵ������ N}

procedure Int64PolynomialSubWord(const P: TCnInt64Polynomial; N: Integer);
{* ��һ����ϵ������ʽ����ĳ�ϵ����ȥ N}

procedure Int64PolynomialMulWord(const P: TCnInt64Polynomial; N: Integer);
{* ��һ����ϵ������ʽ����ĸ���ϵ�������� N}

procedure Int64PolynomialDivWord(const P: TCnInt64Polynomial; N: Integer);
{* ��һ����ϵ������ʽ����ĸ���ϵ�������� N���粻��������ȡ��}

procedure Int64PolynomialNonNegativeModWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ����ϵ������ʽ����ĸ���ϵ������ N �Ǹ�����}

function Int64PolynomialAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ������ӣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ���������������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialDiv(const Res: TCnInt64Polynomial; const Remain: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; const Divisor: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ����������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ���׳��쳣���޷�֧�֣�
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function Int64PolynomialMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ�������࣬�������� Res �У����������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ���׳��쳣���޷�֧�֣�
   Res ������ P �� Divisor��P ������ Divisor}

function Int64PolynomialPower(const Res: TCnInt64Polynomial;
  const P: TCnInt64Polynomial;  Exponent: LongWord): Boolean;
{* ������ϵ������ʽ�� Exponent ���ݣ�������ϵ����������⣬
   ���ؼ����Ƿ�ɹ���Res ������ P}

function Int64PolynomialReduce(const P: TCnInt64Polynomial): Integer;
{* �������ʽϵ����Ҳ�����Ҷ���ʽϵ�������Լ��������ϵ�����������������Լ��}

function Int64PolynomialGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
{* ����������ϵ������ʽ�������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��}

function Int64PolynomialCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial): Boolean;
{* ��ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function Int64PolynomialCalcDivisionPolynomial(A, B: Integer; Degree: Integer;
  outDivisionPolynomial: TCnInt64Polynomial): Boolean;
{* �ݹ����ɳ�����ʽ�������Ƿ����ɹ���ע�� Integer ��Χ�ڴ���һ����������
   ����ο��� F. MORAIN ������
  ��COMPUTING THE CARDINALITY OF CM ELLIPTIC CURVES USING TORSION POINTS��}

// ===================== ���������µ���ϵ������ʽģ���� ========================

function Int64PolynomialGaloisAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η�������������ˣ�������� Res �У�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisDiv(const Res: TCnInt64Polynomial;
  const Remain: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η�����������������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function Int64PolynomialGaloisMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η��������������࣬�������� Res �У����������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res ������ P �� Divisor��P ������ Divisor}

function Int64PolynomialGaloisPower(const Res, P: TCnInt64Polynomial;
  Exponent: LongWord; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ�� Prime �η����������ϵ� Exponent ���ݣ�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ���ؼ����Ƿ�ɹ���Res ������ P}

function Int64PolynomialGaloisAddWord(const P: TCnInt64Polynomial; N: Integer; Prime: Int64): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ�ĳ�ϵ������ N �� mod Prime}

function Int64PolynomialGaloisSubWord(const P: TCnInt64Polynomial; N: Integer; Prime: Int64): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ�ĳ�ϵ����ȥ N �� mod Prime}

function Int64PolynomialGaloisMulWord(const P: TCnInt64Polynomial; N: Integer; Prime: Int64): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ������ N �� mod Prime}

function Int64PolynomialGaloisDivWord(const P: TCnInt64Polynomial; N: Integer; Prime: Int64): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ������ N��Ҳ���ǳ��� N ����Ԫ�� mod Prime}

function Int64PolynomialGaloisMonic(const P: TCnInt64Polynomial; Prime: Int64): Integer;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ��ͬ������ʹ����Ϊһ�����س���ֵ}

function Int64PolynomialGaloisGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
{* ����������ϵ������ʽ�� Prime �η����������ϵ������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

procedure Int64PolynomialGaloisExtendedEuclideanGcd(A, B: TCnInt64Polynomial;
  X, Y: TCnInt64Polynomial; Prime: Int64);
{* ��չŷ�����շת������� Prime �η��������������Ԫһ�β�����ϵ������ʽ���� A * X - B * Y = 1 �Ľ�}

procedure Int64PolynomialGaloisModularInverse(const Res: TCnInt64Polynomial;
  X, Modulus: TCnInt64Polynomial; Prime: Int64);
{* ����ϵ������ʽ X �� Prime �η�������������� Modulus ��ģ������ʽ���ģ��Ԫ����ʽ Y��
   ���� (X * Y) mod M = 1�������������б�֤ X��Modulus ���أ��� Res ����Ϊ X �� Modulus}

function Int64PolynomialGaloisCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial; Prime: Int64): Boolean;
{* �� Prime �η����������Ͻ�����ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function Int64PolynomialGaloisCalcDivisionPolynomial(A, B: Integer; Degree: Integer;
  outDivisionPolynomial: TCnInt64Polynomial; Prime: Int64): Boolean;
{* �ݹ������ Prime �η����������ϵ� N �׿ɳ�����ʽ�������Ƿ����ɹ�
   ����ο��� F. MORAIN ������
  ��COMPUTING THE CARDINALITY OF CM ELLIPTIC CURVES USING TORSION POINTS��}

implementation

resourcestring
  SCnInvalidDegree = 'Invalid Degree %d';
  SCnErrorDivExactly = 'Can NOT Divide Exactly for Integer Polynomial.';

var
  FLocalInt64PolynomialPool: TCnInt64PolynomialPool = nil;

// ��װ�ķǸ����ຯ����Ҳ��������Ϊ��ʱ���Ӹ������������������豣֤ P ���� 0
function NonNegativeMod(N: Int64; P: Int64): Int64;
begin
  if P <= 0 then
    raise ECnPolynomialException.Create('Can NOT Mod a Negative Prime.');

  Result := N mod P;
  if N < 0 then
    Inc(Result, P);
end;

{ TCnInt64Polynomial }

procedure TCnInt64Polynomial.CorrectTop;
begin
  while (MaxDegree > 0) and (Items[MaxDegree] = 0) do
    Delete(MaxDegree);
end;

constructor TCnInt64Polynomial.Create;
begin
  inherited;
  Add(0);   // ��ϵ����
end;

constructor TCnInt64Polynomial.Create(LowToHighCoefficients: array of const);
begin
  inherited Create;
  SetCoefficents(LowToHighCoefficients);
end;

destructor TCnInt64Polynomial.Destroy;
begin

  inherited;
end;

function TCnInt64Polynomial.GetMaxDegree: Integer;
begin
  if Count = 0 then
    Add(0);
  Result := Count - 1;
end;

function TCnInt64Polynomial.IsOne: Boolean;
begin
  Result := Int64PolynomialIsOne(Self);
end;

function TCnInt64Polynomial.IsZero: Boolean;
begin
  Result := Int64PolynomialIsZero(Self);
end;

procedure TCnInt64Polynomial.SetCoefficents(LowToHighCoefficients: array of const);
var
  I: Integer;
begin
  Clear;
  for I := Low(LowToHighCoefficients) to High(LowToHighCoefficients) do
  begin
    case LowToHighCoefficients[I].VType of
    vtInteger:
      begin
        Add(LowToHighCoefficients[I].VInteger);
      end;
    vtInt64:
      begin
        Add(LowToHighCoefficients[I].VInt64^);
      end;
    vtBoolean:
      begin
        if LowToHighCoefficients[I].VBoolean then
          Add(1)
        else
          Add(0);
      end;
    vtString:
      begin
        Add(StrToInt(LowToHighCoefficients[I].VString^));
      end;
    else
      raise ECnPolynomialException.CreateFmt(SInvalidInteger, ['Coefficients ' + IntToStr(I)]);
    end;
  end;

  if Count = 0 then
    Add(0)
  else
    CorrectTop;
end;

procedure TCnInt64Polynomial.SetMaxDegree(const Value: Integer);
begin
  if Value < 0 then
    raise ECnPolynomialException.CreateFmt(SCnInvalidDegree, [Value]);
  Count := Value + 1;
end;

procedure TCnInt64Polynomial.SetOne;
begin
  Int64PolynomialSetOne(Self);
end;

procedure TCnInt64Polynomial.SetZero;
begin
  Int64PolynomialSetZero(Self);
end;

function TCnInt64Polynomial.ToString: string;
begin
  Result := Int64PolynomialToString(Self);
end;

// ============================ ����ʽϵ�в������� =============================

function Int64PolynomialNew: TCnInt64Polynomial;
begin
  Result := TCnInt64Polynomial.Create;
end;

procedure Int64PolynomialFree(const P: TCnInt64Polynomial);
begin
  P.Free;
end;

function Int64PolynomialDuplicate(const P: TCnInt64Polynomial): TCnInt64Polynomial;
begin
  if P = nil then
  begin
    Result := nil;
    Exit;
  end;

  Result := Int64PolynomialNew;
  if Result <> nil then
    Int64PolynomialCopy(Result, P);
end;

function Int64PolynomialCopy(const Dst: TCnInt64Polynomial;
  const Src: TCnInt64Polynomial): TCnInt64Polynomial;
var
  I: Integer;
begin
  Result := Dst;
  if Src <> Dst then
  begin
    Dst.Clear;
    for I := 0 to Src.Count - 1 do
      Dst.Add(Src[I]);
    Dst.CorrectTop;
  end;
end;

function Int64PolynomialToString(const P: TCnInt64Polynomial;
  const VarName: string = 'X'): string;
var
  I, C: Integer;

  function VarPower(E: Integer): string;
  begin
    if E = 0 then
      Result := ''
    else if E = 1 then
      Result := VarName
    else
      Result := VarName + '^' + IntToStr(E);
  end;

begin
  Result := '';
  if Int64PolynomialIsZero(P) then
  begin
    Result := '0';
    Exit;
  end;

  for I := P.MaxDegree downto 0 do
  begin
    C := P[I];
    if C = 0 then
    begin
      Continue;
    end
    else if C > 0 then
    begin
      if Result = '' then  // ���������Ӻ�
        Result := IntToStr(C) + VarPower(I)
      else
        Result := Result + '+' + IntToStr(C) + VarPower(I);
    end
    else // С�� 0��Ҫ�ü���
      Result := Result + IntToStr(C) + VarPower(I);
  end;
end;

function Int64PolynomialIsZero(const P: TCnInt64Polynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and (P[0] = 0);
end;

procedure Int64PolynomialSetZero(const P: TCnInt64Polynomial);
begin
  P.Clear;
  P.Add(0);
end;

function Int64PolynomialIsOne(const P: TCnInt64Polynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and (P[0] = 1);
end;

procedure Int64PolynomialSetOne(const P: TCnInt64Polynomial);
begin
  P.Clear;
  P.Add(1);
end;

procedure Int64PolynomialNegate(const P: TCnInt64Polynomial);
var
  I: Integer;
begin
  for I := 0 to P.MaxDegree do
    P[I] := -P[I];
end;

procedure Int64PolynomialShiftLeft(const P: TCnInt64Polynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    Exit
  else if N < 0 then
    Int64PolynomialShiftRight(P, -N)
  else
  begin
    for I := 1 to N do
      P.Insert(0, 0);
  end;
end;

procedure Int64PolynomialShiftRight(const P: TCnInt64Polynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    Exit
  else if N < 0 then
    Int64PolynomialShiftLeft(P, -N)
  else
  begin
    for I := 1 to N do
    begin
      if P.Count = 0 then
        Break;
      P.Delete(0);
    end;

    if P.Count = 0 then
      P.Add(0);
  end;
end;

function Int64PolynomialEqual(const A, B: TCnInt64Polynomial): Boolean;
var
  I: Integer;
begin
  Result := A.MaxDegree = B.MaxDegree;
  if Result then
  begin
    for I := A.MaxDegree downto 0 do
    begin
      if A[I] <> B[I] then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure Int64PolynomialAddWord(const P: TCnInt64Polynomial; N: Integer);
begin
  P[0] := P[0] + N;
end;

procedure Int64PolynomialSubWord(const P: TCnInt64Polynomial; N: Integer);
begin
  P[0] := P[0] - N;
end;

procedure Int64PolynomialMulWord(const P: TCnInt64Polynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
  begin
    Int64PolynomialSetZero(P);
    Exit;
  end
  else
  begin
    for I := 0 to P.MaxDegree do
      P[I] := P[I] * N;
  end;
end;

procedure Int64PolynomialDivWord(const P: TCnInt64Polynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SZeroDivide);

  for I := 0 to P.MaxDegree do
    P[I] := P[I] div N;
end;

procedure Int64PolynomialNonNegativeModWord(const P: TCnInt64Polynomial; N: Int64);
var
  I: Integer;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SZeroDivide);

  for I := 0 to P.MaxDegree do
    P[I] := NonNegativeMod(P[I], N);
end;

function Int64PolynomialAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
var
  I, D1, D2: Integer;
  PBig: TCnInt64Polynomial;
begin
  D1 := Max(P1.MaxDegree, P2.MaxDegree);
  D2 := Min(P1.MaxDegree, P2.MaxDegree);

  Res.MaxDegree := D1;
  if D1 > D2 then
  begin
    if P1.MaxDegree > P2.MaxDegree then
      PBig := P1
    else
      PBig := P2;

    for I := D1 downto D2 + 1 do
      Res[I] := PBig[I];
  end;

  for I := D2 downto 0 do
    Res[I] := P1[I] + P2[I];
  Res.CorrectTop;
  Result := True;
end;

function Int64PolynomialSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
var
  I, D1, D2: Integer;
begin
  D1 := Max(P1.MaxDegree, P2.MaxDegree);
  D2 := Min(P1.MaxDegree, P2.MaxDegree);

  Res.MaxDegree := D1;
  if D1 > D2 then
  begin
    if P1.MaxDegree > P2.MaxDegree then // ����ʽ��
    begin
      for I := D1 downto D2 + 1 do
        Res[I] := P1[I];
    end
    else  // ��ʽ��
    begin
      for I := D1 downto D2 + 1 do
        Res[I] := -P2[I];
    end;
  end;

  for I := D2 downto 0 do
    Res[I] := P1[I] - P2[I];
  Res.CorrectTop;
  Result := True;
end;

function Int64PolynomialMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
var
  R: TCnInt64Polynomial;
  I, J, M: Integer;
begin
  if Int64PolynomialIsZero(P1) or Int64PolynomialIsZero(P2) then
  begin
    Int64PolynomialSetZero(Res);
    Result := True;
    Exit;
  end;

  if (Res = P1) or (Res = P2) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  M := P1.MaxDegree + P2.MaxDegree;
  R.MaxDegree := M;

  for I := 0 to P1.MaxDegree do
  begin
    // �ѵ� I �η������ֳ��� P2 ��ÿһ�����֣��ӵ������ I ��ͷ�Ĳ���
    for J := 0 to P2.MaxDegree do
    begin
      R[I + J] := R[I + J] + P1[I] * P2[J];
    end;
  end;

  R.CorrectTop;
  if (Res = P1) or (Res = P2) then
  begin
    Int64PolynomialCopy(Res, R);
    FLocalInt64PolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function Int64PolynomialDiv(const Res: TCnInt64Polynomial; const Remain: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; const Divisor: TCnInt64Polynomial): Boolean;
var
  SubRes: TCnInt64Polynomial; // ���ɵݼ���
  MulRes: TCnInt64Polynomial; // ���ɳ����˻�
  DivRes: TCnInt64Polynomial; // ������ʱ��
  I, D: Integer;
begin
  if Int64PolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  if Divisor.MaxDegree > P.MaxDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      Int64PolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      Int64PolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;

  try
    SubRes := FLocalInt64PolynomialPool.Obtain;
    Int64PolynomialCopy(SubRes, P);

    D := P.MaxDegree - Divisor.MaxDegree;
    DivRes := FLocalInt64PolynomialPool.Obtain;
    DivRes.MaxDegree := D;
    MulRes := FLocalInt64PolynomialPool.Obtain;

    for I := 0 to D do
    begin
      if P.MaxDegree - I > SubRes.MaxDegree then                 // �м���������λ
        Continue;

      // �ж� Divisor[Divisor.MaxDegree] �Ƿ������� SubRes[P.MaxDegree - I] ������˵�����������Ͷ���ʽ��Χ���޷�֧�֣�ֻ�ܳ���
      if (SubRes[P.MaxDegree - I] mod Divisor[Divisor.MaxDegree]) <> 0 then
        raise ECnPolynomialException.Create(SCnErrorDivExactly);

      Int64PolynomialCopy(MulRes, Divisor);
      Int64PolynomialShiftLeft(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�
      Int64PolynomialMulWord(MulRes, SubRes[P.MaxDegree - I] div MulRes[MulRes.MaxDegree]); // ��ʽ�˵���ߴ�ϵ����ͬ
      DivRes[D - I] := SubRes[P.MaxDegree - I];                  // �̷ŵ� DivRes λ��
      Int64PolynomialSub(SubRes, SubRes, MulRes);              // ���������·Ż� SubRes
    end;

    if Remain <> nil then
      Int64PolynomialCopy(Remain, SubRes);
    if Res <> nil then
      Int64PolynomialCopy(Res, DivRes);
  finally
    FLocalInt64PolynomialPool.Recycle(SubRes);
    FLocalInt64PolynomialPool.Recycle(MulRes);
    FLocalInt64PolynomialPool.Recycle(DivRes);
  end;
  Result := True;
end;

function Int64PolynomialMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialDiv(nil, Res, P, Divisor);
end;

function Int64PolynomialPower(const Res: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; Exponent: LongWord): Boolean;
var
  T: TCnInt64Polynomial;
begin
  if Exponent = 0 then
  begin
    Res.SetCoefficents([1]);
    Result := True;
    Exit;
  end
  else if Exponent = 1 then
  begin
    if Res <> P then
      Int64PolynomialCopy(Res, P);
    Result := True;
    Exit;
  end;

  T := Int64PolynomialDuplicate(P);
  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetCoefficents([1]);
    while Exponent > 0 do
    begin
      if (Exponent and 1) <> 0 then
        Int64PolynomialMul(Res, Res, T);

      Exponent := Exponent shr 1;
      Int64PolynomialMul(T, T, T);
    end;
    Result := True;
  finally
    T.Free;
  end;
end;

function Int64PolynomialReduce(const P: TCnInt64Polynomial): Integer;
var
  I, D: Integer;

  function Gcd(A, B: Integer): Integer;
  var
    T: Integer;
  begin
    while B <> 0 do
    begin
      T := B;
      B := A mod B;
      A := T;
    end;
    Result := A;
  end;

begin
  if P.MaxDegree = 0 then
  begin
    Result := P[P.MaxDegree];
    if P[P.MaxDegree] <> 0 then
      P[P.MaxDegree] := 1;
  end
  else
  begin
    D := P[0];
    for I := 0 to P.MaxDegree - 1 do
    begin
      D := Gcd(D, P[I + 1]);
      if D = 1 then
        Break;
    end;

    Result := D;
    if Result > 1 then
      Int64PolynomialDivWord(P, Result);
  end;
end;

function Int64PolynomialGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
var
  A, B, C: TCnInt64Polynomial;
begin
  A := nil;
  B := nil;
  C := nil;
  try
    A := FLocalInt64PolynomialPool.Obtain;
    B := FLocalInt64PolynomialPool.Obtain;

    if P1.MaxDegree >= P2.MaxDegree then
    begin
      Int64PolynomialCopy(A, P1);
      Int64PolynomialCopy(B, P2);
    end
    else
    begin
      Int64PolynomialCopy(A, P2);
      Int64PolynomialCopy(B, P1);
    end;

    C := FLocalInt64PolynomialPool.Obtain;
    while not B.IsZero do
    begin
      Int64PolynomialCopy(C, B);        // ���� B
      Int64PolynomialMod(B, A, B);      // A mod B �� B
      // B Ҫϵ��Լ�ֻ���
      Int64PolynomialReduce(B);
      Int64PolynomialCopy(A, C);        // ԭʼ B �� A
    end;

    Int64PolynomialCopy(Res, A);
    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(A);
    FLocalInt64PolynomialPool.Recycle(B);
    FLocalInt64PolynomialPool.Recycle(C);
  end;
end;

function Int64PolynomialCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnInt64Polynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    Res[0] := F[0];
    Result := True;
    Exit;
  end;

  if (Res = F) or (Res = P) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  X := FLocalInt64PolynomialPool.Obtain;
  T := FLocalInt64PolynomialPool.Obtain;
  X.SetOne;
  R.SetZero;

  // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
  for I := 0 to F.MaxDegree do
  begin
    Int64PolynomialCopy(T, X);
    Int64PolynomialMulWord(T, F[I]);
    Int64PolynomialAdd(R, R, T);

    if I <> F.MaxDegree then
      Int64PolynomialMul(X, X, P);
  end;

  if (Res = F) or (Res = P) then
  begin
    Int64PolynomialCopy(Res, R);
    FLocalInt64PolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function Int64PolynomialCalcDivisionPolynomial(A, B: Integer; Degree: Integer;
  outDivisionPolynomial: TCnInt64Polynomial): Boolean;
var
  N: Integer;
  D1, D2, D3, Y: TCnInt64Polynomial;
begin
  Result := False;
  if Degree < 0 then
    Exit
  else if Degree = 0 then
  begin
    outDivisionPolynomial.SetCoefficents([0]);  // f0(X) = 0
    Result := True;
  end
  else if (Degree = 1) or (Degree = 2) then
  begin
    outDivisionPolynomial.SetCoefficents([1]);  // f1(X) = 1, f2(X) = 1,
    Result := True;
  end
  else if Degree = 3 then   // f3(X) = 3 X4 + 6 a X2 + 12 b X - a^2
  begin
    outDivisionPolynomial.SetCoefficents([- A * A,
      12 * B, 6 * A, 0, 3]);
    Result := True;
  end
  else if Degree = 4 then // f4(X) = 2 X6 + 10 a X4 + 40 b X3 - 10 a2X2 - 8 a b X - 2 a3 - 16 b^2
  begin
    outDivisionPolynomial.SetCoefficents([
      -2 * A * A * A - 16 * B * B,
      -8 * A * B, -10 * A * A,
      40 * B, 10 * A, 0, 2]);
    Result := True;
  end
  else
  begin
    D1 := nil;
    D2 := nil;
    D3 := nil;
    Y := nil;

    try
      // ��ʼ�ݹ����
      N := Degree shr 1;
      if (Degree and 1) = 0 then // Degree ��ż��
      begin
        D1 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialCalcDivisionPolynomial(A, B, N + 2, D1);

        D2 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialCalcDivisionPolynomial(A, B, N - 1, D2);
        Int64PolynomialMul(D2, D2, D2);

        Int64PolynomialAdd(D1, D1, D2);   // D1 �õ� Fn+2 * Fn-1 ^ 2

        D3 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialCalcDivisionPolynomial(A, B, N - 2, D3);

        Int64PolynomialCalcDivisionPolynomial(A, B, N + 1, D2);
        Int64PolynomialMul(D2, D2, D2);   // D2 �õ� Fn-2 * Fn+1 ^ 2

        Int64PolynomialSub(D1, D1, D2);   // D1 �õ� Fn+2 * Fn-1 ^ 2 - Fn-2 * Fn+1 ^ 2

        Int64PolynomialCalcDivisionPolynomial(A, B, N, D2);          // D2 �õ� Fn
        Int64PolynomialCompose(outDivisionPolynomial, D2, D1); // ����õ� F2n
      end
      else // Degree ������
      begin
        Y := FLocalInt64PolynomialPool.Obtain;
        Y.SetCoefficents([4 * B, 4 * A, 0, 4]);
        Int64PolynomialMul(Y, Y, Y);

        if (N and 1) <> 0 then // N ������
        begin
          D1 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialCalcDivisionPolynomial(A, B, N + 2, D1);

          D2 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialCalcDivisionPolynomial(A, B, N, D2);
          Int64PolynomialPower(D2, D2, 3);

          Int64PolynomialMul(D1, D1, D2);  // D1 �õ� Fn+2 * Fn ^ 3

          D3 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialCalcDivisionPolynomial(A, B, N + 1, D3);
          Int64PolynomialPower(D3, D3, 3); // D3 �õ� Fn+1 ^ 3

          Int64PolynomialCalcDivisionPolynomial(A, B, N - 1, D2);
          Int64PolynomialCompose(D2, D2, Y); // D2 �õ� Fn-1(Y)

          Int64PolynomialMul(D2, D2, D3);    // D2 �õ� Fn+1 ^ 3 * Fn-1(Y)
          Int64PolynomialSub(outDivisionPolynomial, D1, D2);
        end
        else // N ��ż��
        begin
          D1 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialCalcDivisionPolynomial(A, B, N + 2, D1);

          D2 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialCalcDivisionPolynomial(A, B, N, D2);
          Int64PolynomialPower(D2, D2, 3);

          Int64PolynomialMul(D1, D1, D2);
          Int64PolynomialMul(D1, D1, Y);   // D1 �õ� Y * Fn+2 * Fn ^ 3

          D3 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialCalcDivisionPolynomial(A, B, N + 1, D3);
          Int64PolynomialPower(D3, D3, 3); // D3 �õ� Fn+1 ^ 3

          Int64PolynomialCalcDivisionPolynomial(A, B, N - 1, D2);     // D2 �õ� Fn-1

          Int64PolynomialMul(D2, D2, D3);  // D2 �õ� Fn+1 ^ 3 * Fn-1

          Int64PolynomialSub(outDivisionPolynomial, D1, D2);
        end;
      end;
    finally
      FLocalInt64PolynomialPool.Recycle(D1);
      FLocalInt64PolynomialPool.Recycle(D2);
      FLocalInt64PolynomialPool.Recycle(D3);
      FLocalInt64PolynomialPool.Recycle(Y);
    end;
    Result := True;
  end;
end;

function Int64PolynomialGaloisAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialAdd(Res, P1, P2);
  if Result then
  begin
    Int64PolynomialNonNegativeModWord(Res, Prime);
    if Primitive <> nil then
      Int64PolynomialGaloisMod(Res, Res, Primitive, Prime);
  end;
end;

function Int64PolynomialGaloisSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialSub(Res, P1, P2);
  if Result then
  begin
    Int64PolynomialNonNegativeModWord(Res, Prime);
    if Primitive <> nil then
      Int64PolynomialGaloisMod(Res, Res, Primitive, Prime);
  end;
end;

function Int64PolynomialGaloisMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  R: TCnInt64Polynomial;
  I, J, M: Integer;
begin
  if Int64PolynomialIsZero(P1) or Int64PolynomialIsZero(P2) then
  begin
    Int64PolynomialSetZero(Res);
    Result := True;
    Exit;
  end;

  if (Res = P1) or (Res = P2) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  M := P1.MaxDegree + P2.MaxDegree;
  R.MaxDegree := M;

  for I := 0 to P1.MaxDegree do
  begin
    // �ѵ� I �η������ֳ��� P2 ��ÿһ�����֣��ӵ������ I ��ͷ�Ĳ��֣���ȡģ
    for J := 0 to P2.MaxDegree do
    begin
      R[I + J] := NonNegativeMod(R[I + J] + P1[I] * P2[J], Prime);
    end;
  end;

  R.CorrectTop;

  // �ٶԱ�ԭ����ʽȡģ��ע�����ﴫ��ı�ԭ����ʽ�� mod �����ĳ��������Ǳ�ԭ����ʽ����
  if Primitive <> nil then
    Int64PolynomialGaloisMod(R, R, Primitive, Prime);

  if (Res = P1) or (Res = P2) then
  begin
    Int64PolynomialCopy(Res, R);
    FLocalInt64PolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function Int64PolynomialGaloisDiv(const Res: TCnInt64Polynomial;
  const Remain: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  SubRes: TCnInt64Polynomial; // ���ɵݼ���
  MulRes: TCnInt64Polynomial; // ���ɳ����˻�
  DivRes: TCnInt64Polynomial; // ������ʱ��
  I, D: Integer;
  K, T: Int64;
begin
  if Int64PolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  // ���赣�Ĳ������������⣬��Ϊ����Ԫ�� mod ����

  if Divisor.MaxDegree > P.MaxDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      Int64PolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      Int64PolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;

  try
    SubRes := FLocalInt64PolynomialPool.Obtain;
    Int64PolynomialCopy(SubRes, P);

    D := P.MaxDegree - Divisor.MaxDegree;
    DivRes := FLocalInt64PolynomialPool.Obtain;
    DivRes.MaxDegree := D;
    MulRes := FLocalInt64PolynomialPool.Obtain;

    if Divisor[Divisor.MaxDegree] = 1 then
      K := 1
    else
      K := CnInt64ModularInverse2(Divisor[Divisor.MaxDegree], Prime); // K �ǳ�ʽ���λ����Ԫ

    for I := 0 to D do
    begin
      if P.MaxDegree - I > SubRes.MaxDegree then                 // �м���������λ
        Continue;
      Int64PolynomialCopy(MulRes, Divisor);
      Int64PolynomialShiftLeft(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�

      // ��ʽҪ��һ������������� SubRes ���λ���Գ�ʽ���λ�õ��Ľ����Ҳ�� SubRes ���λ���Գ�ʽ���λ����Ԫ�� mod Prime
      T := NonNegativeMod(SubRes[P.MaxDegree - I] * K, Prime);
      Int64PolynomialGaloisMulWord(MulRes, T, Prime);          // ��ʽ�˵���ߴ�ϵ����ͬ

      DivRes[D - I] := SubRes[P.MaxDegree - I];                  // �̷ŵ� DivRes λ��
      Int64PolynomialGaloisSub(SubRes, SubRes, MulRes, Prime); // ����ģ�������·Ż� SubRes
    end;

    // ������ʽ����Ҫ��ģ��ԭ����ʽ
    if Primitive <> nil then
    begin
      Int64PolynomialGaloisMod(SubRes, SubRes, Primitive, Prime);
      Int64PolynomialGaloisMod(DivRes, DivRes, Primitive, Prime);
    end;

    if Remain <> nil then
      Int64PolynomialCopy(Remain, SubRes);
    if Res <> nil then
      Int64PolynomialCopy(Res, DivRes);
    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(SubRes);
    FLocalInt64PolynomialPool.Recycle(MulRes);
    FLocalInt64PolynomialPool.Recycle(DivRes);
  end;
end;

function Int64PolynomialGaloisMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialGaloisDiv(nil, Res, P, Divisor, Prime, Primitive);
end;

function Int64PolynomialGaloisPower(const Res, P: TCnInt64Polynomial;
  Exponent: LongWord; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  T: TCnInt64Polynomial;
begin
  if Exponent = 0 then
  begin
    Res.SetCoefficents([1]);
    Result := True;
    Exit;
  end
  else if Exponent = 1 then
  begin
    if Res <> P then
      Int64PolynomialCopy(Res, P);
    Result := True;
    Exit;
  end;

  T := Int64PolynomialDuplicate(P);
  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetCoefficents([1]);
    while Exponent > 0 do
    begin
      if (Exponent and 1) <> 0 then
        Int64PolynomialGaloisMul(Res, Res, T, Prime, Primitive);

      Exponent := Exponent shr 1;
      Int64PolynomialGaloisMul(T, T, T, Prime, Primitive);
    end;
    Result := True;
  finally
    T.Free;
  end;
end;

function Int64PolynomialGaloisAddWord(const P: TCnInt64Polynomial; N: Integer; Prime: Int64): Boolean;
begin
  P[0] := NonNegativeMod(P[0] + N, Prime);
  Result := True;
end;

function Int64PolynomialGaloisSubWord(const P: TCnInt64Polynomial; N: Integer; Prime: Int64): Boolean;
begin
  P[0] := NonNegativeMod(P[0] - N, Prime);
  Result := True;
end;

function Int64PolynomialGaloisMulWord(const P: TCnInt64Polynomial; N: Integer; Prime: Int64): Boolean;
begin
  Int64PolynomialMulWord(P, N);
  Int64PolynomialNonNegativeModWord(P, Prime);
  Result := True;
end;

function Int64PolynomialGaloisDivWord(const P: TCnInt64Polynomial; N: Integer; Prime: Int64): Boolean;
var
  I: Integer;
  K: Int64;
  B: Boolean;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SDivByZero);

  B := N < 0;
  if B then
    N := -N;

  K := CnInt64ModularInverse2(N, Prime);
  for I := 0 to P.MaxDegree do
  begin
    P[I] := NonNegativeMod(P[I] * K, Prime);
    if B then
      P[I] := Prime - LongWord(P[I]);
  end;
  Result := True;
end;

function Int64PolynomialGaloisMonic(const P: TCnInt64Polynomial; Prime: Int64): Integer;
begin
  Result := P[P.MaxDegree];
  if (Result <> 1) and (Result <> 0) then
    Int64PolynomialGaloisDivWord(P, Result, Prime);
end;

function Int64PolynomialGaloisGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  A, B, C: TCnInt64Polynomial;
begin
  A := nil;
  B := nil;
  C := nil;
  try
    A := FLocalInt64PolynomialPool.Obtain;
    B := FLocalInt64PolynomialPool.Obtain;

    if P1.MaxDegree >= P2.MaxDegree then
    begin
      Int64PolynomialCopy(A, P1);
      Int64PolynomialCopy(B, P2);
    end
    else
    begin
      Int64PolynomialCopy(A, P2);
      Int64PolynomialCopy(B, P1);
    end;

    C := FLocalInt64PolynomialPool.Obtain;
    while not B.IsZero do
    begin
      Int64PolynomialCopy(C, B);          // ���� B
      Int64PolynomialGaloisMod(B, A, B, Prime);  // A mod B �� B
      Int64PolynomialCopy(A, C);          // ԭʼ B �� A
    end;

    Int64PolynomialCopy(Res, A);
    Int64PolynomialGaloisMonic(Res, Prime);      // ���Ϊһ
    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(A);
    FLocalInt64PolynomialPool.Recycle(B);
    FLocalInt64PolynomialPool.Recycle(C);
  end;
end;

procedure Int64PolynomialGaloisExtendedEuclideanGcd(A, B: TCnInt64Polynomial;
  X, Y: TCnInt64Polynomial; Prime: Int64);
var
  T, P, M: TCnInt64Polynomial;
begin
  if B.IsZero then
  begin
    X.SetZero;
    X[0] := CnInt64ModularInverse2(A[0], Prime);
    // X ���� A ���� P ��ģ��Ԫ��������������շת����������� 1
    // ��Ϊ A �����ǲ����� 1 ������
    Y.SetZero;
  end
  else
  begin
    T := nil;
    P := nil;
    M := nil;

    try
      T := FLocalInt64PolynomialPool.Obtain;
      P := FLocalInt64PolynomialPool.Obtain;
      M := FLocalInt64PolynomialPool.Obtain;

      Int64PolynomialGaloisMod(P, A, B, Prime);

      Int64PolynomialGaloisExtendedEuclideanGcd(B, P, Y, X, Prime);

      // Y := Y - (A div B) * X;
      Int64PolynomialGaloisDiv(P, M, A, B, Prime);
      Int64PolynomialGaloisMul(P, P, X, Prime);
      Int64PolynomialGaloisSub(Y, Y, P, Prime);
    finally
      FLocalInt64PolynomialPool.Recycle(M);
      FLocalInt64PolynomialPool.Recycle(P);
      FLocalInt64PolynomialPool.Recycle(T);
    end;
  end;
end;

procedure Int64PolynomialGaloisModularInverse(const Res: TCnInt64Polynomial;
  X, Modulus: TCnInt64Polynomial; Prime: Int64);
var
  X1, Y: TCnInt64Polynomial;
begin
  X1 := nil;
  Y := nil;

  try
    X1 := FLocalInt64PolynomialPool.Obtain;
    Y := FLocalInt64PolynomialPool.Obtain;

    Int64PolynomialCopy(X1, X);

    // ��չŷ�����շת��������Ԫһ�β�����ϵ������ʽ���� A * X - B * Y = 1 ��������
    Int64PolynomialGaloisExtendedEuclideanGcd(X1, Modulus, Res, Y, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(X1);
    FLocalInt64PolynomialPool.Recycle(Y);
  end;
end;

function Int64PolynomialGaloisCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  I: Integer;
  R, X, T: TCnInt64Polynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    Res[0] := NonNegativeMod(F[0], Prime);
    Result := True;
    Exit;
  end;

  if (Res = F) or (Res = P) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  X := FLocalInt64PolynomialPool.Obtain;
  T := FLocalInt64PolynomialPool.Obtain;
  X.SetOne;
  R.SetZero;

  // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
  for I := 0 to F.MaxDegree do
  begin
    Int64PolynomialCopy(T, X);
    Int64PolynomialGaloisMulWord(T, F[I], Prime);
    Int64PolynomialGaloisAdd(R, R, T, Prime);

    if I <> F.MaxDegree then
      Int64PolynomialGaloisMul(X, X, P, Prime);
  end;

  if (Res = F) or (Res = P) then
  begin
    Int64PolynomialCopy(Res, R);
    FLocalInt64PolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function Int64PolynomialGaloisCalcDivisionPolynomial(A, B: Integer; Degree: Integer;
  outDivisionPolynomial: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  N: Integer;
  D1, D2, D3, Y: TCnInt64Polynomial;
begin
  Result := False;
  if Degree < 0 then
    Exit
  else if Degree = 0 then
  begin
    outDivisionPolynomial.SetCoefficents([0]);  // f0(X) = 0
    Result := True;
  end
  else if (Degree = 1) or (Degree = 2) then
  begin
    outDivisionPolynomial.SetCoefficents([1]);  // f1(X) = 1, f2(X) = 1,
    Result := True;
  end
  else if Degree = 3 then   // f3(X) = 3 X4 + 6 a X2 + 12 b X - a^2
  begin
    outDivisionPolynomial.SetCoefficents([- A * A,
      12 * B, 6 * A, 0, 3]);
    Int64PolynomialNonNegativeModWord(outDivisionPolynomial, Prime);
    Result := True;
  end
  else if Degree = 4 then // f4(X) = 2 X6 + 10 a X4 + 40 b X3 - 10 a2X2 - 8 a b X - 2 a3 - 16 b^2
  begin
    outDivisionPolynomial.SetCoefficents([-2 * A * A * A - 16 * B * B,
      -8 * A * B, -10 * A * A, 40 * B, 10 * A, 0, 2]);
    Int64PolynomialNonNegativeModWord(outDivisionPolynomial, Prime);
    Result := True;
  end
  else
  begin
    D1 := nil;
    D2 := nil;
    D3 := nil;
    Y := nil;

    try
      // ��ʼ�ݹ����
      N := Degree shr 1;
      if (Degree and 1) = 0 then // Degree ��ż��
      begin
        D1 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime);

        D2 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);
        Int64PolynomialGaloisMul(D2, D2, D2, Prime);

        Int64PolynomialGaloisAdd(D1, D1, D2, Prime);   // D1 �õ� Fn+2 * Fn-1 ^ 2

        D3 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 2, D3, Prime);

        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D2, Prime);
        Int64PolynomialGaloisMul(D2, D2, D2, Prime);   // D2 �õ� Fn-2 * Fn+1 ^ 2

        Int64PolynomialGaloisSub(D1, D1, D2, Prime);   // D1 �õ� Fn+2 * Fn-1 ^ 2 - Fn-2 * Fn+1 ^ 2

        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);          // D2 �õ� Fn
        Int64PolynomialCompose(outDivisionPolynomial, D2, D1); // ����õ� F2n
      end
      else // Degree ������
      begin
        Y := FLocalInt64PolynomialPool.Obtain;
        Y.SetCoefficents([4 * B, 4 * A, 0, 4]);
        Int64PolynomialGaloisMul(Y, Y, Y, Prime);

        if (N and 1) <> 0 then // N ������
        begin
          D1 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime);

          D2 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);
          Int64PolynomialGaloisPower(D2, D2, 3, Prime);

          Int64PolynomialGaloisMul(D1, D1, D2, Prime);  // D1 �õ� Fn+2 * Fn ^ 3

          D3 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D3, Prime);
          Int64PolynomialGaloisPower(D3, D3, 3, Prime); // D3 �õ� Fn+1 ^ 3

          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);
          Int64PolynomialGaloisCompose(D2, D2, Y, Prime); // D2 �õ� Fn-1(Y)

          Int64PolynomialGaloisMul(D2, D2, D3, Prime);    // D2 �õ� Fn+1 ^ 3 * Fn-1(Y)
          Int64PolynomialGaloisSub(outDivisionPolynomial, D1, D2, Prime);
        end
        else // N ��ż��
        begin
          D1 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime);

          D2 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);
          Int64PolynomialGaloisPower(D2, D2, 3, Prime);

          Int64PolynomialGaloisMul(D1, D1, D2, Prime);
          Int64PolynomialGaloisMul(D1, D1, Y, Prime);   // D1 �õ� Y * Fn+2 * Fn ^ 3

          D3 := FLocalInt64PolynomialPool.Obtain;
          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D3, Prime);
          Int64PolynomialGaloisPower(D3, D3, 3, Prime); // D3 �õ� Fn+1 ^ 3

          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);     // D2 �õ� Fn-1

          Int64PolynomialGaloisMul(D2, D2, D3, Prime);  // D2 �õ� Fn+1 ^ 3 * Fn-1

          Int64PolynomialGaloisSub(outDivisionPolynomial, D1, D2, Prime);
        end;
      end;
    finally
      FLocalInt64PolynomialPool.Recycle(D1);
      FLocalInt64PolynomialPool.Recycle(D2);
      FLocalInt64PolynomialPool.Recycle(D3);
      FLocalInt64PolynomialPool.Recycle(Y);
    end;
    Result := True;
  end;
end;

{ TCnInt64PolynomialPool }

constructor TCnInt64PolynomialPool.Create;
begin
  inherited Create(False);
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  InitializeCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection := TCriticalSection.Create;
{$ENDIF}
{$ENDIF}
end;

destructor TCnInt64PolynomialPool.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TObject(Items[I]).Free;

{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  DeleteCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Free;
{$ENDIF}
{$ENDIF}
end;

procedure TCnInt64PolynomialPool.Enter;
begin
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  EnterCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Acquire;
{$ENDIF}
{$ENDIF}
end;

procedure TCnInt64PolynomialPool.Leave;
begin
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  LeaveCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Release;
{$ENDIF}
{$ENDIF}
end;

function TCnInt64PolynomialPool.Obtain: TCnInt64Polynomial;
begin
  Enter;
  if Count = 0 then
  begin
    Result := TCnInt64Polynomial.Create;
  end
  else
  begin
    Result := TCnInt64Polynomial(Items[Count - 1]);
    Delete(Count - 1);
  end;
  Leave;

  Result.SetZero;
end;

procedure TCnInt64PolynomialPool.Recycle(Poly: TCnInt64Polynomial);
begin
  if Poly <> nil then
  begin
    Enter;
    Add(Poly);
    Leave;
  end;
end;

initialization
  FLocalInt64PolynomialPool := TCnInt64PolynomialPool.Create;

finalization
  FLocalInt64PolynomialPool.Free;

end.
