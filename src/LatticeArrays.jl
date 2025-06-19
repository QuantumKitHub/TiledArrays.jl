module LatticeArrays

export AbstractTiledArray, TiledArray

"""
    AbstractTiledArray{T,N} <: AbstractArray{T,N}

Abstract supertype for all arrays that have some form of tiling, ie repeated structure
along their axes.
"""
abstract type AbstractTiledArray{T,N} <: AbstractArray{T,N} end

include("tiledarray.jl")

end
