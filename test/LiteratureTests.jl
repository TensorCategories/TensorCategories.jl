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

# EGNO Proposition 2.6.1 identifies normalized tensorators on Vec_G with
# normalized 2-cocycles. For G=C3 with trivial associator, the identity
# cocycle supplies a solution. Unlike the C2 test above, this construction has
# polynomial variables and therefore exercises the equation solver.
@testset "Pointed polynomial tensorators" begin
    N = zeros(Int,3,3,3)
    for i in 1:3,j in 1:3
        N[i,j,mod(i+j-2,3)+1] = 1
    end
    C = six_j_category(QQ,N)
    set_one!(C,1)
    candidates = monoidal_structure_candidates(id(C))
    @test !isempty(candidates)
    # Production trusts the solved equations; the test independently checks
    # coherence, naturality, and invertibility of every returned tensorator.
    @test all(monoidal_functor_axiom,candidates)
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
    @test_throws ArgumentError set_spherical!(I,L.([1,1,2]);check=true)
    @test I.pivotal == old && is_spherical(I)
    set_pivotal!(I,L.([1,1,-1]))
    fresh = matrix(L,[L(tr(braiding(A,B) ∘ braiding(B,A)))
                      for A in simples(I),B in simples(I)])
    @test is_pivotal(I) && smatrix(I) == fresh && fresh != S
    cached = smatrix(I)
    cached[1,1] = 100
    @test smatrix(I) == fresh
    cache = get_attribute(I,:smatrix_by_objects)
    cached_S = only(values(cache))
    @test smatrix(I) == fresh && only(values(cache)) === cached_S

    # EGNO Section 8.10 gives theta=u^-1*j. Pivotal setters invalidate both
    # twist and S caches; recomputation must reflect the new pivotal sign.
    t = copy(TensorCategories.twists(I))
    @test TensorCategories.twists(I) === I.twist
    set_pivotal!(I,L.([1,1,1]))
    @test TensorCategories.twists(I) == t .* L.([1,1,-1])
    @test smatrix(I) == S

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
    source = lazy()
    Fcalls,Rcalls = Ref(0),Ref(0)
    Fprovider = get_attribute(source,:six_j_symbol)
    Rprovider = get_attribute(source,:r_symbol)
    set_attribute!(source,:six_j_symbol,
                   (indices...) -> (Fcalls[] += 1; Fprovider(indices...)))
    set_attribute!(source,:r_symbol,
                   (indices...) -> (Rcalls[] += 1; Rprovider(indices...)))
    E = extension_of_scalars(source,AcbField(64))
    @test Fcalls[] == Rcalls[] == 0
    @test !isassigned(E.ass,2,2,2,2)
    @test !isassigned(E.braiding,2,2,1)
    @test multiplication_table(E) == multiplication_table(eager)
    @test pentagon_axiom(E) && hexagon_axiom(E)
    E = extension_of_scalars(lazy(),QQBarField())
    @test pentagon_axiom(E) && hexagon_axiom(E)

    # Relabelling wraps the provider with the label and channel permutations;
    # it need not evaluate unrelated blocks.
    E = lazy()
    TensorCategories.sort_simples!(E,[4,2,1,3])
    @test !isassigned(E.ass,2,2,2,2)
    @test !isassigned(E.braiding,2,2,1)
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
                @test_throws ArgumentError load_numeric_fusion_category(bad,K;check=true)
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
            @test_throws ArgumentError set_canonical_spherical!(C;check=true)
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
            set_canonical_spherical!(C;check=true)
            @test is_spherical(C) && dim(C[2]) == d
        end
    end

    # Ball overlap is numerical evidence, not an exact certificate.
    A = ising_category(AcbField(64))
    old = copy(A.pivotal)
    @test_throws ArgumentError set_canonical_spherical!(A;check=true)
    @test A.pivotal == old

    # Over Q(sqrt(2)), positivity is relative to a chosen embedding.
    R,x = polynomial_ring(QQ,"x")
    L,r = number_field(x^2-2,"r")
    B = ising_category(L,r)
    set_pivotal!(B,L.([1,1,-1]))
    old = copy(B.pivotal)
    @test_throws ArgumentError set_canonical_spherical!(B;check=true)
    @test B.pivotal == old
    embedding = complex_embedding(L,sqrt(AcbField(128)(2)))
    set_canonical_spherical!(B;embedding=embedding,check=true)
    @test is_spherical(B) && dim(B[3]) == r
end

# Rowell--Stong--Wang, arXiv:0712.1377v4, Section 5.3.4: the Ising Hadamard
# F-matrix divided by sqrt(2) is unitary. QQBar proves the identity exactly;
# Acb can only show compatibility of its enclosures with that identity.
@testset "Exact certification versus numerical unitarity" begin
    E = ising_category(QQBarField())
    f = associator(E[3],E[3],E[3])
    @test is_unitary(f)

    C = ising_category(AcbField(64))
    g = associator(C[3],C[3],C[3])
    @test_throws ArgumentError is_unitary(g)
    @test is_unitary_numeric(g)
    @test is_unitary_numeric(C)
    @test !is_unitary_numeric(2*g)
    # The conservative category predicate reports absence of an exact
    # certificate over the current field, not nonunitarizability.
    @test !is_unitary(C)
    @test overlaps(tmatrix(C)[2,2],base_ring(C)(-1))
end

function literature_jordan_representation(C,n)
    F = base_ring(C)
    J = identity_matrix(F,n)
    for i in 1:n-1
        J[i,i+1] = 1
    end
    Representation(C,gens(base_group(C)),[J])
end

# Etingof--Ostrik, On semisimplification of tensor categories,
# arXiv:1801.04409v4, Definition 2.1 and the paragraph after Definition 2.5.
# The quotient functor need not preserve kernels upstairs; kernels and inverses
# must be computed from the trace-radical quotient Hom spaces.
@testset "Quotient kernels, cokernels, and inverses" begin
    F = GF(5)
    R = representation_category(F,cyclic_group(5))
    J1,J2,J5 = [literature_jordan_representation(R,n) for n in (1,2,5)]
    Q = Semisimplification(R)
    p = semisimplify(only(basis(Hom(J2,J1))),Q)
    i = semisimplify(only(basis(Hom(J1,J2))),Q)
    # J1 and J2 survive as distinct simples, so these opposite maps vanish.
    @test is_zero(p) && is_zero(i)
    K,k = kernel(p)
    C,c = cokernel(i)
    Kc,kc = kernel(p;check=true)
    Cc,cc = cokernel(i;check=true)
    @test dim(Kc) == dim(K) && is_zero(p ∘ kc)
    @test dim(Cc) == dim(C) && is_zero(cc ∘ i)
    @test dim(K) == dim(C) == F(2)
    @test inv(k) ∘ k == id(K)
    @test c ∘ inv(c) == id(C)

    # For N^2=0, (1+N)^-1=1-N already exists upstairs and is the fast path.
    q = semisimplify(morphism(J2,J2,matrix(F,[1 1;0 1])),Q)
    @test matrix(morphism(inv(q))) == matrix(F,[1 -1;0 1])
    @test inv(q;check=true) ∘ q == id(domain(q))
    @test is_zero(kernel(id(K))[1]) && is_zero(cokernel(id(K))[1])
    @test is_zero(inv(id(zero(Q))))

    # Every endomorphism of J5 has trace divisible by 5, so J5 becomes zero.
    disappearing = semisimplify(zero_morphism(J5,zero(R)),Q)
    @test is_zero(inv(disappearing)) && is_invertible(disappearing)
    @test_throws ArgumentError inv(p)
    @test !is_invertible(p)

    S,inc,proj = direct_sum(J1,J5)
    f = semisimplify(proj[1],Q)
    # The representative is rectangular, but the missing J5 summand vanishes.
    @test inv(f) == semisimplify(inc[1],Q)
    @test inv(f;check=true) == inv(f)
    @test inv(f) ∘ f == id(domain(f))
    @test f ∘ inv(f) == id(codomain(f))
    # This square representative is singular only on the negligible summand.
    e = semisimplify(inc[1] ∘ proj[1],Q)
    @test inv(e;check=true) == id(domain(e))
    dec = decompose(semisimplify(S,Q))
    @test length(dec) == 1 && dec[1][2] == 1
    @test dim(dec[1][1]) == F(1)

    X,ix,px = direct_sum(J1,J1,J2,J5)
    Y,iy,py = direct_sum(J1,J2,J2,J5)
    negligible = only(basis(Hom(J2,J1)))
    raw = iy[1] ∘ (px[1]+px[2]) + iy[2] ∘ px[3] + iy[4] ∘ px[4]
    raw += iy[1] ∘ negligible ∘ px[3]
    f = semisimplify(raw,Q)
    K,k = kernel(f)
    C,c = cokernel(f)
    @test dim(K) == F(1) && dim(C) == F(2)
    @test is_zero(f ∘ k) && is_zero(c ∘ f)
    @test left_inverse(k) ∘ k == id(K)
    @test c ∘ right_inverse(c) == id(C)
    for rawS in (J1,J2,J5)
        T = semisimplify(rawS,Q)
        H = basis(Hom(T,domain(f)))
        B = basis(Hom(T,codomain(f)))
        M = matrix(F,length(H),length(B),
            [a for h in H for a in express_in_basis(f ∘ h,B)])
        @test int_dim(Hom(T,K)) == length(H)-rank(M)
        @test int_dim(Hom(T,C)) == length(B)-rank(M)
    end
    @test composition_power(id(K),0) == id(K)
    @test composition_power(id(K),17) == id(K)
    @test_throws ArgumentError composition_power(id(K),-1)
end

# Etingof--Ostrik's negligible ideal tests traces against every opposite
# morphism, not only tr(id). For End(W)=F4 over F2 the field-trace pairing is
# nondegenerate, although dim(W)=0 in F2; compare the standard finite-field
# trace formula Tr_F4/F2(t)=t+t^2.
@testset "Zero-dimensional nonsplit quotient simple" begin
    F = GF(2)
    R = representation_category(F,cyclic_group(3))
    W = Representation(R,gens(base_group(R)),[matrix(F,[0 1;1 1])])
    T = tensor_power_category(W)
    Q = Semisimplification(T)
    @test sort(int_dim.(End.(simples(Q)))) == [1,2]
    @test length(decompose(semisimplify(first(indecomposables(T,1)),Q))) == 1

    Qraw = Semisimplification(R)
    Wq = semisimplify(W,Qraw)
    @test F(id(Wq)) == F(1)
    @test TensorCategories._quotient_inverse(id(Wq)) == id(Wq)
    @test !is_invertible(zero_morphism(Wq,Wq))
    a = semisimplify(morphism(W,W,matrix(F,[0 1;1 1])),Qraw)
    @test_throws ArgumentError F(a)

    X,ix,px = direct_sum(W,W)
    f = semisimplify(ix[1] ∘ px[1],Qraw)
    K,k = kernel(f)
    C,c = cokernel(f)
    @test int_dim(End(K)) == int_dim(End(C)) == 2
    @test is_zero(f ∘ k) && is_zero(c ∘ f)
    @test left_inverse(k) ∘ k == id(K)
    @test c ∘ right_inverse(c) == id(C)
end

# For an indecomposable X over a finite field, End(X)/rad End(X) is a finite
# division algebra and hence a finite field (Wedderburn). Its relative degree
# is the extension degree needed for absolute indecomposability. The radical
# itself must be retained; compare Krause, arXiv:1410.2822v1, Section 4, and
# K. Conrad, Finite Fields, Section 5.
@testset "Splitting finite families over finite fields" begin
    R = representation_category(GF(2),cyclic_group(3))
    W = Representation(R,gens(base_group(R)),[matrix(GF(2),[0 1;1 1])])
    @test is_simple(W) && int_dim(End(W)) == 2
    @test_throws ArgumentError split(W;max_degree=1)
    @test_throws ArgumentError split(Object[])
    @test_throws ArgumentError split(W;max_degree=0)

    result = split(W)
    @test order(result.field) == 4 && result.extension_degree == 2
    @test result.absolutely_indecomposable
    dec = only(result.decompositions)
    @test length(dec) == 2
    @test all(int_dim(End(X)) == 1 && m == 1 for (X,m) in dec)
    rebuilt = reduce(⊕,[X for (X,m) in dec for _ in 1:m])
    ok,iso = is_isomorphic(only(result.objects),rebuilt)
    @test ok && inv(iso) ∘ iso == id(only(result.objects))
    @test iso ∘ inv(iso) == id(rebuilt)
    f = extension_of_scalars(id(W),result.field,result.category;
                             embedding=result.embedding)
    @test f == id(only(result.objects))

    # No extension is introduced for zero or already absolutely split input.
    @test split(one(R)).category === R
    zero_result = split(zero(R))
    @test zero_result.extension_degree == 1
    @test isempty(only(zero_result.decompositions))
    @test base_ring(W) === GF(2)

    # Over F4, the two-dimensional C5-character splits over the relative
    # quadratic extension F16, not over a newly chosen prime-field model.
    R4 = representation_category(GF(4),cyclic_group(5))
    W4 = first(X for X in simples(R4) if int_dim(X) == 2)
    result4 = split(W4)
    @test order(result4.field) == 16 && result4.extension_degree == 2
    @test length(only(result4.decompositions)) == 2

    # J2 for C3 in characteristic three is already absolutely indecomposable:
    # its two-dimensional End algebra has a nilpotent radical and residue F3.
    R3 = representation_category(GF(3),cyclic_group(3))
    J2 = literature_jordan_representation(R3,2)
    nilpotent_result = split(J2)
    @test nilpotent_result.category === R3
    @test int_dim(End(only(nilpotent_result.objects))) == 2

    # Scalar extension also respects the tensor-power and semisimplification
    # wrappers used to study bounded tensor-generated subcategories.
    T = tensor_power_category(W)
    Q = Semisimplification(T)
    X = semisimplify(indecomposables(T,1)[2],Q)
    wrapped = split(X)
    @test length(only(wrapped.decompositions)) == 2
    @test all(int_dim(End(Y)) == 1 for (Y,_) in only(wrapped.decompositions))
    g = extension_of_scalars(id(X),wrapped.field,wrapped.category;
                             embedding=wrapped.embedding)
    @test g == id(only(wrapped.objects))
end
