__precompile__()

module SortedVectors

import Base: getindex, length, push!, isempty,
        pop!, filter!, popfirst!

export SortedVector

include("StrategyBase.jl")
import .StrategyBase:filter_elements!
using .StrategyBase

struct SortedVector{T, F<:Function} <: Strategy

    data::Vector{T}
    by::F

    function SortedVector(data::Vector{T}, by::F) where {T,F}
        new{T,F}(sort(data, by = by), by)
    end
end

SortedVector(data::Vector{T}) where {T} = SortedVector(data, identity)

function show(io::IO, v::SortedVector)
    print(io, "SortedVector($(v.data))")
end



getindex(v::SortedVector, i::Int) = v.data[i]
length(v::SortedVector) = length(v.data)

function push!(v::SortedVector{T}, x::T) where {T}
    i = searchsortedfirst(v.data, x, by=v.by)
    insert!(v.data, i, x)
    return v
end

isempty(v::SortedVector) = isempty(v.data)

pop!(v::SortedVector) = pop!(v.data)

popfirst!(v::SortedVector) = popfirst!(v.data)

function filter_elements!(v::SortedVector{T}, x::T) where {T}
    cutoff = searchsortedfirst(v.data, x, by=v.by)
    resize!(v.data, cutoff-1)
    return v
end

end
