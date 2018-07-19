using IntervalRootFinding, IntervalArithmetic, StaticArrays, ForwardDiff, BenchmarkTools, Compat, IntervalOptimisation, DataStructures

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

        if isempty(p.intval)
            continue
        end

        if p.minima > minima
            continue
        end

        # deriv = ForwardDiff.derivative(f, p.intval)
        # if 0 ∉ deriv
        #     continue
        # end

        doublederiv = ForwardDiff.derivative(x->ForwardDiff.derivative(f, x), p.intval)
        if doublederiv < 0
            continue
        end

        m = mid(p.intval)

        current_minima = f(interval(m)).hi

        if current_minima < minima
            minima = current_minima
        end


        # # Contractor 1
        # x = m .+ extended_div((interval(-∞, minima) - f(m)), deriv)
        #
        # x = x .∩ p.intval

        # Contractor 2
        @show p.intval
        @show (doublederiv/2, ForwardDiff.derivative(f, interval(m)), f(m) - interval(-∞, minima))
        @show (m .+ quadratic_roots(doublederiv/2, ForwardDiff.derivative(f, interval(m)), f(m) - interval(-∞, minima)))
        x = m .+ quadratic_roots(doublederiv/2, ForwardDiff.derivative(f, interval(m)), f(m) - interval(-∞, minima))

        x = x .∩ p.intval

        if diam(p.intval) < abstol
            push!(arg_minima, p.intval)
        else
            if length(x) == 1
                x1, x2 = bisect(x[1])
                push!(Q, IntervalMinima(x1, f(x1).lo), IntervalMinima(x2, f(x2).lo))
            else
                push!(Q, IntervalMinima.(x, inf.(f.(x)))...)
            end
            # if isempty(x[2])
            #     x1, x2 = bisect(x[1])
            #     push!(Q, IntervalMinima(x1, f(x1).lo), IntervalMinima(x2, f(x2).lo))
            # else
            #     x1, x2, x3 = x
            #     push!(Q, IntervalMinima(x1, f(x1).lo), IntervalMinima(x2, f(x2).lo), IntervalMinima(x3, f(x3).lo))
            # end
        end
    end

    return minima, arg_minima
end


function minimise1d_noderiv(f::Function, x::Interval{T}; reltol=1e-3, abstol=1e-3) where {T<:Real}

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



struct IntervalBoxMinima{N, T<:Real}
    intval::IntervalBox{N, T}
    minima::T
end

function isless(a::IntervalBoxMinima{N, T}, b::IntervalBoxMinima{N, T}) where {N, T<:Real}
    return isless(a.minima, b.minima)
end

function minimisend(f::Function, x::IntervalBox{N, T}; reltol=1e-3, abstol=1e-3) where {N, T<:Real}

    Q = binary_minheap(IntervalBoxMinima{N, T})

    minima = f(x).lo
    arg_minima = IntervalBox{N, T}[]

    push!(Q, IntervalBoxMinima(x, minima))

    while !isempty(Q)

        p = pop!(Q)

        if p.minima > minima
            continue
        end

        if 0 .∉ ForwardDiff.gradient(f, p.intval)
            continue
        end

        if p.minima < minima
            minima = p.minima
        end

        if diam(p.intval) < abstol
            push!(arg_minima, p.intval)
        else
            x1, x2 = bisect(p.intval)
            push!(Q, IntervalBoxMinima(x1, f(x1).lo), IntervalBoxMinima(x2, f(x2).lo))
        end
    end

    return minima, arg_minima
end
