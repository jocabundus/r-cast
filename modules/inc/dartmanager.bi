#pragma once
#inclib "dartmanager"

#include once "modules/inc/dart.bi"

type DartManager
private:
	_darts(1023) as Dart
	_idx(1023) as integer
	_nextidx(1023) as integer
	_lastidx as integer
	_firstidx as integer
	_dummydart as Dart
	_x0 as integer
	_y0 as integer
	_z0 as integer
	_x1 as integer
	_y1 as integer
	_z1 as integer
	_render_callback as sub(d as Dart ptr)
	_collide_callback as function(x as double, y as double, z as double) as integer
	_current as Dart ptr = 0
public:
	
	declare constructor()
	declare function setBounds(x0 as integer, y0 as integer, z0 as integer, x1 as integer, y1 as integer, z1 as integer) as DartManager ptr
	declare function setRenderCallback(p as sub(d as Dart ptr)) as DartManager ptr
	declare function setDefaultCollideCallback(p as function(x as double, y as double, z as double) as integer) as DartManager ptr
	declare function fire(start as Vector, forward as Vector, speed as double, id as integer) as Dart ptr
	declare function cycle(speed as double = 1) as DartManager ptr
	declare function getCurrent() as Dart ptr
	declare function clearDarts() as DartManager ptr

end type
