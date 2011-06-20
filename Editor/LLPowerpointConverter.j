@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"

@implementation LLPowerpointConverter : CPObject { }

+(CCPresentation)convertPresentation:(CPString)json
{
	return [self convertPresentationWithObject:[json objectFromJSON]];
}

+(CCPresentation)convertPresentationWithObject:(JSObject)obj
{
	//	Should be an array
	var presentation = [[CCPresentation alloc] init];
	for(var i = 0 ; i < [obj count] ; i++)
	{
		var slide = [self convertSlideWithObject:obj[i]]
		[presentation addSlide:slide];
		//	If there is only 1 widget, it is most likely a title slide
		//	Also, if it is the first slide, it is most likely a title slide
		if([self _slideIsTitleSlide:slide index:i])
			[self _layoutTitleSlide:slide];
		else
			[self _layoutContentSlide:slide];
	}
	return presentation;
}

+(CCSlide)convertSlideWithObject:(JSObject)obj
{
	var slide = [[CCSlide alloc] init];
	for(var i = 0 ; i < [obj count] ; i++)
	{
		var current = obj[i];
		current["is_heading"] = ((i == 0) && (obj[i]["text"].length < 40));
		[slide addWidget:[self convertWidgetWithObject:current]];
	}
	return slide;
}

+(CCWidget)convertWidgetWithObject:(JSObject)obj
{
	var	width = obj["width"],
			height = obj["height"],
			text = obj["text"],
			is_heading = obj["is_heading"],
			alignment = ((is_heading) ? TextLayerCenterAlignmentMask : TextLayerLeftAlignmentMask),
			fontSize = ((is_heading) ? 40 : 24),
			widget = nil;
	if([text rangeOfString:"{ccBulletPoint}"].length != 0)
	{
		var list = [text componentsSeparatedByString:"{ccBulletPoint}"];
		if([list count] != 0)
		{
			var range = CPMakeRange(1,[list count]-1);
			widget = [[CCTextWidget alloc] initWithList:[list subarrayWithRange:range] alignment:alignment fontSize:fontSize];
		}
		else
			widget = [[CCTextWidget alloc] initWithString:"" alignment:alignment fontSize:fontSize];
	}
	else
		widget = [[CCTextWidget alloc] initWithString:text alignment:alignment fontSize:fontSize];
	[widget setSize:CGRectMake(0,0,width,height)];
	return widget;
}

+(BOOL)_slideIsTitleSlide:(CCSlide)slide index:(CPInteger)index
{
	//	There have been a bunch of different outcomes for this, so it is hard to say for sure...
	//	This is what I am going off of
	//
	//	1) The first slide is most likely a title slide (taken care of above)
	//	2) Slides with only one piece of text are most likely title slides
	//		- One notable exception is when the entire content is in one widget.
	//			To test for this I am going to say if the single piece of text is
	//			over 40 characters long, then it is most likely a content slide
	//	3) It does not fulfil the requirements for a two column setup
	//
	//	Check for the two column setup
	var avg_width = 0;
	for(var i = 1 ; i < [[slide widgets] count] ; i++)
	{
		avg_width += CGRectGetWidth([[slide widgets][i] size]);
	}
	avg_width = avg_width / [[slide widgets] count];
	//	If the average width is less than 512, than it is most likely a two column slide,
	//	not a 
	if((avg_width < 512) && (avg_width != 0))
		return NO;
	if(!index)
		return YES;
	return (([[slide widgets] count] == 1) && ([[slide widgets][0] length] < 40));
}

+(void)_layoutTitleSlide:(CCSlide)slide
{
	//	Most likely 1, but want to do this anyway
	var widgets = [slide widgets],
			subtitle_height = 30;
	if([widgets count] == 0)
		return;
	for(var i = 1 ; i < [widgets count] ; i++)
	{
		subtitle_height += (CGRectGetHeight([widgets[i] size]) + 15)
	}
	//	Set the title heading
	// 768/2, 1024 / 2
	var middle_height = 384,
			middle_width = 512,
			title_widget = widgets[0],
			title_height = CGRectGetHeight([title_widget size]),
			title_width = CGRectGetWidth([title_widget size]);
	if(subtitle_height > middle_height)
		middle_height = subtitle_height;
	[title_widget setLocation:CGPointMake(middle_width - (title_width / 2), ((middle_height - 5 - title_height) < 0) ? 0 : middle_height - 5 - title_height)];
	var current_height = middle_height + 5;
	for(var i = 1 ; i < [widgets count] ; i++)
	{
		var widg = widgets[i];
		[widg setLocation:CGPointMake(middle_width - (CGRectGetWidth([widg size]) / 2), current_height)];
		current_height += (CGRectGetHeight([widg size]) + 5);
	}
}

+(void)_layoutContentSlide:(CCSlide)slide
{
	if([[slide widgets] count] == 0)
		return;
	//	To figure out what kind of layout I need to do, I'm going to look at the
	//	width of all the pieces of content. If most of them are over half the
	//	width of the slide, then I can assume that it isn't a two column setup.
	//
	//	Although now that I think about it, the other thing I have to keep in
	//	mind is the total height of all the pieces of content. If the total
	//	height is more than the height of the slide, then it has to be two column
	var total_height = 0,
			total_width = 0;
	for(var i = 0 ; i < [[slide widgets] count] ; i++)
	{
		total_height += CGRectGetHeight([[slide widgets][i] size]);
		total_width += CGRectGetWidth([[slide widgets][i] size]);
	}
	var avg_width = total_width / [[slide widgets] count];
	if(([[slide widgets] count] == 1) || (avg_width > 512 && total_height < 768))
	{
		[self _layoutSingleColumnContentSlide:slide];
	}
	else
	{
		[self _layoutTwoColumnContentSlide:slide];
	}
}

+(void)_layoutSingleColumnContentSlide:(CCSlide)slide
{
	if([[slide widgets] count] == 1)
	{
		var widget = [[slide widgets] objectAtIndex:0];
		[widget setLocation:CGPointMake(512 - (CGRectGetWidth([widget size]) / 2),150)];
		return;
	}
	var content_begin = [self _layoutHeading:[slide widgets][0]],
			current_height = content_begin;
	for(var i = 1; i < [[slide widgets] count] ; i++)
	{
		var wid = [[slide widgets] objectAtIndex:i];
		[wid setLocation:CGPointMake(10,current_height)];
		current_height += (CGRectGetHeight([wid size]) + 5);
	}
}

+(void)_layoutTwoColumnContentSlide:(CCSlide)slide
{
	if([[slide widgets] count] == 0)
		return;
	var content_begin = [self _layoutHeading:[slide widgets][0]],
			current_height = content_begin,
			middle_height = 0,
			widgets = [slide widgets];
	for(var i = 1 ; i < [widgets count] ; i++)
		middle_height += CGRectGetHeight([widgets[i] size]);
	middle_height = (middle_height / 2);
	var float_right = NO;
	for(var i = 1 ; i < [widgets count] ; i++)
	{
		var x = 20;
		if(float_right)
			x = 1024 - 20 - CGRectGetWidth([widgets[i] size]);
		[widgets[i] setLocation:CGPointMake(x,current_height)];
		current_height += (CGRectGetHeight([widgets[i] size]) + 10);
		if((current_height-content_begin) > middle_height)
		{
			float_right = YES;
			current_height = content_begin;
		}
	}
}

//	Returns the height at which content should begin
+(float)_layoutHeading:(CCWidget)widget
{
	var width = CGRectGetWidth([widget size]);
	[widget setLocation:CGPointMake((1024 - width) / 2, 15)];
	return CGRectGetHeight([widget size]) + 15 + 15;
}

@end