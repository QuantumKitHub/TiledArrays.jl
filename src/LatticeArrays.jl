module LatticeArrays

export AbstractTiledArray, PeriodicArray, TiledArray

"""
    AbstractTiledArray{T,N} <: AbstractArray{T,N}

Abstract supertype for all arrays that have some form of tiling, ie repeated structure
along their axes.
"""
abstract type AbstractTiledArray{T,N} <: AbstractArray{T,N} end

include("periodicarray.jl")
include("tiledarray.jl")

end
