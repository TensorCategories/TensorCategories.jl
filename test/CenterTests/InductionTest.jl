#=-------------------------------------------------
    Test sets for the induction functor
        𝒞 → 𝒵(𝒞) 
-------------------------------------------------=#

G    = symmetric_group(3)
H    = cyclic_group(3) 
F,ξ  = cyclotomic_field(3,"ξ")
c    = cyclic_group_3cocycle(H,F,ξ)  

VecG = graded_vector_spaces(F,G)
VecH = graded_vector_spaces(F,H,c)

# Induction is the right adjoint I:C→Z(C) of the forgetful functor.  In a
# fusion category its underlying object is ⊕_X X⊗Y⊗X*, and the construction
# supplies the compatible half-braiding.  See P. Etingof, S. Gelaki,
# D. Nikshych, and V. Ostrik, Tensor Categories, AMS (2015), Section 9.2 and
# Proposition 9.2.2.  This test checks that structural half-braiding for every
# simple input in untwisted Vec_G.
@testset "Graded Vector Spaces" begin
    S = simples(VecG)
    induction_S = induction.(S)
    for X ∈ induction_S
        @test is_half_braiding(object(X), half_braiding(X))
    end
end

# The same center-induction construction applies to Vec_H^ω: the 3-cocycle
# changes the associator, so this separately checks compatibility of the
# induced half-braiding with the twisted pentagon data.
@testset "Twisted Graded Vector Spaces" begin
    S = simples(VecH)
    induction_S = induction.(S)
    for X ∈ induction_S
        @test is_half_braiding(object(X), half_braiding(X))
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
