# [Representations of finite groups](@id representations)

Finite-group representations are a fundamental source of symmetric tensor
categories and the model behind ordinary finite-group symmetry. The
constructor realizes $\operatorname{Rep}_K(G)$ as in
[EGNO; Examples 2.3.4 and 2.10.13, pp. 26 and 43](@citet): the tensor product
uses the diagonal $G$-action, the unit is the trivial representation, and the
symmetry is the ordinary flip. The package uses row coordinates, so action
matrices and intertwiners multiply on the right. Explicitly, a stored row
vector transforms by $v\mathbin{\cdot}g=v\rho(g)$, and an intertwiner
$M:X\to Y$ satisfies
$\rho_X(g)M=M\rho_Y(g)$. This right-action convention is equivalent to the
usual left-action convention after replacing $g$ by $g^{-1}$.

`representation_category(K,G)` models finite-dimensional representations of a
finite group over the specified field. Objects store a group homomorphism into
a matrix group. Morphisms are intertwiners in the row-vector convention.
Use either `Representation(C,generators,matrices; check=false)` for an existing
category $C$, or `Representation(G,generators,matrices; check=false)` to infer
the field and parent category from the matrices. The corresponding overloads
with a Julia function evaluate that function on the package's generators.

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

The keyword defaults to `check=false` for both constructors.
`check=true` on `Representation` checks the group relations, while on
`morphism` it checks equivariance. Parent categories, endpoint dimensions, and
coefficient fields are checked regardless. Supply a generating set of $G$ and
one square action matrix for each generator, with a common size and coefficient
field. A generator image may have smaller order than the generator.

Tensor products use diagonal group actions; duals use contragredient actions;
the usual flip is symmetric in every characteristic. The canonical spherical
structure is implemented. Tensor-product matrices use Kronecker products, with
the coordinate from the right tensor factor varying fastest. No $F$-symbols are
required.

Equality of representations compares their parent categories and their action
matrices on the package's generators; representations related by a nontrivial
change of basis are generally only isomorphic. Use `is_isomorphic(X,Y)` for
that comparison. Two `GroupRepresentationCategory` values compare equal when
their stored groups and coefficient fields compare equal.

## Fields and enumeration

Maschke's theorem gives semisimplicity when the characteristic does not divide
$|G|$. Splitting is a further condition. The rational example above is simple
with a two-dimensional endomorphism field, so it is not absolutely simple.
Finiteness of $G$ is a hypothesis of this model and is not checked by the
constructor.

The no-field constructor `representation_category(G)` uses OSCAR's abelian
closure of `QQ`. Even if the category is mathematically finite, `simples(C)` is
not supported over every coefficient field. The current backend enumerates over
finite fields (and handles the trivial group directly); it does not enumerate
characteristic-zero irreducibles with their Schur-index information.
Constructing explicit representations and computing their Hom spaces still
works.

For small finite fields, the representation backend can enumerate simples and
decompose modules. In modular characteristic distinguish composition factors
from direct-sum summands. See [Splitting](@ref tensor-conventions).

Semisimplicity, splitting, and the distinction between simple and absolutely
simple objects follow the conventions of [EGNO; §§4.2 and 4.16](@citet).
