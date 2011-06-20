/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CCWidget : CPObject {
	CGPoint _location @accessors(property=location);
	CGRect _size @accessors(property=size);
	unsigned _z @accessors(property=zIndex);
}

//	Default implementation just adds "Layer" to the end of the widget class name
//	So the layer class for CCMovieWidget is CCMovieWidgetLayer
//	For now, there is an exception fro CCTextWidget, which uses TextLayer
+(Class)layerClass
{
	return CPClassFromString(CPStringFromClass(self) + "Layer");
}

-(id)initWithWidget:(CCWidget)widget
{
	if(self = [self init])
	{
		[self setLocation:CGPointMakeCopy([widget location])];
		[self setSize:CGRectMakeCopy([widget size])];
		[self setZIndex:[widget zIndex]];
	}
	return self;
}

-(id)init
{
	if(self = [super init])
	{
		[self setLocation:CGPointMakeZero()];
		[self setSize:CGRectMakeZero()];
		_z = 5;
	}
	return self;
}

//	Threw the origin checking on the size just in case. They should both be zero, but I dunno how this will look after a while...
-(BOOL)isEqual:(CCWidget)rhs
{
	return	_location.x == [rhs location].x &&
					_location.y == [rhs location].y &&
					_size.origin.x == [rhs size].origin.x &&
					_size.origin.y == [rhs size].origin.y &&
					_size.size.width == [rhs size].size.width &&
					_size.size.height == [rhs size].size.height	&&
					_z == [rhs zIndex];
}

-(id)copy
{
	return [[CCWidget alloc] initWithWidget:self];
}

@end

@implementation CCWidget (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super init])
	{
		_location = [coder decodePointForKey:@"location"];
		_size = [coder decodeRectForKey:@"size"];
		_z = [[coder decodeObjectForKey:@"zIndex"] unsignedIntValue];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{	
	[coder encodePoint:_location forKey:@"location"];
	[coder encodeRect:_size forKey:@"size"];
	[coder encodeObject:[CPNumber numberWithUnsignedInt:_z] forKey:@"zIndex"];
}

@end