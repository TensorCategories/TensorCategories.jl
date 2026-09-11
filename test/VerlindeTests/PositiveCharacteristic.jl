using Test, Random, Oscar, TensorCategories

# [EGNO] P. Etingof, S. Gelaki, D. Nikshych, V. Ostrik,
# Tensor Categories, AMS, 2015, Exercise 8.18.9.
# [GO] S. Gelaki, V. Ostrik, On the Drinfeld center of the Verlinde
# category Ver_p, arXiv:2608.20465v1, 2026.

@testset "Symmetric Verlinde categories" begin
    @test_throws ArgumentError symmetric_verlinde_category(1)
    @test_throws ArgumentError symmetric_verlinde_category(9)
    @test_throws ArgumentError symmetric_verlinde_category(QQ)

    for (p, plus) in ((5, false), (7, true))
        V = symmetric_verlinde_category(p; plus, check=true)
        labels = plus ? collect(1:2:p-1) : collect(1:p-1)
        S = simples(V)
        @test V.simples_names == ["L$i" for i in labels]
        @test dim.(S) == base_ring(V).(labels)
        @test is_fusion(V) && is_spherical(V; check=true)
        @test pentagon_axiom(V) && hexagon_axiom(V)
        for (i, a) in pairs(labels), (j, b) in pairs(labels)
            allowed = abs(a-b)+1:2:min(a+b-1, 2p-a-b-1)
            @test (S[i] ⊗ S[j]).components == [Int(c in allowed) for c in labels]
            @test braiding(S[j], S[i]) ∘ braiding(S[i], S[j]) == id(S[i] ⊗ S[j])
        end
    end

    # A nontrivial symmetric fusion category has degenerate S-matrix.
    @test !is_modular(symmetric_verlinde_category(5; plus=true))

    Q = symmetric_verlinde_category(GF(9); skeletal=false)
    @test Q isa Semisimplification
    @test characteristic(base_ring(Q)) == 3
    @test length(simples(Q)) == 2

    S = simples(Q)
    M = [int_dim(Hom(Y,S[2]⊗X)) for Y in S, X in S]
    D = fusion_subcategory(S[2];simples=S,products=M,
        names=["L1","L2"],rng=MersenneTwister(20260911))
    @test D isa FusionSubcategory
    @test is_fusion(D) && is_braided(D) && is_spherical(D)
    @test simples_names(D) == ["L1","L2"]
    @test [int_dim(Hom(X,Y)) for X in simples(D), Y in simples(D)] == [1 0;0 1]
    @test multiplication_table(D,simples(D)) == reshape([1,0,0,1,0,1,1,0],2,2,2)
    Dskel = skeletonize(D;check=true)
    @test pentagon_axiom(Dskel) && hexagon_axiom(Dskel)
    Dexplicit = fusion_subcategory(simples(Dskel)[2];simples=simples(Dskel),
        products=M,names=["L1","L2"],check=false)
    @test Dexplicit isa FusionSubcategory
end

function _verlinde_center_data(p)
    V = symmetric_verlinde_category(p; plus=true)
    Z = center(V)
    E = center_embedding(V; parent_category=Z)
    S = simples(Z; sort=false, show_progress=false)
    P = [induction(X; parent_category=Z) for X in simples(V)]
    (; V, Z, embedding=E, simples=S, projectives=P)
end

@testset "Canonical center embedding" begin
    V = symmetric_verlinde_category(5; plus=true)
    Z = center(V)
    E = center_embedding(V; parent_category=Z)
    X, Y = simples(V)
    @test object(E(X)) == X
    @test is_central(E(X))
    @test E(id(X)) == id(E(X))
    @test E(X ⊗ Y) == E(X) ⊗ E(Y)
    Erev = center_embedding(V; reverse=true, parent_category=Z)
    @test is_central(Erev(Y))
end

@testset "Ver_5^+ center and bounded semisimplification" begin
    data = _verlinde_center_data(5)
    Z, S, P = data.Z, data.simples, data.projectives

    @test !is_semisimple(Z) && !is_multifusion(Z) && !is_modular(Z)
    @test length(S) == 2
    @test all(X -> any(Y -> is_isomorphic(X, data.embedding(Y))[1], simples(data.V)), S)
    @test [int_dim(Hom(X, Y)) for X in P, Y in S] == [1 0; 0 1]
    @test [int_dim(Hom(X, Y)) for X in P, Y in P] == [2 1; 1 3]

    decomposition = decomposition_isomorphism(P[1] ⊕ P[1], [(P[1], 2)];
                                               rng=MersenneTwister(20260910))
    @test decomposition.isomorphism ∘ decomposition.inverse == id(P[1] ⊕ P[1])

    unit = one(Z)
    A = cokernel(only(basis(Hom(unit, P[1]))))[1]
    B = kernel(only(basis(Hom(P[1], unit))))[1]
    T = tensor_power_category([S; A; B])
    Q = Semisimplification(T)
    piece = semisimplified_piece(T, 4; quotient=Q)
    @test piece.tensor_closure_complete
    @test length(piece.indecomposables) == 10
    @test length(piece.representatives) == 8
    @test piece.all_images_split_simple

    # The generic Hom functor reads the self-braiding on the one-dimensional
    # quotient endomorphism space. GO, Theorem 4.16(2), gives the sign -1.
    QZ = Semisimplification(Z)
    qA = semisimplify(A, QZ)
    qbraid = semisimplify(braiding(A, A), QZ)
    H = Hom(qA ⊗ qA, :)
    @test matrix(H(qbraid)) == matrix(GF(5), 1, 1, [-1])
end

@testset "Ver_7^+ center projectives" begin
    data = _verlinde_center_data(7)
    S, P = data.simples, data.projectives
    @test length(S) == 3
    @test [object(X).components for X in S] ==
          [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    @test all(X -> int_dim(End(X)) == 1, S)
    @test [int_dim(Hom(X, Y)) for X in P, Y in S] ==
          [1 0 0; 0 1 0; 0 0 1]
    # GO, Theorem 3.4: C_ij=j(p-i)/2 for odd j<=i.
    @test [int_dim(Hom(X, Y)) for X in P, Y in P] ==
          [3 2 1; 2 6 3; 1 3 5]
end
