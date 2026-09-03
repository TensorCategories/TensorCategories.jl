# Direct sums, kernels, and decompositions

For the mathematical background, see [EGNO; Chapter 1](@citet). Direct sums
belong to the additive interface, kernels and cokernels to the abelian
interface, and decomposition into simples to a semisimple setting. A category
need not support all three levels. Here we specify the objects and structural
maps returned by the corresponding functions.

## Direct sums

```julia
D, i, p = direct_sum(X, Y)
```

If the summands are $X_1,\ldots,X_n$, the entries of $i$ are inclusions
$i_s:X_s\to D$, and those of $p$ are projections $p_r:D\to X_r$. They satisfy

```math
p_r\circ i_s=
\begin{cases}
\operatorname{id}_{X_s},&r=s,\\
0_{X_s,X_r},&r\ne s,
\end{cases}
\qquad
\sum_r i_r\circ p_r=\operatorname{id}_D,
```

`X ⊕ Y` returns only the object, and `zero(C)` is the zero object.

`direct_sum` also accepts larger nonempty families. Use `zero(C)` for the empty
direct sum; an empty collection of objects cannot determine its parent
category.

## Kernels and cokernels

For $f:X\to Y$:

| Call | Result | Equation |
|:---|:---|:---|
| `kernel(f)` | $(K,i)$ with $i:K\to X$ | $f\circ i=0$ |
| `cokernel(f)` | $(Q,p)$ with $p:Y\to Q$ | $p\circ f=0$ |
| `image(f)` | $(I,j)$ with $j:I\to Y$ | Image inclusion |

The generic image is the kernel of the cokernel. Implementations must satisfy
the universal properties, not only the displayed zero-composite equations. A
matrix nullspace also needs the category's additional structure.

```@example kernels
using TensorCategories, Oscar
V = vector_spaces(QQ)
X = VectorSpaceObject(V, 2)
f = morphism(X, X, matrix(QQ, [1 0; 0 0]))
K, i = kernel(f)
Q, p = cokernel(f)
@assert int_dim(K) == int_dim(Q) == 1
@assert is_zero(f ∘ i) && is_zero(p ∘ f)
(int_dim(K), int_dim(Q))
```

## Decomposition

For semisimple objects, `decompose(X)` returns pairs `(S,m)` of simple summands
and multiplicities. `simples(C)` enumerates simples when supported by the
backend over the current field.

Outside this setting, distinguish direct-sum decompositions into indecomposables
from `composition_factors(X)`. Composition factors do not assert that the
corresponding short exact sequences split; an injective map need not have a
left inverse.

Schur's lemma says that a simple object has a division endomorphism algebra
[EGNO; Lemma 1.5.2, p. 5](@cite). In a nonsemisimple category the converse
fails: an object with division endomorphism algebra need not be simple.
Consequently, an implementation must not use that condition alone as a
simplicity test outside a semisimple setting.

Continue with [Tensor products and duality](MonoidalCategories.md).
