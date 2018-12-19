#include once "inc/flatmapcell.bi"

constructor FlatMapCell
    this.reset()
end constructor

function FlatMapCell.reset() as FlatMapCell ptr
    this._hp           = 0
    this._is_solid     = 0
    this._floor_height = 0
    this._ceil_height  = 0
    this._floor_tile   = 0
    this._ceil_tile    = 0
    this._item         = 0
    this._normal       = 0
    this._flags        = 0
    this._on_over      = 0
    this._on_hit       = 0
    this._on_destroy   = 0
    return @this
end function

function FlatMapCell.getHp() as short
    return this._hp
end function
function FlatMapCell.setHp(hp as short) as FlatMapCell ptr
    this._hp = hp
    return @this
end function

function FlatMapCell.isSolid() as boolean
    return this._is_solid
end function
function FlatMapCell.setIsSolid(is_solid as boolean) as FlatMapCell ptr
    this._is_solid = is_solid
    return @this
end function

function FlatMapCell.getFloorHeight() as short
    return this._floor_height
end function
function FlatMapCell.setFloorHeight(height as short) as FlatMapCell ptr
    this._floor_height = height
    return @this
end function
function FlatMapCell.getCeilHeight() as short
    return this._ceil_height
end function
function FlatMapCell.setCeilHeight(height as short) as FlatMapCell ptr
    this._ceil_height = height
    return @this
end function

function FlatMapCell.getFloorTile() as short
    return this._floor_tile
end function
function FlatMapCell.setFloorTile(tile as short) as FlatMapCell ptr
    this._floor_tile = tile
    return @this
end function
function FlatMapCell.getCeilTile() as short
    return this._ceil_tile
end function
function FlatMapCell.setCeilTile(tile as short) as FlatMapCell ptr
    this._ceil_tile = tile
    return @this
end function
function FlatMapCell.getSideTile() as short
    return this._side_tile
end function
function FlatMapCell.setSideTile(tile as short) as FlatMapCell ptr
    this._side_tile = tile
    return @this
end function

function FlatMapCell.getItem() as short
    return this._item
end function
function FlatMapCell.setItem(item as short) as FlatMapCell ptr
    this._item = item
    return @this
end function

function FlatMapCell.getNormal() as byte
    return this._normal
end function
function FlatMapCell.setNormal(normal as byte) as FlatMapCell ptr
    this._normal = normal
    return @this
end function

function FlatMapCell.hasFlag(flag as integer) as integer
	return (this._flags and flag) > 0
end function
function FlatMapCell.notFlag(flag as integer) as integer
	return not ((this._flags and flag) > 0)
end function
function FlatMapCell.setFlag(flag as integer) as FlatMapCell ptr
	this._flags = (this._flags or flag)
	return @this
end function
function FlatMapCell.unsetFlag(flag as integer) as FlatMapCell ptr
	this._flags = (this._flags or flag) xor flag
	return @this
end function
function FlatMapCell.getFlags() as integer
	return this._flags
end function
function FlatMapCell.setFlags(flags as integer) as FlatMapCell ptr
	this._flags = flags
	return @this
end function
function FlatMapCell.clearFlags() as FlatMapCell ptr
	this._flags = 0
	return @this
end function

function FlatMapCell.getOnOver() as sub(tile as FlatMapCell ptr)
    return this._on_over
end function
function FlatMapCell.setOnOver(callback as sub(tile as FlatMapCell ptr)) as FlatMapCell ptr
    this._on_over = callback
    return @this
end function
function FlatMapCell.getOnHit() as sub(tile as FlatMapCell ptr, damage as double=1.0, damage_type as integer=0)
    return this._on_hit
end function
function FlatMapCell.setOnHit(callback as sub(tile as FlatMapCell ptr, damage as double=1.0, damage_type as integer=0)) as FlatMapCell ptr
    this._on_hit = callback
    return @this
end function
function FlatMapCell.getOnDestroy() as sub(tile as FlatMapCell ptr)
    return this._on_destroy
end function
function FlatMapCell.setOnDestroy(callback as sub(tile as FlatMapCell ptr)) as FlatMapCell ptr
    this._on_destroy = callback
    return @this
end function

function FlatMapCell.callOver() as FlatMapCell ptr
    if this._on_over <> 0 then
        this._on_over(@this)
    end if
    return @this
end function
function FlatMapCell.callHit(tile as FlatMapCell ptr, damage as double=1.0, damage_type as integer=0) as FlatMapCell ptr
    if this._on_hit <> 0 then
        this._on_hit(@this, damage, damage_type)
    end if
    return @this
end function
function FlatMapCell.callDestroy() as FlatMapCell ptr
    if this._on_destroy <> 0 then
        this._on_destroy(@this)
    end if
    return @this
end function
