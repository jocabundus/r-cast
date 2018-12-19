#pragma once
#inclib "flatmap"

#include once "modules/inc/flatmapcell.bi"

type FlatMap
private:
    _w as integer
    _h as integer
    redim _grid(0, 0) as FlatMapCell
public:
    declare constructor(w as integer, h as integer)
    declare function getWidth() as integer
    declare function setWidth(w as integer) as FlatMap ptr
    declare function getHeight() as integer
    declare function setHeight(h as integer) as FlatMap ptr
    declare function getCell(x as integer, y as integer) as FlatMapCell ptr
    declare function setCell(cell as FlatMapCell, x as integer, y as integer) as FlatMap ptr
    declare function getCellAvg(x as integer, y as integer, size as integer) as FlatMapCell
end type
