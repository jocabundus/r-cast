declare sub cavedweller_init(m as Mob ptr, d as double)
declare sub cavedweller_go(m as Mob ptr, d as double)
declare sub cavedweller_kill(m as Mob ptr, d as double)
declare sub cavedweller_hit(m as Mob ptr, damage as double, damage_type as integer = 0)
declare function cavedweller_collides_with_point(m as Mob ptr, p as Vector) as integer

#include once "../cavedweller.bas"
