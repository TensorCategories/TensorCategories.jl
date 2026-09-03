# [Matrix coordinates](@id matrix-realizations)

Coordinates from `express_in_basis(f,Hom(X,Y))` belong to one Hom space. A
global matrix realization is stronger: it assigns compatible coordinates to
objects as well as morphisms, so that identities and composition are expressed
by identity matrices and matrix multiplication. The method `matrix(f)` is
available only when the concrete category model provides such coordinates.

In many implemented models these coordinates come from a faithful $k$-linear
functor
```math
U:\mathcal C\longrightarrow\operatorname{Vec}_k
```
that is implicit in the representation. Each object has a vector space and a
basis, and `matrix(f)` represents $U(f)$. The realization can be encoded in the
stored objects and morphisms without being represented by a separate Julia
functor value. A model can also provide useful matrices by another documented
coordinate construction; the meaning of `matrix(f)` is therefore part of that
model's interface.

## Row-vector convention

TensorCategories.jl's matrix models use row coordinates: a morphism
$f:X\to Y$ has one matrix row per source basis vector and one column per target
basis vector. Consequently, for $f:X\to Y$ and $g:Y\to Z$,

```math
M_{g\circ f}=M_fM_g.
```

The following example uses ordinary finite-dimensional vector spaces only to
display this convention:

```@example matrix_coordinates
using TensorCategories, Oscar
V = vector_spaces(QQ)
X = VectorSpaceObject(V, 2)
Y = VectorSpaceObject(V, 3)
Z = VectorSpaceObject(V, 1)
f = morphism(X, Y, matrix(QQ, [1 0 2; 0 1 3]))
g = morphism(Y, Z, matrix(QQ, 3, 1, [1, 2, 3]))
@assert matrix(g ∘ f) == matrix(f)*matrix(g)
matrix(compose(f, g))
show(stdout, MIME"text/plain"(), matrix(compose(f, g))); println() # hide
```

Faithfulness does **not** make every matrix a categorical morphism. In
[representations](@ref representations) it must be an intertwiner; in
[graded spaces](@ref graded-spaces) it must preserve degrees. Computing
categorical kernels by linear algebra also needs exactness and reconstruction
of the categorical object and its maps.

## Linear coordinates do not determine tensor structure

A faithful linear realization need not preserve tensor products. Even when
`matrix(f)` and `matrix(g)` are defined, `matrix(f ⊗ g)` need not be the
ordinary Kronecker product: the source and target coordinates may be built from
decomposition bases or other model-specific choices. The category's
`tensor_product` and `associator` methods supply this additional structure.

A [fiber functor](@ref fiber-functors) is a much stronger realization: it is
exact, faithful, and coherently monoidal. The precise distinction is explained
under [Fiber functors and semisimple coordinates](@ref fiber-functors), after
the tensor and functor interfaces on which it depends.

Continue with [Direct sums, kernels, and decompositions](AbelianCategories.md).
