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

unit CnRtlUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnDebugger
* ��Ԫ���ƣ�CnDebug ��ص������ڹ��ߵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org��
* ��    ע���õ�Ԫʵ���˲��� CnDebugger ����� Module/Stack �������
*           �������������� JCL
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�Win32/Win64
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2020.05.08
*               ʵ�� Delphi ģ����쳣�ҽӣ����� raise �� OS �쳣���֣�����֧�� 32/64��
*           ץ��ǰ���ö�ջ           ץ�������쳣             ץ OS �쳣
* ʵ����    TCnCurrentStackInfoList  TCnCurrentStackInfoList  TCnExceptionStackInfoList
* 32 λ     RtlCaptureStackTrace     RtlCaptureStackTrace     �� AddVectoredExceptionHandler �� Context���� StackWalk64
* 64 λ     RtlCaptureStackTrace     RtlCaptureStackTrace     �� AddVectoredExceptionHandler �� Context���� StackWalk64 �Ľ���ƺ�Ҳ���ԡ�
*           2020.05.05
*               ʵ�ֵ�ǰ exe �ڸ�д IAT �ķ�ʽ Hook API��ͬʱ֧�� 32/64��
*               ��ģ���ڵ� OriginalFirstThunk ��Чʱ���ݺ����������� IAT
*               ��ģ���ڵ� OriginalFirstThunk Ϊ 0 ʱֱ���õ�ַ������ IAT
*           2020.05.04
*               ʵ�ֵ�ǰ��ջ�����ֵ��õ�ַ׷��ʵ�֣�ͬʱ֧�� 32/64��
*               ���� 64 λ�µ��� StackWalk64 ������
*           2020.04.26
*               ������Ԫ,ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, Contnrs, TLHelp32, Psapi, Imagehlp;

type
  TCnModuleInfo = class(TObject)
  {* ����һ��ģ����Ϣ��exe �� dll �� bpl �ȣ�֧�� 32/64 λ}
  private
    FSize: Cardinal;
    FStartAddr: Pointer;
    FEndAddr: Pointer;
    FBaseName: string;
    FFullName: string;
    FIsDelphi: Boolean;
    FHModule: HMODULE;
  public
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}

    property BaseName: string read FBaseName write FBaseName;
    {* ģ���ļ���}
    property FullName: string read FFullName write FFullName;
    {* ģ������·����}
    property Size: Cardinal read FSize write FSize;
    {* ģ���С}
    property HModule: HMODULE read FHModule write FHModule;
    {* ģ�� Handle��Ҳ���� AllocationBase��һ����� StartAddr}
    property StartAddr: Pointer read FStartAddr write FStartAddr;
    {* ģ���ڱ����̵�ַ�ռ����ʼ��ַ��Ҳ�� lpBaseOfDll}
    property EndAddr: Pointer read FEndAddr write FEndAddr;
    {* ģ���ڱ����̵�ַ�ռ�Ľ�����ַ}
    property IsDelphi: Boolean read FIsDelphi write FIsDelphi;
    {* �Ƿ��� Delphi ģ�飬ָͨ�� System.pas �е� LibModuleList ע�����}
  end;

  TCnModuleInfoList = class(TObjectList)
  {* �����������ڵ�����ģ����Ϣ��exe �� dll �� bpl �ȣ�֧�� 32/64 λ}
  private
    FDelphiOnly: Boolean;
    function GetItems(Index: Integer): TCnModuleInfo;
    function GetModuleFromAddress(Addr: Pointer): TCnModuleInfo;
    function AddModule(PH: THandle; MH: HMODULE): TCnModuleInfo;
    procedure CheckDelphiModule(Info: TCnModuleInfo);
  protected
    procedure BuildModulesList;
    function CreateItemForAddress(Addr: Pointer; AIsDelphi: Boolean): TCnModuleInfo;
  public
    constructor Create(ADelphiOnly: Boolean = False); virtual;
    destructor Destroy; override;

    procedure DumpToStrings(List: TStrings);

    function IsValidModuleAddress(Addr: Pointer): Boolean;
    {* �ж�ĳ��ַ�Ƿ����ڱ�������һ��ģ���ڵĵ�ַ}
    function IsDelphiModuleAddress(Addr: Pointer): Boolean;
    {* �ж�ĳ��ַ�Ƿ����ڱ�������һ�� Delphi ģ���ڵĵ�ַ}
    property Items[Index: Integer]: TCnModuleInfo read GetItems;
  end;

  TCnStackInfo = class
  {* ����һ���ջ���õ�ַ��֧�� 32/64 λ}
  private
    FCallerAddr: Pointer;
  public
    property CallerAddr: Pointer read FCallerAddr write FCallerAddr;
  end;

  TCnStackInfoList = class(TObjectList)
  {* ��������ʵ����ʱ��ǰ����ջ�Ķ���ַ��֧�� 32/64 λ}
  private
    FModuleList: TCnModuleInfoList;
    function GetItems(Index: Integer): TCnStackInfo;
    procedure TrimNonDelphi;
  protected
    procedure TraceStackFrames; virtual; abstract;
  public
    constructor Create(OnlyDelphi: Boolean = False);
    destructor Destroy; override;

    procedure DumpToStrings(List: TStrings);

    property Items[Index: Integer]: TCnStackInfo read GetItems; default;
  end;

  TCnCurrentStackInfoList = class(TCnStackInfoList)
  {* ���ش�����ʵ��ʱ�Ķ�ջ}
  protected
    procedure TraceStackFrames; override;
  end;

  TCnManualStackInfoList = class(TCnStackInfoList)
  {* �����ⲿ�� Context �����е�ַ���ݵ��ö�ջ}
  private
    FCtxPtr: Pointer;
    FAddr: Pointer;
  protected
    procedure TraceStackFrames; override;
  public
    constructor Create(CtxPtr, Addr: Pointer; OnlyDelphi: Boolean = False);
    {* ����Ϊ Context ָ�롢�����쳣ʱ�ĵ�ַ/EIP}
  end;

// ================= ������ָ��ģ���ø�д IAT ��ķ�ʽ Hook API ================

function CnHookImportAddressTable(const ImportModuleName, ImportFuncName: string;
  out OldAddress: Pointer; NewAddress: Pointer; ModuleHandle: THandle = 0): Boolean;
{* �����ڸ�дָ��ģ��ĵ�����Դﵽ Hook ��ģ���ڶ��ⲿģ��ĺ������õ�Ŀ�ģ�֧�� 32/64 λ

  ImportModuleName: �� Hook �ĺ������ڵ�ģ����������ȫ·�������� user32.dll
  ImportFuncName:   �� Hook �ĺ������ƣ��� MessageBoxA
  OldAddress:       Hook �ɹ��󹩷��صľɵ�ַ�����贫��ֵ���ɵ����߱��棬�� UnHook ʱ�ָ�
  NewAddress:       �º����ĵ�ַ���� @MyMessageBoxA
  ModuleHandle:     �� Hook ��ģ�飬������ GetModuleHandle ������Ҫ��ã�
                    �紫 0����ʾ Hook �����̵� exe ��

  ����ֵ True ��ʾ Hook �ɹ�
  ע������ͬһ��ģ���ڣ�Hook ͬһ���ⲿģ���ͬһ������ʱ��Ҫ���Ʋ����ظ� Hook���Լ��� UnHook Ҫ�ϸ����
}

function CnUnHookImportAddressTable(const ImportModuleName, ImportFuncName: string;
  OldAddress, NewAddress: Pointer; ModuleHandle: THandle = 0): Boolean;
{* �����ڸ�дָ��ģ��ĵ���� Hook �Ļ�ԭ��֧�� 32/64 λ

  ImportModuleName: �� Hook �ĺ������ڵ�ģ����������ȫ·�������� user32.dll
  ImportFuncName:   �� Hook �ĺ������ƣ��� MessageBoxA
  OldAddress:       Hook �ɹ��󷵻صľɵ�ַ
  NewAddress:       �º����ĵ�ַ���� @MyMessageBoxA
  ModuleHandle:     �� Hook ��ģ�飬������ GetModuleHandle ������Ҫ��ã�
                    �紫 0����ʾ Hook �����̵� exe ��

  ����ֵ True ��ʾ UnHook �ɹ�
  ע������ͬһ��ģ���ڣ�Hook ͬһ���ⲿģ���ͬһ������ʱ��Ҫ���Ʋ����ظ� UnHook���Լ��� Hook Ҫ�ϸ����
}

// ======================== ȫ�ֵ��쳣 Hook ���� ===============================

{*
  Delphi ���������쳣��һ���Ǵ����� raise �ģ����� Exception ����ת��Ϊ ExceptionRecord��
  �ٵ��� Kernel32.RaiseException������ SEH ������Ӧ�� except/finally ��䴦

  һ���Ǵ��������ⲿ OS �쳣��� 0������Υ���ȣ�Ҳ����ת����� EExternal ���쳣
  CPU �� SEH ���ƻ��������ⲿ�쳣ʱ�����װ�� ExceptionRecord��
  ���� Delphi Ԥ�����úõ� _ExceptionHandler���ٲ����ȥת���� Exception ����

  �������ùң��κ�һ���쳣ֻ��ѡ��һ����
  ͬʱ������ Add/RemoveVectoredExceptionHandler ��ǰ��¼�쳣�� Context
  ��Ϊ Delphi û�� Context ��������
}
type
  TCnExceptionNotifier = procedure (ExceptObj: Exception; ExceptAddr: Pointer;
    IsOSException: Boolean; StackList: TCnStackInfoList) of object;

function CnHookException: Boolean;
{* �ҽ��쳣���������Ƿ�ҽӳɹ�}

function CnUnHookException: Boolean;
{* ����쳣����Ĺҽӣ������Ƿ����ɹ�}

function CnGetExceptionHooked: Boolean;
{* �����Ƿ��� HookException}

procedure CnSetAdditionalExceptionRecorder(ARecorder: TCnExceptionNotifier);
{* ����һ���쳣�ҽӵļ�¼����ֻ֧�ֵ�������}

implementation

const
{$IFDEF WIN64}
  HEX_FMT = '$%16.16x';
{$ELSE}
  HEX_FMT = '$%8.8x';
{$ENDIF}

  MODULE_INFO_FMT = 'HModule: ' + HEX_FMT + ' Base: ' + HEX_FMT + ' End: ' +
    HEX_FMT + ' Size: ' + HEX_FMT + ' IsDelphiModule %d. Name: %s - %s';
  STACK_INFO_FMT = 'Caller: ' + HEX_FMT;

  MAX_STACK_COUNT = 1024;
  ImagehlpLib = 'IMAGEHLP.DLL';
  IMAGE_ORDINAL_FLAG = LongWord($80000000);

type
{$IFDEF WIN64}
  TCnNativeUInt = NativeUInt;
{$ELSE}
  TCnNativeUInt = Cardinal;
{$ENDIF}

{$IFDEF SUPPORT_UINT64}
  DWORD64 = UInt64;
{$ELSE}
  DWORD64 = Int64;
{$ENDIF}

  TRtlCaptureStackBackTrace = function (FramesToSkip: LongWord; FramesToCapture: LongWord;
    var BackTrace: Pointer; BackTraceHash: PLongWord): Word; stdcall;
  TRtlCaptureContext = procedure (ContextRecord: PContext); stdcall;

  // Types of Address
  LPADDRESS64 = ^ADDRESS64;
  {$EXTERNALSYM PADDRESS64}
  _tagADDRESS64 = record
    Offset: DWORD64;
    Segment: WORD;
    Mode: ADDRESS_MODE;
  end;
  {$EXTERNALSYM _tagADDRESS64}
  ADDRESS64 = _tagADDRESS64;
  {$EXTERNALSYM ADDRESS64}
  TAddress64 = ADDRESS64;
  PAddress64 = LPADDRESS64;

  // Types of KDHelp
  PKDHELP64 = ^KDHELP64;
  {$EXTERNALSYM PKDHELP64}
  _KDHELP64 = record
    Thread: DWORD64;
    ThCallbackStack: DWORD;
    ThCallbackBStore: DWORD;
    NextCallback: DWORD;
    FramePointer: DWORD;
    KiCallUserMode: DWORD64;
    KeUserCallbackDispatcher: DWORD64;
    SystemRangeStart: DWORD64;
    Reserved: array [0..7] of DWORD64;
  end;
  {$EXTERNALSYM _KDHELP64}
  KDHELP64 = _KDHELP64;
  {$EXTERNALSYM KDHELP64}
  TKdHelp64 = KDHELP64;

  // Types of StackFrame64
  LPSTACKFRAME64 = ^STACKFRAME64;
  {$EXTERNALSYM LPSTACKFRAME64}
  _tagSTACKFRAME64 = record
    AddrPC: ADDRESS64; // program counter
    AddrReturn: ADDRESS64; // return address
    AddrFrame: ADDRESS64; // frame pointer
    AddrStack: ADDRESS64; // stack pointer
    AddrBStore: ADDRESS64; // backing store pointer
    FuncTableEntry: Pointer; // pointer to pdata/fpo or NULL
    Params: array [0..3] of DWORD64; // possible arguments to the function
    Far: BOOL; // WOW far call
    Virtual: BOOL; // is this a virtual frame?
    Reserved: array [0..2] of DWORD64;
    KdHelp: KDHELP64;
  end;
  {$EXTERNALSYM _tagSTACKFRAME64}
  STACKFRAME64 = _tagSTACKFRAME64;
  {$EXTERNALSYM STACKFRAME64}
  TStackFrame64 = STACKFRAME64;
  PStackFrame64 = LPSTACKFRAME64;

  // Types of Other Routines
  PREAD_PROCESS_MEMORY_ROUTINE64 = function (hProcess: THandle; qwBaseAddress: DWORD64;
    lpBuffer: Pointer; nSize: DWORD; var lpNumberOfBytesRead: DWORD): BOOL; stdcall;

  PFUNCTION_TABLE_ACCESS_ROUTINE64 = function (hProcess: THandle;
    AddrBase: DWORD64): Pointer; stdcall;

  PGET_MODULE_BASE_ROUTINE64 = function (hProcess: THandle;
    Address: DWORD64): DWORD64; stdcall;

  PTRANSLATE_ADDRESS_ROUTINE64 = function (hProcess: THandle; hThread: THandle;
    const lpaddr: ADDRESS64): DWORD64; stdcall;

  TStackWalk64 = function(MachineType: DWORD; hProcess, hThread: THandle;
    StackFrame: PStackFrame64; ContextRecord: Pointer;
    ReadMemoryRoutine: PREAD_PROCESS_MEMORY_ROUTINE64;
    FunctionTableAccessRoutine: PFUNCTION_TABLE_ACCESS_ROUTINE64;
    GetModuleBaseRoutine: PGET_MODULE_BASE_ROUTINE64;
    TranslateAddress: PTRANSLATE_ADDRESS_ROUTINE64): BOOL; stdcall;

  TSymFunctionTableAccess64 = function (hProcess: THandle; AddrBase: DWORD64): Pointer; stdcall;

  TSymGetModuleBase64 = function (hProcess: THandle; Address: DWORD64): DWORD64; stdcall;

  PEXCEPTION_POINTERS = ^EXCEPTION_POINTERS;

  PVectoredExceptionHandler = function(ExceptionInfo: PEXCEPTION_POINTERS): Integer; stdcall;

  TAddVectoredExceptionHandler = function(FirstHandler: DWORD;
    VectoredHandler: PVectoredExceptionHandler): Pointer; stdcall;

  TRemoveVectoredExceptionHandler = function(VectoredHandlerHandle: Pointer): DWORD; stdcall;

  _IMAGE_IMPORT_DESCRIPTOR = record
    case Byte of
      0: (Characteristics: DWORD);          // 0 for terminating null import descriptor
      1: (OriginalFirstThunk: DWORD;        // RVA to original unbound IAT (PIMAGE_THUNK_DATA)
          TimeDateStamp: DWORD;             // 0 if not bound,
                                            // -1 if bound, and real date\time stamp
                                            //     in IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT (new BIND)
                                            // O.W. date/time stamp of DLL bound to (Old BIND)

          ForwarderChain: DWORD;            // -1 if no forwarders
          Name: DWORD;
          FirstThunk: DWORD);                // RVA to IAT (if bound this IAT has actual addresses)
  end;
  {$EXTERNALSYM _IMAGE_IMPORT_DESCRIPTOR}
  IMAGE_IMPORT_DESCRIPTOR = _IMAGE_IMPORT_DESCRIPTOR;
  {$EXTERNALSYM IMAGE_IMPORT_DESCRIPTOR}
  TImageImportDescriptor = _IMAGE_IMPORT_DESCRIPTOR;
  PIMAGE_IMPORT_DESCRIPTOR = ^_IMAGE_IMPORT_DESCRIPTOR;
  {$EXTERNALSYM PIMAGE_IMPORT_DESCRIPTOR}
  PImageImportDescriptor = ^_IMAGE_IMPORT_DESCRIPTOR;

  _IMAGE_IMPORT_BY_NAME = record
    Hint: Word;
    Name: array[0..0] of Byte;
  end;
  {$EXTERNALSYM _IMAGE_IMPORT_BY_NAME}
  IMAGE_IMPORT_BY_NAME = _IMAGE_IMPORT_BY_NAME;
  {$EXTERNALSYM IMAGE_IMPORT_BY_NAME}
  TImageImportByName = _IMAGE_IMPORT_BY_NAME;
  PIMAGE_IMPORT_BY_NAME = ^_IMAGE_IMPORT_BY_NAME;
  {$EXTERNALSYM PIMAGE_IMPORT_BY_NAME}
  PImageImportByName = ^_IMAGE_IMPORT_BY_NAME;

  _IMAGE_THUNK_DATA32 = record
    case Byte of
      0: (ForwarderString: DWORD); // PBYTE
      1: (_Function: DWORD);       // PDWORD Function -> _Function
      2: (Ordinal: DWORD);
      3: (AddressOfData: DWORD);   // PIMAGE_IMPORT_BY_NAME
  end;
  {$EXTERNALSYM _IMAGE_THUNK_DATA32}
  IMAGE_THUNK_DATA32 = _IMAGE_THUNK_DATA32;
  {$EXTERNALSYM IMAGE_THUNK_DATA32}
  TImageThunkData32 = _IMAGE_THUNK_DATA32;
  PIMAGE_THUNK_DATA32 = ^_IMAGE_THUNK_DATA32;
  {$EXTERNALSYM PIMAGE_THUNK_DATA32}
  PImageThunkData32 = ^_IMAGE_THUNK_DATA32;

{$IFDEF WIN64}

  _IMAGE_THUNK_DATA64 = record
    case Byte of
      0: (ForwarderString: ULONGLONG); // PBYTE
      1: (_Function: ULONGLONG);       // PDWORD Function -> _Function
      2: (Ordinal: ULONGLONG);
      3: (AddressOfData: ULONGLONG);   // PIMAGE_IMPORT_BY_NAME
  end;
  {$EXTERNALSYM _IMAGE_THUNK_DATA64}
  IMAGE_THUNK_DATA64 = _IMAGE_THUNK_DATA64;
  {$EXTERNALSYM IMAGE_THUNK_DATA64}
  TImageThunkData64 = _IMAGE_THUNK_DATA64;
  PIMAGE_THUNK_DATA64 = ^_IMAGE_THUNK_DATA64;
  {$EXTERNALSYM PIMAGE_THUNK_DATA64}
  PImageThunkData64 = ^_IMAGE_THUNK_DATA64;

{$ENDIF}

type
{$IFDEF WIN64}
  PImageThunkData = PImageThunkData64;
{$ELSE}
  PImageThunkData = PImageThunkData32;
{$ENDIF}

var
  // XP ��ǰ��ƽ̨��֧������ API����Ҫ��̬����
  FImagehlpLibHandle: THandle = 0;

  RtlCaptureStackBackTrace: TRtlCaptureStackBackTrace = nil;
  RtlCaptureContext: TRtlCaptureContext = nil;
  StackWalk64: TStackWalk64 = nil;
  SymFunctionTableAccess64: TSymFunctionTableAccess64 = nil;
  SymGetModuleBase64: TSymGetModuleBase64 = nil;

  AddVectoredExceptionHandler: TAddVectoredExceptionHandler = nil;
  RemoveVectoredExceptionHandler: TRemoveVectoredExceptionHandler = nil;

// ��ѯĳ�����ַ�����ķ���ģ�� Handle��Ҳ���� AllocationBase
function ModuleFromAddr(const Addr: Pointer): HMODULE;
var
  MI: TMemoryBasicInformation;
begin
  VirtualQuery(Addr, MI, SizeOf(MI));
  if MI.State <> MEM_COMMIT then
    Result := 0
  else
    Result := HMODULE(MI.AllocationBase);
end;

{ TCnStackInfoList }

constructor TCnStackInfoList.Create(OnlyDelphi: Boolean);
begin
  inherited Create(True);
  FModuleList := TCnModuleInfoList.Create(OnlyDelphi);
  TraceStackFrames;
  if OnlyDelphi then
    TrimNonDelphi;
end;

destructor TCnStackInfoList.Destroy;
begin
  FModuleList.Free;
  inherited;
end;

function TCnStackInfoList.GetItems(Index: Integer): TCnStackInfo;
begin
  Result := TCnStackInfo(inherited Items[Index]);
end;

procedure TCnStackInfoList.TrimNonDelphi;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if not FModuleList.IsDelphiModuleAddress(Items[I].CallerAddr) then
      Delete(I);
end;

procedure TCnStackInfoList.DumpToStrings(List: TStrings);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List.Add(Format(STACK_INFO_FMT, [TCnNativeUInt(Items[I].CallerAddr)]));
end;

{ TCnModuleInfoList }

function TCnModuleInfoList.AddModule(PH: THandle; MH: HMODULE): TCnModuleInfo;
var
  ModuleInfo: TModuleInfo;
  Info: TCnModuleInfo;
  Res: DWORD;
  AName: array[0..MAX_PATH - 1] of Char;
begin
  Result := nil;

  // ����ÿ�� Module Handle �� Module ����ַ����Ϣ
  if GetModuleInformation(PH, MH, @ModuleInfo, SizeOf(TModuleInfo)) then
  begin
    Info := TCnModuleInfo.Create;
    Info.HModule := MH;
    Info.StartAddr := ModuleInfo.lpBaseOfDll;
    Info.Size := ModuleInfo.SizeOfImage;
    Info.EndAddr := Pointer(TCnNativeUInt(ModuleInfo.lpBaseOfDll) + ModuleInfo.SizeOfImage);

    Res := GetModuleBaseName(PH, MH, @AName[0], SizeOf(AName));
    if Res > 0 then
    begin
      SetLength(Info.FBaseName, Res);
      System.Move(AName[0], Info.FBaseName[1], Res * SizeOf(Char));
    end;
    Res := GetModuleFileName(MH, @AName[0], SizeOf(AName));
    if Res > 0 then
    begin
      SetLength(Info.FFullName, Res);
      System.Move(AName[0], Info.FFullName[1], Res * SizeOf(Char));
    end;
    Add(Info);
    Result := Info;
  end;
end;

procedure TCnModuleInfoList.BuildModulesList;
var
  ProcessHandle: THandle;
  Needed: DWORD;
  Modules: array of THandle;
  I, Cnt: Integer;
  Res: Boolean;
  MemInfo: TMemoryBasicInformation;
  Base: PByte;
  LastAllocBase: Pointer;
  QueryRes: DWORD;
  CurModule: PLibModule;
begin
  if FDelphiOnly then
  begin
    CurModule := LibModuleList;
    while CurModule <> nil do
    begin
      CreateItemForAddress(Pointer(CurModule.Instance), True);
      CurModule := CurModule.Next;
    end;
  end
  else
  begin
    ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, GetCurrentProcessId);
    if ProcessHandle <> 0 then
    begin
      try
        Res := EnumProcessModules(ProcessHandle, nil, 0, Needed);
        if Res then
        begin
          Cnt := Needed div SizeOf(HMODULE);
          SetLength(Modules, Cnt);
          if EnumProcessModules(ProcessHandle, @Modules[0], Needed, Needed) then
          begin
            for I := 0 to Cnt - 1 do
              CheckDelphiModule(AddModule(ProcessHandle, Modules[I]));
          end;
        end
        else
        begin
          Base := nil;
          LastAllocBase := nil;
          FillChar(MemInfo, SizeOf(TMemoryBasicInformation), #0);

          QueryRes := VirtualQueryEx(ProcessHandle, Base, MemInfo, SizeOf(TMemoryBasicInformation));
          while QueryRes = SizeOf(TMemoryBasicInformation) do
          begin
            if MemInfo.AllocationBase <> LastAllocBase then
            begin
              if MemInfo.Type_9 = MEM_IMAGE then
                CheckDelphiModule(AddModule(ProcessHandle, HMODULE(MemInfo.AllocationBase)));
              LastAllocBase := MemInfo.AllocationBase;
            end;
            Inc(Base, MemInfo.RegionSize);
            QueryRes := VirtualQueryEx(ProcessHandle, Base, MemInfo, SizeOf(TMemoryBasicInformation));
          end;
        end;
      finally
        CloseHandle(ProcessHandle);
      end;
    end;
  end;
end;

// �� System ��ϵͳģ�������ѯ Delphi ģ��
procedure TCnModuleInfoList.CheckDelphiModule(Info: TCnModuleInfo);
var
  CurModule: PLibModule;
begin
  if (Info <> nil) and (Info.HModule <> 0) then
  begin
    CurModule := LibModuleList;
    while CurModule <> nil do
    begin
      if CurModule.Instance = Info.HModule then
      begin
        Info.IsDelphi := True;
        Exit;
      end;
      CurModule := CurModule.Next;
    end;
  end;
end;

constructor TCnModuleInfoList.Create;
begin
  inherited Create(True);
  FDelphiOnly := ADelphiOnly;
  BuildModulesList;
end;

function TCnModuleInfoList.CreateItemForAddress(Addr: Pointer;
  AIsDelphi: Boolean): TCnModuleInfo;
var
  Module: HMODULE;
  ProcessHandle: THandle;
begin
  Result := nil;
  Module := ModuleFromAddr(Addr);
  if Module > 0 then
  begin
    ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, GetCurrentProcessId);
    if ProcessHandle <> 0 then
    begin
      try
        Result := AddModule(ProcessHandle, Module);
        if Result <> nil then
          Result.IsDelphi := AIsDelphi;
      finally
        CloseHandle(ProcessHandle);
      end;
    end;
  end;
end;

destructor TCnModuleInfoList.Destroy;
begin

  inherited;
end;

procedure TCnModuleInfoList.DumpToStrings(List: TStrings);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List.Add(Items[I].ToString);
end;

function TCnModuleInfoList.GetItems(Index: Integer): TCnModuleInfo;
begin
  Result := TCnModuleInfo(inherited Items[Index]);
end;

function TCnModuleInfoList.GetModuleFromAddress(Addr: Pointer): TCnModuleInfo;
var
  I: Integer;
  Item: TCnModuleInfo;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := Items[I];
    if (TCnNativeUInt(Item.StartAddr) <= TCnNativeUInt(Addr)) and
      (TCnNativeUInt(Item.EndAddr) > TCnNativeUInt(Addr)) then
    begin
      Result := Item;
      Exit;
    end;
  end;
end;

function TCnModuleInfoList.IsDelphiModuleAddress(Addr: Pointer): Boolean;
var
  Info: TCnModuleInfo;
begin
  Info := GetModuleFromAddress(Addr);
  Result := (Info <> nil) and Info.IsDelphi;
end;

function TCnModuleInfoList.IsValidModuleAddress(Addr: Pointer): Boolean;
begin
  Result := GetModuleFromAddress(Addr) <> nil;
end;

{ TCnModuleInfo }

function TCnModuleInfo.ToString: string;
begin
  Result := Format(MODULE_INFO_FMT, [FHModule, TCnNativeUInt(FStartAddr),
    TCnNativeUInt(FEndAddr), FSize, Integer(FIsDelphi), FBaseName, FFullName]);
end;

procedure InitAPIs;
var
  H: HINST;
  P: Pointer;
begin
  H := GetModuleHandle(kernel32);
  if H <> 0 then
  begin
    P := GetProcAddress(H, 'RtlCaptureStackBackTrace');
    if P <> nil then
      RtlCaptureStackBackTrace := TRtlCaptureStackBackTrace(P);
    P := GetProcAddress(H, 'AddVectoredExceptionHandler');
    if P <> nil then
      AddVectoredExceptionHandler := TAddVectoredExceptionHandler(P);
    P := GetProcAddress(H, 'RemoveVectoredExceptionHandler');
    if P <> nil then
      RemoveVectoredExceptionHandler := TRemoveVectoredExceptionHandler(P);
  end;

  H := GetModuleHandle('ntdll.dll');
  if H <> 0 then
  begin
    P := GetProcAddress(H, 'RtlCaptureContext');
    if P <> nil then
      RtlCaptureContext := TRtlCaptureContext(P);
  end;

  FImagehlpLibHandle := LoadLibrary(ImagehlpLib);
  if FImagehlpLibHandle <> 0 then
  begin
    P := GetProcAddress(FImagehlpLibHandle, 'StackWalk64');
    if P <> nil then
      StackWalk64 := TStackWalk64(P);
    P := GetProcAddress(FImagehlpLibHandle, 'SymFunctionTableAccess64');
    if P <> nil then
      SymFunctionTableAccess64 := TSymFunctionTableAccess64(P);
    P := GetProcAddress(FImagehlpLibHandle, 'SymGetModuleBase64');
    if P <> nil then
      SymGetModuleBase64 := TSymGetModuleBase64(P);
  end;
end;

// ===================== �������ø�д IAT ��ķ�ʽ Hook API ====================

// Hook Ϊ True ʱ���� Hook ������Ҫ�����µ�ַ���ɵ�ַͨ�� OldAddress ����ȥ
// Hook Ϊ False ʱ���� UnHook ������Ҫ����ɵ�ַ��
function HookImportAddressTable(Hook: Boolean; const ModuleName, FuncName: string;
  var OldAddress: Pointer; NewAddress: Pointer; ModuleHandle: THandle): Boolean;
var
  HP, HM: THandle;
  Size: DWORD;
  MN, FN: PAnsiChar;
  PIP: PImageImportDescriptor;
  PIIBN: PImageImportByName;
  PITO, PITR: PImageThunkData;
  AMN, AFN: AnsiString;
  MBI: TMemoryBasicInformation;
  FindingAddress: Pointer;
begin
  Result := False;
  if (ModuleName = '') or (FuncName = '') then
    Exit;

  if Hook and (NewAddress = nil) then
    Exit;

  if not Hook and (OldAddress = nil) then
    Exit;

  HP := ModuleHandle;           // ���Ҫʵʩ Hook ��ģ��
  if HP = 0 then
    HP := GetModuleHandle(nil); // ��� EXE ��ģ�� Handle
  if HP = 0 then
    Exit;

  Size := 0;
  PIP := PImageImportDescriptor(ImageDirectoryEntryToData(Pointer(HP), True,
    IMAGE_DIRECTORY_ENTRY_IMPORT, Size));

  if PIP = nil then
    Exit;

  AMN := AnsiString(LowerCase(ModuleName));
  while PIP^.Name <> 0 do
  begin
    MN := PAnsiChar(TCnNativeUInt(HP) + PIP^.Name);
    if MN = '' then
      Break;

    if AnsiStrIComp(MN, PAnsiChar(AMN)) = 0 then
    begin
      PITR := PImageThunkData(TCnNativeUInt(HP) + PIP^.FirstThunk);

      // �ҵ�������� DLL���������������
      if PIP^.OriginalFirstThunk <> 0 then // �� OFT����ʾ���Ը��������� IAT ��Ķ���
      begin
        PITO := PImageThunkData(TCnNativeUInt(HP) + PIP^.OriginalFirstThunk);
        AFN := AnsiString(FuncName);

        while PITO^._Function <> 0 do
        begin
          if (PITO^.Ordinal and IMAGE_ORDINAL_FLAG) <> IMAGE_ORDINAL_FLAG then
          begin
            PIIBN := PImageImportByName(TCnNativeUInt(HP) + PITO^.AddressOfData);
            FN := PAnsiChar(@(PIIBN^.Name[0]));

            if (FN <> '') and (AnsiStrIComp(FN, PAnsiChar(AFN)) = 0) then
            begin
              // �ҵ���Ҫ�滻�ĺ�����ַ����Ȩ����
              VirtualQuery(PITR, MBI, SizeOf(TMemoryBasicInformation));
              VirtualProtect(MBI.BaseAddress, MBI.RegionSize, PAGE_READWRITE, @MBI.Protect);

              if Hook then
              begin
                // �滻
                OldAddress := Pointer(PITR^._Function);
                PITR^._Function := TCnNativeUInt(NewAddress);
              end
              else
              begin
                // �ָ�
                PITR^._Function := TCnNativeUInt(OldAddress);
              end;

              Result := True;
              Exit;
            end;
          end;

          Inc(PITO);
          Inc(PITR);
        end;
      end
      else // OFT Ϊ 0����ʾҪ�������� FirstTrunk ָ��� IAT�������ж��
      begin
        HM := GetModuleHandle(PChar(ModuleName));
        if HM <> 0 then
        begin
          FindingAddress := GetProcAddress(HM, PChar(FuncName));

          if Hook then
          begin
            while PITR^._Function <> 0 do
            begin
              if PITR^._Function = TCnNativeUInt(FindingAddress) then
              begin
                // �滻
                VirtualQuery(PITR, MBI, SizeOf(TMemoryBasicInformation));
                VirtualProtect(MBI.BaseAddress, MBI.RegionSize, PAGE_READWRITE, @MBI.Protect);

                OldAddress := Pointer(PITR^._Function);
                PITR^._Function := TCnNativeUInt(NewAddress);
                Result := True;
              end;
              Inc(PITR);
            end;
          end
          else // ѭ�����һָ��������ж��
          begin
            while PITR^._Function <> 0 do
            begin
              if PITR^._Function = TCnNativeUInt(NewAddress) then
              begin
                VirtualQuery(PITR, MBI, SizeOf(TMemoryBasicInformation));
                VirtualProtect(MBI.BaseAddress, MBI.RegionSize, PAGE_READWRITE, @MBI.Protect);

                if OldAddress <> nil then // �ָ�ʱ�����Դ���ĵ�ַΪ׼
                  PITR^._Function := TCnNativeUInt(OldAddress)
                else
                  PITR^._Function := TCnNativeUInt(FindingAddress);

                Result := True;
              end;
              Inc(PITR);
            end;
          end;
        end;
      end;
    end;
    Inc(PIP);
  end;
end;

function CnHookImportAddressTable(const ImportModuleName, ImportFuncName: string;
  out OldAddress: Pointer; NewAddress: Pointer; ModuleHandle: THandle): Boolean;
begin
  Result := HookImportAddressTable(True, ImportModuleName, ImportFuncName,
    OldAddress, NewAddress, ModuleHandle);
end;

function CnUnHookImportAddressTable(const ImportModuleName, ImportFuncName: string;
  OldAddress, NewAddress: Pointer; ModuleHandle: THandle): Boolean;
begin
  Result := HookImportAddressTable(False, ImportModuleName, ImportFuncName,
    OldAddress, NewAddress, ModuleHandle);
end;

// ======================== ȫ�ֵ��쳣 Hook ���� ===============================

const
  cDelphiException = $0EEDFADE;
  cNonContinuable = 1;

type
  PExceptionArguments = ^TExceptionArguments;
  TExceptionArguments = record
    ExceptAddr: Pointer;
    ExceptObj: Exception;
  end;

  TRaiseException = procedure (dwExceptionCode, dwExceptionFlags, nNumberOfArguments: DWORD;
    lpArguments: TCnNativeUInt); stdcall;

var
  FExceptionHooked: Boolean = False;
  FExceptionRecorder: TCnExceptionNotifier = nil;

  Kernel32RaiseException: Pointer = nil;
  SysUtilsExceptObjProc: function (P: PExceptionRecord): Exception = nil;

function SystemTObjectInstance: HINST;
begin
  Result := FindClassHInstance(System.TObject);
end;

procedure DoExceptionNotify(ExceptObj: Exception; ExceptAddr: Pointer;
  IsOSException: Boolean; StackList: TCnStackInfoList);
begin
  if Assigned(FExceptionRecorder) then
    FExceptionRecorder(ExceptObj, ExceptAddr, IsOSException, StackList);
end;

// ���� raise �쳣ֻ������
procedure MyKernel32RaiseException(ExceptionCode, ExceptionFlags, NumberOfArguments: DWORD;
  Arguments: PExceptionArguments); stdcall;
const
  OFFSET = 4;
var
  StackList: TCnStackInfoList;
begin
  if (ExceptionFlags = cNonContinuable) and (ExceptionCode = cDelphiException) and (NumberOfArguments = 7)
    {$IFNDEF WIN64} and (TCnNativeUInt(Arguments) = TCnNativeUInt(@Arguments) + OFFSET) {$ENDIF}
    then
  begin
    // �ڴ˼�¼��ǰ��ջ����ȥ������Ԫ�ڲ��ļ�¼
    StackList := TCnCurrentStackInfoList.Create;
    if StackList.Count > 2 then
    begin
      StackList.Delete(0);
      StackList.Delete(0);
    end;

    try
      DoExceptionNotify(Arguments.ExceptObj, Arguments.ExceptAddr, False, StackList);
    finally
      StackList.Free;
    end;
  end;

  // ����� API �����������׳�
  TRaiseException(Kernel32RaiseException)(ExceptionCode, ExceptionFlags,
    NumberOfArguments, TCnNativeUInt(Arguments));
end;

threadvar
  ExceptionContext: TContext;

// OS �쳣����������� Vectored
function MyExceptObjProc(P: PExceptionRecord): Exception;
var
  StackList: TCnStackInfoList;
begin
  Result := SysUtilsExceptObjProc(P);  // �ȵ��þɵķ��� Exception ����
  StackList := TCnManualStackInfoList.Create(@ExceptionContext, P^.ExceptionAddress);

  try
    DoExceptionNotify(Result, P^.ExceptionAddress, True, StackList);
  finally
    StackList.Free;
  end;
end;

// OS �쳣����������� ExceptObjProc
function MyVectoredExceptionHandler(ExceptionInfo: PEXCEPTION_POINTERS): DWORD; stdcall;
begin
  // ��¼ Context
  ExceptionContext := ExceptionInfo^.ContextRecord^;
  Result := 0; // EXCEPTION_CONTINUE_SEARCH;
end;

function CnHookException: Boolean;
const
  CALL_FIRST = 1;
begin
  Result := False;
  if not FExceptionHooked then
  begin
    Result := CnHookImportAddressTable(kernel32, 'RaiseException', Kernel32RaiseException,
      @MyKernel32RaiseException, SystemTObjectInstance);

    if Result then
    begin
      SysUtilsExceptObjProc := System.ExceptObjProc;
      System.ExceptObjProc := @MyExceptObjProc;

      if Assigned(AddVectoredExceptionHandler) then
        AddVectoredExceptionHandler(CALL_FIRST, @MyVectoredExceptionHandler);

      FExceptionHooked := True;
    end;
  end;
end;

function CnUnHookException: Boolean;
begin
  Result := False;
  if FExceptionHooked then
  begin
    Result := CnUnHookImportAddressTable(kernel32, 'RaiseException', Kernel32RaiseException,
      @MyKernel32RaiseException, SystemTObjectInstance);

    if Result then
    begin
      System.ExceptObjProc := @SysUtilsExceptObjProc;
      SysUtilsExceptObjProc := nil;

      if Assigned(RemoveVectoredExceptionHandler) then
        RemoveVectoredExceptionHandler(@MyVectoredExceptionHandler);

      FExceptionHooked := False;
    end;
  end;
end;

function CnGetExceptionHooked: Boolean;
begin
  Result := FExceptionHooked;
end;

procedure CnSetAdditionalExceptionRecorder(ARecorder: TCnExceptionNotifier);
begin
  FExceptionRecorder := ARecorder;
end;

{ TCnCurrentStackInfoList }

procedure TCnCurrentStackInfoList.TraceStackFrames;
var
  Info: TCnStackInfo;
  C: Word;
  I: Integer;
  Callers: array[0..MAX_STACK_COUNT - 1] of Pointer;
begin
  if Assigned(RtlCaptureStackBackTrace) then // XP/2003 or above, Support 32/64
  begin
    Capacity := 32;
    C := RtlCaptureStackBackTrace(0, MAX_STACK_COUNT, Callers[0], nil);
    for I := 0 to C - 1 do
    begin
      Info := TCnStackInfo.Create;
      Info.CallerAddr := Callers[I];
      Add(Info);
    end;
  end
end;

{ TCnExceptionStackInfoList }

constructor TCnManualStackInfoList.Create(CtxPtr, Addr: Pointer;
  OnlyDelphi: Boolean);
begin
  FCtxPtr := CtxPtr;
  FAddr := Addr;
  inherited Create(OnlyDelphi);
end;

procedure TCnManualStackInfoList.TraceStackFrames;
var
  Ctx: TContext;     // Ctx ò�Ƶ��������ϣ����ܷŴ�������棬������������Ī������Ĵ�
  PCtx: PContext;
  Info: TCnStackInfo;
  STKF64: TStackFrame64;
  P, T: THandle;
  Res: Boolean;
  MachineType: DWORD;
begin
  if Assigned(RtlCaptureContext) and Assigned(StackWalk64) then
  begin
    if FCtxPtr = nil then
    begin
      FillChar(Ctx, SizeOf(TContext), 0);
      RtlCaptureContext(@Ctx);  // 64 λ������£���Ȼ������Ͽ��ܻ����
      FCtxPtr := @Ctx;
    end;
    PCtx := PContext(FCtxPtr);

{$IFDEF WIN64}
    MachineType := IMAGE_FILE_MACHINE_AMD64;
    if FAddr = nil then
      FAddr := Pointer(PCtx^.Rip);
{$ELSE}
    MachineType := IMAGE_FILE_MACHINE_I386;
    if FAddr = nil then
      FAddr := Pointer(PCtx^.Eip);
{$ENDIF}

    FillChar(STKF64, SizeOf(TStackFrame64), 0);
    STKF64.AddrPC.Mode         := AddrModeFlat;
    STKF64.AddrStack.Mode      := AddrModeFlat;
    STKF64.AddrFrame.Mode      := AddrModeFlat;
    STKF64.AddrPC.Offset       := TCnNativeUInt(FAddr);

{$IFDEF WIN64}
    STKF64.AddrStack.Offset    := PCtx^.Rsp;
    STKF64.AddrFrame.Offset    := PCtx^.Rbp;
{$ELSE}
    STKF64.AddrStack.Offset    := TCnNativeUInt(PCtx^.Esp);
    STKF64.AddrFrame.Offset    := TCnNativeUInt(PCtx^.Ebp);
{$ENDIF}

    P := GetCurrentProcess;
    T := GetCurrentThread;

    while True do
    begin
      // FIXME: 64 λ�� StackWalk64 ʼ��ץ������ջ��զ�죿
      Res := StackWalk64(MachineType, P, T, @STKF64, PCtx, nil, @SymFunctionTableAccess64,
        @SymGetModuleBase64, nil);

      if Res and (STKF64.AddrPC.Offset <> 0) then
      begin
        if STKF64.AddrReturn.Offset = 0 then
          Break;

        Info := TCnStackInfo.Create;
        Info.CallerAddr := Pointer(STKF64.AddrPC.Offset);
        Add(Info);
      end
      else
        Break;

      if STKF64.AddrReturn.Offset = 0 then
        Break;
    end;
  end;
end;

initialization
  InitAPIs;

finalization
  CnUnHookException;
  if FImagehlpLibHandle <> 0 then
    FreeLibrary(FImagehlpLibHandle);

end.





