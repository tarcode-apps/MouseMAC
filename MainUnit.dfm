object MouseExForm: TMouseExForm
  Left = 196
  Top = 149
  AutoSize = True
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'MouseExForm'
  ClientHeight = 197
  ClientWidth = 224
  Color = clWindow
  Ctl3D = False
  DefaultMonitor = dmDesktop
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnShow = FormShow
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 224
    Height = 45
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      224
      45)
    object LabelAppName: TLabel
      Left = 51
      Top = 5
      Width = 153
      Height = 15
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'LabelAppName'
      OnClick = LabelAppInfoClick
    end
    object ImageIcon: TImage
      Left = 10
      Top = 3
      Width = 36
      Height = 36
      Center = True
      Transparent = True
      OnClick = LabelAppInfoClick
    end
    object LabelAppInfo: TLabel
      Left = 51
      Top = 22
      Width = 153
      Height = 15
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'LabelAppInfo'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Visible = False
      OnClick = LabelAppInfoClick
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 154
    Width = 224
    Height = 43
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    Color = clMenu
    Constraints.MinHeight = 43
    ParentBackground = False
    TabOrder = 2
    object LinkGridPanel: TGridPanel
      Left = 0
      Top = 0
      Width = 224
      Height = 43
      Align = alTop
      BevelOuter = bvNone
      Caption = 'LinkGridPanel'
      Color = clMenu
      ColumnCollection = <
        item
          Value = 100.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Link
          Row = 0
        end>
      RowCollection = <
        item
          Value = 100.000000000000000000
        end>
      ShowCaption = False
      TabOrder = 0
      DesignSize = (
        224
        43)
      object Link: TStaticText
        Left = 99
        Top = 12
        Width = 26
        Height = 19
        Margins.Left = 19
        Margins.Top = 14
        Margins.Right = 19
        Margins.Bottom = 8
        Alignment = taCenter
        Anchors = []
        Caption = 'Link'
        ShowAccelChar = False
        TabOrder = 0
        TabStop = True
        OnClick = LinkClick
      end
    end
  end
  object PanelConfig: TPanel
    Left = 0
    Top = 45
    Width = 224
    Height = 109
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 5
    Padding.Right = 4
    Padding.Bottom = 12
    ParentColor = True
    TabOrder = 1
    object LabelConfig: TLabel
      AlignWithMargins = True
      Left = 16
      Top = 5
      Width = 192
      Height = 15
      Margins.Left = 12
      Margins.Top = 0
      Margins.Right = 12
      Margins.Bottom = 2
      Align = alTop
      Alignment = taCenter
      Caption = 'Config'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitWidth = 36
    end
    object CheckBoxEnable: TCheckBox
      AlignWithMargins = True
      Left = 20
      Top = 26
      Width = 184
      Height = 17
      Margins.Left = 16
      Margins.Top = 4
      Margins.Right = 16
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Enable'
      TabOrder = 0
      OnClick = CheckBoxEnableClick
    end
    object CheckBoxInvert: TCheckBox
      AlignWithMargins = True
      Left = 20
      Top = 51
      Width = 184
      Height = 17
      Margins.Left = 16
      Margins.Top = 4
      Margins.Right = 16
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Invert'
      TabOrder = 1
      OnClick = CheckBoxInvertClick
    end
    object CheckBoxHorizontalScrollWithShift: TCheckBox
      AlignWithMargins = True
      Left = 20
      Top = 76
      Width = 184
      Height = 17
      Margins.Left = 16
      Margins.Top = 4
      Margins.Right = 16
      Margins.Bottom = 4
      Align = alTop
      Caption = 'HorizontalScrollWithShift'
      TabOrder = 2
      WordWrap = True
      OnClick = CheckBoxHorizontalScrollWithShiftClick
    end
  end
  object PopupMenuTray: TPopupMenu
    Left = 168
    Top = 80
    object TrayMenuMouse: TMenuItem
      Caption = 'Mouse'
      OnClick = TrayMenuMouseClick
    end
    object TrayMenuSeparator1: TMenuItem
      Caption = '-'
    end
    object TrayMenuEnable: TMenuItem
      AutoCheck = True
      Caption = 'Enable'
      OnClick = TrayMenuEnableClick
    end
    object TrayMenuAutorun: TMenuItem
      AutoCheck = True
      Caption = 'Autorun'
      OnClick = TrayMenuAutorunClick
    end
    object TrayMenuAutoUpdate: TMenuItem
      Caption = 'AutoUpdate'
      object TrayMenuAutoUpdateEnable: TMenuItem
        AutoCheck = True
        Caption = 'Enable'
        OnClick = TrayMenuAutoUpdateEnableClick
      end
      object TrayMenuAutoUpdateCheck: TMenuItem
        Caption = 'Check'
        OnClick = TrayMenuAutoUpdateCheckClick
      end
    end
    object TrayMenuLanguage: TMenuItem
      Caption = 'Language'
      object TrayMenuLanguageSystem: TMenuItem
        Caption = 'System'
        OnClick = TrayMenuLanguageItemClick
      end
      object TrayMenuSeparator5: TMenuItem
        Caption = '-'
      end
    end
    object TrayMenuHorizontalScrollOnShiftDown: TMenuItem
      AutoCheck = True
      Caption = 'HorizontalScrollOnShiftDown'
      OnClick = TrayMenuHorizontalScrollOnShiftDownClick
    end
    object TrayMenuSeparator2: TMenuItem
      Caption = '-'
    end
    object TrayMenuListboxSmoothScrolling: TMenuItem
      AutoCheck = True
      Caption = 'ListboxSmoothScrolling'
      Visible = False
      OnClick = TrayMenuListboxSmoothScrollingClick
    end
    object TrayMenuSeparator3: TMenuItem
      Caption = '-'
    end
    object TrayMenuWebsite: TMenuItem
      Caption = 'Website'
      OnClick = TrayMenuWebsiteClick
    end
    object TrayMenuLicense: TMenuItem
      Caption = 'License'
      OnClick = TrayMenuLicenseClick
    end
    object TrayMenuSeparator4: TMenuItem
      Caption = '-'
    end
    object TrayMenuClose: TMenuItem
      Caption = 'Close'
      OnClick = TrayMenuCloseClick
    end
  end
end
