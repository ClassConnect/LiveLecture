@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;28;../CoreLecture/CoreLecture.jt;1091;

objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("../CoreLecture/CoreLecture.j", YES);

{
var the_class = objj_getClass("CCSlideView")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CCSlideView\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("mouseMoved:"), function $CCSlideView__mouseMoved_(self, _cmd, event)
{ with(self)
{
 var sidebar = objj_msgSend(LLPresentationSideBar, "sharedInstance"),
  locationInView = objj_msgSend(self, "convertPoint:fromView:", objj_msgSend(event, "locationInWindow"), nil);
 if(!objj_msgSend(sidebar, "isDisplayed") && locationInView.x == 0)
 {
  objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setShowsSidebar:", YES);
 }
 else if(objj_msgSend(sidebar, "isDisplayed") && !objj_msgSend(sidebar, "isLocked") && objj_msgSend(event, "locationInWindow").x > 50)
 {
  objj_msgSend(objj_msgSend(LLPresentationController, "sharedController"), "setShowsSidebar:", NO);
 }
}
},["void","CPEvent"])]);
}

