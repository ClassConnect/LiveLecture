@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "LLFileboxAPIManager.j"
@import "LLFileboxCollectionItem.j"
@import "EKActivityIndicatorView.j"

var __shared__ = nil;

function is_folder(object)
{
	return [object class] == [LLFileboxFolder class];
}

@implementation LLFileboxPanel : CPPanel
{
	CPCollectionView _collection;
	
	LLFileboxAPIManager _api;
	
	BOOL _shouldUpdateContents;
	BOOL _foldersLoaded;
	BOOL _filesLoaded;
	
	CPTextField _titleLabel;
	CPButton _backButton;

	CPView _loadingView;
	CPTextField _nothingLabel;
}

+(id)sharedPanel
{
	return ((__shared__) ? __shared__ : __shared__ = [[LLFileboxPanel alloc] init]);
}

-(id)init
{
	if(self = [self initWithContentRect:CGRectMake(300,100,300,400) styleMask:CPTitledWindowMask|CPClosableWindowMask])
	{
		[self setTitle:@"Filebox"];
		
		var contentView = [self contentView],
				sv = [[CPScrollView alloc] initWithFrame:CGRectMake(0,45,CGRectGetWidth([contentView bounds]),CGRectGetHeight([contentView bounds]) - 45)],
				itemPrototype = [[CPCollectionViewItem alloc] init];
				border = [[CPView alloc] initWithFrame:CGRectMake(0,44,CGRectGetWidth([contentView bounds]),1)],
		
		_backButton = [CPButton buttonWithTitle:@"Back"];
				
		//	Load the API Manager
		_api = [LLFileboxAPIManager defaultManager];
		
		//	Set up top bar
		[_backButton setTarget:self];
		[_backButton setAction:@selector(back)];
		[_backButton setFrameOrigin:CGPointMake(5,22 - (CGRectGetHeight([_backButton frame]) / 2))];
		[self setDefaultButton:_backButton];
		_titleLabel = [CPTextField labelWithTitle:@"Home"];
		var bbf = [_backButton frame];
		[_titleLabel setFrame:CGRectMake(CGRectGetMaxX(bbf)+14,0,CGRectGetWidth([contentView bounds])-CGRectGetMaxX(bbf)-14,44)];
		[_titleLabel setFont:[CPFont boldSystemFontOfSize:18]];
		[_titleLabel setVerticalAlignment:CPCenterTextAlignment];
		[border setBackgroundColor:[CPColor lightGrayColor]];
		[contentView addSubview:border];
		[contentView addSubview:_backButton];
		[contentView addSubview:_titleLabel];
		
		//	Set up the Collection View
		_collection = [[CPCollectionView alloc] initWithFrame:CGRectMake(0,0,285,CGRectGetHeight([sv bounds])-15)];
		[_collection setDelegate:self];
		[_collection setMinItemSize:CGSizeMake(285,26)];
		[_collection setMaxItemSize:CGSizeMake(285,26)];
		[_collection setBackgroundColor:[CPColor whiteColor]];
		[_collection setVerticalMargin:0];
		[itemPrototype setView:[[LLFileboxCollectionItem alloc] initWithFrame:CGRectMake(0,0,285,26)]];
		[_collection setItemPrototype:itemPrototype];
		[sv setDocumentView:_collection];
		
		_nothingLabel = [CPTextField labelWithTitle:"This folder is empty"];
		[_nothingLabel setCenter:[contentView center]];
		[contentView addSubview:_nothingLabel];
		[_nothingLabel setHidden:YES];
		
		//	Loading View
		_loadingView = [[CPView alloc] initWithFrame:[sv bounds]];
	   	[_loadingView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
   
		var progressIndicator = [[EKActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,32,32)];
		[progressIndicator setAutoresizingMask:CPViewMinXMargin|CPViewMinYMargin|CPViewMaxXMargin|CPViewMaxYMargin];
		[progressIndicator setCenter:[_loadingView center]];
		[progressIndicator startAnimating];
    
	    [_loadingView addSubview:progressIndicator];
		
		//	Add all the subviews
		[contentView addSubview:sv];
		[sv addSubview:_loadingView];
		
		[_collection setHidden:YES];
		[_loadingView setHidden:NO];
		//	Load the Root folder's contents
		[_api getRootFolderContentsWithCallback:function() {[self refreshFilebox];}];
		[_backButton setEnabled:NO];
	}
	return self;
}

-(void)back
{
	[_collection setHidden:YES];
	[_loadingView setHidden:NO];
	[_api getParentFolderContentsWithCallback:function(){[self refreshFilebox];}];
}

-(void)refreshFilebox
{	
	[_backButton setEnabled:(""+[_api currentFolder] != "0")];
	var contents = [[_api folders] copy];
	contents = [contents arrayByAddingObjectsFromArray:[[_api files] copy]];
	[_loadingView setHidden:YES];
	if([contents count])
	{
		[_collection setHidden:NO];
		[_collection setContent:contents];
		[_nothingLabel setHidden:YES];
	}
	else
	{
		[_nothingLabel setHidden:NO];
		[_collection setHidden:YES];
	}
	[_titleLabel setStringValue:[_api parentName]];
}

-(void)collectionView:(CPCollectionView)collectionView didDoubleClickOnItemAtIndex:(int)index
{
	// If index is greater than the number of folders, then it is a file and we dont do anything
	if(index >= [[_api folders] count])
		return;
	var folder = [[_api folders] objectAtIndex:index];
	if([folder class] != [LLFileboxFolder class])
		return CPLog("Your check for folder is off");
	//	Get the new contents of the filebox	
	[_collection setHidden:YES];
	[_loadingView setHidden:NO];
	[_api getContentsOfFolder: [folder id] withCallback:function() {[self refreshFilebox];}];
}

-(CPData)collectionView:(CPCollectionView)collectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
	var file = [[_api files] objectAtIndex:[indices firstIndex] - [[_api folders] count]],
			obj = nil;
	switch([file type])
	{
		//	I'm using a private helper function to get the filename that I need from the youtube ID. So sue me.
		case kLLFileboxFileTypeMovie: obj = [CPFlashMovie flashMovieWithFile:[CCMovieWidget _filenameFromYoutubeID:[file content]]];
		break;
		//	CCSlideView is expecting a URL for this object
		case kLLFileboxFileTypeWebsite: obj = [file content];
		break;
	}
	return [CPKeyedArchiver archivedDataWithRootObject:[obj]];
}

-(CPArray)collectionView:(CPCollectionView)collectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
	//	This code is for multiple selection. That is great and all, but I just
	//	realized that CCSlideView doesn't support multiple dragging, so screw it
	//
	// //	Get rid of all the folder indicies, and shift everything down so they correlate to file objects
	// var num_folders = [[_api folders] count];
	// [indicies removeIndexesInRange:CPMakeRange(0,num_folders-1)];
	// [indicies shiftIndexesStartingAtIndex:[indicies firstIndex] by:num_folders];
	// //	Figure out the drag types
	// var ret = [ ];
	// while([indicies count])
	// {
	// 	var current_type = [[[_api files] objectAtIndex:[indicies firstIndex]] dragType];
	// 	if(![ret containsObject:current_type])
	// 		[ret addObject:current_type];
	// 	[indicies removeIndex:[indicies firstIndex]];
	// }
	var num_folders = [[_api folders] count];
	if([indices firstIndex] < num_folders)
		return nil;
	return [[[[_api files] objectAtIndex:([indices firstIndex] - num_folders)] dragType]];
}

@end

@implementation CPApplication (LLSlideThemeSelectionPanelAdditions)

-(void)orderFrontFileboxPanel
{
	[[LLFileboxPanel sharedPanel] orderFront:self];
}

@end