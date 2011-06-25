/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLQuizWidget.j"

var _toprightimage = nil;

function LLQuizWidgetLayerResponse(widgetIndex,oldanswer)
{
	var quizwidget = [[[LLPresentationController sharedController] currentSlide] widgetAtIndex:widgetIndex];
	if([quizwidget class] != [LLQuizWidget class])
	{
		//	TODO: Send an error report
		alert("ERRAWR! LLQuizWidgetLayerResponse");
		return;
	}
	[[LLRTE sharedInstance] widget:[LLQuizWidget class] sendData:[widgetIndex,oldanswer,[quizwidget selectedAnswer]]];
//	[quizwidget setSelectedAnswer:answerIndex];
}

@implementation LLQuizWidgetLayerAnswer : CALayer
{
	BOOL _selected @accessors(property=selected,getter=isSelected);
	TextLayer _text;
	CPImage _selectedImage;
	CGRect _imageRect;
	unsigned _numResponses @accessors(property=numberOfResponses);
	TextLayer _numResponsesLayer;
	BOOL _isTeacher @accessors(isTeacher);
}

-(id)initAsTeacher:(BOOL)isTeacher
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
		_isTeacher = isTeacher;
		if(_isTeacher)
		{
			_numResponsesLayer = [[TextLayer alloc] init];
			[_numResponsesLayer setFontSize:20];
			[_numResponsesLayer setIsThumbnail:YES];
			[_numResponsesLayer setBounds:CGRectMake(0,0,40,40)];
			[_numResponsesLayer setPosition:CGPointMake(0,0)];
			[_numResponsesLayer setTextColor:[CPColor redColor]];
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
//	if(/*newNum == _numResponses ||*/ ![[LLUser currentUser] isTeacher])
//		return;
	_numResponses = newNum;
	
	[_numResponsesLayer setStringValue:""+_numResponses];
}

-(void)drawInContext:(CGContext)context
{
	if(_isTeacher)
		return;
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

@implementation LLQuizWidgetLayer : CCWidgetLayer {
	float _textScaleCache;
	TextLayer _questionLayer;
	CPArray _answerLayers;
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
		[self addSublayer:_questionLayer];
		[self setBackgroundColor:[CPColor colorWithHexString:"EEEEEE"]];
	}
	return self;
}

-(void)setQuestionText:(CPString)text
{
	[_questionLayer setStringValue:text];
}

-(void)makeAnswerLayers
{
	var rectHeight = [self bounds].size.height/([_widget numberOfPossibleAnswers]+1),
		rectBounds = CGRectMake(0,0,[self bounds].size.width,rectHeight);
	[_answerLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	[_answerLayers removeAllObjects];
	_answerLayers = [CPArray array];
	var isTeacher = ((_isPresenting) ? [[LLUser currentUser] isTeacher] : NO);
	for(var i = 0 ; i < [_widget numberOfPossibleAnswers] ; i++)
	{
		var current = [[LLQuizWidgetLayerAnswer alloc] initAsTeacher:isTeacher];
		[current setAnswerText:[_widget answerAtIndex:i]];
		[current setBounds:rectBounds];
		//	We put it at i+1 because the question is the same height as the answers, and the answers are below the question
		[current setPosition:CGPointMake(0,rectHeight*(i + 1))];
		[_answerLayers addObject:current];
		if(NO)
		{
			[current setNumberOfResponses:[_widget numberOfResponsesForAnswerAtIndex:i]];
		}
		if(i == [_widget selectedAnswer])
			[current setSelected:YES];
		[self addSublayer:current];
		[current setTextScale:_textScaleCache];
	}
}

-(void)setTextScale:(float)scale
{
	_textScaleCache = scale;
	[_questionLayer setTextScale:scale];
	[_answerLayers makeObjectsPerformSelector:@selector(setTextScale:) withObject:scale];
}

-(void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	if(!_widget)
		return;
	[_questionLayer setBounds:CGRectMake(0,0,[self bounds].size.width,[self bounds].size.height / ([_widget numberOfPossibleAnswers]+1))];
	[self makeAnswerLayers];
}

-(void)setWidget:(CCWidget)widget
{
	[super setWidget:widget];
	[_questionLayer setBounds:CGRectMake(0,0,[self bounds].size.width,[self bounds].size.height / ([_widget numberOfPossibleAnswers]+1))];
	[self setQuestionText:[widget question]];
	//	4 is the mask for center alignment
	[_questionLayer align:4];
	//	Make sure the layout updates
	[self makeAnswerLayers];
	[self setNeedsDisplay];
}

-(void)mouseDown:(CCEvent)event
{
	var oldAnswer = [_widget selectedAnswer];
	var pointInCurrentCoords = [self convertPoint:[event slideLayerPoint] fromLayer:[self superlayer]],
		rectHeight = [self bounds].size.height / ([_widget numberOfPossibleAnswers]+1),
		selectedIndex = parseInt(pointInCurrentCoords.y / rectHeight)-1;
	if(selectedIndex != -1)
	{
		if([_widget selectedAnswer] != -1)
			[[_answerLayers objectAtIndex:[_widget selectedAnswer]] setSelected:NO];
		[[_answerLayers objectAtIndex:selectedIndex] setSelected:YES];
		[_widget setSelectedAnswer:selectedIndex];
		if(_isPresenting)
		{
			var widgetIndex = [[[LLPresentationController sharedController] currentSlide] indexOfWidget:_widget];
			LLQuizWidgetLayerResponse(widgetIndex,oldAnswer);
		}
	}
}

-(BOOL)supportsEditingMode
{
	return YES;
}

-(void)slideThemeDidChangeToTheme:(CCSlideTheme)theme
{
	//	When the theme changes we want to change the text of the quiz widget
	[_questionLayer slideThemeDidChangeToTheme:theme];
	[_answerLayers makeObjectsPerformSelector:@selector(slideThemeDidChangeToTheme:) withObject:theme];
}

-(void)drawInContext:(CGContext)context
{
	//	THIS IS A COMMENT!
	//	Update the number of responses on the layers
	for(var i = 0 ; i < [_answerLayers count] ; i++)
	{
		[_answerLayers[i] setNumberOfResponses:[_widget numberOfResponsesForAnswerAtIndex:i]];
	}
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

@end