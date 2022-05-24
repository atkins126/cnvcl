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

unit CnOTP;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ���̬����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���ο���GB/T 38556-2020 ��Ϣ��ȫ������̬��������Ӧ�ü����淶��
* ����ƽ̨��Win 7
* �޸ļ�¼��2022.02.11 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Math;

const
  CN_DEFAULT_PASSWORD_DIGITS = 6;
  {* Ĭ�Ͽ���ȣ�6 λ}

  CN_SEED_KEY_MIN_LENGTH = 16;
  {* ��С�����ӳ��ȣ��ֽ�}

  CN_CHALLENGE_MIN_LENGTH = 4;
  {* ��С����ս�볤�ȣ��ֽ�}

  CN_ID_MIN_LENGTH = 16;
  {* ��С�� ID ���ȣ��ֽ�}

  CN_PERIOD_MAX_SECOND = 60;
  {* ���Ŀ���仯���ڣ�����}

type
  ECnOneTimePasswordException = class(Exception);

  TCnOnePasswordType = (copSM3, copSM4);
  {* ��̬�����м���㺯���� SM3 �� SM4 ����}

  TCnDynamicToken = class
  {* ��̬���������}
  private
    FSeedKey: array of Byte;
    FChallengeCode: array of Byte;
    FCounter: Integer;
    FPasswordType: TCnOnePasswordType;
    FPeriod: Integer;
    FDigits: Integer;
    procedure SetDigits(const Value: Integer);
    procedure SetPeriod(const Value: Integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetSeedKey(Key: Pointer; KeyByteLength: Integer);
    {* ����������Կ K}

    procedure SetChallengeCode(Code: Pointer; CodeByteLength: Integer);
    {* ������ս���� Q}

    procedure SetCounter(Counter: Integer);
    {* �����¼����� C}

    function OneTimePassword: string;
    {* ���ݸ������ݼ��㶯̬�������������ɵ��ַ���}

    property PasswordType: TCnOnePasswordType read FPasswordType write FPasswordType;
    {* ��̬�����м���㺯������}

    property Period: Integer read FPeriod write SetPeriod;
    {* ����仯���ڣ�����Ϊ��λ��Ĭ�� 60}

    property Digits: Integer read FDigits write SetDigits;
    {* ����λ����Ĭ�� 6}
  end;

implementation

uses
  CnSM3, CnSM4, CnNativeDecl;

resourcestring
  SCnInvalidDataLength = 'Invalid Data or Length';
  SCnInvalidDigits = 'Invalid Digits';
  SCnInvalidPeriod = 'Invalid Period';

function EpochSeconds: Int64;
var
  D: TDateTime;
begin
  D := EncodeDate(1970, 1, 1);
  Result := Trunc(86400 * (Now - D));
end;

{ TCnDynamicToken }

constructor TCnDynamicToken.Create;
begin
  inherited;
  FPeriod := CN_PERIOD_MAX_SECOND;
  FPasswordType := copSM3;
  FDigits := CN_DEFAULT_PASSWORD_DIGITS;
end;

destructor TCnDynamicToken.Destroy;
begin
  SetLength(FSeedKey, 0);
  SetLength(FChallengeCode, 0);
  inherited;
end;

function TCnDynamicToken.OneTimePassword: string;
var
  L, Cnt, KC, IC: Integer;
  T: Int64;
  ID, S, KID, SM4K, SM4ID: array of Byte;
  OD, TD: LongWord;
  TenPow: Integer;
  Fmt: string;
  SM3Dig: TSM3Digest;
  SM4KBuf, SM4IDBuf: array[0..SM4_BLOCKSIZE - 1] of Byte;

  // ���� 128 λ������� A B ��ӣ�����ŵ� R ������� 128 λ���
  procedure Add128Bits(A, B, R: PByteArray);
  var
    I: Integer;
    O: Byte;
    Sum: Word;
  begin
    O := 0;
    for I := 15 downto 0 do
    begin
      Sum := A^[I] + B^[I] + O;
      R^[I] := Byte(Sum);
      O := Byte(Sum shr 8);
    end;
  end;

begin
  // ���㶯̬�������
  T := Int64ToBigEndian(EpochSeconds div FPeriod);

  L := SizeOf(Int64) + SizeOf(Integer) + Length(FChallengeCode);
  if L < CN_ID_MIN_LENGTH then
    L := CN_ID_MIN_LENGTH;

  SetLength(ID, L);
  Move(T, ID[0], SizeOf(Int64));

  Cnt := Int32ToBigEndian(FCounter);
  Move(Cnt, ID[SizeOf(Int64)], SizeOf(Integer));
  if Length(FChallengeCode) > 0 then
    Move(FChallengeCode[0], ID[SizeOf(Int64) + SizeOf(Integer)], Length(FChallengeCode));

  // ID = ( T || C || Q ) ƴ���ˣ�Ȼ��׼������ S

  OD := 0;
  try
    if FPasswordType = copSM3 then // SM3 ����
    begin
      SetLength(S, SizeOf(TSM3Digest)); // 32 �ֽ�

      // K �� ID ƴһ�飬�� SM3 �������� S
      SetLength(KID, Length(ID) + Length(FSeedKey));
      try
        Move(FSeedKey[0], KID[0], Length(FSeedKey));
        Move(ID[0], KID[Length(FSeedKey)], Length(ID));

        SM3Dig := SM3(PAnsiChar(@KID[0]), Length(KID));
        Move(SM3Dig[0], S[0], SizeOf(TSM3Digest));
      finally
        SetLength(KID, 0);
      end;

      // ��� 8 �� Cardinal ���
      Move(S[0], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[4], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[8], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[12], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[16], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[20], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[24], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[28], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
    end
    else // SM4 ����
    begin
      SetLength(S, SM4_BLOCKSIZE); // 16 �ֽ�

      // K �� ID ÿ 16 �ֽڼ���һ�Σ����߳��Ȳ���
      Cnt := Max(Length(FSeedKey), Length(ID));           // �õ� K �� ID �Ľϳ�ֵ
      Cnt := (Cnt + SM4_BLOCKSIZE - 1) div SM4_BLOCKSIZE; // ������ȡ��

      // ���������������� Cnt ��
      SetLength(SM4K, Cnt * SM4_BLOCKSIZE);
      SetLength(SM4ID, Cnt * SM4_BLOCKSIZE);

      try
        // �ֱ���������������������Ѳ� 0
        Move(FSeedKey[0], SM4K[0], Length(FSeedKey));
        Move(ID[0], SM4ID[0], Length(ID));

        FillChar(SM4KBuf[0], SizeOf(SM4KBuf), 0);
        FillChar(SM4IDBuf[0], SizeOf(SM4IDBuf), 0);

        for L := 0 to Cnt - 1 do
        begin
          // S �����ݺ� SM4K �ĵ� L ��������ӷ� SM4KBuf ��
          Add128Bits(PByteArray(@S[0]), PByteArray(@SM4K[L * SM4_BLOCKSIZE]), PByteArray(@SM4KBuf[0]));

          // S �����ݺ� SM4ID �ĵ� L ��������ӷ� SM4IDBuf ��
          Add128Bits(PByteArray(@S[0]), PByteArray(@SM4ID[L * SM4_BLOCKSIZE]), PByteArray(@SM4IDBuf[0]));

          // SM4KBuf �� SM4IDBuf ���� SM4 ���ܣ����ݷ� S ��
          SM4Encrypt(PAnsiChar(@SM4KBuf[0]), PAnsiChar(@SM4IDBuf[0]), PAnsiChar(@S[0]), SM4_BLOCKSIZE);
        end;
      finally
        SetLength(SM4K, 0);
        SetLength(SM4ID, 0);
      end;

      // ��� 4 �� Cardinal ���
      Move(S[0], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[4], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[8], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
      Move(S[12], TD, SizeOf(LongWord));
      OD := OD + Int32ToBigEndian(TD);
    end;

    TenPow := Trunc(IntPower(10, FDigits));
    Fmt := Format('%%%d.%dd', [FDigits, FDigits]);
    Result := Format(Fmt, [OD mod TenPow]);
  finally
    SetLength(S, 0);
    SetLength(ID, 0);
  end;
end;

procedure TCnDynamicToken.SetChallengeCode(Code: Pointer;
  CodeByteLength: Integer);
begin
  if (Code = nil) or (CodeByteLength < CN_CHALLENGE_MIN_LENGTH) then
    raise ECnOneTimePasswordException.Create(SCnInvalidDataLength);

  SetLength(FChallengeCode, CodeByteLength);
  Move(Code^, FChallengeCode[0], CodeByteLength);
end;

procedure TCnDynamicToken.SetDigits(const Value: Integer);
begin
  if Value <= 0 then
    raise ECnOneTimePasswordException.Create(SCnInvalidDigits);

  FDigits := Value;
end;

procedure TCnDynamicToken.SetCounter(Counter: Integer);
begin
  FCounter := Counter;
end;

procedure TCnDynamicToken.SetPeriod(const Value: Integer);
begin
  if (Value <= 0) or (Value > CN_PERIOD_MAX_SECOND) then
    raise ECnOneTimePasswordException.Create(SCnInvalidPeriod);

  FPeriod := Value;
end;

procedure TCnDynamicToken.SetSeedKey(Key: Pointer;
  KeyByteLength: Integer);
begin
  if (Key = nil) or (KeyByteLength < CN_SEED_KEY_MIN_LENGTH) then
    raise ECnOneTimePasswordException.Create(SCnInvalidDataLength);

  SetLength(FSeedKey, KeyByteLength);
  Move(Key^, FSeedKey[0], KeyByteLength);
end;

end.
