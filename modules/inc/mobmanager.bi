#pragma once
#inclib "mobmanager"

#include once "modules/inc/mob.bi"

type MobManager
private:

	_ents(256) as Mob
	_idx(256) as integer
	_nextidx(256) as integer
	_lastidx as integer
	_firstidx as integer
	_rendersubs(256) as sub(e as Mob ptr)
	_num_ents as integer = -1
	
	_dummy as Mob

public:

	declare constructor()
	declare function addMob(e as Mob, rendersub as sub(e as Mob ptr) = 0) as Mob ptr
	declare function cycle(speed as double = 1) as MobManager ptr
	declare function cycleRenderOnly(speed as double = 1) as MobManager ptr
	declare function cycleThroughCallback(callback as sub(e as Mob ptr)) as MobManager ptr
	declare function truncate() as MobManager ptr
	declare function getMobById(id as integer) as Mob ptr

end type
