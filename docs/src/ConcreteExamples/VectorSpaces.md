# [Vector spaces and graded vector spaces](@id graded-spaces)

Finite-dimensional vector spaces are the basic linear tensor category and the
target of the usual fiber functors. The mathematical model is
$\operatorname{Vec}_K$ from [EGNO; Examples 2.3.3 and 2.10.12,
pp. 26 and 42](@citet). Its concrete coordinate realization is
`vector_spaces(K)`: objects carry chosen bases and linear maps are stored as
matrices acting on row coordinates. In a tensor-product basis, the coordinate
from the right tensor factor varies fastest, so tensor products of morphisms
are Kronecker products in this order. `vector_spaces()` uses $\mathbb Q$, and
`VectorSpaceObject(C,n)` constructs an $n$-dimensional object.
The overload `VectorSpaceObject(K,n)` creates the corresponding parent from
$K$; replacing $n$ by a Julia vector supplies explicit basis labels. Finally,
`morphism(M)` infers standard source and target spaces from the row and column
counts of a matrix $M$.

```@example vectors
using TensorCategories, Oscar
V = vector_spaces(QQ)
X = VectorSpaceObject(V,2)
@assert int_dim(X ⊗ X) == 4
@assert int_dim(Hom(X,X)) == 4
@assert int_dim(Hom(zero(V),X)) == 0
int_dim(X)
```

`int_dim` is an integer dimension; `dim` is a scalar in the base field. These
differ in positive characteristic, where an integer dimension can reduce to
zero.
The model implements the usual duality, evaluation and coevaluation, symmetric
braiding, and spherical structure.

The constructor `morphism(X,Y,M)` checks the parent category, coefficient
field, and the matrix size
$\dim_K(X)\times\dim_K(Y)$. Equality of `VectorSpaceObject`s, however, uses
only the coefficient field and dimension; names supplied in a basis vector are
not part of equality. Composition multiplies the stored matrices after checking
only that the two middle objects are isomorphic. It does not insert a
change-of-basis matrix, so matrices being composed must already use the same
ordered coordinates.

## [Finite group gradings](@id finite-group-gradings)

Graded vector spaces are the standard pointed examples of fusion categories.
For finite $G$, the constructor realizes $\operatorname{Vec}_G$ from
[EGNO; Example 2.3.6 and Eq. (2.17), p. 27](@citet), with the degree of a
tensor product equal to the product of the degrees in the displayed order.

`graded_vector_spaces(K,G)` is the category of finite-dimensional $G$-graded
vector spaces. Its simple objects are one-dimensional spaces in degrees
$g\in G$. Tensor products multiply degrees in the order $gh$.
The convenience call `graded_vector_spaces(G)` uses $\mathbb Q$.
For a constructed category $C$, `C[g_1,...,g_n]` creates the based object with
one basis vector in each displayed degree.

Finiteness of $G$ is a hypothesis on these graded-category constructors; they
do not check it. In particular, the current `is_fusion(C)` method returns
`true` without independently establishing that $G$ is finite.
The untwisted model implements graded duals, evaluation and coevaluation, and
its standard spherical structure.

```@example vectors
G = cyclic_group(3)
g = first(gens(G))
C = graded_vector_spaces(QQ,G)
X = C[one(G),g]
@assert C[g] ⊗ C[g] == C[g*g]
@assert int_dim(X) == 2
@assert int_dim(Hom(C[g],C[one(G)])) == 0
decompose(X)
```

For this category, `C[g,h]` specifies the degrees of two basis vectors.
It is not a vector of simple multiplicities.
The graded `morphism` constructor additionally checks that a matrix preserves
degrees. Equality of `GradedVectorSpaces` values compares the field, group,
stored cocycle, spherical scalars, and braiding data; it is not a test of
monoidal equivalence. An object's ordered grading vector is part of equality.
Nevertheless, the inherited composition method tests the middle objects only
up to graded isomorphism, so use the same grading order on both sides of a
composition.

## [Bicharacter braidings](@id bicharacter-braidings)

For abelian $G$, bicharacters turn pointed categories into elementary braided
models used throughout the theory of anyons and quadratic forms. The
implementation follows the braiding in
[EGNO; Exercise 8.4.4, p. 204](@citet) literally, with the first argument of
$\chi$ taken from the left tensor factor.

For a finite abelian group $G$ and a `TensorCategories.BilinearForm` $\chi$
with values in $K^\times$, `graded_vector_spaces(K,G,chi)` retains the trivial
associator and uses the braiding

```math
\label{eq:graded-vector-space-braiding}
c_{V,W}(v_g\otimes w_h)=\chi(g,h)\,w_h\otimes v_g
```

on homogeneous vectors. The hexagon equations are the two multiplicativity
conditions for the bicharacter. The braiding is
symmetric precisely when
$\chi(g,h)\chi(h,g)=1$ for all $g,h\in G$; a general bicharacter need not have
this property. The untwisted two-argument constructor uses the ordinary
symmetric flip when $G$ is abelian.

`BilinearForm` is currently not exported. Its qualified constructor takes the
group, coefficient field, a recorded root of unity, and a
dictionary of values. For the sign bicharacter of $C_2$:

```@example bicharacter
using TensorCategories, Oscar
G = cyclic_group(2)
g = first(gens(G))
values = Dict((x,y) => (x == g && y == g ? QQ(-1) : QQ(1))
              for x in G for y in G)
chi = TensorCategories.BilinearForm(G,QQ,QQ(-1),values)
C = graded_vector_spaces(QQ,G,chi)
@assert matrix(braiding(C[g],C[g])) == matrix(QQ,1,1,[-1])
@assert pentagon_axiom(C) && hexagon_axiom(C)
nothing # hide
```

The overload checks that $G$ is abelian, but it does not verify that the group
recorded by $\chi$ is $G$, that $\chi$ has coefficient field $K$, that every
supplied value is invertible, or that the bicharacter identities hold. These
are hypotheses on the supplied data.

## [Cocycle twists](@id cocycle-twists)

Twisting by a normalized group $3$-cocycle gives the general skeletal pointed
fusion category. As a monoidal category, the implementation is exactly
$\operatorname{Vec}_G^\omega$ of [EGNO; Example 2.3.8 and Eqs. (2.19)–(2.21),
pp. 28–29](@citet): its associator maps left bracketing to right bracketing and
acts by $\omega(g,h,l)$ on a homogeneous tensor of degrees $(g,h,l)$.

`graded_vector_spaces(K,G,omega)` accepts a `Cocycle`. The associator on
homogeneous degrees $g,h,l$ is multiplied by $\omega(g,h,l)$, with the usual
map from left to right bracketing. The cocycle must be normalized and take
invertible values. Its recorded group and coefficient field must be $G$ and
$K$, respectively; the constructor does not check these conditions. The
untwisted constructor supplies the trivial cocycle.

Construct explicit data with `Cocycle(G,values)`, where `values` is a complete
dictionary on $G^N$, or with `Cocycle(G,N,f)`, which evaluates the Julia
function `f` on every $N$-tuple. Neither constructor checks the cocycle or
normalization equations.

For a cyclic group of order $n$, `cyclic_group_3cocycle(G,K,xi)` uses the group
element returned by `G[1]` and the formula
```math
\label{eq:cyclic-three-cocycle}
\omega(g^i,g^j,g^l)=\xi^{i\lfloor(j+l)/n\rfloor}
```
for exponents between $0$ and $n-1$. Supply an $n$-th root of unity $\xi$ in
$K$, and ensure that `G[1]` generates the cyclic group. This fixes both the
generator and cocycle direction; the constructor does not check the cocycle
hypotheses. The positional argument `K` is currently unused: the stored
coefficient field is `parent(xi)`, so ensure that the supplied root $\xi$
actually belongs to $K$.

```@example twist
using TensorCategories, Oscar
G = cyclic_group(2)
g = G[1]
omega = cyclic_group_3cocycle(G,QQ,QQ(-1))
C = graded_vector_spaces(QQ,G,omega)
@assert omega(g,g,g) == -1
@assert matrix(associator(C[g],C[g],C[g])) == matrix(QQ,1,1,[-1])
@assert pentagon_axiom(C)
matrix(associator(C[g],C[g],C[g]))
show(stdout, MIME"text/plain"(), matrix(associator(C[g],C[g],C[g]))); println() # hide
```

Braiding is additional data. A group grading alone does not give a braiding for
a nonabelian group. For an abelian group the untwisted category admits the
ordinary symmetric flip; a nontrivial associator can require different data.
Braiding for a stored nontrivial cocycle is not implemented. For abelian $G$,
the current constructor nevertheless retains a trivial `BilinearForm` field,
so `is_braided(C)` can return `true` even though `braiding(X,Y)` rejects the
nontrivial cocycle. Regard braiding as unavailable in this case.

The [implementation discussion](@ref concrete-models) explains the stored basis,
degree order, and restrictions on morphism matrices.

Forgetting the grading gives a faithful $K$-linear functor
$\operatorname{Vec}_G^\omega\to\operatorname{Vec}_K$. For a nontrivial class
$[\omega]\in H^3(G,K^\times)$, this is generally not a tensor fiber functor: a
tensor structure on the forgetful functor would amount to trivializing
$\omega$ by a $2$-cochain. See [Fiber functors and matrix realizations](@ref
fiber-functors) for the distinction between an underlying matrix model and a
monoidal functor to vector spaces.

The package's evaluation and pivotal scalar on the simple object of degree $g$
is $\omega(g,g^{-1},g)^{-1}$. The cocycle equation identifies this with
$\omega(g^{-1},g,g^{-1})$, which is the normalization in
[gustafson2018finiteness; §3.1, p. 2](@citet). Other common duality
normalizations use different scalars, so agreement of the associator alone
does not determine these structural maps.

For a cyclic group, the displayed cocycle with
$\xi=\exp(2\pi i q/n)$ is the Type I representative of
[wang2015nonabelian; Appendix A.4(a), Table XII, p. 24](@citet). Thus this
special helper has a precise literature identification once the generator and
root $\xi$ have been chosen.

## [Cocycle twists computed with GAP/HAP](@id hap-cocycle-twists)

This helper passes a table derived from HAP to the pointed-category constructor
of the preceding section. HAP and its group-cohomology algorithms are described
by [ellis2008hap](@citet); the contract for `CohomologyModule`, including
representative cocycles in degree three, is in
[hapmanual2026; command entry 11.1-2](@citet).

The helper `twisted_graded_vector_spaces(K,G,i)` first sets
$n=\exp H_3(G,\mathbb Z)$ and lets $B\cong C_n$ be a trivial $G$-module. It
asks GAP/HAP for the $i$-th element in its enumeration of $H^3(G,B)$ and passes
a representative cocycle to `graded_vector_spaces`. It may install and load
HAP. If $n=1$, it returns the trivial cocycle without consulting $i$. To
convert a coefficient $b\in B$ when $n>1$, the code chooses an $n$-th root of
unity $\rho\in K$ and uses
```math
\label{eq:character-root-identification}
b\longmapsto
\rho^{\operatorname{Position}(\operatorname{Elements}(B),b)-1}.
```
It also reverses every argument tuple returned by HAP before installing the
value as $\omega(g,h,l)$. The field must contain the required root of unity.

The underlying exported helper is `unitary_cocycle(G,K,k,i=2)`, which performs
the same construction in degree $k$ and returns a `Cocycle`. The class index
must belong to the enumeration returned by the installed HAP version.

HAP's public interface supplies representative cochains, but it does not
specify that reversing their arguments converts to the convention above, or
that `Elements(B)` lists successive powers of the generator used for the
coefficient embedding. Thus $i$ labels a table returned by the installed HAP
version, rather than a literature-standard cohomology class.
`pentagon_axiom(C)` checks coherence of the installed associator; it does not
identify its cohomology class.

The class index defaults to $i=2$, although an explicit index is preferable:
it is not a canonical label for an element of $H^3(G,K^\times)$. Use the
field-explicit argument order shown here; the group-only convenience overload
is currently unavailable. A trailing positional argument named `j` is accepted
by the compatibility overloads but has no effect. For a reproducible presentation,
construct the `Cocycle` explicitly and call
`graded_vector_spaces(K,G,omega)`.
