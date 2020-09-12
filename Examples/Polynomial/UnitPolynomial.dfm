object FormPolynomial: TFormPolynomial
  Left = 241
  Top = 141
  Width = 955
  Height = 601
  Caption = 'Polynomial Test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pgcPoly: TPageControl
    Left = 8
    Top = 8
    Width = 929
    Height = 553
    ActivePage = tsExtensionEcc
    TabOrder = 0
    object tsIntegerPolynomial: TTabSheet
      Caption = 'Integer Polynomial'
      object grpIntegerPolynomial: TGroupBox
        Left = 8
        Top = 4
        Width = 905
        Height = 513
        Caption = 'Integer Polynomial'
        TabOrder = 0
        object bvl1: TBevel
          Left = 24
          Top = 68
          Width = 857
          Height = 17
          Shape = bsTopLine
        end
        object lblDeg1: TLabel
          Left = 816
          Top = 124
          Width = 38
          Height = 13
          Caption = 'Degree:'
        end
        object lblDeg2: TLabel
          Left = 816
          Top = 220
          Width = 38
          Height = 13
          Caption = 'Degree:'
        end
        object lblIPEqual: TLabel
          Left = 24
          Top = 256
          Width = 11
          Height = 20
          Caption = '='
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object bvl2: TBevel
          Left = 24
          Top = 292
          Width = 865
          Height = 17
          Shape = bsTopLine
        end
        object btnIPCreate: TButton
          Left = 24
          Top = 32
          Width = 75
          Height = 21
          Caption = 'To String'
          TabOrder = 0
          OnClick = btnIPCreateClick
        end
        object edtIP1: TEdit
          Left = 128
          Top = 32
          Width = 753
          Height = 21
          TabOrder = 1
        end
        object mmoIP1: TMemo
          Left = 24
          Top = 88
          Width = 777
          Height = 57
          ReadOnly = True
          TabOrder = 2
        end
        object mmoIP2: TMemo
          Left = 24
          Top = 184
          Width = 777
          Height = 57
          ReadOnly = True
          TabOrder = 3
        end
        object btnIP1Random: TButton
          Left = 816
          Top = 88
          Width = 75
          Height = 21
          Caption = 'Random'
          TabOrder = 4
          OnClick = btnIP1RandomClick
        end
        object btnIP2Random: TButton
          Left = 816
          Top = 184
          Width = 75
          Height = 21
          Caption = 'Random'
          TabOrder = 5
          OnClick = btnIP2RandomClick
        end
        object edtIPDeg1: TEdit
          Left = 864
          Top = 120
          Width = 25
          Height = 21
          TabOrder = 6
          Text = '9'
        end
        object edtIPDeg2: TEdit
          Left = 864
          Top = 216
          Width = 25
          Height = 21
          TabOrder = 7
          Text = '7'
        end
        object btnIPAdd: TButton
          Left = 88
          Top = 152
          Width = 75
          Height = 25
          Caption = 'Add'
          TabOrder = 8
          OnClick = btnIPAddClick
        end
        object btnIPSub: TButton
          Left = 192
          Top = 152
          Width = 75
          Height = 25
          Caption = 'Sub'
          TabOrder = 9
          OnClick = btnIPSubClick
        end
        object btnIPMul: TButton
          Left = 296
          Top = 152
          Width = 75
          Height = 25
          Caption = 'Mul'
          TabOrder = 10
          OnClick = btnIPMulClick
        end
        object btnIPDiv: TButton
          Left = 408
          Top = 152
          Width = 75
          Height = 25
          Caption = 'Div && Mod'
          TabOrder = 11
          OnClick = btnIPDivClick
        end
        object edtIP3: TEdit
          Left = 56
          Top = 256
          Width = 833
          Height = 21
          TabOrder = 12
        end
        object btnTestExample1: TButton
          Left = 24
          Top = 312
          Width = 113
          Height = 25
          Caption = 'Galois Test Point 1'
          TabOrder = 13
          OnClick = btnTestExample1Click
        end
        object btnTestExample2: TButton
          Left = 152
          Top = 312
          Width = 113
          Height = 25
          Caption = 'Galois Test Point 2'
          TabOrder = 14
          OnClick = btnTestExample2Click
        end
        object btnTestExample3: TButton
          Left = 280
          Top = 312
          Width = 113
          Height = 25
          Caption = 'Galois Test Power 3'
          TabOrder = 15
          OnClick = btnTestExample3Click
        end
        object btnTestExample4: TButton
          Left = 408
          Top = 312
          Width = 113
          Height = 25
          Caption = 'Galois Test Power 4'
          TabOrder = 16
          OnClick = btnTestExample4Click
        end
        object btnPolyGcd: TButton
          Left = 792
          Top = 312
          Width = 97
          Height = 25
          Caption = 'Test Poly Gcd'
          TabOrder = 17
          OnClick = btnPolyGcdClick
        end
        object btnGaloisTestGcd: TButton
          Left = 536
          Top = 312
          Width = 113
          Height = 25
          Caption = 'Galois Test GCD'
          TabOrder = 18
          OnClick = btnGaloisTestGcdClick
        end
        object btnTestGaloisMI: TButton
          Left = 664
          Top = 312
          Width = 113
          Height = 25
          Caption = 'Galois Test Inverse'
          TabOrder = 19
          OnClick = btnTestGaloisMIClick
        end
        object btnGF28Test1: TButton
          Left = 24
          Top = 360
          Width = 113
          Height = 25
          Caption = 'GF2^8 Test1'
          TabOrder = 20
          OnClick = btnGF28Test1Click
        end
      end
    end
    object tsExtensionEcc: TTabSheet
      Caption = 'Ecc on Galois'
      ImageIndex = 1
      object grpEccGalois: TGroupBox
        Left = 8
        Top = 4
        Width = 897
        Height = 509
        Caption = 'Ecc on Galois'
        TabOrder = 0
        object btnGaloisOnCurve: TButton
          Left = 24
          Top = 32
          Width = 129
          Height = 25
          Caption = 'Test 1 Point on Curve'
          TabOrder = 0
          OnClick = btnGaloisOnCurveClick
        end
        object btnEccPointAdd: TButton
          Left = 176
          Top = 32
          Width = 113
          Height = 25
          Caption = 'Test Point Add 1'
          TabOrder = 1
          OnClick = btnEccPointAddClick
        end
        object btnTestEccPointAdd2: TButton
          Left = 312
          Top = 32
          Width = 105
          Height = 25
          Caption = 'Test Point Add 2'
          TabOrder = 2
          OnClick = btnTestEccPointAdd2Click
        end
        object btnTestDivPoly: TButton
          Left = 440
          Top = 32
          Width = 177
          Height = 25
          Caption = 'Test Ecc Division Polynomial 1'
          TabOrder = 3
          OnClick = btnTestDivPolyClick
        end
        object btnTestDivPoly2: TButton
          Left = 640
          Top = 32
          Width = 177
          Height = 25
          Caption = 'Test Ecc Division Polynomial 2'
          TabOrder = 4
          OnClick = btnTestDivPoly2Click
        end
      end
    end
  end
end
