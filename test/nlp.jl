using IntervalOptimisation
using JuMP
using NLPModelsJuMP
using Test

@testset "NLPModels / JuMP integration" begin
    @testset "1D quadratic minimization" begin
        model = Model(NLPModelsJuMP.Optimizer)
        set_attribute(model, "solver", IntervalOptimiser)
        set_attribute(model, "tol", 1e-5)
        set_optimizer_attribute(model, "silent", true)

        @variable(model, -10 <= x <= 10)
        @objective(model, Min, (x - 3)^2 + 1)
        optimize!(model)

        @test termination_status(model) == LOCALLY_SOLVED
        @test value(x) ≈ 3.0 atol = 1e-3
        @test objective_value(model) ≈ 1.0 atol = 1e-3
    end

    @testset "2D Rosenbrock-like" begin
        model = Model(NLPModelsJuMP.Optimizer)
        set_attribute(model, "solver", IntervalOptimiser)
        set_attribute(model, "tol", 1e-3)
        set_optimizer_attribute(model, "silent", true)

        @variable(model, -5 <= x <= 5)
        @variable(model, -5 <= y <= 5)
        @objective(model, Min, (x - 1)^2 + (y - 2)^2)
        optimize!(model)

        @test termination_status(model) == LOCALLY_SOLVED
        @test value(x) ≈ 1.0 atol = 1e-2
        @test value(y) ≈ 2.0 atol = 1e-2
        @test objective_value(model) ≈ 0.0 atol = 1e-2
    end

    @testset "Maximization" begin
        model = Model(NLPModelsJuMP.Optimizer)
        set_attribute(model, "solver", IntervalOptimiser)
        set_attribute(model, "tol", 1e-5)
        set_optimizer_attribute(model, "silent", true)

        @variable(model, -2 <= x <= 2)
        @objective(model, Max, -(x - 1)^2 + 5)
        optimize!(model)

        @test termination_status(model) == LOCALLY_SOLVED
        @test value(x) ≈ 1.0 atol = 1e-3
        @test objective_value(model) ≈ 5.0 atol = 1e-3
    end

    @testset "Nonlinear objective" begin
        model = Model(NLPModelsJuMP.Optimizer)
        set_attribute(model, "solver", IntervalOptimiser)
        set_attribute(model, "tol", 1e-4)
        set_optimizer_attribute(model, "silent", true)

        @variable(model, 0.1 <= x <= 5)
        @objective(model, Min, x - log(x))
        optimize!(model)

        # Minimum of x - log(x) is at x = 1, value = 1
        @test termination_status(model) == LOCALLY_SOLVED
        @test value(x) ≈ 1.0 atol = 1e-2
        @test objective_value(model) ≈ 1.0 atol = 1e-2
    end
end
