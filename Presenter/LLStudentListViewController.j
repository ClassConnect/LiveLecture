@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLStudentListManager.j"

@implementation LLStudentListViewController : CPViewController
{
	CPTableView _tableView;
	CPArray _studentNames;
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
	var view = [[CPView alloc] initWithFrame:CGRectMake(0,0,215,200)];
		sv = [[CPScrollView alloc] initWithFrame:CGRectMake(0,0,215,200)];
	[view setAutoresizingMask:CPViewHeightSizable];
	[sv setAutoresizingMask:CPViewHeightSizable];
	[sv setHasHorizontalScroller:YES];
	[sv setHasVerticalScroller:YES];
	_tableView = [[CPTableView alloc] initWithFrame:CGRectMake(0,0,200,200)];
	var column = [[CPTableColumn alloc] initWithIdentifier:"com.classconnect.livelecture.presentor.sidebar.students.namecolumn"];
	[[column headerView] setStringValue:"Students"];
	[column setWidth:196];
	[_tableView addTableColumn:column];
	[_tableView setUsesAlternatingRowBackgroundColors:YES];
	[_tableView setDataSource:self];
	[_tableView setDelegate:self];
	[sv setDocumentView:_tableView];
	[view addSubview:sv];
	[self setView:view];
}

-(void)numberOfRowsInTableView:(CPTableView)tableView
{
	return [_manager numberOfStudents];
}

-(void)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)column row:(CPInteger)row
{
	return [_manager nameOfStudentAtIndex:row];
}

-(void)studentsDidChange:(CPNotification)notification
{
	[_tableView reloadData];
}

@end