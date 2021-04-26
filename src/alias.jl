struct AliasSampler{T<:AbstractFloat,SF<:Random.Sampler{T},SI<:Random.Sampler{Int}} <:
       Random.Sampler{Int}
    acceptance::Vector{T}
    aliastable::Vector{Int}
    floatsampler::SF
    integersampler::SI
end

function AliasSampler(
    prediction::AbstractVector{<:Real},
    floatsampler::Random.Sampler{T},
    integersampler::Random.Sampler{Int},
) where {T<:AbstractFloat}
    sum_prediction = sum(prediction)
    sum_prediction ≈ one(sum_prediction) || error("predictions have to be normalized")

    n = length(prediction)
    acceptance = Vector{T}(undef, n)
    aliastable = Vector{Int}(undef, n)
    StatsBase.make_alias_table!(prediction, sum_prediction, acceptance, aliastable)

    return AliasSampler(acceptance, aliastable, floatsampler, integersampler)
end

function Base.rand(rng::Random.AbstractRNG, sampler::AliasSampler)
    idx = rand(rng, sampler.integersampler)
    x = rand(rng, sampler.floatsampler)
    @inbounds r = x < sampler.acceptance[idx] ? idx : sampler.aliastable[idx]
    return r
end
