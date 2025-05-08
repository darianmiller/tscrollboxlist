# TScrollBoxList

## Virtual scroll box list for Delphi VCL

Display an unlimited number of TFrames within a TScrollBox with configurable cache, smooth scrolling and
 mouse-wheel support, keyboard navigation, and resize handling.


Current VCL usage
1. Drop a TScrollBox on your form.
2. Create a custom TFrame that displays your data elements as you normally would do.
3. Create a function to dynamically create your frame. This can be something simple like this. (You will pass this function to the ScrollBoxList constructor and it will be used to create a new frame as needed.)
````
function MyFixedFrameCreate(const AOwner:TComponent; const AParent:TWinControl):TMyFixedHeightFrame;
begin
  Result := TMyFixedHeightFrame.Create(AOwner);
  Result.Parent := AParent;
  Result.Name := '';
end;
````
4. Create a function to dynamically bind your data to your frame.  (You will pass this function to the ScrollBoxList constructor and it will be used to populate the frame as needed.)
````
procedure MyFrameBind(const AView:TMyFixedHeightFrame; const AModel:TMyFixedData; const AIndex:Integer);
begin
  AView.DoBind(AModel, AIndex);  //typically just a forward 
end;

//normal data-to-visual-control population
procedure TMyFixedHeightFrame.DoBind(const Item:TMyFixedData; const Index:Integer);
begin
  Label2.Caption := Item.Title;
  Label3.Caption := Item.Description;
  Label4.Caption := Item.CurrentValue.ToString;  //Helps prove the binding changed
end;
````
5. Create a `TVariableHeightScrollBoxList` instance for variable item heights or `TFixedHeightScrollBoxList` for rows with all the same heights.
For example:  `TFixedHeightScrollBoxList<TMyFixedHeightFrame>.Create(ScrollBox1, FIXED_HEIGHT, FFixedData.Count, MyFixedFrameCreate, MyFixedHeightBind, CACHE_SIZE);`

With two small/easy functions defined and one ScrollBoxList instance created, you can virtually scroll your data on a designated TScrollBox with a CACHE_SIZE number of TFrame instances that are dynamically built and populated as needed.

Currently a `work-in-progress` and more changes are in the works.  The virtual list is currently assumed to be used for displaying read-only data.

----

<p align="center">
<img src="bin/delphi.png" alt="Delphi">
</p>
<h5 align="center">
