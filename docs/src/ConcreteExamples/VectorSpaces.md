# [Vector spaces and graded vector spaces](@id graded-spaces)

For `vector_spaces(K)`, objects carry bases and morphisms are row-coordinate
matrices. `VectorSpaceObject(C,n)` constructs an `n`-dimensional object.

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
differ in positive characteristic, where an integer dimension can reduce to zero.

## Finite group gradings

`graded_vector_spaces(K,G)` is the category of finite-dimensional $G$-graded
vector spaces. Its simple objects are one-dimensional spaces in degrees
$g\in G$. Tensor products multiply degrees in the order $gh$.

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

## Cocycle twists

`graded_vector_spaces(K,G,omega)` accepts a `Cocycle`. The associator on homogeneous
degrees $g,h,l$ is multiplied by $\omega(g,h,l)$, with the usual map from left to
right bracketing. The cocycle must be normalized and take invertible values.
The untwisted constructor supplies the trivial cocycle.

For a cyclic group of order $n$, `cyclic_group_3cocycle(G,K,xi)` uses the group
element returned by `G[1]` and the formula
```math
\omega(g^i,g^j,g^l)=\xi^{i\lfloor(j+l)/n\rfloor}
```
for exponents between $0$ and $n-1$. Supply an $n$th root of unity $\xi$ in
$K$, and ensure that `G[1]` generates the cyclic group. This fixes both the generator and cocycle
direction; the constructor does not check the cocycle hypotheses.

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
Braiding for a stored nontrivial cocycle is not implemented. In this case,
constructing the monoidal category does not by itself provide braided data.

The mathematical construction is described in [EGNO](@cite), §2.3.
The [implementation discussion](@ref concrete-models) explains the stored basis,
degree order, and restrictions on morphism matrices.
