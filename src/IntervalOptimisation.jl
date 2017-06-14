

module IntervalOptimisation

export optimise

include("SortedVectors.jl")
using .SortedVectors

using IntervalArithmetic

include("optimise.jl")

end
