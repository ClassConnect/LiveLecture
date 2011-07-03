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
	
	BOOL _isDirty;
	//	This variable is here because normally when the bounds are set
	//	I want to redraw the video, but when it is being reset very often
	//	(aka when resizing), I want it to just show a gray box instead,
	//	and only draw the video when it is done.
	BOOL _resizing;
}

-(id)init {
	if(self = [super init])
	{
		_contentElement = document.createElement("div");
		_contentElement.style.width = "100%";
		_contentElement.style.height = "100%";
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
		//	We don't want the gray to draw EVERY TIME that drawInContext
		//	is called, only when the youtube video is loading, which
		//	happens to be when it is either dirty or resizing
		if(_isDirty || _resizing)
		{
			CGContextSetFillColor(context,[CPColor grayColor]);
			CGContextSetStrokeColor(context,[CPColor whiteColor]);
			CGContextFillRect(context,[self bounds]);
			CGContextStrokeRect(context,[self bounds]);
		}
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
}

-(void)setWidget:(CCMovieWidget)widget {
	var oldYID = [_widget youtubeID];
	[super setWidget:widget];
	_isDirty = !(oldYID == [_widget youtubeID]);
	[self setNeedsDisplay];
}

-(void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	if(!_resizing)
		_isDirty = YES;
	[self setNeedsDisplay];
}

-(void)editingControlDidBeginEditing:(CCWidgetEditingControl)control
{
	_resizing = YES;
	_contentElement.innerHTML = "";
	[super editingControlDidBeginEditing:control];
}

-(void)editingControlDidFinishEditing:(CCWidgetEditingControl)control
{
	_resizing = NO;
	_isDirty = YES;
	[self setNeedsDisplay];
	[super editingControlDidFinishEditing:control];
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