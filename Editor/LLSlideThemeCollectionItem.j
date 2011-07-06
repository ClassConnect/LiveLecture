@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"

@implementation LLSlideThemeCollectionItem : CPView
{
	CPImageView _thumbnail;
	CPTextField _label;
}

-(void)setRepresentedObject:(id)object
{
	//	Assume if thumbnail isnt created that label isnt either
	if(!_thumbnail)
	{
		var fo = [self frame],
			fw = fo.size.width,
			fh = fo.size.height,
			w = fw - 10,
			x = ((fw - w) / 2),
			h = (3.0/4.0) * w,
			y = ((fh - h) / 2);
		_thumbnail = [[CPImageView alloc] initWithFrame:CGRectMake(x,y,w,h)];
		var sv = [CPShadowView shadowViewEnclosingView:_thumbnail withWeight:CPLightShadow];
		[self addSubview:sv];
		_label = [[CPTextField alloc] initWithFrame:CGRectMake(0,h+y+5,w,(fh-(h+y+10)))];
		[_label setAlignment:CPCenterTextAlignment]
		[self addSubview:_label];
	}
	[_thumbnail setImage:[[CPImage alloc] initWithContentsOfFile:[object thumbnailURL]]];
	[_label setStringValue:[object title]];
}

-(void)setSelected:(BOOL)isSelected {
	[self setBackgroundColor:(isSelected ? [CPColor colorWithHexString:"7F8DAA"] : nil)];
	[_label setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor blackColor])];
}

@end