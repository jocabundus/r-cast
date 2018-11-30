#pragma once
#inclib "timer"

declare function UpdateSpeed (save_time as integer=1) as double
declare function GetDelay () as double

dim shared TimerSeconds as double
dim shared TimerMaxDiff as double = 1.0
dim shared TimerLastTime as double
