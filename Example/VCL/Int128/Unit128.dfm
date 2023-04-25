object Form128: TForm128
  Left = 241
  Top = 225
  Width = 756
  Height = 435
  Caption = 'Int128 & UInt128'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnSample1: TButton
    Left = 8
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Sample 1'
    TabOrder = 0
    OnClick = btnSample1Click
  end
  object grpInt128: TGroupBox
    Left = 8
    Top = 8
    Width = 721
    Height = 153
    Caption = 'Int128'
    TabOrder = 1
    object lblHex128A: TLabel
      Left = 8
      Top = 48
      Width = 32
      Height = 13
      Caption = 'A Hex:'
    end
    object lblHex128B: TLabel
      Left = 8
      Top = 80
      Width = 32
      Height = 13
      Caption = 'B Hex:'
    end
    object bvl1: TBevel
      Left = 414
      Top = 48
      Width = 25
      Height = 65
      Shape = bsLeftLine
    end
    object btn128Add: TSpeedButton
      Left = 648
      Top = 48
      Width = 23
      Height = 22
      Caption = '+'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btn128AddClick
    end
    object btn128Sub: TSpeedButton
      Left = 648
      Top = 76
      Width = 23
      Height = 22
      Caption = '-'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btn128SubClick
    end
    object btn128Mul: TSpeedButton
      Left = 680
      Top = 48
      Width = 23
      Height = 22
      Caption = '*'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btn128MulClick
    end
    object btn128Div: TSpeedButton
      Left = 680
      Top = 76
      Width = 23
      Height = 22
      Caption = '/'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btn128DivClick
    end
    object btn128Shl: TSpeedButton
      Left = 56
      Top = 20
      Width = 23
      Height = 22
      Caption = '<'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btn128ShlClick
    end
    object btn128Shr: TSpeedButton
      Left = 88
      Top = 20
      Width = 23
      Height = 22
      Caption = '>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btn128ShrClick
    end
    object bvl2: TBevel
      Left = 190
      Top = 48
      Width = 25
      Height = 65
      Shape = bsLeftLine
    end
    object lblHex128r: TLabel
      Left = 8
      Top = 120
      Width = 33
      Height = 13
      Caption = 'R Hex:'
    end
    object bvl21: TBevel
      Left = 526
      Top = 56
      Width = 25
      Height = 65
      Shape = bsLeftLine
    end
    object edt128A: TEdit
      Left = 56
      Top = 48
      Width = 585
      Height = 23
      BiDiMode = bdRightToLeft
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 0
      Text = '11111111222222223333333344444444'
    end
    object edt128B: TEdit
      Left = 56
      Top = 76
      Width = 585
      Height = 23
      BiDiMode = bdRightToLeft
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 1
      Text = '44444444555555556666666677777777'
    end
    object edt128R: TEdit
      Left = 56
      Top = 116
      Width = 585
      Height = 23
      BiDiMode = bdRightToLeft
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 2
    end
  end
  object grpUInt128: TGroupBox
    Left = 8
    Top = 168
    Width = 721
    Height = 177
    Caption = 'UInt128'
    TabOrder = 2
    object lblHexU128A: TLabel
      Left = 8
      Top = 48
      Width = 32
      Height = 13
      Caption = 'A Hex:'
    end
    object btnU128Shl: TSpeedButton
      Left = 56
      Top = 20
      Width = 23
      Height = 22
      Caption = '<'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btnU128ShlClick
    end
    object btnU128Shr: TSpeedButton
      Left = 88
      Top = 20
      Width = 23
      Height = 22
      Caption = '>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btnU128ShrClick
    end
    object btnU128Add: TSpeedButton
      Left = 648
      Top = 48
      Width = 23
      Height = 22
      Caption = '+'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btnU128AddClick
    end
    object btnU128Mul: TSpeedButton
      Left = 680
      Top = 48
      Width = 23
      Height = 22
      Caption = '*'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btnU128MulClick
    end
    object btnU128Div: TSpeedButton
      Left = 680
      Top = 76
      Width = 23
      Height = 22
      Caption = '/'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btnU128DivClick
    end
    object btnU128Sub: TSpeedButton
      Left = 648
      Top = 76
      Width = 23
      Height = 22
      Caption = '-'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = btnU128SubClick
    end
    object lblHexU128B: TLabel
      Left = 8
      Top = 80
      Width = 32
      Height = 13
      Caption = 'B Hex:'
    end
    object bvl4: TBevel
      Left = 190
      Top = 48
      Width = 25
      Height = 65
      Shape = bsLeftLine
    end
    object bvl5: TBevel
      Left = 414
      Top = 48
      Width = 25
      Height = 65
      Shape = bsLeftLine
    end
    object lblHexU128R: TLabel
      Left = 8
      Top = 120
      Width = 33
      Height = 13
      Caption = 'R Hex:'
    end
    object bvl22: TBevel
      Left = 526
      Top = 48
      Width = 25
      Height = 65
      Shape = bsLeftLine
    end
    object edtU128A: TEdit
      Left = 56
      Top = 48
      Width = 585
      Height = 23
      BiDiMode = bdRightToLeft
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 0
      Text = '22222222333333334444444455555555'
    end
    object edtU128B: TEdit
      Left = 56
      Top = 76
      Width = 585
      Height = 23
      BiDiMode = bdRightToLeft
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 1
      Text = 'FFFFFFFF333333335555555566666666'
    end
    object edtU128R: TEdit
      Left = 56
      Top = 116
      Width = 585
      Height = 23
      BiDiMode = bdRightToLeft
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 2
    end
  end
  object btnSample2: TButton
    Left = 96
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Sample 2'
    TabOrder = 3
    OnClick = btnSample2Click
  end
  object btnSample3: TButton
    Left = 184
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Sample 3'
    TabOrder = 4
    OnClick = btnSample3Click
  end
  object btnSample4: TButton
    Left = 280
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Sample 4'
    TabOrder = 5
    OnClick = btnSample4Click
  end
  object btnSample5: TButton
    Left = 376
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Sample 5'
    TabOrder = 6
    OnClick = btnSample5Click
  end
  object btnSample6: TButton
    Left = 464
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Sample6'
    TabOrder = 7
    OnClick = btnSample6Click
  end
end
