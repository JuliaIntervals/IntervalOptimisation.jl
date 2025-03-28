using IntervalArithmetic, IntervalOptimisation
using IntervalArithmetic.Symbols

G(X) = 1 + sum(abs2, X) / 4000 - prod( cos(X[i] / √i) for i in 1:length(X) )

@time minimise(G, -600..600)
@time minimise(G, -600..600)

for N in (10, 30, 50)
    @show N
    @time minimise(G, fill(-600..600, N))
    @time minimise(G, fill(-600..600, N))
end
