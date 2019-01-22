

module IntervalOptimisation

export minimise, maximise,
       minimize, maximize


include("HeapedVectors.jl")
using .HeapedVectors

using IntervalArithmetic, IntervalRootFinding


include("optimise.jl")

const minimize = minimise
const maximize = maximise

end
