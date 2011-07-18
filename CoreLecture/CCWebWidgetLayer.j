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
	CPString _displayedURL;
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

-(void)drawWhileEditing:(CGContext)context
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
}

-(void)drawWhilePresenting:(CGContext)context
{
	[_thumbnailText setHidden:YES];
	[_contentLayer setHidden:NO];
	[_contentLayer setBounds:[self bounds]];
	
	if(_displayedURL != [_widget URL])
	{
		var html = "<iframe";
		html += " src=\""+[_widget URL]+"\"";
		html += " width = \"100%\"";
		html += " height = \"100%\"";
		html += " scrolling = \"yes\"";
		html += " frameborder = \"0\"";
		html += "></iframe>";
		
		_contentLayer._DOMElement.innerHTML = html;
		_displayedURL = [_widget URL];
	}
	CGContextSetFillColor(context,[CPColor grayColor]);
	CGContextSetStrokeColor(context,[CPColor whiteColor]);
	CGContextFillRect(context,[self bounds]);
	CGContextStrokeRect(context,[self bounds]);
}

-(void)setTextScale:(float)scale
{
	[_thumbnailText setTextScale:scale];
}

@end