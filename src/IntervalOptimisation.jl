module IntervalOptimisation

using IntervalArithmetic, IntervalRootFinding


export minimise, maximise,
       minimize, maximize
export HeapedVector, SortedVector

include("StrategyBase.jl")
using .StrategyBase

export mean_value_form_scalar, third_order_taylor_form_scalar

include("SortedVectors.jl")
using .SortedVectors

include("HeapedVectors.jl")
using .HeapedVectors

include("optimise.jl")
include("centered_forms.jl")


const minimize = minimise
const maximize = maximise

end
