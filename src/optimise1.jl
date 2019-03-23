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



Base.isless(a::IntervalBoxMinimum{N, T}, b::IntervalBoxMinimum{N, T}) where {N, T<:Real} = isless(a.minimum, b.minimum)

function minimise_icp(f::Function, x::IntervalBox{N, T}, var ; reltol=1e-3, abstol=1e-3) where {N, T<:Real}

    Q = binary_minheap(IntervalBoxMinimum{N, T})

    global_minimum = ∞

    variables = []
    for i in var append!(variables, Unknown(i)) end

    f_op = f(variables...)
    C = Contractor(f_op)
    x = C(-∞..global_minimum, x)

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

        current_minimum = f(interval.(mid(p.interval))).hi

        if current_minimum < global_minimum
            global_minimum = current_minimum
        end

        C = Contractor(f_op)
        X = C(-∞..global_minimum, p.interval)

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


struct ConstraintCond{T}
    f ::Operation
    c ::Interval{T}
end


function minimise_icp_constrained(f::Function, x::IntervalBox{N,T}, var, constraints::Vector{ConstraintCond{T}} = Vector{ConstraintCond{T}}(); reltol=1e-3, abstol=1e-3) where {N, T<:Real}

    Q = binary_minheap(IntervalBoxMinimum{N, T})

    global_minimum = ∞

    for t in constraints
        C = Contractor(t.f, var)
        x = C(t.c, x)
    end

    variables = []
    for i in var append!(variables, Unknown(i)) end

    f_op = f(variables...)
    C = Contractor(f_op)
    x = C(-∞..global_minimum, x)

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

        C = Contractor(f_op)
        X = C(-∞..global_minimum, p.interval)

        for t in constraints
            C = Contractor(t.f, var)
            A = Interval(a)
            X = C(A, X)
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
