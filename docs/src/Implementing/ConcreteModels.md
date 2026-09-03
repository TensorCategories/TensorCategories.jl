# [Concrete models: graded spaces and representations](@id concrete-models)

The matrix tutorial can be extended by adding structure to each vector space
and restricting the allowed matrices. This is how the package implements
graded vector spaces and group representations. It need not first decompose
every tensor product into simples or compute any $F$-symbols.

In both models, forgetting the additional structure gives a faithful linear
realization

```math
U:\mathcal C\longrightarrow\operatorname{Vec}_k,
```

and the stored matrix of a morphism represents its image under $U$. For
$\operatorname{Rep}_k(G)$ and untwisted graded vector spaces this is the usual
fiber functor. For a cocycle-twisted graded category it remains a faithful
linear realization, but a nontrivial cohomology class can obstruct compatible
tensorators. Thus concrete matrix coordinates do not by themselves require a
fiber functor; see [Fiber functors and semisimple coordinates](@ref fiber-functors).

## Graded vector spaces

For a finite group $G$, the category of finite-dimensional $G$-graded vector
spaces, with associator twisted by a normalized $3$-cocycle $\omega$, is
usually denoted $\operatorname{Vec}_G^\omega$. Store a vector space together
with the degree of each basis vector. A morphism matrix may have a nonzero entry
only between basis vectors of the same degree. Give a tensor basis vector
$v\otimes w$ degree $\deg(v)\deg(w)$, in this order even for nonabelian $G$.
Order the tensor basis so that the coordinate of $w$, the right factor, varies
fastest; then tensor products of morphisms are the corresponding Kronecker
products.

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
the chosen tensor bases. For a normalized $3$-cocycle $\omega$, modify the
associator on homogeneous tensors by $\omega(g,h,l)$. This is additional data,
and its cocycle equation is precisely the relevant coherence condition
[EGNO; §2.3](@cite).
A dual basis vector to one of degree $g$ has degree $g^{-1}$; in the twisted
case the evaluation normalization also depends on $\omega$. A braiding requires
compatible extra data and, in particular, is not supplied by an arbitrary group
grading or $3$-cocycle. The current `braiding` method is available only for an
untwisted category with a stored bilinear form: the ordinary constructor stores
the trivial form when $G$ is abelian, and the bilinear-form constructor permits
other choices. See the
[graded-vector-space catalogue entry](../ConcreteExamples/VectorSpaces.md) for
the exact implemented constructors and limitations.

## Representations

The same pattern implements $\operatorname{Rep}_k(G)$. Store the action of
generators of $G$ on each representation. A matrix $M$ from $X$ to $Y$ is a
morphism when

```math
\rho_X(g)M=M\rho_Y(g)
```

for all generators. This is the row-vector convention. Solving these linear
equations gives a Hom basis. Direct sums use block actions and tensor products
use Kronecker products, again with the right-factor coordinate varying fastest.
Kernels of intertwiners are invariant subspaces; to return a kernel object,
restrict the group action to a basis of that subspace.
The dual has the contragredient action
$\rho^*(g)=\rho(g^{-1})^{\mathsf T}$ in these row coordinates, and the ordinary
flip gives the symmetric braiding. These structures are implemented; see the
[representation catalogue entry](../ConcreteExamples/Representations.md).

```@example concrete
R = representation_category(QQ, G)
A = matrix(QQ, [0 1; -1 -1])
V = Representation(R, gens(G), [A]; check=true)
@assert A^3 == identity_matrix(QQ,2)
@assert int_dim(End(V)) == 2
@assert is_simple(V)
int_dim(V ⊗ V)
```

This is a simple rational representation whose endomorphism algebra is
isomorphic to $\mathbb Q(\zeta_3)$. No $F$-symbol data were used. Enumeration
of all rational irreducibles is a separate backend capability, not a
prerequisite for constructing this object or computing its Hom spaces.

These remain concrete category models: their objects and morphisms retain the
underlying graded spaces or representations. They do not need to be converted
to $F$-symbol data. If a split fusion category supports the necessary
decomposition algorithms, the later section on
[extracting a skeleton](@ref extracting-skeleton) explains how to choose
fusion bases and pass to such coordinates. Non-split and nonsemisimple concrete
models remain usable even when that scalar $F$-symbol construction does not
apply.

Continue with [Skeletal fusion categories](@ref skeletal-fusion), where a split
fusion category is represented by simple multiplicities and structural
matrices rather than by underlying vectors or group actions.
