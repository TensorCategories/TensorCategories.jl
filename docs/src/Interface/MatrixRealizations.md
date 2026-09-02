# [Matrix realizations and fiber functors](@id matrix-realizations)

Often a faithful $k$-linear functor
```math
U:\mathcal C\longrightarrow\mathrm{Vec}_k
```
is implicit in the representation. Each object has a vector space and a basis,
and `matrix(f)` represents `U(f)`. This need not be an explicit Julia `Functor`
object. Identities, composition, sums, and scalar multiplication must still be
respected.

Faithfulness does **not** make every matrix a categorical morphism. In
representations it must be an intertwiner; in graded spaces it must preserve
degrees. Computing categorical kernels by linear algebra also needs exactness
and reconstruction of the categorical object and its maps.

## Fiber functors are stronger

In [EGNO](@citet), Definition 5.1.1, p. 91, a fiber functor is exact and
faithful and has
coherent tensor comparison isomorphisms
```math
J_{X,Y}:U(X)\otimes U(Y)\xrightarrow{\sim}U(X\otimes Y).
```
The usual forgetful functors for $\operatorname{Rep}_k(G)$ and untwisted
$\operatorname{Vec}_k(G)$ are fiber
functors (Example 5.1.2). A nontrivial cocycle twist can obstruct a fiber functor
for graded spaces [EGNO](@cite), Examples 5.1.2 and 5.1.3.

The package does **not** require every category to have a fiber functor.
For Fibonacci, $t\otimes t\cong\mathbb 1\oplus t$ would force
$n^2=1+n$ for the positive integer $n=\dim U(t)$, which is impossible.
Nevertheless we can use matrices.
This obstruction is already visible in the
[Grothendieck ring](@ref grothendieck-rings): it admits no dimension
homomorphism taking positive integer values on the simple classes.

## The split semisimple realization

With finitely many split simple representatives $S_i$, use
```math
U(X)=\bigoplus_i\operatorname{Hom}(S_i,X).
```
This functor is exact and faithful. With compatible bases, morphisms are families
of matrices, one per simple. This explains `SixJCategory`: `matrices(f)` returns
the blocks, and `matrix(f)` puts them on the diagonal. The dimension counts
simple multiplicities, not categorical or Frobenius–Perron dimension.

```@example realization
using TensorCategories, Oscar
C = fibonacci_category()
t = C[2]
@assert size(matrix(id(t))) == (1, 1)
@assert size(matrix(id(t ⊗ t))) == (2, 2)
size(matrix(id(t) ⊗ id(t)))
```

Even the dimensions prevent replacing `matrix(f ⊗ g)` by the ordinary Kronecker
product. The operations `tensor_product` and `associator` supply the tensor
structure separately.

In the non-split case retain $D_i=\operatorname{End}(S_i)$. Precomposition makes
$\operatorname{Hom}(S_i,X)$ a right $D_i$-module. Forgetting to $k$ still gives
a linear realization in the finite semisimple setting, but a copy of $S_i$
contributes $\dim_kD_i$
coordinates. The current scalar-block `SixJCategory` implements the split case.

Coordinate extraction needs faithful linear coordinates; endomorphism-algebra
calculations also need compatibility with composition. Neither alone implies
a monoidal realization.
