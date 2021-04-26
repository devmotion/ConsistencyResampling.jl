```@meta
CurrentModule = ConsistencyResampling
```

# ConsistencyResampling

*Consistency resampling of calibrated predictions*

## Overview

This Julia package contains an implementation of consistency resampling.[^BS07]

Consistency resampling is a resampling technique that generates a calibrated set of predictions and
corresponding targets from a set of predictions. The procedure consists of two steps:
- predictions are resampled with replacement
- synthetic targets are sampled according to the resampled predictions.
This resampling procedure ensures that the predictions are calibrated for the artificial targets.

[^BS07]: Bröcker, J. and Smith, L.A., 2007. [Increasing the reliability of reliability diagrams](https://doi.org/10.1175/WAF993.1). Weather and forecasting, 22(3), pp. 651-661.

## Usage

The API consists only of [`Consistent`](@ref).

```@docs
Consistent
```
