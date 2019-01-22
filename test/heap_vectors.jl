using IntervalOptimisation
using Test

const heap =IntervalOptimisation.heap

@testset "heap" begin
	
	@testset "with standard heaping "
	      v=[9,7,5,2,3]
          h=heap(v) 

          @test h.data==[2, 3, 7, 9, 5]

          push!(h,1)
          @test h.data==[1, 3, 2, 9, 5, 7]

          popfirst!(h)
          @test h.data==[2, 3, 7, 9, 5]

        end 

    @testset "with ordering function"
        v=[(9,"f"),(7,"c"),(5,"e"),(2,"d"),(3,"b")]
        h=heap(v,x->x[2])
        
        @test h.data==[(3, "b"), (5, "c"), (7, "e"), (9, "f"), (2, "d")]

        push!(h,(1,"a"))
        @test h.data==[(1, "a"), (7, "c"), (2, "b"), (9, "f"), (3, "d"), (5, "e")] 
        
        popfirst!(h)
        @test h.data==[(2, "b"), (7, "c"), (5, "e"), (9, "f"), (3, "d")]

    end 

end