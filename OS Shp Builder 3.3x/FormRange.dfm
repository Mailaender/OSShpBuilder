object FrmRange: TFrmRange
  Left = 301
  Top = 309
  BorderIcons = [biSystemMenu]
  Caption = 'Range'
  ClientHeight = 83
  ClientWidth = 262
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SpBegin: TSpinEdit
    Left = 8
    Top = 16
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 0
    OnEnter = SpBeginEnter
  end
  object SpEnd: TSpinEdit
    Left = 80
    Top = 16
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
    OnEnter = SpEndEnter
  end
  object Button1: TButton
    Left = 160
    Top = 16
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 48
    Width = 57
    Height = 25
    Caption = '<< Begin'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 80
    Top = 48
    Width = 57
    Height = 25
    Caption = 'Final >>'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 144
    Top = 48
    Width = 75
    Height = 25
    Caption = '<< Current >>'
    TabOrder = 5
    OnClick = Button4Click
  end
  object XPManifest: TXPManifest
    Left = 224
    Top = 48
  end
end
