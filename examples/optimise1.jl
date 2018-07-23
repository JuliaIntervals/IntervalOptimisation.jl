using IntervalOptimisation, IntervalArithmetic, IntervalConstraintProgramming


# Unconstrained Optimisation
f(x, y) = (1.5 - x * (1 - y))^2 + (2.25 - x * (1 - y^2))^2 + (2.625 - x * (1 - y^3))^2
# f (generic function with 2 methods)

f(X) = f(X...)
# f (generic function with 2 methods)

X = (-1e6..1e6) × (-1e6..1e6)
# [-1e+06, 1e+06] × [-1e+06, 1e+06]

minimise_icp(f, X)
# ([0, 2.39527e-07], IntervalArithmetic.IntervalBox{2,Float64}[[2.99659, 2.99748] × [0.498906, 0.499523], [2.99747, 2.99834] × [0.499198, 0.500185], [2.99833, 2.99922] × [0.499198, 0.500185], [2.99921, 3.00011] × [0.499621, 0.500415], [3.0001, 3.001] × [0.499621, 0.500415], [3.00099, 3.0017] × [0.500169, 0.500566], [3.00169, 3.00242] × [0.500169, 0.500566]])



f(X) = X[1]^2 + X[2]^2
# f (generic function with 2 methods)

X = (-∞..∞) × (-∞..∞)
# [-∞, ∞] × [-∞, ∞]

minimise_icp(f, X)
# ([0, 0], IntervalArithmetic.IntervalBox{2,Float64}[[-0, 0] × [-0, 0], [0, 0] × [-0, 0]])




# Constrained Optimisation
f(X) = -1 * (X[1] + X[2])
# f (generic function with 1 method)

X = (-∞..∞) × (-∞..∞)
# [-∞, ∞] × [-∞, ∞]

constraints = [IntervalOptimisation.constraint(x->(x[1]), -∞..6), IntervalOptimisation.constraint(x->x[2], -∞..4), IntervalOptimisation.constraint(x->(x[1]*x[2]), -∞..4)]
# 3-element Array{IntervalOptimisation.constraint{Float64},1}:
#  IntervalOptimisation.constraint{Float64}(#3, [-∞, 6])
#  IntervalOptimisation.constraint{Float64}(#4, [-∞, 4])
#  IntervalOptimisation.constraint{Float64}(#5, [-∞, 4])

minimise_icp_constrained(f, X, constraints)
# ([-6.66676, -6.66541], IntervalArithmetic.IntervalBox{2,Float64}[[5.99918, 6] × [0.666233, 0.666758], [5.99918, 6] × [0.665717, 0.666234], [5.99887, 5.99919] × [0.666233, 0.666826], [5.99984, 6] × [0.665415, 0.665718], [5.99856, 5.99888] × [0.666233, 0.666826], [5.99969, 5.99985] × [0.665415, 0.665718]])



# One-dimensional case
minimise1d(x -> (x^2 - 2)^2, -10..11)
# ([0, 1.33476e-08], IntervalArithmetic.Interval{Float64}[[-1.41426, -1.41358], [1.41364, 1.41429]])

minimise1d_deriv(x -> (x^2 - 2)^2, -10..11)
# ([0, 8.76812e-08], IntervalArithmetic.Interval{Float64}[[-1.41471, -1.41393], [1.41367, 1.41444]])
