unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes, System.Win.Registry,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Buttons,
  Autorun.Manager,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Desktop,
  Mouse.Mac,
  Tray.Notify.Window, Tray.Notify.Controls,
  Versions, Versions.Info, Versions.Helpers;

const
  REG_Key = 'Software\Mouse MAC';
  REG_Enable = 'Enable';
  REG_Invert = 'Invert';
  REG_HorizontalScrollOnShiftDown = 'HorizontalScrollOnShiftDown';

type
  TConfig = record
    Enable: Boolean;
    Invert: Boolean;
    HorizontalScrollOnShiftDown: Boolean;
  end;

  TUIInfo = (UIInfoHide, UIInfoSN);

type
  TMouseExForm = class(TTrayNotifyWindow)
    PanelTop: TPanel;
    PanelBottom: TPanel;
    PanelConfig: TPanel;
    ImageIcon: TImage;
    LabelAppName: TLabel;
    LabelAppInfo: TLabel;
    LabelConfig: TLabel;
    CheckBoxEnable: TCheckBox;
    CheckBoxInvert: TCheckBox;
    CheckBoxAutorun: TCheckBox;
    PopupMenuTray: TPopupMenu;
    TrayMenuMouse: TMenuItem;
    TrayMenuEnable: TMenuItem;
    TrayMenuAutorun: TMenuItem;
    TrayMenuListboxSmoothScrolling: TMenuItem;
    TrayMenuWebsite: TMenuItem;
    TrayMenuClose: TMenuItem;
    TrayMenuSeparator1: TMenuItem;
    TrayMenuSeparator2: TMenuItem;
    TrayMenuSeparator3: TMenuItem;
    TrayMenuSeparator4: TMenuItem;
    LinkGridPanel: TGridPanel;
    Link: TStaticText;
    TrayMenuHorizontalScrollOnShiftDown: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure LabelAppInfoClick(Sender: TObject);

    procedure LinkClick(Sender: TObject);

    procedure TrayMenuMouseClick(Sender: TObject);
    procedure TrayMenuEnableClick(Sender: TObject);
    procedure TrayMenuAutorunClick(Sender: TObject);
    procedure TrayMenuHorizontalScrollOnShiftDownClick(Sender: TObject);
    procedure TrayMenuListboxSmoothScrollingClick(Sender: TObject);
    procedure TrayMenuWebsiteClick(Sender: TObject);
    procedure TrayMenuCloseClick(Sender: TObject);

    procedure CheckBoxEnableClick(Sender: TObject);
    procedure CheckBoxInvertClick(Sender: TObject);
    procedure CheckBoxAutorunClick(Sender: TObject);
  protected
    procedure LoadIcon; override;
    procedure Loadlocalization;

    function LoadConfig: TConfig;
    procedure SaveConfig(Conf: TConfig);
    procedure SaveCurrentConfig;
  private
    LockerAutorun: ILocker;
    LockerMouseMac: ILocker;
    LockerInvert: ILocker;
    LockerHorizontalScrollOnShiftDown: ILocker;
    LockerUIEffects: ILocker;
    LockerListboxSmoothScrolling: ILocker;

    FUIInfo: TUIInfo;

    procedure SetUIInfo(const Value: TUIInfo);

    procedure AutorunManagerAutorun(Sender: TObject; Enable: Boolean);

    procedure OpenConfigMouse;

    procedure MouseMacStateChange(Sender: TObject; State: Boolean);
    procedure MouseMacInvertChange(Sender: TObject; State: Boolean);
    procedure MouseMacHorizontalScrollOnShiftDownChange(Sender: TObject; State: Boolean);

    procedure DesktopManagerUIEffects(Sender: TObject; Capable: Boolean; State: Boolean);
    procedure DesktopManagerListboxSmoothScrolling(Sender: TObject; Capable: Boolean; State: Boolean);
  public
    property UIInfo: TUIInfo read FUIInfo write SetUIInfo;
  end;

var
  MouseExForm: TMouseExForm;

implementation

{$R *.dfm}

procedure TMouseExForm.FormCreate(Sender: TObject);
var
  Conf: TConfig;
begin
  // Инициализация флагов обновления данных
  LockerAutorun                     := TLocker.Create;
  LockerMouseMac                    := TLocker.Create;
  LockerInvert                      := TLocker.Create;
  LockerHorizontalScrollOnShiftDown := TLocker.Create;
  LockerUIEffects                   := TLocker.Create;
  LockerListboxSmoothScrolling      := TLocker.Create;

  // Загрузка конфигурации
  Conf := LoadConfig;

  // Инициализация интерфейса
  Link.LinkMode := True;
  PanelTop.Shape := psBottomLine;
  PanelTop.Style := tfpsHeader;
  PanelConfig.Shape := psBottomLine;
  PanelConfig.Style := tfpsBody;
  PanelBottom.Style := tfpsLinkArea;
  LabelAppName.Caption := TVersionInfo.ProductName;

  CheckBoxEnable.AutoSize := True;
  CheckBoxInvert.AutoSize := True;
  CheckBoxAutorun.AutoSize := True;

  UIInfo := Low(UIInfo);

  LabelAppInfo.Font.Name := Font.Name;
  LabelAppInfo.Font.Size := Font.Size;
  LabelConfig.Font.Name := Font.Name;
  LabelConfig.Font.Size := Font.Size;

  if IsWindows10OrGreater then begin
    with PanelTop     do Height := Height - 3;
    with LabelAppName do Top := Top - 3;
    with LabelAppInfo do Top := Top - 3;
    with ImageIcon    do Top := Top - 3;
  end;

  // Инициализация трея
  TrayIcon.PopupMenu := PopupMenuTray;
  TrayIcon.Icon := Application.Icon.Handle;

  // Инициализация автозагрузки
  AutorunManager.OnAutorun := AutorunManagerAutorun;

  // Инициализация TMouseMac
  TMouseMac.OnStateChange := MouseMacStateChange;
  TMouseMac.OnInvertChange := MouseMacInvertChange;
  TMouseMac.OnHorizontalScrollOnShiftDownChange := MouseMacHorizontalScrollOnShiftDownChange;
  TMouseMac.Invert := Conf.Invert;
  TMouseMac.Enable := Conf.Enable;
  TMouseMac.HorizontalScrollOnShiftDown := Conf.HorizontalScrollOnShiftDown;

  // Инициализация TDesktopManager
  TDesktopManager.OnUIEffects := DesktopManagerUIEffects;
  TDesktopManager.OnListboxSmoothScrolling := DesktopManagerListboxSmoothScrolling;

  // Загрузка локализации
  Loadlocalization;

  // Отображение иконки в трее
  TrayIcon.Visible := True;
  // Исправление отсутствующего значка при автозапуске через планировщик задач
  TrayIcon.Update(30000);
end;

procedure TMouseExForm.FormDestroy(Sender: TObject);
begin
  if WindowCreated then
    SaveCurrentConfig;

  TMouseMac.Enable := False;
end;

procedure TMouseExForm.FormDeactivate(Sender: TObject);
begin
  UIInfo:= Low(UIInfo);
end;

procedure TMouseExForm.FormShow(Sender: TObject);
begin
  PanelConfig.Realign;
end;

{$REGION 'TMouseExForm Events'}
procedure TMouseExForm.LabelAppInfoClick(Sender: TObject);
begin
  if UIInfo = High(UIInfo) then
    UIInfo := Low(UIInfo)
  else
    UIInfo := Succ(UIInfo);
end;

procedure TMouseExForm.LinkClick(Sender: TObject);
begin
  OpenConfigMouse;
end;

procedure TMouseExForm.CheckBoxEnableClick(Sender: TObject);
begin
  if LockerMouseMac.IsLocked then Exit;
  TMouseMac.Enable := (Sender as TCheckBox).Checked;
end;

procedure TMouseExForm.CheckBoxInvertClick(Sender: TObject);
begin
  if LockerInvert.IsLocked then Exit;
  TMouseMac.Invert := (Sender as TCheckBox).Checked;
end;

procedure TMouseExForm.CheckBoxAutorunClick(Sender: TObject);
begin
  if LockerAutorun.IsLocked then Exit;
  AutorunManager.SetAutorunEx((Sender as TCheckBox).Checked);
  SetForegroundWindow(TrayIcon.Handle);
end;

procedure TMouseExForm.TrayMenuMouseClick(Sender: TObject);
begin
  OpenConfigMouse;
end;

procedure TMouseExForm.TrayMenuEnableClick(Sender: TObject);
begin
  if LockerMouseMac.IsLocked then Exit;
  TMouseMac.Enable := (Sender as TMenuItem).Checked;
end;

procedure TMouseExForm.TrayMenuAutorunClick(Sender: TObject);
begin
  if LockerAutorun.IsLocked then Exit;
  AutorunManager.SetAutorunEx((Sender as TMenuItem).Checked);
  SetForegroundWindow(TrayIcon.Handle);
end;

procedure TMouseExForm.TrayMenuHorizontalScrollOnShiftDownClick(
  Sender: TObject);
begin
  if LockerHorizontalScrollOnShiftDown.IsLocked then Exit;
  TMouseMac.HorizontalScrollOnShiftDown := (Sender as TMenuItem).Checked;
end;

procedure TMouseExForm.TrayMenuListboxSmoothScrollingClick(Sender: TObject);
begin
  if LockerListboxSmoothScrolling.IsLocked then Exit;
  TDesktopManager.ListboxSmoothScrolling := (Sender as TMenuItem).Checked;
end;

procedure TMouseExForm.TrayMenuWebsiteClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[12]), nil, nil, SW_RESTORE);
end;

procedure TMouseExForm.TrayMenuCloseClick(Sender: TObject);
begin
  Close;
end;
{$ENDREGION}

{$REGION 'TMouseMac Event'}
procedure TMouseExForm.MouseMacStateChange(Sender: TObject; State: Boolean);
begin
  LockerMouseMac.Lock;
  try
    CheckBoxEnable.Checked := State;
    TrayMenuEnable.Checked := State;

    CheckBoxInvert.Enabled := State;

    if State then
      TrayIcon.Hint := TLang[1] + sLineBreak + TLang[4]
    else
      TrayIcon.Hint := TLang[1] + sLineBreak + TLang[5];

    LoadIcon;
  finally
    LockerMouseMac.Unlock;
  end;
end;

procedure TMouseExForm.MouseMacInvertChange(Sender: TObject; State: Boolean);
begin
  LockerInvert.Lock;
  try
    CheckBoxInvert.Checked := State;
  finally
    LockerInvert.Unlock;
  end;
end;

procedure TMouseExForm.MouseMacHorizontalScrollOnShiftDownChange(
  Sender: TObject; State: Boolean);
begin
  LockerHorizontalScrollOnShiftDown.Lock;
  try
    TrayMenuHorizontalScrollOnShiftDown.Checked := State;
  finally
    LockerHorizontalScrollOnShiftDown.Unlock;
  end;
end;
{$ENDREGION}

{$REGION 'TDesktopManager Event'}
procedure TMouseExForm.DesktopManagerUIEffects(Sender: TObject; Capable,
  State: Boolean);
begin
  LockerUIEffects.Lock;
  try
    if Capable then
      TrayMenuListboxSmoothScrolling.Enabled := State;
  finally
    LockerUIEffects.Unlock;
  end;
end;

procedure TMouseExForm.DesktopManagerListboxSmoothScrolling(Sender: TObject;
  Capable, State: Boolean);
begin
  LockerListboxSmoothScrolling.Lock;
  try
    TrayMenuListboxSmoothScrolling.Visible := Capable;
    TrayMenuListboxSmoothScrolling.Checked := State;
  finally
    LockerListboxSmoothScrolling.Unlock;
  end;
end;
{$ENDREGION}

procedure TMouseExForm.AutorunManagerAutorun(Sender: TObject; Enable: Boolean);
begin
  LockerAutorun.Lock;
  try
    CheckBoxAutorun.Checked := Enable;
    TrayMenuAutorun.Checked := Enable;
  finally
    LockerAutorun.Unlock;
  end;
end;

procedure TMouseExForm.OpenConfigMouse;
begin
  WinExec('Control.exe main.cpl', SW_RESTORE);
end;

procedure TMouseExForm.LoadIcon;
begin
  if TMouseMac.Enable then
    Application.Icon.Handle := LoadIconW(HInstance, 'RIcon_Enable')
  else
    Application.Icon.Handle := LoadIconW(HInstance, 'RIcon_Disable');

  ImageIcon.Picture.Assign(Application.Icon);
  TrayIcon.Icon := Application.Icon.Handle;
end;

procedure TMouseExForm.Loadlocalization;
begin
  LabelAppName.Caption      := TLang[1];
  LabelConfig.Caption       := TLang[2];
  CheckBoxEnable.Caption    := TLang[3];
  CheckBoxInvert.Caption    := TLang[7];
  CheckBoxAutorun.Caption   := TLang[6];
  Link.Caption              := TLang[8];
  TrayMenuMouse.Caption     := TLang[8];
  TrayMenuEnable.Caption    := TLang[3];
  TrayMenuAutorun.Caption   := TLang[6];
  TrayMenuWebsite.Caption   := TLang[11];
  TrayMenuClose.Caption     := TLang[9];
  TrayMenuListboxSmoothScrolling.Caption      := TLang[22]; // Гладкое прокручивание списков
  TrayMenuHorizontalScrollOnShiftDown.Caption := TLang[30]; // Горизонтальная прокрутка с клавишей Shift

  if TMouseMac.Enable then
    TrayIcon.Hint := TLang[1] + sLineBreak + TLang[4]
  else
    TrayIcon.Hint := TLang[1] + sLineBreak + TLang[5];
end;

procedure TMouseExForm.SetUIInfo(const Value: TUIInfo);
const
  VerFmt = '%0:s: %1:s %2:s';
begin
  FUIInfo := Value;
  case Value of
    UIInfoSN: begin
      LabelAppInfo.Visible := True;
      LabelAppInfo.Caption := Format(VerFmt,
        [TLang[10], string(TVersionInfo.FileVersion), TVersionInfo.BinaryTypeAsShortString]);
    end;
    else begin
      LabelAppInfo.Visible := False;
    end;
  end;
end;

{$REGION 'Config'}
function TMouseExForm.LoadConfig: TConfig;
var
  Registry: TRegistry;

  function ReadBoolDef(const Name: string; const Def: Boolean): Boolean;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadBool(Name)
    else
      Result := Def;
  end;

  function ReadIntegerDef(const Name: string; const Def: Integer): Integer;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadInteger(Name)
    else
      Result := Def;
  end;

  function ReadStringDef(const Name: string; const Def: string): string;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadString(Name)
    else
      Result := Def;
  end;

  function DefConfig: TConfig;
  begin
    Result.Enable:= True;
    Result.Invert:= False;
    Result.HorizontalScrollOnShiftDown:= False;
  end;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if not Registry.KeyExists(REG_Key) then begin
      Result := DefConfig;
      Exit;
    end;

    if not Registry.OpenKeyReadOnly(REG_Key) then begin
      Result := DefConfig;
      Exit;
    end;

    // Read config
    Result.Enable:= ReadBoolDef(REG_Enable, True);
    Result.Invert:= ReadBoolDef(REG_Invert, False);
    Result.HorizontalScrollOnShiftDown:= ReadBoolDef(REG_HorizontalScrollOnShiftDown, False);
    // end read config

    Registry.CloseKey;
  finally
    Registry.Free;
  end;
end;

procedure TMouseExForm.SaveConfig(Conf: TConfig);
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(REG_Key);
    if Registry.OpenKey(REG_Key, True) then begin
      // Write config
      Registry.WriteBool(REG_Enable, Conf.Enable);
      Registry.WriteBool(REG_Invert, Conf.Invert);
      Registry.WriteBool(REG_HorizontalScrollOnShiftDown, Conf.HorizontalScrollOnShiftDown);
      // end write config

      Registry.CloseKey;
    end;
  finally
    Registry.Free;
  end;
end;

procedure TMouseExForm.SaveCurrentConfig;
var
  Conf: TConfig;
begin
  Conf.Enable := TMouseMac.Enable;
  Conf.Invert := TMouseMac.Invert;
  Conf.HorizontalScrollOnShiftDown := TMouseMac.HorizontalScrollOnShiftDown;

  SaveConfig(Conf);
end;
{$ENDREGION}

end.
