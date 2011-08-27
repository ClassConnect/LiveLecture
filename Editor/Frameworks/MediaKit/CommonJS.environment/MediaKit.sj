@STATIC;1.0;p;33;CPApplication+MediaKitAdditions.jt;490;@STATIC;1.0;I;22;AppKit/CPApplication.ji;14;MKMediaPanel.jt;426;
objj_executeFile("AppKit/CPApplication.j",NO);
objj_executeFile("MKMediaPanel.j",YES);
var _1=objj_getClass("CPApplication");
if(!_1){
throw new SyntaxError("*** Could not find definition for class \"CPApplication\"");
}
var _2=_1.isa;
class_addMethods(_1,[new objj_method(sel_getUid("orderFrontMediaPanel:"),function(_3,_4,_5){
with(_3){
objj_msgSend(objj_msgSend(MKMediaPanel,"sharedMediaPanel"),"orderFront:",_3);
}
})]);
p;10;MediaKit.jt;175;@STATIC;1.0;i;33;CPApplication+MediaKitAdditions.ji;14;MKMediaPanel.jt;100;
objj_executeFile("CPApplication+MediaKitAdditions.j",YES);
objj_executeFile("MKMediaPanel.j",YES);
p;16;MKFlickrSearch.jt;1715;@STATIC;1.0;I;21;Foundation/CPObject.ji;14;MKMediaPanel.jt;1651;
objj_executeFile("Foundation/CPObject.j",NO);
objj_executeFile("MKMediaPanel.j",YES);
var _1=objj_allocateClassPair(CPObject,"MKFlickrSearchDelegate"),_2=_1.isa;
objj_registerClassPair(_1);
class_addMethods(_1,[new objj_method(sel_getUid("mediaObjectsForIdentifier:data:"),function(_3,_4,_5,_6){
with(_3){
if(_6.stat!=="ok"){
return [];
}
var _7=_6.photos.photo,_8=_7.length;
for(var i=0;i<_8;i++){
var _9=_7[i];
_9.title=_9.title;
_9.source=objj_msgSend(objj_msgSend(_3,"class"),"description");
_9.contentSize=CGSizeMake(_9.o_width?_9.o_width:"unknown",_9.o_height?_9.o_height:"unknown");
_9.thumbnailSize=CGSizeMake(75,75);
_9.thumbnailURL=_a(_9);
_9.url=_b(_9);
_9.mediaType=MKMediaTypeImage;
}
return _7;
}
}),new objj_method(sel_getUid("mediaSearchWithIdentifier:failedWithError:"),function(_c,_d,_e,_f){
with(_c){
}
})]);
class_addMethods(_2,[new objj_method(sel_getUid("URL"),function(_10,_11){
with(_10){
return "http://www.flickr.com/services/rest/?"+"method=flickr.photos.search&tags="+MKMediaPanelQueryReplacementString+"&media=photos&machine_tag_mode=any&per_page=8&extras=o_dims&format=json"+"&api_key=ca4dd89d3dfaeaf075144c3fdec76756&jsoncallback="+CPJSONPCallbackReplacementString;
}
}),new objj_method(sel_getUid("identifier"),function(_12,_13){
with(_12){
return "FlickrSearch";
}
}),new objj_method(sel_getUid("description"),function(_14,_15){
with(_14){
return "Flickr";
}
})]);
var _b=_b=function(_16){
return "http://farm"+_16.farm+".static.flickr.com/"+_16.server+"/"+_16.id+"_"+_16.secret+".jpg";
};
var _a=_a=function(_17){
return "http://farm"+_17.farm+".static.flickr.com/"+_17.server+"/"+_17.id+"_"+_17.secret+"_s.jpg";
};
p;21;MKGoogleImageSearch.jt;1230;@STATIC;1.0;I;21;Foundation/CPObject.ji;14;MKMediaPanel.jt;1166;
objj_executeFile("Foundation/CPObject.j",NO);
objj_executeFile("MKMediaPanel.j",YES);
var _1=objj_allocateClassPair(CPObject,"MKGoogleImageSearchDelegate"),_2=_1.isa;
objj_registerClassPair(_1);
class_addMethods(_1,[new objj_method(sel_getUid("mediaObjectsForIdentifier:data:"),function(_3,_4,_5,_6){
with(_3){
if(_6.responseStatus!==200){
return [];
}
var _7=_6.responseData.results,_8=_7.length;
for(var i=0;i<_8;i++){
var _9=_7[i];
_9.title=_9.titleNoFormatting;
_9.source="Google Images";
_9.contentSize=CGSizeMake(_9.width,_9.height);
_9.thumbnailSize=CGSizeMake(_9.tbWidth,_9.tbHeight);
_9.thumbnailURL=_9.tbUrl;
_9.mediaType=MKMediaTypeImage;
_9.url=_9.unescapedUrl;
}
return _7;
}
}),new objj_method(sel_getUid("mediaSearchWithIdentifier:failedWithError:"),function(_a,_b,_c,_d){
with(_a){
}
})]);
class_addMethods(_2,[new objj_method(sel_getUid("URL"),function(_e,_f){
with(_e){
return "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=large&q="+MKMediaPanelQueryReplacementString+"&callback="+CPJSONPCallbackReplacementString;
}
}),new objj_method(sel_getUid("identifier"),function(_10,_11){
with(_10){
return "GoogleImageSearch";
}
})]);
p;21;MKGoogleVideoSearch.jt;1361;@STATIC;1.0;I;21;Foundation/CPObject.ji;14;MKMediaPanel.jt;1297;
objj_executeFile("Foundation/CPObject.j",NO);
objj_executeFile("MKMediaPanel.j",YES);
var _1=objj_allocateClassPair(CPObject,"MKGoogleVideoSearchDelegate"),_2=_1.isa;
objj_registerClassPair(_1);
class_addMethods(_1,[new objj_method(sel_getUid("mediaObjectsForIdentifier:data:"),function(_3,_4,_5,_6){
with(_3){
if(_6.responseStatus!==200){
return [];
}
var _7=_6.responseData.results,_8=_7.length;
for(var i=0;i<_8;i++){
var _9=_7[i];
_9.title=_9.titleNoFormatting;
_9.source=objj_msgSend(objj_msgSend(_3,"class"),"description");
_9.contentSize=CGSizeMake(_9.width,_9.height);
_9.thumbnailSize=CGSizeMake(_9.tbWidth,_9.tbHeight);
_9.thumbnailURL=_9.tbUrl;
_9.mediaType=MKMediaTypeVideo;
_9.url=_9.playUrl;
}
return _7;
}
}),new objj_method(sel_getUid("mediaSearchWithIdentifier:failedWithError:"),function(_a,_b,_c,_d){
with(_a){
}
})]);
class_addMethods(_2,[new objj_method(sel_getUid("URL"),function(_e,_f){
with(_e){
return "http://ajax.googleapis.com/ajax/services/search/video?v=1.0&rsz=large&q="+MKMediaPanelQueryReplacementString+"&callback="+CPJSONPCallbackReplacementString;
}
}),new objj_method(sel_getUid("identifier"),function(_10,_11){
with(_10){
return "GoogleVideoSearch";
}
}),new objj_method(sel_getUid("description"),function(_12,_13){
with(_12){
return "Google Video";
}
})]);
p;13;MKMediaCell.jt;5664;@STATIC;1.0;I;15;AppKit/CPView.jt;5625;
objj_executeFile("AppKit/CPView.j",NO);
var _1=4,_2=96,_3=71;
var _4=objj_allocateClassPair(CPView,"MKMediaCell"),_5=_4.isa;
class_addIvars(_4,[new objj_ivar("_image"),new objj_ivar("_imageView"),new objj_ivar("_titleField"),new objj_ivar("_sourceField"),new objj_ivar("_metaField"),new objj_ivar("_object")]);
objj_registerClassPair(_4);
class_addMethods(_4,[new objj_method(sel_getUid("initWithFrame:"),function(_6,_7,_8){
with(_6){
_6=objj_msgSendSuper({receiver:_6,super_class:objj_getClass("MKMediaCell").super_class},"initWithFrame:",_8);
if(_6){
_imageView=objj_msgSend(objj_msgSend(CPImageView,"alloc"),"initWithFrame:",CGRectMake(2,2,_2,_3));
objj_msgSend(_imageView,"setHasShadow:",YES);
objj_msgSend(_6,"addSubview:",_imageView);
var _9=objj_msgSend(_6,"bounds"),_a=CGRectGetWidth(_9),_b=CGRectGetWidth(_9)-_2-2*_1;
_titleField=objj_msgSend(objj_msgSend(CPTextField,"alloc"),"initWithFrame:",CGRectMakeZero());
objj_msgSend(_titleField,"setLineBreakMode:",CPLineBreakByTruncatingTail);
objj_msgSend(_titleField,"setAutoresizingMask:",CPViewWidthSizable);
objj_msgSend(_titleField,"setFont:",objj_msgSend(CPFont,"boldSystemFontOfSize:",11));
objj_msgSend(_titleField,"setStringValue:","Untitled");
objj_msgSend(_titleField,"sizeToFit");
var _c=CGRectGetHeight(objj_msgSend(_titleField,"frame")),x=_2+_1,y=0;
objj_msgSend(_titleField,"setStringValue:","");
objj_msgSend(_titleField,"setFrame:",CGRectMake(x,y,_b,_c));
objj_msgSend(_6,"addSubview:",_titleField);
y+=_c-2;
_sourceField=objj_msgSend(objj_msgSend(CPTextField,"alloc"),"initWithFrame:",CGRectMake(x,y,100,18));
objj_msgSend(_sourceField,"setFont:",objj_msgSend(CPFont,"systemFontOfSize:",11));
objj_msgSend(_sourceField,"setLineBreakMode:",CPLineBreakByWordWrapping);
objj_msgSend(_sourceField,"setAutoresizingMask:",CPViewWidthSizable);
objj_msgSend(_sourceField,"setTextColor:",objj_msgSend(CPColor,"grayColor"));
objj_msgSend(_sourceField,"setStringValue:","12948 views");
objj_msgSend(_6,"addSubview:",_sourceField);
_metaField=objj_msgSend(objj_msgSend(CPTextField,"alloc"),"initWithFrame:",CGRectMake(x,y+15,100,18));
objj_msgSend(_metaField,"setAutoresizingMask:",CPViewWidthSizable);
objj_msgSend(_metaField,"setLineBreakMode:",CPLineBreakByTruncatingTail);
objj_msgSend(_metaField,"setFont:",objj_msgSend(CPFont,"boldSystemFontOfSize:",11));
objj_msgSend(_metaField,"setStringValue:","53:53:40");
objj_msgSend(_metaField,"setTextColor:",objj_msgSend(CPColor,"colorWithCalibratedRed:green:blue:alpha:",67/255,101/255,183/255,1));
objj_msgSend(_6,"addSubview:",_metaField);
}
return _6;
}
}),new objj_method(sel_getUid("setRepresentedObject:"),function(_d,_e,_f){
with(_d){
if(_object==_f){
return;
}
_object=_f;
objj_msgSend(_titleField,"setStringValue:",_object.title);
objj_msgSend(_sourceField,"setStringValue:",_object.source);
if(_object.mediaType===MKMediaTypeVideo){
if(!_object.duration){
objj_msgSend(_metaField,"setStringValue:","");
}else{
var _10=FLOOR(_object.duration/60),_11=_object.duration-_10*60;
objj_msgSend(_metaField,"setStringValue:",((_10<10)?"0":"")+_10+":"+(_11<10?"0":"")+_11);
}
}else{
if(!_object.contentSize){
objj_msgSend(_metaField,"setStringValue:","");
}else{
objj_msgSend(_metaField,"setStringValue:",_object.contentSize.width+" x "+_object.contentSize.height);
}
}
objj_msgSend(_image,"setDelegate:",nil);
_image=objj_msgSend(objj_msgSend(CPImage,"alloc"),"initWithContentsOfFile:size:",_object.thumbnailURL,_object.thumbnailSize);
if(objj_msgSend(_image,"loadStatus")!=CPImageLoadStatusCompleted){
objj_msgSend(_image,"setDelegate:",_d);
if(_object.thumbnailSize){
var _12=objj_msgSend(_imageView,"center");
objj_msgSend(_imageView,"setFrameSize:",CGSizeMake(MIN(_object.thumbnailSize.width,_2),MIN(_object.thumbnailSize.height,_3)));
objj_msgSend(_imageView,"setCenter:",_12);
}
objj_msgSend(_imageView,"setImageScaling:",CPScaleNone);
objj_msgSend(_imageView,"setImage:",nil);
}else{
objj_msgSend(_d,"imageDidLoad:",_image);
}
}
}),new objj_method(sel_getUid("imageDidLoad:"),function(_13,_14,_15){
with(_13){
if(_image!=_15){
return;
}
objj_msgSend(_imageView,"setImage:",_image);
objj_msgSend(_imageView,"setImageScaling:",CPScaleProportionally);
objj_msgSend(_imageView,"setHasShadow:",YES);
}
}),new objj_method(sel_getUid("selectionRect"),function(_16,_17){
with(_16){
return CGRectInset(objj_msgSend(_imageView,"frame"),-2,-2);
}
}),new objj_method(sel_getUid("setSelected:"),function(_18,_19,_1a){
with(_18){
if(_1a){
}else{
}
}
})]);
var _1b="MediaCellImageViewKey",_1c="MediaCellTitleFieldKey",_1d="MediaCellSourceFieldKey",_1e="MediaCellMetaFieldKey";
var _4=objj_getClass("MKMediaCell");
if(!_4){
throw new SyntaxError("*** Could not find definition for class \"MKMediaCell\"");
}
var _5=_4.isa;
class_addMethods(_4,[new objj_method(sel_getUid("initWithCoder:"),function(_1f,_20,_21){
with(_1f){
_1f=objj_msgSendSuper({receiver:_1f,super_class:objj_getClass("MKMediaCell").super_class},"initWithCoder:",_21);
if(_1f){
_imageView=objj_msgSend(_21,"decodeObjectForKey:",_1b);
_titleField=objj_msgSend(_21,"decodeObjectForKey:",_1c);
_sourceField=objj_msgSend(_21,"decodeObjectForKey:",_1d);
_metaField=objj_msgSend(_21,"decodeObjectForKey:",_1e);
}
return _1f;
}
}),new objj_method(sel_getUid("encodeWithCoder:"),function(_22,_23,_24){
with(_22){
objj_msgSendSuper({receiver:_22,super_class:objj_getClass("MKMediaCell").super_class},"encodeWithCoder:",_24);
objj_msgSend(_24,"encodeObject:forKey:",_imageView,_1b);
objj_msgSend(_24,"encodeObject:forKey:",_titleField,_1c);
objj_msgSend(_24,"encodeObject:forKey:",_sourceField,_1d);
objj_msgSend(_24,"encodeObject:forKey:",_metaField,_1e);
}
})]);
p;14;MKMediaPanel.jt;17058;@STATIC;1.0;I;16;AppKit/CPPanel.jI;21;AppKit/CPPasteboard.ji;16;MKFlickrSearch.ji;21;MKGoogleImageSearch.ji;21;MKGoogleVideoSearch.ji;13;MKMediaCell.jt;16900;
objj_executeFile("AppKit/CPPanel.j",NO);
objj_executeFile("AppKit/CPPasteboard.j",NO);
objj_executeFile("MKFlickrSearch.j",YES);
objj_executeFile("MKGoogleImageSearch.j",YES);
objj_executeFile("MKGoogleVideoSearch.j",YES);
objj_executeFile("MKMediaCell.j",YES);
MKMediaTypeImage=1<<0;
MKMediaTypeVideo=1<<1;
MKMediaTypeAll=65535;
MKMediaPanelQueryReplacementString="${QUERY}";
MKMediaPanelPageReplacementString="${PAGE}";
var _1=nil;
var _2=objj_allocateClassPair(CPPanel,"MKMediaPanel"),_3=_2.isa;
class_addIvars(_2,[new objj_ivar("searchField"),new objj_ivar("searchResultsLabel"),new objj_ivar("searchFilterRadioGroup"),new objj_ivar("mediaCollectionView"),new objj_ivar("loadingView"),new objj_ivar("scrollView"),new objj_ivar("connectionsByIdentifier"),new objj_ivar("URLsByIdentifier"),new objj_ivar("resultsByIdentifier"),new objj_ivar("delegatesByIdentifier"),new objj_ivar("target"),new objj_ivar("action")]);
objj_registerClassPair(_2);
class_addMethods(_2,[new objj_method(sel_getUid("target"),function(_4,_5){
with(_4){
return target;
}
}),new objj_method(sel_getUid("setTarget:"),function(_6,_7,_8){
with(_6){
target=_8;
}
}),new objj_method(sel_getUid("action"),function(_9,_a){
with(_9){
return action;
}
}),new objj_method(sel_getUid("setAction:"),function(_b,_c,_d){
with(_b){
action=_d;
}
}),new objj_method(sel_getUid("init"),function(_e,_f){
with(_e){
if(_e=objj_msgSendSuper({receiver:_e,super_class:objj_getClass("MKMediaPanel").super_class},"initWithContentRect:styleMask:",CGRectMake(100,100,300,400),CPTitledWindowMask|CPResizableWindowMask|CPClosableWindowMask)){
objj_msgSend(_e,"setTitle:","Searchbox");
objj_msgSend(_e,"setMinSize:",CPSizeMake(250,300));
var _10=objj_msgSend(_e,"contentView");
searchField=objj_msgSend(CPTextField,"roundedTextFieldWithStringValue:placeholder:width:","","Search for media...",224);
objj_msgSend(searchField,"setFrameOrigin:",CGPointMake(8,8));
objj_msgSend(searchField,"setAutoresizingMask:",CPViewWidthSizable);
objj_msgSend(_10,"addSubview:",searchField);
var _11=objj_msgSend(CPButton,"buttonWithTitle:","Search");
objj_msgSend(_11,"setFrameOrigin:",CGPointMake(CGRectGetMaxX(objj_msgSend(searchField,"bounds"))+14,CGRectGetMinY(objj_msgSend(searchField,"frame"))+3));
objj_msgSend(_11,"setAutoresizingMask:",CPViewMinXMargin);
objj_msgSend(_11,"setTarget:",_e);
objj_msgSend(_11,"setAction:",sel_getUid("search:"));
objj_msgSend(searchField,"setTarget:",_11);
objj_msgSend(searchField,"setAction:",sel_getUid("performClick:"));
objj_msgSend(_e,"setDefaultButton:",_11);
objj_msgSend(_10,"addSubview:",_11);
var _12=objj_msgSend(objj_msgSend(CPView,"alloc"),"initWithFrame:",CGRectMake(-1,CGRectGetMaxY(objj_msgSend(searchField,"bounds"))+14,CGRectGetWidth(objj_msgSend(_10,"bounds"))+2,CGRectGetHeight(objj_msgSend(_10,"bounds"))-40-CGRectGetMaxY(objj_msgSend(searchField,"bounds"))));
objj_msgSend(_12,"setBackgroundColor:",objj_msgSend(CPColor,"lightGrayColor"));
objj_msgSend(_12,"setAutoresizingMask:",CPViewWidthSizable|CPViewHeightSizable);
objj_msgSend(_10,"addSubview:",_12);
var _13=objj_msgSend(objj_msgSend(CPView,"alloc"),"initWithFrame:",CGRectMake(1,1,CGRectGetWidth(objj_msgSend(_12,"bounds"))-2,25));
objj_msgSend(_13,"setBackgroundColor:",objj_msgSend(CPColor,"colorWithRed:green:blue:alpha:",213/255,221/255,230/255,1));
objj_msgSend(_13,"setAutoresizingMask:",CPViewWidthSizable);
objj_msgSend(_12,"addSubview:",_13);
var _14=objj_msgSend(objj_msgSend(CPView,"alloc"),"initWithFrame:",CGRectMake(0,24,CGRectGetWidth(objj_msgSend(_13,"bounds")),1));
objj_msgSend(_14,"setBackgroundColor:",objj_msgSend(CPColor,"colorWithRed:green:blue:alpha:",180/255,195/255,205/255,1));
objj_msgSend(_14,"setAutoresizingMask:",CPViewWidthSizable);
objj_msgSend(_13,"addSubview:",_14);
var _15=objj_msgSend(CPBundle,"bundleForClass:",objj_msgSend(_e,"class")),_16=objj_msgSend(objj_msgSend(CPImage,"alloc"),"initWithContentsOfFile:size:",objj_msgSend(_15,"pathForResource:","MediaFilterLeftCap.png"),CGSizeMake(9,19)),_17=objj_msgSend(objj_msgSend(CPImage,"alloc"),"initWithContentsOfFile:size:",objj_msgSend(_15,"pathForResource:","MediaFilterRightCap.png"),CGSizeMake(9,19)),_18=objj_msgSend(objj_msgSend(CPImage,"alloc"),"initWithContentsOfFile:size:",objj_msgSend(_15,"pathForResource:","MediaFilterCenter.png"),CGSizeMake(1,19)),_19=objj_msgSend(objj_msgSend(CPThreePartImage,"alloc"),"initWithImageSlices:isVertical:",[_16,_18,_17],NO);
var _1a=objj_msgSend(CPRadio,"radioWithTitle:","All"),_1b=objj_msgSend(CPRadio,"radioWithTitle:","Images"),_1c=objj_msgSend(CPRadio,"radioWithTitle:","Videos"),_1d=[_1a,_1b,_1c];
for(var i=0,_1e=_1d.length;i<_1e;i++){
var _1f=_1d[i];
objj_msgSend(_1f,"setAlignment:",CPCenterTextAlignment);
objj_msgSend(_1f,"setValue:forThemeAttribute:",objj_msgSend(CPColor,"clearColor"),"bezel-color");
objj_msgSend(_1f,"setValue:forThemeAttribute:inState:",objj_msgSend(CPColor,"colorWithPatternImage:",_19),"bezel-color",CPThemeStateSelected);
objj_msgSend(_1f,"setValue:forThemeAttribute:",CGInsetMake(0,10,0,10),"content-inset");
objj_msgSend(_1f,"setValue:forThemeAttribute:",CGSizeMake(0,19),"min-size");
objj_msgSend(_1f,"setValue:forThemeAttribute:inState:",CGSizeMake(0,1),"text-shadow-offset",CPThemeStateBordered);
objj_msgSend(_1f,"setValue:forThemeAttribute:",objj_msgSend(CPColor,"colorWithCalibratedWhite:alpha:",79/255,1),"text-color");
objj_msgSend(_1f,"setValue:forThemeAttribute:",objj_msgSend(CPColor,"colorWithCalibratedWhite:alpha:",240/255,1),"text-shadow-color");
objj_msgSend(_1f,"setValue:forThemeAttribute:inState:",objj_msgSend(CPColor,"colorWithCalibratedWhite:alpha:",1,1),"text-color",CPThemeStateSelected);
objj_msgSend(_1f,"setValue:forThemeAttribute:inState:",objj_msgSend(CPColor,"colorWithCalibratedWhite:alpha:",79/255,1),"text-shadow-color",CPThemeStateSelected);
objj_msgSend(_1f,"sizeToFit");
objj_msgSend(_1f,"setTarget:",_e);
objj_msgSend(_13,"addSubview:",_1f);
}
searchFilterRadioGroup=objj_msgSend(_1a,"radioGroup");
objj_msgSend(_1b,"setRadioGroup:",searchFilterRadioGroup);
objj_msgSend(_1c,"setRadioGroup:",searchFilterRadioGroup);
objj_msgSend(_1a,"setTag:",MKMediaTypeAll);
objj_msgSend(_1b,"setTag:",MKMediaTypeImage);
objj_msgSend(_1c,"setTag:",MKMediaTypeVideo);
objj_msgSend(_1a,"setFrameOrigin:",CGPointMake(8,3));
objj_msgSend(_1b,"setFrameOrigin:",CGPointMake(CGRectGetMaxX(objj_msgSend(_1a,"frame"))+8,CGRectGetMinY(objj_msgSend(_1a,"frame"))));
objj_msgSend(_1c,"setFrameOrigin:",CGPointMake(CGRectGetMaxX(objj_msgSend(_1b,"frame"))+8,CGRectGetMinY(objj_msgSend(_1b,"frame"))));
objj_msgSend(_1a,"performClick:",nil);
objj_msgSend(_1a,"setAction:",sel_getUid("showAll:"));
objj_msgSend(_1b,"setAction:",sel_getUid("showImages:"));
objj_msgSend(_1c,"setAction:",sel_getUid("showVideos:"));
scrollView=objj_msgSend(objj_msgSend(CPScrollView,"alloc"),"initWithFrame:",CGRectMake(1,26,CGRectGetWidth(objj_msgSend(_12,"bounds"))-2,CGRectGetHeight(objj_msgSend(_12,"bounds"))-27));
objj_msgSend(scrollView,"setAutoresizingMask:",CPViewWidthSizable|CPViewHeightSizable);
objj_msgSend(scrollView,"setHasHorizontalScroller:",NO);
objj_msgSend(scrollView,"setAutohidesScrollers:",YES);
objj_msgSend(objj_msgSend(scrollView,"contentView"),"setBackgroundColor:",objj_msgSend(CPColor,"whiteColor"));
objj_msgSend(_12,"addSubview:",scrollView);
mediaCollectionView=objj_msgSend(objj_msgSend(CPCollectionView,"alloc"),"initWithFrame:",objj_msgSend(scrollView,"bounds"));
objj_msgSend(mediaCollectionView,"setFrameSize:",CGSizeMake(CGRectGetWidth(objj_msgSend(scrollView,"bounds")),0));
objj_msgSend(mediaCollectionView,"setBackgroundColor:",objj_msgSend(CPColor,"whiteColor"));
objj_msgSend(mediaCollectionView,"setAutoresizingMask:",CPViewWidthSizable);
objj_msgSend(mediaCollectionView,"setDelegate:",_e);
var _20=objj_msgSend(objj_msgSend(CPCollectionViewItem,"alloc"),"init");
objj_msgSend(_20,"setView:",objj_msgSend(objj_msgSend(MKMediaCell,"alloc"),"initWithFrame:",CGRectMake(0,0,200,74)));
objj_msgSend(mediaCollectionView,"setItemPrototype:",_20);
objj_msgSend(mediaCollectionView,"setMinItemSize:",CGSizeMake(200,74));
objj_msgSend(mediaCollectionView,"setMaxItemSize:",CGSizeMake(400,74));
objj_msgSend(mediaCollectionView,"setMaxNumberOfColumns:",0);
objj_msgSend(scrollView,"setDocumentView:",mediaCollectionView);
searchResultsLabel=objj_msgSend(objj_msgSend(CPTextField,"alloc"),"initWithFrame:",CGRectMake(10,CGRectGetMaxY(objj_msgSend(_12,"frame"))+4,CGRectGetWidth(objj_msgSend(_10,"bounds"))-20,20));
objj_msgSend(searchResultsLabel,"setAutoresizingMask:",CPViewWidthSizable|CPViewMinYMargin);
objj_msgSend(searchResultsLabel,"setAlignment:",CPCenterTextAlignment);
objj_msgSend(searchResultsLabel,"setLineBreakMode:",CPLineBreakByTruncatingTail);
objj_msgSend(_10,"addSubview:",searchResultsLabel);
loadingView=objj_msgSend(objj_msgSend(CPView,"alloc"),"initWithFrame:",objj_msgSend(scrollView,"frame"));
objj_msgSend(loadingView,"setAutoresizingMask:",CPViewWidthSizable|CPViewHeightSizable);
var _21=objj_msgSend(CPProgressIndicator,"new");
objj_msgSend(_21,"setStyle:",CPProgressIndicatorSpinningStyle);
objj_msgSend(_21,"sizeToFit");
objj_msgSend(_21,"setAutoresizingMask:",CPViewMinXMargin|CPViewMinYMargin|CPViewMaxXMargin|CPViewMaxYMargin);
objj_msgSend(_21,"setCenter:",objj_msgSend(loadingView,"center"));
objj_msgSend(loadingView,"addSubview:",_21);
objj_msgSend(_12,"addSubview:",loadingView);
objj_msgSend(loadingView,"setHidden:",YES);
connectionsByIdentifier=objj_msgSend(CPDictionary,"dictionary");
URLsByIdentifier=objj_msgSend(CPDictionary,"dictionary");
resultsByIdentifier=objj_msgSend(CPDictionary,"dictionary");
delegatesByIdentifier=objj_msgSend(CPDictionary,"dictionary");
objj_msgSend(_e,"addSourceWithIdentifier:URL:delegate:",objj_msgSend(MKGoogleImageSearchDelegate,"identifier"),objj_msgSend(MKGoogleImageSearchDelegate,"URL"),objj_msgSend(MKGoogleImageSearchDelegate,"new"));
objj_msgSend(_e,"addSourceWithIdentifier:URL:delegate:",objj_msgSend(MKGoogleVideoSearchDelegate,"identifier"),objj_msgSend(MKGoogleVideoSearchDelegate,"URL"),objj_msgSend(MKGoogleVideoSearchDelegate,"new"));
}
return _e;
}
}),new objj_method(sel_getUid("collectionView:dragTypesForItemsAtIndexes:"),function(_22,_23,_24,_25){
with(_22){
return objj_msgSend(_24,"content")[objj_msgSend(_25,"firstIndex")].mediaType===MKMediaTypeImage?[CPImagesPboardType]:[CPVideosPboardType];
}
}),new objj_method(sel_getUid("collectionView:dataForItemsAtIndexes:forType:"),function(_26,_27,_28,_29,_2a){
with(_26){
var _2b=CPNotFound,_2c=objj_msgSend(_28,"content"),_2d=[];
while((_2b=objj_msgSend(_29,"indexGreaterThanIndex:",_2b))!=CPNotFound){
var _2e=_2c[_2b],_2f=nil;
if(_2a===CPImagesPboardType&&_2e.mediaType===MKMediaTypeImage){
_2f=objj_msgSend(objj_msgSend(CPImage,"alloc"),"initWithContentsOfFile:size:",_2e.url,_2e.contentSize);
}else{
if(_2a===CPVideosPboardType&&_2e.mediaType===MKMediaTypeVideo){
_2f=objj_msgSend(objj_msgSend(CPFlashMovie,"alloc"),"initWithFile:",_2e.url);
}
}
if(_2f){
_2d.push(_2f);
}
}
return objj_msgSend(CPKeyedArchiver,"archivedDataWithRootObject:",_2d);
}
}),new objj_method(sel_getUid("collectionView:dragImageForItemWithIndex:"),function(_30,_31,_32,_33){
with(_30){
var _34=objj_msgSend(_32,"content")[_33];
return objj_msgSend(objj_msgSend(CPImage,"alloc"),"initWithContentsOfFile:size:",_34.thumbnailURL,_34.thumbnailSize);
}
}),new objj_method(sel_getUid("collectionView:didDoubleClickOnItemAtIndex:"),function(_35,_36,_37,_38){
with(_35){
objj_msgSend(CPApp,"sendAction:to:from:",action,target,_35);
}
}),new objj_method(sel_getUid("selectedImage"),function(_39,_3a){
with(_39){
var _3b=objj_msgSend(objj_msgSend(mediaCollectionView,"selectionIndexes"),"firstIndex"),_3c=_3b!==nil?objj_msgSend(mediaCollectionView,"content")[_3b]:nil;
if(_3c&&_3c.mediaType===MKMediaTypeImage){
return objj_msgSend(objj_msgSend(CPImage,"alloc"),"initWithContentsOfFile:size:",_3c.url,_3c.contentSize);
}
return nil;
}
}),new objj_method(sel_getUid("selectedVideo"),function(_3d,_3e){
with(_3d){
var _3f=objj_msgSend(objj_msgSend(mediaCollectionView,"selectionIndexes"),"firstIndex"),_40=_3f!==nil?objj_msgSend(mediaCollectionView,"content")[_3f]:nil;
if(_40&&_40.mediaType===MKMediaTypeVideo){
return objj_msgSend(objj_msgSend(CPFlashMovie,"alloc"),"initWithFile:",_40.url);
}
return nil;
}
}),new objj_method(sel_getUid("resultsWithMask:"),function(_41,_42,_43){
with(_41){
var _44=objj_msgSend(resultsByIdentifier,"allKeys"),_45=objj_msgSend(_44,"count"),_46=[];
for(var i=0;i<_45;i++){
var _47=objj_msgSend(resultsByIdentifier,"objectForKey:",_44[i]),_48=objj_msgSend(_47,"count");
for(var j=0;j<_48;j++){
if(_47[j].mediaType&_43){
_46.push(_47[j]);
}
}
}
return _46;
}
}),new objj_method(sel_getUid("showAll:"),function(_49,_4a,_4b){
with(_49){
var _4c=objj_msgSend(_49,"resultsWithMask:",MKMediaTypeAll);
objj_msgSend(mediaCollectionView,"setContent:",_4c);
objj_msgSend(_49,"setResultCount:",objj_msgSend(_4c,"count"));
}
}),new objj_method(sel_getUid("showImages:"),function(_4d,_4e,_4f){
with(_4d){
var _50=objj_msgSend(_4d,"resultsWithMask:",MKMediaTypeImage);
objj_msgSend(mediaCollectionView,"setContent:",_50);
objj_msgSend(_4d,"setResultCount:",objj_msgSend(_50,"count"));
}
}),new objj_method(sel_getUid("showVideos:"),function(_51,_52,_53){
with(_51){
var _54=objj_msgSend(_51,"resultsWithMask:",MKMediaTypeVideo);
objj_msgSend(mediaCollectionView,"setContent:",_54);
objj_msgSend(_51,"setResultCount:",objj_msgSend(_54,"count"));
}
}),new objj_method(sel_getUid("setResultCount:"),function(_55,_56,_57){
with(_55){
objj_msgSend(searchResultsLabel,"setStringValue:",_57==1?"1 Result":_57+" Results");
}
}),new objj_method(sel_getUid("setSearchTerm:"),function(_58,_59,_5a){
with(_58){
objj_msgSend(searchField,"setStringValue:",_5a);
}
}),new objj_method(sel_getUid("search:"),function(_5b,_5c,_5d){
with(_5b){
if(!objj_msgSend(objj_msgSend(searchField,"stringValue"),"length")){
return;
}
objj_msgSend(searchResultsLabel,"setStringValue:","");
objj_msgSend(mediaCollectionView,"setContent:",[]);
var _5e=encodeURIComponent(objj_msgSend(searchField,"stringValue")),_5f=objj_msgSend(URLsByIdentifier,"allKeys");
for(var i=0,_60=objj_msgSend(_5f,"count");i<_60;i++){
var _61=_5f[i],url=objj_msgSend(URLsByIdentifier,"objectForKey:",_61);
url=objj_msgSend(url,"stringByReplacingOccurrencesOfString:withString:",MKMediaPanelQueryReplacementString,_5e);
var _62=objj_msgSend(objj_msgSend(CPJSONPConnection,"alloc"),"initWithRequest:callback:delegate:startImmediately:",objj_msgSend(CPURLRequest,"requestWithURL:",url),nil,_5b,NO);
_62.identifier=_61;
objj_msgSend(objj_msgSend(connectionsByIdentifier,"objectForKey:",_61),"cancel");
objj_msgSend(connectionsByIdentifier,"setObject:forKey:",_62,_61);
objj_msgSend(_62,"start");
}
objj_msgSend(loadingView,"setHidden:",NO);
objj_msgSend(searchResultsLabel,"setStringValue:","Searching...");
}
}),new objj_method(sel_getUid("addSourceWithIdentifier:URL:delegate:"),function(_63,_64,_65,_66,_67){
with(_63){
objj_msgSend(_63,"removeSourceWithIdentifier:",_65);
objj_msgSend(delegatesByIdentifier,"setObject:forKey:",_67,_65);
objj_msgSend(URLsByIdentifier,"setObject:forKey:",_66,_65);
}
}),new objj_method(sel_getUid("removeSourceWithIdentifier:"),function(_68,_69,_6a){
with(_68){
objj_msgSend(objj_msgSend(connectionsByIdentifier,"objectForKey:",_6a),"cancel");
objj_msgSend(connectionsByIdentifier,"removeObjectForKey:",_6a);
objj_msgSend(delegatesByIdentifier,"removeObjectForKey:",_6a);
objj_msgSend(resultsByIdentifier,"removeObjectForKey:",_6a);
objj_msgSend(URLsByIdentifier,"removeObjectForKey:",_6a);
}
}),new objj_method(sel_getUid("connection:didReceiveData:"),function(_6b,_6c,_6d,_6e){
with(_6b){
var _6f=_6d.identifier,_70=objj_msgSend(delegatesByIdentifier,"objectForKey:",_6f),_71=objj_msgSend(_70,"mediaObjectsForIdentifier:data:",_6f,_6e),_72=objj_msgSend(_71,"count"),_73=objj_msgSend(objj_msgSend(mediaCollectionView,"content"),"copy");
objj_msgSend(resultsByIdentifier,"setObject:forKey:",_71,_6f);
for(var i=0;i<_72;i++){
if(_71[i].mediaType&objj_msgSend(objj_msgSend(searchFilterRadioGroup,"selectedRadio"),"tag")){
_73.push(_71[i]);
}
}
objj_msgSend(_6b,"setResultCount:",objj_msgSend(_73,"count"));
objj_msgSend(mediaCollectionView,"setContent:",_73);
objj_msgSend(connectionsByIdentifier,"removeObjectForKey:",_6f);
objj_msgSend(loadingView,"setHidden:",YES);
}
}),new objj_method(sel_getUid("connection:didFailWithError:"),function(_74,_75,_76,_77){
with(_74){
var _78=_76.identifier,_79=objj_msgSend(delegatesByIdentifier,"objectForKey:",_78);
objj_msgSend(_79,"mediaSearchWithIdentifier:failedWithError:",_78,_77);
objj_msgSend(resultsByIdentifier,"setObject:forKey:",[],_78);
objj_msgSend(connectionsByIdentifier,"removeObjectForKey:",_78);
}
})]);
class_addMethods(_3,[new objj_method(sel_getUid("sharedMediaPanel"),function(_7a,_7b){
with(_7a){
if(!_1){
_1=objj_msgSend(objj_msgSend(_7a,"alloc"),"init");
}
return _1;
}
})]);
e;