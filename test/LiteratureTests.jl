# Tests in this file use exact examples from the literature but perform
# computations too substantial for the per-push quick suite.

# For G=C2 and trivial action on QQ*, EGNO Proposition 2.6.1 gives
# H^2(G,QQ*) = QQ*/(QQ*)^2. Thus J(g,g)=2 is coherent and cannot be gauge
# equivalent to J(g,g)=1. This is a counterexample to the former claim that
# the solver enumerated every monoidal structure.
@testset "Pointed tensorators over QQ" begin
    N = zeros(Int,2,2,2)
    N[1,1,1] = N[1,2,2] = N[2,1,2] = N[2,2,1] = 1
    C = six_j_category(QQ,N)
    set_one!(C,1)
    J = Dict((i,j) => (i == j == 2 ? QQ(2) : QQ(1))*id(C[i]⊗C[j])
             for i in 1:2,j in 1:2)
    F = monoidal_functor(id(C),simples(C),J)
    @test monoidal_functor_axiom(F)
    @test !is_square(QQ(2))

    candidates = monoidal_structure_candidates(id(C))
    @test !isempty(candidates)
    @test all(monoidal_functor_axiom,candidates)
    @test all(monoidal_structure(G,C[2],C[2]) != J[(2,2)]
              for G in candidates)
end

# Rowell--Stong--Wang, arXiv:0712.1377v4, Section 5.3.2 gives the exact
# Ising modular data. EGNO Sections 4.7 and 8.13 require a pivotal structure
# to be monoidal and define S using the pivotal trace.
@testset "Ising modular and pivotal data" begin
    L,_ = cyclotomic_field(16)
    I = ising_category(L)
    S = smatrix(I)
    perm = [3,2,1]
    # An argument-dependent S-matrix must preserve the requested order and
    # must not poison a later full matrix through a category-wide cache.
    @test smatrix(I,simples(I)[perm]) == S[perm,perm]
    @test size(smatrix(I,[one(I)])) == (1,1)
    @test size(smatrix(I)) == (3,3)
    @test normalized_smatrix(I,simples(I)[perm]) ==
          normalized_smatrix(I)[perm,perm]

    # Scaling the sigma component by two preserves equality of left and right
    # dimensions but violates monoidality of the pivotal structure.
    old = copy(I.pivotal)
    @test_throws ArgumentError set_spherical!(I,L.([1,1,2]))
    @test I.pivotal == old && is_spherical(I)
    set_pivotal!(I,L.([1,1,-1]))
    fresh = matrix(L,[L(tr(braiding(A,B) ∘ braiding(B,A)))
                      for A in simples(I),B in simples(I)])
    @test is_pivotal(I) && smatrix(I) == fresh && fresh != S
    cached = smatrix(I)
    cached[1,1] = 100
    @test smatrix(I) == fresh

    # Multiplying one non-unit F-matrix by two violates the pentagon.
    J = ising_category(L)
    set_associator!(J,3,3,3,3,2*J.ass[3,3,3,3])
    @test !pentagon_axiom(J)
end

# Rowell--Stong--Wang, arXiv:0712.1377v4, Section 5.3.4: the nontrivial
# F(sigma,sigma,sigma;sigma) block is a Hadamard matrix divided by sqrt(2).
# Swapping the unit and fermion therefore also swaps its intermediate-channel
# rows and columns; permuting only the four outer labels breaks the pentagon.
@testset "Relabeling transports Ising fusion channels" begin
    K,_ = cyclotomic_field(16)
    C = ising_category(K)
    p = [2,1,3]
    dims = dim.(simples(C))
    S = smatrix(C)
    F = copy(C.ass)
    TensorCategories.sort_simples!(C,p)
    @test pentagon_axiom(C) && hexagon_axiom(C) && is_pivotal(C)
    @test dim.(simples(C)) == dims[p]
    @test smatrix(C) == S[p,p]

    TensorCategories.sort_simples!(C,invperm(p))
    @test C.ass == F
    @test_throws ArgumentError TensorCategories.sort_simples!(C,[1,1,3])
    @test C.ass == F
end

# EGNO Section 4.6: Deligne products transport associators and braidings
# componentwise. Deferred storage is an implementation detail, so exporting,
# relabelling, or extending scalars must give the same structural maps as the
# eager construction.
@testset "Deferred structural data and coefficient transport" begin
    N = zeros(Int,2,2,2)
    N[1,1,1] = N[1,2,2] = N[2,1,2] = N[2,2,1] = 1
    C = six_j_category(QQ,N,["1","g"])
    set_one!(C,1)
    set_braiding!(C,[identity_matrix(QQ,N[i,j,k])
                     for i in 1:2,j in 1:2,k in 1:2])
    eager = tensor_product(C,C)
    lazy() = tensor_product(C,C,String[],String[],true)

    D = lazy()
    @test TensorCategories.F_symbols(D) == TensorCategories.F_symbols(eager)
    @test R_symbols(D) == R_symbols(eager)

    # QQ has canonical maps to Acb and QQBar; neither requires choosing a
    # number-field embedding, even when the source symbols are still lazy.
    E = extension_of_scalars(lazy(),AcbField(64))
    @test multiplication_table(E) == multiplication_table(eager)
    @test pentagon_axiom(E) && hexagon_axiom(E)
    E = extension_of_scalars(lazy(),QQBarField())
    @test pentagon_axiom(E) && hexagon_axiom(E)

    # A provider closes over the old labels, so relabelling must materialize
    # it before mutating the fusion rules.
    E = lazy()
    TensorCategories.sort_simples!(E,[4,2,1,3])
    @test pentagon_axiom(E) && hexagon_axiom(E)

    # For a number field, choose the image of its primitive element once and
    # evaluate every coefficient through that exact homomorphism.
    R,x = polynomial_ring(QQ,"x")
    L,r = number_field(x^2-2,"r")
    B = ising_category(L,r)
    embedding = complex_embedding(L,sqrt(AcbField(128)(2)))
    D = extension_of_scalars(B,QQBarField(),embedding)
    @test pentagon_axiom(D)
    @test dim(D[3]) == sqrt(QQBarField()(2))
    E = extension_of_scalars(B,QQBarField();embedding=embedding)
    @test E.ass == D.ass && E.pivotal == D.pivotal
end

# Complete F-symbol paths determine the fusion multiplicities and tensor unit
# independently of label order (EGNO Sections 4.6 and 4.9). The chosen pivotal
# structure is additional data and must be preserved or supplied explicitly.
@testset "CSV preserves labels, unit, and pivotal data" begin
    N = zeros(Int,2,2,2)
    N[1,1,1] = N[1,2,2] = N[2,1,2] = N[2,2,1] = 1
    C = six_j_category(QQ,N,["1","g"])
    set_one!(C,1)
    set_braiding!(C,[identity_matrix(QQ,N[i,j,k])
                     for i in 1:2,j in 1:2,k in 1:2])
    set_name!(C,"Vec_C2")
    TensorCategories.sort_simples!(C,[2,1])
    set_spherical!(C,QQ.([-1,1]))
    I = ising_category(AcbField(128))
    TensorCategories.sort_simples!(I,[3,1,2])
    K = AcbField(64)

    mktempdir() do dir
        # Exact package files include the non-first unit and chosen pivotal
        # character; their loader must not reconstruct from label 1.
        save_fusion_category(C,dir,"relabeled-c2")
        D = load_fusion_category(joinpath(dir,"relabeled-c2"))
        @test multiplication_table(D) == multiplication_table(C)
        @test D.one == C.one && D.pivotal == C.pivotal

        for (j,A) in enumerate((C,I))
            f = joinpath(dir,"F$j.csv")
            r = joinpath(dir,"R$j.csv")
            P = AcbField(128)
            original = TensorCategories.F_symbols(A)
            numeric_symbols_to_csv(f,Dict(k => P(v) for (k,v) in original))
            numeric_symbols_to_csv(r,Dict(k => P(v) for (k,v) in R_symbols(A)))
            for with_R in (false,true)
                D = with_R ?
                    load_numeric_fusion_category(f,r,K;pivotal=A.pivotal) :
                    load_numeric_fusion_category(f,K;pivotal=A.pivotal)
                @test multiplication_table(D) == multiplication_table(A)
                @test D.one == A.one
                loaded = TensorCategories.F_symbols(D)
                @test Set(keys(loaded)) == Set(keys(original))
                @test all(overlaps(loaded[k],P(v)) for (k,v) in original)
                @test D.pivotal == K.(A.pivotal) && is_pivotal(D)
                @test pentagon_axiom(D)
                with_R && @test hexagon_axiom(D)
            end
            @test_throws ArgumentError load_numeric_fusion_category(f,K;unit=1)
            if j == 1
                # Omitting one admissible scalar block makes the associator
                # incomplete even when its numerical value would be zero.
                incomplete = Dict(k => P(v) for (k,v) in original)
                delete!(incomplete,[1,1,1,1,2,2])
                bad = joinpath(dir,"incomplete.csv")
                numeric_symbols_to_csv(bad,incomplete)
                @test_throws ArgumentError load_numeric_fusion_category(bad,K)
            end
        end
    end
end

# EGNO Proposition 9.5.1 supplies the positive spherical structure under the
# pseudounitary hypothesis. It cannot be imposed on an arbitrary fusion
# category from fusion rules alone. Rowell--Stong--Wang, arXiv:0712.1377v4,
# pages 3--4 identify Fibonacci and its Yang--Lee Galois conjugate.
@testset "Canonical spherical structure checks existence" begin
    K = QQBarField()
    for q in 1:2
        C = fibonacci_category(K,q)
        old = copy(C.pivotal)
        d = dim(C[2])
        if d < 0
            # If X^2=1+X, a tensor automorphism component a must satisfy both
            # a^2=1 and a^2=a, hence a=1. Yang--Lee cannot be normalized to
            # the positive Fibonacci dimension character.
            @test_throws ArgumentError set_canonical_spherical!(C)
            @test C.pivotal == old
            @test is_pivotal(C) && dim(C[2]) == d

            # Numeric import must likewise leave this dimension character
            # alone rather than silently claim a positive spherical structure.
            mktempdir() do dir
                A = AcbField(128)
                file = joinpath(dir,"yang-lee.csv")
                numeric_symbols_to_csv(file,Dict(k => A(v)
                    for (k,v) in TensorCategories.F_symbols(C)))
                D = load_numeric_fusion_category(file,AcbField(64))
                @test is_pivotal(D)
                @test overlaps(dim(D[2]),AcbField(64)(d))
            end
        else
            set_canonical_spherical!(C)
            @test is_spherical(C) && dim(C[2]) == d
        end
    end

    # Ball overlap is numerical evidence, not an exact certificate.
    A = ising_category(AcbField(64))
    old = copy(A.pivotal)
    @test_throws ArgumentError set_canonical_spherical!(A)
    @test A.pivotal == old

    # Over Q(sqrt(2)), positivity is relative to a chosen embedding.
    R,x = polynomial_ring(QQ,"x")
    L,r = number_field(x^2-2,"r")
    B = ising_category(L,r)
    set_pivotal!(B,L.([1,1,-1]))
    old = copy(B.pivotal)
    @test_throws ArgumentError set_canonical_spherical!(B)
    @test B.pivotal == old
    embedding = complex_embedding(L,sqrt(AcbField(128)(2)))
    set_canonical_spherical!(B;embedding=embedding)
    @test is_spherical(B) && dim(B[3]) == r
end
