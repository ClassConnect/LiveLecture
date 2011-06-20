@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


@implementation CCEvent : CPEvent
{
	CGPoint _slideLayerPoint @accessors(property=slideLayerPoint);
}

+(CCEvent)eventWithBaseEvent:(CPEvent)base convertedPoint:(CGPoint)point
{
	return [[self alloc] initWithBaseEvent:base convertedPoint:point];
}

-(id)initWithBaseEvent:(CPEvent)event convertedPoint:(CGPoint)point
{
	if(self = [super init])
	{
		//	Copy the base event into the current event
		_type = event._type;
		_location = event._location;
		_modifierFlags = event._modifierFlags;
		_timestamp = event._timestamp;
		_context = event._context;
		_eventNumber = event._eventNumber;
		_clickCount = event._clickCount;
		_pressure = event._pressure;
		_window = event._window;
		_windowNumber = event._windowNumber;
		_characters = event._characters;
		_charactersIgnoringModifiers = event._charactersIgnoringModifiers;
		_isARepeat = event._isARepeat;
		_keyCode = event._keyCode;
		_DOMEvent = event._DOMEvent;
		_deltaX = event._deltaX;
		_deltaY = event._deltaY;
		_deltaZ = event._deltaZ;
		
		_slideLayerPoint = point;
	}
	return self;
}

-(CGPoint)pointInSlideLayer
{
	return _slideLayerPoint;
}

@end