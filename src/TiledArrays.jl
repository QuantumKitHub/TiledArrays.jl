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
    linear = LinearIndices(A)
    return map(1:tilinglength(A)) do i
        ind = findfirst(==(i), tile)
        @assert !isnothing(ind)
        return linear[ind]
    end
end
function eachtilingindex(::IndexCartesian, A)
    tile = tiling(A)
    cartesian = CartesianIndices(A)
    return map(1:tilinglength(A)) do i
        ind = findfirst(==(i), tile)
        @assert !isnothing(ind)
        return cartesian[ind]
    end
end

include("periodicarray.jl")
include("tiledarray.jl")

end
