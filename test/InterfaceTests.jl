# Generic interface regressions. References and counterexamples are recorded
# with the testsets that use them.

# Maschke's theorem gives semisimplicity when the characteristic does not
# divide |G|; see EGNO (2015), Remark 4.2.14. Fusion additionally requires
# splitting; see Mäurer--Thiel, arXiv:2406.13438v2, Section 2.1.
@testset "Weak fusion and splitting over nonclosed fields" begin
    R = representation_category(GF(2), cyclic_group(3))
    # x^2+x+1 is irreducible over F2, so the two-dimensional simple has
    # endomorphism field F4: this category is weak fusion but not fusion.
    @test is_semisimple(R) && is_weak_fusion(R)
    @test !is_split_semisimple(R) && !is_fusion(R)
    @test is_fusion(representation_category(GF(5), cyclic_group(2)))
    M = representation_category(GF(3), cyclic_group(3))
    @test !is_weak_fusion(M) && !is_fusion(M)
end

function audit_jordan_representation(C, n)
    J = identity_matrix(base_ring(C), n)
    for i in 1:n-1
        J[i, i+1] = 1
    end
    Representation(C, gens(base_group(C)), [J])
end

# A representation morphism is an intertwiner; see Etingof et al.,
# Introduction to Representation Theory (2011), Definition 1.13.
@testset "Representation morphism validation" begin
    F = GF(5)
    R = representation_category(F, cyclic_group(5))
    J2 = audit_jordan_representation(R, 2)
    bad = matrix(F, [1 0; 0 0])
    @test_throws ArgumentError morphism(J2, J2, bad; check = true)
    # Expensive equivariance validation is opt-in for performance.
    @test matrix(morphism(J2, J2, bad)) == bad

    S = representation_category(F, cyclic_group(2))
    T = Representation(S, gens(base_group(S)), [identity_matrix(F, 2)])
    @test_throws ArgumentError morphism(J2, T, identity_matrix(F, 2))
    @test_throws ArgumentError morphism(J2, J2, identity_matrix(GF(7), 2))
    @test_throws ErrorException morphism(J2, J2, identity_matrix(F, 1))
end

# Monomorphisms and epimorphisms need not split outside semisimple categories;
# see EGNO (2015), Sections 1.3--1.4.
@testset "Nonsplit monomorphisms and epimorphisms" begin
    R = representation_category(GF(5), cyclic_group(5))
    J1, J2 = audit_jordan_representation(R, 1), audit_jordan_representation(R, 2)
    p = only(basis(Hom(J2, J1)))
    i = only(basis(Hom(J1, J2)))
    @test is_epimorphism(p) && !is_monomorphism(p)
    @test is_monomorphism(i) && !is_epimorphism(i)
    # Splittings would decompose the indecomposable Jordan block J2.
    @test_throws ErrorException right_inverse(p)
    @test_throws ErrorException left_inverse(i)
    @test is_monomorphism(zero_morphism(zero(R), J1))
    @test is_epimorphism(zero_morphism(J1, zero(R)))
end
