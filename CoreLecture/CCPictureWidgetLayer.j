/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidgetLayer.j"
@import "CCPictureWidget.j"

@implementation CCPictureWidgetLayer : CCWidgetLayer {
	CPImage _image;
}

// +(void)initialize
// {
// 	if(self != [CCPictureWidgetLayer class])
// 		return;
// }

-(void)imageDidLoad:(CPImage)image {
	[self setNeedsDisplay];
}

-(void)drawInContext:(CGContext)context {
	//	When the image is nil or when the load isnt completed, show the gray
	var bounds = [self bounds];
	if([_image loadStatus] == CPImageLoadStatusCompleted)
	{
		CGContextDrawImage(context,bounds,_image);
	}
	// else
	// {
	// 	CGContextSetFillColor([CPColor grayColor]);
	// 	CGContextFillRect([self bounds]);
	// 	// CGContextSetFillColor([CPColor grayColor]);
	// 	// CGContextFillRect(CGRectInset([self bounds],1.0,1.0));
	// }
}

-(void)setWidget:(CCWidget)widget {
	[super setWidget:widget];
	_image = [[CPImage alloc] initWithContentsOfFile:[_widget imagePath]];
	[_image setDelegate:self];
}

@end