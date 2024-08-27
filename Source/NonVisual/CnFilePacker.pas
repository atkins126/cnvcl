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

unit CnFilePacker;
{* |<PRE>
================================================================================
* ������ƣ������������������
* ��Ԫ���ƣ��ļ�Ŀ¼������ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack������ �ӕF
* ��    ע��
* ����ƽ̨��PWinXP + Delphi 7.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2011.09.04 V0.03
*               ����һ����Ŀ¼�ṹ��������⡣
*           2009.07.08 V0.02
*               ����һ��ָ���ͷ����⣬���Ӷ� D2009 ��֧�֡�
*           2008.06.27 V0.01
*               ������Ԫ�����������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Windows, CnConsts, CnCompConsts, CnNative, CnClasses, CnCommon;

type

// �ļ��ṹ PPackHeader |PPackDir| ��TDataBlock|data|��...��

  TCompressMode = (cmNONE, cmCustom, cmZIP, cmRAR);
  {* ѹ��ģʽ}

//------------------------------------------------------------------------------
// �ļ�ͷ
//------------------------------------------------------------------------------

  PPackHeader = ^TPackHeader;
  {* ����ļ�ͷ�ṹָ��}

  TPackHeader = record
  {* ����ļ�ͷ�ṹ}
    ZipName: array[0..7] of AnsiChar;      //= ('cnpacker');
    FileInfoCount: Cardinal;
    Compress: TCompressMode;
    FileSize: Int64;
  end;

//------------------------------------------------------------------------------
// �ļ���Ϣ
//------------------------------------------------------------------------------

  PPackFileInformation = ^TPackFileInformation;
  {* �ļ������ص���Ϣ�ṹָ��}

  TPackFileInformation = record
  {* �ļ������ص���Ϣ�ṹ}
    Name: array[0..255] of AnsiChar;
    DataStart: Cardinal;
  end;

  TArrayPackFileInformation = array of TPackFileInformation;

//------------------------------------------------------------------------------
// ����ͷ
//------------------------------------------------------------------------------

  TDataBlock = record
  {* �ļ�����ͷ}
    FileName: array[0..255] of AnsiChar;
    DataLength: Cardinal;
  end;

//------------------------------------------------------------------------------
// �ļ�����Ԫ
//------------------------------------------------------------------------------

  TFileCell = record
  {* �ļ�����Ԫ}
    ReadFileName: string;
    ConvertFileName: string;
  end;

  TFileCells = array of TFileCell;

  ICnCompress = interface
  {* �ļ������ص�ѹ���ӿ�}
    ['{F2379CD7-824B-4D8A-89C3-D897BF95F34C}']
    function GetCompressMode: TCompressMode;
    procedure DoCompressData(var AStream: TBytes; var ALength: Cardinal);
    procedure DoDeCompressData(var AStream: TBytes; var ALength: Cardinal);
  end;

{ TCnFilePacker }

  ECnFilePackerException = class(Exception);
  {* �ļ��������쳣}

{$IFDEF SUPPORT_32_AND_64}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF}
  TCnFilePacker = class(TCnComponent)
  {* �ļ����ʵ����}
  private
    FPackHeaderInfo: PPackHeader;
    {* �ļ�ͷ}
    FPackFileInformations: TArrayPackFileInformation;
    {* ����ļ����ļ���Ϣ}
    FImportPackFileInfo: TArrayPackFileInformation;
    {* ���ⲿʹ�õ��ļ���Ϣ}
    FImprotPackDirectoryInfo: TArrayPackFileInformation;
    {* ���ⲿʹ�õ��ļ�Ŀ¼��Ϣ}
    FCreateSavePath: Boolean;
    {* ��־�Ƿ񴴽��˱�����Ŀ¼��������ļ���Ŀ¼}
    FCompressMode: TCompressMode;
    {* ѹ��ģʽ}
    FCompress: Boolean;
    {* �Ƿ�ѹ��}
    FPackedSubDirectory: Boolean;
    {* �Ƿ������Ŀ¼}
    FFiles: TFileCells;
    {* �γ��ļ��б�}
    FCurrent, FCount: Cardinal;
    {* �ļ���Ϣ�ĵ�ǰ������������}
    FFileinfoCount: Cardinal;
    {* �ļ���Ϣ�����������ʱ=fcurrent�����ʱ�Ӱ��еõ���}
    FDestFileName: string;
    {* �������ļ����ļ�·��}
    FSavePath: string;
    {* ������ŵ�Ŀ¼}
    FAddFilesCount: Integer;
    {* ��־�Ƿ�ʹ�� AddFile �������ӵ��ļ�������}
    FCompressInterface: ICnCompress;
    {* ������Զ���ѹ����}
    function GetPropGetPackFileDirectoryInfo: TArrayPackFileInformation;
    function GetPropGetPackFileInformation: TArrayPackFileInformation;
    function GetPropGetPackHeader: TPackHeader;
    {* �����ֶ��õ��ĺ�����ǰ�߼� prop ��ʾ����}
    procedure CompressData(var AStream: TBytes; var ALength: Cardinal);
    {* ѹ�����ݺ���}
    procedure DeCompressData(var AStream: TBytes; var ALength: Cardinal);
    {* ��ѹ�����ݺ���}
  protected
    FPack, FDestFile: TFileStream;
    procedure CheckFileCellsCounts;
    
    procedure DoCompressData(var AStream: TBytes; var ALength: Cardinal); virtual;
    procedure DoDeCompressData(var AStream: TBytes; var ALength: Cardinal); virtual;
    {* �����Ҫѹ����������ѹ���ӿڵĻ��������������麯����}
    function GetPackHeader: PPackHeader;
    {* �õ�����ļ����ļ�ͷ}
    function GetPackFileInformation: TArrayPackFileInformation;
    {* ����һ���ڴ沢�õ�����ļ��ļ�����Ϣ�����ⲿ�����ͷ�}
    procedure GetComponentInfo(var AName, Author, Email, Comment: string); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    procedure DoPack;
    {* ��װ����ļ���������}
    procedure SaveToFile(APackFileInfo: TPackFileInformation);
    {* �洢һ���ļ�}
    procedure SaveToFiles;
    {* �洢�����ļ�}
    procedure CreateDirectory;
    {* �����ļ�Ŀ¼}
    procedure AddDircetory(ADirName: string); overload;
    procedure AddDircetory(ARootName, ADirName: string); overload;
    {* ���Ŀ¼}
    procedure AddFile(ADirName, AFileName: string); overload;
    procedure AddFile(AFileName: string); overload;
    {* ����ļ�}
    procedure AddCompressClass(ACompressClass: TInterfacedClass);
    {* ���ѹ����}
    property PackFileInformation: TArrayPackFileInformation read GetPropGetPackFileInformation;
    {* �ļ���Ϣ}
    property PackFileDirectoryInfo: TArrayPackFileInformation read GetPropGetPackFileDirectoryInfo;
    {* �ļ�Ŀ¼��Ϣ}
  published
    property DestFileName: string read FDestFileName write FDestFileName;
    property SavePath: string read FSavePath write FSavePath;
    property PackedSubDirectory: Boolean read FPackedSubDirectory write FPackedSubDirectory;
    property Compress: Boolean read FCompress write FCompress;
    property CompressMode: TCompressMode read FCompressMode write FCompressMode;

    property PackHeaderInformation: TPackHeader read GetPropGetPackHeader;
    {* �ļ�ͷ��Ϣ}
  end;

implementation

const
  SCnIncCounts = 20;
  SFileNameError = 'Destination FileName is Empty.';

// �����һ�� '\' Ϊ��õ����沿��
function GetFileName(AFileName: string): string;
var
  Len, I: Cardinal;
begin
  Len := Length(AFileName);
  for I := Len - 1 downto 1 do
    if AFileName[I] = '\' then
      Break;
  Result := Copy(AFileName, I + 1, Len - I);
end;

procedure Check(var ADirName: string);
begin
  if ADirName[Length(ADirName)] <> '\' then
    ADirName := ADirName + '\';
end;

{ TCnFilePacker }

procedure TCnFilePacker.AddCompressClass(ACompressClass: TInterfacedClass);
begin
  FCompressInterface := ACompressClass.Create as ICnCompress;
end;

procedure TCnFilePacker.AddDircetory(ARootName, ADirName: string);
var
  CurrentDirectory, LastNameofCurrentDirectory: string;
  // �ݹ�Ŀ¼���γ��ļ��б�

  procedure FindFile(ADirName: string);
  var
    SRec: TSearchRec;
    tmpCurrentDirectory, tmpLastNameofCurrentDirectory: string;     // ���浱ǰĿ¼��ݹ�û����ջ��nnd
  begin
    if FindFirst(ADirName, faAnyFile, SRec) = 0 then
    begin
      repeat
        CheckFileCellsCounts;
        if (SRec.Name = '.') or (SRec.Name = '..') then
          Continue;
          
        if (SRec.Attr and faDirectory) <> 0 then
        begin
          FFiles[FCurrent].ReadFileName := CurrentDirectory + SRec.Name + '\' + IntToStr(SRec.Attr) + '?';
          FFiles[FCurrent].ConvertFileName := ARootName + LastNameofCurrentDirectory + SRec.Name + '\' + IntToStr(SRec.Attr) + '?';
          Inc(FCurrent);
          
          if FPackedSubDirectory then
          begin
            tmpLastNameofCurrentDirectory := LastNameofCurrentDirectory;
            tmpCurrentDirectory := CurrentDirectory;
            LastNameofCurrentDirectory := LastNameofCurrentDirectory + SRec.Name + '\';
            CurrentDirectory := CurrentDirectory + SRec.Name + '\';
            FindFile(copy(ADirName, 1, Length(ADirName) - 3) + SRec.Name + '\*.*');
            LastNameofCurrentDirectory := tmpLastNameofCurrentDirectory;
            CurrentDirectory := tmpCurrentDirectory;
            Continue;
          end;
        end;
        FFiles[FCurrent].ReadFileName := CurrentDirectory + SRec.Name;
        FFiles[FCurrent].ConvertFileName := ARootName + LastNameofCurrentDirectory + SRec.Name;
        Inc(FCurrent);
      until FindNext(SRec) <> 0;
      SysUtils.FindClose(SRec);
    end;
  end;

begin
  CheckFileCellsCounts;
  Check(ADirName);
  if ARootName = ' ' then
    ARootName := ''
  else
    Check(ARootName);
    
  CurrentDirectory := ADirName;
  LastNameofCurrentDirectory := _CnExtractFileName(CurrentDirectory);
  
  if Length(ADirName) = 3 then // is 'xyz:\'
    LastNameofCurrentDirectory := '';
  FFiles[FCurrent].ReadFileName := ADirName + IntToStr(GetFileAttributes(PChar(ADirName))) + '?';
  FFiles[FCurrent].ConvertFileName := ARootName + IntToStr(GetFileAttributes(PChar(ADirName))) + '?';
  Inc(FCurrent);
  ADirName := ADirName + '*.*';
  FindFile(ADirName);
end;

procedure TCnFilePacker.AddDircetory(ADirName: string);
begin
  AddDircetory(' ', ADirName);
end;

procedure TCnFilePacker.AddFile(AFileName: string);
begin
  CheckFileCellsCounts;
  FFiles[FCurrent].ReadFileName := '?';
  FFiles[FCurrent].ConvertFileName := '16' + '?';
  Inc(FCurrent);
  FFiles[FCurrent].ReadFileName := AFileName;
  FFiles[FCurrent].ConvertFileName := _CnExtractFilename(AFileName);
  Inc(FCurrent);
end;

procedure TCnFilePacker.AddFile(ADirName, AFileName: string);
begin
  CheckFileCellsCounts;
  check(ADirName);
  FFiles[FCurrent].ReadFileName := ADirName + '?';
  FFiles[FCurrent].ConvertFileName := ADirName + '16' + '?';
  Inc(FCurrent);
  FFiles[FCurrent].ReadFileName := AFileName;
  FFiles[FCurrent].ConvertFileName := ADirName + _CnExtractFilename(AFileName);
  Inc(FCurrent);
end;

procedure TCnFilePacker.CheckFileCellsCounts;
begin
  if FCurrent >= FCount then
  begin
    FCount := FCount + SCnIncCounts;
    SetLength(FFiles, FCount);
  end;
end;

procedure TCnFilePacker.CompressData(var AStream: TBytes; var ALength: Cardinal);
begin
  if FCompressInterface = nil then
    DoCompressData(AStream, ALength)
  else if CompressMode = FCompressInterface.GetCompressMode then
    FCompressInterface.DoCompressData(AStream, ALength);
end;

constructor TCnFilePacker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // fms := TMemoryStream.Create;
  FCompress := False;
  FPackedSubDirectory := true;
  FAddFilesCount := -1;
  FCurrent := 0;
  FCount := 20;
  SetLength(FFiles, FCount);
  FCreateSavePath := False;
end;

procedure TCnFilePacker.CreateDirectory;
var
  I: Integer;
  S, DirName: string;
  attr: Byte;
begin
  if not FCreateSavePath then
  begin
    ForceDirectories(SavePath);
    FCreateSavePath := True;
  end;
  
  for I := 0 to FFileinfoCount - 1 do
  begin
    S := {$IFDEF UNICODE}string{$ENDIF}(FPackFileInformations[I].Name);
    if Length(s) < 7 then
      Continue;     // xyz:\16?
      
    if s[Length(s)] = '?' then
    begin
      attr := StrToInt(Copy(s, Length(s) - 2, 2));
      s := Copy(s, 1, Length(s) - 3);
      DirName := SavePath + '\' + s;
      ForceDirectories(DirName);
      SetFileAttributes(PChar(dirname), attr);
    end
  end;
end;

procedure TCnFilePacker.DeCompressData(var AStream: TBytes; var ALength: Cardinal);
begin
  if FCompressInterface = nil then
    DoDeCompressData(AStream, ALength)
  else if CompressMode = FCompressInterface.GetCompressMode then
    FCompressInterface.DoDeCompressData(AStream, ALength);
end;

destructor TCnFilePacker.Destroy;
begin
  if FPackHeaderInfo <> nil then
  begin
    FreeMem(FPackHeaderInfo);
    FPackHeaderInfo := nil;
  end;
  inherited;
end;

procedure TCnFilePacker.DoCompressData(var AStream: TBytes; var ALength: Cardinal);
begin

end;

procedure TCnFilePacker.DoDeCompressData(var AStream: TBytes; var ALength: Cardinal);
begin

end;

procedure TCnFilePacker.SaveToFile(APackFileInfo: TPackFileInformation);
var
  F: TFileStream;   // ��ʱ�ļ����������ļ�
  db: TDataBlock;
  Tdb: TBytes;      // ��ʱ�����������м�����
  S: string;
begin
  S := {$IFDEF UNICODE}string{$ENDIF}(APackFileInfo.Name);
  if (s = '') or (s[Length(s)] = '?') then
    Exit;
  
  try
    FDestFile := TFileStream.Create(DestFileName, fmOpenReadWrite);
    if fSavePath[length(fSavePath)] = '\' then
      SetLength(fSavePath, Length(fSavePath) - 1);
    FDestFile.Position := APackFileInfo.DataStart;
    FDestFile.Read(db, SizeOf(db));
    
    if db.DataLength <> 0 then
    begin
      SetLength(Tdb, db.DataLength);
      FDestFile.Read(Tdb[0], db.DataLength);
      F := TFileStream.Create(SavePath + '\' + S, fmCreate or fmOpenReadWrite);
      if CompressMode <> cmNONE then
        DeCompressData(Tdb, db.DataLength);
      F.Write(tdb[0], db.DataLength);
      F.Free;
    end
    else
    begin
      F := TFileStream.Create(SavePath + '\' + S, fmCreate or fmOpenReadWrite);
      F.Free;
    end;
  finally
    FreeAndNil(FDestFile);
  end;
end;

function TCnFilePacker.GetPackFileInformation: TArrayPackFileInformation;
var
  I: Integer;
  db: TDataBlock;
  fms: TFileStream;  // ��ʱ�ļ���
begin
  if FPackHeaderInfo <> nil then
  begin
    FreeMem(FPackHeaderInfo);
    FPackHeaderInfo := nil;
  end;

  FPackHeaderInfo := GetPackHeader;
  CompressMode := FPackHeaderInfo^.Compress;
  if FPackHeaderInfo^.ZipName <> 'CNPACKER' then // �ļ�ͷ���� cnpacker���˳�
    Exit;
  Fms := TFileStream.Create(DestFileName, fmOpenRead);
  Fms.Position := SizeOf(TpackHeader);
  SetLength(Result, FPackHeaderInfo^.FileInfoCount);
  FFileinfoCount := FPackHeaderInfo^.FileInfoCount;
  
  for I := 0 to FPackHeaderInfo^.FileInfoCount - 1 do
  begin
    Fms.Read(db, SizeOf(db));
    StrCopy(Result[I].Name, db.FileName);
    Result[I].DataStart := Fms.Position - SizeOf(db);
    Fms.Position := Fms.Position + LongInt(db.DataLength);
  end;
  Fms.Free;
end;

function TCnFilePacker.GetPackHeader: PPackHeader;
var
  fms: TFileStream;
begin
  GetMem(Result, SizeOf(TPackHeader));
  Fms := TFileStream.Create(DestFileName, fmOpenRead);
  Fms.Position := 0;
  Fms.Read(Result^, SizeOf(TPackHeader));
  FreeAndNil(fms);
end;

procedure TCnFilePacker.GetComponentInfo(var AName, Author, Email,
  Comment: string);
begin
  AName := SCnFilePackerName;
  Author := SCnPack_ZiMin;
  Email := SCnPack_ZiMinEmail;
  Comment := SCnFilePackerComment;
end;

function TCnFilePacker.GetPropGetPackFileDirectoryInfo: TArrayPackFileInformation;
var
  I: Cardinal;
  S: string;
  count, current: Cardinal;
begin
  count := SCnIncCounts;
  current := 0;
  SetLength(FImprotPackDirectoryInfo, count);
  FPackFileInformations := GetPackFileInformation;
  
  for I := 0 to FFileinfoCount - 1 do
  begin
    S := {$IFDEF UNICODE}string{$ENDIF}(FPackFileInformations[I].Name);
    if S[Length(s)] = '?' then
    begin
      S := IncludeTrailingBackslash(_CnExtractFilePath(S));

      if current = count then
      begin
        count := count + SCnIncCounts;
        SetLength(FImprotPackDirectoryInfo, count);
      end;
      
      StrPCopy(FImprotPackDirectoryInfo[current].Name, {$IFDEF UNICODE}AnsiString{$ENDIF}(S));
      FImprotPackDirectoryInfo[current].DataStart := FPackFileInformations[I].DataStart;
      Inc(current);
    end;
  end;
  SetLength(FImprotPackDirectoryInfo, current);
  Result := FImprotPackDirectoryInfo;
end;

function TCnFilePacker.GetPropGetPackFileInformation: TArrayPackFileInformation;
var
  I: Cardinal;
  S: string;
  count, current: Cardinal;
begin
  count := SCnIncCounts;
  current := 0;
  SetLength(FImportPackFileInfo, count);
  FPackFileInformations := GetPackFileInformation;
  
  for I := 0 to FFileinfoCount - 1 do
  begin
    S := {$IFDEF UNICODE}string{$ENDIF}(FPackFileInformations[I].Name);
    if S[Length(s)] <> '?' then
    begin
      if current = count then
      begin
        count := count + SCnIncCounts;
        SetLength(FImportPackFileInfo, count);
      end;
      
      FImportPackFileInfo[current].Name := FPackFileInformations[I].Name;
      FImportPackFileInfo[current].DataStart := FPackFileInformations[I].DataStart;
      Inc(current);
    end;
  end;
  
  SetLength(FImportPackFileInfo, current);
  Result := FImportPackFileInfo;
end;

function TCnFilePacker.GetPropGetPackHeader: TPackHeader;
begin
  if FPackHeaderInfo <> nil then
  begin
    FreeMem(FPackHeaderInfo);
    FPackHeaderInfo := nil;
  end;
  FPackHeaderInfo := GetPackHeader;
  Result := FPackHeaderInfo^;
end;

procedure TCnFilePacker.DoPack();
var
  ph: TPackHeader;
  db: TDataBlock;
  I: Integer;
  Tdb: TBytes;
  F: TFileStream;
begin
  FillChar(ph, SizeOf(Tpackheader), #0);
  if DestFileName = '' then
    ECnFilePackerException.Create(SFileNameError);

  if not FileExists(DestFileName) then
  begin
    FPack := TFileStream.Create(DestFileName, fmCreate);
    FPack.Position := 0;
    // �����ļ�ͷ
    FPack.Seek(SizeOf(TPackHeader), soFromCurrent);
  end
  else
  begin
    FPack := TFileStream.Create(DestFileName, fmOpenReadWrite);
    FPack.Read(ph, SizeOf(ph));
    FPack.Position := FPack.Size;
  end;
  
   // ѭ�������ļ�
  for I := 0 to FCurrent - 1 do
  begin
    if FFiles[I].ReadFileName[Length(FFiles[I].ReadFileName)] = '?' then
    begin
      strpcopy(db.FileName, {$IFDEF UNICODE}AnsiString{$ENDIF}(FFiles[I].ConvertFileName));
      db.DataLength := 0;
      FPack.Write(db, SizeOf(db));
    end
    else
    begin
      F := TFileStream.Create(FFiles[I].ReadFileName, fmOpenRead);
      strpcopy(db.FileName, {$IFDEF UNICODE}AnsiString{$ENDIF}(FFiles[I].ConvertFileName));
      db.DataLength := F.Size;
      if db.DataLength <> 0 then
      begin
        SetLength(Tdb, db.DataLength);
        F.Read(Tdb[0], db.DataLength);
        if CompressMode <> cmNONE then
          CompressData(tdb, db.DataLength);
        FPack.Write(db, SizeOf(db));
        FPack.Write(tdb[0], db.DataLength);
        FreeAndNil(F);
      end
      else
      begin
        FPack.Write(db, SizeOf(db));
        FreeAndNil(F);
      end;
    end;
  end;
  
  // д�ļ�ͷ
  ph.ZipName := 'CNPACKER';
  ph.Compress := CompressMode;
  ph.FileSize := FPack.Size;
  Inc(ph.FileInfoCount, FCurrent);
  FPack.Position := 0;
  FPack.Write(ph, SizeOf(ph));
  FreeAndNil(FPack);
  FCurrent := 0;
  FCount := 20;
  SetLength(FFiles, FCount);
end;

procedure TCnFilePacker.SaveToFiles;
var
  I: Integer;
begin
  if FPackFileInformations = nil then
    FPackFileInformations := GetPackFileInformation;      // �ȵõ�Ŀ¼
  CreateDirectory;     // ����Ŀ¼
  for I := 0 to Length(FPackFileInformations) - 1 do
    SaveToFile(FPackFileInformations[I]);      // ö�ٵ��ý��ÿ���ļ�

  FreeAndNil(FDestFile);
end;

end.
