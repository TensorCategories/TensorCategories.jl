# [The Ising center over two fields](@id ising-center)

We continue the [Ising example](Introduction.md), now paying attention to the
field of definition. The expected simple objects and splitting phenomenon are
described in [maurer2024computing; §6.1](@citet) and
[maeurer2026thesis; Theorem 2.5.6 and Appendix B.1](@citet).

## Over $\mathbb Q(\sqrt2)$

```@example isingcenter
using TensorCategories, Oscar
K, r2 = quadratic_field(2)
C = ising_category(K,r2)
Z = center(C)
S = simples(Z)
@assert length(S) == 5
@assert sort(int_dim.(End.(S))) == [1,1,1,2,4]
[(object(X), int_dim(End(X))) for X in S]
```

The five underlying objects are $\mathbb 1$, $\mathbb 1$,
$\mathbb 1\oplus\chi$, $2\chi$, and $4X$. Their endomorphism algebras have
dimensions $1,1,1,2,4$ over $K$.
Thus two of the simple central objects are not absolutely simple.

Enumeration uses randomized algebra algorithms. Ordering, matrix bases, and
individual coefficients can vary. Select an object by its mathematical
property instead of relying on a fixed position:

```@example isingcenter
T = only([T for T in S if int_dim(End(T)) == 2])
@assert is_isomorphic(object(T), C[2] ⊕ C[2])[1]
@assert is_central(T)
@assert all(is_invertible, half_braiding(T))
matrix(half_braiding(T,C[3]))
show(stdout, MIME"text/plain"(), matrix(half_braiding(T,C[3]))); println() # hide
```

In this case the component on $X$ squares to minus the identity. Its eigenvalues
require a square root of $-1$:

```@example isingcenter
h = half_braiding(T,C[3])
@assert h ∘ h == -id(domain(h))
@assert half_braiding(T,one(C)) == id(object(T))
int_dim(End(T))
```

The component is a matrix over $K$ even though its eigenvalues are not in $K$.
A nonzero noninvertible endomorphism cannot already exist in the division
algebra $\operatorname{End}(T)$. After scalar extension that algebra can acquire
idempotents; their images split the extended object.

## Over $\mathbb Q(\zeta_{16})$

Use a specified embedding of $K$ into the cyclotomic field, so the meaning of
$\sqrt2$ is unambiguous:

```@example isingcenter
L, z = cyclotomic_field(16)
embedding = hom(K,L,z^2 + z^-2)
CL = extension_of_scalars(C,L; embedding=embedding)
ZL = center(CL)
SL = simples(ZL)
@assert length(SL) == 9
@assert all(T -> int_dim(End(T)) == 1, SL)
@assert is_split_semisimple(ZL)
squared_dimensions = sort([QQ(dim(T)^2) for T in SL])
@assert squared_dimensions == [1,1,1,1,2,2,2,2,4]
@assert sum(squared_dimensions) == 16
squared_dimensions
```

The squared dimensions comprise four entries equal to $1$, four equal to $2$,
and one equal to $4$.
Their sum is $16=\dim(\mathcal C)^2$. This is the familiar rank-nine center of
a split Ising category. Over a field supporting a nondegenerate Ising
braiding, the general equivalence
$\mathcal Z(\mathcal C)\simeq\mathcal C\boxtimes\mathcal C^{\mathrm{rev}}$
explains the nine simples [EGNO; §8.20](@cite).
This argument concerns a braided realization after extension; it does not
supply a braiding over the original field $K$.

`split(Z)` offers automatic field search for supported cases, including this
example. For number fields its current search uses minimal polynomials in
simple endomorphism algebras; it does not handle arbitrary noncommutative
division algebras. Here the explicit field $\mathbb Q(\zeta_{16})$ and
embedding suffice.

## From half-braidings to $F$- and $R$-symbols

```@example isingcenter
D = six_j_category(ZL)
@assert length(simples(D)) == 9
@assert is_braided(D)
@assert pentagon_axiom(D)
@assert hexagon_axiom(D)
F, R = F_symbols(D), R_symbols(D)
(length(F), length(R))
```

The $F$- and $R$-symbols use the decomposition bases chosen during
skeletonization, with the [matrix conventions](@ref f-conventions) and
[dictionary layout](@ref symbol-data) described earlier.

Ordinary `SixJCategory` coordinates require split simples. Trying to extract
such coordinates from the category with five simple objects over $K$ would
discard its nontrivial division algebras; scalar extension must come first.

Continue with [Relative centers](@ref centralizer), which retain
half-braidings only against a specified tensor subcategory.
