#=-------------------------------------------------
    Test sets for relative centers
        𝒞 → 𝒵(𝒞:\scr) 
-------------------------------------------------=#

G    = symmetric_group(3)
H    = cyclic_group(3) 
F,ξ  = cyclotomic_field(3,"ξ")
c    = cyclic_group_3cocycle(H,F,ξ)  

VecG = graded_vector_spaces(F,G)
VecH = graded_vector_spaces(F,H,c)

# The relative center Z_D(C) consists of objects of C with a coherent
# half-braiding against objects of D.  See S. Gelaki, D. Naidu, and
# D. Nikshych, "Centers of graded fusion categories", Algebra & Number
# Theory 3 (2009), Section 2B, especially Definition 2.1.  The returned
# simples must satisfy those centrality equations for the chosen generator.
@testset "Untwisted graded vector spaces" begin
    Z = centralizer(VecG, VecG[2])

    simps = simples(Z)

    for s ∈ simps
        @test is_central(s)
    end
end


# Repeating the construction for Vec_H^ω checks that the relative
# half-braiding equations incorporate the nontrivial 3-cocycle associator.
@testset "Twisted graded vector spaces" begin
    Z = centralizer(VecH, VecH[2])

    simps = simples(Z)

    for s ∈ simps
        @test is_central(s) 
    end
end


F = GF(23)
RepG = representation_category(F,G)

# @testset "Group Representation Category" begin
#     S = simples(RepG)
#     induction_S = induction.(S)
#     for X ∈ induction_S
#         @test is_half_brading(object(X), half_braiding(X))
#     end
# end
