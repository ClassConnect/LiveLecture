@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "CCWidgetInspectorContentView.j"
@import "LLInspectorPanel.j"

@implementation CCWebWidgetInspectorContentView : CCWidgetInspectorContentView
{
	CPTextField _sourceField;
}

+(CGSize)contentSize
{
	return CGSizeMake(250,300);
}

-(void)createView
{
	var label = [CPTextField labelWithTitle:@"Website URL:"],
		editableField = [CPTextField textFieldWithStringValue:@"" placeholder:@"Ex: http://www.google.com" width:240],
		lframe = [label frame],
		eframe = [editableField frame],
		csize  = [[self class] contentSize];
	[label setFrame:CGRectMake(5,(csize.height / 2)-lframe.size.height,lframe.size.width,lframe.size.height)];
	[editableField setFrame:CGRectMake(5,csize.height/2,eframe.size.width,eframe.size.height)];
	[self addSubview:label];
	[self addSubview:editableField];
	_sourceField = editableField;
	[_sourceField setTarget:self];
	[_sourceField setAction:@selector(didPressReturn)];
}

-(void)widgetWillChange
{
	//	Whenever the widget is about to change to a different widget, we want
	//	to update the widget to whatever is in the text field
	[self updateWidget];
	[self updateLayer];
}

-(void)widgetDidChange
{
	[_sourceField setStringValue:[_widget URL]];
}

-(void)didPressReturn
{
	[self updateWidget];
	[self updateLayer];
}

-(void)updateWidget
{
	[_widget setURL:[_sourceField stringValue]];
}

-(void)updateLayer
{
	[_layer setWidget:_widget];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

@end