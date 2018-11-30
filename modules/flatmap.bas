#include once "inc/flatmap.bi"

constructor FlatMap(map_w as integer, map_h as integer)
    this._w = map_w
    this._h = map_h
    dim i as integer
    for i = 0 to MAP_WIDTH*MAP_HEIGHT-1: this._callbacks(i) = 0: next i
    'redim this._walls(map_w, map_h)
    'redim this._heights(map_w, map_h)
    'redim this._colors(map_w, map_h)
end constructor
function FlatMap.walls(x as integer, y as integer) as byte
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._walls(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.heights(x as integer, y as integer) as short
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._heights(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.colors(x as integer, y as integer) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._colors(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.callbacks(x as integer, y as integer) as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._callbacks(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.datas(x as integer, y as integer, z as integer=0) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._data(x+((this._h-1-y) shl 10)+(z shl 20))
    else
        return 0
    end if
end function
property Flatmap.w() as integer
    return this._w
end property
property Flatmap.w(new_w as integer)
    this._w = new_w
end property
property Flatmap.h() as integer
    return this._h
end property
property Flatmap.h(new_h as integer)
    this._h = new_h
end property
function Flatmap.setWall(x as integer, y as integer, new_w as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._walls(x+((this._h-1-y) shl 10)) = new_w
    end if
    return @this
end function
function Flatmap.setHeight(x as integer, y as integer, new_h as integer) as FlatMap ptr
     if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._heights(x+((this._h-1-y) shl 10)) = new_h
    end if
    return @this
end function
function Flatmap.setColor(x as integer, y as integer, new_c as integer) as FlatMap ptr
     if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._colors(x+((this._h-1-y) shl 10)) = new_c
    end if
    return @this
end function
function Flatmap.setCallback(x as integer, y as integer, s as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)) as FlatMap ptr
     if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._callbacks((this._h-1-y) shl 10) = s
    end if
    return @this
end function
function Flatmap.setData(x as integer, y as integer, z as integer, value as integer) as FlatMap ptr
     if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._data(x+((this._h-1-y) shl 10)+(z shl 20)) = value
    end if
    return @this
end function
function FlatMap.getWallAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim sum as double
    dim max as double
    for my = y to y+size-1
        for mx = x to x+size-1
            sum += this.walls(mx, my)
        next mx
    next my
    size *= size
    return sum / size
end function
function FlatMap.getHeightAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    'dim sum as double
    dim max as double
    max = -99999
    for my = y to y+size-1
        for mx = x to x+size-1
            'sum += this.heights(mx, my)
            if this.heights(mx, my) > max then
                max = this.heights(mx, my)
            end if
        next mx
    next my
    'size *= size
    'return sum / size
    return max
end function
function FlatMap.getColorAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim colr as integer
    dim max as double
    max = -99999
    for my = y to y+size-1
        for mx = x to x+size-1
            if this.heights(mx, my) > max then
                max = this.heights(mx, my)
                colr = this.colors(mx, my)
            end if
        next mx
    next my
    return colr
    'dim r as integer, g as integer, b as integer
    'for my = y to y+size-1
    '    for mx = x to x+size-1
    '        r += ((this.colors(mx, my) shr 16) and &hff)
    '        g += ((this.colors(mx, my) shr  8) and &hff)
    '        b += (this.colors(mx, my) and &hff)
    '    next mx
    'next my
    'size *= size
    'return rgb(r / size, g / size, b / size)
end function
function FlatMap.getCallbackAvg(x as integer, y as integer, size as integer) as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)
    dim mx as integer, my as integer
    'dim sum as double
    dim s as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)
    dim max as double
    max = -99999
    s = 0
    for my = y to y+size-1
        for mx = x to x+size-1
            'sum += this.heights(mx, my)
            if this.heights(mx, my) > max then
                max = this.heights(mx, my)
                s = this.callbacks(mx, my)
            end if
        next mx
    next my
    'size *= size
    'return sum / size
    return s
end function
function FlatMap.getDataAvg(x as integer, y as integer, z as integer, size as integer) as integer
    dim mx as integer, my as integer
    'dim sum as double
    dim dat as integer
    dim max as double
    max = -99999
    for my = y to y+size-1
        for mx = x to x+size-1
            'sum += this.heights(mx, my)
            if this.heights(mx, my) > max then
                max = this.heights(mx, my)
                dat = this.datas(mx, my, z)
            end if
        next mx
    next my
    'size *= size
    'return sum / size
    return dat
end function
