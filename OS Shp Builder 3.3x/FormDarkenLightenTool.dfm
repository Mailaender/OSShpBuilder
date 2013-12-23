object frmdarkenlightentool: Tfrmdarkenlightentool
  Left = 378
  Top = 294
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Darken/Lighten Tool Settings'
  ClientHeight = 84
  ClientWidth = 254
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 224
    Height = 13
    Caption = 'Select the amount to lighten or darken a square'
  end
  object ComboBox1: TComboBox
    Left = 16
    Top = 24
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    Text = '1'
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5')
  end
  object Button1: TButton
    Left = 96
    Top = 56
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 176
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button2Click
  end
  object XPManifest: TXPManifest
    Left = 24
    Top = 56
  end
end
