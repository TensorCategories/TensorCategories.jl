#=----------------------------------------------------------
    Test center for graded Vector spaces
----------------------------------------------------------=#

V = graded_vector_spaces(QQ, symmetric_group(2))
V2 = graded_vector_spaces(QQ, symmetric_group(3))
Z = center(V)
Z2 = center(V2)

# For Vec_G, simple center objects are indexed over a splitting field by a
# conjugacy class C and an irreducible representation of a centralizer C_G(g).
# See P. Etingof, S. Gelaki, D. Nikshych, and V. Ostrik, Tensor Categories,
# AMS (2015), Example 8.5.4.  Over QQ this gives 4 simples for S₂.  For S₃,
# the rational irreducibles of S₃, C₂, and C₃ contribute 3+2+2=7.
@testset "Compute Center" begin
    
    @test length(simples(Z)) == 4
    @test length(simples(Z2)) == 7

end

# Splitting the C₃ centralizer representations separates its two-dimensional
# rational irreducible into the two nontrivial linear characters, raising the
# S₃ center rank from 7 to 8.  In the resulting split category every simple
# retains a valid half-braiding and has one-dimensional endomorphism algebra.
@testset "split Center" begin
    Z3,_ = split(Z2)
    @test length(simples(Z3)) == 8 
    
    @test all(is_central.(simples(Z3)))
    @test all([int_dim(End(s)) == 1 for s in simples(Z3)])
end
