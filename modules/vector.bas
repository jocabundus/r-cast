#include once "inc/vector.bi"

function vectorFromAngle(a as double) as Vector

    dim v as Vector
    v.x = cos(a*TO_RAD)
    v.y = sin(a*TO_RAD)
    v.z = 0
    
    return v

end function

function vectorToRight(u as Vector) as Vector

    dim v as Vector
    v.y = -u.x
    v.x =  u.y
    
    return v

end function

function vectorToUnit(u as Vector) as Vector
    dim v as Vector
    dim m as double
    m = sqr(u.x*u.x+u.y*u.y+u.z*u.z)
    if m <> 0 then
        v.x = u.x / m
        v.y = u.y / m
        v.z = u.z / m
    else
        v.x = 0
		v.y = 0
        v.z = 0
    end if
    return v
end function

function vectorDot(u as Vector, v as Vector) as double
    return u.x*v.x+u.y*v.y+u.z*v.z
end function

function vectorCross(u as Vector, v as Vector) as Vector
    dim w as Vector
    w.x = u.y*v.z - u.z*v.y
    w.y = u.z*v.x - u.x*v.z    
    w.z = u.x*v.y - u.y*v.x
    return w
end function
