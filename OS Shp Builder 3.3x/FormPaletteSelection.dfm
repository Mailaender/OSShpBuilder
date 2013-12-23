object FrmPaletteSelection: TFrmPaletteSelection
  Left = 342
  Top = 284
  BorderIcons = [biSystemMenu]
  Caption = 'Select Colour'
  ClientHeight = 279
  ClientWidth = 151
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
  object Panel1: TPanel
    Left = -2
    Top = -2
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
end
