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

unit CnChaCha20;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�ChaCha20 �������㷨ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org)
* ��    ע������ RFC 7539 ʵ�֣����� Nonce �����ڳ�ʼ������
*           �����㣻���� 32 �ֽ� Key��12 �ֽ� Nonce��4 �ֽ� Counter����� 64 �ֽ�����
*           �����㣺���� 32 �ֽ� Key��12 �ֽ� Nonce��4 �ֽ� Counter�����ⳤ����/����
*                   �����ͬ������/����
* ����ƽ̨��Windows 7 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.07.19 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnNative;

const
  CN_CHACHA_STATE_SIZE   = 16;
  {* ChaCha20 �㷨��״̬������64 �ֽ�}

  CN_CHACHA_KEY_SIZE     = 32;
  {* ChaCha20 �㷨�� Key �ֽڳ���}

  CN_CHACHA_NONCE_SIZE   = 12;
  {* ChaCha20 �㷨�� Nonce �ֽڳ���}

  CN_CHACHA_COUNT_SIZE   = 4;
  {* ChaCha20 �㷨�ļ������ֽڳ��ȣ�ʵ������ʱʹ�� Cardinal ����}

type
  TCnChaChaKey = array[0..CN_CHACHA_KEY_SIZE - 1] of Byte;
  {* ChaCha20 �㷨�� Key}

  TCnChaChaNonce = array[0..CN_CHACHA_NONCE_SIZE - 1] of Byte;
  {* ChaCha20 �㷨�� Nonce}

  TCnChaChaCounter = Cardinal;
  {* ChaCha20 �㷨�ļ�����}

  TCnChaChaState = array[0..CN_CHACHA_STATE_SIZE - 1] of Cardinal;
  {* ChaCha20 �㷨��״̬��}

procedure ChaCha20Block(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  Counter: TCnChaChaCounter; var OutState: TCnChaChaState);
{* ����һ�ο����㣬���� 20 �ֵ�������}

function ChaCha20EncryptBytes(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  Data: TBytes): TBytes;
{* ���ֽ�������� ChaCha20 ����}

function ChaCha20DecryptBytes(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  EnData: TBytes): TBytes;
{* ���ֽ�������� ChaCha20 ����}

function ChaCha20EncryptData(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  Data: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
{* �� Data ��ָ�� DataByteLength ���ȵ����ݿ���� ChaCha20 ���ܣ�
  ���ķ� Output ��ָ���ڴ棬Ҫ�󳤶����������� DataByteLength}

function ChaCha20DecryptData(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  EnData: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
{* �� Data ��ָ�� DataByteLength ���ȵ��������ݿ���� ChaCha20 ���ܣ�
  ���ķ� Output ��ָ���ڴ棬Ҫ�󳤶����������� DataByteLength}

implementation

const
  CHACHA20_CONST0 = $61707865;
  CHACHA20_CONST1 = $3320646E;
  CHACHA20_CONST2 = $79622D32;
  CHACHA20_CONST3 = $6B206574;

procedure ROT(var X: Cardinal; N: BYTE);
begin
  X := (X shl N) or (X shr (32 - N));
end;

procedure QuarterRound(var A, B, C, D: Cardinal);
begin
  A := A + B;
  D := D xor A;
  ROT(D, 16);

  C := C + D;
  B := B xor C;
  ROT(B, 12);

  A := A + B;
  D := D xor A;
  ROT(D, 8);

  C := C + D;
  B := B xor C;
  ROT(B, 7);
end;

procedure QuarterRoundState(var State: TCnChaChaState; A, B, C, D: Integer);
begin
  QuarterRound(State[A], State[B], State[C], State[D]);
end;

procedure BuildState(var State: TCnChaChaState; var Key: TCnChaChaKey;
  var Nonce: TCnChaChaNonce; Counter: TCnChaChaCounter);
begin
  State[0] := CHACHA20_CONST0;
  State[1] := CHACHA20_CONST1;
  State[2] := CHACHA20_CONST2;
  State[3] := CHACHA20_CONST3;

  State[4] := PCardinal(@Key[0])^;
  State[5] := PCardinal(@Key[4])^;
  State[6] := PCardinal(@Key[8])^;
  State[7] := PCardinal(@Key[12])^;
  State[8] := PCardinal(@Key[16])^;
  State[9] := PCardinal(@Key[20])^;
  State[10] := PCardinal(@Key[24])^;
  State[11] := PCardinal(@Key[28])^;

  State[12] := Counter;

  State[13] := PCardinal(@Nonce[0])^;
  State[14] := PCardinal(@Nonce[4])^;
  State[15] := PCardinal(@Nonce[8])^;
end;

procedure ChaCha20InnerBlock(var State: TCnChaChaState);
begin
  QuarterRoundState(State, 0, 4, 8, 12);
  QuarterRoundState(State, 1, 5, 9, 13);
  QuarterRoundState(State, 2, 6, 10, 14);
  QuarterRoundState(State, 3, 7, 11, 15);

  QuarterRoundState(State, 0, 5, 10, 15);
  QuarterRoundState(State, 1, 6, 11, 12);
  QuarterRoundState(State, 2, 7, 8, 13);
  QuarterRoundState(State, 3, 4, 9, 14);
end;

procedure ChaCha20Block(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  Counter: TCnChaChaCounter; var OutState: TCnChaChaState);
var
  I: Integer;
  State: TCnChaChaState;
begin
  BuildState(State, Key, Nonce, Counter);
  Move(State[0], OutState[0], SizeOf(TCnChaChaState));

  for I := 1 to 10 do
    ChaCha20InnerBlock(OutState);

  for I := Low(TCnChaChaState) to High(TCnChaChaState) do
    OutState[I] := OutState[I] + State[I];
end;

function ChaCha20Data(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  Data: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
var
  I, J, L, B: Integer;
  Cnt: TCnChaChaCounter;
  Stream: TCnChaChaState;
  P, Q, M: PByteArray;
begin
  Result := False;
  if (Data = nil) or (DataByteLength <= 0) or (Output = nil) then
    Exit;

  Cnt := 1;
  B := DataByteLength div (SizeOf(Cardinal) * CN_CHACHA_STATE_SIZE); // �� B ��������
  P := PByteArray(Data);
  Q := PByteArray(Output);
  M := PByteArray(@Stream[0]);

  if B > 0 then
  begin
    for I := 1 to B do
    begin
      ChaCha20Block(Key, Nonce, Cnt, Stream);

      // P��Q �Ѹ�ָ��Ҫ�����ԭʼ�������Ŀ�
      for J := 0 to SizeOf(Cardinal) * CN_CHACHA_STATE_SIZE - 1 do
        Q^[J] := P^[J] xor M^[J];

      // ָ����һ��
      P := PByteArray(TCnNativeInt(P) + SizeOf(Cardinal) * CN_CHACHA_STATE_SIZE);
      Q := PByteArray(TCnNativeInt(Q) + SizeOf(Cardinal) * CN_CHACHA_STATE_SIZE);

      Inc(Cnt);
    end;
  end;

  L := DataByteLength mod (SizeOf(Cardinal) * CN_CHACHA_STATE_SIZE);
  if L > 0 then // ����ʣ��飬����Ϊ L
  begin
    ChaCha20Block(Key, Nonce, Cnt, Stream);

    // P��Q �Ѹ�ָ��Ҫ�����ԭʼ�������Ŀ�
    for J := 0 to L - 1 do
      Q^[J] := P^[J] xor M^[J];
  end;
  Result := True;
end;

function ChaCha20EncryptBytes(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  Data: TBytes): TBytes;
var
  L: Integer;
begin
  Result := nil;
  if Data = nil then
    Exit;

  L := Length(Data);
  if L > 0 then
  begin
    SetLength(Result, L);
    if not ChaCha20Data(Key, Nonce, @Data[0], L, @Result[0]) then
      SetLength(Result, 0);
  end;
end;

function ChaCha20DecryptBytes(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  EnData: TBytes): TBytes;
var
  L: Integer;
begin
  Result := nil;
  if EnData = nil then
    Exit;

  L := Length(EnData);
  if L > 0 then
  begin
    SetLength(Result, L);
    if not ChaCha20Data(Key, Nonce, @EnData[0], L, @Result[0]) then
      SetLength(Result, 0);
  end;
end;

function ChaCha20EncryptData(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  Data: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
begin
  Result := ChaCha20Data(Key, Nonce, Data, DataByteLength, Output);
end;

function ChaCha20DecryptData(var Key: TCnChaChaKey; var Nonce: TCnChaChaNonce;
  EnData: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
begin
  Result := ChaCha20Data(Key, Nonce, EnData, DataByteLength, Output);
end;

end.
