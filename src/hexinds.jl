struct IndexHexagonal <: IndexStyle end

Base._maybe_reshape(::IndexHexagonal, A::AbstractArray, I...) = A

struct HexagonalIndex
    q::Int
    r::Int
    s::Int
    function HexagonalIndex(q::Int, r::Int, s::Int=-(q+r))
        @assert q + r + s == 0 "Invalid Hexagonal Index"
        new(q, r, s)
    end
end

# function Base.getproperty(h::HexagonalIndex, prop::Symbol)
#     prop === :s && return -(h.q + h.r)
#     return getfield(h, prop)
# end

function Base.getindex(h::HexagonalIndex, i::Int)
    i == 1 && return h.q
    i == 2 && return h.r
    i == 3 && return h.s
    throw(BoundsError(h, i))
end

Base.Tuple(h::HexagonalIndex) = (h.q, h.r, h.s)




@inline function Base._getindex(::IndexHexagonal, A::AbstractMatrix{T}, i::Int) where T
    @boundscheck checkbounds(A, i)
    @inbounds r = getindex(A, _to_hex_indices(A, i)...)
    return r
end

# default value for s is -(q+r)
@inline Base._getindex(l::IndexHexagonal, A::AbstractMatrix, q::Int, r::Int) = Base._getindex(l, A, q, r, -(q+r))


# TODO: is there a way to speed this up?
_to_hex_indices(A::AbstractMatrix, i::Int) = _to_hex_indices(A, axes(A), i)
function _to_hex_indices(A::AbstractMatrix, axes::NTuple{3,AbstractUnitRange{Int}}, i::Int)
    q_range, r_range, s_range = axes
    
    for r in r_range, q in q_range
        s = -(q + r)
        s ∈ s_range && (i -= 1)
        i == 1 && return q, r, s
    end
    
    throw(BoundsError(A, i)) # should never get here
end








# there are 4 ways of converting a HexagonalIndex to a CartesianIndex:
# choosing pointy or flat tops, and choosing even or odd offsets.
# we'll default to pointy tops, even offsets
function offset_coordinate(h::HexagonalIndex; style=:pointy, offset=:even)
    if style === :pointy
        if offset === :even
            col = h.q + (h.r + isodd(h.r)) ÷ 2
            row = h.r
        else
            col = h.q + (h.r - isodd(h.r)) ÷ 2
            row = h.r
        end
    else
        if offset === :even
            col = h.q
            row = h.r + (h.q + isodd(h.q)) ÷ 2
        else
            col = h.q
            row = h.r + (h.q - isodd(h.q)) ÷ 2
        end
    end
    return CartesianIndex(row, col)
end

function Base.show(io::IO, h::HexagonalIndex)
    print(io, "HexagonalIndex($(h.q), $(h.r), $(h.s))")
end


# HexagonalIndices
# ----------------

struct HexagonalIndices{Q<:AbstractUnitRange{Int},R<:AbstractUnitRange{Int},S<:AbstractUnitRange{Int}} <: AbstractArray{HexagonalIndex,2}
    q_range::Q
    r_range::R
    s_range::S
end

HexagonalIndices(inds::NTuple{3,Union{Int,AbstractUnitRange{Int}}}) = HexagonalIndices(map(Base._convert2ind, inds)...)

# AbstractArray implementation
# -----------------------------
Base.IndexStyle(::Type{<:HexagonalIndices}) = IndexHexagonal()
Base.axes(h::HexagonalIndices) = (h.q_range, h.r_range, h.s_range)
Base.size(h::HexagonalIndices) = (length(h.q_range), length(h.r_range), length(h.s_range))
function Base.length(h::HexagonalIndices)
    L = 0
    for q in h.q_range, r in h.r_range
        s = -(q + r)
        s ∈ h.s_range && (L += 1)
    end
    return L
end

@inline function Base.getindex(h::HexagonalIndices, q::Int, r::Int, s::Int=-(q+r))
    @boundscheck checkbounds(h, q, r, s)
    return HexagonalIndex(q, r)
end

function Base.isassigned(h::HexagonalIndices, q::Int, r::Int, s::Int=-(q+r))
    return checkbounds(Bool, h, q, r, s)
end
