@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLStudentListManager.j"
@import "EKActivityIndicatorView.j"

@implementation LLStudentListViewController : CPViewController
{
	EKActivityIndicatorView _activityIndicator;
	CPScrollView _scrollView;
	CPTableView _tableView;
	CPButton _button;
	
	LLStudentListManger _manager;
}

-(id)init
{
	if(self = [super init])
	{
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(studentsDidChange:) name:LLStudentListDidChangeContents object:nil];
		_manager = [LLStudentListManager defaultManager];
	}
	return self;
}

-(void)loadView
{
	_button = [CPButton buttonWithTitle:"Update List"]; // Declare it here so we can use it's height
	var view = [[CPView alloc] initWithFrame:CGRectMake(0,0,215,200)],
		buttonHeight = CGRectGetHeight([_button bounds]);
	_scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0,buttonHeight,215,200-buttonHeight)];
	[view setAutoresizingMask:CPViewHeightSizable];
	[_scrollView setAutoresizingMask:CPViewHeightSizable];
	[_scrollView setHasHorizontalScroller:YES];
	[_scrollView setHasVerticalScroller:YES];
	[_button setFrame:CGRectMake(0,0,215,buttonHeight)];
//	[_button setThemeState:CPThemeStateDefault];
	[_button setTarget:self];
	[_button setAction:@selector(refresh)];
	[_button setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:"icon_refresh.png"] size:CGSizeMake(16,16)]];
	_tableView = [[CPTableView alloc] initWithFrame:CGRectMake(0,0,200,200)];
	var column = [[CPTableColumn alloc] initWithIdentifier:"com.classconnect.livelecture.presentor.sidebar.students.namecolumn"];
	[[column headerView] setStringValue:"Student Name"];
	[column setWidth:196];
	[_tableView addTableColumn:column];
	[_tableView setUsesAlternatingRowBackgroundColors:YES];
	[_tableView setDataSource:self];
	[_tableView setDelegate:self];
	_activityIndicator = [[EKActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,64,64)];
	[_activityIndicator setAutoresizingMask:CPViewMinXMargin|CPViewMaxXMargin|CPViewMinYMargin|CPViewMaxYMargin];
	[_activityIndicator setCenter:[_scrollView center]];
	[_scrollView setDocumentView:_tableView];
	[view addSubview:_activityIndicator];
	[view addSubview:_scrollView];
	[view addSubview:_button];
	[self setView:view];
}

-(void)refresh
{
	[_button setEnabled:NO];
	[_scrollView setHidden:YES];
	[_activityIndicator setHidden:NO];
	[_activityIndicator startAnimating];
	[_manager removeAllStudents];
	[_manager requestListOfStudentsAndWait];
}

-(void)numberOfRowsInTableView:(CPTableView)tableView
{
	return [_manager numberOfStudents] ? [_manager numberOfStudents] : 1;
}

-(void)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)column row:(CPInteger)row
{
	if([_manager numberOfStudents])
		return [_manager nameOfStudentAtIndex:row];
	else
		return "No Students";
}

-(void)studentsDidChange:(CPNotification)notification
{
	[_button setEnabled:YES];
	[_scrollView setHidden:NO];
	[_activityIndicator stopAnimating];
	[_activityIndicator setHidden:YES];
	[_tableView reloadData];
}

@end