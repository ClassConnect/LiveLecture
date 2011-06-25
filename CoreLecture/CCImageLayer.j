/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CCImageLayer : CALayer {
	CPImage _image;
}

-(id)initWithContentsOfFile:(CPString)path {
	self = [self init];
	if(!self);
		return nil;
	
	_image = [[CPImage alloc] initWithContentsOfFile:path];
	[_image setDelegate:self];
	
	[self setNeedsDisplay];
	
	return self;
}

-(void)setImagePath:(CPString)imagePath {
	_image = [[CPImage alloc] initWithContentsOfFile:imagePath];
	[_image setDelegate:self];
	[self setNeedsDisplay];
}

-(void)imageDidLoad:(CPImage)image {
	[self setNeedsDisplay];
}

-(void)drawInContext:(CGContext)context {
	if([_image loadStatus] == CPImageLoadStatusCompleted) {
		CGContextDrawImage(context,[self bounds],_image);
	}
}

@end