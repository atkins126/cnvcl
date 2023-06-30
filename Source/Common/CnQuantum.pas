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

unit CnQuantum;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����ӻ�����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2023.06.27 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

{
  һ�����ӱ��أ���������̬�ĸ��ʲ��ĵ��ӡ����������������λ�Ȳ�����
  �ƺ�Ƶ����ȣ�����˵���ÿ���Ƶ�ʡ�

  ��ѧ�ϣ�һ�����ӱ�����һ����ά��ϵ��������Alpha �� 0 ̬�� Beta �� 1 ̬֮�ͣ�
  ������ϵ���Ǹ�������������ֵƽ����Ϊ 1�������ֵƽ����Ϊ��̬�ĸ��Ը��ʡ�
  ��ʾ��Ϊ�� Alpha �� Beta ���о���

  ���� a �� b ������������ά�ģ�������Ϊ�� |a|^2+|b|^2 = 1 ��Լ��������
  ���������ά�ռ䵥λ�������ϵĵ㣬�����ټ��Ϻ���ȫ����λ��������������ӳ�䵽��ά�ĵ�λ������

  ��Ϊ|a|^2+|b|^2=1�����Կ��� a Ϊһ��������ĳ�Ƕ� cos ֵ thita������Ƕ�����ĸ�����
  b Ϊһ��������ͬһ�Ƕȵ� sin ֵ������Ƕ��������һ���������������ǶȽ���ȫ����λ
  ����ȡ����ֵ��������Ƕ���ʧ��ֻʣ cos ƽ���� sin ƽ�������� 1��

  ����Ϊ a �� b ������ǶȵĴ��ڣ�����֮��ĽǶȲ���������λ phi����Χ�� 0 �� 2�С�
  ���Ʒ��ȵ��Ǹ��� thita����Χ�� 0 ���� �С�
  ��ˣ�ֻҪ�����ǣ�����ȷ�� a �� b��������һ����λ�Ǽ�һ�����Ǿ���ȷ�������ϵĵ㡣
  �ƺ���Ҫ�Ӹ�ǰ�᣺��ͬȫ����λ���迼�ǣ�������� a Ϊʵ����

  ���ǡ������ꡢ������������ a ���鲿Ϊ 0���Ķ�Ӧ��ϵ�����⣿

  a     1     0                                                                 (a)
  b = a 0 + b 1��Ҫ��֤���ⲽ�������㣬������⡣˵��������ӱ��صľ�����ʽ���� (b)

  Bloch ��Z �����������ϵ��ʾ��̬ 0�����µ��ʾ��̬ 1��XY��ǰ�������ĸ����Ǹ��� 2 ��֮һ�������С��������������ļ������塣

  �����ڻ�����⣬�������֮�ͣ��õ�һ�����֣���������
  ��������ڿ˻�������ֱ���������������Ǿ���˷�����������󣨰����������ĸ���˷�����չ����Ҳ������⡣

  һ�������������ĳ���������������ĳ����������ĳ����������ô�ⳣ�����������ͳ�Ϊ�þ������������������ֵ������⣬����֪����ɶ�á�

  ˫���ӱ���״̬�ľ���������⡣

  ���ӱ��صľ���任���Ǳ任�����������ӱ��ؾ���Ҳ�������������ң������һ��������
  ����һ�ж�ӦԪ�س���������ӦԪ�أ��õ�����Ķ�Ӧ��Ԫ��

}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Math, CnMath, CnComplex;

type
  ECnQuantumException = class(Exception);
  {* ������ѧ��ص��쳣}

  TCnQuBit = class(TPersistent)
  {* ����������̬ʵ����}
  private
    FAlpha: TCnComplexNumber;  // ���� a
    FBeta: TCnComplexNumber;   // ���� b
    FPhi: Extended;            // ��λ��ǣ�[0, 2��)
    FTheta: Extended;          // ���ǣ�[0, ��]��ʵ���г����� 2 �Է���ϰ��
    FX: Extended;              // Bloch ������ X ����
    FY: Extended;              // Bloch ������ Y ����
    FZ: Extended;              // Bloch ������ Z ����
    procedure CalcCoordinateFromAngle;
    procedure CalcAngleFromCoordinate;
    procedure CalcAngleFromComplex;
    procedure CalcComplexFromAngle;
    procedure CalcComplexFromCoordinate;
    procedure CalcCoordinateFromComplex;
    procedure SetAlpha(const Value: TCnComplexNumber);
    procedure SetBeta(const Value: TCnComplexNumber);
    procedure SetFX(const Value: Extended);
    procedure SetFY(const Value: Extended);
    procedure SetFZ(const Value: Extended);
    procedure SetPhi(const Value: Extended);
    procedure SetTheta(const Value: Extended);
  protected
    procedure UpdateFromComplex;
    procedure UpdateFromAngle;
    procedure UpdateFromCoordinate;

    procedure CheckValid;
    function ValidComplex: Boolean;
    {* �жϸ��ʺ��Ƿ�Ϊ 1}
    procedure ValidAngle;
    {* �������Ƕȹ���Ϊ�Ϸ���Χ��}
  public
    constructor Create(AR, AI, BR, BI: Extended); overload;
    constructor Create(APhi, ATheta: Extended); overload;
    constructor Create(AX, AY, AZ: Extended); overload;

    procedure Assign(Source: TPersistent); override;
    {* �������ӱ���}
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ַ���}

    property X: Extended read FX write SetFX;
    {* �����ӱ��ص��ڲ������ĵѿ�������ϵ�е� X ����}
    property Y: Extended read FY write SetFY;
    {* �����ӱ��ص��ڲ������ĵѿ�������ϵ�е� Y ����}
    property Z: Extended read FZ write SetFZ;
    {* �����ӱ��ص��ڲ������ĵѿ�������ϵ�е� Z ����}

    property Phi: Extended read FPhi write SetPhi;
    {* ��λ��ǣ����� a �� b �������ļнǣ���Χ�� [0, 2��)}
    property Theta: Extended read FTheta write SetTheta;
    {* ���ǣ����� a �� b �������ľ���ֵ���䣬��Χ�� [0, ��]��ʵ���г����� 2 �Է���ϰ��}

    property Alpha: TCnComplexNumber read FAlpha write SetAlpha;
    {* �����ӱ��صĵ�һ��������}
    property Beta: TCnComplexNumber read FBeta write SetBeta;
    {* �����ӱ��صĵڶ���������}
  end;

procedure CnQuBitMulMatrix(InQ, OutQ: TCnQuBit; var M00, M01, M10, M11: TCnComplexNumber); overload;
{* �����ӱ��ؽ��ж�ά�������㣬�����Ǹ�����InQ��OutQ ������ͬһ������
  00 ��������е���������Ԫ�أ�01 �������д��У�10 ����������У�11 ������д���}

procedure CnQuBitMulMatrix(InQ, OutQ: TCnQuBit; M00, M01, M10, M11: Extended); overload;
{* �����ӱ��ؽ��ж�ά�������㣬������ʵ����InQ��OutQ ������ͬһ������
  00 ��������е���������Ԫ�أ�01 �������д��У�10 ����������У�11 ������д���}

procedure CnQuBitHadamardGate(InQ, OutQ: TCnQuBit);
{* ���ӱ��� Hadamard �ű任}

procedure CnQuBitPauliXGate(InQ, OutQ: TCnQuBit);
{* ���ӱ������� X �ű任���൱�� NOT��Ҳ�� |0> �� |1> ��ϵ������}

procedure CnQuBitPauliYGate(InQ, OutQ: TCnQuBit);
{* ���ӱ������� Y �ű任}

procedure CnQuBitPauliZGate(InQ, OutQ: TCnQuBit);
{* ���ӱ������� Z �ű任����������״̬ |0> ���䣬���ҽ� |1> ��ϵ�����ɸ���}

procedure CnQuBitPhaseShiftGate(InQ, OutQ: TCnQuBit; ATheta: Extended);
{* ���ӱ�����λƫ���ű任����������״̬ |0> ���ҽ� |1> ��ϵ�����ɷ���Ϊ ATheta �ĵ�λģ��������}

var
  CnQuBitBaseZero: TCnQuBit = nil;
  CnQuBitBaseOne: TCnQuBit = nil;

implementation

resourcestring
  SCN_ERROR_QUBIT_AB_RANGE = 'A B Modulus Summary NOT Valid';
  SCN_ERROR_QUBIT_ANGLE_RANGE = 'Phi or Theta Angle NOT Valid';

{ TCnQuBit }

procedure TCnQuBit.Assign(Source: TPersistent);
begin
  if Source is TCnQuBit then
  begin
    FX := (Source as TCnQuBit).X;
    FY := (Source as TCnQuBit).Y;
    FZ := (Source as TCnQuBit).Z;

    FPhi := (Source as TCnQuBit).Phi;
    FTheta := (Source as TCnQuBit).Theta;

    ComplexNumberCopy(FAlpha, (Source as TCnQuBit).FAlpha);
    ComplexNumberCopy(FBeta, (Source as TCnQuBit).FBeta);
  end
  else
    inherited;
end;

procedure TCnQuBit.CalcAngleFromComplex;
var
  A: Extended;
begin
  CheckValid;

  A := ComplexNumberAbsolute(FAlpha);
  // B := ComplexNumberAbsolute(FBeta);

  FTheta := ArcCos(A) * 2; // ��Ϊ���� Valid �ж������ͬ�� ArcSin(B) * 2

  FPhi := ComplexNumberArgument(FBeta) - ComplexNumberArgument(FAlpha);
  if FPhi < 0 then
    FPhi := FPhi + CN_PI * 2;
end;

procedure TCnQuBit.CalcAngleFromCoordinate;
begin
  FTheta := ArcCos(FZ);
  FPhi := ArcCos(FX / Sin(FTheta));
end;

procedure TCnQuBit.CalcComplexFromAngle;
begin
  FAlpha.R := Cos(FTheta / 2);
  FAlpha.I := 0;

  FBeta.R := Sin(FTheta / 2) * Cos(FPhi);
  FBeta.I := Sin(FTheta / 2) * Sin(FPhi);
end;

procedure TCnQuBit.CalcComplexFromCoordinate;
begin
  CalcAngleFromCoordinate;
  CalcComplexFromAngle;
end;

procedure TCnQuBit.CalcCoordinateFromAngle;
begin
  FX := Sin(FTheta) * Cos(FPhi);
  FY := Sin(FTheta) * Sin(FPhi);
  FZ := Cos(FTheta);
end;

procedure TCnQuBit.CalcCoordinateFromComplex;
begin
  CalcAngleFromComplex;
  CalcCoordinateFromAngle;
end;

constructor TCnQuBit.Create(AR, AI, BR, BI: Extended);
begin
  inherited Create;
  FAlpha.R := AR;
  FAlpha.I := AI;
  FBeta.R := BR;
  FBeta.I := BI;

  UpdateFromComplex; // �����Ѿ������� CheckValid
end;

procedure TCnQuBit.CheckValid;
begin
  if not ValidComplex then
    raise ECnQuantumException.Create(SCN_ERROR_QUBIT_AB_RANGE);
end;

constructor TCnQuBit.Create(AX, AY, AZ: Extended);
begin
  inherited Create;
  FX := AX;
  FY := AY;
  FZ := AZ;

  UpdateFromCoordinate;
  CheckValid;
end;

constructor TCnQuBit.Create(APhi, ATheta: Extended);
begin
  inherited Create;
  FPhi := APhi;
  FTheta := ATheta;

  UpdateFromAngle;
  CheckValid;
end;

procedure TCnQuBit.SetAlpha(const Value: TCnComplexNumber);
begin
  FAlpha := Value;
  UpdateFromComplex;
end;

procedure TCnQuBit.SetBeta(const Value: TCnComplexNumber);
begin
  FBeta := Value;
  UpdateFromComplex;
end;

procedure TCnQuBit.SetFX(const Value: Extended);
begin
  FX := Value;
  UpdateFromCoordinate;
end;

procedure TCnQuBit.SetFY(const Value: Extended);
begin
  FY := Value;
  UpdateFromCoordinate;
end;

procedure TCnQuBit.SetFZ(const Value: Extended);
begin
  FZ := Value;
  UpdateFromCoordinate;
end;

procedure TCnQuBit.SetPhi(const Value: Extended);
begin
  FPhi := Value;
  UpdateFromAngle;
end;

procedure TCnQuBit.SetTheta(const Value: Extended);
begin
  FTheta := Value;
  UpdateFromAngle;
end;

function TCnQuBit.ToString: string;
begin
  Result := ComplexNumberToString(FAlpha) + '|0> + ' + ComplexNumberToString(FBeta) + '|1>';
end;

procedure TCnQuBit.UpdateFromAngle;
begin
  ValidAngle;

  CalcComplexFromAngle;
  CalcCoordinateFromAngle;
end;

procedure TCnQuBit.UpdateFromComplex;
begin
  CalcCoordinateFromComplex;
  // CalcAngleFromComplex;
end;

procedure TCnQuBit.UpdateFromCoordinate;
begin
  CalcComplexFromCoordinate;
  // CalcAngleFromCoordinate;
end;

function TCnQuBit.ValidComplex: Boolean;
begin
  Result := FloatEqual(FAlpha.R * FAlpha.R + FAlpha.I * FAlpha.I +
    FBeta.R * FBeta.R + FBeta.I * FBeta.I, 1);
end;

procedure TCnQuBit.ValidAngle;
begin
  // �� FPhi ��λ��������� [0, 2��)
  FPhi := NormalizeAngle(FPhi);

  // �� FTheta ���������� [0, ��]
  FTheta := NormalizeAngle(FTheta);

  if FTheta > CN_PI then
    raise ECnQuantumException.Create(SCN_ERROR_QUBIT_ANGLE_RANGE);
end;

procedure CnQuBitMulMatrix(InQ, OutQ: TCnQuBit; var M00, M01, M10, M11: TCnComplexNumber);
var
  T1, T2, T: TCnComplexNumber;
begin
  // OutQ.Alpha = M00 * InQ.Alpha + M01 * InQ.Beta
  // OutQ.Beta  = M10 * InQ.Alpha + M11 * InQ.Beta

  ComplexNumberMul(T1, InQ.FAlpha, M00);
  ComplexNumberMul(T2, InQ.FBeta,  M01);
  ComplexNumberAdd(T, T1, T2);

  ComplexNumberMul(T1, InQ.FAlpha, M10);
  ComplexNumberMul(T2, InQ.FBeta,  M11);

  ComplexNumberCopy(OutQ.FAlpha, T);
  ComplexNumberAdd(T, T1, T2);
  ComplexNumberCopy(OutQ.FBeta, T);

  OutQ.UpdateFromComplex;
end;

procedure CnQuBitMulMatrix(InQ, OutQ: TCnQuBit; M00, M01, M10, M11: Extended);
var
  C00, C01, C10, C11: TCnComplexNumber;
begin
  C00.R := M00;
  C01.R := M01;
  C10.R := M10;
  C11.R := M11;

  C00.I := 0;
  C01.I := 0;
  C10.I := 0;
  C11.I := 0;

  CnQuBitMulMatrix(InQ, OutQ, C00, C01, C10, C11);
end;

procedure CnQuBitHadamardGate(InQ, OutQ: TCnQuBit);
begin
  CnQuBitMulMatrix(InQ, OutQ, Sqrt(2)/2, Sqrt(2)/2, Sqrt(2)/2, -Sqrt(2)/2);
end;

procedure CnQuBitPauliXGate(InQ, OutQ: TCnQuBit);
begin
  CnQuBitMulMatrix(InQ, OutQ, 0, 1, 1, 0);
end;

procedure CnQuBitPauliYGate(InQ, OutQ: TCnQuBit);
begin
  CnQuBitMulMatrix(InQ, OutQ, CnComplexZero, CnComplexOneI, CnComplexNegOneI, CnComplexZero);
end;

procedure CnQuBitPauliZGate(InQ, OutQ: TCnQuBit);
begin
  CnQuBitMulMatrix(InQ, OutQ, 1, 0, 0, -1);
end;

procedure CnQuBitPhaseShiftGate(InQ, OutQ: TCnQuBit; ATheta: Extended);
var
  C: TCnComplexNumber;
begin
  ComplexNumberSetAbsoluteArgument(C, 1, ATheta);
  CnQuBitMulMatrix(InQ, OutQ, CnComplexOne, CnComplexZero, CnComplexZero, C);
end;

initialization
  CnQuBitBaseZero := TCnQuBit.Create(1, 0, 0, 0);
  CnQuBitBaseOne := TCnQuBit.Create(0, 0, 1, 0);

finalization
  CnQuBitBaseZero.Free;
  CnQuBitBaseOne.Free;

end.
