import Documenter

Documenter.makedocs(
    modules = [IntervalOptimisation],
    format = :html,
    sitename = "IntervalOptimisation.jl",
    root = joinpath(dirname(dirname(@__FILE__)), "docs"),
    pages = Any["Home" => "index.md"],
    strict = true,
    linkcheck = true,
    checkdocs = :exports,
    authors = "David Sanders"
)


Documenter.deploydocs(
    repo = "github.com/dpsanders/IntervalOptimisation.jl.git",
    target = "build",
    deps = nothing,
    make = nothing
)
