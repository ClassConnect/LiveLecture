@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CPArray+CCAdditions.j"

@import "Resources/TokBox.js"

var kCCTokBoxAPIKey = "627682";

var show = function(element) {	element.style.display = "block";	};
var hide = function(element) {	element.style.display = "none"; 	};

@implementation CCTokBoxStreamView : CPView
{
	CPString _streamID;
	
	JSObject _stream;
	JSObject _session;
	
	DOMElement _contentElement;
}

-(id)_initWithStreamObject:(JSObject)stream tokboxSession:(JSObject)session frame:(CGRect)frame
{
//	if(session.connection.connectionID == stream.connection.connectionID)
//		return nil;
	if(self = [super initWithFrame:frame])
	{
		_streamID = stream.streamId;
		_stream = stream;
		_contentElement = document.createElement('div');
		_contentElement.setAttribute("id", _streamID);
		_DOMElement.appendChild(_contentElement);
		_session = session;
	}
	return self;
}

-(void)viewDidMoveToSuperview
{
	_session.subscribe(_stream,_streamID,{width:[self frameSize].width,height:[self frameSize].height});
}

-(CPString)streamID
{
	return _streamID;
}

-(void)mouseDown:(CPEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseDragged:(CPEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseUp:(CPEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseMoved:(CPEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

@end

/*
	Methods the delegate should have
*/

@implementation CCTokBoxView : CPView
{
	BOOL _die;
	
	CPString _sessionID @accessors(property = sessionID);
	CPString _token @accessors(property = token);
	
	JSObject _session;
	JSObject _publisher;
	
	DOMElement _publisherDiv;
	DOMElement _publisherFlashElement;
	
	CPMutableArray _streamViews;
	CPMutableArray _streamIDs;
	
	id delegate @accessors;
}

-(id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		if (TB.checkSystemRequirements() != TB.HAS_REQUIREMENTS)
		{
			alert("You don't have the minimum requirements to run this application. Please upgrade to the latest version of Flash.");
			_die = YES;
		}
		else
		{
			_sessionID = "";
			_token = "";
			_publisherDiv = document.createElement('div');
			_DOMElement.appendChild(_publisherDiv);
			_streamViews = [];
			_streamIDs = [];
		}
	}
	return self;
}

-(void)layoutSubviews
{
/*
	if([delegate respondsToSelector:@selector(layoutStreams)])
		[delegate layoutStreams:_streamViews];
	else
	{
		//	TODO: At least make an attempt to lay it out intelligently
		if([_streamViews count])
			[[_streamViews objectAtIndex:0] setFrame:[self bounds]];
	}
*/
}

-(JSObject)_session
{
	if(_die)
		return nil;
	if(!_session)
	{
		var sess = [self sessionID];
		if(sess != "")
		{
			_session = TB.initSession(sess);
			_session.addEventListener('sessionConnected', function(event){	[self _sessionConnected:event];	});
			_session.addEventListener('sessionDisconnected', function(event){	[self _sessionDisconnected:event];	});
			_session.addEventListener('connectionCreated', function(event){	[self _connectionCreated:event];	});
			_session.addEventListener('connectionDestroyed', function(event){	[self _connectionDestroyed:event];	});
			_session.addEventListener('streamCreated', function(event){	[self _streamCreated:event];	});
			_session.addEventListener('streamDestroyed', function(event){	[self _streamDestroyed:event];	});
		}
		else
		{
			if([delegate respondsToSelector:@selector(tokbox:didFailWithError:)])
				[delegate tokbox:self didFailWithError:"No Session ID set"];
		}
	}
	return _session;
}

-(BOOL)connect
{
	if(_token)
	{
		[self _session].connect(kCCTokBoxAPIKey,_token);
		return YES;
	}
	else
		return NO;
}

-(void)disconnect
{
	if([self isPublishing])
		[self stopPublishing];
	[_streamViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	_streamViews = [ ];
	_streamIDs = [ ];
	[self _session].disconnect();
	[self _session].cleanup();
}

-(void)publish
{
	if(!_publisher)
	{
		var props = {width:[self bounds].size.width,height:[self bounds].size.height};
		if([delegate respondsToSelector:@selector(tokboxViewWillStartPublishing:)])
			[delegate tokboxViewWillStartPublishing:self];
		_DOMElement.appendChild(_publisherDiv);
		_publisher = [self _session].publish(_publisherDiv.id,props);
		_publisherFlashElement = document.getElementById(_publisher.id);
		if([delegate respondsToSelector:@selector(tokboxViewDidStartPublishing:)])
			[delegate tokboxViewDidStartPublishing:self];
	}
	show(_publisherDiv);
}

-(BOOL)isPublishing
{
	return (_publisher != nil);
}

-(void)stopPublishing
{
	if(_publisher)
	{
		[self _session].unpublish(_publisher);
		if([delegate respondsToSelector:@selector(tokboxViewWillStopPublishing)])
			[delegate tokboxViewWillStopPublishing];
		_publisher = nil;
	}
	hide(_publisherDiv);
}

-(void)setSessionID:(CPString)sessionID
{
	if(sessionID == _sessionID)
		return;
	_sessionID = sessionID;
	_publisherDiv.id = "cctokboxpublisher"+sessionID;
}

/*
	@ignore
*/

-(void)mouseDown:(CPEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseDragged:(CPEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseUp:(CPEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseMoved:(CPEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)_addStreams:(CPArray)streams
{
	[streams makeObjectsPerformFunction:function(object){
		var streamview = [[CCTokBoxStreamView alloc] _initWithStreamObject:object tokboxSession:[self _session] frame:CGRectMake(0,0,[self frameSize].width,[self frameSize].height)];
		if(streamview)
		{
			[self addSubview:streamview];
			[_streamViews addObject:streamview];
			[_streamIDs addObject:object.streamId];
		}
	}];
}

-(void)_removeStreams:(CPArray)streams
{
	[streams makeObjectsPerformFunction:function(object){
		var i = [_streamIDs indexOfObject:object.streamID];
		[[_streamViews objectAtIndex:i] removeFromSuperview];
		[_streamViews removeObjectAtIndex:i];
		[_streamIDs removeObjectAtIndex:i];
	}];
	[self setNeedsLayout];
}

-(void)_sessionConnected:(JSObject)event
{
	[self _addStreams:event.streams];
	if([delegate respondsToSelector:@selector(tokboxSessionConnected:)])
		[delegate tokboxSessionConnected:self];
}

-(void)_sessionDisconnected:(JSObject)event
{
	[self _removeStreams:event.streams];
	if([delegate respondsToSelector:@selector(tokboxSessionDisconnected:)])
		[delegate tokboxSessionDisconnected:self];
}

//	Nothing should be done
-(void)_connectionCreated:(JSObject)event
{
	if([delegate respondsToSelector:@selector(tokboxConnectionConnected:)])
		[delegate tokboxConnectionConnected:self];
}

//	Nothing should be done
-(void)_connectionDestroyed:(JSObject)event
{
	if([delegate respondsToSelector:@selector(tokboxConnectionDestroyed:)])
		[delegate tokboxConnectionDestroyed:self];
}

-(void)_streamCreated:(JSObject)event
{
	[self _addStreams:event.streams];
	if([delegate respondsToSelector:@selector(tokboxStreamCreated:)])
		[delegate tokboxStreamCreated:self];
}

-(void)_streamDestroyed:(JSObject)event
{
	[self _removeStreams:event.streams];
	if([delegate respondsToSelector:@selector(tokboxStreamDestroyed:)])
		[delegate tokboxStreamDestroyed:self];
}

@end