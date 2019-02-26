"""
    minimise(f, X, structure = SortedVector, tol=1e-3)
    or
    minimise(f, X, structure = HeapedVector, tol=1e-3)
    or
    minimise(f, X, tol=1e-3) in this case the default value of "structure" is "HeapedVector"

Find the global minimum of the function `f` over the `Interval` or `IntervalBox` `X` using the Moore-Skelboe algorithm. By specifing the way in which vector element are kept arranged which is in heaped array or in sorted array. If you not specify any particular strategy to keep vector elements arranged then by default heaped array is used.

For higher-dimensional functions ``f:\\mathbb{R}^n \\to \\mathbb{R}``, `f` must take a single vector argument.

Returns an interval containing the global minimum, and a list of boxes that contain the minimisers.
"""


function minimise(f, X::T, structure = HeapedVector, tol=1e-3 ) where {T}

    # list of boxes with corresponding lower bound, arranged according to selected structure :
    working = structure([(X, ∞)], x->x[2])
    minimizers = T[]
    global_min = ∞  # upper bound

    num_bisections = 0

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

    end

    lower_bound = minimum(inf.(f.(minimizers)))

    return Interval(lower_bound, global_min), minimizers
end


function maximise(f, X::T; structure = HeapedVector, tol=1e-3 ) where {T}
    bound, minimizers = minimise(x -> -f(x), X, structure, tol)
    return -bound, minimizers
end
