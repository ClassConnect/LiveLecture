@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

LLStudentListDidChangeContents = "LLStudentListDidChangeContents"

var __LLSTUDENTLISTMANAGER_SHARED__ = nil

@implementation LLStudentListManager : CPObject
{
	CPMutableArray _students;
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
	CPLog("Received remove student message");
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
	[[CPNotificationCenter defaultCenter] postNotificationName:LLStudentListDidChangeContents object:nil];
}

@end