

module IntervalOptimisation

export minimise, maximise

include("SortedVectors.jl")
using .SortedVectors

using IntervalArithmetic, IntervalRootFinding

include("optimise.jl")

end
