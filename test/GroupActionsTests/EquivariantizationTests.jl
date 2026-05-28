# Take the Ising Category defined in File TensorActionTest.jl

@testset "Equivariant Induction" begin 
    inds = [equivariant_induction(s,T) for s ∈ simples(I)]
    @test all(is_equivariant, inds)
end

E = equivariantization(I,T)
S = simples(E)

@testset "Simples in the Equivariantization" begin
    @test length(S) == 6
    @test all(is_equivariant, S)
    # tensor product
    @test is_equivariant(S[3] ⊗ S[4])
    @test is_equivariant(S[4] ⊗ S[5])
    # direct sum
    @test is_equivariant(S[3] ⊕ S[4])
    @test is_equivariant(S[3] ⊕ S[4])
    @test is_equivariant(E[3,4] ⊕ S[5])
end

H = Hom(E[2,2,3,3], E[2,2,3,4])

mors_coeffs = [[1,1,0,2,0,1], [-1,0,-1,1,0,0], [2,-1,-1,1,0,1], [0,5,-1,2,0,1]]
mors = [sum(c .* basis(H)) for c ∈ mors_coeffs]

@testset "Kernels & Cokernels in the Equivariantization" begin
    for f in mors
        @test is_equivariant(kernel(f)[1])
        @test is_equivariant(cokernel(f)[1])
    end
end