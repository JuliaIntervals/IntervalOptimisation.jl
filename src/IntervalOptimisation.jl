module IntervalOptimisation

export minimise, maximise,
       minimize, maximize
export HeapedVector, SortedVector

include("StrategyBase.jl")
using .StrategyBase

include("SortedVectors.jl")
using .SortedVectors

include("HeapedVectors.jl")
using .HeapedVectors

using IntervalArithmetic

include("optimise.jl")


const minimize = minimise
const maximize = maximise

end
