@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "../LLSharedUtilities/LLSlideCollectionItem.j"

@implementation LLSlidePickerController : CPViewController
{
	CPCollectionView _collection;
}

-(void)loadView
{
	var view = [[CPView alloc] initWithFrame:CGRectMake(0,0,215,200)],
		sv = [[CPScrollView alloc] initWithFrame:CGRectMake(0,0,215,200)];
	[view setAutoresizingMask:CPViewHeightSizable];
	[sv setHasHorizontalScroller:NO];
	[sv setHasVerticalScroller:YES];
	_collection = [[CPCollectionView alloc] initWithFrame:CGRectMake(0,0,200,200)];
	[_collection setAutoresizingMask:CPViewHeightSizable];
	[_collection setMinItemSize:CGSizeMake(200,200)];
	[_collection setMaxItemSize:CGSizeMake(200,200)];
	var itemPrototype = [[CPCollectionViewItem alloc] init],
		collectionView = [[LLSlideCollectionItem alloc] initWithFrame:CGRectMake(0,0,200,200)];
	[itemPrototype setView:collectionView];
	[_collection setItemPrototype:itemPrototype];
	[_collection setDelegate:self];
	[_collection setContent:[[LLPresentationController sharedController] allSlides]];
	[sv setDocumentView:_collection];
	[self setView:sv];
	
	[[CPNotificationCenter defaultCenter]  addObserver:self selector:@selector(currentSlideChanged) name:LLCurrentSlideDidChangeNotification object:nil];
}

-(void)currentSlideChanged
{
	[_collection setSelectionIndexes:[CPIndexSet indexSetWithIndex:[[LLPresentationController sharedController] currentSlideIndex]]];
}

-(void)collectionViewDidChangeSelection:(CPCollectionView)collection
{
	var currentIndex = [[collection selectionIndexes] firstIndex];
	[[LLPresentationController sharedController] setCurrentSlideIndex:currentIndex];
	[[LLRTE sharedInstance] sendSlideAction:kLLRTEActionMoveToSlide withArguments:[currentIndex]];
}

@end