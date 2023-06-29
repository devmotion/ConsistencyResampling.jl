using ConsistencyResampling
using Aqua
using Distributions
using Documenter
using LinearAlgebra
using Random
using StatsBase
using Test

Random.seed!(1234)

@testset "ConsistencyResampling" begin
    @testset "Aqua tests" begin
        include("aqua.jl")
    end
    @testset "Alias sampler" begin
        include("alias.jl")
    end
    @testset "Consistent" begin
        include("consistent.jl")
    end
    @testset "Sampler (Inf)" begin
        include("many.jl")
    end
    @testset "Sampler (1)" begin
        include("single.jl")
    end

    @testset "doctests" begin
        DocMeta.setdocmeta!(
            ConsistencyResampling,
            :DocTestSetup,
            :(using ConsistencyResampling);
            recursive=true,
        )
        doctest(ConsistencyResampling)
    end
end
