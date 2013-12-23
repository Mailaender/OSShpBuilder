object FrmCanvasResize: TFrmCanvasResize
  Left = 103
  Top = 202
  BorderIcons = [biSystemMenu]
  Caption = 'Canvas Resize'
  ClientHeight = 330
  ClientWidth = 333
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
    333
    330)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 45
    Top = 248
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Caption = 'Top: '
  end
  object Label2: TLabel
    Left = 208
    Top = 248
    Width = 21
    Height = 13
    Alignment = taRightJustify
    Caption = 'Left:'
  end
  object Label3: TLabel
    Left = 29
    Top = 272
    Width = 39
    Height = 13
    Alignment = taRightJustify
    Caption = 'Bottom: '
  end
  object Label4: TLabel
    Left = 196
    Top = 272
    Width = 31
    Height = 13
    Alignment = taRightJustify
    Caption = 'Right: '
  end
  object Bevel1: TBevel
    Left = 0
    Top = 290
    Width = 329
    Height = 10
    Anchors = [akLeft, akBottom]
    Shape = bsBottomLine
  end
  object PaintAreaPanel: TPanel
    Left = 0
    Top = 0
    Width = 332
    Height = 233
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 329
      Height = 233
    end
  end
  object SpinT: TSpinEdit
    Left = 80
    Top = 242
    Width = 57
    Height = 22
    MaxValue = 10000
    MinValue = -10000
    TabOrder = 1
    Value = 0
    OnChange = SpinTChange
  end
  object SpinB: TSpinEdit
    Left = 80
    Top = 266
    Width = 57
    Height = 22
    MaxValue = 10000
    MinValue = -10000
    TabOrder = 2
    Value = 0
    OnChange = SpinBChange
  end
  object SpinL: TSpinEdit
    Left = 240
    Top = 242
    Width = 57
    Height = 22
    MaxValue = 10000
    MinValue = -10000
    TabOrder = 3
    Value = 0
    OnChange = SpinLChange
  end
  object SpinR: TSpinEdit
    Left = 240
    Top = 266
    Width = 57
    Height = 22
    MaxValue = 10000
    MinValue = -10000
    TabOrder = 4
    Value = 0
    OnChange = SpinRChange
  end
  object BtnOK: TButton
    Left = 168
    Top = 305
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    TabOrder = 5
    OnClick = BtnOKClick
  end
  object BtnCancel: TButton
    Left = 251
    Top = 305
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = BtnCancelClick
  end
  object XPManifest: TXPManifest
    Left = 56
    Top = 304
  end
end
