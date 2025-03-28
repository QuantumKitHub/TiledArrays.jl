module LatticeArrays

# exports
# -------
export BoundaryCondition, OBC, PBC, IBC, SBC
export HexagonalIndex, HexagonalIndices
export LatticeRange, OpenRange, PeriodicRange, InfiniteRange, SpiralRange
export HyperCubicArray, SquareArray, CubeArray, TesseractArray
export boundary_conditions


# imports
# -------

include("axes.jl")
include("hexinds.jl")
include("hypercube.jl")
include("triangular.jl")

end
