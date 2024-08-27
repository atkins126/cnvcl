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

unit CnThreadPool;
{* |<PRE>
================================================================================
* ������ƣ������ӹ��������
* ��Ԫ���ƣ��̳߳�ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�Chinbo��Shenloqi��
* ��    ע��֧�� D5 �����°浫��Ӧ�������� Indy �������ֻ���� D7 �����ϱ���
* ����ƽ̨��PWin2000Pro + Delphi 7.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ����ݲ����ϱ��ػ�����ʽ
* �޸ļ�¼��2008.4.1
*               �ҵ��˵�������̳߳ص���Ҫ�ο�ʵ�ֵ�Ԫ��������ԭ����
*                 Aleksej Petrov �İ�Ȩ��Ϣ��������ԭ���Ļ����������˺ܶ�����Ҳ
*                 ��ǿ��һЩ���ܣ����������˼·�ʹ��ʵ�ַ������Ǹ�ԭ����һ����
*                 �ٴθ�л Aleksej Petrov��Ҳ��л Leeon �����ҵ���ԭ������Ϣ
*           2007.7.13
*               �޸��� DeadTaskAsNew �ᵼ�����޵ݹ�Ͳ���Ч�� BUG
*               �����Ҫʹ�� DeadTaskAsNew ����Ҫʵ�� TCnTaskDataObject.Clone ����
*               ������һ�� TCnThreadPool.AddRequests ����
*           2004.8.9
*               ������ TCnPoolingThread.StillWorking
*               �������� TickCount ����� BUG
*           2004.3.14
*               ����һЩ BUG
*           2003.12.24
*               ʹ�� FTaskCount �� FIdleThreadCount �ӿ�ִ��Ч��
*               ������ MinAtLeast ������ȷ������ BUG
*               �� DefaultGetInfo ֮�е��� FreeFinishedThreads
*           2003.12.21
*               ��ɲ����Ե�Ԫ
*           2003.12.16
 *              ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

{********************************************************
  This component is modified from Aleksej Petrov's threadpool, fixed some
  memory leaks and enhanced the scheduling implementation and fixed some bugs.

 {*************************************************************}
 {                                                             }
 {   Component for processing request queue in pool of threads }
 {                                                             }
 {   Copyright (c) 2001, Aleksej Petrov, AKPetrov@pisem.net    }
 {                                                             }
 {    Free for noncommercial use.                              }
 { Please contact with author for use in commercial projects.  }
 {                                                             }
 {*************************************************************}

{********************************************************

    ��Ԫ˵����
        �õ�Ԫʵ�����̳߳صĹ���

    ��ƣ�
        ʵ���̳߳أ�����Ҫ�����������򵥵ľ���ʹ��һ��ָ
      ��ĳһ�ṹ��ָ�룬������������Ȼ����һ���õķ���������
      һ�ֱȽϼ򵥵ķ�������ʹ�ö������˳��������֮�󣬾�
      Ҫ��һ��������Ĺ����б�����Լ򵥵��� TList ʵ�֣�����
      TList ���¼�����һЩ��Ȼ���Ҫ��ִ�д���������̣߳�����
      ��Ҫ�� TThread �̳У�Ȼ��Ҫ��֪ͨ���ƣ�������������ʱ���
      ���㣬����ƽ����ơ�
        ��򵥵�ʵ���ǹ����߳�����һ������֮������ߣ�������
      ��ʹ��һ����ʱ�����ڸ���Щ�߳̽��з��䣬������������
      Ч�ʲ��ߣ�Ҳ���������������ʱ��ͽ���һ�η��䣬������
      ����������������̵߳�������⣬Ч�ʵȶ����ǺõĽ����
      �������ź������ȽϺõĽ��������⡣���̳߳����̵߳�
      �ͷ�����Լ�ͨ����ʱ��ʵ�֡�
        ��������������ι��ƹ��������̳߳صĹ���ǿ�ȣ�Ȼ���
      ����ʱ��Ҫ�����̣߳���ʱ��Ҫ�����߳�:)

    ���ƣ�
        ���ǵ��̳߳ص�ʹ�÷�Χ��������ʵ���в����˲���ֻ����
      NT ϵ�в�ʵ�ֵ� API�����Ը������ NT ϵ�в���ϵͳ�ϻ������
      ��Ч������ȻҲ��֧�ַ� Windows ������
        ��Ϊʹ���� WaitableTimer�������� 9x �������̳߳ز������
      �̳߳��е��߳���Ŀ��Ӧ���ǿ���ͨ�� SetTimer ���������
      SetTimer ��Ҫһ����Ϣѭ������ WM_TIMER ��Ϣ�������ϴ��Ҳ�
      ����ʵ��:)
        ���⻹��һ������ķ������� mmsystem �� timesetevent ����,
      ������������Ŀ���Ӧ�ñ������ĸ���
        �������ͨ�� TTimer ��ʵ�ֵĻ���Ӧ�þͿ���ʵ�ֿ�ƽ̨��
      �����...

    �ڴ�й©��
        һ������¸�����������ڴ�й¶��Ȼ�����̳߳ر��ͷ�ʱ
      �̳߳��л������ڹ������̣߳�����Щ�߳��������ⲿ������
      �ƻ�ʱ��Ϊ���߳��ܹ������˳�������ʹ���� TerminateThread
      ������������������������̷߳�����ڴ棬�Ϳ�������ڴ�
      й¶�����˵�����������һ�㷢����Ӧ�ó����˳�ʱ�ƻ�����
      ���������£�����һ��Ӧ�ó����˳�������ϵͳ������Ӧ����
      ����������ʵ����Ӧ�ò����ڴ�й¶:)
        ��ʹ��ʹ���� TerminateThread��Ҳ��Ӧ�û���ɳ����˳�ʱ
      �������쳣���� RunTime Error 216

    �༰������

      TCnCriticalSection -- �ٽ����ķ�װ
        �� NT ��ʵ���� TryEnterCriticalSection���� SyncObjs.pas ��
      �� TCriticalSection û�з�װ���������TCnCriticalSection
      ��װ��������ֱ�Ӵ� TObject �̳У�����Ӧ��СһЩ:)
        TryEnter -- TryEnterCriticalSection
        TryEnterEx -- 9xʱ�����Enter��NT����TryEnter

      TCnTaskDataObject -- �̳߳��̴߳������ݵķ�װ
        �̳߳��е��̴߳���������������ݵĻ���
        һ������£�Ҫʵ��ĳ���ض����������Ҫʵ����Ӧ��һ��
      �Ӹ���̳е���
        Duplicate -- �Ƿ�����һ������������ͬ����ͬ�򲻴���
        Info -- ��Ϣ�����ڵ������

      TCnPoolingThread -- �̳߳��е��߳�
        �̳߳��е��̵߳Ļ��࣬һ������²���Ҫ�̳и���Ϳ���
      ʵ�ִ󲿷ֵĲ����������߳���ҪһЩ�ⲿ����ʱ���Լ̳и�
      ��Ĺ����������������һ�ַ����ǿ������̳߳ص�����¼�
      �н�����Щ����
        AverageWaitingTime -- ƽ���ȴ�ʱ��
        AverageProcessingTime -- ƽ������ʱ��
        Duplicate -- �Ƿ����ڴ�����ͬ������
        Info -- ��Ϣ�����ڵ������
        IsDead -- �Ƿ�����
        IsFinished -- �Ƿ�ִ�����
        IsIdle -- �Ƿ����
        NewAverage -- ����ƽ��ֵ�������㷨��
        StillWorking -- �����߳���Ȼ������
        Execute -- �߳�ִ�к�����һ�㲻��̳�
        Create -- ���캯��
        Destroy -- ��������
        Terminate -- �����߳�

      TCnThreadPool -- �̳߳�
        �ؼ����¼���û��ʹ��ͬ����ʽ��װ��������Щ�¼��Ĵ���Ҫ�̰߳�ȫ�ſ���
        HasSpareThread -- �п��е��߳�
        AverageWaitingTime -- ƽ���ȴ�ʱ��
        AverageProcessingTime -- ƽ������ʱ��
        TaskCount -- ������Ŀ
        ThreadCount -- �߳���Ŀ
        CheckTaskEmpty -- ��������Ƿ��Ѿ����
        GetRequest -- �Ӷ����л�ȡ����
        DecreaseThreads -- �����߳�
        IncreaseThreads -- �����߳�
        FreeFinishedThreads -- �ͷ���ɵ��߳�
        KillDeadThreads -- ������߳�
        Info -- ��Ϣ�����ڵ������
        OSIsWin9x -- ����ϵͳ��Win9x
        AddRequest -- ��������
        RemoveRequest -- �Ӷ�����ɾ������
        CreateSpecial -- �����Զ����̳߳��̵߳Ĺ��캯��
        AdjustInterval -- �����̵߳�ʱ����
        DeadTaskAsNew -- �����̵߳��������¼ӵ�����
        MinAtLeast -- �߳�����������С��Ŀ
        ThreadDeadTimeout -- �߳�������ʱ
        ThreadsMinCount -- �����߳���
        ThreadsMaxCount -- ����߳���
        OnGetInfo -- ��ȡ��Ϣ�¼�
        OnProcessRequest -- ���������¼�
        OnQueueEmpty -- ���п��¼�
        OnThreadInitializing -- �̳߳�ʼ���¼�
        OnThreadFinalizing -- �߳���ֹ���¼�

********************************************************}

interface

{$I CnPack.inc}

{$IFDEF DEBUG}
  {.$UNDEF DEBUG} //�Ƿ����������Ϣ
{$ENDIF}

uses
  SysUtils, Windows, Classes,
  CnConsts, CnClasses, CnCompConsts;

type
  TCnTaskDataObject = class
  {* ��������̳߳�����ܵ����񣬿��ж��ظ�}
  public
    function Clone: TCnTaskDataObject; virtual; abstract;
    {* ������ʵ�ָ��������ã�����ʵ��}
    function Duplicate(DataObj: TCnTaskDataObject;
      const Processing: Boolean): Boolean; virtual;
    {* �������ж��ظ��ã����ظ���������}
    function Info: string; virtual;
  end;

  { TCnPoolingThread }

  TCnThreadPool = class;

  TCnThreadState = (ctsInitializing, ctsWaiting,
    ctsGetting,
    ctsProcessing, ctsProcessed,
    ctsTerminating, ctsForReduce);

  TCnPoolingThread = class(TThread)
  private
    hInitFinished: THandle;
    sInitError: string;
{$IFDEF DEBUG}
    procedure Trace(const Str: string);
{$ENDIF}
    procedure ForceTerminate;
  protected
    FAverageWaitingTime: Integer;
    FAverageProcessing: Integer;
    FUWaitingStart: DWORD;
    FUProcessingStart: DWORD;
    FUStillWorking: DWORD;
    FWorkCount: Int64;
    FCurState: TCnThreadState;
    FHThreadTerminated: THandle;
    FPool: TCnThreadPool;
    FProcessingDataObject: TCnTaskDataObject; // ����ʱ�ڴ����������󣬴�������ڲ��ͷ�

    FCSProcessingDataObject: TObject; // Hide TCnCriticalSection;

    function AverageProcessingTime: DWORD;
    function AverageWaitingTime: DWORD;
    function CloneData: TCnTaskDataObject;
    function Duplicate(DataObj: TCnTaskDataObject): Boolean; virtual;
    function Info: string; virtual;
    function IsDead: Boolean; virtual;
    {* ��״̬�Ƿ������˵��жϣ��Ա��ⲿ Kill}
    function IsFinished: Boolean; virtual;
    function IsIdle: Boolean; virtual;
    function NewAverage(OldAvg, NewVal: Integer): Integer; virtual;

    procedure Execute; override;
  public
    constructor Create(aPool: TCnThreadPool); virtual;
    destructor Destroy; override;

    procedure StillWorking;
    procedure Terminate(const Force: Boolean = False);
  end;

  TCnPoolingThreadClass = class of TCnPoolingThread;

  { TCnThreadPool }

  TCnCheckDuplicate = (cdQueue, cdProcessing);
  TCnCheckDuplicates = set of TCnCheckDuplicate;
  {* ��ӵ��������ظ���Ҫ��δ����ֱ����������ظ���ɾ�����������ظ���ɾ��}

  TCnThreadPoolGetInfo = procedure(Sender: TCnThreadPool;
    var InfoText: string) of object;
  TCnThreadPoolProcessRequest = procedure(Sender: TCnThreadPool;
    DataObj: TCnTaskDataObject; Thread: TCnPoolingThread) of object;

  TCnPoolEmptyKind = (ekQueueEmpty, ekTaskEmpty);
  TCnQueueEmpty = procedure(Sender: TCnThreadPool;
    EmptyKind: TCnPoolEmptyKind) of object;

  TCnThreadInPoolInitializing = procedure(Sender: TCnThreadPool;
    Thread: TCnPoolingThread) of object;
  TCnThreadInPoolFinalizing = procedure(Sender: TCnThreadPool;
    Thread: TCnPoolingThread) of object;

{$IFDEF SUPPORT_32_AND_64}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF}
  TCnThreadPool = class(TCnComponent)
  private
    FCSQueueManagment: TObject; // Hide TCnCriticalSection;
    FCSThreadManagment: TObject; // Hide TCnCriticalSection;

    FQueue: TList;
    FThreads: TList;             // �����̶߳����б�
    FThreadsKilling: TList;      // ���̶߳����б�
    FThreadsMinCount, FThreadsMaxCount: Integer;
    FThreadDeadTimeout: DWORD;
    FThreadClass: TCnPoolingThreadClass;
    FAdjustInterval: DWORD;
    FDeadTaskAsNew: Boolean;
    FMinAtLeast: Boolean;
    FIdleThreadCount, FTaskCount: Integer;

    FThreadInitializing: TCnThreadInPoolInitializing;
    FThreadFinalizing: TCnThreadInPoolFinalizing;
    FProcessRequest: TCnThreadPoolProcessRequest;
    FQueueEmpty: TCnQueueEmpty;
    FOnGetInfo: TCnThreadPoolGetInfo;
    FForceTerminate: Boolean;

    procedure SetAdjustInterval(const Value: DWORD);
{$IFDEF DEBUG}
    procedure Trace(const Str: string);
{$ENDIF}
  protected
    FLastGetPoint: Integer;
    FTerminateWaitTime: DWORD;
    FQueuePackCount: Integer;
    FHSemRequestCount: THandle;
    FHTimReduce: THandle;

    function HasSpareThread: Boolean;
    function HasTask: Boolean;
    function FinishedThreadsAreFull: Boolean; virtual;
    procedure CheckTaskEmpty;
    procedure GetRequest(var Request: TCnTaskDataObject);
    {* �Ӵ����ж�������һ���������׼������}
    procedure DecreaseThreads;
    {* ����һ�������߳�}
    procedure IncreaseThreads;
    {* ����һ�������̣߳����ӵ�}
    procedure FreeFinishedThreads;
    procedure KillDeadThreads;

    procedure DoProcessRequest(aDataObj: TCnTaskDataObject;
      aThread: TCnPoolingThread); virtual;
    procedure DoQueueEmpty(EmptyKind: TCnPoolEmptyKind); virtual;
    procedure DoThreadInitializing(aThread: TCnPoolingThread); virtual;
    procedure DoThreadFinalizing(aThread: TCnPoolingThread); virtual;

    procedure GetComponentInfo(var AName, Author, Email, Comment: string); override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateSpecial(AOwner: TComponent;
      AClass: TCnPoolingThreadClass);
    destructor Destroy; override;

    function AverageWaitingTime: Integer;
    function AverageProcessingTime: Integer;
    function Info: string;
    function OSIsWin9x: Boolean;
    function TaskCount: Integer;
    function ThreadCount: Integer;
    function ThreadInfo(const I: Integer): string;
    function ThreadKillingCount: Integer;
    function ThreadKillingInfo(const I: Integer): string;
    procedure DefaultGetInfo(Sender: TCnThreadPool; var InfoText: string);

    function AddRequest(DataObject: TCnTaskDataObject;
      CheckDuplicate: TCnCheckDuplicates = [cdQueue]): Boolean;
    {* �����Ӵ��ܵ��������ݣ����̳߳ذ����߳���}
    procedure AddRequests(DataObjects: array of TCnTaskDataObject;
      CheckDuplicate: TCnCheckDuplicates = [cdQueue]);
    procedure RemoveRequest(DataObject: TCnTaskDataObject);

    property TerminateWaitTime: DWORD read FTerminateWaitTime write FTerminateWaitTime;
    property QueuePackCount: Integer read FQueuePackCount write FQueuePackCount;
  published
    property AdjustInterval: DWORD read FAdjustInterval write SetAdjustInterval
      default 10000;
    property DeadTaskAsNew: Boolean read FDeadTaskAsNew write FDeadTaskAsNew
      default True;
    property MinAtLeast: Boolean read FMinAtLeast write FMinAtLeast
      default False;
    property ThreadDeadTimeout: DWORD read FThreadDeadTimeout
      write FThreadDeadTimeout default 0;
    property ThreadsMinCount: Integer read FThreadsMinCount write FThreadsMinCount default 0;
    property ThreadsMaxCount: Integer read FThreadsMaxCount write FThreadsMaxCount default 10;

    property ForceTerminate: Boolean read FForceTerminate write FForceTerminate;
    {* ��������ʱ�Ƿ�ǿ��ֹͣ�߳�}

    property OnGetInfo: TCnThreadPoolGetInfo read FOnGetInfo write FOnGetInfo;
    property OnProcessRequest: TCnThreadPoolProcessRequest read FProcessRequest
      write FProcessRequest;
    {* �̳߳��е��߳̽�ִ������ʱ���ã�Ҫ�ڴ��¼���дʵ�ʴ�����̴߳���}
    property OnQueueEmpty: TCnQueueEmpty read FQueueEmpty write FQueueEmpty;
    property OnThreadInitializing: TCnThreadInPoolInitializing
      read FThreadInitializing write FThreadInitializing;
    property OnThreadFinalizing: TCnThreadInPoolFinalizing read FThreadFinalizing
      write FThreadFinalizing;
  end;

{$IFDEF DEBUG}

  TLogWriteProc = procedure(const Str: string; const ID: Integer);

var
  TraceLog: TLogWriteProc = nil;

{$ENDIF}

const
  CCnTHREADSTATE: array[TCnThreadState] of string = (
    'ctsInitializing', 'ctsWaiting',
    'ctsGetting',
    'ctsProcessing', 'ctsProcessed',
    'ctsTerminating', 'ctsForReduce');

implementation

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF} Math;

type
  TCnCriticalSection = class
  protected
    FSection: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Enter;
    procedure Leave;
    function TryEnter: Boolean;
    function TryEnterEx: Boolean;
  end;

var
  FOSIsWin9x: Boolean;

{$IFDEF DEBUG}

procedure SimpleTrace(const Str: string; const ID: Integer);
begin
  CnDebugger.LogFmt('$%x:%s', [ID, Str]);
  // OutputDebugString(PChar(IntToStr(ID) + ':' + Str))
end;

{$ENDIF}

function GetTickDiff(const AOldTickCount, ANewTickCount : Cardinal):Cardinal;
begin
  if ANewTickCount >= AOldTickCount then
  begin
    Result := ANewTickCount - AOldTickCount;
  end
  else
  begin
    Result := High(Cardinal) - AOldTickCount + ANewTickCount;
  end;
end;

{ TCnCriticalSection }

constructor TCnCriticalSection.Create;
begin
  inherited;
  InitializeCriticalSection(FSection);
end;

destructor TCnCriticalSection.Destroy;
begin
  DeleteCriticalSection(FSection);
  inherited;
end;

procedure TCnCriticalSection.Enter;
begin
  EnterCriticalSection(FSection);
end;

procedure TCnCriticalSection.Leave;
begin
  LeaveCriticalSection(FSection);
end;

function TCnCriticalSection.TryEnter: Boolean;
begin
  Result := TryEnterCriticalSection(FSection)
end;

function TCnCriticalSection.TryEnterEx: Boolean;
begin
  if FOSIsWin9x then
  begin
    Enter;
    Result := True;
  end
  else
    Result := TryEnter;
end;

{ TCnTaskDataObject }

function TCnTaskDataObject.Duplicate(DataObj: TCnTaskDataObject;
  const Processing: Boolean): Boolean;
begin
  Result := False;
end;

function TCnTaskDataObject.Info: string;
begin
  Result := IntToHex(Cardinal(Self), 8);
end;

{ TCnPoolingThread }

constructor TCnPoolingThread.Create(aPool: TCnThreadPool);
begin
{$IFDEF DEBUG}
  Trace('TCnPoolingThread.Create');
{$ENDIF}

  inherited Create(True);
  FPool := aPool;

  FAverageWaitingTime := 0;
  FAverageProcessing := 0;
  FWorkCount := 0;
  sInitError := '';
  FreeOnTerminate := False;
  hInitFinished := CreateEvent(nil, True, False, nil);
  FHThreadTerminated := CreateEvent(nil, True, False, nil);
  FCSProcessingDataObject := TCnCriticalSection.Create;
  try
    Resume;
    WaitForSingleObject(hInitFinished, INFINITE);
    if sInitError <> '' then
      raise Exception.Create(sInitError);
  finally
    CloseHandle(hInitFinished);
  end;

{$IFDEF DEBUG}
  Trace('TCnPoolingThread.Created OK');
{$ENDIF}
end;

destructor TCnPoolingThread.Destroy;
begin
{$IFDEF DEBUG}
  Trace('TCnPoolingThread.Destroy');
{$ENDIF}

  FreeAndNil(FProcessingDataObject);
  CloseHandle(FHThreadTerminated);
  FreeAndNil(FCSProcessingDataObject);
  inherited;
end;

function TCnPoolingThread.AverageProcessingTime: DWORD;
begin
  if FCurState in [ctsProcessing] then
    Result := NewAverage(FAverageProcessing, GetTickDiff(FUProcessingStart, GetTickCount))
  else
    Result := FAverageProcessing
end;

function TCnPoolingThread.AverageWaitingTime: DWORD;
begin
  if FCurState in [ctsWaiting, ctsForReduce] then
    Result := NewAverage(FAverageWaitingTime, GetTickDiff(FUWaitingStart, GetTickCount))
  else
    Result := FAverageWaitingTime
end;

function TCnPoolingThread.Duplicate(DataObj: TCnTaskDataObject): Boolean;
begin
  TCnCriticalSection(FCSProcessingDataObject).Enter;
  try
    Result := (FProcessingDataObject <> nil) and
      DataObj.Duplicate(FProcessingDataObject, True);
  finally
    TCnCriticalSection(FCSProcessingDataObject).Leave;
  end
end;

procedure TCnPoolingThread.ForceTerminate;
begin
{$IFDEF DEBUG}
  Trace('TCnPoolingThread.ForceTerminate');
{$ENDIF}

  TerminateThread(Handle, 0)
end;

procedure TCnPoolingThread.Execute;
type
  THandleID = (hidRequest, hidReduce, hidTerminate);
var
  WaitedTime: Integer;
  Handles: array[THandleID] of THandle;
begin
{$IFDEF DEBUG}
  Trace('TCnPoolingThread.Execute');
{$ENDIF}

  FCurState := ctsInitializing;
  try
    FPool.DoThreadInitializing(Self);
  except
    on E: Exception do
      sInitError := E.Message;
  end;
  SetEvent(hInitFinished);

{$IFDEF DEBUG}
  Trace('TCnPoolingThread.Execute: Initialized');
{$ENDIF}

  Handles[hidRequest] := FPool.FHSemRequestCount;
  Handles[hidReduce] := FPool.FHTimReduce;
  Handles[hidTerminate] := FHThreadTerminated;

  FUWaitingStart := GetTickCount;
  FProcessingDataObject := nil;

  while not Terminated do
  begin
    if not (FCurState in [ctsWaiting, ctsForReduce]) then
      InterlockedIncrement(FPool.FIdleThreadCount);

    FCurState := ctsWaiting; // ��������߳��ǵȴ�״̬
    case WaitForMultipleObjects(Length(Handles), @Handles, False, INFINITE) of
      WAIT_OBJECT_0 + Ord(hidRequest):
        begin
{$IFDEF DEBUG}
          Trace('TCnPoolingThread.Execute: hidRequest');
{$ENDIF}

          WaitedTime := GetTickDiff(FUWaitingStart, GetTickCount);
          FAverageWaitingTime := NewAverage(FAverageWaitingTime, WaitedTime);

          if FCurState in [ctsWaiting, ctsForReduce] then
            InterlockedDecrement(FPool.FIdleThreadCount);

          FCurState := ctsGetting; // ����߳�����׼������������
          FPool.GetRequest(FProcessingDataObject);
          if FWorkCount < High(Int64) then
            FWorkCount := FWorkCount + 1;
          FUProcessingStart := GetTickCount;
          FUStillWorking := FUProcessingStart;

          FCurState := ctsProcessing; // ����߳���������
          try
{$IFDEF DEBUG}
            Trace('Processing: ' + FProcessingDataObject.Info);
{$ENDIF}

            FPool.DoProcessRequest(FProcessingDataObject, Self)
          except
{$IFDEF DEBUG}
            on E: Exception do
              Trace('OnProcessRequest Exception: ' + E.Message);
{$ENDIF}
          end;

          TCnCriticalSection(FCSProcessingDataObject).Enter;
          try
            FreeAndNil(FProcessingDataObject);
          finally
            TCnCriticalSection(FCSProcessingDataObject).Leave;
          end;
          FAverageProcessing :=
            NewAverage(FAverageProcessing, GetTickDiff(FUProcessingStart, GetTickCount));

          FCurState := ctsProcessed; // ����̸߳ո�����ִ�����
          FPool.CheckTaskEmpty;
          FUWaitingStart := GetTickCount;
        end;
      WAIT_OBJECT_0 + Ord(hidReduce):
        begin
{$IFDEF DEBUG}
          Trace('TCnPoolingThread.Execute: hidReduce');
{$ENDIF}

          if not (FCurState in [ctsWaiting, ctsForReduce]) then
            InterlockedIncrement(FPool.FIdleThreadCount);
          FCurState := ctsForReduce;
          FPool.DecreaseThreads;
        end;
      WAIT_OBJECT_0 + Ord(hidTerminate):
        begin
{$IFDEF DEBUG}
          Trace('TCnPoolingThread.Execute: hidTerminate');
{$ENDIF}

          if FCurState in [ctsWaiting, ctsForReduce] then
            InterlockedDecrement(FPool.FIdleThreadCount);

          FCurState := ctsTerminating; // ����߳�׼��������
          Break;
        end;
    end;
  end;

  if FCurState in [ctsWaiting, ctsForReduce] then
    InterlockedDecrement(FPool.FIdleThreadCount);
  FCurState := ctsTerminating;
  FPool.DoThreadFinalizing(Self);
end;

function TCnPoolingThread.Info: string;
begin
  Result := 'AverageWaitingTime=' + IntToStr(AverageWaitingTime) + '; ' +
    'AverageProcessingTime=' + IntToStr(AverageProcessingTime) + '; ' +
    'FCurState=' + CCnTHREADSTATE[FCurState] + '; ' +
    'FWorkCount=' + IntToStr(FWorkCount);

  if not FPool.OSIsWin9x then
  begin
    if TCnCriticalSection(FCSProcessingDataObject).TryEnter then
    try
      Result := Result + '; ' + 'FProcessingDataObject = ';
      if FProcessingDataObject = nil then
        Result := Result + 'nil'
      else
        Result := Result + FProcessingDataObject.Info;
    finally
      TCnCriticalSection(FCSProcessingDataObject).Leave;
    end
  end
  else
  begin
    if FProcessingDataObject = nil then
      Result := Result + '; FProcessingDataObject = nil'
    else
      Result := Result + '; FProcessingDataObject <> nil';
  end
end;

function TCnPoolingThread.IsDead: Boolean;
begin
  Result := Terminated or
    ((FPool.ThreadDeadTimeout > 0) and
    (FCurState = ctsProcessing) and
    (GetTickDiff(FUStillWorking, GetTickCount) > FPool.ThreadDeadTimeout));
{$IFDEF DEBUG}
  if Result then
    Trace('Thread is Dead, Info = ' + Info);
{$ENDIF}
end;

function TCnPoolingThread.IsFinished: Boolean;
begin
  Result := WaitForSingleObject(Handle, 0) = WAIT_OBJECT_0
end;

function TCnPoolingThread.IsIdle: Boolean;
begin
  Result := (FCurState in [ctsWaiting, ctsForReduce]) and
    (AverageWaitingTime > 200) and
    (AverageWaitingTime * 2 > AverageProcessingTime)
end;

function TCnPoolingThread.NewAverage(OldAvg, NewVal: Integer): Integer;
begin
  if FWorkCount >= 8 then
    Result := (OldAvg * 7 + NewVal) div 8
  else if FWorkCount > 0 then
    Result := (OldAvg * FWorkCount + NewVal) div FWorkCount
  else
    Result := NewVal
end;

procedure TCnPoolingThread.StillWorking;
begin
  FUStillWorking := GetTickCount;
end;

procedure TCnPoolingThread.Terminate(const Force: Boolean);
begin
{$IFDEF DEBUG}
  Trace('TCnPoolingThread.Terminate');
{$ENDIF}

  inherited Terminate;

  if Force then
  begin
    ForceTerminate;
    Free;
  end
  else
    SetEvent(FHThreadTerminated)
end;

{$IFDEF DEBUG}

procedure TCnPoolingThread.Trace(const Str: string);
begin
  TraceLog(Str, ThreadID);
end;
{$ENDIF}

function TCnPoolingThread.CloneData: TCnTaskDataObject;
begin
  TCnCriticalSection(FCSProcessingDataObject).Enter;
  try
    Result := nil;
    if FProcessingDataObject <> nil then
      Result := FProcessingDataObject.Clone;
  finally
    TCnCriticalSection(FCSProcessingDataObject).Leave;
  end;
end;

{ TCnThreadPool }

constructor TCnThreadPool.Create(AOwner: TComponent);
var
  DueTo: Int64;
begin
{$IFDEF DEBUG}
  Trace('TCnThreadPool.Create');
{$ENDIF}

  inherited;

  FCSQueueManagment := TCnCriticalSection.Create;
  FCSThreadManagment := TCnCriticalSection.Create;
  FQueue := TList.Create;
  FThreads := TList.Create;
  FThreadsKilling := TList.Create;
  FThreadsMinCount := 0;
  FThreadsMaxCount := 1;
  FThreadDeadTimeout := 0;
  FThreadClass := TCnPoolingThread;
  FAdjustInterval := 10000;
  FDeadTaskAsNew := True;
  FMinAtLeast := False;
  FLastGetPoint := 0;
  TerminateWaitTime := 10000;
  QueuePackCount := 127;
  FIdleThreadCount := 0;
  FTaskCount := 0;

  FHSemRequestCount := CreateSemaphore(nil, 0, $7FFFFFFF, nil);

  DueTo := -1;
  FHTimReduce := CreateWaitableTimer(nil, False, nil);

  if FHTimReduce = 0 then
    FHTimReduce := CreateEvent(nil, False, False, nil)
  else
    SetWaitableTimer(FHTimReduce, DueTo, FAdjustInterval, nil, nil, False);
end;

constructor TCnThreadPool.CreateSpecial(AOwner: TComponent;
  AClass: TCnPoolingThreadClass);
begin
  Create(AOwner);
  if AClass <> nil then
    FThreadClass := AClass
end;

destructor TCnThreadPool.Destroy;
var
  I, N: Integer;
  Handles: array of THandle;
begin
{$IFDEF DEBUG}
  Trace('TCnThreadPool.Destroy');
{$ENDIF}

  TCnCriticalSection(FCSThreadManagment).Enter;
  try
    SetLength(Handles, FThreads.Count);
    N := 0;

{$IFDEF DEBUG}
    Trace('TCnThreadPool Destroy: To Terminate FThreads.');
{$ENDIF}

    // ���ÿ���̣߳��ȵ��������ʱ��
    for I := 0 to FThreads.Count - 1 do
    begin
      if FThreads[I] <> nil then
      begin
        Handles[N] := TCnPoolingThread(FThreads[I]).Handle;
        TCnPoolingThread(FThreads[I]).Terminate(FForceTerminate);
        // �� FForceTerminate Ϊ True���ڲ��� Free
        Inc(N);
      end;
    end;

{$IFDEF DEBUG}
    Trace('TCnThreadPool Destroy: WaitFor FThreads Terminate.');
{$ENDIF}

    WaitForMultipleObjects(N, @Handles[0], True, TerminateWaitTime);

{$IFDEF DEBUG}
    Trace('TCnThreadPool Destroy: Free FThreads Thread Instances.');
{$ENDIF}

    if not FForceTerminate then
    begin
      // ��ǿ������£��ٴΰ����ͷŹ����̣߳��������Ƿ������ע��ǿ��������� Free��
      for I := 0 to FThreads.Count - 1 do
      begin
        {if FThreads[i] <> nil then
          TCnPoolingThread(FThreads[i]).Terminate(True)
        else}
        TCnPoolingThread(FThreads[I]).Free;
      end;
    end;

{$IFDEF DEBUG}
    Trace('TCnThreadPool Destroy: Free FThreads List.');
{$ENDIF}

    // �ͷ��߳��б�
    FThreads.Free;

{$IFDEF DEBUG}
    Trace('TCnThreadPool Destroy: Free Finished Threads.');
{$ENDIF}

    // �ͷ�����˵����߳�
    FreeFinishedThreads;

{$IFDEF DEBUG}
    Trace('TCnThreadPool Destroy: Free FThreadsKilling Thread Instances.');
{$ENDIF}

    // �ͷ��������߳�
    for I := 0 to FThreadsKilling.Count - 1 do
    begin
      {if FThreadsKilling[I] <> nil then
        TCnPoolingThread(FThreadsKilling[I]).Terminate(True)
      else}
      TCnPoolingThread(FThreadsKilling[I]).Free;
    end;

{$IFDEF DEBUG}
    Trace('TCnThreadPool Destroy: Free FThreadsKilling List.');
{$ENDIF}
    FThreadsKilling.Free;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end;
  FCSThreadManagment.Free;

  TCnCriticalSection(FCSQueueManagment).Enter;
  try
    for I := FQueue.Count - 1 downto 0 do
      TObject(FQueue[I]).Free;
    FQueue.Free;
  finally
    TCnCriticalSection(FCSQueueManagment).Leave;
  end;
  FCSQueueManagment.Free;

  CloseHandle(FHSemRequestCount);
  CloseHandle(FHTimReduce);

  inherited;
end;

function TCnThreadPool.AddRequest(DataObject: TCnTaskDataObject;
  CheckDuplicate: TCnCheckDuplicates): Boolean;
var
  I: Integer;
begin
{$IFDEF DEBUG}
  Trace('AddRequest:' + DataObject.Info);
{$ENDIF}

  Result := False;

  TCnCriticalSection(FCSQueueManagment).Enter;
  try
    if cdQueue in CheckDuplicate then
    begin
      for I := 0 to FQueue.Count - 1 do
      begin
        if (FQueue[I] <> nil) and
          DataObject.Duplicate(TCnTaskDataObject(FQueue[I]), False) then
        begin
{$IFDEF DEBUG}
          Trace('Duplicate:' + TCnTaskDataObject(FQueue[I]).Info);
{$ENDIF}

          FreeAndNil(DataObject);
          Exit;
        end;
      end;
    end;

    TCnCriticalSection(FCSThreadManagment).Enter;
    try
      IncreaseThreads;

      if cdProcessing in CheckDuplicate then
      begin
        for I := 0 to FThreads.Count - 1 do
        begin
          if TCnPoolingThread(FThreads[I]).Duplicate(DataObject) then
          begin
{$IFDEF DEBUG}
            Trace('Duplicate:' + TCnPoolingThread(FThreads[I]).FProcessingDataObject.Info);
{$ENDIF}
            FreeAndNil(DataObject);
            Exit;
          end;
        end;
      end;
    finally
      TCnCriticalSection(FCSThreadManagment).Leave;
    end;

    FQueue.Add(DataObject);
    Inc(FTaskCount);
    ReleaseSemaphore(FHSemRequestCount, 1, nil);
{$IFDEF DEBUG}
    Trace('ReleaseSemaphore');
{$ENDIF}

    Result := True;
  finally
    TCnCriticalSection(FCSQueueManagment).Leave;
  end;

{$IFDEF DEBUG}
  Trace('Added Request:' + DataObject.Info);
{$ENDIF}
end;

procedure TCnThreadPool.AddRequests(DataObjects: array of TCnTaskDataObject;
  CheckDuplicate: TCnCheckDuplicates);
var
  I: Integer;
begin
  for I := 0 to Length(DataObjects) - 1 do
    AddRequest(DataObjects[I], CheckDuplicate);
end;

procedure TCnThreadPool.CheckTaskEmpty;
var
  I: Integer;
begin
  TCnCriticalSection(FCSQueueManagment).Enter;
  try
    if FLastGetPoint < FQueue.Count then
      Exit;

    TCnCriticalSection(FCSThreadManagment).Enter;
    try
      for I := 0 to FThreads.Count - 1 do
      begin
        if TCnPoolingThread(FThreads[I]).FCurState in [ctsProcessing] then
          Exit;
      end;
    finally
      TCnCriticalSection(FCSThreadManagment).Leave;
    end;

    DoQueueEmpty(ekTaskEmpty);
  finally
    TCnCriticalSection(FCSQueueManagment).Leave;
  end
end;

procedure TCnThreadPool.DecreaseThreads;
var
  I: Integer;
begin
{$IFDEF DEBUG}
  Trace('TCnThreadPool.DecreaseThreads');
{$ENDIF}

  if TCnCriticalSection(FCSThreadManagment).TryEnter then
  try
    KillDeadThreads;
    FreeFinishedThreads;

    for I := FThreads.Count - 1 downto FThreadsMinCount do
    begin
      if TCnPoolingThread(FThreads[I]).IsIdle then
      begin
        TCnPoolingThread(FThreads[I]).Terminate(False);
        FThreadsKilling.Add(FThreads[I]);
        FThreads.Delete(I);
        Break
      end;
    end;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end
end;

procedure TCnThreadPool.DefaultGetInfo(Sender: TCnThreadPool;
  var InfoText: string);
var
  I: Integer;
  sLine: string;
begin
  sLine := StringOfChar('=', 15);
  with Sender do
  begin
    FreeFinishedThreads;
    InfoText := 'MinCount=' + IntToStr(ThreadsMinCount) +
      '; MaxCount=' + IntToStr(ThreadsMaxCount) +
      '; AdjustInterval=' + IntToStr(AdjustInterval) +
      '; DeadTimeOut=' + IntToStr(ThreadDeadTimeout) + #13#10 +
      'ThreadCount=' + IntToStr(ThreadCount) +
      '; KillingCount=' + IntToStr(ThreadKillingCount) +
      '; SpareThreadCount=' + IntToStr(FIdleThreadCount) +
      '; TaskCount=' + IntToStr(TaskCount) + #13#10 +
      'AverageWaitingTime=' + IntToStr(AverageWaitingTime) +
      '; AverageProcessingTime=' + IntToStr(AverageProcessingTime) + #13#10 +
      {sLine + }'Working Threads Info' + sLine;
    for I := 0 to ThreadCount - 1 do
      InfoText := InfoText + #13#10 + ThreadInfo(I);
    InfoText := InfoText + #13#10 + {sLine +} 'Killing Threads Info' + sLine;
    for I := 0 to ThreadKillingCount - 1 do
      InfoText := InfoText + #13#10 + ThreadKillingInfo(I);
  end
end;

procedure TCnThreadPool.DoProcessRequest(aDataObj: TCnTaskDataObject;
  aThread: TCnPoolingThread);
begin
  if Assigned(FProcessRequest) then
    FProcessRequest(Self, aDataObj, aThread);
end;

procedure TCnThreadPool.DoQueueEmpty(EmptyKind: TCnPoolEmptyKind);
begin
  if Assigned(FQueueEmpty) then
    FQueueEmpty(Self, EmptyKind);
end;

procedure TCnThreadPool.DoThreadFinalizing(aThread: TCnPoolingThread);
begin
  if Assigned(FThreadFinalizing) then
    FThreadFinalizing(Self, aThread);
end;

procedure TCnThreadPool.DoThreadInitializing(aThread: TCnPoolingThread);
begin
  if Assigned(FThreadInitializing) then
    FThreadInitializing(Self, aThread);
end;

procedure TCnThreadPool.FreeFinishedThreads;
var
  I: Integer;
begin
  if TCnCriticalSection(FCSThreadManagment).TryEnter then
  try
    for I := FThreadsKilling.Count - 1 downto 0 do
    begin
      if TCnPoolingThread(FThreadsKilling[I]).IsFinished then
      begin
        TCnPoolingThread(FThreadsKilling[I]).Free;
        FThreadsKilling.Delete(I);
      end;
    end;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end;
end;

procedure TCnThreadPool.GetRequest(var Request: TCnTaskDataObject);
begin
{$IFDEF DEBUG}
  Trace('TCnThreadPool.GetRequest');
{$ENDIF}

  TCnCriticalSection(FCSQueueManagment).Enter;
  try
    while (FLastGetPoint < FQueue.Count) and (FQueue[FLastGetPoint] = nil) do
      Inc(FLastGetPoint);

    if (FQueue.Count > QueuePackCount) and
      (FLastGetPoint >= FQueue.Count * 3 div 4) then
    begin
{$IFDEF DEBUG}
      Trace('FQueue.Pack');
{$ENDIF DEBUG}

      FQueue.Pack;
      FTaskCount := FQueue.Count;
      FLastGetPoint := 0
    end;

    Request := TCnTaskDataObject(FQueue[FLastGetPoint]);
    FQueue[FLastGetPoint] := nil;
    Dec(FTaskCount);
    Inc(FLastGetPoint);

    if (FLastGetPoint = FQueue.Count) then
    begin
      DoQueueEmpty(ekQueueEmpty);
      FQueue.Clear;
      FTaskCount := 0;
      FLastGetPoint := 0;
    end;
  finally
    TCnCriticalSection(FCSQueueManagment).Leave;
  end
end;

function TCnThreadPool.HasSpareThread: Boolean;
begin
  Result := FIdleThreadCount > 0;
end;

function TCnThreadPool.HasTask: Boolean;
begin
  Result := FTaskCount > 0;
end;

function TCnThreadPool.FinishedThreadsAreFull: Boolean;
begin
  TCnCriticalSection(FCSThreadManagment).Enter;
  try
    if FThreadsMaxCount > 0 then
      Result := FThreadsKilling.Count >= FThreadsMaxCount div 2
    else
      Result := FThreadsKilling.Count >= 50;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end
end;

procedure TCnThreadPool.IncreaseThreads;
var
  iAvgWait, iAvgProc: Integer;
  I: Integer;
begin
  TCnCriticalSection(FCSThreadManagment).Enter;
  try
    KillDeadThreads;
    FreeFinishedThreads;

    if FThreads.Count = 0 then
    begin
{$IFDEF DEBUG}
      Trace('IncreaseThreads: FThreads.Count = 0');
{$ENDIF}

      try
        FThreads.Add(FThreadClass.Create(Self));
      except
{$IFDEF DEBUG}
        on E: Exception do
          Trace('New thread Exception on ' + E.ClassName + ': ' + E.Message)
{$ENDIF}
      end
    end
    else if FMinAtLeast and (FThreads.Count < FThreadsMinCount) then
    begin
{$IFDEF DEBUG}
      Trace('IncreaseThreads: FThreads.Count < FThreadsMinCount');
{$ENDIF}

      for I := FThreads.Count to FThreadsMinCount - 1 do
      try
        FThreads.Add(FThreadClass.Create(Self));
      except
{$IFDEF DEBUG}
        on E: Exception do
          Trace('New thread Exception on ' + E.ClassName + ': ' + E.Message)
{$ENDIF}
      end
    end
    else if (FThreads.Count < FThreadsMaxCount) and HasTask and not HasSpareThread then
    begin
{$IFDEF DEBUG}
      Trace('IncreaseThreads: FThreads.Count < FThreadsMaxCount');
{$ENDIF}
      I := TaskCount;
      if I <= 0 then
        Exit;

      iAvgWait := Max(AverageWaitingTime, 1);
      if iAvgWait > 100 then
        Exit;

      iAvgProc := Max(AverageProcessingTime, 2);
{$IFDEF DEBUG}
      Trace(Format(
        'ThreadCount(%D);ThreadsMaxCount(%D);AvgWait(%D);AvgProc(%D);TaskCount(%D);Killing(%D)',
        [FThreads.Count, FThreadsMaxCount, iAvgWait, iAvgProc, I, ThreadKillingCount]));
{$ENDIF}

      //if i * iAvgWait * 2 > iAvgProc * FThreads.Count then
      if ((iAvgProc + iAvgWait) * I > iAvgProc * FThreads.Count) then
      begin
        try
          FThreads.Add(FThreadClass.Create(Self));
        except
{$IFDEF DEBUG}
          on E: Exception do
            Trace('New thread Exception on ' + E.ClassName + ': ' + E.Message)
{$ENDIF}
        end;
      end;
    end;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end
end;

function TCnThreadPool.Info: string;
begin
  if TCnCriticalSection(FCSThreadManagment).TryEnter then
  begin
    try
      if Assigned(FOnGetInfo) then
        FOnGetInfo(Self, Result)
      else
        DefaultGetInfo(Self, Result);
    finally
      TCnCriticalSection(FCSThreadManagment).Leave;
    end;
  end
  else
  begin
    Result := 'Too Busy to Get Info.';
  end;
end;

procedure TCnThreadPool.KillDeadThreads;
var
  I, iLen: Integer;
  LThread: TCnPoolingThread;
  LObjects: array of TCnTaskDataObject;
begin
  if FinishedThreadsAreFull then
    Exit;

  iLen := 0;
  SetLength(LObjects, iLen);
  if TCnCriticalSection(FCSThreadManagment).TryEnter then
  try
    for I := FThreads.Count - 1 downto 0 do
    begin
      LThread := TCnPoolingThread(FThreads[I]);
      if LThread.IsDead then
      begin
        if FDeadTaskAsNew then
        begin
          Inc(iLen);
          SetLength(LObjects, iLen);
          LObjects[iLen - 1] := LThread.CloneData;
        end;

        LThread.Terminate(False);
        FThreadsKilling.Add(LThread);
        FThreads.Delete(I);

//        else
//        try
//          FThreads.Add(FThreadClass.Create(Self));
//        except
//{$IFDEF DEBUG}
//          on E: Exception do
//            Trace('New thread Exception on ' + E.ClassName + ': ' + E.Message)
//{$ENDIF}
//        end
      end;
    end;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end;
  AddRequests(LObjects, []);
end;

function TCnThreadPool.OSIsWin9x: Boolean;
begin
  Result := FOsIsWin9x;
end;

function TCnThreadPool.AverageProcessingTime: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FThreads.Count > 0 then
  begin
    for I := 0 to FThreads.Count - 1 do
      Inc(Result, TCnPoolingThread(FThreads[I]).AverageProcessingTime);
    Result := Result div FThreads.Count;
  end
  else
    Result := 20;
end;

function TCnThreadPool.AverageWaitingTime: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FThreads.Count > 0 then
  begin
    for I := 0 to FThreads.Count - 1 do
      Inc(Result, TCnPoolingThread(FThreads[I]).AverageWaitingTime);
    Result := Result div FThreads.Count;
  end
  else
    Result := 10;
end;

procedure TCnThreadPool.RemoveRequest(DataObject: TCnTaskDataObject);
begin
  TCnCriticalSection(FCSQueueManagment).Enter;
  try
    FQueue.Remove(DataObject);
    Dec(FTaskCount);
    FreeAndNil(DataObject);
  finally
    TCnCriticalSection(FCSQueueManagment).Leave;
  end
end;

procedure TCnThreadPool.SetAdjustInterval(const Value: DWORD);
var
  DueTo: Int64;
begin
  FAdjustInterval := Value;
  if FHTimReduce <> 0 then
    SetWaitableTimer(FHTimReduce, DueTo, Value, nil, nil, False);
end;

function TCnThreadPool.TaskCount: Integer;
begin
  Result := FTaskCount;
end;

function TCnThreadPool.ThreadCount: Integer;
begin
  if TCnCriticalSection(FCSThreadManagment).TryEnter then
  try
    Result := FThreads.Count;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end
  else
    Result := -1;
end;

function TCnThreadPool.ThreadInfo(const I: Integer): string;
begin
  Result := '';

  if TCnCriticalSection(FCSThreadManagment).TryEnter then
  try
    if I < FThreads.Count then
      Result := TCnPoolingThread(FThreads[I]).Info;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end
end;

function TCnThreadPool.ThreadKillingCount: Integer;
begin
  if TCnCriticalSection(FCSThreadManagment).TryEnter then
  try
    Result := FThreadsKilling.Count;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end
  else
    Result := -1;
end;

function TCnThreadPool.ThreadKillingInfo(const I: Integer): string;
begin
  Result := '';

  if TCnCriticalSection(FCSThreadManagment).TryEnter then
  try
    if I < FThreadsKilling.Count then
      Result := TCnPoolingThread(FThreadsKilling[I]).Info;
  finally
    TCnCriticalSection(FCSThreadManagment).Leave;
  end;
end;

procedure TCnThreadPool.GetComponentInfo(var AName, Author, Email,
  Comment: string);
begin
  AName := SCnThreadPoolName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnThreadPoolComment;
end;

{$IFDEF DEBUG}

procedure TCnThreadPool.Trace(const Str: string);
begin
  TraceLog(Str, 0)
end;

{$ENDIF}

var
  V: TOSVersionInfo;

initialization
  V.dwOSVersionInfoSize := SizeOf(V);
  FOSIsWin9x := GetVersionEx(V) and
    (V.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS);
    
{$IFDEF DEBUG}
  TraceLog := SimpleTrace;
{$ENDIF}

end.

