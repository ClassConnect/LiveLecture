@import <Foundation/Foundation.j>
@import <AppKit/CPCollectionView.j>

@implementation CPCollectionView (LLMutableContent)

-(void)setContent:(id)obj forItemAtIndex:(CPInteger)index
{
	[_content replaceObjectAtIndex:index withObject:obj];
	[[_items objectAtIndex:index] setRepresentedObject:obj];
}

-(void)addItem:(CPCollectionViewItem)item
{
	[self _addItem:item atIndex:[_items count] retile:YES];
}

-(void)addItem:(CPCollectionViewItem)item atIndex:(CPInteger)index
{
	[self _addItem:item atIndex:index retile:YES];
}

/* @ignore */
-(void)_addItem:(CPCollectionViewItem)item atIndex:(CPInteger)index retile:(BOOL)retile
{
	[item setSelected:NO];
	[_content insertObject:[item representedObject] atIndex:index];
	[_items insertObject:item atIndex:index];
	[self addSubview:[item view]];
	[self setSelectionIndexes:[CPIndexSet indexSet]];
	if(retile)
	{
		[self tile];
	}
}

/* UNTESTED */
-(void)deleteSelected
{
	var indexes = [self selectionIndexes],
			index = nil;
	//	Clear the selection
	[self setSelectionIndexes:[CPIndexSet indexSet]];
	while((index = [self firstIndex]) != CPNotFound)
	{
		[self _deleteItemAtIndex:index retile:NO];
		//	Adjust the rest of the indexes so they are pointing to the one we actually want
		[indexes shiftIndexesStartingAtIndex:[indexes firstIndex] by:-1];
	}
	[self tile];
//	[self _scrollToSelection];
}

-(void)deleteItemAtIndex:(CPInteger)index
{
	[self _deleteItemAtIndex:index retile:YES];
}

/* @ignore */
-(void)_deleteItemAtIndex:(CPInteger)index retile:(BOOL)retile
{
	[[_items[index] view] removeFromSuperview];
	[_content removeObjectAtIndex:index];
	[_items removeObjectAtIndex:index];
/*
	var selection = [self selectionIndexes];
	if([selection containsIndex:index])
	{
		[selection removeIndex:index];
		[self setSelectionIndexes:selection];
	}
*/
	[self setSelectionIndexes:[CPIndexSet indexSet]];
	if(retile)
	{
		[self tile];
	}
}

@end