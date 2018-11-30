#include once "inc/rgb.bi"

function red(argb32 as integer) as integer
    return (argb32 shr 16) and &hff
end function
function grn(argb32 as integer) as integer
    return (argb32 shr 8) and &hff
end function
function blu(argb32 as integer) as integer
    return argb32 and &hff
end function
function rgbAdd(colr as integer, amount as integer, keepHue as integer = 0) as integer
    dim r as integer
    dim g as integer
    dim b as integer
    r = (colr shr 16) and &hff
    g = (colr shr  8) and &hff
    b = (colr       ) and &hff
    if keepHue then
        '// TODO
    else
        r += amount
        g += amount
        b += amount
        if r > 255 then r = 255: if r < 0 then r = 0
        if g > 255 then g = 255: if g < 0 then g = 0
        if b > 255 then b = 255: if b < 0 then b = 0
    end if
    return rgb(r, g, b)
end function
function rgbMix(colr0 as integer, colr1 as integer, f1 as double = 1, f2 as double = 1) as integer
    dim r0 as integer, r1 as integer
    dim g0 as integer, g1 as integer
    dim b0 as integer, b1 as integer
    dim r as integer
    dim g as integer
    dim b as integer
    r0 = (colr0 shr 16) and &hff: r1 = (colr1 shr 16) and &hff
    g0 = (colr0 shr  8) and &hff: g1 = (colr1 shr  8) and &hff
    b0 = (colr0       ) and &hff: b1 = (colr1       ) and &hff
    r = (r0*f1+r1*f2)/(f1+f2)
    g = (g0*f1+g1*f2)/(f1+f2)
    b = (b0*f1+b1*f2)/(f1+f2)
    return rgb(r, g, b)
end function
