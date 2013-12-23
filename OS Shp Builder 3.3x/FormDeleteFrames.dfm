object FrmDeleteFrames: TFrmDeleteFrames
  Left = 356
  Top = 294
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Delete Frames...'
  ClientHeight = 164
  ClientWidth = 178
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    178
    164)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 32
    Width = 26
    Height = 13
    Caption = 'From:'
  end
  object Label2: TLabel
    Left = 16
    Top = 64
    Width = 16
    Height = 13
    Caption = 'To:'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 114
    Width = 177
    Height = 17
    Anchors = [akLeft, akBottom]
    Shape = bsBottomLine
  end
  object spFrom: TSpinEdit
    Left = 56
    Top = 24
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 0
    OnClick = spFromClick
  end
  object spTo: TSpinEdit
    Left = 56
    Top = 56
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
    OnClick = spToClick
  end
  object BtOK: TButton
    Left = 112
    Top = 138
    Width = 59
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Ok'
    TabOrder = 2
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 48
    Top = 138
    Width = 59
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = BtCancelClick
  end
  object CbShadow: TCheckBox
    Left = 16
    Top = 96
    Width = 145
    Height = 17
    Caption = 'Delete Shadow Frames'
    TabOrder = 4
    OnClick = CbShadowClick
  end
  object BtToOne: TButton
    Left = 128
    Top = 24
    Width = 25
    Height = 25
    Caption = '<<'
    TabOrder = 5
    OnClick = BtToOneClick
  end
  object BtToEnd: TButton
    Left = 128
    Top = 56
    Width = 25
    Height = 25
    Caption = '>>'
    TabOrder = 6
    OnClick = BtToEndClick
  end
  object XPManifest: TXPManifest
    Left = 8
    Top = 136
  end
end
