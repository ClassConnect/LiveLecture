@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCWidget.j"

@implementation CCTextWidget : CCWidget
{
	BOOL _fromStorage @accessors(property=fromStorage);
	CPString _HTML @accessors(property=HTML);
	BOOL _isEmpty @accessors(property=isEmpty);
}

+(Class)layerClass
{
	return [TextLayer class];
}

-(id)initWithWidget:(CCTextWidget)widget
{
	if(self = [super initWithWidget:widget])
	{
		[self setFromStorage:[widget fromStorage]];
		[self setHTML:[[widget HTML] copy]];
		[self setIsEmpty:[[widget isEmpty] copy]];
	}
	return self;
}

- (id)initWithString:(CPString)string
{
	return [self initWithString:string alignment:TextLayerCenterAlignmentMask fontSize:48]
}

-(id)initWithList:(CPArray)list alignment:(unsigned)mask fontSize:(unsigned)size
{
	if((list == nil) || ([list count] == 0))
		return [self initWithString:"" alignment:mask fontSize:size];
	var tl = [[TextLayer alloc] init];
	[tl setFontSize:size];
	[tl align:mask];
	for(var list_index = 0 ; list_index < [list count] ; list_index++)
	{
		var string = list[list_index],
				index = 0,
				count = string.length;
		[tl insertCharacter:"-" stillInserting:YES];
		[tl insertCharacter:" " stillInserting:YES];
		for(var i = 0 ; i < count ; i++)
		{
			var character = string.charAt(i);
		
			if(character != "\r" && character != "\n")
				[tl insertCharacter:character stillInserting:YES];
		}
		[tl insertReturn];
	}
	[tl selectionDidChange];
	return [self initFromStorage:NO withHTML:tl._contentLayer._DOMElement.innerHTML isEmpty:NO];
}

- (id)initWithString:(CPString)string alignment:(unsigned)mask fontSize:(unsigned)size
{
	var tl = [[TextLayer alloc] init];
	[tl setFontSize:size];
	[tl align:mask];
	[tl setStringValue:string];
	return [self initFromStorage:NO withHTML:tl._contentLayer._DOMElement.innerHTML isEmpty:([string length] == 0)];
}

- (id)initFromStorage:(BOOL)fromStorage withHTML:(CPString)HTML isEmpty:(BOOL)isEmpty 
{
	if(self = [self init])
	{
		[self setFromStorage:fromStorage];
		[self setHTML:HTML];
		[self setIsEmpty:isEmpty];
	}
	return self;
}

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (int)length
{
	return _isEmpty ? 0 : _HTML.length;
}

-(CPString)_HTMLToStorage
{
	return escape(_HTML);
}

-(CPString)_HTMLFromStorage:(CPString)HTML
{
	return unescape(HTML);
}

- (BOOL)isEqual:(CCTextWidget)rhs 
{
	if (self == rhs)
			return YES;
	
	if(![super isEqual:rhs])
		return NO;
	
	if ([rhs isKindOfClass:[CCTextWidget class]])
	    return (_isEmpty && _isEmpty == rhs._isEmpty) || _HTML == rhs._HTML;

	return NO;
}

-(CCTextWidget)copy
{
	return [[CCTextWidget alloc] initWithWidget:self];
}

@end

@implementation CCTextWidget (CPCoding)

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super initWithCoder:coder])
	{
		_fromStorage = YES;
		_HTML = [self _HTMLFromStorage:[coder decodeObjectForKey:@"html"]];
		_isEmpty = [[coder decodeObjectForKey:@"isEmpty"] boolValue];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{	
	[super encodeWithCoder:coder];
	[coder encodeObject:[self _HTMLToStorage] forKey:@"html"];
	[coder encodeObject:[CPNumber numberWithBool:_isEmpty] forKey:@"isEmpty"];
}

@end