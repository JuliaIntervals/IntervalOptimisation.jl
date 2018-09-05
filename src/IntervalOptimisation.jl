

module IntervalOptimisation

export minimise, maximise,
       minimize, maximize,
       minimise1d, minimise1d_deriv,
       minimise_icp, minimise_icp_constrained

include("SortedVectors.jl")
using .SortedVectors

using IntervalArithmetic, IntervalRootFinding, DataStructures, IntervalConstraintProgramming, ForwardDiff


include("optimise.jl")
include("optimise1.jl")

const minimize = minimise
const maximize = maximise

end
