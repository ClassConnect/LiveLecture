@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;28;../CoreLecture/CoreLecture.ji;21;CPPropertyAnimation.ji;21;LLSidebarController.jt;8853;objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("../CoreLecture/CoreLecture.j", YES);
objj_executeFile("CPPropertyAnimation.j", YES);
objj_executeFile("LLSidebarController.j", YES);
var __LLPRESENTATION_SHARED__ = nil;
{var the_class = objj_allocateClassPair(CPObject, "LLPresentationController"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_llid"), new objj_ivar("_classID"), new objj_ivar("_isFile"), new objj_ivar("presentation"), new objj_ivar("_showsSidebar"), new objj_ivar("_currentSlideIndex"), new objj_ivar("sidebarController"), new objj_ivar("mainSlideView")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("livelectureID"), function $LLPresentationController__livelectureID(self, _cmd)
{ with(self)
{
return _llid;
}
},["id"]),
new objj_method(sel_getUid("setLivelectureID:"), function $LLPresentationController__setLivelectureID_(self, _cmd, newValue)
{ with(self)
{
_llid = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("classID"), function $LLPresentationController__classID(self, _cmd)
{ with(self)
{
return _classID;
}
},["id"]),
new objj_method(sel_getUid("setClassID:"), function $LLPresentationController__setClassID_(self, _cmd, newValue)
{ with(self)
{
_classID = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("isFile"), function $LLPresentationController__isFile(self, _cmd)
{ with(self)
{
return _isFile;
}
},["id"]),
new objj_method(sel_getUid("setIsFile:"), function $LLPresentationController__setIsFile_(self, _cmd, newValue)
{ with(self)
{
_isFile = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("presentation"), function $LLPresentationController__presentation(self, _cmd)
{ with(self)
{
return presentation;
}
},["id"]),
new objj_method(sel_getUid("setPresentation:"), function $LLPresentationController__setPresentation_(self, _cmd, newValue)
{ with(self)
{
presentation = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("showsSidebar"), function $LLPresentationController__showsSidebar(self, _cmd)
{ with(self)
{
return _showsSidebar;
}
},["id"]),
new objj_method(sel_getUid("setShowsSidebar:"), function $LLPresentationController__setShowsSidebar_(self, _cmd, newValue)
{ with(self)
{
_showsSidebar = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("currentSlideIndex"), function $LLPresentationController__currentSlideIndex(self, _cmd)
{ with(self)
{
return _currentSlideIndex;
}
},["id"]),
new objj_method(sel_getUid("setCurrentSlideIndex:"), function $LLPresentationController__setCurrentSlideIndex_(self, _cmd, newValue)
{ with(self)
{
_currentSlideIndex = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("sidebarController"), function $LLPresentationController__sidebarController(self, _cmd)
{ with(self)
{
return sidebarController;
}
},["id"]),
new objj_method(sel_getUid("setSidebarController:"), function $LLPresentationController__setSidebarController_(self, _cmd, newValue)
{ with(self)
{
sidebarController = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("mainSlideView"), function $LLPresentationController__mainSlideView(self, _cmd)
{ with(self)
{
return mainSlideView;
}
},["id"]),
new objj_method(sel_getUid("setMainSlideView:"), function $LLPresentationController__setMainSlideView_(self, _cmd, newValue)
{ with(self)
{
mainSlideView = newValue;
}
},["void","id"]), new objj_method(sel_getUid("init"), function $LLPresentationController__init(self, _cmd)
{ with(self)
{
 if(self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("LLPresentationController").super_class }, "init")) {
  presentation = objj_msgSend(objj_msgSend(CCPresentation, "alloc"), "init");
 }
 return self;
}
},["id"]), new objj_method(sel_getUid("newSlide"), function $LLPresentationController__newSlide(self, _cmd)
{ with(self)
{
 var slide = objj_msgSend(objj_msgSend(CCSlide, "alloc"), "init");
 objj_msgSend(objj_msgSend(presentation, "slides"), "addObject:", slide);
 objj_msgSend(self, "setCurrentSlideIndex:", objj_msgSend(self, "numberOfSlides")-1);
}
},["void"]), new objj_method(sel_getUid("numberOfSlides"), function $LLPresentationController__numberOfSlides(self, _cmd)
{ with(self)
{
 return objj_msgSend(objj_msgSend(presentation, "slides"), "count");
}
},["int"]), new objj_method(sel_getUid("slideAtIndex:"), function $LLPresentationController__slideAtIndex_(self, _cmd, index)
{ with(self)
{
 return objj_msgSend(objj_msgSend(presentation, "slides"), "objectAtIndex:", index);
}
},["CCSlide","int"]), new objj_method(sel_getUid("indexOfSlide:"), function $LLPresentationController__indexOfSlide_(self, _cmd, slide)
{ with(self)
{
 return objj_msgSend(objj_msgSend(presentation, "slides"), "indexOfObject:", slide);
}
},["int","CCSlide"]), new objj_method(sel_getUid("allSlides"), function $LLPresentationController__allSlides(self, _cmd)
{ with(self)
{
 return objj_msgSend(presentation, "slides");
}
},["CPArray"]), new objj_method(sel_getUid("setCurrentSlideIndex:"), function $LLPresentationController__setCurrentSlideIndex_(self, _cmd, currentSlideIndex)
{ with(self)
{
 if(_currentSlideIndex == currentSlideIndex)
  return;
 _currentSlideIndex = currentSlideIndex;
 objj_msgSend(mainSlideView, "setSlide:", objj_msgSend(self, "currentSlide"));
}
},["void","int"]), new objj_method(sel_getUid("currentSlide"), function $LLPresentationController__currentSlide(self, _cmd)
{ with(self)
{
 return objj_msgSend(self, "slideAtIndex:", objj_msgSend(self, "currentSlideIndex"));
}
},["CCSlide"]), new objj_method(sel_getUid("setCurrentSlide:"), function $LLPresentationController__setCurrentSlide_(self, _cmd, slide)
{ with(self)
{
 objj_msgSend(self, "setCurrentSlideIndex:", objj_msgSend(self, "indexOfSlide:", slide));
}
},["void","CCSlide"]), new objj_method(sel_getUid("moveToNextSlide"), function $LLPresentationController__moveToNextSlide(self, _cmd)
{ with(self)
{
 if(objj_msgSend(self, "numberOfSlides") != objj_msgSend(self, "currentSlideIndex")+1)
 {
  objj_msgSend(self, "setCurrentSlideIndex:", objj_msgSend(self, "currentSlideIndex")+1);
 }
}
},["void"]), new objj_method(sel_getUid("moveToPreviousSlide"), function $LLPresentationController__moveToPreviousSlide(self, _cmd)
{ with(self)
{
 if(objj_msgSend(self, "currentSlideIndex"))
 {
  objj_msgSend(self, "setCurrentSlideIndex:", objj_msgSend(self, "currentSlideIndex")-1);
 }
}
},["void"]), new objj_method(sel_getUid("setShowsSidebar:animated:"), function $LLPresentationController__setShowsSidebar_animated_(self, _cmd, showsSidebar, animated)
{ with(self)
{
 if(showsSidebar == _showsSidebar)
  return;
 _showsSidebar = showsSidebar;
 var sidebar = objj_msgSend(sidebarController, "view"),
  sbf = objj_msgSend(sidebar, "frame"),
  svf = objj_msgSend(mainSlideView, "frame"),
  height = sbf.size.height,
  oldSidebarFrame = ((_showsSidebar) ? CGRectMake(0-sbf.size.width,0,sbf.size.width,height) : CGRectMake(0,0,sbf.size.width,height)),
  oldSlideViewFrame = ((_showsSidebar) ? CGRectMake(0,0,svf.size.width,height) : CGRectMake(sbf.size.width,0,svf.size.width,height)),
  newSidebarFrame = ((_showsSidebar) ? CGRectMake(0,0,sbf.size.width,height) : CGRectMake(0-sbf.size.width,0,sbf.size.width,height)),
  newSlideViewFrame = ((_showsSidebar) ? CGRectMake(sbf.size.width,0,svf.size.width - sbf.size.width,height) : CGRectMake(0,0,svf.size.width+sbf.size.width,height));
 if(animated)
 {
  var sidebaranimation = objj_msgSend(objj_msgSend(CPPropertyAnimation, "alloc"), "initWithView:", sidebar),
   slideviewanimation = objj_msgSend(objj_msgSend(CPPropertyAnimation, "alloc"), "initWithView:", mainSlideView);
  objj_msgSend(sidebaranimation, "setDuration:", .5);
  objj_msgSend(slideviewanimation, "setDuration:", .5);
  objj_msgSend(slideviewanimation, "setDelegate:", sidebarController);
  objj_msgSend(sidebaranimation, "addProperty:start:end:", "frame", oldSidebarFrame, newSidebarFrame);
  objj_msgSend(slideviewanimation, "addProperty:start:end:", "frame", oldSlideViewFrame, newSlideViewFrame);
  objj_msgSend(sidebaranimation, "startAnimation");
  objj_msgSend(slideviewanimation, "startAnimation");
 }
 else
 {
  objj_msgSend(sidebar, "setFrame:", newSidebarFrame);
  objj_msgSend(mainSlideView, "setFrame:", newSlideViewFrame);
 }
}
},["void","BOOL","BOOL"]), new objj_method(sel_getUid("sidebarIsLocked"), function $LLPresentationController__sidebarIsLocked(self, _cmd)
{ with(self)
{
 return objj_msgSend(sidebarController, "sidebarIsLocked");
}
},["BOOL"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("sharedController"), function $LLPresentationController__sharedController(self, _cmd)
{ with(self)
{
 if(__LLPRESENTATION_SHARED__ == nil) {
  __LLPRESENTATION_SHARED__ = objj_msgSend(objj_msgSend(LLPresentationController, "alloc"), "init");
 }
 return __LLPRESENTATION_SHARED__;
}
},["id"])]);
}

