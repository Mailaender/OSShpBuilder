object FrmMoveFrames: TFrmMoveFrames
  Left = 472
  Top = 339
  BorderIcons = []
  Caption = 'Move Frames...'
  ClientHeight = 362
  ClientWidth = 203
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    203
    362)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 26
    Height = 13
    Caption = 'From:'
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 16
    Height = 13
    Caption = 'To:'
  end
  object Label3: TLabel
    Left = 8
    Top = 64
    Width = 56
    Height = 13
    Caption = 'Destination:'
  end
  object Label4: TLabel
    Left = 24
    Top = 183
    Width = 62
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Paste At File:'
  end
  object Bevel1: TBevel
    Left = 5
    Top = 307
    Width = 196
    Height = 14
    Anchors = [akLeft, akBottom]
    Shape = bsBottomLine
  end
  object SpFrom: TSpinEdit
    Left = 72
    Top = 12
    Width = 65
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 0
    Value = 1
    OnClick = SpFromClick
  end
  object SpTo: TSpinEdit
    Left = 72
    Top = 36
    Width = 65
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 1
    OnClick = SpToClick
  end
  object BtGoToOne: TButton
    Left = 160
    Top = 16
    Width = 33
    Height = 25
    Hint = 'Go To First Frame'
    Caption = '<<'
    TabOrder = 2
    OnClick = BtGoToOneClick
  end
  object BtGoToEnd: TButton
    Left = 160
    Top = 48
    Width = 33
    Height = 25
    Hint = 'Go To Last Frame'
    Caption = '>>'
    TabOrder = 3
    OnClick = BtGoToEndClick
  end
  object SpDestiny: TSpinEdit
    Left = 72
    Top = 60
    Width = 65
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 4
    Value = 1
    OnClick = SpDestinyClick
  end
  object CbCopyShadows: TCheckBox
    Left = 32
    Top = 88
    Width = 153
    Height = 17
    Caption = 'Move Shadow Frames'
    TabOrder = 5
    OnClick = CbCopyShadowsClick
  end
  object GbResize: TGroupBox
    Left = 8
    Top = 112
    Width = 185
    Height = 65
    Caption = 'If Needed, Resize:'
    TabOrder = 6
    object RbPixels: TRadioButton
      Left = 16
      Top = 24
      Width = 129
      Height = 17
      Caption = 'Pixels (automatically)'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = RbPixelsClick
    end
    object RbCanvas: TRadioButton
      Left = 16
      Top = 40
      Width = 113
      Height = 17
      Caption = 'Canvas (manually)'
      TabOrder = 1
      OnClick = RbCanvasClick
    end
  end
  object LbPasteAtFile: TListBox
    Left = 8
    Top = 207
    Width = 185
    Height = 97
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    TabOrder = 7
    OnClick = LbPasteAtFileClick
  end
  object BtCancel: TButton
    Left = 78
    Top = 328
    Width = 57
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    TabOrder = 8
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 144
    Top = 328
    Width = 57
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    TabOrder = 9
    OnClick = BtOKClick
  end
  object XPManifest: TXPManifest
    Left = 136
    Top = 176
  end
end
