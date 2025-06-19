struct TiledArray{T, N} <: AbstractTiledArray{T, N}
    data::Vector{T}
    tiling::Array{Int, N}

    function TiledArray{T, N}(data::Vector{T}, tiling::Array{Int, N}) where {T, N}
        issetequal(tiling, axes(data, 1)) || throw(ArgumentError("Incompatible data and tiling"))
        return new{T, N}(data, tiling)
    end

    function TiledArray{T, N}(::UndefInitializer, tiling::Array{Int, N}) where {T, N}
        data = Vector{T}(undef, length(unique(tiling)))
        return new{T, N}(data, tiling)
    end
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
