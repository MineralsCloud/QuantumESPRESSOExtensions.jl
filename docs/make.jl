using QuantumESPRESSOExtensions
using Documenter

DocMeta.setdocmeta!(QuantumESPRESSOExtensions, :DocTestSetup, :(using QuantumESPRESSOExtensions); recursive=true)

makedocs(;
    modules=[QuantumESPRESSOExtensions],
    authors="singularitti <singularitti@outlook.com> and contributors",
    repo="https://github.com/MineralsCloud/QuantumESPRESSOExtensions.jl/blob/{commit}{path}#{line}",
    sitename="QuantumESPRESSOExtensions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MineralsCloud.github.io/QuantumESPRESSOExtensions.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MineralsCloud/QuantumESPRESSOExtensions.jl",
    devbranch="main",
)
