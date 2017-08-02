
"""
    minimise(f, X, tol=1e-3)

Find the global minimum of the function `f` over the `Interval` or `IntervalBox` `X` using the Moore-Skelboe algorithm.

For higher-dimensional functions ``f:\mathbb{R}^n \to \mathbb{R}``, `f` must take a single vector argument.

Returns an interval containing the global minimum, and a list of boxes that contain the minimisers.
"""
function minimise{T}(f, X::T, tol=1e-3)

    # list of boxes with corresponding lower bound, ordered by increasing lower bound:
    working = SortedVector([(X, ∞)], x->x[2])

    minimizers = T[]
    global_min = ∞  # upper bound

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

        else
            X1, X2 = bisect(X)
            push!( working, (X1, inf(f(X1))), (X2, inf(f(X2))) )
            num_bisections += 1
        end

    end

    lower_bound = minimum(inf.(f.(minimizers)))

    return Interval(lower_bound, global_min), minimizers
end


function maximise{T}(f, X::T, tol=1e-3)
    bound, minimizers = minimise(x -> -f(x), X, tol)
    return -bound, minimizers
end



function unify(minimisers)

    n = length(minimisers)
    g = Graph(length(minimisers))

    for i in 1:n, j in i+1:n
        if !isempty(minimisers[i] ∩ minimisers[j])
            add_edge!(g, i, j)
        end
    end

    components = LightGraphs.connected_components(g)

    return [reduce(union, minimisers[components[i]]) for i in 1:length(components)]

end
