struct IntervalMinimum{T<:Real}
    interval::Interval{T}
    minimum::T
end

Base.isless(a::IntervalMinimum{T}, b::IntervalMinimum{T}) where {T<:Real} = isless(a.minimum, b.minimum)

function minimise1d(f::Function, x::Interval{T}; reltol=1e-3, abstol=1e-3, use_deriv=false, use_second_deriv=false) where {T<:Real}

    Q = binary_minheap(IntervalMinimum{T})

    global_minimum = f(interval(mid(x))).hi

    arg_minima = Interval{T}[]

    push!(Q, IntervalMinimum(x, global_minimum))

    while !isempty(Q)

        p = pop!(Q)

        if isempty(p.interval)
            continue
        end

        if p.minimum > global_minimum
            continue
        end

        if use_deriv
            deriv = ForwardDiff.derivative(f, p.interval)
            if 0 ∉ deriv
                continue
            end
        end

        # Second derivative contractor
        if use_second_deriv
            doublederiv = ForwardDiff.derivative(x->ForwardDiff.derivative(f, x), p.interval)
            if doublederiv < 0
                continue
            end
        end

        m = mid(p.interval)
        current_minimum = f(interval(m)).hi

        if current_minimum < global_minimum
            global_minimum = current_minimum
        end


        # Contractor 1
        if use_deriv
            x = m .+ extended_div((interval(-∞, global_minimum) - f(m)), deriv)

            x = x .∩ p.interval
        end

        if diam(p.interval) < abstol
            push!(arg_minima, p.interval)
        else

            if use_deriv && isempty(x[2])
                x1, x2 = bisect(x[1])
                push!(Q, IntervalMinimum(x1, f(x1).lo), IntervalMinimum(x2, f(x2).lo))
                continue
            end

            x1, x2 = bisect(p.interval)
            push!(Q, IntervalMinimum(x1, f(x1).lo), IntervalMinimum(x2, f(x2).lo))
        end
    end
    lb = minimum(inf.(f.(arg_minima)))

    return lb..global_minimum, arg_minima
end


struct IntervalBoxMinimum{N, T<:Real}
    interval::IntervalBox{N, T}
    minimum::T
end

"""
Datatype to provide constraints to Global Optimisation such as:
```
Constraint(x->(x^2 - 10), -∞..1)
```
"""
struct Constraint{T<:Real}
    f::Function
    c::Interval{T}
end

Base.isless(a::IntervalBoxMinimum{N, T}, b::IntervalBoxMinimum{N, T}) where {N, T<:Real} = isless(a.minimum, b.minimum)

function minimise_icp(f::Function, x::IntervalBox{N, T}; reltol=1e-3, abstol=1e-3) where {N, T<:Real}

    Q = binary_minheap(IntervalBoxMinimum{N, T})

    global_minimum = ∞

    x = icp(f, x, -∞..global_minimum)

    arg_minima = IntervalBox{N, T}[]

    push!(Q, IntervalBoxMinimum(x, global_minimum))

    while !isempty(Q)

        p = pop!(Q)

        if isempty(p.interval)
            continue
        end

        if p.minimum > global_minimum
            continue
        end

        current_minimum = sup(f(interval.(mid(p.interval))))

        if current_minimum < global_minimum
            global_minimum = current_minimum
        end

        X = icp(f, p.interval, -∞..global_minimum)

        if diam(p.interval) < abstol
            push!(arg_minima, p.interval)

        else
            x1, x2 = bisect(X)
            push!(Q, IntervalBoxMinimum(x1, f(x1).lo), IntervalBoxMinimum(x2, f(x2).lo))
        end
    end

    #@show arg_minima

    lb = minimum(inf.(f.(arg_minima)))

    return lb..global_minimum, arg_minima
end

function minimise_icp_constrained(f::Function, x::IntervalBox{N, T}, constraints::Vector{Constraint{T}} = Vector{Constraint{T}}(); reltol=1e-3, abstol=1e-3) where {N, T<:Real}

    Q = binary_minheap(IntervalBoxMinimum{N, T})

    global_minimum = ∞

    for t in constraints
        x = icp(t.f, x, t.c)
    end

    x = icp(f, x, -∞..global_minimum)

    arg_minima = IntervalBox{N, T}[]

    push!(Q, IntervalBoxMinimum(x, global_minimum))

    while !isempty(Q)

        p = pop!(Q)

        if isempty(p.interval)
            continue
        end

        if p.minimum > global_minimum
            continue
        end

        # current_minimum = f(interval.(mid(p.interval))).hi
        current_minimum = f(p.interval).hi

        if current_minimum < global_minimum
            global_minimum = current_minimum
        end

        X = icp(f, p.interval, -∞..global_minimum)

        for t in constraints
            X = icp(t.f, X, t.c)
        end

        if diam(p.interval) < abstol
            push!(arg_minima, p.interval)
        else
            x1, x2 = bisect(X)
            push!(Q, IntervalBoxMinimum(x1, f(x1).lo), IntervalBoxMinimum(x2, f(x2).lo))
        end
    end
    lb = minimum(inf.(f.(arg_minima)))
    return lb..global_minimum, arg_minima
end
