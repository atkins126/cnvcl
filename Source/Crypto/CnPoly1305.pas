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

unit CnPoly1305;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�Poly1305 ��Ϣ��֤�㷨ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org)
* ��    ע������ RFC 7539 ʵ��
*           ����Ϊ���ⳤ�������� 32 �ֽ���Կ����� 16 �ֽ��Ӵ�ֵ
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
  Classes, SysUtils, CnNative, CnBigNumber;

const
  CN_POLY1305_KEYSIZE   = 32;
  {* Poly1305 �㷨�����볤�ȣ����� 32 �ֽ�Ҳ���� 256 λ�� Key}

  CN_POLY1305_BLOCKSIZE = 16;
  {* Poly1305 �㷨���ڲ��ֿ鳤�ȣ�ÿ�� 16 �ֽ�}

  CN_POLY1305_DIGSIZE   = 16;
  {* Poly1305 �㷨��ժҪ������ȣ�16 �ֽ�Ҳ���� 128 λ}

type
  TCnPoly1305Key = array[0..CN_POLY1305_KEYSIZE - 1] of Byte;
  {* Poly1305 �㷨�� Key}

  TCnPoly1305Digest = array[0..CN_POLY1305_DIGSIZE - 1] of Byte;
  {* Poly1305 �㷨���Ӵս��}

function Poly1305Bytes(Data: TBytes; Key: TBytes): TCnPoly1305Digest;
{* �����ֽ������ Poly1305 �Ӵ�ֵ}

function Poly1305Data(Data: Pointer; DataByteLength: Integer;
  Key: TCnPoly1305Key): TCnPoly1305Digest;
{* �������ݿ�� Poly1305 �Ӵ�ֵ}

function Poly1305Print(const Digest: TCnPoly1305Digest): string;
{* ��ʮ�����Ƹ�ʽ��� Poly1305 ����ֵ}

implementation

var
  Prime: TCnBigNumber = nil; // Poly1305 ʹ�õ�����
  Clamp: TCnBigNumber = nil; // Poly1305 ʹ�õ� Clamp

function Poly1305Bytes(Data: TBytes; Key: TBytes): TCnPoly1305Digest;
var
  AKey: TCnPoly1305Key;
  L: Integer;
begin
  FillChar(AKey[0], SizeOf(TCnPoly1305Key), 0);
  L := Length(Key);
  if L > SizeOf(TCnPoly1305Key) then
    L := SizeOf(TCnPoly1305Key);

  Move(Key[0], AKey[0], L);
  Result := Poly1305Data(@Data[0], Length(Data), AKey);
end;

function Poly1305Data(Data: Pointer; DataByteLength: Integer;
  Key: TCnPoly1305Key): TCnPoly1305Digest;
var
  I, B, L: Integer;
  R, S, A, N: TCnBigNumber;
  Buf: array[0..CN_POLY1305_BLOCKSIZE] of Byte;
  P: PByteArray;
  RKey: TCnPoly1305Key;
begin
  Move(Key[0], RKey[0], SizeOf(TCnPoly1305Key));
  ReverseMemory(@RKey[0], CN_POLY1305_BLOCKSIZE);
  ReverseMemory(@RKey[CN_POLY1305_BLOCKSIZE], CN_POLY1305_BLOCKSIZE);

  R := nil;
  S := nil;
  A := nil;
  N := nil;

  try
    R := TCnBigNumber.FromBinary(@RKey[0], CN_POLY1305_BLOCKSIZE);
    BigNumberAnd(R, R, Clamp);

    S := TCnBigNumber.FromBinary(@RKey[CN_POLY1305_BLOCKSIZE], CN_POLY1305_BLOCKSIZE);

    A := TCnBigNumber.Create;
    A.SetZero;

    N := TCnBigNumber.Create;

    B := (DataByteLength + CN_POLY1305_BLOCKSIZE - 1) div CN_POLY1305_BLOCKSIZE;
    P := PByteArray(Data);

    for I := 1 to B do
    begin
      if I <> B then // ��ͨ�飬16 �ֽ�����
        L := CN_POLY1305_BLOCKSIZE
      else           // β�飬���ܲ��� 16 �ֽ�
        L := DataByteLength mod CN_POLY1305_BLOCKSIZE;

      Move(P^[(I - 1) * CN_POLY1305_BLOCKSIZE], Buf[0], L);  // ��������
      Buf[L] := 1;                                        // ���ֽ����ø� 1

      ReverseMemory(@Buf[0], L + 1);
      N.SetBinary(@Buf[0], L + 1);

      BigNumberAdd(A, A, N);
      BigNumberDirectMulMod(A, R, A, Prime);
    end;

    BigNumberAdd(A, A, S);
    BigNumberKeepLowBits(A, 8 * CN_POLY1305_DIGSIZE);

    A.ToBinary(@Result[0], CN_POLY1305_DIGSIZE);
    ReverseMemory(@Result[0], SizeOf(TCnPoly1305Digest));
  finally
    N.Free;
    A.Free;
    S.Free;
    R.Free;
  end;
end;

function Poly1305Print(const Digest: TCnPoly1305Digest): string;
begin
  Result := DataToHex(@Digest[0], SizeOf(TCnPoly1305Digest));
end;

initialization
  Prime := TCnBigNumber.Create;
  Prime.SetOne;
  Prime.ShiftLeft(130);
  Prime.SubWord(5);

  Clamp := TCnBigNumber.FromHex('0FFFFFFC0FFFFFFC0FFFFFFC0FFFFFFF');

finalization
  Clamp.Free;
  Prime.Free;

end.
