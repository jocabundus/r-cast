#pragma once
#inclib "flatmapcell"

type FlatMapCell
private:

    _hp as short
    _is_solid as boolean   '// means ray cant pass through
    _floor_height as short '// floor   height -10,000 to 10,000
    _ceil_height  as short '// ceiling height
    _floor_tile as short  '// floor   -- sprite index
    _ceil_tile  as short  '// ceiling -- sprite index
    _side_tile as short
    _item as short
    _normal as byte        '// calculated value of normal, for shading
    _flags as integer
    
    _on_over    as sub(tile as FlatMapCell ptr)
    _on_hit     as sub(tile as FlatMapCell ptr, damage as double=1.0, damage_type as integer=0)
    _on_destroy as sub(tile as FlatMapCell ptr)

public:

    declare constructor()
    declare function reset() as FlatMapCell ptr
    declare function getHp() as short
    declare function setHp(hp as short) as FlatMapCell ptr
    declare function isSolid() as boolean
    declare function setIsSolid(is_solid as boolean) as FlatMapCell ptr
    declare function getFloorHeight() as short
    declare function setFloorHeight(height as short) as FlatMapCell ptr
    declare function getCeilHeight() as short
    declare function setCeilHeight(height as short) as FlatMapCell ptr
    declare function getFloorTile() as short
    declare function setFloorTile(tile as short) as FlatMapCell ptr
    declare function getCeilTile() as short
    declare function setCeilTile(tile as short) as FlatMapCell ptr
    declare function getSideTile() as short
    declare function setSideTile(tile as short) as FlatMapCell ptr
    declare function getItem() as short
    declare function setItem(item as short) as FlatMapCell ptr
    declare function getNormal() as byte
    declare function setNormal(normal as byte) as FlatMapCell ptr
    declare function hasFlag(flag as integer) as integer
    declare function notFlag(flag as integer) as integer
    declare function setFlag(flag as integer) as FlatMapCell ptr
    declare function unsetFlag(flag as integer) as FlatMapCell ptr
    declare function getFlags() as integer
    declare function setFlags(flags as integer) as FlatMapCell ptr
    declare function clearFlags() as FlatMapCell ptr
    
    declare function getOnOver() as sub(tile as FlatMapCell ptr)
    declare function setOnOver(callback as sub(tile as FlatMapCell ptr)) as FlatMapCell ptr
    declare function getOnHit() as sub(tile as FlatMapCell ptr, damage as double=1.0, damage_type as integer=0)
    declare function setOnHit(callback as sub(tile as FlatMapCell ptr, damage as double=1.0, damage_type as integer=0)) as FlatMapCell ptr
    declare function getOnDestroy() as sub(tile as FlatMapCell ptr)
    declare function setOnDestroy(callback as sub(tile as FlatMapCell ptr)) as FlatMapCell ptr
    
    declare function callOver() as FlatMapCell ptr
    declare function callHit(tile as FlatMapCell ptr, damage as double=1.0, damage_type as integer=0) as FlatMapCell ptr
    declare function callDestroy() as FlatMapCell ptr

end type
