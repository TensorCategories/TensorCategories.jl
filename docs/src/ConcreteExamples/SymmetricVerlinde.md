# [Symmetric Verlinde categories in characteristic $p$](@id symmetric-verlinde)

Two related families carry the name *Verlinde category*. The categories called
**Verlinde modular categories** in [EGNO; Example 8.18.5](@citet) arise from
quantum groups at roots of unity in characteristic zero; their
$\mathfrak{sl}_2$ models are constructed by
[`verlinde_category`](@ref verlinde-models). This page concerns the symmetric fusion category
$\operatorname{Ver}_p$ in characteristic $p$. Except in trivial rank, a
symmetric braided category is not modular. The constructor is therefore named
`symmetric_verlinde_category`.

Let $k$ be a field of characteristic $p>0$, and let $J_i$ be the
$i$-dimensional indecomposable representation of $C_p$ on which a generator
acts by one unipotent Jordan block. The semisimplification of
$\operatorname{Rep}_k(C_p)$ kills $J_p$ and has simple objects

```math
L_i=[J_i],\qquad 1\leq i\leq p-1.
```

This is $\operatorname{Ver}_p$ [EGNO; Exercise 8.18.9(v)](@cite). Its tensor
product is the truncated $\mathfrak{sl}_2$ rule

```math
\label{eq:symmetric-verlinde-fusion}
L_a\otimes L_b
=\bigoplus_{\substack{c=|a-b|+1\\c\equiv a+b+1\pmod 2}}^{
\min(a+b-1,\,2p-a-b-1)}L_c.
```

The quotient inherits the ordinary flip, rigidity, and spherical structure
from representations. The full construction and its fusion rules are
described by [etingof2017computations; §2](@citet) and
[etingof2022semisimplification; Example 2.7](@citet).

For $p>2$ there is a factorization

```math
\operatorname{Ver}_p\simeq \operatorname{Ver}_p^+\boxtimes\operatorname{sVect},
```

where $\operatorname{Ver}_p^+$ has the odd-labelled simples
$L_1,L_3,\ldots,L_{p-2}$ [gelaki2026drinfeld; §2.3](@cite).

## The constructor

The integer call uses the prime field $\mathbf F_p$:

```@example symmetric_verlinde
using TensorCategories, Oscar
V = symmetric_verlinde_category(7; plus=true)
simples_names(V)
```

The result is a split skeletal fusion category with associator, symmetric
braiding, and spherical structure transported from the representation
quotient. The categorical dimension of $L_i$ is the image of $i$ in the
coefficient field.

```@example symmetric_verlinde
dim.(simples(V))
```

Pass a finite field instead of an integer to choose a larger coefficient
field of characteristic $p$. The value of $p$ is the characteristic, not the
order of the field. Set `skeletal=false` to retain the semisimplified quotient
of the generated representation category. Set
`check=true` to verify pentagon, hexagon, pivotal, and spherical identities
while constructing the skeleton.

The mathematical literature normally takes $k$ algebraically closed. The
constructor currently uses a finite field, but the Jordan-block model and all
simple endomorphism rings defining $\operatorname{Ver}_p$ and
$\operatorname{Ver}_p^+$ are already split over the prime field. Subsequent
constructions can introduce new nonsplit objects; apply the splitting tests of
[scalar extension and splitting](@ref splitting-and-scalars) when needed.

```@docs
symmetric_verlinde_category
```

## Drinfeld centers

For a braided category $\mathcal C$, `center_embedding(C)` constructs the
canonical functor

```math
\mathcal C\longrightarrow\mathcal Z(\mathcal C),\qquad
X\longmapsto (X,c_{X,-}).
```

This formula uses the package convention
$\gamma_Y:X\otimes Y\to Y\otimes X$ for half-braidings. The keyword
`reverse=true` instead uses $c_{Y,X}^{-1}$. See [Drinfeld centers and
half-braidings](@ref center) for the convention and the general center
algorithm.

For $p>3$, $\mathcal Z(\operatorname{Ver}_p^+)$ is not semisimple. Its simple
objects are precisely the canonical images of the simple objects of
$\operatorname{Ver}_p^+$, and induction of $L_i$ is the projective cover of
that simple object [gelaki2026drinfeld; Lemma 3.1 and Theorem 3.2](@cite). The
Cartan matrix is

```math
\label{eq:verlinde-center-cartan}
C_{ij}=C_{ji}=\frac{j(p-i)}2,
\qquad 1\leq j\leq i\leq p-2,\quad i,j\text{ odd}.
```

The following uses only the general center interface:

```julia
V = symmetric_verlinde_category(7; plus=true)
Z = center(V)
E = center_embedding(V; parent_category=Z)
S = simples(Z; sort=false)
P = [induction(X; parent_category=Z) for X in simples(V)]
[int_dim(End(X)) for X in S]
# [1, 1, 1]
[int_dim(Hom(X,Y)) for X in P, Y in P]
# [3 2 1; 2 6 3; 1 3 5]
```

The paper works over an algebraic closure. The displayed computation over
$\mathbf F_7$ also checks directly that the three central simple objects have
one-dimensional endomorphism rings, so this particular list is already split.

```@docs
center_embedding
```

## Finite pieces of a semisimplified center

For $p\geq7$, the center $\mathcal Z(\operatorname{Ver}_p^+)$ has wild
representation type [gelaki2026drinfeld; Theorem 3.8](@cite). A request for all
indecomposable objects is therefore not a finite computation. One can instead
choose finitely many objects, enumerate summands of tensor words to a specified
depth, and inspect their images modulo negligible morphisms:

```julia
T = tensor_power_category(seeds)
Q = semisimplification(T)
piece = semisimplified_piece(T, 3; quotient=Q)
piece.representatives
```

The result distinguishes all enumerated upstairs indecomposables, their
nonzero quotient images, and one representative of each quotient isomorphism
class. It does not claim that a bounded piece exhausts the ambient center.
`tensor_closure_complete` becomes true only if the generated tensor subcategory
upstairs has actually stopped producing new indecomposables.
`all_images_split_simple` tests whether the enumerated quotient images have
one-dimensional endomorphism spaces.

If a calculation supplies a finite list `S` of quotient simples and the matrix
`N` for multiplication by a simple generator `E`, then

```julia
D = fusion_subcategory(E; simples=S, products=N, names=names)
```

constructs the generated fusion subcategory. Here `N[k,j]` is the multiplicity
of `S[k]` in `E ⊗ S[j]`. The default checks the proposed decompositions by
constructing explicit isomorphisms, checks dual closure, and verifies that all
objects in `S` are reached from the tensor unit. The result retains the
concrete quotient objects and morphisms; pass `skeletal=true` to extract a
`SixJCategory`.

When a theoretical calculation predicts a decomposition, use
`decomposition_isomorphism(X, proposed)` over a finite field. It searches the
complete categorical Hom spaces and returns an explicit isomorphism, its
inverse, and all summand inclusions and projections. Failure of the bounded
search is not a proof that the proposed decomposition is false.

An endomorphism can be studied on a quotient multiplicity space with the
ordinary Hom functor. If $f:X\to X$ and $Y$ are first mapped into a
semisimplification `Q`, then `matrix(Hom(Y,:)(f))` is the matrix induced by
postcomposition on $\operatorname{Hom}_Q(Y,X)$. In particular, taking $f$ to
be a self-braiding reads its action on a chosen fusion channel without
introducing a center-specific matrix convention.

```@docs
semisimplified_piece
decomposition_isomorphism
fusion_subcategory
```
