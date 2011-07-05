@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "LLRTE.j"

@implementation CCWidget (LLRTEAdditions)

-(BOOL)allowedToSendData:(JSObject)data
{
	return NO;
}

-(CPString)receiverChannelForData:(JSObject)data
{
	return nil;
}

-(void)didReceiveData:(JSObject)data
{
	//	Do Nothing
}

@end

@implementation CCWidgetLayer (LLRTEAdditions)

-(void)sendData:(JSObject)data
{
	[[LLRTE sharedInstance] widget:_widget atIndex:_widgetIndex sendData:data];
}

-(void)updateAfterReceivingData:(JSObject)data
{
	//	Do nothing
}

@end