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
