{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
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

unit CnKeyBlocker;
{* |<PRE>
================================================================================
* ������ƣ������ӹ��������
* ��Ԫ���ƣ�ͨ�����̹�������ϵͳ�������
* ��Ԫ���ߣ�����
* ��    ֲ����Х (liuxiao@cnpack.org)
* ��    ע�������ͨ��ʵ�ּ��̹���������ĳЩϵͳ������ Ctrl+Alt+Del ��ϼ�����
*           ��Ϊϵͳ������ԭ����޷����Ρ�
* ����ƽ̨��PWinXP + Delphi 7.0 (Build 8.1)
* ���ݲ��ԣ�PWin2003 + Delphi 7.0 (Build 8.1)
* �� �� �����õ�Ԫ�����ַ�����Դ
* �޸ļ�¼��2021.09.17 v1.1
*               ����������������һ�� CustomKeyCode δ���µ�����
*           2008.10.24 v1.1
*               ����һ��ª�¼�
*           2008.05.29 v1.0
*               ��ֲ��Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, ShlObj, Registry, ShellAPI, Messages;

type
  TCnBlockKeyEvent = procedure(VirtualKey: Cardinal) of object;

  TCnKeyBlocker = class(TComponent)
  private
    FBlockCtrlAltDelete: Boolean;
    FBlockAltTab: Boolean;
    FBlockCtrlEsc: Boolean;
    FEnabled: Boolean;
    FBlockAltEsc: Boolean;
    FBlockCtrlEnter: Boolean;
    FBlockCustomKey: Boolean;
    FBlockPower: Boolean;
    FBlockSleep: Boolean;
    FCustomKeyCode: Cardinal;
    FBlockWinApps: Boolean;
    FBlockCtrlAltEnter: Boolean;
    FOnBlockKey: TCnBlockKeyEvent;
    procedure SetBlockCtrlAltDelete(const Value: Boolean);
    procedure SetBlockAltTab(const Value: Boolean);
    procedure SetBlockCtrlEsc(const Value: Boolean);
    procedure SetEnabled(const Value: Boolean);
    procedure SetBlockAltEsc(const Value: Boolean);
    procedure SetBlockCustomKey(const Value: Boolean);
    procedure SetBlockCtrlEnter(const Value: Boolean);
    procedure SetBlockPower(const Value: Boolean);
    procedure SetBlockSleep(const Value: Boolean);
    procedure SetBlockWinApps(const Value: Boolean);
    procedure SetBlockCtrlAltEnter(const Value: Boolean);
    procedure SetCustomKeyCode(const Value: Cardinal);
  protected
    procedure UpdateKeyBlock;
    procedure DoBlock(VirtualKey: Cardinal);
    property BlockCtrlAltDelete: Boolean read FBlockCtrlAltDelete write SetBlockCtrlAltDelete;
    {* �Ƿ����� Ctrl+Alt+Delete ���������Կ����޷���������ʱ������}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BlockAltTab: Boolean read FBlockAltTab write SetBlockAltTab;
    {* �Ƿ����� Alt+Tab ��}
    property BlockCtrlEsc: Boolean read FBlockCtrlEsc write SetBlockCtrlEsc;
    {* �Ƿ����� Ctrl+Esc ��}
    property BlockAltEsc: Boolean read FBlockAltEsc write SetBlockAltEsc;
    {* �Ƿ����� Alt+Esc ��}
    property BlockCtrlEnter: Boolean read FBlockCtrlEnter write SetBlockCtrlEnter;
    {* �Ƿ����� Ctrl+Enter ��}
    property BlockSleep: Boolean read FBlockSleep write SetBlockSleep;
    {* �Ƿ����� Sleep ���߼�}
    property BlockPower: Boolean read FBlockPower write SetBlockPower;
    {* �Ƿ����� Power ��Դ��}
    property BlockWinApps: Boolean read FBlockWinApps write SetBlockWinApps;
    {* �Ƿ����� Windows ��}
    property BlockCtrlAltEnter: Boolean read FBlockCtrlAltEnter write SetBlockCtrlAltEnter;
    {* �Ƿ����� Ctrl+Alt+Enter ��}

    property CustomKeyCode: Cardinal read FCustomKeyCode write SetCustomKeyCode default 0;
    {* �Զ�������μ�}
    property BlockCustomKey: Boolean read FBlockCustomKey write SetBlockCustomKey;
    {* �Ƿ������Զ����}

    property Enabled: Boolean read FEnabled write SetEnabled default False;
    {* �Ƿ�ʹ�����ι���}

    property OnBlockKey: TCnBlockKeyEvent read FOnBlockKey write FOnBlockKey;
    {* ���μ�ʱ�������¼������ڸ����ԣ�������ָֻ����������������ڹҽӻ��Ʊ���
       �Ļ��ƣ����¼��� Sender��}
  end;

implementation

const
  LLKHF_ALTDOWN = KF_ALTDOWN shr 8;
  WH_KEYBOARD_LL = 13;

type
  PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;
  KBDLLHOOKSTRUCT = packed record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    Time: DWORD;
    dwExtraInfo: DWORD;
  end;

var
  hhkNTKeyboard: HHOOK = 0;
  aBlockCtrlAltDelete: Boolean = False;
  aBlockWinApps: Boolean = False;
  aBlockCtrlEsc: Boolean = False;
  aBlockAltTab: Boolean = False;
  aBlockAltEsc: Boolean = False;
  aBlockCtrlEnter: Boolean = False;
  aBlockCtrlAltEnter: Boolean = False;
  aBlockPower: Boolean = False;
  aBlockSleep: Boolean = False;
  aBlockCustomKey: Boolean = False;
  aCustomKeyCode: Cardinal = 0;

  FKeyBlocker: TCnKeyBlocker = nil;

{ TCnKeyBlocker }

constructor TCnKeyBlocker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKeyBlocker := Self;
end;

procedure EnableCTRLALTDEL(YesNo: Boolean);
const
  sRegPolicies = '\Software\Microsoft\Windows\CurrentVersion\Policies';
begin
  with TRegistry.Create do
  try
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(sRegPolicies + '\System\', True) then
    begin
      case YesNo of
        False:
          begin
            WriteInteger('DisableTaskMgr', 1); //�������
            WriteInteger('DisableLockWorkstation', 1); //�û����������
            WriteInteger('DisableChangePassword', 1); //�û����Ŀ���
          end;
        True:
          begin
            WriteInteger('DisableTaskMgr', 0);
            WriteInteger('DisableLockWorkstation', 0);
            WriteInteger('DisableChangePassword', 0);
          end;
      end;
    end;
    CloseKey;
    if OpenKey(sRegPolicies + '\Explorer\', True) then
    begin
      case YesNo of
        False:
          begin
            WriteInteger('NoChangeStartMenu', 1); //��ʼ�˵�
            WriteInteger('NoClose', 1); // �ر�ϵͳ�˵�
            WriteInteger('NoLogOff', 1); //ע���˵�
            WriteInteger('NoRun', 1); //���в˵�
            WriteInteger('NoSetFolders', 1); //���ò˵�
          end;
        True:
          begin
            WriteInteger('NoChangeStartMenu', 0);
            WriteInteger('NoClose', 0);
            WriteInteger('NoLogOff', 0);
            WriteInteger('NoRun', 0);
          end;
      end;
    end;
    CloseKey;
  finally
    Free;
  end;
end;

function LowLevelKeyboardFunc(nCode: INTEGER; w_Param: WPARAM;
  l_Param: LPARAM): LRESULT; stdcall;
var
  boolKey: Boolean;
  p: PKBDLLHOOKSTRUCT;
const
  VK_SLEEP = $5F;
  VK_POWER = $5E;
begin
  boolKey := False;
  p := nil;
  if nCode = HC_ACTION then
  begin
    case w_Param of
      WM_KEYDOWN, WM_SYSKEYDOWN, WM_KEYUP, WM_SYSKEYUP:
        begin
          p := PKBDLLHOOKSTRUCT(l_Param);
      //---------!-~------------------------------------------------
      {    if ((GetAsyncKeyState(VK_RBUTTON) and $8000) <> 0) then boolKey := True;
          if (CHAR(p.vkCode) >= '!') and (CHAR(p.vkCode) <= '~') and
            ((GetKeyState(VK_CONTROL) and $8000) <> 0) then boolKey := True;
          if (p.vkCode = VK_SPACE) and
            ((GetKeyState(VK_CONTROL) and $8000) <> 0) then boolKey := True;    }

      //---------F1-F12 ----------------------------------------------
      {    if (p.vkCode = VK_F1) or (p.vkCode = VK_F2) or (p.vkCode = VK_F3) or
            (p.vkCode = VK_F4) or (p.vkCode = VK_F5) or (p.vkCode = VK_F6) or
            (p.vkCode = VK_F7) or (p.vkCode = VK_F8) or (p.vkCode = VK_F9) or
            (p.vkCode = VK_F10) or (p.vkCode = VK_F11) or (p.vkCode = VK_F12) then
            boolKey := True;

          if ((p.vkCode = VK_F1) or (p.vkCode = VK_F2) or (p.vkCode = VK_F3) or
            (p.vkCode = VK_F4) or (p.vkCode = VK_F5) or (p.vkCode = VK_F6) or
            (p.vkCode = VK_F7) or (p.vkCode = VK_F8) or (p.vkCode = VK_F9) or
            (p.vkCode = VK_F10) or (p.vkCode = VK_F11) or (p.vkCode = VK_F12)) and
            (((GetKeyState(VK_MENU) and $8000) <> 0) or ((GetKeyState(VK_CONTROL) and $8000) <> 0)
             or ((GetKeyState(VK_SHIFT)and$8000) <> 0)) then
              boolKey := True; }

      //-------ϵͳ�ȼ�---------------------------------------------
      //WIN(Left or Right)+APPS
          if aBlockWinApps then
          begin
            if (p.vkCode = VK_LWIN) or (p.vkCode = VK_RWIN) or (p.vkCode = VK_APPS) then
              boolKey := True;
          end;
      //CTRL+ESC
          if aBlockCtrlEsc then
          begin
            if (p.vkCode = VK_ESCAPE) and ((GetKeyState(VK_CONTROL) and $8000) <> 0) then
              boolKey := True;
          end;
      //ALT+TAB
          if aBlockAltTab then
          begin
            if (p.vkCode = VK_TAB) and ((GetAsyncKeyState(VK_MENU) and $8000) <> 0) then
              boolKey := True;
          end;
      //ALT+ESC
          if aBlockAltEsc then
          begin
            if (p.vkCode = VK_ESCAPE) and ((p.flags and LLKHF_ALTDOWN) <> 0) then
              boolKey := True;
          end;
      //CTRL+ENTER
          if aBlockCtrlEnter then
          begin
            if (p.vkCode = VK_RETURN) and ((GetKeyState(VK_CONTROL) and $8000) <> 0) then
              boolKey := True;
          end;
      //CTRL+ALT+ENTR
          if aBlockCtrlAltEnter then
          begin
            if (p.vkCode = VK_RETURN) and ((p.flags and LLKHF_ALTDOWN) <> 0)
              and ((GetKeyState(VK_CONTROL) and $8000) <> 0) then
              boolKey := True;
          end;
      //POWER
          if aBlockPower then
          begin
            if (p.vkCode = VK_POWER) then
              boolKey := True;
          end;
      //SLEEP
          if aBlockSleep then
          begin
            if (p.vkCode = VK_SLEEP) then
              boolKey := True;
          end;
      //Custom
          if aBlockCustomKey then
          begin
            if (p.vkCode = aCustomKeyCode) then
              boolKey := True;
          end;

      //���������Ҫ���յļ�������ڴ˴�
        end;
    end;
  end;

  //������Щ��ϼ���������Ϣ���Լ��������뷵�� 1
  if boolKey and (p <> nil) then
  begin
    FKeyBlocker.DoBlock(p.vkCode);
    Result := 1;
    Exit;
  end;

  //�����İ��������ɱ���̴߳������ˣ�
  Result := CallNextHookEx(0, nCode, w_Param, l_Param);
end;

destructor TCnKeyBlocker.Destroy;
begin
  Enabled := False;
  FKeyBlocker := nil;
  inherited Destroy;
end;

procedure TCnKeyBlocker.DoBlock(VirtualKey: Cardinal);
begin
  if Assigned(FOnBlockKey) then
    FOnBlockKey(VirtualKey);
end;

procedure TCnKeyBlocker.SetBlockAltEsc(const Value: Boolean);
begin
  FBlockAltEsc := Value;
  aBlockAltEsc := FBlockAltEsc;
end;

procedure TCnKeyBlocker.SetBlockAltTab(const Value: Boolean);
begin
  FBlockAltTab := Value;
  aBlockAltTab := FBlockAltTab;
end;

procedure TCnKeyBlocker.SetBlockCtrlAltDelete(const Value: Boolean);
begin
  FBlockCtrlAltDelete := Value;
  aBlockCtrlAltDelete := FBlockCtrlAltDelete;
end;

procedure TCnKeyBlocker.SetBlockCtrlAltEnter(const Value: Boolean);
begin
  FBlockCtrlAltEnter := Value;
  aBlockCtrlAltEnter := FBlockCtrlAltEnter;
end;

procedure TCnKeyBlocker.SetBlockCtrlEsc(const Value: Boolean);
begin
  FBlockCtrlEsc := Value;
  aBlockCtrlEsc := FBlockCtrlEsc;
end;

procedure TCnKeyBlocker.SetBlockCustomKey(const Value: Boolean);
begin
  FBlockCustomKey := Value;
  aBlockCustomKey := FBlockCustomKey;
end;

procedure TCnKeyBlocker.SetBlockCtrlEnter(const Value: Boolean);
begin
  FBlockCtrlEnter := Value;
  aBlockCtrlEnter := FBlockCtrlEnter;
end;

procedure TCnKeyBlocker.SetBlockPower(const Value: Boolean);
begin
  FBlockPower := Value;
  aBlockPower := FBlockPower;
end;

procedure TCnKeyBlocker.SetBlockSleep(const Value: Boolean);
begin
  FBlockSleep := Value;
  aBlockSleep := FBlockSleep;
end;

procedure TCnKeyBlocker.SetBlockWinApps(const Value: Boolean);
begin
  FBlockWinApps := Value;
  aBlockWinApps := FBlockWinApps;
end;

procedure TCnKeyBlocker.SetCustomKeyCode(const Value: Cardinal);
begin
  FCustomKeyCode := Value;
  aCustomKeyCode := FCustomKeyCode;
end;

procedure TCnKeyBlocker.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
  UpdateKeyBlock;
end;

procedure TCnKeyBlocker.UpdateKeyBlock;
begin
  if csDesigning in ComponentState then
    Exit;

  case FEnabled of
    True:
      begin
        if hhkNTKeyboard <> 0 then
          Exit;

        hhkNTKeyboard := SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelKeyboardFunc, HInstance, 0);
        if FBlockCtrlAltDelete then
        begin
          EnableCTRLALTDEL(False);
          SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
        end;
      end;
    False:
      begin
        if hhkNTKeyboard = 0 then
          Exit;
        UnhookWindowsHookEx(hhkNTKeyboard); // ж�ع���
        EnableCTRLALTDEL(True);
        SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
        hhkNTKeyboard := 0;
      end;
  end;
end;

end.
