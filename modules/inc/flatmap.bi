#pragma once
#inclib "flatmap"

type FlatMap
private:
    _w as integer
    _h as integer
    _size as integer
    dim   _walls(1024*1024) as byte
    dim _heights(1024*1024) as short
    dim   _ceils(1024*1024) as short
    dim   _tiles(1024*1024) as short
    dim  _ctiles(1024*1024) as short
    dim _normals(1024*1024) as byte
    dim _flags(1024*1024) as integer
public:
    declare constructor(w as integer, h as integer)
    declare function walls(x as integer, y as integer) as byte
    declare function heights(x as integer, y as integer) as short
    declare function ceils(x as integer, y as integer) as short
    declare function tiles(x as integer, y as integer) as integer
    declare function ceiltiles(x as integer, y as integer) as integer
    declare function normals(x as integer, y as integer) as byte
    declare function hasFlag(flag as integer, x as integer, y as integer) as integer
    declare function notFlag(flag as integer, x as integer, y as integer) as integer
    declare function setFlag(flag as integer, x as integer, y as integer) as FlatMap ptr
    declare function unsetFlag(flag as integer, x as integer, y as integer) as FlatMap ptr
    declare function getFlags(x as integer, y as integer) as integer
    declare function setFlags(flags as integer, x as integer, y as integer) as FlatMap ptr
    declare function clearFlags(x as integer, y as integer) as FlatMap ptr
    declare property w() as integer
    declare property w(new_w as integer)
    declare property h() as integer
    declare property h(new_h as integer)
    declare function setWall(x as integer, y as integer, new_w as integer) as FlatMap ptr
    declare function setHeight(x as integer, y as integer, new_h as integer) as FlatMap ptr
    declare function setCeil(x as integer, y as integer, new_h as integer) as FlatMap ptr
    declare function setTile(x as integer, y as integer, new_c as integer) as FlatMap ptr
    declare function setCeilTile(x as integer, y as integer, new_c as integer) as FlatMap ptr
    declare function setNormal(x as integer, y as integer, b as byte) as FlatMap ptr
    declare function getWallAvg(x as integer, y as integer, size as integer) as integer
    declare function getHeightAvg(x as integer, y as integer, size as integer) as integer
    declare function getCeilAvg(x as integer, y as integer, size as integer) as integer
    declare function getTileAvg(x as integer, y as integer, size as integer) as integer
    declare function getCeilTileAvg(x as integer, y as integer, size as integer) as integer
    declare function getNormalAvg(x as integer, y as integer, size as integer) as byte
    declare function getFlagsAvg(x as integer, y as integer, size as integer) as integer
end type
