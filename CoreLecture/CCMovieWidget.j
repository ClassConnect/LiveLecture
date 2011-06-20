/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidget.j"

@implementation CCMovieWidget : CCWidget {
	CPFlashMovie _movie @accessors(property=movie);
	CPString _youtubeID @accessors(property=youtubeID);
}

+(CPString)cleanFilename:(CPString)filename
{
	// Strip autoplay
	filename = [[filename stringByReplacingOccurrencesOfString:@"&autoplay=1" withString:@""] stringByReplacingOccurrencesOfString:@"&autoplay=0" withString:@""];
	filename = [filename stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	return filename;
}

//	
+(CPString)_youtubeIDFromFilename:(CPString)filename
{
	var yid = "";
	if(filename.indexOf("youtube.com/v/") != -1)
	{
		filename = [filename stringByReplacingOccurrencesOfString:@"http://www.youtube.com/v/" withString:@""];
		filename = [filename substringToIndex:([filename rangeOfString:"&"].location)];
		yid = filename;
	}
	else
	{
		var yid_location = filename.indexOf("v=");
		//	Move it over so that yid_location now points to the start of the youtube id
		yid_location += 2;
		while((yid_location < filename.length) && (filename.charAt(yid_location) != "&"))
		{
			yid += filename.charAt(yid_location);
			yid_location++;
		}
	}
	return yid;
}

+(CPString)_filenameFromYoutubeID:(CPString)yid
{
	return "http://www.youtube.com/v/"+yid+"&fs=0&source=uds";
}

-(id)initWithWidget:(CCMovieWidget)widget
{
	if(self = [super initWithWidget:widget])
	{
		[self setMovie:[widget movie]];
	}
	return self;
}

-(id)initWithYoutubeID:(CPString)yid
{
	return [self initWithMovie:[CPFlashMovie flashMovieWithFile:[CCMovieWidget _filenameFromYoutubeID:yid]]];
}

-(id)initWithFile:(CPString)file
{
	return [self initWithYoutubeID:[CCMovieWidget _youtubeIDFromFilename:file]];
}

-(id)initWithMovie:(CPFlashMovie)movie
{
	if(self = [super init])
	{
		[self setMovie:movie];
	}
	return self;
}

-(void)setMovie:(CPFlashMovie)movie
{
	if(movie == _movie)
		return;
	
	_movie = movie;
	
	//	WOW! They actually don't give me a setFilename method.
	//	See below for implementatation...
	[_movie setFilename:[CCMovieWidget cleanFilename:[_movie filename]]];
	_youtubeID = [CCMovieWidget _youtubeIDFromFilename:[_movie filename]];
}

-(void)setYoutubeID:(CPString)yid
{
	if(yid == _youtubeID)
		return;
	
	[self setMovie:[CPFlashMovie flashMovieWithFile:[CCMovieWidget _filenameFromYoutubeID:yid]]];
}

-(BOOL)isEqual:(CCMovieWidget)rhs
{
	return	[super isEqual:rhs] 			&&
					[_movie isEqual:[rhs movie]]	&&
					[_youtubeID isEqual:[rhs youtubeID]];
}

-(id)copy
{
	return [[CCMovieWidget alloc] initWithWidget:self];
}

@end

@implementation CCMovieWidget (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super initWithCoder:coder])
	{
		_movie = [CPFlashMovie flashMovieWithFile:unescape([coder decodeObjectForKey:@"movie_filename"])];
		_youtubeID = [coder decodeObjectForKey:@"youtubeID"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{
	[super encodeWithCoder:coder];
	[coder encodeObject:escape([_movie filename]) forKey:@"movie_filename"];
	[coder encodeObject:_youtubeID forKey:@"youtubeID"];
}

@end

@implementation CPFlashMovie (CCMovieWidgetAdditions)

-(void)setFilename:(CPString)filename
{
	_filename = filename;
}

-(BOOL)isEqual:(CPFlashMovie)rhs
{
	return _filename == [rhs filename];
}

@end 