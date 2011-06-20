/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 *
 *	Main overarching class that handles the communication 
 *	between different parts of the application, when appropriate.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "CPPropertyAnimation.j"
@import "LLSidebarController.j"

var __LLPRESENTATION_SHARED__ = nil;

@implementation LLPresentationController : CPObject {
	CPInteger _llid @accessors(property=livelectureID);
	CPInteger _classID @accessors(property=classID);
	BOOL _isFile @accessors(property=isFile);
	CCPresentation presentation @accessors(property=presentation);
	BOOL _showsSidebar @accessors(property=showsSidebar);
	
	int _currentSlideIndex @accessors(property=currentSlideIndex);

	LLSidebarController sidebarController @accessors;
	CCSlideView mainSlideView @accessors;
}

+(id)sharedController {
	if(__LLPRESENTATION_SHARED__ == nil) {
		__LLPRESENTATION_SHARED__ = [[LLPresentationController alloc] init];
	}
	return __LLPRESENTATION_SHARED__;
}

-(id)init {
	if(self = [super init]) {
		presentation = [[CCPresentation alloc] init];
	}
	return self;
}

-(void)newSlide {
	var slide = [[CCSlide alloc] init];
	[[presentation slides] addObject:slide];
	[self setCurrentSlideIndex:[self numberOfSlides]-1];
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
	return [[presentation slides] indexOfObject:slide];
}

-(CPArray)allSlides {
	return [presentation slides];
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

-(void)moveToNextSlide
{
	if([self numberOfSlides] != [self currentSlideIndex]+1)
	{
		[self setCurrentSlideIndex:[self currentSlideIndex]+1];
	}
}

-(void)moveToPreviousSlide
{
	if([self currentSlideIndex])
	{
		[self setCurrentSlideIndex:[self currentSlideIndex]-1];
	}
	
}

//	----------------------------
//	Sidebar
//	----------------------------

-(void)setShowsSidebar:(BOOL)showsSidebar animated:(BOOL)animated
{
	if(showsSidebar == _showsSidebar)
		return;
	
	_showsSidebar = showsSidebar;
	
	//	View animations
	var sidebar = [sidebarController view],
		sbf = [sidebar frame],
		svf = [mainSlideView frame],
		height = sbf.size.height,
		oldSidebarFrame = ((_showsSidebar) ? CGRectMake(0-sbf.size.width,0,sbf.size.width,height) : CGRectMake(0,0,sbf.size.width,height)),
		oldSlideViewFrame = ((_showsSidebar) ? CGRectMake(0,0,svf.size.width,height) : CGRectMake(sbf.size.width,0,svf.size.width,height)),
		newSidebarFrame = ((_showsSidebar) ? CGRectMake(0,0,sbf.size.width,height) : CGRectMake(0-sbf.size.width,0,sbf.size.width,height)),
		newSlideViewFrame = ((_showsSidebar) ? CGRectMake(sbf.size.width,0,svf.size.width - sbf.size.width,height) : CGRectMake(0,0,svf.size.width+sbf.size.width,height));
		
	if(animated)
	{
		var sidebaranimation = [[CPPropertyAnimation alloc] initWithView:sidebar],
			slideviewanimation = [[CPPropertyAnimation alloc] initWithView:mainSlideView];
		[sidebaranimation setDuration:.5];
		[slideviewanimation setDuration:.5];
		[slideviewanimation setDelegate:sidebarController];
		[sidebaranimation addProperty:"frame" start:oldSidebarFrame end:newSidebarFrame];
		[slideviewanimation addProperty:"frame" start:oldSlideViewFrame end:newSlideViewFrame];
		[sidebaranimation startAnimation];
		[slideviewanimation startAnimation];
	}
	else
	{
		[sidebar setFrame:newSidebarFrame];
		[mainSlideView setFrame:newSlideViewFrame];
	}
	
	// if(showsSidebar)
	// {
	// 	[sidebaranimation addProperty:"frame"
	// 	 				  		start:CGRectMake(0-sbf.size.width,0,sbf.size.width,height) 
	// 							  end:CGRectMake(0,0,sbf.size.width,height)];
	// 	[slideviewanimation addProperty:"frame"
	// 							  start:CGRectMake(0,0,svf.size.width,height)
	// 								end:CGRectMake(sbf.size.width,0,svf.size.width - sbf.size.width,height)];
	// }
	// else
	// {
	// 	[sidebaranimation addProperty:"frame"
	// 	 				  		start:CGRectMake(0,0,sbf.size.width,height)
	// 							  end:CGRectMake(0-sbf.size.width,0,sbf.size.width,height) ];
	// 	[slideviewanimation addProperty:"frame"
	// 							  start:CGRectMake(sbf.size.width,0,svf.size.width,height)
	// 								end:CGRectMake(0,0,svf.size.width+sbf.size.width,height)];
	// }
}

-(BOOL)sidebarIsLocked
{
	return [sidebarController sidebarIsLocked];
}

@end