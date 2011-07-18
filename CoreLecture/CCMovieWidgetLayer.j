/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/CAFlashLayer.j>
@import <AppKit/AppKit.j>
@import "CCWidgetLayer.j"

var kCCMovieWidgetLayerPlayButton = nil;

/*
 *	I WAS going to use CAFlashLayer, but there is a bug in the current version of Cappuccino, where they try to access _fileName in CPFlashMovie,
 *	as opposed to the REAL variable _filename. Stupid mistake, and one that should have been caught by any kind of quality checking. Seriously, I love
 *	Cappuccino, but sometimes they make it really hard to...
 */
@implementation CCMovieWidgetLayer : CCWidgetLayer {
	DOMElement _contentElement;
	CPImage _thumbnailImage;
	
	BOOL _isDirty;
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
		var html = "<object width=\"100%\" height=\"100%\">";
		html 	+= "<param name=\"movie\" value=\"" + [[_widget movie] filename] +"\">";
		html	+= "<param name=\"wmode\" value=\"transparent\">";
		html	+= "<embed src=\"" + [[_widget movie] filename] + "\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"100%\" height=\"100%\"></object>";

		_contentElement.innerHTML = html;
		
		_isDirty = NO;	
	}
}

-(void)setWidget:(CCMovieWidget)widget {
	if([_widget isEqual:widget])
		return;
	[super setWidget:widget];
	_thumbnailImage = [[CPImage alloc] initWithContentsOfFile:[_widget previewURL]];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:_thumbnailImage];
	_isDirty = YES;
}

-(void)forceRedraw
{
	_contentElement.innerHTML = "";
	_isDirty = YES;
}

-(void)mouseDown:(CCEvent)event
{
	if(_isPresenting)
		[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseDragged:(CCEvent)event
{
	if(_isPresenting)
		[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseUp:(CCEvent)event
{
	if(_isPresenting)
		[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseMoved:(CCEvent)event
{
	if(_isPresenting)
		[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

@end