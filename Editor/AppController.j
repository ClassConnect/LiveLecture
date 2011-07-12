/*
 * AppController.j
 * LiveLecture
 *
 * Created by Scott Rice on January 12, 2011.
 * Copyright 2011, ClassConnect All rights reserved.
 *
 *	Class that is called as soon as the application loads
 */

//	Debug
//HOST = "http://ccinternal.com"
//	Production
HOST = ""

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "MediaKit/MediaKit.j"
@import "GrowlCappuccino/GrowlCappuccino.j"
@import "../CoreLecture/CoreLecture.j"
@import "LLUser.j"
@import "LLInspectorPanel.j"
@import "LLSlideThemeManager.j"
@import "LLPreviewEventHandler.j"
@import "LLPresentationController.j"
@import "LLOnlinePersistenceHandler.j"
@import "LLSlideNavigationViewController.j"
@import "EKGradientView.j"
@import "ERIC_EDIT_ME.j"

@import "../LLSharedUtilities/LLSlideCollectionItem.j"
@import "../LLSharedUtilities/LLQuizWidget.j"
@import "../LLSharedUtilities/LLQuizWidgetLayer.j"

// Identifiers
//	TODO: Make 'Other Widgets' bring up a panel where the user can drag in widgets that their school has added
var LLToolbarNewSlideItemIdentifier = "LLToolbarNewSlideItemIdentifier",
	LLToolbarDeleteSlideItemIdentifier = "LLToolbarDeleteSlideItemIdentifier",
	LLToolbarSelectThemeItemIdentifier = "LLToolbarSelectThemeItemIdentifier",
	//	Filebox and Searchbox
	LLToolbarFileboxItemIdentifier = "LLToolbarFileboxItemIdentifier",
	LLToolbarSearchboxItemIdentifier = "LLToolbarSearchboxItemIdentifier",
	//	Choosing any widget
    LLToolbarNewTextWidgetItemIdentifier = "LLToolbarNewTextWidgetItemIdentifier",
    LLToolbarNewPictureWidgetItemIdentifier = "LLToolbarNewPictureWidgetItemIdentifier",
	LLToolbarNewMovieWidgetItemIdentifier = "LLToolbarNewMovieWidgetItemIdentifier",
	LLToolbarNewWebWidgetItemIdentifier = "LLToolbarNewWebWidgetItemIdentifier",
	LLToolbarOtherWidgetItemIdentifier = "LLToolbarOtherWidgetItemIdentifier",
	//	Widget Z Index
	LLToolbarWidgetFrontIdentifier = "LLToolbarWidgetFrontIdentifier"
	LLToolbarWidgetBackIdentifier = "LLToolbarWidgetBackIdentifier"
	//	Extra
	LLToolbarInspectorItemIdentifier = "LLToolbarInspectorItemIdentifier",
    LLToolbarPreviewItemIdentifier = "LLToolbarPreviewItemIdentifier";

@implementation AppController : CPObject
{
	CPWindow _mainWindow;
	CPWindow _previewWindow;
	
	CPView _contentView;
	
	LLPresentationController _controller;
	
	CCSlideView _editorView;
	CCSlideView _previewView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification {
	CPLogRegister(CPLogConsole);
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
    _contentView = [theWindow contentView];
		
	[theWindow orderFront:self];
	_mainWindow = theWindow;
	[_contentView setBackgroundColor:[CPColor blackColor]];
	
	_controller = [LLPresentationController sharedController];
	
	var args = [[CPApplication sharedApplication] namedArguments];
	
	if([args containsKey:"fid"])
	{
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFinished:) name:LLOnlinePersistanceLoadSuccessful object:nil];
		[[LLOnlinePersistenceHandler sharedHandler] load];
	}
	else
	{
		[self showErrorMessage:"An error has occured. Try clicking the back button and reopening livelecture"]
	}
}

-(void)loadFinished:(CPNotification)notification
{
	[self setupView];
}

-(void)setupView
{
	[self setupMenuBar];
	
	var toolbar = [[CPToolbar alloc] initWithIdentifier:"com.classconnect.livelecture.toolbar"];
	[toolbar setDelegate:self];
	[toolbar setVisible:YES];
	[_mainWindow setToolbar:toolbar];
	
	var cvbounds = [_contentView bounds];
	
	//	Set up the left view, which is a LLSlideNavigationViewController
	var nav = [[LLSlideNavigationViewController alloc] init];
	[[nav view] setFrame:CGRectMake(0,0,215,cvbounds.size.height)];
	
	//	Set up the right view
	_editorView = [[CCSlideView alloc] initWithFrame:CGRectMake(215,0,CGRectGetWidth([_contentView bounds])-215,CGRectGetHeight([_contentView bounds]))];
	[_editorView setAutoresizingMask:	CPViewWidthSizable	|
	 									CPViewHeightSizable ];
	
	//	Add all the subviews
	[_contentView addSubview:[nav view]];
	
	if(CPBrowserIsEngine(CPInternetExplorerBrowserEngine))
	{
		var gradient = [[CPView alloc] initWithFrame:[_editorView frame]];
		[gradient setBackgroundColor:[CPColor lightGrayColor]];
	}
	else
	{
		var gradient = [[EKGradientView alloc] initWithFrame:[_editorView frame]];
		[gradient setColor1:[CPColor colorWithHexString:"A2A2A2"]];
		[gradient setColor2:[CPColor colorWithHexString:"F3F3F3"]];
	}
	[gradient setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
	[_contentView addSubview:gradient];
	[_contentView addSubview:_editorView];
	
	[_controller setNavigationController:nav];
	[_controller setMainSlideView:_editorView];
	
	[_editorView setIsThumbnail:NO];
	[[_controller mainSlideView] setSlide:[_controller currentSlide]];
	
	//	Set the main slide layer to get notifications from frame changess
	[[CPNotificationCenter defaultCenter] addObserver:[_editorView slideLayer] selector:@selector(resize) name:@"CPViewFrameDidChangeNotification" object:nil];
	[_contentView setPostsFrameChangedNotifications:YES];
	
	//	Set the first slide as the original index
	[[[LLPresentationController sharedController] navigationController] setSelectedIndex:0];
	
	[_editorView setNeedsDisplay:YES];
	
	[[TNGrowlCenter defaultCenter] setView:_contentView];
	
	window.onbeforeunload = function() {
		if([[LLPresentationController sharedController] isDirty])
			return "You have unsaved changes, are you sure you want to leave?";
	}
}

-(void)showErrorMessage:(CPString)message
{
//	[_label removeFromSuperview];
//	[_progressBar removeFromSuperview];
	var tfield = [CPTextField labelWithTitle:message];
	[tfield setTextColor:[CPColor whiteColor]];
	[tfield setCenter:[_contentView center]];
	[_contentView addSubview:tfield];
}

-(void)setupMenuBar {
	[CPMenu setMenuBarVisible:YES];
	var menu = [CPApp mainMenu];
	//	Remove the items I don't want
	[menu removeItem:[menu itemWithTitle:"New"]];
	[menu removeItem:[menu itemWithTitle:"Open"]];
	//	Get rid of the submenu for save, we still want the regular button
	[[menu itemWithTitle:"Save"] setSubmenu:nil];
	[[menu itemWithTitle:"Save"] setIndentationLevel:15];
	//	Set the keyboard shortcut and target/action
	[[menu itemWithTitle:"Save"] setKeyEquivalent:"s"];
	[[menu itemWithTitle:"Save"] setKeyEquivalentModifierMask:CPCommandKeyMask];
	[[menu itemWithTitle:"Save"] setTarget:[LLOnlinePersistenceHandler sharedHandler]];
	[[menu itemWithTitle:"Save"] setAction:@selector(save)];
	
	var helpItem = [[CPMenuItem alloc] initWithTitle:"Help" action:@selector(help) keyEquivalent:""];
	[helpItem setTarget:self];
	var backItem = [[CPMenuItem alloc] initWithTitle:"Back to ClassConnect" action:@selector(back) keyEquivalent:""];
	[backItem setTarget:self];
	[backItem setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:"icon_back.png"] size:CGSizeMake(16,16)]];
	[menu addItem:backItem];
	[menu addItem:helpItem];
}

-(void)back
{
	window.location = "/app/presentations.cc";
}

-(void)help
{
	var window = [[CPWindow alloc] initWithContentRect:CGRectMake(200,200,720,480) styleMask:CPTitledWindowMask|CPClosableWindowMask];
	[window setTitle:"Help"];
	var contentView = [window contentView],
		webview = [[CPWebView alloc] initWithFrame:[contentView bounds]];
	[webview setMainFrameURL:kLLInstructionalVideo];
	[contentView addSubview:webview];
	[window orderFront:self];
}

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar {
   return [	CPToolbarFlexibleSpaceItemIdentifier,
			CPToolbarSpaceItemIdentifier,
			LLToolbarNewSlideItemIdentifier,
			LLToolbarDeleteSlideItemIdentifier,
			LLToolbarSelectThemeItemIdentifier,
			LLToolbarNewTextWidgetItemIdentifier,
			LLToolbarNewPictureWidgetItemIdentifier,
			LLToolbarNewMovieWidgetItemIdentifier,
			LLToolbarNewWebWidgetItemIdentifier,
			LLToolbarOtherWidgetItemIdentifier,
			LLToolbarFileboxItemIdentifier,
			LLToolbarSearchboxItemIdentifier,
			LLToolbarInspectorItemIdentifier,
			LLToolbarPreviewItemIdentifier];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar {
   return [	LLToolbarNewSlideItemIdentifier,
			LLToolbarDeleteSlideItemIdentifier,
   			CPToolbarSpaceItemIdentifier,
			LLToolbarSelectThemeItemIdentifier,
			CPToolbarSpaceItemIdentifier,
			LLToolbarNewTextWidgetItemIdentifier,
   			LLToolbarNewPictureWidgetItemIdentifier,
			LLToolbarNewMovieWidgetItemIdentifier,
			LLToolbarNewWebWidgetItemIdentifier,
			LLToolbarOtherWidgetItemIdentifier,
			CPToolbarSpaceItemIdentifier,
			LLToolbarFileboxItemIdentifier,
			LLToolbarSearchboxItemIdentifier,
			CPToolbarSpaceItemIdentifier,
			LLToolbarWidgetFrontIdentifier,
			LLToolbarWidgetBackIdentifier,
   			CPToolbarFlexibleSpaceItemIdentifier,
			LLToolbarInspectorItemIdentifier,
   			LLToolbarPreviewItemIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)itemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag {
	var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	var target,
		action,
		label,
		imagename;
	switch(itemIdentifier)
	{
		case LLToolbarNewSlideItemIdentifier:			target = _controller;
														action = @selector(newSlide);
														label = "New Slide";
														imagename = "icon_slide_new.png";
														break;
		case LLToolbarDeleteSlideItemIdentifier:		target = _controller;
														action = @selector(deleteCurrentSlide);
														label = "Delete Slide";
														imagename = "icon_slide_delete.png";
														break;
		case LLToolbarSelectThemeItemIdentifier:		target = _controller;
														action = @selector(showThemeSelectionPanel);
														label = "Theme";
														imagename = "icon_slide_theme.png";
														break;
		case LLToolbarNewTextWidgetItemIdentifier:		target = _controller;
														action = @selector(newTextWidget);
														label = "Text";
														imagename = "icon_widget_text.png";
														break;
		case LLToolbarNewPictureWidgetItemIdentifier:	target = _controller;
														action = @selector(showPictureURLPanel);
														label = "Photo";
														imagename = "icon_widget_picture.png";
														break;
		case LLToolbarNewMovieWidgetItemIdentifier:		target = _controller;
														action = @selector(showMovieURLPanel);
														label = "Video";
														imagename = "icon_widget_movie.png";
														break;
		case LLToolbarNewWebWidgetItemIdentifier:		target = _controller;
														action = @selector(showWebURLPanel);
														label = "Website";
														imagename = "icon_widget_web.png";
														break;
		case LLToolbarOtherWidgetItemIdentifier:		target = _controller;
														action = @selector(newQuizWidget);
														label = "Quiz";
														imagename = "icon_widget_other.png";
														break;
		case LLToolbarFileboxItemIdentifier:			target = _controller;
														action = @selector(showFileboxPanel);
														label = "Filebox";
														imagename = "icon_filebox.png";
														break;
		case LLToolbarSearchboxItemIdentifier:			target = _controller;
														action = @selector(showMediaPanel);
														label = "Searchbox";
														imagename = "icon_searchbox.png";
														break;
		case LLToolbarWidgetFrontIdentifier:			target = _editorView;
														action = @selector(sendSelectedWidgetToFront);
														label = "Front";
														imagename = "icon_send_widget_to_front.png";
														break;
		case LLToolbarWidgetBackIdentifier:				target = _editorView;
														action = @selector(sendSelectedWidgetToBack);
														label = "Back";
														imagename = "icon_send_widget_to_back.png";
														break;
		case LLToolbarInspectorItemIdentifier:			target = _controller;
														action = @selector(showInspectorPanel);
														label = "Inspector";
														imagename = "icon_inspector.png";
														break;
		case LLToolbarPreviewItemIdentifier:			target = self;
														action = @selector(beginPreview);
														label = "Preview";
														imagename = "icon_present.png";
														break;
	}
	
	//	Set up the item
	var image = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:imagename] size:CGSizeMake(32,32)];
	[toolbarItem setImage:image];
	[toolbarItem setTarget:target];
	[toolbarItem setAction:action];
	[toolbarItem setLabel:label];
	[toolbarItem setMinSize:CGSizeMake(32,32)];
	[toolbarItem setMaxSize:CGSizeMake(32,32)];
	
	return toolbarItem;
}

-(void)beginPreview
{
	if(!_previewView)
	{
		_previewWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
	    var previewContent = [_previewWindow contentView];
		_previewView = [[CCSlideView alloc] initWithFrame:[previewContent bounds]];
		[_previewView setAutoresizingMask:	CPViewWidthSizable |
											CPViewHeightSizable];
		[previewContent addSubview:_previewView];
		[_previewView setDelegate:[LLPreviewEventHandler new]];
		[_previewView setIsPresenting:YES];
		[_previewWindow makeFirstResponder:_previewView];
		[[CPNotificationCenter defaultCenter] addObserver:[_previewView slideLayer] selector:@selector(resize) name:@"CPViewFrameDidChangeNotification" object:nil];
	}
	else
	{
		[_previewView setHidden:NO];
	}
	
	//	Hide all of the media panels
	[[LLFileboxPanel sharedPanel] close];
	[[LLInspectorPanel sharedPanel] close];
	[[MKMediaPanel sharedMediaPanel] close];
	
	[_controller setMainSlideView:_previewView];
	[_previewView setSlide:[_controller currentSlide]];
	[_previewWindow makeKeyAndOrderFront:self];
	[_editorView resignFirstResponder];
	[_previewView becomeFirstResponder];
	[CPMenu setMenuBarVisible:NO];
}

-(void)endPreview
{
	[_controller setMainSlideView:_editorView];
	[_editorView setSlide:[_controller currentSlide]];
	[_mainWindow makeKeyAndOrderFront:self];
	[_previewView resignFirstResponder];
	[_editorView becomeFirstResponder];
	[_previewView setHidden:YES];
	//	
	var widgetLayers = [[_previewView slideLayer] widgetLayers];
	for(var i = 0 ; i < [widgetLayers count] ; i++)
	{
		if([widgetLayers[i] class] == [CCMovieWidgetLayer class])
			[widgetLayers[i] forceRedraw];
	}
	[CPMenu setMenuBarVisible:YES];
}

@end
