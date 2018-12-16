#include once "modules/inc/mobmanager.bi"
#include once "modules/inc/mob.bi"

constructor MobManager
	'this.truncate()
	'this._firstidx = -1
	'this._lastidx = -1
end constructor

function MobManager.addMob(e as Mob, rendersub as sub(e as Mob ptr) = 0) as Mob ptr

	dim i as integer
	dim idx as integer = -1
	for i = 0 to 255
		if this._idx(i) = 0 then
			this._idx(i) = 1
			idx = i
			exit for
		end if
	next i
	
	if idx = -1 then return @this._dummy
	if this._firstidx = -1 then
		this._firstidx = idx
	end if
	if this._lastidx >= 0 then
		this._nextidx(this._lastidx) = idx
	end if
	this._nextidx(idx) = -1
	this._lastidx = idx
	
	this._ents(idx) = e
	
	this._ents(idx).setIndexId(idx)
	this._rendersubs(idx) = rendersub
	
	static increment_id as integer = 0
    increment_id += 1
    this._ents(idx).setIncrementId(increment_id)
	
	return @this._ents(idx)

end function

function MobManager.getMobById(id as integer) as Mob ptr
	
	dim i as integer
	dim e as Mob ptr
	
	i = this._firstidx
    while i > -1
    
		e = @this._ents(i)
		
		if e->getId() = id then
			return e
		end if
		
		i = this._nextidx(i)
	wend
	
	return 0
	
end function

function MobManager.cycleRenderOnly(speed as double = 1) as MobManager ptr

	dim i as integer
	dim e as Mob ptr
	
	i = this._firstidx
    while i > -1
    
		e = @this._ents(i)
		
		if this._rendersubs(i) then
			this._rendersubs(i)(e)
		end if
		
		i = this._nextidx(i)
	wend
	
	return @this

end function

function MobManager.cycle(speed as double = 1) as MobManager ptr

	dim i as integer
	dim e as Mob ptr
	dim remove as integer
	
	dim tocall(256) as Mob ptr
    dim numtocall as integer = 0
    dim prev as integer
	
	i = this._firstidx
    while i > -1
    
		e = @this._ents(i)
		
		if e->getState() then
			e->callState(speed)
		else
			remove = 1
		end if
		
		if remove then
            tocall(numtocall) = e
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
			remove = 0
        else
			if this._rendersubs(i) then
				this._rendersubs(i)(e)
			end if
			prev = i
            i = this._nextidx(i)
        end if
		
	wend
	
	for i = 0 to numtocall-1
		'tocall(i)->callBeforeDelete()
    next i
    
	return @this

end function

function MobManager.cycleThroughCallback(callback as sub(e as Mob ptr)) as MobManager ptr

	dim i as integer
	dim e as Mob ptr
	
	i = this._firstidx
    while i > -1
		e = @this._ents(i)
		callback(e)
		i = this._nextidx(i)
    wend
    
    return @this

end function

function MobManager.truncate() as MobManager ptr
	dim i as integer
	for i = 0 to 255
		this._idx(i) = 0
	next i
	this._firstidx = -1
	this._lastidx = -1
	return @this
end function
