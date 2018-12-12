#pragma once
#inclib "mesh"

#include once "modules/inc/vector.bi"

type Vector3
    v(4) as Vector
    declare function translate(x as double, y as double, z as double) as Vector3 ptr
    declare function rotateX(a as double) as Vector3 ptr
    declare function rotateY(a as double) as Vector3 ptr
    declare function rotateZ(a as double) as Vector3 ptr
    declare function make2d(xScale as double, yScale as double, zxScale as double = 1.0, zyScale as double = 1.0) as Vector3 ptr
end type

type MeshPoly
    v(4) as Vector ptr
    idx(4) as integer
    declare function copy() as Vector3
end type

type Mesh
private:
    _polys(512) as MeshPoly
    _normals(512) as Vector
    _vertices(512) as Vector
    _polyCount as integer
    _normalCount as integer
    _vertexCount as integer
    _current as integer
    _z as double
public:
    declare constructor()
    declare function addVertex(x as double, y as double, z as double) as Vector ptr
    declare function addVertex(v as Vector) as Vector ptr
    declare function addNormal(v as Vector) as Vector ptr
    declare function addCube(x as double, y as double, z as double, xSize as double=1.0, ySize as double=1.0, zSize as double=1.0) as Mesh ptr
    declare function startOver() as Mesh ptr
    declare function getNext() as MeshPoly ptr
    declare function sort() as Mesh ptr
    declare function addPoly(u as Vector, v as Vector, w as Vector, nIdx as integer = -1) as Mesh ptr
    declare function addPolyByVertices(v0 as integer, v1 as integer, v2 as integer, nIdx as integer = -1) as Mesh ptr
    declare function translate(x as double, y as double, z as double) as Mesh ptr
    declare function rotateX(a as double) as Mesh ptr
    declare function rotateY(a as double) as Mesh ptr
    declare function rotateZ(a as double) as Mesh ptr
    declare function copy(m as Mesh ptr) as Mesh ptr
    declare function getVertexCount() as integer
    declare function getNormalCount() as integer
    declare function getPolyCount() as integer
    declare function getVertex(idx as integer) as Vector ptr
    declare function getNormal(idx as integer) as Vector ptr
    declare function getPoly(idx as integer) as MeshPoly ptr
    declare function addVertexFast(v as Vector ptr) as Mesh ptr
    declare function addNormalFast(v as Vector ptr) as Mesh ptr
    declare function addPolyFast(p as MeshPoly ptr) as Mesh ptr
end type
