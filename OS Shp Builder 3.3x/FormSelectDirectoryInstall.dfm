object FrmSelectDirectoryInstall: TFrmSelectDirectoryInstall
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Select Directory'
  ClientHeight = 346
  ClientWidth = 311
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    311
    346)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 279
    Height = 13
    Caption = 'Select the directory where OS SHP Builder will be installed.'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 303
    Width = 295
    Height = 10
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
  end
  object Drive: TDriveComboBox
    Left = 8
    Top = 31
    Width = 295
    Height = 19
    Anchors = [akLeft, akTop, akRight]
    DirList = Directory
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 228
    Top = 319
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 147
    Top = 319
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = BtCancelClick
  end
  object Directory: TDirectoryListBox
    Left = 8
    Top = 56
    Width = 295
    Height = 249
    ItemHeight = 16
    TabOrder = 3
  end
  object XPManifest: TXPManifest
    Left = 40
    Top = 320
  end
end
