module OneDimExamples

using IntervalArithmetic, IntervalOptimisation

struct working_function{string, F<:Function, reg<:Interval} 
    func::F
    region::reg
    title::string
end

func1 = working_function("Quadrtic equation", Interval(-1,2), x->x*(x-1) )
func2 = working_function("Cubic equation", Interval(-1,4), x->(x-2)^3-5x )
func3 = working_function("quadritic equation", Interval(-4,6), x->(x-6)*(x+4)*(7x^2+10x+24) )


const region=(-4..6)

end 



module TwoDimExamples

using IntervalArithmetic, IntervalOptimisation

struct working_function{string, F<:Function, reg<:Union{Interval, IntervalBox}}  
    func::F
    region::reg
    title::string
end


rosenbrock(xx) = ( (x, y) = xx; 100*(y - x)^2 + (x - 1)^2 )
Rosenbrock = working_function(rosenbrock, IntervalBox(-5..5, 2), "Rosenbrock function")

end










