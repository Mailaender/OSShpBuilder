object FrmPreferences_Anim: TFrmPreferences_Anim
  Left = 192
  Top = 107
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = ' '
  ClientHeight = 179
  ClientWidth = 222
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
    Width = 80
    Height = 21
    AutoSize = False
    Caption = 'Animation Name:'
    Layout = tlCenter
  end
  object Label2: TLabel
    Left = 8
    Top = 64
    Width = 80
    Height = 21
    AutoSize = False
    Caption = 'Count:'
    Layout = tlCenter
  end
  object Label3: TLabel
    Left = 8
    Top = 88
    Width = 80
    Height = 21
    AutoSize = False
    Caption = 'Count2:'
    Layout = tlCenter
  end
  object Label4: TLabel
    Left = 8
    Top = 40
    Width = 80
    Height = 21
    AutoSize = False
    Caption = 'Start Frame:'
    Layout = tlCenter
  end
  object Label5: TLabel
    Left = 8
    Top = 112
    Width = 80
    Height = 21
    AutoSize = False
    Caption = 'Special:'
    Layout = tlCenter
  end
  object Bevel1: TBevel
    Left = 8
    Top = 144
    Width = 209
    Height = 9
    Shape = bsTopLine
  end
  object Name: TEdit
    Left = 96
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object Count: TSpinEdit
    Left = 96
    Top = 64
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
  end
  object Count2: TSpinEdit
    Left = 96
    Top = 88
    Width = 121
    Height = 22
    MaxLength = 1
    MaxValue = 6
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object StartFrame: TSpinEdit
    Left = 96
    Top = 40
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object Special: TEdit
    Left = 96
    Top = 112
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object Button1: TButton
    Left = 88
    Top = 152
    Width = 65
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 152
    Top = 152
    Width = 65
    Height = 25
    Caption = 'OK'
    TabOrder = 6
    OnClick = Button2Click
  end
  object XPManifest: TXPManifest
    Left = 32
    Top = 152
  end
end
