# [Fiber functors and semisimple coordinates](@id fiber-functors)

The presence of matrices in a category model does not imply a fiber functor.
In the split semisimple models discussed below, the matrices are coordinates
of a faithful linear realization, but that realization need not preserve tensor
products. The distinction matters because every finite split semisimple
category has this linear realization, whereas many fusion categories admit no
fiber functor.

## The split semisimple linear realization

Choose split simple representatives $S_1,\ldots,S_r$. The functor

```math
\label{eq:canonical-vector-space-realization}
U(X)=\bigoplus_{i=1}^r\operatorname{Hom}_{\mathcal C}(S_i,X)
```

is exact and faithful. After choosing bases of the Hom spaces, a morphism is
represented by one matrix block for each simple object. The package's later
[skeletal $F$-symbol model](@ref skeletal-fusion), implemented by `SixJCategory`,
uses precisely these coordinates: `matrices(f)` returns the blocks and
`matrix(f)` places them on the diagonal.
The dimension of $U(X)$ counts simple multiplicities; it is neither the
categorical dimension nor, in general, the Frobenius--Perron dimension.

For the supplied [Fibonacci category](../F-symbols/Fibonacci.md):

```@example realization
using TensorCategories, Oscar
C = fibonacci_category()
t = simples(C)[2]
@assert size(matrix(id(t))) == (1, 1)
@assert size(matrix(id(t ⊗ t))) == (2, 2)
size(matrix(id(t) ⊗ id(t)))
```

The functor $U$ is not generally monoidal. In the example, an isomorphism
$U(t)\otimes U(t)\cong U(t\otimes t)$ is already impossible because the two
spaces have dimensions $1$ and $2$. Thus `matrix(f ⊗ g)` is not obtained by
forming the Kronecker product of `matrix(f)` and `matrix(g)`; the tensor product
and associator use the category's fusion and decomposition data.

Over a non-splitting field, put $D_i=\operatorname{End}(S_i)$.
Precomposition makes $\operatorname{Hom}(S_i,X)$ a right $D_i$-module.
Forgetting these modules to the base field still gives a faithful linear
realization in the finite semisimple setting, but one copy of $S_i$ contributes
$\dim_kD_i$ coordinates. The scalar-block representation of `SixJCategory`
implements only the split case.

## When the realization is a fiber functor

A fiber functor on a ring category $\mathcal C$ over $k$ is an exact faithful
$k$-linear functor $F:\mathcal C\to\operatorname{Vec}_k$ equipped with a
compatible unit isomorphism and coherent tensor isomorphisms

```math
\label{eq:fiber-functor-tensorator}
J_{X,Y}:F(X)\otimes F(Y)\xrightarrow{\sim}F(X\otimes Y).
```

This is the definition used by
[EGNO; Definition 5.1.1, p. 91](@citet). The usual forgetful functors
for $\operatorname{Rep}_k(G)$ and untwisted $\operatorname{Vec}_G$ are
fiber functors [EGNO; Example 5.1.2](@cite). For
$\operatorname{Vec}_G^\omega$, a cohomologically nontrivial class
$[\omega]\in H^3(G,k^\times)$ prevents a fiber functor: coherent tensorators
would give a $2$-cochain whose coboundary trivializes $\omega$
[EGNO; Example 5.1.3](@cite).

The Fibonacci fusion rule $t\otimes t\cong\mathbb 1\oplus t$ gives a simple
obstruction. A fiber functor would assign a positive integer
$n=\dim_kF(t)$ satisfying $n^2=1+n$, which is impossible. Equivalently, the
[Grothendieck ring](@ref grothendieck-rings) has no dimension homomorphism that
takes positive integer values on its distinguished basis.

Coordinate extraction requires faithful linear coordinates and compatibility
with composition. A fiber functor supplies more: it identifies tensor products
coherently. TensorCategories.jl uses matrix coordinates without assuming this
extra structure.

Continue with the [implementation checklist](@ref interface-checklist), which
separates the operations required at each categorical level before the complete
matrix example implements them.
