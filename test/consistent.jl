@testset "consistent.jl" begin
    @testset "probabilities" begin
        probs = rand(100)
        c = @inferred(Consistent(probs))
        @test c isa Consistent{Float64,Bool}
        @test c.predictions == probs
        @test eltype(c) === Tuple{Float64,Bool}

        @test_throws ErrorException Consistent(Float64[])
        @test_throws ErrorException Consistent([0.5, prevfloat(0.0)])
        @test_throws ErrorException Consistent([0.1, nextfloat(1.0)])
    end

    @testset "categorical" begin
        predictions = map(1:100) do _
            prediction = rand(5)
            lmul!(inv(sum(prediction)), prediction)
            return prediction
        end
        c = @inferred(Consistent(predictions))
        @test c isa Consistent{Vector{Float64},Int}
        @test c.predictions == predictions
        @test eltype(c) === Tuple{Vector{Float64},Int}

        @test_throws ErrorException Consistent(Vector{Float64}[])
        @test_throws ErrorException Consistent([[0.0, 1.0], [0.1, 0.2]])
    end

    @testset "Distributions" begin
        predictions = map(Normal, randn(100), rand(100))
        c = @inferred(Consistent(predictions))
        @test c isa Consistent{Normal{Float64},Float64}
        @test c.predictions == predictions
        @test eltype(c) === Tuple{Normal{Float64},Float64}

        @test_throws ErrorException Consistent(Normal{Float64}[])
    end
end
