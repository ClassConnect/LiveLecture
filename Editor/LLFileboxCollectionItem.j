@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation LLFileboxCollectionItem : CPView
{
	CPImageView _thumbnail;
	CPTextField _label;
}

-(void)setRepresentedObject:(id)object
{
	if(!_thumbnail)
	{
		//	The collection view item is 285x26
		//	The thumbnail should be 16x16, with a 5px inset
		_thumbnail = [[CPImageView alloc] initWithFrame:CGRectMake(5,5,16, 16)];
		_label = [CPTextField labelWithTitle:@"Hello"];
		[_label setFrame:CGRectMake(30,5,235,16)];
		[_label setVerticalAlignment:CPCenterTextAlignment];
		[self addSubview:_thumbnail];
		[self addSubview:_label];
		var bottomBorder = [[CPView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight([self bounds])-1,CGRectGetWidth([self bounds]),1)];
		[bottomBorder setBackgroundColor:[CPColor lightGrayColor]];
		[self addSubview:bottomBorder];
	}
	[_thumbnail setImage:[[CPImage alloc] initWithContentsOfFile:[object typeIconURL]]];
	[_label setStringValue:[object name]];
}

-(void)setSelected:(BOOL)selected
{
	[self setBackgroundColor:((selected) ? [CPColor colorWithHexString:"758DAA"] : [CPColor whiteColor])];
	[_label setTextColor:((selected) ? [CPColor whiteColor] : [CPColor blackColor])];
}

@end