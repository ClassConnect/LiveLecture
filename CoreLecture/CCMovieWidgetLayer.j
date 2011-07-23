/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/CAFlashLayer.j>
@import <AppKit/AppKit.j>
@import "CCWidgetLayer.j"

@import "swfobject.js"

CCMovieWidgetPlaybackStarted = "CCMovieWidgetPlaybackStarted"
CCMovieWidgetPlaybackPaused = "CCMovieWidgetPlaybackPaused"
CCMovieWidgetPlaybackStopped = "CCMovieWidgetPlaybackStopped"

/*/
 *	Youtube API Functions. Fuck the Youtube API, I have to do some shitty
 *	little eval workaround just to get it to work well with multiple players.
 *	How did Youtube never think that someone would want to put multiple API
 *	players on a page? How?! Fuck those guys...
/*/

var layer_to_uid_map = {};

function onYouTubePlayerReady(uid)
{
	var layer = layer_to_uid_map[uid];
	layer._player = document.getElementById(uid);
	layer._player.addEventListener("onStateChange", "(function(state){__ccmoviewidgetlayerstatechange(state,"+[layer UID]+");})");
	layer._player.addEventListener("onPlaybackQualityChange", "(function(quality){__ccmoviewidgetlayerplaybackqualitychange(quality,"+[layer UID]+");})");
	layer._player.addEventListener("onError", "(function(error){__ccmoviewidgetlayerplaybackqualitychange(error,"+[layer UID]+");})");
	[layer setNeedsDisplay];
}

function __ccmoviewidgetlayerstatechange(state,uid)
{
	var layer = layer_to_uid_map[uid];
	[layer _stateChange:state];
}

function __ccmoviewidgetlayerplaybackqualitychange(quality,uid)
{
	var layer = layer_to_uid_map[uid];
	[layer _playbackQualityChange:quality];
}

function __ccmoviewidgetlayererror(error,uid)
{
	var layer = layer_to_uid_map[uid];
	[layer _error:error];
}

var kCCMovieWidgetLayerPlayButton = nil;

/*
 *	I WAS going to use CAFlashLayer, but there is a bug in the current version of Cappuccino, where they try to access _fileName in CPFlashMovie,
 *	as opposed to the REAL variable _filename. Stupid mistake, and one that should have been caught by any kind of quality checking. Seriously, I love
 *	Cappuccino, but sometimes they make it really hard to...
 */
@implementation CCMovieWidgetLayer : CCWidgetLayer {
	DOMElement _contentElement;
	CPImage _thumbnailImage;
	
	JSObject _player;
	
	BOOL _isDirty;
	
	int _previousState;
}

+(id)initialize
{
	if([self class] != [CCMovieWidgetLayer class])
		return;
	
	var path = [[CPBundle bundleForClass:self] pathForResource:"widget_resource_movie_play.png"];
	kCCMovieWidgetLayerPlayButton = [[CPImage alloc] initWithContentsOfFile:path];
}

-(id)init {
	if(self = [super init])
	{
		_contentElement = document.createElement("div");
		_contentElement.style.width = "100%";
		_contentElement.style.height = "100%";
		_contentElement.id = [self UID];
		_DOMElement.appendChild(_contentElement);
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:kCCMovieWidgetLayerPlayButton];
	}
	
	return self;
}

-(void)drawWhileEditing:(CGContext)context
{
	if([_thumbnailImage loadStatus] != CPImageLoadStatusCompleted)
	{
		CGContextSetFillColor(context,[CPColor grayColor]);
		CGContextSetStrokeColor(context,[CPColor whiteColor]);
		CGContextFillRect(context,[self bounds]);
		CGContextStrokeRect(context,[self bounds]);
	}
	else
	{
		var bounds = [self bounds];
		CGContextDrawImage(context,bounds,_thumbnailImage);
		var playLocation = CGPointMake((bounds.size.width/2)-64,(bounds.size.height/2)-64);
		CGContextDrawImage(context,CGRectMake(playLocation.x,playLocation.y,128,128),kCCMovieWidgetLayerPlayButton);
	}
}

-(void)drawWhilePresenting:(CGContext)context
{
	if(_isDirty)
	{
		_isDirty = NO;
		var params = { allowScriptAccess: "always" },
			atts = { id: [self UID] };
		var urlparams = "";
		if(window.LLRTE && [_widget syncsVideos] && [LLRTE sharedInstance] && ![[LLUser currentUser] isTeacher])
			urlparams = "controls=0&rel=0&iv_load_policy=3&disablekb=1&showinfo=0"
		swfobject.embedSWF("http://www.youtube.com/e/"+[_widget youtubeID]+"?&enablejsapi=1&version=3&"+urlparams+"&playerapiid="+[self UID],[self UID], "100%", "100%", "8", null, null, params, atts);
		layer_to_uid_map[[self UID]] = self;
	}
}

-(void)setWidget:(CCMovieWidget)widget {
	if([_widget isEqual:widget])
		return;
	[[CPNotificationCenter defaultCenter] removeObserver:self name:CCMovieWidgetPlaybackStarted object:_widget];
	[[CPNotificationCenter defaultCenter] removeObserver:self name:CCMovieWidgetPlaybackPaused object:_widget];
	[[CPNotificationCenter defaultCenter] removeObserver:self name:CCMovieWidgetPlaybackStopped object:_widget];
	[super setWidget:widget];
	_thumbnailImage = [[CPImage alloc] initWithContentsOfFile:[_widget previewURL]];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:_thumbnailImage];
	_isDirty = YES;
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(played:) name:CCMovieWidgetPlaybackStarted object:widget];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(paused:) name:CCMovieWidgetPlaybackPaused object:widget];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(stopped:) name:CCMovieWidgetPlaybackStopped object:widget];
}

-(void)forceRedraw
{
	_contentElement.innerHTML = "";
	_isDirty = YES;
}

//	If they are presenting, and the current user is a teacher or the current
//	user isnt a teacher but we aren't syncing videos
-(void)mouseDown:(CCEvent)event
{
	if(_isPresenting && ([[LLUser currentUser] isTeacher] || (![[LLUser currentUser] isTeacher] && ![_widget syncsVideos])))
		[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseDragged:(CCEvent)event
{
	if(_isPresenting && ([[LLUser currentUser] isTeacher] || (![[LLUser currentUser] isTeacher] && ![_widget syncsVideos])))
		[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseUp:(CCEvent)event
{
	if(_isPresenting && ([[LLUser currentUser] isTeacher] || (![[LLUser currentUser] isTeacher] && ![_widget syncsVideos])))
		[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseMoved:(CCEvent)event
{
	if(_isPresenting && ([[LLUser currentUser] isTeacher] || (![[LLUser currentUser] isTeacher] && ![_widget syncsVideos])))
		[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

//	Player callback functions

-(void)_notificationFromState:(CPInteger)state
{
	var map = {1:CCMovieWidgetPlaybackStarted,2:CCMovieWidgetPlaybackPaused,0:CCMovieWidgetPlaybackStopped};
	return map[state];
}

-(void)_stateChange:(CPInteger)state
{
	var n = [self _notificationFromState:state],
		w = [self widget];
	if(state != _previousState)
	{
		if(n && [self widget])
		{
			[[CPNotificationCenter defaultCenter] postNotificationName:n object:w userInfo:{"previousState":_previousState,"currentTime":_player.getCurrentTime()}];
		}
	}
	_previousState = state;
}

-(void)_playbackQualityChange:(CPString)quality
{
	
}

-(void)_error:(CPInteger)errorCode
{
	
}

//	RTE Additions
-(void)updateAfterReceivingData:(JSObject)data
{
	switch(data.type)
	{
		case CCMovieWidgetPlaybackStarted:	_player.seekTo(data.currentTime, true);
											_player.playVideo();
											break;
		case CCMovieWidgetPlaybackPaused:	_player.pauseVideo();
											break;
		case CCMovieWidgetPlaybackStopped:	_player.stopVideo();
											break;
	}
}

-(void)played:(CPNotification)notification
{
	if(window.LLRTE != undefined && [[self widget] syncVideos])
	{
		[self sendData:{
			type:[notification name],
			currentTime:[notification userInfo].currentTime
		}];
	}
}

-(void)paused:(CPNotification)notification
{
	if(window.LLRTE != undefined && [[self widget] syncVideos])
	{
		[self sendData:{
			type:[notification name]
		}];
	}
}

-(void)stopped:(CPNotification)notification
{
	if(window.LLRTE != undefined && [[self widget] syncVideos])
	{
		[self sendData:{
			type:[notification name]
		}];
	}
}

@end