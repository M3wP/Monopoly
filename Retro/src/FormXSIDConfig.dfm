object XSIDConfigForm: TXSIDConfigForm
  Left = 697
  Top = 175
  AutoSize = True
  BorderStyle = bsDialog
  Caption = 'Configuration'
  ClientHeight = 393
  ClientWidth = 432
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 325
    Width = 432
    Height = 68
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 439
    object Button1: TButton
      Left = 351
      Top = 35
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object Button2: TButton
      Left = 271
      Top = 35
      Width = 75
      Height = 25
      Caption = 'OK'
      Enabled = False
      ModalResult = 1
      TabOrder = 1
    end
    object Button3: TButton
      Left = 183
      Top = 35
      Width = 75
      Height = 25
      Caption = 'Default'
      Enabled = False
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 153
    Width = 432
    Height = 172
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 267
    object Bevel2: TBevel
      Left = 8
      Top = 15
      Width = 424
      Height = 2
      Shape = bsBottomLine
    end
    object Label6: TLabel
      Left = 16
      Top = 115
      Width = 68
      Height = 15
      Caption = 'Sample Rate:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label7: TLabel
      Left = 16
      Top = 147
      Width = 58
      Height = 15
      Caption = 'Buffer Size:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label8: TLabel
      Left = 232
      Top = 115
      Width = 71
      Height = 15
      Caption = 'Interpolation:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label12: TLabel
      Left = 16
      Top = 43
      Width = 50
      Height = 15
      Caption = 'Renderer:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label13: TLabel
      Left = 16
      Top = 75
      Width = 46
      Height = 15
      Caption = 'Param 1:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label14: TLabel
      Left = 113
      Top = 77
      Width = 268
      Height = 15
      Caption = 'No additional parameters for the selected renderer.'
      Color = clBtnFace
      Enabled = False
      ParentColor = False
      Visible = False
    end
    object Label2: TLabel
      Left = 8
      Top = 7
      Width = 38
      Height = 15
      Caption = 'Audio  '
      Color = clBtnFace
      ParentColor = False
      Transparent = False
    end
    object ComboBox3: TComboBox
      Left = 113
      Top = 111
      Width = 88
      Height = 23
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 0
      Text = '44100'
      OnChange = ComboBox3Change
      Items.Strings = (
        '11025'
        '22050'
        '44100'
        '48000'
        '96000')
    end
    object ComboBox4: TComboBox
      Left = 113
      Top = 143
      Width = 88
      Height = 23
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 1
      Text = 'Tiny'
      OnChange = ComboBox4Change
      Items.Strings = (
        'Immediate'
        'Tiny'
        'Small'
        'Medium'
        'Large'
        'Extra Large'
        'Huge')
    end
    object ComboBox5: TComboBox
      Left = 320
      Top = 111
      Width = 96
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = 'Decimate'
      OnChange = ComboBox5Change
      Items.Strings = (
        'Decimate'
        'Resampling')
    end
    object ComboBox6: TComboBox
      Left = 113
      Top = 39
      Width = 194
      Height = 23
      Style = csDropDownList
      TabOrder = 3
      OnChange = ComboBox6Change
    end
    object Button5: TButton
      Left = 320
      Top = 38
      Width = 97
      Height = 25
      Caption = 'More Params...'
      TabOrder = 4
    end
    object Edit2: TEdit
      Left = 112
      Top = 72
      Width = 304
      Height = 23
      TabOrder = 5
      Text = 'Edit2'
      OnChange = Edit2Change
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 432
    Height = 153
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Bevel1: TBevel
      Left = 12
      Top = 20
      Width = 420
      Height = 2
      Shape = bsBottomLine
    end
    object Label1: TLabel
      Left = 12
      Top = 12
      Width = 69
      Height = 15
      Caption = 'SID Defaults  '
      Color = clBtnFace
      ParentColor = False
      Transparent = False
    end
    object Label3: TLabel
      Left = 16
      Top = 44
      Width = 37
      Height = 15
      Caption = 'Model:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label9: TLabel
      Left = 232
      Top = 44
      Width = 74
      Height = 15
      Caption = 'Filter Enabled:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label10: TLabel
      Left = 231
      Top = 76
      Width = 63
      Height = 15
      Caption = 'Filter Curve:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label11: TLabel
      Left = 232
      Top = 122
      Width = 57
      Height = 15
      Caption = 'Digi Boost:'
      Color = clBtnFace
      Enabled = False
      ParentColor = False
    end
    object Label5: TLabel
      Left = 328
      Top = 100
      Width = 21
      Height = 15
      Caption = '0.17'
    end
    object ComboBox1: TComboBox
      Left = 113
      Top = 40
      Width = 88
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = '6581'
      OnChange = ComboBox1Change
      Items.Strings = (
        '6581'
        '8580')
    end
    object CheckBox1: TCheckBox
      Left = 328
      Top = 41
      Width = 20
      Height = 19
      BiDiMode = bdLeftToRight
      Checked = True
      ParentBiDiMode = False
      State = cbChecked
      TabOrder = 1
      OnClick = CheckBox1Change
    end
    object CheckBox2: TCheckBox
      Left = 328
      Top = 121
      Width = 20
      Height = 19
      BiDiMode = bdLeftToRight
      Enabled = False
      ParentBiDiMode = False
      TabOrder = 2
      OnClick = CheckBox2Change
    end
    object ComboBox7: TComboBox
      Left = 328
      Top = 72
      Width = 88
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 3
      Text = 'R2'
      OnChange = ComboBox7Change
      Items.Strings = (
        'R2'
        'R4'
        'Custom...')
    end
  end
end
