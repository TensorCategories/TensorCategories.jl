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

    # The same rectangular-coordinate contract holds in a relative center;
    # see Gelaki--Naidu--Nikshych (2009), Definition 2.1.
    X = one(Z)
    Y = X ⊕ X
    HXY = Hom(X,Y)
    @test int_dim(HXY) == 2
    @test all(domain(f) == X && codomain(f) == Y && size(matrix(f)) == (1,2)
              for f in basis(HXY))
    Hlinear = TensorCategories.hom_by_linear_equations(X,Y)
    @test int_dim(Hlinear) == 2
    @test all(domain(f) == X && codomain(f) == Y for f in basis(Hlinear))
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


@testset "Full relative center has structural twists" begin
    # Gelaki--Naidu--Nikshych, Centers of graded fusion categories (2009),
    # Section 2B, Definition 2.1: taking the subcategory to be all of C gives
    # Z(C). For Vec_C2 this is toric code, whose twists are (1,1,1,-1);
    # see Rowell--Stong--Wang, arXiv:0712.1377v4, Section 5.3.8.
    C = graded_vector_spaces(QQ,cyclic_group(2))
    Z = centralizer(C,simples(C))
    S = simples(Z)
    theta = twist_scalar.(S)
    @test length(S) == 4
    @test count(==(QQ(1)),theta) == 3
    @test count(==(QQ(-1)),theta) == 1
    @test tmatrix(Z) == diagonal_matrix(theta)

    # EGNO Section 8.10 defines theta on every object. A direct sum of two
    # eigenspaces has a structural twist but no single twist scalar.
    A = S[findfirst(==(QQ(1)),theta)]
    B = S[findfirst(==(QQ(-1)),theta)]
    X,inc,_ = direct_sum(A,B)
    t = twist(X)
    @test domain(t) == codomain(t) == X
    @test t ∘ inc[1] == inc[1]
    @test t ∘ inc[2] == -inc[2]
    @test_throws ArgumentError twist_scalar(X)
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
