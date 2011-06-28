@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCTokBoxView.j"

LLPresentationVideoEnabled = "LLPresentationVideoEnabled";
LLPresentationVideoDisabled = "LLPresentationVideoDisabled"

var centeredMask = CPViewMinXMargin|CPViewMinYMargin|CPViewMaxXMargin|CPViewMaxYMargin;

@implementation LLTokBoxViewController : CPViewController
{
	BOOL _videoEnabled;
	BOOL _isPublishing;
	BOOL _wantsToWatch;
	
	CPString _sessionID;
	CPString _token;
	
	//	Loading Stuff
	BOOL _loading @accessors(property=loading);
	CPProgressIndicator _activityIndicator;
	CPTextField _label;
	CPButton _streamButton;
	CPButton _stopButton;
	
	CPView _backgroundView;
	
	CCTokBoxView _tokboxview;
	
}

+(BOOL)videoEnabled
{
	return [[LLUser currentUser] videoEnabled];
}

-(id)init
{
	if(self = [super init])
	{
		_videoEnabled = [[LLUser currentUser] videoEnabled];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(videoWasEnabled:) name:LLPresentationVideoEnabled object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(videoWasDisabled:) name:LLPresentationVideoDisabled object:nil];
	}
	return self;
}

-(void)loadView
{
	var v = [[CPView alloc] initWithFrame:CGRectMake(0,0,215,234)];
	[self setView:v];
	[v setAutoresizingMask:CPViewHeightSizable];
	var center = [[self view] center];
	_activityIndicator = [[CPProgressIndicator alloc] initWithFrame:CGRectMake(0,0,64,64)];
	[_activityIndicator setAutoresizingMask:centeredMask];
	[_activityIndicator setCenter:CGPointMake(center.x,center.y - 32)];
	[_activityIndicator setAutoresizingMask:centeredMask];
	[_activityIndicator setStyle:CPProgressIndicatorSpinningStyle];
	_label = [CPTextField labelWithTitle:"Connecting..."];
	[_label setAutoresizingMask:centeredMask];
	[_label setCenter:CGPointMake(center.x,center.y+([_label bounds].size.height/2))];
	[_label setAutoresizingMask:centeredMask];
	[[self view] addSubview:_activityIndicator];
	[[self view] addSubview:_label];
	[_activityIndicator setHidden:YES];
	[_label setHidden:YES];
	[self _makeButtons];
	
	_backgroundView = [[CPView alloc] initWithFrame:CGRectMake(0,34,215,200)];
	[_backgroundView setBackgroundColor:[CPColor grayColor]];
	[[self view] addSubview:_backgroundView];
}

-(void)createStopVideoButton
{
//	var headerView = [[self view] superview]._headerView;
	
}

-(void)tokboxView
{
	if(!_tokboxview)
	{
		_tokboxview = [[CCTokBoxView alloc] initWithFrame:CGRectMake(0,34,215,200)];
		[_tokboxview setDelegate:self];
		[_tokboxview setSessionID:_sessionID];
		[_tokboxview setToken:_token];
	}
	return _tokboxview;
}

-(void)_loadSessionAndToken
{
	if(!_sessionID && !_token)
	{
		var urlstr = "/app/livelecture/init"+(([[LLUser currentUser] isTeacher]) ? "Teacher" : "Student")+".cc?lid="+[[LLPresentationController sharedController] livelectureID];
		var conn = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:urlstr]] delegate:self startImmediately:NO];
		[conn start];
	}
	else
	{
		[self connectionDidFinishLoading:nil];
	}
}

-(void)_makeButtons
{
	_streamButton = [CPButton buttonWithTitle:(([[LLUser currentUser] isTeacher]) ? "Stream Video" : "Watch Video")];
	[_streamButton setFrameOrigin:CGPointMake(5,5)];
	[_streamButton setTarget:self];
	[_streamButton setAction:@selector(startStream)];
	[_streamButton setAutoresizingMask:centeredMask];
	[_streamButton setEnabled:([[LLUser currentUser] isTeacher] || _videoEnabled)];
	
	_stopButton = [CPButton buttonWithTitle:(([[LLUser currentUser] isTeacher]) ? "Stop Stream" : "Stop Video")];
	[_stopButton setFrameOrigin:CGPointMake(215-5-CGRectGetWidth([_stopButton bounds]),5)];
	[_stopButton setTarget:self];
	[_stopButton setAction:@selector(stopStream)];
	[_stopButton setAutoresizingMask:centeredMask];
	//	Not enabled at the start, they have to push the stream button first
	[_stopButton setEnabled:NO];
	
	[[self view] addSubview:_streamButton];
	[[self view] addSubview:_stopButton];
}

-(void)startStream
{
	[_streamButton setEnabled:NO];
	[self _setLoading:YES];
	[self _loadSessionAndToken];
}

-(void)stopStream
{
	[_streamButton setEnabled:YES];
	[_stopButton setEnabled:NO];
	[[self tokboxView] disconnect];
	[[self tokboxView] removeFromSuperview];
	[_backgroundView setHidden:NO];
}

-(void)_setLoading:(BOOL)loading
{
	if(loading == _loading)
		return;
	if(loading)
	{
		[_activityIndicator setHidden:NO];
		[_label setHidden:NO];
		[_tokboxview setHidden:YES];
		[_backgroundView setHidden:YES];
	}
	else
	{
		[_activityIndicator setHidden:YES];
		[_label setHidden:YES];
		[_tokboxview setHidden:NO];
		[_backgroundView setHidden:NO];
	}
}

-(void)watchStream
{
	[[self view] addSubview:[self tokboxView]];
	[[self tokboxView] connect];
	[_stopButton setEnabled:YES];
}

//	Notifications

-(void)videoWasEnabled:(CPNotification)notification
{
	_videoEnabled = YES;
	[_streamButton setEnabled:YES];
}

-(void)videoWasDisabled:(CPNotification)notification
{
	_videoEnabled = NO;
	[_streamButton setEnabled:NO];
}

//	CPURLConnectionDelegate

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	var obj = [data objectFromJSON];
	_sessionID = obj["session"];
	_token = obj["token"];
}
	
-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
	//	We have finished loading the session and token, so add the tokbox view
	[self watchStream];
	if([[LLUser currentUser] isTeacher])
		[[LLRTE sharedInstance] sendVideoStatusMessage:YES];
}

//	CCTokBoxView Delegate

-(void)tokboxSessionConnected:(CCTokBoxView)view
{
	[self _setLoading:NO];
	if([[LLUser currentUser] isTeacher])
		[[self tokboxView] publish];
}

-(void)tokboxStreamCreated:(CCTokboxView)tokbox
{
	
}

@end