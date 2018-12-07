#pragma once
#inclib "vector"

#define TO_RAD     0.017453292519943

type Vector
    x as double
    y as double
    z as double
    declare constructor()
    declare constructor(x as double, y as double, z as double = 0)
end type

declare function vectorFromAngle(a as double) as Vector
declare function vectorToRight(u as Vector) as Vector
declare function vectorToUnit(u as Vector) as Vector
declare function vectorDot(u as Vector, v as Vector) as double
declare function vectorCross(u as Vector, v as Vector) as Vector
declare function vectorSize(u as Vector) as double
declare operator + (byref u as Vector, byref v as Vector) as Vector
declare operator - (byref u as Vector, byref v as Vector) as Vector
declare operator * (byref u as Vector, byref v as Vector) as Vector
declare operator / (byref u as Vector, byref v as Vector) as Vector
declare operator * (byref u as Vector, byref d as double) as Vector
declare operator / (byref u as Vector, byref d as double) as Vector
declare operator = (byref u as Vector, byref d as double) as boolean
