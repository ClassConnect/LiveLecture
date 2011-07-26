/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLQuizWidget.j"

var _toprightimage = nil;

@implementation LLQuizWidgetLayerAnswer : CALayer
{
	LLQuizWidgetLayer _owner @accessors(property=owner);
	BOOL _selected @accessors(property=selected,getter=isSelected);
	TextLayer _text;
	CPString _answer;
	CPImage _selectedImage;
	CGRect _imageRect;
	unsigned _numResponses @accessors(property=numberOfResponses);
	TextLayer _numResponsesLayer;
	BOOL _isTeacher @accessors(property=isTeacher);
}

-(id)initAsTeacher:(BOOL)isTeacher withOwner:(LLQuizWidgetLayer)owner
{
	if(self = [super init])
	{
		[self setAnchorPoint:CGPointMakeZero()];
		_text = [[TextLayer alloc] init];
		[_text setFontSize:20];
		[_text setIsThumbnail:YES];
		[self addSublayer:_text];
		
		//	The code to make sure the text layer isnt editable is based on _isThumbnail, so lets use that
		[_text setIsThumbnail:YES];
//		_isTeacher = (isTeacher) ? YES : NO;
		_isTeacher = isTeacher;
		_owner = owner;
		if(_isTeacher && _owner._isPresenting)
		{
			_numResponsesLayer = [[TextLayer alloc] init];
			[_numResponsesLayer setFontSize:20];
			[_numResponsesLayer setIsThumbnail:YES];
			[_numResponsesLayer setBounds:CGRectMake(0,0,40,40)];
			[_numResponsesLayer setPosition:CGPointMake(0,0)];
			[_numResponsesLayer setTextColor:[CPColor redColor]];
			[_numResponsesLayer align:4];
			[self addSublayer:_numResponsesLayer];
		}
		else
		{
			[self setSelected:NO];
		}
	}
	return self;
}

-(void)setAnswerText:(CPString)string
{
	[_text setStringValue:string];
	_answer = string;
}

-(void)setSelected:(BOOL)selected
{
	if(selected == _selected && ([_selectedImage loadStatus] == CPImageLoadStatusCompleted))
		return;
	_selected = selected;
	var path = [[CPBundle mainBundle] pathForResource:((_selected) ? "LLQuizWidgetLayerAnswerYes.png" : "LLQuizWidgetLayerAnswerNo.png")];
	_selectedImage = [[CPImage alloc] initWithContentsOfFile:path];
	[_selectedImage setDelegate:self];
}

-(void)setNumberOfResponses:(unsigned)newNum
{
	_numResponses = newNum;
	
	[_numResponsesLayer setStringValue:""+_numResponses];
}

-(void)drawInContext:(CGContext)context
{
	if(_owner._isPresenting && (_isTeacher || _owner._isThumbnail))
	{
		//	If we are showing the answers, we want to make the rect above the
		//	numResponsesLayer to be clear, if we aren't showing the answers,
		//	it should be gray
		CGContextSetFillColor(context,[_owner showsAnswers] ? [CPColor clearColor] : [CPColor grayColor]);
		CGContextSetStrokeColor(context,[_owner showsAnswers] ? [CPColor clearColor] : [CPColor whiteColor]);
		CGContextFillRect(context,CGRectMake(0,0,40,40));
		CGContextStrokeRect(context,CGRectMake(0,0,40,40));
		[_numResponsesLayer setHidden:![_owner showsAnswers]];
	}
	//	The rect that the image draws in 
	if([_selectedImage loadStatus] == CPImageLoadStatusCompleted)
	{
		CGContextDrawImage(context,CGRectMake(4,0,32,32),_selectedImage);
	}
}

-(void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	[_text setPosition:CGPointMake(45,0)];
	[_text setBounds:CGRectMake(0,0,bounds.size.width-40,bounds.size.height)];
}

-(void)imageDidLoad:(CPImage)image
{
	[self setNeedsDisplay];
}

-(void)setTextScale:(float)scale
{
	[_text setTextScale:scale];
	[_numResponsesLayer setTextScale:scale];
}

-(void)slideThemeDidChangeToTheme:(CCSlideTheme)theme
{
	[_text slideThemeDidChangeToTheme:theme];
}

@end

@implementation LLQuizWidgetLayer : CCWidgetLayer
{
	float _textScaleCache;
	TextLayer _questionLayer;
	CPArray _answerLayers;
	
	BOOL _showsAnswers @accessors(property=showsAnswers);
	CALayer _showAnswersLink;
	CCSlideTheme _themeCache;
}

+(id)initialize
{
	if([self class] != [LLQuizWidgetLayer class])
		return;
}

-(id)initWithWidget:(CCWidget)widget
{
	if(self = [self init])
	{
		[self setWidget:widget];
		_textScaleCache = 1;
	}
	return self;
}

-(id)init
{
	if(self = [super init])
	{	
		_questionLayer = [[TextLayer alloc] init];
		[_questionLayer setIsThumbnail:YES];
		[_questionLayer setFontSize:20];
		//[_questionLayer setPosition:CGPointMake(0,40)];
		
		[self addSublayer:_questionLayer];
		[self setBackgroundColor:[CPColor colorWithHexString:"EEEEEE"]];
	}
	return self;
}

-(void)setQuestionText:(CPString)text
{
	[_questionLayer setStringValue:text];
}

-(void)setTextScale:(float)scale
{
	_textScaleCache = scale;
	[_questionLayer setTextScale:scale];
	[_answerLayers makeObjectsPerformSelector:@selector(setTextScale:) withObject:scale];
	[_showAnswersLink setTextScale:scale];
}

-(void)setIsPresenting:(BOOL)isPresenting
{
	if(_isPresenting == isPresenting)
		return;
	_isPresenting = isPresenting;
	
	[self makeAnswerLayers];
}

-(void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	if(!_widget)
		return;
	[_questionLayer setBounds:CGRectMake(0,0,[self bounds].size.width,([self bounds].size.height - 40) / ([_widget numberOfPossibleAnswers]+1))];
	[self makeAnswerLayers];
}

-(void)setWidget:(CCWidget)widget
{
	[super setWidget:widget];
	[_questionLayer setBounds:CGRectMake(0,0,[self bounds].size.width,([self bounds].size.height - 40) / ([_widget numberOfPossibleAnswers]+1))];
	[self setQuestionText:[widget question]];
	//	4 is the mask for center alignment
	[_questionLayer align:4];
	//	Make sure the layout updates
	[self makeAnswerLayers];
	[self setNeedsDisplay];
}

-(void)mouseDown:(CCEvent)event
{
	//	This should only be sent when the user double clicked to get
	//	into editing mode, but we don't want to do anything during 'editing'
	//	mode, just use it as a way to detect double clicks, so we ignore the
	//	event.
	if([self isEditing])
		return;
	if([[LLUser currentUser] isTeacher])
	{
		//	All we care about is if they hit the show answers link
		//	
		//	To figure this out, we convert the point to the link's 
		//	coordinate system, then use the CGRectContainsPoint method
		var presController = [LLPresentationController sharedController],
			slideLayer = [[presController mainSlideView] slideLayer],
			linkPoint = [slideLayer convertPoint:[event slideLayerPoint] toLayer:_showAnswersLink];
		if(CGRectContainsPoint([_showAnswersLink bounds],linkPoint))
		{
			[self setShowsAnswers:!_showsAnswers];
			[_showAnswersLink setSelected:_showsAnswers];
			[_answerLayers makeObjectsPerformSelector:@selector(setNeedsDisplay)];
		}
		return;
	}
	var oldAnswer = [_widget selectedAnswer];
	var pointInCurrentCoords = [self convertPoint:[event slideLayerPoint] fromLayer:[self superlayer]],
		selectedIndex = -1;
	for(var i = 0 ; i < [_answerLayers count] ; i++)
	{
		var current = _answerLayers[i];
		if(CGRectContainsPoint([current bounds],[self convertPoint:pointInCurrentCoords toLayer:current]))
		{
			selectedIndex = i;
			break;
		}
	}
	if(selectedIndex != -1)
	{
		if([_widget selectedAnswer] != -1)
			[[_answerLayers objectAtIndex:[_widget selectedAnswer]] setSelected:NO];
		[[_answerLayers objectAtIndex:selectedIndex] setSelected:YES];
		[_widget setSelectedAnswer:selectedIndex];
		if(_isPresenting)
		{
			[self sendData:{
				oldAnswer:oldAnswer,
				newAnswer:selectedIndex
			}];
		}
	}
}

-(BOOL)supportsEditingMode
{
	return YES;
}

-(void)beginEditing
{
	[super beginEditing];
	if(!_isPresenting && window.LLInspectorPanel != undefined)
	{
		//	[[CPApplication sharedApplication] orderFrontInspectorPanel];
		[[CPApplication sharedApplication] orderFrontWidgetFormPanel];
		[[CPApplication sharedApplication] runModalForWindow:[LLWidgetFormPanel sharedPanel]];
		[[LLWidgetFormPanel sharedPanel] setMode:LLWidgetFormPanelModeEdit];
		[[LLWidgetFormPanel sharedPanel] setWidget:_widget];
		[[LLWidgetFormPanel sharedPanel] setCallback:function(widget){
			[self setWidget:_widget];
		}];
	}
	[self endEditing];
}

-(void)slideThemeDidChangeToTheme:(CCSlideTheme)theme
{
	//	When the theme changes we want to change the text of the quiz widget
	[_questionLayer slideThemeDidChangeToTheme:theme];
	[_showAnswersLink slideThemeDidChangeToTheme:theme];
	[_answerLayers makeObjectsPerformSelector:@selector(slideThemeDidChangeToTheme:) withObject:theme];
	_themeCache = theme;
}

-(void)drawInContext:(CGContext)context
{
	//	Update the number of responses on the layers
	for(var i = 0 ; i < [_answerLayers count] ; i++)
	{
		[_answerLayers[i] setNumberOfResponses:[_widget numberOfResponsesForAnswerAtIndex:i]];
	}
	//	Draw the 'quiz' image on the top right
	if([_toprightimage loadStatus] == CPImageLoadStatusCompleted)
		CGContextDrawImage(context,CGRectMake([self bounds].size.width - 87,[self bounds].size.height - 69,87,69),_toprightimage);
	else
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidLoad:) name:CPImageDidLoadNotification object:_toprightimage];
	
	
}

-(void)imageDidLoad:(CPImage)image
{
	[[CPNotificationCenter defaultCenter] removeObserver:self name:CPImageDidLoadNotification object:_toprightimage];
	[self setNeedsDisplay];
}

-(void)makeAnswerLayers
{
	var topHeight = 40;
	var rectHeight = ([self bounds].size.height - topHeight)/([_widget numberOfPossibleAnswers]+1),
		rectBounds = CGRectMake(0,0,[self bounds].size.width,rectHeight),
		currentHeight = topHeight+rectHeight; // topHeight for show answers link, rectHeight for question
	[_answerLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	[_answerLayers removeAllObjects];
	//	Before we do the Answer Layers, lets make the 'show answers' button
	if([[LLUser currentUser] isTeacher] && !_isThumbnail)
	{
		if(_showAnswersLink)
		{
			[_showAnswersLink removeFromSuperlayer];
			_showAnswersLink = nil
		}
		_showAnswersLink = [[LLQuizWidgetLayerAnswer alloc] initAsTeacher:NO withOwner:self];
		[_showAnswersLink setAnswerText:"Show Answers"];
		[_showAnswersLink setSelected:NO];
		[_showAnswersLink setBounds:CGRectMake(0,0,300,40)];
		[_showAnswersLink setPosition:CGPointMake(CGRectGetWidth([self bounds])-300,rectHeight)];
		[_showAnswersLink setTextScale:_textScaleCache];
		//	TODO: This is just a patchy solution to the fact that I remake the answer layers every
		//	time the user stretches the bounds. What I really need to do is reposition all the layers
		[self addSublayer:_showAnswersLink];
	}
	_answerLayers = [CPArray array];
	var isTeacher = [[LLUser currentUser] isTeacher];
	for(var i = 0 ; i < [_widget numberOfPossibleAnswers] ; i++)
	{
		var current = [[LLQuizWidgetLayerAnswer alloc] initAsTeacher:isTeacher withOwner:self];
		[current setAnswerText:[_widget answerAtIndex:i]];
		[current setBounds:rectBounds];
		[current setPosition:CGPointMake(0,currentHeight)];
		[_answerLayers addObject:current];
		if(isTeacher)
			[current setNumberOfResponses:[_widget numberOfResponsesForAnswerAtIndex:i]];
		if(i == [_widget selectedAnswer])
			[current setSelected:YES];
		[self addSublayer:current];
		[current setTextScale:_textScaleCache];
		[current setNeedsDisplay];
		currentHeight += rectHeight;
	}
	//	TODO: This is just a patchy solution to the fact that I remake the answer layers every
	//	time the user does something, event when only one of them changed.
	if(_themeCache)
	{
		[_showAnswersLink slideThemeDidChangeToTheme:_themeCache];
		[_answerLayers makeObjectsPerformSelector:@selector(slideThemeDidChangeToTheme:) withObject:_themeCache];
	}
}

-(void)updateAfterReceivingData:(JSObject)data
{
	for(var i = 0 ; i < [_widget numberOfPossibleAnswers] ; i++)
		[_answerLayers[i] setNumberOfResponses:[_widget numberOfResponsesForAnswerAtIndex:i]];
}

@end