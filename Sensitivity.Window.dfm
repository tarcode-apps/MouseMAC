object SensitivityWindow: TSensitivityWindow
  Left = 0
  Top = 0
  Margins.Left = 6
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Sensitivity'
  ClientHeight = 179
  ClientWidth = 306
  Color = clBtnFace
  DefaultMonitor = dmPrimary
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Padding.Left = 9
  Padding.Top = 12
  Padding.Right = 8
  Padding.Bottom = 12
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object VerticalLabel: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 12
    Width = 282
    Height = 15
    Margins.Left = 7
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 4
    Align = alTop
    Caption = 'Vertical'
    ExplicitWidth = 38
  end
  object HorizontalLabel: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 99
    Width = 282
    Height = 15
    Margins.Left = 7
    Margins.Top = 24
    Margins.Right = 0
    Margins.Bottom = 4
    Align = alTop
    Caption = 'Horizontal'
    ExplicitTop = 53
    ExplicitWidth = 55
  end
  object HorizontalPanel: TPanel
    Left = 9
    Top = 118
    Width = 289
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 16
    ExplicitTop = 68
    ExplicitWidth = 274
    object HorizontalValueLabel: TLabel
      AlignWithMargins = True
      Left = 261
      Top = 0
      Width = 28
      Height = 26
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      AutoSize = False
      Caption = '0'
      Layout = tlCenter
      ExplicitLeft = 255
    end
    object HorizontalTrackBar: TTrackBar
      Left = 0
      Top = 0
      Width = 258
      Height = 26
      Align = alClient
      Max = 30
      Min = -30
      ParentShowHint = False
      ShowHint = False
      ShowSelRange = False
      TabOrder = 0
      ThumbLength = 22
      TickStyle = tsNone
      OnChange = HorizontalTrackBarChange
      ExplicitWidth = 243
    end
  end
  object VerticalPanel: TPanel
    Left = 9
    Top = 31
    Width = 289
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = 16
    ExplicitTop = 27
    ExplicitWidth = 274
    object VerticalValueLabel: TLabel
      AlignWithMargins = True
      Left = 261
      Top = 0
      Width = 28
      Height = 26
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      AutoSize = False
      Caption = '0'
      Layout = tlCenter
      ExplicitLeft = 254
    end
    object VerticalTrackBar: TTrackBar
      Left = 0
      Top = 0
      Width = 258
      Height = 26
      Align = alClient
      Max = 30
      Min = -30
      ParentShowHint = False
      ShowHint = False
      ShowSelRange = False
      TabOrder = 0
      ThumbLength = 22
      TickStyle = tsNone
      OnChange = VerticalTrackBarChange
      ExplicitWidth = 243
    end
  end
  object VerticalRevertPanel: TPanel
    AlignWithMargins = True
    Left = 12
    Top = 57
    Width = 286
    Height = 18
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Caption = 'VerticalRevertPanel'
    ShowCaption = False
    TabOrder = 2
    ExplicitTop = 52
    ExplicitWidth = 289
    object VerticalRevertLink: TStaticText
      AlignWithMargins = True
      Left = 2
      Top = 0
      Width = 98
      Height = 18
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'VerticalRevertLink'
      TabOrder = 0
      TabStop = True
      OnClick = VerticalRevertLinkClick
      ExplicitHeight = 19
    end
  end
  object HorizontalRevertPanel: TPanel
    AlignWithMargins = True
    Left = 12
    Top = 144
    Width = 286
    Height = 18
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Caption = 'HorizontalRevertPanel'
    ShowCaption = False
    TabOrder = 3
    ExplicitTop = 159
    ExplicitWidth = 289
    object HorizontalRevertLink: TStaticText
      AlignWithMargins = True
      Left = 2
      Top = 0
      Width = 114
      Height = 18
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'HorizontalRevertLink'
      TabOrder = 0
      TabStop = True
      OnClick = HorizontalRevertLinkClick
      ExplicitHeight = 19
    end
  end
end
