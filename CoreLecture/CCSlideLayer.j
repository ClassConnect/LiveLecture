/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCSlide.j"
@import "CCImageLayer.j"
@import "CCWidgetLayer.j"
@import "CCNotificationLayer.j"
//	Widgets
@import "CCPictureWidget.j"
@import "CCPictureWidgetLayer.j"
@import "CCTextWidget.j"
@import "TextLayer.j"
//@import "CCTextWidgetLayer.j"
@import "CCMovieWidget.j"
@import "CCMovieWidgetLayer.j"
@import "CCWebWidget.j"
@import "CCWebWidgetLayer.j"

@implementation CCSlideLayer : CALayer
{
	CCSlide _slide @accessors(property=slide);
	CCImageLayer _backgroundLayer;
	CPArray _widgetLayers @accessors(readonly,property=widgetLayers);
	BOOL _isThumbnail @accessors(property=isThumbnail);
	id delegate @accessors;
	float _scale @accessors(readonly,property=scale);
	BOOL _isPresenting @accessors(readonly,property=isPresenting);
}

-(id)init
{
	self = [super init];
	if(!self) 
		return nil;
		
	_widgetLayers = [CPArray array];

	[self setAnchorPoint:CGPointMakeZero()];
	[self setBounds:CGRectMake(0,0,1024,768)];
	
	_backgroundLayer = [[CCImageLayer alloc] init];
	[_backgroundLayer setAnchorPoint:CGPointMakeZero()];
	[_backgroundLayer setPosition:CGPointMakeZero()];
	[_backgroundLayer setBounds:[self bounds]];
	[self addSublayer:_backgroundLayer];
	
	return self;
}

//
//	Helper Functions
//

-(void)resize
{
	var containingFrame = [[self superlayer] bounds];
	var containingHeight = CGRectGetHeight(containingFrame);
	var containingWidth = CGRectGetWidth(containingFrame);
	var oldFrame = [self bounds];
	var newWidth,
		newHeight;
	if((containingHeight < containingWidth) && (containingWidth > ((4.0/3.0) * containingHeight)))
	{
		newHeight = containingHeight - 20;
		newWidth = (4.0/3.0) * newHeight;
	}
	else
	{
		newWidth = containingWidth - 20;
		newHeight = (3.0/4.0)*newWidth;
	}
	
	//	Scale is always the same for the width and height
	_scale = newHeight / CGRectGetHeight(oldFrame);
	if(CGRectGetHeight(oldFrame) <= 0 && CGRectGetWidth(oldFrame) <= 0)
	{
		_scale = 1;
		[self setPosition:CGPointMake((containingWidth - newWidth) / 2,(containingHeight - newHeight) / 2)];
		[self setBounds:CGRectMake(0,0,newWidth,newHeight)];
		[_backgroundLayer setBounds:[self bounds]];
	}
	else
	{
		[self setAffineTransform:CGAffineTransformMakeScale(_scale,_scale)];
		//	Redo the editing controls and take care of the text scaling
		for(var i = 0 ; i < [_widgetLayers count] ; i++) {
			var currentLayer = [_widgetLayers objectAtIndex:i];
			if([currentLayer respondsToSelector:@selector(setTextScale:)])
				[currentLayer setTextScale:_scale];
			[currentLayer removeControls];
			[currentLayer addControls];
		}
		[self setPosition:CGPointMake((containingWidth - newWidth) / 2,(containingHeight - newHeight) / 2)];
	}
	[self setNeedsDisplay];
}

-(void)reposition
{
	var newWidth = (_scale * [self bounds].size.width),
		newHeight = (_scale * [self bounds].size.height),
		containingWidth = CGRectGetWidth([[self superlayer] bounds]),
		containingHeight = CGRectGetHeight([[self superlayer] bounds]),
		newPoint = CGPointMake((containingWidth - newWidth) / 2,(containingHeight - newHeight) / 2);
	[self setPosition:newPoint];
	[self setNeedsDisplay];
}

-(void)addWidgetToSlide:(CCWidget)widget 
{
	[widget setZIndex:_CCWidgetLayerHighestZ];
	[_slide addWidget:widget];
	[self addWidgetLayerToSlide:[self configuredLayerForWidget:widget]];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

-(CCWidgetLayer)configuredLayerForWidget:(CCWidget)widget
{
	var lay = [CCWidgetLayer widgetLayerForWidget:widget];
	[lay setWidgetIndex:[_slide indexOfWidget:widget]];
	[lay slideThemeDidChangeToTheme:[_slide theme]];
	[lay setIsThumbnail:_isThumbnail];
	[lay setDelegate:self];
	return lay;
}

-(void)addWidgetLayerToSlide:(CCWidgetLayer)layer
{
	[_widgetLayers addObject:layer];
	[self addSublayer:layer];
	[layer layerDidMoveToSuperlayer];
	[layer setNeedsDisplay];
	if([layer respondsToSelector:@selector(setTextScale:)])
		[layer setTextScale:_scale];
}

-(void)widgetIsOutOfBounds:(CCWidget)widget
{
	return (([widget location].x < 0) || 
			([widget location].y < 0) || 
			([widget location].x > ([self bounds].size.width - [widget size].size.width)) || 
			([widget location].y > ([self bounds].size.height - [widget size].size.height)));
}

-(void)refreshTheme
{
	[_backgroundLayer setImagePath:[[_slide theme] backgroundPath]];
	[_widgetLayers makeObjectsPerformSelector:@selector(slideThemeDidChangeToTheme:) withObject:[_slide theme]];
}

//
//	Accessor Method Overrides
//

-(void)setSlide:(CCSlide)slide
{
	//	This may seem weird, but it gets rid of a bug with the CPCollectionView not updating. Weird as hell
	if([_slide isEqual:slide])// && !_isThumbnail)
			return;
	
	//	We are going to go through the previous slide's widget layers and see if
	//	there are any that we can reuse.
	[_widgetLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	var cached = _widgetLayers,
			widgets_to_create = [[slide widgets] copy],
			oldSlide = _slide;
	_widgetLayers = [ ];
	//	Do the actual copy before we start
	_slide = slide;
	for(var i = 0 ; i < [cached count] ; i++)
	{
		var current = cached[i];
		if([widgets_to_create containsObject:[current widget]])
		{
			[current setWidgetIndex:[slide indexOfWidget:[current widget]]];
			[self addWidgetLayerToSlide:current];
			[widgets_to_create removeObject:[current widget]];
		}
	}
	//	Now we are going to go through the new slide and make sure we didn't
	//	miss any widgets
	for(var i = 0 ; i < [widgets_to_create count] ; i++) {
		[self addWidgetLayerToSlide:[self configuredLayerForWidget:widgets_to_create[i]]];
	}
	
	if(![[oldSlide theme] isEqual:[_slide theme]])
		[self refreshTheme];
	
	//	Figure out what the current highest z index is in our widgets
	for(var i = 0 ; i < [_slide numberOfWidgets] ; i++)
	{
		var currz = [[_slide widgetAtIndex:i] zIndex];
		if(_CCWidgetLayerHighestZ < currz)
			_CCWidgetLayerHighestZ = currz;
	}
	[self setNeedsDisplay];
	[self resize];
}

-(void)setIsThumbnail:(BOOL)isThumbnail 
{
	if(_isThumbnail == isThumbnail) 
		return;
	_isThumbnail = isThumbnail;
	[_widgetLayers makeObjectsPerformSelector:@selector(setIsThumbnail:) withObject:isThumbnail];
//	for(var i = 0 ; i < [sl count] ; i++) {
//		[[sl objectAtIndex:i] setIsThumbnail:isThumbnail];
//	}
}

-(void)setIsPresenting:(BOOL)isPresenting
{
//	if(isPresenting == _isPresenting)
//		return;
	
	_isPresenting = isPresenting;
	
//	[_widgetLayers makeObjectsPerformSelector:@selector(setIsPresenting:) withObject:isPresenting];
	var count = [_widgetLayers count];
	for(var i = 0 ; i < count ; i++)
		[_widgetLayers[i] setIsPresenting:isPresenting];
}

//	Widget Layer Delegate

-(void)deleteWidget:(CCWidgetLayer)layer
{
	[_slide deleteWidget:[layer widget]];
	[_widgetLayers removeObject:layer];
	[layer removeFromSuperlayer];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

-(void)remakeSlideFromWidgetLayers
{
	var newSlide = [[CCSlide alloc] init],
		widgets = [CPArray array];
	for(var i = 0 ; i < [_widgetLayers count] ; i++)
	{
		[widgets addObject:[[_widgetLayers objectAtIndex:i] widget]];
	}
	newSlide._widgets = widgets;
	//	Force the update of the widgets
	_slide = newSlide;
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

//	HitTest Replacements
-(CCWidget)widgetAtPoint:(CPPoint)point
{
	var ret = nil;
	for(var i = 0 ; i < [_widgetLayers count] ; i++)
	{
		var wid = [_widgetLayers objectAtIndex:i];
		//	If the widget contains the point and the z position of wid is greater than the z position of ret
		//	(aka wid is on top of ret), then wid is the one we want to return over ret
		if([wid containsPoint:[self convertPoint:point toLayer:wid]] && (!ret || wid._zPosition > ret._zPosition))
			ret = wid;
	}
	return ret;
}

-(CALayer)widgetOrEditingControlAtPoint:(CPPoint)point
{
	var widget = [self widgetAtPoint:point];
	if(!widget)
		return nil;
	var control = [widget editingControlAtPoint:[self convertPoint:point toLayer:widget]];
	return ((control) ? control : widget);
}

//
//	FUCK THE TEXTLAYER
//

-(void)textDidChange:(TextLayer)textLayer
{
	var widgetIndex = [textLayer widgetIndex];
	if(![[textLayer textWidget] isEqual:[_slide widgetAtIndex:widgetIndex]])
		[_slide replaceWidgetAtIndex:widgetIndex withWidget:[textLayer textWidget]];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
	[textLayer setTextScale:textLayer._scale];
}

@end