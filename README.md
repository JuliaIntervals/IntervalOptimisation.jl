# `IntervalOptimisation.jl`

[![github badge][gh_badge]][gh_url]
[![codecov badge][codecov_badge]][codecov_url]

[gh_badge]: https://github.com/JuliaIntervals/IntervalOptimisation.jl/workflows/CI/badge.svg
[gh_url]: https://github.com/JuliaIntervals/IntervalOptimisation.jl/actions


[codecov_badge]: http://codecov.io/github/JuliaIntervals/IntervalOptimisation.jl/coverage.svg?branch=master
[codecov_url]: http://codecov.io/github/JuliaIntervals/IntervalOptimisation.jl?branch=master

[documenter_stable]: https://JuliaIntervals.github.io/IntervalOptimisation.jl/stable
[documenter_latest]: https://JuliaIntervals.github.io/IntervalOptimisation.jl/latest


## Rigorous global optimisation using Julia

This package provides rigorous global optimisation routines written in pure Julia, using interval arithmetic provided by the author's [IntervalArithmetic.jl](https://github.com/JuliaIntervals/IntervalArithmetic.jl) package.

Currently, the package uses an implementation of the Moore-Skelboe algorithm.

## Usage  

Functions `minimise` and `maximise` are provided to find the **global** minimum or maximum, respectively, of a standard Julia function `f` of one or several variables.

They return an `Interval` that is guaranteed to contain the global minimum (maximum), and a `Vector` of `Interval`s or `IntervalBox`es whose union contains all the minimisers.

### Examples


#### 1D
```julia
using IntervalArithmetic, IntervalOptimisation

julia> @time global_min, minimisers = minimise(x -> (x^2 - 2)^2, -10..11);
  0.046620 seconds (36.07 k allocations: 1.586 MiB)

julia> global_min
[0, 1.50881e-09]

julia> minimisers
2-element Array{IntervalArithmetic.Interval{Float64},1}:
  [1.41387, 1.41453]
 [-1.41428, -1.41363]
```

#### 2D

```julia
julia> @time global_min, minimisers = minimise(  X -> ( (x,y) = X; x^2 + y^2 ),
                                                        (-10000..10001) × (-10000..10001) );
  0.051122 seconds (46.80 k allocations: 2.027 MiB)

julia> global_min
[0, 2.33167e-08]

julia> minimisers
3-element Array{IntervalArithmetic.IntervalBox{2,Float64},1}:
 [-0.000107974, 0.000488103] × [-0.000107974, 0.000488103]
 [-0.000107974, 0.000488103] × [-0.000704051, -0.000107973]
 [-0.000704051, -0.000107973] × [-0.000107974, 0.000488103]
```
Note that the last two `IntervalBox`es do not actually contain the global minimum;
decreasing the tolerance (maximum allowed box diameter) removes them:

```
julia> @time global_min, minimisers = minimise(  X -> ( (x,y) = X; x^2 + y^2 ),
                                                               (-10000..10001) × (-10000..10001), 1e-5 );
  0.047196 seconds (50.72 k allocations: 2.180 MiB)

julia> minimisers
1-element Array{IntervalArithmetic.IntervalBox{2,Float64},1}:
 [-5.52321e-06, 3.79049e-06] × [-5.52321e-06, 3.79049e-06]
 ```

## Author

- [David P. Sanders](http://sistemas.fciencias.unam.mx/~dsanders),
Departamento de Física, Facultad de Ciencias, Universidad Nacional Autónoma de México (UNAM)


## References:

- *Validated Numerics: A Short Introduction to Rigorous Computations*, W. Tucker, Princeton University Press (2010)

- *Applied Interval Analysis*, Luc Jaulin, Michel Kieffer, Olivier Didrit, Eric Walter (2001)

- van Emden M.H., Moa B. (2004). Termination Criteria in the Moore-Skelboe Algorithm for Global Optimization by Interval Arithmetic. In: Floudas C.A., Pardalos P. (eds), *Frontiers in Global Optimization. Nonconvex Optimization and Its Applications*, vol. 74. Springer, Boston, MA. [Preprint](http://webhome.cs.uvic.ca/~vanemden/Publications/mooreSkelb.pdf)

- H. Ratschek and J. Rokne, [*New Computer Methods for Global Optimization*](http://pages.cpsc.ucalgary.ca/~rokne/global_book.pdf)

## Acknowledements
Financial support is acknowledged from DGAPA-UNAM PAPIIT grant IN-117117.
