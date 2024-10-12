{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnRSA;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�RSA �㷨��Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע������Ԫʵ���� Int64 ����������Χ�ڵ� RSA �㷨����Կ Exponent Ĭ�Ϲ̶�ʹ�� 65537��
*           �����ڴ����� RSA �㷨ʵ���˹�˽Կ���ɡ��洢�����������ݼӽ��ܡ�ǩ����ǩ�� 
*           ����ٷ��ᳫ��Կ���ܡ�˽Կ���ܣ��� RSA ���ߵ�ͬ��Ҳ��˽Կ���ܡ���Կ���ܣ�
*           ����Ԫ���෽�����ṩ�ˣ�ʹ��ʱ��ע����ԡ�
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2024.09.27 V2.8
*               ����˽Կ����λ�����ܴ��������
*           2023.12.14 V2.7
*               ������֤��˽Կ�Ļ��ƣ������ƴ��ļ������м����뱣��
*           2023.02.16 V2.6
*               ʵ�ִ�����ʽ�Ļ�����ɢ�����ı�ɫ���Ӵ��㷨
*           2023.02.15 V2.5
*               ���� RSA ����֧�� CRT���й�ʣ�ඨ�����٣�˽Կ�����ʱ��������֮һ
*           2022.04.26 V2.4
*               �޸� Integer ��ַת����֧�� MacOS64
*           2021.06.12 V2.1
*               ���� OAEP Padding �Ĵ���
*           2021.05.09 V2.0
*               ˽Կ����ʱ�Զ��ж� PEM ���� PKCS1 ���� PKCS8 ��ʽ����������ͷβ�еĺ��ע��
*           2020.06.10 V1.9
*               ��˽Կ����� Stream ������
*           2020.03.27 V1.8
*               ��Կ������ 3��ʵ���˼��ܵ� PEM �ļ��Ķ�д������ֻ֧�� DES/3DES/AES
*           2020.03.13 V1.7
*               ������ϸ�Ĵ����롣���÷��� False ʱ��ͨ�� GetLastCnRSAError ��ȡ ECN_RSA_* ��ʽ�Ĵ�����
*           2019.04.19 V1.6
*               ֧�� Win32/Win64/MacOS32
*           2018.06.15 V1.5
*               ֧���ļ�ǩ������֤�������� Openssl �е��÷�����ԭʼǩ�����Ӵ�ǩ�����ࣺ
*               openssl rsautl -sign -in hello -inkey rsa.pem -out hello.default.sign.openssl
*               // ˽Կԭʼǩ����ֱ�Ӱ��ļ����ݲ������˽Կ���ܲ��洢����ͬ�ڼ��ܣ���Ӧ CnRSASignFile ָ�� sdtNone
*               openssl dgst -md5 -sign rsa.pem -out hello.md5.sign.openssl hello
*               openssl dgst -sha1 -sign rsa.pem -out hello.sha1.sign.openssl hello
*               openssl dgst -sha256 -sign rsa.pem -out hello.sha256.sign.openssl hello
*               // ˽Կ�Ӵ�ǩ������ָ���Ӵ��㷨��Ĭ�� md5����Ӧ CnRSASignFile ��ָ���Ӵ��㷨��
*               // ԭʼ�ļ��Ӵ�ֵ���� BER ������ PKCS1 �����˽Կ���ܲ��洢��ǩ���ļ�
*               openssl dgst -verify rsa_pub.pem -signature hello.sign.openssl hello
*               // ��Կ�Ӵ���֤ԭʼ�ļ���ǩ���ļ����Ӵ��㷨������ǩ���ļ��С�
*               // ��Ӧ CnRSAVerify����Կ�⿪ǩ���ļ���ȥ�� PKCS1 �����ٽ⿪ BER ���벢�ȶ��Ӵ�ֵ
*           2018.06.14 V1.5
*               ֧���ļ��ӽ��ܣ������� Openssl �е��÷����磺
*               openssl rsautl -encrypt -in hello -inkey rsa_pub.pem -pubin -out hello.en.pub.openssl
*               openssl rsautl -encrypt -in hello -inkey rsa.pem -out hello.en.pub.openssl
*               // �ù�Կ���ܣ���ͬ�ڷ��� CnRSAEncryptFile ������ PublicKey
*               openssl rsautl -decrypt -in hello.en.pub.openssl -inkey rsa.pem -out hello.de.priv.openssl
*               // ��˽Կ���ܣ���ͬ�ڷ��� CnRSADecryptFile ������ PrivateKey
*               ע�� Openssl �ᳫ��Կ����˽Կ���ܣ�������Ҳʵ����˽Կ���ܹ�Կ����
*           2018.06.05 V1.4
*               �� Int64 ֧����չ�� UInt64
*           2018.06.02 V1.4
*               �ܹ�����˽Կ����ɼ��� Openssl ��δ���ܵĹ�˽Կ PEM ��ʽ�ļ�
*           2018.05.27 V1.3
*               �ܹ��� Openssl 1.0.2 ���ɵ�δ���ܵĹ�˽Կ PEM ��ʽ�ļ��ж��빫˽Կ����
*               openssl genrsa -out private_pkcs1.pem 2048
*                  // PKCS#1 ��ʽ�Ĺ�˽Կ
*               openssl pkcs8 -topk8 -inform PEM -in private_pkcs1.pem -outform PEM -nocrypt -out private_pkcs8.pem
*                  // PKCS#8 ��ʽ�Ĺ�˽Կ
*               openssl rsa -in private_pkcs1.pem -outform PEM -RSAPublicKey_out -out public_pkcs1.pem
*                  // PKCS#1 ��ʽ�Ĺ�Կ
*               openssl rsa -in private_pkcs1.pem -outform PEM -pubout -out public_pkcs8.pem
*                  // PKCS#8 ��ʽ�Ĺ�Կ
*           2018.05.22 V1.2
*               ����˽Կ��ϳɶ����Է���ʹ��
*           2017.04.05 V1.1
*               ʵ�ִ����� RSA ��Կ������ӽ���
*           2017.04.03 V1.0
*               ������Ԫ��Int64 ��Χ�ڵ� RSA �� CnPrimeNumber �ж�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

{$DEFINE CN_RSA_USE_CRT}
// �����������ʹ�� CRT ���м�����١�1024 λ��˽Կ�����ܹ�����ʱ����������֮һ

uses
  SysUtils, Classes {$IFDEF MSWINDOWS}, Windows {$ENDIF}, CnConsts, CnPrimeNumber,
  CnBigNumber, CnBerUtils, CnPemUtils, CnNative, CnMD5, CnSHA1, CnSHA2, CnSM3;

const
  // ���� OID ��Ԥ��д��������̬���������
  CN_OID_RSAENCRYPTION_PKCS1: array[0..8] of Byte = ( // $2A = 40 * 1 + 2
    $2A, $86, $48, $86, $F7, $0D, $01, $01, $01
  );
  {* RSA PKCS1 �� OID ���룬ʵ��ֵΪ 1.2.840.113549.1.1.1}

  // ������
  ECN_RSA_OK                           = ECN_OK;
  {* RSA ϵ�д����룺�޴���ֵΪ 0}

  ECN_RSA_ERROR_BASE                   = ECN_CUSTOM_ERROR_BASE + $100;
  {* RSA ϵ�д�����Ļ�׼��ʼֵ��Ϊ ECN_CUSTOM_ERROR_BASE ���� $100}

  ECN_RSA_INVALID_INPUT                = ECN_RSA_ERROR_BASE + 1;
  {* RSA ������֮����Ϊ�ջ򳤶ȴ���}
  ECN_RSA_INVALID_BITS                 = ECN_RSA_ERROR_BASE + 2;
  {* RSA ������֮��Կλ������}
  ECN_RSA_BIGNUMBER_ERROR              = ECN_RSA_ERROR_BASE + 3;
  {* RSA ������֮�����������}
  ECN_RSA_BER_ERROR                    = ECN_RSA_ERROR_BASE + 4;
  {* RSA ������֮ BER ��ʽ�������}
  ECN_RSA_PADDING_ERROR                = ECN_RSA_ERROR_BASE + 5;
  {* RSA ������֮ PADDING �������}
  ECN_RSA_DIGEST_ERROR                 = ECN_RSA_ERROR_BASE + 6;
  {* RSA ������֮����ժҪ����}
  ECN_RSA_PEM_FORMAT_ERROR             = ECN_RSA_ERROR_BASE + 7;
  {* RSA ������֮ PEM ��ʽ����}
  ECN_RSA_PEM_CRYPT_ERROR              = ECN_RSA_ERROR_BASE + 8;
  {* RSA ������֮ PEM �ӽ��ܴ���}

type
  TCnRSASignDigestType = (rsdtNone, rsdtMD5, rsdtSHA1, rsdtSHA256, rsdtSM3);
  {* RSA ǩ����֧�ֵ�����ժҪ�㷨������ժҪ}

  TCnRSAKeyType = (cktPKCS1, cktPKCS8);
  {* RSA ��Կ�ļ���ʽ��ע������ CnECC �е� TCnEccKeyType �����ظ���ʹ��ʱҪע��}

  TCnRSAPaddingMode = (cpmPKCS1, cpmOAEP);
  {* RSA ���ܵ����ģʽ��PKCS1 �ʺϼӽ��ܣ���������������ͣ�
    OAEP ֻ�����ڹ�Կ���ܣ�Ĭ��ʹ�� SHA1 ��Ϊ���������Ӵ��㷨}

  TCnRSAPrivateKey = class(TPersistent)
  {* RSA ˽Կ}
  private
    FPrimeKey1: TCnBigNumber;
    FPrimeKey2: TCnBigNumber;
    FPrivKeyProduct: TCnBigNumber;
    FPrivKeyExponent: TCnBigNumber;
{$IFDEF CN_RSA_USE_CRT}
    FDP1: TCnBigNumber;  // CRT ���ٵ������м����
    FDQ1: TCnBigNumber;
    FQInv: TCnBigNumber;
{$ENDIF}
    function GetBitsCount: Integer;
    function GetBytesCount: Integer;
  protected
{$IFDEF CN_RSA_USE_CRT}
    procedure UpdateCRT;
{$ENDIF}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    {* ����һ˽Կ����ֵ}
    procedure Clear;
    {* ���ֵ}

    property PrimeKey1: TCnBigNumber read FPrimeKey1 write FPrimeKey1;
    {* ������ 1��p��Ҫ��� q ��}
    property PrimeKey2: TCnBigNumber read FPrimeKey2 write FPrimeKey2;
    {* ������ 2��q��Ҫ��� p С}
    property PrivKeyProduct: TCnBigNumber read FPrivKeyProduct write FPrivKeyProduct;
    {* �������˻� n��Ҳ�� Modulus������ʱ��λ�����ϸ�������谲ȫλ��}
    property PrivKeyExponent: TCnBigNumber read FPrivKeyExponent write FPrivKeyProduct;
    {* ˽Կָ�� d}
    property BitsCount: Integer read GetBitsCount;
    {* ��Կ��λ����Ҳ�������˻� n ����Чλ��}
    property BytesCount: Integer read GetBytesCount;
    {* ��Կ���ֽ��������������˻� n ����Чλ������ 8}
  end;

  TCnRSAPublicKey = class(TPersistent)
  {* RSA ��Կ}
  private
    FPubKeyProduct: TCnBigNumber;
    FPubKeyExponent: TCnBigNumber;
    function GetBitsCount: Integer;
    function GetBytesCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    {* ����һ��Կ����ֵ}
    procedure Clear;
    {* ���ֵ}

    property PubKeyProduct: TCnBigNumber read FPubKeyProduct write FPubKeyProduct;
    {* �������˻� n��Ҳ�� Modulus}
    property PubKeyExponent: TCnBigNumber read FPubKeyExponent write FPubKeyExponent;
    {* ��Կָ�� e��65537}
    property BitsCount: Integer read GetBitsCount;
    {* ��Կ��λ����Ҳ�������˻� n ����Чλ��}
    property BytesCount: Integer read GetBytesCount;
    {* ��Կ���ֽ��������������˻� n ����Чλ������ 8}
  end;

// UInt64 ��Χ�ڵ� RSA �ӽ���ʵ��

function CnInt64RSAGenerateKeys(out PrimeKey1: Cardinal; out PrimeKey2: Cardinal;
  out PrivKeyProduct: TUInt64; out PrivKeyExponent: TUInt64;
  out PubKeyProduct: TUInt64; out PubKeyExponent: TUInt64; HighBitSet: Boolean = True): Boolean;
{* ���� RSA �㷨�����һ�Թ�˽Կ�������������� Cardinal��Keys �������� UInt64
   HighBitSet Ϊ True ʱҪ���������λΪ 1���ҳ˻��� 64 Bit}

function CnInt64RSAEncrypt(Data: TUInt64; PrivKeyProduct: TUInt64;
  PrivKeyExponent: TUInt64; out Res: TUInt64): Boolean;
{* ���� RSA ˽Կ������ Data ���м��ܣ����ܽ��д�� Res�����ؼ����Ƿ�ɹ�}

function CnInt64RSADecrypt(Res: TUInt64; PubKeyProduct: TUInt64;
  PubKeyExponent: TUInt64; out Data: TUInt64): Boolean;
{* ���� RSA ��Կ������ Res ���н��ܣ����ܽ��д�� Data�����ؽ����Ƿ�ɹ�}

// ������Χ�ڵ� RSA �ӽ���ʵ��

function CnRSAGenerateKeysByPrimeBits(PrimeBits: Integer; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; PublicKeyUse3: Boolean = False): Boolean; {$IFDEF SUPPORT_DEPRECATED} deprecated; {$ENDIF}
{* ���� RSA �㷨�����һ�Թ�˽Կ��PrimeBits �������Ķ�����λ�������������Ϊ���ɡ�
   PrimeBits ȡֵΪ 512/1024/2048�ȣ�ע��Ŀǰ���ǳ˻��ķ�Χ���ڲ�ȱ����ȫ�жϡ����Ƽ�ʹ�á�
   PublicKeyUse3 Ϊ True ʱ��Կָ���� 3�������� 65537}

function CnRSAGenerateKeys(ModulusBits: Integer; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; PublicKeyUse3: Boolean = False): Boolean;
{* ���� RSA �㷨�����һ�Թ�˽Կ��ModulusBits �������˻��Ķ�����λ�������������Ϊ���ɡ�
   ModulusBits ȡֵΪ 512/1024/2048�ȡ��ڲ��а�ȫ�жϡ�
   PublicKeyUse3 Ϊ True ʱ��Կָ���� 3�������� 65537}

function CnRSAVerifyKeys(PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey): Boolean;
{* ��֤һ�� RSA ��˽Կ�Ƿ�����}

function CnRSALoadKeysFromPem(const PemFileName: string; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyHashMethod: TCnKeyHashMethod = ckhMd5;
  const Password: string = ''): Boolean; overload;
{* �� PEM ��ʽ���ļ��м���һ�� RSA ��˽Կ���ݣ���ĳԿ����Ϊ��������
  �Զ��ж� PKCS1 ���� PKCS8����������ͷβ�е� ----- ע��
  KeyHashMethod: ��Ӧ PEM �ļ��ļ����Ӵ��㷨��Ĭ�� MD5���޷����� PEM �ļ������Զ��жϣ�
  Password: PEM �ļ�����ܣ��˴�Ӧ����Ӧ����}

function CnRSALoadKeysFromPem(PemStream: TStream; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyHashMethod: TCnKeyHashMethod = ckhMd5;
  const Password: string = ''): Boolean; overload;
{* �� PEM ��ʽ�����м���һ�� RSA ��˽Կ���ݣ���ĳԿ����Ϊ��������
  �Զ��ж� PKCS1 ���� PKCS8����������ͷβ�е� ----- ע��
  KeyHashMethod: ��Ӧ PEM �ļ��ļ����Ӵ��㷨��Ĭ�� MD5���޷����� PEM �ļ������Զ��жϣ�
  Password: PEM �ļ�����ܣ��˴�Ӧ����Ӧ���룬δ���ܿɲ���}

function CnRSASaveKeysToPem(const PemFileName: string; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType = cktPKCS1;
  KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5;
  const Password: string = ''): Boolean; overload;
{* ��һ�� RSA ��˽Կд�� PEM ��ʽ���ļ��У������Ƿ�ɹ�
  KeyEncryptMethod: �� PEM �ļ�����ܣ����ô˲���ָ�����ܷ�ʽ��ckeNone ��ʾ�����ܣ����Ժ�������
  KeyHashMethod: ���� Key ���Ӵ��㷨��Ĭ�� MD5
  Password: PEM �ļ��ļ������룬δ���ܿɲ���}

function CnRSASaveKeysToPem(PemStream: TStream; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType = cktPKCS1;
  KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5;
  const Password: string = ''): Boolean; overload;
{* ��һ�� RSA ��˽Կд�� PEM ��ʽ�����У������Ƿ�ɹ�
  KeyEncryptMethod: �� PEM �ļ�����ܣ����ô˲���ָ�����ܷ�ʽ��ckeNone ��ʾ�����ܣ����Ժ�������
  KeyHashMethod: ���� Key ���Ӵ��㷨��Ĭ�� MD5
  Password: PEM �ļ��ļ������룬δ���ܿɲ���}

function CnRSALoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey; KeyHashMethod: TCnKeyHashMethod = ckhMd5;
  const Password: string = ''): Boolean; overload;
{* �� PEM ��ʽ���ļ��м��� RSA ��Կ���ݣ������Ƿ�ɹ�}

function CnRSALoadPublicKeyFromPem(const PemStream: TStream;
  PublicKey: TCnRSAPublicKey; KeyHashMethod: TCnKeyHashMethod = ckhMd5;
  const Password: string = ''): Boolean; overload;
{* �� PEM ��ʽ�����м��� RSA ��Կ���ݣ������Ƿ�ɹ�}

function CnRSASavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType = cktPKCS8;
  KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  const Password: string = ''): Boolean; overload;
{* �� RSA ��Կд�� PEM ��ʽ���ļ��У������Ƿ�ɹ�}

function CnRSASavePublicKeyToPem(PemStream: TStream;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType = cktPKCS8;
  KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  const Password: string = ''): Boolean; overload;
{* �� RSA ��Կд�� PEM ��ʽ�����У������Ƿ�ɹ�}

function CnRSAEncrypt(Data: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Res: TCnBigNumber): Boolean; overload;
{* ʹ�� RSA ˽Կ������ Data ���м��ܣ����ܽ��д�� Res�����ؼ����Ƿ�ɹ�}

function CnRSAEncrypt(Data: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Res: TCnBigNumber): Boolean; overload;
{* ���� RSA ��Կ������ Data ���м��ܣ����ܽ��д�� Res�����ؼ����Ƿ�ɹ�}

function CnRSADecrypt(Res: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Data: TCnBigNumber): Boolean; overload;
{* ���� RSA ˽Կ������ Res ���н��ܣ����ܽ��д�� Data�����ؽ����Ƿ�ɹ�}

function CnRSADecrypt(Res: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Data: TCnBigNumber): Boolean; overload;
{* ���� RSA ��Կ������ Res ���н��ܣ����ܽ��д�� Data�����ؽ����Ƿ�ɹ�}

// ======================== RSA �������ļ��ӽ���ʵ�� ===========================

function CnRSAEncryptRawData(PlainData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PublicKey: TCnRSAPublicKey): Boolean; overload;
{* �ù�Կ�����ݿ���м��ܣ�����䣬����� OutBuf �У�
  OutBuf ���Ȳ��ܶ�����Կ���ȣ�1024 Bit �� �� 128 �ֽ�}

function CnRSAEncryptRawData(PlainData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PrivateKey: TCnRSAPrivateKey): Boolean; overload;
{* ��˽Կ�����ݿ���м��ܣ�����䣬����� OutBuf �У�
  OutBuf ���Ȳ��ܶ�����Կ���ȣ�1024 Bit �� �� 128 �ֽ�}

function CnRSADecryptRawData(EnData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PublicKey: TCnRSAPublicKey): Boolean; overload;
{* �ù�Կ�����ݿ�����������ܣ������ OutBuf �У����������ݳ���
  OutBuf ���Ȳ��ܶ�����Կ���ȣ�1024 Bit �� �� 128 �ֽ�}

function CnRSADecryptRawData(EnData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PrivateKey: TCnRSAPrivateKey): Boolean; overload;
{* ��˽Կ�����ݿ�����������ܽ���� OutBuf �У����������ݳ���
  OutBuf ���Ȳ��ܶ�����Կ���ȣ�1024 Bit �� �� 128 �ֽ�}

function CnRSAEncryptData(PlainData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  PublicKey: TCnRSAPublicKey; PaddingMode: TCnRSAPaddingMode = cpmPKCS1): Boolean; overload;
{* �ù�Կ�����ݿ���м��ܣ�����ǰ��ָ��ʹ�� PKCS1 ���� OAEP ��䣬����� OutBuf �У�
  OutBuf ���Ȳ��ܶ�����Կ���ȣ�1024 Bit �� �� 128 �ֽ�}

function CnRSAEncryptData(PlainData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  PrivateKey: TCnRSAPrivateKey): Boolean; overload;
{* ��˽Կ�����ݿ���м��ܣ�����ǰʹ�� PKCS1 ��䣬����� OutBuf �У�
  OutBuf ���Ȳ��ܶ�����Կ���ȣ�1024 Bit �� �� 128 �ֽ�}

function CnRSADecryptData(EnData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PublicKey: TCnRSAPublicKey): Boolean; overload;
{* �ù�Կ�����ݿ���н��ܣ����⿪ PKCS1 ��䣬����� OutBuf �У����������ݳ���
  OutBuf ���Ȳ��ܶ�����Կ���ȣ�1024 Bit �� �� 128 �ֽ�}

function CnRSADecryptData(EnData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PrivateKey: TCnRSAPrivateKey;
  PaddingMode: TCnRSAPaddingMode = cpmPKCS1): Boolean; overload;
{* ��˽Կ�����ݿ���н��ܣ����⿪�� PKCS1 ���� OAEP ��䣬����� OutBuf �У����������ݳ���
  OutBuf ���Ȳ��ܶ�����Կ���ȣ�1024 Bit �� �� 128 �ֽ�}

function CnRSAEncryptFile(const InFileName: string; const OutFileName: string;
  PublicKey: TCnRSAPublicKey; PaddingMode: TCnRSAPaddingMode = cpmPKCS1): Boolean; overload;
{* �ù�Կ���ļ����м��ܣ�����ǰ��ָ��ʹ�� PKCS1 ���� OAEP ��䣬���������ļ���}

function CnRSAEncryptFile(const InFileName: string; const OutFileName: string;
  PrivateKey: TCnRSAPrivateKey): Boolean; overload;
{* ��˽Կ���ļ����м��ܣ�����ǰʹ�� PKCS1 ��䣬���������ļ���}

function CnRSADecryptFile(const InFileName: string; const OutFileName: string;
  PublicKey: TCnRSAPublicKey): Boolean; overload;
{* �ù�Կ���ļ����н��ܣ����⿪�� PKCS1 ��䣬���������ļ��У�ע�ⲻ֧�� OAEP ���}

function CnRSADecryptFile(const InFileName: string; const OutFileName: string;
  PrivateKey: TCnRSAPrivateKey; PaddingMode: TCnRSAPaddingMode = cpmPKCS1): Boolean; overload;
{* ��˽Կ���ļ����н��ܣ����⿪�� PKCS1 ���� OAEP ��䣬���������ļ���}

// =========================== RSA �ļ�ǩ������֤ʵ�� ==========================
//
// �����ļ��ֿ�ʵ������Ϊ�����ļ�ժҪʱ֧�ִ��ļ����� FileStream �Ͱ汾��֧��
//
// ע�� RSA ǩ�������Ӵ���ƴһ�������� RSA ˽Կ���ܣ���֤ʱ�ܽ���Ӵ�ֵ
// ���� ECC ǩ����ͬ��ECC ǩ��������� Hash ֵ������ͨ���м�����ȶԴ���

function CnRSASignFile(const InFileName: string; const OutSignFileName: string;
  PrivateKey: TCnRSAPrivateKey; SignType: TCnRSASignDigestType = rsdtMD5): Boolean;
{* �� RSA ˽Կǩ��ָ���ļ���ǩ�����ֱ�Ӵ洢�� OutSignFileName �ļ��У�����ǩ���Ƿ�ɹ���
   δָ������ժҪ�㷨ʱ���ڽ�Դ�ļ��� PKCS1 Private_FF ��������
   ��ָ��������ժҪ�㷨ʱ��ʹ��ָ������ժҪ�㷨���ļ����м���õ��Ӵ�ֵ��
   ԭʼ�Ķ������Ӵ�ֵ���� BER ������ PKCS1 ��������˽Կ����}

function CnRSAVerifyFile(const InFileName: string; const InSignFileName: string;
  PublicKey: TCnRSAPublicKey; SignType: TCnRSASignDigestType = rsdtMD5): Boolean;
{* �� RSA ��Կ��ǩ��ֵ�ļ���ָ֤���ļ���Ҳ����ָ������ժҪ�㷨���ļ����м���õ��Ӵ�ֵ��
   ���ù�Կ����ǩ�����ݲ��⿪ PKCS1 �����ٽ⿪ BER ����õ��Ӵ��㷨���Ӵ�ֵ��
   ���ȶ������������Ӵ�ֵ�Ƿ���ͬ��������֤�Ƿ�ͨ��}

function CnRSASignStream(InStream: TMemoryStream; OutSignStream: TMemoryStream;
  PrivateKey: TCnRSAPrivateKey; SignType: TCnRSASignDigestType = rsdtMD5): Boolean;
{* �� RSA ˽Կǩ��ָ���ڴ�����ǩ��ֵд�� OutSignStream �У�����ǩ���Ƿ�ɹ�}

function CnRSAVerifyStream(InStream: TMemoryStream; InSignStream: TMemoryStream;
  PublicKey: TCnRSAPublicKey; SignType: TCnRSASignDigestType = rsdtMD5): Boolean;
{* �� RSA ��Կ��ǩ��ֵ�ڴ�����ָ֤���ڴ�����������֤�Ƿ�ͨ��}

function CnRSASignBytes(InData: TBytes; PrivateKey: TCnRSAPrivateKey;
  SignType: TCnRSASignDigestType = rsdtMD5): TBytes;
{* �� RSA ˽Կǩ���ֽ����飬����ǩ��ֵ���ֽ����飬��ǩ��ʧ���򷵻ؿ�}

function CnRSAVerifyBytes(InData: TBytes; InSignBytes: TBytes;
  PublicKey: TCnRSAPublicKey; SignType: TCnRSASignDigestType = rsdtMD5): Boolean;
{* �� RSA ��Կ��ǩ���ֽ�������ָ֤���ֽ����飬������֤�Ƿ�ͨ��}

// OAEP Padding ����������֤�㷨

function AddOaepSha1MgfPadding(ToBuf: PByte; ToLen: Integer; PlainData: PByte;
  DataByteLen: Integer; DigestParam: PByte = nil; ParamLen: Integer = 0): Boolean;
{* �� Data �� DataLen �����ݽ��� OAEP ��䣬���ݷŵ� ToBuf �� ToLen ���������Ƿ�ɹ���
  Ĭ��ʹ�� SHA1 �� DigestBuf ���ݽ����Ӵգ�ToLen һ���� RSA ����Կ�Ļ����ֽ���}

function RemoveOaepSha1MgfPadding(ToBuf: PByte; out OutLen: Integer; EnData: PByte;
  DataByteLen: Integer; DigestParam: PByte = nil; ParamLen: Integer = 0): Boolean;
{* �� EnData �� DataLen �����ݽ��� OAEP ���鲢ȥ����䣬���ݷŵ� ToBuf �� OutLen ����ؼ���Ƿ�ɹ���
  ToBuf �����ɵ�ʵ�ʳ��Ȳ���̫�̣���ɹ���OutLen �����������ݳ���
  Ĭ��ʹ�� SHA1 �� DigestBuf ���ݽ����Ӵգ�DataLen Ҫ���� RSA ����Կ�Ļ����ֽ���}

// ================ Diffie-Hellman ��ɢ������Կ�����㷨 ========================

function CnDiffieHellmanGeneratePrimeRootByBitsCount(BitsCount: Integer;
  Prime: TCnBigNumber; MinRoot: TCnBigNumber): Boolean;
{* ���� Diffie-Hellman ��ԿЭ���㷨���������������Сԭ����ʵ�ʵ�ͬ�ڱ�ɫ���Ӵպ���
  �漰�����طֽ���˽�����ԭ��Ҳ���Ǹ����������Ԫ��Ҳ���Ǹ����������ܱ���������������ֵ��}

function CnDiffieHellmanGenerateOutKey(Prime: TCnBigNumber; Root: TCnBigNumber;
  SelfPrivateKey: TCnBigNumber; const OutPublicKey: TCnBigNumber): Boolean;
{* ��������ѡ�������� PrivateKey ���� Diffie-Hellman ��ԿЭ�̵������Կ
   ���� OutPublicKey = (Root ^ SelfPrivateKey) mod Prime
   Ҫ��֤��ȫ������ʹ�� CnSecretSharing ��Ԫ�ж���� CN_PRIME_FFDHE_* ��������Ӧԭ����Ϊ 2}

function CnDiffieHellmanComputeKey(Prime: TCnBigNumber; SelfPrivateKey: TCnBigNumber;
  OtherPublicKey: TCnBigNumber; const SecretKey: TCnBigNumber): Boolean;
{* ���ݶԷ����͵� Diffie-Hellman ��ԿЭ�̵������Կ�������ɹ��ϵ���Կ
   ���� SecretKey = (OtherPublicKey ^ SelfPrivateKey) mod Prime
   Ҫ��֤��ȫ������ʹ�� CnSecretSharing ��Ԫ�ж���� CN_PRIME_FFDHE_* ��������Ӧԭ����Ϊ 2}

// ====================== ������ɢ�����ı�ɫ���Ӵպ��� =========================

function CnChameleonHashGeneratePrimeRootByBitsCount(BitsCount: Integer;
  Prime: TCnBigNumber; MinRoot: TCnBigNumber): Boolean;
{* ���ɻ�����ɢ�����ı�ɫ���Ӵպ������������������Сԭ����ʵ�ʵ�ͬ�� Diffie-Hellman��
  �漰�����طֽ���˽�����ԭ��Ҳ���Ǹ����������Ԫ��Ҳ���Ǹ����������ܱ���������������ֵ��}

function CnChameleonHashCalcDigest(InData: TCnBigNumber; InRandom: TCnBigNumber;
  InSecretKey: TCnBigNumber; OutHash: TCnBigNumber; Prime: TCnBigNumber; Root: TCnBigNumber): Boolean;
{* ������ͨ��ɢ�����ı�ɫ���Ӵպ���������һ���ֵ��һ SecretKey������ָ����Ϣ���Ӵ�
  ���У�Prime �� Root �������� CnDiffieHellmanGeneratePrimeRootByBitsCount ����}

function CnChameleonHashFindRandom(InOldData: TCnBigNumber; InNewData: TCnBigNumber;
  InOldRandom: TCnBigNumber; InSecretKey: TCnBigNumber; OutNewRandom: TCnBigNumber;
  Prime: TCnBigNumber; Root: TCnBigNumber): Boolean;
{* ������ͨ��ɢ�����ı�ɫ���Ӵպ��������� SecretKey ���¾���Ϣ�������ܹ�������ͬ�Ӵյ������ֵ
  ���У�Prime �� Root ����ԭʼ��Ϣ�Ӵ�����ʱ��ͬ��
  �������� SecretKey �� NewRandom �� InNewData ���� CnChameleonHashCalcDigest ������ͬ���Ӵ�ֵ}

// ================================= ������������ ==============================

function GetDigestSignTypeFromBerOID(OID: Pointer; OidLen: Integer): TCnRSASignDigestType;
{* �� BER �������� OID ��ȡ���Ӧ���Ӵ�ժҪ����}

function AddDigestTypeOIDNodeToWriter(AWriter: TCnBerWriter; ASignType: TCnRSASignDigestType;
  AParent: TCnBerWriteNode): TCnBerWriteNode;
{* ��һ���Ӵ��㷨�� OID д��һ�� Ber �ڵ�}

function GetRSADigestNameFromSignDigestType(Digest: TCnRSASignDigestType): string;
{* ��ǩ���Ӵ��㷨ö��ֵ��ȡ������}

function GetLastCnRSAError: Integer;
{* ��ȡ���߳������һ�� ErrorCode�������Ϻ������� False ʱ�ɵ��ô˺�����ȡ��������}

implementation

uses
  CnRandom;

const
  // PKCS#1
  PEM_RSA_PRIVATE_HEAD = '-----BEGIN RSA PRIVATE KEY-----';
  PEM_RSA_PRIVATE_TAIL = '-----END RSA PRIVATE KEY-----';

  PEM_RSA_PUBLIC_HEAD = '-----BEGIN RSA PUBLIC KEY-----';
  PEM_RSA_PUBLIC_TAIL = '-----END RSA PUBLIC KEY-----';

  // PKCS#8
  PEM_PRIVATE_HEAD = '-----BEGIN PRIVATE KEY-----';
  PEM_PRIVATE_TAIL = '-----END PRIVATE KEY-----';

  PEM_PUBLIC_HEAD = '-----BEGIN PUBLIC KEY-----';
  PEM_PUBLIC_TAIL = '-----END PUBLIC KEY-----';

  OID_SIGN_MD5: array[0..7] of Byte = (            // 1.2.840.113549.2.5
    $2A, $86, $48, $86, $F7, $0D, $02, $05
  );

  OID_SIGN_SHA1: array[0..4] of Byte = (           // 1.3.14.3.2.26
    $2B, $0E, $03, $02, $1A
  );

  OID_SIGN_SHA256: array[0..8] of Byte = (         // 2.16.840.1.101.3.4.2.1
    $60, $86, $48, $01, $65, $03, $04, $02, $01
  );

// ��ȡ���߳������һ�� ErrorCode�������Ϻ������� False ʱ�ɵ��ô˺�����ȡ��������}
function GetLastCnRSAError: Integer;
begin
  Result := CnGetLastError;
end;

// ���ù�˽Կ�����ݽ��мӽ��ܣ�ע��ӽ���ʹ�õ���ͬһ�׻��ƣ���������
function Int64RSACrypt(Data: TUInt64; Product: TUInt64; Exponent: TUInt64;
  out Res: TUInt64): Boolean;
begin
  Res := MontgomeryPowerMod(Data, Exponent, Product);
  Result := True;
end;

function GetInt64BitCount(A: TUInt64): Integer;
var
  I: Integer;
begin
  I := 0;
  while A <> 0 do
  begin
    A := A shr 1;
    Inc(I);
  end;
  Result := I;
end;

// ���� RSA �㷨����Ĺ�˽Կ�������������� Cardinal��Keys �������� TUInt64
function CnInt64RSAGenerateKeys(out PrimeKey1: Cardinal; out PrimeKey2: Cardinal;
  out PrivKeyProduct: TUInt64; out PrivKeyExponent: TUInt64;
  out PubKeyProduct: TUInt64; out PubKeyExponent: TUInt64; HighBitSet: Boolean): Boolean;
var
  N: Cardinal;
  Succ: Boolean;
  Product, Y: TUInt64;
begin
  Succ := False;
  repeat
    PrimeKey1 := CnGenerateUInt32Prime(HighBitSet);

    N := Trunc(Random * 100); // �Ե��� CnGenerateUInt32Prime �ڲ��������������
    Sleep(N);

    PrimeKey2 := CnGenerateUInt32Prime(HighBitSet);

    if PrimeKey1 = PrimeKey2 then // �������������
      Continue;

    if HighBitSet then
    begin
      Product := TUInt64(PrimeKey1) * TUInt64(PrimeKey2);
      Succ := GetInt64BitCount(Product) = 64;
    end
    else
      Succ := True;
  until Succ;

  if PrimeKey2 > PrimeKey1 then  // һ��ʹ p > q
  begin
    N := PrimeKey1;
    PrimeKey1 := PrimeKey2;
    PrimeKey2 := N;
  end;

  PrivKeyProduct := TUInt64(PrimeKey1) * TUInt64(PrimeKey2);
  PubKeyProduct := TUInt64(PrimeKey2) * TUInt64(PrimeKey1);   // �� n �ڹ�˽Կ������ͬ��
  PubKeyExponent := 65537;                                    // �̶�

  Product := TUInt64(PrimeKey1 - 1) * TUInt64(PrimeKey2 - 1);

  //                      e                d             (p-1)(q-1)
  // ��շת������� PubKeyExponent * PrivKeyExponent mod Product = 1 �е� PrivKeyExponent
  // r = (p-1)(q-1) Ҳ���ǽⷽ�� e * d + r * y = 1������ e��r ��֪���� d �� y��
  CnInt64ExtendedEuclideanGcd(PubKeyExponent, Product, PrivKeyExponent, Y);
  while UInt64IsNegative(PrivKeyExponent) do
  begin
     // ���������� d С�� 0���򲻷�����������Ҫ�� d ���ϱ����� r���ӵ�������Ϊֹ
     Y := (UInt64Div(-PrivKeyExponent, Product) + 1) * Product;
     PrivKeyExponent := PrivKeyExponent + Y;
  end;
  Result := True;
end;

// �����������ɵ�˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�
function CnInt64RSAEncrypt(Data: TUInt64; PrivKeyProduct: TUInt64;
  PrivKeyExponent: TUInt64; out Res: TUInt64): Boolean;
begin
  Result := Int64RSACrypt(Data, PrivKeyProduct, PrivKeyExponent, Res);
end;

// �����������ɵĹ�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�
function CnInt64RSADecrypt(Res: TUInt64; PubKeyProduct: TUInt64;
  PubKeyExponent: TUInt64; out Data: TUInt64): Boolean;
begin
  Result := Int64RSACrypt(Res, PubKeyProduct, PubKeyExponent, Data);
end;

function CnRSAGenerateKeysByPrimeBits(PrimeBits: Integer; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; PublicKeyUse3: Boolean): Boolean;
var
  N: Integer;
  Suc: Boolean;
  R, Y, Rem, S1, S2, One: TCnBigNumber;
begin
  Result := False;
  if PrimeBits <= 16 then
  begin
    _CnSetLastError(ECN_RSA_INVALID_BITS);
    Exit;
  end;

  PrivateKey.Clear;
  PublicKey.Clear;

  Suc := False;
  while not Suc do
  begin
    if not BigNumberGeneratePrime(PrivateKey.PrimeKey1, PrimeBits div 8) then
      Exit;

    N := Trunc(Random * 1000);
    Sleep(N);

    if not BigNumberGeneratePrime(PrivateKey.PrimeKey2, PrimeBits div 8) then
      Exit;

    // �������������
    if BigNumberEqual(PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
      Continue;

    // TODO: p �� q �Ĳ�ܹ�С��������ʱ�� Continue

    // һ��Ҫ�� Prime1 > Prime2 �Ա���� CRT �Ȳ���
    if BigNumberCompare(PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) < 0 then
      BigNumberSwap(PrivateKey.PrimeKey1, PrivateKey.PrimeKey2);

    if not BigNumberMul(PrivateKey.PrivKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
      Exit;

    // p��q �Ļ��Ƿ����� Bit ����������ʱ�� Continue
    if PrivateKey.PrivKeyProduct.GetBitsCount <> PrimeBits * 2 then
      Continue;

    // TODO: pq �Ļ��� NAF ϵ���Ƿ�����������������ʱ�� Continue

    if not BigNumberMul(PublicKey.PubKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
      Exit;

    if PublicKeyUse3 then
      PublicKey.PubKeyExponent.SetDec('3')
    else
      PublicKey.PubKeyExponent.SetDec('65537');

    Rem := nil;
    Y := nil;
    R := nil;
    S1 := nil;
    S2 := nil;
    One := nil;

    try
      Rem := TCnBigNumber.Create;
      Y := TCnBigNumber.Create;
      R := TCnBigNumber.Create;
      S1 := TCnBigNumber.Create;
      S2 := TCnBigNumber.Create;
      One := TCnBigNumber.Create;

      BigNumberSetOne(One);
      BigNumberSub(S1, PrivateKey.PrimeKey1, One);
      BigNumberSub(S2, PrivateKey.PrimeKey2, One);
      BigNumberMul(R, S1, S2);     // ���������R = (p - 1) * (q - 1)

      // �� e Ҳ���� PubKeyExponent��65537����Ի��� R ��ģ��Ԫ�� d Ҳ���� PrivKeyExponent
      BigNumberExtendedEuclideanGcd(PublicKey.PubKeyExponent, R, PrivateKey.PrivKeyExponent, Y);

      // ���������� d С�� 0���򲻷�����������Ҫ�� d ���ϻ��� R
      if BigNumberIsNegative(PrivateKey.PrivKeyExponent) then
         BigNumberAdd(PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyExponent, R);

      // TODO: d ����̫С��������ʱ�� Continue
{$IFDEF CN_RSA_USE_CRT}
      PrivateKey.UpdateCRT;
{$ENDIF}
    finally
      One.Free;
      S2.Free;
      S1.Free;
      R.Free;
      Y.Free;
      Rem.Free;
    end;

    Suc := True;
  end;
  Result := True;
end;

function CnRSAGenerateKeys(ModulusBits: Integer; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; PublicKeyUse3: Boolean): Boolean;
var
  PB1, PB2, MinDB, MinW: Integer;
  Suc: Boolean;
  Dif, MinD: TCnBigNumber;
  R, Y, Rem, S1, S2, One: TCnBigNumber;
begin
  Result := False;
  _CnSetLastError(ECN_RSA_BIGNUMBER_ERROR);
  if ModulusBits < 128 then
  begin
    _CnSetLastError(ECN_RSA_INVALID_BITS);
    Exit;
  end;

  PrivateKey.Clear;
  PublicKey.Clear;
  Suc := False;

  PB1 := (ModulusBits + 1) div 2;
  PB2 := ModulusBits - PB1;
  MinDB := ModulusBits div 2 - 100;
  if MinDB < ModulusBits div 3 then
    MinDB := ModulusBits div 3;
  MinW := ModulusBits shr 2;

  Rem := nil;
  Y := nil;
  R := nil;
  S1 := nil;
  S2 := nil;
  One := nil;
  Dif := nil;
  MinD := nil;

  try
    Rem := TCnBigNumber.Create;
    Y := TCnBigNumber.Create;
    R := TCnBigNumber.Create;
    S1 := TCnBigNumber.Create;
    S2 := TCnBigNumber.Create;
    One := TCnBigNumber.Create;
    Dif := TCnBigNumber.Create;
    MinD := TCnBigNumber.Create;

    while not Suc do
    begin
      if not BigNumberGeneratePrimeByBitsCount(PrivateKey.PrimeKey1, PB1) then
        Exit;

      if not BigNumberGeneratePrimeByBitsCount(PrivateKey.PrimeKey2, PB2) then
        Exit;

      // �������������
      if BigNumberEqual(PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
        Continue;

      if not BigNumberMul(PrivateKey.PrivKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
        Exit;

      // p��q �Ļ��Ƿ����� Bit ����������ʱ�� Continue
      if PrivateKey.PrivKeyProduct.GetBitsCount <> ModulusBits then
        Continue;

      // ����˻���λ��Ϊ n���� |p-q| ��λ��Ҫ��� n/3 ��Ҳ�� n/2 - 100 ��
      if not BigNumberSub(Dif, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
        Exit;

      if Dif.GetBitsCount <= MinDB then
        Continue;

      // һ��Ҫ�� Prime1 > Prime2 �Ա���� CRT �Ȳ���
      if BigNumberCompare(PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) < 0 then
        BigNumberSwap(PrivateKey.PrimeKey1, PrivateKey.PrimeKey2);

      // TODO: pq �Ļ��ķ�������ʽ��Non-Adjacent Form��NAF ϵ���Ƿ�����������������ʱ�� Continue

      if not BigNumberMul(PublicKey.PubKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
        Exit;

      if PublicKeyUse3 then
        PublicKey.PubKeyExponent.SetDec('3')
      else
        PublicKey.PubKeyExponent.SetDec('65537');

      BigNumberSetOne(One);
      BigNumberSub(S1, PrivateKey.PrimeKey1, One);
      BigNumberSub(S2, PrivateKey.PrimeKey2, One);
      BigNumberMul(R, S1, S2);     // ���������R = (p - 1) * (q - 1)

      // �� e Ҳ���� PubKeyExponent��65537����Ի��� R ��ģ��Ԫ�� d Ҳ���� PrivKeyExponent
      BigNumberExtendedEuclideanGcd(PublicKey.PubKeyExponent, R, PrivateKey.PrivKeyExponent, Y);

      // ���������� d С�� 0���򲻷�����������Ҫ�� d ���ϻ��� R
      if BigNumberIsNegative(PrivateKey.PrivKeyExponent) then
         BigNumberAdd(PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyExponent, R);

      // d ����̫С��������� 2 �� n/2 �η�
      MinD.SetOne;
      MinD.ShiftLeft(MinW);
      if BigNumberCompare(PrivateKey.PrivKeyExponent, MinD) <= 0 then
        Continue;

{$IFDEF CN_RSA_USE_CRT}
      PrivateKey.UpdateCRT;
{$ENDIF}
      Suc := True;
    end;
  finally
    MinD.Free;
    Dif.Free;
    One.Free;
    S2.Free;
    S1.Free;
    R.Free;
    Y.Free;
    Rem.Free;
  end;

  Result := True;
  _CnSetLastError(ECN_RSA_OK);
end;

function CnRSAVerifyKeys(PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey): Boolean;
var
  T, M, P: TCnBigNumber;
begin
  // ˽Կ���������˻�Ҫ����˽Կ�� Product
  // ��˽Կ�� Product �����
  // ��Կָ���� 3 �� 65537
  // ��֤ d
  Result := False;
  if (PrivateKey = nil) or (PublicKey = nil) then
    Exit;

  if not BigNumberEqual(PrivateKey.PrivKeyProduct, PublicKey.PubKeyProduct) then
    Exit;

  // e ֻ���� 3 �� 65537
  if not PublicKey.PubKeyExponent.IsWord(65537) and not PublicKey.PubKeyExponent.IsWord(3) then
    Exit;

  T := nil;
  P := nil;
  M := nil;

  try
    T := TCnBigNumber.Create;
    BigNumberMul(T, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2);
    if not BigNumberEqual(T, PublicKey.PubKeyProduct) then
      Exit;

    // ��֤ d �Ƿ��� e * d mod (p-1)(q-1) = 1
    P := TCnBigNumber.Create;
    BigNumberCopy(P, PrivateKey.PrimeKey1);
    BigNumberCopy(T, PrivateKey.PrimeKey2);
    BigNumberSubWord(P, 1);
    BigNumberSubWord(T, 1);

    BigNumberMul(T, P, T); // T �õ� (p-1)(q-1)

    M := TCnBigNumber.Create;
    BigNumberMul(M, PrivateKey.FPrivKeyExponent, PublicKey.PubKeyExponent); // M �õ� e * d

    BigNumberMod(P, M, T);
    if not P.IsOne then
      Exit;

    Result := True;
    _CnSetLastError(ECN_RSA_OK);
  finally
    M.Free;
    P.Free;
    T.Free;
  end;
end;

// �� PEM ��ʽ�ļ��м��ع�˽Կ����
(*
PKCS#1:
  RSAPrivateKey ::= SEQUENCE {                       0
    version Version,                                 1 0
    modulus INTEGER, �C n                             2 ��˽Կ
    publicExponent INTEGER, �C e                      3 ��Կ
    privateExponent INTEGER, �C d                     4 ˽Կ
    prime1 INTEGER, �C p                              5 ˽Կ
    prime2 INTEGER, �C q                              6 ˽Կ
    exponent1 INTEGER, �C d mod (p-1)                 7 CRT ϵ�� 1
    exponent2 INTEGER, �C d mod (q-1)                 8 CRT ϵ�� 2
    coefficient INTEGER, �C (1/q) mod p               9 CRT ϵ�� 3��q ��� p ��ģ��Ԫ
    otherPrimeInfos OtherPrimeInfos OPTIONAL         10

    ģ��Ԫ x = (1/q) mod p �ɵ� xq = 1 mod p Ҳ�� xq = 1 + yp Ҳ���� qx + (-p)y = 1
    ��������չŷ�����շת�����ֱ�����
  }

PKCS#8:
  PrivateKeyInfo ::= SEQUENCE {
    version         Version,
    algorithm       AlgorithmIdentifier,
    PrivateKey      OCTET STRING
  }

  AlgorithmIdentifier ::= SEQUENCE {
    algorithm       OBJECT IDENTIFIER,
    parameters      ANY DEFINED BY algorithm OPTIONAL
  }
  PrivateKey ������ PKCS#1 �� RSAPrivateKey �ṹ
  Ҳ����
  SEQUENCE (3 elem)
    INTEGER 0
    SEQUENCE (2 elem)
      OBJECT IDENTIFIER 1.2.840.113549.1.1.1 rsaEncryption(PKCS #1)
      NULL
    OCTET STRING (1 elem)
      SEQUENCE (9 elem)
        INTEGER 0
        INTEGER                                       8 ��˽Կ Modulus
        INTEGER                                       9 ��Կ   e
        INTEGER                                       10 ˽Կ  d
        INTEGER                                       11 ˽Կ  p
        INTEGER                                       12 ˽Կ  q
        INTEGER

        INTEGER
*)
function CnRSALoadKeysFromPem(const PemFileName: string; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyHashMethod: TCnKeyHashMethod; const Password: string): Boolean;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(PemFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := CnRSALoadKeysFromPem(Stream, PrivateKey, PublicKey, KeyHashMethod, Password);
  finally
    Stream.Free;
  end;
end;

function CnRSALoadKeysFromPem(PemStream: TStream; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyHashMethod: TCnKeyHashMethod = ckhMd5;
  const Password: string = ''): Boolean;
var
  LoadOK: Boolean;
  MemStream: TMemoryStream;
  Reader: TCnBerReader;
  Node: TCnBerReadNode;
{$IFDEF TSTREAM_LONGINT}
  OldPos: LongInt;
{$ELSE}
  OldPos: Int64;
{$ENDIF}
begin
  Result := False;
  MemStream := nil;
  Reader := nil;

  try
    MemStream := TMemoryStream.Create;
    OldPos := PemStream.Position;

    LoadOK := LoadPemStreamToMemory(PemStream, PEM_RSA_PRIVATE_HEAD, PEM_RSA_PRIVATE_TAIL,
      MemStream, Password, KeyHashMethod);
    if not LoadOK then
    begin
      PemStream.Position := OldPos;
      LoadOK := LoadPemStreamToMemory(PemStream, PEM_PRIVATE_HEAD, PEM_PRIVATE_TAIL,
        MemStream, Password, KeyHashMethod);
    end;

    if not LoadOK then
    begin
      _CnSetLastError(ECN_RSA_PEM_FORMAT_ERROR);
      Exit;
    end;

    Reader := TCnBerReader.Create(PByte(MemStream.Memory), MemStream.Size, True);
    Reader.ParseToTree;

    if Reader.TotalCount >= 12 then // �ӽڵ�࣬˵���� PKCS#8 �� PEM ��˽Կ��ʽ
    begin
      Node := Reader.Items[1]; // 0 ������ Sequence��1 �� Version
      if Node.AsByte = 0 then // ֻ֧�ְ汾 0
      begin
        // 8 �� 9 ���ɹ�Կ
        if PublicKey <> nil then
        begin
          PutIndexedBigIntegerToBigNumber(Reader.Items[8], PublicKey.PubKeyProduct);
          PutIndexedBigIntegerToBigNumber(Reader.Items[9], PublicKey.PubKeyExponent);
        end;

        // 8 10 11 12 ����˽Կ
        if PrivateKey <> nil then
        begin
          PutIndexedBigIntegerToBigNumber(Reader.Items[8], PrivateKey.PrivKeyProduct);
          PutIndexedBigIntegerToBigNumber(Reader.Items[10], PrivateKey.PrivKeyExponent);
          PutIndexedBigIntegerToBigNumber(Reader.Items[11], PrivateKey.PrimeKey1);
          PutIndexedBigIntegerToBigNumber(Reader.Items[12], PrivateKey.PrimeKey2);
{$IFDEF CN_RSA_USE_CRT}
          PrivateKey.UpdateCRT;
{$ENDIF}
        end;

        Result := True;
      end;
    end
    else // �ӽڵ�̫�٣����²������ڲ��ַ����ض�
    begin
      Reader.Free;
      Reader := TCnBerReader.Create(PByte(MemStream.Memory), MemStream.Size);
      Reader.ParseToTree;

      if Reader.TotalCount >= 8 then // ����������ӽڵ㣬�� PKCS#1 �� PEM ��˽Կ��ʽ
      begin
        Node := Reader.Items[1]; // 0 ������ Sequence��1 �� Version
        if Node.AsByte = 0 then // ֻ֧�ְ汾 0
        begin
          // 2 �� 3 ���ɹ�Կ
          if PublicKey <> nil then
          begin
            PutIndexedBigIntegerToBigNumber(Reader.Items[2], PublicKey.PubKeyProduct);
            PutIndexedBigIntegerToBigNumber(Reader.Items[3], PublicKey.PubKeyExponent);
          end;

          // 2 4 5 6 ����˽Կ
          if PrivateKey <> nil then
          begin
            PutIndexedBigIntegerToBigNumber(Reader.Items[2], PrivateKey.PrivKeyProduct);
            PutIndexedBigIntegerToBigNumber(Reader.Items[4], PrivateKey.PrivKeyExponent);
            PutIndexedBigIntegerToBigNumber(Reader.Items[5], PrivateKey.PrimeKey1);
            PutIndexedBigIntegerToBigNumber(Reader.Items[6], PrivateKey.PrimeKey2);
{$IFDEF CN_RSA_USE_CRT}
            PrivateKey.UpdateCRT;
{$ENDIF}
          end;

          Result := True;
          _CnSetLastError(ECN_RSA_OK);
        end;
      end;
    end;

    if Result then
      _CnSetLastError(ECN_RSA_OK)
    else
      _CnSetLastError(ECN_RSA_PEM_FORMAT_ERROR);
  finally
    MemStream.Free;
    Reader.Free;
  end;
end;

// �� PEM ��ʽ�ļ��м��ع�Կ����
// ע�� PKCS#8 �� PublicKey �� PEM �ڱ�׼ ASN.1 ������һ���װ��
// �� Modulus �� Exponent ������ BitString �У���Ҫ Paser ��������
(*
PKCS#1:
  RSAPublicKey ::= SEQUENCE {
      modulus           INTEGER,  -- n
      publicExponent    INTEGER   -- e
  }

PKCS#8:
  PublicKeyInfo ::= SEQUENCE {
    algorithm       AlgorithmIdentifier,
    PublicKey       BIT STRING
  }

  AlgorithmIdentifier ::= SEQUENCE {
    algorithm       OBJECT IDENTIFIER,
    parameters      ANY DEFINED BY algorithm OPTIONAL
  }
  Ҳ����
  SEQUENCE (2 elem)
    SEQUENCE (2 elem)
      OBJECT IDENTIFIER 1.2.840.113549.1.1.1 rsaEncryption(PKCS #1)
      NULL
    BIT STRING (1 elem)
      SEQUENCE (2 elem)
        INTEGER     - Modulus
        INTEGER     - Exponent
*)
function CnRSALoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey; KeyHashMethod: TCnKeyHashMethod; const Password: string): Boolean;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(PemFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := CnRSALoadPublicKeyFromPem(Stream, PublicKey, KeyHashMethod, Password);
  finally
    Stream.Free;
  end;
end;

function CnRSALoadPublicKeyFromPem(const PemStream: TStream;
  PublicKey: TCnRSAPublicKey; KeyHashMethod: TCnKeyHashMethod = ckhMd5;
  const Password: string = ''): Boolean;
var
  Mem: TMemoryStream;
  Reader: TCnBerReader;
{$IFDEF TSTREAM_LONGINT}
  OldPos: LongInt;
{$ELSE}
  OldPos: Int64;
{$ENDIF}
begin
  Result := False;
  Mem := nil;
  Reader := nil;

  try
    Mem := TMemoryStream.Create;
    OldPos := PemStream.Position;

    if LoadPemStreamToMemory(PemStream, PEM_PUBLIC_HEAD, PEM_PUBLIC_TAIL, Mem,
      Password, KeyHashMethod) then
    begin
      // �� PKCS#8 ��ʽ�Ĺ�Կ
      Reader := TCnBerReader.Create(PByte(Mem.Memory), Mem.Size, True);
      Reader.ParseToTree;
      if Reader.TotalCount >= 7 then
      begin
        // 6 �� 7 ���ɹ�Կ
        if PublicKey <> nil then
        begin
          PutIndexedBigIntegerToBigNumber(Reader.Items[6], PublicKey.PubKeyProduct);
          PutIndexedBigIntegerToBigNumber(Reader.Items[7], PublicKey.PubKeyExponent);
        end;

        Result := True;
      end;
    end;

    if Result then
    begin
      _CnSetLastError(ECN_RSA_OK);
      Exit;
    end;

    PemStream.Position := OldPos;
    if LoadPemStreamToMemory(PemStream, PEM_RSA_PUBLIC_HEAD, PEM_RSA_PUBLIC_TAIL,
      Mem, Password, KeyHashMethod) then
    begin
      // �� PKCS#1 ��ʽ�Ĺ�Կ
      Reader := TCnBerReader.Create(PByte(Mem.Memory), Mem.Size);
      Reader.ParseToTree;
      if Reader.TotalCount >= 3 then
      begin
        // 1 �� 2 ���ɹ�Կ
        if PublicKey <> nil then
        begin
          PutIndexedBigIntegerToBigNumber(Reader.Items[1], PublicKey.PubKeyProduct);
          PutIndexedBigIntegerToBigNumber(Reader.Items[2], PublicKey.PubKeyExponent);
        end;
      
        Result := True;
      end;
    end;

    if Result then
      _CnSetLastError(ECN_RSA_OK)
    else
      _CnSetLastError(ECN_RSA_PEM_FORMAT_ERROR);
  finally
    Mem.Free;
    Reader.Free;
  end;
end;

// ����˽Կд�� PEM ��ʽ�ļ���
function CnRSASaveKeysToPem(const PemFileName: string; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType; KeyEncryptMethod: TCnKeyEncryptMethod;
  KeyHashMethod: TCnKeyHashMethod; const Password: string): Boolean;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(PemFileName, fmCreate);
  try
    Result := CnRSASaveKeysToPem(Stream, PrivateKey, PublicKey, KeyType,
      KeyEncryptMethod, KeyHashMethod, Password);
  finally
    Stream.Free;
  end;
end;

function CnRSASaveKeysToPem(PemStream: TStream; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType;
  KeyEncryptMethod: TCnKeyEncryptMethod;
  KeyHashMethod: TCnKeyHashMethod; const Password: string): Boolean;
var
  Root, Node: TCnBerWriteNode;
  Writer: TCnBerWriter;
  Mem: TMemoryStream;
  N, T, R1, R2, X, Y : TCnBigNumber;
  B: Byte;
begin
  Result := False;
  if (PublicKey = nil) or (PublicKey.PubKeyProduct.GetBytesCount <= 0) or
    (PublicKey.PubKeyExponent.GetBytesCount <= 0) then
  begin
    _CnSetLastError(ECN_RSA_INVALID_INPUT);
    Exit;
  end;

  if (PrivateKey = nil) or (PrivateKey.PrivKeyProduct.GetBytesCount <= 0) or
    (PrivateKey.PrivKeyExponent.GetBytesCount <= 0) then
  begin
    _CnSetLastError(ECN_RSA_INVALID_INPUT);
    Exit;
  end;

  Mem := nil;
  Writer := nil;
  T := nil;
  R1 := nil;
  R2 := nil;
  N := nil;
  X := nil;
  Y := nil;

  try
    T := BigNumberNew;
    R1 := BigNumberNew;
    R2 := BigNumberNew;
    N := BigNumberNew;
    X := BigNumberNew;
    Y := BigNumberNew;
    if not T.SetOne then
      Exit;

    BigNumberSub(N, PrivateKey.PrimeKey1, T);
    BigNumberMod(R1, PrivateKey.PrivKeyExponent, N); // R1 = d mod (p - 1)

    BigNumberSub(N, PrivateKey.PrimeKey2, T);
    BigNumberMod(R2, PrivateKey.PrivKeyExponent, N); // R2 = d mod (q - 1)

    // X = �ǲ������� qx + (-p)y = 1 �Ľ�
    BigNumberExtendedEuclideanGcd(PrivateKey.PrimeKey2, PrivateKey.PrimeKey1, X, Y);
    if BigNumberIsNegative(X) then
      BigNumberAdd(X, X, PrivateKey.PrimeKey1);

    Writer := TCnBerWriter.Create;
    Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
    B := 0;
    if KeyType = cktPKCS1 then
    begin
      // ƴ PKCS1 ��ʽ������
      Writer.AddBasicNode(CN_BER_TAG_INTEGER, @B, 1, Root);
      AddBigNumberToWriter(Writer, PrivateKey.PrivKeyProduct, Root);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Root);
      AddBigNumberToWriter(Writer, PrivateKey.PrivKeyExponent, Root);
      AddBigNumberToWriter(Writer, PrivateKey.PrimeKey1, Root);
      AddBigNumberToWriter(Writer, PrivateKey.PrimeKey2, Root);
      AddBigNumberToWriter(Writer, R1, Root);
      AddBigNumberToWriter(Writer, R2, Root);
      AddBigNumberToWriter(Writer, X, Root);
    end
    else if KeyType = cktPKCS8 then
    begin
      // ƴ PKCS8 ��ʽ������
      Writer.AddBasicNode(CN_BER_TAG_INTEGER, @B, 1, Root);
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);

      // �� Node1 �� ObjectIdentifier �� Null
      Writer.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @CN_OID_RSAENCRYPTION_PKCS1[0],
        SizeOf(CN_OID_RSAENCRYPTION_PKCS1), Node);
      Writer.AddNullNode(Node);

      Node := Writer.AddContainerNode(CN_BER_TAG_OCTET_STRING, Root);
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Node);

      Writer.AddBasicNode(CN_BER_TAG_INTEGER, @B, 1, Node);
      AddBigNumberToWriter(Writer, PrivateKey.PrivKeyProduct, Node);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Node);
      AddBigNumberToWriter(Writer, PrivateKey.PrivKeyExponent, Node);
      AddBigNumberToWriter(Writer, PrivateKey.PrimeKey1, Node);
      AddBigNumberToWriter(Writer, PrivateKey.PrimeKey2, Node);
      AddBigNumberToWriter(Writer, R1, Node);
      AddBigNumberToWriter(Writer, R2, Node);
      AddBigNumberToWriter(Writer, X, Node);
    end;

    // ������ˣ������ Base64 �ٷֶ���ƴͷβ���д�ļ�
    Mem := TMemoryStream.Create;
    Writer.SaveToStream(Mem);

    if KeyType = cktPKCS1 then
      Result := SaveMemoryToPemStream(PemStream, PEM_RSA_PRIVATE_HEAD,
        PEM_RSA_PRIVATE_TAIL, Mem, KeyEncryptMethod, KeyHashMethod, Password)
    else if KeyType = cktPKCS8 then
      Result := SaveMemoryToPemStream(PemStream, PEM_PRIVATE_HEAD,
        PEM_PRIVATE_TAIL, Mem, KeyEncryptMethod, KeyHashMethod, Password);

    if Result then
      _CnSetLastError(ECN_RSA_OK)
    else
      _CnSetLastError(ECN_RSA_PEM_FORMAT_ERROR);
  finally
    BigNumberFree(T);
    BigNumberFree(R1);
    BigNumberFree(R2);
    BigNumberFree(N);
    BigNumberFree(X);
    BigNumberFree(Y);

    Mem.Free;
    Writer.Free;
  end;
end;

// ����Կд�� PEM ��ʽ�ļ���
function CnRSASavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType;
  KeyEncryptMethod: TCnKeyEncryptMethod; const Password: string): Boolean;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(PemFileName, fmCreate);
  try
    Result := CnRSASavePublicKeyToPem(Stream, PublicKey, KeyType,
      KeyEncryptMethod, Password);
  finally
    Stream.Free;
  end;
end;

function CnRSASavePublicKeyToPem(PemStream: TStream;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType;
  KeyEncryptMethod: TCnKeyEncryptMethod; const Password: string): Boolean;
var
  Root, Node: TCnBerWriteNode;
  Writer: TCnBerWriter;
  Mem: TMemoryStream;
begin
  Result := False;
  if (PublicKey = nil) or (PublicKey.PubKeyProduct.GetBytesCount <= 0) or
    (PublicKey.PubKeyExponent.GetBytesCount <= 0) then
  begin
    _CnSetLastError(ECN_RSA_INVALID_INPUT);
    Exit;
  end;

  Writer := nil;
  Mem := nil;

  try
    Writer := TCnBerWriter.Create;
    Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
    if KeyType = cktPKCS1 then
    begin
      // ƴ PKCS1 ��ʽ�����ݣ��Ƚϼ�
      AddBigNumberToWriter(Writer, PublicKey.PubKeyProduct, Root);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Root);
    end
    else if KeyType = cktPKCS8 then
    begin
      // ƴ PKCS8 ��ʽ������
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);

      // �� Node �� ObjectIdentifier �� Null
      Writer.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @CN_OID_RSAENCRYPTION_PKCS1[0],
        SizeOf(CN_OID_RSAENCRYPTION_PKCS1), Node);
      Writer.AddNullNode(Node);

      Node := Writer.AddContainerNode(CN_BER_TAG_BIT_STRING, Root);
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Node);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyProduct, Node);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Node);
    end;

    // ������ˣ������ Base64 �ٷֶ���ƴͷβ���д�ļ�
    Mem := TMemoryStream.Create;
    Writer.SaveToStream(Mem);

    if KeyType = cktPKCS1 then
      Result := SaveMemoryToPemStream(PemStream, PEM_RSA_PUBLIC_HEAD,
        PEM_RSA_PUBLIC_TAIL, Mem, KeyEncryptMethod, ckhMd5, Password)
    else if KeyType = cktPKCS8 then
      Result := SaveMemoryToPemStream(PemStream, PEM_PUBLIC_HEAD,
        PEM_PUBLIC_TAIL, Mem, KeyEncryptMethod, ckhMd5, Password);

    if Result then
      _CnSetLastError(ECN_RSA_OK)
    else
      _CnSetLastError(ECN_RSA_PEM_FORMAT_ERROR);
  finally
    Mem.Free;
    Writer.Free;
  end;
end;

// ���ù�˽Կ�����ݽ��мӽ��ܣ�ע��ӽ���ʹ�õ���ͬһ�׻��ƣ��������֡��ڲ������ô�����
function RSACrypt(Data: TCnBigNumber; Product: TCnBigNumber; Exponent: TCnBigNumber;
  Res: TCnBigNumber): Boolean;
begin
  Result := BigNumberMontgomeryPowerMod(Res, Data, Exponent, Product);
  if not Result then
    _CnSetLastError(ECN_RSA_BIGNUMBER_ERROR);
end;

// ����˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�
function CnRSAEncrypt(Data: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Res: TCnBigNumber): Boolean;
begin
  Result := CnRSADecrypt(Res, PrivateKey, Data); // ��������ͬһ��˽Կ���㣬�ɸ���
end;

// ���ù�Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�
function CnRSAEncrypt(Data: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Res: TCnBigNumber): Boolean;
begin
  Result := RSACrypt(Res, PublicKey.PubKeyProduct, PublicKey.PubKeyExponent, Data);
end;

// ����˽Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�
function CnRSADecrypt(Res: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Data: TCnBigNumber): Boolean;
{$IFDEF CN_RSA_USE_CRT}
var
  M1, M2: TCnBigNumber;
{$ENDIF}
begin
{$IFDEF CN_RSA_USE_CRT}
  M1 := nil;
  M2 := nil;

  // m1 = c^dP mod p
  // m2 = c^dQ mod q
  // h = qInv.(m1 - m2) mod p
  // m = m2 + h.q

  try
    M1 := TCnBigNumber.Create;
    BigNumberMontgomeryPowerMod(M1, Data, PrivateKey.FDP1, PrivateKey.FPrimeKey1);
    // m1 = c^dP mod p

    M2 := TCnBigNumber.Create;
    BigNumberMontgomeryPowerMod(M2, Data, PrivateKey.FDQ1, PrivateKey.FPrimeKey2);
    // m2 = c^dQ mod q

    // ���¸��� m1
    BigNumberSubMod(M1, M1, M2, PrivateKey.FPrimeKey1);
    // m1 := m1 - m2 mod p

    BigNumberDirectMulMod(M1, PrivateKey.FQInv, M1, PrivateKey.FPrimeKey1);
    // m1 := qInv * m1 mod p

    BigNumberMul(M1, M1, PrivateKey.FPrimeKey2);
    // m1 := m1 * q

    BigNumberAdd(Res, M2, M1);
    // m = m2 + m1

    Result := True;
  finally
    M2.Free;
    M1.Free;
  end;
{$ELSE}
  Result := RSACrypt(Data, PrivateKey.PrivKeyProduct, PrivateKey.PrivKeyExponent, Res);
{$ENDIF}
end;

// ���ù�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�
function CnRSADecrypt(Res: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Data: TCnBigNumber): Boolean;
begin
  Result := CnRSAEncrypt(Data, PublicKey, Res); // ��������ͬһ����Կ���㣬�ɸ���
end;

{ TCnRSAPrivateKey }

procedure TCnRSAPrivateKey.Assign(Source: TPersistent);
begin
  if Source is TCnRSAPrivateKey then
  begin
    BigNumberCopy(FPrimeKey1, (Source as TCnRSAPrivateKey).PrimeKey1);
    BigNumberCopy(FPrimeKey2, (Source as TCnRSAPrivateKey).PrimeKey2);
    BigNumberCopy(FPrivKeyProduct, (Source as TCnRSAPrivateKey).PrivKeyProduct);
    BigNumberCopy(FPrivKeyExponent, (Source as TCnRSAPrivateKey).PrivKeyExponent);
{$IFDEF CN_RSA_USE_CRT}
    BigNumberCopy(FDP1, (Source as TCnRSAPrivateKey).FDP1);
    BigNumberCopy(FDQ1, (Source as TCnRSAPrivateKey).FDQ1);
    BigNumberCopy(FQInv, (Source as TCnRSAPrivateKey).FQInv);
{$ENDIF}
  end
  else
    inherited;
end;

procedure TCnRSAPrivateKey.Clear;
begin
  FPrimeKey1.Clear;
  FPrimeKey2.Clear;
  FPrivKeyProduct.Clear;
  FPrivKeyExponent.Clear;
end;

{$IFDEF CN_RSA_USE_CRT}

procedure TCnRSAPrivateKey.UpdateCRT;
var
  T: TCnBigNumber;
begin
  T := TCnBigNumber.Create;
  try
    if BigNumberCompare(FPrimeKey1, FPrimeKey2) < 0 then // ȷ�� p > q
      BigNumberSwap(FPrimeKey1, FPrimeKey2);

    // ���� DP1 = D mod (PrimeKey1 - 1);
    BigNumberCopy(T, FPrimeKey1);
    T.SubWord(1);
    BigNumberMod(FDP1, FPrivKeyExponent, T);

    // ���� DQ1 = D mod (PrimeKey2 - 1);
    BigNumberCopy(T, FPrimeKey2);
    T.SubWord(1);
    BigNumberMod(FDQ1, FPrivKeyExponent, T);

    // ���� QInv = Prime2 �� Prime1 ��ģ��Ԫ
    BigNumberModularInverse(FQInv, FPrimeKey2, FPrimeKey1);
  finally
    T.Free;
  end;
end;

{$ENDIF}

constructor TCnRSAPrivateKey.Create;
begin
  inherited;
  FPrimeKey1 := TCnBigNumber.Create;
  FPrimeKey2 := TCnBigNumber.Create;
  FPrivKeyProduct := TCnBigNumber.Create;
  FPrivKeyExponent := TCnBigNumber.Create;
{$IFDEF CN_RSA_USE_CRT}
  FDP1 := TCnBigNumber.Create;
  FDQ1 := TCnBigNumber.Create;
  FQInv := TCnBigNumber.Create;
{$ENDIF}
end;

destructor TCnRSAPrivateKey.Destroy;
begin
{$IFDEF CN_RSA_USE_CRT}
  FQInv.Free;
  FDQ1.Free;
  FDP1.Free;
{$ENDIF}
  FPrivKeyExponent.Free;
  FPrivKeyProduct.Free;
  FPrimeKey2.Free;
  FPrimeKey1.Free;
  inherited;
end;

function TCnRSAPrivateKey.GetBitsCount: Integer;
begin
  Result := FPrivKeyProduct.GetBitsCount;
end;

function TCnRSAPrivateKey.GetBytesCount: Integer;
begin
  Result := FPrivKeyProduct.GetBytesCount;
end;

{ TCnRSAPublicKey }

procedure TCnRSAPublicKey.Assign(Source: TPersistent);
begin
  if Source is TCnRSAPublicKey then
  begin
    BigNumberCopy(FPubKeyProduct, (Source as TCnRSAPublicKey).PubKeyProduct);
    BigNumberCopy(FPubKeyExponent, (Source as TCnRSAPublicKey).PubKeyExponent);
  end
  else
    inherited;
end;

procedure TCnRSAPublicKey.Clear;
begin
  FPubKeyProduct.Clear;
  FPubKeyExponent.Clear;
end;

constructor TCnRSAPublicKey.Create;
begin
  inherited;
  FPubKeyProduct := TCnBigNumber.Create;
  FPubKeyExponent := TCnBigNumber.Create;
end;

destructor TCnRSAPublicKey.Destroy;
begin
  FPubKeyExponent.Free;
  FPubKeyProduct.Free;
  inherited;
end;

function TCnRSAPublicKey.GetBitsCount: Integer;
begin
  Result := FPubKeyProduct.GetBitsCount;
end;

function TCnRSAPublicKey.GetBytesCount: Integer;
begin
  Result := FPubKeyProduct.GetBytesCount;
end;

{ RSA ���ܽ�������}

function RSACryptRawData(Data: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; Exponent, Product: TCnBigNumber): Boolean;
var
  D, R: TCnBigNumber;
begin
  Result := False;
  if (Data <> nil) and (DataByteLen > 0) then
  begin
    R := TCnBigNumber.Create;
    D := TCnBigNumber.FromBinary(PAnsiChar(Data), DataByteLen);

    if RSACrypt(D, Product, Exponent, R) then
    begin
      R.ToBinary(OutBuf); // TODO: Fixed Len?
      OutLen := R.GetBytesCount;

      Result := True;
      _CnSetLastError(ECN_RSA_OK);
    end;
  end
  else
    _CnSetLastError(ECN_RSA_INVALID_INPUT);
end;

function CnRSAEncryptRawData(PlainData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PublicKey: TCnRSAPublicKey): Boolean;
begin
  Result := RSACryptRawData(PlainData, DataByteLen, OutBuf, OutLen,
    PublicKey.PubKeyExponent, PublicKey.PubKeyProduct);
end;

function CnRSAEncryptRawData(PlainData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PrivateKey: TCnRSAPrivateKey): Boolean;
begin
  Result := RSACryptRawData(PlainData, DataByteLen, OutBuf, OutLen,
    PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyProduct);
end;

function CnRSADecryptRawData(EnData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PublicKey: TCnRSAPublicKey): Boolean;
begin
  Result := RSACryptRawData(EnData, DataByteLen, OutBuf, OutLen,
    PublicKey.PubKeyExponent, PublicKey.PubKeyProduct);
end;

function CnRSADecryptRawData(EnData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PrivateKey: TCnRSAPrivateKey): Boolean;
begin
  Result := RSACryptRawData(EnData, DataByteLen, OutBuf, OutLen,
    PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyProduct);
end;

// ��һƬ�ڴ�����ָ���� Padding ģʽ������������� RSA �ӽ��ܼ���
function RSAPaddingCrypt(PaddingType, BlockSize: Integer; PlainData: Pointer;
  DataByteLen: Integer; OutBuf: Pointer; Exponent, Product: TCnBigNumber;
  PaddingMode: TCnRSAPaddingMode): Boolean;
var
  Stream: TMemoryStream;
  Res, Data: TCnBigNumber;
begin
  Result := False;
  Res := nil;
  Data := nil;
  Stream := nil;

  try
    Stream := TMemoryStream.Create;
    if PaddingMode = cpmPKCS1 then
    begin
      if not AddPKCS1Padding(PaddingType, BlockSize, PlainData, DataByteLen, Stream) then
      begin
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
        Exit;
      end;
    end
    else if PaddingMode = cpmOAEP then
    begin
      // OAEP ��Կ���ܣ�����Կ�Ŀ����ڵ�����
      Stream.Size := Product.GetBytesCount;
      if not AddOaepSha1MgfPadding(Stream.Memory, Stream.Size, PlainData, DataByteLen) then
      begin
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
        Exit;
      end;
    end;

    Res := TCnBigNumber.Create;
    Data := TCnBigNumber.FromBinary(PAnsiChar(Stream.Memory), Stream.Size);
    if not RSACrypt(Data, Product, Exponent, Res) then
      Exit;

    Res.ToBinary(PAnsiChar(OutBuf), Stream.Size);

    Result := True;
    _CnSetLastError(ECN_RSA_OK);
  finally
    Stream.Free;
    Data.Free;
    Res.Free;
  end;
end;

function CnRSAEncryptData(PlainData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  PublicKey: TCnRSAPublicKey; PaddingMode: TCnRSAPaddingMode): Boolean;
begin
  Result := RSAPaddingCrypt(CN_PKCS1_BLOCK_TYPE_PUBLIC_RANDOM, PublicKey.BitsCount div 8,
    PlainData, DataByteLen, OutBuf, PublicKey.PubKeyExponent, PublicKey.PubKeyProduct, PaddingMode);
end;

function CnRSAEncryptData(PlainData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  PrivateKey: TCnRSAPrivateKey): Boolean;
begin
  Result := RSAPaddingCrypt(CN_PKCS1_BLOCK_TYPE_PRIVATE_FF, PrivateKey.BitsCount div 8,
    PlainData, DataByteLen, OutBuf, PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyProduct, cpmPKCS1);
  // ˽Կ����ֻ֧�� PKCS1 ���뷽ʽ����֧�� OAEP ���뷽ʽ
end;

function CnRSAEncryptFile(const InFileName, OutFileName: string;
  PublicKey: TCnRSAPublicKey; PaddingMode: TCnRSAPaddingMode): Boolean;
var
  Stream: TMemoryStream;
  Res: TBytes;
begin
  Result := False;
  Stream := nil;
  try
    SetLength(Res, PublicKey.BytesCount);

    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(InFileName);
    if not CnRSAEncryptData(Stream.Memory, Stream.Size, @Res[0], PublicKey, PaddingMode) then
      Exit;

    Stream.Clear;
    Stream.Write(Res[0], PublicKey.BytesCount);
    Stream.SaveToFile(OutFileName);

    Result := True;
    _CnSetLastError(ECN_RSA_OK);
  finally
    Stream.Free;
    SetLength(Res, 0);
  end;
end;

function CnRSAEncryptFile(const InFileName, OutFileName: string;
  PrivateKey: TCnRSAPrivateKey): Boolean;
var
  Stream: TMemoryStream;
  Res: TBytes;
begin
  Result := False;
  Stream := nil;
  try
    SetLength(Res, PrivateKey.BytesCount);

    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(InFileName);
    if not CnRSAEncryptData(Stream.Memory, Stream.Size, @Res[0], PrivateKey) then
      Exit;

    Stream.Clear;
    Stream.Write(Res[0], PrivateKey.BytesCount);
    Stream.SaveToFile(OutFileName);

    Result := True;
    _CnSetLastError(ECN_RSA_OK);
  finally
    Stream.Free;
    SetLength(Res, 0);
  end;
end;

// ��һƬ�ڴ�������� RSA �ӽ��ܼ������չ�ֵ� Padding ��ʽ���ԭʼ����
function RSADecryptPadding(BlockSize: Integer; EnData: Pointer; DataByteLen: Integer;
  OutBuf: Pointer; out OutLen: Integer; Exponent, Product: TCnBigNumber;
  PaddingMode: TCnRSAPaddingMode): Boolean;
var
  Stream: TMemoryStream;
  Res, Data: TCnBigNumber;
  ResBuf: TBytes;
begin
  Result := False;
  Res := nil;
  Data := nil;
  Stream := nil;

  try
    Res := TCnBigNumber.Create;
    Data := TCnBigNumber.FromBinary(PAnsiChar(EnData), DataByteLen);
    if not RSACrypt(Data, Product, Exponent, Res) then
      Exit;

    SetLength(ResBuf, BlockSize);
    Res.ToBinary(PAnsiChar(@ResBuf[0]), BlockSize);
    // ������� Res ����ǰ���� 0 ���� GetBytesCount ���� BlockSize����Ҫ�Ҷ���

    if PaddingMode = cpmPKCS1 then
    begin
      Result := RemovePKCS1Padding(@ResBuf[0], Length(ResBuf), OutBuf, OutLen);
      if not Result then
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
    end
    else if PaddingMode = cpmOAEP then
    begin
      // OAEP ���ܣ���˽Կ�Ŀ����ڵ�����
      Result := RemoveOaepSha1MgfPadding(OutBuf, OutLen, @ResBuf[0], Length(ResBuf));

      if Result then
        _CnSetLastError(ECN_RSA_OK)
      else
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
    end;
  finally
    Stream.Free;
    Res.Free;
    Data.Free;
  end;
end;

function CnRSADecryptData(EnData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PublicKey: TCnRSAPublicKey): Boolean;
begin
  Result := RSADecryptPadding(PublicKey.GetBytesCount, EnData, DataByteLen,
    OutBuf, OutLen, PublicKey.PubKeyExponent, PublicKey.PubKeyProduct, cpmPKCS1);
  // ��Կ����ֻ֧�� PKCS1����֧�� OAEP
end;

function CnRSADecryptData(EnData: Pointer; DataByteLen: Integer; OutBuf: Pointer;
  out OutLen: Integer; PrivateKey: TCnRSAPrivateKey; PaddingMode: TCnRSAPaddingMode): Boolean;
begin
  Result := RSADecryptPadding(PrivateKey.GetBytesCount, EnData, DataByteLen,
    OutBuf, OutLen, PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyProduct, PaddingMode);
end;

function CnRSADecryptFile(const InFileName, OutFileName: string;
  PublicKey: TCnRSAPublicKey): Boolean;
var
  Stream: TMemoryStream;
  Res: TBytes;
  OutLen: Integer;
begin
  Result := False;
  Stream := nil;
  try
    SetLength(Res, PublicKey.GetBytesCount);

    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(InFileName);

    if Stream.Size <> PublicKey.GetBytesCount then
    begin
      _CnSetLastError(ECN_RSA_INVALID_INPUT);
      Exit;
    end;

    if not CnRSADecryptData(Stream.Memory, Stream.Size, @Res[0], OutLen, PublicKey) then
      Exit;

    Stream.Clear;
    Stream.Write(Res[0], OutLen);
    Stream.SaveToFile(OutFileName);

    Result := True;
    _CnSetLastError(ECN_RSA_OK);
  finally
    Stream.Free;
    SetLength(Res, 0);
  end;
end;

function CnRSADecryptFile(const InFileName, OutFileName: string;
  PrivateKey: TCnRSAPrivateKey; PaddingMode: TCnRSAPaddingMode): Boolean;
var
  Stream: TMemoryStream;
  Res: TBytes;
  OutLen: Integer;
begin
  Result := False;
  Stream := nil;
  try
    SetLength(Res, PrivateKey.BytesCount);

    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(InFileName);

    if Stream.Size <> PrivateKey.GetBytesCount then
    begin
      _CnSetLastError(ECN_RSA_INVALID_INPUT);
      Exit;
    end;

    if not CnRSADecryptData(Stream.Memory, Stream.Size, @Res[0], OutLen, PrivateKey, PaddingMode) then
      Exit;

    Stream.Clear;
    Stream.Write(Res[0], OutLen);
    Stream.SaveToFile(OutFileName);

    Result := True;
    _CnSetLastError(ECN_RSA_OK);
  finally
    Stream.Free;
    SetLength(Res, 0);
  end;
end;

// RSA �ļ�ǩ������֤ʵ��

// ����ָ������ժҪ�㷨����ָ�����Ķ������Ӵ�ֵ��д�� Stream����������ڲ������ô�����
function CalcDigestStream(InStream: TStream; SignType: TCnRSASignDigestType;
  outStream: TStream): Boolean;
var
  Md5: TCnMD5Digest;
  Sha1: TCnSHA1Digest;
  Sha256: TCnSHA256Digest;
  Sm3Dig: TCnSM3Digest;
begin
  Result := False;
  case SignType of
    rsdtMD5:
      begin
        Md5 := MD5Stream(InStream);
        outStream.Write(Md5, SizeOf(TCnMD5Digest));
        Result := True;
      end;
    rsdtSHA1:
      begin
        Sha1 := SHA1Stream(InStream);
        outStream.Write(Sha1, SizeOf(TCnSHA1Digest));
        Result := True;
      end;
    rsdtSHA256:
      begin
        Sha256 := SHA256Stream(InStream);
        outStream.Write(Sha256, SizeOf(TCnSHA256Digest));
        Result := True;
      end;
    rsdtSM3:
      begin
        Sm3Dig := SM3Stream(InStream);
        outStream.Write(Sm3Dig, SizeOf(TCnSM3Digest));
        Result := True;
      end
  end;

  if Result then
    _CnSetLastError(ECN_RSA_OK)
  else
    _CnSetLastError(ECN_RSA_DIGEST_ERROR);
end;

// ����ָ������ժҪ�㷨�����ļ��Ķ������Ӵ�ֵ��д�� Stream
function CalcDigestFile(const FileName: string; SignType: TCnRSASignDigestType;
  outStream: TStream): Boolean;
var
  Md5: TCnMD5Digest;
  Sha1: TCnSHA1Digest;
  Sha256: TCnSHA256Digest;
  Sm3Dig: TCnSM3Digest;
begin
  Result := False;
  case SignType of
    rsdtMD5:
      begin
        Md5 := MD5File(FileName);
        outStream.Write(Md5, SizeOf(TCnMD5Digest));
        Result := True;
      end;
    rsdtSHA1:
      begin
        Sha1 := SHA1File(FileName);
        outStream.Write(Sha1, SizeOf(TCnSHA1Digest));
        Result := True;
      end;
    rsdtSHA256:
      begin
        Sha256 := SHA256File(FileName);
        outStream.Write(Sha256, SizeOf(TCnSHA256Digest));
        Result := True;
      end;
    rsdtSM3:
      begin
        Sm3Dig := SM3File(FileName);
        outStream.Write(Sm3Dig, SizeOf(TCnSM3Digest));
        Result := True;
      end;
  end;

  if Result then
    _CnSetLastError(ECN_RSA_OK)
  else
    _CnSetLastError(ECN_RSA_DIGEST_ERROR);
end;

function AddDigestTypeOIDNodeToWriter(AWriter: TCnBerWriter; ASignType: TCnRSASignDigestType;
  AParent: TCnBerWriteNode): TCnBerWriteNode;
begin
  Result := nil;
  case ASignType of
    rsdtMD5:
      Result := AWriter.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @OID_SIGN_MD5[0],
        SizeOf(OID_SIGN_MD5), AParent);
    rsdtSHA1:
      Result := AWriter.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @OID_SIGN_SHA1[0],
        SizeOf(OID_SIGN_SHA1), AParent);
    rsdtSHA256:
      Result := AWriter.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @OID_SIGN_SHA256[0],
        SizeOf(OID_SIGN_SHA256), AParent);
  end;
end;

{
  ͨ������ժҪ�㷨���������ժҪ�󣬻�Ҫ���� BER ������ PKCS1 Padding
  BER ����ĸ�ʽ���£�
  DigestInfo ::= SEQUENCE )
    digestAlgorithm DigestAlgorithmIdentifier,
    digest Digest )

  DigestAlgorithmIdentifier ::= AlgorithmIdentifier
  Digest ::= OCTET STRING

  Ҳ���ǣ�
  SEQUENCE
    SEQUENCE
      OBJECT IDENTIFIER
      NULL
    OCTET STRING
}

function CnRSASignStream(InStream: TMemoryStream; OutSignStream: TMemoryStream;
  PrivateKey: TCnRSAPrivateKey; SignType: TCnRSASignDigestType = rsdtMD5): Boolean;
var
  Stream, BerStream, EnStream: TMemoryStream;
  Data, Res: TCnBigNumber;
  ResBuf: TBytes;
  Writer: TCnBerWriter;
  Root, Node: TCnBerWriteNode;
begin
  Result := False;
  Stream := nil;
  EnStream := nil;
  BerStream := nil;
  Writer := nil;
  Data := nil;
  Res := nil;

  try
    Stream := TMemoryStream.Create;
    EnStream := TMemoryStream.Create;

    if SignType = rsdtNone then
    begin
      // ������ժҪ��ֱ�������ݶ���
      if not AddPKCS1Padding(CN_PKCS1_BLOCK_TYPE_PRIVATE_FF, PrivateKey.GetBytesCount,
        InStream.Memory, InStream.Size, EnStream) then
      begin
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
        Exit;
      end;
    end
    else // ������ժҪ
    begin
      if not CalcDigestStream(InStream, SignType, Stream) then // ���������Ӵ�ֵ
        Exit;

      BerStream := TMemoryStream.Create;
      Writer := TCnBerWriter.Create;

      // Ȼ�󰴸�ʽ���� BER ����
      Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);
      AddDigestTypeOIDNodeToWriter(Writer, SignType, Node);
      Writer.AddNullNode(Node);
      Writer.AddBasicNode(CN_BER_TAG_OCTET_STRING, Stream.Memory, Stream.Size, Root);
      Writer.SaveToStream(BerStream);

      // �ٰ� BER ���������� PKCS1 ������
      if not AddPKCS1Padding(CN_PKCS1_BLOCK_TYPE_PRIVATE_FF, PrivateKey.GetBytesCount,
        BerStream.Memory, BerStream.Size, EnStream) then
      begin
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
        Exit;
      end;
    end;

    // ˽Կ��������
    Data := TCnBigNumber.FromBinary(PAnsiChar(EnStream.Memory), EnStream.Size);
    Res := TCnBigNumber.Create;

    if RSACrypt(Data, PrivateKey.PrivKeyProduct, PrivateKey.PrivKeyExponent, Res) then
    begin
      // ע�� Res ���ܴ���ǰ�� 0�����Դ˴������� PrivateKey.GetBytesCount Ϊ׼������ȷ����©ǰ�� 0
      SetLength(ResBuf, PrivateKey.GetBytesCount);
      Res.ToBinary(@ResBuf[0], PrivateKey.GetBytesCount);

      // ������˽Կ���ܺ���������ļ�
      Stream.Clear;
      Stream.Write(ResBuf[0], PrivateKey.GetBytesCount);
      Stream.SaveToStream(OutSignStream);

      Result := True;
      _CnSetLastError(ECN_RSA_OK);
    end;
  finally
    Stream.Free;
    EnStream.Free;
    BerStream.Free;
    Data.Free;
    Res.Free;
    Writer.Free;
    SetLength(ResBuf, 0);
  end;
end;

function CnRSAVerifyStream(InStream: TMemoryStream; InSignStream: TMemoryStream;
  PublicKey: TCnRSAPublicKey; SignType: TCnRSASignDigestType = rsdtMD5): Boolean;
var
  Stream: TMemoryStream;
  Data, Res: TCnBigNumber;
  ResBuf, BerBuf: TBytes;
  BerLen: Integer;
  Reader: TCnBerReader;
  Node: TCnBerReadNode;
begin
  Result := False;
  Stream := nil;
  Reader := nil;
  Data := nil;
  Res := nil;

  try
    Stream := TMemoryStream.Create;

    // ��������ǩ�������ȹ�Կ����
    Data := TCnBigNumber.FromBinary(PAnsiChar(InSignStream.Memory), InSignStream.Size);
    Res := TCnBigNumber.Create;

    if RSACrypt(Data, PublicKey.PubKeyProduct, PublicKey.PubKeyExponent, Res) then
    begin
      // ע�� Res ���ܴ���ǰ�� 0�����Դ˴������� PublicKey.GetBytesCount Ϊ׼������ȷ����©ǰ�� 0
      SetLength(ResBuf, PublicKey.GetBytesCount);
      Res.ToBinary(@ResBuf[0], PublicKey.GetBytesCount);

      // �� Res �н�� PKCS1 ��������ݷ��� BerBuf ��
      SetLength(BerBuf, Length(ResBuf));
      if not RemovePKCS1Padding(@ResBuf[0], Length(ResBuf), @BerBuf[0], BerLen) then
      begin
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
        Exit;
      end;

      if SignType = rsdtNone then
      begin
        // ��ժҪʱ���ӽ���������ȥ���� PKCS1 �� Padding ��ʣ������ֱ����ԭʼ InStream ���ݱȶ�
        Result := InStream.Size = BerLen;
        if Result then
          Result := CompareMem(InStream.Memory, @BerBuf[0], InStream.Size);

        _CnSetLastError(ECN_RSA_OK); // ��������У�飬��ʹУ�鲻ͨ��Ҳ��մ�����
      end
      else
      begin
        if (BerLen <= 0) or (BerLen >= Length(ResBuf)) then
        begin
          _CnSetLastError(ECN_RSA_BER_ERROR);
          Exit;
        end;

        // �⿪ Ber ������ı���������㷨����ʹ�� SignType ԭʼֵ
        Reader := TCnBerReader.Create(@BerBuf[0], BerLen);
        Reader.ParseToTree;
        if Reader.TotalCount < 5 then
        begin
          _CnSetLastError(ECN_RSA_BER_ERROR);
          Exit;
        end;

        Node := Reader.Items[2];
        SignType := GetDigestSignTypeFromBerOID(Node.BerDataAddress, Node.BerDataLength);
        if SignType = rsdtNone then
        begin
          _CnSetLastError(ECN_RSA_BER_ERROR);
          Exit;
        end;

        if not CalcDigestStream(InStream, SignType, Stream) then // ���������Ӵ�ֵ
          Exit;

        // �� Ber ������Ӵ�ֵ�Ƚ�
        Node := Reader.Items[4];
        Result := Stream.Size = Node.BerDataLength;
        if Result then
          Result := CompareMem(Stream.Memory, Node.BerDataAddress, Stream.Size);

        _CnSetLastError(ECN_RSA_OK); // ��������У�飬��ʹУ�鲻ͨ��Ҳ��մ�����
      end;
    end;
  finally
    Stream.Free;
    Reader.Free;
    Data.Free;
    Res.Free;
    SetLength(ResBuf, 0);
    SetLength(BerBuf, 0);
  end;
end;

function CnRSASignBytes(InData: TBytes; PrivateKey: TCnRSAPrivateKey;
  SignType: TCnRSASignDigestType): TBytes;
var
  InStream, OutStream: TMemoryStream;
begin
  Result := nil;
  InStream := nil;
  OutStream := nil;

  try
    InStream := TMemoryStream.Create;
    BytesToStream(InData, InStream);

    OutStream := TMemoryStream.Create;
    if CnRSASignStream(InStream, OutStream, PrivateKey, SignType) then
      Result := StreamToBytes(OutStream);
  finally
    OutStream.Free;
    InStream.Free;
  end;
end;

function CnRSAVerifyBytes(InData: TBytes; InSignBytes: TBytes;
  PublicKey: TCnRSAPublicKey; SignType: TCnRSASignDigestType): Boolean;
var
  InStream, SignStream: TMemoryStream;
begin
  InStream := nil;
  SignStream := nil;

  try
    InStream := TMemoryStream.Create;
    BytesToStream(InData, InStream);

    SignStream := TMemoryStream.Create;
    BytesToStream(InSignBytes, SignStream);
    Result := CnRSAVerifyStream(InStream, SignStream, PublicKey, SignType);
  finally
    SignStream.Free;
    InStream.Free;
  end;
end;

function CnRSASignFile(const InFileName, OutSignFileName: string;
  PrivateKey: TCnRSAPrivateKey; SignType: TCnRSASignDigestType): Boolean;
var
  Stream, BerStream, EnStream: TMemoryStream;
  Data, Res: TCnBigNumber;
  ResBuf: TBytes;
  Writer: TCnBerWriter;
  Root, Node: TCnBerWriteNode;
begin
  Result := False;
  Stream := nil;
  EnStream := nil;
  BerStream := nil;
  Writer := nil;
  Data := nil;
  Res := nil;

  try
    Stream := TMemoryStream.Create;
    EnStream := TMemoryStream.Create;

    if SignType = rsdtNone then
    begin
      // ������ժҪ��ֱ�������ݶ���
      Stream.LoadFromFile(InFileName);
      if not AddPKCS1Padding(CN_PKCS1_BLOCK_TYPE_PRIVATE_FF, PrivateKey.GetBytesCount,
        Stream.Memory, Stream.Size, EnStream) then
      begin
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
        Exit;
      end;
    end
    else // ������ժҪ
    begin
      if not CalcDigestFile(InFileName, SignType, Stream) then // �����ļ����Ӵ�ֵ
        Exit;

      BerStream := TMemoryStream.Create;
      Writer := TCnBerWriter.Create;

      // Ȼ�󰴸�ʽ���� BER ����
      Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);
      AddDigestTypeOIDNodeToWriter(Writer, SignType, Node);
      Writer.AddNullNode(Node);
      Writer.AddBasicNode(CN_BER_TAG_OCTET_STRING, Stream.Memory, Stream.Size, Root);
      Writer.SaveToStream(BerStream);

      // �ٰ� BER ���������� PKCS1 ������
      if not AddPKCS1Padding(CN_PKCS1_BLOCK_TYPE_PRIVATE_FF, PrivateKey.GetBytesCount,
        BerStream.Memory, BerStream.Size, EnStream) then
      begin
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
        Exit;
      end;
    end;

    // ˽Կ��������
    Data := TCnBigNumber.FromBinary(PAnsiChar(EnStream.Memory), EnStream.Size);
    Res := TCnBigNumber.Create;

    if RSACrypt(Data, PrivateKey.PrivKeyProduct, PrivateKey.PrivKeyExponent, Res) then
    begin
      // ע�� Res ���ܴ���ǰ�� 0�����Դ˴������� PrivateKey.GetBytesCount Ϊ׼������ȷ����©ǰ�� 0
      SetLength(ResBuf, PrivateKey.GetBytesCount);
      Res.ToBinary(@ResBuf[0], PrivateKey.GetBytesCount);

      // ������˽Կ���ܺ���������ļ�
      Stream.Clear;
      Stream.Write(ResBuf[0], PrivateKey.GetBytesCount);
      Stream.SaveToFile(OutSignFileName);

      Result := True;
      _CnSetLastError(ECN_RSA_OK);
    end;
  finally
    Stream.Free;
    EnStream.Free;
    BerStream.Free;
    Data.Free;
    Res.Free;
    Writer.Free;
    SetLength(ResBuf, 0);
  end;
end;

function CnRSAVerifyFile(const InFileName, InSignFileName: string;
  PublicKey: TCnRSAPublicKey; SignType: TCnRSASignDigestType): Boolean;
var
  Stream, Sign: TMemoryStream;
  Data, Res: TCnBigNumber;
  ResBuf, BerBuf: TBytes;
  BerLen: Integer;
  Reader: TCnBerReader;
  Node: TCnBerReadNode;
begin
  Result := False;
  Stream := nil;
  Reader := nil;
  Sign := nil;
  Data := nil;
  Res := nil;

  try
    Stream := TMemoryStream.Create;
    Sign := TMemoryStream.Create;

    // ��������ǩ���ļ��ȹ�Կ����
    Sign.LoadFromFile(InSignFileName);
    Data := TCnBigNumber.FromBinary(PAnsiChar(Sign.Memory), Sign.Size);
    Res := TCnBigNumber.Create;

    if RSACrypt(Data, PublicKey.PubKeyProduct, PublicKey.PubKeyExponent, Res) then
    begin
      SetLength(ResBuf, PublicKey.GetBytesCount);
      Res.ToBinary(@ResBuf[0], PublicKey.GetBytesCount);

      // �� Res �н�� PKCS1 ��������ݷ��� BerBuf ��
      SetLength(BerBuf, Length(ResBuf));
      if not RemovePKCS1Padding(@ResBuf[0], Length(ResBuf), @BerBuf[0], BerLen) then
      begin
        _CnSetLastError(ECN_RSA_PADDING_ERROR);
        Exit;
      end;

      if SignType = rsdtNone then
      begin
        Stream.LoadFromFile(InFileName); // ��ժҪʱ��ֱ�ӱȶԽ���������ԭʼ�ļ�
        Result := Stream.Size = BerLen;
        if Result then
          Result := CompareMem(Stream.Memory, @BerBuf[0], Stream.Size);

        _CnSetLastError(ECN_RSA_OK); // ��������У�飬��ʹУ�鲻ͨ��Ҳ��մ�����
      end
      else
      begin
        if (BerLen <= 0) or (BerLen >= Length(ResBuf)) then
        begin
          _CnSetLastError(ECN_RSA_BER_ERROR);
          Exit;
        end;

        // �⿪ Ber ������ı���������㷨����ʹ�� SignType ԭʼֵ
        Reader := TCnBerReader.Create(@BerBuf[0], BerLen);
        Reader.ParseToTree;
        if Reader.TotalCount < 5 then
        begin
          _CnSetLastError(ECN_RSA_BER_ERROR);
          Exit;
        end;

        Node := Reader.Items[2];
        SignType := GetDigestSignTypeFromBerOID(Node.BerDataAddress, Node.BerDataLength);
        if SignType = rsdtNone then
        begin
          _CnSetLastError(ECN_RSA_BER_ERROR);
          Exit;
        end;

        if not CalcDigestFile(InFileName, SignType, Stream) then // �����ļ����Ӵ�ֵ
          Exit;

        // �� Ber ������Ӵ�ֵ�Ƚ�
        Node := Reader.Items[4];
        Result := Stream.Size = Node.BerDataLength;
        if Result then
          Result := CompareMem(Stream.Memory, Node.BerDataAddress, Stream.Size);

        _CnSetLastError(ECN_RSA_OK); // ��������У�飬��ʹУ�鲻ͨ��Ҳ��մ�����
      end;
    end;
  finally
    Stream.Free;
    Reader.Free;
    Sign.Free;
    Data.Free;
    Res.Free;
    SetLength(ResBuf, 0);
    SetLength(BerBuf, 0);
  end;
end;

// ���� Diffie-Hellman ��ԿЭ���㷨���������������Сԭ�����漰�����طֽ���˽���
function CnDiffieHellmanGeneratePrimeRootByBitsCount(BitsCount: Integer;
  Prime, MinRoot: TCnBigNumber): Boolean;
var
  I: Integer;
  Q, R, T: TCnBigNumber;
begin
  Result := False;
  if BitsCount <= 16 then
  begin
    _CnSetLastError(ECN_RSA_INVALID_BITS);
    Exit;
  end;

  Q := nil;
  T := nil;
  R := nil;

  try
    Q := TCnBigNumber.Create;
    repeat
      if not BigNumberGeneratePrimeByBitsCount(Prime, BitsCount) then
      begin
        _CnSetLastError(ECN_RSA_BIGNUMBER_ERROR);
        Exit;
      end;

      if BigNumberCopy(Q, Prime) = nil then
        Exit;

      Q.SubWord(1);
      Q.ShiftRightOne;

      if BigNumberIsProbablyPrime(Q) then // P = 2Q + 1��P �� Q �����������������������ж�
        Break;
    until False;

    T := TCnBigNumber.Create;
    R := TCnBigNumber.Create;

    for I := 2 to MaxInt do
    begin
      T.SetWord(I);
      if not BigNumberDirectMulMod(R, T, T, Prime) then // G^2 mod P <> 1
        Exit;

      if not R.IsOne then
      begin
        if not BigNumberPowerMod(R, T, Q, Prime) then   // G^Q mod P <> 1
          Exit;

        if not R.IsOne then
        begin
          Result := BigNumberCopy(MinRoot, T) <> nil;
          Exit;
        end;
      end;
    end;
  finally
    R.Free;
    T.Free;
    Q.Free;
  end;
end;

// ��������ѡ�������� PrivateKey ���� Diffie-Hellman ��ԿЭ�̵������Կ
function CnDiffieHellmanGenerateOutKey(Prime, Root, SelfPrivateKey: TCnBigNumber;
  const OutPublicKey: TCnBigNumber): Boolean;
begin
  // OutPublicKey = (Root ^ SelfPrivateKey) mod Prime
  Result := BigNumberMontgomeryPowerMod(OutPublicKey, Root, SelfPrivateKey, Prime);
end;

// ���ݶԷ����͵� Diffie-Hellman ��ԿЭ�̵������Կ�������ɹ��ϵ���Կ
function CnDiffieHellmanComputeKey(Prime, SelfPrivateKey, OtherPublicKey: TCnBigNumber;
  const SecretKey: TCnBigNumber): Boolean;
begin
  // SecretKey = (OtherPublicKey ^ SelfPrivateKey) mod Prime
  Result := BigNumberMontgomeryPowerMod(SecretKey, OtherPublicKey, SelfPrivateKey, Prime);
end;

// ���ɻ�����ɢ�����ı�ɫ���Ӵպ������������������Сԭ����ʵ�ʵ�ͬ�� Diffie-Hellman
function CnChameleonHashGeneratePrimeRootByBitsCount(BitsCount: Integer;
  Prime, MinRoot: TCnBigNumber): Boolean;
begin
  Result := CnDiffieHellmanGeneratePrimeRootByBitsCount(BitsCount, Prime, MinRoot);
end;

// ������ͨ��ɢ�����ı�ɫ���Ӵպ���������һ���ֵ��һ SecretKey������ָ����Ϣ���Ӵ�
function CnChameleonHashCalcDigest(InData: TCnBigNumber; InRandom: TCnBigNumber;
  InSecretKey: TCnBigNumber; OutHash: TCnBigNumber; Prime, Root: TCnBigNumber): Boolean;
var
  T: TCnBigNumber;
begin
  T := nil;

  // Hash(M, R) = g^(M + R * Sk) mod P
  try
    T := TCnBigNumber.Create;
    BigNumberCopy(T, InSecretKey);
    BigNumberDirectMulMod(T, InRandom, T, Prime);

    BigNumberAddMod(T, InData, T, Prime);
    Result := BigNumberMontgomeryPowerMod(OutHash, Root, T, Prime);
  finally
    T.Free;
  end;
end;

// ������ͨ��ɢ�����ı�ɫ���Ӵպ��������� SecretKey ���¾���Ϣ�������ܹ�������ͬ�Ӵյ������ֵ
function CnChameleonHashFindRandom(InOldData, InNewData: TCnBigNumber;
  InOldRandom, InSecretKey: TCnBigNumber; OutNewRandom: TCnBigNumber;
  Prime, Root: TCnBigNumber): Boolean;
var
  M, SK: TCnBigNumber;
begin
  M := nil;
  SK := nil;

  // R2 := ((M1 - M2)/SK + R1) mod P
  try
    M := TCnBigNumber.Create;
    BigNumberSubMod(M, InOldData, InNewData, Prime);

    SK := TCnBigNumber.Create;
    BigNumberModularInverse(SK, InSecretKey, Prime);

    BigNumberDirectMulMod(M, M, SK, Prime);
    Result := BigNumberAddMod(OutNewRandom, M, InOldRandom, Prime);
  finally
    SK.Free;
    M.Free;
  end;
end;

function GetDigestSignTypeFromBerOID(OID: Pointer; OidLen: Integer): TCnRSASignDigestType;
begin
  Result := rsdtNone;
  if (OidLen = SizeOf(OID_SIGN_MD5)) and CompareMem(OID, @OID_SIGN_MD5[0], OidLen) then
    Result := rsdtMD5
  else if (OidLen = SizeOf(OID_SIGN_SHA1)) and CompareMem(OID, @OID_SIGN_SHA1[0], OidLen) then
    Result := rsdtSHA1
  else if (OidLen = SizeOf(OID_SIGN_SHA256)) and CompareMem(OID, @OID_SIGN_SHA256[0], OidLen) then
    Result := rsdtSHA256;
end;

function GetRSADigestNameFromSignDigestType(Digest: TCnRSASignDigestType): string;
begin
  case Digest of
    rsdtNone: Result := '<None>';
    rsdtMD5: Result := 'MD5';
    rsdtSHA1: Result := 'SHA1';
    rsdtSHA256: Result := 'SHA256';
  else
    Result := '<Unknown>';
  end;
end;

// Ĭ�ϵ�ʹ�� SHA1 ���������ɺ���
function Pkcs1Sha1MGF(Seed: Pointer; SeedLen: Integer; OutMask: Pointer;
  MaskLen: Integer): Boolean;
var
  I, OutLen, MdLen: Integer;
  Cnt: array[0..3] of Byte;
  Ctx: TCnSHA1Context;
  Dig: TCnSHA1Digest;
begin
  Result := False;
  OutLen := 0;
  MdLen := SizeOf(TCnSHA1Digest);
  if (Seed = nil) or (SeedLen <= 0) then
    Exit;

  if (OutMask = nil) or (MaskLen <= 0) then
    Exit;

  I := 0;
  while OutLen < MaskLen do
  begin
    Cnt[0] := (I shr 24) and $FF;
    Cnt[1] := (I shr 16) and $FF;
    Cnt[2] := (I shr 8) and $FF;
    Cnt[3] := I and $FF;

    SHA1Init(Ctx);
    SHA1Update(Ctx, PAnsiChar(Seed), SeedLen);
    SHA1Update(Ctx, @Cnt[0], SizeOf(Cnt));

    if OutLen + MdLen <= MaskLen then
    begin
      SHA1Final(Ctx, PCnSHA1Digest(TCnNativeInt(OutMask) + OutLen)^);
      OutLen := OutLen + MdLen;
    end
    else
    begin
      SHA1Final(Ctx, Dig);
      Move(Dig[0], PCnSHA1Digest(TCnNativeInt(OutMask) + OutLen)^, MaskLen - OutLen);
      OutLen := MaskLen;
    end;

    Inc(I);
  end;
  Result := True;
end;

function AddOaepSha1MgfPadding(ToBuf: PByte; ToLen: Integer; PlainData: PByte;
  DataByteLen: Integer; DigestParam: PByte = nil; ParamLen: Integer = 0): Boolean;
var
  EmLen, MdLen, I: Integer;
  SeedMask: TCnSHA1Digest;
  DB, Seed: PByteArray;
  DBMask: TBytes;
begin
  Result := False;
  EmLen:= ToLen - 1;

  MdLen := SizeOf(TCnSHA1Digest);

  if (DataByteLen > EmLen - 2 * MdLen - 1) or (EmLen < 2 * MdLen + 1) then
  begin
    _CnSetLastError(ECN_RSA_PADDING_ERROR);
    Exit;
  end;

  ToBuf^ := 0;
  Seed := PByteArray(TCnNativeInt(ToBuf) + 1);
  DB := PByteArray(TCnNativeInt(ToBuf) + MdLen + 1);

  // 00 | 20 λ Seed | DB
  // ���� DB := ParamHash || PS || 0x01 || Data�������� EmLen - MdLen
  // ����Ҫ XOR һ�γ�Ϊ MaskDB
  SeedMask := SHA1Buffer(DigestParam, ParamLen);
  Move(SeedMask[0], DB^, MdLen);

  // To �� DB ��ǰ 20 �ֽ������ţ����浽β�������� 0
  FillChar(PByte(TCnNativeInt(DB) + MdLen)^, EmLen - DataByteLen - 2 * MdLen - 1, 0);
  DB^[EmLen - DataByteLen - MdLen - 1] := 1;

  // ���ĸ����
  Move(PlainData^, PByte(TCnNativeInt(DB) + EmLen - DataByteLen - MdLen)^, DataByteLen);

  // To[1] ��ʼ�� 20 ���ֽ� Rand һ��
  if not CnRandomFillBytes(PAnsiChar(Seed), MdLen) then
  begin
    _CnSetLastError(ECN_RSA_PADDING_ERROR);
    Exit;
  end;

  SetLength(DBMask, EmLen - MdLen);

  // ��� Seed ��� MGF ���ݣ�׼���� DB �� XOR
  if not Pkcs1Sha1MGF(Seed, MdLen, @DBMask[0], EmLen - MdLen) then
  begin
    _CnSetLastError(ECN_RSA_PADDING_ERROR);
    Exit;
  end;

  for I := 0 to EmLen - MdLen - 1 do
    DB^[I] := DB^[I] xor DBMask[I];        // �õ� Masked DB

  // XOR ���� Masked DB ����� MGF ���ݣ�׼������� Seed �� XOR
  if not Pkcs1Sha1MGF(DB, EmLen - MdLen, @SeedMask[0], MdLen) then
  begin
    _CnSetLastError(ECN_RSA_PADDING_ERROR);
    Exit;
  end;

  for I := 0 to MdLen - 1 do
    Seed^[I] := Seed^[I] xor SeedMask[I];  // �õ� Masked Seed

  SetLength(DBMask, 0);
  Result := True;
  // ��������Ϣ = 00 || maskedSeed || maskedDB
end;

function RemoveOaepSha1MgfPadding(ToBuf: PByte; out OutLen: Integer; EnData: PByte;
  DataByteLen: Integer; DigestParam: PByte = nil; ParamLen: Integer = 0): Boolean;
var
  I, MdLen, DBLen, MStart: Integer;
  MaskedDB, MaskedSeed: PByteArray;
  Seed, ParamHash: TCnSHA1Digest;
  DB: TBytes;
begin
  Result := False;
  if (EnData = nil) or (ToBuf = nil) then
  begin
    _CnSetLastError(ECN_RSA_PADDING_ERROR);
    Exit;
  end;

  if EnData^ <> 0 then  // ���ֽڱ����� 0
  begin
    _CnSetLastError(ECN_RSA_PADDING_ERROR);
    Exit;
  end;

  MdLen := SizeOf(TCnSHA1Digest);
  DBLen := DataByteLen - MdLen - 1;
  if DBLen <= 0 then
  begin
    _CnSetLastError(ECN_RSA_PADDING_ERROR);
    Exit;
  end;

  // �ҳ������е� �� MdLen �� MaskedSeed �Լ����泤 DBLen �� MaskedDB
  MaskedSeed := PByteArray(TCnNativeInt(EnData) + 1);
  MaskedDB := PByteArray(TCnNativeInt(EnData) + MdLen + 1);

  ParamHash := SHA1Buffer(DigestParam, ParamLen);

  // �� MaskedDB �������
  if not Pkcs1Sha1MGF(@MaskedDB[0], DBLen, @Seed[0], MdLen) then
  begin
    _CnSetLastError(ECN_RSA_PADDING_ERROR);
    Exit;
  end;

  for I := 0 to MdLen - 1 do
    Seed[I] := Seed[I] xor MaskedSeed^[I];  // �õ� Seed

  SetLength(DB, DBLen);
  try
    if not Pkcs1Sha1MGF(@Seed[0], MdLen, @DB[0], DBLen) then
    begin
      _CnSetLastError(ECN_RSA_PADDING_ERROR);
      Exit;
    end;

    for I := 0 to DBLen - 1 do
      DB[I] := DB[I] xor MaskedDB^[I];  // �õ� DB

    // ���� DB ��ǰ MdLen �ֽ�Ӧ�õ��� ParamHash���Ƚ��ж�֮
    if not CompareMem(@DB[0], @ParamHash[0], MdLen) then
    begin
      _CnSetLastError(ECN_RSA_PADDING_ERROR);
      Exit;
    end;

    // ͨ����� DB[MdLen] ��ʼ������ 0 �� 1���ѵ� 1 ��1 ��ĵ�β�͵ľ�����Ϣԭ��
    MStart := -1;
    for I := MdLen to DBLen - 1 do
    begin
      if DB[I] <> 0 then
      begin
        if DB[I] <> 1 then
        begin
          _CnSetLastError(ECN_RSA_PADDING_ERROR);
          Exit;
        end
        else // 0 ��ĵ�һ�� 1
        begin
          // ��¼��ʱ�� I + 1
          MStart := I + 1;
          Break;
        end;
      end; // 0 ������
    end;

    // DB[MStart] �� DB[DBLen - 1] ����������
    if (MStart > 0) and (MStart < DBLen) then
    begin
//      û���ж�Ŀ�������Ƿ񹻲������ɣ���Ϊ OutLen û���� ToBuf ��ʵ�ʳ�����
//      if DBLen - MStart > OutLen then
//      begin
//        _CnSetLastError(ECN_RSA_PADDING_ERROR);
//        Exit;
//      end;

      Move(DB[MStart], ToBuf^, DBLen - MStart);
      OutLen := DBLen - MStart; // �����������ݳ���
      Result := True;
    end;
  finally
    SetLength(DB, 0);
  end;
end;

end.
