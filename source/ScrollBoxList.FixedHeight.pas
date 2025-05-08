unit ScrollBoxList.FixedHeight;

interface

uses
  Vcl.Controls,
  Vcl.Forms,
  ScrollBoxList.Core;

type

  /// <summary>
  /// A lightweight facade over TScrollBoxListEngine for fixed-height items.
  /// </summary>
  /// <typeparam name="TView">The control type used for each item (descends from TWinControl)</typeparam>
  TFixedHeightScrollBoxList<TView:TWinControl> = class
  private
    FEngine:TScrollBoxListCore<TView>;
    FItemCount:Integer;
    FFixedRowHeight:Integer;
    function GetItemCount:Integer;
    function GetItemHeight(const Index:Integer):Integer;
  public
    /// <summary>
    /// Creates a virtual list of fixed-height items inside AScrollBox
    /// </summary>
    /// <param name="AScrollBox">Host scroll-box container</param>
    /// <param name="RowHeight">Pixel height of each item</param>
    /// <param name="ItemCount">Total number of items in the list</param>
    /// <param name="OnCreateItem">Factory delegate to instantiate a TView</param>
    /// <param name="OnBindItem">Delegate to bind each TView to its index</param>
    constructor Create(const AScrollBox:TScrollBox; const RowHeight:Integer; const ItemCount:Integer;
      const OnCreateItem:TScrollBoxListCreateItem<TView>; const OnBindItem:TScrollBoxListBindItem<TView>; const MaxCacheSize:Integer = 0);
    destructor Destroy; override;

    /// <summary>Recalculate range and redraw all visible items</summary>
    procedure Refresh;
  end;


implementation


constructor TFixedHeightScrollBoxList<TView>.Create(const AScrollBox:TScrollBox; const RowHeight:Integer; const ItemCount:Integer;
  const OnCreateItem:TScrollBoxListCreateItem<TView>; const OnBindItem:TScrollBoxListBindItem<TView>; const MaxCacheSize:Integer = 0);
begin
  inherited Create;
  FItemCount := ItemCount;
  FFixedRowHeight := RowHeight;

  FEngine := TScrollBoxListCore<TView>.Create(AScrollBox, GetItemCount, GetItemHeight, OnCreateItem, OnBindItem, MaxCacheSize);
end;


destructor TFixedHeightScrollBoxList<TView>.Destroy;
begin
  FEngine.Free;
  inherited;
end;


function TFixedHeightScrollBoxList<TView>.GetItemCount: Integer;
begin
  Result := FItemCount;
end;


//Simply to meet core requirement - all Indexes have the same height in this implementation
function TFixedHeightScrollBoxList<TView>.GetItemHeight(const Index:Integer):Integer;
begin
  Result := FFixedRowHeight;
end;


procedure TFixedHeightScrollBoxList<TView>.Refresh;
begin
  FEngine.Refresh;
end;


end.
