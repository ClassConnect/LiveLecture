@STATIC;1.0;i;9;CGColor.ji;14;CGColorSpace.jt;1099;objj_executeFile("CGColor.j", YES);
objj_executeFile("CGColorSpace.j", YES);
kCGGradientDrawsBeforeStartLocation = 1 << 0;
kCGGradientDrawsAfterEndLocation = 1 << 1;
CGGradientCreateWithColorComponents= function(aColorSpace, components, locations, count)
{
    if ( locations === undefined || locations === NULL )
    {
        var num_of_colors = components.length / 4,
            locations = [];
        for ( var idx = 0; idx < num_of_colors; idx++ )
            locations.push( idx / (num_of_colors - 1) );
    }
    if ( count === undefined || count === NULL)
        var count = locations.length;
    var colors = [];
    while (count--)
    {
        var offset = count * 4;
        colors[count] = CGColorCreate(aColorSpace, components.slice(offset, offset + 4));
    }
    return CGGradientCreateWithColors(aColorSpace, colors, locations);
}
CGGradientCreateWithColors= function(aColorSpace, colors, locations)
{
    return { colorspace:aColorSpace, colors:colors, locations:locations };
}
CGGradientRelease= function()
{
}
CGGradientRetain= function(aGradient)
{
    return aGradient;
}

