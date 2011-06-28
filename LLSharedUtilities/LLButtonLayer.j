@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

//
//	TODO: Everything
//

@implementation LLButtonLayer : CALayer
{
	// Data
	CPString _title;
	CPImage _image @accessors(property=image);
	
	//	Display
	TextLayer _text;
	
	//	Reponse
	id _tagert @accessors(property=target);
	SEL _action @accessors(property=action);
}

+(id)buttonWithTitle:(CPString)title
{
	return [[self alloc] initWithTitle:title];
}

+(id)buttonWithImage:(CPImage)image
{
	return [[self alloc] initWithImage:image];
}

-(id)initWithTitle:(CPString)title
{
	if(self = [self init])
	{
		[self setTitle:title];
		[self setImage:nil];
	}
	return self;
}

-(id)initWithImage:(CPImage)image
{
	if(self = [self init])
	{
		[self setTitle:""];
		[self setImage:image];
	}
	return self;
}

-(id)init
{
	if(self = [super init])
	{
		_text = [TextLayer layer];
		[_text setAnchorPoint:CGPointMakeZero()];
		[self addSublayer:_text];
	}
	return self;
}

-(void)setTitle:(CPString)title
{
	if([title isEqual:_title])
		return;
	
	_title = title;
	
	[_text setStringValue:title];
}

-(void)setImage:(CPImage)image
{
	if([image isEqual:_image])
		return;
	
	_image = image;
	
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidLoad:) name:CPImageDidLoadNotification object:_image];
	[self setNeedsDisplay];
}

-(void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	//	Make the answer text grow with the button
	[_text setBounds:bounds];
}

-(void)mouseDown:(CCEvent)event
{
	
}

-(void)imageDidLoad:(CPNotification)notification
{
	[self setNeedsDisplay];
}

@end