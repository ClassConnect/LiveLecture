@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;28;../CoreLecture/CoreLecture.jt;2436;

objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("../CoreLecture/CoreLecture.j", YES);

{var the_class = objj_allocateClassPair(CPView, "CPFoldableViewItem"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_contentViewController")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("contentViewController"), function $CPFoldableViewItem__contentViewController(self, _cmd)
{ with(self)
{
return _contentViewController;
}
},["id"]),
new objj_method(sel_getUid("setContentViewController:"), function $CPFoldableViewItem__setContentViewController_(self, _cmd, newValue)
{ with(self)
{
_contentViewController = newValue;
}
},["void","id"]), new objj_method(sel_getUid("initWithTitle:contentViewController:"), function $CPFoldableViewItem__initWithTitle_contentViewController_(self, _cmd, title, contentViewController)
{ with(self)
{

}
},["id","CPString","CPViewController"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("itemWithTitle:contentViewController:"), function $CPFoldableViewItem__itemWithTitle_contentViewController_(self, _cmd, title, contentViewController)
{ with(self)
{
 return objj_msgSend(objj_msgSend(self, "alloc"), "initWithTitle:contentViewController:", title, contentViewController);
}
},["CPFoldableViewItem","CPString","CPViewController"])]);
}

{var the_class = objj_allocateClassPair(CPView, "CPFoldableView"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_items")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("items"), function $CPFoldableView__items(self, _cmd)
{ with(self)
{
return _items;
}
},["id"]),
new objj_method(sel_getUid("setItems:"), function $CPFoldableView__setItems_(self, _cmd, newValue)
{ with(self)
{
_items = newValue;
}
},["void","id"]), new objj_method(sel_getUid("initWithFrame:"), function $CPFoldableView__initWithFrame_(self, _cmd, frame)
{ with(self)
{
 if(self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("CPFoldableView").super_class }, "initWithFrame:", frame))
 {
  _items = objj_msgSend(CPMutableArray, "array");
 }
 return self;
}
},["id","CGRect"]), new objj_method(sel_getUid("setItems:"), function $CPFoldableView__setItems_(self, _cmd, items)
{ with(self)
{
 if(objj_msgSend(_items, "isEqual:", items))
  return;

}
},["void","CPArray"])]);
}

