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

unit CnECC;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ���Բ�����㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��Ŀǰʵ���� Int64 ��Χ���Լ�������ʽ������ y^2 = x^3 + Ax + B mod p
*           ������Բ���ߵļ��㣬x �� y ������������
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.04.06 V1.5
*               ʵ�� ECC ǩ����ǩ�������� openssl �Ĺ���
*               openssl dgst -sha256 -sign ec.pem -out hello.sig hello
*               openssl dgst -sha256 -verify ecpub.pem -signature hello.sig hello
*               ע�� Ecc ��ǩ��ֻ�����Ϣ Hash������в��� Hash �㷨�������û���Ϣ��
*               �� SM2 �淶��ͬ���� RSA �� Hash �� Hash �����ٶ���� BER ����Ҳ��ͬ
*           2020.03.28 V1.4
*               ʵ�� ECC ��˽Կ PEM �ļ����������д�������� openssl �Ĺ���
*               openssl ecparam -name secp256k1 -genkey -out ec.pem
*               openssl ec -in ec.pem -pubout -out ecpub.pem
*           2018.09.29 V1.3
*               ʵ�ִ�����Բ���߸��� X �� Y �������㷨����Ĭ�����ٶȸ���� Lucas
*           2018.09.13 V1.2
*               ����ʵ�ִ�����Բ���ߵļӽ��ܹ��ܣ�֧�� SM2 �Լ� Secp256k1 ������
*           2018.09.10 V1.1
*               �ܹ�����ϵ����С����Բ���߲���
*           2018.09.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

{$DEFINE USE_LUCAS}
// ��������������Ҳ���Ǹ��� X ������Բ���߷��̵� Y ֵʱʹ�� Lucas �����㷨������
// �粻���壬��ʹ�� Tonelli-Shanks �㷨���㡣Tonelli-Shanks �ٶȽ�����������Χ��
// ���� Lucas ������ 10 �����ϡ�

uses
  SysUtils, Classes, Contnrs, Windows, CnNativeDecl, CnPrimeNumber, CnBigNumber,
  CnPolynomial, CnPemUtils, CnBerUtils, CnMD5, CnSHA1, CnSHA2, CnSM3;

const
  // ecPublicKey �� OID
  OID_EC_PUBLIC_KEY: array [0..6] of Byte = (               // 1.2.840.10045.2.1
    $2A, $86, $48, $CE, $3D, $02, $01
  );

type
  TCnEccSignDigestType = (esdtMD5, esdtSHA1, esdtSHA256, esdtSM3);
  {* ECC ǩ����֧�ֵ�����ժҪ�㷨����֧����ժҪ�ķ�ʽ}

  ECnEccException = class(Exception);

  TCnEccPrimeType = (pt4U3, pt8U5, pt8U1);
  {* �������ͣ�mod 4 �� 3��mod 8 �� 5��mod 8 �� 1��������Բ���߷����п����� Y}

  TCnInt64EccPoint = packed record
  {* Int64 ��Χ�ڵ���Բ�����ϵĵ������ṹ}
    X: Int64;
    Y: Int64;
  end;

  TCnInt64PublicKey = TCnInt64EccPoint;
  {* Int64 ��Χ�ڵ���Բ���ߵĹ�Կ��G ����� k �κ�ĵ�����}

  TCnInt64PrivateKey = Int64;
  {* Int64 ��Χ�ڵ���Բ���ߵ�˽Կ��������� k ��}

  TCnInt64Ecc = class
  {* ����һ�������� p Ҳ���� 0 �� p - 1 �ϵ���Բ���� y^2 = x^3 + Ax + B mod p���������� Int64 ��Χ��}
  private
    FGenerator: TCnInt64EccPoint;
    FCoefficientA: Int64;
    FCoefficientB: Int64;
    FFiniteFieldSize: Int64;
    FOrder: Int64;
    FSizeUFactor: Int64;
    FSizePrimeType: TCnEccPrimeType;
  protected
    // Tonelli-Shanks ģ��������ʣ����⣬���� False ��ʾʧ�ܣ������������б�֤ P Ϊ����
    function TonelliShanks(X, P: Int64; out Y: Int64): Boolean;
    // Lucas ����ģ��������ʣ����⣬���� False ��ʾʧ�ܣ�ֻ��� P Ϊ 8*u + 1 ����ʽ
    function Lucas(X, P: Int64; out Y: Int64): Boolean;
  public
    constructor Create(A, B, FieldPrime, GX, GY, Order: Int64);
    {* ���캯�������뷽�̵� A, B �������������Ͻ� p��G �����ꡢG ��Ľ���}
    destructor Destroy; override;
    {* ��������}

    procedure MultiplePoint(K: Int64; var Point: TCnInt64EccPoint);
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure PointAddPoint(var P, Q, Sum: TCnInt64EccPoint);
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointSubPoint(var P, Q, Diff: TCnInt64EccPoint);
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(var P: TCnInt64EccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P}
    function IsPointOnCurve(var P: TCnInt64EccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    function DivisionPolynomial(Degree: Integer; outDivisionPolynomial: TCnInt64Polynomial): Boolean;
    {* �ݹ����� Degree ���ɳ�����ʽ�����ؼ����Ƿ�ɹ�}

    function PlainToPoint(Plain: Int64; var OutPoint: TCnInt64EccPoint): Boolean;
    {* ��Ҫ���ܵ�������ֵ��װ��һ�������ܵĵ㣬Ҳ����������Ϊ X �󷽳̵� Y
       ע�� Plain Ϊ 0 ʱֱ�Ӷ�Ӧ����㣬��ʹ��Բ�������� (0, ���� Y)��ʽ�ĺϷ������}

    procedure GenerateKeys(out PrivateKey: TCnInt64PrivateKey; out PublicKey: TCnInt64PublicKey);
    {* ����һ�Ը���Բ���ߵĹ�˽Կ��˽Կ��������� k����Կ�ǻ��� G ���� k �γ˷���õ��ĵ����� K}
    procedure Encrypt(var PlainPoint: TCnInt64EccPoint; PublicKey: TCnInt64PublicKey;
      var OutDataPoint1, OutDataPoint2: TCnInt64EccPoint; RandomKey: Int64 = 0);
    {* ��Կ�������ĵ� M���õ��������������ģ��ڲ����������ֵ r��Ҳ���� C1 = M + rK; C2 = r * G
      �������� RandomKey �� 0�����ڲ��������}
    procedure Decrypt(var DataPoint1, DataPoint2: TCnInt64EccPoint;
      PrivateKey: TCnInt64PrivateKey; var OutPlainPoint: TCnInt64EccPoint);
    {* ˽Կ�������ĵ㣬Ҳ���Ǽ��� C1 - k * C2 �͵õ���ԭ�ĵ� M}

    property Generator: TCnInt64EccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: Int64 read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientB: Int64 read FCoefficientB;
    {* ����ϵ�� B}
    property FiniteFieldSize: Int64 read FFiniteFieldSize;
    {* ��������Ͻ磬���� p}
    property Order: Int64 read FOrder;
    {* ����Ľ���}
  end;

  TCnEccPoint = class(TPersistent)
  {* ���������ϵ���Բ�����ϵĵ�������}
  private
    FY: TCnBigNumber;
    FX: TCnBigNumber;
    procedure SetX(const Value: TCnBigNumber);
    procedure SetY(const Value: TCnBigNumber);
  public
    constructor Create; overload;
    constructor Create(const XDec, YDec: AnsiString); overload;

    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function IsZero: Boolean;
    procedure SetZero;

    property X: TCnBigNumber read FX write SetX;
    property Y: TCnBigNumber read FY write SetY;
  end;

  TCnEccPublicKey = TCnEccPoint;
  {* ��Բ���ߵĹ�Կ��G ����� k �κ�ĵ�����}

  TCnEccPrivateKey = TCnBigNumber;
  {* ��Բ���ߵ�˽Կ��������� k ��}

  TCnEccCurveType = (ctCustomized, ctSM2, ctSM2Example192, ctSM2Example256,
    ctRfc4754ECDSAExample256, ctSecp224r1, ctSecp224k1, ctSecp256k1, ctPrime256v1);
  {* ֧�ֵ���Բ��������}

  TCnEcc = class
  {* ����һ�������� p Ҳ���� 0 �� p - 1 �ϵ���Բ���� y^2 = x^3 + Ax + B mod p}
  private
    FCoefficientB: TCnBigNumber;
    FCoefficientA: TCnBigNumber;
    FOrder: TCnBigNumber;
    FFiniteFieldSize: TCnBigNumber;
    FGenerator: TCnEccPoint;
    FSizeUFactor: TCnBigNumber;
    FSizePrimeType: TCnEccPrimeType;
    FCoFactor: Integer;
    function GetBitsCount: Integer;
  protected
    procedure CalcX3AddAXAddB(X: TCnBigNumber); // ���� X^3 + A*X + B��������� X
  public
    constructor Create; overload; virtual;
    constructor Create(Predefined: TCnEccCurveType); overload;
    constructor Create(const A, B, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); overload;
    {* ���캯�������뷽�̵� A, B �������������Ͻ� p��G �����ꡢG ��Ľ�������Ҫʮ�������ַ���}
    destructor Destroy; override;
    {* ��������}

    procedure Load(Predefined: TCnEccCurveType); overload; virtual;
    procedure Load(const A, B, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); overload; virtual;
    {* �������߲�����ע���ַ���������ʮ�����Ƹ�ʽ}

    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint);
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure PointAddPoint(P, Q, Sum: TCnEccPoint);
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointSubPoint(P, Q, Diff: TCnEccPoint);
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(P: TCnEccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P}
    function IsPointOnCurve(P: TCnEccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    function PlainToPoint(Plain: TCnBigNumber; OutPoint: TCnEccPoint): Boolean;
    {* ��Ҫ���ܵ�������ֵ��װ��һ�������ܵĵ㣬Ҳ����������Ϊ X �󷽳̵� Y
       ע�� Plain Ϊ 0 ʱֱ�Ӷ�Ӧ����㣬��ʹ��Բ�������� (0, ���� Y)��ʽ�ĺϷ������}
    function PointToPlain(Point: TCnEccPoint; OutPlain: TCnBigNumber): Boolean;
    {* �����ܳ������ĵ�⿪��һ��������ֵ��Ҳ���ǽ���� X ֵȡ��}

    procedure GenerateKeys(PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey);
    {* ����һ�Ը���Բ���ߵĹ�˽Կ��˽Կ��������� k����Կ�ǻ��� G ���� k �γ˷���õ��ĵ����� K}
    procedure Encrypt(PlainPoint: TCnEccPoint; PublicKey: TCnEccPublicKey;
      OutDataPoint1, OutDataPoint2: TCnEccPoint);
    {* ��Կ�������ĵ� M���õ��������������ģ��ڲ����������ֵ r��Ҳ���� C1 = M + rK; C2 = r * G}
    procedure Decrypt(DataPoint1, DataPoint2: TCnEccPoint;
      PrivateKey: TCnEccPrivateKey; OutPlainPoint: TCnEccPoint);
    {* ˽Կ�������ĵ㣬Ҳ���Ǽ��� C1 - k * C2 �͵õ���ԭ�ĵ� M}

    property Generator: TCnEccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: TCnBigNumber read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientB: TCnBigNumber read FCoefficientB;
    {* ����ϵ�� B}
    property FiniteFieldSize: TCnBigNumber read FFiniteFieldSize;
    {* ��������Ͻ磬���� p}
    property Order: TCnBigNumber read FOrder;
    {* ����Ľ��� N}
    property CoFactor: Integer read FCoFactor;
    {* �������� H��Ҳ�����ܵ��� mod N������ Integer ��ʾ��һ�㶼�� 1}
    property BitsCount: Integer read GetBitsCount;
    {* ����Բ���ߵ�������λ��}
  end;

  TCnEccKeyType = (cktPKCS1, cktPKCS8);
  {* ECC ��Կ�ļ���ʽ}

  TCnInt64PolynomialEccPoint = class(TPersistent)
  {* ���������ϵ���Բ�����ϵĶ���ʽ��������}
  private
    FY: TCnInt64Polynomial;
    FX: TCnInt64Polynomial;
    procedure SetX(const Value: TCnInt64Polynomial);
    procedure SetY(const Value: TCnInt64Polynomial);
  public
    constructor Create; overload;
    constructor Create(const XLowToHighCoefficients, YLowToHighCoefficients: array of const); overload;

    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function IsZero: Boolean;
    procedure SetZero;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ʽת���ַ���}

    property X: TCnInt64Polynomial read FX write SetX;
    property Y: TCnInt64Polynomial read FY write SetY;
  end;
  
  TCnInt64PolynomialEcc = class
  {* ����һ�������� p Ҳ���� 0 �� p - 1 �� n �η��ڵ���Բ���� y^2 = x^3 + Ax + B mod p���������� Int64 ��Χ��}
  private
    FGenerator: TCnInt64PolynomialEccPoint;
    FCoefficientA: Int64;
    FCoefficientB: Int64;
    FFiniteFieldSize: Int64;
    FOrder: Int64;
    FExtension: Integer;
    FPrimitive: TCnInt64Polynomial;
    procedure SetPrimitive(const Value: TCnInt64Polynomial);
//    class procedure MultiplePoint1(K: Integer; PX, PY: TCnInt64Polynomial;
//      A, B, APrime: Int64; APrimitive: TCnInt64Polynomial);
  protected

  public
    constructor Create(A, B, FieldPrime: Int64; Ext: Integer; GX, GY: array of const;
      Order: Int64; PrimitivePolynomial: array of const);
    {* ���캯�������뷽�̵� A, B �������������Ͻ� p�����������G ���������ʽ��G ��Ľ�������ԭ����ʽ}
    destructor Destroy; override;
    {* ��������}

    procedure MultiplePoint(K: Integer; Point: TCnInt64PolynomialEccPoint);
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure PointAddPoint(P, Q, Sum: TCnInt64PolynomialEccPoint);
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointSubPoint(P, Q, Diff: TCnInt64PolynomialEccPoint);
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(P: TCnInt64PolynomialEccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P}
    function IsPointOnCurve(P: TCnInt64PolynomialEccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    function DivisionPolynomial(Degree: Integer; outDivisionPolynomial: TCnInt64Polynomial): Boolean;
    {* �ݹ����� Degree ���ɳ�����ʽ�����ؼ����Ƿ�ɹ���ע�����һ���������}

    class function IsPointOnCurve2(PX, PY: TCnInt64Polynomial; A, B, APrime: Int64;
      APrimitive: TCnInt64Polynomial): Boolean;
    {* �����ֱ�ӵ��õ��жϣ�PX, PY�����Ƿ��ڱ������ϣ�
       ��Բ���߲���ֱ��ָ�� A��B�������Ͻ��뱾ԭ����ʽ���������ͽ��Լ��������}

    class procedure PointAddPoint1(PX, PY, QX, QY, SX, SY: TCnInt64Polynomial; A, B, APrime: Int64;
      APrimitive: TCnInt64Polynomial);
    {* �����ֱ�ӵ��õĵ�ӷ��������㣨PX, PY * y) �͵㣨QX, QY * y����ӣ�����ŵ���SX, SY * y������
       ��Բ���߲���ֱ��ָ�� A��B�������Ͻ��뱾ԭ����ʽ���������ͽ��Լ����������SX/SY �������� PX/PY/QX/QY}

    class procedure PointAddPoint2(PX, PY, QX, QY, SX, SY: TCnInt64Polynomial; A, B, APrime: Int64;
      APrimitive: TCnInt64Polynomial);
    {* �����ֱ�ӵ��õĵ�ӷ��������㣨PX, PY) �͵㣨QX, QY����ӣ�����ŵ���SX, SY������
       ��Բ���߲���ֱ��ָ�� A��B�������Ͻ��뱾ԭ����ʽ���������ͽ��Լ��������}

    class procedure RationalPointAddPoint(PX, PY, QX, QY: TCnInt64RationalPolynomial;
      SX, SY: TCnInt64RationalPolynomial; A, B, APrime: Int64; XEqual: Boolean = False; YEqual: Boolean = False);
    {* �����ֱ�ӵ��õ��ޱ�ԭ����ʽ�ĵ�ӷ��������㣨PX, PY * y) �͵㣨QX, QY * y����ӣ�����ŵ���SX, SY * y������
       ע���ޱ�ԭ����ʽ������£������޷�ת��Ϊ�˷����������ݰ���б�ʵ�������Ҫ�÷�ʽ��ʾ�����Ҳ�Է�ʽ��ʽ���
       �������ʽ�޷��ɿ��ж� PX �� QX��PY �� QY �Ƿ���ȣ���������������� XEqual��YEqual ��������}

    class procedure RationalMultiplePoint(K: Integer; MX, MY: TCnInt64RationalPolynomial;
      A, B, APrime: Int64);
    {* �����ֱ�ӵ��õ��ޱ�ԭ����ʽ�Ķ౶�㷽����ʹ�ÿɳ�����ʽֱ�Ӽ���㣨x, 1 * y) �� k * P ֵ��ֵ���� MX, MY * y
       ע�����ޱ�ԭ����ʽ������£������޷�ת��Ϊ�˷����������ݰ���б�ʵ�������Ҫ�÷�ʽ��ʾ�����Ҳ�Է�ʽ��ʽ���}

    class function IsRationalPointOnCurve(PX, PY: TCnInt64RationalPolynomial;
      A, B, APrime: Int64): Boolean;
    {* �����ֱ�ӵ��õ��ޱ�ԭ����ʽ���жϣ�PX, PY * y�����Ƿ��ڱ������ϣ�������û�б����õĳ���
       ��Բ���߲���ֱ��ָ�� A��B�������Ͻ��룬���豾ԭ����ʽ������ͽ��Լ��������
       ע�����ޱ�ԭ����ʽ������£������޷�ת��Ϊ�˷����������ݰ���б�ʵ�������Ҫ�÷�ʽ��ʾ}

    property Generator: TCnInt64PolynomialEccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: Int64 read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientB: Int64 read FCoefficientB;
    {* ����ϵ�� B}
    property FiniteFieldSize: Int64 read FFiniteFieldSize;
    {* ����������Ͻ磬���� p}
    property Extension: Integer read FExtension write FExtension;
    {* ��������Ĵ�����Ҳ������ p ��ָ��}
    property Order: Int64 read FOrder;
    {* ����Ľ���}
    property Primitive: TCnInt64Polynomial read FPrimitive write SetPrimitive;
    {* ��ԭ����ʽ}
  end;

function CnInt64EccPointToString(var P: TCnInt64EccPoint): string;
{* ��һ�� TCnInt64EccPoint ������ת��Ϊ�ַ���}

function CnInt64EccSchoof(A, B, Q: Int64): Int64;
{* �� Schoof �㷨����Բ���� y^2 = x^3 + Ax + B ������ Fq �ϵĵ�����}

function CnEccPointToString(const P: TCnEccPoint): string;
{* ��һ�� TCnEccPoint ������ת��Ϊʮ�����ַ���}

function CnEccPointToHex(const P: TCnEccPoint): string;
{* ��һ�� TCnEccPoint ������ת��Ϊʮ�������ַ���}

function CnInt64EccGenerateParams(var FiniteFieldSize, CoefficientA, CoefficientB,
  GX, GY, Order: Int64): Boolean;
{* ������Բ���� y^2 = x^3 + Ax + B mod p �ĸ�����������������ʵ�֣�ֻ��������ϵ����С��}

function CnInt64EccDiffieHellmanGenerateOutKey(Ecc: TCnInt64Ecc; SelfPrivateKey: TCnInt64PrivateKey;
  out PublicKey: TCnInt64PublicKey): Boolean;
{* ��������ѡ�������� PrivateKey ���� ECDH ��ԿЭ�̵������Կ��
   ���� OutPublicKey = SelfPrivateKey * G}

function CnInt64EccDiffieHellmanComputeKey(Ecc: TCnInt64Ecc; SelfPrivateKey: TCnInt64PrivateKey;
  var OtherPublicKey: TCnInt64PublicKey; var SharedSecretKey: TCnInt64PublicKey): Boolean;
{* ���ݶԷ����͵� ECDH ��ԿЭ�̵������Կ�������ɹ��ϵ���Կ��
   ���� SecretKey = SelfPrivateKey * OtherPublicKey}

function CnInt64EccPointsEqual(var P1, P2: TCnInt64EccPoint): Boolean;
{* �ж����� TCnInt64EccPoint ���Ƿ����}

function CnEccPointsEqual(P1, P2: TCnEccPoint): Boolean;
{* �ж����� TCnEccPoint ���Ƿ����}

function CnEccDiffieHellmanGenerateOutKey(Ecc: TCnEcc; SelfPrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey): Boolean;
{* ��������ѡ�������� PrivateKey ���� ECDH ��ԿЭ�̵������Կ��
   ���� PublicKey = SelfPrivateKey * G}

function CnEccDiffieHellmanComputeKey(Ecc: TCnEcc; SelfPrivateKey: TCnEccPrivateKey;
  OtherPublicKey: TCnEccPublicKey; SharedSecretKey: TCnEccPublicKey): Boolean;
{* ���ݶԷ����͵� ECDH ��ԿЭ�̵������Կ�������ɹ��ϵ���Կ�㣬һ���õ�� X ����������Կ
   ���� SecretKey = SelfPrivateKey * OtherPublicKey}

// ======================= ��Բ������Կ PEM ��дʵ�� ===========================

function CnEccLoadKeysFromPem(const PemFileName: string; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; out CurveType: TCnEccCurveType;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5; const Password: string = ''): Boolean;
{* �� PEM ��ʽ�ļ��м��ع�˽Կ���ݣ���ĳԿ����Ϊ��������}

function CnEccSaveKeysToPem(const PemFileName: string; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; CurveType: TCnEccCurveType;
  KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5; const Password: string = ''): Boolean;
{* ����˽Կд�� PEM ��ʽ�ļ��У������Ƿ�ɹ�}

function CnEccLoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnEccPublicKey; out CurveType: TCnEccCurveType;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5; const Password: string = ''): Boolean;
{* �� PEM ��ʽ�ļ��м��ع�Կ���ݣ������Ƿ�ɹ�}

function CnEccSavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnEccPublicKey; CurveType: TCnEccCurveType;
  KeyType: TCnEccKeyType = cktPKCS1; KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5; const Password: string = ''): Boolean;
{* ����Կд�� PEM ��ʽ�ļ��У������Ƿ�ɹ�}

// ========================= ECC �ļ�ǩ������֤ʵ�� ============================
// �����ļ��ֿ�ʵ������Ϊ�����ļ�ժҪʱ֧�ִ��ļ����� FileStream �Ͱ汾��֧��
// ע�� ECC ǩ����֤�������� RSA �������ܺ�ȶԼ��ܽ�ȥ�� Hash ֵ
// ���Ǳȶ��м����Ĵ�����Ecc ǩ�����ݲ���������ǩ��ʱ��ԭԭʼ Hash ֵ

function CnEccSignFile(const InFileName, OutSignFileName: string; Ecc: TCnEcc;
  PrivateKey: TCnEccPrivateKey; SignType: TCnEccSignDigestType = esdtMD5): Boolean; overload;
{* ��˽Կǩ��ָ���ļ���Ecc ����ҪԤ��ָ�����ߡ�
   ʹ��ָ������ժҪ�㷨���ļ����м���õ�ɢ��ֵ��
   ԭʼ�Ķ�����ɢ��ֵ���� BER ������ PKCS1 ��������˽Կ����}

function CnEccSignFile(const InFileName, OutSignFileName: string; CurveType: TCnEccCurveType;
  PrivateKey: TCnEccPrivateKey; SignType: TCnEccSignDigestType = esdtMD5): Boolean; overload;
{* ��˽Կǩ��ָ���ļ���ʹ��Ԥ�������ߡ�
   ʹ��ָ������ժҪ�㷨���ļ����м���õ�ɢ��ֵ��
   ԭʼ�Ķ�����ɢ��ֵ���� BER ������ PKCS1 ��������˽Կ����}

function CnEccVerifyFile(const InFileName, InSignFileName: string; Ecc: TCnEcc;
  PublicKey: TCnEccPublicKey; SignType: TCnEccSignDigestType = esdtMD5): Boolean; overload;
{* �ù�Կ��ǩ��ֵ��ָ֤���ļ���Ҳ����ָ������ժҪ�㷨���ļ����м���õ�ɢ��ֵ��
   ���ù�Կ����ǩ�����ݲ��⿪ PKCS1 �����ٽ⿪ BER ����õ�ɢ���㷨��ɢ��ֵ��
   ���ȶ�����������ɢ��ֵ�Ƿ���ͬ��������֤�Ƿ�ͨ����
   Ecc ����ҪԤ��ָ�����ߡ�}

function CnEccVerifyFile(const InFileName, InSignFileName: string; CurveType: TCnEccCurveType;
  PublicKey: TCnEccPublicKey; SignType: TCnEccSignDigestType = esdtMD5): Boolean; overload;
{* ��Ԥ���������빫Կ��ǩ��ֵ��ָ֤���ļ���Ҳ����ָ������ժҪ�㷨���ļ����м���õ�ɢ��ֵ��
   ���ù�Կ����ǩ�����ݲ��⿪ PKCS1 �����ٽ⿪ BER ����õ�ɢ���㷨��ɢ��ֵ��
   ���ȶ�����������ɢ��ֵ�Ƿ���ͬ��������֤�Ƿ�ͨ��}

function CnEccSignStream(InStream: TMemoryStream; OutSignStream: TMemoryStream;
  Ecc: TCnEcc; PrivateKey: TCnEccPrivateKey;
  SignType: TCnEccSignDigestType = esdtMD5): Boolean; overload;
{* ��˽Կǩ��ָ���ڴ�����Ecc ����ҪԤ��ָ������}

function CnEccSignStream(InStream: TMemoryStream; OutSignStream: TMemoryStream;
  CurveType: TCnEccCurveType; PrivateKey: TCnEccPrivateKey;
  SignType: TCnEccSignDigestType = esdtMD5): Boolean; overload;
{* ��Ԥ����������˽Կǩ��ָ���ڴ���}

function CnEccVerifyStream(InStream: TMemoryStream; InSignStream: TMemoryStream;
  Ecc: TCnEcc; PublicKey: TCnEccPublicKey;
  SignType: TCnEccSignDigestType = esdtMD5): Boolean; overload;
{* �ù�Կ��ǩ��ֵ��ָ֤���ڴ�����Ecc ����ҪԤ��ָ������}

function CnEccVerifyStream(InStream: TMemoryStream; InSignStream: TMemoryStream;
  CurveType: TCnEccCurveType; PublicKey: TCnEccPublicKey;
  SignType: TCnEccSignDigestType = esdtMD5): Boolean; overload;
{* ��Ԥ���������빫Կ��ǩ��ֵ��ָ֤���ڴ���}

// ===================== ������������Ķ���ʽ��Բ�������� ======================

function CnInt64PolynomialEccPointToString(const P: TCnInt64PolynomialEccPoint): string;
{* ��һ�� TCnInt64PolynomialEccPoint ������ת��Ϊ����ʽ�ַ���}

function CnInt64PolynomialEccPointsEqual(P1, P2: TCnInt64PolynomialEccPoint): Boolean;
{* �ж���������ʽ���Ƿ����}

// ============================= ������������ ==================================

function CheckEccPublicKey(Ecc: TCnEcc; PublicKey: TCnEccPublicKey): Boolean;
{* ����������ߵ� PublicKey �Ƿ�Ϸ�}

function GetCurveTypeFromOID(Data: PAnsiChar; DataLen: Cardinal): TCnEccCurveType;
{* ͨ�� BER �е�ԭʼ OID ���ݣ�����ͷ����ȡ��Ӧ����������}

function GetOIDFromCurveType(Curve: TCnEccCurveType; out OIDAddr: Pointer): Integer;
{* �����������ͷ����� OID ��ַ�볤�ȣ����ʹ�ú������ͷ�}

function ReadEccPublicKeyFromBitStringNode(BitStringNode: TCnBerReadNode;
  PublicKey: TCnEccPublicKey): Boolean;
{* ��ȡ BER �ڵ� BITSTRING �е� ECC ��Կ�������Ƿ�ɹ�}

function WriteEccPublicKeyToBitStringNode(Writer: TCnBerWriter;
  ParentNode: TCnBerWriteNode; PublicKey: TCnEccPublicKey): Boolean;
{* �� ECC ��Կд�� BER �е� BITSTRING �ڵ�}

function GetEccDigestNameFromSignDigestType(Digest: TCnEccSignDigestType): string;
{* ��ǩ��ɢ���㷨ö��ֵ��ȡ������}

procedure CnInt64GenerateGaloisDivisionPolynomials(A, B, Prime: Int64; MaxDegree: Integer;
  PolynomialList: TObjectList);
{* �������� 0 �� MaxDegree �׵Ŀɳ�����ʽ��Ҫȷ���� Int64PolynomialGaloisCalcDivisionPolynomial
   �ĵݹ�ʵ����ȫ��ͬ}

implementation

resourcestring
  SCnEccErrorCurveType = 'Invalid Curve Type.';
  SCnEccErrorKeyData = 'Invalid Key or Data.';

type
  TCnEccPredefinedHexParams = packed record
    P: AnsiString;
    A: AnsiString;
    B: AnsiString;
    X: AnsiString;
    Y: AnsiString;
    N: AnsiString;
    H: AnsiString;
  end;

const
  ECC_PRE_DEFINED_PARAMS: array[TCnEccCurveType] of TCnEccPredefinedHexParams = (
    (P: ''; A: ''; B: ''; X: ''; Y: ''; N: ''; H: ''),
    ( // SM2
      P: 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF';
      A: 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC';
      B: '28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93';
      X: '32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7';
      Y: 'BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0';
      N: 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123';
      H: '01'
    ),
    ( // SM2 Example 192
      P: 'BDB6F4FE3E8B1D9E0DA8C0D46F4C318CEFE4AFE3B6B8551F';
      A: 'BB8E5E8FBC115E139FE6A814FE48AAA6F0ADA1AA5DF91985';
      B: '1854BEBDC31B21B7AEFC80AB0ECD10D5B1B3308E6DBF11C1';
      X: '4AD5F7048DE709AD51236DE65E4D4B482C836DC6E4106640';
      Y: '02BB3A02D4AAADACAE24817A4CA3A1B014B5270432DB27D2';
      N: 'BDB6F4FE3E8B1D9E0DA8C0D40FC962195DFAE76F56564677';
      H: '01'
    ),
    ( // SM2 Example 256
      P: '8542D69E4C044F18E8B92435BF6FF7DE457283915C45517D722EDB8B08F1DFC3';
      A: '787968B4FA32C3FD2417842E73BBFEFF2F3C848B6831D7E0EC65228B3937E498';
      B: '63E4C6D3B23B0C849CF84241484BFE48F61D59A5B16BA06E6E12D1DA27C5249A';
      X: '421DEBD61B62EAB6746434EBC3CC315E32220B3BADD50BDC4C4E6C147FEDD43D';
      Y: '0680512BCBB42C07D47349D2153B70C4E5D7FDFCBFA36EA1A85841B9E46E09A2';
      N: '8542D69E4C044F18E8B92435BF6FF7DD297720630485628D5AE74EE7C32E79B7';
      H: '01'
    ),
    ( // RFC 4754 ECDSA Example 256
      P: 'FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF';
      A: '-03';
      B: '5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B';
      X: '6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296';
      Y: '4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5';
      N: 'FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551';
      H: '01'
    ),
    ( // ctSecp224r1
      P: '00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000001';
      A: '00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFE';
      B: '00B4050A850C04B3ABF54132565044B0B7D7BFD8BA270B39432355FFB4';
      X: 'B70E0CBD6BB4BF7F321390B94A03C1D356C21122343280D6115C1D21';
      Y: 'BD376388B5F723FB4C22DFE6CD4375A05A07476444D5819985007E34';
      N: '00FFFFFFFFFFFFFFFFFFFFFFFFFFFF16A2E0B8F03E13DD29455C5C2A3D';
      H: '01'
    ),
    ( // ctSecp224k1
      P: '00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFE56D';
      A: '00';
      B: '05';
      X: 'A1455B334DF099DF30FC28A169A467E9E47075A90F7E650EB6B7A45C';
      Y: '7E089FED7FBA344282CAFBD6F7E319F7C0B0BD59E2CA4BDB556D61A5';
      N: '010000000000000000000000000001DCE8D2EC6184CAF0A971769FB1F7';
      H: '01'
    ),
    ( // ctSecp256k1
      P: 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
      A: '00';
      B: '07';
      X: '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798';
      Y: '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8';
      N: 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141';
      H: '01'
    ),
    ( // ctPrime256v1
      P: 'FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF';
      A: 'FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC';
      B: '5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B';
      X: '6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296';
      Y: '4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5';
      N: 'FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551';
      H: '01'
    )
  );

  PEM_EC_PARAM_HEAD = '-----BEGIN EC PARAMETERS-----';
  PEM_EC_PARAM_TAIL = '-----END EC PARAMETERS-----';

  PEM_EC_PRIVATE_HEAD = '-----BEGIN EC PRIVATE KEY-----';
  PEM_EC_PRIVATE_TAIL = '-----END EC PRIVATE KEY-----';

  PEM_EC_PUBLIC_HEAD = '-----BEGIN PUBLIC KEY-----';
  PEM_EC_PUBLIC_TAIL = '-----END PUBLIC KEY-----';

  // ECC ˽Կ�ļ��������ڵ�� BER Tag Ҫ������� TypeMask
  ECC_PRIVATEKEY_TYPE_MASK  = $80;

  // ��Կ�Ĵ洢��ʽ
  EC_PUBLICKEY_COMPRESSED1  = 02;
  EC_PUBLICKEY_COMPRESSED2  = 03;
  EC_PUBLICKEY_UNCOMPRESSED = 04;

  // Ԥ�������Բ�������͵� OID ������󳤶�
  EC_CURVE_TYPE_OID_MAX_LENGTH = 8;

  OID_ECPARAM_CURVE_TYPE_SECP256K1: array[0..4] of Byte = ( // 1.3.132.0.10
    $2B, $81, $04, $00, $0A
  );

  OID_ECPARAM_CURVE_TYPE_SM2: array[0..7] of Byte = (       // 1.2.156.10197.301
    $2A, $81, $1C, $CF, $55, $01, $82, $2D
  );

  OID_ECPARAM_CURVE_TYPE_PRIME256V1: array[0..7] of Byte = (  // 1.2.840.10045.3.1.7
    $2A, $86, $48, $CE, $3D, $03, $01, $07
  );

var
  FEccBigNumberPool: TCnBigNumberPool = nil;
  FEccInt64PolynomialPool: TCnInt64PolynomialPool = nil;

function Min(A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

{* ȡ X ����߸� W λ������ W �� N �� BitsCount���ú�������ǩ����ǩ
   ע������ SM2 �е�ͬ���������ܲ�ͬ}
procedure BuildShortXValue(X: TCnBigNumber; Order: TCnBigNumber);
var
  W: Integer;
begin
  W := X.GetBitsCount - Order.GetBitsCount;
  if W > 0 then
    BigNumberShiftRight(X, X, W);
end;

// ��һ�� TCnInt64EccPoint ������ת��Ϊ�ַ���
function CnInt64EccPointToString(var P: TCnInt64EccPoint): string;
begin
  Result := Format('%d,%d', [P.X, P.Y]);
end;

// ��һ�� TCnEccPoint ������ת��Ϊʮ�����ַ���
function CnEccPointToString(const P: TCnEccPoint): string;
begin
  Result := Format('%s,%s', [P.X.ToDec, P.Y.ToDec]);
end;

// ��һ�� TCnEccPoint ������ת��Ϊʮ�������ַ���
function CnEccPointToHex(const P: TCnEccPoint): string;
begin
  Result := Format('%s,%s', [P.X.ToHex, P.Y.ToHex]);
end;

// �ж��������Ƿ����
function CnEccPointsEqual(P1, P2: TCnEccPoint): Boolean;
begin
  if P1 = P2 then
  begin
    Result := True;
    Exit;
  end;
  Result := (BigNumberCompare(P1.X, P2.X) = 0) and (BigNumberCompare(P1.Y, P2.Y) = 0);
end;

function CnInt64EccPointsEqual(var P1, P2: TCnInt64EccPoint): Boolean;
begin
  Result := (P1.X = P2.X) and (P1.Y = P2.Y);
end;

// ������Բ���� y^2 = x^3 + Ax + B mod p �ĸ�������������ʵ��
function CnInt64EccGenerateParams(var FiniteFieldSize, CoefficientA, CoefficientB,
  GX, GY, Order: Int64): Boolean;
var
  I: Integer;
  N: Int64;
  P: TCnInt64EccPoint;
  Ecc64: TCnInt64Ecc;
begin
  // ���裺���ѡ���������� p��������� a��b���� SEA �㷨��������ߵĽ� N
  // �ж� N �Ǵ���������һ�������֮һ�Ǵ�������Ȼ�������������Ϊѭ����Ⱥ�Ľ� n
  // �ٸ��� n Ѱ�һ��� G �����ꡣ��� n �͵��� N ������������� G ���ѡ���С�

  repeat
    // FiniteFieldSize := CnGenerateUInt32Prime; // ����С�������������Ҳ����̫С
    Randomize;
    I := Trunc(Random * (High(CN_PRIME_NUMBERS_SQRT_UINT32) - 100)) + 100;
    FiniteFieldSize := CN_PRIME_NUMBERS_SQRT_UINT32[I];
    CoefficientA := Trunc(Random * 16);
    CoefficientB := Trunc(Random * 256);
    N := 1; // 0,0 ��Ȼ����

    // A��B ���Ƚ�С�����ﲻ�õ������
    if (4 * CoefficientA * CoefficientA * CoefficientA - 27 * CoefficientB * CoefficientB)
      mod FiniteFieldSize = 0 then
      Continue;

    GX := 0;
    GY := 0;

    // ���������Բ���ߵĽף����� SEA��ԭ��ֻ������������ٷ�����������õ¹�ʽ
    // N := 1 + P + ���е����õ�((x^3+ax+b)/p)֮�ͣ����� X �� 0 �� P - 1
    Inc(N, FiniteFieldSize);
    for I := 0 to FiniteFieldSize - 1 do
    begin
      // ������� Int64 ��ת��һ�£����� I �����η����� Integer �����
      N := N + CnInt64Legendre(Int64(I) * Int64(I) * Int64(I) + CoefficientA * I + CoefficientB, FiniteFieldSize);
    end;
  until CnInt64IsPrime(N);

  // Ȼ�������һ�� X �� Y
  Ecc64 := TCnInt64Ecc.Create(CoefficientA, CoefficientB, FiniteFieldSize, 0, 0, FiniteFieldSize);
  repeat
    P.X := Trunc(Random * (FiniteFieldSize - 1)) + 1;
    for I := 0 to FiniteFieldSize - 1 do
    begin
      P.Y := I;
      if Ecc64.IsPointOnCurve(P) then
      begin
        GX := P.X;
        GY := P.Y;
        Break;
      end;
    end;
  until (GX > 0) and (GY > 0);
  Ecc64.Free;

//    ���´�������ٷ�����֤ N �Ƿ���ȷ��ĿǰС��Χ������������û��
//    N := 1;
//    Ecc64 := TCnInt64Ecc.Create(CoefficientA, CoefficientB, FiniteFieldSize, 0, 0, FiniteFieldSize);
//    for I := 0 to FiniteFieldSize - 1 do
//    begin
//      for J := 0 to FiniteFieldSize - 1 do
//      begin
//        P.X := I;
//        P.Y := J;
//        if Ecc64.IsPointOnCurve(P) then
//        begin
//          Inc(N);
//          if (GX = 0) or (GY = 0) then // ��һ������ľ͵�������
//          begin
//            GX := P.X;
//            GY := P.Y;
//          end;
//
//          if P.Y > 0 then
//          begin
//            P.Y := FiniteFieldSize - P.Y;
//            if Ecc64.IsPointOnCurve(P) then
//              Inc(N);
//          end;
//
//          // ��� X �Ѿ������ˣ�ÿ�� X �����ж������� Y��
//          Break;
//        end;
//      end;
//      // Break ���ˣ�������һ�� X ��ѭ��
//    end;

    // N Ϊ������Բ���ߵĽ�

  Order := N;
  Result := True;
end;

// �� X ��� M ��ģ��Ԫ��Ҳ����ģ��Ԫ Y������ (X * Y) mod M = 1����ΧΪ Int64��Ҳ����˵֧�� X Ϊ��ֵ
function Int64ModularInverse(X: Int64; Modulus: Int64): Int64;
var
  Neg: Boolean;
begin
  Neg := False;
  if X < 0 then
  begin
    X := -X;
    Neg := True;
  end;

  // ������ģ��Ԫ������������ģ��Ԫ�ĸ�ֵ����ֵ�������ټ� Modulus
  Result := CnInt64ModularInverse(X, Modulus);
  if Neg and (Result > 0) then
    Result := -Result;

  if Result < 0 then
    Result := Result + Modulus;
end;

function RandomInt64LessThan(HighValue: Int64): Int64;
var
  Hi, Lo: Cardinal;
begin
  Randomize;
  Hi := Trunc(Random * High(Integer) - 1) + 1;   // Int64 ���λ������ 1�����⸺��
  Randomize;
  Lo := Trunc(Random * High(Cardinal) - 1) + 1;
  Result := (Int64(Hi) shl 32) + Lo;
  Result := Result mod HighValue;
end;

{ TCnInt64Ecc }

constructor TCnInt64Ecc.Create(A, B, FieldPrime, GX, GY, Order: Int64);
var
  R: Int64;
begin
  inherited Create;

  // ����籣֤ Order Ϊ����
  if not CnInt64IsPrime(FieldPrime) then // or not CnInt64IsPrime(Order) then
    raise ECnEccException.Create('Infinite Field must be a Prime Number.');

  if not (GX >= 0) and (GX < FieldPrime) or
    not (GY >= 0) and (GY < FieldPrime) then
    raise ECnEccException.Create('Generator Point must be in Infinite Field.');

  // Ҫȷ�� 4*a^3+27*b^2 <> 0
  if 4 * A * A * A + 27 * B * B = 0 then
    raise ECnEccException.Create('Error: 4 * A^3 + 27 * B^2 = 0');

  FCoefficientA := A;
  FCoefficientB := B;
  FFiniteFieldSize := FieldPrime;
  FGenerator.X := GX;
  FGenerator.Y := GY;
  FOrder := Order;

  R := FFiniteFieldSize mod 4;
  if R = 3 then  // RFC 5639 Ҫ�� p ���� 4u + 3 ����ʽ�Ա㷽��ؼ��� Y������������δ��
  begin
    FSizePrimeType := pt4U3;
    FSizeUFactor := FFiniteFieldSize div 4;
  end
  else
  begin
    R := FFiniteFieldSize mod 8;
    if R = 1 then
    begin
      FSizePrimeType := pt8U1;
      FSizeUFactor := FFiniteFieldSize div 8;
    end
    else if R = 5 then
    begin
      FSizePrimeType := pt8U5;
      FSizeUFactor := FFiniteFieldSize div 8;
    end
    else
      raise ECnEccException.Create('Invalid Finite Field Size.');
  end;
end;

procedure TCnInt64Ecc.Decrypt(var DataPoint1, DataPoint2: TCnInt64EccPoint;
  PrivateKey: TCnInt64PrivateKey; var OutPlainPoint: TCnInt64EccPoint);
var
  P: TCnInt64EccPoint;
begin
  P := DataPoint2;
  MultiplePoint(PrivateKey, P);
  PointSubPoint(DataPoint1, P, OutPlainPoint);
end;

destructor TCnInt64Ecc.Destroy;
begin

  inherited;
end;

function TCnInt64Ecc.DivisionPolynomial(Degree: Integer;
  outDivisionPolynomial: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialGaloisCalcDivisionPolynomial(FCoefficientA, FCoefficientB,
    Degree, outDivisionPolynomial, FFiniteFieldSize);
end;

procedure TCnInt64Ecc.Encrypt(var PlainPoint: TCnInt64EccPoint;
  PublicKey: TCnInt64PublicKey; var OutDataPoint1,
  OutDataPoint2: TCnInt64EccPoint; RandomKey: Int64);
begin
  if RandomKey = 0 then
  begin
    Randomize;
    RandomKey := Trunc(Random * (FOrder - 1)) + 1; // �� 0 �󵫱Ȼ����С�������
  end;

  if RandomKey mod FOrder = 0 then
    raise ECnEccException.CreateFmt('Error RandomKey %d for Order.', [RandomKey]);

  // M + rK;
  OutDataPoint1 := PublicKey;
  MultiplePoint(RandomKey, OutDataPoint1);
  PointAddPoint(PlainPoint, OutDataPoint1, OutDataPoint1);

  // r * G
  OutDataPoint2 := FGenerator;
  MultiplePoint(RandomKey, OutDataPoint2);
end;

procedure TCnInt64Ecc.GenerateKeys(out PrivateKey: TCnInt64PrivateKey;
  out PublicKey: TCnInt64PublicKey);
begin
  Randomize;
  PrivateKey := Trunc(Random * (FOrder - 1)) + 1; // �� 0 �󵫱Ȼ����С�������
  PublicKey := FGenerator;
  MultiplePoint(PrivateKey, PublicKey);           // ����� PrivateKey ��
end;

function TCnInt64Ecc.IsPointOnCurve(var P: TCnInt64EccPoint): Boolean;
var
  Y2, X3, AX, B: Int64;
begin
  // ���� (Y^2 - X^3 - A*X - B) mod p �Ƿ���� 0��Ӧ�÷�����
  // Ҳ���Ǽ���(Y^2 mod p - X^3 mod p - A*X mod p - B mod p) mod p
  Y2 := MontgomeryPowerMod(P.Y, 2, FFiniteFieldSize);
  X3 := MontgomeryPowerMod(P.X, 3, FFiniteFieldSize);
  AX := Int64MultipleMod(FCoefficientA, P.X, FFiniteFieldSize);
  B := FCoefficientB mod FFiniteFieldSize;

  Result := ((Y2 - X3 - AX - B) mod FFiniteFieldSize) = 0;
end;

function TCnInt64Ecc.Lucas(X, P: Int64; out Y: Int64): Boolean;
var
  G, U, V, Z: Int64;
begin
  Result := False;
  G := X;

  while True do
  begin
    // ���ȡ X
    X := RandomInt64LessThan(P);

    // �ټ��� Lucas �����е� V�����±� K Ϊ (P+1)/2
    CnLucasSequenceMod(X, G, (P + 1) shr 1, P, U, V);

    // V ż��ֱ������ 1 �� mod P��V ����� P ������ 1
    if (V and 1) = 0 then
      Z := (V shr 1) mod P
    else
      Z := (V + P) shr 1;
    // Z := (V div 2) mod P;

    if Int64MultipleMod(Z, Z, P) = G then
    begin
      Y := Z;
      Result := True;
      Exit;
    end
    else if (U > 1) and (U < P - 1) then
      Break;
  end;
end;

procedure TCnInt64Ecc.MultiplePoint(K: Int64; var Point: TCnInt64EccPoint);
var
  E, R: TCnInt64EccPoint;
begin
  if K < 0 then
  begin
    K := -K;
    PointInverse(Point);
  end;

  if K = 0 then
  begin
    Point.X := 0;
    Point.Y := 0;
    Exit;
  end;

  if K > 1 then
  begin
    R.X := 0;
    R.Y := 0;
    E := Point;

    while K <> 0 do
    begin
      if (K and 1) <> 0 then
        PointAddPoint(R, E, R);

      PointAddPoint(E, E, E);
      K := K shr 1;
    end;

    Point := R;
  end;
end;

function TCnInt64Ecc.PlainToPoint(Plain: Int64;
  var OutPoint: TCnInt64EccPoint): Boolean;
var
  X3, AX, B, G, Y, Z: Int64;
begin
  Result := False;
  if Plain = 0 then
  begin
    OutPoint.X := 0;
    OutPoint.Y := 0;
    Result := True;
    Exit;
  end;

  // �ⷽ���� Y�� (y^2 - (Plain^3 + A * Plain + B)) mod p = 0
  // ע�� Plain ���̫�󣬼�������л���������ô���ֻ���÷����ɡ�
  // (Y^2 mod p - Plain ^ 3 mod p - A * Plain mod p - B mod p) mod p = 0;
  X3 := MontgomeryPowerMod(Plain, 3, FFiniteFieldSize);
  AX := Int64MultipleMod(FCoefficientA, Plain, FFiniteFieldSize);
  B := FCoefficientB mod FFiniteFieldSize;

  G := (X3 + AX + B) mod FFiniteFieldSize; // ���������Ļ�
  if G = 0 then   // ��� X^3 + AX + B Ϊ 0����ֱ�ӷ��� (Plain, 0) ���ҿ϶��������߷���
  begin
    OutPoint.X := Plain;
    OutPoint.Y := 0;
    Result := True;
    Exit;
  end;

  // ��Ϊ Y^2 = N * p + B Ҫ���ҳ� N ���ұ�Ϊ��ȫƽ���������� Y ����ֵ
  // Ҫ��Ӳ�� N �� 0 ��ʼ�� 1 ���������������Ƿ���ȫƽ������������������ô��
  // ���ö���ʣ������ģ�Ŀ����󷨣��������� P �����Է����֣�

  case FSizePrimeType of
  pt4U3:  // �ο��ԡ�SM2��Բ���߹�Կ�����㷨����¼ B �еġ�ģ����ƽ��������⡱һ��
    begin
      Y := MontgomeryPowerMod(G, FSizeUFactor + 1, FFiniteFieldSize);
      Z := Int64MultipleMod(Y, Y, FFiniteFieldSize);
      if Z = G then
      begin
        OutPoint.X := Plain;
        OutPoint.Y := Y;
        Result := True;
      end;
    end;
  pt8U5:  // �ο��ԡ�SM2��Բ���߹�Կ�����㷨����¼ B �еġ�ģ����ƽ��������⡱һ��
    begin
      Z := MontgomeryPowerMod(G, 2 * FSizeUFactor + 1, FFiniteFieldSize);
      if Z = 1 then
      begin
        Y := MontgomeryPowerMod(G, FSizeUFactor + 1, FFiniteFieldSize);
        OutPoint.X := Plain;
        OutPoint.Y := Y;
        Result := True;
      end
      else
      begin
        Z := FFiniteFieldSize - Z;
        if Z = 1 then
        begin
          // y = (2g * (4g)^u) mod p = (2g mod p * (4^u * g^u) mod p) mod p
          Y := (Int64MultipleMod(G, 2, FFiniteFieldSize) *
            MontgomeryPowerMod(4, FSizeUFactor, FFiniteFieldSize) *
            MontgomeryPowerMod(G, FSizeUFactor, FFiniteFieldSize)) mod FFiniteFieldSize;
          OutPoint.X := Plain;
          OutPoint.Y := Y;
          Result := True;
        end;
      end;
    end;
  pt8U1: // �ο��� wikipedia �ϵ� Tonelli-Shanks ����ʣ������㷨�Լ� IEEE P1363 ��� Lucas �����㷨
    begin
{$IFDEF USE_LUCAS}
      // ��SM2��Բ���߹�Կ�����㷨����¼ B �еġ�ģ����ƽ��������⡱һ�� Lucas ���м�������Ľ��ʵ�ڲ���
      if Lucas(G, FFiniteFieldSize, Y) then
      begin
        OutPoint.X := Plain;
        OutPoint.Y := Y;
        Result := True;
      end;
{$ELSE}
      //  ���� Tonelli-Shanks �㷨����ģ��������ʣ����⣬���ڲ���Ҫͨ�����õ·����ж�����Ƿ���ڣ������������ѭ��
      if TonelliShanks(G, FFiniteFieldSize, Y) then
      begin
        OutPoint.X := Plain;
        OutPoint.Y := Y;
        Result := True;
      end;
{$ENDIF}
    end;
  end;
end;

procedure TCnInt64Ecc.PointAddPoint(var P, Q, Sum: TCnInt64EccPoint);
var
  K, X, Y, PX: Int64;
begin
  K := 0;
  if (P.X = 0) and (P.Y = 0) then
  begin
    Sum := Q;
    Exit;
  end
  else if (Q.X = 0) and (Q.Y = 0) then
  begin
    Sum := P;
    Exit;
  end
  else if (P.X = Q.X) and (P.Y = Q.Y) then
  begin
    // ��������ͬһ���㣬����б��Ϊ�����󵼣�3 * X^2 + A / (2 * Y) ���� Y = 0 ��ֱ��������Զ 0��
    X := 3 * P.X * P.X + FCoefficientA;
    Y := 2 * P.Y;

    if Y = 0 then
    begin
      Sum.X := 0;
      Sum.Y := 0;
    end;

    Y := Int64ModularInverse(Y, FFiniteFieldSize);
    K := Int64MultipleMod(X, Y, FFiniteFieldSize); // �õ�б��
  end
  else if (P.X = Q.X) and ((P.Y = -Q.Y) or (P.Y + Q.Y = FFiniteFieldSize)) then        // P = -Q
  begin
    Sum.X := 0;
    Sum.Y := 0;
    Exit;
  end
  else if P.X <> Q.X then
  begin
    // б�� K := ((Q.Y - P.Y) / (Q.X - P.X)) mod p
    Y := Q.Y - P.Y;
    X := Q.X - P.X;

    // Y/X = Y*X^-1 = Y * (X ��� p ����Ԫ)
    X := Int64ModularInverse(X, FFiniteFieldSize);
    K := Int64MultipleMod(Y, X, FFiniteFieldSize); // �õ�б��
  end
  else if P.Y <> Q.Y then
  begin
    // P��Q ���� X ��ͬ��Y ��ͬ���ֲ�����Ԫ���������ӣ������ϲ������
    raise ECnEccException.CreateFmt('Can NOT Calucate %d,%d + %d,%d', [P.X, P.Y, Q.X, Q.Y]);
  end;

  // Xsum = (K^2 - X1 - X2) mod p
  X := K * K - P.X - Q.X;
  while X < 0 do
    X := X + FFiniteFieldSize;
  PX := P.X; // ��� Sum �� P ��ͬһ����Ҫ���� P.X �������������ȴ��� P.X
  if X < 0 then
  begin
    X := -X;
    Sum.X := X mod FFiniteFieldSize;
    if Sum.X > 0 then                      // ��� X �պ����������� 0
      Sum.X := FFiniteFieldSize - Sum.X;
  end
  else
    Sum.X := X mod FFiniteFieldSize;

  // Ysum = (K * (X1 - Xsum) - Y1) mod p  ע��Ҫȡ��
  //   Ҳ = (K * (X2 - Xsum) - Y2) mod p  ע��Ҫȡ��
  X := PX - Sum.X;
  Y := K * X - P.Y;
  if Y < 0 then
  begin
    Y := -Y;
    Sum.Y := Y mod FFiniteFieldSize;
    if Sum.Y > 0 then                      // ��� Y �պ����������� 0
      Sum.Y := FFiniteFieldSize - Sum.Y;
  end
  else
    Sum.Y := Y mod FFiniteFieldSize;
end;

procedure TCnInt64Ecc.PointInverse(var P: TCnInt64EccPoint);
begin
  // P.Y := -P.Y mod p ע������ĸ�ֵȡģ������ Delphi ��ȡ����ȡģ�ٱ为
  P.Y := FFiniteFieldSize - (P.Y mod FFiniteFieldSize);
end;

procedure TCnInt64Ecc.PointSubPoint(var P, Q, Diff: TCnInt64EccPoint);
var
  Inv: TCnInt64EccPoint;
begin
  Inv.X := Q.X;
  Inv.Y := Q.Y;
  PointInverse(Inv);
  PointAddPoint(P, Inv, Diff);
end;

// ��������ѡ�������� PrivateKey ���� ECDH ��ԿЭ�̵������Կ��
function CnInt64EccDiffieHellmanGenerateOutKey(Ecc: TCnInt64Ecc; SelfPrivateKey: TCnInt64PrivateKey;
  out PublicKey: TCnInt64PublicKey): Boolean;
begin
  // OutPublicKey = SelfPrivateKey * G
  Result := False;
  if (Ecc <> nil) and (SelfPrivateKey > 0) then
  begin
    PublicKey := Ecc.Generator;
    Ecc.MultiplePoint(SelfPrivateKey, PublicKey);
    Result := True;
  end;
end;

// ���ݶԷ����͵� ECDH ��ԿЭ�̵������Կ�������ɹ��ϵ���Կ��
function CnInt64EccDiffieHellmanComputeKey(Ecc: TCnInt64Ecc; SelfPrivateKey: TCnInt64PrivateKey;
  var OtherPublicKey: TCnInt64PublicKey; var SharedSecretKey: TCnInt64PublicKey): Boolean;
begin
  // SecretKey = SelfPrivateKey * OtherPublicKey
  Result := False;
  if (Ecc <> nil) and (SelfPrivateKey > 0) then
  begin
    SharedSecretKey := OtherPublicKey;
    Ecc.MultiplePoint(SelfPrivateKey, SharedSecretKey);
    Result := True;
  end;
end;

function TCnInt64Ecc.TonelliShanks(X, P: Int64; out Y: Int64): Boolean;
var
  I: Integer;
  Q, S, Z, C, R, T, M, B: Int64;
begin
  Result := False;
  if (X <= 0) or (P <= 0) or (X >= P) then
    Exit;

  // ��Ҫͨ�����õ·����ж�����Ƿ���ڣ����������������ѭ��
  if CnInt64Legendre(X, P) <> 1 then
    Exit;

  S := 0;
  Q := P - 1;
  while (Q mod 2) = 0 do
  begin
    Q := Q shr 1;
    Inc(S);
  end;

  Z := 2;
  while Z < P do
  begin
    if CnInt64Legendre(Z, P) = -1 then
      Break;
    Inc(Z);
  end;

  // ����һ�� Z ���� ��� P �����õ·���Ϊ -1
  C := MontgomeryPowerMod(Z, Q, P);
  R := MontgomeryPowerMod(X, (Q + 1) div 2, P);
  T := MontgomeryPowerMod(X, Q, P);
  M := S;

  while True do
  begin
    if T mod P = 1 then
      Break;

    for I := 1 to M - 1 do
    begin
      if MontgomeryPowerMod(T, 1 shl I, P) = 1 then
        Break;
    end;

    B := MontgomeryPowerMod(C, 1 shl (M - I - 1), P);
    M := I; // M ÿ�ض����С���㷨����

    R := Int64MultipleMod(R, B, P);
    T := Int64MultipleMod(Int64MultipleMod(T, B, P),
      B mod P, P); // T*B*B mod P = (T*B mod P) * (B mod P) mod P
    C := Int64MultipleMod(B, B, P);
  end;
  Y := (R mod P + P) mod P;
  Result := True;
end;

{ TCnEccPoint }

procedure TCnEccPoint.Assign(Source: TPersistent);
begin
  if Source is TCnEccPoint then
  begin
    BigNumberCopy(FX, (Source as TCnEccPoint).X);
    BigNumberCopy(FY, (Source as TCnEccPoint).Y);
  end
  else
    inherited;
end;

constructor TCnEccPoint.Create;
begin
  inherited;
  FX := TCnBigNumber.Create;
  FY := TCnBigNumber.Create;
  FX.SetZero;
  FY.SetZero;
end;

constructor TCnEccPoint.Create(const XDec, YDec: AnsiString);
begin
  Create;
  FX.SetDec(XDec);
  FY.SetDec(YDec);
end;

destructor TCnEccPoint.Destroy;
begin
  FY.Free;
  FX.Free;
  inherited;
end;

function TCnEccPoint.IsZero: Boolean;
begin
  Result := FX.IsZero and FY.IsZero;
end;

procedure TCnEccPoint.SetX(const Value: TCnBigNumber);
begin
  BigNumberCopy(FX, Value);
end;

procedure TCnEccPoint.SetY(const Value: TCnBigNumber);
begin
  BigNumberCopy(FY, Value);
end;

procedure TCnEccPoint.SetZero;
begin
  FX.SetZero;
  FY.SetZero;
end;

{ TCnEcc }

procedure TCnEcc.CalcX3AddAXAddB(X: TCnBigNumber);
var
  M: TCnBigNumber;
begin
  M := FEccBigNumberPool.Obtain;
  try
    BigNumberCopy(M, X);
    BigNumberMul(X, X, X);
    BigNumberMul(X, X, M); // X: X^3

    BigNumberMul(M, M, FCoefficientA); // M: A*X
    BigNumberAdd(X, X, M);             // X: X^3 + A*X
    BigNumberAdd(X, X, FCoefficientB); // X: X^3 + A*X + B
  finally
    FEccBigNumberPool.Recycle(M);
  end;
end;

constructor TCnEcc.Create(const A, B, FieldPrime, GX, GY, Order: AnsiString; H: Integer);
begin
  Create;
  Load(A, B, FIeldPrime, GX, GY, Order, H);
end;

constructor TCnEcc.Create;
begin
  inherited;
  FGenerator := TCnEccPoint.Create;
  FCoefficientB := TCnBigNumber.Create;
  FCoefficientA := TCnBigNumber.Create;
  FOrder := TCnBigNumber.Create;
  FFiniteFieldSize := TCnBigNumber.Create;

  FSizeUFactor := TCnBigNumber.Create;
end;

constructor TCnEcc.Create(Predefined: TCnEccCurveType);
begin
  Create;
  Load(Predefined);
end;

procedure TCnEcc.Decrypt(DataPoint1, DataPoint2: TCnEccPoint;
  PrivateKey: TCnEccPrivateKey; OutPlainPoint: TCnEccPoint);
var
  P: TCnEccPoint;
begin
  if (BigNumberCompare(PrivateKey, CnBigNumberZero) <= 0) or
    not IsPointOnCurve(DataPoint1) or not IsPointOnCurve(DataPoint2) then
    raise ECnEccException.Create('Invalid Private Key or Data.');

  P := TCnEccPoint.Create;
  try
    P.Assign(DataPoint2);
    MultiplePoint(PrivateKey, P);
    PointSubPoint(DataPoint1, P, OutPlainPoint);
  finally
    P.Free;
  end;
end;

destructor TCnEcc.Destroy;
begin
  FSizeUFactor.Free;

  FGenerator.Free;
  FCoefficientB.Free;
  FCoefficientA.Free;
  FOrder.Free;
  FFiniteFieldSize.Free;
  inherited;
end;

procedure TCnEcc.Encrypt(PlainPoint: TCnEccPoint;
  PublicKey: TCnEccPublicKey; OutDataPoint1, OutDataPoint2: TCnEccPoint);
var
  RandomKey: TCnBigNumber;
begin
  if not IsPointOnCurve(PublicKey) or not IsPointOnCurve(PlainPoint) then
    raise ECnEccException.Create(SCnEccErrorKeyData);

  RandomKey := FEccBigNumberPool.Obtain;
  try
    BigNumberRandRange(RandomKey, FOrder);    // �� 0 �󵫱Ȼ����С�������
    if BigNumberIsZero(RandomKey) then
      BigNumberSetOne(RandomKey);

    // M + rK;
    OutDataPoint1.Assign(PublicKey);
    MultiplePoint(RandomKey, OutDataPoint1);
    PointAddPoint(PlainPoint, OutDataPoint1, OutDataPoint1);

    // r * G
    OutDataPoint2.Assign(FGenerator);
    MultiplePoint(RandomKey, OutDataPoint2);
  finally
    FEccBigNumberPool.Recycle(RandomKey);
  end;
end;

procedure TCnEcc.GenerateKeys(PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey);
begin
  BigNumberRandRange(PrivateKey, FOrder);           // �� 0 �󵫱Ȼ����С�������
  if PrivateKey.IsZero then                         // ��һ���õ� 0���ͼ� 1
    PrivateKey.SetOne;

  PublicKey.Assign(FGenerator);
  MultiplePoint(PrivateKey, PublicKey);             // ����� PrivateKey ��
end;

function TCnEcc.GetBitsCount: Integer;
begin
  Result := FFiniteFieldSize.GetBitsCount;
end;

function TCnEcc.IsPointOnCurve(P: TCnEccPoint): Boolean;
var
  X, Y, A: TCnBigNumber;
begin
  X := FEccBigNumberPool.Obtain;
  Y := FEccBigNumberPool.Obtain;
  A := FEccBigNumberPool.Obtain;

  try
    BigNumberCopy(X, P.X);
    BigNumberCopy(Y, P.Y);

    BigNumberMul(Y, Y, Y);                // Y: Y^2
    BigNumberMod(Y, Y, FFiniteFieldSize); // Y^2 mod P

    CalcX3AddAXAddB(X);                   // X: X^3 + A*X + B
    BigNumberMod(X, X, FFiniteFieldSize); // X: (X^3 + A*X + B) mod P
    Result := BigNumberCompare(X, Y) = 0;
  finally
    FEccBigNumberPool.Recycle(X);
    FEccBigNumberPool.Recycle(Y);
    FEccBigNumberPool.Recycle(A);
  end;
end;

procedure TCnEcc.Load(Predefined: TCnEccCurveType);
begin
  Load(ECC_PRE_DEFINED_PARAMS[Predefined].A, ECC_PRE_DEFINED_PARAMS[Predefined].B,
    ECC_PRE_DEFINED_PARAMS[Predefined].P, ECC_PRE_DEFINED_PARAMS[Predefined].X,
    ECC_PRE_DEFINED_PARAMS[Predefined].Y, ECC_PRE_DEFINED_PARAMS[Predefined].N,
    StrToIntDef(ECC_PRE_DEFINED_PARAMS[Predefined].H, 1));
end;

procedure TCnEcc.Load(const A, B, FieldPrime, GX, GY, Order: AnsiString; H: Integer);
var
  R: DWORD;
begin
  FGenerator.X.SetHex(GX);
  FGenerator.Y.SetHex(GY);
  FCoefficientA.SetHex(A);
  FCoefficientB.SetHex(B);
  FFiniteFieldSize.SetHex(FieldPrime);
  FOrder.SetHex(Order);
  FCoFactor := H;

  // TODO: Ҫȷ�� 4*a^3+27*b^2 <> 0

//  �ɵ����߱�֤������߽�Ϊ����
//  if not BigNumberIsProbablyPrime(FFiniteFieldSize) then
//    raise ECnEccException.Create('Error: Finite Field Size must be Prime.');

  // ȷ�� PrimeType
  R := BigNumberModWord(FFiniteFieldSize, 4);
  BigNumberCopy(FSizeUFactor, FFiniteFieldSize);
  if R = 3 then  // RFC 5639 Ҫ�� p ���� 4u + 3 ����ʽ�Ա㷽��ؼ��� Y������������δ��
  begin
    FSizePrimeType := pt4U3;
    BigNumberDivWord(FSizeUFactor, 4);
  end
  else
  begin
    R := BigNumberModWord(FFiniteFieldSize, 8);
    if R = 1 then
    begin
      FSizePrimeType := pt8U1;
      BigNumberDivWord(FSizeUFactor, 8);
    end
    else if R = 5 then
    begin
      FSizePrimeType := pt8U5;
      BigNumberDivWord(FSizeUFactor, 8);
    end
    else
      raise ECnEccException.Create('Invalid Finite Field Size.');
  end;
end;

procedure TCnEcc.MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint);
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
  end;

  R := nil;
  E := nil;

  try
    R := TCnEccPoint.Create;
    E := TCnEccPoint.Create;
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
    R.Free;
    E.Free;
  end;
end;

function TCnEcc.PlainToPoint(Plain: TCnBigNumber;
  OutPoint: TCnEccPoint): Boolean;
var
  X, Y, Z, U, R, T, L, X3, C, M: TCnBigNumber;
begin
  Result := False;
  if Plain.IsNegative then
    Exit;

  if BigNumberCompare(Plain, FFiniteFieldSize) >= 0 then
    Exit;

  X := nil;
  U := nil;
  Y := nil;
  Z := nil;
  R := nil;
  T := nil;
  L := nil;
  X3 := nil;
  C := nil;
  M := nil;

  try
    X := FEccBigNumberPool.Obtain;
    Y := FEccBigNumberPool.Obtain;
    Z := FEccBigNumberPool.Obtain;
    U := FEccBigNumberPool.Obtain;
    X3 := FEccBigNumberPool.Obtain;

    BigNumberCopy(X, Plain);
    BigNumberCopy(U, FSizeUFactor);

    CalcX3AddAXAddB(X);
    BigNumberMod(X, X, FFiniteFieldSize);
    BigNumberCopy(X3, X);    // ����ԭʼ g

    if X3.IsZero then // ��� (X^3 + AX + B) mod p Ϊ 0����ֱ�ӷ��� (Plain, 0) ���ҿ϶��������߷���
    begin
      BigNumberCopy(OutPoint.X, Plain);
      OutPoint.Y.SetZero;
      Result := True;
      Exit;
    end;

    // �ο��ԡ�SM2��Բ���߹�Կ�����㷨����¼ B �еġ�ģ����ƽ��������⡱һ�ڣ����� g �� X ���������ķ����Ұ벿��ֵ
    case FSizePrimeType of
      pt4U3:
        begin
          // ����� g^(u+1) mod p
          BigNumberAddWord(U, 1);
          BigNumberMontgomeryPowerMod(Y, X, U, FFiniteFieldSize);
          BigNumberMulMod(Z, Y, Y, FFiniteFieldSize);
          if BigNumberCompare(Z, X) = 0 then
          begin
            BigNumberCopy(OutPoint.X, Plain);
            BigNumberCopy(OutPoint.Y, Y);
            Result := True;
            Exit;
          end;
        end;
      pt8U5:
        begin
          BigNumberMulWord(U, 2);
          BigNumberAddWord(U, 1);
          BigNumberMontgomeryPowerMod(Z, X, U, FFiniteFieldSize);
          R := FEccBigNumberPool.Obtain;
          BigNumberMod(R, Z, FFiniteFieldSize);

          if R.IsOne then
          begin
            // ����� g^(u+1) mod p
            BigNumberCopy(U, FSizeUFactor);
            BigNumberAddWord(U, 1);
            BigNumberMontgomeryPowerMod(Y, X, U, FFiniteFieldSize);

            BigNumberCopy(OutPoint.X, Plain);
            BigNumberCopy(OutPoint.Y, Y);
            Result := True;
          end
          else
          begin
            if R.IsNegative then
              BigNumberAdd(R, R, FFiniteFieldSize);
            BigNumberSub(R, FFiniteFieldSize, R);
            if R.IsOne then
            begin
              // �����(2g ��(4g)^u) mod p = (2g mod p * (4g)^u mod p) mod p
              BigNumberCopy(X, X3);
              BigNumberMulWord(X, 2);
              BigNumberMod(R, X, FFiniteFieldSize);  // R: 2g mod p

              BigNumberCopy(X, X3);
              BigNumberMulWord(X, 4);
              T := FEccBigNumberPool.Obtain;
              BigNumberMontgomeryPowerMod(T, X, FSizeUFactor, FFiniteFieldSize); // T: (4g)^u mod p
              BigNumberMulMod(Y, R, T, FFiniteFieldSize);

              BigNumberCopy(OutPoint.X, Plain);
              BigNumberCopy(OutPoint.Y, Y);
              Result := True;
            end;
          end;
        end;
      pt8U1: // Lucas ���м��㷨�� Tonelli-Shanks �㷨���ܽ���ģ��������ʣ�����
        begin
{$IFDEF USE_LUCAS}
          if BigNumberLucas(OutPoint.Y, X3, FFiniteFieldSize) then
          begin
            BigNumberCopy(OutPoint.X, Plain);
            Result := True;
          end;
{$ELSE}
          if BigNumberTonelliShanks(OutPoint.Y, X3, FFiniteFieldSize) then
          begin
            BigNumberCopy(OutPoint.X, Plain);
            Result := True;
          end;
{$ENDIF}
        end;
    end;
  finally
    FEccBigNumberPool.Recycle(X);
    FEccBigNumberPool.Recycle(Y);
    FEccBigNumberPool.Recycle(Z);
    FEccBigNumberPool.Recycle(U);
    FEccBigNumberPool.Recycle(R);
    FEccBigNumberPool.Recycle(T);
    FEccBigNumberPool.Recycle(L);
    FEccBigNumberPool.Recycle(X3);
    FEccBigNumberPool.Recycle(C);
    FEccBigNumberPool.Recycle(M);
  end;
end;

procedure TCnEcc.PointAddPoint(P, Q, Sum: TCnEccPoint);
var
  K, X, Y, A, SX, SY: TCnBigNumber;
begin
  K := nil;
  X := nil;
  Y := nil;
  A := nil;
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
    end
    else if (BigNumberCompare(P.X, Q.X) = 0) and (BigNumberCompare(P.Y, Q.Y) = 0) then
    begin
      // ��������ͬһ���㣬����б��Ϊ�����󵼣�3 * X^2 + A / (2 * Y) ���� Y = 0 ��ֱ��������Զ 0��
      if P.Y.IsZero then
      begin
        Sum.SetZero;
        Exit;
      end;

      X := FEccBigNumberPool.Obtain;
      Y := FEccBigNumberPool.Obtain;
      K := FEccBigNumberPool.Obtain;

      // X := 3 * P.X * P.X + CoefficientA;
      BigNumberMul(X, P.X, P.X);             // X: P.X^2
      BigNumberMulWord(X, 3);                // X: 3 * P.X^2
      BigNumberAdd(X, X, FCoefficientA);     // X: 3 * P.X^2 + A

      // Y := 2 * P.Y;
      BigNumberCopy(Y, P.Y);
      BigNumberMulWord(Y, 2);                // Y: 2 * P.Y

      A := FEccBigNumberPool.Obtain;
      BigNumberCopy(A, Y);
      BigNumberModularInverse(Y, A, FFiniteFieldSize); // Y := Y^-1

      // K := X * Y mod FFiniteFieldSize;
      BigNumberMulMod(K, X, Y, FFiniteFieldSize);      // �õ�б��
    end
    else // �ǲ�ͬ��
    begin
      if BigNumberCompare(P.X, Q.X) = 0 then // ��� X ��ȣ�Ҫ�ж� Y �ǲ��ǻ����������Ϊ 0�����������
      begin
        A := FEccBigNumberPool.Obtain;
        BigNumberAdd(A, P.Y, Q.Y);
        if BigNumberCompare(A, FFiniteFieldSize) = 0 then  // ��������Ϊ 0
          Sum.SetZero
        else                                               // ������������
          raise ECnEccException.CreateFmt('Can NOT Calucate %s,%s + %s,%s',
            [P.X.ToDec, P.Y.ToDec, Q.X.ToDec, Q.Y.ToDec]);

        Exit;
      end;

      // �����X ȷ����ͬ��б�� K := ((Q.Y - P.Y) / (Q.X - P.X)) mod p
      X := FEccBigNumberPool.Obtain;
      Y := FEccBigNumberPool.Obtain;
      K := FEccBigNumberPool.Obtain;

      // Y := Q.Y - P.Y;
      // X := Q.X - P.X;
      BigNumberSub(Y, Q.Y, P.Y);
      BigNumberSub(X, Q.X, P.X);

      A := FEccBigNumberPool.Obtain;
      BigNumberCopy(A, X);
      BigNumberModularInverse(X, A, FFiniteFieldSize);
      BigNumberMulMod(K, Y, X, FFiniteFieldSize);      // �õ�б��
    end;

    BigNumberCopy(X, K);
    BigNumberMul(X, X, K);
    BigNumberSub(X, X, P.X);
    BigNumberSub(X, X, Q.X);    //  X := K * K - P.X - Q.X;

    SX := FEccBigNumberPool.Obtain;
    if BigNumberIsNegative(X) then // ��ֵ��ģ������ֵ��ģ��ģ����
    begin
      BigNumberSetNegative(X, False);
      BigNumberMod(SX, X, FFiniteFieldSize);
      if not SX.IsZero then                   // �պ�����ʱ����������� 0��������� X ֵ�����������Ͻ�����
        BigNumberSub(SX, FFiniteFieldSize, SX);
    end
    else
      BigNumberMod(SX, X, FFiniteFieldSize);

    // Ysum = (K * (X1 - Xsum) - Y1) mod p  ע��Ҫȡ��
    //   Ҳ = (K * (X2 - Xsum) - Y2) mod p  ע��Ҫȡ��
    BigNumberSub(X, P.X, SX);
    BigNumberMul(Y, K, X);
    BigNumberSub(Y, Y, P.Y);

    SY := FEccBigNumberPool.Obtain;
    if BigNumberIsNegative(Y) then
    begin
      BigNumberSetNegative(Y, False);
      BigNumberMod(SY, Y, FFiniteFieldSize);
      if not SY.IsZero then                     // �պ�����ʱ����������� 0��������� Y ֵ�����������Ͻ�����
        BigNumberSub(SY, FFiniteFieldSize, SY);
    end
    else
      BigNumberMod(SY, Y, FFiniteFieldSize);

    BigNumberCopy(Sum.X, SX);
    BigNumberCopy(Sum.Y, SY);
  finally
    FEccBigNumberPool.Recycle(K);
    FEccBigNumberPool.Recycle(X);
    FEccBigNumberPool.Recycle(Y);
    FEccBigNumberPool.Recycle(A);
    FEccBigNumberPool.Recycle(SX);
    FEccBigNumberPool.Recycle(SY);
  end;
end;

procedure TCnEcc.PointInverse(P: TCnEccPoint);
begin
  if BigNumberIsNegative(P.Y) or (BigNumberCompare(P.Y, FFiniteFieldSize) >= 0) then
    raise ECnEccException.Create('Inverse Error.');

  BigNumberSub(P.Y, FFiniteFieldSize, P.Y);
end;

procedure TCnEcc.PointSubPoint(P, Q, Diff: TCnEccPoint);
var
  Inv: TCnEccPoint;
begin
  Inv := TCnEccPoint.Create;
  try
    Inv.X := Q.X;
    Inv.Y := Q.Y;

    PointInverse(Inv);
    PointAddPoint(P, Inv, Diff);
  finally
    Inv.Free;
  end;
end;

function TCnEcc.PointToPlain(Point: TCnEccPoint;
  OutPlain: TCnBigNumber): Boolean;
begin
  Result := False;
  if (Point <> nil) and (OutPlain <> nil) and IsPointOnCurve(Point) then
  begin
    BigNumberCopy(OutPlain, Point.X);
    Result := True;
  end;
end;

function CnEccDiffieHellmanGenerateOutKey(Ecc: TCnEcc; SelfPrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey): Boolean;
begin
  // PublicKey = SelfPrivateKey * G
  Result := False;
  if (Ecc <> nil) and (SelfPrivateKey <> nil) and not BigNumberIsNegative(SelfPrivateKey) then
  begin
    PublicKey.Assign(Ecc.Generator);
    Ecc.MultiplePoint(SelfPrivateKey, PublicKey);
    Result := True;
  end;
end;

function CnEccDiffieHellmanComputeKey(Ecc: TCnEcc; SelfPrivateKey: TCnEccPrivateKey;
  OtherPublicKey: TCnEccPublicKey; SharedSecretKey: TCnEccPublicKey): Boolean;
begin
  // SecretKey = SelfPrivateKey * OtherPublicKey
  Result := False;
  if (Ecc <> nil) and (SelfPrivateKey <> nil) and not BigNumberIsNegative(SelfPrivateKey) then
  begin
    SharedSecretKey.Assign(OtherPublicKey);
    Ecc.MultiplePoint(SelfPrivateKey, SharedSecretKey);
    Result := True;
  end;
end;

function GetCurveTypeFromOID(Data: PAnsiChar; DataLen: Cardinal): TCnEccCurveType;
var
  P: PByte;
  L: Byte;
begin
  Result := ctCustomized;
  if (Data = nil) or (DataLen < 3) then
    Exit;

  P := PByte(Data);
  if P^ <> CN_BER_TAG_OBJECT_IDENTIFIER then
    Exit;
  Inc(P);

  L := P^;
  if L > EC_CURVE_TYPE_OID_MAX_LENGTH then
    Exit;

  Inc(P);
  if CompareMem(P, @OID_ECPARAM_CURVE_TYPE_SECP256K1[0],
    Min(L, SizeOf(OID_ECPARAM_CURVE_TYPE_SECP256K1))) then
    Result := ctSecp256k1
  else if CompareMem(P, @OID_ECPARAM_CURVE_TYPE_SM2[0],
    Min(L, SizeOf(OID_ECPARAM_CURVE_TYPE_SM2))) then
    Result := ctSM2
  else if CompareMem(P, @OID_ECPARAM_CURVE_TYPE_PRIME256V1[0],
    Min(L, SizeOf(OID_ECPARAM_CURVE_TYPE_PRIME256V1))) then
    Result := ctPrime256v1
end;

// �����������ͷ����� OID ��ַ�볤�ȣ����ʹ�ú������ͷ�
function GetOIDFromCurveType(Curve: TCnEccCurveType; out OIDAddr: Pointer): Integer;
begin
  Result := 0;
  OIDAddr := nil;

  case Curve of
    ctSecp256k1:
      begin
        OIDAddr := @OID_ECPARAM_CURVE_TYPE_SECP256K1[0];
        Result := SizeOf(OID_ECPARAM_CURVE_TYPE_SECP256K1);
      end;
    ctSM2:
      begin
        OIDAddr := @OID_ECPARAM_CURVE_TYPE_SM2[0];
        Result := SizeOf(OID_ECPARAM_CURVE_TYPE_SM2);
      end;
    ctPrime256v1:
      begin
        OIDAddr := @OID_ECPARAM_CURVE_TYPE_PRIME256V1[0];
        Result := SizeOf(OID_ECPARAM_CURVE_TYPE_PRIME256V1);
      end;
  end;
end;

function ReadEccPublicKeyFromBitStringNode(BitStringNode: TCnBerReadNode; PublicKey: TCnEccPublicKey): Boolean;
var
  B: PByte;
  Len: Integer;
begin
  Result := False;
  if (BitStringNode = nil) or (PublicKey = nil) then
    Exit;

  // PubNode �� Data �� BITSTRING��00 04 ��ͷ
  // BITSTRING ��������һ�������ֽ��Ǹ� BITSTRING �ճ� 8 �ı�����ȱ�ٵ� Bit ���������� 0������
  B := BitStringNode.BerDataAddress;
  Inc(B); // ���� 00��ָ��ѹ��ģʽ�ֽ�

  if B^ = EC_PUBLICKEY_UNCOMPRESSED then
  begin
    // δѹ����ʽ��ǰһ���ǹ�Կ�� X����һ���ǹ�Կ�� Y
    Inc(B);
    Len := (BitStringNode.BerDataLength - 2) div 2;
    PublicKey.X.SetBinary(PAnsiChar(B), Len);
    Inc(B, Len);
    PublicKey.Y.SetBinary(PAnsiChar(B), Len);

    Result := True;
  end
  else if (B^ = EC_PUBLICKEY_COMPRESSED1) or (B^ = EC_PUBLICKEY_COMPRESSED2) then
  begin
    Inc(B);
    // ѹ����ʽ��ȫ�ǹ�Կ X
    PublicKey.X.SetBinary(PAnsiChar(B), BitStringNode.BerDataLength - 2);
    PublicKey.Y.SetZero; // Y �� 0���ⲿ��ȥ���

    Result := True;
  end;
end;

function WriteEccPublicKeyToBitStringNode(Writer: TCnBerWriter;
  ParentNode: TCnBerWriteNode; PublicKey: TCnEccPublicKey): Boolean;
var
  Cnt: Integer;
  B: Byte;
  OP, P: PByte;
begin
  Result := False;
  if (ParentNode = nil) or (PublicKey = nil) then
    Exit;

  Cnt := PublicKey.X.GetBytesCount;
  if not PublicKey.Y.IsZero then
  begin
    Cnt := Cnt + PublicKey.Y.GetBytesCount;
    B := EC_PUBLICKEY_UNCOMPRESSED;
  end
  else
    B := EC_PUBLICKEY_COMPRESSED2;

  OP := GetMemory(Cnt + 1);
  P := OP;
  P^ := B;

  Inc(P);
  PublicKey.X.ToBinary(PAnsiChar(P));
  if B = EC_PUBLICKEY_UNCOMPRESSED then
  begin
    Inc(P, PublicKey.X.GetBytesCount);
    PublicKey.Y.ToBinary(PAnsiChar(P));
  end;
  Writer.AddBasicNode(CN_BER_TAG_BIT_STRING, OP, Cnt + 1, ParentNode);
  FreeMemory(OP);
end;

(*
  SEQUENCE (2 elem)
    SEQUENCE (2 elem)
      OBJECT IDENTIFIER 1.2.840.10045.2.1 ecPublicKey (ANSI X9.62 public key type)
      OBJECT IDENTIFIER 1.3.132.0.10 secp256k1 (SECG (Certicom) named elliptic curve)
    BIT STRING
*)
function CnEccLoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnEccPublicKey; out CurveType: TCnEccCurveType;
  KeyHashMethod: TCnKeyHashMethod; const Password: string): Boolean;
var
  MemStream: TMemoryStream;
  Reader: TCnBerReader;
  Node: TCnBerReadNode;
begin
  Result := False;
  MemStream := nil;
  Reader := nil;

  if PublicKey = nil then
    Exit;

  try
    MemStream := TMemoryStream.Create;
    if LoadPemFileToMemory(PemFileName, PEM_EC_PUBLIC_HEAD, PEM_EC_PUBLIC_TAIL,
      MemStream, Password, KeyHashMethod) then
    begin
      Reader := TCnBerReader.Create(PByte(MemStream.Memory), MemStream.Size);
      Reader.ParseToTree;
      if Reader.TotalCount >= 5 then
      begin
        // 2 Ҫ�ж��Ƿ�Կ
        Node := Reader.Items[2];
        if (Node.BerLength <> SizeOf(OID_EC_PUBLIC_KEY)) or not CompareMem(@OID_EC_PUBLIC_KEY[0],
          Node.BerAddress, Node.BerLength) then
          Exit;

        // 3 ����������
        Node := Reader.Items[3];
        CurveType := GetCurveTypeFromOID(Node.BerDataAddress, Node.BerDataLength);

        // �� 4 ��Ĺ�Կ
        Result := ReadEccPublicKeyFromBitStringNode(Reader.Items[4], PublicKey);
      end;
    end;
  finally
    MemStream.Free;
    Reader.Free;
  end;
end;

(*
   ECPrivateKey ::= SEQUENCE {
     version        INTEGER { ecPrivkeyVer1(1) } (ecPrivkeyVer1),
     privateKey     OCTET STRING,
     parameters [0] ECParameters {{ NamedCurve }} OPTIONAL,
     publicKey  [1] BIT STRING OPTIONAL
   }

  SEQUENCE (4 elem)
    INTEGER 1
    OCTET STRING (32 byte) 10C8813CC012D659A282B261E86D0440848DB246A077C427203F92FD90B3CD77
    [0] (1 elem)
      OBJECT IDENTIFIER 1.3.132.0.10 secp256k1 (SECG (Certicom) named elliptic curve)
    [1] (1 elem)
      BIT STRING
*)
function CnEccLoadKeysFromPem(const PemFileName: string; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; out CurveType: TCnEccCurveType;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5; const Password: string = ''): Boolean;
var
  MemStream: TMemoryStream;
  Reader: TCnBerReader;
  Node: TCnBerReadNode;
  CurveType2: TCnEccCurveType;
begin
  Result := False;
  MemStream := nil;
  Reader := nil;

  try
    MemStream := TMemoryStream.Create;
    if LoadPemFileToMemory(PemFileName, PEM_EC_PARAM_HEAD, PEM_EC_PARAM_TAIL,
      MemStream, Password, KeyHashMethod) then
      // �� ECPARAM Ҳ����Բ��������
      CurveType := GetCurveTypeFromOID(PAnsiChar(MemStream.Memory), MemStream.Size);

    if LoadPemFileToMemory(PemFileName, PEM_EC_PRIVATE_HEAD, PEM_EC_PRIVATE_TAIL,
      MemStream, Password, KeyHashMethod) then
    begin
      Reader := TCnBerReader.Create(PByte(MemStream.Memory), MemStream.Size);
      Reader.ParseToTree;
      if Reader.TotalCount >= 7 then
      begin
        Node := Reader.Items[1]; // 0 ������ Sequence��1 �� Version
        if Node.AsByte = 1 then  // ֻ֧�ְ汾 1
        begin
          // 2 ��˽Կ
          if PrivateKey <> nil then
            PutIndexedBigIntegerToBigInt(Reader.Items[2], PrivateKey);

          // 4 ������������
          Node := Reader.Items[4];
          CurveType2 := GetCurveTypeFromOID(Node.BerAddress, Node.BerLength);
          if (CurveType <> ctCustomized) and (CurveType2 <> CurveType) then
            Exit;

          CurveType := CurveType2; // �����������һ�����Եڶ���Ϊ׼

          // �� 6 ��Ĺ�Կ
          Result := ReadEccPublicKeyFromBitStringNode(Reader.Items[6], PublicKey);
        end;
      end;
    end;
  finally
    MemStream.Free;
    Reader.Free;
  end;
end;

function CnEccSaveKeysToPem(const PemFileName: string; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; CurveType: TCnEccCurveType;
  KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5; const Password: string = ''): Boolean;
var
  Root, Node: TCnBerWriteNode;
  Writer: TCnBerWriter;
  Mem: TMemoryStream;
  OIDPtr: Pointer;
  OIDLen: Integer;
  B: Byte;
begin
  Result := False;
  if (PrivateKey = nil) or (PublicKey = nil) then
    Exit;

  OIDLen := GetOIDFromCurveType(CurveType, OIDPtr);
  if (OIDPtr = nil) or (OIDLen <= 0) then
    Exit;

  Mem := nil;
  Writer := nil;

  try
    Mem := TMemoryStream.Create;
    if (KeyEncryptMethod = ckeNone) or (Password = '') then
    begin
      // �����ܣ������Σ���һ���ֹ�д
      B := CN_BER_TAG_OBJECT_IDENTIFIER;
      Mem.Write(B, 1);
      B := OIDLen;
      Mem.Write(B, 1);

      Mem.Write(OIDPtr^, OIDLen);
      if not SaveMemoryToPemFile(PemFileName, PEM_EC_PARAM_HEAD, PEM_EC_PARAM_TAIL, Mem) then
        Exit;

      Mem.Clear;
    end;

    Writer := TCnBerWriter.Create;

    // �ڶ�������
    Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
    B := 1;
    Writer.AddBasicNode(CN_BER_TAG_INTEGER, @B, 1, Root); // д Version 1
    AddBigNumberToWriter(Writer, PrivateKey, Root);       // д˽Կ

    Node := Writer.AddContainerNode(CN_BER_TAG_RESERVED, Root);
    Node.BerTypeMask := ECC_PRIVATEKEY_TYPE_MASK;
    Writer.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, PByte(OIDPtr), OIDLen, Node);

    Node := Writer.AddContainerNode(CN_BER_TAG_BOOLEAN, Root); // ��ȻҪ�� BOOLEAN ����
    Node.BerTypeMask := ECC_PRIVATEKEY_TYPE_MASK;

    WriteEccPublicKeyToBitStringNode(Writer, Node, PublicKey);
    Writer.SaveToStream(Mem);
    Result := SaveMemoryToPemFile(PemFileName, PEM_EC_PRIVATE_HEAD, PEM_EC_PRIVATE_TAIL, Mem,
      KeyEncryptMethod, KeyHashMethod, Password, True);
  finally
    Mem.Free;
    Writer.Free;
  end;
end;

function CnEccSavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnEccPublicKey; CurveType: TCnEccCurveType;
  KeyType: TCnEccKeyType = cktPKCS1; KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5; const Password: string = ''): Boolean;
var
  Root, Node: TCnBerWriteNode;
  Writer: TCnBerWriter;
  Mem: TMemoryStream;
  OIDPtr: Pointer;
  OIDLen: Integer;
begin
  Result := False;
  if (PublicKey = nil) or (PublicKey.X.IsZero) then
    Exit;

  OIDLen := GetOIDFromCurveType(CurveType, OIDPtr);
  if (OIDPtr = nil) or (OIDLen <= 0) then
    Exit;

  Mem := nil;
  Writer := nil;

  try
    Writer := TCnBerWriter.Create;
    Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
    Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);

    // �� Node �� ECPublicKey �� �������͵� ObjectIdentifier
    Writer.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @OID_EC_PUBLIC_KEY[0],
      SizeOf(OID_EC_PUBLIC_KEY), Node);
    Writer.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, OIDPtr, OIDLen, Node);
    WriteEccPublicKeyToBitStringNode(Writer, Node, PublicKey);

    Mem := TMemoryStream.Create;
    Writer.SaveToStream(Mem);

    Result := SaveMemoryToPemFile(PemFileName, PEM_EC_PUBLIC_HEAD, PEM_EC_PUBLIC_TAIL, Mem,
      KeyEncryptMethod, KeyHashMethod, Password);
  finally
    Mem.Free;
    Writer.Free;
  end;
end;

// ECC ǩ������֤

// ����ָ������ժҪ�㷨����ָ�����Ķ�����ɢ��ֵ��д�� Stream
function CalcDigestStream(InStream: TStream; SignType: TCnEccSignDigestType;
  outStream: TStream): Boolean;
var
  Md5: TMD5Digest;
  Sha1: TSHA1Digest;
  Sha256: TSHA256Digest;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  case SignType of
    esdtMD5:
      begin
        Md5 := MD5Stream(InStream);
        outStream.Write(Md5, SizeOf(TMD5Digest));
        Result := True;
      end;
    esdtSHA1:
      begin
        Sha1 := SHA1Stream(InStream);
        outStream.Write(Sha1, SizeOf(TSHA1Digest));
        Result := True;
      end;
    esdtSHA256:
      begin
        Sha256 := SHA256Stream(InStream);
        outStream.Write(Sha256, SizeOf(TSHA256Digest));
        Result := True;
      end;
    esdtSM3:
      begin
        Sm3Dig := SM3Stream(InStream);
        outStream.Write(Sm3Dig, SizeOf(TSM3Digest));
        Result := True;
      end;
  end;
end;

// ����ָ������ժҪ�㷨�����ļ��Ķ�����ɢ��ֵ��д�� Stream
function CalcDigestFile(const FileName: string; SignType: TCnEccSignDigestType;
  outStream: TStream): Boolean;
var
  Md5: TMD5Digest;
  Sha1: TSHA1Digest;
  Sha256: TSHA256Digest;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  case SignType of
    esdtMD5:
      begin
        Md5 := MD5File(FileName);
        outStream.Write(Md5, SizeOf(TMD5Digest));
        Result := True;
      end;
    esdtSHA1:
      begin
        Sha1 := SHA1File(FileName);
        outStream.Write(Sha1, SizeOf(TSHA1Digest));
        Result := True;
      end;
    esdtSHA256:
      begin
        Sha256 := SHA256File(FileName);
        outStream.Write(Sha256, SizeOf(TSHA256Digest));
        Result := True;
      end;
    esdtSM3:
      begin
        Sm3Dig := SM3File(FileName);
        outStream.Write(Sm3Dig, SizeOf(TSM3Digest));
        Result := True;
      end;
  end;
end;

{
  ��ά���ٿ���˵���� ECDSA �㷨����ǩ����
  https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
}
function EccSignValue(Ecc: TCnEcc; PrivateKey: TCnEccPrivateKey; InE, OutR, OutS: TCnBigNumber): Boolean;
var
  K, X, KInv: TCnBigNumber;
  P: TCnEccPoint;
begin
  Result := False;
  BuildShortXValue(InE, Ecc.Order); // InE ������ z

  K := nil;
  X := nil;
  KInv := nil;
  P := nil;

  try
    K := TCnBigNumber.Create;
    KInv := TCnBigNumber.Create;
    X := TCnBigNumber.Create;
    P := TCnEccPoint.Create;

    while True do
    begin
      if not BigNumberRandRange(K, Ecc.Order) then // ������Ҫ����� K
        Exit;

      // K.SetHex('9E56F509196784D963D1C0A401510EE7ADA3DCC5DEE04B154BF61AF1D5A6DECE');   // ָ�����ֵʱ������

      P.Assign(Ecc.Generator);
      Ecc.MultiplePoint(K, P);

      if not BigNumberNonNegativeMod(OutR, P.X, Ecc.Order) then
        Exit;

      if OutR.IsZero then
        Continue;
      // �����ǩ����һ���� R

      if not BigNumberMul(X, PrivateKey, OutR) then   // X <= r * PrivateKey
        Exit;
      if not BigNumberAdd(X, X, InE) then             // X <= X + z
        Exit;
      BigNumberModularInverse(KInv, K, Ecc.Order);
      if not BigNumberMul(X, KInv, X) then            // X <= K^-1 * X
        Exit;
      if not BigNumberNonNegativeMod(OutS, X, Ecc.Order) then  // OutS <= K^-1 * (z + r * PrivateKey) mod N
        Exit;

      if OutS.IsZero then
        Continue;

      Break;
    end;
    Result := True;
  finally
    P.Free;
    KInv.Free;
    X.Free;
    K.Free;
  end;
end;

function CnEccSignFile(const InFileName, OutSignFileName: string; Ecc: TCnEcc;
  PrivateKey: TCnEccPrivateKey; SignType: TCnEccSignDigestType = esdtMD5): Boolean;
var
  Stream: TMemoryStream;
  E, R, S: TCnBigNumber;
  Writer: TCnBerWriter;
  Root: TCnBerWriteNode;
begin
  Result := False;
  Stream := nil;
  Writer := nil;
  E := nil;
  R := nil;
  S := nil;

  try
    Stream := TMemoryStream.Create;

    if not CalcDigestFile(InFileName, SignType, Stream) then // �����ļ���ɢ��ֵ
      Exit;
    E := TCnBigNumber.Create;
    E.SetBinary(Stream.Memory, Stream.Size);

    R := TCnBigNumber.Create;
    S := TCnBigNumber.Create;

    if EccSignValue(Ecc, PrivateKey, E, R, S) then
    begin
      // Ȼ�󰴸�ʽ���� BER ����
      Writer := TCnBerWriter.Create;
      Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
      AddBigNumberToWriter(Writer, R, Root);
      AddBigNumberToWriter(Writer, S, Root);

      Writer.SaveToFile(OutSignFileName);
      Result := True;
    end;
  finally
    Stream.Free;
    E.Free;
    R.Free;
    S.Free;
    Writer.Free;
  end;
end;

function CnEccSignFile(const InFileName, OutSignFileName: string; CurveType: TCnEccCurveType;
  PrivateKey: TCnEccPrivateKey; SignType: TCnEccSignDigestType = esdtMD5): Boolean;
var
  Ecc: TCnEcc;
begin
  if CurveType = ctCustomized then
    raise ECnEccException.Create(SCnEccErrorCurveType);

  Ecc := TCnEcc.Create(CurveType);
  try
    Result := CnEccSignFile(InFileName, OutSignFileName, Ecc, PrivateKey, SignType);
  finally
    Ecc.Free;
  end;
end;

{
  ��ά���ٿ���˵���� ECDSA �㷨����ǩ����֤��
  https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
}
function EccVerifyValue(Ecc: TCnEcc; PublicKey: TCnEccPublicKey; InE, InR, InS: TCnBigNumber): Boolean;
var
  U1, U2, SInv: TCnBigNumber;
  P1, P2: TCnEccPoint;
begin
  Result := False;
  if not CheckEccPublicKey(Ecc, PublicKey) then
    Exit;

  BuildShortXValue(InE, Ecc.Order); // InE is z

  U1 := nil;
  U2 := nil;
  P1 := nil;
  P2 := nil;
  SInv := nil;

  try
    SInv := TCnBigNumber.Create;
    BigNumberModularInverse(SInv, InS, Ecc.Order);
    U1 := TCnBigNumber.Create;
    if not BigNumberMul(U1, InE, SInv) then
      Exit;
    if not BigNumberNonNegativeMod(U1, U1, Ecc.Order) then // u1 = (z * s^-1) mod N
      Exit;

    U2 := TCnBigNumber.Create;
    if not BigNumberMul(U2, InR, SInv) then
      Exit;
    if not BigNumberNonNegativeMod(U1, U1, Ecc.Order) then // u2 = (r * s^-1) mod N
      Exit;

    P1 := TCnEccPoint.Create;
    P1.Assign(Ecc.Generator);
    Ecc.MultiplePoint(U1, P1);

    P2 := TCnEccPoint.Create;
    P2.Assign(PublicKey);
    Ecc.MultiplePoint(U2, P2);
    Ecc.PointAddPoint(P1, P2, P1);  // ���� u1 * G + u2 * PublicKey ��
    if P1.IsZero then
      Exit;

    if not BigNumberNonNegativeMod(P1.X, P1.X, Ecc.Order) then // ���� P1.X mod N
      Exit;

    if not BigNumberNonNegativeMod(P1.Y, InR, Ecc.Order) then  // ���� r mod N
      Exit;

    Result := BigNumberCompare(P1.X, P1.Y) = 0;
  finally
    SInv.Free;
    P2.Free;
    P1.Free;
    U2.Free;
    U1.Free;
  end;
end;

function CnEccVerifyFile(const InFileName, InSignFileName: string; Ecc: TCnEcc;
  PublicKey: TCnEccPublicKey; SignType: TCnEccSignDigestType = esdtMD5): Boolean;
var
  Stream: TMemoryStream;
  E, R, S: TCnBigNumber;
  Reader: TCnBerReader;
begin
  Result := False;
  Stream := nil;
  Reader := nil;
  E := nil;
  R := nil;
  S := nil;

  try
    Stream := TMemoryStream.Create;

    if not CalcDigestFile(InFileName, SignType, Stream) then // �����ļ���ɢ��ֵ
      Exit;

    E := TCnBigNumber.Create;
    E.SetBinary(Stream.Memory, Stream.Size);

    Stream.Clear;
    Stream.LoadFromFile(InSignFileName);
    Reader := TCnBerReader.Create(Stream.Memory, Stream.Size);
    Reader.ParseToTree;

    if Reader.TotalCount <> 3 then
      Exit;

    R := TCnBigNumber.Create;
    S := TCnBigNumber.Create;
    PutIndexedBigIntegerToBigInt(Reader.Items[1], R);
    PutIndexedBigIntegerToBigInt(Reader.Items[2], S);

    Result := EccVerifyValue(Ecc, PublicKey, E, R, S);
  finally
    Stream.Free;
    Reader.Free;
    E.Free;
    R.Free;
    S.Free;
  end;
end;

function CnEccVerifyFile(const InFileName, InSignFileName: string; CurveType: TCnEccCurveType;
  PublicKey: TCnEccPublicKey; SignType: TCnEccSignDigestType = esdtMD5): Boolean;
var
  Ecc: TCnEcc;
begin
  if CurveType = ctCustomized then
    raise ECnEccException.Create(SCnEccErrorCurveType);

  Ecc := TCnEcc.Create(CurveType);
  try
    Result := CnEccVerifyFile(InFileName, InSignFileName, Ecc, PublicKey, SignType);
  finally
    Ecc.Free;
  end;
end;

{
  ECC ǩ������� BER ��ʽ���£�ֱ�Ӵ�ɶ������ļ�����
  SEQUENCE (2 elem)
    INTEGER r
    INTEGER s
}
function CnEccSignStream(InStream: TMemoryStream; OutSignStream: TMemoryStream;
  Ecc: TCnEcc; PrivateKey: TCnEccPrivateKey;
  SignType: TCnEccSignDigestType = esdtMD5): Boolean;
var
  Stream: TMemoryStream;
  E, R, S: TCnBigNumber;
  Writer: TCnBerWriter;
  Root: TCnBerWriteNode;
begin
  Result := False;
  Stream := nil;
  Writer := nil;
  E := nil;
  R := nil;
  S := nil;

  try
    Stream := TMemoryStream.Create;

    if not CalcDigestStream(InStream, SignType, Stream) then // ��������ɢ��ֵ
      Exit;
    E := TCnBigNumber.Create;
    E.SetBinary(Stream.Memory, Stream.Size);

    R := TCnBigNumber.Create;
    S := TCnBigNumber.Create;

    if EccSignValue(Ecc, PrivateKey, E, R, S) then
    begin
      // Ȼ�󰴸�ʽ���� BER ����
      Writer := TCnBerWriter.Create;
      Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
      AddBigNumberToWriter(Writer, R, Root);
      AddBigNumberToWriter(Writer, S, Root);

      Writer.SaveToStream(OutSignStream);
      Result := True;
    end;
  finally
    Stream.Free;
    E.Free;
    R.Free;
    S.Free;
    Writer.Free;
  end;
end;

function CnEccSignStream(InStream: TMemoryStream; OutSignStream: TMemoryStream;
  CurveType: TCnEccCurveType; PrivateKey: TCnEccPrivateKey;
  SignType: TCnEccSignDigestType = esdtMD5): Boolean;
var
  Ecc: TCnEcc;
begin
  if CurveType = ctCustomized then
    raise ECnEccException.Create(SCnEccErrorCurveType);

  Ecc := TCnEcc.Create(CurveType);
  try
    Result := CnEccSignStream(InStream, OutSignStream, Ecc, PrivateKey, SignType);
  finally
    Ecc.Free;
  end;
end;

function CnEccVerifyStream(InStream: TMemoryStream; InSignStream: TMemoryStream;
  Ecc: TCnEcc; PublicKey: TCnEccPublicKey;
  SignType: TCnEccSignDigestType = esdtMD5): Boolean;
var
  Stream: TMemoryStream;
  E, R, S: TCnBigNumber;
  Reader: TCnBerReader;
begin
  Result := False;
  Stream := nil;
  Reader := nil;
  E := nil;
  R := nil;
  S := nil;

  try
    Stream := TMemoryStream.Create;

    if not CalcDigestStream(InStream, SignType, Stream) then // ��������ɢ��ֵ
      Exit;

    E := TCnBigNumber.Create;
    E.SetBinary(Stream.Memory, Stream.Size);

    Stream.Clear;
    Stream.LoadFromStream(InSignStream);
    Reader := TCnBerReader.Create(Stream.Memory, Stream.Size);
    Reader.ParseToTree;

    if Reader.TotalCount <> 3 then
      Exit;

    R := TCnBigNumber.Create;
    S := TCnBigNumber.Create;
    PutIndexedBigIntegerToBigInt(Reader.Items[1], R);
    PutIndexedBigIntegerToBigInt(Reader.Items[2], S);

    Result := EccVerifyValue(Ecc, PublicKey, E, R, S);
  finally
    Stream.Free;
    Reader.Free;
    E.Free;
    R.Free;
    S.Free;
  end;
end;

function CnEccVerifyStream(InStream: TMemoryStream; InSignStream: TMemoryStream;
  CurveType: TCnEccCurveType; PublicKey: TCnEccPublicKey;
  SignType: TCnEccSignDigestType = esdtMD5): Boolean;
var
  Ecc: TCnEcc;
begin
  if CurveType = ctCustomized then
    raise ECnEccException.Create(SCnEccErrorCurveType);

  Ecc := TCnEcc.Create(CurveType);
  try
    Result := CnEccVerifyStream(InStream, InSignStream, Ecc, PublicKey, SignType);
  finally
    Ecc.Free;
  end;
end;

function CheckEccPublicKey(Ecc: TCnEcc; PublicKey: TCnEccPublicKey): Boolean;
var
  P: TCnEccPoint;
begin
  Result := False;
  if (Ecc <> nil) and (PublicKey <> nil) then
  begin
    if PublicKey.IsZero then
      Exit;
    if not Ecc.IsPointOnCurve(PublicKey) then
      Exit;

    P := TCnEccPoint.Create;
    try
      P.Assign(PublicKey);
      Ecc.MultiplePoint(Ecc.Order, P);
      Result := P.IsZero;
    finally
      P.Free;
    end;
  end;
end;

function GetEccDigestNameFromSignDigestType(Digest: TCnEccSignDigestType): string;
begin
  case Digest of
    esdtMD5: Result := 'MD5';
    esdtSHA1: Result := 'SHA1';
    esdtSHA256: Result := 'SHA256';
    esdtSM3: Result := 'SM3';
  else
    Result := '<Unknown>';
  end;
end;

{ TCnInt64PolynomialEccPoint }

procedure TCnInt64PolynomialEccPoint.Assign(Source: TPersistent);
begin
  if Source is TCnInt64PolynomialEccPoint then
  begin
    Int64PolynomialCopy(FX, (Source as TCnInt64PolynomialEccPoint).X);
    Int64PolynomialCopy(FY, (Source as TCnInt64PolynomialEccPoint).Y);
  end
  else
    inherited;
end;

constructor TCnInt64PolynomialEccPoint.Create;
begin
  inherited;
  FX := TCnInt64Polynomial.Create;
  FY := TCnInt64Polynomial.Create;
end;

constructor TCnInt64PolynomialEccPoint.Create(
  const XLowToHighCoefficients, YLowToHighCoefficients: array of const);
begin
  Create;
  FX.SetCoefficents(XLowToHighCoefficients);
  FY.SetCoefficents(YLowToHighCoefficients);
end;

destructor TCnInt64PolynomialEccPoint.Destroy;
begin
  FY.Free;
  FX.Free;
  inherited;
end;

function TCnInt64PolynomialEccPoint.IsZero: Boolean;
begin
  Result := FX.IsZero and FY.IsZero;
end;

procedure TCnInt64PolynomialEccPoint.SetX(
  const Value: TCnInt64Polynomial);
begin
  if Value <> nil then
    Int64PolynomialCopy(FX, Value);
end;

procedure TCnInt64PolynomialEccPoint.SetY(
  const Value: TCnInt64Polynomial);
begin
  if Value <> nil then
    Int64PolynomialCopy(FY, Value);
end;

procedure TCnInt64PolynomialEccPoint.SetZero;
begin
  FX.SetZero;
  FY.SetZero;
end;

function TCnInt64PolynomialEccPoint.ToString: string;
begin
  Result := CnInt64PolynomialEccPointToString(Self);
end;

function CnInt64PolynomialEccPointToString(const P: TCnInt64PolynomialEccPoint): string;
begin
  Result := Format('%s; %s', [P.X.ToString, P.Y.ToString]);
end;

function CnInt64PolynomialEccPointsEqual(P1, P2: TCnInt64PolynomialEccPoint): Boolean;
begin
  Result := Int64PolynomialEqual(P1.X, P2.X) and Int64PolynomialEqual(P1.Y, P2.Y);
end;

{ TCnInt64PolynomialEcc }

constructor TCnInt64PolynomialEcc.Create(A, B, FieldPrime: Int64; Ext: Integer;
  GX, GY: array of const; Order: Int64; PrimitivePolynomial: array of const);
begin
  inherited Create;

  // ����籣֤ Order Ϊ����
  if not CnInt64IsPrime(FieldPrime) then // or not CnInt64IsPrime(Order) then
    raise ECnEccException.Create('Infinite Field must be a Prime Number.');

  // ��������ô��� 1
  if Ext <= 1 then
    raise ECnEccException.Create('Field Extension must > 1.');

  // Ҫȷ�� 4*a^3+27*b^2 <> 0
  if 4 * A * A * A + 27 * B * B = 0 then
    raise ECnEccException.Create('Error: 4 * A^3 + 27 * B^2 = 0');

  FCoefficientA := A;
  FCoefficientB := B;
  FFiniteFieldSize := FieldPrime;
  FExtension := Ext;

  FGenerator := TCnInt64PolynomialEccPoint.Create;
  FGenerator.X.SetCoefficents(GX);
  FGenerator.Y.SetCoefficents(GY);

  FOrder := Order;

  FPrimitive := TCnInt64Polynomial.Create;
  FPrimitive.SetCoefficents(PrimitivePolynomial);
end;

destructor TCnInt64PolynomialEcc.Destroy;
begin
  FPrimitive.Free;
  FGenerator.Free;
  inherited;
end;

function TCnInt64PolynomialEcc.DivisionPolynomial(Degree: Integer;
  outDivisionPolynomial: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialGaloisCalcDivisionPolynomial(FCoefficientA, FCoefficientB,
    Degree, outDivisionPolynomial, FFiniteFieldSize);
end;

function TCnInt64PolynomialEcc.IsPointOnCurve(
  P: TCnInt64PolynomialEccPoint): Boolean;
var
  X, Y: TCnInt64Polynomial;
begin
  // ���� (Y^2 - X^3 - A*X - B) mod primitive ������ʽϵ������Ҫ mod p���Ƿ���� 0 ����ʽ
  Result := False;
  if P <> nil then
  begin
    X := nil;
    Y := nil;

    try
      X := FEccInt64PolynomialPool.Obtain;
      Y := FEccInt64PolynomialPool.Obtain;

      Int64PolynomialCopy(Y, P.Y);
      Int64PolynomialGaloisMul(Y, Y, Y, FFiniteFieldSize, FPrimitive);

      Int64PolynomialCopy(X, P.X);
      Int64PolynomialGaloisPower(X, X, 3, FFiniteFieldSize, FPrimitive);

      Int64PolynomialGaloisSub(Y, Y, X, FFiniteFieldSize, FPrimitive);                // Y := Y^2 - X^3

      Int64PolynomialCopy(X, P.X);
      Int64PolynomialMulWord(X, FCoefficientA);
      Int64PolynomialAddWord(X, FCoefficientB);   // X := A*X + B
      Int64PolynomialNonNegativeModWord(X, FFiniteFieldSize);

      Int64PolynomialGaloisSub(Y, Y, X, FFiniteFieldSize, FPrimitive);
      Int64PolynomialGaloisMod(Y, Y, FPrimitive, FFiniteFieldSize);

      Result := Y.IsZero;
    finally
      FEccInt64PolynomialPool.Recycle(Y);
      FEccInt64PolynomialPool.Recycle(X);
    end;
  end;
end;

class function TCnInt64PolynomialEcc.IsPointOnCurve2(PX,
  PY: TCnInt64Polynomial; A, B, APrime: Int64;
  APrimitive: TCnInt64Polynomial): Boolean;
var
  X, Y: TCnInt64Polynomial;
begin
  // ���� (Y^2 - X^3 - A*X - B) mod primitive ������ʽϵ������Ҫ mod p���Ƿ���� 0 ����ʽ
  X := nil;
  Y := nil;

  try
    X := FEccInt64PolynomialPool.Obtain;
    Y := FEccInt64PolynomialPool.Obtain;

    Int64PolynomialCopy(Y, PY);
    Int64PolynomialGaloisMul(Y, Y, Y, APrime, APrimitive);

    Int64PolynomialCopy(X, PX);
    Int64PolynomialGaloisPower(X, X, 3, APrime, APrimitive);

    Int64PolynomialGaloisSub(Y, Y, X, APrime, APrimitive);                // Y := Y^2 - X^3

    Int64PolynomialCopy(X, PX);
    Int64PolynomialMulWord(X, A);
    Int64PolynomialAddWord(X, B);   // X := A*X + B
    Int64PolynomialNonNegativeModWord(X, APrime);

    Int64PolynomialGaloisSub(Y, Y, X, APrime, APrimitive);
    Int64PolynomialGaloisMod(Y, Y, APrimitive, APrime);

    Result := Y.IsZero;
  finally
    FEccInt64PolynomialPool.Recycle(Y);
    FEccInt64PolynomialPool.Recycle(X);
  end;
end;

class function TCnInt64PolynomialEcc.IsRationalPointOnCurve(PX,
  PY: TCnInt64RationalPolynomial; A, B, APrime: Int64): Boolean;
var
  Y2, T1: TCnInt64Polynomial;
  RL, RR, T2: TCnInt64RationalPolynomial;
begin
  // ���� PY^2 * (x^3 + Ax + B) �Ƿ���� PX^3 + A * PX + B��ϵ���� mod APrime
  Y2 := nil;
  T1 := nil;
  T2 := nil;
  RL := nil;
  RR := nil;

  try
    Y2 := FEccInt64PolynomialPool.Obtain;
    Y2.SetCoefficents([B, A, 0, 1]);

    RL := TCnInt64RationalPolynomial.Create;
    Int64RationalPolynomialGaloisMul(PY, PY, RL, APrime);
    Int64RationalPolynomialGaloisMul(RL, Y2, RL, APrime);  // �õ��Ⱥ���ߵ�ֵ

    RR := TCnInt64RationalPolynomial.Create;
    Int64RationalPolynomialGaloisMul(PX, PX, RR, APrime);
    Int64RationalPolynomialGaloisMul(RR, PX, RR, APrime);  // �õ� PX^3
    
    T1 := FEccInt64PolynomialPool.Obtain;
    T1.SetCoefficents([A]);

    T2 := TCnInt64RationalPolynomial.Create;
    Int64RationalPolynomialGaloisMul(PX, T1, T2, APrime);  // T2 �õ� A * PX

    T1.SetCoefficents([B]);
    Int64RationalPolynomialGaloisAdd(T2, T1, T2, APrime);  // T2 �õ� A * PX + B

    Int64RationalPolynomialGaloisAdd(T2, RR, RR, APrime);  // RR �õ� PX^3 + A * PX + B

    Result := Int64RationalPolynomialEqual(RL, RR);       // �Ƚ��Ƿ����
  finally
    FEccInt64PolynomialPool.Recycle(Y2);
    FEccInt64PolynomialPool.Recycle(T1);
    T2.Free;
    RL.Free;
    RR.Free;
  end;
end;

procedure TCnInt64PolynomialEcc.MultiplePoint(K: Integer;
  Point: TCnInt64PolynomialEccPoint);
var
  E, R: TCnInt64PolynomialEccPoint;
begin
  if K = 0 then
  begin
    Point.SetZero;
    Exit;
  end
  else if K < 0 then
  begin
    K := -K;
    PointInverse(Point);
  end;

  R := nil;
  E := nil;

  try
    R := TCnInt64PolynomialEccPoint.Create;
    E := TCnInt64PolynomialEccPoint.Create;

    R.SetZero;
    E.Assign(Point);

    while K <> 0 do
    begin
      if (K and 1) <> 0 then
        PointAddPoint(R, E, R);

      PointAddPoint(E, E, E);
      K := K shr 1;
    end;

    Point.Assign(R);
  finally
    R.Free;
    E.Free;
  end;
end;

//class procedure TCnInt64PolynomialEcc.MultiplePoint1(K: Integer; PX,
//  PY: TCnInt64Polynomial; A, B, APrime: Int64;
//  APrimitive: TCnInt64Polynomial);
//var
//  EX, EY, RX, RY, SX, SY: TCnInt64Polynomial;
//begin
//  if K = 0 then
//  begin
//    PX.SetZero;
//    PY.SetZero;
//    Exit;
//  end
//  else if K < 0 then
//    raise ECnEccException.Create('Negative Multiple NOT Support');
//
//  EX := nil;
//  EY := nil;
//  RX := nil;
//  RY := nil;
//  SX := nil;
//  SY := nil;
//
//  try
//    EX := FEccInt64PolynomialPool.Obtain;
//    EY := FEccInt64PolynomialPool.Obtain;
//    RX := FEccInt64PolynomialPool.Obtain;
//    RY := FEccInt64PolynomialPool.Obtain;
//    SX := FEccInt64PolynomialPool.Obtain;
//    SY := FEccInt64PolynomialPool.Obtain;
//
//    RX.SetZero;
//    RY.SetZero;
//
//    Int64PolynomialCopy(EX, PX);
//    Int64PolynomialCopy(EY, PY);
//
//    while K <> 0 do
//    begin
//      if (K and 1) <> 0 then
//      begin
//        PointAddPoint1(RX, RY, EX, EY, SX, SY, A, B, APrime, APrimitive);
//        Int64PolynomialCopy(RX, SX);
//        Int64PolynomialCopy(RY, SY);
//      end;
//
//      PointAddPoint1(EX, EY, EX, EY, SX, SY, A, B, APrime, APrimitive);
//      Int64PolynomialCopy(EX, SX);
//      Int64PolynomialCopy(EY, SY);
//
//      K := K shr 1;
//    end;
//
//    Int64PolynomialCopy(PX, RX);
//    Int64PolynomialCopy(PY, RY);
//  finally
//    FEccInt64PolynomialPool.Recycle(EX);
//    FEccInt64PolynomialPool.Recycle(EY);
//    FEccInt64PolynomialPool.Recycle(RX);
//    FEccInt64PolynomialPool.Recycle(RY);
//    FEccInt64PolynomialPool.Recycle(SX);
//    FEccInt64PolynomialPool.Recycle(SY);
//  end;
//end;

procedure TCnInt64PolynomialEcc.PointAddPoint(P, Q,
  Sum: TCnInt64PolynomialEccPoint);
var
  K, X, Y, T: TCnInt64Polynomial;
begin
  K := nil;
  X := nil;
  Y := nil;
  T := nil;

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
    end
    else if Int64PolynomialEqual(P.X, Q.X) and Int64PolynomialEqual(P.Y, Q.Y) then
    begin
      // ��������ͬһ���㣬����б��Ϊ�����󵼣�3 * X^2 + A / (2 * Y) ���� Y = 0 ��ֱ��������Զ 0��
      X := FEccInt64PolynomialPool.Obtain;
      Y := FEccInt64PolynomialPool.Obtain;

      // X := 3 * P.X * P.X + FCoefficientA
      Int64PolynomialGaloisMul(X, P.X, P.X, FFiniteFieldSize, FPrimitive);
      Int64PolynomialGaloisMulWord(X, 3, FFiniteFieldSize);
      Int64PolynomialGaloisAddWord(X, FCoefficientA, FFiniteFieldSize);

      // Y := 2 * P.Y;
      Int64PolynomialCopy(Y, P.Y);
      Int64PolynomialGaloisMulWord(Y, 2, FFiniteFieldSize);

      if Y.IsZero then
      begin
        Sum.X.SetZero;
        Sum.Y.SetZero;
      end;

      // Y := Y^-1
      T := FEccInt64PolynomialPool.Obtain;
      Int64PolynomialCopy(T, Y);
      Int64PolynomialGaloisModularInverse(Y, T, FPrimitive, FFiniteFieldSize);

      // K := X * Y mod FFiniteFieldSize;
      K := FEccInt64PolynomialPool.Obtain;
      Int64PolynomialGaloisMul(K, X, Y, FFiniteFieldSize, FPrimitive);
      // �õ�����б�� K
    end
    else // �ǲ�ͬ��
    begin
      if Int64PolynomialEqual(P.X, Q.X) then // ��� X ��ȣ�Ҫ�ж� Y �ǲ��ǻ����������Ϊ 0�����������
      begin
        T := FEccInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisAdd(T, P.Y, Q.Y, FFiniteFieldSize);
        if T.IsZero then
          Sum.SetZero
        else
          raise ECnEccException.CreateFmt('Can NOT Calucate %s,%s + %s,%s',
            [P.X.ToString, P.Y.ToString, Q.X.ToString, Q.Y.ToString]);

        Exit;
      end;

      // �����X ȷ����ͬ��б�� K := ((Q.Y - P.Y) / (Q.X - P.X)) mod p
      X := FEccInt64PolynomialPool.Obtain;
      Y := FEccInt64PolynomialPool.Obtain;
      K := FEccInt64PolynomialPool.Obtain;

      Int64PolynomialGaloisSub(Y, Q.Y, P.Y, FFiniteFieldSize);
      Int64PolynomialGaloisSub(X, Q.X, P.X, FFiniteFieldSize);

      T := FEccInt64PolynomialPool.Obtain;
      Int64PolynomialCopy(T, X);
      Int64PolynomialGaloisModularInverse(X, T, FPrimitive, FFiniteFieldSize);
      Int64PolynomialGaloisMul(K, Y, X, FFiniteFieldSize, FPrimitive); // �õ�б��
    end;

    //  X := K * K - P.X - Q.X;
    Int64PolynomialCopy(X, K);
    Int64PolynomialGaloisMul(X, X, K, FFiniteFieldSize, FPrimitive);
    Int64PolynomialGaloisSub(X, X, P.X, FFiniteFieldSize);
    Int64PolynomialGaloisSub(X, X, Q.X, FFiniteFieldSize);

    // Ysum = (K * (X1 - Xsum) - Y1) mod p
    Int64PolynomialGaloisSub(X, P.X, X, FFiniteFieldSize);
    Int64PolynomialGaloisMul(Y, K, X, FFiniteFieldSize, FPrimitive);
    Int64PolynomialGaloisSub(Y, Y, P.Y, FFiniteFieldSize);

    Int64PolynomialCopy(Sum.X, X);
    Int64PolynomialCopy(Sum.Y, Y);
  finally
    FEccInt64PolynomialPool.Recycle(K);
    FEccInt64PolynomialPool.Recycle(X);
    FEccInt64PolynomialPool.Recycle(Y);
    FEccInt64PolynomialPool.Recycle(T);
  end;
end;

class procedure TCnInt64PolynomialEcc.PointAddPoint1(PX, PY, QX, QY, SX,
  SY: TCnInt64Polynomial; A, B, APrime: Int64; APrimitive: TCnInt64Polynomial);
var
  R, E, T1, T2, T3: TCnInt64Polynomial;
begin
  // �÷���Ϊ Schoof �㷨��ʹ�ã�����ĵ���������У�a(x), b(x) * y) ����ʽ
  // (PX(x), PY(x) * y) + (QX(x), QY(x) * y) = (SX(x), SY(x) * y)

  // ����б�ʱ��ʽ��X ��ͬʱб��Ϊ y * (PY-QY)/(PX-QX) ����ͬʱб��Ϊ y * (3*PX^2 + A)/(2*PY * (x^3+Ax+B))
  // �� R ����б���� y ��ϵ������ô SX = R^2 * (x^3+Ax+B) - PX - QX       SY = R * (PX - SX) - PY

  R := nil;
  E := nil;
  T1 := nil;
  T2 := nil;
  T3 := nil;

  try
    R := FEccInt64PolynomialPool.Obtain;
    E := FEccInt64PolynomialPool.Obtain;
    T1 := FEccInt64PolynomialPool.Obtain;
    T2 := FEccInt64PolynomialPool.Obtain;
    T3 := FEccInt64PolynomialPool.Obtain;

    E.SetCoefficents([B, A, 0, 1]);
    if Int64PolynomialEqual(PX, QX) then
    begin
      if not Int64PolynomialEqual(PY, QY) then // ��ֱ
      begin
        SX.SetZero;
        SY.SetZero;
        Exit;
      end;

      // ������б�ʣ����� (3*PX^2 + A)/(2*PY * (x^3+Ax+B))
      Int64PolynomialGaloisMul(T1, PX, PX, APrime, APrimitive);
      Int64PolynomialGaloisMulWord(T1, 3, APrime);
      Int64PolynomialGaloisAddWord(T1, A, APrime); // T1 �õ� 3*PX^2 + A

      Int64PolynomialCopy(T2, PY);
      Int64PolynomialGaloisMulWord(T2, 2, APrime);
      Int64PolynomialGaloisMul(T2, T2, E, APrime, APrimitive); // T2 �õ� 2*PY * (x^3+Ax+B)

      Int64PolynomialGaloisModularInverse(T3, T2, APrimitive, APrime); // T3 �õ� T2^-1
      Int64PolynomialGaloisMul(R, T1, T3, APrime, APrimitive);         // R �õ�����б��
    end
    else
    begin
      // ������б�ʣ����� (PY-QY)/(PX-QX)
      Int64PolynomialGaloisSub(T1, PY, QY, APrime, APrimitive);
      Int64PolynomialGaloisSub(T2, PX, QX, APrime, APrimitive);
      Int64PolynomialGaloisModularInverse(T3, T2, APrimitive, APrime); // T3 �õ� T2^-1
      Int64PolynomialGaloisMul(R, T1, T3, APrime, APrimitive);         // R �õ�����б��
    end;

    // б����ú���͵㣬SX = R^2 * (x^3+Ax+B) - PX - QX
    Int64PolynomialCopy(T1, R);
    Int64PolynomialGaloisMul(T1, T1, T1, APrime, APrimitive);
    Int64PolynomialGaloisMul(T1, T1, E, APrime, APrimitive); // T1 �õ� R^2 * (x^3+Ax+B)

    Int64PolynomialGaloisSub(SX, T1, PX, APrime);
    Int64PolynomialGaloisSub(SX, SX, QX, APrime);            // ��� SX

    // ���� SY = R * (PX - SX) - PY
    Int64PolynomialGaloisSub(T1, PX, SX, APrime);
    Int64PolynomialGaloisMul(T2, R, T1, APrime, APrimitive);
    Int64PolynomialGaloisSub(SY, T2, PY, APrime);            // ��� SY
  finally
    FEccInt64PolynomialPool.Recycle(T3);
    FEccInt64PolynomialPool.Recycle(T2);
    FEccInt64PolynomialPool.Recycle(T1);
    FEccInt64PolynomialPool.Recycle(E);
    FEccInt64PolynomialPool.Recycle(R);
  end;
end;

class procedure TCnInt64PolynomialEcc.PointAddPoint2(PX, PY, QX, QY,
  SX, SY: TCnInt64Polynomial; A, B, APrime: Int64;
  APrimitive: TCnInt64Polynomial);
var
  K, X, Y, T: TCnInt64Polynomial;
begin
  K := nil;
  X := nil;
  Y := nil;
  T := nil;

  try
    if PX.IsZero and PY.IsZero then
    begin
      Int64PolynomialCopy(SX, QX);
      Int64PolynomialCopy(SY, QY);
      Exit;
    end
    else if QX.IsZero and QY.IsZero then
    begin
      Int64PolynomialCopy(SX, PX);
      Int64PolynomialCopy(SY, PY);
      Exit;
    end
    else if Int64PolynomialEqual(PX, QX) and Int64PolynomialEqual(PY, QY) then
    begin
      // ��������ͬһ���㣬����б��Ϊ�����󵼣�3 * X^2 + A / (2 * Y) ���� Y = 0 ��ֱ��������Զ 0��
      X := FEccInt64PolynomialPool.Obtain;
      Y := FEccInt64PolynomialPool.Obtain;

      // X := 3 * PX * PX + A
      Int64PolynomialGaloisMul(X, PX, PX, APrime, APrimitive);
      Int64PolynomialGaloisMulWord(X, 3, APrime);
      Int64PolynomialGaloisAddWord(X, A, APrime);

      // Y := 2 * PY;
      Int64PolynomialCopy(Y, PY);
      Int64PolynomialGaloisMulWord(Y, 2, APrime);

      if Y.IsZero then
      begin
        SX.SetZero;
        SY.SetZero;
      end;

      // Y := Y^-1
      T := FEccInt64PolynomialPool.Obtain;
      Int64PolynomialCopy(T, Y);
      Int64PolynomialGaloisModularInverse(Y, T, APrimitive, APrime);

      // K := X * Y mod APrime;
      K := FEccInt64PolynomialPool.Obtain;
      Int64PolynomialGaloisMul(K, X, Y, APrime, APrimitive);
      // �õ�����б�� K
    end
    else // �ǲ�ͬ��
    begin
      if Int64PolynomialEqual(PX, QX) then // ��� X ��ȣ�Ҫ�ж� Y �ǲ��ǻ����������Ϊ 0�����������
      begin
        T := FEccInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisAdd(T, PY, QY, APrime);
        if T.IsZero then
        begin
          SX.SetZero;
          SY.SetZero;
        end
        else
          raise ECnEccException.CreateFmt('Can NOT Calucate %s,%s + %s,%s',
            [PX.ToString, PY.ToString, QX.ToString, QY.ToString]);

        Exit;
      end;

      // �����X ȷ����ͬ��б�� K := ((QY - PY) / (QX - PX)) mod p
      X := FEccInt64PolynomialPool.Obtain;
      Y := FEccInt64PolynomialPool.Obtain;
      K := FEccInt64PolynomialPool.Obtain;

      Int64PolynomialGaloisSub(Y, QY, PY, APrime);
      Int64PolynomialGaloisSub(X, QX, PX, APrime);

      T := FEccInt64PolynomialPool.Obtain;
      Int64PolynomialCopy(T, X);
      Int64PolynomialGaloisModularInverse(X, T, APrimitive, APrime);
      Int64PolynomialGaloisMul(K, Y, X, APrime, APrimitive); // �õ�б��
    end;

    //  X := K * K - PX - QX;
    Int64PolynomialCopy(X, K);
    Int64PolynomialGaloisMul(X, X, K, APrime, APrimitive);
    Int64PolynomialGaloisSub(X, X, PX, APrime);
    Int64PolynomialGaloisSub(X, X, QX, APrime);

    // SY = (K * (X1 - SX) - Y1) mod p
    Int64PolynomialGaloisSub(X, PX, X, APrime);
    Int64PolynomialGaloisMul(Y, K, X, APrime, APrimitive);
    Int64PolynomialGaloisSub(Y, Y, PY, APrime);

    Int64PolynomialCopy(SX, X);
    Int64PolynomialCopy(SY, Y);
  finally
    FEccInt64PolynomialPool.Recycle(K);
    FEccInt64PolynomialPool.Recycle(X);
    FEccInt64PolynomialPool.Recycle(Y);
    FEccInt64PolynomialPool.Recycle(T);
  end;
end;

procedure TCnInt64PolynomialEcc.PointInverse(
  P: TCnInt64PolynomialEccPoint);
var
  I: Integer;
begin
  for I := 0 to P.Y.MaxDegree do
    P.Y[I] := FFiniteFieldSize - P.Y[I];
end;

procedure TCnInt64PolynomialEcc.PointSubPoint(P, Q,
  Diff: TCnInt64PolynomialEccPoint);
var
  Inv: TCnInt64PolynomialEccPoint;
begin
  Inv := TCnInt64PolynomialEccPoint.Create;
  try
    Inv.Assign(Q);
    PointInverse(Inv);
    PointAddPoint(P, Inv, Diff);
  finally
    Inv.Free;
  end;
end;

class procedure TCnInt64PolynomialEcc.RationalMultiplePoint(K: Integer;
  MX, MY: TCnInt64RationalPolynomial; A, B, APrime: Int64);
var
  Neg: Boolean;
  FN, FNa1, FNa2, FNs1, FNs2, P1, P2, X1, Y2: TCnInt64Polynomial;
begin
  if K = 0 then
  begin
    MX.SetZero;
    MY.SetZero;
    Exit;
  end;

  Neg := K < 0;
  if Neg then
    K := -K;

  if K = 1 then // û�ˣ�ԭ�ⲻ������ x �� 1
  begin
    MX.Nominator.SetCoefficents([0, 1]);
    MX.Denominator.SetOne;

    MY.Nominator.SetOne;
    MY.Denominator.SetOne;
  end
  else
  begin
    FN := FEccInt64PolynomialPool.Obtain;
    FNa1 := FEccInt64PolynomialPool.Obtain;
    FNa2 := FEccInt64PolynomialPool.Obtain;
    FNs1 := FEccInt64PolynomialPool.Obtain;
    FNs2 := FEccInt64PolynomialPool.Obtain;
    X1 := FEccInt64PolynomialPool.Obtain;
    Y2 := FEccInt64PolynomialPool.Obtain;
    P1 := FEccInt64PolynomialPool.Obtain;
    P2 := FEccInt64PolynomialPool.Obtain;

    try
      X1.SetCoefficents([0, 1]);
      Y2.SetCoefficents([B, A, 0, 1]);

      Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K, FN, APrime);
      Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K + 1, FNa1, APrime);
      Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K + 2, FNa2, APrime);
      Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K - 1, FNs1, APrime);
      Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K - 2, FNs2, APrime);

      // �� X ���ʽ
      if (K and 1) = 0 then // K ż��ʱ
      begin
        // ����� x ����Ϊ (x*fn^2 * Y^2 - fn+1 * fn-1) / fn^2 * Y^2
        Int64PolynomialGaloisMul(MX.Denominator, FN, FN, APrime);
        Int64PolynomialGaloisMul(MX.Denominator, MX.Denominator, Y2, APrime);

        Int64PolynomialGaloisMul(P1, FNa1, FNs1, APrime); // P1 �õ� fn+1 * fn-1
        Int64PolynomialGaloisMul(P2, FN, FN, APrime);
        Int64PolynomialGaloisMul(P2, P2, X1, APrime);     // P2 �õ� x*fn^2
        Int64PolynomialGaloisMul(P2, P2, Y2, APrime);     // P2 �õ� x*fn^2 * Y^2

        Int64PolynomialGaloisSub(MX.Nominator, P2, P1, APrime); // MX �������
      end
      else // K ����ʱ
      begin
        // ����� x ����Ϊ (x*fn^2 - Y^2 * fn+1 * fn-1) / fn^2
        Int64PolynomialGaloisMul(MX.Denominator, FN, FN, APrime);

        Int64PolynomialGaloisMul(P1, FNa1, FNs1, APrime); // P1 �õ� fn+1 * fn-1
        Int64PolynomialGaloisMul(P1, P1, Y2, APrime);     // P1 �õ� Y^2 * fn+1 * fn-1

        Int64PolynomialGaloisMul(P2, FN, FN, APrime);
        Int64PolynomialGaloisMul(P2, P2, X1, APrime);     // P2 �õ� x*fn^2
        Int64PolynomialGaloisSub(MX.Nominator, P2, P1, APrime); // MX �������
      end;

      // �� Y ���ʽ
      if K = 2 then // Y �ķ����� f2n��n Ϊ 2 ʱ����ݹ飬ֱ���� f4
      begin
        Int64PolynomialCopy(MY.Nominator, FNa2);
      end
      else
      begin
        // ����� y �������Ϊ fn+2 * fn-1^2 - fn-2 * fn+1 ^2
        Int64PolynomialGaloisMul(P1, FNs1, FNs1, APrime);
        Int64PolynomialGaloisMul(P1, P1, FNa2, APrime);
        Int64PolynomialGaloisMul(P2, FNa1, FNa1, APrime);
        Int64PolynomialGaloisMul(P2, P2, FNs2, APrime);

        Int64PolynomialGaloisSub(MY.Nominator, P1, P2, APrime); // MY ���Ӽ������
      end;

      Int64PolynomialGaloisPower(MY.Denominator, FN, 3, APrime);
      Int64PolynomialGaloisMulWord(MY.Denominator, 4, APrime);   // ������ĸ 4 * fn^3 �������

      if (K and 1) = 0 then // ż����ĸ���ó��� y^4
      begin
        Int64PolynomialGaloisMul(MY.Denominator, Y2, MY.Denominator, APrime);
        Int64PolynomialGaloisMul(MY.Denominator, Y2, MY.Denominator, APrime);
      end;
    finally
      FEccInt64PolynomialPool.Recycle(FN);
      FEccInt64PolynomialPool.Recycle(FNa1);
      FEccInt64PolynomialPool.Recycle(FNa2);
      FEccInt64PolynomialPool.Recycle(FNs1);
      FEccInt64PolynomialPool.Recycle(FNs2);
      FEccInt64PolynomialPool.Recycle(X1);
      FEccInt64PolynomialPool.Recycle(Y2);
      FEccInt64PolynomialPool.Recycle(P1);
      FEccInt64PolynomialPool.Recycle(P2);
    end;
  end;

  if Neg then
    MY.Neg;
end;

class procedure TCnInt64PolynomialEcc.RationalPointAddPoint(PX, PY, QX, QY,
  SX, SY: TCnInt64RationalPolynomial; A, B, APrime: Int64; XEqual, YEqual: Boolean);
var
  R, T1, T2: TCnInt64RationalPolynomial;
  Y2, C: TCnInt64Polynomial;
begin
  // �� (PX, PY * y) + (QX, QY * y) = (SX, SY * y)
  // ����б�� R = (QY - PY) / (QX - PX) �� 3PX^2 + A) / 2PY (x^3+Ax+B)

  R := nil;
  T1 := nil;
  T2 := nil;

  Y2 := nil;
  C := nil;

  try
    R := TCnInt64RationalPolynomial.Create;
    T1 := TCnInt64RationalPolynomial.Create;
    T2 := TCnInt64RationalPolynomial.Create;

    Y2 := FEccInt64PolynomialPool.Obtain;
    C := FEccInt64PolynomialPool.Obtain;

    if XEqual or Int64RationalPolynomialEqual(PX, QX) then
    begin
      // X ��ȣ��ж� Y �Ƿ���ȣ������򷵻� 0
      if not Int64RationalPolynomialEqual(PY, QY) and not YEqual then
      begin
        // ��� PY��QY ��ʽ��ȣ����ܽ����Ҫ��ȥ
        // ��� PY��QY ��ʽ���ȣ��� YEqual Ϊ True��Ҳ���ܽ����Ҫ��ȥ
        // Ҳ������ʽ���ȣ���û��������� YEqual���ű�ʾ Y ȷʵ���ȣ�������
        SX.SetZero;
        SY.SetZero;
        Exit;
      end;

      // X Y ����ȣ���
      Y2.SetCoefficents([B, A, 0, 1]);
      C.SetCoefficents([3]);

      Int64RationalPolynomialGaloisMul(PX, PX, T1, APrime);
      Int64RationalPolynomialGaloisMul(T1, C, T1, APrime);  // T1 �õ� 3PX^2

      C.SetCoefficents([A]);
      Int64RationalPolynomialGaloisAdd(T1, C, T1, APrime);  // T1 �õ� 3PX^2 + A

      C.SetCoefficents([2]);
      Int64RationalPolynomialGaloisMul(PY, Y2, T2, APrime); // T2 �õ� PY * (x^3+Ax+B)
      Int64RationalPolynomialGaloisMul(T2, C, T2, APrime);  // T2 �õ� 2PY * (x^3+Ax+B)

      Int64RationalPolynomialGaloisDiv(T1, T2, R, APrime);
    end
    else
    begin
      // ����ȣ���
      Int64RationalPolynomialGaloisSub(QY, PY, T1, APrime);
      Int64RationalPolynomialGaloisSub(QX, PX, T2, APrime);
      Int64RationalPolynomialGaloisDiv(T1, T2, R, APrime);
    end;

    // R �õ�б����
    // SX = R^2 * (x^3+Ax+B) - PX - QX
    Int64RationalPolynomialGaloisMul(R, R, SX, APrime);
    Int64RationalPolynomialGaloisMul(SX, Y2, SX, APrime);
    Int64RationalPolynomialGaloisSub(SX, PX, SX, APrime);
    Int64RationalPolynomialGaloisMul(SX, QX, SX, APrime);

    // SY = R * (PX - SX) - PY
    Int64RationalPolynomialGaloisSub(PX, SX, SY, APrime);
    Int64RationalPolynomialGaloisMul(SY, R, SY, APrime);
    Int64RationalPolynomialGaloisSub(SY, PY, SY, APrime);
  finally
    FEccInt64PolynomialPool.Recycle(Y2);
    FEccInt64PolynomialPool.Recycle(C);

    T2.Free;
    T1.Free;
    R.Free;
  end;
end;

procedure TCnInt64PolynomialEcc.SetPrimitive(
  const Value: TCnInt64Polynomial);
begin
  if Value <> nil then
  begin
    if Value.MaxDegree <> FExtension then
      raise ECnEccException.Create('Primitive Polynomial Max Degree must be Field Extension.');
    Int64PolynomialCopy(FPrimitive, Value);
  end;
end;

procedure CnInt64GenerateGaloisDivisionPolynomials(A, B, Prime: Int64; MaxDegree: Integer;
  PolynomialList: TObjectList);
var
  I, N: Integer;

  // ���ص� Degree ���ɳ����ʽ�����ã���ͬʱ���� PolynomialList �Ķ�Ӧλ�ã�ע�ⷵ��ֵ��Ҫ�Ķ�
  function GetInt64GaloisDivisionPolynomial(Degree: Integer): TCnInt64Polynomial;
  var
    MI: Int64;
    F1, F2, F3, F4, F5: TCnInt64Polynomial;  // �ӵݹ� GetInt64GaloisDivisionPolynomial �õ������ã�������Ķ�
    D1, D2, D3, Y4: TCnInt64Polynomial;      // �����м�����Ҫ����Ҫ�ͷ�
  begin
    if PolynomialList[Degree] <> nil then // ����л���ͷ��ػ����
    begin
      Result := TCnInt64Polynomial(PolynomialList[Degree]);
      Exit;
    end;

    if Degree = 0 then
    begin
      Result := TCnInt64Polynomial.Create;
      Result.SetCoefficents([0]);  // f0(X) = 0
      PolynomialList[0] := Result;
    end
    else if Degree = 1 then
    begin
      Result := TCnInt64Polynomial.Create;
      Result.SetCoefficents([1]);  // f1(X) = 1
      PolynomialList[1] := Result;
    end
    else if Degree = 2 then
    begin
      Result := TCnInt64Polynomial.Create;
      Result.SetCoefficents([2]);  // f2(X) = 2
      PolynomialList[2] := Result;
    end
    else if Degree = 3 then   // f3(X) = 3 X4 + 6 a X2 + 12 b X - a^2
    begin
      Result := TCnInt64Polynomial.Create;
      Result.SetCoefficents([- A * A,
        12 * B, 6 * A, 0, 3]);
      Int64PolynomialNonNegativeModWord(Result, Prime);
      PolynomialList[3] := Result;
    end
    else if Degree = 4 then // f4(X) = 4 X6 + 20 a X4 + 80 b X3 - 20 a2X2 - 16 a b X - 4 a3 - 32 b^2
    begin
      Result := TCnInt64Polynomial.Create;
      Result.SetCoefficents([-4 * A * A * A - 32 * B * B,
        -16 * A * B, -20 * A * A, 80 * B, 20 * A, 0, 4]);
      Int64PolynomialNonNegativeModWord(Result, Prime);
      PolynomialList[4] := Result;
    end
    else
    begin
      // ����� Degree ���ɳ����ʽ���м���ܵݹ���õ�����ͬ�������ӻ�����ȡ
      D1 := nil;
      D2 := nil;
      D3 := nil;
      Y4 := nil;

      try
        // ��ʼ�ݹ����
        N := Degree shr 1;
        if (Degree and 1) = 0 then // Degree ��ż��
        begin
          F1 := GetInt64GaloisDivisionPolynomial(N + 2); // F1 �õ� Fn+2
          F2 := GetInt64GaloisDivisionPolynomial(N - 1); // F2 �õ� Fn-1

          D2 := FEccInt64PolynomialPool.Obtain;
          Int64PolynomialGaloisMul(D2, F2, F2, Prime);   // D2 �õ� Fn-1 ^ 2

          D1 := FEccInt64PolynomialPool.Obtain;
          Int64PolynomialGaloisMul(D1, F1, D2, Prime);   // D1 �õ� Fn+2 * Fn-1 ^ 2

          F3 := GetInt64GaloisDivisionPolynomial(N - 2);  // F3 �õ� Fn-2
          F4 := GetInt64GaloisDivisionPolynomial(N + 1);  // F4 �õ� Fn+1

          Int64PolynomialGaloisMul(D2, F4, F4, Prime);   // D2 �õ� Fn+1 ^ 2
          Int64PolynomialGaloisMul(D2, D2, F3, Prime);   // D2 �õ� Fn-2 * Fn+1 ^ 2

          Int64PolynomialGaloisSub(D1, D1, D2, Prime);   // D1 �õ� Fn+2 * Fn-1 ^ 2 - Fn-2 * Fn+1 ^ 2

          F5 := GetInt64GaloisDivisionPolynomial(N);     // F5 �õ� Fn

          Result := TCnInt64Polynomial.Create;
          Int64PolynomialGaloisMul(Result, F5, D1, Prime);           // ��˵õ� Fn * (Fn+2 * Fn-1 ^ 2 - Fn-2 * Fn+1 ^ 2)

          MI := CnInt64ModularInverse(2, Prime);
          Int64PolynomialGaloisMulWord(Result, MI, Prime);           // �ٳ��� 2

          PolynomialList[Degree] := Result;
        end
        else // Degree ������
        begin
          Y4 := FEccInt64PolynomialPool.Obtain;
          Y4.SetCoefficents([B, A, 0, 1]);
          Int64PolynomialGaloisMul(Y4, Y4, Y4, Prime);

          F1 := GetInt64GaloisDivisionPolynomial(N + 2); // F1 �õ� Fn+2

          D2 := FEccInt64PolynomialPool.Obtain;
          F2 := GetInt64GaloisDivisionPolynomial(N);     // F2 �õ� Fn
          Int64PolynomialGaloisPower(D2, F2, 3, Prime);  // D2 �õ� Fn^3

          D3 := FEccInt64PolynomialPool.Obtain;
          F3 := GetInt64GaloisDivisionPolynomial(N + 1); // F3 �õ� Fn+1
          Int64PolynomialGaloisPower(D3, F3, 3, Prime);  // D3 �õ� Fn+1 ^ 3

          if (N and 1) <> 0 then // N ������
          begin
            D1 := FEccInt64PolynomialPool.Obtain;
            Int64PolynomialGaloisMul(D1, F1, D2, Prime);     // D1 �õ� Fn+2 * Fn ^ 3�����ͷ� D2

            F4 := GetInt64GaloisDivisionPolynomial(N - 1);
            Int64PolynomialGaloisMul(D2, F4, Y4, Prime);     // D2 �õ� Fn-1 * Y^2

            Int64PolynomialGaloisMul(D2, D2, D3, Prime);     // D2 �õ� Fn+1 ^ 3 * Fn-1(Y)

            Result := TCnInt64Polynomial.Create;
            Int64PolynomialGaloisSub(Result, D1, D2, Prime); // D1 - D2

            PolynomialList[Degree] := Result;
          end
          else // N ��ż��
          begin
            D1 := FEccInt64PolynomialPool.Obtain;
            Int64PolynomialGaloisMul(D1, F1, D2, Prime);     // D1 �õ� Fn+2 * Fn ^ 3�����ͷ� D2
            Int64PolynomialGaloisMul(D1, D1, Y4, Prime);     // D1 �õ� Y * Fn+2 * Fn ^ 3

            F4 := GetInt64GaloisDivisionPolynomial(N - 1);   // F4 �õ� Fn-1

            Int64PolynomialGaloisMul(D2, F4, D3, Prime);     // D2 �õ� Fn+1 ^ 3 * Fn-1

            Result := TCnInt64Polynomial.Create;
            Int64PolynomialGaloisSub(Result, D1, D2, Prime); // D1 - D2

            PolynomialList[Degree] := Result;
          end;
        end;
      finally
        FEccInt64PolynomialPool.Recycle(D1);
        FEccInt64PolynomialPool.Recycle(D2);
        FEccInt64PolynomialPool.Recycle(D3);
        FEccInt64PolynomialPool.Recycle(Y4);
      end;
    end;
  end;

begin
  // ���� 0 �� MaxDegree �Ŀɳ�����ʽ���洢�� PolynomialList �С�
  PolynomialList.Clear;
  PolynomialList.Count := MaxDegree + 1;

  for I := 0 to MaxDegree do
    GetInt64GaloisDivisionPolynomial(I);
end;

function CnInt64EccSchoof(A, B, Q: Int64): Int64;
var
  Pa, Ta: TCnInt64List;
  QMul, QMax, L, K, W: Int64;
  I, J: Integer;
  F, G, Y2, P1, P2, P3, P4, LDP: TCnInt64Polynomial;
  AlphaEvenNoY, BetaEven, AlphaOdd, BetaOddNoY: TCnInt64Polynomial; // ��ʾб�ʵķ��ӷ�ĸ�ı��ʽ
  F1, F2, F3, F4, F5: TCnInt64Polynomial; // �ɳ�����ʽ���ã����ɸı�
  DPs: TObjectList;
begin
  // �� Schoof �㷨����Բ���� y^2 = x^3 + Ax + B ������ Fq �ϵĵ�����
  // �Ƚ��� List��������� 2 ~ lmax ������������ 3 * ... * lmax �պ� > 4 ������ q
  // �� x^q -x �� x^3 + Ax + B �Ĺ���ʽ������� 1 �� t2 = 1������ t2 = 0��
  // ���� t2 �� List ��������� 2 ��Ԫ�أ������±꣬����ͬ

  Pa := TCnInt64List.Create;
  Ta := TCnInt64List.Create;

  Y2 := FEccInt64PolynomialPool.Obtain;
  P1 := FEccInt64PolynomialPool.Obtain;
  P2 := FEccInt64PolynomialPool.Obtain;
  P3 := FEccInt64PolynomialPool.Obtain;
  P4 := FEccInt64PolynomialPool.Obtain;
  AlphaEvenNoY := FEccInt64PolynomialPool.Obtain;
  BetaEven := FEccInt64PolynomialPool.Obtain;
  AlphaOdd := FEccInt64PolynomialPool.Obtain;
  BetaOddNoY := FEccInt64PolynomialPool.Obtain;

  F := FEccInt64PolynomialPool.Obtain;
  G := FEccInt64PolynomialPool.Obtain;

  QMax := 1 + 4 * UInt64Sqrt(Q);
  QMul := 1;
  I := Low(CN_PRIME_NUMBERS_SQRT_UINT32);

  DPs := nil;

  try
    Pa := TCnInt64List.Create;
    Ta := TCnInt64List.Create;

    while (QMul <= QMax) and (I <= High(CN_PRIME_NUMBERS_SQRT_UINT32)) do
    begin
      QMul := QMul * CN_PRIME_NUMBERS_SQRT_UINT32[I];
      Pa.Add(CN_PRIME_NUMBERS_SQRT_UINT32[I]);
      Ta.Add(0);
      Inc(I);
    end;

    if I > High(CN_PRIME_NUMBERS_SQRT_UINT32) then
      raise ECnEccException.Create('Prime Number is Too Large.');

    // Ta �� Pa ������׼����
    P1.MaxDegree := Q;
    P1[0] := -1;          // P1 := X^q - X

    P2.SetCoefficents([B, A, 0, 1]); // P2 := X^3 + AX + B
    Int64PolynomialGaloisGreatestCommonDivisor(G, P1, P2, Q);
    if G.IsOne then
      Ta[0] := 1
    else
      Ta[0] := 0;   // ��� T2

    // ��ǰ���������� + 2 �׵Ŀɳ�����ʽ���Լ�׼���� Y^2
    DPs := TObjectList.Create(True);
    CnInt64GenerateGaloisDivisionPolynomials(A, B, Q, Pa[Pa.Count - 1] + 2, DPs);
    Y2.SetCoefficents([B, A, 0, 1]);

    // �������� G������ x-x^(q^2)
    G.Clear;
    G.MaxDegree := Q * Q;
    G[Q * Q] := -1;
    G[1] := 1;

    for I := 1 to Ta.Count - 1 do  // ���ÿһ�� L
    begin
      L := Pa[I];
      K := Q mod L;

      // �ȵõ� L �׿ɳ�����ʽ����Ϊ���������ģ����ʽ
      LDP := TCnInt64Polynomial(DPs[L]);
LDP.ToString;

      // ���ж��Ƿ����һ���㣬�� ��^2(P) = ���� K * (P)��Ҳ���Ǽ���һ�� GCD

      P1.Clear;
      P1.MaxDegree := Q * Q;
      P1[Q * Q] := 1;
      P1[1] := 1;           // P1 �� x^q^2 -x

      if (K and 1) = 0 then // K ��ż��
      begin
        // �� (x^q^2 - x) * Fk^2 * (x^3 + Ax + B) + Fk-1 * Fk+1
        F1 := TCnInt64Polynomial(DPs[K]);         // �õ� Fk
        F2 := TCnInt64Polynomial(DPs[K - 1]);     // �õ� Fk-1
        F3 := TCnInt64Polynomial(DPs[K + 1]);     // �õ� Fk+1

        Int64PolynomialGaloisMul(P2, F1, F1, Q);  // �õ� Fk^2
        Int64PolynomialGaloisMul(P2, P2, Y2, Q);  // �õ� Fk^2 * (x^3 + Ax + B)
        Int64PolynomialGaloisMul(P2, P2, P1, Q);  // �õ� (x^q^2 - x) * Fk^2 * (x^3 + Ax + B)

        Int64PolynomialGaloisMul(P3, F2, F3, Q);  // �õ� Fk-1 * Fk+1
        Int64PolynomialGaloisAdd(P3, P2, P2, Q);  // P3 �õ�����ʽ
      end
      else // K ������
      begin
        // �� (x^q^2 - x)* Fk^2 + Fk-1 * Fk+1 * (x^3 + Ax + B)
        F1 := TCnInt64Polynomial(DPs[K]);         // �õ� Fk
        F2 := TCnInt64Polynomial(DPs[K - 1]);     // �õ� Fk-1
        F3 := TCnInt64Polynomial(DPs[K + 1]);     // �õ� Fk+1

        Int64PolynomialGaloisMul(P2, F1, F1, Q);  // �õ� Fk^2
        Int64PolynomialGaloisMul(P2, P2, P1, Q);  // �õ� (x^q^2 - x) * Fk^2

        Int64PolynomialGaloisMul(P3, F2, F3, Q);  // �õ� Fk-1 * Fk+1
        Int64PolynomialGaloisMul(P3, P3, Y2, Q);  // �õ� (Fk-1 * Fk+1) * (x^3 + Ax + B)
        Int64PolynomialGaloisAdd(P3, P3, P2, Q);  // P3 �õ�����ʽ
      end;

      Int64PolynomialGreatestCommonDivisor(P2, P3, LDP); // �����Լʽ
      if P2.IsOne then
      begin
        // û�в����� 1 �Ĺ����ӣ�˵�� ��^2(P) <> ���� K * P����Ҫ������
        // ��Թ�ʽ ��^2(P) + K * (P) = t * ��(P) �ȼ�����ߵĺ͵�ֵ��
        // ����������� X ���겻ͬ�����Կ��������б��Ϊ Alpha/Beta ���ӱ��ʽ
        // �����й��� k �׿ɳ�����ʽ�ı��ʽ���ٺ͵�ʽ�ұ���Ӧ�õ��ڵļ��� ��P ��ֵ�����Ա�

        // ���� Alpha Beta���� K ����ż�ԣ��ڵ���ѭ���䱣�ֲ���
        F1 := TCnInt64Polynomial(DPs[K]);
        F2 := TCnInt64Polynomial(DPs[K - 2]);
        F3 := TCnInt64Polynomial(DPs[K - 1]);
        F4 := TCnInt64Polynomial(DPs[K + 1]);
        F5 := TCnInt64Polynomial(DPs[K + 2]);

        if (K and 1) = 0 then // K ��ż��
        begin
          // �� AlphaEvenNoY��BetaEven
          Int64PolynomialGaloisMul(P1, F3, F3, Q);  // P1 �õ� Fk-1^2
          Int64PolynomialGaloisMul(P1, P1, F5, Q);  // P1 �õ� Fk-1^2 * Fk+2

          Int64PolynomialGaloisMul(P2, F4, F4, Q);  // P2 �õ� Fk+1^2
          Int64PolynomialGaloisMul(P2, P2, F2, Q);  // P2 �õ� Fk+1^2 * Fk-2

          Int64PolynomialGaloisSub(P1, P1, P2, Q);  // P1 - P2

          Int64PolynomialGaloisPower(P2, F1, 3, Q); // P2 �õ� Fk^3
          Int64PolynomialGaloisMulWord(P2, 4, Q);   // P2 �õ� 4 * Fk^3

          Int64PolynomialGaloisPower(P3, Y2, (Q * Q + 3) shr 1, Q); // P3 �õ� Y^(Q^2+3)
          Int64PolynomialGaloisMul(P2, P2, P3, Q);                  // P2 �õ� 4 * Fk^3 * Y^(Q^2+3)
          Int64PolynomialGaloisSub(AlphaEvenNoY, P1, P2, Q);        // �õ� AlphaEvenNoY��ʵ�ʵ� AlphaEven ���滹�����һ�� y

          // ���� G �Ѿ��� x-x^(q^2)
          Int64PolynomialGaloisMul(P1, F1, F1, Q);
          Int64PolynomialGaloisMul(P1, P1, Y2, Q);
          Int64PolynomialGaloisMul(P1, G, Y2, Q);         // P1 �õ� Y^2 * Fk^2 * (x - x^(q^2)

          Int64PolynomialGaloisMul(P2, F3, F4, Q);        // P2 �õ� Fk-1 * Fk+1
          Int64PolynomialGaloisSub(P1, P1, P2, Q);        // P1 �õ� Y^2 * Fk^2 * (x - x^(q^2) - Fk-1 * Fk+1

          Int64PolynomialGaloisMul(P1, P1, F1, Q);        // P1 ���� Fx
          Int64PolynomialGaloisMul(BetaEven, P1, Y2, Q);  // P1 �ٳ��� Y^2
          Int64PolynomialGaloisMulWord(BetaEven, 4, Q);   // �õ� BetaEven = 4y^2 * Fk * (Y^2 * Fk^2 * (x - x^(q^2) - Fk-1 * Fk+1)
        end
        else // K ������
        begin
          // �� AlphaOdd��BetaOddNoY
          Int64PolynomialGaloisMul(P1, F3, F3, Q);
          Int64PolynomialGaloisMul(P1, P1, F5, Q);        // P1 �õ� Fk+2 * Fk-1^2

          Int64PolynomialGaloisMul(P2, F4, F4, Q);
          Int64PolynomialGaloisMul(P2, P2, F2, Q);        // P2 �õ� Fk-2 * Fk+1^2
          Int64PolynomialGaloisSub(P1, P1, P2, Q);
          Int64PolynomialGaloisMul(P1, P1, Y2, Q);        // P1 �õ� Y^2 * (Fk+2 * Fk-1^2 - Fk-2 * Fk+1^2)

          Int64PolynomialGaloisPower(P2, F1, 3, Q);
          Int64PolynomialGaloisMulWord(P2, 4, Q);         // P2 �õ� 4 Fk^3

          Int64PolynomialGaloisPower(P3, Y2, (Q * Q - 1) shr 1, Q);  // P3 �õ� Y^(Q^2 - 1)
          Int64PolynomialGaloisMul(P3, P2, P3, Q);        // P2 * P3
          Int64PolynomialGaloisSub(AlphaOdd, P1, P3, Q);  // �õ� AlphaOdd = Y^2 * (Fk+2 * Fk-1^2 - Fk-2 * Fk+1^2) - 4 Fk^3 * Y^(Q^2 - 1)

          // ���� G �Ѿ��� x-x^(q^2)
          Int64PolynomialGaloisMul(P1, F1, F1, Q);
          Int64PolynomialGaloisMul(P1, P1, G, Q);         // P1 �õ� Fk^2 * (x - x^(q^2))

          Int64PolynomialGaloisMul(P2, F3, F4, Q);
          Int64PolynomialGaloisMul(P2, P2, Y2, Q);        // P2 �õ� Y^2 * Fk-1 * Fk+1

          Int64PolynomialGaloisSub(P1, P1, P2, Q);        // P1 - P2

          Int64PolynomialGaloisMul(BetaOddNoY, P1, F1, Q);
          Int64PolynomialGaloisMulWord(BetaOddNoY, 4, Q); // �õ� BetaOddNoY = 4 * Fk * (Fk^2 * (x - x^(q^2)) - Y^2 * Fk-1 * Fk+1)
        end;

        // ׼������б��ϵ������ʼ������Ҳ���ǰ������� J * �У��ŵ���ʽ��չ������ʽ���ж����޽����ж� J �Ƿ���ϵ�ʽ������������һ��
        for J := 1 to (L - 1) div 2 do
        begin
          if (J and 1) = 0 then
          begin
            // J ��ż��
          end
          else
          begin
            // J ������
          end;

        end;
      end
      else
      begin
        // �в����� 1 �Ĺ���ʽ˵������ L ��Ť�� P ���� ��^2(P) �� X ������� K * P �ģ�Ҳ���� ��^2(P) = ���� K * P
        // �����ȷ�������أ���ģƽ����

        W := CnInt64SquareRoot(Q, L);
        if W = 0 then                  // ��������� W������� T Ϊ 0
          Ta[I] := 0
        else
        begin
          // �ж� X �Ƿ���ȣ�Ҳ�����ÿɳ�����ʽ�� W �����һ������ʽ�� P3 �� GCD
          P1.Clear;
          P1.MaxDegree := Q;
          P1[Q] := 1;
          P1[1] := 1;           // P1 �� x^q -x

          F1 := TCnInt64Polynomial(DPs[W]);
          F2 := TCnInt64Polynomial(DPs[W - 1]);
          F3 := TCnInt64Polynomial(DPs[W + 1]);

          if (W and 1) = 0 then  // W ��ż��
          begin
            Int64PolynomialGaloisMul(P2, F1, F1, Q);   // P2 �õ� Fw^2
            Int64PolynomialGaloisMul(P2, P2, Y2, Q);   // P2 �õ� Fw^2 * (x^3+Ax+B)
            Int64PolynomialGaloisMul(P2, P2, P1, Q);   // P2 �õ� (x^q-x) * Fw^2 * (x^3+Ax+B)
            Int64PolynomialGaloisMul(P3, F2, F3, Q);   // P3 �õ� Fw-1 * Fw+1
            Int64PolynomialGaloisAdd(P3, P2, P3, Q);   // P3 �õ� (x^q-x) * Fw^2 * (x^3+Ax+B) - Fw-1 * Fw+1
          end
          else // W ������
          begin
            Int64PolynomialGaloisMul(P2, F1, F1, Q);   // P2 �õ� Fw^2
            Int64PolynomialGaloisMul(P2, P2, P1, Q);   // P2 �õ� (x^q-x) * Fw^2
            Int64PolynomialGaloisMul(P3, F2, F3, Q);   // P3 �õ� Fw-1 * Fw+1
            Int64PolynomialGaloisMul(P3, P3, Y2, Q);   // P3 �õ� Fw-1 * Fw+1 * (x^3+Ax+B)
            Int64PolynomialGaloisAdd(P3, P2, P3, Q);   // P3 �õ� (x^q-x) * Fw^2 - Fw-1 * Fw+1 * (x^3+Ax+B)
          end;

          Int64PolynomialGreatestCommonDivisor(P2, P3, LDP); // �����Լʽ
          if P2.IsOne then
            Ta[I] := 0
          else
          begin
            // ��� X ��ȣ���Ƚ� Y ���꣬ͬ��Ҳ���ÿɳ�����ʽ�� W �����һ������ʽ�� P1 �� GCD
            F1 := TCnInt64Polynomial(DPs[W]);
            F2 := TCnInt64Polynomial(DPs[W - 2]);
            F3 := TCnInt64Polynomial(DPs[W - 1]);
            F4 := TCnInt64Polynomial(DPs[W + 1]);
            F5 := TCnInt64Polynomial(DPs[W + 2]);

            if (W and 1) = 0 then  // W ��ż��
            begin
              Int64PolynomialGaloisPower(P1, F1, 3, Q);               // P1 �õ� FW^3
              Int64PolynomialGaloisPower(P2, Y2, ((Q + 3) shr 1), Q); // P2 �õ� Y2^(Q+3)/2
              Int64PolynomialGaloisMul(P1, P1, P2, Q);                // P1 �õ� Y2^(Q+3)/2 * FW^3
              Int64PolynomialGaloisMulWord(P1, 4, Q);                 // P1 �õ� 4 * Y2^(Q+3)/2 * FW^3

              Int64PolynomialGaloisMul(P2, F3, F3, Q);                // P2 �õ� Fw-1^2
              Int64PolynomialGaloisMul(P2, P2, F5, Q);                // P2 �õ� Fw-1^2 * Fw+2
              Int64PolynomialGaloisSub(P1, P1, P2, Q);                // P1 �õ� P1 - P2

              Int64PolynomialGaloisMul(P2, F4, F4, Q);                // P2 �õ� Fw+1^2
              Int64PolynomialGaloisMul(P2, P2, F2, Q);                // P2 �õ� Fw+1^2 * Fw-2

              Int64PolynomialGaloisAdd(P1, P1, P2, Q);                // P1 �õ� 4 * Y2^(Q+3)/2 * FW^3 - Fw-1^2 * Fw+2 + Fw+1^2 * Fw-2
            end
            else // W ������
            begin
              Int64PolynomialGaloisPower(P1, F1, 3, Q);               // P1 �õ� FW^3
              Int64PolynomialGaloisPower(P2, Y2, ((Q - 1) shr 1), Q); // P2 �õ� Y2^(Q-1)/2
              Int64PolynomialGaloisMul(P1, P1, P2, Q);                // P1 �õ� Y2^(Q-1)/2 * FW^3
              Int64PolynomialGaloisMulWord(P1, 4, Q);                 // P1 �õ� 4 * Y2^(Q-1)/2 * FW^3

              Int64PolynomialGaloisMul(P2, F3, F3, Q);                // P2 �õ� Fw-1^2
              Int64PolynomialGaloisMul(P2, P2, F5, Q);                // P2 �õ� Fw-1^2 * Fw+2
              Int64PolynomialGaloisSub(P1, P1, P2, Q);                // P1 �õ� P1 - P2

              Int64PolynomialGaloisMul(P2, F4, F4, Q);                // P2 �õ� Fw+1^2
              Int64PolynomialGaloisMul(P2, P2, F2, Q);                // P2 �õ� Fw+1^2 * Fw-2

              Int64PolynomialGaloisAdd(P1, P1, P2, Q);                // P1 �õ� 4 * Y2^(Q-1)/2 * FW^3 - Fw-1^2 * Fw+2 + Fw+1^2 * Fw-2
            end;

            Int64PolynomialGreatestCommonDivisor(P2, P1, LDP); // �����Լʽ
            if P2.IsOne then
              Ta[I] := L - 2 * W
            else
              Ta[I] := 2 * W;
          end;
        end;
      end;
    end;



{
      // ��Թ�ʽ ��^2(P) + K * (P) = t * ��(P) �ֱ���� ��^2 �� �е� x �� y����������о���Ҫ mod LDP
      P1.Clear;
      P1.MaxDegree := Q;
      P1[Q] := 1;
      Int64PolynomialGaloisMod(Pi1X, P1, LDP, Q);   // �õ� �е� x ������ʽ x^Q mod LDP

      P2.SetCoefficents([B, A, 0, 1]);
      Int64PolynomialGaloisPower(Pi1Y, P2, (Q - 1) shr 1, Q, LDP); // �õ� �е� y ������ʽ��(x^3+Ax+B)^(Q-1)/2 mod LDP ʵ���ϻ�Ҫ���� y

      P1.Clear;
      P1.MaxDegree := Q * Q;
      P1[Q * Q] := 1;
      Int64PolynomialGaloisMod(Pi2X, P1, LDP, Q);   // �õ� ��^2 �� x ������ʽ x^(Q^2) mod LDP

      Int64PolynomialGaloisPower(Pi2Y, P2, (Q * Q - 1) shr 1, Q, LDP); // �õ� ��^2 �� y ������ʽ��(x^3+Ax+B)^(Q^Q-1)/2 mod LDP ʵ���ϻ�Ҫ���� y
LDP.ToString;
      // ��ʼ ���� K * P �ı��ʽ
      if K = 0 then
      begin         // ��ʵ������������������
        KX.SetZero;
        KY.SetZero;
      end
      else if K = 1 then
      begin
        KX.SetCoefficents([0, 1]);
        KY.SetOne;
      end
      else // TODO: ���� K >= 2 �������֤
      begin
        KX.SetCoefficents([0, 1]);
        KY.SetOne;
        TCnInt64PolynomialEcc.MultiplePoint1(K, KX, KY, A, B, Q, LDP);

  === ������ Division Polynomial �������ǲ��ԣ����θĻ�������

       // K * P��x, y���� x ���ʽΪ x - F(k-1)*F(k+1)/F^2(k)������ F(k) �ǵ� k ��ֻ�� x �Ŀɳ�����ʽ
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K - 1, DK1, Q);
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K + 1, DK2, Q);
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K, D2K, Q);
        Int64PolynomialGaloisMul(D2K, D2K, D2K, Q, LDP); // D2K �õ� F^2k

        Int64PolynomialGaloisMul(P1, DK1, DK2, Q, LDP);  // P1 �õ� Fk-1*Fk+1
        Int64PolynomialGaloisModularInverse(P2, D2K, LDP, Q); // P2 �õ� F^2K ��ģ�����ʽ
        Int64PolynomialGaloisMul(P1, P1, P2, Q, LDP);         // P1 �õ� Fk-1*Fk+1/F^2k

        P2.SetCoefficents([0, 1]);  // P2 ��Ϊ x
        Int64PolynomialGaloisSub(KX, P2, P1, Q, LDP);         // KX �õ� x - Fk-1*Fk+1/F^2k

        // K * P��x, y���� y ���ʽΪ ((Fk+2 * F^2k-1 - Fk-2 * F^2(k+1)) / 4y^2 * F^2(k)) * y��
        // ���� y ������󣬷�ĸ��� y^2 �Ϳ����滻�� x3+Ax+B ��
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K + 2, DK1, Q);
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K - 1, DK2, Q);
        Int64PolynomialGaloisMul(DK2, DK2, DK2, Q, LDP); // DK2 �õ�F^2(k-1)
        Int64PolynomialGaloisMul(P1, DK1, DK2, Q, LDP);  // P1 �õ� Fk+2 * F^2k-1

        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K - 2, DK1, Q);
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K + 1, DK2, Q);
        Int64PolynomialGaloisMul(DK2, DK2, DK2, Q, LDP); // DK2 �õ�F^2(k+1)
        Int64PolynomialGaloisMul(P2, DK1, DK2, Q, LDP);  // P2 �õ� Fk-2 * F^2k+1

        Int64PolynomialGaloisSub(P1, P1, P2, Q, LDP);    // P1 �õ�����

        P2.SetCoefficents([B * 4, A * 4, 4]);
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, K, DK2, Q);
        Int64PolynomialGaloisMul(DK2, DK2, DK2, Q, LDP); // DK2 �õ�F^2(k)
        Int64PolynomialGaloisMul(P2, P2, DK2, Q, LDP);   // P2 �õ� 4y^2 * F^2(k)������ y^2 ֱ���滻�� x^3 + Ax + B

        Int64PolynomialGaloisModularInverse(DK2, P2, LDP, Q); // DK2 ����� P2 ��ģ�����ʽ
        Int64PolynomialGaloisMul(KY, P1, DK2, Q, LDP);        // KY �õ� P1 * P2^-1

      end;

      if Int64PolynomialEqual(KX, Pi2X) then
      begin
        // ��������� ��^2 P �� K * P ������� X ������ȣ���ô�� q ���� l ��ƽ��ʣ�࣬Ҳ������һ�� w^2 mod L = Q mod L
        W := CnInt64SquareRoot(Q, L);
        if W = 0 then
          Ta[I] := 0
        else
        begin
          // TODO: ���� W * �У�X ����Ӧ�õ��� ��^2���Ƚ� Y ���꣬��ͬ�� Ta[I] := 2W ���� -2W

          // ��� X ���겻���� ��^2���� Ta[I] := 0;
        end;
      end
      else
      begin
        // �󲿷�����£���^2 P �� K * P ������� X ������ʽ����ȣ������㰴��Բ���߹�����ӣ��õ�һ���͵㣨S1X, S1Y��
        // ע������ Y ���궼���ó���һ�� y������ֱ��������Բ������ĵ��
        TCnInt64PolynomialEcc.PointAddPoint1(Pi2X, Pi2Y, KX, KY, S1X, S1Y, A, B, Q, LDP);

        // �ٴ� 1 �ҵ� (L - 1)/2 ���ĸ�ֵ�˵ĵ�������ʽ����������������ͬ
        Int64PolynomialCopy(S2X, Pi1X);
        Int64PolynomialCopy(S2Y, Pi1Y);
        for J := 1 to (L - 1) div 2 do
        begin
          // �ǰ����ۼӼ��� J * �е� x ���꣬�����ж���������ʽ�Ĺ���ʽ������һ���� LDP���� ��ʱ��ѡǰ��
          if Int64PolynomialEqual(S1X, S2X) then
          begin
            // X ����������ˣ��ж� Y �����Ƿ����
            if Int64PolynomialEqual(S1Y, S2Y) then
              Ta[I] := J
            else
              Ta[I] := Q - J;
            Break;
          end;
          TCnInt64PolynomialEcc.PointAddPoint1(S2X, S2Y, Pi1X, Pi1Y, S2X, S2Y, A, B, Q, LDP); // �ӵ���һ�� J
        end;
      end;
    end;
}
    // ����������������й�ʣ�ඨ�������ս�
    Result := Q + 1 - ChineseRemainderTheoremInt64(Ta, Pa);
  finally
    FEccInt64PolynomialPool.Recycle(Y2);
    FEccInt64PolynomialPool.Recycle(P1);
    FEccInt64PolynomialPool.Recycle(P2);
    FEccInt64PolynomialPool.Recycle(P3);
    FEccInt64PolynomialPool.Recycle(P4);
    FEccInt64PolynomialPool.Recycle(AlphaEvenNoY);
    FEccInt64PolynomialPool.Recycle(BetaEven);
    FEccInt64PolynomialPool.Recycle(AlphaOdd);
    FEccInt64PolynomialPool.Recycle(BetaOddNoY);

    FEccInt64PolynomialPool.Recycle(G);
    FEccInt64PolynomialPool.Recycle(F);

    DPs.Free;
    Pa.Free;
    Ta.Free;
  end;
end;

initialization
  FEccBigNumberPool := TCnBigNumberPool.Create;
  FEccInt64PolynomialPool := TCnInt64PolynomialPool.Create;

finalization
  FEccInt64PolynomialPool.Free;
  FEccBigNumberPool.Free;

end.
