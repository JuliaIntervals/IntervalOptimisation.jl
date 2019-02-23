__precompile__()

module HeapedVectors

import Base: getindex, length, push!, isempty,
        pop!, filter!, popfirst!

export HeapedVector

include("StrategyBase.jl")
import .StrategyBase:filter_elements!
using .StrategyBase

struct HeapedVector{T, F<:Function} <: Strategy
    data::Vector{T}
    by::F
    function HeapedVector(v::Vector{T}, by::F) where {T, F}
        new{T, F}(heaping(v, by), by)
    end
end

HeapedVector(data::Vector{T}) where {T} = HeapedVector(data, identity)


function heaping(v, by)
    ar = typeof(v[1])[]
    for i = 1:length(v)
        insert!(ar, i, v[i])
        floatup!(ar, length(ar), by)
    end
    return ar
end

function floatup!(ar, index, by)
    par = convert(Int, floor(index/2))
    if index <= 1
        return ar
    end
    if by(ar[index]) < by(ar[par])
       ar[par], ar[index] = ar[index], ar[par]
    end
    floatup!(ar, par, by)
end


function push!(v::HeapedVector{T}, x::T) where {T}
    insert!(v.data, length(v.data)+1, x)
    floatup!(v.data, length(v.data), v.by)
    return v
end


isempty(v::HeapedVector) = isempty(v.data)


function popfirst!(v::HeapedVector{T}) where {T}
    if length(v.data) == 0
         return
    end

    if length(v.data) > 2
        v.data[length(v.data)], v.data[1] = v.data[1], v.data[length(v.data)]
    	minm = pop!(v.data)
    	bubbledown!(v::HeapedVector{T}, 1)

    elseif length(v.data) == 2
        v.data[length(v.data)], v.data[1] = v.data[1], v.data[length(v.data)]
    	minm = pop!(v.data)
    else
    	minm = pop!(v.data)
    end
    return minm
end


function bubbledown!(v::HeapedVector{T}, index) where{T}
    left = index*2
    right = index*2+1
    smallest = index

    if length(v.data)+1 > left && v.by(v.data[smallest]) > v.by(v.data[left])
        smallest = left
    end

    if length(v.data)+1 > right && v.by(v.data[smallest]) > v.by(v.data[right])
	   smallest = right
    end

    if smallest != index
       v.data[index], v.data[smallest] = v.data[smallest], v.data[index]
	   bubbledown!(v, smallest)
    end
end

function filter_elements!(A::HeapedVector{T}, x::T) where{T}
    func(y) = A.by(y) < A.by(x)
    filter!(func, A.data)

    if length(A.data) == 0
        return A
    end

    ar = heaping(A.data, A.by)
    for i = 1:length(A.data)
        A.data[i] = ar[i]
    end

    return A
end

end
