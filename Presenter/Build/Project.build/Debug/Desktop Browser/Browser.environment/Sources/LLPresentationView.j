@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;28;../CoreLecture/CoreLecture.jt;751;

objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("../CoreLecture/CoreLecture.j", YES);

{var the_class = objj_allocateClassPair(CCSlideView, "LLPresentationView"),
meta_class = the_class.isa;objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("mouseDown:"), function $LLPresentationView__mouseDown_(self, _cmd, event)
{ with(self)
{

}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseDragged:"), function $LLPresentationView__mouseDragged_(self, _cmd, event)
{ with(self)
{

}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseUp:"), function $LLPresentationView__mouseUp_(self, _cmd, event)
{ with(self)
{

}
},["void","CPEvent"])]);
}

