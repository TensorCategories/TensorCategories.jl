# Hom spaces and linear algebra

TensorCategories.jl records linear enrichment and additive structure
separately. Thus `is_linear(C)` says that the Hom spaces are $k$-modules and
composition is $k$-bilinear, while `is_additive(C)` records finite biproducts
and a zero object. When $k$ is a field, the Hom spaces are $k$-vector spaces.
This differs slightly from the terminology of
[EGNO; Definition 1.2.2](@citet), where a $k$-linear category is additive by
definition. The package uses the same `base_ring(C)` interface over fields and
more general coefficient rings, but algorithms that divide by scalars or use
vector-space dimension require a field and finite-dimensional Hom spaces. This
chapter describes that field-linear setting.

| Operation | Result |
|:---|:---|
| `Hom(X,Y)` | An `AbstractHomSpace` for maps $X\to Y$ |
| `End(X)` | `Hom(X,X)` |
| `basis(H)` | A vector of basis morphisms |
| `int_dim(H)` | Dimension as a Julia integer |
| `zero_morphism(X,Y)` | The zero map |
| `a*f + b*g` | A linear combination of parallel maps |
| `express_in_basis(f,H)` | Coordinates in `basis(H)` |
| `endomorphism_ring(X)` | An associative algebra representing `End(X)` |

The last operation includes multiplication. Dimension alone does not determine
the algebra structure.

```@example homs
using TensorCategories, Oscar
V = vector_spaces(QQ)
X, Y = VectorSpaceObject(V, 2), VectorSpaceObject(V, 3)
H = Hom(X, Y)
@assert int_dim(H) == 6
B = basis(H)
f = 2*B[1] - B[end]
c = express_in_basis(f, H)
@assert sum(c[i]*B[i] for i in eachindex(B)) == f
c
```

A Hom basis is a choice, not an invariant. Coordinates of structural morphisms
must therefore be compared in compatible bases. In the later
[skeletal fusion model](@ref skeletal-fusion), this dependence becomes the
gauge dependence of $F$- and $R$-symbols; their bases and matrix directions are
fixed only after the model is introduced.

Over a non-splitting field, a simple object $S$ can have a division algebra
$D=\operatorname{End}(S)$ larger than $k$. In a semisimple category,
$\operatorname{Hom}(S,X)$ is a right $D$-module by precomposition, and the
multiplicity of $S$ in $X$ is its dimension over $D$, not generally its
dimension over $k$. See [Fusion categories and splitting](@ref
tensor-conventions).

Coordinates in each Hom space do not by themselves specify a functor on
objects to vector spaces. The next page explains when morphisms also have a
compatible global matrix realization.

Continue with [Matrix coordinates](@ref matrix-realizations).
