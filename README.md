# `IntervalOptimisation.jl`

[![travis badge][travis_badge]][travis_url]
[![appveyor badge][appveyor_badge]][appveyor_url]
[![codecov badge][codecov_badge]][codecov_url]

[travis_badge]: https://travis-ci.org/JuliaIntervals/IntervalOptimisation.jl.svg?branch=master
[travis_url]: https://travis-ci.org/JuliaIntervals/IntervalOptimisation.jl

[appveyor_badge]: https://ci.appveyor.com/api/projects/status/github/JuliaIntervals/IntervalOptimisation.jl?svg=true&branch=master
[appveyor_url]: https://ci.appveyor.com/project/JuliaIntervals/intervaloptimisation-jl

[codecov_badge]: http://codecov.io/github/JuliaIntervals/IntervalOptimisation.jl/coverage.svg?branch=master
[codecov_url]: http://codecov.io/github/JuliaIntervals/IntervalOptimisation.jl?branch=master

[documenter_stable]: https://JuliaIntervals.github.io/IntervalOptimisation.jl/stable


## Rigorous global optimisation using Julia

This package provides rigorous global optimisation routines written in pure Julia, using interval arithmetic provided by the author's [IntervalArithmetic.jl](https://github.com/JuliaIntervals/IntervalArithmetic.jl) package.

Currently, the package uses an implementation of the Moore-Skelboe algorithm.

## Documentation
Documentation of this package is available [here](https://JuliaIntervals.github.io/IntervalOptimisation.jl/latest/)


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
