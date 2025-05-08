unit VariableHeight.WrappedData;

interface

uses
  System.Generics.Collections,
  ScrollBoxList.VariableHeight,
  VariableHeight.Data;


type
  // Simple wrapper example that provides a IScrollBoxListItem interface to customize the view with the data
  TMyDataWrapper = class(TInterfacedObject, IScrollBoxListItem<TMyHeightData>)
  private
    FData:TMyHeightData;
  public
    constructor Create(const AData:TMyHeightData);

    { IScrollBoxListItem }
    function ViewHeight:Integer;
    function GetData:TMyHeightData;
  end;


function CreateWrappedDataList:TList<IScrollBoxListItem<TMyHeightData>>;


implementation


constructor TMyDataWrapper.Create(const AData:TMyHeightData);
begin
  FData := AData;
end;


function TMyDataWrapper.ViewHeight:Integer;
begin
  Result := FData.LastHeight;
end;


function TMyDataWrapper.GetData:TMyHeightData;
begin
  Result := FData;
end;


function CreateWrappedDataList:TList<IScrollBoxListItem<TMyHeightData>>;
var
  RawData:TList<TMyHeightData>;
  WrappedItem:IScrollBoxListItem<TMyHeightData>;
  Item:TMyHeightData;
begin
  RawData := ExampleVariableDataList;
  try
    Result := TList<IScrollBoxListItem<TMyHeightData>>.Create;
    for Item in RawData do
    begin
      WrappedItem := TMyDataWrapper.Create(Item);
      Result.Add(WrappedItem);
    end;
  finally
    RawData.Free;
  end;
end;

end.
