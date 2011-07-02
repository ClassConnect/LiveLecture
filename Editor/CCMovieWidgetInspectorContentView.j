@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "CCWidgetInspectorContentView.j"
@import "LLInspectorPanel.j"

@implementation CCMovieWidgetInspectorContentView : CCWidgetInspectorContentView
{
	CPTextField _yidField;
}

+(CGSize)contentSize
{
	return CGSizeMake(250,300);
}

-(void)createView
{
	var label = [CPTextField labelWithTitle:@"Youtube URL:"],
		editableField = [CPTextField textFieldWithStringValue:@"" placeholder:@"Ex: http://www.youtube.com/watch?v=bESGLojNYSo" width:240],
		lframe = [label frame],
		eframe = [editableField frame],
		csize  = [[self class] contentSize];
	[label setFrame:CGRectMake(5,(csize.height / 2)-lframe.size.height,lframe.size.width,lframe.size.height)];
	[editableField setFrame:CGRectMake(5,csize.height/2,eframe.size.width,eframe.size.height)];
	//	We need to adjust the editable field to be even with the label
	//	To do that, after we set the frame, we set the center y coordinate to be the same as the example label
	[self addSubview:label];
	[self addSubview:editableField];
	_yidField = editableField;
	[_yidField setTarget:self];
	[_yidField setAction:@selector(didPressReturn)];
}

-(void)widgetWillChange
{
	//	Whenever the widget is about to change to a different widget, we want
	//	to update the widget to whatever is in the text field
	[self updateWidget];
}

-(void)widgetDidChange
{
	[_yidField setStringValue:[_widget movie]._filename];
}

-(void)didPressReturn
{
	[self updateWidget];
}

-(void)updateWidget
{
	var text = [_yidField stringValue];
	if(text.indexOf("youtube.com") == -1)
		[_widget setYoutubeID:text];
	else
		[_widget setMovie:[CPFlashMovie flashMovieWithFile:text]];
	[_layer setWidget:_widget];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

@end