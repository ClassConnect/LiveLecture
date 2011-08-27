/*
@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CCMovieWidget.j"

//	Add the option
@implementation CCMovieWidget (LiveLectureAdditions)

-(void)syncsVideos
{
	debugger;
	return self._syncsVideos = self._syncsVideos || NO;
}

-(void)setSyncsVideos:(BOOL)syncsVideos
{
	debugger;
	if(!syncsVideos)
		syncsVideos = NO;
	if(self._syncsVideos == syncsVideos)
		return;
	self._syncsVideos = syncsVideos;
}


//	Basically a straight copy of the current source code, but I am going to add the _syncsVideos option
-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super initWithCoder:coder])
	{
		_movie = [CPFlashMovie flashMovieWithFile:unescape([coder decodeObjectForKey:@"movie_filename"])];
		_youtubeID = [coder decodeObjectForKey:@"youtubeID"];
		[self setSyncsVideos:[coder decodeObjectForKey:@"syncsVideos"]];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{
	[super encodeWithCoder:coder];
	[coder encodeObject:escape([_movie filename]) forKey:@"movie_filename"];
	[coder encodeObject:_youtubeID forKey:@"youtubeID"];
	[coder encodeObject:[self syncsVideos] forKey:@"syncsVideos"];
}

@end
*/