import NLPModels
import SolverCore

export IntervalOptimiser

"""
    IntervalOptimiser <: SolverCore.AbstractOptimizationSolver

A global optimization solver based on the Moore-Skelboe interval branch-and-bound algorithm.
Can be used with NLPModelsJuMP to solve JuMP models.

# Usage with JuMP and NLPModelsJuMP

```julia
using JuMP, NLPModelsJuMP, IntervalOptimisation

model = Model(NLPModelsJuMP.Optimizer)
set_attribute(model, "solver", IntervalOptimiser)
set_attribute(model, "tol", 1e-5)

@variable(model, -10 <= x <= 10)
@objective(model, Min, (x - 3)^2 + 1)
optimize!(model)
```

The solver stores the interval enclosure of the global minimum and the list of minimizer
boxes in the `solver_specific` fields `:global_min_interval` and `:minimizers`.
"""
mutable struct IntervalOptimiser <: SolverCore.AbstractOptimizationSolver
end

function IntervalOptimiser(nlp::NLPModels.AbstractNLPModel; kwargs...)
    return IntervalOptimiser()
end

"""
    _eval_moi_expr(expr, x)

Recursively evaluate a Julia `Expr` returned by `MOI.objective_expr` using the
variable values in `x`. Works with any numeric type including intervals.
"""
function _eval_moi_expr(expr::Expr, x)
    if expr.head == :ref && expr.args[1] == :x
        # x[MOI.VariableIndex(i)] → x[i]
        vi = expr.args[2]
        return x[vi.value]
    elseif expr.head == :call
        op = expr.args[1]
        evaluated_args = [_eval_moi_expr(a, x) for a in @view(expr.args[2:end])]
        if op isa Symbol
            return _call_op(Val(op), evaluated_args)
        else
            return op(evaluated_args...)
        end
    else
        error("Unsupported expression head: $(expr.head)")
    end
end

_eval_moi_expr(v::Number, _) = v

# Arithmetic
_call_op(::Val{:+}, args) = length(args) == 1 ? +args[1] : +(args...)
_call_op(::Val{:-}, args) = length(args) == 1 ? -args[1] : args[1] - args[2]
_call_op(::Val{:*}, args) = *(args...)
_call_op(::Val{:/}, args) = args[1] / args[2]
_call_op(::Val{:^}, args) = args[1] ^ args[2]
# Common math functions
_call_op(::Val{:log}, args)   = log(args[1])
_call_op(::Val{:log2}, args)  = log2(args[1])
_call_op(::Val{:log10}, args) = log10(args[1])
_call_op(::Val{:exp}, args)   = exp(args[1])
_call_op(::Val{:sqrt}, args)  = sqrt(args[1])
_call_op(::Val{:abs}, args)   = abs(args[1])
_call_op(::Val{:sin}, args)   = sin(args[1])
_call_op(::Val{:cos}, args)   = cos(args[1])
_call_op(::Val{:tan}, args)   = tan(args[1])
_call_op(::Val{:asin}, args)  = asin(args[1])
_call_op(::Val{:acos}, args)  = acos(args[1])
_call_op(::Val{:atan}, args)  = atan(args...)
_call_op(::Val{:min}, args)   = min(args...)
_call_op(::Val{:max}, args)   = max(args...)
# Fallback: try to find the function in Base/Main
_call_op(::Val{op}, args) where {op} = getfield(Base, op)(args...)

function SolverCore.solve!(
    solver::IntervalOptimiser,
    nlp::NLPModels.AbstractNLPModel,
    stats::SolverCore.GenericExecutionStats;
    tol::Real = 1e-3,
    structure = HeapedVector,
    kwargs...,
)
    start_time = time()

    # Only box-constrained or unconstrained problems are supported
    if nlp.meta.ncon > 0
        SolverCore.set_status!(stats, :exception)
        SolverCore.set_time!(stats, time() - start_time)
        error("IntervalOptimiser only supports unconstrained or box-constrained problems")
    end

    nvar = nlp.meta.nvar
    lvar = nlp.meta.lvar
    uvar = nlp.meta.uvar

    # Check that all variables have finite bounds
    for i in 1:nvar
        if !isfinite(lvar[i]) || !isfinite(uvar[i])
            SolverCore.set_status!(stats, :exception)
            SolverCore.set_time!(stats, time() - start_time)
            error("IntervalOptimiser requires finite bounds on all variables")
        end
    end

    # Build the interval search box
    X = [interval(lvar[i], uvar[i]) for i in 1:nvar]

    # Create the objective function for interval evaluation
    f = _make_objective(nlp, nvar)

    # Solve
    dom = nvar == 1 ? X[1] : X
    if nlp.meta.minimize
        global_opt, optimizer_boxes = minimise(f, dom; structure = structure, tol = tol)
    else
        global_opt, optimizer_boxes = maximise(f, dom; structure = structure, tol = tol)
    end

    # Extract solution (midpoint of the first minimizer box)
    if nvar == 1
        solution = [mid(optimizer_boxes[1])]
    else
        solution = mid.(optimizer_boxes[1])
    end
    objective = mid(global_opt)

    SolverCore.set_status!(stats, :first_order)
    SolverCore.set_solution!(stats, solution)
    SolverCore.set_objective!(stats, objective)
    SolverCore.set_iter!(stats, length(optimizer_boxes))
    SolverCore.set_time!(stats, time() - start_time)
    SolverCore.set_solver_specific!(stats, :global_min_interval, global_opt)
    SolverCore.set_solver_specific!(stats, :minimizers, optimizer_boxes)

    return stats
end

# Default: use NLPModels.obj directly (works for linear/quadratic objectives)
function _make_objective(nlp::NLPModels.AbstractNLPModel, nvar)
    if nvar == 1
        return x -> NLPModels.obj(nlp, [x])
    else
        return x -> NLPModels.obj(nlp, x)
    end
end
