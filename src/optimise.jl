
"""
    minimise(f, X, tol=1e-3)

Find the global minimum of the function `f` over the `Interval` or `IntervalBox` `X`.

Uses a version of the Moore-Skelboe algorithm.
"""
function minimise{T}(f, X::T, tol=1e-3)

    # list of boxes with corresponding lower bound, ordered by increasing lower bound:
    working = SortedVector([(X, ∞)], x->x[2])

    minimizers = T[]
    global_min = ∞  # upper bound
    lower_bound = -∞

    num_bisections = 0

    while !isempty(working)

        (X, X_min) = shift!(working)

        if X_min > global_min    # X_min == inf(f(X))
            continue
        end

        # find candidate for upper bound of global minimum by just evaluating a point in the interval:
        m = sup(f(Interval.(mid.(X))))   # evaluate at midpoint of current interval

        if m < global_min
            global_min = m
        end

        # Remove all boxes whose lower bound is greater than the current one:
        # Since they are ordered, just find the first one that is too big

        cutoff = searchsortedfirst(working.data, (X, global_min), by=x->x[2])
        resize!(working, cutoff-1)

        if diam(X) < tol
            push!(minimizers, X)

            if X_min > lower_bound
                lower_bound = X_min
            end
    
        else
            X1, X2 = bisect(X)
            push!( working, (X1, inf(f(X1))), (X2, inf(f(X2))) )
            num_bisections += 1
        end

    end

    return Interval(lower_bound, global_min), minimizers
end
