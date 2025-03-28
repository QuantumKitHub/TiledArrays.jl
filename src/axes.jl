@enum BoundaryCondition::UInt8 OBC PBC IBC SBC
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
const SpiralRange = LatticeRange{SBC}

boundary_conditions(r::LatticeRange) = boundary_conditions(typeof(r))
boundary_conditions(::Type{LatticeRange{BC}}) where {BC} = BC

Base.isfinite(bc::BoundaryCondition) = bc === OBC || bc === SBC

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
Base.getindex(r::SpiralRange, i::Int) = getindex(r.r, mod1(i, length(r)))

Base.checkindex(::Type{Bool}, r::LatticeRange, i::Int) = boundary_conditions(r) !== OBC || checkindex(Bool, r.r, i)

Base.offsetin(i, r::PeriodicRange) = mod1(i, length(r)) - 1
# Base.offsetin(i, r::InfiniteRange) = mod1(i, length(r)) - 1
Base.offsetin(i, r::SpiralRange) = mod1(i, length(r)) - 1

Base.to_shape(r::LatticeRange) = Base.to_shape(r.r)

# Show
# ----
Base.show(io::IO, r::LatticeRange) = print(io, typeof(r), "($(last(r)))")

# Various fixes
# -------------

# Avoid wrapping in IdentityUnitRange as LatticeRange is already OneTo
Base.axes(S::Base.Slice{<:LatticeRange}) = (S.indices,)
Base.axes1(S::Base.Slice{<:LatticeRange}) = S.indices

# make sure checkbounds works with LinearIndices?
Base.checkindex(::Type{Bool}, linds::LinearIndices, i) = checkbounds(Bool, linds, i)

# make sure sub2ind works with spiral stuff
Base.@inline function Base._sub2ind_recurse(inds::Tuple{SpiralRange,Any,Vararg{Any}}, L, ind, i::Integer, I1::Integer, I::Integer...)
    r1 = inds[1]
    i1 = mod1(i, length(r1))
    i2 = div(i, length(r1))
    i1 == length(r1) && (i2 -= 1;)
    Base._sub2ind_recurse(Base.tail(inds), Base.nextL(L, r1), ind + (i1-1) * L, I1 + i2, I...)
end