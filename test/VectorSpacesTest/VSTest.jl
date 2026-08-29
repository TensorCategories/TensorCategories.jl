
m = matrix(QQ, [1 -1 1; -1 1 -1; 1 -1 1])
f = morphism(m)

# In finite-dimensional vector spaces, direct-sum dimensions are additive and
# tensor-product dimensions are multiplicative.  The two objects use the
# dimension-based and explicit-basis constructors, respectively, so these
# equalities also check that both representations obey the same linear algebra.
@testset "Objects" begin
    V = VectorSpaceObject(QQ, 2)
    W = VectorSpaceObject(QQ, ["v", "w", "x"])
    @test dim(V ⊕ W) == 5
    @test dim(V⊗W) == 6
end

# A kernel inclusion k and cokernel projection c necessarily satisfy f*k = 0
# and c*f = 0.  These assertions check those defining annihilation equations;
# they do not by themselves test the corresponding universal properties.
@testset "(Co)Kernel" begin
    K,k = kernel(f)
    C,c = cokernel(f)
    @test iszero(matrix(f∘k))
    @test iszero(matrix(c∘f))
end
