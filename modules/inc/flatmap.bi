#pragma once
#inclib "flatmap"

#define MAP_WIDTH    1024
#define MAP_HEIGHT   1024

type FlatMap
private:
    _w as integer
    _h as integer
    dim   _walls(MAP_WIDTH*MAP_HEIGHT) as byte
    dim _heights(MAP_WIDTH*MAP_HEIGHT) as short
    dim  _colors(MAP_WIDTH*MAP_HEIGHT) as integer
    dim _callbacks(MAP_WIDTH*MAP_HEIGHT) as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)
    dim _data(MAP_WIDTH*MAP_HEIGHT*2) as integer
public:
    declare constructor(w as integer, h as integer)
    declare function walls(x as integer, y as integer) as byte
    declare function heights(x as integer, y as integer) as short
    declare function colors(x as integer, y as integer) as integer
    declare function callbacks(x as integer, y as integer) as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)
    declare function datas(x as integer, y as integer, z as integer=0) as integer
    declare property w() as integer
    declare property w(new_w as integer)
    declare property h() as integer
    declare property h(new_h as integer)
    declare function setWall(x as integer, y as integer, new_w as integer) as FlatMap ptr
    declare function setHeight(x as integer, y as integer, new_h as integer) as FlatMap ptr
    declare function setColor(x as integer, y as integer, new_c as integer) as FlatMap ptr
    declare function setCallback(x as integer, y as integer, s as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)) as FlatMap ptr
    declare function setData(x as integer, y as integer, z as integer, value as integer) as FlatMap ptr
    declare function getWallAvg(x as integer, y as integer, size as integer) as integer
    declare function getHeightAvg(x as integer, y as integer, size as integer) as integer
    declare function getColorAvg(x as integer, y as integer, size as integer) as integer
    declare function getCallbackAvg(x as integer, y as integer, size as integer) as sub(byref x_dx as uinteger, byref x_dy as uinteger, byref y_dx as uinteger, byref y_dy as uinteger)
    declare function getDataAvg(x as integer, y as integer, z as integer, size as integer) as integer
end type
