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
	return CGSizeMake(300,200);
}

-(void)createView
{
	var label = [CPTextField labelWithTitle:@"Youtube ID:"],
		exampleLabel = [CPTextField labelWithTitle:@"http://youtube.com/watch?v="];
		editableField = [CPTextField textFieldWithStringValue:@"" placeholder:@"Ex: bESGLojNYSo" width:50],
		lframe = [label frame],
		xframe = [exampleLabel frame],
		eframe = [editableField frame],
		csize  = [[self class] contentSize];
	[label setFrame:CGRectMake(5,(csize.height / 2)-lframe.size.height,lframe.size.width,lframe.size.height)];
	[exampleLabel setFrame:CGRectMake(5,csize.height/2,xframe.size.width,xframe.size.height)];
	[editableField setFrame:CGRectMake(5+xframe.size.width+1,csize.height/2,300-10-xframe.size.width,eframe.size.height)];
	//	We need to adjust the editable field to be even with the label
	//	To do that, after we set the frame, we set the center y coordinate to be the same as the example label
	[editableField setCenter:CGPointMake([editableField center].x,[exampleLabel center].y)];
	[self addSubview:label];
	[self addSubview:exampleLabel];
	[self addSubview:editableField];
	_yidField = editableField;
	[_yidField setTarget:self];
	[_yidField setAction:@selector(didPressReturn)];
}

-(void)widgetDidChange
{
	[_yidField setStringValue:[_widget youtubeID]];
}

-(void)didPressReturn
{
	var newYID = [_yidField stringValue];
	[_widget setYoutubeID:newYID];
	[_layer setWidget:_widget];
}

@end