object FormLockFree: TFormLockFree
  Left = 192
  Top = 107
  Width = 979
  Height = 563
  Caption = 'Lock Free Containers'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnTestNoCritical: TButton
    Left = 32
    Top = 32
    Width = 89
    Height = 25
    Caption = 'Test No Critical'
    TabOrder = 0
    OnClick = btnTestNoCriticalClick
  end
  object btnTestCritical: TButton
    Left = 144
    Top = 32
    Width = 89
    Height = 25
    Caption = 'Test Critical'
    TabOrder = 1
    OnClick = btnTestCriticalClick
  end
  object btnTestSysCritical: TButton
    Left = 256
    Top = 32
    Width = 89
    Height = 25
    Caption = 'Test Sys Critical'
    TabOrder = 2
    OnClick = btnTestSysCriticalClick
  end
  object btnTestLockFreeLinkedList: TButton
    Left = 504
    Top = 32
    Width = 233
    Height = 25
    Caption = 'Test Lock-Free LinkedList Append in Threads'
    TabOrder = 3
    OnClick = btnTestLockFreeLinkedListClick
  end
  object btnTestLockFreeInsert: TButton
    Left = 784
    Top = 32
    Width = 153
    Height = 25
    Caption = 'Lock Free Linked List Insert'
    TabOrder = 4
    OnClick = btnTestLockFreeInsertClick
  end
  object btnLockFreeLinkedListInsert: TButton
    Left = 504
    Top = 72
    Width = 233
    Height = 25
    Caption = 'Test Lock-Free LinkedList Insert in Threads'
    TabOrder = 5
    OnClick = btnLockFreeLinkedListInsertClick
  end
  object mmoLinkedListResult: TMemo
    Left = 504
    Top = 128
    Width = 233
    Height = 369
    Lines.Strings = (
      '')
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object btnLockFreeLinkedListInsertDelete: TButton
    Left = 184
    Top = 72
    Width = 297
    Height = 25
    Caption = 'Test Lock-Free LinkedList Insert and Delete in Threads'
    TabOrder = 7
    OnClick = btnLockFreeLinkedListInsertDeleteClick
  end
  object btnTestIncDec: TButton
    Left = 32
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Test Inc Dec'
    TabOrder = 8
    OnClick = btnTestIncDecClick
  end
  object rgIncDec: TRadioGroup
    Left = 32
    Top = 120
    Width = 89
    Height = 137
    Caption = 'Inc Dec'
    ItemIndex = 0
    Items.Strings = (
      'Inc 32'
      'Dec 32'
      'Inc 64'
      'Dec 64')
    TabOrder = 9
  end
  object btnTestSingleRing: TButton
    Left = 184
    Top = 128
    Width = 297
    Height = 25
    Caption = 'Test Single Read Write Ring Queue'
    TabOrder = 10
    OnClick = btnTestSingleRingClick
  end
  object btnTestPushAndPop: TButton
    Left = 184
    Top = 184
    Width = 297
    Height = 25
    Caption = 'Test Lock-Free Link Stack Push And Pop'
    TabOrder = 11
    OnClick = btnTestPushAndPopClick
  end
end
