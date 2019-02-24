using IntervalOptimisation
using Test

const HeapedVector = IntervalOptimisation.HeapedVector

@testset "heap" begin
	
	@testset "with standard heaping " begin

    h=HeapedVector([9, 7, 5, 2, 3]) 

    @test h.data == [2, 3, 7, 9, 5]

    push!(h, 1)
    @test h.data == [1, 3, 2, 9, 5, 7]

    popfirst!(h)
    @test h.data == [2, 3, 7, 9, 5]

  end 

  @testset "with ordering function" begin

    h=HeapedVector( [(9,"f"), (7,"c"), (5,"e"), (2,"d"), (3,"b")] , x->x[2])
        
    @test h.data == [(3, "b"), (7, "c"), (5, "e"), (9, "f"), (2, "d")]

    push!(h, (1,"a"))
    @test h.data == [(1, "a"), (7, "c"), (3, "b"), (9, "f"), (2, "d"), (5, "e")]
        
    popfirst!(h)
    @test h.data == [(3, "b"), (7, "c"), (5, "e"), (9, "f"), (2, "d")]

  end 

end