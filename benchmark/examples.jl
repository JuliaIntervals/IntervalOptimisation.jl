module OneDimExamples

using IntervalArithmetic, IntervalOptimisation

struct working_function{F<:Function}
    func::F
    region::Interval
    title::string
end

func1 = working_function("Quadratic equation", (-1..2), x->x*(x-1) )
func2 = working_function("Cubic equation", (-1..4), x->(x-2)^3-5x )
func3 = working_function("Quartic equation", (-4..6), x->(x-6)*(x+4)*(7x^2+10x+24) )

end



module TwoDimExamples

using IntervalArithmetic, IntervalOptimisation

struct working_function{S<:string, F<:Function}
    func::F
    region::IntervalBox
    title::S
end


rosenbrock(xx) = ( (x, y) = xx; 100*(y - x)^2 + (x - 1)^2 )
Rosenbrock = working_function(rosenbrock, (-5..5, 2), "Rosenbrock function")

end
