@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidgetInspectorContentView.j"
@import "LLInspectorPanel.j"

@implementation CCMovieWidgetInspectorContentView : CCWidgetInspectorContentView
{
	CPTextField _yidField;
	CPCheckBox _svCheckBox;
}

+(CGSize)contentSize
{
	return CGSizeMake(250,300);
}

-(void)createView
{
	var label = [CPTextField labelWithTitle:@"Youtube URL:"],
		editableField = [CPTextField textFieldWithStringValue:@"" placeholder:@"Ex: http://www.youtube.com/watch?v=bESGLojNYSo" width:240],
		checkbox = [CPCheckBox checkBoxWithTitle:"Sync video with your students"],
		explanationLabel = [CPTextField labelWithTitle:@"If checked, during a presentation your students' videos will start when your video start, and will pause when your video pauses."];
	[label setFrame:CGRectMake(17,20,216,17)];
	[editableField setFrame:CGRectMake(17,45,216,22+8)];
	[checkbox setFrame:CGRectMake(18,73+8,214,18)];
	[explanationLabel setFrame:CGRectMake(17,97+8,216,87)]
	//	We need to adjust the editable field to be even with the label
	//	To do that, after we set the frame, we set the center y coordinate to be the same as the example label
	[self addSubview:label];
	[self addSubview:editableField];
	[self addSubview:checkbox];
	[self addSubview:explanationLabel];
	//	Multi line fix
	[explanationLabel setLineBreakMode:CPLineBreakByWordWrapping];
	_yidField = editableField;
	_svCheckBox = checkbox;
	[_yidField setTarget:self];
	[_yidField setAction:@selector(didPressReturn)];
	[checkbox setTarget:self];
	[checkbox setAction:@selector(didChangeSyncVideos)];
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
	[_yidField setStringValue:[_widget movie]._filename];
	[_svCheckBox setState:([_widget syncsVideos]) ? CPOnState : CPOffState];
}

-(void)didPressReturn
{
	[self updateWidget];
	[self updateLayer];
}

-(void)didChangeSyncVideos
{
	[self updateWidget];
	[self updateLayer];
}

-(void)updateWidget
{
	var text = [_yidField stringValue];
	if(text.indexOf("youtube.com") == -1)
		[_widget setYoutubeID:text];
	else
		[_widget setMovie:[CPFlashMovie flashMovieWithFile:text]];
	//	Update sync
	[_widget setSyncsVideos:([_svCheckBox intValue]) ? YES : NO];
}

-(void)updateLayer
{
	[_layer setWidget:_widget];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

@end