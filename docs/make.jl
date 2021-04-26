using Documenter

# Print `@debug` statements (https://github.com/JuliaDocs/Documenter.jl/issues/955)
if haskey(ENV, "GITHUB_ACTIONS")
    ENV["JULIA_DEBUG"] = "Documenter"
end

using ConsistencyResampling

DocMeta.setdocmeta!(
    ConsistencyResampling, :DocTestSetup, :(using ConsistencyResampling); recursive=true
)

makedocs(;
    modules=[ConsistencyResampling],
    authors="David Widmann",
    repo="https://github.com/devmotion/ConsistencyResampling.jl/blob/{commit}{path}#{line}",
    sitename="ConsistencyResampling.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://devmotion.github.io/ConsistencyResampling.jl",
        assets=String[],
    ),
    pages=["Home" => "index.md", "supported.md"],
    strict=true,
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/devmotion/ConsistencyResampling.jl",
    push_preview=true,
    devbranch="main",
)
