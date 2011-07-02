@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidget+LLInspectorPanelAdditions.j" 

//	NOTE: All Content Views are imported at the bottom of this file

var __LLINSPECTORPANEL_SHARED__ = nil;

@implementation LLInspectorPanel : CPPanel
{
	LLInspectorPanelContentView _content;
}

+ (id)sharedPanel
{
	if(!__LLINSPECTORPANEL_SHARED__)
	{
		__LLINSPECTORPANEL_SHARED__ = [[self alloc] init];
	}
	return __LLINSPECTORPANEL_SHARED__;
}

- (id)init
{
	var size = [[CCWidget inspectorContentViewClass] contentSize];
	if (self = [super initWithContentRect:CGRectMake(400, 100, size.width, size.height) styleMask:CPTitledWindowMask|CPResizableWindowMask|CPClosableWindowMask])
	{
		[self setShowsResizeIndicator:NO];
		[self setTitle:@"Inspector"];
        [self setMinSize:CPSizeMake(250, 76)];
		//	Set the default inspector thing
		_content = [[CCWidget inspectorContentViewClass] new];
		[[self contentView] addSubview:_content];
	}
	return self;
}

-(void)setContentViewForWidget:(CCWidget)widget correspondingLayer:(CCWidgetLayer)layer
{
	//	If it is the same widget, then don't do anything
	if(widget == [_content widget])
		return;
	[_content widgetWillChange];
	//	Only make a new view if there is a differnet widget class
	if([[_content widget] class] != [widget class])
	{
		[_content removeFromSuperview];
		var inspectorClass = ((!widget) ? [CCWidget inspectorContentViewClass] : [[widget class] inspectorContentViewClass]);
		//	Add 26 to the size to account for the top bar.
		var size = [inspectorClass contentSize];
		size.height = size.height + 26;
		if([inspectorClass contentSize] != [self frame].size)
			[self setFrameSize:size];
		_content = [inspectorClass new];
		[[self contentView] addSubview:_content];
	}
	[_content setWidget:widget];
	[_content setLayer:layer];
	[_content widgetDidChange];
}

@end

@implementation CPApplication (LLInspectorPanelAdditions)

- (void)orderFrontInspectorPanel
{
    [[LLInspectorPanel sharedPanel] orderFront:self];
}

@end

//	I have to put these down here because CCTextWidgetInspectorContentView adds methods to LLInspectorPanel, which is not yet declared by the
//	time it is executed
@import "CCPictureWidgetInspectorContentView.j"
@import "CCMovieWidgetInspectorContentView.j"
@import "CCTextWidgetInspectorContentView.j"
@import "LLQuizWidgetInspectorContentView.j"
@import "CCWebWidgetInspectorContentView.j"
@import "CCWidgetInspectorContentView.j"