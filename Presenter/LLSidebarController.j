@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <AppKit/CPAccordionView.j>
@import "../CoreLecture/CoreLecture.j"
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
	var view = [[CPView alloc] initWithFrame:CGRectMake(0,0,215,200)];
	[view setAutoresizingMask:CPViewHeightSizable];
	[view setBackgroundColor:[CPColor colorWithHexString:"DAE1E9"]];
	_buttonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0,175,215,25)];
	[_buttonBar setAutoresizingMask:CPViewMinYMargin];
	//	Lock Button
	var lockButton = [[CPButton alloc] initWithFrame:CGRectMake(0,0,35,25)],
		lockImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:"icon_bar_button_lock.png"] size:CGSizeMake(20,20)];
	[lockButton setBordered:NO];
	[lockButton setImage:lockImage];
	[lockButton setImagePosition:CPImageOnly];
	[lockButton setTarget:self];
	[lockButton setAction:@selector(toggleLock:)];
	//	Stop Hosting LiveLecture button
	var stopButton = [[CPButton alloc] initWithFrame:CGRectMake(0,0,35,25)];
		stopImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:"icon_bar_button_stop.png"] size:CGSizeMake(20,20)];
	[stopButton setBordered:NO];
	[stopButton setImage:lockImage];
	[stopButton setImagePosition:CPImageOnly];
	[stopButton setTarget:[LLPresentationController sharedController]];
	[stopButton setAction:@selector(stopHostingLiveLecture)];
	//	Add buttons to bar
	//	If they are viewing this from Archive (which will be able to be told
	//	by them being a teacher but having the RTE disabled), then they should
	//	not have a stop button.
	if([[LLUser currentUser] isTeacher] && [[LLUser currentUser] RTEEnabled])
		[_buttonBar setButtons:[lockButton, stopButton]];
	else
		[_buttonBar setButtons:[lockButton]];
	//	Setup the accordionview
	var rteenabled = [[LLUser currentUser] RTEEnabled];
	_accordionView = [[CCAutoresizingAccordionView alloc] initWithFrame:CGRectMake(0,0,215,175)];
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
	[view addSubview:_buttonBar];
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