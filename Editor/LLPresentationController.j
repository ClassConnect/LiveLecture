/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 *
 *	Main overarching class that handles the communication 
 *	between different parts of the application, when appropriate.
 */
@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "MKMediaPanel+LLRadioSelection.j"
@import "LLSlideThemeSelectionPanel.j"
@import "LLFileboxPanel.j"
@import "280UploadButton.j"

var __LLPRESENTATION_SHARED__ = nil;

var file_extension = function(string){
	var c = [string componentsSeparatedByString:"."];
	if(c.length)
		return c[c.length-1];
	else
		return "";
}

@implementation LLPresentationController : CPObject
{
	CCPresentation _presentation @accessors(property=presentation);
	
	int _currentSlideIndex @accessors(property=currentSlideIndex);
	
	LLSlideNavigationController navigationController @accessors;
	CCSlideView mainSlideView @accessors;
	
	CPAlert _alert;
	CPString _growlIntervalID;
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
	[self newSlide:s];
	// [s setTheme:[_presentation theme]];
	// if([[_presentation slides] count])
	// {
	// 	[[_presentation slides] insertObject:s atIndex:_currentSlideIndex+1];
	// 	[self setCurrentSlideIndex:_currentSlideIndex+1];
	// }
	// else
	// {
	// 	[[_presentation slides] addObject:s];
	// 	[self setCurrentSlideIndex:0];
	// }
	// [navigationController addSlide:s];
}

-(void)duplicateCurrentSlide
{
	[self newSlide:[[self currentSlide] copy]];
}

-(void)newSlide:(CCSlide)s
{
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
	[navigationController removeSlideAtIndex:start];
	[slides insertObject:slide atIndex:finish];
	[navigationController addSlide:slide atIndex:finish];
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
	[widget setSize:CGRectMake(0,0,924,100)];
	//	Indent the widgets if they keep throwing things in there
	var checkLocation = CGPointMake(50,334),
		widgets = [[self currentSlide] widgets],
		again = YES;
	while(again)
	{
		//	Go through the widgets
		//	BUG: The scoping on i is fucked up.
		for(var i = 0 ; i < [widgets count] ; i++)
		{
			if(CGPointEqualToPoint([widgets[i] location],checkLocation))
			{
				var flag = 0;
				if((checkLocation.x + 10 + [widget size].size.width) < 1024)
				{
					flag = 1;
					checkLocation.x += 10;
				}
				if((checkLocation.y + 10 + [widget size].size.height) < 768)
				{
					flag = 1
					checkLocation.y += 10;
				}
				//	BUGFIX: If neither of the above get called, then it goes
				//	into an infinite loop. Put a flag so that it only keeps
				//	indenting if there is space to be had.
				if(flag)
				{
					i = -1;
					break;
				}
			}
		}
		//	If i isnt -1 then there are no widgets there currently, so we are
		//	finished
		if(i != -1)
			again = NO;
	}
	[widget setLocation:checkLocation];
	[[mainSlideView slideLayer] addWidgetToSlide:widget];
	[[_presentation slides] replaceObjectAtIndex:[self currentSlideIndex] withObject:[mainSlideView slide]];
}

-(void)newQuizWidget
{
	//	Show black box that adds widgets
	[[CPApplication sharedApplication] orderFrontWidgetFormPanel];
	[[CPApplication sharedApplication] runModalForWindow:[LLWidgetFormPanel sharedPanel]];
	[[LLWidgetFormPanel sharedPanel] setMode:LLWidgetFormPanelModeNew];
	[[LLWidgetFormPanel sharedPanel] setWidget:[LLQuizWidget new]];
	[[LLWidgetFormPanel sharedPanel] setCallback:function(widget){
		[widget setLocation:CGPointMake(152,144)];
		[widget setSize:CGRectMake(0,0,720,480)];
		[[mainSlideView slideLayer] addWidgetToSlide:widget];
	}];
	// var widget = [[LLQuizWidget alloc] initWithQuestion:"How to change the questions/answers" possibleAnswers:["Click on this widget","Click on the blue 'i' in the top right","Edit any fields you want","Hit Enter"]];
	// 	[widget setLocation:CGPointMake(362,334)];
	// 	[widget setSize:CGRectMake(0,0,520,300)];
	// 	[[mainSlideView slideLayer] addWidgetToSlide:widget];
	// 	
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

-(void)showModalAlertWithText:(CPString)text informativeText:informative_text placeholder:(CPString)placeholder widgetName:(CPString)widgetname imageName:(CPString)image callback:(Function)callback
{
	_alert = [[CPAlert alloc] init];
	var	w = [[CPApplication sharedApplication] mainWindow];
	_alert_callback = callback;
	_alert_text_field = [CPTextField textFieldWithStringValue:"" placeholder:placeholder width:305];
	[_alert addButtonWithTitle:"Add "+widgetname];
	[_alert addButtonWithTitle:"Cancel"];
	if(widgetname == "Picture" || widgetname == "Video")
		[_alert addButtonWithTitle:"Search for "+widgetname+"s"];
	[_alert setMessageText:text];
	[_alert setInformativeText:informative_text];
	[_alert setAccessoryView:_alert_text_field];
	[_alert setIcon:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:image] size:CGSizeMake(50,50)]];
	[_alert beginSheetModalForWindow:w modalDelegate:self didEndSelector:@selector(alert:didEndWithReturnCode:) contextInfo:nil];
	[[_alert window] makeFirstResponder:_alert_text_field];
}

-(void)alert:(CPAlert)alert didEndWithReturnCode:(int)returnCode
{
	window.clearInterval(_growlIntervalID)
	if(returnCode == 0 && [_alert_text_field stringValue] != "")
		_alert_callback([_alert_text_field stringValue]);
	else
	{
		if(returnCode == 2)
		{
			[[CPApplication sharedApplication] orderFrontMediaPanel:self];
			var title = [[alert buttons][0] title];
			if(title == "Search for Pictures")
				[[MKMediaPanel sharedMediaPanel] setImagesAsSelectedFilter];
			if(title == "Search for Videos")
				[[MKMediaPanel sharedMediaPanel] setVideosAsSelectedFilter];
			//	If there is text in field, make searchbox come up with the text
			//	already inserted and searched for
			if([_alert_text_field stringValue] != "")
			{
				[[MKMediaPanel sharedMediaPanel] setSearchTerm:[_alert_text_field stringValue]];
				[[MKMediaPanel sharedMediaPanel] search:nil];
			}
		}
	}
	_alert_callback = function(){};
	[[mainSlideView window] makeFirstResponder:mainSlideView];
}

-(void)showPictureURLPanel
{
	//	Since I have to show a custom view, I am just going to copy the alert code from above to here
	_alert_callback = function(text){
		//	Make new Picture Widget with the given URL
		var widget = [[CCPictureWidget alloc] initWithPathToImage:text];
		[widget setSize:CGRectMake(0,0,720,480)];
		//	((1024 / 2) - (720 / 2)), ((768 / 2) - (480 / 2))
		[widget setLocation:CGPointMake(152,144)];
		[[mainSlideView slideLayer] addWidgetToSlide:widget];
	};
	_alert = [[CPAlert alloc] init];
	var w = [[CPApplication sharedApplication] mainWindow];
	[_alert addButtonWithTitle:"Add Picture"];
	[_alert addButtonWithTitle:"Cancel"];
	[_alert addButtonWithTitle:"Search for Pictures"];
	[_alert setMessageText:"Add Picture"];
	var v = [[CPView alloc] initWithFrame:CGRectMake(0,0,305,25)],
		button = [[UploadButton alloc] initWithFrame:CGRectMake(230,0,75,25)],
		orLabel = [CPTextField labelWithTitle:"or"],
		urlField = [CPTextField textFieldWithStringValue:"" placeholder:"enter url" width:200];
	[button setTheme:[CPTheme defaultTheme]];
	[button setTitle:"Upload"];
	[button setBordered:YES];
	[button setURL:"/app/livelecture/iapi_imgupload.php"];
	[button setDelegate:self];
	[orLabel setFrame:CGRectMake(200,2,27,17)];
	[urlField setFrameOrigin:CGPointMake(0,0)];
	[orLabel setAlignment:CPCenterTextAlignment];
	_alert_text_field = urlField;
	[v addSubview:button];
	[v addSubview:orLabel];
	[v addSubview:urlField];
	[_alert setAccessoryView:v];
	[_alert setIcon:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:"alert_icon_picture.png"] size:CGSizeMake(50,50)]];
	[_alert beginSheetModalForWindow:w modalDelegate:self didEndSelector:@selector(alert:didEndWithReturnCode:) contextInfo:nil];
}

-(void)uploadButton:(UploadButton)button didChangeSelection:(CPString)selection
{
	var ext = file_extension(selection)
	if(![["png","gif","jpg","jpeg"] containsObject:ext])
	{
		[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:"Invalid Extension" message:"LiveLecture only supports png, gif, jpg, and jpeg image types" icon:TNGrowlIconError];
		return;
	}
	[button setEnabled:NO];
	for(var i = 0 ; i < [[_alert buttons] count] ; i++)
	{
		if([[_alert buttons][i] title] != "Cancel")
		{
			[[_alert buttons][i] setEnabled:NO];
		}
	}
//	[[_alert buttons] makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
	[button submit];
}

-(void)uploadButtonDidBeginUpload:(UploadButton)button
{
	[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:"Upload Started" message:"Please wait while we upload your image"];
	_growlIntervalID = window.setInterval(function(){
		var messages = ["Still uploading...", "Is this a big file or what?", "We haven't forgotten about you, we are just still uploading"],
			message = messages[Math.floor(Math.random() * messages.length)];
		[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:"Uploading..." message:message];
	},5000);
}

-(void)uploadButton:(UploadButton)button didFinishUploadWithData:(CPString)data
{
	var url = [data objectFromJSON].url;
	[_alert_text_field setStringValue:url];
	[self _endSheet];
}

-(void)uploadButton:(UploadButton)button didFailWithError:(CPString)error
{
	[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:"Error" message:"An error occured. Please try again" icon:TNGrowlIconError];
	[_alert_text_field setStringValue:""];
	[self _endSheet];
}

-(void)_endSheet
{
   	window.clearInterval(_growlIntervalID);
	[[CPApplication sharedApplication] endSheet:[_alert window]];
	[[mainSlideView window] makeFirstResponder:mainSlideView]; 
}

-(void)showMovieURLPanel
{
	[self showModalAlertWithText:"Youtube Video:"
				 informativeText:"Paste the full URL of the Youtube Video Here"
					 placeholder:"http://www.youtube.com/watch?v=bESGLojNYSo"
					  widgetName:"Video"
					   imageName:"alert_icon_movie.png"
						callback:function(text){
		//	Make new Movie Widget with the given URL
		var widget;
		if(text.indexOf("youtube.com") == -1 && text.indexOf("youtu.be") == -1)
		{
			widget = [[CCMovieWidget alloc] initWithYoutubeID:text];
		}
		else
			widget = [[CCMovieWidget alloc] initWithFile:text];
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
					  widgetName:"Website"
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