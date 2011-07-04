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
	
	BOOL _isDirty @accessors(property=dirty,getter=isDirty);
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
		_currentSlideIndex = -1;
		// var s = [CCSlide titleSlide];
		// [s setTheme:[_presentation theme]];
		// [_presentation addSlide:s];
		// [self setCurrentSlideIndex:0];
		[self newSlide];
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
	if([[_presentation theme] isEqual:theme])
		return;
	[_presentation setTheme:theme];
	//	BUGFIX: Since the slide that the slideLayer is referencing is actually
	//	a copy of the current slide, we need to explicitly set the theme before
	//	we refresh for it to show up
	[mainSlideView setSlide:[self currentSlide]];
	[[mainSlideView slideLayer] refreshTheme];
	[navigationController setThemeForItems:theme];
}

//	----------------------------
//	Slide Management Controls
//	----------------------------

-(void)newSlide
{
	var s;
	//	When we make a new slide, if this is the ONLY slide, it should be layed
	//	out like a title slide. If there are other slides already, it should be
	//	layed out like a content slide
	if([[_presentation slides] count])
		s = [CCSlide contentSlide];
	else
		s = [CCSlide titleSlide];
	[s setTheme:[_presentation theme]];
	if([[_presentation slides] count])
	{
		[[_presentation slides] insertObject:s atIndex:_currentSlideIndex+1];
		[self setCurrentSlideIndex:_currentSlideIndex+1];
	}
	else
	{
		[[_presentation slides] addObject:s];
		[self setCurrentSlideIndex:0];
	}
	[navigationController addSlide:s];
}

-(void)deleteCurrentSlide
{
	[[_presentation slides] removeObjectAtIndex:_currentSlideIndex];
	var oldCurr = _currentSlideIndex;
	if(_currentSlideIndex == [self numberOfSlides])
	{
		[self setCurrentSlideIndex:_currentSlideIndex-1];
	}
	[navigationController removeSlideAtIndex:oldCurr];
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
	//	When this happens, we dont want anything to happen
	if(_currentSlideIndex == currentSlideIndex || currentSlideIndex < 0)
		return;
	_currentSlideIndex = currentSlideIndex;
	[mainSlideView setSlide:[self currentSlide]];
	[navigationController setSelectedIndex:_currentSlideIndex];
	[[LLInspectorPanel sharedPanel] setContentViewForWidget:nil correspondingLayer:nil];
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
	if(![[MKMediaPanel sharedMediaPanel] target])
	{
		[[MKMediaPanel sharedMediaPanel] setTarget:self];
		var sel = @selector(addWidgetFromMediaPanelToCenter);
		[[MKMediaPanel sharedMediaPanel] setAction:sel];
	}
	[[CPApplication sharedApplication] orderFrontMediaPanel:self];
}

-(void)addWidgetFromMediaPanelToCenter
{
	var panel = [MKMediaPanel sharedMediaPanel],
		widget;
	if([panel selectedImage])
	{
		var img = [panel selectedImage],
			size = [img size];
		widget = [[CCPictureWidget alloc] initWithPathToImage:[img filename]];
		if(size.width > 1024) 
			size.width = 1024;
		if(size.height > 768)
			size.height = 768;
		[widget setSize:CGRectMake(0,0,size.width,size.height)];
	}
	else //	Video
	{
		widget = [[CCMovieWidget alloc] initWithMovie:[panel selectedVideo]];
		[widget setSize:CGRectMake(0,0,720,480)];
	}
	//	Put it in the center
	//	We also don't have to worry about it going out of bounds, since the
	//	size took care of that. Yay!
	var x = (512 - ([widget size].size.width / 2)),
		y = (384 - ([widget size].size.height / 2));
	[widget setLocation:CGPointMake(x,y)];
	[[mainSlideView slideLayer] addWidgetToSlide:widget];
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
	[self showModalAlertWithText:"Youtube Video:"
				 informativeText:"Paste the full URL of the Youtube Video Here"
					 placeholder:"http://www.youtube.com/watch?v=bESGLojNYSo"
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

-(void)mainSlideContentDidChange
{
	[[_presentation slides] replaceObjectAtIndex:_currentSlideIndex withObject:[[mainSlideView slide] copy]];
	[navigationController slideContentChanged];
	[self setDirty:YES];
}

@end