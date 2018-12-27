#pragma once
#inclib "dart"

#include once "modules/inc/vector.bi"

type Dart
private:
	_index_id as integer
	_increment_id as integer
	_owner_id as integer
	_x as double
	_y as double
	_z as double
	_vx as double
	_vy as double
	_vz as double
	_startX as double
	_startY as double
	_startZ as double
	_way as Vector
	_position as Vector
	_angleX as double
	_angleY as double
	_angleZ as double
	_clipVx as double
	_clipVy as double
	_clipVz as double
	_clipStepX as double
	_clipStepY as double
	_clipStepZ as double
	_speed as double
	_count as double
	_move_callback as sub(d as Dart ptr, t as double)
	_collide_callback as function(d as Dart ptr, extra as any ptr) as integer
	_before_delete as sub(d as Dart ptr)
	_expires as integer
	_expires_in_seconds as double
	_damage as double
	_damage_type as integer
	_frames as integer
	_frame_start as integer
	_frame_speed as double
	_flags as integer
	_check_bounds as boolean
	_render_callback as sub(d as Dart ptr)
public:

	declare property way as Vector
	declare property way(new_way as Vector)
	declare property position as Vector
	declare property position(new_position as Vector)
	declare property speed() as double
	declare property speed(new_speed as double)
	
	declare function getIndexId() as integer
	declare function setIndexId(id as integer) as Dart ptr
	declare function getIncrementId() as integer
	declare function setIncrementId(id as integer) as Dart ptr
	declare function getOwnerId() as integer
	declare function setOwnerId(id as integer) as Dart ptr
	declare function getX() as double
	declare function setX(x as double) as Dart ptr
	declare function getY() as double
	declare function setY(y as double) as Dart ptr
	declare function getZ() as double
	declare function setZ(z as double) as Dart ptr
	declare function setXYZ(x as double, y as double, z as double) as Dart ptr
	declare function getVx() as double
	declare function setVx(vx as double) as Dart ptr
	declare function getVy() as double
	declare function setVy(vy as double) as Dart ptr
	declare function getVz() as double
	declare function setVz(vz as double) as Dart ptr
	declare function setVxVyVz(vx as double, vy as double, vz as double) as Dart ptr
	declare function getStartX() as double
	declare function setStartX(x as double) as Dart ptr
	declare function getStartY() as double
	declare function setStartY(y as double) as Dart ptr
	declare function getStartZ() as double
	declare function setStartZ(z as double) as Dart ptr
	declare function setStartXYZ(x as double, y as double, z as double) as Dart ptr
	declare function getAngleX() as double
	declare function setAngleX(ang as double) as Dart ptr
	declare function getAngleY() as double
	declare function setAngleY(ang as double) as Dart ptr
	declare function getAngleZ() as double
	declare function setAngleZ(ang as double) as Dart ptr
	declare function hasClip() as integer
	declare function clearClip() as Dart ptr
	declare function getSpeed() as double
	declare function setSpeed(speed as double) as Dart ptr
	declare function getCount() as double
	declare function setCount(count as double) as Dart ptr
	declare function setMoveCallback(p as sub(d as Dart ptr, t as double)) as Dart ptr
	declare function move(t as double) as Dart ptr
	declare function setCollideCallback(p as function(d as Dart ptr, extra as any ptr) as integer) as Dart ptr
	declare function collide(extra as any ptr = 0) as integer
	declare function setBeforeDelete(p as sub(d as Dart ptr)) as Dart ptr
	declare function callBeforeDelete() as Dart ptr
	declare function getExpires() as integer
	declare function setExpires(expires as integer) as Dart ptr
	declare function getExpiresInSeconds() as double
	declare function setExpiresInSeconds(seconds as double) as Dart ptr
	declare function getDamage() as double
	declare function setDamage(damage as double) as Dart ptr
	declare function getDamageType() as integer
	declare function setDamageType(damage_type as integer) as Dart ptr
	declare function getFrames() as integer
	declare function setFrames(frames as integer) as Dart ptr
	declare function getFrameStart() as integer
	declare function setFrameStart(frame_start as integer) as Dart ptr
	declare function getFrameSpeed() as double
	declare function setFrameSpeed(frame_speed as double) as Dart ptr
	declare function expire() as Dart ptr
	declare function expireSeconds(seconds as double) as integer
	declare function setFlag(flag as integer) as Dart ptr
	declare function hasFlag(flag as integer) as integer
	declare function clearFlag(flag as integer) as Dart ptr
	declare function clearAllFlags() as Dart ptr
	declare function setCheckBounds(do_check as boolean) as Dart ptr
	declare function checkBounds() as boolean
	declare function setRenderCallback(p as sub(d as Dart ptr)) as Dart ptr
	declare function render() as Dart ptr
    
    declare sub moveSimple(t as double)
    declare sub moveFast(t as double)
    declare sub moveUnit(t as double)
    declare sub moveOrthogonal(t as double)
    declare sub movePerfect(t as double)

end type
