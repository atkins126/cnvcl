unit UnitPdf;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TypInfo, ComCtrls, ExtCtrls;

type
  TFormPDF = class(TForm)
    dlgSave1: TSaveDialog;
    dlgOpen1: TOpenDialog;
    pgc1: TPageControl;
    tsParsePDF: TTabSheet;
    btnParsePDFToken: TButton;
    mmoPDF: TMemo;
    btnParsePDFStructure: TButton;
    btnGenSimple: TButton;
    btnExtractJPG: TButton;
    tsGenPDF: TTabSheet;
    btnPDFCreator: TButton;
    btnImages: TButton;
    btnAddJPG: TButton;
    lstJpegs: TListBox;
    chkUsePass: TCheckBox;
    lblOwnerPass: TLabel;
    lblUserPass: TLabel;
    edtOwnerPass: TEdit;
    edtUserPass: TEdit;
    rgPDFCrypt: TRadioGroup;
    grpPermission: TGroupBox;
    chkPrint: TCheckBox;
    chkCopy: TCheckBox;
    chkModify: TCheckBox;
    chkAnnotations: TCheckBox;
    chkInteractive: TCheckBox;
    chkExtract: TCheckBox;
    chkAssemble: TCheckBox;
    chkPrintHi: TCheckBox;
    procedure btnGenSimpleClick(Sender: TObject);
    procedure btnParsePDFTokenClick(Sender: TObject);
    procedure btnParsePDFStructureClick(Sender: TObject);
    procedure btnAddJPGClick(Sender: TObject);
    procedure btnImagesClick(Sender: TObject);
    procedure btnPDFCreatorClick(Sender: TObject);
    procedure btnExtractJPGClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPDF: TFormPDF;

implementation

uses
  CnPDF, CnPDFCrypt, CnNative; 

{$R *.dfm}

procedure TFormPDF.btnGenSimpleClick(Sender: TObject);
var
  PDF: TCnPDFDocument;
  Page: TCnPDFDictionaryObject;
  Box: TCnPDFArrayObject;
  Stream: TCnPDFStreamObject;
  Resource: TCnPDFDictionaryObject;
  Dict, ResDict: TCnPDFDictionaryObject;
  Content: TCnPDFStreamObject;
  ContData: TStringList;
begin
  dlgOpen1.Title := 'Open a JPEG File';
  if not dlgOpen1.Execute then
    Exit;

  dlgSave1.Title := 'Save PDF File';
  if dlgSave1.Execute then
  begin
    PDF := TCnPDFDocument.Create;
    try
      PDF.Body.CreateResources;

      PDF.Body.Info.AddAnsiString('Author', 'CnPack');
      PDF.Body.Info.AddAnsiString('Producer', 'CnPDF in CnVCL');
      PDF.Body.Info.AddAnsiString('Creator', 'CnPack PDF Demo');
      PDF.Body.Info.AddAnsiString('CreationDate', 'D:20240101000946+08''00''');

      PDF.Body.Info.AddWideString('Title', '���Ա���');
      PDF.Body.Info.AddWideString('Subject', '��������');  // ք
      PDF.Body.Info.AddWideString('Keywords', '�ؼ���1���ؼ���2');
      PDF.Body.Info.AddWideString('Company', 'CnPack������');
      PDF.Body.Info.AddWideString('Comments', '����ע��');

      Page := PDF.Body.AddPage;
      Box := Page.AddArray('MediaBox');
      Box.AddNumber(0);
      Box.AddNumber(0);
      Box.AddNumber(612);
      Box.AddNumber(792);

      // ���ͼ������
      Stream := TCnPDFStreamObject.Create;
      Stream.SetJpegImage(dlgOpen1.FileName);
      PDF.Body.AddObject(Stream);

      // ��� ExtGState
      Dict := TCnPDFDictionaryObject.Create;
      Dict.AddName('Type', 'ExtGState');
      Dict.AddFalse('AIS');
      Dict.AddName('BM', 'Normal');
      Dict.AddNumber('CA', 1);
      Dict.AddNumber('ca', 1);
      PDF.Body.AddObject(Dict);

      // ������ô�ͼ�����Դ
      Resource := PDF.Body.AddResource(Page);

      // Dict �� Stream �� ID Ҫ��Ϊ����
      ResDict := Resource.AddDictionary('ExtGState');
      ResDict.AddObjectRef('GS' + IntToStr(Dict.ID), Dict);
      ResDict := Resource.AddDictionary('XObject');
      ResDict.AddObjectRef('IM' + IntToStr(Stream.ID), Stream);

      // ���ҳ�沼������
      Content := PDF.Body.AddContent(Page);

      // զ�����أ�����ͼ�ȣ�
      ContData := TStringList.Create;
      ContData.Add('q');
      ContData.Add('1 0 0 1 400 400 cm');
      ContData.Add('200 0 0 200 0 0 cm');
      ContData.Add('/IM' + IntToStr(Stream.ID) + ' Do');
      ContData.Add('Q');
      Content.SetStrings(ContData);
      ContData.Free;

      PDF.SaveToFile(dlgSave1.FileName);
    finally
      PDF.Free;
    end;
  end;
end;

procedure TFormPDF.btnParsePDFTokenClick(Sender: TObject);
var
  I: Integer;
  P: TCnPDFParser;
  M: TMemoryStream;
  S, C: string;
begin
  dlgOpen1.Title := 'Open a PDF File';
  if dlgOpen1.Execute then
  begin
    P := TCnPDFParser.Create;
    M := TMemoryStream.Create;
    M.LoadFromFile(dlgOpen1.FileName);
    P.SetOrigin(M.Memory, M.Size);

    mmoPDF.Lines.Clear;
    mmoPDF.Lines.BeginUpdate;
    I := 0;
    try
      while True do
      begin
        // ��ӡ P �������� Token
        Inc(I);
        if P.TokenID in [pttStreamData] then
          C := '... Stream Data ...'
        else if P.TokenID in [pttLineBreak] then
          C := '<CRLF>'
        else if P.TokenLength > 128 then
          C := '... <Token Too Long> ...'
        else
          C := P.Token;

        S := Format('#%d Offset %d Length %d %-20.20s %s ', [I, P.RunPos - P.TokenLength, P.TokenLength,
          GetEnumName(TypeInfo(TCnPDFTokenType), Ord(P.TokenID)), C]);

        mmoPDF.Lines.Add(S);
        P.Next;
      end;
    finally
      mmoPDF.Lines.EndUpdate;
      M.Free;
      P.Free;
    end;
  end;
end;

procedure TFormPDF.btnParsePDFStructureClick(Sender: TObject);
var
  PDF: TCnPDFDocument;
  Pass: string;
begin
   dlgOpen1.Title := 'Open a PDF File';
  if dlgOpen1.Execute then
  begin
    PDF := CnLoadPDFFile(dlgOpen1.FileName);

    if PDF <> nil then
    begin
      if PDF.Encrypted then
      begin
        Pass := '123456';
        if PDf.NeedPassword then
        begin
          if InputQuery('Enter Password', 'Enter Password:', Pass) then
          begin
            try
              PDF.Decrypt(Pass);
            except
              ;
            end;
          end;
        end;
      end;
      mmoPDF.Lines.Clear;

      mmoPDF.Lines.BeginUpdate;
      PDF.DumpToStrings(mmoPDF.Lines);
      mmoPDF.Lines.EndUpdate;

      if dlgSave1.Execute then
        PDF.SaveToFile(dlgSave1.FileName);
      PDF.Free;
    end;
  end;
end;

procedure TFormPDF.btnAddJPGClick(Sender: TObject);
begin
  dlgOpen1.Title := 'Open JPEG File(s)';
  if dlgOpen1.Execute then
    lstJpegs.Items.AddStrings(dlgOpen1.Files);
end;

procedure TFormPDF.btnImagesClick(Sender: TObject);
begin
  dlgSave1.Title := 'Save to a PDF';
  if dlgSave1.Execute then
    CnJpegFilesToPDF(lstJpegs.Items, dlgSave1.FileName);
end;

procedure TFormPDF.btnPDFCreatorClick(Sender: TObject);
var
  Creator: TCnImagesToPDFCreator;
begin
  dlgSave1.Title := 'Save to a PDF';
  if dlgSave1.Execute then
  begin
    Creator := TCnImagesToPDFCreator.Create;
    Creator.AddJpegFiles(lstJpegs.Items);
    Creator.TopMargin := 20;
    Creator.LeftMargin := 20;
    Creator.RightMargin := 20;
    Creator.BottomMargin := 20;

    if chkUsePass.Checked then
    begin
      Creator.Encrypt := True;
//      if rgPDFCrypt.ItemIndex = 2 then
//        Creator.Permission := Cardinal(-3904)
//      else
//        Creator.Permission := Cardinal(-2880);

      Creator.CanPrint := chkPrint.Checked;
      Creator.CanModify := chkModify.Checked;
      Creator.CanCopy := chkCopy.Checked;
      Creator.CanAnnotations := chkAnnotations.Checked;
      Creator.CanInteractive := chkInteractive.Checked;
      Creator.CanExtract := chkExtract.Checked;
      Creator.CanAssemble := chkAssemble.Checked;
      Creator.CanPrintHi := chkPrintHi.Checked;

      Creator.OwnerPassword := edtOwnerPass.Text;
      Creator.UserPassword := edtUserPass.Text;
      Creator.EncryptionMethod := TCnPDFEncryptionMethod(rgPDFCrypt.ItemIndex + 1);
    end;

    Creator.SaveToPDF(dlgSave1.FileName);
    Creator.Free;
  end;
end;

procedure TFormPDF.btnExtractJPGClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    CnExtractJpegFilesFromPDF(dlgOpen1.FileName, ExtractFilePath(Application.ExeName));
end;

end.
