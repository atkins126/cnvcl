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

unit CnPolynomial;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�����ʽ����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org��
* ��    ע��1��֧����ͨ����ϵ������ʽ�������㣬����ֻ֧�ֳ�����ߴ���Ϊ 1 �����
*           ֧����������Χ�ڵĶ���ʽ�������㣬ϵ���� mod p ���ҽ���Ա�ԭ����ʽ����
*           2��֧�ִ�����ϵ������ʽ�Լ������ʽ����ͨ���������Լ�����������Χ�ڵ�����
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2021.12.01 V1.6
*               ʵ�� BigNumber ��Χ�ڵĶ�Ԫ��ϵ������ʽ�������㣬������������
*           2021.11.17 V1.5
*               ʵ�� Int64 ��Χ�ڵĶ�Ԫ��ϵ������ʽ�������㣬������������
*           2020.08.29 V1.4
*               ʵ�� Int64 ��Χ�ڵĿ������۱任/���ٸ���Ҷ�任����ʽ�˷���������������
*           2020.11.14 V1.3
*               ʵ������������ Int64 �Լ���������Χ�ڵ������ʽ�Ĵ���
*           2020.11.08 V1.3
*               ʵ�����������д�������Χ�ڵĶ���ʽ�Լ������ʽ��������
*           2020.10.20 V1.2
*               ʵ������������ Int64 ��Χ�ڵ������ʽ��������
*           2020.08.28 V1.1
*               ʵ������������ Int64 ��Χ�ڵĶ���ʽ�������㣬�����Ա�ԭ����ʽ�����ģ��Ԫ
*           2020.08.21 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, SysConst, Math, Contnrs, CnPrimeNumber, CnNativeDecl,
  CnMatrix, CnContainers, CnBigNumber, CnBigRational, CnComplex, CnDFT;

type
  ECnPolynomialException = class(Exception);

// =============================================================================
//
//                      һԪ��ϵ������ʽ��һԪ�����ʽ
//
// =============================================================================

  TCnInt64Polynomial = class(TCnInt64List)
  {* һԪ��ϵ������ʽ��ϵ����ΧΪ Int64}
  private
    function GetMaxDegree: Integer;
    procedure SetMaxDegree(const Value: Integer);
  public
    constructor Create(LowToHighCoefficients: array of const); overload;
    {* ���캯��������Ϊ�ӵ͵��ߵ�ϵ����ע��ϵ����ʼ��ʱ���� MaxInt32/MaxInt64 �Ļᱻ���� Integer/Int64 ���为}
    constructor Create; overload;
    destructor Destroy; override;

    procedure SetCoefficents(LowToHighCoefficients: array of const);
    {* һ���������ôӵ͵��ߵ�ϵ��}
    procedure CorrectTop;
    {* �޳��ߴε� 0 ϵ��}
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ʽת���ַ���}
    procedure SetString(const Poly: string);
    {* ������ʽ�ַ���ת��Ϊ�����������}
    function IsZero: Boolean;
    {* �����Ƿ�Ϊ 0}
    procedure SetZero;
    {* ��Ϊ 0}
    function IsOne: Boolean;
    {* �����Ƿ�Ϊ 1}
    procedure SetOne;
    {* ��Ϊ 1}
    function IsNegOne: Boolean;
    {* �����Ƿ�Ϊ -1}
    procedure Negate;
    {* ����ϵ����}
    function IsMonic: Boolean;
    {* �Ƿ���һ����ʽ}
    property MaxDegree: Integer read GetMaxDegree write SetMaxDegree;
    {* ��ߴ�����0 ��ʼ������ Count ����ֻ���� Integer}
  end;

  TCnInt64RationalPolynomial = class(TPersistent)
  {* һԪ��ϵ�������ʽ����ĸ���ӷֱ�ΪһԪ��ϵ������ʽ}
  private
    FNominator: TCnInt64Polynomial;
    FDenominator: TCnInt64Polynomial;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function IsInt: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�������ʽ��Ҳ�����жϷ�ĸ�Ƿ������� 1}
    function IsZero: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�Ϊ 0}
    function IsOne: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�Ϊ 1}
    procedure Reciprocal;
    {* ��ɵ���}
    procedure Neg;
    {* ��ɸ���}
    procedure SetZero;
    {* ��Ϊ 0}
    procedure SetOne;
    {* ��Ϊ 1}
    procedure Reduce;
    {* Լ��}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ַ���}
    procedure SetString(const Rational: string);
    {* ������ʽ���ʽ�ַ���ת��Ϊ�����������}

    property Nominator: TCnInt64Polynomial read FNominator;
    {* ����ʽ}
    property Denominator: TCnInt64Polynomial read FDenominator;
    {* ��ĸʽ}
  end;

  TCnInt64PolynomialPool = class(TCnMathObjectPool)
  {* һԪ��ϵ������ʽ��ʵ���࣬����ʹ�õ�һԪ��ϵ������ʽ�ĵط����д���һԪ��ϵ������ʽ��}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnInt64Polynomial; reintroduce;
    procedure Recycle(Poly: TCnInt64Polynomial); reintroduce;
  end;

  TCnInt64RationalPolynomialPool = class(TCnMathObjectPool)
  {* һԪ��ϵ�������ʽ��ʵ���࣬����ʹ�õ�һԪ��ϵ�������ʽ�ĵط����д�����һԪϵ�������ʽ��}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnInt64RationalPolynomial; reintroduce;
    procedure Recycle(Poly: TCnInt64RationalPolynomial); reintroduce;
  end;

// =============================================================================
//
//                 һԪ����ϵ������ʽ��һԪ����ϵ�������ʽ
//
// =============================================================================

  TCnBigNumberPolynomial = class(TCnBigNumberList)
  {* һԪ����ϵ������ʽ}
  private
    function GetMaxDegree: Integer;
    procedure SetMaxDegree(const Value: Integer);
  public
    constructor Create(LowToHighCoefficients: array of const); overload;
    {* ���캯��������Ϊ�ӵ͵��ߵ�ϵ����ע��ϵ����ʼ��ʱ���� MaxInt32/MaxInt64 �Ļᱻ���� Integer/Int64 ���为}
    constructor Create; overload;
    destructor Destroy; override;

    procedure SetCoefficents(LowToHighCoefficients: array of const);
    {* һ���������ôӵ͵��ߵ�ϵ��}
    procedure CorrectTop;
    {* �޳��ߴε� 0 ϵ��}
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ʽת���ַ���}
    procedure SetString(const Poly: string);
    {* ������ʽ�ַ���ת��Ϊ�����������}
    function IsZero: Boolean;
    {* �����Ƿ�Ϊ 0}
    procedure SetZero;
    {* ��Ϊ 0}
    function IsOne: Boolean;
    {* �����Ƿ�Ϊ 1}
    procedure SetOne;
    {* ��Ϊ 1}
    function IsNegOne: Boolean;
    {* �����Ƿ�Ϊ -1}
    procedure Negate;
    {* ����ϵ����}
    function IsMonic: Boolean;
    {* �Ƿ���һ����ʽ}
    property MaxDegree: Integer read GetMaxDegree write SetMaxDegree;
    {* ��ߴ�����0 ��ʼ}
  end;

  TCnBigNumberRationalPolynomial = class(TPersistent)
  {* һԪ����ϵ�������ʽ����ĸ���ӷֱ�ΪһԪ����ϵ������ʽ}
  private
    FNominator: TCnBigNumberPolynomial;
    FDenominator: TCnBigNumberPolynomial;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function IsInt: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�������ʽ��Ҳ�����жϷ�ĸ�Ƿ������� 1}
    function IsZero: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�Ϊ 0}
    function IsOne: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�Ϊ 1}
    procedure Reciprocal;
    {* ��ɵ���}
    procedure Neg;
    {* ��ɸ���}
    procedure SetZero;
    {* ��Ϊ 0}
    procedure SetOne;
    {* ��Ϊ 1}
    procedure Reduce;
    {* Լ��}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ַ���}
    procedure SetString(const Rational: string);
    {* ������ʽ���ʽ�ַ���ת��Ϊ�����������}

    property Nominator: TCnBigNumberPolynomial read FNominator;
    {* ����ʽ}
    property Denominator: TCnBigNumberPolynomial read FDenominator;
    {* ��ĸʽ}
  end;

  TCnBigNumberPolynomialPool = class(TCnMathObjectPool)
  {* һԪ����ϵ������ʽ��ʵ���࣬����ʹ�õ�һԪ������ϵ������ʽ�ĵط����д���һԪ������ϵ������ʽ��}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnBigNumberPolynomial; reintroduce;
    procedure Recycle(Poly: TCnBigNumberPolynomial); reintroduce;
  end;

  TCnBigNumberRationalPolynomialPool = class(TCnMathObjectPool)
  {* һԪ����ϵ�������ʽ��ʵ���࣬����ʹ�õ�һԪ����ϵ�������ʽ�ĵط����д���һԪ����ϵ�������ʽ��}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnBigNumberRationalPolynomial; reintroduce;
    procedure Recycle(Poly: TCnBigNumberRationalPolynomial); reintroduce;
  end;

// ====================== һԪ��ϵ������ʽ�������� =============================

function Int64PolynomialNew: TCnInt64Polynomial;
{* ����һ����̬�����һԪ��ϵ������ʽ���󣬵�ͬ�� TCnInt64Polynomial.Create}

procedure Int64PolynomialFree(const P: TCnInt64Polynomial);
{* �ͷ�һ��һԪ��ϵ������ʽ���󣬵�ͬ�� TCnInt64Polynomial.Free}

function Int64PolynomialDuplicate(const P: TCnInt64Polynomial): TCnInt64Polynomial;
{* ��һ��һԪ��ϵ������ʽ�����¡һ���¶���}

function Int64PolynomialCopy(const Dst: TCnInt64Polynomial;
  const Src: TCnInt64Polynomial): TCnInt64Polynomial;
{* ����һ��һԪ��ϵ������ʽ���󣬳ɹ����� Dst}

function Int64PolynomialToString(const P: TCnInt64Polynomial;
  const VarName: Char = 'X'): string;
{* ��һ��һԪ��ϵ������ʽ����ת���ַ�����δ֪��Ĭ���� X ��ʾ}

function Int64PolynomialSetString(const P: TCnInt64Polynomial;
  const Str: string; const VarName: Char = 'X'): Boolean;
{* ���ַ�����ʽ��һԪ��ϵ������ʽ��ֵ��һԪ��ϵ������ʽ���󣬷����Ƿ�ֵ�ɹ�}

function Int64PolynomialIsZero(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ��һԪ��ϵ������ʽ�����Ƿ�Ϊ 0}

procedure Int64PolynomialSetZero(const P: TCnInt64Polynomial);
{* ��һ��һԪ��ϵ������ʽ������Ϊ 0}

function Int64PolynomialIsOne(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ��һԪ��ϵ������ʽ�����Ƿ�Ϊ 1}

procedure Int64PolynomialSetOne(const P: TCnInt64Polynomial);
{* ��һ��һԪ��ϵ������ʽ������Ϊ 1}

function Int64PolynomialIsNegOne(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ��һԪ��ϵ������ʽ�����Ƿ�Ϊ -1}

procedure Int64PolynomialNegate(const P: TCnInt64Polynomial);
{* ��һ��һԪ��ϵ������ʽ��������ϵ����}

function Int64PolynomialIsMonic(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ��һԪ��ϵ������ʽ�Ƿ�����һ����ʽ��Ҳ�����ж���ߴ�ϵ���Ƿ�Ϊ 1}

procedure Int64PolynomialShiftLeft(const P: TCnInt64Polynomial; N: Integer);
{* ��һ��һԪ��ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N}

procedure Int64PolynomialShiftRight(const P: TCnInt64Polynomial; N: Integer);
{* ��һ��һԪ��ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N��С�� 0 �ĺ�����}

function Int64PolynomialEqual(const A, B: TCnInt64Polynomial): Boolean;
{* �ж���һԪ��ϵ������ʽÿ��ϵ���Ƿ��Ӧ��ȣ����򷵻� True}

// ====================== һԪ��ϵ������ʽ��ͨ���� =============================

procedure Int64PolynomialAddWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ��һԪ��ϵ������ʽ����ĳ�ϵ������ N}

procedure Int64PolynomialSubWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ��һԪ��ϵ������ʽ����ĳ�ϵ����ȥ N}

procedure Int64PolynomialMulWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ��һԪ��ϵ������ʽ����ĸ���ϵ�������� N}

procedure Int64PolynomialDivWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ��һԪ��ϵ������ʽ����ĸ���ϵ�������� N���粻��������ȡ��}

procedure Int64PolynomialNonNegativeModWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ��һԪ��ϵ������ʽ����ĸ���ϵ������ N �Ǹ����࣬��������������}

function Int64PolynomialAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
{* ����һԪ��ϵ������ʽ������ӣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
{* ����һԪ��ϵ������ʽ���������������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
{* ����һԪ��ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialDftMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
{* ����һԪ��ϵ������ʽ����ʹ����ɢ����Ҷ�任����ɢ����Ҷ��任��ˣ�������� Res �У�
  ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2
  ע��ʹ�ø������ٵ���Ϊ����Ե�ʿ��ܳ��ֲ���ϵ���и�λ�����Ǻ��Ƽ�ʹ��}

function Int64PolynomialNttMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
{* ����һԪ��ϵ������ʽ����ʹ�ÿ������۱任�����������任��ˣ�������� Res �У�
  ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2
  ע������ʽϵ��ֻ֧�� [0, CN_P) ���䣬����ʽ��������С��ģ���� 2^23��������÷�ΧҲ����}

function Int64PolynomialDiv(const Res: TCnInt64Polynomial; const Remain: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; const Divisor: TCnInt64Polynomial): Boolean;
{* ����һԪ��ϵ������ʽ����������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ�᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function Int64PolynomialMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial): Boolean;
{* ����һԪ��ϵ������ʽ�������࣬�������� Res �У����������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ�᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ��
   Res ������ P �� Divisor��P ������ Divisor}

function Int64PolynomialPower(const Res: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; Exponent: Int64): Boolean;
{* ����һԪ��ϵ������ʽ�� Exponent ���ݣ�������ϵ����������⣬
   ���ؼ����Ƿ�ɹ���Res ������ P}

function Int64PolynomialReduce(const P: TCnInt64Polynomial): Integer;
{* ����һԪ��ϵ������ʽϵ����Ҳ�����Ҷ���ʽϵ�������Լ��������ϵ�����������������Լ��}

function Int64PolynomialGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
{* ��������һԪ��ϵ������ʽ�������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��
   �緵�� False�������߿ɸɴ���Ϊ���أ������ʽΪ 1}

function Int64PolynomialLeastCommonMultiple(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
{* ��������һԪ��ϵ������ʽ����С����ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��
   �緵�� False�������߿ɸɴ���Ϊ���أ���С����ʽΪ������ˣ����н���}

function Int64PolynomialCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial): Boolean;
{* һԪ��ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ���Res ������ F �� P}

function Int64PolynomialGetValue(const F: TCnInt64Polynomial; X: Int64): Int64;
{* һԪ��ϵ������ʽ��ֵ��Ҳ���Ǽ��� F(x)�����ؼ�����}

procedure Int64PolynomialReduce2(P1, P2: TCnInt64Polynomial);
{* �������һԪ��ϵ������ʽ����Լ�֣�Ҳ�����������أ����������ʽԼ������}

// ===================== ���������µ���ϵ������ʽģ���� ========================

function Int64PolynomialGaloisEqual(const A, B: TCnInt64Polynomial; Prime: Int64): Boolean;
{* ����һԪ��ϵ������ʽ��ģ Prime ���������Ƿ����}

procedure Int64PolynomialGaloisNegate(const P: TCnInt64Polynomial; Prime: Int64);
{* ��һ��һԪ��ϵ������ʽ��������ϵ����ģ Prime ����������}

function Int64PolynomialGaloisAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ����һԪ��ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ����һԪ��ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisMul(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ����һԪ��ϵ������ʽ������ Prime �η�������������ˣ�������� Res �У�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisDiv(const Res: TCnInt64Polynomial;
  const Remain: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ����һԪ��ϵ������ʽ������ Prime �η�����������������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function Int64PolynomialGaloisMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ����һԪ��ϵ������ʽ������ Prime �η��������������࣬�������� Res �У����������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res ������ P �� Divisor��P ������ Divisor}

function Int64PolynomialGaloisPower(const Res, P: TCnInt64Polynomial;
  Exponent: Int64; Prime: Int64; Primitive: TCnInt64Polynomial = nil;
  ExponentHi: Int64 = 0): Boolean;
{* ����һԪ��ϵ������ʽ�� Prime �η����������ϵ� Exponent ���ݣ�Exponent ������ 128 λ��
   Exponent ������������Ǹ�ֵ���Զ�ת�� UInt64
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ���ؼ����Ƿ�ɹ���Res ������ P}

procedure Int64PolynomialGaloisAddWord(const P: TCnInt64Polynomial; N: Int64; Prime: Int64);
{* �� Prime �η����������ϵ�һԪ��ϵ������ʽ�ĳ�ϵ������ N �� mod Prime}

procedure Int64PolynomialGaloisSubWord(const P: TCnInt64Polynomial; N: Int64; Prime: Int64);
{* �� Prime �η����������ϵ�һԪ��ϵ������ʽ�ĳ�ϵ����ȥ N �� mod Prime}

procedure Int64PolynomialGaloisMulWord(const P: TCnInt64Polynomial; N: Int64; Prime: Int64);
{* �� Prime �η����������ϵ�һԪ��ϵ������ʽ����ϵ������ N �� mod Prime}

procedure Int64PolynomialGaloisDivWord(const P: TCnInt64Polynomial; N: Int64; Prime: Int64);
{* �� Prime �η����������ϵ�һԪ��ϵ������ʽ����ϵ������ N��Ҳ���ǳ��� N ����Ԫ�� mod Prime}

function Int64PolynomialGaloisMonic(const P: TCnInt64Polynomial; Prime: Int64): Integer;
{* �� Prime �η����������ϵ�һԪ��ϵ������ʽ����ϵ��ͬ������ʹ����Ϊһ�����س���ֵ}

function Int64PolynomialGaloisGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
{* ��������һԪ��ϵ������ʽ�� Prime �η����������ϵ������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

function Int64PolynomialGaloisLeastCommonMultiple(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
{* ��������һԪ��ϵ������ʽ�� Prime �η����������ϵ���С����ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

procedure Int64PolynomialGaloisExtendedEuclideanGcd(A, B: TCnInt64Polynomial;
  X, Y: TCnInt64Polynomial; Prime: Int64);
{* ��չŷ�����շת������� Prime �η��������������Ԫһ�β�����ϵ������ʽ���� A * X + B * Y = 1 �Ľ�}

procedure Int64PolynomialGaloisModularInverse(const Res: TCnInt64Polynomial;
  X, Modulus: TCnInt64Polynomial; Prime: Int64; CheckGcd: Boolean = False);
{* ��һԪ��ϵ������ʽ X �� Prime �η�������������� Modulus ��ģ������ʽ���ģ��Ԫ����ʽ Y��
   ���� (X * Y) mod M = 1���������뾡����֤ X��Modulus ���أ��� Res ����Ϊ X �� Modulus
   CheckGcd ����Ϊ True ʱ���ڲ����� X��Modulus �Ƿ���}

function Int64PolynomialGaloisCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* �� Prime �η����������Ͻ���һԪ��ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ���Res ������ F �� P}

function Int64PolynomialGaloisGetValue(const F: TCnInt64Polynomial; X, Prime: Int64): Int64;
{* �� Prime �η����������Ͻ���һԪ��ϵ������ʽ��ֵ��Ҳ���Ǽ��� F(x)�����ؼ�����}

function Int64PolynomialGaloisCalcDivisionPolynomial(A, B: Int64; Degree: Int64;
  outDivisionPolynomial: TCnInt64Polynomial; Prime: Int64): Boolean;
{* �ݹ����ָ����Բ������ Prime �η����������ϵ� N �׿ɳ�����ʽ�������Ƿ����ɹ�
   ע�� Degree ������ʱ���ɳ�����ʽ�Ǵ� x �Ķ���ʽ��ż��ʱ���ǣ�x �Ķ���ʽ��* y ����ʽ��
   �����ֻ���� x �Ķ���ʽ���֡�
   ����ο��� F. MORAIN �����²����ϳ��� 2 ���Ƶ�����
  ��COMPUTING THE CARDINALITY OF CM ELLIPTIC CURVES USING TORSION POINTS��}

procedure Int64PolynomialGaloisReduce2(P1, P2: TCnInt64Polynomial; Prime: Int64);
{* �� Prime �η������������������һԪ��ϵ������ʽ����Լ�֣�Ҳ�����������أ����������ʽԼ������}

// ======================== һԪ�����ʽ�������� ===============================

function Int64RationalPolynomialEqual(R1, R2: TCnInt64RationalPolynomial): Boolean;
{* �Ƚ�����һԪ�����ʽ�Ƿ����}

function Int64RationalPolynomialCopy(const Dst: TCnInt64RationalPolynomial;
  const Src: TCnInt64RationalPolynomial): TCnInt64RationalPolynomial;
{* һԪ�����ʽ����}

procedure Int64RationalPolynomialAdd(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial); overload;
{* һԪ�����ʽ��ͨ�ӷ��������������}

procedure Int64RationalPolynomialSub(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial); overload;
{* һԪ�����ʽ��ͨ�����������������}

procedure Int64RationalPolynomialMul(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial); overload;
{* һԪ�����ʽ��ͨ�˷��������������}

procedure Int64RationalPolynomialDiv(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial); overload;
{* һԪ�����ʽ��ͨ�����������������}

procedure Int64RationalPolynomialAddWord(R: TCnInt64RationalPolynomial; N: Int64);
{* һԪ�����ʽ��ͨ�ӷ����� Int64}

procedure Int64RationalPolynomialSubWord(R: TCnInt64RationalPolynomial; N: Int64);
{* һԪ�����ʽ��ͨ������ȥ Int64}

procedure Int64RationalPolynomialMulWord(R: TCnInt64RationalPolynomial; N: Int64);
{* һԪ�����ʽ��ͨ�˷����� Int64}

procedure Int64RationalPolynomialDivWord(R: TCnInt64RationalPolynomial; N: Int64);
{* һԪ�����ʽ��ͨ�������� Int64}

procedure Int64RationalPolynomialAdd(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
{* һԪ�����ʽ����ϵ������ʽ����ͨ�ӷ���RationalResult ������ R1}

procedure Int64RationalPolynomialSub(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
{* һԪ�����ʽ����ϵ������ʽ����ͨ������RationalResult ������ R1}

procedure Int64RationalPolynomialMul(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
{* һԪ�����ʽ����ϵ������ʽ����ͨ�˷���RationalResult ������ R1}

procedure Int64RationalPolynomialDiv(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
{* һԪ�����ʽ����ϵ������ʽ����ͨ������RationalResult ������ R1}

function Int64RationalPolynomialCompose(Res: TCnInt64RationalPolynomial;
  F, P: TCnInt64RationalPolynomial): Boolean; overload;
{* һԪ��ϵ�������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function Int64RationalPolynomialCompose(Res: TCnInt64RationalPolynomial;
  F: TCnInt64RationalPolynomial; P: TCnInt64Polynomial): Boolean; overload;
{* һԪ��ϵ�������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function Int64RationalPolynomialCompose(Res: TCnInt64RationalPolynomial;
  F: TCnInt64Polynomial; P: TCnInt64RationalPolynomial): Boolean; overload;
{* һԪ��ϵ�������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

procedure Int64RationalPolynomialGetValue(const F: TCnInt64RationalPolynomial;
  X: Int64; outResult: TCnRationalNumber);
{* һԪ�����ʽ��ֵ��Ҳ���Ǽ��� F(x)����������� outResult ��}

// ====================== �����ʽ���������ϵ�ģ���� ===========================

function Int64RationalPolynomialGaloisEqual(R1, R2: TCnInt64RationalPolynomial;
  Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* �Ƚ�����ģϵ��һԪ�����ʽ�Ƿ����}

procedure Int64RationalPolynomialGaloisNegate(const P: TCnInt64RationalPolynomial;
  Prime: Int64);
{* ��һ��һԪ�����ʽ������ӵ�����ϵ����ģ Prime ����������}

procedure Int64RationalPolynomialGaloisAdd(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* һԪ�����ʽģϵ���ӷ��������������}

procedure Int64RationalPolynomialGaloisSub(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* һԪ�����ʽģϵ�������������������}

procedure Int64RationalPolynomialGaloisMul(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* һԪ�����ʽģϵ���˷��������������}

procedure Int64RationalPolynomialGaloisDiv(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* һԪ�����ʽģϵ�������������������}

procedure Int64RationalPolynomialGaloisAddWord(R: TCnInt64RationalPolynomial;
  N: Int64; Prime: Int64);
{* һԪ�����ʽģϵ���ӷ����� Int64}

procedure Int64RationalPolynomialGaloisSubWord(R: TCnInt64RationalPolynomial;
  N: Int64; Prime: Int64);
{* һԪ�����ʽģϵ��������ȥ Int64}

procedure Int64RationalPolynomialGaloisMulWord(R: TCnInt64RationalPolynomial;
  N: Int64; Prime: Int64);
{* һԪ�����ʽģϵ���˷����� Int64}

procedure Int64RationalPolynomialGaloisDivWord(R: TCnInt64RationalPolynomial;
  N: Int64; Prime: Int64);
{* һԪ�����ʽģϵ���������� Int64}

procedure Int64RationalPolynomialGaloisAdd(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* һԪ�����ʽ����ϵ������ʽ��ģϵ���ӷ���RationalResult ������ R1}

procedure Int64RationalPolynomialGaloisSub(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* һԪ�����ʽ����ϵ������ʽ��ģϵ��������RationalResult ������ R1}

procedure Int64RationalPolynomialGaloisMul(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* һԪ�����ʽ����ϵ������ʽ��ģϵ���˷���RationalResult ������ R1}

procedure Int64RationalPolynomialGaloisDiv(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* һԪ�����ʽ����ϵ������ʽ��ģϵ��������RationalResult ������ R1}

function Int64RationalPolynomialGaloisCompose(Res: TCnInt64RationalPolynomial;
  F, P: TCnInt64RationalPolynomial; Prime: Int64;
  Primitive: TCnInt64Polynomial = nil): Boolean; overload;
{* һԪ�����ʽģϵ��������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function Int64RationalPolynomialGaloisCompose(Res: TCnInt64RationalPolynomial;
  F: TCnInt64RationalPolynomial; P: TCnInt64Polynomial; Prime: Int64;
  Primitive: TCnInt64Polynomial = nil): Boolean; overload;
{* һԪ�����ʽģϵ��������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function Int64RationalPolynomialGaloisCompose(Res: TCnInt64RationalPolynomial;
  F: TCnInt64Polynomial; P: TCnInt64RationalPolynomial; Prime: Int64;
  Primitive: TCnInt64Polynomial = nil): Boolean; overload;
{* һԪ�����ʽģϵ��������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function Int64RationalPolynomialGaloisGetValue(const F: TCnInt64RationalPolynomial;
  X: Int64; Prime: Int64): Int64;
{* һԪ�����ʽģϵ����ֵ��Ҳ����ģ���� F(x)�������ó˷�ģ��Ԫ��ʾ}

// ===================== һԪ����ϵ������ʽ�������� ============================

function BigNumberPolynomialNew: TCnBigNumberPolynomial;
{* ����һ����̬�����һԪ����ϵ������ʽ���󣬵�ͬ�� TCnBigNumberPolynomial.Create}

procedure BigNumberPolynomialFree(const P: TCnBigNumberPolynomial);
{* �ͷ�һ��һԪ����ϵ������ʽ���󣬵�ͬ�� TCnBigNumberPolynomial.Free}

function BigNumberPolynomialDuplicate(const P: TCnBigNumberPolynomial): TCnBigNumberPolynomial;
{* ��һ��һԪ����ϵ������ʽ�����¡һ���¶���}

function BigNumberPolynomialCopy(const Dst: TCnBigNumberPolynomial;
  const Src: TCnBigNumberPolynomial): TCnBigNumberPolynomial;
{* ����һ��һԪ����ϵ������ʽ���󣬳ɹ����� Dst}

function BigNumberPolynomialToString(const P: TCnBigNumberPolynomial;
  const VarName: string = 'X'): string;
{* ��һ������ϵ������ʽ����ת���ַ�����δ֪��Ĭ���� X ��ʾ}

function BigNumberPolynomialSetString(const P: TCnBigNumberPolynomial;
  const Str: string; const VarName: Char = 'X'): Boolean;
{* ���ַ�����ʽ��һԪ����ϵ������ʽ��ֵ����ϵ������ʽ���󣬷����Ƿ�ֵ�ɹ�}

function BigNumberPolynomialIsZero(const P: TCnBigNumberPolynomial): Boolean;
{* �ж�һ��һԪ����ϵ������ʽ�����Ƿ�Ϊ 0}

procedure BigNumberPolynomialSetZero(const P: TCnBigNumberPolynomial);
{* ��һ��һԪ����ϵ������ʽ������Ϊ 0}

function BigNumberPolynomialIsOne(const P: TCnBigNumberPolynomial): Boolean;
{* �ж�һ��һԪ����ϵ������ʽ�����Ƿ�Ϊ 1}

procedure BigNumberPolynomialSetOne(const P: TCnBigNumberPolynomial);
{* ��һ��һԪ����ϵ������ʽ������Ϊ 1}

function BigNumberPolynomialIsNegOne(const P: TCnBigNumberPolynomial): Boolean;
{* �ж�һ��һԪ����ϵ������ʽ�����Ƿ�Ϊ -1}

procedure BigNumberPolynomialNegate(const P: TCnBigNumberPolynomial);
{* ��һ��һԪ����ϵ������ʽ��������ϵ����}

function BigNumberPolynomialIsMonic(const P: TCnBigNumberPolynomial): Boolean;
{* �ж�һ��һԪ����ϵ������ʽ�Ƿ�����һ����ʽ��Ҳ�����ж���ߴ�ϵ���Ƿ�Ϊ 1}

procedure BigNumberPolynomialShiftLeft(const P: TCnBigNumberPolynomial; N: Integer);
{* ��һ��һԪ����ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N}

procedure BigNumberPolynomialShiftRight(const P: TCnBigNumberPolynomial; N: Integer);
{* ��һ��һԪ����ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N��С�� 0 �ĺ�����}

function BigNumberPolynomialEqual(const A, B: TCnBigNumberPolynomial): Boolean;
{* �ж�����ϵ������ʽÿ��ϵ���Ƿ��Ӧ��ȣ����򷵻� True}

// ======================== һԪ����ϵ������ʽ��ͨ���� =============================

procedure BigNumberPolynomialAddWord(const P: TCnBigNumberPolynomial; N: LongWord);
{* ��һ��һԪ����ϵ������ʽ����ĳ�ϵ������ N}

procedure BigNumberPolynomialSubWord(const P: TCnBigNumberPolynomial; N: LongWord);
{* ��һ��һԪ����ϵ������ʽ����ĳ�ϵ����ȥ N}

procedure BigNumberPolynomialMulWord(const P: TCnBigNumberPolynomial; N: LongWord);
{* ��һ��һԪ����ϵ������ʽ����ĸ���ϵ�������� N}

procedure BigNumberPolynomialDivWord(const P: TCnBigNumberPolynomial; N: LongWord);
{* ��һ��һԪ����ϵ������ʽ����ĸ���ϵ�������� N���粻��������ȡ��}

procedure BigNumberPolynomialNonNegativeModWord(const P: TCnBigNumberPolynomial; N: LongWord);
{* ��һ��һԪ����ϵ������ʽ����ĸ���ϵ������ N �Ǹ����࣬��������������}

procedure BigNumberPolynomialAddBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
{* ��һ��һԪ����ϵ������ʽ����ĳ�ϵ�����ϴ��� N}

procedure BigNumberPolynomialSubBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
{* ��һ��һԪ����ϵ������ʽ����ĳ�ϵ����ȥ���� N}

procedure BigNumberPolynomialMulBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
{* ��һ��һԪ����ϵ������ʽ����ĸ���ϵ�������Դ��� N}

procedure BigNumberPolynomialDivBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
{* ��һ��һԪ����ϵ������ʽ����ĸ���ϵ�������Դ��� N���粻��������ȡ��}

procedure BigNumberPolynomialNonNegativeModBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
{* ��һ��һԪ����ϵ������ʽ����ĸ���ϵ�����Դ��� N �Ǹ�����}

function BigNumberPolynomialAdd(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial): Boolean;
{* ����һԪ����ϵ������ʽ������ӣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialSub(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial): Boolean;
{* ����һԪ����ϵ������ʽ���������������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialMul(const Res: TCnBigNumberPolynomial; P1: TCnBigNumberPolynomial;
  P2: TCnBigNumberPolynomial): Boolean;
{* ����һԪ����ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialDiv(const Res: TCnBigNumberPolynomial; const Remain: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; const Divisor: TCnBigNumberPolynomial): Boolean;
{* ����һԪ����ϵ������ʽ����������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ�᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function BigNumberPolynomialMod(const Res: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial): Boolean;
{* ����һԪ����ϵ������ʽ�������࣬�������� Res �У����������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ�᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ��
   Res ������ P �� Divisor��P ������ Divisor}

function BigNumberPolynomialPower(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; Exponent: TCnBigNumber): Boolean;
{* ����һԪ����ϵ������ʽ�� Exponent ���ݣ����ؼ����Ƿ�ɹ���Res ������ P}

procedure BigNumberPolynomialReduce(const P: TCnBigNumberPolynomial);
{* ����һԪ����ϵ������ʽϵ����Ҳ�����Ҷ���ʽϵ�������Լ��������ϵ��������}

function BigNumberPolynomialGreatestCommonDivisor(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial): Boolean;
{* ��������һԪ����ϵ������ʽ�������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��
   �緵�� False�������߿ɸɴ���Ϊ���أ������ʽΪ 1}

function BigNumberPolynomialLeastCommonMultiple(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial): Boolean;
{* ��������һԪ����ϵ������ʽ����С����ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��
   �緵�� False�������߿ɸɴ���Ϊ���أ���С����ʽΪ������ˣ����н���}

function BigNumberPolynomialCompose(const Res: TCnBigNumberPolynomial;
  const F, P: TCnBigNumberPolynomial): Boolean;
{* һԪ����ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ���Res ������ F �� P}

procedure BigNumberPolynomialGetValue(Res: TCnBigNumber; F: TCnBigNumberPolynomial;
  X: TCnBigNumber);
{* һԪ����ϵ������ʽ��ֵ��Ҳ���Ǽ��� F(x)�����ؼ����Ƿ�ɹ���Res ������ X}

procedure BigNumberPolynomialReduce2(P1, P2: TCnBigNumberPolynomial);
{* �������һԪ����ϵ������ʽ����Լ�֣�Ҳ�����������أ����������ʽԼ������}

// ===================== ���������µ���ϵ������ʽģ���� ========================

function BigNumberPolynomialGaloisEqual(const A, B: TCnBigNumberPolynomial;
  Prime: TCnBigNumber): Boolean;
{* ����һԪ����ϵ������ʽ��ģ Prime ���������Ƿ����}

procedure BigNumberPolynomialGaloisNegate(const P: TCnBigNumberPolynomial;
  Prime: TCnBigNumber);
{* ��һ��һԪ����ϵ������ʽ��������ϵ����ģ Prime ����������}

function BigNumberPolynomialGaloisAdd(const Res: TCnBigNumberPolynomial;
  const P1: TCnBigNumberPolynomial; const P2: TCnBigNumberPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ����һԪ����ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialGaloisSub(const Res: TCnBigNumberPolynomial;
  const P1: TCnBigNumberPolynomial; const P2: TCnBigNumberPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ����һԪ����ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialGaloisMul(const Res: TCnBigNumberPolynomial;
  const P1: TCnBigNumberPolynomial; const P2: TCnBigNumberPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ����һԪ����ϵ������ʽ������ Prime �η�������������ˣ�������� Res �У�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialGaloisDiv(const Res: TCnBigNumberPolynomial;
  const Remain: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ����һԪ����ϵ������ʽ������ Prime �η�����������������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function BigNumberPolynomialGaloisMod(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; const Divisor: TCnBigNumberPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ����һԪ����ϵ������ʽ������ Prime �η��������������࣬�������� Res �У����������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res ������ P �� Divisor��P ������ Divisor}

function BigNumberPolynomialGaloisPower(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; Exponent: TCnBigNumber; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial = nil): Boolean; overload;
{* ����һԪ����ϵ������ʽ�� Prime �η����������ϵ� Exponent ���ݣ�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ���ؼ����Ƿ�ɹ���Res ������ P}

function BigNumberPolynomialGaloisPower(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; Exponent: LongWord; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial = nil): Boolean; overload;
{* ����һԪ����ϵ������ʽ�� Prime �η����������ϵ� Exponent ���ݣ�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ���ؼ����Ƿ�ɹ���Res ������ P}

function BigNumberPolynomialGaloisAddWord(const P: TCnBigNumberPolynomial;
  N: LongWord; Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������ϵ�һԪ����ϵ������ʽ�ĳ�ϵ������ N �� mod Prime}

function BigNumberPolynomialGaloisSubWord(const P: TCnBigNumberPolynomial;
  N: LongWord; Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������ϵ�һԪ����ϵ������ʽ�ĳ�ϵ����ȥ N �� mod Prime}

function BigNumberPolynomialGaloisMulWord(const P: TCnBigNumberPolynomial;
  N: LongWord; Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������ϵ�һԪ����ϵ������ʽ����ϵ������ N �� mod Prime}

function BigNumberPolynomialGaloisDivWord(const P: TCnBigNumberPolynomial;
  N: LongWord; Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ������ N��Ҳ���ǳ��� N ����Ԫ�� mod Prime}

procedure BigNumberPolynomialGaloisAddBigNumber(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber);
{* �� Prime �η����������ϵ�һԪ����ϵ������ʽ�ĳ�ϵ������ N �� mod Prime}

procedure BigNumberPolynomialGaloisSubBigNumber(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber);
{* �� Prime �η����������ϵ�һԪ����ϵ������ʽ�ĳ�ϵ����ȥ N �� mod Prime}

procedure BigNumberPolynomialGaloisMulBigNumber(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber);
{* �� Prime �η����������ϵ�һԪ����ϵ������ʽ����ϵ������ N �� mod Prime}

procedure BigNumberPolynomialGaloisDivBigNumber(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber);
{* �� Prime �η����������ϵ�һԪ����ϵ������ʽ����ϵ������ N��Ҳ���ǳ��� N ����Ԫ�� mod Prime}

procedure BigNumberPolynomialGaloisMonic(const P: TCnBigNumberPolynomial; Prime: TCnBigNumber);
{* �� Prime �η����������ϵ�һԪ����ϵ������ʽ����ϵ��ͬ������ʹ����Ϊһ}

function BigNumberPolynomialGaloisGreatestCommonDivisor(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
{* ��������һԪ����ϵ������ʽ�� Prime �η����������ϵ������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

function BigNumberPolynomialGaloisLeastCommonMultiple(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
{* ��������һԪ����ϵ������ʽ�� Prime �η����������ϵ���С����ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

procedure BigNumberPolynomialGaloisExtendedEuclideanGcd(A, B: TCnBigNumberPolynomial;
  X, Y: TCnBigNumberPolynomial; Prime: TCnBigNumber);
{* ��չŷ�����շת������� Prime �η��������������Ԫһ�β���һԪ����ϵ������ʽ���� A * X + B * Y = 1 �Ľ�}

procedure BigNumberPolynomialGaloisModularInverse(const Res: TCnBigNumberPolynomial;
  X, Modulus: TCnBigNumberPolynomial; Prime: TCnBigNumber; CheckGcd: Boolean = False);
{* ��һԪ����ϵ������ʽ X �� Prime �η�������������� Modulus ��ģ������ʽ���ģ��Ԫ����ʽ Y��
   ���� (X * Y) mod M = 1���������뾡����֤ X��Modulus ���أ��� Res ����Ϊ X �� Modulus
   CheckGcd ����Ϊ True ʱ���ڲ����� X��Modulus �Ƿ���}

function BigNumberPolynomialGaloisCompose(const Res: TCnBigNumberPolynomial;
  const F, P: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* �� Prime �η����������Ͻ���һԪ����ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ���Res ������ F �� P}

function BigNumberPolynomialGaloisGetValue(Res: TCnBigNumber;
  const F: TCnBigNumberPolynomial; X, Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������Ͻ���һԪ����ϵ������ʽ��ֵ��Ҳ���Ǽ��� F(x)�����ؼ����Ƿ�ɹ�}

function BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B: Integer; Degree: Integer;
  outDivisionPolynomial: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean; overload;
{* �ݹ����ָ����Բ������ Prime �η����������ϵ� N �׿ɳ�����ʽ�������Ƿ����ɹ�
   ע�� Degree ������ʱ���ɳ�����ʽ�Ǵ� x �Ķ���ʽ��ż��ʱ���ǣ�x �Ķ���ʽ��* y ����ʽ��
   �����ֻ���� x �Ķ���ʽ���֡�
   ���� A B �� 32 λ�з�������}

function BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B: TCnBigNumber; Degree: Integer;
  outDivisionPolynomial: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean; overload;
{* �ݹ����ָ����Բ������ Prime �η����������ϵ� N �׿ɳ�����ʽ�������Ƿ����ɹ�
   ע�� Degree ������ʱ���ɳ�����ʽ�Ǵ� x �Ķ���ʽ��ż��ʱ���ǣ�x �Ķ���ʽ��* y ����ʽ��
   �����ֻ���� x �Ķ���ʽ���֡�
   ����ο��� F. MORAIN �����²����ϳ��� 2 ���Ƶ�����
  ��COMPUTING THE CARDINALITY OF CM ELLIPTIC CURVES USING TORSION POINTS��}

procedure BigNumberPolynomialGaloisReduce2(P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber);
{* �� Prime �η������������������һԪ����ϵ������ʽ����Լ�֣�Ҳ�����������أ����������ʽԼ������}

// ===================== һԪ����ϵ�������ʽ�������� ==========================

function BigNumberRationalPolynomialEqual(R1, R2: TCnBigNumberRationalPolynomial): Boolean;
{* �Ƚ�����һԪ����ϵ�������ʽ�Ƿ����}

function BigNumberRationalPolynomialCopy(const Dst: TCnBigNumberRationalPolynomial;
  const Src: TCnBigNumberRationalPolynomial): TCnBigNumberRationalPolynomial;
{* һԪ����ϵ�������ʽ����}

procedure BigNumberRationalPolynomialAdd(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
{* һԪ����ϵ�������ʽ��ͨ�ӷ��������������}

procedure BigNumberRationalPolynomialSub(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
{* һԪ����ϵ�������ʽ��ͨ�����������������}

procedure BigNumberRationalPolynomialMul(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
{* һԪ����ϵ�������ʽ��ͨ�˷��������������}

procedure BigNumberRationalPolynomialDiv(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
{* һԪ����ϵ�������ʽ��ͨ�����������������}

procedure BigNumberRationalPolynomialAddBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber);
{* һԪ����ϵ�������ʽ��ͨ�ӷ�������һ������}

procedure BigNumberRationalPolynomialSubBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber);
{* һԪ����ϵ�������ʽ��ͨ��������ȥһ������}

procedure BigNumberRationalPolynomialMulBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber);
{* һԪ����ϵ�������ʽ��ͨ�˷�������һ������}

procedure BigNumberRationalPolynomialDivBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber);
{* һԪ����ϵ�������ʽ��ͨ����������һ������}

procedure BigNumberRationalPolynomialAdd(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
{* һԪ����ϵ�������ʽ��һԪ����ϵ������ʽ����ͨ�ӷ���RationalResult ������ R1}

procedure BigNumberRationalPolynomialSub(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
{* һԪ����ϵ�������ʽ��һԪ����ϵ������ʽ����ͨ������RationalResult ������ R1}

procedure BigNumberRationalPolynomialMul(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
{* һԪ����ϵ�������ʽ��һԪ����ϵ������ʽ����ͨ�˷���RationalResult ������ R1}

procedure BigNumberRationalPolynomialDiv(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
{* һԪ����ϵ�������ʽ����ϵ������ʽ����ͨ������RationalResult ������ R1}

function BigNumberRationalPolynomialCompose(Res: TCnBigNumberRationalPolynomial;
  F, P: TCnBigNumberRationalPolynomial): Boolean; overload;
{* һԪ����ϵ�������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function BigNumberRationalPolynomialCompose(Res: TCnBigNumberRationalPolynomial;
  F: TCnBigNumberRationalPolynomial; P: TCnBigNumberPolynomial): Boolean; overload;
{* һԪ����ϵ�������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function BigNumberRationalPolynomialCompose(Res: TCnBigNumberRationalPolynomial;
  F: TCnBigNumberPolynomial; P: TCnBigNumberRationalPolynomial): Boolean; overload;
{* ��ϵ�������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

procedure BigNumberRationalPolynomialGetValue(const F: TCnBigNumberRationalPolynomial;
  X: TCnBigNumber; outResult: TCnBigRational);
{* һԪ����ϵ�������ʽ��ֵ��Ҳ���Ǽ��� F(x)����������� outResult ��}

// ================== һԪ����ϵ�������ʽ���������ϵ�ģ���� ===================

function BigNumberRationalPolynomialGaloisEqual(R1, R2: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* �Ƚ�����һԪ����ϵ��ģϵ�������ʽ�Ƿ����}

procedure BigNumberRationalPolynomialGaloisNegate(const P: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber);
{* ��һ��һԪ����ϵ�������ʽ������ӵ�����ϵ����ģ Prime ����������}

procedure BigNumberRationalPolynomialGaloisAdd(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* һԪ����ϵ�������ʽģϵ���ӷ��������������}

procedure BigNumberRationalPolynomialGaloisSub(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* һԪ����ϵ�������ʽģϵ�������������������}

procedure BigNumberRationalPolynomialGaloisMul(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* һԪ����ϵ�������ʽģϵ���˷��������������}

procedure BigNumberRationalPolynomialGaloisDiv(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* һԪ����ϵ�������ʽģϵ�������������������}

procedure BigNumberRationalPolynomialGaloisAddBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber; Prime: TCnBigNumber);
{* һԪ����ϵ�������ʽģϵ���ӷ�������һ������}

procedure BigNumberRationalPolynomialGaloisSubBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber; Prime: TCnBigNumber);
{* һԪ����ϵ�������ʽģϵ����������ȥһ������}

procedure BigNumberRationalPolynomialGaloisMulBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber; Prime: TCnBigNumber);
{* һԪ����ϵ�������ʽģϵ���˷�������һ������}

procedure BigNumberRationalPolynomialGaloisDivBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber; Prime: TCnBigNumber);
{* һԪ����ϵ�������ʽģϵ������������һ������}

procedure BigNumberRationalPolynomialGaloisAdd(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber); overload;
{* һԪ����ϵ�������ʽ��һԪ����ϵ������ʽ��ģϵ���ӷ���RationalResult ������ R1}

procedure BigNumberRationalPolynomialGaloisSub(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber); overload;
{* һԪ����ϵ�������ʽ��һԪ����ϵ������ʽ��ģϵ��������RationalResult ������ R1}

procedure BigNumberRationalPolynomialGaloisMul(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber); overload;
{* һԪ����ϵ�������ʽ��һԪ����ϵ������ʽ��ģϵ���˷���RationalResult ������ R1}

procedure BigNumberRationalPolynomialGaloisDiv(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber); overload;
{* һԪ����ϵ�������ʽ��һԪ����ϵ������ʽ��ģϵ��������RationalResult ������ R1}

function BigNumberRationalPolynomialGaloisCompose(Res: TCnBigNumberRationalPolynomial;
  F, P: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial = nil): Boolean; overload;
{* �����ʽģϵ��������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function BigNumberRationalPolynomialGaloisCompose(Res: TCnBigNumberRationalPolynomial;
  F: TCnBigNumberRationalPolynomial; P: TCnBigNumberPolynomial; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial = nil): Boolean; overload;
{* �����ʽģϵ��������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

function BigNumberRationalPolynomialGaloisCompose(Res: TCnBigNumberRationalPolynomial;
  F: TCnBigNumberPolynomial; P: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial = nil): Boolean; overload;
{* �����ʽģϵ��������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ�}

procedure BigNumberRationalPolynomialGaloisGetValue(Res: TCnBigNumber;
  const F: TCnBigNumberRationalPolynomial; X: TCnBigNumber; Prime: TCnBigNumber);
{* һԪ����ϵ�������ʽģϵ����ֵ��Ҳ����ģ���� F(x)�������ó˷�ģ��Ԫ��ʾ}

// =============================================================================
//
//                            ��Ԫ��ϵ������ʽ
//
// =============================================================================

{
   FXs TObjectList
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  | X^n   �� Y ϵ�� List  | -> | X^n*Y^0 ��ϵ��  |X^n*Y^1 ��ϵ��   | ......
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  | X^n-1 �� Y ϵ�� List  | -> | X^n-1*Y^0 ��ϵ��|X^n-1*Y^1 ��ϵ�� | ......
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |......                 | -> |
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  | X^0   �� Y ϵ�� List  | -> | X^0*Y^0 ��ϵ��  | X^0*Y^1 ��ϵ��  | ......
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

}
type
  TCnInt64BiPolynomial = class
  {* ��Ԫ��ϵ������ʽ���ڲ�ʵ�ַ�ϡ�裬���һ������ױ��ڴ�}
  private
    FXs: TObjectList; // Ԫ��Ϊ TCnInt64List���洢�� X ���ݵ�ÿһ����ͬ�� Y ���ݵ�ϵ��
    procedure EnsureDegrees(XDegree, YDegree: Integer);
    {* ȷ�� XDegree, YDegree ��Ԫ�ش���}
    function GetMaxXDegree: Integer;
    function GetMaxYDegree: Integer;
    procedure SetMaxXDegree(const Value: Integer);
    procedure SetMaxYDegree(const Value: Integer);
    function GetYFactorsList(Index: Integer): TCnInt64List;
    function GetSafeValue(XDegree, YDegree: Integer): Int64;
    procedure SetSafeValue(XDegree, YDegree: Integer; const Value: Int64);
  protected
    function CompactYDegree(YList: TCnInt64List): Boolean;
    {* ȥ��һ�� Y ϵ���ߴ������ȫ 0 �򷵻� True}
    property YFactorsList[Index: Integer]: TCnInt64List read GetYFactorsList;
    {* ��װ�Ķ� X �� Index ����� Y ϵ���б�}
    procedure Clear;
    {* �ڲ�����������ݣ�ֻ�� FXs[0] ��һ�� List��һ�㲻����ʹ��}
  public
    constructor Create(XDegree: Integer = 0; YDegree: Integer = 0);
    {* ���캯�������� X �� Y ����ߴ�������Ĭ��Ϊ 0���Ժ��ٲ���}
    destructor Destroy; override;

    procedure SetYCoefficentsFromPolynomial(XDegree: Integer; PY: TCnInt64Polynomial);
    {* ����ض������� X����һԪ�� Y ����ʽ��һ���������� Y ��ϵ��}
    procedure SetYCoefficents(XDegree: Integer; LowToHighYCoefficients: array of const);
    {* ����ض������� X��һ���������� Y �ӵ͵��ߵ�ϵ��}
    procedure SetXCoefficents(YDegree: Integer; LowToHighXCoefficients: array of const);
    {* ����ض������� Y��һ���������� X �ӵ͵��ߵ�ϵ��}
    procedure SetXYCoefficent(XDegree, YDegree: Integer; ACoefficient: Int64);
    {* ����ض������� X �� Y��������ϵ��}

    procedure CorrectTop;
    {* �޳��ߴε� 0 ϵ��}
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ʽת���ַ���}
    procedure SetString(const Poly: string);
    {* ������ʽ�ַ���ת��Ϊ�����������}
    function IsZero: Boolean;
    {* �����Ƿ�Ϊ 0}
    procedure SetZero;
    {* ��Ϊ 0}
    procedure SetOne;
    {* ��Ϊ 1}
    procedure Negate;
    {* ����ϵ����}
    function IsMonicX: Boolean;
    {* �Ƿ��ǹ��� X ����һ����ʽ}
    procedure Transpose;
    {* ת�ã�Ҳ���ǻ��� X Y Ԫ}

    property MaxXDegree: Integer read GetMaxXDegree write SetMaxXDegree;
    {* X Ԫ����ߴ�����0 ��ʼ������ Count ����ֻ���� Integer}
    property MaxYDegree: Integer read GetMaxYDegree write SetMaxYDegree;
    {* X Ԫ����ߴ�����0 ��ʼ������ Count ����ֻ���� Integer}

    property SafeValue[XDegree, YDegree: Integer]: Int64 read GetSafeValue write SetSafeValue;
    {* ��ȫ�Ķ�дϵ����������������ʱ���� 0��д������ʱ�Զ���չ}
  end;

  TCnInt64BiPolynomialPool = class(TCnMathObjectPool)
  {* ��Ԫ��ϵ������ʽ��ʵ���࣬����ʹ�õ���Ԫ��ϵ������ʽ�ĵط����д�����Ԫ��ϵ������ʽ��}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnInt64BiPolynomial; reintroduce;
    procedure Recycle(Poly: TCnInt64BiPolynomial); reintroduce;
  end;

function Int64BiPolynomialNew: TCnInt64BiPolynomial;
{* ����һ����Ԫ��ϵ������ʽ���󣬵�ͬ�� TCnInt64BiPolynomial.Create}

procedure Int64BiPolynomialFree(const P: TCnInt64BiPolynomial);
{* �ͷ�һ����Ԫ��ϵ������ʽ���󣬵�ͬ�� TCnInt64BiPolynomial.Free}

function Int64BiPolynomialDuplicate(const P: TCnInt64BiPolynomial): TCnInt64BiPolynomial;
{* ��һ����Ԫ��ϵ������ʽ�����¡һ���¶���}

function Int64BiPolynomialCopy(const Dst: TCnInt64BiPolynomial;
  const Src: TCnInt64BiPolynomial): TCnInt64BiPolynomial;
{* ����һ����Ԫ��ϵ������ʽ���󣬳ɹ����� Dst}

function Int64BiPolynomialCopyFromX(const Dst: TCnInt64BiPolynomial;
  const SrcX: TCnInt64Polynomial): TCnInt64BiPolynomial;
{* ��һԪ X ��ϵ������ʽ�и���һ����Ԫ��ϵ������ʽ���󣬳ɹ����� Dst}

function Int64BiPolynomialCopyFromY(const Dst: TCnInt64BiPolynomial;
  const SrcY: TCnInt64Polynomial): TCnInt64BiPolynomial;
{* ��һԪ Y ��ϵ������ʽ�и���һ����Ԫ��ϵ������ʽ���󣬳ɹ����� Dst}

function Int64BiPolynomialToString(const P: TCnInt64BiPolynomial;
  const Var1Name: Char = 'X'; const Var2Name: Char = 'Y'): string;
{* ��һ����Ԫ��ϵ������ʽ����ת���ַ�����δ֪��Ĭ���� X �� Y ��ʾ}

function Int64BiPolynomialSetString(const P: TCnInt64BiPolynomial;
  const Str: string; const Var1Name: Char = 'X'; const Var2Name: Char = 'Y'): Boolean;
{* ���ַ�����ʽ�Ķ�Ԫ��ϵ������ʽ��ֵ����Ԫ��ϵ������ʽ���󣬷����Ƿ�ֵ�ɹ�}

function Int64BiPolynomialIsZero(const P: TCnInt64BiPolynomial): Boolean;
{* �ж�һ����Ԫ��ϵ������ʽ�����Ƿ�Ϊ 0}

procedure Int64BiPolynomialSetZero(const P: TCnInt64BiPolynomial);
{* ��һ����Ԫ��ϵ������ʽ������Ϊ 0}

procedure Int64BiPolynomialSetOne(const P: TCnInt64BiPolynomial);
{* ��һ����Ԫ��ϵ������ʽ������Ϊ 1}

procedure Int64BiPolynomialNegate(const P: TCnInt64BiPolynomial);
{* ��һ����Ԫ��ϵ������ʽ��������ϵ����}

function Int64BiPolynomialIsMonicX(const P: TCnInt64BiPolynomial): Boolean;
{* �ж�һ����Ԫ��ϵ������ʽ�Ƿ��ǹ��� X ����һ����ʽ��Ҳ�����ж� X ��ߴε�ϵ���Ƿ�Ϊ 1}

procedure Int64BiPolynomialShiftLeftX(const P: TCnInt64BiPolynomial; N: Integer);
{* ��һ����Ԫ��ϵ������ʽ����� X ���� N �Σ�Ҳ���� X ����ָ������ N}

procedure Int64BiPolynomialShiftRightX(const P: TCnInt64BiPolynomial; N: Integer);
{* ��һ����Ԫ��ϵ������ʽ����� X ���� N �Σ�Ҳ���� X ����ָ������ N��С�� 0 �ĺ�����}

function Int64BiPolynomialEqual(const A, B: TCnInt64BiPolynomial): Boolean;
{* �ж�����Ԫ��ϵ������ʽÿ��ϵ���Ƿ��Ӧ��ȣ����򷵻� True}

// ====================== ��Ԫ��ϵ������ʽ��ͨ���� =============================

procedure Int64BiPolynomialAddWord(const P: TCnInt64BiPolynomial; N: Int64);
{* ��һ����Ԫ��ϵ������ʽ����ĸ���ϵ������ N}

procedure Int64BiPolynomialSubWord(const P: TCnInt64BiPolynomial; N: Int64);
{* ��һ����Ԫ��ϵ������ʽ����ĸ���ϵ����ȥ N}

procedure Int64BiPolynomialMulWord(const P: TCnInt64BiPolynomial; N: Int64);
{* ��һ����Ԫ��ϵ������ʽ����ĸ���ϵ�������� N}

procedure Int64BiPolynomialDivWord(const P: TCnInt64BiPolynomial; N: Int64);
{* ��һ����Ԫ��ϵ������ʽ����ĸ���ϵ�������� N���粻��������ȡ��}

procedure Int64BiPolynomialNonNegativeModWord(const P: TCnInt64BiPolynomial; N: Int64);
{* ��һ����Ԫ��ϵ������ʽ����ĸ���ϵ������ N �Ǹ����࣬��������������}

function Int64BiPolynomialAdd(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial): Boolean;
{* ������Ԫ��ϵ������ʽ������ӣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64BiPolynomialSub(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial): Boolean;
{* ������Ԫ��ϵ������ʽ���������������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64BiPolynomialMul(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  P2: TCnInt64BiPolynomial): Boolean;
{* ������Ԫ��ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64BiPolynomialMulX(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  PX: TCnInt64Polynomial): Boolean;
{* һ����Ԫ��ϵ������ʽ������һ�� X ��һԪ��ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���Res ������ P1}

function Int64BiPolynomialMulY(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  PY: TCnInt64Polynomial): Boolean;
{* һ����Ԫ��ϵ������ʽ������һ�� Y ��һԪ��ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���Res ������ P1}

function Int64BiPolynomialDivX(const Res: TCnInt64BiPolynomial; const Remain: TCnInt64BiPolynomial;
  const P: TCnInt64BiPolynomial; const Divisor: TCnInt64BiPolynomial): Boolean;
{* ������Ԫ��ϵ������ʽ������ X Ϊ��������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   ע�� Divisor ������ X ����һ����ʽ������᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function Int64BiPolynomialModX(const Res: TCnInt64BiPolynomial;
  const P: TCnInt64BiPolynomial; const Divisor: TCnInt64BiPolynomial): Boolean;
{* ������Ԫ��ϵ������ʽ������ X Ϊ�����࣬�������� Res �У����������Ƿ�ɹ���
   ע�� Divisor ������ X ����һ����ʽ������᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ
   Res ������ P �� Divisor��P ������ Divisor}

function Int64BiPolynomialPower(const Res: TCnInt64BiPolynomial;
  const P: TCnInt64BiPolynomial; Exponent: Int64): Boolean;
{* �����Ԫ��ϵ������ʽ�� Exponent ���ݣ�������ϵ����������⣬���ؼ����Ƿ�ɹ���Res ������ P}

function Int64BiPolynomialEvaluateByY(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; YValue: Int64): Boolean;
{* ��һ���� Y ֵ�����Ԫ��ϵ������ʽ���õ�ֻ���� X ��һԪ��ϵ������ʽ}

function Int64BiPolynomialEvaluateByX(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; XValue: Int64): Boolean;
{* ��һ���� X ֵ�����Ԫ��ϵ������ʽ���õ�ֻ���� Y ��һԪ��ϵ������ʽ}

procedure Int64BiPolynomialTranspose(const Dst, Src: TCnInt64BiPolynomial);
{* ����Ԫ��ϵ������ʽ�� X Y Ԫ��������һ����Ԫ��ϵ������ʽ�����У�Src �� Dst ������ͬ}

procedure Int64BiPolynomialExtractYByX(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; XDegree: Int64);
{* ����Ԫ��ϵ������ʽ�� X �η�ϵ����ȡ�����ŵ�һ�� Y ��һԪ����ʽ��}

procedure Int64BiPolynomialExtractXByY(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; YDegree: Int64);
{* ����Ԫ��ϵ������ʽ�� X �η�ϵ����ȡ�����ŵ�һ�� Y ��һԪ����ʽ��}

// =================== ��Ԫ��ϵ������ʽʽ���������ϵ�ģ���� ====================

function Int64BiPolynomialGaloisEqual(const A, B: TCnInt64BiPolynomial; Prime: Int64): Boolean;
{* ������Ԫ��ϵ������ʽ��ģ Prime ���������Ƿ����}

procedure Int64BiPolynomialGaloisNegate(const P: TCnInt64BiPolynomial; Prime: Int64);
{* ��һ����Ԫ��ϵ������ʽ��������ϵ����ģ Prime ����������}

function Int64BiPolynomialGaloisAdd(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial = nil): Boolean;
{* ������Ԫ��ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64BiPolynomialGaloisSub(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial = nil): Boolean;
{* ������Ԫ��ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64BiPolynomialGaloisMul(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial = nil): Boolean;
{* ������Ԫ��ϵ������ʽ������ Prime �η�������������ˣ�������� Res �У�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64BiPolynomialGaloisMulX(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  PX: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial = nil): Boolean;
{* һ����Ԫ��ϵ������ʽ������һ�� X ��һԪ��ϵ������ʽ������ Prime �η�������������ˣ�
  ������� Res �У���������Ƿ�ɹ���Res ������ P1}

function Int64BiPolynomialGaloisMulY(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  PY: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial = nil): Boolean;
{* һ����Ԫ��ϵ������ʽ������һ�� Y ��һԪ��ϵ������ʽ������ Prime �η�������������ˣ�
  ������� Res �У���������Ƿ�ɹ���Res ������ P1}

function Int64BiPolynomialGaloisDivX(const Res: TCnInt64BiPolynomial;
  const Remain: TCnInt64BiPolynomial; const P: TCnInt64BiPolynomial;
  const Divisor: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial = nil): Boolean;
{* ������Ԫ��ϵ������ʽ������ Prime �η�����������������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   �����������б�֤ Divisor �� X ����һ����ʽ�� Prime �������ұ�ԭ����ʽ Primitive Ϊ X �Ĳ���Լ����ʽ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor
   ע�⣺��һԪ����ʽ��ͬ��ֻ��ϵ����ģ��}

function Int64BiPolynomialGaloisModX(const Res: TCnInt64BiPolynomial; const P: TCnInt64BiPolynomial;
  const Divisor: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial = nil): Boolean;
{* ������Ԫ��ϵ������ʽ������ Prime �η��������������࣬�������� Res �У����������Ƿ�ɹ���
   �����������б�֤ Divisor �� X ����һ����ʽ�� Prime �������ұ�ԭ����ʽ Primitive Ϊ X �Ĳ���Լ����ʽ
   Res ������ P �� Divisor��P ������ Divisor}

function Int64BiPolynomialGaloisPower(const Res, P: TCnInt64BiPolynomial;
  Exponent: Int64; Prime: Int64; Primitive: TCnInt64BiPolynomial = nil;
  ExponentHi: Int64 = 0): Boolean;
{* �����Ԫ��ϵ������ʽ�� Prime �η����������ϵ� Exponent ���ݣ�Exponent ������ 128 λ��
   Exponent ������������Ǹ�ֵ���Զ�ת�� UInt64
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ���ؼ����Ƿ�ɹ���Res ������ P}

function Int64BiPolynomialGaloisEvaluateByY(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; YValue, Prime: Int64): Boolean;
{* ��һ���� Y ֵ�����Ԫ��ϵ������ʽ���õ�ֻ���� X ��һԪ��ϵ������ʽ��ϵ����� Prime ȡģ}

function Int64BiPolynomialGaloisEvaluateByX(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; XValue, Prime: Int64): Boolean;
{* ��һ���� X ֵ�����Ԫ��ϵ������ʽ���õ�ֻ���� Y ��һԪ��ϵ������ʽ��ϵ����� Prime ȡģ}

procedure Int64BiPolynomialGaloisAddWord(const P: TCnInt64BiPolynomial; N: Int64; Prime: Int64);
{* �� Prime �η����������ϵĶ�Ԫ��ϵ������ʽ�ĸ���ϵ������ N �� mod Prime��ע�ⲻ�ǳ�ϵ��}

procedure Int64BiPolynomialGaloisSubWord(const P: TCnInt64BiPolynomial; N: Int64; Prime: Int64);
{* �� Prime �η����������ϵĶ�Ԫ��ϵ������ʽ�ĸ���ϵ����ȥ N �� mod Prime��ע�ⲻ�ǳ�ϵ��}

procedure Int64BiPolynomialGaloisMulWord(const P: TCnInt64BiPolynomial; N: Int64; Prime: Int64);
{* �� Prime �η����������ϵĶ�Ԫ��ϵ������ʽ����ϵ������ N �� mod Prime}

procedure Int64BiPolynomialGaloisDivWord(const P: TCnInt64BiPolynomial; N: Int64; Prime: Int64);
{* �� Prime �η����������ϵĶ�Ԫ��ϵ������ʽ����ϵ������ N��Ҳ���ǳ��� N ����Ԫ�� mod Prime}

// =============================================================================
//
//                           ��Ԫ����ϵ������ʽ
//
// =============================================================================

{
   FXs TObjectList
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  | X^n   �� Y ϵ�� Sparse| -> | X^n*Y^0 ��ϵ��  |X^n*Y^3 ��ϵ��   | ......
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  | X^n-1 �� Y ϵ�� Sparse| -> | X^n-1*Y^2 ��ϵ��|X^n-1*Y^5 ��ϵ�� | ......
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |......                 | -> |
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  | X^0   �� Y ϵ�� Sparse| -> | X^0*Y^4 ��ϵ��  | X^0*Y^7 ��ϵ��  | ......
  +-+-+-+-+-+-+-+-+-+-+-+-+    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

}

type
  TCnBigNumberBiPolynomial = class
  {* ��Ԫ����ϵ������ʽ���ڲ���ȡϡ�跽ʽ����΢��ռ���ڴ�}
  private
    FXs: TCnRefObjectList; // Ԫ��Ϊ TCnSparseBigNumberList���洢�� X ���ݵ�ÿһ����ͬ�� Y ���ݵ�ϵ��
    procedure EnsureDegrees(XDegree, YDegree: Integer);
    {* ȷ�� XDegree, YDegree ��Ԫ�ش���}
    function GetMaxXDegree: Integer;
    function GetMaxYDegree: Integer;
    procedure SetMaxXDegree(const Value: Integer);
    procedure SetMaxYDegree(const Value: Integer);
    function GetYFactorsList(Index: Integer): TCnSparseBigNumberList;
    function GetSafeValue(XDegree, YDegree: Integer): TCnBigNumber;
    procedure SetSafeValue(XDegree, YDegree: Integer; const Value: TCnBigNumber);
    function GetReadonlyValue(XDegree, YDegree: Integer): TCnBigNumber;
  protected
    function CompactYDegree(YList: TCnSparseBigNumberList): Boolean;
    {* ȥ��һ�� Y ϵ���ߴ�������� nil �������ݵ�ȫ 0 �򷵻� True}
    property YFactorsList[Index: Integer]: TCnSparseBigNumberList read GetYFactorsList;
    {* ��װ�Ķ� X �� Index ����� Y ϵ���б�FXs[Index] Ϊ nil ʱ���Զ�����������FXs.Count ����ʱ���Զ�����}
    procedure Clear;
    {* �ڲ�����������ݣ�ֻ�� FXs[0] ��һ�� List��һ�㲻����ʹ��}
  public
    constructor Create(XDegree: Integer = 0; YDegree: Integer = 0);
    {* ���캯�������� X �� Y ����ߴ�������Ĭ��Ϊ 0���Ժ��ٲ���}
    destructor Destroy; override;

    procedure SetYCoefficentsFromPolynomial(XDegree: Integer; PY: TCnInt64Polynomial); overload;
    {* ����ض������� X����һԪ�� Y ����ʽ��һ���������� Y ��ϵ��}
    procedure SetYCoefficentsFromPolynomial(XDegree: Integer; PY: TCnBigNumberPolynomial); overload;
    {* ����ض������� X����һԪ�Ĵ���ϵ�� Y ����ʽ��һ���������� Y ��ϵ��}
    procedure SetYCoefficents(XDegree: Integer; LowToHighYCoefficients: array of const);
    {* ����ض������� X��һ���������� Y �ӵ͵��ߵ�ϵ��}
    procedure SetXCoefficents(YDegree: Integer; LowToHighXCoefficients: array of const);
    {* ����ض������� Y��һ���������� X �ӵ͵��ߵ�ϵ��}
    procedure SetXYCoefficent(XDegree, YDegree: Integer; ACoefficient: TCnBigNumber);
    {* ����ض������� X �� Y��������ϵ��}

    procedure CorrectTop;
    {* �޳��ߴε� 0 ϵ��}
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ʽת���ַ���}
    procedure SetString(const Poly: string);
    {* ������ʽ�ַ���ת��Ϊ�����������}
    function IsZero: Boolean;
    {* �����Ƿ�Ϊ 0}
    procedure SetZero;
    {* ��Ϊ 0}
    procedure SetOne;
    {* ��Ϊ 1}
    procedure Negate;
    {* ����ϵ����}
    function IsMonicX: Boolean;
    {* �Ƿ��ǹ��� X ����һ����ʽ}
    procedure Transpose;
    {* ת�ã�Ҳ���ǻ��� X Y Ԫ}

    property MaxXDegree: Integer read GetMaxXDegree write SetMaxXDegree;
    {* X Ԫ����ߴ�����0 ��ʼ������ Count ����ֻ���� Integer��
      ���ú��ܱ�֤������ÿ�� XDegree�����Ӧ�� SparseBigNumberList ������}
    property MaxYDegree: Integer read GetMaxYDegree write SetMaxYDegree;
    {* X Ԫ����ߴ�����0 ��ʼ������ Count ����ֻ���� Integer}

    property SafeValue[XDegree, YDegree: Integer]: TCnBigNumber read GetSafeValue write SetSafeValue;
    {* ��ȫ�Ķ�дϵ����������������ʱ���� 0��д������ʱ�Զ���չ���ڲ����ƴ���ֵ}
    property ReadonlyValue[XDegree, YDegree: Integer]: TCnBigNumber read GetReadonlyValue;
    {* ֻ���ĸ��ݲ������� Exponent ��ȡ�����ķ�������ʱ���ڲ��鲻�����᷵��һ�̶�����ֵ TCnBigNumber ���������޸���ֵ}
  end;

  TCnBigNumberBiPolynomialPool = class(TCnMathObjectPool)
  {* ��Ԫ����ϵ������ʽ��ʵ���࣬����ʹ�õ���Ԫ����ϵ������ʽ�ĵط����д�����Ԫ����ϵ������ʽ��}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnBigNumberBiPolynomial; reintroduce;
    procedure Recycle(Poly: TCnBigNumberBiPolynomial); reintroduce;
  end;

function BigNumberBiPolynomialNew: TCnBigNumberBiPolynomial;
{* ����һ����Ԫ����ϵ������ʽ���󣬵�ͬ�� TCnBigNumberBiPolynomial.Create}

procedure BigNumberBiPolynomialFree(const P: TCnBigNumberBiPolynomial);
{* �ͷ�һ����Ԫ����ϵ������ʽ���󣬵�ͬ�� TCnBigNumberBiPolynomial.Free}

function BigNumberBiPolynomialDuplicate(const P: TCnBigNumberBiPolynomial): TCnBigNumberBiPolynomial;
{* ��һ����Ԫ����ϵ������ʽ�����¡һ���¶���}

function BigNumberBiPolynomialCopy(const Dst: TCnBigNumberBiPolynomial;
  const Src: TCnBigNumberBiPolynomial): TCnBigNumberBiPolynomial;
{* ����һ����Ԫ����ϵ������ʽ���󣬳ɹ����� Dst}

function BigNumberBiPolynomialCopyFromX(const Dst: TCnBigNumberBiPolynomial;
  const SrcX: TCnBigNumberPolynomial): TCnBigNumberBiPolynomial;
{* ��һԪ X ����ϵ������ʽ�и���һ����Ԫ����ϵ������ʽ���󣬳ɹ����� Dst}

function BigNumberBiPolynomialCopyFromY(const Dst: TCnBigNumberBiPolynomial;
  const SrcY: TCnBigNumberPolynomial): TCnBigNumberBiPolynomial;
{* ��һԪ Y ����ϵ������ʽ�и���һ����Ԫ����ϵ������ʽ���󣬳ɹ����� Dst}

function BigNumberBiPolynomialToString(const P: TCnBigNumberBiPolynomial;
  const Var1Name: Char = 'X'; const Var2Name: Char = 'Y'): string;
{* ��һ����Ԫ����ϵ������ʽ����ת���ַ�����δ֪��Ĭ���� X �� Y ��ʾ}

function BigNumberBiPolynomialSetString(const P: TCnBigNumberBiPolynomial;
  const Str: string; const Var1Name: Char = 'X'; const Var2Name: Char = 'Y'): Boolean;
{* ���ַ�����ʽ�Ķ�Ԫ����ϵ������ʽ��ֵ����Ԫ����ϵ������ʽ���󣬷����Ƿ�ֵ�ɹ�}

function BigNumberBiPolynomialIsZero(const P: TCnBigNumberBiPolynomial): Boolean;
{* �ж�һ����Ԫ����ϵ������ʽ�����Ƿ�Ϊ 0}

procedure BigNumberBiPolynomialSetZero(const P: TCnBigNumberBiPolynomial);
{* ��һ����Ԫ����ϵ������ʽ������Ϊ 0}

procedure BigNumberBiPolynomialSetOne(const P: TCnBigNumberBiPolynomial);
{* ��һ����Ԫ����ϵ������ʽ������Ϊ 1}

procedure BigNumberBiPolynomialNegate(const P: TCnBigNumberBiPolynomial);
{* ��һ����Ԫ����ϵ������ʽ��������ϵ����}

function BigNumberBiPolynomialIsMonicX(const P: TCnBigNumberBiPolynomial): Boolean;
{* �ж�һ����Ԫ����ϵ������ʽ�Ƿ��ǹ��� X ����һ����ʽ��Ҳ�����ж� X ��ߴε�ϵ���Ƿ�Ϊ 1}

procedure BigNumberBiPolynomialShiftLeftX(const P: TCnBigNumberBiPolynomial; N: Integer);
{* ��һ����Ԫ����ϵ������ʽ����� X ���� N �Σ�Ҳ���� X ����ָ������ N}

procedure BigNumberBiPolynomialShiftRightX(const P: TCnBigNumberBiPolynomial; N: Integer);
{* ��һ����Ԫ����ϵ������ʽ����� X ���� N �Σ�Ҳ���� X ����ָ������ N��С�� 0 �ĺ�����}

function BigNumberBiPolynomialEqual(const A, B: TCnBigNumberBiPolynomial): Boolean;
{* �ж�����Ԫ����ϵ������ʽÿ��ϵ���Ƿ��Ӧ��ȣ����򷵻� True}

// ===================== ��Ԫ����ϵ������ʽ��ͨ���� ============================

// procedure BigNumberBiPolynomialAddWord(const P: TCnBigNumberBiPolynomial; N: Int64);
{* ��һ����Ԫ����ϵ������ʽ����ĸ���ϵ������ N��������ϡ���б���˵ûɶ���壬��ʵ��}

// procedure BigNumberBiPolynomialSubWord(const P: TCnBigNumberBiPolynomial; N: Int64);
{* ��һ����Ԫ����ϵ������ʽ����ĸ���ϵ����ȥ N��������ϡ���б���˵ûɶ���壬��ʵ��}

procedure BigNumberBiPolynomialMulWord(const P: TCnBigNumberBiPolynomial; N: Int64);
{* ��һ����Ԫ����ϵ������ʽ����ĸ���ϵ�������� N}

procedure BigNumberBiPolynomialDivWord(const P: TCnBigNumberBiPolynomial; N: Int64);
{* ��һ����Ԫ����ϵ������ʽ����ĸ���ϵ�������� N���粻��������ȡ��}

procedure BigNumberBiPolynomialNonNegativeModWord(const P: TCnBigNumberBiPolynomial; N: Int64);
{* ��һ����Ԫ����ϵ������ʽ����ĸ���ϵ������ N �Ǹ����࣬��������������}

procedure BigNumberBiPolynomialMulBigNumber(const P: TCnBigNumberBiPolynomial; N: TCnBigNumber);
{* ��һ����Ԫ����ϵ������ʽ����ĸ���ϵ�������Դ��� N}

procedure BigNumberBiPolynomialDivBigNumber(const P: TCnBigNumberBiPolynomial; N: TCnBigNumber);
{* ��һ����Ԫ����ϵ������ʽ����ĸ���ϵ�������Դ��� N���粻��������ȡ��}

procedure BigNumberBiPolynomialNonNegativeModBigNumber(const P: TCnBigNumberBiPolynomial; N: TCnBigNumber);
{* ��һ����Ԫ����ϵ������ʽ����ĸ���ϵ������ N �Ǹ����࣬��������������}

function BigNumberBiPolynomialAdd(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial): Boolean;
{* ������Ԫ����ϵ������ʽ������ӣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberBiPolynomialSub(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial): Boolean;
{* ������Ԫ����ϵ������ʽ���������������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberBiPolynomialMul(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  P2: TCnBigNumberBiPolynomial): Boolean;
{* ������Ԫ����ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberBiPolynomialMulX(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  PX: TCnBigNumberPolynomial): Boolean;
{* һ����Ԫ����ϵ������ʽ������һ�� X ��һԪ����ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���Res ������ P1}

function BigNumberBiPolynomialMulY(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  PY: TCnBigNumberPolynomial): Boolean;
{* һ����Ԫ����ϵ������ʽ������һ�� Y ��һԪ����ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���Res ������ P1}

function BigNumberBiPolynomialDivX(const Res: TCnBigNumberBiPolynomial; const Remain: TCnBigNumberBiPolynomial;
  const P: TCnBigNumberBiPolynomial; const Divisor: TCnBigNumberBiPolynomial): Boolean;
{* ������Ԫ����ϵ������ʽ������ X Ϊ��������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   ע�� Divisor ������ X ����һ����ʽ������᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function BigNumberBiPolynomialModX(const Res: TCnBigNumberBiPolynomial;
  const P: TCnBigNumberBiPolynomial; const Divisor: TCnBigNumberBiPolynomial): Boolean;
{* ������Ԫ����ϵ������ʽ������ X Ϊ�����࣬�������� Res �У����������Ƿ�ɹ���
   ע�� Divisor ������ X ����һ����ʽ������᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ
   Res ������ P �� Divisor��P ������ Divisor}

function BigNumberBiPolynomialPower(const Res: TCnBigNumberBiPolynomial;
  const P: TCnBigNumberBiPolynomial; Exponent: TCnBigNumber): Boolean;
{* �����Ԫ����ϵ������ʽ�� Exponent ���ݣ�������ϵ����������⣬���ؼ����Ƿ�ɹ���Res ������ P}

function BigNumberBiPolynomialEvaluateByY(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; YValue: TCnBigNumber): Boolean;
{* ��һ���� Y ֵ�����Ԫ����ϵ������ʽ���õ�ֻ���� X ��һԪ����ϵ������ʽ}

function BigNumberBiPolynomialEvaluateByX(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; XValue: TCnBigNumber): Boolean;
{* ��һ���� X ֵ�����Ԫ����ϵ������ʽ���õ�ֻ���� Y ��һԪ����ϵ������ʽ}

procedure BigNumberBiPolynomialTranspose(const Dst, Src: TCnBigNumberBiPolynomial);
{* ����Ԫ����ϵ������ʽ�� X Y Ԫ��������һ����Ԫ����ϵ������ʽ�����У�Src �� Dst ������ͬ}

procedure BigNumberBiPolynomialExtractYByX(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; XDegree: Integer);
{* ����Ԫ����ϵ������ʽ�� X �η�ϵ����ȡ�����ŵ�һ�� Y ��һԪ����ʽ��}

procedure BigNumberBiPolynomialExtractXByY(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; YDegree: Integer);
{* ����Ԫ����ϵ������ʽ�� X �η�ϵ����ȡ�����ŵ�һ�� Y ��һԪ����ʽ��}

// ================== ��Ԫ����ϵ������ʽʽ���������ϵ�ģ���� ===================

function BigNumberBiPolynomialGaloisEqual(const A, B: TCnBigNumberBiPolynomial; Prime: TCnBigNumber): Boolean;
{* ������Ԫ����ϵ������ʽ��ģ Prime ���������Ƿ����}

procedure BigNumberBiPolynomialGaloisNegate(const P: TCnBigNumberBiPolynomial; Prime: TCnBigNumber);
{* ��һ����Ԫ����ϵ������ʽ��������ϵ����ģ Prime ����������}

function BigNumberBiPolynomialGaloisAdd(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial = nil): Boolean;
{* ������Ԫ����ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberBiPolynomialGaloisSub(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial = nil): Boolean;
{* ������Ԫ����ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberBiPolynomialGaloisMul(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial = nil): Boolean;
{* ������Ԫ����ϵ������ʽ������ Prime �η�������������ˣ�������� Res �У�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberBiPolynomialGaloisMulX(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  PX: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial = nil): Boolean;
{* һ����Ԫ����ϵ������ʽ������һ�� X ��һԪ����ϵ������ʽ������ Prime �η�������������ˣ�
  ������� Res �У���������Ƿ�ɹ���Res ������ P1}

function BigNumberBiPolynomialGaloisMulY(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  PY: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial = nil): Boolean;
{* һ����Ԫ����ϵ������ʽ������һ�� Y ��һԪ����ϵ������ʽ������ Prime �η�������������ˣ�
  ������� Res �У���������Ƿ�ɹ���Res ������ P1}

function BigNumberBiPolynomialGaloisDivX(const Res: TCnBigNumberBiPolynomial;
  const Remain: TCnBigNumberBiPolynomial; const P: TCnBigNumberBiPolynomial;
  const Divisor: TCnBigNumberBiPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial = nil): Boolean;
{* ������Ԫ����ϵ������ʽ������ Prime �η�����������������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   �����������б�֤ Divisor �� X ����һ����ʽ�� Prime �������ұ�ԭ����ʽ Primitive Ϊ X �Ĳ���Լ����ʽ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor
   ע�⣺��һԪ����ʽ��ͬ��ֻ��ϵ����ģ��}

function BigNumberBiPolynomialGaloisModX(const Res: TCnBigNumberBiPolynomial; const P: TCnBigNumberBiPolynomial;
  const Divisor: TCnBigNumberBiPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial = nil): Boolean;
{* ������Ԫ����ϵ������ʽ������ Prime �η��������������࣬�������� Res �У����������Ƿ�ɹ���
   �����������б�֤ Divisor �� X ����һ����ʽ�� Prime �������ұ�ԭ����ʽ Primitive Ϊ X �Ĳ���Լ����ʽ
   Res ������ P �� Divisor��P ������ Divisor}

function BigNumberBiPolynomialGaloisPower(const Res, P: TCnBigNumberBiPolynomial;
  Exponent: TCnBigNumber; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial = nil): Boolean;
{* �����Ԫ����ϵ������ʽ�� Prime �η����������ϵ� Exponent ����
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ���ؼ����Ƿ�ɹ���Res ������ P}

function BigNumberBiPolynomialGaloisEvaluateByY(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; YValue, Prime: TCnBigNumber): Boolean;
{* ��һ���� Y ֵ�����Ԫ����ϵ������ʽ���õ�ֻ���� X ��һԪ����ϵ������ʽ��ϵ����� Prime ȡģ}

function BigNumberBiPolynomialGaloisEvaluateByX(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; XValue, Prime: TCnBigNumber): Boolean;
{* ��һ���� X ֵ�����Ԫ����ϵ������ʽ���õ�ֻ���� Y ��һԪ����ϵ������ʽ��ϵ����� Prime ȡģ}

// procedure BigNumberBiPolynomialGaloisAddWord(const P: TCnBigNumberBiPolynomial; N: Int64; Prime: TCnBigNumber);
{* �� Prime �η����������ϵĶ�Ԫ����ϵ������ʽ�ĸ���ϵ������ N �� mod Prime��ע�ⲻ�ǳ�ϵ����������ϡ���б���˵ûɶ���壬��ʵ��}

// procedure BigNumberBiPolynomialGaloisSubWord(const P: TCnBigNumberBiPolynomial; N: Int64; Prime: TCnBigNumber);
{* �� Prime �η����������ϵĶ�Ԫ����ϵ������ʽ�ĸ���ϵ����ȥ N �� mod Prime��ע�ⲻ�ǳ�ϵ����������ϡ���б���˵ûɶ���壬��ʵ��}

procedure BigNumberBiPolynomialGaloisMulWord(const P: TCnBigNumberBiPolynomial; N: Int64; Prime: TCnBigNumber);
{* �� Prime �η����������ϵĶ�Ԫ����ϵ������ʽ����ϵ������ N �� mod Prime}

procedure BigNumberBiPolynomialGaloisDivWord(const P: TCnBigNumberBiPolynomial; N: Int64; Prime: TCnBigNumber);
{* �� Prime �η����������ϵĶ�Ԫ����ϵ������ʽ����ϵ������ N��Ҳ���ǳ��� N ����Ԫ�� mod Prime}

var
  CnInt64PolynomialOne: TCnInt64Polynomial = nil;     // ��ʾ 1 �ĳ���
  CnInt64PolynomialZero: TCnInt64Polynomial = nil;    // ��ʾ 0 �ĳ���

  CnBigNumberPolynomialOne: TCnBigNumberPolynomial = nil;     // ��ʾ 1 �ĳ���
  CnBigNumberPolynomialZero: TCnBigNumberPolynomial = nil;    // ��ʾ 0 �ĳ���

implementation

resourcestring
  SCnInvalidDegree = 'Invalid Degree %d';
  SCnErrorDivExactly = 'Can NOT Divide Exactly for Integer Polynomial.';
  SCnInvalidExponent = 'Invalid Exponent %d';
  SCnInvalidModulus = 'Can NOT Mod a Negative or Zero Value.';
  SCnDegreeTooLarge = 'Degree Too Large';

var
  FLocalInt64PolynomialPool: TCnInt64PolynomialPool = nil;
  FLocalInt64RationalPolynomialPool: TCnInt64RationalPolynomialPool = nil;
  FLocalBigNumberPolynomialPool: TCnBigNumberPolynomialPool = nil;
  FLocalBigNumberRationalPolynomialPool: TCnBigNumberRationalPolynomialPool = nil;
  FLocalBigNumberPool: TCnBigNumberPool = nil;
  FLocalInt64BiPolynomialPool: TCnInt64BiPolynomialPool = nil;
  FLocalBigNumberBiPolynomialPool: TCnBigNumberBiPolynomialPool = nil;

procedure CheckDegree(Degree: Integer);
begin
  if Degree < 0 then
    raise ECnPolynomialException.CreateFmt(SCnInvalidDegree, [Degree]);
end;

function VarPower(const VarName: string; E: Integer): string;
begin
  if E = 0 then
    Result := ''
  else if E = 1 then
    Result := VarName
  else
    Result := VarName + '^' + IntToStr(E);
end;

function VarPower2(const Var1Name, Var2Name: string; E1, E2: Integer): string;
begin
  Result := VarPower(Var1Name, E1) + VarPower(Var2Name, E2);
end;

// ����ʽϵ��ת�ַ���ʱ��װ�Ĺ���DecStr �Ǹ�ϵ�����ַ�����ʽ�������� - �ţ�
// ����ֵ��ϵ���� 0 ʱΪ True����ʾ������Ҫ�ӵ���ʽ
function VarItemFactor(var Res: string; ExpsIsZero: Boolean; const DecStr: string): Boolean;
var
  IsPositive, IsNegative, IsZero, IsOne, IsNegOne: Boolean;
begin
  Result := True;
  if Length(DecStr) = 0 then
    Exit;

  IsZero := (DecStr = '0') or (DecStr = '-0');
  IsOne := DecStr = '1';
  IsNegOne := DecStr = '-1';

  IsNegative := (not IsZero) and (DecStr[1] = '-');
  IsPositive := (not IsZero) and (DecStr[1] <> '-');

  if IsZero then // ��ϵ��
  begin
    if ExpsIsZero and (Res = '') then
      Res := '0';
    // ����� Res ɶ������
    Result := False;
  end
  else if IsPositive then // ���� 0
  begin
    if IsOne and not ExpsIsZero then  // �ǳ������ 1 ϵ��������ʾ
    begin
      if Res <> '' then  // ����� Res Ϊ�գ�����Ӻ�
        Res := Res + '+';
    end
    else
    begin
      if Res = '' then  // ���������Ӻ�
        Res := DecStr
      else
        Res := Res + '+' + DecStr;
    end;
  end
  else if IsNegative then // С�� 0��Ҫ�ü���
  begin
    if IsNegOne and not ExpsIsZero then // �ǳ������ -1 ������ʾ 1��ֻ�����
      Res := Res + '-'
    else
      Res := Res + DecStr; // DecStr ���м���
  end;
end;

// ��װ�Ĵ� TVarRec Ҳ���� array of const Ԫ���ﷵ�� Int64 �ĺ���
function ExtractInt64FromArrayConstElement(Element: TVarRec): Int64;
begin
  case Element.VType of
  vtInteger:
    begin
      Result := Element.VInteger;
    end;
  vtInt64:
    begin
      Result := Element.VInt64^;
    end;
  vtBoolean:
    begin
      if Element.VBoolean then
        Result := 1
      else
        Result := 0;
    end;
  vtString:
    begin
      Result := StrToInt(Element.VString^);
    end;
  else
    raise ECnPolynomialException.CreateFmt(SInvalidInteger, ['Coefficients ' + Element.VString^]);
  end;
end;

// ��װ�Ĵ� TVarRec Ҳ���� array of const Ԫ���ﷵ�ش����ַ����ĺ���
function ExtractBigNumberFromArrayConstElement(Element: TVarRec): string;
begin
  Result := '';
  case Element.VType of
  vtInteger:
    begin
      Result := IntToStr(Element.VInteger);
    end;
  vtInt64:
    begin
      Result := IntToStr(Element.VInt64^);
    end;
  vtBoolean:
    begin
      if Element.VBoolean then
        Result := '1'
      else
        Result := '0';
    end;
  vtString:
    begin
      Result := Element.VString^;
    end;
  vtObject:
    begin
      // ���� TCnBigNumber �����и���ֵ
      if Element.VObject is TCnBigNumber then
        Result := (Element.VObject as TCnBigNumber).ToDec;
    end;
  else
    raise ECnPolynomialException.CreateFmt(SInvalidInteger, ['Coefficients ' + Element.VString^]);
  end;
end;

function Exponent128IsZero(Exponent, ExponentHi: Int64): Boolean;
begin
  Result := (Exponent = 0) and (ExponentHi = 0);
end;

function Exponent128IsOne(Exponent, ExponentHi: Int64): Boolean;
begin
  Result := (Exponent = 1) and (ExponentHi = 0);
end;

procedure ExponentShiftRightOne(var Exponent, ExponentHi: Int64);
begin
  Exponent := Exponent shr 1;
  if (ExponentHi and 1) <> 0 then
    Exponent := Exponent or $8000000000000000;
  ExponentHi := ExponentHi shr 1;
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

function TCnInt64Polynomial.IsMonic: Boolean;
begin
  Result := Int64PolynomialIsMonic(Self);
end;

function TCnInt64Polynomial.IsNegOne: Boolean;
begin
  Result := Int64PolynomialIsNegOne(Self);
end;

function TCnInt64Polynomial.IsOne: Boolean;
begin
  Result := Int64PolynomialIsOne(Self);
end;

function TCnInt64Polynomial.IsZero: Boolean;
begin
  Result := Int64PolynomialIsZero(Self);
end;

procedure TCnInt64Polynomial.Negate;
begin
  Int64PolynomialNegate(Self);
end;

procedure TCnInt64Polynomial.SetCoefficents(LowToHighCoefficients: array of const);
var
  I: Integer;
begin
  Clear;
  for I := Low(LowToHighCoefficients) to High(LowToHighCoefficients) do
    Add(ExtractInt64FromArrayConstElement(LowToHighCoefficients[I]));

  if Count = 0 then
    Add(0)
  else
    CorrectTop;
end;

procedure TCnInt64Polynomial.SetMaxDegree(const Value: Integer);
begin
  CheckDegree(Value);
  Count := Value + 1;
end;

procedure TCnInt64Polynomial.SetOne;
begin
  Int64PolynomialSetOne(Self);
end;

procedure TCnInt64Polynomial.SetString(const Poly: string);
begin
  Int64PolynomialSetString(Self, Poly);
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
  const VarName: Char = 'X'): string;
var
  I: Integer;
begin
  Result := '';
  if Int64PolynomialIsZero(P) then
  begin
    Result := '0';
    Exit;
  end;

  for I := P.MaxDegree downto 0 do
  begin
    if VarItemFactor(Result, (I = 0), IntToStr(P[I])) then
      Result := Result + VarPower(VarName, I);
  end;
end;

function Int64PolynomialSetString(const P: TCnInt64Polynomial;
  const Str: string; const VarName: Char = 'X'): Boolean;
var
  C, Ptr: PChar;
  Num: string;
  MDFlag, E: Integer;
  F: Int64;
  IsNeg: Boolean;
begin
  Result := False;
  if Str = '' then
    Exit;

  MDFlag := -1;
  C := @Str[1];

  while C^ <> #0 do
  begin
    if not (C^ in ['+', '-', '0'..'9']) and (C^ <> VarName) then
    begin
      Inc(C);
      Continue;
    end;

    IsNeg := False;
    if C^ = '+' then
      Inc(C)
    else if C^ = '-' then
    begin
      IsNeg := True;
      Inc(C);
    end;

    F := 1;
    if C^ in ['0'..'9'] then // ��ϵ��
    begin
      Ptr := C;
      while C^ in ['0'..'9'] do
        Inc(C);

      // Ptr �� C ֮�������֣�����һ��ϵ��
      SetString(Num, Ptr, C - Ptr);
      F := StrToInt64(Num);
      if IsNeg then
        F := -F;
    end
    else if IsNeg then
      F := -F;

    if C^ = VarName then
    begin
      E := 1;
      Inc(C);
      if C^ = '^' then // ��ָ��
      begin
        Inc(C);
        if C^ in ['0'..'9'] then
        begin
          Ptr := C;
          while C^ in ['0'..'9'] do
            Inc(C);

          // Ptr �� C ֮�������֣�����һ��ָ��
          SetString(Num, Ptr, C - Ptr);
          E := StrToInt64(Num);
        end;
      end;
    end
    else
      E := 0;

    // ָ�������ˣ���
    if MDFlag = -1 then // ��һ��ָ���� MaxDegree
    begin
      P.MaxDegree := E;
      MDFlag := 0;
    end;

    P[E] := F;
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

function Int64PolynomialIsNegOne(const P: TCnInt64Polynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and (P[0] = -1);
end;

procedure Int64PolynomialNegate(const P: TCnInt64Polynomial);
var
  I: Integer;
begin
  for I := 0 to P.MaxDegree do
    P[I] := -P[I];
end;

function Int64PolynomialIsMonic(const P: TCnInt64Polynomial): Boolean;
begin
  Result := P[P.MaxDegree] = 1;
end;

procedure Int64PolynomialShiftLeft(const P: TCnInt64Polynomial; N: Integer);
begin
  if N = 0 then
    Exit
  else if N < 0 then
    Int64PolynomialShiftRight(P, -N)
  else
    P.InsertBatch(0, N);
end;

procedure Int64PolynomialShiftRight(const P: TCnInt64Polynomial; N: Integer);
begin
  if N = 0 then
    Exit
  else if N < 0 then
    Int64PolynomialShiftLeft(P, -N)
  else
  begin
    P.DeleteLow(N);

    if P.Count = 0 then
      P.Add(0);
  end;
end;

function Int64PolynomialEqual(const A, B: TCnInt64Polynomial): Boolean;
var
  I: Integer;
begin
  if A = B then
  begin
    Result := True;
    Exit;
  end;

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

procedure Int64PolynomialAddWord(const P: TCnInt64Polynomial; N: Int64);
begin
  P[0] := P[0] + N;
end;

procedure Int64PolynomialSubWord(const P: TCnInt64Polynomial; N: Int64);
begin
  P[0] := P[0] - N;
end;

procedure Int64PolynomialMulWord(const P: TCnInt64Polynomial; N: Int64);
var
  I: Integer;
begin
  if N = 0 then
    Int64PolynomialSetZero(P)
  else if N <> 1 then
  begin
    for I := 0 to P.MaxDegree do
      P[I] := P[I] * N;
  end;
end;

procedure Int64PolynomialDivWord(const P: TCnInt64Polynomial; N: Int64);
var
  I: Integer;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SZeroDivide);

  if N <> 1 then
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
    P[I] := Int64NonNegativeMod(P[I], N);
end;

function Int64PolynomialAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
var
  I, D1, D2: Integer;
  PBig: TCnInt64Polynomial;
begin
  D1 := Max(P1.MaxDegree, P2.MaxDegree);
  D2 := Min(P1.MaxDegree, P2.MaxDegree);

  if D1 > D2 then
  begin
    if P1.MaxDegree > P2.MaxDegree then
      PBig := P1
    else
      PBig := P2;

    Res.MaxDegree := D1; // ���ǵ� Res ������ P1 �� P2�����Ը� Res �� MaxDegree ��ֵ�÷�����ıȽ�֮��
    for I := D1 downto D2 + 1 do
      Res[I] := PBig[I];
  end
  else // D1 = D2 ˵������ʽͬ��
    Res.MaxDegree := D1;

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
  I, J: Integer;
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

  R.Clear;
  R.MaxDegree := P1.MaxDegree + P2.MaxDegree;

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

function Int64PolynomialDftMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
var
  M1, M2: PCnComplexNumber;
  C1, C2: PCnComplexArray;
  M, I: Integer;
begin
  Result := False;
  M := P1.MaxDegree;
  if M < P2.MaxDegree then
    M := P2.MaxDegree;

  if M < 0 then
    Exit;

  if M = 0 then // �������ֱ����
  begin
    Res.SetMaxDegree(0);
    Res[0] := P1[0] * P2[0];
    Result := True;
    Exit;
  end;

  // M �õ���ߴ������� 1 ��ʾ����ʽ�������
  Inc(M);

  // ���� 2 ��ʾ����ʽ�����������
  M := M shl 1;

  // ���ұ� M ����ߵ��� M �� 2 ����������
  if not IsUInt32PowerOf2(Cardinal(M)) then
  begin
    // ������� 2 ����������
    M := GetUInt32HighBits(Cardinal(M)); // M �õ����λ�� 1 ��λ�ã������� -1
    if M > 30 then
      raise ECnPolynomialException.Create(SCnDegreeTooLarge);

    Inc(M);
    M := 1 shl M; // �õ��� M �����С�� 2 ����������
  end;

  M1 := GetMemory(M * SizeOf(TCnComplexNumber));
  M2 := GetMemory(M * SizeOf(TCnComplexNumber));

  C1 := PCnComplexArray(M1);
  C2 := PCnComplexArray(M2);

  try
    for I := 0 to M - 1 do
    begin
      ComplexNumberSetZero(C1^[I]);
      ComplexNumberSetZero(C2^[I]);
    end;

    for I := 0 to P1.MaxDegree do
    begin
      C1^[I].R := P1[I];
      C1^[I].I := 0.0;
    end;
    for I := 0 to P2.MaxDegree do
    begin
      C2^[I].R := P2[I];
      C2^[I].I := 0.0;
    end;

    CnFFT(C1, M);
    CnFFT(C2, M);        // �õ������ֵ

    for I := 0 to M - 1 do   // ��ֵ���
      ComplexNumberMul(C1^[I], C1^[I], C2^[I]);

    Result := CnIFFT(C1, M);       // ��ֵ���ϵ�����ʽ

    Res.SetZero;
    Res.SetMaxDegree(M);
    for I := 0 to M - 1 do   // ��ֵ����������������ȡ��
      Res[I] := Round(C1^[I].R);

    Res.CorrectTop;
  finally
    FreeMemory(M1);
    FreeMemory(M2);
  end;
end;

function Int64PolynomialNttMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
var
  M1, M2: PInt64;
  C1, C2: PInt64Array;
  M, I: Integer;
begin
  Result := False;
  M := P1.MaxDegree;
  if M < P2.MaxDegree then
    M := P2.MaxDegree;

  if M < 0 then
    Exit;

  if M = 0 then // �������ֱ����
  begin
    Res.SetMaxDegree(0);
    Res[0] := P1[0] * P2[0];
    Result := True;
    Exit;
  end;

  // M �õ���ߴ������� 1 ��ʾ����ʽ�������
  Inc(M);

  // ���� 2 ��ʾ����ʽ�����������
  M := M shl 1;

  // ���ұ� M ����ߵ��� M �� 2 ����������
  if not IsUInt32PowerOf2(Cardinal(M)) then
  begin
    // ������� 2 ����������
    M := GetUInt32HighBits(Cardinal(M)); // M �õ����λ�� 1 ��λ�ã������� -1
    if M > 30 then
      raise ECnPolynomialException.Create(SCnDegreeTooLarge);

    Inc(M);
    M := 1 shl M; // �õ��� M �����С�� 2 ����������
  end;

  M1 := GetMemory(M * SizeOf(Int64));
  M2 := GetMemory(M * SizeOf(Int64));

  C1 := PInt64Array(M1);
  C2 := PInt64Array(M2);

  try
    for I := 0 to M - 1 do
    begin
      C1^[I] := 0;
      C2^[I] := 0;
    end;

    for I := 0 to P1.MaxDegree do
      C1^[I] := P1[I];

    for I := 0 to P2.MaxDegree do
      C2^[I] := P2[I];

    CnNTT(C1, M);
    CnNTT(C2, M);        // �õ������ֵ

    for I := 0 to M - 1 do   // ��ֵ��ˣ����������
      C1^[I] := C1^[I] * C2^[I];

    Result := CnINTT(C1, M);       // ��ֵ���ϵ�����ʽ

    Res.SetZero;
    Res.SetMaxDegree(M);
    for I := 0 to M - 1 do
      Res[I] := C1^[I];

    Res.CorrectTop;
  finally
    FreeMemory(M1);
    FreeMemory(M2);
  end;
end;

function Int64PolynomialDiv(const Res: TCnInt64Polynomial; const Remain: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; const Divisor: TCnInt64Polynomial): Boolean;
var
  SubRes: TCnInt64Polynomial; // ���ɵݼ���
  MulRes: TCnInt64Polynomial; // ���ɳ����˻�
  DivRes: TCnInt64Polynomial; // ������ʱ��
  I, D: Integer;
  T: Int64;
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
      begin
        Result := False;
        Exit;
        // raise ECnPolynomialException.Create(SCnErrorDivExactly);
      end;

      Int64PolynomialCopy(MulRes, Divisor);
      Int64PolynomialShiftLeft(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�
      T := SubRes[P.MaxDegree - I] div MulRes[MulRes.MaxDegree];
      Int64PolynomialMulWord(MulRes, T); // ��ʽ�˵���ߴ�ϵ����ͬ
      DivRes[D - I] := T;                // �̷ŵ� DivRes λ��
      Int64PolynomialSub(SubRes, SubRes, MulRes);              // ���������·Ż� SubRes
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

function Int64PolynomialMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialDiv(nil, Res, P, Divisor);
end;

function Int64PolynomialPower(const Res: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; Exponent: Int64): Boolean;
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
  end
  else if Exponent < 0 then
    raise ECnPolynomialException.CreateFmt(SCnInvalidExponent, [Exponent]);

  T := FLocalInt64PolynomialPool.Obtain;
  Int64PolynomialCopy(T, P);

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
    FLocalInt64PolynomialPool.Recycle(T);
  end;
end;

function Int64PolynomialReduce(const P: TCnInt64Polynomial): Integer;
var
  I: Integer;
  D: Int64;

  function Gcd(A, B: Int64): Int64;
  var
    T: Int64;
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
  Result := False;
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
      if not Int64PolynomialMod(B, A, B) then   // A mod B �� B
        Exit;

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

function Int64PolynomialLeastCommonMultiple(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
var
  G, M, R: TCnInt64Polynomial;
begin
  Result := False;
  if Int64PolynomialEqual(P1, P2) then
  begin
    Int64PolynomialCopy(Res, P1);
    Result := True;
    Exit;
  end;

  G := nil;
  M := nil;
  R := nil;

  try
    G := FLocalInt64PolynomialPool.Obtain;
    M := FLocalInt64PolynomialPool.Obtain;
    R := FLocalInt64PolynomialPool.Obtain;

    if not Int64PolynomialMul(M, P1, P2) then
      Exit;

    if not Int64PolynomialGreatestCommonDivisor(G, P1, P2) then
      Exit;

    if not Int64PolynomialDiv(Res, R, M, G) then
      Exit;

    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(R);
    FLocalInt64PolynomialPool.Recycle(M);
    FLocalInt64PolynomialPool.Recycle(G);
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

  try
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
  finally
    FLocalInt64PolynomialPool.Recycle(X);
    FLocalInt64PolynomialPool.Recycle(T);
  end;
  Result := True;
end;

function Int64PolynomialGetValue(const F: TCnInt64Polynomial; X: Int64): Int64;
var
  I: Integer;
  T: Int64;
begin
  Result := F[0];
  if (X = 0) or (F.MaxDegree = 0) then    // ֻ�г����������£��ó�����
    Exit;

  T := X;

  // �� F �е�ÿ��ϵ������ X �Ķ�Ӧ������ˣ�������
  for I := 1 to F.MaxDegree do
  begin
    Result := Result + F[I] * T;
    if I <> F.MaxDegree then
      T := T * X;
  end;
end;

procedure Int64PolynomialReduce2(P1, P2: TCnInt64Polynomial);
var
  D: TCnInt64Polynomial;
begin
  if P1 = P2 then
  begin
    P1.SetOne;
    Exit;
  end;

  D := FLocalInt64PolynomialPool.Obtain;
  try
    if not Int64PolynomialGreatestCommonDivisor(D, P1, P2) then
      Exit;

    if not D.IsOne then
    begin
      Int64PolynomialDiv(P1, nil, P1, D);
      Int64PolynomialDiv(P1, nil, P1, D);
    end;
  finally
    FLocalInt64PolynomialPool.Recycle(D);
  end;
end;

function Int64PolynomialGaloisEqual(const A, B: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  I: Integer;
begin
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  Result := A.MaxDegree = B.MaxDegree;
  if Result then
  begin
    for I := A.MaxDegree downto 0 do
    begin
      if (A[I] <> B[I]) and (Int64NonNegativeMod(A[I], Prime) <> Int64NonNegativeMod(B[I], Prime)) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure Int64PolynomialGaloisNegate(const P: TCnInt64Polynomial; Prime: Int64);
var
  I: Integer;
begin
  for I := 0 to P.MaxDegree do
    P[I] := Int64NonNegativeMod(-P[I], Prime);
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

function Int64PolynomialGaloisMul(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  R: TCnInt64Polynomial;
  I, J: Integer;
  T: Int64;
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

  R.Clear;
  R.MaxDegree := P1.MaxDegree + P2.MaxDegree;

  for I := 0 to P1.MaxDegree do
  begin
    // �ѵ� I �η������ֳ��� P2 ��ÿһ�����֣��ӵ������ I ��ͷ�Ĳ��֣���ȡģ
    for J := 0 to P2.MaxDegree do
    begin
      // �������������ֱ�����
      T := Int64NonNegativeMulMod(P1[I], P2[J], Prime);
      R[I + J] := Int64NonNegativeMod(R[I + J] + Int64NonNegativeMod(T, Prime), Prime);
      // TODO: ��δ����ӷ���������
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
      if P.MaxDegree - I > SubRes.MaxDegree then               // �м���������λ
        Continue;
      Int64PolynomialCopy(MulRes, Divisor);
      Int64PolynomialShiftLeft(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�

      // ��ʽҪ��һ������������� SubRes ���λ���Գ�ʽ���λ�õ��Ľ����Ҳ�� SubRes ���λ���Գ�ʽ���λ����Ԫ�� mod Prime
      T := Int64NonNegativeMulMod(SubRes[P.MaxDegree - I], K, Prime);
      Int64PolynomialGaloisMulWord(MulRes, T, Prime);          // ��ʽ�˵���ߴ�ϵ����ͬ

      DivRes[D - I] := T;                                      // ��Ӧλ���̷ŵ� DivRes λ��
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
  Exponent: Int64; Prime: Int64; Primitive: TCnInt64Polynomial;
  ExponentHi: Int64): Boolean;
var
  T: TCnInt64Polynomial;
begin
  if Exponent128IsZero(Exponent, ExponentHi) then
  begin
    Res.SetCoefficents([1]);
    Result := True;
    Exit;
  end
  else if Exponent128IsOne(Exponent, ExponentHi) then
  begin
    if Res <> P then
      Int64PolynomialCopy(Res, P);
    Result := True;
    Exit;
  end;

  T := FLocalInt64PolynomialPool.Obtain;
  Int64PolynomialCopy(T, P);

  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetCoefficents([1]);
    while not Exponent128IsZero(Exponent, ExponentHi) do
    begin
      if (Exponent and 1) <> 0 then
        Int64PolynomialGaloisMul(Res, Res, T, Prime, Primitive);

      ExponentShiftRightOne(Exponent, ExponentHi);
      Int64PolynomialGaloisMul(T, T, T, Prime, Primitive);
    end;
    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(T);
  end;
end;

procedure Int64PolynomialGaloisAddWord(const P: TCnInt64Polynomial; N: Int64;
  Prime: Int64);
begin
  if N <> 0 then
    P[0] := Int64NonNegativeMod(P[0] + N, Prime);
end;

procedure Int64PolynomialGaloisSubWord(const P: TCnInt64Polynomial; N: Int64;
  Prime: Int64);
begin
  if N <> 0 then
    P[0] := Int64NonNegativeMod(P[0] - N, Prime);
end;

procedure Int64PolynomialGaloisMulWord(const P: TCnInt64Polynomial; N: Int64;
  Prime: Int64);
var
  I: Integer;
begin
  if N = 0 then
  begin
    Int64PolynomialSetZero(P);
  end
  else if N <> 1 then
  begin
    for I := 0 to P.MaxDegree do
      P[I] := Int64NonNegativeMulMod(P[I], N, Prime);
  end;
end;

procedure Int64PolynomialGaloisDivWord(const P: TCnInt64Polynomial; N: Int64;
  Prime: Int64);
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
    P[I] := Int64NonNegativeMulMod(P[I], K, Prime);
    if B then
      P[I] := Prime - P[I];
  end;
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

function Int64PolynomialGaloisLeastCommonMultiple(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  G, M, R: TCnInt64Polynomial;
begin
  Result := False;
  if Int64PolynomialEqual(P1, P2) then
  begin
    Int64PolynomialCopy(Res, P1);
    Result := True;
    Exit;
  end;

  G := nil;
  M := nil;
  R := nil;

  try
    G := FLocalInt64PolynomialPool.Obtain;
    M := FLocalInt64PolynomialPool.Obtain;
    R := FLocalInt64PolynomialPool.Obtain;

    if not Int64PolynomialGaloisMul(M, P1, P2, Prime) then
      Exit;

    if not Int64PolynomialGaloisGreatestCommonDivisor(G, P1, P2, Prime) then
      Exit;

    if not Int64PolynomialGaloisDiv(Res, R, M, G, Prime) then
      Exit;

    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(R);
    FLocalInt64PolynomialPool.Recycle(M);
    FLocalInt64PolynomialPool.Recycle(G);
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
  X, Modulus: TCnInt64Polynomial; Prime: Int64; CheckGcd: Boolean);
var
  X1, Y, G: TCnInt64Polynomial;
begin
  X1 := nil;
  Y := nil;
  G := nil;

  try
    if CheckGcd then
    begin
      G := FLocalInt64PolynomialPool.Obtain;
      Int64PolynomialGaloisGreatestCommonDivisor(G, X, Modulus, Prime);
      if not G.IsOne then
        raise ECnPolynomialException.Create('Modular Inverse Need GCD = 1');
    end;

    X1 := FLocalInt64PolynomialPool.Obtain;
    Y := FLocalInt64PolynomialPool.Obtain;

    Int64PolynomialCopy(X1, X);

    // ��չŷ�����շת��������Ԫһ�β�����ϵ������ʽ���� A * X - B * Y = 1 ��������
    Int64PolynomialGaloisExtendedEuclideanGcd(X1, Modulus, Res, Y, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(X1);
    FLocalInt64PolynomialPool.Recycle(Y);
    FLocalInt64PolynomialPool.Recycle(G);
  end;
end;

function Int64PolynomialGaloisCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnInt64Polynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    Res[0] := Int64NonNegativeMod(F[0], Prime);
    Result := True;
    Exit;
  end;

  if (Res = F) or (Res = P) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  X := FLocalInt64PolynomialPool.Obtain;
  T := FLocalInt64PolynomialPool.Obtain;

  try
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

    if Primitive <> nil then
      Int64PolynomialGaloisMod(R, R, Primitive, Prime);

    if (Res = F) or (Res = P) then
    begin
      Int64PolynomialCopy(Res, R);
      FLocalInt64PolynomialPool.Recycle(R);
    end;
  finally
    FLocalInt64PolynomialPool.Recycle(X);
    FLocalInt64PolynomialPool.Recycle(T);
  end;
  Result := True;
end;

function Int64PolynomialGaloisGetValue(const F: TCnInt64Polynomial; X, Prime: Int64): Int64;
var
  I: Integer;
  T: Int64;
begin
  Result := Int64NonNegativeMod(F[0], Prime);
  if (X = 0) or (F.MaxDegree = 0) then    // ֻ�г����������£��ó�����
    Exit;

  T := X;

  // �� F �е�ÿ��ϵ������ X �Ķ�Ӧ������ˣ�������
  for I := 1 to F.MaxDegree do
  begin
    Result := Int64NonNegativeMod(Result + Int64NonNegativeMulMod(F[I], T, Prime), Prime);
    if I <> F.MaxDegree then
      T := Int64NonNegativeMulMod(T, X, Prime);
  end;
  Result := Int64NonNegativeMod(Result, Prime);
end;

{
  �ɳ�����ʽ�����֣�һ���Ǻ� x y �� F��һ����ֻ�� x �� f�����߶��� y ��������Ҫ����˸� y
  ���� Fn �� n Ϊż��ʱ��Ȼ���� y * ������Կ��Թ涨 Fn = fn * y ��n Ϊż����fn = Fn ��n Ϊ�棩

  F0 = 0
  F1 = 1
  F2 = 2y
  F3 = 3x^4 + 6Ax^2 + 12Bx - A^2
  F4 = 4y * (x^6 + 5Ax^4 + 20Bx^3 - 5A^2x^2 - 4ABx - 8B^2 - A^3)
  F5 = 5x^12 + 62Ax^10 + 380Bx^9 + 105A^2x^8 + 240BAx^7 + (-300A^3 - 240B^2)x^6
    - 696BA^2x^5 + (-125A^4 - 1920B^2A)x^4 + (-80BA^3 - 1600B^3)x^3 + (-50A^5 - 240B^2A^2)x^2
    + (100BA^4 - 640B^3A)x + (A^6 - 32B^2A^3 - 256B4)
  ......

  һ�㣺
    F2n+1 = Fn+2 * Fn^3 - Fn-1 * Fn+1^3
    F2n   = (Fn/2y) * (Fn+2 * Fn-1^2 - Fn-2 * Fn+1^2)       // �𿴳��� 2y��ʵ���ϱ�Ȼ�� * y ��

  ��Ӧ�ģ�

  f0 = 0
  f1 = 1
  f2 = 2
  f3 = 3x^4 + 6Ax^2 + 12Bx - A^2
  f4 = 4 * (x^6 + 5Ax^4 + 20Bx^3 - 5A^2x^2 - 4ABx - 8B^2 - A^3)
  f5 = 5x^12 + 62Ax^10 + 380Bx^9 + 105A^2x^8 + 240BAx^7 + (-300A^3 - 240B^2)x^6
    - 696BA^2x^5 + (-125A^4 - 1920B^2A)x^4 + (-80BA^3 - 1600B^3)x^3 + (-50A^5 - 240B^2A^2)x^2
    + (100BA^4 - 640B^3A)x + (A^6 - 32B^2A^3 - 256B4)
  ......

  һ�㣺
    f2n = fn * (fn+2 * fn-1 ^ 2 - fn-2 * fn+1 ^ 2) / 2
    f2n+1 = fn+2 * fn^3 - fn-1 * fn+1^3 * (x^3 + Ax + B)^2     //  nΪ��
          = (x^3 + Ax + B)^2 * fn+2 * fn^3 - fn-1 * fn+1^3     //  nΪż

}
function Int64PolynomialGaloisCalcDivisionPolynomial(A, B: Int64; Degree: Int64;
  outDivisionPolynomial: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  N: Integer;
  MI, T1, T2: Int64;
  D1, D2, D3, Y4: TCnInt64Polynomial;
begin
  if Degree < 0 then
    raise ECnPolynomialException.Create('Galois Division Polynomial Invalid Degree')
  else if Degree = 0 then
  begin
    outDivisionPolynomial.SetCoefficents([0]);  // f0(X) = 0
    Result := True;
  end
  else if Degree = 1 then
  begin
    outDivisionPolynomial.SetCoefficents([1]);  // f1(X) = 1
    Result := True;
  end
  else if Degree = 2 then
  begin
    outDivisionPolynomial.SetCoefficents([2]);  // f2(X) = 2
    Result := True;
  end
  else if Degree = 3 then   // f3(X) = 3 X4 + 6 a X2 + 12 b X - a^2
  begin
    outDivisionPolynomial.MaxDegree := 4;
    outDivisionPolynomial[4] := 3;
    outDivisionPolynomial[3] := 0;
    outDivisionPolynomial[2] := Int64NonNegativeMulMod(6, A, Prime);
    outDivisionPolynomial[1] := Int64NonNegativeMulMod(12, B, Prime);
    outDivisionPolynomial[0] := Int64NonNegativeMulMod(-A, A, Prime);

    Result := True;
  end
  else if Degree = 4 then // f4(X) = 4 X6 + 20 a X4 + 80 b X3 - 20 a2X2 - 16 a b X - 4 a3 - 32 b^2
  begin
    outDivisionPolynomial.MaxDegree := 6;
    outDivisionPolynomial[6] := 4;
    outDivisionPolynomial[5] := 0;
    outDivisionPolynomial[4] := Int64NonNegativeMulMod(20, A, Prime);
    outDivisionPolynomial[3] := Int64NonNegativeMulMod(80, B, Prime);
    outDivisionPolynomial[2] := Int64NonNegativeMulMod(Int64NonNegativeMulMod(-20, A, Prime), A, Prime);
    outDivisionPolynomial[1] := Int64NonNegativeMulMod(Int64NonNegativeMulMod(-16, A, Prime), B, Prime);
    T1 := Int64NonNegativeMulMod(Int64NonNegativeMulMod(Int64NonNegativeMulMod(-4, A, Prime), A, Prime), A, Prime);
    T2 := Int64NonNegativeMulMod(Int64NonNegativeMulMod(-32, B, Prime), B, Prime);
    outDivisionPolynomial[0] := Int64NonNegativeMod(T1 + T2, Prime); // TODO: ��δ������������ȡģ

    Result := True;
  end
  else
  begin
    D1 := nil;
    D2 := nil;
    D3 := nil;
    Y4 := nil;

    try
      // ��ʼ�ݹ����
      N := Degree shr 1;
      if (Degree and 1) = 0 then // Degree ��ż�������� fn * (fn+2 * fn-1 ^ 2 - fn-2 * fn+1 ^ 2) / 2
      begin
        D1 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime);

        D2 := FLocalInt64PolynomialPool.Obtain;        // D1 �õ� fn+2
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);
        Int64PolynomialGaloisMul(D2, D2, D2, Prime);   // D2 �õ� fn-1 ^2

        Int64PolynomialGaloisMul(D1, D1, D2, Prime);   // D1 �õ� fn+2 * fn-1 ^ 2

        D3 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 2, D3, Prime);  // D3 �õ� fn-2

        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D2, Prime);
        Int64PolynomialGaloisMul(D2, D2, D2, Prime);   // D2 �õ� fn+1^2
        Int64PolynomialGaloisMul(D2, D2, D3, Prime);   // D2 �õ� fn-2 * fn+1^2

        Int64PolynomialGaloisSub(D1, D1, D2, Prime);   // D1 �õ� fn+2 * fn-1^2 - fn-2 * fn+1^2

        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);    // D2 �õ� fn
        Int64PolynomialGaloisMul(outDivisionPolynomial, D2, D1, Prime);     // ��˵õ� f2n
        MI := CnInt64ModularInverse(2, Prime);
        Int64PolynomialGaloisMulWord(outDivisionPolynomial, MI, Prime);     // �ٳ��� 2
      end
      else // Degree ������
      begin
        Y4 := FLocalInt64PolynomialPool.Obtain;
        Y4.SetCoefficents([B, A, 0, 1]);
        Int64PolynomialGaloisMul(Y4, Y4, Y4, Prime);

        D1 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime); // D1 �õ� fn+2

        D2 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);
        Int64PolynomialGaloisPower(D2, D2, 3, Prime);                        // D2 �õ� fn^3

        D3 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D3, Prime);
        Int64PolynomialGaloisPower(D3, D3, 3, Prime);                        // D3 �õ� fn+1^3

        if (N and 1) <> 0 then // N ������������ f2n+1 = fn+2 * fn^3 - fn-1 * fn+1^3 * (x^3 + Ax + B)^2
        begin
          Int64PolynomialGaloisMul(D1, D1, D2, Prime);  // D1 �õ� fn+2 * fn^3

          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);
          Int64PolynomialGaloisMul(D2, D2, Y4, Prime);     // D2 �õ� fn-1 * Y^4

          Int64PolynomialGaloisMul(D2, D2, D3, Prime);     // D2 �õ� fn+1^3 * fn-1 * Y^4
          Int64PolynomialGaloisSub(outDivisionPolynomial, D1, D2, Prime);
        end
        else // N ��ż�������� (x^3 + Ax + B)^2 * fn+2 * fn^3 - fn-1 * fn+1^3
        begin
          Int64PolynomialGaloisMul(D1, D1, D2, Prime);
          Int64PolynomialGaloisMul(D1, D1, Y4, Prime);   // D1 �õ� Y^4 * fn+2 * fn^3

          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);  // D2 �õ� fn-1

          Int64PolynomialGaloisMul(D2, D2, D3, Prime);  // D2 �õ� fn-1 * fn+1^3

          Int64PolynomialGaloisSub(outDivisionPolynomial, D1, D2, Prime);
        end;
      end;
    finally
      FLocalInt64PolynomialPool.Recycle(D1);
      FLocalInt64PolynomialPool.Recycle(D2);
      FLocalInt64PolynomialPool.Recycle(D3);
      FLocalInt64PolynomialPool.Recycle(Y4);
    end;
    Result := True;
  end;
end;

procedure Int64PolynomialGaloisReduce2(P1, P2: TCnInt64Polynomial; Prime: Int64);
var
  D: TCnInt64Polynomial;
begin
  if P1 = P2 then
  begin
    P1.SetOne;
    Exit;
  end;

  D := FLocalInt64PolynomialPool.Obtain;
  try
    if not Int64PolynomialGaloisGreatestCommonDivisor(D, P1, P2, Prime) then
      Exit;

    if not D.IsOne then
    begin
      Int64PolynomialGaloisDiv(P1, nil, P1, D, Prime);
      Int64PolynomialGaloisDiv(P1, nil, P1, D, Prime);
    end;
  finally
    FLocalInt64PolynomialPool.Recycle(D);
  end;
end;

{ TCnInt64PolynomialPool }

function TCnInt64PolynomialPool.CreateObject: TObject;
begin
  Result := TCnInt64Polynomial.Create;
end;

function TCnInt64PolynomialPool.Obtain: TCnInt64Polynomial;
begin
  Result := TCnInt64Polynomial(inherited Obtain);
  Result.SetZero;
end;

procedure TCnInt64PolynomialPool.Recycle(Poly: TCnInt64Polynomial);
begin
  inherited Recycle(Poly);
end;

{ TCnInt64RationalPolynomial }

procedure TCnInt64RationalPolynomial.AssignTo(Dest: TPersistent);
begin
  if Dest is TCnInt64RationalPolynomial then
  begin
    Int64PolynomialCopy(TCnInt64RationalPolynomial(Dest).Nominator, FNominator);
    Int64PolynomialCopy(TCnInt64RationalPolynomial(Dest).Denominator, FDenominator);
  end
  else
    inherited;
end;

constructor TCnInt64RationalPolynomial.Create;
begin
  inherited;
  FNominator := TCnInt64Polynomial.Create([0]);
  FDenominator := TCnInt64Polynomial.Create([1]);
end;

destructor TCnInt64RationalPolynomial.Destroy;
begin
  FDenominator.Free;
  FNominator.Free;
  inherited;
end;

function TCnInt64RationalPolynomial.IsInt: Boolean;
begin
  Result := FDenominator.IsOne or FDenominator.IsNegOne;
end;

function TCnInt64RationalPolynomial.IsOne: Boolean;
begin
  Result := not FNominator.IsZero and Int64PolynomialEqual(FNominator, FDenominator);
end;

function TCnInt64RationalPolynomial.IsZero: Boolean;
begin
  Result := not FDenominator.IsZero and FNominator.IsZero;
end;

procedure TCnInt64RationalPolynomial.Neg;
begin
  FNominator.Negate;
end;

procedure TCnInt64RationalPolynomial.Reciprocal;
var
  T: TCnInt64Polynomial;
begin
  if FNominator.IsZero then
    raise EDivByZero.Create(SDivByZero);

  T := FLocalInt64PolynomialPool.Obtain;
  try
    Int64PolynomialCopy(T, FDenominator);
    Int64PolynomialCopy(FDenominator, FNominator);
    Int64PolynomialCopy(FNominator, T);
  finally
    FLocalInt64PolynomialPool.Recycle(T);
  end;
end;

procedure TCnInt64RationalPolynomial.Reduce;
begin
  Int64PolynomialReduce2(FNominator, FDenominator);
end;

procedure TCnInt64RationalPolynomial.SetOne;
begin
  FDenominator.SetOne;
  FNominator.SetOne;
end;

procedure TCnInt64RationalPolynomial.SetString(const Rational: string);
var
  P: Integer;
  N, D: string;
begin
  P := Pos('/', Rational);
  if P > 1 then
  begin
    N := Copy(Rational, 1, P - 1);
    D := Copy(Rational, P + 1, MaxInt);

    FNominator.SetString(Trim(N));
    FDenominator.SetString(Trim(D));
  end
  else
  begin
    FNominator.SetString(Rational);
    FDenominator.SetOne;
  end;
end;

procedure TCnInt64RationalPolynomial.SetZero;
begin
  FDenominator.SetOne;
  FNominator.SetZero;
end;

function TCnInt64RationalPolynomial.ToString: string;
begin
  if FDenominator.IsOne then
    Result := FNominator.ToString
  else if FNominator.IsZero then
    Result := '0'
  else
    Result := FNominator.ToString + ' / ' + FDenominator.ToString;
end;

// ============================= �����ʽ���� ==================================

function Int64RationalPolynomialEqual(R1, R2: TCnInt64RationalPolynomial): Boolean;
var
  T1, T2: TCnInt64Polynomial;
begin
  if R1 = R2 then
  begin
    Result := True;
    Exit;
  end;

  if R1.IsInt and R2.IsInt then
  begin
    Result := Int64PolynomialEqual(R1.Nominator, R2.Nominator);
    Exit;
  end;

  T1 := FLocalInt64PolynomialPool.Obtain;
  T2 := FLocalInt64PolynomialPool.Obtain;

  try
    // �жϷ��ӷ�ĸ����˵Ľ���Ƿ����
    Int64PolynomialMul(T1, R1.Nominator, R2.Denominator);
    Int64PolynomialMul(T2, R2.Nominator, R1.Denominator);
    Result := Int64PolynomialEqual(T1, T2);
  finally
    FLocalInt64PolynomialPool.Recycle(T2);
    FLocalInt64PolynomialPool.Recycle(T1);
  end;
end;

function Int64RationalPolynomialCopy(const Dst: TCnInt64RationalPolynomial;
  const Src: TCnInt64RationalPolynomial): TCnInt64RationalPolynomial;
begin
  Result := Dst;
  if Src <> Dst then
  begin
    Int64PolynomialCopy(Dst.Nominator, Src.Nominator);
    Int64PolynomialCopy(Dst.Denominator, Src.Denominator);
  end;
end;

procedure Int64RationalPolynomialAdd(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial);
var
  M, R, F1, F2, D1, D2: TCnInt64Polynomial;
begin
  if R1.IsInt and R2.IsInt then
  begin
    Int64PolynomialAdd(RationalResult.Nominator, R1.Nominator, R2.Nominator);
    RationalResult.Denominator.SetOne;
    Exit;
  end
  else if R1.IsZero then
  begin
    if R2 <> RationalResult then
      RationalResult.Assign(R2);
  end
  else if R2.IsZero then
  begin
    if R1 <> RationalResult then
      RationalResult.Assign(R1);
  end
  else
  begin
    M := nil;
    R := nil;
    F1 := nil;
    F2 := nil;
    D1 := nil;
    D2 := nil;

    try
      // ���ĸ����С������
      M := FLocalInt64PolynomialPool.Obtain;
      R := FLocalInt64PolynomialPool.Obtain;
      F1 := FLocalInt64PolynomialPool.Obtain;
      F2 := FLocalInt64PolynomialPool.Obtain;
      D1 := FLocalInt64PolynomialPool.Obtain;
      D2 := FLocalInt64PolynomialPool.Obtain;

      Int64PolynomialCopy(D1, R1.Denominator);
      Int64PolynomialCopy(D2, R2.Denominator);

      if not Int64PolynomialLeastCommonMultiple(M, D1, D2) then
        Int64PolynomialMul(M, D1, D2);   // �޷�����С����ʽ��ʾϵ���޷�������ֱ�����

      Int64PolynomialDiv(F1, R, M, D1);
      Int64PolynomialDiv(F2, R, M, D2);

      Int64PolynomialCopy(RationalResult.Denominator, M);
      Int64PolynomialMul(R, R1.Nominator, F1);
      Int64PolynomialMul(M, R2.Nominator, F2);
      Int64PolynomialAdd(RationalResult.Nominator, R, M);
    finally
      FLocalInt64PolynomialPool.Recycle(M);
      FLocalInt64PolynomialPool.Recycle(R);
      FLocalInt64PolynomialPool.Recycle(F1);
      FLocalInt64PolynomialPool.Recycle(F2);
      FLocalInt64PolynomialPool.Recycle(D1);
      FLocalInt64PolynomialPool.Recycle(D2);
    end;
  end;
end;

procedure Int64RationalPolynomialSub(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial);
begin
  R2.Nominator.Negate;
  Int64RationalPolynomialAdd(R1, R2, RationalResult);
  if RationalResult <> R2 then
    R2.Nominator.Negate;
end;

procedure Int64RationalPolynomialMul(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial);
begin
  Int64PolynomialMul(RationalResult.Nominator, R1.Nominator, R2.Nominator);
  Int64PolynomialMul(RationalResult.Denominator, R1.Denominator, R2.Denominator);
end;

procedure Int64RationalPolynomialDiv(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial);
var
  N: TCnInt64Polynomial;
begin
  if R2.IsZero then
    raise EDivByZero.Create('Divide by Zero.');

  N := FLocalInt64PolynomialPool.Obtain; // ������ˣ��������м��������ֹ RationalResult �� Number1 �� Number 2
  try
    Int64PolynomialMul(N, R1.Nominator, R2.Denominator);
    Int64PolynomialMul(RationalResult.Denominator, R1.Denominator, R2.Nominator);
    Int64PolynomialCopy(RationalResult.Nominator, N);
  finally
    FLocalInt64PolynomialPool.Recycle(N);
  end;
end;

procedure Int64RationalPolynomialAddWord(R: TCnInt64RationalPolynomial; N: Int64);
var
  P: TCnInt64Polynomial;
begin
  P := FLocalInt64PolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    P[0] := N;
    Int64RationalPolynomialAdd(R, P, R);
  finally
    FLocalInt64PolynomialPool.Recycle(P);
  end;
end;

procedure Int64RationalPolynomialSubWord(R: TCnInt64RationalPolynomial; N: Int64);
var
  P: TCnInt64Polynomial;
begin
  P := FLocalInt64PolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    P[0] := N;
    Int64RationalPolynomialSub(R, P, R);
  finally
    FLocalInt64PolynomialPool.Recycle(P);
  end;
end;

procedure Int64RationalPolynomialMulWord(R: TCnInt64RationalPolynomial; N: Int64);
var
  P: TCnInt64Polynomial;
begin
  P := FLocalInt64PolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    P[0] := N;
    Int64RationalPolynomialMul(R, P, R);
  finally
    FLocalInt64PolynomialPool.Recycle(P);
  end;
end;

procedure Int64RationalPolynomialDivWord(R: TCnInt64RationalPolynomial; N: Int64);
var
  P: TCnInt64Polynomial;
begin
  P := FLocalInt64PolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    P[0] := N;
    Int64RationalPolynomialDiv(R, P, R);
  finally
    FLocalInt64PolynomialPool.Recycle(P);
  end;
end;

procedure Int64RationalPolynomialAdd(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial);
var
  T: TCnInt64RationalPolynomial;
begin
  if P1.IsZero then
  begin
    if R1 <> RationalResult then
    begin
      Int64RationalPolynomialCopy(RationalResult, R1);
      Exit;
    end;
  end;

  T := FLocalInt64RationalPolynomialPool.Obtain;
  try
    T.Denominator.SetOne;
    Int64PolynomialCopy(T.Nominator, P1);
    Int64RationalPolynomialAdd(R1, T, RationalResult);
  finally
    FLocalInt64RationalPolynomialPool.Recycle(T);
  end;
end;

procedure Int64RationalPolynomialSub(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial);
begin
  P1.Negate;
  try
    Int64RationalPolynomialAdd(R1, P1, RationalResult);
  finally
    P1.Negate;
  end;
end;

procedure Int64RationalPolynomialMul(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial);
begin
  if P1.IsZero then
    RationalResult.SetZero
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    Int64PolynomialMul(RationalResult.Nominator, R1.Nominator, P1);
    Int64PolynomialCopy(RationalResult.Denominator, R1.Denominator);
  end;
end;

procedure Int64RationalPolynomialDiv(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial);
begin
  if P1.IsZero then
    raise EDivByZero.Create('Divide by Zero.')
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    Int64PolynomialMul(RationalResult.Denominator, R1.Denominator, P1);
    Int64PolynomialCopy(RationalResult.Nominator, R1.Nominator);
  end;
end;

function Int64RationalPolynomialCompose(Res: TCnInt64RationalPolynomial;
  F, P: TCnInt64RationalPolynomial): Boolean;
var
  RN, RD: TCnInt64RationalPolynomial;
begin
  if P.IsInt then
    Result := Int64RationalPolynomialCompose(Res, F, P.Nominator)
  else
  begin
    RD := FLocalInt64RationalPolynomialPool.Obtain;
    RN := FLocalInt64RationalPolynomialPool.Obtain;

    try
      Int64RationalPolynomialCompose(RN, F.Nominator, P);
      Int64RationalPolynomialCompose(RD, F.Denominator, P);

      Int64PolynomialMul(Res.Nominator, RN.Nominator, RD.Denominator);
      Int64PolynomialMul(Res.Denominator, RN.Denominator, RD.Nominator);
      Result := True;
    finally
      FLocalInt64RationalPolynomialPool.Recycle(RN);
      FLocalInt64RationalPolynomialPool.Recycle(RD);
    end;
  end;
end;

function Int64RationalPolynomialCompose(Res: TCnInt64RationalPolynomial;
  F: TCnInt64RationalPolynomial; P: TCnInt64Polynomial): Boolean;
begin
  Int64PolynomialCompose(Res.Nominator, F.Nominator, P);
  Int64PolynomialCompose(Res.Denominator, F.Denominator, P);
  Result := True;
end;

function Int64RationalPolynomialCompose(Res: TCnInt64RationalPolynomial;
  F: TCnInt64Polynomial; P: TCnInt64RationalPolynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnInt64RationalPolynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    Res.Nominator[0] := F[0];
    Result := True;
    Exit;
  end;

  if Res = P then
    R := FLocalInt64RationalPolynomialPool.Obtain
  else
    R := Res;

  X := FLocalInt64RationalPolynomialPool.Obtain;
  T := FLocalInt64RationalPolynomialPool.Obtain;

  try
    X.SetOne;
    R.SetZero;

    // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
    for I := 0 to F.MaxDegree do
    begin
      Int64RationalPolynomialCopy(T, X);
      Int64RationalPolynomialMulWord(T, F[I]);
      Int64RationalPolynomialAdd(R, T, R);

      if I <> F.MaxDegree then
        Int64RationalPolynomialMul(X, P, X);
    end;

    if Res = P then
    begin
      Int64RationalPolynomialCopy(Res, R);
      FLocalInt64RationalPolynomialPool.Recycle(R);
    end;
  finally
    FLocalInt64RationalPolynomialPool.Recycle(X);
    FLocalInt64RationalPolynomialPool.Recycle(T);
  end;
  Result := True;
end;

procedure Int64RationalPolynomialGetValue(const F: TCnInt64RationalPolynomial;
  X: Int64; outResult: TCnRationalNumber);
begin
  outResult.Nominator := Int64PolynomialGetValue(F.Nominator, X);
  outResult.Denominator := Int64PolynomialGetValue(F.Denominator, X);
  outResult.Reduce;
end;

// ====================== �����ʽ���������ϵ�ģ���� ===========================

function Int64RationalPolynomialGaloisEqual(R1, R2: TCnInt64RationalPolynomial;
  Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  T1, T2: TCnInt64Polynomial;
begin
  if R1 = R2 then
  begin
    Result := True;
    Exit;
  end;

  T1 := FLocalInt64PolynomialPool.Obtain;
  T2 := FLocalInt64PolynomialPool.Obtain;

  try
    // �жϷ��ӷ�ĸ����˵Ľ���Ƿ����
    Int64PolynomialGaloisMul(T1, R1.Nominator, R2.Denominator, Prime, Primitive);
    Int64PolynomialGaloisMul(T2, R2.Nominator, R1.Denominator, Prime, Primitive);
    Result := Int64PolynomialGaloisEqual(T1, T2, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(T2);
    FLocalInt64PolynomialPool.Recycle(T1);
  end;
end;

procedure Int64RationalPolynomialGaloisNegate(const P: TCnInt64RationalPolynomial;
  Prime: Int64);
begin
  Int64PolynomialGaloisNegate(P.Nominator, Prime);
end;

procedure Int64RationalPolynomialGaloisAdd(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64);
var
  M, R, F1, F2, D1, D2: TCnInt64Polynomial;
begin
  if R1.IsInt and R2.IsInt then
  begin
    Int64PolynomialGaloisAdd(RationalResult.Nominator, R1.Nominator,
      R2.Nominator, Prime);
    RationalResult.Denominator.SetOne;
    Exit;
  end
  else if R1.IsZero then
  begin
    if R2 <> RationalResult then
      RationalResult.Assign(R2);
  end
  else if R2.IsZero then
  begin
    if R1 <> RationalResult then
      RationalResult.Assign(R1);
  end
  else
  begin
    M := nil;
    R := nil;
    F1 := nil;
    F2 := nil;
    D1 := nil;
    D2 := nil;

    try
      // ���ĸ����С������
      M := FLocalInt64PolynomialPool.Obtain;
      R := FLocalInt64PolynomialPool.Obtain;
      F1 := FLocalInt64PolynomialPool.Obtain;
      F2 := FLocalInt64PolynomialPool.Obtain;
      D1 := FLocalInt64PolynomialPool.Obtain;
      D2 := FLocalInt64PolynomialPool.Obtain;

      Int64PolynomialCopy(D1, R1.Denominator);
      Int64PolynomialCopy(D2, R2.Denominator);

      if not Int64PolynomialGaloisLeastCommonMultiple(M, D1, D2, Prime) then
        Int64PolynomialGaloisMul(M, D1, D2, Prime);   // �޷�����С����ʽ��ʾϵ���޷�������ֱ�����

      Int64PolynomialGaloisDiv(F1, R, M, D1, Prime);  // ��С������ M div D1 ����� F1
      Int64PolynomialGaloisDiv(F2, R, M, D2, Prime);  // ��С������ M div D2 ����� F2

      Int64PolynomialCopy(RationalResult.Denominator, M);  // ����ķ�ĸ����С������
      Int64PolynomialGaloisMul(R, R1.Nominator, F1, Prime);
      Int64PolynomialGaloisMul(M, R2.Nominator, F2, Prime);
      Int64PolynomialGaloisAdd(RationalResult.Nominator, R, M, Prime);
    finally
      FLocalInt64PolynomialPool.Recycle(M);
      FLocalInt64PolynomialPool.Recycle(R);
      FLocalInt64PolynomialPool.Recycle(F1);
      FLocalInt64PolynomialPool.Recycle(F2);
      FLocalInt64PolynomialPool.Recycle(D1);
      FLocalInt64PolynomialPool.Recycle(D2);
    end;
  end;
end;

procedure Int64RationalPolynomialGaloisSub(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64);
begin
  R2.Nominator.Negate;
  Int64RationalPolynomialGaloisAdd(R1, R2, RationalResult, Prime);
  if RationalResult <> R2 then
    R2.Nominator.Negate;
end;

procedure Int64RationalPolynomialGaloisMul(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64);
begin
  Int64PolynomialGaloisMul(RationalResult.Nominator, R1.Nominator, R2.Nominator, Prime);
  Int64PolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, R2.Denominator, Prime);
end;

procedure Int64RationalPolynomialGaloisDiv(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64);
var
  N: TCnInt64Polynomial;
begin
  if R2.IsZero then
    raise EDivByZero.Create('Divide by Zero.');

  N := FLocalInt64PolynomialPool.Obtain; // ������ˣ��������м��������ֹ RationalResult �� Number1 �� Number 2
  try
    Int64PolynomialGaloisMul(N, R1.Nominator, R2.Denominator, Prime);
    Int64PolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, R2.Nominator, Prime);
    Int64PolynomialCopy(RationalResult.Nominator, N);
  finally
    FLocalInt64PolynomialPool.Recycle(N);
  end;
end;

procedure Int64RationalPolynomialGaloisAddWord(R: TCnInt64RationalPolynomial;
  N: Int64; Prime: Int64);
var
  P: TCnInt64Polynomial;
begin
  P := FLocalInt64PolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    P[0] := N;
    Int64RationalPolynomialGaloisAdd(R, P, R, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(P);
  end;
end;

procedure Int64RationalPolynomialGaloisSubWord(R: TCnInt64RationalPolynomial;
  N: Int64; Prime: Int64);
var
  P: TCnInt64Polynomial;
begin
  P := FLocalInt64PolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    P[0] := N;
    Int64RationalPolynomialGaloisSub(R, P, R, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(P);
  end;
end;

procedure Int64RationalPolynomialGaloisMulWord(R: TCnInt64RationalPolynomial;
  N: Int64; Prime: Int64);
var
  P: TCnInt64Polynomial;
begin
  P := FLocalInt64PolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    P[0] := N;
    Int64RationalPolynomialGaloisMul(R, P, R, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(P);
  end;
end;

procedure Int64RationalPolynomialGaloisDivWord(R: TCnInt64RationalPolynomial;
  N: Int64; Prime: Int64);
var
  P: TCnInt64Polynomial;
begin
  P := FLocalInt64PolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    P[0] := N;
    Int64RationalPolynomialGaloisDiv(R, P, R, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(P);
  end;
end;

procedure Int64RationalPolynomialGaloisAdd(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
var
  T: TCnInt64RationalPolynomial;
begin
  if P1.IsZero then
  begin
    if R1 <> RationalResult then
    begin
      Int64RationalPolynomialCopy(RationalResult, R1);
      Exit;
    end;
  end;

  T := FLocalInt64RationalPolynomialPool.Obtain;
  try
    T.Denominator.SetOne;
    Int64PolynomialCopy(T.Nominator, P1);
    Int64RationalPolynomialGaloisAdd(R1, T, RationalResult, Prime);
  finally
    FLocalInt64RationalPolynomialPool.Recycle(T);
  end;
end;

procedure Int64RationalPolynomialGaloisSub(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
begin
  P1.Negate;
  try
    Int64RationalPolynomialGaloisAdd(R1, P1, RationalResult, Prime);
  finally
    P1.Negate;
  end;
end;

procedure Int64RationalPolynomialGaloisMul(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
begin
  if P1.IsZero then
    RationalResult.SetZero
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    Int64PolynomialGaloisMul(RationalResult.Nominator, R1.Nominator, P1, Prime);
    Int64PolynomialCopy(RationalResult.Denominator, R1.Denominator);
  end;
end;

procedure Int64RationalPolynomialGaloisDiv(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
begin
  if P1.IsZero then
    raise EDivByZero.Create('Divide by Zero.')
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    Int64PolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, P1, Prime);
    Int64PolynomialCopy(RationalResult.Nominator, R1.Nominator);
  end;
end;

function Int64RationalPolynomialGaloisCompose(Res: TCnInt64RationalPolynomial;
  F, P: TCnInt64RationalPolynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  RN, RD: TCnInt64RationalPolynomial;
begin
  if P.IsInt then
    Result := Int64RationalPolynomialGaloisCompose(Res, F, P.Nominator, Prime, Primitive)
  else
  begin
    RD := FLocalInt64RationalPolynomialPool.Obtain;
    RN := FLocalInt64RationalPolynomialPool.Obtain;

    try
      Int64RationalPolynomialGaloisCompose(RN, F.Nominator, P, Prime, Primitive);
      Int64RationalPolynomialGaloisCompose(RD, F.Denominator, P, Prime, Primitive);

      Int64PolynomialGaloisMul(Res.Nominator, RN.Nominator, RD.Denominator, Prime);
      Int64PolynomialGaloisMul(Res.Denominator, RN.Denominator, RD.Nominator, Prime);

      if Primitive <> nil then
      begin
        Int64PolynomialGaloisMod(Res.Nominator, Res.Nominator, Primitive, Prime);
        Int64PolynomialGaloisMod(Res.Denominator, Res.Denominator, Primitive, Prime);
      end;
      Result := True;
    finally
      FLocalInt64RationalPolynomialPool.Recycle(RN);
      FLocalInt64RationalPolynomialPool.Recycle(RD);
    end;
  end;
end;

function Int64RationalPolynomialGaloisCompose(Res: TCnInt64RationalPolynomial;
  F: TCnInt64RationalPolynomial; P: TCnInt64Polynomial; Prime: Int64;
  Primitive: TCnInt64Polynomial): Boolean;
begin
  Int64PolynomialGaloisCompose(Res.Nominator, F.Nominator, P, Prime, Primitive);
  Int64PolynomialGaloisCompose(Res.Denominator, F.Denominator, P, Prime, Primitive);
  Result := True;
end;

function Int64RationalPolynomialGaloisCompose(Res: TCnInt64RationalPolynomial;
  F: TCnInt64Polynomial; P: TCnInt64RationalPolynomial; Prime: Int64;
  Primitive: TCnInt64Polynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnInt64RationalPolynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    Res.Nominator[0] := Int64NonNegativeMod(F[0], Prime);
    Result := True;
    Exit;
  end;

  if Res = P then
    R := FLocalInt64RationalPolynomialPool.Obtain
  else
    R := Res;

  X := FLocalInt64RationalPolynomialPool.Obtain;
  T := FLocalInt64RationalPolynomialPool.Obtain;

  try
    X.SetOne;
    R.SetZero;

    // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
    for I := 0 to F.MaxDegree do
    begin
      Int64RationalPolynomialCopy(T, X);
      Int64RationalPolynomialGaloisMulWord(T, F[I], Prime);
      Int64RationalPolynomialGaloisAdd(R, T, R, Prime);

      if I <> F.MaxDegree then
        Int64RationalPolynomialGaloisMul(X, P, X, Prime);
    end;

    if Primitive <> nil then
    begin
      Int64PolynomialGaloisMod(R.Nominator, R.Nominator, Primitive, Prime);
      Int64PolynomialGaloisMod(R.Denominator, R.Denominator, Primitive, Prime);
    end;

    if Res = P then
    begin
      Int64RationalPolynomialCopy(Res, R);
      FLocalInt64RationalPolynomialPool.Recycle(R);
    end;
  finally
    FLocalInt64RationalPolynomialPool.Recycle(X);
    FLocalInt64RationalPolynomialPool.Recycle(T);
  end;
  Result := True;
end;

function Int64RationalPolynomialGaloisGetValue(const F: TCnInt64RationalPolynomial;
  X: Int64; Prime: Int64): Int64;
var
  N, D: Int64;
begin
  D := Int64PolynomialGaloisGetValue(F.Denominator, X, Prime);
  if D = 0 then
    raise EDivByZero.Create(SDivByZero);

  N := Int64PolynomialGaloisGetValue(F.Nominator, X, Prime);
  Result := Int64NonNegativeMulMod(N, CnInt64ModularInverse2(D, Prime), Prime);
end;

{ TCnBigNumberPolynomial }

procedure TCnBigNumberPolynomial.CorrectTop;
begin
  while (MaxDegree > 0) and Items[MaxDegree].IsZero do
    Delete(MaxDegree);
end;

constructor TCnBigNumberPolynomial.Create;
begin
  inherited Create;
  Add.SetZero;   // ��ϵ����
end;

constructor TCnBigNumberPolynomial.Create(
  LowToHighCoefficients: array of const);
begin
  inherited Create;
  SetCoefficents(LowToHighCoefficients);
end;

destructor TCnBigNumberPolynomial.Destroy;
begin

  inherited;
end;

function TCnBigNumberPolynomial.GetMaxDegree: Integer;
begin
  if Count = 0 then
    Add.SetZero;
  Result := Count - 1;
end;

function TCnBigNumberPolynomial.IsMonic: Boolean;
begin
  Result := BigNumberPolynomialIsMonic(Self);
end;

function TCnBigNumberPolynomial.IsNegOne: Boolean;
begin
  Result := BigNumberPolynomialIsNegOne(Self);
end;

function TCnBigNumberPolynomial.IsOne: Boolean;
begin
  Result := BigNumberPolynomialIsOne(Self);
end;

function TCnBigNumberPolynomial.IsZero: Boolean;
begin
  Result := BigNumberPolynomialIsZero(Self);
end;

procedure TCnBigNumberPolynomial.Negate;
begin
  BigNumberPolynomialNegate(Self);
end;

procedure TCnBigNumberPolynomial.SetCoefficents(
  LowToHighCoefficients: array of const);
var
  I: Integer;
begin
  Clear;
  for I := Low(LowToHighCoefficients) to High(LowToHighCoefficients) do
  begin
    case LowToHighCoefficients[I].VType of
    vtInteger:
      begin
        Add.SetInteger(LowToHighCoefficients[I].VInteger);
      end;
    vtInt64:
      begin
        Add.SetInt64(LowToHighCoefficients[I].VInt64^);
      end;
    vtBoolean:
      begin
        if LowToHighCoefficients[I].VBoolean then
          Add.SetOne
        else
          Add.SetZero;
      end;
    vtString:
      begin
        Add.SetDec(LowToHighCoefficients[I].VString^);
      end;
    vtObject:
      begin
        // ���� TCnBigNumber �����и���ֵ
        if LowToHighCoefficients[I].VObject is TCnBigNumber then
          BigNumberCopy(Add, LowToHighCoefficients[I].VObject as TCnBigNumber);
      end;
    else
      raise ECnPolynomialException.CreateFmt(SInvalidInteger, ['Coefficients ' + IntToStr(I)]);
    end;
  end;

  if Count = 0 then
    Add.SetZero
  else
    CorrectTop;
end;

procedure TCnBigNumberPolynomial.SetMaxDegree(const Value: Integer);
var
  I, OC: Integer;
begin
  CheckDegree(Value);

  OC := Count;
  Count := Value + 1; // ֱ������ Count�����С�����Զ��ͷŶ���Ķ���

  if Count > OC then  // ���ӵĲ��ִ����¶���
  begin
    for I := OC to Count - 1 do
      Items[I] := TCnBigNumber.Create;
  end;
end;

procedure TCnBigNumberPolynomial.SetOne;
begin
  BigNumberPolynomialSetOne(Self);
end;

procedure TCnBigNumberPolynomial.SetString(const Poly: string);
begin
  BigNumberPolynomialSetString(Self, Poly);
end;

procedure TCnBigNumberPolynomial.SetZero;
begin
  BigNumberPolynomialSetZero(Self);
end;

function TCnBigNumberPolynomial.ToString: string;
begin
  Result := BigNumberPolynomialToString(Self);
end;

{ TCnBigNumberRationalPolynomial }

procedure TCnBigNumberRationalPolynomial.AssignTo(Dest: TPersistent);
begin
  if Dest is TCnBigNumberRationalPolynomial then
  begin
    BigNumberPolynomialCopy(TCnBigNumberRationalPolynomial(Dest).Nominator, FNominator);
    BigNumberPolynomialCopy(TCnBigNumberRationalPolynomial(Dest).Denominator, FDenominator);
  end
  else
    inherited;
end;

constructor TCnBigNumberRationalPolynomial.Create;
begin
  inherited;
  FNominator := TCnBigNumberPolynomial.Create([0]);
  FDenominator := TCnBigNumberPolynomial.Create([1]);
end;

destructor TCnBigNumberRationalPolynomial.Destroy;
begin
  FDenominator.Free;
  FNominator.Free;
  inherited;
end;

function TCnBigNumberRationalPolynomial.IsInt: Boolean;
begin
  Result := FDenominator.IsOne or FDenominator.IsNegOne;
end;

function TCnBigNumberRationalPolynomial.IsOne: Boolean;
begin
  Result := not FNominator.IsZero and BigNumberPolynomialEqual(FNominator, FDenominator);
end;

function TCnBigNumberRationalPolynomial.IsZero: Boolean;
begin
  Result := not FDenominator.IsZero and FNominator.IsZero;
end;

procedure TCnBigNumberRationalPolynomial.Neg;
begin
  FNominator.Negate;
end;

procedure TCnBigNumberRationalPolynomial.Reciprocal;
var
  T: TCnBigNumberPolynomial;
begin
  if FNominator.IsZero then
    raise EDivByZero.Create(SDivByZero);

  T := FLocalBigNumberPolynomialPool.Obtain;
  try
    BigNumberPolynomialCopy(T, FDenominator);
    BigNumberPolynomialCopy(FDenominator, FNominator);
    BigNumberPolynomialCopy(FNominator, T);
  finally
    FLocalBigNumberPolynomialPool.Recycle(T);
  end;
end;

procedure TCnBigNumberRationalPolynomial.Reduce;
begin
  BigNumberPolynomialReduce2(FNominator, FDenominator);
end;

procedure TCnBigNumberRationalPolynomial.SetOne;
begin
  FDenominator.SetOne;
  FNominator.SetOne;
end;

procedure TCnBigNumberRationalPolynomial.SetString(const Rational: string);
var
  P: Integer;
  N, D: string;
begin
  P := Pos('/', Rational);
  if P > 1 then
  begin
    N := Copy(Rational, 1, P - 1);
    D := Copy(Rational, P + 1, MaxInt);

    FNominator.SetString(Trim(N));
    FDenominator.SetString(Trim(D));
  end
  else
  begin
    FNominator.SetString(Rational);
    FDenominator.SetOne;
  end;
end;

procedure TCnBigNumberRationalPolynomial.SetZero;
begin
  FDenominator.SetOne;
  FNominator.SetZero;
end;

function TCnBigNumberRationalPolynomial.ToString: string;
begin
  if FDenominator.IsOne then
    Result := FNominator.ToString
  else if FNominator.IsZero then
    Result := '0'
  else
    Result := FNominator.ToString + ' / ' + FDenominator.ToString;
end;

{ TCnBigNumberPolynomialPool }

function TCnBigNumberPolynomialPool.CreateObject: TObject;
begin
  Result := TCnBigNumberPolynomial.Create;
end;

function TCnBigNumberPolynomialPool.Obtain: TCnBigNumberPolynomial;
begin
  Result := TCnBigNumberPolynomial(inherited Obtain);
  Result.SetZero;
end;

procedure TCnBigNumberPolynomialPool.Recycle(Poly: TCnBigNumberPolynomial);
begin
  inherited Recycle(Poly);
end;

{ TCnInt64RationalPolynomialPool }

function TCnInt64RationalPolynomialPool.CreateObject: TObject;
begin
  Result := TCnInt64RationalPolynomial.Create;
end;

function TCnInt64RationalPolynomialPool.Obtain: TCnInt64RationalPolynomial;
begin
  Result := TCnInt64RationalPolynomial(inherited Obtain);
  Result.SetZero;
end;

procedure TCnInt64RationalPolynomialPool.Recycle(Poly: TCnInt64RationalPolynomial);
begin
  inherited Recycle(Poly);
end;

function BigNumberPolynomialNew: TCnBigNumberPolynomial;
begin
  Result := TCnBigNumberPolynomial.Create;
end;

procedure BigNumberPolynomialFree(const P: TCnBigNumberPolynomial);
begin
  P.Free;
end;

function BigNumberPolynomialDuplicate(const P: TCnBigNumberPolynomial): TCnBigNumberPolynomial;
begin
  if P = nil then
  begin
    Result := nil;
    Exit;
  end;

  Result := BigNumberPolynomialNew;
  if Result <> nil then
    BigNumberPolynomialCopy(Result, P);
end;

function BigNumberPolynomialCopy(const Dst: TCnBigNumberPolynomial;
  const Src: TCnBigNumberPolynomial): TCnBigNumberPolynomial;
var
  I: Integer;
begin
  Result := Dst;
  if Src <> Dst then
  begin
    Dst.Clear;
    for I := 0 to Src.Count - 1 do
      Dst.Add(BigNumberDuplicate(Src[I]));
    Dst.CorrectTop;
  end;
end;

function BigNumberPolynomialToString(const P: TCnBigNumberPolynomial;
  const VarName: string = 'X'): string;
var
  I: Integer;
begin
  Result := '';
  if BigNumberPolynomialIsZero(P) then
  begin
    Result := '0';
    Exit;
  end;

  for I := P.MaxDegree downto 0 do
  begin
    if VarItemFactor(Result, (I = 0), P[I].ToDec) then
      Result := Result + VarPower(VarName, I);
  end;
end;

function BigNumberPolynomialSetString(const P: TCnBigNumberPolynomial;
  const Str: string; const VarName: Char = 'X'): Boolean;
var
  C, Ptr: PChar;
  Num, ES: string;
  MDFlag, E: Integer;
  IsNeg: Boolean;
begin
  Result := False;
  if Str = '' then
    Exit;

  MDFlag := -1;
  C := @Str[1];

  while C^ <> #0 do
  begin
    if not (C^ in ['+', '-', '0'..'9']) and (C^ <> VarName) then
    begin
      Inc(C);
      Continue;
    end;

    IsNeg := False;
    if C^ = '+' then
      Inc(C)
    else if C^ = '-' then
    begin
      IsNeg := True;
      Inc(C);
    end;

    Num := '1';
    if C^ in ['0'..'9'] then // ��ϵ��
    begin
      Ptr := C;
      while C^ in ['0'..'9'] do
        Inc(C);

      // Ptr �� C ֮�������֣�����һ��ϵ��
      SetString(Num, Ptr, C - Ptr);
      if IsNeg then
        Num := '-' + Num;
    end
    else if IsNeg then
      Num := '-' + Num;

    if C^ = VarName then
    begin
      E := 1;
      Inc(C);
      if C^ = '^' then // ��ָ��
      begin
        Inc(C);
        if C^ in ['0'..'9'] then
        begin
          Ptr := C;
          while C^ in ['0'..'9'] do
            Inc(C);

          // Ptr �� C ֮�������֣�����һ��ָ��
          SetString(ES, Ptr, C - Ptr);
          E := StrToInt64(ES);
        end;
      end;
    end
    else
      E := 0;

    // ָ�������ˣ���
    if MDFlag = -1 then // ��һ��ָ���� MaxDegree
    begin
      P.MaxDegree := E;
      MDFlag := 0;
    end;

    P[E].SetDec(Num);
  end;
end;

function BigNumberPolynomialIsZero(const P: TCnBigNumberPolynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and P[0].IsZero;
end;

procedure BigNumberPolynomialSetZero(const P: TCnBigNumberPolynomial);
begin
  P.Clear;
  P.Add.SetZero;
end;

function BigNumberPolynomialIsOne(const P: TCnBigNumberPolynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and P[0].IsOne;
end;

procedure BigNumberPolynomialSetOne(const P: TCnBigNumberPolynomial);
begin
  P.Clear;
  P.Add.SetOne;
end;

function BigNumberPolynomialIsNegOne(const P: TCnBigNumberPolynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and P[0].IsNegOne;
end;

procedure BigNumberPolynomialNegate(const P: TCnBigNumberPolynomial);
var
  I: Integer;
begin
  for I := 0 to P.MaxDegree do
    P[I].Negate;
end;

function BigNumberPolynomialIsMonic(const P: TCnBigNumberPolynomial): Boolean;
begin
  Result := P[P.MaxDegree].IsOne;
end;

procedure BigNumberPolynomialShiftLeft(const P: TCnBigNumberPolynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    Exit
  else if N < 0 then
    BigNumberPolynomialShiftRight(P, -N)
  else
    for I := 1 to N do
      P.Insert(0, TCnBigNumber.Create);
end;

procedure BigNumberPolynomialShiftRight(const P: TCnBigNumberPolynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    Exit
  else if N < 0 then
    BigNumberPolynomialShiftLeft(P, -N)
  else
  begin
    for I := 1 to N do
      P.Delete(0);

    if P.Count = 0 then
      P.Add.SetZero;
  end;
end;

function BigNumberPolynomialEqual(const A, B: TCnBigNumberPolynomial): Boolean;
var
  I: Integer;
begin
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  Result := A.MaxDegree = B.MaxDegree;
  if Result then
  begin
    for I := A.MaxDegree downto 0 do
    begin
      if BigNumberCompare(A[I], B[I]) <> 0 then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

// ======================== һԪ����ϵ������ʽ��ͨ���� =============================

procedure BigNumberPolynomialAddWord(const P: TCnBigNumberPolynomial; N: LongWord);
begin
  if N <> 0 then
    BigNumberAddWord(P[0], N);
end;

procedure BigNumberPolynomialSubWord(const P: TCnBigNumberPolynomial; N: LongWord);
begin
  if N <> 0 then
    BigNumberSubWord(P[0], N);
end;

procedure BigNumberPolynomialMulWord(const P: TCnBigNumberPolynomial; N: LongWord);
var
  I: Integer;
begin
  if N = 0 then
    BigNumberPolynomialSetZero(P)
  else if N <> 1 then
  begin
    for I := 0 to P.MaxDegree do
      BigNumberMulWord(P[I], N);
  end;
end;

procedure BigNumberPolynomialDivWord(const P: TCnBigNumberPolynomial; N: LongWord);
var
  I: Integer;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SZeroDivide)
  else if N <> 1 then
    for I := 0 to P.MaxDegree do
      BigNumberDivWord(P[I], N);
end;

procedure BigNumberPolynomialNonNegativeModWord(const P: TCnBigNumberPolynomial; N: LongWord);
var
  I: Integer;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SZeroDivide);

  for I := 0 to P.MaxDegree do
  begin
    BigNumberModWord(P[I], N);
    if P[I].IsNegative then
      BigNumberAddWord(P[I], N);
  end;
end;

procedure BigNumberPolynomialAddBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
begin
  BigNumberAdd(P[0], P[0], N);
end;

procedure BigNumberPolynomialSubBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
begin
  BigNumberSub(P[0], P[0], N);
end;

procedure BigNumberPolynomialMulBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
var
  I: Integer;
begin
  if N.IsZero then
    BigNumberPolynomialSetZero(P)
  else if not N.IsOne then
  begin
    for I := 0 to P.MaxDegree do
      BigNumberMul(P[I], P[I], N);
  end;
end;

procedure BigNumberPolynomialDivBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
var
  I: Integer;
  T: TCnBigNumber;
begin
  if N.IsZero then
    BigNumberPolynomialSetZero(P)
  else if not N.IsOne then
  begin
    T := FLocalBigNumberPool.Obtain;
    try
      for I := 0 to P.MaxDegree do
        BigNumberDiv(P[I], T, P[I], N);
    finally
      FLocalBigNumberPool.Recycle(T);
    end;
  end;
end;

procedure BigNumberPolynomialNonNegativeModBigNumber(const P: TCnBigNumberPolynomial; N: TCnBigNumber);
var
  I: Integer;
begin
  if N.IsZero then
    raise ECnPolynomialException.Create(SZeroDivide);

  for I := 0 to P.MaxDegree do
    BigNumberNonNegativeMod(P[I], P[I], N);
end;

function BigNumberPolynomialAdd(const Res: TCnBigNumberPolynomial;
  const P1: TCnBigNumberPolynomial; const P2: TCnBigNumberPolynomial): Boolean;
var
  I, D1, D2: Integer;
  PBig: TCnBigNumberPolynomial;
begin
  D1 := Max(P1.MaxDegree, P2.MaxDegree);
  D2 := Min(P1.MaxDegree, P2.MaxDegree);

  if D1 > D2 then
  begin
    if P1.MaxDegree > P2.MaxDegree then
      PBig := P1
    else
      PBig := P2;

    Res.MaxDegree := D1; // ���ǵ� Res ������ P1 �� P2�����Ը� Res �� MaxDegree ��ֵ�÷�����ıȽ�֮��
    for I := D1 downto D2 + 1 do
      BigNumberCopy(Res[I], PBig[I]);
  end
  else // D1 = D2 ˵������ʽͬ��
    Res.MaxDegree := D1;

  for I := D2 downto 0 do
    BigNumberAdd(Res[I], P1[I], P2[I]);

  Res.CorrectTop;
  Result := True;
end;

function BigNumberPolynomialSub(const Res: TCnBigNumberPolynomial;
  const P1: TCnBigNumberPolynomial; const P2: TCnBigNumberPolynomial): Boolean;
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
        BigNumberCopy(Res[I], P1[I]);
    end
    else  // ��ʽ��
    begin
      for I := D1 downto D2 + 1 do
      begin
        BigNumberCopy(Res[I], P2[I]);
        Res[I].Negate;
      end;
    end;
  end;

  for I := D2 downto 0 do
    BigNumberSub(Res[I], P1[I], P2[I]);

  Res.CorrectTop;
  Result := True;
end;

function BigNumberPolynomialMul(const Res: TCnBigNumberPolynomial; P1: TCnBigNumberPolynomial;
  P2: TCnBigNumberPolynomial): Boolean;
var
  R: TCnBigNumberPolynomial;
  T: TCnBigNumber;
  I, J: Integer;
begin
  if BigNumberPolynomialIsZero(P1) or BigNumberPolynomialIsZero(P2) then
  begin
    BigNumberPolynomialSetZero(Res);
    Result := True;
    Exit;
  end;

  T := FLocalBigNumberPool.Obtain;
  if (Res = P1) or (Res = P2) then
    R := FLocalBigNumberPolynomialPool.Obtain
  else
    R := Res;

  R.Clear;
  R.MaxDegree := P1.MaxDegree + P2.MaxDegree;

  for I := 0 to P1.MaxDegree do
  begin
    // �ѵ� I �η������ֳ��� P2 ��ÿһ�����֣��ӵ������ I ��ͷ�Ĳ���
    for J := 0 to P2.MaxDegree do
    begin
      BigNumberMul(T, P1[I], P2[J]);
      BigNumberAdd(R[I + J], R[I + J], T);
    end;
  end;

  R.CorrectTop;
  if (Res = P1) or (Res = P2) then
  begin
    BigNumberPolynomialCopy(Res, R);
    FLocalBigNumberPolynomialPool.Recycle(R);
  end;
  FLocalBigNumberPool.Recycle(T);
  Result := True;
end;

function BigNumberPolynomialDiv(const Res: TCnBigNumberPolynomial; const Remain: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; const Divisor: TCnBigNumberPolynomial): Boolean;
var
  SubRes: TCnBigNumberPolynomial; // ���ɵݼ���
  MulRes: TCnBigNumberPolynomial; // ���ɳ����˻�
  DivRes: TCnBigNumberPolynomial; // ������ʱ��
  I, D: Integer;
  T, R: TCnBigNumber;
begin
  if BigNumberPolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  if Divisor.MaxDegree > P.MaxDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      BigNumberPolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      BigNumberPolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;
  T := nil;
  R := nil;

  try
    T := FLocalBigNumberPool.Obtain;
    R := FLocalBigNumberPool.Obtain;

    SubRes := FLocalBigNumberPolynomialPool.Obtain;
    BigNumberPolynomialCopy(SubRes, P);

    D := P.MaxDegree - Divisor.MaxDegree;
    DivRes := FLocalBigNumberPolynomialPool.Obtain;
    DivRes.MaxDegree := D;
    MulRes := FLocalBigNumberPolynomialPool.Obtain;

    Result := False;
    for I := 0 to D do
    begin
      if P.MaxDegree - I > SubRes.MaxDegree then                 // �м���������λ
        Continue;

      // �ж� Divisor[Divisor.MaxDegree] �Ƿ������� SubRes[P.MaxDegree - I] ������˵�����������Ͷ���ʽ��Χ���޷�֧�֣�ֻ�ܳ���
      if not BigNumberMod(T, SubRes[P.MaxDegree - I], Divisor[Divisor.MaxDegree]) then
        Exit;

      if not T.IsZero then
        Exit;

      BigNumberPolynomialCopy(MulRes, Divisor);
      BigNumberPolynomialShiftLeft(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�
      BigNumberDiv(T, R, SubRes[P.MaxDegree - I], MulRes[MulRes.MaxDegree]);

      BigNumberPolynomialMulBigNumber(MulRes, T); // ��ʽ�˵���ߴ�ϵ����ͬ
      BigNumberCopy(DivRes[D - I], T);            // �̷ŵ� DivRes λ��

      BigNumberPolynomialSub(SubRes, SubRes, MulRes);              // ���������·Ż� SubRes
    end;

    if Remain <> nil then
      BigNumberPolynomialCopy(Remain, SubRes);
    if Res <> nil then
      BigNumberPolynomialCopy(Res, DivRes);
  finally
    FLocalBigNumberPolynomialPool.Recycle(SubRes);
    FLocalBigNumberPolynomialPool.Recycle(MulRes);
    FLocalBigNumberPolynomialPool.Recycle(DivRes);
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(R);
  end;
  Result := True;
end;

function BigNumberPolynomialMod(const Res: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial): Boolean;
begin
  Result := BigNumberPolynomialDiv(nil, Res, P, Divisor);
end;

function BigNumberPolynomialPower(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; Exponent: TCnBigNumber): Boolean;
var
  T: TCnBigNumberPolynomial;
  E: TCnBigNumber;
begin
  if Exponent.IsZero then
  begin
    Res.SetOne;
    Result := True;
    Exit;
  end
  else if Exponent.IsOne then
  begin
    if Res <> P then
      BigNumberPolynomialCopy(Res, P);
    Result := True;
    Exit;
  end
  else if Exponent.IsNegative then
    raise ECnPolynomialException.CreateFmt(SCnInvalidExponent, [Exponent.ToDec]);

  T := FLocalBigNumberPolynomialPool.Obtain;
  BigNumberPolynomialCopy(T, P);
  E := FLocalBigNumberPool.Obtain;
  BigNumberCopy(E, Exponent);

  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetOne;
    while not E.IsNegative and not E.IsZero do
    begin
      if BigNumberIsBitSet(E, 0) then
        BigNumberPolynomialMul(Res, Res, T);

      BigNumberShiftRightOne(E, E);
      BigNumberPolynomialMul(T, T, T);
    end;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(E);
    FLocalBigNumberPolynomialPool.Recycle(T);
  end;
end;

procedure BigNumberPolynomialReduce(const P: TCnBigNumberPolynomial);
var
  I: Integer;
  D: TCnBigNumber;
begin
  if P.MaxDegree = 0 then
  begin
    if not P[P.MaxDegree].IsZero then
      P[P.MaxDegree].SetOne;
  end
  else
  begin
    D := FLocalBigNumberPool.Obtain;
    BigNumberCopy(D, P[0]);

    for I := 0 to P.MaxDegree - 1 do
    begin
      BigNumberGcd(D, D, P[I + 1]);
      if D.IsOne then
        Break;
    end;

    if not D.IsOne then
      BigNumberPolynomialDivBigNumber(P, D);
  end;
end;

function BigNumberPolynomialGreatestCommonDivisor(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial): Boolean;
var
  A, B, C: TCnBigNumberPolynomial;
begin
  Result := False;
  A := nil;
  B := nil;
  C := nil;

  try
    A := FLocalBigNumberPolynomialPool.Obtain;
    B := FLocalBigNumberPolynomialPool.Obtain;

    if P1.MaxDegree >= P2.MaxDegree then
    begin
      BigNumberPolynomialCopy(A, P1);
      BigNumberPolynomialCopy(B, P2);
    end
    else
    begin
      BigNumberPolynomialCopy(A, P2);
      BigNumberPolynomialCopy(B, P1);
    end;

    C := FLocalBigNumberPolynomialPool.Obtain;
    while not B.IsZero do
    begin
      BigNumberPolynomialCopy(C, B);        // ���� B
      if not BigNumberPolynomialMod(B, A, B) then   // A mod B �� B
        Exit;

      // B Ҫϵ��Լ�ֻ���
      BigNumberPolynomialReduce(B);
      BigNumberPolynomialCopy(A, C);        // ԭʼ B �� A
    end;

    BigNumberPolynomialCopy(Res, A);
    Result := True;
  finally
    FLocalBigNumberPolynomialPool.Recycle(A);
    FLocalBigNumberPolynomialPool.Recycle(B);
    FLocalBigNumberPolynomialPool.Recycle(C);
  end;
end;

function BigNumberPolynomialLeastCommonMultiple(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial): Boolean;
var
  G, M, R: TCnBigNumberPolynomial;
begin
  Result := False;
  if BigNumberPolynomialEqual(P1, P2) then
  begin
    BigNumberPolynomialCopy(Res, P1);
    Result := True;
    Exit;
  end;

  G := nil;
  M := nil;
  R := nil;

  try
    G := FLocalBigNumberPolynomialPool.Obtain;
    M := FLocalBigNumberPolynomialPool.Obtain;
    R := FLocalBigNumberPolynomialPool.Obtain;

    if not BigNumberPolynomialMul(M, P1, P2) then
      Exit;

    if not BigNumberPolynomialGreatestCommonDivisor(G, P1, P2) then
      Exit;

    if not BigNumberPolynomialDiv(Res, R, M, G) then
      Exit;

    Result := True;
  finally
    FLocalBigNumberPolynomialPool.Recycle(R);
    FLocalBigNumberPolynomialPool.Recycle(M);
    FLocalBigNumberPolynomialPool.Recycle(G);
  end;
end;

function BigNumberPolynomialCompose(const Res: TCnBigNumberPolynomial;
  const F, P: TCnBigNumberPolynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnBigNumberPolynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    BigNumberCopy(Res[0], F[0]);
    Result := True;
    Exit;
  end;

  if (Res = F) or (Res = P) then
    R := FLocalBigNumberPolynomialPool.Obtain
  else
    R := Res;

  X := FLocalBigNumberPolynomialPool.Obtain;
  T := FLocalBigNumberPolynomialPool.Obtain;

  try
    X.SetOne;
    R.SetZero;

    // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
    for I := 0 to F.MaxDegree do
    begin
      BigNumberPolynomialCopy(T, X);
      BigNumberPolynomialMulBigNumber(T, F[I]);
      BigNumberPolynomialAdd(R, R, T);

      if I <> F.MaxDegree then
        BigNumberPolynomialMul(X, X, P);
    end;

    if (Res = F) or (Res = P) then
    begin
      BigNumberPolynomialCopy(Res, R);
      FLocalBigNumberPolynomialPool.Recycle(R);
    end;
  finally
    FLocalBigNumberPolynomialPool.Recycle(X);
    FLocalBigNumberPolynomialPool.Recycle(T);
  end;
  Result := True;
end;

procedure BigNumberPolynomialGetValue(Res: TCnBigNumber; F: TCnBigNumberPolynomial;
  X: TCnBigNumber);
var
  I: Integer;
  T, M: TCnBigNumber;
begin
  BigNumberCopy(Res, F[0]);
  if X.IsZero or (F.MaxDegree = 0) then    // ֻ�г����������£��ó�����
    Exit;

  T := FLocalBigNumberPool.Obtain;
  M := FLocalBigNumberPool.Obtain;

  try
    BigNumberCopy(T, X);

    // �� F �е�ÿ��ϵ������ X �Ķ�Ӧ������ˣ�������
    for I := 1 to F.MaxDegree do
    begin
      BigNumberMul(M, F[I], T);
      BigNumberAdd(Res, Res, M);

      if I <> F.MaxDegree then
        BigNumberMul(T, T, X);
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(M);
  end;
end;

procedure BigNumberPolynomialReduce2(P1, P2: TCnBigNumberPolynomial);
var
  D: TCnBigNumberPolynomial;
begin
  if P1 = P2 then
  begin
    P1.SetOne;
    Exit;
  end;

  D := FLocalBigNumberPolynomialPool.Obtain;
  try
    if not BigNumberPolynomialGreatestCommonDivisor(D, P1, P2) then
      Exit;

    if not D.IsOne then
    begin
      BigNumberPolynomialDiv(P1, nil, P1, D);
      BigNumberPolynomialDiv(P1, nil, P1, D);
    end;
  finally
    FLocalBigNumberPolynomialPool.Recycle(D);
  end;
end;

// ===================== ���������µ���ϵ������ʽģ���� ========================

function BigNumberPolynomialGaloisEqual(const A, B: TCnBigNumberPolynomial;
  Prime: TCnBigNumber): Boolean;
var
  I: Integer;
  T1, T2: TCnBigNumber;
begin
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  Result := A.MaxDegree = B.MaxDegree;
  if Result then
  begin
    T1 := FLocalBigNumberPool.Obtain;
    T2 := FLocalBigNumberPool.Obtain;

    try
      for I := A.MaxDegree downto 0 do
      begin
        if BigNumberEqual(A[I], B[I]) then
          Continue;

        // ��������ж�����
        BigNumberNonNegativeMod(T1, A[I], Prime);
        BigNumberNonNegativeMod(T2, B[I], Prime);

        if not BigNumberEqual(T1, T2) then
        begin
          Result := False;
          Exit;
        end;
      end;
    finally
      FLocalBigNumberPool.Recycle(T2);
      FLocalBigNumberPool.Recycle(T1);
    end;
  end;
end;

procedure BigNumberPolynomialGaloisNegate(const P: TCnBigNumberPolynomial;
  Prime: TCnBigNumber);
var
  I: Integer;
begin
  for I := 0 to P.MaxDegree do
  begin
    P[I].Negate;
    BigNumberNonNegativeMod(P[I], P[I], Prime);
  end;
end;

function BigNumberPolynomialGaloisAdd(const Res: TCnBigNumberPolynomial;
  const P1: TCnBigNumberPolynomial; const P2: TCnBigNumberPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin
  Result := BigNumberPolynomialAdd(Res, P1, P2);
  if Result then
  begin
    BigNumberPolynomialNonNegativeModBigNumber(Res, Prime);
    if Primitive <> nil then
      BigNumberPolynomialGaloisMod(Res, Res, Primitive, Prime);
  end;
end;

function BigNumberPolynomialGaloisSub(const Res: TCnBigNumberPolynomial;
  const P1: TCnBigNumberPolynomial; const P2: TCnBigNumberPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin
  Result := BigNumberPolynomialSub(Res, P1, P2);
  if Result then
  begin
    BigNumberPolynomialNonNegativeModBigNumber(Res, Prime);
    if Primitive <> nil then
      BigNumberPolynomialGaloisMod(Res, Res, Primitive, Prime);
  end;
end;

function BigNumberPolynomialGaloisMul(const Res: TCnBigNumberPolynomial;
  const P1: TCnBigNumberPolynomial; const P2: TCnBigNumberPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
var
  R: TCnBigNumberPolynomial;
  T: TCnBigNumber;
  I, J: Integer;
begin
  if BigNumberPolynomialIsZero(P1) or BigNumberPolynomialIsZero(P2) then
  begin
    BigNumberPolynomialSetZero(Res);
    Result := True;
    Exit;
  end;

  T := FLocalBigNumberPool.Obtain;
  if (Res = P1) or (Res = P2) then
    R := FLocalBigNumberPolynomialPool.Obtain
  else
    R := Res;

  R.Clear;
  R.MaxDegree := P1.MaxDegree + P2.MaxDegree;

  for I := 0 to P1.MaxDegree do
  begin
    // �ѵ� I �η������ֳ��� P2 ��ÿһ�����֣��ӵ������ I ��ͷ�Ĳ���
    for J := 0 to P2.MaxDegree do
    begin
      BigNumberMul(T, P1[I], P2[J]);
      BigNumberAdd(R[I + J], R[I + J], T);
      BigNumberNonNegativeMod(R[I + J], R[I + J], Prime);
    end;
  end;

  R.CorrectTop;

  // �ٶԱ�ԭ����ʽȡģ��ע�����ﴫ��ı�ԭ����ʽ�� mod �����ĳ��������Ǳ�ԭ����ʽ����
  if Primitive <> nil then
    BigNumberPolynomialGaloisMod(R, R, Primitive, Prime);

  if (Res = P1) or (Res = P2) then
  begin
    BigNumberPolynomialCopy(Res, R);
    FLocalBigNumberPolynomialPool.Recycle(R);
  end;
  FLocalBigNumberPool.Recycle(T);
  Result := True;
end;

function BigNumberPolynomialGaloisDiv(const Res: TCnBigNumberPolynomial;
  const Remain: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial = nil): Boolean;
var
  SubRes: TCnBigNumberPolynomial; // ���ɵݼ���
  MulRes: TCnBigNumberPolynomial; // ���ɳ����˻�
  DivRes: TCnBigNumberPolynomial; // ������ʱ��
  I, D: Integer;
  K, T: TCnBigNumber;
begin
  if BigNumberPolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  if Divisor.MaxDegree > P.MaxDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      BigNumberPolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      BigNumberPolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;
  T := nil;
  K := nil;

  try
    T := FLocalBigNumberPool.Obtain;
    SubRes := FLocalBigNumberPolynomialPool.Obtain;
    BigNumberPolynomialCopy(SubRes, P);

    D := P.MaxDegree - Divisor.MaxDegree;
    DivRes := FLocalBigNumberPolynomialPool.Obtain;
    DivRes.MaxDegree := D;
    MulRes := FLocalBigNumberPolynomialPool.Obtain;

    K := FLocalBigNumberPool.Obtain;
    if Divisor[Divisor.MaxDegree].IsOne then
      K.SetOne
    else
      BigNumberModularInverse(K, Divisor[Divisor.MaxDegree], Prime);

    for I := 0 to D do
    begin
      if P.MaxDegree - I > SubRes.MaxDegree then               // �м���������λ
        Continue;
      BigNumberPolynomialCopy(MulRes, Divisor);
      BigNumberPolynomialShiftLeft(MulRes, D - I);             // ���뵽 SubRes ����ߴ�

      // ��ʽҪ��һ������������� SubRes ���λ���Գ�ʽ���λ�õ��Ľ����Ҳ�� SubRes ���λ���Գ�ʽ���λ����Ԫ�� mod Prime
      BigNumberDirectMulMod(T, SubRes[P.MaxDegree - I], K, Prime);
      BigNumberPolynomialGaloisMulBigNumber(MulRes, T, Prime);          // ��ʽ�˵���ߴ�ϵ����ͬ

      BigNumberCopy(DivRes[D - I], T);                             // ��Ӧλ���̷ŵ� DivRes λ��
      BigNumberPolynomialGaloisSub(SubRes, SubRes, MulRes, Prime); // ����ģ�������·Ż� SubRes
    end;

    // ������ʽ����Ҫ��ģ��ԭ����ʽ
    if Primitive <> nil then
    begin
      BigNumberPolynomialGaloisMod(SubRes, SubRes, Primitive, Prime);
      BigNumberPolynomialGaloisMod(DivRes, DivRes, Primitive, Prime);
    end;

    if Remain <> nil then
      BigNumberPolynomialCopy(Remain, SubRes);
    if Res <> nil then
      BigNumberPolynomialCopy(Res, DivRes);
    Result := True;
  finally
    FLocalBigNumberPolynomialPool.Recycle(SubRes);
    FLocalBigNumberPolynomialPool.Recycle(MulRes);
    FLocalBigNumberPolynomialPool.Recycle(DivRes);
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(K);
  end;
end;

function BigNumberPolynomialGaloisMod(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; const Divisor: TCnBigNumberPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin
  Result := BigNumberPolynomialGaloisDiv(nil, Res, P, Divisor, Prime, Primitive);
end;

function BigNumberPolynomialGaloisPower(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; Exponent: TCnBigNumber;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
var
  T: TCnBigNumberPolynomial;
  E: TCnBigNumber;
begin
  if Exponent.IsZero then
  begin
    Res.SetOne;
    Result := True;
    Exit;
  end
  else if Exponent.IsOne then
  begin
    if Res <> P then
      BigNumberPolynomialCopy(Res, P);
    Result := True;
    Exit;
  end
  else if Exponent.IsNegative then
    raise ECnPolynomialException.CreateFmt(SCnInvalidExponent, [Exponent]);

  T := FLocalBigNumberPolynomialPool.Obtain;
  BigNumberPolynomialCopy(T, P);
  E := FLocalBigNumberPool.Obtain;
  BigNumberCopy(E, Exponent);

  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetOne;
    while not E.IsNegative and not E.IsZero do
    begin
      if BigNumberIsBitSet(E, 0) then
        BigNumberPolynomialGaloisMul(Res, Res, T, Prime, Primitive);

      BigNumberShiftRightOne(E, E);
      BigNumberPolynomialGaloisMul(T, T, T, Prime, Primitive);
    end;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(E);
    FLocalBigNumberPolynomialPool.Recycle(T);
  end;
end;

function BigNumberPolynomialGaloisPower(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; Exponent: LongWord; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial = nil): Boolean; overload;
var
  T: TCnBigNumber;
begin
  T := FLocalBigNumberPool.Obtain;
  try
    T.SetWord(Exponent);
    Result := BigNumberPolynomialGaloisPower(Res, P, T, Prime, Primitive);
  finally
    FLocalBigNumberPool.Recycle(T);
  end;
end;

function BigNumberPolynomialGaloisAddWord(const P: TCnBigNumberPolynomial;
  N: LongWord; Prime: TCnBigNumber): Boolean;
begin
  if N <> 0 then
  begin
    BigNumberAddWord(P[0], N);
    BigNumberNonNegativeMod(P[0], P[0], Prime);
  end;
  Result := True;
end;

function BigNumberPolynomialGaloisSubWord(const P: TCnBigNumberPolynomial;
  N: LongWord; Prime: TCnBigNumber): Boolean;
begin
  if N <> 0 then
  begin
    BigNumberSubWord(P[0], N);
    BigNumberNonNegativeMod(P[0], P[0], Prime);
  end;
  Result := True;
end;

function BigNumberPolynomialGaloisMulWord(const P: TCnBigNumberPolynomial;
  N: LongWord; Prime: TCnBigNumber): Boolean;
var
  I: Integer;
begin
  if N = 0 then
  begin
    BigNumberPolynomialSetZero(P);
  end
  else if N <> 1 then
  begin
    for I := 0 to P.MaxDegree do
    begin
      BigNumberMulWord(P[I], N);
      BigNumberNonNegativeMod(P[I], P[I], Prime);
    end;
  end;
  Result := True;
end;

function BigNumberPolynomialGaloisDivWord(const P: TCnBigNumberPolynomial;
  N: LongWord; Prime: TCnBigNumber): Boolean;
var
  I: Integer;
  K, T: TCnBigNumber;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SDivByZero);

  K := nil;
  T := nil;

  try
    K := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;
    T.SetWord(N);

    BigNumberModularInverse(K, T, Prime);
    for I := 0 to P.MaxDegree do
    begin
      BigNumberMul(P[I], P[I], T);
      BigNumberNonNegativeMod(P[I], P[I], Prime);
    end;
  finally
    FLocalBigNumberPool.Recycle(K);
    FLocalBigNumberPool.Recycle(T);
  end;
  Result := True;
end;

procedure BigNumberPolynomialGaloisAddBigNumber(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber);
begin
  BigNumberAdd(P[0], P[0], N);
  BigNumberNonNegativeMod(P[0], P[0], Prime);
end;

procedure BigNumberPolynomialGaloisSubBigNumber(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber);
begin
  BigNumberSub(P[0], P[0], N);
  BigNumberNonNegativeMod(P[0], P[0], Prime);
end;

procedure BigNumberPolynomialGaloisMulBigNumber(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber);
var
  I: Integer;
begin
  if N.IsZero then
    BigNumberPolynomialSetZero(P)
  else if not N.IsOne then
  begin
    for I := 0 to P.MaxDegree do
    begin
      BigNumberMul(P[I], P[I], N);
      BigNumberNonNegativeMod(P[I], P[I], Prime);
    end;
  end;
end;

procedure BigNumberPolynomialGaloisDivBigNumber(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber);
var
  I: Integer;
  K: TCnBigNumber;
  B: Boolean;
begin
  if N.IsZero then
    raise ECnPolynomialException.Create(SDivByZero);

  B := N.IsNegative;
  if B then
    N.Negate;

  K := FLocalBigNumberPool.Obtain;
  try
    BigNumberModularInverse(K, N, Prime);

    for I := 0 to P.MaxDegree do
    begin
      BigNumberMul(P[I], P[I], K);
      BigNumberNonNegativeMod(P[I], P[I], Prime);

      if B then
        BigNumberSub(P[I], Prime, P[I]);
    end;
  finally
    FLocalBigNumberPool.Recycle(K);
    if B then
      N.Negate;
  end;
end;

procedure BigNumberPolynomialGaloisMonic(const P: TCnBigNumberPolynomial; Prime: TCnBigNumber);
begin
  if not P[P.MaxDegree].IsZero and not P[P.MaxDegree].IsOne then
    BigNumberPolynomialGaloisDivBigNumber(P, P[P.MaxDegree], Prime);
end;

function BigNumberPolynomialGaloisGreatestCommonDivisor(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
var
  A, B, C: TCnBigNumberPolynomial;
begin
  A := nil;
  B := nil;
  C := nil;

  try
    A := FLocalBigNumberPolynomialPool.Obtain;
    B := FLocalBigNumberPolynomialPool.Obtain;

    if P1.MaxDegree >= P2.MaxDegree then
    begin
      BigNumberPolynomialCopy(A, P1);
      BigNumberPolynomialCopy(B, P2);
    end
    else
    begin
      BigNumberPolynomialCopy(A, P2);
      BigNumberPolynomialCopy(B, P1);
    end;

    C := FLocalBigNumberPolynomialPool.Obtain;
    while not B.IsZero do
    begin
      BigNumberPolynomialCopy(C, B);          // ���� B
      BigNumberPolynomialGaloisMod(B, A, B, Prime);  // A mod B �� B
      BigNumberPolynomialCopy(A, C);          // ԭʼ B �� A
    end;

    BigNumberPolynomialCopy(Res, A);
    BigNumberPolynomialGaloisMonic(Res, Prime);      // ���Ϊһ
    Result := True;
  finally
    FLocalBigNumberPolynomialPool.Recycle(A);
    FLocalBigNumberPolynomialPool.Recycle(B);
    FLocalBigNumberPolynomialPool.Recycle(C);
  end;
end;

function BigNumberPolynomialGaloisLeastCommonMultiple(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
var
  G, M, R: TCnBigNumberPolynomial;
begin
  Result := False;
  if BigNumberPolynomialEqual(P1, P2) then
  begin
    BigNumberPolynomialCopy(Res, P1);
    Result := True;
    Exit;
  end;

  G := nil;
  M := nil;
  R := nil;

  try
    G := FLocalBigNumberPolynomialPool.Obtain;
    M := FLocalBigNumberPolynomialPool.Obtain;
    R := FLocalBigNumberPolynomialPool.Obtain;

    if not BigNumberPolynomialGaloisMul(M, P1, P2, Prime) then
      Exit;

    if not BigNumberPolynomialGaloisGreatestCommonDivisor(G, P1, P2, Prime) then
      Exit;

    if not BigNumberPolynomialGaloisDiv(Res, R, M, G, Prime) then
      Exit;

    Result := True;
  finally
    FLocalBigNumberPolynomialPool.Recycle(R);
    FLocalBigNumberPolynomialPool.Recycle(M);
    FLocalBigNumberPolynomialPool.Recycle(G);
  end;
end;

procedure BigNumberPolynomialGaloisExtendedEuclideanGcd(A, B: TCnBigNumberPolynomial;
  X, Y: TCnBigNumberPolynomial; Prime: TCnBigNumber);
var
  T, P, M: TCnBigNumberPolynomial;
begin
  if B.IsZero then
  begin
    X.SetZero;
    BigNumberModularInverse(X[0], A[0], Prime);
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
      T := FLocalBigNumberPolynomialPool.Obtain;
      P := FLocalBigNumberPolynomialPool.Obtain;
      M := FLocalBigNumberPolynomialPool.Obtain;

      BigNumberPolynomialGaloisMod(P, A, B, Prime);

      BigNumberPolynomialGaloisExtendedEuclideanGcd(B, P, Y, X, Prime);

      // Y := Y - (A div B) * X;
      BigNumberPolynomialGaloisDiv(P, M, A, B, Prime);
      BigNumberPolynomialGaloisMul(P, P, X, Prime);
      BigNumberPolynomialGaloisSub(Y, Y, P, Prime);
    finally
      FLocalBigNumberPolynomialPool.Recycle(M);
      FLocalBigNumberPolynomialPool.Recycle(P);
      FLocalBigNumberPolynomialPool.Recycle(T);
    end;
  end;
end;

procedure BigNumberPolynomialGaloisModularInverse(const Res: TCnBigNumberPolynomial;
  X, Modulus: TCnBigNumberPolynomial; Prime: TCnBigNumber; CheckGcd: Boolean = False);
var
  X1, Y, G: TCnBigNumberPolynomial;
begin
  X1 := nil;
  Y := nil;
  G := nil;

  try
    if CheckGcd then
    begin
      G := FLocalBigNumberPolynomialPool.Obtain;
      BigNumberPolynomialGaloisGreatestCommonDivisor(G, X, Modulus, Prime);
      if not G.IsOne then
        raise ECnPolynomialException.Create('Modular Inverse Need GCD = 1');
    end;

    X1 := FLocalBigNumberPolynomialPool.Obtain;
    Y := FLocalBigNumberPolynomialPool.Obtain;

    BigNumberPolynomialCopy(X1, X);

    // ��չŷ�����շת��������Ԫһ�β�����ϵ������ʽ���� A * X - B * Y = 1 ��������
    BigNumberPolynomialGaloisExtendedEuclideanGcd(X1, Modulus, Res, Y, Prime);
  finally
    FLocalBigNumberPolynomialPool.Recycle(X1);
    FLocalBigNumberPolynomialPool.Recycle(Y);
    FLocalBigNumberPolynomialPool.Recycle(G);
  end;
end;

function BigNumberPolynomialGaloisCompose(const Res: TCnBigNumberPolynomial;
  const F, P: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
var
  I: Integer;
  R, X, T: TCnBigNumberPolynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    BigNumberNonNegativeMod(Res[0], F[0], Prime);
    Result := True;
    Exit;
  end;

  if (Res = F) or (Res = P) then
    R := FLocalBigNumberPolynomialPool.Obtain
  else
    R := Res;

  X := FLocalBigNumberPolynomialPool.Obtain;
  T := FLocalBigNumberPolynomialPool.Obtain;

  try
    X.SetOne;
    R.SetZero;

    // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
    for I := 0 to F.MaxDegree do
    begin
      BigNumberPolynomialCopy(T, X);
      BigNumberPolynomialGaloisMulBigNumber(T, F[I], Prime);
      BigNumberPolynomialGaloisAdd(R, R, T, Prime);

      if I <> F.MaxDegree then
        BigNumberPolynomialGaloisMul(X, X, P, Prime);
    end;

    if Primitive <> nil then
      BigNumberPolynomialGaloisMod(R, R, Primitive, Prime);

    if (Res = F) or (Res = P) then
    begin
      BigNumberPolynomialCopy(Res, R);
      FLocalBigNumberPolynomialPool.Recycle(R);
    end;
  finally
    FLocalBigNumberPolynomialPool.Recycle(X);
    FLocalBigNumberPolynomialPool.Recycle(T);
  end;
  Result := True;
end;

function BigNumberPolynomialGaloisGetValue(Res: TCnBigNumber;
  const F: TCnBigNumberPolynomial; X, Prime: TCnBigNumber): Boolean;
var
  I: Integer;
  T, M: TCnBigNumber;
begin
  Result := True;
  BigNumberNonNegativeMod(Res, F[0], Prime);
  if X.IsZero or (F.MaxDegree = 0) then    // ֻ�г����������£��ó�����
    Exit;

  T := nil;
  M := nil;

  try
    T := FLocalBigNumberPool.Obtain;
    BigNumberCopy(T, X);
    M := FLocalBigNumberPool.Obtain;

    // �� F �е�ÿ��ϵ������ X �Ķ�Ӧ������ˣ�������
    for I := 1 to F.MaxDegree do
    begin
      BigNumberDirectMulMod(M, F[I], T, Prime);
      BigNumberAdd(Res, Res, M);
      BigNumberNonNegativeMod(Res, Res, Prime);

      if I <> F.MaxDegree then
        BigNumberDirectMulMod(T, T, X, Prime);
    end;
    BigNumberNonNegativeMod(Res, Res, Prime);
  finally
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(M);
  end;
end;

function BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B: Integer; Degree: Integer;
  outDivisionPolynomial: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean; overload;
var
  NA, NB: TCnBigNumber;
begin
  NA := FLocalBigNumberPool.Obtain;
  NB := FLocalBigNumberPool.Obtain;

  try
    NA.SetInteger(A);
    NB.SetInteger(B);
    Result := BigNumberPolynomialGaloisCalcDivisionPolynomial(NA, NB, Degree,
      outDivisionPolynomial, Prime);
  finally
    FLocalBigNumberPool.Recycle(NB);
    FLocalBigNumberPool.Recycle(NA);
  end;
end;

function BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B: TCnBigNumber; Degree: Integer;
  outDivisionPolynomial: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
var
  N: Integer;
  T, MI: TCnBigNumber;
  D1, D2, D3, Y4: TCnBigNumberPolynomial;
begin
  if Degree < 0 then
    raise ECnPolynomialException.Create('Galois Division Polynomial Invalid Degree')
  else if Degree = 0 then
  begin
    outDivisionPolynomial.SetCoefficents([0]);  // f0(X) = 0
    Result := True;
  end
  else if Degree = 1 then
  begin
    outDivisionPolynomial.SetCoefficents([1]);  // f1(X) = 1
    Result := True;
  end
  else if Degree = 2 then
  begin
    outDivisionPolynomial.SetCoefficents([2]);  // f2(X) = 2
    Result := True;
  end
  else if Degree = 3 then   // f3(X) = 3 X4 + 6 a X2 + 12 b X - a^2
  begin
    outDivisionPolynomial.MaxDegree := 4;
    outDivisionPolynomial[4].SetWord(3);
    outDivisionPolynomial[3].SetWord(0);
    BigNumberMulWordNonNegativeMod(outDivisionPolynomial[2], A, 6, Prime);
    BigNumberMulWordNonNegativeMod(outDivisionPolynomial[1], B, 12, Prime);

    T := FLocalBigNumberPool.Obtain;
    try
      BigNumberCopy(T, A);
      T.Negate;
      BigNumberDirectMulMod(outDivisionPolynomial[0], T, A, Prime);
    finally
      FLocalBigNumberPool.Recycle(T);
    end;
    Result := True;
  end
  else if Degree = 4 then // f4(X) = 4 X6 + 20 a X4 + 80 b X3 - 20 a2X2 - 16 a b X - 4 a3 - 32 b^2
  begin
    outDivisionPolynomial.MaxDegree := 6;
    outDivisionPolynomial[6].SetWord(4);
    outDivisionPolynomial[5].SetWord(0);
    BigNumberMulWordNonNegativeMod(outDivisionPolynomial[4], A, 20, Prime);
    BigNumberMulWordNonNegativeMod(outDivisionPolynomial[3], B, 80, Prime);

    T := FLocalBigNumberPool.Obtain;
    try
      BigNumberMulWordNonNegativeMod(T, A, -20, Prime);
      BigNumberDirectMulMod(outDivisionPolynomial[2], T, A, Prime);
      BigNumberMulWordNonNegativeMod(T, A, -16, Prime);
      BigNumberDirectMulMod(outDivisionPolynomial[1], T, B, Prime);

      BigNumberMulWordNonNegativeMod(T, A, -4, Prime);
      BigNumberDirectMulMod(T, T, A, Prime);
      BigNumberDirectMulMod(outDivisionPolynomial[0], T, A, Prime);

      BigNumberMulWordNonNegativeMod(T, B, -32, Prime);
      BigNumberDirectMulMod(T, T, B, Prime);
      BigNumberAdd(outDivisionPolynomial[0], outDivisionPolynomial[0], T);
      BigNumberNonNegativeMod(outDivisionPolynomial[0], outDivisionPolynomial[0], Prime);
    finally
      FLocalBigNumberPool.Recycle(T);
    end;
    Result := True;
  end
  else
  begin
    D1 := nil;
    D2 := nil;
    D3 := nil;
    Y4 := nil;
    MI := nil;

    try
      // ��ʼ�ݹ����
      N := Degree shr 1;
      if (Degree and 1) = 0 then // Degree ��ż�������� fn * (fn+2 * fn-1 ^ 2 - fn-2 * fn+1 ^ 2) / 2
      begin
        D1 := FLocalBigNumberPolynomialPool.Obtain;
        BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime);

        D2 := FLocalBigNumberPolynomialPool.Obtain;        // D1 �õ� fn+2
        BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);
        BigNumberPolynomialGaloisMul(D2, D2, D2, Prime);   // D2 �õ� fn-1 ^2

        BigNumberPolynomialGaloisMul(D1, D1, D2, Prime);   // D1 �õ� fn+2 * fn-1 ^ 2

        D3 := FLocalBigNumberPolynomialPool.Obtain;
        BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N - 2, D3, Prime);  // D3 �õ� fn-2

        BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D2, Prime);
        BigNumberPolynomialGaloisMul(D2, D2, D2, Prime);   // D2 �õ� fn+1^2
        BigNumberPolynomialGaloisMul(D2, D2, D3, Prime);   // D2 �õ� fn-2 * fn+1^2

        BigNumberPolynomialGaloisSub(D1, D1, D2, Prime);   // D1 �õ� fn+2 * fn-1^2 - fn-2 * fn+1^2

        BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);    // D2 �õ� fn
        BigNumberPolynomialGaloisMul(outDivisionPolynomial, D2, D1, Prime);     // ��˵õ� f2n

        MI := FLocalBigNumberPool.Obtain;
        BigNumberModularInverseWord(MI, 2, Prime);
        BigNumberPolynomialGaloisMulBigNumber(outDivisionPolynomial, MI, Prime);     // �ٳ��� 2
      end
      else // Degree ������
      begin
        Y4 := FLocalBigNumberPolynomialPool.Obtain;
        Y4.MaxDegree := 3;
        BigNumberCopy(Y4[0], B);
        BigNumberCopy(Y4[1], A);
        Y4[2].SetZero;
        Y4[3].SetOne;

        BigNumberPolynomialGaloisMul(Y4, Y4, Y4, Prime);

        D1 := FLocalBigNumberPolynomialPool.Obtain;
        BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime); // D1 �õ� fn+2

        D2 := FLocalBigNumberPolynomialPool.Obtain;
        BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);
        BigNumberPolynomialGaloisPower(D2, D2, 3, Prime);                        // D2 �õ� fn^3

        D3 := FLocalBigNumberPolynomialPool.Obtain;
        BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D3, Prime);
        BigNumberPolynomialGaloisPower(D3, D3, 3, Prime);                        // D3 �õ� fn+1^3

        if (N and 1) <> 0 then // N ������������ f2n+1 = fn+2 * fn^3 - fn-1 * fn+1^3 * (x^3 + Ax + B)^2
        begin
          BigNumberPolynomialGaloisMul(D1, D1, D2, Prime);  // D1 �õ� fn+2 * fn^3

          BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);
          BigNumberPolynomialGaloisMul(D2, D2, Y4, Prime);     // D2 �õ� fn-1 * Y^4

          BigNumberPolynomialGaloisMul(D2, D2, D3, Prime);     // D2 �õ� fn+1^3 * fn-1 * Y^4
          BigNumberPolynomialGaloisSub(outDivisionPolynomial, D1, D2, Prime);
        end
        else // N ��ż�������� (x^3 + Ax + B)^2 * fn+2 * fn^3 - fn-1 * fn+1^3
        begin
          BigNumberPolynomialGaloisMul(D1, D1, D2, Prime);
          BigNumberPolynomialGaloisMul(D1, D1, Y4, Prime);   // D1 �õ� Y^4 * fn+2 * fn^3

          BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);  // D2 �õ� fn-1

          BigNumberPolynomialGaloisMul(D2, D2, D3, Prime);  // D2 �õ� fn-1 * fn+1^3

          BigNumberPolynomialGaloisSub(outDivisionPolynomial, D1, D2, Prime);
        end;
      end;
    finally
      FLocalBigNumberPolynomialPool.Recycle(D1);
      FLocalBigNumberPolynomialPool.Recycle(D2);
      FLocalBigNumberPolynomialPool.Recycle(D3);
      FLocalBigNumberPolynomialPool.Recycle(Y4);
      FLocalBigNumberPool.Recycle(MI);
    end;
    Result := True;
  end;
end;

procedure BigNumberPolynomialGaloisReduce2(P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber);
var
  D: TCnBigNumberPolynomial;
begin
  if P1 = P2 then
  begin
    P1.SetOne;
    Exit;
  end;

  D := FLocalBigNumberPolynomialPool.Obtain;
  try
    if not BigNumberPolynomialGaloisGreatestCommonDivisor(D, P1, P2, Prime) then
      Exit;

    if not D.IsOne then
    begin
      BigNumberPolynomialGaloisDiv(P1, nil, P1, D, Prime);
      BigNumberPolynomialGaloisDiv(P1, nil, P1, D, Prime);
    end;
  finally
    FLocalBigNumberPolynomialPool.Recycle(D);
  end;
end;

{ TCnBigNumberRationalPolynomialPool }

function TCnBigNumberRationalPolynomialPool.CreateObject: TObject;
begin
  Result := TCnBigNumberRationalPolynomial.Create;
end;

function TCnBigNumberRationalPolynomialPool.Obtain: TCnBigNumberRationalPolynomial;
begin
  Result := TCnBigNumberRationalPolynomial(inherited Obtain);
  Result.SetZero;
end;

procedure TCnBigNumberRationalPolynomialPool.Recycle(
  Poly: TCnBigNumberRationalPolynomial);
begin
  inherited Recycle(Poly);
end;

// ======================= һԪ����ϵ�������ʽ�������� ============================

function BigNumberRationalPolynomialEqual(R1, R2: TCnBigNumberRationalPolynomial): Boolean;
var
  T1, T2: TCnBigNumberPolynomial;
begin
  if R1 = R2 then
  begin
    Result := True;
    Exit;
  end;

  if R1.IsInt and R2.IsInt then
  begin
    Result := BigNumberPolynomialEqual(R1.Nominator, R2.Nominator);
    Exit;
  end;

  T1 := FLocalBigNumberPolynomialPool.Obtain;
  T2 := FLocalBigNumberPolynomialPool.Obtain;

  try
    // �жϷ��ӷ�ĸ����˵Ľ���Ƿ����
    BigNumberPolynomialMul(T1, R1.Nominator, R2.Denominator);
    BigNumberPolynomialMul(T2, R2.Nominator, R1.Denominator);
    Result := BigNumberPolynomialEqual(T1, T2);
  finally
    FLocalBigNumberPolynomialPool.Recycle(T2);
    FLocalBigNumberPolynomialPool.Recycle(T1);
  end;
end;

function BigNumberRationalPolynomialCopy(const Dst: TCnBigNumberRationalPolynomial;
  const Src: TCnBigNumberRationalPolynomial): TCnBigNumberRationalPolynomial;
begin
  Result := Dst;
  if Src <> Dst then
  begin
    BigNumberPolynomialCopy(Dst.Nominator, Src.Nominator);
    BigNumberPolynomialCopy(Dst.Denominator, Src.Denominator);
  end;
end;

procedure BigNumberRationalPolynomialAdd(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
var
  M, R, F1, F2, D1, D2: TCnBigNumberPolynomial;
begin
  if R1.IsInt and R2.IsInt then
  begin
    BigNumberPolynomialAdd(RationalResult.Nominator, R1.Nominator, R2.Nominator);
    RationalResult.Denominator.SetOne;
    Exit;
  end
  else if R1.IsZero then
  begin
    if R2 <> RationalResult then
      RationalResult.Assign(R2);
  end
  else if R2.IsZero then
  begin
    if R1 <> RationalResult then
      RationalResult.Assign(R1);
  end
  else
  begin
    M := nil;
    R := nil;
    F1 := nil;
    F2 := nil;
    D1 := nil;
    D2 := nil;

    try
      // ���ĸ����С������
      M := FLocalBigNumberPolynomialPool.Obtain;
      R := FLocalBigNumberPolynomialPool.Obtain;
      F1 := FLocalBigNumberPolynomialPool.Obtain;
      F2 := FLocalBigNumberPolynomialPool.Obtain;
      D1 := FLocalBigNumberPolynomialPool.Obtain;
      D2 := FLocalBigNumberPolynomialPool.Obtain;

      BigNumberPolynomialCopy(D1, R1.Denominator);
      BigNumberPolynomialCopy(D2, R2.Denominator);

      if not BigNumberPolynomialLeastCommonMultiple(M, D1, D2) then
        BigNumberPolynomialMul(M, D1, D2);   // �޷�����С����ʽ��ʾϵ���޷�������ֱ�����

      BigNumberPolynomialDiv(F1, R, M, D1);
      BigNumberPolynomialDiv(F2, R, M, D2);

      BigNumberPolynomialCopy(RationalResult.Denominator, M);
      BigNumberPolynomialMul(R, R1.Nominator, F1);
      BigNumberPolynomialMul(M, R2.Nominator, F2);
      BigNumberPolynomialAdd(RationalResult.Nominator, R, M);
    finally
      FLocalBigNumberPolynomialPool.Recycle(M);
      FLocalBigNumberPolynomialPool.Recycle(R);
      FLocalBigNumberPolynomialPool.Recycle(F1);
      FLocalBigNumberPolynomialPool.Recycle(F2);
      FLocalBigNumberPolynomialPool.Recycle(D1);
      FLocalBigNumberPolynomialPool.Recycle(D2);
    end;
  end;
end;

procedure BigNumberRationalPolynomialSub(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
begin
  R2.Nominator.Negate;
  BigNumberRationalPolynomialAdd(R1, R2, RationalResult);
  if RationalResult <> R2 then
    R2.Nominator.Negate;
end;

procedure BigNumberRationalPolynomialMul(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
begin
  BigNumberPolynomialMul(RationalResult.Nominator, R1.Nominator, R2.Nominator);
  BigNumberPolynomialMul(RationalResult.Denominator, R1.Denominator, R2.Denominator);
end;

procedure BigNumberRationalPolynomialDiv(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
var
  N: TCnBigNumberPolynomial;
begin
  if R2.IsZero then
    raise EDivByZero.Create('Divide by Zero.');

  N := FLocalBigNumberPolynomialPool.Obtain; // ������ˣ��������м��������ֹ RationalResult �� Number1 �� Number 2
  try
    BigNumberPolynomialMul(N, R1.Nominator, R2.Denominator);
    BigNumberPolynomialMul(RationalResult.Denominator, R1.Denominator, R2.Nominator);
    BigNumberPolynomialCopy(RationalResult.Nominator, N);
  finally
    FLocalBigNumberPolynomialPool.Recycle(N);
  end;
end;

procedure BigNumberRationalPolynomialAddBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber);
var
  P: TCnBigNumberPolynomial;
begin
  P := FLocalBigNumberPolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    BigNumberCopy(P[0], Num);
    BigNumberRationalPolynomialAdd(R, P, R);
  finally
    FLocalBigNumberPolynomialPool.Recycle(P);
  end;
end;

procedure BigNumberRationalPolynomialSubBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber);
var
  P: TCnBigNumberPolynomial;
begin
  P := FLocalBigNumberPolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    BigNumberCopy(P[0], Num);
    BigNumberRationalPolynomialSub(R, P, R);
  finally
    FLocalBigNumberPolynomialPool.Recycle(P);
  end;
end;

procedure BigNumberRationalPolynomialMulBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber);
var
  P: TCnBigNumberPolynomial;
begin
  P := FLocalBigNumberPolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    BigNumberCopy(P[0], Num);
    BigNumberRationalPolynomialMul(R, P, R);
  finally
    FLocalBigNumberPolynomialPool.Recycle(P);
  end;
end;

procedure BigNumberRationalPolynomialDivBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber);
var
  P: TCnBigNumberPolynomial;
begin
  P := FLocalBigNumberPolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    BigNumberCopy(P[0], Num);
    BigNumberRationalPolynomialDiv(R, P, R);
  finally
    FLocalBigNumberPolynomialPool.Recycle(P);
  end;
end;

procedure BigNumberRationalPolynomialAdd(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
var
  T: TCnBigNumberRationalPolynomial;
begin
  if P1.IsZero then
  begin
    if R1 <> RationalResult then
    begin
      BigNumberRationalPolynomialCopy(RationalResult, R1);
      Exit;
    end;
  end;

  T := FLocalBigNumberRationalPolynomialPool.Obtain;
  try
    T.Denominator.SetOne;
    BigNumberPolynomialCopy(T.Nominator, P1);
    BigNumberRationalPolynomialAdd(R1, T, RationalResult);
  finally
    FLocalBigNumberRationalPolynomialPool.Recycle(T);
  end;
end;

procedure BigNumberRationalPolynomialSub(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
begin
  P1.Negate;
  try
    BigNumberRationalPolynomialAdd(R1, P1, RationalResult);
  finally
    P1.Negate;
  end;
end;

procedure BigNumberRationalPolynomialMul(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
begin
  if P1.IsZero then
    RationalResult.SetZero
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    BigNumberPolynomialMul(RationalResult.Nominator, R1.Nominator, P1);
    BigNumberPolynomialCopy(RationalResult.Denominator, R1.Denominator);
  end;
end;

procedure BigNumberRationalPolynomialDiv(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
begin
  if P1.IsZero then
    raise EDivByZero.Create('Divide by Zero.')
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    BigNumberPolynomialMul(RationalResult.Denominator, R1.Denominator, P1);
    BigNumberPolynomialCopy(RationalResult.Nominator, R1.Nominator);
  end;
end;

function BigNumberRationalPolynomialCompose(Res: TCnBigNumberRationalPolynomial;
  F, P: TCnBigNumberRationalPolynomial): Boolean;
var
  RN, RD: TCnBigNumberRationalPolynomial;
begin
  if P.IsInt then
    Result := BigNumberRationalPolynomialCompose(Res, F, P.Nominator)
  else
  begin
    RD := FLocalBigNumberRationalPolynomialPool.Obtain;
    RN := FLocalBigNumberRationalPolynomialPool.Obtain;

    try
      BigNumberRationalPolynomialCompose(RN, F.Nominator, P);
      BigNumberRationalPolynomialCompose(RD, F.Denominator, P);

      BigNumberPolynomialMul(Res.Nominator, RN.Nominator, RD.Denominator);
      BigNumberPolynomialMul(Res.Denominator, RN.Denominator, RD.Nominator);
      Result := True;
    finally
      FLocalBigNumberRationalPolynomialPool.Recycle(RN);
      FLocalBigNumberRationalPolynomialPool.Recycle(RD);
    end;
  end;
end;

function BigNumberRationalPolynomialCompose(Res: TCnBigNumberRationalPolynomial;
  F: TCnBigNumberRationalPolynomial; P: TCnBigNumberPolynomial): Boolean;
begin
  BigNumberPolynomialCompose(Res.Nominator, F.Nominator, P);
  BigNumberPolynomialCompose(Res.Denominator, F.Denominator, P);
  Result := True;
end;

function BigNumberRationalPolynomialCompose(Res: TCnBigNumberRationalPolynomial;
  F: TCnBigNumberPolynomial; P: TCnBigNumberRationalPolynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnBigNumberRationalPolynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    Res.Nominator[0] := F[0];
    Result := True;
    Exit;
  end;

  if Res = P then
    R := FLocalBigNumberRationalPolynomialPool.Obtain
  else
    R := Res;

  X := FLocalBigNumberRationalPolynomialPool.Obtain;
  T := FLocalBigNumberRationalPolynomialPool.Obtain;

  try
    X.SetOne;
    R.SetZero;

    // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
    for I := 0 to F.MaxDegree do
    begin
      BigNumberRationalPolynomialCopy(T, X);
      BigNumberRationalPolynomialMulBigNumber(T, F[I]);
      BigNumberRationalPolynomialAdd(R, T, R);

      if I <> F.MaxDegree then
        BigNumberRationalPolynomialMul(X, P, X);
    end;

    if Res = P then
    begin
      BigNumberRationalPolynomialCopy(Res, R);
      FLocalBigNumberRationalPolynomialPool.Recycle(R);
    end;
  finally
    FLocalBigNumberRationalPolynomialPool.Recycle(X);
    FLocalBigNumberRationalPolynomialPool.Recycle(T);
  end;
  Result := True;
end;

procedure BigNumberRationalPolynomialGetValue(const F: TCnBigNumberRationalPolynomial;
  X: TCnBigNumber; outResult: TCnBigRational);
begin
  BigNumberPolynomialGetValue(outResult.Nominator, F.Nominator, X);
  BigNumberPolynomialGetValue(outResult.Denominator, F.Denominator, X);
  outResult.Reduce;
end;

// ================== һԪ����ϵ�������ʽ���������ϵ�ģ���� ===================

function BigNumberRationalPolynomialGaloisEqual(R1, R2: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
var
  T1, T2: TCnBigNumberPolynomial;
begin
  if R1 = R2 then
  begin
    Result := True;
    Exit;
  end;

  T1 := FLocalBigNumberPolynomialPool.Obtain;
  T2 := FLocalBigNumberPolynomialPool.Obtain;

  try
    // �жϷ��ӷ�ĸ����˵Ľ���Ƿ����
    BigNumberPolynomialGaloisMul(T1, R1.Nominator, R2.Denominator, Prime, Primitive);
    BigNumberPolynomialGaloisMul(T2, R2.Nominator, R1.Denominator, Prime, Primitive);
    Result := BigNumberPolynomialGaloisEqual(T1, T2, Prime);
  finally
    FLocalBigNumberPolynomialPool.Recycle(T2);
    FLocalBigNumberPolynomialPool.Recycle(T1);
  end;
end;

procedure BigNumberRationalPolynomialGaloisNegate(const P: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber);
begin
  BigNumberPolynomialGaloisNegate(P.Nominator, Prime);
end;

procedure BigNumberRationalPolynomialGaloisAdd(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
var
  M, R, F1, F2, D1, D2: TCnBigNumberPolynomial;
begin
  if R1.IsInt and R2.IsInt then
  begin
    BigNumberPolynomialGaloisAdd(RationalResult.Nominator, R1.Nominator,
      R2.Nominator, Prime);
    RationalResult.Denominator.SetOne;
    Exit;
  end
  else if R1.IsZero then
  begin
    if R2 <> RationalResult then
      RationalResult.Assign(R2);
  end
  else if R2.IsZero then
  begin
    if R1 <> RationalResult then
      RationalResult.Assign(R1);
  end
  else
  begin
    M := nil;
    R := nil;
    F1 := nil;
    F2 := nil;
    D1 := nil;
    D2 := nil;

    try
      // ���ĸ����С������
      M := FLocalBigNumberPolynomialPool.Obtain;
      R := FLocalBigNumberPolynomialPool.Obtain;
      F1 := FLocalBigNumberPolynomialPool.Obtain;
      F2 := FLocalBigNumberPolynomialPool.Obtain;
      D1 := FLocalBigNumberPolynomialPool.Obtain;
      D2 := FLocalBigNumberPolynomialPool.Obtain;

      BigNumberPolynomialCopy(D1, R1.Denominator);
      BigNumberPolynomialCopy(D2, R2.Denominator);

      if not BigNumberPolynomialGaloisLeastCommonMultiple(M, D1, D2, Prime) then
        BigNumberPolynomialGaloisMul(M, D1, D2, Prime);   // �޷�����С����ʽ��ʾϵ���޷�������ֱ�����

      BigNumberPolynomialGaloisDiv(F1, R, M, D1, Prime);  // ��С������ M div D1 ����� F1
      BigNumberPolynomialGaloisDiv(F2, R, M, D2, Prime);  // ��С������ M div D2 ����� F2

      BigNumberPolynomialCopy(RationalResult.Denominator, M);  // ����ķ�ĸ����С������
      BigNumberPolynomialGaloisMul(R, R1.Nominator, F1, Prime);
      BigNumberPolynomialGaloisMul(M, R2.Nominator, F2, Prime);
      BigNumberPolynomialGaloisAdd(RationalResult.Nominator, R, M, Prime);
    finally
      FLocalBigNumberPolynomialPool.Recycle(M);
      FLocalBigNumberPolynomialPool.Recycle(R);
      FLocalBigNumberPolynomialPool.Recycle(F1);
      FLocalBigNumberPolynomialPool.Recycle(F2);
      FLocalBigNumberPolynomialPool.Recycle(D1);
      FLocalBigNumberPolynomialPool.Recycle(D2);
    end;
  end;
end;

procedure BigNumberRationalPolynomialGaloisSub(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin
  R2.Nominator.Negate;
  BignumberRationalPolynomialGaloisAdd(R1, R2, RationalResult, Prime);
  if RationalResult <> R2 then
    R2.Nominator.Negate;
end;

procedure BigNumberRationalPolynomialGaloisMul(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin
  BigNumberPolynomialGaloisMul(RationalResult.Nominator, R1.Nominator, R2.Nominator, Prime);
  BigNumberPolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, R2.Denominator, Prime);
end;

procedure BigNumberRationalPolynomialGaloisDiv(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
var
  N: TCnBigNumberPolynomial;
begin
  if R2.IsZero then
    raise EDivByZero.Create('Divide by Zero.');

  N := FLocalBigNumberPolynomialPool.Obtain; // ������ˣ��������м��������ֹ RationalResult �� Number1 �� Number 2
  try
    BigNumberPolynomialGaloisMul(N, R1.Nominator, R2.Denominator, Prime);
    BigNumberPolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, R2.Nominator, Prime);
    BigNumberPolynomialCopy(RationalResult.Nominator, N);
  finally
    FLocalBigNumberPolynomialPool.Recycle(N);
  end;
end;

procedure BigNumberRationalPolynomialGaloisAddBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber; Prime: TCnBigNumber);
var
  P: TCnBigNumberPolynomial;
begin
  P := FLocalBigNumberPolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    BigNumberCopy(P[0], Num);
    BigNumberRationalPolynomialGaloisAdd(R, P, R, Prime);
  finally
    FLocalBigNumberPolynomialPool.Recycle(P);
  end;
end;

procedure BigNumberRationalPolynomialGaloisSubBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber; Prime: TCnBigNumber);
var
  P: TCnBigNumberPolynomial;
begin
  P := FLocalBigNumberPolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    BigNumberCopy(P[0], Num);
    BigNumberRationalPolynomialGaloisSub(R, P, R, Prime);
  finally
    FLocalBigNumberPolynomialPool.Recycle(P);
  end;
end;

procedure BigNumberRationalPolynomialGaloisMulBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber; Prime: TCnBigNumber);
var
  P: TCnBigNumberPolynomial;
begin
  P := FLocalBigNumberPolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    BigNumberCopy(P[0], Num);
    BigNumberRationalPolynomialGaloisMul(R, P, R, Prime);
  finally
    FLocalBigNumberPolynomialPool.Recycle(P);
  end;
end;

procedure BigNumberRationalPolynomialGaloisDivBigNumber(R: TCnBigNumberRationalPolynomial;
  Num: TCnBigNumber; Prime: TCnBigNumber);
var
  P: TCnBigNumberPolynomial;
begin
  P := FLocalBigNumberPolynomialPool.Obtain;
  try
    P.MaxDegree := 0;
    BigNumberCopy(P[0], Num);
    BigNumberRationalPolynomialGaloisDiv(R, P, R, Prime);
  finally
    FLocalBigNumberPolynomialPool.Recycle(P);
  end;
end;

procedure BigNumberRationalPolynomialGaloisAdd(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
var
  T: TCnBigNumberRationalPolynomial;
begin
  if P1.IsZero then
  begin
    if R1 <> RationalResult then
    begin
      BigNumberRationalPolynomialCopy(RationalResult, R1);
      Exit;
    end;
  end;

  T := FLocalBigNumberRationalPolynomialPool.Obtain;
  try
    T.Denominator.SetOne;
    BigNumberPolynomialCopy(T.Nominator, P1);
    BigNumberRationalPolynomialGaloisAdd(R1, T, RationalResult, Prime);
  finally
    FLocalBigNumberRationalPolynomialPool.Recycle(T);
  end;
end;

procedure BigNumberRationalPolynomialGaloisSub(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin
  P1.Negate;
  try
    BigNumberRationalPolynomialGaloisAdd(R1, P1, RationalResult, Prime);
  finally
    P1.Negate;
  end;
end;

procedure BigNumberRationalPolynomialGaloisMul(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin
  if P1.IsZero then
    RationalResult.SetZero
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    BigNumberPolynomialGaloisMul(RationalResult.Nominator, R1.Nominator, P1, Prime);
    BigNumberPolynomialCopy(RationalResult.Denominator, R1.Denominator);
  end;
end;

procedure BigNumberRationalPolynomialGaloisDiv(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin
  if P1.IsZero then
    raise EDivByZero.Create('Divide by Zero.')
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    BigNumberPolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, P1, Prime);
    BigNumberPolynomialCopy(RationalResult.Nominator, R1.Nominator);
  end;
end;

function BigNumberRationalPolynomialGaloisCompose(Res: TCnBigNumberRationalPolynomial;
  F, P: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial): Boolean;
var
  RN, RD: TCnBigNumberRationalPolynomial;
begin
  if P.IsInt then
    Result := BigNumberRationalPolynomialGaloisCompose(Res, F, P.Nominator, Prime, Primitive)
  else
  begin
    RD := FLocalBigNumberRationalPolynomialPool.Obtain;
    RN := FLocalBigNumberRationalPolynomialPool.Obtain;

    try
      BigNumberRationalPolynomialGaloisCompose(RN, F.Nominator, P, Prime, Primitive);
      BigNumberRationalPolynomialGaloisCompose(RD, F.Denominator, P, Prime, Primitive);

      BigNumberPolynomialGaloisMul(Res.Nominator, RN.Nominator, RD.Denominator, Prime);
      BigNumberPolynomialGaloisMul(Res.Denominator, RN.Denominator, RD.Nominator, Prime);

      if Primitive <> nil then
      begin
        BigNumberPolynomialGaloisMod(Res.Nominator, Res.Nominator, Primitive, Prime);
        BigNumberPolynomialGaloisMod(Res.Denominator, Res.Denominator, Primitive, Prime);
      end;
      Result := True;
    finally
      FLocalBigNumberRationalPolynomialPool.Recycle(RN);
      FLocalBigNumberRationalPolynomialPool.Recycle(RD);
    end;
  end;
end;

function BigNumberRationalPolynomialGaloisCompose(Res: TCnBigNumberRationalPolynomial;
  F: TCnBigNumberRationalPolynomial; P: TCnBigNumberPolynomial; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial): Boolean;
begin
  BigNumberPolynomialGaloisCompose(Res.Nominator, F.Nominator, P, Prime, Primitive);
  BigNumberPolynomialGaloisCompose(Res.Denominator, F.Denominator, P, Prime, Primitive);
  Result := True;
end;

function BigNumberRationalPolynomialGaloisCompose(Res: TCnBigNumberRationalPolynomial;
  F: TCnBigNumberPolynomial; P: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber;
  Primitive: TCnBigNumberPolynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnBigNumberRationalPolynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    BigNumberNonNegativeMod(Res.Nominator[0], F[0], Prime);
    Result := True;
    Exit;
  end;

  if Res = P then
    R := FLocalBigNumberRationalPolynomialPool.Obtain
  else
    R := Res;

  X := FLocalBigNumberRationalPolynomialPool.Obtain;
  T := FLocalBigNumberRationalPolynomialPool.Obtain;

  try
    X.SetOne;
    R.SetZero;

    // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
    for I := 0 to F.MaxDegree do
    begin
      BigNumberRationalPolynomialCopy(T, X);
      BigNumberRationalPolynomialGaloisMulBigNumber(T, F[I], Prime);
      BigNumberRationalPolynomialGaloisAdd(R, T, R, Prime);

      if I <> F.MaxDegree then
        BigNumberRationalPolynomialGaloisMul(X, P, X, Prime);
    end;

    if Primitive <> nil then
    begin
      BigNumberPolynomialGaloisMod(R.Nominator, R.Nominator, Primitive, Prime);
      BigNumberPolynomialGaloisMod(R.Denominator, R.Denominator, Primitive, Prime);
    end;

    if Res = P then
    begin
      BigNumberRationalPolynomialCopy(Res, R);
      FLocalBigNumberRationalPolynomialPool.Recycle(R);
    end;
  finally
    FLocalBigNumberRationalPolynomialPool.Recycle(X);
    FLocalBigNumberRationalPolynomialPool.Recycle(T);
  end;
  Result := True;
end;

procedure BigNumberRationalPolynomialGaloisGetValue(Res: TCnBigNumber;
  const F: TCnBigNumberRationalPolynomial; X: TCnBigNumber; Prime: TCnBigNumber);
var
  N, D, T: TCnBigNumber;
begin
  D := nil;
  N := nil;
  T := nil;

  try
    D := FLocalBigNumberPool.Obtain;
    BigNumberPolynomialGaloisGetValue(D, F.Denominator, X, Prime);
    if D.IsZero then
      raise EDivByZero.Create(SDivByZero);

    N := FLocalBigNumberPool.Obtain;
    BigNumberPolynomialGaloisGetValue(N, F.Nominator, X, Prime);

    T := FLocalBigNumberPool.Obtain;
    BigNumberModularInverse(T, D, Prime);
    BigNumberMul(N, T, N);
    BigNumberNonNegativeMod(Res, N, Prime);
  finally
    FLocalBigNumberPool.Recycle(D);
    FLocalBigNumberPool.Recycle(N);
    FLocalBigNumberPool.Recycle(T);
  end;
end;

{ TCnInt64BiPolynomial }

procedure TCnInt64BiPolynomial.CorrectTop;
var
  I: Integer;
  Compact, MeetNonEmpty: Boolean;
  YL: TCnInt64List;
begin
  MeetNonEmpty := False;
  for I := FXs.Count - 1 downto 0 do
  begin
    YL := TCnInt64List(FXs[I]);
    Compact := CompactYDegree(YL);

    if not Compact then     // ����ѹ���� 0
      MeetNonEmpty := True;

    if Compact and not MeetNonEmpty then // ��ߵ�һ·����ѹ������ȫ 0 ��Ҫɾ��
    begin
      FXs.Delete(I);
      YL.Free;
    end;
  end;
end;

function TCnInt64BiPolynomial.CompactYDegree(YList: TCnInt64List): Boolean;
var
  I: Integer;
begin
  for I := YList.Count - 1 downto 0 do
  begin
    if YList[I] = 0 then
      YList.Delete(I)
    else
      Break;
  end;

  Result := YList.Count = 0;
end;

constructor TCnInt64BiPolynomial.Create(XDegree, YDegree: Integer);
begin
  FXs := TObjectList.Create(False);
  EnsureDegrees(XDegree, YDegree);
end;

destructor TCnInt64BiPolynomial.Destroy;
var
  I: Integer;
begin
  for I := FXs.Count - 1 downto 0 do
    FXs[I].Free;
  FXs.Free;
  inherited;
end;

procedure TCnInt64BiPolynomial.EnsureDegrees(XDegree, YDegree: Integer);
var
  I, OldCount: Integer;
begin
  CheckDegree(XDegree);
  CheckDegree(YDegree);

  OldCount := FXs.Count;
  if (XDegree + 1) > FXs.Count then
  begin
    for I := FXs.Count + 1 to XDegree + 1 do
    begin
      FXs.Add(TCnInt64List.Create);
      TCnInt64List(FXs[FXs.Count - 1]).Count := YDegree + 1;
    end;
  end;

  for I:= OldCount - 1 downto 0 do
    if TCnInt64List(FXs[I]).Count < YDegree + 1 then
      TCnInt64List(FXs[I]).Count := YDegree + 1;
end;

function TCnInt64BiPolynomial.GetMaxXDegree: Integer;
begin
  Result := FXs.Count - 1;
end;

function TCnInt64BiPolynomial.GetMaxYDegree: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FXs.Count - 1 downto 0 do
    if YFactorsList[I].Count - 1 > Result then
      Result := YFactorsList[I].Count - 1;
end;

function TCnInt64BiPolynomial.GetYFactorsList(
  Index: Integer): TCnInt64List;
begin
  if (Index < 0) or (Index >= FXs.Count) then
    raise ECnPolynomialException.CreateFmt(SCnInvalidDegree, [Index]);

  Result := TCnInt64List(FXs[Index]);
end;

function TCnInt64BiPolynomial.IsZero: Boolean;
begin
  Result := Int64BiPolynomialIsZero(Self);
end;

procedure TCnInt64BiPolynomial.Negate;
begin
  Int64BiPolynomialNegate(Self);
end;

procedure TCnInt64BiPolynomial.SetMaxXDegree(const Value: Integer);
var
  I: Integer;
begin
  CheckDegree(Value);

  if Value + 1 > FXs.Count then
  begin
    for I := FXs.Count + 1 to Value + 1 do
      FXs.Add(TCnInt64List.Create);
  end
  else if Value + 1 < FXs.Count then
  begin
    for I := FXs.Count - 1 downto Value + 1 do
    begin
      FXs[I].Free;
      FXs.Delete(I);
    end;
  end;
end;

procedure TCnInt64BiPolynomial.SetMaxYDegree(const Value: Integer);
var
  I: Integer;
begin
  CheckDegree(Value);

  for I := FXs.Count - 1 downto 0 do
    TCnInt64List(FXs[I]).Count := Value + 1;
end;

procedure TCnInt64BiPolynomial.SetString(const Poly: string);
begin
  Int64BiPolynomialSetString(Self, Poly);
end;

procedure TCnInt64BiPolynomial.SetZero;
begin
  Int64BiPolynomialSetZero(Self);
end;

function TCnInt64BiPolynomial.ToString: string;
begin
  Result := Int64BiPolynomialToString(Self);
end;

function Int64BiPolynomialNew: TCnInt64BiPolynomial;
begin
  Result := TCnInt64BiPolynomial.Create;
end;

procedure Int64BiPolynomialFree(const P: TCnInt64BiPolynomial);
begin
  P.Free;
end;

function Int64BiPolynomialDuplicate(const P: TCnInt64BiPolynomial): TCnInt64BiPolynomial;
begin
  if P = nil then
  begin
    Result := nil;
    Exit;
  end;

  Result := Int64BiPolynomialNew;
  if Result <> nil then
    Int64BiPolynomialCopy(Result, P);
end;

function Int64BiPolynomialCopy(const Dst: TCnInt64BiPolynomial;
  const Src: TCnInt64BiPolynomial): TCnInt64BiPolynomial;
var
  I: Integer;
begin
  Result := Dst;
  if Src <> Dst then
  begin
    if Src.MaxXDegree >= 0 then
    begin
      Dst.MaxXDegree := Src.MaxXDegree;
      for I := 0 to Src.MaxXDegree do
        CnInt64ListCopy(Dst.YFactorsList[I], Src.YFactorsList[I]);
    end
    else
      Dst.SetZero; // ��� Src δ��ʼ������ Dst Ҳ����
  end;
end;

function Int64BiPolynomialCopyFromX(const Dst: TCnInt64BiPolynomial;
  const SrcX: TCnInt64Polynomial): TCnInt64BiPolynomial;
var
  I: Integer;
begin
  Result := Dst;
  Dst.Clear;

  Dst.MaxXDegree := SrcX.MaxDegree;
  for I := 0 to SrcX.MaxDegree do
    Dst.SafeValue[I, 0] := SrcX[I]; // ��ÿһ�� YList ����Ԫ����ֵ
end;

function Int64BiPolynomialCopyFromY(const Dst: TCnInt64BiPolynomial;
  const SrcY: TCnInt64Polynomial): TCnInt64BiPolynomial;
var
  I: Integer;
begin
  Result := Dst;
  Dst.Clear;

  for I := 0 to SrcY.MaxDegree do
    Dst.YFactorsList[0].Add(SrcY[I]); // �����һ�� YList ������Ԫ����ֵ
end;

function Int64BiPolynomialToString(const P: TCnInt64BiPolynomial;
  const Var1Name: Char = 'X'; const Var2Name: Char = 'Y'): string;
var
  I, J: Integer;
  YL: TCnInt64List;
begin
  Result := '';
  for I := P.FXs.Count - 1 downto 0 do
  begin
    YL := TCnInt64List(P.FXs[I]);
    for J := YL.Count - 1 downto 0 do
    begin
      if VarItemFactor(Result, (J = 0) and (I = 0), IntToStr(YL[J])) then
        Result := Result + VarPower2(Var1Name, Var2Name, I, J);
    end;
  end;

  if Result = '' then
    Result := '0';
end;

function Int64BiPolynomialSetString(const P: TCnInt64BiPolynomial;
  const Str: string; const Var1Name: Char = 'X'; const Var2Name: Char = 'Y'): Boolean;
var
  C, Ptr: PChar;
  Num: string;
  E1, E2: Integer;
  F: Int64;
  IsNeg: Boolean;
begin
  // ��Ԫ����ʽ�ַ��������е���
  Result := False;
  if (P = nil) or (Str = '') then
    Exit;

  P.SetZero;
  C := @Str[1];

  while C^ <> #0 do
  begin
    if not (C^ in ['+', '-', '0'..'9']) and (C^ <> Var1Name) and (C^ <> Var2Name) then
    begin
      Inc(C);
      Continue;
    end;

    IsNeg := False;
    if C^ = '+' then
      Inc(C)
    else if C^ = '-' then
    begin
      IsNeg := True;
      Inc(C);
    end;

    F := 1;
    if C^ in ['0'..'9'] then // ��ϵ��
    begin
      Ptr := C;
      while C^ in ['0'..'9'] do
        Inc(C);

      // Ptr �� C ֮�������֣�����һ��ϵ��
      SetString(Num, Ptr, C - Ptr);
      F := StrToInt64(Num);
      if IsNeg then
        F := -F;
    end
    else if IsNeg then
      F := -F;

    E1 := 0;
    if C^ = Var1Name then
    begin
      E1 := 1;
      Inc(C);
      if C^ = '^' then // ��ָ��
      begin
        Inc(C);
        if C^ in ['0'..'9'] then
        begin
          Ptr := C;
          while C^ in ['0'..'9'] do
            Inc(C);

          // Ptr �� C ֮�������֣�����һ��ָ��
          SetString(Num, Ptr, C - Ptr);
          E1 := StrToInt64(Num);
        end;
      end;
    end;

    E2 := 0;
    if C^ = Var2Name then
    begin
      E2 := 1;
      Inc(C);
      if C^ = '^' then // ��ָ��
      begin
        Inc(C);
        if C^ in ['0'..'9'] then
        begin
          Ptr := C;
          while C^ in ['0'..'9'] do
            Inc(C);

          // Ptr �� C ֮�������֣�����һ��ָ��
          SetString(Num, Ptr, C - Ptr);
          E2 := StrToInt64(Num);
        end;
      end;
    end;

    // ��ָ�������ˣ���
    P.SafeValue[E1, E2] := F;
  end;

  Result := True;
end;

function Int64BiPolynomialIsZero(const P: TCnInt64BiPolynomial): Boolean;
begin
  Result := (P.FXs.Count = 1) and (TCnInt64List(P.FXs[0]).Count = 1)
    and (TCnInt64List(P.FXs[0])[0] = 0);
end;

procedure Int64BiPolynomialSetZero(const P: TCnInt64BiPolynomial);
var
  I: Integer;
begin
  if P.FXs.Count <= 0 then
    P.FXs.Add(TCnInt64List.Create)
  else
    for I := P.FXs.Count - 1 downto 1 do
    begin
      P.FXs[I].Free;
      P.FXs.Delete(I);
    end;

  if P.YFactorsList[0].Count <= 0 then
    P.YFactorsList[0].Add(0)
  else
  begin
    for I := P.YFactorsList[0].Count - 1 downto 1 do
      P.YFactorsList[0].Delete(I);

    P.YFactorsList[0][0] := 0;
  end;
end;

procedure Int64BiPolynomialSetOne(const P: TCnInt64BiPolynomial);
var
  I: Integer;
begin
  if P.FXs.Count <= 0 then
    P.FXs.Add(TCnInt64List.Create)
  else
    for I := P.FXs.Count - 1 downto 1 do
    begin
      P.FXs[I].Free;
      P.FXs.Delete(I);
    end;

  if P.YFactorsList[0].Count <= 0 then
    P.YFactorsList[0].Add(1)
  else
  begin
    for I := P.YFactorsList[0].Count - 1 downto 1 do
      P.YFactorsList[0].Delete(I);

    P.YFactorsList[0][0] := 1;
  end;
end;

procedure Int64BiPolynomialNegate(const P: TCnInt64BiPolynomial);
var
  I, J: Integer;
  YL: TCnInt64List;
begin
  for I := P.FXs.Count - 1 downto 0 do
  begin
    YL := TCnInt64List(P.FXs[I]);
    for J := YL.Count - 1 downto 0 do
      YL[J] := - YL[J];
  end;
end;

function Int64BiPolynomialIsMonicX(const P: TCnInt64BiPolynomial): Boolean;
begin
  Result := False;
  if P.MaxXDegree >= 0 then
    Result := (P.YFactorsList[P.MaxXDegree].Count = 1) and (P.YFactorsList[P.MaxXDegree][0] = 1);
end;

procedure Int64BiPolynomialShiftLeftX(const P: TCnInt64BiPolynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    Exit
  else if N < 0 then
    Int64BiPolynomialShiftRightX(P, -N)
  else
    for I := 0 to N - 1 do
      P.FXs.Insert(0, TCnInt64List.Create);
end;

procedure Int64BiPolynomialShiftRightX(const P: TCnInt64BiPolynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    Exit
  else if N < 0 then
    Int64BiPolynomialShiftLeftX(P, -N)
  else
  begin
    if N > P.FXs.Count then
      N := P.FXs.Count;

    for I := 0 to N - 1 do
    begin
      P.FXs[0].Free;
      P.FXs.Delete(0);
    end;
  end;
end;

function Int64BiPolynomialEqual(const A, B: TCnInt64BiPolynomial): Boolean;
var
  I, J: Integer;
begin
  Result := False;
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  if (A = nil) or (B = nil) then
    Exit;

  if A.MaxXDegree <> B.MaxXDegree then
    Exit;

  for I := A.FXs.Count - 1 downto 0 do
  begin
    if A.YFactorsList[I].Count <> B.YFactorsList[I].Count then
      Exit;

    for J := A.YFactorsList[I].Count - 1 downto 0 do
      if A.YFactorsList[I][J] <> B.YFactorsList[I][J] then
        Exit;
  end;
  Result := True;
end;

procedure Int64BiPolynomialAddWord(const P: TCnInt64BiPolynomial; N: Int64);
var
  I, J: Integer;
begin
  for I := P.FXs.Count - 1 downto 0 do
    for J := P.YFactorsList[I].Count - 1 downto 0 do
      P.YFactorsList[I][J] := P.YFactorsList[I][J] + N;
end;

procedure Int64BiPolynomialSubWord(const P: TCnInt64BiPolynomial; N: Int64);
var
  I, J: Integer;
begin
  for I := P.FXs.Count - 1 downto 0 do
    for J := P.YFactorsList[I].Count - 1 downto 0 do
      P.YFactorsList[I][J] := P.YFactorsList[I][J] - N;
end;

procedure Int64BiPolynomialMulWord(const P: TCnInt64BiPolynomial; N: Int64);
var
  I, J: Integer;
begin
  if N = 0 then
    P.SetZero
  else if N <> 1 then
    for I := P.FXs.Count - 1 downto 0 do
      for J := P.YFactorsList[I].Count - 1 downto 0 do
        P.YFactorsList[I][J] := P.YFactorsList[I][J] * N;
end;

procedure Int64BiPolynomialDivWord(const P: TCnInt64BiPolynomial; N: Int64);
var
  I, J: Integer;
begin
  if N = 0 then
    raise EDivByZero.Create(SDivByZero)
  else if N <> 1 then
    for I := P.FXs.Count - 1 downto 0 do
      for J := P.YFactorsList[I].Count - 1 downto 0 do
        P.YFactorsList[I][J] := P.YFactorsList[I][J] div N;
end;

procedure Int64BiPolynomialNonNegativeModWord(const P: TCnInt64BiPolynomial; N: Int64);
var
  I, J: Integer;
begin
  if N = 0 then
    raise EDivByZero.Create(SDivByZero);

  for I := P.FXs.Count - 1 downto 0 do
    for J := P.YFactorsList[I].Count - 1 downto 0 do
      P.YFactorsList[I][J] := Int64NonNegativeMod(P.YFactorsList[I][J], N);
end;

function Int64BiPolynomialAdd(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial): Boolean;
var
  I, J, MaxX, MaxY: Integer;
begin
  MaxX := Max(P1.MaxXDegree, P2.MaxXDegree);
  MaxY := Max(P1.MaxYDegree, P2.MaxYDegree);
  Res.MaxXDegree := MaxX;
  Res.MaxYDegree := MaxY;

  for I := MaxX downto 0 do
  begin
    for J := MaxY downto 0 do
    begin
      Res.YFactorsList[I][J] := P1.SafeValue[I, J] + P2.SafeValue[I, J];
    end;
  end;

  Res.CorrectTop;
  Result := True;
end;

function Int64BiPolynomialSub(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial): Boolean;
var
  I, J, MaxX, MaxY: Integer;
begin
  MaxX := Max(P1.MaxXDegree, P2.MaxXDegree);
  MaxY := Max(P1.MaxYDegree, P2.MaxYDegree);
  Res.MaxXDegree := MaxX;
  Res.MaxYDegree := MaxY;

  for I := MaxX downto 0 do
  begin
    for J := MaxY downto 0 do
    begin
      Res.YFactorsList[I][J] := P1.SafeValue[I, J] - P2.SafeValue[I, J];
    end;
  end;

  Res.CorrectTop;
  Result := True;
end;

function Int64BiPolynomialMul(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  P2: TCnInt64BiPolynomial): Boolean;
var
  I, J, K, L: Integer;
  R: TCnInt64BiPolynomial;
begin
  if P1.IsZero or P2.IsZero then
  begin
    Res.SetZero;
    Result := True;
    Exit;
  end;

  if (Res = P1) or (Res = P2) then
    R := FLocalInt64BiPolynomialPool.Obtain
  else
    R := Res;

  R.Clear;
  R.MaxXDegree := P1.MaxXDegree + P2.MaxXDegree;
  R.MaxYDegree := P1.MaxYDegree + P2.MaxYDegree;

  for I := P1.FXs.Count - 1 downto 0 do
  begin
    for J := P1.YFactorsList[I].Count - 1 downto 0 do
    begin
      // �õ� P1.SafeValue[I, J]��Ҫ������� P2 ��ÿһ��
      for K := P2.FXs.Count - 1 downto 0 do
      begin
        for L := P2.YFactorsList[K].Count - 1 downto 0 do
        begin
          R.SafeValue[I + K, J + L] := R.SafeValue[I + K, J + L] + P1.SafeValue[I, J] * P2.SafeValue[K, L];
        end;
      end;
    end;
  end;

  R.CorrectTop;
  if (Res = P1) or (Res = P2) then
  begin
    Int64BiPolynomialCopy(Res, R);
    FLocalInt64BiPolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function Int64BiPolynomialMulX(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  PX: TCnInt64Polynomial): Boolean;
var
  P: TCnInt64BiPolynomial;
begin
  P := FLocalInt64BiPolynomialPool.Obtain;
  try
    Int64BiPolynomialCopyFromX(P, PX);
    Result := Int64BiPolynomialMul(Res, P1, P);
  finally
    FLocalInt64BiPolynomialPool.Recycle(P);
  end;
end;

function Int64BiPolynomialMulY(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  PY: TCnInt64Polynomial): Boolean;
var
  P: TCnInt64BiPolynomial;
begin
  P := FLocalInt64BiPolynomialPool.Obtain;
  try
    Int64BiPolynomialCopyFromY(P, PY);
    Result := Int64BiPolynomialMul(Res, P1, P);
  finally
    FLocalInt64BiPolynomialPool.Recycle(P);
  end;
end;

function Int64BiPolynomialDivX(const Res: TCnInt64BiPolynomial; const Remain: TCnInt64BiPolynomial;
  const P: TCnInt64BiPolynomial; const Divisor: TCnInt64BiPolynomial): Boolean;
var
  SubRes: TCnInt64BiPolynomial; // ���ɵݼ���
  MulRes: TCnInt64BiPolynomial; // ���ɳ����˻�
  DivRes: TCnInt64BiPolynomial; // ������ʱ��
  I, D: Integer;
  TY: TCnInt64Polynomial;        // ������һ����ʽ��Ҫ�˵� Y ����ʽ
begin
  Result := False;
  if Int64BiPolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  if Divisor.MaxXDegree > P.MaxXDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      Int64BiPolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      Int64BiPolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  if not Divisor.IsMonicX then // ֻ֧�� X ����һ����ʽ
    Exit;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;
  TY := nil;

  try
    SubRes := FLocalInt64BiPolynomialPool.Obtain;
    Int64BiPolynomialCopy(SubRes, P);

    D := P.MaxXDegree - Divisor.MaxXDegree;
    DivRes := FLocalInt64BiPolynomialPool.Obtain;
    DivRes.MaxXDegree := D;
    MulRes := FLocalInt64BiPolynomialPool.Obtain;

    TY := FLocalInt64PolynomialPool.Obtain;

    for I := 0 to D do
    begin
      if P.MaxXDegree - I > SubRes.MaxXDegree then                 // �м���������λ
        Continue;

      Int64BiPolynomialCopy(MulRes, Divisor);
      Int64BiPolynomialShiftLeftX(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�

      Int64BiPolynomialExtractYByX(TY, SubRes, P.MaxXDegree - I);
      Int64BiPolynomialMulY(MulRes, MulRes, TY);                  // ��ʽ�˵���ߴ�ϵ����ͬ

      DivRes.SetYCoefficentsFromPolynomial(D - I, TY);            // �̷ŵ� DivRes λ��
      Int64BiPolynomialSub(SubRes, SubRes, MulRes);               // ���������·Ż� SubRes
    end;

    if Remain <> nil then
      Int64BiPolynomialCopy(Remain, SubRes);
    if Res <> nil then
      Int64BiPolynomialCopy(Res, DivRes);
  finally
    FLocalInt64BiPolynomialPool.Recycle(SubRes);
    FLocalInt64BiPolynomialPool.Recycle(MulRes);
    FLocalInt64BiPolynomialPool.Recycle(DivRes);
    FLocalInt64PolynomialPool.Recycle(TY);
  end;
  Result := True;
end;

function Int64BiPolynomialModX(const Res: TCnInt64BiPolynomial;
  const P: TCnInt64BiPolynomial; const Divisor: TCnInt64BiPolynomial): Boolean;
begin
  Result := Int64BiPolynomialDivX(nil, Res, P, Divisor);
end;

function Int64BiPolynomialPower(const Res: TCnInt64BiPolynomial;
  const P: TCnInt64BiPolynomial; Exponent: Int64): Boolean;
var
  T: TCnInt64BiPolynomial;
begin
  if Exponent = 0 then
  begin
    Res.SetOne;
    Result := True;
    Exit;
  end
  else if Exponent = 1 then
  begin
    if Res <> P then
      Int64BiPolynomialCopy(Res, P);
    Result := True;
    Exit;
  end
  else if Exponent < 0 then
    raise ECnPolynomialException.CreateFmt(SCnInvalidExponent, [Exponent]);

  T := FLocalInt64BiPolynomialPool.Obtain;
  Int64BiPolynomialCopy(T, P);

  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetOne;
    while Exponent > 0 do
    begin
      if (Exponent and 1) <> 0 then
        Int64BiPolynomialMul(Res, Res, T);

      Exponent := Exponent shr 1;
      Int64BiPolynomialMul(T, T, T);
    end;
    Result := True;
  finally
    FLocalInt64BiPolynomialPool.Recycle(T);
  end;
end;

function Int64BiPolynomialEvaluateByY(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; YValue: Int64): Boolean;
var
  I, J: Integer;
  Sum, TY: Int64;
  YL: TCnInt64List;
begin
  // ���ÿһ�� FXs[I] �� List������������ Y ���η�ֵ�ۼӣ���Ϊ X ��ϵ��
  Res.Clear;
  for I := 0 to P.FXs.Count - 1 do
  begin
    Sum := 0;
    TY := 1;
    YL := TCnInt64List(P.FXs[I]);

    for J := 0 to YL.Count - 1 do
    begin
      Sum := Sum + TY * YL[J];
      TY := TY * YValue;
    end;
    Res.Add(Sum);
  end;
  Result := True;
end;

function Int64BiPolynomialEvaluateByX(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; XValue: Int64): Boolean;
var
  I, J: Integer;
  Sum, TX: Int64;
begin
  // ���ÿһ�� Y ���������� FXs[I] �� List �еĸô���Ԫ�أ�����ۼӣ���Ϊ Y ��ϵ��
  Res.Clear;
  for I := 0 to P.MaxYDegree do
  begin
    Sum := 0;
    TX := 1;

    for J := 0 to P.FXs.Count - 1 do
    begin
      Sum := Sum + TX * P.SafeValue[J, I];
      TX := TX * XValue;
    end;
    Res.Add(Sum);
  end;
  Result := True;
end;

procedure Int64BiPolynomialTranspose(const Dst, Src: TCnInt64BiPolynomial);
var
  I, J: Integer;
  T: TCnInt64BiPolynomial;
begin
  if Src = Dst then
    T := FLocalInt64BiPolynomialPool.Obtain
  else
    T := Dst;

  // �� Src ת������ T ��
  T.SetZero;
  T.MaxXDegree := Src.MaxYDegree;
  T.MaxYDegree := Src.MaxXDegree;

  for I := Src.FXs.Count - 1 downto 0 do
    for J := Src.YFactorsList[I].Count - 1 downto 0 do
      T.SafeValue[J, I] := Src.SafeValue[I, J];

  if Src = Dst then
  begin
    Int64BiPolynomialCopy(Dst, T);
    FLocalInt64BiPolynomialPool.Recycle(T);
  end;
end;

procedure Int64BiPolynomialExtractYByX(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; XDegree: Int64);
begin
  CheckDegree(XDegree);
  if XDegree < P.FXs.Count then
    CnInt64ListCopy(Res, TCnInt64List(P.FXs[XDegree]))
  else
    Res.SetZero;
end;

procedure Int64BiPolynomialExtractXByY(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; YDegree: Int64);
var
  I: Integer;
begin
  CheckDegree(YDegree);
  Res.Clear;
  for I := 0 to P.FXs.Count - 1 do
    Res.Add(P.SafeValue[I, YDegree]);

  Res.CorrectTop;
end;

function Int64BiPolynomialGaloisEqual(const A, B: TCnInt64BiPolynomial; Prime: Int64): Boolean;
var
  I, J: Integer;
begin
  Result := False;
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  if (A = nil) or (B = nil) then
    Exit;

  if A.MaxXDegree <> B.MaxXDegree then
    Exit;

  for I := A.FXs.Count - 1 downto 0 do
  begin
    if A.YFactorsList[I].Count <> B.YFactorsList[I].Count then
      Exit;

    for J := A.YFactorsList[I].Count - 1 downto 0 do
      if (A.YFactorsList[I][J] <> B.YFactorsList[I][J]) and
        (Int64NonNegativeMod(A.YFactorsList[I][J], Prime) <> Int64NonNegativeMod(A.YFactorsList[I][J], Prime)) then
        Exit;
  end;
  Result := True;
end;

procedure Int64BiPolynomialGaloisNegate(const P: TCnInt64BiPolynomial; Prime: Int64);
var
  I, J: Integer;
  YL: TCnInt64List;
begin
  for I := P.FXs.Count - 1 downto 0 do
  begin
    YL := TCnInt64List(P.FXs[I]);
    for J := YL.Count - 1 downto 0 do
      YL[J] := Int64NonNegativeMod(-YL[J], Prime);
  end;
end;

function Int64BiPolynomialGaloisAdd(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial): Boolean;
begin
  Result := Int64BiPolynomialAdd(Res, P1, P2);
  if Result then
  begin
    Int64BiPolynomialNonNegativeModWord(Res, Prime);
    if Primitive <> nil then
      Int64BiPolynomialGaloisModX(Res, Res, Primitive, Prime);
  end;
end;

function Int64BiPolynomialGaloisSub(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial): Boolean;
begin
  Result := Int64BiPolynomialSub(Res, P1, P2);
  if Result then
  begin
    Int64BiPolynomialNonNegativeModWord(Res, Prime);
    if Primitive <> nil then
      Int64BiPolynomialGaloisModX(Res, Res, Primitive, Prime);
  end;
end;

function Int64BiPolynomialGaloisMul(const Res: TCnInt64BiPolynomial; const P1: TCnInt64BiPolynomial;
  const P2: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial): Boolean;
var
  I, J, K, L: Integer;
  R: TCnInt64BiPolynomial;
  T: Int64;
begin
  if P1.IsZero or P2.IsZero then
  begin
    Res.SetZero;
    Result := True;
    Exit;
  end;

  if (Res = P1) or (Res = P2) then
    R := FLocalInt64BiPolynomialPool.Obtain
  else
    R := Res;

  R.Clear;
  R.MaxXDegree := P1.MaxXDegree + P2.MaxXDegree;
  R.MaxYDegree := P1.MaxYDegree + P2.MaxYDegree;

  for I := P1.FXs.Count - 1 downto 0 do
  begin
    for J := P1.YFactorsList[I].Count - 1 downto 0 do
    begin
      // �õ� P1.SafeValue[I, J]��Ҫ������� P2 ��ÿһ��
      for K := P2.FXs.Count - 1 downto 0 do
      begin
        for L := P2.YFactorsList[K].Count - 1 downto 0 do
        begin
          // �������������ֱ�����
          T := Int64NonNegativeMulMod(P1.SafeValue[I, J], P2.SafeValue[K, L], Prime);
          R.SafeValue[I + K, J + L] := Int64NonNegativeMod(R.SafeValue[I + K, J + L] + Int64NonNegativeMod(T, Prime), Prime);
          // TODO: ��δ����ӷ���������
        end;
      end;
    end;
  end;

  R.CorrectTop;

  // �ٶԱ�ԭ����ʽȡģ��ע�����ﴫ��ı�ԭ����ʽ�� mod �����ĳ��������Ǳ�ԭ����ʽ����
  if Primitive <> nil then
    Int64BiPolynomialGaloisModX(R, R, Primitive, Prime);

  if (Res = P1) or (Res = P2) then
  begin
    Int64BiPolynomialCopy(Res, R);
    FLocalInt64BiPolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function Int64BiPolynomialGaloisMulX(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  PX: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial): Boolean;
var
  P: TCnInt64BiPolynomial;
begin
  P := FLocalInt64BiPolynomialPool.Obtain;
  try
    Int64BiPolynomialCopyFromX(P, PX);
    Result := Int64BiPolynomialGaloisMul(Res, P1, P, Prime, Primitive);
  finally
    FLocalInt64BiPolynomialPool.Recycle(P);
  end;
end;

function Int64BiPolynomialGaloisMulY(const Res: TCnInt64BiPolynomial; P1: TCnInt64BiPolynomial;
  PY: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial): Boolean;
var
  P: TCnInt64BiPolynomial;
begin
  P := FLocalInt64BiPolynomialPool.Obtain;
  try
    Int64BiPolynomialCopyFromY(P, PY);
    Result := Int64BiPolynomialGaloisMul(Res, P1, P, Prime, Primitive);
  finally
    FLocalInt64BiPolynomialPool.Recycle(P);
  end;
end;

function Int64BiPolynomialGaloisDivX(const Res: TCnInt64BiPolynomial;
  const Remain: TCnInt64BiPolynomial; const P: TCnInt64BiPolynomial;
  const Divisor: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial): Boolean;
var
  SubRes: TCnInt64BiPolynomial; // ���ɵݼ���
  MulRes: TCnInt64BiPolynomial; // ���ɳ����˻�
  DivRes: TCnInt64BiPolynomial; // ������ʱ��
  I, D: Integer;
  TY: TCnInt64Polynomial;        // ������һ����ʽ��Ҫ�˵� Y ����ʽ
begin
  Result := False;
  if Int64BiPolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  if Divisor.MaxXDegree > P.MaxXDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      Int64BiPolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      Int64BiPolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  if not Divisor.IsMonicX then // ֻ֧�� X ����һ����ʽ
    Exit;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;
  TY := nil;

  try
    SubRes := FLocalInt64BiPolynomialPool.Obtain;
    Int64BiPolynomialCopy(SubRes, P);

    D := P.MaxXDegree - Divisor.MaxXDegree;
    DivRes := FLocalInt64BiPolynomialPool.Obtain;
    DivRes.MaxXDegree := D;
    MulRes := FLocalInt64BiPolynomialPool.Obtain;

    TY := FLocalInt64PolynomialPool.Obtain;

    for I := 0 to D do
    begin
      if P.MaxXDegree - I > SubRes.MaxXDegree then                 // �м���������λ
        Continue;

      Int64BiPolynomialCopy(MulRes, Divisor);
      Int64BiPolynomialShiftLeftX(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�

      Int64BiPolynomialExtractYByX(TY, SubRes, P.MaxXDegree - I);
      Int64BiPolynomialGaloisMulY(MulRes, MulRes, TY, Prime, Primitive);     // ��ʽ�˵���ߴ�ϵ����ͬ

      DivRes.SetYCoefficentsFromPolynomial(D - I, TY);            // �̷ŵ� DivRes λ��
      Int64BiPolynomialGaloisSub(SubRes, SubRes, MulRes, Prime, Primitive);  // ���������·Ż� SubRes
    end;

    // ������ʽ����Ҫ��ģ��ԭ����ʽ
    if Primitive <> nil then
    begin
      Int64BiPolynomialGaloisModX(SubRes, SubRes, Primitive, Prime);
      Int64BiPolynomialGaloisModX(DivRes, DivRes, Primitive, Prime);
    end;

    if Remain <> nil then
      Int64BiPolynomialCopy(Remain, SubRes);
    if Res <> nil then
      Int64BiPolynomialCopy(Res, DivRes);
  finally
    FLocalInt64BiPolynomialPool.Recycle(SubRes);
    FLocalInt64BiPolynomialPool.Recycle(MulRes);
    FLocalInt64BiPolynomialPool.Recycle(DivRes);
    FLocalInt64PolynomialPool.Recycle(TY);
  end;
  Result := True;
end;

function Int64BiPolynomialGaloisModX(const Res: TCnInt64BiPolynomial; const P: TCnInt64BiPolynomial;
  const Divisor: TCnInt64BiPolynomial; Prime: Int64; Primitive: TCnInt64BiPolynomial): Boolean;
begin
  Result := Int64BiPolynomialGaloisDivX(nil, Res, P, Divisor, Prime, Primitive);
end;

function Int64BiPolynomialGaloisPower(const Res, P: TCnInt64BiPolynomial;
  Exponent: Int64; Prime: Int64; Primitive: TCnInt64BiPolynomial;
  ExponentHi: Int64): Boolean;
var
  T: TCnInt64BiPolynomial;
begin
  if Exponent128IsZero(Exponent, ExponentHi) then
  begin
    Res.SetOne;
    Result := True;
    Exit;
  end
  else if Exponent128IsOne(Exponent, ExponentHi) then
  begin
    if Res <> P then
      Int64BiPolynomialCopy(Res, P);
    Result := True;
    Exit;
  end;

  T := FLocalInt64BiPolynomialPool.Obtain;
  Int64BiPolynomialCopy(T, P);

  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetOne;
    while not Exponent128IsZero(Exponent, ExponentHi) do
    begin
      if (Exponent and 1) <> 0 then
        Int64BiPolynomialGaloisMul(Res, Res, T, Prime, Primitive);

      ExponentShiftRightOne(Exponent, ExponentHi);
      Int64BiPolynomialGaloisMul(T, T, T, Prime, Primitive);
    end;
    Result := True;
  finally
    FLocalInt64BiPolynomialPool.Recycle(T);
  end;
end;

function Int64BiPolynomialGaloisEvaluateByY(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; YValue, Prime: Int64): Boolean;
var
  I, J: Integer;
  Sum, TY: Int64;
  YL: TCnInt64List;
begin
  // ���ÿһ�� FXs[I] �� List������������ Y ���η�ֵ�ۼӣ���Ϊ X ��ϵ��
  Res.Clear;
  for I := 0 to P.FXs.Count - 1 do
  begin
    Sum := 0;
    TY := 1;
    YL := TCnInt64List(P.FXs[I]);

    for J := 0 to YL.Count - 1 do
    begin
      // TODO: �ݲ����������������
      Sum := Int64NonNegativeMod(Sum + Int64NonNegativeMulMod(TY, YL[J], Prime), Prime);
      TY := Int64NonNegativeMulMod(TY, YValue, Prime);
    end;
    Res.Add(Sum);
  end;
  Result := True;
end;

function Int64BiPolynomialGaloisEvaluateByX(const Res: TCnInt64Polynomial;
  const P: TCnInt64BiPolynomial; XValue, Prime: Int64): Boolean;
var
  I, J: Integer;
  Sum, TX: Int64;
begin
  // ���ÿһ�� Y ���������� FXs[I] �� List �еĸô���Ԫ�أ�����ۼӣ���Ϊ Y ��ϵ��
  Res.Clear;
  for I := 0 to P.MaxYDegree do
  begin
    Sum := 0;
    TX := 1;

    for J := 0 to P.FXs.Count - 1 do
    begin
      // TODO: �ݲ����������������
      Sum := Int64NonNegativeMod(Sum + Int64NonNegativeMulMod(TX, P.SafeValue[J, I], Prime), Prime);
      TX := Int64NonNegativeMulMod(TX, XValue, Prime);
    end;
    Res.Add(Sum);
  end;
  Result := True;
end;

procedure Int64BiPolynomialGaloisAddWord(const P: TCnInt64BiPolynomial; N: Int64; Prime: Int64);
var
  I, J: Integer;
begin
  for I := P.FXs.Count - 1 downto 0 do
    for J := P.YFactorsList[I].Count - 1 downto 0 do
      P.YFactorsList[I][J] := Int64NonNegativeMod(P.YFactorsList[I][J] + N, Prime);
end;

procedure Int64BiPolynomialGaloisSubWord(const P: TCnInt64BiPolynomial; N: Int64; Prime: Int64);
var
  I, J: Integer;
begin
  for I := P.FXs.Count - 1 downto 0 do
    for J := P.YFactorsList[I].Count - 1 downto 0 do
      P.YFactorsList[I][J] := Int64NonNegativeMod(P.YFactorsList[I][J] - N, Prime);
end;

procedure Int64BiPolynomialGaloisMulWord(const P: TCnInt64BiPolynomial; N: Int64; Prime: Int64);
var
  I, J: Integer;
begin
  if N = 0 then
    P.SetZero
  else // �� Prime ��Ҫ Mod�����ж��Ƿ��� 1 ��
    for I := P.FXs.Count - 1 downto 0 do
      for J := P.YFactorsList[I].Count - 1 downto 0 do
        P.YFactorsList[I][J] := Int64NonNegativeMulMod(P.YFactorsList[I][J], N, Prime);
end;

procedure Int64BiPolynomialGaloisDivWord(const P: TCnInt64BiPolynomial; N: Int64; Prime: Int64);
var
  I, J: Integer;
  K: Int64;
  B: Boolean;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SDivByZero);

  B := N < 0;
  if B then
    N := -N;

  K := CnInt64ModularInverse2(N, Prime);
  for I := P.FXs.Count - 1 downto 0 do
  begin
    for J := P.YFactorsList[I].Count - 1 downto 0 do
    begin
      P.YFactorsList[I][J] := Int64NonNegativeMulMod(P.YFactorsList[I][J], K, Prime);
      if B then
        P.YFactorsList[I][J] := Prime - P.YFactorsList[I][J];
    end;
  end;
end;

procedure TCnInt64BiPolynomial.SetXCoefficents(YDegree: Integer;
  LowToHighXCoefficients: array of const);
var
  I: Integer;
begin
  CheckDegree(YDegree);

  MaxXDegree := High(LowToHighXCoefficients);

  if YDegree > MaxYDegree then
    MaxYDegree := YDegree;

  for I := Low(LowToHighXCoefficients) to High(LowToHighXCoefficients) do
    SafeValue[I, YDegree] := ExtractInt64FromArrayConstElement(LowToHighXCoefficients[I]);
end;

procedure TCnInt64BiPolynomial.SetYCoefficents(XDegree: Integer;
  LowToHighYCoefficients: array of const);
var
  I: Integer;
begin
  CheckDegree(XDegree);

  if XDegree > MaxXDegree then
    MaxXDegree := XDegree;

  YFactorsList[XDegree].Clear;
  for I := Low(LowToHighYCoefficients) to High(LowToHighYCoefficients) do
    YFactorsList[XDegree].Add(ExtractInt64FromArrayConstElement(LowToHighYCoefficients[I]));
end;

procedure TCnInt64BiPolynomial.SetXYCoefficent(XDegree, YDegree: Integer;
  ACoefficient: Int64);
begin
  CheckDegree(XDegree);
  CheckDegree(YDegree);

  if MaxXDegree < XDegree then
    MaxXDegree := XDegree;

  if YFactorsList[XDegree].Count - 1 < YDegree then
    YFactorsList[XDegree].Count := YDegree + 1;

  YFactorsList[XDegree][YDegree] := ACoefficient;
end;

function TCnInt64BiPolynomial.GetSafeValue(XDegree, YDegree: Integer): Int64;
var
  YL: TCnInt64List;
begin
  Result := 0;
  if (XDegree >= 0) and (XDegree < FXs.Count) then
  begin
    YL := TCnInt64List(FXs[XDegree]);
    if (YDegree >= 0) and (YDegree < YL.Count) then
      Result := YL[YDegree];
  end;
end;

procedure TCnInt64BiPolynomial.SetSafeValue(XDegree, YDegree: Integer;
  const Value: Int64);
begin
  SetXYCoefficent(XDegree, YDegree, Value);
end;

procedure TCnInt64BiPolynomial.SetOne;
begin
  Int64BiPolynomialSetOne(Self);
end;

procedure TCnInt64BiPolynomial.Transpose;
begin
  Int64BiPolynomialTranspose(Self, Self);
end;

function TCnInt64BiPolynomial.IsMonicX: Boolean;
begin
  Result := Int64BiPolynomialIsMonicX(Self);
end;

procedure TCnInt64BiPolynomial.SetYCoefficentsFromPolynomial(
  XDegree: Integer; PY: TCnInt64Polynomial);
var
  I: Integer;
begin
  CheckDegree(XDegree);

  if XDegree > MaxXDegree then   // ȷ�� X ����� List ����
    MaxXDegree := XDegree;

  YFactorsList[XDegree].Clear;
  for I := 0 to PY.MaxDegree do
    YFactorsList[XDegree].Add(PY[I]); // ���ض��� YList ������Ԫ����ֵ
end;

procedure TCnInt64BiPolynomial.Clear;
var
  I: Integer;
begin
  if FXs.Count <= 0 then
    FXs.Add(TCnInt64List.Create)
  else
    for I := FXs.Count - 1 downto 1 do
    begin
      FXs[I].Free;
      FXs.Delete(I);
    end;

  YFactorsList[0].Clear;
end;

{ TCnInt64BiPolynomialPool }

function TCnInt64BiPolynomialPool.CreateObject: TObject;
begin
  Result := TCnInt64BiPolynomial.Create;
end;

function TCnInt64BiPolynomialPool.Obtain: TCnInt64BiPolynomial;
begin
  Result := TCnInt64BiPolynomial(inherited Obtain);
  Result.SetZero;
end;

procedure TCnInt64BiPolynomialPool.Recycle(Poly: TCnInt64BiPolynomial);
begin
  inherited Recycle(Poly);
end;

// ========================== ��Ԫ����ϵ������ʽ ===============================

function BigNumberBiPolynomialNew: TCnBigNumberBiPolynomial;
begin
  Result := TCnBigNumberBiPolynomial.Create;
end;

procedure BigNumberBiPolynomialFree(const P: TCnBigNumberBiPolynomial);
begin
  P.Free;
end;

function BigNumberBiPolynomialDuplicate(const P: TCnBigNumberBiPolynomial): TCnBigNumberBiPolynomial;
begin
  if P = nil then
  begin
    Result := nil;
    Exit;
  end;

  Result := BigNumberBiPolynomialNew;
  if Result <> nil then
    BigNumberBiPolynomialCopy(Result, P);
end;

function BigNumberBiPolynomialCopy(const Dst: TCnBigNumberBiPolynomial;
  const Src: TCnBigNumberBiPolynomial): TCnBigNumberBiPolynomial;
var
  I: Integer;
begin
  Result := Dst;
  if Src <> Dst then
  begin
    if Src.MaxXDegree >= 0 then
    begin
      Dst.MaxXDegree := Src.MaxXDegree;
      for I := 0 to Src.MaxXDegree do
      begin
        if Src.FXs[I] = nil then
        begin
          Dst.FXs[I].Free;
          Dst.FXs[I] := nil;
        end
        else
          Src.YFactorsList[I].AssignTo(Dst.YFactorsList[I]);
      end;
    end
    else
      Dst.SetZero; // ��� Src δ��ʼ������ Dst Ҳ����
  end;
end;

function BigNumberBiPolynomialCopyFromX(const Dst: TCnBigNumberBiPolynomial;
  const SrcX: TCnBigNumberPolynomial): TCnBigNumberBiPolynomial;
var
  I: Integer;
begin
  Result := Dst;
  Dst.Clear;

  Dst.MaxXDegree := SrcX.MaxDegree;
  for I := 0 to SrcX.MaxDegree do
    if SrcX[I].IsZero then
    begin
      Dst.FXs[I].Free;
      Dst.FXs[I] := nil;
    end
    else
      Dst.SafeValue[I, 0] := SrcX[I]; // ��ÿһ�� YList ����Ԫ����ֵ��0 ����� FXs ��Ӧ��
end;

function BigNumberBiPolynomialCopyFromY(const Dst: TCnBigNumberBiPolynomial;
  const SrcY: TCnBigNumberPolynomial): TCnBigNumberBiPolynomial;
var
  I: Integer;
begin
  Result := Dst;
  Dst.Clear;

  if not SrcY.IsZero then
    for I := 0 to SrcY.MaxDegree do
      Dst.YFactorsList[0].AddPair(I, SrcY[I]); // �����һ�� YList ������Ԫ����ֵ
end;

function BigNumberBiPolynomialToString(const P: TCnBigNumberBiPolynomial;
  const Var1Name: Char = 'X'; const Var2Name: Char = 'Y'): string;
var
  I, J: Integer;
  YL: TCnSparseBigNumberList;
begin
  Result := '';
  for I := P.FXs.Count - 1 downto 0 do
  begin
    YL := TCnSparseBigNumberList(P.FXs[I]);  // ֻ������ڵ���������� 0 ��
    if YL <> nil then
      for J := YL.Count - 1 downto 0 do
      begin
        if VarItemFactor(Result, (YL[J].Exponent = 0) and (I = 0), YL[J].Value.ToDec) then
          Result := Result + VarPower2(Var1Name, Var2Name, I, YL[J].Exponent);
      end;
  end;

  if Result = '' then
    Result := '0';
end;

function BigNumberBiPolynomialSetString(const P: TCnBigNumberBiPolynomial;
  const Str: string; const Var1Name: Char = 'X'; const Var2Name: Char = 'Y'): Boolean;
var
  C, Ptr: PChar;
  Num, ES: string;
  E1, E2: Integer;
  IsNeg: Boolean;
begin
  // ��Ԫ����ʽ�ַ��������е���
  Result := False;
  if (P = nil) or (Str = '') then
    Exit;

  P.SetZero;
  C := @Str[1];

  while C^ <> #0 do
  begin
    if not (C^ in ['+', '-', '0'..'9']) and (C^ <> Var1Name) and (C^ <> Var2Name) then
    begin
      Inc(C);
      Continue;
    end;

    IsNeg := False;
    if C^ = '+' then
      Inc(C)
    else if C^ = '-' then
    begin
      IsNeg := True;
      Inc(C);
    end;

    Num := '1';
    if C^ in ['0'..'9'] then // ��ϵ��
    begin
      Ptr := C;
      while C^ in ['0'..'9'] do
        Inc(C);

      // Ptr �� C ֮�������֣�����һ��ϵ��
      SetString(Num, Ptr, C - Ptr);
      if IsNeg then
        Num := '-' + Num;
    end
    else if IsNeg then
      Num := '-' + Num;

    E1 := 0;
    if C^ = Var1Name then
    begin
      E1 := 1;
      Inc(C);
      if C^ = '^' then // ��ָ��
      begin
        Inc(C);
        if C^ in ['0'..'9'] then
        begin
          Ptr := C;
          while C^ in ['0'..'9'] do
            Inc(C);

          // Ptr �� C ֮�������֣�����һ��ָ��
          SetString(ES, Ptr, C - Ptr);
          E1 := StrToInt64(ES);
        end;
      end;
    end;

    E2 := 0;
    if C^ = Var2Name then
    begin
      E2 := 1;
      Inc(C);
      if C^ = '^' then // ��ָ��
      begin
        Inc(C);
        if C^ in ['0'..'9'] then
        begin
          Ptr := C;
          while C^ in ['0'..'9'] do
            Inc(C);

          // Ptr �� C ֮�������֣�����һ��ָ��
          SetString(ES, Ptr, C - Ptr);
          E2 := StrToInt64(ES);
        end;
      end;
    end;

    // ��ָ�������ˣ���
    P.SafeValue[E1, E2].SetDec(Num);
  end;

  Result := True;
end;

function BigNumberBiPolynomialIsZero(const P: TCnBigNumberBiPolynomial): Boolean;
begin
  Result := True;
  if P.FXs.Count = 0 then
    Exit;

  if (P.FXs.Count = 1) and ((P.FXs[0] = nil) or (TCnSparseBigNumberList(P.FXs[0]).Count = 0)) then
    Exit;

  if (P.FXs.Count = 1) and (P.FXs[0] <> nil) and (TCnSparseBigNumberList(P.FXs[0]).Count = 1)
    and (TCnSparseBigNumberList(P.FXs[0])[0].Exponent = 0) and TCnSparseBigNumberList(P.FXs[0])[0].Value.IsZero then
    Exit;

  Result := False;
//  Result := (P.FXs.Count = 0) or
//    ((P.FXs.Count = 1) and (P.FXs[0] = nil)) or
//    (TCnSparseBigNumberList(P.FXs[0]).Count = 0) or
//    ((TCnSparseBigNumberList(P.FXs[0]).Count = 1) and (TCnSparseBigNumberList(P.FXs[0])[0].Exponent = 0)
//     and ((TCnSparseBigNumberList(P.FXs[0])[0].Value.IsZero)));
end;

procedure BigNumberBiPolynomialSetZero(const P: TCnBigNumberBiPolynomial);
//var
//  I: Integer;
begin
  P.FXs.Clear;
//  if P.FXs.Count <= 0 then
//    P.FXs.Add(TCnSparseBigNumberList.Create)
//  else
//    for I := P.FXs.Count - 1 downto 1 do
//    begin
//      P.FXs[I].Free;
//      P.FXs.Delete(I);
//    end;
//
//  if P.YFactorsList[0].Count <= 0 then
//    P.YFactorsList[0].Add(TCnExponentBigNumberPair.Create)
//  else
//  begin
//    for I := P.YFactorsList[0].Count - 1 downto 1 do
//      P.YFactorsList[0].Delete(I);
//
//    P.YFactorsList[0][0].Exponent := 0;
//    P.YFactorsList[0][0].Value.SetZero;
//  end;
end;

procedure BigNumberBiPolynomialSetOne(const P: TCnBigNumberBiPolynomial);
var
  I: Integer;
begin
  if P.FXs.Count <= 0 then
    P.FXs.Add(TCnSparseBigNumberList.Create)
  else
    for I := P.FXs.Count - 1 downto 1 do
    begin
      P.FXs[I].Free;
      P.FXs.Delete(I);
    end;

  if P.YFactorsList[0].Count <= 0 then
    P.YFactorsList[0].Add(TCnExponentBigNumberPair.Create)
  else
  begin
    for I := P.YFactorsList[0].Count - 1 downto 1 do
      P.YFactorsList[0].Delete(I);
  end;

  P.YFactorsList[0][0].Exponent := 0;
  P.YFactorsList[0][0].Value.SetOne;
end;

procedure BigNumberBiPolynomialNegate(const P: TCnBigNumberBiPolynomial);
var
  I, J: Integer;
  YL: TCnSparseBigNumberList;
begin
  for I := P.FXs.Count - 1 downto 0 do
  begin
    YL := TCnSparseBigNumberList(P.FXs[I]); // �粻���ڣ����贴��
    if YL <> nil then
      for J := YL.Count - 1 downto 0 do
        YL[I].Value.Negate;
  end;
end;

function BigNumberBiPolynomialIsMonicX(const P: TCnBigNumberBiPolynomial): Boolean;
begin
  Result := False;
  if P.MaxXDegree >= 0 then
    Result := (P.YFactorsList[P.MaxXDegree].Count = 1) and (P.YFactorsList[P.MaxXDegree][0].Exponent = 0)
      and (P.YFactorsList[P.MaxXDegree][0].Value.IsOne);
end;

procedure BigNumberBiPolynomialShiftLeftX(const P: TCnBigNumberBiPolynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    Exit
  else if N < 0 then
    BigNumberBiPolynomialShiftRightX(P, -N)
  else
    for I := 0 to N - 1 do
      P.FXs.InsertBatch(0, N);
end;

procedure BigNumberBiPolynomialShiftRightX(const P: TCnBigNumberBiPolynomial; N: Integer);
var
  I: Integer;
begin
  if N = 0 then
    Exit
  else if N < 0 then
    BigNumberBiPolynomialShiftLeftX(P, -N)
  else
  begin
    if N > P.FXs.Count then
      N := P.FXs.Count;

    for I := N - 1 downto 0 do
      P.FXs[I].Free;

    P.FXs.DeleteLow(N);
  end;
end;

function BigNumberBiPolynomialEqual(const A, B: TCnBigNumberBiPolynomial): Boolean;
var
  I: Integer;
begin
  Result := False;
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  if (A = nil) or (B = nil) then
    Exit;

  if A.MaxXDegree <> B.MaxXDegree then
    Exit;

  for I := A.FXs.Count - 1 downto 0 do
  begin
    if not SparseBigNumberListEqual(TCnSparseBigNumberList(A.FXs[I]), TCnSparseBigNumberList(B.FXs[I])) then
      Exit;

//    if (A.FXs[I] = nil) and (B.FXs[I] = nil) then
//      Continue;
//
//    if A.YFactorsList[I].Count <> B.YFactorsList[I].Count then
//      Exit;
//
//    for J := A.YFactorsList[I].Count - 1 downto 0 do
//      if (A.YFactorsList[I][J].Exponent <> B.YFactorsList[I][J].Exponent) or
//        not BigNumberEqual(A.YFactorsList[I][J].Value, B.YFactorsList[I][J].Value) then
//        Exit;
  end;
  Result := True;
end;

// ===================== ��Ԫ����ϵ������ʽ��ͨ���� ============================

procedure BigNumberBiPolynomialMulWord(const P: TCnBigNumberBiPolynomial; N: Int64);
var
  I, J: Integer;
begin
  if N = 0 then
    P.SetZero
  else if N <> 1 then
    for I := P.FXs.Count - 1 downto 0 do
      if P.FXs[I] <> nil then
        for J := P.YFactorsList[I].Count - 1 downto 0 do
          P.YFactorsList[I][J].Value.MulWord(N);
end;

procedure BigNumberBiPolynomialDivWord(const P: TCnBigNumberBiPolynomial; N: Int64);
var
  I, J: Integer;
begin
  if N = 0 then
    raise EDivByZero.Create(SDivByZero)
  else if N <> 1 then
    for I := P.FXs.Count - 1 downto 0 do
      if P.FXs[I] <> nil then
        for J := P.YFactorsList[I].Count - 1 downto 0 do
          P.YFactorsList[I][J].Value.DivWord(N);
end;

procedure BigNumberBiPolynomialNonNegativeModWord(const P: TCnBigNumberBiPolynomial; N: Int64);
var
  I, J: Integer;
begin
  if N = 0 then
    raise EDivByZero.Create(SDivByZero);

  for I := P.FXs.Count - 1 downto 0 do
    if P.FXs[I] <> nil then
      for J := P.YFactorsList[I].Count - 1 downto 0 do
        P.YFactorsList[I][J].Value.ModWord(N); // ���� NonNegativeMod ������
end;

procedure BigNumberBiPolynomialMulBigNumber(const P: TCnBigNumberBiPolynomial; N: TCnBigNumber);
var
  I, J: Integer;
begin
  if N.IsZero then
    P.SetZero
  else if not N.IsOne then
    for I := P.FXs.Count - 1 downto 0 do
      if P.FXs[I] <> nil then
        for J := P.YFactorsList[I].Count - 1 downto 0 do
          BigNumberMul(P.YFactorsList[I][J].Value, P.YFactorsList[I][J].Value, N);
end;

procedure BigNumberBiPolynomialDivBigNumber(const P: TCnBigNumberBiPolynomial; N: TCnBigNumber);
var
  I, J: Integer;
begin
  if N.IsZero then
    raise EDivByZero.Create(SDivByZero)
  else if not N.IsOne then
    for I := P.FXs.Count - 1 downto 0 do
      if P.FXs[I] <> nil then
        for J := P.YFactorsList[I].Count - 1 downto 0 do
          BigNumberDiv(P.YFactorsList[I][J].Value, nil, P.YFactorsList[I][J].Value, N);
end;

procedure BigNumberBiPolynomialNonNegativeModBigNumber(const P: TCnBigNumberBiPolynomial; N: TCnBigNumber);
var
  I, J: Integer;
begin
  if N.IsZero then
    raise EDivByZero.Create(SDivByZero);

  for I := P.FXs.Count - 1 downto 0 do
    if P.FXs[I] <> nil then
      for J := P.YFactorsList[I].Count - 1 downto 0 do
        BigNumberNonNegativeMod(P.YFactorsList[I][J].Value, P.YFactorsList[I][J].Value, N);
end;

function BigNumberBiPolynomialAdd(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial): Boolean;
var
  I, M: Integer;
  S1, S2: TCnSparseBigNumberList;
begin
  M := Max(P1.MaxXDegree, P2.MaxXDegree);
  Res.SetMaxXDegree(M);

  for I := M downto 0 do
  begin
    if I >= P1.FXs.Count then
      S1 := nil
    else
      S1 := TCnSparseBigNumberList(P1.FXs[I]);

    if I >= P2.FXs.Count then
      S2 := nil
    else
      S2 := TCnSparseBigNumberList(P2.FXs[I]);

    if (S1 = nil) and (S2 = nil) then
    begin
      Res.FXs[I].Free;
      Res.FXs[I] := nil;
    end
    else
      SparseBigNumberListMerge(Res.YFactorsList[I], S1, S2, True); // ��ѭ��ȷ������ÿһ�� Res.YFactorsList[I]
  end;
  Res.CorrectTop;
  Result := True;
end;

function BigNumberBiPolynomialSub(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial): Boolean;
var
  I, M: Integer;
  S1, S2: TCnSparseBigNumberList;
begin
  M := Max(P1.MaxXDegree, P2.MaxXDegree);
  Res.SetMaxXDegree(M);

  for I := M downto 0 do
  begin
    if I >= P1.FXs.Count then
      S1 := nil
    else
      S1 := TCnSparseBigNumberList(P1.FXs[I]);

    if I >= P2.FXs.Count then
      S2 := nil
    else
      S2 := TCnSparseBigNumberList(P2.FXs[I]);

    if (S1 = nil) and (S2 = nil) then
    begin
      Res.FXs[I].Free;
      Res.FXs[I] := nil;
    end
    else
      SparseBigNumberListMerge(Res.YFactorsList[I], S1, S2, False);
  end;
  Res.CorrectTop;
  Result := True;
end;

function BigNumberBiPolynomialMul(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  P2: TCnBigNumberBiPolynomial): Boolean;
var
  I, J, K, L: Integer;
  R: TCnBigNumberBiPolynomial;
  T: TCnBigNumber;
  Pair1, Pair2: TCnExponentBigNumberPair;
begin
  if P1.IsZero or P2.IsZero then
  begin
    Res.SetZero;
    Result := True;
    Exit;
  end;

  if (Res = P1) or (Res = P2) then
    R := FLocalBigNumberBiPolynomialPool.Obtain
  else
    R := Res;

  R.Clear;
  R.MaxXDegree := P1.MaxXDegree + P2.MaxXDegree;
  R.MaxYDegree := P1.MaxYDegree + P2.MaxYDegree;

  T := FLocalBigNumberPool.Obtain;
  try
    for I := P1.FXs.Count - 1 downto 0 do
    begin
      if P1.FXs[I] = nil then
        Continue;

      for J := P1.YFactorsList[I].Count - 1 downto 0 do
      begin
        Pair1 := P1.YFactorsList[I][J];
        // �õ� P1.SafeValue[I, J]��Ҫ������� P2 ��ÿһ��
        for K := P2.FXs.Count - 1 downto 0 do
        begin
          if P2.FXs[K] = nil then
            Continue;

          for L := P2.YFactorsList[K].Count - 1 downto 0 do
          begin
            Pair2 := P2.YFactorsList[K][L];
            BigNumberMul(T, Pair1.Value, Pair2.Value);
            BigNumberAdd(R.SafeValue[I + K, Pair1.Exponent + Pair2.Exponent],
              R.SafeValue[I + K, Pair1.Exponent + Pair2.Exponent], T);
          end;
        end;
      end;
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
  end;

  R.CorrectTop;
  if (Res = P1) or (Res = P2) then
  begin
    BigNumberBiPolynomialCopy(Res, R);
    FLocalBigNumberBiPolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function BigNumberBiPolynomialMulX(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  PX: TCnBigNumberPolynomial): Boolean;
var
  P: TCnBigNumberBiPolynomial;
begin
  P := FLocalBigNumberBiPolynomialPool.Obtain;
  try
    BigNumberBiPolynomialCopyFromX(P, PX);
    Result := BigNumberBiPolynomialMul(Res, P1, P);
  finally
    FLocalBigNumberBiPolynomialPool.Recycle(P);
  end;
end;

function BigNumberBiPolynomialMulY(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  PY: TCnBigNumberPolynomial): Boolean;
var
  P: TCnBigNumberBiPolynomial;
begin
  P := FLocalBigNumberBiPolynomialPool.Obtain;
  try
    BigNumberBiPolynomialCopyFromY(P, PY);
    Result := BigNumberBiPolynomialMul(Res, P1, P);
  finally
    FLocalBigNumberBiPolynomialPool.Recycle(P);
  end;
end;

function BigNumberBiPolynomialDivX(const Res: TCnBigNumberBiPolynomial;
  const Remain: TCnBigNumberBiPolynomial; const P: TCnBigNumberBiPolynomial;
  const Divisor: TCnBigNumberBiPolynomial): Boolean;
var
  SubRes: TCnBigNumberBiPolynomial; // ���ɵݼ���
  MulRes: TCnBigNumberBiPolynomial; // ���ɳ����˻�
  DivRes: TCnBigNumberBiPolynomial; // ������ʱ��
  I, D: Integer;
  TY: TCnBigNumberPolynomial;       // ������һ����ʽ��Ҫ�˵� Y ����ʽ
begin
  Result := False;
  if BigNumberBiPolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  if Divisor.MaxXDegree > P.MaxXDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      BigNumberBiPolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      BigNumberBiPolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  if not Divisor.IsMonicX then // ֻ֧�� X ����һ����ʽ
    Exit;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;
  TY := nil;

  try
    SubRes := FLocalBigNumberBiPolynomialPool.Obtain;
    BigNumberBiPolynomialCopy(SubRes, P);

    D := P.MaxXDegree - Divisor.MaxXDegree;
    DivRes := FLocalBigNumberBiPolynomialPool.Obtain;
    DivRes.MaxXDegree := D;
    MulRes := FLocalBigNumberBiPolynomialPool.Obtain;

    TY := FLocalBigNumberPolynomialPool.Obtain;

    for I := 0 to D do
    begin
      if P.MaxXDegree - I > SubRes.MaxXDegree then                 // �м���������λ
        Continue;

      BigNumberBiPolynomialCopy(MulRes, Divisor);
      BigNumberBiPolynomialShiftLeftX(MulRes, D - I);              // ���뵽 SubRes ����ߴ�

      BigNumberBiPolynomialExtractYByX(TY, SubRes, P.MaxXDegree - I);
      BigNumberBiPolynomialMulY(MulRes, MulRes, TY);               // ��ʽ�˵���ߴ�ϵ����ͬ

      DivRes.SetYCoefficentsFromPolynomial(D - I, TY);             // �̷ŵ� DivRes λ��
      BigNumberBiPolynomialSub(SubRes, SubRes, MulRes);            // ���������·Ż� SubRes
    end;

    if Remain <> nil then
      BigNumberBiPolynomialCopy(Remain, SubRes);
    if Res <> nil then
      BigNumberBiPolynomialCopy(Res, DivRes);
  finally
    FLocalBigNumberBiPolynomialPool.Recycle(SubRes);
    FLocalBigNumberBiPolynomialPool.Recycle(MulRes);
    FLocalBigNumberBiPolynomialPool.Recycle(DivRes);
    FLocalBigNumberPolynomialPool.Recycle(TY);
  end;
  Result := True;
end;

function BigNumberBiPolynomialModX(const Res: TCnBigNumberBiPolynomial;
  const P: TCnBigNumberBiPolynomial; const Divisor: TCnBigNumberBiPolynomial): Boolean;
begin
  Result := BigNumberBiPolynomialDivX(nil, Res, P, Divisor);
end;

function BigNumberBiPolynomialPower(const Res: TCnBigNumberBiPolynomial;
  const P: TCnBigNumberBiPolynomial; Exponent: TCnBigNumber): Boolean;
var
  T: TCnBigNumberBiPolynomial;
  E: TCnBigNumber;
begin
  if Exponent.IsZero then
  begin
    Res.SetOne;
    Result := True;
    Exit;
  end
  else if Exponent.IsOne then
  begin
    if Res <> P then
      BigNumberBiPolynomialCopy(Res, P);
    Result := True;
    Exit;
  end
  else if Exponent.IsNegative then
    raise ECnPolynomialException.CreateFmt(SCnInvalidExponent, [Exponent.ToDec]);

  T := FLocalBigNumberBiPolynomialPool.Obtain;
  BigNumberBiPolynomialCopy(T, P);
  E := FLocalBigNumberPool.Obtain;
  BigNumberCopy(E, Exponent);

  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetOne;
    while not E.IsNegative and not E.IsZero do
    begin
      if BigNumberIsBitSet(E, 0) then
        BigNumberBiPolynomialMul(Res, Res, T);

      BigNumberShiftRightOne(E, E);
      BigNumberBiPolynomialMul(T, T, T);
    end;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(E);
    FLocalBigNumberBiPolynomialPool.Recycle(T);
  end;
end;

function BigNumberBiPolynomialEvaluateByY(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; YValue: TCnBigNumber): Boolean;
var
  I, J: Integer;
  Sum, TY, T: TCnBigNumber;
  YL: TCnSparseBigNumberList;
  Pair: TCnExponentBigNumberPair;
begin
  // ���ÿһ�� FXs[I] �� List������������ Y ���η�ֵ�ۼӣ���Ϊ X ��ϵ��
  Res.Clear;
  Sum := nil;
  TY := nil;
  T := nil;

  try
    Sum := FLocalBigNumberPool.Obtain;
    TY := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;

    for I := 0 to P.FXs.Count - 1 do
    begin
      if P.FXs[I] = nil then
        Continue;

      Sum.SetZero;
      YL := P.YFactorsList[I];

      if YL.Count > 0 then
      begin
        if YL.Bottom.Exponent = 0 then
          TY.SetOne
        else
          BigNumberPower(TY, YValue, YL.Bottom.Exponent);

        for J := 0 to YL.Count - 1 do
        begin
          Pair := YL[J];

          // Sum := Sum + TY * YL[J];
          BigNumberMul(T, TY, Pair.Value);
          BigNumberAdd(Sum, Sum, T);

          // TY := TY * Power(YValue, YL[J+1].Exponent - YL[J].Exponent);
          if J < YL.Count - 1 then
          begin
            BigNumberPower(T, YValue, YL[J + 1].Exponent - YL[J].Exponent);
            BigNumberMul(TY, TY, T);
          end;
        end;
      end;
      BigNumberCopy(Res.Add, Sum);
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(TY);
    FLocalBigNumberPool.Recycle(Sum);
  end;
  Result := True;
end;

function BigNumberBiPolynomialEvaluateByX(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; XValue: TCnBigNumber): Boolean;
var
  I, J: Integer;
  Sum, TX, T: TCnBigNumber;
begin
  // ���ÿһ�� Y ���������� FXs[I] �� List �еĸô���Ԫ�أ�����ۼӣ���Ϊ Y ��ϵ��
  Res.Clear;
  Sum := nil;
  TX := nil;
  T := nil;

  try
    Sum := FLocalBigNumberPool.Obtain;
    TX := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;

    for I := 0 to P.MaxYDegree do
    begin
      Sum.SetZero;
      TX.SetOne;

      for J := 0 to P.FXs.Count - 1 do
      begin
        //Sum := Sum + TX * P.SafeValue[J, I];
        BigNumberMul(T, TX, P.ReadonlyValue[J, I]);
        BigNumberAdd(Sum, Sum, T);

        //TX := TX * XValue;
        BigNumberMul(TX, TX, XValue);
      end;
      BigNumberCopy(Res.Add, Sum);
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(TX);
    FLocalBigNumberPool.Recycle(Sum);
  end;
  Result := True;
end;

procedure BigNumberBiPolynomialTranspose(const Dst, Src: TCnBigNumberBiPolynomial);
var
  I, J: Integer;
  T: TCnBigNumberBiPolynomial;
  Pair: TCnExponentBigNumberPair;
begin
  if Src = Dst then
    T := FLocalBigNumberBiPolynomialPool.Obtain
  else
    T := Dst;

  // �� Src ת������ T ��
  T.SetZero;
  T.MaxXDegree := Src.MaxYDegree;
  T.MaxYDegree := Src.MaxXDegree;

  for I := Src.FXs.Count - 1 downto 0 do
  begin
    if Src.FXs[I] <> nil then
      for J := Src.YFactorsList[I].Count - 1 downto 0 do
      begin
        Pair := Src.YFactorsList[I][J];
        T.SafeValue[Pair.Exponent, I] := Pair.Value; // �ڲ�����
      end;
  end;

  if Src = Dst then
  begin
    BigNumberBiPolynomialCopy(Dst, T);
    FLocalBigNumberBiPolynomialPool.Recycle(T);
  end;
end;

procedure BigNumberBiPolynomialExtractYByX(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; XDegree: Integer);
var
  I: Integer;
  Pair: TCnExponentBigNumberPair;
begin
  CheckDegree(XDegree);
  Res.SetZero;

  if XDegree < P.FXs.Count then
  begin
    if P.FXs[XDegree] <> nil then
    begin
      Pair := P.YFactorsList[XDegree].Top;
      Res.MaxDegree := Pair.Exponent;

      for I := 0 to P.YFactorsList[XDegree].Count - 1 do
      begin
        Pair := P.YFactorsList[XDegree][I];
        if Res[Pair.Exponent] = nil then
          Res[Pair.Exponent] := TCnBigNumber.Create;

        BigNumberCopy(Res[Pair.Exponent], Pair.Value);
      end;
    end;
  end;
end;

procedure BigNumberBiPolynomialExtractXByY(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; YDegree: Integer);
var
  I: Integer;
begin
  CheckDegree(YDegree);
  Res.Clear;
  for I := 0 to P.FXs.Count - 1 do
    BigNumberCopy(Res.Add, P.ReadonlyValue[I, YDegree]);

  Res.CorrectTop;
end;

// ================== ��Ԫ����ϵ������ʽʽ���������ϵ�ģ���� ===================

function BigNumberBiPolynomialGaloisEqual(const A, B: TCnBigNumberBiPolynomial; Prime: TCnBigNumber): Boolean;
var
  I, J: Integer;
  T1, T2: TCnBigNumber;
begin
  Result := False;
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  if (A = nil) or (B = nil) then
    Exit;

  if A.MaxXDegree <> B.MaxXDegree then
    Exit;

  T1 := nil;
  T2 := nil;

  try
    T1 := FLocalBigNumberPool.Obtain;
    T2 := FLocalBigNumberPool.Obtain;

    for I := A.FXs.Count - 1 downto 0 do
    begin
      // TODO: δ���� A[I] �� B[I] һ���� nil����һ������ mod ������� 0 ������
      if (A.FXs[I] = nil) and (B.FXs[I] = nil) then
        Continue
      else if A.FXs[I] = nil then // �ж� B �Ƿ�Ϊ 0
      begin
        if not SparseBigNumberListIsZero(TCnSparseBigNumberList(B.FXs[I])) then
          Exit;
      end
      else if B.FXs[I] = nil then // �ж� A �Ƿ�Ϊ 0
      begin
        if not SparseBigNumberListIsZero(TCnSparseBigNumberList(A.FXs[I])) then
          Exit;
      end;

      if A.YFactorsList[I].Count <> B.YFactorsList[I].Count then
        Exit;

      for J := A.YFactorsList[I].Count - 1 downto 0 do
      begin
        if (A.YFactorsList[I][J].Exponent <> B.YFactorsList[I][J].Exponent) or
          not BigNumberEqual(A.YFactorsList[I][J].Value, B.YFactorsList[I][J].Value) then
        begin
          BigNumberNonNegativeMod(T1, A.YFactorsList[I][J].Value, Prime);
          BigNumberNonNegativeMod(T2, B.YFactorsList[I][J].Value, Prime);
          if not BigNumberEqual(T1, T2) then
            Exit;
        end;
      end;
    end;
  finally
    FLocalBigNumberPool.Recycle(T1);
    FLocalBigNumberPool.Recycle(T2);
  end;
  Result := True;
end;

procedure BigNumberBiPolynomialGaloisNegate(const P: TCnBigNumberBiPolynomial; Prime: TCnBigNumber);
var
  I, J: Integer;
  YL: TCnSparseBigNumberList;
begin
  for I := P.FXs.Count - 1 downto 0 do
  begin
    YL := TCnSparseBigNumberList(P.FXs[I]);
    if YL <> nil then
      for J := YL.Count - 1 downto 0 do
      begin
        YL[J].Value.Negate;
        BigNumberNonNegativeMod(YL[J].Value, YL[J].Value, Prime);
      end;
  end;
end;

function BigNumberBiPolynomialGaloisAdd(const Res: TCnBigNumberBiPolynomial;
  const P1: TCnBigNumberBiPolynomial; const P2: TCnBigNumberBiPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial): Boolean;
begin
  Result := BigNumberBiPolynomialAdd(Res, P1, P2);
  if Result then
  begin
    BigNumberBiPolynomialNonNegativeModBigNumber(Res, Prime);
    if Primitive <> nil then
      BigNumberBiPolynomialGaloisModX(Res, Res, Primitive, Prime);
  end;
end;

function BigNumberBiPolynomialGaloisSub(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial): Boolean;
begin
  Result := BigNumberBiPolynomialSub(Res, P1, P2);
  if Result then
  begin
    BigNumberBiPolynomialNonNegativeModBigNumber(Res, Prime);
    if Primitive <> nil then
      BigNumberBiPolynomialGaloisModX(Res, Res, Primitive, Prime);
  end;
end;

function BigNumberBiPolynomialGaloisMul(const Res: TCnBigNumberBiPolynomial; const P1: TCnBigNumberBiPolynomial;
  const P2: TCnBigNumberBiPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial): Boolean;
var
  I, J, K, L: Integer;
  R: TCnBigNumberBiPolynomial;
  T: TCnBigNumber;
  Pair1, Pair2: TCnExponentBigNumberPair;
begin
  if P1.IsZero or P2.IsZero then
  begin
    Res.SetZero;
    Result := True;
    Exit;
  end;

  if (Res = P1) or (Res = P2) then
    R := FLocalBigNumberBiPolynomialPool.Obtain
  else
    R := Res;

  R.Clear;
  R.MaxXDegree := P1.MaxXDegree + P2.MaxXDegree;
  R.MaxYDegree := P1.MaxYDegree + P2.MaxYDegree;

  T := FLocalBigNumberPool.Obtain;
  try
    for I := P1.FXs.Count - 1 downto 0 do
    begin
      if P1.FXs[I] = nil then
        Continue;

      for J := P1.YFactorsList[I].Count - 1 downto 0 do
      begin
        Pair1 := P1.YFactorsList[I][J];
        // �õ� P1.SafeValue[I, J] ��ķ� 0 �Ҫ������� P2 ��ÿһ���� 0 ��
        for K := P2.FXs.Count - 1 downto 0 do
        begin
          if P2.FXs[K] = nil then
            Continue;

          for L := P2.YFactorsList[K].Count - 1 downto 0 do
          begin
            Pair2 := P2.YFactorsList[K][L];
            BigNumberMul(T, Pair1.Value, Pair2.Value);
            BigNumberAdd(R.SafeValue[I + K, Pair1.Exponent + Pair2.Exponent],
              R.SafeValue[I + K, Pair1.Exponent + Pair2.Exponent], T);
            BigNumberNonNegativeMod(R.SafeValue[I + K, Pair1.Exponent + Pair2.Exponent],
              R.SafeValue[I + K, Pair1.Exponent + Pair2.Exponent], Prime);
          end;
        end;
      end;
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
  end;

  R.CorrectTop;
  if Primitive <> nil then
    BigNumberBiPolynomialGaloisModX(R, R, Primitive, Prime);

  if (Res = P1) or (Res = P2) then
  begin
    BigNumberBiPolynomialCopy(Res, R);
    FLocalBigNumberBiPolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function BigNumberBiPolynomialGaloisMulX(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  PX: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial): Boolean;
var
  P: TCnBigNumberBiPolynomial;
begin
  P := FLocalBigNumberBiPolynomialPool.Obtain;
  try
    BigNumberBiPolynomialCopyFromX(P, PX);
    Result := BigNumberBiPolynomialGaloisMul(Res, P1, P, Prime, Primitive);
  finally
    FLocalBigNumberBiPolynomialPool.Recycle(P);
  end;
end;

function BigNumberBiPolynomialGaloisMulY(const Res: TCnBigNumberBiPolynomial; P1: TCnBigNumberBiPolynomial;
  PY: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial): Boolean;
var
  P: TCnBigNumberBiPolynomial;
begin
  P := FLocalBigNumberBiPolynomialPool.Obtain;
  try
    BigNumberBiPolynomialCopyFromY(P, PY);
    Result := BigNumberBiPolynomialGaloisMul(Res, P1, P, Prime, Primitive);
  finally
    FLocalBigNumberBiPolynomialPool.Recycle(P);
  end;
end;

function BigNumberBiPolynomialGaloisDivX(const Res: TCnBigNumberBiPolynomial;
  const Remain: TCnBigNumberBiPolynomial; const P: TCnBigNumberBiPolynomial;
  const Divisor: TCnBigNumberBiPolynomial; Prime: TCnBigNumber;
  Primitive: TCnBigNumberBiPolynomial): Boolean;
var
  SubRes: TCnBigNumberBiPolynomial; // ���ɵݼ���
  MulRes: TCnBigNumberBiPolynomial; // ���ɳ����˻�
  DivRes: TCnBigNumberBiPolynomial; // ������ʱ��
  I, D: Integer;
  TY: TCnBigNumberPolynomial;       // ������һ����ʽ��Ҫ�˵� Y ����ʽ
begin
  Result := False;
  if BigNumberBiPolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  if Divisor.MaxXDegree > P.MaxXDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      BigNumberBiPolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      BigNumberBiPolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  if not Divisor.IsMonicX then // ֻ֧�� X ����һ����ʽ
    Exit;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;
  TY := nil;

  try
    SubRes := FLocalBigNumberBiPolynomialPool.Obtain;
    BigNumberBiPolynomialCopy(SubRes, P);

    D := P.MaxXDegree - Divisor.MaxXDegree;
    DivRes := FLocalBigNumberBiPolynomialPool.Obtain;
    DivRes.MaxXDegree := D;
    MulRes := FLocalBigNumberBiPolynomialPool.Obtain;

    TY := FLocalBigNumberPolynomialPool.Obtain;

    for I := 0 to D do
    begin
      if P.MaxXDegree - I > SubRes.MaxXDegree then                 // �м���������λ
        Continue;

      BigNumberBiPolynomialCopy(MulRes, Divisor);
      BigNumberBiPolynomialShiftLeftX(MulRes, D - I);              // ���뵽 SubRes ����ߴ�

      BigNumberBiPolynomialExtractYByX(TY, SubRes, P.MaxXDegree - I);
      BigNumberBiPolynomialGaloisMulY(MulRes, MulRes, TY, Prime, Primitive);               // ��ʽ�˵���ߴ�ϵ����ͬ

      DivRes.SetYCoefficentsFromPolynomial(D - I, TY);             // �̷ŵ� DivRes λ��
      BigNumberBiPolynomialGaloisSub(SubRes, SubRes, MulRes, Prime, Primitive);            // ���������·Ż� SubRes
    end;

    // ������ʽ����Ҫ��ģ��ԭ����ʽ
    if Primitive <> nil then
    begin
      BigNumberBiPolynomialGaloisModX(SubRes, SubRes, Primitive, Prime);
      BigNumberBiPolynomialGaloisModX(DivRes, DivRes, Primitive, Prime);
    end;

    if Remain <> nil then
      BigNumberBiPolynomialCopy(Remain, SubRes);
    if Res <> nil then
      BigNumberBiPolynomialCopy(Res, DivRes);
  finally
    FLocalBigNumberBiPolynomialPool.Recycle(SubRes);
    FLocalBigNumberBiPolynomialPool.Recycle(MulRes);
    FLocalBigNumberBiPolynomialPool.Recycle(DivRes);
    FLocalBigNumberPolynomialPool.Recycle(TY);
  end;
  Result := True;
end;

function BigNumberBiPolynomialGaloisModX(const Res: TCnBigNumberBiPolynomial;
  const P: TCnBigNumberBiPolynomial; const Divisor: TCnBigNumberBiPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial): Boolean;
begin
  Result := BigNumberBiPolynomialGaloisDivX(nil, Res, P, Divisor, Prime, Primitive);
end;

function BigNumberBiPolynomialGaloisPower(const Res, P: TCnBigNumberBiPolynomial;
  Exponent: TCnBigNumber; Prime: TCnBigNumber; Primitive: TCnBigNumberBiPolynomial): Boolean;
var
  T: TCnBigNumberBiPolynomial;
  E: TCnBigNumber;
begin
  if Exponent.IsZero then
  begin
    Res.SetOne;
    Result := True;
    Exit;
  end
  else if Exponent.IsOne then
  begin
    if Res <> P then
      BigNumberBiPolynomialCopy(Res, P);
    Result := True;
    Exit;
  end
  else if Exponent.IsNegative then
    raise ECnPolynomialException.CreateFmt(SCnInvalidExponent, [Exponent.ToDec]);

  T := FLocalBigNumberBiPolynomialPool.Obtain;
  BigNumberBiPolynomialCopy(T, P);
  E := FLocalBigNumberPool.Obtain;
  BigNumberCopy(E, Exponent);

  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetOne;
    while not E.IsNegative and not E.IsZero do
    begin
      if BigNumberIsBitSet(E, 0) then
        BigNumberBiPolynomialGaloisMul(Res, Res, T, Prime, Primitive);

      BigNumberShiftRightOne(E, E);
      BigNumberBiPolynomialGaloisMul(T, T, T, Prime, Primitive);
    end;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(E);
    FLocalBigNumberBiPolynomialPool.Recycle(T);
  end;
end;

function BigNumberBiPolynomialGaloisEvaluateByY(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; YValue, Prime: TCnBigNumber): Boolean;
var
  I, J: Integer;
  Sum, TY, T, TE: TCnBigNumber;
  YL: TCnSparseBigNumberList;
  Pair: TCnExponentBigNumberPair;
begin
  // ���ÿһ�� FXs[I] �� List������������ Y ���η�ֵ�ۼӣ���Ϊ X ��ϵ��
  Res.Clear;
  Sum := nil;
  TY := nil;
  TE := nil;
  T := nil;

  try
    Sum := FLocalBigNumberPool.Obtain;
    TY := FLocalBigNumberPool.Obtain;
    TE := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;

    for I := 0 to P.FXs.Count - 1 do
    begin
      if P.FXs[I] = nil then
        Continue;

      Sum.SetZero;
      YL := P.YFactorsList[I];

      if YL.Count > 0 then
      begin
        if YL.Bottom.Exponent = 0 then
          TY.SetOne
        else if YL.Bottom.Exponent = 1 then
          BigNumberCopy(TY, YValue)
        else if YL.Bottom.Exponent = 2 then
          BigNumberDirectMulMod(TY, YValue, YValue, Prime)
        else
        begin
          T.SetWord(YL.Bottom.Exponent);
          BigNumberPowerMod(TY, YValue, T, Prime);
        end;

        for J := 0 to YL.Count - 1 do
        begin
          Pair := YL[J];

          // Sum := Sum + TY * YL[J];
          BigNumberMul(T, TY, Pair.Value);
          BigNumberAdd(Sum, Sum, T);
          BigNumberNonNegativeMod(Sum, Sum, Prime);

          // TY := TY * Power(YValue, YL[J+1].Exponent - YL[J].Exponent);
          if J < YL.Count - 1 then
          begin
            TE.SetWord(YL[J + 1].Exponent - YL[J].Exponent);
            BigNumberPowerMod(T, YValue, TE, Prime);
            BigNumberDirectMulMod(TY, TY, T, Prime);
          end;
        end;
      end;
      BigNumberCopy(Res.Add, Sum);
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(TY);
    FLocalBigNumberPool.Recycle(TE);
    FLocalBigNumberPool.Recycle(Sum);
  end;
  Result := True;
end;

function BigNumberBiPolynomialGaloisEvaluateByX(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberBiPolynomial; XValue, Prime: TCnBigNumber): Boolean;
var
  I, J: Integer;
  Sum, TX, T: TCnBigNumber;
begin
  // ���ÿһ�� Y ���������� FXs[I] �� List �еĸô���Ԫ�أ�����ۼӣ���Ϊ Y ��ϵ��
  Res.Clear;
  Sum := nil;
  TX := nil;
  T := nil;

  try
    Sum := FLocalBigNumberPool.Obtain;
    TX := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;

    for I := 0 to P.MaxYDegree do
    begin
      Sum.SetZero;
      TX.SetOne;

      for J := 0 to P.FXs.Count - 1 do
      begin
        if P.FXs[J] <> nil then
        begin
          //Sum := Sum + TX * P.SafeValue[J, I];
          BigNumberMul(T, TX, P.ReadonlyValue[J, I]);
          BigNumberAdd(Sum, Sum, T);
          BigNumberNonNegativeMod(Sum, Sum, Prime);
        end;

        //TX := TX * XValue;
        BigNumberMul(TX, TX, XValue);
        BigNumberNonNegativeMod(TX, TX, Prime);
      end;
      BigNumberCopy(Res.Add, Sum);
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(TX);
    FLocalBigNumberPool.Recycle(Sum);
  end;
  Result := True;
end;

procedure BigNumberBiPolynomialGaloisMulWord(const P: TCnBigNumberBiPolynomial;
  N: Int64; Prime: TCnBigNumber);
var
  I, J: Integer;
begin
  if N = 0 then
    P.SetZero
  else // �� Prime ��Ҫ Mod�����ж��Ƿ��� 1 ��
    for I := P.FXs.Count - 1 downto 0 do
    begin
      if P.FXs[I] <> nil then
        for J := P.YFactorsList[I].Count - 1 downto 0 do
        begin
          P.YFactorsList[I][J].Value.MulWord(N);
          BigNumberNonNegativeMod(P.YFactorsList[I][J].Value, P.YFactorsList[I][J].Value, Prime);
        end;
    end;
end;

procedure BigNumberBiPolynomialGaloisDivWord(const P: TCnBigNumberBiPolynomial;
  N: Int64; Prime: TCnBigNumber);
var
  I, J: Integer;
  B: Boolean;
  K, T: TCnBigNumber;
begin
  if N = 0 then
    raise EDivByZero.Create(SDivByZero);

  B := N < 0;
  if B then
    N := -N;

  K := nil;
  T := nil;

  try
    K := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;
    T.SetWord(N);

    BigNumberModularInverse(K, T, Prime);

    for I := P.FXs.Count - 1 downto 0 do
    begin
      if P.FXs[I] <> nil then
        for J := P.YFactorsList[I].Count - 1 downto 0 do
        begin
          BigNumberDirectMulMod(P.YFactorsList[I][J].Value, P.YFactorsList[I][J].Value, K, Prime);
          if B then
            BigNumberSub(P.YFactorsList[I][J].Value, Prime, P.YFactorsList[I][J].Value);
        end;
    end;
  finally
    FLocalBigNumberPool.Recycle(K);
    FLocalBigNumberPool.Recycle(T);
  end;
end;

{ TCnBigNumberBiPolynomial }

procedure TCnBigNumberBiPolynomial.Clear;
var
  I: Integer;
begin
//  if FXs.Count <= 0 then
//    FXs.Add(TCnSparseBigNumberList.Create)
//  else
    for I := FXs.Count - 1 downto 0 do
    begin
      FXs[I].Free;
      FXs.Delete(I);
    end;

//  YFactorsList[0].Clear;
end;

function TCnBigNumberBiPolynomial.CompactYDegree(
  YList: TCnSparseBigNumberList): Boolean;
begin
  if YList = nil then
    Result := True
  else
  begin
    YList.Compact;
    Result := YList.Count = 0;
  end;
end;

procedure TCnBigNumberBiPolynomial.CorrectTop;
var
  I: Integer;
  Compact, MeetNonEmpty: Boolean;
  YL: TCnSparseBigNumberList;
begin
  MeetNonEmpty := False;
  for I := FXs.Count - 1 downto 0 do
  begin
    YL := TCnSparseBigNumberList(FXs[I]);
    if YL = nil then
      Compact := True
    else
      Compact := CompactYDegree(YL);

    if not Compact then     // ����ѹ���� 0
      MeetNonEmpty := True;

    if Compact and not MeetNonEmpty then // ��ߵ�һ·����ѹ������ȫ 0 ��Ҫɾ��
    begin
      FXs.Delete(I);
      YL.Free;
    end
    else if Compact then // ��ͨ��ѹ����ȫ 0 �ģ���Ҫ�ͷ� SparseBigNumberList���� FXs �ﻹ��ռλ
    begin
      FXs[I] := nil;
      YL.Free;
    end;
  end;
end;

constructor TCnBigNumberBiPolynomial.Create(XDegree, YDegree: Integer);
begin
  FXs := TCnRefObjectList.Create;
  EnsureDegrees(XDegree, YDegree);
end;

destructor TCnBigNumberBiPolynomial.Destroy;
var
  I: Integer;
begin
  for I := FXs.Count - 1 downto 0 do
    FXs[I].Free;
  FXs.Free;
  inherited;
end;

procedure TCnBigNumberBiPolynomial.EnsureDegrees(XDegree,
  YDegree: Integer);
var
  I: Integer;
begin
  CheckDegree(XDegree);
  CheckDegree(YDegree);

  // OldCount := FXs.Count;
  if (XDegree + 1) > FXs.Count then
  begin
    for I := FXs.Count + 1 to XDegree + 1 do
    begin
      FXs.Add(nil);
      // TCnSparseBigNumberList(FXs[FXs.Count - 1]).Count := YDegree + 1;
    end;
  end;

//  for I:= OldCount - 1 downto 0 do
//    if TCnSparseBigNumberList(FXs[I]).Count < YDegree + 1 then
//      TCnSparseBigNumberList(FXs[I]).Count := YDegree + 1;
end;

function TCnBigNumberBiPolynomial.GetMaxXDegree: Integer;
begin
  Result := FXs.Count - 1;
end;

function TCnBigNumberBiPolynomial.GetMaxYDegree: Integer;
var
  I: Integer;
  Pair: TCnExponentBigNumberPair;
begin
  Result := 0;
  for I := FXs.Count - 1 downto 0 do
  begin
    if FXs[I] <> nil then
      if YFactorsList[I].Count > 0 then
      begin
        Pair := YFactorsList[I].Top;
        if Pair <> nil then
        begin
          if Pair.Exponent > Result then
          Result := Pair.Exponent;
        end;
      end;
  end;
end;

function TCnBigNumberBiPolynomial.GetReadonlyValue(XDegree,
  YDegree: Integer): TCnBigNumber;
var
  YL: TCnSparseBigNumberList;
begin
  Result := CnBigNumberZero;
  if (XDegree >= 0) and (XDegree < FXs.Count) then
  begin
    YL := TCnSparseBigNumberList(FXs[XDegree]);
    if YL <> nil then
      if (YDegree >= 0) and (YDegree < YL.Count) then
        Result := YL.ReadonlyValue[YDegree];
  end;
end;

function TCnBigNumberBiPolynomial.GetSafeValue(XDegree,
  YDegree: Integer): TCnBigNumber;
var
  YL: TCnSparseBigNumberList;
begin
  if XDegree > MaxXDegree then  
    MaxXDegree := XDegree;

  YL := YFactorsList[XDegree];  // ȷ�� XDegree ����
  Result := YL.SafeValue[YDegree];
end;

function TCnBigNumberBiPolynomial.GetYFactorsList(
  Index: Integer): TCnSparseBigNumberList;
begin
  if Index < 0 then
    raise ECnPolynomialException.CreateFmt(SCnInvalidDegree, [Index]);

  if Index >= FXs.Count then
    FXs.Count := Index + 1;

  Result := TCnSparseBigNumberList(FXs[Index]);
  if Result = nil then
  begin
    Result := TCnSparseBigNumberList.Create;
    FXs[Index] := Result;
  end;
end;

function TCnBigNumberBiPolynomial.IsMonicX: Boolean;
begin
  Result := BigNumberBiPolynomialIsMonicX(Self);
end;

function TCnBigNumberBiPolynomial.IsZero: Boolean;
begin
  Result := BigNumberBiPolynomialIsZero(Self);
end;

procedure TCnBigNumberBiPolynomial.Negate;
begin
  BignumberBiPolynomialNegate(Self);
end;

procedure TCnBigNumberBiPolynomial.SetMaxXDegree(const Value: Integer);
var
  I: Integer;
begin
  CheckDegree(Value);

  if Value + 1 > FXs.Count then
  begin
    FXs.Count := Value + 1; // ��Ԥ�ȴ���
//    for I := FXs.Count + 1 to Value + 1 do
//      FXs.Add(TCnSparseBigNumberList.Create);
  end
  else if Value + 1 < FXs.Count then
  begin
    for I := FXs.Count - 1 downto Value + 1 do
    begin
      FXs[I].Free;
      FXs.Delete(I);
    end;
  end;
end;

procedure TCnBigNumberBiPolynomial.SetMaxYDegree(const Value: Integer);
begin
  // Not Needed
end;

procedure TCnBigNumberBiPolynomial.SetOne;
begin
  BigNumberBiPolynomialSetOne(Self);
end;

procedure TCnBigNumberBiPolynomial.SetSafeValue(XDegree, YDegree: Integer;
  const Value: TCnBigNumber);
var
  YL: TCnSparseBigNumberList;
begin
  if XDegree > MaxXDegree then  
    MaxXDegree := XDegree;

  YL := YFactorsList[XDegree];    // ȷ�� XDegree ����
  YL.SafeValue[YDegree] := Value; // �ڲ� Copy ����
end;

procedure TCnBigNumberBiPolynomial.SetString(const Poly: string);
begin
  BigNumberBiPolynomialSetString(Self, Poly);
end;

procedure TCnBigNumberBiPolynomial.SetXCoefficents(YDegree: Integer;
  LowToHighXCoefficients: array of const);
var
  I: Integer;
  S: string;
begin
  CheckDegree(YDegree);

  MaxXDegree := High(LowToHighXCoefficients);

  if YDegree > MaxYDegree then
    MaxYDegree := YDegree;

  for I := Low(LowToHighXCoefficients) to High(LowToHighXCoefficients) do
  begin
    S := ExtractBigNumberFromArrayConstElement(LowToHighXCoefficients[I]);
    if S <> '' then
      SafeValue[I, YDegree].SetDec(ExtractBigNumberFromArrayConstElement(LowToHighXCoefficients[I]))
  end;
end;

procedure TCnBigNumberBiPolynomial.SetXYCoefficent(XDegree,
  YDegree: Integer; ACoefficient: TCnBigNumber);
begin
  CheckDegree(XDegree);
  CheckDegree(YDegree);

  if MaxXDegree < XDegree then
    MaxXDegree := XDegree;

  YFactorsList[XDegree].SafeValue[YDegree] := ACoefficient; // �ڲ��� BigNumberCopy ֵ
end;

procedure TCnBigNumberBiPolynomial.SetYCoefficents(XDegree: Integer;
  LowToHighYCoefficients: array of const);
var
  I: Integer;
begin
  CheckDegree(XDegree);

  if XDegree > MaxXDegree then
    MaxXDegree := XDegree;

  YFactorsList[XDegree].Clear;
  for I := Low(LowToHighYCoefficients) to High(LowToHighYCoefficients) do
    YFactorsList[XDegree].SafeValue[I].SetDec(ExtractBigNumberFromArrayConstElement(LowToHighYCoefficients[I]));
end;

procedure TCnBigNumberBiPolynomial.SetYCoefficentsFromPolynomial(
  XDegree: Integer; PY: TCnInt64Polynomial);
var
  I: Integer;
begin
  CheckDegree(XDegree);

  if XDegree > MaxXDegree then   
    MaxXDegree := XDegree;

  if PY.IsZero then
  begin
    FXs[XDegree].Free;
    FXs[XDegree] := nil;
  end
  else
  begin
    YFactorsList[XDegree].Clear; // ȷ�� X ����� List ����
    for I := 0 to PY.MaxDegree do
      YFactorsList[XDegree].SafeValue[I].SetInt64(PY[I]);
  end;
end;

procedure TCnBigNumberBiPolynomial.SetYCoefficentsFromPolynomial(
  XDegree: Integer; PY: TCnBigNumberPolynomial);
var
  I: Integer;
begin
  CheckDegree(XDegree);

  if XDegree > MaxXDegree then   
    MaxXDegree := XDegree;

  if PY.IsZero then
  begin
    FXs[XDegree].Free;
    FXs[XDegree] := nil;
  end
  else
  begin
    YFactorsList[XDegree].Clear;   // ȷ�� X ����� List ����
    for I := 0 to PY.MaxDegree do
      YFactorsList[XDegree].SafeValue[I] := PY[I];
  end;
end;

procedure TCnBigNumberBiPolynomial.SetZero;
begin
  BigNumberBiPolynomialSetZero(Self);
end;

function TCnBigNumberBiPolynomial.ToString: string;
begin
  Result := BigNumberBiPolynomialToString(Self);
end;

procedure TCnBigNumberBiPolynomial.Transpose;
begin
  BigNumberBiPolynomialTranspose(Self, Self);
end;

{ TCnBigNumberBiPolynomialPool }

function TCnBigNumberBiPolynomialPool.CreateObject: TObject;
begin
  Result := TCnBigNumberBiPolynomial.Create;
end;

function TCnBigNumberBiPolynomialPool.Obtain: TCnBigNumberBiPolynomial;
begin
  Result := TCnBigNumberBiPolynomial(inherited Obtain);
  Result.SetZero;
end;

procedure TCnBigNumberBiPolynomialPool.Recycle(
  Poly: TCnBigNumberBiPolynomial);
begin
  inherited Recycle(Poly);
end;

initialization
  FLocalInt64PolynomialPool := TCnInt64PolynomialPool.Create;
  FLocalInt64RationalPolynomialPool := TCnInt64RationalPolynomialPool.Create;
  FLocalBigNumberPolynomialPool := TCnBigNumberPolynomialPool.Create;
  FLocalBigNumberRationalPolynomialPool := TCnBigNumberRationalPolynomialPool.Create;
  FLocalBigNumberPool := TCnBigNumberPool.Create;
  FLocalInt64BiPolynomialPool := TCnInt64BiPolynomialPool.Create;
  FLocalBigNumberBiPolynomialPool := TCnBigNumberBiPolynomialPool.Create;

  CnInt64PolynomialOne := TCnInt64Polynomial.Create([1]);
  CnInt64PolynomialZero := TCnInt64Polynomial.Create([0]);

  CnBigNumberPolynomialOne := TCnBigNumberPolynomial.Create([1]);
  CnBigNumberPolynomialZero := TCnBigNumberPolynomial.Create([0]);

finalization
  // CnInt64PolynomialOne.ToString; // �ֹ����÷�ֹ������������

  CnBigNumberPolynomialOne.Free;
  CnBigNumberPolynomialZero.Free;

  CnInt64PolynomialOne.Free;
  CnInt64PolynomialZero.Free;

  FLocalBigNumberBiPolynomialPool.Free;
  FLocalInt64BiPolynomialPool.Free;
  FLocalInt64PolynomialPool.Free;
  FLocalInt64RationalPolynomialPool.Free;
  FLocalBigNumberPolynomialPool.Free;
  FLocalBigNumberRationalPolynomialPool.Free;
  FLocalBigNumberPool.Free;

end.
