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

unit CnTCPClient;
{* |<PRE>
================================================================================
* ������ƣ�����ͨѶ�����
* ��Ԫ���ƣ�����ͨѶ����� TCP Client ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ Liu Xiao
* ��    ע��һ�����׵Ķ��߳�����ʽ TCP Server���¿ͻ�������ʱ�����̣߳�������
*           �� OnAccept �¼���ѭ�� recv/send ���ɣ����̳߳ػ���
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.02.22 V1.1
*                �����ƽ̨��֧�֣�������
*           2020.02.22 V1.0
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
  System.Net.Socket, Posix.NetinetIn, Posix.SysSocket, Posix.Unistd, Posix.ArpaInet,
{$ENDIF}
  CnConsts, CnNetConsts, CnSocket, CnClasses;

type
  ECnClientSocketError = class(Exception);

  TCnClientSocketErrorEvent = procedure (Sender: TObject; SocketError: Integer) of object;

{$IFDEF SUPPORT_32_AND_64}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF}
  TCnTCPClient = class(TCnComponent)
  private
    FSocket: TSocket;
    FActive: Boolean;
    FConnected: Boolean;
    FBytesReceived: Cardinal;
    FBytesSent: Cardinal;
    FRemoteHost: string;
    FOnError: TCnClientSocketErrorEvent;
    FOnConnect: TNotifyEvent;
    FOnDisconnect: TNotifyEvent;
    FRemotePort: Word;
    procedure SetActive(const Value: Boolean);
    procedure SetRemoteHost(const Value: string);
    procedure SetRemotePort(const Value: Word);
    function CheckSocketError(ResultCode: Integer): Integer;
  protected
    procedure GetComponentInfo(var AName, Author, Email, Comment: string); override;
    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Open;
    {* ��ʼ���ӣ���ͬ�� Active := True}
    procedure Close;
    {* �ر����ӣ���ͬ�� Active := False}

    class function LookupHostAddr(const HostName: string): string;

    // send/recv �շ����ݷ�װ
    function Send(var Buf; Len: Integer; Flags: Integer = 0): Integer;
    function Recv(var Buf; Len: Integer; Flags: Integer = 0): Integer;
    // ע�� Recv ���� 0 ʱ˵����ǰ����Է��ѶϿ����� Client ���Զ� Close��
    // ������Ҳ��Ҫ���ݷ���ֵ���Ͽ�����

    property BytesSent: Cardinal read FBytesSent;
    {* ���͸����ͻ��˵����ֽ���}
    property BytesReceived: Cardinal read FBytesReceived;
    {* �Ӹ��ͻ�����ȡ�����ֽ���}
    property Connected: Boolean read FConnected;
    {* �Ƿ�������}
  published
    property Active: Boolean read FActive write SetActive;
    {* �Ƿ�ʼ����}
    property RemoteHost: string read FRemoteHost write SetRemoteHost;
    {* Ҫ���ӵ�Զ������}
    property RemotePort: Word read FRemotePort write SetRemotePort;
    {* Ҫ���ӵ�Զ�̶˿�}

    property OnError: TCnClientSocketErrorEvent read FOnError write FOnError;
    {* �����¼�}
    property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
    {* ���ӳɹ����¼�}
    property OnDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;
    {* ���ӶϿ����¼�}
  end;

implementation

{$IFDEF MSWINDOWS}
var
  WSAData: TWSAData;
{$ENDIF}

{ TCnTCPClient }

function TCnTCPClient.CheckSocketError(ResultCode: Integer): Integer;
begin
  Result := ResultCode;
  if ResultCode = SOCKET_ERROR then
  begin
    if Assigned(FOnError) then
    begin
{$IFDEF MSWINDOWS}
      FOnError(Self, WSAGetLastError);
{$ELSE}
      FOnError(Self, GetLastError);
{$ENDIF};
    end;
  end;
end;

procedure TCnTCPClient.Close;
begin
  if FActive then
  begin
    if FConnected then
    begin
      FConnected := False;
      CnShutdown(FSocket, SD_BOTH);

      DoDisconnect;
    end;

    FActive := False;
    CheckSocketError(CnCloseSocket(FSocket));

    FSocket := INVALID_SOCKET;
  end;
end;

constructor TCnTCPClient.Create(AOwner: TComponent);
begin
  inherited;
  FSocket := INVALID_SOCKET;
end;

destructor TCnTCPClient.Destroy;
begin
  Close;
  inherited;
end;

procedure TCnTCPClient.DoConnect;
begin
  if Assigned(FOnConnect) then
    FOnConnect(Self);
end;

procedure TCnTCPClient.DoDisconnect;
begin
  if Assigned(FOnDisconnect) then
    FOnDisconnect(Self);
end;

procedure TCnTCPClient.GetComponentInfo(var AName, Author, Email,
  Comment: string);
begin
  AName := SCnTCPClientName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnTCPClientComment;
end;

class function TCnTCPClient.LookupHostAddr(const HostName: string): string;
{$IFDEF MSWINDOWS}
var
  H: PHostEnt;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := '';
  if HostName <> '' then
  begin
    if HostName[1] in ['0'..'9'] then // IP ��ַ
    begin
      if inet_addr(PAnsiChar(AnsiString(HostName))) <> INADDR_NONE then
        Result := HostName;
    end
    else
    begin
      H := gethostbyname(PAnsiChar(AnsiString(HostName)));
      if H <> nil then
        with H^ do
        Result := Format('%d.%d.%d.%d', [Ord(h_addr^[0]), Ord(h_addr^[1]),
          Ord(h_addr^[2]), Ord(h_addr^[3])]);
    end;
  end
  else
    Result := '0.0.0.0';
{$ELSE}
  Result := TIPAddress.LookupName(HostName).Address;
{$ENDIF}
end;

procedure TCnTCPClient.Open;
var
  SockAddress: TSockAddr;
begin
  if not FActive then
  begin
    FSocket := CnNewSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    FActive := FSocket <> INVALID_SOCKET;

    if FActive and not FConnected then
    begin
      FBytesReceived := 0;
      FBytesSent := 0;

      SockAddress.sin_family := AF_INET;
      SockAddress.sin_port := ntohs(FRemotePort);

{$IFDEF MSWINDOWS}
      SockAddress.sin_addr.s_addr := inet_addr(PAnsiChar(AnsiString(LookupHostAddr(FRemoteHost))));
{$ELSE}
      SockAddress.sin_addr := TIPAddress.LookupName(FRemoteHost);
{$ENDIF}

      FConnected := CheckSocketError(CnConnect(FSocket, SockAddress, SizeOf(SockAddress))) = 0;
      if FConnected then
        DoConnect;
    end;
  end;
end;

function TCnTCPClient.Recv(var Buf; Len, Flags: Integer): Integer;
begin
  Result := CheckSocketError(CnRecv(FSocket, Buf, Len, Flags));

  if Result <> SOCKET_ERROR then
  begin
    if Result = 0 then
      Close
    else
      Inc(FBytesReceived, Result);
  end
end;

function TCnTCPClient.Send(var Buf; Len, Flags: Integer): Integer;
begin
  Result := CheckSocketError(CnSend(FSocket, Buf, Len, Flags));

  if Result <> SOCKET_ERROR then
    Inc(FBytesSent, Result);
end;

procedure TCnTCPClient.SetActive(const Value: Boolean);
begin
  if Value <> FActive then
  begin
    if not (csLoading in ComponentState) and not (csDesigning in ComponentState) then
      if Value then
        Open
      else
        Close
    else
      FActive := Value;
  end;
end;

procedure TCnTCPClient.SetRemoteHost(const Value: string);
begin
  FRemoteHost := Value;
end;

procedure TCnTCPClient.SetRemotePort(const Value: Word);
begin
  FRemotePort := Value;
end;

{$IFDEF MSWINDOWS}

procedure Startup;
var
  ErrorCode: Integer;
begin
  ErrorCode := WSAStartup($0101, WSAData);
  if ErrorCode <> 0 then
    raise ECnClientSocketError.Create('WSAStartup');
end;

procedure Cleanup;
var
  ErrorCode: Integer;
begin
  ErrorCode := WSACleanup;
  if ErrorCode <> 0 then
    raise ECnClientSocketError.Create('WSACleanup');
end;

initialization
  Startup;

finalization
  Cleanup;

{$ENDIF}

end.
