struct HyperCubicArray{T,N,B} <: AbstractArray{T,N}
    data::Array{T,N}
    function HyperCubicArray{T,N,B}(data::Array{T,N}) where {T,N,B}
        B isa NTuple{N,BoundaryCondition} || throw(TypeError(:HyperCubicArray, NTuple{N,BoundaryCondition}, B))
        new{T,N,B}(data)
    end
end

const SquareArray{T,B} = HyperCubicArray{T,2,B}
const CubeArray{T,B} = HyperCubicArray{T,3,B}
# don't think this is useful, but I like the name:
const TesseractArray{T,B} = HyperCubicArray{T,4,B}

_default_boundary(N::Int) = ntuple(i -> OBC, N)
boundary_conditions(a::HyperCubicArray) = boundary_conditions(typeof(a))
boundary_conditions(::Type{HyperCubicArray{T,N,B}}) where {T,N,B} = B

# type, dimensionality and boundaries specified
function HyperCubicArray{T,N,B}(::UndefInitializer, dims::Dims{N}) where {T,N,B}
    HyperCubicArray{T,N,B}(Array{T,N}(undef, dims))
end
function HyperCubicArray{T,N,B}(::UndefInitializer, dims::Vararg{Int,N}) where {T,N,B}
    HyperCubicArray{T,N,B}(UndefInitializer(), dims)
end
# type and dimensionality specified
HyperCubicArray{T,N}(args...) where {T,N} = HyperCubicArray{T,N,_default_boundary(N)}(args...)
function HyperCubicArray{T,N}(::UndefInitializer, dims::Vararg{Int,N}) where {T,N}
    HyperCubicArray{T,N}(UndefInitializer(), dims)
end
# only type specified
function HyperCubicArray{T}(::UndefInitializer, dims::Dims{N}) where {T,N}
    HyperCubicArray{T,N}(UndefInitializer(), dims)
end
function HyperCubicArray{T}(::UndefInitializer, dims::Vararg{Int,N}) where {T,N}
    HyperCubicArray{T,N}(UndefInitializer(), dims)
end

# AbstractArray
# -------------
Base.size(a::HyperCubicArray) = size(a.data)
Base.axes(a::HyperCubicArray) = map((sz, bc) -> LatticeRange{bc}(sz), size(a), boundary_conditions(a))

Base.IndexStyle(::Type{<:HyperCubicArray}) = IndexLinear()

@inline function Base.getindex(a::HyperCubicArray, i::Int) 
    @boundscheck checkbounds(a, i)
    i′ = all(isfinite, boundary_conditions(a)) ? i : mod1(i, length(a.data))
    @inbounds return getindex(a.data, i′)
end

@inline function Base.setindex!(a::HyperCubicArray, v, i::Int)
    @boundscheck checkbounds(a, i)
    i′ = all(isfinite, boundary_conditions(a)) ? i : mod1(i, length(a.data))
    @inbounds a.data[i′] = v
    return a
end

Base.eachindex(::IndexLinear, a::HyperCubicArray) = LinearIndices(axes(a))

Base.similar(::HyperCubicArray, ::Type{S}, dims::Dims{N}) where {S,N} = HyperCubicArray{S,N}(undef, dims)
function Base.similar(::Type{<:HyperCubicArray{T}}, inds::Tuple{LatticeRange,Vararg{LatticeRange,N}}) where {T,N}
    B = map(boundary_conditions, inds)
    dims = map(length, inds)
    return HyperCubicArray{T,N+1,B}(undef, dims)
end
