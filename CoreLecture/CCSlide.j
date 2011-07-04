/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 *
 *	An object representing a slide.
 *	The main function of this class is to be storeable in a database,
 *	and be retreivable from the database
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidget.j"
@import "CCWebWidget.j"
@import "CCTextWidget.j"
@import "CCSlideTheme.j"
@import "CCPictureWidget.j"

@implementation CCSlide : CPObject {
	CPArray _widgets @accessors(readonly,property=widgets);
	CCSlideTheme _theme @accessors(property=theme);
}

+(id)titleSlide
{
	var s = [[CCSlide alloc] init],
		w1 = [[CCTextWidget alloc] initWithString:@"Double-click to add title" alignment:TextLayerCenterAlignmentMask fontSize:48],
		w2 = [[CCTextWidget alloc] initWithString:@"Double-click to add subtitle" alignment:TextLayerCenterAlignmentMask fontSize:36];
	//	Magic numbers are taken from putting the top one right above the middle, and bottom right under the middle
	[w1 setLocation:CGPointMake(50,274)];
	[w1 setSize:CGRectMake(0,0,924,100)];
	[w2 setLocation:CGPointMake(100,394)];
	[w2 setSize:CGRectMake(0,0,824,349)];
	[s addWidget:w1];
	[s addWidget:w2];
	return s;
}

+(id)contentSlide
{
	var s = [[CCSlide alloc] init];
		w1 = [[CCTextWidget alloc] initWithString:@"Double-click to add title" alignment:TextLayerCenterAlignmentMask fontSize:48],
		w2 = [[CCTextWidget alloc] initWithString:@"Double-click to add text" alignment:TextLayerLeftAlignmentMask fontSize:24];
	//	Magic numbers are from some intense in my head calculations. Yeah!
	[w1 setLocation:CGPointMake(50,50)];
	[w1 setSize:CGRectMake(0,0,924,100)];
	[w2 setLocation:CGPointMake(50,170)];
	[w2 setSize:CGRectMake(0,0,924,548)];
	[s addWidget:w1];
	[s addWidget:w2];
	return s;
}

-(id)initWithSlide:(CCSlide)slide
{
	if(self = [self init])
	{
		[self setTheme:[[slide theme] copy]];
		_widgets = [[CPArray alloc] initWithArray:[slide widgets] copyItems:YES];
	}
	return self;
}

-(id)initWithTheme:(CCSlideTheme)theme
{
	if(self = [self init])
	{
		_theme = theme;
	}
	return self;
}

-(id)init {
	if([super init]) {
		_widgets = [CPArray array];
		_theme = [CCSlideTheme defaultTheme];
	}
	return self;
}

//	-------------------------------
//				Widgets
//	-------------------------------

-(int)numberOfWidgets
{
	return [_widgets count];
}

-(CCWidget)widgetAtIndex:(int)index
{
	return [_widgets objectAtIndex:index];
}

-(void)addWidget:(CCWidget)widget
{
	[_widgets addObject:widget];
}

-(int)indexOfWidget:(CCWidget)widget
{
	return [_widgets indexOfObject:widget];
}

-(void)deleteWidgetAtIndex:(int)index
{
	[_widgets removeObjectAtIndex:index];
}

-(void)deleteWidget:(CCWidget)widget
{
	[self deleteWidgetAtIndex:[self indexOfWidget:widget]];
}

-(void)replaceWidgetAtIndex:(int)index withWidget:(CCWidget)widget
{
	[_widgets replaceObjectAtIndex:index withObject:widget];
}

-(BOOL)isEqual:(CCSlide)rhs
{
	return 	[_theme isEqual:[rhs theme]]		&&
			[_widgets isEqual:[rhs widgets]];
}

-(id)copy
{
	return [[CCSlide alloc] initWithSlide:self];
}

@end

@implementation CCSlide (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super init])
	{
		_widgets = [coder decodeObjectForKey:@"widgets"];
		_theme = [coder decodeObjectForKey:@"theme"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{	
	[coder encodeObject:_widgets forKey:@"widgets"];
	[coder encodeObject:_theme forKey:@"theme"];
}

@end