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

function vectorRight(u as Vector) as Vector

    dim v as Vector
    v.y = -u.x
    v.x =  u.y
    v.z =  u.z
    
    return v

end function

function vectorUnit(u as Vector) as Vector
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

function vectorTranslate(u as Vector, x as double, y as double, z as double) as Vector
    dim v as Vector
    v.x = u.x + x
    v.y = u.y + y
    v.z = u.x + z
    return v
end function

function vectorRotateX(u as Vector, a as double) as Vector
    dim v as Vector
    dim va as Vector
    va = vectorFromAngle(a)
    v.x = u.x
    v.y = u.y*va.x + u.z*-va.y
    v.z = u.y*va.y + u.z*va.x
    return v
end function

function vectorRotateY(u as Vector, a as double) as Vector
    dim v as Vector
    dim va as Vector
    va = vectorFromAngle(a)
    v.x = u.x*va.x + u.z*-va.y
    v.y = u.y
    v.z = u.x*va.y + u.z*va.x
    return v
end function

function vectorRotateZ(u as Vector, a as double) as Vector
    dim v as Vector
    dim va as Vector
    va = vectorFromAngle(a)
    v.x = u.x*va.x + u.y*-va.y
    v.y = u.x*va.y + u.y*va.x
    v.z = u.z
    return v
end function

function vectorMake2d(u as Vector, xScale as double, yScale as double, zxScale as double, zyScale as double) as Vector
    dim halfx as double, halfy as double
    dim zx as double, zy as double
    dim v as Vector
    halfx = xScale*0.5
    halfy = yScale*0.5
    zx = (u.z * zxScale): if zx = 0 then return u
    zy = (u.z * zyScale): if zy = 0 then return u
    v.x = ( u.x*xScale) / zx + halfx
    v.y = (-u.y*xScale) / zy + halfy
    v.z = 0
    return v
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
operator - (byref u as Vector) as Vector
    return Vector(-u.x, -u.y, -u.z)
end operator
