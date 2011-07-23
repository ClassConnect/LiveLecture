@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLInspectorPanel.j"

@implementation CCWidgetInspectorContentView : CPView
{
	CCWidget _widget @accessors(property=widget);
	CCWidgetLayer _layer @accessors(property=layer);
}

+(CGSize)contentSize
{
	return CGSizeMake(250,300);
}

-(id)init
{
	if(self = [super init])
	{
		var size = [[self class] contentSize];
		[self setFrame:CGRectMake(0,0,size.width,size.height)];
		[self setAutoresizingMask:	CPViewMinXMargin   |
									CPViewMaxXMargin   |
									CPViewMinYMargin   |
									CPViewMaxYMargin   |
									CPViewWidthSizable |
									CPViewHeightSizable];
		[self createView];
	}
	return self;
}

-(void)createView
{
	var label = [CPTextField labelWithTitle:@"No Options Avaliable"];
	var csize = [[self class] contentSize];
	var lframe = [label frame];
//	[label setFrame:CGRectMake((csize.width - lframe.size.width) / 2, (csize.height - lframe.size.height) / 2,lframe.size.width,lframe.size.height)];
	[label setCenter:[self center]];
	[label setAutoresizingMask:	CPViewMinXMargin   |
								CPViewMaxXMargin   |
								CPViewWidthSizable |
								CPViewHeightSizable];
	[label setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
	[self addSubview:label];
}

-(void)widgetWillChange
{
	//	Do nothing
	[self updateWidget];
	[self updateLayer];
}

-(void)widgetDidChange
{
	//	Do nothing
}

-(void)updateWidget
{
	
}

-(void)updateLayer
{

}

@end