# This fixed AnyonWiki entry has the Ising fusion rules
#   ψ² = 1,  ψ⊗σ = σ,  σ² = 1⊕ψ.
# See Rowell--Stong--Wang, arXiv:0712.1377v4, Section 5.3.4. The database
# loader is tested against these independently known rules, and all 3^4
# pentagon equations are checked exactly (EGNO (2015), Section 2.2).
@testset "AnyonWiki rank-three Ising fixture" begin
    code = (3,1,0,1,1,1,1)
    C = anyonwiki(code...)

    N = zeros(Int,3,3,3)
    N[1,1,1] = N[1,2,2] = N[1,3,3] = 1
    N[2,1,2] = N[2,2,1] = N[2,3,3] = 1
    N[3,1,3] = N[3,2,3] = N[3,3,1] = N[3,3,2] = 1
    @test multiplication_table(C) == N
    @test TensorCategories.squared_norm(C[3]) == base_ring(C)(2)

    @test pentagon_axiom(C)
end
