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
declare function vectorRight(u as Vector) as Vector
declare function vectorUnit(u as Vector) as Vector
declare function vectorDot(u as Vector, v as Vector) as double
declare function vectorCross(u as Vector, v as Vector) as Vector
declare function vectorSize(u as Vector) as double
declare function vectorTranslate(u as Vector, x as double, y as double, z as double) as Vector
declare function vectorRotateX(u as Vector, a as double) as Vector
declare function vectorRotateY(u as Vector, a as double) as Vector
declare function vectorRotateZ(u as Vector, a as double) as Vector
declare function vectorMake2d(u as Vector, xScale as double, yScale as double, zxScale as double, zyScale as double) as Vector
declare operator + (byref u as Vector, byref v as Vector) as Vector
declare operator - (byref u as Vector, byref v as Vector) as Vector
declare operator * (byref u as Vector, byref v as Vector) as Vector
declare operator / (byref u as Vector, byref v as Vector) as Vector
declare operator * (byref u as Vector, byref d as double) as Vector
declare operator / (byref u as Vector, byref d as double) as Vector
declare operator = (byref u as Vector, byref d as double) as boolean
declare operator - (byref u as Vector) as Vector
