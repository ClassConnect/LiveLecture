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
	CPButton _button;
	
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
	var v = [[CPView alloc] initWithFrame:CGRectMake(0,0,200,200)];
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
}

-(void)tokboxView
{
	if(!_tokboxview)
	{
		_tokboxview = [[CCTokBoxView alloc] initWithFrame:[[self view] bounds]];
		[_tokboxview setDelegate:self];
		[_tokboxview setSessionID:_sessionID];
		[_tokboxview setToken:_token];
		CPLog("Session ID: "+_sessionID+" Token: "+_token);
	}
	return _tokboxview;
}

-(void)_loadSessionAndToken
{
	var urlstr = "/app/livelecture/init"+(([[LLUser currentUser] isTeacher]) ? "Teacher" : "Student")+".cc?lid="+[[LLPresentationController sharedController] livelectureID];
	var conn = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:urlstr]] delegate:self startImmediately:NO];
	[conn start];
}

-(void)_makeButtons
{
	_button = [CPButton buttonWithTitle:(([[LLUser currentUser] isTeacher]) ? "Stream Video" : "Watch Video")];
	[_button setCenter:[[self view] center]];
	[_button setTarget:self];
	[_button setAction:@selector(startStream)];
	[_button setAutoresizingMask:centeredMask];
	[_button setEnabled:([[LLUser currentUser] isTeacher] || _videoEnabled)];
	[[self view] addSubview:_button];
}

-(void)startStream
{
	[_button setHidden:YES];
	[self _setLoading:YES];
	[self _loadSessionAndToken];
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
	}
	else
	{
		[_activityIndicator setHidden:YES];
		[_label setHidden:YES];
		[_tokboxview setHidden:NO];
	}
}

-(void)watchStream
{
	[[self view] addSubview:[self tokboxView]];
	[[self tokboxView] connect];
}

//	Notifications

-(void)videoWasEnabled:(CPNotification)notification
{
	_videoEnabled = YES;
	[_button setEnabled:YES];
}

-(void)videoWasDisabled:(CPNotification)notification
{
	_videoEnabled = NO;
	[_button setEnabled:NO];
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
	[[LLRTE sharedInstance] sendVideoStatusMessage:YES];
}

//	CCTokBoxView Delegate

-(void)tokboxSessionConnected:(CCTokBoxView)view
{
	[_activityIndicator setHidden:YES];
	[_label setHidden:YES];
	if([[LLUser currentUser] isTeacher])
		[[self tokboxView] publish];
}

@end