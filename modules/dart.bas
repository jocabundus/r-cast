#include once "modules/inc/dart.bi"

property Dart.way() as Vector
	'return this._way
	return Vector(this._vx, this._vy)
end property
property Dart.way(new_way as Vector)
	'this._way = new_way
	this._vx = new_way.x
	this._vy = new_way.y
end property
property Dart.position() as Vector
	'return this._position
	return Vector(this._x, this._y)
end property
property Dart.position(new_position as Vector)
	'this._position = new_position
	this._x = new_position.x
	this._y = new_position.y
end property
property Dart.speed() as double
	return this._speed
end property
property Dart.speed(new_speed as double)
	this._speed = new_speed
end property

function Dart.getIndexId() as integer
	return this._index_id
end function
function Dart.setIndexId(id as integer) as Dart ptr
	this._index_id = id
	return @this
end function
function Dart.getIncrementId() as integer
	return this._increment_id
end function
function Dart.setIncrementId(id as integer) as Dart ptr
	this._increment_id = id
	return @this
end function
function Dart.getOwnerId() as integer
	return this._owner_id
end function
function Dart.setOwnerId(owner_id as integer) as Dart ptr
	this._owner_id = owner_id
	return @this
end function
function Dart.getX() as double
	return this._x
end function
function Dart.setX(x as double) as Dart ptr
	this._x = x
	return @this
end function
function Dart.getY() as double
	return this._y
end function
function Dart.setY(y as double) as Dart ptr
	this._y = y
	return @this
end function
function Dart.getZ() as double
	return this._z
end function
function Dart.setZ(z as double) as Dart ptr
	this._z = z
	return @this
end function
function Dart.setXYZ(x as double, y as double, z as double) as Dart ptr
	this._x = x
	this._y = y
	this._z = z
	return @this
end function
function Dart.getVx() as double
	return this._vx
end function
function Dart.setVx(vx as double) as Dart ptr
	this._vx = vx
	return @this
end function
function Dart.getVy() as double
	return this._vy
end function
function Dart.setVy(vy as double) as Dart ptr
	this._vy = vy
	return @this
end function
function Dart.getVz() as double
	return this._vz
end function
function Dart.setVz(vz as double) as Dart ptr
	this._vz = vz
	return @this
end function
function Dart.setVxVyVz(vx as double, vy as double, vz as double) as Dart ptr
	this._vx = vx
	this._vy = vy
	this._vz = vz
	return @this
end function
function Dart.getStartX() as double
	return this._startX
end function
function Dart.setStartX(x as double) as Dart ptr
	this._startX = x
	return @this
end function
function Dart.getStartY() as double
	return this._startY
end function
function Dart.setStartY(y as double) as Dart ptr
	this._startX = y
	return @this
end function
function Dart.getStartZ() as double
	return this._startZ
end function
function Dart.setStartZ(z as double) as Dart ptr
	this._startZ = z
	return @this
end function
function Dart.setStartXYZ(x as double, y as double, z as double) as Dart ptr
	this._startX = x
	this._startY = y
	this._startZ = z
	return @this
end function
function Dart.getAngleX() as double
	return this._angleX
end function
function Dart.getAngleY() as double
	return this._angleY
end function
function Dart.getAngleZ() as double
	return this._angleZ
end function
function Dart.setAngleX(ang as double) as Dart ptr
	this._angleX = ang
	return @this
end function
function Dart.setAngleY(ang as double) as Dart ptr
	this._angleY = ang
	return @this
end function
function Dart.setAngleZ(ang as double) as Dart ptr
	this._angleZ = ang
	return @this
end function
function Dart.hasClip() as integer
	return (this._clipVx <> 0 or this._clipVy <> 0 or this._clipVz <> 0)
end function
function Dart.clearClip() as Dart ptr
	this._clipVx = 0
	this._clipVy = 0
	this._clipVz = 0
	this._clipStepX = 0
	this._clipStepY = 0
	this._clipStepZ = 0
	return @this
end function
function Dart.getSpeed() as double
	return this._speed
end function
function Dart.setSpeed(dart_speed as double) as Dart ptr
	this._speed = dart_speed
	return @this
end function
function Dart.getCount() as double
	return this._count
end function
function Dart.setCount(count as double) as Dart ptr
	this._count = count
	return @this
end function
function Dart.setMoveCallback(p as sub(d as Dart ptr, t as double)) as Dart ptr
	this._move_callback = p
	return @this
end function
function Dart.move(t as double) as Dart ptr
	if this._move_callback <> 0 then
		this._move_callback(@this, t)
	else
		this.moveUnit(t)
	end if
	return @this
end function
sub Dart.moveSimple(t as double)

	this._x += this._vx*this._speed*t
	this._y += this._vy*this._speed*t
	this._z += this._vz*this._speed*t

end sub
'// when precision doesn't matter
'// move with minimal processing
sub Dart.moveFast(t as double)

	'this._ix += this._ivx*t
	'this._iy += this._ivy*t
	'this._iz += this._ivz*t

end sub
'// move dart in any direction one unit at a time
'// some corners might be missed
sub Dart.moveUnit(t as double)

	'// assumed that vx/vy/vz is a unit vector

	if this._clipVx = 0 then
		this._clipVx = this._speed*t
	end if
	
	if this._clipVx > 1 then
		this._clipVx -= 1
		this._x += this._vx
		this._y += this._vy
		this._z += this._vz
	elseif this._clipVx <= 1 then
		this._x += this._vx*this._clipVx
		this._y += this._vy*this._clipVx
		this._z += this._vz*this._clipVx
		this._clipVx = 0
	end if

end sub
'// move dart along one axis, don't skip any squares
sub Dart.moveOrthogonal(t as double)
	dim dx as double, dy as double, dz as double
	dim x as double, y as double, z as double
	if this.hasClip() then
		if abs(this._clipVx) > 0 then
			if abs(this._clipVx) > abs(this._clipStepX) then
				dx = this._clipStepX
				this._clipVx -= this._clipStepX
			else
				dx = this._clipVx
				this._clipVx = 0
			end if
		elseif abs(this._clipVy) > 0 then
			if abs(this._clipVy) > abs(this._clipStepY) then
				dy = this._clipStepY
				this._clipVy -= this._clipStepY
			else
				dy = this._clipVy
				this._clipVy = 0
			end if
		elseif abs(this._clipVz) > 0 then
			if abs(this._clipVz) > abs(this._clipStepZ) then
				dz = this._clipStepZ
				this._clipVz -= this._clipStepZ
			else
				dz = this._clipVz
				this._clipVz = 0
			end if
		end if
	else
		dx = this._vx*this._speed*t
		dy = this._vy*this._speed*t
		dz = this._vz*this._speed*t
		if abs(dx) > 1 then
			x = dx / (int(abs(dx))+1)
			this._clipVx = dx - x
			this._clipStepX = x
			dx = x
		elseif abs(dy) > 1 then
			y = dy / (int(abs(dy))+1)
			this._clipVy = dy - y
			dy = y
			this._clipStepY = y
		elseif abs(dz) > 1 then
			z = dz / (int(abs(dz))+1)
			this._clipVz = dz - z
			dz = z
			this._clipStepZ = z
		end if
	end if
	this._x += dx
	this._y += dy
	this._z += dz
end sub
'// move dart along any axes, don't miss any squares
sub Dart.movePerfect(t as double)
end sub
function Dart.setCollideCallback(p as function(d as Dart ptr, extra as any ptr) as integer) as Dart ptr
	this._collide_callback = p
	return @this
end function
function Dart.collide(extra as any ptr = 0) as integer
	if this._collide_callback <> 0 then
		return this._collide_callback(@this, extra)
	else
		return 0
	end if
end function
function Dart.setBeforeDelete(p as sub(d as Dart ptr)) as Dart ptr
	this._before_delete = p
	return @this
end function
function Dart.callBeforeDelete() as Dart ptr
	if this._before_delete <> 0 then
		this._before_delete(@this)
	end if
	return @this
end function
function Dart.getExpires() as integer
	return this._expires
end function
function Dart.setExpires(expires as integer) as Dart ptr
	this._expires = expires
	return @this
end function
function Dart.getExpiresInSeconds() as double
	return this._expires_in_seconds
end function
function Dart.setExpiresInSeconds(seconds as double) as Dart ptr
	this._expires_in_seconds = seconds
	return @this
end function
function Dart.getDamage() as double
	return this._damage
end function
function Dart.setDamage(damage as double) as Dart ptr
	this._damage = damage
	return @this
end function
function Dart.getDamageType() as integer
	return this._damage_type
end function
function Dart.setDamageType(damage_type as integer) as Dart ptr
	this._damage_type = damage_type
	return @this
end function
function Dart.getFrames() as integer
	return this._frames
end function
function Dart.setFrames(frames as integer) as Dart ptr
	this._frames = frames
	return @this
end function
function Dart.getFrameStart() as integer
	return this._frame_start
end function
function Dart.setFrameStart(frame_start as integer) as Dart ptr
	this._frame_start = frame_start
	return @this
end function
function Dart.getFrameSpeed() as double
	return this._frame_speed
end function
function Dart.setFrameSpeed(frame_speed as double) as Dart ptr
	this._frame_speed = frame_speed
	return @this
end function
function Dart.expire() as Dart ptr
	this._expires = 1
	this._count = this._frames
	return @this
end function
function Dart.expireSeconds(seconds as double) as integer
	this._expires_in_seconds -= seconds
	if this._expires_in_seconds <= 0 then
		this._expires_in_seconds = 0
		return 1
	end if
	return 0
end function
function Dart.setFlag(flag as integer) as Dart ptr
	this._flags = (this._flags or flag)
	return @this
end function
function Dart.hasFlag(flag as integer) as integer
	return iif((this._flags and flag) > 0, 1, 0)
end function
function Dart.clearFlag(flag as integer) as Dart ptr
	this._flags = (this._flags or flag) xor flag
	return @this
end function
function Dart.clearAllFlags() as Dart ptr
	this._flags = 0
	return @this
end function
function Dart.setCheckBounds(do_check as boolean) as Dart ptr
	this._check_bounds = do_check
	return @this
end function
function Dart.checkBounds() as boolean
	return this._check_bounds
end function
function Dart.setRenderCallback(p as sub(d as Dart ptr)) as Dart ptr
    this._render_callback = p
    return @this
end function
function Dart.render() as Dart ptr
	if this._render_callback <> 0 then
		this._render_callback(@this)
	end if
	return @this
end function