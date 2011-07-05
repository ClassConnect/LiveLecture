@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CCSlideTheme : CPObject
{
	CPString _backgroundPath @accessors(property=backgroundPath);
	CPColor _fontColor @accessors(property=fontColor);
	CPString _thumbnailURL @accessors(property=thumbnailURL);
	CPString _title @accessors(property=title);
}

+(id)defaultTheme
{
	return [CCSlideTheme themeWithBackgroundPath:"/app/livelecture/Editor/Resources/Themes/keynote.png" fontColor:"#FFFFFF" thumbnailURL:"app/livelecture/Editor/Resources/Themes/keynote_thumbnail.png" title:"Stevenote"];
}

+(CCSlideTheme)themeFromJSObject:(JSObject)jsobj
{
	return [CCSlideTheme themeWithBackgroundPath:jsobj["backgroundPath"] fontColor:jsobj["fontColor"] thumbnailURL:jsobj["thumbnailURL"] title:jsobj["title"]];
}

+(CCSlideTheme)themeWithBackgroundPath:(CPString)path fontColor:(CPColor)color thumbnailURL:(CPString)thumbnailURL title:(CPString)title
{
	return [[CCSlideTheme alloc] initWithBackgroundPath:path fontColor:color thumbnailURL:thumbnailURL title:title];
}

-(id)initWithTheme:(CCSlideTheme)theme
{
	if(self = [self init])
	{
		[self setBackgroundPath:[[theme backgroundPath] copy]];
		[self setFontColor:[[theme fontColor] copy]];
		[self setThumbnailURL:[[theme thumbnailURL] copy]];
		[self setTitle:[[theme title] copy]];
	}
	return self;
}

-(id)initWithBackgroundPath:(CPString)path fontColor:(CPColor)color thumbnailURL:(CPString)thumbnailURL title:(CPString)title
{
	if(self = [self init])
	{
		_backgroundPath = path;
		_fontColor = color;
		_thumbnailURL = thumbnailURL;
		_title = title;
	}
	return self;
}

-(id)init
{
	if(self = [super init])
	{
		//	The default initializations should be good enough for now
	}
	return self;
}

-(BOOL)isEqual:(CCSlideTheme)rhs
{
	return	_title == [rhs title]					&&
			[_fontColor isEqual:[rhs fontColor]]	&&
			_thumbnailURL == [rhs thumbnailURL]		&&
			_backgroundPath == [rhs backgroundPath];
}

-(id)copy
{
	return [[CCSlideTheme alloc] initWithTheme:self];
}

@end

@implementation CCSlideTheme (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super init])
	{
		_backgroundPath = [coder decodeObjectForKey:"backgroundPath"];
		_thumbnailURL = [coder decodeObjectForKey:"thumbnailURL"];
		_fontColor = [coder decodeObjectForKey:"fontColor"];
	}
	return self;
}

-(void)encodeWithCoder:(CPCoder)coder
{
	[coder encodeObject:_backgroundPath forKey:"backgroundPath"];
	[coder encodeObject:_thumbnailURL forKey:"thumbnailURL"];
	[coder encodeObject:_fontColor forKey:"fontColor"];
}

@end