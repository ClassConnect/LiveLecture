/*
 * AppController.j
 * LiveLecture
 *
 * Created by Scott Rice on January 12, 2011.
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
// @import <CoreLecture/CoreLecture.j>
// @import <LiveLectureUtilities/LiveLectureUtilities.j>
@import "../CoreLecture/CoreLecture.j"
@import "../LiveLectureUtilities/LiveLectureUtilities.j"
@import "LLPresentationController.j"
@import "LLPresentationEventHandler.j"
@import "LLRTE.j"
@import "LLUser.j"
@import "EKGradientView.j"
@import "LLSidebarController.j"
@import "CCSlideView+LLSidebarAdditions.j"

//  The final word in the name represents the state of the sidebar when it uses
//  that image. So an open sidebar would use the SIDEBAR_ICON_OPEN image, which
//  would most likely have the word 'close' or something similar on it.
SIDEBAR_TAB_SIZE = CGSizeMake(44,200);
SIDEBAR_ICON_OPEN = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:self] pathForResource:"sidebar_icon_open.png"] size:SIDEBAR_TAB_SIZE];
SIDEBAR_ICON_CLOSE = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:self] pathForResource:"sidebar_icon_close.png"] size:SIDEBAR_TAB_SIZE];

@implementation AppController : CPObject {
	CPView _contentView;
	CPTextField _label;
	CPProgressIndicator _progressBar;
	CPTimer _timer;
	CPURLConnection _loadConnection;
	CPURLConnection _configConnection;
	LLPresentationController _controller;
	
	CPButton _sidebarButton @accessors(readonly,property=sidebarButton);
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification {
	CPLogRegister(CPLogConsole);
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];
	_contentView = contentView;
	_controller = [LLPresentationController sharedController];
	[theWindow makeKeyAndOrderFront:self];
	
	var args = [[CPApplication sharedApplication] namedArguments];
	[_contentView setBackgroundColor:[CPColor blackColor]];
	
	if([args containsKey:@"lid"] || [args containsKey:@"fid"])
	{
		var url;
		if([args containsKey:@"lid"])
		{
			var lid = [args objectForKey:@"lid"];
			[[LLPresentationController sharedController] setIsFile:NO];
			[[LLPresentationController sharedController] setLivelectureID:lid];
			url = [CPURL URLWithString:"/app/livelecture/config.php?lid="+lid];
		}
		else
		{
			var fid = [args objectForKey:@"fid"],
				cid = [args objectForKey:@"cid"];
			[[LLPresentationController sharedController] setIsFile:YES];
			[[LLPresentationController sharedController] setLivelectureID:fid];
			[[LLPresentationController sharedController] setClassID:cid];
			//	Setup the user with the file settings
			var user = [LLUser currentUser];
			[user setRTEEnabled:NO];
			[user setIsTeacher:YES];
			[user setVideoEnabled:NO];
			user._allowed = YES;
			url = [CPURL URLWithString:"/app/livelecture/config.php?fid="+fid+"&cid="+cid];
		}
		var req = [CPURLRequest requestWithURL:url],
			_configConnection = [[CPURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
		
		var cvc = [contentView center];
		_progressBar = [[CPProgressIndicator alloc] initWithFrame:CGRectMake(0,0,200,15)];
		[_progressBar setStyle:CPProgressIndicatorBarStyle];
		[_progressBar setCenter:CGPointMake(cvc.x,cvc.y + 7.5 + 5)];
		[_progressBar setAutoresizingMask:CPViewMinXMargin|CPViewMaxXMargin|CPViewMinYMargin|CPViewMaxYMargin];
		_label = [CPTextField labelWithTitle:"Loading LiveLecture Presentation"];
		[_label setTextColor:[CPColor whiteColor]];
		[_label setCenter:CGPointMake(cvc.x,cvc.y - ([_label frameSize].height / 2) - 5)];
		[_label setAutoresizingMask:CPViewMinXMargin|CPViewMaxXMargin|CPViewMinYMargin|CPViewMaxYMargin];
		[contentView addSubview:_progressBar];
		[contentView addSubview:_label];
		
		if(![[LLPresentationController sharedController] isFile])
			[_configConnection start];
		else
			// Just keep on going!
			[self connectionDidFinishLoading:_configConnection];
	}
	else
	{
		[self showErrorMessage:"An error has occured. Please hit the back button and try to reopen LiveLecture"];
	}
}

-(void)showErrorMessage:(CPString)message
{
	[_label removeFromSuperview];
	[_progressBar removeFromSuperview];
	var tfield = [CPTextField labelWithTitle:message];
	[tfield setTextColor:[CPColor whiteColor]];
	[tfield setCenter:[_contentView center]];
	[tfield setAutoresizingMask:CPViewMinXMargin|CPViewMinYMargin|CPViewMaxXMargin|CPViewMaxYMargin];
	[_contentView addSubview:tfield];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	if(connection == _loadConnection)
	{
		if(![data isEqual:""])
			[[LLPresentationController sharedController] setPresentation:[CPKeyedUnarchiver unarchiveObjectWithData:[CPData dataWithRawString:data]]];
		else
			[self showErrorMessage:"Your presentation could not be loaded."];
	}
	else
	{
		[[LLUser currentUser] configureFromJSON:data];
	}
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
	//	Finish setting up the UI
	if(connection == _loadConnection)
	{
		var view = [[CCSlideView alloc] initWithFrame:[_contentView bounds]],
			sidebarController = [[LLSidebarController alloc] init];
		[view setAutoresizingMask:	CPViewWidthSizable	|
			 						CPViewHeightSizable ];
		[view setDelegate:[LLPresentationEventHandler new]];
		[_controller setMainSlideView:view];
		[view setBackgroundColor:[CPColor blackColor]];
		
		//	Set the sidebar's frame
		[[sidebarController view] setFrame:CGRectMake(0-[[sidebarController view] frameSize].width,0,[[sidebarController view] frameSize].width,[_contentView frame].size.height)];
		[_contentView addSubview:[sidebarController view]];
		
		[_controller setSidebarController:sidebarController];

		[_controller setCurrentSlideIndex:0];

		[LLRTE sharedInstance];

		[view setSlide:[_controller currentSlide]];
		[view setIsPresenting:YES];

		[[CPNotificationCenter defaultCenter] addObserver:[view slideLayer] selector:@selector(resize) name:@"CPViewFrameDidChangeNotification" object:nil];
		[_contentView setPostsFrameChangedNotifications:YES];	
		
		//	[_progressBar setDoubleValue:100];
		
		[[LLPresentationController sharedController] setShowsSidebar:YES animated:NO];
		[_label removeFromSuperview];
		[_progressBar removeFromSuperview];
		[_contentView addSubview:view];
		[[_contentView window] makeFirstResponder:view];
		[[LLPresentationController sharedController] setShowsSidebar:NO animated:YES];
		
		//	Setup the arrow that will let the user click and open the sidebar
		var sidebar_tab_width = SIDEBAR_TAB_SIZE.width,
		    sidebar_tab_height = SIDEBAR_TAB_SIZE.height;
		_sidebarButton = [CPButton buttonWithTitle:""];
		[_sidebarButton setBordered:NO];
		[_sidebarButton setImage:SIDEBAR_ICON_CLOSE];
		[_sidebarButton setImagePosition:CPImageOnly];
		[_sidebarButton setTarget:_controller];
		[_sidebarButton setAction:@selector(toggleSidebar)];
		//  Initially position it in the middle of the screen vertically, but at 0px horizontally
		[_sidebarButton setFrame:CGRectMake(0,([_contentView frameSize].height-sidebar_tab_height)/2,sidebar_tab_width,sidebar_tab_height)];
		//  Make sure it stays there when the frame changes
		[_sidebarButton setAutoresizingMask:CPViewMinYMargin|CPViewMaxXMargin|CPViewMaxYMargin];
		[view addSubview:_sidebarButton];
		
		if(![[LLUser currentUser] isTeacher])
		{
			//	Student specific setup
			[[LLRTE sharedInstance] requestCurrentSlideIndex];
		}
		else
		{
			//	Do teacher specific config
			[[LLRTE sharedInstance] sendSlideAction:kLLRTEActionMoveToSlide withArguments:[0]];
		}
		window.onbeforeunload = function() {
			if(![[LLPresentationController sharedController] stopped] && [[LLUser currentUser] isTeacher] && [[LLUser currentUser] RTEEnabled] && ![[LLPresentationController sharedController] isFile])
				return "Your LiveLecture is still running. Are you sure you want to leave without stopping it?\n(To stop hosting, open the sidebar and click the x at the bottom)";
		};
	}
	else	//	Start the connection to the load the presentation 
	{
		if(![[LLUser currentUser] allowedToViewLecture])
		{
			[self showErrorMessage:"You are not allowed to view this LiveLecture"];
			return;
		}
		[_label setStringValue:"Loading LiveLecture Presentation"];
		[_progressBar setDoubleValue:10];
		var urlstr = "/app/livelecture/load.php?"+(([_controller isFile]) ? "fid" : "lid")+"="+[_controller livelectureID]+(([_controller isFile]) ? "&cid="+[_controller classID] : "");
		var req = [CPURLRequest requestWithURL:[CPURL URLWithString:urlstr]];
		_loadConnection = [[CPURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
		_timer = [CPTimer scheduledTimerWithTimeInterval:.05 callback:function(){
			if([_progressBar doubleValue] < 90)
				[_progressBar incrementBy:.5];
		} repeats:YES];
		[_loadConnection start];
	}
}

@end
