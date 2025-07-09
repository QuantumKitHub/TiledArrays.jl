using TiledArrays
using Test

@testset "Indexing" begin
    tiling = [1, 2, 1, 2]
    A = TiledArray{Float64, 1}(rand(2), tiling)
    @test A[1] == A[3]
    @test A[2] == A[4]
    @test_throws BoundsError A[5]
    A[2] = 1
    @test A[2] == convert(Float64, 1)

    A[1] = 1.0
    @test A[1] == 1.0
    @test A[3] == 1.0

    tiling = [1 2; 2 1]
    A = TiledArray{Int}(undef, tiling)
    A[1] = 1
    A[2] = 2
    @test A[3] == A[2]
    @test A[4] == A[1]
    @test A[1, 1] == A[2, 2] == 1
    @test A[2, 1] == A[1, 2] == 2
    @test_throws BoundsError A[0]
    @test_throws BoundsError A[0] = 1
    @test_throws BoundsError A[3, 1]
    @test_throws BoundsError A[3, 1] = 3
    @test_throws BoundsError A[1, 2, 3]
    @test_throws BoundsError A[1, 2, 3] = 1
end
