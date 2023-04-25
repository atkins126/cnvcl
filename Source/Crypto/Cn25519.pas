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

unit Cn25519;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�25519 ϵ����Բ�����㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��Ŀǰʵ���� Montgomery ��Բ���� y^2 = x^3 + A*X^2 + x
*           �Լ�Ť�� Edwards ��Բ���� au^2 + v^2 = 1 + d * u^2 * v^2 �ĵ�Ӽ���
*           ��ʵ�ֽ����� X �Լ��ɸ��������ݵĿ��ٱ������Լ���չ��Ԫ����Ŀ��ٵ��
*           �Լ���϶���ʽԼ������ģ���������еļ����㷨����ԭʼ����㷨�ٶȵ���ʮ������
*           ǩ������ rfc 8032 ��˵��
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2022.07.30 V1.5
*               ȥ���������õ��ж��Ծ������
*           2022.06.14 V1.4
*               ʵ�� Ed25519 ���ļ���ǩ������֤
*           2022.06.12 V1.3
*               ʵ�� Field64 ����ʽ���������������㷨��
*               �����ڴ˸����ɸ��������ݼ��ٱ���������չ��Ԫ����Ŀ��ٵ��������ˣ�
*               �ٶ��ٴ����һ�����ϣ���� 64 λ�£����ܶ����ٴ����һ��
*           2022.06.09 V1.2
*               ʵ�� Curve25519 ���ߵ��ɸ��������ݼ��ٱ����ˣ��ٶȽ�ԭʼ�˷���ʮ������
*           2022.06.08 V1.1
*               ʵ�� Ed25519 ǩ������֤
*           2022.06.07 V1.1
*               ʵ�� Ed25519 ��չ��Ԫ����Ŀ��ٵ��������ˣ��ٶȽ�ԭʼ�����˷���ʮ������
*           2022.06.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnNative, CnBigNumber, CnInt128, CnECC, CnSHA2;

const
  CN_25519_BLOCK_BYTESIZE = 32;
  {* 25519 ��������㷨�����ݿ��С}

type
  TCn25519Field64 = array[0..4] of TUInt64;
  {* �ö���ʽ�����ʾһ�� 2^255-19 ��Χ�ڵ�������Ԫ�أ�f0 + 2*51*f1 + 2^102*f2 + 2^153*f3 + 2^204*f4}

  TCn25519Field64EccPoint = packed record
  {* �ö���ʽ�����ʾ�� 25519 ��Բ�����ϵĵ㣨������ X ��Ӱ�㣬Z �� Y ���棩
    �������ټ��㣬���������������Բ����}
    X: TCn25519Field64;
    Y: TCn25519Field64;
  end;

  TCn25519Field64Ecc4Point = packed record
  {* �ö���ʽ�����ʾ�� 25519 ��Բ�����ϵ���Ԫ��չ��
    �������ټ��㣬���������������Բ����}
    X: TCn25519Field64;
    Y: TCn25519Field64;
    Z: TCn25519Field64;
    T: TCn25519Field64;
  end;

  TCnEcc4Point = class(TCnEcc3Point)
  {* ��չ����Ӱ/����/�ſɱ�����㣬������ T ���ڼ�¼�м���
     ������ x = X/Z  y = Y/Z  x*y = T/Z�����Ե��� ��0, 1, 1, 0��}
  private
    FT: TCnBigNumber;
    procedure SetT(const Value: TCnBigNumber);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function ToString: string; override; // ������ ToString

    property T: TCnBigNumber read FT write SetT;
    {* �м��� T}
  end;

  TCnTwistedEdwardsCurve = class
  {* �������ϵ�Ť�����»����� au^2 + v^2 = 1 + du^2v^2 (���� u v ���ɸ��������ߵ� x y ��ӳ���ϵ)}
  private
    FCoefficientA: TCnBigNumber;
    FCoefficientD: TCnBigNumber;
    FOrder: TCnBigNumber;
    FFiniteFieldSize: TCnBigNumber;
    FGenerator: TCnEccPoint;
    FCoFactor: Integer;
  public
    constructor Create; overload; virtual;
    {* ��ͨ���캯����δ��ʼ������}
    constructor Create(const A, D, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); overload;
    {* ���캯�������뷽�̵� A, D �������������Ͻ� p��G �����ꡢG ��Ľ�������Ҫʮ�������ַ���}

    destructor Destroy; override;
    {* ��������}

    procedure Load(const A, D, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); virtual;
    {* �������߲�����ע���ַ���������ʮ�����Ƹ�ʽ}

    procedure MultiplePoint(K: Int64; Point: TCnEccPoint); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); overload; virtual;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P���ڲ�ʵ�ֵ�ͬ�� CnECC ��ͬ������}

    procedure PointAddPoint(P, Q, Sum: TCnEccPoint);
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ
      �˴��ļӷ��ļ��������൱�ڵ�λԲ�ϵ����� Y ��ļнǽǶ���ӷ���
      ���Ե�(0, 1)����ͬ�� Weierstrass �����е�����Զ��}
    procedure PointSubPoint(P, Q, Diff: TCnEccPoint);
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(P: TCnEccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P��Ҳ���� X ֵȡ��}
    function IsPointOnCurve(P: TCnEccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    function IsNeutualPoint(P: TCnEccPoint): Boolean;
    {* �жϵ��Ƿ������Ե㣬Ҳ�����ж� X = 0 �� Y = 1���� Weierstrass ������Զ��ȫ 0 ��ͬ}
    procedure SetNeutualPoint(P: TCnEccPoint);
    {* ������Ϊ���Ե㣬Ҳ���� X := 0 �� Y := 1}

    property Generator: TCnEccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: TCnBigNumber read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientD: TCnBigNumber read FCoefficientD;
    {* ����ϵ�� B}
    property FiniteFieldSize: TCnBigNumber read FFiniteFieldSize;
    {* ��������Ͻ磬���� p}
    property Order: TCnBigNumber read FOrder;
    {* ����Ľ��� N��ע����ֻ�� H Ϊ 1 ʱ�ŵ��ڱ����ߵ��ܵ���}
    property CoFactor: Integer read FCoFactor;
    {* �������� H��Ҳ�����ܵ��� = N * H������ Integer ��ʾ}
  end;

  TCnMontgomeryCurve = class
  {* �������ϵ��ɸ��������� By^2 = x^3 + Ax^2 + x������ B*(A^2 - 4) <> 0}
  private
    FCoefficientB: TCnBigNumber;
    FCoefficientA: TCnBigNumber;
    FOrder: TCnBigNumber;
    FFiniteFieldSize: TCnBigNumber;
    FGenerator: TCnEccPoint;
    FCoFactor: Integer;
    FLadderConst: TCnBigNumber;
    FLadderField64: TCn25519Field64;
    procedure CheckLadderConst;
  public
    constructor Create; overload; virtual;
    {* ��ͨ���캯����δ��ʼ������}
    constructor Create(const A, B, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); overload;
    {* ���캯�������뷽�̵� A, B �������������Ͻ� p��G �����ꡢG ��Ľ�������Ҫʮ�������ַ���}

    destructor Destroy; override;
    {* ��������}

    procedure Load(const A, B, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); virtual;
    {* �������߲�����ע���ַ���������ʮ�����Ƹ�ʽ}

    procedure GenerateKeys(PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey); virtual;
    {* ����һ�Ը���Բ���ߵĹ�˽Կ��˽Կ��������� k����Կ�ǻ��� G ���� k �γ˷���õ��ĵ����� K}

    procedure MultiplePoint(K: Int64; Point: TCnEccPoint); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� Point}
    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); overload; virtual;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� Point���ڲ�ʵ�ֵ�ͬ�� CnECC ��ͬ������}

    procedure PointAddPoint(P, Q, Sum: TCnEccPoint);
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ
      �˴��ļӷ��ļ������������� Weierstrass ��Բ�����ϵ����߻����߽�����ȡ����ͬ����������Զ��(0, 0)}
    procedure PointSubPoint(P, Q, Diff: TCnEccPoint);
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(P: TCnEccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P��Ҳ���� Y ֵȡ��}
    function IsPointOnCurve(P: TCnEccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    // ============ �ɸ����������㷨�еĽ� X ����Ӱ���������㷨 ==============

    procedure PointToXAffinePoint(DestPoint, SourcePoint: TCnEccPoint);
    {* ������ X Y ����Բ���ߵ�ת��Ϊ��Ӱ���� X Y Z ��ֻ���� X Z ���ɸ����������㷨ʹ�ã�
      ��ʵ���� Y �� 1��SourcePoint �� DestPoint ������ͬ}
    procedure XAffinePointToPoint(DestPoint, SourcePoint: TCnEccPoint);
    {* ��ֻ�� X Z(Y ���� Z) ����Ӱ�����ת��Ϊ��ͨ���ߵ㣬��ʵ������� Y ���滻 Z��
      SourcePoint �� DestPoint ������ͬ}

    procedure XAffinePointInverse(P: TCnEccPoint);
    {* ����� X ����Ӱ����� P �����Ԫ -P��ֵ���·��� P��Ҳ���� Y ֵȡ��
      ʵ���ڲ���Ϊû�� Y��ɶ��������}

    procedure MontgomeryLadderPointXDouble(Dbl: TCnEccPoint; P: TCnEccPoint);
    {* �ɸ����������㷨�еĽ� X ����Ӱ�����Ķ��������㣬Y �ڲ��� Z �ã�Dbl ������ P}
    procedure MontgomeryLadderPointXAdd(Sum, P, Q, PMinusQ: TCnEccPoint);
    {* �ɸ����������㷨�еĽ� X ����Ӱ�����ĵ�����㣬Y �ڲ��� Z �ã�������Ҫ������ֵ�⻹��Ҫһ�����ֵ}

    procedure MontgomeryLadderMultiplePoint(K: Int64; Point: TCnEccPoint); overload;
    {* ���ɸ����������㷨����� X ����Ӱ������ K ���㣬ֵ���·��� Point}
    procedure MontgomeryLadderMultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); overload;
    {* ���ɸ����������㷨����� X ����Ӱ������ K ���㣬ֵ���·��� Point}

    // ======= �ɸ����������㷨�еĽ� X ����Ӱ����� 2^51 ����ʽ�����㷨 =======

    procedure PointToField64XAffinePoint(var DestPoint: TCn25519Field64EccPoint; SourcePoint: TCnEccPoint);
    {* ������ X Y ����Բ���ߵ�ת��Ϊ��Ӱ���� X Y Z ��ֻ���� X Z ��ת��Ϊ����ʽ�㣬���ɸ����������㷨ʹ��}
    procedure Field64XAffinePointToPoint(DestPoint: TCnEccPoint; var SourcePoint: TCn25519Field64EccPoint);
    {* ������ʽ��ʽ��ֻ�� X Z(Y ���� Z) ����Ӱ�����ת��Ϊ��ͨ���ߵ�}

    procedure MontgomeryLadderField64PointXDouble(var Dbl: TCn25519Field64EccPoint; var P: TCn25519Field64EccPoint);
    {* ����ʽ��ʽ���ɸ����������㷨�еĽ� X ����Ӱ�����Ķ��������㣬Y �ڲ��� Z �ã�Dbl ������ P}
    procedure MontgomeryLadderField64PointXAdd(var Sum, P, Q, PMinusQ: TCn25519Field64EccPoint);
    {* ����ʽ��ʽ���ɸ����������㷨�еĽ� X ����Ӱ�����ĵ�����㣬Y �ڲ��� Z �ã�������Ҫ������ֵ�⻹��Ҫһ�����ֵ}

    procedure MontgomeryLadderField64MultiplePoint(K: Int64; var Point: TCn25519Field64EccPoint); overload;
    {* �ö���ʽ��ʽ���ɸ����������㷨����� X ����Ӱ������ K ���㣬ֵ���·��� Point}
    procedure MontgomeryLadderField64MultiplePoint(K: TCnBigNumber; var Point: TCn25519Field64EccPoint); overload;
    {* �ö���ʽ��ʽ���ɸ����������㷨����� X ����Ӱ������ K ���㣬ֵ���·��� Point}

    property Generator: TCnEccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: TCnBigNumber read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientB: TCnBigNumber read FCoefficientB;
    {* ����ϵ�� B}
    property FiniteFieldSize: TCnBigNumber read FFiniteFieldSize;
    {* ��������Ͻ磬���� p}
    property Order: TCnBigNumber read FOrder;
    {* ����Ľ��� N��ע����ֻ�� H Ϊ 1 ʱ�ŵ��ڱ����ߵ��ܵ���}
    property CoFactor: Integer read FCoFactor;
    {* �������� H��Ҳ�����ܵ��� = N * H������ Integer ��ʾ}
  end;

  TCnCurve25519 = class(TCnMontgomeryCurve)
  {* rfc 7748/8032 �й涨�� Curve25519 ����}
  public
    constructor Create; override;

    procedure GenerateKeys(PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey); override;
    {* ����һ�� Curve25519 ��Բ���ߵĹ�˽Կ������˽Կ�ĸߵ�λ�����⴦��}

    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); override;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� Point���ڲ�ʵ��ʹ�� 64 λ����ʽ������ɸ����������㷨}
  end;

  TCnEd25519Data = array[0..CN_25519_BLOCK_BYTESIZE - 1] of Byte;

  TCnEd25519SignatureData = array[0..2 * CN_25519_BLOCK_BYTESIZE - 1] of Byte;

  TCnEd25519 = class(TCnTwistedEdwardsCurve)
  {* rfc 7748/8032 �й涨�� Ed25519 ����}
  public
    constructor Create; override;

    function GenerateKeys(PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey): Boolean;
    {* ����һ�� Ed25519 ��Բ���ߵĹ�˽Կ�����й�Կ�Ļ���������� SHA512 �������}

    procedure PlainToPoint(Plain: TCnEd25519Data; OutPoint: TCnEccPoint);
    {* �� 32 �ֽ�ֵת��Ϊ����㣬�漰�����}
    procedure PointToPlain(Point: TCnEccPoint; var OutPlain: TCnEd25519Data);
    {* ��������ת���� 32 �ֽ�ֵ��ƴ Y ���� X ����һλ}

    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); override;
    {* ���ظ������ͨ��ˣ��ڲ�������չ��Ԫ���ٳ�}

    function IsNeutualExtendedPoint(P: TCnEcc4Point): Boolean;
    {* �жϵ��Ƿ������Ե㣬Ҳ�����ж� X = 0 �� Y = Z <> 0 �� T = 0���� Weierstrass ������Զ��ȫ 0 ��ͬ}
    procedure SetNeutualExtendedPoint(P: TCnEcc4Point);
    {* ������Ϊ���Ե㣬Ҳ���� X := 0 �� Y := 1 �� Z := 1 �� T := 0}

    // ================= ��չŤ�����»����꣨��Ԫ��������㷨 ==================

    procedure ExtendedPointAddPoint(P, Q, Sum: TCnEcc4Point);
    {* ʹ����չŤ�����»����꣨��Ԫ���Ŀ��ٵ�ӷ����� P + Q��ֵ���� Sum �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure ExtendedPointSubPoint(P, Q, Diff: TCnEcc4Point);
    {* ʹ����չŤ�����»����꣨��Ԫ������ P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure ExtendedPointInverse(P: TCnEcc4Point);
    {* ʹ����չŤ�����»����꣨��Ԫ������ P �����Ԫ -P��ֵ���·��� P��Ҳ���� Y ֵȡ��}
    function IsExtendedPointOnCurve(P: TCnEcc4Point): Boolean;
    {* �ж���չŤ�����»����꣨��Ԫ�� P ���Ƿ��ڱ�������}

    procedure ExtendedMultiplePoint(K: Int64; Point: TCnEcc4Point); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure ExtendedMultiplePoint(K: TCnBigNumber; Point: TCnEcc4Point); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P���ٶȱ���ͨ�����˿�ʮ������}

    // ============= ��չŤ�����»����꣨��Ԫ����Ķ���ʽ�����㷨 ==============

    function ExtendedField64PointAddPoint(var P, Q, Sum: TCn25519Field64Ecc4Point): Boolean;
    {* ʹ����չŤ�����»����꣨��Ԫ�����������ʽ�Ŀ��ٵ�ӷ����� P + Q��ֵ���� Sum �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    function ExtendedField64PointSubPoint(var P, Q, Diff: TCn25519Field64Ecc4Point): Boolean;
    {* ʹ����չŤ�����»����꣨��Ԫ�����������ʽ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure ExtendedField64PointInverse(var P: TCn25519Field64Ecc4Point);
    {* ʹ����չŤ�����»����꣨��Ԫ�����������ʽ���� P �����Ԫ -P��ֵ���·��� P��Ҳ���� Y ֵȡ��}
    function IsExtendedField64PointOnCurve(var P: TCn25519Field64Ecc4Point): Boolean;
    {* �ж���չŤ�����»����꣨��Ԫ�����������ʽ P ���Ƿ��ڱ�������}

    procedure ExtendedField64MultiplePoint(K: Int64; var Point: TCn25519Field64Ecc4Point); overload;
    {* ʹ����չŤ�����»����꣨��Ԫ�����������ʽ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure ExtendedField64MultiplePoint(K: TCnBigNumber; var Point: TCn25519Field64Ecc4Point); overload;
    {* ʹ����չŤ�����»����꣨��Ԫ�����������ʽ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
  end;

  TCnEd25519Signature = class(TPersistent)
  {* Ed25519 ��ǩ������һ������һ���������� TCnEccSignature ��ͬ}
  private
    FR: TCnEccPoint;
    FS: TCnBigNumber;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure SaveToData(var Sig: TCnEd25519SignatureData);
    {* ����ת���� 64 �ֽ�ǩ�����鹩�洢�봫��}

    procedure LoadFromData(Sig: TCnEd25519SignatureData);
    {* ��64 �ֽ�ǩ�������м���ǩ��}

    property R: TCnEccPoint read FR;
    {* ǩ���� R}
    property S: TCnBigNumber read FS;
    {* ǩ���� S}
  end;

function CnEcc4PointToString(const P: TCnEcc4Point): string;
{* ��һ�� TCnEcc4Point ������ת��Ϊʮ�����ַ���}

function CnEcc4PointToHex(const P: TCnEcc4Point): string;
{* ��һ�� TCnEcc4Point ������ת��Ϊʮ�������ַ���}

function CnEcc4PointEqual(const P, Q: TCnEcc4Point; Prime: TCnBigNumber): Boolean;
{* �ж����� TCnEcc4Point �Ƿ�ͬһ����}

function CnEccPointToEcc4Point(DestPoint: TCnEcc4Point; SourcePoint: TCnEccPoint;
  Prime: TCnBigNumber): Boolean;
{* ������Χ�ڵ���ͨ���굽��չ��������ĵ�ת��}

function CnEcc4PointToEccPoint(DestPoint: TCnEccPoint; SourcePoint: TCnEcc4Point;
  Prime: TCnBigNumber): Boolean;
{* ������Χ�ڵ���չ�������굽��ͨ����ĵ�ת��}

procedure CnCurve25519PointToEd25519Point(DestPoint, SourcePoint: TCnEccPoint);
{* �� Curve25519 �������ת��Ϊ Ed25519 ������㣬Source �� Dest ������ͬ}

procedure CnEd25519PointToCurve25519Point(DestPoint, SourcePoint: TCnEccPoint);
{* �� Ed25519 �������ת��Ϊ Curve25519 ������㣬Source �� Dest ������ͬ}

procedure CnEd25519PointToData(P: TCnEccPoint; var Data: TCnEd25519Data);
{* �� 25519 ��׼����Բ���ߵ�ת��Ϊѹ����ʽ�� 32 �ֽ�����}

procedure CnEd25519DataToPoint(Data: TCnEd25519Data; P: TCnEccPoint; out XOdd: Boolean);
{* �� 25519 ��׼�� 32 �ֽ�����ת��Ϊ��Բ���ߵ�ѹ����ʽ
  P �з��ض�Ӧ Y ֵ���Լ� XOdd �з��ض�Ӧ�� X ֵ�Ƿ�����������Ҫ������н� X}

procedure CnEd25519BigNumberToData(N: TCnBigNumber; var Data: TCnEd25519Data);
{* �� 25519 ��׼������ת��Ϊ 32 �ֽ����飬����ת���Ƿ�ɹ�}

procedure CnEd25519DataToBigNumber(Data: TCnEd25519Data; N: TCnBigNumber);
{* �� 25519 ��׼�� 32 �ֽ�����ת��Ϊ����������ת���Ƿ�ɹ�}

// ===================== Ed25519 ��Բ��������ǩ����֤�㷨 ======================

function CnEd25519SignData(PlainData: Pointer; DataLen: Integer; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; OutSignature: TCnEd25519Signature; Ed25519: TCnEd25519 = nil): Boolean;
{* Ed25519 �ù�˽Կ�����ݿ����ǩ��������ǩ���Ƿ�ɹ�}

function CnEd25519VerifyData(PlainData: Pointer; DataLen: Integer; InSignature: TCnEd25519Signature;
  PublicKey: TCnEccPublicKey; Ed25519: TCnEd25519 = nil): Boolean;
{* Ed25519 �ù�Կ�����ݿ���ǩ��������֤��������֤�Ƿ�ɹ�}

function CnEd25519SignFile(const FileName: string; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; OutSignatureStream: TStream; Ed25519: TCnEd25519 = nil): Boolean;
{* Ed25519 �ù�˽Կ���ļ�����ǩ����ǩ��ֵ 64 �ֽ�д�� OutSignatureStream �У�����ǩ���Ƿ�ɹ�}

function CnEd25519VerifyFile(const FileName: string; InSignatureStream: TStream;
  PublicKey: TCnEccPublicKey; Ed25519: TCnEd25519 = nil): Boolean;
{* Ed25519 �ù�Կ���ļ���ǩ��������֤��InSignatureStream �ڲ����� 64 �ֽ�ǩ��ֵ��������֤�Ƿ�ɹ�}

// ================= Ed25519 ��Բ���� Diffie-Hellman ��Կ����  =================

function CnCurve25519KeyExchangeStep1(SelfPrivateKey: TCnEccPrivateKey;
  OutPointToAnother: TCnEccPoint; Curve25519: TCnCurve25519 = nil): Boolean;
{* ���� 25519 �� Diffie-Hellman ��Կ�����㷨��A �� B ���ȵ��ô˷�����
  ���ݸ���˽Կ���ɵ����꣬�õ������跢���Է������������Ƿ�ɹ�}

function CnCurve25519KeyExchangeStep2(SelfPrivateKey: TCnEccPrivateKey;
  InPointFromAnother: TCnEccPoint; OutKey: TCnEccPoint; Curve25519: TCnCurve25519 = nil): Boolean;
{* ���� 25519 �� Diffie-Hellman ��Կ�����㷨��A �� B �յ��Է��� Point ������ٵ��ô˷�����
  ���ݸ���˽Կ����һ��ͬ�ĵ����꣬�õ������Ϊ������Կ������ͨ��������һ�����ӻ���
  ���������Ƿ�ɹ�}

// ============================== ����ʽ�����㷨 ===============================

procedure Cn25519BigNumberToField64(var Field: TCn25519Field64; const Num: TCnBigNumber);
{* ��һ������ת��Ϊ 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ��}

procedure Cn25519Field64ToBigNumber(const Res: TCnBigNumber; var Field: TCn25519Field64);
{* ��һ������ת��Ϊ 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ��}

procedure Cn25519Field64Reduce(var Field: TCn25519Field64);
{* ��һ�� 64 λ����ʽϵ���� 2^255-19 ������Χ�����滯��
  Ҳ���ǰ�ÿ��ϵ��ȷ���� 2^51 С����Ĳ��ֽ�λ����һ������ֵ�糬���������Ͻ�Ҳ���Զ���ģ}

function Cn25519Field64ToHex(var Field: TCn25519Field64): string;
{* ��һ�� 64 λ����ʽϵ��ת��Ϊʮ�������ַ���}

procedure Cn25519Field64Copy(var Dest, Source: TCn25519Field64);
{* ����һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ��}

function Cn25519Field64Equal(var A, B: TCn25519Field64): Boolean;
{* �ж����� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ���Ƿ����}

procedure Cn25519Field64Swap(var A, B: TCn25519Field64);
{* �������� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ��}

procedure Cn25519Field64Zero(var Field: TCn25519Field64);
{* ��һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ����Ϊ 0}

procedure Cn25519Field64One(var Field: TCn25519Field64);
{* ��һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ����Ϊ 1}

procedure Cn25519Field64NegOne(var Field: TCn25519Field64);
{* ��һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ����Ϊ -1}

procedure Cn25519Field64Negate(var Field: TCn25519Field64);
{* ��һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ����Ϊ�෴��}

procedure Cn25519Field64Add(var Res, A, B: TCn25519Field64);
{* ���� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ����ӣ�A + B => Res��Res ������ A �� B��A��B ������ͬһ��}

procedure Cn25519Field64Sub(var Res, A, B: TCn25519Field64);
{* ���� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ�������A - B => Res��Res ������ A �� B��A��B ������ͬһ��}

procedure Cn25519Field64Mul(var Res, A, B: TCn25519Field64);
{* ���� 2^255-19 ������Χ�ڵ� 64 λ����ʽϵ����ˣ�A * B => Res��Res ������ A �� B��A��B ������ͬһ��}

procedure Cn25519Field64Power(var Res, A: TCn25519Field64; K: Cardinal); overload;
{* ����һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽ�� K �η�ֵ��A^K) => Res��Res ������ A}

procedure Cn25519Field64Power(var Res, A: TCn25519Field64; K: TCnBigNumber); overload;
{* ����һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽ�� K �η�ֵ��A^K) => Res��Res ������ A}

procedure Cn25519Field64Power2K(var Res, A: TCn25519Field64; K: Cardinal);
{* ����һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽ�� 2^K �η�ֵ��A^(2^K) => Res��Res ������ A}

procedure Cn25519Field64ModularInverse(var Res, A: TCn25519Field64);
{* ����һ�� 2^255-19 ������Χ�ڵ� 64 λ����ʽ��ģ��Ԫ��A * Res mod P = 1��Res ������ A}

// =========================== ����ʽ�㴦���� ================================

procedure Cn25519Field64EccPointZero(var Point: TCn25519Field64EccPoint);
{* ��һ����ʽ�����ʾ�� 25519 ��Բ�����ϵĵ��� 0}

procedure Cn25519Field64EccPointCopy(var DestPoint, SourcePoint: TCn25519Field64EccPoint);
{* ���ƶ���ʽ�����ʾ�� 25519 ��Բ�����ϵĵ�}

function Cn25519Field64EccPointToHex(var Point: TCn25519Field64EccPoint): string;
{* ��һ����ʽ�����ʾ�� 25519 ��Բ�����ϵĵ�ת��Ϊʮ�������ַ���}

function Cn25519Field64EccPointEqual(var A, B: TCn25519Field64EccPoint): Boolean;
{* �ж���������ʽ�����ʾ�� 25519 ��Բ�����ϵĵ��Ƿ����}

procedure Cn25519Field64Ecc4PointNeutual(var Point: TCn25519Field64Ecc4Point);
{* ��һ����ʽ�����ʾ�� 25519 ��Բ�����ϵ���Ԫ��չ����Ϊ���Ե�}

procedure Cn25519Field64Ecc4PointCopy(var DestPoint, SourcePoint: TCn25519Field64Ecc4Point);
{* ���ƶ���ʽ�����ʾ�� 25519 ��Բ�����ϵ���Ԫ��չ��}

function Cn25519Field64Ecc4PointToHex(var Point: TCn25519Field64Ecc4Point): string;
{* ��һ����ʽ�����ʾ�� 25519 ��Բ�����ϵ���Ԫ��չ��ת��Ϊʮ�������ַ���}

function Cn25519Field64Ecc4PointEqual(var A, B: TCn25519Field64Ecc4Point): Boolean;
{* �ж���������ʽ�����ʾ�� 25519 ��Բ�����ϵĵ��Ƿ����}

function CnEccPointToField64Ecc4Point(var DestPoint: TCn25519Field64Ecc4Point;
  SourcePoint: TCnEccPoint): Boolean;
{* ������Χ�ڵ���ͨ���굽��չ�������ʽ����ĵ�ת��}

function CnField64Ecc4PointToEccPoint(DestPoint: TCnEccPoint;
  var SourcePoint: TCn25519Field64Ecc4Point): Boolean;
{* ������Χ�ڵ���չ�������ʽ���굽��ͨ����ĵ�ת��}

function CnEcc4PointToField64Ecc4Point(var DestPoint: TCn25519Field64Ecc4Point;
  SourcePoint: TCnEcc4Point): Boolean;
{* ������Χ�ڵ���չ�������굽��չ�������ʽ����ĵ�ת��}

function CnField64Ecc4PointToEcc4Point(DestPoint: TCnEcc4Point;
  var SourcePoint: TCn25519Field64Ecc4Point): Boolean;
{* ������Χ�ڵ���չ�������ʽ���굽��չ��������ĵ�ת��}

implementation

resourcestring
  SCnEInverseError = 'Point Inverse Error.';
  SCnECanNOTCalcErrorFmt = 'Can NOT Calucate %s,%s + %s,%s';

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

  // 25519 �ɸ��������߲���
  SCN_25519_MONT_A = '076D06';
  // 486662

  SCN_25519_MONT_B = '01';
  // 1

  SCN_25519_MONT_GX = '09';
  // 9
  SCN_25519_MONT_GY = '20AE19A1B8A086B4E01EDD2C7748D14C923D4D7E6D7C61B229E9C5A27ECED3D9';
  // ���� RFC �е� y = 14781619447589544791020593568409986887264606134616475288964881837755586237401�����ƺ����� 4/5��Ҳ���� 5 * Y mod P = 4
  // ������ 5F51E65E475F794B1FE122D388B72EB36DC2B28192839E4DD6163A5D81312C14 �ŷ��� 4/5 ���Һ� Ed25519 �� GY ��Ӧ

  SCN_25519_SQRT_NEG_486664 = '0F26EDF460A006BBD27B08DC03FC4F7EC5A1D3D14B7D1A82CC6E04AAFF457E06';
  // ��ǰ��õ� sqrt(-486664)����������ת������

  SCN_LOW51_MASK = $7FFFFFFFFFFFF;

// =============================================================================
// �ɸ��������� By^2 = x^3 + Ax^2 + x ��Ť�����»����� au^2 + v^2 = 1 + du^2v^2
// �����еȼ۵�һһӳ���ϵ������ A = 2(a+d)/(a-d) ������֤�� �� B = 4 /(a-d)
// �� Curve25519 ������ Ed25519 �����־����˲���������B = 4 /(a-d) ������
// ͬ����(x, y) �� (u, v) �Ķ�Ӧ��ϵҲ��Ϊ A B a d ��ϵ�ĵ������������׼ӳ��
// =============================================================================

var
  F25519BigNumberPool: TCnBigNumberPool = nil;
  FPrime25519: TCnBigNumber = nil;

  // ����
  F25519Field64Zero: TCn25519Field64 = (0, 0, 0, 0, 0);
  F25519Field64One: TCn25519Field64 = (1, 0, 0, 0, 0);
  F25519Field64NegOne: TCn25519Field64 = (2251799813685228, 2251799813685247, 2251799813685247, 2251799813685247, 2251799813685247);

procedure ConditionalSwapPoint(Swap: Boolean; A, B: TCnEccPoint);
begin
  if Swap then
  begin
    BigNumberSwap(A.X, B.X);
    BigNumberSwap(A.Y, B.Y);
  end;
end;

procedure ConditionalSwapField64Point(Swap: Boolean; var A, B: TCn25519Field64EccPoint);
begin
  if Swap then
  begin
    Cn25519Field64Swap(A.X, B.X);
    Cn25519Field64Swap(A.Y, B.Y);
  end;
end;

function CalcBigNumberDigest(const Num: TCnBigNumber; FixedLen: Integer): TCnSHA512Digest;
var
  Stream: TStream;
begin
  Stream := TMemoryStream.Create;
  try
    FillChar(Result[0], SizeOf(TCnSHA512Digest), 0);
    if BigNumberWriteBinaryToStream(Num, Stream, FixedLen) <> FixedLen then
      Exit;

    Result := SHA512Stream(Stream);
  finally
    Stream.Free;
  end;
end;

// �������˽Կ�����ɹ�Կ�� Ed25519 ǩ��ʹ�õ� Hash ����
procedure CalcBigNumbersFromPrivateKey(const InPrivateKey: TCnBigNumber; FixedLen: Integer;
  OutMulFactor, OutHashPrefix: TCnBigNumber);
var
  Dig: TCnSHA512Digest;
begin
  // �� PrivateKey �� Sha512���õ� 64 �ֽڽ�� Dig
  Dig := CalcBigNumberDigest(InPrivateKey, CN_25519_BLOCK_BYTESIZE);

  // ������ Sha512���õ� 64 �ֽڽ����ǰ 32 �ֽ�ȡ�����������ȵ��򣬵� 3 λ�����㣬
  // ���� CoFactor �� 2^3 = 8 ��Ӧ���������λ 2^255 ���� 0���θ�λ 2^254 ���� 1
  if OutMulFactor <> nil then
  begin
    ReverseMemory(@Dig[0], CN_25519_BLOCK_BYTESIZE);         // �õ�����
    OutMulFactor.SetBinary(@Dig[0], CN_25519_BLOCK_BYTESIZE);

    OutMulFactor.ClearBit(0);                                // ����λ�� 0
    OutMulFactor.ClearBit(1);
    OutMulFactor.ClearBit(2);
    OutMulFactor.ClearBit(CN_25519_BLOCK_BYTESIZE * 8 - 1);  // ���λ�� 0
    OutMulFactor.SetBit(CN_25519_BLOCK_BYTESIZE * 8 - 2);    // �θ�λ�� 1
  end;

  // �� 32 �ֽ���Ϊ Hash ����ڲ���
  if OutHashPrefix <> nil then
    OutHashPrefix.SetBinary(@Dig[CN_25519_BLOCK_BYTESIZE], CN_25519_BLOCK_BYTESIZE);
end;

{ TCnTwistedEdwardsCurve }

constructor TCnTwistedEdwardsCurve.Create(const A, D, FieldPrime, GX, GY,
  Order: AnsiString; H: Integer);
begin
  Create;
  Load(A, D, FieldPrime, GX, GY, Order, H);
end;

constructor TCnTwistedEdwardsCurve.Create;
begin
  inherited;
  FCoefficientA := TCnBigNumber.Create;
  FCoefficientD := TCnBigNumber.Create;
  FOrder := TCnBigNumber.Create;
  FFiniteFieldSize := TCnBigNumber.Create;
  FGenerator := TCnEccPoint.Create;
  FCoFactor := 1;
end;

destructor TCnTwistedEdwardsCurve.Destroy;
begin
  FGenerator.Free;
  FFiniteFieldSize.Free;
  FOrder.Free;
  FCoefficientD.Free;
  FCoefficientA.Free;
  inherited;
end;

function TCnTwistedEdwardsCurve.IsNeutualPoint(P: TCnEccPoint): Boolean;
begin
  Result := P.X.IsZero and P.Y.IsOne;
end;

function TCnTwistedEdwardsCurve.IsPointOnCurve(P: TCnEccPoint): Boolean;
var
  X, Y, L, R: TCnBigNumber;
begin
  // �ж� au^2 + v^2 �Ƿ���� 1 + du^2v^2������ U �� X ���棬V �� Y ����

  X := nil;
  Y := nil;
  L := nil;
  R := nil;

  try
    X := F25519BigNumberPool.Obtain;
    BigNumberCopy(X, P.X);
    BigNumberDirectMulMod(X, X, X, FFiniteFieldSize);

    Y := F25519BigNumberPool.Obtain;
    BigNumberCopy(Y, P.Y);
    BigNumberDirectMulMod(Y, Y, Y, FFiniteFieldSize);

    L := F25519BigNumberPool.Obtain;
    BigNumberDirectMulMod(L, FCoefficientA, X, FFiniteFieldSize);
    BigNumberAddMod(L, L, Y, FFiniteFieldSize); // ��ʱ L := A * X^2 + Y^2

    R := F25519BigNumberPool.Obtain;
    BigNumberDirectMulMod(R, X, Y, FFiniteFieldSize);
    BigNumberDirectMulMod(R, FCoefficientD, R, FFiniteFieldSize);
    R.AddWord(1); // ��ʱ R := 1 + D * X^2 * Y^2

    Result := BigNumberEqual(L, R);
  finally
    F25519BigNumberPool.Recycle(R);
    F25519BigNumberPool.Recycle(L);
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(X);
  end;
end;

procedure TCnTwistedEdwardsCurve.Load(const A, D, FieldPrime, GX, GY,
  Order: AnsiString; H: Integer);
begin
  FCoefficientA.SetHex(A);
  FCoefficientD.SetHex(D);
  FFiniteFieldSize.SetHex(FieldPrime);
  FGenerator.X.SetHex(GX);
  FGenerator.Y.SetHex(GY);
  FOrder.SetHex(Order);
  FCoFactor := H;
end;

procedure TCnTwistedEdwardsCurve.MultiplePoint(K: Int64;
  Point: TCnEccPoint);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    MultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnTwistedEdwardsCurve.MultiplePoint(K: TCnBigNumber;
  Point: TCnEccPoint);
var
  I: Integer;
  E, R: TCnEccPoint;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    PointInverse(Point);
  end;

  if BigNumberIsZero(K) then
  begin
    SetNeutualPoint(Point);
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  R := nil;
  E := nil;

  try
    R := TCnEccPoint.Create;
    E := TCnEccPoint.Create;

    SetNeutualPoint(R); // R ������ʱĬ��Ϊ (0, 0)�����˴�����Ϊ���Ե� (0, 1)
    E.X := Point.X;
    E.Y := Point.Y;

    for I := 0 to BigNumberGetBitsCount(K) - 1 do
    begin
      if BigNumberIsBitSet(K, I) then
        PointAddPoint(R, E, R);
      PointAddPoint(E, E, E);
    end;

    Point.X := R.X;
    Point.Y := R.Y;
  finally
    E.Free;
    R.Free;
  end;
end;

procedure TCnTwistedEdwardsCurve.PointAddPoint(P, Q, Sum: TCnEccPoint);
var
  X, Y, T, D1, D2, N1, N2: TCnBigNumber;
begin
//            x1 * y2 + x2 * y1                 y1 * y2 - a * x1 * x2
//   x3 = --------------------------,   y3 = ---------------------------  �������迼�� P/Q �Ƿ�ͬһ��
//         1 + d * x1 * x2 * y1 * y2          1 - d * x1 * x2 * y1 * y2

  X := nil;
  Y := nil;
  T := nil;
  D1 := nil;
  D2 := nil;
  N1 := nil;
  N2 := nil;

  try
    X := F25519BigNumberPool.Obtain;
    Y := F25519BigNumberPool.Obtain;
    T := F25519BigNumberPool.Obtain;
    D1 := F25519BigNumberPool.Obtain;
    D2 := F25519BigNumberPool.Obtain;
    N1 := F25519BigNumberPool.Obtain;
    N2 := F25519BigNumberPool.Obtain;

    BigNumberDirectMulMod(T, P.X, Q.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(N1, Q.X, P.Y, FFiniteFieldSize);
    BigNumberAddMod(N1, N1, T, FFiniteFieldSize); // N1 �õ� x1 * y2 + x2 * y1���ͷ� T

    BigNumberDirectMulMod(T, P.X, Q.X, FFiniteFieldSize);
    BigNumberDirectMulMod(T, T, FCoefficientA, FFiniteFieldSize);
    BigNumberDirectMulMod(N2, P.Y, Q.Y, FFiniteFieldSize);
    BigNumberSubMod(N2, N2, T, FFiniteFieldSize); // N2 �õ� y1 * y2 - a * x1 * x2���ͷ� T

    BigNumberDirectMulMod(T, P.Y, Q.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(T, T, Q.X, FFiniteFieldSize);
    BigNumberDirectMulMod(T, T, P.X, FFiniteFieldSize);
    BigNumberDirectMulMod(T, T, FCoefficientD, FFiniteFieldSize); // T �õ� d * x1 * x2 * y1 * y2

    BigNumberAddMod(D1, T, CnBigNumberOne, FFiniteFieldSize); // D1 �õ� 1 + d * x1 * x2 * y1 * y2
    BigNumberSubMod(D2, CnBigNumberOne, T, FFiniteFieldSize); // D2 �õ� 1 - d * x1 * x2 * y1 * y2

    BigNumberModularInverse(T, D1, FFiniteFieldSize);  // T �õ� D1 ��Ԫ
    BigNumberDirectMulMod(X, N1, T, FFiniteFieldSize); // �õ� Sum.X

    BigNumberModularInverse(T, D2, FFiniteFieldSize);  // T �õ� D2 ��Ԫ
    BigNumberDirectMulMod(Y, N2, T, FFiniteFieldSize); // �õ� Sum.Y

    BigNumberCopy(Sum.X, X);
    BigNumberCopy(Sum.Y, Y);
  finally
    F25519BigNumberPool.Recycle(N2);
    F25519BigNumberPool.Recycle(N1);
    F25519BigNumberPool.Recycle(D2);
    F25519BigNumberPool.Recycle(D1);
    F25519BigNumberPool.Recycle(T);
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(X);
  end;
end;

procedure TCnTwistedEdwardsCurve.PointInverse(P: TCnEccPoint);
begin
  if BigNumberIsNegative(P.X) or (BigNumberCompare(P.X, FFiniteFieldSize) >= 0) then
    raise ECnEccException.Create(SCnEInverseError);

  BigNumberSub(P.X, FFiniteFieldSize, P.X);
end;

procedure TCnTwistedEdwardsCurve.PointSubPoint(P, Q, Diff: TCnEccPoint);
var
  Inv: TCnEccPoint;
begin
  Inv := TCnEccPoint.Create;
  try
    Inv.Assign(Q);
    PointInverse(Inv);
    PointAddPoint(P, Inv, Diff);
  finally
    Inv.Free;
  end;
end;

procedure TCnTwistedEdwardsCurve.SetNeutualPoint(P: TCnEccPoint);
begin
  P.X.SetZero;
  P.Y.SetOne;
end;

{ TCnMontgomeryCurve }

constructor TCnMontgomeryCurve.Create(const A, B, FieldPrime, GX, GY,
  Order: AnsiString; H: Integer);
begin
  Create;
  Load(A, B, FieldPrime, GX, GY, Order, H);
end;

constructor TCnMontgomeryCurve.Create;
begin
  inherited;
  FCoefficientA := TCnBigNumber.Create;
  FCoefficientB := TCnBigNumber.Create;
  FOrder := TCnBigNumber.Create;
  FFiniteFieldSize := TCnBigNumber.Create;
  FGenerator := TCnEccPoint.Create;
  FCoFactor := 1;

  FLadderConst := TCnBigNumber.Create;
end;

destructor TCnMontgomeryCurve.Destroy;
begin
  FLadderConst.Free;
  FGenerator.Free;
  FFiniteFieldSize.Free;
  FOrder.Free;
  FCoefficientB.Free;
  FCoefficientA.Free;
  inherited;
end;

procedure TCnMontgomeryCurve.GenerateKeys(PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey);
begin
  BigNumberRandRange(PrivateKey, FOrder);           // �� 0 �󵫱Ȼ����С�������
  if PrivateKey.IsZero then                         // ��һ���õ� 0���ͼ� 1
    PrivateKey.SetOne;

  PublicKey.Assign(FGenerator);
  MultiplePoint(PrivateKey, PublicKey);             // ����� PrivateKey ��
end;

function TCnMontgomeryCurve.IsPointOnCurve(P: TCnEccPoint): Boolean;
var
  X, Y, T: TCnBigNumber;
begin
  // �ж� B*y^2 �Ƿ���� x^3 + A*x^2 + x mod P

  X := nil;
  Y := nil;
  T := nil;

  try
    X := F25519BigNumberPool.Obtain;
    BigNumberCopy(X, P.X);

    Y := F25519BigNumberPool.Obtain;
    BigNumberCopy(Y, P.Y);

    BigNumberDirectMulMod(Y, Y, Y, FFiniteFieldSize);
    BigNumberDirectMulMod(Y, FCoefficientB, Y, FFiniteFieldSize);  // Y := B * y^2 mod P

    T := F25519BigNumberPool.Obtain;
    BigNumberDirectMulMod(T, FCoefficientA, X, FFiniteFieldSize);  // T := A*X

    T.AddWord(1); // T := A*X + 1
    BigNumberDirectMulMod(T, X, T, FFiniteFieldSize);       // T := X * (A*X + 1) = AX^2 + X
    BigNumberPowerWordMod(X, X, 3, FFiniteFieldSize);  // X^3
    BigNumberAddMod(X, X, T, FFiniteFieldSize); // X := x^3 + Ax^2 + x mod P

    Result := BigNumberEqual(X, Y);
  finally
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(X);
    F25519BigNumberPool.Recycle(T);
  end;
end;

procedure TCnMontgomeryCurve.Load(const A, B, FieldPrime, GX, GY,
  Order: AnsiString; H: Integer);
begin
  FCoefficientA.SetHex(A);
  FCoefficientB.SetHex(B);
  FFiniteFieldSize.SetHex(FieldPrime);
  FGenerator.X.SetHex(GX);
  FGenerator.Y.SetHex(GY);
  FOrder.SetHex(Order);
  FCoFactor := H;

  // ��ǰ���� (A+2)/4 �Ա��ɸ����������㷨��ʹ��
  CheckLadderConst;
end;

procedure TCnMontgomeryCurve.MultiplePoint(K: Int64; Point: TCnEccPoint);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    MultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnMontgomeryCurve.MontgomeryLadderMultiplePoint(K: TCnBigNumber;
  Point: TCnEccPoint);
var
  I, C: Integer;
  X0, X1: TCnEccPoint;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    XAffinePointInverse(Point);
  end;

  if BigNumberIsZero(K) then 
  begin
    Point.SetZero;
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  X0 := nil;
  X1 := nil;

  try
    X0 := TCnEccPoint.Create;
    X1 := TCnEccPoint.Create;

    X1.Assign(Point);
    MontgomeryLadderPointXDouble(X0, Point);

    C := K.GetBitsCount;
    for I := C - 2 downto 0 do // �ڲ��Ȳ����� Time Constant ִ��ʱ��̶���Ҫ��
    begin
      ConditionalSwapPoint(K.IsBitSet(I + 1) <> K.IsBitSet(I), X0, X1); // ��

      MontgomeryLadderPointXAdd(X1, X0, X1, Point);
      MontgomeryLadderPointXDouble(X0, X0);
    end;

    ConditionalSwapPoint(K.IsBitSet(0), X0, X1);
    Point.Assign(X0);
  finally
    X1.Free;
    X0.Free;
  end;
end;

procedure TCnMontgomeryCurve.MontgomeryLadderPointXAdd(Sum, P, Q,
  PMinusQ: TCnEccPoint);
var
  V0, V1, V2, V3, V4: TCnBigNumber;
begin
  V0 := nil;
  V1 := nil;
  V2 := nil;
  V3 := nil;
  V4 := nil;

  try
    V0 := F25519BigNumberPool.Obtain;
    V1 := F25519BigNumberPool.Obtain;
    V2 := F25519BigNumberPool.Obtain;
    V3 := F25519BigNumberPool.Obtain;
    V4 := F25519BigNumberPool.Obtain;

    BigNumberAddMod(V0, P.X, P.Y, FFiniteFieldSize);
    BigNumberSubMod(V1, Q.X, Q.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(V1, V1, V0, FFiniteFieldSize);

    BigNumberSubMod(V0, P.X, P.Y, FFiniteFieldSize);
    BigNumberAddMod(V2, Q.X, Q.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(V2, V2, V0, FFiniteFieldSize);

    BigNumberAddMod(V3, V1, V2, FFiniteFieldSize);
    BigNumberDirectMulMod(V3, V3, V3, FFiniteFieldSize);

    BigNumberSubMod(V4, V1, V2, FFiniteFieldSize);
    BigNumberDirectMulMod(V4, V4, V4, FFiniteFieldSize);

    BigNumberCopy(V0, PMinusQ.X); // V0 ���ݣ����� Sum �� PMinusQ ��ͬһ����ʱ���Ķ�
    BigNumberDirectMulMod(Sum.X, PMinusQ.Y, V3, FFiniteFieldSize);
    BigNumberDirectMulMod(Sum.Y, V0, V4, FFiniteFieldSize);
  finally
    F25519BigNumberPool.Recycle(V4);
    F25519BigNumberPool.Recycle(V3);
    F25519BigNumberPool.Recycle(V2);
    F25519BigNumberPool.Recycle(V1);
    F25519BigNumberPool.Recycle(V0);
  end;
end;

procedure TCnMontgomeryCurve.MontgomeryLadderPointXDouble(Dbl,
  P: TCnEccPoint);
var
  V1, V2, V3: TCnBigNumber;
begin
  V1 := nil;
  V2 := nil;
  V3 := nil;

  try
    V1 := F25519BigNumberPool.Obtain;
    V2 := F25519BigNumberPool.Obtain;
    V3 := F25519BigNumberPool.Obtain;

    CheckLadderConst;

    BigNumberAddMod(V1, P.X, P.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(V1, V1, V1, FFiniteFieldSize);
    BigNumberSubMod(V2, P.X, P.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(V2, V2, V2, FFiniteFieldSize);
    BigNumberDirectMulMod(Dbl.X, V1, V2, FFiniteFieldSize);

    BigNumberSubMod(V1, V1, V2, FFiniteFieldSize);
    BigNumberDirectMulMod(V3, V1, FLadderConst, FFiniteFieldSize);
    BigNumberAddMod(V3, V3, V2, FFiniteFieldSize);

    BigNumberDirectMulMod(Dbl.Y, V1, V3, FFiniteFieldSize);
  finally
    F25519BigNumberPool.Recycle(V3);
    F25519BigNumberPool.Recycle(V2);
    F25519BigNumberPool.Recycle(V1);
  end;
end;

procedure TCnMontgomeryCurve.MultiplePoint(K: TCnBigNumber;
  Point: TCnEccPoint);
var
  I: Integer;
  E, R: TCnEccPoint;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    PointInverse(Point);
  end;

  if BigNumberIsZero(K) then
  begin
    Point.SetZero;
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  R := nil;
  E := nil;

  try
    R := TCnEccPoint.Create;
    E := TCnEccPoint.Create;

    // R ������ʱĬ��Ϊ����Զ��
    E.X := Point.X;
    E.Y := Point.Y;

    for I := 0 to BigNumberGetBitsCount(K) - 1 do
    begin
      if BigNumberIsBitSet(K, I) then
        PointAddPoint(R, E, R);
      PointAddPoint(E, E, E);
    end;

    Point.X := R.X;
    Point.Y := R.Y;
  finally
    E.Free;
    R.Free;
  end;
end;

procedure TCnMontgomeryCurve.PointAddPoint(P, Q, Sum: TCnEccPoint);
var
  K, X, Y, T, SX, SY: TCnBigNumber;
begin
  // �ȼ���б�ʣ������� X ���Ȼ����ʱ��б�ʷֱ�Ϊ
  //          (y2 - y1)           3*x1^2 + 2*A*x1 + 1
  // б�� K = ----------  �� =  ----------------------
  //          (x2 - x1)                2*y1
  //
  // x3 = B*K^2 - A - x1 - x2
  // y3 = -(y1 + K * (x3 - x1))

  K := nil;
  X := nil;
  Y := nil;
  T := nil;
  SX := nil;
  SY := nil;

  try
    if P.IsZero then
    begin
      Sum.Assign(Q);
      Exit;
    end
    else if Q.IsZero then
    begin
      Sum.Assign(P);
      Exit;
    end;

    K := F25519BigNumberPool.Obtain;
    X := F25519BigNumberPool.Obtain;
    Y := F25519BigNumberPool.Obtain;
    T := F25519BigNumberPool.Obtain;
    SX := F25519BigNumberPool.Obtain;
    SY := F25519BigNumberPool.Obtain;

    if (BigNumberCompare(P.X, Q.X) = 0) and (BigNumberCompare(P.Y, Q.Y) = 0) then
    begin
      if P.Y.IsZero then
      begin
        Sum.SetZero;
        Exit;
      end;

      // ͬһ���㣬������б��
      // ������ (3*x1^2 + 2*A*x1 + 1)
      BigNumberDirectMulMod(Y, FCoefficientA, P.X, FFiniteFieldSize);
      BigNumberAddMod(Y, Y, Y, FFiniteFieldSize);
      Y.AddWord(1); // Y �õ� 2*A*x1 + 1

      BigNumberDirectMulMod(T, P.X, P.X, FFiniteFieldSize);
      T.MulWord(3);
      BigNumberAddMod(Y, T, Y, FFiniteFieldSize); // Y �õ� 3*x1^2 + 2*A*x1 + 1���ͷ� T

      BigNumberAddMod(X, P.Y, P.Y, FFiniteFieldSize);  // 2Y
      BigNumberModularInverse(T, X, FFiniteFieldSize); // �õ���ĸ 2*y1

      BigNumberDirectMulMod(K, Y, T, FFiniteFieldSize); // K �õ�����б��
    end
    else
    begin
      if BigNumberCompare(P.X, Q.X) = 0 then // ��� X ��ȣ�Ҫ�ж� Y �ǲ��ǻ����������Ϊ 0�����������
      begin
        BigNumberAdd(T, P.Y, Q.Y);
        if BigNumberCompare(T, FFiniteFieldSize) = 0 then  // ��������Ϊ 0
          Sum.SetZero
        else                                               // ������������
          raise ECnEccException.CreateFmt(SCnECanNOTCalcErrorFmt,
            [P.X.ToDec, P.Y.ToDec, Q.X.ToDec, Q.Y.ToDec]);

        Exit;
      end;

      BigNumberSubMod(Y, Q.Y, P.Y, FFiniteFieldSize);   // �õ����� (y2 - y1)
      BigNumberSubMod(X, Q.X, P.X, FFiniteFieldSize);   // �õ���ĸ (x2 - x1)

      BigNumberModularInverse(T, X, FFiniteFieldSize);
      BigNumberDirectMulMod(K, Y, T, FFiniteFieldSize); // K �õ�����б��
    end;

    // x3 = B * K^2 - A - x1 - x2
    BigNumberDirectMulMod(SX, K, K, FFiniteFieldSize);
    BigNumberDirectMulMod(SX, FCoefficientB, SX, FFiniteFieldSize);
    BigNumberSubMod(SX, SX, FCoefficientA, FFiniteFieldSize);
    BigNumberSubMod(SX, SX, P.X, FFiniteFieldSize);
    BigNumberSubMod(SX, SX, Q.X, FFiniteFieldSize);

    // y3 = -(y1 + K * (x3 - x1))
    BigNumberSubMod(SY, SX, P.X, FFiniteFieldSize);
    BigNumberDirectMulMod(SY, SY, K, FFiniteFieldSize);
    BigNumberAddMod(SY, SY, P.Y, FFiniteFieldSize);
    BigNumberSub(SY, FFiniteFieldSize, SY);

    BigNumberCopy(Sum.X, SX);
    BigNumberCopy(Sum.Y, SY);
  finally
    F25519BigNumberPool.Recycle(SY);
    F25519BigNumberPool.Recycle(SX);
    F25519BigNumberPool.Recycle(T);
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(X);
    F25519BigNumberPool.Recycle(K);
  end;
end;

procedure TCnMontgomeryCurve.PointInverse(P: TCnEccPoint);
begin
  if BigNumberIsNegative(P.Y) or (BigNumberCompare(P.Y, FFiniteFieldSize) >= 0) then
    raise ECnEccException.Create(SCnEInverseError);

  BigNumberSub(P.Y, FFiniteFieldSize, P.Y);
end;

procedure TCnMontgomeryCurve.PointSubPoint(P, Q, Diff: TCnEccPoint);
var
  Inv: TCnEccPoint;
begin
  Inv := TCnEccPoint.Create;
  try
    Inv.Assign(Q);
    PointInverse(Inv);
    PointAddPoint(P, Inv, Diff);
  finally
    Inv.Free;
  end;
end;

procedure TCnMontgomeryCurve.CheckLadderConst;
var
  T: TCnBigNumber;
begin
  if FLadderConst.IsZero then
  begin
    FLadderConst.SetWord(4);
    T := F25519BigNumberPool.Obtain;

    try
      BigNumberModularInverse(T, FLadderConst, FFiniteFieldSize); // ���� 4 ����Ԫ

      BigNumberCopy(FLadderConst, FCoefficientA); // ���� A+2
      FLadderConst.AddWord(2);

      BigNumberDirectMulMod(FLadderConst, FLadderConst, T, FFiniteFieldSize); // ����Ԫ���ڳ�

      Cn25519BigNumberToField64(FLadderField64, FLadderConst);
    finally
      F25519BigNumberPool.Recycle(T);
    end;
  end;
end;

procedure TCnMontgomeryCurve.MontgomeryLadderMultiplePoint(K: Int64;
  Point: TCnEccPoint);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    MontgomeryLadderMultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnMontgomeryCurve.PointToXAffinePoint(DestPoint,
  SourcePoint: TCnEccPoint);
begin
  BigNumberCopy(DestPoint.X, SourcePoint.X);
  if SourcePoint.X.IsZero and SourcePoint.Y.IsZero then
  begin
    DestPoint.X.SetOne;
    DestPoint.Y.SetZero;
  end
  else
    DestPoint.Y.SetOne;
end;

procedure TCnMontgomeryCurve.XAffinePointToPoint(DestPoint,
  SourcePoint: TCnEccPoint);
var
  T, X, DX: TCnBigNumber;
begin
  // ����Ϊ��Ӱ (X, Z)���� x = (X/Z)������ y
  if SourcePoint.Y.IsZero then
  begin
    DestPoint.SetZero;
    Exit;
  end;

  T := nil;
  X := nil;
  DX := nil;

  try
    T := F25519BigNumberPool.Obtain;
    X := F25519BigNumberPool.Obtain;
    DX := F25519BigNumberPool.Obtain;

    BigNumberModularInverse(T, SourcePoint.Y, FFiniteFieldSize); // Z^-1
    BigNumberDirectMulMod(DX, SourcePoint.X, T, FFiniteFieldSize); // ��� DX ���Ȳ���ֵ����Ӱ��

    BigNumberCopy(X, DX); // DestPoint.X = X/Z

    // �� X^3+A*X^2+X mod P
    BigNumberPowerWordMod(X, DX, 3, FFiniteFieldSize);  // X^3

    BigNumberDirectMulMod(T, DX, DX, FFiniteFieldSize);
    BigNumberDirectMulMod(T, T, FCoefficientA, FFiniteFieldSize);  // A*X^2

    BigNumberAddMod(X, T, X, FFiniteFieldSize);
    BigNumberAddMod(X, X, DX, FFiniteFieldSize);  // �õ� X^3+A*X^2+X mod P

    BigNumberSquareRootModPrime(DestPoint.Y, X, FFiniteFieldSize);  // ��ģƽ����
    BigNumberCopy(DestPoint.X, DX);
  finally
    F25519BigNumberPool.Recycle(DX);
    F25519BigNumberPool.Recycle(X);
    F25519BigNumberPool.Recycle(T);
  end;
end;

procedure TCnMontgomeryCurve.Field64XAffinePointToPoint(DestPoint: TCnEccPoint;
  var SourcePoint: TCn25519Field64EccPoint);
var
  T: TCnEccPoint;
begin
  if DestPoint = nil then
    Exit;

  T := TCnEccPoint.Create;
  try
    Cn25519Field64ToBigNumber(T.X, SourcePoint.X);  // ����ʽ��ת��Ϊ��Ӱ���� X Z ��
    Cn25519Field64ToBigNumber(T.Y, SourcePoint.Y);

    XAffinePointToPoint(DestPoint, T);   // ����ʽ��ת��Ϊ��Ӱ���� X Z ��
  finally
    T.Free;
  end;
end;

procedure TCnMontgomeryCurve.MontgomeryLadderField64MultiplePoint(
  K: TCnBigNumber; var Point: TCn25519Field64EccPoint);
var
  I, C: Integer;
  X0, X1: TCn25519Field64EccPoint;
begin
  if BigNumberIsZero(K) then // ������ K Ϊ��ֵ�����
  begin
    Cn25519Field64Zero(Point.X);
    Cn25519Field64Zero(Point.Y);
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  Cn25519Field64EccPointCopy(X1, Point);
  MontgomeryLadderField64PointXDouble(X0, Point);

  C := K.GetBitsCount;
  for I := C - 2 downto 0 do // �ڲ��Ȳ����� Time Constant ִ��ʱ��̶���Ҫ��
  begin
    ConditionalSwapField64Point(K.IsBitSet(I + 1) <> K.IsBitSet(I), X0, X1); // ��

    MontgomeryLadderField64PointXAdd(X1, X0, X1, Point);
    MontgomeryLadderField64PointXDouble(X0, X0);
  end;

  ConditionalSwapField64Point(K.IsBitSet(0), X0, X1);
  Cn25519Field64EccPointCopy(Point, X0);
end;

procedure TCnMontgomeryCurve.MontgomeryLadderField64MultiplePoint(K: Int64;
  var Point: TCn25519Field64EccPoint);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    MontgomeryLadderField64MultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnMontgomeryCurve.MontgomeryLadderField64PointXAdd(var Sum, P,
  Q, PMinusQ: TCn25519Field64EccPoint);
var
  V0, V1, V2, V3, V4: TCn25519Field64;
begin
  Cn25519Field64Add(V0, P.X, P.Y);
  Cn25519Field64Sub(V1, Q.X, Q.Y);
  Cn25519Field64Mul(V1, V1, V0);

  Cn25519Field64Sub(V0, P.X, P.Y);
  Cn25519Field64Add(V2, Q.X, Q.Y);
  Cn25519Field64Mul(V2, V2, V0);

  Cn25519Field64Add(V3, V1, V2);
  Cn25519Field64Mul(V3, V3, V3);

  Cn25519Field64Sub(V4, V1, V2);
  Cn25519Field64Mul(V4, V4, V4);

  Cn25519Field64Copy(V0, PMinusQ.X);   // V0 ���ݣ����� Sum �� PMinusQ ��ͬһ����ʱ���Ķ�
  Cn25519Field64Mul(Sum.X, PMinusQ.Y, V3);
  Cn25519Field64Mul(Sum.Y, V0, V4);
end;

procedure TCnMontgomeryCurve.MontgomeryLadderField64PointXDouble(var Dbl,
  P: TCn25519Field64EccPoint);
var
  V1, V2, V3: TCn25519Field64;
begin
  CheckLadderConst;
  Cn25519Field64Add(V1, P.X, P.Y);
  Cn25519Field64Mul(V1, V1, V1);

  Cn25519Field64Sub(V2, P.X, P.Y);
  Cn25519Field64Mul(V2, V2, V2);

  Cn25519Field64Mul(Dbl.X, V1, V2);

  Cn25519Field64Sub(V1, V1, V2);
  Cn25519Field64Mul(V3, V1, FLadderField64);

  Cn25519Field64Add(V3, V3, V2);

  Cn25519Field64Mul(Dbl.Y, V1, V3);
end;

procedure TCnMontgomeryCurve.PointToField64XAffinePoint(
  var DestPoint: TCn25519Field64EccPoint; SourcePoint: TCnEccPoint);
var
  T: TCnEccPoint;
begin
  if SourcePoint = nil then
    Exit;

  T := TCnEccPoint.Create;
  try
    PointToXAffinePoint(T, SourcePoint); // ��ͨ��ת��Ϊ��Ӱ���� X Z ��

    Cn25519BigNumberToField64(DestPoint.X, T.X);    // ��Ӱ���� X Z ��ת��Ϊ����ʽ��
    Cn25519BigNumberToField64(DestPoint.Y, T.Y);
  finally
    T.Free;
  end;
end;

procedure TCnMontgomeryCurve.XAffinePointInverse(P: TCnEccPoint);
begin
  // P ���ö�
end;

{ TCnCurve25519 }

constructor TCnCurve25519.Create;
begin
  inherited;
  Load(SCN_25519_MONT_A, SCN_25519_MONT_B, SCN_25519_PRIME, SCN_25519_MONT_GX,
    SCN_25519_MONT_GY, SCN_25519_ORDER, SCN_25519_COFACTOR);
end;

procedure TCnCurve25519.GenerateKeys(PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey);
begin
  BigNumberRandRange(PrivateKey, FOrder);           // �� 0 �󵫱Ȼ����С�������
  if PrivateKey.IsZero then                         // ��һ���õ� 0���ͼ� 1
    PrivateKey.SetOne;

  PrivateKey.ClearBit(0);                                // ����λ�� 0
  PrivateKey.ClearBit(1);
  PrivateKey.ClearBit(2);
  PrivateKey.ClearBit(CN_25519_BLOCK_BYTESIZE * 8 - 1);  // ���λ�� 0
  PrivateKey.SetBit(CN_25519_BLOCK_BYTESIZE * 8 - 2);    // �θ�λ�� 1

  PublicKey.Assign(FGenerator);
  MultiplePoint(PrivateKey, PublicKey);             // ����� PrivateKey ��
end;

procedure TCnCurve25519.MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint);
var
  M: TCn25519Field64EccPoint;
begin
  PointToField64XAffinePoint(M, Point);
  MontgomeryLadderField64MultiplePoint(K, M);
  Field64XAffinePointToPoint(Point, M);
end;

{ TCnEd25519 }

constructor TCnEd25519.Create;
begin
  inherited;
  Load(SCN_25519_EDWARDS_A, SCN_25519_EDWARDS_D, SCN_25519_PRIME, SCN_25519_EDWARDS_GX,
    SCN_25519_EDWARDS_GY, SCN_25519_ORDER, 8);
end;

procedure TCnEd25519.ExtendedMultiplePoint(K: Int64; Point: TCnEcc4Point);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    ExtendedMultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnEd25519.ExtendedField64MultiplePoint(K: Int64;
  var Point: TCn25519Field64Ecc4Point);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    ExtendedField64MultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnEd25519.ExtendedField64MultiplePoint(K: TCnBigNumber;
  var Point: TCn25519Field64Ecc4Point);
var
  I: Integer;
  E, R: TCn25519Field64Ecc4Point;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    ExtendedField64PointInverse(Point);
  end;

  if BigNumberIsZero(K) then
  begin
    Cn25519Field64Ecc4PointNeutual(Point);
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  // R Ҫ�����Ե�
  Cn25519Field64Ecc4PointNeutual(R);
  Cn25519Field64Ecc4PointCopy(E, Point);

  for I := 0 to BigNumberGetBitsCount(K) - 1 do
  begin
    if BigNumberIsBitSet(K, I) then
      ExtendedField64PointAddPoint(R, E, R);
    ExtendedField64PointAddPoint(E, E, E);
  end;

  Cn25519Field64Ecc4PointCopy(Point, R);
end;

function TCnEd25519.ExtendedField64PointAddPoint(var P, Q,
  Sum: TCn25519Field64Ecc4Point): Boolean;
var
  A, B, C, D, E, F, G, H: TCn25519Field64;
  CoD: TCn25519Field64;
begin
  if Cn25519Field64Ecc4PointEqual(P, Q) then
  begin
    // ��ͬһ����
    Cn25519Field64Mul(A, P.X, P.X);   // A = X1^2
    Cn25519Field64Mul(B, P.Y, P.Y);   // B = Y1^2

    Cn25519Field64Mul(C, P.Z, P.Z);
    Cn25519Field64Add(C, C, C);       // C = 2*Z1^2

    Cn25519Field64Add(H, A, B);       // H = A+B

    Cn25519Field64Add(E, P.X, P.Y);
    Cn25519Field64Mul(E, E, E);
    Cn25519Field64Sub(E, H, E);       // E = H-(X1+Y1)^2

    Cn25519Field64Sub(G, A, B);       // G = A-B
    Cn25519Field64Add(F, C, G);       // F = C+G

    Cn25519Field64Mul(Sum.X, E, F);   // X3 = E*F
    Cn25519Field64Mul(Sum.Y, G, H);   // Y3 = G*H
    Cn25519Field64Mul(Sum.T, E, H);   // T3 = E*H
    Cn25519Field64Mul(Sum.Z, F, G);   // Z3 = F*G

    Result := True;
  end
  else
  begin
    // ����ͬһ���㡣���� G H ����ʱ����
    Cn25519Field64Sub(G, P.Y, P.X);
    Cn25519Field64Sub(H, Q.Y, Q.X);
    Cn25519Field64Mul(A, G, H); // A = (Y1-X1)*(Y2-X2)

    Cn25519Field64Add(G, P.Y, P.X);
    Cn25519Field64Add(H, Q.Y, Q.X);
    Cn25519Field64Mul(B, G, H);  // B = (Y1+X1)*(Y2+X2)

    Cn25519BigNumberToField64(CoD, FCoefficientD);
    Cn25519Field64Add(C, CoD, CoD);
    Cn25519Field64Mul(C, P.T, C);
    Cn25519Field64Mul(C, Q.T, C);   // C = T1*2*d*T2

    Cn25519Field64Add(D, P.Z, P.Z);
    Cn25519Field64Mul(D, Q.Z, D);   // D = Z1*2*Z2

    Cn25519Field64Sub(E, B, A);   // E = B-A
    Cn25519Field64Sub(F, D, C);   // F = D-C
    Cn25519Field64Add(G, D, C);   // G = D+C
    Cn25519Field64Add(H, B, A);   // H = B+A

    Cn25519Field64Mul(Sum.X, E, F);   // X3 = E*F
    Cn25519Field64Mul(Sum.Y, G, H);   // Y3 = G*H
    Cn25519Field64Mul(Sum.T, E, H);   // T3 = E*H
    Cn25519Field64Mul(Sum.Z, F, G);   // Z3 = F*G

    Result := True;
  end;
end;

procedure TCnEd25519.ExtendedField64PointInverse(
  var P: TCn25519Field64Ecc4Point);
var
  T: TCn25519Field64;
begin
  // X -> Prime - X
  Cn25519Field64Sub(P.X, F25519Field64Zero, P.X);

  // T := X * Y / Z^3
  if Cn25519Field64Equal(P.Z, F25519Field64One) then
  begin
    // Z = 1 ��ֱ�ӳ�
    Cn25519Field64Mul(P.T, P.X, P.Y);
  end
  else // Z <> 1 
  begin
    // ���� Z^3 ��ģ��Ԫ
    Cn25519Field64Mul(T, P.Z, P.Z);
    Cn25519Field64Mul(T, T, P.Z);

    Cn25519Field64ModularInverse(T, T);

    // �ٳ��� X * Y
    Cn25519Field64Mul(P.T, P.X, P.Y);
    Cn25519Field64Mul(P.T, P.T, T);
  end;
end;

function TCnEd25519.ExtendedField64PointSubPoint(var P, Q,
  Diff: TCn25519Field64Ecc4Point): Boolean;
var
  Inv: TCn25519Field64Ecc4Point;
begin
  Cn25519Field64Ecc4PointCopy(Inv, Q);
  ExtendedField64PointInverse(Inv);
  Result := ExtendedField64PointAddPoint(P, Inv, Diff);
end;

procedure TCnEd25519.ExtendedMultiplePoint(K: TCnBigNumber;
  Point: TCnEcc4Point);
var
  I: Integer;
  E, R: TCnEcc4Point;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    ExtendedPointInverse(Point);
  end;

  if BigNumberIsZero(K) then
  begin
    SetNeutualExtendedPoint(Point);
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  R := nil;
  E := nil;

  try
    R := TCnEcc4Point.Create;
    E := TCnEcc4Point.Create;

    // R Ҫ�����Ե�
    SetNeutualExtendedPoint(R);

    E.X := Point.X;
    E.Y := Point.Y;
    E.Z := Point.Z;
    E.T := Point.T;

    for I := 0 to BigNumberGetBitsCount(K) - 1 do
    begin
      if BigNumberIsBitSet(K, I) then
        ExtendedPointAddPoint(R, E, R);
      ExtendedPointAddPoint(E, E, E);
    end;

    Point.X := R.X;
    Point.Y := R.Y;
    Point.Z := R.Z;
  finally
    R.Free;
    E.Free;
  end;
end;

procedure TCnEd25519.ExtendedPointAddPoint(P, Q, Sum: TCnEcc4Point);
var
  A, B, C, D, E, F, G, H: TCnBigNumber;
begin
  A := nil;
  B := nil;
  C := nil;
  D := nil;
  E := nil;
  F := nil;
  G := nil;
  H := nil;

  try
    A := F25519BigNumberPool.Obtain;
    B := F25519BigNumberPool.Obtain;
    C := F25519BigNumberPool.Obtain;
    D := F25519BigNumberPool.Obtain;
    E := F25519BigNumberPool.Obtain;
    F := F25519BigNumberPool.Obtain;
    G := F25519BigNumberPool.Obtain;
    H := F25519BigNumberPool.Obtain;

    if CnEcc4PointEqual(P, Q, FFiniteFieldSize) then
    begin
      // ��ͬһ����
      BigNumberDirectMulMod(A, P.X, P.X, FFiniteFieldSize); // A = X1^2
      BigNumberDirectMulMod(B, P.Y, P.Y, FFiniteFieldSize);  // B = Y1^2

      BigNumberDirectMulMod(C, P.Z, P.Z, FFiniteFieldSize);
      BigNumberAddMod(C, C, C, FFiniteFieldSize);      // C = 2*Z1^2

      BigNumberAddMod(H, A, B, FFiniteFieldSize);      // H = A+B

      BigNumberAddMod(E, P.X, P.Y, FFiniteFieldSize);
      BigNumberDirectMulMod(E, E, E, FFiniteFieldSize);
      BigNumberSubMod(E, H, E, FFiniteFieldSize);      // E = H-(X1+Y1)^2

      BigNumberSubMod(G, A, B, FFiniteFieldSize);      // G = A-B
      BigNumberAddMod(F, C, G, FFiniteFieldSize);      // F = C+G

      BigNumberDirectMulMod(Sum.X, E, F, FFiniteFieldSize);  // X3 = E*F
      BigNumberDirectMulMod(Sum.Y, G, H, FFiniteFieldSize);  // Y3 = G*H
      BigNumberDirectMulMod(Sum.T, E, H, FFiniteFieldSize);  // T3 = E*H
      BigNumberDirectMulMod(Sum.Z, F, G, FFiniteFieldSize);  // Z3 = F*G
    end
    else
    begin
      // ����ͬһ���㡣���� G H ����ʱ����
      BigNumberSubMod(G, P.Y, P.X, FFiniteFieldSize);
      BigNumberSubMod(H, Q.Y, Q.X, FFiniteFieldSize);
      BigNumberDirectMulMod(A, G, H, FFiniteFieldSize); // A = (Y1-X1)*(Y2-X2)

      BigNumberAddMod(G, P.Y, P.X, FFiniteFieldSize);
      BigNumberAddMod(H, Q.Y, Q.X, FFiniteFieldSize);
      BigNumberDirectMulMod(B, G, H, FFiniteFieldSize);  // B = (Y1+X1)*(Y2+X2)

      BigNumberAdd(C, FCoefficientD, FCoefficientD);
      BigNumberDirectMulMod(C, P.T, C, FFiniteFieldSize);
      BigNumberDirectMulMod(C, Q.T, C, FFiniteFieldSize);  // C = T1*2*d*T2

      BigNumberAdd(D, P.Z, P.Z);
      BigNumberDirectMulMod(D, Q.Z, D, FFiniteFieldSize);  // D = Z1*2*Z2

      BigNumberSubMod(E, B, A, FFiniteFieldSize);  // E = B-A
      BigNumberSubMod(F, D, C, FFiniteFieldSize);  // F = D-C
      BigNumberAddMod(G, D, C, FFiniteFieldSize);  // G = D+C
      BigNumberAddMod(H, B, A, FFiniteFieldSize);  // H = B+A

      BigNumberDirectMulMod(Sum.X, E, F, FFiniteFieldSize);  // X3 = E*F
      BigNumberDirectMulMod(Sum.Y, G, H, FFiniteFieldSize);  // Y3 = G*H
      BigNumberDirectMulMod(Sum.T, E, H, FFiniteFieldSize);  // T3 = E*H
      BigNumberDirectMulMod(Sum.Z, F, G, FFiniteFieldSize);  // Z3 = F*G
    end;
  finally
    F25519BigNumberPool.Recycle(H);
    F25519BigNumberPool.Recycle(G);
    F25519BigNumberPool.Recycle(F);
    F25519BigNumberPool.Recycle(E);
    F25519BigNumberPool.Recycle(D);
    F25519BigNumberPool.Recycle(C);
    F25519BigNumberPool.Recycle(B);
    F25519BigNumberPool.Recycle(A);
  end;
end;

procedure TCnEd25519.ExtendedPointInverse(P: TCnEcc4Point);
var
  T: TCnBigNumber;
begin
  T := F25519BigNumberPool.Obtain;
  try
    // x -> -x����ζ�� X/Z -> P - X/Z��Ҳ���� (P*Z - X)/Z�������� X = P*Z - X��ǰ���� 0��������� P - X
    BigNumberDirectMulMod(T, P.Z, FFiniteFieldSize, FFiniteFieldSize);
    BigNumberSubMod(P.X, T, P.X, FFiniteFieldSize); // �ͷ� T

    // T := X * Y / Z^3
    BigNumberPowerWordMod(T, P.Z, 3, FFiniteFieldSize);
    BigNumberModularInverse(T, T, FFiniteFieldSize); // T �� Z^3 ����Ԫ
    BigNumberDirectMulMod(P.T, P.X, P.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(P.T, P.T, T, FFiniteFieldSize);
  finally
    F25519BigNumberPool.Recycle(T);
  end;
end;

procedure TCnEd25519.ExtendedPointSubPoint(P, Q, Diff: TCnEcc4Point);
var
  Inv: TCnEcc4Point;
begin
  Inv := TCnEcc4Point.Create;
  try
    Inv.Assign(Q);
    ExtendedPointInverse(Inv);
    ExtendedPointAddPoint(P, Inv, Diff);
  finally
    Inv.Free;
  end;
end;

function TCnEd25519.GenerateKeys(PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey): Boolean;
var
  K: TCnBigNumber;
begin
  Result := False;

  // ��� 32 �ֽ��� PrivateKey
  if not BigNumberRandBytes(PrivateKey, CN_25519_BLOCK_BYTESIZE) then
    Exit;

  K := F25519BigNumberPool.Obtain;
  try
    CalcBigNumbersFromPrivateKey(PrivateKey, CN_25519_BLOCK_BYTESIZE, K, nil);

    // �ó��� K ���� G ��õ���Կ
    PublicKey.Assign(FGenerator);
    MultiplePoint(K, PublicKey);                         // ����� K ��

    Result := True;
  finally
    F25519BigNumberPool.Recycle(K);
  end;
end;

function CnEcc4PointToString(const P: TCnEcc4Point): string;
begin
  Result := Format('%s,%s,%s,%s', [P.X.ToDec, P.Y.ToDec, P.Z.ToDec, P.T.ToDec]);
end;

function CnEcc4PointToHex(const P: TCnEcc4Point): string;
begin
  Result := Format('%s,%s,%s,%s', [P.X.ToHex, P.Y.ToHex, P.Z.ToHex, P.T.ToHex]);
end;

function CnEcc4PointEqual(const P, Q: TCnEcc4Point; Prime: TCnBigNumber): Boolean;
var
  T1, T2: TCnBigNumber;
begin
  // X1*Z2 = X2*Z1 �� Y1*Z2 = Y2*Z1
  Result := False;
  if P = Q then
  begin
    Result := True;
    Exit;
  end;

  T1 := nil;
  T2 := nil;

  try
    T1 := F25519BigNumberPool.Obtain;
    T2 := F25519BigNumberPool.Obtain;

    BigNumberDirectMulMod(T1, P.X, Q.Z, Prime);
    BigNumberDirectMulMod(T2, Q.X, P.Z, Prime);

    if not BigNumberEqual(T1, T2) then
      Exit;

    BigNumberDirectMulMod(T1, P.Y, Q.Z, Prime);
    BigNumberDirectMulMod(T2, Q.Y, P.Z, Prime);

    if not BigNumberEqual(T1, T2) then
      Exit;

    Result := True;
  finally
    F25519BigNumberPool.Recycle(T2);
    F25519BigNumberPool.Recycle(T1);
  end;
end;

function CnEccPointToEcc4Point(DestPoint: TCnEcc4Point; SourcePoint: TCnEccPoint;
  Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not CnEccPointToEcc3Point(SourcePoint, DestPoint) then
    Exit;
  Result := BigNumberDirectMulMod(DestPoint.T, SourcePoint.X, SourcePoint.Y, Prime);
end;

function CnEcc4PointToEccPoint(DestPoint: TCnEccPoint; SourcePoint: TCnEcc4Point;
  Prime: TCnBigNumber): Boolean;
begin
  Result := CnAffinePointToEccPoint(SourcePoint, DestPoint, Prime);
end;

// =============================================================================
//
//          Curve25519 �� u v �� Ed25519 �� x y ��˫��ӳ���ϵΪ��
//
//              (u, v) = ((1+y)/(1-y), sqrt(-486664)*u/x)
//              (x, y) = (sqrt(-486664)*u/v, (u-1)/(u+1))
//
// =============================================================================

procedure CnCurve25519PointToEd25519Point(DestPoint, SourcePoint: TCnEccPoint);
var
  S, T, Inv, Prime, TX: TCnBigNumber;
begin
  // x = sqrt(-486664)*u/v
  // y = (u-1)/(u+1)

  S := nil;
  T := nil;
  Prime := nil;
  Inv := nil;
  TX := nil;

  try
    S := F25519BigNumberPool.Obtain;
    T := F25519BigNumberPool.Obtain;

    S.SetHex(SCN_25519_SQRT_NEG_486664);
    Prime := F25519BigNumberPool.Obtain;
    Prime.SetHex(SCN_25519_PRIME);

    BigNumberDirectMulMod(T, S, SourcePoint.X, Prime); // sqrt * u

    Inv := F25519BigNumberPool.Obtain;
    BigNumberModularInverse(Inv, SourcePoint.Y, Prime); // v^-1

    TX := F25519BigNumberPool.Obtain;
    BigNumberDirectMulMod(TX, T, Inv, Prime); // �㵽 X�����Ȳ���ֵ������ԴĿ��ͬ�������Ӱ��

    BigNumberCopy(T, SourcePoint.X);
    BigNumberCopy(S, SourcePoint.X);

    T.SubWord(1);  // u - 1
    S.AddWord(1);  // u + 1

    BigNumberModularInverse(Inv, S, Prime); // (u + 1)^1
    BigNumberDirectMulMod(DestPoint.Y, T, Inv, Prime);
    BigNumberCopy(DestPoint.X, TX);
  finally
    F25519BigNumberPool.Recycle(TX);
    F25519BigNumberPool.Recycle(Inv);
    F25519BigNumberPool.Recycle(Prime);
    F25519BigNumberPool.Recycle(T);
    F25519BigNumberPool.Recycle(S);
  end;
end;

procedure CnEd25519PointToCurve25519Point(DestPoint, SourcePoint: TCnEccPoint);
var
  S, T, Inv, Prime, TX: TCnBigNumber;
begin
  // u = (1+y)/(1-y)
  // v = sqrt(-486664)*u/x

  S := nil;
  T := nil;
  Prime := nil;
  Inv := nil;
  TX := nil;

  try
    S := F25519BigNumberPool.Obtain;
    T := F25519BigNumberPool.Obtain;

    BigNumberCopy(T, SourcePoint.Y);
    BigNumberCopy(S, SourcePoint.Y);
    T.AddWord(1);  // T �Ƿ��� 1+y

    Prime := F25519BigNumberPool.Obtain;
    Prime.SetHex(SCN_25519_PRIME);

    BigNumberSubMod(S, CnBigNumberOne, SourcePoint.Y, Prime); // S �Ƿ�ĸ 1-y

    Inv := F25519BigNumberPool.Obtain;
    BigNumberModularInverse(Inv, S, Prime); // Inv �Ƿ�ĸ����������

    TX := F25519BigNumberPool.Obtain;
    BigNumberDirectMulMod(TX, T, Inv, Prime); // �õ� U��������ֵ�����ݴ棬����ԴĿ��ͬ�����Ӱ��

    S.SetHex(SCN_25519_SQRT_NEG_486664);
    BigNumberDirectMulMod(T, S, TX, Prime);

    BigNumberModularInverse(Inv, SourcePoint.X, Prime);
    BigNumberDirectMulMod(DestPoint.Y, T, Inv, Prime);

    BigNumberCopy(DestPoint.X, TX); // ���ݴ�� TX ����Ŀ���
  finally
    F25519BigNumberPool.Recycle(TX);
    F25519BigNumberPool.Recycle(Inv);
    F25519BigNumberPool.Recycle(Prime);
    F25519BigNumberPool.Recycle(T);
    F25519BigNumberPool.Recycle(S);
  end;
end;

procedure CnEd25519PointToData(P: TCnEccPoint; var Data: TCnEd25519Data);
begin
  if P = nil then
    Exit;

  FillChar(Data[0], SizeOf(TCnEd25519Data), 0);
  P.Y.ToBinary(@Data[0], SizeOf(TCnEd25519Data));
  ReverseMemory(@Data[0], SizeOf(TCnEd25519Data)); // С������Ҫ��һ��

  if P.X.IsOdd then // X �����������λ�� 1
    Data[CN_25519_BLOCK_BYTESIZE - 1] := Data[CN_25519_BLOCK_BYTESIZE - 1] or $80  // ��λ�� 1
  else
    Data[CN_25519_BLOCK_BYTESIZE - 1] := Data[CN_25519_BLOCK_BYTESIZE - 1] and $7F; // ��λ�� 0
end;

procedure CnEd25519DataToPoint(Data: TCnEd25519Data; P: TCnEccPoint;
  out XOdd: Boolean);
var
  D: TCnEd25519Data;
begin
  if P = nil then
    Exit;

  Move(Data[0], D[0], SizeOf(TCnEd25519Data));
  ReverseMemory(@D[0], SizeOf(TCnEd25519Data));
  P.Y.SetBinary(@D[0], SizeOf(TCnEd25519Data));

  // ���λ�Ƿ��� 0 ��ʾ�� X ����ż
  XOdd := P.Y.IsBitSet(8 * CN_25519_BLOCK_BYTESIZE - 1);

  // ���λ������
  P.Y.ClearBit(8 * CN_25519_BLOCK_BYTESIZE - 1);
end;

procedure CnEd25519BigNumberToData(N: TCnBigNumber; var Data: TCnEd25519Data);
begin
  if (N = nil) or (N.GetBytesCount > SizeOf(TCnEd25519Data)) then
    Exit;

  FillChar(Data[0], SizeOf(TCnEd25519Data), 0);
  N.ToBinary(@Data[0], SizeOf(TCnEd25519Data));
  ReverseMemory(@Data[0], SizeOf(TCnEd25519Data));
end;

procedure CnEd25519DataToBigNumber(Data: TCnEd25519Data; N: TCnBigNumber);
var
  D: TCnEd25519Data;
begin
  if N = nil then
    Exit;

  Move(Data[0], D[0], SizeOf(TCnEd25519Data));
  ReverseMemory(@D[0], SizeOf(TCnEd25519Data));
  N.SetBinary(@D[0], SizeOf(TCnEd25519Data));
end;

function CnEd25519SignData(PlainData: Pointer; DataLen: Integer; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; OutSignature: TCnEd25519Signature; Ed25519: TCnEd25519): Boolean;
var
  Is25519Nil: Boolean;
  Stream: TMemoryStream;
  R, S, K, HP: TCnBigNumber;
  Dig: TCnSHA512Digest;
  Data: TCnEd25519Data;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (PrivateKey = nil) or (PublicKey = nil)
    or (OutSignature = nil) then
    Exit;

  R := nil;
  S := nil;
  K := nil;
  HP := nil;
  Stream := nil;
  Is25519Nil := Ed25519 = nil;

  try
    if Is25519Nil then
      Ed25519 := TCnEd25519.Create;

    R := F25519BigNumberPool.Obtain;
    S := F25519BigNumberPool.Obtain;
    K := F25519BigNumberPool.Obtain;
    HP := F25519BigNumberPool.Obtain;

    // ����˽Կ�õ�˽Կ���� s ���Ӵ�ǰ׺
    CalcBigNumbersFromPrivateKey(PrivateKey, CN_25519_BLOCK_BYTESIZE, S, HP);

    // �Ӵ�ǰ׺ƴ��ԭʼ����
    Stream := TMemoryStream.Create;
    BigNumberWriteBinaryToStream(HP, Stream, CN_25519_BLOCK_BYTESIZE);
    Stream.Write(PlainData^, DataLen);

    // ����� SHA512 ֵ��Ϊ r ������׼�����Ի�����Ϊ R ��
    Dig := SHA512Buffer(Stream.Memory, Stream.Size);

    ReverseMemory(@Dig[0], SizeOf(TCnSHA512Digest)); // ��Ҫ��תһ��
    R.SetBinary(@Dig[0], SizeOf(TCnSHA512Digest));
    BigNumberNonNegativeMod(R, R, Ed25519.Order);  // r ����̫���� mod һ�½�

    OutSignature.R.Assign(Ed25519.Generator);
    Ed25519.MultiplePoint(R, OutSignature.R);      // ����õ�ǩ��ֵ R����ֵ��һ��������

    // �� Hash ���� S���ȵ� R ת��Ϊ�ֽ�����
    Ed25519.PointToPlain(OutSignature.R, Data);

    // ƴ����
    Stream.Clear;
    Stream.Write(Data[0], SizeOf(TCnEd25519Data));

    // ��Կ��Ҳת��Ϊ�ֽ�����
    Ed25519.PointToPlain(PublicKey, Data);
    Stream.Write(Data[0], SizeOf(TCnEd25519Data));

    // д���ģ�ƴ�����
    Stream.Write(PlainData^, DataLen);

    // �ٴ��Ӵ� R||PublicKey||����
    Dig := SHA512Buffer(Stream.Memory, Stream.Size);

    ReverseMemory(@Dig[0], SizeOf(TCnSHA512Digest)); // ����Ҫ��תһ��
    K.SetBinary(@Dig[0], SizeOf(TCnSHA512Digest));
    BigNumberNonNegativeMod(K, K, Ed25519.Order);  // ����̫������ mod һ�½�

    // ������� R + K * S mod Order
    BigNumberDirectMulMod(OutSignature.S, K, S, Ed25519.Order);
    BigNumberAddMod(OutSignature.S, R, OutSignature.S, Ed25519.Order);

    Result := True;
  finally
    Stream.Free;
    F25519BigNumberPool.Recycle(HP);
    F25519BigNumberPool.Recycle(K);
    F25519BigNumberPool.Recycle(S);
    F25519BigNumberPool.Recycle(R);
    if Is25519Nil then
      Ed25519.Free;
  end;
end;

function CnEd25519VerifyData(PlainData: Pointer; DataLen: Integer;
  InSignature: TCnEd25519Signature; PublicKey: TCnEccPublicKey; Ed25519: TCnEd25519): Boolean;
var
  Is25519Nil: Boolean;
  L, R, M: TCnEccPoint;
  T: TCnBigNumber;
  Stream: TMemoryStream;
  Data: TCnEd25519Data;
  Dig: TCnSHA512Digest;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (PublicKey = nil) or (InSignature = nil) then
    Exit;

  L := nil;
  R := nil;
  Stream := nil;
  T := nil;
  M := nil;
  Is25519Nil := Ed25519 = nil;

  try
    if Is25519Nil then
      Ed25519 := TCnEd25519.Create;

    // ��֤ 8*S*���� �Ƿ� = 8*R�� + 8*Hash(R32λ||��Կ��32λ||����) * ��Կ��
    L := TCnEccPoint.Create;
    R := TCnEccPoint.Create;

    L.Assign(Ed25519.Generator);
    Ed25519.MultiplePoint(InSignature.S, L);
    Ed25519.MultiplePoint(8, L);  // �㵽��ߵ�

    R.Assign(InSignature.R);
    Ed25519.MultiplePoint(8, R);  // �㵽 8*R�����

    Stream := TMemoryStream.Create;
    CnEd25519PointToData(InSignature.R, Data);
    Stream.Write(Data[0], SizeOf(TCnEd25519Data));        // ƴ R ��

    CnEd25519PointToData(PublicKey, Data);
    Stream.Write(Data[0], SizeOf(TCnEd25519Data));        // ƴ��Կ��
    Stream.Write(PlainData^, DataLen);                    // ƴ����

    Dig := SHA512Buffer(Stream.Memory, Stream.Size);      // ���� Hash ��Ϊֵ
    ReverseMemory(@Dig[0], SizeOf(TCnSHA512Digest));        // ��Ҫ��תһ��

    T := F25519BigNumberPool.Obtain;
    T.SetBinary(@Dig[0], SizeOf(TCnSHA512Digest));
    T.MulWord(8);
    BigNumberNonNegativeMod(T, T, Ed25519.Order); // T ����̫���� mod һ�½�

    M := TCnEccPoint.Create;
    M.Assign(PublicKey);
    Ed25519.MultiplePoint(T, M);      // T �˹�Կ��
    Ed25519.PointAddPoint(R, M, R);   // ���

    Result := CnEccPointsEqual(L, R);
  finally
    M.Free;
    F25519BigNumberPool.Recycle(T);
    Stream.Free;
    R.Free;
    L.Free;
    if Is25519Nil then
      Ed25519.Free;
  end;
end;

function CnEd25519SignFile(const FileName: string; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; OutSignatureStream: TStream; Ed25519: TCnEd25519): Boolean;
var
  Stream: TMemoryStream;
  Sig: TCnEd25519Signature;
  SigData: TCnEd25519SignatureData;
begin
  Result := False;
  if (PrivateKey = nil) or (PublicKey = nil) or (OutSignatureStream = nil)
    or not FileExists(FileName) then
    Exit;

  Stream := nil;
  Sig := nil;

  try
    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(FileName);

    Sig := TCnEd25519Signature.Create;

    if CnEd25519SignData(Stream.Memory, Stream.Size, PrivateKey, PublicKey, Sig, Ed25519) then
    begin
      Sig.SaveToData(SigData);
      Result := OutSignatureStream.Write(SigData[0], SizeOf(TCnEd25519SignatureData))
        = SizeOf(TCnEd25519SignatureData);
    end;
  finally
    Sig.Free;
    Stream.Free;
  end;
end;

function CnEd25519VerifyFile(const FileName: string; InSignatureStream: TStream;
  PublicKey: TCnEccPublicKey; Ed25519: TCnEd25519 = nil): Boolean;
var
  Stream: TMemoryStream;
  Sig: TCnEd25519Signature;
  SigData: TCnEd25519SignatureData;
begin
  Result := False;
  if (PublicKey = nil) or (InSignatureStream = nil) or not FileExists(FileName) then
    Exit;

  Stream := nil;
  Sig := nil;

  try
    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(FileName);

    if InSignatureStream.Read(SigData[0], SizeOf(TCnEd25519SignatureData)) <>
      SizeOf(TCnEd25519SignatureData) then
      Exit;

    Sig := TCnEd25519Signature.Create;
    Sig.LoadFromData(SigData);

    Result := CnEd25519VerifyData(Stream.Memory, Stream.Size, Sig, PublicKey, Ed25519);
  finally
    Sig.Free;
    Stream.Free;
  end;
end;

function CnCurve25519KeyExchangeStep1(SelfPrivateKey: TCnEccPrivateKey;
  OutPointToAnother: TCnEccPoint; Curve25519: TCnCurve25519): Boolean;
var
  Is25519Nil: Boolean;
begin
  Result := False;
  if (SelfPrivateKey = nil) or (OutPointToAnother = nil) then
    Exit;

  Is25519Nil := Curve25519 = nil;

  try
    if Is25519Nil then
      Curve25519 := TCnCurve25519.Create;

    OutPointToAnother.Assign(Curve25519.Generator);
    Curve25519.MultiplePoint(SelfPrivateKey, OutPointToAnother);

    Result := True;
  finally
    if Is25519Nil then
      Curve25519.Free;
  end;
end;

function CnCurve25519KeyExchangeStep2(SelfPrivateKey: TCnEccPrivateKey;
  InPointFromAnother: TCnEccPoint; OutKey: TCnEccPoint; Curve25519: TCnCurve25519): Boolean;
var
  Is25519Nil: Boolean;
begin
  Result := False;
  if (SelfPrivateKey = nil) or (InPointFromAnother = nil) or (OutKey = nil) then
    Exit;

  Is25519Nil := Curve25519 = nil;

  try
    if Is25519Nil then
      Curve25519 := TCnCurve25519.Create;

    OutKey.Assign(InPointFromAnother);
    Curve25519.MultiplePoint(SelfPrivateKey, OutKey);

    Result := True;
  finally
    if Is25519Nil then
      Curve25519.Free;
  end;
end;

function TCnEd25519.IsExtendedPointOnCurve(P: TCnEcc4Point): Boolean;
var
  Q: TCnEccPoint;
begin
  Q := TCnEccPoint.Create;
  try
    CnEcc4PointToEccPoint(Q, P, FFiniteFieldSize);
    Result := IsPointOnCurve(Q);
  finally
    Q.Free;
  end;
end;

function TCnEd25519.IsExtendedField64PointOnCurve(
  var P: TCn25519Field64Ecc4Point): Boolean;
var
  Q: TCnEccPoint;
begin
  Q := TCnEccPoint.Create;
  try
    CnField64Ecc4PointToEccPoint(Q, P);
    Result := IsPointOnCurve(Q);
  finally
    Q.Free;
  end;
end;

function TCnEd25519.IsNeutualExtendedPoint(P: TCnEcc4Point): Boolean;
begin
  Result := P.X.IsZero and P.T.IsZero and not P.Y.IsZero and not P.Z.IsZero
    and BigNumberEqual(P.Y, P.Z);
end;

procedure TCnEd25519.MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint);
var
  P4: TCn25519Field64Ecc4Point;
begin
  CnEccPointToField64Ecc4Point(P4, Point);
  ExtendedField64MultiplePoint(K, P4);
  CnField64Ecc4PointToEccPoint(Point, P4);
end;

procedure TCnEd25519.PlainToPoint(Plain: TCnEd25519Data;
  OutPoint: TCnEccPoint);
var
  XOdd: Boolean;
  T, Y, Inv: TCnBigNumber;
begin
  if OutPoint = nil then
    Exit;

  // �ȴ� Plain �л�ԭ Y �����Լ� X �����ż��
  CnEd25519DataToPoint(Plain, OutPoint, XOdd);

  // �õ� Y ����� x �ķ��� x^2 = (Y^2 - 1) / (D*Y^2 + 1) mod P
  // ע������ 25519 �� 8u5 ����ʽ

  T := nil;
  Y := nil;
  Inv := nil;

  try
    T := F25519BigNumberPool.Obtain;
    Y := F25519BigNumberPool.Obtain;

    BigNumberDirectMulMod(Y, OutPoint.Y, OutPoint.Y, FFiniteFieldSize);
    Y.SubWord(1); // Y := Y^2 - 1

    BigNumberDirectMulMod(T, OutPoint.Y, OutPoint.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(T, T, FCoefficientD, FFiniteFieldSize);
    T.AddWord(1); // T := D*Y^2 + 1

    Inv := F25519BigNumberPool.Obtain;
    BigNumberModularInverse(Inv, T, FFiniteFieldSize);

    BigNumberDirectMulMod(Y, Y, Inv, FFiniteFieldSize);  // Y �õ������ұߵ�ֵ

    BigNumberSquareRootModPrime(OutPoint.X, Y, FFiniteFieldSize);

    // ��� X ��
    if OutPoint.X.IsBitSet(0) <> XOdd then
      BigNumberSub(OutPoint.X, FFiniteFieldSize, OutPoint.X);
  finally
    F25519BigNumberPool.Recycle(Inv);
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(T);
  end;
end;

procedure TCnEd25519.PointToPlain(Point: TCnEccPoint;
  var OutPlain: TCnEd25519Data);
begin
  if (Point = nil) or (BigNumberCompare(Point.Y, FFiniteFieldSize) >= 0) then
    Exit;

  CnEd25519PointToData(Point, OutPlain);
end;

procedure TCnEd25519.SetNeutualExtendedPoint(P: TCnEcc4Point);
begin
  P.X.SetZero;
  P.Y.SetOne;
  P.Z.SetOne;
  P.T.SetZero;
end;

{ TCnEd25519Sigature }

procedure TCnEd25519Signature.Assign(Source: TPersistent);
begin
  if Source is TCnEd25519Signature then
  begin
    FR.Assign((Source as TCnEd25519Signature).R);
    BigNumberCopy(FS, (Source as TCnEd25519Signature).S);
  end
  else
    inherited;
end;

constructor TCnEd25519Signature.Create;
begin
  inherited;
  FR := TCnEccPoint.Create;
  FS := TCnBigNumber.Create;
end;

destructor TCnEd25519Signature.Destroy;
begin
  FS.Free;
  FR.Free;
  inherited;
end;

{ TCnEcc4Point }

procedure TCnEcc4Point.Assign(Source: TPersistent);
begin
  if Source is TCnEcc4Point then
    BigNumberCopy(FT, (Source as TCnEcc4Point).T);
  inherited;
end;

constructor TCnEcc4Point.Create;
begin
  inherited;
  FT := TCnBigNumber.Create;
end;

destructor TCnEcc4Point.Destroy;
begin
  FT.Free;
  inherited;
end;

procedure TCnEcc4Point.SetT(const Value: TCnBigNumber);
begin
  BigNumberCopy(FT, Value);
end;

function TCnEcc4Point.ToString: string;
begin
  Result := CnEcc4PointToHex(Self);
end;

procedure TCnEd25519Signature.LoadFromData(Sig: TCnEd25519SignatureData);
var
  Data: TCnEd25519Data;
  Ed25519: TCnEd25519;
begin
  Move(Sig[0], Data[0], SizeOf(TCnEd25519Data));

  // �� Data �м��� R ��
  Ed25519 := TCnEd25519.Create;
  try
    Ed25519.PlainToPoint(Data, FR);
  finally
    Ed25519.Free;
  end;

  Move(Sig[SizeOf(TCnEd25519Data)], Data[0], SizeOf(TCnEd25519Data));
  // �� Data �м��� S ��
  CnEd25519DataToBigNumber(Data, FS);
end;

procedure TCnEd25519Signature.SaveToData(var Sig: TCnEd25519SignatureData);
var
  Data: TCnEd25519Data;
begin
  FillChar(Sig[0], SizeOf(TCnEd25519SignatureData), 0);

  // �� R ��д�� Data
  CnEd25519PointToData(FR, Data);
  Move(Data[0], Sig[0], SizeOf(TCnEd25519Data));

  // �� S ��д�� Data
  CnEd25519BigNumberToData(FS, Data);
  Move(Data[0], Sig[SizeOf(TCnEd25519Data)], SizeOf(TCnEd25519Data));
end;

procedure Cn25519BigNumberToField64(var Field: TCn25519Field64; const Num: TCnBigNumber);
var
  D: TCn25519Field64;
begin
  if Num.IsNegative or (BigNumberUnsignedCompare(Num, FPrime25519) > 0) then
    BigNumberNonNegativeMod(Num, Num, FPrime25519);

  // ��� Num �� SetHex 8888888877777777666666665555555544444444333333332222222211111111
  // ��ô����ʵֵȷʵ�� 8888888877777777666666665555555544444444333333332222222211111111
  // �ڴ��е͵����� 11111111 22222222 33333333 44444444 55555555 66666666 77777777 88888888
  // ���������ֽڣ�ÿ�����ֽ��ڲ�����С�˲�ͬ�����𣬵��������账��
  // ��� 64 λ��ֵ�� D0=2222222211111111 D1=4444444433333333 D3=6666666655555555 D4=8888888877777777

  FillChar(D[0], SizeOf(TCn25519Field64), 0);
  BigNumberRawDump(Num, @D[0]);

  Field[0] := D[0] and $7FFFFFFFFFFFF;  // D0 ������ 51 λ��0 �� 50����1��
  Field[1] := (D[0] shr 51) or ((D[1] and $3FFFFFFFFF) shl 13); // D0 �ĸ� 13 λ��64 �� 51���� D1 �ĵ� 38 λ����1��ƴ����
  Field[2] := (D[1] shr 38) or ((D[2] and $1FFFFFF) shl 26); // D1 �ĸ� 26 λ��64 �� 38���� D2 �ĵ� 25 λ����1��ƴ����
  Field[3] := (D[2] shr 25) or ((D[3] and $0FFF) shl 39); // D2 �ĸ� 39 λ��64 �� 25���� D2 �ĵ� 12 λ����1��ƴ����
  Field[4] := D[3] shr 12;                             // D3 �ĸ� 52 λ��64 �� 12��
end;

procedure Cn25519Field64ToBigNumber(const Res: TCnBigNumber; var Field: TCn25519Field64);
var
  B0, B1, B2, B3, B4: TCnBigNumber;
begin
  B0 := nil;
  B1 := nil;
  B2 := nil;
  B3 := nil;
  B4 := nil;

  try
    B0 := F25519BigNumberPool.Obtain;
    B1 := F25519BigNumberPool.Obtain;
    B2 := F25519BigNumberPool.Obtain;
    B3 := F25519BigNumberPool.Obtain;
    B4 := F25519BigNumberPool.Obtain;

    B0.SetInt64(Field[0]);
    B1.SetInt64(Field[1]);
    B2.SetInt64(Field[2]);
    B3.SetInt64(Field[3]);
    B4.SetInt64(Field[4]);

    B1.ShiftLeft(51);
    B2.ShiftLeft(102);
    B3.ShiftLeft(153);
    B4.ShiftLeft(204);

    Res.SetZero;
    BigNumberAdd(Res, B1, B0);
    BigNumberAdd(Res, Res, B2);
    BigNumberAdd(Res, Res, B3);
    BigNumberAdd(Res, Res, B4);

    BigNumberNonNegativeMod(Res, Res, FPrime25519);
  finally
    F25519BigNumberPool.Recycle(B4);
    F25519BigNumberPool.Recycle(B3);
    F25519BigNumberPool.Recycle(B2);
    F25519BigNumberPool.Recycle(B1);
    F25519BigNumberPool.Recycle(B0);
  end;
end;

procedure Cn25519Field64Reduce(var Field: TCn25519Field64);
var
  C: TCn25519Field64;
begin
  C[0] := Field[0] shr 51;
  C[1] := Field[1] shr 51;
  C[2] := Field[2] shr 51;
  C[3] := Field[3] shr 51;
  C[4] := Field[4] shr 51;

  Field[0] := Field[0] and SCN_LOW51_MASK;
  Field[1] := Field[1] and SCN_LOW51_MASK;
  Field[2] := Field[2] and SCN_LOW51_MASK;
  Field[3] := Field[3] and SCN_LOW51_MASK;
  Field[4] := Field[4] and SCN_LOW51_MASK;

  Field[0] := Field[0] + C[4] * 19; // ���λ�Ľ�λ�� mod ��ʣ�µĸ������λ
  Field[1] := Field[1] + C[0];
  Field[2] := Field[2] + C[1];
  Field[3] := Field[3] + C[2];
  Field[4] := Field[4] + C[3];
end;

function Cn25519Field64ToHex(var Field: TCn25519Field64): string;
begin
  Result := '$' + UInt64ToHex(Field[0]) + ' $' + UInt64ToHex(Field[1]) + ' $' +
    UInt64ToHex(Field[2]) + ' $'+ UInt64ToHex(Field[3]) + ' $' + UInt64ToHex(Field[4]);
end;

procedure Cn25519Field64Copy(var Dest, Source: TCn25519Field64);
begin
  Move(Source[0], Dest[0], SizeOf(TCn25519Field64));
end;

function Cn25519Field64Equal(var A, B: TCn25519Field64): Boolean;
begin
  Result := (A[0] = B[0]) and (A[1] = B[1]) and (A[2] = B[2])
    and (A[3] = B[3]) and (A[4] = B[4]);
  // ֻ���б��Ӧֵ������ Reduce �ж�

//  if not Result then
//  begin
//    Cn25519Field64Copy(T1, A);
//    Cn25519Field64Copy(T2, B);
//
//    Cn25519Field64Reduce(T1);
//    Cn25519Field64Reduce(T2);
//    Result := (T1[0] = T2[0]) and (T1[1] = T2[1]) and (T1[2] = T2[2])
//      and (T1[3] = T2[3]) and (T1[4] = T2[4]);
//  end;
end;

procedure Cn25519Field64Swap(var A, B: TCn25519Field64);
var
  I: Integer;
  T: TUInt64;
begin
  for I := Low(TCn25519Field64) to High(TCn25519Field64) do
  begin
    T := A[I];
    A[I] := B[I];
    B[I] := T;
  end;
end;

procedure Cn25519Field64Zero(var Field: TCn25519Field64);
begin
  Move(F25519Field64Zero[0], Field[0], SizeOf(TCn25519Field64));
end;

procedure Cn25519Field64One(var Field: TCn25519Field64);
begin
  Move(F25519Field64One[0], Field[0], SizeOf(TCn25519Field64));
end;

procedure Cn25519Field64NegOne(var Field: TCn25519Field64);
begin
  Move(F25519Field64NegOne[0], Field[0], SizeOf(TCn25519Field64));
end;

{$WARNINGS OFF}

procedure Cn25519Field64Negate(var Field: TCn25519Field64);
begin
  Field[0] := 36028797018963664 - Field[0];
  Field[1] := 36028797018963952 - Field[1];
  Field[2] := 36028797018963952 - Field[2];
  Field[3] := 36028797018963952 - Field[3];
  Field[4] := 36028797018963952 - Field[4];
  Cn25519Field64Reduce(Field);
end;

{$WARNINGS ON}

procedure Cn25519Field64Add(var Res, A, B: TCn25519Field64);
var
  I: Integer;
begin
  for I := Low(TCn25519Field64) to High(TCn25519Field64) do
    Res[I] := A[I] + B[I];
end;

{$WARNINGS OFF}

procedure Cn25519Field64Sub(var Res, A, B: TCn25519Field64);
begin
  Res[0] := A[0] + 36028797018963664 - B[0];
  Res[1] := A[1] + 36028797018963952 - B[1];
  Res[2] := A[2] + 36028797018963952 - B[2];
  Res[3] := A[3] + 36028797018963952 - B[3];
  Res[4] := A[4] + 36028797018963952 - B[4];
  Cn25519Field64Reduce(Res);
end;

{$WARNINGS ON}

procedure Cn25519Field64Mul(var Res, A, B: TCn25519Field64);
var
  B1, B2, B3, B4, C: TUInt64;
  C0, C1, C2, C3, C4, T: TCnUInt128;
begin
  B1 := B[1] * 19;
  B2 := B[2] * 19;
  B3 := B[3] * 19;
  B4 := B[4] * 19;

  UInt128SetZero(C0);
  // c0 = m(a[0],b[0]) + m(a[4],b1_19) + m(a[3],b2_19) + m(a[2],b3_19) + m(a[1],b4_19);
  UInt64MulUInt64(A[0], B[0], T.Lo64, T.Hi64);
  UInt128Add(C0, C0, T);
  UInt64MulUInt64(A[4], B1, T.Lo64, T.Hi64);
  UInt128Add(C0, C0, T);
  UInt64MulUInt64(A[3], B2, T.Lo64, T.Hi64);
  UInt128Add(C0, C0, T);
  UInt64MulUInt64(A[2], B3, T.Lo64, T.Hi64);
  UInt128Add(C0, C0, T);
  UInt64MulUInt64(A[1], B4, T.Lo64, T.Hi64);
  UInt128Add(C0, C0, T);

  UInt128SetZero(C1);
  // c1 = m(a[1],b[0]) + m(a[0],b[1])  + m(a[4],b2_19) + m(a[3],b3_19) + m(a[2],b4_19);
  UInt64MulUInt64(A[1], B[0], T.Lo64, T.Hi64);
  UInt128Add(C1, C1, T);
  UInt64MulUInt64(A[0], B[1], T.Lo64, T.Hi64);
  UInt128Add(C1, C1, T);
  UInt64MulUInt64(A[4], B2, T.Lo64, T.Hi64);
  UInt128Add(C1, C1, T);
  UInt64MulUInt64(A[3], B3, T.Lo64, T.Hi64);
  UInt128Add(C1, C1, T);
  UInt64MulUInt64(A[2], B4, T.Lo64, T.Hi64);
  UInt128Add(C1, C1, T);

  UInt128SetZero(C2);
  // c2 = m(a[2],b[0]) + m(a[1],b[1])  + m(a[0],b[2])  + m(a[4],b3_19) + m(a[3],b4_19);
  UInt64MulUInt64(A[2], B[0], T.Lo64, T.Hi64);
  UInt128Add(C2, C2, T);
  UInt64MulUInt64(A[1], B[1], T.Lo64, T.Hi64);
  UInt128Add(C2, C2, T);
  UInt64MulUInt64(A[0], B[2], T.Lo64, T.Hi64);
  UInt128Add(C2, C2, T);
  UInt64MulUInt64(A[4], B3, T.Lo64, T.Hi64);
  UInt128Add(C2, C2, T);
  UInt64MulUInt64(A[3], B4, T.Lo64, T.Hi64);
  UInt128Add(C2, C2, T);

  UInt128SetZero(C3);
  // c3 = m(a[3],b[0]) + m(a[2],b[1])  + m(a[1],b[2])  + m(a[0],b[3])  + m(a[4],b4_19);
  UInt64MulUInt64(A[3], B[0], T.Lo64, T.Hi64);
  UInt128Add(C3, C3, T);
  UInt64MulUInt64(A[2], B[1], T.Lo64, T.Hi64);
  UInt128Add(C3, C3, T);
  UInt64MulUInt64(A[1], B[2], T.Lo64, T.Hi64);
  UInt128Add(C3, C3, T);
  UInt64MulUInt64(A[0], B[3], T.Lo64, T.Hi64);
  UInt128Add(C3, C3, T);
  UInt64MulUInt64(A[4], B4, T.Lo64, T.Hi64);
  UInt128Add(C3, C3, T);

  UInt128SetZero(C4);
  // c4 = m(a[4],b[0]) + m(a[3],b[1])  + m(a[2],b[2])  + m(a[1],b[3])  + m(a[0],b[4]);
  UInt64MulUInt64(A[4], B[0], T.Lo64, T.Hi64);
  UInt128Add(C4, C4, T);
  UInt64MulUInt64(A[3], B[1], T.Lo64, T.Hi64);
  UInt128Add(C4, C4, T);
  UInt64MulUInt64(A[2], B[2], T.Lo64, T.Hi64);
  UInt128Add(C4, C4, T);
  UInt64MulUInt64(A[1], B[3], T.Lo64, T.Hi64);
  UInt128Add(C4, C4, T);
  UInt64MulUInt64(A[0], B[4], T.Lo64, T.Hi64);
  UInt128Add(C4, C4, T);

  // ƴ���
  UInt128Copy(T, C0);
  UInt128ShiftRight(T, 51);
  UInt128Add(C1, T.Lo64);
  Res[0] := C0.Lo64 and SCN_LOW51_MASK;

  UInt128Copy(T, C1);
  UInt128ShiftRight(T, 51);
  UInt128Add(C2, T.Lo64);
  Res[1] := C1.Lo64 and SCN_LOW51_MASK;

  UInt128Copy(T, C2);
  UInt128ShiftRight(T, 51);
  UInt128Add(C3, T.Lo64);
  Res[2] := C2.Lo64 and SCN_LOW51_MASK;

  UInt128Copy(T, C3);
  UInt128ShiftRight(T, 51);
  UInt128Add(C4, T.Lo64);
  Res[3] := C3.Lo64 and SCN_LOW51_MASK;

  UInt128Copy(T, C4);
  UInt128ShiftRight(T, 51);
  C := T.Lo64;
  Res[4] := C4.Lo64 and SCN_LOW51_MASK;

  Res[0] := Res[0] + C * 19;
  Res[1] := Res[1] + (Res[0] shr 51);

  Res[0] := Res[0] and SCN_LOW51_MASK;
end;

procedure Cn25519Field64Power(var Res, A: TCn25519Field64; K: Cardinal);
var
  T: TCn25519Field64;
begin
  if K = 0 then
    Cn25519Field64One(Res)
  else if K = 1 then
    Cn25519Field64Copy(Res, A)
  else
  begin
    Cn25519Field64Copy(T, A);
    Cn25519Field64One(Res);

    while K > 0 do
    begin
      if (K and 1) <> 0 then
        Cn25519Field64Mul(Res, Res, T);

      K := K shr 1;
      Cn25519Field64Mul(T, T, T);
    end;
  end;
end;

procedure Cn25519Field64Power(var Res, A: TCn25519Field64; K: TCnBigNumber);
var
  T: TCn25519Field64;
  I, B: Integer;
begin
  if K.IsZero then
    Cn25519Field64One(Res)
  else if K.IsOne then
    Cn25519Field64Copy(Res, A)
  else
  begin
    Cn25519Field64Copy(T, A);
    Cn25519Field64One(Res);

    B := K.GetBitsCount;
    for I := 0 to B - 1 do
    begin
      if K.IsBitSet(I) then
        Cn25519Field64Mul(Res, Res, T);
      Cn25519Field64Mul(T, T, T);
    end;
  end;
end;

procedure Cn25519Field64Power2K(var Res, A: TCn25519Field64; K: Cardinal);
begin
  Cn25519Field64Copy(Res, A);
  if K = 0 then
    Exit;

  while K > 0 do
  begin
    Cn25519Field64Mul(Res, Res, Res);
    Dec(K);
  end;
end;

procedure Cn25519Field64ModularInverse(var Res, A: TCn25519Field64);
var
  P: TCnBigNumber;
begin
  // �÷���С������ A �� P - 2 �η�
  P := F25519BigNumberPool.Obtain;
  try
    BigNumberCopy(P, FPrime25519);
    P.SubWord(2);

    Cn25519Field64Power(Res, A, P);
  finally
    F25519BigNumberPool.Recycle(P);
  end;
end;

// =========================== ����ʽ�㴦���� ================================

procedure Cn25519Field64EccPointZero(var Point: TCn25519Field64EccPoint);
begin
  Cn25519Field64Zero(Point.X);
  Cn25519Field64Zero(Point.Y);
end;

procedure Cn25519Field64EccPointCopy(var DestPoint, SourcePoint: TCn25519Field64EccPoint);
begin
  Cn25519Field64Copy(DestPoint.X, SourcePoint.X);
  Cn25519Field64Copy(DestPoint.Y, SourcePoint.Y);
end;

function Cn25519Field64EccPointToHex(var Point: TCn25519Field64EccPoint): string;
begin
  Result := 'X: ' + Cn25519Field64ToHex(Point.X) + ' Y: ' + Cn25519Field64ToHex(Point.Y);
end;

function Cn25519Field64EccPointEqual(var A, B: TCn25519Field64EccPoint): Boolean;
begin
  Result := Cn25519Field64Equal(A.X, B.X) and  Cn25519Field64Equal(A.Y, B.Y);
end;

procedure Cn25519Field64Ecc4PointNeutual(var Point: TCn25519Field64Ecc4Point);
begin
  Cn25519Field64Zero(Point.X);
  Cn25519Field64One(Point.Y);
  Cn25519Field64One(Point.Z);
  Cn25519Field64Zero(Point.T);
end;

procedure Cn25519Field64Ecc4PointCopy(var DestPoint, SourcePoint: TCn25519Field64Ecc4Point);
begin
  Cn25519Field64Copy(DestPoint.X, SourcePoint.X);
  Cn25519Field64Copy(DestPoint.Y, SourcePoint.Y);
  Cn25519Field64Copy(DestPoint.Z, SourcePoint.Z);
  Cn25519Field64Copy(DestPoint.T, SourcePoint.T);
end;

function Cn25519Field64Ecc4PointToHex(var Point: TCn25519Field64Ecc4Point): string;
begin
  Result := 'X: ' + Cn25519Field64ToHex(Point.X) + ' Y: ' + Cn25519Field64ToHex(Point.Y)
    + ' Z: ' + Cn25519Field64ToHex(Point.Z) + ' T: ' + Cn25519Field64ToHex(Point.T);
end;

function Cn25519Field64Ecc4PointEqual(var A, B: TCn25519Field64Ecc4Point): Boolean;
var
  T1, T2: TCn25519Field64;
begin
  // X1Z2 = X2Z1 �� Y1Z2 = Y2Z1
  Result := False;

  Cn25519Field64Mul(T1, A.X, B.Z);
  Cn25519Field64Mul(T2, B.X, A.Z);

  if not Cn25519Field64Equal(T1, T2) then
    Exit;

  Cn25519Field64Mul(T1, A.Y, B.Z);
  Cn25519Field64Mul(T2, B.Y, A.Z);

  if not Cn25519Field64Equal(T1, T2) then
    Exit;

  Result := True;
end;

function CnEccPointToField64Ecc4Point(var DestPoint: TCn25519Field64Ecc4Point;
  SourcePoint: TCnEccPoint): Boolean;
var
  P4: TCnEcc4Point;
begin
  P4 := TCnEcc4Point.Create;
  try
    CnEccPointToEcc4Point(P4, SourcePoint, FPrime25519);
    Result := CnEcc4PointToField64Ecc4Point(DestPoint, P4);
  finally
    P4.Free;
  end;
end;

function CnField64Ecc4PointToEccPoint(DestPoint: TCnEccPoint;
  var SourcePoint: TCn25519Field64Ecc4Point): Boolean;
var
  P4: TCnEcc4Point;
begin
  P4 := TCnEcc4Point.Create;
  try
    CnField64Ecc4PointToEcc4Point(P4, SourcePoint);
    Result := CnEcc4PointToEccPoint(DestPoint, P4, FPrime25519);
  finally
    P4.Free;
  end;
end;

function CnEcc4PointToField64Ecc4Point(var DestPoint: TCn25519Field64Ecc4Point;
  SourcePoint: TCnEcc4Point): Boolean;
begin
  Cn25519BigNumberToField64(DestPoint.X, SourcePoint.X);
  Cn25519BigNumberToField64(DestPoint.Y, SourcePoint.Y);
  Cn25519BigNumberToField64(DestPoint.Z, SourcePoint.Z);
  Cn25519BigNumberToField64(DestPoint.T, SourcePoint.T);
  Result := True;
end;

function CnField64Ecc4PointToEcc4Point(DestPoint: TCnEcc4Point;
  var SourcePoint: TCn25519Field64Ecc4Point): Boolean;
begin
  Cn25519Field64ToBigNumber(DestPoint.X, SourcePoint.X);
  Cn25519Field64ToBigNumber(DestPoint.Y, SourcePoint.Y);
  Cn25519Field64ToBigNumber(DestPoint.Z, SourcePoint.Z);
  Cn25519Field64ToBigNumber(DestPoint.T, SourcePoint.T);
  Result := True;
end;

initialization
  F25519BigNumberPool := TCnBigNumberPool.Create;
  FPrime25519 := TCnBigNumber.FromHex(SCN_25519_PRIME);

finalization
  FPrime25519.Free;
  F25519BigNumberPool.Free;

end.
