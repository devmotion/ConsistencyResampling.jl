# Supported predictions

This page explains three supported types of predictions.

## Probabilities

If the predictions are provided as a vector of probabilities, they correspond to a set of
Bernoulli distributions with these parameters. Accordingly, the synthetic targets will
be boolean values (`true` if the predicted outcome occurs, `false` if not).

We define a vector of 100 randomly sampled probabilities.

```@example probabilities
using ConsistencyResampling
using Random #hide
Random.seed!(1234) #hide

probabilities = rand(100)
nothing #hide
```

Consistency resampling yields a tuple consisting of a randomly sampled probability and a
sample from the corresponding Bernoulli distribution.

```@example probabilities
probability, target = rand(Consistent(probabilities))
```

```@example probabilities
probability in probabilities
```

Multiple samples are returned as a vector of tuples.

```@example probabilities
rand(Consistent(probabilities), 10)
```

## Vectors of probabilities

If the predictions are vectors of real-valued vectors, they correspond to the class
probabilities of categorical distributions. In this case, the targets will be `1,…,m`
where the number of classes `m` is given by the length of the real-valued vectors.

We generate 100 randomly sampled vectors of probabilities for `m = 5` classes.

```@example categorical
using ConsistencyResampling
using Random #hide
Random.seed!(1234) #hide

predictions = map(1:100) do _
    x = rand(5)
    x ./= sum(x)
    return x
end
nothing #hide
```

Consistency resampling returns a tuple of a randomly sampled prediction and a
sample from the corresponding categorical distribution.

```@example categorical
prediction, target = rand(Consistent(predictions))
```

```@example categorical
prediction in predictions
```

## Vectors of distributions

Additionally, predictions can be provided as a vector of distributions. These distributions
have to support the [Random API](https://docs.julialang.org/en/v1/stdlib/Random/). More
precisely,
```julia
Random.Sampler(::Type{<:Random.AbstractRNG}, ::MyDistributionType, ::Random.Repetition)
```
must be defined and it must be possible to sample from the resulting samplers with `rand`.
More information about the interface can be found in the
[documentation of Random](https://docs.julialang.org/en/v1/stdlib/Random/).

We define vector of 100 normal distributions with randomly sampled mean and standard deviation.

```@example distribution
using ConsistencyResampling
using Distributions
using Random #hide
Random.seed!(1234) #hide

predictions = map(Normal, randn(100), rand(100))
nothing #hide
```

Unfortunately, currently Distributions does not define `Random.Sampler` and therefore we have
to implement it to be able to perform consistency resampling:

```@example distribution
using Random

Random.Sampler(::Type{<:AbstractRNG}, s::Sampleable, ::Val{1}) = s
Random.Sampler(::Type{<:AbstractRNG}, s::Sampleable, ::Val{Inf}) = sampler(s)
```

Consistency resampling yields a randomly sampled prediction and a sample from it.

```@example distribution
prediction, target = rand(Consistent(predictions))
```

```@example distribution
prediction in predictions
```
