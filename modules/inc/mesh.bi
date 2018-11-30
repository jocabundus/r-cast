#pragma once
#inclib "mesh"

#include once "modules/inc/vector.bi"

type MeshTriangle
private:
    _points(3) as Vector
    _count as integer
public:
    declare constructor
    declare function points(idx as integer) as Vector ptr
    declare function addPoint(x as double, y as double, z as double) as MeshTriangle ptr
end type

type Mesh
private:
    _polys(144) as MeshTriangle
    _count as integer
    _current as integer
public:
    declare constructor
    declare function addCube(x as integer, y as integer, z as integer) as Mesh ptr
    declare function startOver() as Mesh ptr
    declare function getNext() as MeshTriangle ptr
end type
