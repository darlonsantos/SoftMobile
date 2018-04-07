unit UConfig;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, FMX.Edit, IniFiles;

type
  TfrmConfig = class(TForm)
    ToolBar1: TToolBar;
    btnVoltar: TSpeedButton;
    Label1: TLabel;
    VertScrollBox1: TVertScrollBox;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    Layout2: TLayout;
    edtlink: TEdit;
    Label2: TLabel;
    Layout3: TLayout;
    edtPorta: TEdit;
    Label3: TLabel;
    ToolBar2: TToolBar;
    btnSalvar: TSpeedButton;
    btnEditar: TSpeedButton;
    ClearEditButton1: TClearEditButton;
    ClearEditButton2: TClearEditButton;
    procedure btnVoltarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfig: TfrmConfig;

implementation

{$R *.fmx}

uses Utatico, System.IOUtils;

procedure TfrmConfig.btnEditarClick(Sender: TObject);
begin
  principal.conn.Close;
  edtlink.Enabled := true;
  edtPorta.Enabled := true;
end;

procedure TfrmConfig.btnSalvarClick(Sender: TObject);

var
 ArqIni : TIniFile;
begin

    ArqIni := TIniFile.Create(TPath.GetDocumentsPath + PathDelim + 'Mobile.ini');
       try
        ArqIni.WriteString('Servidor/Base','Servidor',edtlink.Text);
        ArqIni.WriteString('Porta','Porta', edtPorta.Text);
         principal.conn.Close;
          begin
           principal.conn.Params.Values['HostName'] := edtlink.Text;
           principal.conn.Params.Values['Port'] := edtPorta.Text;
          if edtlink.Text >= '0'  then
            begin
            ShowMessage('Alteração efetuada com sucesso!'+'  '+
            'Por favor, renicie o aplicativo.')
            end;
            end;
       finally
            ArqIni.Free;

       end;
       edtlink.Enabled := false;
       edtPorta.Enabled := false;
end;
procedure TfrmConfig.btnVoltarClick(Sender: TObject);
begin
Close;
end;

end.
