@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLSlideThemeManager.j"
@import "LLSlideThemeCollectionItem.j"

var __shared__ = nil;

@implementation LLSlideThemeSelectionPanel : CPPanel
{
	LLSlideThemeManager _manager;
	
	CPCollectionView _collection;
}

+(id)sharedPanel
{
	return ((__shared__) ? __shared__ : __shared__ = [[LLSlideThemeSelectionPanel alloc] init]);
}

-(id)init
{
	if(self = [self initWithContentRect:CGRectMake(200,100,617,390) styleMask:CPTitledWindowMask|CPHUDBackgroundWindowMask])
	{
		[self setTitle:"Themes"];
		_manager = [[LLSlideThemeManager alloc] init];
		[_manager setDelegate:self];
		//	CPScrollView
		var sv = [[CPScrollView alloc] initWithFrame:CGRectMake(1,0,615,350)],
			itemPrototype = [[CPCollectionViewItem alloc] init];
		[sv setAutoresizingMask:	CPViewWidthSizable |
									CPViewHeightSizable];
		[sv setHasHorizontalScroller:NO];
		[sv setBackgroundColor:[CPColor whiteColor]];
		//	CPCollectionView
		_collection = [[CPCollectionView alloc] initWithFrame:CGRectMake(0,0,600,350)];
		[_collection setMinItemSize:CGSizeMake(200,200)];
		[_collection setMaxItemSize:CGSizeMake(200,200)];
		[_collection setBackgroundColor:[CPColor colorWithCSSString:"#DDDDDD"]];
		[itemPrototype setView:[[LLSlideThemeCollectionItem alloc] initWithFrame:CGRectMake(0,0,199,200)]];
		[_collection setItemPrototype:itemPrototype];
		[sv setDocumentView:_collection];
		//	Buttons
		var okButton = [CPButton buttonWithTitle:"OK" theme:[CPTheme defaultHudTheme]],
			cancelButton = [CPButton buttonWithTitle:"Cancel" theme:[CPTheme defaultHudTheme]],
			buttonY = 390/*Height of the content rect*/ - ((390 - [sv frame].size.height - [okButton frame].size.height) / 2) - [okButton frame].size.height,
			okX = 617/*Width of the content rect*/ - 10 - [okButton frame].size.width,
			cancelX = okX - 10 - [cancelButton frame].size.width;
		[okButton setFrameOrigin:CGPointMake(okX,buttonY)];
		[cancelButton setFrameOrigin:CGPointMake(cancelX,buttonY)];
		[okButton setTarget:self];
		[cancelButton setTarget:self];
		[okButton setAction:@selector(userDidConfirmNewTheme)];
		[cancelButton setAction:@selector(cancel)];
		//	Adding Subviews
		[[self contentView] addSubview:sv];
		[[self contentView] addSubview:okButton];
		[[self contentView] addSubview:cancelButton];
	}
	return self;
}

-(void)loadContent
{
	if([_manager loadStatus] != LLSlideThemeManagerLoadStatusCompleted)
		return;
	[_collection setContent:[_manager themes]];
	[self selectCurrentTheme];
}

-(void)selectCurrentTheme
{
	[_collection setSelectionIndexes:[CPIndexSet indexSetWithIndex:[_manager indexOfTheme:[[[LLPresentationController sharedController] currentSlide] theme]]]];
}

-(void)cancel
{
	[self selectCurrentTheme];
	[self close];
	[[CPApplication sharedApplication] abortModal];
}

-(void)userDidConfirmNewTheme
{
	//	If they selected a theme that is not the currrent one, then set the new theme and close the window
	if([_manager indexOfTheme:[[[LLPresentationController sharedController] presentation] theme]] != [[_collection selectionIndexes] lastIndex])
	{
		//	Set the new theme!
		[[LLPresentationController sharedController] setTheme:[[_manager themeAtIndex:[[_collection selectionIndexes] lastIndex]] copy]];
	}
	[self close];
	[[CPApplication sharedApplication] abortModal];
}

//
//	LLSlideThemeManagerDelegate
//

-(void)themeManagerDidFinishLoading:(LLSlideThemeManager)manager
{
	[self loadContent];
}

@end

@implementation CPApplication (LLSlideThemeSelectionPanelAdditions)

-(void)orderFrontThemeSelectionPanel
{
	[[LLSlideThemeSelectionPanel sharedPanel] orderFront:self];
}

@end