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

unit CnGB18030;
{* |<PRE>
================================================================================
* �������ƣ�������������
* ��Ԫ���ƣ�֧�� GB18030 ���ַ��� 2022 �� Unicode �Ĺ��ߵ�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��GB18030 ���ַ�����Ϊ����� GBK/GB2312���ʴ˱������Ƿǵȿ��ַ�����
*           �ַ������� ASCII ��һ�ֽڡ���ͨ���ֵĶ��ֽڡ���Ƨ���ֵ����ֽ�����
*           �Ҿ��ǰ��Ķ�ϰ�߽������У������� AnsiString
*           �� Delphi �� WideString �� UnicodeString �� UTF16-LE��˫�ֽڱ����еߵ�
*           ���硰�Է��������֣�
*           AnsiString �ڴ����� B3D4B7B9��GB18030����Ҳ�� B3D4 �� B7B9 �����Ķ�˳��
*           UnicodeString �ڴ����� 03546D99���� Unicode ����ȴ�� 5403 �� 996D���з���
*
*           GB18030 �У��ַ��ı���ֵ����ʵ�ʱ�������
*           UTF16 �У�����ƽ���ڵı���ֵ���������ֽڣ�����ʵ�����ֽڱ��뷽ʽ��ͬ
*
*           ϵͳ�� UtfEncode �����ܹ���ȷ�������ֽ� UTF16-LE��ע�� UTF8 ת������
*           ���ֽ� UTF16 �ַ��ı���ֵ������ת�����ֽڱ�������� UTF8-MB4 �㹻����
*
*           GB18030 �ı���ȡֵ��Χ��ʮ�����ƣ�
*           ע�⣺˫�ֽڵ� AABB~CCDD �ķ�Χ����ͨ�������ϵ����� FF �ٽ�λ��
*             ���Ǵ���ǰһ���ֽ� AA �� CC���Һ�һ���ֽ� CC �� DD���������� AAFF ���֡�
*           �����ֽ�ȴ�ֲ�ͬ��
*             �����ֽ�˳�����ӣ������� 30~39��û�� 40�������� 40 ʱ������ֽڽ�λ��һ�� 10 ��
*             �����ֽ�˳�����ӣ������� 81~FE��û�� FF�������� FF ʱ��ڶ��ֽڽ�λ��һ�� 10 * 126 = 1260 ��
*             �ڶ��ֽ�˳�����ӣ������� 30~39��û�� 40�������� 40 ʱ���һ�ֽڽ�λ��һ�� 1260 * 10 = 12600 ��
*             ��һ�ֽ�˳�����ӣ������� 81~FE��û�� FF�������� FF ʱ��׼�����硣    һ�� 12600 * 126 = 1587600 �������Ϲ淶
*
*           ���ֽڣ�00~7F
*
*           ˫�ֽڣ������������й��޹ص����������ַ����� Unicode ���ֶ��ֽ���λ���Ҷ�Ӧ��ֻ�ܲ����
*
*                   �ܷ�Χ��ͷ�ֽ� 81~FE�����ֽ� 40~7E��80~FE          ��λ�� �ַ���
*                   8140~A07E, 8180~A0FE          3 ������     ������  6080   6080   GBK ������
*                   A140~A77E, A180~A7A0          �û� 3 ��    ������  672
*                   A1A1~A9FE                     1 ������     ������  846    171
*                   A840~A97E, A880~A9A0          5 ������     ������  192    166
*                   AA40~FE7E, AA80~FEA0          4 ������     ������  8160   8160
*                   AAA1~AFFE                     �û� 1 ��    ����    564           E000 �� E233
*                   B0A1~F7FE                     2 ������     ������  6768   6763   GB2312
*                   F8A1~FEFE                     �û� 2 ��    ����    658           E234 �� E4C5
*
*           ���ֽڣ������������й��޹ص����������ַ���
*
*  ���뷶Χ                      ��������                           ����λ������������ ��Ч�ַ���   Unicode ����
*  ���ֽڵ� Unicode ����ƽ��ӳ��
*           81308130~81318131            �ָ���һ                               1262                0080 �� 060B�������������жദ��Ծ
*  81318132~81319934             ά����������ˡ��¶�������һ                   243    42           060C �� 06FE����ʼ����
*           81319935~8132E833            �ָ�����                               2049                06FF �� 0EFF  |
*  8132E834~8132FD31             ����                                           208    193          0F00 �� 0FCF  |
*           8132FD32~81339D35            �ָ�����                               304                 0FD0 �� 10FF  |
*  81339D36~8133B635             ��������ĸ                                     250    69           1100 �� 11F9  |
*           8133B636~8134D237            �ָ�����                               1542                11FA �� 17FF  |
*  8134D238~8134E337             �ɹ��ģ�������߯�������Ͱ�������֣�           170    149          1800 �� 18A9  |
*           8134E338~8134F433            �ָ�����                               166                 18AA �� 194F  |
*  8134F434~8134F830             �º����                                       37     35           1950 �� 1974  |
*           8134F831~8134F931            �ָ�����                               11                  1975 �� 197F  |
*  8134F932~81358437             ��˫�����´���                                 96     83           1980 �� 19DF  |
*           81358438~81358B31            �ָ�����                               64                  19E0 �� 1A1F  |
*  81358B32~81359935             ��˫�����ϴ���                                 144    127          1A20 �� 1AAF��������ֹ
*           81359936~81398B31            �ָ�����                               4896                1AB0 �� 2EFF�������������� 81379735 = 24FF �� 81379736 = 254C ����Ծ
*  81398B32~8139A135             �������ף��淶�����н�β�� 8139A035��          224    214          2F00 �� 2FDF����������
*           8139A136~8139A932            �ָ�����                               77                  2FE0 �� 3130��������
*  8139A933~8139B734             �����ļ�����ĸ                                 142    51           3131 �� 31BE����������
*           8139B735~8139EE38            �ָ���ʮ                               554                 31BF �� 33FF�������������� 8139C131 = 321F �� 8139C132 = 322A ����Ծ
*  8139EE39~82358738             CJK ͳһ�������� A                             6530   6530         3400 �� 4DB5��������������82358731 = 4DAD �� 82358732 = 4DAF �Լ������ط�����ʮ�ദ��Ծ
*           82358739~82358F32            �ָ���ʮһ                             74                  4DB6 �� 4DFF����������
*  82358F33~82359636             CJK ͳһ����                                   74     66           9FA6 �� 9FEF����ʼ����
*           82359637~82359832            �ָ���ʮ��                             16                  9FF0 �� 9FFF  |
*  82359833~82369435             ����                                           1223   1215         A000 �� A4C6  |
*           82369436~82369534            �ָ���ʮ��                             9                   A4C7 �� A4CF  |
*  82369535~82369A32             ������                                         48     48           A4D0 �� A4FF  |
*           82369A33~8237CF34            �ָ���ʮ��                             1792                A500 �� ABFF  |
*  8237CF35~8336BE36             ����������                                     11172  3431         AC00 �� D7A3��������ֹ
*           8336BE37~8430BA31            �ָ���ʮ��                             4995                D7A4 �� FB4F�������������� 8336C738 = D7FF �� 8336C739 = E76C
*  8430BA32~8430FE35             ά����������ˡ��¶������Ķ�                   684    59           FB50 �� FDFB����������
*           8430FE36~84318639            �ָ���ʮ��                             64                  FDFC �� FE6F�������������� 84318537 = FE2F �� 84318538 = FE32
*  84318730~84319530             ά����������ˡ��¶���������                   141    84           FE70 �� FEFC����������
*           84319531~8431A439            �ָ���ʮ�ߣ�GB18030 ������ֹ           159                 FEFD �� FFFF����������84319534 = FF00 ���� 84319535 = FF5F
*
*  ���ֽڵ� Unicode ��չƽ��ӳ�䡣��Χ�� 90308130~E339FE39����������ӳ�䵽ʮ����ƽ�棬�� 1058400 ����λ
*  9034C538~9034C730             �ɹ��� BIRGA��GB18030 �ֿ�ʼ����               13     13           11660 �� 1166C����ʼ����
*           9034C731~9232C635            �ָ���ʮ�ˣ��淶ʡ��ֻ�� 9034C739      22675               1166D �� 16EFF  |
*  9232C636~9232D635             �ᶫ������                                     160    133          16F00 �� 16F9F  |
*           9232D636~95328235            �ָ���ʮ�ţ��淶ʡ��ֻ�� 9232D639      36960               16FA0 �� 1FFFF  |
*  95328236~9835F336             CJK ͳһ�������� B                             42711  42711        20000 �� 2A6D6  |
*           9835F337~9835F737            �ָ�����ʮ                             41                  2A6D7 �� 2A6FF  |
*  9835F738~98399E36             CJK ͳһ�������� C                             4149   4149         2A700 �� 2B734  |
*           98399E37~98399F37            �ָ�����ʮһ                           11                  2B735 �� 2B73F  |
*  98399F38~9839B539             CJK ͳһ�������� D                             222    222          2B740 �� 2B81D  |
*           9839B630~9839B631            �ָ�����ʮ��                           2                   2B81E �� 2B81F  |
*  9839B632~9933FE33             CJK ͳһ�������� E                             5762   5762         2B820 �� 2CEA1  |
*           9933FE34~99348137            �ָ�����ʮ��                           14                  2CEA2 �� 2CEAF  |
*  99348138~9939F730             CJK ͳһ�������� F                             7473   7473         2CEB0 �� 2EBE0  |
*           9939F731~9A348431            �ָ�����ʮ��                           5151                2EBE1 �� 2FFFF��������ֹ
*
*  FD308130~FE39FE39             �û��Զ�������Ŀǰ�� Unicode ӳ��
*
*           ע�⣺ÿ�����ֽ����������������ڻ���������ڹ涨����Ч�ַ�����
*              ��ʣ�����Ч�ַ�����Ч�ַ�һ����ͬ���� Unicode �ַ�ֵӳ�䡣
*              ����������֮��ķָ�����Ҳͬ���� Unicode �ַ�ֵӳ�䣬ֻ��û����Ч�ַ���
*
*           ���ԣ��������ֽ� GB18010 ������ Unicode ��Ӧ�����������ӳ��������£�����˸����ֻ��д󲿷�˫�ֽ�ֻ�ܲ������
*
*                 AAA1~AFFE         ���Զ�Ӧ E000~E233    �û�һ����
*                 F8A1~FEFE         ���Զ�Ӧ E234~E4C5    �û�������
*                 81318132~81359935 ���Զ�Ӧ 060C~1AAF    ά����������ˡ��¶�������һͷ����˫�����ϴ���β
*                 81398B32~8139A135 ���Զ�Ӧ 2F00~2FDF    ��������
*                 8139A933~8139B734 ���Զ�Ӧ 3131~31BE    �����ļ�����ĸ
*                 82358739~82358F32 ���Զ�Ӧ 4DB6~4DFF    �ָ���ʮһ
*                 82358F33~8336BE36 ���Զ�Ӧ 9FA6~D7A3    CJK ͳһ����ͷ������������β
*                 8430BA32~8430FE35 ���Զ�Ӧ FB50~FDFB    ά����������ˡ��¶������Ķ�
*                 84318730~84319530 ���Զ�Ӧ FE70~FEFC    ά����������ˡ��¶���������
*                 9034C538~9A348431 ���Զ�Ӧ 11660~2FFFF  �ɹ��� BIRGA ͷ���ָ�����ʮ��β
*
*             �� GB18030 ˫�ֽڱ���ת��Ϊ Unicode ʱ���ȸ���˫�ֽ�ֵȷ�����������������ĸ�
*                Ȼ���ɴӸߵ��Ͷ��ֽڣ�����ȥ GB18010 ���俪ʼ���ֽ�ֵ�������и�ֵ��
*                ������ֵ�ֱ���� 94��1 ����ӣ��ټ��� Unicode ������ʼֵ����
*
*             �� GB18030 ���ֽڱ���ת��Ϊ Unicode ʱ���ȸ������ֽ�ֵȷ����������������ĸ�
*                Ȼ���ɴӸߵ������ֽڣ�����ȥ GB18010 ���俪ʼ���ֽ�ֵ�������и�ֵ����
*                �ĸ���ֵ�ֱ���� 12600��1260��10��1 ����ӣ��ټ��� Unicode ������ʼֵ����
*             ������������ڣ���ֻ�ܲ������ż������������ı�
*
*             ����չλ���ӳ�䣺90308130 ��Ӧ 10000���� 95328235 ��Ӧ 1FFFF
*                ���� 90308130 �ĺ����ֽڸպ��Ǹ��ֽڵ���ʼֵ������� 95308130 ǰһ������ 5 * 12600 = 63000 ����λ
*                ���� 95308130 �ĺ���ֽ�Ҳ�պ��Ǹ��ֽ���ʼֵ������� 95328130 ǰһ������ 2 * 1260 = 2520 ����λ
*                ���� 95328130 �ĺ�һ�ֽ�Ҳ�պ��Ǹ��ֽ���ʼֵ������� 95328230 ǰһ������ 1 * 10 = 10 ����λ
*                95328230 �� 95328235��6 ����λ��������һ�� 65536 ����λ�����õ���һ�� Unicode ��չλ�������λ��
*
* ����ƽ̨��PWin98SE + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�������ʽ
* �޸ļ�¼��2022.11.25
*               ������ Unicode ��غ������� CnWideStrings ��
*           2022.11.20
*               ʵ�� 52 �������ֵ��ж�
*           2022.11.16
*               ʵ�ֲ������� Windows API �� Unicode �ַ��� GB18030-2022 ��ת��
*           2022.11.14
*               ʵ�ֲ������� Windows API �� GB18030-2022 ȫ���ַ��� Unicode ��ת��
*           2022.11.11
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNative, CnWideStrings;

const
  CN_GB18030_CODEPAGE  = 54936;

type
{$IFDEF SUPPORT_ANSISTRING_CODEPAGE}
  TCnGB18030String = RawByteString;
{$ELSE}
  TCnGB18030String = AnsiString;
{$ENDIF}
  {* GB18030 ������ַ������ڲ��� RawByteString Ҳ���� AnsiString($FFFF) ��ʾ}

  PCnGB18130String = ^TCnGB18030String;
  {* ָ�� GB18030 ������ַ�����ָ��}

  PCnGB18030StringPtr = PAnsiChar;
  {* GB18030 ������ַ�ָ�룬�ڲ��� PAnsiChar ��ʾ}

function GetCharLengthFromGB18030(GB18030Str: PCnGB18030StringPtr): Integer;
{* ����һ GB18030 �ַ������ַ���}

function GetByteWidthFromGB18030(GB18030Str: PCnGB18030StringPtr): Integer;
{* ����һ GB18030 �ַ����ĵ�ǰ�ַ�ռ�����ֽ�}

function Utf16ToGB18030(Utf16Str: PWideChar; GB18030Str: PCnGB18030StringPtr): Integer;
{* ��һ UTF16�����ܻ�� Unicode ��չƽ��������ֽ��ַ����ַ���ת��Ϊ GB18030 �ַ���
  GB18030Str ��ָ������������ת���Ľ�����紫 nil���򲻽���ת��
  ����ֵ���� GB18030Str ����ı��س��Ȼ�ת����ı��س��ȣ�������ĩβ�� #0}

function GB18030ToUtf16(GB18030Str: PCnGB18030StringPtr; Utf16Str: PWideChar): Integer;
{* ��һ GB18030 �ַ���ת��Ϊ UTF16�����ܻ�� Unicode ��չƽ��������ֽ��ַ����ַ���
  UniStr ��ָ������������ת���Ľ�����紫 nil���򲻽���ת��
  ����ֵ���� UniStr �����˫�ֽ��ַ����Ȼ�ת�����˫�ֽ��ַ����ȣ�������ĩβ�Ŀ��ַ� #0}

function GetGB18030FromUtf16(Utf16Str: PWideChar): TCnGB18030String;
{* ����һ Unicode �ַ�����Ӧ�� GB18030 �ַ���}

function GetUnicodeFromGB18030CodePoint(GBCP: TCnCodePoint): TCnCodePoint;
{* �� GB18030 �ַ�����ֵ��ȡ���Ӧ�� Unicode ����ֵ}

function GetGB18030FromUnicodeCodePoint(UCP: TCnCodePoint): TCnCodePoint;
{* �� Unicode �ַ�����ֵ��ȡ���Ӧ�� GB18030 ����ֵ}

{$IFDEF UNICODE}

function GetUtf16FromGB18030(GB18030Str: TCnGB18030String): string;
{* ����һ GB18030 �ַ�����Ӧ�� Utf16 �ַ���}

{$ELSE}

function GetUtf16FromGB18030(GB18030Str: TCnGB18030String): WideString;
{* ����һ GB18030 �ַ�����Ӧ�� Utf16 �ַ���}

{$ENDIF}

function GetCodePointFromGB18030Char(PtrToGB18030Chars: PCnGB18030StringPtr): TCnCodePoint;
{* ����һ�� GB18030 �ַ��ı���ֵ��Ҳ�д���λ�ã���ע�� PtrToGB18030Chars ����ָ��һ������˫�����ֽ��ַ�}

function GetGB18030CharsFromCodePoint(CP: TCnCodePoint; PtrToChars: Pointer): Integer;
{* ����һ�� GB18030 ����ֵ��һ�ֽڻ���ֽڻ����ֽڱ�ʾ����� PtrToChars ָ���λ�ò�Ϊ����ת��������ݷ���ͷ
   ����ֵ��ת�����ֽ�����1 �� 2 �� 4}

function IsUnicodeDuplicated(CP: TCnCodePoint): Boolean; overload;
{* �ж�һ Unicode �����Ƿ��� 52 ��������֮һ����ʽ�� PUA ����}

function IsUnicodeDuplicated(CP: TCnCodePoint; out Dup: TCnCodePoint): Boolean; overload;
{* �ж�һ Unicode �����Ƿ��� 52 ��������֮һ��˳�㷵�������֣���ʽ�� PUA ����}

function IsUnicodeDuplicated3(CP: TCnCodePoint): Boolean; overload;
{* �ж�һ Unicode �����Ƿ��� 3 ����������֮һ���� PUA ��һ����ʽ}

function IsUnicodeDuplicated3(CP: TCnCodePoint; out Dup1, Dup2: TCnCodePoint): Boolean; overload;
{* �ж�һ Unicode �����Ƿ��� 3 ����������֮һ��˳�㷵���������֣��� PUA ��һ����ʽ}

function IsUnicodeEqual(CP1, CP2: TCnCodePoint): Boolean;
{* �ж����� Unicode �����Ƿ���ȣ��в��� GB18030 �����ֵĴ���}

function CnCompareUnicodeString(US1, US2: PWideChar): Boolean;
{* �Ƚ����� Utf16 ����� UnicodeString �Ƿ���ȣ��� 52 �������ֵĴ���}

function IsGBKDuplicated(CP: TCnCodePoint): Boolean;
{* �ж�һ�� GBK �����Ƿ����� 52 ��������֮һ}

function IsGB18030Duplicated(CP: TCnCodePoint): Boolean;
{* �ж�һ�� GB18030 �����Ƿ����� 52 ��������֮һ}

function IsGB18030CodePointEqual(CP1, CP2: TCnCodePoint): Boolean;
{* �ж����� GB18030 �����Ƿ���ȣ����������ֵĴ���}

function IsGB18030Char1(CP: TCnCodePoint): Boolean;
{* �ж�ָ�� GB18030 ����ֵ�Ƿ�Ϸ��ĵ��ֽ��ַ�}

function IsGB18030Char2(CP: TCnCodePoint): Boolean;
{* �ж�ָ�� GB18030 ����ֵ�Ƿ�Ϸ���˫�ֽ��ַ�}

function IsGB18030Char4(CP: TCnCodePoint): Boolean;
{* �ж�ָ�� GB18030 ����ֵ�Ƿ�Ϸ������ֽ��ַ�}

function IsUnicodeInPrivateUserArea(CP: TCnCodePoint): Boolean;
{* �ж�ָ���� Unicode ����ֵ�Ƿ����� PUA ��}

function IsGB18030InPrivateUserArea(CP: TCnCodePoint): Boolean;
{* �ж�ָ�� GB18030 ����ֵ�Ƿ����� PUA ��}

function IsGB18030In2PrivateUserArea(CP: TCnCodePoint): Boolean;
{* �ж�ָ�� GB18030 ����ֵ�Ƿ�����˫�ֽ� PUA ��}

function IsGB18030In4PrivateUserArea(CP: TCnCodePoint): Boolean;
{* �ж�ָ�� GB18030 ����ֵ�Ƿ��������ֽ� PUA ��}

function GetPrevGB18030CodePoint(CP: TCnCodePoint; CheckRange: Boolean = False): TCnCodePoint;
{* ��ȡָ�� GB18030 ����ֵ��ǰһ������ֵ������ 0���򷵻� CN_INVALID_CODEPOINT
  CheckRange Ϊ True ʱ��ʾ���ϸ��� CP �Ƿ�Ϸ��� GB18030 ����ֵ���ǲŷ���ǰһ��
  Ϊ False ʱ���۸��ַ��Ƿ�Ϸ�����������ǰһ���Ϸ��ַ�����ֵ}

function GetNextGB18030CodePoint(CP: TCnCodePoint; CheckRange: Boolean = False): TCnCodePoint;
{* ��ȡָ�� GB18030 ����ֵ�ĺ�һ������ֵ���������һ�����򷵻� CN_INVALID_CODEPOINT
  CheckRange Ϊ True ʱ��ʾ���ϸ��� CP �Ƿ�Ϸ��� GB18030 ����ֵ���ǲŷ��غ�һ��
  Ϊ False ʱ���۸��ַ��Ƿ�Ϸ������������һ���Ϸ��ַ�����ֵ}

implementation

uses
  CnHashMap;

type
  TCnGB18030MappingPage = packed record
  {* ��¼һ�������ַ���ӳ������}
    GBHead: TCnCodePoint;
    GBTail: TCnCodePoint;
    UHead:  TCnCodePoint;
    UTail:  TCnCodePoint;
  end;

const
  CN_GB18030_BOM: array[0..3] of Byte = ($84, $31, $95, $33);

  // GB18030 �е� 52 �������ֵı���ֵ��Դ�� GBK��ԭʼ������˫�ֽ�������������չ��
  CN_DUPLICATES_GB18030: array[0..51] of TCnCodePoint = (
    $8336C936, $8336C937, $8336CA30, $8336CA31, $8336CA32, $8336CA35, $8336CA36,
    $8336CA37, $8336CA38, $8336CA39, $8336CB30, $8336CB31, $8336CB32, $8336CB33,
    $8336CB36, $8336CB37, $8336CB39, $8336CC33, $8336CC34, $8336CC36, $8336CC37,
    $8336CC38, $8336CC39, $8336CD30, $8336CD31, $8336CD32, $8336CD33, $8336CD35,
    $8336CD36, $8336CD37, $8336CD38, $8336CD39, $8336CE30, $8336CE31, $8336CE32,
    $8336CE33, $8336CE34, $8336CE35, $8336CE36, $8336CE37, $8336CE38, $8336CE39,
    $8336CF30, $8336CF31, $8336CF32, $8336CF33, $8336CF34, $8336CF35, $8336CF36,
    $8336CF37, $8336CF38, $8336CF39
  );

  // GB18030 �е� 52 �������ֵı���ֵ��ֵԴ�� GBK����˫�ֽ�����
  CN_DUPLICATES_GBK: array[0..51] of TCnCodePoint = (
    $FE55, $FE56, $FE5A, $FE5B, $FE5C, $FE5F, $FE60, $FE62, $FE63, $FE64, $FE65,
    $FE68, $FE69, $FE6A, $FE6F, $FE70, $FE72, $FE77, $FE78, $FE7A, $FE7B, $FE7C,
    $FE7D, $FE80, $FE81, $FE82, $FE83, $FE85, $FE86, $FE87, $FE88, $FE89, $FE8A,
    $FE8B, $FE8C, $FE8D, $FE8E, $FE8F, $FE92, $FE93, $FE94, $FE95, $FE96, $FE97,
    $FE98, $FE99, $FE9A, $FE9B, $FE9C, $FE9D, $FE9E, $FE9F
  );

  // GBK �е� 52 �������ֵ� Unicode ������ʽֵ������ 3400 �� 4DB5 ��� CJK ��չ A ����
  CN_DUPLICATES_UNICODE: array[0..51] of TCnCodePoint = (
    $3473, $3447, $359E, $361A, $360E, $396E, $3918, $39CF, $39DF, $3A73, $39D0,
    $3B4E, $3C6E, $3CE0, $4056, $415F, $4337, $43B1, $43AC, $43DD, $44D6, $4661,
    $464C, $4723, $4729, $477C, $478D, $4947, $497A, $497D, $4982, $4983, $4985,
    $4986, $499F, $499B, $49B7, $49B6, $4CA3, $4C9F, $4CA0, $4CA1, $4C77, $4CA2,
    $4D13, $4D14, $4D15, $4D16, $4D17, $4D18, $4D19, $4DAE
  );

  // GBK �е� 52 ���������� Unicode ��ԭ�ȵ� PUA ֵ
  CN_DUPLICATES_UNICODE_PUA: array[0..51] of TCnCodePoint = (
    $E81A, $E81B, $E81F, $E820, $E821, $E824, $E825, $E827, $E828, $E829, $E82A,
    $E82D, $E82E, $E82F, $E834, $E835, $E837, $E83C, $E83D, $E83F, $E840, $E841,
    $E842, $E844, $E845, $E846, $E847, $E849, $E84A, $E84B, $E84C, $E84D, $E84E,
    $E84F, $E850, $E851, $E852, $E853, $E856, $E857, $E858, $E859, $E85A, $E85B,
    $E85C, $E85D, $E85E, $E85F, $E860, $E861, $E862, $E863
  );

  // �����������֣�Ҳ����һ���������룡��Դ�� JRT0253-2022 �淶
  CN_DUPLICATES_3_UNICODE: array[0..2] of array[0..2] of TCnCodePoint = (
    ($E3FE, $E579, $2B4E9),
    ($E05D, $F429, $39D1),
    ($E56B, $EAF0, $2285F)
  );

  // ˫�ֽ���ת�����
  CN_GB18030_2CHAR_PAGES: array[0..1] of TCnGB18030MappingPage = (
    (GBHead: $AAA1; GBTail: $AFFE; UHead: $E000; UTail: $E233),
    (GBHead: $F8A1; GBTail: $FEFE; UHead: $E234; UTail: $E4C5)
  );
  // ˫�ֽ������ڻ��� 9983~99F5 -> 6AAD~6B1F һ���� 115 ���ַ���������������
  CN_GB18030_2CHAR_PAGE_COUNT = 94;

  // ���ֽ���ת����ء������������������� *** �ģ���Ҳ�в��������е�����С�����䣨�����ַ����� 32 ���ģ�
  CN_GB18030_4CHAR_PAGES: array[0..65] of TCnGB18030MappingPage = (

    // �ָ���һ��
    (GBHead: $81308130; GBTail: $81308435; UHead: $0080; UTail: $00A3),   // 36
    (GBHead: $81309538; GBTail: $81309F35; UHead: $016C; UTail: $01CD),   // 98
    (GBHead: $8130A331; GBTail: $8130AB37; UHead: $01FA; UTail: $0250),   // 87
    (GBHead: $8130AD33; GBTail: $8130B733; UHead: $0262; UTail: $02C6),   // 101
    (GBHead: $8130B838; GBTail: $8130CB30; UHead: $02DA; UTail: $0390),   // 183
    (GBHead: $8130CC30; GBTail: $8130D134; UHead: $03CA; UTail: $0400),   // 55
    (GBHead: $8130D330; GBTail: $81318131; UHead: $0452; UTail: $060B),   // 442

    (GBHead: $81318132; GBTail: $81359935; UHead: $060C; UTail: $1AAF),   // *** ά����������ˡ��¶�������һͷ����˫�����ϴ���β

    // �ָ����ˣ�
    (GBHead: $81359936; GBTail: $8136A531; UHead: $1AB0; UTail: $200F),   // 1376
    (GBHead: $8136A830; GBTail: $8136B331; UHead: $203C; UTail: $20AB),   // 112
    (GBHead: $8136B332; GBTail: $8136BB37; UHead: $20AD; UTail: $2102),   // 86
    (GBHead: $8136BE34; GBTail: $8136C435; UHead: $2122; UTail: $215F),   // 62
    (GBHead: $8136C734; GBTail: $8136D233; UHead: $219A; UTail: $2207),   // 110
    (GBHead: $8136D935; GBTail: $8136DD31; UHead: $2270; UTail: $2294),   // 37
    (GBHead: $8136E131; GBTail: $8136E932; UHead: $22C0; UTail: $2311),   // 82
    (GBHead: $8136E933; GBTail: $81378C35; UHead: $2313; UTail: $245F),   // 333
    (GBHead: $81378D36; GBTail: $81379735; UHead: $249C; UTail: $24FF),   // 100
    (GBHead: $8137A334; GBTail: $8137A837; UHead: $260A; UTail: $263F),   // 54
    (GBHead: $8137A839; GBTail: $8138FD38; UHead: $2643; UTail: $2E80),   // 2110
    (GBHead: $81398539; GBTail: $81398B31; UHead: $2ECB; UTail: $2EFF),   // 53

    (GBHead: $81398B32; GBTail: $8139A135; UHead: $2F00; UTail: $2FDF),   // *** ��������
    (GBHead: $8139A933; GBTail: $8139B734; UHead: $3131; UTail: $31BE),   // *** �����ļ�����ĸ

    // �ָ���ʮ��
    (GBHead: $8139B735; GBTail: $8139C131; UHead: $31BF; UTail: $321F),   // 97
    (GBHead: $8139C139; GBTail: $8139CD31; UHead: $3232; UTail: $32A2),   // 113
    (GBHead: $8139CD32; GBTail: $8139E435; UHead: $32A4; UTail: $338D),   // 234
    (GBHead: $8139E630; GBTail: $8139E933; UHead: $33A2; UTail: $33C3),   // 34
    (GBHead: $8139EA37; GBTail: $8139EE38; UHead: $33D6; UTail: $33FF),   // 42

    // CJK ͳһ�������� A��
    (GBHead: $8139EE39; GBTail: $8139F539; UHead: $3400; UTail: $3446),   // 71
    (GBHead: $8139F630; GBTail: $8139FA32; UHead: $3448; UTail: $3472),   // 43
    (GBHead: $8139FA33; GBTail: $82309A30; UHead: $3474; UTail: $359D),   // 298
    (GBHead: $82309A31; GBTail: $8230A531; UHead: $359F; UTail: $360D),   // 111
    (GBHead: $8230A633; GBTail: $8230F237; UHead: $361B; UTail: $3917),   // 765
    (GBHead: $8230F238; GBTail: $8230FB32; UHead: $3919; UTail: $396D),   // 85
    (GBHead: $8230FB33; GBTail: $82318638; UHead: $396F; UTail: $39CE),   // 96
    (GBHead: $82318833; GBTail: $82319639; UHead: $39E0; UTail: $3A72),   // 147
    (GBHead: $82319730; GBTail: $8231AC37; UHead: $3A74; UTail: $3B4D),   // 218
    (GBHead: $8231AC38; GBTail: $8231C934; UHead: $3B4F; UTail: $3C6D),   // 287
    (GBHead: $8231C935; GBTail: $8231D437; UHead: $3C6F; UTail: $3CDF),   // 113
    (GBHead: $8231D438; GBTail: $8232AF32; UHead: $3CE1; UTail: $4055),   // 885
    (GBHead: $8232AF33; GBTail: $8232C936; UHead: $4057; UTail: $415E),   // 264
    (GBHead: $8232C937; GBTail: $8232F837; UHead: $4160; UTail: $4336),   // 471
    (GBHead: $8232F838; GBTail: $82338633; UHead: $4338; UTail: $43AB),   // 116
    (GBHead: $82338638; GBTail: $82338B30; UHead: $43B2; UTail: $43DC),   // 43
    (GBHead: $82338B31; GBTail: $8233A338; UHead: $43DE; UTail: $44D5),   // 248
    (GBHead: $8233A339; GBTail: $8233C931; UHead: $44D7; UTail: $464B),   // 373
    (GBHead: $8233CB32; GBTail: $8233DE34; UHead: $4662; UTail: $4722),   // 193
    (GBHead: $8233DF30; GBTail: $8233E731; UHead: $472A; UTail: $477B),   // 82
    (GBHead: $8233E838; GBTail: $82349638; UHead: $478E; UTail: $4946),   // 441
    (GBHead: $82349639; GBTail: $82349B38; UHead: $4948; UTail: $4979),   // 50
    (GBHead: $8234A131; GBTail: $8234E733; UHead: $49B8; UTail: $4C76),   // 703
    (GBHead: $8234E734; GBTail: $8234EB32; UHead: $4C78; UTail: $4C9E),   // 39
    (GBHead: $8234EB33; GBTail: $8234F633; UHead: $4CA4; UTail: $4D12),   // 111
    (GBHead: $8234F634; GBTail: $82358731; UHead: $4D1A; UTail: $4DAD),   // 148

    (GBHead: $82358739; GBTail: $82358F32; UHead: $4DB6; UTail: $4DFF),   // *** �ָ���ʮһ
    (GBHead: $82358F33; GBTail: $8336BE36; UHead: $9FA6; UTail: $D7A3),   // *** CJK ͳһ����ͷ������������β

    // �ָ���ʮ�壺
    (GBHead: $8336BE37; GBTail: $8336C738; UHead: $D7A4; UTail: $D7FF),   // 92
    (GBHead: $8336D030; GBTail: $84308534; UHead: $E865; UTail: $F92B),   // 4295
    (GBHead: $84308535; GBTail: $84308D30; UHead: $F92D; UTail: $F978),   // 76
    (GBHead: $84308F38; GBTail: $84309738; UHead: $F996; UTail: $F9E6),   // 81
    (GBHead: $84309C38; GBTail: $8430BA31; UHead: $FA2A; UTail: $FB4F),   // 294

    (GBHead: $8430BA32; GBTail: $8430FE35; UHead: $FB50; UTail: $FDFB),   // *** ά����������ˡ��¶������Ķ�

    // �ָ���ʮ����
    (GBHead: $8430FE36; GBTail: $84318537; UHead: $FDFC; UTail: $FE2F),   // 52

    (GBHead: $84318730; GBTail: $84319530; UHead: $FE70; UTail: $FEFC),   // *** ά����������ˡ��¶���������

    // �ָ���ʮ�ߣ�
    (GBHead: $84319535; GBTail: $8431A233; UHead: $FF5F; UTail: $FFDF),   // 129

    (GBHead: $90308130; GBTail: $9034C537; UHead: $10000; UTail: $1165F), // *** ��չƽ����ʼ��
    (GBHead: $9034C538; GBTail: $9A348431; UHead: $11660; UTail: $2FFFF)  // *** �ɹ��� BIRGA ͷ���ָ�����ʮ��β
  );

  CN_GB18030_4CHAR_PAGE_COUNT1 = 12600;
  CN_GB18030_4CHAR_PAGE_COUNT2 = 1260;
  CN_GB18030_4CHAR_PAGE_COUNT3 = 10;

  CN_GB18030_MAP_DEF_CAPACITY = 65536;

{$I GB18030_Unicode_2.inc}

{$I GB18030_Unicode_4.inc}

var
  F2GB18030ToUnicodeMap: TCnHashMap = nil;
  F4GB18030ToUnicodeMap: TCnHashMap = nil;
  FUnicodeToGB18030Map: TCnHashMap = nil;
  FUnicodeDuplicateMap: TCnHashMap = nil;

procedure CreateGB18030ToUnicodeMap;
var
  I: Integer;
begin
  if F2GB18030ToUnicodeMap = nil then
  begin
    F2GB18030ToUnicodeMap := TCnHashMap.Create(CN_GB18030_MAP_DEF_CAPACITY);
    for I := Low(CN_GB18030_2MAPPING) to High(CN_GB18030_2MAPPING) do
      F2GB18030ToUnicodeMap.Add(Integer(CN_GB18030_2MAPPING[I]), Integer(CN_UNICODE_2MAPPING[I]));
  end;

  if F4GB18030ToUnicodeMap = nil then
  begin
    F4GB18030ToUnicodeMap := TCnHashMap.Create(CN_GB18030_MAP_DEF_CAPACITY);
    for I := Low(CN_GB18030_4MAPPING) to High(CN_GB18030_4MAPPING) do
      F4GB18030ToUnicodeMap.Add(Integer(CN_GB18030_4MAPPING[I]), Integer(CN_UNICODE_4MAPPING[I]));
  end;
end;

procedure CreateUnicodeToGB18030Map;
var
  I: Integer;
begin
  if FUnicodeToGB18030Map = nil then
  begin
    FUnicodeToGB18030Map := TCnHashMap.Create(CN_GB18030_MAP_DEF_CAPACITY * 2);

    for I := Low(CN_UNICODE_2MAPPING) to High(CN_UNICODE_2MAPPING) do
      FUnicodeToGB18030Map.Add(Integer(CN_UNICODE_2MAPPING[I]), Integer(CN_GB18030_2MAPPING[I]));
    for I := Low(CN_UNICODE_4MAPPING) to High(CN_UNICODE_4MAPPING) do
      FUnicodeToGB18030Map.Add(Integer(CN_UNICODE_4MAPPING[I]), Integer(CN_GB18030_4MAPPING[I]));
  end;
end;

procedure CreateUnicodeDuplicateMap;
var
  I: Integer;
begin
  if FUnicodeDuplicateMap = nil then
  begin
    FUnicodeDuplicateMap := TCnHashMap.Create(256);
    for I := Low(CN_DUPLICATES_UNICODE) to High(CN_DUPLICATES_UNICODE) do
      FUnicodeDuplicateMap.Add(Integer(CN_DUPLICATES_UNICODE[I]), CN_DUPLICATES_UNICODE_PUA[I]);
    for I := Low(CN_DUPLICATES_UNICODE_PUA) to High(CN_DUPLICATES_UNICODE_PUA) do
      FUnicodeDuplicateMap.Add(Integer(CN_DUPLICATES_UNICODE_PUA[I]), CN_DUPLICATES_UNICODE[I]);
  end;
end;

procedure ExtractGB18030CodePoint(CP: TCnCodePoint; out B1, B2, B3, B4: Byte);
begin
  B1 := (CP and $FF000000) shr 24;
  B2 := (CP and $00FF0000) shr 16;
  B3 := (CP and $0000FF00) shr 8;
  B4 := CP and $000000FF;
end;

function CombineGB18030CodePoint(B1, B2, B3, B4: Byte): TCnCodePoint;
begin
  Result := (B1 shl 24) + (B2 shl 16) + (B3 shl 8) + B4;
end;

function IsGB18030CodePointEqual(CP1, CP2: TCnCodePoint): Boolean;
begin
  Result := CP1 = CP2;
end;

function IsGBKDuplicated(CP: TCnCodePoint): Boolean;
var
  I: Integer;
begin
  Result := (CP < CN_DUPLICATES_GBK[0]) or (CP > $FFFF);
  if not Result then
  begin
    for I := Low(CN_DUPLICATES_GBK) to High(CN_DUPLICATES_GBK) do
    begin
      if CP = CN_DUPLICATES_GBK[I] then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function IsGB18030Duplicated(CP: TCnCodePoint): Boolean;
var
  I: Integer;
begin
  Result := (CP < CN_DUPLICATES_GB18030[0]) or (CP > $FFFF);
  if not Result then
  begin
    for I := Low(CN_DUPLICATES_GB18030) to High(CN_DUPLICATES_GB18030) do
    begin
      if CP = CN_DUPLICATES_GB18030[I] then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function IsUnicodeEqual(CP1, CP2: TCnCodePoint): Boolean;
var
  D1, D2: TCnCodePoint;
  Is2, Is3: Boolean;
begin
  Result := CP1 = CP2;
  if not Result and (CP1 <> 0) then // �� 0 �϶�������
  begin
    // �ж�����һ���Ƿ��Ƕ�������
    Is2 := IsUnicodeDuplicated(CP1, D1);
    if Is2 then
      Result := D1 = CP2  // ��� CP1 �������֣����ж� CP2 ����һ�����Ƿ����
    else  // �������һ�����Ƕ������֣�˵�������������ֵ��ж�
    begin
      Is3 := IsUnicodeDuplicated3(CP1, D1, D2);
      if Is3 then // C1 ���������֣��ж� CP2 �����������Ƿ����
        Result := (CP2 = D1) or (CP2 = D2);
    end;
  end;
end;

function CnCompareUnicodeString(US1, US2: PWideChar): Boolean;
var
  L1, L2: Integer;
  C1, C2: TCnCodePoint;
begin
  Result := False;
  if (US1 = nil) and (US2 = nil) then
  begin
    Result := True;
    Exit;
  end
  else if (US1 = nil) or (US2 = nil) then
    Exit;

  // ����ֵ�����Բ���
  while (US1^ <> #0) and (US2^ <> #0) do
  begin
    L1 := GetByteWidthFromUtf16(US1);
    L2 := GetByteWidthFromUtf16(US2);

    if L1 <> L2 then
      Exit;

    C1 := GetCodePointFromUtf16Char(US1);
    C2 := GetCodePointFromUtf16Char(US2);

    if not IsUnicodeEqual(C1, C2) then
      Exit;

    Inc(US1, L1 shr 1);
    Inc(US2, L2 shr 1);
  end;

  Result := US1^ = US2^; // ��һ�� #0 �Ż����ѭ�����⣬������� #0 ��ʾ����û�ˣ����
end;

function IsUnicodeDuplicated(CP: TCnCodePoint): Boolean;
var
  C: TCnCodePoint;
begin
  Result := IsUnicodeDuplicated(CP, C);
end;

function IsUnicodeDuplicated(CP: TCnCodePoint; out Dup: TCnCodePoint): Boolean;
var
  C: Integer;
begin
  Result := FUnicodeDuplicateMap.Find(CP, C);
  if Result then
    Dup := TCnCodePoint(C);
end;

function IsUnicodeDuplicated3(CP: TCnCodePoint): Boolean;
var
  I, J: Integer;
begin
  Result := True;
  for I := Low(CN_DUPLICATES_3_UNICODE) to High(CN_DUPLICATES_3_UNICODE) do
  begin
    // ����ÿ����ֵ��
    for J := Low(CN_DUPLICATES_3_UNICODE[I]) to High(CN_DUPLICATES_3_UNICODE[I]) do
    begin
      if CP = CN_DUPLICATES_3_UNICODE[I][J] then
        Exit;
    end;
  end;
  Result := False;
end;

function IsUnicodeDuplicated3(CP: TCnCodePoint; out Dup1, Dup2: TCnCodePoint): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := Low(CN_DUPLICATES_3_UNICODE) to High(CN_DUPLICATES_3_UNICODE) do
  begin
    // ����ÿ����ֵ��
    if CP = CN_DUPLICATES_3_UNICODE[I][0] then
    begin
      Dup1 := CN_DUPLICATES_3_UNICODE[I][1];
      Dup2 := CN_DUPLICATES_3_UNICODE[I][2];
      Exit;
    end
    else if CP = CN_DUPLICATES_3_UNICODE[I][1] then
    begin
      Dup1 := CN_DUPLICATES_3_UNICODE[I][0];
      Dup2 := CN_DUPLICATES_3_UNICODE[I][2];
      Exit;
    end
    else if CP = CN_DUPLICATES_3_UNICODE[I][2] then
    begin
      Dup1 := CN_DUPLICATES_3_UNICODE[I][0];
      Dup2 := CN_DUPLICATES_3_UNICODE[I][1];
      Exit;
    end;
  end;
  Result := False;
end;

function IsGB18030Char1(CP: TCnCodePoint): Boolean;
begin
  Result := CP in [$00..$7F];
end;

function IsGB18030Char2(CP: TCnCodePoint): Boolean;
var
  B1, B2, B3, B4: Byte;
begin
  ExtractGB18030CodePoint(CP, B1, B2, B3, B4);
  Result := (B1 = 0) and (B2 = 0) and ((B3 >= $81) and (B3 <= $FE)) and
    (((B4 >= $40) and (B4 <= $7E)) or ((B4 >= $80) and (B4 <= $FE)));
end;

function IsGB18030Char4(CP: TCnCodePoint): Boolean;
var
  B1, B2, B3, B4: Byte;
begin
  ExtractGB18030CodePoint(CP, B1, B2, B3, B4);
  Result := ((B1 >= $81) and (B1 <= $FE)) and ((B2 >= $30) and (B2 <= $39))
    and ((B3 >= $81) and (B3 <= $FE)) and ((B4 >= $30) and (B4 <= $39));
end;

function IsUnicodeInPrivateUserArea(CP: TCnCodePoint): Boolean;
begin
  Result := ((CP >= $E000) and (CP <= $F8FF)) or
    ((CP >= $F0000) and (CP <= $FFFFD)) or
    ((CP >= $100000) and (CP <= $10FFFD));
end;

function IsGB18030InPrivateUserArea(CP: TCnCodePoint): Boolean;
begin
  Result := IsGB18030In2PrivateUserArea(CP) or IsGB18030In4PrivateUserArea(CP);
end;

function IsGB18030In2PrivateUserArea(CP: TCnCodePoint): Boolean;
var
  B1, B2, B3, B4: Byte;
begin
  Result := IsGB18030Char2(CP);
  if Result then
  begin
    ExtractGB18030CodePoint(CP, B1, B2, B3, B4);
    Result := ((B3 >= $AA) and (B3 <= $AF) and (B4 >= $A1) and (B4 <= $FE))  // ˫�ֽ��û�һ��
      or ((B3 >= $F8) and (B3 <= $FE) and (B4 >= $A1) and (B4 <= $FE))       // ˫�ֽ��û�����
      or (((B3 >= $A1) and (B3 <= $A7)) and ((B4 >= $40) and (B4 <= $7E) or (B4 >= $80) and (B4 <= $A0))); // ˫�ֽ��û�����
  end;
end;

function IsGB18030In4PrivateUserArea(CP: TCnCodePoint): Boolean;
var
  B1, B2, B3, B4: Byte;
begin
  Result := IsGB18030Char4(CP);
  if Result then
  begin
    ExtractGB18030CodePoint(CP, B1, B2, B3, B4);
    Result := (B1 >= $FD) and (B1 <= $FE); // �����жϾ��� IsGB18030Char4 ��
  end;
end;

function GetPrevGB18030CodePoint(CP: TCnCodePoint; CheckRange: Boolean): TCnCodePoint;
var
  B1, B2, B3, B4: Byte;
begin
  Result := CN_INVALID_CODEPOINT;
  if CP = 0 then
    Exit;

  if CheckRange and (CP in [$80..$FF]) and not IsGB18030Char2(CP) and not IsGB18030Char4(CP) then
    Exit;

  if CP <= $7F then
    Result := CP - 1
  else if CP <= $8140 then    // ���ֽں�˫�ֽڼ�Ŀհף�ǰһ��ȡ���ֽ��ַ����ֵ
    Result := $7F
  else if CP <= $FEFE then    // 8141~FEFE ͷȱһ��
  begin
    // ���ֽ�����
    ExtractGB18030CodePoint(CP, B1, B2, B3, B4);
    if B4 <= $40 then
    begin
      B4 := $FE;
      Dec(B3);
    end
    else
      Dec(B4);

    if B4 = $7F then
      Dec(B4);

    Result := CombineGB18030CodePoint(0, 0, B3, B4);
  end
  else if CP <= $81308130 then // ���ֽں����ֽڼ�Ŀհף�ǰһ��ȡ˫�ֽ��ַ����ֵ
    Result := $FEFE
  else if CP <= $FE39FE39 then // ���ֽ�ͷȱһ��
  begin
    // ���ֽ�����
    ExtractGB18030CodePoint(CP, B1, B2, B3, B4);
    if B4 <= $30 then
    begin
      B4 := $39;
      Dec(B3);
      if B3 < $81 then
      begin
        B3 := $FE;
        Dec(B2);
        if B2 < $30 then
        begin
          B2 := $39;
          Dec(B1);
        end;
        if B1 < $81 then // �����˳�
          Exit;
      end;
    end
    else
      Dec(B4);

    Result := CombineGB18030CodePoint(B1, B2, B3, B4);
  end
  else
    Result := $FE39FE39;
end;

function GetNextGB18030CodePoint(CP: TCnCodePoint; CheckRange: Boolean): TCnCodePoint;
var
  B1, B2, B3, B4: Byte;
begin
  Result := CN_INVALID_CODEPOINT;
  if CP >= $FE39FE39 then
    Exit;

  if CheckRange and (CP in [$80..$FF]) and not IsGB18030Char2(CP) and not IsGB18030Char4(CP) then
    Exit;

  if CP < $7F then
    Result := CP + 1
  else if CP < $8140 then    // ���ֽں�˫�ֽڼ�Ŀհף���һ��ȡ˫�ֽ��ַ���Сֵ
    Result := $8140
  else if CP < $FEFE then    // 8140~FEFD βȱһ��
  begin
    // ���ֽ�����
    ExtractGB18030CodePoint(CP, B1, B2, B3, B4);
    if B4 = $FE then
    begin
      B4 := $40;
      Inc(B3);
    end
    else
    begin
      Inc(B4);
      if B4 = $7F then
        Inc(B4);
    end;
    Result := CombineGB18030CodePoint(0, 0, B3, B4);
  end
  else if CP < $81308130 then // ���ֽں����ֽڼ�Ŀհף���һ��ȡ���ֽ��ַ���Сֵ
    Result := $81308130
  else if CP < $FE39FE39 then // ���ֽ�βȱһ��
  begin
    // ���ֽ�����
    ExtractGB18030CodePoint(CP, B1, B2, B3, B4);

    if B4 >= $39 then
    begin
      B4 := $30;
      Inc(B3);
      if B3 > $FE then
      begin
        B3 := $81;
        Inc(B2);
        if B2 > $39 then
        begin
          B2 := $30;
          Inc(B1);
        end;
        if B1 > $FE then // �����˳�
          Exit;
      end;
    end
    else
      Inc(B4);

    Result := CombineGB18030CodePoint(B1, B2, B3, B4);
  end;
end;

function GetCharLengthFromGB18030(GB18030Str: PCnGB18030StringPtr): Integer;
var
  L: Integer;
begin
  Result := 0;
  while GB18030Str^ <> #0 do
  begin
    L := GetByteWidthFromGB18030(GB18030Str);
    Inc(GB18030Str, L);
    Inc(Result);
  end;
end;

function GetByteWidthFromGB18030(GB18030Str: PCnGB18030StringPtr): Integer;
var
  B1, B2, B3, B4: Byte;
begin
  Result := 1;
  B1 := Byte(GB18030Str^);
  if B1 <= $7F then
    Exit;

  Inc(GB18030Str);
  B2 := Byte(GB18030Str^);

  if (B1 >= $81) and (B1 <= $FE) then
  begin
    if ((B2 >= $40) and (B2 <= $7E)) or
      ((B2 >= $80) and (B2 <= $FE)) then
      Result := 2
    else if (B2 >= $30) and (B2 <= $39) then
    begin
      Inc(GB18030Str);
      B3 := Byte(GB18030Str^);
      Inc(GB18030Str);
      B4 := Byte(GB18030Str^);

      if ((B3 >= $81) and (B3 <= $FE)) or
      ((B4 >= $30) and (B4 <= $39)) then
        Result := 4;
    end;
  end;
end;

function Utf16ToGB18030(Utf16Str: PWideChar; GB18030Str: PCnGB18030StringPtr): Integer;
var
  W: Integer;
  GBCP, UCP: TCnCodePoint;
begin
  Result := 0;
  if Utf16Str = nil then
    Exit;

  while Utf16Str^ <> #0 do
  begin
    W := GetByteWidthFromUtf16(Utf16Str);
    UCP := GetCodePointFromUtf16Char(Utf16Str);
    GBCP := GetGB18030FromUnicodeCodePoint(UCP);
    Inc(Utf16Str, W shr 1);

    if GBCP = CN_INVALID_CODEPOINT then // �Ƿ� GB18030 �ַ�����һ���ʺŴ���
    begin
      if GB18030Str <> nil then
      begin
        GB18030Str^ := CN_ALTERNATIVE_CHAR;
        Inc(GB18030Str);
      end;

      Inc(Result);
    end
    else // �Ϸ��� GB18030 �ַ�
    begin
      W := GetGB18030CharsFromCodePoint(GBCP, GB18030Str);
      if GB18030Str <> nil then
        Inc(GB18030Str, W);

      Inc(Result, W);
    end;
  end;
end;

function GB18030ToUtf16(GB18030Str: PCnGB18030StringPtr; Utf16Str: PWideChar): Integer;
var
  W: Integer;
  GBCP, UCP: TCnCodePoint;
begin
  Result := 0;
  if GB18030Str = nil then
    Exit;

  while GB18030Str^ <> #0 do
  begin
    W := GetByteWidthFromGB18030(GB18030Str);
    GBCP := GetCodePointFromGB18030Char(GB18030Str);
    UCP := GetUnicodeFromGB18030CodePoint(GBCP);
    Inc(GB18030Str, W);

    if UCP = CN_INVALID_CODEPOINT then // �Ƿ� Unicode �ַ�����һ���ʺŴ���
    begin
      if Utf16Str <> nil then
      begin
        Utf16Str^ := CN_ALTERNATIVE_CHAR;
        Inc(Utf16Str);
      end;

      Inc(Result);
    end
    else // �Ϸ��� Unicode �ַ�
    begin
      W := GetUtf16CharFromCodePoint(UCP, Utf16Str);
      if Utf16Str <> nil then
        Inc(Utf16Str, W);

      Inc(Result, W);
    end;
  end;
end;

function GetUnicodeFromGB18030CodePoint(GBCP: TCnCodePoint): TCnCodePoint;
var
  I, GBBase, UBase: TCnCodePoint;
  A1, A2, B1, B2, B3, B4, C1, C2, C3, C4: Byte;
  D1, D2, D3, D4: Integer;
begin
  Result := CN_INVALID_CODEPOINT;

  if GBCP < $80 then
    Result := GBCP
  else if GBCP < $FFFF then
  begin
    // ��˫�ֽڱ�
    GBBase := 0;
    UBase := 0;

    B1 := (GBCP and $0000FF00) shr 8;
    B2 := GBCP and $000000FF;

    for I := Low(CN_GB18030_2CHAR_PAGES) to High(CN_GB18030_2CHAR_PAGES) do
    begin
      A1 := (CN_GB18030_2CHAR_PAGES[I].GBHead and $0000FF00) shr 8;
      A2 := CN_GB18030_2CHAR_PAGES[I].GBHead and $000000FF;
      C1 := (CN_GB18030_2CHAR_PAGES[I].GBTail and $0000FF00) shr 8;
      C2 := CN_GB18030_2CHAR_PAGES[I].GBTail and $000000FF;

      // ˫�ֽ������н��棬����ֱ�ӱȽϴ�С���ж�λ�ã��ò�ֱȽ�
      if (B1 >= A1) and (B1 <= C1) and (B2 >= A2) and (B2 <= C2) then
      begin
        GBBase := CN_GB18030_2CHAR_PAGES[I].GBHead;
        UBase := CN_GB18030_2CHAR_PAGES[I].UHead;
        Break;
      end;
    end;

    if GBBase > 0 then
    begin
      B1 := (GBBase and $0000FF00) shr 8;
      B2 := GBBase and $000000FF;

      C1 := (GBCP and $0000FF00) shr 8;
      C2 := GBCP and $000000FF;

      D1 := C1 - B1;   // ��Ҫ�� Integer����Ϊ�����и�ֵ
      D2 := C2 - B2;

      Result := D1 * CN_GB18030_2CHAR_PAGE_COUNT + D2 + UBase;
    end
    else
    begin
      // ���������ֽ���ϳɵı�
      UBase := F2GB18030ToUnicodeMap.Find(Integer(GBCP));
      if UBase > 0 then
        Result := UBase;
    end;
  end
  else
  begin
    // ���ֽ�
    GBBase := 0;
    UBase := 0;

    for I := Low(CN_GB18030_4CHAR_PAGES) to High(CN_GB18030_4CHAR_PAGES) do
    begin
      if (GBCP >= CN_GB18030_4CHAR_PAGES[I].GBHead) and (GBCP <= CN_GB18030_4CHAR_PAGES[I].GBTail) then
      begin
        GBBase := CN_GB18030_4CHAR_PAGES[I].GBHead;
        UBase := CN_GB18030_4CHAR_PAGES[I].UHead;
        Break;
      end;
    end;

    if GBBase > 0 then
    begin
      ExtractGB18030CodePoint(GBBase, B1, B2, B3, B4);
      ExtractGB18030CodePoint(GBCP, C1, C2, C3, C4);

      D1 := C1 - B1;   // ��Ҫ�� Integer����Ϊ�����и�ֵ
      D2 := C2 - B2;
      D3 := C3 - B3;
      D4 := C4 - B4;

      Result := D1 * CN_GB18030_4CHAR_PAGE_COUNT1 + D2 * CN_GB18030_4CHAR_PAGE_COUNT2
        + D3 * CN_GB18030_4CHAR_PAGE_COUNT3 + D4 + UBase;
    end
    else
    begin
      // ��˸����ֽڱ�
      UBase := F4GB18030ToUnicodeMap.Find(Integer(GBCP));
      if UBase > 0 then
        Result := UBase;
    end;
  end;
end;

function GetGB18030FromUnicodeCodePoint(UCP: TCnCodePoint): TCnCodePoint;
var
  I, GBBase, UBase: TCnCodePoint;
  A1, A2, B1, B2, B3, B4, C1, C2, C3, C4: Byte;
  D1, D2, D3, D4: Cardinal;
begin
  Result := CN_INVALID_CODEPOINT;

  if UCP < $80 then
    Result := UCP
  else // ���� Unicode ��Χ���Ȳ��������䣬�ٲ� Map
  begin
    // ��˫�ֽ������
    UBase := 0;
    GBBase := 0;

    for I := Low(CN_GB18030_2CHAR_PAGES) to High(CN_GB18030_2CHAR_PAGES) do
    begin
      if (UCP >= CN_GB18030_2CHAR_PAGES[I].UHead) and (UCP <= CN_GB18030_2CHAR_PAGES[I].UTail) then
      begin
        UBase := CN_GB18030_2CHAR_PAGES[I].UHead;
        GBBase := CN_GB18030_2CHAR_PAGES[I].GBHead;
        Break;
      end;
    end;

    if UBase > 0 then
    begin
      // ���˫�ֽ�����㣿
      UCP := UCP - UBase;

      A1 := UCP div 94;
      A2 := UCP mod 94;

      B1 := (GBBase and $0000FF00) shr 8;
      B2 := GBBase and $000000FF;

      D1 := A1 + B1;
      D2 := A2 + B2;
      if D2 > $FE then
      begin
        Dec(D2, 94);
        Inc(D1);
      end;

      Result := (D1 shl 8) + D2;
    end
    else // �����ֽ������
    begin
      GBBase := 0;
      UBase := 0;

      for I := Low(CN_GB18030_4CHAR_PAGES) to High(CN_GB18030_4CHAR_PAGES) do
      begin
        if (UCP >= CN_GB18030_4CHAR_PAGES[I].UHead) and (UCP <= CN_GB18030_4CHAR_PAGES[I].UTail) then
        begin
          UBase := CN_GB18030_4CHAR_PAGES[I].UHead;
          GBBase := CN_GB18030_4CHAR_PAGES[I].GBHead;
          Break;
        end;
      end;

      if GBBase > 0 then
      begin
        // ���ֽ������
        UCP := UCP - UBase;
        C1 := UCP div 12600;
        C2 := (UCP - 12600 * C1) div 1260;
        C3 := (UCP - 12600 * C1- 1260 * C2) div 10;
        C4 := UCP - 12600 * C1- 1260 * C2 - 10 * C3;

        ExtractGB18030CodePoint(GBBase, B1, B2, B3, B4);

        A1 := UnsignedAddWithLimitRadix(C4, B4, $0, D4, $30, $39);  // ���λ��ӣ���λ������ʹ��
        A1 := UnsignedAddWithLimitRadix(C3, B3, A1, D3, $81, $FE);  // �ε�λ��ӣ���λ������ʹ��
        A1 := UnsignedAddWithLimitRadix(C2, B2, A1, D2, $30, $39);
        A1 := UnsignedAddWithLimitRadix(C1, B1, A1, D1, $81, $FE);  // ���λ��ӣ���Ӧ�н�λ

        if A1 = 0 then
          Result := CombineGB18030CodePoint(D1, D2, D3, D4);     // ƴ�����
      end;
    end;

    if Result = CN_INVALID_CODEPOINT then
    begin
      // ����ϳɵĴ��
      GBBase := FUnicodeToGB18030Map.Find(Integer(UCP));
      if GBBase > 0 then
        Result := GBBase;
    end;
  end;
end;

function GetGB18030FromUtf16(Utf16Str: PWideChar): TCnGB18030String;
var
  L: Integer;
begin
  L := Utf16ToGB18030(Utf16Str, nil);
  if L > 0 then
  begin
    SetLength(Result, L);
    Utf16ToGB18030(Utf16Str, @Result[1]);
  end;
end;

{$IFDEF UNICODE}

function GetUtf16FromGB18030(GB18030Str: TCnGB18030String): string;
var
  L: Integer;
begin
  L := GB18030ToUtf16(PCnGB18030StringPtr(GB18030Str), nil);
  if L > 0 then
  begin
    SetLength(Result, L);
    GB18030ToUtf16(PCnGB18030StringPtr(GB18030Str), @Result[1]);
  end;
end;

{$ELSE}

function GetUtf16FromGB18030(GB18030Str: TCnGB18030String): WideString;
var
  L: Integer;
begin
  L := GB18030ToUtf16(PCnGB18030StringPtr(GB18030Str), nil);
  if L > 0 then
  begin
    SetLength(Result, L);
    GB18030ToUtf16(PCnGB18030StringPtr(GB18030Str), @Result[1]);
  end;
end;

{$ENDIF}

function GetCodePointFromGB18030Char(PtrToGB18030Chars: PCnGB18030StringPtr): TCnCodePoint;
var
  C1, C2, C3, C4: Byte;
begin
  Result := CN_INVALID_CODEPOINT;

  C1 := Byte(PtrToGB18030Chars^);
  if C1 < $80 then
    Result := C1                                // ���ֽ�
  else if (C1 >= $81) and (C1 <= $FE) then
  begin
    Inc(PtrToGB18030Chars);
    C2 := Byte(PtrToGB18030Chars^);
    if ((C2 >= $40) and (C2 <= $7E)) or ((C2 >= $90) and (C2 <= $FE)) then
      Result := C1 shl 8 + C2                   // ˫�ֽ�
    else if (C2 >= $30) and (C2 <= $39) then    // ���ֽ�
    begin
      Inc(PtrToGB18030Chars);
      C3 := Byte(PtrToGB18030Chars^);
      Inc(PtrToGB18030Chars);
      C4 := Byte(PtrToGB18030Chars^);

      // ���ж����ֽڵ� 81 �� FE �Լ����ֽڵ� 30 �� 39
      if (C3 >= $81) and (C3 <= $FE) and (C4 >= $30) and (C4 <= $39) then
        Result := CombineGB18030CodePoint(C1, C2, C3, C4);
    end;
  end;
end;

function GetGB18030CharsFromCodePoint(CP: TCnCodePoint; PtrToChars: Pointer): Integer;
var
  P: PByte;
  C1, C2, C3, C4: Byte;
begin
  Result := 0;
  P := PByte(PtrToChars);
  if CP < $80 then
  begin
    if P <> nil then
      P^ := Byte(CP);
    Result := 1;
  end
  else
  begin
    ExtractGB18030CodePoint(CP, C1, C2, C3, C4);

    if (C1 = 0) and (C2 = 0) and ((C3 >= $81) and (C3 <= $FE)) and
      (((C4 >= $40) and (C4 <= $7E)) or ((C4 >= $80) and (C4 <= $FE))) then
    begin
      // �����ֽ��ַ�
      if P <> nil then
      begin
        P^ := C3;
        Inc(P);
        P^ := C4;
      end;
      Result := 2;
    end
    else if ((C1 >= $81) and (C1 <= $FE)) and ((C2 >= $30) and (C2 <= $39))
      and ((C3 >= $81) and (C3 <= $FE)) and ((C4 >= $30) and (C4 <= $39)) then
    begin
      // �����ֽ��ַ�
      if P <> nil then
      begin
        P^ := C1;
        Inc(P);
        P^ := C2;
        Inc(P);
        P^ := C3;
        Inc(P);
        P^ := C4;
      end;
      Result := 4;
    end;
  end;
end;

initialization
  CreateGB18030ToUnicodeMap;
  CreateUnicodeToGB18030Map;
  CreateUnicodeDuplicateMap;

finalization
  F2GB18030ToUnicodeMap.Free;
  F4GB18030ToUnicodeMap.Free;
  FUnicodeToGB18030Map.Free;
  FUnicodeDuplicateMap.Free;

end.
