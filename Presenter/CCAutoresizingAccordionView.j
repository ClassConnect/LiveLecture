@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CPArray+CCAdditions.j"

@implementation CCAutoresizingAccordionViewItem : CPAccordionViewItem
{
	CPInteger _staticHeight @accessors(property=staticHeight);
}

-(id)initWithIdentifier:(CPString)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		_staticHeight = -1;
	}
	return self;
}

@end

@implementation CCAutoresizingAccordionView : CPAccordionView
{
	
}

-(CPInteger)_resizableItemHeight
{
	//	To calculate the size of the resizable views when it is possible to have static sizes, we need to take
	//	the content height, and subtract the height of all of the static items. After that, we divide the remaining height
	//	by the number of resizing items, and we get the content height per item
	//
	var heightOfHeaders = (([[self items] count]) * ([[self itemHeaderPrototype] frame].size.height)),
		contentSize = ([self frameSize].height - heightOfHeaders),
		expandedItems = [[self items] objectsAtIndexes:[self expandedItemIndexes]],
		numberOfResizableItems = [expandedItems count];
	for (var i = 0 ; i < [expandedItems count] ; i++)
	{
		var item = [expandedItems objectAtIndex:i];
		if([item staticHeight] != -1)
		{
			contentSize -= [item staticHeight];
			numberOfResizableItems--;
		}
	}
	if(numberOfResizableItems == 0)
		return 0;
	if(contentSize <= 0)
		return 0;
	return (contentSize / numberOfResizableItems);
}

-(void)layoutSubviews
{
	var heightOfHeaders = (([[self items] count]) * ([[self itemHeaderPrototype] frame].size.height)),
		contentSize = ([self frameSize].height - heightOfHeaders),
		expandedItems = [[self items] objectsAtIndexes:[self expandedItemIndexes]],
		newViewHeight = [self _resizableItemHeight];
	[expandedItems makeObjectsPerformFunction:function(item) {
		var v = [item view];
		[v setFrameSize:CGSizeMake([v frameSize].width,(([item staticHeight] == -1) ? newViewHeight : [item staticHeight]))];
	}];
	var y = 0,
		width = [self frameSize].width,
		headerHeight = [_itemViews[0]._headerView frame].size.height;
	[_itemViews makeObjectsPerformFunction:function(item) {
		//	I am basically calling setFrameY:width: here, but I need it to be animated, so I have to do the shit manually
		//	[item setFrameY:y width:width];
		var contentHeight = [item._contentView frame].size.height;
		[item._headerView setFrameSize:CGSizeMake(width,headerHeight)];
		[item._contentView setFrameOrigin:CGPointMake(0.0,headerHeight)];
		[item._contentView setFrameSize:CGSizeMake(width,contentHeight)];
		//	Animation Time!!!!!
		var frameAnimation = [[CPPropertyAnimation alloc] initWithView:item];
		[frameAnimation setDuration:.1];
		var endFrame = (([item isCollapsed]) ? CGRectMake(0,y,width,headerHeight) : CGRectMake(0,y,width,contentHeight + headerHeight));
		[frameAnimation addProperty:"frame" start:[item frame] end:endFrame];
		[frameAnimation startAnimation];
		y = CGRectGetMaxY(endFrame);
	}];
}

@end