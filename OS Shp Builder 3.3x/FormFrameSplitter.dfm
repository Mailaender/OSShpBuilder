object FrmFrameSplitter: TFrmFrameSplitter
  Left = 275
  Top = 215
  BorderIcons = [biSystemMenu]
  Caption = 'Frame Splitter'
  ClientHeight = 160
  ClientWidth = 363
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
    Caption = 'Split Frame:'
  end
  object Label2: TLabel
    Left = 16
    Top = 40
    Width = 153
    Height = 13
    AutoSize = False
    Caption = 'Divide Horizontally by:'
  end
  object Label3: TLabel
    Left = 16
    Top = 64
    Width = 153
    Height = 13
    AutoSize = False
    Caption = 'Divide Vertically by:'
  end
  object Bevel1: TBevel
    Left = 16
    Top = 112
    Width = 337
    Height = 9
    Shape = bsBottomLine
  end
  object Label4: TLabel
    Left = 16
    Top = 88
    Width = 153
    Height = 13
    AutoSize = False
    Caption = 'Order by:'
  end
  object Label5: TLabel
    Left = 280
    Top = 16
    Width = 81
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'Frame Size:'
  end
  object SpeFrameNum: TSpinEdit
    Left = 184
    Top = 8
    Width = 89
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 0
    Value = 1
  end
  object SpeHorizontal: TSpinEdit
    Left = 184
    Top = 32
    Width = 89
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 1
    Value = 1
    OnChange = SpeHorizontalChange
  end
  object SpeVertical: TSpinEdit
    Left = 184
    Top = 56
    Width = 89
    Height = 22
    MaxValue = 1
    MinValue = 1
    TabOrder = 2
    Value = 1
    OnChange = SpeVerticalChange
  end
  object EdWidth: TEdit
    Left = 296
    Top = 32
    Width = 49
    Height = 21
    Color = clMenu
    ReadOnly = True
    TabOrder = 3
  end
  object EdHeight: TEdit
    Left = 296
    Top = 56
    Width = 49
    Height = 21
    Color = clMenu
    ReadOnly = True
    TabOrder = 4
  end
  object ComboOrder: TComboBox
    Left = 184
    Top = 80
    Width = 89
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 5
    Text = 'Horizontal'
    Items.Strings = (
      'Horizontal'
      'Vertical')
  end
  object Button1: TButton
    Left = 280
    Top = 128
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 6
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 192
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = Button2Click
  end
  object XPManifest: TXPManifest
    Left = 168
    Top = 80
  end
end
