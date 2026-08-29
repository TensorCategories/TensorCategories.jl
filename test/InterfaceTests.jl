# Generic interface regressions. References and counterexamples are recorded
# with the testsets that use them.

struct UndeclaredAuditCategory <: Category end
@attributes mutable struct DeclaredAuditCategory <: Category end
struct MultifusionShortcutAuditCategory <: Category end
TensorCategories.is_multifusion(::MultifusionShortcutAuditCategory) = true
TensorCategories.is_fusion(::MultifusionShortcutAuditCategory) =
    error("the fusion predicate must not be needed here")

# Structural predicates record axioms supplied by an implementation. The mere
# presence of a generic method does not establish an axiom. The fusion/weak
# fusion convention is Mäurer--Thiel, arXiv:2406.13438v2, Section 2.1; weak
# multifusion and multifusion are the corresponding variants without a simple
# unit object.
@testset "Declared categorical structures" begin
    C = UndeclaredAuditCategory()
    # Previously these two queries called each other indefinitely.
    @test !is_additive(C) && !is_abelian(C) && !is_linear(C) && !is_monoidal(C)

    D = DeclaredAuditCategory(Dict{Symbol, Any}(
        :additive => true,
        :rigid => true,
        :spherical => false,
        :krull_schmidt => true,
    ))
    # Additivity does not imply k-linearity, and every property reads its own
    # declaration rather than the unrelated spherical flag.
    @test is_additive(D) && !is_linear(D)
    @test TensorCategories.is_rigid(D) && TensorCategories.is_krull_schmidt(D)

    S = DeclaredAuditCategory(Dict{Symbol, Any}(:spherical => true))
    # Spherical structure is rigid monoidal structure, but does not by itself
    # assert the finiteness hypotheses used for Krull--Schmidt decomposition.
    @test TensorCategories.is_rigid(S) && is_monoidal(S)
    @test !TensorCategories.is_krull_schmidt(S)

    W = DeclaredAuditCategory(Dict{Symbol, Any}(:weak_fusion => true))
    @test is_weak_fusion(W) && is_weak_multifusion(W) && is_semisimple(W)
    @test !is_fusion(W) && !is_multifusion(W)

    M = DeclaredAuditCategory(Dict{Symbol, Any}(:multifusion => true))
    @test is_multifusion(M) && is_weak_multifusion(M) && is_semisimple(M)
    @test !is_fusion(M) && !is_weak_fusion(M) && is_split_semisimple(M)

    # Multifusion already implies weak multifusion and semisimplicity. Checking
    # the stronger fusion condition caused recursive centralizer decomposition.
    M0 = MultifusionShortcutAuditCategory()
    @test is_weak_multifusion(M0) && is_semisimple(M0)

    F = DeclaredAuditCategory(Dict{Symbol, Any}(:fusion => true))
    @test is_fusion(F) && is_multifusion(F)
    @test is_weak_fusion(F) && is_weak_multifusion(F)
    @test is_split_semisimple(F)

    V = vector_spaces(QQ)
    @test is_braided(V) && is_additive(id(V)) && is_linear(id(V))
    A = ArrowCategory(V)
    @test is_linear(A) && TensorCategories.is_krull_schmidt(A)
end

# In a skeletal semisimple category, a component vector records multiplicities
# relative to the chosen simple objects of one parent; see EGNO (2015),
# Sections 1.1 and 4.9. Equal coordinates in different categories do not define
# equal objects or mixed-category morphisms.
@testset "Parent-sensitive skeletal operations" begin
    F = GF(11)
    M = zeros(Int, 2, 2, 2)
    for i in 1:2, j in 1:2
        M[i, j, mod(i + j - 2, 2) + 1] = 1
    end
    C = six_j_category(F, M, ["1", "g"])
    set_one!(C, [1, 0])
    D = fibonacci_category(F)
    g, X = simples(C)[2], simples(D)[2]

    # Both have coordinates [0,1], but g⊗g=1 whereas X⊗X=1⊕X.
    @test g != X && !is_isomorphic(g, X)[1]
    @test_throws ArgumentError Hom(g, X)
    @test_throws ArgumentError zero_morphism(g, X)
    @test_throws ArgumentError morphism(g, X, matrices(id(g)))
    @test_throws ArgumentError g ⊗ X
    @test_throws ArgumentError direct_sum(g, X)
    @test_throws ArgumentError g ⊕ X
    @test_throws ArgumentError express_in_basis(id(g), End(X))

    g2 = simples(C)[2]
    ok, f = is_isomorphic(g, g2)
    @test ok && domain(f) === g && codomain(f) === g2
    @test inv(f) ∘ f == id(g)
    @test Dict(g => 7)[g2] == 7

    C2 = six_j_category(F, M, ["1", "g"])
    set_one!(C2, [1, 0])
    g3 = simples(C2)[2]
    # Structurally identical presentations still require explicit transport.
    @test g != g3
    @test parent(extension_of_scalars(g, F, C2)) === C2

    G = cyclic_group(5)
    R11, R13 = representation_category(F, G), representation_category(GF(13), G)
    # Zero representations retain their group and coefficient field.
    @test zero(R11) != zero(R13)
    @test !is_isomorphic(zero(R11), zero(R13))[1]
end

# Finite coproducts in an additive category are biproducts; see EGNO (2015),
# Section 1.2. The symbolic operator returns the object, while `coproduct`
# also returns the universal injections.
@testset "Coproduct operator" begin
    F = GF(5)
    C = six_j_category(F, ones(Int, 1, 1, 1), ["1"])
    set_one!(C, [1])
    U = one(C)
    @test ∐(U, U) == U ⊕ U

    V, inc = coproduct(U, U)
    h = morphism(V, U, [matrix(F, 2, 1, [2, 3])])
    # The copairing [2*id,3*id] is characterized by its restrictions.
    @test h ∘ inc[1] == F(2) * id(U)
    @test h ∘ inc[2] == F(3) * id(U)
end

# A scalar multiple is an equality M=cN over the common matrix base ring.
# The coefficient must be selected using a nonzero entry of N, and conversion
# of categorical scalars must land in the ring requested by the caller.
@testset "Scalar-multiple fallbacks" begin
    F = GF(5)
    N = matrix(F, [0 1; 0 0])
    I = identity_matrix(F, 2)
    # E12 is not scalar; its nonzero off-diagonal entry faces a zero entry of I.
    @test TensorCategories.is_scalar_multiple(N, I) == (false, nothing)
    @test TensorCategories.is_scalar_multiple(zero_matrix(F, 2, 2), I) ==
          (true, F(0))
    @test TensorCategories.is_scalar_multiple(F(3) * N, N) == (true, F(3))
    # Matrix equality, hence scalar-multiple equality, requires equal shapes.
    @test TensorCategories.is_scalar_multiple(I, identity_matrix(F, 1)) ==
          (false, nothing)

    C = six_j_category(F, ones(Int, 1, 1, 1), ["1"])
    set_one!(C, [1])
    L = GF(5, 2)
    # The previous fallback returned an F5 element despite being called as L(f).
    c = L(F(3) * id(one(C)))
    @test c == L(3) && parent(c) === L
end

# Scalar extension applies one chosen field embedding to objects and every
# Hom-space basis morphism. For finite fields these embeddings are controlled
# by Frobenius; see K. Conrad, Finite Fields, Section 5,
# https://kconrad.math.uconn.edu/blurbs/galoistheory/finitefields.pdf.
@testset "Finite-field Hom scalar extension" begin
    F = GF(5)
    C = six_j_category(F, ones(Int, 1, 1, 1), ["1"])
    set_one!(C, [1])
    TensorCategories.set_twist!(C, [F(2)])
    U = one(C)
    L = GF(5, 2)
    CL = extension_of_scalars(C, L)
    # Optional metadata is transported only when present, along the same map.
    @test getfield(CL, :twist) == [L(2)] && !isdefined(CL, :name)
    HL = extension_of_scalars(Hom(U, U), L, CL)
    @test int_dim(HL) == 1
    @test only(basis(HL)) == id(domain(HL))
    @test parent(domain(HL)) === CL

    F9, L81 = GF(3, 2), GF(3, 4)
    D = six_j_category(F9, ones(Int, 1, 1, 1), ["1"])
    set_one!(D, [1])
    e = Oscar.embed(F9, L81)
    DL = extension_of_scalars(D, L81; embedding=e)
    a = gen(F9)
    H = HomSpace(one(D), one(D), [a * id(one(D))])
    H1 = extension_of_scalars(H, L81, DL; embedding=e)
    H2 = extension_of_scalars(H, L81, DL; embedding=x -> e(x)^3)
    # Frobenius x↦x³ is the nontrivial F3-automorphism of F9.
    @test matrix(only(basis(H1)))[1,1] == e(a)
    @test matrix(only(basis(H2)))[1,1] == e(a)^3
end

# Vec_G is the direct sum of its homogeneous components, and tensor degrees
# multiply in the order gh; see EGNO (2015), Section 2.3.
@testset "Graded multiplicities and tensor order" begin
    G = cyclic_group(2)
    e, g = one(G), only(gens(G))
    C = graded_vector_spaces(QQ, G)
    X, Y, Z = C[e,e,g], C[e,g,g], C[g,e,e]
    # Equal support and total dimension do not imply equal graded dimensions.
    @test is_isomorphic(X, Y) == (false, nothing)
    ok, f = is_isomorphic(X, Z)
    @test ok && inv(f) ∘ f == id(X) && f ∘ inv(f) == id(Z)

    # A graded map has no nonzero component between unequal degrees.
    @test_throws ErrorException morphism(C[e], C[g], matrix(QQ, 1, 1, [1]))
    @test_throws ArgumentError morphism(C[e], C[e], identity_matrix(GF(5), 1))
    @test_throws ArgumentError morphism(C[e], C[e], identity_matrix(QQ, 2))

    H = symmetric_group(3)
    D = graded_vector_spaces(QQ, H)
    a, b = gens(H)[1:2]
    @test a*b != b*a
    @test TensorCategories.grading(D[a] ⊗ D[b]) == [a*b]
    @test_throws ArgumentError C[e] ⊗ D[a]
end

# Hom spaces are vector spaces (EGNO (2015), Section 1.2): zero has the unique
# empty coordinate vector in the zero subspace, while a nonzero vector is not
# in that span. A one-factor tensor product is the factor itself.
@testset "Zero coordinates and unary tensor products" begin
    V = VectorSpaces(QQ)
    U = one(V)
    empty_basis = VectorSpaceMorphism[]
    @test express_in_basis(zero_morphism(U,U), empty_basis) == QQFieldElem[]
    @test_throws ArgumentError express_in_basis(id(U), empty_basis)
    @test tensor_product(U) === U
    @test_throws ArgumentError tensor_product()

    X, Y = VectorSpaceObject(V,2), VectorSpaceObject(V,3)
    @test isempty(basis([zero_morphism(X,Y)]))
    @test_throws ArgumentError express_in_basis(
        zero_morphism(X,Y), [zero_morphism(Y,X)])
end

# Row reduction in a Hom space must preserve the original source and target.
# Rectangular matrices detect both accidental transposition and flattening in
# the wrong order; compare the vector-space structure in EGNO (2015), §1.2.
@testset "Rectangular Hom-span coordinates" begin
    V = VectorSpaces(QQ)
    X, Y = VectorSpaceObject(V,2), VectorSpaceObject(V,3)
    f = morphism(X,Y,matrix(QQ,2,3,[1,2,0,3,0,4]))
    g = morphism(X,Y,matrix(QQ,2,3,[0,1,2,0,3,0]))
    B = basis([f,g,f+g])
    @test length(B) == 2
    @test all(domain(b) == X && codomain(b) == Y for b in B)
    # The independent output spans each original generator exactly.
    for h in (f,g)
        c = express_in_basis(h,B)
        @test sum((a*b for (a,b) in zip(c,B));
                  init=zero_morphism(X,Y)) == h
    end
end

# Maschke's theorem gives semisimplicity when the characteristic does not
# divide |G|; see EGNO (2015), Remark 4.2.14. Fusion additionally requires
# splitting; see Mäurer--Thiel, arXiv:2406.13438v2, Section 2.1.
@testset "Weak fusion and splitting over nonclosed fields" begin
    R = representation_category(GF(2), cyclic_group(3))
    # x^2+x+1 is irreducible over F2, so the two-dimensional simple has
    # endomorphism field F4: this category is weak fusion but not fusion.
    @test is_semisimple(R) && is_weak_fusion(R)
    @test is_braided(R)
    @test !is_split_semisimple(R) && !is_fusion(R)
    @test is_fusion(representation_category(GF(5), cyclic_group(2)))
    M = representation_category(GF(3), cyclic_group(3))
    @test !is_weak_fusion(M) && !is_fusion(M)
end

function audit_jordan_representation(C, n)
    J = identity_matrix(base_ring(C), n)
    for i in 1:n-1
        J[i, i+1] = 1
    end
    Representation(C, gens(base_group(C)), [J])
end

# Semisimplification quotients Hom spaces by negligible morphisms; see
# Etingof--Ostrik, arXiv:1801.04409v4, Definition 2.1 and Proposition 2.4.
@testset "Semisimplification scalar coordinates" begin
    F = GF(5)
    R = representation_category(F, cyclic_group(5))
    J2 = audit_jordan_representation(R, 2)
    Q = Semisimplification(R)
    X = semisimplify(J2, Q)
    generator = matrix(J2(gens(base_group(R))[1]))
    f = semisimplify(morphism(J2, J2, generator), Q)

    # End(J2)=F5[N]/(N^2), and tr(Nh)=0 for every h. Thus [N]=0 and
    # the group generator [1+N] is the quotient identity.
    @test f == id(X)
    @test express_in_basis(f, [id(X)]) == [F(1)]
    @test F(f) == F(id(X)) == F(1)
    n = f - id(X)
    @test is_zero(n) && F(n) == F(0)
    @test F(F(3) * id(X) + n) == F(3)

    P = semisimplify(audit_jordan_representation(R, 5), Q)
    # Every endomorphism of J5 has trace divisible by five, so J5 becomes zero.
    @test F(id(P)) == F(0)

    U, inc, proj = direct_sum(X, X)
    # Projection onto one summand is not a scalar endomorphism of X⊕X.
    @test_throws ArgumentError F(inc[1] ∘ proj[1])
    # A nonzero map between different objects has no scalar value.
    @test_throws ArgumentError F(inc[1])
end

# A representation morphism is an intertwiner; see Etingof et al.,
# Introduction to Representation Theory (2011), Definition 1.13.
@testset "Representation morphism validation" begin
    F = GF(5)
    R = representation_category(F, cyclic_group(5))
    J2 = audit_jordan_representation(R, 2)
    bad = matrix(F, [1 0; 0 0])
    @test_throws ArgumentError morphism(J2, J2, bad; check = true)
    # Expensive equivariance validation is opt-in for performance.
    @test matrix(morphism(J2, J2, bad)) == bad

    S = representation_category(F, cyclic_group(2))
    T = Representation(S, gens(base_group(S)), [identity_matrix(F, 2)])
    @test_throws ArgumentError morphism(J2, T, identity_matrix(F, 2))
    @test_throws ArgumentError morphism(J2, J2, identity_matrix(GF(7), 2))
    @test_throws ErrorException morphism(J2, J2, identity_matrix(F, 1))
end

# Monomorphisms and epimorphisms need not split outside semisimple categories;
# see EGNO (2015), Sections 1.3--1.4.
@testset "Nonsplit monomorphisms and epimorphisms" begin
    R = representation_category(GF(5), cyclic_group(5))
    J1, J2 = audit_jordan_representation(R, 1), audit_jordan_representation(R, 2)
    p = only(basis(Hom(J2, J1)))
    i = only(basis(Hom(J1, J2)))
    @test is_epimorphism(p) && !is_monomorphism(p)
    @test is_monomorphism(i) && !is_epimorphism(i)
    # Splittings would decompose the indecomposable Jordan block J2.
    @test_throws ErrorException right_inverse(p)
    @test_throws ErrorException left_inverse(i)
    @test is_monomorphism(zero_morphism(zero(R), J1))
    @test is_epimorphism(zero_morphism(J1, zero(R)))
end
