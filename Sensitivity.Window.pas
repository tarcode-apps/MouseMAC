unit Sensitivity.Window;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Mouse.Mac,
  Versions.Helpers;

type
  TSensitivityWindow = class(TCompatibleForm)
    VerticalLabel: TLabel;
    VerticalTrackBar: TTrackBar;
    HorizontalLabel: TLabel;
    VerticalPanel: TPanel;
    VerticalValueLabel: TLabel;
    HorizontalPanel: TPanel;
    HorizontalValueLabel: TLabel;
    HorizontalTrackBar: TTrackBar;
    VerticalRevertPanel: TPanel;
    VerticalRevertLink: TStaticText;
    HorizontalRevertPanel: TPanel;
    HorizontalRevertLink: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure VerticalTrackBarChange(Sender: TObject);
    procedure HorizontalTrackBarChange(Sender: TObject);
    procedure VerticalRevertLinkClick(Sender: TObject);
    procedure HorizontalRevertLinkClick(Sender: TObject);
  strict private
    class var FLastWindowHandle: THandle;
  strict private
    FParentHandle: THandle;
    function PositionToSensitivity(Position: Integer): Double;
    function SensitivityToPosition(Sensitivity: Double): Integer;
    procedure Loadlocalization;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoClose(var Action: TCloseAction); override;
  public
    class procedure Open;
  public
    constructor Create(AOwner: TComponent; ParentHandle: THandle); reintroduce;
  end;

implementation

{$R *.dfm}

class procedure TSensitivityWindow.Open;
var
  Window: TSensitivityWindow;
begin
  if FLastWindowHandle = 0 then
  begin
    Window := TSensitivityWindow.Create(nil, 0);
    Window.Show;
  end
  else
  begin
    ShowWindow(FLastWindowHandle, SW_RESTORE);
    SetForegroundWindow(FLastWindowHandle);
  end;
end;

constructor TSensitivityWindow.Create(AOwner: TComponent;
  ParentHandle: THandle);
begin
  FParentHandle := ParentHandle;
  inherited Create(AOwner);

  FLastWindowHandle := WindowHandle;
end;

procedure TSensitivityWindow.FormCreate(Sender: TObject);
begin
  if IsWindows10OrGreater then Color := clWindow;

  VerticalTrackBar.DirectDrag := True;
  VerticalTrackBar.Position := SensitivityToPosition(TMouseMac.VerticalSensitivity);
  VerticalValueLabel.Caption := TMouseMac.VerticalSensitivity.ToString;
  HorizontalTrackBar.DirectDrag := True;
  HorizontalTrackBar.Position := SensitivityToPosition(TMouseMac.HorizontalSensitivity);
  HorizontalValueLabel.Caption := TMouseMac.HorizontalSensitivity.ToString;

  VerticalRevertLink.LinkMode := True;
  HorizontalRevertLink.LinkMode := True;

  Loadlocalization;

  SendMessage(Handle, WM_CHANGEUISTATE, MakeLong(UIS_SET, UISF_HIDEFOCUS), 0);
end;

procedure TSensitivityWindow.FormDestroy(Sender: TObject);
begin
  FLastWindowHandle := 0;
end;

procedure TSensitivityWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := FParentHandle;
  if FParentHandle = 0 then
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TSensitivityWindow.KeyPress(var Key: Char);
begin
  inherited;
  if Key =  Char(VK_ESCAPE) then Close;
end;

procedure TSensitivityWindow.DoClose(var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;

procedure TSensitivityWindow.VerticalTrackBarChange(Sender: TObject);
begin
  TMouseMac.VerticalSensitivity := PositionToSensitivity((Sender as TTrackBar).Position);
  VerticalValueLabel.Caption := TMouseMac.VerticalSensitivity.ToString;
end;

procedure TSensitivityWindow.VerticalRevertLinkClick(Sender: TObject);
begin
  VerticalTrackBar.Position := 0;
end;

procedure TSensitivityWindow.HorizontalTrackBarChange(Sender: TObject);
begin
  TMouseMac.HorizontalSensitivity := PositionToSensitivity((Sender as TTrackBar).Position);
  HorizontalValueLabel.Caption := TMouseMac.HorizontalSensitivity.ToString;
end;

procedure TSensitivityWindow.HorizontalRevertLinkClick(Sender: TObject);
begin
  HorizontalTrackBar.Position := 0;
end;

function TSensitivityWindow.PositionToSensitivity(Position: Integer): Double;
begin
  if Position >= 0 then Exit(1 + Position/10.0);

  Result := 1 + Position/40.0;
end;

function TSensitivityWindow.SensitivityToPosition(Sensitivity: Double): Integer;
begin
  if Sensitivity >= 1 then Exit(Round((Sensitivity - 1)*10.0));

  Result := Round((Sensitivity - 1) * 40);
end;

procedure TSensitivityWindow.Loadlocalization;
begin
  Caption := TLang[300]; // Sensitivity setting

  VerticalLabel.Caption := TLang[301]; // Vertical scroll
  VerticalRevertLink.Caption := TLang[303]; // Reset to default
  HorizontalLabel.Caption := TLang[302]; // Horizontal scroll
  HorizontalRevertLink.Caption := TLang[303]; // Reset to default
end;

end.
