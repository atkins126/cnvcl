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

unit CnEdit;
{* |<PRE>
================================================================================
* ������ƣ�����ؼ���
* ��Ԫ���ƣ�CnEdit �ؼ���Ԫ
* ��Ԫ���ߣ�ʢС��  chbsxq@163.com   QQ:822154
*           jAmEs_
* ��    ע��-ʹ CnEdit ����һ����ť����ťӵ�е����¼���
*           -LinkStyle ���Կ�������ΪlsNone, lsEllipsis, lsDropDown
*
*           -CnEdit �� Text ���Ϳ���Ϊ���Ρ������͡���ͨ�����͡���ʶ����
*           -TextType ���Կ�������Ϊ NormalText, IntegerText, FloatText
*           -TextType ����Ϊ IntegerText ʱ��CnEdit ֻ�������ּ��� Backspace ��������������Ч
*            ͬ������Ϊ FloatText ֻ�� IntegerText ���ܽ��� '.'������� CnEdit.Text �Ѱ���'.'����������.
*            -�Ը���'-'��ֻ���ڿ�ͷ����.
*           -FloatText ����ʱ������'0.'����'.0'������������Զ�����Ϊ'0.0'
*           -CnEdit ʧȥ����ʱ���� Text����������� TextType �����ã�����ջ��� 0
*            ����������ճ���������Ϸ��ַ�
*
*           -�߱��س����滻�� Tab ���Ĺ��ܣ�ֻҪ�������� EnterAsTab Ϊ True��
*            ���� CnEdit ���а��س������Զ�������һ�ؼ���
* ����ƽ̨��PWinXP + Delphi 6.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 6.0
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.03.26 V1.4
*               ������ߴ�ʱ�İ�ť����ϸ��
*           2009.07.04 V1.3
*               ���� tArightJustify ʱ���Ʋ���ȷ�����⣬��л jAmEs_
*           2008.06.05 V1.2
*               ����ճ��ʱ����������
*           2007.08.02 V1.1
*               jAmEs_ ���� Value ���ԣ������ʶ���͡����ֹ��˺͸������ƹ���
*           2004.04.24 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls, Forms, Graphics,
  Clipbrd;

type
  TLinkStyle = (lsNone, lsEllipsis, lsDropDown); // �Ƿ���ְ�ť�Լ���ť����
  TTextType = (NormalText, IntegerText, FloatText, IdentText); // �ı�����
  //           ��ͨ�ı���  ������       С����     ��ʶ��

  TCnEdit = class(TEdit)
  private
    FButtonWidth: Integer;
    FCanvas: TControlCanvas;
    FLinkStyle: TLinkStyle;
    FAlignment: TAlignment;
    FPressed: Boolean;
    FTracking: Boolean;
    FOnButtonClick: TNotifyEvent;
    FTextType: TTextType; // �ı����͡����Ρ����㡢����
    FEnterAsTab: Boolean; // �س���Ϊ Tab
    FAcceptNegative: Boolean;
    FAcceptCharList: string;
    FButtonCursor: TCursor;
    procedure SetLinkStyle(Value: TLinkStyle); // �����Ƿ���ʾ��ť
    procedure TrackButton(X, Y: Integer); // ������갴�°�ť�ƿ��ֻ�������������´���
    procedure StopTracking; //ͬ�ϡ�up ����
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
    function GetTextMargins: TPoint; // Text �༭�����ϵĿհ�
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR; // ��������ڰ�ť�ϵļ�ͷ
    function GetValue: Variant;
    procedure SetButtonCursor(const Value: TCursor);
  protected
    procedure EditButtonClick; virtual; // �����¼�
    procedure BoundsChanged;
    procedure CreateParams(var Params: TCreateParams); override; // ����ǳ�����
    procedure DoEnter; override; // ��ȡ����ʱѡ��ȫ������
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override; // ��ݼ�
    procedure KeyPress(var Key: Char); override; // �������λس�������Ϊ�Ƕ��з�ʽ������������
    // �� MouseUp ������ť�¼��������¼�����ť״̬
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Value: Variant read GetValue;
  published
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    {* �Ҳఴť����¼�}
    property LinkStyle: TLinkStyle read FLinkStyle write SetLinkStyle default lsNone;
    {* ��ť����}
    property ButtonCursor: TCursor read FButtonCursor write SetButtonCursor default crDefault;
    {* ��ť�ϵĹ��}
    property Alignment: TAlignment read FAlignment write FAlignment default TaLeftJustify;
    {* ���뷽ʽ}
    property TextType: TTextType read FTextType write FTextType default NormalText;
    {* �ı�����}
    property EnterAsTab: Boolean read FEnterAsTab write FEnterAsTab default False;
    {* �س����Ƿ�ת��Ϊ Tab ��}
    property AcceptNegative: Boolean read FAcceptNegative write FAcceptNegative default True;
    {* �Ƿ������� - ��}
    property AcceptCharList: string read FAcceptCharList write FAcceptCharList;
    {* ����������ַ��б��� Unicode �����¶Ժ���֧�ֲ���}
  end;

implementation

uses CnCommon;

{ TCnEdit }

procedure TCnEdit.DoExit;
var
  Ri, Code: Integer;
  Rs: Single;
begin
  inherited;
  // ���Ϊ���Σ�Ϊ��ʱ�Զ�Ϊ 0
  if FTextType = IntegerText then
  begin
    if Text = '' then
      Text := '0';
    Val(Text, Ri, Code);
    if Code <> 0 then
      Text := '0';
    Code := Ri; // ������뾯��
  end;
  // ���Ϊ���㣬���.ǰ���Ƿ�Ϊ�գ�Ϊ�ռ� 0
  if FTextType = FloatText then
  begin
    if Pos('.', Text) = 1 then
      Text := '0' + Text;
    if Pos('.', Text) = Length(Text) then
      Text := Text + '0';
    Val(Text, Rs, Code);
    if Code <> 0 then
       Text := '0';
    Code := Round(Rs); // ������뾯��
  end;
  Invalidate;
end;

procedure TCnEdit.BoundsChanged;
var
  R: TRect;
begin
  SetRect(R, 0, 0, ClientWidth - 2, ClientHeight + 1); // +1 is workAround for Windows paint bug
  if (FLinkStyle <> lsNone) then
    Dec(R.Right, FButtonWidth);
  SendMessage(Handle, EM_SETRECT, 0, LongInt(@R));
  Repaint;
end;

constructor TCnEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtonWidth := GetSystemMetrics(SM_CXVSCROLL);
  FAcceptNegative := True;
end;

procedure TCnEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or ES_MULTILINE;
  end;
end;

destructor TCnEdit.Destroy;
begin
  inherited Destroy;
  FCanvas.Free;
end;

procedure TCnEdit.DoEnter;
begin
  if (FLinkStyle <> lsNone) then
    BoundsChanged;
  inherited DoEnter;
  if AutoSelect then
    SelectAll;
end;

procedure TCnEdit.EditButtonClick;
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);
end;

function TCnEdit.GetTextMargins: TPoint;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  if NewStyleControls then
  begin
    if BOrderStyle = bsNone then
      I := 0
    else if Ctl3D then
      I := 1
    else
      I := 2;
      
    Result.X := SendMessage(Handle, EM_GETMARGINS, 0, 0) and $0000FFFF + I;
    Result.Y := I;
  end
  else
  begin
    if BorderStyle = bsNone then
      I := 0
    else
    begin
      DC := GetDC(0);
      GetTextMetrics(DC, SysMetrics);
      SaveFont := SelectObject(DC, Font.Handle);
      GetTextMetrics(DC, Metrics);
      SelectObject(DC, SaveFont);
      ReleaseDC(0, DC);
      I := SysMetrics.tmHeight;
      if I > Metrics.tmHeight then
        I := Metrics.tmHeight;
      I := I div 4;
    end;
    Result.X := I;
    Result.Y := I;
  end;
end;

procedure TCnEdit.KeyDown(var Key: Word; Shift: TShiftState);
var
  Msg: TMsg;
begin
  if (FLinkStyle in [lsEllipsis, lsDropDown]) and (Key = VK_RETURN) and (Shift = [sSCtrl]) then
  begin
    EditButtonClick;
    PeekMessage(Msg, Handle, WM_CHAR, WM_CHAR, PM_REMOVE);
  end
  else
    inherited KeyDown(Key, Shift);
end;

procedure TCnEdit.KeyPress(var Key: ChAr);
var
  AParent: TControl;
begin
  if Key = #13 then
  begin
    if FEnterAsTab then
    begin
      AParent := Parent;
      if AParent <> nil then
        while AParent.Parent <> nil do
          AParent := AParent.Parent;

      if (AParent <> nil) and (AParent is TControl) then
        (AParent as TControl).Perform(WM_NEXTDLGCTL, 0, 0);
      Key := #0;
    end
    else
      MessageBeep(0);
  end
  else
  begin
    if not CharInSet(Key, [Chr(VK_BACK), Chr(VK_RETURN), #01, #03, #08, #22, #24, #26]) then // Ctrl+A/C/BK/V/X/Z
    begin
      if FTextType = IntegerText then
      begin
        if not FAcceptNegative and (Key = '-') then
          Key := #0
        else if not CharInSet(Key, ['0'..'9', '-']) then
          Key := #0
        else
        begin
          if (Key = '-') and ((Pos('-', Text) > 0) or (SelStart > 0)) then Key := #0;
        end;
      end
      else if FTextType = FloatText then
      begin
        if not FAcceptNegative and (Key = '-') then
          Key := #0
        else if not CharInSet(Key, ['0'..'9', '.', '-']) then
          Key := #0
        else
        begin
          if (Key = '-') and ((Pos('-', Text) > 0) or (SelStart > 0)) then
            Key := #0;
          if (Pos('.', Text) > 0) and (Key = '.') then
            Key := #0;
        end;
      end
      else if (FTextType = IdentText) and (not IsValidIdentChar(Key, SelStart = 0)) then
        Key := #0
      else if FAcceptCharList <> '' then
      begin
        if Pos(Key, FAcceptCharList) = 0 then
          Key := #0;
      end;
    end;
  end;
  inherited KeyPress(Key);
end;

procedure TCnEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (FLinkStyle <> lsNone)
    and PtInRect(Rect(Width - FButtonWidth, 0, Width, Height), Point(X, Y)) then
  begin
    MouseCapture := True;
    FTracking := True;
    TrackButton(X, Y);
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCnEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FTracking then
    TrackButton(X, Y);
  inherited MouseMove(Shift, X, Y);
end;

procedure TCnEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  WasPressed: Boolean;
begin
  WasPressed := FPressed;
  StopTracking;

  if (Button = mbLeft) and (FLinkStyle in [lsEllipsis, lsDropDown]) and WasPressed then
    EditButtonClick;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TCnEdit.SetLinkStyle(Value: TLinkStyle);
begin
  if Value = FLinkStyle then
    Exit;
  FLinkStyle := Value;
  if not HandleAllocated then
    Exit;
  BoundsChanged;
end;

procedure TCnEdit.StopTracking;
begin
  if FTracking then
  begin
    TrackButton(-1, -1);
    FTracking := False;
    MouseCApture := False;
  end;
end;

procedure TCnEdit.TrackButton(X, Y: Integer);
var
  NewState: Boolean;
  R: TRect;
begin
  SetRect(R, ClientWidth - FButtonWidth, 0, ClientWidth, ClientHeight);
  NewState := PtInRect(R, Point(X, Y));
  if FPressed <> NewState then
  begin
    FPressed := NewState;
    InvalidateRect(Handle, @R, False);
  end;
end;

procedure TCnEdit.WMPaint(var Message: TWMPaint);
var
  Margins: TPoint;
  R: TRect;
  DC: HDC;
  PS: TPaintStruct;
  S: string;
  Flags: Integer;
  W: Integer;
  L, I, Offset: Integer;
begin
  if FCanvas = nil then
  begin
    FCanvas := TControlCanvas.Create;
    FCanvas.Control := Self;
  end;

  DC := Message.DC;
  if DC = 0 then
    DC := BeginPaint(Handle, PS);

  FCanvas.Handle := DC;
  try
    FCanvas.Font := Font;
    with FCanvas do
    begin
      // ���ÿؼ��ķ�Χ
      if (FLinkStyle <> lsNone) then
        SetRect(R, ClientWidth - FButtonWidth, 0, ClientWidth, ClientHeight)
      else
      begin
        R := ClientRect;
        if not (NewStyleControls and Ctl3D) and (BOrderStyle = bsSingle) then
        begin
          Brush.Color := clWindowFrame;
          FrameRect(R);
          InflateRect(R, -1, -1);
        end;
        Brush.Color := Color;
      end;

      // �Ƿ���������
      S := Text;
      if PasswordChar <> #0 then
        FillChar(S[1], Length(S), PasswordChar);

      // ������
      Margins := GetTextMargins;
      if Focused then
      begin
        L := Margins.X;
      end
      else
      begin
        case FAlignment of
          taLeftJustify: L := Margins.X;
          tArightJustify: L := ClientWidth - TextWidth(S) - Margins.X - 1;
        else
          L := (ClientWidth - TextWidth(S)) div 2;
        end;
      end;
        
      TextRect(R, L, Margins.Y, S);

      if FLinkStyle <> lsNone then   // ����ť
      begin
        Flags := 0;
        if FPressed then
          Flags := BF_FLAT;
        DrawEdge(DC, R, EDGE_RAISED, BF_RECT or BF_MIDDLE or Flags);
        Flags := ((R.Right - R.Left) shr 1) - 1 + Ord(FPressed);
        if FLinkStyle = lsEllipsis then // ����
        begin
          W := 2; // �����֮��ĺ������
          PatBlt(DC, R.Left + Flags, R.Top + Round(ClientHeight / 2) - 1, W, W, BLACKNESS);
          PatBlt(DC, R.Left + Flags - (W * 2), R.Top + Round(ClientHeight / 2) - 1, W, W, BLACKNESS);
          PatBlt(DC, R.Left + Flags + (W * 2), R.Top + Round(ClientHeight / 2) - 1, W, W, BLACKNESS);
        end
        else if FLinkStyle = lsDropDown then
        begin
          if FButtonWidth <= 16 then // ���滭��
          begin
            for I := 0 to 3 do // ��������ͷ
            begin
              // R �� 21 ʱ���� 7����ʼ Y ����ռ����֮һ
              // ��ť�� 16 ʱ�� 4 ��ʼ��11 ��������ʼ X �����ķ�֮һ���ķ�֮�������ĸ߶��� X ���ķ�֮һ
              Windows.MoveToEx(DC, R.Left + 4 + I, R.Top + 7 + I, nil);
              Windows.LineTo(DC, R.Left + 4 + 7 - I, R.Top + 7 + I);
            end;
          end
          else
          begin
            L := FButtonWidth div 4;
            Offset := (FButtonWidth - 16) div 4 - 1;
            if Offset < 0 then
              Offset := 0;
            W := (R.Bottom - R.Top) div 3 + 1;

            for I := 0 to L do
            begin
              if R.Left + L + Offset + I > R.Left + L + Offset + W - I then // ���⻭��ͷ
                Break;
              Windows.MoveToEx(DC, R.Left + L + Offset + I, R.Top + W + I, nil);
              Windows.LineTo(DC, R.Left + L + Offset + W - I, R.Top + W + I);
            end;
          end;
        end;

        ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
        PaintWindow(DC);
      end;
    end;
  finally
    FCanvas.Handle := 0;
    if Message.DC = 0 then
      EndPaint(Handle, PS);
  end;
end;

procedure TCnEdit.WMSetCursor(var Msg: TWMSetCursor);
var
  P: TPoint;
begin
  GetCursorPos(P);
  if (FLinkStyle <> lsNone) and
    PtInRect(Rect(Width - FButtonWidth - 4, 0, ClientWidth,
    ClientHeight), ScreenToClient(P)) then
    Windows.SetCursor(Screen.Cursors[FButtonCursor])
  else
    inherited;
end;

function TCnEdit.GetValue: Variant;
begin
  case FTextType of
    IntegerText: Result := StrToInt(Text);
    FloatText: Result := StrToFloat(Text);
  else
    Result := Text;
  end;
end;

procedure TCnEdit.SetButtonCursor(const Value: TCursor);
begin
  if FButtonCursor <> Value then
  begin
    FButtonCursor := Value;
    Perform(WM_SETCURSOR, 0, 0);
  end;
end;

procedure TCnEdit.WMPaste(var Message: TWMPaste);
var
  I: Integer;
  S: string;
begin
  // ����ճ����Ϣ��ɾ������Ҫ���ַ����������ǻ�Ӱ�����������
  if Clipboard.AsText = '' then
    Exit;

  S := Clipboard.AsText;
  I := Length(S);
  case FTextType of
    IntegerText:
      begin
        while I > 0 do
        begin
          if not CharInSet(S[I], ['0'..'9', '-']) then
            Delete(S, I, 1);
          Dec(I);
        end;
      end;
    FloatText:
      begin
        while I > 0 do
        begin
          if not CharInSet(S[I], ['0'..'9', '-', '.']) then
            Delete(S, I, 1);
          Dec(I);
        end;
      end;
    IdentText:
      begin
        while I > 0 do
        begin
          if not IsValidIdentChar(S[I], I = 1) then
            Delete(S, I, 1);
          Dec(I);
        end;
      end;  
  else
    ;
  end;
  Clipboard.AsText := S;
  inherited;
end;

end.

