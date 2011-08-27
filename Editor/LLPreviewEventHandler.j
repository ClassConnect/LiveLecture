@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "LLPresentationController.j"

@implementation LLPreviewEventHandler : CPObject
{
	
}

-(void)slideView:(CCSlideView)slideView mouseClickedAtPoint:(CGPoint)point
{
	
}

-(void)slideViewDidPressEscapeKey:(CCSlideView)slideView
{
	[[[CPApplication sharedApplication] delegate] endPreview];
}

-(void)slideViewDidPressRightArrowKey:(CCSlideView)slideView
{
	if([[LLPresentationController sharedController] currentSlideIndex] == [[LLPresentationController sharedController] numberOfSlides]-1)
	{
		[[[LLPresentationController sharedController] mainSlideView] showPresentationFinishedView];
	}
	else
	{
		[[LLPresentationController sharedController] moveToNextSlide];
	}
}

-(void)slideViewDidPressLeftArrowKey:(CCSlideView)slideView
{
	if(![[LLPresentationController sharedController] mainSlideView]._endOfSlideshow)
		[[LLPresentationController sharedController] moveToPreviousSlide];
	else
	{
		[[[LLPresentationController sharedController] mainSlideView] stopShowingPresentationFinishedView];
	}
}

-(void)slideView:(CCSlideView)slideView didPressKey:(char)key
{
	//	Dont need to do anything special
}

@end