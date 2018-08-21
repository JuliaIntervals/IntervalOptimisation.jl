__precompile__()

module SortedVectors

import Base: getindex, length, push!, isempty,
        pop!, shift!, resize!

export SortedVector

"""
A `SortedVector` behaves like a standard Julia `Vector`, except that its elements are stored in sorted order, with an optional function `by` that determines the sorting order in the same way as `Base.searchsorted`.
"""
struct SortedVector{T, F<:Function}
    data::Vector{T}
    by::F

    function SortedVector{T,F}(data::Vector{T}, by::F) where {T,F}
        new{T,F}(sort(data), by)
    end
end


SortedVector(data::Vector{T}, by::F) where {T,F} = SortedVector{T,F}(data, by)
SortedVector(data::Vector{T}) where {T} = SortedVector{T,typeof(identity)}(data, identity)

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

shift!(v::SortedVector) = shift!(v.data)


function resize!(v::SortedVector, n::Int)
    resize!(v.data, n)
    return v
end

end
