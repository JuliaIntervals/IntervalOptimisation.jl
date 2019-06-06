using Documenter
using IntervalArithmetic, IntervalOptimisation

makedocs(
    modules = [IntervalOptimisation],
    format = Documenter.HTML(),
    sitename = "IntervalOptimisation.jl",
    pages = Any["Home" => "index.md"],
    authors = "David Sanders"
)


Documenter.deploydocs(
    repo = "github.com/JuliaIntervals/IntervalOptimisation.jl.git",
    target = "build",
    deps = nothing,
    make = nothing
)
