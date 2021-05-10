{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
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

unit CnKDF;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����������㷨��KDF����Ԫ
* ��Ԫ���ߣ���Х
* ��    ע������ RFC2898 �� PBKDF1 �� PBKDF2 ʵ�֣��� PBKDF1 ��֧�� MD2
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.03.30 V1.0
*               ������Ԫ���� CnPemUtils �ж�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnMD5, CnSHA1, CnSHA2, CnSM3;

type
  TCnKeyDeriveHash = (ckdMd5, ckdSha256, ckdSha1);

  TCnPBKDF1KeyHash = (cpdfMd2, cpdfMd5, cpdfSha1);

  TCnPBKDF2KeyHash = (cpdfSha1Hmac, cpdfSha256Hmac);

  ECnKDFException = class(Exception);

function CnGetDeriveKey(const Password, Salt: AnsiString; OutKey: PAnsiChar; KeyLength: Cardinal;
  KeyHash: TCnKeyDeriveHash = ckdMd5): Boolean;
{* ������ Openssl �е� BytesToKey�������������ָ���� Hash �㷨���ɼ��� Key��
  Ŀǰ�������� KeyLength ���֧������ Hash��Ҳ���� MD5 32 �ֽڣ�SHA256 64 �ֽ�}

function CnPBKDF1(const Password, Salt: AnsiString; Count, DerivedKeyLength: Integer;
  KeyHash: TCnPBKDF1KeyHash = cpdfMd5): AnsiString;
{* Password Based KDF 1 ʵ�֣��򵥵Ĺ̶� Hash ������ֻ֧�� MD5 �� SHA1��
   DerivedKeyLength ���������Կ�ֽ��������ȹ̶�}

function CnPBKDF2(const Password, Salt: AnsiString; Count, DerivedKeyLength: Integer;
  KeyHash: TCnPBKDF2KeyHash = cpdfSha1Hmac): AnsiString;
{* Password Based KDF 2 ʵ�֣����� HMAC-SHA1 �� HMAC-SHA256��
   DerivedKeyLength ���������Կ�ֽ��������ȿɱ䣬������}

function CnSM2KDF(const Data: AnsiString; DerivedKeyLength: Integer): AnsiString;
{* SM2 ��Բ���߹�Կ�����㷨�й涨����Կ����������DerivedKeyLength ���������Կ�ֽ���}

implementation

resourcestring
  SCnKDFErrorTooLong = 'Derived Key Too Long.';
  SCnKDFErrorParam = 'Invalid Parameters.';
  SCnKDFHashNOTSupport = 'Hash Method NOT Support.';

function Min(A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function CnGetDeriveKey(const Password, Salt: AnsiString; OutKey: PAnsiChar; KeyLength: Cardinal;
  KeyHash: TCnKeyDeriveHash): Boolean;
var
  Md5Dig, Md5Dig2: TMD5Digest;
  Sha256Dig, Sha256Dig2: TSHA256Digest;
  SaltBuf, PS, PSMD5, PSSHA256: AnsiString;
begin
  Result := False;

  if (Password = '') or (OutKey = nil) or (KeyLength < 8) then
    Exit;

  SetLength(SaltBuf, 8);
  FillChar(SaltBuf[1], Length(SaltBuf), 0);
  if Salt <> '' then
    Move(Salt[1], SaltBuf[1], Min(Length(Salt), 8));

  if not (KeyHash in [ckdMd5, ckdSha256]) then
    raise ECnKDFException.Create(SCnKDFHashNOTSupport);

  PS := AnsiString(Password) + SaltBuf; // �涨ǰ 8 ���ֽ���Ϊ Salt
  if KeyHash = ckdMd5 then
  begin
    SetLength(PSMD5, SizeOf(TMD5Digest) + Length(PS));
    Move(PS[1], PSMD5[SizeOf(TMD5Digest) + 1], Length(PS));
    Md5Dig := MD5StringA(PS);
    // ������ Salt ƴ������ MD5 �����16 Byte����Ϊ��һ����

    Move(Md5Dig[0], OutKey^, Min(KeyLength, SizeOf(TMD5Digest)));
    if KeyLength <= SizeOf(TMD5Digest) then
    begin
      Result := True;
      Exit;
    end;

    KeyLength := KeyLength - SizeOf(TMD5Digest);
    OutKey := PAnsiChar(Integer(OutKey) + SizeOf(TMD5Digest));

    Move(Md5Dig[0], PSMD5[1], SizeOf(TMD5Digest));
    Md5Dig2 := MD5StringA(PSMD5);
    Move(Md5Dig2[0], OutKey^, Min(KeyLength, SizeOf(TMD5Digest)));
    if KeyLength <= SizeOf(TMD5Digest) then
      Result := True;

    // ���� KeyLength ̫�����㲻��
  end
  else if KeyHash = ckdSha256 then
  begin
    SetLength(PSSHA256, SizeOf(TSHA256Digest) + Length(PS));
    Move(PS[1], PSSHA256[SizeOf(TSHA256Digest) + 1], Length(PS));
    Sha256Dig := SHA256StringA(PS);
    // ������ Salt ƴ������ SHA256 �����32 Byte����Ϊ��һ����

    Move(Sha256Dig[0], OutKey^, Min(KeyLength, SizeOf(TSHA256Digest)));
    if KeyLength <= SizeOf(TSHA256Digest) then
    begin
      Result := True;
      Exit;
    end;

    KeyLength := KeyLength - SizeOf(TSHA256Digest);
    OutKey := PAnsiChar(Integer(OutKey) + SizeOf(TSHA256Digest));

    Move(Sha256Dig[0], PSSHA256[1], SizeOf(TSHA256Digest));
    Sha256Dig2 := SHA256StringA(PSSHA256);
    Move(Sha256Dig2[0], OutKey^, Min(KeyLength, SizeOf(TSHA256Digest)));
    if KeyLength <= SizeOf(TSHA256Digest) then
      Result := True;

    // ���� KeyLength ̫�����㲻��
  end;
end;

(*
  T_1 = Hash (P || S) ,
  T_2 = Hash (T_1) ,
  ...
  T_c = Hash (T_{c-1}) ,
  DK = Tc<0..dkLen-1>
*)
function CnPBKDF1(const Password, Salt: AnsiString; Count, DerivedKeyLength: Integer;
  KeyHash: TCnPBKDF1KeyHash): AnsiString;
var
  I: Integer;
  Md5Dig, TM: TMD5Digest;
  Sha1Dig, TS: TSHA1Digest;
  Ptr: PAnsiChar;
begin
  if (Password = '') or (Count <= 0) or (DerivedKeyLength <= 0) then
    raise ECnKDFException.Create(SCnKDFErrorParam);

  case KeyHash of
    cpdfMd5:
      begin
        if DerivedKeyLength > SizeOf(TMD5Digest) then
          raise ECnKDFException.Create(SCnKDFErrorTooLong);

        SetLength(Result, DerivedKeyLength);
        Md5Dig := MD5StringA(Password + Salt);  // Got T1
        if Count > 1 then
        begin
          Ptr := PAnsiChar(@TM[0]);
          for I := 2 to Count do
          begin
            TM := Md5Dig;
            Md5Dig := MD5Buffer(Ptr, SizeOf(TMD5Digest)); // Got T_c
          end;
        end;

        Move(Md5Dig[0], Result[1], DerivedKeyLength);
      end;
    cpdfSha1:
      begin
        if DerivedKeyLength > SizeOf(TSHA1Digest) then
          raise ECnKDFException.Create(SCnKDFErrorTooLong);

        SetLength(Result, DerivedKeyLength);
        Sha1Dig := SHA1StringA(Password + Salt);  // Got T1
        if Count > 1 then
        begin
          Ptr := PAnsiChar(@TS[0]);
          for I := 2 to Count do
          begin
            TS := Sha1Dig;
            Sha1Dig := SHA1Buffer(Ptr, SizeOf(TSHA1Digest)); // Got T_c
          end;
        end;

        Move(Sha1Dig[0], Result[1], DerivedKeyLength);
      end;
    else
      raise ECnKDFException.Create(SCnKDFHashNOTSupport);
  end;
end;

{
  DK = T1 + T2 + ... + Tdklen/hlen
  Ti = F(Password, Salt, c, i)

  F(Password, Salt, c, i) = U1 ^ U2 ^ ... ^ Uc

  U1 = PRF(Password, Salt + INT_32_BE(i))
  U2 = PRF(Password, U1)
  ...
  Uc = PRF(Password, Uc-1)
}
function CnPBKDF2(const Password, Salt: AnsiString; Count, DerivedKeyLength: Integer;
  KeyHash: TCnPBKDF2KeyHash): AnsiString;
var
  HLen, D, I, J, K: Integer;
  Sha1Dig1, Sha1Dig, T1: TSHA1Digest;
  Sha256Dig1, Sha256Dig, T256: TSHA256Digest;
  S, S1, S256: AnsiString;
begin
  Result := '';
  if (Password = '') or (Salt = '') or (Count <= 0) or (DerivedKeyLength <=0) then
    raise ECnKDFException.Create(SCnKDFErrorParam);

  case KeyHash of
    cpdfSha1Hmac:
      HLen := 20;
    cpdfSha256Hmac:
      HLen := 32;
  else
    raise ECnKDFException.Create(SCnKDFErrorParam);
  end;

  D := (DerivedKeyLength div HLen) + 1;
  SetLength(S1, SizeOf(TSHA1Digest));
  SetLength(S256, SizeOf(TSHA256Digest));

  if KeyHash = cpdfSha1Hmac then
  begin
    for I := 1 to D do
    begin
      S := Salt + Chr(I shr 24) + Chr(I shr 16) + Chr(I shr 8) + Chr(I);
      SHA1Hmac(PAnsiChar(Password), Length(Password), PAnsiChar(S), Length(S), Sha1Dig1);
      T1 := Sha1Dig1;

      for J := 2 to Count do
      begin
        SHA1Hmac(PAnsiChar(Password), Length(Password), PAnsiChar(@T1[0]), SizeOf(TSHA1Digest), Sha1Dig);
        T1 := Sha1Dig;
        for K := Low(TSHA1Digest) to High(TSHA1Digest) do
          Sha1Dig1[K] := Sha1Dig1[K] xor T1[K];
      end;

      Move(Sha1Dig1[0], S1[1], SizeOf(TSHA1Digest));
      Result := Result + S1;
    end;
    Result := Copy(Result, 1, DerivedKeyLength);
  end
  else if KeyHash = cpdfSha256Hmac then
  begin
    for I := 1 to D do
    begin
      S := Salt + Chr(I shr 24) + Chr(I shr 16) + Chr(I shr 8) + Chr(I);
      SHA256Hmac(PAnsiChar(Password), Length(Password), PAnsiChar(S), Length(S), Sha256Dig1);
      T256 := Sha256Dig1;

      for J := 2 to Count do
      begin
        SHA256Hmac(PAnsiChar(Password), Length(Password), PAnsiChar(@T256[0]), SizeOf(TSHA256Digest), Sha256Dig);
        T256 := Sha256Dig;
        for K := Low(TSHA256Digest) to High(TSHA256Digest) do
          Sha256Dig1[K] := Sha256Dig1[K] xor T1[K];
      end;

      Move(Sha256Dig1[0], S256[1], SizeOf(TSHA256Digest));
      Result := Result + S256;
    end;
    Result := Copy(Result, 1, DerivedKeyLength);
  end;
end;

function CnSM2KDF(const Data: AnsiString; DerivedKeyLength: Integer): AnsiString;
var
  S, SDig: AnsiString;
  I, D: Integer;
  Dig: TSM3Digest;
begin
  Result := '';
  if (Data = '') or (DerivedKeyLength <= 0) then
    raise ECnKDFException.Create(SCnKDFErrorParam);

  SetLength(SDig, SizeOf(TSM3Digest));
  D := DerivedKeyLength div SizeOf(TSM3Digest) + 1;
  for I := 1 to D do
  begin
    S := Data + Chr(I shr 24) + Chr(I shr 16) + Chr(I shr 8) + Chr(I);
    Dig := SM3StringA(S);
    Move(Dig[0], SDig[1], SizeOf(TSM3Digest));
    Result := Result + SDig;
  end;
  Result := Copy(Result, 1, DerivedKeyLength);
end;

end.
