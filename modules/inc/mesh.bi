#pragma once
#inclib "mesh"

#include once "modules/inc/vector.bi"

type Vector3
    v(3) as Vector
    declare function translate(x as double, y as double, z as double) as Vector3 ptr
    declare function rotateX(a as double) as Vector3 ptr
    declare function rotateY(a as double) as Vector3 ptr
    declare function rotateZ(a as double) as Vector3 ptr
    declare function make2d(xScale as double, yScale as double, zxScale as double = 1.0, zyScale as double = 1.0) as Vector3 ptr
end type

type MeshPoly
    v(3) as Vector ptr
    idx(3) as integer
    declare function copy() as Vector3
end type

type Mesh
private:
    _polys(768) as MeshPoly
    _points(768) as Vector
    _polyCount as integer
    _pointCount as integer
    _current as integer
    _z as double
    declare function _addPoint(x as double, y as double, z as double) as Vector ptr
    declare function _addPoint(v as Vector) as Vector ptr
public:
    declare constructor()
    declare function addCube(x as double, y as double, z as double, xSize as double=1.0, ySize as double=1.0, zSize as double=1.0) as Mesh ptr
    declare function startOver() as Mesh ptr
    declare function getNext() as MeshPoly ptr
    declare function sort() as Mesh ptr
    declare function addPoly(u as Vector, v as Vector, w as Vector) as Mesh ptr
    declare function translate(x as double, y as double, z as double) as Mesh ptr
    declare function rotateX(a as double) as Mesh ptr
    declare function rotateY(a as double) as Mesh ptr
    declare function rotateZ(a as double) as Mesh ptr
    declare function copy(m as Mesh ptr) as Mesh ptr
    declare function getPointCount() as integer
    declare function getPolyCount() as integer
    declare function getPoint(idx as integer) as Vector ptr
    declare function getPoly(idx as integer) as MeshPoly ptr
    declare function addPointFast(v as Vector ptr) as Mesh ptr
    declare function addPolyFast(p as MeshPoly ptr) as Mesh ptr
end type
