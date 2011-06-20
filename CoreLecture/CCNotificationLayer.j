/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 *
 *	The sole purpose of this class is provide layer hierarchy change notificaions 
 *	to CALayers similar to how they are with CPViews.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CCNotificationLayer : CALayer {
	
}

-(void)addSublayer(CALayer)layer {
	//	Tell the layer is is about to be added
	if([layer respondsToSelector:@selector(layerWillMoveToSuperlayer:)])
		[layer layerWillMoveToSuperlayer:self];
	//	Add the layer
	[super addSublayer:layer];
	//	Tell the layer it was just added
	if([layer respondsToSelector:@selector(layerDidMoveToSuperlayer)])
		[layer layerDidMoveToSuperlayer];
	//	Tell myself that I have just added a sublayer
	if([self respondsToSelector:@selector(didAddSublayer:)])
		[self didAddSublayer:layer];
}

@end