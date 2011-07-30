@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation LLQuizWidgetForm : CCWidgetForm
{
	CPTextField _questionField;
	CPArray _answerFields;
	
	CPDictionary _keyViews;
}

-(id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		//	The default setup should make a question and 3 answers
		var firstView = [[CPView alloc] initWithFrame:CGRectMake(0,0,[self frameSize].width,1)],
			secondView = [[CPView alloc] initWithFrame:CGRectMake(0,0,[self frameSize].width,1)];
		[firstView setBackgroundColor:[CPColor grayColor]];
		[secondView setBackgroundColor:[CPColor grayColor]];
		
		var questionLabel = [CPTextField labelWithTitle:@"Question"],
			answerLabel = [CPTextField labelWithTitle:@"Answers"];
		
		[questionLabel setFont:[CPFont systemFontOfSize:24]];
		[questionLabel setBackgroundColor:[CPColor whiteColor]];
		[questionLabel sizeToFit];
		[answerLabel setFont:[CPFont systemFontOfSize:24]];
		[answerLabel setBackgroundColor:[CPColor whiteColor]];
		[answerLabel sizeToFit];
		
		_questionField = [CPTextField textFieldWithStringValue:@"" placeholder:@"Ask a question..." width:445];
		[_questionField setDelegate:self];
		
		[questionLabel setFrameOrigin:CGPointMake(20,20)];
		[_questionField setFrameOrigin:CGPointMake(17,57)];
		[answerLabel setFrameOrigin:CGPointMake(20,87+26)];
		
		var formCenterX = [self center].x;
		[firstView setCenter:CGPointMake(formCenterX,[questionLabel center].y)];
		[secondView setCenter:CGPointMake(formCenterX,[answerLabel center].y)];
		
		[self addSubview:firstView];
		[self addSubview:questionLabel];
		[self addSubview:_questionField];
		[self addSubview:secondView];
		[self addSubview:answerLabel];
		
		_answerFields = [ ];
		for(var i = 0 ; i < 3 ; i++)
			[self _addNewTextFieldAtIndex:i];
	}
	return self;
}

-(void)_yValueForTextFieldAtIndex:(int)index
{
	return 124 /**/+ 26 /**/+ (34 * index);
}

-(void)_addNewTextFieldAtIndex:(int)index
{
	var current = [CPTextField textFieldWithStringValue:@"" placeholder:@"Add an answer..." width:445];
	[current setFrameOrigin:CGPointMake(17,[self _yValueForTextFieldAtIndex:index])];
	[current setDelegate:self];
	[self addSubview:current];
	_answerFields[index] = current;
	[current setNextKeyView:_questionField];
	[((index) ? _answerFields[index-1] : _questionField) setNextKeyView:current];
	[self _extendView];
}

-(void)_extendView
{
	var lowestPoint = CGRectGetMaxY([_answerFields[[_answerFields count]-1] frame]) + 20;
	if(lowestPoint > CGRectGetMaxY([self bounds]))
		[self setFrameSize:CGSizeMake([self frameSize].width,lowestPoint)];
}

/*/
 *	Reimplemented from CCWidgetForm
/*/

-(void)updateFormForNewWidget
{
	[_questionField setStringValue:[_widget question]];
	//	Make any text fields that we need
	if([_widget numberOfPossibleAnswers] > 2)
	{
		for(var i = 3 ; i < Math.min([_widget numberOfPossibleAnswers]+1,10) ; i++)
		{
			[self _addNewTextFieldAtIndex:i];
		}
	}
	for(var i = 0 ; i < [_widget numberOfPossibleAnswers] ; i++)
	{
		//	Set the answers
		if(i >= [_answerFields count])
			continue;
		[_answerFields[i] setStringValue:[_widget answerAtIndex:i]];
	}
}

-(void)commit
{
	[_widget setQuestion:[_questionField stringValue]];
	//	We need to get an array of all of the string values of the text fields
	//	keeping in mind that the user might not have them in any sort of order
	//	(aka, fields might be empty, but fields after them might have strings)
	var answerStrings = [ ];
	for(var i = 0 ; i < [_answerFields count] ; i++)
		if([_answerFields[i] stringValue] != "")
			[answerStrings addObject:[_answerFields[i] stringValue]];
	[_widget setAnswers:answerStrings];
}

/*/
 *	CPTextFieldDelegate
/*/

-(void)controlTextDidFocus:(CPTextField)textField
{
	textField = [textField object];
	if(textField != _questionField)
	{
		var answerCount = [_answerFields count];
		if(textField == _answerFields[answerCount-1] && answerCount < 10)
			[self _addNewTextFieldAtIndex:[_answerFields count]];
	
		//	ALRIGHT LISTEN UP SHITLORDS, HERE IS THE PLAN
		//	For some reason, Cappuccino keeps recalculating the key view loop
		//	(incorrectly), and it won't fucking stop. So every time a text field
		//	gets focus, I make sure the next key view is the right one. FUCK BOI!
		var tfIndex = [_answerFields indexOfObject:textField];
		[textField setNextKeyView:(tfIndex != 9) ? _answerFields[tfIndex+1] : _questionField];
		[((tfIndex) ? _answerFields[tfIndex-1] : _questionField) setNextKeyView:textField];
	}
	var topleftpoint = [textField frameOrigin],
		bottomleftpoint = [textField frameOrigin],
		superviewbounds = [[self superview] bounds];
	//	Make the bottom left point not a liar, and actually point to the bottom left point
	bottomleftpoint.y += [textField frameSize].height;
	//	Scroll to the selected view
	if(!CGRectContainsPoint(superviewbounds,topleftpoint) || !CGRectContainsPoint(superviewbounds,bottomleftpoint))
		[[self superview] scrollToPoint:[textField frameOrigin]];
}

@end