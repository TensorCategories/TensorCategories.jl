# Take the Ising Category defined in File TensorActionTest.jl

# Equivariant induction sums the translates of an object and equips that sum
# with the canonical permutation equivariance.  The resulting objects must
# satisfy the action compatibility equations.  See P. Etingof, S. Gelaki,
# D. Nikshych, and V. Ostrik, Tensor Categories, AMS (2015), Section 4.15.
@testset "Equivariant Induction" begin 
    inds = [equivariant_induction(s,T) for s ∈ simples(I)]
    @test all(is_equivariant, inds)
end

E = equivariantization(I,T)
S = simples(E)

# All three Ising simples are fixed by this split C₂-action.  Simple objects of
# an equivariantization are pairs consisting of an orbit representative and an
# irreducible projective stabilizer representation; the trivial cocycles give
# two C₂-characters for each Ising simple, hence 3*2=6 simples.  Tensor products
# and biproducts of equivariant objects inherit equivariance.  See S. Burciu and
# S. Natale, J. Math. Phys. 54 (2013), Corollary 2.13.
@testset "Simples in the Equivariantization" begin
    @test length(S) == 6
    @test is_multitensor(E) && is_tensor(E)
    @test is_weak_fusion(E) && is_fusion(E)
    @test all(is_equivariant, S)
    # tensor product
    @test is_equivariant(S[3] ⊗ S[4])
    @test is_equivariant(S[4] ⊗ S[5])
    # direct sum
    @test is_equivariant(S[3] ⊕ S[4])
    @test is_equivariant(S[3] ⊕ S[4])
    @test is_equivariant(E[3,4] ⊕ S[5])
end

# Fusion properties do not simply pass from C to C^G.  For the trivial action
# of C2 on Vec_F2, equivariant objects are Rep_F2(C2), which is not semisimple
# because char(F2) divides |C2| (Maschke's theorem).  Thus it is a tensor
# category, but neither weak fusion nor fusion.  See EGNO, Section 4.15.
@testset "Equivariantization in modular characteristic" begin
    V = VectorSpaces(GF(2))
    G2 = cyclic_group(2)
    F = identity_as_monoidal_functor(V)
    η = id(F)
    trivial_action = gtensor_action(
        V,
        elements(G2),
        fill(F, Int(order(G2))),
        Dict((i,j) => η for i in 1:Int(order(G2)), j in 1:Int(order(G2)))
    )
    E2 = equivariantization(V, trivial_action)

    @test is_tensor_action(trivial_action)
    @test is_multitensor(E2) && is_tensor(E2)
    @test !is_weak_multifusion(E2) && !is_weak_fusion(E2)
    @test !is_multifusion(E2) && !is_fusion(E2)
end

H = Hom(E[2,2,3,3], E[2,2,3,4])

mors_coeffs = [[1,1,0,2,0,1], [-1,0,-1,1,0,0], [2,-1,-1,1,0,1], [0,5,-1,2,0,1]]
mors = [sum(c .* basis(H)) for c ∈ mors_coeffs]

# Equivariantization is an abelian category here, and the forgetful functor
# creates kernels and cokernels: the underlying (co)kernel receives the induced
# equivariant structure.  Each object returned for these sample morphisms must
# therefore satisfy the equivariance equations.
@testset "Kernels & Cokernels in the Equivariantization" begin
    for f in mors
        @test is_equivariant(kernel(f)[1])
        @test is_equivariant(cokernel(f)[1])
    end
end
