using IntervalArithmetic, IntervalOptimisation
using Test
using IntervalOptimisation: numeric_type

@testset "IntervalOptimisation tests" begin
    @testset "numeric_type" begin
        x = -10..10
        big_x = big(x)
        @test numeric_type(x) == Float64
        @test numeric_type(big_x) == BigFloat
        @test numeric_type(IntervalBox(x, x)) == Float64
        @test numeric_type(IntervalBox(big_x, big_x)) == BigFloat
    end

    @testset "Minimise in 1D using default data structure i.e HeapedVector" begin
        global_min, minimisers = minimise(x->x, -10..10)
        @test global_min ⊆ -10 .. -9.999
        @test length(minimisers) == 1
        @test minimisers[1] ⊆ -10 .. -9.999

        # same but with maximise
        global_max, maximisers = maximise(x->x, -10..10)
        @test global_max ⊆ 9.999 .. 10
        @test length(maximisers) == 1
        @test maximisers[1] ⊆ 9.999 .. 10

        # same but with BigFloats
        global_min, minimisers = minimise(x->x, -big(10.0)..big(10.0))
        @test global_min ⊆ -10 .. -9.999
        @test length(minimisers) == 1
        @test minimisers[1] ⊆ -10 .. -9.999

        global_min, minimisers = minimise(x->x^2, -10..11, tol = 1e-10)
        @test global_min ⊆ 0..1e-20
        @test length(minimisers) == 1
        @test minimisers[1] ⊆ -0.1..0.1

        global n_calls = 0
        f = x -> begin global n_calls += 1; x^2 end
        global_min, minimisers = minimise(f, -10..11, tol = 1e-10, f_calls_limit = 10)
        @test n_calls == 10 #note : for other values we can overshoot, since we call 3 times per iteration

        global_min, minimisers = minimise(x->(x^2-2)^2, -10..11)
        @test global_min ⊆ 0..1e-7
        @test length(minimisers) == 2
        @test sqrt(2) ∈ minimisers[2]
    end

    for Structure in (SortedVector, HeapedVector)

        @testset "Minimise in 1D using SortedVector" begin
            global_min, minimisers = minimise(x->x, -10..10, structure = Structure)
            @test global_min ⊆ -10 .. -9.999
            @test length(minimisers) == 1
            @test minimisers[1] ⊆ -10 .. -9.999

            # same but with maximise
            global_max, maximisers = maximise(x->x, -10..10, structure = Structure)
            @test global_max ⊆ 9.999 .. 10
            @test length(maximisers) == 1
            @test maximisers[1] ⊆ 9.999 .. 10

            # same but with BigFloats
            global_min, minimisers = minimise(x->x, -big(10.0)..big(10.0), structure = Structure)
            @test global_min ⊆ -10 .. -9.999
            @test length(minimisers) == 1
            @test minimisers[1] ⊆ -10 .. -9.999

            global_min, minimisers = minimise(x->x^2, -10..11, tol=1e-10, structure = Structure)
            @test global_min ⊆ 0..1e-20
            @test length(minimisers) == 1
            @test minimisers[1] ⊆ -0.1..0.1

            global_min, minimisers = minimise(x->(x^2-2)^2, -10..11, structure = Structure)
            @test global_min ⊆ 0..1e-7
            @test length(minimisers) == 2
            @test sqrt(2) ∈ max(minimisers[1], minimisers[2])
        end


        @testset "Discontinuous function in 1D" begin

            H(x) = (sign(x) + 1) / 2   # Heaviside function except at 0, where H(0) = 0.5
            global_min, minimisers = minimise(x -> abs(x) + H(x) - 1, -10..11, tol=1e-5, structure = Structure)
            @test global_min ⊆ -1 .. -0.9999
            @test length(minimisers) == 1
            @test 0 ∈ minimisers[1]
            @test diam(minimisers[1]) <= 1e-5
        end


        @testset "Smooth function in 2D" begin
            global_min, minimisers = minimise( X -> ( (x,y) = X; x^2 + y^2 ), (-10..10) × (-10..10), structure = Structure )
            @test global_min ⊆ 0..1e-7
            @test all(X ⊆ (-1e-3..1e3) × (-1e-3..1e-3) for X in minimisers)

            # same but with maximise
            global_max, maximisers = maximise( X -> ( (x,y) = X; x^2 + y^2 ), (-10..10) × (-10..10), structure = Structure )
            @test global_max ⊆ 199.9..200
            m = (9.99..10)
            @test all(X ⊆ m × m || X ⊆ -m × m || X ⊆ m × -m || X ⊆ -m × -m for X in maximisers)

            # same but with BigFloats
            global_min, minimisers = minimise( X -> ( (x,y) = X; x^2 + y^2 ), (-big(10.0)..big(10.0)) × (-big(10.0)..big(10.0)), structure = Structure )
            @test global_min ⊆ 0..1e-7
            @test all(X ⊆ big(-1e-3..1e3) × big(-1e-3..1e-3) for X in minimisers)

        end

    end

end
