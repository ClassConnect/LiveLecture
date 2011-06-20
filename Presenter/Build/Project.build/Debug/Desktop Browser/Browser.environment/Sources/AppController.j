@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;28;../CoreLecture/CoreLecture.ji;26;LLPresentationController.ji;28;LLPresentationEventHandler.ji;7;LLRTE.ji;8;LLUser.ji;35;../LLSharedUtilities/LLQuizWidget.ji;40;../LLSharedUtilities/LLQuizWidgetLayer.ji;32;CCSlideView+LLSidebarAdditions.ji;21;LLSidebarController.jt;9030;objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("../CoreLecture/CoreLecture.j", YES);
objj_executeFile("LLPresentationController.j", YES);
objj_executeFile("LLPresentationEventHandler.j", YES);
objj_executeFile("LLRTE.j", YES);
objj_executeFile("LLUser.j", YES);
objj_executeFile("../LLSharedUtilities/LLQuizWidget.j", YES);
objj_executeFile("../LLSharedUtilities/LLQuizWidgetLayer.j", YES);
objj_executeFile("CCSlideView+LLSidebarAdditions.j", YES);
objj_executeFile("LLSidebarController.j", YES);
{var the_class = objj_allocateClassPair(CPObject, "AppController"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_contentView"), new objj_ivar("_label"), new objj_ivar("_progressBar"), new objj_ivar("_timer"), new objj_ivar("_loadConnection"), new objj_ivar("_configConnection"), new objj_ivar("_controller")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("applicationDidFinishLaunching:"), function $AppController__applicationDidFinishLaunching_(self, _cmd, aNotification)
{ with(self)
{
 CPLogRegister(CPLogConsole);
    var theWindow = objj_msgSend(objj_msgSend(CPWindow, "alloc"), "initWithContentRect:styleMask:", CGRectMakeZero(), CPBorderlessBridgeWindowMask),
        contentView = objj_msgSend(theWindow, "contentView");
 _contentView = contentView;
 _controller = objj_msgSend(LLPresentationController, "sharedController");
 objj_msgSend(theWindow, "orderFront:", self);
 var args = objj_msgSend(objj_msgSend(CPApplication, "sharedApplication"), "namedArguments");
 objj_msgSend(_contentView, "setBackgroundColor:", objj_msgSend(CPColor, "blackColor"));
 if(objj_msgSend(args, "containsKey:", "lid") || objj_msgSend(args, "containsKey:", "fid"))
 {
  var url;
  if(objj_msgSend(args, "containsKey:", "lid"))
  {
   var lid = objj_msgSend(args, "objectForKey:", "lid");
   objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setIsFile:", YES);
   objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setLivelectureID:", lid);
   url = objj_msgSend(CPURL, "URLWithString:", "/app/livelecture/config.cc?lid="+lid);
  }
  else
  {
   var fid = objj_msgSend(args, "objectForKey:", "fid"),
    cid = objj_msgSend(args, "objectForKey:", "cid");
   objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setIsFile:", YES);
   objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setLiveLectureID:", lid);
   objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setClassID:", cid)
   url = objj_msgSend(CPURL, "URLWithString:", "/app/livelecture/config.cc?fid="+fid+"&cid="+cid);
  }
  var req = objj_msgSend(CPURLRequest, "requestWithURL:", url),
   _configConnection = objj_msgSend(objj_msgSend(CPURLConnection, "alloc"), "initWithRequest:delegate:startImmediately:", req, self, NO);
  var cvc = objj_msgSend(contentView, "center");
  _progressBar = objj_msgSend(objj_msgSend(CPProgressIndicator, "alloc"), "initWithFrame:", CGRectMake(0,0,200,15));
  objj_msgSend(_progressBar, "setStyle:", CPProgressIndicatorBarStyle);
  objj_msgSend(_progressBar, "setCenter:", CGPointMake(cvc.x,cvc.y + 7.5 + 5));
  objj_msgSend(_progressBar, "setAutoresizingMask:", CPViewMinXMargin|CPViewMaxXMargin|CPViewMinYMargin|CPViewMaxYMargin);
  _label = objj_msgSend(CPTextField, "labelWithTitle:", "Loading LiveLecture Presentation");
  objj_msgSend(_label, "setTextColor:", objj_msgSend(CPColor, "whiteColor"));
  objj_msgSend(_label, "setCenter:", CGPointMake(cvc.x,cvc.y - (objj_msgSend(_label, "frameSize").height / 2) - 5));
  objj_msgSend(_label, "setAutoresizingMask:", CPViewMinXMargin|CPViewMaxXMargin|CPViewMinYMargin|CPViewMaxYMargin);
  objj_msgSend(contentView, "addSubview:", _progressBar);
  objj_msgSend(contentView, "addSubview:", _label);
  objj_msgSend(_configConnection, "start");
 }
 else
 {
  objj_msgSend(self, "showErrorMessage:", "An error has occured. Please hit the back button and try to reopen LiveLecture");
 }
}
},["void","CPNotification"]), new objj_method(sel_getUid("showErrorMessage:"), function $AppController__showErrorMessage_(self, _cmd, message)
{ with(self)
{
 objj_msgSend(_label, "removeFromSuperview");
 objj_msgSend(_progressBar, "removeFromSuperview");
 var tfield = objj_msgSend(CPTextField, "labelWithTitle:", message);
 objj_msgSend(tfield, "setTextColor:", objj_msgSend(CPColor, "whiteColor"));
 objj_msgSend(tfield, "setCenter:", objj_msgSend(_contentView, "center"));
 objj_msgSend(tfield, "setAutoresizingMask:", CPViewMinXMargin|CPViewMinYMargin|CPViewMaxXMargin|CPViewMaxYMargin);
 objj_msgSend(_contentView, "addSubview:", tfield);
}
},["void","CPString"]), new objj_method(sel_getUid("connection:didReceiveData:"), function $AppController__connection_didReceiveData_(self, _cmd, connection, data)
{ with(self)
{
 if(connection == _loadConnection)
 {
  if(!objj_msgSend(data, "isEqual:", ""))
   objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setPresentation:", objj_msgSend(CPKeyedUnarchiver, "unarchiveObjectWithData:", objj_msgSend(CPData, "dataWithRawString:", data)));
  else
   objj_msgSend(self, "showErrorMessage:", "An error has occured. Please hit the back button and try to reopen LiveLecture");
 }
 else
  objj_msgSend(objj_msgSend(LLUser, "currentUser"), "configureFromJSON:", data);
}
},["void","CPURLConnection","CPString"]), new objj_method(sel_getUid("connectionDidFinishLoading:"), function $AppController__connectionDidFinishLoading_(self, _cmd, connection)
{ with(self)
{
 if(connection == _loadConnection)
 {
  var view = objj_msgSend(objj_msgSend(CCSlideView, "alloc"), "initWithFrame:", objj_msgSend(_contentView, "bounds")),
   sidebarController = objj_msgSend(objj_msgSend(LLSidebarController, "alloc"), "init");
  objj_msgSend(view, "setAutoresizingMask:",  CPViewWidthSizable |
          CPViewHeightSizable );
  objj_msgSend(view, "setDelegate:", objj_msgSend(LLPresentationEventHandler, "new"));
  objj_msgSend(_controller, "setMainSlideView:", view);
  objj_msgSend(view, "setBackgroundColor:", objj_msgSend(CPColor, "blackColor"));
  objj_msgSend(objj_msgSend(sidebarController, "view"), "setFrame:", CGRectMake(0-objj_msgSend(objj_msgSend(sidebarController, "view"), "frameSize").width,0,objj_msgSend(objj_msgSend(sidebarController, "view"), "frameSize").width,objj_msgSend(_contentView, "frame").size.height));
  objj_msgSend(_contentView, "addSubview:", objj_msgSend(sidebarController, "view"));
  objj_msgSend(_controller, "setSidebarController:", sidebarController);
  objj_msgSend(_controller, "setCurrentSlideIndex:", 0);
  objj_msgSend(LLRTE, "sharedInstance");
  objj_msgSend(view, "setSlide:", objj_msgSend(_controller, "currentSlide"));
  objj_msgSend(view, "setIsPresenting:", YES);
  objj_msgSend(objj_msgSend(CPNotificationCenter, "defaultCenter"), "addObserver:selector:name:object:", objj_msgSend(view, "slideLayer"), sel_getUid("resize"), "CPViewFrameDidChangeNotification", nil);
  objj_msgSend(_contentView, "setPostsFrameChangedNotifications:", YES);
  objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setShowsSidebar:animated:", YES, NO);
  objj_msgSend(_label, "removeFromSuperview");
  objj_msgSend(_progressBar, "removeFromSuperview");
  objj_msgSend(_contentView, "addSubview:", view);
  objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setShowsSidebar:animated:", NO, YES);
  objj_msgSend(objj_msgSend(LLRTE, "sharedInstance"), "notifyOfEntry");
  objj_msgSend(objj_msgSend(LLRTE, "sharedInstance"), "requestListOfStudents");
  window.onbeforeunload = function()
  {
   objj_msgSend(objj_msgSend(LLRTE, "sharedInstance"), "notifyOfExit");
   if(confirm("Would you like to stop hosting this LiveLecture?"))
   {
    alert("Stop Hosting!");
   }
   else
   {
    alert("Keep it open!");
   }
   return;
  }
 }
 else
 {
  if(!objj_msgSend(objj_msgSend(LLUser, "currentUser"), "allowedToViewLecture"))
  {
   objj_msgSend(self, "showErrorMessage:", "You are not allowed to view this LiveLecture");
   return;
  }
  objj_msgSend(_label, "setStringValue:", "Loading LiveLecture Presentation");
  objj_msgSend(_progressBar, "setDoubleValue:", 10);
  var urlstr = "/app/livelecture/load.cc?"+((objj_msgSend(_controller, "isFile")) ? "lid" : "fid")+"="+objj_msgSend(_controller, "livelectureID")+((objj_msgSend(_controller, "isFile")) ? "&cid="+objj_msgSend(_controller, "classID") : "");
  var req = objj_msgSend(CPURLRequest, "requestWithURL:", objj_msgSend(CPURL, "URLWithString:", urlstr));
  _loadConnection = objj_msgSend(objj_msgSend(CPURLConnection, "alloc"), "initWithRequest:delegate:startImmediately:", req, self, NO);
  _timer = objj_msgSend(CPTimer, "scheduledTimerWithTimeInterval:callback:repeats:", .5, function(){
   if(objj_msgSend(_progressBar, "doubleValue") < 90)
    objj_msgSend(_progressBar, "incrementBy:", 5);
  }, YES);
  objj_msgSend(_loadConnection, "start");
 }
}
},["void","CPURLConnection"])]);
}

