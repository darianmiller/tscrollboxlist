unit FixedHeight.Frame;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  FixedHeight.Data;

type

  TMyFixedHeightFrame = class(TFrame)
    panClient:TPanel;
    Label1:TLabel;
    Label2:TLabel;
    Label3:TLabel;
    Label4:TLabel;
  private
    procedure DoBind(const Item:TMyFixedData; const Index:Integer);
  public
    constructor Create(AOwner: TComponent); override;
  end;


function MyFixedFrameCreate(const AOwner:TComponent; const AParent:TWinControl):TMyFixedHeightFrame;
procedure MyFixedFrameBind(const AView:TMyFixedHeightFrame; const AModel:TMyFixedData; const AIndex:Integer);


implementation

uses
  System.SysUtils;

{$R *.dfm}


function MyFixedFrameCreate(const AOwner:TComponent; const AParent:TWinControl):TMyFixedHeightFrame;
begin
  Result := TMyFixedHeightFrame.Create(AOwner);
  Result.Parent := AParent;
  Result.Name := '';
end;


procedure MyFixedFrameBind(const AView:TMyFixedHeightFrame; const AModel:TMyFixedData; const AIndex:Integer);
begin
  AView.DoBind(AModel, AIndex);
end;


constructor TMyFixedHeightFrame.Create(AOwner: TComponent);
begin
  inherited;
  //Helps prove the frame instance will get re-used
  Label1.Caption := Format('Created at %s', [FormatDateTime('hh:nn:ss:zzz', Now)]);
end;


procedure TMyFixedHeightFrame.DoBind(const Item:TMyFixedData; const Index:Integer);
begin
  Label2.Caption := Item.Title;
  Label3.Caption := Item.Description;
  Label4.Caption := Item.CurrentValue.ToString;  //Helps prove the binding changed
end;

end.
