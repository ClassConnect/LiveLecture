@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;28;../CoreLecture/CoreLecture.ji;26;LLPresentationController.ji;7;LLRTE.jt;2102;

objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("../CoreLecture/CoreLecture.j", YES);
objj_executeFile("LLPresentationController.j", YES);
objj_executeFile("LLRTE.j", YES);

{var the_class = objj_allocateClassPair(CPObject, "LLPresentationEventHandler"),
meta_class = the_class.isa;objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("slideView:mouseClickedAtPoint:"), function $LLPresentationEventHandler__slideView_mouseClickedAtPoint_(self, _cmd, slideView, point)
{ with(self)
{
 if(objj_msgSend(objj_msgSend(LLUser, "currentUser"), "hasControlPermission"))
 {


 }
}
},["void","CCSlideView","CGPoint"]), new objj_method(sel_getUid("slideViewDidPressEscapeKey:"), function $LLPresentationEventHandler__slideViewDidPressEscapeKey_(self, _cmd, slideView)
{ with(self)
{

}
},["void","CCSlideView"]), new objj_method(sel_getUid("slideViewDidPressRightArrowKey:"), function $LLPresentationEventHandler__slideViewDidPressRightArrowKey_(self, _cmd, slideView)
{ with(self)
{
 if(objj_msgSend(objj_msgSend(LLUser, "currentUser"), "hasControlPermission"))
 {
  objj_msgSend(objj_msgSend(LLRTE, "sharedInstance"), "sendSlideAction:withArguments:", kLLRTEActionNextSlide, nil);
  objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "moveToNextSlide");
 }
}
},["void","CCSlideView"]), new objj_method(sel_getUid("slideViewDidPressLeftArrowKey:"), function $LLPresentationEventHandler__slideViewDidPressLeftArrowKey_(self, _cmd, slideView)
{ with(self)
{
 if(objj_msgSend(objj_msgSend(LLUser, "currentUser"), "hasControlPermission"))
 {
  objj_msgSend(objj_msgSend(LLRTE, "sharedInstance"), "sendSlideAction:withArguments:", kLLRTEActionPreviousSlide, nil);
  objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "moveToPreviousSlide");
 }
}
},["void","CCSlideView"]), new objj_method(sel_getUid("slideView:didPressKey:"), function $LLPresentationEventHandler__slideView_didPressKey_(self, _cmd, slideView, key)
{ with(self)
{

}
},["void","CCSlideView","char"])]);
}

