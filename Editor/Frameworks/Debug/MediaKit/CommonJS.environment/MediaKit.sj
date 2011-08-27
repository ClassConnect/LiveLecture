@STATIC;1.0;p;33;CPApplication+MediaKitAdditions.jt;609;@STATIC;1.0;I;22;AppKit/CPApplication.ji;14;MKMediaPanel.jt;545;objj_executeFile("AppKit/CPApplication.j", NO);
objj_executeFile("MKMediaPanel.j", YES);
{
var the_class = objj_getClass("CPApplication")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CPApplication\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("orderFrontMediaPanel:"), function $CPApplication__orderFrontMediaPanel_(self, _cmd, aSender)
{ with(self)
{
    objj_msgSend(objj_msgSend(MKMediaPanel, "sharedMediaPanel"), "orderFront:", self);
}
},["void","id"])]);
}

p;10;MediaKit.jt;177;@STATIC;1.0;i;33;CPApplication+MediaKitAdditions.ji;14;MKMediaPanel.jt;102;objj_executeFile("CPApplication+MediaKitAdditions.j", YES);
objj_executeFile("MKMediaPanel.j", YES);

p;16;MKFlickrSearch.jt;2595;@STATIC;1.0;I;21;Foundation/CPObject.ji;14;MKMediaPanel.jt;2531;objj_executeFile("Foundation/CPObject.j", NO);
objj_executeFile("MKMediaPanel.j", YES);
{var the_class = objj_allocateClassPair(CPObject, "MKFlickrSearchDelegate"),
meta_class = the_class.isa;objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("mediaObjectsForIdentifier:data:"), function $MKFlickrSearchDelegate__mediaObjectsForIdentifier_data_(self, _cmd, anIdentifier, data)
{ with(self)
{
    if (data.stat !== "ok")
        return [];
    var results = data.photos.photo,
        count = results.length;
    for (var i = 0; i < count; i++)
    {
        var object = results[i];
        object.title = object.title;
        object.source = objj_msgSend(objj_msgSend(self, "class"), "description");
        object.contentSize = CGSizeMake(object.o_width ? object.o_width : "unknown", object.o_height ? object.o_height : "unknown");
        object.thumbnailSize = CGSizeMake(75, 75);
        object.thumbnailURL = thumbForFlickrPhoto(object);
        object.url = urlForFlickrPhoto(object);
        object.mediaType = MKMediaTypeImage;
    }
    return results;
}
},["CPArray","CPString","Object"]), new objj_method(sel_getUid("mediaSearchWithIdentifier:failedWithError:"), function $MKFlickrSearchDelegate__mediaSearchWithIdentifier_failedWithError_(self, _cmd, anIdentifier, anError)
{ with(self)
{
}
},["void","CPString","CPString"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("URL"), function $MKFlickrSearchDelegate__URL(self, _cmd)
{ with(self)
{
    return "http://www.flickr.com/services/rest/?" +
           "method=flickr.photos.search&tags=" + MKMediaPanelQueryReplacementString+
           "&media=photos&machine_tag_mode=any&per_page=8&extras=o_dims&format=json"+
           "&api_key=ca4dd89d3dfaeaf075144c3fdec76756&jsoncallback=" + CPJSONPCallbackReplacementString;
}
},["CPString"]), new objj_method(sel_getUid("identifier"), function $MKFlickrSearchDelegate__identifier(self, _cmd)
{ with(self)
{
    return "FlickrSearch";
}
},["CPString"]), new objj_method(sel_getUid("description"), function $MKFlickrSearchDelegate__description(self, _cmd)
{ with(self)
{
    return "Flickr";
}
},["CPString"])]);
}
var urlForFlickrPhoto = urlForFlickrPhoto= function(photo)
{
    return "http://farm"+photo.farm+".static.flickr.com/"+photo.server+"/"+photo.id+"_"+photo.secret+".jpg";
}
var thumbForFlickrPhoto = thumbForFlickrPhoto= function(photo)
{
    return "http://farm"+photo.farm+".static.flickr.com/"+photo.server+"/"+photo.id+"_"+photo.secret+"_s.jpg";
}

p;21;MKGoogleImageSearch.jt;1894;@STATIC;1.0;I;21;Foundation/CPObject.ji;14;MKMediaPanel.jt;1830;objj_executeFile("Foundation/CPObject.j", NO);
objj_executeFile("MKMediaPanel.j", YES);
{var the_class = objj_allocateClassPair(CPObject, "MKGoogleImageSearchDelegate"),
meta_class = the_class.isa;objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("mediaObjectsForIdentifier:data:"), function $MKGoogleImageSearchDelegate__mediaObjectsForIdentifier_data_(self, _cmd, anIdentifier, data)
{ with(self)
{
    if (data.responseStatus !== 200)
        return [];
    var results = data.responseData.results,
        count = results.length;
    for (var i = 0; i < count; i++)
    {
        var object = results[i];
        object.title = object.titleNoFormatting;
        object.source = "Google Images";
        object.contentSize = CGSizeMake(object.width, object.height);
        object.thumbnailSize = CGSizeMake(object.tbWidth, object.tbHeight);
        object.thumbnailURL = object.tbUrl;
        object.mediaType = MKMediaTypeImage;
        object.url = object.unescapedUrl;
    }
    return results;
}
},["CPArray","CPString","Object"]), new objj_method(sel_getUid("mediaSearchWithIdentifier:failedWithError:"), function $MKGoogleImageSearchDelegate__mediaSearchWithIdentifier_failedWithError_(self, _cmd, anIdentifier, anError)
{ with(self)
{
}
},["void","CPString","CPString"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("URL"), function $MKGoogleImageSearchDelegate__URL(self, _cmd)
{ with(self)
{
    return "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=large&q=" + MKMediaPanelQueryReplacementString + "&callback=" + CPJSONPCallbackReplacementString;
}
},["CPString"]), new objj_method(sel_getUid("identifier"), function $MKGoogleImageSearchDelegate__identifier(self, _cmd)
{ with(self)
{
    return "GoogleImageSearch";
}
},["CPString"])]);
}

p;21;MKGoogleVideoSearch.jt;2096;@STATIC;1.0;I;21;Foundation/CPObject.ji;14;MKMediaPanel.jt;2032;objj_executeFile("Foundation/CPObject.j", NO);
objj_executeFile("MKMediaPanel.j", YES);
{var the_class = objj_allocateClassPair(CPObject, "MKGoogleVideoSearchDelegate"),
meta_class = the_class.isa;objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("mediaObjectsForIdentifier:data:"), function $MKGoogleVideoSearchDelegate__mediaObjectsForIdentifier_data_(self, _cmd, anIdentifier, data)
{ with(self)
{
    if (data.responseStatus !== 200)
        return [];
    var results = data.responseData.results,
        count = results.length;
    for (var i = 0; i < count; i++)
    {
        var object = results[i];
        object.title = object.titleNoFormatting;
        object.source = objj_msgSend(objj_msgSend(self, "class"), "description");
        object.contentSize = CGSizeMake(object.width, object.height);
        object.thumbnailSize = CGSizeMake(object.tbWidth, object.tbHeight);
        object.thumbnailURL = object.tbUrl;
        object.mediaType = MKMediaTypeVideo;
        object.url = object.playUrl;
    }
    return results;
}
},["CPArray","CPString","Object"]), new objj_method(sel_getUid("mediaSearchWithIdentifier:failedWithError:"), function $MKGoogleVideoSearchDelegate__mediaSearchWithIdentifier_failedWithError_(self, _cmd, anIdentifier, anError)
{ with(self)
{
}
},["void","CPString","CPString"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("URL"), function $MKGoogleVideoSearchDelegate__URL(self, _cmd)
{ with(self)
{
    return "http://ajax.googleapis.com/ajax/services/search/video?v=1.0&rsz=large&q=" + MKMediaPanelQueryReplacementString + "&callback=" + CPJSONPCallbackReplacementString;
}
},["CPString"]), new objj_method(sel_getUid("identifier"), function $MKGoogleVideoSearchDelegate__identifier(self, _cmd)
{ with(self)
{
    return "GoogleVideoSearch";
}
},["CPString"]), new objj_method(sel_getUid("description"), function $MKGoogleVideoSearchDelegate__description(self, _cmd)
{ with(self)
{
    return "Google Video";
}
},["CPString"])]);
}

p;13;MKMediaCell.jt;7970;@STATIC;1.0;I;15;AppKit/CPView.jt;7931;objj_executeFile("AppKit/CPView.j", NO);
var MEDIA_PREVIEW_MARGIN = 4.0,
    MEDIA_THUMBNAIL_MAX_WIDTH = 96.0,
    MEDIA_THUMBNAIL_MAX_HEIGHT = 71.0;
{var the_class = objj_allocateClassPair(CPView, "MKMediaCell"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_image"), new objj_ivar("_imageView"), new objj_ivar("_titleField"), new objj_ivar("_sourceField"), new objj_ivar("_metaField"), new objj_ivar("_object")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("initWithFrame:"), function $MKMediaCell__initWithFrame_(self, _cmd, aFrame)
{ with(self)
{
    self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("MKMediaCell").super_class }, "initWithFrame:", aFrame);
    if (self)
    {
        _imageView = objj_msgSend(objj_msgSend(CPImageView, "alloc"), "initWithFrame:", CGRectMake(2.0, 2.0, MEDIA_THUMBNAIL_MAX_WIDTH, MEDIA_THUMBNAIL_MAX_HEIGHT));
        objj_msgSend(_imageView, "setHasShadow:", YES);
        objj_msgSend(self, "addSubview:", _imageView);
        var bounds = objj_msgSend(self, "bounds"),
            width = CGRectGetWidth(bounds),
            fieldWidth = CGRectGetWidth(bounds) - MEDIA_THUMBNAIL_MAX_WIDTH - 2 * MEDIA_PREVIEW_MARGIN;
        _titleField = objj_msgSend(objj_msgSend(CPTextField, "alloc"), "initWithFrame:", CGRectMakeZero());
        objj_msgSend(_titleField, "setLineBreakMode:", CPLineBreakByTruncatingTail);
        objj_msgSend(_titleField, "setAutoresizingMask:", CPViewWidthSizable);
        objj_msgSend(_titleField, "setFont:", objj_msgSend(CPFont, "boldSystemFontOfSize:", 11.0));
        objj_msgSend(_titleField, "setStringValue:", "Untitled");
        objj_msgSend(_titleField, "sizeToFit");
        var titleFieldHeight = CGRectGetHeight(objj_msgSend(_titleField, "frame")),
            x = MEDIA_THUMBNAIL_MAX_WIDTH + MEDIA_PREVIEW_MARGIN,
            y = 0.0;
        objj_msgSend(_titleField, "setStringValue:", "");
        objj_msgSend(_titleField, "setFrame:", CGRectMake(x, y, fieldWidth, titleFieldHeight));
        objj_msgSend(self, "addSubview:", _titleField);
        y += titleFieldHeight - 2.0;
        _sourceField = objj_msgSend(objj_msgSend(CPTextField, "alloc"), "initWithFrame:", CGRectMake(x, y, 100.0, 18.0));
        objj_msgSend(_sourceField, "setFont:", objj_msgSend(CPFont, "systemFontOfSize:", 11.0));
        objj_msgSend(_sourceField, "setLineBreakMode:", CPLineBreakByWordWrapping);
        objj_msgSend(_sourceField, "setAutoresizingMask:", CPViewWidthSizable);
        objj_msgSend(_sourceField, "setTextColor:", objj_msgSend(CPColor, "grayColor"));
        objj_msgSend(_sourceField, "setStringValue:", "12948 views");
        objj_msgSend(self, "addSubview:", _sourceField);
        _metaField = objj_msgSend(objj_msgSend(CPTextField, "alloc"), "initWithFrame:", CGRectMake(x, y + 15.0, 100.0, 18.0));
        objj_msgSend(_metaField, "setAutoresizingMask:", CPViewWidthSizable);
        objj_msgSend(_metaField, "setLineBreakMode:", CPLineBreakByTruncatingTail);
        objj_msgSend(_metaField, "setFont:", objj_msgSend(CPFont, "boldSystemFontOfSize:", 11.0));
        objj_msgSend(_metaField, "setStringValue:", "53:53:40");
        objj_msgSend(_metaField, "setTextColor:", objj_msgSend(CPColor, "colorWithCalibratedRed:green:blue:alpha:", 67.0 / 255.0, 101.0 / 255.0, 183.0 / 255.0, 1.0));
        objj_msgSend(self, "addSubview:", _metaField);
    }
    return self;
}
},["id","CGRect"]), new objj_method(sel_getUid("setRepresentedObject:"), function $MKMediaCell__setRepresentedObject_(self, _cmd, anObject)
{ with(self)
{
    if (_object == anObject)
        return;
    _object = anObject;
    objj_msgSend(_titleField, "setStringValue:", _object.title);
    objj_msgSend(_sourceField, "setStringValue:", _object.source);
    if (_object.mediaType === MKMediaTypeVideo)
    {
        if (!_object.duration)
            objj_msgSend(_metaField, "setStringValue:", "");
        else
        {
            var minutes = FLOOR(_object.duration / 60.0),
                seconds = _object.duration - minutes * 60.0;
            objj_msgSend(_metaField, "setStringValue:", ((minutes < 10) ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds);
        }
    }
    else
    {
        if (!_object.contentSize)
            objj_msgSend(_metaField, "setStringValue:", "")
        else
            objj_msgSend(_metaField, "setStringValue:", _object.contentSize.width + " x " + _object.contentSize.height);
    }
    objj_msgSend(_image, "setDelegate:", nil);
    _image = objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", _object.thumbnailURL, _object.thumbnailSize);
    if (objj_msgSend(_image, "loadStatus") != CPImageLoadStatusCompleted)
    {
        objj_msgSend(_image, "setDelegate:", self);
        if (_object.thumbnailSize)
        {
            var center = objj_msgSend(_imageView, "center");
            objj_msgSend(_imageView, "setFrameSize:", CGSizeMake(MIN(_object.thumbnailSize.width, MEDIA_THUMBNAIL_MAX_WIDTH),
                                                MIN(_object.thumbnailSize.height, MEDIA_THUMBNAIL_MAX_HEIGHT)));
            objj_msgSend(_imageView, "setCenter:", center);
        }
        objj_msgSend(_imageView, "setImageScaling:", CPScaleNone);
        objj_msgSend(_imageView, "setImage:", nil);
    }
    else
        objj_msgSend(self, "imageDidLoad:", _image);
}
},["void","Object"]), new objj_method(sel_getUid("imageDidLoad:"), function $MKMediaCell__imageDidLoad_(self, _cmd, anImage)
{ with(self)
{
    if (_image != anImage)
        return;
    objj_msgSend(_imageView, "setImage:", _image);
    objj_msgSend(_imageView, "setImageScaling:", CPScaleProportionally);
    objj_msgSend(_imageView, "setHasShadow:", YES);
}
},["void","CPImage"]), new objj_method(sel_getUid("selectionRect"), function $MKMediaCell__selectionRect(self, _cmd)
{ with(self)
{
    return CGRectInset(objj_msgSend(_imageView, "frame"), -2.0, -2.0);
}
},["CGRect"]), new objj_method(sel_getUid("setSelected:"), function $MKMediaCell__setSelected_(self, _cmd, shouldBeSelected)
{ with(self)
{
    if (shouldBeSelected)
    {
    }
    else
    {
    }
}
},["void","BOOL"])]);
}
var MediaCellImageViewKey = "MediaCellImageViewKey",
    MediaCellTitleFieldKey = "MediaCellTitleFieldKey",
    MediaCellSourceFieldKey = "MediaCellSourceFieldKey",
    MediaCellMetaFieldKey = "MediaCellMetaFieldKey";
{
var the_class = objj_getClass("MKMediaCell")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"MKMediaCell\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("initWithCoder:"), function $MKMediaCell__initWithCoder_(self, _cmd, aCoder)
{ with(self)
{
    self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("MKMediaCell").super_class }, "initWithCoder:", aCoder);
    if (self)
    {
        _imageView = objj_msgSend(aCoder, "decodeObjectForKey:", MediaCellImageViewKey);
        _titleField = objj_msgSend(aCoder, "decodeObjectForKey:", MediaCellTitleFieldKey);
        _sourceField = objj_msgSend(aCoder, "decodeObjectForKey:", MediaCellSourceFieldKey);
        _metaField = objj_msgSend(aCoder, "decodeObjectForKey:", MediaCellMetaFieldKey);
    }
    return self;
}
},["id","CPCoder"]), new objj_method(sel_getUid("encodeWithCoder:"), function $MKMediaCell__encodeWithCoder_(self, _cmd, aCoder)
{ with(self)
{
    objj_msgSendSuper({ receiver:self, super_class:objj_getClass("MKMediaCell").super_class }, "encodeWithCoder:", aCoder);
    objj_msgSend(aCoder, "encodeObject:forKey:", _imageView, MediaCellImageViewKey);
    objj_msgSend(aCoder, "encodeObject:forKey:", _titleField, MediaCellTitleFieldKey);
    objj_msgSend(aCoder, "encodeObject:forKey:", _sourceField, MediaCellSourceFieldKey);
    objj_msgSend(aCoder, "encodeObject:forKey:", _metaField, MediaCellMetaFieldKey);
}
},["void","CPCoder"])]);
}

p;14;MKMediaPanel.jt;22888;@STATIC;1.0;I;16;AppKit/CPPanel.jI;21;AppKit/CPPasteboard.ji;16;MKFlickrSearch.ji;21;MKGoogleImageSearch.ji;21;MKGoogleVideoSearch.ji;13;MKMediaCell.jt;22730;objj_executeFile("AppKit/CPPanel.j", NO);
objj_executeFile("AppKit/CPPasteboard.j", NO);
objj_executeFile("MKFlickrSearch.j", YES);
objj_executeFile("MKGoogleImageSearch.j", YES);
objj_executeFile("MKGoogleVideoSearch.j", YES);
objj_executeFile("MKMediaCell.j", YES);
MKMediaTypeImage = 1 << 0;
MKMediaTypeVideo = 1 << 1;
MKMediaTypeAll = 0xFFFF;
MKMediaPanelQueryReplacementString = "${QUERY}";
MKMediaPanelPageReplacementString = "${PAGE}";
var SharedMediaPanel = nil;
{var the_class = objj_allocateClassPair(CPPanel, "MKMediaPanel"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("searchField"), new objj_ivar("searchResultsLabel"), new objj_ivar("searchFilterRadioGroup"), new objj_ivar("mediaCollectionView"), new objj_ivar("loadingView"), new objj_ivar("scrollView"), new objj_ivar("connectionsByIdentifier"), new objj_ivar("URLsByIdentifier"), new objj_ivar("resultsByIdentifier"), new objj_ivar("delegatesByIdentifier"), new objj_ivar("target"), new objj_ivar("action")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("target"), function $MKMediaPanel__target(self, _cmd)
{ with(self)
{
return target;
}
},["id"]),
new objj_method(sel_getUid("setTarget:"), function $MKMediaPanel__setTarget_(self, _cmd, newValue)
{ with(self)
{
target = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("action"), function $MKMediaPanel__action(self, _cmd)
{ with(self)
{
return action;
}
},["id"]),
new objj_method(sel_getUid("setAction:"), function $MKMediaPanel__setAction_(self, _cmd, newValue)
{ with(self)
{
action = newValue;
}
},["void","id"]), new objj_method(sel_getUid("init"), function $MKMediaPanel__init(self, _cmd)
{ with(self)
{
    if (self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("MKMediaPanel").super_class }, "initWithContentRect:styleMask:", CGRectMake(100, 100, 300, 400), CPTitledWindowMask|CPResizableWindowMask|CPClosableWindowMask))
    {
        objj_msgSend(self, "setTitle:", "Searchbox");
        objj_msgSend(self, "setMinSize:", CPSizeMake(250, 300));
        var contentView = objj_msgSend(self, "contentView");
        searchField = objj_msgSend(CPTextField, "roundedTextFieldWithStringValue:placeholder:width:", "", "Search for media...", 224);
        objj_msgSend(searchField, "setFrameOrigin:", CGPointMake(8, 8));
        objj_msgSend(searchField, "setAutoresizingMask:", CPViewWidthSizable);
        objj_msgSend(contentView, "addSubview:", searchField);
        var searchButton = objj_msgSend(CPButton, "buttonWithTitle:", "Search");
        objj_msgSend(searchButton, "setFrameOrigin:", CGPointMake(CGRectGetMaxX(objj_msgSend(searchField, "bounds")) + 14, CGRectGetMinY(objj_msgSend(searchField, "frame")) + 3));
        objj_msgSend(searchButton, "setAutoresizingMask:", CPViewMinXMargin);
        objj_msgSend(searchButton, "setTarget:", self);
        objj_msgSend(searchButton, "setAction:", sel_getUid("search:"));
        objj_msgSend(searchField, "setTarget:", searchButton);
        objj_msgSend(searchField, "setAction:", sel_getUid("performClick:"));
        objj_msgSend(self, "setDefaultButton:", searchButton);
        objj_msgSend(contentView, "addSubview:", searchButton);
        var frameView = objj_msgSend(objj_msgSend(CPView, "alloc"), "initWithFrame:", CGRectMake(-1, CGRectGetMaxY(objj_msgSend(searchField, "bounds")) + 14, CGRectGetWidth(objj_msgSend(contentView, "bounds"))+2, CGRectGetHeight(objj_msgSend(contentView, "bounds")) - 40 - CGRectGetMaxY(objj_msgSend(searchField, "bounds"))));
        objj_msgSend(frameView, "setBackgroundColor:", objj_msgSend(CPColor, "lightGrayColor"));
        objj_msgSend(frameView, "setAutoresizingMask:", CPViewWidthSizable|CPViewHeightSizable);
        objj_msgSend(contentView, "addSubview:", frameView);
        var filterView = objj_msgSend(objj_msgSend(CPView, "alloc"), "initWithFrame:", CGRectMake(1, 1, CGRectGetWidth(objj_msgSend(frameView, "bounds")) - 2, 25));
        objj_msgSend(filterView, "setBackgroundColor:", objj_msgSend(CPColor, "colorWithRed:green:blue:alpha:", 213.0/255.0, 221.0/255.0, 230.0/255.0, 1.0));
        objj_msgSend(filterView, "setAutoresizingMask:", CPViewWidthSizable);
        objj_msgSend(frameView, "addSubview:", filterView);
        var filterBorder = objj_msgSend(objj_msgSend(CPView, "alloc"), "initWithFrame:", CGRectMake(0, 24, CGRectGetWidth(objj_msgSend(filterView, "bounds")), 1));
        objj_msgSend(filterBorder, "setBackgroundColor:", objj_msgSend(CPColor, "colorWithRed:green:blue:alpha:", 180.0/255.0, 195.0/255.0, 205.0/255.0, 1.0));
        objj_msgSend(filterBorder, "setAutoresizingMask:", CPViewWidthSizable);
        objj_msgSend(filterView, "addSubview:", filterBorder);
        var bundle = objj_msgSend(CPBundle, "bundleForClass:", objj_msgSend(self, "class")),
            leftCapImage = objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", objj_msgSend(bundle, "pathForResource:", "MediaFilterLeftCap.png"), CGSizeMake(9, 19)),
            rightCapImage = objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", objj_msgSend(bundle, "pathForResource:", "MediaFilterRightCap.png"), CGSizeMake(9, 19)),
            centerImage = objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", objj_msgSend(bundle, "pathForResource:", "MediaFilterCenter.png"), CGSizeMake(1, 19)),
            bezelImage = objj_msgSend(objj_msgSend(CPThreePartImage, "alloc"), "initWithImageSlices:isVertical:", [leftCapImage, centerImage, rightCapImage], NO);
        var allRadio = objj_msgSend(CPRadio, "radioWithTitle:", "All"),
            imagesRadio = objj_msgSend(CPRadio, "radioWithTitle:", "Images"),
            videosRadio = objj_msgSend(CPRadio, "radioWithTitle:", "Videos"),
            radioButtons = [allRadio, imagesRadio, videosRadio];
        for (var i=0, count = radioButtons.length; i < count; i++)
        {
            var thisRadio = radioButtons[i];
            objj_msgSend(thisRadio, "setAlignment:", CPCenterTextAlignment);
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:", objj_msgSend(CPColor, "clearColor"), "bezel-color");
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:inState:", objj_msgSend(CPColor, "colorWithPatternImage:", bezelImage), "bezel-color", CPThemeStateSelected);
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:", CGInsetMake(0.0, 10.0, 0.0, 10.0), "content-inset");
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:", CGSizeMake(0.0, 19.0), "min-size");
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:inState:", CGSizeMake(0.0, 1.0), "text-shadow-offset", CPThemeStateBordered);
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:", objj_msgSend(CPColor, "colorWithCalibratedWhite:alpha:", 79.0 / 255.0, 1.0), "text-color");
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:", objj_msgSend(CPColor, "colorWithCalibratedWhite:alpha:", 240.0 / 255.0, 1.0), "text-shadow-color");
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:inState:", objj_msgSend(CPColor, "colorWithCalibratedWhite:alpha:", 1.0, 1.0), "text-color", CPThemeStateSelected);
            objj_msgSend(thisRadio, "setValue:forThemeAttribute:inState:", objj_msgSend(CPColor, "colorWithCalibratedWhite:alpha:", 79 / 255.0, 1.0), "text-shadow-color", CPThemeStateSelected);
            objj_msgSend(thisRadio, "sizeToFit");
            objj_msgSend(thisRadio, "setTarget:", self);
            objj_msgSend(filterView, "addSubview:", thisRadio);
        }
        searchFilterRadioGroup = objj_msgSend(allRadio, "radioGroup");
        objj_msgSend(imagesRadio, "setRadioGroup:", searchFilterRadioGroup);
        objj_msgSend(videosRadio, "setRadioGroup:", searchFilterRadioGroup);
        objj_msgSend(allRadio, "setTag:", MKMediaTypeAll);
        objj_msgSend(imagesRadio, "setTag:", MKMediaTypeImage);
        objj_msgSend(videosRadio, "setTag:", MKMediaTypeVideo);
        objj_msgSend(allRadio, "setFrameOrigin:", CGPointMake(8, 3));
        objj_msgSend(imagesRadio, "setFrameOrigin:", CGPointMake(CGRectGetMaxX(objj_msgSend(allRadio, "frame")) + 8, CGRectGetMinY(objj_msgSend(allRadio, "frame"))));
        objj_msgSend(videosRadio, "setFrameOrigin:", CGPointMake(CGRectGetMaxX(objj_msgSend(imagesRadio, "frame")) + 8, CGRectGetMinY(objj_msgSend(imagesRadio, "frame"))));
        objj_msgSend(allRadio, "performClick:", nil);
        objj_msgSend(allRadio, "setAction:", sel_getUid("showAll:"));
        objj_msgSend(imagesRadio, "setAction:", sel_getUid("showImages:"));
        objj_msgSend(videosRadio, "setAction:", sel_getUid("showVideos:"));
        scrollView = objj_msgSend(objj_msgSend(CPScrollView, "alloc"), "initWithFrame:", CGRectMake(1, 26, CGRectGetWidth(objj_msgSend(frameView, "bounds")) - 2, CGRectGetHeight(objj_msgSend(frameView, "bounds")) - 27));
        objj_msgSend(scrollView, "setAutoresizingMask:", CPViewWidthSizable|CPViewHeightSizable);
        objj_msgSend(scrollView, "setHasHorizontalScroller:", NO);
        objj_msgSend(scrollView, "setAutohidesScrollers:", YES);
        objj_msgSend(objj_msgSend(scrollView, "contentView"), "setBackgroundColor:", objj_msgSend(CPColor, "whiteColor"));
        objj_msgSend(frameView, "addSubview:", scrollView);
        mediaCollectionView = objj_msgSend(objj_msgSend(CPCollectionView, "alloc"), "initWithFrame:", objj_msgSend(scrollView, "bounds"));
        objj_msgSend(mediaCollectionView, "setFrameSize:", CGSizeMake(CGRectGetWidth(objj_msgSend(scrollView, "bounds")), 0));
        objj_msgSend(mediaCollectionView, "setBackgroundColor:", objj_msgSend(CPColor, "whiteColor"));
        objj_msgSend(mediaCollectionView, "setAutoresizingMask:", CPViewWidthSizable);
        objj_msgSend(mediaCollectionView, "setDelegate:", self);
        var mediaCollectionItem = objj_msgSend(objj_msgSend(CPCollectionViewItem, "alloc"), "init");
        objj_msgSend(mediaCollectionItem, "setView:", objj_msgSend(objj_msgSend(MKMediaCell, "alloc"), "initWithFrame:", CGRectMake(0.0, 0.0, 200.0, 74.0)));
        objj_msgSend(mediaCollectionView, "setItemPrototype:", mediaCollectionItem);
        objj_msgSend(mediaCollectionView, "setMinItemSize:", CGSizeMake(200.0, 74.0));
        objj_msgSend(mediaCollectionView, "setMaxItemSize:", CGSizeMake(400.0, 74.0));
        objj_msgSend(mediaCollectionView, "setMaxNumberOfColumns:", 0);
        objj_msgSend(scrollView, "setDocumentView:", mediaCollectionView);
        searchResultsLabel = objj_msgSend(objj_msgSend(CPTextField, "alloc"), "initWithFrame:", CGRectMake(10, CGRectGetMaxY(objj_msgSend(frameView, "frame")) + 4, CGRectGetWidth(objj_msgSend(contentView, "bounds")) - 20, 20));
        objj_msgSend(searchResultsLabel, "setAutoresizingMask:", CPViewWidthSizable|CPViewMinYMargin);
        objj_msgSend(searchResultsLabel, "setAlignment:", CPCenterTextAlignment);
        objj_msgSend(searchResultsLabel, "setLineBreakMode:", CPLineBreakByTruncatingTail);
        objj_msgSend(contentView, "addSubview:", searchResultsLabel);
        loadingView = objj_msgSend(objj_msgSend(CPView, "alloc"), "initWithFrame:", objj_msgSend(scrollView, "frame"));
        objj_msgSend(loadingView, "setAutoresizingMask:", CPViewWidthSizable|CPViewHeightSizable);
        var progressIndicator = objj_msgSend(CPProgressIndicator, "new");
        objj_msgSend(progressIndicator, "setStyle:", CPProgressIndicatorSpinningStyle);
        objj_msgSend(progressIndicator, "sizeToFit");
        objj_msgSend(progressIndicator, "setAutoresizingMask:", CPViewMinXMargin|CPViewMinYMargin|CPViewMaxXMargin|CPViewMaxYMargin);
        objj_msgSend(progressIndicator, "setCenter:", objj_msgSend(loadingView, "center"));
        objj_msgSend(loadingView, "addSubview:", progressIndicator);
        objj_msgSend(frameView, "addSubview:", loadingView);
        objj_msgSend(loadingView, "setHidden:", YES);
  connectionsByIdentifier = objj_msgSend(CPDictionary, "dictionary");
  URLsByIdentifier = objj_msgSend(CPDictionary, "dictionary");
  resultsByIdentifier = objj_msgSend(CPDictionary, "dictionary");
  delegatesByIdentifier = objj_msgSend(CPDictionary, "dictionary");
  objj_msgSend(self, "addSourceWithIdentifier:URL:delegate:", objj_msgSend(MKGoogleImageSearchDelegate, "identifier"), objj_msgSend(MKGoogleImageSearchDelegate, "URL"), objj_msgSend(MKGoogleImageSearchDelegate, "new"));
  objj_msgSend(self, "addSourceWithIdentifier:URL:delegate:", objj_msgSend(MKGoogleVideoSearchDelegate, "identifier"), objj_msgSend(MKGoogleVideoSearchDelegate, "URL"), objj_msgSend(MKGoogleVideoSearchDelegate, "new"));
    }
    return self;
}
},["id"]), new objj_method(sel_getUid("collectionView:dragTypesForItemsAtIndexes:"), function $MKMediaPanel__collectionView_dragTypesForItemsAtIndexes_(self, _cmd, aCollectionView, anIndexSet)
{ with(self)
{
    return objj_msgSend(aCollectionView, "content")[objj_msgSend(anIndexSet, "firstIndex")].mediaType === MKMediaTypeImage ? [CPImagesPboardType] : [CPVideosPboardType];
}
},["CPArray","CPCollectionView","CPIndexSet"]), new objj_method(sel_getUid("collectionView:dataForItemsAtIndexes:forType:"), function $MKMediaPanel__collectionView_dataForItemsAtIndexes_forType_(self, _cmd, aCollectionView, indexes, aType)
{ with(self)
{
    var index = CPNotFound,
        content = objj_msgSend(aCollectionView, "content"),
        representedObjects = [];
    while ((index = objj_msgSend(indexes, "indexGreaterThanIndex:", index)) != CPNotFound)
    {
        var object = content[index],
            result = nil;
        if (aType === CPImagesPboardType && object.mediaType === MKMediaTypeImage)
            result = objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", object.url, object.contentSize);
        else if (aType === CPVideosPboardType && object.mediaType === MKMediaTypeVideo)
            result = objj_msgSend(objj_msgSend(CPFlashMovie, "alloc"), "initWithFile:", object.url);
        if (result)
            representedObjects.push(result);
    }
    return objj_msgSend(CPKeyedArchiver, "archivedDataWithRootObject:", representedObjects);
}
},["CPData","CPCollectionView","CPIndexSet","CPString"]), new objj_method(sel_getUid("collectionView:dragImageForItemWithIndex:"), function $MKMediaPanel__collectionView_dragImageForItemWithIndex_(self, _cmd, aCollectionView, anIndex)
{ with(self)
{
    var object = objj_msgSend(aCollectionView, "content")[anIndex];
    return objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", object.thumbnailURL, object.thumbnailSize);
}
},["CPImage","CPCollectionView","unsigned"]), new objj_method(sel_getUid("collectionView:didDoubleClickOnItemAtIndex:"), function $MKMediaPanel__collectionView_didDoubleClickOnItemAtIndex_(self, _cmd, aCollectionView, anIndex)
{ with(self)
{
    objj_msgSend(CPApp, "sendAction:to:from:", action, target, self);
}
},["void","CPCollectionView","unsgined"]), new objj_method(sel_getUid("selectedImage"), function $MKMediaPanel__selectedImage(self, _cmd)
{ with(self)
{
    var selectionIndex = objj_msgSend(objj_msgSend(mediaCollectionView, "selectionIndexes"), "firstIndex"),
        selection = selectionIndex !== nil ? objj_msgSend(mediaCollectionView, "content")[selectionIndex] : nil;
    if (selection && selection.mediaType === MKMediaTypeImage)
        return objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", selection.url, selection.contentSize);
    return nil;
}
},["CPImage"]), new objj_method(sel_getUid("selectedVideo"), function $MKMediaPanel__selectedVideo(self, _cmd)
{ with(self)
{
    var selectionIndex = objj_msgSend(objj_msgSend(mediaCollectionView, "selectionIndexes"), "firstIndex"),
        selection = selectionIndex !== nil ? objj_msgSend(mediaCollectionView, "content")[selectionIndex] : nil;
    if (selection && selection.mediaType === MKMediaTypeVideo)
        return objj_msgSend(objj_msgSend(CPFlashMovie, "alloc"), "initWithFile:", selection.url);
    return nil;
}
},["CPFlashMovie"]), new objj_method(sel_getUid("resultsWithMask:"), function $MKMediaPanel__resultsWithMask_(self, _cmd, aMask)
{ with(self)
{
    var allIDs = objj_msgSend(resultsByIdentifier, "allKeys"),
        count = objj_msgSend(allIDs, "count"),
        results = [];
    for (var i=0; i<count; i++)
    {
        var allObjects = objj_msgSend(resultsByIdentifier, "objectForKey:", allIDs[i]),
            allObjectsCount = objj_msgSend(allObjects, "count");
        for (var j=0; j<allObjectsCount; j++)
        {
            if (allObjects[j].mediaType & aMask)
                results.push(allObjects[j]);
        }
    }
    return results;
}
},["CPArray","unsigned"]), new objj_method(sel_getUid("showAll:"), function $MKMediaPanel__showAll_(self, _cmd, sender)
{ with(self)
{
    var allResults = objj_msgSend(self, "resultsWithMask:", MKMediaTypeAll);
    objj_msgSend(mediaCollectionView, "setContent:", allResults);
    objj_msgSend(self, "setResultCount:", objj_msgSend(allResults, "count"));
}
},["void","id"]), new objj_method(sel_getUid("showImages:"), function $MKMediaPanel__showImages_(self, _cmd, sender)
{ with(self)
{
    var imageResults = objj_msgSend(self, "resultsWithMask:", MKMediaTypeImage);
    objj_msgSend(mediaCollectionView, "setContent:", imageResults);
    objj_msgSend(self, "setResultCount:", objj_msgSend(imageResults, "count"));
}
},["void","id"]), new objj_method(sel_getUid("showVideos:"), function $MKMediaPanel__showVideos_(self, _cmd, sender)
{ with(self)
{
    var videoResults = objj_msgSend(self, "resultsWithMask:", MKMediaTypeVideo);
    objj_msgSend(mediaCollectionView, "setContent:", videoResults);
    objj_msgSend(self, "setResultCount:", objj_msgSend(videoResults, "count"));
}
},["void","id"]), new objj_method(sel_getUid("setResultCount:"), function $MKMediaPanel__setResultCount_(self, _cmd, count)
{ with(self)
{
    objj_msgSend(searchResultsLabel, "setStringValue:",  count == 1 ? "1 Result" : count+" Results");
}
},["void","unsigned"]), new objj_method(sel_getUid("setSearchTerm:"), function $MKMediaPanel__setSearchTerm_(self, _cmd, aQuery)
{ with(self)
{
    objj_msgSend(searchField, "setStringValue:", aQuery);
}
},["void","CPString"]), new objj_method(sel_getUid("search:"), function $MKMediaPanel__search_(self, _cmd, sender)
{ with(self)
{
    if (!objj_msgSend(objj_msgSend(searchField, "stringValue"), "length"))
        return;
    objj_msgSend(searchResultsLabel, "setStringValue:", "");
    objj_msgSend(mediaCollectionView, "setContent:", []);
    var query = encodeURIComponent(objj_msgSend(searchField, "stringValue")),
        identifiers = objj_msgSend(URLsByIdentifier, "allKeys");
    for (var i=0, count = objj_msgSend(identifiers, "count"); i<count; i++)
    {
        var identifier = identifiers[i],
            url = objj_msgSend(URLsByIdentifier, "objectForKey:", identifier);
        url = objj_msgSend(url, "stringByReplacingOccurrencesOfString:withString:", MKMediaPanelQueryReplacementString, query);
        var connection = objj_msgSend(objj_msgSend(CPJSONPConnection, "alloc"), "initWithRequest:callback:delegate:startImmediately:", objj_msgSend(CPURLRequest, "requestWithURL:", url), nil, self, NO);
        connection.identifier = identifier;
        objj_msgSend(objj_msgSend(connectionsByIdentifier, "objectForKey:", identifier), "cancel");
        objj_msgSend(connectionsByIdentifier, "setObject:forKey:", connection, identifier);
        objj_msgSend(connection, "start");
    }
    objj_msgSend(loadingView, "setHidden:", NO);
    objj_msgSend(searchResultsLabel, "setStringValue:", "Searching...");
}
},["void","id"]), new objj_method(sel_getUid("addSourceWithIdentifier:URL:delegate:"), function $MKMediaPanel__addSourceWithIdentifier_URL_delegate_(self, _cmd, anIdentifier, aURL, aDelegate)
{ with(self)
{
    objj_msgSend(self, "removeSourceWithIdentifier:", anIdentifier);
    objj_msgSend(delegatesByIdentifier, "setObject:forKey:", aDelegate, anIdentifier);
    objj_msgSend(URLsByIdentifier, "setObject:forKey:", aURL, anIdentifier);
}
},["void","CPString","CPString","id"]), new objj_method(sel_getUid("removeSourceWithIdentifier:"), function $MKMediaPanel__removeSourceWithIdentifier_(self, _cmd, anIdentifier)
{ with(self)
{
    objj_msgSend(objj_msgSend(connectionsByIdentifier, "objectForKey:", anIdentifier), "cancel");
    objj_msgSend(connectionsByIdentifier, "removeObjectForKey:", anIdentifier);
    objj_msgSend(delegatesByIdentifier, "removeObjectForKey:", anIdentifier);
    objj_msgSend(resultsByIdentifier, "removeObjectForKey:", anIdentifier);
    objj_msgSend(URLsByIdentifier, "removeObjectForKey:", anIdentifier);
}
},["void","CPString"]), new objj_method(sel_getUid("connection:didReceiveData:"), function $MKMediaPanel__connection_didReceiveData_(self, _cmd, aConnection, data)
{ with(self)
{
    var identifier = aConnection.identifier,
        delegate = objj_msgSend(delegatesByIdentifier, "objectForKey:", identifier),
        results = objj_msgSend(delegate, "mediaObjectsForIdentifier:data:", identifier, data),
        resultCount = objj_msgSend(results, "count"),
        updatedResultSet = objj_msgSend(objj_msgSend(mediaCollectionView, "content"), "copy");
    objj_msgSend(resultsByIdentifier, "setObject:forKey:", results, identifier);
    for (var i = 0; i < resultCount; i++)
        if (results[i].mediaType & objj_msgSend(objj_msgSend(searchFilterRadioGroup, "selectedRadio"), "tag"))
            updatedResultSet.push(results[i]);
    objj_msgSend(self, "setResultCount:", objj_msgSend(updatedResultSet, "count"));
    objj_msgSend(mediaCollectionView, "setContent:", updatedResultSet);
    objj_msgSend(connectionsByIdentifier, "removeObjectForKey:", identifier);
    objj_msgSend(loadingView, "setHidden:", YES);
}
},["void","CPJSONPConnection","Object"]), new objj_method(sel_getUid("connection:didFailWithError:"), function $MKMediaPanel__connection_didFailWithError_(self, _cmd, aConnection, anError)
{ with(self)
{
    var identifier = aConnection.identifier,
        delegate = objj_msgSend(delegatesByIdentifier, "objectForKey:", identifier);
    objj_msgSend(delegate, "mediaSearchWithIdentifier:failedWithError:", identifier, anError);
    objj_msgSend(resultsByIdentifier, "setObject:forKey:", [], identifier);
    objj_msgSend(connectionsByIdentifier, "removeObjectForKey:", identifier);
}
},["void","CPJSONPConnection","CPString"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("sharedMediaPanel"), function $MKMediaPanel__sharedMediaPanel(self, _cmd)
{ with(self)
{
    if (!SharedMediaPanel)
        SharedMediaPanel = objj_msgSend(objj_msgSend(self, "alloc"), "init");
    return SharedMediaPanel;
}
},["id"])]);
}

e;