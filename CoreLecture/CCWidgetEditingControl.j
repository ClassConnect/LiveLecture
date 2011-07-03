/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidgetLayer.j"

//
//	CCWidgetEditingControl sizes
//
kCCWidgetEditingControlSquareSize = 10;
kCCWidgetEditingControlLineSize = 2;

//
//	CCWidgetEditingControlSizable
//
CCWidgetEditingControlMovable		=  1;
CCWidgetEditingControlSizableLeft	=  2;
CCWidgetEditingControlSizableRight	=  4;
CCWidgetEditingControlSizableTop	=  8;
CCWidgetEditingControlSizableBottom	= 16;

var CCWidgetEditingControlOutlineWidth = .1;

@implementation CCWidgetEditingControl : CALayer {
	CCWidgetLayer _layer @accessors(property=layer);
	unsigned _resizingMask @accessors(property=resizingMask);
	CGPoint _lastPoint;
}

+(CGPoint)controlPositionForResizingMask:(unsigned)resizingMask inBounds:(CGRect)bounds withScale:(float)scale
{
	var scaledSize = kCCWidgetEditingControlSquareSize / scale,
		halfScaledSize = (scaledSize / 2);
	if(resizingMask & CCWidgetEditingControlMovable)
		return;
	var point = CGPointMakeZero();
	//	X Direction
	if(resizingMask & CCWidgetEditingControlSizableLeft)
	{
//		point.x = (0 - halfScaledSize);
		point.x = 0;
	}
	else if(resizingMask & CCWidgetEditingControlSizableRight)
	{
//		point.x = (bounds.size.width - halfScaledSize);
		point.x = bounds.size.width - scaledSize;
	}
	else //	Middle
	{
		point.x = ((bounds.size.width / 2) - halfScaledSize);
	}
	//	Y Direction
	if(resizingMask & CCWidgetEditingControlSizableTop)
	{
//		point.y = (0 - halfScaledSize);
		point.y = 0;
	}
	else if(resizingMask & CCWidgetEditingControlSizableBottom)
	{
//		point.y = (bounds.size.height - halfScaledSize);
		point.y = bounds.size.height - scaledSize;
	}
	else //	Middle
	{
		point.y = ((bounds.size.height / 2) - halfScaledSize);
	}
	return point;
}

-(id)initWithWidgetLayer:(CCWidgetLayer)layer
{
	if(self = [self init])
	{
		[self setLayer:layer];
	}
	return self;
}

-(id)init
{
	if(self = [super init])
	{
		[self setAnchorPoint:CGPointMakeZero()];
	}
	return self;
}

-(void)drawInContext:(CGContext)context
{
	CGContextSetFillColor(context,[CPColor blackColor]);
	CGContextFillRect(context,[self bounds]);
	CGContextSetFillColor(context,[CPColor whiteColor]);
	CGContextFillRect(context,CGRectInset([self bounds],CCWidgetEditingControlOutlineWidth,CCWidgetEditingControlOutlineWidth));
}

-(void)mouseDown:(CCEvent)event
{
	_lastPoint = [event slideLayerPoint];
	[_layer editingControlDidBeginEditing:self];
}

-(void)mouseDragged:(CCEvent)event
{
	var position = [event slideLayerPoint];
	if(_resizingMask & CCWidgetEditingControlMovable)
	{
		[_layer moveLayerWithEvent:event];
	}
	else
	{
		var p = CGPointMakeCopy(position);
//		p.x = ((p.x /*- _lastPoint.x*/ < 0 || p.x /*- _lastPoint.x*/ > 1024) ? 0 : p.x - _lastPoint.x);
//		p.y = ((p.y /*- _lastPoint.y*/ < 0 || p.y /*- _lastPoint.y*/ > 768) ? 0 : p.y - _lastPoint.y);
		p.x -= _lastPoint.x;
		p.y -= _lastPoint.y;
		[_layer editingControl:self didOffsetByPoint:p];
		_lastPoint = position;
	}
}

-(void)mouseUp:(CGPoint)position
{
	[_layer editingControlDidFinishEditing:self];
	_lastPoint = nil;
}

-(void)setResizingMask:(unsigned)mask
{
	if(mask == _resizingMask)
		return;
	
	_resizingMask = mask;
	
	[self setZPosition:((_resizingMask & CCWidgetEditingControlMovable) ? 999999 : 1000000)];
}

@end