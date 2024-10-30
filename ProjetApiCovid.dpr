program ProjetApiCovid;

uses
  Vcl.Forms,
  UnitPrincipalApiCovid in 'UnitPrincipalApiCovid.pas' {FormPrincipalApi};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipalApi, FormPrincipalApi);
  Application.Run;
end.
