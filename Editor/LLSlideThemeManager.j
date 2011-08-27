@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

var __LLSLIDETHEMEMANAGER_THEMEURL__ = "Resources/Themes/themes.json";

LLSlideThemeManagerLoadStatusStopped	= 0;
LLSlideThemeManagerLoadStatusLoading	= 1;
LLSlideThemeManagerLoadStatusCompleted	= 2;

@implementation LLSlideThemeManager : CPObject
{
	CPArray _themes @accessors(readonly,property=themes);
	
	unsigned _loadStatus @accessors(readonly,property=loadStatus);
	
	id _delegate @accessors(property=delegate);
}

-(id)init
{
	if(self = [super init])
	{
		var conn = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:__LLSLIDETHEMEMANAGER_THEMEURL__]] delegate:self];
		[conn start];
		_loadStatus = LLSlideThemeManagerLoadStatusLoading;
	}
	return self;
}

-(int)numberOfThemes
{
	return [_themes count];
}

-(CCSlideTheme)themeAtIndex:(int)index
{
	return [_themes objectAtIndex:index];
}

-(int)indexOfTheme:(CCSlideTheme)theme
{
	return [_themes indexOfObject:theme];
}

//	
//	CPURLConnectionDelegate Methods
//	

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	_loadStatus = LLSlideThemeManagerLoadStatusCompleted;
	_themes = [CPArray array];
	var jso_themes = [data objectFromJSON];
	for(var i = 0 ; i < [jso_themes count] ; i++)
	{
		[_themes addObject:[CCSlideTheme themeFromJSObject:jso_themes[i]]];
	}
	if([_delegate respondsToSelector:@selector(themeManagerDidFinishLoading:)])
		[_delegate themeManagerDidFinishLoading:self];
}

-(void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
	_loadStatus = LLSlideThemeManagerLoadStatusStopped;
}

@end