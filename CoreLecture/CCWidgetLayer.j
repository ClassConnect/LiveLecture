/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCEvent.j"
@import "CCWidget.j"
@import "CCWidgetEditingControl.j"

_CCWidgetLayerHighestZ = 1;

var kMinimumWidgetSize = 15;

@implementation CCWidgetLayer : CALayer {
	//	I have to put this property here JUST BECAUSE OF THE TEXTLAYER! AJKLDFJS
	CPInteger _widgetIndex @accessors(property=widgetIndex);
	CCWidget _widget @accessors(property=widget);
	CPArray _controls;
	CGPoint mouseDownPoint;
	BOOL _moving;
	BOOL _isEditing;
	BOOL _isFirstResponder;
	BOOL _isThumbnail @accessors(property=isThumbnail);
	BOOL _isPresenting @accessors(readonly,property=isPresenting);
	
	id _delegate @accessors(property=delegate);
}

+(CCWidgetLayer)widgetLayerForWidget:(CCWidget)widget
{
	return [[[[widget class] layerClass] alloc] initWithWidget:widget];
}

-(id)initWithWidget:(CCWidget)widget
{
	if(self = [self init])
	{
		[self setWidget:widget];
	}
	return self;
}

-(id)init
{
	self = [super init];
	if(!self) 
		return nil;
	
	[self setAnchorPoint:CGPointMakeZero()];
	_controls = [CPArray array];
	
	return self;
}

-(void)slideThemeDidChangeToTheme:(CCSlideTheme)theme
{
	//	Do nothing
}

-(void)layerDidMoveToSuperlayer
{
	[self removeControls];
	[self addControls];
}

-(void)setWidget:(CCWidget)widget
{
	if(_widget == widget)
		return;
	
	_widget = widget;
	
	[self setPosition:[_widget location]];
	[self setBounds:[_widget size]];
	[self setZPosition:[_widget zIndex]];
	
	[self setNeedsDisplay];
}

-(void)setIsThumbnail:(BOOL)isThumbnail
{
	if(isThumbnail == _isThumbnail)
		return;
	_isThumbnail = isThumbnail;
	//	If its a thumbnail, dont show controls
	[self setShowsControls:!isThumbnail];
}

-(void)setIsPresenting:(BOOL)isPresenting
{
	if(isPresenting == _isPresenting)
		return;
	
	_isPresenting = isPresenting;
	
	[self setShowsControls:!isPresenting];
}

-(void)moveLayerWithEvent:(CCEvent)event
{
	var position = [event slideLayerPoint];
	var sb = [[self superlayer] bounds];
    var b = [self bounds];
	position.x -= mouseDownPoint.x;
	position.y -= mouseDownPoint.y;
	
	//	Set the boundaries
	position.x = ((position.x < 0) ? 0 : position.x);
	position.y = ((position.y < 0) ? 0 : position.y);
	position.x = ((position.x > (sb.size.width - b.size.width)) ? (sb.size.width - b.size.width) : position.x);
	position.y = ((position.y > (sb.size.height - b.size.height)) ? (sb.size.height - b.size.height) : position.y);
	
	//	Set the final information
	[self setPosition:position];
	[_widget setLocation:position];
}

-(void)movingFinished
{
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

//	
//	Responder Events
//	

//	This method is called on mouseDown when the user is not in editing mode. I figure it would be important to have a different method
//	for editing mode vs regular mode.
-(void)_mouseDown:(CCEvent)event
{
	++_CCWidgetLayerHighestZ;
	[self setZPosition:_CCWidgetLayerHighestZ];
	[_widget setZIndex:_CCWidgetLayerHighestZ];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
	mouseDownPoint = [self convertPoint:[event slideLayerPoint] fromLayer:[self superlayer]];
	[self setNeedsDisplay];
}

-(void)mouseDown:(CCEvent)event 
{
	//	Just here so that I dont have to check to see if subclasses implement this
}

-(void)mouseDragged:(CCEvent)event 
{
	//	Same as above
}

-(void)mouseUp:(CCEvent)event
{
//	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

-(void)mouseMoved:(CCEvent)event
{
	//	Same as mouseDown
}

-(void)keyDown:(CPEvent)event
{
	//	Do nothing
}

-(void)keyUp:(CPEvent)event
{
	// var character = [event charactersIgnoringModifiers];
	// switch(character)
	// {
	// 	case CPDeleteCharacter:	[_delegate deleteWidget:_widget];
	// 							[[LLPresentationController sharedController] mainSlideContentDidChange];
	// 							break;
	// 	//	More cases
	// }
}

//	
//	First Responder Functions
//	

-(void)becomeFirstResponder
{
	if(_isFirstResponder && [self class] != [TextLayer class])
		return;
	_isFirstResponder = YES;
	[self setShowsControls:YES];
	if(!_isPresenting)
		[[LLInspectorPanel sharedPanel] setContentViewForWidget:_widget correspondingLayer:self];
}

-(void)resignFirstResponder
{
	if(!_isFirstResponder && [self class] != [TextLayer class])
		return;
	_isFirstResponder = NO;
	[self setShowsControls:NO];
	[self endEditing];
	[[LLInspectorPanel sharedPanel] setContentViewForWidget:nil correspondingLayer:nil];
}

//
//	Editing Control Helper Functions
//

-(CCWidgetEditingControl)editingControlAtPoint:(CPPoint)point
{
	//	If we arent the first responder, we shouldnt be showing editing controls, so just return
	if(!_isFirstResponder)
		return nil;
	var ret = nil;
	for(var i = 0 ; i < [_controls count] ; i++)
	{
		var c = [_controls objectAtIndex:i];
		//	The Z Position of the squares is greater than the sides, and more often than not that is the one we want
		if([c containsPoint:[self convertPoint:point toLayer:c]] && (!ret || c._zPosition > ret._zPosition))
			ret = c;
	}
	return ret;
}

-(void)editingControlDidBeginEditing:(CCWidgetEditingControl)control
{
	//	Do nothing
}

-(void)editingControl:(CCWidgetEditingControl)control didOffsetByPoint:(CGPoint)offset
{
	var pos = CGPointMakeCopy([self position]),
		bounds = CGRectMakeCopy([self bounds]);
	//	X Direction
	if([control resizingMask] & CCWidgetEditingControlSizableLeft)
	{
		if(pos.x + offset.x < 0)
		{
			pos.x = 0;
		}
		else
		{
			if(bounds.size.width - offset.x > kMinimumWidgetSize)
			{
				pos.x += offset.x;
				bounds.size.width -= offset.x;
			}
		}
	}
	else if([control resizingMask] & CCWidgetEditingControlSizableRight)
	{
		if((pos.x + (bounds.size.width + offset.x) <= 1024) && bounds.size.width + offset.x > kMinimumWidgetSize)
			bounds.size.width += offset.x;
	}
	//	Y Direction
	if([control resizingMask] & CCWidgetEditingControlSizableTop)
	{
		if(pos.y + offset.y < 0)
		{
			pos.y = 0;
		}
		else
		{
			if(bounds.size.height - offset.y > kMinimumWidgetSize)
			{
				pos.y += offset.y;
				bounds.size.height -= offset.y;
			} 
		}
	}
	else if([control resizingMask] & CCWidgetEditingControlSizableBottom)
	{
		if((pos.y + (bounds.size.height + offset.y) <= 768) && bounds.size.height + offset.y > kMinimumWidgetSize)
			bounds.size.height += offset.y;
	}
	if(bounds.size.width > 15)
	//	Update the layer and the widget
	[self setPosition:pos];
	[_widget setLocation:pos];
	[self setBounds:bounds];
	[_widget setSize:bounds];
	
	[self removeControls];
	[self addControls];
	//	Make sure that the editing controls are still there afterwards
	[self setShowsControls:_isFirstResponder];
	[self setNeedsDisplay];
}

-(void)editingControlDidFinishEditing:(CCWidgetEditingControl)control
{
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

-(void)addControls
{
	if(_isThumbnail)
	{
		return;
	}
	var w,
			h,
			boundsWidth = CGRectGetWidth([self bounds]),
			boundsHeight = CGRectGetHeight([self bounds]),
			scale = [[self superlayer] affineTransform].a;
	//	
	//	Make the lines
	//	
	w = kCCWidgetEditingControlLineSize / scale;
	h = kCCWidgetEditingControlLineSize / scale;
	//		Vertical
	[self addControlWithMask:CCWidgetEditingControlMovable
					  bounds:CGRectMake(0,0,w,boundsHeight)
					position:CGPointMake(0,0)];
	[self addControlWithMask:CCWidgetEditingControlMovable
					  bounds:CGRectMake(0,0,w,boundsHeight)
					position:CGPointMake(boundsWidth - w,0)];
	//		Horizontal
	[self addControlWithMask:CCWidgetEditingControlMovable
					  bounds:CGRectMake(0,0,boundsWidth,h)
					position:CGPointMake(0,0)];
	[self addControlWithMask:CCWidgetEditingControlMovable
					  bounds:CGRectMake(0,0,boundsWidth,h)
					position:CGPointMake(0,boundsHeight - h)];
	//
	//	Make the squares
	//
	w = kCCWidgetEditingControlSquareSize / scale;
	h = kCCWidgetEditingControlSquareSize / scale;
	//	Goes clockwise starting at top middle (12 o'clock)
	var masks =[ CCWidgetEditingControlSizableTop,
				 CCWidgetEditingControlSizableTop | CCWidgetEditingControlSizableRight,
				 CCWidgetEditingControlSizableRight,
				 CCWidgetEditingControlSizableRight | CCWidgetEditingControlSizableBottom,
				 CCWidgetEditingControlSizableBottom,
				 CCWidgetEditingControlSizableBottom | CCWidgetEditingControlSizableLeft,
				 CCWidgetEditingControlSizableLeft,
				 CCWidgetEditingControlSizableLeft | CCWidgetEditingControlSizableTop];
	for(var i = 0 ; i < [masks count] ; i++)
	{
		[self addControlWithMask:[masks objectAtIndex:i]
						  bounds:CGRectMake(0,0,w,h)
						position:[CCWidgetEditingControl controlPositionForResizingMask:[masks objectAtIndex:i] inBounds:[self bounds] withScale:scale]];
	}
	if(!_isFirstResponder)
	{
		[self setShowsControls:NO];
	}
}

-(void)addControlWithMask:(unsigned)mask bounds:(CGRect)bounds position:(CGPoint)position
{
	var current = [[CCWidgetEditingControl alloc] initWithWidgetLayer:self];
	[current setResizingMask:mask];
	[current setBounds:bounds];
	[current setPosition:position];
	[self addSublayer:current];
	[current setNeedsDisplay];
	[_controls addObject:current];
}

-(void)removeControls
{
	[_controls makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	[_controls removeAllObjects];
}

-(void)setShowsControls:(BOOL)showsControls
{
	[_controls makeObjectsPerformSelector:@selector(setHidden:) withObject:!showsControls];
}

//
//	Different methods called while the widget is in different states. That way you don't have to manually check yourselves
//

-(void)drawInContext:(CGContext)context
{
	if(_isPresenting)
	{
		[self drawWhilePresenting:context];
		return;
	}
	if(_isThumbnail)
		[self drawThumbnail:context];
	else
		[self drawWhileEditing:context];
}

-(void)drawWhilePresenting:(CGContext)context
{
	
}

-(void)drawThumbnail:(CGContext)context
{
	
}

-(void)drawWhileEditing:(CGContext)context
{
	
}

//	
//	Editing Helper Methods
//	

-(BOOL)supportsEditingMode
{
	return NO;
}

-(BOOL)isEditing
{
	return _isEditing;
}

-(void)beginEditing
{
	if(![self supportsEditingMode])
		return;
	_isEditing = YES;
}

-(void)endEditing
{
	if(![self supportsEditingMode])
		return;
	_isEditing = NO;
}

-(void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
}

@end