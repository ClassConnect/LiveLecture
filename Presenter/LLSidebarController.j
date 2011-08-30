@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <AppKit/CPAccordionView.j>
@import "CCButton.j"
@import "LLSlidePickerController.j"
@import "LLStudentListViewController.j"
@import "LLTokBoxViewController.j"
@import "CCAutoresizingAccordionView.j"

@implementation LLSidebarController : CPViewController
{
	BOOL _locked @accessors(property=sidebarIsLocked);
	CPButtonBar _buttonBar;
	CPAccordionView _accordionView;
	LLSlidePickerController _pickerController;
	LLStudentListViewController _studentsController;
	LLTokBoxViewController _tokboxController;
}

-(void)loadView
{
    var accordianFrame;
    var view = [[CPView alloc] initWithFrame:CGRectMake(0,0,215,200)];
	[view setAutoresizingMask:CPViewHeightSizable];
	[view setBackgroundColor:[CPColor colorWithHexString:"DAE1E9"]];
    if([[LLUser currentUser] isTeacher] && [[LLUser currentUser] RTEEnabled])
    {
        var stopButton = [CCButton buttonWithTitle:"Click to stop hosting"];
        [stopButton setFrame:CGRectMake(0,0,215,25)];
        [stopButton setBordered:NO];
        [stopButton setBackgroundColor:[CPColor colorWithHexString:"F05044"]];
        [stopButton setHoverColor:[CPColor colorWithHexString:"EE3A2C"]];
        [stopButton setPushColor:[CPColor colorWithHexString:"E72C1F"]]
        [stopButton setTextColor:[CPColor whiteColor]];
        [stopButton setFont:[CPFont boldSystemFontOfSize:12]];
        [stopButton setTarget:[LLPresentationController sharedController]];
        [stopButton setAction:@selector(stopHostingLiveLecture)];
        [view addSubview:stopButton];
        accordianFrame = CGRectMake(0,25,215,175);
    }
    else
    {
        accordianFrame = CGRectMake(0,0,215,200);
    }
	//  Set up the accordian view
	var rteenabled = [[LLUser currentUser] RTEEnabled];
	_accordionView = [[CCAutoresizingAccordionView alloc] initWithFrame:accordianFrame];
	[_accordionView setAutoresizingMask:CPViewHeightSizable];
	_pickerController = [[LLSlidePickerController alloc] init];
	_tokboxController = [[LLTokBoxViewController alloc] init];
	var tokItem = [[CCAutoresizingAccordionViewItem alloc] initWithIdentifier:"com.classconnect.livelecture.presentor.sidebar.tokboxview"];
	[tokItem setLabel:"Teacher Video"];
	[tokItem setStaticHeight:234];
	[tokItem setView:[_tokboxController view]];
	[_tokboxController createStopVideoButton];
	var navItem = [[CCAutoresizingAccordionViewItem alloc] initWithIdentifier:"com.classconnect.livelecture.presentor.sidebar.slidepicker"];
	[navItem setLabel:"Jump to Slide"];
	[navItem setView:[_pickerController view]];
	_studentsController = [[LLStudentListViewController alloc] init];
	var stuItem = [[CCAutoresizingAccordionViewItem alloc] initWithIdentifier:"com.classconnect.livelecture.presentor.sidebar.studentview"];
	[stuItem setLabel:"List of Students"];
	[stuItem setView:[_studentsController view]];
	if(rteenabled)
		[_accordionView addItem:tokItem];
	if((rteenabled && [[LLUser currentUser] isTeacher]) || !rteenabled)
		[_accordionView addItem:navItem];
	if((rteenabled && [[LLUser currentUser] isTeacher]))
		[_accordionView addItem:stuItem];
	[view addSubview:_accordionView];
	[self setView:view];
}

- (void)animationDidUpdate:(CPAnimation)animation
{
	[[[[LLPresentationController sharedController] mainSlideView] slideLayer] reposition];
}

-(void)toggleLock:(id)sender
{
	[self setSidebarIsLocked:![self sidebarIsLocked]];
}

@end