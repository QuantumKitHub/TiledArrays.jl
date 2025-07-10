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

    function TiledArray{T, N}(data::Vector{T}, tiling::A) where {T, N, A}
        issetequal(tiling, axes(data, 1)) ||
            throw(ArgumentError("Incompatible data and tiling"))
        return new{T, N, A}(data, tiling)
    end

    function TiledArray{T, N}(::UndefInitializer, tiling::A) where {T, N, A}
        data = Vector{T}(undef, length(unique(tiling)))
        return new{T, N, A}(data, tiling)
    end
end

function TiledArray{T}(::UndefInitializer, tiling::AbstractArray{Int, N}) where {T, N}
    return TiledArray{T, N}(undef, tiling)
end
function TiledArray(data::Vector{T}, tiling::AbstractArray{Int, N}) where {T, N}
    return TiledArray{T, N}(data, tiling)
end

const InfiniteTiledArray{T, N} = TiledArray{T, N, PeriodicArray{Int, N, Array{Int, N}}}

function InfiniteTiledArray(A::AbstractArray)
    tiling = PeriodicArray{Int}(undef, size(A))
    copyto!(tiling, 1:length(A))
    C = TiledArray{eltype(A)}(undef, tiling)
    copyto!(C.data, A)
    return C
end
function InfiniteTiledArray(
        data::Vector, tiling::PeriodicArray{Int, N, Array{Int, N}}
    ) where {N}
    return TiledArray{eltype(data), N}(data, tiling)
end
function InfiniteTiledArray{T}(
        ::UndefInitializer, tiling::PeriodicArray{Int, N, Array{Int, N}}
    ) where {T, N}
    return TiledArray{T, N}(undef, tiling)
end

# Indexing
# --------

Base.size(A::TiledArray) = size(A.tiling)

Base.IndexStyle(::Type{T}) where {A, T <: TiledArray{<:Any, <:Any, <:A}} = IndexStyle(A)

# Need to define both linear and cartesian indexing here to support the parent IndexStyle
@inline function Base.getindex(A::TiledArray, i::Int)
    @boundscheck checkbounds(A, i)
    return @inbounds A.data[A.tiling[i]]
end
@inline function Base.getindex(A::TiledArray{T, N}, I::Vararg{Int, N}) where {T, N}
    @boundscheck checkbounds(A, I...)
    return @inbounds A.data[A.tiling[I...]]
end
@inline function Base.setindex!(A::TiledArray, v, i::Int)
    @boundscheck checkbounds(A, i)
    @inbounds setindex!(A.data, v, A.tiling[i])
    return A
end
@inline function Base.setindex!(A::TiledArray{T, N}, v, I::Vararg{Int, N}) where {T, N}
    @boundscheck checkbounds(A, I...)
    @inbounds setindex!(A.data, v, A.tiling[I...])
    return A
end

function Base.checkbounds(::Type{Bool}, A::TiledArray, i::Int)
    return checkbounds(Bool, A.tiling, i) &&
        checkbounds(Bool, A.data, @inbounds(A.tiling[i]))
end
function Base.checkbounds(::Type{Bool}, A::TiledArray{T, N}, I::Vararg{Int, N}) where {T, N}
    return checkbounds(Bool, A.tiling, I...) &&
        checkbounds(Bool, A.data, @inbounds(A.tiling[I...]))
end
