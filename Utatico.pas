unit Utatico;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Data.DBXDataSnap, Data.DBXCommon, IPPeerClient, Data.DB, Data.SqlExpr,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Effects,
  FMX.DateTimeCtrls, FMX.Edit, FGX.ProgressDialog, Datasnap.DBClient,
  Datasnap.DSConnect, Datasnap.Provider, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, IniFiles;

type
  Tprincipal = class(TForm)
    conn: TSQLConnection;
    ToolBar1: TToolBar;
    VertScrollBox1: TVertScrollBox;
    Rectangle2: TRectangle;
    GlowEffect1: TGlowEffect;
    Layout1: TLayout;
    Layout3: TLayout;
    Rectangle3: TRectangle;
    GlowEffect3: TGlowEffect;
    Layout2: TLayout;
    Rectangle1: TRectangle;
    GlowEffect2: TGlowEffect;
    Layout4: TLayout;
    GlowEffect4: TGlowEffect;
    Rectangle4: TRectangle;
    Layout5: TLayout;
    GlowEffect5: TGlowEffect;
    Rectangle5: TRectangle;
    Layout6: TLayout;
    GlowEffect6: TGlowEffect;
    Rectangle6: TRectangle;
    Label1: TLabel;
    Layout7: TLayout;
    Rectangle7: TRectangle;
    GlowEffect7: TGlowEffect;
    dtInicio: TDateEdit;
    Label2: TLabel;
    edtValorMedio: TEdit;
    edtLucroPorcentagem: TEdit;
    edtPedidosEmitidos: TEdit;
    edtLucro: TEdit;
    Label3: TLabel;
    dtFinalizacao: TDateEdit;
    edtVendaGeral: TEdit;
    ToolBar2: TToolBar;
    SpeedButton1: TSpeedButton;
    btnConexao: TSpeedButton;
    msg: TfgActivityDialog;
    dsVendasGeral: TDataSetProvider;
    cdsVendaGeral: TClientDataSet;
    DSPVendasGeral: TDSProviderConnection;
    SpeedButton2: TSpeedButton;
    cdsVendaGeralQTPED: TFloatField;
    cdsVendaGeralVLATEND: TFloatField;
    cdsVendaGeralVLTOTAL: TFloatField;
    cdsVendaGeralVLPM: TFloatField;
    cdsVendaGeralVLLUCRO: TFloatField;
    cdsVendaGeralVLTABELA: TFloatField;
    cdsVendaGeralVLCUSTOFIN: TFloatField;
    cdsVendaGeralVLBONIF: TFloatField;
    cdsVendaGeralVLFRETE: TFloatField;
    cdsVendaGeralVLOUTRASDESP: TFloatField;
    cdsVendaGeralTOTPESO: TFloatField;
    cdsVendaGeralQTMIXCLI: TFloatField;
    cdsVendaGeralQTCLIENTES: TFloatField;
    cdsVendaGeralNUMITENS: TFloatField;
    cdsVendaGeralQTITENS: TFloatField;
    cdsVendaGeralVLVENDAPREV: TFloatField;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure DesconectadoClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    FProgressDialogThread: TThread;
    FActivityDialogThread: TThread;
  public
    { Public declarations }
  end;

var
  principal: Tprincipal;

implementation


uses
System.Math, UConfig, System.IOUtils;
{$R *.fmx}


procedure Tprincipal.FormShow(Sender: TObject);
var
 ArqIni : TIniFile;
begin
 { TODO : Inicia a data de Inicio e data de finalização com a data atual do dia. }
dtInicio.Text := DateToStr(Now);
dtFinalizacao.Text := DateToStr(Now);

  ArqIni := TIniFile.Create(TPath.GetDocumentsPath + PathDelim + 'Mobile.ini');
      try
   frmConfig.edtlink.Text :=  ArqIni.ReadString('Servidor/Base','Servidor',frmConfig.edtlink.Text);
   frmConfig.edtPorta.Text := ArqIni.ReadString('Porta','Porta', frmConfig.edtPorta.Text);
      conn.Close;
      begin
         if (frmConfig.edtlink.Text = '') or (frmConfig.edtPorta.Text = '') then
          begin
             frmConfig.Show;
            ShowMessage('Por favor configurar o servidor.');
          end
            else
            begin
           conn.Params.Values['HostName'] :=   frmConfig.edtlink.Text;
           conn.Params.Values['Port'] := frmConfig.edtPorta.Text;
          end;
        end;
     finally
       ArqIni.Free;
     end;




end;

procedure Tprincipal.SpeedButton1Click(Sender: TObject);
begin
ShowMessage('Favor aguarde buscando vendas...');
end;

procedure Tprincipal.SpeedButton2Click(Sender: TObject);
 var
 Total: Currency;
 lucro: Currency;
 emitidos: Currency;
 totalcadastro : Currency;
 positivados : Currency;
 margemitemssuperv : Currency;
 nMargem , nMedia: real;
 meta, rcaativo, rcaposit : Currency;
begin
conn.Close;
conn.Open;
cdsVendaGeral.Close;
 if (frmConfig.edtlink.Text = '') or (frmConfig.edtPorta.Text ='') then
 begin
   ShowMessage('Servidor não encontrado.');
   Exit
 end
 else
  begin
   cdsVendaGeral.Close;
   cdsVendaGeral.ParamByName('DTINCIO').AsDateTime := dtInicio.DateTime;
  cdsVendaGeral.ParamByName('DTFIM').AsDateTime    := dtFinalizacao.DateTime;

 if cdsVendaGeral.ParamByName('DTINCIO').AsDateTime > cdsVendaGeral.ParamByName('DTFIM').AsDateTime then
     begin
        ShowMessage('A data de inicialização do período de vendas deve ser menor ou igual a data de finalização!');
        Exit
     end
      else
     begin
       Sleep(1000);
       msg.Message := 'Buscando informações de vendas';
       msg.Show;
       cdsVendaGeral.Open;
       msg.Hide;
       end;
       begin
       Total := 0 ;
       lucro := 0 ;
       emitidos := 0 ;
       cdsVendaGeral.DisableControls;
   try
         cdsVendaGeral.First ;
     while not cdsVendaGeral.EOF do
        begin
          Total    :=  Total  +    cdsVendaGeral.FieldByName  ('VLATEND').AsCurrency;
          lucro    :=  lucro +     cdsVendaGeral.FieldByName ('VLLUCRO').AsCurrency;
          emitidos :=  emitidos +  cdsVendaGeral.FieldByName('QTPED' ).AsCurrency;
          cdsVendaGeral.Next;
        end;
   finally
       cdsVendaGeral.EnableControls;
       edtpedidosemitidos.Text     :=   FormatFloat('#,##0', emitidos);
       edtLucro.Text        :=   FormatFloat('R$ #,##0.00', lucro);
       edtVendaGeral.Text   :=   FormatFloat('R$ #,##0.00', Total);
       if (Total <> 0)  and (emitidos <> 0)   then
          begin
          edtValorMedio.Text :=  FormatFloat('#,##0.00',(Total/emitidos));
          end
       else
        ShowMessage('loja sem vendas!');
          if (lucro <> 0 ) and (Total <> 0) then
          begin
           edtLucroPorcentagem.Text  :=  FormatFloat('#,##0.00',(lucro/Total*100));
       end;
     end;
     end;
  end;
  end;

procedure Tprincipal.DesconectadoClick(Sender: TObject);
begin
{ TODO : abre a tela de configurações }
 if (frmConfig.edtlink.Text = '') or (frmConfig.edtPorta.Text = '') then
  begin
  frmConfig.edtlink.Enabled := true;
  frmConfig.edtPorta.Enabled := true;
  end
  else
   begin
   frmConfig.edtlink.Enabled := false;
   frmConfig.edtPorta.Enabled := false;
   end;
  frmConfig.Show;
end;

end.
