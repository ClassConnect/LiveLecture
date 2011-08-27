@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation LLClassCollectionItem : CPView
{
	CPImageView _thumbnail;
	CPTextField _label;
	CPView _divider;
}

-(void)setRepresentedObject:(id)object
{
	//	Assume if thumbnail isnt created that label isnt either
	if(!_thumbnail)
	{
//	    [self setBackgroundColor:[CPColor colorWithCalibratedRed:Math.random() green:Math.random() blue:Math.random() alpha:1]];
		var fo = [self frame],
			fw = fo.size.width,
			fh = fo.size.height;
		
		_thumbnail = [[CPImageView alloc] initWithFrame:CGRectMake(4,4,fh-8,fh-8)];
		[_thumbnail setImageAlignment:CPImageAlignCenter];
		var sv = [CPShadowView shadowViewEnclosingView:_thumbnail withWeight:CPLightShadow];
		[self addSubview:sv];
		
		_label = [[CPTextField alloc] initWithFrame:CGRectMake([_thumbnail frameSize].width+16,4,fw-([_thumbnail frameSize].width-16),fh-8)];
		[_label setFont:[CPFont systemFontOfSize:20]];
		[_label setVerticalAlignment:CPCenterVerticalTextAlignment];
		[self addSubview:_label];
		
		_divider = [[CPView alloc] initWithFrame:CGRectMake(0,fh-1,fw,1)];
		[_divider setBackgroundColor:[CPColor blackColor]];
		[self addSubview:_divider];
	}
	[_thumbnail setImage:[[CPImage alloc] initWithContentsOfFile:[object imagePath]]];
	[_label setStringValue:[object name]];
}

-(void)setSelected:(BOOL)isSelected {
	[self setBackgroundColor:(isSelected ? [CPColor colorWithHexString:"7F8DAA"] : nil)];
	[_label setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor blackColor])];
}

@end