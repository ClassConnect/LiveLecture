/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

TextLayerRichTextPboardType = "TextLayerRichTextPboardType";

TextLayerLeftAlignmentMask = 1 << 0;
TextLayerRightAlignmentMask = 1 << 1;
TextLayerCenterAlignmentMask = 1 << 2;
TextLayerJustifiedAlignmentMask = 1 << 3;
TextLayerAllAlignmentMask = TextLayerLeftAlignmentMask | TextLayerRightAlignmentMask | TextLayerCenterAlignmentMask | TextLayerJustifiedAlignmentMask;

TextLayerAlignmentMaskValues = {}
TextLayerAlignmentMaskValues[TextLayerLeftAlignmentMask] = "left";
TextLayerAlignmentMaskValues[TextLayerRightAlignmentMask] = "right";
TextLayerAlignmentMaskValues[TextLayerCenterAlignmentMask] = "center";
TextLayerAlignmentMaskValues[TextLayerJustifiedAlignmentMask] = "justify";

TextLayerDiscBulletStyleMask = 1 << 0;
TextLayerNumberBulletStyleMask = 1 << 2;
TextLayerAllBulletStyleMask = TextLayerDiscBulletStyleMask | TextLayerNumberBulletStyleMask;

TextLayerBulletStyleMaskValues = {};
TextLayerBulletStyleMaskValues[TextLayerDiscBulletStyleMask] = "disc";
TextLayerBulletStyleMaskValues[TextLayerNumberBulletStyleMask] = "decimal";

TextAttributeOnState = 1 << 0;
TextAttributeOffState = 1 << 1;
TextAttributeMixedState = TextAttributeOnState | TextAttributeOffState;

TextAttributesMake= function(aFontFamily, aSize, aColor, aBoldState, anItalicState, anUnderlineState, anAlignmentMask, aBulletStyleMask)
{
    return { fontFamily:aFontFamily, fontSize:aSize, color:aColor, boldState:aBoldState, italicState:anItalicState, underlineState:anUnderlineState, alignmentMask:anAlignmentMask, bulletStyleMask:aBulletStyleMask };
}

TextAttributesMakeCopy= function(attributes)
{
    return TextAttributesMake(attributes.fontFamily, attributes.fontSize, attributes.color, attributes.boldState, attributes.italicState, attributes.underlineState, attributes.alignmentMask, attributes.bulletStyleMask);
}

TextAttributesCombine= function(lhsAttributes, rhsAttributes)
{
    return TextAttributesMake(
        lhsAttributes.fontFamily == rhsAttributes.fontFamily ? lhsAttributes.fontFamily : nil,
        lhsAttributes.fontSize == rhsAttributes.fontSize ? lhsAttributes.fontSize : 0.0,
        lhsAttributes.color,
        lhsAttributes.boldState | rhsAttributes.boldState,
        lhsAttributes.italicState | rhsAttributes.italicState,
        lhsAttributes.underlineState | rhsAttributes.underlineState,
        lhsAttributes.alignmentMask | rhsAttributes.alignmentMask,
        lhsAttributes.bulletStyleMask | rhsAttributes.bulletStyleMask);
}

var kRight = 39,
    kLeft = 37,
    kDown = 40,
    kUp = 38,
    kFirst = 1,
    kLast = 2,
    kEnd = 3,
    kHome = 4;

var kEmacsConversion = {65: kFirst, 69: kLast, 66: kLeft, 70: kRight, 78: kDown, 80: kUp};
var kArrowConversion = {39: kLast, 37: kFirst, 38: kHome, 40: kEnd};
var kValidCommandKeys = {'b':1, 'i':1, 'u':1, '-':1, '=':1, 'a':1};

var TextLayerSharedCaretBlinkingSuspended = NO,
    TextLayerLastCaretHighlight = 0,
    TextLayerSharedCaret = nil,
    TextLayerSharedCaretTimer = [CPNull null];

var TextLayerWhiteSpaceRegex = /\s/,
    TextLayerWordBreakRegex = /\w/,

    TextLayerLineSpacerElement = nil,
    TextLayerLiElement = nil,
    TextLayerParagraphElement = nil,
    TextLayerUlElement = nil,
    TextLayerNewLineElement = nil,
 	TextLayerSpanElement = nil,

    TextLayerSelectionLayers = nil,
    TextLayerSelectionLayerColor = nil;

var TextLayerIsMSIE = NO;

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CCTextWidget.j"
@import "CCWidgetLayer.j"

@implementation TextLayer : CCWidgetLayer {
	CPArray _selectionLayers;
	CALayer _contentLayer;
	DOMElement _currentParagraph;
	id _previousCharacter;
	DOMElement _selectionStart;
	DOMElement _selectionEnd;
	JSObject _lastCharacterOnPreviousLineCacheMap;
	JSObject _firstCharacterOnNextLineCacheMap;
	JSObject _tallestElementCacheMap;
	CGPoint _contentLocationCache;
	float _characterDeltaX;
	float _characterDeltaY;
	float _maximumWidth;
	float _maximumHeight;
	float _caretLeftOffset;
	BOOL _isFirstResponder;
	BOOL _needsSelectionRedraw;
	BOOL _isInsertingFromStorageObject;
	id _delegate;
	id _selectionDelegate;
 	float _scale;
	CPRange _selectionRange;
	JSObject _typingTextAttributes;
	JSObject _typingTextProperties;
	JSObject _defaultTextAttributes;
	//	My Edits
	CPColor _defaultColor @accessors(property=defaultColor);
	CCTextWidget _textBody;
	
	CPUndoManager _undoManager;
}

+(CALayer)takeSelectionLayerFromPool {
	if (TextLayerSelectionLayers.length)
        return TextLayerSelectionLayers.pop();

    var layer = [CALayer layer];

    [layer setAnchorPoint:CGPointMake(0.0,0.0)];
    [layer setBackgroundColor:TextLayerSelectionLayerColor];

    return layer;
}

+(void)returnSelectionLayerToPool:(CALayer)layer {
	TextLayerSelectionLayers.push(layer);
}

+(id)initialize {
	if (self != [TextLayer class])
        return;

    TextLayerSharedCaret = [CALayer layer];

    [TextLayerSharedCaret setMasksToBounds:YES];
    [TextLayerSharedCaret setBounds:CGRectMake(0.0,0.0,1.0,16.0)];
    [TextLayerSharedCaret setAnchorPoint:CGPointMake(0.0,0.0)];
    [TextLayerSharedCaret setBackgroundColor:[CPColor grayColor]];
	[TextLayerSharedCaret setZPosition:9001];

    TextLayerIsMSIE = navigator && navigator.userAgent && navigator.userAgent.indexOf("MSIE") >= 0;

    TextLayerLineSpacerElement = document.createElement("div");

    TextLayerLineSpacerElement.className = "lineSpacer";
    TextLayerLineSpacerElement.style.fontSize = "31.25%";

    TextLayerUlElement = document.createElement("ul");

    TextLayerUlElement.style.marginTop = "0";
    TextLayerUlElement.style.paddingTop = "0";
    TextLayerUlElement.style.marginBottom = "0";
    TextLayerUlElement.style.paddingBottom = "0";
    TextLayerUlElement.style.paddingLeft = "1em";
    TextLayerUlElement.style.marginLeft = "2em";

    TextLayerLiElement = document.createElement("li");

    TextLayerLiElement.style.marginTop = "0";
    TextLayerLiElement.style.paddingTop = "0";
    TextLayerLiElement.style.marginBottom = "0";
    TextLayerLiElement.style.paddingBottom = "0";
    TextLayerLiElement.style.paddingLeft = "0";
    TextLayerLiElement.style.marginleft = "0.5em";
    TextLayerLiElement.style.fontSize = "320%";
 	TextLayerLiElement.style.listStyleType = "disc";

    TextLayerParagraphElement = document.createElement("div");
    TextLayerParagraphElement.className = "paragraph";
	TextLayerParagraphElement.style.verticalAlign = "inherit";

    TextLayerSpanElement = document.createElement("span");
	TextLayerSpanElement.style.verticalAlign="inherit";

    TextLayerNewLineElement = document.createElement("span");
    TextLayerNewLineElement.appendChild(document.createTextNode(TextLayerIsMSIE ? '\r' : '\n'));
    TextLayerNewLineElement.style.fontSize = "320%";

    TextLayerSelectionLayers = [];
    TextLayerSelectionLayerColor = [CPColor colorWithCalibratedRed:(181.0/255.0) green:(213.0/255.0) blue:(255.0/255.0) alpha:(0.8)];
}

+(void)blinkCaret {
	if (TextLayerSharedCaretTimer != [CPNull null])
        return;

    TextLayerSharedCaretTimer = window.setTimeout(function()
    {
        if (!TextLayerLastCaretHighlight || new Date() - TextLayerLastCaretHighlight > 600)
        {
            [TextLayerSharedCaret setHidden:(!TextLayerSharedCaretBlinkingSuspended && ![TextLayerSharedCaret isHidden])];
            TextLayerLastCaretHighlight = nil;
        }

        [[CPRunLoop currentRunLoop] performSelectors];

        TextLayerSharedCaretTimer = [CPNull null];

        [self blinkCaret];
    }, 600);
}

+(void)highlightCaret {
	TextLayerLastCaretHighlight = new Date();

    [TextLayerSharedCaret setHidden:NO];
}

+(void)setCaretBlinkingSuspended:(BOOL)suspended {
	TextLayerSharedCaretBlinkingSuspended = suspended;
}

+(BOOL)careBlinkingSuspended {
	return TextLayerSharedCaretBlinkingSuspended;
}

-(id)initWithWidget:(CCWidget)widget
{
	if(self = [self init])
	{
		[self setTextWidget:widget];
	}
	return self;
}

-(id)init {
	self = [super init];
	
    if (!self)
        return;

    _scale = 1.0;

    [self setBounds:CGRectMake(0.0,0.0,100.0,16.0)];

    _contentLayer = [CALayer layer];
    _contentLayer._DOMElement.className = "root";

  	[_contentLayer setAnchorPoint:CGPointMake(0.0,0.0)];
    [_contentLayer setBounds:CGRectMakeCopy([self bounds])];

    [self addSublayer:_contentLayer];

    _currentParagraph = TextLayerParagraphElement.cloneNode(false);

    _DOMElement.style.fontSize = "10pt";

    _currentParagraph.appendChild(TextLayerNewLineElement.cloneNode(true));
    _contentLayer._DOMElement.appendChild(_currentParagraph);

    if(TextLayerIsMSIE)
    {
        _contentLayer._DOMElement.style.wordWrap = "break-word";
        _contentLayer._DOMElement.style.whiteSpace = "pre";
    }
    else
    {
        _contentLayer._DOMElement.style.whiteSpace = "-moz-pre-wrap";
        _contentLayer._DOMElement.style.whiteSpace = "pre-wrap";
    }

    _caretLeftOffset = 0;

    [self setMasksToBounds: YES];

    _typingTextProperties = TextAttributesMake("", "", "", "", "", "", "", "");

    _typingTextAttributes = nil;

    [self setDefaultTextAttributes:TextAttributesMake("Arial", 12.0, [CPColor whiteColor], TextAttributeOffState, TextAttributeOffState, TextAttributeOffState, TextLayerLeftAlignmentMask, TextLayerDiscBulletStyleMask)];

    _selectionRange = CPMakeRange(0, 0);

    _textBody = nil;

	//	TODO: Make this work with the upcoming theme system instead of just a default
	_defaultColor = [CPColor whiteColor];

    return self;
}

-(void)setDelegate:(id)delegate {
	_delegate = delegate;
}

-(id)delegate {
	return _delegate;
}

-(id)previousCharacter {
	return _previousCharacter;
}

-(id)nextCharacter {
	if(_previousCharacter)
		return _previousCharacter.nextSibling;
	else
		return _currentParagraph.firstChild;
}

-(id)firstCharacter {
	return [self firstCharacterInParagraph:[self firstParagraph]];
}

-(id)firstParagraph {
	var paragraph = _contentLayer._DOMElement.firstChild;

    if(paragraph.nodeName == TextLayerUlElement.nodeName)
        while(paragraph.className != TextLayerLineSpacerElement.className)
            paragraph = paragraph.firstChild;

    return paragraph;
}

-(id)lastParagraph {
	var paragraph = _contentLayer._DOMElement.lastChild;

    if(paragraph.nodeName == TextLayerUlElement.nodeName)
        while(paragraph.className != TextLayerLineSpacerElement.className)
            paragraph = paragraph.lastChild;

    return paragraph;
}

-(id)lastCharacterInParagraph:(DOMElement)paragraph {
	if(paragraph)
		return paragraph.lastChild;
	return NULL;
}

-(id)firstCharacterInParagraph:(DOMElement)paragraph {
	if(paragraph)
		return paragraph.firstChild;
	return NULL;
}

-(void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	[_contentLayer setBounds:CGRectMakeCopy(bounds)];
	[self setNeedsSelectionRedraw];
}

-(void)resize {
	return;

    var lastChild = _contentLayer._DOMElement.lastChild;

    var deltaY = _contentLayer._DOMElement.offsetTop;
    var height = lastChild.offsetTop - deltaY + lastChild.offsetHeight;
    var currentWidth = CGRectGetWidth([self bounds]);

    [self setBounds:CGRectMake(0.0,0.0,currentWidth,height)];
    [_contentLayer setBounds:CGRectMake(0.0,0.0,currentWidth,height)];
}

-(void)adoptSharedCaret {
	if([TextLayerSharedCaret superlayer] == self || _isThumbnail)
	{
		return;
	}
	[self addSublayer:TextLayerSharedCaret];
	[self positionCaret];
	[[self class] blinkCaret];
}

-(void)orphanSharedCaret {
	if([TextLayerSharedCaret superlayer] != self)
		return;
	
	[TextLayerSharedCaret removeFromSuperlayer];
	
	if(TextLayerSharedCaretTimer != [CPNull null]) 
		window.clearTimeout(TextLayerSharedCaretTimer);
	
	TextLayerSharedCaretTimer = [CPNull null];
}

-(void)becomeFirstResponder {
	if(_isFirstResponder || _isThumbnail)
		return;
	_isFirstResponder = YES;
	[self updateTypingTextAttributes];
	[super becomeFirstResponder];
}

-(void)resignFirstResponder {
	if(_isThumbnail)
		return;
	_isFirstResponder = NO;
	[self clearSelection];
	[self updateTypingTextAttributes];
	[super resignFirstResponder];
}

-(void)keyDown:(CPEvent)event {
	var keyCode = [event keyCode];
	var character = [event characters];
	var flags = [event modifierFlags];
	alert("CPRightArrowFunctionKey: "+(character == CPRightArrowFunctionKey));
	// alert("KeyCode: "+keyCode);
	// alert("Character: "+character);
	// alert("Character Ignoring Modifiers: "+[event charactersIgnoringModifiers]);
	if(flags & (CPCommandKeyMask | CPControlKeyMask))
			if((keyCode < 36 || keyCode > 41) && !kEmacsConversion[keyCode] && !kValidCommandKeys[character])
				return;
	//	Deal with the control characters special cases
	if(kValidCommandKeys[character] && (flags & (CPCommandKeyMask | CPControlKeyMask))) {
		switch(character) {
			case 'b': 	if(_typingTextAttributes.boldState & TextAttributeOffState)
							[self bold:self];
						else
							[self unbold:self];
			break;
			case 'i':	if(_typingTextAttributes.italicState & TextAttributeOffState)
							[self italicize:self];
						else
							[self unitalicize:self];
			break;
			case 'u':	if(_typingTextAttributes.underlineState & TextAttributeOffState)
							[self underline:self];
						else
							[self ununderline:self];
			break;
			case '=': 	[self resizeFontByFactor:1.25];
			break;
			case '-': 	[self resizeFontByFactor:.85];
			break;
			case 'a': 	[self selectAll];
			break;
		}
		return;
	}
	if([self hasSelection] && keyCode != 9) {
			switch(keyCode) {
				case 8:
				case 46: 	//if(character != '.')
							//{
								[self deleteSelection];
								[self positionCaret];
								[self redrawSelection];
								return;
							// }
							// else
							// {
							// 	[self deleteSelection];
							// 	break;
							// }
				case 36:	[self moveCaret:kHome extendSelection:(flags & CPShiftKeyMask)];
							[self positionCaret];
							[self redrawSelection];
							return;
				case 35:	[self moveCaret:kEnd extendSelection:(flags & CPShiftKeyMask)];
							[self positionCaret];
							[self redrawSelection];
							return;
				case 37:
				case 38:
				case 39:
				case 40:	//if(character == "'")
							//{
							//	[self deleteSelection];
							//	break;
							//}
							if(flags & CPCommandKeyMask)
							{
								[self moveCaret:kArrowConversion[keyCode] extendSelection:(flags & CPShiftKeyMask)];
							}
							else
							{
								[self moveCaret:keyCode extendSelection:(flags & CPShiftKeyMask)];
							}
							[self positionCaret];
							[self redrawSelection];
							return;
				case 65:
				case 69:
				case 66:
				case 70:
				case 78:
				case 80:	if(flags & CPControlKeyMask)
							{
								[self moveCaret:kEmacsConversion[keyCode] extendSelection:(flags & CPShiftKeyMask)];
								[self positionCaret];
								[self redrawSelection];
								return;
							}
				default:	[self deleteSelection];
							break;
			}
			_selectionStart = _selectionEnd = NULL;
			[self redrawSelection];
		}
		switch(keyCode) 
		{
			case 8:
			case 46:	if(character != '.')
							[self removeCharacter:( (keyCode==8) ? kLeft : kRight) stillDeleting:NO];
						else
							[self insertCharacter:'.' stillInserting:NO];
						break;
			case 36:	[self moveCaret:kHome extendSelection:(flags & CPShiftKeyMask)];
						break;
			case 35:	[self moveCaret:kEnd extendSelection:(flags & CPShiftKeyMask)];
						break;
			case 37:
			case 38:
			case 39:
			case 40:	if(character == "'")
						{
							[self insertCharacter:"'" stillInserting:NO];
							break;
						}
						if(flags & CPCommandKeyMask)
							[self moveCaret:kArrowConversion[keyCode] extendSelection:(flags & CPShiftKeyMask)];
						else
							[self moveCaret:keyCode extendSelection:(flags & CPShiftKeyMask)];
						break;
			//	Tab
			case 9:		if(flags & CPShiftKeyMask)
						{
							[self decreaseBulletLevel];
						}
						else
						{
							[self increaseBulletLevel];
						}
						break;
			//	Enter
			case 13:	[self insertReturn];
						break;
			case 65:
			case 69:
			case 66:
			case 70:
			case 78:
			case 80: 	if(flags & CPControlKeyMask)
						{
							[self moveCaret:kEmacsConversion[keyCode] extendSelection:(flags & CPShiftKeyMask)];
							break;		
						}
			default: 	[self insertCharacter:character stillInserting:NO];
						break;
		}
		
		[self textDidChange];
			
		[self resize];
		[self positionCaret];
		[self redrawSelection];
}

-(void)keyUp:(CPEvent)event
{
	//	Do nothing
}

-(void)insertCharacter:(char)character stillInserting:(BOOL)isStillInserting {
	if(!isStillInserting)
		if(![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
			return;
	var nextCharacter = [self nextCharacter],
		newSpan;
	if(newSpan)
		newSpan = newSpan.cloneNode(false);
	else {
		newSpan = document.createElement("span");
		newSpan.style.verticalAlign = "inherit";
		setFontSize(newSpan, _typingTextProperties.fontSize);
		takeStyleFrom(newSpan, _typingTextProperties);
	}
	
	newSpan.appendChild(document.createTextNode(character));
	
	_currentParagraph.insertBefore(newSpan, nextCharacter);
	
	_previousCharacter = newSpan;
	
	++_selectionRange.location;
	
	if(!isStillInserting) {
		[self selectionDidChange];
		
		[self resize];
		[self positionCaret];
		
		[self textDidChange];
	}
}

-(void)copy:(id)sender {
	if([self hasSelection]) {
		if([self selectionIsInverted])
			var start = _selectionEnd, end = _selectionStart;
		else
			var start = _selectionStart, end = _selectionEnd;
		
		var current = start, previous = null, result = "";
		while(current && current != end) {
			if(previous && current.parentNode != previous.parentNode) {
				if(current.parentNode.className == TextLayerLineSpacerElement.className) {
					var depth = getBulletDepth(current.parentNode);
					while(depth--)
						result += "\t";
				}
			}
			
			result += current.firstChild.nodeValue;
			
			previous = current;
			current = nextCharacter(current);
		}
		
		var textObject = [self rtfObjectFrom:start to:end forCopy:YES];
		
		var pasteboard = [CPPasteboard generalPasteboard];
		[pasteboard declareTypes:[CPStringPboardType,TextLayerRichTextPboardType] owner:nil];
		
		[pasteboard setString:result forType:CPStringPboardType];
		[pasteboard setString:CPJSObjectCreateJSON(textObject) forType:TextLayerRichTextPboardType];
	}
}

-(void)cut:(id)sender {
	if([self hasSelection]) {
		[self copy:sender];
		[self deleteSelection];
	}
}

-(void)paste:(id)sender {
	if(![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
		return;
	var pasteboard = [CPPasteboard generalPasteboard],
		types = [pasteboard types];
	if([types containsObject:TextLayerRichTextPboardType]) {
		if([self hasSelection])
			[self deleteSelection];
		var textObject = CPJSObjectCreateWithJSON([pasteboard stringForType:TextLayerRichTextPboardType]);
		[self insertFromStorageObject:textObject];
	}
	else if([types containsObject:CPStringPboardType]) {
		if([self hasSelection])
			[self deleteSelection];
		var textObject = [pasteboard stringForType:CPStringPboardType];
		
		for(var i=0 ; i < textObject.length; i++) {
			switch(textObject.charAt(i)) {
				case "\t" :	[self changeBulletLevel:kRight];
							break;
				case "\r":
				case "\n":	[self insertReturn];
							break;
							
				default: 	[self insertCharacter:textObject.charAt(i) stillInserting:YES];
							break;
			}
		}
	}
	else
		return;
	
	[self selectionDidChange];
	
	[self resize];
	[self positionCaret];
	
	[self textDidChange];
}

-(void)textDidChange {
	_textBody = nil;
	[_delegate textDidChange:self];
}

-(CCTextWidget)textWidget {
	if(!_textBody) {
		var contentElement = _contentLayer._DOMElement,
			contentChildren = contentElement.childNodes,
			isEmpty = contentChildren.length == 1 && contentChildren[0].className == TextLayerParagraphElement.className && contentChildren[0].childNodes.length == 1;
			
		_textBody = [[CCTextWidget alloc] initFromStorage:NO withHTML:contentElement.innerHTML isEmpty:isEmpty];
		[_textBody setLocation:[_widget location]];
		[_textBody setSize:[_widget size]];
		_widget = _textBody;
		// var oldWidget = _widget;
		// _widget = [[CCTextWidget alloc] initFromStorage:NO withHTML:contentElement.innerHTML isEmpty:isEmpty];
		// [_widget setLocation:[oldWidget location]];
		// [_widget setSize:[oldWidget size]];
	}
	return _textBody;
}

-(void)setTextWidget:(id)widget {
	[super setWidget:widget];
	_textBody = widget;
	if([widget respondsToSelector:@selector(HTML)])
	{
		_contentLayer._DOMElement.innerHTML = [widget HTML];
		_currentParagraph = _contentLayer._DOMElement.childNodes[0];
	}
}

-(void)setTextWidget_:(CCTextWidget)widget {
	if(![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
		return;
	
	[self setTextWidget:widget];
	
	[self textDidChange];
}

-(void)setStringValue:(CPString)string {
	[self selectAll];
	[self deleteSelection];
	
	var index = 0,
		count = string.length;
	
	for( ; index < count ; ++index) {
		var character = string.charAt(index);
		
		if(character != "\r" && character != "\n")
			[self insertCharacter:character stillInserting:YES];
		else
			[self insertReturn];
	}
	
	if([string length])
		[self selectionDidChange];
}

-(void)moveCaret:(int)direction extendSelection:(BOOL)extendSelection {
	if([self hasSelection] && !extendSelection)
    {
        if([self selectionIsInverted])
            var start = _selectionEnd, end = _selectionStart;
        else
            var start = _selectionStart, end = _selectionEnd;

        switch(direction)
        {
            case kUp:
            case kLeft: _previousCharacter = start.previousSibling;
                            _currentParagraph = start.parentNode;

                            _selectionRange.length = 0;
                            [self selectionDidChange];

                            return _selectionStart = _selectionEnd = NULL;
            case kDown:
            case kRight: _previousCharacter = end.previousSibling;
                            _currentParagraph = end.parentNode;

                            _selectionRange.location = CPMaxRange(_selectionRange);
                            _selectionRange.length = 0;
                            [self selectionDidChange];

                            return _selectionStart = _selectionEnd = NULL;
        }
    }

    if(extendSelection && ![self hasSelection])
    {
        if(_previousCharacter)
            _selectionEnd = _selectionStart = _previousCharacter.nextSibling;
        else
            _selectionEnd = _selectionStart = _currentParagraph.firstChild;

        var start = _selectionStart, end = _selectionEnd, inverted = false;
    }
    else if(extendSelection)
    {
        var inverted = [self selectionIsInverted];
        if(inverted)
            var start = _selectionEnd, end = _selectionStart;
        else
            var start = _selectionStart, end = _selectionEnd;
    }

    switch(direction)
    {
        case kLeft: if(extendSelection)
                        {
                            var previous = previousCharacter(start);
                            if(previous)
                            {
                                start = previous;

                                --_selectionRange.location;
                                ++_selectionRange.length;
                            }

                            break;
                        }

                        if(_previousCharacter != NULL)
                        {
                            _previousCharacter = _previousCharacter.previousSibling;
                            _caretLeftOffset = _previousCharacter ? _previousCharacter.offsetLeft : 0;

                            --_selectionRange.location;

                            break;
                        }

                        var previousParagraph = traversePreviousNode(_currentParagraph);
                        if(previousParagraph && previousParagraph.nodeName != TextLayerUlElement.nodeName)
                        {
                            _currentParagraph = previousParagraph;
                            _previousCharacter = _currentParagraph.lastChild.previousSibling;
                            _caretLeftOffset = _previousCharacter.offsetLeft;

                            --_selectionRange.location;
                        }
                        break;

        case kRight: if(extendSelection)
                        {
                            var next = nextCharacter(end);
                            if(next)
                            {
                                end = next;

                                ++_selectionRange.length;
                            }

                            break;
                        }

                        var nextChar = [self nextCharacter];
                        if(nextChar != NULL && nextChar.innerHTML != TextLayerNewLineElement.innerHTML)
                        {
                            _previousCharacter = nextChar;
                            _caretLeftOffset = nextChar.offsetLeft;

                            ++_selectionRange.location;

                            break;
                        }

                        var nextParagraph = traverseNextNode(_currentParagraph);
                        if(nextParagraph && nextParagraph.nodeName != TextLayerUlElement.nodeName)
                        {
                            _currentParagraph = nextParagraph;
                            _previousCharacter = NULL;
                            _caretLeftOffset = 0;

                            ++_selectionRange.location;
                        }

                        break;

        case kUp: var currentLeftOffset = 0, currentNode = _previousCharacter;
                        if(currentNode)
                            currentLeftOffset = currentNode.offsetLeft + 1;

                        while(currentNode && currentNode.offsetLeft < currentLeftOffset)
                            currentNode = currentNode.previousSibling;

                        if(!currentNode)
                        {
                            var previousParagraph = traversePreviousNode(_currentParagraph);
                            if(previousParagraph)
                            {
                                _currentParagraph = previousParagraph;
                                currentNode = previousParagraph.lastChild.previousSibling;
                            }
                        }

                        while(currentNode && currentNode.offsetLeft > _caretLeftOffset)
                            currentNode = currentNode.previousSibling;

                        _previousCharacter = currentNode;

                        if(extendSelection)
                            start = [self nextCharacter];

                        [self calculateSelectedRange];

                        break;

        case kDown: var currentLeftOffset = 0, currentNode = [self nextCharacter];
                        if(currentNode)
                            currentLeftOffset = currentNode.offsetLeft;

                        while(currentNode && currentNode.offsetLeft >= currentLeftOffset)
                            currentNode = currentNode.nextSibling;

                        if(!currentNode)
                        {
                            var nextParagraph = traverseNextNode(_currentParagraph);
                            if(nextParagraph)
                            {
                                _currentParagraph = nextParagraph;
                                currentNode = nextParagraph.firstChild;
                            }
                        }

                        while(currentNode && currentNode.offsetLeft <= _caretLeftOffset)
                            currentNode = currentNode.nextSibling;

                        if(currentNode && currentNode.innerHTML != TextLayerNewLineElement.innerHTML)
                            _previousCharacter = currentNode;
                        else
                            _previousCharacter = _currentParagraph.lastChild.previousSibling;

                        if(extendSelection)
                            end = [self nextCharacter];

                        [self calculateSelectedRange];

                        break;

        case kHome: _currentParagraph = _contentLayer._DOMElement.firstChild;
                        while(_currentParagraph.nodeName == TextLayerUlElement.nodeName)
                            _currentParagraph = paragraph.firstChild;







                        _previousCharacter = NULL;
                        _selectionStart = _selectionEnd = NULL;

                        _selectionRange = CPMakeRange(0, 0);

                        break;

        case kEnd: _currentParagraph = _contentLayer._DOMElement.lastChild;
                        while(_currentParagraph.nodeName == TextLayerUlElement.nodeName)
                            _currentParagraph = paragraph.lastChild;







                        _previousCharacter = _currentParagraph.lastChild.previousSibling;
                        _selectionStart = _selectionEnd = NULL;

                        [self calculateSelectedRange];

                        break;

        case kFirst:





                        _previousCharacter = NULL;
                        _selectionStart = _selectionEnd = NULL;

                        [self calculateSelectedRange];

                        break;

        case kLast:





                        _previousCharacter = _currentParagraph.lastChild.previousSibling;
                        _selectionStart = _selectionEnd = NULL;

                        [self calculateSelectedRange];

                        break;
    }

    if(extendSelection)
    {
        if(!inverted)
        {
            _selectionStart = start;
            _selectionEnd = end;
        }
        else
        {
            _selectionStart = end;
            _selectionEnd = start;
        }
    }

    [self selectionDidChange];
}

-(void)removeCharacter:(int)direction stillDeleting:(BOOL)stillDeleting {
	if (!stillDeleting)
    {
        if (![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
            return;

        [self selectionDidChange];
    }

    if(direction == kRight)
    {
        var nextChar = [self nextCharacter];
        if(nextChar.innerHTML != TextLayerNewLineElement.innerHTML)
        {
            _currentParagraph.removeChild(nextChar);
        }
        else
        {
            var firstCharacterOfNextParagraph = nextCharacter(nextChar);
            if(firstCharacterOfNextParagraph)
            {
                _previousCharacter = null;
                _currentParagraph = firstCharacterOfNextParagraph.parentNode;

                if(firstCharacterOfNextParagraph.parentNode.className == TextLayerLineSpacerElement.className)
                {
                    var depth = getBulletDepth(firstCharacterOfNextParagraph.parentNode);
                    while(depth--)
                        [self removeCharacter:kLeft stillDeleting:YES];
                }

                return [self removeCharacter:kLeft stillDeleting:stillDeleting];
            }
        }
    }
    else
    {
        var currentCharacter = [self previousCharacter];
        if(currentCharacter)
        {
            var previous = currentCharacter.previousSibling;
            _currentParagraph.removeChild(currentCharacter);
            _previousCharacter = previous;
            _caretLeftOffset = _previousCharacter ? _previousCharacter.offsetLeft : 0;

            if (!stillDeleting)
                --_selectionRange.location;
        }
        else
        {
            if(_currentParagraph.parentNode.nodeName == TextLayerLiElement.nodeName)
                [self changeBulletLevel:kLeft];
            else
            {
                var previousParagraph = _currentParagraph.previousSibling;
                if(!previousParagraph)
                    return;

                if (!stillDeleting)
                    --_selectionRange.location;

                while(previousParagraph.firstChild.firstChild.nodeType != 3)
                    previousParagraph = previousParagraph.lastChild;

                var lastCharOfLastParagraph = [self lastCharacterInParagraph:previousParagraph];
                var nextCursorPosition = lastCharOfLastParagraph.previousSibling;

                var start = [self nextCharacter];
                var end = [self lastCharacterInParagraph:_currentParagraph];

                while(start && start != end)
                {
                    var next = start.nextSibling;
                    previousParagraph.insertBefore(start, lastCharOfLastParagraph);
                    start = next;
                }

                _contentLayer._DOMElement.removeChild(_currentParagraph);
                _previousCharacter = nextCursorPosition;
                _currentParagraph = previousParagraph;
                _caretLeftOffset = _previousCharacter ? _previousCharacter.offsetLeft : 0;
            }
        }
    }
}

-(void)insertReturn {
	var start = [self nextCharacter];
    var end = [self lastCharacterInParagraph:_currentParagraph];

    var newParagraph = _currentParagraph.cloneNode(false);
    while(start && start!=end)
    {
        var next = start.nextSibling;
        newParagraph.appendChild(start);
        start = next;
    }

    var newLine = TextLayerNewLineElement.cloneNode(true);
    newParagraph.appendChild(newLine);

    var aSize = _typingTextAttributes.fontSize;

    if(_currentParagraph.parentNode.nodeName == TextLayerLiElement.nodeName)
    {
        var newLI = _currentParagraph.parentNode.cloneNode(false);
        newLI.appendChild(newParagraph);

        [self applyFontSize:aSize toElement:newLI];
        [self applyFontSize:((1.0/aSize)*100.0) toElement:newParagraph];

        _currentParagraph.parentNode.parentNode.insertBefore(newLI, _currentParagraph.parentNode.nextSibling);
    }
    else
        _currentParagraph.parentNode.insertBefore(newParagraph, _currentParagraph.nextSibling);

    [self applyFontSize:aSize toElement: newLine];

    takeStyleFrom(newLine, _typingTextProperties);

    _currentParagraph = newParagraph;
    _previousCharacter = NULL;
    _caretLeftOffset = 0;

    ++_selectionRange.location;

    [self textDidChange];
}

-(void)changeBulletLevel:(int)direction {
	var paragraph = [self nextCharacter].parentNode;
    var liNode = paragraph.parentNode
    var liParent = liNode.parentNode;
    var parentsParent = liParent.parentNode;

    if(direction == kLeft)
    {
        if (paragraph.className != TextLayerLineSpacerElement.className)
            return;

        var newUL = liParent.cloneNode(false);
        while(liNode.nextSibling)
            newUL.appendChild(liNode.nextSibling);

        if(parentsParent.className == "root")
        {
            var newDiv = TextLayerParagraphElement.cloneNode(false);

            newDiv.style.textAlign = _typingTextProperties.alignmentMask;

            while(paragraph.firstChild)
                newDiv.appendChild(paragraph.firstChild);

            parentsParent.insertBefore(newUL, liParent.nextSibling);
            parentsParent.insertBefore(newDiv, newUL);
            liParent.removeChild(liNode);
            _currentParagraph = newDiv;
        }
        else
        {
            parentsParent.insertBefore(newUL, liParent.nextSibling);
            parentsParent.insertBefore(liNode, newUL);
        }

        if(!liParent.childNodes || liParent.childNodes.length == 0)
            parentsParent.removeChild(liParent);

        if(!newUL.childNodes || newUL.childNodes.length == 0)
            parentsParent.removeChild(newUL);
    }
    else
    {
        if(paragraph.className == TextLayerLineSpacerElement.className)
        {
            if(liNode.previousSibling && liNode.previousSibling.nodeName == TextLayerUlElement.nodeName)
            {
                if(liNode.nextSibling && liNode.nextSibling.nodeName == TextLayerUlElement.nodeName)
                {
                    var nextList = liNode.nextSibling;
                    var lastList = liNode.previousSibling;

                    lastList.appendChild(liNode);
                    while(nextList.firstChild)
                        lastList.appendChild(nextList.firstChild);

                    liParent.removeChild(nextList);
                }
                else
                    liNode.previousSibling.appendChild(liNode);
            }
            else if(liNode.nextSibling && liNode.nextSibling.nodeName == TextLayerUlElement.nodeName)
                liNode.nextSibling.insertBefore(liNode, liNode.nextSibling.firstChild);
            else
            {
                var newUL = TextLayerUlElement.cloneNode(false);
                liParent.insertBefore(newUL, liNode);
                newUL.appendChild(liNode);
            }

            if(!liParent.childNodes || liParent.childNodes.length == 0)
                parentsParent.removeChild(liParent);
        }
        else
        {
            var newList = TextLayerLiElement.cloneNode(false);
            var newScaler = TextLayerLineSpacerElement.cloneNode(false);

            newScaler.style.textAlign = _typingTextProperties.alignmentMask;

            newList.appendChild(newScaler);

            while(paragraph.firstChild)
                newScaler.appendChild(paragraph.firstChild);

            if(paragraph.previousSibling && paragraph.previousSibling.nodeName == TextLayerUlElement.nodeName)
            {
                var lastList = paragraph.previousSibling;
                if(paragraph.nextSibling && paragraph.nextSibling.nodeName == TextLayerUlElement.nodeName)
                {
                    lastList.appendChild(newList);

                    var nextList = paragraph.nextSibling;
                    while(nextList.firstChild)
                        lastList.appendChild(nextList.firstChild);

                    _contentLayer._DOMElement.removeChild(nextList);
                }
                else
                    lastList.appendChild(newList);
            }
            else if(paragraph.nextSibling && paragraph.nextSibling.nodeName == TextLayerUlElement.nodeName)
                paragraph.nextSibling.insertBefore(newList, paragraph.nextSibling.firstChild);
            else
            {
                var newUL = TextLayerUlElement.cloneNode(false);
                newUL.appendChild(newList);
                _contentLayer._DOMElement.insertBefore(newUL, paragraph);
            }

            setFontSize(newScaler.firstChild, parseFontSize(newScaler.firstChild.style.fontSize));

            _contentLayer._DOMElement.removeChild(paragraph);
            _currentParagraph = newScaler;
        }
    }

    _caretLeftOffset = _previousCharacter ? _previousCharacter.offsetLeft : 0;

    [self textDidChange]
}

-(void)mouseDown:(CPEvent)event {
	_tallestElementCacheMap = new Array();
    _firstCharacterOnNextLineCacheMap = new Array();
    _lastCharacterOnPreviousLineCacheMap = new Array();

    _contentLocationCache = locationInWindow(_contentLayer._DOMElement);
	
    var target = [self returnTarget:event];
    var count = [event clickCount];

    if([event modifierFlags] & CPShiftKeyMask)
    {
        if(![self hasSelection])
            _selectionStart = _selectionEnd = _previousCharacter;

        [self extendSelection:target];
    }
    else if(count >= 3 && target.character && target.character == _previousCharacter && target.character.firstChild &&
       target.character.firstChild.nodeType == 3 && target.character.innerHTML != TextLayerNewLineElement.innerHTML)
    {
        _selectionStart = _currentParagraph.firstChild;
        _selectionEnd = _currentParagraph.lastChild;
    }
    else if(count >= 2 && target.character && target.character == _previousCharacter && target.character.firstChild &&
       target.character.firstChild.nodeType == 3 && target.character.innerHTML != TextLayerNewLineElement.innerHTML)
    {
        var regex = TextLayerWordBreakRegex;
        if(target.character && !target.character.firstChild.nodeValue.match(regex))
            regex = TextLayerWhiteSpaceRegex;

        var start = target.character ? target.character : target.paragraph.firstChild;
        while(start && start.previousSibling && start.previousSibling.firstChild.nodeValue.match(regex))
            start = start.previousSibling;

        var end = target.character;
        while(end && end.firstChild.nodeValue.match(regex) && end.innerHTML != TextLayerNewLineElement.innerHTML)
            end = end.nextSibling;

        _selectionStart = start;
        _selectionEnd = end;
    }
    else
    {
        _previousCharacter = target.character;
        _currentParagraph = target.paragraph;
        _caretLeftOffset = _previousCharacter ? _previousCharacter.offsetLeft : 0;

        _selectionStart = _selectionEnd = [self nextCharacter];
    }

    [self positionCaret];
    [self redrawSelection];
}

-(void)mouseDragged:(CPEvent)event {
	var target = [self returnTarget:event];

    if(target.character)
        var charOfInterest = target.character.nextSibling;
    else
        var charOfInterest = target.paragraph.firstChild;

    if([event modifierFlags] & CPShiftKeyMask)
    {
        [self extendSelection:target];
    }
    else
    {
        _selectionEnd = charOfInterest;
    }

    [self redrawSelectionWhileStillSelecting:YES];
}

-(void)extendSelection:(id)target {
	var charOfInterest = target.character;

    if(!charOfInterest)
        charOfInterest = target.paragraph.firstChild;
    else
        charOfInterest = charOfInterest.nextSibling;

    if([self selectionIsInverted])
        var start = _selectionEnd, end = _selectionStart;
    else
        var start = _selectionStart, end = _selectionEnd;

    var beforeStart = comparator(charOfInterest, CPPointMake(start.offsetLeft, start.offsetTop), self, YES) > 0;
    var afterEnd = comparator(charOfInterest, CPPointMake(end.offsetLeft, end.offsetTop), self, YES) < 0;

    if(beforeStart)
        start = charOfInterest;
    else if(afterEnd)
        end = charOfInterest;
    else
    {

        var distanceToStart = SQRT((charOfInterest.offsetLeft-start.offsetLeft)*(charOfInterest.offsetLeft-start.offsetLeft)+
                                   (charOfInterest.offsetTop-start.offsetTop)*(charOfInterest.offsetTop-start.offsetTop));

        var distanceToEnd = SQRT((charOfInterest.offsetLeft-end.offsetLeft)*(charOfInterest.offsetLeft-end.offsetLeft) +
                                   (charOfInterest.offsetTop-end.offsetTop)*(charOfInterest.offsetTop-end.offsetTop));

        if(distanceToStart < distanceToEnd)
            start = charOfInterest;
        else
            end = charOfInterest;
    }

    _selectionStart = start;
    _selectionEnd = end;
}

-(void)mouseUp:(CPEvent)event {
	_contentLocationCache = NULL;
    _tallestElementCacheMap = NULL;
    _firstCharacterOnNextLineCacheMap = NULL;
    _lastCharacterOnPreviousLineCacheMap = NULL;

    [self redrawSelection];
    [self positionCaret];

    [self calculateSelectedRange];
    [self selectionDidChange];
}

-(CPArray)returnTarget:(CPEvent)event {
	var domEvent = [event _DOMEvent];
    var location = [[CPApp keyWindow] convertBaseToBridge:[event locationInWindow]];

    var target = domEvent.srcElement || domEvent.target;

    var content = _contentLayer._DOMElement;

    if(_contentLocationCache)
        var contentLocation = _contentLocationCache;
    else
        var contentLocation = locationInWindow(content);

    var relativeX = location.x - contentLocation.x + content.offsetLeft;
    var relativeY = location.y - contentLocation.y + content.offsetTop;

    if(relativeY >= content.lastChild.offsetTop + content.lastChild.offsetHeight)
    {
        var lastParagraph = content.lastChild;
        while(lastParagraph.nodeName == TextLayerUlElement.nodeName)
            lastParagraph = lastParagraph.lastChild;

        if(lastParagraph.nodeName == TextLayerLiElement.nodeName)
            lastParagraph = lastParagraph.firstChild;

        return { character: lastParagraph.lastChild.previousSibling, paragraph: lastParagraph };
    }

    if(relativeY < content.firstChild.offsetTop)
    {
        var firstParagraph = content.firstChild;
        while(firstParagraph.nodeName == TextLayerUlElement.nodeName)
            firstParagraph = firstParagraph.firstChild;

        if(firstParagraph.nodeName == TextLayerLiElement.nodeName)
            firstParagraph = firstParagraph.firstChild;

        return { character: NULL, paragraph: firstParagraph };
    }

    var element = content;
    while(element && element.firstChild.firstChild.nodeType != 3 && element.nodeName != TextLayerLiElement.nodeName)
        element = [self binarySearch:element.childNodes compare:targetComparator args:relativeY];


    if(element && element.nodeName == TextLayerLiElement.nodeName)
        element = element.firstChild;

    if(!element)
        return {character:NULL, paragraph:_contentLayer._DOMElement.firstChild};
    else if(element.firstChild.innerHTML == TextLayerNewLineElement.innerHTML)
        return { character: NULL, paragraph: element };

    var character = [self binarySearch:element.childNodes compare:paragraphComparator args:CGPointMake(relativeX,relativeY)];

    if(character)
    {
        if(relativeX - character.offsetLeft < character.offsetWidth / 2.0)
            return { character: character.previousSibling, paragraph: character.parentNode };

        return { character:character, paragraph:character.parentNode };
    }

    character = [self binarySearch:element.childNodes compare:targetComparator args:relativeY];
		
	if(character)//	CCEdit
	{//	CCEdit
	    var leftOffset = character.offsetLeft;
	    var leftCharacter = character.previousSibling;
	    while(leftCharacter && leftCharacter.offsetLeft < leftOffset)
	    {
	        leftOffset = leftCharacter.offsetLeft;
	        leftCharacter = leftCharacter.previousSibling;
	    }

	    if(relativeX < leftOffset)
	    {
	        if(leftCharacter && leftCharacter.innerHTML == TextLayerNewLineElement.innerHTML)
	            leftCharacter = leftCharacter.previousSibling;

	        character = leftCharacter;
	    }
	    else
	    {
	        leftOffset = character.offsetLeft;
	        while(character && character.nextSibling && character.nextSibling.offsetLeft > leftOffset)
	        {
	            character = character.nextSibling;
	            leftOffset = character.offsetLeft;
	        }

	        if(character && character.innerHTML == TextLayerNewLineElement.innerHTML)
	            character = character.previousSibling;
	    }
	}//	CCEdit

    return { character:character, paragraph:element };
}

-(id)binarySearch:(CPArray)array compare:(id)comparisonFunction args:(id)args {
	if(!array || !comparisonFunction) return NULL;

    var mid, c, first = 0, last = array.length - 1;
    while (first <= last)
    {
        mid = FLOOR((first + last) / 2);
          c = comparisonFunction(array[mid], args, self);



        if ( c > 0)
            first = mid + 1;
        else if ( c < 0)
            last = mid - 1;
        else
            return array[mid];
    }

    return NULL;
}

-(void)setNeedsSelectionRedraw {
	if (_needsSelectionRedraw || !_isFirstResponder)
        return;

    _needsSelectionRedraw = YES;

    [[CPRunLoop currentRunLoop] performSelector:@selector(redrawSelectionAndCaret) target:self argument:nil order:1000 modes:[CPDefaultRunLoopMode]];
}

-(void)redrawSelectionAndCaret {
	[self positionCaret];
	[self redrawSelection];
	
	_needsSelectionRedraw = NO;
}

-(void)positionCaret {
	if (!_isFirstResponder || _isThumbnail || ![self isEditing])
        return;

    if (![self hasSelection])
    {
        var previousCharacter = [self previousCharacter];

        if(previousCharacter)
            var nextCharacter = previousCharacter,
                offset = previousCharacter.offsetWidth;
        else
            var offset = 0,
                nextCharacter = [self nextCharacter];

        var location = locationInWindow(nextCharacter),
            frameLocation = locationInWindow(_contentLayer._DOMElement);
		
        [TextLayerSharedCaret setPosition:CGPointMake((location.x-frameLocation.x+offset)/_scale,(location.y-frameLocation.y)/_scale)];
        [TextLayerSharedCaret setBounds:CGRectMake(0.0,0.0,1.0/_scale,nextCharacter.offsetHeight/_scale)];

        if (_needsSelectionRedraw)
            [TextLayerSharedCaret _update];

        [self adoptSharedCaret];
    }

    [[self class] highlightCaret];
}

-(void)redrawSelection {
	[self redrawSelectionWhileStillSelecting:NO];
}

-(void)redrawSelectionWhileStillSelecting:(BOOL)isStillSelecting {
	if (!_isFirstResponder && [self hasSelection])
        return;

    if([self hasSelection])
    {
        if (!_selectionLayers)
        {
            var theClass = [self class];

            _selectionLayers =
                [[theClass takeSelectionLayerFromPool],[theClass takeSelectionLayerFromPool],[theClass takeSelectionLayerFromPool]];

            [self insertSublayer:_selectionLayers[0] atIndex:0];
            [self insertSublayer:_selectionLayers[1] atIndex:0];
            [self insertSublayer:_selectionLayers[2] atIndex:0];
        }

        if([self selectionIsInverted])
            var start = _selectionEnd, end = _selectionStart;
        else
            var start = _selectionStart, end = _selectionEnd;

        if(_contentLocationCache)
            var origin = _contentLocationCache;
        else
            var origin = locationInWindow(_contentLayer._DOMElement);

        if(!_characterDeltaX)
        {
            var characterLocal = locationInWindow(start);
            _characterDeltaX = characterLocal.x - origin.x - start.offsetLeft;
            _characterDeltaY = characterLocal.y - origin.y - start.offsetTop;
        }

        var highestStart = tallestCharacterOnSameLine(start, self);
        var highestEnd = tallestCharacterOnSameLine(end, self);

        var startLineHeight = highestStart.offsetHeight;
        var endLineHeight = highestEnd.offsetHeight;

        var startX = start.offsetLeft - _characterDeltaX;
        var startY = highestStart.offsetTop - _characterDeltaY;
        var endX = end.offsetLeft - _characterDeltaX;
        var endY = highestEnd.offsetTop - _characterDeltaY;

        if(start.innerHTML == TextLayerNewLineElement.innerHTML)
        {
            if(start.previousSibling)
                startX = start.previousSibling.offsetLeft + start.previousSibling.offsetWidth - _characterDeltaX;
            else
                startX = 0 - _characterDeltaX;
        }

        if(end.innerHTML == TextLayerNewLineElement.innerHTML)
        {
            if(end.previousSibling)
                endX = end.previousSibling.offsetLeft + end.previousSibling.offsetWidth - _characterDeltaX;
            else
                endX = 0 - _characterDeltaX;
        }

        var bounds = [CGRectMakeZero(),CGRectMakeZero(),CGRectMakeZero()],
            positions = [CGPointMakeZero(),CGPointMakeZero(),CGPointMakeZero()];


        if(startY == endY)
        {
            bounds[0].size = CGSizeMake((endX - startX) / _scale, startLineHeight / _scale);
            positions[0] = CGPointMake(startX / _scale, startY / _scale);
        }
        else
        {
            var contentFrame = [_contentLayer frame];

            bounds[0].size = CGSizeMake(CGRectGetWidth(contentFrame) - startX / _scale, startLineHeight / _scale);
            bounds[1].size = CGSizeMake(CGRectGetWidth(contentFrame), MAX(endY - startY - startLineHeight, 0) / _scale);
            bounds[2].size = CGSizeMake(endX / _scale, endLineHeight / _scale);

            positions[0] = CGPointMake(startX / _scale, startY / _scale);
            positions[1] = CGPointMake(CGRectGetMinX(contentFrame), (startY + startLineHeight) / _scale);
            positions[2] = CGPointMake(CGRectGetMinX(contentFrame), endY / _scale);
        }

        var count = _selectionLayers.length;

        while (count--)
        {
            [_selectionLayers[count] setBounds:bounds[count]];
            [_selectionLayers[count] setPosition:positions[count]];

            if (_needsSelectionRedraw)
                [_selectionLayers[count] _update];

        }

        [self orphanSharedCaret];
    }
    else if (_selectionLayers)
    {
        if (isStillSelecting)
        {
            [_selectionLayers[0] setBounds:CGRectMakeZero()];
            [_selectionLayers[1] setBounds:CGRectMakeZero()];
            [_selectionLayers[2] setBounds:CGRectMakeZero()];
        }
        else
        {
            [_selectionLayers[0] removeFromSuperlayer];
            [_selectionLayers[1] removeFromSuperlayer];
            [_selectionLayers[2] removeFromSuperlayer];

            var theClass = [self class];

            [theClass returnSelectionLayerToPool:_selectionLayers[0]];
            [theClass returnSelectionLayerToPool:_selectionLayers[1]];
            [theClass returnSelectionLayerToPool:_selectionLayers[2]];

            _selectionLayers = nil;
        }
    }
}

-(void)selectAll {
	_selectionStart = [self firstCharacterInParagraph:[self firstParagraph]];
    _selectionEnd = [self lastCharacterInParagraph:[self lastParagraph]];

    [self redrawSelection];

    [self calculateSelectedRange];
    [self selectionDidChange];
}

-(void)clearSelection {
	if (_selectionStart == _selectionEnd && _selectionStart == NULL)
        return;

    _selectionStart = NULL;
    _selectionEnd = NULL;

    [self redrawSelection];

    [self calculateSelectedRange];
    [self selectionDidChange];
}

-(void)deleteSelection {
	if (![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;

    if([self selectionIsInverted])
        var start = _selectionEnd, end = _selectionStart;
    else
        var start = _selectionStart, end = _selectionEnd;

    _selectionStart = _selectionEnd = NULL;

    var finalParagraph = start.parentNode;
    _previousCharacter = end.previousSibling;
    _currentParagraph = end.parentNode;

    start = start.previousSibling;

    while(start != _previousCharacter || _currentParagraph != finalParagraph)
        [self removeCharacter:kLeft stillDeleting:YES];

    _previousCharacter = start;

    _selectionRange.length = 0;

    [self redrawSelection];
    [self textDidChange];
}

-(BOOL)selectionIsInverted {
	if(!_selectionStart || !_selectionEnd)
        return NO;

    var tallestStart = tallestCharacterOnSameLine(_selectionStart, self);
    var tallestEnd = tallestCharacterOnSameLine(_selectionEnd, self);

    var startX = _selectionStart.offsetLeft;
    var startY = tallestStart.offsetTop;
    var endX = _selectionEnd.offsetLeft;
    var endY = tallestEnd.offsetTop;

    if(_selectionEnd.innerHTML == TextLayerNewLineElement.innerHTML)
    {
        if(_selectionEnd.previousSibling)
            endX = _selectionEnd.previousSibling.offsetLeft + _selectionEnd.previousSibling.offsetWidth
        else
            endX = 0;
    }

    if(_selectionStart.innerHTML == TextLayerNewLineElement.innerHTML)
    {
        if(_selectionStart.previousSibling)
            startX = _selectionStart.previousSibling.offsetLeft + _selectionStart.previousSibling.offsetWidth
        else
            startX = 0;
    }

    return ((startY == endY && startX > endX) || startY > endY);
}

-(BOOL)hasSelection {
	return _selectionStart != _selectionEnd;
}

-(char)characterForInspection {
	if([self hasSelection])
    {
        if([self selectionIsInverted])
            var start = _selectionEnd;
        else
            var start = _selectionStart;
    }
    else
        var start = _previousCharacter;

    if(!start) start = [self nextCharacter];

    return start;
}

-(void)resizeFontByFactor:(float)factor {
	if([self hasSelection])
    {
        if([self selectionIsInverted])
            var start = _selectionEnd, end = _selectionStart;
        else
            var start = _selectionStart, end = _selectionEnd;

        while(start && start != end)
        {
            [self applyFontSize:ROUND((parseInt(start.style.fontSize,10)/10)*factor) toElement:start];
            start = nextCharacter(start);
        }
    }
    else
        _typingTextAttributes.fontSize = ROUND(_typingTextAttributes.fontSize * aFactor);

    [self resize];
    [self textDidChange];
}

-(void)increaseBulletLevel {
	[self _changeBulletLevel:kRight];
}

-(void)decreaseBulletLevel {
	[self _changeBulletLevel:kLeft];
}

-(void)_changeBulletLevel:(int)direction {
	var range = [self typingCharacterRange],
        character = range.start,
        endCharacter = range.end,
        endParagraph = endCharacter ? endCharacter.parentNode : null;

    _previousCharacter = null;
    _currentParagraph = character.parentNode;
    while (_currentParagraph != endParagraph)
    {
        [self changeBulletLevel:direction];
        _currentParagraph = traverseNextNode(_currentParagraph);
    }

    if(_currentParagraph)
        [self changeBulletLevel:direction];

    if(character && character.innerHTML != TextLayerNewLineElement.innerHTML)
        _previousCharacter = character;

    [self resize];
    [self positionCaret];
    [self redrawSelection];

    [self updateTypingTextAttributes];

    [self textDidChange];
    [_selectionDelegate textLayerDidChangeTextAttributes:self];
}

/********************************************************/
/*											Section 1												*/
/********************************************************/

-(void)setTextScale:(float)scale {
	if(_scale != scale)
	{
		_contentLayer._DOMElement.style.fontSize = ROUND(scale * 100) + "%";
		_scale = scale;	
	}
	
    [self setNeedsSelectionRedraw];
}

-(JSObject)rtfObjectFrom:(DOMElement)startNode to:(DOMElement)endNode forCopy:(BOOL)copy {
	var textObject = {format:"rosstf", version:3.1, content:[]};
    var paragraph = startNode.parentNode;

    while(paragraph)
    {
        if(!copy || paragraph != startNode.parentNode)
            var depth = getBulletDepth(paragraph);
        else
            var depth = 0;

        var paragraphObject = {};
        textObject.content.push(paragraphObject);

        paragraphObject.list = depth > 0;
        paragraphObject.depth = depth;
        paragraphObject.ordered = false;
        paragraphObject.content = [];

        if(paragraph.style.textAlign && paragraph.style.textAlign != "")
            paragraphObject.align = paragraph.style.textAlign;

        if(paragraphObject.list && paragraph.parentNode.style.listStyleType && paragraph.parentNode.style.listStyleType != "")
            paragraphObject.ordered = paragraph.parentNode.style.listStyleType == TextLayerBulletStyleMaskValues[TextLayerNumberBulletStyleMask];

        var styleObject = NULL,
            previousStyle = NULL;

        if(paragraph == startNode.parentNode)
            var character = startNode;
        else
            var character = paragraph.firstChild;

        while(character && character != endNode)
        {
            var style = [self styleObjectForCharacter:character];

            if(!styleObject || (!compareStyles(style, previousStyle) && character.innerHTML != TextLayerNewLineElement.innerHTML))
            {
                styleObject = {};
                styleObject.content = "";
                styleObject.style = style;
                paragraphObject.content.push(styleObject);
            }

            if(character.firstChild.nodeValue != TextLayerNewLineElement.firstChild.nodeValue)
                styleObject.content += character.firstChild.nodeValue;

            previousStyle = style;

            character = character.nextSibling;
        }

        if(character != endNode)
            paragraph = traverseNextNode(paragraph);
        else
            break;
    }

    return textObject;
}

-(void)toStorageFormat {
	var textObject = null;

    try
    {
        textObject = [self rtfObjectFrom:[self firstCharacterInParagraph:[self firstParagraph]] to:[self lastCharacterInParagraph:[self lastParagraph]] forCopy:NO];
    }
    catch (e)
    {
        if(!TextLayerDidAlert)
        {
//            alert("Whoops.  We've encountered a bug. \n\n"
//                 +"We're trying our best to recover from it, but if you encounter "
//                 +"any problems with your document, please let us know!");
			  alert("We've encountered a bug");
        }

        TextLayerDidAlert = YES;

        try
        {
            var text = _contentLayer._DOMElement.innerText;
            textObject = [[self class] simpleRossTFObjectForString:text];

//            [BugReporter sendFeedback:("Error saving text: "+e+" text: "+text) title:"Text Save Error" delegate:nil];
        }
        catch (f)
        {
//            alert("We were unable to recover from the following errors: \n\n"+e+"\n\n"+f+
//                  "\n\nPlease send this feedback to feedback@280north.com");
			  alert("We were unable to recover from an error");
        }
    }

    return textObject;
}

+(JSObject)simpleRossTFObjectForString:(CPString)string {
	return CPJSObjectCreateWithJSON("{\"format\":\"rosstf\",\"version\":3,\"content\":[{\"list\":false,\"content\":"+
                                   "[{\"content\":\"" + string + "\",\"style\":{\"style\":0,\"size\":32}}]}]}");
}

-(void)insertFromStorageObject:(JSObject)textObject {
	_isInsertingFromStorageObject = YES;

    if([self hasSelection])
        [self deleteSelection];

    var paragraphs = textObject.content;
    var previousList, previousListLevel = 0;


    _typingTextAttributes = TextAttributesMake(0, 0, 0, 0, 0, 0, 0, 0);
    _typingTextProperties = TextAttributesMake("", "", "", "", "", "", "", "");

    for(var i=0; i<paragraphs.length; i++)
    {
        var currentParagraph = paragraphs[i];

        if(currentParagraph.content.length == 1 && currentParagraph.content[0].content == "")
            [self setFontSize:currentParagraph.content[0].style.size];

        if(i > 0)
            [self insertReturn];

        if(currentParagraph.list)
        {
            var depth = currentParagraph.depth - getBulletDepth(_currentParagraph);

            if(depth > 0)
                while(depth-- > 0)
                    [self changeBulletLevel:kRight];
            else
                while(depth++ < 0)
                    [self changeBulletLevel:kLeft];

            _currentParagraph.parentNode.style.listStyleType = currentParagraph.ordered ?
                                                                    TextLayerBulletStyleMaskValues[TextLayerNumberBulletStyleMask] :
                                                                    TextLayerBulletStyleMaskValues[TextLayerDiscBulletStyleMask];
        }
        else
        {
            var depth = getBulletDepth(_currentParagraph);

            while(depth-- > 0)
                [self changeBulletLevel:kLeft];
        }

        [self align:parseTextAlignment(currentParagraph.align)];

        var styleObjects = currentParagraph.content;

        for(var j=0; j<styleObjects.length; j++)
        {
            var style = styleObjects[j].style,
                characters = styleObjects[j].content;

            [self setFontFamily:style.name];
            [self setFontSize:style.size];

            [self setTextColor:((style.color) ? [CPColor colorWithHexString:style.color] : nil)];

            [self setState:style.bold forAttribute:"boldState" andProperty:"fontWeight" onStateValue:"bold" offStateValue:"normal"];
            [self setState:style.italic forAttribute:"italicState" andProperty:"fontStyle" onStateValue:"italic" offStateValue:"normal"];
            [self setState:style.underline forAttribute:"underlineState" andProperty:"textDecoration" onStateValue:"underline" offStateValue:"none"];

            for(var k=0; k<characters.length; k++)
            {
                var character = characters.charAt(k);

                if(character != "\r" && character != "\n")
                    [self insertCharacter:character stillInserting:YES];
            }
        }
    }

    if([TextLayerSharedCaret superlayer] == self)
    {
        [self resize];
        [self positionCaret];
        [self redrawSelection];
    }

    _isInsertingFromStorageObject = NO;

    [self calculateSelectedRange];

    [self clearTypingTextAttributes];
}

-(void)setHTMLFromStorageObject:(JSObject)text {
	_selectionStart = _selectionEnd = _currentParagraph = _previousCharacter = NULL;

    var newDocument = _contentLayer._DOMElement;
    newDocument.innerHTML="";

    _currentParagraph = TextLayerParagraphElement.cloneNode(false);
    _currentParagraph.appendChild(TextLayerNewLineElement.cloneNode(true));

    newDocument.appendChild(_currentParagraph);

    [self insertFromStorageObject:text];
}

-(void)styleObjectForCharacter:(DOMElement)character {
	var style = character.style,
        size = parseFontSize(character.style.fontSize),
        color = [[CPColor colorWithCSSString:character.style.color] hexString],
        fontFamily = parseFontFamily(character.style.fontFamily);

    return makeStyleObject(parseFontWeight(style.fontWeight), parseFontStyle(style.fontStyle), parseTextDecoration(style.textDecoration), size, color, fontFamily);
}

/********************************************************/
/*						Section 2						*/
/********************************************************/

-(void)selectionDidChange {
	[self updateTypingTextAttributes];
    [_selectionDelegate textLayerDidChangeSelection:self];
}

-(void)clearTypingTextAttributes {
	_typingTextAttributes = nil;
}

-(void)updateTypingTextAttributes {
	try{
    	var range = [self typingCharacterRange],

        character = range.start,
        endCharacter = range.end,

        paragraph = character.parentNode,
        endParagraph = endCharacter ? traverseNextNode(endCharacter.parentNode) : nil;
    } catch(e) { objj_debug_print_backtrace(); }
    if (character == endCharacter)
        endCharacter = nextCharacter(character);

    var defaultValue = [CPNull null];
    _typingTextAttributes = TextAttributesMake(defaultValue, defaultValue, defaultValue, 0, 0, 0, 0, 0);
    _typingTextProperties = TextAttributesMake("", "", "", "", "", "", "", "");

    while (character && character != endCharacter && (
        _typingTextAttributes.fontFamily ||
        _typingTextAttributes.fontSize ||
        _typingTextAttributes.boldState != TextAttributeMixedState ||
        _typingTextAttributes.italicState != TextAttributeMixedState ||
        _typingTextAttributes.underlineState != TextAttributeMixedState ))
    {
        var style = character.style;


        if (_typingTextAttributes.color == defaultValue)
        {
            _typingTextAttributes.color = [CPColor colorWithCSSString:character.style.color];
            _typingTextProperties.color = character.style.color;
        }


        var characterFontSize = parseFontSize(character.style.fontSize);

        if (_typingTextAttributes.fontSize == defaultValue)
        {
            _typingTextAttributes.fontSize = characterFontSize;
            _typingTextProperties.fontSize = characterFontSize;
        }
        else if (_typingTextAttributes.fontSize != characterFontSize)
            _typingTextAttributes.fontSize = nil;
        var fontWeight = character.style.fontWeight;
        if (!_typingTextProperties.boldState)
            _typingTextProperties.boldState = fontWeight;
        _typingTextAttributes.boldState |= parseFontWeight(fontWeight);
        var fontStyle = character.style.fontStyle;
        if (!_typingTextProperties.italicState)
            _typingTextProperties.italicState = fontStyle;
        _typingTextAttributes.italicState |= parseFontStyle(fontStyle);
        var textDecoration = character.style.textDecoration;
        if (!_typingTextProperties.underlineState)
            _typingTextProperties.underlineState = textDecoration;
        _typingTextAttributes.underlineState |= parseTextDecoration(textDecoration);
        var characterFontFamily = parseFontFamily(character.style.fontFamily);
        if (_typingTextAttributes.fontFamily == defaultValue)
        {
            _typingTextAttributes.fontFamily = characterFontFamily;
            _typingTextProperties.fontFamily = character.style.fontFamily;
        }
        else if (_typingTextAttributes.fontFamily != characterFontFamily)
            _typingTextAttributes.fontFamily = nil;
        character = nextCharacter(character);
    }
    while (paragraph && paragraph != endParagraph && (_typingTextAttributes.alignmentMask != TextLayerAllAlignmentMask || _typingTextAttributes.bulletStyleMask != TextLayerAllBulletStyleMask))
    {
        _typingTextAttributes.alignmentMask |= parseTextAlignment(paragraph.style.textAlign);
        _typingTextProperties.alignmentMask = paragraph.style.textAlign;
        if (paragraph.parentNode.nodeName == TextLayerLiElement.nodeName)
            if (paragraph.parentNode.style.listStyleType == "disc")
                _typingTextAttributes.bulletStyleMask |= TextLayerDiscBulletStyleMask;
            else if (paragraph.parentNode.style.listStyleType == "decimal")
                _typingTextAttributes.bulletStyleMask |= TextLayerNumberBulletStyleMask;
        paragraph = traverseNextNode(paragraph);
    }
}

-(void)setFontFamily:(id)aFontFamily {
	if (!aFontFamily)
        aFontFamily = _defaultTextAttributes.fontFamily;
    if (_typingTextAttributes.fontFamily == aFontFamily)
        return;
    if (![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    _typingTextAttributes.fontFamily = aFontFamily;
    _typingTextProperties.fontFamily = aFontFamily;
    var range = [self typingCharacterRange],
        character = range.start,
        endCharacter = range.end;
    while (character && character != endCharacter)
    {
        character.style.fontFamily = aFontFamily;
        character = nextCharacter(character);
    }
    if(character && character.innerHTML == TextLayerNewLineElement.innerHTML)
        character.style.fontFamily = aFontFamily;
    [self resize];
    [self positionCaret];
    [self redrawSelection];
    [self textDidChange];
    [_selectionDelegate textLayerDidChangeTextAttributes:self];
}

-(void)setFontSize:(id)aSize {
	if (_typingTextAttributes.fontSize == aSize)
        return;
    if (![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    _typingTextAttributes.fontSize = aSize;
    _typingTextProperties.fontSize = aSize;
    var range = [self typingCharacterRange],
        character = range.start,
        endCharacter = range.end;
    while (character && character != endCharacter)
    {
        setFontSize(character, aSize);
        character = nextCharacter(character);
    }
    if(character && character.innerHTML == TextLayerNewLineElement.innerHTML)
        setFontSize(character, aSize);
    [self resize];
    [self positionCaret];
    [self redrawSelection];
    [self textDidChange]
    [_selectionDelegate textLayerDidChangeTextAttributes:self];
}

-(void)setTextColor:(id)aColor {
	if (!aColor)
        aColor == _defaultTextAttributes.color;
    if (_typingTextAttributes.color == aColor)
        return;
    var range = [self typingCharacterRange],
        cssValue = [aColor cssString];
    _typingTextAttributes.color = aColor;
    _typingTextProperties.color = cssValue;
    var character = range.start,
        endCharacter = range.end;
    while (character && character != endCharacter)
    {
        character.style.color = cssValue;
        character = nextCharacter(character);
    }
    if(character && character.innerHTML == TextLayerNewLineElement.innerHTML)
        character.style.color = cssValue;
    [self textDidChange]
    [_selectionDelegate textLayerDidChangeTextAttributes:self];
}

-(void)align:(id)anAlignmentMask {
	if (!anAlignmentMask)
        anAlignmentMask = _defaultTextAttributes.alignmentMask;
    if (_typingTextAttributes.aligmentMask == anAlignmentMask)
        return;
    if (![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    _typingTextAttributes.alignmentMask = anAlignmentMask;
    var range = [self typingCharacterRange],
        cssValue = TextLayerAlignmentMaskValues[anAlignmentMask];
    _typingTextProperties.alignment = cssValue;
    var range = [self typingCharacterRange],
        paragraph = range.start.parentNode,
        endParagraph = range.end ? traverseNextNode(range.end.parentNode) : nil;
    while (paragraph && paragraph != endParagraph)
    {
        paragraph.style.textAlign = cssValue;
        _typingTextProperties.alignmentMask = cssValue;
        paragraph = traverseNextNode(paragraph);
    }
    [self redrawSelection];
    [self positionCaret];
    [self textDidChange]
    [_selectionDelegate textLayerDidChangeTextAttributes:self];
}

-(void)bulletStyle:(id)aBulletStyleMask {
	if (![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    _typingTextAttributes.bulletStyleMask = aBulletStyleMask;
    var range = [self typingCharacterRange],
        cssValue = TextLayerBulletStyleMaskValues[aBulletStyleMask];
    _typingTextProperties.bulletStyle = cssValue;
    var range = [self typingCharacterRange],
        paragraph = range.start.parentNode,
        endParagraph = range.end ? traverseNextNode(range.end.parentNode) : nil,
        shouldDecreaseBulletLevel = YES;
    while (paragraph && paragraph != endParagraph)
    {
        var listNode = paragraph.parentNode;
        if (listNode.nodeName == TextLayerLiElement.nodeName)
        {
            if (listNode.style.listStyleType != cssValue)
                shouldDecreaseBulletLevel = NO;
            listNode.style.listStyleType = cssValue;
        }
        else
        {
            _currentParagraph = paragraph;
            _previousCharacter = NULL;
            [self changeBulletLevel:kRight];
            paragraph = _currentParagraph;
            paragraph.parentNode.style.listStyleType = cssValue;
            shouldDecreaseBulletLevel = NO;
        }
        paragraph = traverseNextNode(paragraph);
    }
    if (!_previousCharacter && range.start && range.start.innerHTML != TextLayerNewLineElement.innerHTML)
        _previousCharacter = range.start;
    if (shouldDecreaseBulletLevel)
        [self decreaseBulletLevel];
    [self redrawSelection];
    [self positionCaret];
    [self textDidChange]
    [_selectionDelegate textLayerDidChangeTextAttributes:self];
}

-(JSObject)typingCharacterRange {
	var range = { start:nil, end:nil };
    if (_isFirstResponder || _isInsertingFromStorageObject)
    {
        if ([self hasSelection])
        {
            if([self selectionIsInverted])
            {
                range.start = _selectionEnd;
                range.end = _selectionStart;
            }
            else
            {
                range.start = _selectionStart;
                range.end = _selectionEnd;
            }
        }
        else
        {
            range.start = [self characterForInspection];
            range.end = range.start;
        }
    }
    else
    {
        range.start = [self firstCharacterInParagraph:[self firstParagraph]];
        range.end = nil;
    }
    return range;
}

-(JSObject)typingTextAttributes {
	if (!_typingTextAttributes)
        [self updateTypingTextAttributes];
    return _typingTextAttributes;
}

-(void)setDefaultTextAttributes:(id)attributes {
	if (_defaultTextAttributes == attributes)
        return;
    var initial = _defaultTextAttributes == nil,
        fontFamily = attributes.fontFamily,
        fontSize = attributes.fontSize,
        color = [attributes.color cssString],
        fontWeight = attributes.boldState == TextAttributeOnState ? "bold" : "normal",
        fontStyle = attributes.italicState == TextAttributeOnState ? "italic" : "normal",
        textDecoration = attributes.underlineState == TextAttributeOnState ? "underline" : "none",
        textAlign = TextLayerAlignmentMaskValues[attributes.alignmentMask];
    if (!initial)
    {
        var oldDefaultFontFamily = _defaultTextAttributes.fontFamily,
            oldDefaultFontSize = _defaultTextAttributes.fontSize,
            oldDefaultColor = [_defaultColor cssString],
            oldDefaultFontWeight = _defaultTextAttributes.boldState == TextAttributeOnState ? "bold" : "normal",
            oldDefaultFontStyle = _defaultTextAttributes.italicState == TextAttributeOnState ? "italic" : "normal",
            oldDefaultTextDecoration = _defaultTextAttributes.underlineState == TextAttributeOnState ? "underline" : "none",
            oldDefaultTextAlign = TextLayerAlignmentMaskValues[_defaultTextAttributes.alignmentMask];
    }
    var style = _contentLayer._DOMElement.style;
    style.fontFamily = fontFamily;
    style.fontWeight = fontWeight;
    style.fontStyle = fontStyle;
    style.color = color;
    var character = [self firstCharacterInParagraph:[self firstParagraph]];
    while (character)
    {
        var style = character.style;
        if (initial || parseFontFamily(style.fontFamily) == oldDefaultFontFamily)
            style.fontFamily = fontFamily;
        if (initial || parseFontSize(style.fontSize) == oldDefaultFontSize)
            setFontSize(character, fontSize);
        if (initial || colorsAreEqual(style.color, oldDefaultColor))
            style.color = color;
        if (initial || style.fontWeight == oldDefaultFontWeight)
            style.fontWeight = fontWeight;
        if (initial || style.fontStyle == oldDefaultFontStyle)
            style.fontStyle = fontStyle;
        if (initial || style.textDecoration == oldDefaultTextDecoration)
            style.textDecoration = textDecoration;
        character = nextCharacter(character);
    }
    var paragraph = [self firstParagraph];
    while (paragraph)
    {
        if (initial || paragraph.style.textAlign == oldDefaultTextAlign)
            paragraph.style.textAlign = textAlign;
        paragraph = traverseNextNode(paragraph);
    }
    _defaultTextAttributes = TextAttributesMakeCopy(attributes);
    [self updateTypingTextAttributes];
}

-(void)defaultTextAttributes {
	return _defaultTextAttributes;
}

-(void)setState:(int)aState forAttribute:(CPString)anAttribute andProperty:(CPString)aProperty onStateValue:(CPString)anOnStateValue offStateValue:(CPString)anOffStateValue {
	if (!aState)
        aState = _defaultTextAttributes[anAttribute];
    if (aState == _typingTextAttributes[anAttribute])
        return;
    var cssValue = aState == TextAttributeOnState ? anOnStateValue : anOffStateValue;
    _typingTextAttributes[anAttribute] = aState;
    _typingTextProperties[anAttribute] = cssValue;
    var range = [self typingCharacterRange],
        character = range.start,
        endCharacter = range.end;
    while (character && character != endCharacter)
    {
        character.style[aProperty] = cssValue;
        character = nextCharacter(character);
    }
    if(character && character.innerHTML == TextLayerNewLineElement.innerHTML)
        character.style[aProperty] = cssValue;
    [self resize];
    [self redrawSelection];
    [self positionCaret];
    [self textDidChange]
    [_selectionDelegate textLayerDidChangeTextAttributes:self];
}

-(void)bold:(id)sender {
	if ((_typingTextAttributes.boldState == TextAttributeOnState) || ![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    [self setState:TextAttributeOnState forAttribute:"boldState" andProperty:"fontWeight" onStateValue:"bold" offStateValue:"normal"];
}

-(void)unbold:(id)sender {
	if ((_typingTextAttributes.boldState == TextAttributeOffState) || ![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    [self setState:TextAttributeOffState forAttribute:"boldState" andProperty:"fontWeight" onStateValue:"bold" offStateValue:"normal"];
}

-(void)italicize:(id)sender {
	if ((_typingTextAttributes.italicState == TextAttributeOnState) || ![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    [self setState:TextAttributeOnState forAttribute:"italicState" andProperty:"fontStyle" onStateValue:"italic" offStateValue:"normal"];
}

-(void)unitalicize:(id)sender {
	if ((_typingTextAttributes.italicState == TextAttributeOffState) || ![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    [self setState:TextAttributeOffState forAttribute:"italicState" andProperty:"fontStyle" onStateValue:"italic" offStateValue:"normal"];
}

-(void)underline:(id)sender {
	if ((_typingTextAttributes.underlineState == TextAttributeOnState) || ![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    [self setState:TextAttributeOnState forAttribute:"underlineState" andProperty:"textDecoration" onStateValue:"underline" offStateValue:"none"];
}

-(void)ununderline:(id)sender {
	if ((_typingTextAttributes.underlineState == TextAttributeOffState) || ![self shouldChangeTextInRange:[self selectedRange] replacementString:nil])
        return;
    [self setState:TextAttributeOffState forAttribute:"underlineState" andProperty:"textDecoration" onStateValue:"underline" offStateValue:"none"];
}

-(void)applyFontSize:(id)aFontSize toElement:(DOMElement)anElement {
	setFontSize(anElement, aFontSize);
}

-(CPRange)selectedRange {
	return _selectionRange;
}

-(void)calculateSelectedRange {
	if (_isFirstResponder && ![self hasSelection] && !_previousCharacter && _currentParagraph == [self firstParagraph])
        return CPMakeRange(0, 0);
    var range = [self typingCharacterRange];
    _selectionRange = CPMakeRange(range.start == range.end ? 1 : 0, 0);
    var character = [self firstCharacter];
    while (character != range.start)
    {
        ++_selectionRange.location;
        character = nextCharacter(character);
    }
    if (!range.end)
        range.end = [self lastCharacterInParagraph:[self lastParagraph]];
    while (character != range.end)
    {
        ++_selectionRange.length;
        character = nextCharacter(character);
    }
}

-(void)setSelectedRange:(CPRange)aRange {
	aRange = CPMakeRangeCopy(aRange);
    _selectionRange = CPMakeRangeCopy(aRange);
    _selectionStart = NULL;
    _selectionEnd = NULL;
    var character = [self firstCharacter];
    if (aRange.length == 0)
    {
        if (aRange.location-- == 0)
        {
            _previousCharacter = nil;
            _currentParagraph = [self firstParagraph];
        }
        else
        {
            while (aRange.location--)
                character = nextCharacter(character);
            _previousCharacter = character;
            _currentParagraph = _previousCharacter.parentNode;
        }
    }
    else
    {
        while (character && !_selectionStart)
            if (!(aRange.location--))
                _selectionStart = character;
            else
                character = nextCharacter(character);
        while (character && !_selectionEnd)
            if (!aRange.length--)
                _selectionEnd = character;
            else
                character = nextCharacter(character);
    }
    [self positionCaret];
    [self redrawSelection];
    [self selectionDidChange];
}

-(BOOL)shouldChangeTextInRange:(CPRange)aRange replacementString:(CPString)aString {
	if (!_isInsertingFromStorageObject)
    {
        [_undoManager registerUndoWithTarget:self selector:@selector(setSelectedRange:) object:CPMakeRangeCopy(aRange)];
        [_undoManager registerUndoWithTarget:self selector:@selector(setTextWidget_:) object:[self textWidget]];
    }
    return YES;
}

//	------------
//	CCEdits
//	------------

-(BOOL)supportsEditingMode
{
	return YES;
}

-(void)beginEditing
{
	[super beginEditing];
	[self adoptSharedCaret];
}

-(void)endEditing
{
	[super endEditing];
	[self orphanSharedCaret];
}

-(void)editingControl:(CCWidgetEditingControl)editingControl didOffsetByPoint:(CGPoint)point
{
	[super editingControl:editingControl didOffsetByPoint:point];
	[self setTextScale:_scale];
}

-(void)setDefaultColor:(CPColor)color
{
	var attribs = [self defaultTextAttributes];
	[self setDefaultTextAttributes:TextAttributesMake("Arial", 12.0, color, TextAttributeOffState, TextAttributeOffState, TextAttributeOffState, TextLayerLeftAlignmentMask, TextLayerDiscBulletStyleMask)]
}

-(void)slideThemeDidChangeToTheme:(CCSlideTheme)theme
{
	[self setDefaultColor:[theme fontColor]];
}

// -(void)editingControlDidFinishEditing:(CCWidgetEditingControl)editingControl
// {
// 	//	Do nothing
// }

@end

takeStyleFrom= function(aDOMElement, properties)
{
    var style = aDOMElement.style;
    style.fontFamily = properties.fontFamily;
    style.color = properties.color;
    style.fontWeight = properties.boldState;
    style.fontStyle = properties.italicState;
    style.textDecoration = properties.underlineState;
}
var setFontSize = function(anElement, aSize)
{
	
    anElement.style.fontSize = ROUND(aSize * 10.0) + "%";
    if(anElement.nodeName == TextLayerLiElement.nodeName)
        anElement.style.marginLeft = MIN(1, (aSize/52.0)) + "em";
    if(!anElement.previousSibling && anElement.parentNode && anElement.parentNode.className == TextLayerLineSpacerElement.className)
    {
        setFontSize(anElement.parentNode.parentNode, aSize);
        setFontSize(anElement.parentNode, ((1.0 / aSize) * 100.0));
    }
    if(anElement.nextSibling && anElement.nextSibling.innerHTML == TextLayerNewLineElement.innerHTML)
        setFontSize(anElement.nextSibling, aSize);
}
var parseFontSize = function(aFontSizeString)
{
    return ROUND(parseInt(aFontSizeString, 10) / 10.0);
}
var parseFontFamily = function(aFontFamily)
{
    var firstCharacter = aFontFamily.charAt(0);
    if (firstCharacter == '\'' || firstCharacter == '"')
        return aFontFamily.substr(1, aFontFamily.length - 2);
    return aFontFamily;
}
var parseFontWeight = function(aFontWeight)
{
    if (!aFontWeight || !aFontWeight.length)
        return nil;
    if (aFontWeight == "bold")
        return TextAttributeOnState;
    return TextAttributeOffState;
}
var parseFontStyle = function(aFontStyle)
{
    if (!aFontStyle || !aFontStyle.length)
        return nil;
    if (aFontStyle == "italic")
        return TextAttributeOnState;
    return TextAttributeOffState;
}
var parseTextDecoration = function(aTextDecoration)
{
    if (!aTextDecoration || !aTextDecoration.length)
        return nil;
    if (aTextDecoration == "underline")
        return TextAttributeOnState;
    return TextAttributeOffState;
}
var parseTextAlignment = function(aTextAlignmentString)
{
    switch (aTextAlignmentString)
    {
        case "left": return TextLayerLeftAlignmentMask;
        case "center": return TextLayerCenterAlignmentMask;
        case "right": return TextLayerRightAlignmentMask;
        case "justify": return TextLayerJustifiedAlignmentMask;
    }
    return 0;
}
var colorsAreEqual = function(lhsColor, rhsColor)
{
    return lhsColor && rhsColor && lhsColor.replace(/\s/g, "") == rhsColor.replace(/\s/g, "");
}
var makeStyleObject = makeStyleObject= function(boldState, italicState, underlineState, fontSize, fontColor, fontFamily)
{
    var object = {};

    if (fontSize)
        object.size = fontSize;

    if(fontColor)
        object.color = fontColor;

    if(fontFamily)
        object.name = fontFamily;

    if (boldState)
        object.bold = boldState;

    if (italicState)
        object.italic = italicState;

    if (underlineState)
        object.underline = underlineState;

    return object;
}

var compareStyles = compareStyles= function(lhsStyle, rhsStyle)
{
    if( lhsStyle && rhsStyle &&
        lhsStyle.bold == rhsStyle.bold && lhsStyle.italic == rhsStyle.italic && lhsStyle.underline == rhsStyle.underline &&
        lhsStyle.size == rhsStyle.size && lhsStyle.name == rhsStyle.name && lhsStyle.color == rhsStyle.color)
        return YES;

    return NO;
}

var nextCharacter = nextCharacter= function(character)
{
    if(character)
    {
        if(character.nextSibling)
        {
            return character.nextSibling;
        }
        else
        {
            var nextParagraph = traverseNextNode(character.parentNode);
            if(nextParagraph)
            {
                return nextParagraph.firstChild;
            }
            else
            {
                return NULL;
            }
        }
    }

    return NULL;
}

var previousCharacter = previousCharacter= function(character)
{
    if(character)
    {
        if(character.previousSibling)
            return character.previousSibling;
        else
        {
            var previousParagraph = traversePreviousNode(character.parentNode);
            if(previousParagraph)
                return previousParagraph.lastChild;
            else
                return NULL;
        }
    }

    return NULL;
}

var traverseNextNode = traverseNextNode= function(aNode)
{
    while(aNode && !aNode.nextSibling && aNode.parentNode.className != "root")
        aNode = aNode.parentNode;

    if(aNode)
        aNode = aNode.nextSibling;

    while(aNode && aNode.firstChild && aNode.nodeName == TextLayerUlElement.nodeName)
        aNode = aNode.firstChild;

    if(aNode && aNode.nodeName == TextLayerLiElement.nodeName)
        return aNode.firstChild;

    return aNode;
}

var traversePreviousNode = traversePreviousNoded= function(aNode)
{
    while(aNode && !aNode.previousSibling && aNode.parentNode.className != "root")
        aNode = aNode.parentNode;

    if(aNode)
        aNode = aNode.previousSibling;

    while(aNode && aNode.lastChild && aNode.nodeName == TextLayerUlElement.nodeName)
        aNode = aNode.lastChild;

    if(aNode && aNode.nodeName == TextLayerLiElement.nodeName)
        return aNode.firstChild;

    return aNode;
}

var getBulletDepth = getBulletDepth= function(paragraph)
{
    if (paragraph.className != TextLayerLineSpacerElement.className)
        return 0;

    if(paragraph.parentNode.nodeName != TextLayerLiElement.nodeName)
        return 0;

    var count = 0;
    while(paragraph.parentNode.parentNode.nodeName == TextLayerUlElement.nodeName)
    {
        paragraph = paragraph.parentNode;
        count++;
    }

    return count;
}

var getComputedProperty = getComputedProperty= function(property, element)
{
    return document.defaultView.getComputedStyle(element, "").getPropertyValue(property);
}

var tallestCharacterOnSameLine = tallestCharacterOnSameLine= function(character, self)
{
    if(character.previousSibling && character.innerHTML == TextLayerNewLineElement.innerHTML)
        character = character.previousSibling;

    if(self._tallestElementCacheMap)
    {
        if(!character.__address)
		{
            character.__address = objj_generateObjectUID;
		}
        else if(self._tallestElementCacheMap[character.__address])
		{
            return self._tallestElementCacheMap[character.__address];
		}
    }

    var height = character.offsetHeight, left = character.offsetLeft,
         right = character.offsetLeft, fontSize = character.style.fontSize;

    var current = character.previousSibling, result = character;

    while(current && current.offsetLeft < left)
    {
        if(current.offsetHeight > height && current.innerHTML != TextLayerNewLineElement.innerHTML)
        {
            result = current;
            height = current.offsetHeight;
        }

        left = current.offsetLeft;
        current = current.previousSibling;
    }

    if(current && current.innerHTML == TextLayerNewLineElement.innerHTML)
        current = null;

    if(current && current.nextSibling && current.offsetTop == current.nextSibling.offsetTop && current.nextSibling == result)
        result = current.nextSibling.nextSibling;

    if(self._lastCharacterOnPreviousLineCacheMap)
        self._lastCharacterOnPreviousLineCacheMap[character.__address] = current;

    current = character.nextSibling;
    while(current && current.offsetLeft > right)
    {
        if(current.offsetHeight > height && current.innerHTML != TextLayerNewLineElement.innerHTML)
        {
            result = current;
            height = current.offsetHeight;
        }

        right = current.offsetLeft;
        current = current.nextSibling;
    }

    if(current && current.innerHTML == TextLayerNewLineElement.innerHTML)
        current = null;

    if(current && current.previousSibling && current.offsetTop == current.previousSibling.offsetTop && current.previousSibling == result)
        result = current.previousSibling.previousSibling;

    if(self._firstCharacterOnNextLineCacheMap)
        self._firstCharacterOnNextLineCacheMap[character.__address] = current;

    if(self._tallestElementCacheMap)
        self._tallestElementCacheMap[character.__address] = result;

    return result;
}

var targetComparator = targetComparator= function(element, relativeY, self)
{
    return comparator(element, CPPointMake(0, relativeY), self, false);
}

var paragraphComparator = paragraphComparator= function(element, point, self)
{
    return comparator(element, point, self, true);
}

var comparator = comparator= function(element, point, self, checkHorizontal)
{
    if(checkHorizontal || element.firstChild.nodeType == 3)
    {
        var highestElement = tallestCharacterOnSameLine(element, self);

        var lastCharacterOnPreviousLine = self._lastCharacterOnPreviousLineCacheMap[element.__address];
        var firstCharacterOnNextLine = self._firstCharacterOnNextLineCacheMap[element.__address];

        if(!lastCharacterOnPreviousLine)
        {
            if(element.parentNode.nodeName == TextLayerParagraphElement.nodeName)
                var topBarrier = highestElement.offsetTop;
            else
                var topBarrier = element.parentNode.parentNode.offsetTop;
        }
        else
            var topBarrier = lastCharacterOnPreviousLine.offsetTop + lastCharacterOnPreviousLine.offsetHeight;

        if(!firstCharacterOnNextLine)
        {
            var parentNode = element.parentNode;


            if (parentNode.className == TextLayerParagraphElement.className)
                var bottomBarrier = highestElement.offsetTop + highestElement.offsetHeight;
            else
                var bottomBarrier = element.parentNode.parentNode.offsetTop + element.parentNode.parentNode.offsetHeight;
        }
        else
        {
            var first = firstCharacterOnNextLine;
            if(first.offsetTop == first.previousSibling.offsetTop)
                var bottomBarrier = first.offsetTop + first.offsetHeight - first.previousSibling.offsetHeight;
            else
                var bottomBarrier = first.offsetTop;
        }
    }
    else
    {
        var bottomBarrier = element.offsetTop + element.offsetHeight;
        var topBarrier = element.offsetTop;
    }


    if(point.y >= bottomBarrier)
        return 1;
    else if (point.y < topBarrier)
        return -1;
    else if (checkHorizontal && point.x < element.offsetLeft)
        return -1;
    else if (checkHorizontal && point.x >= element.offsetLeft + element.offsetWidth)
        return 1;
    else
        return 0;
}

var locationInWindow = locationInWindow= function(element)
{
    var x=0, y=0;
    while(element && element.offsetLeft >= 0 && element.offsetTop >= 0)
    {
        x += element.offsetLeft;
        y += element.offsetTop;
        element = element.offsetParent;
    }
    return CPPointMake(x, y);
}
