/*
 * AppController.j
 * Core Lecture
 *
 * Created by Scott Rice on January 12, 2011.
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
//@import "CCPresentation.j"
//@import "CCPresentationController.j"
//@import "CCEventForwardingView.j"
//	Slides
//@import "CCSlide.j"
//@import "CCSlideLayer.j"
//@import "CCNotificationLayer.j"

@import "CCTokBoxView.j"

@implementation AppController : CPObject {
	CPWindow theWindow;
	CCPresentationController controller;
	
	CPView _containerView @accessors(readonly,property=container);
	CALayer _rootLayer;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification {
	CPLogRegister(CPLogConsole);
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];
		
	[theWindow orderFront:self];

	var tbv = [[CCTokBoxView alloc] initWithFrame:[contentView bounds]];
	[tbv setSessionID:"1b964a08d446dcbb811889deca24dbcb69926100"];
	[tbv setToken: "T1==cGFydG5lcl9pZD02Mjc2ODImc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wMy0wNyZzaWc9YjBkM2E4ZGJjZjJkYmNmYWJlZWI2YTFjNDcxNjUyMmM0NGNiZDlkZDpzZXNzaW9uX2lkPSZjcmVhdGVfdGltZT0xMzA1MTY5NzcyJnJvbGU9cHVibGlzaGVyJm5vbmNlPTEzMDUxNjk3NzIuMTk1NzQ3MjcxNDc4"];
	[contentView addSubview:tbv];
	[tbv connect];
	
/*
	var cvbounds = [contentView bounds];
	
	var container = [[CCSlideView alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth([contentView bounds]),CGRectGetHeight([contentView bounds]))];
	[container setAutoresizingMask: CPViewWidthSizable	|
	 								CPViewHeightSizable ];
									
	_containerView = container;
	//	Add all the subviews
	// [contentView addSubview:[nav view]];
	[contentView addSubview:container];
	
	//	Set the references in the CCPresentationController
	controller = [CCPresentationController sharedController];
	[controller setMainSlideView:container];
	[container setIsThumbnail:NO];
	[[controller mainSlideView] setSlide:[controller currentSlide]];
	
	//	Set the main slide layer to get notifications from frame changess
	[[CPNotificationCenter defaultCenter] addObserver:[container slideLayer] selector:@selector(resize) name:@"CPViewFrameDidChangeNotification" object:nil];
	[contentView setPostsFrameChangedNotifications:YES];
	
	[container setNeedsDisplay:YES];
*/
}

-(void)setupMenuBar {
	[CPMenu setMenuBarVisible:YES];
	var menu = [CPApp mainMenu];
	[[menu itemWithTitle:"New"] setKeyEquivalent:"n"];
	[[menu itemWithTitle:"New"] setKeyEquivalentModifierMask:CPCommandKeyMask];
	[[menu itemWithTitle:"New"] setTarget:controller];
	[[menu itemWithTitle:"New"] setAction:@selector(new)];
	[[menu itemWithTitle:"Open"] setKeyEquivalent:"o"];
	[[menu itemWithTitle:"Open"] setKeyEquivalentModifierMask:CPCommandKeyMask];
	[[menu itemWithTitle:"Open"] setTarget:controller];
	[[menu itemWithTitle:"Open"] setAction:@selector(open)];
	[[menu itemWithTitle:"Save"] setKeyEquivalent:"s"];
	[[menu itemWithTitle:"Save"] setKeyEquivalentModifierMask:CPCommandKeyMask];
	[[menu itemWithTitle:"Save"] setTarget:controller];
	[[menu itemWithTitle:"Save"] setAction:@selector(save)];
//	[[menu itemWithTitle:"Save As"] setKeyEquivalent:"S"];
//	[[menu itemWithTitle:"Save As"] setKeyEquivalentModifierMask:CPCommandKeyMask];
//	[[menu itemWithTitle:"Save As"] setTarget:controller];
//	[[menu itemWithTitle:"Save As"] setAction:@selector(saveas)];
	
}

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar {
   return [	CPToolbarFlexibleSpaceItemIdentifier,
   			LLToolbarNewSlideItemIdentifier,
   			LLToolbarDeleteSlideItemIdentifier,
   			LLToolbarNewTextWidgetItemIdentifier,
   			LLToolbarNewPictureWidgetItemIdentifier,
   			LLToolbarPresentItemIdentifier];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar {
   return [	LLToolbarNewSlideItemIdentifier,
   			LLToolbarDeleteSlideItemIdentifier,
   			CPToolbarFlexibleSpaceItemIdentifier,
   			LLToolbarNewTextWidgetItemIdentifier,
   			LLToolbarNewPictureWidgetItemIdentifier,
   			CPToolbarFlexibleSpaceItemIdentifier,
   			LLToolbarPresentItemIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag {
	var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
	var target,
		action,
		label,
		imagename;
	if(anItemIdentifier == LLToolbarNewSlideItemIdentifier) {
		target = controller;
		action = @selector(newSlide);
		label = "New Slide";
		imagename = "Icon.png";
	}
	else if(anItemIdentifier == LLToolbarDeleteSlideItemIdentifier) {
		target = controller;
		action = @selector(deleteCurrentSlide);
		label = "Delete Slide";
		imagename = "Icon.png";
	}
	else if(anItemIdentifier == LLToolbarNewTextWidgetItemIdentifier) {
		target = nil;
		action = @selector(newTextWidget);
		label = "Text";
		imagename = "Icon.png";
	}
	else if(anItemIdentifier == LLToolbarNewPictureWidgetItemIdentifier) {
		target = controller;
		action = @selector(newPictureWidget);
		label = "Pictures";
		imagename = "Icon.png";
	}
	else if(anItemIdentifier == LLToolbarPresentItemIdentifier) {
		target = nil;
		action = @selector(present:);
		label = "Present";
		imagename = "Icon.png";
	}
	//	Set up the item
	var image = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:imagename]];
	[toolbarItem setImage:image];
	[toolbarItem setTarget:target];
	[toolbarItem setAction:action];
	[toolbarItem setLabel:label];
	[toolbarItem setMinSize:CGSizeMake(32,32)];
	[toolbarItem setMaxSize:CGSizeMake(32,32)];
	
	return toolbarItem;
}

@end


