#pragma once
#inclib "mob"

#include once "modules/inc/vector.bi"

type Mob
private:
	_index_id as integer
	_increment_id as integer
	_custom_id as integer
	_state as sub(e as Mob ptr, d as double)
	_state_before as sub(e as Mob ptr, d as double)
	_state_after as sub(e as Mob ptr, d as double)
	_spawn_x as double
	_spawn_y as double
	_vx as double
	_vy as double
	_ang as double
	_hp as double
	_max_hp as double
	_top as double
	_lft as double
	_btm as double
	_rgt as double
	
	const DEFAULT_MAX_ITEM_QTY as integer = &h7fffffff
	
	_position as Vector
	
	_inventory(255) as integer
	_max_qty(255) as integer
	_counters(3) as double
	_flags as integer
	
	_on_hit as sub(e as Mob ptr, damage as double, damage_type as integer = 0)
	_collision_callback as function(e as Mob ptr, x as double, y as double) as integer
	_awake_callback as sub(e as Mob ptr, d as double)
	_sleep_callback as sub(e as Mob ptr, d as double)
	_in_awake_range as function(e as Mob ptr) as integer
	_in_active_range as function(e as Mob ptr) as integer
	_switched_state as integer
	
	_is_locked as integer

public:

	declare constructor()
	
	declare function truncate() as Mob ptr
	
	declare property position() as Vector
	declare property position(new_position as Vector)
	
	declare function getId() as integer
	declare function setId(id as integer) as Mob ptr
	declare function getIndexId() as integer
	declare function setIndexId(id as integer) as Mob ptr
	declare function getIncrementId() as integer
	declare function setIncrementId(id as integer) as Mob ptr
	declare function getState() as sub(e as Mob ptr, d as double)
	declare function setState(state as sub(e as Mob ptr, d as double)) as Mob ptr
	declare function switchedState() as integer
	declare function initState() as integer
	declare function lock() as Mob ptr
	declare function unlock() as Mob ptr
	
	declare function getX() as double
	declare function setX(x as double) as Mob ptr
	declare function getY() as double
	declare function setY(y as double) as Mob ptr
	declare function setXY(x as double, y as double) as Mob ptr
	declare function addXY(x as double, y as double) as Mob ptr
	
	declare function getVx() as double
	declare function setVx(vx as double) as Mob ptr
	declare function getVy() as double
	declare function setVy(vy as double) as Mob ptr
	declare function setVxVy(vx as double, vy as double) as Mob ptr
	declare function addVxVy(vx as double, vy as double) as Mob ptr
	
	declare function getSpawnX() as double
	declare function setSpawnX(x as double) as Mob ptr
	declare function getSpawnY() as double
	declare function setSpawnY(y as double) as Mob ptr
	declare function setSpawnXY(x as double, y as double) as Mob ptr
	
	declare function getTop() as double
	declare function getLft() as double
	declare function getBtm() as double
	declare function getRgt() as double
	declare function getWidth() as double
	declare function getHeight() as double
	declare function getBoxTop() as double
	declare function getBoxLft() as double
	declare function getBoxBtm() as double
	declare function getBoxRgt() as double
	declare function setBounds(top as double, lft as double, btm as double, rgt as double) as Mob ptr
	
	declare function getAngle() as double
	declare function setAngle(ang as double) as Mob ptr
	
	declare function getHp() as double
	declare function setHp(hp as double) as Mob ptr
	declare function addHp(hp as double) as Mob ptr
	declare function subHp(hp as double) as Mob ptr
	declare function getMaxHp() as double
	declare function setMaxHp(max_hp as double) as Mob ptr
	
	declare function addItem(id as integer, qty as integer = 1) as Mob ptr
	declare function removeItem(id as integer) as Mob ptr
	declare function hasItem(id as integer) as integer
	declare function lacksItem(id as integer) as integer
	declare function setItemQty(id as integer, qty as integer) as Mob ptr
	declare function addItemQty(id as integer, qty as integer) as Mob ptr
	declare function getItemQty(id as integer) as integer
	declare function setMaxItemQty(id as integer, max_qty as integer) as Mob ptr
	declare function getMaxItemQty(id as integer) as integer
	
	declare function getCounter(id as integer) as double
	declare function setCounter(id as integer, count as double) as Mob ptr
	declare function addCounter(id as integer, amount as double) as Mob ptr
	
	declare function registerHit(callback as sub(e as Mob ptr, damage as double, damage_type as integer = 0)) as Mob ptr
	declare function unregisterHit() as Mob ptr
	declare function callHit(damage as double=1.0) as Mob ptr
	
	declare function callState(d as double=1.0) as Mob ptr
	
	declare function registerBefore(state_before as sub(e as Mob ptr, d as double)) as Mob ptr
	declare function registerAfter(state_after as sub(e as Mob ptr, d as double)) as Mob ptr
	declare function registerCollision(collision_callback as function(e as Mob ptr, x as double, y as double) as integer) as Mob ptr
	declare function collidesWithPoint(x as double, y as double) as integer
	declare function registerAwake(callback as sub(e as Mob ptr, d as double)) as Mob ptr
	declare function registerSleep(callback as sub(e as Mob ptr, d as double)) as Mob ptr
	declare function awake() as Mob ptr
	declare function sleep() as Mob ptr
	
	declare function setInAwakeRange(callback as function(e as Mob ptr) as integer) as Mob ptr
	declare function setInActiveRange(callback as function(e as Mob ptr) as integer) as Mob ptr
	declare function inAwakeRange() as integer
	declare function notInActiveRange() as integer
	
	declare function getFlagsMask() as integer
	declare function setFlagsMask(flags as integer) as Mob ptr
	declare function setFlag(flag as integer) as Mob ptr
	declare function hasFlag(flag as integer) as integer
	declare function notFlag(flag as integer) as integer
	declare function clearFlag(flag as integer) as Mob ptr
	declare function clearAllFlags() as Mob ptr
	
end type
