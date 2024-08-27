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

unit CnMethodHook;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����󷽷��ҽӵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ�����ҽ���ķ������� CnWizMethodHook ��ֲ�������������ʹ��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2023.05.27
*               ���� Win64 �µ�֧�֣�����ȷ���Ƿ񸲸������г���ת�����
*           2018.01.12
*               �����ýӿڳ�Ա������ַ�ķ��������������� DefaultHook ����
*           2016.10.31
*               ���� Hooked ����
*           2007.11.05
*               �� CnWizMethodHook ����ֲ����
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, SysUtils, Classes;

type
  PCnLongJump = ^TCnLongJump;
  TCnLongJump = packed record
    JmpOp: Byte;        // Jmp �����תָ�Ϊ $E9��32 λ�� 64 λͨ��
{$IFDEF CPU64BITS}
    Addr: DWORD;        // 64 λ�µ���ת������Ե�ַ��Ҳ�� 32 λ������ȷ�����޸����������
{$ELSE}
    Addr: Pointer;      // ��ת������Ե�ַ
{$ENDIF}
  end;

  TCnMethodHook = class
  {* ��̬�� dynamic �����ҽ��࣬���ڹҽ����о�̬����������Ϊ dynamic �Ķ�̬������
     ����ͨ���޸�ԭ�������ǰ 5 �ֽڣ���Ϊ��תָ����ʵ�ַ����ҽӲ�������ʹ��ʱ
     �뱣֤ԭ������ִ���������� 5 �ֽڣ�������ܻ�������غ����}
  private
    FHooked: Boolean;
    FOldMethod: Pointer;
    FNewMethod: Pointer;
    FSaveData: TCnLongJump;
  public
    constructor Create(const AOldMethod, ANewMethod: Pointer; DefaultHook: Boolean = True);
    {* ������������Ϊԭ������ַ���·�����ַ��ע�������ר�Ұ���ʹ�ã�ԭ������ַ
       ���� CnGetBplMethodAddress ת������ʵ��ַ�����������ú���Զ��ҽӴ���ķ�����
     |<PRE>
       �������Ҫ�ҽ� TTest.Abc(const A: Integer) ���������Զ����·���Ϊ��
       procedure MyAbc(ASelf: TTest; const A: Integer);
       �˴� MyAbc Ϊ��ͨ���̣���Ϊ������������һ������Ϊ Self���ʴ˴�����һ��
       ASelf: TTest ������֮��ԣ�ʵ�ִ����п��԰�����������ʵ�������ʡ�
     |</PRE>}
    destructor Destroy; override;
    {* ����������ȡ���ҽ�}

    property Hooked: Boolean read FHooked;
    {* �Ƿ��ѹҽ�}
    procedure HookMethod; virtual;
    {* ���¹ҽӣ������Ҫִ��ԭ���̣���ʹ���� UnhookMethod������ִ����ɺ����¹ҽ�}
    procedure UnhookMethod; virtual;
    {* ȡ���ҽӣ������Ҫִ��ԭ���̣�����ʹ�� UnhookMethod���ٵ���ԭ���̣���������}
  end;

function CnGetBplMethodAddress(Method: Pointer): Pointer;
{* ������ BPL ��ʵ�ʵķ�����ַ����ר�Ұ����� @TPersistent.Assign ���ص���ʵ��
   һ�� Jmp ��ת��ַ���ú������Է����� BPL �з�������ʵ��ַ��}

function GetInterfaceMethodAddress(const AIntf: IUnknown;
  MethodIndex: Integer): Pointer;
{* ���� Delphi ��֧�� @AIntf.Proc �ķ�ʽ���ؽӿڵĺ�����ڵ�ַ������ Self ָ��Ҳ
   ��ƫ�����⡣���������ڷ��� AIntf �ĵ� MethodIndex ����������ڵ�ַ����������
   Self ָ���ƫ�����⡣
   MethodIndex �� 0 ��ʼ��0��1��2 �ֱ���� QueryInterface��_AddRef��_Release��
   ע�� MethodIndex �����߽��飬�����˸� Interface �ķ����������}

implementation

resourcestring
  SMemoryWriteError = 'Error Writing Method Memory (%s).';

const
  csJmpCode = $E9;              // �����תָ�������
  csJmp32Code = $25FF;          // BPL ����ڵ���ת�����룬32 λ�� 64 λͨ��

type
{$IFDEF CPU64BITS}
  TCnAddressInt = NativeInt;
{$ELSE}
  TCnAddressInt = Integer;
{$ENDIF}

// ������ BPL ��ʵ�ʵķ�����ַ
function CnGetBplMethodAddress(Method: Pointer): Pointer;
type
  PJmpCode = ^TJmpCode;
  TJmpCode = packed record
    Code: Word;                 // �����תָ����Ϊ $25FF
    Addr: ^Pointer;             // ��תָ���ַ��ָ�򱣴�Ŀ���ַ��ָ��
  end;

begin
  if PJmpCode(Method)^.Code = csJmp32Code then
    Result := PJmpCode(Method)^.Addr^
  else
    Result := Method;
end;

// ���� Interface ��ĳ��ŷ�����ʵ�ʵ�ַ�������� Self ƫ�ƣ�֧�� 32 λ�� 64 λ
function GetInterfaceMethodAddress(const AIntf: IUnknown;
  MethodIndex: Integer): Pointer;
type
  TIntfMethodEntry = packed record
    case Integer of
      0: (ByteOpCode: Byte);        // 32 λ�µ� $05 �����ֽ�
      1: (WordOpCode: Word);        // 32 λ�µ� $C083 ��һ�ֽ�
      2: (DWordOpCode: DWORD);      // 32 λ�µ� $04244483 ��һ�ֽڻ� $04244481 �����ֽڣ�
                                    // �� 64 λ�µ� $4883C1E0 ��һ�ֽ�
  end;
  PIntfMethodEntry = ^TIntfMethodEntry;

  // ������ת�����������ʵ���ϵ�ͬ�� TJmpCode �� TLongJmp ���ṹ�����
  TIntfJumpEntry = packed record
    case Integer of
      0: (ByteOpCode: Byte; Offset: LongInt);       // $E9 �����ֽڣ�32 λ�� 64 λͨ��
      1: (WordOpCode: Word; Addr: ^Pointer);        // $25FF �����ֽ�
  end;
  PIntfJumpEntry = ^TIntfJumpEntry;
  PPointer = ^Pointer;

var
  OffsetStubPtr: Pointer;
  IntfPtr: PIntfMethodEntry;
  JmpPtr: PIntfJumpEntry;
begin
  Result := nil;
  if (AIntf = nil) or (MethodIndex < 0) then
    Exit;

  OffsetStubPtr := PPointer(TCnAddressInt(PPointer(AIntf)^) + SizeOf(Pointer) * MethodIndex)^;

  // �õ��� interface ��Ա������ת��ڣ�����ڻ����� Self ָ��������������
  // 32 λ�£�IUnknown �����׼������ھ��� add dword ptr [esp+$04],-$xx ��xx Ϊ ShortInt �� LongInt������Ϊ�� stdcall
  // stdcall/safecall/cdecl �Ĵ���Ϊ $04244483 ��һ�ֽڵ� ShortInt���� $04244481 �����ֽڵ� LongInt
  // ���������������÷�ʽ���п�����Ĭ�� register �� add eax -$xx ��xx Ϊ ShortInt �� LongInt��
  // stdcall/safecall/cdecl �Ĵ���Ϊ $C083 ��һ�ֽڵ� ShortInt���� $05 �����ֽڵ� LongInt
  // pascal ��������ջ��ʽ�����ƺ��Ժ� stdcall ��һ��
  // Win64 �£�������ھ��� add ecx, -$20��֮���� Jump
  IntfPtr := PIntfMethodEntry(OffsetStubPtr);

  JmpPtr := nil;

{$IFDEF CPU64BITS}
  // 64 λ��ת�ƺ�����һ��
  if IntfPtr^.DWordOpCode = $E0C18348 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 4);
{$ELSE}
  if IntfPtr^.ByteOpCode = $05 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 1 + 4)
  else if IntfPtr^.DWordOpCode = $04244481 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 4 + 4)
  else if IntfPtr^.WordOpCode = $C083 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 2 + 1)
  else if IntfPtr^.DWordOpCode = $04244483 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 4 + 1);
{$ENDIF}

  if JmpPtr <> nil then
  begin
    // Ҫ���ָ��ֲ�ͬ����ת�������� E9 �����ֽ����ƫ�ƣ�32 λ�� 64 λͨ�ã����Լ� 25FF �����ֽھ��Ե�ַ�ĵ�ַ
    if JmpPtr^.ByteOpCode = csJmpCode then
    begin
      Result := Pointer(TCnAddressInt(JmpPtr) + JmpPtr^.Offset + 5); // 5 ��ʾ Jmp ָ��ĳ���
    end
    else if JmpPtr^.WordOpCode = csJmp32Code then
    begin
      Result := JmpPtr^.Addr^;
    end;
  end;
end;

//==============================================================================
// ��̬�� dynamic �����ҽ���
//==============================================================================

{ TCnMethodHook }

constructor TCnMethodHook.Create(const AOldMethod, ANewMethod: Pointer;
  DefaultHook: Boolean);
begin
  inherited Create;
  FHooked := False;
  FOldMethod := AOldMethod;
  FNewMethod := ANewMethod;

  if DefaultHook then
    HookMethod;
end;

destructor TCnMethodHook.Destroy;
begin
  UnHookMethod;
  inherited;
end;

procedure TCnMethodHook.HookMethod;
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
begin
  if FHooked then Exit;
  
  // ���ô���ҳд����Ȩ��
  if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump), PAGE_EXECUTE_READWRITE, @OldProtection) then
    raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

  try
    // ����ԭ���Ĵ���
    FSaveData := PCnLongJump(FOldMethod)^;

    // ����תָ���滻ԭ������ǰ 5 �ֽڴ���
    PCnLongJump(FOldMethod)^.JmpOp := csJmpCode;
{$IFDEF CPU64BITS}
    PCnLongJump(FOldMethod)^.Addr := DWORD(TCnAddressInt(FNewMethod) -
      TCnAddressInt(FOldMethod) - SizeOf(TCnLongJump)); // 64 ��Ҳʹ�� 32 λ��Ե�ַ
{$ELSE}
    PCnLongJump(FOldMethod)^.Addr := Pointer(TCnAddressInt(FNewMethod) -
      TCnAddressInt(FOldMethod) - SizeOf(TCnLongJump)); // ʹ�� 32 λ��Ե�ַ
{$ENDIF}

    // ����ദ������ָ�����ͬ��
    FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TCnLongJump));
  finally
    // �ָ�����ҳ����Ȩ��
    if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump), OldProtection, @DummyProtection) then
      raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
  end;

  FHooked := True;
end;

procedure TCnMethodHook.UnhookMethod;
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
begin
  if not FHooked then Exit;
  
  // ���ô���ҳд����Ȩ��
  if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump), PAGE_READWRITE, @OldProtection) then
    raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

  try
    // �ָ�ԭ���Ĵ���
    PCnLongJump(FOldMethod)^ := FSaveData;
  finally
    // �ָ�����ҳ����Ȩ��
    if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump), OldProtection, @DummyProtection) then
      raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
  end;

  // ����ദ������ָ�����ͬ��
  FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TCnLongJump));

  FHooked := False;
end;

end.
