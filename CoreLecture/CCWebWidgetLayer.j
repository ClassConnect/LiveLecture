/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCButtonLayer.j"
@import "CCWidgetLayer.j"
@import "CCWebWidget.j"
@import "TextLayer.j"

var BORDER = 8;
var BUTTONY = 5;

//	To still load these here while the CCWebWidgetLayer class still isn't
//	defined, we make CPBundle look in the bundle for a class most likely
//	packaged with this layer, the widget class
var _GLOBE_ = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CCWebWidget class]] pathForResource:@"widget_resource_web_globe.png"] size:CGSizeMake(128,128)];
var _BACK_ARROW_ = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CCWebWidget class]] pathForResource:@"widget_resource_web_back.png"] size:CGSizeMake(24,24)];
var _FORWARD_ARROW_ = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CCWebWidget class]] pathForResource:@"widget_resource_web_forward.png"] size:CGSizeMake(24,24)];
var _NEW_TAB_ICON_ = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CCWebWidget class]] pathForResource:@"widget_resource_web_new_tab.png"] size:CGSizeMake(24,24)];

@implementation CCWebWidgetLayer : CCWidgetLayer
{
	TextLayer _thumbnailText;
	CPString _displayedURL;
	
	CALayer _contentLayer;
	CCButtonLayer _backButton;
	CCButtonLayer _forwardButton;
	CCButtonLayer _newTabButton;
	
	DOMElement _iframe;
	
	int _maxdepth;
	int _curdepth;
	BOOL _usedBack;
	BOOL _usedForward;
}

-(id)init {
	self = [super init];
	if(!self)
		return nil;
	
	_widget = nil;
	
	//	Editing Layers
	_thumbnailText = [TextLayer new];
	[_thumbnailText align:TextLayerCenterAlignmentMask];
	[_thumbnailText setFontSize:24];
	
	[self addSublayer:_thumbnailText];
	
	//	PresentingLayers
	_contentLayer = [CALayer layer];
	[_contentLayer setAnchorPoint:CGPointMakeZero()];
	
	_iframe = document.createElement('iframe');
	_iframe.style.width = "100%";
	_iframe.style.height = "100%";
	_iframe.frameBorder = 0;
	_iframe.onload = function(){
		if(![_contentLayer isHidden])
		{
			if(_usedBack)
				_curdepth--;
			else
				_curdepth++;
			if(!_usedBack && !_usedForward)
				_maxdepth = _curdepth;
			[self enableButtons];
			[self resetFlags];
		}
		else
			depth = -1;
	}
	_contentLayer._DOMElement.appendChild(_iframe);
	
	var bundle = [CPBundle bundleForClass:[self class]];
	_backButton = [CCButtonLayer buttonWithImage:_BACK_ARROW_];
	if([_BACK_ARROW_ loadStatus] != CPImageLoadStatusCompleted)
		[[CPNotificationCenter defaultCenter] addObserver:_backButton selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:_BACK_ARROW_];
	[_backButton setTarget:self];
	[_backButton setAction:@selector(back)];
	[_backButton setPosition:CGPointMake(20,BUTTONY)];
	[_backButton setBounds:CGRectMake(0,0,20,20)];
	
	_forwardButton = [CCButtonLayer buttonWithImage:_FORWARD_ARROW_];
	if([_FORWARD_ARROW_ loadStatus] != CPImageLoadStatusCompleted)
		[[CPNotificationCenter defaultCenter] addObserver:_forwardButton selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:_FORWARD_ARROW_];
	[_forwardButton setTarget:self];
	[_forwardButton setAction:@selector(forward)];
	[_forwardButton setPosition:CGPointMake(49,BUTTONY)];
	[_forwardButton setBounds:CGRectMake(0,0,20,20)];
	
	_newTabButton = [CCButtonLayer buttonWithImage:_NEW_TAB_ICON_];
	if([_NEW_TAB_ICON_ loadStatus] != CPImageLoadStatusCompleted)
		[[CPNotificationCenter defaultCenter] addObserver:_newTabButton selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:_NEW_TAB_ICON_];
	[_newTabButton setTarget:self];
	[_newTabButton setAction:@selector(newTab)];
	[_newTabButton setBounds:CGRectMake(0,0,20,20)];
	
	[self addSublayer:_contentLayer];
	[self addSublayer:_backButton];
	[self addSublayer:_forwardButton];
	[self addSublayer:_newTabButton];
	
	_editingLayers[0] = _thumbnailText;
	_presentingLayers[0] = _contentLayer;
	_presentingLayers[1] = _backButton;
	_presentingLayers[2] = _forwardButton;
	_presentingLayers[3] = _newTabButton;
	
	[_backButton setEnabled:NO];
	[_forwardButton setEnabled:NO];
	
	return self;
}

-(void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	var size = bounds.size
	[_thumbnailText setBounds:CGRectMake(0,0,size.width, 50)];
	[_thumbnailText setPosition:CGPointMake(0,(size.height / 2))];
	
	[_contentLayer setPosition:CGPointMake(BORDER,34)];
	[_contentLayer setBounds:CGRectMake(0,0,size.width-(2*BORDER),size.height-(34+BORDER))];
	
	[_newTabButton setPosition:CGPointMake(size.width-15-20,BUTTONY)]
}

-(void)setWidget:(CCWidget)widget {
	[super setWidget:widget];
	//	BUGFIX:	When one of these is hidden, setStringValue gets fucked up.
	//	So we save their states, make them both visible, then put the state
	//	back where we found it.
	var tth = [_thumbnailText isHidden];
	[_thumbnailText setHidden:NO];
	// -----
	[_thumbnailText setStringValue:[widget URL]];
	// -----
	[_thumbnailText setHidden:tth];
	
	_iframe.src = [widget URL];
}

-(void)drawWhileEditing:(CGContext)context
{
	[self drawChromeInContext:context withDrawingCallback:function(contentFrame){
		CGContextSetFillColor(context, [CPColor whiteColor]);
		CGContextFillRect(context,contentFrame); 
		CGContextSetFillColor(context, [CPColor blackColor]);
		CGContextFillRect(context, CGRectInset(contentFrame, 5.0, 5.0));
		if([_GLOBE_ loadStatus] == CPImageLoadStatusCompleted)
		{
			CGContextDrawImage(context,CGRectMake(CGRectGetMidX(contentFrame)-64,CGRectGetMidY(contentFrame)-10-128,128,128),_GLOBE_);
		}
	}];
}

-(void)drawWhilePresenting:(CGContext)context
{
	[self drawChromeInContext:context withDrawingCallback:function(contentFrame){
		CGContextSetFillColor(context,[CPColor whiteColor]);
		//	Fill the website area, so that it emulates what a web browser would show
		CGContextFillRect(context,contentFrame);
	}];
}

-(void)drawChromeInContext:(CGContext)context withDrawingCallback:(Function)callback
{
	var radius = 20,
		size = [self bounds].size;
	//	Draw the surrounding chrome
	CGContextSetFillColor(context,[CPColor colorWithHexString:"CCCCCC"])
	CGContextMoveToPoint(context,0,radius);
	CGContextAddLineToPoint(context,0,size.height);
	CGContextAddLineToPoint(context,size.width,size.height);
	CGContextAddLineToPoint(context,size.width,radius);
	CGContextAddArc(context,size.width-radius,radius,radius,0,-Math.PI/2,0);
	CGContextAddLineToPoint(context,radius,0);
	CGContextAddArc(context,radius,radius,radius,Math.PI/2,Math.PI,0);
	CGContextFillPath(context);
	
	callback(CGRectMake(BORDER,34,size.width-(2*BORDER),size.height-(34+BORDER)));
}

-(void)mouseDown:(CCEvent)event
{
	var layer = [self hitTest:[event slideLayerPoint]];
	//	Let the mouse event go to the layer farther down, which is hopefully the button
	[layer mouseDown:event];
}

-(void)setTextScale:(float)scale
{
	[_thumbnailText setTextScale:scale];
}

-(void)back
{
	_usedBack = YES;
	_iframe.contentWindow.history.back();
}

-(void)forward
{
	_usedForward = YES;
	_iframe.contentWindow.history.forward();
}

-(void)newTab
{
	window.open(_iframe.src,'_blank');
}

/*/
 *	These are the use cases that we have to deal with
 *	-	When current depth == max depth, the forward button should be disabled
 *	-	When the user is at the shallowest level (current depth == 0) the back
 *		button should not be enabled.
 *	-	When the user has clicked the back button 1 or more times
 *		(curdepth < maxdepth), the forward button should be enabled, provided 
 *		the user didn't click a link inside	the frame.
/*/
-(void)enableButtons
{
	[_backButton setEnabled:YES];
	[_forwardButton setEnabled:NO];
	//	Because of some bullshit, I have to wait till we get 3 deep till I let
	//	the user use the back button. 1 is the first page that is loaded, and
	//	for some reason at 2 the back button still sends the user out of 
	//	livelecture. So we wait till 3 to show the back button.
	if(_curdepth < 3)
		[_backButton setEnabled:NO];
	if(_curdepth < _maxdepth)
		[_forwardButton setEnabled:YES];
}

-(void)resetFlags
{
	_usedBack = NO;
	_usedForward = NO;
}

@end