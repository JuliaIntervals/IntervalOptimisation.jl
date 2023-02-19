numeric_type(::Interval{T}) where {T} = T
numeric_type(::IntervalBox{N, T}) where {N, T} = T

"""
    minimise(f, X, structure = SortedVector, tol=1e-3, f_calls_limit=Inf)
    or
    minimise(f, X, structure = HeapedVector, tol=1e-3, f_calls_limit=Inf)
    or
    minimise(f, X, tol=1e-3, f_calls_limit=Inf) in this case the default value of "structure" is "HeapedVector"

Find the global minimum of the function `f` over the `Interval` or `IntervalBox` `X`
using the Moore-Skelboe algorithm. The way in which vector elements are
kept arranged can be either a heaped array or a sorted array.
If you not specify any particular strategy to keep vector elements arranged then
by default heaped array is used.

For higher-dimensional functions ``f:\\mathbb{R}^n \\to \\mathbb{R}``, `f` must take a single vector argument.

Returns an interval containing the global minimum, and a list of boxes that contain the minimisers.
"""
function minimise(f, X::T; structure = HeapedVector, tol=1e-3, f_calls_limit=Inf) where {T}
    nT = numeric_type(X)
    
    # list of boxes with corresponding lower bound, arranged according to selected structure :
    working = structure([(X, nT(∞))], x->x[2])
    minimizers = T[]
    global_min = nT(∞)  # upper bound

    num_bisections = 0
    f_calls = 0

    while !isempty(working)

        (X, X_min) = popfirst!(working)

        if X_min > global_min    # X_min == inf(f(X))
            continue
        end

        # find candidate for upper bound of global minimum by just evaluating a point in the interval:
        m = sup(f(Interval.(mid.(X))))   # evaluate at midpoint of current interval

        if m < global_min
            global_min = m
        end

        # Remove all boxes whose lower bound is greater than the current one:
        filter_elements!(working , (X, global_min) )

        if diam(X) < tol
            push!(minimizers, X)
        else
            X1, X2 = bisect(X)
            push!( working, (X1, inf(f(X1))) )
            push!( working, (X2, inf(f(X2))) )
            num_bisections += 1
        end

        f_calls += 3 # we called the function 3 times
        # we still need length(minimizers) + 1 evaluations to compute lower_bound
        if ((f_calls + length(minimizers) + 1) >= f_calls_limit)
            push!(minimizers, X)
            break
        end
    end

    lower_bound = minimum(inf.(f.(minimizers)))

    return Interval(lower_bound, global_min), minimizers
end

"""
    maximise(f, X, structure = SortedVector, tol=1e-3, f_calls_limit=Inf)
    or
    maximise(f, X, structure = HeapedVector, tol=1e-3, f_calls_limit=Inf)
    or
    maximise(f, X, tol=1e-3, f_calls_limit=Inf) in this case the default value of "structure" is "HeapedVector"

Find the global maximum of the function `f` over the `Interval` or `IntervalBox` `X`
using the Moore-Skelboe algorithm. See [`minimise`](@ref) for a description
of the available options.
"""
function maximise(f, X::T; structure=HeapedVector, tol=1e-3, f_calls_limit=Inf) where {T}
    bound, minimizers = minimise(x -> -f(x), X, structure=structure, tol=tol, f_calls_limit=f_calls_limit)
    return -bound, minimizers
end
