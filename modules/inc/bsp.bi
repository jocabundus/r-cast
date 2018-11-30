#pragma once
#inclib "bsp"

#include once "modules/inc/vector.bi"

type BspNode
private:
    _normal as Vector
    _behind as BspNode ptr
    _front as BspNode ptr
    _data as any ptr
public:
    declare constructor()
    declare function getNormal() as Vector ptr
    declare function getBehind() as BspNode ptr
    declare function getFront() as BspNode ptr
    declare function getData() as any ptr
    declare function setData(p as any ptr) as BspNode ptr
end type

constructor BspNode
    this._behind = 0
    this._front = 0
    this._data = 0
end constructor
function BspNode.getNormal() as Vector ptr
    return @this._normal
end function
function BspNode.getBehind() as BspNode ptr
    return this._behind
end function
function BspNode.getFront() as BspNode ptr
    return this._front
end function
function BspNode.getData() as any ptr
    return this._data
end function
function BspNode.setData(p as any ptr) as BspNode ptr
    this._data = p
    return @this
end function

type BspTree
private:
    _node_start as BspNode
    _nodes(4096) as BspNode
public:
    declare function addBehind(normal as Vector) as BspTree ptr
    declare function addFront(normal as Vector) as BspTree ptr
end type
