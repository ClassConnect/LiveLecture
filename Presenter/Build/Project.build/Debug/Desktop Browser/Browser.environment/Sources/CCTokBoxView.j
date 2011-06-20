@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;21;CPArray+CCAdditions.ji;9;TokBox.jst;11470;

objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("CPArray+CCAdditions.j", YES);

objj_executeFile("TokBox.js", YES);

var kCCTokBoxAPIKey = "627682";

var show = function(element) { element.style.display = "block"; };
var hide = function(element) { element.style.display = "none"; };

{var the_class = objj_allocateClassPair(CPView, "CCTokBoxStreamView"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_streamID"), new objj_ivar("_contentElement")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("_initWithStreamObject:tokboxSession:frame:"), function $CCTokBoxStreamView___initWithStreamObject_tokboxSession_frame_(self, _cmd, stream, session, frame)
{ with(self)
{
 if(session.connection.connectionID == stream.connection.connectionID)
  return nil;
 if(self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("CCTokBoxStreamView").super_class }, "initWithFrame:", frame))
 {
  _streamID = stream.streamID;
  _contentElement = document.createElement('div');
  _contentElement.setAttribute("id", _streamID);
  _DOMElement.appendChild(_contentElement);
  session.subscribe(stream,_streamID,{width:frame.size.width,height:frame.size.height});
 }
 return self;
}
},["id","JSObject","JSObject","CGRect"]), new objj_method(sel_getUid("streamID"), function $CCTokBoxStreamView__streamID(self, _cmd)
{ with(self)
{
 return _streamID;
}
},["CPString"]), new objj_method(sel_getUid("mouseDown:"), function $CCTokBoxStreamView__mouseDown_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(objj_msgSend(CPPlatformWindow, "primaryPlatformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseDragged:"), function $CCTokBoxStreamView__mouseDragged_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(objj_msgSend(CPPlatformWindow, "primaryPlatformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseUp:"), function $CCTokBoxStreamView__mouseUp_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(objj_msgSend(CPPlatformWindow, "primaryPlatformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseMoved:"), function $CCTokBoxStreamView__mouseMoved_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(objj_msgSend(CPPlatformWindow, "primaryPlatformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"])]);
}





{var the_class = objj_allocateClassPair(CPView, "CCTokBoxView"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_die"), new objj_ivar("_sessionID"), new objj_ivar("_token"), new objj_ivar("_session"), new objj_ivar("_publisher"), new objj_ivar("_publisherDiv"), new objj_ivar("_publisherFlashElement"), new objj_ivar("_streamViews"), new objj_ivar("_streamIDs"), new objj_ivar("delegate")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("sessionID"), function $CCTokBoxView__sessionID(self, _cmd)
{ with(self)
{
return _sessionID;
}
},["id"]),
new objj_method(sel_getUid("setSessionID:"), function $CCTokBoxView__setSessionID_(self, _cmd, newValue)
{ with(self)
{
_sessionID = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("token"), function $CCTokBoxView__token(self, _cmd)
{ with(self)
{
return _token;
}
},["id"]),
new objj_method(sel_getUid("setToken:"), function $CCTokBoxView__setToken_(self, _cmd, newValue)
{ with(self)
{
_token = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("delegate"), function $CCTokBoxView__delegate(self, _cmd)
{ with(self)
{
return delegate;
}
},["id"]),
new objj_method(sel_getUid("setDelegate:"), function $CCTokBoxView__setDelegate_(self, _cmd, newValue)
{ with(self)
{
delegate = newValue;
}
},["void","id"]), new objj_method(sel_getUid("initWithFrame:"), function $CCTokBoxView__initWithFrame_(self, _cmd, frame)
{ with(self)
{
 if(self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("CCTokBoxView").super_class }, "initWithFrame:", frame))
 {
  if (TB.checkSystemRequirements() != TB.HAS_REQUIREMENTS)
  {
   alert("You don't have the minimum requirements to run this application. Please upgrade to the latest version of Flash.");
   _die = YES;
  }
  else
  {
   _sessionID = "";
   _token = "";
   _publisherDiv = document.createElement('div');
   _DOMElement.appendChild(_publisherDiv);
   _streamViews = [];
   _streamIDs = [];
  }
 }
 return self;
}
},["id","CGRect"]), new objj_method(sel_getUid("layoutSubviews"), function $CCTokBoxView__layoutSubviews(self, _cmd)
{ with(self)
{
}
},["void"]), new objj_method(sel_getUid("_session"), function $CCTokBoxView___session(self, _cmd)
{ with(self)
{
 if(!_session && !_die)
 {
  var sess = objj_msgSend(self, "sessionID");
  if(sess != "")
  {
   _session = TB.initSession(sess);
   _session.addEventListener('sessionConnected', function(event){ objj_msgSend(self, "_sessionConnected:", event); });
   _session.addEventListener('sessionDisconnected', function(event){ objj_msgSend(self, "_sessionDisconnected:", event); });
   _session.addEventListener('connectionCreated', function(event){ objj_msgSend(self, "_connectionCreated:", event); });
   _session.addEventListener('connectionDestroyed', function(event){ objj_msgSend(self, "_connectionDestroyed:", event); });
   _session.addEventListener('streamCreated', function(event){ objj_msgSend(self, "_streamCreated:", event); });
   _session.addEventListener('streamDestroyed', function(event){ objj_msgSend(self, "_streamDestroyed:", event); });
  }
  else
  {
   if(objj_msgSend(delegate, "respondsToSelector:", sel_getUid("tokbox:didFailWithError:")))
    objj_msgSend(delegate, "tokbox:didFailWithError:", self, "No Session ID set");
  }
 }
 return _session;
}
},["JSObject"]), new objj_method(sel_getUid("connect"), function $CCTokBoxView__connect(self, _cmd)
{ with(self)
{
 if(_token)
 {
  objj_msgSend(self, "_session").connect(kCCTokBoxAPIKey,_token);
  return YES;
 }
 else
  return NO;
}
},["BOOL"]), new objj_method(sel_getUid("disconnect"), function $CCTokBoxView__disconnect(self, _cmd)
{ with(self)
{
 objj_msgSend(self, "_session").disconnect();
}
},["void"]), new objj_method(sel_getUid("publish"), function $CCTokBoxView__publish(self, _cmd)
{ with(self)
{
 if(!_publisher)
 {
  var props = {width:objj_msgSend(self, "bounds").size.width,height:objj_msgSend(self, "bounds").size.height};
  _publisher = objj_msgSend(self, "_session").publish(_publisherDiv.id,props);
  _publisherFlashElement = document.getElementById(_publisher.id);
 }
 show(_publisherDiv);
}
},["void"]), new objj_method(sel_getUid("isPublishing"), function $CCTokBoxView__isPublishing(self, _cmd)
{ with(self)
{
 return (_publisher != nil);
}
},["BOOL"]), new objj_method(sel_getUid("stopPublishing"), function $CCTokBoxView__stopPublishing(self, _cmd)
{ with(self)
{
 if(_publisher)
 {
  objj_msgSend(self, "_session").unpublish(_publisher);
  _publisher = nil;
 }
 hide(_publisherDiv);
}
},["void"]), new objj_method(sel_getUid("setSessionID:"), function $CCTokBoxView__setSessionID_(self, _cmd, sessionID)
{ with(self)
{
 if(sessionID == _sessionID)
  return;
 _sessionID = sessionID;
 _publisherDiv.id = "cctokboxpublisher"+sessionID;
}
},["void","CPString"]), new objj_method(sel_getUid("mouseDown:"), function $CCTokBoxView__mouseDown_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(objj_msgSend(CPPlatformWindow, "primaryPlatformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseDragged:"), function $CCTokBoxView__mouseDragged_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(objj_msgSend(CPPlatformWindow, "primaryPlatformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseUp:"), function $CCTokBoxView__mouseUp_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(objj_msgSend(CPPlatformWindow, "primaryPlatformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseMoved:"), function $CCTokBoxView__mouseMoved_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(objj_msgSend(CPPlatformWindow, "primaryPlatformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("_addStreams:"), function $CCTokBoxView___addStreams_(self, _cmd, streams)
{ with(self)
{
 objj_msgSend(streams, "makeObjectsPerformFunction:", function(object){
  var streamview = objj_msgSend(objj_msgSend(CCTokBoxStreamView, "alloc"), "_initWithStreamObject:tokboxSession:frame:", object, objj_msgSend(self, "_session"), CGRectMake(0,0,200,200));
  if(streamview)
  {
   objj_msgSend(self, "addSubview:", streamView);
   objj_msgSend(_streamViews, "addObject:", streamView);
   objj_msgSend(_streamIDs, "addObject:", object.stream.streamID);
  }
 });
}
},["void","CPArray"]), new objj_method(sel_getUid("_removeStreams:"), function $CCTokBoxView___removeStreams_(self, _cmd, streams)
{ with(self)
{
 objj_msgSend(streams, "makeObjectsPerformFunction:", function(object){
  var i = objj_msgSend(_streamIDs, "indexOfObject:", object.stream.streamID);
  objj_msgSend(objj_msgSend(_streamViews, "objectAtIndex:", i), "removeFromSuperview");
  objj_msgSend(_streamViews, "removeObjectAtIndex:", i);
  objj_msgSend(_streamIDs, "removeObjectAtIndex:", i);
 });
 objj_msgSend(self, "setNeedsLayout");
}
},["void","CPArray"]), new objj_method(sel_getUid("_sessionConnected:"), function $CCTokBoxView___sessionConnected_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(self, "_addStreams:", event.streams);
 if(objj_msgSend(delegate, "respondsToSelector:", sel_getUid("tokboxSessionConnected:")))
  objj_msgSend(delegate, "tokboxSessionConnected:", self);
}
},["void","JSObject"]), new objj_method(sel_getUid("_sessionDisconnected:"), function $CCTokBoxView___sessionDisconnected_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(self, "_removeStreams:", event.streams);
 if(objj_msgSend(delegate, "respondsToSelector:", sel_getUid("tokboxSessionDisconnected:")))
  objj_msgSend(delegate, "tokboxSessionDisconnected:", self);
}
},["void","JSObject"]), new objj_method(sel_getUid("_connectionCreated:"), function $CCTokBoxView___connectionCreated_(self, _cmd, event)
{ with(self)
{
 if(objj_msgSend(delegate, "respondsToSelector:", sel_getUid("tokboxConnectionConnected:")))
  objj_msgSend(delegate, "tokboxConnectionConnected:", self);
}
},["void","JSObject"]), new objj_method(sel_getUid("_connectionDestroyed:"), function $CCTokBoxView___connectionDestroyed_(self, _cmd, event)
{ with(self)
{
 if(objj_msgSend(delegate, "respondsToSelector:", sel_getUid("tokboxConnectionDestroyed:")))
  objj_msgSend(delegate, "tokboxConnectionDestroyed:", self);
}
},["void","JSObject"]), new objj_method(sel_getUid("_streamCreated:"), function $CCTokBoxView___streamCreated_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(self, "_addStreams:", event.streams);
 if(objj_msgSend(delegate, "respondsToSelector:", sel_getUid("tokboxStreamCreated:")))
  objj_msgSend(delegate, "tokboxStreamCreated:", self);
}
},["void","JSObject"]), new objj_method(sel_getUid("_streamDestroyed:"), function $CCTokBoxView___streamDestroyed_(self, _cmd, event)
{ with(self)
{
 objj_msgSend(self, "_removeStreams:", event.streams);
 if(objj_msgSend(delegate, "respondsToSelector:", sel_getUid("tokboxStreamDestroyed:")))
  objj_msgSend(delegate, "tokboxStreamDestroyed:", self);
}
},["void","JSObject"])]);
}

