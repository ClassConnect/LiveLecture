/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/CAFlashLayer.j>
@import <AppKit/AppKit.j>
@import "CCWidgetLayer.j"

/*
 *	I WAS going to use CAFlashLayer, but there is a bug in the current version of Cappuccino, where they try to access _fileName in CPFlashMovie,
 *	as opposed to the REAL variable _filename. Stupid mistake, and one that should have been caught by any kind of quality checking. Seriously, I love
 *	Cappuccino, but sometimes they make it really hard to...
 */
@implementation CCMovieWidgetLayer : CCWidgetLayer {
	DOMElement _contentElement;
}

-(id)init {
	if(self = [super init])
	{
		_contentElement = document.createElement("div");
		_DOMElement.appendChild(_contentElement);
	}
	
	return self;
}

-(void)drawInContext:(CGContext)context
{
	if(_widget == nil)
		return;
	
	if(_isThumbnail)
	{
		CGContextSetFillColor(context, [CPColor whiteColor]);
		CGContextFillRect(context,[self bounds]); 
		CGContextSetFillColor(context, [CPColor blackColor]);
		CGContextFillRect(context, CGRectInset([self bounds], 5.0, 5.0));
	}
	else
	{
		var html = "<object width=\"100%\" height=\"100%\">";
		html 	+= "<param name=\"movie\" value=\"" + [[_widget movie] filename] +"\">";
		html	+= "<param name=\"wmode\" value=\"transparent\">";
		html	+= "<embed src=\"" + [[_widget movie] filename] + "\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"100%\" height=\"100%\"></object>";
		
		if(_contentElement.innerHTML != html)
			_contentElement.innerHTML = html;
	}
}

-(void)setWidget:(CCMovieWidget)widget {
	[super setWidget:widget];
	[self setNeedsDisplay];
}

-(void)layerDidMoveToSuperlayer {
	[super layerDidMoveToSuperlayer];
	// [fl setBounds:[self bounds]];
}

-(void)mouseDown:(CCEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseDragged:(CCEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseUp:(CCEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}

-(void)mouseMoved:(CCEvent)event
{
	[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
}


@end