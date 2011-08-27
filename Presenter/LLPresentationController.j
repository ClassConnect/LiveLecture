/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CPPropertyAnimation.j"
@import "LLSidebarController.j"

var __LLPRESENTATION_SHARED__ = nil;

LLCurrentSlideDidChangeNotification = "LLCurrentSlideDidChangeNotification"

@implementation LLPresentationController : CPObject {
	CPInteger _llid @accessors(property=livelectureID);
	CPInteger _classID @accessors(property=classID);
	BOOL _isFile @accessors(property=isFile);
	CCPresentation presentation @accessors(property=presentation);
	BOOL _showsSidebar @accessors(property=showsSidebar);
	
	int _currentSlideIndex @accessors(property=currentSlideIndex);

	LLSidebarController sidebarController @accessors;
	CCSlideView mainSlideView @accessors;
	
	//	To make sure that when the user hits the stop button they don't
	//	get asked if they want to stop the livelecture before leaving
	BOOL _stopped @accessors(property=stopped);
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
	if(_currentSlideIndex == currentSlideIndex || currentSlideIndex < 0)
		return;
	_currentSlideIndex = currentSlideIndex;
	[mainSlideView setSlide:[self currentSlide]];
	[[CPNotificationCenter defaultCenter] postNotificationName:LLCurrentSlideDidChangeNotification object:nil];
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

-(void)toggleSidebar
{
	[self setShowsSidebar:!_showsSidebar animated:YES];
}

-(void)setShowsSidebar:(BOOL)showsSidebar animated:(BOOL)animated
{
	if(showsSidebar == _showsSidebar)
		return;
	
	_showsSidebar = showsSidebar;
	
	//	View animations
	var sidebar = [sidebarController view],
		mainFrame = [[[CPApplication sharedApplication] delegate]._contentView frame],
		width = mainFrame.size.width,
		height = mainFrame.size.height,
		sidebarSize = 215,
		sidebarVisibleSidebarFrame = CGRectMake(0,0,sidebarSize,height),
		sidebarHiddenSidebarFrame = CGRectMake(-sidebarSize,0,sidebarSize,height),
		sidebarVisibleSlideViewFrame = CGRectMake(sidebarSize,0,width-sidebarSize,height),
		sidebarHiddenSlideViewFrame = CGRectMake(0,0,width,height);
		// oldSidebarFrame = ((_showsSidebar) ? CGRectMake(0-sbf.size.width,0,sbf.size.width,height) : CGRectMake(0,0,sbf.size.width,height)),
		// oldSlideViewFrame = ((_showsSidebar) ? CGRectMake(0,0,svf.size.width,height) : CGRectMake(sbf.size.width,0,svf.size.width,height)),
		// newSidebarFrame = ((_showsSidebar) ? CGRectMake(0,0,sbf.size.width,height) : CGRectMake(0-sbf.size.width,0,sbf.size.width,height)),
		// newSlideViewFrame = ((_showsSidebar) ? CGRectMake(sbf.size.width,0,svf.size.width - sbf.size.width,height) : CGRectMake(0,0,svf.size.width+sbf.size.width,height));
		
	if(NO/*animated*/)
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
		// [sidebar setFrame:newSidebarFrame];
		// [mainSlideView setFrame:newSlideViewFrame];
		[sidebar setFrame:(_showsSidebar ? sidebarVisibleSidebarFrame : sidebarHiddenSidebarFrame)];
		[mainSlideView setFrame:(_showsSidebar ? sidebarVisibleSlideViewFrame : sidebarHiddenSlideViewFrame)];
		[[mainSlideView slideLayer] reposition];
	}
	[[[[CPApplication sharedApplication] delegate] sidebarButton] setImage:(_showsSidebar ? SIDEBAR_ICON_OPEN : SIDEBAR_ICON_CLOSE)];
}

-(BOOL)sidebarIsLocked
{
	return [sidebarController sidebarIsLocked];
}

-(void)stopHostingLiveLecture
{
	//	Ask the user if they are sure they want to leave
	if(confirm("Are you sure you want to stop hosting this LiveLecture?"))
	{
		[[LLPresentationController sharedController] setStopped:YES];
		window.location = ("/app/livelecture/stophosting.php?llid="+_llid);
	}
}

@end