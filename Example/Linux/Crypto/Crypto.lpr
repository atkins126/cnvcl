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

program Crypto;

{$MODE Delphi}

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils, Interfaces,
  Cn25519 in '..\..\..\Source\Crypto\Cn25519.pas',
  CnAEAD in '..\..\..\Source\Crypto\CnAEAD.pas',
  CnAES in '..\..\..\Source\Crypto\CnAES.pas',
  CnBase64 in '..\..\..\Source\Crypto\CnBase64.pas',
  CnBerUtils in '..\..\..\Source\Crypto\CnBerUtils.pas',
  CnBigNumber in '..\..\..\Source\Crypto\CnBigNumber.pas',
  CnCertificateAuthority in '..\..\..\Source\Crypto\CnCertificateAuthority.pas',
  CnChaCha20 in '..\..\..\Source\Crypto\CnChaCha20.pas',
  CnComplex in '..\..\..\Source\Crypto\CnComplex.pas',
  CnCRC32 in '..\..\..\Source\Crypto\CnCRC32.pas',
  CnDES in '..\..\..\Source\Crypto\CnDES.pas',
  CnDFT in '..\..\..\Source\Crypto\CnDFT.pas',
  CnDSA in '..\..\..\Source\Crypto\CnDSA.pas',
  CnECC in '..\..\..\Source\Crypto\CnECC.pas',
  CnFEC in '..\..\..\Source\Crypto\CnFEC.pas',
  CnFNV in '..\..\..\Source\Crypto\CnFNV.pas',
  CnInt128 in '..\..\..\Source\Crypto\CnInt128.pas',
  CnKDF in '..\..\..\Source\Crypto\CnKDF.pas',
  CnMD5 in '..\..\..\Source\Crypto\CnMD5.pas',
  CnNative in '..\..\..\Source\Crypto\CnNative.pas',
  CnOTP in '..\..\..\Source\Crypto\CnOTP.pas',
  CnPaillier in '..\..\..\Source\Crypto\CnPaillier.pas',
  CnPemUtils in '..\..\..\Source\Crypto\CnPemUtils.pas',
  CnPoly1305 in '..\..\..\Source\Crypto\CnPoly1305.pas',
  CnPolynomial in '..\..\..\Source\Crypto\CnPolynomial.pas',
  CnPrimeNumber in '..\..\..\Source\Crypto\CnPrimeNumber.pas',
  CnRandom in '..\..\..\Source\Crypto\CnRandom.pas',
  CnRSA in '..\..\..\Source\Crypto\CnRSA.pas',
  CnSecretSharing in '..\..\..\Source\Crypto\CnSecretSharing.pas',
  CnSHA1 in '..\..\..\Source\Crypto\CnSHA1.pas',
  CnSHA2 in '..\..\..\Source\Crypto\CnSHA2.pas',
  CnSHA3 in '..\..\..\Source\Crypto\CnSHA3.pas',
  CnSM2 in '..\..\..\Source\Crypto\CnSM2.pas',
  CnSM3 in '..\..\..\Source\Crypto\CnSM3.pas',
  CnSM4 in '..\..\..\Source\Crypto\CnSM4.pas',
  CnSM9 in '..\..\..\Source\Crypto\CnSM9.pas',
  CnTEA in '..\..\..\Source\Crypto\CnTEA.pas',
  CnZUC in '..\..\..\Source\Crypto\CnZUC.pas',
  CryptoTest in 'CryptoTest.pas';

begin
  try
    TestCrypto;
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
