#=----------------------------------------------------------
    Test UqSL2Representations 
----------------------------------------------------------=#

# Uq(𝔰𝔩₂) reps at q = √2
C = sl2_representations(quadratic_field(2)...)

# The associator must satisfy pentagon coherence.  The tensor-product equality
# is the Clebsch--Gordan rule V_i⊗V_j = ⊕_l V_{i+j-2l} in this indexing;
# specifically C[2]⊗C[3] = C[1]⊕C[3]⊕C[5].  See P. Etingof,
# S. Gelaki, D. Nikshych, and V. Ostrik, Tensor Categories, AMS (2015),
# Example 4.9.3, equation (4.11).
@testset "Uq(sl2) representations" begin
    # test some Associators
    @test pentagon_axiom([C[1],C[2],C[3]])
    
    @test C[2] ⊗ C[3] == C[1,3,5]
end
