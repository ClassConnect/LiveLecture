@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "CCWidgetInspectorContentView.j"
@import "LLInspectorPanel.j"

@implementation CCPictureWidgetInspectorContentView : CCWidgetInspectorContentView
{
	CPTextField _sourceField;
}

+(CGSize)contentSize
{
	return CGSizeMake(250,300);
}

-(void)createView
{
	var label = [CPTextField labelWithTitle:@"Picture URL:"],
		editableField = [CPTextField textFieldWithStringValue:@"" placeholder:@"Ex: http://classconnect.com/site_img/logo.png" width:240],
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
	[self updateWidget];
}

-(void)widgetDidChange
{
	[_sourceField setStringValue:[_widget imagePath]];
}

-(void)didPressReturn
{
	[self updateWidget];
}

-(void)updateWidget
{
	[_widget setImagePath:[_sourceField stringValue]];
	[_layer setWidget:_widget];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

@end