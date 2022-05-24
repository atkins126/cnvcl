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

unit CnSM4;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ��������������㷨 SM4 ��Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org)
* ��    ע���ο������㷨�����ĵ� SM4 Encryption alogrithm
*           ���ο���ֲ goldboar �� C ����
* ����ƽ̨��Windows 7 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP/7 + Delphi 5/6 + MaxOS 64
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.04.26 V1.5
*               �޸� LongWord �� Integer ��ַת����֧�� MacOS64
*           2022.04.19 V1.4
*               ʹ�ó�ʼ������ʱ�ڲ����ݣ����޸Ĵ��������
*           2021.12.12 V1.3
*               ���� CFB/OFB ģʽ��֧��
*           2020.03.24 V1.2
*               ���Ӳ��ַ�װ��������������
*           2019.04.15 V1.1
*               ֧�� Win32/Win64/MacOS
*           2014.09.25 V1.0
*               ��ֲ��������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils {$IFDEF MSWINDOWS}, Windows {$ENDIF}, CnNativeDecl;

const
  SM4_KEYSIZE = 16;
  SM4_BLOCKSIZE = 16;

type
  TSM4Key    = array[0..SM4_KEYSIZE - 1] of Byte;
  {* SM4 �ļ��� Key}

  TSM4Buffer = array[0..SM4_BLOCKSIZE - 1] of Byte;
  {* SM4 �ļ��ܿ�}

  TSM4Iv     = array[0..SM4_BLOCKSIZE - 1] of Byte;
  {* SM4 �� CBC/CFB/OFB �ȵĳ�ʼ������}

procedure SM4Encrypt(Key: PAnsiChar; Input: PAnsiChar; Output: PAnsiChar; Len: Integer);
{* ԭʼ�� SM4 �������ݿ飬ECB ģʽ���� Input �ڵ��������ݼ��ܸ鵽 Output ��
  ���������б�֤ Key ָ���������� 16 �ֽڣ�Input �� Output ָ�����ݳ���Ȳ��Ҷ�Ϊ Len �ֽ�
  �� Len ���뱻 16 ����}

procedure SM4Decrypt(Key: PAnsiChar; Input: PAnsiChar; Output: PAnsiChar; Len: Integer);
{* ԭʼ�� SM4 �������ݿ飬ECB ģʽ���� Input �ڵ��������ݽ��ܸ鵽 Output ��
  ���������б�֤ Key ָ������������ 16 �ֽڣ�Input �� Output ָ�����ݳ���Ȳ��Ҷ�Ϊ Len �ֽ�
  �� Len ���뱻 16 ����}

procedure SM4EncryptEcbStr(Key: AnsiString; const Input: AnsiString; Output: PAnsiChar);
{* SM4-ECB ��װ�õ���� AnsiString �ļ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� #0
  Input    input �ַ������䳤���粻�� 16 ����������ʱ�ᱻ��� #0 �����ȴﵽ 16 �ı���
  Output   output ��������䳤�ȱ�����ڻ���� (((Length(Input) - 1) div 16) + 1) * 16
 |</PRE>}

procedure SM4DecryptEcbStr(Key: AnsiString; const Input: AnsiString; Output: PAnsiChar);
{* SM4-ECB ��װ�õ���� AnsiString �Ľ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� #0
  Input    input �ַ������䳤���粻�� 16 ����������ʱ�ᱻ��� #0 �����ȴﵽ 16 �ı���
  Output   output ��������䳤�ȱ�����ڻ���� (((Length(Input) - 1) div 16) + 1) * 16
 |</PRE>}

procedure SM4EncryptCbcStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
{* SM4-CBC ��װ�õ���� AnsiString �ļ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� #0
  Iv       ������ 16 �ֽڵĳ�ʼ��������̫���򳬳����ֺ���
  Input    input string
  Output   output ��������䳤�ȱ�����ڻ���� (((Length(Input) - 1) div 16) + 1) * 16
 |</PRE>}

procedure SM4DecryptCbcStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
{* SM4-CBC ��װ�õ���� AnsiString �Ľ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� #0
  Iv       ������ 16 �ֽڵĳ�ʼ��������̫���򳬳����ֺ���
  Input    input string
  Output   output ��������䳤�ȱ�����ڻ���� (((Length(Input) - 1) div 16) + 1) * 16
 |</PRE>}

procedure SM4EncryptCfbStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
{* SM4-CFB ��װ�õ���� AnsiString �ļ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� #0
  Iv       ������ 16 �ֽڵĳ�ʼ��������̫���򳬳����ֺ���
  Input    input string
  Output   output ��������䳤�ȱ�����ڻ���� (((Length(Input) - 1) div 16) + 1) * 16
 |</PRE>}

procedure SM4DecryptCfbStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
{* SM4-CFB ��װ�õ���� AnsiString �Ľ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� #0
  Iv       ������ 16 �ֽڵĳ�ʼ��������̫���򳬳����ֺ���
  Input    input string
  Output   output ��������䳤�ȱ�����ڻ���� (((Length(Input) - 1) div 16) + 1) * 16
 |</PRE>}

procedure SM4EncryptOfbStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
{* SM4-OFB ��װ�õ���� AnsiString �ļ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� #0
  Iv       ������ 16 �ֽڵĳ�ʼ��������̫���򳬳����ֺ���
  Input    input string
  Output   output ��������䳤�ȱ�����ڻ���� (((Length(Input) - 1) div 16) + 1) * 16
 |</PRE>}

procedure SM4DecryptOfbStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
{* SM4-OFB ��װ�õ���� AnsiString �Ľ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� #0
  Iv       ������ 16 �ֽڵĳ�ʼ��������̫���򳬳����ֺ���
  Input    input string
  Output   output ��������䳤�ȱ�����ڻ���� (((Length(Input) - 1) div 16) + 1) * 16
 |</PRE>}

{$IFDEF TBYTES_DEFINED}

function SM4EncryptEcbBytes(Key: TBytes; const Input: TBytes): TBytes;
{* SM4-ECB ��װ�õ���� TBytes �ļ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� 0
  Input    input ���ݣ��䳤���粻�� 16 ����������ʱ�ᱻ��� 0 �����ȴﵽ 16 �ı���
  ����ֵ   ��������
 |</PRE>}

function SM4DecryptEcbBytes(Key: TBytes; const Input: TBytes): TBytes;
{* SM4-ECB ��װ�õ���� TBytes �Ľ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� 0
  Input    input ���ģ��䳤���粻�� 16 ����������ʱ�ᱻ��� 0 �����ȴﵽ 16 �ı���
  ����ֵ   ��������
 |</PRE>}

function SM4EncryptCbcBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
{* SM4-CBC ��װ�õ���� TBytes �ļ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� 0
  Iv       16 �ֽڳ�ʼ��������̫���򳬳����ֺ��ԣ��������� Iv �� 0
  Input    input ����
  ����ֵ   ��������
 |</PRE>}

function SM4DecryptCbcBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
{* SM4-CBC ��װ�õ���� TBytes �Ľ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� 0
  Iv       16 �ֽڳ�ʼ��������̫���򳬳����ֺ��ԣ��������� Iv �� 0
  Input    input ����
  ����ֵ   ��������
 |</PRE>}

function SM4EncryptCfbBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
{* SM4-CFB ��װ�õ���� TBytes �ļ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� 0
  Iv       16 �ֽڳ�ʼ��������̫���򳬳����ֺ��ԣ��������� Iv �� 0
  Input    input ����
  ����ֵ   ��������
 |</PRE>}

function SM4DecryptCfbBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
{* SM4-CFB ��װ�õ���� TBytes �Ľ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� 0
  Iv       16 �ֽڳ�ʼ��������̫���򳬳����ֺ��ԣ��������� Iv �� 0
  Input    input ����
  ����ֵ   ��������
 |</PRE>}

function SM4EncryptOfbBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
{* SM4-OFB ��װ�õ���� TBytes �ļ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� 0
  Iv       16 �ֽڳ�ʼ��������̫���򳬳����ֺ��ԣ��������� Iv �� 0
  Input    input ����
  ����ֵ   ��������
 |</PRE>}

function SM4DecryptOfbBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
{* SM4-OFB ��װ�õ���� TBytes �Ľ��ܷ���
 |<PRE>
  Key      16 �ֽ����룬̫����ضϣ������� 0
  Iv       16 �ֽڳ�ʼ��������̫���򳬳����ֺ��ԣ��������� Iv �� 0
  Input    input ����
  ����ֵ   ��������
 |</PRE>}

{$ENDIF}

procedure SM4EncryptStreamECB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; Dest: TStream); overload;
{* SM4-ECB �����ܣ�Count Ϊ 0 ��ʾ��ͷ����������������ֻ���� Stream ��ǰλ���� Count ���ֽ���}

procedure SM4DecryptStreamECB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; Dest: TStream); overload;
{* SM4-ECB �����ܣ�Count Ϊ 0 ��ʾ��ͷ����������������ֻ���� Stream ��ǰλ���� Count ���ֽ���}

procedure SM4EncryptStreamCBC(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
{* SM4-CBC �����ܣ�Count Ϊ 0 ��ʾ��ͷ����������������ֻ���� Stream ��ǰλ���� Count ���ֽ���}

procedure SM4DecryptStreamCBC(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
{* SM4-CBC �����ܣ�Count Ϊ 0 ��ʾ��ͷ����������������ֻ���� Stream ��ǰλ���� Count ���ֽ���}

procedure SM4EncryptStreamCFB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
{* SM4-CFB �����ܣ�Count Ϊ 0 ��ʾ��ͷ����������������ֻ���� Stream ��ǰλ���� Count ���ֽ���}

procedure SM4DecryptStreamCFB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
{* SM4-CFB �����ܣ�Count Ϊ 0 ��ʾ��ͷ����������������ֻ���� Stream ��ǰλ���� Count ���ֽ���}

procedure SM4EncryptStreamOFB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
{* SM4-OFB �����ܣ�Count Ϊ 0 ��ʾ��ͷ����������������ֻ���� Stream ��ǰλ���� Count ���ֽ���}

procedure SM4DecryptStreamOFB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
{* SM4-OFB �����ܣ�Count Ϊ 0 ��ʾ��ͷ����������������ֻ���� Stream ��ǰλ���� Count ���ֽ���}

implementation

resourcestring
  SInvalidInBufSize = 'Invalid Buffer Size for Decryption';
  SReadError = 'Stream Read Error';
  SWriteError = 'Stream Write Error';

const
  SM4_ENCRYPT = 1;
  SM4_DECRYPT = 0;

  SBoxTable: array[0..SM4_KEYSIZE - 1] of array[0..SM4_KEYSIZE - 1] of Byte = (
    ($D6, $90, $E9, $FE, $CC, $E1, $3D, $B7, $16, $B6, $14, $C2, $28, $FB, $2C, $05),
    ($2B, $67, $9A, $76, $2A, $BE, $04, $C3, $AA, $44, $13, $26, $49, $86, $06, $99),
    ($9C, $42, $50, $F4, $91, $EF, $98, $7A, $33, $54, $0B, $43, $ED, $CF, $AC, $62),
    ($E4, $B3, $1C, $A9, $C9, $08, $E8, $95, $80, $DF, $94, $FA, $75, $8F, $3F, $A6),
    ($47, $07, $A7, $FC, $F3, $73, $17, $BA, $83, $59, $3C, $19, $E6, $85, $4F, $A8),
    ($68, $6B, $81, $B2, $71, $64, $DA, $8B, $F8, $EB, $0F, $4B, $70, $56, $9D, $35),
    ($1E, $24, $0E, $5E, $63, $58, $D1, $A2, $25, $22, $7C, $3B, $01, $21, $78, $87),
    ($D4, $00, $46, $57, $9F, $D3, $27, $52, $4C, $36, $02, $E7, $A0, $C4, $C8, $9E),
    ($EA, $BF, $8A, $D2, $40, $C7, $38, $B5, $A3, $F7, $F2, $CE, $F9, $61, $15, $A1),
    ($E0, $AE, $5D, $A4, $9B, $34, $1A, $55, $AD, $93, $32, $30, $F5, $8C, $B1, $E3),
    ($1D, $F6, $E2, $2E, $82, $66, $CA, $60, $C0, $29, $23, $AB, $0D, $53, $4E, $6F),
    ($D5, $DB, $37, $45, $DE, $FD, $8E, $2F, $03, $FF, $6A, $72, $6D, $6C, $5B, $51),
    ($8D, $1B, $AF, $92, $BB, $DD, $BC, $7F, $11, $D9, $5C, $41, $1F, $10, $5A, $D8),
    ($0A, $C1, $31, $88, $A5, $CD, $7B, $BD, $2D, $74, $D0, $12, $B8, $E5, $B4, $B0),
    ($89, $69, $97, $4A, $0C, $96, $77, $7E, $65, $B9, $F1, $09, $C5, $6E, $C6, $84),
    ($18, $F0, $7D, $EC, $3A, $DC, $4D, $20, $79, $EE, $5F, $3E, $D7, $CB, $39, $48)
  );

  FK: array[0..3] of TCnLongWord32 = ($A3B1BAC6, $56AA3350, $677D9197, $B27022DC);

  CK: array[0..SM4_KEYSIZE * 2 - 1] of TCnLongWord32 = (
    $00070E15, $1C232A31, $383F464D, $545B6269,
    $70777E85, $8C939AA1, $A8AFB6BD, $C4CBD2D9,
    $E0E7EEF5, $FC030A11, $181F262D, $343B4249,
    $50575E65, $6C737A81, $888F969D, $A4ABB2B9,
    $C0C7CED5, $DCE3EAF1, $F8FF060D, $141B2229,
    $30373E45, $4C535A61, $686F767D, $848B9299,
    $A0A7AEB5, $BCC3CAD1, $D8DFE6ED, $F4FB0209,
    $10171E25, $2C333A41, $484F565D, $646B7279 );

type
  TSM4Context = packed record
    Mode: Integer;              {!<  encrypt/decrypt   }
    Sk: array[0..SM4_KEYSIZE * 2 - 1] of TCnLongWord32;  {!<  SM4 subkeys       }
  end;

function Min(A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

procedure GetULongBe(var N: TCnLongWord32; B: PAnsiChar; I: Integer);
var
  D: TCnLongWord32;
begin
  D := (TCnLongWord32(B[I]) shl 24) or (TCnLongWord32(B[I + 1]) shl 16) or
    (TCnLongWord32(B[I + 2]) shl 8) or (TCnLongWord32(B[I + 3]));
  N := D;
end;

procedure PutULongBe(N: TCnLongWord32; B: PAnsiChar; I: Integer);
begin
  B[I] := AnsiChar(N shr 24);
  B[I + 1] := AnsiChar(N shr 16);
  B[I + 2] := AnsiChar(N shr 8);
  B[I + 3] := AnsiChar(N);
end;

function SM4Shl(X: TCnLongWord32; N: Integer): TCnLongWord32;
begin
  Result := (X and $FFFFFFFF) shl N;
end;

function ROTL(X: TCnLongWord32; N: Integer): TCnLongWord32;
begin
  Result := SM4Shl(X, N) or (X shr (32 - N));
end;

procedure Swap(var A: TCnLongWord32; var B: TCnLongWord32);
var
  T: TCnLongWord32;
begin
  T := A;
  A := B;
  B := T;
end;

function SM4SBox(Inch: Byte): Byte;
var
  PTable: Pointer;
begin
  PTable := @(SboxTable[0][0]);
  Result := PByte(TCnNativeInt(PTable) + Inch)^;
end;

function SM4Lt(Ka: TCnLongWord32): TCnLongWord32;
var
  BB: TCnLongWord32;
  A: array[0..3] of Byte;
  B: array[0..3] of Byte;
begin
  BB := 0;
  PutULongBe(Ka, @(A[0]), 0);
  B[0] := SM4SBox(A[0]);
  B[1] := SM4SBox(A[1]);
  B[2] := SM4SBox(A[2]);
  B[3] := SM4SBox(A[3]);
  GetULongBe(BB, @(B[0]), 0);

  Result := BB xor (ROTL(BB, 2)) xor (ROTL(BB, 10)) xor (ROTL(BB, 18))
    xor (ROTL(BB, 24));
end;

function SM4F(X0: TCnLongWord32; X1: TCnLongWord32; X2: TCnLongWord32; X3: TCnLongWord32; RK: TCnLongWord32): TCnLongWord32;
begin
  Result := X0 xor SM4Lt(X1 xor X2 xor X3 xor RK);
end;

function SM4CalciRK(Ka: TCnLongWord32): TCnLongWord32;
var
  BB: TCnLongWord32;
  A: array[0..3] of Byte;
  B: array[0..3] of Byte;
begin
  PutULongBe(Ka, @(A[0]), 0);
  B[0] := SM4SBox(A[0]);
  B[1] := SM4SBox(A[1]);
  B[2] := SM4SBox(A[2]);
  B[3] := SM4SBox(A[3]);
  GetULongBe(BB, @(B[0]), 0);
  Result := BB xor ROTL(BB, 13) xor ROTL(BB, 23);
end;

// SK Points to 32 DWord Array; Key Points to 16 Byte Array
procedure SM4SetKey(SK: PCnLongWord32; Key: PAnsiChar);
var
  MK: array[0..3] of TCnLongWord32;
  K: array[0..35] of TCnLongWord32;
  I: Integer;
begin
  GetULongBe(MK[0], Key, 0);
  GetULongBe(MK[1], Key, 4);
  GetULongBe(MK[2], Key, 8);
  GetULongBe(MK[3], Key, 12);

  K[0] := MK[0] xor FK[0];
  K[1] := MK[1] xor FK[1];
  K[2] := MK[2] xor FK[2];
  K[3] := MK[3] xor FK[3];

  for I := 0 to 31 do
  begin
    K[I + 4] := K[I] xor SM4CalciRK(K[I + 1] xor K[I + 2] xor K[I + 3] xor CK[I]);
      (PCnLongWord32(TCnNativeInt(SK) + I * SizeOf(TCnLongWord32)))^ := K[I + 4];
  end;
end;

// SK Points to 32 DWord Array; Input/Output Points to 16 Byte Array
procedure SM4OneRound(SK: PCnLongWord32; Input: PAnsiChar; Output: PAnsiChar);
var
  I: Integer;
  UlBuf: array[0..35] of TCnLongWord32;
begin
  FillChar(UlBuf[0], SizeOf(UlBuf), 0);

  GetULongBe(UlBuf[0], Input, 0);
  GetULongBe(UlBuf[1], Input, 4);
  GetULongBe(UlBuf[2], Input, 8);
  GetULongBe(UlBuf[3], Input, 12);

  for I := 0 to 31 do
  begin
    UlBuf[I + 4] := SM4F(UlBuf[I], UlBuf[I + 1], UlBuf[I + 2], UlBuf[I + 3],
      (PCnLongWord32(TCnNativeInt(SK) + I * SizeOf(TCnLongWord32)))^);
  end;

  PutULongBe(UlBuf[35], Output, 0);
  PutULongBe(UlBuf[34], Output, 4);
  PutULongBe(UlBuf[33], Output, 8);
  PutULongBe(UlBuf[32], Output, 12);
end;

procedure SM4SetKeyEnc(var Ctx: TSM4Context; Key: PAnsiChar);
begin
  Ctx.Mode := SM4_ENCRYPT;
  SM4SetKey(@(Ctx.Sk[0]), Key);
end;

procedure SM4SetKeyDec(var Ctx: TSM4Context; Key: PAnsiChar);
var
  I: Integer;
begin
  Ctx.Mode := SM4_DECRYPT;
  SM4SetKey(@(Ctx.Sk[0]), Key);

  for I := 0 to SM4_KEYSIZE - 1 do
    Swap(Ctx.Sk[I], Ctx.Sk[31 - I]);
end;

procedure SM4CryptEcb(var Ctx: TSM4Context; Mode: Integer; Length: Integer;
  Input: PAnsiChar; Output: PAnsiChar);
var
  EndBuf: TSM4Buffer;
begin
  while Length > 0 do
  begin
    if Length >= SM4_BLOCKSIZE then
    begin
      SM4OneRound(@(Ctx.Sk[0]), Input, Output);
    end
    else
    begin
      // β������ 16���� 0
      FillChar(EndBuf[0], SM4_BLOCKSIZE, 0);
      Move(Input^, EndBuf[0], Length);
      SM4OneRound(@(Ctx.Sk[0]), @(EndBuf[0]), Output);
    end;
    Inc(Input, SM4_BLOCKSIZE);
    Inc(Output, SM4_BLOCKSIZE);
    Dec(Length, SM4_BLOCKSIZE);
  end;
end;

procedure SM4CryptEcbStr(Mode: Integer; Key: AnsiString;
  const Input: AnsiString; Output: PAnsiChar);
var
  Ctx: TSM4Context;
begin
  if Length(Key) < SM4_KEYSIZE then
    while Length(Key) < SM4_KEYSIZE do Key := Key + Chr(0) // 16 bytes at least padding 0.
  else if Length(Key) > SM4_KEYSIZE then
    Key := Copy(Key, 1, SM4_KEYSIZE);  // Only keep 16

  if Mode = SM4_ENCRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[1]));
    SM4CryptEcb(Ctx, SM4_ENCRYPT, Length(Input), @(Input[1]), @(Output[0]));
  end
  else if Mode = SM4_DECRYPT then
  begin
    SM4SetKeyDec(Ctx, @(Key[1]));
    SM4CryptEcb(Ctx, SM4_DECRYPT, Length(Input), @(Input[1]), @(Output[0]));
  end;
end;

procedure SM4CryptCbc(var Ctx: TSM4Context; Mode: Integer; Length: Integer;
  Iv: PAnsiChar; Input: PAnsiChar; Output: PAnsiChar);
var
  I: Integer;
  EndBuf: TSM4Buffer;
  LocalIv: TSM4Iv;
begin
  Move(Iv^, LocalIv[0], SM4_BLOCKSIZE);
  if Mode = SM4_ENCRYPT then
  begin
    while Length > 0 do
    begin
      if Length >= SM4_BLOCKSIZE then
      begin
        for I := 0 to SM4_BLOCKSIZE - 1 do
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Input) + I))^
            xor LocalIv[I];

        SM4OneRound(@(Ctx.Sk[0]), Output, Output);
        Move(Output[0], LocalIv[0], SM4_BLOCKSIZE);
      end
      else
      begin
        // β������ 16���� 0
        FillChar(EndBuf[0], SizeOf(EndBuf), 0);
        Move(Input^, EndBuf[0], Length);

        for I := 0 to SM4_BLOCKSIZE - 1 do
          (PByte(TCnNativeInt(Output) + I))^ := EndBuf[I]
            xor LocalIv[I];

        SM4OneRound(@(Ctx.Sk[0]), Output, Output);
        Move(Output[0], LocalIv[0], SM4_BLOCKSIZE);
      end;

      Inc(Input, SM4_BLOCKSIZE);
      Inc(Output, SM4_BLOCKSIZE);
      Dec(Length, SM4_BLOCKSIZE);
    end;
  end
  else if Mode = SM4_DECRYPT then
  begin
    while Length > 0 do
    begin
      if Length >= SM4_BLOCKSIZE then
      begin
        SM4OneRound(@(Ctx.Sk[0]), Input, Output);

        for I := 0 to SM4_BLOCKSIZE - 1 do
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Output) + I))^
            xor LocalIv[I];

        Move(Input^, LocalIv[0], SM4_BLOCKSIZE);
      end
      else
      begin
        // β������ 16���� 0
        FillChar(EndBuf[0], SizeOf(EndBuf), 0);
        Move(Input^, EndBuf[0], Length);
        SM4OneRound(@(Ctx.Sk[0]), @(EndBuf[0]), Output);

        for I := 0 to SM4_BLOCKSIZE - 1 do
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Output) + I))^
            xor LocalIv[I];

        Move(EndBuf[0], LocalIv[0], SM4_BLOCKSIZE);
      end;

      Inc(Input, SM4_BLOCKSIZE);
      Inc(Output, SM4_BLOCKSIZE);
      Dec(Length, SM4_BLOCKSIZE);
    end;
  end;
end;

procedure SM4CryptCfb(var Ctx: TSM4Context; Mode: Integer; Length: Integer;
  Iv: PAnsiChar; Input: PAnsiChar; Output: PAnsiChar);
var
  I: Integer;
  LocalIv: TSM4Iv;
begin
  Move(Iv^, LocalIv[0], SM4_BLOCKSIZE);
  if Mode = SM4_ENCRYPT then
  begin
    while Length > 0 do
    begin
      if Length >= SM4_BLOCKSIZE then
      begin
        SM4OneRound(@(Ctx.Sk[0]), @LocalIv[0], Output);  // �ȼ��� Iv

        for I := 0 to SM4_BLOCKSIZE - 1 do
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Input) + I))^
            xor (PByte(TCnNativeInt(Output) + I))^;  // ���ܽ�������������Ϊ�������

        Move(Output[0], LocalIv[0], SM4_BLOCKSIZE);  // ����ȡ�� Iv �Ա���һ��
      end
      else
      begin
        SM4OneRound(@(Ctx.Sk[0]), @LocalIv[0], Output);

        for I := 0 to Length - 1 do // ֻ�����ʣ�೤�ȣ����账�������� 16 �ֽ�
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Input) + I))^
            xor (PByte(TCnNativeInt(Output) + I))^;
      end;

      Inc(Input, SM4_BLOCKSIZE);
      Inc(Output, SM4_BLOCKSIZE);
      Dec(Length, SM4_BLOCKSIZE);
    end;
  end
  else if Mode = SM4_DECRYPT then
  begin
    while Length > 0 do
    begin
      if Length >= SM4_BLOCKSIZE then
      begin
        SM4OneRound(@(Ctx.Sk[0]), @LocalIv[0], Output);   // �ȼ��� Iv

        for I := 0 to SM4_BLOCKSIZE - 1 do
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Output) + I))^
            xor (PByte(TCnNativeInt(Input) + I))^;    // ���ܽ�����������õ�����

        Move(Input[0], LocalIv[0], SM4_BLOCKSIZE);    // ����ȡ�� Iv ����ȥ��һ�ּ���
      end
      else
      begin
        SM4OneRound(@(Ctx.Sk[0]), @LocalIv[0], Output);

        for I := 0 to Length - 1 do
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Output) + I))^
            xor (PByte(TCnNativeInt(Input) + I))^;
      end;

      Inc(Input, SM4_BLOCKSIZE);
      Inc(Output, SM4_BLOCKSIZE);
      Dec(Length, SM4_BLOCKSIZE);
    end;
  end;
end;

procedure SM4CryptOfb(var Ctx: TSM4Context; Mode: Integer; Length: Integer;
  Iv: PAnsiChar; Input: PAnsiChar; Output: PAnsiChar);
var
  I: Integer;
  LocalIv: TSM4Iv;
begin
  Move(Iv^, LocalIv[0], SM4_BLOCKSIZE);
  if Mode = SM4_ENCRYPT then
  begin
    while Length > 0 do
    begin
      if Length >= SM4_BLOCKSIZE then
      begin
        SM4OneRound(@(Ctx.Sk[0]), @LocalIv[0], Output);  // �ȼ��� Iv

        Move(Output[0], LocalIv[0], SM4_BLOCKSIZE);  // ���ܽ�����������һ��

        for I := 0 to SM4_BLOCKSIZE - 1 do      // ���ܽ����������������
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Input) + I))^
            xor (PByte(TCnNativeInt(Output) + I))^;
      end
      else
      begin
        SM4OneRound(@(Ctx.Sk[0]), @LocalIv[0], Output);  // �ȼ��� Iv

        for I := 0 to Length - 1 do             // �������� 16 �ֽ�
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Input) + I))^
            xor (PByte(TCnNativeInt(Output) + I))^;
      end;

      Inc(Input, SM4_BLOCKSIZE);
      Inc(Output, SM4_BLOCKSIZE);
      Dec(Length, SM4_BLOCKSIZE);
    end;
  end
  else if Mode = SM4_DECRYPT then
  begin
    while Length > 0 do
    begin
      if Length >= SM4_BLOCKSIZE then
      begin
        SM4OneRound(@(Ctx.Sk[0]), @LocalIv[0], Output);   // �ȼ��� Iv

        Move(Output[0], LocalIv[0], SM4_BLOCKSIZE);   // ���ܽ�����������һ��

        for I := 0 to SM4_BLOCKSIZE - 1 do       // �����������������õ�����
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Output) + I))^
            xor (PByte(TCnNativeInt(Input) + I))^;
      end
      else
      begin
        SM4OneRound(@(Ctx.Sk[0]), @LocalIv[0], Output);   // �ȼ��� Iv

        for I := 0 to Length - 1 do
          (PByte(TCnNativeInt(Output) + I))^ := (PByte(TCnNativeInt(Output) + I))^
            xor (PByte(TCnNativeInt(Input) + I))^;
      end;

      Inc(Input, SM4_BLOCKSIZE);
      Inc(Output, SM4_BLOCKSIZE);
      Dec(Length, SM4_BLOCKSIZE);
    end;
  end;
end;

procedure SM4CryptCbcStr(Mode: Integer; Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
var
  Ctx: TSM4Context;
begin
  if Length(Key) < SM4_KEYSIZE then
    while Length(Key) < SM4_KEYSIZE do Key := Key + Chr(0) // 16 bytes at least padding 0.
  else if Length(Key) > SM4_KEYSIZE then
    Key := Copy(Key, 1, SM4_KEYSIZE);  // Only keep 16

  if Mode = SM4_ENCRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[1]));
    SM4CryptCbc(Ctx, SM4_ENCRYPT, Length(Input), @(Iv[0]), @(Input[1]), @(Output[0]));
  end
  else if Mode = SM4_DECRYPT then
  begin
    SM4SetKeyDec(Ctx, @(Key[1]));
    SM4CryptCbc(Ctx, SM4_DECRYPT, Length(Input), @(Iv[0]), @(Input[1]), @(Output[0]));
  end;
end;

procedure SM4CryptCfbStr(Mode: Integer; Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
var
  Ctx: TSM4Context;
begin
  if Length(Key) < SM4_KEYSIZE then
    while Length(Key) < SM4_KEYSIZE do Key := Key + Chr(0) // 16 bytes at least padding 0.
  else if Length(Key) > SM4_KEYSIZE then
    Key := Copy(Key, 1, SM4_KEYSIZE);  // Only keep 16

  if Mode = SM4_ENCRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[1]));
    SM4CryptCfb(Ctx, SM4_ENCRYPT, Length(Input), @(Iv[0]), @(Input[1]), @(Output[0]));
  end
  else if Mode = SM4_DECRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[1])); // ע�� CFB �Ľ���Ҳ�õ��Ǽ��ܣ�
    SM4CryptCfb(Ctx, SM4_DECRYPT, Length(Input), @(Iv[0]), @(Input[1]), @(Output[0]));
  end;
end;

procedure SM4CryptOfbStr(Mode: Integer; Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
var
  Ctx: TSM4Context;
begin
  if Length(Key) < SM4_KEYSIZE then
    while Length(Key) < SM4_KEYSIZE do Key := Key + Chr(0) // 16 bytes at least padding 0.
  else if Length(Key) > SM4_KEYSIZE then
    Key := Copy(Key, 1, SM4_KEYSIZE);  // Only keep 16

  if Mode = SM4_ENCRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[1]));
    SM4CryptOfb(Ctx, SM4_ENCRYPT, Length(Input), @(Iv[0]), @(Input[1]), @(Output[0]));
  end
  else if Mode = SM4_DECRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[1])); // ע�� OFB �Ľ���Ҳ�õ��Ǽ��ܣ�
    SM4CryptOfb(Ctx, SM4_DECRYPT, Length(Input), @(Iv[0]), @(Input[1]), @(Output[0]));
  end;
end;

procedure SM4EncryptEcbStr(Key: AnsiString; const Input: AnsiString; Output: PAnsiChar);
begin
  SM4CryptEcbStr(SM4_ENCRYPT, Key, Input, Output);
end;

procedure SM4DecryptEcbStr(Key: AnsiString; const Input: AnsiString; Output: PAnsiChar);
begin
  SM4CryptEcbStr(SM4_DECRYPT, Key, Input, Output);
end;

procedure SM4EncryptCbcStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
begin
  SM4CryptCbcStr(SM4_ENCRYPT, Key, Iv, Input, Output);
end;

procedure SM4DecryptCbcStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
begin
  SM4CryptCbcStr(SM4_DECRYPT, Key, Iv, Input, Output);
end;

procedure SM4EncryptCfbStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
begin
  SM4CryptCfbStr(SM4_ENCRYPT, Key, Iv, Input, Output);
end;

procedure SM4DecryptCfbStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
begin
  SM4CryptCfbStr(SM4_DECRYPT, Key, Iv, Input, Output);
end;

procedure SM4EncryptOfbStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
begin
  SM4CryptOfbStr(SM4_ENCRYPT, Key, Iv, Input, Output);
end;

procedure SM4DecryptOfbStr(Key: AnsiString; Iv: PAnsiChar;
  const Input: AnsiString; Output: PAnsiChar);
begin
  SM4CryptOfbStr(SM4_DECRYPT, Key, Iv, Input, Output);
end;

{$IFDEF TBYTES_DEFINED}

function SM4CryptEcbBytes(Mode: Integer; Key: TBytes;
  const Input: TBytes): TBytes;
var
  Ctx: TSM4Context;
  I, Len: Integer;
begin
  Len := Length(Input);
  if Len <= 0 then
  begin
    Result := nil;
    Exit;
  end;
  SetLength(Result, (((Len - 1) div 16) + 1) * 16);

  Len := Length(Key);
  if Len < SM4_KEYSIZE then // Key ����С�� 16 �ֽڲ� 0
  begin
    SetLength(Key, SM4_KEYSIZE);
    for I := Len to SM4_KEYSIZE - 1 do
      Key[I] := 0;
  end;
  // ���ȴ��� 16 �ֽ�ʱ SM4SetKeyEnc ���Զ����Ժ���Ĳ���

  if Mode = SM4_ENCRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[0]));
    SM4CryptEcb(Ctx, SM4_ENCRYPT, Length(Input), @(Input[0]), @(Result[0]));
  end
  else if Mode = SM4_DECRYPT then
  begin
    SM4SetKeyDec(Ctx, @(Key[0]));
    SM4CryptEcb(Ctx, SM4_DECRYPT, Length(Input), @(Input[0]), @(Result[0]));
  end;
end;

function SM4CryptCbcBytes(Mode: Integer; Key, Iv: TBytes;
  const Input: TBytes): TBytes;
var
  Ctx: TSM4Context;
  I, Len: Integer;
begin
  Len := Length(Input);
  if Len <= 0 then
  begin
    Result := nil;
    Exit;
  end;
  SetLength(Result, (((Len - 1) div 16) + 1) * 16);

  Len := Length(Key);
  if Len < SM4_KEYSIZE then // Key ����С�� 16 �ֽڲ� 0
  begin
    SetLength(Key, SM4_KEYSIZE);
    for I := Len to SM4_KEYSIZE - 1 do
      Key[I] := 0;
  end;
  // ���ȴ��� 16 �ֽ�ʱ SM4SetKeyEnc ���Զ����Ժ���Ĳ���

  Len := Length(Iv);
  if Len < SM4_BLOCKSIZE then // Iv ����С�� 16 �ֽڲ� 0
  begin
    SetLength(Iv, SM4_BLOCKSIZE);
    for I := Len to SM4_BLOCKSIZE - 1 do
      Iv[I] := 0;
  end;

  if Mode = SM4_ENCRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[0]));
    SM4CryptCbc(Ctx, SM4_ENCRYPT, Length(Input), @(Iv[0]), @(Input[0]), @(Result[0]));
  end
  else if Mode = SM4_DECRYPT then
  begin
    SM4SetKeyDec(Ctx, @(Key[0]));
    SM4CryptCbc(Ctx, SM4_DECRYPT, Length(Input), @(Iv[0]), @(Input[0]), @(Result[0]));
  end;
end;

function SM4CryptCfbBytes(Mode: Integer; Key, Iv: TBytes;
  const Input: TBytes): TBytes;
var
  Ctx: TSM4Context;
  I, Len: Integer;
begin
  Len := Length(Input);
  if Len <= 0 then
  begin
    Result := nil;
    Exit;
  end;
  SetLength(Result, (((Len - 1) div 16) + 1) * 16);

  Len := Length(Key);
  if Len < SM4_KEYSIZE then // Key ����С�� 16 �ֽڲ� 0
  begin
    SetLength(Key, SM4_KEYSIZE);
    for I := Len to SM4_KEYSIZE - 1 do
      Key[I] := 0;
  end;
  // ���ȴ��� 16 �ֽ�ʱ SM4SetKeyEnc ���Զ����Ժ���Ĳ���

  Len := Length(Iv);
  if Len < SM4_BLOCKSIZE then // Iv ����С�� 16 �ֽڲ� 0
  begin
    SetLength(Iv, SM4_BLOCKSIZE);
    for I := Len to SM4_BLOCKSIZE - 1 do
      Iv[I] := 0;
  end;

  if Mode = SM4_ENCRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[0]));
    SM4CryptCfb(Ctx, SM4_ENCRYPT, Length(Input), @(Iv[0]), @(Input[0]), @(Result[0]));
  end
  else if Mode = SM4_DECRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[0])); // ע�� CFB �Ľ���Ҳ�õ��Ǽ��ܣ�
    SM4CryptCfb(Ctx, SM4_DECRYPT, Length(Input), @(Iv[0]), @(Input[0]), @(Result[0]));
  end;
end;

function SM4CryptOfbBytes(Mode: Integer; Key, Iv: TBytes;
  const Input: TBytes): TBytes;
var
  Ctx: TSM4Context;
  I, Len: Integer;
begin
  Len := Length(Input);
  if Len <= 0 then
  begin
    Result := nil;
    Exit;
  end;
  SetLength(Result, (((Len - 1) div 16) + 1) * 16);

  Len := Length(Key);
  if Len < SM4_KEYSIZE then // Key ����С�� 16 �ֽڲ� 0
  begin
    SetLength(Key, SM4_KEYSIZE);
    for I := Len to SM4_KEYSIZE - 1 do
      Key[I] := 0;
  end;
  // ���ȴ��� 16 �ֽ�ʱ SM4SetKeyEnc ���Զ����Ժ���Ĳ���

  Len := Length(Iv);
  if Len < SM4_BLOCKSIZE then // Iv ����С�� 16 �ֽڲ� 0
  begin
    SetLength(Iv, SM4_BLOCKSIZE);
    for I := Len to SM4_BLOCKSIZE - 1 do
      Iv[I] := 0;
  end;

  if Mode = SM4_ENCRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[0]));
    SM4CryptOfb(Ctx, SM4_ENCRYPT, Length(Input), @(Iv[0]), @(Input[0]), @(Result[0]));
  end
  else if Mode = SM4_DECRYPT then
  begin
    SM4SetKeyEnc(Ctx, @(Key[0])); // ע�� OFB �Ľ���Ҳ�õ��Ǽ��ܣ�
    SM4CryptOfb(Ctx, SM4_DECRYPT, Length(Input), @(Iv[0]), @(Input[0]), @(Result[0]));
  end;
end;

function SM4EncryptEcbBytes(Key: TBytes; const Input: TBytes): TBytes;
begin
  Result := SM4CryptEcbBytes(SM4_ENCRYPT, Key, Input);
end;

function SM4DecryptEcbBytes(Key: TBytes; const Input: TBytes): TBytes;
begin
  Result := SM4CryptEcbBytes(SM4_DECRYPT, Key, Input);
end;

function SM4EncryptCbcBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
begin
  Result := SM4CryptCbcBytes(SM4_ENCRYPT, Key, Iv, Input);
end;

function SM4DecryptCbcBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
begin
  Result := SM4CryptCbcBytes(SM4_DECRYPT, Key, Iv, Input);
end;

function SM4EncryptCfbBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
begin
  Result := SM4CryptCfbBytes(SM4_ENCRYPT, Key, Iv, Input);
end;

function SM4DecryptCfbBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
begin
  Result := SM4CryptCfbBytes(SM4_DECRYPT, Key, Iv, Input);
end;

function SM4EncryptOfbBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
begin
  Result := SM4CryptOfbBytes(SM4_ENCRYPT, Key, Iv, Input);
end;

function SM4DecryptOfbBytes(Key, Iv: TBytes; const Input: TBytes): TBytes;
begin
  Result := SM4CryptOfbBytes(SM4_DECRYPT, Key, Iv, Input);
end;

{$ENDIF}

procedure SM4EncryptStreamECB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; Dest: TStream); overload;
var
  TempIn, TempOut: TSM4Buffer;
  Done: Cardinal;
  Ctx: TSM4Context;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end
  else
    Count := Min(Count, Source.Size - Source.Position);

  if Count = 0 then
    Exit;

  SM4SetKeyEnc(Ctx, @(Key[0]));
  while Count >= SizeOf(TSM4Buffer) do
  begin
    Done := Source.Read(TempIn, SizeOf(TempIn));
    if Done < SizeOf(TempIn) then
      raise EStreamError.Create(SReadError);

    SM4OneRound(@(Ctx.Sk[0]), @(TempIn[0]), @(TempOut[0]));

    Done := Dest.Write(TempOut, SizeOf(TempOut));
    if Done < SizeOf(TempOut) then
      raise EStreamError.Create(SWriteError);

    Dec(Count, SizeOf(TSM4Buffer));
  end;

  if Count > 0 then // β���� 0
  begin
    Done := Source.Read(TempIn, Count);
    if Done < Count then
      raise EStreamError.Create(SReadError);
    FillChar(TempIn[Count], SizeOf(TempIn) - Count, 0);

    SM4OneRound(@(Ctx.Sk[0]), @(TempIn[0]), @(TempOut[0]));

    Done := Dest.Write(TempOut, SizeOf(TempOut));
    if Done < SizeOf(TempOut) then
      raise EStreamError.Create(SWriteError);
  end;
end;

procedure SM4DecryptStreamECB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; Dest: TStream); overload;
var
  TempIn, TempOut: TSM4Buffer;
  Done: Cardinal;
  Ctx: TSM4Context;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end
  else
    Count := Min(Count, Source.Size - Source.Position);

  if Count = 0 then
    Exit;
  if (Count mod SizeOf(TSM4Buffer)) > 0 then
    raise Exception.Create(SInvalidInBufSize);

  SM4SetKeyDec(Ctx, @(Key[0]));
  while Count >= SizeOf(TSM4Buffer) do
  begin
    Done := Source.Read(TempIn, SizeOf(TempIn));
    if Done < SizeOf(TempIn) then
      raise EStreamError.Create(SReadError);

    SM4OneRound(@(Ctx.Sk[0]), @(TempIn[0]), @(TempOut[0]));

    Done := Dest.Write(TempOut, SizeOf(TempOut));
    if Done < SizeOf(TempOut) then
      raise EStreamError.Create(SWriteError);

    Dec(Count, SizeOf(TSM4Buffer));
  end;
end;

procedure SM4EncryptStreamCBC(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
var
  TempIn, TempOut: TSM4Buffer;
  Vector: TSM4Iv;
  Done: Cardinal;
  Ctx: TSM4Context;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end
  else
    Count := Min(Count, Source.Size - Source.Position);

  if Count = 0 then
    Exit;

  Vector := InitVector;
  SM4SetKeyEnc(Ctx, @(Key[0]));

  while Count >= SizeOf(TSM4Buffer) do
  begin
    Done := Source.Read(TempIn, SizeOf(TempIn));
    if Done < SizeOf(TempIn) then
      raise EStreamError.Create(SReadError);

    PCnLongWord32(@TempIn[0])^ := PCnLongWord32(@TempIn[0])^ xor PCnLongWord32(@Vector[0])^;
    PCnLongWord32(@TempIn[4])^ := PCnLongWord32(@TempIn[4])^ xor PCnLongWord32(@Vector[4])^;
    PCnLongWord32(@TempIn[8])^ := PCnLongWord32(@TempIn[8])^ xor PCnLongWord32(@Vector[8])^;
    PCnLongWord32(@TempIn[12])^ := PCnLongWord32(@TempIn[12])^ xor PCnLongWord32(@Vector[12])^;

    SM4OneRound(@(Ctx.Sk[0]), @(TempIn[0]), @(TempOut[0]));

    Done := Dest.Write(TempOut, SizeOf(TempOut));
    if Done < SizeOf(TempOut) then
      raise EStreamError.Create(SWriteError);

    Move(TempOut[0], Vector[0], SizeOf(TSM4Iv));
    Dec(Count, SizeOf(TSM4Buffer));
  end;

  if Count > 0 then
  begin
    Done := Source.Read(TempIn, Count);
    if Done < Count then
      raise EStreamError.Create(SReadError);
    FillChar(TempIn[Count], SizeOf(TempIn) - Count, 0);

    PCnLongWord32(@TempIn[0])^ := PCnLongWord32(@TempIn[0])^ xor PCnLongWord32(@Vector[0])^;
    PCnLongWord32(@TempIn[4])^ := PCnLongWord32(@TempIn[4])^ xor PCnLongWord32(@Vector[4])^;
    PCnLongWord32(@TempIn[8])^ := PCnLongWord32(@TempIn[8])^ xor PCnLongWord32(@Vector[8])^;
    PCnLongWord32(@TempIn[12])^ := PCnLongWord32(@TempIn[12])^ xor PCnLongWord32(@Vector[12])^;

    SM4OneRound(@(Ctx.Sk[0]), @(TempIn[0]), @(TempOut[0]));

    Done := Dest.Write(TempOut, SizeOf(TempOut));
    if Done < SizeOf(TempOut) then
      raise EStreamError.Create(SWriteError);
  end;
end;

procedure SM4DecryptStreamCBC(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
var
  TempIn, TempOut: TSM4Buffer;
  Vector1, Vector2: TSM4Iv;
  Done: Cardinal;
  Ctx: TSM4Context;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end
  else
    Count := Min(Count, Source.Size - Source.Position);

  if Count = 0 then
    Exit;
  if (Count mod SizeOf(TSM4Buffer)) > 0 then
    raise Exception.Create(SInvalidInBufSize);

  Vector1 := InitVector;
  SM4SetKeyDec(Ctx, @(Key[0]));

  while Count >= SizeOf(TSM4Buffer) do
  begin
    Done := Source.Read(TempIn, SizeOf(TempIn));
    if Done < SizeOf(TempIn) then
      raise EStreamError(SReadError);

    Move(TempIn[0], Vector2[0], SizeOf(TSM4Iv));
    SM4OneRound(@(Ctx.Sk[0]), @(TempIn[0]), @(TempOut[0]));

    PCnLongWord32(@TempOut[0])^ := PCnLongWord32(@TempOut[0])^ xor PCnLongWord32(@Vector1[0])^;
    PCnLongWord32(@TempOut[4])^ := PCnLongWord32(@TempOut[4])^ xor PCnLongWord32(@Vector1[4])^;
    PCnLongWord32(@TempOut[8])^ := PCnLongWord32(@TempOut[8])^ xor PCnLongWord32(@Vector1[8])^;
    PCnLongWord32(@TempOut[12])^ := PCnLongWord32(@TempOut[12])^ xor PCnLongWord32(@Vector1[12])^;

    Done := Dest.Write(TempOut, SizeOf(TempOut));
    if Done < SizeOf(TempOut) then
      raise EStreamError(SWriteError);

    Vector1 := Vector2;
    Dec(Count, SizeOf(TSM4Buffer));
  end;
end;

procedure SM4EncryptStreamCFB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
var
  TempIn, TempOut: TSM4Buffer;
  Vector: TSM4Iv;
  Done: Cardinal;
  Ctx: TSM4Context;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end
  else
    Count := Min(Count, Source.Size - Source.Position);

  if Count = 0 then
    Exit;

  Vector := InitVector;
  SM4SetKeyEnc(Ctx, @(Key[0]));

  while Count >= SizeOf(TSM4Buffer) do
  begin
    Done := Source.Read(TempIn, SizeOf(TempIn));
    if Done < SizeOf(TempIn) then
      raise EStreamError.Create(SReadError);

    SM4OneRound(@(Ctx.Sk[0]), @(Vector[0]), @(TempOut[0]));     // Key �ȼ��� Iv

    PCnLongWord32(@TempOut[0])^ := PCnLongWord32(@TempIn[0])^ xor PCnLongWord32(@TempOut[0])^;  // ���ܽ�����������
    PCnLongWord32(@TempOut[4])^ := PCnLongWord32(@TempIn[4])^ xor PCnLongWord32(@TempOut[4])^;
    PCnLongWord32(@TempOut[8])^ := PCnLongWord32(@TempIn[8])^ xor PCnLongWord32(@TempOut[8])^;
    PCnLongWord32(@TempOut[12])^ := PCnLongWord32(@TempIn[12])^ xor PCnLongWord32(@TempOut[12])^;

    Done := Dest.Write(TempOut, SizeOf(TempOut));   // ���Ľ��д�����Ľ��
    if Done < SizeOf(TempOut) then
      raise EStreamError.Create(SWriteError);

    Move(TempOut[0], Vector[0], SizeOf(TSM4Iv));    // ���Ľ��ȡ�� Iv ����һ�ּ���
    Dec(Count, SizeOf(TSM4Buffer));
  end;

  if Count > 0 then
  begin
    Done := Source.Read(TempIn, Count);
    if Done < Count then
      raise EStreamError.Create(SReadError);
    SM4OneRound(@(Ctx.Sk[0]), @(Vector[0]), @(TempOut[0]));

    PCnLongWord32(@TempOut[0])^ := PCnLongWord32(@TempIn[0])^ xor PCnLongWord32(@TempOut[0])^;
    PCnLongWord32(@TempOut[4])^ := PCnLongWord32(@TempIn[4])^ xor PCnLongWord32(@TempOut[4])^;
    PCnLongWord32(@TempOut[8])^ := PCnLongWord32(@TempIn[8])^ xor PCnLongWord32(@TempOut[8])^;
    PCnLongWord32(@TempOut[12])^ := PCnLongWord32(@TempIn[12])^ xor PCnLongWord32(@TempOut[12])^;

    Done := Dest.Write(TempOut, Count);  // ���д���ֻ�������ĳ��ȵĲ��֣�����������
    if Done < Count then
      raise EStreamError.Create(SWriteError);
  end;
end;

procedure SM4DecryptStreamCFB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
var
  TempIn, TempOut: TSM4Buffer;
  Vector: TSM4Iv;
  Done: Cardinal;
  Ctx: TSM4Context;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end
  else
    Count := Min(Count, Source.Size - Source.Position);

  if Count = 0 then
    Exit;

  Vector := InitVector;
  SM4SetKeyEnc(Ctx, @(Key[0]));  // ע���Ǽ��ܣ����ǽ��ܣ�

  while Count >= SizeOf(TSM4Buffer) do
  begin
    Done := Source.Read(TempIn, SizeOf(TempIn));             // ���Ķ����� TempIn
    if Done < SizeOf(TempIn) then
      raise EStreamError(SReadError);
    SM4OneRound(@(Ctx.Sk[0]), @(Vector[0]), @(TempOut[0])); // Iv �ȼ����� TempOut

    // ���ܺ������ TempOut ������ TempIn ���õ����� TempOut
    PCnLongWord32(@TempOut[0])^ := PCnLongWord32(@TempOut[0])^ xor PCnLongWord32(@TempIn[0])^;
    PCnLongWord32(@TempOut[4])^ := PCnLongWord32(@TempOut[4])^ xor PCnLongWord32(@TempIn[4])^;
    PCnLongWord32(@TempOut[8])^ := PCnLongWord32(@TempOut[8])^ xor PCnLongWord32(@TempIn[8])^;
    PCnLongWord32(@TempOut[12])^ := PCnLongWord32(@TempOut[12])^ xor PCnLongWord32(@TempIn[12])^;

    Done := Dest.Write(TempOut, SizeOf(TempOut));      // ���� TempOut д��ȥ
    if Done < SizeOf(TempOut) then
      raise EStreamError(SWriteError);
    Move(TempIn[0], Vector[0], SizeOf(TSM4Iv));       // �������� TempIn ȡ�� Iv ��Ϊ��һ�μ�������������
    Dec(Count, SizeOf(TSM4Buffer));
  end;

  if Count > 0 then
  begin
    Done := Source.Read(TempIn, Count);
    if Done < Count then
      raise EStreamError.Create(SReadError);
    SM4OneRound(@(Ctx.Sk[0]), @(Vector[0]), @(TempOut[0]));

    PCnLongWord32(@TempOut[0])^ := PCnLongWord32(@TempIn[0])^ xor PCnLongWord32(@TempOut[0])^;
    PCnLongWord32(@TempOut[4])^ := PCnLongWord32(@TempIn[4])^ xor PCnLongWord32(@TempOut[4])^;
    PCnLongWord32(@TempOut[8])^ := PCnLongWord32(@TempIn[8])^ xor PCnLongWord32(@TempOut[8])^;
    PCnLongWord32(@TempOut[12])^ := PCnLongWord32(@TempIn[12])^ xor PCnLongWord32(@TempOut[12])^;

    Done := Dest.Write(TempOut, Count);  // ���д���ֻ�������ĳ��ȵĲ��֣�����������
    if Done < Count then
      raise EStreamError.Create(SWriteError);
  end;
end;

procedure SM4EncryptStreamOFB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
var
  TempIn, TempOut: TSM4Buffer;
  Vector: TSM4Iv;
  Done: Cardinal;
  Ctx: TSM4Context;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end
  else
    Count := Min(Count, Source.Size - Source.Position);

  if Count = 0 then
    Exit;

  Vector := InitVector;
  SM4SetKeyEnc(Ctx, @(Key[0]));

  while Count >= SizeOf(TSM4Buffer) do
  begin
    Done := Source.Read(TempIn, SizeOf(TempIn));
    if Done < SizeOf(TempIn) then
      raise EStreamError.Create(SReadError);

    SM4OneRound(@(Ctx.Sk[0]), @(Vector[0]), @(TempOut[0]));     // Key �ȼ��� Iv

    PCnLongWord32(@TempIn[0])^ := PCnLongWord32(@TempIn[0])^ xor PCnLongWord32(@TempOut[0])^;  // ���ܽ�����������
    PCnLongWord32(@TempIn[4])^ := PCnLongWord32(@TempIn[4])^ xor PCnLongWord32(@TempOut[4])^;
    PCnLongWord32(@TempIn[8])^ := PCnLongWord32(@TempIn[8])^ xor PCnLongWord32(@TempOut[8])^;
    PCnLongWord32(@TempIn[12])^ := PCnLongWord32(@TempIn[12])^ xor PCnLongWord32(@TempOut[12])^;

    Done := Dest.Write(TempIn, SizeOf(TempIn));   // ���Ľ��д�����Ľ��
    if Done < SizeOf(TempIn) then
      raise EStreamError.Create(SWriteError);

    Move(TempOut[0], Vector[0], SizeOf(TSM4Iv));    // ���ܽ��ȡ�� Iv ����һ�ּ��ܣ�ע�ⲻ�������
    Dec(Count, SizeOf(TSM4Buffer));
  end;

  if Count > 0 then
  begin
    Done := Source.Read(TempIn, Count);
    if Done < Count then
      raise EStreamError.Create(SReadError);
    SM4OneRound(@(Ctx.Sk[0]), @(Vector[0]), @(TempOut[0]));

    PCnLongWord32(@TempIn[0])^ := PCnLongWord32(@TempIn[0])^ xor PCnLongWord32(@TempOut[0])^;
    PCnLongWord32(@TempIn[4])^ := PCnLongWord32(@TempIn[4])^ xor PCnLongWord32(@TempOut[4])^;
    PCnLongWord32(@TempIn[8])^ := PCnLongWord32(@TempIn[8])^ xor PCnLongWord32(@TempOut[8])^;
    PCnLongWord32(@TempIn[12])^ := PCnLongWord32(@TempIn[12])^ xor PCnLongWord32(@TempOut[12])^;

    Done := Dest.Write(TempIn, Count);  // ���д���ֻ�������ĳ��ȵĲ��֣�����������
    if Done < Count then
      raise EStreamError.Create(SWriteError);
  end;
end;

procedure SM4DecryptStreamOFB(Source: TStream; Count: Cardinal;
  const Key: TSM4Key; const InitVector: TSM4Iv; Dest: TStream); overload;
var
  TempIn, TempOut: TSM4Buffer;
  Vector: TSM4Iv;
  Done: Cardinal;
  Ctx: TSM4Context;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end
  else
    Count := Min(Count, Source.Size - Source.Position);

  if Count = 0 then
    Exit;

  Vector := InitVector;
  SM4SetKeyEnc(Ctx, @(Key[0]));  // ע���Ǽ��ܣ����ǽ��ܣ�

  while Count >= SizeOf(TSM4Buffer) do
  begin
    Done := Source.Read(TempIn, SizeOf(TempIn));             // ���Ķ����� TempIn
    if Done < SizeOf(TempIn) then
      raise EStreamError(SReadError);
    SM4OneRound(@(Ctx.Sk[0]), @(Vector[0]), @(TempOut[0])); // Iv �ȼ����� TempOut

    // ���ܺ������ TempOut ������ TempIn ���õ����� TempIn
    PCnLongWord32(@TempIn[0])^ := PCnLongWord32(@TempOut[0])^ xor PCnLongWord32(@TempIn[0])^;
    PCnLongWord32(@TempIn[4])^ := PCnLongWord32(@TempOut[4])^ xor PCnLongWord32(@TempIn[4])^;
    PCnLongWord32(@TempIn[8])^ := PCnLongWord32(@TempOut[8])^ xor PCnLongWord32(@TempIn[8])^;
    PCnLongWord32(@TempIn[12])^ := PCnLongWord32(@TempOut[12])^ xor PCnLongWord32(@TempIn[12])^;

    Done := Dest.Write(TempIn, SizeOf(TempIn));      // ���� TempIn д��ȥ
    if Done < SizeOf(TempIn) then
      raise EStreamError(SWriteError);
    Move(TempOut[0], Vector[0], SizeOf(TSM4Iv));       // �������ܽ�� TempOut ȡ�� Iv ��Ϊ��һ�μ�������������
    Dec(Count, SizeOf(TSM4Buffer));
  end;

  if Count > 0 then
  begin
    Done := Source.Read(TempIn, Count);
    if Done < Count then
      raise EStreamError.Create(SReadError);
    SM4OneRound(@(Ctx.Sk[0]), @(Vector[0]), @(TempOut[0]));

    PCnLongWord32(@TempIn[0])^ := PCnLongWord32(@TempIn[0])^ xor PCnLongWord32(@TempOut[0])^;
    PCnLongWord32(@TempIn[4])^ := PCnLongWord32(@TempIn[4])^ xor PCnLongWord32(@TempOut[4])^;
    PCnLongWord32(@TempIn[8])^ := PCnLongWord32(@TempIn[8])^ xor PCnLongWord32(@TempOut[8])^;
    PCnLongWord32(@TempIn[12])^ := PCnLongWord32(@TempIn[12])^ xor PCnLongWord32(@TempOut[12])^;

    Done := Dest.Write(TempOut, Count);  // ���д���ֻ�������ĳ��ȵĲ��֣�����������
    if Done < Count then
      raise EStreamError.Create(SWriteError);
  end;
end;

procedure SM4Encrypt(Key: PAnsiChar; Input: PAnsiChar; Output: PAnsiChar; Len: Integer);
var
  Ctx: TSM4Context;
begin
  SM4SetKeyEnc(Ctx, Key);
  SM4CryptEcb(Ctx, SM4_ENCRYPT, Len, Input, Output);
end;

procedure SM4Decrypt(Key: PAnsiChar; Input: PAnsiChar; Output: PAnsiChar; Len: Integer);
var
  Ctx: TSM4Context;
begin
  SM4SetKeyDec(Ctx, Key);
  SM4CryptEcb(Ctx, SM4_DECRYPT, Len, Input, Output);
end;

end.
