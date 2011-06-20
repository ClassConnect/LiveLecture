@STATIC;1.0;i;14;CGColorSpace.jt;2197;
objj_executeFile("CGColorSpace.j",YES);
var _1=0;
CFHashCode=function(_2){
if(!_2.hash){
_2.hash=++_1;
}
return _2;
};
kCGColorWhite="kCGColorWhite";
kCGColorBlack="kCGColorBlack";
kCGColorClear="kCGColorClear";
var _3={};
CGColorGetConstantColor=function(_4){
alert("FIX ME");
};
CGColorRetain=function(_5){
return _5;
};
CGColorRelease=function(){
};
CGColorCreate=function(_6,_7){
if(!_6||!_7){
return NULL;
}
var _7=_7.slice();
CGColorSpaceStandardizeComponents(_6,_7);
var _8=CFHashCode(_6)+_7.join("");
if(_3[_8]){
return _3[_8];
}
return _3[_8]={colorspace:_6,pattern:NULL,components:_7};
};
CGColorCreateCopy=function(_9){
return _9;
};
CGColorCreateGenericGray=function(_a,_b){
return CGColorCreate(CGColorSpaceCreateDeviceRGB(),[_a,_a,_a,_b]);
};
CGColorCreateGenericRGB=function(_c,_d,_e,_f){
return CGColorCreate(CGColorSpaceCreateDeviceRGB(),[_c,_d,_e,_f]);
};
CGColorCreateGenericCMYK=function(_10,_11,_12,_13,_14){
return CGColorCreate(CGColorSpaceCreateDeviceCMYK(),[_10,_11,_12,_13,_14]);
};
CGColorCreateCopyWithAlpha=function(_15,_16){
if(!_15){
return _15;
}
var _17=_15.components.slice();
if(_16==_17[_17.length-1]){
return _15;
}
_17[_17.length-1]=_16;
if(_15.pattern){
return CGColorCreateWithPattern(_15.colorspace,_15.pattern,_17);
}else{
return CGColorCreate(_15.colorspace,_17);
}
};
CGColorCreateWithPattern=function(_18,_19,_1a){
if(!_18||!_19||!_1a){
return NULL;
}
return {colorspace:_18,pattern:_19,components:_1a.slice()};
};
CGColorEqualToColor=function(lhs,rhs){
if(lhs==rhs){
return true;
}
if(!lhs||!rhs){
return false;
}
var _1b=lhs.components,_1c=rhs.components,_1d=_1b.length;
if(_1d!=_1c.length){
return false;
}
while(_1d--){
if(_1b[_1d]!=_1c[_1d]){
return false;
}
}
if(lhs.pattern!=rhs.pattern){
return false;
}
if(CGColorSpaceEqualToColorSpace(lhs.colorspace,rhs.colorspace)){
return false;
}
return true;
};
CGColorGetAlpha=function(_1e){
var _1f=_1e.components;
return _1f[_1f.length-1];
};
CGColorGetColorSpace=function(_20){
return _20.colorspace;
};
CGColorGetComponents=function(_21){
return _21.components;
};
CGColorGetNumberOfComponents=function(_22){
return _22.components.length;
};
CGColorGetPattern=function(_23){
return _23.pattern;
};
