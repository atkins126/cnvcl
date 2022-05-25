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

unit CnBigNumber;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ������㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע���󲿷ִ� Openssl �� C ������ֲ�����������ز�֧�ֶ��߳�
*           Word ϵ�в�������ָ������ DWORD �������㣬�� Words ϵ�в�������ָ
*           �����м��������̡�
*           ======== !!! D5/D6/CB5/CB6 �¿������ϱ����� Bug �޷��޸� !!! =======
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2022.04.26 V2.4
*               �޸� LongWord �� Integer ��ַת����֧�� MacOS64
*           2021.12.08 V2.3
*               ʵ���� Extended ��չ���ȸ�������˳�������һ���������������� AKS
*           2021.12.04 V2.2
*               ʵ���� Extended ��չ���ȸ���������ת��
*           2021.11.29 V2.2
*               ʵ��һ��ϡ��Ĵ����б���
*           2021.11.23 V2.1
*               ʵ������������Ĵ���
*           2021.09.20 V2.0
*               ʵ�ִ�����λ����
*           2021.09.05 V1.9
*               ʵ����ȫ�ݵ��ж�
*           2021.04.02 V1.8
*               POSIX 64 �� LongWord �� 64 λ��Ǩ��
*           2020.07.04 V1.7
*               �����������ض��󣬼�����߳̿���
*           2020.06.20 V1.6
*               ������ٳ˷�������ʮ����λ������
*           2020.01.16 V1.5
*               �Ż��˷��� MulMod ���ٶȣ�ȥ��������
*           2019.04.16 V1.4
*               ֧�� Win32/Win64/MacOS32
*           2017.04.04 V1.3
*               ����������������ص� Bug������չŷ�������ⷨ��������
*           2016.09.26 V1.2
*               �����������㣻�����ظĳ�ȫ�ַ�ʽ�����Ч��
*           2014.11.05 V1.1
*               �����ӽṹ��ʽ��Ϊ����ʽ�����Ӳ��ַ���
*           2014.10.15 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Math, CnNativeDecl {$IFDEF MSWINDOWS}, Windows {$ENDIF},
  Contnrs, CnContainers, CnRandom {$IFDEF UNICODE}, AnsiStrings {$ENDIF};

const
  BN_BITS_UINT_32       = 32;
  BN_BITS_UINT_64       = 64;
  BN_BYTES              = 4;
  BN_BITS2              = 32;     // D �����е�һ��Ԫ����������λ��
  BN_BITS4              = 16;
  BN_TBIT               = $80000000;
  BN_MASK2S             = $7FFFFFFF;
  BN_MASK2              = $FFFFFFFF;
  BN_MASK2l             = $FFFF;
  BN_MASK2h             = $FFFF0000;
  BN_MASK2h1            = $FFFF8000;
  BN_MASK3S             = $7FFFFFFFFFFFFFFF;
  BN_MASK3U             = $FFFFFFFFFFFFFFFF;

  BN_MILLER_RABIN_DEF_COUNT = 50; // Miller-Rabin �㷨��Ĭ�ϲ��Դ���

type
  TLongWordArray = array [0..MaxInt div SizeOf(Integer) - 1] of TCnLongWord32;
  PLongWordArray = ^TLongWordArray;

{$IFDEF SUPPORT_UINT64}
  TUInt64Array = array [0..MaxInt div SizeOf(UInt64) - 1] of UInt64;
  PUInt64Array = ^TUInt64Array;
{$ENDIF}

  {* ��������һ�������Ķ���}
  TCnBigNumber = class(TObject)
  private
{$IFDEF DEBUG}
    FIsFromPool: Boolean;
{$ENDIF}
    function GetDecString: string;
    function GetHexString: string;
    function GetDebugDump: string;
  public
    D: PCnLongWord32;       // һ�� array[0..Top-1] of LongWord ���飬Խ����Խ�����λ
    Top: Integer;       // Top ��ʾ�������ޣ�Ҳ���� Top ����Ч LongWord��D[Top] ֵΪ 0��D[Top - 1] �����λ��Ч�����ڵ� LongWord
    DMax: Integer;      // D �����ѷ���Ĵ洢���ޣ���λ�� LongWord �������ڻ���� Top������������
    Neg: Integer;       // 1 Ϊ����0 Ϊ��

    constructor Create; virtual;
    destructor Destroy; override;

    procedure Init;
    {* ��ʼ��Ϊȫ 0���������� D �ڴ�}

    procedure Clear;
    {* ���������ݿռ��� 0�������ͷ� D �ڴ�}

    function IsZero: Boolean;
    {* ���ش����Ƿ�Ϊ 0}

    function SetZero: Boolean;
    {* ����������Ϊ 0�������Ƿ����óɹ�}

    function IsOne: Boolean;
    {* ���ش����Ƿ�Ϊ 1}

    function IsNegOne: Boolean;
    {* ���ش����Ƿ�Ϊ -1}

    function SetOne: Boolean;
    {* ����������Ϊ 1�������Ƿ����óɹ�}

    function IsOdd: Boolean;
    {* ���ش����Ƿ�Ϊ����}

    function GetBitsCount: Integer;
    {* ���ش����ж��ٸ���Ч Bits}

    function GetBytesCount: Integer;
    {* ���ش����ж��ٸ���Ч Bytes}

    function GetWordCount: Integer;
    {* ���ش����ж��ٸ���Ч LongWord}

    function GetTenPrecision: Integer;
    {* ���ش����ж��ٸ�ʮ����λ}

    function GetWord: TCnLongWord32;
    {* ȡ DWORD ����ֵ}

    function SetWord(W: TCnLongWord32): Boolean;
    {* �������� DWORD ����ֵ}

    function GetInteger: Integer;
    {* ȡ Integer ����ֵ}

    function SetInteger(W: Integer): Boolean;
    {* �������� Integer ����ֵ}

    function GetInt64: Int64;
    {* ȡ Int64 ����ֵ}

    function SetInt64(W: Int64): Boolean;
    {* �������� Int64 ����ֵ}

{$IFDEF SUPPORT_UINT64}

    function GetUInt64: UInt64;
    {* ȡ UInt64 ����ֵ}

    function SetUInt64(W: UInt64): Boolean;
    {* �������� UInt64 ����ֵ}

{$ENDIF}

    function IsWord(W: TCnLongWord32): Boolean;
    {* �����Ƿ����ָ�� DWORD}

    function AddWord(W: TCnLongWord32): Boolean;
    {* ��������һ�� DWORD������Է������У���������Ƿ�ɹ�}

    function SubWord(W: TCnLongWord32): Boolean;
    {* ������ȥһ�� DWORD������Է������У���������Ƿ�ɹ�}

    function MulWord(W: TCnLongWord32): Boolean;
    {* ��������һ�� DWORD������Է������У���������Ƿ�ɹ�}

    function ModWord(W: TCnLongWord32): TCnLongWord32;
    {* ������һ�� DWORD ���࣬��������}

    function DivWord(W: TCnLongWord32): TCnLongWord32;
    {* ��������һ�� DWORD�������·��������У���������}

    function PowerWord(W: TCnLongWord32): Boolean;
    {* �����˷���������·��������У����س˷��Ƿ�ɹ�}

    procedure SetNegative(Negative: Boolean);
    {* ���ô����Ƿ�ֵ}

    function IsNegative: Boolean;
    {* ���ش����Ƿ�ֵ}

    procedure Negate;
    {* ���������ŷ���}

    procedure ShiftLeftOne;
    {* ���� 1 λ}

    procedure ShiftRightOne;
    {* ���� 1 λ}

    procedure ShiftLeft(N: Integer);
    {* ���� N λ}

    procedure ShiftRight(N: Integer);
    {* ���� N λ}

    function ClearBit(N: Integer): Boolean;
    {* �������ĵ� N �� Bit �� 0�����سɹ����N �����λ 0 �����λ GetBitsCount - 1}

    function SetBit(N: Integer): Boolean;
    {* �������ĵ� N �� Bit �� 1�����سɹ����N �����λ 0 �����λ GetBitsCount - 1}

    function IsBitSet(N: Integer): Boolean;
    {* ���ش����ĵ� N �� Bit �Ƿ�Ϊ 1��N �����λ 0 �����λ GetBitsCount - 1}

    function WordExpand(Words: Integer): TCnBigNumber;
    {* ��������չ��֧�� Words �� DWORD���ɹ�������չ�Ĵ��������� Self��ʧ�ܷ��� nil}

    function ToBinary(const Buf: PAnsiChar): Integer;
    {* ������ת���ɶ��������ݷ��� Buf �У�Buf �ĳ��ȱ�����ڵ����� BytesCount��
       ���� Buf д��ĳ���}

    function SetBinary(Buf: PAnsiChar; Len: Integer): Boolean;
    {* ����һ�������ƿ������ֵ���ڲ����ø���}

    class function FromBinary(Buf: PAnsiChar; Len: Integer): TCnBigNumber;
    {* ����һ�������ƿ����һ���µĴ�������������Ϊ����}

{$IFDEF TBYTES_DEFINED}

    class function FromBytes(Buf: TBytes): TCnBigNumber;
    {* ����һ���ֽ��������һ���µĴ�������������Ϊ����}

    function ToBytes: TBytes;
    {* ���������ݻ����ֽ�����}

{$ENDIF}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ת���ַ���}

    function ToHex(FixedLen: Integer = 0): string;
    {* ������ת��ʮ�������ַ���}

    function SetHex(const Buf: AnsiString): Boolean;
    {* ����һ��ʮ�������ַ���������ֵ}

    class function FromHex(const Buf: AnsiString): TCnBigNumber;
    {* ����һ��ʮ�������ַ�������һ���µĴ�������}

    function ToDec: string;
    {* ������ת��ʮ�����ַ���}

    function SetDec(const Buf: AnsiString): Boolean;
    {* ����һ��ʮ�����ַ���������ֵ}

    class function FromDec(const Buf: AnsiString): TCnBigNumber;
    {* ����һ��ʮ�����ַ����������µĴ�������}

    property DecString: string read GetDecString;
    property HexString: string read GetHexString;

    property DebugDump: string read GetDebugDump;
  end;
  PCnBigNumber = ^TCnBigNumber;

  TCnBigNumberList = class(TObjectList)
  {* ���ɴ����Ķ����б�ͬʱӵ�д���������}
  private

  protected
    function GetItem(Index: Integer): TCnBigNumber;
    procedure SetItem(Index: Integer; ABigNumber: TCnBigNumber);
  public
    constructor Create; reintroduce;

    function Add: TCnBigNumber; overload;
    {* ����һ���������󣬷��ظö���ע����Ӻ�����Ҳ�����ֶ��ͷ�}
    function Add(ABigNumber: TCnBigNumber): Integer; overload;
    {* ����ⲿ�Ĵ�������ע����Ӻ�����Ҳ�����ֶ��ͷ�}
    function Remove(ABigNumber: TCnBigNumber): Integer;
    function IndexOfValue(ABigNumber: TCnBigNumber): Integer;
    procedure Insert(Index: Integer; ABigNumber: TCnBigNumber);
    procedure RemoveDuplicated;
    {* ȥ�أ�Ҳ����ɾ�����ͷ��ظ��Ĵ���ֵ����ֻ��һ��}
    property Items[Index: Integer]: TCnBigNumber read GetItem write SetItem; default;
  end;

  TCnBigNumberPool = class(TCnMathObjectPool)
  {* ������ʵ���࣬����ʹ�õ������ĵط����д���������}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnBigNumber; reintroduce;
    procedure Recycle(Num: TCnBigNumber); reintroduce;
  end;

  TCnExponentBigNumberPair = class(TObject)
  {* ָ�������������࣬����ϡ���б�}
  private
    FExponent: Integer;
    FValue: TCnBigNumber;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ��ָ�������ת���ַ���}

    property Exponent: Integer read FExponent write FExponent;
    property Value: TCnBigNumber read FValue;
  end;

  TCnSparseBigNumberList = class(TObjectList)
  {* ���ɴ�����ָ����ϡ������б�ͬʱӵ�� TCnExponentBigNumberPair �����ǣ�
    �ڲ��� Exponent ��С��������}
  private
    function GetItem(Index: Integer): TCnExponentBigNumberPair;
    procedure SetItem(Index: Integer; const Value: TCnExponentBigNumberPair);
    function BinarySearchExponent(AExponent: Integer; var OutIndex: Integer): Boolean;
    {* ���ַ����� AExponent ��λ�ã��ҵ����� True��OutIndex ���ö�Ӧ�б�����λ��
      ��δ�ҵ���OutIndex �򷵻ز���λ�ù�ֱ�� Insert��MaxInt ʱ�� Add}
    function InsertByOutIndex(OutIndex: Integer): Integer;
    {* ���ݶ��ַ�����ʧ�ܳ��Ϸ��ص� OutIndex ʵʩ���룬���ز�������ʵ Index}
    function GetSafeValue(Exponent: Integer): TCnBigNumber;
    function GetReadonlyValue(Exponent: Integer): TCnBigNumber;
    procedure SetSafeValue(Exponent: Integer; const Value: TCnBigNumber);
  public
    constructor Create; reintroduce;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������Ԫ���е�ָ�������ת�ɶ����ַ���}

    function Top: TCnExponentBigNumberPair;
    {* �����ߴζ���}
    function Bottom: TCnExponentBigNumberPair;
    {* �����ʹζ���}

    // ��Ҫȡ������ɾ���ġ�ѹ�Ȳ���
    function AddPair(AExponent: Integer; Num: TCnBigNumber): TCnExponentBigNumberPair;
    {* ���һ�� Pair���ڲ����ƴ���}
    procedure AssignTo(Dest: TCnSparseBigNumberList);
    {* ���Ƹ�����һ��}
    procedure SetValues(LowToHighList: array of Int64);
    {* �ӵ͵�������ֵ}
    procedure Compact;
    {* ѹ����Ҳ����ɾ������ 0 ϵ����}
    procedure Negate;
    {* ����ϵ����}
    property SafeValue[Exponent: Integer]: TCnBigNumber read GetSafeValue write SetSafeValue;
    {* ��ȫ�ĸ��ݲ��� Exponent ��ȡ�����ķ�������ʱ���ڲ��鲻����������½�ֵ�����أ�
      дʱ���ڲ��鲻�������½�����ָ��λ�ú� Value ������� BigNumber ����}
    property ReadonlyValue[Exponent: Integer]: TCnBigNumber read GetReadonlyValue;
    {* ֻ���ĸ��ݲ��� Exponent ��ȡ�����ķ�������ʱ���ڲ��鲻�����᷵��һ�̶�����ֵ TCnBigNumber ���������޸���ֵ}
    property Items[Index: Integer]: TCnExponentBigNumberPair read GetItem write SetItem; default;
    {* ���ص� Items ����}
  end;

function BigNumberNew: TCnBigNumber;
{* ����һ����̬����Ĵ������󣬵�ͬ�� TCnBigNumber.Create}

procedure BigNumberFree(const Num: TCnBigNumber);
{* ����Ҫ�ͷ�һ���� BigNumerNew ���������Ĵ������󣬲�����Ҫ�ͷ��� D ����
   ��ͬ��ֱ�ӵ��� Free}

procedure BigNumberInit(const Num: TCnBigNumber);
{* ��ʼ��һ����������ȫΪ 0���������� D �ڴ�}

procedure BigNumberClear(const Num: TCnBigNumber);
{* ���һ���������󣬲��������ݿռ��� 0�������ͷ� D �ڴ�}

function BigNumberIsZero(const Num: TCnBigNumber): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* ����һ������������Ĵ����Ƿ�Ϊ 0}

function BigNumberSetZero(const Num: TCnBigNumber): Boolean;
{* ��һ������������Ĵ�������Ϊ 0}

function BigNumberIsOne(const Num: TCnBigNumber): Boolean;
{* ����һ������������Ĵ����Ƿ�Ϊ 1}

function BigNumberIsNegOne(const Num: TCnBigNumber): Boolean;
{* ����һ������������Ĵ����Ƿ�Ϊ -1}

function BigNumberSetOne(const Num: TCnBigNumber): Boolean;
{* ��һ������������Ĵ�������Ϊ 1}

function BigNumberIsOdd(const Num: TCnBigNumber): Boolean;
{* ����һ������������Ĵ����Ƿ�Ϊ����}

function BigNumberGetBitsCount(const Num: TCnBigNumber): Integer;
{* ����һ������������Ĵ����ж��ٸ���Ч Bits}

function BigNumberGetBytesCount(const Num: TCnBigNumber): Integer;
{* ����һ������������Ĵ����ж��ٸ���Ч Bytes}

function BigNumberGetWordsCount(const Num: TCnBigNumber): Integer;
{* ����һ������������Ĵ����ж��ٸ���Ч LongWord}

function BigNumberGetTenPrecision(const Num: TCnBigNumber): Integer;
{* ����һ������������Ĵ����ж��ٸ���Чʮ����λ��}

function BigNumberGetTenPrecision2(const Num: TCnBigNumber): Integer;
{* ���Է���һ������������Ĵ����ж��ٸ���Чʮ����λ���������� 1 λ���Ͽ�}

function BigNumberGetWord(const Num: TCnBigNumber): TCnLongWord32;
{* ȡһ�������������ֵ��Ҳ���ǵ� 32 λ�޷���ֵ}

function BigNumberSetWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
{* ��һ������������ֵ��Ҳ���ǵ� 32 λ�޷���ֵ}

function BigNumberGetInteger(const Num: TCnBigNumber): Integer;
{* ȡһ�������������ֵ��Ҳ���ǵ� 32 λ�з�����}

function BigNumberSetInteger(const Num: TCnBigNumber; W: Integer): Boolean;
{* ��һ������������ֵ��Ҳ���ǵ� 32 λ�з�����}

function BigNumberGetInt64(const Num: TCnBigNumber): Int64;
{* ȡһ�������������ֵ Int64}

function BigNumberSetInt64(const Num: TCnBigNumber; W: Int64): Boolean;
{* ��һ������������ֵ Int64}

function BigNumberGetUInt64UsingInt64(const Num: TCnBigNumber): TUInt64;
{* ʹ�� Int64 ȡһ�������������ֵ UInt64}

function BigNumberSetUInt64UsingInt64(const Num: TCnBigNumber; W: TUInt64): Boolean;
{* ʹ�� Int64 ��һ���������� UInt64 ��ֵ}

{$IFDEF SUPPORT_UINT64}

function BigNumberGetUInt64(const Num: TCnBigNumber): UInt64;
{* ȡһ�������������ֵ UInt64}

function BigNumberSetUInt64(const Num: TCnBigNumber; W: UInt64): Boolean;
{* ��һ������������ֵ UInt64}

{$ENDIF}

function BigNumberIsWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
{* ĳ�����Ƿ����ָ�� DWORD}

function BigNumberAbsIsWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
{* ĳ��������ֵ�Ƿ����ָ�� DWORD}

function BigNumberAddWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
{* ��������һ�� DWORD������Է� Num �У���������Ƿ�ɹ�}

function BigNumberSubWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
{* ������ȥһ�� DWORD������Է� Num �У���������Ƿ�ɹ�}

function BigNumberMulWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
{* ��������һ�� DWORD������Է� Num �У���������Ƿ�ɹ�}

function BigNumberModWord(const Num: TCnBigNumber; W: TCnLongWord32): TCnLongWord32;
{* ������һ�� DWORD ���࣬��������}

function BigNumberDivWord(const Num: TCnBigNumber; W: TCnLongWord32): TCnLongWord32;
{* ��������һ�� DWORD�������·��� Num �У���������}

procedure BigNumberSetNegative(const Num: TCnBigNumber; Negative: Boolean);
{* ��һ���������������Ƿ�ֵ}

function BigNumberIsNegative(const Num: TCnBigNumber): Boolean;
{* ����һ�����������Ƿ�ֵ}

procedure BigNumberNegate(const Num: TCnBigNumber);
{* ��һ����������������������}

function BigNumberClearBit(const Num: TCnBigNumber; N: Integer): Boolean;
{* ��һ����������ĵ� N �� Bit �� 0�����سɹ����N Ϊ 0 ʱ������������λ��}

function BigNumberKeepLowBits(const Num: TCnBigNumber; Count: Integer): Boolean;
{* ��һ����������ֻ������ 0 �� Count - 1 �� Bit λ����λ���㣬���سɹ����}

function BigNumberSetBit(const Num: TCnBigNumber; N: Integer): Boolean;
{* ��һ����������ĵ� N �� Bit �� 1�����سɹ����N Ϊ 0 ʱ������������λ��}

function BigNumberIsBitSet(const Num: TCnBigNumber; N: Integer): Boolean;
{* ����һ����������ĵ� N �� Bit �Ƿ�Ϊ 1��N Ϊ 0 ʱ������������λ��}

function BigNumberWordExpand(const Num: TCnBigNumber; Words: Integer): TCnBigNumber;
{* ��һ������������չ��֧�� Words �� DWORD���ɹ�������չ�Ĵ��������ַ��ʧ�ܷ��� nil}

function BigNumberToBinary(const Num: TCnBigNumber; Buf: PAnsiChar): Integer;
{* ��һ������ת���ɶ��������ݷ��� Buf �У�Buf �ĳ��ȱ�����ڵ����� BytesCount��
   ���� Buf д��ĳ��ȣ�ע�ⲻ���������š���� Buf Ϊ nil����ֱ�ӷ������賤��}

function BigNumberWriteBinaryToStream(const Num: TCnBigNumber; Stream: TStream;
  FixedLen: Integer = 0): Integer;
{* ��һ�������Ķ����Ʋ���д����������д�����ĳ��ȡ�
  FixedLen ��ʾ�������ݲ��� FixedLen �ֽڳ���ʱ��λ���� 0 �Ա�֤ Stream ������̶� FixedLen �ֽڵĳ���
  �������ȳ��� FixedLen ʱ������ʵ���ֽڳ���д}

function BigNumberFromBinary(Buf: PAnsiChar; Len: Integer): TCnBigNumber;
{* ��һ�������ƿ�ת���ɴ�������ע�ⲻ���������š���������ʱ������ BigNumberFree �ͷ�}

{$IFDEF TBYTES_DEFINED}

function BigNumberFromBytes(Buf: TBytes): TCnBigNumber;
{* ��һ���ֽ���������ת���ɴ�������ע�ⲻ���������š���������ʱ������ BigNumberFree �ͷ�}

function BigNumberToBytes(const Num: TCnBigNumber): TBytes;
{* ��һ������ת���ɶ���������д���ֽ����鲢���أ�ʧ�ܷ��� nil}

{$ENDIF}

function BigNumberSetBinary(Buf: PAnsiChar; Len: Integer;
  const Res: TCnBigNumber): Boolean;
{* ��һ�������ƿ鸳ֵ��ָ����������ע�ⲻ���������ţ��ڲ����ø���}

function BigNumberToString(const Num: TCnBigNumber): string;
{* ��һ����������ת��ʮ�����ַ��������� - ��ʾ}

function BigNumberToHex(const Num: TCnBigNumber; FixedLen: Integer = 0): string;
{* ��һ����������ת��ʮ�������ַ��������� - ��ʾ
  FixedLen ��ʾ�������ݲ��� FixedLen �ֽڳ���ʱ��λ���� 0 �Ա�֤���������̶� FixedLen �ֽڵĳ��ȣ����������ţ�
  �ڲ��������ȳ��� FixedLen ʱ������ʵ�ʳ���д��ע�� FixedLen ����ʮ�������ַ�������}

function BigNumberSetHex(const Buf: AnsiString; const Res: TCnBigNumber): Boolean;
{* ��һ��ʮ�������ַ�����ֵ��ָ���������󣬸��� - ��ʾ���ڲ����ܰ����س�����}

function BigNumberFromHex(const Buf: AnsiString): TCnBigNumber;
{* ��һ��ʮ�������ַ���ת��Ϊ�������󣬸��� - ��ʾ����������ʱ������ BigNumberFree �ͷ�}

function BigNumberToDec(const Num: TCnBigNumber): AnsiString;
{* ��һ����������ת��ʮ�����ַ��������� - ��ʾ}

function BigNumberSetDec(const Buf: AnsiString; const Res: TCnBigNumber): Boolean;
{* ��һ��ʮ�����ַ�����ֵ��ָ���������󣬸��� - ��ʾ���ڲ����ܰ����س�����}

function BigNumberFromDec(const Buf: AnsiString): TCnBigNumber;
{* ��һ��ʮ�����ַ���ת��Ϊ�������󣬸��� - ��ʾ����������ʱ������ BigNumberFree �ͷ�}

function BigNumberSetFloat(F: Extended; const Res: TCnBigNumber): Boolean;
{* �����������ø��������󣬺���С������}

function BigNumberGetFloat(const Num: TCnBigNumber): Extended;
{* ������ת��Ϊ������������ʱ��Ӧ�׳��쳣��Ŀǰ��δ����}

function BigNumberFromFloat(F: Extended): TCnBigNumber;
{* ��������ת��Ϊ�½��Ĵ���������������ʱ������ BigNumberFree �ͷ�}

function BigNumberEqual(const Num1: TCnBigNumber; const Num2: TCnBigNumber): Boolean;
{* �Ƚ��������������Ƿ���ȣ���ȷ��� True�����ȷ��� False}

function BigNumberCompare(const Num1: TCnBigNumber; const Num2: TCnBigNumber): Integer;
{* �����űȽ�������������ǰ�ߴ��ڵ���С�ں��߷ֱ𷵻� 1��0��-1}

function BigNumberCompareInteger(const Num1: TCnBigNumber; const Num2: Integer): Integer;
{* �����űȽ�һ������������һ��������ǰ�ߴ��ڵ���С�ں��߷ֱ𷵻� 1��0��-1}

function BigNumberUnsignedCompare(const Num1: TCnBigNumber; const Num2: TCnBigNumber): Integer;
{* �޷��űȽ�������������ǰ�ߴ��ڵ���С�ں��߷ֱ𷵻� 1��0��-1}

function BigNumberDuplicate(const Num: TCnBigNumber): TCnBigNumber;
{* ����������һ���������󣬷��ش��´���������Ҫ�� BigNumberFree ���ͷ�}

function BigNumberCopy(const Dst: TCnBigNumber; const Src: TCnBigNumber): TCnBigNumber;
{* ����һ���������󣬳ɹ����� Dst}

function BigNumberCopyLow(const Dst: TCnBigNumber; const Src: TCnBigNumber;
  WordCount: Integer): TCnBigNumber;
{* ����һ����������ĵ� WordCount �� LongWord���ɹ����� Dst}

function BigNumberCopyHigh(const Dst: TCnBigNumber; const Src: TCnBigNumber;
  WordCount: Integer): TCnBigNumber;
{* ����һ����������ĸ� WordCount �� LongWord���ɹ����� Dst}

procedure BigNumberSwap(const Num1: TCnBigNumber; const Num2: TCnBigNumber);
{* ���������������������}

function BigNumberRandBytes(const Num: TCnBigNumber; BytesCount: Integer): Boolean;
{* �����̶��ֽڳ��ȵ��������������֤���λ�� 1����������ֽڶ�����֤�� 0}

function BigNumberRandBits(const Num: TCnBigNumber; BitsCount: Integer): Boolean;
{* �����̶�λ���ȵ��������������֤���λ�� 1����������ֽڶ�����֤�� 0}

function BigNumberRandRange(const Num: TCnBigNumber; const Range: TCnBigNumber): Boolean;
{* ���� [0, Range) ֮����������}

function BigNumberAnd(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
{* ������������λ�룬������� Res �У����������Ƿ�ɹ���Res ������ Num1 �� Num2}

function BigNumberOr(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
{* ������������λ�򣬽������ Res �У����������Ƿ�ɹ���Res ������ Num1 �� Num2}

function BigNumberXor(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
{* ������������λ��򣬽������ Res �У����������Ƿ�ɹ���Res ������ Num1 �� Num2}

function BigNumberUnsignedAdd(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
{* �������������޷�����ӣ�������� Res �У���������Ƿ�ɹ���Res ������ Num1 �� Num2}

function BigNumberUnsignedSub(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
{* �������������޷��������Num1 �� Num2��������� Res �У�
  ��������Ƿ�ɹ����� Num1 < Num2 ��ʧ��}

function BigNumberAdd(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
{* �������������������ӣ�������� Res �У���������Ƿ�ɹ���Num1 ������ Num2��Res ������ Num1 �� Num2}

function BigNumberSub(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
{* ����������������������������� Res �У���������Ƿ�ɹ���Num1 ������ Num2��Res ������ Num1 �� Num2}

function BigNumberShiftLeftOne(const Res: TCnBigNumber; const Num: TCnBigNumber): Boolean;
{* ��һ������������һλ��������� Res �У����������Ƿ�ɹ���Res ������ Num}

function BigNumberShiftRightOne(const Res: TCnBigNumber; const Num: TCnBigNumber): Boolean;
{* ��һ������������һλ��������� Res �У����������Ƿ�ɹ���Res ������ Num}

function BigNumberShiftLeft(const Res: TCnBigNumber; const Num: TCnBigNumber;
  N: Integer): Boolean;
{* ��һ������������ N λ��������� Res �У����������Ƿ�ɹ���Res ������ Num}

function BigNumberShiftRight(const Res: TCnBigNumber; const Num: TCnBigNumber;
  N: Integer): Boolean;
{* ��һ������������ N λ��������� Res �У����������Ƿ�ɹ���Res ������ Num}

function BigNumberSqr(const Res: TCnBigNumber; const Num: TCnBigNumber): Boolean;
{* ����һ���������ƽ��������� Res �У�����ƽ�������Ƿ�ɹ���Res ������ Num}

function BigNumberSqrt(const Res: TCnBigNumber; const Num: TCnBigNumber): Boolean;
{* ����һ���������ƽ�������������֣������ Res �У�����ƽ�������Ƿ�ɹ���Res ������ Num}

function BigNumberRoot(const Res: TCnBigNumber; const Num: TCnBigNumber; Exponent: Integer): Boolean;
{* ����һ��������� Exp �η������������֣������ Res �У����ظ������Ƿ�ɹ�
  Ҫ�� Num ����Ϊ����Exponent ����Ϊ 0 ��
  ע��FIXME: ��Ϊ�����޷����и�����㣬Ŀǰ����������ƫ����ƫ�󣬲��Ƽ�ʹ�ã�}

function BigNumberMul(const Res: TCnBigNumber; Num1: TCnBigNumber;
  Num2: TCnBigNumber): Boolean;
{* ��������������ĳ˻�������� Res �У����س˻������Ƿ�ɹ���Res ������ Num1 �� Num2}

function BigNumberMulKaratsuba(const Res: TCnBigNumber; Num1: TCnBigNumber;
  Num2: TCnBigNumber): Boolean;
{* �� Karatsuba �㷨��������������ĳ˻�������� Res �У����س˻������Ƿ�ɹ���Res ������ Num1 �� Num2
  ע������Ҳû���쵽����ȥ}

function BigNumberMulFloat(const Res: TCnBigNumber; Num: TCnBigNumber;
  F: Extended): Boolean;
{* ������������븡�����ĳ˻������ȡ����� Res �У����س˻������Ƿ�ɹ���Res ������ Num}

function BigNumberDiv(const Res: TCnBigNumber; const Remain: TCnBigNumber;
  const Num: TCnBigNumber; const Divisor: TCnBigNumber): Boolean;
{* ���������������Num / Divisor���̷� Res �У������� Remain �У����س��������Ƿ�ɹ���
   Res ������ Num��Remain ������ nil �Բ���Ҫ��������}

function BigNumberMod(const Remain: TCnBigNumber;
  const Num: TCnBigNumber; const Divisor: TCnBigNumber): Boolean;
{* �������������࣬Num mod Divisor�������� Remain �У�������������Ƿ�ɹ���Remain ������ Num}

function BigNumberNonNegativeMod(const Remain: TCnBigNumber;
  const Num: TCnBigNumber; const Divisor: TCnBigNumber): Boolean;
{* ����������Ǹ����࣬Num mod Divisor�������� Remain �У�0 <= Remain < |Divisor|
   Remain ʼ�մ����㣬������������Ƿ�ɹ�}

function BigNumberMulWordNonNegativeMod(const Res: TCnBigNumber;
  const Num: TCnBigNumber; N: Integer; const Divisor: TCnBigNumber): Boolean;
{* ����������� 32λ�з��������ٷǸ����࣬������ Res �У�0 <= Remain < |Divisor|
   Res ʼ�մ����㣬������������Ƿ�ɹ�}

function BigNumberAddMod(const Res: TCnBigNumber; const Num1, Num2: TCnBigNumber;
  const Divisor: TCnBigNumber): Boolean;
{* ����������ͺ�Ǹ����࣬Ҳ���� Res = (Num1 + Num2) mod Divisor ������������Ƿ�ɹ�}

function BigNumberSubMod(const Res: TCnBigNumber; const Num1, Num2: TCnBigNumber;
  const Divisor: TCnBigNumber): Boolean;
{* ������������Ǹ����࣬Ҳ���� Res = (Num1 - Num2) mod Divisor ������������Ƿ�ɹ�}

function BigNumberDivFloat(const Res: TCnBigNumber; Num: TCnBigNumber;
  F: Extended): Boolean;
{* ������������븡�������̣����ȡ����� Res �У����س˻������Ƿ�ɹ���Res ������ Num}

function BigNumberPower(const Res: TCnBigNumber; const Num: TCnBigNumber;
  Exponent: TCnLongWord32): Boolean;
{* ������������η������ؼ����Ƿ�ɹ���Res ������ Num}

function BigNumberExp(const Res: TCnBigNumber; const Num: TCnBigNumber;
  Exponent: TCnBigNumber): Boolean;
{* ����� Num �� Exponent  �η������س˷������Ƿ�ɹ��������ʱ}

function BigNumberGcd(const Res: TCnBigNumber; Num1: TCnBigNumber;
  Num2: TCnBigNumber): Boolean;
{* �������� Num1 �� Num2 �����Լ����Res ������ Num1 �� Num2}

function BigNumberLcm(const Res: TCnBigNumber; Num1: TCnBigNumber;
  Num2: TCnBigNumber): Boolean;
{* �������� Num1 �� Num2 ����С��������Res ������ Num1 �� Num2}

function BigNumberUnsignedMulMod(const Res: TCnBigNumber; const A, B, C: TCnBigNumber): Boolean;
{* ���ټ��� (A * B) mod C�����ؼ����Ƿ�ɹ���Res ������ C��A��B��C ���ֲ��䣨��� Res ���� A��B �Ļ���
  ע��: ��������������Ը�ֵ��Ҳ���Ǿ�����ֵ�������}

function BigNumberMulMod(const Res: TCnBigNumber; const A, B, C: TCnBigNumber): Boolean; {$IFDEF SUPPORT_DEPRECATED} deprecated; {$ENDIF}
{* ���ټ��� (A * B) mod C�����ؼ����Ƿ�ɹ���Res ������ C��A��B��C ���ֲ��䣨��� Res ���� A��B �Ļ���
  ע��: A��B �����Ǹ�ֵ���˻�Ϊ��ʱ�����Ϊ C - �˻�Ϊ������
  ����÷�����Ϊ������� BigNumberDirectMulMod �������Բ�����ʹ��}

function BigNumberDirectMulMod(const Res: TCnBigNumber; A, B, C: TCnBigNumber): Boolean;
{* ��ͨ���� (A * B) mod C�����ؼ����Ƿ�ɹ���Res ������ C��A��B��C ���ֲ��䣨��� Res ���� A��B �Ļ���
  ע�⣺λ������ʱ���÷���������� BigNumberMulMod ����Ҫ�첻�٣������ڲ�ִ�е��� NonNegativeMod������Ϊ��}

function BigNumberPowerMod(const Res: TCnBigNumber; A, B, C: TCnBigNumber): Boolean;
{* ���ټ��� (A ^ B) mod C�����ؼ����Ƿ�ɹ���Res ������ A��B��C ֮һ�����ܱ�������ɸ��������ô�Լ�ٷ�֮ʮ}

function BigNumberMontgomeryPowerMod(const Res: TCnBigNumber; A, B, C: TCnBigNumber): Boolean;
{* �ɸ����������ټ��� (A ^ B) mod C�����ؼ����Ƿ�ɹ���Res ������ A��B��C ֮һ�������Բ���Բ���}

function BigNumberLog2(const Num: TCnBigNumber): Extended;
{* ���ش����� 2 Ϊ�׵Ķ�������չ���ȸ���ֵ���ڲ�����չ���ȸ���ʵ�֣�����δ����}

function BigNumberLog10(const Num: TCnBigNumber): Extended;
{* ���ش����� 10 Ϊ�׵ĳ��ö�������չ���ȸ���ֵ���ڲ�����չ���ȸ���ʵ�֣�����δ����}

function BigNumberLogN(const Num: TCnBigNumber): Extended;
{* ���ش����� e Ϊ�׵���Ȼ��������չ���ȸ���ֵ���ڲ�����չ���ȸ���ʵ�֣�����δ����}

function BigNumberIsProbablyPrime(const Num: TCnBigNumber; TestCount: Integer = BN_MILLER_RABIN_DEF_COUNT): Boolean;
{* �������ж�һ�������Ƿ�������TestCount ָ Miller-Rabin �㷨�Ĳ��Դ�����Խ��Խ��ȷҲԽ��}

function BigNumberGeneratePrime(const Num: TCnBigNumber; BytesCount: Integer;
  TestCount: Integer = BN_MILLER_RABIN_DEF_COUNT): Boolean;
{* ����һ��ָ���ֽ�λ���Ĵ�����������֤���λΪ 1��TestCount ָ Miller-Rabin �㷨�Ĳ��Դ�����Խ��Խ��ȷҲԽ��}

function BigNumberGeneratePrimeByBitsCount(const Num: TCnBigNumber; BitsCount: Integer;
  TestCount: Integer = BN_MILLER_RABIN_DEF_COUNT): Boolean;
{* ����һ��ָ��������λ���Ĵ����������λȷ��Ϊ 1��TestCount ָ Miller-Rabin �㷨�Ĳ��Դ�����Խ��Խ��ȷҲԽ��}

function BigNumberNextPrime(Res, Num: TCnBigNumber;
  TestCount: Integer = BN_MILLER_RABIN_DEF_COUNT): Boolean;
{* ����һ���� Num �����ȵĴ������������ Res��Res ������ Num��
  TestCount ָ Miller-Rabin �㷨�Ĳ��Դ�����Խ��Խ��ȷҲԽ��}

function BigNumberCheckPrimitiveRoot(R, Prime: TCnBigNumber; Factors: TCnBigNumberList): Boolean;
{* ԭ���жϸ����������ж� R �Ƿ���� Prime - 1 ��ÿ�����ӣ����� R ^ (ʣ�����ӵĻ�) mod Prime <> 1
   Factors ������ Prime - 1 �Ĳ��ظ����������б��ɴ� BigNumberFindFactors ��ȡ��ȥ�ض���}

function BigNumberIsInt32(const Num: TCnBigNumber): Boolean;
{* �����Ƿ���һ�� 32 λ�з������ͷ�Χ�ڵ���}

function BigNumberIsUInt32(const Num: TCnBigNumber): Boolean;
{* �����Ƿ���һ�� 32 λ�޷������ͷ�Χ�ڵ���}

function BigNumberIsInt64(const Num: TCnBigNumber): Boolean;
{* �����Ƿ���һ�� 64 λ�з������ͷ�Χ�ڵ���}

function BigNumberIsUInt64(const Num: TCnBigNumber): Boolean;
{* �����Ƿ���һ�� 64 λ�޷������ͷ�Χ�ڵ���}

procedure BigNumberExtendedEuclideanGcd(A, B: TCnBigNumber; X: TCnBigNumber;
  Y: TCnBigNumber);
{* ��չŷ�����շת��������Ԫһ�β������� A * X + B * Y = 1 �������⣬�����������б�֤ A B ����
   A, B ����֪������X, Y �ǽ�����Ľ����ע�� X �п���С�� 0������Ҫ�����������ټ��� B}

procedure BigNumberExtendedEuclideanGcd2(A, B: TCnBigNumber; X: TCnBigNumber;
  Y: TCnBigNumber);
{* ��չŷ�����շת��������Ԫһ�β������� A * X - B * Y = 1 �������⣬�����������б�֤ A B ����
   A, B ����֪������X, Y �ǽ�����Ľ����ע�� X �п���С�� 0������Ҫ�����������ټ��� B
   X ����Ϊ A ��� B ��ģ��Ԫ�أ���˱��㷨Ҳ������ A ��� B ��ģ��Ԫ��
   �����ڿ������� -Y�����Ա���������һ�����ǵ�ͬ�� ��}

function BigNumberModularInverse(const Res: TCnBigNumber; X, Modulus: TCnBigNumber): Boolean;
{* �� X ��� Modulus ��ģ�����ģ��Ԫ Y������ (X * Y) mod M = 1��X ��Ϊ��ֵ��Y �����ֵ��
   �����������б�֤ X��Modulus ���ʣ��� Res ������ X �� Modulus}

procedure BigNumberModularInverseWord(const Res: TCnBigNumber; X: Integer; Modulus: TCnBigNumber);
{* �� 32 λ�з����� X ��� Modulus ��ģ�����ģ��Ԫ Y������ (X * Y) mod M = 1��X ��Ϊ��ֵ��Y �����ֵ��
   �����������б�֤ X��Modulus ���ʣ��� Res ������ X �� Modulus}

function BigNumberLegendre(A, P: TCnBigNumber): Integer;
{* �ö��λ����ɵݹ�������õ·��� ( A / P) ��ֵ���Ͽ�}

function BigNumberLegendre2(A, P: TCnBigNumber): Integer;
{* ��ŷ���б𷨼������õ·��� ( A / P) ��ֵ������}

function BigNumberTonelliShanks(const Res: TCnBigNumber; A, P: TCnBigNumber): Boolean;
{* ʹ�� Tonelli-Shanks �㷨����ģ��������ʣ����⣬Ҳ������ Res^2 mod P = A�������Ƿ��н�
   �����������б�֤ P Ϊ���������������������η�}

function BigNumberLucas(const Res: TCnBigNumber; A, P: TCnBigNumber): Boolean;
{* ʹ�� IEEE P1363 �淶�е� Lucas ���н���ģ��������ʣ����⣬Ҳ������ Res^2 mod P = A�������Ƿ��н�}

procedure BigNumberFindFactors(Num: TCnBigNumber; Factors: TCnBigNumberList);
{* �ҳ��������������б�}

procedure BigNumberEuler(const Res: TCnBigNumber; Num: TCnBigNumber);
{* �󲻴���һ 64 λ�޷����� Num ���� Num ���ʵ��������ĸ�����Ҳ����ŷ������}

function BigNumberLucasSequenceMod(X, Y, K, N: TCnBigNumber; Q, V: TCnBigNumber): Boolean;
{* ���� IEEE P1363 �Ĺ淶��˵���� Lucas ���У������������б�֤ N Ϊ������
   Lucas ���еݹ鶨��Ϊ��V0 = 2, V1 = X, and Vk = X * Vk-1 - Y * Vk-2   for k >= 2
   V ���� Vk mod N��Q ���� Y ^ (K div 2) mod N}

function BigNumberChineseRemainderTheorem(Res: TCnBigNumber;
  Remainers, Factors: TCnBigNumberList): Boolean; overload;
{* ���й�ʣ�ඨ�����������뻥�صĳ�����һԪ����ͬ�෽�������С�⣬��������Ƿ�ɹ�
  ����Ϊ�����б�}

function BigNumberChineseRemainderTheorem(Res: TCnBigNumber;
  Remainers, Factors: TCnInt64List): Boolean; overload;
{* ���й�ʣ�ඨ�����������뻥�صĳ�����һԪ����ͬ�෽�������С�⣬��������Ƿ�ɹ�
   ����Ϊ Int64 �б�}

function BigNumberIsPerfectPower(Num: TCnBigNumber): Boolean;
{* �жϴ����Ƿ�����ȫ�ݣ������ϴ�ʱ��һ����ʱ}

procedure BigNumberFillCombinatorialNumbers(List: TCnBigNumberList; N: Integer);
{* ��������� C(m, N) �����ɴ�������������������У����� m �� 0 �� N}

procedure BigNumberFillCombinatorialNumbersMod(List: TCnBigNumberList; N: Integer; P: TCnBigNumber);
{* ��������� C(m, N) mod P �����ɴ�������������������У����� m �� 0 �� N}

function BigNumberAKSIsPrime(N: TCnBigNumber): Boolean;
{* �� AKS �㷨�ж�ĳ�������Ƿ����������ж� 9223372036854775783 Լ�� 15 ��}

function BigNumberDebugDump(const Num: TCnBigNumber): string;
{* ��ӡ�����ڲ���Ϣ}

function SparseBigNumberListIsZero(P: TCnSparseBigNumberList): Boolean;
{* �ж� SparseBigNumberList �Ƿ�Ϊ 0��ע�� nil��0 ���Ψһ 1 ������ 0������Ϊ 0 ����}

function SparseBigNumberListEqual(A, B: TCnSparseBigNumberList): Boolean;
{* �ж����� SparseBigNumberList �Ƿ���ȣ�ע�� nil��0 ���Ψһ 1 ������ 0������Ϊ 0 ����}

procedure SparseBigNumberListCopy(Dst, Src: TCnSparseBigNumberList);
{* �� Src ������ Dst}

procedure SparseBigNumberListMerge(Dst, Src1, Src2: TCnSparseBigNumberList; Add: Boolean = True);
{* �ϲ����� SparseBigNumberList ��Ŀ�� List �У�ָ����ͬ��ϵ�� Add Ϊ True ʱ��ӣ��������
  Dst ������ Src1 �� Src2��Src1 �� Src2 �������}

var
  CnBigNumberOne: TCnBigNumber = nil;     // ��ʾ 1 �ĳ���
  CnBigNumberZero: TCnBigNumber = nil;    // ��ʾ 0 �ĳ���

implementation

uses
  CnPrimeNumber, CnBigDecimal, CnFloatConvert;

resourcestring
  SCN_BN_LOG_RANGE_ERROR = 'Log Range Error';
  SCN_BN_LEGENDRE_ERROR = 'Legendre: A, P Must > 0';
  SCN_BN_FLOAT_EXP_RANGE_ERROR = 'Extended Float Exponent Range Error';

const
  Hex: string = '0123456789ABCDEF';

  BN_DEC_CONV = 1000000000;
  BN_DEC_FMT = '%u';
  BN_DEC_FMT2 = '%.9u';
  BN_PRIME_NUMBERS = 2048;

  BN_MUL_KARATSUBA = 80;  // ���ڵ��� 80 �� LongWord �ĳ˷����� Karatsuba �㷨
  CRLF = #13#10;

  SPARSE_BINARY_SEARCH_THRESHOLD = 4;

{$IFNDEF MSWINDOWS}
  MAXDWORD = TCnLongWord32($FFFFFFFF);
{$ENDIF}

var
  FLocalBigNumberPool: TCnBigNumberPool = nil;
  FLocalBigBinaryPool: TCnBigBinaryPool = nil;

function BigNumberNew: TCnBigNumber;
begin
  Result := TCnBigNumber.Create;
end;

procedure BigNumberInit(const Num: TCnBigNumber);
begin
  // FillChar(Num, SizeOf(TCnBigNumber), 0);
  if Num = nil then
    Exit;

  Num.Top := 0;
  Num.Neg := 0;
  Num.DMax := 0;
  Num.D := nil;
end;

procedure BigNumberFree(const Num: TCnBigNumber);
begin
  Num.Free;
end;

function BigNumberIsZero(const Num: TCnBigNumber): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  Result := (Num.Top = 0);
end;

function BigNumberSetZero(const Num: TCnBigNumber): Boolean;
begin
  Result := BigNumberSetWord(Num, 0);
end;

// ����һ�������ṹ��Ĵ����ľ���ֵ�Ƿ�Ϊָ���� DWORD ֵ
function BigNumberAbsIsWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
begin
  Result := True;
  if (W = 0) and (Num.Top = 0) then
    Exit;
  if (Num.Top = 1) and (PLongWordArray(Num.D)^[0] = W) then
    Exit;
  Result := False;
end;

function BigNumberIsOne(const Num: TCnBigNumber): Boolean;
begin
  Result := (Num.Neg = 0) and BigNumberAbsIsWord(Num, 1);
end;

function BigNumberIsNegOne(const Num: TCnBigNumber): Boolean;
begin
  Result := (Num.Neg = 1) and BigNumberAbsIsWord(Num, 1);
end;

function BigNumberSetOne(const Num: TCnBigNumber): Boolean;
begin
  Result := BigNumberSetWord(Num, 1);
end;

function BigNumberIsOdd(const Num: TCnBigNumber): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  if (Num.Top > 0) and ((PLongWordArray(Num.D)^[0] and 1) <> 0) then
    Result := True
  else
    Result := False;
end;

function BigNumberGetWordBitsCount(L: TCnLongWord32): Integer;
const
  Bits: array[0..255] of Byte = (
    0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4,
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
  );
begin
  if (L and $FFFF0000) <> 0 then
  begin
    if (L and $FF000000) <> 0 then
      Result := Bits[L shr 24] + 24
    else
      Result := Bits[L shr 16] + 16;
  end
  else
  begin
    if (L and $FF00) <> 0 then
      Result := Bits[L shr 8] + 8
    else
      Result := Bits[L];
  end;
end;

function BigNumberGetBitsCount(const Num: TCnBigNumber): Integer;
var
  I: Integer;
begin
  Result := 0;
  if BigNumberIsZero(Num) then
    Exit;

  I := Num.Top - 1;
  Result := ((I * BN_BITS2) + BigNumberGetWordBitsCount(PLongWordArray(Num.D)^[I]));
end;

function BigNumberGetBytesCount(const Num: TCnBigNumber): Integer;
begin
  Result := (BigNumberGetBitsCount(Num) + 7) div 8;
end;

function BigNumberGetWordsCount(const Num: TCnBigNumber): Integer;
begin
  Result := Num.Top;
end;

function BigNumberGetTenPrecision(const Num: TCnBigNumber): Integer;
const
  LOG_10_2 = 0.30103;
var
  B, P, Q: Integer;
  N: TCnBigNumber;
begin
  Result := 0;
  if Num.IsZero then
    Exit;

  B := Num.GetBitsCount;
  if B <= 3 then
  begin
    Result := 1;
    Exit;
  end;

  P := Trunc(LOG_10_2 * B) + 1;
  Q := Trunc(LOG_10_2 * (B - 1)) + 1;
  // N λ������ȫ 1 ʱ�������Դ�ģ�Ҳ���� N + 1 λ�Ķ�����ֻ�и�λ 1 �ģ� 10 ������ʽ��λ������ (N) * Log10(2) ���������� + 1������Ϊ P
  // N λ������ֻ�и�λ 1 ʱ������ 10 ������ʽ��λ������ (N - 1) * Log10(2) ���������� + 1������Ϊ Q��Q �� P ����� 1���п������
  // Ҳ���� N λ���������ʱ���� 10 ����λ������ P��N λ��������Сֻ�и�λΪ 1 ʱ���� 10 ����λ������ Q
  // Ҳ����˵��N λ�����ƴ����ֵ����ֵ��Ȼ���� 10^(Q - 1)�������п�����ǰ���� 10^(P - 1)��P��Q ���� 1�����ֻҪ�Ƚ�һ�ξ�����

  // ����ο��ټ���� 10^Q�����ǵ��ö������ݳ˷� BigNumberPower

  if P = Q then  // ������ N�������С�� 10 ����λ����һ�������������Ƚϼ��㣬ֱ�ӷ���
  begin
    Result := P;
    Exit;
  end;

  N := FLocalBigNumberPool.Obtain;
  try
    // �ȼ��� P λ 10 ���Ƶ���Сֵ 10^(P - 1) ���ݣ��ͱ����Ƚϣ�ע������ P �� Q ��һ��
    N.SetWord(10);
    N.PowerWord(Q);

    Result := Q;
    if BignumberUnsignedCompare(Num, N) < 0 then
      Exit;

    Inc(Result); // ������ڻ���� P λ 10 ���Ƶ���Сֵ 10^(P - 1) ���ݣ���λ���� Q �� 1
  finally
    FLocalBigNumberPool.Recycle(N);
  end;
end;

function BigNumberGetTenPrecision2(const Num: TCnBigNumber): Integer;
const
  LOG_10_2 = 0.30103;
var
  B: Integer;
begin
  Result := 0;
  if Num.IsZero then
    Exit;

  B := Num.GetBitsCount;
  if B <= 3 then
  begin
    Result := 1;
    Exit;
  end;

  Result := Trunc(LOG_10_2 * B) + 1;
end;

function BigNumberExpandInternal(const Num: TCnBigNumber; Words: Integer): PCnLongWord32;
var
  A, B, TmpA: PCnLongWord32;
  I: Integer;
  A0, A1, A2, A3: TCnLongWord32;
begin
  Result := nil;
  if Words > (MaxInt div (4 * BN_BITS2)) then
    Exit;

  A := PCnLongWord32(GetMemory(SizeOf(MAXDWORD) * Words));
  if A = nil then
    Exit;

  FillChar(A^, SizeOf(MAXDWORD) * Words, 0);

  // ����Ƿ�Ҫ����֮ǰ��ֵ
  B := Num.D;
  if B <> nil then
  begin
    TmpA := A;
    I :=  Num.Top shr 2;
    while I > 0 do
    begin
      A0 := PLongWordArray(B)^[0];
      A1 := PLongWordArray(B)^[1];
      A2 := PLongWordArray(B)^[2];
      A3 := PLongWordArray(B)^[3];

      PLongWordArray(TmpA)^[0] := A0;
      PLongWordArray(TmpA)^[1] := A1;
      PLongWordArray(TmpA)^[2] := A2;
      PLongWordArray(TmpA)^[3] := A3;

      Dec(I);
      TmpA := PCnLongWord32(TCnNativeInt(TmpA) + 4 * SizeOf(TCnLongWord32));
      B := PCnLongWord32(TCnNativeInt(B) + 4 * SizeOf(TCnLongWord32));
    end;

    case Num.Top and 3 of
      3:
        begin
          PLongWordArray(TmpA)^[2] := PLongWordArray(B)^[2];
          PLongWordArray(TmpA)^[1] := PLongWordArray(B)^[1];
          PLongWordArray(TmpA)^[0] := PLongWordArray(B)^[0];
        end;
      2:
        begin
          PLongWordArray(TmpA)^[1] := PLongWordArray(B)^[1];
          PLongWordArray(TmpA)^[0] := PLongWordArray(B)^[0];
        end;
      1:
        begin
          PLongWordArray(TmpA)^[0] := PLongWordArray(B)^[0];
        end;
      0:
        begin
          ;
        end;
    end;
  end;

  Result := A;
end;

function BigNumberExpand2(const Num: TCnBigNumber; Words: Integer): TCnBigNumber;
var
  P: PCnLongWord32;
begin
  Result := nil;
  if Words > Num.DMax then
  begin
    P := BigNumberExpandInternal(Num, Words);
    if P = nil then
      Exit;

    if Num.D <> nil then
      FreeMemory(Num.D);
    Num.D := P;
    Num.DMax := Words;

    Result := Num;
  end;
end;

function BigNumberWordExpand(const Num: TCnBigNumber; Words: Integer): TCnBigNumber;
begin
  if Words <= Num.DMax then
    Result := Num
  else
    Result := BigNumberExpand2(Num, Words);
end;

function BigNumberExpandBits(const Num: TCnBigNumber; Bits: Integer): TCnBigNumber;
begin
  if ((Bits + BN_BITS2 - 1) div BN_BITS2) <= Num.DMax then
    Result := Num
  else
    Result := BigNumberExpand2(Num, (Bits + BN_BITS2 - 1) div BN_BITS2);
end;

procedure BigNumberClear(const Num: TCnBigNumber);
begin
  if Num = nil then
    Exit;

  if Num.D <> nil then
    FillChar(Num.D^, Num.DMax * SizeOf(TCnLongWord32), 0);
  Num.Top := 0;
  Num.Neg := 0;
end;

function BigNumberGetWord(const Num: TCnBigNumber): TCnLongWord32;
begin
  if Num.Top > 1 then
    Result := BN_MASK2
  else if Num.Top = 1 then
    Result := PLongWordArray(Num.D)^[0]
  else
    Result := 0;
end;

function BigNumberSetWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
begin
  Result := False;
  if BigNumberExpandBits(Num, SizeOf(TCnLongWord32) * 8) = nil then
    Exit;
  Num.Neg := 0;
  PLongWordArray(Num.D)^[0] := W;
  if W <> 0 then
    Num.Top := 1
  else
    Num.Top := 0;
  Result := True;
end;

function BigNumberGetInteger(const Num: TCnBigNumber): Integer;
begin
  if Num.Top > 1 then
    Result := BN_MASK2S
  else if Num.Top = 1 then
  begin
    Result := Integer(PLongWordArray(Num.D)^[0]);
    if Result < 0 then        // UInt32 ���λ��ֵ��˵���Ѿ������� Integer �ķ�Χ������ Max Integer
      Result := BN_MASK2S
    else if Num.Neg <> 0 then // �����󷴼�һ
      Result := (not Result) + 1;
  end
  else
    Result := 0;
end;

function BigNumberSetInteger(const Num: TCnBigNumber; W: Integer): Boolean;
begin
  if W < 0 then
  begin
    BigNumberSetWord(Num, -W);
    Num.Negate;
  end
  else
    BigNumberSetWord(Num ,W);
  Result := True;
end;

function BigNumberGetInt64(const Num: TCnBigNumber): Int64;
begin
  if Num.Top > 2 then
    Result := BN_MASK3S
  else if Num.Top = 2 then
  begin
    Result := PInt64Array(Num.D)^[0];
    if Result < 0 then        // UInt64 ���λ��ֵ��˵���Ѿ������� Int64 �ķ�Χ������ Max Int64
      Result := BN_MASK3S
    else if Num.Neg <> 0 then // �����󷴼�һ
      Result := (not Result) + 1;
  end
  else if Num.Top = 1 then
    Result := Int64(PLongWordArray(Num.D)^[0])
  else
    Result := 0;
end;

function BigNumberSetInt64(const Num: TCnBigNumber; W: Int64): Boolean;
begin
  Result := False;
  if BigNumberExpandBits(Num, SizeOf(Int64) * 8) = nil then
    Exit;

  if W >= 0 then
  begin
    Num.Neg := 0;
    PInt64Array(Num.D)^[0] := W;
    if W = 0 then
      Num.Top := 0
    else if ((W and $FFFFFFFF00000000) shr 32) = 0 then // ��� Int64 �� 32 λ�� 0
      Num.Top := 1
    else
      Num.Top := 2;
  end
  else // W < 0
  begin
    Num.Neg := 1;
    W := (not W) + 1;
    PInt64Array(Num.D)^[0] := W;

    if ((W and $FFFFFFFF00000000) shr 32) = 0 then // ��� Int64 �� 32 λ�� 0
      Num.Top := 1
    else
      Num.Top := 2;
  end;
  Result := True;
end;

function BigNumberGetUInt64UsingInt64(const Num: TCnBigNumber): TUInt64;
begin
  if Num.Top > 2 then
    Result := TUInt64(BN_MASK3U)
  else if Num.Top = 2 then
  begin
{$IFDEF SUPPORT_UINT64}
    Result := TUInt64(PInt64Array(Num.D)^[0]);
{$ELSE}
    Result := PInt64Array(Num.D)^[0]; // �� D5/6 �� Int64ת Int64 ���� C3517 ���󣡣���
{$ENDIF}
  end
  else if Num.Top = 1 then
    Result := TUInt64(PLongWordArray(Num.D)^[0])
  else
    Result := 0;
end;

function BigNumberSetUInt64UsingInt64(const Num: TCnBigNumber; W: TUInt64): Boolean;
begin
  Result := False;
  if BigNumberExpandBits(Num, SizeOf(Int64) * 8) = nil then
    Exit;

  Num.Neg := 0;
  PInt64Array(Num.D)^[0] := Int64(W);
  if W = 0 then
    Num.Top := 0
  else if ((W and $FFFFFFFF00000000) shr 32) = 0 then // ��� Int64 �� 32 λ�� 0
    Num.Top := 1
  else
    Num.Top := 2;

  Result := True;
end;

{$IFDEF SUPPORT_UINT64}

function BigNumberGetUInt64(const Num: TCnBigNumber): UInt64;
begin
  if Num.Top > 2 then
    Result := UInt64(BN_MASK3U)
  else if Num.Top = 2 then
    Result := PUInt64Array(Num.D)^[0]
  else if Num.Top = 1 then
    Result := UInt64(PLongWordArray(Num.D)^[0])
  else
    Result := 0;
end;

function BigNumberSetUInt64(const Num: TCnBigNumber; W: UInt64): Boolean;
begin
  Result := False;
  if BigNumberExpandBits(Num, SizeOf(UInt64) * 8) = nil then
    Exit;

  Num.Neg := 0;
  PUInt64Array(Num.D)^[0] := W;
  if W <> 0 then
    Num.Top := 2
  else if ((W and $FFFFFFFF00000000) shr 32) = 0 then // ��� UInt64 �� 32 λ�� 0
    Num.Top := 1
  else
    Num.Top := 0;
  Result := True;
end;

{$ENDIF}

// ĳ�����Ƿ����ָ�� DWORD
function BigNumberIsWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
begin
  Result := False;
  if (W = 0) or (Num.Neg = 0) then
    if BigNumberAbsIsWord(Num, W) then
      Result := True;
end;

// ���� Top ��֤ D[Top - 1] ָ�����λ�� 0 ��
procedure BigNumberCorrectTop(const Num: TCnBigNumber);
var
  Ftl: PCnLongWord32;
  Top: Integer;
begin
  Top := Num.Top;
  Ftl := @(PLongWordArray(Num.D)^[Top - 1]);
  while Top > 0 do
  begin
    if Ftl^ <> 0 then
      Break;

    Ftl := PCnLongWord32(TCnNativeInt(Ftl) - SizeOf(TCnLongWord32));
    Dec(Top);
  end;
  Num.Top := Top;
end;

function BigNumberToBinary(const Num: TCnBigNumber; Buf: PAnsiChar): Integer;
var
  I: Integer;
  L: TCnLongWord32;
begin
  Result := BigNumberGetBytesCount(Num);
  if Buf = nil then
    Exit;

  I := Result;
  while I > 0 do
  begin
    Dec(I);
    L := PLongWordArray(Num.D)^[I div BN_BYTES];
    Buf^ := AnsiChar(Chr(L shr (8 * (I mod BN_BYTES)) and $FF));

    Buf := PAnsiChar(TCnNativeInt(Buf) + 1);
  end;
end;

function BigNumberWriteBinaryToStream(const Num: TCnBigNumber; Stream: TStream;
  FixedLen: Integer): Integer;
var
  Buf: array of Byte;
  Len: Integer;
begin
  Result := 0;
  Len := BigNumberGetBytesCount(Num);
  if (Stream <> nil) and (Len > 0) then
  begin
    if FixedLen > Len then
    begin
      SetLength(Buf, FixedLen);
      BigNumberToBinary(Num, @Buf[FixedLen - Len]);
      Result := Stream.Write(Buf[0], FixedLen);
    end
    else
    begin
      SetLength(Buf, Len);
      BigNumberToBinary(Num, @Buf[0]);
      Result := Stream.Write(Buf[0], Len);
    end;
    SetLength(Buf, 0);
  end;
end;

function BigNumberFromBinary(Buf: PAnsiChar; Len: Integer): TCnBigNumber;
begin
  Result := BigNumberNew;
  if Result = nil then
    Exit;

  if not BigNumberSetBinary(Buf, Len, Result) then
  begin
    BigNumberFree(Result);
    Result := nil;
  end;
end;

{$IFDEF TBYTES_DEFINED}

function BigNumberFromBytes(Buf: TBytes): TCnBigNumber;
begin
  Result := nil;
  if (Buf <> nil) and (Length(Buf) > 0) then
    Result := BigNumberFromBinary(@Buf[0], Length(Buf) - 1);
end;

function BigNumberToBytes(const Num: TCnBigNumber): TBytes;
var
  L: Integer;
begin
  Result := nil;
  L := BigNumberGetBytesCount(Num);
  if L > 0 then
  begin
    SetLength(Result, L);
    BigNumberToBinary(Num, @Result[0]);
  end;
end;

{$ENDIF}

function BigNumberSetBinary(Buf: PAnsiChar; Len: Integer;
  const Res: TCnBigNumber): Boolean;
var
  I, M, N, L: TCnLongWord32;
begin
  Result := False;
  L := 0;
  N := Len;
  if N = 0 then
  begin
    Res.Top := 0;
    Exit;
  end;

  I := ((N - 1) div BN_BYTES) + 1;
  M := (N - 1) mod BN_BYTES;

  if BigNumberWordExpand(Res, I) = nil then
  begin
    BigNumberFree(Res);
    Exit;
  end;

  Res.Top := I;
  Res.Neg := 0;
  while N > 0 do
  begin
    L := (L shl 8) or Ord(Buf^);
    Buf := PAnsiChar(TCnNativeInt(Buf) + 1);

    if M = 0 then
    begin
      Dec(I);
      PLongWordArray(Res.D)^[I] := L;
      L := 0;
      M := BN_BYTES - 1;
    end
    else
      Dec(M);

    Dec(N);
  end;
  BigNumberCorrectTop(Res);
  Result := True;
end;

procedure BigNumberSetNegative(const Num: TCnBigNumber; Negative: Boolean);
begin
  if BigNumberIsZero(Num) then
    Exit;
  if Negative then
    Num.Neg := 1
  else
    Num.Neg := 0;
end;

function BigNumberIsNegative(const Num: TCnBigNumber): Boolean;
begin
  Result := Num.Neg <> 0;
end;

procedure BigNumberNegate(const Num: TCnBigNumber);
begin
  if BigNumberIsZero(Num) then
    Exit;
  if Num.Neg <> 0 then
    Num.Neg := 0
  else
    Num.Neg := 1;
end;

function BigNumberClearBit(const Num: TCnBigNumber; N: Integer): Boolean;
var
  I, J: Integer;
begin
  Result := False;
  if N < 0 then
    Exit;

  I := N div BN_BITS2;
  J := N mod BN_BITS2;

  if Num.Top <= I then
    Exit;

  PLongWordArray(Num.D)^[I] := PLongWordArray(Num.D)^[I] and TCnLongWord32(not (1 shl J));
  BigNumberCorrectTop(Num);
  Result := True;
end;

function BigNumberKeepLowBits(const Num: TCnBigNumber; Count: Integer): Boolean;
var
  I, J: Integer;
  B: TCnLongWord32;
begin
  Result := False;
  if Count < 0 then
    Exit;

  if Count = 0 then
  begin
    Num.SetZero;
    Result := True;
    Exit;
  end;

  I := Count div BN_BITS2;
  J := Count mod BN_BITS2;

  if Num.Top <= I then
  begin
    Result := True;
    Exit;
  end;

  Num.Top := I + 1;
  if J > 0 then // Ҫ�������һ�� LongWord �е� 0 �� J - 1 λ���� J λ��J ��� 31
  begin
    B := 1 shl J;         // 0000100000 ��� J �� 31 Ҳ�������
    B := B - 1;           // 0000011111
    PLongWordArray(Num.D)^[I] := PLongWordArray(Num.D)^[I] and B;
  end;

  BigNumberCorrectTop(Num);
  Result := True;
end;

function BigNumberSetBit(const Num: TCnBigNumber; N: Integer): Boolean;
var
  I, J, K: Integer;
begin
  Result := False;
  if N < 0 then
    Exit;

  I := N div BN_BITS2;
  J := N mod BN_BITS2;

  if Num.Top <= I then
  begin
    if BigNumberWordExpand(Num, I + 1) = nil then
      Exit;

    for K := Num.Top to I do
      PLongWordArray(Num.D)^[K] := 0;

    Num.Top := I + 1;
  end;

  PLongWordArray(Num.D)^[I] := PLongWordArray(Num.D)^[I] or TCnLongWord32(1 shl J);
  Result := True;
end;

function BigNumberIsBitSet(const Num: TCnBigNumber; N: Integer): Boolean;
var
  I, J: Integer;
begin
  Result := False;
  if N < 0 then
    Exit;

  I := N div BN_BITS2;
  J := N mod BN_BITS2;

  if Num.Top <= I then
    Exit;

  if (TCnLongWord32(PLongWordArray(Num.D)^[I] shr J) and TCnLongWord32(1)) <> 0 then
    Result := True;
end;

function BigNumberCompareWords(var Num1: TCnBigNumber; var Num2: TCnBigNumber;
  N: Integer): Integer;
var
  I: Integer;
  A, B: TCnLongWord32;
begin
  A := PLongWordArray(Num1.D)^[N - 1];
  B := PLongWordArray(Num2.D)^[N - 1];

  if A <> B then
  begin
    if A > B then
      Result := 1
    else
      Result := -1;
    Exit;
  end;

  for I := N - 2 downto 0 do
  begin
    A := PLongWordArray(Num1.D)^[I];
    B := PLongWordArray(Num2.D)^[I];

    if A <> B then
    begin
      if A > B then
        Result := 1
      else
        Result := -1;
      Exit;
    end;
  end;
  Result := 0;
end;

function BigNumberEqual(const Num1: TCnBigNumber; const Num2: TCnBigNumber): Boolean;
begin
  Result := BigNumberCompare(Num1, Num2) = 0;
end;

function BigNumberCompare(const Num1: TCnBigNumber; const Num2: TCnBigNumber): Integer;
var
  I, Gt, Lt: Integer;
  T1, T2: TCnLongWord32;
begin
  if Num1 = Num2 then
  begin
    Result := 0;
    Exit;
  end;

  if (Num1 = nil) or (Num2 = nil) then
  begin
    if Num1 <> nil then
      Result := -1
    else if Num2 <> nil then
      Result := 1
    else
      Result := 0;

    Exit;
  end;

  if Num1.Neg <> Num2.Neg then
  begin
    if Num1.Neg <> 0 then
      Result := -1
    else
      Result := 1;
    Exit;
  end;

  if Num1.Neg = 0 then
  begin
    Gt := 1;
    Lt := -1;
  end
  else
  begin
    Gt := -1;
    Lt := 1;
  end;

  if Num1.Top > Num2.Top then
  begin
    Result := Gt;
    Exit;
  end
  else if Num1.Top < Num2.Top then
  begin
    Result := Lt;
    Exit;
  end;

  for I := Num1.Top - 1 downto 0 do
  begin
    T1 := PLongWordArray(Num1.D)^[I];
    T2 := PLongWordArray(Num2.D)^[I];
    if T1 > T2 then
    begin
      Result := Gt;
      Exit;
    end;
    if T1 < T2 then
    begin
      Result := Lt;
      Exit;
    end;
  end;
  Result := 0;
end;

function BigNumberCompareInteger(const Num1: TCnBigNumber; const Num2: Integer): Integer;
var
  T: TCnBigNumber;
begin
  T := FLocalBigNumberPool.Obtain;
  try
    T.SetInteger(Num2);
    Result := BigNumberCompare(Num1, T);
  finally
    FLocalBigNumberPool.Recycle(T);
  end;
end;

function BigNumberUnsignedCompare(const Num1: TCnBigNumber; const Num2: TCnBigNumber): Integer;
var
  I: Integer;
  T1, T2: TCnLongWord32;
begin
  Result := Num1.Top - Num2.Top;
  if Result <> 0 then
    Exit;

  for I := Num1.Top - 1 downto 0 do
  begin
    T1 := PLongWordArray(Num1.D)^[I];
    T2 := PLongWordArray(Num2.D)^[I];
    if T1 > T2 then
    begin
      Result := 1;
      Exit;
    end;
    if T1 < T2 then
    begin
      Result := -1;
      Exit;
    end;
  end;
  Result := 0;
end;

// �����̶��ֽڳ��ȵ��������
function BigNumberRandBytes(const Num: TCnBigNumber; BytesCount: Integer): Boolean;
begin
  Result := False;
  if BytesCount < 0 then
    Exit;
  if BytesCount = 0 then
  begin
    Result := BigNumberSetZero(Num);
    Exit;
  end;

  if BigNumberWordExpand(Num, (BytesCount + 3) div 4) <> nil then
  begin
    Result := CnRandomFillBytes(PAnsiChar(Num.D), BytesCount);
    if Result then
    begin
      Num.Top := (BytesCount + 3) div 4;
      BigNumberCorrectTop(Num);
    end;
  end;
end;

// �����̶�λ���ȵ��������
function BigNumberRandBits(const Num: TCnBigNumber; BitsCount: Integer): Boolean;
var
  C, I: Integer;
begin
  Result := False;
  if BitsCount < 0 then
    Exit;
  if BitsCount = 0 then
  begin
    Result := BigNumberSetZero(Num);
    Exit;
  end;

  // Ҫ���� N bits ������������ֽڼ���Ҳ���� (N + 7) div 8 bytes
  C := (BitsCount + 7) div 8;
  if not BigNumberRandBytes(Num, C) then
    Exit;

  // ��ͷ�Ͽ����ж���ģ��ٰ� C * 8 - 1 �� N ֮���λ���㣬ֻ�� 0 �� N - 1 λ
  if BitsCount <= C * 8 - 1 then
    for I := C * 8 - 1 downto BitsCount do
      if not BigNumberClearBit(Num, I) then
        Exit;

  Result := True;
end;

function BigNumberRandRange(const Num: TCnBigNumber; const Range: TCnBigNumber): Boolean;
var
  N, C, I: Integer;
begin
  Result := False;
  if (Range = nil) or (Num = nil) or (Range.Neg <> 0) or BigNumberIsZero(Range) then
    Exit;

  N := BigNumberGetBitsCount(Range);
  if N = 1 then
    BigNumberSetZero(Num)
  else
  begin
    // Ҫ���� N bits ������������ֽڼ���Ҳ���� (N + 7) div 8 bytes
    C := (N + 7) div 8;
    if not BigNumberRandBytes(Num, C) then
      Exit;

    // ��ͷ�Ͽ����ж���ģ��ٰ� C * 8 - 1 �� N + 1 ֮���λ����
    if N + 1 <= C * 8 - 1 then
      for I := C * 8 - 1 downto N + 1 do
        if BigNumberIsBitSet(Num, I) then
          if not BigNumberClearBit(Num, I) then
            Exit;
    // �Ӹ� IsBitSet ���жϣ���Ϊ ClearBit ���жϴ� Clear ��λ�Ƿ񳬳� Top��
    // ������ɵ�λ�������� 0�����Ѿ��� CorrectTop�ˣ���ô ClearBit �����

    while BigNumberCompare(Num, Range) >= 0 do
    begin
      if not BigNumberSub(Num, Num, Range) then
        Exit;
    end;
  end;
  Result := True;
end;

function BigNumberDuplicate(const Num: TCnBigNumber): TCnBigNumber;
begin
  Result := BigNumberNew;
  if Result = nil then
    Exit;

  if BigNumberCopy(Result, Num) = nil then
  begin
    BigNumberFree(Result);
    Result := nil;
  end;
end;

function BigNumberCopy(const Dst: TCnBigNumber; const Src: TCnBigNumber): TCnBigNumber;
var
  I: Integer;
  A, B: PLongWordArray;
  A0, A1, A2, A3: TCnLongWord32;
begin
  if Dst = Src then
  begin
    Result := Dst;
    Exit;
  end;

  if BigNumberWordExpand(Dst, Src.Top) = nil then
  begin
    Result := nil;
    Exit;
  end;

  A := PLongWordArray(Dst.D);
  B := PLongWordArray(Src.D);

  for I := (Src.Top shr 2) downto 1 do
  begin
    A0 := B^[0];
    A1 := B^[1];
    A2 := B^[2];
    A3 := B^[3];
    A^[0] := A0;
    A^[1] := A1;
    A^[2] := A2;
    A^[3] := A3;

    A := PLongWordArray(TCnNativeInt(A) + 4 * SizeOf(TCnLongWord32));
    B := PLongWordArray(TCnNativeInt(B) + 4 * SizeOf(TCnLongWord32));
  end;

  case Src.Top and 3 of
  3:
    begin
      A[2] := B[2];
      A[1] := B[1];
      A[0] := B[0];
    end;
  2:
    begin
      A[1] := B[1];
      A[0] := B[0];
    end;
  1:
    begin
      A[0] := B[0];
    end;
  0:
    begin

    end;
  end;

  Dst.Top := Src.Top;
  Dst.Neg := Src.Neg;
  Result := Dst;
end;

function BigNumberCopyLow(const Dst: TCnBigNumber; const Src: TCnBigNumber;
  WordCount: Integer): TCnBigNumber;
var
  I: Integer;
  A, B: PLongWordArray;
begin
  if WordCount <= 0 then
  begin
    Result := Dst;
    Dst.SetZero;
    Exit;
  end
  else if Src = Dst then // ��֧�� Src �� Dst ��ͬ�����
    Result := nil
  else
  begin
    if WordCount > Src.GetWordCount then
      WordCount := Src.GetWordCount;

    if BigNumberWordExpand(Dst, WordCount) = nil then
    begin
      Result := nil;
      Exit;
    end;

    A := PLongWordArray(Dst.D);
    B := PLongWordArray(Src.D);

    Result := Dst;
    for I := 0 to WordCount - 1 do // �� Src �� 0 �� WordCount - 1 ��ֵ�� Dst �� 0 �� WordCount - 1
      A[I] := B[I];

    Dst.Top := WordCount;
    Dst.Neg := Src.Neg;
  end;
end;

function BigNumberCopyHigh(const Dst: TCnBigNumber; const Src: TCnBigNumber;
  WordCount: Integer): TCnBigNumber;
var
  I: Integer;
  A, B: PLongWordArray;
begin
  if WordCount <= 0 then
  begin
    Result := Dst;
    Dst.SetZero;
    Exit;
  end
  else if Src = Dst then // ��֧�� Src �� Dst ��ͬ�����
    Result := nil
  else
  begin
    if WordCount > Src.GetWordCount then
      WordCount := Src.GetWordCount;

    if BigNumberWordExpand(Dst, WordCount) = nil then
    begin
      Result := nil;
      Exit;
    end;

    A := PLongWordArray(Dst.D);
    B := PLongWordArray(Src.D);

    Result := Dst;
    for I := 0 to WordCount - 1 do // �� Src �� Top - WordCount �� Top - 1 ��ֵ�� Dst �� 0 �� WordCount - 1
      A[I] := B[Src.Top - WordCount + I];

    Dst.Top := WordCount;
    Dst.Neg := Src.Neg;
  end;
end;

procedure BigNumberSwap(const Num1: TCnBigNumber; const Num2: TCnBigNumber);
var
  TmpD: PCnLongWord32;
  TmpTop, TmpDMax, TmpNeg: Integer;
begin
  TmpD := Num1.D;
  TmpTop := Num1.Top;
  TmpDMax := Num1.DMax;
  TmpNeg := Num1.Neg;

  Num1.D := Num2.D;
  Num1.Top := Num2.Top;
  Num1.DMax := Num2.DMax;
  Num1.Neg := Num2.Neg;

  Num2.D := TmpD;
  Num2.Top := TmpTop;
  Num2.DMax := TmpDMax;
  Num2.Neg := TmpNeg;
end;

// ============================ �ͽ����㶨�忪ʼ ===============================

// UInt64 �ķ�ʽ���� N ƽ��
procedure Sqr(var L: TCnLongWord32; var H: TCnLongWord32; N: TCnLongWord32); {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
var
  T: TUInt64;
begin
  T := UInt64Mul(N, N);
  // �޷��� 32 λ�������ֱ����ˣ��õ��� Int64 ��������õ���ֵ���÷�װ��������档
  L := TCnLongWord32(T) and BN_MASK2;
  H := TCnLongWord32(T shr BN_BITS2) and BN_MASK2;
end;

// UInt64 �ķ�ʽ���� A * B + R + C
procedure MulAdd(var R: TCnLongWord32; A: TCnLongWord32; B: TCnLongWord32; var C: TCnLongWord32); {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
var
  T: TUInt64;
begin
  T := UInt64Mul(A, B) + R + C;
  // �޷��� 32 λ�������ֱ����ˣ��õ��� Int64 ��������õ���ֵ���÷�װ��������档
  R := TCnLongWord32(T) and BN_MASK2;
  C := TCnLongWord32(T shr BN_BITS2) and BN_MASK2;
end;

// UInt64 �ķ�ʽ���� A * B + C
procedure Mul(var R: TCnLongWord32; A: TCnLongWord32; B: TCnLongWord32; var C: TCnLongWord32); {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
var
  T: TUInt64;
begin
  T := UInt64Mul(A, B) + C;
  // �޷��� 32 λ�������ֱ����ˣ��õ��� Int64 ��������õ���ֵ���÷�װ��������档
  R := TCnLongWord32(T) and BN_MASK2;
  C := TCnLongWord32(T shr BN_BITS2) and BN_MASK2;
end;

type
  TCnBitOperation = (boAnd, boOr, boXor);

// N �� TCnLongWord32 �����������ݽ���λ���㣬��� BP Ϊ nil����ʾ����������Ϊ 0 ����
procedure BigNumberBitOperation(RP: PLongWordArray; AP: PLongWordArray; BP: PLongWordArray;
  N: Integer; Op: TCnBitOperation);
begin
  if N <= 0 then
    Exit;

  if BP <> nil then
  begin
    while (N and (not 3)) <> 0 do
    begin
      case Op of
        boAnd:
          begin
            RP^[0] := TCnLongWord32((Int64(AP^[0]) and Int64(BP^[0])) and BN_MASK2);
            RP^[1] := TCnLongWord32((Int64(AP^[1]) and Int64(BP^[1])) and BN_MASK2);
            RP^[2] := TCnLongWord32((Int64(AP^[2]) and Int64(BP^[2])) and BN_MASK2);
            RP^[3] := TCnLongWord32((Int64(AP^[3]) and Int64(BP^[3])) and BN_MASK2);
          end;
        boOr:
          begin
            RP^[0] := TCnLongWord32((Int64(AP^[0]) or Int64(BP^[0])) and BN_MASK2);
            RP^[1] := TCnLongWord32((Int64(AP^[1]) or Int64(BP^[1])) and BN_MASK2);
            RP^[2] := TCnLongWord32((Int64(AP^[2]) or Int64(BP^[2])) and BN_MASK2);
            RP^[3] := TCnLongWord32((Int64(AP^[3]) or Int64(BP^[3])) and BN_MASK2);
          end;
        boXor:
          begin
            RP^[0] := TCnLongWord32((Int64(AP^[0]) xor Int64(BP^[0])) and BN_MASK2);
            RP^[1] := TCnLongWord32((Int64(AP^[1]) xor Int64(BP^[1])) and BN_MASK2);
            RP^[2] := TCnLongWord32((Int64(AP^[2]) xor Int64(BP^[2])) and BN_MASK2);
            RP^[3] := TCnLongWord32((Int64(AP^[3]) xor Int64(BP^[3])) and BN_MASK2);
          end;
      end;

      AP := PLongWordArray(TCnNativeInt(AP) + 4 * SizeOf(TCnLongWord32));
      BP := PLongWordArray(TCnNativeInt(BP) + 4 * SizeOf(TCnLongWord32));
      RP := PLongWordArray(TCnNativeInt(RP) + 4 * SizeOf(TCnLongWord32));

      Dec(N, 4);
    end;

    while N <> 0 do
    begin
      case Op of
        boAnd:
          RP^[0] := TCnLongWord32((Int64(AP^[0]) and Int64(BP^[0])) and BN_MASK2);
        boOr:
          RP^[0] := TCnLongWord32((Int64(AP^[0]) or Int64(BP^[0])) and BN_MASK2);
        boXor:
          RP^[0] := TCnLongWord32((Int64(AP^[0]) xor Int64(BP^[0])) and BN_MASK2);
      end;

      AP := PLongWordArray(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
      BP := PLongWordArray(TCnNativeInt(BP) + SizeOf(TCnLongWord32));
      RP := PLongWordArray(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
      Dec(N);
    end;
  end
  else // BP Ϊ nil���������鲻���������� 0 ����
  begin
    if Op = boAnd then
      FillChar(RP[0], N * SizeOf(TCnLongWord32), 0)
    else if Op in [boOr, boXor] then
      Move(AP[0], RP[0], N * SizeOf(TCnLongWord32));
  end;
end;

// ============================ �ͽ����㶨����� ===============================

{* Words ϵ���ڲ����㺯����ʼ}

procedure BigNumberAndWords(RP: PLongWordArray; AP: PLongWordArray; BP: PLongWordArray; N: Integer);
begin
  BigNumberBitOperation(RP, AP, BP, N, boAnd);
end;

procedure BigNumberOrWords(RP: PLongWordArray; AP: PLongWordArray; BP: PLongWordArray; N: Integer);
begin
  BigNumberBitOperation(RP, AP, BP, N, boOr);
end;

procedure BigNumberXorWords(RP: PLongWordArray; AP: PLongWordArray; BP: PLongWordArray; N: Integer);
begin
  BigNumberBitOperation(RP, AP, BP, N, boXor);
end;

function BigNumberAddWords(RP: PLongWordArray; AP: PLongWordArray; BP: PLongWordArray; N: Integer): TCnLongWord32;
var
  LL: Int64;
begin
  Result := 0;
  if N <= 0 then
    Exit;

  LL := 0;
  while (N and (not 3)) <> 0 do
  begin
    LL := LL + Int64(AP^[0]) + Int64(BP^[0]);
    RP^[0] := TCnLongWord32(LL) and BN_MASK2;
    LL := LL shr BN_BITS2;

    LL := LL + Int64(AP^[1]) + Int64(BP^[1]);
    RP^[1] := TCnLongWord32(LL) and BN_MASK2;
    LL := LL shr BN_BITS2;

    LL := LL + Int64(AP^[2]) + Int64(BP^[2]);
    RP^[2] := TCnLongWord32(LL) and BN_MASK2;
    LL := LL shr BN_BITS2;

    LL := LL + Int64(AP^[3]) + Int64(BP^[3]);
    RP^[3] := TCnLongWord32(LL) and BN_MASK2;
    LL := LL shr BN_BITS2;

    AP := PLongWordArray(TCnNativeInt(AP) + 4 * SizeOf(TCnLongWord32));
    BP := PLongWordArray(TCnNativeInt(BP) + 4 * SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + 4 * SizeOf(TCnLongWord32));

    Dec(N, 4);
  end;

  while N <> 0 do
  begin
    LL := LL + Int64(AP^[0]) + Int64(BP^[0]);
    RP^[0] := TCnLongWord32(LL) and BN_MASK2;
    LL := LL shr BN_BITS2;

    AP := PLongWordArray(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    BP := PLongWordArray(TCnNativeInt(BP) + SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
    Dec(N);
  end;
  Result := TCnLongWord32(LL);
end;

function BigNumberSubWords(RP: PLongWordArray; AP: PLongWordArray; BP: PLongWordArray; N: Integer): TCnLongWord32;
var
  T1, T2, C: TCnLongWord32;
begin
  Result := 0;
  if N <= 0 then
    Exit;

  C := 0;
  while (N and (not 3)) <> 0 do
  begin
    T1 := AP^[0];
    T2 := BP^[0];
    RP^[0] := (T1 - T2 - C) and BN_MASK2;
    if T1 <> T2 then
      if T1 < T2 then C := 1 else C := 0;

    T1 := AP^[1];
    T2 := BP^[1];
    RP^[1] := (T1 - T2 - C) and BN_MASK2;
    if T1 <> T2 then
      if T1 < T2 then C := 1 else C := 0;

    T1 := AP^[2];
    T2 := BP^[2];
    RP^[2] := (T1 - T2 - C) and BN_MASK2;
    if T1 <> T2 then
      if T1 < T2 then C := 1 else C := 0;

    T1 := AP^[3];
    T2 := BP^[3];
    RP^[3] := (T1 - T2 - C) and BN_MASK2;
    if T1 <> T2 then
      if T1 < T2 then C := 1 else C := 0;

    AP := PLongWordArray(TCnNativeInt(AP) + 4 * SizeOf(TCnLongWord32));
    BP := PLongWordArray(TCnNativeInt(BP) + 4 * SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + 4 * SizeOf(TCnLongWord32));

    Dec(N, 4);
  end;

  while N <> 0 do
  begin
    T1 := AP^[0];
    T2 := BP^[0];
    RP^[0] := (T1 - T2 - C) and BN_MASK2;
    if T1 <> T2 then
      if T1 < T2 then C := 1 else C := 0;

    AP := PLongWordArray(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    BP := PLongWordArray(TCnNativeInt(BP) + SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
    Dec(N);
  end;
  Result := C;
end;

function BigNumberMulAddWords(RP: PLongWordArray; AP: PLongWordArray; N: Integer; W: TCnLongWord32): TCnLongWord32;
begin
  Result := 0;
  if N <= 0 then
    Exit;

  while (N and (not 3)) <> 0 do
  begin
    MulAdd(RP^[0], AP^[0], W, Result);
    MulAdd(RP^[1], AP^[1], W, Result);
    MulAdd(RP^[2], AP^[2], W, Result);
    MulAdd(RP^[3], AP^[3], W, Result);

    AP := PLongWordArray(TCnNativeInt(AP) + 4 * SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + 4 * SizeOf(TCnLongWord32));
    Dec(N, 4);
  end;

  while N <> 0 do
  begin
    MulAdd(RP^[0], AP^[0], W, Result);
    AP := PLongWordArray(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
    Dec(N);
  end;
end;

// AP ָ��� N �����ֶ����� W������ĵ� N λ�� RP �У���λ�ŷ���ֵ
function BigNumberMulWords(RP: PLongWordArray; AP: PLongWordArray; N: Integer; W: TCnLongWord32): TCnLongWord32;
begin
  Result := 0;
  if N <= 0 then
    Exit;

  while (N and (not 3)) <> 0 do
  begin
    Mul(RP^[0], AP^[0], W, Result);
    Mul(RP^[1], AP^[1], W, Result);
    Mul(RP^[2], AP^[2], W, Result);
    Mul(RP^[3], AP^[3], W, Result);

    AP := PLongWordArray(TCnNativeInt(AP) + 4 * SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + 4 * SizeOf(TCnLongWord32));

    Dec(N, 4);
  end;

  while N <> 0 do
  begin
    Mul(RP^[0], AP^[0], W, Result);

    AP := PLongWordArray(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + SizeOf(TCnLongWord32));

    Dec(N);
  end;
end;

procedure BigNumberSqrWords(RP: PLongWordArray; AP: PLongWordArray; N: Integer);
begin
  if N = 0 then
    Exit;

  while (N and (not 3)) <> 0 do
  begin
    Sqr(RP^[0], RP^[1], AP^[0]);
    Sqr(RP^[2], RP^[3], AP^[1]);
    Sqr(RP^[4], RP^[5], AP^[2]);
    Sqr(RP^[6], RP^[7], AP^[3]);

    AP := PLongWordArray(TCnNativeInt(AP) + 4 * SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + 8 * SizeOf(TCnLongWord32));
    Dec(N, 4);
  end;

  while N <> 0 do
  begin
    Sqr(RP^[0], RP^[1], AP^[0]);
    AP := PLongWordArray(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    RP := PLongWordArray(TCnNativeInt(RP) + 2 * SizeOf(TCnLongWord32));
    Dec(N);
  end;
end;

// 64 λ���������� 32 λ�����������̣�Result := H L div D�������̵ĸ� 32 λ
// ���Ҫ��֤ D �����λΪ 1���̵ĸ� 32 λ�Ż�Ϊ 0���˺������òŲ���������� 32 λ�²ſ����� DIV ָ���Ż�
function InternalDivWords(H: TCnLongWord32; L: TCnLongWord32; D: TCnLongWord32): TCnLongWord32;
begin
  if D = 0 then
  begin
    Result := BN_MASK2;
    Exit;
  end;

{$IFDEF CPUX64}
  Result := TCnLongWord32(((UInt64(H) shl 32) or UInt64(L)) div UInt64(D));
{$ELSE}
  Result := 0;
  asm
    MOV EAX, L
    MOV EDX, H
    DIV ECX       // DIV ò�Ƶ��� DIVL������Ż�������� _lludiv �ĺ�ʱ���� 20%
    MOV Result, EAX
  end;
//  asm
//    PUSH 0
//    PUSH D
//    MOV EAX, L
//    MOV EDX, H
//    CALL System.@_lludiv;
//    // Delphi ������ʵ�ֵ� 64 λ�޷��ų������������Ҫ��
//    // Dividend(EAX(lo):EDX(hi)), Divisor([ESP+8](hi):[ESP+4](lo))
//    MOV Result, EAX
//  end;
{$ENDIF}
end;

{*  Words ϵ���ڲ����㺯������}

function BigNumberAnd(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
var
  Max, Min, Dif: Integer;
  AP, BP, RP: PCnLongWord32;
  A, B, Tmp: TCnBigNumber;
begin
  Result := False;

  A := Num1;
  B := Num2;
  if A.Top < B.Top then
  begin
    Tmp := A;
    A := B;
    B := Tmp;
  end;

  Max := A.Top;
  Min := B.Top;
  Dif := Max - Min;

  if BigNumberWordExpand(Res, Max) = nil then
    Exit;

  Res.Top := Max;
  AP := PCnLongWord32(A.D);
  BP := PCnLongWord32(B.D);
  RP := PCnLongWord32(Res.D);

  BigNumberAndWords(PLongWordArray(RP), PLongWordArray(AP), PLongWordArray(BP), Min);

  // AP ���ĺ�ͷ���� Dif һ��û�д�����Ҫ���ɺ� 0 һ������
  Inc(AP, Min);
  Inc(RP, Min);
  BigNumberAndWords(PLongWordArray(RP), PLongWordArray(AP), nil, Dif);

  BigNumberCorrectTop(Res);
  Result := True;
end;

function BigNumberOr(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
var
  Max, Min, Dif: Integer;
  AP, BP, RP: PCnLongWord32;
  A, B, Tmp: TCnBigNumber;
begin
  Result := False;

  A := Num1;
  B := Num2;
  if A.Top < B.Top then
  begin
    Tmp := A;
    A := B;
    B := Tmp;
  end;

  Max := A.Top;
  Min := B.Top;
  Dif := Max - Min;

  if BigNumberWordExpand(Res, Max) = nil then
    Exit;

  Res.Top := Max;
  AP := PCnLongWord32(A.D);
  BP := PCnLongWord32(B.D);
  RP := PCnLongWord32(Res.D);

  BigNumberOrWords(PLongWordArray(RP), PLongWordArray(AP), PLongWordArray(BP), Min);

  // AP ���ĺ�ͷ���� Dif һ��û�д�����Ҫ���ɺ� 0 һ������
  Inc(AP, Min);
  Inc(RP, Min);
  BigNumberOrWords(PLongWordArray(RP), PLongWordArray(AP), nil, Dif);

  BigNumberCorrectTop(Res);
  Result := True;
end;

function BigNumberXor(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
var
  Max, Min, Dif: Integer;
  AP, BP, RP: PCnLongWord32;
  A, B, Tmp: TCnBigNumber;
begin
  Result := False;

  A := Num1;
  B := Num2;
  if A.Top < B.Top then
  begin
    Tmp := A;
    A := B;
    B := Tmp;
  end;

  Max := A.Top;
  Min := B.Top;
  Dif := Max - Min;

  if BigNumberWordExpand(Res, Max) = nil then
    Exit;

  Res.Top := Max;
  AP := PCnLongWord32(A.D);
  BP := PCnLongWord32(B.D);
  RP := PCnLongWord32(Res.D);

  BigNumberXorWords(PLongWordArray(RP), PLongWordArray(AP), PLongWordArray(BP), Min);

  // AP ���ĺ�ͷ���� Dif һ��û�д�����Ҫ���ɺ� 0 һ������
  Inc(AP, Min);
  Inc(RP, Min);
  BigNumberXorWords(PLongWordArray(RP), PLongWordArray(AP), nil, Dif);

  BigNumberCorrectTop(Res);
  Result := True;
end;

function BigNumberUnsignedAdd(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
var
  Max, Min, Dif: Integer;
  AP, BP, RP: PCnLongWord32;
  Carry, T1, T2: TCnLongWord32;
  A, B, Tmp: TCnBigNumber;
begin
  Result := False;

  A := Num1;
  B := Num2;
  if A.Top < B.Top then
  begin
    Tmp := A;
    A := B;
    B := Tmp;
  end;

  Max := A.Top;
  Min := B.Top;
  Dif := Max - Min;

  if BigNumberWordExpand(Res, Max + 1) = nil then
    Exit;

  Res.Top := Max;
  AP := PCnLongWord32(A.D);
  BP := PCnLongWord32(B.D);
  RP := PCnLongWord32(Res.D);

  Carry := BigNumberAddWords(PLongWordArray(RP), PLongWordArray(AP), PLongWordArray(BP), Min);

  AP := PCnLongWord32(TCnNativeInt(AP) + Min * SizeOf(TCnLongWord32));
  RP := PCnLongWord32(TCnNativeInt(RP) + Min * SizeOf(TCnLongWord32));

  if Carry <> 0 then
  begin
    while Dif <> 0 do
    begin
      Dec(Dif);
      T1 := AP^;
      AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
      T2 := (T1 + 1) and BN_MASK2;

      RP^ := T2;
      RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));

      if T2 <> 0 then
      begin
        Carry := 0;
        Break;
      end;
    end;

    if Carry <> 0 then
    begin
      RP^ := 1;
      Inc(Res.Top);
    end;
  end;

  if (Dif <> 0) and (RP <> AP) then
  begin
    while Dif <> 0 do
    begin
      Dec(Dif);
      RP^ := AP^;
      AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
      RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
    end;
  end;

  Res.Neg := 0;
  Result := True;
end;

function BigNumberUnsignedSub(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
var
  Max, Min, Dif, I: Integer;
  AP, BP, RP: PCnLongWord32;
  Carry, T1, T2: TCnLongWord32;
begin
  Result := False;

  Max := Num1.Top;
  Min := Num2.Top;
  Dif := Max - Min;

  if Dif < 0 then
    Exit;

  if BigNumberWordExpand(Res, Max) = nil then
    Exit;

  AP := PCnLongWord32(Num1.D);
  BP := PCnLongWord32(Num2.D);
  RP := PCnLongWord32(Res.D);

  Carry := 0;
  for I := Min downto 1 do
  begin
    T1 := AP^;
    T2 := BP^;
    AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    BP := PCnLongWord32(TCnNativeInt(BP) + SizeOf(TCnLongWord32));
    if Carry <> 0 then
    begin
      if T1 <= T2 then
        Carry := 1
      else
        Carry := 0;
      T1 := (T1 - T2 - 1) and BN_MASK2;
    end
    else
    begin
      if T1 < T2 then
        Carry := 1
      else
        Carry := 0;
      T1 := (T1 - T2) and BN_MASK2;
    end;
    RP^ := T1 and BN_MASK2;
    RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
  end;

  if Carry <> 0 then
  begin
    if Dif = 0 then  // Error! Num1 < Num2
      Exit;

    while Dif <> 0 do
    begin
      Dec(Dif);
      T1 := AP^;
      AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
      T2 := (T1 - 1) and BN_MASK2;

      RP^ := T2;
      RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
      if T1 <> 0 then
        Break;
    end;
  end;

  if RP <> AP then
  begin
    while True do
    begin
      if Dif = 0 then Break;
      Dec(Dif);
      RP^ := AP^;
      AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
      RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));

      if Dif = 0 then Break;
      Dec(Dif);
      RP^ := AP^;
      AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
      RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));

      if Dif = 0 then Break;
      Dec(Dif);
      RP^ := AP^;
      AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
      RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));

      if Dif = 0 then Break;
      Dec(Dif);
      RP^ := AP^;
      AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
      RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
    end;
  end;

  Res.Top := Max;
  Res.Neg := 0;
  BigNumberCorrectTop(Res);
  Result := True;
end;

function BigNumberAdd(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
var
  A, B, Tmp: TCnBigNumber;
  Neg: Integer;
begin
  Result := False;

  Neg := Num1.Neg;
  A := Num1;
  B := Num2;

  if Neg <> Num2.Neg then // One is negative
  begin
    if Neg <> 0 then
    begin
      Tmp := A;
      A := B;
      B := Tmp;
    end;

    // A is positive and B is negative
    if BigNumberUnsignedCompare(A, B) < 0 then
    begin
      if not BigNumberUnsignedSub(Res, B, A) then
        Exit;
      Res.Neg := 1;
    end
    else
    begin
      if not BigNumberUnsignedSub(Res, A, B) then
        Exit;
      Res.Neg := 0;
    end;
    Result := True;
    Exit;
  end;

  Result := BigNumberUnsignedAdd(Res, A, B);
  Res.Neg := Neg;
end;

function BigNumberSub(const Res: TCnBigNumber; const Num1: TCnBigNumber;
  const Num2: TCnBigNumber): Boolean;
var
  A, B, Tmp: TCnBigNumber;
  Max, Add, Neg: Integer;
begin
  Result := False;
  Add := 0;
  Neg := 0;
  A := Num1;
  B := Num2;

  if A.Neg <> 0 then
  begin
    if B.Neg <> 0 then
    begin
      Tmp := A;
      A := B;
      B := Tmp;
    end
    else // A Negative B Positive
    begin
      Add := 1;
      Neg := 1;
    end;
  end
  else
  begin
    if B.Neg <> 0 then // A Positive B Negative
    begin
      Add := 1;
      Neg := 0;
    end;
  end;

  if Add = 1 then
  begin
    if not BigNumberUnsignedAdd(Res, A, B) then
      Exit;

    Res.Neg := Neg;
    Result := True;
    Exit;
  end;

  if A.Top > B.Top then
    Max := A.Top
  else
    Max := B.Top;

  if BigNumberWordExpand(Res, Max) = nil then
    Exit;

  if BigNumberUnsignedCompare(A, B) < 0 then
  begin
    if not BigNumberUnsignedSub(Res, B, A) then
      Exit;
    Res.Neg := 1;
  end
  else
  begin
    if not BigNumberUnsignedSub(Res, A, B) then
      Exit;
    Res.Neg := 0;
  end;
  Result := True;
end;

function BigNumberShiftLeftOne(const Res: TCnBigNumber; const Num: TCnBigNumber): Boolean;
var
  RP, AP: PCnLongWord32;
  I: Integer;
  T, C: TCnLongWord32;
begin
  Result := False;

  if Res <> Num then
  begin
    Res.Neg := Num.Neg;
    if BigNumberWordExpand(Res, Num.Top + 1) = nil then
      Exit;

    Res.Top := Num.Top;
  end
  else
  begin
    if BigNumberWordExpand(Res, Num.Top + 1) = nil then
      Exit;
  end;

  AP := Num.D;
  RP := Res.D;
  C := 0;
  for I := 0 to Num.Top - 1 do
  begin
    T := AP^;
    AP := PCnLongWord32(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    RP^ := ((T shl 1) or C) and BN_MASK2;
    RP := PCnLongWord32(TCnNativeInt(RP) + SizeOf(TCnLongWord32));

    if (T and BN_TBIT) <> 0 then
      C := 1
    else
      C := 0;
  end;

  if C <> 0 then
  begin
    RP^ := 1;
    Inc(Res.Top);
  end;
  Result := True;
end;

function BigNumberShiftRightOne(const Res: TCnBigNumber; const Num: TCnBigNumber): Boolean;
var
  RP, AP: PCnLongWord32;
  I, J: Integer;
  T, C: TCnLongWord32;
begin
  Result := False;
  if BigNumberIsZero(Num) then
  begin
    BigNumberSetZero(Res);
    Result := True;
    Exit;
  end;

  I := Num.Top;
  AP := Num.D;

  if PLongWordArray(AP)^[I - 1] = 1 then
    J := I - 1
  else
    J := I;

  if Res <> Num then
  begin
    if BigNumberWordExpand(Res, J) = nil then
      Exit;
    Res.Neg := Num.Neg;
  end;

  RP := Res.D;
  Dec(I);
  T := PLongWordArray(AP)^[I];

  if (T and 1) <> 0 then
    C := BN_TBIT
  else
    C := 0;

  T := T shr 1;
  if T <> 0 then
    PLongWordArray(RP)^[I] := T;

  while I > 0 do
  begin
    Dec(I);
    T := PLongWordArray(AP)^[I];
    PLongWordArray(RP)^[I] := ((T shr 1) and BN_MASK2) or C;

    if (T and 1) <> 0 then
      C := BN_TBIT
    else
      C := 0;
  end;

  Res.Top := J;
  Result := True;
end;

function BigNumberShiftLeft(const Res: TCnBigNumber; const Num: TCnBigNumber;
  N: Integer): Boolean;
var
  I, NW, LB, RB: Integer;
  L: TCnLongWord32;
  T, F: PLongWordArray;
begin
  Result := False;
  Res.Neg := Num.Neg;
  NW := N div BN_BITS2;

  if BigNumberWordExpand(Res, Num.Top + NW + 1) = nil then
    Exit;

  LB := N mod BN_BITS2;
  RB := BN_BITS2 - LB;

  F := PLongWordArray(Num.D);
  T := PLongWordArray(Res.D);

  T^[Num.Top + NW] := 0;
  if LB = 0 then
  begin
    for I := Num.Top - 1 downto 0 do
      T^[NW + I] := F^[I];
  end
  else
  begin
    for I := Num.Top - 1 downto 0 do
    begin
      L := F^[I];
      T^[NW + I + 1] := T^[NW + I + 1] or ((L shr RB) and BN_MASK2);
      T^[NW + I] := (L shl LB) and BN_MASK2;
    end;
  end;

  FillChar(Pointer(T)^, NW * SizeOf(TCnLongWord32), 0);
  Res.Top := Num.Top + NW + 1;
  BigNumberCorrectTop(Res);
  Result := True;
end;

function BigNumberShiftRight(const Res: TCnBigNumber; const Num: TCnBigNumber;
  N: Integer): Boolean;
var
  I, J, NW, LB, RB: Integer;
  L, Tmp: TCnLongWord32;
  T, F: PLongWordArray;
begin
  Result := False;

  NW := N div BN_BITS2;
  RB := N mod BN_BITS2;
  LB := BN_BITS2 - RB;

  if (NW >= Num.Top) or (Num.Top = 0) then
  begin
    BigNumberSetZero(Res);
    Result := True;
    Exit;
  end;

  I := (BigNumberGetBitsCount(Num) - N + (BN_BITS2 - 1)) div BN_BITS2;
  if Res <> Num then
  begin
    Res.Neg := Num.Neg;
    if BigNumberWordExpand(Res, I) = nil then
      Exit;
  end
  else
  begin
    if N = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;

  F := PLongWordArray(TCnNativeInt(Num.D) + NW * SizeOf(TCnLongWord32));
  T := PLongWordArray(Res.D);
  J := Num.Top - NW;
  Res.Top := I;

  if RB = 0 then
  begin
    for I := J downto 1 do
    begin
      T^[0] := F^[0];
      F := PLongWordArray(TCnNativeInt(F) + SizeOf(TCnLongWord32));
      T := PLongWordArray(TCnNativeInt(T) + SizeOf(TCnLongWord32));
    end;
  end
  else
  begin
    L := F^[0];
    F := PLongWordArray(TCnNativeInt(F) + SizeOf(TCnLongWord32));
    for I := J - 1 downto 1 do
    begin
      Tmp := (L shr RB) and BN_MASK2;
      L := F^[0];
      T^[0] := (Tmp or (L shl LB)) and BN_MASK2;

      F := PLongWordArray(TCnNativeInt(F) + SizeOf(TCnLongWord32));
      T := PLongWordArray(TCnNativeInt(T) + SizeOf(TCnLongWord32));
    end;

    L := (L shr RB) and BN_MASK2;
    if L <> 0 then
      T^[0] := L;
  end;
  Result := True;
end;

{* ������ Word ����ϵ�к�����ʼ}

function BigNumberAddWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
var
  I: Integer;
  L: TCnLongWord32;
begin
  Result := False;
  W := W and BN_MASK2;

  if W = 0 then
  begin
    Result := True;
    Exit;
  end;

  if BigNumberIsZero(Num) then
  begin
    Result := BigNumberSetWord(Num, W);
    Exit;
  end;

  if Num.Neg <> 0 then // �����ü���
  begin
    Num.Neg := 0;
    Result := BigNumberSubWord(Num, W);
    if not BigNumberIsZero(Num) then
      Num.Neg := 1 - Num.Neg;
    Exit;
  end;

  I := 0;
  while (W <> 0) and (I < Num.Top) do
  begin
    L := (PLongWordArray(Num.D)^[I] + W) and BN_MASK2;
    PLongWordArray(Num.D)^[I] := L;
    if W > L then // ����ȼ���С��˵��������߽�λ�ˣ��ѽ�λ�ø� W��������
      W := 1
    else
      W := 0;
    Inc(I);
  end;

  if (W <> 0) and (I = Num.Top) then // �����λ��Ȼ���������λ
  begin
    if BigNumberWordExpand(Num, Num.Top + 1) = nil then
      Exit;
    Inc(Num.Top);
    PLongWordArray(Num.D)^[I] := W;
  end;
  Result := True;
end;

function BigNumberSubWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
var
  I: Integer;
begin
  W := W and BN_MASK2;

  if W = 0 then
  begin
    Result := True;
    Exit;
  end;

  if BigNumberIsZero(Num) then
  begin
    Result := BigNumberSetWord(Num, W);
    if Result then
      BigNumberSetNegative(Num, True);
    Exit;
  end;

  if Num.Neg <> 0 then
  begin
    Num.Neg := 0;
    Result := BigNumberAddWord(Num, W);
    Num.Neg := 1;
    Exit;
  end;

  if (Num.Top = 1) and (PLongWordArray(Num.D)^[0] < W) then // ������
  begin
    PLongWordArray(Num.D)^[0] := W - PLongWordArray(Num.D)^[0];
    Num.Neg := 1;
    Result := True;
    Exit;
  end;

  I := 0;
  while True do
  begin
    if PLongWordArray(Num.D)^[I] >= W then // ����ֱ�Ӽ�
    begin
      PLongWordArray(Num.D)^[I] := PLongWordArray(Num.D)^[I] - W;
      Break;
    end
    else
    begin
      PLongWordArray(Num.D)^[I] := (PLongWordArray(Num.D)^[I] - W) and BN_MASK2;
      Inc(I);
      W := 1;  // �������н�λ
    end;
  end;

  if (PLongWordArray(Num.D)^[I] = 0) and (I = Num.Top - 1) then
    Dec(Num.Top);
  Result := True;
end;

function BigNumberMulWord(const Num: TCnBigNumber; W: TCnLongWord32): Boolean;
var
  L: TCnLongWord32;
begin
  Result := False;
  W := W and BN_MASK2;
  if Num.Top <> 0 then
  begin
    if W = 0 then
      BigNumberSetZero(Num)
    else
    begin
      L := BigNumberMulWords(PLongWordArray(Num.D), PLongWordArray(Num.D), Num.Top, W);
      if L <> 0 then
      begin
        if BigNumberWordExpand(Num, Num.Top + 1) = nil then
          Exit;
        PLongWordArray(Num.D)^[Num.Top] := L;
        Inc(Num.Top);
      end;
    end;
  end;
  Result := True;
end;

function BigNumberModWord(const Num: TCnBigNumber; W: TCnLongWord32): TCnLongWord32;
var
  I: Integer;
begin
  if W = 0 then
  begin
    Result := TCnLongWord32(-1);
    Exit;
  end;

  Result := 0;
  W := W and BN_MASK2;
  for I := Num.Top - 1 downto 0 do
  begin
    Result := ((Result shl BN_BITS4) or ((PLongWordArray(Num.D)^[I] shr BN_BITS4) and BN_MASK2l)) mod W;
    Result := ((Result shl BN_BITS4) or (PLongWordArray(Num.D)^[I] and BN_MASK2l)) mod W;
  end;
end;

function BigNumberDivWord(const Num: TCnBigNumber; W: TCnLongWord32): TCnLongWord32;
var
  I, J: Integer;
  L, D: TCnLongWord32;
begin
  W := W and BN_MASK2;
  if W = 0 then
  begin
    Result := TCnLongWord32(-1);
    Exit;
  end;

  Result := 0;
  if Num.Top = 0 then
    Exit;

  J := BN_BITS2 - BigNumberGetWordBitsCount(W);

  W := W shl J; // ��֤ W ���λΪ 1
  if not BigNumberShiftLeft(Num, Num, J) then
  begin
    Result := TCnLongWord32(-1);
    Exit;
  end;

  for I := Num.Top - 1 downto 0 do
  begin
    L := PLongWordArray(Num.D)^[I];
    D := InternalDivWords(Result, L, W); // W ��֤�����λΪ 1��������� 32 λ
    Result := (L - ((D * W) and BN_MASK2)) and BN_MASK2;

    PLongWordArray(Num.D)^[I] := D;
  end;

  if (Num.Top > 0) and (PLongWordArray(Num.D)^[Num.Top - 1] = 0) then
    Dec(Num.Top);
  Result := Result shr J;
end;

{* ������ Word ����ϵ�к�������}

function BigNumberToString(const Num: TCnBigNumber): string;
var
  I, J, V, Z: Integer;
begin
  Result := '';
  if BigNumberIsZero(Num) then
  begin
    Result := '0';
    Exit;
  end;
  if BigNumberIsNegative(Num) then
    Result := '-';

  Z := 0;
  for I := Num.Top - 1 downto 0 do
  begin
    J := BN_BITS2 - 4;
    while J >= 0 do
    begin
      V := ((PLongWordArray(Num.D)^[I]) shr TCnLongWord32(J)) and $0F;
      if (Z <> 0) or (V <> 0) then
      begin
        Result := Result + Hex[V + 1];
        Z := 1;
      end;
      Dec(J, 4);
    end;
  end;
end;

function BigNumberToHex(const Num: TCnBigNumber; FixedLen: Integer): string;
var
  I, J, V, Z: Integer;
begin
  Result := '';
  if BigNumberIsZero(Num) then
  begin
    if FixedLen <= 0 then
      Result := '0'
    else
      Result := StringOfChar('0', FixedLen * 2);
    Exit;
  end;

  Z := 0;
  for I := Num.Top - 1 downto 0 do
  begin
    J := BN_BITS2 - 8;
    while J >= 0 do
    begin
      V := ((PLongWordArray(Num.D)^[I]) shr TCnLongWord32(J)) and $FF;
      if (Z <> 0) or (V <> 0) then
      begin
        Result := Result + Hex[(V shr 4) + 1];
        Result := Result + Hex[(V and $0F) + 1];
        Z := 1;
      end;
      Dec(J, 8);
    end;
  end;

  if FixedLen * 2 > Length(Result) then
    Result := StringOfChar('0', FixedLen * 2 - Length(Result)) + Result;

  if BigNumberIsNegative(Num) then
    Result := '-' + Result;
end;

function BigNumberSetHex(const Buf: AnsiString; const Res: TCnBigNumber): Boolean;
var
  P: PAnsiChar;
  Neg, H, M, J, I, K, C: Integer;
  L: TCnLongWord32;
begin
  Result := False;
  if (Buf = '') or (Res = nil) then
    Exit;

  P := @Buf[1];
  if P^ = '-' then
  begin
    Neg := 1;
    Inc(P);
  end
  else
    Neg := 0;

  // ����Ч����
  I := 0;
  while PAnsiChar(TCnNativeInt(P) + I)^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
    Inc(I);

  BigNumberSetZero(Res);

  if BigNumberWordExpand(Res, I * 4) = nil then
  begin
    BigNumberFree(Res);
    Exit;
  end;

  J := I;
  H := 0;
  while J > 0 do
  begin
    L := 0;
    if BN_BYTES * 2 <= J then
      M := BN_BYTES * 2
    else
      M := J;

    while True do
    begin
      C := Ord(PAnsiChar(TCnNativeInt(P) + J - M)^);
      if (C >= Ord('0')) and (C <= Ord('9')) then
        K := C - Ord('0')
      else if (C >= Ord('a')) and (C <= Ord('f')) then
        K := C - Ord('a') + 10
      else if (C >= Ord('A')) and (C <= Ord('F')) then
        K := C - Ord('A') + 10
      else
        K := 0;

      L := (L shl 4) or TCnLongWord32(K);

      Dec(M);
      if M <= 0 then
      begin
        PLongWordArray(Res.D)^[H] := L;
        Inc(H);
        Break;
      end;
    end;
    Dec(J, BN_BYTES * 2);
  end;

  Res.Top := H;
  BigNumberCorrectTop(Res);
  Res.Neg := Neg;
  Result := True;
end;

function BigNumberFromHex(const Buf: AnsiString): TCnBigNumber;
begin
  Result := BigNumberNew;
  if Result = nil then
    Exit;

  if not BigNumberSetHex(Buf, Result) then
  begin
    BigNumberFree(Result);
    Result := nil;
  end;
end;

function BigNumberToDec(const Num: TCnBigNumber): AnsiString;
var
  I, N, R, Len: Integer;
  BnData, LP: PCnLongWord32;
  T: TCnBigNumber;
  P: PAnsiChar;

  function BufRemain(Nu: Integer; Pt: PAnsiChar; Res: PAnsiChar): Integer;
  begin
    Result := Nu + 3 - (TCnNativeInt(Pt) - TCnNativeInt(Res));
  end;

begin
  Result := '';

  I := BigNumberGetBitsCount(Num) * 3;
  N := ((I div 10) + (I div 1000) + 1) + 1;

  BnData := nil;
  T := nil;
  try
    BnData := PCnLongWord32(GetMemory(((N div 9) + 1) * SizeOf(TCnLongWord32)));
    if BnData = nil then
      Exit;

    SetLength(Result, N + 3);
    FillChar(Result[1], Length(Result), 0);

    T := FLocalBigNumberPool.Obtain;
    if BigNumberCopy(T, Num) = nil then
      Exit;

    P := @(Result[1]);
    LP := BnData;

    if BigNumberIsZero(T) then
    begin
      P^ := '0';
      Inc(P);
      P^ := Chr(0);
    end
    else
    begin
      if BigNumberIsNegative(T) then
      begin
        P^ := '-';
        Inc(P);
      end;

      while not BigNumberIsZero(T) do
      begin
        LP^ := BigNumberDivWord(T, BN_DEC_CONV);
        LP := PCnLongWord32(TCnNativeInt(LP) + SizeOf(TCnLongWord32));
      end;
      LP := PCnLongWord32(TCnNativeInt(LP) - SizeOf(TCnLongWord32));

      R := BufRemain(N, P, @(Result[1]));
{$IFDEF UNICODE}
      AnsiStrings.AnsiFormatBuf(P^, R, AnsiString(BN_DEC_FMT), Length(BN_DEC_FMT), [LP^]);
{$ELSE}
      FormatBuf(P^, R, BN_DEC_FMT, Length(BN_DEC_FMT), [LP^]);
{$ENDIF}
      while P^ <> #0 do
        Inc(P);
      while LP <> BnData do
      begin
        LP := PCnLongWord32(TCnNativeInt(LP) - SizeOf(TCnLongWord32));
        R := BufRemain(N, P, @(Result[1]));
{$IFDEF UNICODE}
        AnsiStrings.AnsiFormatBuf(P^, R, AnsiString(BN_DEC_FMT2), Length(BN_DEC_FMT2), [LP^]);
{$ELSE}
        FormatBuf(P^, R, BN_DEC_FMT2, Length(BN_DEC_FMT2), [LP^]);
{$ENDIF}
        while P^ <> #0 do
          Inc(P);
      end;
    end;
  finally
    if BnData <> nil then
      FreeMemory(BnData);

    FLocalBigNumberPool.Recycle(T);
  end;

  Len := SysUtils.StrLen(PAnsiChar(Result));
  if Len >= 0 then
    SetLength(Result, Len); // ȥ��β������� #0
end;

function BigNumberSetDec(const Buf: AnsiString; const Res: TCnBigNumber): Boolean;
var
  P: PAnsiChar;
  Neg, J, I: Integer;
  L: TCnLongWord32;
begin
  Result := False;
  if (Buf = '') or (Res = nil) then
    Exit;

  P := @Buf[1];
  if P^ = '-' then
  begin
    Neg := 1;
    Inc(P);
  end
  else
    Neg := 0;

  // ����Ч����
  I := 0;
  while PAnsiChar(TCnNativeInt(P) + I)^ in ['0'..'9'] do
    Inc(I);

  BigNumberSetZero(Res);

  if BigNumberWordExpand(Res, I * 4) = nil then
  begin
    BigNumberFree(Res);
    Exit;
  end;

  J := 9 - (I mod 9);
  if J = 9 then
    J := 0;
  L := 0;

  while P^ <> #0 do
  begin
    L := L * 10;
    L := L + Ord(P^) - Ord('0');
    Inc(P);
    Inc(J);
    if J = 9 then
    begin
      BigNumberMulWord(Res, BN_DEC_CONV);
      BigNumberAddWord(Res, L);
      L := 0;
      J := 0;
    end;
  end;

  BigNumberCorrectTop(Res);
  Res.Neg := Neg;
  Result := True;
end;

function BigNumberFromDec(const Buf: AnsiString): TCnBigNumber;
begin
  Result := BigNumberNew;
  if Result = nil then
    Exit;

  if not BigNumberSetDec(Buf, Result) then
  begin
    BigNumberFree(Result);
    Result := nil;
  end;
end;

function BigNumberSetFloat(F: Extended; const Res: TCnBigNumber): Boolean;
var
  N: Boolean;
  E: Integer;
  M: TUInt64;
begin
  ExtractFloatExtended(F, N, E, M);

  BigNumberSetUInt64UsingInt64(Res, M);
  Res.SetNegative(N);

  E := E - 63;
  if E > 0 then
    Res.ShiftLeft(E)
  else
    Res.ShiftRight(-E);

  Result := True;
end;

function BigNumberGetFloat(const Num: TCnBigNumber): Extended;
var
  N: Boolean;
  E, B, K: Integer;
  M, T: TUInt64;
begin
  Result := 0;
  if not Num.IsZero then
  begin
    N := Num.IsNegative;

    B := Num.GetBitsCount;
    E := B - 1;

    if E > CN_EXTENDED_MAX_EXPONENT then
      raise ERangeError.Create(SCN_BN_FLOAT_EXP_RANGE_ERROR);

    if B <= 64 then
    begin
      M := PInt64Array(Num.D)^[0];

      if B < 64 then
        M := M shl (64 - B);
    end
    else // �� Top > 2����ֻ��ȡ��� 64 λ�� M ������ֻ������
    begin
      // (B - 1) div 64 �Ǹߵ�Ҫ���� 64 λ����ţ���ͷ�� B mod 64 ��λ
      K := (B - 1) div 64;
{$IFDEF SUPPORT_UINT64}
      T := TUInt64(PInt64Array(Num.D)^[K]);
{$ELSE}
      T := PInt64Array(Num.D)^[K];
{$ENDIF}
      K := B mod 64;
      if K > 0 then // T ��ֻ�е� K λ
        T := T shl (64 - K);

      M := T; // M �õ�һ����λ��

      if K > 0 then // Ҫ����һ�� M �ĵ�λ
      begin
        K := ((B - 1) div 64) - 1;
{$IFDEF SUPPORT_UINT64}
        T := TUInt64(PInt64Array(Num.D)^[K]);
{$ELSE}
        T := PInt64Array(Num.D)^[K];
{$ENDIF}
        K := 64 - (B mod 64); // Ҫ������� T �ĸ� K λ

        T := T shr (64 - K);
        M := M or T;
      end;
    end;

    CombineFloatExtended(N, E, M, Result);
  end;
end;

function BigNumberFromFloat(F: Extended): TCnBigNumber;
begin
  Result := BigNumberNew;
  if Result = nil then
    Exit;

  if not BigNumberSetFloat(F, Result) then
  begin
    BigNumberFree(Result);
    Result := nil;
  end;
end;

// Tmp should have 2 * N DWORDs
procedure BigNumberSqrNormal(R: PCnLongWord32; A: PCnLongWord32; N: Integer; Tmp: PCnLongWord32);
var
  I, J, Max: Integer;
  AP, RP: PLongWordArray;
begin
  Max := N * 2;
  AP := PLongWordArray(A);
  RP := PLongWordArray(R);
  RP^[0] := 0;
  RP^[Max - 1] := 0;

  RP := PLongWordArray(TCnNativeInt(RP) + SizeOf(TCnLongWord32));
  J := N - 1;

  if J > 0 then
  begin
    AP := PLongWordArray(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    RP^[J] := BigNumberMulWords(RP, AP, J, PLongWordArray(TCnNativeInt(AP) - SizeOf(TCnLongWord32))^[0]);
    RP := PLongWordArray(TCnNativeInt(RP) + 2 * SizeOf(TCnLongWord32));
  end;

  for I := N - 2 downto 1 do
  begin
    Dec(J);
    AP := PLongWordArray(TCnNativeInt(AP) + SizeOf(TCnLongWord32));
    RP^[J] := BigNumberMulAddWords(RP, AP, J, PLongWordArray(TCnNativeInt(AP) - SizeOf(TCnLongWord32))^[0]);
    RP := PLongWordArray(TCnNativeInt(RP) + 2 * SizeOf(TCnLongWord32));
  end;

  BigNumberAddWords(PLongWordArray(R), PLongWordArray(R), PLongWordArray(R), Max);
  BigNumberSqrWords(PLongWordArray(Tmp), PLongWordArray(A), N);
  BigNumberAddWords(PLongWordArray(R), PLongWordArray(R), PLongWordArray(Tmp), Max);
end;

function BigNumberSqr(const Res: TCnBigNumber; const Num: TCnBigNumber): Boolean;
var
  Max, AL: Integer;
  Tmp, RR: TCnBigNumber;
  T: array[0..15] of TCnLongWord32;
  IsFromPool: Boolean;
begin
  Result := False;
  AL := Num.Top;
  if AL <= 0 then
  begin
    Res.Top := 0;
    Res.Neg := 0;
    Result := True;
    Exit;
  end;

  RR := nil;
  Tmp := nil;
  IsFromPool := False;

  try
    if Num <> Res then
      RR := Res
    else
    begin
      RR := FLocalBigNumberPool.Obtain;
      IsFromPool := True;
    end;

    Tmp := FLocalBigNumberPool.Obtain;
    if (RR = nil) or (Tmp = nil) then
      Exit;

    Max := 2 * AL;
    if BigNumberWordExpand(RR, Max) = nil then
      Exit;

    if AL = 4 then
    begin
      BigNumberSqrNormal(RR.D, Num.D, 4, @(T[0]));
    end
    else if AL = 8 then
    begin
      BigNumberSqrNormal(RR.D, Num.D, 8, @(T[0]));
    end
    else
    begin
      if BigNumberWordExpand(Tmp, Max) = nil then
        Exit;
      BigNumberSqrNormal(RR.D, Num.D, AL, Tmp.D);
    end;

    RR.Neg := 0;
    if PLongWordArray(Num.D)^[AL - 1] = (PLongWordArray(Num.D)^[AL - 1] and BN_MASK2l) then
      RR.Top := Max - 1
    else
      RR.Top := Max;

    if RR <> Res then
      BigNumberCopy(Res, RR);
    Result := True;
  finally
    if IsFromPool then
      FLocalBigNumberPool.Recycle(RR);
    FLocalBigNumberPool.Recycle(Tmp);
  end;
end;

function BigNumberSqrt(const Res: TCnBigNumber; const Num: TCnBigNumber): Boolean;
var
  U: TUInt64;
  BitLength, Shift: Integer;
  X, XNext: TCnBigNumber;
begin
  Result := False;
  if Num.IsZero then
  begin
    Res.SetZero;
    Result := True;
    Exit;
  end
  else if Num.IsNegative then
    Exit
  else if Num.Top <= 2 then
  begin
    U := BigNumberGetUInt64UsingInt64(Num);
    U := UInt64Sqrt(U);
    BigNumberSetUInt64UsingInt64(Res, U);
    Result := True;
    Exit;
  end
  else
  begin
    BitLength := Num.GetBitsCount;
    Shift := BitLength - 63;
    if (Shift and 1) <> 0 then  // �� 63 λ������������� 64��Ҳ����ż��λȡ�� 64 λ������λȡ�� 63 λ����ƽ��������
      Inc(Shift);

    X := nil;
    XNext := nil;

    try
      X := FLocalBigNumberPool.Obtain;
      XNext := FLocalBigNumberPool.Obtain;

      BigNumberCopy(X, Num);
      X.ShiftRight(Shift); // ȡ��ߵ� 64 λ�� 63 λ������ƽ����

      U := X.GetInt64;
      U := UInt64Sqrt(U);
      X.SetInt64(U);

      X.ShiftLeft(Shift shr 1); // X �ǹ����ƽ����

      // ţ�ٵ�����
      while True do
      begin
        // Xnext = (x + n/x)/2
        BigNumberDiv(XNext, nil, Num, X);
        BigNumberAdd(XNext, XNext, X);
        XNext.ShiftRightOne;

        if BigNumberCompare(XNext, X) = 0 then
        begin
          // ���� X ���������ֲ��ٱ仯ʱ���ǽ��
          BigNumberCopy(Res, X);
          Result := True;
          Exit;
        end;
        // X := XNext
        BigNumberCopy(X, XNext);
      end;
    finally
      FLocalBigNumberPool.Recycle(XNext);
      FLocalBigNumberPool.Recycle(X);
    end;
  end;
end;

function BigNumberRoot(const Res: TCnBigNumber; const Num: TCnBigNumber;
  Exponent: Integer): Boolean;
var
  I: Integer;
  X0, X1, T1, T2, T3: TCnBigBinary;
  C0, C1: TCnBigNumber;
  U: TUInt64;
begin
  Result := False;
  if (Exponent <= 0) or Num.IsNegative then
    Exit;

  if Num.IsOne or Num.IsZero then
  begin
    BigNumberCopy(Res, Num);
    Result := True;
    Exit;
  end
  else if Exponent = 2 then
    Result := BigNumberSqrt(Res, Num)
  else if Num.Top <= 2 then
  begin
    U := BigNumberGetUInt64UsingInt64(Num);
    U := UInt64NonNegativeRoot(U, Exponent);
    BigNumberSetUInt64UsingInt64(Res, U);
    Result := True;
    Exit;
  end
  else
  begin
    // ţ�ٵ��������
    I := Num.GetBitsCount + 1;  // �õ���Լ Log2 N ��ֵ
    I := (I div Exponent) + 1;

    X0 := nil;
    X1 := nil;
    T1 := nil;
    T2 := nil;
    T3 := nil;
    C0 := nil;
    C1 := nil;

    // ��ĶԷ�ûʹ�ã��ӳٵ��˴���ʼ��
    if FLocalBigBinaryPool = nil then
      FLocalBigBinaryPool := TCnBigBinaryPool.Create;

    try
      X0 := FLocalBigBinaryPool.Obtain;
      X1 := FLocalBigBinaryPool.Obtain;
      T1 := FLocalBigBinaryPool.Obtain;
      T2 := FLocalBigBinaryPool.Obtain;
      T3 := FLocalBigBinaryPool.Obtain;

      C0 := FLocalBigNumberPool.Obtain;
      C1 := FLocalBigNumberPool.Obtain;

      X0.SetOne;
      X0.ShiftLeft(I);                  // �õ�һ���ϴ�� X0 ֵ��Ϊ��ʼֵ

      repeat
        // X1 := X0 - (Power(X0, Exponent) - N) / (Exponent * Power(X0, Exponent - 1));
        BigBinaryCopy(T1, X0);
        T1.Power(Exponent);
        T2.SetBigNumber(Num);
        BigBinarySub(T1, T1, T2);             // �õ� Power(X0, Exponent) - N

        BigBinaryCopy(T2, X0);
        T2.Power(Exponent - 1);
        T2.MulWord(Exponent);                // �õ� Exponent * Power(X0, Exponent - 1)

        BigBinaryDiv(T1, T1, T2, 10);            // �õ��̣�����һ������
        BigBinarySub(X1, X0, T1);            // ��� X1

        // �õ� X0 �� X1 ���������ֲ��Ƚ�
        BigBinaryTruncTo(C0, X0);
        BigBinaryTruncTo(C1, X1);
        if BigNumberCompare(C0, C1) = 0 then
        begin
          // ������Ϊ X0 X1 �������ֲ������仯����Ϊ�ﵽ������
          BigNumberCopy(Res, C0);
          Result := True;
          Exit;
        end;

        BigBinaryCopy(X0, X1);
      until False;
    finally
      FLocalBigBinaryPool.Recycle(X1);
      FLocalBigBinaryPool.Recycle(X0);
      FLocalBigBinaryPool.Recycle(T3);
      FLocalBigBinaryPool.Recycle(T2);
      FLocalBigBinaryPool.Recycle(T1);

      FLocalBigNumberPool.Recycle(C1);
      FLocalBigNumberPool.Recycle(C0);
    end;
  end;
end;

procedure BigNumberMulNormal(R: PCnLongWord32; A: PCnLongWord32; NA: Integer; B: PCnLongWord32;
  NB: Integer);
var
  RR: PCnLongWord32;
  Tmp: Integer;
begin
  if NA < NB then
  begin
    Tmp := NA;
    NA := NB;
    NB := Tmp;

    RR := B;
    B := A;
    A := RR;
  end;

  RR := PCnLongWord32(TCnNativeInt(R) + NA * SizeOf(TCnLongWord32));
  if NB <= 0 then
  begin
    BigNumberMulWords(PLongWordArray(R), PLongWordArray(A), NA, 0);
    Exit;
  end
  else
    RR^ := BigNumberMulWords(PLongWordArray(R), PLongWordArray(A), NA, B^);

  while True do
  begin
    Dec(NB);
    if NB <=0 then
      Exit;
    RR := PCnLongWord32(TCnNativeInt(RR) + SizeOf(TCnLongWord32));
    R := PCnLongWord32(TCnNativeInt(R) + SizeOf(TCnLongWord32));
    B := PCnLongWord32(TCnNativeInt(B) + SizeOf(TCnLongWord32));

    RR^ := BigNumberMulAddWords(PLongWordArray(R), PLongWordArray(A), NA, B^);

    Dec(NB);
    if NB <=0 then
      Exit;
    RR := PCnLongWord32(TCnNativeInt(RR) + SizeOf(TCnLongWord32));
    R := PCnLongWord32(TCnNativeInt(R) + SizeOf(TCnLongWord32));
    B := PCnLongWord32(TCnNativeInt(B) + SizeOf(TCnLongWord32));
    RR^ := BigNumberMulAddWords(PLongWordArray(R), PLongWordArray(A), NA, B^);

    Dec(NB);
    if NB <=0 then
      Exit;
    RR := PCnLongWord32(TCnNativeInt(RR) + SizeOf(TCnLongWord32));
    R := PCnLongWord32(TCnNativeInt(R) + SizeOf(TCnLongWord32));
    B := PCnLongWord32(TCnNativeInt(B) + SizeOf(TCnLongWord32));
    RR^ := BigNumberMulAddWords(PLongWordArray(R), PLongWordArray(A), NA, B^);

    Dec(NB);
    if NB <=0 then
      Exit;
    RR := PCnLongWord32(TCnNativeInt(RR) + SizeOf(TCnLongWord32));
    R := PCnLongWord32(TCnNativeInt(R) + SizeOf(TCnLongWord32));
    B := PCnLongWord32(TCnNativeInt(B) + SizeOf(TCnLongWord32));
    RR^ := BigNumberMulAddWords(PLongWordArray(R), PLongWordArray(A), NA, B^);
  end;
end;

function BigNumberMulKaratsuba(const Res: TCnBigNumber; Num1: TCnBigNumber;
  Num2: TCnBigNumber): Boolean;
var
  H: Integer;
  XL, XH, YL, YH, P1, P2, P3: TCnBigNumber;
begin
  H := Num1.GetWordCount;
  if H < Num2.GetWordCount then
    H := Num2.GetWordCount;

  Inc(H);
  H := H shr 1;

  XL := FLocalBigNumberPool.Obtain;
  XH := FLocalBigNumberPool.Obtain;
  YL := FLocalBigNumberPool.Obtain;
  YH := FLocalBigNumberPool.Obtain;
  P1 := FLocalBigNumberPool.Obtain;
  P2 := FLocalBigNumberPool.Obtain;
  P3 := FLocalBigNumberPool.Obtain;

  try
    BigNumberCopyLow(XL, Num1, H);
    BigNumberCopyHigh(XH, Num1, Num1.GetWordCount - H);
    BigNumberCopyLow(YL, Num2, H);
    BigNumberCopyHigh(YH, Num2, Num2.GetWordCount - H);

    BigNumberAdd(P1, XH, XL);
    BigNumberAdd(P2, YH, YL);
    BigNumberMul(P3, P1, P2); // p3=(xh+xl)*(yh+yl)

    BigNumberMul(P1, XH, YH); // p1 = xh*yh
    BigNumberMul(P2, XL, YL); // p2 = xl*yl

    // p1 * 2^(32*2*h) + (p3 - p1 - p2) * 2^(32*h) + p2
    BigNumberSub(P3, P3, P1);
    BigNumberSub(P3, P3, P2);
    BigNumberShiftLeft(P3, P3, 32 * H); // P3 �õ� (p3 - p1 - p2) * 2^(32*h)

    BigNumberShiftLeft(P1, P1, 32 * 2 * H); // P1 �õ� p1 * 2^(32*2*h)

    BigNumberAdd(Res, P3, P1);
    BigNumberAdd(Res, Res, P2);
    Res.SetNegative(Num1.IsNegative <> Num2.IsNegative);
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(XL);
    FLocalBigNumberPool.Recycle(XH);
    FLocalBigNumberPool.Recycle(YL);
    FLocalBigNumberPool.Recycle(YH);
    FLocalBigNumberPool.Recycle(P1);
    FLocalBigNumberPool.Recycle(P2);
    FLocalBigNumberPool.Recycle(P3);
  end;
end;

function BigNumberMul(const Res: TCnBigNumber; Num1: TCnBigNumber;
  Num2: TCnBigNumber): Boolean;
var
  Top, AL, BL: Integer;
  RR: TCnBigNumber;
  IsFromPool: Boolean;
begin
  Result := False;
  AL := Num1.Top;
  BL := Num2.Top;

  if (AL = 0) or (BL = 0) then
  begin
    BigNumberSetZero(Res);
    Result := True;
    Exit;
  end;

  if (AL < BN_MUL_KARATSUBA) and (BL < BN_MUL_KARATSUBA) then // С�ġ�ֱ�ӳ�
  begin
    Top := AL + BL;

    RR := nil;
    IsFromPool := False;

    try
      if (Res = Num1) or (Res = Num2) then
      begin
        RR := FLocalBigNumberPool.Obtain;
        IsFromPool := True;
        if RR = nil then
          Exit;
      end
      else
        RR := Res;

      if Num1.Neg <> Num2.Neg then
        RR.Neg := 1
      else
        RR.Neg := 0;

      if BigNumberWordExpand(RR, Top) = nil then
        Exit;
      RR.Top := Top;
      BigNumberMulNormal(RR.D, Num1.D, AL, Num2.D, BL);

      if RR <> Res then
        BigNumberCopy(Res, RR);

      BigNumberCorrectTop(Res);
      Result := True;
    finally
      if IsFromPool then
        FLocalBigNumberPool.Recycle(RR);
    end;
  end
  else // ���������㷨
    Result := BigNumberMulKaratsuba(Res, Num1, Num2);
end;

function BigNumberMulFloat(const Res: TCnBigNumber; Num: TCnBigNumber;
  F: Extended): Boolean;
var
  N: Boolean;
  E: Integer;
  M: TUInt64;
  B: TCnBigNumber;
begin
  if F = 0 then
    Res.SetZero
  else if (F = 1) or (F = -1) then
  begin
    BigNumberCopy(Res, Num);
    if F = -1 then
      Res.Negate;
  end
  else
  begin
    // ������š�ָ������Ч���ֽ�����������
    ExtractFloatExtended(F, N, E, M);
    E := E - 63;
    // ���ڵ���ʵֵΪ M * 2^E �η�������Ҫ���� M���ٳ��� 2^E

    B := FLocalBigNumberPool.Obtain;
    try
      BigNumberSetUInt64UsingInt64(B, M);
      BigNumberMul(Res, Num, B);

      B.SetWord(1);
      if E > 0 then
      begin
        B.ShiftLeft(E);
        BigNumberMul(Res, Res, B);
      end
      else
      begin
        B.ShiftLeft(-E);
        BigNumberDiv(Res, nil, Res, B);
      end;

      if N then
        Res.Negate;
    finally
      FLocalBigNumberPool.Recycle(B);
    end;
  end;
  Result := True;
end;

function BigNumberDiv(const Res: TCnBigNumber; const Remain: TCnBigNumber;
  const Num: TCnBigNumber; const Divisor: TCnBigNumber): Boolean;
var
  Tmp, SNum, SDiv, SRes: TCnBigNumber;
  I, NormShift, Loop, NumN, DivN, Neg, BackupTop, BackupDMax, BackupNeg: Integer;
  D0, D1, Q, L0, N0, N1, Rem, T2L, T2H: TCnLongWord32;
  Resp, WNump, BackupD: PCnLongWord32;
  WNum: TCnBigNumber;
  T2: TUInt64;
begin
  Result := False;
  if (Num.Top > 0) and (PLongWordArray(Num.D)^[Num.Top - 1] = 0) then
    Exit;

  if BigNumberIsZero(Divisor) then
    Exit;

  if BigNumberUnsignedCompare(Num, Divisor) < 0 then
  begin
    if Remain <> nil then
      if BigNumberCopy(Remain, Num) = nil then
        Exit;
    BigNumberSetZero(Res);
    Result := True;
    Exit;
  end;

  WNum := nil;
  Tmp := nil;
  SNum := nil;
  SDiv := nil;
  BackupTop := 0;
  BackupDMax := 0;
  BackupNeg := 0;
  BackupD := nil;

  try
    Tmp := FLocalBigNumberPool.Obtain;
    SNum := FLocalBigNumberPool.Obtain;
    SDiv := FLocalBigNumberPool.Obtain;
    SRes := Res;

    if (Tmp = nil) or (SNum = nil) or (SDiv = nil) or (SRes = nil) then
      Exit;

    // �ѳ������Ƶ����λ�� 1������ SDiv���� ȷ������� D0 ���λ�� 1
    NormShift := BN_BITS2 - (BigNumberGetBitsCount(Divisor) mod BN_BITS2);
    if not BigNumberShiftLeft(SDiv, Divisor, NormShift) then
      Exit;

    SDiv.Neg := 0;
    // �ѱ�����ͬ�����ƣ���������һ����
    NormShift := NormShift + BN_BITS2;
    if not BigNumberShiftLeft(SNum, Num, NormShift) then
      Exit;

    SNum.Neg := 0;
    DivN := SDiv.Top;
    NumN := SNum.Top;
    Loop := NumN - DivN;

    WNum := FLocalBigNumberPool.Obtain;
    BackupNeg := WNum.Neg;
    BackupD := WNum.D;
    BackupTop := WNum.Top;
    BackupDMax := WNum.DMax;

    // ע�� WNum ��Ҫʹ���ⲿ�� D���ѳ������ó����Ķ����ȱ���
    WNum.Neg := 0;
    WNum.D := PCnLongWord32(TCnNativeInt(SNum.D) + Loop * SizeOf(TCnLongWord32));
    WNum.Top := DivN;
    WNum.DMax := SNum.DMax - Loop;

    D0 := PLongWordArray(SDiv.D)^[DivN - 1];
    if DivN = 1 then
      D1 := 0
    else
      D1 := PLongWordArray(SDiv.D)^[DivN - 2];
    // D0 D1 �� SDiv ������� DWORD

    WNump := PCnLongWord32(TCnNativeInt(SNum.D) + (NumN - 1) * SizeOf(TCnLongWord32));

    if Num.Neg <> Divisor.Neg then
      SRes.Neg := 1
    else
      SRes.Neg := 0;

    if BigNumberWordExpand(SRes, Loop + 1) = nil then
      Exit;

    SRes.Top := Loop;
    Resp := PCnLongWord32(TCnNativeInt(SRes.D) + (Loop - 1) * SizeOf(TCnLongWord32));

    if BigNumberWordExpand(Tmp, DivN + 1) = nil then
      Exit;

    if BigNumberUnsignedCompare(WNum, SDiv) >= 0 then
    begin
      BigNumberSubWords(PLongWordArray(WNum.D), PLongWordArray(WNum.D),
        PLongWordArray(SDiv.D), DivN);
      Resp^ := 1;
    end
    else
      Dec(SRes.Top);

    if SRes.Top = 0 then
      SRes.Neg := 0
    else
      Resp := PCnLongWord32(TCnNativeInt(Resp) - SizeOf(TCnLongWord32));

    for I := 0 to Loop - 2 do
    begin
//    Rem := 0;
      // �� N0/N1/D0/D1 �����һ�� Q ʹ | WNum - SDiv * Q | < SDiv
      N0 := WNump^;
      N1 := (PCnLongWord32(TCnNativeInt(WNump) - SizeOf(TCnLongWord32)))^;

      if N0 = D0 then
        Q := BN_MASK2
      else
      begin
        Q := InternalDivWords(N0, N1, D0); // D0 �������ı�֤���λ�� 1
        Rem := (N1 - Q * D0) and BN_MASK2;

        T2 := UInt64Mul(D1, Q);
        T2H := (T2 shr 32) and BN_MASK2;
        T2L := T2 and BN_MASK2;

        while True do
        begin
          if (T2H < Rem) or ((T2H = Rem) and
             (T2L <= (PCnLongWord32(TCnNativeInt(WNump) - 2 * SizeOf(TCnLongWord32)))^)) then
             Break;
          Dec(Q);
          Inc(Rem, D0);
          if Rem < D0 then
            Break;
          if T2L < D1 then
            Dec(T2H);
          Dec(T2L, D1);
        end;
      end;

      L0 := BigNumberMulWords(PLongWordArray(Tmp.D), PLongWordArray(SDiv.D), DivN, Q);
      PLongWordArray(Tmp.D)^[DivN] := L0;
      WNum.D := PCnLongWord32(TCnNativeInt(WNum.D) - SizeOf(TCnLongWord32));

      if BigNumberSubWords(PLongWordArray(WNum.D), PLongWordArray(WNum.D),
        PLongWordArray(Tmp.D), DivN + 1) <> 0 then
      begin
        Dec(Q);
        if BigNumberAddWords(PLongWordArray(WNum.D), PLongWordArray(WNum.D),
          PLongWordArray(SDiv.D), DivN) <> 0 then
          WNump^ := WNump^ + 1;
      end;

      Resp^ := Q;
      WNump := PCnLongWord32(TCnNativeInt(WNump) - SizeOf(TCnLongWord32));
      Resp := PCnLongWord32(TCnNativeInt(Resp) - SizeOf(TCnLongWord32));
    end;

    BigNumberCorrectTop(SNum);
    Neg := Num.Neg;

    if Remain <> nil then // ��Ҫ����ʱ
    begin
      BigNumberShiftRight(Remain, SNum, NormShift);
      if not BigNumberIsZero(Remain) then
        Remain.Neg := Neg;
    end;

    Result := True;
  finally
    FLocalBigNumberPool.Recycle(Tmp);
    FLocalBigNumberPool.Recycle(SNum);
    FLocalBigNumberPool.Recycle(SDiv);
    // �ָ� WNum ���ݲ��ӻس�����
    WNum.Neg := BackupNeg;
    WNum.D := BackupD;
    WNum.Top := BackupTop;
    WNum.DMax := BackupDMax;
    FLocalBigNumberPool.Recycle(WNum);
  end;
end;

function BigNumberMod(const Remain: TCnBigNumber;
  const Num: TCnBigNumber; const Divisor: TCnBigNumber): Boolean;
var
  Res: TCnBigNumber;
begin
  Res := FLocalBigNumberPool.Obtain;
  try
    Result := BigNumberDiv(Res, Remain, Num, Divisor);
  finally
    FLocalBigNumberPool.Recycle(Res);
  end;
end;

function BigNumberNonNegativeMod(const Remain: TCnBigNumber;
  const Num: TCnBigNumber; const Divisor: TCnBigNumber): Boolean;
begin
  Result := False;
  if not BigNumberMod(Remain, Num, Divisor) then
    Exit;
  Result := True;
  if Remain.Neg = 0 then
    Exit;

  // ���� -|Divisor| < Remain < 0��������Ҫ Remain := Remain + |Divisor|
  if Divisor.Neg <> 0 then
    Result := BigNumberSub(Remain, Remain, Divisor)
  else
    Result := BigNumberAdd(Remain, Remain, Divisor);
end;

function BigNumberMulWordNonNegativeMod(const Res: TCnBigNumber;
  const Num: TCnBigNumber; N: Integer; const Divisor: TCnBigNumber): Boolean;
var
  T: TCnBigNumber;
begin
  T := FLocalBigNumberPool.Obtain;
  try
    T.SetInteger(N);
    Result := BigNumberDirectMulMod(Res, Num, T, Divisor);
  finally
    FLocalBigNumberPool.Recycle(T);
  end;
end;

function BigNumberAddMod(const Res: TCnBigNumber; const Num1, Num2: TCnBigNumber;
  const Divisor: TCnBigNumber): Boolean;
var
  T: TCnBigNumber;
begin
  Result := False;
  T := FLocalBigNumberPool.Obtain;
  try
    if not BigNumberAdd(T, Num1, Num2) then
      Exit;

    Result := BigNumberNonNegativeMod(Res, T, Divisor);
  finally
    FLocalBigNumberPool.Recycle(T);
  end;
end;

function BigNumberSubMod(const Res: TCnBigNumber; const Num1, Num2: TCnBigNumber;
  const Divisor: TCnBigNumber): Boolean;
var
  T: TCnBigNumber;
begin
  Result := False;
  T := FLocalBigNumberPool.Obtain;
  try
    if not BigNumberSub(T, Num1, Num2) then
      Exit;

    Result := BigNumberNonNegativeMod(Res, T, Divisor);
  finally
    FLocalBigNumberPool.Recycle(T);
  end;
end;

function BigNumberDivFloat(const Res: TCnBigNumber; Num: TCnBigNumber;
  F: Extended): Boolean;
begin
  Result := False;
  if F = 0 then
     Exit;

  Result := BigNumberMulFloat(Res, Num, 1 / F);
end;

function BigNumberPower(const Res: TCnBigNumber; const Num: TCnBigNumber;
  Exponent: TCnLongWord32): Boolean;
var
  T: TCnBigNumber;
begin
  Result := False;
  if Exponent = 0 then
  begin
    if Num.IsZero then  // 0 �� 0 �η�
      Exit;

    Res.SetOne;
    Result := True;
    Exit;
  end
  else if Exponent = 1 then // 1 �η�Ϊ����
  begin
    BigNumberCopy(Res, Num);
    Result := True;
    Exit;
  end;

  T := FLocalBigNumberPool.Obtain;
  BigNumberCopy(T, Num);

  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetOne;
    while Exponent > 0 do
    begin
      if (Exponent and 1) <> 0 then
        BigNumberMul(Res, Res, T);

      Exponent := Exponent shr 1;
      BigNumberMul(T, T, T);
    end;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(T);
  end;
end;

function BigNumberExp(const Res: TCnBigNumber; const Num: TCnBigNumber;
  Exponent: TCnBigNumber): Boolean;
var
  I, Bits: Integer;
  V, RR: TCnBigNumber;
  IsFromPool: Boolean;
begin
  Result := False;
  RR := nil;
  V := nil;
  IsFromPool := False;

  try
    if (Res = Num) or (Res = Exponent) then
    begin
      RR := FLocalBigNumberPool.Obtain;
      IsFromPool := True;
    end
    else
      RR := Res;

    V := FLocalBigNumberPool.Obtain;
    if (RR = nil) or (V = nil) then
      Exit;

    if BigNumberCopy(V, Num) = nil then
      Exit;

    Bits := BigNumberGetBitsCount(Exponent);
    if BigNumberIsOdd(Exponent) then
    begin
      if BigNumberCopy(RR, Num) = nil then
        Exit;
    end
    else
    begin
      if not BigNumberSetOne(RR) then
        Exit;
    end;

    for I := 1 to Bits - 1 do
    begin
      if not BigNumberSqr(V, V) then
        Exit;

      if BigNumberIsBitSet(Exponent, I) then
        if not BigNumberMul(RR, RR, V) then
          Exit;
    end;

    if Res <> RR then
      BigNumberCopy(Res, RR);
    Result := True;
  finally
    if IsFromPool then
      FLocalBigNumberPool.Recycle(RR);
    FLocalBigNumberPool.Recycle(V);
  end;
end;

// շת������� A �� B �����Լ������Լ������ A �� B �У����ص�ַ
function EuclidGcd(A: TCnBigNumber; B: TCnBigNumber): TCnBigNumber;
var
  T: TCnBigNumber;
  Shifts: Integer;
begin
  Result := nil;
  Shifts := 0;
  while not BigNumberIsZero(B) do
  begin
    if BigNumberIsOdd(A) then
    begin
      if BigNumberIsOdd(B) then
      begin
        // A �� B ��
        if not BigNumberSub(A, A, B) then
          Exit;
        if not BigNumberShiftRightOne(A, A) then
          Exit;
        if BigNumberCompare(A, B) < 0 then
        begin
          T := A;
          A := B;
          B := T;
        end;
      end
      else  // A �� B ż
      begin
        if not BigNumberShiftRightOne(B, B) then
          Exit;
        if BigNumberCompare(A, B) < 0 then
        begin
          T := A;
          A := B;
          B := T;
        end;
      end;
    end
    else // A ż
    begin
      if BigNumberIsOdd(B) then
      begin
        // A ż B ��
        if not BigNumberShiftRightOne(A, A) then
          Exit;
        if BigNumberCompare(A, B) < 0 then
        begin
          T := A;
          A := B;
          B := T;
        end;
      end
      else // A ż B ż
      begin
        if not BigNumberShiftRightOne(A, A) then
          Exit;
        if not BigNumberShiftRightOne(B, B) then
          Exit;
        Inc(Shifts);
      end;
    end;
  end;

  if Shifts <> 0 then
    if not BigNumberShiftLeft(A, A, Shifts) then
      Exit;
  Result := A;
end;

function BigNumberGcd(const Res: TCnBigNumber; Num1: TCnBigNumber;
  Num2: TCnBigNumber): Boolean;
var
  T, A, B: TCnBigNumber;
begin
  Result := False;

  A := nil;
  B := nil;

  try
    A := FLocalBigNumberPool.Obtain;
    B := FLocalBigNumberPool.Obtain;
    if (A = nil) or (B = nil) then
      Exit;

    if BigNumberCopy(A, Num1) = nil then
      Exit;
    if BigNumberCopy(B, Num2) = nil then
      Exit;

    A.Neg := 0;
    B.Neg := 0;
    if BigNumberCompare(A, B) < 0 then
    begin
      T := A;
      A := B;
      B := T;
    end;

    T := EuclidGcd(A, B);
    if T = nil then
      Exit;

    if BigNumberCopy(Res, T) = nil then
      Exit;

    Result := True;
  finally
    FLocalBigNumberPool.Recycle(A);
    FLocalBigNumberPool.Recycle(B);
  end;
end;

function BigNumberLcm(const Res: TCnBigNumber; Num1: TCnBigNumber;
  Num2: TCnBigNumber): Boolean;
var
  G, M, R: TCnBigNumber;
begin
  Result := False;
  if BigNumberCompare(Num1, Num2) = 0 then
  begin
    BigNumberCopy(Res, Num1);
    Result := True;
    Exit;
  end;

  G := nil;
  M := nil;
  R := nil;

  try
    G := FLocalBigNumberPool.Obtain;
    M := FLocalBigNumberPool.Obtain;
    R := FLocalBigNumberPool.Obtain;

    if not BigNumberGcd(G, Num1, Num2) then
      Exit;

    if not BigNumberMul(M, Num1, Num2) then
      Exit;

    if not BigNumberDiv(Res, R, M, G) then
      Exit;

    Result := True;
  finally
    FLocalBigNumberPool.Recycle(R);
    FLocalBigNumberPool.Recycle(M);
    FLocalBigNumberPool.Recycle(G);
  end;
end;

// ���ټ��� (A * B) mod C�����ؼ����Ƿ�ɹ���Res ������ C��A��B��C ���ֲ��䣨��� Res ���� A��B �Ļ�}
function BigNumberMulMod(const Res: TCnBigNumber; const A, B, C: TCnBigNumber): Boolean;
var
  T, P: TCnBigNumber;
begin
  if not BigNumberIsNegative(A) and not BigNumberIsNegative(B) then
    Result := BigNumberUnsignedMulMod(Res, A, B, C)
  else if BigNumberIsNegative(A) and BigNumberIsNegative(B) then
  begin
    T := FLocalBigNumberPool.Obtain;
    P := FLocalBigNumberPool.Obtain;
    try
      BigNumberCopy(T, A);
      BigNumberCopy(P, B);
      BigNumberSetNegative(T, False);
      BigNumberSetNegative(P, False);
      Result := BigNumberUnsignedMulMod(Res, T, P, C);
    finally
      FLocalBigNumberPool.Recycle(T);
      FLocalBigNumberPool.Recycle(P);
    end;
  end
  else if BigNumberIsNegative(A) and not BigNumberIsNegative(B) then // A ��
  begin
    T := FLocalBigNumberPool.Obtain;
    try
      BigNumberCopy(T, A);
      BigNumberSetNegative(T, False);
      Result := BigNumberUnsignedMulMod(Res, T, B, C);
      BigNumberSub(Res, C, Res);
    finally
      FLocalBigNumberPool.Recycle(T);
    end;
  end
  else if not BigNumberIsNegative(A) and BigNumberIsNegative(B) then // B ��
  begin
    T := FLocalBigNumberPool.Obtain;
    try
      BigNumberCopy(T, B);
      BigNumberSetNegative(T, False);
      Result := BigNumberUnsignedMulMod(Res, A, T, C);
      BigNumberSub(Res, C, Res);
    finally
      FLocalBigNumberPool.Recycle(T);
    end;
  end
  else
    Result := False;
end;

// ���ټ��� (A * B) mod C�����ؼ����Ƿ�ɹ���Res ������ C��A��B��C ���ֲ��䣨��� Res ���� A��B �Ļ�}
function BigNumberUnsignedMulMod(const Res: TCnBigNumber; const A, B, C: TCnBigNumber): Boolean;
var
  AA, BB: TCnBigNumber;
begin
  Result := False;
  AA := nil;
  BB := nil;

  try
    // ʹ����ʱ��������֤ A��B �����ֵ�������仯
    AA := FLocalBigNumberPool.Obtain;
    BB := FLocalBigNumberPool.Obtain;

    BigNumberCopy(AA, A);
    BigNumberCopy(BB, B);
    BigNumberSetNegative(AA, False); // ȫ������
    BigNumberSetNegative(BB, False);

    if not BigNumberMod(AA, AA, C) then
      Exit;

    if not BigNumberMod(BB, BB, C) then
      Exit;

    Res.SetZero; // ��� Res �� A �� B���������������� AA �� BB���ı� A �� B ��Ӱ��

    while not BB.IsZero do
    begin
      if BigNumberIsBitSet(BB, 0) then
      begin
        if not BigNumberAdd(Res, Res, AA) then
          Exit;

        if not BigNumberMod(Res, Res, C) then
          Exit;
      end;

      if not BigNumberShiftLeftOne(AA, AA) then
        Exit;

      if BigNumberCompare(AA, C) >= 0 then
        if not BigNumberMod(AA, AA, C) then
          Exit;

      if not BigNumberShiftRightOne(BB, BB) then
        Exit;
    end;
  finally
    FLocalBigNumberPool.Recycle(AA);
    FLocalBigNumberPool.Recycle(BB);
  end;
  Result := True;
end;

{* ��ͨ���� (A * B) mod C�����ؼ����Ƿ�ɹ���Res ������ C��A��B��C ���ֲ��䣨��� Res ���� A��B �Ļ���}
function BigNumberDirectMulMod(const Res: TCnBigNumber; A, B, C: TCnBigNumber): Boolean;
begin
  Result := False;
  if A = B then
  begin
    if not BigNumberSqr(Res, A) then
      Exit;
  end
  else
  begin
    if not BigNumberMul(Res, A, B) then
      Exit;
  end;

  if not BigNumberNonNegativeMod(Res, Res, C) then
    Exit;
  Result := True;
end;

// ���ټ��� (A ^ B) mod C�����ؼ����Ƿ�ɹ���Res ������ A��B��C ֮һ
function BigNumberPowerMod(const Res: TCnBigNumber; A, B, C: TCnBigNumber): Boolean;
var
  I, J, Bits, WStart, WEnd, Window, WValue, Start: Integer;
  D: TCnBigNumber;
  Val: array[0..31] of TCnBigNumber;

  function WindowBit(B: Integer): Integer;
  begin
    if B > 671 then
      Result := 6
    else if B > 239 then
      Result := 5
    else if B > 79 then
      Result := 4
    else if B > 23 then
      Result := 3
    else
      Result := 1;
  end;

begin
  Result := False;
  Bits := BigNumberGetBitsCount(B);

  if Bits = 0 then
  begin
    if BigNumberAbsIsWord(C, 1) then
      BigNumberSetZero(Res)
    else
      BigNumberSetOne(Res);
    Result := True;
    Exit;
  end;

  D := nil;
  for I := Low(Val) to High(Val) do
    Val[I] := nil;

  try
    Val[0] := FLocalBigNumberPool.Obtain;
    if not BigNumberNonNegativeMod(Val[0], A, C) then
      Exit;

    if BigNumberIsZero(Val[0]) then
    begin
      if not BigNumberSetZero(Res) then
        Exit;
      Result := True;
      Exit;
    end;

    Window := WindowBit(Bits);
    D := FLocalBigNumberPool.Obtain;
    if Window > 1 then
    begin
      if not BigNumberDirectMulMod(D, Val[0], Val[0], C) then
        Exit;

      J := 1 shl (Window - 1);
      for I := 1 to J - 1 do
      begin
        Val[I] := FLocalBigNumberPool.Obtain;
        if not BigNumberDirectMulMod(Val[I], Val[I - 1], D, C) then
          Exit;
      end;
    end;

    Start := 1;
    WStart := Bits - 1;

    if not BigNumberSetOne(Res) then
      Exit;

    while True do
    begin
      if not BigNumberIsBitSet(B, WStart) then
      begin
        if Start = 0 then
          if not BigNumberDirectMulMod(Res, Res, Res, C) then
            Exit;

        if WStart = 0 then
          Break;

        Dec(WStart);
        Continue;
      end;

      WValue := 1;
      WEnd := 0;
      for I := 1 to Window - 1 do
      begin
        if WStart - I < 0 then
          Break;

        if BigNumberIsBitSet(B, WStart - I) then
        begin
          WValue := WValue shl (I - WEnd);
          WValue := WValue or 1;
          WEnd := I;
        end;
      end;

      J := WEnd + 1;
      if Start = 0 then
      begin
        for I := 0 to J - 1 do
          if not BigNumberDirectMulMod(Res, Res, Res, C) then
            Exit;
      end;

      if not BigNumberDirectMulMod(Res, Res, Val[WValue shr 1], C) then
        Exit;

      WStart := WStart - WEnd - 1;
      Start := 0;
      if WStart < 0 then
        Break;
    end;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(D);
    for I := Low(Val) to High(Val) do
      FLocalBigNumberPool.Recycle(Val[I]);
  end;
end;

// �ɸ����������ټ��� (A ^ B) mod C�������ؼ����Ƿ�ɹ���Res ������ A��B��C ֮һ
function BigNumberMontgomeryPowerMod(const Res: TCnBigNumber; A, B, C: TCnBigNumber): Boolean;
var
  T, AA, BB: TCnBigNumber;
begin
  Result := False;
  if B.IsZero then
  begin
    Res.SetOne;
    Result := True;
    Exit;
  end;

  AA := nil;
  BB := nil;
  T := nil;

  try
    AA := FLocalBigNumberPool.Obtain;
    BB := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;

    if not T.SetOne then
      Exit;

    if not BigNumberMod(AA, A, C) then
      Exit;

    if BigNumberCopy(BB, B) = nil then
      Exit;

    while not BB.IsOne do
    begin
      if BigNumberIsBitSet(BB, 0) then
      begin
        if not BigNumberDirectMulMod(T, AA, T, C) then
          Exit;
      end;
      if not BigNumberDirectMulMod(AA, AA, AA, C) then
        Exit;

      if not BigNumberShiftRightOne(BB, BB) then
        Exit;
    end;

    if not BigNumberDirectMulMod(Res, AA, T, C) then
      Exit;
  finally
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(AA);
    FLocalBigNumberPool.Recycle(BB);
  end;
  Result := True;
end;

procedure CheckLog(const Num: TCnBigNumber);
begin
  if Num.IsZero or Num.IsNegative then
    raise ERangeError.Create(SCN_BN_LOG_RANGE_ERROR);
end;

function BigNumberLog2(const Num: TCnBigNumber): Extended;
var
  F: Extended;
begin
  CheckLog(Num);
  if Num.IsOne then
    Result := 0
  else
  begin
    F := BigNumberGetFloat(Num);
    Result := Log2(F);
  end;
end;

function BigNumberLog10(const Num: TCnBigNumber): Extended;
var
  F: Extended;
begin
  CheckLog(Num);
  if Num.IsOne then
    Result := 0
  else
  begin
    F := BigNumberGetFloat(Num);
    Result := Log10(F);
  end;
end;

function BigNumberLogN(const Num: TCnBigNumber): Extended;
var
  F: Extended;
begin
  CheckLog(Num);
  if Num.IsOne then
    Result := 0
  else
  begin
    F := BigNumberGetFloat(Num);
    Result := Ln(F);
  end;
end;

function BigNumberFermatCheckComposite(const A, B, C: TCnBigNumber; T: Integer): Boolean;
var
  I: Integer;
  R, L, S: TCnBigNumber;
begin
  Result := False;

  R := nil;
  L := nil;
  S := nil;

  try
    R := FLocalBigNumberPool.Obtain;
    if not BigNumberPowerMod(R, A, C, B) then
      Exit;

    L := FLocalBigNumberPool.Obtain;
    if BigNumberCopy(L, R) = nil then // L := R;
      Exit;

    S := FLocalBigNumberPool.Obtain;
    for I := 1 to T do
    begin
      if not BigNumberMulMod(R, R, R, B) then
        Exit;

      if R.IsOne and not L.IsOne then
      begin
        BigNumberSub(S, B, L);
        if not S.IsOne then
        begin
          Result := True;
          Exit;
        end;
      end;

      if BigNumberCopy(L, R) = nil then
        Exit;
    end;

    Result := not R.IsOne;
  finally
    FLocalBigNumberPool.Recycle(R);
    FLocalBigNumberPool.Recycle(L);
    FLocalBigNumberPool.Recycle(S);
  end;
end;

// TestCount ָ Miller-Rabin �㷨�Ĳ��Դ�����Խ��Խ��ȷҲԽ��
function BigNumberIsProbablyPrime(const Num: TCnBigNumber; TestCount: Integer): Boolean;
var
  I, T: Integer;
  X, R, W: TCnBigNumber;
begin
  Result := False;
  if TestCount <= 1 then
    Exit;

  // �ų��� ������0��1 �Լ� 2 ֮���ż����
  if Num.IsZero or Num.IsNegative or Num.IsOne or (not Num.IsOdd and not BigNumberAbsIsWord(Num, 2))then
    Exit;

  // С�������ȶԱ��жϣ����� 2
  X := FLocalBigNumberPool.Obtain;
  try
    X.SetWord(CN_PRIME_NUMBERS_SQRT_UINT32[High(CN_PRIME_NUMBERS_SQRT_UINT32)]);
    if BigNumberCompare(Num, X) <= 0 then
    begin
      for I := Low(CN_PRIME_NUMBERS_SQRT_UINT32) to High(CN_PRIME_NUMBERS_SQRT_UINT32) do
      begin
        if BigNumberAbsIsWord(Num, CN_PRIME_NUMBERS_SQRT_UINT32[I]) then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  finally
    FLocalBigNumberPool.Recycle(X);
  end;

  // ����С���������������� 2 �ˣ���Ϊ 2 ֮���ż���Ѿ����ų���
  for I := Low(CN_PRIME_NUMBERS_SQRT_UINT32) + 1 to High(CN_PRIME_NUMBERS_SQRT_UINT32) do
  begin
    if BigNumberModWord(Num, CN_PRIME_NUMBERS_SQRT_UINT32[I]) = 0 then
      Exit;
  end;

  // ��©���ˣ����� Miller-Rabin Test
  X := nil;
  R := nil;
  W := nil;

  try
    X := FLocalBigNumberPool.Obtain;
    R := FLocalBigNumberPool.Obtain;
    W := FLocalBigNumberPool.Obtain;

    if BigNumberCopy(X, Num) = nil then
      Exit;

    if not BigNumberSubWord(X, 1) then
      Exit;

    if BigNumberCopy(W, X) = nil then  // W := Num - 1;
      Exit;

    T := 0;
    while not X.IsOdd do // X and 1 = 0
    begin
      if not BigNumberShiftRightOne(X, X) then
        Exit;
      Inc(T);
    end;

    for I := 1 to TestCount do
    begin
      if not BigNumberRandRange(R, W) then
        Exit;

      if not BigNumberAddWord(R, 1) then
        Exit;

      if BigNumberFermatCheckComposite(R, Num, X, T) then
        Exit;
    end;
  finally
    FLocalBigNumberPool.Recycle(X);
    FLocalBigNumberPool.Recycle(R);
    FLocalBigNumberPool.Recycle(W);
  end;
  Result := True;
end;

function InternalGenerateProbablePrime(const Num: TCnBigNumber; BitsCount: Integer): Boolean;
var
  Mods: array[0..BN_PRIME_NUMBERS - 1] of Cardinal;
  Delta, MaxDelta: Cardinal;
  I: Integer;
label
  AGAIN;
begin
  Result := False;

AGAIN:
  if not BigNumberRandBits(Num, BitsCount) then
    Exit;

  for I := 1 to BN_PRIME_NUMBERS - 1 do
    Mods[I] := BigNumberModWord(Num, CN_PRIME_NUMBERS_SQRT_UINT32[I + 1]);

  MaxDelta := BN_MASK2 - CN_PRIME_NUMBERS_SQRT_UINT32[BN_PRIME_NUMBERS];
  Delta := 0;

  for I := 1 to BN_PRIME_NUMBERS - 1 do
  begin
    if ((Mods[I] + Delta) mod CN_PRIME_NUMBERS_SQRT_UINT32[I + 1]) <= 1 then
    begin
      Inc(Delta, 2);
      if Delta > MaxDelta then
        goto AGAIN;
      Continue;
    end;
  end;

  if not BigNumberAddWord(Num, Delta) then
    Exit;
  Result := True;
end;

// ����һ��ָ��λ���Ĵ�������TestCount ָ Miller-Rabin �㷨�Ĳ��Դ�����Խ��Խ��ȷҲԽ��
function BigNumberGeneratePrime(const Num: TCnBigNumber; BytesCount: Integer;
  TestCount: Integer): Boolean;
begin
  Result := False;
  if not InternalGenerateProbablePrime(Num, BytesCount * 8) then
    Exit;

  while not BigNumberIsProbablyPrime(Num, TestCount) do
  begin
    if not InternalGenerateProbablePrime(Num, BytesCount * 8) then
      Exit;
  end;
  Result := True;
end;

// ����һ��ָ��������λ���Ĵ�������TestCount ָ Miller-Rabin �㷨�Ĳ��Դ�����Խ��Խ��ȷҲԽ��
function BigNumberGeneratePrimeByBitsCount(const Num: TCnBigNumber; BitsCount: Integer;
  TestCount: Integer = BN_MILLER_RABIN_DEF_COUNT): Boolean;
begin
  Result := False;
  if not BigNumberRandBits(Num, BitsCount) then
    Exit;

  if not BigNumberSetBit(Num, BitsCount - 1) then
    Exit;

  if not Num.IsOdd then
    Num.AddWord(1);

  while not BigNumberIsProbablyPrime(Num, TestCount) do
    Num.AddWord(2);

  Result := True;
end;

function BigNumberNextPrime(Res, Num: TCnBigNumber;
  TestCount: Integer = BN_MILLER_RABIN_DEF_COUNT): Boolean;
begin
  Result := True;
  if Num.IsNegative or Num.IsZero or Num.IsOne or (Num.GetWord = 2) then
  begin
    Res.SetWord(2);
    Exit;
  end
  else
  begin
    BigNumberCopy(Res, Num);
    if not Res.IsOdd then
      Res.AddWord(1);

    while not BigNumberIsProbablyPrime(Res, TestCount) do
      Res.AddWord(2);
  end;
end;

// �� R �Ƿ���� Prime - 1 ��ÿ�����ӣ����� R ^ (ʣ�����ӵĻ�) mod Prime <> 1
function BigNumberCheckPrimitiveRoot(R, Prime: TCnBigNumber; Factors: TCnBigNumberList): Boolean;
var
  I: Integer;
  Res, SubOne, T, Remain: TCnBigNumber;
begin
  Result := False;
  Res := FLocalBigNumberPool.Obtain;
  T := FLocalBigNumberPool.Obtain;
  Remain := FLocalBigNumberPool.Obtain;
  SubOne := FLocalBigNumberPool.Obtain;

  BigNumberCopy(SubOne, Prime);
  BigNumberSubWord(SubOne, 1);

  try
    for I := 0 to Factors.Count - 1 do
    begin
      BigNumberDiv(T, Remain, SubOne, Factors[I]);
      BigNumberMontgomeryPowerMod(Res, R, T, Prime);
      if Res.IsOne then
        Exit;
    end;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(Res);
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(Remain);
    FLocalBigNumberPool.Recycle(SubOne);
  end;
end;

// �����Ƿ���һ�� 32 λ�з������ͷ�Χ�ڵ���
function BigNumberIsInt32(const Num: TCnBigNumber): Boolean;
var
  C: Integer;
begin
  Result := False;

  C := Num.GetBitsCount;
  if C > BN_BITS_UINT_32 then // ����
    Exit;
  if C < BN_BITS_UINT_32 then // С�� 32 λ����
  begin
    Result := True;
    Exit;
  end;

  // 32 λ
  if Num.IsNegative then // ������С�� -$80000000 �򳬽�
  begin
    if not BigNumberIsBitSet(Num, BN_BITS_UINT_32 - 1) then
      Result := True  // ���λ��Ϊ 1��˵������ֵС�� $80000000
    else
    begin
      // ���λΪ 1������λ��Ҫȫ 0 ������ Int32
      for C := 0 to BN_BITS_UINT_32 - 2 do
        if BigNumberIsBitSet(Num, C) then // ֻҪ�и� 1 �ͱ�ʾ������
          Exit;
      Result := True;
    end;
  end
  else // ��������Ҫ�ж����λ�Ƿ��� 1���� 1 �򳬽磬Ҳ���Ǵ��� $7FFFFFFF
    Result := not BigNumberIsBitSet(Num, BN_BITS_UINT_32 - 1);
end;

// �����Ƿ���һ�� 32 λ�޷������ͷ�Χ�ڵ���
function BigNumberIsUInt32(const Num: TCnBigNumber): Boolean;
begin
  Result := not Num.IsNegative and (Num.GetBitsCount <= BN_BITS_UINT_32);
end;

// �����Ƿ���һ�� 64 λ�з������ͷ�Χ�ڵ���
function BigNumberIsInt64(const Num: TCnBigNumber): Boolean;
var
  C: Integer;
begin
  Result := False;

  C := Num.GetBitsCount;
  if C > BN_BITS_UINT_64 then // ����
    Exit;
  if C < BN_BITS_UINT_64 then // С�� 32 λ����
  begin
    Result := True;
    Exit;
  end;

  // 64 λ
  if Num.IsNegative then // ������С�� -$80000000 00000000 �򳬽�
  begin
    if not BigNumberIsBitSet(Num, BN_BITS_UINT_64 - 1) then
      Result := True  // ���λ��Ϊ 1��˵������ֵС�� $80000000 00000000
    else
    begin
      // ���λΪ 1������λ��Ҫȫ 0 ������ Int64
      for C := 0 to BN_BITS_UINT_64 - 2 do
        if BigNumberIsBitSet(Num, C) then // ֻҪ�и� 1 �ͱ�ʾ������
          Exit;
      Result := True;
    end;
  end
  else // ��������Ҫ�ж����λ�Ƿ��� 1���� 1 �򳬽磬Ҳ���Ǵ��� $7FFFFFFF
    Result := not BigNumberIsBitSet(Num, BN_BITS_UINT_64 - 1);
end;

// �����Ƿ���һ�� 64 λ�޷������ͷ�Χ�ڵ���
function BigNumberIsUInt64(const Num: TCnBigNumber): Boolean;
begin
  Result := not Num.IsNegative and (Num.GetBitsCount <= BN_BITS_UINT_64);
end;

// ��չŷ�����շת��������Ԫһ�β������� A * X + B * Y = 1 ��������
procedure BigNumberExtendedEuclideanGcd(A, B: TCnBigNumber; X: TCnBigNumber;
  Y: TCnBigNumber);
var
  T, P, M: TCnBigNumber;
begin
  if BigNumberIsZero(B) then
  begin
    BigNumberSetOne(X);
    BigNumberSetZero(Y);
  end
  else
  begin
    T := nil;
    P := nil;
    M := nil;

    try
      T := FLocalBigNumberPool.Obtain;
      P := FLocalBigNumberPool.Obtain;
      M := FLocalBigNumberPool.Obtain;
      BigNumberMod(P, A, B);

      BigNumberExtendedEuclideanGcd(B, P, X, Y);
      BigNumberCopy(T, X);
      BigNumberCopy(X, Y);

      // �� CorrectTop ���� Top ֵ��̫��ԭ����
      BigNumberCorrectTop(X);
      BigNumberCorrectTop(Y);

      // T := X;
      // X := Y;
      // Y := T - (A div B) * Y;
      BigNumberDiv(P, M, A, B);
      BigNumberMul(P, P, Y);
      BigNumberSub(Y, T, P);
    finally
      FLocalBigNumberPool.Recycle(M);
      FLocalBigNumberPool.Recycle(P);
      FLocalBigNumberPool.Recycle(T);
    end;
  end;
end;

// ��չŷ�����շת��������Ԫһ�β������� A * X - B * Y = 1 ��������
procedure BigNumberExtendedEuclideanGcd2(A, B: TCnBigNumber; X: TCnBigNumber;
  Y: TCnBigNumber);
var
  T, P, M: TCnBigNumber;
begin
  if BigNumberIsZero(B) then
  begin
    BigNumberSetOne(X);
    BigNumberSetZero(Y);
  end
  else
  begin
    T := nil;
    P := nil;
    M := nil;

    try
      T := FLocalBigNumberPool.Obtain;
      P := FLocalBigNumberPool.Obtain;
      M := FLocalBigNumberPool.Obtain;
      BigNumberMod(P, A, B);

      BigNumberExtendedEuclideanGcd2(B, P, Y, X);

      // �� CorrectTop ���� Top ֵ��̫��ԭ����
      BigNumberCorrectTop(X);
      BigNumberCorrectTop(Y);

      // Y := Y - (A div B) * X;
      BigNumberDiv(P, M, A, B);
      BigNumberMul(P, P, X);
      BigNumberSub(Y, Y, P);
    finally
      FLocalBigNumberPool.Recycle(M);
      FLocalBigNumberPool.Recycle(P);
      FLocalBigNumberPool.Recycle(T);
    end;
  end;
end;

// �� X ��� Modulus ��ģ�����ģ��Ԫ Y������ (X * Y) mod M = 1��X ��Ϊ��ֵ��Y �����ֵ�������������б�֤ X��Modulus ����
function BigNumberModularInverse(const Res: TCnBigNumber; X, Modulus: TCnBigNumber): Boolean;
var
  Neg: Boolean;
  X1, Y: TCnBigNumber;
begin
  Result := False;
  Neg := False;

  X1 := nil;
  Y := nil;

  try
    X1 := FLocalBigNumberPool.Obtain;
    Y := FLocalBigNumberPool.Obtain;

    if BigNumberCopy(X1, X) = nil then Exit;
    if BigNumberIsNegative(X1) then
    begin
      BigNumberSetNegative(X1, False);
      Neg := True;
    end;

    // ��������ģ��Ԫ��������ģ��Ԫ����������ģ��Ԫ�ĸ�ֵ��������ĸ�ֵ�������ټ� Modulus
    BigNumberExtendedEuclideanGcd2(X1, Modulus, Res, Y);
    // ��չŷ�����շת��������Ԫһ�β������� A * X - B * Y = 1 ��������

    if Neg then
      BigNumberSetNegative(Res, not BigNumberIsNegative(Res));

    if BigNumberIsNegative(Res) then
      if not BigNumberAdd(Res, Res, Modulus) then Exit;

    Result := True;
  finally
    FLocalBigNumberPool.Recycle(X1);
    FLocalBigNumberPool.Recycle(Y);
  end;
end;

procedure BigNumberModularInverseWord(const Res: TCnBigNumber; X: Integer;
  Modulus: TCnBigNumber);
var
  T: TCnBigNumber;
begin
  T := FLocalBigNumberPool.Obtain;
  try
    T.SetInteger(X);
    BigNumberModularInverse(Res, T, Modulus);
  finally
    FLocalBigNumberPool.Recycle(T);
  end;
end;

// �ö��λ����ɵݹ�������õ·��� ( A / P) ��ֵ���Ͽ�
function BigNumberLegendre(A, P: TCnBigNumber): Integer;
var
  AA, Q: TCnBigNumber;
begin
  if A.IsZero or A.IsNegative or P.IsZero or P.IsNegative then
    raise Exception.Create(SCN_BN_LEGENDRE_ERROR);

  if A.IsOne then
  begin
    Result := 1;
    Exit;
  end;

  AA := FLocalBigNumberPool.Obtain;
  Q := FLocalBigNumberPool.Obtain;

  try
    if A.IsOdd then
    begin
      // ����
      BigNumberMod(AA, P, A);
      Result := BigNumberLegendre(AA, A);

      // ���� (A-1)*(P-1)/4 �� -1 ���
      BigNumberSub(AA, A, CnBigNumberOne);
      BigNumberSub(Q, P, CnBigNumberOne);
      BigNumberMul(Q, AA, Q);
      BigNumberShiftRight(Q, Q, 2);

      if Q.IsOdd then // ������ -1 �˻��ǵ� -1
        Result := -Result;
    end
    else
    begin
      // ż��
      BigNumberShiftRight(AA, A, 1);
      Result := BigNumberLegendre(AA, P);

      // ���� (P^2 - 1)/8 �� -1 ���
      BigNumberMul(Q, P, P);
      BigNumberSubWord(Q, 1);
      BigNumberShiftRight(Q, Q, 3);

      if Q.IsOdd then // ������ -1 �˻��ǵ� -1
        Result := -Result;
    end;
  finally
    FLocalBigNumberPool.Recycle(Q);
    FLocalBigNumberPool.Recycle(AA);
  end;
end;

// ��ŷ���б𷨼������õ·��� ( A / P) ��ֵ������
function BigNumberLegendre2(A, P: TCnBigNumber): Integer;
var
  R, Res: TCnBigNumber;
begin
  if A.IsZero or A.IsNegative or P.IsZero or P.IsNegative then
    raise Exception.Create(SCN_BN_LEGENDRE_ERROR);

  R := FLocalBigNumberPool.Obtain;
  Res := FLocalBigNumberPool.Obtain;

  try
    // ���������P ������ A ʱ���� 0����������ʱ����� A ����ȫƽ�����ͷ��� 1�����򷵻� -1
    BigNumberMod(R, A, P);
    if R.IsZero then
      Result := 0
    else
    begin
      BigNumberCopy(R, P);
      BigNumberSubWord(R, 1);
      BigNumberShiftRightOne(R, R);
      BigNumberMontgomeryPowerMod(Res, A, R, P);

      if Res.IsOne then // ŷ���б�
        Result := 1
      else
        Result := -1;
    end;
  finally
    FLocalBigNumberPool.Recycle(R);
    FLocalBigNumberPool.Recycle(Res);
  end;
end;

// ʹ�� Tonelli Shanks �㷨����ģ��������ʣ����⣬�����������б�֤ P Ϊ���������������������η�
function BigNumberTonelliShanks(const Res: TCnBigNumber; A, P: TCnBigNumber): Boolean;
var
  Q, Z, C, R, T, N, L, U, B: TCnBigNumber;
  S, I, M: Integer;
begin
  Result := False;
  if (Res = nil) or A.IsZero or A.IsNegative or P.IsZero or P.IsNegative
    or (BigNumberCompare(A, P) >= 0) then
    Exit;

  // ������õ·��Ų�Ϊ 1��˵���޽⣬����Ͳ�������
  if BigNumberLegendre(A, P) <> 1 then
    Exit;

  Q := FLocalBigNumberPool.Obtain;
  Z := FLocalBigNumberPool.Obtain;
  C := FLocalBigNumberPool.Obtain;
  R := FLocalBigNumberPool.Obtain;
  T := FLocalBigNumberPool.Obtain;
  L := FLocalBigNumberPool.Obtain;
  U := FLocalBigNumberPool.Obtain;
  B := FLocalBigNumberPool.Obtain;
  N := FLocalBigNumberPool.Obtain;

  try
    S := 0;
    BigNumberSub(Q, P, CnBigNumberOne);
    while not Q.IsOdd do
    begin
      BigNumberShiftRightOne(Q, Q);
      Inc(S);
    end;

    // ����һ�� Z ���� ��� P �����õ·���Ϊ -1
    Z.SetWord(2);
    while BigNumberCompare(Z, P) < 0 do
    begin
      if BigNumberLegendre(Z, P) = -1 then
        Break;
      BigNumberAddWord(Z, 1);
    end;

    BigNumberAdd(N, Q, CnBigNumberOne);
    BigNumberShiftRight(N, N, 1);
    BigNumberMontgomeryPowerMod(C, Z, Q, P);
    BigNumberMontgomeryPowerMod(R, A, N, P);
    BigNumberMontgomeryPowerMod(T, A, Q, P);
    M := S;

    while True do
    begin
      BigNumberMod(U, T, P);
      if U.IsOne then
        Break;

      for I := 1 to M - 1 do
      begin
        U.SetOne;
        BigNumberShiftLeft(U, U, I);
        BigNumberMontgomeryPowerMod(N, T, U, P);
        if N.IsOne then
          Break;
      end;

      U.SetOne;
      BigNumberShiftLeft(U, U, M - I - 1);
      BigNumberMontgomeryPowerMod(B, C, U, P);
      M := I;
      BigNumberMulMod(R, R, B, P);

      // T := T*B*B mod P = (T*B mod P) * (B mod P) mod P
      BigNumberMulMod(U, T, B, P); // U := T*B mod P
      BigNumberMod(L, B, P);       // L := B mod P
      BigNumberMulMod(T, U, L, P);

      BigNumberMulMod(C, B, B, P);
    end;

    BigNumberMod(L, R, P);
    BigNumberAdd(L, L, P);
    BigNumberMod(Res, L, P);
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(Q);
    FLocalBigNumberPool.Recycle(Z);
    FLocalBigNumberPool.Recycle(C);
    FLocalBigNumberPool.Recycle(R);
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(L);
    FLocalBigNumberPool.Recycle(U);
    FLocalBigNumberPool.Recycle(B);
    FLocalBigNumberPool.Recycle(N);
  end;
end;

// ʹ�� IEEE P1363 �淶�е� Lucas ���н���ģ��������ʣ�����
function BigNumberLucas(const Res: TCnBigNumber; A, P: TCnBigNumber): Boolean;
var
  G, X, Z, U, V, T: TCnBigNumber;
begin
  Result := False;

  G := nil;
  X := nil;
  Z := nil;
  U := nil;
  V := nil;
  T := nil;

  try
    G := FLocalBigNumberPool.Obtain;
    X := FLocalBigNumberPool.Obtain;
    Z := FLocalBigNumberPool.Obtain;
    U := FLocalBigNumberPool.Obtain;
    V := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;

    while True do
    begin
      if not BigNumberRandRange(X, P) then
        Exit;

      BigNumberCopy(T, P);
      BigNumberAddWord(T, 1);
      BigNumberShiftRight(T, T, 1);
      if not BigNumberLucasSequenceMod(X, A, T, P, U, V) then
        Exit;

      BigNumberCopy(Z, V);
      if not V.IsOdd then
      begin
        BigNumberShiftRight(Z, Z, 1);
        BigNumberMod(Z, Z, P);
      end
      else
      begin
        BigNumberAdd(Z, Z, P);
        BigNumberShiftRight(Z, Z, 1);
      end;

      if not BigNumberUnsignedMulMod(T, Z, Z, P) then
        Exit;

      if BigNumberCompare(T, A) = 0 then
      begin
        BigNumberCopy(Res, Z);
        Result := True;
        Exit;
      end
      else if BigNumberCompare(U, CnBigNumberOne) > 0 then
      begin
        BigNumberCopy(T, P);
        BigNumberSubWord(T, 1);

        if BigNumberCompare(U, T) < 0 then
          Break;
      end;
    end;
  finally
    FLocalBigNumberPool.Recycle(G);
    FLocalBigNumberPool.Recycle(X);
    FLocalBigNumberPool.Recycle(Z);
    FLocalBigNumberPool.Recycle(U);
    FLocalBigNumberPool.Recycle(V);
    FLocalBigNumberPool.Recycle(T);
  end;
end;

procedure BigNumberPollardRho(X: TCnBigNumber; C: TCnBigNumber; Res: TCnBigNumber);
var
  I, K, X0, Y0, Y, D, X1, R: TCnBigNumber;
begin
  I := FLocalBigNumberPool.Obtain;
  K := FLocalBigNumberPool.Obtain;
  X0 := FLocalBigNumberPool.Obtain;
  X1 := FLocalBigNumberPool.Obtain;
  Y0 := FLocalBigNumberPool.Obtain;
  Y := FLocalBigNumberPool.Obtain;
  D := FLocalBigNumberPool.Obtain;
  R := FLocalBigNumberPool.Obtain;

  try
    I.SetOne;
    K.SetZero;
    BigNumberAddWord(K, 2);
    BigNumberCopy(X1, X);
    BigNumberSubWord(X1, 1);
    BigNumberRandRange(X0, X1);
    BigNumberAddWord(X1, 1);
    BigNumberCopy(Y, X0);

    while True do
    begin
      BigNumberAddWord(I, 1);

      BigNumberMulMod(R, X0, X0, X);
      BigNumberAdd(R, R, C);
      BigNumberMod(X0, R, X);

      BigNumberSub(Y0, Y, X0);
      BigNumberGcd(D, Y0, X);

      if not D.IsOne and (BigNumberCompare(D, X) <> 0) then
      begin
        BigNumberCopy(Res, D);
        Exit;
      end;

      if BigNumberCompare(Y, X0) = 0 then
      begin
        BigNumberCopy(Res, X);
        Exit;
      end;

      if BigNumberCompare(I, K) = 0 then
      begin
        BigNumberCopy(Y, X0);
        BigNumberMulWord(K, 2);
      end;
    end;
  finally
    FLocalBigNumberPool.Recycle(R);
    FLocalBigNumberPool.Recycle(I);
    FLocalBigNumberPool.Recycle(K);
    FLocalBigNumberPool.Recycle(X0);
    FLocalBigNumberPool.Recycle(X1);
    FLocalBigNumberPool.Recycle(Y0);
    FLocalBigNumberPool.Recycle(Y);
    FLocalBigNumberPool.Recycle(D);
  end;
end;

// �ҳ��������������б�
procedure BigNumberFindFactors(Num: TCnBigNumber; Factors: TCnBigNumberList);
var
  P, R, S, D, T: TCnBigNumber;
begin
  if Num.IsZero or Num.IsNegative or Num.IsOne then
    Exit;

  if BigNumberIsProbablyPrime(Num) then
  begin
    Factors.Add(BigNumberDuplicate(Num));
    Exit;
  end;

  P := nil;
  R := nil;
  S := nil;
  D := nil;
  T := nil;

  try
    P := FLocalBigNumberPool.Obtain;
    R := FLocalBigNumberPool.Obtain;
    S := FLocalBigNumberPool.Obtain;
    D := FLocalBigNumberPool.Obtain;
    T := FLocalBigNumberPool.Obtain;

    BigNumberCopy(P, Num);

    while BigNumberCompare(P, Num) >= 0 do
    begin
      BigNumberCopy(S, Num);
      BigNumberSubWord(S, 1);
      BigNumberRandRange(R, S);
      BigNumberAddWord(R, 1);
      BigNumberPollardRho(P, R, P);
    end;

    BigNumberFindFactors(P, Factors);
    T := FLocalBigNumberPool.Obtain;
    BigNumberDiv(T, R, Num, P);
    BigNumberFindFactors(T, Factors);
  finally
    FLocalBigNumberPool.Remove(T);
    FLocalBigNumberPool.Recycle(D);
    FLocalBigNumberPool.Recycle(S);
    FLocalBigNumberPool.Recycle(R);
    FLocalBigNumberPool.Recycle(P);
  end;
end;

procedure BigNumberEuler(const Res: TCnBigNumber; Num: TCnBigNumber);
var
  F: TCnBigNumberList;
  T: TCnBigNumber;
  I: Integer;
begin
  // ���� Num �Ĳ��ظ����������������ù�ʽ Num * (1- 1/p1) * (1- 1/p2) ����
  F := nil;
  T := nil;

  try
    F := TCnBigNumberList.Create;
    BigNumberFindFactors(Num, F);

    // �ֹ�ȥ��
    F.RemoveDuplicated;

    BigNumberCopy(Res, Num);
    for I := 0 to F.Count - 1 do
      BigNumberDiv(Res, nil, Res, F[I]);

    T := FLocalBigNumberPool.Obtain;
    for I := 0 to F.Count - 1 do
    begin
      BigNumberCopy(T, F[I]);
      T.SubWord(1);
      BigNumberMul(Res, Res, T);
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
    F.Free;
  end;
end;

// ���� IEEE P1363 �Ĺ淶��˵���� Lucas ����
function BigNumberLucasSequenceMod(X, Y, K, N: TCnBigNumber; Q, V: TCnBigNumber): Boolean;
var
  C, I: Integer;
  V0, V1, Q0, Q1, T0, T1, C2: TCnBigNumber;
begin
  Result := False;
  if K.IsNegative then
    Exit;

  if K.IsZero then
  begin
    Q.SetOne;
    V.SetWord(2);
    Result := True;
    Exit;
  end
  else if K.IsOne then
  begin
    Q.SetOne;
    BigNumberCopy(V, X);
    Result := True;
    Exit;
  end;

  V0 := nil;
  V1 := nil;
  Q0 := nil;
  Q1 := nil;
  T0 := nil;
  T1 := nil;
  C2 := nil;

  try
    V0 := FLocalBigNumberPool.Obtain;
    V1 := FLocalBigNumberPool.Obtain;
    Q0 := FLocalBigNumberPool.Obtain;
    Q1 := FLocalBigNumberPool.Obtain;
    T0 := FLocalBigNumberPool.Obtain;
    T1 := FLocalBigNumberPool.Obtain;
    C2 := FLocalBigNumberPool.Obtain;

    C2.SetWord(2);
    V0.SetWord(2);
    BigNumberCopy(V1, X);
    Q0.SetOne;
    Q1.SetOne;

    C := BigNumberGetBitsCount(K);
    if C < 1 then
      Exit;

    for I := C - 1 downto 0 do
    begin
      if not BigNumberMulMod(Q0, Q0, Q1, N) then
        Exit;

      if BigNumberIsBitSet(K, I) then
      begin
        if not BigNumberMulMod(Q1, Q0, Y, N) then
          Exit;

        if not BigNumberMulMod(T0, V0, V1, N) then
          Exit;
        if not BigNumberMulMod(T1, X, Q0, N) then
          Exit;
        if not BigNumberSub(T0, T0, T1) then
          Exit;
        if not BigNumberNonNegativeMod(V0, T0, N) then
          Exit;

        if not BigNumberMulMod(T0, V1, V1, N) then
          Exit;
        if not BigNumberMulMod(T1, C2, Q1, N) then
          Exit;
        if not BigNumberSub(T0, T0, T1) then
          Exit;
        if not BigNumberNonNegativeMod(V1, T0, N) then
          Exit;
      end
      else
      begin
        BigNumberCopy(Q1, Q0);

        if not BigNumberMulMod(T0, V0, V1, N) then
          Exit;
        if not BigNumberMulMod(T1, X, Q0, N) then
          Exit;
        if not BigNumberSub(T0, T0, T1) then
          Exit;
        if not BigNumberNonNegativeMod(V1, T0, N) then
          Exit;

        if not BigNumberMulMod(T0, V0, V0, N) then
          Exit;
        if not BigNumberMulMod(T1, C2, Q0, N) then
          Exit;
        if not BigNumberSub(T0, T0, T1) then
          Exit;
        if not BigNumberNonNegativeMod(V0, T0, N) then
          Exit;
      end;
    end;

    BigNumberCopy(Q, Q0);
    BigNumberCopy(V, V0);
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(V0);
    FLocalBigNumberPool.Recycle(V1);
    FLocalBigNumberPool.Recycle(Q0);
    FLocalBigNumberPool.Recycle(Q1);
    FLocalBigNumberPool.Recycle(T0);
    FLocalBigNumberPool.Recycle(T1);
    FLocalBigNumberPool.Recycle(C2);
  end;
end;

// ���й�ʣ�ඨ�����������뻥�صĳ�����һԪ����ͬ�෽�������С�⣬��������Ƿ�ɹ�
function BigNumberChineseRemainderTheorem(Res: TCnBigNumber;
  Remainers, Factors: TCnBigNumberList): Boolean;
var
  I, J: Integer;
  G, N, Sum: TCnBigNumber;
begin
  Result := False;
  if (Remainers.Count <> Factors.Count) or (Remainers.Count = 0) then
    Exit;

  Sum := nil;
  G := nil;
  N := nil;

  try
    Sum := FLocalBigNumberPool.Obtain;
    G := FLocalBigNumberPool.Obtain;
    N := FLocalBigNumberPool.Obtain;

    BigNumberSetZero(Sum);
    for I := 0 to Remainers.Count - 1 do
    begin
      // ����ÿһ�������Ͷ�Ӧ�������ҳ����������Ĺ������г��Ըó����� 1 �������漰��ģ��Ԫ����
      // �� 5 7 �Ĺ����� 35n���� 3 �� 1 ���� 70��3 7 �� 5 �� 1 ���� 21��3 5 �� 7 �� 1 ���� 14
      // Ȼ��������͸�ģ��Ԫ���
      // ���еĳ˻���������mod һ��ȫ������ǵ���С���������͵õ������

      G.SetOne;
      for J := 0 to Factors.Count - 1 do
        if J <> I then
          if not BigNumberMul(G, G, Factors[J]) then
            Exit;

      // G �˿�����С����������Ϊ Factors ����
      // �� X ��� M ��ģ��Ԫ��Ҳ����ģ��Ԫ Y������ (X * Y) mod M = 1
      BigNumberModularInverse(N, G, Factors[I]);

      if not BigNumberMul(G, N, G) then // �õ�����
        Exit;

      if not BigNumberMul(G, Remainers[I], G) then // �������������
        Exit;

      if not BigNumberAdd(Sum, Sum, G) then // ���
        Exit;
    end;

    G.SetOne;
    for J := 0 to Factors.Count - 1 do
      if not BigNumberMul(G, G, Factors[J]) then
        Exit;

    Result := BigNumberMod(Res, Sum, G);
  finally
    FLocalBigNumberPool.Recycle(N);
    FLocalBigNumberPool.Recycle(G);
    FLocalBigNumberPool.Recycle(Sum);
  end;
end;

function BigNumberChineseRemainderTheorem(Res: TCnBigNumber;
  Remainers, Factors: TCnInt64List): Boolean; overload;
var
  I: Integer;
  BR, BF: TCnBigNumberList;
begin
  BR := nil;
  BF := nil;

  try
    BR := TCnBigNumberList.Create;
    BF := TCnBigNumberList.Create;

    for I := 0 to Remainers.Count - 1 do
      BR.Add.SetInt64(Remainers[I]);

    for I := 0 to Factors.Count - 1 do
      BF.Add.SetInt64(Factors[I]);

    Result := BigNumberChineseRemainderTheorem(Res, BR, BF);
  finally
    BF.Free;
    BR.Free;
  end;
end;

function BigNumberIsPerfectPower(Num: TCnBigNumber): Boolean;
var
  LG2, I: Integer;
  T: TCnBigNumber;
begin
  Result := False;
  if Num.IsNegative or Num.IsWord(2) or Num.IsWord(3) then
    Exit;

  if Num.IsZero or Num.IsOne then
  begin
    Result := True;
    Exit;
  end;

  LG2 := Num.GetBitsCount;
  T := FLocalBigNumberPool.Obtain;

  try
    for I := 2 to LG2 do
    begin
      // �� Num �� I �η�������������
      BigNumberRoot(T, Num, I);
      // ��������������
      BigNumberPower(T, T, I);

      // �ж��Ƿ����
      if BigNumberCompare(T, Num) = 0 then
      begin
        Result := True;
        Exit;
      end;
    end;
  finally
    FLocalBigNumberPool.Recycle(T);
  end;
end;

procedure BigNumberFillCombinatorialNumbers(List: TCnBigNumberList; N: Integer);
var
  M, MC: Integer;
  C, T: TCnBigNumber;
begin
  if (N < 0) or (List = nil) then
    Exit;

  List.Clear;
  List.Add.SetOne;
  if N = 0 then
    Exit;

  MC := N div 2;

  List.Count := N + 1;    // C(n, m) m �� 0 �� n��һ�� n+1 ��
  C := TCnBigNumber.Create;
  C.SetOne;
  List[N] := C;

  C := FLocalBigNumberPool.Obtain;
  C.SetOne;
  try
    for M := 0 to MC - 1 do
    begin
      T := TCnBigNumber.Create;
      BigNumberCopy(T, C);
      BigNumberMulWord(T, N - M);
      BigNumberDivWord(T, M + 1);

      List[M + 1] := T;
      if M + 1 <> N - M - 1 then
        List[N - M - 1] := BigNumberDuplicate(T);
      BigNumberCopy(C, T);
    end;
  finally
    FLocalBigNumberPool.Recycle(C);
  end;
end;

procedure BigNumberFillCombinatorialNumbersMod(List: TCnBigNumberList; N: Integer; P: TCnBigNumber);
var
  I: Integer;
begin
  if (P = nil) or (N < 0) then
    Exit;

  BigNumberFillCombinatorialNumbers(List, N);
  for I := 0 to List.Count - 1 do
    BigNumberNonNegativeMod(List[I], List[I], P);
end;

function BigNumberAKSIsPrime(N: TCnBigNumber): Boolean;
var
  NR: Boolean;
  R, T, C, Q: TCnBigNumber;
  K, LG22: Integer;
  LG2: Extended;
  BK: TCnBigNumber;
begin
  Result := False;
  if N.IsNegative or N.IsZero or N.IsOne then
    Exit;
  if BigNumberIsPerfectPower(N) then // �������ȫ�����Ǻ���
    Exit;

  R := nil;
  T := nil;
  C := nil;
  Q := nil;
  BK := nil;

  try
    // �ҳ���С�� R ���� ŷ��(R) > (Log����(N))^2��
    NR := True;

    R := FLocalBigNumberPool.Obtain;
    R.SetOne;
    LG2 := BigNumberLog2(N);
    // LG2 := GetUInt64HighBits(N); // �����������
    LG22 := Trunc(LG2 * LG2);

    T := FLocalBigNumberPool.Obtain;
    BK := FLocalBigNumberPool.Obtain;
    // �ҳ���С�� R
    while NR do
    begin
      R.AddWord(1);
      NR := False;

      K := 1;
      while not NR and (K <= LG22) do
      begin
        BK.SetWord(K);
        BigNumberPowerMod(T, N, BK, R);
        NR := T.IsZero or T.IsOne;
        Inc(K);
      end;
    end;

    // �õ� R�����ĳЩ�� R С�� T �� N �����أ����Ǻ���
    BigNumberCopy(T, R);
    C := FLocalBigNumberPool.Obtain;

    while BigNumberCompare(T, CnBigNumberOne) > 0 do
    begin
      BigNumberGcd(C, T, N);
      if (BigNumberCompare(C, CnBigNumberOne) > 0) and (BigNumberCompare(C, N) < 0) then
        Exit;

      T.SubWord(1);
    end;

    if BigNumberCompare(N, R) <= 0 then
    begin
      Result := True;
      Exit;
    end;

    Q := FLocalBigNumberPool.Obtain;
    BigNumberEuler(Q, R);
    BigNumberSqrt(Q, Q);
    BigNumberMulFloat(C, Q, LG2);
    // �˴�Ӧ����С�����㣬��Ϊ����������ϴ����
    // C := Trunc(Sqrt(Q) * LG2);

    // ���ڻ� (X^R-1, N) ����ǰ���� (X+Y)^N - (X^N + Y)��
    // Ҳ���� (X+Y)^N - (X^N + Y) չ������� X^R-1 ���࣬��ϵ������� N ȡģ
    // ���ݶ���ʽ���� (X+Y)^N չ�������ϵ�� mod N �󣬾ͱ���� X^N+Y^N��������������Ϊ 0
    // �� mod X^R - 1 ����ݼӷ���ģ����õ����� X^(N-R) + Y^N
    // X^N + Y �� X^R-1 ȡģ���� X^(N-R) + Y
    // һ�����õ��Ľ����ʵ�� Y^N - Y

    // �� 1 �� ŷ��(R)ƽ���� * (Log����(N)) ������������Ϊ Y������ Y^N - Y mod N �Ƿ��� 0

    T.SetOne;
    while BigNumberCompare(T, C) <= 0 do
    begin
      if not BigNumberPowerMod(R, T, N, N) then // ���� R
        Exit;

      if not BigNumberSub(R, R, T) then
        Exit;

      if not BigNumberMod(R, R, N) then
        Exit;

      if not R.IsZero then
        Exit;

      T.AddWord(1);
    end;

    Result := True;
  finally
    FLocalBigNumberPool.Recycle(R);
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(C);
    FLocalBigNumberPool.Recycle(Q);
    FLocalBigNumberPool.Recycle(BK);
  end;
end;

// ��ӡ�����ڲ���Ϣ
function BigNumberDebugDump(const Num: TCnBigNumber): string;
var
  I: Integer;
begin
  Result := '';
  if Num = nil then
    Exit;

  Result := Format('Neg %d. DMax %d. Top %d.', [Num.Neg, Num.DMax, Num.Top]);
  if (Num.D <> nil) and (Num.Top > 0) then
    for I := 0 to Num.Top do
      Result := Result + Format(' $%8.8x', [PLongWordArray(Num.D)^[I]]);
end;

function SparseBigNumberListIsZero(P: TCnSparseBigNumberList): Boolean;
begin
  Result := (P = nil) or (P.Count = 0) or
    ((P.Count = 1) and (P[0].Exponent = 0) and (P[0].Value.IsZero));
end;

function SparseBigNumberListEqual(A, B: TCnSparseBigNumberList): Boolean;
var
  I: Integer;
begin
  Result := False;
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  if (A = nil) and (B <> nil)then // һ���� nil����Ҫ�ж�����һ���ǲ��� 0
  begin
    if (B.Count = 0) or ((B.Count = 1) and (B[0].Exponent = 0) and B[0].Value.IsZero) then
    begin
      Result := True;
      Exit;
    end;
  end
  else if (B = nil) and (A <> nil) then
  begin
    if (A.Count = 0) or ((A.Count = 1) and (A[0].Exponent = 0) and A[0].Value.IsZero) then
    begin
      Result := True;
      Exit;
    end;
  end;

  if A.Count <> B.Count then
    Exit;

  for I := A.Count - 1 downto 0 do
  begin
    if (A[I].Exponent <> B[I].Exponent) or not BigNumberEqual(A[I].Value, B[I].Value) then
      Exit;
  end;
  Result := True;
end;

procedure SparseBigNumberListCopy(Dst, Src: TCnSparseBigNumberList);
var
  I: Integer;
  Pair: TCnExponentBigNumberPair;
begin
  if (Dst <> Src) and (Dst <> nil) then
  begin
    Dst.Clear;
    for I := 0 to Src.Count - 1 do
    begin
      Pair := TCnExponentBigNumberPair.Create;
      Pair.Exponent := Src[I].Exponent;
      BigNumberCopy(Pair.Value, Src[I].Value);
      Dst.Add(Pair);
    end;
  end;
end;

procedure SparseBigNumberListMerge(Dst, Src1, Src2: TCnSparseBigNumberList; Add: Boolean);
var
  I, J, K: Integer;
  P1, P2: TCnExponentBigNumberPair;
begin
  if Src1 = nil then                   // ֻҪ��һ���� nil��Dst �ͱ���Ϊ��һ��
  begin
    SparseBigNumberListCopy(Dst, Src2);
    if not Add then  // Src2 �Ǳ�����
      Dst.Negate;
  end
  else if Src2 = nil then
    SparseBigNumberListCopy(Dst, Src1)
  else if Src1 = Src2 then // ��� Src1 �� Src2 ��ͬһ�����ϲ���֧�� Dst Ҳ��ͬһ��������
  begin
    Dst.Count := Src1.Count;
    for I := 0 to Src1.Count - 1 do
    begin
      if Dst[I] = nil then
        Dst[I] := TCnExponentBigNumberPair.Create;
      Dst[I].Exponent := Src1[I].Exponent;
      if Add then
        BigNumberAdd(Dst[I].Value, Src1[I].Value, Src2[I].Value)
      else
        BigNumberSub(Dst[I].Value, Src1[I].Value, Src2[I].Value);
    end;
  end
  else // Src1 �� Src2 ����ͬһ����Ҫ�鲢
  begin
    if (Dst <> Src1) and (Dst <> Src2) then // �� Dst ���� Src1 �� Src2��Ҳ���������
    begin
      I := 0;
      J := 0;
      K := 0;

      Dst.Count := Src1.Count + Src2.Count;

      while (I < Src1.Count) and (J < Src2.Count) do
      begin
        P1 := Src1[I];
        P2 := Src2[J];

        if P1.Exponent = P2.Exponent then
        begin
          // ��ȣ����������� Dst ��
          if Dst[K] = nil then
            Dst[K] := TCnExponentBigNumberPair.Create;
          Dst[K].Exponent := P1.Exponent;

          if Add then
            BigNumberAdd(Dst[K].Value, P1.Value, P2.Value)
          else
            BigNumberSub(Dst[K].Value, P1.Value, P2.Value);

          Inc(I);
          Inc(J);
          Inc(K);
        end
        else if P1.Exponent < P2.Exponent then
        begin
          // P1 С���� P1 �� Dst[K] ��
          if Dst[K] = nil then
            Dst[K] := TCnExponentBigNumberPair.Create;
          Dst[K].Exponent := P1.Exponent;

          BigNumberCopy(Dst[K].Value, P1.Value);
          Inc(I);
          Inc(K);
        end
        else // P2 С���� P2 �� Dst[K] ��
        begin
          if Dst[K] = nil then
            Dst[K] := TCnExponentBigNumberPair.Create;
          Dst[K].Exponent := P2.Exponent;

          BigNumberCopy(Dst[K].Value, P2.Value);
          if not Add then
            Dst[K].Value.Negate;
          Inc(J);
          Inc(K);
        end;
      end;

      if (I = Src1.Count) and (J = Src2.Count) then
      begin
        Dst.Compact;
        Exit;
      end;

      // ʣ���ĸ��У���ȫ�ӵ� Dst �� K ��ʼ��λ��ȥ
      if I = Src1.Count then
      begin
        for I := J to Src2.Count - 1 do
        begin
          if K >= Dst.Count then
            Dst.Add(TCnExponentBigNumberPair.Create)
          else if Dst[K] = nil then
            Dst[K] := TCnExponentBigNumberPair.Create;

          Dst[K].Exponent := Src2[I].Exponent;
          BigNumberCopy(Dst[K].Value, Src2[I].Value);
          Inc(K);
        end;
      end
      else if J = Src2.Count then
      begin
        for J := I to Src1.Count - 1 do
        begin
          if K >= Dst.Count then
            Dst.Add(TCnExponentBigNumberPair.Create)
          else if Dst[K] = nil then
            Dst[K] := TCnExponentBigNumberPair.Create;

          Dst[K].Exponent := Src1[J].Exponent;
          BigNumberCopy(Dst[K].Value, Src1[J].Value);
          Inc(K);
        end;
      end;
      Dst.Compact;
    end
    else if Dst = Src1 then // Dst �� Src1���� Src1 �� Src2 ��ͬ
    begin
      // ���� Src2�������� Src1 ��
      for I := 0 to Src2.Count - 1 do
      begin
        P2 := Src2[I];
        if Add then
          BigNumberAdd(Dst.SafeValue[P2.Exponent], Dst.SafeValue[P2.Exponent], P2.Value)
        else
          BigNumberSub(Dst.SafeValue[P2.Exponent], Dst.SafeValue[P2.Exponent], P2.Value);
      end;
    end
    else if Dst = Src2 then // Dst �� Src2���� Src1 �� Src2 ��ͬ
    begin
      // ���� Src1�������� Src2 ��
      for I := 0 to Src1.Count - 1 do
      begin
        P1 := Src1[I];
        if Add then
          BigNumberAdd(Dst.SafeValue[P1.Exponent], Dst.SafeValue[P1.Exponent], P1.Value)
        else
          BigNumberSub(Dst.SafeValue[P1.Exponent], Dst.SafeValue[P1.Exponent], P1.Value);
      end;
    end;
  end;
end;

{ TCnBigNumber }

function TCnBigNumber.AddWord(W: TCnLongWord32): Boolean;
begin
  Result := BigNumberAddWord(Self, W);
end;

procedure TCnBigNumber.Clear;
begin
  BigNumberClear(Self);
end;

function TCnBigNumber.ClearBit(N: Integer): Boolean;
begin
  Result := BigNumberClearBit(Self, N);
end;

constructor TCnBigNumber.Create;
begin
  inherited;
  Top := 0;
  Neg := 0;
  DMax := 0;
  D := nil;
end;

destructor TCnBigNumber.Destroy;
begin
{$IFDEF DEBUG}
  if FIsFromPool then
    raise Exception.Create('Error. Try to Free a Big Number From Pool.');
{$ENDIF}

  if D <> nil then
    FreeMemory(D);

  D := nil;
  inherited;
end;

function TCnBigNumber.DivWord(W: TCnLongWord32): TCnLongWord32;
begin
  Result := BigNumberDivWord(Self, W);
end;

class function TCnBigNumber.FromBinary(Buf: PAnsiChar;
  Len: Integer): TCnBigNumber;
begin
  Result := BigNumberFromBinary(Buf, Len);
end;

{$IFDEF TBYTES_DEFINED}

class function TCnBigNumber.FromBytes(Buf: TBytes): TCnBigNumber;
begin
  Result := BigNumberFromBytes(Buf);
end;

function TCnBigNumber.ToBytes: TBytes;
begin
  Result := BigNumberToBytes(Self);
end;

{$ENDIF}

class function TCnBigNumber.FromDec(const Buf: AnsiString): TCnBigNumber;
begin
  Result := BigNumberFromDec(Buf);
end;

class function TCnBigNumber.FromHex(const Buf: AnsiString): TCnBigNumber;
begin
  Result := BigNumberFromHex(Buf);
end;

function TCnBigNumber.GetBitsCount: Integer;
begin
  Result := BigNumberGetBitsCount(Self);
end;

function TCnBigNumber.GetBytesCount: Integer;
begin
  Result := BigNumberGetBytesCount(Self);
end;

function TCnBigNumber.GetWord: TCnLongWord32;
begin
  Result := BigNumberGetWord(Self);
end;

{$IFDEF SUPPORT_UINT64}

function TCnBigNumber.GetUInt64: UInt64;
begin
  Result := BigNumberGetUInt64(Self);
end;

{$ENDIF}

procedure TCnBigNumber.Init;
begin
  BigNumberInit(Self);
end;

function TCnBigNumber.IsBitSet(N: Integer): Boolean;
begin
  Result := BigNumberIsBitSet(Self, N);
end;

function TCnBigNumber.IsNegative: Boolean;
begin
  Result := BigNumberIsNegative(Self);
end;

function TCnBigNumber.IsOdd: Boolean;
begin
  Result := BigNumberIsOdd(Self);
end;

function TCnBigNumber.IsOne: Boolean;
begin
  Result := BigNumberIsOne(Self);
end;

function TCnBigNumber.IsNegOne: Boolean;
begin
  Result := BigNumberIsNegOne(Self);
end;

function TCnBigNumber.IsWord(W: TCnLongWord32): Boolean;
begin
  Result := BigNumberIsWord(Self, W);
end;

function TCnBigNumber.IsZero: Boolean;
begin
  Result := BigNumberIsZero(Self);
end;

function TCnBigNumber.ModWord(W: TCnLongWord32): TCnLongWord32;
begin
  Result := BigNumberModWord(Self, W);
end;

function TCnBigNumber.MulWord(W: TCnLongWord32): Boolean;
begin
  Result := BigNumberMulWord(Self, W);
end;

function TCnBigNumber.SetBit(N: Integer): Boolean;
begin
  Result := BigNumberSetBit(Self, N);
end;

function TCnBigNumber.SetDec(const Buf: AnsiString): Boolean;
begin
  Result := BigNumberSetDec(Buf, Self);
end;

function TCnBigNumber.SetBinary(Buf: PAnsiChar; Len: Integer): Boolean;
begin
  Result := BigNumberSetBinary(Buf, Len, Self);
end;

function TCnBigNumber.SetHex(const Buf: AnsiString): Boolean;
begin
  Result := BigNumberSetHex(Buf, Self);
end;

procedure TCnBigNumber.SetNegative(Negative: Boolean);
begin
  BigNumberSetNegative(Self, Negative);
end;

function TCnBigNumber.SetOne: Boolean;
begin
  Result := BigNumberSetOne(Self);
end;

function TCnBigNumber.SetWord(W: TCnLongWord32): Boolean;
begin
  Result := BigNumberSetWord(Self, W);
end;

{$IFDEF SUPPORT_UINT64}

function TCnBigNumber.SetUInt64(W: UInt64): Boolean;
begin
  Result := BigNumberSetUInt64(Self, W);
end;

{$ENDIF}

function TCnBigNumber.SetZero: Boolean;
begin
  Result := BigNumberSetZero(Self);
end;

function TCnBigNumber.SubWord(W: TCnLongWord32): Boolean;
begin
  Result := BigNumberSubWord(Self, W);
end;

function TCnBigNumber.ToBinary(const Buf: PAnsiChar): Integer;
begin
  Result := BigNumberToBinary(Self, Buf);
end;

function TCnBigNumber.ToDec: string;
begin
  Result := string(BigNumberToDec(Self));
end;

function TCnBigNumber.ToHex(FixedLen: Integer): string;
begin
  Result := BigNumberToHex(Self, FixedLen);
end;

function TCnBigNumber.ToString: string;
begin
  Result := BigNumberToString(Self);
end;

function TCnBigNumber.WordExpand(Words: Integer): TCnBigNumber;
begin
  Result := BigNumberWordExpand(Self, Words);
end;


function TCnBigNumber.GetDecString: string;
begin
  Result := ToDec;
end;

function TCnBigNumber.GetHexString: string;
begin
  Result := ToHex;
end;

function TCnBigNumber.GetDebugDump: string;
begin
  Result := BigNumberDebugDump(Self);
end;

function TCnBigNumber.GetInt64: Int64;
begin
  Result := BigNumberGetInt64(Self);
end;

function TCnBigNumber.SetInt64(W: Int64): Boolean;
begin
  Result := BigNumberSetInt64(Self, W);
end;

procedure TCnBigNumber.Negate;
begin
  BigNumberNegate(Self);
end;

function TCnBigNumber.PowerWord(W: TCnLongWord32): Boolean;
begin
  Result := BigNumberPower(Self, Self, W);
end;

function TCnBigNumber.GetTenPrecision: Integer;
begin
  Result := BigNumberGetTenPrecision(Self);
end;

procedure TCnBigNumber.ShiftLeft(N: Integer);
begin
  BigNumberShiftLeft(Self, Self, N);
end;

procedure TCnBigNumber.ShiftRight(N: Integer);
begin
  BigNumberShiftRight(Self, Self, N);
end;

procedure TCnBigNumber.ShiftLeftOne;
begin
  BigNumberShiftLeftOne(Self, Self);
end;

procedure TCnBigNumber.ShiftRightOne;
begin
  BigNumberShiftRightOne(Self, Self);
end;

function TCnBigNumber.GetInteger: Integer;
begin
  Result := BigNumberGetInteger(Self);
end;

function TCnBigNumber.SetInteger(W: Integer): Boolean;
begin
  Result := BigNumberSetInteger(Self, W);
end;

function TCnBigNumber.GetWordCount: Integer;
begin
  Result := BigNumberGetWordsCount(Self);
end;

{ TCnBigNumberList }

function TCnBigNumberList.Add(ABigNumber: TCnBigNumber): Integer;
begin
  Result := inherited Add(ABigNumber);
end;

function TCnBigNumberList.Add: TCnBigNumber;
begin
  Result := TCnBigNumber.Create;
  Add(Result);
end;

constructor TCnBigNumberList.Create;
begin
  inherited Create(True);
end;

function TCnBigNumberList.GetItem(Index: Integer): TCnBigNumber;
begin
  Result := TCnBigNumber(inherited GetItem(Index));
end;

function TCnBigNumberList.IndexOfValue(ABigNumber: TCnBigNumber): Integer;
begin
  Result := 0;
  while (Result < Count) and (BigNumberCompare(Items[Result], ABigNumber) <> 0) do
    Inc(Result);
  if Result = Count then
    Result := -1;
end;

procedure TCnBigNumberList.Insert(Index: Integer;
  ABigNumber: TCnBigNumber);
begin
  inherited Insert(Index, ABigNumber);
end;

function TCnBigNumberList.Remove(ABigNumber: TCnBigNumber): Integer;
begin
  Result := inherited Remove(ABigNumber);
end;

procedure TCnBigNumberList.RemoveDuplicated;
var
  I, Idx: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    // ȥ���ظ�����
    Idx := IndexOfValue(Items[I]);
    if (Idx >= 0) and (Idx <> I) then
      Delete(I);
  end;
end;

procedure TCnBigNumberList.SetItem(Index: Integer;
  ABigNumber: TCnBigNumber);
begin
  inherited SetItem(Index, ABigNumber);
end;

{ TCnBigNumberPool }

function TCnBigNumberPool.CreateObject: TObject;
begin
  Result := TCnBigNumber.Create;
end;

function TCnBigNumberPool.Obtain: TCnBigNumber;
begin
  Result := TCnBigNumber(inherited Obtain);
  Result.Clear;
end;

procedure TCnBigNumberPool.Recycle(Num: TCnBigNumber);
begin
  inherited Recycle(Num);
end;

{ TCnExponentBigNumberPair }

constructor TCnExponentBigNumberPair.Create;
begin
  inherited;
  FValue := TCnBigNumber.Create;
  FValue.SetZero;
end;

destructor TCnExponentBigNumberPair.Destroy;
begin
  FValue.Free;
  inherited;
end;

function TCnExponentBigNumberPair.ToString: string;
begin
  Result := '^' + IntToStr(FExponent) + ' ' + FValue.ToDec;
end;

{ TCnSparseBigNumberList }

function TCnSparseBigNumberList.AddPair(AExponent: Integer;
  Num: TCnBigNumber): TCnExponentBigNumberPair;
begin
  Result := TCnExponentBigNumberPair.Create;
  Result.Exponent := AExponent;
  BigNumberCopy(Result.Value, Num);
  Add(Result);
end;

procedure TCnSparseBigNumberList.AssignTo(Dest: TCnSparseBigNumberList);
begin
  SparseBigNumberListCopy(Dest, Self);
end;

function TCnSparseBigNumberList.BinarySearchExponent(AExponent: Integer;
  var OutIndex: Integer): Boolean;
var
  I, Start,Stop, Mid: Integer;
  Pair: TCnExponentBigNumberPair;
  BreakFromStart: Boolean;
begin
  Result := False;
  if Count = 0 then
  begin
    OutIndex := MaxInt;
  end
  else if Count <= SPARSE_BINARY_SEARCH_THRESHOLD then
  begin
    // �����٣�ֱ����
    for I := 0 to Count - 1 do
    begin
      Pair := Items[I];
      if Pair.Exponent = AExponent then
      begin
        Result := True;
        OutIndex := I;
        Exit;
      end
      else if Pair.Exponent > AExponent then
      begin
        OutIndex := I;
        Exit;
      end;
    end;
    // AExponent �����һ�� Pair �Ļ���
    OutIndex := MaxInt;
  end
  else
  begin
    Pair := Top;
    if Pair.Exponent < AExponent then      // AExponent �����һ�� Pair �Ļ���
    begin
      OutIndex := MaxInt;
      Exit;
    end
    else if Pair.Exponent = AExponent then // AExponent ���������һ�� Pair
    begin
      OutIndex := Count - 1;
      Result := True;
      Exit;
    end
    else
    begin
      Pair := Bottom;
      if Pair.Exponent > AExponent then    // AExponent �ȵ�һ�� Pair �Ļ�С
      begin
        OutIndex := 0;
        Exit;
      end
      else if Pair.Exponent = AExponent then // AExponent �����ǵ�һ�� Pair
      begin
        OutIndex := 0;
        Result := True;
        Exit;
      end
    end;

    // ��ʼ�����Ķ��ֲ���
    Start := 0;
    Stop := Count - 1;
    Mid := 0;
    BreakFromStart := False;

    while Start <= Stop do
    begin
      Mid := (Start + Stop) div 2;

      Pair := Items[Mid];
      if Pair.Exponent = AExponent then
      begin
        Result := True;
        OutIndex := Mid;
        Exit;
      end
      else if Pair.Exponent < AExponent then
      begin
        Start := Mid + 1; // ������һ���Ǵ����˳��������λ��Ϊ Mid + 1
        BreakFromStart := True;
      end
      else if Pair.Exponent > AExponent then
      begin
        Stop := Mid - 1;  // ������һ���Ǵ����˳��������λ��Ϊ Mid - 1
        BreakFromStart := False;
      end;
    end;

    if BreakFromStart then
      OutIndex := Mid + 1
    else
      OutIndex := Mid;
    Result := False;
  end;
end;

function TCnSparseBigNumberList.Bottom: TCnExponentBigNumberPair;
begin
  Result := nil;
  if Count > 0 then
    Result := Items[0];
end;

procedure TCnSparseBigNumberList.Compact;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if (Items[I] = nil) or Items[I].Value.IsZero then
      Delete(I);
end;

constructor TCnSparseBigNumberList.Create;
begin
  inherited Create(True);
end;

function TCnSparseBigNumberList.GetItem(Index: Integer): TCnExponentBigNumberPair;
begin
  Result := TCnExponentBigNumberPair(inherited GetItem(Index));
end;

function TCnSparseBigNumberList.GetReadonlyValue(Exponent: Integer): TCnBigNumber;
var
  OutIndex: Integer;
begin
  if not BinarySearchExponent(Exponent, OutIndex) then
    Result := CnBigNumberZero
  else
    Result := Items[OutIndex].Value;
end;

function TCnSparseBigNumberList.GetSafeValue(Exponent: Integer): TCnBigNumber;
var
  OutIndex: Integer;
begin
  if not BinarySearchExponent(Exponent, OutIndex) then
  begin
    // δ�ҵ���Ҫ����
    OutIndex := InsertByOutIndex(OutIndex);
    Items[OutIndex].Exponent := Exponent;
  end;
  Result := Items[OutIndex].Value;
end;

function TCnSparseBigNumberList.InsertByOutIndex(
  OutIndex: Integer): Integer;
var
  Pair: TCnExponentBigNumberPair;
begin
  if OutIndex < 0 then
    OutIndex := 0;

  Pair := TCnExponentBigNumberPair.Create;
  if OutIndex >= Count then
  begin
    Add(Pair);
    Result := Count - 1;
  end
  else
  begin
    Insert(OutIndex, Pair);
    Result := OutIndex;
  end;
end;

procedure TCnSparseBigNumberList.Negate;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if (Items[I] <> nil) then
      Items[I].Value.Negate;
end;

procedure TCnSparseBigNumberList.SetItem(Index: Integer;
  const Value: TCnExponentBigNumberPair);
begin
  inherited SetItem(Index, Value);
end;

procedure TCnSparseBigNumberList.SetSafeValue(Exponent: Integer;
  const Value: TCnBigNumber);
var
  OutIndex: Integer;
begin
  if not BinarySearchExponent(Exponent, OutIndex) then
  begin
    // δ�ҵ������ Value �޻� 0����Ҫ����
    if (Value <> nil) and not Value.IsZero then
    begin
      OutIndex := InsertByOutIndex(OutIndex);
      Items[OutIndex].Exponent := Exponent;
    end
    else // δ�ҵ����� 0������
      Exit;
  end;

  // �ҵ��˻��߲����ˣ���ֵ
  if (Value <> nil) and not Value.IsZero then
    BigNumberCopy(Items[OutIndex].Value, Value)
  else
    Items[OutIndex].Value.SetZero;
end;

procedure TCnSparseBigNumberList.SetValues(LowToHighList: array of Int64);
var
  I: Integer;
  Pair: TCnExponentBigNumberPair;
begin
  Clear;
  for I := Low(LowToHighList) to High(LowToHighList) do
  begin
    Pair := TCnExponentBigNumberPair.Create;
    Pair.Exponent := I;
    Pair.Value.SetInt64(LowToHighList[I]);
    Add(Pair);
  end;
end;

function TCnSparseBigNumberList.Top: TCnExponentBigNumberPair;
begin
  Result := nil;
  if Count > 0 then
    Result := Items[Count - 1];
end;

function TCnSparseBigNumberList.ToString: string;
var
  I: Integer;
  IsFirst: Boolean;
begin
  Result := '';
  IsFirst := True;
  for I := Count - 1 downto 0 do
  begin
    if IsFirst then
    begin
      Result := Items[I].ToString;
      IsFirst := False;
    end
    else
      Result := Result + CRLF + Items[I].ToString;
  end;
end;

initialization
  FLocalBigNumberPool := TCnBigNumberPool.Create;

  CnBigNumberOne := TCnBigNumber.Create;
  CnBigNumberOne.SetOne;
  CnBigNumberZero := TCnBigNumber.Create;
  CnBigNumberZero.SetZero;

finalization
//  CnBigNumberZero.DecString;  // �ֹ������������ֹ������������
//  CnBigNumberZero.DebugDump;

  CnBigNumberOne.Free;
  CnBigNumberZero.Free;
  FLocalBigNumberPool.Free;
  FLocalBigBinaryPool.Free;

end.

