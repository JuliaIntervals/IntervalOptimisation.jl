

module IntervalOptimisation

export minimise

include("SortedVectors.jl")
using .SortedVectors

using IntervalArithmetic, IntervalRootFinding

include("optimise.jl")

end
