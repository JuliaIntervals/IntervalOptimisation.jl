using IntervalRootFinding, IntervalArithmetic, StaticArrays, ForwardDiff, BenchmarkTools, Compat, IntervalOptimisation, DataStructures, IntervalConstraintProgramming

import Base.isless

struct IntervalMinima{T<:Real}
    intval::Interval{T}
    global_minimum::T
end

function isless(a::IntervalMinima{T}, b::IntervalMinima{T}) where {T<:Real}
    return isless(a.global_minimum, b.global_minimum)
end

function minimise1d(f::Function, x::Interval{T}; reltol=1e-3, abstol=1e-3) where {T<:Real}

    Q = binary_minheap(IntervalMinima{T})

    global_minimum = f(interval(mid(x))).hi

    arg_minima = Interval{T}[]

    push!(Q, IntervalMinima(x, global_minimum))

    while !isempty(Q)

        p = pop!(Q)

        if isempty(p.intval)
            continue
        end

        if p.global_minimum > global_minimum
            continue
        end

        current_minimum = f(interval(mid(p.intval))).hi

        if current_minimum < global_minimum
            global_minimum = current_minimum
        end

        if diam(p.intval) < abstol
            push!(arg_minima, p.intval)
        else
            x1, x2 = bisect(p.intval)
            push!(Q, IntervalMinima(x1, f(x1).lo), IntervalMinima(x2, f(x2).lo))
        end
    end
    lb = minimum(inf.(f.(arg_minima)))

    return lb..global_minimum, arg_minima
end

function minimise1d_deriv(f::Function, x::Interval{T}; reltol=1e-3, abstol=1e-3) where {T<:Real}

    Q = binary_minheap(IntervalMinima{T})

    global_minimum = f(interval(mid(x))).hi

    arg_minima = Interval{T}[]

    push!(Q, IntervalMinima(x, global_minimum))

    while !isempty(Q)

        p = pop!(Q)

        if isempty(p.intval)
            continue
        end

        if p.global_minimum > global_minimum
            continue
        end

        deriv = ForwardDiff.derivative(f, p.intval)
        if 0 ∉ deriv
            continue
        end
        # Second derivative contractor
        # doublederiv = ForwardDiff.derivative(x->ForwardDiff.derivative(f, x), p.intval)
        # if doublederiv < 0
        #     continue
        # end

        m = mid(p.intval)

        current_minimum = f(interval(m)).hi

        if current_minimum < global_minimum
            global_minimum = current_minimum
        end


        # Contractor 1
        x = m .+ extended_div((interval(-∞, global_minimum) - f(m)), deriv)

        x = x .∩ p.intval

        # # Contractor 2 (Second derivative, expanding more on the Taylor Series, not beneficial in practice)
        # x = m .+ quadratic_roots(doublederiv/2, ForwardDiff.derivative(f, interval(m)), f(m) - interval(-∞, global_minimum))
        #
        # x = x .∩ p.intval

        if diam(p.intval) < abstol
            push!(arg_minima, p.intval)
        else
            if isempty(x[2])
                x1, x2 = bisect(x[1])
                push!(Q, IntervalMinima(x1, f(x1).lo), IntervalMinima(x2, f(x2).lo))
            else
                push!(Q, IntervalMinima.(x, inf.(f.(x)))...)
            end

            # Second Deriv contractor
            # if isempty(x[2])
            #     x1, x2 = bisect(x[1])
            #     push!(Q, IntervalMinima(x1, f(x1).lo), IntervalMinima(x2, f(x2).lo))
            # else
            #     x1, x2, x3 = x
            #     push!(Q, IntervalMinima(x1, f(x1).lo), IntervalMinima(x2, f(x2).lo), IntervalMinima(x3, f(x3).lo))
            # end
        end
    end
    lb = minimum(inf.(f.(arg_minima)))

    return lb..global_minimum, arg_minima
end




struct IntervalBoxMinima{N, T<:Real}
    intval::IntervalBox{N, T}
    global_minimum::T
end

struct constraint{T<:Real}
    f::Function
    c::Interval{T}
end

function isless(a::IntervalBoxMinima{N, T}, b::IntervalBoxMinima{N, T}) where {N, T<:Real}
    return isless(a.global_minimum, b.global_minimum)
end

function minimise_icp(f::Function, x::IntervalBox{N, T}; reltol=1e-3, abstol=1e-3) where {N, T<:Real}

    Q = binary_minheap(IntervalBoxMinima{N, T})

    global_minimum = ∞

    x = icp(f, x, -∞..global_minimum)

    arg_minima = IntervalBox{N, T}[]

    push!(Q, IntervalBoxMinima(x, global_minimum))

    while !isempty(Q)

        p = pop!(Q)

        if isempty(p.intval)
            continue
        end

        if p.global_minimum > global_minimum
            continue
        end

        current_minimum = f(interval.(mid(p.intval))).hi

        if current_minimum < global_minimum
            global_minimum = current_minimum
        end
        # if all(0 .∉ ForwardDiff.gradient(f, p.intval.v))
        #     continue
        # end

        X = icp(f, p.intval, -∞..global_minimum)

        if diam(p.intval) < abstol
            push!(arg_minima, p.intval)

        else
            x1, x2 = bisect(X)
            push!(Q, IntervalBoxMinima(x1, f(x1).lo), IntervalBoxMinima(x2, f(x2).lo))
        end
    end

    lb = minimum(inf.(f.(arg_minima)))

    return lb..global_minimum, arg_minima
end

function minimise_icp_constrained(f::Function, x::IntervalBox{N, T}, constraints::Vector{constraint{T}} = Vector{constraint{T}}(); reltol=1e-3, abstol=1e-3) where {N, T<:Real}

    Q = binary_minheap(IntervalBoxMinima{N, T})

    global_minimum = ∞

    for t in constraints
        x = icp(t.f, x, t.c)
    end

    x = icp(f, x, -∞..global_minimum)

    arg_minima = IntervalBox{N, T}[]

    push!(Q, IntervalBoxMinima(x, global_minimum))

    while !isempty(Q)

        p = pop!(Q)

        if isempty(p.intval)
            continue
        end

        if p.global_minimum > global_minimum
            continue
        end

        # current_minimum = f(interval.(mid(p.intval))).hi
        current_minimum = f(p.intval).hi

        if current_minimum < global_minimum
            global_minimum = current_minimum
        end
        # if 0 .∉ ForwardDiff.gradient(f, p.intval.v)
        #     continue
        # end
        X = icp(f, p.intval, -∞..global_minimum)

        for t in constraints
            X = icp(t.f, X, t.c)
        end

        if diam(p.intval) < abstol
            push!(arg_minima, p.intval)
        else
            x1, x2 = bisect(X)
            push!(Q, IntervalBoxMinima(x1, f(x1).lo), IntervalBoxMinima(x2, f(x2).lo))
        end
    end
    lb = minimum(inf.(f.(arg_minima)))
    return lb..global_minimum, arg_minima
end
