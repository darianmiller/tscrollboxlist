unit VariableHeight.Data;

interface

uses
  System.Generics.Collections;

type

  TMyHeightData = record
    // Whatever you want to display in the View
    Title:string;
    Description:string;
    CurrentValue:Integer;
    // For variable height items, ideally, save the last computed height when created/last populated
    // so it doesn't need to be calculated on startup and lag the initial draw (as we need total list height for proper scroll bar navigation)
    // Or add setting height to item creation for fixed-height items
    LastHeight:Integer;
  end;

//Example enumerable list of data to view
function ExampleVariableDataList:TList<TMyHeightData>;

implementation

uses
  System.SysUtils,
  System.Math;


function ExampleVariableDataList:TList<TMyHeightData>;
var
  Item:TMyHeightData;
  i:Integer;
begin
  Result := TList<TMyHeightData>.Create;
  for i := 0 to 99999 do
  begin
    Item.Title := 'Title ' + TGUID.NewGuid.ToString;
    Item.Description := 'Desc ' + TGUID.NewGuid.ToString;
    Item.CurrentValue := i;
    Item.LastHeight := IfThen(i mod 7 = 0, 250, 100);

    Result.Add(item);
  end;
end;

end.
