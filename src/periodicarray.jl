"""
    PeriodicArray{T, N, A <: AbstractArray{T, N}} <: AbstractTiledArray{T, N}

Wrapper for an array of type `A` with periodic boundary conditions on the indexes.
This can be understood as an infinitely repeating tiling of the parent array, along all its dimensions.

# Fields

- `data::A`: the wrapped parent array

# Examples

```jldoctest
A = PeriodicArray([1, 2, 3])
A[0], A[2], A[4]

# output

(3, 2, 1)
```
```jldoctest
A = PeriodicArray([1 2; 3 4])
A[-1, 1], A[1, 1], A[4, 5]

# output

(1, 1, 3)
```

See also [`PeriodicVector`](@ref), [`PeriodicMatrix`](@ref)
"""
struct PeriodicArray{T, N, A <: AbstractArray{T, N}} <: AbstractTiledArray{T, N}
    data::A
end
function PeriodicArray{T}(initializer, args...) where {T}
    return PeriodicArray(Array{T}(initializer, args...))
end
function PeriodicArray{T, N}(initializer, args...) where {T, N}
    return PeriodicArray(Array{T, N}(initializer, args...))
end

"""
    PeriodicVector{T}

One-dimensional dense array with elements of type `T` and periodic boundary conditions.
Alias for [`PeriodicArray{T, 1}`](@ref).
"""
const PeriodicVector{T} = PeriodicArray{T, 1, Vector{T}}
PeriodicVector(data::AbstractVector{T}) where {T} = PeriodicVector{T}(data)

"""
    PeriodicMatrix{T}

Two-dimensional dense array with elements of type `T` and periodic boundary conditions.
Alias for [`PeriodicArray{T, 2}`](@ref).
"""
const PeriodicMatrix{T} = PeriodicArray{T, 2, Matrix{T}}
PeriodicMatrix(data::AbstractMatrix{T}) where {T} = PeriodicMatrix{T}(data)

Base.parent(A::PeriodicArray) = A.data

# AbstractArray interface
# -----------------------
Base.size(A::PeriodicArray) = size(parent(A))

@inline function Base.getindex(A::PeriodicArray{T, N}, I::Vararg{Int, N}) where {T, N}
    @boundscheck checkbounds(A, I...)
    return @inbounds getindex(parent(A), map(mod1, I, size(A))...)
end
@inline function Base.setindex!(A::PeriodicArray{T, N}, v, I::Vararg{Int, N}) where {T, N}
    @boundscheck checkbounds(A, I...)
    return @inbounds setindex!(parent(A), v, map(mod1, I, size(A))...)
end

function Base.checkbounds(::Type{Bool}, A::PeriodicArray{T, N}, I::Vararg{Int, N}) where {T, N}
    return checkbounds(Bool, parent(A), map(mod1, I, size(A)))
end
function Base.checkbounds(
        ::Type{Bool}, A::PeriodicArray{T, N, Array{T, N}}, I::Vararg{Int, N}
    ) where {T, N}
    return true
end

Base.LinearIndices(A::PeriodicArray) = PeriodicArray(LinearIndices(parent(A)))
Base.CartesianIndices(A::PeriodicArray) = PeriodicArray(CartesianIndices(parent(A)))

function Base.similar(A::PeriodicArray, ::Type{S}, dims::Dims) where {S}
    return PeriodicArray(similar(parent(A), S, dims))
end

Base.copy(A::PeriodicArray) = PeriodicArray(copy(parent(A)))

function Base.copyto!(dst::PeriodicArray, src::PeriodicArray)
    copyto!(parent(dst), parent(src))
    return dst
end

# Broadcasting
# ------------
Base.BroadcastStyle(::Type{T}) where {T <: PeriodicArray} = Broadcast.ArrayStyle{T}()

function Base.similar(
        bc::Broadcast.Broadcasted{<:Broadcast.ArrayStyle{<:PeriodicArray}}, ::Type{T}
    ) where {T}
    return PeriodicArray(similar(Array{T}, axes(bc)))
end

# Conversion
# ----------
Base.convert(::Type{T}, A::AbstractArray) where {T <: PeriodicArray} = T(A)
Base.convert(::Type{T}, A::PeriodicArray) where {T <: AbstractArray} = convert(T, parent(A))
# fix ambiguities
Base.convert(::Type{T}, A::PeriodicArray) where {T <: PeriodicArray} = A isa T ? A : T(A)
Base.convert(::Type{T}, A::PeriodicArray) where {T <: Array} = convert(T, parent(A))
