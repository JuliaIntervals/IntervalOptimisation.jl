
"""
    minimise(f, X, tol=1e-3)

Find the global minimum of the function `f` over the `Interval` or `IntervalBox` `X` using the Moore-Skelboe algorithm.

For higher-dimensional functions ``f:\\mathbb{R}^n \\to \\mathbb{R}``, `f` must take a single vector argument.

Returns an interval containing the global minimum, and a list of boxes that contain the minimisers.
"""
function minimise(f, X::T, tol=1e-3) where {T}

    # list of boxes with corresponding lower bound, ordered by increasing lower bound:
    working = PriorityQueue(X => ∞)

    return _minimise(f, working, tol)
end

function minimise(f, Xs::Vector{T}, tol=1e-3) where {T}

    # list of boxes with corresponding lower bound, ordered by increasing lower bound:
    working = PriorityQueue(Dict(X => f(X).lo for X in Xs))

    return _minimise(f, working, tol)
end

function _minimise(f, working::PriorityQueue{K,V}, tol) where {K,V}

    minimizers = K[]
    global_min = ∞   # upper bound for the global minimum value

    num_bisections = 0

    while !isempty(working)

        #@show working, minimizers

        (XX, X_min) = dequeue_pair!(working)

        if X_min > global_min    # X_min == inf(f(X))
            continue
        end

        # find candidate for upper bound of global minimum by just evaluating a point in the interval:

        #@show f(interval.(mid(XX)))

        m = sup(f(interval.(mid(XX))))   # evaluate at midpoint of current interval

        if m < global_min && m > -∞
            global_min = m
        end

        # Remove all boxes whose lower bound is greater than the current one:
        # Since they are ordered, just find the first one that is too big

        # cutoff = searchsortedfirst(working.data, (X, global_min), by=x->x[2])
        # resize!(working, cutoff)

        if diam(XX) <= tol
            push!(minimizers, XX)

        else
            X1, X2 = bisect(XX)

            inf1 = inf(f(X1))
            inf1 <= global_min && enqueue!(working, X1 => inf1 )

            inf2 = inf(f(X2))
            inf2 <= global_min && enqueue!(working, X2 => inf2 )

            num_bisections += 1
        end

    end

    # @show global_min
    # @show minimizers

    new_minimizers = [minimizer for minimizer in minimizers if f(minimizer).lo <= global_min]

    lower_bound = minimum(inf.(f.(new_minimizers)))

    return Interval(lower_bound, global_min), new_minimizers
end


function maximise(f, X::T, tol=1e-3) where {T}
    bound, minimizers = minimise(x -> -f(x), X, tol)
    return -bound, minimizers
end
