program Tatico;

uses
  System.StartUpCopy,
  FMX.Forms,
  Utatico in 'Utatico.pas' {principal},
  UConfig in 'UConfig.pas' {frmConfig};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tprincipal, principal);
  Application.CreateForm(TfrmConfig, frmConfig);
  Application.Run;
end.
