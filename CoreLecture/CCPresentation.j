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
@import "CCSlide.j"
@import "CCSlideTheme.j"

@implementation CCPresentation : CPObject {
	CCSlideTheme _theme @accessors(property=theme);
	CPMutableArray _slides @accessors(readonly, property=slides);
	
	//	Not Yet Used
	CPMutableArray _transitions @accessors(readonly, property=transitions);
}

-(id)init {
	if([super init]) {
		_theme = [CCSlideTheme defaultTheme];
		_slides = [[CPMutableArray alloc] init];
		_transitions = [[CPMutableArray alloc] init];
	}
	return self;
}

-(void)addSlide:(CCSlide)slide
{
	[_slides addObject:slide];
}

-(CCSlideTheme)theme
{
	if(_theme)
		return _theme;
	else
	{
		if(_slides[0] && _slides[0]._theme)
			return _slides[0]._theme
		else
			return [CCSlideTheme defaultTheme];
	}
}

-(void)setTheme:(CCSlideTheme)theme
{
	if([_theme isEqual:theme])
		return;
	_theme = theme;
	[_slides makeObjectsPerformSelector:@selector(setTheme:) withObject:_theme];
}

@end

@implementation CCPresentation (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super init])
	{
		_slides = [coder decodeObjectForKey:@"slides"];
		_transitions = [coder decodeObjectForKey:@"transitions"];
		_theme = [coder decodeObjectForKey:@"theme"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{	
	[coder encodeObject:_slides forKey:@"slides"];
	[coder encodeObject:_transitions forKey:@"transitions"];
	[coder encodeObject:_theme forKey:@"theme"];
}

@end