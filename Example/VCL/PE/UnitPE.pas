unit UnitPE;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, ToolWin, Psapi, CnPE, CnNative, CnCommon, CnRTL;

type
  TFormPE = class(TForm)
    lblPEFile: TLabel;
    edtPEFile: TEdit;
    btnParsePE: TButton;
    cbbRunModule: TComboBox;
    btnBrowse: TButton;
    btnParsePEFile: TButton;
    bvl1: TBevel;
    pgcPE: TPageControl;
    tsDosHeader: TTabSheet;
    tsNtHeader: TTabSheet;
    dlgOpen1: TOpenDialog;
    mmoDos: TMemo;
    mmoFile: TMemo;
    mmoOptional: TMemo;
    tsSectionHeader: TTabSheet;
    mmoSection: TMemo;
    tlb1: TToolBar;
    btn0: TToolButton;
    btn1: TToolButton;
    btn2: TToolButton;
    btn3: TToolButton;
    btn4: TToolButton;
    btn5: TToolButton;
    btn6: TToolButton;
    btn7: TToolButton;
    btn8: TToolButton;
    btn9: TToolButton;
    btn10: TToolButton;
    btn11: TToolButton;
    btn12: TToolButton;
    btn13: TToolButton;
    btn14: TToolButton;
    btn15: TToolButton;
    btnViewSection: TButton;
    edtSectionIndex: TEdit;
    udSection: TUpDown;
    tsStackTrace: TTabSheet;
    btnStackTrace: TButton;
    mmoStack: TMemo;
    btnDebugInfo: TButton;
    mmoNames: TMemo;
    btnTDNames: TButton;
    btnTDSourceModules: TButton;
    btnTDProc: TButton;
    btnTDLineNumbers: TButton;
    btnLoad: TButton;
    btnMapNames: TButton;
    btnMapSourceModules: TButton;
    btnMapProc: TButton;
    btnMapLineNumbers: TButton;
    procedure btnBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnParsePEFileClick(Sender: TObject);
    procedure btnParsePEClick(Sender: TObject);
    procedure btn0Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnViewSectionClick(Sender: TObject);
    procedure btnStackTraceClick(Sender: TObject);
    procedure btnDebugInfoClick(Sender: TObject);
    procedure btnTDNamesClick(Sender: TObject);
    procedure btnTDSourceModulesClick(Sender: TObject);
    procedure btnTDProcClick(Sender: TObject);
    procedure btnTDLineNumbersClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnMapSourceModulesClick(Sender: TObject);
    procedure btnMapProcClick(Sender: TObject);
    procedure btnMapLineNumbersClick(Sender: TObject);
  private
    FPE: TCnPE;
    procedure DumpPE(PE: TCnPE);
    procedure LoadModuleList;
  public
    property PE: TCnPE read FPE write FPE;
  end;

var
  FormPE: TFormPE;

implementation

{$R *.DFM}

function DumpByte(AB: Byte): string;
begin
  Result := Format('%2.2x', [AB]);
end;

function DumpWord(AW: Word): string;
begin
  Result := Format('%4.4x', [AW]);
end;

function DumpDWord(AD: DWORD): string;
begin
  Result := Format('%8.8x', [AD]);
end;

function DumpTUInt64(AU: TUInt64): string;
begin
  Result := Format('%16.16x', [AU]);
end;

function DumpBoolean(AB: Boolean): string;
begin
  if AB then
    Result := 'True'
  else
    Result := 'False';
end;

function DumpPointer(AP: Pointer): string;
begin
{$IFDEF CPUX64}
  Result := Format('%16.16x', [TCnNativeUInt(AP)]);
{$ELSE}
  Result := Format('%8.8x', [TCnNativeUInt(AP)]);
{$ENDIF}
end;

procedure D(M: TMemo; const N, V: string);
begin
  if N <> '' then
    M.Lines.Add(N + ': ' + V)
  else
    M.Lines.Add(V);
end;

procedure TFormPE.btnBrowseClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    edtPEFile.Text := dlgOpen1.FileName;
end;

procedure TFormPE.FormCreate(Sender: TObject);
begin
  LoadModuleList;
end;

procedure TFormPE.btnParsePEFileClick(Sender: TObject);
begin
  mmoDos.Clear;
  mmoFile.Clear;
  mmoOptional.Clear;
  mmoSection.Clear;

  FreeAndNil(FPE);

  PE := TCnPE.Create(edtPEFile.Text);
  PE.Parse;
  DumpPE(PE);
end;

procedure TFormPE.DumpPE(PE: TCnPE);
var
  I: Integer;
  E: PCnPEExportItem;
begin
  D(mmoDos, 'DosMagic', DumpWord(PE.DosMagic));
  D(mmoDos, 'DosCblp', DumpWord(PE.DosCblp));
  D(mmoDos, 'DosCp', DumpWord(PE.DosCp));
  D(mmoDos, 'DosCrlc', DumpWord(PE.DosCrlc));
  D(mmoDos, 'DosCparhdr', DumpWord(PE.DosCparhdr));
  D(mmoDos, 'DosMinalloc', DumpWord(PE.DosMinalloc));
  D(mmoDos, 'DosMaxalloc', DumpWord(PE.DosMaxalloc));
  D(mmoDos, 'DosSs', DumpWord(PE.DosSs));
  D(mmoDos, 'DosSp', DumpWord(PE.DosSp));
  D(mmoDos, 'DosCsum', DumpWord(PE.DosCsum));
  D(mmoDos, 'DosIp', DumpWord(PE.DosIp));
  D(mmoDos, 'DosCs', DumpWord(PE.DosCs));
  D(mmoDos, 'DosLfarlc', DumpWord(PE.DosLfarlc));
  D(mmoDos, 'DosOvno', DumpWord(PE.DosOvno));
  D(mmoDos, 'DosOemid', DumpWord(PE.DosOemid));
  D(mmoDos, 'DosOeminfo', DumpWord(PE.DosOeminfo));
  D(mmoDos, 'DosLfanew', DumpDWord(PE.DosLfanew));

  D(mmoFile, 'Signature', DumpDWORD(PE.Signature));

  D(mmoFile, 'FileMachine', DumpWord(PE.FileMachine));
  D(mmoFile, 'FileNumberOfSections', DumpWord(PE.FileNumberOfSections));
  D(mmoFile, 'FileTimeDateStamp', DumpDWORD(PE.FileTimeDateStamp));
  D(mmoFile, 'FilePointerToSymbolTable', DumpDWORD(PE.FilePointerToSymbolTable));
  D(mmoFile, 'FileNumberOfSymbols', DumpDWORD(PE.FileNumberOfSymbols));
  D(mmoFile, 'FileSizeOfOptionalHeader', DumpWord(PE.FileSizeOfOptionalHeader));
  D(mmoFile, 'FileCharacteristics', DumpWord(PE.FileCharacteristics));

  D(mmoOptional, 'OptionalMagic', DumpWord(PE.OptionalMagic));
  D(mmoOptional, 'OptionalMajorLinkerVersion', DumpByte(PE.OptionalMajorLinkerVersion));
  D(mmoOptional, 'OptionalMinorLinkerVersion', DumpByte(PE.OptionalMinorLinkerVersion));
  D(mmoOptional, 'OptionalSizeOfCode', DumpDWORD(PE.OptionalSizeOfCode));
  D(mmoOptional, 'OptionalSizeOfInitializedData', DumpDWORD(PE.OptionalSizeOfInitializedData));
  D(mmoOptional, 'OptionalSizeOfUninitializedData', DumpDWORD(PE.OptionalSizeOfUninitializedData));
  D(mmoOptional, 'OptionalAddressOfEntryPoint', DumpDWORD(PE.OptionalAddressOfEntryPoint));
  D(mmoOptional, 'OptionalBaseOfCode', DumpDWORD(PE.OptionalBaseOfCode));
  D(mmoOptional, 'OptionalBaseOfData', DumpDWORD(PE.OptionalBaseOfData));

  if PE.IsWin32 then
    D(mmoOptional, 'OptionalImageBase', DumpDWORD(PE.OptionalImageBase));
  if PE.IsWin64 then
    D(mmoOptional, 'OptionalImageBase64', DumpTUInt64(PE.OptionalImageBase64));

  D(mmoOptional, 'OptionalSectionAlignment', DumpDWORD(PE.OptionalSectionAlignment));
  D(mmoOptional, 'OptionalFileAlignment', DumpDWORD(PE.OptionalFileAlignment));
  D(mmoOptional, 'OptionalMajorOperatingSystemVersion', DumpWord(PE.OptionalMajorOperatingSystemVersion));
  D(mmoOptional, 'OptionalMinorOperatingSystemVersion', DumpWord(PE.OptionalMinorOperatingSystemVersion));
  D(mmoOptional, 'OptionalMajorImageVersion', DumpWord(PE.OptionalMajorImageVersion));
  D(mmoOptional, 'OptionalMinorImageVersion', DumpWord(PE.OptionalMinorImageVersion));
  D(mmoOptional, 'OptionalMajorSubsystemVersion', DumpWord(PE.OptionalMajorSubsystemVersion));
  D(mmoOptional, 'OptionalMinorSubsystemVersion', DumpWord(PE.OptionalMinorSubsystemVersion));
  D(mmoOptional, 'OptionalWin32VersionValue', DumpDWORD(PE.OptionalWin32VersionValue));
  D(mmoOptional, 'OptionalSizeOfImage', DumpDWORD(PE.OptionalSizeOfImage));
  D(mmoOptional, 'OptionalSizeOfHeaders', DumpDWORD(PE.OptionalSizeOfHeaders));
  D(mmoOptional, 'OptionalCheckSum', DumpDWORD(PE.OptionalCheckSum));
  D(mmoOptional, 'OptionalSubsystem', DumpWord(PE.OptionalSubsystem));
  D(mmoOptional, 'OptionalDllCharacteristics', DumpWord(PE.OptionalDllCharacteristics));

  if PE.IsWin32 then
    D(mmoOptional, 'OptionalSizeOfStackReserve', DumpDWORD(PE.OptionalSizeOfStackReserve));
  if PE.IsWin64 then
    D(mmoOptional, 'OptionalSizeOfStackReserve64', DumpTUInt64(PE.OptionalSizeOfStackReserve64));
  if PE.IsWin32 then
    D(mmoOptional, 'OptionalSizeOfStackCommit', DumpDWORD(PE.OptionalSizeOfStackCommit));
  if PE.IsWin64 then
    D(mmoOptional, 'OptionalSizeOfStackCommit64', DumpTUInt64(PE.OptionalSizeOfStackCommit64));
  if PE.IsWin32 then
    D(mmoOptional, 'OptionalSizeOfHeapReserve', DumpDWORD(PE.OptionalSizeOfHeapReserve));
  if PE.IsWin64 then
    D(mmoOptional, 'OptionalSizeOfHeapReserve64', DumpTUInt64(PE.OptionalSizeOfHeapReserve64));
  if PE.IsWin32 then
    D(mmoOptional, 'OptionalSizeOfHeapCommit', DumpDWORD(PE.OptionalSizeOfHeapCommit));
  if PE.IsWin64 then
    D(mmoOptional, 'OptionalSizeOfHeapCommit64', DumpTUInt64(PE.OptionalSizeOfHeapCommit64));
  D(mmoOptional, 'OptionalLoaderFlags', DumpDWORD(PE.OptionalLoaderFlags));
  D(mmoOptional, 'OptionalNumberOfRvaAndSizes', DumpDWORD(PE.OptionalNumberOfRvaAndSizes));

  // Dump ��������
  D(mmoFile, '----', '----');
  D(mmoFile, 'IsWin32', DumpBoolean(PE.IsWin32));
  D(mmoFile, 'IsWin64', DumpBoolean(PE.IsWin64));
  D(mmoFile, 'IsExe', DumpBoolean(PE.IsExe));
  D(mmoFile, 'IsDll', DumpBoolean(PE.IsDll));
  D(mmoFile, 'IsDebug', DumpBoolean(PE.IsDebug));

  D(mmoOptional, '----', '----');
  for I := 0 to PE.DataDirectoryCount - 1 do
  begin
    D(mmoOptional, Format('DataDirectory %d VirtualAddress', [I]), DumpDWord(PE.DataDirectoryVirtualAddress[I]));
    D(mmoOptional, Format('DataDirectory %d Size', [I]), DumpDWord(PE.DataDirectorySize[I]));
  end;

  D(mmoOptional, '----', '----');
  D(mmoOptional, '----', 'Export Functions');
  D(mmoOptional, 'Base', DumpDWord(PE.ExportBase));
  D(mmoOptional, 'Names Count', DumpDWord(PE.ExportNumberOfNames));
  D(mmoOptional, 'Functions Count', DumpDWord(PE.ExportNumberOfFunctions));

  // �������
  for I := 0 to PE.ExportNumberOfFunctions - 1 do
  begin
    E := PE.ExportFunctionItem[I];
    if E <> nil then
      D(mmoOptional, Format('  Function %d %s: %s', [E.Ordinal, E.Name, DumpPointer(E.Address)]), '');
  end;

  // ������Ϣ
  D(mmoOptional, '----', '----');
  D(mmoOptional, '----', 'Debug Information');
  D(mmoOptional, 'Type', DumpDWord(PE.DebugType));
  D(mmoOptional, 'SizeOfData', DumpDWord(PE.DebugSizeOfData));
  D(mmoOptional, 'AddressOfRawData', DumpDWord(PE.DebugAddressOfRawData));
  D(mmoOptional, 'PointerToRawData', DumpDWord(PE.DebugPointerToRawData));

  // ������
  for I := 0 to PE.SectionCount - 1 do
  begin
    D(mmoSection, Format('Section %d Address', [I]), DumpPointer(PE.SectionHeader[I]));
    D(mmoSection, '    Name', PE.SectionName[I]);
    D(mmoSection, '    VirtualSize', DumpDWord(PE.SectionVirtualSize[I]));
    D(mmoSection, '    VirtualAddress', DumpDWord(PE.SectionVirtualAddress[I]));
    D(mmoSection, '    SizeOfRawData', DumpDWord(PE.SectionSizeOfRawData[I]));
    D(mmoSection, '    PointerToRawData', DumpDWord(PE.SectionPointerToRawData[I]));
    D(mmoSection, '    PointerToRelocations', DumpDWord(PE.SectionPointerToRelocations[I]));
    D(mmoSection, '    PointerToLinenumbers', DumpDWord(PE.SectionPointerToLinenumbers[I]));
    D(mmoSection, '    NumberOfRelocations', DumpWord(PE.SectionNumberOfRelocations[I]));
    D(mmoSection, '    NumberOfLinenumbers', DumpWord(PE.SectionNumberOfLinenumbers[I]));
    D(mmoSection, '    Characteristics', DumpDWord(PE.SectionCharacteristics[I]));
  end;

  udSection.Max := PE.SectionCount - 1;
end;

procedure TFormPE.btnParsePEClick(Sender: TObject);
var
  H: HMODULE;
begin
  if cbbRunModule.ItemIndex < 0 then
    Exit;

  mmoDos.Clear;
  mmoFile.Clear;
  mmoOptional.Clear;
  mmoSection.Clear;

  H := HMODULE(cbbRunModule.Items.Objects[cbbRunModule.ItemIndex]);
  FreeAndNil(FPE);

  PE := TCnPE.Create(H);
  PE.Parse;

  PE.SortExports;
  DumpPE(PE);
end;

procedure TFormPE.btn0Click(Sender: TObject);
var
  P: Pointer;
  S: DWORD;
  Idx: Integer;
begin
  if PE = nil then
    Exit;

  // Data Directory ������
  if Sender is TToolButton then
    Idx := (Sender as TToolButton).Tag
  else
    Idx := 0;

  P := PE.DataDirectoryContent[Idx];
  S := PE.DataDirectorySize[Idx];

  CnShowHexData(P, S, Integer(P));
end;

procedure TFormPE.FormDestroy(Sender: TObject);
begin
  FPE.Free;
end;

procedure TFormPE.btnViewSectionClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := udSection.Position;
  CnShowHexData(PE.SectionContent[Idx], PE.SectionContentSize[Idx]);
end;

procedure TFormPE.btnStackTraceClick(Sender: TObject);
var
  I, LN, OL, OP: Integer;
  SL: TCnStackInfoList;
  ML: TCnInProcessModuleList;
  Info: TCnModuleDebugInfo;
  MN, UN, PN: string;
begin
  mmoStack.Lines.Clear;

  SL := nil;
  ML := nil;
  try
    SL := TCnCurrentStackInfoList.Create;
    ML := TCnInProcessModuleList.Create;

    for I := 0 to SL.Count - 1 do
    begin
      Info := ML.GetDebugInfoFromAddress(SL.Items[I].CallerAddr);
      if Info = nil then
      begin
        ML.CreateDebugInfoFromAddress(SL.Items[I].CallerAddr);
        Info := ML.GetDebugInfoFromAddress(SL.Items[I].CallerAddr);
      end;

      if Info.GetDebugInfoFromAddr(SL.Items[I].CallerAddr, MN, UN, PN, LN, OL, OP) then
        mmoStack.Lines.Add(Format('#%2.2d %p - Module: %s Unit: %s Procedure %s. Line %d, +%d +%x',
          [I, SL.Items[I].CallerAddr, MN, UN, PN, LN, OL, OP]))
      else
        mmoStack.Lines.Add(Format('#%2.2d %p', [I, SL.Items[I].CallerAddr]));
    end;
  finally
    ML.Free;
    SL.Free;
  end;
end;

procedure TFormPE.btnDebugInfoClick(Sender: TObject);
var
  L: Integer;
begin
  if FPE <> nil then
  begin
    if FPE.DebugContent <> nil then
    begin
      L := FPE.DebugSizeOfData;
      if L > 65536 then
        L := 65536;
      CnShowHexData(FPE.DebugContent, L, Integer(FPE.DebugContent));
    end;
  end;
end;

procedure TFormPE.btnTDNamesClick(Sender: TObject);
var
  I: Integer;
  H: HMODULE;
  TD32: TCnModuleDebugInfoTD;
begin
  H := GetModuleHandle(nil);
  mmoNames.Clear;
  if H <> 0 then
  begin
    TD32 := TCnModuleDebugInfoTD.Create(H);
    try
      if TD32.Init then
        for I := 0 to TD32.Names.Count - 1 do
          mmoNames.Lines.Add(TD32.Names[I]);
    finally
      TD32.Free;
    end;
  end;
end;

procedure TFormPE.btnTDSourceModulesClick(Sender: TObject);
var
  I, J: Integer;
  H: HMODULE;
  TD32: TCnModuleDebugInfoTD;
  SM: TCnTDSourceModule;
begin
  H := GetModuleHandle(nil);
  mmoNames.Clear;
  if H <> 0 then
  begin
    TD32 := TCnModuleDebugInfoTD.Create(H);
    try
      if TD32.Init then
      begin
        for I := 0 to TD32.SourceModuleNames.Count - 1 do
          mmoNames.Lines.Add(TD32.SourceModuleNames[I]);
        mmoNames.Lines.Add('--------');
        for I := 0 to TD32.SourceModuleCount - 1 do
        begin
          SM := TD32.SourceModules[I];
          for J := 0 to SM.SegmentCount - 1 do
            D(mmoNames, '', Format('%s: Seg %d from %s to %s', [SM.Name, J,
              DumpDWORD(SM.SegmentStart[J]), DumpDWORD(SM.SegmentEnd[J])]));
        end;
      end;
    finally
      TD32.Free;
    end;
  end;
end;

procedure TFormPE.btnTDProcClick(Sender: TObject);
var
  I: Integer;
  H: HMODULE;
  TD32: TCnModuleDebugInfoTD;
  PS: TCnTDProcedureSymbol;
begin
  H := GetModuleHandle(nil);
  mmoNames.Clear;
  if H <> 0 then
  begin
    TD32 := TCnModuleDebugInfoTD.Create(H);
    try
      if TD32.Init then
      begin
        for I := 0 to TD32.ProcedureNames.Count - 1 do
          mmoNames.Lines.Add(TD32.ProcedureNames[I]);
        mmoNames.Lines.Add('--------');
        for I := 0 to TD32.ProcedureCount - 1 do
        begin
          PS := TD32.Procedures[I];
          D(mmoNames, '', Format('%s: from %s to %s', [PS.Name,
            DumpDWORD(PS.Offset), DumpDWORD(PS.Offset + PS.Size)]));
        end;

        mmoNames.Lines.Add('--------');
        D(mmoNames, 'TFormPE.btnSourceModulesClick', DumpPointer(@TFormPE.btnTDSourceModulesClick));
      end;
    finally
      TD32.Free;
    end;
  end;
end;

procedure TFormPE.btnTDLineNumbersClick(Sender: TObject);
var
  I: Integer;
  H: HMODULE;
  TD32: TCnModuleDebugInfoTD;
begin
  H := GetModuleHandle(nil);
  mmoNames.Clear;
  if H <> 0 then
  begin
    TD32 := TCnModuleDebugInfoTD.Create(H);
    try
      if TD32.Init then
      begin
        for I := 0 to TD32.LineNumberCount - 1 do
        begin
          D(mmoNames, '', Format('Line %d: Offset %s', [TD32.LineNumbers[I],
            DumpDWORD(TD32.Offsets[I])]));
        end;
      end;
    finally
      TD32.Free;
    end;
  end;
end;

procedure TFormPE.btnLoadClick(Sender: TObject);
begin
  if FileExists(edtPEFile.Text) then
  begin
    LoadLibrary(PChar(edtPEFile.Text));
    LoadModuleList;
  end;
end;

procedure TFormPE.LoadModuleList;
var
  HP: array of THandle;
  I, L: Integer;
  Cnt: DWORD;
  F: array[0..MAX_PATH] of Char;
begin
  cbbRunModule.Items.Clear;

  // ��ȡ Module �б�
  if EnumProcessModules(GetCurrentProcess, nil, 0, Cnt) then
  begin
    if Cnt > 0 then
    begin
      L := Cnt div SizeOf(THandle);
      SetLength(HP, L);
      if EnumProcessModules(GetCurrentProcess, @HP[0], Cnt, Cnt) then
      begin
        for I := 0 to L - 1 do
        begin
          GetModuleFileName(HP[I], @F[0], MAX_PATH);
{$IFDEF CPUX64}
          cbbRunModule.Items.AddObject(Format('%16.16x', [HP[I]]) + ' - ' + F, Pointer(HP[I]));
{$ELSE}
          cbbRunModule.Items.AddObject(Format('%8.8x', [HP[I]]) + ' - ' + F, Pointer(HP[I]));
{$ENDIF}
        end;
      end;
      cbbRunModule.ItemIndex := 0;
    end;
  end;
end;

procedure TFormPE.btnMapSourceModulesClick(Sender: TObject);
var
  I, J: Integer;
  H: HMODULE;
  Map: TCnModuleDebugInfoMap;
  SM: TCnMapSourceModule;
begin
  H := GetModuleHandle(nil);
  mmoNames.Clear;
  if H <> 0 then
  begin
    Map := TCnModuleDebugInfoMap.Create(H);
    try
      if Map.Init then
      begin
        for I := 0 to Map.SourceModuleNames.Count - 1 do
          mmoNames.Lines.Add(Map.SourceModuleNames[I]);
        mmoNames.Lines.Add('--------');
        for I := 0 to Map.SourceModuleCount - 1 do
        begin
          SM := Map.SourceModules[I];
          for J := 0 to SM.SegmentCount - 1 do
            D(mmoNames, '', Format('%s: Seg %d from %s to %s', [SM.Name, J,
              DumpDWORD(SM.SegmentStart[J]), DumpDWORD(SM.SegmentEnd[J])]));
        end;
      end;
    finally
      Map.Free;
    end;
  end;
end;

procedure TFormPE.btnMapProcClick(Sender: TObject);
var
  I: Integer;
  H: HMODULE;
  Map: TCnModuleDebugInfoMap;
begin
  H := GetModuleHandle(nil);
  mmoNames.Clear;
  if H <> 0 then
  begin
    Map := TCnModuleDebugInfoMap.Create(H);
    try
      if Map.Init then
      begin
        for I := 0 to Map.ProcedureCount - 1 do
          mmoNames.Lines.Add(Map.ProcedureNames[I] + ' ' + DumpDWORD(Map.ProcedureAddress[I]));
      end;
    finally
      Map.Free;
    end;
  end;
end;

procedure TFormPE.btnMapLineNumbersClick(Sender: TObject);
var
  I, J: Integer;
  H: HMODULE;
  Map: TCnModuleDebugInfoMap;
  SM: TCnMapSourceModule;
begin
  H := GetModuleHandle(nil);
  mmoNames.Clear;
  if H <> 0 then
  begin
    Map := TCnModuleDebugInfoMap.Create(H);
    try
      if Map.Init then
      begin
        for I := 0 to Map.SourceModuleCount - 1 do
        begin
          SM := Map.SourceModules[I];

          mmoNames.Lines.Add('--------');
          mmoNames.Lines.Add(Format('%s(%s)', [SM.Name, SM.FileName]));

          for J := 0 to SM.LineNumberCount - 1 do
          begin
            D(mmoNames, '', Format('Line %d: Offset %s', [SM.LineNumbers[J],
              DumpDWORD(SM.Offsets[J])]));
          end;
        end;
      end;
    finally
      Map.Free;
    end;
  end;
end;

end.
