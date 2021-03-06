/*
 * Created by Scott Rice
 * Copyright 2011, ClassConnect All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <Foundation/CPObjJRuntime.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"
@import "LLUser.j"
@import "LLStudentListManager.j"
@import "CCWidget+LLRTEAdditions.j"

@import "faye.js"

kLLRTEChannelEveryone = "kLLRTEChannelEveryone"
kLLRTEChannelTeachers = "kLLRTEChannelTeachers"
kLLRTEChannelStudents = "kLLRTEChannelStudents"

//	Controls
kLLRTESlideAction = "kLLRTESlideAction"
kLLRTEActionNextSlide = "kLLRTEActionNextSlide"
kLLRTEActionPreviousSlide = "kLLRTEActionPreviousSlide"
kLLRTEActionMoveToSlide = "kLLRTEActionMoveToSlide"
kLLRTEWidgetAction = "kLLRTEWidgetAction"

//	Student Requests:
kLLRTEGetStudentListRequest = "kLLRTEGetStudentListRequest"
kLLRTEStudentJoinedNotification = "kLLRTEStudentJoinedNotification"
kLLRTEStudentLeftNotification = "kLLRTEStudentLeftNotification"

//	Teacher Requests:
kLLRTECurrentSlideRequest = "kLLRTECurrentSlideRequest"

//	Personal Requests:
kLLRTEGetStudentListResponse = "kLLRTEGetStudentListResponse"
kLLRTECurrentSlideNotification = "kLLRTECurrentSlideNotification"

//	Video Enabled/Disabled
kLLRTEVideoEnabledMessage = "kLLRTEVideoEnabledMessage"
kLLRTEVideoDisabledMessage = "kLLRTEVideoDisabledMessage"

//	Stop Hosting
kLLRTEStopHostingNotification = "kLLRTEStopHostingNotification"

var __LLRTE_SHARED__ = nil

var kLLRTEURL = "http://www.ccrte.com:8124/faye"

@implementation LLRTE : CPObject {
	JSObject _connection;
	CPString _everyone;
	CPString _students;
	CPString _teachers;
	CPString _user;
	
	CPMutableArray _students;
}

+(id)sharedInstance
{
	//	If the RTE is'nt enabled, don't even bother creating an object, just give back nil all the time
	if(![self isEnabled])
		return nil;
	if(__LLRTE_SHARED__ == nil)
		__LLRTE_SHARED__ = [[LLRTE alloc] init];
	return __LLRTE_SHARED__;
}

+(BOOL)isEnabled
{
	return [[LLUser currentUser] RTEEnabled];
}

-(CPString)_channelFromConstant:(CPString)constant
{
	switch(constant)
	{
		case kLLRTEChannelEveryone:	return _everyone;
		case kLLRTEChannelTeachers: return _teachers;
		case kLLRTEChannelStudents: return _students;
		default:					return "";
	}
}

+(CPString)channelNameForUserID:(CPInteger)uid
{
	return "/livelecture/"+[[LLPresentationController sharedController] livelectureID]+"/users/"+uid;
}

-(id)init
{
	if(self = [super init])
	{
		var lid = [[LLPresentationController sharedController] livelectureID];
		_connection = new Faye.Client(kLLRTEURL);
		_everyone = "/livelecture/"+lid;
		_students = "/livelecture/"+lid+"/students";
		_teachers = "/livelecture/"+lid+"/teachers";
		_user = [LLRTE channelNameForUserID:[[LLUser currentUser] userID]];
		
		//	Subscribe to the channels that we need to
		_connection.subscribe(_everyone,function(message) {
			[self receivedMessage:message];
		});
		if([[LLUser currentUser] isTeacher])
			_connection.subscribe(_teachers,function(message) {
				[self receivedTeacherMessage:message];
			});
		else
			_connection.subscribe(_students,function(message) {
				[self receivedStudentMessage:message];
			});
		_connection.subscribe(_user,function(message) {
			[self receievedPersonalMessage:message];
		});
	}
	
	return self;
}

-(void)sendVideoStatusMessage:(BOOL)enabled
{
	var type = ((enabled) ? kLLRTEVideoEnabledMessage : kLLRTEVideoDisabledMessage);
	_connection.publish(_students,{
		type:type
	});
}

-(void)notifyOfEntry
{
	if([[LLUser currentUser] isTeacher])
		return;
	_connection.publish(_teachers,{
		type:kLLRTEStudentJoinedNotification,
		u:[[LLUser currentUser] userID],
		n:[[LLUser currentUser] name]
	});
}

-(void)notifyOfExit
{
	if([[LLUser currentUser] isTeacher])
		return;
	_connection.publish(_teachers,{
		type:kLLRTEStudentLeftNotification,
		u:[[LLUser currentUser] userID]
	});
}

-(void)requestListOfStudents
{
	_connection.publish(_students,{
		type:kLLRTEGetStudentListRequest,
		u:[[LLUser currentUser] userID]
	});
}

-(void)requestCurrentSlideIndex
{
	_connection.publish(_teachers,{
		type:kLLRTECurrentSlideRequest,
		u:[[LLUser currentUser] userID]
	});
}

-(void)sendCurrentSlideMessageToStudent:(CPInteger)student_id
{
	_connection.publish([LLRTE channelNameForUserID:student_id],{
		type:kLLRTECurrentSlideNotification,
		s:[[LLPresentationController sharedController] currentSlideIndex]
	});
}

-(void)widget:(CCWidget)widget atIndex:(CPInteger)index sendData:(JSObject)data
{
	if([widget allowedToSendData:data])
	{
		_connection.publish([self _channelFromConstant:[widget receiverChannelForData:data]],{
			type:kLLRTEWidgetAction,
			index:index,
			data:data
		});
	}
}

-(void)sendSlideAction:(CPString)action withArguments:(CPArray)args
{
	if([[LLUser currentUser] hasControlPermission])
	{
		[self _publishSlideActionWithType:kLLRTESlideAction action:action withArguments:args];
	}
}

-(void)_publishSlideActionWithType:(CPString)actionType action:(CPString)action withArguments:(CPArray)args
{
	_connection.publish(_everyone,{
		type:actionType,
		data:action,
		arguements:[args componentsJoinedByString:":LLARG:"]
	});
}

//
//	Message Callbacks
//

-(void)receivedMessage:(JSObject)message
{
	if(message.type == kLLRTESlideAction)
	{
		var args = [message.arguements componentsSeparatedByString:@":LLARG:"];
		if([[LLUser currentUser] isTeacher])
		{
			return;
		}
		switch(message.data)
		{
			case kLLRTEActionNextSlide:		[[LLPresentationController sharedController] moveToNextSlide];
											break;
			case kLLRTEActionPreviousSlide:	[[LLPresentationController sharedController] moveToPreviousSlide];
											break;
			case kLLRTEActionMoveToSlide:	[[LLPresentationController sharedController] setCurrentSlideIndex:[args objectAtIndex:0]];
											break;
			default:						CPLog("Received Everyone Message in Error");
											break;
		}
	}
	if(message.type == kLLRTEWidgetAction)
		[self handleWidgetAction:message];
	if(message.type == kLLRTEStudentJoinedNotification)
	{
		if(message.u != [[LLUser currentUser] userID])
			[[LLStudentListManager defaultManager] addStudentWithID:message.u name:message.n];
	}
	if(message.type == kLLRTEStudentLeftNotification)
	{
		[[LLStudentListManager defaultManager] removeStudentWithID:message.u];
	}
	if(message.type == kLLRTEStopHostingNotification)
	{
		window.location = "/app/class.cc?id="+message.text+"#5";
	}
}

-(void)receivedTeacherMessage:(JSObject)message
{
	if(![[LLUser currentUser] isTeacher])
		return; //SOMEONE IS BEING NAUGHTY!
	switch(message.type)
	{
		case kLLRTEStudentJoinedNotification:	[[LLStudentListManager defaultManager] addStudentWithID:message.u name:message.n];
												//[self sendCurrentSlideMessageToStudent:message.u];
												break;
		case kLLRTECurrentSlideRequest:			[self sendCurrentSlideMessageToStudent:message.u];
												break;
		case kLLRTEWidgetAction:				[self handleWidgetAction:message];
												break;
	}
}

-(void)receivedStudentMessage:(JSObject)message
{
	//	I'm not quite sure what this does. I think it is so if I receive a
	//	message from Eric's PHP Script, then it will behave correctly
	if(message.text != undefined)
		message.u = message.text;
	switch(message.type)
	{
		case kLLRTEGetStudentListRequest:		if(message.u != [[LLUser currentUser] userID])
													_connection.publish([LLRTE channelNameForUserID:message.u],{
														type:kLLRTEGetStudentListResponse,
														u:[[LLUser currentUser] userID],
														n:[[LLUser currentUser] name]
													});
												break;
		case kLLRTEStudentJoinedNotification:	if(message.u != [[LLUser currentUser] userID])
													[[LLStudentListManager defaultManager] addStudentWithID:message.u name:message.n];
												break;
		case kLLRTEStudentLeftNotification:		[[LLStudentListManager defaultManager] removeStudentWithID:message.u];
												break;
		case kLLRTEVideoEnabledMessage:			[[CPNotificationCenter defaultCenter] postNotificationName:LLPresentationVideoEnabled object:nil];
												break;
		case kLLRTEVideoDisabledMessage:		[[CPNotificationCenter defaultCenter] postNotificationName:LLPresentationVideoDisabled object:nil];
												break;
		case kLLRTEWidgetAction:				[self handleWidgetAction:message];
												break;
		default:								CPLog("Received Student Message in Error");
												break;
	}
}

-(void)receievedPersonalMessage:(JSObject)message
{
	switch(message.type)
	{
		case kLLRTEGetStudentListResponse:		[[LLStudentListManager defaultManager] addStudentWithID:message.u name:message.n];
												break;
		case kLLRTECurrentSlideNotification:	[[LLPresentationController sharedController] setCurrentSlideIndex:message.s];
												break;
		default:								CPLog("Received Personal Message in Error");
												break;
	}
}

-(void)handleWidgetAction:(JSObject)message
{
	var layer = [[[[LLPresentationController sharedController] mainSlideView] slideLayer] widgetLayers][message.index];
	[[layer widget] didReceiveData:message.data];
	[layer updateAfterReceivingData:message.data];
}

@end