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

unit CnNativeDecl;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����
* ��Ԫ���ƣ�32 λ�� 64 λ��һЩͳһ����
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��Delphi XE 2 ֧�� 32 �� 64 ���������ų��� NativeInt �� NativeUInt ��
*           ��ǰ�� 32 λ���� 64 ����̬�仯��Ӱ�쵽���� Pointer��Reference�ȶ�����
*           ���ǵ������ԣ��̶����ȵ� 32 λ Cardinal/Integer �Ⱥ� Pointer ��Щ��
*           ������ͨ���ˣ���ʹ 32 λ��Ҳ����������ֹ����˱���Ԫ�����˼������ͣ�
*           ��ͬʱ�ڵͰ汾�͸߰汾�� Delphi ��ʹ�á�
*           �������� UInt64 �İ�װ��ע�� D567 �²�ֱ��֧��UInt64 �����㣬��Ҫ��
*           ��������ʵ�֣�Ŀǰʵ���� div �� mod
* ����ƽ̨��PWin2000 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 XE 2
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2020.09.06 V1.5
*               ������ UInt64 ����ƽ�����ĺ���
*           2020.07.01 V1.5
*               �����ж� 32 λ�� 64 λ���޷���������Ƿ�����ĺ���
*           2020.06.20 V1.4
*               ���� 32 λ�� 64 λ��ȡ�������͵� 1 λλ�õĺ���
*           2020.01.01 V1.3
*               ���� 32 λ�޷������͵� mul ���㣬�ڲ�֧�� UInt64 ��ϵͳ���� Int64 �����Ա������
*           2018.06.05 V1.2
*               ���� 64 λ���͵� div/mod ���㣬�ڲ�֧�� UInt64 ��ϵͳ���� Int64 ���� 
*           2016.09.27 V1.1
*               ���� 64 λ���͵�һЩ����
*           2011.07.06 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, SysConst {$IFDEF MACOS}, System.Generics.Collections {$ENDIF};

type
{$IFDEF SUPPORT_32_AND_64}
  TCnNativeInt     = NativeInt;
  TCnNativeUInt    = NativeUInt;
  TCnNativePointer = NativeUInt;
{$ELSE}
  TCnNativeInt     = Integer;
  TCnNativeUInt    = Cardinal;
  TCnNativePointer = Cardinal;
{$ENDIF}

{$IFDEF WIN64}
  TCnUInt64        = NativeUInt;
  TCnInt64         = NativeInt;
{$ELSE}
  {$IFDEF SUPPORT_UINT64}
  TCnUInt64        = UInt64;
  {$ELSE}
  TCnUInt64 = packed record  // ֻ���������Ľṹ����
    case Boolean of
      True:  (Value: Int64);
      False: (Low32, Hi32: Cardinal);
  end;
  {$ENDIF}
  TCnInt64         = Int64;
{$ENDIF}

// TUInt64 ���� cnvcl ���в�֧�� UInt64 �������� div mod ��
{$IFDEF SUPPORT_UINT64}
  TUInt64          = UInt64;
{$ELSE}
  TUInt64          = Int64;
  PUInt64          = ^TUInt64;
{$ENDIF}

  TUInt64Array = array of TUInt64;

{$IFDEF MACOS}
  TCnUInt32List = TList<LongWord>;
  TCnUInt64List = TList<UInt64>;
{$ENDIF}

const
  MAX_TUINT64: TUInt64                   = $FFFFFFFFFFFFFFFF;
  MAX_SIGNED_INT64_IN_TUINT64: TUInt64   = $7FFFFFFFFFFFFFFF;

type
  TCnIntegerList = class(TList)
  {* �����б�}
  private
    function Get(Index: Integer): Integer;
    procedure Put(Index: Integer; const Value: Integer);
  public
    function Add(Item: Integer): Integer; reintroduce;
    procedure Insert(Index: Integer; Item: Integer); reintroduce;
    property Items[Index: Integer]: Integer read Get write Put; default;
  end;

  PInt64List = ^TInt64List;
  TInt64List = array[0..MaxListSize - 1] of Int64;

  TCnInt64List = class(TObject)
  {* 64 λ�����б�}
  private
    FList: PInt64List;
    FCount: Integer;
    FCapacity: Integer;
  protected
    function Get(Index: Integer): Int64;
    procedure Grow; virtual;
    procedure Put(Index: Integer; Item: Int64);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  public
    destructor Destroy; override;
    function Add(Item: Int64): Integer;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    class procedure Error(const Msg: string; Data: Integer); virtual;
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TCnInt64List;
    function First: Int64;
    function IndexOf(Item: Int64): Integer;
    procedure Insert(Index: Integer; Item: Int64);
    function Last: Int64;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Int64): Integer;

    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: Int64 read Get write Put; default;
    property List: PInt64List read FList;
  end;

{*
  ���� D567 �Ȳ�֧�� UInt64 �ı���������Ȼ������ Int64 ���� UInt64 ���мӼ����洢
  ���˳��������޷�ֱ����ɣ������װ���������� System ���е� _lludiv �� _llumod
  ������ʵ���� Int64 ��ʾ�� UInt64 ���ݵ� div �� mod ���ܡ�
}
function UInt64Mod(A, B: TUInt64): TUInt64;
{* ���� UInt64 ����}

function UInt64Div(A, B: TUInt64): TUInt64;
{* ���� UInt64 ����}

function UInt64Mul(A, B: Cardinal): TUInt64;
{* �޷��� 32 λ�������������ˣ��ڲ�֧�� UInt64 ��ƽ̨�ϣ������ UInt64 ����ʽ���� Int64 �
  ������ֱ��ʹ�� Int64 �������п������}

function UInt64ToStr(N: TUInt64): string;
{* �� UInt64 ת��Ϊ�ַ���}

function StrToUInt64(const S: string): TUInt64;
{* ���ַ���ת��Ϊ UInt64}

function UInt64Compare(A, B: TUInt64): Integer;
{* �Ƚ����� UInt64 ֵ���ֱ���� > = < ���� 1��0��-1}

function UInt64Sqrt(N: TUInt64): TUInt64;
{* �� UInt64 ��ƽ��������������}

function UInt32IsNegative(N: Cardinal): Boolean;
{* �� Cardinal ������ Integer ʱ�Ƿ�С�� 0}

function UInt64IsNegative(N: TUInt64): Boolean;
{* �� UInt64 ������ Int64 ʱ�Ƿ�С�� 0}

function GetUInt64BitSet(B: TUInt64; Index: Integer): Boolean;
{* ���� Int64 ��ĳһλ�Ƿ��� 1��λ Index �� 0 ��ʼ}

function GetUInt64HighBits(B: TUInt64): Integer;
{* ���� Int64 ���� 1 ����߶�����λ�ǵڼ�λ�����λ�� 0�����û�� 1������ -1}

function GetUInt32HighBits(B: Cardinal): Integer;
{* ���� Cardinal ���� 1 ����߶�����λ�ǵڼ�λ�����λ�� 0�����û�� 1������ -1}

function GetUInt64LowBits(B: TUInt64): Integer;
{* ���� Int64 ���� 1 ����Ͷ�����λ�ǵڼ�λ�����λ�� 0��������ͬ��ĩβ���� 0�����û�� 1������ -1}

function GetUInt32LowBits(B: Cardinal): Integer;
{* ���� Cardinal ���� 1 ����Ͷ�����λ�ǵڼ�λ�����λ�� 0��������ͬ��ĩβ���� 0�����û�� 1������ -1}

function Int64Mod(M, N: Int64): Int64;
{* ��װ�� Int64 Mod��M ������ֵʱȡ����ģ��ģ������ N ��Ҫ������������������}

function IsInt32AddOverflow(A, B: Integer): Boolean;
{* �ж����� 32 λ�з���������Ƿ����}

function IsUInt32AddOverflow(A, B: Cardinal): Boolean;
{* �ж����� 32 λ�޷���������Ƿ����}

function IsInt64AddOverflow(A, B: Int64): Boolean;
{* �ж����� 64 λ�з���������Ƿ����}

function IsUInt64AddOverflow(A, B: TUInt64): Boolean;
{* �ж����� 64 λ�޷���������Ƿ����}

function PointerToInteger(P: Pointer): Integer;
{* ָ������ת�������ͣ�֧�� 32/64 λ}

function IntegerToPointer(I: Integer): Pointer;
{* ����ת����ָ�����ͣ�֧�� 32/64 λ}

implementation

resourcestring
  SCnInt64ListError = 'Int64 List Error. %d';

{$IFDEF WIN64}

function UInt64Mod(A, B: TUInt64): TUInt64;
begin
  Result := A mod B;
end;

function UInt64Div(A, B: TUInt64): TUInt64;
begin
  Result := A div B;
end;

{$ELSE}
{
  UInt64 �� A mod B

  ���õ���ջ˳���� A �ĸ�λ��A �ĵ�λ��B �ĸ�λ��B �ĵ�λ������ push ��ϲ����뺯����
  ESP �Ƿ��ص�ַ��ESP+4 �� B �ĵ�λ��ESP + 8 �� B �ĸ�λ��ESP + C �� A �ĵ�λ��ESP + 10 �� A �ĸ�λ
  ����� push esp �� ESP ���� 4��Ȼ�� mov ebp esp��֮���� EBP ��Ѱַ��ȫҪ��� 4

  �� System.@_llumod Ҫ���ڸս���ʱ��EAX <- A �ĵ�λ��EDX <- A �ĸ�λ����System Դ��ע���� EAX/EDX д���ˣ�
  [ESP + 8]��Ҳ���� EBP + C��<- B �ĸ�λ��[ESP + 4] ��Ҳ���� EBP + 8��<- B �ĵ�λ

  ���� CALL ǰ�����ľ���ƴ��롣UInt64 Div ��Ҳ����
}
function UInt64Mod(A, B: TUInt64): TUInt64;
asm
        // PUSH ESP �� ESP ���� 4��Ҫ����
        MOV     EAX, [EBP + $10]              // A Lo
        MOV     EDX, [EBP + $14]              // A Hi
        PUSH    DWORD PTR[EBP + $C]           // B Hi
        PUSH    DWORD PTR[EBP + $8]           // B Lo
        CALL    System.@_llumod;
end;

function UInt64Div(A, B: TUInt64): TUInt64;
asm
        // PUSH ESP �� ESP ���� 4��Ҫ����
        MOV     EAX, [EBP + $10]              // A Lo
        MOV     EDX, [EBP + $14]              // A Hi
        PUSH    DWORD PTR[EBP + $C]           // B Hi
        PUSH    DWORD PTR[EBP + $8]           // B Lo
        CALL    System.@_lludiv;
end;

{$ENDIF}

{$IFDEF SUPPORT_UINT64}

function UInt64Mul(A, B: Cardinal): TUInt64;
begin
  Result := TUInt64(A) * B;
end;

{$ELSE}

{
  �޷��� 32 λ������ˣ�������ֱ��ʹ�� Int64 �������ģ�� 64 λ�޷�������

  ���üĴ���Լ���� A -> EAX��B -> EDX����ʹ�ö�ջ
  �� System.@_llmul Ҫ���ڸս���ʱ��EAX <- A �ĵ�λ��EDX <- A �ĸ�λ 0��
  [ESP + 8]��Ҳ���� EBP + C��<- B �ĸ�λ 0��[ESP + 4] ��Ҳ���� EBP + 8��<- B �ĵ�λ
}
function UInt64Mul(A, B: Cardinal): TUInt64;
asm
        PUSH    0               // PUSH B ��λ 0
        PUSH    EDX             // PUSH B ��λ
                                // EAX A ��λ���Ѿ�����
        XOR     EDX, EDX        // EDX A ��λ 0
        CALL    System.@_llmul; // ���� EAX �� 32 λ��EDX �� 32 λ
end;

{$ENDIF}


function _ValUInt64(const S: string; var Code: Integer): TUInt64;
const
  FirstIndex = 1;
var
  I: Integer;
  Dig: Integer;
  Sign: Boolean;
  Empty: Boolean;
begin
  I := FirstIndex;
  Dig := 0;
  Result := 0;

  if S = '' then
  begin
    Code := 1;
    Exit;
  end;
  while S[I] = Char(' ') do
    Inc(I);
  Sign := False;
  if S[I] =  Char('-') then
  begin
    Sign := True;
    Inc(I);
  end
  else if S[I] =  Char('+') then
    Inc(I);
  Empty := True;

  if (S[I] =  Char('$')) or (UpCase(S[I]) =  Char('X'))
    or ((S[I] =  Char('0')) and (I < Length(S)) and (UpCase(S[I+1]) =  Char('X'))) then
  begin
    if S[I] =  Char('0') then
      Inc(I);
    Inc(I);
    while True do
    begin
      case   Char(S[I]) of
       Char('0').. Char('9'): Dig := Ord(S[I]) -  Ord('0');
       Char('A').. Char('F'): Dig := Ord(S[I]) - (Ord('A') - 10);
       Char('a').. Char('f'): Dig := Ord(S[I]) - (Ord('a') - 10);
      else
        Break;
      end;
      if Result > (MAX_TUINT64 shr 4) then
        Break;
      if Sign and (Dig <> 0) then
        Break;
      Result := Result shl 4 + Dig;
      Inc(I);
      Empty := False;
    end;
  end
  else
  begin
    while True do
    begin
      case Char(S[I]) of
        Char('0').. Char('9'): Dig := Ord(S[I]) - Ord('0');
      else
        Break;
      end;

      if Result > UInt64Div(MAX_TUINT64, 10) then
        Break;
      if Sign and (Dig <> 0) then
        Break;
      Result := Result * 10 + Dig;
      Inc(I);
      Empty := False;
    end;
  end;

  if (S[I] <> Char(#0)) or Empty then
    Code := I + 1 - FirstIndex
  else
    Code := 0;
end;

function UInt64ToStr(N: TUInt64): string;
begin
  Result := Format('%u', [N]);
end;

function StrToUInt64(const S: string): TUInt64;
{$IFNDEF DELPHIXE6_UP}
var
  E: Integer;
{$ENDIF}
begin
{$IFDEF DELPHIXE6_UP}
  Result := SysUtils.StrToUInt64(S);  // StrToUInt64 only exists under XE6 or above
{$ELSE}
  Result := _ValUInt64(S,  E);
  if E <> 0 then raise EConvertError.CreateResFmt(@SInvalidInteger, [S]);
{$ENDIF}
end;

function UInt64Compare(A, B: TUInt64): Integer;
{$IFNDEF SUPPORT_UINT64}
var
  HiA, HiB, LoA, LoB: LongWord;
{$ENDIF}
begin
{$IFDEF SUPPORT_UINT64}
  if A > B then
    Result := 1
  else if A < B then
    Result := -1
  else
    Result := 0;
{$ELSE}
  HiA := (A and $FFFFFFFF00000000) shr 32;
  HiB := (B and $FFFFFFFF00000000) shr 32;
  if HiA > HiB then
    Result := 1
  else if HiA < HiB then
    Result := -1
  else
  begin
    LoA := LongWord(A and $00000000FFFFFFFF);
    LoB := LongWord(B and $00000000FFFFFFFF);
    if LoA > LoB then
      Result := 1
    else if LoA < LoB then
      Result := -1
    else
      Result := 0;
  end;
{$ENDIF}
end;

function UInt64Sqrt(N: TUInt64): TUInt64;
var
  Rem, Root: TUInt64;
  I: Integer;
begin
  Result := 0;
  if N = 0 then
    Exit;

  if UInt64Compare(N, 4) < 0 then
  begin
    Result := 1;
    Exit;
  end;

  Rem := 0;
  Root := 0;

  for I := 0 to 31 do
  begin
    Root := Root shl 1;
    Inc(Root);

    Rem := Rem shl 2;
    Rem := Rem or (N shr 62);
    N := N shl 2;

    if UInt64Compare(Root, Rem) <= 0 then
    begin
      Rem := Rem - Root;
      Inc(Root);
    end
    else
      Dec(Root);
  end;
  Result := Root shr 1;
end;

function UInt32IsNegative(N: Cardinal): Boolean;
begin
  Result := (N and (1 shl 31)) <> 0;
end;

function UInt64IsNegative(N: TUInt64): Boolean;
begin
{$IFDEF SUPPORT_UINT64}
  Result := (N and (1 shl 63)) <> 0;
{$ELSE}
  Result := N < 0;
{$ENDIF}
end;

// ���� UInt64 �ĵڼ�λ�Ƿ��� 1��0 ��ʼ
function GetUInt64BitSet(B: TUInt64; Index: Integer): Boolean;
begin
  B := B and (TUInt64(1) shl Index);
  Result := B <> 0;
end;

// ���� Int64 ���� 1 ����߶�����λ�ǵڼ�λ�����λ�� 0�����û�� 1������ -1
function GetUInt64HighBits(B: TUInt64): Integer;
begin
  if B = 0 then
  begin
    Result := -1;
    Exit;
  end;

  Result := 1;
  if B shr 32 = 0 then
  begin
   Inc(Result, 32);
   B := B shl 32;
  end;
  if B shr 48 = 0 then
  begin
   Inc(Result, 16);
   B := B shl 16;
  end;
  if B shr 56 = 0 then
  begin
    Inc(Result, 8);
    B := B shl 8;
  end;
  if B shr 60 = 0 then
  begin
    Inc(Result, 4);
    B := B shl 4;
  end;
  if B shr 62 = 0 then
  begin
    Inc(Result, 2);
    B := B shl 2;
  end;
  Result := Result - Integer(B shr 63); // �õ�ǰ�� 0 ������
  Result := 63 - Result;
end;

// ���� Cardinal ���� 1 ����߶�����λ�ǵڼ�λ�����λ�� 0�����û�� 1������ -1
function GetUInt32HighBits(B: Cardinal): Integer;
begin
  if B = 0 then
  begin
    Result := -1;
    Exit;
  end;

  Result := 1;
  if B shr 16 = 0 then
  begin
   Inc(Result, 16);
   B := B shl 16;
  end;
  if B shr 24 = 0 then
  begin
    Inc(Result, 8);
    B := B shl 8;
  end;
  if B shr 28 = 0 then
  begin
    Inc(Result, 4);
    B := B shl 4;
  end;
  if B shr 30 = 0 then
  begin
    Inc(Result, 2);
    B := B shl 2;
  end;
  Result := Result - Integer(B shr 31); // �õ�ǰ�� 0 ������
  Result := 31 - Result;
end;

// ���� Int64 ���� 1 ����Ͷ�����λ�ǵڼ�λ�����λ�� 0�����û�� 1������ -1
function GetUInt64LowBits(B: TUInt64): Integer;
var
  Y: TUInt64;
  N: Integer;
begin
  Result := -1;
  if B = 0 then
    Exit;

  N := 63;
  Y := B shl 32;
  if Y <> 0 then
  begin
    Dec(N, 32);
    B := Y;
  end;
  Y := B shl 16;
  if Y <> 0 then
  begin
    Dec(N, 16);
    B := Y;
  end;
  Y := B shl 8;
  if Y <> 0 then
  begin
    Dec(N, 8);
    B := Y;
  end;
  Y := B shl 4;
  if Y <> 0 then
  begin
    Dec(N, 4);
    B := Y;
  end;
  Y := B shl 2;
  if Y <> 0 then
  begin
    Dec(N, 2);
    B := Y;
  end;
  B := B shl 1;
  Result := N - Integer(B shr 63);
end;

// ���� Cardinal ���� 1 ����Ͷ�����λ�ǵڼ�λ�����λ�� 0�����û�� 1������ -1
function GetUInt32LowBits(B: Cardinal): Integer;
var
  Y, N: Integer;
begin
  Result := -1;
  if B = 0 then
    Exit;

  N := 31;
  Y := B shl 16;
  if Y <> 0 then
  begin
    Dec(N, 16);
    B := Y;
  end;
  Y := B shl 8;
  if Y <> 0 then
  begin
    Dec(N, 8);
    B := Y;
  end;
  Y := B shl 4;
  if Y <> 0 then
  begin
    Dec(N, 4);
    B := Y;
  end;
  Y := B shl 2;
  if Y <> 0 then
  begin
    Dec(N, 2);
    B := Y;
  end;
  B := B shl 1;
  Result := N - Integer(B shr 31);
end;

// ��װ�� Int64 Mod��������ֵʱȡ����ģ��ģ��
function Int64Mod(M, N: Int64): Int64;
begin
  if M > 0 then
    Result := M mod N
  else
    Result := N - ((-M) mod N);
end;

// �ж����� 32 λ�з���������Ƿ����
function IsInt32AddOverflow(A, B: Integer): Boolean;
var
  C: Integer;
begin
  C := A + B;
  Result := ((A > 0) and (B > 0) and (C < 0)) or   // ͬ�����ҽ��������˵�����������
    ((A < 0) and (B < 0) and (C > 0));
end;

// �ж����� 32 λ�޷���������Ƿ����
function IsUInt32AddOverflow(A, B: Cardinal): Boolean;
begin
  Result := (A + B) < A; // �޷�����ӣ����ֻҪС����һ������˵�������
end;

// �ж����� 64 λ�з���������Ƿ����
function IsInt64AddOverflow(A, B: Int64): Boolean;
var
  C: Int64;
begin
  C := A + B;
  Result := ((A > 0) and (B > 0) and (C < 0)) or   // ͬ�����ҽ��������˵�����������
    ((A < 0) and (B < 0) and (C > 0));
end;

// �ж����� 64 λ�޷���������Ƿ����
function IsUInt64AddOverflow(A, B: TUInt64): Boolean;
begin
  Result := UInt64Compare(A + B, A) < 0; // �޷�����ӣ����ֻҪС����һ������˵�������
end;

// ָ������ת�������ͣ�֧�� 32/64 λ
function PointerToInteger(P: Pointer): Integer;
begin
{$IFDEF WIN64}
  // ����ôд������ Pointer �ĵ� 32 λ�� Integer
  Result := Integer(P);
{$ELSE}
  Result := Integer(P);
{$ENDIF}
end;

// ����ת����ָ�����ͣ�֧�� 32/64 λ
function IntegerToPointer(I: Integer): Pointer;
begin
{$IFDEF WIN64}
  // ����ôд������ Pointer �ĵ� 32 λ�� Integer
  Result := Pointer(I);
{$ELSE}
  Result := Pointer(I);
{$ENDIF}
end;

{ TCnIntegerList }

function TCnIntegerList.Add(Item: Integer): Integer;
begin
  Result := inherited Add(IntegerToPointer(Item));
end;

function TCnIntegerList.Get(Index: Integer): Integer;
begin
  Result := PointerToInteger(inherited Get(Index));
end;

procedure TCnIntegerList.Insert(Index, Item: Integer);
begin
  inherited Insert(Index, IntegerToPointer(Item));
end;

procedure TCnIntegerList.Put(Index: Integer; const Value: Integer);
begin
  inherited Put(Index, IntegerToPointer(Value));
end;

{ TCnInt64List }

destructor TCnInt64List.Destroy;
begin
  Clear;
end;

function TCnInt64List.Add(Item: Int64): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TCnInt64List.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TCnInt64List.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnInt64ListError, Index);

  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Int64));
end;

class procedure TCnInt64List.Error(const Msg: string; Data: Integer);
begin
  raise EListError.CreateFmt(Msg, [Data]);
end;

procedure TCnInt64List.Exchange(Index1, Index2: Integer);
var
  Item: Int64;
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    Error(SCnInt64ListError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then
    Error(SCnInt64ListError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TCnInt64List.Expand: TCnInt64List;
begin
  if FCount = FCapacity then
    Grow;
  Result := Self;
end;

function TCnInt64List.First: Int64;
begin
  Result := Get(0);
end;

function TCnInt64List.Get(Index: Integer): Int64;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnInt64ListError, Index);
  Result := FList^[Index];
end;

procedure TCnInt64List.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TCnInt64List.IndexOf(Item: Int64): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do
    Inc(Result);
  if Result = FCount then
    Result := -1;
end;

procedure TCnInt64List.Insert(Index: Integer; Item: Int64);
begin
  if (Index < 0) or (Index > FCount) then
    Error(SCnInt64ListError, Index);
  if FCount = FCapacity then
    Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(Int64));
  FList^[Index] := Item;
  Inc(FCount);
end;

function TCnInt64List.Last: Int64;
begin
  Result := Get(FCount - 1);
end;

procedure TCnInt64List.Move(CurIndex, NewIndex: Integer);
var
  Item: Int64;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then
      Error(SCnInt64ListError, NewIndex);
    Item := Get(CurIndex);
    FList^[CurIndex] := 0;
    Delete(CurIndex);
    Insert(NewIndex, 0);
    FList^[NewIndex] := Item;
  end;
end;

procedure TCnInt64List.Put(Index: Integer; Item: Int64);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnInt64ListError, Index);

  FList^[Index] := Item;
end;

function TCnInt64List.Remove(Item: Int64): Integer;
begin
  Result := IndexOf(Item);
  if Result >= 0 then
    Delete(Result);
end;

procedure TCnInt64List.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SCnInt64ListError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Int64));
    FCapacity := NewCapacity;
  end;
end;

procedure TCnInt64List.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SCnInt64ListError, NewCount);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Int64), 0)
  else
    for I := FCount - 1 downto NewCount do
      Delete(I);
  FCount := NewCount;
end;

end.
