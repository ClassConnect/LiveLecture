/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLQuizWidget.j"
@import "CCHighchartLayer.j"

var _toprightimage = nil;
var _textColor = [CPColor blackColor];

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
		[_text setTextColor:_textColor];
		_isTeacher = isTeacher;
		_owner = owner;
		// if(_isTeacher && _owner._isPresenting)
		// {
		// 	_numResponsesLayer = [[TextLayer alloc] init];
		// 	[_numResponsesLayer setFontSize:20];
		// 	[_numResponsesLayer setIsThumbnail:YES];
		// 	[_numResponsesLayer setBounds:CGRectMake(0,0,40,40)];
		// 	[_numResponsesLayer setPosition:CGPointMake(0,0)];
		// 	[_numResponsesLayer setTextColor:[CPColor redColor]];
		// 	[_numResponsesLayer align:4];
		// 	[self addSublayer:_numResponsesLayer];
		// }
		// else
		// {
			[self setSelected:NO];
		// }
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
	// if(_owner._isPresenting && (_isTeacher || _owner._isThumbnail))
	// {
	// 	//	If we are showing the answers, we want to make the rect above the
	// 	//	numResponsesLayer to be clear, if we aren't showing the answers,
	// 	//	it should be gray
	// 	CGContextSetFillColor(context,[_owner showsGraph] ? [CPColor clearColor] : [CPColor grayColor]);
	// 	CGContextSetStrokeColor(context,[_owner showsGraph] ? [CPColor clearColor] : [CPColor whiteColor]);
	// 	CGContextFillRect(context,CGRectMake(0,0,40,40));
	// 	CGContextStrokeRect(context,CGRectMake(0,0,40,40));
	// 	[_numResponsesLayer setHidden:![_owner showsGraph]];
	// }
	//	The rect that the image draws in 
	if([self _shouldDrawImage] && [_selectedImage loadStatus] == CPImageLoadStatusCompleted)
		CGContextDrawImage(context,CGRectMake(4,0,32,32),_selectedImage);
}

-(void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	var point = [self _shouldDrawImage] ? CGPointMake(45,0) : CGPointMake(0,0);
	var rect = CGRectMake(0,0,bounds.size.width-point.x,bounds.size.height);
	[_text setPosition:point];
	[_text setBounds:rect];
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

//	Helper to shorten ifs
-(BOOL)_shouldDrawImage
{
	//	We should draw the image if we are in editing mode, or if we are
	//	presenting and we are a student
	return (!_owner._isPresenting) || (!_isTeacher)
}

@end

@implementation LLQuizWidgetLayer : CCWidgetLayer
{
	float _textScaleCache;
	TextLayer _questionLayer;
	CPArray _answerLayers;
	
	BOOL _showsGraph @accessors(property=showsGraph);
	LLQuizWidgetAnswerLayer _showGraphLink;
	CCHighchartLayer _graphLayer;
}

+(id)initialize
{
	if([self class] != [LLQuizWidgetLayer class])
		return;
	var path = [[CPBundle bundleForClass:self] pathForResource:"LLQuizWidgetBackgroundText.png"];
	_toprightimage = [[CPImage alloc] initWithContentsOfFile:path size:CGSizeMake(87,69)];
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
		[_questionLayer setFontSize:24];
		[_questionLayer setTextColor:_textColor];
		[_questionLayer setPosition:CGPointMake(20,0)];
		
		[self addSublayer:_questionLayer];
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
	[_showGraphLink setTextScale:scale];
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
	var bs = [self bounds].size,
		rectHeight = (bs.height - 40) / ([_widget numberOfPossibleAnswers]+1);
	[_questionLayer setBounds:CGRectMake(0,0,bs.width - 40,rectHeight)];
	//	Graph layer should take up the entire thing minus one rect (question)
	//	and 40 pixels for the showGraph link
	[[self _graphLayer] setBounds:CGRectMake(0,0,bs.width-20,bs.height-rectHeight-40-10)];
	[[self _graphLayer] setPosition:CGPointMake(10,rectHeight+40)];
	[self makeAnswerLayers];
}

-(void)setWidget:(CCWidget)widget
{
	[super setWidget:widget];
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
	if(!_isPresenting)
		return;
	if([[LLUser currentUser] isTeacher])
	{
		//	All we care about is if they hit the show answers link
		//	
		//	To figure this out, we convert the point to the link's 
		//	coordinate system, then use the CGRectContainsPoint method
		var presController = [LLPresentationController sharedController],
			slideLayer = [[presController mainSlideView] slideLayer],
			linkPoint = [slideLayer convertPoint:[event slideLayerPoint] toLayer:_showGraphLink];
		if(CGRectContainsPoint([_showGraphLink bounds],linkPoint))
		{
			[self setShowsGraph:!_showsGraph];
			[_showGraphLink setSelected:_showsGraph];
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
	if(!_isPresenting && window.LLWidgetFormPanel != undefined)
	{
		[[CPApplication sharedApplication] orderFrontWidgetFormPanel];
		[[CPApplication sharedApplication] runModalForWindow:[LLWidgetFormPanel sharedPanel]];
		[[LLWidgetFormPanel sharedPanel] setMode:LLWidgetFormPanelModeEdit];
		[[LLWidgetFormPanel sharedPanel] setWidget:_widget];
		[[LLWidgetFormPanel sharedPanel] setCallback:function(widget){
			[self setWidget:_widget];
			[[LLPresentationController sharedController] mainSlideContentDidChange];
		}];
	}
	[self endEditing];
}

-(void)drawInContext:(CGContext)context
{
	//	Update the number of responses on the layers
	for(var i = 0 ; i < [_answerLayers count] ; i++)
	{
		[_answerLayers[i] setNumberOfResponses:[_widget numberOfResponsesForAnswerAtIndex:i]];
	}
	/*/
	 *	Most of this code was gotten from StackOverflow. Thanks porneL
	 *	http://stackoverflow.com/questions/1031930/how-is-a-rounded-rect-view-with-transparency-done-on-iphone/1031936#1031936
	/*/
	var size = [self bounds].size,
		radius = 20,
		qheight = [_questionLayer bounds].size.height - 1;
	//	Make the area below the question a lighter gray than the other
	CGContextSetStrokeColor(context,[CPColor colorWithHexString:"666"]);
	CGContextSetFillColor(context, [CPColor colorWithHexString:"CCC"]);
	CGContextMoveToPoint(context, 0, qheight);
	CGContextMoveToPoint(context, 0, radius);
	CGContextAddLineToPoint(context, 0, size.height - radius);
	CGContextAddArc(context, radius, size.height - radius, radius, Math.PI, Math.PI / 2, 0); //STS fixed
	CGContextAddLineToPoint(context, size.width - radius, size.height);
	CGContextAddArc(context, size.width - radius, size.height - radius, radius, Math.PI / 2, 0, 0);
	CGContextAddLineToPoint(context, size.width, qheight);
	CGContextAddLineToPoint(context,0,qheight);
	CGContextFillPath(context);
	CGContextStrokePath(context);
	// Make the area below it 
	CGContextSetFillColor(context,[CPColor colorWithHexString:"AAA"]);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context,0,qheight);
	CGContextAddLineToPoint(context,size.width,qheight);
	CGContextAddLineToPoint(context, size.width, radius);
	CGContextAddArc(context, size.width - radius, radius, radius, 0, -Math.PI / 2, 0);
	CGContextAddLineToPoint(context, radius, 0);
	CGContextAddArc(context, radius, radius, radius, -Math.PI / 2, Math.PI, 0);
	CGContextAddLineToPoint(context,0,qheight);
	CGContextFillPath(context);
	CGContextStrokePath(context);
	
	//	Draw the 'quiz' image on the top right
	if([_toprightimage loadStatus] == CPImageLoadStatusCompleted)
		CGContextDrawImage(context,CGRectMake([self bounds].size.width - 87,0,87,69),_toprightimage);
	else
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:CPImageDidLoadNotification object:_toprightimage];
}

-(void)makeAnswerLayers
{
	var topHeight = 40;
	var inset = 10;
	var rectHeight = ([self bounds].size.height - topHeight-10)/([_widget numberOfPossibleAnswers]+1),
		rectBounds = CGRectMake(0,0,[self bounds].size.width-(2*inset),rectHeight),
		currentHeight = topHeight+rectHeight; // topHeight for show answers link, rectHeight for question
	[_answerLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	[_answerLayers removeAllObjects];
	//	Before we do the Answer Layers, lets make the 'show answers' button
	if([[LLUser currentUser] isTeacher] && !_isThumbnail)
	{
		if(_showGraphLink)
		{
			[_showGraphLink removeFromSuperlayer];
			_showGraphLink = nil
		}
		_showGraphLink = [[LLQuizWidgetLayerAnswer alloc] initAsTeacher:NO withOwner:self];
		[_showGraphLink setAnswerText:"Show Graph"];
		[_showGraphLink setSelected:NO];
		[_showGraphLink setBounds:CGRectMake(0,0,250,40)];
		[_showGraphLink setPosition:CGPointMake(CGRectGetWidth([self bounds])-250,rectHeight)];
		[_showGraphLink setTextScale:_textScaleCache];
		//	TODO: This is just a patchy solution to the fact that I remake the answer layers every
		//	time the user stretches the bounds. What I really need to do is reposition all the layers
		[self addSublayer:_showGraphLink];
	}
	_answerLayers = [CPArray array];
	var isTeacher = [[LLUser currentUser] isTeacher];
	for(var i = 0 ; i < [_widget numberOfPossibleAnswers] ; i++)
	{
		var current = [[LLQuizWidgetLayerAnswer alloc] initAsTeacher:isTeacher withOwner:self];
		[current setAnswerText:[_widget answerAtIndex:i]];
		[current setBounds:rectBounds];
		[current setPosition:CGPointMake(inset,currentHeight)];
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
}

-(void)setShowsGraph:(BOOL)showsGraph
{
	if(showsGraph == _showsGraph)
		return;
	_showsGraph = showsGraph;
	[[self _graphLayer] setHidden:!showsGraph];
	[_answerLayers makeObjectsPerformSelector:@selector(setHidden:) withObject:showsGraph];
	[[self _graphLayer] setNeedsDisplay];
}

-(void)_graphLayer
{
	if(!_graphLayer)
	{
		_graphLayer = [CCHighchartLayer new];
		[_graphLayer setBounds:[self bounds]];
		[_graphLayer setPosition:CGPointMake(0,0)];
		[self addSublayer:_graphLayer];
		[_graphLayer setHidden:!_showsGraph];
		[_graphLayer setData:[_widget highchartData]];
	}
	return _graphLayer;
}

-(void)updateAfterReceivingData:(JSObject)data
{
	var g = [self _graphLayer];
	if(data.oldAnswer != -1)
		[g updateDatapointAtIndex:data.oldAnswer toValue:[_widget numberOfResponsesForAnswerAtIndex:data.oldAnswer] redraw:NO];
	[g updateDatapointAtIndex:data.newAnswer toValue:[_widget numberOfResponsesForAnswerAtIndex:data.newAnswer]];
}

@end

@implementation LLQuizWidget (CCHighchartAdditions)

-(void)highchartData
{
	var array = [ ];
	for(var i = 0 ; i < [_answers count]; i++)
	{
		var j;
		if(i == _selectedAnswer)
		{
			//	Make the sliced thing
			j = {
				name: _answers[i],
				y: _answerCount[i],
				sliced: true,
				selected: true
			}
		}
		else
		{
			j = [_answers[i], _answerCount[i]];
		}
		array[i] = j;
	}
	return array;
}

@end