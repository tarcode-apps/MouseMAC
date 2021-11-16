program MouseMAC;

{$WEAKLINKRTTI ON}

{$R *.res}

{$R 'EnglishAutorunMessage.res' 'Localization\English\EnglishAutorunMessage.rc'}
{$R 'EnglishAutoUpdate.res' 'Localization\English\EnglishAutoUpdate.rc'}
{$R 'EnglishMainLanguage.res' 'Localization\English\EnglishMainLanguage.rc'}
{$R 'RussianAutorunMessage.res' 'Localization\Russian\RussianAutorunMessage.rc'}
{$R 'RussianAutoUpdate.res' 'Localization\Russian\RussianAutoUpdate.rc'}
{$R 'RussianMainLanguage.res' 'Localization\Russian\RussianMainLanguage.rc'}
{$R *.dres}

uses
  Vcl.Forms,
  Winapi.Windows,
  Winapi.Messages,
  System.Win.Registry,
  Autorun in 'Autorun\Autorun.pas',
  Autorun.Providers.TaskScheduler2 in 'Autorun\Autorun.Providers.TaskScheduler2.pas',
  Autorun.Providers.Registry in 'Autorun\Autorun.Providers.Registry.pas',
  Autorun.Manager in 'Autorun\Autorun.Manager.pas',
  AutoUpdate.Params in 'AutoUpdate\AutoUpdate.Params.pas',
  AutoUpdate in 'AutoUpdate\AutoUpdate.pas',
  AutoUpdate.Scheduler in 'AutoUpdate\AutoUpdate.Scheduler.pas',
  AutoUpdate.VersionDefinition in 'AutoUpdate\AutoUpdate.VersionDefinition.pas',
  AutoUpdate.Window.NotFound in 'AutoUpdate\AutoUpdate.Window.NotFound.pas',
  AutoUpdate.Window.Notify in 'AutoUpdate\AutoUpdate.Window.Notify.pas',
  AutoUpdate.Window.Update in 'AutoUpdate\AutoUpdate.Window.Update.pas',
  TaskSchd in 'Libs\TaskSchd.pas',
  WinHttp_TLB in 'Libs\WinHttp_TLB.pas',
  Core.Language.Controls in 'Core.Language.Controls.pas',
  Core.Language in 'Core.Language.pas',
  Core.Startup in 'Core.Startup.pas',
  Core.Startup.Tasks in 'Core.Startup.Tasks.pas',
  Core.UI in 'Core.UI.pas',
  Core.UI.Controls in 'Core.UI.Controls.pas',
  Core.UI.Notifications in 'Core.UI.Notifications.pas',
  Desktop in 'Desktop.pas',
  Helpers.License in 'Helpers.License.pas',
  Helpers.Services in 'Helpers.Services.pas',
  Helpers.Wts in 'Helpers.Wts.pas',
  MainUnit in 'MainUnit.pas' {MouseExForm},
  Mouse.Mac in 'Mouse.Mac.pas',
  Tray.Helpers in 'Tray.Helpers.pas',
  Tray.Icon in 'Tray.Icon.pas',
  Tray.Icon.Notifications in 'Tray.Icon.Notifications.pas',
  Tray.Notify.Controls in 'Tray.Notify.Controls.pas',
  Tray.Notify.Window in 'Tray.Notify.Window.pas',
  Versions in 'Versions.pas',
  Versions.Helpers in 'Versions.Helpers.pas',
  Versions.Info in 'Versions.Info.pas';

{$SETPEFlAGS IMAGE_FILE_DEBUG_STRIPPED or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_LOCAL_SYMS_STRIPPED or IMAGE_FILE_RELOCS_STRIPPED}

var
  Wnd: HWND;
  i: Integer;
  CallExit: Boolean;
  ExitCode: UINT;
  Registry: TRegistry;

begin
  Registry := TRegistry.Create;
  try
    try
      Registry.RootKey := HKEY_CURRENT_USER;
      if Registry.KeyExists(REG_Key) then
        if Registry.OpenKeyReadOnly(REG_Key) then
        try
          if Registry.ValueExists(REG_LanguageId) then
            TLang.LanguageId := Registry.ReadInteger(REG_LanguageId)
          else if Registry.ValueExists(REG_Language) then
            TLang.LanguageId := TLang.LocaleNameToLCID(Registry.ReadString(REG_Language));
        finally
          Registry.CloseKey;
        end;
    finally
      Registry.Free;
    end;
  except
    TLang.GetStringRes(HInstance, 0, TLang.EffectiveLanguageId);
  end;

  //TLang.LanguageId := MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US);       // 1033 (0x0409)

  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_LOWEST);

  AutorunManager.AddProvider(TRegistryProvider.Create, False, True);
  AutorunManager.AddProvider(TTaskScheduler2Provider.Create, True, False);
  AutorunManager.Options.HighestRunLevel := True;
  AutorunManager.Options.Priority := apRealtime;

  CallExit := False;
  ExitCode := TTasks.ERROR_Ok;
  for i := 1 to ParamCount do
    ExitCode := ExitCode or TTasks.Perform(ParamStr(i), CallExit);
  if CallExit then ExitProcess(ExitCode);

  // Проверка запущеной копии программы
  TMutexLocker.Init('MouseMACMutex');
  TMutexLocker.Lock;
  if TMutexLocker.IsExist then
  begin
    Wnd := FindWindow('TMouseExForm', nil);
    if Wnd <> 0 then begin
      ShowWindowAsync(Wnd, SW_SHOW);
      SetForegroundWindow(Wnd);
    end;
    TMutexLocker.Unlock;
    ExitProcess(TTasks.ERROR_Mutex);
  end;

  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title := TLang[1];
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMouseExForm, MouseExForm);
  Application.Run;

  TMutexLocker.Unlock;
end.

