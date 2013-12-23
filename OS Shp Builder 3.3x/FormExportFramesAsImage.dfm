object FrmExportFramesAsImage: TFrmExportFramesAsImage
  Left = 0
  Top = 0
  Caption = 'Export Frames -> Image'
  ClientHeight = 111
  ClientWidth = 281
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    281
    111)
  PixelsPerInch = 96
  TextHeight = 13
  object lblFrom: TLabel
    Left = 8
    Top = 11
    Width = 61
    Height = 13
    Caption = 'From Frame:'
  end
  object lblTo: TLabel
    Left = 8
    Top = 39
    Width = 49
    Height = 13
    Caption = 'To Frame:'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 64
    Width = 269
    Height = 9
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 92
    ExplicitWidth = 225
  end
  object SpeFrom: TSpinEdit
    Left = 88
    Top = 8
    Width = 121
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 0
    Value = 1
    OnChange = SpeFromChange
  end
  object SpeTo: TSpinEdit
    Left = 88
    Top = 36
    Width = 121
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 1
    Value = 1
    OnChange = SpeToChange
  end
  object BtOK: TButton
    Left = 202
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 2
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 121
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = BtCancelClick
  end
  object BtToEnd: TButton
    Left = 232
    Top = 33
    Width = 25
    Height = 25
    Caption = '>>'
    TabOrder = 4
    OnClick = BtToEndClick
  end
  object BtToOne: TButton
    Left = 232
    Top = 8
    Width = 25
    Height = 25
    Caption = '<<'
    TabOrder = 5
    OnClick = BtToOneClick
  end
  object XPManifest: TXPManifest
    Left = 56
    Top = 80
  end
end
