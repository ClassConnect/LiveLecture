@STATIC;1.0;i;9;CGColor.ji;14;CGColorSpace.jt;680;
objj_executeFile("CGColor.j",YES);
objj_executeFile("CGColorSpace.j",YES);
kCGGradientDrawsBeforeStartLocation=1<<0;
kCGGradientDrawsAfterEndLocation=1<<1;
CGGradientCreateWithColorComponents=function(_1,_2,_3,_4){
if(_3===undefined||_3===NULL){
var _5=_2.length/4,_3=[];
for(var _6=0;_6<_5;_6++){
_3.push(_6/(_5-1));
}
}
if(_4===undefined||_4===NULL){
var _4=_3.length;
}
var _7=[];
while(_4--){
var _8=_4*4;
_7[_4]=CGColorCreate(_1,_2.slice(_8,_8+4));
}
return CGGradientCreateWithColors(_1,_7,_3);
};
CGGradientCreateWithColors=function(_9,_a,_b){
return {colorspace:_9,colors:_a,locations:_b};
};
CGGradientRelease=function(){
};
CGGradientRetain=function(_c){
return _c;
};
