@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidgetForm.j"
@import "LLQuizWidgetForm.j"

var __LLWidgetFormPanelShared__ = nil;

LLWidgetFormPanelModeNew = "LLWidgetFormPanelModeNew"
LLWidgetFormPanelModeEdit = "LLWidgetFormPanelModeEdit"

@implementation LLWidgetFormPanel : CPPanel
{
	CCWidget _widget @accessors(property=widget);
	
	CPButton _okButton;
	CPString _mode @accessors(property=mode);
	Function _callback @accessors(property=callback);
	CCWidgetForm _form;
	CPScrollView sv;
}

+(id)sharedPanel
{
	if(!__LLWidgetFormPanelShared__)
		__LLWidgetFormPanelShared__ = [[self alloc] init];
	return __LLWidgetFormPanelShared__;
}

- (id)init
{
	var width = 500;
	var height = 400;
	if (self = [super initWithContentRect:CGRectMake(100, 100, width, height) styleMask:CPTitledWindowMask|CPHUDBackgroundWindowMask])
	{
		[self setShowsResizeIndicator:NO];
		[self setTitle:@"Widget Form"];
        [self setMinSize:CPSizeMake(250, 76)];
		_mode = LLWidgetFormPanelModeEdit;
		sv = [[CPScrollView alloc] initWithFrame:CGRectMake(0,0,width,height-40)];
		[sv setHasHorizontalScroller:NO];
		var okButton = [CPButton buttonWithTitle:"School" theme:[CPTheme defaultHudTheme]];
			cancelButton = [CPButton buttonWithTitle:"Cancel" theme:[CPTheme defaultHudTheme]],
			buttonY = height/*Height of the content rect*/ - ((40 - [okButton frame].size.height) / 2) - [okButton frame].size.height,
			okX = width/*Width of the content rect*/ - 10 - [okButton frame].size.width,
			cancelX = okX - 10 - [cancelButton frame].size.width;
		[okButton setFrameOrigin:CGPointMake(okX,buttonY)];
		[cancelButton setFrameOrigin:CGPointMake(cancelX,buttonY)];
		[okButton setTarget:self];
		[cancelButton setTarget:self];
		[okButton setAction:@selector(ok)];
		[cancelButton setAction:@selector(cancel)];
		_okButton = okButton;
		//	Adding Subviews
		[[self contentView] addSubview:sv];
		[[self contentView] addSubview:okButton];
		[[self contentView] addSubview:cancelButton];
		[self setMode:LLWidgetFormPanelModeNew];
	}
	return self;
}

-(CPView)_configureFormForWidget:(CCWidget)widget
{
	var svfs = [sv frameSize];
	_form = [[[widget formClass] alloc] initWithFrame:CGRectMake(0,0,svfs.width-15,svfs.height)];
	[sv setDocumentView:_form];
	[_form setWidget:widget];
}

-(void)setWidget:(CCWidget)widget
{
	_widget = widget;
	[self _configureFormForWidget:widget];
	[self _updateUI];
}

-(void)setMode:(CPString)mode
{
	if(_mode == mode)
		return;
	_mode = mode;
	[self _updateUI];
}

-(void)_updateUI
{
	[_okButton setTitle:(_mode == LLWidgetFormPanelModeNew ? @"Add" : @"Edit")];
	[self setTitle:(_mode == LLWidgetFormPanelModeNew ? @"New" : @"Edit")+" "+[_widget name]];	
}

-(void)ok
{
	[_form commit];
	_callback([_form widget]);
	[self cancel];
}

-(void)cancel
{
	_callback = function(){};
	[self close];
	[[CPApplication sharedApplication] abortModal];
}

@end

@implementation CPApplication (LLWidgetFormPanelAdditions)

-(void)orderFrontWidgetFormPanel
{
	[[LLWidgetFormPanel sharedPanel] makeKeyAndOrderFront:self];
}

@end

@implementation CCWidget (LLWidgetFormPanelAdditions)

+(Class)formClass
{
	return CPClassFromString(CPStringFromClass(self) + "Form");
}

-(Class)formClass
{
	return [[self class] formClass];
}

+(CPString)name
{
	var str = CPStringFromClass(self);
	str = [str stringByReplacingOccurrencesOfString:"Widget" withString:""];
	return [str substringFromIndex:2];
}

-(CPString)name
{
	return [[self class] name];
}

@end