unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes, System.Win.Registry,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Buttons,
  Autorun.Manager,
  AutoUpdate, AutoUpdate.Scheduler,
  Core.Startup,
  Core.Language, Core.Language.Controls,
  Core.UI, Core.UI.Controls, Core.UI.Notifications,
  Desktop,
  Mouse.Mac,
  Tray.Notify.Window, Tray.Notify.Controls,
  Versions, Versions.Info, Versions.Helpers,
  Helpers.License;

const
  REG_Key = 'Software\Mouse MAC';
  REG_ID = 'ID';
  REG_Version = 'Version';
  REG_AutoUpdateEnable = 'AutoUpdateEnable';
  REG_AutoUpdateLastCheck = 'AutoUpdateLastCheck';
  REG_AutoUpdateSkipVersion = 'AutoUpdateSkipVersion';
  REG_Language = 'Language';
  REG_LanguageId = 'LanguageId';
  REG_Enable = 'Enable';
  REG_Invert = 'Invert';
  REG_HorizontalScrollOnShiftDown = 'HorizontalScrollOnShiftDown';

type
  TConfig = record
    ID: TAppID;
    AutoUpdateEnable: Boolean;
    AutoUpdateLastCheck: TDateTime;
    AutoUpdateSkipVersion: TVersion;
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
    TrayMenuAutoUpdate: TMenuItem;
    TrayMenuAutoUpdateEnable: TMenuItem;
    TrayMenuAutoUpdateCheck: TMenuItem;
    PopupMenuTray: TPopupMenu;
    TrayMenuMouse: TMenuItem;
    TrayMenuEnable: TMenuItem;
    TrayMenuAutorun: TMenuItem;
    TrayMenuListboxSmoothScrolling: TMenuItem;
    TrayMenuHorizontalScrollOnShiftDown: TMenuItem;
    TrayMenuWebsite: TMenuItem;
    TrayMenuLicense: TMenuItem;
    TrayMenuClose: TMenuItem;
    TrayMenuSeparator1: TMenuItem;
    TrayMenuSeparator2: TMenuItem;
    TrayMenuSeparator3: TMenuItem;
    TrayMenuSeparator4: TMenuItem;
    TrayMenuLanguage: TMenuItem;
    TrayMenuLanguageSystem: TMenuItem;
    TrayMenuSeparator5: TMenuItem;
    LinkGridPanel: TGridPanel;
    Link: TStaticText;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure LabelAppInfoClick(Sender: TObject);

    procedure LinkClick(Sender: TObject);

    procedure TrayMenuMouseClick(Sender: TObject);
    procedure TrayMenuEnableClick(Sender: TObject);
    procedure TrayMenuAutorunClick(Sender: TObject);
    procedure TrayMenuAutoUpdateEnableClick(Sender: TObject);
    procedure TrayMenuAutoUpdateCheckClick(Sender: TObject);
    procedure TrayMenuLanguageItemClick(Sender: TObject);
    procedure TrayMenuHorizontalScrollOnShiftDownClick(Sender: TObject);
    procedure TrayMenuListboxSmoothScrollingClick(Sender: TObject);
    procedure TrayMenuWebsiteClick(Sender: TObject);
    procedure TrayMenuLicenseClick(Sender: TObject);
    procedure TrayMenuCloseClick(Sender: TObject);

    procedure CheckBoxEnableClick(Sender: TObject);
    procedure CheckBoxInvertClick(Sender: TObject);
    procedure CheckBoxAutorunClick(Sender: TObject);

    procedure TrayNotifyUpdateAvalible(Sender: TObject; Value: Integer);
    procedure TrayNotifyUpdateFail(Sender: TObject; Value: Integer);
  protected
    procedure LoadIcon; override;
    procedure Loadlocalization;
    procedure LoadAvailableLocalizetions;

    function DefaultConfig: TConfig;
    function LoadConfig: TConfig;
    procedure SaveConfig(Conf: TConfig);
    procedure SaveCurrentConfig;
    procedure DeleteConfig;
  private
    LockerAutorun: ILocker;
    LockerSaveConfig: ILocker;
    LockerMouseMac: ILocker;
    LockerInvert: ILocker;
    LockerHorizontalScrollOnShiftDown: ILocker;
    LockerUIEffects: ILocker;
    LockerListboxSmoothScrolling: ILocker;

    FUIInfo: TUIInfo;

    AutoUpdateScheduler: TAutoUpdateScheduler;

    procedure SetUIInfo(const Value: TUIInfo);

    procedure AutorunManagerAutorun(Sender: TObject; Enable: Boolean);

    procedure OpenConfigMouse;

    procedure MouseMacStateChange(Sender: TObject; State: Boolean);
    procedure MouseMacInvertChange(Sender: TObject; State: Boolean);
    procedure MouseMacHorizontalScrollOnShiftDownChange(Sender: TObject; State: Boolean);

    procedure DesktopManagerUIEffects(Sender: TObject; Capable: Boolean; State: Boolean);
    procedure DesktopManagerListboxSmoothScrolling(Sender: TObject; Capable: Boolean; State: Boolean);

    procedure AutoUpdateSchedulerInCheck(Sender: TObject);
    procedure AutoUpdateSchedulerChecked(Sender: TObject);
    procedure AutoUpdateSchedulerSaveLastCheck(Sender: TObject; Time: TDateTime);
    procedure AutoUpdateSchedulerInstalling(Sender: TObject);
    procedure AutoUpdateSchedulerSkip(Sender: TObject; Version: TVersion);
    procedure AutoUpdateSchedulerAvalible(Sender: TObject; Version: TVersion);
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
  LockerSaveConfig                  := TLocker.Create;
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

  // Инициализация Notification
  TNotificationService.Notification := TrayNotification;

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

  // Инициализация AutoUpdateScheduler
  AutoUpdateScheduler := TAutoUpdateScheduler.Create(TLang[40],
    Conf.AutoUpdateLastCheck, Conf.AutoUpdateSkipVersion, Conf.ID);
  AutoUpdateScheduler.OnInCheck := AutoUpdateSchedulerInCheck;
  AutoUpdateScheduler.OnChecked := AutoUpdateSchedulerChecked;
  AutoUpdateScheduler.OnSaveLastCheck := AutoUpdateSchedulerSaveLastCheck;
  AutoUpdateScheduler.OnInstalling := AutoUpdateSchedulerInstalling;
  AutoUpdateScheduler.OnSkip := AutoUpdateSchedulerSkip;
  AutoUpdateScheduler.OnAvalible := AutoUpdateSchedulerAvalible;
  AutoUpdateScheduler.Enable := Conf.AutoUpdateEnable;

  TrayMenuAutoUpdateEnable.Checked := AutoUpdateScheduler.Enable;

  // Загрузка локализации
  LoadAvailableLocalizetions;
  Loadlocalization;

  // Отображение иконки в трее
  TrayIcon.Visible := True;
  // Исправление отсутствующего значка при автозапуске через планировщик задач
  TrayIcon.Update(30000);

  case AutoUpdateScheduler.StartupUpdateStatus of
    susComplete: TrayNotification.Notify(Format(TLang[45], [TVersionInfo.FileVersion.ToString]));
    susFail: TrayNotification.Notify(Format(TLang[46], [TVersionInfo.FileVersion.ToString]), [nfError], TrayNotifyUpdateFail);
  end;
end;

procedure TMouseExForm.FormDestroy(Sender: TObject);
begin
  if WindowCreated and not LockerSaveConfig.IsLocked then
    SaveCurrentConfig;

  AutoUpdateScheduler.Free;

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

procedure TMouseExForm.TrayMenuAutoUpdateEnableClick(Sender: TObject);
begin
  AutoUpdateScheduler.Enable := (Sender as TMenuItem).Checked;
end;

procedure TMouseExForm.TrayMenuAutoUpdateCheckClick(Sender: TObject);
begin
  AutoUpdateScheduler.Check(True);
end;

procedure TMouseExForm.TrayMenuLanguageItemClick(Sender: TObject);
var
  NewLanguageId, LastEffectiveLanguageId: LANGID;
  StartUpInfo : TStartUpInfo;
  ProcessInfo : TProcessInformation;
begin
  if (Sender is TLanguageMenuItem) then
    NewLanguageId := (Sender as TLanguageMenuItem).Localization.LanguageId
  else
    NewLanguageId := 0;

  if TLang.LanguageId = NewLanguageId then Exit;

  LastEffectiveLanguageId := TLang.EffectiveLanguageId;
  TLang.LanguageId := NewLanguageId;
  if LastEffectiveLanguageId = TLang.EffectiveLanguageId then Exit;

  Loadlocalization;

  SaveCurrentConfig;

  TMutexLocker.Unlock;
  TrayIcon.Visible := False;

  ZeroMemory(@StartUpInfo, SizeOf(StartUpInfo));
  StartUpInfo.cb := SizeOf(StartUpInfo);

  if not CreateProcess(LPCTSTR(Application.ExeName), nil, nil, nil, True,
    GetPriorityClass(GetCurrentProcess), nil, nil, StartUpInfo, ProcessInfo) then
  begin
    TMutexLocker.Lock;
    TrayIcon.Visible := True;
    Exit;
  end;

  LockerSaveConfig.Lock;
  try
    Application.Terminate;
  finally
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);

    ExitProcess(0);
  end;
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

procedure TMouseExForm.TrayMenuLicenseClick(Sender: TObject);
begin
  TLicense.Open;
end;

procedure TMouseExForm.TrayMenuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMouseExForm.TrayNotifyUpdateAvalible(Sender: TObject;
  Value: Integer);
begin
  SetForegroundWindow(TrayIcon.Handle);
  AutoUpdateScheduler.Check(True);
end;

procedure TMouseExForm.TrayNotifyUpdateFail(Sender: TObject; Value: Integer);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang.GetString(12)), nil, nil, SW_RESTORE);
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

{$REGION 'AutoUpdateScheduler Event'}
procedure TMouseExForm.AutoUpdateSchedulerChecked(Sender: TObject);
begin
  TrayMenuAutoUpdateCheck.Enabled := True
end;

procedure TMouseExForm.AutoUpdateSchedulerInCheck(Sender: TObject);
begin
  TrayMenuAutoUpdateCheck.Enabled := False;
end;

procedure TMouseExForm.AutoUpdateSchedulerInstalling(Sender: TObject);
begin
  SaveCurrentConfig;
  TrayIcon.Visible := False;
  Application.Terminate;
  ExitProcess(0);
end;

procedure TMouseExForm.AutoUpdateSchedulerSaveLastCheck(Sender: TObject;
  Time: TDateTime);
begin
  SaveCurrentConfig;
end;

procedure TMouseExForm.AutoUpdateSchedulerSkip(Sender: TObject;
  Version: TVersion);
begin
  SaveCurrentConfig;
end;

procedure TMouseExForm.AutoUpdateSchedulerAvalible(Sender: TObject;
  Version: TVersion);
begin
  TrayNotification.Notify(Format(TLang[44], [Version.ToString]), TrayNotifyUpdateAvalible);
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
  function GetInternationalization(Index: Integer): string;
  var
    NonLocalized: string;
  begin
    Result := TLang[Index];
    NonLocalized := TLang.GetString(Index, TLang.DefaultLang);
    if Result <> NonLocalized then
      Result := Result + ' (' + NonLocalized + ')';
  end;
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
  TrayMenuLicense.Caption   := TLang[224]; // License
  TrayMenuClose.Caption     := TLang[9];
  TrayMenuListboxSmoothScrolling.Caption      := TLang[22]; // Гладкое прокручивание списков
  TrayMenuHorizontalScrollOnShiftDown.Caption := TLang[30]; // Горизонтальная прокрутка с клавишей Shift

  TrayMenuAutoUpdate.Caption        := TLang[41]; // Automatic updates
  TrayMenuAutoUpdateEnable.Caption  := TLang[42]; // Turn on automatic updates
  TrayMenuAutoUpdateCheck.Caption   := TLang[43]; // Check for Updates

  TrayMenuLanguage.Caption            := GetInternationalization(150);
  TrayMenuLanguageSystem.Caption      := GetInternationalization(151);

  if TMouseMac.Enable then
    TrayIcon.Hint := TLang[1] + sLineBreak + TLang[4]
  else
    TrayIcon.Hint := TLang[1] + sLineBreak + TLang[5];

  TrayIcon.BalloonTitle  := TLang[1]; // MouseMAC
  TrayNotification.Title := TLang[1]; // MouseMAC
end;

procedure TMouseExForm.LoadAvailableLocalizetions;
var
  AvailableLocalizations: TAvailableLocalizations;
  Localization: TAvailableLocalization;
  MenuItem: TMenuItem;
begin
  AvailableLocalizations := TLang.GetAvailableLocalizations(0);
  AvailableLocalizations.Sort(TComparer<TAvailableLocalization>.Construct(
    function(const Left, Right: TAvailableLocalization): Integer
    begin
      Result := string.Compare(
        Left.Value,
        Right.Value,
        [coLingIgnoreCase],
        MAKELCID(TLang.LanguageId, SORT_DEFAULT));
    end
  ));
  try
    for Localization in AvailableLocalizations do
    begin
      MenuItem := TLanguageMenuItem.Create(PopupMenuTray, Localization);
      MenuItem.OnClick := TrayMenuLanguageItemClick;
      MenuItem.Checked := Localization.LanguageId = TLang.LanguageId;

      TrayMenuLanguage.Add(MenuItem);
    end;

    TrayMenuLanguageSystem.Checked := TLang.LanguageId = 0;
  finally
    AvailableLocalizations.Free;
  end;
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
function TMouseExForm.DefaultConfig: TConfig;
begin
  Result.ID := TAutoUpdateScheduler.NewID;
  Result.AutoUpdateEnable := True;
  Result.AutoUpdateLastCheck := 0;
  Result.AutoUpdateSkipVersion := TVersion.Empty;
  Result.Enable:= True;
  Result.Invert:= False;
  Result.HorizontalScrollOnShiftDown:= False;
end;

function TMouseExForm.LoadConfig: TConfig;
var
  Default: TConfig;
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
begin
  Default := DefaultConfig;
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if not Registry.KeyExists(REG_Key) then Exit(Default);
    if not Registry.OpenKeyReadOnly(REG_Key) then Exit(Default);

    // Read config
    Result.ID := ReadIntegerDef(REG_ID, Default.ID);
    Result.AutoUpdateEnable := ReadBoolDef(REG_AutoUpdateEnable, Default.AutoUpdateEnable);
    Result.AutoUpdateLastCheck := StrToDateTimeDef(ReadStringDef(REG_AutoUpdateLastCheck, ''), Default.AutoUpdateLastCheck);
    Result.AutoUpdateSkipVersion := ReadStringDef(REG_AutoUpdateSkipVersion, Default.AutoUpdateSkipVersion);
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
    if Registry.OpenKey(REG_Key, True) then begin
      // Write config
      Registry.WriteInteger(REG_ID, Conf.ID);
      Registry.WriteString(REG_Version, TVersionInfo.FileVersion); // Last version
      Registry.WriteInteger(REG_LanguageId, TLang.LanguageId);

      Registry.WriteBool(REG_AutoUpdateEnable, Conf.AutoUpdateEnable);
      Registry.WriteString(REG_AutoUpdateLastCheck, DateTimeToStr(Conf.AutoUpdateLastCheck));
      Registry.WriteString(REG_AutoUpdateSkipVersion, Conf.AutoUpdateSkipVersion);
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
  Conf.ID := AutoUpdateScheduler.ID;
  Conf.AutoUpdateEnable := AutoUpdateScheduler.Enable;
  Conf.AutoUpdateLastCheck := AutoUpdateScheduler.LastCheck;
  Conf.AutoUpdateSkipVersion := AutoUpdateScheduler.SkipVersion;
  Conf.Enable := TMouseMac.Enable;
  Conf.Invert := TMouseMac.Invert;
  Conf.HorizontalScrollOnShiftDown := TMouseMac.HorizontalScrollOnShiftDown;

  SaveConfig(Conf);
end;

procedure TMouseExForm.DeleteConfig;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(REG_Key);
  finally
    Registry.Free;
  end;
end;
{$ENDREGION}

end.
