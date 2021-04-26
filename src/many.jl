function Random.Sampler(T::Type{<:Random.AbstractRNG}, x::Consistent, ::Val{Inf})
    # sampler for sampling indices of predictions
    predictions = x.predictions
    idxsampler = Random.Sampler(T, eachindex(predictions))
    return Random.SamplerSimple(x, (idxsampler, make_samplers(T, x)))
end

function make_samplers(T::Type{<:Random.AbstractRNG}, x::Consistent{<:Real})
    return Random.Sampler(T, float(eltype(x.predictions)))
end

# set up alias samplers
function make_samplers(
    T::Type{<:Random.AbstractRNG}, x::Consistent{<:AbstractVector{<:Real}}
)
    predictions = x.predictions
    prediction = first(predictions)
    floatsampler = Random.Sampler(T, float(eltype(prediction)))
    integersampler = Random.Sampler(T, Base.OneTo(length(prediction)))
    samplers = let floatsampler = floatsampler, integersampler = integersampler
        map(predictions) do prediction
            return AliasSampler(prediction, floatsampler, integersampler)
        end
    end
    return samplers
end

function make_samplers(T::Type{<:Random.AbstractRNG}, x::Consistent)
    samplers = let T = T
        map(x.predictions) do prediction
            return Random.Sampler(T, prediction)
        end
    end
    return samplers
end

# out-of-place sampling
function Base.rand(
    rng::Random.AbstractRNG, sampler::Random.SamplerSimple{<:Consistent{<:Real}}
)
    idxsampler, floatsampler = sampler.data
    idx = rand(rng, idxsampler)
    @inbounds prediction = sampler[].predictions[idx]
    @inbounds target = rand(rng, floatsampler) < prediction
    return (prediction, target)
end
function Base.rand(rng::Random.AbstractRNG, sampler::Random.SamplerSimple{<:Consistent})
    idxsampler, samplers = sampler.data
    idx = rand(rng, idxsampler)
    @inbounds prediction = sampler[].predictions[idx]
    @inbounds target = rand(rng, samplers[idx])
    return (prediction, target)
end

# in-place sampling
function Random.rand!(
    rng::Random.AbstractRNG,
    out::AbstractArray{<:Tuple{<:Any,<:Any}},
    sampler::Random.SamplerSimple{<:Consistent{<:Real}},
)
    predictions = sampler[].predictions
    idxsampler, floatsampler = sampler.data
    for i in eachindex(out)
        idx = rand(rng, idxsampler)
        @inbounds prediction = predictions[idx]
        @inbounds target = rand(rng, floatsampler) < prediction
        @inbounds out[i] = (prediction, target)
    end
    return out
end
function Random.rand!(
    rng::Random.AbstractRNG,
    out::AbstractArray{<:Tuple{<:Any,<:Any}},
    sampler::Random.SamplerSimple{<:Consistent},
)
    predictions = sampler[].predictions
    idxsampler, samplers = sampler.data
    for i in eachindex(out)
        idx = rand(rng, idxsampler)
        @inbounds prediction = predictions[idx]
        @inbounds target = rand(rng, samplers[idx])
        @inbounds out[i] = (prediction, target)
    end
    return out
end
