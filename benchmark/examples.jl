module Working_function
using IntervalArithmetic

struct Working_func{F<:Function, reg<:Union{Interval, IntervalBox}}
   title::String
   region::reg
   func::F
end

end


module OneDimExamples

using IntervalArithmetic, IntervalOptimisation

import ..Working_function:Working_func
func1 = Working_func("Quadratic equation", (-1..2), x->x*(x-1) )
func2 = Working_func("Cubic equation", (-1..4), x->(x-2)^3-5x )
func3 = Working_func("Quartic equation", (-4..6), x->(x-6)*(x+4)*(7x^2+10x+24) )

end



module TwoDimExamples

using IntervalArithmetic, IntervalOptimisation

import ..Working_function:Working_func
rosenbrock(xx) = ( (x, y) = xx; 100*(y - x)^2 + (x - 1)^2 )
Rosenbrock = Working_func("Rosenbrock function", IntervalBox(-5..5, 2), rosenbrock)
end
