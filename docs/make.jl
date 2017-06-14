import Documenter

Documenter.deploydocs(
    repo = "github.com/dpsanders/IntervalOptimisation.jl.git",
    target = "build",
    deps = nothing,
    make = nothing
)
