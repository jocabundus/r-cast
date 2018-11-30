#include once "inc/timer.bi"

'- Calculate the global delay factor
function UpdateSpeed (save_time as integer=1) as double
	
	dim seconds as double
	
	seconds       = TIMER-TimerLastTime
	TimerLastTime = TIMER
	
	if seconds > TimerMaxDiff then
		seconds = TimerMaxDiff
	end if
	
	if save_time then
		TimerSeconds = seconds
	end if
	
	return seconds
	
end function

'- Return the delay factor
function GetDelay () as double

	return TimerSeconds
	
end function

function GetLastTime () as double

	return TimerLastTime

end function
