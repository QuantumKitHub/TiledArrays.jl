@enum BoundaryCondition::UInt8 OBC PBC IBC
const BC = BoundaryCondition

const BoundaryConditions{N} = NTuple{N,BoundaryCondition}
const BCS = BoundaryConditions

struct LatticeRange{BC} <: AbstractUnitRange{Int}
    r::Base.OneTo{Int}
    function LatticeRange{BC}(r::Base.OneTo{Int}) where {BC}
        BC isa BoundaryCondition && return new{BC}(r)
        BC isa Integer && return new{BoundaryCondition(BC)}(r)
        throw(TypeError(:LatticeRange, BoundaryCondition, BC))
    end
end

# utility constructors
function LatticeRange{BC}(r::UnitRange) where {BC}
    isone(first(r)) || throw(ArgumentError("start(r) must be 1"))
    return LatticeRange{BC}(Base.OneTo(last(r)))
end
LatticeRange{BC}(r::Integer) where {BC} = LatticeRange{BC}(Base.OneTo(r))

# type aliases
const OpenRange = LatticeRange{OBC}
const PeriodicRange = LatticeRange{PBC}
const InfiniteRange = LatticeRange{IBC}

boundary_conditions(r::LatticeRange) = boundary_conditions(typeof(r))
boundary_conditions(::Type{LatticeRange{BC}}) where {BC} = BC

# Iteration
# ---------
Base.iterate(r::LatticeRange, state...) = iterate(r.r, state...)
Base.length(r::LatticeRange) = length(r.r)
Base.first(r::LatticeRange) = first(r.r)
Base.last(r::LatticeRange) = last(r.r)
Base.step(r::LatticeRange) = step(r.r)

# AbstractArray
# -------------
Base.axes(r::LatticeRange) = (r,)
Base.size(r::LatticeRange) = (length(r),)

Base.getindex(r::OpenRange, i::Int) = getindex(r.r, i)
Base.getindex(r::PeriodicRange, i::Int) = getindex(r.r, mod1(i, length(r)))
Base.getindex(r::InfiniteRange, i::Int) = getindex(r.r, i)

Base.checkindex(::Type{Bool}, r::OpenRange, i::Int) = checkindex(Bool, r.r, i)
Base.checkindex(::Type{Bool}, r::PeriodicRange, i::Int) = true
Base.checkindex(::Type{Bool}, r::InfiniteRange, i::Int) = true

Base.offsetin(i, r::PeriodicRange) = mod1(i, length(r)) - 1

Base.to_shape(r::LatticeRange) = Base.to_shape(r.r)

# Show
# ----
Base.show(io::IO, r::LatticeRange) = print(io, typeof(r), "($(last(r)))")

# Various fixes
# -------------

# Avoid wrapping in IdentityUnitRange as LatticeRange is already OneTo
Base.axes(S::Base.Slice{<:LatticeRange}) = (S.indices,)
Base.axes1(S::Base.Slice{<:LatticeRange}) = S.indices