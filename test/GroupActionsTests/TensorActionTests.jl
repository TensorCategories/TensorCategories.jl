#=----------------------------------------------------------
    Test the Group action on the Ising Category
----------------------------------------------------------=#
#=
This test computes the equivariantization C^G of an Ising fusion category C
by G ≅ C₂. The Ising category has three simple isomorphism classes

    𝟙, ψ, σ,

with fusion rules ψ ⊗ ψ ≅ 𝟙, ψ ⊗ σ ≅ σ, and
σ ⊗ σ ≅ 𝟙 ⊕ ψ. Every tensor autoequivalence fixes these three classes:
𝟙 is the tensor unit, ψ is the unique nontrivial invertible simple, and σ
is the unique noninvertible simple.

We let the identity of G act by Id_C and its nontrivial element act by the
nontrivial monoidal autoequivalence b. We choose the split coherence

    b ∘ b ⇒ Id_C,

meaning that the induced stabilizer 2-cocycle α_X is cohomologically trivial
for every simple X.

Simple objects of an equivariantization are classified by pairs (X, π), where
X represents a G-orbit in Irr(C) and π is an irreducible α_X-projective
representation of the stabilizer G_X. In this example every simple is fixed,
so there are three singleton orbits and G_X = G ≅ C₂ for each X. Since the
action is split, α_X is trivial, and C₂ has two irreducible characters.
Consequently, each Ising simple has two equivariant lifts and

    rank(C^G) = 3 * 2 = 6.

This count already holds over the base field used here: its characteristic is
not 2, so K[C₂] ≅ K × K. As a dimension check, the six simples have
Frobenius–Perron dimensions 1, 1, 1, 1, √2, √2, whose squared dimensions sum
to 8 = |G| FPdim(C).

References:
- V. Drinfeld, S. Gelaki, D. Nikshych, V. Ostrik,
  "On braided fusion categories I", Selecta Math. (N.S.) 16 (2010),
  1–119, Appendix B.
- S. Burciu, S. Natale,
  "Fusion rules of equivariantizations of fusion categories",
  J. Math. Phys. 54 (2013), 013511, Corollary 2.13.
=#

I = ising_category() 
G = cyclic_group(2)
aut = autoequivalences(I)
#  Compute the autoequivalences of the Ising category. There are 2, the identity functor and the identity functor with alternative monoidal structure.
@testset "Autoequivalences of Ising category" begin

    @test length(aut) == 2
    @test all(monoidal_functor_axiom, aut)
end

# Construct a GTensorAction and test basic properties.

a,b = aut    

# decide which one is the identity functor and which one is the nontrivial autoequivalence and fix a to the identity
if length(monoidal_natural_transformations(a,identity_as_monoidal_functor(I))) == 0
    a,b = b,a
end

# UT: There are two natural transformations b^2 => a. The selection of the 
# non-trivial one via selection [1] below is not stable, and indeed in OSCAR 1.8
# the solutions were returned in another order, causing a later test to fail.
# So, we will choose this now by mathematical means instead.
#
# the monoidal structure is given by a Dict 
# monoidal_str = Dict(
#     (1,1) => id(a),
#     (1,2) => id(b),
#     (2,1) => id(b),
#     (2,2) => monoidal_natural_transformations(b∘b, a)[1] # the nontrivial monoidal structure on the identity functor
# )

μs = monoidal_natural_transformations(b ∘ b, a)

scalar_component(μ, Y) =
    only(express_in_basis(μ(Y), [id(Y)]))

μ_split = only(
    μ for μ in μs
    if all(is_square(scalar_component(μ, Y)) for Y in simples(I))
)

monoidal_str = Dict(
    (1,1) => id(a),
    (1,2) => id(b),
    (2,1) => id(b),
    (2,2) => μ_split # the nontrivial monoidal structure on the identity functor
)

T = gtensor_action(I, elements(G), [a,b], monoidal_str)

@testset "GTensorAction on Ising category" begin    

    @test is_tensor_action(T) 
    @test length(monoidal_natural_transformations(b∘b, a)) == 2
    @test length(monoidal_natural_transformations(a∘a, a)) == 2
    @test length(monoidal_natural_transformations(a∘b, b)) == 2
    @test length(monoidal_natural_transformations(b∘a, b)) == 2
    @test length(monoidal_natural_transformations(b∘b, b)) == 0
end

#=----------------------------------------------------------
    Test The construction of the G-crossed Product 
        C ⋉ G
----------------------------------------------------------=#

GI = gcrossed_product(I,T)

@testset "G-crossed product of Ising category with ℤ₂" begin
    @test pentagon_axiom(GI)
end