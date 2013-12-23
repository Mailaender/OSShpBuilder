object FrmMirrorSHP: TFrmMirrorSHP
  Left = 0
  Top = 0
  Caption = 'Mirror SHP'
  ClientHeight = 178
  ClientWidth = 318
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    318
    178)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel: TBevel
    Left = 0
    Top = 134
    Width = 321
    Height = 10
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 119
  end
  object GbEscope: TGroupBox
    Left = 8
    Top = 8
    Width = 302
    Height = 120
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Mirror The Following Frames :'
    TabOrder = 0
    object LbFrom: TLabel
      Left = 24
      Top = 66
      Width = 27
      Height = 13
      Caption = 'From '
    end
    object LbTo: TLabel
      Left = 120
      Top = 66
      Width = 12
      Height = 13
      Caption = 'To'
    end
    object RbAll: TRadioButton
      Left = 24
      Top = 24
      Width = 113
      Height = 17
      Caption = 'All'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object RbRange: TRadioButton
      Left = 24
      Top = 40
      Width = 241
      Height = 17
      Caption = 'Only The Ones In The Range Below:'
      TabOrder = 1
    end
    object SpeFrom: TSpinEdit
      Left = 57
      Top = 63
      Width = 56
      Height = 22
      MaxValue = 1
      MinValue = 1
      TabOrder = 2
      Value = 1
      OnChange = SpeFromChange
    end
    object SpeTo: TSpinEdit
      Left = 138
      Top = 63
      Width = 56
      Height = 22
      MaxValue = 1
      MinValue = 1
      TabOrder = 3
      Value = 1
      OnChange = SpeToChange
    end
    object RbCurrent: TRadioButton
      Left = 24
      Top = 91
      Width = 161
      Height = 17
      Caption = 'Only The Current Frame'
      TabOrder = 4
    end
  end
  object BtOK: TButton
    Left = 248
    Top = 150
    Width = 62
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 176
    Top = 150
    Width = 62
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = BtCancelClick
  end
  object XPManifest: TXPManifest
    Left = 80
    Top = 152
  end
end
