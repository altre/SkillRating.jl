using Documenter, SkillRating

makedocs(;
    modules=[SkillRating],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/altre/SkillRating.jl/blob/{commit}{path}#L{line}",
    sitename="SkillRating.jl",
    authors="Alan Schelten",
    assets=String[],
)

deploydocs(;
    repo="github.com/altre/SkillRating.jl",
)
