program TwoBasicScrollLists;

uses
  Vcl.Forms,
  FixedHeight.Frame in 'Fixed Height\FixedHeight.Frame.pas' {MyFixedHeightFrame: TFrame},
  TwoBasicScrollLists.MainForm in 'TwoBasicScrollLists.MainForm.pas' {ExampleForm},
  FixedHeight.Data in 'Fixed Height\FixedHeight.Data.pas',
  VariableHeight.WrappedData in 'Variable Height\VariableHeight.WrappedData.pas',
  ScrollBoxList.Core in '..\..\source\ScrollBoxList.Core.pas',
  ScrollBoxList.FixedHeight in '..\..\source\ScrollBoxList.FixedHeight.pas',
  ScrollBoxList.VariableHeight in '..\..\source\ScrollBoxList.VariableHeight.pas',
  VariableHeight.Data in 'Variable Height\VariableHeight.Data.pas',
  VariableHeight.Frame in 'Variable Height\VariableHeight.Frame.pas' {MyVariableHeightFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskBar := True;
  Application.CreateForm(TExampleForm, ExampleForm);
  Application.Run;
end.
