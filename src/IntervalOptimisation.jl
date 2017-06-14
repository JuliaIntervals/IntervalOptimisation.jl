

module IntervalOptimisation

export optimise

include("SortedVectors.jl")
using .SortedVectors

using IntervalArithmetic, IntervalRootFinding

include("optimise.jl")

end
