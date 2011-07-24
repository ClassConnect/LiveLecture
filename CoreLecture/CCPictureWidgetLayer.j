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

-(void)imageDidLoad:(CPImage)image
{
	[self setNeedsDisplay];
}

-(void)imageDidError:(CPImage)image
{
	if(window.TNGrowlCenter)
	{
		[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:@"Error loading image" message:@"There was an error loading the image at '"+[_image filename]+"'" icon:TNGrowlIconError]
	}
}

-(void)drawWhileEditing:(CGContext)context {
	//	When the image is nil or when the load isnt completed, show the gray
	if([_image loadStatus] == CPImageLoadStatusCompleted)
	{
		CGContextDrawImage(context,[self bounds],_image);
	}
	else
	{
		CGContextSetFillColor(context,[CPColor grayColor]);
		CGContextSetStrokeColor(context,[CPColor blackColor]);
		CGContextFillRect(context,[self bounds]);
	}
}

-(void)drawWhilePresenting:(CGContext)context
{
	[self drawWhileEditing:context];
}

-(void)setWidget:(CCWidget)widget {
	[super setWidget:widget];
	_image = [[CPImage alloc] initWithContentsOfFile:[_widget imagePath]];
	[_image setDelegate:self];
	[self setNeedsDisplay];
}

@end