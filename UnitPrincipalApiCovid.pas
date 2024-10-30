unit UnitPrincipalApiCovid;

interface


uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,System.JSON,
  REST.Client,
  REST.Json,
  REST.Types, Vcl.Grids;

type
  TFormPrincipalApi = class(TForm)
    PanelPrincipal: TPanel;
    PanelTitulo: TPanel;
    PanelCorpo: TPanel;
    BtnFechar: TBitBtn;
    SG: TStringGrid;
    ComboBoxPaises: TComboBox;
    lblComboBox: TLabel;
    BtnAplicar: TBitBtn;
    BitBtn1: TBitBtn;
    btnAplicaFiltro: TBitBtn;
    btnLimpaFiltro: TBitBtn;
    LabelErrorApi: TLabel;
    LabelStatusCode: TLabel;
    procedure BtnAplicarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnLimpaGridClick(Sender: TObject);
    procedure btnAplicaFiltroClick(Sender: TObject);
    procedure btnLimpaFiltroClick(Sender: TObject);
    procedure BtnFecharClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  //Const com a url da api informada pela EDATA
  ApiCovidURL : String = 'https://covid19-brazil-api.now.sh/api/report/v1/countries';
var
  FormPrincipalApi: TFormPrincipalApi;

implementation

{$R *.dfm}

procedure TFormPrincipalApi.BtnLimpaGridClick(Sender: TObject);
var
  i: Integer;
begin
  // Itera pelas linhas, começando pela segunda linha para não apagar o titulo   rs
  for i := 1 to SG.RowCount - 1 do
  begin
    sg.Rows[i].Clear;
  end;
  ComboBoxPaises.Items.Clear;
end;

procedure TFormPrincipalApi.btnAplicaFiltroClick(Sender: TObject);
var
i : Integer;
begin
  if ComboBoxPaises.Items.Count = 0 then
  begin
    ShowMessage('Por favor, requisite a api para carregar o combobox!');
    Exit; // Interrompe a execução do código se o combobox estiver vazio
  end
  else if ComboBoxPaises.ItemIndex = -1 then
  begin
    ShowMessage('Por favor, selecione um país no combobox!');
    Exit; // Interrompe a execução do código se nada estiver selecionado no combobox
  end;

  BtnAplicarClick(Sender);

end;

procedure TFormPrincipalApi.BtnAplicarClick(Sender: TObject);
var
  JsonResponse: TJSONObject;
  JsonDataArray: TJSONArray;
  JsonItem: TJSONObject;
  i: Integer;
  RestClientAuth: TRESTClient;
  RestRequestAuth: TRESTRequest;
  RestResponseAuth: TRESTResponse;
begin
  RestClientAuth := TRESTClient.Create(nil);
  RestRequestAuth := TRESTRequest.Create(nil);
  RestResponseAuth := TRESTResponse.Create(nil);

  try
    RestClientAuth.BaseURL := ApiCovidURL;
    RestClientAuth.Accept := 'application/octet-stream';
    RestRequestAuth.Client := RestClientAuth;
    RestRequestAuth.Params.Clear;
    RestRequestAuth.Method := TRESTRequestMethod.rmPOST;
    RestResponseAuth.ContentType := 'application/json';
    RestRequestAuth.Response := RestResponseAuth;

    try
      RestRequestAuth.Execute;

      LabelStatusCode.Visible := True;
      LabelStatusCode.Caption := 'Status Code: ' + IntToStr(RestResponseAuth.StatusCode);

      // Verifica o status code e exibe mensagens de erro se necessário
      if RestResponseAuth.StatusCode <> 200 then
      begin
        LabelErrorApi.Caption := 'Erro: ' + RestResponseAuth.StatusText; // Mostra o texto do erro
        LabelErrorApi.Visible := True; // Torna a label visível
        Exit; // Sai do método se houver um erro
      end
      else
      begin
        LabelErrorApi.Visible := False; // Oculta a label de erro se não houver erro
      end;

      JsonResponse := TJSONObject.ParseJSONValue(RestResponseAuth.Content) as TJSONObject;

      if Assigned(JsonResponse) then
      begin
        JsonDataArray := JsonResponse.GetValue<TJSONArray>('data');
        if Assigned(JsonDataArray) then
        begin
          // Verificar se um país específico está selecionado
          var selectedCountry := ComboBoxPaises.Text;

          SG.RowCount := 1; // Comece com 1 para a linha de cabeçalho
          for i := 0 to JsonDataArray.Count - 1 do
          begin
            JsonItem := JsonDataArray.Items[i] as TJSONObject;
            var country := JsonItem.GetValue<string>('country');

            // Se nenhum país estiver selecionado, adicione todos os dados
            if (selectedCountry = '') or (selectedCountry = country) then
            begin
              SG.RowCount := SG.RowCount + 1; // Adiciona uma linha
              SG.Cells[0, SG.RowCount - 1] := country;
              SG.Cells[1, SG.RowCount - 1] := JsonItem.GetValue<string>('cases');
              SG.Cells[2, SG.RowCount - 1] := JsonItem.GetValue<string>('confirmed');
              SG.Cells[3, SG.RowCount - 1] := JsonItem.GetValue<string>('deaths');
              SG.Cells[4, SG.RowCount - 1] := JsonItem.GetValue<string>('recovered');

              ComboBoxPaises.Items.Add(JsonItem.GetValue<string>('country'));
            end;
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        LabelErrorApi.Caption := 'Erro ao conectar à API: ' + E.Message; // Mostra a mensagem de erro
        LabelErrorApi.Visible := True; // Torna a label visível
      end;
    end;

  finally
    JsonResponse.Free;
    RestResponseAuth.Free;
    RestRequestAuth.Free;
    RestClientAuth.Free;
  end;
end;

procedure TFormPrincipalApi.BtnFecharClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormPrincipalApi.btnLimpaFiltroClick(Sender: TObject);
begin
  if ComboBoxPaises.ItemIndex = -1 then
  begin
    ShowMessage('Não há filtros selecionados para limpar!');
    Exit; // Interrompe a execução do código se nada estiver selecionado no combobox
  end;
   ComboBoxPaises.Items.Clear;
   BtnAplicarClick(Sender);
end;

procedure TFormPrincipalApi.FormCreate(Sender: TObject);
var
i : Integer;
begin
  //Criação dos campos do string grid
  for i:=0 to SG.ColCount-1 do
  begin
    SG.Cols[i].Clear;
  end;
  SG.RowCount := 1;
  SG.ColCount := 5;

  SG.Cells[0,0]:='Nome do País';
  SG.Cells[1,0]:='Número de Casos';
  SG.Cells[2,0]:='Número de Casos Confirmados';
  SG.Cells[3,0]:='Número de Mortes';
  SG.Cells[4,0]:='Número de Recuperados';
end;

end.
