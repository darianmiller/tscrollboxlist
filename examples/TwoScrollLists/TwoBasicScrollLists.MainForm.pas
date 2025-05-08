// todo: https://github.com/shaunroselt/Delphi-Feather-Icons

unit TwoBasicScrollLists.MainForm;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.Generics.Collections,
  ScrollBoxList.VariableHeight,
  ScrollBoxList.FixedHeight,
  FixedHeight.Frame,
  FixedHeight.Data,
  VariableHeight.Frame,
  VariableHeight.Data;


type

  TExampleForm = class(TForm)
    panFixedHeight:TPanel;
    ScrollBox1: TScrollBox;
    panVariableHeight:TPanel;
    ScrollBox2: TScrollBox;
    procedure FormCreate(Sender:TObject);
    procedure FormDestroy(Sender:TObject);
  private
    // We will virtually scroll 100,000 Data Elements with a CACHE_SIZE of TFrames of all the same height
    FFixedData:TList<TMyFixedData>;
    FFixedList:TFixedHeightScrollBoxList<TMyFixedHeightFrame>;

    // We will virtually scroll 100,000 Data Elements with a CACHE_SIZE of TFrames of variable heights (in this demo, two heights based on index)
    FHeightData:TList<IScrollBoxListItem<TMyHeightData>>;
    FVarList:TVariableHeightScrollBoxList<TMyVariableHeightFrame, TMyHeightData>;
  protected
    procedure MyFixedHeightBind(const AView:TMyFixedHeightFrame; const AIndex:Integer);
  end;

var
  ExampleForm:TExampleForm;


implementation

uses
  VariableHeight.WrappedData;

{$R *.dfm}


procedure TExampleForm.FormCreate(Sender:TObject);
const
  FIXED_HEIGHT = 100;
  CACHE_SIZE = 100;
begin
  ReportMemoryLeaksOnShutdown := True;

  FFixedData := ExampleFixedDataList;
  //Single generic-type View(Frame) + linked Model data with a local Bind function
  FFixedList := TFixedHeightScrollBoxList<TMyFixedHeightFrame>.Create(ScrollBox1, FIXED_HEIGHT, FFixedData.Count, MyFixedFrameCreate, MyFixedHeightBind, CACHE_SIZE);


  FHeightData := CreateWrappedDataList; //for IScrollBoxListItem methods
  //Two generic-types View(Frame) + Model data
  FVarList := TVariableHeightScrollBoxList<TMyVariableHeightFrame, TMyHeightData>.Create(ScrollBox2, FHeightData, MyFrameCreate, MyFrameBind, CACHE_SIZE);
end;


procedure TExampleForm.FormDestroy(Sender:TObject);
begin
  FHeightData.Free;
  FFixedData.Free;
  FVarList.Free;
  FFixedList.Free;
end;


procedure TExampleForm.MyFixedHeightBind(const AView:TMyFixedHeightFrame; const AIndex:Integer);
begin
  MyFixedFrameBind(AView, FFixedData[AIndex], AIndex);
end;


end.
