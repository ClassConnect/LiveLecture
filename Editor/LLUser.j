/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 *
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"

var __LLUSER_SHARED__ = nil

@implementation LLUser : CPObject {
	CPInteger _uid @accessors(property=userID);
	CPString _name @accessors(property=name);
	BOOL _allowed;
	BOOL _isTeacher @accessors(property=isTeacher);
	BOOL _RTEEnabled @accessors(property=RTEEnabled);
	BOOL _videoEnabled @accessors(property=videoEnabled);
}

+(id)currentUser
{
	if(__LLUSER_SHARED__ == nil)
		__LLUSER_SHARED__ = [[LLUser alloc] init];
	return __LLUSER_SHARED__;
}

-(id)init
{
	if(self = [super init])
	{
		_uid = -1;
		//	This will set up everything to be how it should be in the editor
		//	Basically, we want the user to be a teacher, but the RTE should be
		//	off.
		//	Since every bool defaults to NO, we can just set isTeacher to YES
		//
		//	In the presenter, the configureFromJSON will take care of setup
		_isTeacher = YES;
	}
	return self;
}

-(BOOL)hasControlPermission
{
	return _isTeacher;
}

-(BOOL)allowedToViewLecture
{
	return _allowed;
}

-(void)configureFromJSON:(CPString)json
{
	var obj = [json objectFromJSON];
	_allowed = [obj["allow"] boolValue];
	if(_allowed)
	{
		[self setIsTeacher:[obj["isTeacher"] boolValue]];
		[self setRTEEnabled:[obj["RTEEnabled"] boolValue]];
		[self setUserID:obj["uid"]];
		[self setName:obj["firstName"]+" "+obj["lastName"]];
		[self setVideoEnabled:obj["videoEnabled"]];
	}
	CPLog("UID:"+obj["uid"]+" LLID:"+[[LLPresentationController sharedController] livelectureID]);
}

@end