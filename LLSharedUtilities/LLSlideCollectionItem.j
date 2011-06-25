/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"

var LLSlideDragType = "LLSlideDragType";

var slideDivider = nil;

@implementation LLSlideCollectionItem : CPView
{
	CCSlideLayer _slideLayer;
	CPTextField _slideNumberLabel;
	CPInteger _slideIndex @accessors(property=slideIndex);
}

+(void)initialize
{
	if(self != [LLSlideCollectionItem class])
		return;
	
	slideDivider = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,200,5)];
	[slideDivider setBackgroundColor:[CPColor blackColor]];
}

-(void)setRepresentedObject:(id)object
{
	if(!_slideLayer) {
		[self setWantsLayer:YES];
		
		var _rootLayer = [CALayer layer];
		[_rootLayer setAnchorPoint:CGPointMakeZero()];
		[_rootLayer setPosition:CGPointMakeZero()];
		[_rootLayer setBounds:[self bounds]];
		[self setLayer:_rootLayer];
		[self setClipsToBounds:NO];
		[self registerForDraggedTypes:[LLSlideDragType]];
		
		_slideLayer = [[CCSlideLayer alloc] init];
		[_slideLayer setIsThumbnail:YES];
		[_rootLayer addSublayer:_slideLayer];
		[_slideLayer resize];
		
		_slideNumberLabel = [CPTextField labelWithTitle:"7777"];
		[_slideNumberLabel setFrameOrigin:CGPointMake(5,5)];
		[self addSubview:_slideNumberLabel];
	}
	[_slideLayer setSlide:object];
	[_slideLayer setNeedsDisplay];
	[self setSlideIndex:[[LLPresentationController sharedController] indexOfSlide:object]]
}

-(void)setSelected:(BOOL)isSelected
{
	[self setBackgroundColor:(isSelected ? [CPColor colorWithHexString:"7F8DAA"] : nil)];
	[_slideNumberLabel setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor blackColor])];
}

-(void)setTheme:(CCSlideTheme)theme
{
	// if([[[_slideLayer slide] theme] isEqual:theme])
	// 	return;
	[[_slideLayer slide] setTheme:theme];
	[_slideLayer refreshTheme];
}

-(void)setSlideIndex:(CPInteger)slideIndex
{
	if(_slideIndex == slideIndex)
		return;
	_slideIndex = slideIndex;
	[_slideNumberLabel setStringValue:""+(slideIndex+1)];
}

-(void)draggingEntered:(CPDraggingInfo)info
{
	[self draggingUpdated:info];
	[self addSubview:slideDivider];
}

-(void)draggingUpdated:(CPDraggingInfo)info
{
	var point = [self convertPoint:[info draggingLocation] fromView:nil];
	if(point.y < 100)
			[slideDivider setFrameOrigin:CGPointMake(0,-2.5)];
	else
			[slideDivider setFrameOrigin:CGPointMake(0,197.5)];
}

-(void)draggingExited:(CPDraggingInfo)info
{
	[slideDivider removeFromSuperview];
}

-(void)performDragOperation:(CPDraggingInfo)info
{
	[slideDivider removeFromSuperview];
	// Figure out where to move to
	var point = [self convertPoint:[info draggingLocation] fromView:nil],
			moveFromIndex = [CPKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:LLSlideDragType]],
			moveToIndex = ((point.y < 100) ? _slideIndex : (_slideIndex + 1));
	if(moveFromIndex == moveToIndex)
		return;
	[[LLPresentationController sharedController] moveSlideAtIndex:moveFromIndex toIndex:moveToIndex];
}

@end