@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCEvent.j"

@implementation CCButtonLayer : CALayer
{
	CPImage _image @accessors(property=image);
	CPImage _imageForDisabled @accessors(property=imageForDisabled);
	
	id _target @accessors(property=target);
	SEL _action @accessors(property=action);
	Function _callback @accessors(property=callback);
	
	BOOL _enabled @accessors(property=enabled);
}

+(id)buttonWithImage:(CPImage)image
{
	var button = [[self alloc] init];
	[button setImage:image];
	return button;
}

-(id)init
{
	if(self = [super init])
	{
		[self setAnchorPoint:CGPointMakeZero()];
		[self setEnabled:YES];
	}
	return self;
}

-(void)setTarget:(id)target
{
	if(target == _target)
		return;
	_target = target;
	_callback = function(){};
}

-(void)setCallback:(Function)callback
{
	_callback = callback;
	_target = nil;
}

-(void)setImage:(CPImage)image
{
	if(_image == image)
		return;
	_image = image;
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:image];
}

-(void)setImageForDisabled:(CPImage)image
{
	if(_imageForDisabled == image)
		return;
	_imageForDisabled = image;
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:image];
}

-(void)mouseDown:(CCEvent)event
{
	if(_enabled)
		[CPApp sendAction:_action to:_target from:self];
}

-(void)setEnabled:(BOOL)enabled
{
	if(_enabled == enabled)
		return;
	_enabled = enabled;
	[self setNeedsDisplay];
}

-(void)drawInContext:(CGContext)context
{
	var image = [self imageForState];
	if([image loadStatus] == CPImageLoadStatusCompleted)
		CGContextDrawImage(context,[self bounds],image)
}

-(void)imageForState
{
	return _enabled ? _image : _imageForDisabled;
}

@end