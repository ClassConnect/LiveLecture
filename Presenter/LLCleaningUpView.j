@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


@implementation LLCleaningUpView : CPView
{
	CPTextField _label;
	CPProgressIndicator _spinner;
}

-(id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame)
	{
		_spinner = [[CPProgressIndicator alloc] initWithFrame:CGRectMake(0,0,64,64)];
		_label = [CPTextField labelWithTitle:"Cleaning Up..."];
		var sfs = [_spinner frameSize],
			lfs = [_label frameSize],
			sc = [self center];
		var contentView = [[CPView alloc] initWithFrame:CGRectMake(0,0,10 + Math.max(sfs.width,lfs.width),10+sfs.height,lfs.height];
		[contentView setBackgroundColor:[CPColor colorWithHexString:"EEEEEE"]];
		[_spinner setCenter:CGPointMake(sc.x,sc.y - (sfs.height/2)-2)];
		[_label setCenter:CGPointMake(sc.x,sc.y + (lfs.height/2)+2];
		[contentView addSubview:_spinner];
		[contentView addSubview:_label];
		[contentView setCenter:[self center]];
		[self addSubview:contentView];
	}
	return self;
}

@end