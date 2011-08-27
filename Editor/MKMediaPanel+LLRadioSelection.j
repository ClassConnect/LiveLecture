@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation MKMediaPanel (LLRadioSelection)

-(void)selectRadioWithTag:(CPString)tag
{
	var allRadios = [searchFilterRadioGroup radios];
	var radio = nil,
		i=allRadios.length;
	//	Sets radio as the CPRadio object that has the right tag
	while((i>=0) && (radio = allRadios[--i]) && ([radio tag] != tag));
	[radio performClick:nil];
}

-(void)setImagesAsSelectedFilter
{
	[self selectRadioWithTag:MKMediaTypeImage];
}

-(void)setVideosAsSelectedFilter
{
	[self selectRadioWithTag:MKMediaTypeVideo];
}

@end