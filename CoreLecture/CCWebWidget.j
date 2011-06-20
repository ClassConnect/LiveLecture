/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidget.j"

@implementation CCWebWidget : CCWidget {
	CPString _url @accessors(property=URL);
}

-(id)initWithWidget:(CCWebWidget)widget
{
	if(self = [super initWithWidget:widget])
	{
		[self setURL:[[widget URL] copy]];
	}
	return self;
}

-(id)initWithURL:(CPString)url {
	self = [self init];
	if(!self)
		return nil;
	
	[self setURL:url];

	return self;
}

-(id)init {
	self = [super init];
	if(!self)
		return nil;
	
	//	Extra intialization here

	return self;
}

-(BOOL)isEqual:(CCWebWidget)rhs
{
	return 	[super isEqual:rhs] &&
			[_url isEqual:rhs._url];
}

-(id)copy
{
	return [[CCWebWidget alloc] initWithWidget:self];
}

@end

@implementation CCWebWidget (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super initWithCoder:coder])
	{
		_url = [coder decodeObjectForKey:@"url"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{	
	[super encodeWithCoder:coder];
	[coder encodeObject:_url forKey:@"url"];
}

@end