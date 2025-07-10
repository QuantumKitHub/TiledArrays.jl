module TiledArrays

export AbstractTiledArray, PeriodicArray, TiledArray
export tiling, tilinglength
export eachtilingindex
export tiledmap

"""
    AbstractTiledArray{T,N} <: AbstractArray{T,N}

Abstract supertype for all arrays that have some form of tiling, ie repeated structure
along their axes.
"""
abstract type AbstractTiledArray{T, N} <: AbstractArray{T, N} end

tiling(A::AbstractArray) = LinearIndices(A)
tiling(A::AbstractTiledArray) = throw(MethodError(tiling, A))

tilingdata(A::AbstractArray) = A

tilinglength(A) = length(tilingdata(A))

eachtilingindex(A) = eachtilingindex(IndexStyle(A), A)
function eachtilingindex(::IndexLinear, A)
    tile = tiling(A)
    inds = collect(keytype(tile), indexin(1:tilinglength(A), tile))
    eltype(inds) isa Int && return inds
    linear = LinearIndices(A)
    return linear[inds]
end
function eachtilingindex(::IndexCartesian, A)
    tile = tiling(A)
    inds = collect(keytype(tile), indexin(1:tilinglength(A), tile))
    eltype(inds) isa CartesianIndex && return inds
    cartesian = CartesianIndices(A)
    return cartesian[inds]
end

include("periodicarray.jl")
include("tiledarray.jl")

end
