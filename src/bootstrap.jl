function Bootstrap.bootstrap(statistic,
                             data::Tuple{<:AbstractMatrix{<:Real},AbstractVector{<:Integer}},
                             sampling::ConsistentSampling)
    bootstrap(statistic, Random.GLOBAL_RNG, data, sampling)
end

"""
    bootstrap(statistic[, rng::AbstractRNG = Random.GLOBAL_RNG], data,
              sampling::ConsistentSampling)

Obtain non-parametric bootstrap sample of `statistic` from the `data` set of predictions and
corresponding labels using consistency resampling, i.e., resampling of the labels, with
random number generator `rng.`
"""
function Bootstrap.bootstrap(statistic, rng::AbstractRNG,
                             data::Tuple{<:AbstractMatrix{<:Real},<:AbstractVector{<:Integer}},
                             sampling::ConsistentSampling)
    # check arguments
    predictions, labels = data
    nsamples = size(predictions, 2)
    nsamples == length(labels) ||
        throw(DimensionMismatch("number of predictions and labels must be equal"))

    # evaluate statistic
    t0 = tx(statistic(data))

    # create caches
    weights = [Weights(w) for w in eachcol(predictions)]
    resampled_predictions = similar(predictions)
    resampled_labels = similar(labels)
    resampled_data = (resampled_predictions, resampled_labels)

    # create sampler
    sp = Random.Sampler(rng, Base.OneTo(nsamples))

    # create output
    m = nrun(sampling)
    t1 = zeros_tuple(typeof(t0), m)

    # for each resampling step
    @inbounds for i in 1:m
        # resample predictions and labels
        for j in 1:nsamples
            idx = rand(sp)
            for k in axes(predictions, 1)
                resampled_predictions[k, j] = predictions[k, idx]
            end
            resampled_labels[j] = sample(rng, weights[idx])
        end

        # evaluate statistic
        for (j, t) in enumerate(tx(statistic(resampled_data)))
            t1[j][i] = t
        end
    end

    return NonParametricBootstrapSample(t0, t1, statistic, data, sampling)
end
