unit Mouse.Mac;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.PsAPI,
  System.SysUtils, System.Classes, System.SyncObjs,
  Versions.Helpers;

type
  TEventStateChange = procedure(Sender: TObject; State: Boolean) of object;

  TWindowWheelMethods = set of (
    wwmSkip,
    wwmDefault,
    wwmRealChild,
    wwmRoot,
    wwmNeedFocus,
    wwmKillFocus,
    wwmScroll,
    wwmSkipHScroll,
    wwmHScrollAsHWheel,
    wwmHInvert);

  TWindowWheelInfo = record
  strict private type
    TEnumChildParam = record
      Window: HWND;
      IsChild: Boolean;
    end;
    PEnumChildParam = ^TEnumChildParam;
  strict private
    FAncestorRoot: HWND;
    FAncestorRootName: string;
    FAncestorRootText: string;
    FClassName: string;
    FText: string;
    FParent: HWND;
    FParentClassName: string;
    FExePath: string;
    FExeName: string;
    function GetAncestorRoot: HWND; inline;
    function GetAncestorRootName: string; inline;
    function GetAncestorRootText: string; inline;
    function GetIsWindowDesktop: Boolean; inline;
    function GetClassName: string; inline;
    function GetText: string; inline;
    function GetParent: HWND; inline;
    function GetParentClassName: string; inline;
    function GetRealWheelWindow(Index: TPoint): HWND; inline;
    function GetExePath: string; inline;
    function GetExeName: string; inline;
    function GetWheelMethods(HScrollChecking: Boolean): TWindowWheelMethods; inline;
  public
    Window: HWND;
    WheelMethods: TWindowWheelMethods;
    WheelWindow: HWND;

    constructor Create(aWindow: HWND; aPoint: TPoint; aHScrollChecking: Boolean);
    
    property AncestorRoot: HWND read GetAncestorRoot;
    property AncestorRootName: string read GetAncestorRootName;
    property AncestorRootText: string read GetAncestorRootText;
    property IsWindowDesktop: Boolean read GetIsWindowDesktop;
    property ClassName: string read GetClassName;
    property Text: string read GetText;
    property Parent: HWND read GetParent;
    property ParentClassName: string read GetParentClassName;
    property RealWheelWindow[Index: TPoint]: HWND read GetRealWheelWindow;
    property ExePath: string read GetExePath;
    property ExeName: string read GetExeName;
  private
    class procedure Init; static;
    class procedure Done; static;
  strict private
    class var FWindowsVistaOrGreater: Boolean;
    class var FWindows8OrGreater: Boolean;
    class var FWindows8Point1OrGreater: Boolean;
    class var FWindows10OrGreater: Boolean;
    class var FWindows10WndWhiteList: TStringList;

    class function EnumChildProc(wnd: HWND; lParam: LPARAM): BOOL; stdcall; static; inline;
  public
    class function PhysicalToLogicalPointUniversal(hWnd: HWND;
      var lpPoint: TPoint): BOOL; stdcall; static; inline;

    class function GetWindowClass(Wnd: HWND): string; stdcall; static; inline;
    class function GetWindowText(Wnd: HWND): string; stdcall; static; inline;
    class function GetWindowExePath(Wnd: HWND): string; stdcall; static; inline;
  end;

  TMouseMac = class
  public const
    DefaultVerticalSensitivity = 1.0;
    DefaultHorizontalSensitivity = 1.0;
  private const
    WH_MOUSE_LL = 14;
    HC_ACTION = 0;
    LLMHF_INJECTED          = $00000001;
    LLMHF_LOWER_IL_INJECTED = $00000002;
    WM_HOOK   = WM_USER + 256;
    WM_UNHOOK = WM_USER + 257;
  private type
    tagMSLLHOOKSTRUCT = record
      pt: TPoint;
      mouseData: DWORD;
      flags: DWORD;
      time: DWORD;
      dwExtraInfo: ULONG_PTR;
    end;
    MSLLHOOKSTRUCT = tagMSLLHOOKSTRUCT;
    PMSLLHOOKSTRUCT = ^MSLLHOOKSTRUCT;
    LPMSLLHOOKSTRUCT = ^MSLLHOOKSTRUCT;
  private
    class var HookHandle: HHOOK;
    class var StateChangeCriticalSection: TCriticalSection;
    class var HThread: THandle;
    class var IdThread: DWORD;
    class var FPreviousWindowWheelInfo: TWindowWheelInfo;
    class var FEnable: Boolean;
    class var FInvert: Boolean;
    class var FHorizontalScrollOnShiftDown: Boolean;
    class var FVerticalSensitivity: Double;
    class var FHorizontalSensitivity: Double;
    class var FOnStateChange: TEventStateChange;
    class var FOnInvertChange: TEventStateChange;
    class var FOnHorizontalScrollOnShiftDownChange: TEventStateChange;
    class procedure Init;
    class procedure Done;
    class function Hook: boolean; static;
    class function UnHook: boolean; static;
    class function LowLevelMouseProc(nCode: Integer; wParam: WPARAM;
      lParam: LPARAM): LRESULT; stdcall; static;
    class function ThreadExecute(lpParameter: LPVOID): DWORD; stdcall; static;
    class procedure SetEnable(const Value: Boolean); static;
    class procedure SetInvert(const Value: Boolean); static;
    class procedure SetHorizontalScrollOnShiftDown(const Value: Boolean); static;
    class procedure SetOnStateChange(const Value: TEventStateChange); static;
    class procedure SetOnInvertChange(const Value: TEventStateChange); static;
    class procedure SetOnHorizontalScrollOnShiftDownChange(
      const Value: TEventStateChange); static;
    class procedure DoStateChange(ThreadHookEnable: Boolean);
  public
    class property Enable: Boolean read FEnable write SetEnable;
    class property Invert: Boolean read FInvert write SetInvert;
    class property HorizontalScrollOnShiftDown: Boolean read FHorizontalScrollOnShiftDown write SetHorizontalScrollOnShiftDown;
    class property VerticalSensitivity: Double read FVerticalSensitivity write FVerticalSensitivity;
    class property HorizontalSensitivity: Double read FHorizontalSensitivity write FHorizontalSensitivity;
    class property OnStateChange: TEventStateChange read FOnStateChange write SetOnStateChange;
    class property OnInvertChange: TEventStateChange read FOnInvertChange write SetOnInvertChange;
    class property OnHorizontalScrollOnShiftDownChange: TEventStateChange read FOnHorizontalScrollOnShiftDownChange write SetOnHorizontalScrollOnShiftDownChange;
  end;

{$WARN SYMBOL_PLATFORM OFF}
  {$EXTERNALSYM IsImmersiveProcess}
function IsImmersiveProcess(hProcess: THandle): BOOL; stdcall; external user32 delayed;

  {$EXTERNALSYM LogicalToPhysicalPointForPerMonitorDPI}
function LogicalToPhysicalPointForPerMonitorDPI(
  hWnd: HWND;
  var lpPoint: TPoint): BOOL; stdcall; external user32 delayed;

  {$EXTERNALSYM PhysicalToLogicalPointForPerMonitorDPI}
function PhysicalToLogicalPointForPerMonitorDPI(
  hWnd: HWND;
  var lpPoint: TPoint): BOOL; stdcall; external user32 delayed;
{$WARN SYMBOL_PLATFORM ON}

implementation

{ TMouseMac }

class procedure TMouseMac.SetEnable(const Value: Boolean);
var
  ThreadAvalibleEvent: TEvent;
begin
  if FEnable = Value then Exit;

  if HThread = 0 then
  begin
    ThreadAvalibleEvent := TEvent.Create;
    HThread := CreateThread(nil, 0, @ThreadExecute, @ThreadAvalibleEvent, 0, IdThread);
    SetThreadPriority(HThread, THREAD_PRIORITY_TIME_CRITICAL);
    ThreadAvalibleEvent.WaitFor;
    ThreadAvalibleEvent.Free;
  end;

  if Value then Hook else UnHook;
end;

class procedure TMouseMac.SetInvert(const Value: Boolean);
begin
  if FInvert = Value then Exit;
  FInvert := Value;
  if Assigned(FOnInvertChange) then FOnInvertChange(nil, FInvert);
end;

class procedure TMouseMac.SetHorizontalScrollOnShiftDown(const Value: Boolean);
begin
  if FHorizontalScrollOnShiftDown = Value then Exit;
  FHorizontalScrollOnShiftDown := Value;
  if Assigned(FOnHorizontalScrollOnShiftDownChange) then FOnHorizontalScrollOnShiftDownChange(nil, FHorizontalScrollOnShiftDown);
end;

class procedure TMouseMac.SetOnStateChange(const Value: TEventStateChange);
begin
  FOnStateChange := Value;
  if Assigned(FOnStateChange) then FOnStateChange(nil, FEnable);
end;

class procedure TMouseMac.SetOnInvertChange(const Value: TEventStateChange);
begin
  FOnInvertChange := Value;
  if Assigned(FOnInvertChange) then FOnInvertChange(nil, FInvert);
end;

class procedure TMouseMac.SetOnHorizontalScrollOnShiftDownChange(
  const Value: TEventStateChange);
begin
  FOnHorizontalScrollOnShiftDownChange := Value;
  if Assigned(FOnHorizontalScrollOnShiftDownChange) then FOnHorizontalScrollOnShiftDownChange(nil, FHorizontalScrollOnShiftDown);
end;

class function TMouseMac.Hook: Boolean;
begin
  Result:= PostThreadMessage(IdThread, WM_HOOK, 0, 0);
end;

class function TMouseMac.UnHook: Boolean;
begin
  Result:= PostThreadMessage(IdThread, WM_UNHOOK, 0, 0);
end;

class procedure TMouseMac.DoStateChange(ThreadHookEnable: Boolean);
begin
  StateChangeCriticalSection.Enter;
  FEnable:= ThreadHookEnable;
  if Assigned(FOnStateChange) then FOnStateChange(nil, FEnable);
  StateChangeCriticalSection.Leave;
end;

class function TMouseMac.LowLevelMouseProc(nCode: Integer; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
var
  WheelMessage: Winapi.Windows.WPARAM;
  PMsLl: LPMSLLHOOKSTRUCT;
  WheelDelta: SHORT;
  IsShiftDown: Boolean;
  IsHScroll: Boolean;
  KeyState: Word;
  Wnd: HWND;
  wP: Winapi.Windows.WPARAM;
  lP: Winapi.Windows.LPARAM;
begin
  try
    if nCode <> HC_ACTION then
      Exit(CallNextHookEx(HookHandle, nCode, wParam, lParam));

    case wParam of
      WM_MOUSEWHEEL, WM_MOUSEHWHEEL: begin
        WheelMessage := wParam;

        PMsLl := LPMSLLHOOKSTRUCT(lParam);

        Wnd := WindowFromPoint(PMsLl^.pt);
        if Wnd = 0 then
          Exit(CallNextHookEx(HookHandle, nCode, wParam, lParam));

        if FPreviousWindowWheelInfo.Window <> Wnd then
          FPreviousWindowWheelInfo.Create(Wnd, PMsLl^.pt, FHorizontalScrollOnShiftDown);

        if wwmSkip in FPreviousWindowWheelInfo.WheelMethods then
          Exit(CallNextHookEx(HookHandle, nCode, wParam, lParam));
            
        if FInvert then
          WheelDelta := - HiWord(PMsLl^.mouseData)
        else
          WheelDelta := HiWord(PMsLl^.mouseData);

        IsShiftDown := HiByte(GetKeyState(VK_SHIFT)) <> 0;
        IsHScroll := IsShiftDown and
                     FHorizontalScrollOnShiftDown and
                     not (wwmSkipHScroll in FPreviousWindowWheelInfo.WheelMethods);

        if IsHScroll then WheelMessage := WM_MOUSEHWHEEL;

        if (WheelMessage = WM_MOUSEHWHEEL) and (wwmHInvert in FPreviousWindowWheelInfo.WheelMethods) then
          WheelDelta := - WheelDelta;

        if (wwmScroll in FPreviousWindowWheelInfo.WheelMethods) or
           (IsHScroll and not (wwmHScrollAsHWheel in FPreviousWindowWheelInfo.WheelMethods)) then
        begin
          if WheelMessage = WM_MOUSEWHEEL then
            WheelMessage := WM_VSCROLL
          else
            WheelMessage := WM_HSCROLL;

          if WheelDelta > 0 then
            wP := MakeWParam(SB_LINEUP, 0)
          else
            wP := MakeWParam(SB_LINEDOWN, 0);

          lP := 0;
        end
        else
        begin
          KeyState:= 0;
          if IsShiftDown                          then KeyState := KeyState or MK_SHIFT;
          if HiByte(GetKeyState(VK_LBUTTON)) <> 0 then KeyState := KeyState or MK_LBUTTON;
          if HiByte(GetKeyState(VK_RBUTTON)) <> 0 then KeyState := KeyState or MK_RBUTTON;
          if HiByte(GetKeyState(VK_CONTROL)) <> 0 then KeyState := KeyState or MK_CONTROL;
          if HiByte(GetKeyState(VK_MBUTTON)) <> 0 then KeyState := KeyState or MK_MBUTTON;

          if (WheelMessage = WM_MOUSEHWHEEL) or (IsShiftDown and FHorizontalScrollOnShiftDown) then
            WheelDelta := Round(WheelDelta * FHorizontalSensitivity)
          else
            WheelDelta := Round(WheelDelta * FVerticalSensitivity);

          wP := MakeWParam(KeyState, WheelDelta);
          lP := MakeLParam(PMsLl^.pt.X, PMsLl^.pt.Y);

          if wwmNeedFocus in FPreviousWindowWheelInfo.WheelMethods then
            PostMessage(FPreviousWindowWheelInfo.WheelWindow, WM_SETFOCUS, 0, 0)
          else if wwmKillFocus in FPreviousWindowWheelInfo.WheelMethods then
            PostMessage(FPreviousWindowWheelInfo.WheelWindow, WM_KILLFOCUS, 0, 0);
        end;

        if PostMessage(FPreviousWindowWheelInfo.WheelWindow, WheelMessage, wP, lP) then
          Result:= LRESULT(-1)
        else
          Exit(CallNextHookEx(HookHandle, nCode, wParam, lParam));
      end;
      else
        Exit(CallNextHookEx(HookHandle, nCode, wParam, lParam));
    end;
  except
    Exit(CallNextHookEx(HookHandle, nCode, wParam, lParam));
  end;
end;

class function TMouseMac.ThreadExecute(lpParameter: LPVOID): DWORD;
var
  Msg: TMsg;
  bRet: BOOL;
begin
  Result := 0;
  PeekMessage(Msg, HWND(-1), 0, 0, PM_NOREMOVE);
  TEvent(lpParameter^).SetEvent;
  try
    repeat
      bRet := GetMessage(Msg, HWND(-1), 0, 0);
      if LONG(bRet) <> -1 then begin
        case Msg.message of
          WM_HOOK: begin
            HookHandle:= SetWindowsHookEx(WH_MOUSE_LL, @LowLevelMouseProc, HInstance, 0);
            DoStateChange(HookHandle <> 0);
          end;
          WM_UNHOOK: begin
            if HookHandle <> 0 then
              if UnhookWindowsHookEx(HookHandle) then HookHandle:= 0;
            DoStateChange(False);
          end;
        end;

        DispatchMessage(Msg);
      end;
    until (not bRet);
  finally
    if HookHandle <> 0 then
      if UnhookWindowsHookEx(HookHandle) then HookHandle:= 0;
  end;
end;

class procedure TMouseMac.Init;
begin
  StateChangeCriticalSection := TCriticalSection.Create;
  HookHandle := 0;
  FEnable := False;
  FInvert := False;
  FHorizontalScrollOnShiftDown := False;
  FVerticalSensitivity := DefaultVerticalSensitivity;
  FHorizontalSensitivity := DefaultHorizontalSensitivity;
  HThread := 0;
end;

class procedure TMouseMac.Done;
begin
  UnHook;
  PostThreadMessage(IdThread, WM_QUIT, 0, 0);
end;

{ TWindowWheelInfo }

constructor TWindowWheelInfo.Create(aWindow: HWND; aPoint: TPoint; aHScrollChecking: Boolean);
begin
  Window := aWindow;
  FAncestorRoot := 0;
  FAncestorRootName := '';
  FClassName := '';

  WheelMethods := GetWheelMethods(aHScrollChecking);

  if wwmDefault in WheelMethods then
    WheelWindow := Window
  else if wwmRealChild in WheelMethods then
    WheelWindow := RealWheelWindow[aPoint]
  else if wwmRoot in WheelMethods then
    WheelWindow := AncestorRoot
  else
    WheelWindow := 0;

  if WheelWindow = 0 then
    WheelMethods := [wwmSkip];
end;

function TWindowWheelInfo.GetAncestorRoot: HWND;
begin
  if FAncestorRoot = 0 then
    FAncestorRoot := GetAncestor(Window, GA_ROOT);
    
  Exit(FAncestorRoot);
end;

function TWindowWheelInfo.GetAncestorRootName: string;
begin
  if FAncestorRootName.IsEmpty then
    FAncestorRootName := GetWindowClass(AncestorRoot);

  Result := FAncestorRootName;
end;

function TWindowWheelInfo.GetAncestorRootText: string;
begin
  if FAncestorRootText.IsEmpty then
    FAncestorRootText := GetWindowText(AncestorRoot);

  Result := FAncestorRootText;
end;

function TWindowWheelInfo.GetClassName: string;
begin
  if FClassName.IsEmpty then
    FClassName := GetWindowClass(Window);

  Result := FClassName;
end;

function TWindowWheelInfo.GetText: string;
begin
  if FText.IsEmpty then
    FText := GetWindowText(Window);

  Result := FText;
end;

function TWindowWheelInfo.GetParent: HWND;
begin
  if FParent = 0 then
    FParent := Winapi.Windows.GetParent(Window);

  Exit(FParent);
end;

function TWindowWheelInfo.GetParentClassName: string;
begin
  if FParentClassName.IsEmpty then
    FParentClassName := GetWindowClass(Parent);

  Result := FParentClassName;
end;

function TWindowWheelInfo.GetIsWindowDesktop: Boolean;
var
  ProcessId: DWORD;
  ProcessHandle: THandle;
  EnumChildParam: TEnumChildParam;
begin
  Result := False;

  if FWindows10OrGreater then
  begin
    GetWindowThreadProcessId(Window, ProcessId);
    ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessId);
    if ProcessHandle <> 0 then
    begin
      Result := not IsImmersiveProcess(ProcessHandle);
      if FExePath.IsEmpty then
      begin
        SetLength(FExePath, MAX_PATH);
        SetLength(FExePath, GetModuleFileNameEx(ProcessHandle, 0, LPTSTR(FExePath), MAX_PATH));
      end;
      
      if not Result then
      begin
        Result := FWindows10WndWhiteList.IndexOf(ExeName) >= 0;
      end;
      CloseHandle(ProcessHandle);
    end;
    Exit;
  end;

  EnumChildParam.Window := AncestorRoot;
  if EnumChildParam.Window = 0 then Exit;

  EnumChildParam.IsChild := False;
  EnumWindows(@EnumChildProc, LPARAM(@EnumChildParam));
  Result := EnumChildParam.IsChild;
  if not Result then
    Result := (GetWindowLong(EnumChildParam.Window, GWL_STYLE) and WS_CHILD) = WS_CHILD;
end;

function TWindowWheelInfo.GetRealWheelWindow(Index: TPoint): HWND;
var
  RootWnd: HWND;
  ChildWnd: HWND;
  WndRect: TRect;
  PointInWindow: TPoint;
  LogicalTopLeft: TPoint;
begin
  Result := Window;
  RootWnd := AncestorRoot;
  ChildWnd := RootWnd;
  while (ChildWnd <> 0) and (ChildWnd <> Result) do
  begin
    Result := ChildWnd;

    PointInWindow := Index;

    MapWindowPoints(HWND_DESKTOP, ChildWnd, PointInWindow, 1);

    if FWindowsVistaOrGreater then
      if GetWindowRect(ChildWnd, WndRect) then
      begin
        PointInWindow := PointInWindow.Add(WndRect.TopLeft);

        PhysicalToLogicalPointUniversal(ChildWnd, PointInWindow);

        LogicalTopLeft := WndRect.TopLeft;
        PhysicalToLogicalPointUniversal(ChildWnd, LogicalTopLeft);

        PointInWindow := PointInWindow.Subtract(LogicalTopLeft);
      end;

    ChildWnd := RealChildWindowFromPoint(ChildWnd, PointInWindow);
  end;
end;

function TWindowWheelInfo.GetExePath: string;
begin
  if FExePath.IsEmpty then
    FExePath := GetWindowExePath(Window);

  Result := FExePath;
end;

function TWindowWheelInfo.GetExeName: string;
begin
  if FExeName.IsEmpty then
    FExeName := ExtractFileName(ExePath);

  Result := FExeName;
end;

function TWindowWheelInfo.GetWheelMethods(HScrollChecking: Boolean): TWindowWheelMethods;
begin
  Result := [wwmDefault];

  // MetroApp
  if FWindows8OrGreater then
  begin
    if not IsWindowDesktop then
      Exit([wwmSkip]);
  end;
  
  // VMWare
  if ClassName = 'MKSEmbedded' then
  begin
    if GetForegroundWindow = AncestorRoot then
      Exit([wwmSkip]);

    Exit;
  end;

  // Переменные среды и т.п.
  if AncestorRootName = '#32770' then
  begin
    Exit([wwmRealChild]);
  end;

  // Skype
  if (ClassName = 'TChatContentControl') or (ClassName = 'TConversationsControl') then
  begin
    Exit([wwmDefault, wwmNeedFocus]);
  end;

  // IP-TV Player каналы
  if AncestorRootName = 'IpTvPlayerMainWndClass' then
  begin
    Exit([wwmRoot]);
  end;

  // Центр обновления Windows
  if ClassName = 'DirectUIHWND' then
  begin
    if ParentClassName = 'XBabyHost' then
      Exit([wwmDefault, wwmKillFocus]);
  end;

  // Управление дисками
  if ClassName = 'AfxWnd42u' then
  begin
    if Text = 'DMDiskView' then
      Exit([wwmScroll]);
  end;

  // Microsoft PowerToys
  if ExePath.Contains('PowerToys') then
  begin
    Exit([wwmSkip]);
  end;

  if (HScrollChecking) then
  begin
    // Браузеры на Chromium
    if ClassName = 'Chrome_RenderWidgetHostHWND' then
    begin
      Exit([wwmDefault, wwmSkipHScroll]);
    end;

    // AkelPad
    if ClassName = 'AkelEditW' then
    begin
      Exit([wwmDefault, wwmHScrollAsHWheel, wwmHInvert]);
    end;

    // CorelDRAW
    if ClassName.StartsWith('CorelDRAW') then
    begin
      Exit([wwmDefault, wwmSkipHScroll]);
    end;

    // Adobe
    if (ExePath.Contains('Adobe')) or
       (AncestorRootName = 'Photoshop') or
       (AncestorRootName = 'illustrator') or
       (AncestorRootName.StartsWith('audition')) or
       (AncestorRootName.StartsWith('Adobe Media Encoder')) or
       (AncestorRootName = 'Premiere Pro') or
       (AncestorRootName = 'AcrobatSDIWindow') then
    begin
      Exit([wwmDefault, wwmSkipHScroll]);
    end;

    // Java
    if ClassName = 'SunAwtFrame' then
    begin
      Exit([wwmDefault, wwmSkipHScroll]);
    end;

    // AIMP
    if CompareText(ExeName, 'AIMP.exe') = 0 then
    begin
      Exit([wwmDefault, wwmSkipHScroll]);
    end;

    // RDP
    if AncestorRootName = 'TscShellContainerClass' then
    begin
      Exit([wwmDefault, wwmSkipHScroll]);
    end;
  end;
end;

class function TWindowWheelInfo.EnumChildProc(wnd: HWND; lParam: LPARAM): BOOL;
var
  EnumChildParam: PEnumChildParam;
begin
  EnumChildParam := PEnumChildParam(lParam);
  if wnd = EnumChildParam^.Window then begin
    EnumChildParam^.IsChild := True;
    Result:= False;
  end else
    Result:= True;
end;

class function TWindowWheelInfo.PhysicalToLogicalPointUniversal(hWnd: HWND;
  var lpPoint: TPoint): BOOL;
begin
  if FWindows8Point1OrGreater then
    Exit(PhysicalToLogicalPointForPerMonitorDPI(hWnd, lpPoint));

  if FWindowsVistaOrGreater then
    Exit(PhysicalToLogicalPoint(hWnd, lpPoint));

  Result := True;
end;

class function TWindowWheelInfo.GetWindowClass(Wnd: HWND): string;
var
  WndClassLng: Integer;
begin
  SetLength(Result, MAX_PATH);
  WndClassLng := Winapi.Windows.GetClassName(Wnd, LPTSTR(Result), MAX_PATH);
  if WndClassLng > 0 then
    SetLength(Result, WndClassLng)
  else
    Result := '';
end;

class function TWindowWheelInfo.GetWindowText(Wnd: HWND): string;
var
  WndTextLength: Integer;
begin
  WndTextLength := GetWindowTextLength(Wnd);
  if WndTextLength > 0 then
  begin
    SetLength(Result, WndTextLength);
    WndTextLength := Winapi.Windows.GetWindowText(Wnd, LPTSTR(Result), WndTextLength + 1);
    SetLength(Result, WndTextLength);
  end
  else
    Result := '';
end;

class function TWindowWheelInfo.GetWindowExePath(Wnd: HWND): string;
var
  ProcessId: DWORD;
  ProcessHandle: THandle;
begin
  GetWindowThreadProcessId(Wnd, ProcessId);
  if ProcessId = 0 then Exit('');

  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessId);
  if ProcessHandle = 0 then Exit('');

  SetLength(Result, MAX_PATH);
  SetLength(Result, GetModuleFileNameEx(ProcessHandle, 0, LPTSTR(Result), MAX_PATH));

  CloseHandle(ProcessHandle);
end;

class procedure TWindowWheelInfo.Init;
begin
  FWindowsVistaOrGreater := IsWindowsVistaOrGreater;
  FWindows8OrGreater := IsWindows8OrGreater;
  FWindows8Point1OrGreater := IsWindows8Point1OrGreater;
  FWindows10OrGreater := IsWindows10OrGreater;

  FWindows10WndWhiteList := TStringList.Create;
  with FWindows10WndWhiteList do
  begin
    CaseSensitive := False;
    BeginUpdate;

    Add('explorer.exe');
    Add('Taskmgr.exe');

    EndUpdate;
    Sorted := True;
  end;
end;

class procedure TWindowWheelInfo.Done;
begin
  FWindows10WndWhiteList.Free;
end;

initialization
  TWindowWheelInfo.Init;
  TMouseMac.Init;

finalization
  TMouseMac.Done;
  TWindowWheelInfo.Done;

end.

