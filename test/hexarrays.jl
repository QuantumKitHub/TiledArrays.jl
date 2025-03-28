using Revise

Revise.includet("../src/hexarray.jl")

using .HexArrays

A = RectangleHexArray{Int}(undef, 3, 3)

fill!(A, 1)