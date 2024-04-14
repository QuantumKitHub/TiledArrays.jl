module LatticeArrays

# exports
# -------
export BoundaryCondition, OBC, PBC, IBC
export LatticeRange, OpenRange, PeriodicRange, InfiniteRange
export HyperCubicArray, SquareArray, CubeArray, TesseractArray
export boundary_conditions


# imports
# -------

include("axes.jl")
include("hypercube.jl")

end
