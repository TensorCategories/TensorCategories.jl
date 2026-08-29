# Naturality is the equation G(f)η_X=η_YF(f) for every f:X→Y, not
# merely for endomorphisms; see EGNO (2015), Section 1.1.
@testset "Naturality on all arrows" begin
    V = VectorSpaces(QQ)
    U = one(V)
    @test int_dim(TensorCategories.Nat(id(V),id(V))) == 1

    # Rep(A2) has indecomposables k→0, 0→k, and k --id→ k. The arrows
    # between them force a common scalar on a natural endomorphism of Id.
    C = ArrowCategory(V)
    objects = [ArrowObject(C,id(U)),
               ArrowObject(C,zero_morphism(U,zero(V))),
               ArrowObject(C,zero_morphism(zero(V),U))]
    N = TensorCategories.Nat(id(C),id(C); indecomposables=objects)
    @test int_dim(N) == 1
    @test all(f ∘ η(X) == η(Y) ∘ f for η in basis(N)
              for X in objects for Y in objects for f in basis(Hom(X,Y)))

    # Even for one generator, every endomorphism equation is imposed: the
    # commutant of Mat_2(Q) consists of scalars.
    A = VectorSpaceObject(V,2)
    M = TensorCategories.additive_natural_transformations(id(V),id(V),[A])
    @test length(M) == 1
    @test all(f ∘ only(M)(A) == only(M)(A) ∘ f for f in basis(End(A)))

    # Inversion swaps functor endpoints; pair-valued component input is keyed
    # by objects rather than by positions in the generator list.
    F, G = id(V), functor(V,V,X -> X,f -> f)
    η = TensorCategories.AdditiveNaturalTransformation(F,G,[U],[2*id(U)])
    @test domain(inv(η)) == G && codomain(inv(η)) == F
    @test inv(η)(U) ∘ η(U) == id(U)
    ν = TensorCategories.AdditiveNaturalTransformation(F,G,[U],
                                                           [U => 2*id(U)])
    @test ν == η
end
