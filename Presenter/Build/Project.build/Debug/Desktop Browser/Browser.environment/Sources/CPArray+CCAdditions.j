@STATIC;1.0;I;23;Foundation/Foundation.jt;523;

objj_executeFile("Foundation/Foundation.j", NO);

{
var the_class = objj_getClass("CPArray")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CPArray\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("makeObjectsPerformFunction:"), function $CPArray__makeObjectsPerformFunction_(self, _cmd, f)
{ with(self)
{
 for(var i = 0 ; i < objj_msgSend(self, "count") ; i++)
 {
  f(objj_msgSend(self, "objectAtIndex:", i));
 }
}
},["void","Function"])]);
}

