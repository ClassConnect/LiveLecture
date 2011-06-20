@STATIC;1.0;i;14;CGColorSpace.jt;3192;objj_executeFile("CGColorSpace.j", YES);
var CFTypeGlobalCount = 0;
CFHashCode= function(aCFObject)
{
    if (!aCFObject.hash)
        aCFObject.hash = ++CFTypeGlobalCount;
    return aCFObject;
}
kCGColorWhite = "kCGColorWhite";
kCGColorBlack = "kCGColorBlack";
kCGColorClear = "kCGColorClear";
var _CGColorMap = { };
CGColorGetConstantColor= function(aColorName)
{
    alert("FIX ME");
}
CGColorRetain= function(aColor)
{
    return aColor;
}
CGColorRelease= function()
{
}
CGColorCreate= function(aColorSpace, components)
{
    if (!aColorSpace || !components)
        return NULL;
    var components = components.slice();
    CGColorSpaceStandardizeComponents(aColorSpace, components);
    var UID = CFHashCode(aColorSpace) + components.join("");
    if (_CGColorMap[UID])
        return _CGColorMap[UID];
    return _CGColorMap[UID] = { colorspace:aColorSpace, pattern:NULL, components:components };
}
CGColorCreateCopy= function(aColor)
{
    return aColor;
}
CGColorCreateGenericGray= function(gray, alpha)
{
    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), [gray,gray,gray, alpha]);
}
CGColorCreateGenericRGB= function(red, green, blue, alpha)
{
    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), [red, green, blue, alpha]);
}
CGColorCreateGenericCMYK= function(cyan, magenta, yellow, black, alpha)
{
    return CGColorCreate(CGColorSpaceCreateDeviceCMYK(),
                         [cyan, magenta, yellow, black, alpha]);
}
CGColorCreateCopyWithAlpha= function(aColor, anAlpha)
{
    if ( !aColor ) return aColor;
    var components = aColor.components.slice();
    if (anAlpha == components[components.length - 1])
        return aColor;
    components[components.length - 1] = anAlpha;
    if (aColor.pattern)
        return CGColorCreateWithPattern(aColor.colorspace, aColor.pattern, components);
    else
        return CGColorCreate(aColor.colorspace, components);
}
CGColorCreateWithPattern= function(aColorSpace, aPattern, components)
{
    if (!aColorSpace || !aPattern || !components)
        return NULL;
    return { colorspace:aColorSpace, pattern:aPattern, components:components.slice() };
}
CGColorEqualToColor= function(lhs, rhs)
{
    if (lhs == rhs)
        return true;
    if (!lhs || !rhs)
        return false;
    var lhsComponents = lhs.components,
        rhsComponents = rhs.components,
        lhsComponentCount = lhsComponents.length;
    if (lhsComponentCount != rhsComponents.length)
        return false;
    while (lhsComponentCount--)
        if (lhsComponents[lhsComponentCount] != rhsComponents[lhsComponentCount])
            return false;
    if (lhs.pattern != rhs.pattern)
        return false;
    if (CGColorSpaceEqualToColorSpace(lhs.colorspace, rhs.colorspace))
        return false;
    return true;
}
CGColorGetAlpha= function(aColor)
{
    var components = aColor.components;
    return components[components.length - 1];
}
CGColorGetColorSpace= function(aColor)
{
    return aColor.colorspace;
}
CGColorGetComponents= function(aColor)
{
    return aColor.components;
}
CGColorGetNumberOfComponents= function(aColor)
{
    return aColor.components.length;
}
CGColorGetPattern= function(aColor)
{
    return aColor.pattern;
}

