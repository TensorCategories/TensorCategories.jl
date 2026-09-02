# [Representations of finite groups](@id representations)

`representation_category(K,G)` models finite-dimensional representations of a
finite group over the specified field. Objects store a group homomorphism into
a matrix group. Morphisms are intertwiners in the row-vector convention.

## Supplying action matrices

```@example representations
using TensorCategories, Oscar
G = cyclic_group(3)
C = representation_category(QQ,G)
A = matrix(QQ,[0 1; -1 -1])
X = Representation(C,gens(G),[A]; check=true)
@assert A^3 == identity_matrix(QQ,2)
@assert int_dim(End(X)) == 2
@assert is_simple(X)
f = morphism(X,X,A; check=true)
@assert matrix(f ∘ f) == A^2
int_dim(X ⊗ X)
```

`check=true` on `Representation` checks the group relations. On `morphism` it
checks equivariance. Endpoint dimensions and coefficient fields are checked
regardless. The supplied generators and matrices must have matching orders.

Tensor products use diagonal group actions; duals use contragredient actions;
the usual flip is symmetric in every characteristic. No F-symbols are required.

## Fields and enumeration

Maschke's theorem gives semisimplicity when the characteristic does not divide
$|G|$. Splitting is a further condition. The rational example above is simple
with a two-dimensional endomorphism field, so it is not absolutely simple.

The no-field constructor uses OSCAR's abelian closure of `QQ`. Even if the
category is mathematically finite, `simples(C)` is not supported over every
coefficient field. The current backend enumerates over finite fields (and
handles the trivial group directly); it does not enumerate characteristic-zero
irreducibles with their Schur-index information. Constructing explicit
representations and computing their Hom spaces still works.

For small finite fields, the representation backend can enumerate simples and
decompose modules. In modular characteristic distinguish composition factors
from direct-sum summands. See [Splitting](@ref tensor-conventions).

See [EGNO](@cite), §§2.3, 4.2, and 4.16.
