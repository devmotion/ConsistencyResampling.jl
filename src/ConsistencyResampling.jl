module ConsistencyResampling

using StatsBase: StatsBase
using Random: Random

export Consistent

include("alias.jl")
include("consistent.jl")
include("many.jl")
include("single.jl")

end # module
