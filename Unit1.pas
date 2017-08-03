unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Sensors,
  System.Sensors.Components, FMX.Objects,IdMessage,IdtEXT, System.IOUtils, System.ZLib,
  FMX.Edit, FMX.TabControl;
type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    IdSMTP1: TIdSMTP;
    LocationSensor1: TLocationSensor;
    Text1: TText;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Address: TEdit;
    Pass: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SendTo: TEdit;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure FormCreate(Sender: TObject);
  private
    { private �錾 }
    FGeocoder: TGeocoder;
 Procedure OnGeocodeReverseEvent(const Address: TCivicAddress);
  procedure IdMessage_InitializeISO(var VHeaderEncoding: Char; var VCharSet: string);
  procedure SendMail(str:string;Time:TDateTime);

  public
    { public �錾 }
  end;

var
  Form1: TForm1;
 // StartTime: TDateTime;
//  EndTime: TDateTime;
  GPSstate:string;

implementation

{$R *.fmx}


procedure TForm1.IdMessage_InitializeISO(var VHeaderEncoding: Char; var VCharSet: string);
begin
  VHeaderEncoding := 'B';
  VCharSet := 'UTF-8';
end;

procedure TForm1.SendMail(str:string; Time:TDateTime);
var
  IdSMTP: TIdSMTP;
 // host, subject, mailto, from:string ;
  //body:AnsiString;
   msg :  TIdMessage;
begin
  IdSMTP := TIdSMTP.Create(nil);
  IdSMTP.Port      := 000;
  IdSMTP.Host      := '***.***';
  IdSMTP.Username  := Address.text;   //���[�U�[��
  IdSMTP.Password  :=Pass.text;           //�p�X���[�h
   msg := TIdMessage.Create(IdSMTP);
  try
      msg.Recipients.EMailAddresses := SendTo.text;
      msg.From.Text := Address.text;
      msg.Body.Text :=UTF8Encode( str +DateToStr(Time)+'  '+TimeToStr(Time)+'  '+GPSstate+' '+Text1.text);


      Msg.OnInitializeISO           := IdMessage_InitializeISO;
      Msg.ContentType               := 'text/plain';
      Msg.CharSet                   := 'UTF-8';
      Msg.ContentTransferEncoding   := 'BASE64';
      Msg.Subject                   := UTF8Encode(str);

    IdSmtp.Connect;
    IdSmtp.Send(msg);
    IdSmtp.Disconnect ;
   finally
    msg.Free;
   end;

   ShowMessage(str);
   IdSMTP.Free;
end;
procedure TForm1.Button1Click(Sender: TObject);

begin
 // StartTime:= Now;
  SendMail('�o�Ђ��܂���',Now);
end;

procedure TForm1.Button2Click(Sender: TObject);

begin
  SendMail('�ގЂ��܂���',Now);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   LocationSensor1.Active := true;
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
begin
  GPSstate:=FloatToStr(NewLocation.Latitude)+'  ' +FloatToStr(NewLocation.Longitude);
   // ���݂̈ܓx�o�x�ɑΉ�����Z�����擾���邽�߂̈�A�̏����B
  if not Assigned(FGeocoder) then
  begin
    if Assigned(TGeocoder.Current) then
      FGeocoder := TGeocoder.Current.Create;
    if Assigned(FGeocoder) then
      FGeocoder.OnGeocodeReverse := OnGeocodeReverseEvent;
  end;

  if Assigned(FGeocoder) and not FGeocoder.Geocoding then
    FGeocoder.GeocodeReverse(NewLocation);
end;

procedure TForm1.OnGeocodeReverseEvent( const Address: TCivicAddress );
begin
  // �ܓx�o�x���猻�݈ʒu�̏Z�����擾�ł����ꍇ�͕\�����X�V����B
  Text1.Text :=Address.PostalCode +' '+Address.AdminArea+' '+Address.Locality;
end;
end.
