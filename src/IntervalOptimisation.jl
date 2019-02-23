module IntervalOptimisation

export minimise, maximise,
       minimize, maximize
export HeapedVector, SortedVector

include("SortedVectors.jl")
using .SortedVectors

include("HeapedVectors.jl")
using .HeapedVectors

using IntervalArithmetic, IntervalRootFinding

include("Strategy.jl")
using Strategy:filter_elements!
include("optimise.jl")

const minimize = minimise
const maximize = maximise

end
