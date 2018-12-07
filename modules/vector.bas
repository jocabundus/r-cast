#include once "inc/vector.bi"

constructor Vector()
    this.x = 0
    this.y = 0
    this.z = 0
end constructor

constructor Vector(x as double, y as double, z as double = 0)
    this.x = x
    this.y = y
    this.z = z
end constructor

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
    v.z =  u.z
    
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

function vectorSize(u as Vector) as double

    return sqr(u.x*u.x+u.y*u.y+u.z*u.z)

end function

operator + (byref u as Vector, byref v as Vector) as Vector
	return Vector(u.x+v.x, u.y+v.y, u.z+v.z)
end operator
operator - (byref u as Vector, byref v as Vector) as Vector
	return Vector(u.x-v.x, u.y-v.y, u.z-v.z)
end operator
operator * (byref u as Vector, byref v as Vector) as Vector
	return Vector(u.x*v.x, u.y*v.y, u.z*v.z)
end operator
operator / (byref u as Vector, byref v as Vector) as Vector
	return Vector(u.x/v.x, u.y/v.y, u.z/v.z)
end operator
operator * (byref u as Vector, byref d as double) as Vector
	return Vector(u.x*d, u.y*d, u.z*d)
end operator
operator / (byref u as Vector, byref d as double) as Vector
	return Vector(u.x/d, u.y/d, u.z/d)
end operator
operator = (byref u as Vector, byref v as Vector) as boolean
	return ((u.x = v.x) and (u.y = v.y) and (u.z = v.z))
end operator
