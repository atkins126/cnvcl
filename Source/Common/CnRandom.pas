{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
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

unit CnRandom;
{* |<PRE>
================================================================================
* �������ƣ�������������
* ��Ԫ���ƣ��������䵥Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.03.27 V1.0
*               ������Ԫ���� CnPrimeNumber �ж�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils {$IFDEF MSWINDOWS}, Windows {$ENDIF},  Classes;

type
  ECnRandomAPIError = class(Exception);

function CnRandomFillBytes(Buf: PAnsiChar; Len: Integer): Boolean;
{* ʹ�� Windows API �� /dev/random �豸ʵ������������}

implementation

{$IFDEF MSWINDOWS}

const
  ADVAPI32 = 'advapi32.dll';

  CRYPT_VERIFYCONTEXT = $F0000000;
  CRYPT_NEWKEYSET = $8;
  CRYPT_DELETEKEYSET = $10;

  PROV_RSA_FULL = 1;
  NTE_BAD_KEYSET = $80090016;

function CryptAcquireContext(phProv: PULONG; pszContainer: PAnsiChar;
  pszProvider: PAnsiChar; dwProvType: LongWord; dwFlags: LongWord): BOOL;
  stdcall; external ADVAPI32 name 'CryptAcquireContextA';

function CryptReleaseContext(hProv: ULONG; dwFlags: LongWord): BOOL;
  stdcall; external ADVAPI32 name 'CryptReleaseContext';

function CryptGenRandom(hProv: ULONG; dwLen: LongWord; pbBuffer: PAnsiChar): BOOL;
  stdcall; external ADVAPI32 name 'CryptGenRandom';

{$ENDIF}

function CnRandomFillBytes(Buf: PAnsiChar; Len: Integer): Boolean;
var
{$IFDEF MSWINDOWS}
  HProv: THandle;
  Res: LongWord;
{$ELSE}
  F: TFileStream;
{$ENDIF}
begin
  Result := False;
{$IFDEF MSWINDOWS}
  // ʹ�� Windows API ʵ������������
  HProv := 0;
  if not CryptAcquireContext(@HProv, nil, nil, PROV_RSA_FULL, 0) then
  begin
    Res := GetLastError;
    if Res = NTE_BAD_KEYSET then // KeyContainer �����ڣ����½��ķ�ʽ
    begin
      if not CryptAcquireContext(@HProv, nil, nil, PROV_RSA_FULL, CRYPT_NEWKEYSET) then
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext NewKeySet $%8.8x', [GetLastError]);
    end
    else
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext $%8.8x', [Res]);
  end;

  if HProv <> 0 then
  begin
    try
      Result := CryptGenRandom(HProv, Len, Buf);
      if not Result then
        raise ECnRandomAPIError.CreateFmt('Error CryptGenRandom $%8.8x', [GetLastError]);
    finally
      CryptReleaseContext(HProv, 0);
    end;
  end;
{$ELSE}
  // MacOS �µ�������ʵ�֣����ö�ȡ /dev/random ���ݵķ�ʽ
  F := nil;
  try
    F := TFileStream.Create('/dev/random', fmOpenRead);
    Result := F.Read(Buf^, Len) = Len;
  finally
    F.Free;
  end;
{$ENDIF}
end;

end.