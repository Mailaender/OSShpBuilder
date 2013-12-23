object FrmSpriteSheetExport: TFrmSpriteSheetExport
  Left = 619
  Top = 425
  Caption = 'Export Sprite Sheet Options'
  ClientHeight = 192
  ClientWidth = 369
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 153
    Height = 13
    AutoSize = False
    Caption = 'Starting Frame:'
  end
  object Label3: TLabel
    Left = 16
    Top = 88
    Width = 153
    Height = 13
    AutoSize = False
    Caption = 'Divide Vertically by:'
  end
  object Label4: TLabel
    Left = 16
    Top = 112
    Width = 153
    Height = 13
    AutoSize = False
    Caption = 'Order by:'
  end
  object Bevel1: TBevel
    Left = 16
    Top = 144
    Width = 337
    Height = 9
    Shape = bsBottomLine
  end
  object Label5: TLabel
    Left = 280
    Top = 64
    Width = 81
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'Frame Size:'
  end
  object Label6: TLabel
    Left = 16
    Top = 40
    Width = 153
    Height = 13
    AutoSize = False
    Caption = 'Final Frame:'
  end
  object Button2: TButton
    Left = 192
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 280
    Top = 160
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
  object ComboOrder: TComboBox
    Left = 184
    Top = 104
    Width = 89
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 2
    Text = 'Horizontal'
    Items.Strings = (
      'Horizontal'
      'Vertical')
  end
  object SpeVertical: TSpinEdit
    Left = 184
    Top = 80
    Width = 89
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 3
    Value = 1
    OnChange = SpeVerticalChange
  end
  object SpeFrameStartNum: TSpinEdit
    Left = 184
    Top = 8
    Width = 89
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 4
    Value = 1
    OnChange = SpeFrameStartNumChange
  end
  object EdWidth: TEdit
    Left = 296
    Top = 80
    Width = 49
    Height = 21
    Color = clMenu
    ReadOnly = True
    TabOrder = 5
  end
  object EdHeight: TEdit
    Left = 296
    Top = 104
    Width = 49
    Height = 21
    Color = clMenu
    ReadOnly = True
    TabOrder = 6
  end
  object SpeFrameEndNum: TSpinEdit
    Left = 184
    Top = 32
    Width = 89
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 7
    Value = 1
    OnChange = SpeFrameStartNumChange
  end
  object BtFirst: TButton
    Left = 296
    Top = 8
    Width = 25
    Height = 25
    Hint = 'Go to First Frame'
    Caption = '<<'
    TabOrder = 8
    OnClick = BtFirstClick
  end
  object BtLast: TButton
    Left = 296
    Top = 32
    Width = 25
    Height = 25
    Hint = 'Go to Last Frame'
    Caption = '>>'
    TabOrder = 9
    OnClick = BtLastClick
  end
  object XPManifest: TXPManifest
    Left = 104
    Top = 160
  end
end
