using Pkg

# Activate test environment on older Julia versions
@static if VERSION < v"1.2"
    Pkg.activate(@__DIR__)
    Pkg.develop(PackageSpec(; path=dirname(@__DIR__)))
    Pkg.instantiate()
end

using ConsistencyResampling
using Distributions
using Documenter
using LinearAlgebra
using Random
using StatsBase
using Test

Random.seed!(1234)

# Distributions.jl does not implement the Random API
Random.Sampler(::Type{<:AbstractRNG}, s::Sampleable, ::Val{1}) = s
Random.Sampler(::Type{<:AbstractRNG}, s::Sampleable, ::Val{Inf}) = sampler(s)

@testset "ConsistencyResampling" begin
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
