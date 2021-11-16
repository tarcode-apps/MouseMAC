unit Core.Startup.Tasks;

interface

type
  TTasks = class
  public const
    ERROR_Ok = $0000;
    ERROR_Autorun = $0001;
    ERROR_DelAutorun = $0002;
    ERROR_Mutex = $0003;
  public type
    TTaskType = (Autorun, AutorunForce, DelAutorun);
    TTaskArray = array [TTaskType] of string;
  public const
    TaskNames: TTaskArray = ('-Autorun', '-AutorunForce', '-DelAutorun');
  private
    class function AddAutorun(var CallExit: Boolean): Cardinal;
    class function AddAutorunForce(var CallExit: Boolean): Cardinal;
    class function DelAutorun(var CallExit: Boolean): Cardinal;
  public
    class function Perform(Task: string; var CallExit: Boolean): Cardinal;
  end;

implementation

uses
  Autorun.Manager;

{ TTasks }

class function TTasks.AddAutorun(var CallExit: Boolean): Cardinal;
begin
  if AutorunManager.Autorun then
    Result:= ERROR_Ok
  else
    Result:= ERROR_Autorun;
  CallExit:= True;
end;

class function TTasks.AddAutorunForce(var CallExit: Boolean): Cardinal;
begin
  Result := AddAutorun(CallExit);
  if (Result <> ERROR_Ok) and AutorunManager.Options.HighestRunLevel then
  begin
    AutorunManager.Options.HighestRunLevel := False;
    try
      Result := AddAutorun(CallExit);
    finally
      AutorunManager.Options.HighestRunLevel := True;
    end;
  end;
end;

class function TTasks.DelAutorun(var CallExit: Boolean): Cardinal;
begin
  if AutorunManager.DeleteAutorun then
    Result:= ERROR_Ok
  else
    Result:= ERROR_DelAutorun;
  CallExit:= True;
end;

class function TTasks.Perform(Task: string; var CallExit: Boolean): Cardinal;
begin
  Result:= ERROR_Ok;
  if Task = TaskNames[TTaskType.Autorun] then
    Exit(AddAutorun(CallExit));

  if Task = TaskNames[TTaskType.AutorunForce] then
    Exit(AddAutorunForce(CallExit));

  if Task = TaskNames[TTaskType.DelAutorun] then
    Exit(DelAutorun(CallExit));
end;

end.
