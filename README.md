<h1 align="center">
IntervalOptimisation

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaintervals.github.io/IntervalOptimisation.jl/stable)
[![Build Status](https://github.com/JuliaIntervals/IntervalOptimisation.jl/workflows/CI/badge.svg)](https://github.com/JuliaIntervals/IntervalOptimisation.jl/actions/workflows/CI.yml)
[![coverage](https://codecov.io/gh/JuliaIntervals/IntervalOptimisation.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaIntervals/IntervalOptimisation.jl)
</h1>

IntervalOptimisation.jl is a Julia package for rigorous global optimisation routines, using interval arithmetic provided by the [IntervalArithmetic.jl](https://github.com/JuliaIntervals/IntervalArithmetic.jl) package.

Currently, the package uses an implementation of the Moore-Skelboe algorithm.

## Documentation

The official documentation is available online: https://juliaintervals.github.io/IntervalOptimisation.jl/stable.

## Usage

Functions `minimise` and `maximise` are provided to find the **global** minimum or maximum, respectively, of a function `f` of one or several variables.

They return an `Interval` that is guaranteed to contain the global minimum (maximum), and a `Vector` of `Interval`s whose union contains all the minimisers.

### Examples

#### 1D

```julia
using IntervalArithmetic, IntervalOptimisation

julia> global_min, minimisers = minimise(x -> (x^2 - interval(2))^2, interval(-10, 11));

julia> global_min
[0, 1.50881e-09]_com

julia> minimisers
2-element Vector{Interval{Float64}}:
 [-1.41428, -1.41363]_com
  [1.41387, 1.41453]_com
```

#### 2D

```julia
julia> global_min, minimisers = minimise(X -> ( (x,y) = X; x^2 + y^2 ), [interval(-10000, 10001), interval(-10000, 10001)]);

julia> global_min
[0.0, 3.63963e-08]_com

julia> minimisers
3-element Vector{Vector{Interval{Float64}}}:
 [[-0.000412491, 0.00014269]_com, [-0.000412491, 0.00014269]_com]
 [[-0.000412491, 0.00014269]_com, [0.000142689, 0.000706613]_com]
 [[0.000142689, 0.000706613]_com, [-0.000412491, 0.00014269]_com]
```

Note that the last two `Vector` of `Interval`s do not actually contain the global minimum;
decreasing the tolerance (maximum allowed box diameter) removes them:

```
julia> global_min, minimisers = minimise(X -> ( (x,y) = X; x^2 + y^2 ), [interval(-10000, 10001), interval(-10000, 10001)]; tol = 1e-8);

julia> minimisers
1-element Vector{Vector{Interval{Float64}}}:
 [[-4.74512e-09, 4.41017e-09]_com, [-4.74512e-09, 4.41017e-09]_com]
 ```

## References

- *Validated Numerics: A Short Introduction to Rigorous Computations*, W. Tucker, Princeton University Press (2010)

- *Applied Interval Analysis*, Luc Jaulin, Michel Kieffer, Olivier Didrit, Eric Walter (2001)

- van Emden M.H., Moa B. (2004). Termination Criteria in the Moore-Skelboe Algorithm for Global Optimization by Interval Arithmetic. In: Floudas C.A., Pardalos P. (eds), *Frontiers in Global Optimization. Nonconvex Optimization and Its Applications*, vol. 74. Springer, Boston, MA. [Preprint](http://webhome.cs.uvic.ca/~vanemden/Publications/mooreSkelb.pdf)

- H. Ratschek and J. Rokne, [*New Computer Methods for Global Optimization*](http://pages.cpsc.ucalgary.ca/~rokne/global_book.pdf)
