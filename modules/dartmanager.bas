#include once "modules/inc/dartmanager.bi"

constructor DartManager()
    dim i as integer
    this._firstidx = -1
    this._lastidx = -1
end constructor

function DartManager.setBounds(x0 as integer, y0 as integer, z0 as integer, x1 as integer, y1 as integer, z1 as integer) as DartManager ptr

    this._x0 = x0
    this._y0 = y0
    this._z0 = z0
    this._x1 = x1
    this._y1 = y1
    this._z1 = z1
    
    return @this

end function

function DartManager.setRenderCallback(p as sub(d as Dart ptr)) as DartManager ptr

    this._render_callback = p
    return @this
    
end function

function DartManager.fire(start as Vector, forward as Vector, speed as double, frame_start as integer) as Dart ptr

    dim i as integer
    dim idx as integer = -1
    for i = 0 to 255
	if this._idx(i) = 0 then
	    this._idx(i) = 1
	    idx = i
	    exit for
	end if
    next i
    
    if idx = -1 then return @this._dummydart
    if this._firstidx = -1 then
	    this._firstidx = idx
    end if
    if this._lastidx >= 0 then
	    this._nextidx(this._lastidx) = idx
    end if
    this._nextidx(idx) = -1
    this._lastidx = idx
    
    dim d as Dart ptr
    d = @this._darts(idx)
    
    dim vx as double
    dim vy as double
    dim vz as double
    
    vx = forward.x
    vy = forward.y
    vz = forward.z
    
    d->setStartXYZ(start.x, start.y, start.z)
    d->setIndexId(idx)
    d->setOwnerId(0)
    d->setVx(vx)
    d->setVy(vy)
    d->setVz(vz)
    d->setSpeed(speed)
    d->setX(start.x+vx*0.5)
    d->setY(start.y+vy*0.5)
    d->setZ(start.z+vz*0.5)
    d->setCount(0)
    d->setExpires(0)
    d->setExpiresInSeconds(0)
    d->setDamage(1)
    d->setDamageType(0)
    d->setMoveCallback(0)
    d->setCollideCallback(this._collide_callback)
    d->setBeforeDelete(0)
    d->setFrames(4)
    d->setFrameStart(frame_start)
    d->setFrameSpeed(7.5)
    d->clearAllFlags()
    d->clearClip()
    d->setRenderCallback(this._render_callback)
    
    static increment_id as integer = 0
    increment_id += 1
    d->setIncrementId(increment_id)
    
    return d
    
end function

function DartManager.cycle(speed as double = 1) as DartManager ptr

    dim n as integer, i as integer
    dim x as double, y as double, z as double
    
    dim deleteDart as integer
    dim clipped as integer
    
    dim d as Dart ptr
    dim num_darts as integer
    dim prev as integer
    
    dim tocall(256) as Dart
    dim numtocall as integer = 0
    
    i = this._firstidx
    prev = this._firstidx
    while i > -1
    
	d = @this._darts(i)
	this._current = d
	
	do
	    d->move(speed)
	    
	    clipped = d->hasClip()
	    
	    if clipped = 0 then
		d->setCount(d->getCount()+speed*d->getFrameSpeed()) '- if d->hasClip() = 0 then
		if d->getExpiresInSeconds() then
		    if d->expireSeconds(speed) then
			deleteDart = 1
		    end if
		end if
		if d->getCount() >= d->getFrames() then
		    if d->getExpires() then
			deleteDart = 1
		    else
			d->setCount(d->getCount()-d->getFrames())
		    end if
		end if
	    end if
	    
	    x = d->getX(): y = d->getY(): z = d->getZ()
	    
	    if (x < this._x0 or y < this._y0 or z < this._z0) or (x > this._x1 or y > this._y1 or z > this._z1) then
		deleteDart = 1
	    else
		if d->collide() then
		    deleteDart = 1
		end if
	    end if
	    
	    if deleteDart then
		tocall(numtocall) = *d
		numtocall += 1
		this._idx(i) = 0
		if i = this._firstidx then
		    if i = this._lastidx then
			this._lastidx = -1
			this._firstidx = -1
			i = -1
		    else
			i = this._nextidx(i)
			this._firstidx = i
			prev = i
		    end if
		elseif i = this._lastidx then
		    this._lastidx = prev
		    this._nextidx(prev) = -1
		    i = -1
		else
		    i = this._nextidx(i)
		    this._nextidx(prev) = i
		end if
		deleteDart = 0
		clipped = 0
	    elseif clipped = 0 then
		d->render()
		prev = i
		i = this._nextidx(i)
	    else
		d->render()
	    end if
		
	loop while clipped
        
    wend
    
    for i = 0 to numtocall-1
	this._current = @tocall(i)
	tocall(i).callBeforeDelete()
    next i
    
    this._current = 0
    
    return @this
	
end function

function DartManager.getCurrent() as Dart ptr
    return this._current
end function

function DartManager.setDefaultCollideCallback(p as function(x as double, y as double, z as double) as integer) as DartManager ptr
    this._collide_callback = p
    return @this
end function

function DartManager.clearDarts() as DartManager ptr
    dim i as integer
    for i = 0 to 255
	this._idx(i) = 0
    next i
    this._lastidx = -1
    this._firstidx = -1
    return @this
end function
