object FrmManualColourMatch: TFrmManualColourMatch
  Left = 192
  Top = 106
  Width = 397
  Height = 358
  Caption = 'Manual Colour Match'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 288
    Width = 377
    Height = 10
    Shape = bsBottomLine
  end
  object Image1: TImage
    Left = 168
    Top = 48
    Width = 217
    Height = 241
  end
  object Label1: TLabel
    Left = 168
    Top = 13
    Width = 38
    Height = 25
    AutoSize = False
    Caption = 'Original:'
    Layout = tlCenter
  end
  object Label2: TLabel
    Left = 280
    Top = 13
    Width = 38
    Height = 25
    AutoSize = False
    Caption = 'New:'
    Layout = tlCenter
  end
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 153
    Height = 281
    BevelOuter = bvLowered
    TabOrder = 0
    object cnvPalette: TPaintBox
      Left = 1
      Top = 1
      Width = 151
      Height = 279
      Align = alClient
      OnMouseUp = cnvPaletteMouseUp
      OnPaint = cnvPalettePaint
    end
  end
  object Button1: TButton
    Left = 312
    Top = 304
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Panel2: TPanel
    Left = 216
    Top = 13
    Width = 57
    Height = 25
    BevelOuter = bvLowered
    TabOrder = 2
  end
  object Panel3: TPanel
    Left = 328
    Top = 13
    Width = 57
    Height = 25
    BevelOuter = bvLowered
    TabOrder = 3
  end
  object Button2: TButton
    Left = 128
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Difference'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 208
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Backdoor'
    TabOrder = 5
    OnClick = Button3Click
  end
end
