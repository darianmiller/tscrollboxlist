unit ScrollBoxList.VariableHeight;

interface

uses
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  ScrollBoxList.Core;

type

  /// <summary>
  /// Interface for model data items used by TVariableHeightScrollBoxList.
  /// </summary>
  /// <typeparam name="TModel">The raw data type (record or class)</typeparam>
  IScrollBoxListItem<TModel> = interface
    ['{D4A5F1C9-ABCD-1234-EF00-112233445566}']
    /// <summary>Precomputed height in pixels for this item</summary>
    function ViewHeight:Integer;
    /// <summary>Underlying data payload</summary>
    function GetData:TModel;
  end;


  /// <summary>Delegate to bind a view control to its model data</summary>
  TVariableHeightBindItem<TView:TWinControl; TModel> = reference to procedure(const AView:TView; const AModel:TModel; const AIndex:Integer);


  /// <summary>
  /// TScrollBoxListEngine list facade for variable-height items
  /// </summary>
  TVariableHeightScrollBoxList<TView:TWinControl; TModel> = class
  private
    FEngine:TScrollBoxListCore<TView>;
    FData:TList<IScrollBoxListItem<TModel>>;
    FBindItem:TVariableHeightBindItem<TView, TModel>;
    function GetItemCount:Integer;
    function GetItemHeight(const Index:Integer):Integer;
    procedure DoBind(const View:TView; const Index:Integer);
  public
    /// <summary>
    /// Creates a virtual list where each item can have its own height.
    /// </summary>
    /// <param name="AScrollBox">Host scroll-box</param>
    /// <param name="DataElements">Enumerable of <TModel> items</param>
    /// <param name="OnCreateItem">Factory to create each view (TView)</param>
    /// <param name="OnBindItem">Callback to bind a view to its model and index</param>
    constructor Create(const AScrollBox:TScrollBox; const DataElements:TEnumerable<IScrollBoxListItem<TModel>>;
      const OnCreateItem:TScrollBoxListCreateItem<TView>; const OnBindItem:TVariableHeightBindItem<TView, TModel>;
      const MaxCacheSize:Integer = 0);
    destructor Destroy; override;

    /// <summary>Recalculate range and refresh visible views</summary>
    procedure Refresh;
  end;


implementation

uses
  System.SysUtils;


constructor TVariableHeightScrollBoxList<TView, TModel>.Create(const AScrollBox:TScrollBox;
  const DataElements:TEnumerable<IScrollBoxListItem<TModel>>; const OnCreateItem:TScrollBoxListCreateItem<TView>;
  const OnBindItem:TVariableHeightBindItem<TView, TModel>; const MaxCacheSize:Integer = 0);
var
  ItemIntf:IScrollBoxListItem<TModel>;
begin
  inherited Create;
  FBindItem := OnBindItem;

  // Work off a local copy in case source changes
  FData := TList<IScrollBoxListItem<TModel>>.Create;
  for ItemIntf in DataElements do
  begin
    FData.Add(ItemIntf);
  end;

  FEngine := TScrollBoxListCore<TView>.Create(AScrollBox, GetItemCount, GetItemHeight, OnCreateItem, DoBind, MaxCacheSize);
end;


destructor TVariableHeightScrollBoxList<TView, TModel>.Destroy;
begin
  FEngine.Free;
  FData.Free;
  inherited;
end;


procedure TVariableHeightScrollBoxList<TView, TModel>.Refresh;
begin
  FEngine.Refresh;
end;


function TVariableHeightScrollBoxList<TView, TModel>.GetItemCount:Integer;
begin
  Result := FData.Count;
end;


function TVariableHeightScrollBoxList<TView, TModel>.GetItemHeight(const Index:Integer):Integer;
begin
  Result := FData[Index].ViewHeight;
end;


procedure TVariableHeightScrollBoxList<TView, TModel>.DoBind(const View:TView; const Index:Integer);
var
  Model:TModel;
begin
  Model := FData[Index].GetData;

  FBindItem(View, Model, Index);
end;


end.
