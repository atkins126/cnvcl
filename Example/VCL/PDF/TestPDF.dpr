program TestPDF;

uses
  Forms,
  UnitPdf in 'UnitPdf.pas' {FormPDF},
  CnPDF in '..\..\..\Source\Common\CnPDF.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormPDF, FormPDF);
  Application.Run;
end.
