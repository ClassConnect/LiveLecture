@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;28;../CoreLecture/CoreLecture.jt;946;

objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("../CoreLecture/CoreLecture.j", YES);

{
var the_class = objj_getClass("CCSlideView")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CCSlideView\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("mouseMoved:"), function $CCSlideView__mouseMoved_(self, _cmd, event)
{ with(self)
{
 var p = objj_msgSend(self, "convertPoint:fromView:", objj_msgSend(event, "locationInWindow"), nil),
  c = objj_msgSend(LLPresentationController, "sharedController")
 if(!objj_msgSend(c, "showsSidebar") && p.x == 0)
 {
  objj_msgSend(c, "setShowsSidebar:animated:", YES, YES);
  return;
 }
 if(objj_msgSend(c, "showsSidebar") && !objj_msgSend(c, "sidebarIsLocked") && p.x > 100)
 {
  objj_msgSend(c, "setShowsSidebar:animated:", NO, YES);
  return;
 }
}
},["void","CPEvent"])]);
}

