/*
 * Created by Scott Rice
 * Copyright 2010, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
//@import <AppKit/CPDOMWindowBridge.j>
@import "CCEvent.j"
@import "CCSlideLayer.j"

CPWebsitesPboardType = "CPWebsitesPboardType"

function CCCallDelegateMethodWithObject(delegate,selector,object)
{
	if([delegate respondsToSelector:selector])
		[delegate performSelector:selector withObject:object];
}

function CCCallDelegateMethodWithTwoObjects(delegate,selector,object1,object2)
{
	if([delegate respondsToSelector:selector])
		[delegate performSelector:selector withObject:object1 withObject:object2];
}



@implementation CCSlideView : CPView
{
	CCSlideLayer _slideLayer @accessors(readonly,property=slideLayer);
	CALayer _firstResponder;
	CALayer _receiverLayer;
	BOOL _isPresenting @accessors(readonly,property=isPresenting);
	BOOL _moving;
	id _delegate @accessors(property=delegate);
}

-(id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{ 
		[self setWantsLayer:YES];
		var rootLayer = [CALayer layer];
		[rootLayer setBounds:CGRectMake(0,0,frame.size.width,frame.size.height)];
		[rootLayer setAnchorPoint:CGPointMakeZero()];
		[rootLayer setPosition:CGPointMakeZero()];
		[self setLayer:rootLayer];
		_slideLayer = [CCSlideLayer layer];
		[rootLayer addSublayer:_slideLayer];
		[_slideLayer resize];
		[self setBackgroundColor:[CPColor grayColor]];
		[self registerForDraggedTypes:[CPImagesPboardType,CPVideosPboardType,CPWebsitesPboardType]];
    }
    return self;
}

-(void)acceptsFirstResponder
{
	return YES;
}

-(void)resignFirstResponder
{
	if([_firstResponder respondsToSelector:@selector(resignFirstResponder)])
		[_firstResponder resignFirstResponder];
	_firstResponder = nil;
	_receiverLayer = nil;
}

//	----------------------------------------------------
//				  SlideLayer Forwarding
//	----------------------------------------------------

-(CCSlide)slide
{
	return [_slideLayer slide];
}

-(void)setSlide:(CCSlide)slide
{
	[_slideLayer setSlide:slide];
	[_slideLayer setIsPresenting:_isPresenting];
}

-(void)setNeedsDisplay:(BOOL)flag
{
	if(flag)
	{
		[super setNeedsDisplay:flag];
		[[self layer] setNeedsDisplay];
	}
}

-(BOOL)isThumbnail
{
	return [_slideLayer isThumbnail];
}

-(void)setIsThumbnail:(BOOL)isThumbnail
{
	[_slideLayer setIsThumbnail:isThumbnail];
}

-(void)setIsPresenting:(BOOL)isPresenting
{
	if(isPresenting == _isPresenting)
		return;
	
	_isPresenting = isPresenting;
	
	[_slideLayer setIsPresenting:isPresenting];
	[self setBackgroundColor:((isPresenting) ? [CPColor blackColor] : [CPColor whiteColor])];
}

-(void)performDragOperation:(CPDraggingInfo)info
{
	var type = [[[info draggingPasteboard] types] lastObject],
		data = [[info draggingPasteboard] dataForType:type],
		obj = [CPKeyedUnarchiver unarchiveObjectWithData:data][0];
	var	wid;
	if(type == CPImagesPboardType)
	{
		wid = [[CCPictureWidget alloc] initWithPathToImage:[obj filename]];
		[wid setSize:CGRectMake(0,0,((obj._size.width > 1024) ? 1024 : obj._size.width ),((obj._size.height > 768) ? 768 : obj._size.height))];
	}
	else if(type == CPVideosPboardType)
	{
		wid = [[CCMovieWidget alloc] initWithMovie:obj];
		[wid setSize:CGRectMake(0,0,720,480)];
	}
	else //	type == CPWebsitesPboardType
	{
		wid = [[CCWebWidget alloc] initWithURL:obj];
		[wid setSize:CGRectMake(0,0,720,480)];
	}
	//	Set the center of the content to be the mouse point
	var point = [self convertPointFromWindowToSlideLayer:[info draggingLocation]];
	point.x -= ([wid size].size.width / 2);
	point.y -= ([wid size].size.height / 2);
	var farthestRight = 1024 - [wid size].size.width,
		farthestDown = 768 - [wid size].size.height;
	point.x = ((point.x < 0) ? 0 : ((point.x > farthestRight) ? farthestRight : point.x));
	point.y = ((point.y < 0) ? 0 : ((point.y > farthestDown) ? farthestDown : point.y));
	[wid setLocation:point];
	[_slideLayer addWidgetToSlide:wid];
}

-(void)setFirstResponder:(CCWidgetLayer)firstResponder
{
	[_firstResponder resignFirstResponder];
	_firstResponder = firstResponder;
	_receiverLayer = firstResponder;
	[_firstResponder becomeFirstResponder];
}

-(void)sendSelectedWidgetToBack
{
	[_slideLayer sendWidgetLayerToBack:_firstResponder];
}

-(void)sendSelectedWidgetToFront
{
	[_slideLayer sendWidgetLayerToFront:_firstResponder];
}

//	----------------------------------------------------
//					Point Conversion
//	----------------------------------------------------

//
//	Converts a point from the windows coordinate system to the slide layers coordinate system
//
-(CGPoint)convertPointFromWindowToSlideLayer:(CGPoint)point
{
	return [self convertPointToSlideLayer:[self convertPoint:point fromView:nil]];
}

//
//	Converts a point from the views coordinate system to the slide layers coordinate system
//
-(CGPoint)convertPointToSlideLayer:(CGPoint)point
{
	return [[self layer] convertPoint:point toLayer:_slideLayer];
}

//	----------------------------------------------------
//						Events							
//	----------------------------------------------------
	
//
//	Mouse Events
//

-(void)mouseDown:(CPEvent)event {
	var betterEvent = [CCEvent eventWithBaseEvent:event convertedPoint:[self convertPointFromWindowToSlideLayer:[event locationInWindow]]],
			oldFirst = _firstResponder,
			slidePoint = [self convertPointFromWindowToSlideLayer:[event locationInWindow]];
	//	We need to draw a distinction between the receiver layer and the first responder here
	//	The first responder should always be the widget layer, the receiver should be whatever receive the mouse events,
	//	whereas the first responder should receive the key events
	//	This is important when we think about the editing controls. If you click on an editing control, the widget layer
	//	will be the first responder, but the control will receive all the mouse events
	_firstResponder = [_slideLayer widgetAtPoint:[self convertPointFromWindowToSlideLayer:[event locationInWindow]]];
	_receiverLayer = [_slideLayer widgetOrEditingControlAtPoint:[self convertPointFromWindowToSlideLayer:[event locationInWindow]]];
	if(_isPresenting)
	{
		//[[CPPlatformWindow primaryPlatformWindow] _propagateCurrentDOMEvent:YES];
		
		//	This is here so that mouse events can be sort of smart
		//	We want it so that the delegate only receives a message if we think the user isn't interacting with a widget
		//	We will define 'interacting with a widget' as "clicked on a widget", but we may need to change this as time goes on
		if(_firstResponder == nil)
		{
			CCCallDelegateMethodWithObject(_delegate,@selector(slideView:mouseClickedAtPoint:),self,[betterEvent slideLayerPoint]);
		}
		else
		{
			[_firstResponder mouseDown:betterEvent];
		}
		return;
	}
	//	Get rid of the old first responder
	if(oldFirst != _firstResponder)
	{
		if ([oldFirst respondsToSelector:@selector(resignFirstResponder)])
			[oldFirst resignFirstResponder];
		if ([_firstResponder respondsToSelector:@selector(becomeFirstResponder)])
			[_firstResponder becomeFirstResponder];
	}
	//	The editing control doesnt care about this "editing mode" bullshit, so I just send it a straight up message
	if([_receiverLayer class] == [CCWidgetEditingControl class])
		[_receiverLayer mouseDown:betterEvent];
	else
	{
		if([_receiverLayer supportsEditingMode])
		{
			//	If we are editing, we just forward on the mouse event
			//	If we arent editing:
			//		If we have 1 click we do nothing special
			//		If we have 2 clicks then we begin editing mode (though
			//		we send n-1 clicks, so this shows up as a regular click
			//		in editing mode to the layer)
			if([_receiverLayer isEditing])
				[_receiverLayer mouseDown:betterEvent];
			else
			{
				if(![_receiverLayer isEditing] && [betterEvent clickCount] > 1)
				{
					[_receiverLayer beginEditing];
					betterEvent._clickCount = betterEvent._clickCount -1;
					[_receiverLayer mouseDown:betterEvent];
				}
				else
				{
					[_receiverLayer _mouseDown:betterEvent];
				}
			}
		}
		else
			[_receiverLayer _mouseDown:betterEvent];
	}
}

-(void)mouseDragged:(CPEvent)event {
	var betterEvent = [CCEvent eventWithBaseEvent:event convertedPoint:[self convertPointFromWindowToSlideLayer:[event locationInWindow]]]
	if(_isPresenting)
	{
		[_firstResponder mouseDragged:betterEvent];
		return;
	}
	if([_receiverLayer class] == [CCWidgetEditingControl class])
		[_receiverLayer mouseDragged:betterEvent];
	else
	{
		if([_receiverLayer isEditing])
			[_receiverLayer mouseDragged:betterEvent];
		else
			[_receiverLayer moveLayerWithEvent:betterEvent];
	}
}

-(void)mouseUp:(CPEvent)event {
	var betterEvent = [CCEvent eventWithBaseEvent:event convertedPoint:[self convertPointFromWindowToSlideLayer:[event locationInWindow]]];
	if(_isPresenting)
	{
		[_firstResponder mouseUp:betterEvent];
		return;
	}
	if([_receiverLayer class] == [CCWidgetEditingControl class])
		[_receiverLayer mouseUp:betterEvent];
	else
	{
		if([_receiverLayer isEditing])
			[_receiverLayer mouseUp:betterEvent];
		else
			[_receiverLayer movingFinished];
	}
}

-(void)mouseMoved:(CPEvent)event
{
	var betterEvent = [CCEvent eventWithBaseEvent:event convertedPoint:[self convertPointFromWindowToSlideLayer:[event locationInWindow]]];
	if(_isPresenting)
	{
		[_firstResponder mouseMoved:betterEvent];
		return;
	}
}

//
//	Key Events
//
-(void)keyDown:(CPEvent)event {
	var character = [event charactersIgnoringModifiers];
	if(_isPresenting)
	{
		switch(character)
		{
			case CPEscapeFunctionKey:		CCCallDelegateMethodWithObject(_delegate,@selector(slideViewDidPressEscapeKey:),self);
			break;
			case CPRightArrowFunctionKey:	CCCallDelegateMethodWithObject(_delegate,@selector(slideViewDidPressRightArrowKey:),self);
			break;
			case CPLeftArrowFunctionKey:	CCCallDelegateMethodWithObject(_delegate,@selector(slideViewDidPressLeftArrowKey:),self);
			break;
			default:						CCCallDelegateMethodWithTwoObjects(_delegate,@selector(slideView:didPressKey:),self,character);
			break;
		}
		return;
	}
	if(_firstResponder)
	{
		//	If the widget is in editing mode, then the key events should go to the widget layer.
		//	If it isnt in editing mode / doesnt support it, it should take care of the default cases
		//	(aka, letting you hit the delete key to delete the widget)
		if([_firstResponder supportsEditingMode])
		{
		    if([_firstResponder isEditing])
			{
				[_firstResponder keyDown:event];
				return;
			}
		}
		switch([event charactersIgnoringModifiers])
		{
			case CPDeleteCharacter:	
			case CPDeleteFunctionKey:	[_firstResponder resignFirstResponder];
										[_slideLayer deleteWidget:_firstResponder];
										_firstResponder = nil;
										break;
		}
	}
}

-(void)keyUp:(CPEvent)event {
	if(_isPresenting)
	{
		return;
	}
	if(_firstResponder)
	{
		if ([_firstResponder isEditing])
		    [_firstResponder keyUp:event];
	}	
}


@end