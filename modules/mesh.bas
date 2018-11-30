#include once "inc/mesh.bi"

constructor MeshTriangle
    this._count = 0
end constructor
function MeshTriangle.points(idx as integer) as Vector ptr
    if idx >= 0 and idx < 3 then
        return @this._points(idx)
    else
        return 0
    end if
end function
function MeshTriangle.addPoint(x as double, y as double, z as double) as MeshTriangle ptr
    dim i as integer
    if i < 3 then
        i = this._count
        this._points(i).x = x
        this._points(i).y = y
        this._points(i).z = z
        this._count += 1
    end if
    return @this
end function

constructor Mesh()
    this._count = 0
    this._current = 0
end constructor
function Mesh.startOver() as Mesh ptr
    this._current = 0
    return @this
end function
function Mesh.getNext() as MeshTriangle ptr
    dim c as integer
    if this._current < this._count then
        c = this._current
        this._current += 1
        return @this._polys(c)
    else
        return 0
    end if
end function
function Mesh.addCube(x as integer, y as integer, z as integer) as Mesh ptr

    dim polys(12) as MeshTriangle
    dim c as integer
    
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

'data 1,2,4, 1,2,3
'data 5,6,8, 5,6,7
'data 5,1,3, 5,3,7
'data 6,2,4, 6,4,8
'data 5,6,2, 5,2,1

/'    if this._count <= 132 then
        c = this._count
        this._addPoint(x+0, y+0, z+0)
        this._addPoint(x+1, y+0, z+0)
        this._addPoint(x+0, y+1, z+0)
        this._addPoint(x+1, y+1, z+0)
        this._addPoint(x+0, y+0, z+1)
        this._addPoint(x+1, y+0, z+1)
        this._addPoint(x+0, y+1, z+1)
        this._addPoint(x+1, y+1, z+1)
        
        polys(c+0).addPoint(x+0, y+0, z+0)
        polys(c+0).addPoint(x+1, y+0, z+0)
        polys(c+0).addPoint(x+1, y+1, z+0)
        polys(c+1).addPoint(x+0, y+0, z+0)
        polys(c+1).addPoint(x+0, y+1, z+0)
        polys(c+1).addPoint(x+1, y+1, z+0)
        polys(c+2).addPoint(x+0, y+0, z+1)
        polys(c+2).addPoint(x+1, y+0, z+1)
        polys(c+2).addPoint(x+1, y+1, z+1)
        polys(c+3).addPoint(x+0, y+0, z+1)
        polys(c+3).addPoint(x+0, y+0, z+1)
        polys(c+3).addPoint(x+1, y+1, z+1)
        
        polys(c+4).addPoint(x+0, y+0, z+0)
        polys(c+4).addPoint(x+0, y+0, z+1)
        polys(c+4).addPoint(x+1, y+0, z+1)
        polys(c+5).addPoint(x+0, y+0, z+0)
        polys(c+5).addPoint(x+1, y+0, z+0)
        polys(c+5).addPoint(x+1, y+0, z+1)
        polys(c+6).addPoint(x+0, y+1, z+0)
        polys(c+6).addPoint(x+0, y+1, z+1)
        polys(c+6).addPoint(x+1, y+1, z+1)
        polys(c+7).addPoint(x+0, y+1, z+0)
        polys(c+7).addPoint(x+1, y+1, z+0)
        polys(c+7).addPoint(x+1, y+1, z+1)

        polys(c+8).addPoint(x+0, y+0, z+0)
        polys(c+8).addPoint(x+0, y+1, z+0)
        polys(c+8).addPoint(x+0, y+1, z+1)
        polys(c+9).addPoint(x+0, y+0, z+0)
        polys(c+9).addPoint(x+0, y+0, z+1)
        polys(c+9).addPoint(x+0, y+1, z+1)
        polys(c+10).addPoint(x+1, y+0, z+0)
        polys(c+10).addPoint(x+1, y+1, z+0)
        polys(c+10).addPoint(x+1, y+1, z+1)
        polys(c+11).addPoint(x+1, y+0, z+0)
        polys(c+11).addPoint(x+1, y+0, z+1)
        polys(c+11).addPoint(x+1, y+1, z+1)
        
        this._count += 12
    end if
   '/ 
    return @this

end function
