"""
    TiledArray{T, N, A <: AbstractArray{Int, N}} <: AbstractTiledArray{T, N}

Efficient representation for arrays with repeating elements, according to some given tiling.
Here the tiling is an array of integers of the same size as the tiled array that dictates the position in the data vector.

# Fields

- `data::Vector{T}` : underlying (non-duplicated) data of unique elements
- `tiling::A}` : tiling pattern for specifying the repititions

# Examples

```jldoctest
tiling = [1, 2, 3, 2, 1]
A = TiledArray{Int}([4, 5, 6], tiling)
collect(A)

# output

[4, 5, 6, 5, 4]
```
"""
struct TiledArray{T, N, A <: AbstractArray{Int, N}} <: AbstractTiledArray{T, N}
    data::Vector{T}
    tiling::A

    function TiledArray{T, N}(data::Vector{T}, tiling::Array{Int, N}) where {T, N}
        issetequal(tiling, axes(data, 1)) || throw(ArgumentError("Incompatible data and tiling"))
        return new{T, N}(data, tiling)
    end

    function TiledArray{T, N}(::UndefInitializer, tiling::Array{Int, N}) where {T, N}
        data = Vector{T}(undef, length(unique(tiling)))
        return new{T, N}(data, tiling)
    end
end

function TiledArray{T}(::UndefInitializer, tiling::Array{Int,N}) where {T,N}
    return TiledArray{T, N}(undef, tiling)
end

# Indexing
# --------

Base.size(A::TiledArray) = size(A.tiling)

Base.IndexStyle(::Type{A}) where {A <: TiledArray} = IndexLinear()

@inline function Base.getindex(A::TiledArray, i::Int)
    @boundscheck checkbounds(A, i)
    return @inbounds A.data[A.tiling[i]]
end
@inline function Base.setindex!(A::TiledArray, v, i::Int)
    @boundscheck checkbounds(A, i)
    @inbounds setindex!(A.data, v, A.tiling[i])
    return A
end

function Base.checkbounds(::Type{Bool}, A::TiledArray, i::Int)
    return checkbounds(Bool, A.tiling, i) && checkbounds(Bool, A.data, @inbounds(A.tiling[i]))
end
