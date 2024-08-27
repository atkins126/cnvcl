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

{ -----------------------------------------------------------------------------}
{ uTBase64 v1.0 - Simple Base64 encoding/decoding class                        }
{ Base64 described in RFC2045, Page 24, (w) 1996 Freed & Borenstein            }
{ Delphi implementation (w) 1999 Dennis D. Spreen (dennis@spreendigital.de)    }
{ This unit is freeware. Just drop me a line if this unit is useful for you.   }
{ -----------------------------------------------------------------------------}

unit CnBase64;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�Base64 ������㷨ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�ղ����Solin�� solin@21cn.com; http://www.ilovezhuzhu.net
*           wr960204
*           CnPack ������ (master@cnpack.org)
*           �������ݻ��� Dennis D. Spreen �� UTBASE64.pas ��д������ԭ�а�Ȩ��Ϣ��
* ��    ע������Ԫʵ���˱�׼ Base64 �� Base64URL �ı�������빦�ܡ�
*           Base64URL ������ڱ�׼ Base64�����ѷ��� + / �滻���� - _ ������ URL �����
*           �Ѻã���ɾ����β���� =
*
* ����ƽ̨��PWin2003Std + Delphi 6.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2023.10.04 V1.6
*               ɾ������ʵ�֡�Base64Encode �� Base64Decode ֧�� Base64URL �ı��������
*           2019.12.12 V1.5
*               ֧�� TBytes
*           2019.04.15 V1.4
*               ֧�� Win32/Win64/MacOS
*           2018.06.22 V1.3
*               ���������ԭʼ���ݿ��ܰ������� #0 ��ԭʼβ�� #0 �������Ƴ�������
*           2016.05.03 V1.2
*               �����ַ����а��� #0 ʱ���ܻᱻ�ضϵ�����
*           2006.10.25 V1.1
*               ���� wr960204 ���Ż��汾
*           2003.10.14 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNative, CnConsts;

function Base64Encode(InputData: TStream; var OutputData: string;
  URL: Boolean = False): Integer; overload;
{* �������� Base64 ����� Base64URL ���룬�����ɹ����� ECN_BASE64_OK
|<PRE>
  InputData: TStream           - Ҫ�����������
  var OutputData: AnsiString   - ����������
  URL: Boolean                 - True ��ʹ�� Base64URL ���룬False ��ʹ�ñ�׼ Base64 ���룬Ĭ�� False
|</PRE>}

function Base64Encode(const InputData: AnsiString; var OutputData: string;
  URL: Boolean = False): Integer; overload;
{* ���ַ������� Base64 ����� Base64URL ���룬�����ɹ����� ECN_BASE64_OK
|<PRE>
  InputData: AnsiString        - Ҫ���������
  var OutputData: AnsiString   - ����������
  URL: Boolean                 - True ��ʹ�� Base64URL ���룬False ��ʹ�ñ�׼ Base64 ���룬Ĭ�� False
|</PRE>}

function Base64Encode(InputData: Pointer; DataLen: Integer; var OutputData: string;
  URL: Boolean = False): Integer; overload;
{* �����ݽ��� Base64 ����� Base64URL ���룬�����ɹ����� ECN_BASE64_OK
|<PRE>
  InputData: AnsiString        - Ҫ���������
  var OutputData: AnsiString   - ����������
  URL: Boolean                 - True ��ʹ�� Base64URL ���룬False ��ʹ�ñ�׼ Base64 ���룬Ĭ�� False
|</PRE>}

function Base64Encode(InputData: TBytes; var OutputData: string;
  URL: Boolean = False): Integer; overload;
{* �� TBytes ���� Base64 ����� Base64URL ���룬�����ɹ����� ECN_BASE64_OK
|<PRE>
  InputData: TBytes            - Ҫ�����������
  var OutputData: AnsiString   - ����������
  URL: Boolean                 - True ��ʹ�� Base64URL ���룬False ��ʹ�ñ�׼ Base64 ���룬Ĭ�� False
|</PRE>}

function Base64Decode(const InputData: AnsiString; var OutputData: AnsiString;
  FixZero: Boolean = True): Integer; overload;
{* �����ݽ��� Base64 ���루���� Base64URL ���룩�������ɹ����� ECN_BASE64_OK
|<PRE>
  InputData: AnsiString        - Ҫ���������
  var OutputData: AnsiString   - ����������
  FixZero: Boolean             - �Ƿ���ȥβ���� #0
|</PRE>}

function Base64Decode(const InputData: AnsiString; OutputData: TStream;
  FixZero: Boolean = True): Integer; overload;
{* �����ݽ��� Base64 ���루���� Base64URL ���룩�������ɹ����� ECN_BASE64_OK
|<PRE>
  InputData: AnsiString        - Ҫ���������
  var OutputData: TStream      - ����������
  FixZero: Boolean             - �Ƿ���ȥβ���� #0
|</PRE>}

function Base64Decode(InputData: string; out OutputData: TBytes;
  FixZero: Boolean = True): Integer; overload;
{* �����ݽ��� Base64 ���루���� Base64URL ���룩�������ɹ����� ECN_BASE64_OK
|<PRE>
  InputData: string            - Ҫ���������
  out OutputData: TBytes       - ����������
  FixZero: Boolean             - �Ƿ���ȥβ���� 0
|</PRE>}

const
  ECN_BASE64_OK                        = ECN_OK; // ת���ɹ�
  ECN_BASE64_ERROR_BASE                = ECN_CUSTOM_ERROR_BASE + $500; // Base64 �������׼

  ECN_BASE64_ERROR                     = ECN_BASE64_ERROR_BASE + 1; // ת������δ֪���� (e.g. can't encode octet in input stream) -> error in implementation
  ECN_BASE64_INVALID                   = ECN_BASE64_ERROR_BASE + 2; // ������ַ������зǷ��ַ� (�� FilterDecodeInput=False ʱ���ܳ���)
  ECN_BASE64_LENGTH                    = ECN_BASE64_ERROR_BASE + 3; // ���ݳ��ȷǷ�
  ECN_BASE64_DATALEFT                  = ECN_BASE64_ERROR_BASE + 4; // too much input data left (receveived 'end of encoded data' but not end of input string)
  ECN_BASE64_PADDING                   = ECN_BASE64_ERROR_BASE + 5; // ���������δ������ȷ������ַ�����

implementation

var
  FilterDecodeInput: Boolean = True;

//------------------------------------------------------------------------------
// ����Ĳο���
//------------------------------------------------------------------------------

  EnCodeTab: array[0..64] of AnsiChar =
  (
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '+', '/',
    '=');

  EnCodeTabURL: array[0..64] of AnsiChar =
  (
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '-', '_',
    '=');

//------------------------------------------------------------------------------
// ����Ĳο���
//------------------------------------------------------------------------------

  { �������� Base64 ������ַ�ֱ�Ӹ��㣬����Ҳȡ����}
  DecodeTable: array[#0..#127] of Byte =
  (
    Byte('='), 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
    00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
    00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 62, 00, 62, 00, 63,  // ����ĵ�һ�� 62���� 63 �� + �� /����� - ���� 62
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 00, 00, 00, 00, 00, 00,
    00, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 00, 00, 00, 00, 63,  // _ ���� 63
    00, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 00, 00, 00, 00, 00
  );

function Base64Encode(InputData: TStream; var OutputData: string; URL: Boolean): Integer;
var
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream.Create;
  try
    Mem.CopyFrom(InputData, InputData.Size);
    Result := Base64Encode(Mem.Memory, Mem.Size, OutputData, URL);
  finally
    Mem.Free;
  end;
end;

// ����Ϊ wr960204 �Ľ��Ŀ��� Base64 ������㷨
function Base64Encode(InputData: Pointer; DataLen: Integer; var OutputData: string;
  URL: Boolean): Integer;
var
  Times, I: Integer;
  x1, x2, x3, x4: AnsiChar;
  Xt: Byte;
begin
  if (InputData = nil) or (DataLen <= 0) then
  begin
    Result := ECN_BASE64_LENGTH;
    Exit;
  end;

  if DataLen mod 3 = 0 then
    Times := DataLen div 3
  else
    Times := DataLen div 3 + 1;
  SetLength(OutputData, Times * 4);   //һ�η��������ڴ�,����һ�δ��ַ������,һ�δ��ͷŷ����ڴ�

  if URL then
  begin
    for I := 0 to Times - 1 do
    begin
      if DataLen >= (3 + I * 3) then
      begin
        x1 := EnCodeTabURL[(Ord(PAnsiChar(InputData)[I * 3]) shr 2)];
        Xt := (Ord(PAnsiChar(InputData)[I * 3]) shl 4) and 48;
        Xt := Xt or (Ord(PAnsiChar(InputData)[1 + I * 3]) shr 4);
        x2 := EnCodeTabURL[Xt];
        Xt := (Ord(PAnsiChar(InputData)[1 + I * 3]) shl 2) and 60;
        Xt := Xt or (Ord(PAnsiChar(InputData)[2 + I * 3]) shr 6);
        x3 := EnCodeTabURL[Xt];
        Xt := (Ord(PAnsiChar(InputData)[2 + I * 3]) and 63);
        x4 := EnCodeTabURL[Xt];
      end
      else if DataLen >= (2 + I * 3) then
      begin
        x1 := EnCodeTabURL[(Ord(PAnsiChar(InputData)[I * 3]) shr 2)];
        Xt := (Ord(PAnsiChar(InputData)[I * 3]) shl 4) and 48;
        Xt := Xt or (Ord(PAnsiChar(InputData)[1 + I * 3]) shr 4);
        x2 := EnCodeTabURL[Xt];
        Xt := (Ord(PAnsiChar(InputData)[1 + I * 3]) shl 2) and 60;
        x3 := EnCodeTabURL[Xt ];
        x4 := '=';
      end
      else
      begin
        x1 := EnCodeTabURL[(Ord(PAnsiChar(InputData)[I * 3]) shr 2)];
        Xt := (Ord(PAnsiChar(InputData)[I * 3]) shl 4) and 48;
        x2 := EnCodeTabURL[Xt];
        x3 := '=';
        x4 := '=';
      end;
      OutputData[I shl 2 + 1] := Char(X1);
      OutputData[I shl 2 + 2] := Char(X2);
      OutputData[I shl 2 + 3] := Char(X3);
      OutputData[I shl 2 + 4] := Char(X4);
    end;
  end
  else
  begin
    for I := 0 to Times - 1 do
    begin
      if DataLen >= (3 + I * 3) then
      begin
        x1 := EnCodeTab[(Ord(PAnsiChar(InputData)[I * 3]) shr 2)];
        Xt := (Ord(PAnsiChar(InputData)[I * 3]) shl 4) and 48;
        Xt := Xt or (Ord(PAnsiChar(InputData)[1 + I * 3]) shr 4);
        x2 := EnCodeTab[Xt];
        Xt := (Ord(PAnsiChar(InputData)[1 + I * 3]) shl 2) and 60;
        Xt := Xt or (Ord(PAnsiChar(InputData)[2 + I * 3]) shr 6);
        x3 := EnCodeTab[Xt];
        Xt := (Ord(PAnsiChar(InputData)[2 + I * 3]) and 63);
        x4 := EnCodeTab[Xt];
      end
      else if DataLen >= (2 + I * 3) then
      begin
        x1 := EnCodeTab[(Ord(PAnsiChar(InputData)[I * 3]) shr 2)];
        Xt := (Ord(PAnsiChar(InputData)[I * 3]) shl 4) and 48;
        Xt := Xt or (Ord(PAnsiChar(InputData)[1 + I * 3]) shr 4);
        x2 := EnCodeTab[Xt];
        Xt := (Ord(PAnsiChar(InputData)[1 + I * 3]) shl 2) and 60;
        x3 := EnCodeTab[Xt ];
        x4 := '=';
      end
      else
      begin
        x1 := EnCodeTab[(Ord(PAnsiChar(InputData)[I * 3]) shr 2)];
        Xt := (Ord(PAnsiChar(InputData)[I * 3]) shl 4) and 48;
        x2 := EnCodeTab[Xt];
        x3 := '=';
        x4 := '=';
      end;
      OutputData[I shl 2 + 1] := Char(X1);
      OutputData[I shl 2 + 2] := Char(X2);
      OutputData[I shl 2 + 3] := Char(X3);
      OutputData[I shl 2 + 4] := Char(X4);
    end;
  end;

  OutputData := Trim(OutputData);
  if URL then
  begin
    // ɾ�� OutputData β���� = �ַ����������������
    if (Length(OutputData) > 0) and (OutputData[Length(OutputData)] = '=') then
    begin
      Delete(OutputData, Length(OutputData), 1);
      if (Length(OutputData) > 0) and (OutputData[Length(OutputData)] = '=') then
      begin
        Delete(OutputData, Length(OutputData), 1);
        if (Length(OutputData) > 0) and (OutputData[Length(OutputData)] = '=') then
          Delete(OutputData, Length(OutputData), 1);
      end;
    end;
  end;
  Result := ECN_BASE64_OK;
end;

function Base64Encode(const InputData: AnsiString; var OutputData: string; URL: Boolean): Integer;
begin
  if InputData <> '' then
    Result := Base64Encode(@InputData[1], Length(InputData), OutputData, URL)
  else
    Result := ECN_BASE64_LENGTH;
end;

function Base64Encode(InputData: TBytes; var OutputData: string; URL: Boolean): Integer;
begin
  if Length(InputData) > 0 then
    Result := Base64Encode(@InputData[0], Length(InputData), OutputData, URL)
  else
    Result := ECN_BASE64_LENGTH;
end;

function Base64Decode(const InputData: AnsiString; OutputData: TStream; FixZero: Boolean): Integer;
var
  Data: TBytes;
begin
  Result := Base64Decode(string(InputData), Data, FixZero);
  if (Result = ECN_BASE64_OK) and (Length(Data) > 0) then
  begin
    OutputData.Size := Length(Data);
    OutputData.Position := 0;
    OutputData.Write(Data[0], Length(Data));
  end;
end;

function Base64Decode(InputData: string; out OutputData: TBytes;
  FixZero: Boolean): Integer;
var
  SrcLen, DstLen, Times, I: Integer;
  x1, x2, x3, x4, xt: Byte;
  C, ToDec: Integer;
  Data: AnsiString;

  function FilterLine(const Source: AnsiString): AnsiString;
  var
    P, PP: PAnsiChar;
    I: Integer;
  begin
    SrcLen := Length(Source);
    GetMem(P, Srclen);                   // һ�η��������ڴ�,����һ�δ��ַ������,һ�δ��ͷŷ����ڴ�
    PP := P;
    FillChar(P^, Srclen, 0);
    for I := 1 to SrcLen do
    begin
      if Source[I] in ['0'..'9', 'A'..'Z', 'a'..'z', '+', '/', '=', '-', '_'] then
      begin
        PP^ := Source[I];
        Inc(PP);
      end;
    end;
    SetString(Result, P, PP - P);        // ��ȡ��Ч����
    FreeMem(P, SrcLen);
  end;

begin
  if (InputData = '') then
  begin
    Result := ECN_BASE64_OK;
    Exit;
  end;
  OutPutData := nil;

  if FilterDecodeInput then
    Data := FilterLine(AnsiString(InputData))
  else
    Data := AnsiString(InputData);

  // ����� Base64URL ����Ľ��ȥ����β���� =������Ҫ���ݳ����Ƿ��� 4 �ı���������
  if (Length(Data) and $03) <> 0 then
    Data := Data + StringOfChar(AnsiChar('='), 4 - (Length(Data) and $03));

  SrcLen := Length(Data);
  DstLen := SrcLen * 3 div 4;
  ToDec := 0;

  // β����һ���Ⱥ���ζ��ԭʼ���ݲ��˸� #0�������Ⱥ���ζ�Ų������� #0����Ҫȥ��Ҳ�������̳���
  // ע���ⲻ��ͬ��ԭʼ���ݵ�β���� #0 ���������������ȥ��
  if Data[SrcLen] = '=' then
  begin
    Inc(ToDec);
    if (SrcLen > 1) and (Data[SrcLen - 1] = '=') then
      Inc(ToDec);
  end;

  SetLength(OutputData, DstLen);  // һ�η��������ڴ�,����һ�δ��ַ������,һ�δ��ͷŷ����ڴ�
  Times := SrcLen div 4;
  C := 0;

  for I := 0 to Times - 1 do
  begin
    x1 := DecodeTable[Data[1 + I shl 2]];
    x2 := DecodeTable[Data[2 + I shl 2]];
    x3 := DecodeTable[Data[3 + I shl 2]];
    x4 := DecodeTable[Data[4 + I shl 2]];
    x1 := x1 shl 2;
    xt := x2 shr 4;
    x1 := x1 or xt;
    x2 := x2 shl 4;
    OutputData[C] := x1;
    Inc(C);
    if x3 = 64 then
      Break;
    xt := x3 shr 2;
    x2 := x2 or xt;
    x3 := x3 shl 6;
    OutputData[C] := x2;
    Inc(C);
    if x4 = 64 then
      Break;
    x3 := x3 or x4;
    OutputData[C] := x3;
    Inc(C);
  end;

  // ���ݲ��ĵȺ���Ŀ�����Ƿ�ɾ��β�� #0
  while (ToDec > 0) and (OutputData[DstLen - 1] = 0) do
  begin
    Dec(ToDec);
    Dec(DstLen);
  end;
  SetLength(OutputData, DstLen);

  // �ٸ����ⲿҪ��ɾ��β���� #0����ʵ��̫���ʵ��������
  if FixZero then
  begin
    while (DstLen > 0) and (OutputData[DstLen - 1] = 0) do
      Dec(DstLen);
    SetLength(OutputData, DstLen);
  end;

  Result := ECN_BASE64_OK;
end;

function Base64Decode(const InputData: AnsiString; var OutputData: AnsiString; FixZero: Boolean): Integer;
var
  Data: TBytes;
begin
  Result := Base64Decode(string(InputData), Data, FixZero);
  if (Result = ECN_BASE64_OK) and (Length(Data) > 0) then
  begin
    SetLength(OutputData, Length(Data));
    Move(Data[0], OutputData[1], Length(Data));
  end;
end;

end.
