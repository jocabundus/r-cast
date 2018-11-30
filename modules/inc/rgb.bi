#pragma once
#inclib "rgb"

declare function red(argb32 as integer) as integer
declare function grn(argb32 as integer) as integer
declare function blu(argb32 as integer) as integer
declare function rgbAdd(colr as integer, amount as integer, keepHue as integer = 0) as integer
declare function rgbMix(colr0 as integer, colr1 as integer, f1 as double = 1, f2 as double = 1) as integer
