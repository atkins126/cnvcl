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

unit CnUDP;
{* |<PRE>
================================================================================
* ������ƣ�����ͨѶ�����
* ��Ԫ���ƣ�UDP ͨѶ��Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע�������� TCnUDP���� Windows��ʹ�÷�������ʽ���� UDP ͨѶ��֧�ֹ㲥
*           MACOS �����߳�������ʽ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP/10+ Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.12.15 V1.2
*                ֧�� MACOS��ʹ������ʽ�߳�
*           2008.11.28 V1.1
*                ����һ���ƽ��ջ�������С������
*           2003.11.21 V1.0
*                ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs,
  {$IFDEF MSWINDOWS}
  Windows, Messages, WinSock, Forms, // ��Ҫ���ù��̵ĵ�Ԫǰ׺ Vcl �� FMX
  {$ELSE}
  Posix.Base, Posix.NetIf, Posix.SysSocket, Posix.ArpaInet, Posix.NetinetIn,
  Posix.Unistd, System.Net.Socket,
  {$ENDIF}
  CnClasses, CnConsts, CnNetConsts, CnSocket;

const
  csDefRecvBuffSize = 4096;
  csDefUDPSendBuffSize = 256 * 1024;
  csDefUDPRecvBuffSize = 256 * 1024;

type

//==============================================================================
// UDP ͨѶ��
//==============================================================================

{ TCnUDP }

  TCnOnDataReceived = procedure(Sender: TComponent; Buffer: Pointer; Len: Integer;
    const FromIP: string; Port: Integer) of object;
  {* ���յ������¼�
   |<PRE>
     Sender     - TCnUDP ����
     Buffer     - ���ݻ�����
     Len        - ���ݻ���������
     FromIP     - ������Դ IP
     Port       - ������Դ�˿ں�
   |</PRE>}

  TCnUDP = class(TCnComponent)
  {* ʹ�÷�������ʽ���� UDP ͨѶ���ࡣ֧�ֹ㲥�����ݶ��еȡ�}
  private
    FRemoteHost: string;
    FRemotePort: Integer;
    FLocalPort: Integer;
{$IFDEF MSWINDOWS}
    FSockCount: Integer;
    FSocketWindow: HWND;
    RemoteHostS: PHostEnt;
    Succeed: Boolean;
    EventHandle: THandle;
{$ELSE}
    FThread: TThread;
    FLock: TObject;
{$ENDIF}
    Wait_Flag: Boolean;
    FProcing: Boolean;
    FRemoteAddress: TSockAddr;
    FOnDataReceived: TCnOnDataReceived;
    FListening: Boolean;
    FThisSocket: TSocket;
    FQueue: TQueue;
    FLastError: Integer;
    FRecvBufSize: Cardinal;
    FRecvBuf: Pointer;
    FBindAddr: string;
    FUDPSendBufSize: Cardinal;
    FUDPRecvBufSize: Cardinal;
{$IFDEF MSWINDOWS}
    procedure WndProc(var Message: TMessage);
    procedure ProcessIncomingdata;
{$ENDIF}
    procedure ProcessQueue;
    function ResolveRemoteHost(ARemoteHost: string): Boolean;
    procedure SetLocalPort(NewLocalPort: Integer);

    procedure FreeQueueItem(P: Pointer);
    function GetQueueCount: Integer;
    procedure SetupLastError;
    function GetLocalHost: string;
    procedure SetRecvBufSize(const Value: Cardinal);
    procedure SetBindAddr(const Value: string);
    function SockStartup: Boolean;
    procedure SockCleanup;
    procedure SetUDPRecvBufSize(const Value: Cardinal);
    procedure SetUDPSendBufSize(const Value: Cardinal);
  protected
    procedure GetComponentInfo(var AName, Author, Email, Comment: string); override;
    procedure DoDataReceived(Buffer: Pointer; Len: Integer; const FromIP: string; Port: Integer);
{$IFDEF MSWINDOWS}
    procedure Wait;
{$ELSE}
    procedure StartThread;
    procedure StopThread;
{$ENDIF}
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateBinding;
    {* ʵʩ����󶨶˿ڲ�����}

    function SendStream(DataStream: TStream; BroadCast: Boolean = False): Boolean;
    {* ����һ������������� BroadCase Ϊ�棬ִ�� UDP �㲥�����������ݵ�
       RomoteHost �Ļ����ϵ� RemotePort �˿�}
    function SendBuffer(Buff: Pointer; Length: Integer; BroadCast:
      Boolean = False): Boolean;
    {* ����һ�����ݿ顣��� BroadCase Ϊ�棬ִ�� UDP �㲥�����������ݵ�
       RomoteHost �Ļ����ϵ� RemotePort �˿�}
    procedure ClearQueue;
    {* ������ݶ��С�����û�������������յ������ݣ������������ݰ��ŵ�����
       �����У����ø÷�����������ݶ���}

{$IFDEF MSWINDOWS}
    function ProcessRecv: Boolean;
    {* ����� UDP �ӿڵĽ������ݡ����� CnUDP ����� OnDataReceived �������߳�
       ��Ϣ�����е��õģ�������̴߳�����Ҫ�ȴ� UDP ���ն���ϣ������������Ϣ��
       ���Ե��øú�����}
{$ENDIF}

    property LastError: Integer read FLastError;
    {* ���һ�δ���Ĵ���ţ�ֻ������}
    property Listening: Boolean read FListening;
    {* ��ʾ��ǰ�Ƿ����ڼ������ض˿ڣ�ֻ������}
    property QueueCount: Integer read GetQueueCount;
    {* ��ǰ���ݶ��еĳ��ȣ�ֻ������}
    property BindAddr: string read FBindAddr write SetBindAddr;
    {* �󶨱��ص�ַ}
  published
    property RemoteHost: string read FRemoteHost write FRemoteHost;
    {* Ҫ���� UDP ���ݵ�Ŀ��������ַ}
    property RemotePort: Integer read FRemotePort write FRemotePort;
    {* Ҫ���� UDP ���ݵ�Ŀ�������˿ں�}
    property LocalHost: string read GetLocalHost;
    {* ���ر��� IP ��ַ��ֻ������}
    property LocalPort: Integer read FLocalPort write SetLocalPort;
    {* ���ؼ����Ķ˿ں�}
    property RecvBufSize: Cardinal read FRecvBufSize write SetRecvBufSize default csDefRecvBuffSize;
    {* ���յ����ݻ�������С}
    property UDPSendBufSize: Cardinal read FUDPSendBufSize write SetUDPSendBufSize default csDefUDPSendBuffSize;
    {* UDP ���͵����ݻ�������С}
    property UDPRecvBufSize: Cardinal read FUDPRecvBufSize write SetUDPRecvBufSize default csDefUDPRecvBuffSize;
    {* UDP ���յ����ݻ�������С}
    property OnDataReceived: TCnOnDataReceived read FOnDataReceived write
      FOnDataReceived;
    {* ���յ� UDP ���ݰ��¼���Windows ƽ̨�����߳���ִ�У�����ƽ̨���߳���ִ��}
  end;

{$IFNDEF MSWINDOWS}

  TCnUDPReadThread = class(TThread)
  private
    FUDP: TCnUDP;
  protected
    procedure ProcessData;
    procedure Execute; override;
  public
    property UDP: TCnUDP read FUDP write FUDP;
  end;

{$ENDIF}

// ȡ�㲥��ַ
procedure GetBroadCastAddress(sInt: TStrings);

// ȡ���� IP ��ַ
procedure GetLocalIPAddress(sInt: TStrings);

implementation

{$R-}

//==============================================================================
// ��������
//==============================================================================

{$IFDEF MSWINDOWS}

// �� Winsock 2.0���뺯�� WSAIOCtl
function WSAIoctl(S: TSocket; cmd: DWORD; lpInBuffer: PCHAR; dwInBufferLen:
  DWORD;
  lpOutBuffer: PCHAR; dwOutBufferLen: DWORD;
  lpdwOutBytesReturned: LPDWORD;
  lpOverLapped: POINTER;
  lpOverLappedRoutine: POINTER): Integer; stdcall; external 'WS2_32.DLL';

const
  SIO_GET_INTERFACE_LIST = $4004747F;
  IFF_UP = $00000001;
  IFF_BROADCAST = $00000002;
  IFF_LOOPBACK = $00000004;
  IFF_POINTTOPOINT = $00000008;
  IFF_MULTICAST = $00000010;

type
  sockaddr_gen = packed record
    AddressIn: sockaddr_in;
    filler: packed array[0..7] of AnsiChar;
  end;

  INTERFACE_INFO = packed record
    iiFlags: u_long;                    // Interface flags
    iiAddress: sockaddr_gen;            // Interface address
    iiBroadcastAddress: sockaddr_gen;   // Broadcast address
    iiNetmask: sockaddr_gen;            // Network mask
  end;

{$ENDIF}

// ȡ�������е�ַ��㲥��ַ
procedure DoGetIPAddress(sInt: TStrings; IsBroadCast: Boolean);
var
  pAddrStr: string;
{$IFDEF MSWINDOWS}
  S: TSocket;
  wsaD: WSADATA;
  NumInterfaces: Integer;
  BytesReturned, SetFlags: u_long;
  pAddr, pMask, pCast: TInAddr;
  PtrA: pointer;
  Buffer: array[0..20] of INTERFACE_INFO;
  I: Integer;
{$ELSE}
  Pif: Pifaddrs;
  InAddr: in_addr;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  WSAStartup($0101, wsaD);              // Start WinSock
  S := Socket(AF_INET, SOCK_STREAM, 0); // Open a socket
  if (S = INVALID_SOCKET) then
    Exit;

  try                                   // Call WSAIoCtl
    PtrA := @bytesReturned;
    if (WSAIoCtl(S, SIO_GET_INTERFACE_LIST, nil, 0, @Buffer, 1024, PtrA, nil,
      nil) <> SOCKET_ERROR) then
    begin                               // If ok, find out how
      // many interfaces exist
      NumInterfaces := BytesReturned div SizeOf(INTERFACE_INFO);
      sInt.Clear;
      for I := 0 to NumInterfaces - 1 do // For every interface
      begin
        SetFlags := Buffer[I].iiFlags;
        if (SetFlags and IFF_BROADCAST = IFF_BROADCAST) and not
          (SetFlags and IFF_LOOPBACK = IFF_LOOPBACK) then
        begin
          pAddr := Buffer[I].iiAddress.AddressIn.sin_addr;
          pMask := Buffer[I].iiNetmask.AddressIn.sin_addr;
          if IsBroadCast then
          begin
            pCast.S_addr := pAddr.S_addr or not pMask.S_addr;
            pAddrStr := string(inet_ntoa(pCast));
          end
          else
          begin
            pAddrStr := string(inet_ntoa(pAddr));
          end;

          if sInt.IndexOf(pAddrStr) < 0 then
            sInt.Add(pAddrStr);
        end;
      end;
    end;
  except
    ;
  end;
  CloseSocket(S);
  WSACleanUp;
{$ELSE}
  getifaddrs(Pif);
  while Pif <> nil do
  begin
    // �Ȳ����� BROADCAST ���
    if (Pif^.ifa_addr.sa_family = AF_INET) and ((Pif^.ifa_flags and IFF_LOOPBACK) = 0) then
    begin
      InAddr := Psockaddr_in(Pif^.ifa_addr)^.sin_addr;
      if IsBroadCast then
        InAddr.s_addr := InAddr.s_addr or not
          Psockaddr_in(Pif^.ifa_netmask)^.sin_addr.s_addr;

      pAddrStr := string(inet_ntoa(InAddr));

      if sInt.IndexOf(pAddrStr) < 0 then
        sInt.Add(pAddrStr);
    end;
    Pif := Pif^.ifa_next;
  end;
  freeifaddrs(Pif);
{$ENDIF}
end;

// ȡ���� IP ��ַ
procedure GetLocalIPAddress(sInt: TStrings);
begin
  DoGetIPAddress(sInt, False);
end;

// ȡ�㲥��ַ
procedure GetBroadCastAddress(sInt: TStrings);
begin
  DoGetIPAddress(sInt, True);
end;

//==============================================================================
// UDP ͨѶ��
//==============================================================================

{ TCnUDP }

const
{$IFDEF MSWINDOWS}
  WM_ASYNCHRONOUSPROCESS = WM_USER + 101;
{$ENDIF}
  CONST_CMD_TRUE: AnsiString = 'TRUE';

type
  PRecvDataRec = ^TRecvDataRec;
  TRecvDataRec = record
    FromIP: string[128];
    FromPort: Word;
    Buff: Pointer;
    BuffSize: Integer;
  end;

constructor TCnUDP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FQueue := TQueue.Create;
  FListening := False;
  FProcing := False;
  FRecvBufSize := csDefRecvBuffSize;
  FUDPSendBufSize := csDefUDPSendBuffSize;
  FUDPRecvBufSize := csDefUDPRecvBuffSize;

{$IFDEF MSWINDOWS}
  GetMem(RemoteHostS, MAXGETHOSTSTRUCT);
  FSocketWindow := AllocateHWND(WndProc);
  EventHandle := CreateEvent(nil, True, False, '');
{$ELSE}
  FLock := TObject.Create;
{$ENDIF}

  FBindAddr := '0.0.0.0';
  if SockStartup then
  begin
    FThisSocket := CnNewSocket(AF_INET, SOCK_DGRAM, 0);
    if FThisSocket = INVALID_SOCKET then
    begin
      SetupLastError;
      SockCleanup;
      Exit;
    end;

    CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_DONTLINGER, PAnsiChar(CONST_CMD_TRUE), 4);
    CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_BROADCAST, PAnsiChar(CONST_CMD_TRUE), 4);
    FListening := True;
  end;
end;

destructor TCnUDP.Destroy;
begin
{$IFNDEF MSWINDOWS}
  StopThread;
{$ENDIF}

  if FRecvBuf <> nil then
  begin
    FreeMem(FRecvBuf);
    FRecvBuf := nil;
  end;

  ClearQueue;
  FQueue.Free;

{$IFDEF MSWINDOWS}
  FreeMem(RemoteHostS, MAXGETHOSTSTRUCT);
  DeallocateHWND(FSocketWindow);
  CloseHandle(EventHandle);
{$ELSE}
  FLock.Free;
{$ENDIF}

  if FThisSocket <> 0 then
    CnCloseSocket(FThisSocket);
  if FListening then
    SockCleanup;
  inherited Destroy;
end;

procedure TCnUDP.DoDataReceived(Buffer: Pointer; Len: Integer;
  const FromIP: string; Port: Integer);
begin
  if Assigned(FOnDataReceived) then
    FOnDataReceived(Self, Buffer, Len, FromIP, Port);
end;

procedure TCnUDP.UpdateBinding;
var
  Data: Cardinal;
  Address: TSockAddr;
begin
  if not (csDesigning in ComponentState) then
  begin
    FListening := False;

    if FThisSocket <> 0 then
    begin
      CnCloseSocket(FThisSocket);
      SockCleanup;
    end;

    if SockStartup then
    begin
      FThisSocket := CnNewSocket(AF_INET, SOCK_DGRAM, 0);
      if FThisSocket = INVALID_SOCKET then
      begin
        SockCleanup;
        SetupLastError;
        Exit;
      end;
      CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_DONTLINGER, PAnsiChar(CONST_CMD_TRUE), 4);
      CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_BROADCAST, PAnsiChar(CONST_CMD_TRUE), 4);
    end;

    FillChar(Address, SizeOf(Address), 0);
    if FBindAddr <> '' then
      Address.sin_addr.S_addr := inet_addr(PAnsiChar(AnsiString(FBindAddr)))
    else
      Address.sin_addr.S_addr := INADDR_ANY;

    Address.sin_family := AF_INET;
    Address.sin_port := htons(FLocalPort);

    Wait_Flag := False;
    if CnBind(FThisSocket, Address, SizeOf(Address)) = SOCKET_ERROR then
    begin
      SetupLastError;
      SockCleanup;
      Exit;
    end;

    // Allow to send to 255.255.255.255
    Data := 1;
    CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_BROADCAST,
      PAnsiChar(@Data), SizeOf(Data));
    Data := FUDPSendBufSize;
    CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_SNDBUF,
      PAnsiChar(@Data), SizeOf(Data));
    Data := FUDPRecvBufSize;
    CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_RCVBUF,
      PAnsiChar(@Data), SizeOf(Data));

{$IFDEF MSWINDOWS}
    WSAAsyncSelect(FThisSocket, FSocketWindow, WM_ASYNCHRONOUSPROCESS, FD_READ);
{$ELSE}
    // ������߳�
    StopThread;
    StartThread;
{$ENDIF}

    FListening := True;
  end;
end;

procedure TCnUDP.Loaded;
begin
  inherited;
  UpdateBinding;
end;

procedure TCnUDP.SetBindAddr(const Value: string);
begin
  if Value <> FBindAddr then
  begin
    FBindAddr := Value;
    UpdateBinding;
  end;
end;

procedure TCnUDP.SetLocalPort(NewLocalPort: Integer);
begin
  if NewLocalPort <> FLocalPort then
  begin
    FLocalPort := NewLocalPort;
    UpdateBinding;
  end;
end;

function TCnUDP.ResolveRemoteHost(ARemoteHost: string): Boolean;
var
{$IFDEF MSWINDOWS}
  Buf: array[0..127] of AnsiChar;
{$ELSE}
  IP: TIPAddress;
{$ENDIF}
begin
  Result := False;
  if not FListening then
    Exit;

{$IFDEF MSWINDOWS}
  try
    FRemoteAddress.sin_addr.S_addr := Inet_Addr(PAnsiChar(StrPCopy(Buf, {$IFDEF UNICODE}AnsiString{$ENDIF}(ARemoteHost))));
    if FRemoteAddress.sin_addr.S_addr = SOCKET_ERROR then
    begin
      Wait_Flag := False;
      WSAAsyncGetHostByName(FSocketWindow, WM_ASYNCHRONOUSPROCESS, Buf,
        PAnsiChar(RemoteHostS), MAXGETHOSTSTRUCT);
      repeat
        Wait;
      until Wait_Flag;

      if Succeed then
      begin
        with FRemoteAddress.sin_addr.S_un_b do
        begin
          s_b1 := remotehostS.h_addr_list^[0];
          s_b2 := remotehostS.h_addr_list^[1];
          s_b3 := remotehostS.h_addr_list^[2];
          s_b4 := remotehostS.h_addr_list^[3];
        end;
      end;
    end;
  except
    ;
  end;
{$ELSE}
  // POSIX ������첽������ֻ����дͬ��
  IP := TIPAddress.LookupName(ARemoteHost);
  FRemoteAddress.sin_addr := IP.Addr;
{$ENDIF}

  if FRemoteAddress.sin_addr.S_addr <> 0 then
    Result := True;

  if not Result then
    SetupLastError;
end;

function TCnUDP.SendStream(DataStream: TStream; BroadCast: Boolean): Boolean;
var
  Buff: Pointer;
begin
  GetMem(Buff, DataStream.Size);
  try
    DataStream.Position := 0;
    DataStream.Read(Buff^, DataStream.Size);
    Result := SendBuffer(Buff, DataStream.Size, BroadCast);
  finally
    FreeMem(Buff);
  end;
end;

function TCnUDP.SendBuffer(Buff: Pointer; Length: Integer;
  BroadCast: Boolean): Boolean;
var
  Hosts: TStrings;
  I: Integer;

  function DoSendBuffer(Buff: Pointer; Length: Integer; Host: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    try
      if not ResolveRemoteHost(Host) then
        Exit;
      FRemoteAddress.sin_family := AF_INET;
      FRemoteAddress.sin_port := htons(FRemotePort);
      I := SizeOf(FRemoteAddress);

      if CnSendTo(FThisSocket, Buff^, Length, 0, FRemoteAddress, I) <> SOCKET_ERROR then
        Result := True
      else
        SetupLastError;
    except
      SetupLastError;
    end;
  end;

begin
  if BroadCast then
  begin
    Result := False;
    Hosts := TStringList.Create;
    try
      GetBroadCastAddress(Hosts);
      for I := 0 to Hosts.Count - 1 do
        if DoSendBuffer(Buff, Length, Hosts[I]) then
          Result := True;
    finally
      Hosts.Free;
    end;
  end
  else
    Result := DoSendBuffer(Buff, Length, FRemoteHost);
end;

function TCnUDP.GetQueueCount: Integer;
begin
  Result := FQueue.Count;
end;

procedure TCnUDP.FreeQueueItem(P: Pointer);
var
  Rec: PRecvDataRec;
begin
  Rec := PRecvDataRec(P);
  Rec.FromIP := '';
  FreeMem(Rec^.Buff);
  FreeMem(Rec);
end;

procedure TCnUDP.ClearQueue;
var
  Rec: PRecvDataRec;
begin
  while FQueue.Count > 0 do
  begin
    Rec := FQueue.Pop;
    FreeQueueItem(Rec);
  end;
end;

procedure TCnUDP.ProcessQueue;
var
  Rec: PRecvDataRec;
begin
  if FProcing then Exit;
  FProcing := True;
  try
{$IFNDEF MSWINDOWS}
    TMonitor.Enter(FLock);
{$ENDIF}
    while FQueue.Count > 0 do
    begin
      Rec := FQueue.Pop;
      DoDataReceived(Rec^.Buff, Rec^.BuffSize, string(Rec^.FromIP), Rec^.FromPort);
      FreeQueueItem(Rec);
    end;
  finally
{$IFNDEF MSWINDOWS}
    TMonitor.Exit(FLock);
{$ENDIF}
    FProcing := False;
  end;
end;

{$IFDEF MSWINDOWS}

function TCnUDP.ProcessRecv: Boolean;
var
  Unicode: Boolean;
  MsgExists: Boolean;
  Msg: TMsg;
begin
  Unicode := IsWindowUnicode(FSocketWindow);
  if Unicode then
    MsgExists := PeekMessageW(Msg, FSocketWindow, 0, 0, PM_REMOVE)
  else
    MsgExists := PeekMessageA(Msg, FSocketWindow, 0, 0, PM_REMOVE);

  if MsgExists then
  begin
    if Msg.Message <> WM_QUIT then
    begin
      TranslateMessage(Msg);
      if Unicode then
        DispatchMessageW(Msg)
      else
        DispatchMessageA(Msg);
    end;
  end;
  Result := MsgExists;
end;

procedure TCnUDP.WndProc(var Message: TMessage);
begin
  if FListening then
  begin
    with Message do
    begin
      if Msg = WM_ASYNCHRONOUSPROCESS then
      begin
        if LParamLo = FD_READ then
        begin
          ProcessIncomingdata;
          if not FProcing then
            ProcessQueue;
        end
        else
        begin
          Wait_Flag := True;
          if LParamHi > 0 then
            Succeed := False
          else
            Succeed := True;
        end;
        SetEvent(EventHandle);
      end
      else
        Result := DefWindowProc(FSocketWindow, Msg, WParam, LParam);
    end;
  end;
end;

procedure TCnUDP.ProcessIncomingdata;
var
  From: TSockAddr;
  I: Integer;
  Rec: PRecvDataRec;
  IBuffSize: Integer;
begin
  I := SizeOf(From);
  if FRecvBuf = nil then
    GetMem(FRecvBuf, FRecvBufSize);

  IBuffSize := CnRecvFrom(FThisSocket, FRecvBuf^, FRecvBufSize, 0, From, I);
  if (IBuffSize > 0) and Assigned(FOnDataReceived) then
  begin
    GetMem(Rec, SizeOf(TRecvDataRec));
    FillChar(Rec^, SizeOf(TRecvDataRec), 0);

    Rec.FromIP := ShortString(Format('%d.%d.%d.%d', [Ord(From.sin_addr.S_un_b.S_b1),
      Ord(From.sin_addr.S_un_b.S_b2), Ord(From.sin_addr.S_un_b.S_b3),
      Ord(From.sin_addr.S_un_b.S_b4)]));
    Rec.FromPort := ntohs(From.sin_port);

    GetMem(Rec.Buff, IBuffSize);
    Rec.BuffSize := IBuffSize;
    Move(FRecvBuf^, Rec.Buff^, IBuffSize);

    FQueue.Push(Rec);
  end;
end;

procedure WaitforSync(Handle: THandle);
begin
  repeat
    if MsgWaitForMultipleObjects(1, Handle, False, INFINITE, QS_ALLINPUT)
      = WAIT_OBJECT_0 + 1 then
      Application.ProcessMessages
    else
      Break;
  until False;
end;

procedure TCnUDP.Wait;
begin
  WaitforSync(EventHandle);
  ResetEvent(EventHandle);
end;

{$ELSE}

procedure TCnUDP.StartThread;
begin
  if FThread = nil then
  begin
    FThread := TCnUDPReadThread.Create(True);
    FThread.FreeOnTerminate := True;
  end;

  if FRecvBuf = nil then
    GetMem(FRecvBuf, FRecvBufSize);

  TCnUDPReadThread(FThread).UDP := Self;
  FThread.Resume;
end;

procedure TCnUDP.StopThread;
begin
  if FThread = nil then
    Exit;

  FThread.Terminate;
  try
    FThread.WaitFor;
  except
    ;  // WaitFor ʱ�����Ѿ� Terminated�����³������Ч�Ĵ�
  end;
  FThread := nil;
end;

{$ENDIF}

procedure TCnUDP.SetupLastError;
begin
{$IFDEF MSWINDOWS}
  FLastError := WSAGetLastError;
{$ELSE}
  FLastError := GetLastError;
{$ENDIF}
end;

procedure TCnUDP.SockCleanup;
begin
{$IFDEF MSWINDOWS}
  if FSockCount > 0 then
  begin
    Dec(FSockCount);
    if FSockCount = 0 then
      WSACleanup;
  end;
{$ENDIF}
end;

function TCnUDP.SockStartup: Boolean;
{$IFDEF MSWINDOWS}
var
  wsaData: TWSAData;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  if FSockCount = 0 then
  begin
    Result := WSAStartup($0101, wsaData) = 0;
    if not Result then
      Exit;
  end;
  Inc(FSockCount);
{$ENDIF}
  Result := True;
end;

procedure TCnUDP.GetComponentInfo(var AName, Author, Email, Comment: string);
begin
  AName := SCnUDPName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnUDPComment;
end;

function TCnUDP.GetLocalHost: string;
var
  S: array[0..256] of AnsiChar;
{$IFDEF MSWINDOWS}
  P: PHostEnt;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  SockStartup;
  try
    GetHostName(@S, 256);
    P := GetHostByName(@S);
    Result := string(inet_ntoa(PInAddr(P^.h_addr_list^)^));
  finally
    SockCleanup;
  end;
{$ELSE}
  // �ñ��������� IP
  Posix.Unistd.gethostname(@S, 256);
  Result := TIPAddress.LookupName(string(S)).Address;
{$ENDIF}
end;

procedure TCnUDP.SetRecvBufSize(const Value: Cardinal);
begin
  if FRecvBufSize <> Value then
  begin
    FRecvBufSize := Value;
    if FRecvBuf <> nil then
    begin
      // �ͷţ��ȴ��´���Ҫʱ���·���
      FreeMem(FRecvBuf);
      FRecvBuf := nil;
    end;
  end;
end;

procedure TCnUDP.SetUDPRecvBufSize(const Value: Cardinal);
var
  Data: Cardinal;
begin
  FUDPRecvBufSize := Value;
  if FListening then
  begin
    Data := FUDPRecvBufSize;
    CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_RCVBUF,
      PAnsiChar(@Data), SizeOf(Data));
  end;
end;

procedure TCnUDP.SetUDPSendBufSize(const Value: Cardinal);
var
  Data: Cardinal;
begin
  FUDPSendBufSize := Value;
  if FListening then
  begin
    Data := FUDPSendBufSize;
    CnSetSockOpt(FThisSocket, SOL_SOCKET, SO_SNDBUF,
      PAnsiChar(@Data), SizeOf(Data));
  end;
end;

{$IFNDEF MSWINDOWS}

{ TCnUDPReadThread }

procedure TCnUDPReadThread.Execute;
var
  Res, I, FromPort: Integer;
  From: TSockAddr;
  Rec: PRecvDataRec;
begin
  if (UDP = nil) or (UDP.FRecvBuf = nil) then
    Exit;

  I := SizeOf(From);
  while not Terminated do
  begin
    Res := CnRecvFrom(UDP.FThisSocket, UDP.FRecvBuf^, UDP.FRecvBufSize, 0, From, I);

    if Res <> SOCKET_ERROR then
    begin
      if Res = 0 then
        Continue;

      GetMem(Rec, SizeOf(TRecvDataRec));
      FillChar(Rec^, SizeOf(TRecvDataRec), 0);

      GetMem(Rec^.Buff, Res);
      Rec^.FromIP := TIPAddress.Create(From.sin_addr).Address;
      Rec^.FromPort := ntohs(From.sin_port);
      Rec^.BuffSize := Res;
      Move(UDP.FRecvBuf^, Rec^.Buff^, Res);

{$IFNDEF MSWINDOWS}
      TMonitor.Enter(UDP.FLock);
{$ENDIF}
      UDP.FQueue.Push(Rec);
{$IFNDEF MSWINDOWS}
      TMonitor.Exit(UDP.FLock);
{$ENDIF}

      Synchronize(ProcessData);
    end;
  end;
end;

procedure TCnUDPReadThread.ProcessData;
begin
  if not UDP.FProcing then
    UDP.ProcessQueue
  else if UDP.FQueue.Count > 0 then
  begin
    Sleep(0);
    Synchronize(ProcessData);
  end;
end;

{$ENDIF}

end.

