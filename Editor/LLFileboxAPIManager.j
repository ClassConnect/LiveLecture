@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

var __shared__ = nil;

//	Type Constants
kLLFileboxFileTypeMovie = "kLLFileboxFileTypeMovie";
kLLFileboxFileTypeWebsite = "kLLFileboxFileTypeWebsite";

//	Drag Type Constants
kLLFileboxFileTypeMovieDragType = "kLLFileboxFileTypeMovieDragType";
kLLFileboxFileTypeWebsiteDragType = "kLLFileboxFileTypeWebsiteDragType";

function _iapi_url_for_folder(folder)
{
	return "/app/livelecture/iapi_filebox.cc?fid="+folder;
}

function _iapi_folders_url_for_folder(folder)
{
	return "/app/livelecture/iapi_filebox_folders.cc?fid="+folder;
}

function _iapi_files_url_for_folder(folder)
{
	return "/app/livelecture/iapi_filebox_files.cc?fid="+folder;
}

///////////////////////////////////////////////////////////
//	Model Objects

@implementation LLFileboxFolder : CPObject
{
	CPInteger _id @accessors(property=id);
	CPString _name @accessors(property=name);
}
+(id)fromObject:(JSObject)obj
{
	var folder = [LLFileboxFolder new];
	folder._id = obj["id"];
	folder._name = obj["name"];
	return folder;
}
-(CPString)typeIconURL
{
	return HOST+"/app/core/site_img/fileBox/folder.png";
}
@end

@implementation LLFileboxFile : CPObject
{
	CPInteger _id @accessors(property=id);
	CPString _name @accessors(property=name);
	CPString _type @accessors(property=type);
	CPString _type_icon_url @accessors(property=typeIconURL);
	CPString _content @accessors(property=content);
}
+(id)fromObject:(JSObject)obj
{
	var file = [LLFileboxFile new];
	file._id = obj["id"];
	file._name = obj["name"];
	file._type = [self typeFromWeb:obj["type"]];
	file._type_icon_url = obj["type_icon_url"];
	file._content = obj["content"];
	return file;
}
+(CPString)typeFromWeb:(CPString)web
{
	switch(""+web)
	{
		case "3": return kLLFileboxFileTypeMovie;break;
		case "2": return kLLFileboxFileTypeWebsite;break;
	}
}
-(void)dragType
{
	switch(_type)
	{
		case kLLFileboxFileTypeMovie: return "CPVideosPboardType";break;
		case kLLFileboxFileTypeWebsite: return "CPWebsitesPboardType";break;
	}
}
@end

///////////////////////////////////////////////////////////

@implementation LLFileboxAPIManager : CPObject
{	
	CPInteger _current_folder @accessors(property=currentFolder);
	CPDictionary _contents;
	CPDictionary _cache;
	Function _callback;
}

+(id)defaultManager
{
	if(!__shared__)
		__shared__ = [[LLFileboxAPIManager alloc] init];
	return __shared__;
}

-(id)init
{
	if(self = [super init])
	{
		_cache = { };
		_contents = { };
		_callback = function(){};
		_folders_callback = function(){};
		_files_callback = function(){};
	}
	return self;
}

-(void)parentName
{
	return _contents["parent_name"];
}

-(void)folders
{
	return _contents["folders"];
}

-(void)files
{
	return _contents["files"];
}

-(void)getRootFolderContentsWithCallback:(Function)callback
{
	[self getContentsOfFolder:"0" withCallback:callback];
}

-(void)getParentFolderContentsWithCallback:(Function)callback
{
	[self getContentsOfFolder:_contents["parent_id"] withCallback:callback];
}

-(void)getContentsOfFolder:(CPInteger)folder_id withCallback:(Function)callback
{
	var cache_key = ""+folder_id;
	_current_folder = folder_id;
	if(_cache[cache_key] != NULL)
	{
		_contents = _cache[cache_key];
		callback();
	}
	else
	{
		_callback = callback;
		_connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:_iapi_url_for_folder(folder_id)]] delegate:self];
	}
}

//
//	CPURLConnection Delegate Methods
//
-(void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
	_folders = nil;
	_files = nil;
	_callback();
	_callback = function(){};
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	if(data == "")
		return;
	var obj = [data objectFromJSON],
			cache_key = ""+_current_folder,
			num_folders = [obj["folders"] count],
			num_files = [obj["files"] count];
	var folders = [CPArray array];
	for(var i = 0; i < num_folders; i++)
		folders[i] = [LLFileboxFolder fromObject:obj["folders"][i]];
	var files = [CPArray array];
	for(var i = 0; i < num_files; i++)
		files[i] = [LLFileboxFile fromObject:obj["files"][i]];
	obj["folders"] = folders;
	obj["files"] = files;
	//	Get the Parent Name
	if(""+_current_folder != ""+0)
	{
		var previous_parent = obj["parent_id"];
		//	Get Parent Name
		var previous_folders = _cache[previous_parent]["folders"];
		for(var i = 0 ; i < [previous_folders count]; i++)
		{
			var current = previous_folders[i];
			if([current id] == _current_folder)
				obj["parent_name"] = [current name];
		}
	}
	else
	{
		obj["parent_name"] = "Home";
	}
	_contents = obj;
	_cache[cache_key] = obj;
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
	_callback();
	_callback = function(){};
}

@end