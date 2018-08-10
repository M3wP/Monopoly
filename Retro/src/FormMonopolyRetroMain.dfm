object MonopolyRetroMainForm: TMonopolyRetroMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'MonopolyRetro!  An ArooC64 Project!'
  ClientHeight = 585
  ClientWidth = 720
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 544
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 0
    Top = 544
    Width = 720
    Height = 41
    Align = alBottom
    BevelInner = bvLowered
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 6
      Width = 33
      Height = 13
      Caption = 'Label1'
    end
    object Label2: TLabel
      Left = 8
      Top = 25
      Width = 33
      Height = 13
      Caption = 'Label2'
    end
  end
  object MainMenu1: TMainMenu
    Left = 696
    Top = 65524
    object File1: TMenuItem
      Caption = '&File'
      object Test1: TMenuItem
        Caption = 'Test'
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
    end
    object View1: TMenuItem
      Caption = '&View'
    end
    object Tools1: TMenuItem
      Caption = '&Tools'
      object Input1: TMenuItem
        Caption = 'Input'
        object EnableJoystick1: TMenuItem
          Action = actInputJoystick
        end
      end
      object Configure1: TMenuItem
        Caption = 'Configure'
        object SIDAudio1: TMenuItem
          Action = actConfigSID
        end
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
    end
  end
  object ActionList1: TActionList
    Left = 640
    Top = 65524
    object actInputJoystick: TAction
      Category = 'Input'
      Caption = '&Joystick Enable'
      OnExecute = actInputJoystickExecute
    end
    object actConfigSID: TAction
      Category = 'Config'
      Caption = 'SID Audio'
      OnExecute = actConfigSIDExecute
    end
  end
  object Timer1: TTimer
    Interval = 20
    OnTimer = Timer1Timer
    Left = 668
    Top = 36
  end
end
