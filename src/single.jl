function Base.rand(rng::Random.AbstractRNG, sampler::Random.SamplerTrivial{<:Consistent})
    prediction = rand(rng, sampler[].predictions)
    target = sample_target(rng, prediction)
    return (prediction, target)
end

# in-place sampling
function Random.rand!(
    rng::Random.AbstractRNG,
    out::AbstractArray{<:Tuple{<:Any,<:Any}},
    sampler::Random.SamplerTrivial{<:Consistent},
)
    s = Random.Sampler(rng, sampler[].predictions)
    for i in eachindex(out)
        prediction = rand(rng, s)
        target = sample_target(rng, prediction)
        @inbounds out[i] = (prediction, target)
    end
    return out
end

# sample targets
sample_target(rng::Random.AbstractRNG, sampler) = rand(rng, sampler)
function sample_target(rng::Random.AbstractRNG, prediction::Real)
    return rand(rng, typeof(float(prediction))) < prediction
end
function sample_target(rng::Random.AbstractRNG, prediction::AbstractVector{<:Real})
    return StatsBase.sample(rng, StatsBase.Weights(prediction, one(eltype(prediction))))
end
