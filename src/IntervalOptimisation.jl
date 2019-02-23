

module IntervalOptimisation

using IntervalArithmetic, IntervalRootFinding
using LinearAlgebra

export minimise, maximise,
       minimize, maximize

export mean_value_form_scalar, third_order_taylor_form_scalar


include("SortedVectors.jl")
using .SortedVectors


include("optimise.jl")
include("centered_forms.jl")

const minimize = minimise
const maximize = maximise

end
