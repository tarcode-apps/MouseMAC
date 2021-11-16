unit Desktop;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes,
  Vcl.Dialogs;

type
  TEventStateChange = procedure(Sender: TObject; Capable: Boolean; State: Boolean) of object;

  TDesktopManager = class
  private
    class var FMsgWindow: HWND;

    class var FDisableOverlappedContent: Boolean;
    class var FIsDisableOverlappedContentCapable: Boolean;

    class var FClientAreaAnimation: Boolean;
    class var FIsClientAreaAnimationCapable: Boolean;

    class var FUIEffects: Boolean;
    class var FIsUIEffectsCapable: Boolean;

    class var FListboxSmoothScrolling: Boolean;
    class var FIsListboxSmoothScrollingCapable: Boolean;

    class var FOnDisableOverlappedContent: TEventStateChange;
    class var FOnClientAreaAnimation: TEventStateChange;
    class var FOnUIEffects: TEventStateChange;
    class var FOnListboxSmoothScrolling: TEventStateChange;

    class constructor Create;
    class destructor Destroy;

    class procedure MsgWindowHandle(var Message: TMessage);
    class function GetSystemParametersInfo(uiAction, uiParam: UINT; var Value: Boolean): Boolean;
    class function SetSystemParametersInfo(uiAction, uiParam: UINT; Value: Boolean): Boolean;

    class function GetDisableOverlappedContent(var Value: Boolean): Boolean;
    class function SetDisableOverlappedContent(Value: Boolean): Boolean;

    class function GetClientAreaAnimation(var Value: Boolean): Boolean;
    class function SetClientAreaAnimation(Value: Boolean): Boolean;

    class function GetUIEffects(var Value: Boolean): Boolean;
    class function SetUIEffects(Value: Boolean): Boolean;

    class function GetListboxSmoothScrolling(var Value: Boolean): Boolean;
    class function SetListboxSmoothScrolling(Value: Boolean): Boolean;

    class procedure SetDisableOverlappedContentProp(const Value: Boolean); static;
    class procedure SetClientAreaAnimationProp(const Value: Boolean); static;
    class procedure SetUIEffectsProp(const Value: Boolean); static;
    class procedure SetListboxSmoothScrollingProp(const Value: Boolean); static;

    class procedure SetOnDisableOverlappedContent(
      const Value: TEventStateChange); static;
    class procedure SetOnClientAreaAnimation(
      const Value: TEventStateChange); static;
    class procedure SetOnUIEffects(
      const Value: TEventStateChange); static;
    class procedure SetOnListboxSmoothScrolling(
      const Value: TEventStateChange); static;
  public
    class property DisableOverlappedContent: Boolean read FDisableOverlappedContent write SetDisableOverlappedContentProp;
    class property ClientAreaAnimation: Boolean read FClientAreaAnimation write SetClientAreaAnimationProp;
    class property UIEffects: Boolean read FUIEffects write SetUIEffectsProp;
    class property ListboxSmoothScrolling: Boolean read FListboxSmoothScrolling write SetListboxSmoothScrollingProp;

    class property IsDisableOverlappedContentCapable: Boolean read FIsDisableOverlappedContentCapable;
    class property IsClientAreaAnimationCapable: Boolean read FIsClientAreaAnimationCapable;
    class property IsUIEffectsCapable: Boolean read FIsUIEffectsCapable;
    class property IsListboxSmoothScrollingCapable: Boolean read FIsListboxSmoothScrollingCapable;

    class property OnDisableOverlappedContent: TEventStateChange read FOnDisableOverlappedContent write SetOnDisableOverlappedContent;
    class property OnClientAreaAnimation: TEventStateChange read FOnClientAreaAnimation write SetOnClientAreaAnimation;
    class property OnUIEffects: TEventStateChange read FOnUIEffects write SetOnUIEffects;
    class property OnListboxSmoothScrolling: TEventStateChange read FOnListboxSmoothScrolling write SetOnListboxSmoothScrolling;
  end;

implementation

{$REGION 'Setter and Getter'}
class procedure TDesktopManager.SetDisableOverlappedContentProp(const Value: Boolean);
begin
  FIsDisableOverlappedContentCapable := SetDisableOverlappedContent(Value);
  if not FIsDisableOverlappedContentCapable then FDisableOverlappedContent := False;
end;

class procedure TDesktopManager.SetClientAreaAnimationProp(
  const Value: Boolean);
begin
  FIsClientAreaAnimationCapable := SetClientAreaAnimation(Value);
  if not FIsClientAreaAnimationCapable then FClientAreaAnimation := False;
end;

class procedure TDesktopManager.SetUIEffectsProp(const Value: Boolean);
begin
  FIsUIEffectsCapable := SetUIEffects(Value);
  if not FIsUIEffectsCapable then FUIEffects := False;
end;

class procedure TDesktopManager.SetListboxSmoothScrollingProp(
  const Value: Boolean);
begin
  FIsListboxSmoothScrollingCapable := SetListboxSmoothScrolling(Value);
  if not FIsListboxSmoothScrollingCapable then begin
    FListboxSmoothScrolling := False;
    if Assigned(FOnListboxSmoothScrolling) then
      FOnListboxSmoothScrolling(nil, FIsListboxSmoothScrollingCapable, FListboxSmoothScrolling);
  end;
end;
{$ENDREGION}

{$REGION 'Events'}
class procedure TDesktopManager.SetOnDisableOverlappedContent(
  const Value: TEventStateChange);
begin
  FOnDisableOverlappedContent := Value;
  if Assigned(FOnDisableOverlappedContent) then
    FOnDisableOverlappedContent(nil, FIsDisableOverlappedContentCapable, FDisableOverlappedContent);
end;

class procedure TDesktopManager.SetOnClientAreaAnimation(
  const Value: TEventStateChange);
begin
  FOnClientAreaAnimation := Value;
  if Assigned(FOnClientAreaAnimation) then
    FOnClientAreaAnimation(nil, FIsClientAreaAnimationCapable, FClientAreaAnimation);
end;

class procedure TDesktopManager.SetOnUIEffects(
  const Value: TEventStateChange);
begin
  FOnUIEffects := Value;
  if Assigned(FOnUIEffects) then
    FOnUIEffects(nil, FIsUIEffectsCapable, FUIEffects);
end;

class procedure TDesktopManager.SetOnListboxSmoothScrolling(
  const Value: TEventStateChange);
begin
  FOnListboxSmoothScrolling := Value;
  if Assigned(FOnListboxSmoothScrolling) then
    FOnListboxSmoothScrolling(nil, FIsListboxSmoothScrollingCapable, FListboxSmoothScrolling);
end;
{$ENDREGION}


class function TDesktopManager.GetSystemParametersInfo(uiAction, uiParam: UINT; var Value: Boolean): Boolean;
var
  pvParam: Pointer;
  Val: BOOL;
begin
  pvParam := @Val;
  Result := SystemParametersInfo(uiAction, uiParam, pvParam, 0);
  Value := Val;
end;

class function TDesktopManager.SetSystemParametersInfo(uiAction, uiParam: UINT; Value: Boolean): Boolean;
var
  pvParam: Pointer;
  Val: BOOL;
begin
  Val := Value;
  if Val then pvParam := @Val else pvParam := nil;
  Result := SystemParametersInfo(uiAction, uiParam, pvParam, SPIF_UPDATEINIFILE or SPIF_SENDWININICHANGE);
end;


{ Disable Overlapped Content }

class function TDesktopManager.GetDisableOverlappedContent(var Value: Boolean): Boolean;
begin
  Result := GetSystemParametersInfo(SPI_GETDISABLEOVERLAPPEDCONTENT, 0, Value);
end;

class function TDesktopManager.SetDisableOverlappedContent(Value: Boolean): Boolean;
begin
  if Value = FDisableOverlappedContent then Exit(True);
  Result := SetSystemParametersInfo(SPI_SETDISABLEOVERLAPPEDCONTENT, 0, Value);
end;


{ Client Area Animation }

class function TDesktopManager.GetClientAreaAnimation(var Value: Boolean): Boolean;
begin
  Result := GetSystemParametersInfo(SPI_GETCLIENTAREAANIMATION, 0, Value);
end;

class function TDesktopManager.SetClientAreaAnimation(Value: Boolean): Boolean;
begin
  if Value = FClientAreaAnimation then Exit(True);
  Result := SetSystemParametersInfo(SPI_SETCLIENTAREAANIMATION, 0, Value);
end;


{ UI Effects }

class function TDesktopManager.GetUIEffects(var Value: Boolean): Boolean;
begin
  Result := GetSystemParametersInfo(SPI_GETUIEFFECTS, 0, Value);
end;

class function TDesktopManager.SetUIEffects(Value: Boolean): Boolean;
begin
  if Value = FUIEffects then Exit(True);
  Result := SetSystemParametersInfo(SPI_SETUIEFFECTS, 0, Value);
end;


{ Listbox Smooth Scrolling }

class function TDesktopManager.GetListboxSmoothScrolling(var Value: Boolean): Boolean;
begin
  Result := GetSystemParametersInfo(SPI_GETLISTBOXSMOOTHSCROLLING, 0, Value);
end;

class function TDesktopManager.SetListboxSmoothScrolling(Value: Boolean): Boolean;
begin
  if Value = FListboxSmoothScrolling then Exit(True);
  Result := SetSystemParametersInfo(SPI_SETLISTBOXSMOOTHSCROLLING, 0, Value);
end;


class procedure TDesktopManager.MsgWindowHandle(var Message: TMessage);
begin
  if Message.Msg = WM_SETTINGCHANGE then begin
    Message.Result := 0;
    case Message.WParam of
      SPI_SETDISABLEOVERLAPPEDCONTENT: begin
        FIsDisableOverlappedContentCapable := GetDisableOverlappedContent(FDisableOverlappedContent);
        if not FIsDisableOverlappedContentCapable then FDisableOverlappedContent := False;
        if Assigned(FOnDisableOverlappedContent) then
          FOnDisableOverlappedContent(nil, FIsDisableOverlappedContentCapable, FDisableOverlappedContent);
      end;
      SPI_SETCLIENTAREAANIMATION: begin
        FIsClientAreaAnimationCapable := GetClientAreaAnimation(FClientAreaAnimation);
        if not FIsClientAreaAnimationCapable then FClientAreaAnimation := False;
        if Assigned(FOnClientAreaAnimation) then
          FOnClientAreaAnimation(nil, FIsClientAreaAnimationCapable, FClientAreaAnimation);
      end;
      SPI_SETUIEFFECTS: begin
        FIsUIEffectsCapable := GetUIEffects(FUIEffects);
        if not FIsUIEffectsCapable then FUIEffects := False;
        if Assigned(FOnUIEffects) then
          FOnUIEffects(nil, FIsUIEffectsCapable, FUIEffects);

        FIsListboxSmoothScrollingCapable := GetListboxSmoothScrolling(FListboxSmoothScrolling);
        if not FIsListboxSmoothScrollingCapable then FListboxSmoothScrolling := False;
        if Assigned(FOnListboxSmoothScrolling) then
          FOnListboxSmoothScrolling(nil, FIsListboxSmoothScrollingCapable, FListboxSmoothScrolling);
      end;
      SPI_SETLISTBOXSMOOTHSCROLLING: begin
        FIsListboxSmoothScrollingCapable := GetListboxSmoothScrolling(FListboxSmoothScrolling);
        if not FIsListboxSmoothScrollingCapable then FListboxSmoothScrolling := False;
        if Assigned(FOnListboxSmoothScrolling) then
          FOnListboxSmoothScrolling(nil, FIsListboxSmoothScrollingCapable, FListboxSmoothScrolling);
      end;
      else Message.Result := 1;
    end;
  end else
    Message.Result := DefWindowProc(FMsgWindow, Message.Msg, Message.WParam, Message.LParam);
end;

class constructor TDesktopManager.Create;
begin
  FIsDisableOverlappedContentCapable := GetDisableOverlappedContent(FDisableOverlappedContent);
  if not FIsDisableOverlappedContentCapable then FDisableOverlappedContent := False;

  FIsClientAreaAnimationCapable := GetClientAreaAnimation(FClientAreaAnimation);
  if not FIsClientAreaAnimationCapable then FClientAreaAnimation := False;

  FIsUIEffectsCapable := GetUIEffects(FUIEffects);
  if not FIsUIEffectsCapable then FUIEffects := False;

  FIsListboxSmoothScrollingCapable := GetListboxSmoothScrolling(FListboxSmoothScrolling);
  if not FIsListboxSmoothScrollingCapable then FListboxSmoothScrolling := False;

  FMsgWindow := AllocateHWnd(MsgWindowHandle);
end;

class destructor TDesktopManager.Destroy;
begin
  DeallocateHWnd(FMsgWindow);
end;

end.
