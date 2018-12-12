#include once "inc/easing.bi"

Namespace Easing

	function linear(d as double) as double
		return d
	end function
	
	function quad_easein(d as double) as double
		return d*d
	end function
	
	function quad_easeout(d as double) as double
		return 1-(d*d)
	end function
	
	function quad_easeinout(d as double) as double
		return iif(d < 0.5, (d*d)*2, 1.0-((1-d)*(1-d)*2))
	end function
	
	function cubic_easein(d as double) as double
		return d*d*d
	end function
	
	function cubic_easeout(d as double) as double
		return 1-(d*d*d)
	end function
	
	function cubic_easeinout(d as double) as double
		return iif(d < 0.5, (d*d*d)*4, 1.0-((1-d)*(1-d)*(1-d)*4))
	end function
	
	function sinusoidal(d as double) as double
		return sin(d*3.1415926535)
	end function
	
	function quint_easein(d as double) as double
		return d*d*d*d
	end function
	
	function quint_easeout(d as double) as double
		return 1-(d*d*d*d)
	end function
	
	function quint_easeinout(d as double) as double
		return iif(d < 0.5, (d*d*d*d)*8, 1.0-((1-d)*(1-d)*(1-d)*(1-d)*8))
	end function

end Namespace
