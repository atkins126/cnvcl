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

unit CnLockFree;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����
* ��Ԫ���ƣ��漰���������Ƶ�һЩԭ�Ӳ�����װ�Լ��������ݽṹ��ʵ��
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע����װ�� CnAtomicCompareAndSet �� CAS ʵ�֣���Ӧ 32 λ�� 64 λ
*           �����ڴ�ʵ������������������������������д������ѭ������
*           ������������ο��� Timothy L. Harris �����ģ�
*             ��A Pragmatic Implementation of Non-Blocking Linked-Lists��
* ����ƽ̨��PWin2000 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/ 10.3������ Win32/64
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2021.04.02 V1.2
*               ��֧�� Atomic �� C++Buider ƽ̨�����ĸ��������׳��쳣
*           2021.01.22 V1.1
*               ʵ�ֵ��̶߳����߳�д������ѭ������
*           2021.01.10 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, {$IFDEF MSWINDOWS} Windows, {$ENDIF} Classes, CnNativeDecl;

const
  CN_RING_QUEUE_DEFAULT_CAPACITY = 16;

type
{$IFDEF CPUX64}
  TCnSpinLockRecord = NativeInt;
{$ELSE}
  TCnSpinLockRecord = Integer;
{$ENDIF}
  {* ��������ֵΪ 1 ʱ��ʾ�б�����������0 ��ʾ����}

  TCnLockFreeNodeKeyCompare = function(Key1, Key2: TObject): Integer;
  {* �����Ƚ� Key �ķ������ͣ����� -1��0��1}

  PCnLockFreeLinkedNode = ^TCnLockFreeLinkedNode;

  TCnLockFreeLinkedNode = packed record
  {* ����������ڵ�}
    Key: TObject;
    Value: TObject;
    Next: PCnLockFreeLinkedNode; // ��ָ���λΪ 1 ��ʾ�ýڵ��ɾ��
  end;

  TCnLockFreeNodeTravelEvent = procedure(Sender: TObject; Node: PCnLockFreeLinkedNode) of object;

  TCnLockFreeLinkedList = class
  {* ������������ʵ��}
  private
    FCompare: TCnLockFreeNodeKeyCompare;
    FGuardHead: PCnLockFreeLinkedNode; // �̶���ͷ�ڵ�ָ��
    FGuardTail: PCnLockFreeLinkedNode; // �̶���β�ڵ�ָ��
    FHiddenHead, FHiddenTail: TCnLockFreeLinkedNode;
    FOnTravelNode: TCnLockFreeNodeTravelEvent;
    function GetLastNode: PCnLockFreeLinkedNode; // ��������� FGuadTail ֮ǰ�����һ����ָ��
    function GetLast2Nodes(out P1, P2: PCnLockFreeLinkedNode): Boolean;
    // ��������� FGuadTail ֮ǰ���������ָ�룬P1.Next ָ�� P2��P2.Next ָ�� FTail

    function CompareKey(Key1, Key2: TObject): Integer;
    function IsNodePointerMarked(Node: PCnLockFreeLinkedNode): Boolean;  // �ڵ�ָ�������λ�洢һ Mark ���
    function GetMarkedNodePointer(Node: PCnLockFreeLinkedNode): PCnLockFreeLinkedNode;   // ��һ���ڵ�ָ����� Mark ���
    function ExtractRealNodePointer(Node: PCnLockFreeLinkedNode): PCnLockFreeLinkedNode; // ����һ���ڵ�ָ���ʵ��ֵ�������޼��� Mark ���
    function GetNextNode(Node: PCnLockFreeLinkedNode): PCnLockFreeLinkedNode; // ����һ���ڵ�ĺ�����ʵ�ڵ㣬ȥ�� Mark ��ǵ�
    procedure InternalSearch(Key: TObject; var LeftNode, RightNode: PCnLockFreeLinkedNode);
    {* �ڲ�������������������ض� Key ����������δ��ǽڵ㣬������ڵ�� Key < Key���ҽڵ�� Key >= Key}
  protected
    function CreateNode: PCnLockFreeLinkedNode;
    procedure FreeNode(Node: PCnLockFreeLinkedNode);
    procedure DoTravelNode(Node: PCnLockFreeLinkedNode); virtual;
  public
    constructor Create(KeyCompare: TCnLockFreeNodeKeyCompare = nil);
    destructor Destroy; override;

    function GetCount: Integer;
    {* ������ȡ�ж��ٸ��ڵ㣬���������ؽڵ�}
    procedure Clear;
    {* ȫ����գ��÷�����֧�ֶ��߳�}
    procedure Travel;
    {* ��ͷ���������ÿ���ڵ���� OnTravelNode �¼�����֧�ֶ��߳�}

    procedure Append(Key, Value: TObject);
    {* ������β��ֱ������½ڵ㣬�����������б�֤ Key �������������������}
    function RemoveTail(out Key, Value: TObject): Boolean;
    {* ɾ������β�ڵ㣬����ɾ����β�ڵ�� Key �� Value ���ء�����β�ڵ㣬���� False}

    function Insert(Key, Value: TObject): Boolean;
    {* �������и��� Key ����λ�ò����벢���� True����� Key �Ѿ������򷵻� False}
    function HasKey(Key: TObject; out Value: TObject): Boolean;
    {* ������������ָ�� Key �Ƿ���ڣ�������򷵻� True ������Ӧ Value ����}
    function Delete(Key: TObject): Boolean;
    {* ��������ɾ��ָ�� Key ƥ��Ľڵ㣬�����Ƿ��ҵ�}

    property OnTravelNode: TCnLockFreeNodeTravelEvent read FOnTravelNode write FOnTravelNode;
    {* ����ʱ�������¼�}
  end;

  TCnLockFreeLinkedStack = class(TCnLockFreeLinkedList)
  {* ����������Ϊ����ʵ�ֵ������������ջ}
  public
    procedure Push(Key, Value: TObject);
    {* ��ջ}
    function Pop(out Key, Value: TObject): Boolean;
    {* ��ջ����ջ���򷵻� False}
  end;

  TCnLockFreeSingleRingQueueNode = packed record
  {* ���нڵ�}
    Key: TObject;
    Value: TObject;
  end;

  TCnLockFreeSingleRingQueue = class
  {* ֻ֧��һ�̶߳�һ�߳�д������ѭ������}
  private
    FSize: Integer;
    FHead: Cardinal; // ����в��գ�Head ʼ��ָ����Ч�ڵ㡣Head ��һ���ڵ�ʼ����Ч�����۶��������
    FTail: Cardinal; // ���۶�������գ�Tail ʼ��ָ����Ч�ڵ㡣����в��գ�Tail ��һ���ڵ�ʼ����Ч
    FNodes: array of TCnLockFreeSingleRingQueueNode;
    function GetCount: Integer;
    function GetIndex(Seq: Cardinal): Integer;
  protected

  public
    constructor Create(ASize: Integer = CN_RING_QUEUE_DEFAULT_CAPACITY);
    destructor Destroy; override;

    function Enqueue(Key, Value: TObject): Boolean;
    {* �����ͷ�������Ƿ���ɹ�����������򷵻� False}
    function Dequeue(out Key, Value: TObject): Boolean;
    {* ������β�������Ƿ���ɹ�������п��򷵻� False}

    function IsEmpty: Boolean;
    {* �����Ƿ�գ�Ҳ����ͷָ���βָ�����}
    function IsFull: Boolean;
    {* �����Ƿ�����Ҳ����ͷָ���βָ���һ}
    property Count: Integer read GetCount;
    {* �������м�����ЧԪ��}
    property Size: Integer read FSize;
    {* ���еĴ�С}
  end;

//------------------------------------------------------------------------------
// ԭ�Ӳ�����װ
//------------------------------------------------------------------------------

function CnAtomicIncrement32(var Addend: Integer): Integer;
{* ԭ�Ӳ�����һ 32 λֵ�� 1���������Ӻ��ֵ}

function CnAtomicDecrement32(var Addend: Integer): Integer;
{* ԭ�Ӳ�����һ 32 λֵ�� 1�����ؼ��ٺ��ֵ}

function CnAtomicExchange32(var Target: Integer; Value: Integer): Integer;
{* ԭ�Ӳ������� 32 λֵ���������� Targe ��ԭʼֵ}

function CnAtomicExchangeAdd32(var Addend: LongInt; Value: LongInt): Longint;
{* ԭ�Ӳ����� 32 λֵ Addend := Addend + Value������ Addend ԭʼֵ}

// ���� 4 �� 64 λ�������������� API���ڲ�֧�� Atomic �� C++Buider ƽ̨�ϲ�֧�֣����׳��쳣

function CnAtomicIncrement64(var Addend: Int64): Int64;
{* ԭ�Ӳ�����һ 64 λֵ�� 1���������Ӻ��ֵ}

function CnAtomicDecrement64(var Addend: Int64): Int64;
{* ԭ�Ӳ�����һ 64 λֵ�� 1�����ؼ��ٺ��ֵ}

function CnAtomicExchange64(var Target: Int64; Value: Int64): Int64;
{* ԭ�Ӳ������� 64 λֵ���������� Targe ��ԭʼֵ}

function CnAtomicExchangeAdd64(var Addend: Int64; Value: Int64): Int64;
{* ԭ�Ӳ����� 64 λֵ Addend := Addend + Value������ Addend ԭʼֵ}

// ���� 4 �� 64 λ�������������� API���ڲ�֧�� Atomic �� C++Buider ƽ̨�ϲ�֧��

function CnAtomicCompareExchange(var Target: Pointer; NewValue: Pointer; Comperand: Pointer): Pointer;
{* ԭ�Ӳ����Ƚ� Target �� Comperand ��ֵ�����ʱ�� NewValue ��ֵ�� Target�����ؾɵ� Target ֵ
  32 λ��֧�� 32 λֵ��64 λ��֧�� 64 λֵ}

function CnAtomicCompareAndSet(var Target: Pointer; NewValue: Pointer; Comperand: Pointer): Boolean;
{* ԭ�Ӳ���ִ�����´��룬�Ƚ� Target �� Comperand ��ֵ�����ʱ�� NewValue ��ֵ�� Target��
  32 λ��֧�� 32 λֵ��64 λ��֧�� 64 λֵ��δ������ֵ����ʱ���� False����ֵʱ���� True
  ע�� NewValue ��Ҫ���� Target�������޷������Ƿ�ִ���˸�ֵ��������Ϊ�����Ƿ�ֵ��һ��
  if Comperand = Target then
  begin
    Target := NewValue;
    Result := True;
  end
  else
    Result := False;
}

//------------------------------------------------------------------------------
// ������
//------------------------------------------------------------------------------

procedure CnInitSpinLockRecord(var Critical: TCnSpinLockRecord);
{* ��ʼ��һ������������ʵ���Ǹ�ֵΪ 0�������ͷ�}

procedure CnSpinLockEnter(var Critical: TCnSpinLockRecord);
{* ����������}

procedure CnSpinLockLeave(var Critical: TCnSpinLockRecord);
{* �뿪������}

implementation

{$IFDEF MSWINDOWS}
const
  kernel32  = 'kernel32.dll';
{$ELSE}
const // MACOS �� Linux ���������TODO: ��ȷ�� Mac ���в�
  kernel32  = 'libwine.borland.so';
{$ENDIF}

{$IFDEF DELPHI}

function InterlockedCompareExchange64(var Destination: Int64; Exchange: Int64;
  Comparand: Int64): Int64 stdcall; external kernel32 name 'InterlockedCompareExchange64';

{$ENDIF}

function CnAtomicIncrement32(var Addend: Integer): Integer;
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicIncrement(Addend);
{$ELSE}
  Result := InterlockedIncrement(Addend);
{$ENDIF}
end;

function CnAtomicDecrement32(var Addend: Integer): Integer;
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicDecrement(Addend);
{$ELSE}
  Result := InterlockedDecrement(Addend);
{$ENDIF}
end;

function CnAtomicExchange32(var Target: Integer; Value: Integer): Integer;
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicExchange(Target, Value);
{$ELSE}
  Result := InterlockedExchange(Target, Value);
{$ENDIF}
end;

function CnAtomicExchangeAdd32(var Addend: LongInt; Value: LongInt): LongInt;
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicIncrement(Addend, Value) - Value;
{$ELSE}
  {$IFDEF WIN64}
  Result := InterlockedExchangeAdd(Addend, Value);
  {$ELSE}
  Result := InterlockedExchangeAdd(@Addend, Value);
  {$ENDIF}
{$ENDIF}
end;

function CnAtomicIncrement64(var Addend: Int64): Int64;
{$IFNDEF SUPPORT_ATOMIC}
{$IFDEF DELPHI}
var
  Tmp: Int64;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicIncrement(Addend);
{$ELSE}
  {$IFDEF DELPHI}
  repeat
    Tmp := Addend;
    Result := InterlockedCompareExchange64(Addend, Tmp + 1, Tmp);
  until Result = Tmp;
  Inc(Result);
  {$ELSE}
  raise Exception.Create('NOT Implemented.');
  {$ENDIF}
{$ENDIF}
end;

function CnAtomicDecrement64(var Addend: Int64): Int64;
{$IFNDEF SUPPORT_ATOMIC}
{$IFDEF DELPHI}
var
  Tmp: Int64;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicDecrement(Addend);
{$ELSE}
  {$IFDEF DELPHI}
  repeat
    Tmp := Addend;
    Result := InterlockedCompareExchange64(Addend, Tmp - 1, Tmp);
  until Result = Tmp;
  Dec(Result);
  {$ELSE}
  raise Exception.Create('NOT Implemented.');
  {$ENDIF}
{$ENDIF}
end;

function CnAtomicExchange64(var Target: Int64; Value: Int64): Int64;
{$IFNDEF SUPPORT_ATOMIC}
{$IFDEF DELPHI}
var
  Tmp: Int64;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicExchange(Target, Value);
{$ELSE}
  {$IFDEF DELPHI}
  repeat
    Tmp := Target;
    Result := InterlockedCompareExchange64(Target, Value, Tmp);
  until Result = Tmp;
  {$ELSE}
  raise Exception.Create('NOT Implemented.');
  {$ENDIF}
{$ENDIF}
end;

function CnAtomicExchangeAdd64(var Addend: Int64; Value: Int64): Int64;
var
  Tmp: Int64;
begin
  repeat
{$IFDEF SUPPORT_ATOMIC}
    Tmp := Addend;
    Result := AtomicCmpExchange(Addend, Addend + Value, Tmp);
{$ELSE}
    {$IFDEF DELPHI}
    Tmp := Addend;
    Result := InterlockedCompareExchange64(Addend, Addend + Value, Tmp);
    {$ELSE}
    raise Exception.Create('NOT Implemented.');
    {$ENDIF}
{$ENDIF}
  until Result = Tmp;
end;

function CnAtomicCompareExchange(var Target: Pointer; NewValue: Pointer; Comperand: Pointer): Pointer;
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicCmpExchange(Target, NewValue, Comperand);
{$ELSE}
  {$IFDEF BDS}
  Result := Pointer(InterlockedCompareExchange(Integer(Target), Integer(NewValue), Integer(Comperand)));
  {$ELSE} // D567 �µ� InterlockedCompareExchange ������Ϊ Pointer
  Result := InterlockedCompareExchange(Target, NewValue, Comperand);
  {$ENDIF}
{$ENDIF}
end;

{$IFDEF SUPPORT_ATOMIC}

function CnAtomicCompareAndSet(var Target: Pointer; NewValue: Pointer;
  Comperand: Pointer): Boolean;
begin
  AtomicCmpExchange(Target, NewValue, Comperand, Result);
end;

{$ELSE}

{$IFDEF WIN64}

// XE2 �� Win64 ��û�� Atomic ϵ�к���
function CnAtomicCompareAndSet(var Target: Pointer; NewValue: Pointer;
  Comperand: Pointer): Boolean; assembler;
asm
  // API ��� InterlockedCompareExchange ���᷵���Ƿ�ɹ������ò��û�����
  MOV  RAX,  R8
  LOCK CMPXCHG [RCX], RDX
  SETZ AL
  AND RAX, $FF
end;

{$ELSE}

// XE2 �����°汾�� Win32 ʵ��
function CnAtomicCompareAndSet(var Target: Pointer; NewValue: Pointer;
  Comperand: Pointer): Boolean; assembler;
asm
  // API ��� InterlockedCompareExchange ���᷵���Ƿ�ɹ������ò��û�����
  // ���� @Target �� EAX, NewValue �� EDX��Comperand �� ECX��
  // Ҫ��һ�� ECX �� EAX �Ļ������ܵ��� LOCK CMPXCHG [ECX], EDX����������� AL ��
  XCHG  EAX, ECX
  LOCK CMPXCHG [ECX], EDX
  SETZ AL
  AND EAX, $FF
end;

{$ENDIF}

{$ENDIF}

procedure CnInitSpinLockRecord(var Critical: TCnSpinLockRecord);
begin
  Critical := 0;
end;

procedure CnSpinLockEnter(var Critical: TCnSpinLockRecord);
begin
  repeat
    while Critical <> 0 do
      ;  // �˴�����ĳ� Sleep(0) �ͻ����߳��л��������Ͳ�����������
  until CnAtomicCompareAndSet(Pointer(Critical), Pointer(1), Pointer(0));
end;

procedure CnSpinLockLeave(var Critical: TCnSpinLockRecord);
begin
  while not CnAtomicCompareAndSet(Pointer(Critical), Pointer(0), Pointer(1)) do
    Sleep(0);
end;

{ TCnLockFreeLinkedList }

function DefaultKeyCompare(Key1, Key2: TObject): Integer;
var
  K1, K2: TCnNativeInt;
begin
  K1 := TCnNativeInt(Key1);
  K2 := TCnNativeInt(Key2);

  if K1 > K2 then
    Result := 1
  else if K1 < K2 then
    Result := -1
  else
    Result := 0;
end;

procedure TCnLockFreeLinkedList.Append(Key, Value: TObject);
var
  Node, P: PCnLockFreeLinkedNode;
begin
  Node := CreateNode;
  Node^.Key := Key;
  Node^.Value := Value;
  Node^.Next := FGuardTail;

  // ԭ�Ӳ�����������β�� Tail���ж� Tail �� Next �Ƿ��� FGuardTail������ Tail �� Next ��Ϊ NewNode
  // ��������߳��޸��� Tail����������ȡ���� Tail ����β�ͣ���ô Tail �� Next �Ͳ�Ϊ nil���͵�����
  // ע�������β����ָ������ FGuardTail �ڵ����һ���ڵ㣬β�͵� Next Ӧ���� FGuardTail
  repeat
    P := GetLastNode;
  until CnAtomicCompareAndSet(Pointer(P^.Next), Pointer(Node), FGuardTail);
end;

procedure TCnLockFreeLinkedList.Clear;
var
  P, N: PCnLockFreeLinkedNode;
begin
  P := GetNextNode(FGuardHead);
  while (P <> nil) and (P <> FGuardTail) do
  begin
    N := P;
    P := GetNextNode(P);
    FreeNode(N);
  end;
  FGuardHead := @FHiddenHead;
  FGuardTail := @FHiddenTail;
end;

function TCnLockFreeLinkedList.CompareKey(Key1, Key2: TObject): Integer;
begin
  if Assigned(FCompare) then
    Result := FCompare(Key1, Key2)
  else
    Result := DefaultKeyCompare(Key1, Key2);
end;

constructor TCnLockFreeLinkedList.Create(KeyCompare: TCnLockFreeNodeKeyCompare);
begin
  inherited Create;
  FCompare := KeyCompare;

  FHiddenTail.Key := nil;
  FHiddenTail.Value := nil;
  FHiddenTail.Next := nil;

  FHiddenHead.Key := nil;
  FHiddenHead.Value := nil;
  FHiddenHead.Next := @FHiddenTail;

  FGuardHead := @FHiddenHead;
  FGuardTail := @FHiddenTail;
end;

function TCnLockFreeLinkedList.CreateNode: PCnLockFreeLinkedNode;
begin
  New(Result);
  Result^.Next := nil;
end;

function TCnLockFreeLinkedList.Delete(Key: TObject): Boolean;
var
  R, RN, L: PCnLockFreeLinkedNode;
begin
  Result := False;
  RN := nil;

  while True do
  begin
    InternalSearch(Key, L, R);
    if (R = FGuardTail) or (CompareKey(R^.Key, Key) <> 0) then
      Exit;

    // R ����Ҫ��Ҫɾ�� R���Ȱ� R �� Next ���Ϊ��ɾ��
    RN := R^.Next;
    if not IsNodePointerMarked(RN) then
      if CnAtomicCompareAndSet(Pointer(R^.Next), GetMarkedNodePointer(RN), RN) then
        Break;
  end;

  // �ٰ� L �� Next �ҵ� R �� Next
  if not CnAtomicCompareAndSet(Pointer(L^.Next), RN, R) then
    InternalSearch(R^.Key, L, R); // Ȼ��ɾ R
  Result := True;
end;

destructor TCnLockFreeLinkedList.Destroy;
begin
  Clear;
  inherited;
end;

function TCnLockFreeLinkedList.ExtractRealNodePointer(
  Node: PCnLockFreeLinkedNode): PCnLockFreeLinkedNode;
begin
  Result := PCnLockFreeLinkedNode(TCnNativeUInt(Node) and TCnNativeUInt(not 1));
end;

procedure TCnLockFreeLinkedList.FreeNode(Node: PCnLockFreeLinkedNode);
begin
  if Node <> nil then
    Dispose(Node);
end;

function TCnLockFreeLinkedList.GetCount: Integer;
var
  P: PCnLockFreeLinkedNode;
begin
  Result := 0;
  P := GetNextNode(FGuardHead);
  while (P <> nil) and (P <> FGuardTail) do
  begin
    Inc(Result);
    P := GetNextNode(P);
  end;
end;

function TCnLockFreeLinkedList.GetLastNode: PCnLockFreeLinkedNode;
begin
  Result := FGuardHead;
  while (Result^.Next <> nil) and (Result^.Next <> FGuardTail) do
    Result := Result^.Next;
end;

function TCnLockFreeLinkedList.GetNextNode(
  Node: PCnLockFreeLinkedNode): PCnLockFreeLinkedNode;
begin
  Result := ExtractRealNodePointer(Node^.Next);
end;

function TCnLockFreeLinkedList.HasKey(Key: TObject; out Value: TObject): Boolean;
var
  L, R: PCnLockFreeLinkedNode;
begin
  InternalSearch(Key, L, R);
  if (R = FGuardTail) or (R^.Key <> Key) then
  begin
    Value := nil;
    Result := False;
  end
  else
  begin
    Value := R^.Value;
    Result := True;
  end;
end;

procedure TCnLockFreeLinkedList.InternalSearch(Key: TObject; var LeftNode,
  RightNode: PCnLockFreeLinkedNode);
var
  T, TN, L: PCnLockFreeLinkedNode;
begin
  L := nil;
  while True do
  begin
    T := FGuardHead;
    TN := T^.Next;

    // �����ڵ㣬�����õ����ҽڵ�
    repeat
      if not IsNodePointerMarked(TN) then
      begin
        LeftNode := T;
        L := TN;
      end;

      T := ExtractRealNodePointer(TN);
      if T = FGuardTail then
        Break;

      TN := T^.Next;
    until (not IsNodePointerMarked(TN)) and (CompareKey(T^.Key, Key) >= 0);
    RightNode := T;

    // ��� LeftNode �� RightNode �Ƿ����ڣ����� L �� LeftNode ����һ���ڵ㣬
    if L = RightNode then
    begin
      // ����ҽڵ���¸��ڵ㱻����ˣ�Ҫ����
      if (RightNode <> FGuardTail) and IsNodePointerMarked(RightNode^.Next) then
        Continue
      else
      begin
        Exit;
      end;
    end;

    // ������Ļ�˵�� L �� RightNode ��һ�����м��б�ǹ��Ľڵ㣬����ɾ����ǹ��Ľڵ� L���� LeftNode �� Next ָ�� Right
    if CnAtomicCompareAndSet(Pointer(LeftNode^.Next), RightNode, L) then
    begin
      FreeNode(L);
      if (RightNode <> FGuardTail) and IsNodePointerMarked(RightNode^.Next) then
        Continue
      else
      begin
        Exit;
      end;
    end;
  end;
end;

function TCnLockFreeLinkedList.IsNodePointerMarked(
  Node: PCnLockFreeLinkedNode): Boolean;
begin
  Result := (TCnNativeUInt(Node) and 1) <> 0;
end;

function TCnLockFreeLinkedList.GetMarkedNodePointer(
  Node: PCnLockFreeLinkedNode): PCnLockFreeLinkedNode;
begin
  Result := PCnLockFreeLinkedNode(TCnNativeUInt(Node) or 1);
end;

function TCnLockFreeLinkedList.Insert(Key, Value: TObject): Boolean;
var
  L, R, N: PCnLockFreeLinkedNode;
begin
  Result := False;
  N := nil;

  while True do
  begin
    InternalSearch(Key, L, R);
    if (R <> FGuardTail) and (CompareKey(R^.Key, Key) = 0) then
      Exit; // Key �Ѵ���

    FreeNode(N);
    N := CreateNode;
    N^.Next := R;
    N^.Key := Key;
    N^.Value := Value;

    if CnAtomicCompareAndSet(Pointer(L^.Next), N, R) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TCnLockFreeLinkedList.Travel;
var
  P: PCnLockFreeLinkedNode;
begin
  P := GetNextNode(FGuardHead);
  while (P <> nil) and (P <> FGuardTail) do
  begin
    DoTravelNode(P);
    P := GetNextNode(P);
  end;
end;

procedure TCnLockFreeLinkedList.DoTravelNode(Node: PCnLockFreeLinkedNode);
begin
  if Assigned(FOnTravelNode) then
    FOnTravelNode(Self, Node);
end;

function TCnLockFreeLinkedList.RemoveTail(out Key, Value: TObject): Boolean;
var
  P1, P2, RN: PCnLockFreeLinkedNode;
begin
  Result := False;
  RN := nil;

  while True do
  begin
    if not GetLast2Nodes(P1, P2) then
      Exit;

    RN := P2^.Next;
    if not IsNodePointerMarked(RN) then
      if CnAtomicCompareAndSet(Pointer(P2^.Next), GetMarkedNodePointer(RN), RN) then
        Break;
  end;

  Key := P2^.Key;
  Value := P2^.Value;

  if not CnAtomicCompareAndSet(Pointer(P1^.Next), RN, P2) then
    InternalSearch(P2^.Key, P1, P2);
  Result := True;
end;

function TCnLockFreeLinkedList.GetLast2Nodes(out P1,
  P2: PCnLockFreeLinkedNode): Boolean;
var
  T, TN, L: PCnLockFreeLinkedNode;
begin
  Result := False;
  if FGuardHead^.Next = FGuardTail then
    Exit;

  L := nil;
  while True do
  begin
    T := FGuardHead;
    P1 := T;
    TN := T^.Next;

    // �����ڵ㣬�����õ����ҽڵ�
    repeat
      if not IsNodePointerMarked(TN) then
      begin
        P1 := T;
        L := TN;
      end;

      T := ExtractRealNodePointer(TN);
      if T^.Next = FGuardTail then
        Break;

      TN := T^.Next;
    until False;
    P2 := T;

    // ��� LeftNode �� RightNode �Ƿ�����
    if L = P2 then
    begin
      // ����ҽڵ���¸��ڵ㱻����ˣ�Ҫ����
      if (P2 <> FGuardTail) and IsNodePointerMarked(P2^.Next) then
        Continue
      else
      begin
        Result := True;
        Exit;
      end;
    end;

    // ɾ����ǹ��Ľڵ�
    if CnAtomicCompareAndSet(Pointer(P1^.Next), P2, L) then
    begin
      if (P2 <> FGuardTail) and IsNodePointerMarked(P2^.Next) then
        Continue
      else
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

{ TCnLockFreeSingleRingQueue }

constructor TCnLockFreeSingleRingQueue.Create(ASize: Integer);
begin
  if ASize <= 0 then
    ASize := CN_RING_QUEUE_DEFAULT_CAPACITY;

  FSize := GetUInt32PowerOf2GreaterEqual(ASize);
  if FSize <= 1 then
    FSize := CN_RING_QUEUE_DEFAULT_CAPACITY;

  SetLength(FNodes, FSize);
  FHead := 0;
  FTail := 0;
end;

function TCnLockFreeSingleRingQueue.Dequeue(out Key, Value: TObject): Boolean;
var
  Idx: Integer;
begin
  // �ȳ������ٸ� Tail
  Result := False;
  if not IsEmpty then
  begin
    Idx := GetIndex(FTail + 1);
    Key := FNodes[Idx].Key;
    Value := FNodes[Idx].Value;

    Inc(FTail);
    Result := True;
  end;
end;

destructor TCnLockFreeSingleRingQueue.Destroy;
begin
  SetLength(FNodes, 0);
  inherited;
end;

function TCnLockFreeSingleRingQueue.Enqueue(Key, Value: TObject): Boolean;
var
  Idx: Integer;
begin
  // �Ƚ������ٸ� Head
  Result := False;
  if not IsFull then
  begin
    Idx := GetIndex(FHead + 1);
    FNodes[Idx].Key := Key;
    FNodes[Idx].Value := Value;

    Inc(FHead);
    Result := True;
  end;
end;

function TCnLockFreeSingleRingQueue.GetCount: Integer;
begin
  Result := FHead - FTail;
end;

function TCnLockFreeSingleRingQueue.GetIndex(Seq: Cardinal): Integer;
begin
  Result := Seq and (FSize - 1);
end;

function TCnLockFreeSingleRingQueue.IsEmpty: Boolean;
begin
  Result := (GetIndex(FHead) = GetIndex(FTail));
end;

function TCnLockFreeSingleRingQueue.IsFull: Boolean;
begin
  Result := (GetIndex(FHead) = GetIndex(FTail - 1));
end;

{ TCnLockFreeLinkedStack }

function TCnLockFreeLinkedStack.Pop(out Key, Value: TObject): Boolean;
begin
  Result := RemoveTail(Key, Value);
end;

procedure TCnLockFreeLinkedStack.Push(Key, Value: TObject);
begin
  Append(Key, Value);
end;

end.
