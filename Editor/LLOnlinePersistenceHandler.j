@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "LPURLPostRequest.j"
@import "LLPresentationController.j"
@import "LLPowerpointConverter.j"

var __LLONLINEPERSISTENCEHANDLER_SHARED__ = nil;

//var kLLLoadURL = "/app/livelecture/pptconversiontest.php";
var kLLLoadURL = HOST+"/app/livelecture/load.cc";
var kLLSaveURL = HOST+"/app/livelecture/save.cc";

LLOnlinePersistanceSaveSuccessful = "LLOnlinePersistanceSaveSuccessful";
LLOnlinePersistanceLoadSuccessful = "LLOnlinePersistanceLoadSuccessful";

@implementation LLOnlinePersistenceHandler : CPObject
{
	int _fid @accessors(property=liveLectureID);
	CPURLConnection _saveConnection;
	CPURLConnection _loadConnection;
}

+(id)sharedHandler
{
	if(!__LLONLINEPERSISTENCEHANDLER_SHARED__)
		__LLONLINEPERSISTENCEHANDLER_SHARED__ = [[LLOnlinePersistenceHandler alloc] init];
	return __LLONLINEPERSISTENCEHANDLER_SHARED__;
}

-(id)init
{
	if(self = [super init])
	{
		[self setFileID:[[[CPApplication sharedApplication] namedArguments] objectForKey:@"fid"]];
	}
	return self;
}

-(void)setFileID:(int)fid
{
	if(_fid == fid)
		return;
		
	_fid = fid;
}

-(BOOL)save
{
	var data = [CPKeyedArchiver archivedDataWithRootObject:[[LLPresentationController sharedController] presentation]];
	var req = [LPURLPostRequest requestWithURL:[CPURL URLWithString:kLLSaveURL]];
	[req setContent:{
		fid:_fid,
		data:[data rawString]
	}];
	_saveConnection = [[CPURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
	[[LLPresentationController sharedController] setDirty:YES];
	[_saveConnection start];
	[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:"Saving" message:"Your presentation is now saving..." icon:TNGrowlIconInfo];
}

-(void)load
{
	_loadConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:(kLLLoadURL+"?fid="+_fid)]] delegate:self startImmediately:NO];
	[_loadConnection start];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	if(connection == _saveConnection)
	{
		var obj = [data objectFromJSON];
		if(obj["success"] == true)
		{
			[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:@"Save Successful!" message:"You have successfully saved your presentation" icon:TNGrowlIconInfo];
			[[LLPresentationController sharedController] setDirty:NO];
		}
		else
		{
			if(obj["needsLogin"] == true)
			{
				[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:"Save Failed" 
																 message:"You need to log in to save. Click here to log in, then try again" 
															  customIcon:TNGrowlIconError 
																  target:self 
																  action:@selector(openLoginWindow)
														actionParameters:nil];
			}
			else
				[[TNGrowlCenter defaultCenter] pushNotificationWithTitle:"Save Failed" message:obj["errorString"] icon:TNGrowlIconError];
		}
	}
	else
	{
		if(data != "")
		{
			var presentation = nil;
			if(""+data.charAt(0) != "2")
			{
				presentation = [LLPowerpointConverter convertPresentation:data];
			}
			else
			{
				presentation = [CPKeyedUnarchiver unarchiveObjectWithData:[CPData dataWithRawString:data]];
			}
			[[LLPresentationController sharedController] setPresentation:presentation];
		}
		else
		{
			//	There is nothing in this LiveLecture.
			//	To make sure they save on their way out,
			//	 we set the Lecture as Dirty
			[[LLPresentationController sharedController] setDirty:YES];
		}
	}
}

-(void)openLoginWindow
{
	window.open("/app/login.cc");
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
	var notifname = ((connection == _saveConnection) ? LLOnlinePersistanceSaveSuccessful : LLOnlinePersistanceLoadSuccessful);
	[[CPNotificationCenter defaultCenter] postNotificationName:notifname object:nil];
}

-(void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
	//	Tell the user whether saving or loading was the function that failed
	if(connection == _saveConnection)
	{
		alert("Your presentation could not be saved. Make sure you are connected to the internet, and try again later");
	}
	else
	{
		alert("Your presentation could not be loaded. Make sure you are connected to the internet, and try again later");
	}
}

@end