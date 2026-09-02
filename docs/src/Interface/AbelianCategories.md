# Direct sums, kernels, and decompositions

[EGNO](@citet), Chapter 1, is the mathematical reference. Here we specify
the returned objects and maps.

## Direct sums

```julia
D, i, p = direct_sum(X, Y)
```

The entries of $i$ are inclusions into $D$; those of $p$ are projections.
They satisfy $p_r\circ i_s=\delta_{r,s}$ and
$\sum_r i_r\circ p_r=\operatorname{id}_D$.
`X ⊕ Y` returns only the object. `zero(C)` is the zero object; `one(C)` is the
tensor unit.

Generic methods extend binary direct sums to larger families; specialized
methods can avoid repeated construction and composition of structure maps.
An empty family needs a specified category.

## Kernels and cokernels

For $f:X\to Y$:

| Call | Result | Equation |
|:---|:---|:---|
| `kernel(f)` | $(K,i)$ with $i:K\to X$ | $f\circ i=0$ |
| `cokernel(f)` | $(Q,p)$ with $p:Y\to Q$ | $p\circ f=0$ |
| `image(f)` | $(I,j)$ with $j:I\to Y$ | Image inclusion |

The generic image is the kernel of the cokernel. Universal properties, not just
the zero-composite equations, belong to the contract. A matrix nullspace also
needs the category's additional structure.

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

In a nonsemisimple category an object with division endomorphism algebra need
not be simple: the converse of Schur's lemma fails in this generality.
