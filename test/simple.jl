using ConsistencyResampling, Bootstrap
using Random

Random.seed!(1234)

@testset "Simple example" begin
    predictions = reshape([1, 0], 2, 1)
    labels = [2]

    b = bootstrap((x, y) -> y, predictions, labels, ConsistentSampling(20))

    @test data(b) == (predictions, labels)
    @test original(b) == (2,)
    @test straps(b) == (ones(Int, 20),)
end
