

module IntervalOptimisation

export minimise, maximise,
       minimize, maximize,
       minimise1d, minimise1d_deriv,
       minimise_icp, minimise_icp_constrained

include("SortedVectors.jl")
using .SortedVectors

using IntervalArithmetic, IntervalRootFinding, DataStructures, IntervalConstraintProgramming, StaticArrays, ForwardDiff

if !isdefined(:sup)
    const sup = supremum
end

if !isdefined(:inf)
    const inf = infimum
end

include("optimise.jl")
include("optimise1.jl")

const minimize = minimise
const maximize = maximise

end
