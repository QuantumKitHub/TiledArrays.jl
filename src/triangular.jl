struct TriangularMatrix{T,R₁<:Base.OrdinalRangeInt,R₂<:Base.OrdinalRangeInt,R₃<:OrdinalRangeInt} <: AbstractMatrix{T}
    data::Vector{T}
    q_inds::R₁
    r_inds::R₂
    s_inds::R₃
    function TriangularMatrix{T}(data::Vector{T}, q_inds::R₁, r_inds::R₂, s_inds::R₃) where {T, R₁, R₂, R₃}
        @assert length(data) == length(HexagonalIndices(q_inds, r_inds, s_inds)) "Data length does not match indices"
        new{T,R₁,R₂,R₃}(data, q_inds, r_inds, s_inds)
    end
end
