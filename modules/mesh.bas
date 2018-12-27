#include once "inc/mesh.bi"

constructor Mesh()
    this._polyCount = 0
    this._normalCount = 0
    this._vertexCount = 0
    this._current = 0
    this._z = 0
end constructor
function Mesh.startOver() as Mesh ptr
    this._current = 0
    return @this
end function
function Mesh.getNext() as MeshPoly ptr
    dim c as integer
    if this._current < this._polyCount then
        c = this._current
        this._current += 1
        return @this._polys(c)
    else
        return 0
    end if
end function
function Mesh.sort() as Mesh ptr
    dim i as integer
    dim n as integer
    dim z0 as double
    dim z1 as double
    for i = 0 to this._polyCount-1
        for n = i+1 to this._polyCount-1
            z0 = (this._polys(i).v(0)->z+this._polys(i).v(1)->z+this._polys(i).v(2)->z)/3
            z1 = (this._polys(n).v(0)->z+this._polys(n).v(1)->z+this._polys(n).v(2)->z)/3
            'z0 = iif(this._polys(i).v(0)->z > this._polys(i).v(1)->z,_
            '     iif(this._polys(i).v(0)->z > this._polys(i).v(2)->z, this._polys(i).v(0)->z, this._polys(i).v(2)->z),_
            '     iif(this._polys(i).v(1)->z > this._polys(i).v(2)->z, this._polys(i).v(1)->z, this._polys(i).v(2)->z))
            'z1 = iif(this._polys(n).v(0)->z > this._polys(n).v(1)->z,_
            '     iif(this._polys(n).v(0)->z > this._polys(n).v(2)->z, this._polys(n).v(0)->z, this._polys(n).v(2)->z),_
            '     iif(this._polys(n).v(1)->z > this._polys(n).v(2)->z, this._polys(n).v(1)->z, this._polys(n).v(2)->z))
            'if z0 > z1 then
            if z0 < z1 then
                swap this._polys(i), this._polys(n)
            end if
        next n
    next i
    return @this
end function
function Mesh.addVertex(x as double, y as double, z as double) as Vector ptr
    dim i as integer
    dim n as integer
    i = this._vertexCount
    if i < 768 then
        for n = 0 to i-1
            if (this._vertices(n).x = x) and (this._vertices(n).y = y) and (this._vertices(n).z = z) then
                return @this._vertices(n)
            end if
        next n
        this._vertices(i).x = x
        this._vertices(i).y = y
        this._vertices(i).z = z
        this._vertexCount += 1
    else
        return 0
    end if
    return @this._vertices(i)
end function
function Mesh.addVertex(v as Vector) as Vector ptr
    return this.addVertex(v.x, v.y, v.z)
end function
function Mesh.addNormal(v as Vector) as Vector ptr
    dim i as integer
    dim n as integer
    i = this._normalCount
    if i < 768 then
        for n = 0 to i-1
            if (this._normals(n).x = v.x) and (this._normals(n).y = v.y) and (this._normals(n).z = v.z) then
                return @this._normals(n)
            end if
        next n
        this._normals(i).x = v.x
        this._normals(i).y = v.y
        this._normals(i).z = v.z
        this._normalCount += 1
    else
        return 0
    end if
end function
function Mesh.addPoly(u as Vector, v as Vector, w as Vector, nIdx as integer = -1) as Mesh ptr
    dim i as integer
    dim n as integer
    dim poly as MeshPoly ptr
    dim addU as integer
    dim addV as integer
    dim addW as integer
    addU = 0
    addV = 0
    addW = 0
    if this._polyCount < 768 then
        for i = 0 to this._polyCount - 1
            poly = @this._polys(i)
            if (*poly->v(0).x = u.x) and (*poly->v(0).y = u.y) and (*poly->v(0).z = u.z)_
            and(*poly->v(1).x = v.x) and (*poly->v(1).y = v.y) and (*poly->v(1).z = v.z)_
            and(*poly->v(2).x = w.x) and (*poly->v(2).y = w.y) and (*poly->v(2).z = w.z) then
                for n = i to this._polyCount - 2
                    this._polys(n) = this._polys(n+1)
                next n
                this._polyCount -= 1
                return @this
            end if
            if (*poly->v(0).x = u.x) and (*poly->v(0).y = u.y) and (*poly->v(0).z = u.z)_
            and(*poly->v(2).x = v.x) and (*poly->v(2).y = v.y) and (*poly->v(2).z = v.z)_
            and(*poly->v(1).x = w.x) and (*poly->v(1).y = w.y) and (*poly->v(1).z = w.z) then
                for n = i to this._polyCount - 2
                    this._polys(n) = this._polys(n+1)
                next n
                this._polyCount -= 1
                return @this
            end if
            if (*poly->v(1).x = u.x) and (*poly->v(1).y = u.y) and (*poly->v(1).z = u.z)_
            and(*poly->v(0).x = v.x) and (*poly->v(0).y = v.y) and (*poly->v(0).z = v.z)_
            and(*poly->v(2).x = w.x) and (*poly->v(2).y = w.y) and (*poly->v(2).z = w.z) then
                for n = i to this._polyCount - 2
                    this._polys(n) = this._polys(n+1)
                next n
                this._polyCount -= 1
                return @this
            end if
            if (*poly->v(1).x = u.x) and (*poly->v(1).y = u.y) and (*poly->v(1).z = u.z)_
            and(*poly->v(2).x = v.x) and (*poly->v(2).y = v.y) and (*poly->v(2).z = v.z)_
            and(*poly->v(0).x = w.x) and (*poly->v(0).y = w.y) and (*poly->v(0).z = w.z) then
                for n = i to this._polyCount - 2
                    this._polys(n) = this._polys(n+1)
                next n
                this._polyCount -= 1
                return @this
            end if
            if (*poly->v(2).x = u.x) and (*poly->v(2).y = u.y) and (*poly->v(2).z = u.z)_
            and(*poly->v(1).x = v.x) and (*poly->v(1).y = v.y) and (*poly->v(1).z = v.z)_
            and(*poly->v(0).x = w.x) and (*poly->v(0).y = w.y) and (*poly->v(0).z = w.z) then
                for n = i to this._polyCount - 2
                    this._polys(n) = this._polys(n+1)
                next n
                this._polyCount -= 1
                return @this
            end if
            if (*poly->v(2).x = u.x) and (*poly->v(2).y = u.y) and (*poly->v(2).z = u.z)_
            and(*poly->v(0).x = v.x) and (*poly->v(0).y = v.y) and (*poly->v(0).z = v.z)_
            and(*poly->v(1).x = w.x) and (*poly->v(1).y = w.y) and (*poly->v(1).z = w.z) then
                for n = i to this._polyCount - 2
                    this._polys(n) = this._polys(n+1)
                next n
                this._polyCount -= 1
                return @this
            end if
        next i
        poly = @this._polys(this._polyCount)
        poly->v(0) = 0
        poly->v(1) = 0
        poly->v(2) = 0
        for i = 0 to this._vertexCount - 1
            if (u.x = this._vertices(i).x) and (u.y = this._vertices(i).y) and (u.z = this._vertices(i).z) then
                poly->v(0) = @this._vertices(i)
                poly->idx(0) = i
                exit for
            end if
        next i
        if poly->v(0) = 0 then addU = 1
        for i = 0 to this._vertexCount - 1
            if (v.x = this._vertices(i).x) and (v.y = this._vertices(i).y) and (v.z = this._vertices(i).z) then
                poly->v(1) = @this._vertices(i)
                poly->idx(1) = i
                exit for
            end if
        next i
        if poly->v(1) = 0 then addV = 1
        for i = 0 to this._vertexCount - 1
            if (w.x = this._vertices(i).x) and (w.y = this._vertices(i).y) and (w.z = this._vertices(i).z) then
                poly->v(2) = @this._vertices(i)
                poly->idx(2) = i
                exit for
            end if
        next i
        if poly->v(2) = 0 then addW = 1
        if addU then poly->v(0) = this.addVertex(u): poly->idx(0) = this._vertexCount-1
        if addV then poly->v(1) = this.addVertex(v): poly->idx(1) = this._vertexCount-1
        if addW then poly->v(2) = this.addVertex(w): poly->idx(2) = this._vertexCount-1
        if nIdx >= 0 then poly->v(3) = this.getNormal(nIdx): poly->idx(3) = nIdx
        'this._polys(this._polyCount) = poly
        this._polyCount += 1
    end if
    return @this
end function
function Mesh.addPolyByVertices(v0 as integer, v1 as integer, v2 as integer, nIdx as integer = -1) as Mesh ptr
    'this.addPoly(*this.getVertex(v0), *this.getVertex(v1), *this.getVertex(v2), nIdx)
    dim poly as MeshPoly ptr
    poly = @this._polys(this._polyCount)
    poly->v(0) = this.getVertex(v0): poly->idx(0) = v0
    poly->v(1) = this.getVertex(v1): poly->idx(1) = v1
    poly->v(2) = this.getVertex(v2): poly->idx(2) = v2
    if nIdx >= 0 then
        poly->v(3) = this.getNormal(nIdx): poly->idx(3) = nIdx
    end if
    this._polyCount += 1
    return @this
end function
function Mesh.addCube(x as double, y as double, z as double, xSize as double=1.0, ySize as double=1.0, zSize as double=1.0) as Mesh ptr

    dim cube(12, 9) as integer => {_
        {0,0,0, 1,0,0, 1,1,0},_
        {0,0,0, 1,1,0, 0,1,0},_
        {1,1,1, 1,0,1, 0,0,1},_
        {0,1,1, 1,1,1, 0,0,1},_
                              _
        {0,0,1, 0,0,0, 0,1,0},_
        {0,0,1, 0,1,0, 0,1,1},_
        {1,1,0, 1,0,0, 1,0,1},_
        {1,1,1, 1,1,0, 1,0,1},_
                              _
        {0,0,1, 1,0,1, 1,0,0},_
        {0,0,1, 1,0,0, 0,0,0},_
        {1,1,0, 1,1,1, 0,1,1},_
        {0,1,0, 1,1,0, 0,1,1} _
    }
    
    dim xs as double
    dim ys as double
    dim zs as double
    xs = xSize
    ys = ySize
    zs = zSize
    'this._addPoint(x   , y   , z)
    'this._addPoint(x+xs, y   , z)
    'this._addPoint(x   , y+ys, z)
    'this._addPoint(x+xs, y+ys, z)
    'this._addPoint(x   , y   , z+zs)
    'this._addPoint(x+xs, y   , z+zs)
    'this._addPoint(x   , y+ys, z+zs)
    'this._addPoint(x+xs, y+ys, z+zs)
    
    dim i as integer
    dim xd as double, yd as double, zd as double
    dim u as Vector, v as Vector, w as Vector
    for i = 0 to 11
        xd = cube(i, 0): yd = cube(i, 1): zd = cube(i, 2)
        u.x = x+xd: u.y = y+yd: u.z = z+zd
        xd = cube(i, 3): yd = cube(i, 4): zd = cube(i, 5)
        v.x = x+xd: v.y = y+yd: v.z = z+zd
        xd = cube(i, 6): yd = cube(i, 7): zd = cube(i, 8)
        w.x = x+xd: w.y = y+yd: w.z = z+zd
        u.x *= xs: v.x *= xs: w.x *= xs
        u.y *= ys: v.y *= ys: w.y *= ys
        u.z *= zs: v.z *= zs: w.z *= zs
        this.addPoly(u, v, w)
    next i
    
    return @this

end function
function Mesh.translate(x as double, y as double, z as double) as Mesh ptr
    dim i as integer
    for i = 0 to this._vertexCount-1
        this._vertices(i).x += x
        this._vertices(i).y += y
        this._vertices(i).z += z
    next i
    'for i = 0 to this._normalCount-1
    '    this._normals(i).x += x
    '    this._normals(i).y += y
    '    this._normals(i).z += z
    'next i
    return @this
end function
function Mesh.rotateX(a as double) as Mesh ptr
    dim va as Vector
    dim y as double
    dim z as double
    dim i as integer
    dim v as Vector ptr
    va = vectorFromAngle(a)
    if a <> 0 then
        for i = 0 to this._vertexCount-1
            v = @this._vertices(i)
            y = v->y*va.x + v->z*-va.y
            z = v->y*va.y + v->z*va.x
            v->y = y
            v->z = z
        next i
        for i = 0 to this._normalCount-1
            v = @this._normals(i)
            y = v->y*va.x + v->z*-va.y
            z = v->y*va.y + v->z*va.x
            v->y = y
            v->z = z
        next i
    end if
    return @this
end function
function Mesh.rotateY(a as double) as Mesh ptr
    dim va as Vector
    dim x as double
    dim z as double
    dim i as integer
    dim v as Vector ptr
    va = vectorFromAngle(a)
    if a <> 0 then
        for i = 0 to this._vertexCount-1
            v = @this._vertices(i)
            x = v->x*va.x + v->z*-va.y
            z = v->x*va.y + v->z*va.x
            v->x = x
            v->z = z
        next i
        for i = 0 to this._normalCount-1
            v = @this._normals(i)
            x = v->x*va.x + v->z*-va.y
            z = v->x*va.y + v->z*va.x
            v->x = x
            v->z = z
        next i
    end if
    return @this
end function
function Mesh.rotateZ(a as double) as Mesh ptr
    dim va as Vector
    dim x as double
    dim y as double
    dim i as integer
    dim v as Vector ptr
    va = vectorFromAngle(a)
    if a <> 0 then
        for i = 0 to this._vertexCount-1
            v = @this._vertices(i)
            x = v->x*va.x + v->y*-va.y
            y = v->x*va.y + v->y*va.x
            v->x = x
            v->y = y
        next i
        for i = 0 to this._normalCount-1
            v = @this._normals(i)
            x = v->x*va.x + v->y*-va.y
            y = v->x*va.y + v->y*va.x
            v->x = x
            v->y = y
        next i
    end if
    return @this
end function
function Mesh.addVertexFast(v as Vector ptr) as Mesh ptr
    if v <> 0 then
        this._vertices(this._vertexCount) = *v
        this._vertexCount += 1
    end if
    return @this
end function
function Mesh.addNormalFast(v as Vector ptr) as Mesh ptr
    if v <> 0 then
        this._normals(this._normalCount) = *v
        this._normalCount += 1
    end if
    return @this
end function
function Mesh.addPolyFast(p as MeshPoly ptr) as Mesh ptr
    if p <> 0 then
        this._polys(this._polyCount).v(0) = @this._vertices(p->idx(0))
        this._polys(this._polyCount).v(1) = @this._vertices(p->idx(1))
        this._polys(this._polyCount).v(2) = @this._vertices(p->idx(2))
        this._polys(this._polyCount).v(3) = @this._normals(p->idx(3))
        this._polyCount += 1
    end if
    return @this
end function
function Mesh.copy(m as Mesh ptr) as Mesh ptr
    this._polyCount = 0
    this._normalCount = 0
    this._vertexCount = 0
    this._current = 0
    this._z = 0
    dim i as integer
    for i = 0 to m->getVertexCount()-1
        this.addVertexFast(m->getVertex(i))
    next i
    for i = 0 to m->getNormalCount()-1
        this.addNormalFast(m->getNormal(i))
    next i
    for i = 0 to m->getPolyCount()-1
        this.addPolyFast(m->getPoly(i))
    next i
    return @this
end function
function Mesh.getVertex(idx as integer) as Vector ptr
    if idx >= 0 and idx < this._vertexCount then
        return @this._vertices(idx)
    else
        return 0
    end if
end function
function Mesh.getNormal(idx as integer) as Vector ptr
    if idx >= 0 and idx < this._normalCount then
        return @this._normals(idx)
    else
        return 0
    end if
end function
function Mesh.getPoly(idx as integer) as MeshPoly ptr
    if idx >= 0 and idx < this._polyCount then
        return @this._polys(idx)
    else
        return 0
    end if
end function
function Mesh.getVertexCount() as integer
    return this._vertexCount
end function
function Mesh.getNormalCount() as integer
    return this._normalCount
end function
function Mesh.getPolyCount() as integer
    return this._polyCount
end function

function Vector3.translate(x as double, y as double, z as double) as Vector3 ptr
    this.v(0).x += x: this.v(0).y += y: this.v(0).z += z
    this.v(1).x += x: this.v(1).y += y: this.v(1).z += z
    this.v(2).x += x: this.v(2).y += y: this.v(2).z += z
    'this.v(3).x += x: this.v(3).y += y: this.v(3).z += z
    return @this
end function
function Vector3.rotateX(a as double) as Vector3 ptr
     if a <> 0 then
        this.v(0) = vectorRotateX(this.v(0), a)
        this.v(1) = vectorRotateX(this.v(1), a)
        this.v(2) = vectorRotateX(this.v(2), a)
        this.v(3) = vectorRotateX(this.v(3), a)
    end if
    return @this
end function
function Vector3.rotateY(a as double) as Vector3 ptr
    if a <> 0 then
        this.v(0) = vectorRotateY(this.v(0), a)
        this.v(1) = vectorRotateY(this.v(1), a)
        this.v(2) = vectorRotateY(this.v(2), a)
        this.v(3) = vectorRotateY(this.v(3), a)
    end if
    return @this
end function
function Vector3.rotateZ(a as double) as Vector3 ptr
    if a <> 0 then
        this.v(0) = vectorRotateZ(this.v(0), a)
        this.v(1) = vectorRotateZ(this.v(1), a)
        this.v(2) = vectorRotateZ(this.v(2), a)
        this.v(3) = vectorRotateZ(this.v(3), a)
    end if
    return @this
end function
function Vector3.make2d(screenX as integer, screenY as integer, scale as double=1.0) as Vector3 ptr
    dim v3 as Vector3
    dim halfx as integer, halfy as integer
    halfx = screenX shr 1
    halfy = screenY shr 1
    if this.v(0).z <= 0.0001 then this.v(0).z = 0.0001
    if this.v(1).z <= 0.0001 then this.v(1).z = 0.0001
    if this.v(2).z <= 0.0001 then this.v(2).z = 0.0001
    this.v(0).x = ( this.v(0).x*scale ) / this.v(0).z + halfx
    this.v(0).y = (-this.v(0).y*scale ) / this.v(0).z + halfy
    this.v(0).z = 0
    this.v(1).x = ( this.v(1).x*scale ) / this.v(1).z + halfx
    this.v(1).y = (-this.v(1).y*scale ) / this.v(1).z + halfy
    this.v(1).z = 0
    this.v(2).x = ( this.v(2).x*scale ) / this.v(2).z + halfx
    this.v(2).y = (-this.v(2).y*scale ) / this.v(2).z + halfy
    this.v(2).z = 0
    return @this
end function
function MeshPoly.copy() as Vector3
    dim v as Vector3
    v.v(0).x = *this.v(0).x: v.v(0).y = *this.v(0).y: v.v(0).z = *this.v(0).z
    v.v(1).x = *this.v(1).x: v.v(1).y = *this.v(1).y: v.v(1).z = *this.v(1).z
    v.v(2).x = *this.v(2).x: v.v(2).y = *this.v(2).y: v.v(2).z = *this.v(2).z
    v.v(3).x = *this.v(3).x: v.v(3).y = *this.v(3).y: v.v(3).z = *this.v(3).z
    return v
end function

'MeshCube:
'data 0,0,0, 1,0,0, 1,1,0
'data 0,0,0, 0,1,0, 1,1,0
'data 0,0,1, 1,0,1, 1,1,1
'data 0,0,1, 0,1,1, 1,1,1
'
'data 0,0,0, 0,0,1, 1,0,1
'data 0,0,0, 1,0,0, 1,0,1
'data 0,1,0, 0,1,1, 1,1,1
'data 0,1,0, 1,1,0, 1,1,1
'
'data 0,0,0, 0,1,0, 0,1,1
'data 0,0,0, 0,0,1, 0,1,1
'data 1,0,0, 1,1,0, 1,1,1
'data 1,0,0, 1,0,1, 1,1,1
