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

unit CnCallBack;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����
* ��Ԫ���ƣ��ص�ת���Ĺ��ߵ�Ԫ����֧�� 64 λ
* ��Ԫ���ߣ�CnPack ������ savetime (savetime2k@yahoo.com)
*           CnPack ������ (master@cnpack.org)
* ��    ע���õ�Ԫ�ǻص�ת���ȵĴ��뵥Ԫ
*           ��װ�Ĵ��벿�������з���Ŀ�ִ�е��ڴ�ռ䣬������ DEP �³���
* ����ƽ̨��PWin2000 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.09.25 V1.0
*               ���� 32 λʵ�� 64 λ���� 64 λ��û�� stdcall��ֻ�� fastcall���������֮��������֮
*           2006.10.13 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

//{$IFDEF CPUX64}
//  {$MESSAGE ERROR 'NO stdcall in x64!!!'}
//{$ENDIF}

uses
  Classes, Windows, SysUtils, CnNative;

{$IFDEF WIN32}

type
  ECnCallBackException = class(Exception);

function StdcallMethodToCallBack(ASelf: Pointer; AMethodAddr: Pointer): Pointer;
{* �� stdcall �����Ա������ʵ�����԰�װ������һ���µ� stdcall �Ļص�������ַ }

{* ʹ���﷨:
  @AStdCallbackFunc := StdcallMethodToCallBack(AObject, @TAObject.CallbackMethod);
  ���� AStdCallbackFunc �� CallbackMethod ������ʹ�� stdcall ������
}

{$ENDIF}

implementation

{$IFDEF WIN32}

type
{$IFDEF CPUX64}
  TCnCallback = array [1..28] of Byte; // �� 64 λ�����������
{$ELSE}
  TCnCallback = array [1..18] of Byte; // �� 32 λ�����������
{$ENDIF}
  PCnCallback = ^TCnCallback;

const
  THUNK_SIZE = 4096; // x86 ҳ��С��ĿǰֻŪһ��ҳ��

{$IFDEF CPUX64}

  StdcallCode: TCnCallback =
    ($48,$8B,$04,$24,$50,$48,$B8,$00,$00,$00,$00,$00,$00,$00,$00,$89,$44,$24,$08,$E9,$00,$00,$00,$00,$00,$00,$00,$00);

  {----------------------------}
  { Stdcall CallbackCode ASM   }
  {----------------------------}
  {    MOV RAX, [RSP];         }
  {    PUSH RAX;               }
  {    MOV RAX, ASelf;         }  // ASelf �� 1 ����� 8 �������� 8 �ֽ�
  {    MOV [RSP+8], RAX;       }
  {    JMP AMethodAddr;        }  // AMethodAddr �� 1 ����� 21 �������� 8 �ֽ�
  {----------------------------}

{$ELSE}

  StdcallCode: TCnCallback =
    ($8B,$04,$24,$50,$B8,$00,$00,$00,$00,$89,$44,$24,$04,$E9,$00,$00,$00,$00);

  {----------------------------}
  { Stdcall CallbackCode ASM   }
  {----------------------------}
  {    MOV EAX, [ESP];         }
  {    PUSH EAX;               }
  {    MOV EAX, ASelf;         }  // ASelf �� 1 ����� 6 �������� 4 �ֽ�
  {    MOV [ESP+4], EAX;       }
  {    JMP AMethodAddr;        }  // AMethodAddr �� 1 ����� 15 �������� 4 �ֽ�
  {----------------------------}

{$ENDIF}

var
  FCallBackPool: Pointer = nil;
  FEmptyPtr: Integer = 0;
  FCS: TRTLCriticalSection;

procedure InitCallBackPool;
begin
  FCallBackPool := VirtualAlloc(nil, THUNK_SIZE, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if FCallBackPool = nil then
    raise ECnCallBackException.Create('Callback Pool Init Error!');
end;

function StdcallMethodToCallBack(ASelf: Pointer; AMethodAddr: Pointer): Pointer;
var
  Instance: PCnCallback;
begin
  Result := nil;
  Instance := nil;

  try
    EnterCriticalSection(FCS);

    if FCallBackPool = nil then
    begin
      InitCallBackPool;
      Instance := FCallBackPool;
    end
    else
    begin
      if FEmptyPtr = (THUNK_SIZE div SizeOf(TCnCallback)) then
        raise ECnCallBackException.Create('Callback Pool Overflow!');

      Inc(FEmptyPtr);
      Instance := PCnCallback(TCnNativeInt(FCallBackPool) + FEmptyPtr * SizeOf(TCnCallback));
    end;
  finally
    LeaveCriticalSection(FCS);
  end;

  if Instance <> nil then
  begin
    Move(StdcallCode, Instance^, SizeOf(TCnCallback));
{$IFDEF CPUX64}
    TCnNativeIntPtr(@(Instance^[8]))^ := TCnNativePointer(ASelf);
    TCnNativeIntPtr(@(Instance^[21]))^ := TCnNativePointer(TCnNativePointer(AMethodAddr) - TCnNativePointer(Instance) - 22);
{$ELSE}
    TCnNativeIntPtr(@(Instance^[6]))^ := TCnNativePointer(ASelf);
    TCnNativeIntPtr(@(Instance^[15]))^ := TCnNativePointer(TCnNativePointer(AMethodAddr) - TCnNativePointer(Instance) - 18);
{$ENDIF}
    Result := Instance;
  end;
end;

initialization
  InitializeCriticalSection(FCS);

finalization
  DeleteCriticalSection(FCS);
  if FCallBackPool <> nil then
    VirtualFree(FCallBackPool, 0, MEM_RELEASE);

{$ENDIF}
end.
