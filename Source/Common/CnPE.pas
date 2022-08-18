{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
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

unit CnPE;
{* |<PRE>
================================================================================
* �������ƣ�CnPack �����
* ��Ԫ���ƣ����� PE �ļ��Ĺ��ߵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org��
* ��    ע���õ�Ԫʵ���˲��� PE ��ʽ����
*           ����ļ���һ������λ��������ļ�ͷ��һ���ֽڵ�ƫ�Ƴ�Ϊ��Ե�ַ��RA��
*                 ���ؽ��ڴ��һ����������ڳ���ʼ����ƫ�Ƴ�Ϊ��������ַ��RVA��
*           PE �ļ��д󲿷�ƫ�ƶ��� RVA���ٲ��ֺͼ����޹ص�ʹ�� RA
*           PE �ļ��ĸ�ʽ���������£�
*           +------------------------------------------------------------------+
*           | IMAGE_DOS_HEADER  64 �ֽڡ�MZ��e_lfanew �� PE ͷ���ļ�ƫ��
*           +------------------------------------------------------------------+
*           | IMAGE_NT_HEADERS  -- Signature 4 �ֽ�
*           |                   -- IMAGE_FILE_HEADER 40 �ֽ�
*           |                      -- ���� x86/x64��Section ��������������ѡ��Ĵ�С
*           |                   -- IMAGE_OPTIONAL_HEADER 32/64 λ�� $E0/$F0 �ֽ�
*           |                      -- ������ַ����ڡ��汾�š��������Ŀ¼���
*           |                      -- ����Ŀ¼���е����������ܶ���������������Ϣ��
*           +------------------------------------------------------------------+
*           | IMAGE_SECTION_HEADER[] ���飬ÿ�� 40 �ֽ�
*           |                   -- �������֡�����ַ����С���ļ�ƫ�ơ�Section ���Ե�
*           +------------------------------------------------------------------+
*           | ��϶�������� RA �� RVA �Ĳ��죩
*           +------------------------------------------------------------------+
*           | ���� Section ����
*           +------------------------------------------------------------------+
*           | ���� Section ����
*           +------------------------------------------------------------------+
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�Win32/Win64
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�������ʽ
* �޸ļ�¼��2022.08.07
*               ������Ԫ,ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, Psapi, Contnrs, CnContainers, CnNative;

const
  CN_INVALID_LINENUMBER_OFFSET = -1;

type
  ECnPEException = class(Exception);

  TCnPEParseMode = (ppmInvalid, ppmFile, ppmMemoryModule);
  {* ���� PE ��ģʽ���Ƿ������ļ����ڴ�ģ�飨�Ѽ������ڴ沢�ض�λ���ģ�}

  TCnPEExportItem = packed record
  {* ����һ���������������֡��������ʵ��ַ}
    Name: string;
    Ordinal: DWORD;
    Address: Pointer;
  end;
  PCnPEExportItem = ^TCnPEExportItem;

  TCnPE = class
  {* ����һ�� PE �ļ����࣬���� 32 λ�� 64 λ PE �ļ�������ҲҪ 32 λ�� 64 λ������}
  private
    FMode: TCnPEParseMode;
    FPEFile: string;
    FModule: HMODULE;
    FFileHandle: THandle;
    FMapHandle: THandle;
    FBaseAddress: Pointer;
    // �ļ�ģʽʱ�Ǳ� Map ���ڴ�ĵ͵�ַ���ڴ�ģʽʱ�� HModule���� PE ����չ����Ļ���ַ

    FDosHeader: PImageDosHeader;
    FNtHeaders: PImageNtHeaders;
    FFileHeader: PImageFileHeader;
    FOptionalHeader: Pointer;
    // 32 λ PE �ļ�ʱָ�������� PImageOptionalHeader��64 λʱָ�������� PImageOptionalHeader64
    FSectionHeader: PImageSectionHeader; // ������ OptionalHeader ��

    FDirectoryExport: PImageExportDirectory; // ������Ľṹ
    FExportItems: array of TCnPEExportItem;  // ��������������ݣ��ⲿ������Ҫ����

    FDirectoryDebug: PImageDebugDirectory;   // ������Ϣ���Ľṹ

    FOptionalMajorLinkerVersion: Byte;
    FOptionalMinorLinkerVersion: Byte;
    FOptionalCheckSum: DWORD;
    FOptionalSizeOfInitializedData: DWORD;
    FOptionalSizeOfStackReserve: DWORD;
    FOptionalSizeOfUninitializedData: DWORD;
    FOptionalBaseOfData: DWORD;
    FOptionalSizeOfHeapReserve: DWORD;
    FOptionalLoaderFlags: DWORD;
    FFileTimeDateStamp: DWORD;
    FOptionalSizeOfStackCommit: DWORD;
    FOptionalImageBase: DWORD;
    FOptionalAddressOfEntryPoint: DWORD;
    FOptionalNumberOfRvaAndSizes: DWORD;
    FOptionalSizeOfImage: DWORD;
    FFileNumberOfSymbols: DWORD;
    FOptionalSectionAlignment: DWORD;
    FOptionalSizeOfHeaders: DWORD;
    FOptionalSizeOfCode: DWORD;
    FOptionalSizeOfHeapCommit: DWORD;
    FOptionalBaseOfCode: DWORD;
    FFilePointerToSymbolTable: DWORD;
    FOptionalWin32VersionValue: DWORD;
    FOptionalFileAlignment: DWORD;
    FDosLfanew: LongInt;
    FDosSs: Word;
    FOptionalMagic: Word;
    FDosCblp: Word;
    FDosCrlc: Word;
    FDosSp: Word;
    FFileCharacteristics: Word;
    FDosOeminfo: Word;
    FDosMinalloc: Word;
    FDosMaxalloc: Word;
    FDosLfarlc: Word;
    FOptionalMinorOperatingSystemVersion: Word;
    FOptionalMinorSubsystemVersion: Word;
    FDosCs: Word;
    FOptionalMajorImageVersion: Word;
    FOptionalSubsystem: Word;
    FOptionalDllCharacteristics: Word;
    FFileSizeOfOptionalHeader: Word;
    FOptionalMinorImageVersion: Word;
    FDosIp: Word;
    FOptionalMajorOperatingSystemVersion: Word;
    FDosOvno: Word;
    FFileNumberOfSections: Word;
    FDosMagic: Word;
    FDosCparhdr: Word;
    FDosOemid: Word;
    FDosCp: Word;
    FFileMachine: Word;
    FDosCsum: Word;
    FOptionalMajorSubsystemVersion: Word;
    FSignature: DWORD;
    FOptionalSizeOfHeapCommit64: TUInt64;
    FOptionalSizeOfStackCommit64: TUInt64;
    FOptionalSizeOfStackReserve64: TUInt64;
    FOptionalSizeOfHeapReserve64: TUInt64;
    FOptionalImageBase64: TUInt64;
    FExportName: AnsiString;
    FExportNumberOfNames: DWORD;
    FExportNumberOfFunctions: DWORD;
    FExportBase: DWORD;
    FDebugType: DWORD;
    FDebugPointerToRawData: DWORD;
    FDebugAddressOfRawData: DWORD;
    FDebugSizeOfData: DWORD;
    function GetDataDirectorySize(Index: Integer): DWORD;
    function GetDataDirectory(Index: Integer): PImageDataDirectory;
    function GetDataDirectoryVirtualAddress(Index: Integer): DWORD;
    function GetDataDirectoryContent(Index: Integer): Pointer;
    function GetSectionHeader(Index: Integer): PImageSectionHeader;
    function GetIsDll: Boolean;
    function GetIsExe: Boolean;
    function GetIsWin32: Boolean;
    function GetIsWin64: Boolean;
    function GetIsSys: Boolean;
    function GetDataDirectoryCount: Integer;
    function GetSectionCount: Integer;
    function GetSectionCharacteristics(Index: Integer): DWORD;
    function GetSectionContent(Index: Integer): Pointer;
    function GetSectionVirtualSize(Index: Integer): DWORD;
    function GetSectionName(Index: Integer): AnsiString;
    function GetSectionNumberOfLinenumbers(Index: Integer): Word;
    function GetSectionNumberOfRelocations(Index: Integer): Word;
    function GetSectionPointerToLinenumbers(Index: Integer): DWORD;
    function GetSectionPointerToRawData(Index: Integer): DWORD;
    function GetSectionPointerToRelocations(Index: Integer): DWORD;
    function GetSectionSizeOfRawData(Index: Integer): DWORD;
    function GetSectionVirtualAddress(Index: Integer): DWORD;
    function GetSectionContentSize(Index: Integer): DWORD;
    function GetExportFunctionItem(Index: Integer): PCnPEExportItem;
    function GetDebugContent: Pointer;
    function GetIsDebug: Boolean;

  protected
    function RvaToActual(Rva: DWORD): Pointer;
    {* RVA ת�����ڴ��е���ʵ��ַ������ֱ�ӷ���}
    function GetSectionHeaderFromRva(Rva: DWORD): PImageSectionHeader;
    {* ���� RVA �ҵ��������ĸ� Section ������� SectionHeader}

    procedure ParseHeaders;
    procedure ParseExports;
    procedure ParseDebugData;
  public
    constructor Create(const APEFileName: string); overload; virtual;
    constructor Create(AModuleHandle: HMODULE); overload; virtual;

    destructor Destroy; override;

    procedure Parse;
    {* ���� PE �ļ������óɹ������ʹ���ڲ�������}

    procedure SortExports;
    {* �ڲ������������ĵ�ַ��������}

    property Mode: TCnPEParseMode read FMode;
    {* PE ����ģʽ}

    // Dos ��ͷ�����Ա�ʾ�� DosHeader �е�
    property DosMagic: Word read FDosMagic;
    {* EXE��־���ַ� MZ}
    property DosCblp: Word read FDosCblp;
    {* ���һҳ�е��ֽ���}
    property DosCp: Word read FDosCp;
    {* �ļ��е�ҳ��}
    property DosCrlc: Word read FDosCrlc;
    {* �ض�λ���е�ָ����}
    property DosCparhdr: Word read FDosCparhdr;
    {* ͷ���ߴ磬�Զ�Ϊ��λ}
    property DosMinalloc: Word read FDosMinalloc;
    {* �������С���Ӷ�}
    property DosMaxalloc: Word read FDosMaxalloc;
    {* �������󸽼Ӷ�}
    property DosSs: Word read FDosSs;
    {* ��ʼ�� SS ֵ�����ƫ������}
    property DosSp: Word read FDosSp;
    {* ��ʼ�� SP ֵ�����ƫ������}
    property DosCsum: Word read FDosCsum;
    {* У���                         }
    property DosIp: Word read FDosIp;
    {* ��ʼ�� IP ֵ}
    property DosCs: Word read FDosCs;
    {* ��ʼ�� CS ֵ}
    property DosLfarlc: Word read FDosLfarlc;
    {* �ض�λ�����ֽ�ƫ����}
    property DosOvno: Word read FDosOvno;
    {* ���Ǻ�}
    // DosRes: array [0..3] of Word;    { Reserved words}
    property DosOemid: Word read FDosOemid;
    {* OEM ��ʶ��}
    property DosOeminfo: Word read FDosOeminfo;
    {* OEM ��Ϣ}
    // DosRes2: array [0..9] of Word;   { Reserved words}
    property DosLfanew: LongInt read FDosLfanew;
    {* PE ͷ������ļ���ƫ�Ƶ�ַ��Ҳ����ָ�� NtHeader}

    property Signature: DWORD read FSignature;
    {* PE �ļ���ʶ��PE00}

    // File ��ͷ�����Ա�ʾ�� NtHeader �е� FileHeader �е�
    property FileMachine: Word read FFileMachine;
    {* ����ƽ̨}
    property FileNumberOfSections: Word read FFileNumberOfSections;
    {* Section ������}
    property FileTimeDateStamp: DWORD read FFileTimeDateStamp;
    {* �ļ��������ں�ʱ��}
    property FilePointerToSymbolTable: DWORD read FFilePointerToSymbolTable;
    {* ָ����ű�}
    property FileNumberOfSymbols: DWORD read FFileNumberOfSymbols;
    {* ���ű��еķ�������}
    property FileSizeOfOptionalHeader: Word read FFileSizeOfOptionalHeader;
    {* OptionalHeader �ṹ�ĳ���}
    property FileCharacteristics: Word read FFileCharacteristics;
    {* �ļ�����}

    // Optional ��ͷ�����Ա�ʾ�� NtHeader �е� OptionalHeader �е�
    { Standard fields. }
    property OptionalMagic: Word read FOptionalMagic;
    property OptionalMajorLinkerVersion: Byte read FOptionalMajorLinkerVersion;
    property OptionalMinorLinkerVersion: Byte read FOptionalMinorLinkerVersion;
    property OptionalSizeOfCode: DWORD read FOptionalSizeOfCode;
    property OptionalSizeOfInitializedData: DWORD read FOptionalSizeOfInitializedData;
    property OptionalSizeOfUninitializedData: DWORD read FOptionalSizeOfUninitializedData;
    property OptionalAddressOfEntryPoint: DWORD read FOptionalAddressOfEntryPoint;
    property OptionalBaseOfCode: DWORD read FOptionalBaseOfCode;
    property OptionalBaseOfData: DWORD read FOptionalBaseOfData;
    { NT additional fields. }
    property OptionalImageBase: DWORD read FOptionalImageBase;
    property OptionalImageBase64: TUInt64 read FOptionalImageBase64;
    {* 64 λ���� UInt64}
    property OptionalSectionAlignment: DWORD read FOptionalSectionAlignment;
    property OptionalFileAlignment: DWORD read FOptionalFileAlignment;
    property OptionalMajorOperatingSystemVersion: Word read FOptionalMajorOperatingSystemVersion;
    property OptionalMinorOperatingSystemVersion: Word read FOptionalMinorOperatingSystemVersion;
    property OptionalMajorImageVersion: Word read FOptionalMajorImageVersion;
    property OptionalMinorImageVersion: Word read FOptionalMinorImageVersion;
    property OptionalMajorSubsystemVersion: Word read FOptionalMajorSubsystemVersion;
    property OptionalMinorSubsystemVersion: Word read FOptionalMinorSubsystemVersion;
    property OptionalWin32VersionValue: DWORD read FOptionalWin32VersionValue;
    property OptionalSizeOfImage: DWORD read FOptionalSizeOfImage;
    property OptionalSizeOfHeaders: DWORD read FOptionalSizeOfHeaders;
    property OptionalCheckSum: DWORD read FOptionalCheckSum;
    property OptionalSubsystem: Word read FOptionalSubsystem;
    property OptionalDllCharacteristics: Word read FOptionalDllCharacteristics;
    property OptionalSizeOfStackReserve: DWORD read FOptionalSizeOfStackReserve;
    property OptionalSizeOfStackReserve64: TUInt64 read FOptionalSizeOfStackReserve64;
    {* 64 λ���� UInt64}
    property OptionalSizeOfStackCommit: DWORD read FOptionalSizeOfStackCommit;
    property OptionalSizeOfStackCommit64: TUInt64 read FOptionalSizeOfStackCommit64;
    {* 64 λ���� UInt64}
    property OptionalSizeOfHeapReserve: DWORD read FOptionalSizeOfHeapReserve;
    property OptionalSizeOfHeapReserve64: TUInt64 read FOptionalSizeOfHeapReserve64;
    {* 64 λ���� UInt64}
    property OptionalSizeOfHeapCommit: DWORD read FOptionalSizeOfHeapCommit;
    property OptionalSizeOfHeapCommit64: TUInt64 read FOptionalSizeOfHeapCommit64;
    {* 64 λ���� UInt64}
    property OptionalLoaderFlags: DWORD read FOptionalLoaderFlags;
    property OptionalNumberOfRvaAndSizes: DWORD read FOptionalNumberOfRvaAndSizes;
    {* DataDirectory �� Size��һ��Ϊ 16}

    // �������� DataDirectory ��Ϣ��ע������ֻ�� Directory������ָ���ʵ������
    property DataDirectoryCount: Integer read GetDataDirectoryCount;
    {* DataDirectory ���������ڲ��� NumberOfRvaAndSizes}
    property DataDirectory[Index: Integer]: PImageDataDirectory read GetDataDirectory;
    {* �� Index �� DataDirectory ��ָ�룬0 �� 15��ʼ�ն�����}
    property DataDirectoryContent[Index: Integer]: Pointer read GetDataDirectoryContent;
    {* �� Index �� DataDirectory ��ʵ�ʵ�ַ��ͨ���˵�ַ����ֱ�ӷ���������}

    property DataDirectoryVirtualAddress[Index: Integer]: DWORD read GetDataDirectoryVirtualAddress;
    {* �� Index �� DataDirectory ��ƫ�Ƶ�ַ}
    property DataDirectorySize[Index: Integer]: DWORD read GetDataDirectorySize;
    {* �� Index �� DataDirectory �ĳߴ磬��λ�ֽڣ��ƺ����ڹ̶�������˵����Ҫ}

    // Sections ��Ϣ������ PE ������Ӧ�ý� Section �������ļ�ƫ�� PointerToRawData ��������ӳ�����ڴ�� VritualAddress ��
    property SectionCount: Integer read GetSectionCount;
    {* Section ���������ڲ��� NumberOfSections}
    property SectionHeader[Index: Integer]: PImageSectionHeader read GetSectionHeader;
    {* �� Index �� SectionHeader ��ָ�룬0 ��ʼ}
    property SectionContent[Index: Integer]: Pointer read GetSectionContent;
    {* �� Index �� Section ��ʵ�ʵ�ַ��ͨ���˵�ַ����ֱ�ӷ��������ݣ��ڲ�Ҫ�����ļ�ģʽ�����ڴ����ģʽ}
    property SectionContentSize[Index: Integer]: DWORD read GetSectionContentSize;
    {* �� Index �� Section ��ʵ�ʴ�С��ȡ VirtualSize �� SizeOfRawData �еĽ�С��}

    property SectionName[Index: Integer]: AnsiString read GetSectionName;
    {* �� Index �� Section ������}
    property SectionVirtualSize[Index: Integer]: DWORD read GetSectionVirtualSize;
    {* �� Index �� Section �� Misc �����ֶε����ݣ�һ���� VirtualSize��
      ָ���ؽ��ڴ���ʵ�ʴ�С}
    property SectionVirtualAddress[Index: Integer]: DWORD read GetSectionVirtualAddress;
    {* �� Index �� Section �� RVA ƫ�ƣ�Ҳ���� PE ���ؽ��ڴ��ý���Ի�ַ��ƫ�ƣ�RVA��}
    property SectionSizeOfRawData[Index: Integer]: DWORD read GetSectionSizeOfRawData;
    {* �� Index �� Section ���ļ��е�ԭʼ�ߴ磬һ�㱻����������ܱ� VirtualSize ����}
    property SectionPointerToRawData[Index: Integer]: DWORD read GetSectionPointerToRawData;
    {* �� Index �� Section ���ļ��е�ƫ������RA��}
    property SectionPointerToRelocations[Index: Integer]: DWORD read GetSectionPointerToRelocations;
    {* �� Index �� Section �� PointerToRelocations}
    property SectionPointerToLinenumbers[Index: Integer]: DWORD read GetSectionPointerToLinenumbers;
    {* �� Index �� Section �� PointerToLinenumbers}
    property SectionNumberOfRelocations[Index: Integer]: Word read GetSectionNumberOfRelocations;
    {* �� Index �� Section �� NumberOfRelocations}
    property SectionNumberOfLinenumbers[Index: Integer]: Word read GetSectionNumberOfLinenumbers;
    {* �� Index �� Section �� NumberOfLinenumbers}
    property SectionCharacteristics[Index: Integer]: DWORD read GetSectionCharacteristics;
    {* �� Index �� Section �� Characteristics}

    // ������ϸ��һЩ�ض����� 32 ���� 64�����ԡ���������������������Ϣ��
    property IsWin32: Boolean read GetIsWin32;
    {* �� PE �ļ��Ƿ� Win32 ��ʽ}
    property IsWin64: Boolean read GetIsWin64;
    {* �� PE �ļ��Ƿ� Win64 ��ʽ}
    property IsExe: Boolean read GetIsExe;
    {* �� PE �ļ��Ƿ�Ϊ�������е� EXE}
    property IsDll: Boolean read GetIsDll;
    {* �� PE �ļ��Ƿ� DLL}
    property IsSys: Boolean read GetIsSys;
    {* �� PE �ļ��Ƿ� SYS �ļ�}
    property IsDebug: Boolean read GetIsDebug;
    {* �� PE �ļ��Ƿ����������Ϣ}

    // �������Ϣ
    property ExportName: AnsiString read FExportName;
    {* ��������ƣ�һ���� DLL �ļ���}
    property ExportBase: DWORD read FExportBase;
    {* ������ĺ��������ʼֵ}
    property ExportNumberOfFunctions: DWORD read FExportNumberOfFunctions;
    {* ����ĺ������������������ֵĺ�û���ֵ�}
    property ExportNumberOfNames: DWORD read FExportNumberOfNames;
    {* �������ַ�ʽ����ĺ�������}
    property ExportFunctionItem[Index: Integer]: PCnPEExportItem read GetExportFunctionItem;
    {* ��ȡ�� Index ����������ļ�¼ָ�룬Index �� 0 �� FExportNumberOfFunctions - 1��ע�� Index ������ Ordinal}

    // ������Ϣ
    property DebugType: DWORD read FDebugType;
    {* ������Ϣ����}
    property DebugSizeOfData: DWORD read FDebugSizeOfData;
    {* �������ݴ�С}
    property DebugAddressOfRawData: DWORD read FDebugAddressOfRawData;
    {* �����������ڴ��е� RVA}
    property DebugPointerToRawData: DWORD read FDebugPointerToRawData;
    {* �����������ļ��е�ƫ��}
    property DebugContent: Pointer read GetDebugContent;
    {* �������ݵ���ʵָ�룬����ȥֱ�ӽ������ߴ�Ϊ DebugSizeOfData}
  end;

  TCnModuleDebugInfo = class
  {* ������������һģ��ĵ�����Ϣ�Ļ��࣬Ĭ��ʵ�ָ��������׷�ٵĹ���}
  private
    FModuleFile: string;
    FModuleHandle: HMODULE;
  protected
    FPE: TCnPE;
  public
    constructor Create(AModuleHandle: HMODULE); virtual;
    destructor Destroy; override;

    function Init: Boolean; virtual;
    {* ��ʼ�������������������Դ������ָ�ʽ�ĵ�����Ϣ�� map/tds/td32/DebugInfo �ڵ�}

    function GetDebugInfoFromAddr(Address: Pointer; out OutModuleFile, OutUnitName, OutProcName: string;
      out OutLineNumber, OutOffsetLineNumber, OutOffsetProc: Integer): Boolean; virtual;
    {* �ӵ�ǰ�����ڵ������ַ������ģ���ļ�����������·��������Ԫ��������еĻ�������ǰ��������
      ��ǰ�кš����кŵ��ֽ�λ�á��뵱ǰ������ʼ���ֽ�λ��}

    function VAFromAddr(Address: Pointer): DWORD;
    {* ������ʵ��ַ����ģ����ƫ�ƣ���ʵ�Ǽ�ȥģ�����ַ�ټ�ȥ�������ַ}

    property ModuleHandle: HMODULE read FModuleHandle;
    {* ��ǰģ��� Handle}
    property ModuleFile: string read FModuleFile;
    {* �����ļ�������·��}
  end;

  TCnTDSourceModule = class
  {* ����һ TD ������Ϣ��Դ�ļ�����}
  private
    FSegmentCount: Integer;
    FName: string;
    FSegmentArray: PDWORD;  // ָ��һ�� Start/End ��˫ DWORD ����
    FNameIndex: Integer;
    function GetSegmentEnd(Index: Integer): DWORD;
    function GetSegmentStart(Index: Integer): DWORD;
  public
    function IsAddressInSource(Address: DWORD): Boolean;
    {* ����һ����ַ�Ƿ��ڱ�ģ����}

    property NameIndex: Integer read FNameIndex write FNameIndex;
    property Name: string read FName write FName;
    property SegmentCount: Integer read FSegmentCount write FSegmentCount;

    property SegmentArray: PDWORD read FSegmentArray write FSegmentArray;
    property SegmentStart[Index: Integer]: DWORD read GetSegmentStart;
    property SegmentEnd[Index: Integer]: DWORD read GetSegmentEnd;
  end;

  TCnTDProcedureSymbol = class
  {* ����һ TD ������Ϣ�к�������̵���}
  private
    FNameIndex: DWORD;
    FOffset: DWORD;
    FSize: DWORD;
    FName: string;
  public
    function IsAddressInProcedure(Address: DWORD): Boolean;
    {* ����һ����ַ�Ƿ��ڱ�������}

    property Name: string read FName write FName;
    property NameIndex: DWORD read FNameIndex write FNameIndex;
    property Offset: DWORD read FOffset write FOffset;
    property Size: DWORD read FSize write FSize;
  end;

  TCnModuleDebugInfoTD32 = class(TCnModuleDebugInfo)
  {* ���� TD32 Debugger Info �ĵ�����Ϣ�࣬ע��ֻ�������ֶ�ջ��������}
  private
    FData: Pointer;
    FSize: DWORD;
    FStream: TMemoryStream;
    FNames: TStringList;
    FSourceModuleNames: TStringList;
    FProcedureNames: TStringList;
    FOffsets: TCnIntegerList;
    FLineNumbers: TCnIntegerList;
    procedure SyncNames; // �� NameIndex ת��Ϊ Name
    procedure ParseSubSection(DSE: Pointer);
    function GetSourceModules(Index: Integer): TCnTDSourceModule;
    function GetSourceModuleCount: Integer;
    function GetProcedureCount: Integer;
    function GetProcedures(Index: Integer): TCnTDProcedureSymbol;
    function GetLineNumberCount: Integer;
    function GetOffsetCount: Integer;
    function GetLineNumbers(Index: Integer): Integer;
    function GetOffsets(Index: Integer): Integer;
  public
    constructor Create(AModuleHandle: HMODULE); override;
    destructor Destroy; override;

    function Init: Boolean; override;

    function GetDebugInfoFromAddr(Address: Pointer; out OutModuleFile, OutUnitName, OutProcName: string;
      out OutLineNumber, OutOffsetLineNumber, OutOffsetProc: Integer): Boolean; override;

    property Names: TStringList read FNames;
    {* �ڲ��������б�}

    property SourceModuleNames: TStringList read FSourceModuleNames;
    {* �ڲ���Դ�ļ����б�}
    property SourceModuleCount: Integer read GetSourceModuleCount;
    {* �ڲ���Դ�ļ���������}
    property SourceModules[Index: Integer]: TCnTDSourceModule read GetSourceModules;
    {* �ڲ���Դ�ļ������б�}

    property ProcedureNames: TStringList read FProcedureNames;
    {* �ڲ��ĺ����������б�}
    property ProcedureCount: Integer read GetProcedureCount;
    {* �ڲ��ĺ������̶�������}
    property Procedures[Index: Integer]: TCnTDProcedureSymbol read GetProcedures;
    {* �ڲ��ĺ������̶����б�}

    property LineNumberCount: Integer read GetLineNumberCount;
    {* �к�����}
    property LineNumbers[Index: Integer]: Integer read GetLineNumbers;
    {* �к�}
    property OffsetCount: Integer read GetOffsetCount;
    {* ƫ��������}
    property Offsets[Index: Integer]: Integer read GetOffsets;
    {* ƫ������ԭʼ�����Ѵӵ͵�������õ�}
  end;

  TCnInProcessModuleList = class(TObjectList)
  {* ����������������ģ��ĵ�����Ϣ�б��࣬�ڲ����� TCnModuleDebugInfo ��������}
  private
    function GetItem(Index: Integer): TCnModuleDebugInfo;
    procedure SetItem(Index: Integer; const Value: TCnModuleDebugInfo);

  protected
    function CreateDebugInfoFromModule(AModuleHandle: HMODULE): TCnModuleDebugInfo;
    {* ��ĳģ����������������ĵ�����Ϣ����}
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;

    function GetDebugInfoFromAddress(Address: Pointer): TCnModuleDebugInfo;
    {* ��ĳ��ַ���ظ�ģ��ĵ�����Ϣ}
    function GetDebugInfoFromModule(AModuleHandle: HMODULE): TCnModuleDebugInfo;
    {* ��ĳģ�������ظ�ģ��ĵ�����Ϣ}

    function CreateDebugInfoFromAddress(Address: Pointer): TCnModuleDebugInfo;
    {* ��ĳ��ַ������������ĵ�����Ϣ�������ӵ��б��У�����Ѵ������ظ��������Է���}

    property Items[Index: Integer]: TCnModuleDebugInfo read GetItem write SetItem; default;
    {* �������ڵĵ�����Ϣ�б�}
  end;

function CreateInProcessAllModulesList: TCnInProcessModuleList;
{* ������ǰ����������ģ��� TCnInProcessModuleList�������������ͷ�}

implementation

resourcestring
  SCnPEOpenErrorFmt = 'Can NOT Open File ''%s''';
  SCnPEFormatError = 'NOT a Valid PE File';
  SCnPEDataDirectoryIndexErrorFmt = 'Data Directory Out Of Index %d';
  SCnPESectionIndexErrorFmt = 'Section Out Of Index %d';
  SCnPEExportIndexErrorFmt = 'Export Item Out Of Index %d';

const
  IMAGE_FILE_MACHINE_IA64                  = $0200;  { Intel 64 }
  IMAGE_FILE_MACHINE_AMD64                 = $8664;  { AMD64 (K8) }

  IMAGE_NT_OPTIONAL_HDR32_MAGIC            = $010B;
  IMAGE_NT_OPTIONAL_HDR64_MAGIC            = $020B;

  { Turbo Debugger ������Ϣͷ���}
  TD_SIGNATURE_DELPHI = $39304246; // 'FB09'
  TD_SIGNATURE_BCB    = $41304246; // 'FB0A'

  { Turbo Debugger ������Ϣ Entry �е� Subsection Types}
  TD_SUBSECTION_TYPE_MODULE         = $120;
  TD_SUBSECTION_TYPE_TYPES          = $121;
  TD_SUBSECTION_TYPE_SYMBOLS        = $124;
  TD_SUBSECTION_TYPE_ALIGN_SYMBOLS  = $125;
  TD_SUBSECTION_TYPE_SOURCE_MODULE  = $127;
  TD_SUBSECTION_TYPE_GLOBAL_SYMBOLS = $129;
  TD_SUBSECTION_TYPE_GLOBAL_TYPES   = $12B;
  TD_SUBSECTION_TYPE_NAMES          = $130;

  { Turbo Debugger ������Ϣ �е� Symbol type defines}
  SYMBOL_TYPE_COMPILE        = $0001; // Compile flags symbol
  SYMBOL_TYPE_REGISTER       = $0002; // Register variable
  SYMBOL_TYPE_CONST          = $0003; // Constant symbol
  SYMBOL_TYPE_UDT            = $0004; // User-defined Type
  SYMBOL_TYPE_SSEARCH        = $0005; // Start search
  SYMBOL_TYPE_END            = $0006; // End block, procedure, with, or thunk
  SYMBOL_TYPE_SKIP           = $0007; // Skip - Reserve symbol space
  SYMBOL_TYPE_CVRESERVE      = $0008; // Reserved for Code View internal use
  SYMBOL_TYPE_OBJNAME        = $0009; // Specify name of object file

  SYMBOL_TYPE_BPREL16        = $0100; // BP relative 16:16
  SYMBOL_TYPE_LDATA16        = $0101; // Local data 16:16
  SYMBOL_TYPE_GDATA16        = $0102; // Global data 16:16
  SYMBOL_TYPE_PUB16          = $0103; // Public symbol 16:16
  SYMBOL_TYPE_LPROC16        = $0104; // Local procedure start 16:16
  SYMBOL_TYPE_GPROC16        = $0105; // Global procedure start 16:16
  SYMBOL_TYPE_THUNK16        = $0106; // Thunk start 16:16
  SYMBOL_TYPE_BLOCK16        = $0107; // Block start 16:16
  SYMBOL_TYPE_WITH16         = $0108; // With start 16:16
  SYMBOL_TYPE_LABEL16        = $0109; // Code label 16:16
  SYMBOL_TYPE_CEXMODEL16     = $010A; // Change execution model 16:16
  SYMBOL_TYPE_VFTPATH16      = $010B; // Virtual function table path descriptor 16:16

  SYMBOL_TYPE_BPREL32        = $0200; // BP relative 16:32
  SYMBOL_TYPE_LDATA32        = $0201; // Local data 16:32
  SYMBOL_TYPE_GDATA32        = $0202; // Global data 16:32
  SYMBOL_TYPE_PUB32          = $0203; // Public symbol 16:32
  SYMBOL_TYPE_LPROC32        = $0204; // Local procedure start 16:32
  SYMBOL_TYPE_GPROC32        = $0205; // Global procedure start 16:32
  SYMBOL_TYPE_THUNK32        = $0206; // Thunk start 16:32
  SYMBOL_TYPE_BLOCK32        = $0207; // Block start 16:32
  SYMBOL_TYPE_WITH32         = $0208; // With start 16:32
  SYMBOL_TYPE_LABEL32        = $0209; // Label 16:32
  SYMBOL_TYPE_CEXMODEL32     = $020A; // Change execution model 16:32
  SYMBOL_TYPE_VFTPATH32      = $020B; // Virtual function table path descriptor 16:32

type
{$IFDEF SUPPORT_32_AND_64}
  PImageOptionalHeader = PImageOptionalHeader32;
{$ELSE}
  TImageOptionalHeader32 = TImageOptionalHeader;
{$ENDIF}

  TImageOptionalHeader64 = record
    { Standard fields. }
    Magic: Word;
    MajorLinkerVersion: Byte;
    MinorLinkerVersion: Byte;
    SizeOfCode: DWORD;
    SizeOfInitializedData: DWORD;
    SizeOfUninitializedData: DWORD;
    AddressOfEntryPoint: DWORD;
    BaseOfCode: DWORD;
    { NT additional fields. }
    ImageBase: TUInt64;
    SectionAlignment: DWORD;
    FileAlignment: DWORD;
    MajorOperatingSystemVersion: Word;
    MinorOperatingSystemVersion: Word;
    MajorImageVersion: Word;
    MinorImageVersion: Word;
    MajorSubsystemVersion: Word;
    MinorSubsystemVersion: Word;
    Win32VersionValue: DWORD;
    SizeOfImage: DWORD;
    SizeOfHeaders: DWORD;
    CheckSum: DWORD;
    Subsystem: Word;
    DllCharacteristics: Word;
    SizeOfStackReserve: TUInt64;
    SizeOfStackCommit: TUInt64;
    SizeOfHeapReserve: TUInt64;
    SizeOfHeapCommit: TUInt64;
    LoaderFlags: DWORD;
    NumberOfRvaAndSizes: DWORD;
    DataDirectory: packed array[0..IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1] of TImageDataDirectory;
  end;
  PImageOptionalHeader64 = ^TImageOptionalHeader64;

// ==================== Turbo Debugger ������Ϣ��ؽṹ���� ====================

  TTDFileSignature = packed record
  { TD ������Ϣ��ͷ���Ľṹ}
    Signature: DWORD;
    Offset: DWORD;        // ָ�� TTDDirectoryHeader�����ĵ�����Ϣͷ������Ž� Section
  end;
  PTDFileSignature = ^TTDFileSignature;

  TTDDirectoryEntry = packed record
  {* TD ������Ϣ��Ԫ�أ�����һ����������Ϣͷ�ĺ�����}
    SubsectionType: Word; // SubSection ���ͣ���Ӧ TD_SUBSECTION_TYPE_* ����
    ModuleIndex: Word;    // Module index
    Offset: DWORD;        // Offset from the base offset lfoBase��ָ�����ĵ�����Ϣ SubSection
    Size: DWORD;          // Number of bytes in subsection
  end;
  PTDDirectoryEntry = ^TTDDirectoryEntry;

  TTDDirectoryHeader = packed record
  {* ÿ��� TD ������Ϣ�� Section ��ͷ����������� DirEntryCount �� TTDDirectoryEntry��
    ÿ����С DirEntrySize��Ҳ���� SizeOf(TTDDirectoryEntry)
    Ȼ�� lfoNextDir ָ����һ��������Ϣ Section ��ͷ}
    Size: Word;           // Length of this structure
    DirEntrySize: Word;   // Length of each directory entry
    DirEntryCount: DWORD; // Number of directory entries
    lfoNextDir: DWORD;    // Offset from lfoBase of next directory.
    Flags: DWORD;         // Flags describing directory and subsection tables.
    DirEntries: array [0..0] of TTDDirectoryEntry;
  end;
  PTDDirectoryHeader = ^TTDDirectoryHeader;

  TSymbolProcInfo = packed record
  {* TD ������Ϣ�� Subsection �еĹ������͵ķ�����ṹ}
    pParent: DWORD;
    pEnd: DWORD;
    pNext: DWORD;
    Size: DWORD;        // Length in bytes of this procedure
    DebugStart: DWORD;  // Offset in bytes from the start of the procedure to
                        // the point where the stack frame has been set up.
    DebugEnd: DWORD;    // Offset in bytes from the start of the procedure to
                        // the point where the  procedure is  ready to  return
                        // and has calculated its return value, if any.
                        // Frame and register variables an still be viewed.
    Offset: DWORD;      // Offset portion of  the segmented address of
                        // the start of the procedure in the code segment
    Segment: Word;      // Segment portion of the segmented address of
                        // the start of the procedure in the code segment
    ProcType: DWORD;    // Type of the procedure type record
    NearFar: Byte;      // Type of return the procedure makes:
                        //   0       near
                        //   4       far
    Reserved: Byte;
    NameIndex: DWORD;   // Name index of procedure
  end;

  TTDSymbolInfo = packed record
  {* TD ������Ϣ�� Subsection �еķ��ű��ṹ}
    Size: Word;
    SymbolType: Word;
    case Word of
      SYMBOL_TYPE_LPROC32, SYMBOL_TYPE_GPROC32:
        (Proc: TSymbolProcInfo);
      // ����Ĳ������������ʹ��
  end;
  PTDSymbolInfo = ^TTDSymbolInfo;

  TTDSymbolInfos = packed record
  {* TD ������Ϣ�� Subsection �еķ��ű��ṹ�б�}
    Signature: DWORD;
    Symbols: array [0..0] of TTDSymbolInfo;
  end;
  PTDSymbolInfos = ^TTDSymbolInfos;

  TTDSourceModuleInfo = packed record
  {* TD ������Ϣ�� Subsection �е�Դ���ļ�ͷ�ṹ}
    FileCount: Word;    // The number of source file scontributing code to segments
    SegmentCount: Word; // The number of code segments receiving code from this module

    BaseSrcFiles: array [0..0] of DWORD;
  end;
  PTDSourceModuleInfo = ^TTDSourceModuleInfo;

  TTDSourceFileEntry = packed record
  {* TD ������Ϣ�� Subsection �еĵ���Դ���ļ��ṹ}
    SegmentCount: Word; // Number of segments that receive code from this source file.
    NameIndex: DWORD;   // Name index of Source file name.
    BaseSrcLines: array [0..0] of DWORD; // ������ SegmentCount ����0 �� SegmentCount - 1
    // BaseSrcLines[SegmentCount] �� TTDOffsetPair �����飬ָʾ��ǰ�ļ��Ĵ�����ÿ�� Segment �е�ƫ��ͷβ
  end;
  PTDSourceFileEntry = ^TTDSourceFileEntry;

  TTDOffsetPair = packed record
  {* TD ������Ϣ�еĴ������ʼ��ַ}
    StartOffset: DWORD;
    EndOffset: DWORD;
  end;
  PTDOffsetPairArray = ^TTDOffsetPairArray;
  TTDOffsetPairArray = array [0..32767] of TTDOffsetPair;

  TTDLineMappingEntry = packed record
  {* TD ������Ϣ�е��к���ƫ������Ӧ��ϵ}
    SegmentIndex: Word;  // Segment index for this table
    PairCount: Word;     // Count of the number of source line pairs to follow
    Offsets: array [0..0] of DWORD; // PairCount �� DWORD ��ʾƫ��
    // LineNumbers: array [0..PairCount - 1] of Word; // PairCount �� Word ��ʾ�кţ��кų��� 65536զ�죿)
  end;
  PTDLineMappingEntry = ^TTDLineMappingEntry;

function CreateInProcessAllModulesList: TCnInProcessModuleList;
var
  HP: array of THandle;
  I, L: Integer;
  Cnt: DWORD;
  Info: TCnModuleDebugInfo;
begin
  Result := nil;

  // ��ȡ Module �б�
  if not EnumProcessModules(GetCurrentProcess, nil, 0, Cnt) then
    Exit;

  if Cnt = 0 then
    Exit;

  L := Cnt div SizeOf(THandle);
  SetLength(HP, L);
  if EnumProcessModules(GetCurrentProcess, @HP[0], Cnt, Cnt) then
  begin
    Result := TCnInProcessModuleList.Create;
    for I := 0 to L - 1 do
    begin
      Info := Result.CreateDebugInfoFromModule(HP[I]);
      if Info <> nil then
        Result.Add(Info);
    end;
  end;
end;

// �õ�������ĳ�����ַ������ Module��Ҳ����ģ�����ַ���粻����ģ���򷵻� 0
function ModuleFromAddr(const Addr: Pointer): HMODULE;
var
  MBI: TMemoryBasicInformation;
begin
  VirtualQuery(Addr, MBI, SizeOf(MBI));
  if MBI.State <> MEM_COMMIT then
    Result := 0
  else
    Result := HMODULE(MBI.AllocationBase);
end;

function ExtractNewString(Ptr: Pointer; MaxLen: Integer = 0): AnsiString;
var
  L: Integer;
begin
  Result := '';
  if Ptr <> nil then
  begin
    L := StrLen(PAnsiChar(Ptr));
    if L > 0 then
      Result := StrNew(PAnsiChar(Ptr));
  end;
end;

function MapFileToPointer(const FileName: string; out FileHandle, MapHandle: THandle;
  out Address: Pointer): Boolean;
begin
  // ���ļ�������ӳ�䡢ӳ���ַ
  Result := False;
  FileHandle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ or
                FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or
                FILE_FLAG_SEQUENTIAL_SCAN, 0);

  if FileHandle <> INVALID_HANDLE_VALUE then
  begin
    MapHandle := CreateFileMapping(FileHandle, nil, PAGE_READONLY, 0, 0, nil);
    if MapHandle <> 0 then
    begin
      Address := MapViewOfFile(MapHandle, FILE_MAP_READ, 0, 0, 0);
      if Address <> nil then
      begin
        Result := True; // �ɹ�����ʱ������ֵ������Ч��
        Exit;
      end
      else // �������ӳ��ɹ�������ַӳ��ʧ�ܣ�����Ҫ�رմ���ӳ��
      begin
        CloseHandle(MapHandle);
        MapHandle := INVALID_HANDLE_VALUE;
      end;
    end
    else // ������ļ��ɹ���������ӳ��ʧ�ܣ�����Ҫ�ر��ļ�
    begin
      CloseHandle(FileHandle);
      MapHandle := INVALID_HANDLE_VALUE;
    end;
  end;
end;

function UnMapFileFromPointer(var FileHandle, MapHandle: THandle;
  var Address: Pointer): Boolean;
begin
  UnmapViewOfFile(Address);
  Address := nil;

  CloseHandle(MapHandle);
  MapHandle := INVALID_HANDLE_VALUE;

  CloseHandle(FileHandle);
  FileHandle := INVALID_HANDLE_VALUE;

  Result := True;
end;

{ TCnPE }

constructor TCnPE.Create(const APEFileName: string);
begin
  inherited Create;
  FFileHandle := INVALID_HANDLE_VALUE;
  FMapHandle := INVALID_HANDLE_VALUE;

  FPEFile := APEFileName;
  FMode := ppmFile;
end;

constructor TCnPE.Create(AModuleHandle: HMODULE);
begin
  inherited Create;
  FFileHandle := INVALID_HANDLE_VALUE;
  FMapHandle := INVALID_HANDLE_VALUE;

  FModule := AModuleHandle;
  FMode := ppmMemoryModule;
end;

destructor TCnPE.Destroy;
begin
  if FMode = ppmFile then
    UnMapFileFromPointer(FFileHandle, FMapHandle, FBaseAddress);
  inherited;
end;

function TCnPE.GetIsDll: Boolean;
begin
  Result := (FFileHeader^.Characteristics and IMAGE_FILE_DLL) <> 0;
end;

function TCnPE.GetIsExe: Boolean;
begin
  Result := ((FFileHeader^.Characteristics and IMAGE_FILE_EXECUTABLE_IMAGE) <> 0) // ������ָ���Ǵ������ˣ�û���Ӵ��󣬲�����ָ EXE
    and not GetIsDll and not GetIsSys;
end;

function TCnPE.GetIsSys: Boolean;
begin
  Result := (FFileHeader^.Characteristics and IMAGE_FILE_SYSTEM) <> 0;
end;

function TCnPE.GetIsWin32: Boolean;
begin
  Result := ((FFileHeader^.Machine and IMAGE_FILE_MACHINE_I386) <> 0) and
    (FOptionalMagic = IMAGE_NT_OPTIONAL_HDR32_MAGIC);
end;

function TCnPE.GetIsWin64: Boolean;
begin
  Result := ((FFileHeader^.Machine = IMAGE_FILE_MACHINE_IA64) or
    (FFileHeader^.Machine = IMAGE_FILE_MACHINE_AMD64)) and
    (FOptionalMagic = IMAGE_NT_OPTIONAL_HDR64_MAGIC);
end;

function TCnPE.GetSectionHeader(Index: Integer): PImageSectionHeader;
begin
  if (Index < 0) or (Index >= Integer(FFileNumberOfSections)) then
    raise ECnPEException.CreateFmt(SCnPESectionIndexErrorFmt, [Index]);

  Result := PImageSectionHeader(TCnNativeInt(FSectionHeader) + Index * SizeOf(TImageSectionHeader));
end;

procedure TCnPE.Parse;
begin
  if FMode = ppmFile then
  begin
    if not MapFileToPointer(FPEFile, FFileHandle, FMapHandle, FBaseAddress) then
      raise ECnPEException.CreateFmt(SCnPEOpenErrorFmt, [FPEFile]);
  end
  else if FMode = ppmMemoryModule then
  begin
    FBaseAddress := Pointer(FModule);
  end;

  // ������ͷ
  ParseHeaders;

  // ���������
  ParseExports;

  // �����ڲ�������Ϣ
  ParseDebugData;
end;


procedure TCnPE.ParseDebugData;
begin
  FDirectoryDebug := nil;
  try
    FDirectoryDebug := PImageDebugDirectory(DataDirectoryContent[IMAGE_DIRECTORY_ENTRY_DEBUG]);
  except
    ;
  end;

  if FDirectoryDebug = nil then
    Exit;

  FDebugType := FDirectoryDebug^._Type;
  FDebugSizeOfData := FDirectoryDebug^.SizeOfData;
  FDebugAddressOfRawData := FDirectoryDebug^.AddressOfRawData;
  FDebugPointerToRawData := FDirectoryDebug^.PointerToRawData;


end;

function TCnPE.GetDataDirectory(Index: Integer): PImageDataDirectory;
begin
  if (Index < 0) or (DWORD(Index) >= FOptionalNumberOfRvaAndSizes) then
    raise ECnPEException.CreateFmt(SCnPEDataDirectoryIndexErrorFmt, [Index]);

  if IsWin32 then
    Result := @(PImageOptionalHeader(FOptionalHeader)^.DataDirectory[Index])
  else if IsWin64 then
    Result := @(PImageOptionalHeader64(FOptionalHeader)^.DataDirectory[Index])
  else
    Result := nil;
end;

function TCnPE.GetDataDirectoryVirtualAddress(Index: Integer): DWORD;
var
  P: PImageDataDirectory;
begin
  P := DataDirectory[Index];
  if P <> nil then
    Result := P^.VirtualAddress
  else
    Result := 0;
end;

function TCnPE.GetDebugContent: Pointer;
var
  D: DWORD;
begin
  if FMode = ppmFile then
  begin
    D := FDebugPointerToRawData;   // ���ļ�ƫ��
    if D = 0 then
      D := FDebugAddressOfRawData; // ���ܴ����ļ�ƫ��Ϊ 0 �������
    Result := RvaToActual(D);
  end
  else if FMode = ppmMemoryModule then
  begin
    D := FDebugAddressOfRawData;   // ���Ѽ���չ������ڴ�ƫ��
    Result := RvaToActual(D);
  end
  else
    Result := nil;
end;

function TCnPE.GetDataDirectorySize(Index: Integer): DWORD;
var
  P: PImageDataDirectory;
begin
  P := DataDirectory[Index];
  if P <> nil then
    Result := P^.Size
  else
    Result := 0;
end;

function TCnPE.GetDataDirectoryContent(Index: Integer): Pointer;
var
  D: DWORD;
begin
  D := GetDataDirectoryVirtualAddress(Index);
  Result := RvaToActual(D);
end;

function TCnPE.GetDataDirectoryCount: Integer;
begin
  Result := FOptionalNumberOfRvaAndSizes;
end;

function TCnPE.GetSectionCount: Integer;
begin
  Result := FFileNumberOfSections;
end;

function TCnPE.GetSectionCharacteristics(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.Characteristics
  else
    Result := 0;
end;

function TCnPE.GetSectionContent(Index: Integer): Pointer;
var
  D: DWORD;
begin
  Result := nil;
  if FMode = ppmFile then
  begin
    D := GetSectionPointerToRawData(Index); // ���ļ�ƫ��
    if D = 0 then
      D := GetSectionVirtualAddress(Index); // �����ļ�ƫ��Ϊ 0 �����
    Result := RvaToActual(D);
  end
  else if FMode = ppmMemoryModule then
  begin
    D := GetSectionVirtualAddress(Index);   // ���Ѽ���չ������ڴ�ƫ��
    Result := RvaToActual(D);
  end;
end;

function TCnPE.GetSectionVirtualSize(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.Misc.VirtualSize
  else
    Result := 0;
end;

function TCnPE.GetSectionName(Index: Integer): AnsiString;
var
  P: PImageSectionHeader;
begin
  Result := '';
  P := SectionHeader[Index];
  if P <> nil then
    Result := ExtractNewString(@P^.Name[0]);
end;

function TCnPE.GetSectionNumberOfLinenumbers(Index: Integer): Word;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.NumberOfLinenumbers
  else
    Result := 0;
end;

function TCnPE.GetSectionNumberOfRelocations(Index: Integer): Word;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.NumberOfRelocations
  else
    Result := 0;
end;

function TCnPE.GetSectionPointerToLinenumbers(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.PointerToLinenumbers
  else
    Result := 0;
end;

function TCnPE.GetSectionPointerToRawData(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.PointerToRawData
  else
    Result := 0;
end;

function TCnPE.GetSectionPointerToRelocations(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.PointerToRelocations
  else
    Result := 0;
end;

function TCnPE.GetSectionSizeOfRawData(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.SizeOfRawData
  else
    Result := 0;
end;

function TCnPE.GetSectionVirtualAddress(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.VirtualAddress
  else
    Result := 0;
end;

function TCnPE.GetSectionContentSize(Index: Integer): DWORD;
var
  T: DWORD;
begin
  Result := GetSectionSizeOfRawData(Index);
  T := GetSectionVirtualSize(Index);
  if (T <> 0) and (Result <> 0) and (Result > T) then
    Result := T
  else if Result = 0 then
    Result := T;
end;

function TCnPE.RvaToActual(Rva: DWORD): Pointer;
var
  SH: PImageSectionHeader;
begin
  Result := nil;

  // PE �������ڴ�չ����ȫ�����ϴ˹���
  if FMode = ppmMemoryModule then
    Result := Pointer(TCnNativeUInt(FBaseAddress) + Rva)
  else if FMode = ppmFile then
  begin
    // ������ļ�ģʽ��ͷ�����ϴ˹��򣻸������������̿������ļ���ֱ�ӷ����в��
    SH := GetSectionHeaderFromRva(Rva);
    if SH <> nil then
    begin
      // �ҵ��� RVA �� Section ͷ�� RVA �ľ��룬�ټ��� Section ͷ���ļ�ƫ��
      Result := Pointer(TCnNativeUInt(FBaseAddress) +
        (Rva - SH^.VirtualAddress + SH^.PointerToRawData));
    end;
  end;
end;

function TCnPE.GetSectionHeaderFromRva(Rva: DWORD): PImageSectionHeader;
var
  I: Integer;
  SH: PImageSectionHeader;
  ER: DWORD;
begin
  Result := nil;
  for I := 0 to SectionCount - 1 do
  begin
    SH := GetSectionHeader(I);
    if SH^.SizeOfRawData = 0 then
      ER := SH^.Misc.VirtualSize
    else
      ER := SH^.SizeOfRawData;
    Inc(ER, SH^.VirtualAddress);
    if (SH^.VirtualAddress <= Rva) and (ER >= Rva) then
    begin
      Result := SH;
      Break;
    end;
  end;
end;

procedure TCnPE.ParseExports;
var
  I, J, T: DWORD;
  O: WORD;
  PAddress, PName: PDWORD;
  POrd: PWORD;
begin
  FDirectoryExport := nil;
  try
    FDirectoryExport := PImageExportDirectory(DataDirectoryContent[IMAGE_DIRECTORY_ENTRY_EXPORT]);
  except
    ;
  end;

  if FDirectoryExport = nil then
    Exit;

  if FDirectoryExport^.Name <> 0 then
    FExportName := ExtractNewString(RvaToActual(FDirectoryExport^.Name));
  FExportBase := FDirectoryExport^.Base;
  FExportNumberOfNames := FDirectoryExport^.NumberOfNames;
  FExportNumberOfFunctions := FDirectoryExport^.NumberOfFunctions;

  SetLength(FExportItems, FExportNumberOfFunctions);
  if FExportNumberOfFunctions <= 0 then
    Exit;

{
  AddressOfFunctions: ^PDWORD;     ָ���ַ���飬�±�� AddressOfNameOrdinals �л�ȡ��һ�� NumberOfFunctions ��
  AddressOfNames: ^PDWORD;         ָ����������  �±�����������ڵĶ�Ӧ��ֵ�������ַ����� RVA��һ�� NumberOfNames ����
  AddressOfNameOrdinals: ^PWord;   ָ��������飬�±������������ڵĶ�Ӧ��ֵ�� AddressOfFunctions ����±꣬һ�� NumberOfFunctions

  NumberOfFunctions ���ܴ��� NumberOfNames����Ĳ�����û���֡����������ĺ�����
  ����� AddressOfNameOrdinals ���ֵ�� Base
}

  // ���� AddressofFunctions ���˳�����У�ȡ����ַ
  PAddress := PDWORD(RvaToActual(DWORD(FDirectoryExport^.AddressOfFunctions)));
  PName := PDWORD(RvaToActual(DWORD(FDirectoryExport^.AddressOfNames)));
  POrd := PWORD(RvaToActual(DWORD(FDirectoryExport^.AddressOfNameOrdinals)));

  I := 0;
  while I < FExportNumberOfNames do
  begin
    FExportItems[I].Name := ExtractNewString(RvaToActual(PName^));  // ȡ���֡���ź͵�ַ

    O := POrd^;
    FExportItems[I].Ordinal := O + FExportBase;

    T := PDWORD(TCnNativeUInt(PAddress) + O * SizeOf(DWORD))^;
    if T <> 0 then
      FExportItems[I].Address := RvaToActual(T)
    else
      FExportItems[I].Address := nil;

    Inc(PName);
    Inc(POrd);
    Inc(I);
  end;

  J := I;
  I := 0;
  while I < FExportNumberOfFunctions - FExportNumberOfNames do
  begin
    O := POrd^;                                                    // û���ֵģ�ȡ��ź͵�ַ
    FExportItems[J + I].Ordinal := O + FExportBase;

    T := PDWORD(TCnNativeUInt(PAddress) + O * SizeOf(DWORD))^;
    if T <> 0 then
      FExportItems[J + I].Address := RvaToActual(T)
    else
      FExportItems[J + I].Address := nil;

    Inc(POrd);
    Inc(I);
  end;
end;

procedure TCnPE.ParseHeaders;
var
  P: PByte;
  OH32: PImageOptionalHeader;
  OH64: PImageOptionalHeader64;
begin
  FDosHeader := PImageDosHeader(FBaseAddress);
  if FDosHeader^.e_magic <> IMAGE_DOS_SIGNATURE then
    raise ECnPEException.Create(SCnPEFormatError);

  P := PByte(FBaseAddress);
  Inc(P, FDosHeader^._lfanew);

  FNtHeaders := PImageNtHeaders(P);
  if FNtHeaders^.Signature <> IMAGE_NT_SIGNATURE then
    raise ECnPEException.Create(SCnPEFormatError);

  FFileHeader := @FNtHeaders^.FileHeader;
  FOptionalHeader := @FNtHeaders^.OptionalHeader;

  // �ĸ��� Header ��ָ���ˣ���ʼ��ֵ������ DosHeader
  FDosMagic := FDosHeader^.e_magic;
  FDosCblp := FDosHeader^.e_cblp;
  FDosCp := FDosHeader^.e_cp;
  FDosCrlc := FDosHeader^.e_crlc;
  FDosCparhdr := FDosHeader^.e_cparhdr;
  FDosMinalloc := FDosHeader^.e_minalloc;
  FDosMaxalloc := FDosHeader^.e_maxalloc;
  FDosSs := FDosHeader^.e_ss;
  FDosSp := FDosHeader^.e_sp;
  FDosCsum := FDosHeader^.e_csum;
  FDosIp := FDosHeader^.e_ip;
  FDosCs := FDosHeader^.e_cs;
  FDosLfarlc := FDosHeader^.e_lfarlc;
  FDosOvno := FDosHeader^.e_ovno;
  FDosOemid := FDosHeader^.e_oemid;
  FDosOeminfo := FDosHeader^.e_oeminfo;
  FDosLfanew := FDosHeader^._lfanew;

  // Signature
  FSignature := FNtHeaders^.Signature;

  // Ȼ���� FileHeader
  FFileMachine := FFileHeader^.Machine;
  FFileNumberOfSections := FFileHeader^.NumberOfSections;
  FFileTimeDateStamp := FFileHeader^.TimeDateStamp;
  FFilePointerToSymbolTable := FFileHeader^.PointerToSymbolTable;
  FFileNumberOfSymbols := FFileHeader^.NumberOfSymbols;
  FFileSizeOfOptionalHeader := FFileHeader^.SizeOfOptionalHeader;
  FFileCharacteristics := FFileHeader^.Characteristics;

  // Ȼ���� OptionalHeader��ע�� TImageOptionalHeader�� 64 λ�������¾����� TImageOptionalHeader64���˴�����ʽд�� 32
  if FFileSizeOfOptionalHeader = SizeOf(TImageOptionalHeader32) then // 32 λ
  begin
    OH32 := PImageOptionalHeader(FOptionalHeader);

    FOptionalMagic := OH32^.Magic;
    FOptionalMajorLinkerVersion := OH32^.MajorLinkerVersion;
    FOptionalMinorLinkerVersion := OH32^.MinorLinkerVersion;
    FOptionalSizeOfCode := OH32^.SizeOfCode;
    FOptionalSizeOfInitializedData := OH32^.SizeOfInitializedData;
    FOptionalSizeOfUninitializedData := OH32^.SizeOfUninitializedData;
    FOptionalAddressOfEntryPoint := OH32^.AddressOfEntryPoint;
    FOptionalBaseOfCode := OH32^.BaseOfCode;
    FOptionalBaseOfData := OH32^.BaseOfData;

    FOptionalImageBase := OH32^.ImageBase;
    FOptionalSectionAlignment := OH32^.SectionAlignment;
    FOptionalFileAlignment := OH32^.FileAlignment;
    FOptionalMajorOperatingSystemVersion := OH32^.MajorOperatingSystemVersion;
    FOptionalMinorOperatingSystemVersion := OH32^.MinorOperatingSystemVersion;
    FOptionalMajorImageVersion := OH32^.MajorImageVersion;
    FOptionalMinorImageVersion := OH32^.MinorImageVersion;
    FOptionalMajorSubsystemVersion := OH32^.MajorSubsystemVersion;
    FOptionalMinorSubsystemVersion := OH32^.MinorSubsystemVersion;
    FOptionalWin32VersionValue := OH32^.Win32VersionValue;
    FOptionalSizeOfImage := OH32^.SizeOfImage;
    FOptionalSizeOfHeaders := OH32^.SizeOfHeaders;
    FOptionalCheckSum := OH32^.CheckSum;
    FOptionalSubsystem := OH32^.Subsystem;
    FOptionalDllCharacteristics := OH32^.DllCharacteristics;
    FOptionalSizeOfStackReserve := OH32^.SizeOfStackReserve;
    FOptionalSizeOfStackCommit := OH32^.SizeOfStackCommit;
    FOptionalSizeOfHeapReserve := OH32^.SizeOfHeapReserve;
    FOptionalSizeOfHeapCommit := OH32^.SizeOfHeapCommit;
    FOptionalLoaderFlags := OH32^.LoaderFlags;
    FOptionalNumberOfRvaAndSizes := OH32^.NumberOfRvaAndSizes;
  end
  else if FFileSizeOfOptionalHeader = SizeOf(TImageOptionalHeader64) then // 64 λ
  begin
    OH64 := PImageOptionalHeader64(FOptionalHeader);

    FOptionalMagic := OH64^.Magic;
    FOptionalMajorLinkerVersion := OH64^.MajorLinkerVersion;
    FOptionalMinorLinkerVersion := OH64^.MinorLinkerVersion;
    FOptionalSizeOfCode := OH64^.SizeOfCode;
    FOptionalSizeOfInitializedData := OH64^.SizeOfInitializedData;
    FOptionalSizeOfUninitializedData := OH64^.SizeOfUninitializedData;
    FOptionalAddressOfEntryPoint := OH64^.AddressOfEntryPoint;
    FOptionalBaseOfCode := OH64^.BaseOfCode;
    FOptionalBaseOfData := 0;  // 64 λû�� OH64^.BaseOfData;

    FOptionalImageBase64 := OH64^.ImageBase;
    FOptionalSectionAlignment := OH64^.SectionAlignment;
    FOptionalFileAlignment := OH64^.FileAlignment;
    FOptionalMajorOperatingSystemVersion := OH64^.MajorOperatingSystemVersion;
    FOptionalMinorOperatingSystemVersion := OH64^.MinorOperatingSystemVersion;
    FOptionalMajorImageVersion := OH64^.MajorImageVersion;
    FOptionalMinorImageVersion := OH64^.MinorImageVersion;
    FOptionalMajorSubsystemVersion := OH64^.MajorSubsystemVersion;
    FOptionalMinorSubsystemVersion := OH64^.MinorSubsystemVersion;
    FOptionalWin32VersionValue := OH64^.Win32VersionValue;
    FOptionalSizeOfImage := OH64^.SizeOfImage;
    FOptionalSizeOfHeaders := OH64^.SizeOfHeaders;
    FOptionalCheckSum := OH64^.CheckSum;
    FOptionalSubsystem := OH64^.Subsystem;
    FOptionalDllCharacteristics := OH64^.DllCharacteristics;
    FOptionalSizeOfStackReserve64 := OH64^.SizeOfStackReserve;
    FOptionalSizeOfStackCommit64 := OH64^.SizeOfStackCommit;
    FOptionalSizeOfHeapReserve64 := OH64^.SizeOfHeapReserve;
    FOptionalSizeOfHeapCommit64 := OH64^.SizeOfHeapCommit;
    FOptionalLoaderFlags := OH64^.LoaderFlags;
    FOptionalNumberOfRvaAndSizes := OH64^.NumberOfRvaAndSizes;
  end;

  FSectionHeader := PImageSectionHeader(TCnNativeInt(FOptionalHeader) + FFileSizeOfOptionalHeader);
end;

function TCnPE.GetExportFunctionItem(Index: Integer): PCnPEExportItem;
begin
  if (Index < 0) or (Index >= Length(FExportItems)) then
    raise ECnPEException.CreateFmt(SCnPEExportIndexErrorFmt, [Index]);

  Result := @FExportItems[Index];
end;

function ExportItemCompare(P1, P2: Pointer; ElementByteSize: Integer): Integer;
var
  E1, E2: PCnPEExportItem;
begin
  E1 := PCnPEExportItem(P1);
  E2 := PCnPEExportItem(P2);

  if TCnNativeUInt(E1^.Address) > TCnNativeUInt(E2^.Address) then
    Result := 1
  else if TCnNativeUInt(E1^.Address) < TCnNativeUInt(E2^.Address) then
    Result := -1
  else
    Result := 0;
end;

procedure TCnPE.SortExports;
begin
  // ���������ַ����
  MemoryQuickSort(@FExportItems[0], SizeOf(TCnPEExportItem), Length(FExportItems), ExportItemCompare);
end;

function TCnPE.GetIsDebug: Boolean;
begin
  Result := DataDirectoryContent[IMAGE_DIRECTORY_ENTRY_DEBUG] <> nil;
end;

{ TCnInProcessModuleList }

constructor TCnInProcessModuleList.Create;
begin
  inherited Create(True);
end;

function TCnInProcessModuleList.CreateDebugInfoFromAddress(
  Address: Pointer): TCnModuleDebugInfo;
var
  M: HMODULE;
begin
  M := ModuleFromAddr(Address);
  Result := GetDebugInfoFromModule(M);

  if Result = nil then
  begin
    Result := CreateDebugInfoFromModule(M);
    if Result <> nil then
      Add(Result);
  end;
end;

function TCnInProcessModuleList.CreateDebugInfoFromModule(AModuleHandle: HMODULE): TCnModuleDebugInfo;
begin
  // ���ݸ������������ͬ�����࣬������� 64 λ��Map �� tds �ļ���
  Result := TCnModuleDebugInfoTD32.Create(AModuleHandle);
  if not Result.Init then
    FreeAndNil(Result)
  else
    Exit;

  Result := TCnModuleDebugInfo.Create(AModuleHandle);
  if not Result.Init then
    FreeAndNil(Result);
end;

destructor TCnInProcessModuleList.Destroy;
begin

  inherited;
end;

function TCnInProcessModuleList.GetDebugInfoFromAddress(
  Address: Pointer): TCnModuleDebugInfo;
begin
  Result := GetDebugInfoFromModule(ModuleFromAddr(Address));
end;

function TCnInProcessModuleList.GetDebugInfoFromModule(
  AModuleHandle: HMODULE): TCnModuleDebugInfo;
var
  I: Integer;
  Info: TCnModuleDebugInfo;
begin
  for I := 0 to Count - 1 do
  begin
    Info := Items[I];
    if (Info <> nil) and (Info.ModuleHandle = AModuleHandle) then
    begin
      Result := Info;
      Exit;
    end;
  end;
  Result := nil;
end;

function TCnInProcessModuleList.GetItem(Index: Integer): TCnModuleDebugInfo;
begin
  Result := TCnModuleDebugInfo(inherited GetItem(Index));
end;

procedure TCnInProcessModuleList.SetItem(Index: Integer;
  const Value: TCnModuleDebugInfo);
begin
  inherited SetItem(Index, Value);
end;

{ TCnModuleDebugInfo }

constructor TCnModuleDebugInfo.Create(AModuleHandle: HMODULE);
var
  F: array[0..MAX_PATH - 1] of Char;
begin
  inherited Create;
  FModuleHandle := AModuleHandle;
  if GetModuleFileName(FModuleHandle, @F[0], SizeOf(F)) > 0 then;
    FModuleFile := StrNew(PChar(@F[0]));
end;

destructor TCnModuleDebugInfo.Destroy;
begin
  FPE.Free;
  inherited;
end;

function TCnModuleDebugInfo.GetDebugInfoFromAddr(Address: Pointer;
  out OutModuleFile, OutUnitName, OutProcName: string; out OutLineNumber, OutOffsetLineNumber,
  OutOffsetProc: Integer): Boolean;
var
  I: Integer;
  Item: PCnPEExportItem;
begin
  Result := False;
  OutModuleFile := ExtractFileName(FModuleFile);
  OutUnitName := '';

  for I := FPE.ExportNumberOfFunctions - 1 downto 0 do
  begin
    Item := FPE.ExportFunctionItem[I];
    if TCnNativeUInt(Item^.Address) < TCnNativeUInt(Address) then
    begin
      OutProcName := Item^.Name;
      OutOffsetProc := TCnNativeUInt(Address) - TCnNativeUInt(Item^.Address);

      OutLineNumber := CN_INVALID_LINENUMBER_OFFSET;
      OutOffsetLineNumber := CN_INVALID_LINENUMBER_OFFSET;

      Result := True;
      Exit;
    end;
  end;
end;

function TCnModuleDebugInfo.Init: Boolean;
begin
  Result := (FModuleHandle <> 0) and (FModuleHandle <> INVALID_HANDLE_VALUE)
    and FileExists(FModuleFile);
  if Result then
  begin
    FPE := TCnPE.Create(FModuleHandle);
    FPE.Parse;
    FPE.SortExports;
  end;
end;

function TCnModuleDebugInfo.VAFromAddr(Address: Pointer): DWORD;
begin
  Result := DWORD(TCnNativeUInt(Address) - TCnNativeUInt(FModuleHandle)
    - TCnNativeUInt(FPE.FOptionalBaseOfCode));
end;

{ TCnModuleDebugInfoTD32 }

constructor TCnModuleDebugInfoTD32.Create(AModuleHandle: HMODULE);
begin
  inherited;
  FNames := TStringList.Create;
  FSourceModuleNames := TStringList.Create;
  FProcedureNames := TStringList.Create;

  FLineNumbers := TCnIntegerList.Create;
  FOffsets := TCnIntegerList.Create;

  FNames.Add('');  // NameIndex �� 1 ��ʼ
end;

destructor TCnModuleDebugInfoTD32.Destroy;
var
  I: Integer;
begin
  FStream.Free;

  FOffsets.Free;
  FLineNumbers.Free;

  for I := 0 to FProcedureNames.Count - 1 do
    FProcedureNames.Objects[I].Free;
  FProcedureNames.Free;

  for I := 0 to FSourceModuleNames.Count - 1 do
    FSourceModuleNames.Objects[I].Free;
  FSourceModuleNames.Free;

  FNames.Free;
  inherited;
end;

function TCnModuleDebugInfoTD32.GetDebugInfoFromAddr(Address: Pointer;
  out OutModuleFile, OutUnitName, OutProcName: string; out OutLineNumber,
  OutOffsetLineNumber, OutOffsetProc: Integer): Boolean;
var
  I: Integer;
  VA: DWORD;
begin
  VA := VAFromAddr(Address);

  // ģ����
  OutModuleFile := ExtractFileName(FModuleFile);

  // Դ���ļ���
  OutUnitName := '';
  for I := 0 to SourceModuleCount - 1 do
  begin
    if SourceModules[I].IsAddressInSource(VA) then
    begin
      OutUnitName := SourceModules[I].Name;
      Break;
    end;
  end;

  // ������
  for I := 0 to ProcedureCount - 1 do
  begin
    if Procedures[I].IsAddressInProcedure(VA) then
    begin
      OutProcName := Procedures[I].Name;
      OutOffsetProc := VA - Procedures[I].Offset;
      Break;
    end;
  end;

  // �к���ƫ��
  if OutUnitName <> '' then
  begin
    // ��Դ�ļ������кź��кż�ƫ��
    for I := 0 to FLineNumbers.Count - 1 do
    begin
      if VA = DWORD(FOffsets[I]) then
      begin
        OutLineNumber := FLineNumbers[I];
        OutOffsetLineNumber := 0;
        Break;
      end
      else if (I > 0) and (DWORD(FOffsets[I - 1]) <= VA) and (DWORD(FOffsets[I]) > VA) then
      begin
        OutLineNumber := FLineNumbers[I - 1];
        OutOffsetLineNumber := VA - DWORD(FOffsets[I - 1]);
        Break;
      end;

      OutOffsetLineNumber := CN_INVALID_LINENUMBER_OFFSET;
    end;
  end
  else
  begin
    OutOffsetLineNumber := CN_INVALID_LINENUMBER_OFFSET;
    OutLineNumber := CN_INVALID_LINENUMBER_OFFSET;
  end;

  Result := True;
end;

function TCnModuleDebugInfoTD32.GetLineNumberCount: Integer;
begin
  Result := FLineNumbers.Count;
end;

function TCnModuleDebugInfoTD32.GetLineNumbers(Index: Integer): Integer;
begin
  Result := FLineNumbers[Index];
end;

function TCnModuleDebugInfoTD32.GetOffsetCount: Integer;
begin
  Result := FOffsets.Count;
end;

function TCnModuleDebugInfoTD32.GetOffsets(Index: Integer): Integer;
begin
  Result := FOffsets[Index];
end;

function TCnModuleDebugInfoTD32.GetProcedureCount: Integer;
begin
  Result := FProcedureNames.Count;
end;

function TCnModuleDebugInfoTD32.GetProcedures(Index: Integer): TCnTDProcedureSymbol;
begin
  Result := TCnTDProcedureSymbol(FProcedureNames.Objects[Index]);
end;

function TCnModuleDebugInfoTD32.GetSourceModuleCount: Integer;
begin
  Result := FSourceModuleNames.Count;
end;

function TCnModuleDebugInfoTD32.GetSourceModules(Index: Integer): TCnTDSourceModule;
begin
  Result := TCnTDSourceModule(FSourceModuleNames.Objects[Index]);
end;

function TCnModuleDebugInfoTD32.Init: Boolean;
var
  I: Integer;
  Sig: PTDFileSignature;
  DH: PTDDirectoryHeader;
  Tds: string;
begin
  Result := inherited Init;
  if not Result then
    Exit;

  // ���ഴ���� PE ���󣬶����� Debug Information ָ����ߴ�
  Result := False;
  FData := FPE.DebugContent;
  FSize := FPE.DebugSizeOfData;

  if (FPE.DebugType <> IMAGE_DEBUG_TYPE_UNKNOWN) or (FData = nil) or (FSize <= SizeOf(TTDFileSignature)) then
  begin
    Tds := ChangeFileExt(FModuleFile, '.tds');  // �޵�����Ϣ�򲻺Ϸ����ж� tds �ļ�
    if FileExists(Tds) then
    begin
      FStream := TMemoryStream.Create;
      FStream.LoadFromFile(Tds);

      FData := FStream.Memory;
      FSize := FStream.Size;
    end
    else
      Exit;  
  end;

  Sig := PTDFileSignature(FData);
  if (Sig^.Signature <> TD_SIGNATURE_DELPHI) and (Sig^.Signature <> TD_SIGNATURE_BCB) then
    Exit;  // ���ֵ�������˳�

  DH := PTDDirectoryHeader(TCnNativeUInt(Sig) + Sig^.Offset);
  while True do
  begin
    for I := 0 to DH^.DirEntryCount - 1 do
    begin
      // ���� DH^.DirEntries[I];
      ParseSubSection(@DH^.DirEntries[I]);
    end;

    // Ѱ����һ�� Header
    if DH^.lfoNextDir = 0 then
      Break;
    DH := PTDDirectoryHeader(TCnNativeUInt(DH) + DH^.lfoNextDir);
  end;
  SyncNames;

  Result := True;
end;

procedure TCnModuleDebugInfoTD32.ParseSubSection(DSE: Pointer);
var
  DE: PTDDirectoryEntry;
  DS: Pointer;
  C, O: DWORD;
  I, J, L: Integer;
  PName: PAnsiChar;
  S: string;
  MI: PTDSourceModuleInfo;
  SE: PTDSourceFileEntry;
  LM: PTDLineMappingEntry;
  SM: TCnTDSourceModule;
  SIS: PTDSymbolInfos;
  SI: PTDSymbolInfo;
  PS: TCnTDProcedureSymbol;
begin
  DE := PTDDirectoryEntry(DSE); // ������ Entry
  DS := Pointer(TCnNativeUInt(FData) + DE^.Offset); // �ҵ������� SubSection ���ݣ���ߴ��� DE^.Size
  case DE^.SubsectionType of
    TD_SUBSECTION_TYPE_NAMES:
      begin
        C := PDWORD(DS)^; // ��һ�� DWORD ������
        PName := PAnsiChar(DS);
        Inc(PName, SizeOf(DWORD));

        for I := 0 to C - 1 do // ������һ�ֽڳ��ȼ��ַ������ݼ� #0
        begin
          L := Ord(PName^);
          Inc(PName);
          S := StrNew(PName);
          FNames.Add(S);
          Inc(PName, L + 1);
        end;
      end;
    TD_SUBSECTION_TYPE_SOURCE_MODULE:
      begin
        MI := PTDSourceModuleInfo(DS);
        for I := 0 to MI^.FileCount - 1 do
        begin
          SE := PTDSourceFileEntry(TCnNativeUInt(MI) + MI^.BaseSrcFiles[I]);
          if SE^.NameIndex > 0 then
          begin
            // һ�� SourceFileEntry ���ļ���������������ÿ�ζ�Ӧ�� LineMappingEntry �ṹ�����ʼ�ṹ
            SM := TCnTDSourceModule.Create;
            SM.NameIndex := SE^.NameIndex;
            SM.SegmentCount := SE^.SegmentCount;
            SM.SegmentArray := @SE^.BaseSrcLines[SE^.SegmentCount];

            for J := 0 to SM.SegmentCount - 1 do
            begin
              LM := PTDLineMappingEntry(TCnNativeUInt(MI) + SE^.BaseSrcLines[J]);
              for L := 0 to LM^.PairCount - 1 do
              begin
                FOffsets.Add(Integer(LM^.Offsets[L]));
                FLineNumbers.Add(Integer(PCnWord16Array(@LM^.Offsets[LM^.PairCount])^[L]));
              end;
            end;

            FSourceModuleNames.AddObject('', SM); // �����º��ٲ���
          end;
        end;
      end;
    TD_SUBSECTION_TYPE_ALIGN_SYMBOLS:
      begin
        SIS := PTDSymbolInfos(DS);
        O := SizeOf(SIS^.Signature);
        while O < DE^.Size do
        begin
          SI := PTDSymbolInfo(TCnNativeUInt(SIS) + O);
          if (SI^.SymbolType = SYMBOL_TYPE_LPROC32) or (SI^.SymbolType = SYMBOL_TYPE_GPROC32) then
          begin
            PS := TCnTDProcedureSymbol.Create;
            PS.NameIndex := SI^.Proc.NameIndex;
            PS.Offset := SI^.Proc.Offset;
            PS.Size := SI^.Proc.Size;
            FProcedureNames.AddObject('', PS);
          end;
          Inc(O, SI^.Size + SizeOf(SI^.Size));
        end;
      end;
  end;
end;

procedure TCnModuleDebugInfoTD32.SyncNames;
var
  I: Integer;
  SM: TCnTDSourceModule;
  PS: TCnTDProcedureSymbol;
begin
  for I := 0 to FSourceModuleNames.Count - 1 do
  begin
    SM := TCnTDSourceModule(FSourceModuleNames.Objects[I]);
    if (SM <> nil) and (SM.Name = '') then
    begin
      SM.Name := FNames[SM.NameIndex];
      FSourceModuleNames[I] := SM.Name;
    end;
  end;

  for I := 0 to FProcedureNames.Count - 1 do
  begin
    PS := TCnTDProcedureSymbol(FProcedureNames.Objects[I]);
    if (PS <> nil) and (PS.Name = '') then
    begin
      PS.Name := FNames[PS.NameIndex];
      FProcedureNames[I] := PS.Name;
    end;
  end;
end;

{ TCnTDSourceModule }

function TCnTDSourceModule.GetSegmentEnd(Index: Integer): DWORD;
var
  P: PDWORD;
begin
  P := FSegmentArray;
  Inc(P, 2 * Index + 1);
  Result := P^;
end;

function TCnTDSourceModule.GetSegmentStart(Index: Integer): DWORD;
var
  P: PDWORD;
begin
  P := FSegmentArray;
  Inc(P, 2 * Index);
  Result := P^;
end;

function TCnTDSourceModule.IsAddressInSource(Address: DWORD): Boolean;
var
  I: Integer;
  S, E: DWORD;
begin
  Result := False;
  for I := 0 to FSegmentCount - 1 do
  begin
    S := SegmentStart[I];
    E := SegmentEnd[I];
    if (Address >= S) and (Address <= E) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

{ TCnTDProcSymbol }

function TCnTDProcedureSymbol.IsAddressInProcedure(Address: DWORD): Boolean;
begin
  Result := (Address >= FOffset) and (Address <= FOffset + FSize);
end;

end.