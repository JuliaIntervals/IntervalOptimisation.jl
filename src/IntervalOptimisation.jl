module IntervalOptimisation

export minimise, maximise,
       minimize, maximize
export HeapedVector, SortedVector
export mean_value_form_scalar, third_order_taylor_form_scalar

include("StrategyBase.jl")
using .StrategyBase

include("SortedVectors.jl")
using .SortedVectors

include("HeapedVectors.jl")
using .HeapedVectors

using IntervalArithmetic, IntervalRootFinding
using LinearAlgebra

include("optimise.jl")
include("centered_forms.jl") 

const minimize = minimise
const maximize = maximise

end
