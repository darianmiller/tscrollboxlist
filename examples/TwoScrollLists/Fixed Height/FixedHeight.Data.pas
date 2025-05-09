unit FixedHeight.Data;

interface

uses
  System.Generics.Collections;

type

  TMyFixedData = record
    // Whatever you want to display in the View
    Title:string;
    Description:string;
    CurrentValue:Integer;
  end;


//Example enumerable list of data to view
function ExampleFixedDataList:TList<TMyFixedData>;

implementation

uses
  System.SysUtils;


function ExampleFixedDataList:TList<TMyFixedData>;
var
  Item:TMyFixedData;
  Index:Integer;
begin
  Result := TList<TMyFixedData>.Create;
  for Index := 0 to 99999 do // no one wants to create 100,000 TFrames at once, right?
  begin
    Item.Title := 'Title ' + TGUID.NewGuid.ToString;
    Item.Description := 'Desc ' + TGUID.NewGuid.ToString;
    Item.CurrentValue := Index;

    Result.Add(Item);
  end;
end;

end.
