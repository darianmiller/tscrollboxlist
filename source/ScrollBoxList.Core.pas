unit ScrollBoxList.Core;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Forms;

type

  /// <summary>Factory for creating item views</summary>
  TScrollBoxListCreateItem<TView:TWinControl> = reference to function(const AOwner:TComponent; const AParent:TWinControl):TView;

  /// <summary>Delegate that returns total item count</summary>
  TScrollBoxListGetCount = reference to function:Integer;

  /// <summary>Delegate that returns the height of an item at Index</summary>
  TScrollBoxListGetItemHeight = reference to function(const AIndex:Integer):Integer;

  /// <summary>Delegate to bind a view control to its item at Index</summary>
  TScrollBoxListBindItem<TView:TWinControl> = reference to procedure(const AView:TView; const AIndex:Integer);


  /// <summary>
  /// Engine that virtualizes TView items inside a TScrollBox,
  /// supporting dynamic heights, pooling, smooth scroll, mouse-wheel,
  /// key navigation, and resize handling.
  /// </summary>
  TScrollBoxListCore<TView:TWinControl> = class
  private
    FScrollBox:TScrollBox;
    FMaxCacheSize:Integer;
    FPool:TOrderedDictionary<Integer, TView>;
    FActive:TDictionary<Integer, TView>;

    FGetCount:TScrollBoxListGetCount;
    FGetHeight:TScrollBoxListGetItemHeight;
    FCreateItem:TScrollBoxListCreateItem<TView>;
    FBindItem:TScrollBoxListBindItem<TView>;

    FOrigSBoxWinMethod:TWndMethod;
    FOrigSBoxResize:TNotifyEvent;
    FOrigAppOnMessage:TMessageEvent;

    procedure CustomSBoxWindowMethod(var Msg:TMessage);
    procedure CustomAppOnMessage(var Msg:TMsg; var Handled:Boolean);
    procedure CustomSBoxResize(Sender:TObject);
    function HandleNavigateKeyPress(Key:Word; Shift:TShiftState):Boolean;
    procedure ReleaseUnusedItems(const Visible:TList<Integer>);
    procedure UpdateView;
  public
    constructor Create(AScrollBox:TScrollBox; GetCount:TScrollBoxListGetCount; GetHeight:TScrollBoxListGetItemHeight;
      CreateItem:TScrollBoxListCreateItem<TView>; BindItem:TScrollBoxListBindItem<TView>; MaxCacheSize:Integer);
    destructor Destroy; override;

    procedure Refresh;
  end;


implementation

uses
  System.SysUtils,
  System.Math;


constructor TScrollBoxListCore<TView>.Create(AScrollBox:TScrollBox; GetCount:TScrollBoxListGetCount; GetHeight:TScrollBoxListGetItemHeight;
  CreateItem:TScrollBoxListCreateItem<TView>; BindItem:TScrollBoxListBindItem<TView>; MaxCacheSize:Integer);
begin
  inherited Create;
  FScrollBox := AScrollBox;
  FGetCount := GetCount;
  FGetHeight := GetHeight;
  FCreateItem := CreateItem;
  FBindItem := BindItem;
  FMaxCacheSize := MaxCacheSize;

  FPool := TOrderedDictionary<Integer, TView>.Create;
  FActive := TDictionary<Integer, TView>.Create;

  // hook application OnMessage for mouse-wheel
  FOrigAppOnMessage := Application.OnMessage;
  Application.OnMessage := CustomAppOnMessage;

  // hook scrollbox window proc for scroll and key messages
  FOrigSBoxWinMethod := FScrollBox.WindowProc;
  FScrollBox.WindowProc := CustomSBoxWindowMethod;

  // hook resize for layout on size change
  FOrigSBoxResize := FScrollBox.OnResize;
  FScrollBox.OnResize := CustomSBoxResize;

  // initial draw
  Refresh;
end;


destructor TScrollBoxListCore<TView>.Destroy;
begin
  // restore hooks
  FScrollBox.OnResize := FOrigSBoxResize;
  FScrollBox.WindowProc := FOrigSBoxWinMethod;
  Application.OnMessage := FOrigAppOnMessage;

  // toconsider: manual free
  // for V in FPool do
  // V.Free;
  // for V in FActive.Values do
  // V.Free;

  FActive.Free;
  FPool.Free;
  inherited;
end;


procedure TScrollBoxListCore<TView>.Refresh;
var
  TotalHeight, i:Integer;
begin
  TotalHeight := 0;
  for i := 0 to FGetCount - 1 do
  begin
    Inc(TotalHeight, FGetHeight(i));
  end;
  FScrollBox.VertScrollBar.Range := TotalHeight;
  UpdateView;
end;


procedure TScrollBoxListCore<TView>.CustomSBoxWindowMethod(var Msg:TMessage);
begin
  // default processing (scrolling moves child windows)
  FOrigSBoxWinMethod(Msg);

  // update virtual view on scroll or wheel
  if (Msg.Msg = WM_VSCROLL) or (Msg.Msg = WM_HSCROLL) or (Msg.Msg = WM_MOUSEWHEEL) then
  begin
    UpdateView;
  end;
end;


procedure TScrollBoxListCore<TView>.CustomAppOnMessage(var Msg:TMsg; var Handled:Boolean);
var
  delta:SmallInt;
  pt:TPoint;
  R:TRect;
  Key:Word;
  Shift:TShiftState;
  FocusWnd:HWND;
begin
  try
    if Msg.message = WM_KEYDOWN then // intercept navigation keystrokes
    begin
      FocusWnd := GetFocus;
      if FocusWnd = 0 then Exit;
      if not(FocusWnd = FScrollBox.Handle) then Exit;

      Key := Msg.WParam;
      Shift := KeyDataToShiftState(Msg.LParam);
      if HandleNavigateKeyPress(Key, Shift) then
      begin
        Handled := True;
        Exit;
      end;
    end
    else if Msg.message = WM_MOUSEWHEEL then
    begin
      delta := SmallInt(HiWord(Msg.WParam));
      pt.x := SmallInt(LoWord(Msg.LParam));
      pt.y := SmallInt(HiWord(Msg.LParam));

      R := FScrollBox.ClientRect;
      MapWindowPoints(FScrollBox.Handle, 0, R, 2);
      if PtInRect(R, pt) then // Wheel activity is within the ScrollBox
      begin
        FScrollBox.VertScrollBar.Position := FScrollBox.VertScrollBar.Position - delta;
        UpdateView;
        Handled := True;
        Exit;
      end;
    end;
  finally
    if (not Handled) and Assigned(FOrigAppOnMessage) then
      FOrigAppOnMessage(Msg, Handled);
  end;
end;


procedure TScrollBoxListCore<TView>.CustomSBoxResize(Sender:TObject);
begin
  if Assigned(FOrigSBoxResize) then
  begin
    FOrigSBoxResize(Sender);
  end;
  UpdateView;
end;


function TScrollBoxListCore<TView>.HandleNavigateKeyPress(Key:Word; Shift:TShiftState):Boolean;
var
  PageSize, MaxPos, NewPos:Integer;
begin
  Result := True;

  PageSize := FScrollBox.ClientHeight;
  MaxPos := FScrollBox.VertScrollBar.Range;
  case Key of
    VK_PRIOR:
      NewPos := FScrollBox.VertScrollBar.Position - PageSize;
    VK_NEXT:
      NewPos := FScrollBox.VertScrollBar.Position + PageSize;
    VK_HOME:
      NewPos := 0;
    VK_END:
      NewPos := MaxPos;
    VK_UP:
      NewPos := FScrollBox.VertScrollBar.Position - FScrollBox.VertScrollBar.Increment;
    VK_DOWN:
      NewPos := FScrollBox.VertScrollBar.Position + FScrollBox.VertScrollBar.Increment;
  else
    Exit(False);
  end;

  NewPos := Max(0, Min(MaxPos, NewPos));
  if NewPos <> FScrollBox.VertScrollBar.Position then
  begin
    FScrollBox.VertScrollBar.Position := NewPos;
    UpdateView;
  end;
end;


procedure TScrollBoxListCore<TView>.UpdateView;
var
  topView, bottomView, yAccum:Integer;
  i, count:Integer;
  Visible:TList<Integer>;
  View:TView;
  h:Integer;
  IndexIsActive:Boolean;
  IndexIsPooled:Boolean;
begin
  topView := FScrollBox.VertScrollBar.Position;
  bottomView := topView + FScrollBox.ClientHeight;

  Visible := TList<Integer>.Create;
  try
    yAccum := 0;
    count := FGetCount();
    for i := 0 to count - 1 do
    begin
      h := FGetHeight(i);
      if (yAccum + h >= topView) and (yAccum <= bottomView) then
      begin
        Visible.Add(i);
        IndexIsActive := FActive.TryGetValue(i, View); // if active, can skip create and bind and is already visible
        IndexIsPooled := False;
        if not IndexIsActive then
        begin
          IndexIsPooled := FPool.TryGetValue(i, View);
          if IndexIsPooled then // re-use pooled view for this index (can skip create + bind, but need to set visible)
          begin
            FPool.Remove(i);
          end
          else if not(FMaxCacheSize <= 0) then //no need to pool - unlimited cache
          begin
            if (FPool.count > 0) then
            begin
              // remove oldest from pool to be reused  (can skip create, but need to bind)
              var Pairs := FPool.ToArray;
              var FIFO := Pairs[0];
              View := FIFO.Value;
              FPool.Remove(FIFO.Key);
            end
            else
            begin
              // not an active view, and nothing in pool re-use, so this is the heaviest load: now need to create, bind, and set visible
              View := FCreateItem(FScrollBox.Owner, FScrollBox);
            end;
          end;
          FActive.Add(i, View);
        end;
        View.SetBounds(0, yAccum - topView, FScrollBox.ClientWidth, h);
        if not IndexIsActive then
        begin
          if not IndexIsPooled then
          begin
            FBindItem(View, i);
          end;
          View.Visible := True;
        end;
      end;
      Inc(yAccum, h);
    end;

    ReleaseUnusedItems(Visible);
  finally
    Visible.Free;
  end;
end;


procedure TScrollBoxListCore<TView>.ReleaseUnusedItems(const Visible:TList<Integer>);
var
  ToRecycle:TList<Integer>;
  idx:Integer;
  View:TView;
begin
  ToRecycle := TList<Integer>.Create;
  try
    // Collect indices that fell out of view
    for idx in FActive.Keys do
      if not Visible.Contains(idx) then
      begin
        ToRecycle.Add(idx);
      end;

    // Recycle or free each one
    for idx in ToRecycle do
      if FActive.TryGetValue(idx, View) then
      begin
        FActive.Remove(idx);
        View.Visible := False;

        // If cache is unlimited (<=0) or still under capacity, keep it
        if (FMaxCacheSize <= 0) or (FPool.count < FMaxCacheSize) then
        begin
          FPool.Add(idx, View)
        end
        else
        begin
          if FPool.count > 0 then
          begin
            // remove oldest in the pool
            var Pairs := FPool.ToArray;
            var  FIFO := Pairs[0];
            FIFO.Value.Free;
            FPool.Remove(FIFO.Key);
          end;
          // add to end of queue
          FPool.Add(idx, View);
        end;
      end;
  finally
    ToRecycle.Free;
  end;
end;

end.
