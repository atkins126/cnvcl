unit Unit18030;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnStrings, CnWideStrings, CnGB18030, ExtCtrls;

type
  TFormGB18030 = class(TForm)
    grpTestGB2U: TGroupBox;
    btnGB18030CodePointToUtf16: TButton;
    btnGenGB18030UnicodeCompare: TButton;
    grpGenerate: TGroupBox;
    btnGenUtf16: TButton;
    btnGenGB18030Page: TButton;
    btnGenUtf16Page: TButton;
    chkIncludeCharValue: TCheckBox;
    btnGenGB18030PagePartly: TButton;
    grpMisc: TGroupBox;
    btnCodePointFromUtf161: TButton;
    btnCodePointFromUtf162: TButton;
    btnUtf16CharLength: TButton;
    btnUtf8CharLength: TButton;
    btnUtf8Encode: TButton;
    btnCodePointUtf16: TButton;
    btnCodePointUtf162: TButton;
    btnUtf8Decode: TButton;
    btnCodePointUtf163: TButton;
    btnGB18030ToUtf16: TButton;
    btn18030CodePoint1: TButton;
    btn18030CodePoint2: TButton;
    btn18030CodePoint3: TButton;
    btnCodePoint180301: TButton;
    btnCodePoint180302: TButton;
    btnCodePoint180303: TButton;
    btnMultiUtf16ToGB18030: TButton;
    btnMultiGB18030ToUtf16: TButton;
    dlgSave1: TSaveDialog;
    btnGenUtf16Page1: TButton;
    bvl1: TBevel;
    bvl2: TBevel;
    grpTestU2GB: TGroupBox;
    btnUtf16CodePointToGB180301: TButton;
    btnGenUnicodeGB18030Compare2: TButton;
    btnStringGB18030ToUnicode: TButton;
    btnStringUnicodeToGB18030: TButton;
    chkIncludeValue: TCheckBox;
    grpSequence: TGroupBox;
    btnGenGB18030From0: TButton;
    btnGenGB18030DownTo0: TButton;
    grp1: TGroupBox;
    btnCheckOneRange: TButton;
    btnCheckAllRange: TButton;
    btnGenGB18030PagePartly2: TButton;
    btnUnicodeIsDup: TButton;
    btnCompareUnicodeString: TButton;
    btnCompareUnicodeString2: TButton;
    btnPinYinTest: TButton;
    grpPuaNTS: TGroupBox;
    btnGenGB18030PuaUtf16: TButton;
    btnGenGB18030Utf16Pua: TButton;
    btnGenGB18030UnicodeMapBMP: TButton;
    btnGenGB18030UnicodeMapSMP: TButton;
    btnGenUnicodePuaList: TButton;
    procedure btnCodePointFromUtf161Click(Sender: TObject);
    procedure btnCodePointFromUtf162Click(Sender: TObject);
    procedure btnUtf16CharLengthClick(Sender: TObject);
    procedure btnUtf8CharLengthClick(Sender: TObject);
    procedure btnUtf8EncodeClick(Sender: TObject);
    procedure btnCodePointUtf16Click(Sender: TObject);
    procedure btnCodePointUtf162Click(Sender: TObject);
    procedure btnUtf8DecodeClick(Sender: TObject);
    procedure btnGenUtf16Click(Sender: TObject);
    procedure btnCodePointUtf163Click(Sender: TObject);
    procedure btnGB18030ToUtf16Click(Sender: TObject);
    procedure btn18030CodePoint1Click(Sender: TObject);
    procedure btn18030CodePoint2Click(Sender: TObject);
    procedure btn18030CodePoint3Click(Sender: TObject);
    procedure btnCodePoint180301Click(Sender: TObject);
    procedure btnCodePoint180302Click(Sender: TObject);
    procedure btnCodePoint180303Click(Sender: TObject);
    procedure btnMultiUtf16ToGB18030Click(Sender: TObject);
    procedure btnMultiGB18030ToUtf16Click(Sender: TObject);
    procedure btnGenGB18030PageClick(Sender: TObject);
    procedure btnGenUtf16PageClick(Sender: TObject);
    procedure btnGB18030CodePointToUtf16Click(Sender: TObject);
    procedure btnGenGB18030PagePartlyClick(Sender: TObject);
    procedure btnGenGB18030UnicodeCompareClick(Sender: TObject);
    procedure btnGenUtf16Page1Click(Sender: TObject);
    procedure btnUtf16CodePointToGB180301Click(Sender: TObject);
    procedure btnGenUnicodeGB18030Compare2Click(Sender: TObject);
    procedure btnStringGB18030ToUnicodeClick(Sender: TObject);
    procedure btnStringUnicodeToGB18030Click(Sender: TObject);
    procedure btnGenGB18030From0Click(Sender: TObject);
    procedure btnGenGB18030DownTo0Click(Sender: TObject);
    procedure btnCheckOneRangeClick(Sender: TObject);
    procedure btnCheckAllRangeClick(Sender: TObject);
    procedure btnGenGB18030PagePartly2Click(Sender: TObject);
    procedure btnUnicodeIsDupClick(Sender: TObject);
    procedure btnCompareUnicodeStringClick(Sender: TObject);
    procedure btnCompareUnicodeString2Click(Sender: TObject);
    procedure btnPinYinTestClick(Sender: TObject);
    procedure btnGenGB18030PuaUtf16Click(Sender: TObject);
    procedure btnGenGB18030Utf16PuaClick(Sender: TObject);
    procedure btnGenGB18030UnicodeMapBMPClick(Sender: TObject);
    procedure btnGenGB18030UnicodeMapSMPClick(Sender: TObject);
    procedure btnGenUnicodePuaListClick(Sender: TObject);
  private
    // �� Windows API �ķ�ʽ�������� 256 �� Unicode �ַ�
    procedure GenUtf16Page(Page: Byte; Content: TCnWideStringList);

    // �� Windows API �ķ�ʽʵ�ֵ��� Utf16 �ַ������ GB18030 �ַ�����Ļ�ת
    function APICodePointUtf16ToGB18030(UCP: TCnCodePoint): TCnCodePoint;
    function APICodePointGB18030ToUtf16(GBCP: TCnCodePoint): TCnCodePoint;

    // ����ָ����Χ�ڵ� Utf16 �ַ��� GB18030 �ַ���ӳ��
    procedure Gen2Utf16ToGB18030Page(FromH, FromL, ToH, ToL: Byte; Content: TCnAnsiStringList; H2: Word = 0);

    // ȡ����һ�����ֽ�ֵ�� GB18030 �ַ�����ֵ
    procedure Step4GB18030CodePoint(var CP: TCnCodePoint);

    // �� Windows API �ķ�ʽ�������� GB18030 �� Unicode ������ӳ�����䣬���ȶԽ��
    function Gen2GB18030ToUtf16Page(FromH, FromL, ToH, ToL: Byte; Content: TCnWideStringList): Integer;
    function Gen4GB18030ToUtf16Page(From4, To4: TCnCodePoint; Content: TCnWideStringList): Integer;

    // �� Windows API �ķ�ʽ�������� GB18030 �� Unicode ��ӳ���������ݣ��� CnPack ���ʹ��
    function Gen2GB18030ToUtf16Array(FromH, FromL, ToH, ToL: Byte; CGB, CU: TCnWideStringList): Integer;
    function Gen4GB18030ToUtf16Array(From4, To4: TCnCodePoint; CGB, CU: TCnWideStringList): Integer;

    // �� CnPack �Ĵ������� GB18030 �� Unicode ������ӳ�����䣬�������� Windows API �ķ�ʽ�ȶԽ��
    function GenCn2GB18030ToUtf16Page(FromH, FromL, ToH, ToL: Byte; Content: TCnAnsiStringList): Integer;
    function GenCn4GB18030ToUtf16Page(From4, To4: TCnCodePoint; Content: TCnAnsiStringList): Integer;

    // �� CnPack �Ĵ������� GB18030 �� Unicode ������ӳ�����䣬�������ַ�����
    function GenCn2GB18030ToUtf16PageChar(FromH, FromL, ToH, ToL: Byte; Content: TCnWideStringList): Integer;
    function GenCn4GB18030ToUtf16PageChar(From4, To4: TCnCodePoint; Content: TCnWideStringList): Integer;

    // �� Windows API �ķ�ʽ�������� Unicode �� GB18030 ������ӳ������
    function GenUnicodeToGB18030Page(FromU, ToU: TCnCodePoint; Content: TCnWideStringList): Integer;

    // �� CnPack �Ĵ�������ָ����Χ�ڵ� Utf16 �ַ��� GB18030 �ַ���ӳ��
    procedure GenCn2Utf16ToGB18030Page(FromH, FromL, ToH, ToL: Byte; Content: TCnAnsiStringList; H2: Word = 0);

    // �� CnPack �Ĵ�������ָ����Χ�ڵ� Utf16 �ַ��� GB18030 �ַ���ӳ�䣬�������ַ�����
    procedure GenCn2Utf16ToGB18030PageChars(FromH, FromL, ToH, ToL: Byte; Content: TCnWideStringList; H2: Word = 0);

    // ���һ�� GB18030 ���������� Unicode ��������Χ��Ranges ����������ĸ��Ե���ʼ����ͽ������룬�Լ�����
    procedure CheckRange(FromG, ToG: TCnCodePoint; Ranges, Others: TCnAnsiStringList; Threshold: Integer = 0);
    procedure CheckRangeThreshold(FromG, ToG: TCnCodePoint; Ranges, Others: TCnAnsiStringList);
  public

  end;

var
  FormGB18030: TFormGB18030;

implementation

uses
  CnNative;

{$R *.DFM}

const
  FACE: array[0..3] of Byte = ($3D, $D8, $02, $DE);      // Ц���˵ı������ UTF16-LE ��ʾ
  FACE_UTF8: array[0..3] of Byte = ($F0, $9F, $98, $82); // Ц���˵ı������ UTF8-MB4 ��ʾ

  CP_GB18030 = 54936;

{$I ..\..\..\Source\Common\Unicode_Pua.inc}

procedure TFormGB18030.btnCodePointFromUtf161Click(Sender: TObject);
var
  A: AnsiString;
  S: WideString;
  C: Cardinal;
begin
  A := '�Է�'; // �ڴ����� B3D4B7B9��GB18030����Ҳ�� B3D4 �� B7B9�����Ķ�˳��
  S := '�Է�'; // �ڴ����� 03546D99���� Unicode ����ȴ�� 5403 �� 996D���з���
  C := GetCodePointFromUtf16Char(PWideChar(S));
  ShowMessage(IntToHex(C, 2));
end;

procedure TFormGB18030.btnCodePointFromUtf162Click(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  SetLength(S, 2);
  Move(FACE[0], S[1], 4);

  C := GetCodePointFromUtf16Char(PWideChar(S));
  ShowMessage(IntToHex(C, 2)); // Ӧ�õ� $1F602
end;

procedure TFormGB18030.btnUtf16CharLengthClick(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  SetLength(S, 2);
  Move(FACE[0], S[1], 4);

  C := GetCharLengthFromUtf16(PWideChar(S));
  ShowMessage(IntToStr(C)); // Ӧ�õ� 1
end;

procedure TFormGB18030.btnUtf8CharLengthClick(Sender: TObject);
var
  S: AnsiString;
  C: Cardinal;
begin
  SetLength(S, 4);
  Move(FACE_UTF8[0], S[1], 4);

  C := GetCharLengthFromUtf8(PAnsiChar(S));
  ShowMessage(IntToStr(C)); // Ӧ�õ� 1
end;

procedure TFormGB18030.btnUtf8EncodeClick(Sender: TObject);
var
  S: WideString;
  R: AnsiString;
begin
  SetLength(S, 2);
  Move(FACE[0], S[1], 4);

  R := CnUtf8EncodeWideString(S);
  if R <> '' then
    ShowMessage(DataToHex(@R[1], Length(R)))  // F09F9882
  else
    ShowMessage('Error');
end;

procedure TFormGB18030.btnCodePointUtf16Click(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  C := $5403;  // �Ե� Unicode ���
  SetLength(S, 1);
  GetUtf16CharFromCodePoint(C, @S[1]);
  ShowMessage(S);
end;

procedure TFormGB18030.btnCodePointUtf162Click(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  C := $1F602;  // Ц���˵ı������ Unicode ���
  SetLength(S, 2);
  GetUtf16CharFromCodePoint(C, @S[1]);
  ShowMessage(DataToHex(@S[1], Length(S) * SizeOf(WideChar))); // $3DD802DE
end;

procedure TFormGB18030.btnUtf8DecodeClick(Sender: TObject);
var
  S: AnsiString;
  R: WideString;
begin
  SetLength(S, 4);
  Move(FACE_UTF8[0], S[1], 4);

  R := CnUtf8DecodeToWideString(S);
  if R <> '' then
    ShowMessage(DataToHex(@R[1], Length(R) * SizeOf(WideChar)))  // 3DD802DE
  else
    ShowMessage('Error');
end;

procedure TFormGB18030.btnGenUtf16Click(Sender: TObject);
var
  I: Integer;
  WS: TCnWideStringList;
begin
  // 0000 ~ FFFF��һ�� 0~F��һҳ 0~F���� 255 ҳ
  WS := TCnWideStringList.Create;
  Screen.Cursor := crHourGlass;

  try
    for I := 0 to 255 do
    begin
      WS.Add('');
      GenUtf16Page(I, WS);
    end;

    dlgSave1.FileName := 'UTF16.txt';
    if dlgSave1.Execute then
    begin
      WS.SaveToFile(dlgSave1.FileName);
      ShowMessage('Save to ' + dlgSave1.FileName);
    end;
  finally
    Screen.Cursor := crDefault;
    WS.Free;
  end;
end;

procedure TFormGB18030.GenUtf16Page(Page: Byte; Content: TCnWideStringList);
var
  R, C: Byte;
  S, T: WideString;
begin
  S := '    ';
  for C := 0 to $F do
    S := S + ' ' + IntToHex(C, 2);
  Content.Add(S);

  SetLength(T, 1);
  for R := 0 to $F do
  begin
    S := IntToHex(Page, 2) + IntToHex(16 * R, 2);
    for C := 0 to $F do
    begin
      GetUtf16CharFromCodePoint(Page * 256 + R * 16 + C, @T[1]);
      S := S + ' ' + T;
    end;
    Content.Add(S);
  end;
end;

procedure TFormGB18030.btnCodePointUtf163Click(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  C := $20BB7;  // �����¿� �� Unicode ���
  SetLength(S, 2);
  GetUtf16CharFromCodePoint(C, @S[1]);
  ShowMessage(DataToHex(@S[1], Length(S) * SizeOf(WideChar))); // $42D8B7DF
end;

procedure TFormGB18030.btnGB18030ToUtf16Click(Sender: TObject);
var
  S: AnsiString;
  W: WideString;
  C: Integer;
begin
  S := '�Է�';

  C := MultiByteToWideChar(CP_GB18030, 0, @S[1], Length(S), nil, 0);
  if C > 0 then
  begin
    SetLength(W, C);
    C := MultiByteToWideChar(CP_GB18030, 0, @S[1], Length(S), @W[1], Length(W));

    if C > 0 then
    begin
      ShowMessage(W);

      C := WideCharToMultiByte(CP_GB18030, 0, @W[1], Length(W), nil, 0, nil, nil);
      if C > 0 then
      begin
        SetLength(S, C);

        C := WideCharToMultiByte(CP_GB18030, 0, @W[1], Length(W), @S[1], Length(S), nil, nil);
        if C > 0 then
          ShowMessage(S);
      end;
    end;
  end;
end;

procedure TFormGB18030.btn18030CodePoint1Click(Sender: TObject);
var
  S: AnsiString;
  C: TCnCodePoint;
begin
  S := 'A';
  C := GetCodePointFromGB18030Char(@S[1]);
  ShowMessage(IntToHex(C, 2));              // 41
end;

procedure TFormGB18030.btn18030CodePoint2Click(Sender: TObject);
var
  S: AnsiString;
  C: TCnCodePoint;
begin
  S := '��';
  C := GetCodePointFromGB18030Char(@S[1]);
  ShowMessage(IntToHex(C, 2));              // B3D4
end;

procedure TFormGB18030.btn18030CodePoint3Click(Sender: TObject);
var
  S: AnsiString;
  C: TCnCodePoint;
begin
  SetLength(S, 4);
  S[1] := #$82;   // ��Ů�Ұ�
  S[2] := #$30;
  S[3] := #$C2;
  S[4] := #$30;

  C := GetCodePointFromGB18030Char(@S[1]);
  ShowMessage(IntToHex(C, 2));              // 8230C230
end;

procedure TFormGB18030.btnCodePoint180301Click(Sender: TObject);
var
  S: AnsiString;
  C: Cardinal;
begin
  C := $42;  // B �� GB18030 ���
  SetLength(S, 1);
  GetGB18030CharsFromCodePoint(C, @S[1]);
  ShowMessage(S);
end;

procedure TFormGB18030.btnCodePoint180302Click(Sender: TObject);
var
  S: AnsiString;
  C: Cardinal;
begin
  C := $B3D4;  // �Ե� GB18030 ���
  SetLength(S, 2);
  GetGB18030CharsFromCodePoint(C, @S[1]);
  ShowMessage(S);
end;

procedure TFormGB18030.btnCodePoint180303Click(Sender: TObject);
var
  S: AnsiString;
  C: Cardinal;
begin
  C := $8139EF34;  // һ����� GB18030 ���
  SetLength(S, 4);
  GetGB18030CharsFromCodePoint(C, @S[1]);   // �ڴ��еõ� 8139EF34
  ShowMessage(S);
end;

function TFormGB18030.APICodePointGB18030ToUtf16(GBCP: TCnCodePoint): TCnCodePoint;
var
  S: AnsiString;
  W: WideString;
  C, T: Integer;
begin
  Result := CN_INVALID_CODEPOINT;

  SetLength(S, 4); // ��� 4
  C := GetGB18030CharsFromCodePoint(GBCP, @S[1]);  // S �Ǹ� GB18030 �ַ���C �����ֽڳ���

  T := MultiByteToWideChar(CP_GB18030, 0, @S[1], C, nil, 0);
  if T > 0 then
  begin
    SetLength(W, T);
    T := MultiByteToWideChar(CP_GB18030, 0, @S[1], C, @W[1], Length(W));
    if T > 0 then
      Result := GetCodePointFromUtf16Char(@W[1]);
  end;
end;

function TFormGB18030.APICodePointUtf16ToGB18030(UCP: TCnCodePoint): TCnCodePoint;
var
  S: AnsiString;
  W: WideString;
  C, T: Integer;
begin
  Result := CN_INVALID_CODEPOINT;

  SetLength(W, 2); // ��� 2 �����ַ�Ҳ�������ֽ�
  C := GetUtf16CharFromCodePoint(UCP, @W[1]);  // W �Ǹ� Utf16 �ַ���C ������ַ�����

  T := WideCharToMultiByte(CP_GB18030, 0, @W[1], C, nil, 0, nil, nil);
  if T > 0 then
  begin
    SetLength(S, T);

    T := WideCharToMultiByte(CP_GB18030, 0, @W[1], C, @S[1], Length(S), nil, nil);
    if T > 0 then
      Result := GetCodePointFromGB18030Char(@S[1]);
  end;
end;

procedure TFormGB18030.btnMultiUtf16ToGB18030Click(Sender: TObject);
var
  S: WideString;
  A, T: AnsiString;
  I: Integer;
  C: TCnCodePoint;
begin
  S := '�Է�һ���٣�˯�����ܶ�';
  A := '';
  for I := 1 to Length(S) do
  begin
    C := GetCodePointFromUtf16Char(@S[I]);   // Utf16 ֵ
    if C = CN_INVALID_CODEPOINT then
      Exit;

    C := APICodePointUtf16ToGB18030(C);         // ת�� GB18030
    if C = CN_INVALID_CODEPOINT then
      Exit;

    SetLength(T, 4);
    C := GetGB18030CharsFromCodePoint(C, @T[1]);
    if C > 0 then
      SetLength(T, C);

    A := A + T;
  end;
  ShowMessage(A);
end;

procedure TFormGB18030.btnMultiGB18030ToUtf16Click(Sender: TObject);
var
  S, T: WideString;
  A: AnsiString;
  I: Integer;
  C: TCnCodePoint;
begin
  A := '�Է�һ���٣�˯�����ܶ�';
  S := '';
  I := 1;

  while I <= Length(A) do
  begin
    C := GetCodePointFromGB18030Char(@A[I]);   // GB18030 ֵ
    Inc(I, 2);

    if C = CN_INVALID_CODEPOINT then
      Exit;

    C := APICodePointGB18030ToUtf16(C);           // ת�� Utf16
    if C = CN_INVALID_CODEPOINT then
      Exit;

    SetLength(T, 1);
    GetUtf16CharFromCodePoint(C, @T[1]);

    S := S + T;
  end;
  ShowMessage(S);
end;

function TFormGB18030.Gen2GB18030ToUtf16Page(FromH, FromL, ToH, ToL: Byte;
  Content: TCnWideStringList): Integer;
var
  H, L, T: Integer;
  GBCP, UCP: TCnCodePoint;
  S, C: WideString;
begin
  Result := 0;
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      GBCP := (H shl 8) or L;
      UCP := APICodePointGB18030ToUtf16(GBCP);
      T := GetUtf16CharFromCodePoint(UCP, nil);
      SetLength(C, T);
      GetUtf16CharFromCodePoint(UCP, @C[1]);

      if chkIncludeCharValue.Checked then
        S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2) + '  ' + C
      else if chkIncludeValue.Checked then
        S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2)
      else
        S := IntToHex(GBCP, 2);

      Content.Add(S);
      Inc(Result);
    end;
  end;
end;

procedure TFormGB18030.btnGenGB18030PageClick(Sender: TObject);
var
  R, I: Integer;
  WS: TCnWideStringList;
  ASS: TCnAnsiStringList;
begin
  WS := TCnWideStringList.Create;
// ˫�ֽڣ�
//   8140~A07E, 8180~A0FE          3 ������     ������  6080   6080   GBK ������
//   A140~A77E, A180~A7A0          �û� 3 ��    ������  672
//   A1A1~A9FE                     1 ������     ������  846    171
//   A840~A97E, A880~A9A0          5 ������     ������  192    166
//   AA40~FE7E, AA80~FEA0          4 ������     ������  8160   8160
//   AAA1~AFFE                     �û� 1 ��    ����    564           E000 �� E233
//   B0A1~F7FE                     2 ������     ������  6768   6763   GB2312
//   F8A1~FEFE                     �û� 2 ��    ����    658           E234 �� E4C5

  R := 0;
  WS.Add('����˫�ֽں�����; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($81, $40, $A0, $7E, WS);
  R := R + Gen2GB18030ToUtf16Page($81, $80, $A0, $FE, WS);
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($A1, $40, $A7, $7E, WS);
  R := R + Gen2GB18030ToUtf16Page($A1, $80, $A7, $A0, WS);
  WS.Add('����˫�ֽ�һ; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($A1, $A1, $A9, $FE, WS);
  WS.Add('����˫�ֽ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($A8, $40, $A9, $7E, WS);
  R := R + Gen2GB18030ToUtf16Page($A8, $80, $A9, $A0, WS);
  WS.Add('����˫�ֽں�����; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($AA, $40, $FE, $7E, WS);
  R := R + Gen2GB18030ToUtf16Page($AA, $80, $FE, $A0, WS);
  WS.Add('����˫�ֽ��û�һ; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($AA, $A1, $AF, $FE, WS);
  WS.Add('����˫�ֽں��ֶ�; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($B0, $A1, $F7, $FE, WS);
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($F8, $A1, $FE, $FE, WS);

  // ���ֽ�
  WS.Add('�����ָ�һ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81308130, $81318131, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶�������һ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81318132, $81319934, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81319935, $8132E833, WS);

  WS.Add('�������ֽڲ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8132E834, $8132FD31, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8132FD32, $81339D35, WS);

  WS.Add('�������ֽڳ�������ĸ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81339D36, $8133B635, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8133B636, $8134D237, WS);

  WS.Add('�������ֽ��ɹ��ģ��������ġ���߯�ġ������ĺͰ�������֣�; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8134D238, $8134E337, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8134E338, $8134F433, WS);

  WS.Add('�������ֽڵº����; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8134F434, $8134F830, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8134F831, $8134F931, WS);

  WS.Add('�������ֽ���˫�����´���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8134F932, $81358437, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81358438, $81358B31, WS);

  WS.Add('�������ֽ���˫�����ϴ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81358B32, $81359935, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81359936, $81398B31, WS);

  WS.Add('�������ֽڿ�������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81398B32, $8139A135, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8139A136, $8139A932, WS);

  WS.Add('�������ֽڳ����ļ�����ĸ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8139A933, $8139B734, WS);

  WS.Add('�����ָ�ʮ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8139B735, $8139EE38, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� A; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8139EE39, $82358738, WS);

  WS.Add('�����ָ�ʮһ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82358739, $82358F32, WS);

  WS.Add('�������ֽ� CJK ͳһ����; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82358F33, $82359636, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82359637, $82359832, WS);

  WS.Add('�������ֽ�����; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82359833, $82369435, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82369436, $82369534, WS);

  WS.Add('�������ֽ�������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82369535, $82369A32, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82369A33, $8237CF34, WS);

  WS.Add('�������ֽڳ���������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8237CF35, $8336BE36, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8336BE37, $8430BA31, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶������Ķ�; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8430BA32, $8430FE35, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8430FE36, $84318639, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶���������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($84318730, $84319530, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($84319531, $8431A439, WS);

  WS.Add('�������ֽ��ɹ��� BIRGA; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9034C538, $9034C730, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9034C731, $9232C635, WS);

  WS.Add('�������ֽڵᶫ������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9232C636, $9232D635, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9232D636, $95328235, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� B; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($95328236, $9835F336, WS);

  WS.Add('�����ָ���ʮ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9835F337, $9835F737, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� C; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9835F738, $98399E36, WS);

  WS.Add('�����ָ���ʮһ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($98399E37, $98399F37, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� D; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($98399F38, $9839B539, WS);

  WS.Add('�����ָ���ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9839B630, $9839B631, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� E; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9839B632, $9933FE33, WS);

  WS.Add('�����ָ���ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9933FE34, $99348137, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� F; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($99348138, $9939F730, WS);

  WS.Add('�����ָ���ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9939F731, $9A348431, WS);

  WS.Add('�������ֽ��û���չ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($FD308130, $FE39FE39, WS);
  WS.Add('����β; ��һ���ַ�����' + IntToStr(R));

  dlgSave1.FileName := 'GB18030_UTF16_API.txt';
  if dlgSave1.Execute then
  begin
    if chkIncludeCharValue.Checked then
      WS.SaveToFile(dlgSave1.FileName)
    else
    begin
      ASS := TCnAnsiStringList.Create;
      for I := 0 to WS.Count - 1 do
        ASS.Add(WS[I]);
      ASS.SaveToFile(dlgSave1.FileName);
      ASS.Free;
    end;
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  WS.Free;
end;

procedure TFormGB18030.btnGenUtf16PageClick(Sender: TObject);
var
  SL: TCnAnsiStringList;
begin
  SL := TCnAnsiStringList.Create;

  Gen2Utf16ToGB18030Page(0, 0, $FF, $FF, SL);
  Gen2Utf16ToGB18030Page(0, 0, $FF, $FF, SL, 1);
  Gen2Utf16ToGB18030Page(0, 0, $FF, $FF, SL, 2);

  dlgSave1.FileName := 'UTF16_GB18030_API.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

procedure TFormGB18030.Gen2Utf16ToGB18030Page(FromH, FromL, ToH, ToL: Byte;
  Content: TCnAnsiStringList; H2: Word);
var
  H, L, T: Integer;
  GBCP, UCP: TCnCodePoint;
  S, C: AnsiString;
begin
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      UCP := ((H shl 8) or L) + (H2 shl 16);
      GBCP := APICodePointUtf16ToGB18030(UCP);
      if GBCP <> CN_INVALID_CODEPOINT then
      begin
        T := GetGB18030CharsFromCodePoint(GBCP, nil);
        SetLength(C, T);
        GetGB18030CharsFromCodePoint(GBCP, @C[1]);

        if chkIncludeCharValue.Checked then
          S := IntToHex(UCP, 2) + ' = ' + IntToHex(GBCP, 2) + '  ' + C
        else if chkIncludeValue.Checked then
          S := IntToHex(UCP, 2) + ' = ' + IntToHex(GBCP, 2)
        else
          S := IntToHex(UCP, 2);
      end
      else
        S := IntToHex(UCP, 2) + ' = ';

      Content.Add(S);
    end;
  end;
end;

function TFormGB18030.Gen4GB18030ToUtf16Page(From4, To4: TCnCodePoint;
  Content: TCnWideStringList): Integer;
var
  GBCP, UCP: TCnCodePoint;
  T: Integer;
  S, C: WideString;
begin
  Result := 0;
  GBCP := From4;
  while GBCP <= To4 do
  begin
    UCP := APICodePointGB18030ToUtf16(GBCP);
    T := GetUtf16CharFromCodePoint(UCP, nil);
    SetLength(C, T);
    GetUtf16CharFromCodePoint(UCP, @C[1]);

    if chkIncludeCharValue.Checked then
      S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2) + '  ' + C
    else if chkIncludeValue.Checked then
      S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2)
    else
      S := IntToHex(GBCP, 2);

    Content.Add(S);
    Inc(Result);

    Step4GB18030CodePoint(GBCP);
  end;
end;

procedure TFormGB18030.btnGB18030CodePointToUtf16Click(Sender: TObject);
var
  GBCP, UCP: TCnCodePoint;
begin
  GBCP := $81308130;
  UCP := GetUnicodeFromGB18030CodePoint(GBCP);
  ShowMessage(IntToHex(UCP, 2));
end;

procedure TFormGB18030.btnGenGB18030PagePartlyClick(Sender: TObject);
var
  WSGB, WSU: TCnWideStringList;
  ASS: TCnAnsiStringList;
  SB: TCnStringBuilder;

  procedure AddSep;
  begin
    WSGB.Add('');
    WSU.Add('');
  end;

  procedure Combine(OutAss: TCnAnsiStringList; AWS: TCnWideStringList);
  var
    I: Integer;
  begin
    for I := 0 to AWS.Count - 1 do
    begin
      if AWS[I] <> '' then
      begin
        SB.Append(AWS[I]);
        if I < AWS.Count - 1 then
          SB.Append(string(','));
        if (SB.CharLength >= 80) or (I = AWS.Count - 1) then
        begin
          OutAss.Add('    ' + SB.ToString);
          SB.Clear;
        end
        else
          SB.Append(string(' '));
      end;
    end;
    OutAss.Add('  );');
  end;

begin
  WSGB := TCnWideStringList.Create;
  WSU := TCnWideStringList.Create;
  ASS := TCnAnsiStringList.Create;
  SB := TCnStringBuilder.Create;

// ˫�ֽڣ�
//   8140~A07E, 8180~A0FE          3 ������     ������  6080   6080   GBK ������
//   A140~A77E, A180~A7A0          �û� 3 ��    ������  672
//   A1A1~A9FE                     1 ������     ������  846    171
//   A840~A97E, A880~A9A0          5 ������     ������  192    166
//   AA40~FE7E, AA80~FEA0          4 ������     ������  8160   8160
//   B0A1~F7FE                     2 ������     ������  6768   6763   GB2312

  // ˫�ֽں�����
  Gen2GB18030ToUtf16Array($81, $40, $A0, $7E, WSGB, WSU);
  Gen2GB18030ToUtf16Array($81, $80, $A0, $FE, WSGB, WSU);
  // ˫�ֽ��û���
  Gen2GB18030ToUtf16Array($A1, $40, $A7, $7E, WSGB, WSU);
  Gen2GB18030ToUtf16Array($A1, $80, $A7, $A0, WSGB, WSU);
  // ˫�ֽ�һ
  Gen2GB18030ToUtf16Array($A1, $A1, $A9, $FE, WSGB, WSU);
  // ˫�ֽ���
  Gen2GB18030ToUtf16Array($A8, $40, $A9, $7E, WSGB, WSU);
  Gen2GB18030ToUtf16Array($A8, $80, $A9, $A0, WSGB, WSU);
  // ˫�ֽں�����
  Gen2GB18030ToUtf16Array($AA, $40, $FE, $7E, WSGB, WSU);
  Gen2GB18030ToUtf16Array($AA, $80, $FE, $A0, WSGB, WSU);
  // ˫�ֽں��ֶ�
  Gen2GB18030ToUtf16Array($B0, $A1, $F7, $FE, WSGB, WSU);

  ASS.Add('');
  ASS.Add('  CN_GB18030_2MAPPING: array[0..' + IntToStr(WSGB.Count - 1) + '] of TCnCodePoint = (');
  Combine(ASS, WSGB);
  ASS.Add('');
  ASS.Add('  CN_UNICODE_2MAPPING: array[0..' + IntToStr(WSU.Count - 1) + '] of TCnCodePoint = (');
  Combine(ASS, WSU);
  ASS.Add('');

  WSGB.Clear;
  WSU.Clear;

//  // ���ֽ�
//  // �ָ�һ
//  Gen4GB18030ToUtf16Array($81308130, $81318131, WSGB, WSU);
//
//  // �ָ���
//  Gen4GB18030ToUtf16Array($81359936, $81398B31, WSGB, WSU);
//
//  // �ָ���
//  Gen4GB18030ToUtf16Array($8139A136, $8139A932, WSGB, WSU);
//
//  // �ָ�ʮ
//  Gen4GB18030ToUtf16Array($8139B735, $8139EE38, WSGB, WSU);
//
//  // CJK ͳһ�������� A
//  Gen4GB18030ToUtf16Array($8139EE39, $82358738, WSGB, WSU);
//
//  // �ָ�ʮ��
//  Gen4GB18030ToUtf16Array($8336BE37, $8430BA31, WSGB, WSU);
//
//  // �ָ�ʮ��
//  Gen4GB18030ToUtf16Array($8430FE36, $84318639, WSGB, WSU);
//
//  // �ָ�ʮ��
//  Gen4GB18030ToUtf16Array($84319531, $8431A439, WSGB, WSU);
//
//  ASS.Add('  CN_GB18030_4MAPPING: array[0..' + IntToStr(WSGB.Count - 1) + '] of TCnCodePoint = (');
//  Combine(ASS, WSGB);
//  ASS.Add('');
//  ASS.Add('  CN_UNICODE_4MAPPING: array[0..' + IntToStr(WSU.Count - 1) + '] of TCnCodePoint = (');
//  Combine(ASS, WSU);
//  ASS.Add('');

  dlgSave1.FileName := 'GB18030_Unicode_2.inc';
  if dlgSave1.Execute then
  begin
    ASS.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;

  SB.Free;
  ASS.Free;
  WSGB.Free;
  WSU.Free;
end;

function TFormGB18030.Gen2GB18030ToUtf16Array(FromH, FromL, ToH, ToL: Byte;
  CGB, CU: TCnWideStringList): Integer;
var
  H, L, T: Integer;
  GBCP, UCP: TCnCodePoint;
  C: WideString;
begin
  Result := 0;
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      GBCP := (H shl 8) or L;
      UCP := APICodePointGB18030ToUtf16(GBCP);
      T := GetUtf16CharFromCodePoint(UCP, nil);
      SetLength(C, T);
      GetUtf16CharFromCodePoint(UCP, @C[1]);

      CGB.Add('$' + Format('%4.4x', [GBCP]));
      CU.Add('$' + Format('%4.4x', [UCP]));

      Inc(Result);
    end;
  end;
end;

function TFormGB18030.Gen4GB18030ToUtf16Array(From4, To4: TCnCodePoint;
  CGB, CU: TCnWideStringList): Integer;
var
  GBCP, UCP: TCnCodePoint;
  T: Integer;
  C: WideString;
begin
  Result := 0;
  GBCP := From4;
  while GBCP <= To4 do
  begin
    UCP := APICodePointGB18030ToUtf16(GBCP);
    T := GetUtf16CharFromCodePoint(UCP, nil);
    SetLength(C, T);
    GetUtf16CharFromCodePoint(UCP, @C[1]);

    CGB.Add('$' + IntToHex(GBCP, 2));
    CU.Add('$' + IntToHex(UCP, 2));

    Inc(Result);
    Step4GB18030CodePoint(GBCP);
  end;
end;

procedure TFormGB18030.Step4GB18030CodePoint(var CP: TCnCodePoint);
var
  B2, B3, B4: Byte;
begin
  repeat
    Inc(CP);
    B4 := Byte(CP);
    B3 := Byte(CP shr 8);
    B2 := Byte(CP shr 16);
  until (B4 in [$30..$39]) and (B3 in [$81..$FE]) and (B2 in [$30..$39]);
end;

procedure TFormGB18030.btnGenGB18030UnicodeCompareClick(Sender: TObject);
var
  R: Integer;
  WS: TCnAnsiStringList;
begin
  WS := TCnAnsiStringList.Create;
// ˫�ֽڣ�
//   8140~A07E, 8180~A0FE          3 ������     ������  6080   6080   GBK ������
//   A140~A77E, A180~A7A0          �û� 3 ��    ������  672
//   A1A1~A9FE                     1 ������     ������  846    171
//   A840~A97E, A880~A9A0          5 ������     ������  192    166
//   AA40~FE7E, AA80~FEA0          4 ������     ������  8160   8160
//   AAA1~AFFE                     �û� 1 ��    ����    564           E000 �� E233
//   B0A1~F7FE                     2 ������     ������  6768   6763   GB2312
//   F8A1~FEFE                     �û� 2 ��    ����    658           E234 �� E4C5

  R := 0;
  WS.Add('����˫�ֽں�����; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16Page($81, $40, $A0, $7E, WS);
  R := R + GenCn2GB18030ToUtf16Page($81, $80, $A0, $FE, WS);
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16Page($A1, $40, $A7, $7E, WS);
  R := R + GenCn2GB18030ToUtf16Page($A1, $80, $A7, $A0, WS);
  WS.Add('����˫�ֽ�һ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16Page($A1, $A1, $A9, $FE, WS);
  WS.Add('����˫�ֽ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16Page($A8, $40, $A9, $7E, WS);
  R := R + GenCn2GB18030ToUtf16Page($A8, $80, $A9, $A0, WS);
  WS.Add('����˫�ֽں�����; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16Page($AA, $40, $FE, $7E, WS);
  R := R + GenCn2GB18030ToUtf16Page($AA, $80, $FE, $A0, WS);
  WS.Add('����˫�ֽ��û�һ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16Page($AA, $A1, $AF, $FE, WS);
  WS.Add('����˫�ֽں��ֶ�; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16Page($B0, $A1, $F7, $FE, WS);
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16Page($F8, $A1, $FE, $FE, WS);

  // ���ֽ�
  WS.Add('�����ָ�һ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($81308130, $81318131, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶�������һ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($81318132, $81319934, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($81319935, $8132E833, WS);

  WS.Add('�������ֽڲ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8132E834, $8132FD31, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8132FD32, $81339D35, WS);

  WS.Add('�������ֽڳ�������ĸ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($81339D36, $8133B635, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8133B636, $8134D237, WS);

  WS.Add('�������ֽ��ɹ��ģ��������ġ���߯�ġ������ĺͰ�������֣�; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8134D238, $8134E337, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8134E338, $8134F433, WS);

  WS.Add('�������ֽڵº����; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8134F434, $8134F830, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8134F831, $8134F931, WS);

  WS.Add('�������ֽ���˫�����´���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8134F932, $81358437, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($81358438, $81358B31, WS);

  WS.Add('�������ֽ���˫�����ϴ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($81358B32, $81359935, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($81359936, $81398B31, WS);

  WS.Add('�������ֽڿ�������; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($81398B32, $8139A135, WS);

  WS.Add('�����ָ���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8139A136, $8139A932, WS);

  WS.Add('�������ֽڳ����ļ�����ĸ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8139A933, $8139B734, WS);

  WS.Add('�����ָ�ʮ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8139B735, $8139EE38, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� A; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8139EE39, $82358738, WS);

  WS.Add('�����ָ�ʮһ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($82358739, $82358F32, WS);

  WS.Add('�������ֽ� CJK ͳһ����; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($82358F33, $82359636, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($82359637, $82359832, WS);

  WS.Add('�������ֽ�����; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($82359833, $82369435, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($82369436, $82369534, WS);

  WS.Add('�������ֽ�������; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($82369535, $82369A32, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($82369A33, $8237CF34, WS);

  WS.Add('�������ֽڳ���������; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8237CF35, $8336BE36, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8336BE37, $8430BA31, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶������Ķ�; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8430BA32, $8430FE35, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($8430FE36, $84318639, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶���������; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($84318730, $84319530, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($84319531, $8431A439, WS);

  WS.Add('�������ֽ��ɹ��� BIRGA; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9034C538, $9034C730, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9034C731, $9232C635, WS);

  WS.Add('�������ֽڵᶫ������; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9232C636, $9232D635, WS);

  WS.Add('�����ָ�ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9232D636, $95328235, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� B; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($95328236, $9835F336, WS);

  WS.Add('�����ָ���ʮ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9835F337, $9835F737, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� C; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9835F738, $98399E36, WS);

  WS.Add('�����ָ���ʮһ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($98399E37, $98399F37, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� D; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($98399F38, $9839B539, WS);

  WS.Add('�����ָ���ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9839B630, $9839B631, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� E; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9839B632, $9933FE33, WS);

  WS.Add('�����ָ���ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9933FE34, $99348137, WS);

  WS.Add('�������ֽ� CJK ͳһ�������� F; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($99348138, $9939F730, WS);

  WS.Add('�����ָ���ʮ��; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($9939F731, $9A348431, WS);

  WS.Add('�������ֽ��û���չ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16Page($FD308130, $FE39FE39, WS);
  WS.Add('����β; ��һ���ַ�����' + IntToStr(R));

  dlgSave1.FileName := 'GB18030_UTF16_CN.txt';
  if dlgSave1.Execute then
  begin
    WS.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  WS.Free;
end;

function TFormGB18030.GenCn4GB18030ToUtf16Page(From4, To4: TCnCodePoint;
  Content: TCnAnsiStringList): Integer;
var
  GBCP, UCP: TCnCodePoint;
  S: AnsiString;
begin
  Result := 0;
  GBCP := From4;
  while GBCP <= To4 do
  begin
    UCP := GetUnicodeFromGB18030CodePoint(GBCP);
    S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2);

    Content.Add(S);
    Inc(Result);

    Step4GB18030CodePoint(GBCP);
  end;
end;

function TFormGB18030.GenCn2GB18030ToUtf16Page(FromH, FromL, ToH,
  ToL: Byte; Content: TCnAnsiStringList): Integer;
var
  H, L: Integer;
  GBCP, UCP: TCnCodePoint;
  S: AnsiString;
begin
  Result := 0;
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      GBCP := (H shl 8) or L;
      UCP := GetUnicodeFromGB18030CodePoint(GBCP);
      S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2);

      Content.Add(S);
      Inc(Result);
    end;
  end;
end;

procedure TFormGB18030.btnGenUtf16Page1Click(Sender: TObject);
var
  R, I: Integer;
  WS: TCnWideStringList;
  ASS: TCnAnsiStringList;
begin
  WS := TCnWideStringList.Create;
// ˫�ֽڣ�
//   AAA1~AFFE                     �û� 1 ��    ����    564           E000 �� E233
//   F8A1~FEFE                     �û� 2 ��    ����    658           E234 �� E4C5

  R := 0;

  WS.Add('����˫�ֽ��û�һ; ��һ���ַ�����' + IntToStr(R)); // ����˫�ֽ��û���
  R := GenUnicodeToGB18030Page($E000, $E233, WS);
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($E234, $E4C5, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶�������һ; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($060C, $1AAF, WS);

  WS.Add('�������ֽڿ�������; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($2F00, $2FDF, WS);

  WS.Add('�������ֽڳ����ļ�����ĸ; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($3131, $31BE, WS);

  WS.Add('�����ָ�ʮһ; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($4DB6, $4DFF, WS);

  WS.Add('�������ֽ� CJK ͳһ����; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($9FA6, $D7A3, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶������Ķ�; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($FB50, $FDFE, WS);

  WS.Add('�������ֽ�ά����������ˡ��¶���������; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($FE70, $FEFC, WS);

  WS.Add('�������ֽ��ɹ��� BIRGA; ��һ���ַ�����' + IntToStr(R));
  R := GenUnicodeToGB18030Page($11660, $2FFFF, WS);

  WS.Add('����β; ��һ���ַ�����' + IntToStr(R));

  dlgSave1.FileName := 'UTF16_GB18030_continue.txt';
  if dlgSave1.Execute then
  begin
    if chkIncludeCharValue.Checked then
      WS.SaveToFile(dlgSave1.FileName)
    else
    begin
      ASS := TCnAnsiStringList.Create;
      for I := 0 to WS.Count - 1 do
        ASS.Add(WS[I]);
      ASS.SaveToFile(dlgSave1.FileName);
      ASS.Free;
    end;
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  WS.Free;
end;

function TFormGB18030.GenUnicodeToGB18030Page(FromU, ToU: TCnCodePoint;
  Content: TCnWideStringList): Integer;
var
  T: Integer;
  UCP, GBCP: TCnCodePoint;
  S: AnsiString;
begin
  Result := 0;
  UCP := FromU;
  while UCP <= ToU do
  begin
    GBCP := APICodePointUtf16ToGB18030(UCP);
    if GBCP <> CN_INVALID_CODEPOINT then
    begin
      T := GetGB18030CharsFromCodePoint(GBCP, nil);
      if T > 0 then
      begin
        SetLength(S, T);
        GetGB18030CharsFromCodePoint(GBCP, @S[1]);

        Content.Add(IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2));
        Inc(Result);
      end;
    end;
    Inc(UCP);
  end;
end;

procedure TFormGB18030.btnUtf16CodePointToGB180301Click(Sender: TObject);
var
  GBCP, UCP: TCnCodePoint;
begin
  UCP := $2ECA;
  GBCP := GetGB18030FromUnicodeCodePoint(UCP);
  ShowMessage(IntToHex(GBCP, 2));
end;

procedure TFormGB18030.btnGenUnicodeGB18030Compare2Click(Sender: TObject);
var
  SL: TCnAnsiStringList;
begin
  SL := TCnAnsiStringList.Create;

  GenCn2Utf16ToGB18030Page(0, 0, $FF, $FF, SL);
  GenCn2Utf16ToGB18030Page(0, 0, $FF, $FF, SL, 1);
  GenCn2Utf16ToGB18030Page(0, 0, $FF, $FF, SL, 2);

  dlgSave1.FileName := 'UTF16_GB18030_CN.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

procedure TFormGB18030.GenCn2Utf16ToGB18030Page(FromH, FromL, ToH,
  ToL: Byte; Content: TCnAnsiStringList; H2: Word);
var
  H, L: Integer;
  GBCP, UCP: TCnCodePoint;
  S: AnsiString;
begin
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      UCP := ((H shl 8) or L) + (H2 shl 16);
      GBCP := GetGB18030FromUnicodeCodePoint(UCP);
      if GBCP <> CN_INVALID_CODEPOINT then
      begin
        S := IntToHex(UCP, 2) + ' = ' + IntToHex(GBCP, 2);
      end
      else
        S := IntToHex(UCP, 2) + ' = ';

      Content.Add(S);
    end;
  end;
end;

procedure TFormGB18030.btnStringGB18030ToUnicodeClick(Sender: TObject);
var
  S: TCnGB18030String;
  W: WideString;
  L: Integer;
begin
  SetLength(S, 20);  // 1 1 1 2 4 2 4 1 4
  S[1] := 'A';
  S[2] := '3';
  S[3] := '.';

  S[4] := #$E0;
  S[5] := #$D3;      // Unicode $5624

  S[6] := #$81;
  S[7] := #$39;
  S[8] := #$EF;
  S[9] := #$34;      // Unicode $3405

  S[10] := #$C0;
  S[11] := #$D0;     // Unicode $4F6C

  S[12] := #$98;
  S[13] := #$32;
  S[14] := #$8D;
  S[15] := #$33;     // Unicode $29413 ���ֽڱ���Ϊ $65D813DC

  S[16] := '_';

  S[17] := #$83;
  S[18] := #$36;
  S[19] := #$B1;
  S[20] := #$35;     // Unicode $D720

  L := GB18030ToUtf16(PCnGB18030StringPtr(S), nil); // Ӧ�÷��� 10 �����ַ�
  if L > 0 then
  begin
    SetLength(W, L);
    GB18030ToUtf16(PCnGB18030StringPtr(S), PWideChar(W));
    MessageBoxW(Handle, PWideChar(W), nil, MB_OK);
  end;
end;

procedure TFormGB18030.btnStringUnicodeToGB18030Click(Sender: TObject);
var
  S: WideString;
  P: PAnsiChar;
  O: TCnGB18030String;
  L: Integer;
begin
  SetLength(S, 10);

  P := PAnsiChar(S);
  P[0] := #$41;
  P[1] := #$00;
  P[2] := #$33;
  P[3] := #$00;
  P[4] := #$2E;
  P[5] := #$00;      // GB18030 $41 $33 $2E

  P[6] := #$24;
  P[7] := #$56;
  P[8] := #$05;
  P[9] := #$34;      // GB18030 $E0D3

  P[10] := #$6C;
  P[11] := #$4F;     // GB18030 $8139EF34

  P[12] := #$65;
  P[13] := #$D8;
  P[14] := #$13;
  P[15] := #$DC;     // GB18030 $98328D33

  P[16] := #$5F;
  P[17] := #$00;     // GB18030 $5F

  P[18] := #$20;
  P[19] := #$D7;     // GB18030 $8336B135

  L := Utf16ToGB18030(PWideChar(S), nil); // Ӧ�÷��� 20 ���ַ�
  if L > 0 then
  begin
    SetLength(O, L);
    Utf16ToGB18030(PWideChar(S), PCnGB18030StringPtr(O));
    ShowMessage(O);
  end;
end;

procedure TFormGB18030.CheckRange(FromG, ToG: TCnCodePoint;
  Ranges, Others: TCnAnsiStringList; Threshold: Integer);
var
  Cnt: Integer;
  GC, UC: TCnCodePoint;
  StartUC, EndUC, PrevUC: TCnCodePoint;
  StartGC, EndGC, PrevGC: TCnCodePoint;
  Cont: Boolean;

  procedure SaveRes;
  var
    S: AnsiString;
    GBCP, UCP: TCnCodePoint;
  begin
    if Cnt >= Threshold then
    begin
      S := Format('(GBHead: $%8.8x; GBTail: $%8.8x; UHead: $%4.4x; UTail: $%4.4x),  // %d',
        [StartGC, EndGC, StartUC, EndUC, Cnt]);
      Ranges.Add(S);
    end
    else
    begin
      GBCP := StartGC;
      while GBCP <= EndGC do
      begin
        UCP := GetUnicodeFromGB18030CodePoint(GBCP);
        Others.Add(IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2));
        GBCP := GetNextGB18030CodePoint(GBCP);
      end;
    end;
  end;

begin
  GC := FromG;
  UC := GetUnicodeFromGB18030CodePoint(GC);

  StartGC := CN_INVALID_CODEPOINT;
  StartUC := CN_INVALID_CODEPOINT;

  PrevGC := CN_INVALID_CODEPOINT;
  PrevUC := CN_INVALID_CODEPOINT;

  Cont := False;
  Cnt := 1;

  while GC <= ToG do
  begin
    UC := GetUnicodeFromGB18030CodePoint(GC);
    if (StartGC = CN_INVALID_CODEPOINT) or (StartUC = CN_INVALID_CODEPOINT) then // ��ͷ��ʼ�ĵ�һ��
    begin
      StartGC := GC;
      PrevGC := GC;

      StartUC := UC;
      PrevUC := UC;

      GC := GetNextGB18030CodePoint(GC);
      Continue;
    end;

    if UC = PrevUC + 1 then // ����Ǵ�ͷ��ʼ�ĵ�һ�������������
    begin
      // ����һ����������¼ǰһ��
      PrevGC := GC;
      PrevUC := UC;
      Inc(Cnt);

      Cont := True;
    end
    else
    begin
      // �����������ϸ�����Ϊ��������
      EndGC := PrevGC;
      EndUC := PrevUC;

      SaveRes;

      // �����������Ϊ������ʼ
      StartGC := GC;
      StartUC := UC;
      Cnt := 1;

      PrevGC := GC;
      PrevUC := UC;

      Cont := False;
    end;

    GC := GetNextGB18030CodePoint(GC);
  end;

  if Cont then // ��βʱ�Ƿ���������������Ҫ�ֹ���β
  begin
    EndGC := GetPrevGB18030CodePoint(GC); // ��һ�����ǽ�β
    EndUC := UC;

    SaveRes;
  end;
end;

procedure TFormGB18030.btnGenGB18030From0Click(Sender: TObject);
var
  I: Integer;
  CP: TCnCodePoint;
  SL: TCnAnsiStringList;
begin
  CP := 0;
  SL := TCnAnsiStringList.Create;
  while CP <> CN_INVALID_CODEPOINT do
  begin
    CP := GetNextGB18030CodePoint(CP);
    SL.Add(IntToHex(CP, 2));
  end;

  for I := 0 to SL.Count - 2 do
  begin
    CP := StrToInt('$' + SL[I]);
    if not IsGB18030Char1(CP) and not IsGB18030Char2(CP) and not IsGB18030Char4(CP) then
    begin
      ShowMessage('NOT ' + SL[I]);
      Exit;
    end;
  end;

  dlgSave1.FileName := 'GB18030_0.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

procedure TFormGB18030.btnGenGB18030DownTo0Click(Sender: TObject);
var
  I: Integer;
  CP: TCnCodePoint;
  SL: TCnAnsiStringList;
begin
  CP := CN_INVALID_CODEPOINT - 1;
  SL := TCnAnsiStringList.Create;
  while CP <> CN_INVALID_CODEPOINT do
  begin
    CP := GetPrevGB18030CodePoint(CP);
    SL.Add(IntToHex(CP, 2));
  end;

  for I := 0 to SL.Count - 2 do
  begin
    CP := StrToInt('$' + SL[I]);
    if not IsGB18030Char1(CP) and not IsGB18030Char2(CP) and not IsGB18030Char4(CP) then
    begin
      ShowMessage('NOT ' + SL[I]);
      Exit;
    end;
  end;

  dlgSave1.FileName := 'GB18030_FFFFFFFF.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

procedure TFormGB18030.btnCheckOneRangeClick(Sender: TObject);
var
  SL, OT: TCnAnsiStringList;
begin
  SL := TCnAnsiStringList.Create;
  OT := TCnAnsiStringList.Create;

  // CheckRange($8139A136, $8139A932, SL, OT);
  // CheckRange($8139EE39, $82358738, SL); // CJK ͳһ�������� A
  // CheckRange($A1A1, $A1A9, SL, OT);
  CheckRange($84319531, $8431A439, SL, OT, 0);

  dlgSave1.FileName := 'Range.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;

  if OT.Count > 0 then
  begin
    dlgSave1.FileName := 'Other.txt';
    if dlgSave1.Execute then
    begin
      OT.SaveToFile(dlgSave1.FileName);
      ShowMessage('Save to ' + dlgSave1.FileName);
    end;
  end;
  SL.Free;
  OT.Free;
end;

procedure TFormGB18030.btnCheckAllRangeClick(Sender: TObject);
var
  SL, OT: TCnAnsiStringList;
begin
  SL := TCnAnsiStringList.Create;
  OT := TCnAnsiStringList.Create;

  // ������в����������е�����״��
//  SL.Add('˫�ֽ��������֣�');
//  CheckRangeThreshold($8140, $A07E, SL, OT);
//  CheckRangeThreshold($8180, $A0FE, SL, OT);
//
//  SL.Add('˫�ֽ��û�������');
//  CheckRangeThreshold($A140, $A77E, SL, OT);
//  CheckRangeThreshold($A180, $A7A0, SL, OT);
//
//  SL.Add('˫�ֽڷ���һ����');
//  CheckRangeThreshold($A1A1, $A9FE, SL, OT);
//
//  SL.Add('˫�ֽڷ���������');
//  CheckRangeThreshold($A840, $A97E, SL, OT);
//  CheckRangeThreshold($A880, $A9A0, SL, OT);
//
//  SL.Add('˫�ֽں���������');
//  CheckRangeThreshold($AA40, $FE7E, SL, OT);
//  CheckRangeThreshold($AA80, $FEA0, SL, OT);
//
//  SL.Add('˫�ֽں��ֶ�����');
//  CheckRangeThreshold($B0A1, $F7FE, SL, OT);

  SL.Add('���ֽڷָ���һ��');
  OT.Add('���ֽڷָ���һ��');
  CheckRangeThreshold($81308130, $81318131, SL, OT);

  SL.Add('���ֽڷָ����ˣ�');
  OT.Add('���ֽڷָ����ˣ�');
  CheckRangeThreshold($81359936, $81398B31, SL, OT);

  SL.Add('���ֽڷָ����ţ�');
  OT.Add('���ֽڷָ����ţ�');
  CheckRangeThreshold($8139A136, $8139A932, SL, OT);

  SL.Add('���ֽڷָ���ʮ��');
  OT.Add('���ֽڷָ���ʮ��');
  CheckRangeThreshold($8139B735, $8139EE38, SL, OT);

  SL.Add('CJK ͳһ�������� A��');
  OT.Add('CJK ͳһ�������� A��');
  CheckRangeThreshold($8139EE39, $82358738, SL, OT);

  SL.Add('���ֽڷָ���ʮ�壺');
  OT.Add('���ֽڷָ���ʮ�壺');
  CheckRangeThreshold($8336BE37, $8430BA31, SL, OT);

  SL.Add('���ֽڷָ���ʮ����');
  OT.Add('���ֽڷָ���ʮ����');
  CheckRangeThreshold($8430FE36, $84318639, SL, OT);

  SL.Add('���ֽڷָ���ʮ�ߣ�');
  OT.Add('���ֽڷָ���ʮ�ߣ�');
  CheckRangeThreshold($84319531, $8431A439, SL, OT);

  dlgSave1.FileName := 'Ranges.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;

  dlgSave1.FileName := 'Others.txt';
  if dlgSave1.Execute then
  begin
    OT.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;

  SL.Free;
  OT.Free;
end;

procedure TFormGB18030.CheckRangeThreshold(FromG, ToG: TCnCodePoint;
  Ranges, Others: TCnAnsiStringList);
begin
  CheckRange(FromG, ToG, Ranges, Others, 32);
end;

procedure TFormGB18030.btnGenGB18030PagePartly2Click(Sender: TObject);
const
  EQUAL = ' = ';
var
  SL, OT: TCnAnsiStringList;
  I, T: Integer;
  SB: TCnStringBuilder;
begin
  SL := TCnAnsiStringList.Create;
  OT := TCnAnsiStringList.Create;

  // ��ȡ���ֽ� GB18030 �ַ����Ĳ������������� inc
  SL.Add('���ֽڷָ���һ��');
  CheckRangeThreshold($81308130, $81318131, SL, OT);

  SL.Add('���ֽڷָ����ˣ�');
  CheckRangeThreshold($81359936, $81398B31, SL, OT);

  SL.Add('���ֽڷָ����ţ�');
  CheckRangeThreshold($8139A136, $8139A932, SL, OT);

  SL.Add('���ֽڷָ���ʮ��');
  CheckRangeThreshold($8139B735, $8139EE38, SL, OT);

  SL.Add('CJK ͳһ�������� A��');
  CheckRangeThreshold($8139EE39, $82358738, SL, OT);

  SL.Add('���ֽڷָ���ʮ�壺');
  CheckRangeThreshold($8336BE37, $8430BA31, SL, OT);

  SL.Add('���ֽڷָ���ʮ����');
  CheckRangeThreshold($8430FE36, $84318639, SL, OT);

  SL.Add('���ֽڷָ���ʮ�ߣ�');
  CheckRangeThreshold($84319531, $8431A439, SL, OT);

  dlgSave1.FileName := 'GB18030_Unicode_4.inc';
  if dlgSave1.Execute then
  begin
    SB := TCnStringBuilder.Create;

    SL.Clear;
    SL.Add('');
    SL.Add('  CN_GB18030_4MAPPING: array[0..' + IntToStr(OT.Count - 1) + '] of TCnCodePoint = (');
    for I := 0 to OT.Count - 1 do
    begin
      T := Pos(EQUAL, OT[I]);
      if T <= 1 then
        Continue;

      SB.Append('$' + Copy(OT[I], 1, T - 1));
      if I < OT.Count - 1 then
        SB.Append(string(','));
      if (SB.CharLength >= 80) or (I = OT.Count - 1) then
      begin
        SL.Add('    ' + SB.ToString);
        SB.Clear;
      end
      else
        SB.Append(string(' '));
    end;
    SL.Add('  );');

    SL.Add('');
    SL.Add('  CN_UNICODE_4MAPPING: array[0..' + IntToStr(OT.Count - 1) + '] of TCnCodePoint = (');
    for I := 0 to OT.Count - 1 do
    begin
      T := Pos(' = ', OT[I]);
      if T <= 1 then
        Continue;

      SB.Append('$' + Copy(OT[I], T + Length(EQUAL), MaxInt));
      if I < OT.Count - 1 then
        SB.Append(string(','));
      if (SB.CharLength >= 80) or (I = OT.Count - 1) then
      begin
        SL.Add('    ' + SB.ToString);
        SB.Clear;
      end
      else
        SB.Append(string(' '));
    end;
    SL.Add('  );');

    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
    SB.Free;
  end;

  SL.Free;
  OT.Free;
end;

procedure TFormGB18030.btnUnicodeIsDupClick(Sender: TObject);
var
  C, D: TCnCodePoint;
begin
  C := $E85B;
  if IsUnicodeDuplicated(C, D) then
    ShowMessage(IntToHex(C, 2) + ' Duplicate to ' + IntToHex(D, 2));

  C := $4DAE;
  if IsUnicodeDuplicated(C, D) then
    ShowMessage(IntToHex(C, 2) + ' Duplicate to ' + IntToHex(D, 2));

  C := $A530;
  if IsUnicodeDuplicated(C, D) then
    ShowMessage(IntToHex(C, 2) + ' Duplicate to ' + IntToHex(D, 2))
  else
    ShowMessage('NO Duplicate for ' + IntToHex(C, 2));
end;

procedure TFormGB18030.btnCompareUnicodeStringClick(Sender: TObject);
var
  S1, S2: WideString;
begin
  SetLength(S1, 4);
  SetLength(S2, 4);

  // ����*��
  S1[1] := #$6211;
  S1[2] := #$662F;
  S1[3] := #$E863; // ��������� PUA ��
  S1[4] := #$5B57;

  S2[1] := #$6211;
  S2[2] := #$662F;
  S2[3] := #$4DAE; // �����������ʽ Unicode ��
  S2[4] := #$5B57;

  ShowMessage(S1);
  ShowMessage(S2);

  if CnCompareUnicodeString(PWideChar(S1), PWideChar(S2)) then
    ShowMessage('Equal')
  else
    ShowMessage('NOT Equal');
end;

procedure TFormGB18030.btnCompareUnicodeString2Click(Sender: TObject);
var
  S1, S2: WideString;
begin
  SetLength(S1, 4);
  SetLength(S2, 4);

  // ����*��
  S1[1] := #$6211;
  S1[2] := #$662F;
  S1[3] := #$F429; // ������Ϊ�� PUA2 ��
  S1[4] := #$5B57;

  S2[1] := #$6211;
  S2[2] := #$662F;
  S2[3] := #$39D1; // ������Ϊ����ʽ Unicode ��
  S2[4] := #$5B57;

  ShowMessage(S1);
  ShowMessage(S2);

  if CnCompareUnicodeString(PWideChar(S1), PWideChar(S2)) then
    ShowMessage('Equal')
  else
    ShowMessage('NOT Equal');
end;

procedure TFormGB18030.btnPinYinTestClick(Sender: TObject);
var
  I: Integer;
  WS: WideString;
begin
  WS := '����Ҫ�Է�����������';
  for I := 1 to Length(WS) do
    ShowMessage(GetPinYinFromUtf16Char(WS[I]));
end;

procedure TFormGB18030.btnGenGB18030PuaUtf16Click(Sender: TObject);
var
  R: Integer;
  WS: TCnWideStringList;
begin
  WS := TCnWideStringList.Create;
// ˫�ֽڣ�
//   A140~A77E, A180~A7A0          �û� 3 ��    ������  672
//   AAA1~AFFE                     �û� 1 ��    ����    564           E000 �� E233
//   F8A1~FEFE                     �û� 2 ��    ����    658           E234 �� E4C5

  R := 0;
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16PageChar($A1, $40, $A7, $7E, WS);
  R := R + GenCn2GB18030ToUtf16PageChar($A1, $80, $A7, $A0, WS);
  WS.Add('����˫�ֽ��û�һ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16PageChar($AA, $A1, $AF, $FE, WS);
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := GenCn2GB18030ToUtf16PageChar($F8, $A1, $FE, $FE, WS);

  WS.Add('�������ֽ��û���չ; ��һ���ַ�����' + IntToStr(R));
  R := GenCn4GB18030ToUtf16PageChar($FD308130, $FE39FE39, WS);
  WS.Add('����β; ��һ���ַ�����' + IntToStr(R));

  dlgSave1.FileName := 'GB18030_PUA_UTF16.txt';
  if dlgSave1.Execute then
  begin
    WS.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  WS.Free;
end;

function TFormGB18030.GenCn2GB18030ToUtf16PageChar(FromH, FromL, ToH,
  ToL: Byte; Content: TCnWideStringList): Integer;
var
  H, L, T: Integer;
  GBCP, UCP: TCnCodePoint;
  S, C: WideString;
begin
  Result := 0;
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      GBCP := (H shl 8) or L;
      UCP := GetUnicodeFromGB18030CodePoint(GBCP);
      T := GetUtf16CharFromCodePoint(UCP, nil);
      SetLength(C, T);
      GetUtf16CharFromCodePoint(UCP, @C[1]);

      S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2) + '  ' + C;

      Content.Add(S);
      Inc(Result);
    end;
  end;
end;

function TFormGB18030.GenCn4GB18030ToUtf16PageChar(From4,
  To4: TCnCodePoint; Content: TCnWideStringList): Integer;
var
  T: Integer;
  GBCP, UCP: TCnCodePoint;
  S, C: WideString;
begin
  Result := 0;
  GBCP := From4;
  while GBCP <= To4 do
  begin
    UCP := GetUnicodeFromGB18030CodePoint(GBCP);
    T := GetUtf16CharFromCodePoint(UCP, nil);
    SetLength(C, T);
    GetUtf16CharFromCodePoint(UCP, @C[1]);

    S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2) + '  ' + C;

    Content.Add(S);
    Inc(Result);

    Step4GB18030CodePoint(GBCP);
  end;
end;

procedure TFormGB18030.GenCn2Utf16ToGB18030PageChars(FromH, FromL, ToH,
  ToL: Byte; Content: TCnWideStringList; H2: Word);
var
  H, L, T: Integer;
  GBCP, UCP: TCnCodePoint;
  S, C: WideString;
begin
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      UCP := ((H shl 8) or L) + (H2 shl 16);
      T := GetUtf16CharFromCodePoint(UCP, nil);
      SetLength(C, T);
      GetUtf16CharFromCodePoint(UCP, @C[1]);

      GBCP := GetGB18030FromUnicodeCodePoint(UCP);
      if GBCP <> CN_INVALID_CODEPOINT then
      begin
        S := IntToHex(UCP, 2) + ' = ' + IntToHex(GBCP, 2) + '  ' + C;
      end
      else
        S := IntToHex(UCP, 2) + ' = ';

      Content.Add(S);
    end;
  end;
end;

procedure TFormGB18030.btnGenGB18030Utf16PuaClick(Sender: TObject);
var
  SL: TCnWideStringList;
begin
  SL := TCnWideStringList.Create;

  GenCn2Utf16ToGB18030PageChars($E0, 0, $F8, $FF, SL);
  GenCn2Utf16ToGB18030PageChars(0, 0, $FF, $FF, SL, $F);
  GenCn2Utf16ToGB18030PageChars(0, 0, $FF, $FF, SL, $10);

  dlgSave1.FileName := 'UTF16_PUA_GB18030.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

procedure TFormGB18030.btnGenGB18030UnicodeMapBMPClick(Sender: TObject);
var
  UCP, GBCP: TCnCodePoint;
  SL: TCnAnsiStringList;
  I: Integer;
  S: AnsiString;
begin
  // �� CnPack �ķ������� Unicode �� 0000 ��ʼ �� FFFF �ĺ� GB18030 ��Ӧ�����
  // �Ժ��ű�ί NITS �ṩ�� GB18030-2022MappingTableBMP.txt ���գ�ע���ڲ����ֵ�����λ��˳��ͬ������Ӧһ��
  SL := TCnAnsiStringList.Create;
  SL.UseSingleLF := True;
  for I := $0 to $FFFF do
  begin
    UCP := TCnCodePoint(I);
    GBCP := GetGB18030FromUnicodeCodePoint(UCP);
    if GBCP <> CN_INVALID_CODEPOINT then
    begin
      S := Format('%4.4x', [UCP]) + #9 + IntToHex(GBCP, 2);
      SL.Add(S);
    end;
  end;

  dlgSave1.FileName := 'GB18030-2022MappingTableBMP_Cn.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

procedure TFormGB18030.btnGenGB18030UnicodeMapSMPClick(Sender: TObject);
var
  UCP, GBCP: TCnCodePoint;
  SL: TCnAnsiStringList;
  I: Integer;
  S: AnsiString;
begin
  // �� CnPack �ķ������� Unicode �� 10000 ��ʼ �� 10FFFF �ĺ� GB18030 ��Ӧ�����
  // �Ժ��ű�ί NITS �ṩ�� GB18030-2022MappingTableSMP.txt ���գ�˳������Ӧһ��
  SL := TCnAnsiStringList.Create;
  SL.UseSingleLF := True;
  for I := $10000 to $10FFFF do
  begin
    UCP := TCnCodePoint(I);
    GBCP := GetGB18030FromUnicodeCodePoint(UCP);
    if GBCP <> CN_INVALID_CODEPOINT then
    begin
      S := Format('%x', [UCP]) + #9 + IntToHex(GBCP, 2);
      SL.Add(S);
    end;
  end;

  dlgSave1.FileName := 'GB18030-2022MappingTableSMP_Cn.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

procedure TFormGB18030.btnGenUnicodePuaListClick(Sender: TObject);
var
  I, T: Integer;
  SL: TCnWideStringList;
  S, C1, C2: WideString;
begin
  SL := TCnWideStringList.Create;
  for I := Low(CN_UNICODE_PUA_MAPPING) to High(CN_UNICODE_PUA_MAPPING) do
  begin
    T := GetUtf16CharFromCodePoint(CN_UNICODE_PUA_MAPPING[I], nil);
    SetLength(C1, T);
    GetUtf16CharFromCodePoint(CN_UNICODE_PUA_MAPPING[I], @C1[1]);

    T := GetUtf16CharFromCodePoint(CN_UNICODE_UCS_MAPPING[I], nil);
    SetLength(C2, T);
    GetUtf16CharFromCodePoint(CN_UNICODE_UCS_MAPPING[I], @C2[1]);

    S := Format('%x', [CN_UNICODE_PUA_MAPPING[I]]) + '  ' + Format('%x', [CN_UNICODE_UCS_MAPPING[I]]) + '  ' + C1 + C2;

    SL.Add(S);
  end;

  dlgSave1.FileName := 'Unicode_PUA.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

end.
