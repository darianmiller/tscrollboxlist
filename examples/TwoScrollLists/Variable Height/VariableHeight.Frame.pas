unit VariableHeight.Frame;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  VariableHeight.Data;

type

  TMyVariableHeightFrame = class(TFrame)
    panClient:TPanel;
    Label1:TLabel;
    Label2:TLabel;
    Label3:TLabel;
    Label4:TLabel;
  private
    procedure DoBind(const Item:TMyHeightData; const Index:Integer);
  public
    constructor Create(AOwner: TComponent); override;
  end;


function MyFrameCreate(const AOwner:TComponent; const AParent:TWinControl):TMyVariableHeightFrame;
procedure MyFrameBind(const AView:TMyVariableHeightFrame; const AModel:TMyHeightData; const AIndex:Integer);


implementation

uses
  System.SysUtils;

{$R *.dfm}


function MyFrameCreate(const AOwner:TComponent; const AParent:TWinControl):TMyVariableHeightFrame;
begin
  Result := TMyVariableHeightFrame.Create(AOwner);
  Result.Parent := AParent;
  Result.Name := '';
end;


procedure MyFrameBind(const AView:TMyVariableHeightFrame; const AModel:TMyHeightData; const AIndex:Integer);
begin
  AView.DoBind(AModel, AIndex);
end;


constructor TMyVariableHeightFrame.Create(AOwner: TComponent);
begin
  inherited;
  // To help demonstrate that this frame instance will get re-used
  // (as the created date won't change)
  Label1.Caption := Format('Created at %s', [FormatDateTime('hh:nn:ss:zzz', Now)]);
end;


procedure TMyVariableHeightFrame.DoBind(const Item:TMyHeightData; const Index:Integer);
begin
  Label2.Caption := Item.Title;
  Label3.Caption := Item.Description;
  Label4.Caption := Item.CurrentValue.ToString;
end;

end.
