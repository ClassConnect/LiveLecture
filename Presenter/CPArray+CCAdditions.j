@import <Foundation/Foundation.j>

@implementation CPArray (CCAdditions)

-(void)makeObjectsPerformFunction:(Function)f
{
	for(var i = 0 ; i < [self count] ; i++)
	{
		f([self objectAtIndex:i]);
	}
}

@end