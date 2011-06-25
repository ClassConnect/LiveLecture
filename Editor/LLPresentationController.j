/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 *
 *	Main overarching class that handles the communication 
 *	between different parts of the application, when appropriate.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "MediaKit/MediaKit.j"
@import "../CoreLecture/CoreLecture.j"
@import "MKMediaPanel+LLRadioSelection.j"
@import "LLSlideThemeSelectionPanel.j"
@import "LLFileboxPanel.j"

var __LLPRESENTATION_SHARED__ = nil;

@implementation LLPresentationController : CPObject
{
	CCPresentation _presentation @accessors(property=presentation);
	
	int _currentSlideIndex @accessors(property=currentSlideIndex);
	
	LLSlideNavigationController navigationController @accessors;
	CCSlideView mainSlideView @accessors;
	
	Function _alert_callback;
	CPTextField _alert_text_field;
}

+(id)sharedController
{
	if(__LLPRESENTATION_SHARED__ == nil)
		__LLPRESENTATION_SHARED__ = [[LLPresentationController alloc] init];
	return __LLPRESENTATION_SHARED__;
}

-(id)init
{
	if(self = [super init]) {
		_alert_callback = function(){};
		_presentation = [[CCPresentation alloc] init];
		//	We want to have an original slide that has a title and a subtitle
		var s = [[CCSlide alloc] init],
			w1 = [[CCTextWidget alloc] initWithString:@"Double-click to add title" alignment:TextLayerCenterAlignmentMask fontSize:48],
			w2 = [[CCTextWidget alloc] initWithString:@"Double-click to add subtitle" alignment:TextLayerCenterAlignmentMask fontSize:36];
		//	Magic numbers are taken from putting the top one right above the middle, and bottom right under the middle
		[w1 setLocation:CGPointMake(50,274)];
		[w1 setSize:CGRectMake(0,0,924,100)];
		[w2 setLocation:CGPointMake(100,394)];
		[w2 setSize:CGRectMake(0,0,824,349)];
		[s addWidget:w1];
		[s addWidget:w2];
		[_presentation addSlide:s];
		[self setCurrentSlideIndex:0];
	}
	return self;
}

//	----------------------------
//	Slide Information
//	----------------------------

-(void)setPresentation:(CCPresentation)presentation
{
	_presentation = presentation;
	[navigationController reload];
}

-(int)numberOfSlides
{
	return [[_presentation slides] count];
}

-(CCSlide)slideAtIndex:(int)index
{
	return [[_presentation slides] objectAtIndex:index];
}

-(int)indexOfSlide:(CCSlide)slide
{
	return [[_presentation slides] indexOfObject:slide];
}

-(CPArray)allSlides
{
	return [_presentation slides];
}

-(void)setTheme:(CCSlideTheme)theme
{
	debugger;
	if([[_presentation theme] isEqual:theme])
		return;
	[_presentation setTheme:theme];
	[[mainSlideView slideLayer] refreshTheme];
	[navigationController setThemeForItems:theme];
}

//	----------------------------
//	Slide Management Controls
//	----------------------------

-(void)newSlide
{
	var s = [[CCSlide alloc] init];
		w1 = [[CCTextWidget alloc] initWithString:@"Double-click to add title" alignment:TextLayerCenterAlignmentMask fontSize:48],
		w2 = [[CCTextWidget alloc] initWithString:@"Double-click to add text" alignment:TextLayerLeftAlignmentMask fontSize:24];
	//	Magic numbers are from some intense in my head calculations. Yeah
	[w1 setLocation:CGPointMake(50,50)];
	[w1 setSize:CGRectMake(0,0,924,100)];
	[w2 setLocation:CGPointMake(50,170)];
	[w2 setSize:CGRectMake(0,0,924,548)];
	[s addWidget:w1];
	[s addWidget:w2];
	[[_presentation slides] addObject:s];
	[self setCurrentSlideIndex:[self numberOfSlides]-1];
	[navigationController addSlide:s];
}

-(void)deleteCurrentSlide
{
	[[_presentation slides] removeObjectAtIndex:_currentSlideIndex];
	[navigationController removeSlideAtIndex:_currentSlideIndex];
	if((_currentSlideIndex == [self numberOfSlides]) && [self numberOfSlides])
	{
		[self setCurrentSlideIndex:_currentSlideIndex-1];
	}
	//	If they got rid of the last slide, give them a new one
	if([self numberOfSlides] == 0) {
		[self newSlide];
	}
	[mainSlideView setSlide:[self slideAtIndex:_currentSlideIndex]];
}

-(void)moveSlideAtIndex:(int)start toIndex:(int)finish
{
	finish = ((finish >= [self numberOfSlides] ) ? ([self numberOfSlides]-1) : ((finish < 0) ? 0 : finish));
	var slides = [_presentation slides];
	var slide = [slides objectAtIndex:start];
	[slides removeObjectAtIndex:start];
	[slides insertObject:slide atIndex:finish];
	[navigationController moveSlideAtIndex:start toIndex:finish];
	[self setCurrentSlideIndex:finish];
}

//	----------------------------
//	Slide Selection
//	----------------------------

-(void)setCurrentSlideIndex:(int)currentSlideIndex
{
	//	Make sure to deal with the -1 case, which is when the user clicks somewhere that doesnt correspond to a slide
	//	When this happens, we dont want anything to happen visually, so we set the selected index to be the current one again
	if(_currentSlideIndex == currentSlideIndex || currentSlideIndex < 0)
		return;
	_currentSlideIndex = currentSlideIndex;
	[mainSlideView setSlide:[self currentSlide]];
	[navigationController setSelectedIndex:_currentSlideIndex];
}

-(CCSlide)currentSlide
{
	return [self slideAtIndex:[self currentSlideIndex]];
}

-(void)setCurrentSlide:(CCSlide)slide
{
	[self setCurrentSlideIndex:[self indexOfSlide:slide]];
}

-(void)moveToNextSlide
{
	if([self currentSlideIndex] != [self numberOfSlides]-1)
		[self setCurrentSlideIndex:[self currentSlideIndex]+1];
}

-(void)moveToPreviousSlide
{
	if([self currentSlideIndex])
		[self setCurrentSlideIndex:[self currentSlideIndex]-1];
}

//	----------------------------
//	Widgets
//	----------------------------

-(void)newTextWidget
{
	var widget = [[CCTextWidget alloc] initWithString:@"Double click to Edit"];
	[widget setLocation:CGPointMake(50,334)];
	[widget setSize:CGRectMake(0,0,924,100)];
	[[mainSlideView slideLayer] addWidgetToSlide:widget];
	[[_presentation slides] replaceObjectAtIndex:[self currentSlideIndex] withObject:[mainSlideView slide]];
}

-(void)newQuizWidget
{
	var widget = [[LLQuizWidget alloc] initWithQuestion:"How to change the questions/answers" possibleAnswers:["Click on this widget","Click on the blue 'i' in the top right","Edit any fields you want","Hit Enter"]];
	[widget setLocation:CGPointMake(362,334)];
	[widget setSize:CGRectMake(0,0,520,300)];
	[[mainSlideView slideLayer] addWidgetToSlide:widget];
//	[[_presentation slides] replaceObjectAtIndex:[self currentSlideIndex] withObject:[[mainSlideView slide] copy]];
}

-(void)showThemeSelectionPanel
{
	[[CPApplication sharedApplication] orderFrontThemeSelectionPanel];
	[[CPApplication sharedApplication] runModalForWindow:[LLSlideThemeSelectionPanel sharedPanel]];
}

-(void)showFileboxPanel
{
	[[CPApplication sharedApplication] orderFrontFileboxPanel];
}

-(void)showMediaPanel
{
	[[CPApplication sharedApplication] orderFrontMediaPanel:self];
}

-(void)showMediaPanelWithImagesSelected
{
	[self showMediaPanel];
	[[MKMediaPanel sharedMediaPanel] setImagesAsSelectedFilter];
}

-(void)showMediaPanelWithVideosSelected
{
	[self showMediaPanel];
	[[MKMediaPanel sharedMediaPanel] setVideosAsSelectedFilter];
}

-(void)showModalAlertWithText:(CPString)text informativeText:informative_text placeholder:(CPString)placeholder imageName:(CPString)image callback:(Function)callback
{
	var alert = [[CPAlert alloc] init],
			window = [[CPApplication sharedApplication] mainWindow];
	_alert_callback = callback;
	_alert_text_field = [CPTextField textFieldWithStringValue:"" placeholder:placeholder width:300];
	[alert addButtonWithTitle:"Add Widget"];
	[alert addButtonWithTitle:"Cancel"];
	[alert setMessageText:text];
	[alert setInformativeText:informative_text];
	[alert setAccessoryView:_alert_text_field];
	[alert setIcon:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:image] size:CGSizeMake(50,50)]];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alert:didEndWithReturnCode:) contextInfo:nil];
}

-(void)alert:(CPAlert)alert didEndWithReturnCode:(int)returnCode
{
	if([_alert_text_field stringValue] == "")
		return;
	if(!returnCode)
		_alert_callback([_alert_text_field stringValue]);
	_alert_callback = function(){};
}

-(void)showPictureURLPanel
{
	[self showModalAlertWithText:"Picture URL:"
				 informativeText:"Make sure to include 'http://'"
					 placeholder:"http://www.google.com/images/logos/ps_logo2.png"
					   imageName:"alert_icon_picture.png"
						callback:function(text){
		//	Make new Picture Widget with the given URL
		var widget = [[CCPictureWidget alloc] initWithPathToImage:text];
		[widget setSize:CGRectMake(0,0,720,480)];
		//	((1024 / 2) - (720 / 2)), ((768 / 2) - (480 / 2))
		[widget setLocation:CGPointMake(152,144)];
		[[mainSlideView slideLayer] addWidgetToSlide:widget];
	}];
}

-(void)showMovieURLPanel
{
	[self showModalAlertWithText:"Youtube ID:"
				 informativeText:"http://www.youtube.com/watch?v=*This Text Here*"
					 placeholder:"bESGLojNYSo"
					   imageName:"alert_icon_movie.png"
						callback:function(text){
		//	Make new Movie Widget with the given URL
		var widget;
		if(text.indexOf("youtube.com") == -1)
			widget = [[CCMovieWidget alloc] initWithYoutubeID:text];
		else
		{
			widget = [[CCMovieWidget alloc] initWithFile:text];
		}
		[widget setSize:CGRectMake(0,0,720,480)];
		//	((1024 / 2) - (720 / 2)), ((768 / 2) - (480 / 2))
		[widget setLocation:CGPointMake(152,144)];
		[[mainSlideView slideLayer] addWidgetToSlide:widget];
	}];
}

-(void)showWebURLPanel
{
	[self showModalAlertWithText:"Website URL:"
				 informativeText:""
					 placeholder:"http://www.google.com"
					   imageName:"alert_icon_website.png"
						callback:function(text){
		//	Make new Web Widget with the given URL
		if(text.indexOf("http://") != 0)
			text = "http://"+text;
		var widget = [[CCWebWidget alloc] initWithURL:text];
		[widget setSize:CGRectMake(0,0,720,480)];
		//	((1024 / 2) - (720 / 2)), ((768 / 2) - (480 / 2))
		[widget setLocation:CGPointMake(152,144)];
		[[mainSlideView slideLayer] addWidgetToSlide:widget];
	}];
}

-(void)showInspectorPanel
{
	[[CPApplication sharedApplication] orderFrontInspectorPanel];
}

//	----------------------------
//	Navigation/Main Slide Connectivity
//	----------------------------

-(void)mainSlideContentDidChange {
	[[_presentation slides] replaceObjectAtIndex:_currentSlideIndex withObject:[[mainSlideView slide] copy]];
	[navigationController slideContentChanged];
}

@end