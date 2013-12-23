object frmReplaceColour: TfrmReplaceColour
  Left = 338
  Top = 116
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Replace Colour'
  ClientHeight = 492
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    394
    492)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 449
    Width = 385
    Height = 10
    Anchors = [akLeft, akBottom]
    Shape = bsBottomLine
  end
  object TopLabel: TLabel
    Left = 168
    Top = 8
    Width = 225
    Height = 41
    AutoSize = False
    Caption = 
      'Select a colour form the left for the replace colour and then th' +
      'e replace with colour'
    WordWrap = True
  end
  object LabelL1: TLabel
    Left = 184
    Top = 380
    Width = 134
    Height = 13
    Caption = 'Colour Replacement Range:'
  end
  object LabelL2: TLabel
    Left = 184
    Top = 412
    Width = 29
    Height = 13
    Caption = 'From: '
  end
  object LabelL3: TLabel
    Left = 280
    Top = 412
    Width = 19
    Height = 13
    Caption = 'To: '
  end
  object PCGroup: TGroupBox
    Left = 168
    Top = 48
    Width = 225
    Height = 113
    Caption = 'Palette Conversion:'
    TabOrder = 13
    Visible = False
    object Label8: TLabel
      Left = 8
      Top = 24
      Width = 113
      Height = 13
      AutoSize = False
      Caption = 'Convert To Palette:'
    end
    object Button3: TButton
      Left = 152
      Top = 47
      Width = 67
      Height = 25
      Caption = 'Browse'
      TabOrder = 0
      OnClick = Button3Click
    end
    object FilenameText: TEdit
      Left = 8
      Top = 48
      Width = 137
      Height = 21
      AutoSize = False
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 1
      OnChange = FilenameTextChange
    end
  end
  object USCGroup: TGroupBox
    Left = 168
    Top = 48
    Width = 225
    Height = 321
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 9
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 73
      Height = 13
      Caption = 'Replace Colour'
    end
    object Label2: TLabel
      Left = 128
      Top = 8
      Width = 65
      Height = 13
      Caption = 'Replace With'
    end
    object LabC01: TLabel
      Left = 98
      Top = 24
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW01: TLabel
      Left = 192
      Top = 24
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC02: TLabel
      Left = 98
      Top = 40
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW02: TLabel
      Left = 192
      Top = 40
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC03: TLabel
      Left = 98
      Top = 56
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW03: TLabel
      Left = 192
      Top = 56
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC04: TLabel
      Left = 98
      Top = 72
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW04: TLabel
      Left = 192
      Top = 72
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC05: TLabel
      Left = 98
      Top = 88
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW05: TLabel
      Left = 192
      Top = 88
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC06: TLabel
      Left = 98
      Top = 104
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW06: TLabel
      Left = 192
      Top = 104
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC07: TLabel
      Left = 98
      Top = 120
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW07: TLabel
      Left = 192
      Top = 120
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC08: TLabel
      Left = 98
      Top = 136
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW08: TLabel
      Left = 192
      Top = 136
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC09: TLabel
      Left = 98
      Top = 152
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW09: TLabel
      Left = 192
      Top = 152
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC10: TLabel
      Left = 98
      Top = 168
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW10: TLabel
      Left = 192
      Top = 168
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC11: TLabel
      Left = 98
      Top = 184
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW11: TLabel
      Left = 192
      Top = 184
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC12: TLabel
      Left = 98
      Top = 200
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW12: TLabel
      Left = 192
      Top = 200
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC13: TLabel
      Left = 98
      Top = 216
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW13: TLabel
      Left = 192
      Top = 216
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC14: TLabel
      Left = 98
      Top = 232
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW14: TLabel
      Left = 192
      Top = 232
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC15: TLabel
      Left = 98
      Top = 248
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW15: TLabel
      Left = 192
      Top = 248
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC17: TLabel
      Left = 98
      Top = 280
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW17: TLabel
      Left = 192
      Top = 280
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC18: TLabel
      Left = 98
      Top = 296
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabW18: TLabel
      Left = 192
      Top = 296
      Width = 30
      Height = 13
      AutoSize = False
    end
    object LabC16: TLabel
      Left = 98
      Top = 264
      Width = 30
      Height = 17
      AutoSize = False
    end
    object LabW16: TLabel
      Left = 192
      Top = 264
      Width = 30
      Height = 13
      AutoSize = False
    end
    object PanC1: TPanel
      Left = 32
      Top = 24
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 0
      OnClick = PanW1Click
    end
    object PanW1: TPanel
      Left = 128
      Top = 24
      Width = 57
      Height = 17
      TabOrder = 1
      OnClick = PanW1Click
    end
    object CheckBox1: TCheckBox
      Left = 8
      Top = 24
      Width = 17
      Height = 17
      TabOrder = 2
      OnClick = CheckBox1Click
    end
    object CheckBox2: TCheckBox
      Left = 8
      Top = 40
      Width = 17
      Height = 17
      TabOrder = 3
      OnClick = CheckBox2Click
    end
    object CheckBox3: TCheckBox
      Left = 8
      Top = 56
      Width = 17
      Height = 17
      TabOrder = 4
      OnClick = CheckBox3Click
    end
    object CheckBox4: TCheckBox
      Left = 8
      Top = 72
      Width = 17
      Height = 17
      TabOrder = 5
      OnClick = CheckBox4Click
    end
    object CheckBox5: TCheckBox
      Left = 8
      Top = 88
      Width = 17
      Height = 17
      TabOrder = 6
    end
    object PanC2: TPanel
      Left = 32
      Top = 40
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 7
      OnClick = PanW1Click
    end
    object PanW2: TPanel
      Left = 128
      Top = 40
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 8
      OnClick = PanW1Click
    end
    object PanC3: TPanel
      Left = 32
      Top = 56
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 9
      OnClick = PanW1Click
    end
    object PanW3: TPanel
      Left = 128
      Top = 56
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 10
      OnClick = PanW1Click
    end
    object PanC4: TPanel
      Left = 32
      Top = 72
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 11
      OnClick = PanW1Click
    end
    object PanW4: TPanel
      Left = 128
      Top = 72
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 12
      OnClick = PanW1Click
    end
    object PanC5: TPanel
      Left = 32
      Top = 88
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 13
      OnClick = PanW1Click
    end
    object PanW5: TPanel
      Left = 128
      Top = 88
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 14
      OnClick = PanW1Click
    end
    object PanC6: TPanel
      Left = 32
      Top = 104
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 15
      OnClick = PanW1Click
    end
    object PanW6: TPanel
      Left = 128
      Top = 104
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 16
      OnClick = PanW1Click
    end
    object PanC7: TPanel
      Left = 32
      Top = 120
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 17
      OnClick = PanW1Click
    end
    object PanW7: TPanel
      Left = 128
      Top = 120
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 18
      OnClick = PanW1Click
    end
    object PanC8: TPanel
      Left = 32
      Top = 136
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 19
      OnClick = PanW1Click
    end
    object PanW8: TPanel
      Left = 128
      Top = 136
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 20
      OnClick = PanW1Click
    end
    object PanC9: TPanel
      Left = 32
      Top = 152
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 21
      OnClick = PanW1Click
    end
    object PanW9: TPanel
      Left = 128
      Top = 152
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 22
      OnClick = PanW1Click
    end
    object PanC10: TPanel
      Left = 32
      Top = 168
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 23
      OnClick = PanW1Click
    end
    object PanW10: TPanel
      Left = 128
      Top = 168
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 24
      OnClick = PanW1Click
    end
    object PanC11: TPanel
      Left = 32
      Top = 184
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 25
      OnClick = PanW1Click
    end
    object PanW11: TPanel
      Left = 128
      Top = 184
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 26
      OnClick = PanW1Click
    end
    object PanC12: TPanel
      Left = 32
      Top = 200
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 27
      OnClick = PanW1Click
    end
    object PanW12: TPanel
      Left = 128
      Top = 200
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 28
      OnClick = PanW1Click
    end
    object PanC13: TPanel
      Left = 32
      Top = 216
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 29
      OnClick = PanW1Click
    end
    object PanW13: TPanel
      Left = 128
      Top = 216
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 30
      OnClick = PanW1Click
      OnExit = CheckBox13Click
    end
    object PanC14: TPanel
      Left = 32
      Top = 232
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 31
      OnClick = PanW1Click
    end
    object PanW14: TPanel
      Left = 128
      Top = 232
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 32
      OnClick = PanW1Click
    end
    object PanC15: TPanel
      Left = 32
      Top = 248
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 33
      OnClick = PanW1Click
    end
    object PanW15: TPanel
      Left = 128
      Top = 248
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 34
      OnClick = PanW1Click
    end
    object PanC16: TPanel
      Left = 32
      Top = 264
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 35
      OnClick = PanW1Click
    end
    object PanW16: TPanel
      Left = 128
      Top = 264
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 36
      OnClick = PanW1Click
    end
    object PanC17: TPanel
      Left = 32
      Top = 280
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 37
      OnClick = PanW1Click
    end
    object PanW17: TPanel
      Left = 128
      Top = 280
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 38
      OnClick = PanW1Click
    end
    object PanC18: TPanel
      Left = 32
      Top = 296
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 39
      OnClick = PanW1Click
    end
    object PanW18: TPanel
      Left = 128
      Top = 296
      Width = 57
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 41
      OnClick = PanW1Click
    end
    object CheckBox6: TCheckBox
      Left = 8
      Top = 104
      Width = 17
      Height = 17
      TabOrder = 43
      OnClick = CheckBox6Click
    end
    object CheckBox7: TCheckBox
      Left = 8
      Top = 120
      Width = 17
      Height = 17
      TabOrder = 45
      OnClick = CheckBox7Click
    end
    object CheckBox8: TCheckBox
      Left = 8
      Top = 136
      Width = 17
      Height = 17
      TabOrder = 47
      OnClick = CheckBox8Click
    end
    object CheckBox9: TCheckBox
      Left = 8
      Top = 152
      Width = 17
      Height = 17
      TabOrder = 49
      OnClick = CheckBox9Click
    end
    object CheckBox10: TCheckBox
      Left = 8
      Top = 168
      Width = 17
      Height = 17
      TabOrder = 51
      OnClick = CheckBox10Click
    end
    object CheckBox11: TCheckBox
      Left = 8
      Top = 184
      Width = 17
      Height = 17
      TabOrder = 53
      OnClick = CheckBox11Click
    end
    object CheckBox12: TCheckBox
      Left = 8
      Top = 200
      Width = 17
      Height = 17
      TabOrder = 40
      OnClick = CheckBox12Click
    end
    object CheckBox13: TCheckBox
      Left = 8
      Top = 216
      Width = 17
      Height = 17
      TabOrder = 42
      OnClick = CheckBox13Click
    end
    object CheckBox14: TCheckBox
      Left = 8
      Top = 232
      Width = 17
      Height = 17
      TabOrder = 44
      OnClick = CheckBox14Click
    end
    object CheckBox15: TCheckBox
      Left = 8
      Top = 248
      Width = 17
      Height = 17
      TabOrder = 46
      OnClick = CheckBox15Click
    end
    object CheckBox16: TCheckBox
      Left = 8
      Top = 264
      Width = 17
      Height = 17
      TabOrder = 48
      OnClick = CheckBox16Click
    end
    object CheckBox17: TCheckBox
      Left = 8
      Top = 280
      Width = 17
      Height = 17
      TabOrder = 50
      OnClick = CheckBox17Click
    end
    object CheckBox18: TCheckBox
      Left = 8
      Top = 296
      Width = 17
      Height = 17
      TabOrder = 52
      OnClick = CheckBox18Click
    end
  end
  object BCEGroup: TGroupBox
    Left = 168
    Top = 48
    Width = 225
    Height = 117
    Caption = 'Ammount:'
    TabOrder = 10
    Visible = False
    object Label4: TLabel
      Left = 8
      Top = 21
      Width = 33
      Height = 13
      AutoSize = False
      Caption = 'Red:'
    end
    object Label5: TLabel
      Left = 8
      Top = 45
      Width = 33
      Height = 13
      AutoSize = False
      Caption = 'Green:'
    end
    object Label6: TLabel
      Left = 8
      Top = 69
      Width = 41
      Height = 13
      AutoSize = False
      Caption = 'Blue:'
    end
    object SpinRed: TSpinEdit
      Left = 48
      Top = 16
      Width = 57
      Height = 22
      MaxValue = 255
      MinValue = -255
      TabOrder = 0
      Value = 0
      OnChange = SpinRedChange
    end
    object SpinGreen: TSpinEdit
      Left = 48
      Top = 40
      Width = 57
      Height = 22
      MaxValue = 255
      MinValue = -255
      TabOrder = 1
      Value = 0
      OnChange = SpinRedChange
    end
    object SpinBlue: TSpinEdit
      Left = 48
      Top = 64
      Width = 57
      Height = 22
      MaxValue = 255
      MinValue = -255
      TabOrder = 2
      Value = 0
      OnChange = SpinRedChange
    end
    object Panel2: TPanel
      Left = 112
      Top = 8
      Width = 105
      Height = 105
      BevelOuter = bvLowered
      TabOrder = 3
      Visible = False
      object cnvPreview24B: TPaintBox
        Left = 1
        Top = 1
        Width = 103
        Height = 103
        Align = alClient
        Color = clBtnFace
        ParentColor = False
        OnPaint = cnvPreview24BPaint
      end
    end
    object AutoProof: TCheckBox
      Left = 8
      Top = 88
      Width = 97
      Height = 17
      Caption = 'Auto Proof'
      TabOrder = 4
    end
  end
  object ApplyToAll: TCheckBox
    Left = 184
    Top = 433
    Width = 153
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Apply To All Frames'
    TabOrder = 1
    OnClick = ApplyToAllClick
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 469
    Width = 225
    Height = 16
    Anchors = [akLeft, akBottom]
    TabOrder = 2
    Visible = False
  end
  object SpeFrom: TSpinEdit
    Left = 216
    Top = 408
    Width = 57
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 5
    Value = 1
  end
  object SpeTo: TSpinEdit
    Left = 304
    Top = 408
    Width = 57
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 6
    Value = 1
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 304
    Width = 153
    Height = 97
    Caption = 'Replacement Options:'
    TabOrder = 7
    object ropUSC: TRadioButton
      Left = 8
      Top = 24
      Width = 137
      Height = 17
      Caption = 'Use Selected Colours'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = ropUSCClick
    end
    object rop24BCE: TRadioButton
      Left = 8
      Top = 48
      Width = 121
      Height = 17
      Caption = '24 Bit Colour Effects'
      TabOrder = 1
      OnClick = rop24BCEClick
    end
    object ropPC: TRadioButton
      Left = 8
      Top = 72
      Width = 113
      Height = 17
      Caption = 'Palette Conversion'
      TabOrder = 2
      OnClick = ropPCClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 408
    Width = 153
    Height = 49
    Caption = 'Replacement Range:'
    TabOrder = 8
    object RRselectedonly: TCheckBox
      Left = 8
      Top = 24
      Width = 137
      Height = 17
      Caption = 'Replace Selected Only'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = SpinRedChange
    end
  end
  object Button1: TButton
    Left = 240
    Top = 465
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 320
    Top = 465
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 153
    Height = 290
    BevelOuter = bvLowered
    TabOrder = 0
    object cnvPalette: TPaintBox
      Left = 1
      Top = 1
      Width = 151
      Height = 288
      Align = alClient
      OnMouseUp = cnvPaletteMouseUp
      OnPaint = cnvPalettePaint
    end
  end
  object CCMGroup: TGroupBox
    Left = 168
    Top = 272
    Width = 225
    Height = 97
    Caption = 'Select your Colour Conversion Method:'
    TabOrder = 11
    Visible = False
    object CCM3DRGBColourPlus: TRadioButton
      Left = 40
      Top = 46
      Width = 145
      Height = 17
      Caption = '3D RGB Full Diff. Colour+'
      TabOrder = 0
    end
    object CCM3DRGBFD: TRadioButton
      Left = 40
      Top = 24
      Width = 145
      Height = 17
      Caption = '3D RGB Full Difference'
      TabOrder = 1
    end
    object CCMStructuralis: TRadioButton
      Left = 40
      Top = 68
      Width = 137
      Height = 17
      Caption = '3D RGB Structuralis'
      TabOrder = 2
    end
  end
  object CTSGroup: TGroupBox
    Left = 168
    Top = 164
    Width = 225
    Height = 109
    Caption = 'Colours To Spare:'
    TabOrder = 12
    Visible = False
    object SpareColourLabel: TLabel
      Left = 40
      Top = 56
      Width = 32
      Height = 13
      Alignment = taCenter
      AutoSize = False
    end
    object Label3: TLabel
      Left = 8
      Top = 84
      Width = 6
      Height = 13
      Caption = '+'
    end
    object Label7: TLabel
      Left = 56
      Top = 84
      Width = 35
      Height = 13
      Caption = 'Colours'
    end
    object AddCTS: TButton
      Left = 8
      Top = 16
      Width = 81
      Height = 17
      Caption = 'Add'
      TabOrder = 0
      OnClick = AddCTSClick
    end
    object RemoveCTS: TButton
      Left = 8
      Top = 32
      Width = 81
      Height = 17
      Caption = 'Remove'
      TabOrder = 1
      OnClick = RemoveCTSClick
    end
    object SpareColourPanel: TPanel
      Left = 10
      Top = 56
      Width = 23
      Height = 17
      BevelOuter = bvLowered
      TabOrder = 2
    end
    object SpinCTS: TSpinEdit
      Left = 16
      Top = 80
      Width = 41
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 3
      Value = 0
    end
    object ColoursToSpareList: TListBox
      Left = 96
      Top = 8
      Width = 121
      Height = 97
      ItemHeight = 13
      TabOrder = 4
    end
  end
  object OpenPalette: TOpenDialog
    Filter = 'RA2 & TS Palettes/JASC Pal|*.pal'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 208
    Top = 128
  end
  object XPManifest: TXPManifest
    Left = 352
    Top = 376
  end
end
