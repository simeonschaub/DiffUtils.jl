using DiffUtils
using Documenter

DocMeta.setdocmeta!(DiffUtils, :DocTestSetup, :(using DiffUtils); recursive=true)

makedocs(;
    modules=[DiffUtils],
    authors="Simeon Schaub <simeondavidschaub99@gmail.com> and contributors",
    repo="https://github.com/simeonschaub/DiffUtils.jl/blob/{commit}{path}#L{line}",
    sitename="DiffUtils.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://simeonschaub.github.io/DiffUtils.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/simeonschaub/DiffUtils.jl",
    devbranch="main",
)
