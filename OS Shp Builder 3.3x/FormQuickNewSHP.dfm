object FrmQuickNewSHP: TFrmQuickNewSHP
  Left = 248
  Top = 211
  BorderIcons = []
  Caption = 'Quick New SHP Settings:'
  ClientHeight = 127
  ClientWidth = 213
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    213
    127)
  PixelsPerInch = 96
  TextHeight = 13
  object OK: TButton
    Left = 129
    Top = 96
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = OKClick
  end
  object Cancel: TButton
    Left = 49
    Top = 96
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = CancelClick
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 209
    Height = 89
    Caption = 'SHP Game Settings'
    TabOrder = 2
    object Label4: TLabel
      Left = 8
      Top = 28
      Width = 31
      Height = 13
      Caption = 'Game:'
    end
    object Label5: TLabel
      Left = 8
      Top = 56
      Width = 27
      Height = 13
      Caption = 'Type:'
    end
    object CbxGame: TComboBoxEx
      Left = 64
      Top = 19
      Width = 65
      Height = 22
      ItemsEx = <
        item
          Caption = 'TD'
          ImageIndex = 24
          SelectedImageIndex = 24
        end
        item
          Caption = 'RA1'
          ImageIndex = 23
          SelectedImageIndex = 23
        end
        item
          Caption = 'TS'
          ImageIndex = 0
          SelectedImageIndex = 0
        end
        item
          Caption = 'RA2'
          ImageIndex = 2
          SelectedImageIndex = 2
        end>
      ItemHeight = 16
      TabOrder = 0
      OnChange = CbxGameChange
    end
    object CbxType: TComboBoxEx
      Left = 64
      Top = 51
      Width = 81
      Height = 22
      ItemsEx = <>
      ItemHeight = 16
      TabOrder = 1
    end
  end
  object XPManifest: TXPManifest
    Left = 160
    Top = 8
  end
end
