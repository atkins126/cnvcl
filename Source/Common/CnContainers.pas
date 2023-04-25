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

unit CnContainers;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ��������ʵ��
* ��Ԫ���ߣ�С��
* ��    ע���򵥵���������࣬��βPush����ͷPop�����������Ƕ��󣨱�ת����ָ�룩��
*           ����ʱ�ڲ��л�����ƣ��������ⲿͨ���ٽ������⡣�������ӣ�
*           ������
*           var
*             Q: TCnQueue;
*
*           ������
*             Q := TCnQueue.Create;
*            
*           ʹ�ã�
*
*           var
*             TmpObj: TObject;
*           begin
*             TmpObj := TObject.Create;
*             Q.Push(Data); // �������β
*           end;
*            
*           var
*             TmpObj: TObject;
*           begin
*             TmpObj := TObject(Q.Pop); // �Ӷ���ͷ��ȡ��
*             TmpObj.Free;
*           end;
*
*           �ͷţ�
*             Q.Free;
* ����ƽ̨��PWinXP + Delphi 7
* ���ݲ��ԣ�PWin2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2020.11.05 V1.3
*               �������ػ����ȡ���˴�
*           2017.01.17 V1.2
*               ���� TCnObjectRingBuffer ѭ��������ʵ��
*           2016.12.02 V1.1
*               ���� TCnObjectStack ʵ�֣����� Clear �ȷ���
*           2008.04.30 V1.0
*               С���ԭʼ������ֲ������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs, SyncObjs
  {$IFDEF POSIX}, System.Generics.Collections {$ENDIF};

{$DEFINE MULTI_THREAD} // ��ѧ�����֧�ֶ��̣߳����������½����粻��Ҫ��ע�ʹ��м���

type
  TCnQueue = class
  private
    FMultiThread: Boolean;
    FHead: TObject;
    FTail: TObject;
    FSize: Integer;
    FLock: TCriticalSection;
    procedure FreeNode(Value: TObject);
    function GetSize: Integer;
  public
    constructor Create(MultiThread: Boolean = False);
    destructor Destroy; override;
    procedure Push(Data: Pointer);
    function Pop: Pointer;
    property Size: Integer read GetSize;
  end;

  TCnObjectStack = class(TObject)
  private
    FList: TList;
  public
    constructor Create;
    destructor Destroy; override;

    function Count: Integer;
    function IsEmpty: Boolean;
    procedure Clear;

    procedure Push(AObject: TObject);
    function Pop: TObject;
    function Peek: TObject;
  end;

  ECnRingBufferFullException = class(Exception);

  ECnRingBufferEmptyException = class(Exception);

  TCnObjectRingBuffer = class(TObject)
  {* ѭ�����л�����}
  private
    FFullOverwrite: Boolean;
    FMultiThread: Boolean;
    FSize: Integer;
    FList: TList;
    FLock: TCriticalSection;
    // Idx �������Ϊʼ��ָ������λ���м�ķ죬��Ŵӵ� 0 ���� Size - 1 ( �� Size Ҳ�����ڵ� 0 )
    // ��Ԫ�ص�����£�FrontIdx �ߺ�ʼ����Ԫ�أ�ǰ�����ǿգ����ƻ�����β��
    //                 BackIdx �ĵ�ǰʼ����Ԫ�أ�������ǿգ����ƻ�����ͷ
    // ��Ԫ�ص�����£�FrontIdx �� BackIdx ���
    FFrontIdx: Integer;
    FBackIdx: Integer;
    FCount: Integer;
    function GetCount: Integer;
  public
    constructor Create(ASize: Integer; AFullOverwrite: Boolean = False;
      AMultiThread: Boolean = False);
    {* ���캯����ASize �ǻ�����������AFullOverwrite �Ƿ���������������������ʱ
      ������ǰ�����ݣ�AMultiThread �Ƿ���Ҫ���̻߳���}
    destructor Destroy; override;
    {* ��������}

    procedure PushToFront(AObject: TObject);
    {* ��ѭ�����л�����ǰ������һ�� Object��ǰ����ָ�ڲ��洢�����͵�һ�ˣ������Ҳ������������쳣}
    function PopFromBack: TObject;
    {* ��ѭ�����л������󷽵���һ�� Object������ָ�ڲ��洢�����ߵ�һ�ˣ��޿ɵ������쳣}

    procedure PushToBack(AObject: TObject);
    {* ��ѭ�����л�����������һ�� Object������ָ�ڲ��洢�����ߵ�һ�ˣ������Ҳ������������쳣}
    function PopFromFront: TObject;
    {* ��ѭ�����л�����ǰ������һ�� Object��ǰ����ָ�ڲ��洢�����͵�һ�ˣ��޿ɵ������쳣}

    procedure Dump(List: TList; out FrontIdx: Integer; out BackIdx: Integer);
    {* ��ȫ�����ݵ�����һ TList���Լ�ָ��λ��}

    property FullOverwrite: Boolean read FFullOverwrite;
    {* ��ѭ�����л�������ʱ�Ƿ������Ǿ�����}
    property MultiThread: Boolean read FMultiThread;
    {* ��ѭ�����л������Ƿ���Ҫ֧�ֶ��̲߳������ʣ�Ϊ True ʱ�ڲ����ٽ�������}
    property Size: Integer read FSize;
    {* ��ѭ�����л������ĳߴ�}
    property Count: Integer read GetCount;
    {* ��ѭ�����л������ڵ���ЧԪ������}
  end;

  TCnMathObjectPool = class(TObjectList)
  {* ��ѧ�����ʵ���࣬����ʹ�õ���ѧ����صĵط����м̳в�������}
  private
{$IFDEF MULTI_THREAD}
    FCriticalSection: TCriticalSection;
{$ENDIF}
    procedure Enter; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    procedure Leave; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  protected
    function CreateObject: TObject; virtual; abstract;
    {* ����������صĴ����������ķ���}
  public
    constructor Create; reintroduce;

    destructor Destroy; override;

    function Obtain: TObject;
    procedure Recycle(Num: TObject);
  end;

  TCnIntegerList = class(TList)
  {* �����б�}
  private
    function Get(Index: Integer): Integer;
    procedure Put(Index: Integer; const Value: Integer);
  public
    function Add(Item: Integer): Integer; reintroduce;
    procedure Insert(Index: Integer; Item: Integer); reintroduce;
    property Items[Index: Integer]: Integer read Get write Put; default;
  end;

  PInt64List = ^TInt64List;
  TInt64List = array[0..MaxListSize - 1] of Int64;

  TCnInt64List = class(TObject)
  {* 64 λ�����б�}
  private
    FList: PInt64List;
    FCount: Integer;
    FCapacity: Integer;
  protected
    function Get(Index: Integer): Int64;
    procedure Grow; virtual;
    procedure Put(Index: Integer; Item: Int64);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  public
    destructor Destroy; override;
    function Add(Item: Int64): Integer;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    procedure DeleteLow(ACount: Integer);
    {* ����������ɾ�� ACount ����Ͷ�Ԫ�أ���� Count ������ɾ�� Count ��}
    class procedure Error(const Msg: string; Data: Integer); virtual;
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TCnInt64List;
    function First: Int64;
    function IndexOf(Item: Int64): Integer;
    procedure Insert(Index: Integer; Item: Int64);
    procedure InsertBatch(Index: Integer; ACount: Integer);
    {* ������������ĳλ����������ȫ 0 ֵ ACount ��}
    function Last: Int64;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Int64): Integer;

    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: Int64 read Get write Put; default;
    property List: PInt64List read FList;
  end;

  PRefObjectList = ^TRefObjectList;
  TRefObjectList = array[0..MaxListSize - 1] of TObject;

  TCnRefObjectList = class(TObject)
  {* ���������б������� TObjectList ���� Own ����}
  private
    FList: PRefObjectList;
    FCount: Integer;
    FCapacity: Integer;
  protected
    function Get(Index: Integer): TObject;
    procedure Grow; virtual;
    procedure Put(Index: Integer; Item: TObject);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  public
    destructor Destroy; override;
    function Add(Item: TObject): Integer;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    procedure DeleteLow(ACount: Integer);
    {* ����������ɾ�� ACount ����Ͷ�Ԫ�أ���� Count ������ɾ�� Count ��}
    class procedure Error(const Msg: string; Data: Integer); virtual;
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TCnRefObjectList;
    function First: TObject;
    function IndexOf(Item: TObject): Integer;
    procedure Insert(Index: Integer; Item: TObject);
    procedure InsertBatch(Index: Integer; ACount: Integer);
    {* ������������ĳλ����������ȫ 0 ֵ ACount ��}
    function Last: TObject;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: TObject): Integer;

    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: TObject read Get write Put; default;
    property List: PRefObjectList read FList;
  end;

{$IFDEF POSIX}

  // MACOS/LINUX ��ƽ̨�µ� TList û�� IgnoreDuplicated ���ܣ���Ҫ�ֹ�ȥ��
  TCnInternalList<T> = class(TList<T>)
  public
    procedure RemoveDuplictedElements;
  end;

{$ENDIF}

procedure CnIntegerListCopy(Dst, Src: TCnIntegerList);
{* ���� TCnIntegerList}

procedure CnInt64ListCopy(Dst, Src: TCnInt64List);
{* ���� TCnInt64List}

procedure CnRefObjectListCopy(Dst, Src: TCnRefObjectList);
{* ���� TCnRefObjectList}

implementation

uses
  CnNative;

resourcestring
  SCnInt64ListError = 'Int64 List Error. %d';
  SCnRefObjectListError = 'Reference Object List Error. %d';
  SCnEmptyPopFromBackError = 'Ring Buffer Empty. Can NOT Pop From Back.';
  SCnEmptyPopFromFrontError = 'Ring Buffer Empty. Can NOT Pop From Front.';
  SCnFullPushToBackError = 'Ring Buffer Full. Can NOT Push To Back.';
  SCnFullPushToFrontError = 'Ring Buffer Full. Can NOT Push To Front.';

type
  TCnNode = class
  private
    FNext: TCnNode;
    FData: Pointer;
  public
    property Next: TCnNode read FNext write FNext;
    property Data: Pointer read FData write FData;
  end;

{ TCnQueue }

procedure TCnQueue.FreeNode(Value: TObject);
var
  Tmp: TCnNode;
begin
  Tmp := TCnNode(Value).Next;
  TCnNode(Value).Free;
  if Tmp = nil then
    Exit;
  FreeNode(Tmp);
end;

constructor TCnQueue.Create(MultiThread: Boolean);
begin
  FMultiThread := MultiThread;
  FHead := nil;
  FTail := nil;
  FSize := 0;
  if FMultiThread then
    FLock := TCriticalSection.Create;
end;

destructor TCnQueue.Destroy;
begin
  if FHead <> nil then
    FreeNode(FHead);
  if FMultiThread then
    FLock.Free;
  inherited;
end;

function TCnQueue.Pop: Pointer;
var
  Tmp: TCnNode;
begin
  if FMultiThread then
    FLock.Enter;

  try
    Result := nil;
    if FHead = nil then
      Exit;

    Result := TCnNode(FHead).Data;
    Tmp := TCnNode(FHead).Next;
    TCnNode(FHead).Free;
    FHead := Tmp;
    
    if Tmp = nil then
      FTail := nil;
    FSize := FSize - 1;
  finally
    if FMultiThread then
      FLock.Leave;
  end;
end;

procedure TCnQueue.Push(Data: Pointer);
var
  Tmp: TCnNode;
begin
  if FMultiThread then
    FLock.Enter;

  try
    if Data = nil then Exit;
    Tmp := TCnNode.Create;
    Tmp.Data := Data;
    Tmp.Next := nil;
    
    if FTail = nil then
    begin
      FTail := Tmp;
      FHead := Tmp;
    end
    else
    begin
      TCnNode(FTail).Next := Tmp;
      FTail := Tmp
    end;
    
    FSize := FSize + 1;
  finally
    if FMultiThread then
      FLock.Leave;
  end;
end;

function TCnQueue.GetSize: Integer;
begin
  Result := FSize;
end;

{ TCnObjectStack }

procedure TCnObjectStack.Clear;
begin
  FList.Clear;
end;

function TCnObjectStack.Count: Integer;
begin
  Result := FList.Count;
end;

constructor TCnObjectStack.Create;
begin
  FList := TList.Create;
end;

destructor TCnObjectStack.Destroy;
begin
  FList.Free;
  inherited;
end;

function TCnObjectStack.IsEmpty: Boolean;
begin
  Result := FList.Count = 0;
end;

function TCnObjectStack.Peek: TObject;
begin
  Result := TObject(FList[FList.Count - 1]);
end;

function TCnObjectStack.Pop: TObject;
begin
  Result := TObject(FList[FList.Count - 1]);
  FList.Delete(FList.Count - 1);
end;

procedure TCnObjectStack.Push(AObject: TObject);
begin
  FList.Add(AObject);
end;

{ TCnRingBuffer }

constructor TCnObjectRingBuffer.Create(ASize: Integer; AFullOverwrite,
  AMultiThread: Boolean);
begin
  Assert(ASize > 0);

  FSize := ASize;
  FFullOverwrite := AFullOverwrite;
  FMultiThread := AMultiThread;

  FList := TList.Create;
  FList.Count := FSize;

  if FMultiThread then
    FLock := TCriticalSection.Create;
end;

destructor TCnObjectRingBuffer.Destroy;
begin
  if FMultiThread then
    FLock.Free;
  FList.Free;
  inherited;
end;

procedure TCnObjectRingBuffer.Dump(List: TList; out FrontIdx: Integer;
  out BackIdx: Integer);
var
  I: Integer;
begin
  FrontIdx := FFrontIdx;
  BackIdx := FBackIdx;
  if List <> nil then
  begin
    List.Clear;
    for I := 0 to FList.Count - 1 do
      List.Add(FList[I]);
  end;
end;

function TCnObjectRingBuffer.GetCount: Integer;
begin
  Result := FCount;
end;

{$HINTS OFF}

function TCnObjectRingBuffer.PopFromBack: TObject;
begin
  Result := nil;  // ������Ͱ汾 Delphi �о��棬����߰汾 Delphi �о���
  if FMultiThread then
    FLock.Enter;

  try
    if FCount <= 0 then
      raise ECnRingBufferEmptyException.Create(SCnEmptyPopFromBackError);

    Dec(FBackIdx);
    if FBackIdx < 0 then
      FBackIdx := FSize - 1;
    Result := TObject(FList[FBackIdx]);
    FList[FBackIdx] := nil;
    Dec(FCount);
  finally
    if FMultiThread then
      FLock.Leave;
  end;
end;

function TCnObjectRingBuffer.PopFromFront: TObject;
begin
  Result := nil; // ������Ͱ汾 Delphi �о��棬����߰汾 Delphi �о���
  if FMultiThread then
    FLock.Enter;

  try
    if FCount <= 0 then
      raise ECnRingBufferEmptyException.Create(SCnEmptyPopFromFrontError);

    Result := TObject(FList[FFrontIdx]);
    FList[FFrontIdx] := nil;

    Inc(FFrontIdx);
    if FFrontIdx >= FSize then
      FFrontIdx := 0;
    Dec(FCount);
  finally
    if FMultiThread then
      FLock.Leave;
  end;
end;

{$HINTS ON}

procedure TCnObjectRingBuffer.PushToBack(AObject: TObject);
begin
  if FMultiThread then
    FLock.Enter;

  try
    if not FFullOverwrite and (FCount >= FSize) then
      raise ECnRingBufferFullException.Create(SCnFullPushToBackError);

    FList[FBackIdx] := AObject;
    Inc(FBackIdx);
    if FBackIdx >= FSize then
      FBackIdx := 0;

    if FCount < FSize then
      Inc(FCount);
  finally
    if FMultiThread then
      FLock.Leave;
  end;
end;

procedure TCnObjectRingBuffer.PushToFront(AObject: TObject);
begin
  if FMultiThread then
    FLock.Enter;

  try
    if not FFullOverwrite and (FCount >= FSize) then
      raise ECnRingBufferFullException.Create(SCnFullPushToFrontError);

    Dec(FFrontIdx);
    if FFrontIdx < 0 then
      FFrontIdx := FSize - 1;
    FList[FFrontIdx] := AObject;

    if FCount < FSize then
      Inc(FCount);
  finally
    if FMultiThread then
      FLock.Leave;
  end;
end;

{ TCnMathObjectPool }

constructor TCnMathObjectPool.Create;
begin
  inherited Create(False);
{$IFDEF MULTI_THREAD}
  FCriticalSection := TCriticalSection.Create;
{$ENDIF}
end;

destructor TCnMathObjectPool.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TObject(Items[I]).Free;

{$IFDEF MULTI_THREAD}
  FCriticalSection.Free;
{$ENDIF}
  inherited;
end;

procedure TCnMathObjectPool.Enter;
begin
{$IFDEF MULTI_THREAD}
  FCriticalSection.Enter;
{$ENDIF}
end;

procedure TCnMathObjectPool.Leave;
begin
{$IFDEF MULTI_THREAD}
  FCriticalSection.Leave;
{$ENDIF}
end;

function TCnMathObjectPool.Obtain: TObject;
begin
  Enter;
  try
    if Count = 0 then
      Result := CreateObject
    else
    begin
      Result := TObject(Items[Count - 1]);
      Delete(Count - 1);
    end;
  finally
    Leave;
  end;
end;

procedure TCnMathObjectPool.Recycle(Num: TObject);
begin
  if Num <> nil then
  begin
    Enter;
    try
      Add(Num);
    finally
      Leave;
    end;
  end;
end;

{ TCnIntegerList }

function TCnIntegerList.Add(Item: Integer): Integer;
begin
  Result := inherited Add(IntegerToPointer(Item));
end;

function TCnIntegerList.Get(Index: Integer): Integer;
begin
  Result := PointerToInteger(inherited Get(Index));
end;

procedure TCnIntegerList.Insert(Index, Item: Integer);
begin
  inherited Insert(Index, IntegerToPointer(Item));
end;

procedure TCnIntegerList.Put(Index: Integer; const Value: Integer);
begin
  inherited Put(Index, IntegerToPointer(Value));
end;

{ TCnInt64List }

destructor TCnInt64List.Destroy;
begin
  Clear;
end;

function TCnInt64List.Add(Item: Int64): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TCnInt64List.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TCnInt64List.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnInt64ListError, Index);

  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Int64));
end;

procedure TCnInt64List.DeleteLow(ACount: Integer);
begin
  if ACount > 0 then
  begin
    if ACount >= FCount then
      Clear
    else
    begin
      Dec(FCount, ACount);

      // �� 0 ɾ���� ACount - 1��Ҳ���ǰ� ACount �� Count - 1 ���� Move �� 0
      System.Move(FList^[ACount], FList^[0],
        FCount * SizeOf(Int64));
    end;
  end;
end;

class procedure TCnInt64List.Error(const Msg: string; Data: Integer);
begin
  raise EListError.CreateFmt(Msg, [Data]);
end;

procedure TCnInt64List.Exchange(Index1, Index2: Integer);
var
  Item: Int64;
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    Error(SCnInt64ListError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then
    Error(SCnInt64ListError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TCnInt64List.Expand: TCnInt64List;
begin
  if FCount = FCapacity then
    Grow;
  Result := Self;
end;

function TCnInt64List.First: Int64;
begin
  Result := Get(0);
end;

function TCnInt64List.Get(Index: Integer): Int64;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnInt64ListError, Index);
  Result := FList^[Index];
end;

procedure TCnInt64List.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TCnInt64List.IndexOf(Item: Int64): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do
    Inc(Result);
  if Result = FCount then
    Result := -1;
end;

procedure TCnInt64List.Insert(Index: Integer; Item: Int64);
begin
  if (Index < 0) or (Index > FCount) then
    Error(SCnInt64ListError, Index);
  if FCount = FCapacity then
    Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(Int64));
  FList^[Index] := Item;
  Inc(FCount);
end;

procedure TCnInt64List.InsertBatch(Index, ACount: Integer);
begin
  if ACount <= 0 then
    Exit;

  if (Index < 0) or (Index > FCount) then
    Error(SCnInt64ListError, Index);
  SetCapacity(FCount + ACount); // �������������� FCount + ACount��FCount û��

  System.Move(FList^[Index], FList^[Index + ACount],
    (FCount - Index) * SizeOf(Int64));
  System.FillChar(FList^[Index], ACount * SizeOf(Int64), 0);
  FCount := FCount + ACount;
end;

function TCnInt64List.Last: Int64;
begin
  Result := Get(FCount - 1);
end;

procedure TCnInt64List.Move(CurIndex, NewIndex: Integer);
var
  Item: Int64;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then
      Error(SCnInt64ListError, NewIndex);
    Item := Get(CurIndex);
    FList^[CurIndex] := 0;
    Delete(CurIndex);
    Insert(NewIndex, 0);
    FList^[NewIndex] := Item;
  end;
end;

procedure TCnInt64List.Put(Index: Integer; Item: Int64);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnInt64ListError, Index);

  FList^[Index] := Item;
end;

function TCnInt64List.Remove(Item: Int64): Integer;
begin
  Result := IndexOf(Item);
  if Result >= 0 then
    Delete(Result);
end;

procedure TCnInt64List.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SCnInt64ListError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Int64));
    FCapacity := NewCapacity;
  end;
end;

procedure TCnInt64List.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SCnInt64ListError, NewCount);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Int64), 0)
  else
    for I := FCount - 1 downto NewCount do
      Delete(I);
  FCount := NewCount;
end;

{ TCnRefObjectList }

destructor TCnRefObjectList.Destroy;
begin
  Clear;
end;

function TCnRefObjectList.Add(Item: TObject): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TCnRefObjectList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TCnRefObjectList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnRefObjectListError, Index);

  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(TObject));
end;

procedure TCnRefObjectList.DeleteLow(ACount: Integer);
begin
  if ACount > 0 then
  begin
    if ACount >= FCount then
      Clear
    else
    begin
      Dec(FCount, ACount);

      // �� 0 ɾ���� ACount - 1��Ҳ���ǰ� ACount �� Count - 1 ���� Move �� 0
      System.Move(FList^[ACount], FList^[0],
        FCount * SizeOf(TObject));
    end;
  end;
end;

class procedure TCnRefObjectList.Error(const Msg: string; Data: Integer);
begin
  raise EListError.CreateFmt(Msg, [Data]);
end;

procedure TCnRefObjectList.Exchange(Index1, Index2: Integer);
var
  Item: TObject;
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    Error(SCnRefObjectListError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then
    Error(SCnRefObjectListError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TCnRefObjectList.Expand: TCnRefObjectList;
begin
  if FCount = FCapacity then
    Grow;
  Result := Self;
end;

function TCnRefObjectList.First: TObject;
begin
  Result := Get(0);
end;

function TCnRefObjectList.Get(Index: Integer): TObject;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnRefObjectListError, Index);
  Result := FList^[Index];
end;

procedure TCnRefObjectList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TCnRefObjectList.IndexOf(Item: TObject): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do
    Inc(Result);
  if Result = FCount then
    Result := -1;
end;

procedure TCnRefObjectList.Insert(Index: Integer; Item: TObject);
begin
  if (Index < 0) or (Index > FCount) then
    Error(SCnRefObjectListError, Index);
  if FCount = FCapacity then
    Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(TObject));
  FList^[Index] := Item;
  Inc(FCount);
end;

procedure TCnRefObjectList.InsertBatch(Index, ACount: Integer);
begin
  if ACount <= 0 then
    Exit;

  if (Index < 0) or (Index > FCount) then
    Error(SCnRefObjectListError, Index);
  SetCapacity(FCount + ACount); // �������������� FCount + ACount��FCount û��

  System.Move(FList^[Index], FList^[Index + ACount],
    (FCount - Index) * SizeOf(TObject));
  System.FillChar(FList^[Index], ACount * SizeOf(TObject), 0);
  FCount := FCount + ACount;
end;

function TCnRefObjectList.Last: TObject;
begin
  Result := Get(FCount - 1);
end;

procedure TCnRefObjectList.Move(CurIndex, NewIndex: Integer);
var
  Item: TObject;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then
      Error(SCnRefObjectListError, NewIndex);
    Item := Get(CurIndex);
    FList^[CurIndex] := nil;
    Delete(CurIndex);
    Insert(NewIndex, nil);
    FList^[NewIndex] := Item;
  end;
end;

procedure TCnRefObjectList.Put(Index: Integer; Item: TObject);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SCnRefObjectListError, Index);

  FList^[Index] := Item;
end;

function TCnRefObjectList.Remove(Item: TObject): Integer;
begin
  Result := IndexOf(Item);
  if Result >= 0 then
    Delete(Result);
end;

procedure TCnRefObjectList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SCnRefObjectListError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(TObject));
    FCapacity := NewCapacity;
  end;
end;

procedure TCnRefObjectList.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SCnRefObjectListError, NewCount);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(TObject), 0)
  else
    for I := FCount - 1 downto NewCount do
      Delete(I);
  FCount := NewCount;
end;

procedure CnIntegerListCopy(Dst, Src: TCnIntegerList);
begin
  if (Src <> nil) and (Dst <> nil) and (Src <> Dst) then
  begin
    Dst.Count := Src.Count;
    if Src.Count > 0 then
    begin
{$IFDEF LIST_NEW_POINTER}
      Move(Src.List[0], Dst.List[0], Src.Count * SizeOf(Integer));
{$ELSE}
      Move(Src.List^, Dst.List^, Src.Count * SizeOf(Integer));
{$ENDIF}
    end;
  end;
end;

procedure CnInt64ListCopy(Dst, Src: TCnInt64List);
begin
  if (Src <> nil) and (Dst <> nil) and (Src <> Dst) then
  begin
    Dst.Count := Src.Count;
    if Src.Count > 0 then
      Move(Src.List^, Dst.List^, Src.Count * SizeOf(Int64));
  end;
end;

procedure CnRefObjectListCopy(Dst, Src: TCnRefObjectList);
begin
  if (Src <> nil) and (Dst <> nil) and (Src <> Dst) then
  begin
    Dst.Count := Src.Count;
    if Src.Count > 0 then
      Move(Src.List^, Dst.List^, Src.Count * SizeOf(TObject));
  end;
end;

{$IFDEF POSIX}

{ TCnInternalList<T> }

procedure TCnInternalList<T>.RemoveDuplictedElements;
var
  I, J: Integer;
  V: NativeInt;
  Dup: Boolean;
begin
  for I := Count - 1 downto 0 do
  begin
    V := ItemValue(Items[I]);
    Dup := False;
    for J := 0 to I - 1 do
    begin
      if V = ItemValue(Items[J]) then
      begin
        Dup := True;
        Break;
      end;
    end;

    if Dup then
      Delete(I);
  end;
end;

{$ENDIF}

end.
