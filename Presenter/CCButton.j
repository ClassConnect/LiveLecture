@import <Foundation/Foundation.j>
@import <AppKit/CPButton.j>

@implementation CCButton : CPButton
{
    CPColor _backgroundColorCache;
    CPColor _hoverColor @accessors(property=hoverColor);
    CPColor _pushColor @accessors(property=pushColor);
}

- (BOOL)acceptsFirstResponder 
{     
    return YES; 
} 

- (BOOL)becomeFirstResponder 
{
    return YES; 
} 

- (BOOL)resignFirstResponder 
{ 
    return YES; 
} 

- (void)mouseEntered:(CPEvent)theEvent 
{
    if(_hoverColor && !_backgroundColorCache)
    {
        _backgroundColorCache = [self backgroundColor];
        [self setBackgroundColor:_hoverColor];
    }
} 

- (void)mouseExited:(CPEvent)theEvent 
{
    if(_backgroundColorCache)
    {
        [self setBackgroundColor:_backgroundColorCache];
        _backgroundColorCache = nil;
    }
}

-(void)mouseDown:(CPEvent)event
{
    if(_pushColor)
    {
        //  If they have the hoverColor defined, then we dont want to overwrite
        //  the original background color
        if(!_backgroundColorCache)
            _backgroundColorCache = [self backgroundColor];
        [self setBackgroundColor:_pushColor];
    }
    [super mouseDown:event];
}

-(void)mouseUp:(CPEvent)event
{
    if(_backgroundColorCache)
    {
        if(_hoverColor)
            [self setBackgroundColor:_hoverColor];
        else
        {
            [self setBackgroundColor:_backgroundColorCache];
            _backgroundColorCache = nil;
        }
    }
    [super mouseUp:event];
}

@end