#include once "inc/flatmap.bi"
#include once "inc/flatmapcell.bi"

constructor FlatMap(w as integer, h as integer)
    this._w = w
    this._h = h
    redim _grid(w, h) as FlatMapCell
end constructor

function FlatMap.getWidth() as integer
    return this._w
end function
function FlatMap.setWidth(w as integer) as FlatMap ptr
    this._w = w
    return @this
end function
function FlatMap.getHeight() as integer
    return this._h
end function
function FlatMap.setHeight(h as integer) as FlatMap ptr
    this._h = h
    return @this
end function

function FlatMap.getCell(x as integer, y as integer) as FlatMapCell ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        return @this._grid(x, this._h-1-y)
    else
        return @this._grid(0, 0)
    end if
end function
function FlatMap.setCell(cell as FlatMapCell, x as integer, y as integer) as FlatMap ptr
    if x >= 0 and x < this._w and y >= 0 and y < this._h then
        this._grid(x, this._h-1-y) = cell
    end if
    return @this
end function
function FlatMap.getCellAvg(x as integer, y as integer, size as integer) as FlatMapCell
    dim mx as integer, my as integer
    dim cell as FlatMapCell ptr
    dim newCell as FlatMapCell
    dim maxFloorHeight as double
    dim minCeilHeight as double
    dim sum as integer
    sum = 0
    maxFloorHeight = -99999
    minCeilHeight  =  99999
    for my = y to y+size-1
        for mx = x to x+size-1
            cell = this.getCell(mx, my)
            if cell <> 0 then
                sum += cell->getNormal()
                if cell->getFloorHeight() > maxFloorHeight then
                    maxFloorHeight = cell->getFloorHeight()
                    newCell.setFloorHeight(maxFloorHeight)
                    newCell.setFloorTile(cell->getFloorTile())
                    newCell.setSideTile(cell->getSideTile())
                    newCell.setFlags(cell->getFlags())
                end if
                if cell->getCeilHeight() < minCeilHeight then
                    minCeilHeight = cell->getCeilHeight()
                    newCell.setCeilHeight(minCeilHeight)
                    newCell.setCeilTile(cell->getCeilTile())
                end if
            end if
        next mx
    next my
    newCell.setNormal(sum / (size*size))
    return newCell
end function
