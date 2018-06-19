using IntervalArithmetic, DataStructures

import Base.isless

struct IntervalMinima{T<:Real}
    intval::Interval{T}
    minima::T
end

function isless(a::IntervalMinima{T}, b::IntervalMinima{T}) where {T<:Real}
    return isless(a.minima, b.minima)
end

function minimise1d(f::Function, x::Interval{T}; reltol=1e-3, abstol=1e-3) where {T<:Real}

    Q = binary_minheap(IntervalMinima{T})

    minima = f(interval(mid(x))).hi
    arg_minima = Interval{T}[]

    push!(Q, IntervalMinima(x, minima))

    while !isempty(Q)

        p = pop!(Q)

        if p.minima > minima
            continue
        end
        #
        # if 0 ∉ ForwardDiff.derivative(f, p.intval)
        #     continue
        # end

        # current_minima = f(p.intval).lo

        current_minima = f(interval(mid(p.intval))).hi

        if current_minima < minima
            minima = current_minima
        end

        if diam(p.intval) < abstol
            push!(arg_minima, p.intval)
        else
            x1, x2 = bisect(p.intval)
            push!(Q, IntervalMinima(x1, f(x1).lo), IntervalMinima(x2, f(x2).lo))
        end
    end

    return minima, arg_minima
end
