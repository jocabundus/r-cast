#pragma once
#inclib "vector"

#define TO_RAD     0.017453292519943

type Vector
    x as double
    y as double
    z as double
end type

declare function vectorFromAngle(a as double) as Vector
declare function vectorToRight(u as Vector) as Vector
declare function vectorToUnit(u as Vector) as Vector
declare function vectorDot(u as Vector, v as Vector) as double
declare function vectorCross(u as Vector, v as Vector) as Vector
