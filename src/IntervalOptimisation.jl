

module IntervalOptimisation

export minimise, maximise,
       minimize, maximize

include("SortedVectors.jl")
using .SortedVectors

using IntervalArithmetic, IntervalRootFinding

if !isdefined(:sup)
    const sup = supremum
end

if !isdefined(:inf)
    const inf = infimum
end

include("optimise.jl")

const minimize = minimise
const maximize = maximise 

end
