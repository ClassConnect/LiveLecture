@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;21;CPArray+CCAdditions.jt;4083;

objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("CPArray+CCAdditions.j", YES);

{var the_class = objj_allocateClassPair(CPAccordionViewItem, "CCAutoresizingAccordionViewItem"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_staticHeight")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("staticHeight"), function $CCAutoresizingAccordionViewItem__staticHeight(self, _cmd)
{ with(self)
{
return _staticHeight;
}
},["id"]),
new objj_method(sel_getUid("setStaticHeight:"), function $CCAutoresizingAccordionViewItem__setStaticHeight_(self, _cmd, newValue)
{ with(self)
{
_staticHeight = newValue;
}
},["void","id"]), new objj_method(sel_getUid("initWithIdentifier:"), function $CCAutoresizingAccordionViewItem__initWithIdentifier_(self, _cmd, identifier)
{ with(self)
{
 if(self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("CCAutoresizingAccordionViewItem").super_class }, "initWithIdentifier:", identifier))
 {
  _staticHeight = -1;
 }
 return self;
}
},["id","CPString"])]);
}

{var the_class = objj_allocateClassPair(CPAccordionView, "CCAutoresizingAccordionView"),
meta_class = the_class.isa;objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("_resizableItemHeight"), function $CCAutoresizingAccordionView___resizableItemHeight(self, _cmd)
{ with(self)
{



 var hoh = ((objj_msgSend(objj_msgSend(self, "items"), "count")) * (objj_msgSend(objj_msgSend(self, "itemHeaderPrototype"), "frame").size.height)),
  cs = (objj_msgSend(self, "frameSize").height - hoh),
  ei = objj_msgSend(objj_msgSend(self, "items"), "objectsAtIndexes:", objj_msgSend(self, "expandedItemIndexes")),
  nori = objj_msgSend(ei, "count");
 for (var i = 0 ; i < objj_msgSend(ei, "count") ; i++)
 {
  var item = objj_msgSend(ei, "objectAtIndex:", i);
  if(objj_msgSend(item, "staticHeight") != -1)
  {
   cs -= objj_msgSend(item, "staticHeight");
   nori--;
  }
 }
 CPLog("CS:"+cs+" NORI:"+nori+" CS/NORI:"+(cs/nori));
 if(nori == 0)
  return 0;
 if(cs <= 0)
  return 0;
 return (cs / nori);
}
},["CPInteger"]), new objj_method(sel_getUid("layoutSubviews"), function $CCAutoresizingAccordionView__layoutSubviews(self, _cmd)
{ with(self)
{
 var heightOfHeaders = ((objj_msgSend(objj_msgSend(self, "items"), "count")) * (objj_msgSend(objj_msgSend(self, "itemHeaderPrototype"), "frame").size.height)),
  contentSize = (objj_msgSend(self, "frameSize").height - heightOfHeaders),
  expandedItems = objj_msgSend(objj_msgSend(self, "items"), "objectsAtIndexes:", objj_msgSend(self, "expandedItemIndexes")),
  newViewHeight = objj_msgSend(self, "_resizableItemHeight");
 objj_msgSend(expandedItems, "makeObjectsPerformFunction:", function(item) {
  var v = objj_msgSend(item, "view");
  objj_msgSend(v, "setFrameSize:", CGSizeMake(objj_msgSend(v, "frameSize").width,((objj_msgSend(item, "staticHeight") == -1) ? newViewHeight : objj_msgSend(item, "staticHeight"))));
 });
 var y = 0,
  width = objj_msgSend(self, "frameSize").width,
  headerHeight = objj_msgSend(_itemViews[0]._headerView, "frame").size.height;
 objj_msgSend(_itemViews, "makeObjectsPerformFunction:", function(item) {


  var contentHeight = objj_msgSend(item._contentView, "frame").size.height;
  objj_msgSend(item._headerView, "setFrameSize:", CGSizeMake(width,headerHeight));
  objj_msgSend(item._contentView, "setFrameOrigin:", CGPointMake(0.0,headerHeight));
  objj_msgSend(item._contentView, "setFrameSize:", CGSizeMake(width,contentHeight));

  var frameAnimation = objj_msgSend(objj_msgSend(CPPropertyAnimation, "alloc"), "initWithView:", item);
  objj_msgSend(frameAnimation, "setDuration:", .1);
  var endFrame = ((objj_msgSend(item, "isCollapsed")) ? CGRectMake(0,y,width,headerHeight) : CGRectMake(0,y,width,contentHeight + headerHeight));
  objj_msgSend(frameAnimation, "addProperty:start:end:", "frame", objj_msgSend(item, "frame"), endFrame);
  objj_msgSend(frameAnimation, "startAnimation");
  y = CGRectGetMaxY(endFrame);
 });
}
},["void"])]);
}

