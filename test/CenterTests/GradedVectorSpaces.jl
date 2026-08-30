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
    @test is_weak_fusion(Z) && is_fusion(Z) && is_modular(Z)
    # The rational two-dimensional C3-representation in Z(Vec_S3) has
    # endomorphism field Q(zeta_3).  Hence the center is weak fusion but not
    # split fusion; see EGNO, Example 8.5.4, and Mäurer--Thiel,
    # arXiv:2406.13438v2, Section 2.1.
    @test is_weak_fusion(Z2) && !is_fusion(Z2) && !is_modular(Z2)

    # Hom_Z(1,1⊕1) has dimension two, represented by 1×2 matrices. The
    # adjunction basis reduction must preserve those endpoints (EGNO §9.2).
    X = one(Z)
    Y = X ⊕ X
    H = Hom(X,Y)
    @test int_dim(H) == 2
    @test all(domain(f) == X && codomain(f) == Y && size(matrix(f)) == (1,2)
              for f in basis(H))
    # The half-braiding condition is linear in the underlying map. Building
    # its coefficient matrix directly must give the same two-dimensional Hom.
    Hlinear = TensorCategories.hom_by_linear_equations(X,Y)
    @test int_dim(Hlinear) == 2
    @test all(domain(f) == X && codomain(f) == Y for f in basis(Hlinear))

end

# Under the package convention, modular means braided spherical fusion with a
# nonsingular S-matrix.  EGNO, Corollary 8.20.14 proves modularity of the center
# for a spherical fusion category; fusion alone does not supply the spherical
# structure.  Changing the rank-one pivotal component to 2 violates pivotal
# monoidality while leaving the underlying fusion category unchanged.
@testset "Center modularity requires spherical structure" begin
    C = six_j_category(QQ,ones(Int,1,1,1),["1"])
    set_one!(C,[1])
    set_pivotal!(C,QQ.([1]))
    ZC = center(C)
    @test length(simples(ZC)) == 1
    @test is_fusion(ZC) && is_spherical(ZC) && is_modular(ZC)

    set_pivotal!(C,QQ.([2]))
    @test is_fusion(C) && !is_spherical(C)
    @test is_fusion(ZC) && !is_spherical(ZC) && !is_modular(ZC)
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

# A change of basis in each multiplicity space transports both F- and
# R-symbols. They must use the same bases for the pentagon and hexagon to refer
# to one braided category; see EGNO (2015), Sections 2.4, 4.9, and 8.1.
@testset "Shared center multiplicity-space bases" begin
    S = simples(Z)
    H = TensorCategories.multiplicity_spaces(Z)
    @test TensorCategories.multiplicity_spaces(Z,S) === H
    @test TensorCategories.six_j_symbols(Z,copy(S);homs=H) ==
          TensorCategories.six_j_symbols_of_construction(Z,copy(S);homs=H)

    W = skeletonize(Z)
    @test pentagon_axiom(W) && hexagon_axiom(W)

    R = reverse(S)
    HR = TensorCategories.multiplicity_spaces(Z,R)
    @test all(int_dim(get(HR,(i,j,k),
                          HomSpace(R[i]⊗R[j],R[k],CenterMorphism[]))) ==
              int_dim(Hom(R[i]⊗R[j],R[k]))
              for i in eachindex(R),j in eachindex(R),k in eachindex(R))
end
