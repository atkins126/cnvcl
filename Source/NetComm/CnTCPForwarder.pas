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

unit CnTCPForwarder;
{* |<PRE>
================================================================================
* ������ƣ�����ͨѶ�����
* ��Ԫ���ƣ�����ͨѶ����� TCP �˿�ת��ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ Liu Xiao
* ��    ע��һ��ʹ�� ThreadingTCPServer �Ķ��̶߳˿�ת����������̳߳ػ���
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.11.24 V1.1
*                �Զ�������������ԭʼ����������Ҳ����ʹ���������������ɵ������ͷ�
*           2022.11.15 V1.1
*                �����Զ������ݵĹ���
*           2020.02.25 V1.0
*                ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs,
{$IFDEF MSWINDOWS}
  Windows,  WinSock,
{$ELSE}
  System.Net.Socket, Posix.NetinetIn, Posix.SysSocket, Posix.Unistd,
  Posix.ArpaInet, Posix.SysSelect,
{$ENDIF}
  CnConsts, CnNetConsts, CnClasses, CnSocket,
  CnThreadingTCPServer, CnTCPClient;

type
  TCnForwarderEvent = procedure (Sender: TObject; Buf: Pointer; var DataSize: Integer;
    var NewBuf: Pointer; var NewDataSize: Integer) of object;
  {* ת��ʱ�����������¼���ԭʼ���ݴ��� Buf ��ָ�����򣬳���Ϊ DataSize
    �¼������߿��������Ƭ����������䲢�������ݳ��ȣ���ʱ���账�� NewBuf �� NewDataSize����
    ע�ⲻ�ɳ���ԭ�е� DataSize���罫 DataSize �� 0����ʾ������������
    ����¼������������� NewBuf �� NewDataSize����ʾʹ�������һƬ���ݣ�ԭʼ��������}

{$IFDEF SUPPORT_32_AND_64}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF}
  TCnTCPForwarder = class(TCnThreadingTCPServer)
  {* TCP �˿�ת���������ÿ���ͻ��������������߳�}
  private
    FRemoteHost: string;
    FRemotePort: Word;
    FOnRemoteConnected: TNotifyEvent;
    FOnServerData: TCnForwarderEvent;
    FOnClientData: TCnForwarderEvent;
    procedure SetRemoteHost(const Value: string);
    procedure SetRemotePort(const Value: Word);
  protected
    procedure GetComponentInfo(var AName, Author, Email, Comment: string); override;

    function DoGetClientThread: TCnTCPClientThread; override;
    {* ��������ʹ�� TCnTCPForwardThread}

    procedure DoRemoteConnected; virtual;
    procedure DoServerData(Buf: Pointer; var DataSize: Integer;
      var NewBuf: Pointer; var NewDataSize: Integer); virtual;
    procedure DoClientData(Buf: Pointer; var DataSize: Integer;
      var NewBuf: Pointer; var NewDataSize: Integer); virtual;
  published
    property RemoteHost: string read FRemoteHost write SetRemoteHost;
    {* ת����Զ������}
    property RemotePort: Word read FRemotePort write SetRemotePort;
    {* ת����Զ�̶˿�}

    property OnRemoteConnected: TNotifyEvent read FOnRemoteConnected write FOnRemoteConnected;
    {* ������Զ�̷�����ʱ����}

    property OnServerData: TCnForwarderEvent read FOnServerData write FOnServerData;
    {* Զ������������ʱ����������ԭʼ���ݣ�Ҳ�������µ����ݿ飬�����ɵ����߸���������ͷ�}
    property OnClientData: TCnForwarderEvent read FOnClientData write FOnClientData;
    {* �ͻ���������ʱ����������ԭʼ���ݣ�Ҳ�������µ����ݿ飬�����ɵ����߸���������ͷ�}
  end;

implementation

const
  FORWARDER_BUF_SIZE = 32 * 1024;

type
  TCnForwarderClientSocket = class(TCnClientSocket)
  {* ��װ�Ĵ���һ�ͻ�������ת���Ķ��󣬰���˫��ͨѶ����һ�� Socket}
  private
    FRemoteSocket: TSocket;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Shutdown; override;
    {* �ر�ǰ��������� Socket}

    // send/recv �շ����ݷ�װ
    function RemoteSend(var Buf; Len: Integer; Flags: Integer = 0): Integer;
    function RemoteRecv(var Buf; Len: Integer; Flags: Integer = 0): Integer;

    property RemoteSocket: TSocket read FRemoteSocket write FRemoteSocket;
    {* ����Զ�̷������� Socket}
  end;

  TCnTCPForwardThread = class(TCnTCPClientThread)
  {* �пͻ���������ʱ�Ĵ����̣߳��ӿͻ��˷����˫���д}
  protected
    function DoGetClientSocket: TCnClientSocket; override;
    procedure Execute; override;
  end;

{ TCnTCPForwarder }

procedure TCnTCPForwarder.DoClientData(Buf: Pointer; var DataSize: Integer;
  var NewBuf: Pointer; var NewDataSize: Integer);
begin
  if Assigned(FOnClientData) then
    FOnClientData(Self, Buf, DataSize, NewBuf, NewDataSize);
end;

function TCnTCPForwarder.DoGetClientThread: TCnTCPClientThread;
begin
  Result := TCnTCPForwardThread.Create(True);
end;

procedure TCnTCPForwarder.DoRemoteConnected;
begin
  if Assigned(FOnRemoteConnected) then
    FOnRemoteConnected(Self);
end;

procedure TCnTCPForwarder.DoServerData(Buf: Pointer; var DataSize: Integer;
  var NewBuf: Pointer; var NewDataSize: Integer);
begin
  if Assigned(FOnServerData) then
    FOnServerData(Self, Buf, DataSize, NewBuf, NewDataSize);
end;

procedure TCnTCPForwarder.GetComponentInfo(var AName, Author, Email,
  Comment: string);
begin
  AName := SCnTCPForwarderName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnTCPForwarderComment;
end;

procedure TCnTCPForwarder.SetRemoteHost(const Value: string);
begin
  FRemoteHost := Value;
end;

procedure TCnTCPForwarder.SetRemotePort(const Value: Word);
begin
  FRemotePort := Value;
end;

{ TCnTCPForwardThread }

function TCnTCPForwardThread.DoGetClientSocket: TCnClientSocket;
begin
  Result := TCnForwarderClientSocket.Create;
end;

procedure TCnTCPForwardThread.Execute;
var
  Client: TCnForwarderClientSocket;
  Forwarder: TCnTCPForwarder;
  Buf: array[0..FORWARDER_BUF_SIZE - 1] of Byte;
  NewBuf: Pointer;
  Ret, NewSize: Integer;
  SockAddress: TSockAddr;
{$IFDEF MSWINDOWS}
  ReadFds: TFDSet;
{$ELSE}
  ReadFds: fd_set;
{$ENDIF}
begin
  // �ͻ����������ϣ��¼����в����ɱ���
  DoAccept;
  Forwarder := TCnTCPForwarder(ClientSocket.Server);

  Client := TCnForwarderClientSocket(ClientSocket);
  Client.RemoteSocket := Forwarder.CheckSocketError(socket(AF_INET, SOCK_STREAM, IPPROTO_TCP));
  if Client.RemoteSocket = INVALID_SOCKET then
    Exit;

  SockAddress.sin_family := AF_INET;
  SockAddress.sin_addr.s_addr := inet_addr(PAnsiChar(AnsiString(TCnTCPClient.LookupHostAddr(Forwarder.RemoteHost))));
  SockAddress.sin_port := ntohs(Forwarder.RemotePort);

  Ret := Forwarder.CheckSocketError(CnConnect(Client.RemoteSocket, SockAddress, SizeOf(SockAddress)));
  if Ret <> 0 then
  begin
    // ����Զ�̷�����ʧ�ܣ������˳�
    Forwarder.CheckSocketError(CnCloseSocket(Client.RemoteSocket));

    Client.RemoteSocket := INVALID_SOCKET;
    Exit;
  end;

  Forwarder.DoRemoteConnected;

  // ���ӳɹ��󣬱��߳̿�ʼѭ��ת�����������˳�
  while not Terminated do
  begin
    // SELECT ���� Socket �ϵ���Ϣ��׼������дȥ
    CnFDZero(ReadFds);
    CnFDSet(Client.Socket, ReadFds);
    CnFDSet(Client.RemoteSocket, ReadFds);

    Ret := Forwarder.CheckSocketError(CnSelect(0, @ReadFds, nil, nil, nil));
    if Ret <= 0 then
    begin
      Client.Shutdown;
      Exit;
    end;

    if CnFDIsSet(Client.Socket, ReadFds) then // �ͻ�����������
    begin
      Ret := Client.Recv(Buf, SizeOf(Buf));
      if Ret <= 0 then
      begin
        Client.Shutdown;
        Exit;
      end;

      // �����һ���������ݵĻ���
      NewBuf := nil;
      NewSize := 0;
      TCnTCPForwarder(Client.Server).DoClientData(@Buf[0], Ret, NewBuf, NewSize);
      if (NewBuf <> nil) and (NewSize > 0) then // ����������ݾͷ�
      begin
        Ret := Client.RemoteSend(NewBuf^, NewSize); // ���������
        if Ret <= 0 then
        begin
          Client.Shutdown;
          Exit;
        end;
      end
      else if Ret > 0 then // ����������ԭʼ���ݾͷ�
      begin
        Ret := Client.RemoteSend(Buf, Ret); // ���������
        if Ret <= 0 then
        begin
          Client.Shutdown;
          Exit;
        end;
      end;
    end;

    if CnFDIsSet(Client.RemoteSocket, ReadFds) then // �������������
    begin
      Ret := Client.RemoteRecv(Buf, SizeOf(Buf));
      if Ret <= 0 then
      begin
        Client.Shutdown;
        Exit;
      end;

      // �����һ���������ݵĻ���
      NewBuf := nil;
      NewSize := 0;
      TCnTCPForwarder(Client.Server).DoServerData(@Buf[0], Ret, NewBuf, NewSize);
      if (NewBuf <> nil) and (NewSize > 0) then // ����������ݾͷ�
      begin
        Ret := Client.Send(NewBuf^, NewSize); // �����ͻ���
        if Ret <= 0 then
        begin
          Client.Shutdown;
          Exit;
        end;
      end
      else if Ret > 0 then // �������������ݾͷ�
      begin
        Ret := Client.Send(Buf, Ret); // �����ͻ���
        if Ret <= 0 then
        begin
          Client.Shutdown;
          Exit;
        end;
      end;
    end;
    Sleep(0);
  end;
end;

{ TCnForwarderClientSocket }

procedure TCnForwarderClientSocket.Shutdown;
begin
  inherited;
  if FRemoteSocket <> INVALID_SOCKET then
  begin
    (Server as TCnTCPForwarder).CheckSocketError(CnShutdown(FRemoteSocket, SD_BOTH));
    (Server as TCnTCPForwarder).CheckSocketError(CnCloseSocket(FRemoteSocket));

    FRemoteSocket := INVALID_SOCKET;
  end;
end;

constructor TCnForwarderClientSocket.Create;
begin
  inherited;

end;

destructor TCnForwarderClientSocket.Destroy;
begin

  inherited;
end;

function TCnForwarderClientSocket.RemoteRecv(var Buf; Len,
  Flags: Integer): Integer;
begin
  Result := (Server as TCnTCPForwarder).CheckSocketError(
    CnRecv(FRemoteSocket, Buf, Len, Flags));
end;

function TCnForwarderClientSocket.RemoteSend(var Buf; Len,
  Flags: Integer): Integer;
begin
  Result := (Server as TCnTCPForwarder).CheckSocketError(
    CnSend(FRemoteSocket, Buf, Len, Flags));
end;

end.
