#include once "modules/inc/mob.bi"
#include once "modules/inc/vector.bi"

constructor Mob
	'this.truncate()
end constructor

function Mob.truncate() as Mob ptr

	this._index_id     = 0
	this._increment_id = 0
	this._custom_id    = 0
	this._state        = 0
	this._state_before = 0
	this._state_after  = 0
	this._spawn_x      = 0
	this._spawn_y      = 0
	this._vx           = 0
	this._vy           = 0
	this._ang          = 0
	this._hp	       = 0
	this._max_hp       = Mob.DEFAULT_MAX_ITEM_QTY
	this._flags        = 0
	this._on_hit       = 0
	this._switched_state = 0
	this._is_locked      = 0
		
	this._position.x = 0
	this._position.y = 0
	
	dim i as integer
	for i = 0 to 3
		this._counters(i) = 0
	next i
	for i = 0 to 255
		this._inventory(i) = 0
		this._max_qty(i) = Mob.DEFAULT_MAX_ITEM_QTY
	next i
	
	return @this
end function

property Mob.position() as Vector
	return this._position
end property
property Mob.position(new_position as Vector)
	this._position = new_position
end property

function Mob.getId() as integer
	return this._custom_id
end function
function Mob.setId(id as integer) as Mob ptr
	this._custom_id = id
	return @this
end function
function Mob.getIndexId() as integer
	return this._index_id
end function
function Mob.setIndexId(id as integer) as Mob ptr
	this._index_id = id
	return @this
end function
function Mob.getIncrementId() as integer
	return this._increment_id
end function
function Mob.setIncrementId(id as integer) as Mob ptr
	this._increment_id = id
	return @this
end function
function Mob.getState() as sub(e as Mob ptr, d as double)
	return this._state
end function
function Mob.setState(state as sub(e as Mob ptr, d as double)) as Mob ptr
	if this._is_locked = 0 then
		if this._state <> state then
			this._switched_state = 1
		end if
		this._state = state
	end if
	return @this
end function
function Mob.switchedState() as integer
	dim switched as integer = this._switched_state
	this._switched_state = 0
	return switched
end function
function Mob.initState() as integer
	return this.switchedState()
end function
function Mob.lock() as Mob ptr
	this._is_locked = 1
	return @this
end function
function Mob.unlock() as Mob ptr
	this._is_locked = 0
	return @this
end function
function Mob.getX() as double
	dim x as double = this._position.x
	return (int(x) and 127) + (x-int(x))
end function
function Mob.setX(x as double) as Mob ptr
	this._position.x = x
	return @this
end function
function Mob.getY() as double
	dim y as double = this._position.y
	return (int(y) and 127) + (y-int(y))
end function
function Mob.setY(y as double) as Mob ptr
	this._position.y = y
	return @this
end function
function Mob.setXY(x as double, y as double) as Mob ptr
	this._position.x = x
	this._position.y = y
	return @this
end function
function Mob.addXY(x as double, y as double) as Mob ptr
	this._position.x = (this._position.x + x)
	this._position.y = (this._position.y + y)
	return @this
end function

function Mob.getVx() as double
	return this._vx
end function
function Mob.setVx(vx as double) as Mob ptr
	this._vx = vx
	return @this
end function
function Mob.getVy() as double
	return this._vy
end function
function Mob.setVy(vy as double) as Mob ptr
	this._vy = vy
	return @this
end function
function Mob.setVxVy(vx as double, vy as double) as Mob ptr
	this._vx = vx
	this._vy = vy
	return @this
end function
function Mob.addVxVy(vx as double, vy as double) as Mob ptr
	this._vx += vx
	this._vy += vy
	return @this
end function

function Mob.getSpawnX() as double
	return this._spawn_x
end function
function Mob.setSpawnX(x as double) as Mob ptr
	this._spawn_x = x
	return @this
end function
function Mob.getSpawnY() as double
	return this._spawn_y
end function
function Mob.setSpawnY(y as double) as Mob ptr
	this._spawn_y = y
	return @this
end function
function Mob.setSpawnXY(x as double, y as double) as Mob ptr
	this._spawn_x = x
	this._spawn_y = y
	return @this
end function

function Mob.getTop() as double
	return this._position.y+this._top
end function
function Mob.getLft() as double
	return this._position.x+this._lft
end function
function Mob.getBtm() as double
	return this._position.y+this._btm
end function
function Mob.getRgt() as double
	return this._position.x+this._rgt
end function
function Mob.getWidth() as double
	return abs(this._rgt-this._lft)
end function
function Mob.getHeight() as double
	return abs(this._btm-this._top)
end function
function Mob.getBoxTop() as double
	return this._top
end function
function Mob.getBoxLft() as double
	return this._lft
end function
function Mob.getBoxBtm() as double
	return this._btm
end function
function Mob.getBoxRgt() as double
	return this._rgt
end function
function Mob.setBounds(top as double, lft as double, btm as double, rgt as double) as Mob ptr
	this._top = top
	this._lft = lft
	this._btm = btm
	this._rgt = rgt
	return @this
end function

function Mob.getAngle() as double
	return this._ang
end function
function Mob.setAngle(ang as double) as Mob ptr
	this._ang = ang
	return @this
end function
function Mob.getHp() as double
	return this._hp
end function
function Mob.setHp(hp as double) as Mob ptr
	if hp < 0 then hp = 0
	if hp > this._max_hp then hp = this._max_hp
	this._hp = hp
	return @this
end function
function Mob.addHp(hp as double) as Mob ptr
	if (this._hp+hp) > this._max_hp then
		this.setHp(this._max_hp)
	else
		this.setHp(this._hp+hp)
	end if
	return @this
end function
function Mob.subHp(hp as double) as Mob ptr
	if (this._hp-hp) < 0 then
		this.setHp(0)
	else
		this.setHp(this._hp-hp)
	end if
	return @this
end function
function Mob.getMaxHp() as double
	return this._max_hp
end function
function Mob.setMaxHp(max_hp as double) as Mob ptr
	this._max_hp = max_hp
	return @this
end function

function Mob.addItem(id as integer, qty as integer = 1) as Mob ptr
	return this.setItemQty(id, qty)
end function
function Mob.removeItem(id as integer) as Mob ptr
	this._inventory(id) = 0
	return @this
end function
function Mob.hasItem(id as integer) as integer
	return iif(this._inventory(id) > 0, 1, 0)
end function
function Mob.lacksItem(id as integer) as integer
	return iif(this._inventory(id) = 0, 1, 0)
end function
function Mob.setItemQty(id as integer, qty as integer) as Mob ptr
	if qty < this._max_qty(id) then
		this._inventory(id) = qty
	else
		this._inventory(id) = this._max_qty(id)
	end if
	return @this
end function
function Mob.addItemQty(id as integer, qty as integer) as Mob ptr
	this._inventory(id) += qty
	if this._inventory(id) < 0 then this._inventory(id) = 0
	if this._inventory(id) > this._max_qty(id) then
		this._inventory(id) = this._max_qty(id)
	end if
	return @this
end function
function Mob.getItemQty(id as integer) as integer
	return this._inventory(id)
end function
function Mob.setMaxItemQty(id as integer, max_qty as integer) as Mob ptr
	this._max_qty(id) = max_qty
	return @this
end function
function Mob.getMaxItemQty(id as integer) as integer
	return this._max_qty(id)
end function

function Mob.getCounter(id as integer) as double
	return this._counters(id)
end function

function Mob.setCounter(id as integer, count as double) as Mob ptr
	this._counters(id) = count
	return @this
end function

function Mob.addCounter(id as integer, amount as double) as Mob ptr
	this._counters(id) += amount
	return @this
end function

function Mob.registerHit(callback as sub(e as Mob ptr, damage as double, damage_type as integer = 0)) as Mob ptr
	this._on_hit = callback
	return @this
end function

function Mob.unregisterHit() as Mob ptr
	this._on_hit = 0
	return @this
end function

function Mob.callHit(damage as double=1.0) as Mob ptr
	if this._on_hit then
		this._on_hit(@this, damage)
	end if
	return @this
end function

function Mob.callState(d as double=1.0) as Mob ptr
	if this._state then
		if this._state_before then
			this._state_before(@this, d)
		end if
		this._state(@this, d)
		if this._state_after then
			this._state_after(@this, d)
		end if
	end if
	return @this
end function

function Mob.registerBefore(state_before as sub(e as Mob ptr, d as double)) as Mob ptr
	this._state_before = state_before
	return @this
end function

function Mob.registerAfter(state_after as sub(e as Mob ptr, d as double)) as Mob ptr
	this._state_after = state_after
	return @this
end function

function Mob.registerCollision(collision_callback as function(e as Mob ptr, x as double, y as double) as integer) as Mob ptr
	this._collision_callback = collision_callback
	return @this
end function

function Mob.collidesWithPoint(x as double, y as double) as integer
	if this._collision_callback then
		return this._collision_callback(@this, x, y)
	end if
	return 0
end function

function Mob.registerAwake(callback as sub(e as Mob ptr, d as double)) as Mob ptr
	this._awake_callback = callback
	return @this
end function

function Mob.registerSleep(callback as sub(e as Mob ptr, d as double)) as Mob ptr
	this._sleep_callback = callback
	return @this
end function

function Mob.awake() as Mob ptr
	this.setState( this._awake_callback )
	return @this
end function

function Mob.sleep() as Mob ptr
	this.setState( this._sleep_callback )
	return @this
end function

function Mob.setInAwakeRange(callback as function(e as Mob ptr) as integer) as Mob ptr
	this._in_awake_range = callback
	return @this
end function

function Mob.setInActiveRange(callback as function(e as Mob ptr) as integer) as Mob ptr
	this._in_active_range = callback
	return @this
end function

function Mob.inAwakeRange() as integer
	return this._in_awake_range( @this )
end function

function Mob.notInActiveRange() as integer
	return (this._in_active_range( @this ) = 0)
end function

function Mob.getFlagsMask() as integer
	return this._flags
end function

function Mob.setFlagsMask(flags as integer) as Mob ptr
	this._flags = flags
	return @this
end function

function Mob.setFlag(flag as integer) as Mob ptr
	this._flags = (this._flags or flag)
	return @this
end function

function Mob.hasFlag(flag as integer) as integer
	return iif((this._flags and flag) > 0, 1, 0)
end function

function Mob.notFlag(flag as integer) as integer
	return iif((this._flags and flag) > 0, 0, 1)
end function

function Mob.clearFlag(flag as integer) as Mob ptr
	this._flags = (this._flags or flag) xor flag
	return @this
end function

function Mob.clearAllFlags() as Mob ptr
	this._flags = 0
	return @this
end function
