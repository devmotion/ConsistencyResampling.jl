@testset "single.jl" begin
    @testset "probabilities" begin
        probs = rand(10)
        consistent = Consistent(probs)
        sampler = Random.Sampler(Random.GLOBAL_RNG, consistent, Val(1))
        @test sampler isa Random.SamplerTrivial{<:Consistent{Float64,Bool}}

        # single sample
        for spl in (consistent, sampler)
            sample = @inferred(rand(spl))
            @test sample isa Tuple{Float64,Bool}
            @test first(sample) in probs
        end

        # multiple samples
        samples_oop = @inferred(rand(sampler, 100_000))
        @test samples_oop isa Vector{Tuple{Float64,Bool}}
        @test length(samples_oop) == 100_000
        samples_iip = similar(samples_oop)
        rand!(samples_iip, sampler)

        for samples in (samples_oop, samples_iip)
            @test all(first(s) in probs for s in samples)

            for prob in probs
                @test count(s -> first(s) == prob, samples) ≈ 10_000 atol = 300
                @test mean(t for (p, t) in samples if p == prob) ≈ prob atol = 2e-2
            end
        end
    end

    @testset "categorical" begin
        predictions = map(1:10) do _
            prediction = rand(5)
            lmul!(inv(sum(prediction)), prediction)
            return prediction
        end
        consistent = Consistent(predictions)
        sampler = Random.Sampler(Random.GLOBAL_RNG, consistent, Val(1))
        @test sampler isa Random.SamplerTrivial{<:Consistent{Vector{Float64},Int}}

        # single sample
        for spl in (consistent, sampler)
            sample = @inferred(rand(spl))
            @test sample isa Tuple{Vector{Float64},Int}
            @test first(sample) in predictions
            @test 1 ≤ last(sample) ≤ 5
        end

        # multiple samples
        samples_oop = @inferred(rand(sampler, 100_000))
        @test samples_oop isa Vector{Tuple{Vector{Float64},Int}}
        @test length(samples_oop) == 100_000
        samples_iip = similar(samples_oop)
        rand!(samples_iip, sampler)

        for samples in (samples_oop, samples_iip)
            @test all(first(s) in predictions for s in samples)
            @test all(1 ≤ last(s) ≤ 5 for s in samples)

            for prediction in predictions
                @test count(s -> first(s) == prediction, samples) ≈ 10_000 atol = 300
                @test proportions([t for (p, t) in samples if p == prediction], 1:5) ≈ prediction atol =
                    2e-2
            end
        end
    end

    @testset "Distributions" begin
        predictions = map(Normal, randn(10), rand(10))
        consistent = Consistent(predictions)
        sampler = Random.Sampler(Random.GLOBAL_RNG, consistent, Val(1))
        @test sampler isa Random.SamplerTrivial{<:Consistent{Normal{Float64},Float64}}

        # single sample
        for spl in (consistent, sampler)
            sample = @inferred(rand(spl))
            @test sample isa Tuple{Normal{Float64},Float64}
            @test first(sample) in predictions
        end

        # multiple samples
        samples_oop = @inferred(rand(sampler, 100_000))
        @test samples_oop isa Vector{Tuple{Normal{Float64},Float64}}
        @test length(samples_oop) == 100_000
        samples_iip = similar(samples_oop)
        rand!(samples_iip, sampler)

        for samples in (samples_oop, samples_iip)
            @test all(first(s) in predictions for s in samples)

            for prediction in predictions
                @test count(s -> first(s) == prediction, samples) ≈ 10_000 atol = 300
                @test mean(t for (p, t) in samples if p == prediction) ≈ mean(prediction) atol =
                    2e-2
                @test std(t for (p, t) in samples if p == prediction) ≈ std(prediction) atol =
                    2e-2
            end
        end
    end
end
