#include once "inc/flatmap.bi"

constructor FlatMap(map_w as integer, map_h as integer)
    this._w = map_w
    this._h = map_h
    this._size = map_w*map_h
    'redim   _walls(map_w*map_h) as byte
    'redim _heights(map_w*map_h) as short
    'redim   _ceils(map_w*map_h) as short
    'redim  _colors(map_w*map_h) as integer
    'redim _ccolors(map_w*map_h) as integer
    'redim _normals(map_w*map_h) as byte
    'redim _flags(map_w*map_h) as integer
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
function FlatMap.ceils(x as integer, y as integer) as short
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._ceils(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.tiles(x as integer, y as integer) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._tiles(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.ceiltiles(x as integer, y as integer) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._ctiles(x+((this._h-1-y) shl 10))
    else
        return 0
    end if
end function
function FlatMap.normals(x as integer, y as integer) as byte
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._normals(x+((this._h-1-y) shl 10))
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
function Flatmap.setCeil(x as integer, y as integer, new_h as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._ceils(x+((this._h-1-y) shl 10)) = new_h
    end if
    return @this
end function
function Flatmap.setTile(x as integer, y as integer, new_c as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._tiles(x+((this._h-1-y) shl 10)) = new_c
    end if
    return @this
end function
function Flatmap.setCeilTile(x as integer, y as integer, new_c as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._ctiles(x+((this._h-1-y) shl 10)) = new_c
    end if
    return @this
end function
function Flatmap.setNormal(x as integer, y as integer, b as byte) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._normals(x+((this._h-1-y) shl 10)) = b
    end if
    return @this
end function
function FlatMap.hasFlag(flag as integer, x as integer, y as integer) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return (this._flags(x+((this._h-1-y) shl 10)) and flag) > 0
    else
        return -1
    end if
end function
function FlatMap.notFlag(flag as integer, x as integer, y as integer) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return not ((this._flags(x+((this._h-1-y) shl 10)) and flag) > 0)
    else
        return -1
    end if
end function
function FlatMap.setFlag(flag as integer, x as integer, y as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._flags(x+((this._h-1-y) shl 10)) = (this._flags(x+((this._h-1-y) shl 10)) or flag)
    end if
    return @this
end function
function FlatMap.unsetFlag(flag as integer, x as integer, y as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._flags(x+((this._h-1-y) shl 10)) = (this._flags(x+((this._h-1-y) shl 10)) or flag) xor flag
    end if
    return @this
end function
function FlatMap.getFlags(x as integer, y as integer) as integer
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return this._flags(x+((this._h-1-y) shl 10))
    else
        return -1
    end if
end function
function FlatMap.setFlags(flags as integer, x as integer, y as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._flags(x+((this._h-1-y) shl 10)) = flags
    end if
    return @this
end function
function FlatMap.clearFlags(x as integer, y as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._flags(x+((this._h-1-y) shl 10)) = 0
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
    dim max as double
    max = -99999
    for my = y to y+size-1
        for mx = x to x+size-1
            if this.heights(mx, my) > max then
                max = this.heights(mx, my)
            end if
        next mx
    next my
    return max
end function
function FlatMap.getCeilAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim min as double
    min = 99999
    for my = y to y+size-1
        for mx = x to x+size-1
            if this.ceils(mx, my) < min then
                min = this.ceils(mx, my)
            end if
        next mx
    next my
    return min
end function
function FlatMap.getTileAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim colr as integer
    dim max as double
    max = -99999
    for my = y to y+size-1
        for mx = x to x+size-1
            if this.heights(mx, my) > max then
                max = this.heights(mx, my)
                colr = this.tiles(mx, my)
            end if
        next mx
    next my
    return colr
end function
function FlatMap.getCeilTileAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim colr as integer
    dim min as double
    min = 99999
    for my = y to y+size-1
        for mx = x to x+size-1
            if this.ceils(mx, my) < min then
                min = this.ceils(mx, my)
                colr = this.ceiltiles(mx, my)
            end if
        next mx
    next my
    return colr
end function
function FlatMap.getNormalAvg(x as integer, y as integer, size as integer) as byte
    dim mx as integer, my as integer
    dim sum as integer
    sum = 0
    for my = y to y+size-1
        for mx = x to x+size-1
            sum += this.normals(mx, my)
        next mx
    next my
    return sum / (size*size)
end function
function FlatMap.getFlagsAvg(x as integer, y as integer, size as integer) as integer
    dim mx as integer, my as integer
    dim flags as integer
    dim max as double
    max = -99999
    for my = y to y+size-1
        for mx = x to x+size-1
            if this.heights(mx, my) > max then
                max = this.heights(mx, my)
                flags = this._flags(mx+((this._h-1-y) shl 10))
            end if
        next mx
    next my
    return flags
end function