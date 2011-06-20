/*
 * AppController.j
 * LiveLecture
 *
 * Created by Scott Rice on January 12, 2011.
 * Copyright 2011, ClassConnect All rights reserved.
 */

//	Debug
HOST = "http://ccinternal.com"
//	Production
//HOST = ""

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLPresentationController.j"
@import "LLPresentationEventHandler.j"
@import "LLRTE.j"
@import "LLUser.j"
@import "../LLSharedUtilities/LLQuizWidget.j"
@import "../LLSharedUtilities/LLQuizWidgetLayer.j"
@import "CCSlideView+LLSidebarAdditions.j"
@import "LLSidebarController.j"

@implementation AppController : CPObject {
	CPView _contentView;
	CPTextField _label;
	CPProgressIndicator _progressBar;
	CPTimer _timer;
	CPURLConnection _loadConnection;
	CPURLConnection _configConnection;
	LLPresentationController _controller;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification {
	CPLogRegister(CPLogConsole);
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];
	_contentView = contentView;
	_controller = [LLPresentationController sharedController];
	[theWindow orderFront:self];
	
	var args = [[CPApplication sharedApplication] namedArguments];
	[_contentView setBackgroundColor:[CPColor blackColor]];
	
	if([args containsKey:@"lid"] || [args containsKey:@"fid"])
	{
		var url;
		if([args containsKey:@"lid"])
		{
			var lid = [args objectForKey:@"lid"];
			[[LLPresentationController sharedController] setIsFile:YES];
			[[LLPresentationController sharedController] setLivelectureID:lid];
			url = [CPURL URLWithString:HOST + "/app/livelecture/config.cc?lid="+lid];
		}
		else
		{
			var fid = [args objectForKey:@"fid"],
				cid = [args objectForKey:@"cid"];
			[[LLPresentationController sharedController] setIsFile:YES];
			[[LLPresentationController sharedController] setLiveLectureID:lid];
			[[LLPresentationController sharedController] setClassID:cid];
			url = [CPURL URLWithString:HOST + "/app/livelecture/config.cc?fid="+fid+"&cid="+cid];
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
		
		[_configConnection start];
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
			[self showErrorMessage:"An error has occured. Please hit the back button and try to reopen LiveLecture"];
	}
	else
		[[LLUser currentUser] configureFromJSON:data];
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
		[[LLPresentationController sharedController] setShowsSidebar:NO animated:YES];
		[[LLRTE sharedInstance] notifyOfEntry];
		[[LLRTE sharedInstance] requestListOfStudents];
		window.onbeforeunload = function()
		{
			[[LLRTE sharedInstance] notifyOfExit];
			if([[LLUser currentUser] isTeacher])
			{
				var answer = confirm("Would you like to stop hosting this LiveLecture?");
				if(answer)
				{
					alert("Stop Hosting!");
				}
				else
				{
					alert("Keep it open!");
				}
			}
			return;
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
		var urlstr = HOST + "/app/livelecture/load.cc?"+(([_controller isFile]) ? "lid" : "fid")+"="+[_controller livelectureID]+(([_controller isFile]) ? "&cid="+[_controller classID] : "");
		var req = [CPURLRequest requestWithURL:[CPURL URLWithString:urlstr]];
		_loadConnection = [[CPURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
		_timer = [CPTimer scheduledTimerWithTimeInterval:.5 callback:function(){
			if([_progressBar doubleValue] < 90)
				[_progressBar incrementBy:5];
		} repeats:YES];
		[_loadConnection start];
	}
}

@end