

module IntervalOptimisation

export minimise, maximise

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

end
