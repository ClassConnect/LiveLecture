@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

LLStudentListDidChangeContents = "LLStudentListDidChangeContents"

var __LLSTUDENTLISTMANAGER_SHARED__ = nil

@implementation LLStudentListManager : CPObject
{
	CPMutableArray _students;
	
	BOOL _isWaitingForResponses;
}

+(id)defaultManager
{
	if(!__LLSTUDENTLISTMANAGER_SHARED__)
		__LLSTUDENTLISTMANAGER_SHARED__ = [[LLStudentListManager alloc] init];
	return __LLSTUDENTLISTMANAGER_SHARED__;
}

-(id)init
{
	if(self = [super init])
	{
		_students = [CPMutableArray array];
		var user = [LLUser currentUser];
		if(![user isTeacher])
		{
			[self addStudentWithID:[user userID] name:[user name]];
		}
	}
	return self;
}

-(CPInteger)numberOfStudents
{
	return [_students count];
}

-(void)addStudentWithID:(CPInteger)id name:(CPString)name
{
	var contains = NO;
	for(var i = 0 ; i < [_students count] ; i++)
		if(_students[i]["uid"] == id)
			contains = YES;
	if(!contains)
	{
		[_students addObject: { uid:id , name:name }];
		[self postNotification];
	}
}

-(void)removeStudentWithID:(CPString)id
{
	var count = [_students count];
	var removed = NO;
	for(var i = 0 ; i < count ; i++)
	{
		if(_students[i]["uid"] == id)
		{
			[_students removeObjectAtIndex:i];
			removed = YES;
		}
	}
	if(removed)
		[self postNotification];
}

-(void)removeAllStudents
{
	_students = [ ];
}

-(void)requestListOfStudentsAndWait
{
	_isWaitingForResponses = YES;
	[[LLRTE sharedInstance] requestListOfStudents];
	[CPTimer scheduledTimerWithTimeInterval:5 callback:function(){
		_isWaitingForResponses = NO;
		[self postNotification];
	} repeats:NO];
}

-(CPInteger)IDOfStudentAtIndex:(CPInteger)index
{
	return [_students[index] objectForKey:"uid"];
}

-(CPString)nameOfStudentAtIndex:(CPInteger)index
{
	return _students[index]["name"];
}

-(void)setName:(CPString)name ofStudentAtIndex:(CPInteger)index
{
	[_students[index] setObject:id forKey:"name"];
	[self postNotification];
}

-(void)setUserID:(CPInteger)id ofStudentAtIndex:(CPInteger)index
{
	[_students[index] setObject:id forKey:"uid"];
	[self postNotification];
}

-(void)postNotification
{
	//	Don't post notifications if we are waiting for a response
	//	As soon as we are done waiting, it will update the list for us
	if(_isWaitingForResponses)
		return;
	[[CPNotificationCenter defaultCenter] postNotificationName:LLStudentListDidChangeContents object:nil];
}

@end