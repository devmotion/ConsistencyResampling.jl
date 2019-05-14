module ConsistencyResampling

using Bootstrap
using Bootstrap: BootstrapSampling
using StatsBase

using Random

export ConsistentSampling

include("type.jl")
include("bootstrap.jl")
include("utils.jl")

end # module
