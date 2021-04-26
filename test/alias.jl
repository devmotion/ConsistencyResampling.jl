@testset "alias.jl" begin
    prediction = rand(5)
    lmul!(inv(sum(prediction)), prediction)
    sampler = @inferred(
        ConsistencyResampling.AliasSampler(
            prediction,
            Random.Sampler(Random.GLOBAL_RNG, Float64),
            Random.Sampler(Random.GLOBAL_RNG, 1:5),
        ),
    )
    samples = @inferred(rand(sampler, 100_000))
    @test samples isa Vector{Int}
    @test all(1 ≤ s ≤ 5 for s in samples)
    @test proportions(samples, 1:5) ≈ prediction rtol = 1e-2

    # special cases
    for prediction in ([1.0, 0.0], [0.0, 1.0], [0.0, 1.0, 0.0], [0.5, 0.0, 0.5])
        n = length(prediction)
        sampler = @inferred(
            ConsistencyResampling.AliasSampler(
                prediction,
                Random.Sampler(Random.GLOBAL_RNG, Float64),
                Random.Sampler(Random.GLOBAL_RNG, 1:n),
            ),
        )
        samples = @inferred(rand(sampler, 100_000))
        @test samples isa Vector{Int}
        @test all(1 ≤ s ≤ n for s in samples)
        @test all(!iszero(prediction[s]) for s in samples)
        @test proportions(samples, 1:n) ≈ prediction rtol = 1e-2
    end
end
