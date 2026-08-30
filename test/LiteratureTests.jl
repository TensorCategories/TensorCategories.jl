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
    @test I.pivotal == old && is_spherical(I;check=true)
    set_pivotal!(I,L.([1,1,-1]))
    fresh = matrix(L,[L(tr(braiding(A,B) ∘ braiding(B,A)))
                      for A in simples(I),B in simples(I)])
    @test is_pivotal(I;check=true) && smatrix(I) == fresh && fresh != S
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
    @test pentagon_axiom(C) && hexagon_axiom(C) && is_pivotal(C;check=true)
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
    # RSW Section 5.3.2 supplies this spherical Ising structure. Its
    # declaration, as well as its coefficients, must cross the same embedding.
    set_spherical!(B,copy(B.pivotal))
    embedding = complex_embedding(L,sqrt(AcbField(128)(2)))
    D = extension_of_scalars(B,QQBarField(),embedding)
    @test is_pivotal(D) && is_spherical(D)
    @test pentagon_axiom(D)
    @test dim(D[3]) == sqrt(QQBarField()(2))
    @test is_pivotal(D;check=true) && is_spherical(D;check=true)
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
                @test D.pivotal == K.(A.pivotal) && is_pivotal(D;check=true)
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

                # This dictionary is complete and dimensionally valid, but a
                # unit-containing F-symbol is not the normalized identity.
                # The checked loader must enforce the skeletal unit convention.
                badunit = Dict(k => P(v) for (k,v) in original)
                u = only(findall(!iszero,A.one))
                key = first(k for (k,v) in badunit if k[1] == u && !iszero(v))
                badunit[key] = 2*badunit[key]
                unitfile = joinpath(dir,"bad-unit.csv")
                numeric_symbols_to_csv(unitfile,badunit)
                @test_throws ArgumentError load_numeric_fusion_category(
                    unitfile,K;check=true)
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
            @test is_pivotal(C;check=true) && dim(C[2]) == d

            # Numeric import must likewise leave this dimension character
            # alone rather than silently claim a positive spherical structure.
            mktempdir() do dir
                A = AcbField(128)
                file = joinpath(dir,"yang-lee.csv")
                numeric_symbols_to_csv(file,Dict(k => A(v)
                    for (k,v) in TensorCategories.F_symbols(C)))
                D = load_numeric_fusion_category(file,AcbField(64))
                @test is_pivotal(D;check=true)
                @test overlaps(dim(D[2]),AcbField(64)(d))
            end
        else
            set_canonical_spherical!(C;check=true)
            @test is_spherical(C;check=true) && dim(C[2]) == d
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
    @test is_spherical(B;check=true) && dim(B[3]) == r
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

function literature_nonsplit_center_object()
    F = GF(2)
    N = zeros(Int,3,3,3)
    for i in 1:3,j in 1:3
        N[i,j,mod(i+j-2,3)+1] = 1
    end
    C = six_j_category(F,N,["1","g","g2"])
    set_one!(C,1)
    Z = center(C)
    U = one(C) ⊕ one(C)
    A = matrix(F,[0 1;1 1])
    gamma = [morphism(U⊗S,S⊗U,
                [k == j ? A^(j-1) : zero_matrix(F,0,0) for k in 1:3])
             for (j,S) in enumerate(simples(C))]
    C,Z,CenterObject(Z,U,gamma)
end

# EGNO Example 8.5.4 identifies Z(Vec_C3) with C3-graded C3-modules. The
# irreducible polynomial x^2+x+1 gives a two-dimensional simple over F2 whose
# endomorphism field is F4. Local center algorithms must not enumerate all
# ambient simples and must decompose the full End algebra, including radicals.
@testset "Finite-field center objects" begin
    _,Z,X = literature_nonsplit_center_object()
    @test is_central(X) && int_dim(End(X)) == 2
    @test is_simple(X)
    @test !isdefined(Z,:simples)

    dec = decompose(X ⊕ X)
    @test length(dec) == 1 && dec[1][2] == 2
    @test is_isomorphic(dec[1][1],X)[1]
    Y = CenterObject(Z,object(X),copy(half_braiding(X)))
    ok,f = is_isomorphic(X,Y)
    @test ok && inv(f) ∘ f == id(X) && f ∘ inv(f) == id(Y)
    @test !isdefined(Z,:simples)

    family = split(X)
    @test order(family.field) == 4 && family.extension_degree == 2
    @test !isdefined(Z,:simples) && !isdefined(family.category,:simples)
    @test length(only(family.decompositions)) == 2
    @test all(is_central(S) && int_dim(End(S)) == 1
              for (S,_) in only(family.decompositions))
    fL = extension_of_scalars(id(X),family.field,family.category;
                              embedding=family.embedding)
    @test is_central(morphism(fL),domain(fL),codomain(fL))
    @test fL == id(only(family.objects))

    # Category-level extension intentionally enumerates all simples. The two
    # nonsplit F4 endomorphism fields split, raising the rank from six to nine;
    # a cached six-by-six fusion table therefore cannot be transported.
    S = simples(Z;sort=false)
    @test length(S) == 6
    @test is_weak_multifusion(Z) && !is_multifusion(Z) && !is_fusion(Z)
    @test size(multiplication_table(Z)) == (6,6,6)
    D = extension_of_scalars(Z,GF(4))
    @test length(simples(D)) == 9
    @test is_multifusion(D) && is_fusion(D)
    @test !has_attribute(D,:multiplication_table)
    splitZ,_ = split(Z)
    @test length(simples(splitZ)) == 9
    @test all(int_dim(End(S)) == 1 for S in simples(splitZ))
end
# Cross-backend literature benchmarks, included by the full suite only.
# Direct central Hom calculations are independent of the optimized
# S-matrix/Verlinde multiplication-table implementation.
# RSW, On classification of modular tensor categories, arXiv:0712.1377v4,
# §5.3.1: s²=1, F(s,s,s;s)=-1, R(s,s;1)=i, d(s)=1, theta(s)=i.
function semion_fixture(K, imaginary_unit)
    N=zeros(Int,2,2,2)
    N[1,1,1]=N[1,2,2]=N[2,1,2]=N[2,2,1]=1
    C=six_j_category(K,N,["1","s"])
    set_one!(C,1); set_name!(C,"Semion literature fixture")
    set_associator!(C,2,2,2,2,matrix(K,1,1,[-1]))
    set_braiding!(C,[N[i,j,k]==0 ? zero_matrix(K,0,0) :
        matrix(K,1,1,[i==j==2 ? imaginary_unit : K(1)]) for i=1:2,j=1:2,k=1:2])
    # The skeletal duality convention uses ev_s=-1. Thus j_s=-1 gives d_s=1.
    set_pivotal!(C,K.([1,-1]))
    C
end

# RSW §5.3.8. Label order (1,e,m,epsilon), with e=(1,0), m=(0,1).
# The bicharacter R((a,b),(c,d))=(-1)^(bc) has q(a,b)=(-1)^(ab).
function toric_fixture(K=QQ)
    labels=[(0,0),(1,0),(0,1),(1,1)]
    N=zeros(Int,4,4,4)
    for i=1:4,j=1:4
        a,b=labels[i]; c,d=labels[j]
        k=findfirst(==((mod(a+c,2),mod(b+d,2))),labels)
        N[i,j,k]=1
    end
    C=six_j_category(K,N,["1","e","m","epsilon"])
    set_one!(C,1); set_name!(C,"Toric-code literature fixture")
    set_braiding!(C,[N[i,j,k]==0 ? zero_matrix(K,0,0) :
        matrix(K,1,1,[(-1)^(labels[i][2]*labels[j][1])]) for i=1:4,j=1:4,k=1:4])
    C
end

# EGNO, Tensor Categories (2015), §§8.13–8.16:
# https://math.mit.edu/~etingof/egnobookfinal.pdf.
# These are consequences of modularity, checked independently of the
# implementation's is_modular predicate. S is UNNORMALIZED positive monodromy.
function modular_checks(C)
    K=base_ring(C); objects=simples(C); n=length(objects)
    d=dim.(objects); theta=[K(twist(s)) for s in objects]
    S=smatrix(C); T=tmatrix(C)
    N = if C isa CenterCategory
        # Independent route: the center's default multiplication_table itself
        # uses Verlinde. Count actual central intertwiners instead, so that
        # comparison with the S-matrix formula below is not circular.
        products=[s⊗t for s in objects,t in objects]
        direct=[int_dim(Hom(products[i,j],objects[k])) for i=1:n,j=1:n,k=1:n]
        # These examples are split, hence Hom dimensions ARE multiplicities
        # (Schur's lemma, EGNO §1.5). Compare the optimized implementation too.
        @test multiplication_table(C)==direct
        direct
    else
        multiplication_table(C)
    end
    D=sum(d.^2); u=findfirst(s->is_isomorphic(s,one(C))[1],objects)
    conjugation=matrix(K,[Int(is_isomorphic(dual(s),t)[1]) for s in objects,t in objects])
    # EGNO Prop. 8.13.8: balancing computes S from fusion, twists, dimensions.
    @test S == matrix(K,[sum(N[i,j,k]*theta[k]*d[k] for k=1:n)/(theta[i]*theta[j]) for i=1:n,j=1:n])
    # EGNO Remark 8.13.3 and Prop. 8.14.2: symmetry, unit row and charge conjugation.
    @test S == transpose(S) && [S[u,i] for i=1:n] == d
    @test S^2 == D*conjugation
    # EGNO Prop. 8.15.4: the two Gauss sums multiply to global dimension.
    tauplus=sum(theta.*d.^2); tauminus=sum(inv.(theta).*d.^2)
    @test tauplus*tauminus == D
    # EGNO Thm. 8.16.1 uses T_EGNO=diag(theta^-1), unlike this package's T.
    @test T == diagonal_matrix(theta)
    @test (S*inv(T))^3 == tauminus*S^2
    # EGNO §8.14: the Verlinde formula must recover EVERY integer coefficient.
    Sinv=inv(S)
    @test all(sum(S[i,l]*S[j,l]*Sinv[l,k]/S[u,l] for l=1:n)==N[i,j,k] for i=1:n,j=1:n,k=1:n)
end

# EGNO, Proposition 9.2.2 (p. 278), for the forgetful functor
# F: Z(C) -> C and its right adjoint I:
#     F I(Y) = direct_sum_X X tensor Y tensor X^*.
# In a split fusion category, if B[a,i] = [F(Z_a):X_i], adjunction and
# semisimplicity give B'B[i,j] = [F I(X_j):X_i].  The right-adjunction
# routine is checked below as an actual linear isomorphism of Hom spaces,
# not just by comparing their dimensions.
function center_induction_checks(C,Z; check_maps=false)
    X,Zs=simples(C),simples(Z)
    @test is_split_semisimple(C) && all(int_dim(End(z))==1 for z in Zs)
    B=[int_dim(Hom(X[i],object(Zs[a]))) for a=eachindex(Zs),i=eachindex(X)]
    gram=transpose(B)*B
    # Compute (9.4) directly from tensor products, without calling the
    # package's induction_restriction implementation being tested.
    expected=[sum(int_dim(Hom(X[i],s⊗X[j]⊗dual(s))) for s in X)
        for i=eachindex(X),j=eachindex(X)]
    @test gram==expected
    check_maps || return
    for x in X, z in Zs
        H=Hom(object(z),x)
        isempty(basis(H)) && continue
        Ix=induction(x;parent_category=Z)
        image=induction_right_adjunction(H,z,Ix)
        ambient=Hom(z,Ix)
        @test int_dim(image)==int_dim(H)==int_dim(ambient)
        # Expressing the constructed maps in the independently computed
        # central Hom basis checks both centrality and surjectivity.
        coordinates=[express_in_basis(f,basis(ambient)) for f in basis(image)]
        A=matrix(base_ring(C),length(coordinates),int_dim(ambient),vcat(coordinates...))
        @test rank(A)==int_dim(ambient)
    end
end

# Müger, arXiv:math/0111205v1, Theorem 1.2:
# https://arxiv.org/pdf/math/0111205v1
# For a split spherical fusion category, scalar extension of the stated
# algebraically-closed-field result gives BOTH Gauss sums of its center:
#     sum_Z theta_Z^(+/-1) dim(Z)^2 = dim(C).
# This is strictly stronger than the product identity in modular_checks.
function center_gauss_checks(C,Z)
    D=sum(dim(x)^2 for x in simples(C))
    Zs=simples(Z); d=dim.(Zs); theta=twist_scalar.(Zs)
    @test sum(theta.*d.^2)==D
    @test sum(inv.(theta).*d.^2)==D
end

# The package's historical Rep(A4) F-symbol fixture predates Oscar's current
# serializer schema. Decode that fixed exact input without changing it. The
# independent oracle below comes from group characters, not from this file.
function a4_rep_fixture()
    path=joinpath(dirname(pathof(TensorCategories)),"SixJCategoryDatabase","Rep_A4.mrdi")
    d=Oscar.JSON.parsefile(path)["data"]
    K,a=number_field(polynomial(QQ,[1,-1,1]),"a")
    rational(c)=(q=split(c,"//"); length(q)==1 ? QQ(parse(BigInt,q[1])) :
        QQ(parse(BigInt,q[1]),parse(BigInt,q[2])))
    scalar(x)=sum(rational(c)*a^parse(Int,e) for (e,c) in x;init=zero(K))
    mat(x)=isempty(x) ? zero_matrix(K,0,0) :
        matrix(K,length(x),length(x[1]),[scalar(c) for row in x for c in row])
    n=parse(Int,d["simples"])
    C=six_j_category(K,reshape(parse.(Int,d["tensor_product"]),n,n,n),
        String.(d["simples_names"]))
    set_one!(C,parse.(Int,d["one"]))
    set_associator!(C,reshape(mat.(d["ass"]),n,n,n,n))
    # Rep(A4) is pseudounitary. EGNO Proposition 9.5.1 gives its canonical
    # spherical structure, with dimensions 1,1,1,3. Check it exactly here.
    set_canonical_spherical!(C;embedding=complex_embeddings(K)[1],check=true)
    C
end


const A4Perm = NTuple{4,Int}
a4_mul(p::A4Perm,q::A4Perm)=ntuple(i->p[q[i]],4)
a4_inv(p::A4Perm)=ntuple(i->findfirst(==(i),p),4)
a4_conj(p::A4Perm,q::A4Perm)=a4_mul(p,a4_mul(q,a4_inv(p)))
a4_power(p::A4Perm,n::Int)=foldl((q,_)->a4_mul(q,p),1:n;init=(1,2,3,4))

# EGNO Example 8.13.6 and formula (8.47), pp. 224--225, give the simple
# labels (conjugacy class, irreducible centralizer character), dimensions,
# twists and every S-entry of Z(Vec_G).  Morita invariance identifies this
# with Z(Rep(G)); see EGNO Theorem 8.12.3.  For A4 the character data are
# generated below from its permutations, rather than copied from the center.
function a4_double_modular_data(K,a)
    G=A4Perm[]
    for i=1:4,j=1:4,k=1:4,l=1:4
        p=(i,j,k,l); allunique(p)||continue
        iseven(sum(p[r]>p[s] for r=1:4 for s=r+1:4))&&push!(G,p)
    end
    e=(1,2,3,4); r2=(2,1,4,3); r3=(2,3,1,4); r3i=a4_inv(r3)
    centralizer(g)=[x for x in G if a4_mul(x,g)==a4_mul(g,x)]
    conjugacy_class(g)=Set(a4_conj(x,g) for x in G)
    V4class=conjugacy_class(r2); C3=conjugacy_class(r3); zeta=a^2
    # The three linear A4 characters factor through A4/V4 = C3.  The
    # remaining character is the four-point permutation character minus 1.
    a4_character(j,x)=x==e||x in V4class ? K(1) : x in C3 ? zeta^j : zeta^(2j)
    standard_character(x)=x==e ? K(3) : x in V4class ? -K(1) : K(0)
    V4=centralizer(r2); b=first(x for x in V4 if x!=e&&x!=r2)
    function v4_character(u,v,x)
        exponents=first((i,j) for i=0:1 for j=0:1
            if a4_mul(a4_power(r2,i),a4_power(b,j))==x)
        K((-1)^(u*exponents[1]+v*exponents[2]))
    end
    c3_character(rep,j,x)=K(zeta^(j*first(m for m=0:2 if a4_power(rep,m)==x)))
    labels=Any[]
    for j=0:2; push!(labels,(r=e,C=G,ch=x->a4_character(j,x),degree=K(1))); end
    push!(labels,(r=e,C=G,ch=standard_character,degree=K(3)))
    for u=0:1,v=0:1
        push!(labels,(r=r2,C=V4,ch=x->v4_character(u,v,x),degree=K(1)))
    end
    for rep in (r3,r3i),j=0:2
        push!(labels,(r=rep,C=centralizer(rep),
            ch=x->c3_character(rep,j,x),degree=K(1)))
    end
    dimensions=[K(12)*q.degree/K(length(q.C)) for q in labels]
    theta=[q.ch(q.r)/q.degree for q in labels]
    S=matrix(K,[K(12)/(K(length(q.C))*K(length(t.C)))*
        sum(q.ch(a4_conj(x,t.r))*t.ch(a4_conj(a4_inv(x),q.r))
            for x in G if a4_mul(q.r,a4_conj(x,t.r))==a4_mul(a4_conj(x,t.r),q.r);
            init=K(0)) for q in labels,t in labels])
    dimensions,theta,S
end

function simultaneous_modular_permutation(expected_d,expected_t,expected_S,Zs,actual_S)
    actual_d,actual_t=dim.(Zs),twist_scalar.(Zs)
    candidates=[[j for j=eachindex(Zs) if expected_d[i]==actual_d[j]&&
        expected_t[i]==actual_t[j]] for i=eachindex(expected_d)]
    permutation=zeros(Int,length(Zs)); order=sortperm(length.(candidates))
    function search(depth)
        depth>length(order)&&return copy(permutation)
        i=order[depth]
        for j in candidates[i]
            j in permutation&&continue
            permutation[i]=j; assigned=findall(!iszero,permutation)
            if all(expected_S[x,y]==actual_S[permutation[x],permutation[y]]
                    for x in assigned,y in assigned)
                result=search(depth+1)
                result===nothing||return result
            end
            permutation[i]=0
        end
        nothing
    end
    search(1)
end

@testset "Independent modular-data benchmarks" begin
    K,z=cyclotomic_field(8); C=semion_fixture(K,z^2)
    # RSW §5.3.1: the nontrivial cocycle and braiding satisfy both coherence axioms.
    @test pentagon_axiom(C) && hexagon_axiom(C)
    # Positive dimension is obtained from the pivotal convention explained above.
    @test is_pivotal(C;check=true) && is_spherical(C;check=true) &&
          dim.(simples(C))==K.([1,1])
    @test smatrix(C)==matrix(K,[1 1;1 -1]) && tmatrix(C)==diagonal_matrix([K(1),z^2])
    modular_checks(C)
    D=toric_fixture()
    # RSW §5.3.8: the trivial associator and bilinear braiding give toric-code data.
    @test pentagon_axiom(D) && hexagon_axiom(D)
    @test smatrix(D)==matrix(QQ,[1 1 1 1;1 1 -1 -1;1 -1 1 -1;1 -1 -1 1])
    @test tmatrix(D)==diagonal_matrix(QQ.([1,1,1,-1]))
    modular_checks(D)
end
flush(stdout)

@testset "Semion center and toric-code center" begin
    K,z=cyclotomic_field(8); C=semion_fixture(K,z^2); Z=center(C); S=simples(Z)
    # Müger, arXiv:math/0111205v1, Thm. 7.10: Z(C) ≃ C ⊠ C^rev for modular C.
    # This predicts four invertible objects with twists {1,1,i,-i}. Matching
    # these invariants is a test of the construction, not a proof of equivalence.
    @test length(S)==4 && all(dim(s)==1 for s in S)
    @test all(is_central,S)
    theta=[K(twist(s)) for s in S]
    @test count(==(K(1)),theta)==2 && z^2 in theta && -z^2 in theta
    @test all(is_isomorphic(s⊗s,one(Z))[1] for s in S)
    # EGNO §8.10: theta is a natural endomorphism on EVERY object. For
    # 1⊕s in the semion factor its two eigenvalues are 1 and i, so no
    # single scalar represents it. This caught the center's scalar-only API.
    a = findfirst(==(z^2),theta); b = findfirst(==(K(1)),theta)
    X,inc,proj = direct_sum(S[a],S[b]); t = twist(X)
    @test domain(t) == codomain(t) == X
    @test t ∘ inc[1] == inc[1] ∘ twist(S[a]) && t ∘ inc[2] == inc[2] ∘ twist(S[b])
    @test_throws ArgumentError twist_scalar(X)
    modular_checks(Z)
    center_gauss_checks(C,Z)
    # RSW §5.3.8 realizes toric code as D(C2); EGNO Example 8.13.6 gives
    # its four (group element, character) labels and twists chi(g).
    VC2=graded_vector_spaces(QQ,cyclic_group(2)); W=center(VC2); P=simples(W)
    @test length(P)==4 && all(dim(s)==1 for s in P)
    @test count(s->QQ(twist(s))==-1,P)==1 && count(s->QQ(twist(s))==1,P)==3
    @test all(is_central,P)
    modular_checks(W)
    center_gauss_checks(VC2,W)
end
flush(stdout)

@testset "Nonabelian quantum double of S3" begin
    K,z=cyclotomic_field(3)
    Z=center(graded_vector_spaces(K,symmetric_group(3))); S=simples(Z)
    # EGNO Example 8.13.6 and formula (8.47). The three conjugacy classes
    # have sizes 1,3,2 and centralizers S3,C2,C3. Their irreducible dimensions
    # give [1,1,2], [3,3], [2,2,2], and twists 1, +/-1, and cube roots.
    @test length(S)==8 && all(int_dim(End(s))==1 for s in S)
    @test count(s->dim(s)==1,S)==2 && count(s->dim(s)==2,S)==4 && count(s->dim(s)==3,S)==2
    theta=[K(twist(s)) for s in S]
    @test count(==(K(1)),theta)==5 && count(==(-K(1)),theta)==1 && z in theta && z^2 in theta
    # EGNO Thm. 7.16.6: FPdim Z(Vec_S3)=6², here also the spherical dimension.
    @test sum(dim(s)^2 for s in S)==36 && all(is_central,S)
    modular_checks(Z)
    center_induction_checks(category(Z),Z;check_maps=true)
    center_gauss_checks(category(Z),Z)
end
flush(stdout)

@testset "Character-theoretic quantum double of A4" begin
    C=a4_rep_fixture(); K=base_ring(C)
    # The ordinary A4 character table gives degrees 1,1,1,3 and
    # V⊗V=1+chi+chi^2+2V. This explicitly exercises multiplicity two.
    @test dim.(simples(C))==K.([1,1,1,3])
    @test C.tensor_product[4,4,:]==[1,1,1,2]
    @test pentagon_axiom(C)
    Z=center(C); Zs=simples(Z)
    expected_d,expected_t,expected_S=a4_double_modular_data(K,gen(K))
    permutation=simultaneous_modular_permutation(
        expected_d,expected_t,expected_S,Zs,smatrix(Z))
    # EGNO Example 8.13.6 predicts 14 split simples with dimensions
    # 1^3, 3^5, 4^6. Matching the full S and T data fixes one simultaneous
    # relabeling; separate multisets would miss correlations between entries.
    @test length(Zs)==14&&all(int_dim(End(z))==1 for z in Zs)
    @test count(==(K(1)),dim.(Zs))==3
    @test count(==(K(3)),dim.(Zs))==5
    @test count(==(K(4)),dim.(Zs))==6
    @test permutation!==nothing
    if permutation!==nothing
        @test twist_scalar.(Zs[permutation])==expected_t
        @test smatrix(Z)[permutation,permutation]==expected_S
        # Label 4 is the identity-flux three-dimensional representation V.
        # Check its multiplicity two directly in the central Hom space, not
        # through Verlinde's formula or the expected character table.
        V=Zs[permutation[4]]
        @test int_dim(Hom(V⊗V,V))==2
    end
    center_induction_checks(C,Z)
    center_gauss_checks(C,Z)
end
flush(stdout)

@testset "TY signs and numerical Ising data" begin
    # Gelaki–Naidu–Nikshych, Centers of graded fusion categories (2009), §4A:
    # https://msp.org/ant/2009/3-8/ant-v3-n8-p05-s.pdf.
    # Their tau is the RECIPROCAL of this constructor's sqrt(|A|) argument.
    # Both signs give fusion categories. With the stored pivotal maps 1,
    # categorical dim(m) is signed, while FPdim(m)=sqrt(|A|) stays positive.
    for sign in (1,-1)
        C=tambara_yamagami(QQ,abelian_group(PcGroup,[2,2]),QQ(sign*2)); S=simples(C)
        @test pentagon_axiom(C) && is_pivotal(C;check=true) &&
              is_spherical(C;check=true)
        @test dim.(S)==QQ.([1,1,1,1,sign*2]) && sum(dim(s)^2 for s in S)==8
        @test C[5]⊗C[5]==direct_sum(S[1:4])[1]
    end
    # RSW §5.3.4: Ising's positive pivotal structure has dimensions 1,1,sqrt(2)
    # in package order, and this unnormalized S. Acb checks are compatibility
    # of enclosures at two precisions, NEVER proofs of exact identities.
    for precision in (64,128)
        K=AcbField(precision); C=ising_category(K); r=sqrt(K(2))
        @test all(overlaps.(dim.(simples(C)),[K(1),K(1),r]))
        expected=matrix(K,[K(1) K(1) r;K(1) K(1) -r;r -r K(0)])
        @test all(overlaps.(smatrix(C),expected))
        # Ising's fermion twist is -1 and the noninvertible twist has eighth
        # power -1 (RSW §5.3.4, allowing the constructor's conjugate braiding).
        T = tmatrix(C)
        @test overlaps(T[1,1],K(1)) && overlaps(T[2,2],K(-1)) && overlaps(T[3,3]^8,K(-1))
        f=associator(C[3],C[3],C[3])
        @test overlaps(f∘dagger(f),id(codomain(f)))
    end
end
