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
