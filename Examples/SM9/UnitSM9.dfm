object FormSM9: TFormSM9
  Left = 232
  Top = 180
  Width = 979
  Height = 563
  Caption = 'SM9 Test'
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
  object pgcSM9: TPageControl
    Left = 8
    Top = 8
    Width = 953
    Height = 513
    ActivePage = tsFP2
    TabOrder = 0
    object tsFP2: TTabSheet
      Caption = 'FP2'
      object grpFP2: TGroupBox
        Left = 8
        Top = 8
        Width = 929
        Height = 465
        Caption = 'FP2'
        TabOrder = 0
        object btnTestFP2: TButton
          Left = 16
          Top = 24
          Width = 75
          Height = 25
          Caption = 'Test FP2'
          TabOrder = 0
          OnClick = btnTestFP2Click
        end
        object mmoFP2: TMemo
          Left = 16
          Top = 72
          Width = 897
          Height = 377
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
    end
    object tsFP4: TTabSheet
      Caption = 'FP4'
      ImageIndex = 1
      object grpFP4: TGroupBox
        Left = 8
        Top = 8
        Width = 929
        Height = 465
        Caption = 'FP4'
        TabOrder = 0
        object btnTestFp4: TButton
          Left = 16
          Top = 24
          Width = 75
          Height = 25
          Caption = 'Test FP4'
          TabOrder = 0
          OnClick = btnTestFp4Click
        end
        object mmoFP4: TMemo
          Left = 16
          Top = 72
          Width = 897
          Height = 377
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
    end
    object tsFP12: TTabSheet
      Caption = 'FP12'
      ImageIndex = 2
      object grpFP12: TGroupBox
        Left = 8
        Top = 8
        Width = 929
        Height = 465
        Caption = 'FP12'
        TabOrder = 0
        object btnTestFP12: TButton
          Left = 16
          Top = 24
          Width = 75
          Height = 25
          Caption = 'Test FP12'
          TabOrder = 0
          OnClick = btnTestFP12Click
        end
        object mmoFP12: TMemo
          Left = 16
          Top = 72
          Width = 897
          Height = 377
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
    end
    object tsAffinePoint: TTabSheet
      Caption = 'Affine Point'
      ImageIndex = 3
      object grpAP: TGroupBox
        Left = 8
        Top = 8
        Width = 929
        Height = 465
        Caption = 'Affine Point'
        TabOrder = 0
        object btnAP: TButton
          Left = 16
          Top = 24
          Width = 89
          Height = 25
          Caption = 'Test Affine Point'
          TabOrder = 0
          OnClick = btnAPClick
        end
        object mmoAP: TMemo
          Left = 16
          Top = 72
          Width = 897
          Height = 377
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
    end
  end
end