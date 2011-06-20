@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLPresentationController.j"
@import "LLRTE.j"

@implementation LLPresentationEventHandler : CPObject
{
	
}

-(void)slideView:(CCSlideView)slideView mouseClickedAtPoint:(CGPoint)point
{
	if([[LLUser currentUser] hasControlPermission])
	{
//		[[LLRTE sharedInstance] sendSlideAction:kLLRTEActionNextSlide withArguments:nil];
//		[[LLPresentationController sharedController] moveToNextSlide];
	}
}

-(void)slideViewDidPressEscapeKey:(CCSlideView)slideView
{
	//	The presentor shouldn't do anything if you press the escape key
}

-(void)slideViewDidPressRightArrowKey:(CCSlideView)slideView
{
	if([[LLUser currentUser] hasControlPermission])
	{
		[[LLRTE sharedInstance] sendSlideAction:kLLRTEActionNextSlide withArguments:nil];
		[[LLPresentationController sharedController] moveToNextSlide];
	}
}

-(void)slideViewDidPressLeftArrowKey:(CCSlideView)slideView
{
	if([[LLUser currentUser] hasControlPermission])
	{
		[[LLRTE sharedInstance] sendSlideAction:kLLRTEActionPreviousSlide withArguments:nil];
		[[LLPresentationController sharedController] moveToPreviousSlide];
	}
}

-(void)slideView:(CCSlideView)slideView didPressKey:(char)key
{
	//	Dont need to do anything special
}

@end