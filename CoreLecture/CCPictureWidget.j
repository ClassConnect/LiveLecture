/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidget.j"

@implementation CCPictureWidget : CCWidget {
	CPString _imagePath @accessors(property=imagePath);
}

-(id)initWithWidget:(CCPictureWidget)widget
{
	if(self = [self init])
	{
		[self setImagePath:[[widget imagePath] copy]];
	}
	return self;
}

-(id)initWithPathToImage:(CPString)imagePath {
	self = [super init];
	if(!self)
		return;
	
	[self setImagePath:imagePath];
	
	return self;
}

-(BOOL)isEqual:(CCPictureWidget)rhs
{
	return	[super isEqual:rhs] &&
					[_imagePath isEqual:[rhs imagePath]];
}

-(id)copy
{
	return [[CCPictureWidget alloc] initWithWidget:self];
}

@end

@implementation CCPictureWidget (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super initWithCoder:coder])
	{
		_imagePath = [coder decodeObjectForKey:@"imagePath"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{	
	[super encodeWithCoder:coder];
	[coder encodeObject:_imagePath forKey:@"imagePath"];
}

@end