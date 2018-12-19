declare sub zombie_init(m as Mob ptr, d as double)
declare sub zombie_go(m as Mob ptr, d as double)
declare sub zombie_kill(m as Mob ptr, d as double)
declare sub zombie_hit(m as Mob ptr, damage as double, damage_type as integer = 0)
declare function zombie_collides_with_point(m as Mob ptr, p as Vector) as integer

#include once "../zombie.bas"
