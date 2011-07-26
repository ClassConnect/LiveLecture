/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 *
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"

@implementation LLQuizWidget : CCWidget
{
	CPString _question @accessors(property=question);
	CPArray _answers @accessors(property=answers);
	
	int _selectedAnswer @accessors(property=selectedAnswer);
	CPArray _answerCount;
}

-(id)initWithWidget:(LLQuizWidget)widget
{
	if(self = [super initWithWidget:widget])
	{
		[self setQuestion:[[widget question] copy]];
		[self setAnswers:[[CPArray alloc] initWithArray:[widget answers] copyItems:YES]];
		[self setSelectedAnswer:[[widget selectedAnswer] copy]];
		_answerCount = [widget._answerCount copy];
	}
	return self;
}

-(id)initWithQuestion:(CPString)question possibleAnswers:(CPArray)answers
{
	if(self = [self init])
	{
		_question = question;
		_answers = answers;
		for(var i = 0 ; i < [_answers count] ; i++)
		{
			_answerCount[i] = 0;
		}
	}
	return self;
}

-(id)init
{
	if(self = [super init])
	{
		_question = "";
		_answers = [CPArray array];
		_answerCount = [CPArray array];
		_selectedAnswer = -1;
	}
	return self;
}

-(BOOL)isEqual:(LLQuizWidget)rhs
{
	return	([super isEqual:rhs]						&&
			 [_question isEqual:rhs._question]			&&
			 [_answers isEqual:rhs._answers]			&&
		 	 [_answerCount isEqual:rhs._answerCount]	&&			
			 _selectedAnswer == rhs._selectedAnswer);
}

-(id)copy
{
	return [[LLQuizWidget alloc] initWithWidget:self];
}

-(void)setAnswers:(CPArray)answers
{
	_answers = answers;
	_answerCount = [ ];
	for(var i = 0 ; i < [_answers count] ; i++)
	{
		_answerCount[i] = 0;
	}
}

-(void)addAnswer:(CPString)answer
{
	[_answers addObject:answer];
	[_answerCount addObject:0];
}

-(void)removeAnswer:(CPString)answer
{
	[self removeAnswerAtIndex:[_answers indexOfObject:answer]];
}

-(void)removeAnswerAtIndex:(unsigned)index
{
	[_answers removeObjectAtIndex:index];
	[_answerCount removeObjectAtIndex:index];
}

-(CPString)answerAtIndex:(int)index
{
	return [_answers objectAtIndex:index];
}

-(int)numberOfPossibleAnswers
{
	return [_answers count];
}

-(void)changeAnswerAtIndex:(int)index toAnswer:(CPString)newAnswer
{
	[_answers replaceObjectAtIndex:index withObject:newAnswer];
}

-(int)numberOfResponsesForAnswerAtIndex:(int)index
{
	return [_answerCount objectAtIndex:index];
}

-(void)incrementAnswerCountAtIndex:(int)index
{
	//	Not sure when this might show up, but I figure it is safer this way
	if(index == -1)
		return;
	
	_answerCount[index] = _answerCount[index]+1;
}

-(void)decrementAnswerCountAtIndex:(int)index
{
	if(index == -1)
		return;
	
	_answerCount[index] = _answerCount[index]-1;
}

-(void)toStorage
{
	_question = escape(_question);
	for(var i = 0 ; i < [_answers count]; i++)
	{
		_answers[i] = escape(_answers[i]);
//		_answerCount[i] = [CPNumber numberWithInt:_answerCount[i]];
	}
}

-(void)fromStorage
{
	_question = unescape(_question);
	for(var i = 0 ; i < [_answers count] ; i++)
	{
		_answers[i] = unescape(_answers[i]);
//		_answerCount[i] = [_answerCount[i] intValue];
	}
}

-(id)initWithCoder:(CPCoder)coder
{
	if(self = [super initWithCoder:coder])
	{	
		_question = unescape([coder decodeObjectForKey:@"question"]);
		_answers = [ ];
		var escapedAnswers = [coder decodeObjectForKey:@"answers"];
		for(var i = 0 ; i < [escapedAnswers count] ; i++)
			_answers[i] = unescape(escapedAnswers[i]);
		_selectedAnswer = [[coder decodeObjectForKey:@"selectedAnswer"] intValue];
		_answerCount = [ ];
		for(var i = 0  ; i < [_answers count] ; i++)
			_answerCount[i] = 0;
	}
	return self;
}

-(void)encodeWithCoder:(CPCoder)coder
{
	[super encodeWithCoder:coder];
	[coder encodeObject:escape(_question) forKey:@"question"];
	var escapedAnswers = [ ];
	for(var i = 0 ; i < [_answers count] ; i++)
		escapedAnswers[i] = escape(_answers[i]);
	[coder encodeObject:escapedAnswers forKey:@"answers"];
	[coder encodeObject:[CPNumber numberWithInt:_selectedAnswer] forKey:@"selectedAnswer"];
}

@end

@implementation LLQuizWidget (LLRTEAdditions)

-(BOOL)allowedToSendData:(JSObject)data
{
	//	Only students should send data
	return ![[LLUser currentUser] isTeacher];
}

-(CPString)receiverChannelForData:(JSObject)data
{
	return kLLRTEChannelTeachers;
}

-(void)didReceiveData:(JSObject)data
{	
	var	oldAnswer = data.oldAnswer,
		answerIndex = data.newAnswer;
	
	[self incrementAnswerCountAtIndex:answerIndex];
	[self decrementAnswerCountAtIndex:oldAnswer];
}

@end