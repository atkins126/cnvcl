unit UnitMemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnMemo, CnSpin, ComCtrls, CnTextControl;

type
  TCnMemoForm = class(TForm)
    PageControl1: TPageControl;
    ts1: TTabSheet;
    lblLeftMargin: TLabel;
    lblRightMargin: TLabel;
    chkShowLineNumber: TCheckBox;
    chkHilightLineNumber: TCheckBox;
    btnChangeFont: TButton;
    grpColors: TGroupBox;
    btnLineBkColor: TButton;
    btnLineNumberColor: TButton;
    btnLineNumberHighlight: TButton;
    dlgFontMemo: TFontDialog;
    dlgColor: TColorDialog;
    tsEditorStringList: TTabSheet;
    mmoEditorStringList: TMemo;
    tsTextControl: TTabSheet;
    Label1: TLabel;
    chkTCLine: TCheckBox;
    btnTCFont: TButton;
    StatusBar1: TStatusBar;
    edtMemoLeftMargin: TEdit;
    edtMemoRightMargin: TEdit;
    udMemoLeftMargin: TUpDown;
    udMemoRightMargin: TUpDown;
    chkShowCaret: TCheckBox;
    lblCaretRow: TLabel;
    lblCaretCol: TLabel;
    edtCaretRow: TEdit;
    edtCaretCol: TEdit;
    udCaretRow: TUpDown;
    udCaretCol: TUpDown;
    chkUseSelection: TCheckBox;
    chkMemoShowCaret: TCheckBox;
    chkMemoUseSelection: TCheckBox;
    btnMemoLoad: TButton;
    dlgOpen1: TOpenDialog;
    chkCaretAfterLineEnd: TCheckBox;
    lblString: TLabel;
    edtString: TEdit;
    mmoColumnIndex: TMemo;
    mmoIndexColumn: TMemo;
    statMemo: TStatusBar;
    chkMapAfterEnd: TCheckBox;
    mmoSelection: TMemo;
    edtMemoInsert: TEdit;
    btnMemoInsert: TButton;
    btnMemoInsertCRLF: TButton;
    btnMemoInsertMulti: TButton;
    chkMemoReadOnly: TCheckBox;
    btnMemoSelectRange: TButton;
    btnMemoCut: TButton;
    btnMemoCopy: TButton;
    btnMemoPaste: TButton;
    procedure FormCreate(Sender: TObject);
    procedure chkShowLineNumberClick(Sender: TObject);
    procedure btnChangeFontClick(Sender: TObject);
    procedure chkTCLineClick(Sender: TObject);
    procedure btnTCFontClick(Sender: TObject);
    procedure chkShowCaretClick(Sender: TObject);
    procedure edtCaretRowChange(Sender: TObject);
    procedure edtCaretColChange(Sender: TObject);
    procedure chkUseSelectionClick(Sender: TObject);
    procedure chkMemoShowCaretClick(Sender: TObject);
    procedure chkMemoUseSelectionClick(Sender: TObject);
    procedure btnMemoLoadClick(Sender: TObject);
    procedure chkCaretAfterLineEndClick(Sender: TObject);
    procedure edtStringChange(Sender: TObject);
    procedure chkMapAfterEndClick(Sender: TObject);
    procedure btnMemoInsertClick(Sender: TObject);
    procedure btnMemoInsertCRLFClick(Sender: TObject);
    procedure btnMemoInsertMultiClick(Sender: TObject);
    procedure chkMemoReadOnlyClick(Sender: TObject);
    procedure btnMemoSelectRangeClick(Sender: TObject);
    procedure btnMemoCutClick(Sender: TObject);
    procedure btnMemoCopyClick(Sender: TObject);
    procedure btnMemoPasteClick(Sender: TObject);
  private
    { Private declarations }
    FMemo: TCnMemo;
    FTextControl: TCnVirtualTextControl;
    procedure TestVirtualClick(Sender: TObject);
    procedure TestVirtualCaretChange(Sender: TObject);
    procedure TestVirtualSelectChange(Sender: TObject);
    procedure MemoCaretChange(Sender: TObject);
    procedure MemoSelectChange(Sender: TObject);
    procedure UpdateStatusBar;
    procedure UpdateMemoStatusBar;
    procedure CalcIndexColumnMaps;
  public
    { Public declarations }
  end;

var
  CnMemoForm: TCnMemoForm;

implementation

{$R *.DFM}

type
  TCnTestVirtualText = class(TCnVirtualTextControl)
  private

  protected
    procedure DoPaintLine(LineCanvas:TCanvas; LineNumber, HoriCharOffset: Integer;
      LineRect: TRect); override;
    procedure Paint; override;
  public
    procedure PaintCursorFrame;
  end;

procedure TCnMemoForm.FormCreate(Sender: TObject);
begin
  FMemo := TCnMemo.Create(Self);
  FMemo.Left := 16;
  FMemo.Top := 48;
  FMemo.Width := 300;
  FMemo.Height := 200;
  FMemo.Anchors := [akLeft, akRight, akTop, akBottom];
  FMemo.Lines.Add('');
  FMemo.Lines.Add('123');
  FMemo.Lines.Add('W��');
  FMemo.Lines.Add('�ҳԷ�˯���򶹶�sleep eat hit����');
  FMemo.Lines.Add(' a c .����sleep eat hit�����ʹ﷽ʽ�����졣---');
  FMemo.Lines.Add('');
  FMemo.Lines.Add(' ��a ��');
  FMemo.Lines.Add('--,.,.��');
  FMemo.Lines.Add('');

  FMemo.OnCaretChange := MemoCaretChange;
  FMemo.OnSelectChange := MemoSelectChange;
  //FMemo.Font.Name := 'Courier New';
  FMemo.Parent := ts1;

  FTextControl := TCnTestVirtualText.Create(Self);
  FTextControl.MaxLineCount := 1000;
  FTextControl.Anchors := [akLeft, akTop, akRight, akBottom];
  FTextControl.Height := 400;
  FTextControl.ShowLineNumber := True;
  FTextControl.Font.Name := 'Courier New';
  FTextControl.Parent := tsTextControl;
  FTextControl.OnCaretChange := TestVirtualCaretChange;
  FTextControl.OnSelectChange := TestVirtualSelectChange;
  (FTextControl as TCnTestVirtualText).OnClick := TestVirtualClick;

  CalcIndexColumnMaps;
end;

procedure TCnMemoForm.chkShowLineNumberClick(Sender: TObject);
begin
  FMemo.ShowLineNumber := chkShowLineNumber.Checked;
end;

procedure TCnMemoForm.btnChangeFontClick(Sender: TObject);
begin
  if dlgFontMemo.Execute then
    FMemo.Font := dlgFontMemo.Font;
end;

procedure TCnMemoForm.chkTCLineClick(Sender: TObject);
begin
  FTextControl.ShowLineNumber := chkTCLine.Checked;
end;

procedure TCnMemoForm.btnTCFontClick(Sender: TObject);
begin
  if dlgFontMemo.Execute then
    FTextControl.Font := dlgFontMemo.Font;
end;

{ TCnTestVirtualText }

procedure TCnTestVirtualText.DoPaintLine(LineCanvas: TCanvas; LineNumber,
  HoriCharOffset: Integer; LineRect: TRect);
var
  S, S1: string;
  SSR, SSC, SER, SEC, T: Integer;
begin
  S := '=== *** ' + IntToStr(LineNumber - FVertOffset) + ' - ' + IntToStr(LineNumber) + ' qwertyuiop ASDFGHJKL zxcvbnm,. 0987654321';
//  if HoriCharOffset > 0 then
//    Delete(S, 1, HoriCharOffset);

  if UseSelection and HasSelection then
  begin
    // �жϱ����Ƿ���ѡ���������������
    // ���ڡ�����ȫ�ǡ���������ǡ������Ұ��ǡ������м���
    SSR := SelectStartRow;
    SSC := SelectStartCol;
    SER := SelectEndRow;
    SEC := SelectEndCol;

    if (SER < SSR) or ((SER = SSR) and (SEC < SSC)) then
    begin
      T := SER;
      SER := SSR;
      SSR := T;

      T := SEC;
      SEC := SSC;
      SSC := T;
    end;    // ȷ�� StartRow/Col �� EndRow/Col ǰ��

    if ((LineNumber < SSR) and (LineNumber < SER)) or
      ((LineNumber > SSR) and (LineNumber > SER)) then
    begin
      // ��ѡ�����⣬������
      LineCanvas.Font.Color := Font.Color;
      LineCanvas.Brush.Style := bsClear;
      LineCanvas.TextOut(LineRect.Left, LineRect.Top, S);
    end
    else if (LineNumber = SSR) and (LineNumber <> SER) then
    begin
      // ������ʼ�е������ڽ�β�У��� 1 �� SSC - 1 ����������SSC ��ѡ����
      LineCanvas.Font.Color := Font.Color;
      LineCanvas.Brush.Style := bsClear;
      S1 := Copy(S, 1, SSC - 1);
      if S1 <> '' then
      begin
        LineCanvas.TextOut(LineRect.Left, LineRect.Top, S1);
        T := LineCanvas.TextWidth(S1);
        Inc(LineRect.Left, T);
      end;

      LineCanvas.Brush.Style := bsSolid;
      LineCanvas.Brush.Color := clHighlight;
      LineCanvas.FillRect(LineRect);
      S1 := Copy(S, SSC, MaxInt);
      if S1 <> '' then
      begin
        LineCanvas.Font.Color := clHighlightText;
        LineCanvas.Brush.Style := bsClear;
        LineCanvas.TextOut(LineRect.Left, LineRect.Top, S1);
      end;
    end
    else if (LineNumber = SER) and (LineNumber <> SSR) then
    begin
      // ���ڽ�β�е���������ʼ�У��� 1 �� SEC - 1 ��ѡ������SEC ��������
      S1 := Copy(S, 1, SEC - 1);
      if S1 <> '' then
      begin
        T := LineCanvas.TextWidth(S1);

        LineCanvas.Brush.Style := bsSolid;
        LineCanvas.Brush.Color := clHighlight;

        LineRect.Right := T;
        LineCanvas.FillRect(LineRect);

        LineCanvas.TextOut(LineRect.Left, LineRect.Top, S1);
        Inc(LineRect.Left, T);
      end;
      S1 := Copy(S, SEC, MaxInt);
      if S1 <> '' then
      begin
        LineCanvas.Brush.Style := bsClear;
        LineCanvas.Font.Color := Font.Color;
        LineCanvas.TextOut(LineRect.Left, LineRect.Top, S1);
      end;
    end
    else if (LineNumber > SSR) and (LineNumber < SER) then
    begin
      // ��ѡ�����ڣ�ȫ��ѡ��ɫ
      LineCanvas.Brush.Style := bsSolid;
      LineCanvas.Brush.Color := clHighlight;
      LineCanvas.FillRect(LineRect);

      LineCanvas.Font.Color := clHighlightText;
      LineCanvas.Brush.Style := bsClear;
      LineCanvas.TextOut(LineRect.Left, LineRect.Top, S);
    end
    else
    begin
      // ��ѡ�����ڣ��� 1 �� SSC - 1 ��������SSC �� SEC �м仭ѡ������SEC + 1 ������
      S1 := Copy(S, 1, SSC - 1);
      if S1 <> '' then   // ��������
      begin
        T := LineCanvas.TextWidth(S1);
        LineCanvas.Font.Color := Font.Color;
        LineCanvas.Brush.Style := bsClear;
        LineCanvas.TextOut(LineRect.Left, LineRect.Top, S1);
        Inc(LineRect.Left, T);
      end;

      S1 := Copy(S, SSC, SEC - SSC);
      if S1 <> '' then   // ��ѡ����
      begin
        T := LineCanvas.TextWidth(S1);
        LineCanvas.Brush.Style := bsSolid;
        LineCanvas.Brush.Color := clHighlight;
        LineRect.Right := LineRect.Left + T;
        LineCanvas.FillRect(LineRect);

        LineCanvas.Font.Color := clHighlightText;
        LineCanvas.Brush.Style := bsClear;
        LineCanvas.TextOut(LineRect.Left, LineRect.Top, S1);

        Inc(LineRect.Left, T);
      end;

      S1 := Copy(S, SEC, MaxInt);
      if S1 <> '' then   // ��������
      begin
        LineCanvas.Font.Color := Font.Color;
        LineCanvas.Brush.Style := bsClear;
        LineCanvas.TextOut(LineRect.Left, LineRect.Top, S1);
      end;
    end;
  end
  else
  begin
    LineCanvas.Font.Color := Font.Color;
    LineCanvas.Brush.Style := bsClear;
    LineCanvas.TextOut(LineRect.Left, LineRect.Top, S);
  end;
end;

procedure TCnMemoForm.TestVirtualClick(Sender: TObject);
begin
  FTextControl.Invalidate;
end;

procedure TCnTestVirtualText.Paint;
begin
  inherited;
  PaintCursorFrame;
end;

procedure TCnTestVirtualText.PaintCursorFrame;
var
  R: TRect;
begin
  GetVirtualCharPosPhysicalRect(CaretRow, CaretCol, R);
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clRed;
  Canvas.FillRect(R);
end;

procedure TCnMemoForm.chkShowCaretClick(Sender: TObject);
begin
  FTextControl.UseCaret := chkShowCaret.Checked;
end;

procedure TCnMemoForm.edtCaretRowChange(Sender: TObject);
begin
  if FTextControl <> nil then
    FTextControl.CaretRow := StrToInt(edtCaretRow.Text);
end;

procedure TCnMemoForm.edtCaretColChange(Sender: TObject);
begin
  if FTextControl <> nil then
    FTextControl.CaretCol := StrToInt(edtCaretCol.Text);
end;

procedure TCnMemoForm.TestVirtualCaretChange(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TCnMemoForm.chkUseSelectionClick(Sender: TObject);
begin
  FTextControl.UseSelection := chkUseSelection.Checked;
end;

procedure TCnMemoForm.UpdateStatusBar;
begin
  if FTextControl.HasSelection then
    StatusBar1.SimpleText := Format('Line: %d. Col: %d. Selection from %d/%d to %d/%d',
      [FTextControl.CaretRow, FTextControl.CaretCol, FTextControl.SelectStartRow, FTextControl.SelectStartCol,
       FTextControl.SelectEndRow, FTextControl.SelectEndCol])
  else
    StatusBar1.SimpleText := Format('Line: %d. Col: %d. No Selection %d/%d',
      [FTextControl.CaretRow, FTextControl.CaretCol, FTextControl.SelectStartRow, FTextControl.SelectStartCol]);
end;

procedure TCnMemoForm.TestVirtualSelectChange(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TCnMemoForm.chkMemoShowCaretClick(Sender: TObject);
begin
  FMemo.UseCaret := chkMemoShowCaret.Checked;
end;

procedure TCnMemoForm.chkMemoUseSelectionClick(Sender: TObject);
begin
  FMemo.UseSelection := chkMemoUseSelection.Checked;
end;

procedure TCnMemoForm.btnMemoLoadClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    FMemo.LoadFromFile(dlgOpen1.FileName);
end;

procedure TCnMemoForm.chkCaretAfterLineEndClick(Sender: TObject);
begin
  FMemo.CaretAfterLineEnd := chkCaretAfterLineEnd.Checked;
end;

procedure TCnMemoForm.CalcIndexColumnMaps;
var
  S: string;
  I, L, R: Integer;
begin
  mmoColumnIndex.Lines.Clear;
  mmoIndexColumn.Lines.Clear;

  S := edtString.Text;
  for I := -1 to 50 do
  begin
    if MapColumnToWideCharIndexes(S, I, L, R) then
      mmoColumnIndex.Lines.Add(Format('Col %d: Left Idx %d, Right Idx %d.', [I, L, R]));

    if MapWideCharIndexToColumns(S, I, L, R, chkMapAfterEnd.Checked) then
      mmoIndexColumn.Lines.Add(Format('Idx %d: Left Col %d, Right Col %d.', [I, L, R]));
  end;
end;

procedure TCnMemoForm.edtStringChange(Sender: TObject);
begin
  CalcIndexColumnMaps;
end;

procedure TCnMemoForm.MemoCaretChange(Sender: TObject);
begin
  UpdateMemoStatusBar;
end;

procedure TCnMemoForm.MemoSelectChange(Sender: TObject);
begin
  UpdateMemoStatusBar;
  mmoSelection.Lines.Text := FMemo.SelectText;
end;

procedure TCnMemoForm.UpdateMemoStatusBar;
begin
  if FMemo.HasSelection then
    statMemo.SimpleText := Format('Line: %d. Col: %d. Selection from %d/%d to %d/%d',
      [FMemo.CaretRow, FMemo.CaretCol, FMemo.SelectStartRow, FMemo.SelectStartCol,
       FMemo.SelectEndRow, FMemo.SelectEndCol])
  else
    statMemo.SimpleText := Format('Line: %d. Col: %d. No Selection %d/%d',
      [FMemo.CaretRow, FMemo.CaretCol, FMemo.SelectStartRow, FMemo.SelectStartCol]);
end;

procedure TCnMemoForm.chkMapAfterEndClick(Sender: TObject);
begin
  CalcIndexColumnMaps;
end;

procedure TCnMemoForm.btnMemoInsertClick(Sender: TObject);
begin
  FMemo.InsertText(edtMemoInsert.Text);
end;

procedure TCnMemoForm.btnMemoInsertCRLFClick(Sender: TObject);
begin
  FMemo.InsertText(#13#10);
end;

procedure TCnMemoForm.btnMemoInsertMultiClick(Sender: TObject);
var
  S: string;
begin
  S := '��һ��' + #13#10 + '�ڶ���' + #13#10 + '������' + #13#10 + '������'
     + #13#10 + '������' + #13#10;
  FMemo.InsertText(S);
end;

procedure TCnMemoForm.chkMemoReadOnlyClick(Sender: TObject);
begin
  FMemo.ReadOnly := chkMemoReadOnly.Checked;
end;

procedure TCnMemoForm.btnMemoSelectRangeClick(Sender: TObject);
begin
  FMemo.SelectRange(2, 3, 7, 9);
end;

procedure TCnMemoForm.btnMemoCutClick(Sender: TObject);
begin
  FMemo.CutSelectionToClipboard;
end;

procedure TCnMemoForm.btnMemoCopyClick(Sender: TObject);
begin
  FMemo.CopySelectionToClipboard;
end;

procedure TCnMemoForm.btnMemoPasteClick(Sender: TObject);
begin
  FMemo.PasteFromClipboard;
end;

end.
