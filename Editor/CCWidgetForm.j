@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CCWidgetForm : CPView
{
	CCWidget _widget @accessors(property=widget);
}

-(id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		[self setBackgroundColor:[CPColor whiteColor]];
	}
	return self
}

-(void)setWidget:(CCWidget)widget
{
	_widget = widget;
	[self updateFormForNewWidget];
}

-(void)updateFormForNewWidget
{
	//	Do nothing
}

-(void)commit
{
	//	Do nothing
}

@end