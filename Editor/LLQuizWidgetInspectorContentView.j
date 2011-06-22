@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "CCWidgetInspectorContentView.j"
@import "../LLSharedUtilities/LLQuizWidget.j"

@implementation LLQuizWidgetInspectorContentView : CCWidgetInspectorContentView
{
	CPTextField _questionField;
	CPTableView _answerTableView;
}

+(CGSize)contentSize
{
	return CGSizeMake(250,300);
}

-(void)createView
{
	var questionLabel = [CPTextField labelWithTitle:"Quesiton:"],
		answerLabel = [CPTextField labelWithTitle:"Answer:"];
		buttonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(16,258,218,26)],
		scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(16,72,218,188)];
	_questionField = [CPTextField textFieldWithStringValue:"" placeholder:"How do you find the area of a circle?" width:226];
	_answerTableView = [[CPTableView alloc] initWithFrame:CGRectMake(0,0,198,188)];
	
	[questionLabel setFrameOrigin:CGPointMake(16,16)];
	
	[answerLabel setFrameOrigin:CGPointMake(16,72)];
	
	[_questionField setFrameOrigin:CGPointMake(12,38)];
	[_questionField setDelegate:self];
	
	[_answerTableView setDataSource:self];
	[_answerTableView setDelegate:self];
	[_answerTableView setUsesAlternatingRowBackgroundColors:YES];
	var column = [[CPTableColumn alloc] initWithIdentifier:"Answers"];
	[[column headerView] setStringValue:"Answers"];
	[column setWidth:198];
	[column setEditable:YES];
	[_answerTableView addTableColumn:column];
	
	var buttons = [[CPButtonBar plusButton], [CPButtonBar minusButton]];
	[buttons makeObjectsPerformSelector:@selector(setTarget:) withObject:self];
	[buttons[0] setAction:@selector(addAnswer)];
	[buttons[1] setAction:@selector(removeSelectedAnswer)];
	[buttonBar setButtons:buttons];
	
	[self addSubview:questionLabel];
	[self addSubview:answerLabel];
	[self addSubview:buttonBar];
	[self addSubview:_questionField];
	[scrollView setDocumentView:_answerTableView];
	[self addSubview:scrollView];
}

//	
//	Controlling the Widget
//	

-(void)setWidget:(CCWidget)widget
{
	[super setWidget:widget];
	[_questionField setStringValue:[widget question]];
	[_answerTableView reloadData];
}

-(void)addAnswer
{
	[_widget addAnswer:"Double Click to Edit"];
	[self _widgetDidUpdateAnswers];
}

-(void)removeSelectedAnswer
{
	[_widget removeAnswerAtIndex:[_answerTableView selectedRow]];
	[self _widgetDidUpdateAnswers];
}

-(void)_widgetDidUpdateAnswers
{
	[_answerTableView reloadData];
	[_layer makeAnswerLayers];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

//
//	CPTextField
//

-(void)controlTextDidChange:(CPTextField)field
{
	// [_widget setQuestion:[_questionField stringValue]];
	// [_layer setQuestionText:[_questionField stringValue]];
	// [[LLPresentationController sharedController] mainSlideContentDidChange];
}

-(void)controlTextDidEndEditing:(CPTextField)field
{
	[_widget setQuestion:[_questionField stringValue]];
	[_layer setQuestionText:[_questionField stringValue]];
	[[LLPresentationController sharedController] mainSlideContentDidChange];
}

//
//	CPTableView
//

-(int)numberOfRowsInTableView:(CPTableView)aTableView
{
    return [_widget numberOfPossibleAnswers];
}
 
-(id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
    return [_widget answerAtIndex:row];
}

-(BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
	return YES;
}

-(void)tableView:(CPTableView)aTableView setObjectValue: (CPControl)anObject forTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
	[_widget changeAnswerAtIndex:rowIndex toAnswer:anObject];
	[_layer setWidget:_widget];
}

-(void)keyDown:(CCEvent)event
{
	//	Do Nothing
}

-(void)keyUp:(CCEvent)event
{
	//	Do Nothing
}

@end