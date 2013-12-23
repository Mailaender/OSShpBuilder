object FrmSelectDirectory: TFrmSelectDirectory
  Left = 507
  Top = 168
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Select A Directory'
  ClientHeight = 323
  ClientWidth = 249
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object ShellTreeView1: TShellTreeView
    Left = 8
    Top = 8
    Width = 233
    Height = 281
    ObjectTypes = [otFolders]
    Root = 'rfDesktop'
    UseShellImages = True
    AutoRefresh = True
    Indent = 19
    ParentColor = False
    RightClickSelect = True
    ShowRoot = False
    TabOrder = 0
  end
  object Button1: TButton
    Left = 168
    Top = 296
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
end
