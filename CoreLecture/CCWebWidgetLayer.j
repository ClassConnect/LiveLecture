/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidgetLayer.j"
@import "CCWebWidget.j"
@import "TextLayer.j"

var _GLOBE_ = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"widget_resource_web_globe.png"] size:CGSizeMake(128,128)];

@implementation CCWebWidgetLayer : CCWidgetLayer
{
	TextLayer _thumbnailText;
	CALayer _contentLayer;
}

-(id)init {
	self = [super init];
	if(!self)
		return nil;
	
	_widget = nil;
	_thumbnailText = [TextLayer new];
	[_thumbnailText align:TextLayerCenterAlignmentMask];
	[_thumbnailText setFontSize:24];
	_contentLayer = [CALayer layer];
	[_contentLayer setAnchorPoint:CGPointMakeZero()];
	[self addSublayer:_thumbnailText];
	[self addSublayer:_contentLayer];
	return self;
}

-(void)setWidget:(CCWidget)widget {
	if(widget == nil) {
		_DOMElement.innerHTML = "";
		return;
	}
	[super setWidget:widget];
	[_thumbnailText setStringValue:[widget URL]];
}

-(void)drawInContext:(CGContext)context {
	if(!_isPresenting)
	{
		CGContextSetFillColor(context, [CPColor whiteColor]);
		CGContextFillRect(context,[self bounds]); 
		CGContextSetFillColor(context, [CPColor blackColor]);
		CGContextFillRect(context, CGRectInset([self bounds], 5.0, 5.0));
		if([_GLOBE_ loadStatus] == CPImageLoadStatusCompleted)
		{
			CGContextDrawImage(context,CGRectMake((CGRectGetWidth([self bounds]) / 2)-64,(CGRectGetHeight([self bounds]) / 2)-10-128,128,128),_GLOBE_);
		}
		[_thumbnailText setBounds:CGRectMake(0,0,CGRectGetWidth([self bounds]), 50)];
		[_thumbnailText setPosition:CGPointMake(0,(CGRectGetHeight([self bounds]) / 2))];
		[_thumbnailText setHidden:NO];
		[_contentLayer setHidden:YES];
		return;
	}
	[_contentLayer setBounds:[self bounds]];
	
	var html = "<iframe";
	html += " src=\""+[_widget URL]+"\"";
	html += " width = \"100%\"";
	html += " height = \"100%\"";
	html += " scrolling = \"yes\"";
	html += " frameborder = \"0\"";
	html += "></iframe>";
	
	_contentLayer._DOMElement.innerHTML = html;
	[_thumbnailText setHidden:YES];
	[_contentLayer setHidden:NO];
}

-(void)setTextScale:(float)scale
{
	[_thumbnailText setTextScale:scale];
}

@end