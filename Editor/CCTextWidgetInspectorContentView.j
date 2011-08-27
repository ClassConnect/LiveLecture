@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidgetInspectorContentView.j"
@import "LLInspectorPanel.j"

var CCTextWidgetInspectorContentViewSeperatorColor = [CPColor grayColor];
var CCTextAvaliableFonts = [[CPFontManager sharedFontManager] availableFonts];
var CCTextAvaliableFontSizes = ["8","12","14","16","18","20","24","28","32","36","40","48","60","72","84","96"];

@implementation CCTextWidgetInspectorContentView : CCWidgetInspectorContentView
{
	CPPopUpButton _fontSelector;
	CPPopUpButton _fontSizeSelector;
	CPColorWell _textColorWell;
	CPSegmentedControl _alignmentPicker;
	CPSegmentedControl _textStylingPicker;
	CPSegmentedControl _bulletLevelPicker;
	CPSegmentedControl _bulletTypePicker;
}

+(CGSize)contentSize
{
	return CGSizeMake(250,200);
}

-(void)createView
{
	var firstSeperator = [[CPView alloc] initWithFrame:CGRectMake(12,67,226,1)],
		secondSeperator= [[CPView alloc] initWithFrame:CGRectMake(12,134,226,1)];
	[firstSeperator setBackgroundColor:CCTextWidgetInspectorContentViewSeperatorColor];
	[secondSeperator setBackgroundColor:CCTextWidgetInspectorContentViewSeperatorColor];
	
	//	First Row
	_fontSelector = [[CPPopUpButton alloc] initWithFrame:CGRectMake(136,20,97,26)];
	[self addFontOptionsWithTitles:CCTextAvaliableFonts];
	_fontSizeSelector = [[CPPopUpButton alloc] initWithFrame:CGRectMake(69,20,65,26)];
	[self addFontSizeOptionsWithTitles:CCTextAvaliableFontSizes];
	
	//	CGRectMake(20,20,44,26)
	_textColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(20,20,44,26)];
	[_textColorWell setTarget:self];
	[_textColorWell setAction:@selector(colorWellDidChangeColor)];
	var sv = [CPShadowView shadowViewEnclosingView:_textColorWell withWeight:CPLightShadow];
	//	Second Row
	_alignmentPicker = [[CPSegmentedControl alloc] initWithFrame:CGRectMake(18,89,104,24)];
	//	The tags in this case correspond to the alignment mask that the option represents
	[self setupSegmentedControl:_alignmentPicker withItems:["text_icon_align_left.png","text_icon_align_center.png","text_icon_align_right.png","text_icon_align_justify.png"] andTags:[1,4,2,8]];
	_textStylingPicker = [[CPSegmentedControl alloc] initWithFrame:CGRectMake(128,89,104,24)];
	[self setupSegmentedControl:_textStylingPicker withItems:["text_icon_style_bold.png","text_icon_style_italic.png","text_icon_style_underline.png"] andTags:nil];
	[_textStylingPicker setTrackingMode:CPSegmentSwitchTrackingSelectAny];
	//	Third Row
	_bulletLevelPicker = [[CPSegmentedControl alloc] initWithFrame:CGRectMake(18,159,87,24)];
	[self setupSegmentedControl:_bulletLevelPicker withItems:["text_icon_indent_decrease.png","text_icon_indent_increase.png"] andTags:nil];
	[_bulletLevelPicker setTrackingMode:CPSegmentSwitchTrackingMomentary];
	_bulletTypePicker = [[CPSegmentedControl alloc] initWithFrame:CGRectMake(109,159,87,24)];
	//	The tags are the bullet style masks
	[self setupSegmentedControl:_bulletTypePicker withItems:["text_icon_bullets_decimal.png","text_icon_bullets_numbered.png"] andTags:[1,4]];
	[self addSubview:firstSeperator];
	[self addSubview:secondSeperator];
	[self addSubview:_fontSelector];
	[self addSubview:_fontSizeSelector]
//	[self addSubview:_textColorWell];
	[self addSubview:sv];
	[self addSubview:_alignmentPicker];
	[self addSubview:_textStylingPicker];
	[self addSubview:_bulletLevelPicker];
	[self addSubview:_bulletTypePicker];
}

-(void)widgetWillChange
{
	_layer._selectionDelegate = nil;
}

-(void)widgetDidChange
{
	_layer._selectionDelegate = self;
	[self textLayerDidChangeSelection:_layer];
}

//	Setup helper functions
	
-(void)setupSegmentedControl:(CPSegmentedControl)control withItems:(CPArray)items andTags:(CPArray)tags
{
	var origFrame = [control frame],
		dividerThickness = [control currentValueForThemeAttribute:@"divider-thickness"],
		segmentWidth = (origFrame.size.width - (([items count]-1) *dividerThickness)) / [items count];
	[control setSegmentCount:[items count]];
	for(var i = 0 ; i < [items count] ; i++)
	{
		[control setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:items[i]] size:CGSizeMake(16,16)] forSegment:i];
		[control setWidth:segmentWidth forSegment:i];
		if(tags)
			[control setTag:tags[i] forSegment:i];
	}
	//	The above methods fuck with the width, so lets manually reset it here
	[control setFrame:origFrame];
	[control setTarget:self];
	[control setAction:@selector(segmentedControlDidChangeSelection:)];
}

-(void)addFontOptionsWithTitles:(CPArray)titles
{
	[self addMenuItemsToPopUpButton:_fontSelector 
						 withTitles:titles 
					 callbackAction:@selector(selectedFontDidChange:) 
					  customization:function(item){
		[item setFont:[CPFont fontWithName:[item title] size:12]];
	}];
}

-(void)addFontSizeOptionsWithTitles:(CPArray)titles
{
	[self addMenuItemsToPopUpButton:_fontSizeSelector withTitles:titles callbackAction:@selector(selectedFontSizeDidChange:) customization:function(item){}];
}

-(void)addMenuItemsToPopUpButton:(CPPopUpButton)button withTitles:(CPArray)titles callbackAction:(sel)action customization:(JSObject)custoFunction
{
	for(var i = 0 ; i < [titles count] ; i++)
	{
		var item = [[CPMenuItem alloc] initWithTitle:titles[i] action:action keyEquivalent:nil];
		[item setTarget:self];
		[button addItem:item];
		custoFunction(item);
	}
}

//	Control Callbacks

-(void)selectedFontDidChange:(id)sender
{
	[_layer setFontFamily:[sender title]];
}

-(void)selectedFontSizeDidChange:(id)sender
{
	[_layer setFontSize:[sender title]];
}

-(void)colorWellDidChangeColor
{
	[_layer setTextColor:[_textColorWell color]];
}

-(void)segmentedControlDidChangeSelection:(id)sender
{
	switch(sender)
	{
		case _alignmentPicker:		[_layer align:[_alignmentPicker selectedTag]];
		break;
		case _textStylingPicker:	(([_textStylingPicker isSelectedForSegment:0]) ? [_layer bold:nil] : [_layer unbold:nil]);
									(([_textStylingPicker isSelectedForSegment:1]) ? [_layer italicize:nil] : [_layer unitalicize:nil]);
									(([_textStylingPicker isSelectedForSegment:2]) ? [_layer underline:nil] : [_layer ununderline:nil]);
		break;
		//	If the user clicks on the current bullet type, it should be turned off. If the current type is not the selected one, then set that one
		case _bulletTypePicker:		if([_layer typingTextAttributes].bulletStyleMask == [_bulletTypePicker selectedTag])
									{
										[_layer bulletStyle:[_bulletTypePicker selectedTag]];
										[_bulletTypePicker setSelected:NO forSegment:[_bulletTypePicker selectedSegment]];
									}
									else
									{
										(([_bulletTypePicker selectedTag] == -1) ? 0 : [_layer bulletStyle:[_bulletTypePicker selectedTag]]);
									}
		break;
		case _bulletLevelPicker:if([_bulletLevelPicker isSelectedForSegment:0])
															[_layer decreaseBulletLevel];
														if([_bulletLevelPicker isSelectedForSegment:1])
															[_layer increaseBulletLevel];
		break;
	}
}

//	Selection Delegate Methods

-(void)textLayerDidChangeSelection:(TextLayer)textLayer
{
	var attribs = [textLayer typingTextAttributes];
	[_fontSelector selectItemWithTitle:attribs.fontFamily];
	//	The "" is to turn attribs.fontSize into a string so the equality works
	[_fontSizeSelector selectItemWithTitle:""+attribs.fontSize];
	[_textColorWell setColor:attribs.color];
	[_textStylingPicker setSelected:(attribs.boldState & TextAttributeOnState) forSegment:0];
	[_textStylingPicker setSelected:(attribs.italicState & TextAttributeOnState) forSegment:1];
	[_textStylingPicker setSelected:(attribs.underlineState & TextAttributeOnState) forSegment:2];
	[_alignmentPicker selectSegmentWithTag:attribs.alignmentMask];
	//	TODO: Actually test this...
	[_bulletTypePicker setSelected:(attribs.bulletStyleMask == 1) forSegment:0];
	[_bulletTypePicker setSelected:(attribs.bulletStyleMask == 4) forSegment:1];
}

-(void)textLayerDidChangeTextAttributes:(TextLayer)textLayer
{
	//	I dont think this should do anything. Only the inspector panel should be changing attributes, so I think it is good.
}

@end

//	HACKY: So here is the deal, when I click on the color well to select a color, the slide view loses first responder
//	That means that the only way to get first responder back is by clicking on the text layer, but that is an issue
//	because as soon as I click the typing text attributes are back to whatever the previous character had.
//	So what I am going to do is forward on all the key events from the Inspector Panel and the Content View to the text layer
//	so it can hopefully update without trouble

@implementation LLInspectorPanel (CCTextWidgetFirstResponderHack)

-(BOOL)acceptsFirstResponder
{
	return YES;
}	

-(void)keyDown:(CPEvent)event
{
	if([_content respondsToSelector:@selector(keyDown:)])
		[_content keyDown:event];
}

-(void)keyUp:(CPEvent)event
{
	if([_content respondsToSelector:@selector(keyUp:)])
		[_content keyUp:event];
}

@end

@implementation CCTextWidgetInspectorContentView (CCTextWidgetFirstResponderHack)

-(BOOL)acceptsFirstResponder
{
	return YES;
}	

-(void)keyDown:(CPEvent)event
{
	[_layer keyDown:event];
}

-(void)keyUp:(CPEvent)event
{
	[_layer keyUp:event];
}

@end

