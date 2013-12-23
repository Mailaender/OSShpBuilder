object FrmSequence: TFrmSequence
  Left = 276
  Top = 146
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSizeToolWin
  Caption = 'Sequence Maker'
  ClientHeight = 606
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 688
    Height = 587
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 185
      Height = 585
      Align = alLeft
      TabOrder = 0
      object Label1: TLabel
        Left = 1
        Top = 105
        Width = 183
        Height = 13
        Align = alTop
        Caption = 'Advanced Controls'
        Color = clBtnHighlight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        ExplicitWidth = 90
      end
      object Panel6: TPanel
        Left = 1
        Top = 177
        Width = 183
        Height = 384
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblTools: TLabel
          Left = 0
          Top = 0
          Width = 183
          Height = 13
          Align = alTop
          Caption = ' INI Code'
          Color = clBtnHighlight
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          ExplicitWidth = 45
        end
        object INI_Code: TRichEdit
          Left = 16
          Top = 21
          Width = 153
          Height = 356
          BevelInner = bvNone
          BevelOuter = bvNone
          Color = clBtnFace
          PlainText = True
          PopupMenu = PopupMenu1
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          WantReturns = False
          WordWrap = False
        end
      end
      object Panel7: TPanel
        Left = 1
        Top = 1
        Width = 183
        Height = 104
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Label3: TLabel
          Left = 8
          Top = 48
          Width = 29
          Height = 21
          AutoSize = False
          Caption = 'Frame'
          Layout = tlCenter
        end
        object Label4: TLabel
          Left = 104
          Top = 48
          Width = 13
          Height = 21
          AutoSize = False
          Caption = 'To'
          Layout = tlCenter
        end
        object Label5: TLabel
          Left = 0
          Top = 0
          Width = 183
          Height = 13
          Align = alTop
          Caption = ' Sequence'
          Color = clBtnHighlight
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          ExplicitWidth = 52
        end
        object ComboBoxEx1: TComboBoxEx
          Left = 16
          Top = 19
          Width = 161
          Height = 22
          ItemsEx = <
            item
              Caption = 'Ready'
            end
            item
              Caption = 'Guard'
            end
            item
              Caption = 'Prone'
            end
            item
              Caption = 'Down'
            end
            item
              Caption = 'Crawl'
            end
            item
              Caption = 'Walk'
            end
            item
              Caption = 'Up'
            end
            item
              Caption = 'Idle1'
            end
            item
              Caption = 'Idle2'
            end
            item
              Caption = 'Die1'
            end
            item
              Caption = 'Die2'
            end
            item
              Caption = 'Die3'
            end
            item
              Caption = 'Die4'
            end
            item
              Caption = 'Die5'
            end
            item
              Caption = 'FireUp'
            end
            item
              Caption = 'FireProne'
            end
            item
              Caption = 'Paradrop'
            end
            item
              Caption = 'Cheer'
            end
            item
              Caption = 'Panic'
            end
            item
              Caption = 'Deployed'
            end
            item
              Caption = 'DeployedFire'
            end
            item
              Caption = 'Undeploy'
            end
            item
              Caption = 'Fly'
            end
            item
              Caption = 'Hover'
            end
            item
              Caption = 'Tumble'
            end
            item
              Caption = 'FireFly'
            end>
          ItemHeight = 16
          TabOrder = 0
          Text = 'Action'
          OnChange = ComboBoxEx1Change
        end
        object From_Frame: TSpinEdit
          Left = 48
          Top = 48
          Width = 49
          Height = 22
          MaxLength = 100
          MaxValue = 0
          MinValue = 0
          TabOrder = 1
          Value = 0
          OnChange = From_FrameChange
        end
        object To_Frame: TSpinEdit
          Left = 128
          Top = 48
          Width = 49
          Height = 22
          MaxLength = 100
          MaxValue = 0
          MinValue = 0
          TabOrder = 2
          Value = 0
        end
        object Button1: TButton
          Left = 128
          Top = 80
          Width = 49
          Height = 17
          Caption = 'Edit'
          TabOrder = 3
          OnClick = Button1Click
        end
      end
      object Panel8: TPanel
        Left = 1
        Top = 118
        Width = 183
        Height = 59
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object Label2: TLabel
          Left = 8
          Top = 8
          Width = 41
          Height = 21
          AutoSize = False
          Caption = 'Count2'
          Layout = tlCenter
        end
        object Label6: TLabel
          Left = 8
          Top = 32
          Width = 41
          Height = 17
          AutoSize = False
          Caption = 'Special'
          Layout = tlCenter
        end
        object Count2Edit: TSpinEdit
          Left = 56
          Top = 8
          Width = 49
          Height = 22
          MaxLength = 1
          MaxValue = 6
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
        object SpecialEdit: TEdit
          Left = 56
          Top = 32
          Width = 49
          Height = 21
          TabOrder = 1
        end
        object Button2: TButton
          Left = 128
          Top = 35
          Width = 51
          Height = 17
          Caption = 'Edit'
          TabOrder = 2
          OnClick = Button2Click
        end
      end
    end
    object Panel3: TPanel
      Left = 186
      Top = 1
      Width = 501
      Height = 585
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object ScrollBox1: TScrollBox
        Left = 0
        Top = 241
        Width = 501
        Height = 344
        HorzScrollBar.Tracking = True
        VertScrollBar.Tracking = True
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        DragMode = dmAutomatic
        TabOrder = 0
        object Frame_Image_List: TImage
          Left = 0
          Top = 0
          Width = 501
          Height = 306
          AutoSize = True
        end
        object ScrollBar1: TScrollBar
          Left = 0
          Top = 328
          Width = 501
          Height = 16
          Align = alBottom
          PageSize = 0
          TabOrder = 0
          OnChange = ScrollBar1Change
        end
      end
      object ScrollBox2: TScrollBox
        Left = 0
        Top = 32
        Width = 501
        Height = 177
        HorzScrollBar.Tracking = True
        VertScrollBar.Tracking = True
        Align = alTop
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        TabOrder = 1
        object Sequence_Image: TImage
          Left = 0
          Top = 0
          Width = 501
          Height = 161
          AutoSize = True
        end
        object ScrollBar2: TScrollBar
          Left = 0
          Top = 161
          Width = 501
          Height = 16
          Align = alBottom
          PageSize = 0
          TabOrder = 0
          OnChange = ScrollBar2Change
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 501
        Height = 32
        Align = alTop
        Caption = 'Sequence'
        TabOrder = 2
      end
      object Panel5: TPanel
        Left = 0
        Top = 209
        Width = 501
        Height = 32
        Align = alTop
        Caption = 'Frame List'
        TabOrder = 3
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 587
    Width = 688
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object MainMenu1: TMainMenu
    Left = 40
    Top = 256
    object File1: TMenuItem
      Caption = 'File'
      object OpenAnimationSequence1: TMenuItem
        Caption = 'Load'
        OnClick = OpenAnimationSequence1Click
      end
      object SaveAnimationSequence1: TMenuItem
        Caption = 'Save'
        OnClick = SaveAnimationSequence1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Reset1: TMenuItem
        Caption = 'Reset Animations'
        OnClick = Reset1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object SaveSequence1: TMenuItem
        Caption = 'Save Sequence As Image'
        OnClick = SaveSequence1Click
      end
      object SaveFrameListAsBMP1: TMenuItem
        Caption = 'Save Frame List As Image'
        OnClick = SaveFrameListAsBMP1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Sequence1: TMenuItem
      Caption = 'Sequence'
      object Options1: TMenuItem
        Caption = 'Preferences'
        OnClick = Options1Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object FrameList1: TMenuItem
        Caption = 'Frame List'
        Checked = True
        OnClick = Preview1Click
      end
      object Preview1: TMenuItem
        Caption = 'Preview'
        OnClick = Preview1Click
      end
    end
  end
  object SaveSequencePictureDialog: TSavePictureDialog
    DefaultExt = 'bmp'
    Filter = 
      'All Supported Graphics|*.bmp;*.jpg;*.jpeg;*.pcx;*.gif;*.tga;*.pn' +
      'g|Bitmap|*.bmp|JPG|*.jpg;*.jpeg|PCX|*.pcx|GIF|*.gif|TGA|*.tga|PN' +
      'G|*.png'
    Left = 72
    Top = 192
  end
  object Refresh_Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Refresh_TimerTimer
    Left = 8
    Top = 224
  end
  object PopupMenu1: TPopupMenu
    Left = 8
    Top = 256
    object Copy1: TMenuItem
      Caption = 'Copy Selection'
      OnClick = Copy1Click
    end
  end
  object SequenceTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = SequenceTimerTimer
    Left = 40
    Top = 224
  end
  object OpenASFDialog: TOpenDialog
    DefaultExt = 'shpasf'
    Filter = 'OS Animation Sequence File (*.shpasf)|*.shpasf'
    Left = 8
    Top = 192
  end
  object SaveASFDialog: TSaveDialog
    DefaultExt = 'shpasf'
    Filter = 'OS Animation Sequence File (*.shpasf)|*.shpasf'
    Left = 40
    Top = 192
  end
  object XPManifest: TXPManifest
    Left = 72
    Top = 224
  end
end
