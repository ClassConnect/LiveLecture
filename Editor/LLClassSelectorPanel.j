@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "LLClassCollectionItem.j"

var _LLClassSelectorSharedPanel_ = nil;
var _iapiurl = "/app/livelecture/iapi_classes.php";

@implementation CCClass : CPObject
{
    int _classID @accessors(property=classID);
    CPString _name @accessors(property=name);
    CPString _imagePath @accessors(property=imagePath);
}

+(CCClass)fromJSObject:(JSObject)obj
{
    var ret = [CCClass new];
    [ret setClassID:obj.id];
    [ret setName:obj.name];
    [ret setImagePath:obj.icon];
    return ret;
}

@end

@implementation LLClassSelectorPanel : CPPanel
{
    Function _callback;
    CPArray _classes;
    
    EKActivityIndicatorView _spinner;
    CPCollectionView _collection;
}

+(id)sharedPanel
{
    if(_LLClassSelectorSharedPanel_ == nil)
        _LLClassSelectorSharedPanel_ = [[LLClassSelectorPanel alloc] init];
    return _LLClassSelectorSharedPanel_;
}

-(id)init
{
    var width = 417,
        height = 390;
    if(self = [super initWithContentRect:CGRectMake(200, 100, width, height) styleMask:CPTitledWindowMask|CPHUDBackgroundWindowMask])
    {   
        [self setTitle:"Choose your class"];
		//	CPScrollView
		var sv = [[CPScrollView alloc] initWithFrame:CGRectMake(1,0,415,350)],
			itemPrototype = [[CPCollectionViewItem alloc] init];
		[sv setAutoresizingMask:	CPViewWidthSizable |
									CPViewHeightSizable];
		[sv setHasHorizontalScroller:NO];
		[sv setBackgroundColor:[CPColor whiteColor]];
		//	CPCollectionView
		_collection = [[CPCollectionView alloc] initWithFrame:CGRectMake(0,0,400,350)];
		//  CPCollectionViewItemSize
		var cpcvis = CGSizeMake(400,75);
		[_collection setMinItemSize:cpcvis];
		[_collection setMaxItemSize:cpcvis];
		[_collection setBackgroundColor:[CPColor colorWithCSSString:"#DDDDDD"]];
		[itemPrototype setView:[[LLClassCollectionItem alloc] initWithFrame:CGRectMake(0,0,cpcvis.width,cpcvis.height)]];
		[_collection setItemPrototype:itemPrototype];
		[_collection setDelegate:self];
		[_collection setVerticalMargin:0];
		[sv setDocumentView:_collection];
		//	Buttons
		var okButton = [CPButton buttonWithTitle:"OK" theme:[CPTheme defaultHudTheme]],
			cancelButton = [CPButton buttonWithTitle:"Cancel" theme:[CPTheme defaultHudTheme]],
			buttonY = height - ((height - [sv frame].size.height - [okButton frame].size.height) / 2) - [okButton frame].size.height,
			okX = width - 10 - [okButton frame].size.width,
			cancelX = okX - 10 - [cancelButton frame].size.width;
		[okButton setFrameOrigin:CGPointMake(okX,buttonY)];
		[cancelButton setFrameOrigin:CGPointMake(cancelX,buttonY)];
		[okButton setTarget:self];
		[cancelButton setTarget:self];
		[okButton setAction:@selector(ok)];
		[cancelButton setAction:@selector(cancel)];
		//	Adding Subviews
		[[self contentView] addSubview:sv];
		[[self contentView] addSubview:okButton];
		[[self contentView] addSubview:cancelButton];
		
		[CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:_iapiurl]] delegate:self];
    }
    return self;
}

-(void)runModalWithSuccessFunction:(Function)success
{
    _callback = success;
    [self orderFront:nil];
    [[CPApplication sharedApplication] runModalForWindow:self];
}

-(void)ok
{
    //  Figure out what the selected class is, then call the callback function
    var index = [[_collection selectionIndexes] firstIndex];
    _callback(_classes[index]);
    [self cancel];
}

-(void)cancel
{
    [self close];
    [[CPApplication sharedApplication] abortModal];
}

-(void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
//    CPLog("Welp...");
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    _classes = [ ];
    var aoClasses = [data objectFromJSON];
    for(var i = 0 ; i < [aoClasses count] ; i++)
        [_classes addObject:[CCClass fromJSObject:aoClasses[i]]];
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
    [_spinner setHidden:YES];
    [_collection setContent:_classes];
}

@end