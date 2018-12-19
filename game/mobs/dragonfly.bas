sub dragonfly_init(m as Mob ptr, d as double)
end sub

sub dragonfly_go(m as Mob ptr, d as double)
end sub

sub dragonfly_kill(m as Mob ptr, d as double)
end sub

sub dragonfly_hit(m as Mob ptr, damage as double, damage_type as integer = 0)
end sub

function dragonfly_collides_with_point(m as Mob ptr, p as Vector) as integer
    return 0
end function
