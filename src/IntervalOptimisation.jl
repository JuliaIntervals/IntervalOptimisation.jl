

module IntervalOptimisation

export minimise, maximise,
       minimize, maximize

include("SortedVectors.jl")
using .SortedVectors

using IntervalArithmetic, IntervalRootFinding


include("optimise.jl")

const minimize = minimise
const maximize = maximise

end
