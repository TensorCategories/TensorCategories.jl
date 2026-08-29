#=----------------------------------------------------------
    Test Algebras 
----------------------------------------------------------=#

V = graded_vector_spaces(QQ, symmetric_group(3))

# @testset "Algebras in VecG" begin
#     algs = algebra_structures(V[1,2])
#     algs2 = algebra_structures(V[1,4,5])
#     @test all(is_algebra.(algs))
#     @test all(is_algebra.(algs2))
# end

I = ising_category()

# An algebra object is a multiplication and unit satisfying associativity and
# the two unit equations.  The test validates every candidate returned on
# 1⊕ψ and 1⊕σ; it does not prove that algebra_structures found every algebra.
# Separability means that multiplication splits as an A-bimodule map.  The last
# assertion concerns only the returned 1⊕σ candidates.  See P. Etingof,
# S. Gelaki, D. Nikshych, and V. Ostrik, Tensor Categories, AMS (2015),
# Section 7.8, especially Definition 7.8.29.
@testset "Algebras in Ising" begin 
    algs = algebra_structures(I[1,2];check=true)
    @test all(is_algebra.(algs))

    algs2 = algebra_structures(I[1,3];check=true)
    @test all(is_algebra.(algs2))
    @test !any(is_separable.(algs2))
end
