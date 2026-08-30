#=----------------------------------------------------------
    Test structures for non semisimple module categories 
----------------------------------------------------------=#

C = graded_vector_spaces(QQ, symmetric_group(3))

# take a non-separable_algebra
A = filter(!is_separable, algebra_structures(C[1]⊕C[2])) |> first

# This is only a smoke test that the search returns at least one candidate
# classified as nonseparable.  Because A is selected using the same predicate,
# the assertion is not an independent mathematical check of nonseparability;
# a future regression should use an explicit obstruction to a bimodule section.
@testset "Non-semisimple modules" begin
    @test !is_separable(A)
    #@test !is_semisimple(endomorphism_ring(free_right_module(C[1,2],A)))    
end
