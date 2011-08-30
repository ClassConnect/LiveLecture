@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CCSlideView (LLSidebarAdditions)

// -(void)mouseMoved:(CPEvent)event
// {
//  var p = [self convertPoint:[event locationInWindow] fromView:nil],
//      c = [LLPresentationController sharedController]
//  if(![c showsSidebar] && p.x < 44)
//  {
//      [c setShowsSidebar:YES animated:YES];
//      return;
//  }
//  if([c showsSidebar] && ![c sidebarIsLocked] && p.x > 100)
//  {
//      [c setShowsSidebar:NO animated:YES];
//      return;
//  }
// }

@end