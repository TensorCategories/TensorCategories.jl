# In Vec_G, tensor words follow multiplication in G; see EGNO (2015),
# Section 2.3. The depth and cache semantics are the documented API convention.
@testset "Tensor-power depth and structural wrappers" begin
    C = graded_vector_spaces(QQ,cyclic_group(5))
    g = simples(C)[2]
    T = tensor_power_category(g)
    @test length(indecomposables(T,0)) == 1
    @test length(indecomposables(T,1)) == 2
    @test length(indecomposables(T,2)) == 3
    @test length(indecomposables(T,5)) == 5
    @test T.complete
    # Completion must not make later shallow queries return the full cache.
    @test length(indecomposables(T,1)) == 2
    @test length(indecomposables(T,0)) == 1
    @test_throws ArgumentError indecomposables(T,-1)
    @test_throws ArgumentError indecomposables(T,1.5)
    @test_throws ArgumentError tensor_power_category()

    Z = tensor_power_category(zero(C))
    @test length(indecomposables(Z,0)) == 1
    @test length(indecomposables(Z,2)) == 1

    X = first(indecomposables(T,1))
    # The categorical trace of an endomorphism has unit endpoints and the
    # trace of the identity is its categorical dimension (EGNO, Definition 4.7.1).
    @test domain(tr(id(X))) == one(T) == codomain(tr(id(X)))
    @test base_ring(T)(tr(id(X))) == dim(X)
end
