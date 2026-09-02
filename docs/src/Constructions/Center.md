# [Drinfeld centers and half-braidings](@id center)

The center is implemented in terms of objects and morphisms of the input
category. It does not require an F-symbol presentation. For the theory use
[EGNO](@citet), §7.13; for the algorithm and its hypotheses over more general
fields use [maurer2024computing](@cite) and [maeurer2026thesis](@cite),
Chapter 2.

## The direction of a half-braiding

A central object is a pair $(X,\gamma)$, with natural isomorphisms
```math
\gamma_Y:X\otimes Y\longrightarrow Y\otimes X.
```
With $a_{X,Y,Z}:(X\otimes Y)\otimes Z\to X\otimes(Y\otimes Z)$, the
compatibility is
```math
\gamma_{Y\otimes Z}
=a^{-1}_{Y,Z,X}\circ(\mathrm{id}_Y\otimes\gamma_Z)
 \circ a_{Y,X,Z}\circ(\gamma_Y\otimes\mathrm{id}_Z)
 \circ a^{-1}_{X,Y,Z}.
```
The unit condition is $\gamma_{\mathbb 1}=\operatorname{id}_X$ under the package's normalized unit
identifications. In the opposite convention, the half-braiding components
are $\gamma_Y^{-1}:Y\otimes X\to X\otimes Y$.

A morphism $f:(X,\gamma)\to(X',\gamma')$ is a morphism $f:X\to X'$ satisfying
```math
(\mathrm{id}_Y\otimes f)\circ\gamma_Y
 =\gamma'_Y\circ(f\otimes\mathrm{id}_Y).
```

`center(C)` constructs a parent. `simples(center(C))` performs the expensive
enumeration, using induction and decomposition of endomorphism algebras.
The implementation requires the corresponding operations on the input category. Its generic
induction algorithm is intended for split fusion input with nonzero global
dimension, together with the pivotal/duality data used by the algorithm.
It is not an algorithm for arbitrary monoidal categories.

In positive characteristic, check those hypotheses separately. Semisimplicity
of the input alone does not imply semisimplicity of its center. The center need
not be split even when the input is split.

## Constructing half-braidings by hand

For $\operatorname{Vec}_{k}(C_2)$ in characteristic zero, the four simple
central objects are indexed by a degree $g\in C_2$ and a character
$\chi:C_2\to k^\times$. On an object homogeneous of degree $h$, the
half-braiding is $\chi(h)$ times the usual interchange map.

Here is this construction over $\mathbb Q$. We do not enumerate the center to construct
these objects.

```@example halfbraiding
using TensorCategories, Oscar
G = cyclic_group(2)
C = graded_vector_spaces(QQ,G)
S = simples(C)
Z = center(C)
central = [
    CenterObject(Z, X,
        [braiding(X,Y) * (Y == one(C) ? QQ(1) : QQ(epsilon)) for Y in S])
    for X in S for epsilon in (1,-1)
]
@assert length(central) == 4
for X in central
    @assert is_central(X)
    @assert all(is_invertible, half_braiding(X))
    @assert half_braiding(X, one(C)) == id(object(X))
end
[int_dim(Hom(X,Y)) for X in central, Y in central]
```

The displayed matrix is the identity: these objects are simple and pairwise
nonisomorphic. Their completeness follows independently from the classification
by the two degrees and two characters. We can also test the equation on a
non-simple object:

```@example halfbraiding
X = central[end]
Y = S[1] ⊕ S[2]
W = S[2]
rhs = inv_associator(Y,W,object(X)) ∘
      (id(Y) ⊗ half_braiding(X,W)) ∘ associator(Y,object(X),W) ∘
      (half_braiding(X,Y) ⊗ id(W)) ∘ inv_associator(object(X),Y,W)
@assert half_braiding(X,Y⊗W) == rhs
matrix(half_braiding(X,Y))
show(stdout, MIME"text/plain"(), matrix(half_braiding(X,Y))); println() # hide
```

`CenterObject(Z,X,gamma)` stores components in the order `simples(C)`;
`object` forgets the half-braiding, `half_braiding(X)` returns the stored list,
and `half_braiding(X,Y)` extends it to a general object.
The constructor stores the components without validation. `is_central` checks
the coherence equations; invertibility and the normalized unit condition
$\gamma_{\mathbb 1}=\operatorname{id}_X$ are additional requirements on the supplied components.

The braiding in the center is
$c_{(X,\gamma),(Y,\delta)}=\gamma_Y$. Thus two central objects with the same underlying object
can be different. The forgetful functor is faithful and tensor, but its target
is $\mathcal C$, not necessarily vector spaces.

## Extracting structural data

Once a center is split, use `six_j_category(Z)` to construct a skeleton,
or `six_j_symbols(Z)` to compute its associators. Use the same binary Hom
bases when computing associators and braiding; independently chosen bases need
not give a compatible pair of F- and R-symbols.

The next chapter follows the non-split Ising center through scalar extension
and extraction of a single compatible skeleton. Precomputed database centers
are described under [AnyonWiki](../F-symbols/AnyonWiki.md); a saved skeletal
center does not retain the original explicit half-braidings.
