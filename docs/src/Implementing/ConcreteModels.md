# [Concrete models: graded spaces and representations](@id concrete-models)

The matrix tutorial can be extended by adding structure to each vector space
and restricting the allowed matrices. This is how the package implements
graded vector spaces and group representations. It need not first decompose
every tensor product into simples or compute any F-symbols.

## Graded vector spaces

For a finite group $G$, store a vector space together with the degree of each
basis vector. A morphism matrix may have a nonzero entry only between basis
vectors of the same degree. Give a tensor basis vector $v\otimes w$ degree
$\deg(v)\deg(w)$, in this order even for nonabelian $G$.

The existing representation uses `GVSObject` with fields `V` and `grading`,
and `GVSMorphism` with a matrix. Here is a computation with those types:

```@example concrete
using TensorCategories, Oscar
G = cyclic_group(3)
g = first(gens(G))
C = graded_vector_spaces(QQ, G)
X = C[one(G), g]
Y = C[g]
f = morphism(X, Y, matrix(QQ, 2, 1, [0, 1]))
@assert int_dim(Hom(X,Y)) == 1
@assert int_dim(X ⊗ Y) == 2
K, inclusion = kernel(f)
@assert int_dim(K) == 1 && is_zero(f ∘ inclusion)
matrix(f)
show(stdout, MIME"text/plain"(), matrix(f)); println() # hide
```

For the untwisted category, the associator is the canonical rebracketing map in
the chosen tensor bases. For a normalized $3$-cocycle $\omega$, modify the associator
on homogeneous tensors by $\omega(g,h,l)$. This is additional data, and its cocycle
equation is precisely the relevant coherence condition [EGNO](@cite), §2.3.
See the [catalogue entry](../ConcreteExamples/VectorSpaces.md) for constructors.

## Representations

For a representation, store the action of generators of $G$. A matrix $M$
from $X$ to $Y$ is a morphism when

```math
\rho_X(g)M=M\rho_Y(g)
```

for all generators. This is the row-vector convention. Solving these linear
equations gives a Hom basis. Direct sums use block actions and tensor products
use Kronecker products. Kernels of intertwiners are invariant subspaces; to
return a kernel object, restrict the group action to a basis of that subspace.

```@example concrete
R = representation_category(QQ, G)
A = matrix(QQ, [0 1; -1 -1])
V = Representation(R, gens(G), [A]; check=true)
@assert A^3 == identity_matrix(QQ,2)
@assert int_dim(End(V)) == 2
@assert is_simple(V)
int_dim(V ⊗ V)
```

This is a simple rational representation with endomorphism field
$\mathbb Q(\zeta_3)$. No F-symbol data were used. Enumeration of all rational irreducibles
is a separate backend capability, not a prerequisite for constructing this
object or computing its Hom spaces.

## From a concrete model to symbols

If the category is split and the necessary algorithms are available,
`six_j_category(C)` chooses decomposition bases and extracts associators in
those coordinates. A canonical vector-space rebracketing can become a
nonidentity F-matrix in those bases. See [F-symbol conventions](@ref f-conventions).

For non-split or nonsemisimple categories, the concrete model still supports
categorical operations even though the scalar F-symbol model does not apply.
[EGNO](@citet), §§2.3 and 5.1, describes the underlying forgetful functors.
