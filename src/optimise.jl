
"""
    optimise(f, X, tol=1e-3)

Find the global minimum of the function `f` over the `Interval` or `IntervalBox` `X`.

Uses a version of the Moore-Skelboe algorithm.
"""
function optimise{T}(f, X::T, tol=1e-3)

    # list of boxes with corresponding lower bound, ordered by increasing lower bound:
    working = SortedVector([(X, ∞)], x->x[2])

    global_min = ∞
    minimizers = Tuple{T, Float64}[]

    num_bisections = 0

    while !isempty(working)

        # @show working

        (X, Xmin) = shift!(working)
        # Y = f(X)

        if inf(f(X)) > global_min  # inf(f(X)) is Xmin?
            continue
        end

        # find candidate for global minimum upper bound:
        m = sup(f(Interval.(mid.(X))))   # evaluate at midpoint of current interval

        # @show m, global_min
        # @show length(working.data)

        if m < global_min
            global_min = m
        end

        # Remove all boxes whose lower bound is greater than the current one:
        # Since they are ordered, just find the first one that is too big

        cutoff = searchsortedfirst(working.data, (X, global_min), by=x->x[2])
        resize!(working, cutoff-1)

        if diam(X) < tol
            push!( minimizers, (X, inf(f(X))) )

        else
            X1, X2 = bisect(X)
            push!( working, (X1, inf(f(X1))), (X2, inf(f(X2))) )
            num_bisections += 1
        end

    end

    @show num_bisections

    return global_min, minimizers
end
