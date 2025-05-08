unit VariableHeight.Frame;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  ScrollBoxList.VariableHeight,
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
  WinAPi.Windows,
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
  Label1.Caption := Format('Created at %s', [FormatDateTime('hh:nn:ss:zzz', Now)]);  //To show that the frame instance will get re-used
end;


procedure TMyVariableHeightFrame.DoBind(const Item:TMyHeightData; const Index:Integer);
begin
  Label2.caption := Item.Title;
  Label3.caption := Item.Description;
  Label4.Caption := Item.CurrentValue.ToString;
end;

end.
