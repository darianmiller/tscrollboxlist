object ExampleForm: TExampleForm
  Left = 0
  Top = 0
  Caption = 'TScrollList Basic Functionality Test'
  ClientHeight = 766
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object panVariableHeight: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 385
    Align = alTop
    TabOrder = 0
    object ScrollBox1: TScrollBox
      Left = 1
      Top = 1
      Width = 622
      Height = 383
      Align = alClient
      TabOrder = 0
      TabStop = True
    end
  end
  object panFixedHeight: TPanel
    Left = 0
    Top = 385
    Width = 624
    Height = 381
    Align = alClient
    TabOrder = 1
    object ScrollBox2: TScrollBox
      Left = 1
      Top = 1
      Width = 622
      Height = 379
      Align = alClient
      TabOrder = 0
      TabStop = True
    end
  end
end
