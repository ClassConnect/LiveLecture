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
	CPMutableArray _slides @accessors(readonly, property=slides);
	CPMutableArray _transitions @accessors(readonly, property=transitions);
	CPString _name @accessors(property=projectName);
}

-(id)init {
	if([super init]) {
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
	//	Since the themes are the same throughout the entire presentation, I can just grab the first theme and return that
	return [_slides[0] theme];
}

-(void)setTheme:(CCSlideTheme)theme
{
	[_slides makeObjectsPerformSelector:@selector(setTheme:) withObject:theme];
}

@end

@implementation CCPresentation (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super init])
	{
		_slides = [coder decodeObjectForKey:@"slides"];
		_transitions = [coder decodeObjectForKey:@"transitions"];
		_name = [coder decodeObjectForKey:@"name"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{	
	[coder encodeObject:_slides forKey:@"slides"];
	[coder encodeObject:_transitions forKey:@"transitions"];
	[coder encodeObject:_name forKey:@"name"];
}

@end