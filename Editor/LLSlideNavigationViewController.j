/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CPCollectionView+LLMutableContent.j"

var LLSlideDragType = "LLSlideDragType";

@implementation LLSlideNavigationViewController : CPViewController {
	CPCollectionView collection;
}

-(id)init
{
	if(self = [super init]) {
	}
	return self;
}

-(void)loadView
{
	//	This is just an example frame. Not exactly a good example of a generic class, but whatever.
	var frame = CGRectMake(0,0,215,391);
	
	var v = [[CPView alloc] initWithFrame:frame];
	[v setAutoresizingMask:CPViewHeightSizable];
	
	[v setBackgroundColor:[CPColor colorWithHexString:"DAE1E9"]];
	
	var sv = [[CPScrollView alloc] initWithFrame:frame];
	[sv setAutoresizingMask:CPViewHeightSizable];
	[sv setHasHorizontalScroller:NO];
	[sv setHasVerticalScroller:YES];
	
	//	Same rect as the scroll view
	var cv = [[CPCollectionView alloc] initWithFrame:CGRectMake(0,0,200,391)];
	[cv setAllowsEmptySelection:NO];
	[cv setAutoresizingMask:CPViewHeightSizable];
	//	200 for the scroll view frame, 15 for the bar
	[cv setMinItemSize:CGSizeMake(200,200)];
	[cv setMaxItemSize:CGSizeMake(200,200)];
	[cv setVerticalMargin:0];
	
	var itemPrototype = [[CPCollectionViewItem alloc] init],
		//	Give the slide thumbnail an original frame, to avoid some nasty bugs later
		slideThumbnail = [[LLSlideCollectionItem alloc] initWithFrame:CGRectMake(0,0,200,200)];
		
	[itemPrototype setView:slideThumbnail];
	[cv setItemPrototype:itemPrototype];
	
	[cv setContent:[[CPArray alloc] initWithArray:[[LLPresentationController sharedController] allSlides] copyItems:YES]];
	
	[cv setDelegate:self];
	
	[sv setDocumentView:cv];
	
	collection = cv;
	
	[v addSubview:sv];
	[self setView:v];
}

-(void)reload
{
	[collection setContent:[[CPArray alloc] initWithArray:[[LLPresentationController sharedController] allSlides] copyItems:YES]];
}

-(void)moveSlideAtIndex:(CPInteger)start toIndex:(CPInteger)finish
{
	//	To 'move' a slide, I am just going to remove it from start, and add
	// it to finish. Yay!
	var item = [collection itemAtIndex:start];
	[collection deleteItemAtIndex:start];
	[collection addItem:item atIndex:finish];
	//	FUCK. THIS. SHIT. I am going through and manually setting the selection
	//	TODO: Remove this
	for(var i = 0 ; i < [[collection items] count] ; i++)
	{
		[[[collection itemAtIndex:i] view] setSlideIndex:i];
		//	TODO: Get rid of this when I know why this is happening
		[[collection itemAtIndex:i] setSelected:NO];
	}
	[collection setSelectionIndexes:[CPIndexSet indexSetWithIndex:finish]];
}

-(void)addSlide:(CCSlide)slide
{
	[self addSlide:slide atIndex:[[LLPresentationController sharedController] currentSlideIndex]];
}

-(void)addSlide:(CCSlide)slide atIndex:(CPInteger)index
{
	var item = [collection newItemForRepresentedObject:[slide copy]];
	[collection addItem:item atIndex:index];
	for(var i = 0 ; i < [[collection items] count] ; i++)
	{
		[[[collection itemAtIndex:i] view] setSlideIndex:i];
		[[collection itemAtIndex:i] setSelected:NO];
	}
	[collection setSelectionIndexes:[CPIndexSet indexSetWithIndex:[[LLPresentationController sharedController] currentSlideIndex]]];
	[collection _scrollToSelection];
}

-(void)removeSlideAtIndex:(CPInteger)index
{
	[collection deleteItemAtIndex:index];
	
	for(var i = index ; i < [[collection items] count] ; i++)
		[[[collection itemAtIndex:i] view] setSlideIndex:i];
	var controllerref = [LLPresentationController sharedController],
		numSlides = [controllerref numberOfSlides];
	[collection setSelectionIndexes:[CPIndexSet indexSetWithIndex:[controllerref currentSlideIndex]]];
	if(numSlides && [controllerref currentSlideIndex] < numSlides)
		[collection _scrollToSelection];
}

-(void)slideContentChanged
{
	var controller = [LLPresentationController sharedController],
		currentIndex = [controller currentSlideIndex];
	[collection setContent:[[controller currentSlide] copy] forItemAtIndex:currentIndex];
	[[[collection itemAtIndex:currentIndex] view] setSlideIndex:currentIndex];
}

-(void)setSelectedIndex:(int)index
{
	[collection setSelectionIndexes:[CPIndexSet indexSetWithIndex:index]];
}

-(void)setThemeForItems:(CCSlideTheme)theme
{
	for(var i = 0 ; i < [[collection content] count] ; i++)
	{
		[[[collection itemAtIndex:i] view] setTheme:theme];
	}
}

//	---------------------------------
//	CPCollectionViewDelegate Methods
//	---------------------------------

-(void)collectionViewDidChangeSelection:(CPCollectionView)collectionView
{
	//	Set the current slide as the last index in the indexset
	if([[collection selectionIndexes] lastIndex] == [[LLPresentationController sharedController] currentSlideIndex])
		return;
	[[LLPresentationController sharedController] setCurrentSlideIndex:[[collection selectionIndexes] lastIndex]];
}

-(CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
	return [LLSlideDragType];
}

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
    return [CPKeyedArchiver archivedDataWithRootObject:[indices firstIndex]];
}

-(BOOL)collectionView:(CPCollectionView)collectionView shouldDeleteItemsAtIndexes:(CPIndexSet)indices
{
	return YES;
}

@end