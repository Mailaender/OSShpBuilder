object FrmImportImageAsSHP: TFrmImportImageAsSHP
  Left = 193
  Top = 108
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Import Image as SHP'
  ClientHeight = 374
  ClientWidth = 368
  Color = clBtnFace
  TransparentColor = True
  TransparentColorValue = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    368
    374)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 324
    Width = 361
    Height = 14
    Anchors = [akLeft, akBottom]
    Shape = bsBottomLine
  end
  object BtOK: TButton
    Left = 232
    Top = 344
    Width = 65
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtOKClick
  end
  object Button3: TButton
    Left = 296
    Top = 344
    Width = 65
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button3Click
  end
  object FileListBox: TFileListBox
    Left = 184
    Top = 24
    Width = 17
    Height = 17
    ItemHeight = 13
    Mask = '*.bmp'
    TabOrder = 2
    Visible = False
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 348
    Width = 209
    Height = 16
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    Visible = False
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 353
    Height = 321
    ActivePage = TabSheet1
    TabOrder = 4
    object TabSheet1: TTabSheet
      Caption = 'Main'
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 311
        Height = 13
        Caption = 
          'Please enter the location of the first frame using the browse bu' +
          'tton'
      end
      object Label10: TLabel
        Left = 8
        Top = 72
        Width = 117
        Height = 13
        Caption = 'Optimize Conversion For:'
      end
      object Label11: TLabel
        Left = 8
        Top = 144
        Width = 109
        Height = 13
        Caption = 'Conversion Range:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label15: TLabel
        Left = 8
        Top = 224
        Width = 113
        Height = 13
        AutoSize = False
        Caption = 'Target:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LbTargetFrame: TLabel
        Left = 8
        Top = 268
        Width = 73
        Height = 13
        AutoSize = False
        Caption = 'Target Frame:'
        Enabled = False
      end
      object Label16: TLabel
        Left = 168
        Top = 268
        Width = 82
        Height = 13
        Caption = '(Start At Frame 1)'
      end
      object Button1: TButton
        Left = 280
        Top = 24
        Width = 60
        Height = 21
        Caption = 'Browse'
        TabOrder = 0
        OnClick = Button1Click
      end
      object Image_Location: TEdit
        Left = 8
        Top = 24
        Width = 265
        Height = 21
        Color = clSilver
        ReadOnly = True
        TabOrder = 1
      end
      object cbMode: TCheckBox
        Left = 8
        Top = 48
        Width = 225
        Height = 17
        Caption = 'View Only The First File Of The Package'
        TabOrder = 2
        OnClick = cbModeClick
      end
      object ConversionOptimizeBox: TPanel
        Left = 8
        Top = 88
        Width = 321
        Height = 57
        BevelOuter = bvNone
        TabOrder = 3
        DesignSize = (
          321
          57)
        object Label17: TLabel
          Left = 0
          Top = 4
          Width = 31
          Height = 13
          Caption = 'Game:'
        end
        object Label18: TLabel
          Left = 136
          Top = 4
          Width = 27
          Height = 13
          Caption = 'Type:'
        end
        object Label19: TLabel
          Left = 0
          Top = 28
          Width = 40
          Height = 13
          Caption = 'Theater:'
        end
        object ocfStyle: TComboBox
          Left = 48
          Top = 25
          Width = 273
          Height = 21
          AutoDropDown = True
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight, akBottom]
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = ocfStyleChange
        end
        object ocfComboOptions: TComboBox
          Left = 176
          Top = 1
          Width = 145
          Height = 21
          AutoDropDown = True
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight, akBottom]
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnChange = ocfComboOptionsChange
        end
        object CbxOptGame: TComboBoxEx
          Left = 48
          Top = 0
          Width = 81
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
            end
            item
              Caption = 'None'
              ImageIndex = 17
              SelectedImageIndex = 17
            end>
          ItemHeight = 16
          TabOrder = 2
          OnChange = CbxOptGameChange
          Images = SHPBuilderFrmMain.ImageList
        end
      end
      object ConversionRangeBox: TPanel
        Left = 8
        Top = 160
        Width = 145
        Height = 65
        BevelOuter = bvNone
        TabOrder = 4
        object Label3: TLabel
          Left = 56
          Top = 40
          Width = 13
          Height = 13
          Caption = 'To'
        end
        object crFrom: TSpinEdit
          Left = 0
          Top = 34
          Width = 49
          Height = 22
          MaxLength = 10
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 0
          OnChange = crFromChange
        end
        object crTo: TSpinEdit
          Left = 80
          Top = 34
          Width = 49
          Height = 22
          MaxLength = 10
          MaxValue = 0
          MinValue = 0
          TabOrder = 1
          Value = 0
          OnChange = crToChange
        end
        object crCustomFrames: TRadioButton
          Left = 0
          Top = 16
          Width = 113
          Height = 17
          Caption = 'Custom'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object crAllFrames: TRadioButton
          Left = 0
          Top = 0
          Width = 113
          Height = 17
          Caption = 'All frames'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          TabStop = True
        end
      end
      object CbTarget: TComboBox
        Left = 8
        Top = 240
        Width = 289
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        OnChange = CbTargetChange
      end
      object SpeTargetFrame: TSpinEdit
        Left = 104
        Top = 264
        Width = 57
        Height = 22
        Enabled = False
        MaxValue = 1
        MinValue = 1
        TabOrder = 6
        Value = 1
        OnChange = SpeTargetFrameChange
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Colours'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label8: TLabel
        Left = 8
        Top = 8
        Width = 150
        Height = 13
        Caption = 'Colour Conversion Method'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label9: TLabel
        Left = 8
        Top = 144
        Width = 109
        Height = 13
        Caption = 'Background Colour'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ColourConversionBox: TPanel
        Left = 16
        Top = 24
        Width = 329
        Height = 121
        BevelOuter = bvNone
        TabOrder = 0
        object ccmInfurion: TRadioButton
          Left = 0
          Top = 32
          Width = 313
          Height = 17
          Hint = 
            '3D RGB Infurium is the top notch colour conversion algorithm. It' +
            ' works like RGB Full Difference, but it also decides colours bas' +
            'ed on neighboorhod and the ammount of light close to it. For thi' +
            's reason, it does not use cache, which makes it the slowest and ' +
            'most memory consuming colour conversion method.'
          Caption = '3D RGB Infurium (top quality and very slow)'
          TabOrder = 0
        end
        object ccmBanshee3: TRadioButton
          Left = 0
          Top = 16
          Width = 313
          Height = 17
          Hint = 
            '3D RGB Full Difference Colour + is a method that treats the red,' +
            ' green and blue from the colours as a tridimensional cube. Tt ge' +
            'ts the colour with the smallest 3D distance between the choosen ' +
            'colour and the original colour. However, unlike 3D RGB Full Diff' +
            'erence, this method adds a priority factor for red, green and bl' +
            'ue, that modifies the results according to the ammount of red, g' +
            'reen and blue that the original colour has. The results are amaz' +
            'ing when the picture is light or has a considerable ammount of r' +
            'ed, green or blue. Dark pictures tends to get results similar to' +
            ' 3D RGB Full Difference.'
          Caption = '3D RGB Full Diff. Colour+ (fast and twisted)'
          TabOrder = 1
        end
        object ccmBanshee2: TRadioButton
          Left = 0
          Top = 0
          Width = 321
          Height = 17
          Hint = 
            'R+G+B Full Difference is a method that it gets the colour with t' +
            'he smallest result of the square root of the square of the sum o' +
            'f the diference between the file (R,G,B) and palette (R, G, B) c' +
            'ombined. It definitelly gets the best colours in 99% of the situ' +
            'ations and is heavly recommended to be used. This is a great imp' +
            'rovement of R+G+B Difference.'
          HelpType = htKeyword
          Caption = '3D RGB Full Difference (fastest and good: the Photoshop one)'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object ccmStructuralis: TRadioButton
          Left = 0
          Top = 48
          Width = 313
          Height = 17
          Hint = 
            '3D RGB Structuralis works similarly to 3D RGB Full Difference, b' +
            'ut it has an improved decision power based on the normal vector ' +
            'of the colour.'
          Caption = '3D RGB Structuralis (fast and very good)'
          TabOrder = 3
        end
      end
      object BackgroundOverrideBox: TPanel
        Left = 16
        Top = 160
        Width = 297
        Height = 73
        BevelOuter = bvNone
        TabOrder = 1
        object bcNone: TRadioButton
          Left = 0
          Top = 48
          Width = 89
          Height = 17
          Hint = 
            'Use this setting if you are making cameos to avoid cameos to loo' +
            'k corrupted in game.'
          HelpType = htKeyword
          Caption = 'None'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          TabStop = True
          OnClick = bcNoneClick
        end
        object bcAutoSelect: TRadioButton
          Left = 0
          Top = 32
          Width = 89
          Height = 17
          Hint = 
            'This auto selects the background colour by checking the colour o' +
            'f the first frame of the image.'
          HelpType = htKeyword
          Caption = 'Auto Select'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          TabStop = True
          OnClick = bcAutoSelectClick
        end
        object bcCustom: TRadioButton
          Left = 0
          Top = 16
          Width = 89
          Height = 17
          Hint = 
            'This allows you to set your own colour to override the palette c' +
            'olour 0. Good for those who used a wrong colour for the backgrou' +
            'nd of the image.'
          HelpType = htKeyword
          Caption = 'Custom'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          TabStop = True
          OnClick = bcCustomClick
        end
        object bcDefault: TRadioButton
          Left = 0
          Top = 0
          Width = 89
          Height = 17
          Hint = 
            'This uses the first colour of the palette as the colour 0 of the' +
            ' palette.'
          HelpType = htKeyword
          Caption = 'Palette Default'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          OnClick = bcDefaultClick
        end
        object bcColourEdit: TPanel
          Left = 96
          Top = 24
          Width = 57
          Height = 41
          BevelOuter = bvLowered
          Color = clSilver
          TabOrder = 4
          OnClick = bcColourEditChange
        end
      end
      object Panel1: TPanel
        Left = 8
        Top = 232
        Width = 321
        Height = 57
        BevelOuter = bvNone
        TabOrder = 2
        object Label14: TLabel
          Left = 0
          Top = 8
          Width = 36
          Height = 13
          Caption = 'Palette:'
        end
        object LbTechPal: TLabel
          Left = 0
          Top = 32
          Width = 64
          Height = 13
          Caption = 'Tech Palette:'
          Enabled = False
        end
        object CboxUseTech: TCheckBox
          Left = 232
          Top = 32
          Width = 45
          Height = 17
          Hint = 
            'Check this setting only if you are importing a tech building. In' +
            ' this case, the 4th and 8th frames will use this palette while o' +
            'ther frames will use the normal palette.'
          Caption = 'Use'
          TabOrder = 0
          OnClick = CboxUseTechClick
        end
        object CbxPalette: TComboBoxEx
          Left = 80
          Top = 4
          Width = 145
          Height = 22
          ItemsEx = <>
          ItemHeight = 16
          TabOrder = 1
          Images = SHPBuilderFrmMain.ImageList
        end
        object CbxTechPalette: TComboBoxEx
          Left = 80
          Top = 28
          Width = 145
          Height = 22
          ItemsEx = <>
          Enabled = False
          ItemHeight = 16
          TabOrder = 2
          Images = SHPBuilderFrmMain.ImageList
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Frame Size'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label7: TLabel
        Left = 8
        Top = 160
        Width = 145
        Height = 13
        Caption = 'If Frame Size is Different:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label2: TLabel
        Left = 8
        Top = 16
        Width = 67
        Height = 13
        Caption = 'Frame Size:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ResizeOrCanvasBox: TPanel
        Left = 8
        Top = 176
        Width = 169
        Height = 33
        BevelOuter = bvNone
        TabOrder = 0
        object rocResize: TRadioButton
          Left = 0
          Top = 0
          Width = 113
          Height = 17
          Caption = 'Resize'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rocMCCanvas: TRadioButton
          Left = 0
          Top = 16
          Width = 169
          Height = 17
          Caption = 'Manually Change Canvas Size'
          TabOrder = 1
        end
      end
      object FramesSize: TPanel
        Left = 8
        Top = 32
        Width = 129
        Height = 89
        BevelOuter = bvNone
        TabOrder = 1
        object Label4: TLabel
          Left = 10
          Top = 33
          Width = 31
          Height = 22
          AutoSize = False
          Caption = 'Width:'
          Layout = tlCenter
        end
        object Label5: TLabel
          Left = 10
          Top = 59
          Width = 34
          Height = 22
          AutoSize = False
          Caption = 'Height:'
          Layout = tlCenter
        end
        object fszAuto: TRadioButton
          Left = 0
          Top = 0
          Width = 73
          Height = 17
          Caption = 'Automatic'
          TabOrder = 0
          OnClick = fszAutoClick
        end
        object fszCustom: TRadioButton
          Left = 0
          Top = 16
          Width = 57
          Height = 17
          Caption = 'Custom'
          Checked = True
          TabOrder = 1
          TabStop = True
        end
        object fszWidth: TSpinEdit
          Left = 52
          Top = 33
          Width = 49
          Height = 22
          MaxValue = 10000
          MinValue = 1
          TabOrder = 2
          Value = 1
          OnChange = fszHeightChange
          OnExit = fszWidthExit
        end
        object fszHeight: TSpinEdit
          Left = 52
          Top = 59
          Width = 49
          Height = 22
          MaxValue = 10000
          MinValue = 1
          TabOrder = 3
          Value = 1
          OnChange = fszHeightChange
          OnExit = fszHeightExit
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Extra Settings'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label6: TLabel
        Left = 8
        Top = 120
        Width = 121
        Height = 13
        AutoSize = False
        Caption = 'Other Settings:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SplitShadowBox: TPanel
        Left = 8
        Top = 136
        Width = 185
        Height = 81
        BevelOuter = bvNone
        TabOrder = 0
        object ssRedToRemap: TCheckBox
          Left = 0
          Top = 32
          Width = 117
          Height = 17
          Caption = 'Red To Remappable'
          TabOrder = 0
        end
        object ssIgnoreLastColours: TCheckBox
          Left = 0
          Top = 16
          Width = 125
          Height = 17
          Hint = 
            'This option is used to avoid glowing colours on unitXX.pal. Don'#39 +
            't use this if you are making an isometric building, animations o' +
            'r cameos.'
          Caption = 'Improve Lighting'
          TabOrder = 1
        end
        object ssShadow: TCheckBox
          Left = 0
          Top = 0
          Width = 113
          Height = 17
          Hint = 
            'When the colours of the last half of frames are not background, ' +
            'they will be detected as shadows. Recommended if your picture in' +
            'cludes shadows (even if they are in the wrong colours). Do not u' +
            'se this with cameos and animations that uses no shadows.'
          Caption = 'Optimize Shadows'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object DitheringCheck: TCheckBox
          Left = 0
          Top = 48
          Width = 117
          Height = 17
          Caption = 'Apply Dithering'
          TabOrder = 3
        end
        object ssSplitShadows: TCheckBox
          Left = 0
          Top = 64
          Width = 169
          Height = 17
          Caption = 'Split Shadows'
          Enabled = False
          TabOrder = 4
        end
      end
      object ItsBox: TPanel
        Left = 8
        Top = 232
        Width = 281
        Height = 49
        BevelOuter = bvNone
        TabOrder = 1
        object Label20: TLabel
          Left = 0
          Top = 0
          Width = 121
          Height = 13
          Caption = 'Image Type Settings:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object itsAS00: TRadioButton
          Left = 0
          Top = 16
          Width = 249
          Height = 17
          Caption = 'AutoSelect Background by Pixel (0,0)'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = itsAS00Click
        end
        object itsASTransparent: TRadioButton
          Left = 0
          Top = 32
          Width = 273
          Height = 17
          Caption = 'Auto Select Background by Transparency Colour'
          TabOrder = 1
          OnClick = itsASTransparentClick
        end
      end
      object SHPIDOptions: TPanel
        Left = 8
        Top = 8
        Width = 329
        Height = 97
        BevelOuter = bvNone
        TabOrder = 2
        object Label12: TLabel
          Left = 8
          Top = 8
          Width = 81
          Height = 13
          AutoSize = False
          Caption = 'Game:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label13: TLabel
          Left = 8
          Top = 56
          Width = 89
          Height = 13
          AutoSize = False
          Caption = 'Type:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object CbxSHPGame: TComboBoxEx
          Left = 8
          Top = 24
          Width = 73
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
          OnChange = CbxSHPGameChange
          Images = SHPBuilderFrmMain.ImageList
        end
        object CbxSHPType: TComboBoxEx
          Left = 8
          Top = 72
          Width = 233
          Height = 22
          ItemsEx = <>
          ItemHeight = 16
          TabOrder = 1
        end
      end
    end
  end
  object OpenPictureDialog: TOpenPictureDialog
    Filter = 
      'All Files|*0000.bmp;*0000.jpg;*0000.jpeg;*0000.pcx;*.gif;*0000.p' +
      'ng;*0000.tga|Bitmaps (*0000.bmp)|*0000.bmp|JPEGs (*0000.jpg, *00' +
      '00.jpeg)|*0000.jpg;*0000.jpeg|PCX (*0000.pcx) [Limited Support]|' +
      '*0000.pcx|GIF (*.gif)|*.gif|PNG (*0000.png)|*0000.png|TGA (*0000' +
      '.tga)|*0000.tga'
    Options = [ofHideReadOnly, ofDontAddToRecent]
    Left = 272
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 
      'All Files(*.bmp, *.jpg, *.jpeg, *.pcx, *.gif, *.png, *.tga)|*.bm' +
      'p;*.jpg;*.jpeg;*.pcx;*.png;*.tga|Bitmap (*.bmp)|*.bmp|JPEG (*.jp' +
      'g, *.jpeg)|*.jpg;*.jpeg|PCX(*.pcx) [Limited Support]|*.pcx|GIF (' +
      '*.gif) |*.gif|PNG (*.png)|*.png|TGA(*.tga)|*.tga'
    Left = 304
  end
  object ColorDialog1: TColorDialog
    Left = 336
    Top = 65535
  end
  object XPManifest: TXPManifest
    Left = 176
    Top = 184
  end
end
