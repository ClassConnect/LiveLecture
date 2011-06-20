/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 *
 *	Main overarching class that handles the communication 
 *	between different parts of the application, when appropriate.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "MediaKit/MediaKit.j"
@import "CCSlideView.j"
@import "CCSlideLayer.j"
@import "CCPresentation.j"
//@import "LLSlideNavigationViewController.j"

var __CCPRESENTATION_SHARED__ = nil

@implementation CCPresentationController : CPObject {
	CCPresentation presentation;
	
	int _currentSlideIndex @accessors(property=currentSlideIndex);
	
	LLSlideNavigationController navigationController @accessors;
	CCSlideLayer mainSlideView @accessors;
}

+(id)sharedController {
	if(__CCPRESENTATION_SHARED__ == nil) {
		__CCPRESENTATION_SHARED__ = [[CCPresentationController alloc] init];
	}
	return __CCPRESENTATION_SHARED__;
}

-(id)init {
	if(self = [super init]) {
		presentation = [[CCPresentation alloc] init];
		[self newSlide];
	}
	return self;
}

//	----------------------------
//	Slide Information
//	----------------------------

-(int)numberOfSlides {
	return [[presentation slides] count];
}

-(CCSlide)slideAtIndex:(int)index {
	return [[presentation slides] objectAtIndex:index];
}

-(int)indexOfSlide:(CCSlide)slide {
	[[presentation slides] indexOfObject:slide];
}

-(CPArray)allSlides {
	return [presentation slides];
}

//	----------------------------
//	Slide Management Controls
//	----------------------------

-(void)newSlide {
	var slide = [[CCSlide alloc] init];
	[[presentation slides] addObject:slide];
	[self setCurrentSlideIndex:[self numberOfSlides]-1];
	[navigationController slideContentChanged];
}

-(void)deleteCurrentSlide {
	[self deleteSlideAtIndex:_currentSlideIndex];
}

-(void)deleteSlideAtIndex:(int)index {
	[[presentation slides] removeObjectAtIndex:index];
	if((_currentSlide == [self numberOfSlides]) && [self numberOfSlides])
	{
		_currentSlide--;
	}
	//	If they got rid of the last slide, give them a new one
	if([self numberOfSlides] == 0) {
		[self newSlide:nil];
	}
	[mainSlideView setSlide:[self slideAtIndex:_currentSlide]];
	[navigationController slideContentChanged];
}

-(int)moveSlideAtIndex:(int)start toIndex:(int)finish
{
	var slides = [presentation slides];
	var slide = [slides objectAtIndex:start];
	[slides removeObjectAtIndex:start];
	[slides insertObject:slide atIndex:finish];
	_currentSlide = finish;
	[navigationController slideContentChanged];
}

//	----------------------------
//	Slide Selection
//	----------------------------

-(void)setCurrentSlideIndex:(int)currentSlideIndex {
	if(_currentSlideIndex == currentSlideIndex)
		return;
	_currentSlideIndex = currentSlideIndex;
	[mainSlideView setSlide:[self currentSlide]];
}

-(CCSlide)currentSlide
{
	return [self slideAtIndex:[self currentSlideIndex]];
}

-(void)setCurrentSlide:(CCSlide)slide
{
	[self setCurrentSlideIndex:[self indexOfSlide:slide]];
}

//	----------------------------
//	Widgets
//	----------------------------

-(void)newMediaWidget
{
	[[CPApplication sharedApplication] orderFrontMediaPanel:self];
}

@end