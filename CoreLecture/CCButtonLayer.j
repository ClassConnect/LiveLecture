@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CCEvent.j"

@implementation CCButtonLayer : CALayer
{
	CPImage _image @accessors(property=image);
	
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
	if(_enabled)
	{
		if([_image loadStatus] == CPImageLoadStatusCompleted)
			CGContextDrawImage(context,[self bounds],_image)
	}
}

@end