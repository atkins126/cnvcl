{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2007 CnPack ������                       }
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

unit uCnPingDemo;
{* |<PRE>
================================================================================
* ������ƣ�CnPing CnIP ���Գ���
* ��Ԫ���ƣ�CnPing CnIP ���Գ�������Ԫ
* ��Ԫ���ߣ�������(Sesame) sesamehch@163.com
* ��    ע��
* ����ƽ̨��PWin2000 + Delphi 5
* ���ݲ��ԣ����ޣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6��
* �� �� �����ô����е��ַ����ݲ����ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: uCnPingDemo.pas,v 1.1 2008/05/23 14:03:51 liuxiao Exp $
* �޸ļ�¼��2008.04.12 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

uses
  {$IFDEF MSWINDOWS} Windows, Messages, Winsock, {$ENDIF} SysUtils, Classes, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.ExtCtrls,
  CnIP, CnPing, FMX.Edit, FMX.ListBox, FMX.Memo, FMX.TabControl, FMX.Types, System.Types, System.UITypes,
  FMX.Memo.Types, FMX.Layouts, FMX.ScrollBox, FMX.Controls.Presentation;

type
  TfrmCnPingDemo = class(TForm)
    Label1: TLabel;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    edtStartIP: TEdit;
    edtEndIP: TEdit;
    btnPingOnce: TButton;
    btnPingBuffer: TButton;
    btnIPInfo: TButton;
    btnPing: TButton;
    Panel3: TPanel;
    pgcResult: TTabControl;
    TabSheet1: TTabItem;
    redtPing: TMemo;
    TabSheet2: TTabItem;
    chklstResult: TListBox;
    TabSheet3: TTabItem;
    redtPingBuffer: TMemo;
    TabSheet4: TTabItem;
    redtIPInfo: TMemo;
    statDemo: TStatusBar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnPingOnceClick(Sender: TObject);
    procedure btnPingBufferClick(Sender: TObject);
    procedure btnIPInfoClick(Sender: TObject);
    procedure btnPingClick(Sender: TObject);
  private
    Ping: TCnPing;
    IP: TCnIp;
    FLocalIP, FResult: string;
    procedure CheckIP(Sender: TControl);
  public

  end;

var
  frmCnPingDemo: TfrmCnPingDemo;

implementation

{$R *.fmx}

procedure TfrmCnPingDemo.FormCreate(Sender: TObject);
begin
  Ping := TCnPing.Create(Self); //��ʼ��
  IP := TCnIP.Create(Self); //��ʼ��
  FLocalIP := IP.IPAddress;
  edtStartIP.Text := IP.IPAddress;
  edtEndIP.Text := IP.NextIP(edtStartIP.Text);
  btnIPInfoClick(btnIPInfo);
end;

procedure TfrmCnPingDemo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeAndNil(IP);
  FreeAndNil(Ping);
end;

procedure TfrmCnPingDemo.CheckIP(Sender: TControl);
begin
  if IP.IPTypeCheck(edtStartIP.Text) = iptNone then
  begin
    ShowMessage('IP��ַ����');
    Abort;
  end;
  if Sender.Tag = 0 then
  begin
    if IP.IPTypeCheck(edtEndIP.Text) = iptNone then
    begin
      ShowMessage('IP��ַ����');
      Abort;
    end;
    if IP.IPToInt(edtendIP.Text) < IP.IPToInt(edtStartIP.Text) then
    begin
      ShowMessage('����IP��ַС�ڿ�ʼ��ַ');
      Abort;
    end;
  end;
  pgcResult.TabIndex := Sender.Tag;
end;

procedure TfrmCnPingDemo.btnPingClick(Sender: TObject);
begin
  CheckIP(TButton(Sender));
  //statDemo.Panels[0].Text := '����Ping';
  Ping.RemoteHost := IP.ComputerName;
  Ping.Ping(FResult);
  redtPing.Lines.Text := FResult;
end;

procedure TfrmCnPingDemo.btnPingOnceClick(Sender: TObject);
var
  iIP: Cardinal;
  bOnLine: Boolean;
begin
  CheckIP(TButton(Sender));
  chklstResult.Items.Clear;
  for iIP := IP.IPToInt(edtStartIP.Text) to IP.IPToInt(edtendIP.Text) do
  begin
    Ping.RemoteIP := IP.IntToIP(iIP);
    //statDemo.Panels[0].Text := '����Ping to ' + Ping.RemoteHost;
    //Update;
    bOnLine := Ping.PingOnce(FResult);
    chklstResult.Items.Add(FResult);
    chklstResult.ListItems[chklstResult.Items.Count - 1].IsChecked := bOnLine;
    Application.ProcessMessages;
  end;
end;

procedure TfrmCnPingDemo.btnPingBufferClick(Sender: TObject);
var
  sData: string;
begin
  CheckIP(TButton(Sender));
  //statDemo.Panels[0].Text := '����PingFromBuffer';
  sData:='�й����Լ��Ŀ���Դ�������������CnPing CnIP';
  Ping.RemoteIP := IP.IntToIP(IP.IPToInt(edtStartIP.Text));
  Ping.PingFromBuffer(sData[1], Length(sData) * SizeOf(Char), FResult);
  redtPingBuffer.Lines.Text := FResult;
end;

procedure TfrmCnPingDemo.btnIPInfoClick(Sender: TObject);
const
  IPINFO = '���������: %0:S' + #13#10
    + '����IP��ַ: %1:S' + #13#10
    + '��������: %2:S' + #13#10
    + 'Mac��ַ: %3:S' + #13#10
    + '�㲥��ַ: %4:S' + #13#10
    + 'IP��ַ��: %5:D' + #13#10
    + '���ɵ�������: %6:D' + #13#10;
  BOOL_STRS: array[False..True] of string = ('False', 'True');
var
  I: Integer;
  IpGroups: TCnIPGroup;
begin
  CheckIP(TButton(Sender));
  IP.IPAddress := FLocalIP;
  //statDemo.Panels[0].Text := '����IP��Ϣ';
  redtIPInfo.Lines.Text := Format(IPINFO, [IP.ComputerName, IP.IPAddress,
    IP.SubnetMask, IP.MacAddress, IP.BroadCastIP, IP.LocalIPCount, IP.Hosts]);

  IpGroups := IP.LocalIPGroup;
  for I := Low(IpGroups) to High(IpGroups) do
  begin
    redtIPInfo.Lines.Add('================ ' + IntToStr(I));
    redtIPInfo.Lines.Add(IP.IntToIP(IpGroups[I].IPAddress));
    redtIPInfo.Lines.Add(IP.IntToIP(IpGroups[I].SubnetMask));
    redtIPInfo.Lines.Add(IP.IntToIP(IpGroups[I].BroadCast));
    redtIPInfo.Lines.Add('UpState ' + BOOL_STRS[IpGroups[I].UpState]);
    redtIPInfo.Lines.Add('Loopback ' + BOOL_STRS[IpGroups[I].Loopback]);
    redtIPInfo.Lines.Add('SupportBroadcast ' + BOOL_STRS[IpGroups[I].SupportBroadcast]);
  end;
end;

end.

